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
import fnmatch
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
# get_climo_files_to_regrid
#================================================
def get_climo_files_to_regrid(file_extensions, workdir, stream, env):
    """ get_climo_files_to_regrid - return a list of climo files that need to be 
        regrided in a given workdir.

        Input:
        file_extensions (list) - list of file extensions of associated files to be regridded.
                                 This list also defines the names of the subdirectories to
                                 be used to setup the regridding in parallel.
        workdir (string) - location of climo files to be regridded
        stream (string) - lnd history stream used in filename
        env (dict) - environment dictionary

        Return:
        climo_files (dict) - dictionary of climo files to be regridded
     """
    climo_files_dict = dict()
    current_dir = os.getcwd()
    os.chdir(workdir)

    endYr = str((int(env['clim_first_yr_1']) + int(env['clim_num_yrs_1'])) - 1)
    file_prefix = '{0}.{1}.{2}-{3}'.format(env['caseid_1'], stream, env['clim_first_yr_1'].zfill(4), endYr.zfill(4))
    
    trends_endYr = str((int(env['trends_first_yr_1']) + int(env['trends_num_yrs_1'])) - 1)
    trends_file_ANN_ALL = '{0}.{1}.{2}-{3}.ANN_ALL.nc'.format(env['caseid_1'], stream, env['trends_first_yr_1'].zfill(4), trends_endYr.zfill(4))

    # build up the dictionary of climo files to be regridded
    for filename in os.listdir('.'):
        print('DEBUG: in get_climo_files_to_regrid filename = {0}'.format(filename))

        for ext in file_extensions:
            if fnmatch.fnmatch(filename, '{0}.{1}.nc'.format(file_prefix, ext)):
                climo_files_dict[ext] = filename
                print('DEBUG: matching fn {0} = {1}'.format(climo_files_dict[ext], filename))
        
        if fnmatch.fnmatch(filename, trends_file_ANN_ALL):
            climo_files_dict['trends_ANN_ALL'] = filename

    # create the temporary work directories for each climo file
    for ext_dir, climo_file in climo_files_dict.iteritems():
        tmp_workdir = '{0}/{1}'.format(workdir, ext_dir)
        try:
            os.makedirs(tmp_workdir)
        except OSError as e:
            if e.errno != errno.EEXISTS:
                err_msg = 'ERROR: problem accessing the regridding working directory (0}'.format(tmp_workdir)
                raise OSError(err_msg)

    os.chdir(current_dir)
    return climo_files_dict

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
 
    climo_files_dict = dict()
    env['NCLPATH'] = env['POSTPROCESS_PATH']+'/lnd_diag/shared/'   

    # If SE grid, convert to lat/lon grid
    regrid_script = 'se2fv_esmf.regrid2file.ncl'

    # define list of file extensions of associated files to be regridded
    file_extensions = ['_MONS_climo', '_ANN_climo', '_ANN_means',
                       '_DJF_climo', '_DJF_means', '_JJA_climo', '_JJA_means',
                       '_MAM_climo', '_MAM_means', '_SON_climo', '_SON_means']

    # Convert Case1
    m_dir = 'lnd'
    if (env['regrid_1'] == 'True'):
        # get list of climo files to regrid
        # create the working directory first before calling the base class prerequisites
        endYr = (int(env['clim_first_yr_1']) + int(env['clim_num_yrs_1'])) - 1
        subdir = '{0}.{1}-{2}'.format(env['caseid_1'], env['clim_first_yr_1'], endYr)
        workdir = '{0}/climo/{1}/{2}/{3}/'.format(env['PTMPDIR_1'], env['caseid_1'], subdir, m_dir)
        print('LOOKING TO REGRID IN: '+workdir)
