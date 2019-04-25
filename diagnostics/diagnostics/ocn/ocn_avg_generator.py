#!/usr/bin/env python2
"""Generate ocean climatology average files for a given CESM case 

This script provides an interface between:
1. the CESM case environment,
2. the ocean diagnostics environment defined in XML files,
3. the Python package for averaging operations in parallel

It is called from the run script and resides in the $CCSMROOT/postprocessing/cesm-env2
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
import getopt
import os
import re
import traceback

# import local modules for postprocessing
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# import the pyaverager
from pyaverager import specification, PyAverager

#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():
    """Process the command line arguments.
    """
    parser = argparse.ArgumentParser(
        description='ocn_avg_generator: CESM wrapper python program for ocean climatology packages.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging '
                        'output')

    parser.add_argument('--debug', nargs=1, required=False, type=int, default=0,
                        help='debugging verbosity level output: 0 = none, 1 = minimum, 2 = maximum. 0 is default')

    parser.add_argument('--caseroot', nargs=1, required=True, 
                        help='fully quailfied path to case root directory')

    parser.add_argument('--control-run', action='store_true', default=False,
                        help='Controls whether or not to process climatology files for a control run using the settings in the caseroot env_diags_[component].xml files.')

    parser.add_argument('--standalone', action='store_true',
                        help='switch to indicate stand-alone post processing caseroot')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = ' ERROR: ocn_avg_generator.py invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options


#====================================================================
# buildOcnTseriesAvgList - build the list of averages to be computed
#====================================================================
def buildOcnTseriesAvgList(start_year, stop_year, avgFileBaseName, moc, main_comm, debugMsg):
    """buildOcnTseriesAvgList - build the list of averages to be computed
    by the pyAverager for timeseries. Checks if the file exists or not already.

    Arguments:
    start_year (string) - tseries starting year
    stop_year (string) - tseries ending year
    avgFileBaseName (string) - avgFileBaseName (tavgdir/case.[stream].)

    Return:
    avgList (list) - list of averages to be passed to the pyaverager
    """
    avgList = []
    avgListMoc = []
    
    # append the horizontal mean concatenation
    avgList.append('hor.meanConcat:{0}:{1}'.format(start_year, stop_year))

    # the following averages are necessary for model timeseries diagnostics
    # append the MOC and monthly MOC files
    if (moc):
        avgFile = '{0}.{1}-{2}.moc.nc'.format(avgFileBaseName, start_year, stop_year)
        if main_comm.is_manager():
            debugMsg('mocFile = {0}'.format(avgFile), header=True, verbosity=2)
        rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
        if not rc:
            avgListMoc.append('moc:{0}:{1}'.format(start_year, stop_year))
        
        avgFile = '{0}.{1}-{2}.mocm.nc'.format(avgFileBaseName, start_year, stop_year)
        if main_comm.is_manager():
            debugMsg('mocmFile = {0}'.format(avgFile), header=True, verbosity=2)
        rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
        if not rc:
            avgListMoc.append('mocm:{0}:{1}'.format(start_year, stop_year))

    if main_comm.is_manager():
        debugMsg('exit buildOcnAvgTseriesList avgList = {0}'.format(avgList), header=True, verbosity=2)

    return avgList, avgListMoc

#============================================================
# buildOcnAvgList - build the list of averages to be computed
#============================================================
def buildOcnAvgList(start_year, stop_year, tavgdir, main_comm, debugMsg):
    """buildOcnAvgList - build the list of averages to be computed
    by the pyAverager. Checks if the file exists or not already.

    Arguments:
    start_year (string) - starting year
    stop_year (string) - ending year
    tavgdir (string) - averages directory

    Return:
    avgList (list) - list of averages to be passed to the pyaverager
    """
    avgList = []

    # check if mavg file already exists
    avgFile = '{0}/mavg.{1}-{2}.nc'.format(tavgdir, start_year, stop_year)
    if main_comm.is_manager():
        debugMsg('mavgFile = {0}'.format(avgFile), header=True, verbosity=2)
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if not rc:
        avgList.append('mavg:{0}:{1}'.format(start_year, stop_year))

    # check if tavg file already exists
    avgFile = '{0}/tavg.{1}-{2}.nc'.format(tavgdir, start_year, stop_year)
    if main_comm.is_manager():
        debugMsg('tavgFile = {0}'.format(avgFile), header=True, verbosity=2)
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if not rc:
        avgList.append('tavg:{0}:{1}'.format(start_year, stop_year))

    if main_comm.is_manager():
        debugMsg('exit buildOcnAvgList avgList = {0}'.format(avgList), header=True, verbosity=2)
    return avgList

#========================================================================
# callPyAverager - create the climatology files by calling the pyAverager
#========================================================================
def callPyAverager(in_dir, htype, tavgdir, case_prefix, averageList, varList,
                   diag_obs_root, netcdf_format, nlev, timeseries_obspath, 
                   main_comm, debugMsg):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       in_dir (string) - input directory with either history time slice or variable time series files
       htype (string) - 'series' or 'slice' depending on input history file type
       tavgdir (string) - output directory for climatology files
       case_prefix (string) - input filename prefix
       averageList (list) - list of averages to be created
       varList (list) - list of variables. Note: an empty list implies all variables.
       tseries (boolean) - TRUE if TIMESERIES plots are specified.
       diag_obs_root (string) - OCNDIAG_DIAGOBSROOT machine dependent path to input data root
       netcdf_format (string) - OCNDIAG_netcdf_format one of ['netcdf', 'netcdf4', 'netcdf4c', 'netcdfLarge']
       nlev (integer) - Number of ocean vertical levels
       timeseries_obspath (string) - timeseries observation files path
       main_comm (object) - simple MPI communicator object

    """
    # the following are used for timeseries averages and ignored otherwise
