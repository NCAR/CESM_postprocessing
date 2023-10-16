#!/usr/bin/env python
"""Generate regridded land climatology and means files

This script provides an interface between:
1. the CESM case environment and/or postprocessing environment
2. the land diagnostics environment defined in XML files

It is called from the run script and resides in the $SRCROOT/postprocessing/cesm-env2.
and assumes that the lnd_avg_generator.py script has been run to generate the
land climatology files for the given run.
__________________________
Created on May, 2016

Author: CSEG <cseg@cgd.ucar.edu>
"""

from __future__ import print_function
import sys

# check the system python version and require 3.7.x or greater
if sys.hexversion < 0x03070000:
    print(70 * '*')
    print('ERROR: {0} requires python >= 3.7.x. '.format(sys.argv[0]))
    print('It appears that you are running python {0}'.format(
        '.'.join(str(x) for x in sys.version_info[0:3])))
    print(70 * '*')
    sys.exit(1)

# import core python modules
import argparse
import fnmatch
import errno
import os
import re
import traceback

# import local modules for postprocessing
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# import the diagnostics classes
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
        description='lnd_regrid_generator: CESM wrapper python program for Land Diagnostics regridding packages.')

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
        err_msg = ' ERROR: lnd_regrid_generator.py invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options

#================================================
# get_climo_files_to_regrid
#================================================
def get_climo_files_to_regrid(workdir, stream, t, env, debugMsg):
    """ get_climo_files_to_regrid - return a list of climo files that need to be 
        regrided in a given workdir.

        Input:
        workdir (string) - location of climo files to be regridded
        stream (string) - lnd history stream used in filename
        env (dict) - environment dictionary
        t (string) - model designation 1 or 2
        debugMsg (object) - debug message object

        Return:
        climo_files (dict) - dictionary of climo files to be regridded
     """

    # define list of file extensions of associated files to be regridded 
    # this also defines the subdirectories
    file_extensions = ['ANN_ALL', '_ANN_climo', 'MONS_climo', '_DJF_climo',
                       '_ANN_means', '_JJA_climo', '_DJF_means', '_JJA_means',
                       '_MAM_climo', '_MAM_means', '_SON_climo', '_SON_means']

    climo_files = list()
    current_dir = os.getcwd()
    os.chdir(workdir)

    endYr = str((int(env['clim_first_yr_'+t]) + int(env['clim_num_yrs_'+t])) - 1)
    file_prefix = '{0}.{1}.{2}-{3}'.format(env['caseid_'+t], stream, env['clim_first_yr_'+t].zfill(4), endYr.zfill(4))
    
    # trends file may have different years
    trends_endYr = str((int(env['trends_first_yr_'+t]) + int(env['trends_num_yrs_'+t])) - 1)
    trends_file_ANN_ALL = '{0}.{1}.{2}-{3}.ANN_ALL.nc'.format(env['caseid_'+t], stream, env['trends_first_yr_'+t].zfill(4), trends_endYr.zfill(4))

    # build up the list of climo files to be regridded
    for filename in os.listdir('.'):
        # place the largest file at the beginning of the list
        if fnmatch.fnmatch(filename, trends_file_ANN_ALL):
            climo_files.append([t, 'ANN_ALL',filename])

    for filename in os.listdir('.'):
        for ext in file_extensions:
            if fnmatch.fnmatch(filename, '{0}.{1}.nc'.format(file_prefix, ext)):
                climo_files.append([t,ext, filename])

    # create the temporary work directories for each climo file extension
    for ext in file_extensions:
        tmp_workdir = '{0}/{1}'.format(workdir, ext)
        debugMsg('checking tmp_workdir = {0}'.format(tmp_workdir), header=True, verbosity=1)
        if not os.path.isdir(tmp_workdir):
            os.makedirs(tmp_workdir)

    os.chdir(current_dir)
    return climo_files

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
##    env_file_list = ['../env_case.xml', '../env_run.xml', '../env_build.xml', '../env_mach_pes.xml', './env_postprocess.xml', './env_diags_lnd.xml']
##    envDict['STANDALONE'] = False
##    if standalone:
    env_file_list =  ['./env_postprocess.xml', './env_diags_lnd.xml']
##        envDict['STANDALONE'] = True
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
    debugMsg('calling checkAvgFiles', header=True, verbosity=1)
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

    return envDict

#======
# main
#======