#        climo_files = glob.glob( workdir+'/*.nc')
        if main_comm.is_manager():
            climo_files_dict = get_climo_files_to_regrid(file_extensions, workdir, env['lnd_modelstream_1'], env)
            for ext, filename in climo_files_dict.iteritems():
                print('DEBUG: regridding climo_files_dict[{0}] = {1}'.format(ext, filename))
        main_comm.sync()

        # broadcast the climo_files_dict to all tasks
        climo_files_dict = main_comm.partition(data=climo_files_dict, func=partition.Duplicate(), involved=True)

        # partition the climo files between the ranks so each rank will get a portion of the dictionary to regrid
        local_file_extensions = main_comm.partition(file_extensions, func=partition.EqualStride(), involved=True)

        env['WORKDIR'] = workdir
        current_dir = os.getcwd()
        os.chdir(workdir)
        for ext_dir in local_file_extensions:
            diagUtilsLib.lnd_regrid(climo_files_dict[ext_dir], regrid_script, '1', workdir, ext_dir, env)
        os.chdir(current_dir)

    # Convert Case2
    if (env['MODEL_VS_MODEL'] == 'True' and env['regrid_2'] == 'True'):
        # get list of climo files to regrid
        endYr = (int(env['clim_first_yr_2']) + int(env['clim_num_yrs_2'])) - 1
        subdir = '{0}.{1}-{2}'.format(env['caseid_2'], env['clim_first_yr_2'], endYr)
        workdir = '{0}/climo/{1}/{2}/{3}/'.format(env['PTMPDIR_2'], env['caseid_2'], subdir, m_dir)
        print('LOOKING TO REGRID IN: '+workdir)
#        climo_files = glob.glob(workdir+'/*.nc')
        if main_comm.is_manager():
            climo_files_dict = get_climo_files_to_regrid(file_extensions, workdir, env['lnd_modelstream_2'], env)
        main_comm.sync()

        # partition the climo files between the ranks so each rank will get a portion of the list to regrid
        local_climo_files = main_comm.partition(climo_files, func=partition.EqualStride(), involved=True)
        env['WORKDIR'] = workdir