##    mean_diff_rms_obs_dir = '{0}/omwg/timeseries_obs'.format(diag_obs_root)
    mean_diff_rms_obs_dir = timeseries_obspath
    region_nc_var = 'REGION_MASK'
    regions={1:'Sou',2:'Pac',3:'Ind',6:'Atl',8:'Lab',9:'Gin',10:'Arc',11:'Hud',0:'Glo'}
    region_wgt_var = 'TAREA'
##    obs_dir = '{0}/omwg/timeseries_obs'.format(diag_obs_root)
    obs_dir = timeseries_obspath
    obs_file = 'obs.nc'
    reg_obs_file_suffix = '_hor_mean_obs.nc'

    wght = False
    valid_netcdf_formats = ['netcdf', 'netcdf4', 'netcdf4c', 'netcdfLarge']
    ncfrmt = 'netcdf'
    if netcdf_format in valid_netcdf_formats:
        ncfrmt = netcdf_format
    serial = False
    clobber = True
    date_pattern = 'yyyymm-yyyymm'
    suffix = 'nc'

    main_comm.sync();

    if main_comm.is_manager():
        debugMsg('calling specification.create_specifier with following args', header=True)
        debugMsg('... in_directory = {0}'.format(in_dir), header=True)
        debugMsg('... out_directory = {0}'.format(tavgdir), header=True)
        debugMsg('... prefix = {0}'.format(case_prefix), header=True)
        debugMsg('... suffix = {0}'.format(suffix), header=True)
        debugMsg('... date_pattern = {0}'.format(date_pattern), header=True)
        debugMsg('... hist_type = {0}'.format(htype), header=True)
        debugMsg('... avg_list = {0}'.format(averageList), header=True)
        debugMsg('... weighted = {0}'.format(wght), header=True)
        debugMsg('... ncformat = {0}'.format(ncfrmt), header=True)
        debugMsg('... varlist = {0}'.format(varList), header=True)
        debugMsg('... serial = {0}'.format(serial), header=True)
        debugMsg('... clobber = {0}'.format(clobber), header=True)
        debugMsg('... mean_diff_rms_obs_dir = {0}'.format(mean_diff_rms_obs_dir), header=True)
        debugMsg('... region_nc_var = {0}'.format(region_nc_var), header=True)
        debugMsg('... regions = {0}'.format(regions), header=True)
        debugMsg('... region_wgt_var = {0}'.format(region_wgt_var), header=True)
        debugMsg('... obs_dir = {0}'.format(obs_dir), header=True)
        debugMsg('... obs_file = {0}'.format(obs_file), header=True)
        debugMsg('... reg_obs_file_suffix = {0}'.format(reg_obs_file_suffix), header=True)
        debugMsg('... nlev = {0}'.format(nlev), header=True)

    main_comm.sync();

    try: 
        pyAveSpecifier = specification.create_specifier(
            in_directory = in_dir,
            out_directory = tavgdir,
            prefix = case_prefix,
            suffix=suffix,
            date_pattern=date_pattern,
            hist_type = htype,
            avg_list = averageList,
            weighted = wght,
            ncformat = ncfrmt,
            varlist = varList,
            serial = serial,
            clobber = clobber,
            mean_diff_rms_obs_dir = mean_diff_rms_obs_dir,
            region_nc_var = region_nc_var,
            regions = regions,
            region_wgt_var = region_wgt_var,
            obs_dir = obs_dir,
            obs_file = obs_file,
            reg_obs_file_suffix = reg_obs_file_suffix,
            vertical_levels = nlev,
            main_comm = main_comm)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

    try:
        if main_comm.is_manager():
            debugMsg("calling run_pyAverager")

        PyAverager.run_pyAverager(pyAveSpecifier)

        main_comm.sync();

    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

