#!/usr/bin/env python2
"""Generate atmosphere climatology average files for a given CESM case 

This script provides an interface between:
1. the CESM case environment,
2. the atmosphere diagnostics environment defined in XML files,
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
        description='atm_avg_generator: CESM wrapper python program for atmosphere climatology packages.')

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
        err_msg = ' ERROR: atm_avg_generator.py invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options


#============================================================
# buildAtmAvgList - build the list of averages to be computed
#============================================================
def buildAtmAvgList(start_year, stop_year, avgFileBaseName, out_dir, envDict, debugMsg):
    """buildAtmAvgList - build the list of averages to be computed
    by the pyAverager. Checks if the file exists or not already.

    Arguments:
    start_year (string) - starting year
    stop_year (string) - ending year
    avgFileBaseName (string) - avgFileBaseName (out_dir/case.[stream].)

    Return:
    avgList (list) - list of averages to be passed to the pyaverager
    """

    avgList = []

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
       
    # add WACCM zonal averages
    if envDict['test_compute_zonalAvg'] == 'True' or envDict['cntl_compute_zonalAvg'] == 'True':
        avgList.append('zonalavg:{0}:{1}'.format(start_year, stop_year))

    if main_comm.is_manager():
        debugMsg('exit buildAtmAvgList avgList = {0}'.format(avgList))

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

    required_vars =    ['AODVIS','AODDUST','AODDUST1','AODDUST2','AODDUST3','ANRAIN','ANSNOW','AQRAIN','AQSNOW',
                        'AREI','AREL','AWNC','AWNI','CCN3','CDNUMC','CLDHGH','CLDICE','CLDLIQ','CLDMED','CLDLOW',
                        'CLDTOT','CLOUD','DCQ','DTCOND','DTV','FICE','FLDS','FLNS','FLNSC','FLNT','FLNTC','FLUT',
                        'FLUTC','FREQI','FREQL','FREQR','FREQS','FSDS','FSDSC','FSNS','FSNSC','FSNTC','FSNTOA',
                        'FSNTOAC','FSNT','ICEFRAC','ICIMR','ICWMR','IWC','LANDFRAC','LHFLX','LWCF','NUMICE','NUMLIQ',
                        'OCNFRAC','OMEGA','OMEGAT','PBLH','PRECC','PRECL','PRECSC','PRECSL','PS','PSL','Q',
                        'QFLX','QRL','QRS','RELHUM','SHFLX','SNOWHICE','SNOWHLND','SOLIN','SWCF','T','TAUX','TAUY',
                        'TGCLDIWP','TGCLDLWP','TMQ','TREFHT','TS','U','UU','V','VD01','VQ','VT','VU','VV','WSUB','Z3',
                        'CLD_MISR','FMISR1','FISCCP1_COSP','FISCCP1','CLDTOT_ISCCP','MEANPTOP_ISCCP','MEANCLDALB_ISCCP',
                        'CLMODIS','FMODIS1','CLTMODIS','CLLMODIS','CLMMODIS','CLHMODIS','CLWMODIS','CLIMODIS','IWPMODIS',
                        'LWPMODIS','REFFCLIMODIS','REFFCLWMODIS','TAUILOGMODIS','TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS',
                        'TAUWMODIS','TAUTMODIS','PCTMODIS','CFAD_DBZE94_CS','CFAD_SR532_CAL','CLDTOT_CAL','CLDLOW_CAL',
                        'CLDMED_CAL','CLDHGH_CAL','CLDTOT_CS2','U10','ICLDTWP','ICLDIWP']
    cam_chem_vars =    ['CH4','CH4_CHML','SFCH4','CO','CO_CHMP','CO_CHML','SFCO','DCOCHM','DF_CO','O3','O3_Prod','O3_Loss',
                        'O3_CHMP','O3_CHML','DF_O3','CH3CCL3','CH3CCL3_CHML','ISOP','C10H16','LNO_COL_PROD','SFISOP','SFC10H16',
                        'SFCH3OH','SFC2H2','SFCH3COCH3','PHIS','ODV_DST01','ODV_DST02','ODV_DST03','ODV_DST04','AODDUST1',
                        'AODDUST2','AODDUST3','AEROD_v','SFO3','DO3CHM','NO','NO2','NOX','NOY','H2O','Q','OH','H2O2','N2O','HNO3',
                        'PAN','C3H8','CH3COCH3','CH2O','CH3OH','C2H2','C2H6','C3H6','SO2','SO4','CB1','CB2','OC1','OC2','SOA',
                        'SOAI','SOAM','SOAX','SOAB','SOAT','NH4NO3','SOAI_PROD','SOAM_PROD','SOAX_PROD','SOAB_PROD','SOAT_PROD',
                        'CB2SFWET','OC2SFWET','OC2WET','SO4SFWET','SOAISFWET','SOATSFWET','SOABSFWET','SOAXSFWET','SOAMSFWET',
                        'DST01','DST02','DST03','DST04','SSLT01','SSLT02','SSLT03','SSLT04','SAD_TROP','SAD_ICE','SAD_LNAT',
                        'SAD_SULFC','SAD_SO4NIT','SAD_SOA','SAD_BC','jo3_a','jno2','jpan','jh2o2','SFSSLT01','SFSSLT02','SFSSLT03',
                        'SFSSLT04','SFDST01','SFDST02','SFDST03','SFDST04','DST01SFWET','','DST02SFWET','','DST03SFWET','',
                        'DST04SFWET','SSLT01SFWET','SSLT02SFWET','SSLT03SFWET','SSLT04SFWET','SFSO4','SO4_CHMP','SO4_CHML','DSO4CHM',
                        'DTWR_SO2','DF_DST01','DF_DST02','DF_DST03','DF_DST04','DF_SSLT01','DF_SSLT02','DF_SSLT03','DF_SSLT04','DF_OC1',
                        'DF_OC2','DF_CB1','DF_CB2','DF_SOAM','DF_SOAI','DF_SOAT','DF_SOAB','DF_SOAX','DF_SO4','a2x_DSTWET1',
                        'a2x_DSTWET2','a2x_DSTWET3','a2x_DSTWET4','CB1_CLXF','SFCB1','SFCB2','SFOC1','SFOC2','AQSO4_H2O2',
                        'AQSO4_O3','soa_a1','soa_a2','soa_c1','soa_c2','dst_a1','dst_a3','dst_a5','dst_a7','dst_c1','dst_c3','dst_c5',
                        'dst_c7','ncl_a1','ncl_a2','ncl_a3','ncl_a4','ncl_a6','ncl_c1','ncl_a2','ncl_c3','ncl_c4','ncl_c6','pom_a1',
                        'pom_c1','pom_a3','pom_c3','pom_a4','pom_c4','bc_a1','bc_a3','bc_a4','bc_c1','bc_c3','bc_c4','so4_a1','so4_a2',
                        'so4_a3','so4_a4','so4_a5','so4_a6','so4_a7','so4_c1','so4_c2','so4_c3','so4_c4','so4_c5','so4_c6','so4_c7',
                        'SFpom_a1','SFpom_a3','SFpom_a4','pom_a1_CLXF','pom_a2_CLXF','pom_a4_CLXF','pom_a1DDF','pom_a2DDF','pom_a4DDF',
                        'pom_a1SFWET','pom_a2SFWET','pom_a4SFWET','pom_c1DDF','pom_c2DDF','pom_c4DDF','','pom_c1SFWET','pom_c2SFWET',
                        'pom_c4SFWET','SFbc_a1','SFbc_a3','SFbc_a4','bc_a1_CLXF','bc_a2_CLXF','bc_a4_CLXF','bc_a1DDF',
                        'bc_a2DDF','bc_a4DDF','','bc_a1SFWET','bc_a2SFWET','bc_a4SFWET','bc_c1DDF','bc_c2DDF','bc_c4DDF','bc_c1SFWET',
                        'bc_c2SFWET','bc_c4SFWET','soa_a1_sfgaex1','soa_a2_sfgaex1','','soa_a1DDF','soa_a2DDF','soa_a1SFWET',
                        'soa_a2SFWET','soa_c1DDF','soa_c2DDF','soa_c1SFWET','soa_c2SFWET','dst_a1SFWET','dst_a3SFWET','dst_a5SFWET',
                        'dst_a7SFWET','dst_a1DDF','dst_a3DDF','dst_a5DDF','dst_a7DDF','dst_c1SFWET','dst_c3SFWET','dst_c5SFWET',
                        'dst_c7SFWET','dst_c1DDF','dst_c3DDF','dst_c5DDF','dst_c7DDF','ncl_a1SFWET','ncl_a2SFWET','ncl_a3SFWET',
                        'ncl_a4SFWET','ncl_a6SFWET','ncl_a1DDF','ncl_a3DDF','ncl_a4DDF','ncl_a6DDF','ncl_c1SFWET','ncl_c2SFWET',
                        'ncl_c3SFWET','ncl_c4SFWET','ncl_c6SFWET','ncl_c1DDF','ncl_c3DDF','ncl_c4DDF','ncl_c6DDF','SFdst_a1',
                        'SFdst_a3','SFdst_a5','SFdst_a7','SFncl_a1','SFncl_a2','SFncl_a3','SFncl_a4','SFncl_a6','so4_a1_CHMP','so4_a2_CHMP',
                        'so4_a3_CHMP','so4_a4_CHMP','so4_a5_CHMP','so4_a6_CHMP','so4_a7_CHMP','SFso4_a1','SFso4_a2','SFso4_a3','SFso4_a4',
                        'SFso4_a5','SFso4_a6','SFso4_a7','so4_a1_CLXF','so4_a2_CLXF','so4_a3_CLXF','so4_a4_CLXF','so4_a5_CLXF','so4_a6_CLXF',
                        'so4_a7_CLXF','so4_a1_sfgaex1','so4_a2_sfgaex1','so4_a3_sfgaex1','so4_a4_sfgaex1','so4_a5_sfgaex1','so4_a6_sfgaex1',
                        'so4_a7_sfgaex1','so4_a1_sfnnuc1','so4_a2_sfnnuc1','so4_a3_sfnnuc1','so4_a4_sfnnuc1','so4_a5_sfnnuc1','so4_a6_sfnnuc1',
                        'so4_a7_sfnnuc1','so4_a1DDF','so4_a2DDF','so4_a3DDF','so4_a4DDF','so4_a5DDF','so4_a6DDF','so4_a7DDF','so4_a1SFWET',
                        'so4_a2SFWET','so4_a3SFWET','so4_a4SFWET','so4_a5SFWET','so4_a6SFWET','so4_a7SFWET','so4_c1DDF','so4_c2DDF',
                        'so4_c3DDF','so4_c4DDF','so4_c5DDF','so4_c6DDF','so4_c7DDF','so4_c1SFWET','so4_c2SFWET','so4_c3SFWET','so4_c4SFWET',
                        'so4_c5SFWET','so4_c6SFWET','so4_c7SFWET']
    waccm_vars =       ['BRO','CH3CL','CLO','CO2','HCL','HO2','HOCL','QRL_TOT','QRS_TOT']
    #waccm_vars =       ['QRS_TOT', 'QRL_TOT']

    var_list = []
    fileVars = []
   
    # Get a list of variables that we have input data for
    if (htype == 'slice'):
         import Nio

         # Open file and get all variable names 
         f = Nio.open_file(key_infile,'r')
         fileVars = f.variables.keys()

    else: # htype == series
        import glob

        glob_string = '{0}/{1}.{2}.'.format(in_dir,case_prefix,stream)
        file_list = glob.glob(glob_string+'*')
        print (glob_string,'File list:',file_list)
        for f in file_list:
            f_suffix = f.split(glob_string) # remove case name
            suffix_split =  f_suffix[1].split('.') # separate the suffix into pieces, the first will be variable name
            fileVars.append(suffix_split[0])

    # Loop through the requried vars to see which are located in the files
    for var in required_vars:
        if var in fileVars:
            var_list.append(var) # Found in in_files, add to the var_list
    # Loop through cam_chem_vars if users are plotting these sets, then add those variables to the list if we have data for them
    #if all_chem_sets or cset_1 or cset_2 or cset_3 or cset_4 or cset_5 or cset_6 or cset_7:
    for var in cam_chem_vars:
        if var in fileVars:
            var_list.append(var) # Found in in_files, add to the var_list 

    for var in waccm_vars:
        if var in fileVars:
            var_list.append(var) # Found in in_files, add to the var_list 

    return var_list


#========================================================================
# callPyAverager - create the climatology files by calling the pyAverager
#========================================================================
def callPyAverager(start_year, stop_year, in_dir, htype, key_infile, out_dir, case_prefix, averageList, varList, envDict, stream, main_comm, debugMsg):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       start_year (integer) - starting year for diagnostics
       stop_year (integer) - ending year for diagnositcs
       in_dir (string) - input directory with either history time slice or variable time series files
       htype (string) - 'series' or 'slice' depending on input history file type
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
    valid_netcdf_formats = ['netcdf', 'netcdf4', 'netcdf4c', 'netcdfLarge']
    ncfrmt = 'netcdf'
    if envDict['netcdf_format'] in valid_netcdf_formats:
        ncfrmt = envDict['netcdf_format']
    serial = False
    clobber = True
    collapse_dim = 'lon'
    if htype == 'series':
        date_pattern = 'yyyymm-yyyymm'
    else:
        date_pattern = 'yyyy-mm'
    suffix = 'nc'

    main_comm.sync()

    varList = []
    if envDict['strip_off_vars'].lower() in ['t','true']:
        varList = get_variable_list(envDict,in_dir,case_prefix,key_infile,htype,stream)

    main_comm.sync()

    if main_comm.is_manager():
        debugMsg('calling specification.create_specifier with following args', header=True)
        debugMsg('... in_directory = {0}'.format(in_dir), header=True)
        debugMsg('... out_directory = {0}'.format(out_dir), header=True)
        debugMsg('... prefix = {0}'.format(case_prefix), header=True)
        debugMsg('... suffix = {0}'.format(suffix), header=True)
        debugMsg('... date_pattern = {0}'.format(date_pattern), header=True)
        debugMsg('... hist_type = {0}'.format(htype), header=True)
        debugMsg('... avg_list = {0}'.format(averageList), header=True)
        debugMsg('... collapse_dim = {0}'.format(collapse_dim), header=True)
        debugMsg('... weighted = {0}'.format(wght), header=True)
        debugMsg('... ncformat = {0}'.format(ncfrmt), header=True)
        debugMsg('... varlist = {0}'.format(varList), header=True)
        debugMsg('... serial = {0}'.format(serial), header=True)
        debugMsg('... clobber = {0}'.format(clobber), header=True)

    try: 
        pyAveSpecifier = specification.create_specifier(
            in_directory = in_dir,
            out_directory = out_dir,
            prefix = case_prefix,
            suffix=suffix,
            date_pattern=date_pattern,
            hist_type = htype,
            avg_list = averageList,
            collapse_dim = collapse_dim,
            weighted = wght,
            ncformat = ncfrmt,
            varlist = varList,
            serial = serial,
            clobber = clobber,
            main_comm = main_comm)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

    try:
        if main_comm.is_manager():
            debugMsg("calling run_pyAverager", header=True)
        PyAverager.run_pyAverager(pyAveSpecifier)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

#=========================================================================
# createClimFiles - create the climatology files by calling the pyAverager
#=========================================================================
def createClimFiles(start_year, stop_year, in_dir, htype, key_infile, out_dir, case, stream, inVarList, envDict, main_comm, debugMsg):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       start_year (integer) - starting year for diagnostics
       stop_year (integer) - ending year for diagnositcs
       in_dir (string) - input directory with either history time slice or variable time series files
       htype (string) - 'series' or 'slice' depending on input history file type
       out_dir (string) - output directory for averages
       case (string) - case name
       inVarList (list) - if empty, then create climatology files for all vars
    """
    # create the list of averages to be computed
    out_dir = out_dir+'/'+case+'.'+str(start_year)+'-'+str(stop_year)
    avgFileBaseName = '{0}/{1}.{2}'.format(out_dir,case,stream)
    case_prefix = '{0}.{1}'.format(case,stream)
    averageList = []

    # create the list of averages to be computed by the pyAverager
    averageList = buildAtmAvgList(start_year, stop_year, avgFileBaseName, out_dir, envDict, debugMsg)

    main_comm.sync()

    # if the averageList is empty, then all the climatology files exist with all variables
    if len(averageList) > 0:
        # call the pyAverager with the inVarList
        callPyAverager(start_year, stop_year, in_dir, htype, key_infile, out_dir, case_prefix, averageList, inVarList, envDict, stream, main_comm, debugMsg)