def main(options, main_comm, debugMsg, timer):
    """setup the environment for running the diagnostics in parallel. 

    Calls 2 different regridding types
    model1 only 
    model1 and model2

    Arguments:
    options (object) - command line options
    main_comm (object) - MPI simple communicator object
    debugMsg (object) - vprinter object for printing debugging messages
    timer (object) - timer object for keeping times

    The env_diags_lnd.xml configuration file defines whether or not to regrid the climatology files. 
    See (website URL here...) for a complete desciption of the env_diags_lnd XML options.
    """

    # initialize the environment dictionary
    envDict = dict()
    regrid_list = list()
    climo_list = list()

    # set some variables for all tasks
    regrid_script = 'se2fv_esmf.regrid2file.ncl'
    m_dir = 'lnd'

    # CASEROOT is given on the command line as required option --caseroot
    caseroot = options.caseroot[0]
    debugMsg('caseroot = {0}'.format(caseroot), header=True, verbosity=1)

    debugMsg('calling initialize_main', header=True, verbosity=1)
    envDict = initialize_main(envDict, caseroot, debugMsg, options.standalone)

    if main_comm.is_manager():

        debugMsg('calling check_ncl_nco', header=True, verbosity=1)
        diagUtilsLib.check_ncl_nco(envDict)

        if not os.path.exists(envDict['WKDIR']):
            os.makedirs(envDict['WKDIR'])

        # build up the climo files to be regridded in parallel
        if (envDict['regrid_1'] == 'True'):
            # setup the working directory first before calling the base class prerequisites
            endYr = (int(envDict['clim_first_yr_1']) + int(envDict['clim_num_yrs_1'])) - 1
            subdir = '{0}.{1}-{2}'.format(envDict['caseid_1'], envDict['clim_first_yr_1'], endYr)
            workdir = '{0}/climo/{1}/{2}/{3}/'.format(envDict['PTMPDIR_1'], envDict['caseid_1'], subdir, m_dir)
            regrid_list = get_climo_files_to_regrid(workdir, envDict['lnd_modelstream_1'], '1', envDict, debugMsg)
            debugMsg('t = 1 regrid_list = {0}'.format(regrid_list), header=True, verbosity=1)

        if (envDict['MODEL_VS_MODEL'] == 'True' and envDict['regrid_2'] == 'True'):

            # setup the working directory first before calling the base class prerequisites
            endYr = (int(envDict['clim_first_yr_2']) + int(envDict['clim_num_yrs_2'])) - 1
            subdir = '{0}.{1}-{2}'.format(envDict['caseid_2'], envDict['clim_first_yr_2'], endYr)
            workdir = '{0}/climo/{1}/{2}/{3}/'.format(envDict['PTMPDIR_2'], envDict['caseid_2'], subdir, m_dir)
            regrid_list = regrid_list + get_climo_files_to_regrid(workdir, envDict['lnd_modelstream_2'], '2', envDict, debugMsg)
            debugMsg('t = 2 regrid_list = {0}'.format(regrid_list), header=True, verbosity=1)

    main_comm.sync()

    # broadcast envDict to all tasks
    envDict['NCLPATH'] = envDict['POSTPROCESS_PATH']+'/lnd_diag/shared/'   
    envDict = main_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)

    # broadcast the regrid_list to all tasks
    regrid_list = main_comm.partition(data=regrid_list, func=partition.Duplicate(), involved=True)
    main_comm.sync()

    # initialize some variables for distributing regridding across the communicators
    size = main_comm.get_size()
    rank = main_comm.get_rank()
    main_comm.sync()

    # ration files to be regridded
    if main_comm.is_manager():
        num_regrids = len(regrid_list)
        debugMsg('{0} num_regrids'.format(num_regrids), header=True, verbosity=1)

        for i in range(num_regrids):
            debugMsg('Sent out index {2!r}'.format(rank, size, i), header=True, verbosity=1)
            main_comm.ration(i)

        for i in range(size - 1):
            debugMsg('Sent None'.format(rank, size), header=True, verbosity=1)
            main_comm.ration(None)

    else:
        i = -1
        while i is not None:
            debugMsg('Recvd index {2!r}'.format(rank, size, i), header=True, verbosity=1)
            i = main_comm.ration()

            if i is not None:
                # extract the i'th list of the regrid_list
                climo_list = regrid_list[i]
                t = climo_list[0]
                ext_dir = climo_list[1]
                climo_file = climo_list[2]
        
                # setup the working directory first for each climo file
                endYr = (int(envDict['clim_first_yr_'+t]) + int(envDict['clim_num_yrs_'+t])) - 1
                subdir = '{0}.{1}-{2}'.format(envDict['caseid_'+t], envDict['clim_first_yr_'+t], endYr)
                workdir = '{0}/climo/{1}/{2}/{3}/'.format(envDict['PTMPDIR_'+t], envDict['caseid_'+t], subdir, m_dir)

                timer_tag = '{0}_{1}'.format(t, climo_file)
                timer.start(timer_tag)
                debugMsg('Before call to lnd_regrid using workdir = {0}/{1}'.format(workdir, ext_dir), header=True, verbosity=1)
                diagUtilsLib.lnd_regrid(climo_file, regrid_script, t, workdir, ext_dir, envDict)
                timer.stop(timer_tag)

                debugMsg("Total time to regrid file {0} = {1}".format(climo_file, timer.get_time(timer_tag)), header=True, verbosity=1)

#===================================


if __name__ == "__main__":
    # initialize simplecomm object
    main_comm = simplecomm.create_comm(serial=False)

    # setup an overall timer
    timer = timekeeper.TimeKeeper()

    # get commandline options
    options = commandline_options()

    # initialize global vprinter object for printing debug messages
    if options.debug:
        header = "[" + str(main_comm.get_rank()) + "/" + str(main_comm.get_size()) + "]: DEBUG... "
        debugMsg = vprinter.VPrinter(header=header, verbosity=options.debug[0])
   
    try:
        timer.start("Total Time")
        status = main(options, main_comm, debugMsg, timer)
        main_comm.sync()
        timer.stop("Total Time")
        if main_comm.is_manager():
            print('***************************************************')
            print('Total Time: {0} seconds'.format(timer.get_time("Total Time")))
            print('Successfully completed regridding of land climatology files')
            print('***************************************************')
        sys.exit(status)

    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)

