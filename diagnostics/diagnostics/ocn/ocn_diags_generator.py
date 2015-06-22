#!/usr/bin/env python2
"""Generate ocn diagnostics from a CESM case 

This script provides an interface between:
1. the CESM case environment,
2. the ocean diagnostics environment defined in XML files,
3. the popdiag zonal average and plotting packages

It is called from the run script and resides in the $SRCROOT/postprocessing/cesm-env2.
and assumes that the ocn_avg_generator.py script has been run to generate the
ocean climatology files for the given run.
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

# import modules installed by pip into virtualenv
import jinja2

# import local modules for postprocessing
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

#import the diags classes
import ocn_diags_bc
import ocn_diags_factory

# import the plot classes
from diagnostics.ocn.Plots import ocn_diags_plot_bc
from diagnostics.ocn.Plots import ocn_diags_plot_factory

# define global debug message string variable
debugMsg = ''

#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():
    """Process the command line arguments.
    """
    parser = argparse.ArgumentParser(
        description='ocn_diags_generator: CESM wrapper python program for Ocean Diagnostics packages.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging '
                        'output')

    parser.add_argument('--debug', nargs=1, required=False, type=int, default=0,
                        help='debugging verbosity level output: 0 = none, 1 = minimum, 2 = maximum. 0 is default')

    parser.add_argument('--caseroot', nargs=1, required=True, 
                        help='fully quailfied path to case root directory')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = ' ERROR: ocn_diags_generator.py invalid option --caseroot {0}'.format(options.caseroot[0])
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
    avail_diags = ['MODEL_VS_OBS', 'MODEL_VS_OBS_ECOSYS', 'MODEL_VS_MODEL', 'MODEL_VS_MODEL_ECOSYS', 'TS', 'TS_ECOSYS']
    for diag in avail_diags:
        for key, value in envDict.iteritems():
            if (diag == key and value.upper() in ['T','TRUE']):
                requested_diags.append(key)

    return requested_diags


#============================================
# initialize_main - initialization from main
#============================================
def initialize_main(envDict, caseroot, debugMsg):
    """initialize_main - initialize settings on rank 0 
    
    Arguments:
    envDict (dictionary) - environment dictionary
    caseroot (string) - case root
    debugMsg (object) - vprinter object for printing debugging messages

    Return:
    envDict (dictionary) - environment dictionary
    """
    # setup envDict['id'] = 'value' parsed from the CASEROOT/[env_file_list] files
    env_file_list = ['env_case.xml', 'env_run.xml', 'env_build.xml', 'env_mach_pes.xml', 'env_postprocess.xml', 'env_diags_ocn.xml']
    envDict = cesmEnvLib.readXML(caseroot, env_file_list)

    # debug print out the envDict
    debugMsg('envDict after readXML = {0}'.format(envDict), header=True, verbosity=2)

    # refer to the caseroot that was specified on the command line instead of what
    # is read in the environment as the caseroot may have changed from what is listed
    # in the env xml
    envDict['CASEROOT'] = caseroot

    # add the os.environ['PATH'] to the envDict['PATH']
    envDict['OCNDIAG_PATH'] += os.pathsep + os.environ['PATH']

    # strip the OCNDIAG_ prefix from the envDict entries before setting the 
    # enviroment to allow for compatibility with all the diag routine calls
    envDict = diagUtilsLib.strip_prefix(envDict, 'OCNDIAG_')

    # special variable mapped from the CESM env to the OCN diags env
    envDict['RESOLUTION'] = envDict['OCN_GRID']

    # setup the TOBSFILE and SOBSFILE variables based on the vertical levels 
    # 60 (default) or 42
    if envDict['VERTICAL'] == '42':
        envDict['TOBSFILE'] = envDict['TOBSFILE_V42']
        envDict['SOBSFILE'] = envDict['SOBSFILE_V42']
    debugMsg('TOBSFILE = {0}, SOBSFILE= {1}'.format(envDict['TOBSFILE'], envDict['SOBSFILE']))

    # TODO - create the list of necessary climatology files for model
    filelist = list()

    # check average files
    debugMsg('calling checkAvgFiles', header=True)
    rc = diagUtilsLib.checkAvgFiles(filelist)
    if not rc:
        print('---------------------------------------------------------------------------')
        print('ERROR: ocean climatology files do not exist in:')
        print('   {0}'.format(envDict['TAVGDIR']))
        print('Please run the {0}.ocn_avg_generator script first.'.format(envDict['CASE']))
        print('---------------------------------------------------------------------------')
        sys.exit(1)

    # TODO - create the list of necessary climatology files for control

    return envDict

#======
# main
#======

def main(options, main_comm, debugMsg):
    """setup the environment for running the diagnostics in parallel. 

    Calls 6 different diagnostics generation types:
    model vs. observation (optional BGC - ecosystem)
    model vs. model (optional BGC - ecosystem)
    model time-series (optional BGC - ecosystem)

    Arguments:
    options (object) - command line options
    main_comm (object) - MPI simple communicator object
    debugMsg (object) - vprinter object for printing debugging messages

    The env_diags_ocn.xml configuration file defines the way the diagnostics are generated. 
    See (website URL here...) for a complete desciption of the env_diags_ocn XML options.
    """

    # initialize the environment dictionary
    envDict = dict()

    # CASEROOT is given on the command line as required option --caseroot
    if main_comm.is_manager():
        caseroot = options.caseroot[0]
        debugMsg('caseroot = {0}'.format(caseroot), header=True)

        debugMsg('calling initialize_main', header=True)
        envDict = initialize_main(envDict, caseroot, debugMsg)

        debugMsg('calling check_ncl_nco', header=True)
        diagUtilsLib.check_ncl_nco(envDict)

    # broadcast envDict to all tasks
    envDict = main_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)
    sys.path.append(envDict['PATH'])
    main_comm.sync()

    # get list of diagnostics types to be created
    diag_list = list()
    if main_comm.is_manager():
        diag_list = setup_diags(envDict)
        print('User requested diagnostics:')
        for diag in diag_list:
            print('  {0}'.format(diag))

        # TODO - create a jinja template for the main links to all the diag classes

    main_comm.sync()

    # TODO divide the main communicator into sub_communicators to be passed to each diag class
    num_of_diags = len(diag_list)
    min_diags_per_comm = 1

    # group[color_id] == intercommunicator
    size = main_comm.get_size()
    rank = main_comm.get_rank()

    # split mpi comm world
    temp_color = (rank % num_diags)
    if (temp_color == num_of_diags):
        temp_color = temp_color - 1
    groups = []
    for g in range(0,num_of_diags):
        groups.append(g)
    print 'g_rank:',rank,'size:',size,'temp_color:',temp_color,'#of groups',num_of_diags,'groups:',groups 
    group = groups[temp_color]
    inter_comm,multi_comm = spec.main_comm.divide(group)
    color = inter_comm.get_color()
    lsize = inter_comm.get_size()
    lrank = inter_comm.get_rank()
                
    #g_master = spec.main_comm.is_manager()
    l_master = inter_comm.is_manager()

    local_diag_list = list()
    if l_master:
        local_diag_list = multi_comm.partition(diag_list,func=partition.EqualStride(),involved=True)
        for b in range(1, lsize):
            diags_send = inter_comm.ration(data=local_diag_list, tag=DIAG_LIST_TAG) 
    else:
        diags_send = inter_comm.ration(tag=DIAG_LIST_TAG)

    for requested_diag in diags_send:
        try:
            diag = ocn_diags_factory.oceanDiagnosticsFactory(requested_diag)

            # check the prerequisites for the diagnostics types
            debugMsg('Checking prerequisites for {0}'.format(diag.__class__.__name__), header=True)
            
            if l_master:
                envDict = diag.check_prerequisites(envDict, debugMsg)

            # set the shell env using the values set in the XML and read into the envDict
            # across all tasks

            inter_comm.sync()
            cesmEnvLib.setXmlEnv(envDict)

            diag.run_diagnostics(envDict, inter_comm, debugMsg)
            
        except ocn_diags_bc.RecoverableError as e:
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
    main_comm = simplecomm.create_comm(serial=True)

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
            print('Successfully completed generating ocean diagnostics')
            print('***************************************************')
        sys.exit(status)

##    except RunTimeError as error:
        
    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)