#============================================
# initialize_envDict - initialization envDict
#============================================
def initialize_envDict(envDict, caseroot, debugMsg, standalone):
    """initialize_main - initialize settings on rank 0 
    
    Arguments:
    envDict (dictionary) - environment dictionary
    caseroot (string) - case root
    debugMsg (object) - vprinter object for printing debugging messages

    Return:
    envDict (dictionary) - environment dictionary
    """
    # setup envDict['id'] = 'value' parsed from the CASEROOT/[env_file_list] files
    env_file_list =  ['./env_postprocess.xml', './env_diags_atm.xml']
    envDict = cesmEnvLib.readXML(caseroot, env_file_list)

    # debug print out the envDict
    debugMsg('envDict after readXML = {0}'.format(envDict), header=True, verbosity=2)

    # refer to the caseroot that was specified on the command line instead of what
    # is read in the environment as the caseroot may have changed from what is listed
    # in the env xml
    envDict['CASEROOT'] = caseroot

    # add the os.environ['PATH'] to the envDict['PATH']
    envDict['ATMDIAG_PATH'] = os.pathsep + os.environ['PATH']

    # strip the ATMDIAG_ prefix from the envDict entries before setting the 
    # enviroment to allow for compatibility with all the diag routine calls
    envDict = diagUtilsLib.strip_prefix(envDict, 'ATMDIAG_')

    envDict['seas'] = []
    if envDict['plot_ANN_climo']:
        envDict['seas'].append('ANN')
    if envDict['plot_DJF_climo']:
        envDict['seas'].append('DJF')
    if envDict['plot_MAM_climo']:
        envDict['seas'].append('MAM')
    if envDict['plot_JJA_climo']:
        envDict['seas'].append('JJA')
    if envDict['plot_SON_climo']:
        envDict['seas'].append('SON')

    return envDict

