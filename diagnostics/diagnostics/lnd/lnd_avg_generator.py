#!/usr/bin/env python2
"""Generate lnd climatology average files for a given CESM case 

This script provides an interface between:
1. the CESM case environment,
2. the lnd diagnostics environment defined in XML files,
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

# import the pyaverager and preproc
from pyaverager import specification, PyAverager, PreProc

#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():
    """Process the command line arguments.
    """
    parser = argparse.ArgumentParser(
        description='lnd_avg_generator: CESM wrapper python program for lnd climatology packages.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging '
                        'output')

    parser.add_argument('--debug', nargs=1, required=False, type=int, default=0,
                        help='debugging verbosity level output: 0 = none, 1 = minimum, 2 = maximum. 0 is default')

    parser.add_argument('--caseroot', nargs=1, required=True, 
                        help='fully quailfied path to case root directory')

    parser.add_argument('--control-run', action='store_true', default=False,
                        help='Controls whether or not to process climatology files for a control run using the settings in the caseroot env_diags_[component].xml files.')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = ' ERROR: lnd_avg_generator.py invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options


#============================================================
# buildLndAvgList - build the list of averages to be computed
#============================================================
def buildLndAvgList(climo, avg_start_year, avg_stop_year, trends, trends_start_year, trends_stop_year, avgFileBaseName, out_dir, envDict, debugMsg):
    """buildLndAvgList - build the list of averages to be computed
    by the pyAverager. Checks if the file exists or not already.

    Arguments:
    avg_start_year (string) - starting year
    avg_stop_year (string) - ending year
    avgFileBaseName (string) - avgFileBaseName (out_dir/case.[stream].)

    Return:
    avgList (list) - list of averages to be passed to the pyaverager
    """

    avgList = []

    if (climo == 'True'):
        # Seasonal Files
        if envDict['significance'] == 'True':
            for seas in envDict['seas']:
                avgFile = '{0}.{1}-{2}.{3}_climo.nc'.format(avgFileBaseName, start_year, stop_year,seas)
                rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
                if not rc:
                    avgList.append('{0}_sig:{1}:{2}'.format(seas.lower(), start_year, stop_year))

                meanAvgFile = '{0}.{1}-{2}.{3}_mean.nc'.format(avgFileBaseName, start_year, stop_year,seas)
                rc, err_msg = cesmEnvLib.checkFile(meanAvgFile, 'read')
                if not rc:
                    avgList.append('{0}_mean:{1}:{2}'.format(seas.lower(), start_year, stop_year))
        else:
            for seas in envDict['seas']:
                avgFile = '{0}.{1}-{2}.{3}_climo.nc'.format(avgFileBaseName, start_year, stop_year,seas)
                rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
                if not rc:
                    avgList.append('dep_{0}:{1}:{2}'.format(seas.lower(), start_year, stop_year))

        # Monthly Files
        m_names = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
        for m in range(1,13):
            month = str(m).zfill(2)
            avgFile = '{0}.{1}-{2}.{3}_climo.nc'.format(avgFileBaseName, start_year, stop_year,month)
            rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
            if not rc:
                avgList.append('{0}:{1}:{2}'.format(m_names[m-1], start_year, stop_year))    

    if (trends == 'True'):
        avgFile = '{0}.{1}-{2}.ANN_ALL.nc'.format(avgFileBaseName, start_year, stop_year)
        rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
        if not rc:
            avgList.append('annall:{1}:{2}'.format(start_year, stop_year))
        
    debugMsg('exit buildLndAvgList avgList = {0}'.format(avgList))
    return avgList

#=========================================================================
# Get a shortened variable list
#=========================================================================
def get_variable_list(envDict,in_dir,case_prefix, key_infile, htype, stream):
    """get_variable_list - build a list of variables to compute climatologies for.
    This is only done if the users set the 'strip_off_vars' option to True.

    Arguments:
    envDict (dictionary) - list of all env variables
    in_dir (string) - input directory
    case_prefix (string) - the name of the case

    Return:
    var_list (list) - a list of the variables to compute climatologies for
    """   
    # All variables are averaged into the climo files
    var_list = []
    return var_list


#========================================================================
# callPyAverager - create the climatology files by calling the pyAverager
#========================================================================
def callPyAverager(avg_start_year, avg_stop_year, in_dir, htype, key_infile, out_dir, case_prefix, averageList, varList, 
                   envDict, stream, grid_file, trend_year0, trend_year1, debugMsg):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       avg_start_year (integer) - starting year for diagnostics
       avg_stop_year (integer) - ending year for diagnositcs
       in_dir (string) - input directory with either history time sllnd or variable time series files
       htype (string) - 'series' or 'sllnd' depending on input history file type
       out_dir (string) - output directory for climatology files
       case_prefix (string) - input filename prefix
       averageList (list) - list of averages to be created
       varList (list) - list of variables. Note: an empty list implies all variables.
    """
    wght = envDict['weight_months']
    if wght == 'True':
       wght = True
    else:
       wght = False
    ncfrmt = 'netcdf'
    serial = False
    clobber = True
    if htype == 'series':
        date_pattern = 'yyyymm-yyyymm'
    else:
        date_pattern = 'yyyy-mm'
    suffix = 'nc'

    debugMsg('calling specification.create_specifier with following args', header=True)
    debugMsg('... in_directory = {0}'.format(in_dir), header=True)
    debugMsg('... out_directory = {0}'.format(out_dir), header=True)
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
    debugMsg('... lnd_obs_file = {0}'.format(lnd_obs_file), header=True)
    debugMsg('... ncl_location = {0}'.format(ncl_location), header=True)

    try: 
        pyAveSpecifier = specification.create_specifier(
            in_directory = in_dir,
            out_directory = out_dir,
            prefix = case_prefix,
            suffix=suffix,
            date_pattern=date_pattern,
            hist_type = htype,
            avg_list = averageList,
            weighted = wght,
            ncformat = ncfrmt,
            varlist = varList,
            serial = serial,
            clobber = clobber)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

    try:
        debugMsg("calling run_pyAverager")
        PyAverager.run_pyAverager(pyAveSpecifier)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