#=========================================================================
# createClimFiles - create the climatology files by calling the pyAverager
#=========================================================================
def createClimFiles(start_year, stop_year, in_dir, htype, tavgdir, case, tseries, inVarList,
                    tseries_start_year, tseries_stop_year, diag_obs_root, netcdf_format, 
                    nlev, timeseries_obspath, main_comm, debugMsg):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       start_year (integer) - starting year for diagnostics
       stop_year (integer) - ending year for diagnositcs
       in_dir (string) - input directory with either history time slice or variable time series files
       htype (string) - 'series' or 'slice' depending on input history file type
       tavgdir (string) - output directory for averages
       case (string) - case name
       tseries (boolean) - TRUE if TIMESERIES plots are specified
       inVarList (list) - if empty, then create climatology files for all vars, RHO, SALT and TEMP
       tseries_start_year (integer) - starting year for timeseries diagnostics 
       tseries_stop_year (integer) - stop year for timeseries diagnostics
       diag_obs_root (string) - OCNDIAG_DIAGOBSROOT machine dependent path to input data root
       netcdf_format (string) - OCNDIAG_netcdf_format one of ['netcdf', 'netcdf4', 'netcdf4c', 'netcdfLarge']
       nlev (integer) - Number of ocean vertical levels
       timeseries_obspath (string) - timeseries observation files path
       main_comm (object) - simple MPI communicator object

    """
    # create the list of averages to be computed
    avgFileBaseName = '{0}/{1}.pop.h'.format(tavgdir,case)
    case_prefix = '{0}.pop.h'.format(case)
    averageList = []
    avgList = []

    # create the list of averages to be computed by the pyAverager
    averageList = buildOcnAvgList(start_year, stop_year, tavgdir, main_comm, debugMsg)

    # if the averageList is empty, then all the climatology files exist with all variables
    if len(averageList) > 0:

        # call the pyAverager with the inVarList for tavg only - all variables
        avgList.append('tavg:{0}:{1}'.format(start_year, stop_year))        
        if main_comm.is_manager():
            debugMsg('Calling callPyAverager with averageList = {0}'.format(avgList), header=True, verbosity=1)
            debugMsg(' and inVarList = {0}'.format(inVarList), header=True, verbosity=1)
        callPyAverager(in_dir=in_dir, htype=htype, tavgdir=tavgdir, 
                       case_prefix=case_prefix, averageList=avgList, 
                       varList=inVarList, diag_obs_root=diag_obs_root, 
                       netcdf_format=netcdf_format, nlev=nlev, 
                       timeseries_obspath=timeseries_obspath, 
                       main_comm=main_comm, debugMsg=debugMsg)
        main_comm.sync()

        # call the pyAverager with the just SALT and TEMP for mavg only
        avgList = []
        avgList.append('mavg:{0}:{1}'.format(start_year, stop_year))
        tmpInVarList = ['SALT', 'TEMP']
        if main_comm.is_manager():
            debugMsg('Calling callPyAverager with averageList = {0}'.format(avgList), header=True, verbosity=1)
            debugMsg(' and inVarList = {0}'.format(tmpInVarList), header=True, verbosity=1)
        callPyAverager(in_dir=in_dir, htype=htype, tavgdir=tavgdir, 
                       case_prefix=case_prefix, averageList=avgList, 
                       varList=tmpInVarList, diag_obs_root=diag_obs_root, 
                       netcdf_format=netcdf_format, nlev=nlev, 
                       timeseries_obspath=timeseries_obspath, 
                       main_comm=main_comm, debugMsg=debugMsg)
    main_comm.sync()

    # check if timeseries diagnostics is requested
    if tseries:
        # create the list of averages to be computed by the pyAverager
        if 'MOC' in inVarList:
            averageList, averageListMoc = buildOcnTseriesAvgList(start_year=tseries_start_year, 
                                                                 stop_year=tseries_stop_year, 
                                                                 avgFileBaseName=avgFileBaseName, 
                                                                 moc=True, 
                                                                 main_comm=main_comm, debugMsg=debugMsg)
        else:
            averageList, averageListMoc = buildOcnTseriesAvgList(start_year=tseries_start_year, 
                                                                 stop_year=tseries_stop_year, 
                                                                 avgFileBaseName=avgFileBaseName, 
                                                                 moc=False, 
                                                                 main_comm=main_comm, debugMsg=debugMsg)
        main_comm.sync()

        # generate the annual timeseries files and MOC file with TEMP, SALT, MOC variables
        if len(averageListMoc) > 0:
            # call the pyAverager with the inVarList
            if 'MOC' in inVarList:
                tmpInVarList = ['MOC','SALT', 'TEMP']
            else:
                tmpInVarList = ['SALT', 'TEMP']
            if main_comm.is_manager():
                debugMsg('Calling callPyAverager with averageListMoc = {0}'.format(averageListMoc), header=True, verbosity=1)
                debugMsg(' and inVarList = {0}'.format(tmpInVarList), header=True, verbosity=1)

            callPyAverager(in_dir=in_dir, htype=htype, tavgdir=tavgdir, 
                           case_prefix=case_prefix, averageList=averageListMoc, 
                           varList=tmpInVarList, diag_obs_root=diag_obs_root, 
                           netcdf_format=netcdf_format, nlev=nlev, 
                           timeseries_obspath=timeseries_obspath, 
                           main_comm=main_comm, debugMsg=debugMsg)
        main_comm.sync()

        # generate the horizontal mean files with just SALT and TEMP
        if len(averageList) > 0:
            # call the pyAverager with the inVarList
            tmpInVarList = ['SALT', 'TEMP']
            if main_comm.is_manager():
                debugMsg('Calling callPyAverager with averageList = {0}'.format(averageList), header=True, verbosity=1)
                debugMsg(' and inVarList = {0}'.format(tmpInVarList), header=True, verbosity=1)
            callPyAverager(in_dir=in_dir, htype=htype, tavgdir=tavgdir, 
                           case_prefix=case_prefix, averageList=averageList,
                           varList=tmpInVarList, diag_obs_root=diag_obs_root, 
                           netcdf_format=netcdf_format, nlev=nlev, 
                           timeseries_obspath=timeseries_obspath, 
                           main_comm=main_comm, debugMsg=debugMsg)
        main_comm.sync()

#============================================
# initialize_envDict - initialization envDict
#============================================
def initialize_envDict(envDict, caseroot, debugMsg, standalone):
    """initialize_main - initialize settings on rank 0 
    
    Arguments:
    envDict (dictionary) - environment dictionary
    caseroot (string) - case root
    debugMsg (object) - vprinter object for printing debugging messages
    standalone (boolean) - indicate stand-alone post processing caseroot

    Return:
    envDict (dictionary) - environment dictionary
    """
    # setup envDict['id'] = 'value' parsed from the CASEROOT/[env_file_list] files
    env_file_list =  ['./env_postprocess.xml', './env_diags_ocn.xml']
    envDict = cesmEnvLib.readXML(caseroot, env_file_list)

    # debug print out the envDict
    debugMsg('envDict after readXML = {0}'.format(envDict), header=True, verbosity=2)

    # refer to the caseroot that was specified on the command line instead of what
    # is read in the environment as the caseroot may have changed from what is listed
    # in the env xml
    envDict['CASEROOT'] = caseroot

    # add the os.environ['PATH'] to the envDict['PATH']
    envDict['OCNDIAG_PATH'] += os.pathsep + os.environ['PATH']

    # initialize varLists
    envDict['MODEL_VARLIST'] = []
    if len(envDict['OCNDIAG_PYAVG_MODELCASE_VARLIST']) > 0:
        envDict['MODEL_VARLIST'] = envDict['OCNDIAG_PYAVG_MODELCASE_VARLIST'].split(',')

    envDict['CNTRL_VARLIST'] = []
    if len(envDict['OCNDIAG_PYAVG_CNTRLCASE_VARLIST']) > 0:
        envDict['CNTRL_VARLIST'] = envDict['OCNDIAG_PYAVG_CNTRLCASE_VARLIST'].split(',')
    
    # strip the OCNDIAG_ prefix from the envDict entries before setting the 
    # enviroment to allow for compatibility with all the diag routine calls
    envDict = diagUtilsLib.strip_prefix(envDict, 'OCNDIAG_')

    return envDict

#======
# main
#======

def main(options, main_comm, debugMsg):
    """setup the environment for running the pyAverager in parallel. 

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
        debugMsg('calling initialize_envDict', header=True)
        envDict = initialize_envDict(envDict, caseroot, debugMsg, options.standalone)

    # broadcast envDict to all tasks
    envDict = main_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)
    sys.path.append(envDict['PATH'])
    main_comm.sync()

    # generate the climatology files used for all plotting types using the pyAverager
    if main_comm.is_manager():
        debugMsg('calling checkHistoryFiles for model case', header=True)
        suffix = 'pop.h.*.nc'
        file_pattern = '.*\.pop\.h\.\d{4,4}-\d{2,2}\.nc'
        start_year, stop_year, in_dir, htype, firstHistoryFile = diagUtilsLib.checkHistoryFiles(
            envDict['MODELCASE_INPUT_TSERIES'], envDict['DOUT_S_ROOT'], envDict['CASE'],
            envDict['YEAR0'], envDict['YEAR1'], 'ocn', suffix, file_pattern, envDict['MODELCASE_SUBDIR'])
        envDict['YEAR0'] = start_year
        envDict['YEAR1'] = stop_year
        envDict['in_dir'] = in_dir
        envDict['htype'] = htype

    main_comm.sync()

    envDict = main_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)
    main_comm.sync()


    # MODEL_TIMESERIES denotes the plotting diagnostic type requested and whether or
    # not to generate the necessary climo files for those plot sets
    tseries = False
    if envDict['MODEL_TIMESERIES'].lower() in ['t','true']:
        if main_comm.is_manager():
            debugMsg('timeseries years before checkHistoryFiles {0} - {1}'.format(envDict['TSERIES_YEAR0'], envDict['TSERIES_YEAR1']), header=True)
            tseries_start_year, tseries_stop_year, in_dir, htype, firstHistoryFile = \
                diagUtilsLib.checkHistoryFiles(envDict['MODELCASE_INPUT_TSERIES'], envDict['DOUT_S_ROOT'], 
                                               envDict['CASE'], envDict['TSERIES_YEAR0'], 
                                               envDict['TSERIES_YEAR1'], 'ocn', suffix, file_pattern,
                                               envDict['MODELCASE_SUBDIR'])
            debugMsg('timeseries years after checkHistoryFiles {0} - {1}'.format(envDict['TSERIES_YEAR0'], envDict['TSERIES_YEAR1']), header=True)
            envDict['TSERIES_YEAR0'] = tseries_start_year
            envDict['TSERIES_YEAR1'] = tseries_stop_year

        main_comm.sync()
        tseries = True
        envDict = main_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)
        main_comm.sync()

    try:
        if main_comm.is_manager():
            debugMsg('calling createClimFiles for model and timeseries', header=True)

        createClimFiles(envDict['YEAR0'], envDict['YEAR1'], envDict['in_dir'],
                        envDict['htype'], envDict['TAVGDIR'], envDict['CASE'], 
                        tseries, envDict['MODEL_VARLIST'], envDict['TSERIES_YEAR0'], 
                        envDict['TSERIES_YEAR1'], envDict['DIAGOBSROOT'], 
                        envDict['netcdf_format'], int(envDict['VERTICAL']), 
                        envDict['TIMESERIES_OBSPATH'], main_comm, debugMsg)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

    main_comm.sync()

    # check that the necessary control climotology files exist
    if envDict['MODEL_VS_CONTROL'].upper() == 'TRUE':

        if main_comm.is_manager():
            debugMsg('calling checkHistoryFiles for control case', header=True)
            suffix = 'pop.h.*.nc'
            file_pattern = '.*\.pop\.h\.\d{4,4}-\d{2,2}\.nc'
            start_year, stop_year, in_dir, htype, firstHistoryFile = diagUtilsLib.checkHistoryFiles(
                envDict['CNTRLCASE_INPUT_TSERIES'], envDict['CNTRLCASEDIR'], envDict['CNTRLCASE'], 
                envDict['CNTRLYEAR0'], envDict['CNTRLYEAR1'], 'ocn', suffix, file_pattern,
                envDict['CNTRLCASE_SUBDIR'])
            envDict['CNTRLYEAR0'] = start_year
            envDict['CNTRLYEAR1'] = stop_year
            envDict['cntrl_in_dir'] = in_dir
            envDict['cntrl_htype'] = htype

        main_comm.sync()
        envDict = main_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)
        main_comm.sync()

        if main_comm.is_manager():
            debugMsg('before createClimFiles call for control', header=True)
            debugMsg('...CNTRLYEAR0 = {0}'.format(envDict['CNTRLYEAR0']), header=True)
            debugMsg('...CNTRLYEAR1 = {0}'.format(envDict['CNTRLYEAR1']), header=True)
            debugMsg('...cntrl_in_dir = {0}'.format(envDict['cntrl_in_dir']), header=True)
            debugMsg('...cntrl_htype = {0}'.format(envDict['cntrl_htype']), header=True)
            debugMsg('...CNTRLTAVGDIR = {0}'.format(envDict['CNTRLTAVGDIR']), header=True)
            debugMsg('...CNTRLCASE = {0}'.format(envDict['CNTRLCASE']), header=True)
            debugMsg('...CNTRLCASE_INPUT_TSERIES = {0}'.format(envDict['CNTRLCASE_INPUT_TSERIES']), header=True)
            debugMsg('...varlist = {0}'.format(envDict['CNTRL_VARLIST']), header=True)
            debugMsg('calling createClimFiles for control', header=True)
        
        # don't create timeseries averages for the control case so set to False and set the
        # tseries_start_year and tseries_stop_year to 0
        try:
            createClimFiles(envDict['CNTRLYEAR0'], envDict['CNTRLYEAR1'], envDict['cntrl_in_dir'],
                            envDict['cntrl_htype'], envDict['CNTRLTAVGDIR'], envDict['CNTRLCASE'], 
                            False, envDict['CNTRL_VARLIST'], 0, 0, envDict['DIAGOBSROOT'],
                            envDict['netcdf_format'], int(envDict['VERTICAL']), 
                            envDict['TIMESERIES_OBSPATH'], main_comm, debugMsg)
        except Exception as error:
            print(str(error))
            traceback.print_exc()
            sys.exit(1)

#===================================

if __name__ == "__main__":
    # initialize simplecomm object
    main_comm = simplecomm.create_comm(serial=False)

    # get commandline options
    options = commandline_options()

    # initialize global vprinter object for printing debug messages
    debugMsg = vprinter.VPrinter(header='', verbosity=0)
    if options.debug:
        header = 'ocn_avg_generator: DEBUG... '
        debugMsg = vprinter.VPrinter(header=header, verbosity=options.debug[0])
    
    try:
        status = main(options, main_comm, debugMsg)
        if main_comm.is_manager():
            print('*************************************************************')
            print(' Successfully completed generating ocean climatology averages')
            print('*************************************************************')
        sys.exit(status)
        
    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)