##        for climo_file in local_climo_files:
##            diagUtilsLib.lnd_regrid(climo_file, regrid_script, '2', workdir, env)

    main_comm.sync()
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
    env_file_list = ['../env_case.xml', '../env_run.xml', '../env_build.xml', '../env_mach_pes.xml', './env_postprocess.xml', './env_diags_lnd.xml']
    envDict['STANDALONE'] = False
    if standalone:
        env_file_list =  ['./env_postprocess.xml', './env_diags_lnd.xml']
        envDict['STANDALONE'] = True
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


    # setup the working directories
    sys.path.append(envDict['PATH'])

    # the WKDIR variable is very confusing... it gets reset in setup_workdir
    if (envDict['MODEL_VS_MODEL'] == 'True'):
        envDict['WKDIR'] =  envDict['PTMPDIR_1']+'/diag/'+envDict['caseid_1']+'-'+envDict['caseid_2']+'/'
    else:
        envDict['WKDIR'] =  envDict['PTMPDIR_1']+'/diag/'+envDict['caseid_1']+'-obs/'

    if envDict['CASA'] == '1':
        envDict['VAR_MASTER'] = envDict['var_master_casa']
    else:
        envDict['VAR_MASTER'] = envDict['var_master_cn']

    # setup of the web_path_file text file in config_web
    debugMsg('Setting up config_web/web_paths_lnd.txt', header=True, verbosity=1)

    envDict['WEB_PATH_FILE'] = '{0}/config_web/web_paths_lnd.txt'.format(envDict['CASEROOT'])
    if os.path.exists(envDict['WEB_PATH_FILE']):
        os.utime(envDict['WEB_PATH_FILE'], None)
    else:
        open(envDict['WEB_PATH_FILE'],'a').close()

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
        debugMsg('global_rank {0}, temp_color {1}, #of groups(diag types) {2}, groups {3}, diag_list {4}'.format(grank, temp_color, num_of_diags, groups, diag_list), header=True, verbosity=2)
        group = groups[temp_color]
        inter_comm, multi_comm = main_comm.divide(group)
        color = inter_comm.get_color()
        lsize = inter_comm.get_size()
        lrank = inter_comm.get_rank()
        lmaster = inter_comm.is_manager()
        if lmaster:
            debugMsg('color {0}, lsize {1}, lrank {2}, lmaster {3}'.format(color, lsize, lrank, lmaster), header=True, verbosity=2)

        # partition the diag_list between communicators
        DIAG_LIST_TAG = 10
        if lmaster:
            local_diag_list = multi_comm.partition(diag_list,func=partition.EqualStride(),involved=True)
            for b in range(1, lsize):
                diags_send = inter_comm.ration(data=local_diag_list, tag=DIAG_LIST_TAG)
        else:
            local_diag_list = inter_comm.ration(tag=DIAG_LIST_TAG)
        if lmaster:
            debugMsg('local_diag_list {0}',format(local_diag_list), header=True)
    else:
        inter_comm = main_comm
        lmaster = main_comm.is_manager()
        lsize = main_comm.get_size()
        lrank = main_comm.get_rank()
        local_diag_list = diag_list

    inter_comm.sync()
    main_comm.sync()    
    
    if lmaster:
        debugMsg('lsize = {0}, lrank = {1}'.format(lsize, lrank), header=True, verbosity=2)
    inter_comm.sync()

    web_dir_ic_tag = 1
    web_dir_mc_tag = 2
    
    ic_web_info = dict()
    mc_web_info = dict()

    # loop through the local_diag_list list
    for requested_diag in local_diag_list:
        try:
            diag = lnd_diags_factory.landDiagnosticsFactory(requested_diag,envDict)

            # check the prerequisites for the diagnostics types
            if lmaster:
                debugMsg('Checking prerequisites for {0}'.format(diag.__class__.__name__), header=True)
            
            envDict = diag.check_prerequisites(envDict, inter_comm)
            inter_comm.sync()

            # broadcast the envDict
            envDict = inter_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)
         
            # set the shell env using the values set in the XML and read into the envDict across all tasks
            cesmEnvLib.setXmlEnv(envDict)

            # debug check if the envDict contains a non-string entry
            if lmaster:
                for k,v in envDict.iteritems():
                    if not isinstance(v, basestring):
                        debugMsg('lnd_diags_generator - envDict: key = {0}, value = {1}'.format(k,v), header=True, verbosity=2)

            debugMsg('inter_comm size = {0}'.format(inter_comm.get_size()), header=True, verbosity=2)
            envDict = diag.run_diagnostics(envDict, inter_comm)

            if lmaster:
                debugMsg('after run_diagnostics', header=True, verbosity=1)

            web_info = dict()
            for key in envDict:
                if 'LNDDIAG_WEBDIR' in key:
                    web_info[key] = envDict[key]

            if lsize > 1:
                if not lmaster:
                    debugMsg('lnd_diags_generator before collection not on master rank = {0}'.format(inter_comm.get_rank()), header=True, verbosity=1)
                    inter_comm.collect(data=web_info, tag=web_dir_tag)
                else:
                    debugMsg('lnd_diags_generator before collection on master', header=True, verbosity=1)
                    rank, tmp_web_info = inter_comm.collect(tag=web_dir_tag)
                    ic_web_info.update(web_info)
                    ic_web_info.update(tmp_web_info)
            else:
                ic_web_info.update(web_info)

            inter_comm.sync()

            if lmaster:
                for k,v in ic_web_info.iteritems():
                    debugMsg('lnd_diags_generator ic_web_info[{0}] = {1}'.format(k,v), header=True, verbosity=1)

        except lnd_diags_bc.RecoverableError as e:
            # catch all recoverable errors, print a message and continue.
            print(e)
            print("Skipped '{0}' and continuing!".format(request_diag))
        except RuntimeError as e:
            # unrecoverable error, bail!
            print(e)
            return 1

    inter_comm.sync()
    main_comm.sync()

    # update the env_diags_lnd.xml with LNDIAG_WEBDIR settings to be used by the copy_html utility
    if main_comm.is_manager():
        for k, v in ic_web_info.iteritems():
            debugMsg('lnd_diags_generator: all ic_web_info[{0}] = {1}'.format(k, v), header=True, verbosity=1)


#===================================


if __name__ == "__main__":
    # initialize simplecomm object
    main_comm = simplecomm.create_comm(serial=False)

    # setup an overall timer
    timer = timekeeper.TimeKeeper()

    # get commandline options
    options = commandline_options()

    # initialize global vprinter object for printing debug messages
    # TODO - if debug option is not set, then debugMsg shouldn't fail
    if options.debug:
        header = "[" + str(main_comm.get_rank()) + "/" + str(main_comm.get_size()) + "]: DEBUG... "
        debugMsg = vprinter.VPrinter(header=header, verbosity=options.debug[0])
    
    try:
        timer.start("Total Time")
        status = main(options, main_comm, debugMsg)
        main_comm.sync()
        timer.stop("Total Time")
        if main_comm.is_manager():
            print('***************************************************')
            print('Run copy_html utility to copy web files and plots to a remote web server')
            print('Total Time: {0} seconds'.format(timer.get_time("Total Time")))
            print('Successfully completed generating land diagnostics')
            print('***************************************************')
        sys.exit(status)

    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)

