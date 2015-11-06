#!/usr/bin/env python2
"""Generate lnd diagnostics from a CESM case 

This script provides an interface between:
1. the CESM case environment,
2. the land diagnostics environment defined in XML files,
3. the popdiag zonal average and plotting packages

It is called from the run script and resides in the $SRCROOT/postprocessing/cesm-env2.
and assumes that the lnd_avg_generator.py script has been run to generate the
land climatology files for the given run.
__________________________
Created on October 28, 2014

Author: CSEG <cseg@cgd.ucar.edu>
"""

from __future__ import print_function
import sys

# check the system python version and require 2.7.x or greater
if sys.hexversion < 0x02070000:
    print(70 * '*')
    print('ERROR: {0} requires python >= 2.7.x. '.format(sys.argv[0]))
    print('It appears that you are running python {0}'.format(
        '.'.join(str(x) for x in sys.version_info[0:3])))
    print(70 * '*')
    sys.exit(1)

# import core python modules
import argparse
import os
import re
import traceback

# import local modules for postprocessing
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

#import the diagnosticss classes
from diagnostics.lnd import lnd_diags_bc
from diagnostics.lnd import lnd_diags_factory

# define global debug message string variable
debugMsg = ''

#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():
    """Process the command line arguments.
    """
    parser = argparse.ArgumentParser(
        description='lnd_diags_generator: CESM wrapper python program for Land Diagnostics packages.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging '
                        'output')

    parser.add_argument('--debug', nargs=1, required=False, type=int, default=0,
                        help='debugging verbosity level output: 0 = none, 1 = minimum, 2 = maximum. 0 is default')

    parser.add_argument('--caseroot', nargs=1, required=True, 
                        help='fully quailfied path to case root directory')

    parser.add_argument('--standalone', action='store_true',
                        help='switch to indicate stand-alone post processing caseroot')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = ' ERROR: lnd_diags_generator.py invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options


#================================================
# setup_diags - get the list of diags to generate
#================================================
def setup_diags(envDict):
    """setup_diags - read the XML directives on which diagnostics to create

       Return:
       requested_diags (list) - list of diagnostics classes to be generated
    """
    requested_diags = []
    avail_diags = ['MODEL_VS_OBS', 'MODEL_VS_MODEL']
    for key, value in envDict.iteritems():
        if (key in avail_diags and value == 'True'):
            requested_diags.append(key)

    return requested_diags


#================================================
# regrid 
#================================================
def regrid_climos(env,main_comm):
    """ regrid_climos - regrid the climos into a lat/lon grid
    """

    import glob  
    if main_comm.is_manager():
        if not os.path.exists(env['WKDIR']):
            os.makedirs(env['WKDIR'])
    main_comm.sync()
 
    env['NCLPATH'] = env['POSTPROCESS_PATH']+'/lnd_diag/shared/'   

    # If SE grid, convert to lat/lon grid
    regrid_script = 'se2fv_esmf.regrid2file.ncl'
    # Convert Case1
    m_dir = 'lnd'
    if (env['regrid_1'] == 'True'):
        # get list of climo files to regrid
        # create the working directory first before calling the base class prerequisites
        endYr = (int(env['clim_first_yr_1']) + int(env['clim_num_yrs_1'])) - 1
        subdir = '{0}.{1}-{2}'.format(env['caseid_1'], env['clim_first_yr_1'], endYr)
        workdir = '{0}/climo/{1}/{2}/{3}/'.format(env['PTMPDIR_1'], env['caseid_1'], subdir, m_dir)
        print('LOOKING TO REGRID IN: '+workdir)
        climo_files = glob.glob( workdir+'/*.nc')
        # partition the climo files between the ranks so each rank will get a portion of the list to regrid
        local_climo_files = main_comm.partition(climo_files, func=partition.EqualStride(), involved=True)
        env['WORKDIR'] = workdir
        current_dir = os.getcwd()
        os.chdir(workdir)
        for climo_file in local_climo_files:
            diagUtilsLib.lnd_regrid(climo_file, regrid_script, '1', workdir, env)
        os.chdir(current_dir)
    # Convert Case2
    if (env['MODEL_VS_MODEL'] == 'True' and env['regrid_2'] == 'True'):
        # get list of climo files to regrid
        endYr = (int(env['clim_first_yr_2']) + int(env['clim_num_yrs_2'])) - 1
        subdir = '{0}.{1}-{2}'.format(env['caseid_2'], env['clim_first_yr_2'], endYr)
        workdir = '{0}/climo/{1}/{2}/{3}/'.format(env['PTMPDIR_2'], env['caseid_2'], subdir, m_dir)
        climo_files = glob.glob(workdir+'/*.nc')
        # partition the climo files between the ranks so each rank will get a portion of the list to regrid
        local_climo_files = main_comm.partition(climo_files, func=partition.EqualStride(), involved=True)
        env['WORKDIR'] = workdir
        for climo_file in local_climo_files:
            diagUtilsLib.lnd_regrid(climo_file, regrid_script, '2', workdir, env)
    env['WORKDIR'] = env['WKDIR']
    print("Finished regridding, id: "+str(main_comm.get_rank()))