#=========================================================================
# createClimFiles - create the climatology files by calling the pyAverager
#=========================================================================
def createClimFiles(avg_start_year, avg_stop_year, in_dir, htype, key_infile, out_dir, case, stream, inVarList, envDict, 
                    trend_year0, trend_year1, climo, trends, debugMsg):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       avg_start_year (integer) - starting year for diagnostics
       avg_stop_year (integer) - ending year for diagnositcs
       in_dir (string) - input directory with either history time sllnd or variable time series files
       htype (string) - 'series' or 'sllnd' depending on input history file type
       out_dir (string) - output directory for averages
       case (string) - case name
       inVarList (list) - if empty, then create climatology files for all vars
    """
    # create the list of averages to be computed
    out_dir = out_dir+'/'+case+'.'+str(avg_start_year)+'-'+str(avg_stop_year)
    avgFileBaseName = '{0}/{1}.{2}'.format(out_dir,case,stream)
    case_prefix = '{0}.{1}'.format(case,stream)
    averageList = []

    # create the list of averages to be computed by the pyAverager
    averageList = buildLndAvgList(climo, avg_start_year, avg_stop_year, trends, trend_year0, trend_year1, 
                                  avgFileBaseName, out_dir, envDict, debugMsg)

    # if the averageList is empty, then all the climatology files exist with all variables
    if len(averageList) > 0:
        # call the pyAverager with the inVarList
        callPyAverager(avg_start_year, avg_stop_year, in_dir, htype, key_infile, out_dir, case_prefix, averageList, inVarList, 
                       envDict, stream, trend_year0, trend_year1, debugMsg)


#============================================
# initialize_envDict - initialization envDict
#============================================
def initialize_envDict(envDict, caseroot, debugMsg):
    """initialize_main - initialize settings on rank 0 
    
    Arguments:
    envDict (dictionary) - environment dictionary
    caseroot (string) - case root
    debugMsg (object) - vprinter object for printing debugging messages

    Return:
    envDict (dictionary) - environment dictionary
    """
    # setup envDict['id'] = 'value' parsed from the CASEROOT/[env_file_list] files
    # TODO put this file list into the config_postprocess definition
    env_file_list = ['env_case.xml', 'env_run.xml', 'env_build.xml', 'env_mach_pes.xml', 'env_postprocess.xml', 'env_diags_lnd.xml']
    envDict = cesmEnvLib.readXML(caseroot, env_file_list)

    # debug print out the envDict
    debugMsg('envDict after readXML = {0}'.format(envDict), header=True, verbosity=2)

    # refer to the caseroot that was specified on the command line instead of what
    # is read in the environment as the caseroot may have changed from what is listed
    # in the env xml

    # add the os.environ['PATH'] to the envDict['PATH']
    envDict['LANDDIAG_PATH'] = os.pathsep + os.environ['PATH']

    # strip the ATMDIAG_ prefix from the envDict entries before setting the 
    # enviroment to allow for compatibility with all the diag routine calls
    envDict = diagUtilsLib.strip_prefix(envDict, 'LANDDIAG_')

    envDict['seas'] = ['djf','mam','jja','son','ann']

    return envDict


#======
# main
#======

def main(options, debugMsg):
    """setup the environment for running the pyAverager in parallel. 

    Arguments:
    options (object) - command line options
    debugMsg (object) - vprinter object for printing debugging messages

    The env_diags_lnd.xml configuration file defines the way the diagnostics are generated. 
    See (website URL here...) for a complete desciption of the env_diags_lnd XML options.
    """

    # initialize the environment dictionary
    envDict = dict()

    # CASEROOT is given on the command line as required option --caseroot
    caseroot = options.caseroot[0]
    debugMsg('caseroot = {0}'.format(caseroot), header=True)
    

    debugMsg('calling initialize_envDict', header=True)
    envDict = initialize_envDict(envDict, caseroot, debugMsg)

    # specify variables to include in the averages, empty list implies get them all
    varList = []

    # generate the climatology files used for all plotting types using the pyAverager
    debugMsg('calling createClimFiles', header=True)

    # get model history file information from the DOUT_S_ROOT archive location
    debugMsg('calling checkHistoryFiles for control run', header=True)
    case1_time_series = envDict['CASE1_TIMESERIES']

    for model in ('lnd', 'atm', 'rtm'):
        if envDict['climo_'+model+'_1'] == 'True' or envDict['trends_'+model+'_1'] == 'True':
            m_dir = model
            if rtm in model:
                m_dir = 'rof'

            suffix = envDict[model+'_modelstream_1']
            filep = '.*\.'+suffix+'.\d{4,4}-\d{2,2}\.nc'
            envDict['clim_last_yr_1'] = (int(envDict['clim_first_yr_1']) + int(envDict['clim_num_yrs_1'])) -1  
            envDict['trends_last_yr_1'] = (int(envDict['trends_first_yr_1']) + int(envDict['trends_num_yrs_1'])) -1

            # Check the history files for climos date range
            start_year, stop_year, in_dir, envDict['case1_htype'],  envDict['case1_key_infile'] = diagUtilsLib.checkHistoryFiles(
                case1_time_series, envDict['SOURCE_1'], envDict['caseid_1'], envDict['clim_first_yr_1'], envDict['clim_last_yr_1'],
                m_dir,suffix,filep)
            # Check the history files for trends date range
            start_year, stop_year, in_dir, envDict['case1_htype'],  envDict['case1_key_infile'] = diagUtilsLib.checkHistoryFiles(
                case1_time_series, envDict['SOURCE_1'], envDict['caseid_1'], envDict['trends_first_yr_1'], envDict['trends_last_yr_1'],
                m_dir,suffix,filep)
    

            try:
                if case1_time_series == 'True':
                    h_path = envDict['SOURCE_1']+'/'+m_dir+'/proc/tseries/monthly/'
                else:
                    h_path = envDict['SOURCE_1']+'/'+m_dir+'/hist/'
                case1_climo_dir =  envDict['PTMPDIR']+'/'+ envDict['caseid_1']+'/' 
 
                createClimFiles(envDict['clim_first_yr_1'], envDict['clim_last_yr_1'], h_path, 
                                envDict['case1_htype'], envDict['case1_key_infile'], case1_climo_dir, envDict['caseid_1'], 
                                suffix, varList, envDict, envDict['trends_first_yr_1'], envDict['trends_last_yr_1'], 
                                envDict['climo_'+model+'_1'], envDict['trends_'+model+'_1'], debugMsg)
            except Exception as error:
                print(str(error))
                traceback.print_exc()
                sys.exit(1)

    if (envDict['MODEL_VS_MODEL'] == 'True':
        for model in ('lnd', 'atm', 'rtm'):
            if envDict['climo_'+model+'_2'] == 'True' or envDict['trends_'+model+'_2'] == 'True':
                m_dir = model
                if rtm in model:
                    m_dir = 'rof'
                try:
                    diff_time_series = envDict['DIFF_TIMESERIES']
                    suffix = envDict[[model+'modelstream_2']
                    filep = '.*\.'+suffix+'.\d{4,4}-\d{2,2}\.nc'
                    envDict['clim_last_yr_2'] = (int(envDict['clim_first_yr_2']) + int(envDict['clim_num_yrs_2'])) - 1
                    envDict['trends_last_yr_2'] = (int(envDict['trends_first_yr_2']) + int(envDict['trends_num_yrs_2'])) - 1

                    # Check the history files for climo date range
                    start_year, stop_year, in_dir, envDict['case2_htype'],  envDict['case2_key_infile'] = diagUtilsLib.checkHistoryFiles(
                        diff_time_series, envDict['SOURCE_2'], envDict['caseid_2'], envDict['clim_first_yr_2'], envDict['clim_last_yr_2'],
                        m_dir,suffix,filep)
                    # Check the history files for trends date range
                    start_year, stop_year, in_dir, envDict['case2_htype'],  envDict['case2_key_infile'] = diagUtilsLib.checkHistoryFiles(
                        diff_time_series, envDict['SOURCE_2'], envDict['caseid_2'], envDict['trends_first_yr_2'], envDict['trends_last_yr_2'],
                        m_dir,suffix,filep)

                    if diff_time_series == 'TRUE':
                        h_path = envDict['SOURCE_2']+'/'+m_dir+'/proc/tseries/monthly/'
                    else:
                        h_path = envDict['SOURCE_2']+'/'+m_dir+'/hist/'
                    case2_climo_dir =  envDict['PTMPDIR']+'/'+ envDict['caseid_2']+'/'

                    createClimFiles(envDict['clim_first_yr_2'], envDict['clim_last_yr_2'], h_path,
                                envDict['case2_htype'], envDict['case2_key_infile'], case2_climo_dir, envDict['caseid_1'], 
                                suffix, varList, envDict, envDict['trends_first_yr_2'], envDict['trends_last_yr_2'], 
                                envDict['climo_'+model+'_2'], envDict['trends_'+model+'_2'], debugMsg)
                except Exception as error:
                    print(str(error))
                    traceback.print_exc()
                    sys.exit(1)


#===================================

if __name__ == "__main__":
    # get commandline options
    options = commandline_options()

    # initialize global vprinter object for printing debug messages
    debugMsg = vprinter.VPrinter(header='', verbosity=0)
    if options.debug:
        header = 'lnd_avg_generator: DEBUG... '
        debugMsg = vprinter.VPrinter(header=header, verbosity=options.debug[0])
    
    try:
        status = main(options, debugMsg)
        debugMsg('*** Successfully completed generating lnd climatology averages ***', header=False)
        sys.exit(status)

##    except RunTimeError as error:
        
    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)