#======
# main
#======

def main(options, main_comm, debugMsg):
    """setup the environment for running the pyAverager in parallel. 

    Arguments:
    options (object) - command line options
    main_comm (object) communicator object
    debugMsg (object) - vprinter object for printing debugging messages

    The env_diags_atm.xml configuration file defines the way the diagnostics are generated. 
    See (website URL here...) for a complete desciption of the env_diags_atm XML options.
    """

    # initialize the environment dictionary
    envDict = dict()

    # CASEROOT is given on the command line as required option --caseroot
    caseroot = options.caseroot[0]
    if main_comm.is_manager():
        debugMsg('caseroot = {0}'.format(caseroot), header=True)
        debugMsg('calling initialize_envDict', header=True)

    envDict = initialize_envDict(envDict, caseroot, debugMsg, options.standalone)

    main_comm.sync()
    # specify variables to include in the averages, empty list implies get them all
    varList = []

    # get model history file information from the DOUT_S_ROOT archive location
    if main_comm.is_manager():
        debugMsg('calling checkHistoryFiles for control run', header=True)

    test_time_series = envDict['TEST_TIMESERIES']

    test_end_year = (int(envDict['test_first_yr']) + int(envDict['test_nyrs'])) - 1
    suffix = envDict['test_modelstream']+'.*.nc'
    filep = '.*\.'+ envDict['test_modelstream']+'.\d{4,4}-\d{2,2}\.nc'
    start_year, stop_year, in_dir, envDict['test_htype'],  envDict['test_key_infile'] = \
        diagUtilsLib.checkHistoryFiles(test_time_series, envDict['test_path_history'], 
                                       envDict['test_casename'], envDict['test_first_yr'], test_end_year,
                                       'atm',suffix,filep,envDict['test_path_history_subdir'])

    if envDict['test_compute_climo'] == 'True':
        try:
##            if test_time_series == 'True':
##                h_path = envDict['test_path_history']+'/atm/proc/tseries/month_1/'
##            else:
##                h_path = envDict['test_path_history']+'/atm/hist/'

            h_path = envDict['test_path_history']+envDict['test_path_history_subdir']

            # generate the climatology files used for all plotting types using the pyAverager
            if main_comm.is_manager():
                debugMsg('calling createClimFiles', header=True)

            createClimFiles(envDict['test_first_yr'], test_end_year, h_path,
                            envDict['test_htype'], envDict['test_key_infile'], 
                            envDict['test_path_climo'], envDict['test_casename'], 
                            envDict['test_modelstream'], varList, envDict, main_comm, debugMsg)
        except Exception as error:
            print(str(error))
            traceback.print_exc()
            sys.exit(1)

    if (envDict['MODEL_VS_MODEL'] == 'True' and envDict['cntl_compute_climo'] == 'True'):
        try:
            cntl_time_series = envDict['CNTL_TIMESERIES']
            cntl_end_year = (int(envDict['cntl_first_yr']) + int(envDict['cntl_nyrs'])) - 1
            suffix = envDict['cntl_modelstream']+'.*.nc'
            filep = '.*\.'+ envDict['cntl_modelstream']+'.\d{4,4}-\d{2,2}\.nc'
            start_year, stop_year, in_dir, envDict['cntl_htype'],  envDict['cntl_key_infile'] = \
                diagUtilsLib.checkHistoryFiles(cntl_time_series, envDict['cntl_path_history'], 
                                               envDict['cntl_casename'], envDict['cntl_first_yr'], 
                                               cntl_end_year,'atm',suffix,filep,
                                               envDict['cntl_path_history_subdir'])

##            if cntl_time_series == 'True':
##                h_path = envDict['cntl_path_history']+'/atm/proc/tseries/month_1/'
##            else:
##                h_path = envDict['cntl_path_history']+'/atm/hist/'

            h_path = envDict['cntl_path_history']+envDict['cntl_path_history_subdir']
 
            # generate the climatology files used for all plotting types using the pyAverager
            debugMsg('calling createClimFiles', header=True)

            createClimFiles(envDict['cntl_first_yr'], cntl_end_year, h_path,
                            envDict['cntl_htype'], envDict['cntl_key_infile'], 
                            envDict['cntl_path_climo'], envDict['cntl_casename'], 
                            envDict['cntl_modelstream'], varList, envDict, main_comm, debugMsg)
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
        header = 'atm_avg_generator: DEBUG... '
        debugMsg = vprinter.VPrinter(header=header, verbosity=options.debug[0])
    
    try:
        status = main(options, main_comm, debugMsg)
        if main_comm.is_manager():
            print('*****************************************************************')
            debugMsg('Successfully completed generating atmosphere climatology averages', header=False)
            print('*****************************************************************')
        sys.exit(status)

    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)