#============================================
# initialize_main - initialization from main
#============================================
def initialize_main(envDict, caseroot, debugMsg, standalone):
    """initialize_main - initialize settings on rank 0 
    
    Arguments:
    envDict (dictionary) - environment dictionary
    caseroot (string) - case root
    debugMsg (object) - vprinter object for printing debugging messages

    Return:
    envDict (dictionary) - environment dictionary
    """
    # setup envDict['id'] = 'value' parsed from the CASEROOT/[env_file_list] files
    env_file_list = ['env_case.xml', 'env_run.xml', 'env_build.xml', 'env_mach_pes.xml', 'env_postprocess.xml', 'env_diags_lnd.xml']
    if standalone:
        env_file_list =  ['env_postprocess.xml', 'env_diags_lnd.xml']
    envDict = cesmEnvLib.readXML(caseroot, env_file_list)

    # debug print out the envDict
    debugMsg('envDict after readXML = {0}'.format(envDict), header=True, verbosity=2)

    # refer to the caseroot that was specified on the command line instead of what
    # is read in the environment as the caseroot may have changed from what is listed
    # in the env xml
    envDict['CASEROOT'] = caseroot

    # add the os.environ['PATH'] to the envDict['PATH']
    envDict['LNDDIAG_PATH'] = os.pathsep + os.environ['PATH']

    # strip the LNDDIAG_ prefix from the envDict entries before setting the 
    # enviroment to allow for compatibility with all the diag routine calls
    envDict = diagUtilsLib.strip_prefix(envDict, 'LNDDIAG_')

    # TODO - create the list of necessary climatology files for model
    filelist = list()

    # check average files
    debugMsg('calling checkAvgFiles', header=True)
    rc = diagUtilsLib.checkAvgFiles(filelist)
    if not rc:
        print('---------------------------------------------------------------------------')
        print('ERROR: land climatology files do not exist')
        print('Please run the {0}.lnd_avg_generator script first.'.format(envDict['CASE']))
        print('---------------------------------------------------------------------------')
        sys.exit(1)

    # TODO - create the list of necessary climatology files for control

    return envDict

#======
# main
#======

def main(options, main_comm, debugMsg):
    """setup the environment for running the diagnostics in parallel. 

    Calls 2 different diagnostics generation types:
    model vs. observation 
    model vs. model 

    Arguments:
    options (object) - command line options
    main_comm (object) - MPI simple communicator object
    debugMsg (object) - vprinter object for printing debugging messages

    The env_diags_lnd.xml configuration file defines the way the diagnostics are generated. 
    See (website URL here...) for a complete desciption of the env_diags_lnd XML options.
    """

    # initialize the environment dictionary
    envDict = dict()

    # CASEROOT is given on the command line as required option --caseroot
    if main_comm.is_manager():
        caseroot = options.caseroot[0]
        debugMsg('caseroot = {0}'.format(caseroot), header=True)

        debugMsg('calling initialize_main', header=True)
        envDict = initialize_main(envDict, caseroot, debugMsg, options.standalone)

        debugMsg('calling check_ncl_nco', header=True)
        diagUtilsLib.check_ncl_nco(envDict)

    # broadcast envDict to all tasks
    envDict = main_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)
    sys.path.append(envDict['PATH'])
    if (envDict['MODEL_VS_MODEL'] == 'True'):
        envDict['WKDIR'] =  envDict['PTMPDIR_1']+'/diag/'+envDict['caseid_1']+'-'+envDict['caseid_2']+'/'
    else:
        envDict['WKDIR'] =  envDict['PTMPDIR_1']+'/diag/'+envDict['caseid_1']+'-obs/'
    if envDict['CASA'] == '1':
        envDict['VAR_MASTER'] = envDict['var_master_casa']
    else:
        envDict['VAR_MASTER'] = envDict['var_master_cn']
    main_comm.sync()

    # check to see if the climos need to be regridded into a lat/lon grid
    if (envDict['regrid_1'] == 'True' or envDict['regrid_2'] == 'True'):
        regrid_climos(envDict, main_comm)
    main_comm.sync()

    # get list of diagnostics types to be created
    diag_list = list()
    diag_list = setup_diags(envDict)
    if  main_comm.is_manager():
        print('User requested diagnostics:')
        for diag in diag_list:
            print('  {0}'.format(diag))

    main_comm.sync()

    # broadcast the diag_list to all tasks
    num_of_diags = len(diag_list)
    num_of_diags = main_comm.partition(num_of_diags, func=partition.Duplicate(), involved=True)
    diag_list = main_comm.partition(data=diag_list, func=partition.Duplicate(), involved=True)
    main_comm.sync()

    # initialize some variables for distributing diagnostics across the communicators
    diags_send = diag_list
    gmaster = main_comm.is_manager()
    gsize = main_comm.get_size()
    grank = main_comm.get_rank()
    local_diag_list = list()

    # divide the main communicator into sub_communicators to be passed to each diag class
    # split mpi comm world if the size of the communicator > 1 and the num_of_diags > 1
    if gsize > 1 and num_of_diags > 1:
        temp_color = (grank % num_of_diags)
        if (temp_color == num_of_diags):
            temp_color = temp_color - 1
        groups = list()
        for g in range(0,num_of_diags):
            groups.append(g)
        debugMsg('global_rank {0}, temp_color {1}, #of groups(diag types) {2}, groups {3}, diag_list {4}'.format(grank, temp_color, num_of_diags, groups, diag_list))
        group = groups[temp_color]
        inter_comm, multi_comm = main_comm.divide(group)
        color = inter_comm.get_color()
        lsize = inter_comm.get_size()
        lrank = inter_comm.get_rank()
        lmaster = inter_comm.is_manager()
        debugMsg('color {0}, lsize {1}, lrank {2}, lmaster {3}'.format(color, lsize, lrank, lmaster))

        # partition the diag_list between communicators
        DIAG_LIST_TAG = 10
        if lmaster:
            local_diag_list = multi_comm.partition(diag_list,func=partition.EqualStride(),involved=True)
            for b in range(1, lsize):
                diags_send = inter_comm.ration(data=local_diag_list, tag=DIAG_LIST_TAG)
        else:
            local_diag_list = inter_comm.ration(tag=DIAG_LIST_TAG)
        debugMsg('local_diag_list {0}',format(local_diag_list))
    else:
        inter_comm = main_comm
        lmaster = main_comm.is_manager()
        lsize = main_comm.get_size()
        lrank = main_comm.get_rank()
        local_diag_list = diag_list

    inter_comm.sync()
    main_comm.sync()    
    
    debugMsg('lsize = {0}, lrank = {1}'.format(lsize, lrank))
    inter_comm.sync()

    # loop through the local_diag_list list
    for requested_diag in local_diag_list:
        try:
            diag = lnd_diags_factory.landDiagnosticsFactory(requested_diag,envDict)

            # check the prerequisites for the diagnostics types
            debugMsg('Checking prerequisites for {0}'.format(diag.__class__.__name__), header=True)
            
            #if lmaster:
            envDict = diag.check_prerequisites(envDict, inter_comm)

            inter_comm.sync()

            ## broadcast the envDict
            #envDict = inter_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)
         
            # set the shell env using the values set in the XML and read into the envDict across all tasks
            #cesmEnvLib.setXmlEnv(envDict)

            debugMsg('inter_comm = {0}'.format(inter_comm))
            diag.run_diagnostics(envDict, inter_comm)
            
        except lnd_diags_bc.RecoverableError as e:
            # catch all recoverable errors, print a message and continue.
            print(e)
            print("Skipped '{0}' and continuing!".format(request_diag))
        except RuntimeError as e:
            # unrecoverable error, bail!
            print(e)
            return 1

    main_comm.sync()


#===================================


if __name__ == "__main__":
    # initialize simplecomm object
    main_comm = simplecomm.create_comm(serial=False)

    # get commandline options
    options = commandline_options()

    # initialize global vprinter object for printing debug messages
    # TODO - if debug option is not set, then debugMsg shouldn't fail
    if options.debug:
        header = "[" + str(main_comm.get_rank()) + "/" + str(main_comm.get_size()) + "]: DEBUG... "
        debugMsg = vprinter.VPrinter(header=header, verbosity=options.debug[0])
    
    try:
        status = main(options, main_comm, debugMsg)
        main_comm.sync()
        if main_comm.is_manager():
            print('***************************************************')
            print('Successfully completed generating land diagnostics')
            print('***************************************************')
        sys.exit(status)

##    except RunTimeError as error:
        
    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)
