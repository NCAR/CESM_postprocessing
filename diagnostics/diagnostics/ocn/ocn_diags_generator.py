#!/usr/bin/env python2
"""Generate ocn diagnostics from a CESM case 

This script provides an interface between:
1. the CESM case environment,
2. the ocean diagnostics environment defined in XML files,
3. the Python package for averaging operations in parallel
4. the popdiag zonal average and plotting packages

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

# import additional modules
import datetime
import time
import os, getopt
import glob
import re
import string
import subprocess
import shutil
import shlex
import xml.etree.ElementTree as ET
import argparse
import traceback
import errno
import jinja2

if sys.version_info[0] == 2:
    from ConfigParser import SafeConfigParser as config_parser
else:
    from configparser import ConfigParser as config_parser

from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the MPI related module
from asaptools import partition, simplecomm

# import the pyaverager
from pyaverager import specification, PyAverager

# import the plot modules 
from diagnostics.ocn.Plots import ocn_diags_plot_bc
from diagnostics.ocn.Plots import ocn_diags_plot_factory

# set the debug flag to false by default - can override with the
# --debug command line option
DEBUG = False

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

    parser.add_argument('--debug', action='store_true',
                        help='extra debugging output')

    parser.add_argument('--caseroot', nargs=1, required=True, 
                        help='fully quailfied path to case root directory')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = ' ERROR: ocn_diags_generator.py invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options


#============================================
# initialize_main - initialization from main
#============================================
def initialize_main(envDict, caseroot):
    """initialize_main - initialize settings on rank 0 
    
    Arguments:
    envDict (dictionary) - environment dictionary
    options (list) - input options from command line

    Return:
    envDict (dictionary) - environment dictionary
    """
    # envDict['id'] = 'value' parsed from the CASEROOT/[env_file_list] files
    env_file_list = ['env_case.xml', 'env_run.xml', 'env_build.xml', 'env_mach_pes.xml', 'env_postprocess.xml', 'env_diags_ocn.xml']
    envDict = cesmEnvLib.readXML(caseroot, env_file_list)

##    if DEBUG:
##        print('DEBUG... envDict after readXML')
##        for k,v in envDict.iteritems():
##            print('DEBUG...... envDict[{0}] = {1}'.format(k, v))

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

    # initialize some global variables needed for all plotting types
    start_year = 0
    stop_year = 1
    htype = 'series'
    in_dir = '{0}/ocn/hist'.format(envDict['DOUT_S_ROOT'])

    # get model history file information from the DOUT_S_ROOT archive location
    if DEBUG:
        print('DEBUG... calling checkHistoryFiles')
    start_year, stop_year, in_dir, htype = diagUtilsLib.checkHistoryFiles(
        envDict['GENERATE_TIMESERIES'], envDict['DOUT_S_ROOT'], 
        envDict['CASE'], envDict['YEAR0'], envDict['YEAR1'], 
        'ocn', 'pop.h.*.nc', '.*\.pop\.h\.\d{4,4}-\d{2,2}\.nc')

    envDict['YEAR0'] = start_year
    envDict['YEAR1'] = stop_year
    envDict['in_dir'] = in_dir
    envDict['htype'] = htype

    return envDict

#===================================================
# initialize_model_vs_obs - initialization on rank 0
#===================================================
def initialize_model_vs_obs(envDict):
    """initialize_model_vs_obs - initialize settings on rank 0 for model vs. Observations
    
    Arguments:
    envDict (dictionary) - environment dictionary

    Return:
    envDict (dictionary) - environment dictionary
    """
    # create the working directory if it doesn't already exists
    subdir = 'model_vs_obs.{0}_{1}'.format(envDict['YEAR0'], envDict['YEAR1'])
    workdir = '{0}/{1}'.format(envDict['WORKDIR'], subdir)
    if DEBUG:
        print('DEBUG... checking workdir = {0}'.format(workdir))
    try:
        os.makedirs(workdir)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            err_msg = 'ERROR: ocn_diags_generator.py problem accessing the working directory {0}'.format(workdir)
            raise OSError(err_msg)

    envDict['WORKDIR'] = workdir

    # clean out the old working plot files from the workdir
    if envDict['CLEANUP_FILES'].upper() in ['T','TRUE']:
        cesmEnvLib.purge(workdir, '.*\.pro')
        cesmEnvLib.purge(workdir, '.*\.gif')
        cesmEnvLib.purge(workdir, '.*\.dat')
        cesmEnvLib.purge(workdir, '.*\.ps')
        cesmEnvLib.purge(workdir, '.*\.png')
        cesmEnvLib.purge(workdir, '.*\.html')

    # create the plot.dat file in the workdir used by all NCL plotting routines
    create_plot_dat(envDict['WORKDIR'], envDict['XYRANGE'], envDict['DEPTHS'])

    # create symbolic links between the tavgdir and the workdir
    createLinks(envDict['YEAR0'], envDict['YEAR1'], envDict['TAVGDIR'], envDict['WORKDIR'], envDict['CASE'])

    # setup the gridfile based on the resolution
    os.environ['gridfile'] = '{0}/tool_lib/zon_avg/grids/{1}_grid_info.nc'.format(envDict['DIAGROOTPATH'],envDict['RESOLUTION'])
    if envDict['VERTICAL'] == '42':
        os.environ['gridfile'] = '{0}/tool_lib/zon_avg/grids/{1}_42lev_grid_info.nc'.format(envDict['DIAGROOTPATH'],envDict['RESOLUTION'])

    # check if gridfile exists and is readable
    rc, err_msg = cesmEnvLib.checkFile(os.environ['gridfile'], 'read')
    if not rc:
        raise OSError(err_msg)

    envDict['GRIDFILE'] = os.environ['gridfile']

    # check the resolution and decide if some plot modules should be turned off
    if envDict['RESOLUTION'] == 'tx0.1v2' :
        os.environ['PM_VELISOPZ'] = 'FALSE'
        os.environ['PM_KAPPAZ'] = 'FALSE'

    # create the global zonal average file used by most of the plotting classes
    if DEBUG:
        print('DEBUG... calling create_za')
    create_za( envDict['WORKDIR'], envDict['TAVGFILE'], envDict['GRIDFILE'], envDict['TOOLPATH'], envDict )

    # setup of ecosys files
    if envDict['MODEL_VS_OBS_ECOSYS'].upper() in ['T','TRUE'] :
        # setup some ecosys environment settings
        os.environ['POPDIR'] = 'TRUE'
        os.environ['PME'] = '1'
        sys.path.append(envDict['ECOPATH'])

        # check if extract_zavg exists and is executable
        rc, err_msg = cesmEnvLib.checkFile(envDict['{0}/extract_zavg.sh'.format(envDict['ECOPATH'])],'exec')
        if not rc:
            raise OSError(err_msg)

        # call the ecosystem zonal average extraction modules
        zavg_command = '{0}/extract_zavg.sh {1} {2} {3} {4}'.format(envDict['ECOPATH'],envDict['CASE'],str(start_year),str(stop_year),ecoSysVars)
        rc = os.system(zavg_command)
        if rc:
            err_msg = 'ERROR: ocn_diags_generator.py command {0} failed.'.format(zavg_command)
            raise OSError(err_msg)
 
    return envDict


#==========================================================
# create_plot_dat - create the plot.dat file in the workdir
#==========================================================
def create_plot_dat(workdir, xyrange, depths):
    """create plot.dot  file in the workdir

    Arguments:
    workdir (string) - work directory for plots
    xyrange (string) - env['XYRANGE']
    depths (string) - env['DEPTHS']
    """
    rc, err_msg = cesmEnvLib.checkFile('{0}/plot.dat'.format(workdir), 'read')
    if not rc:
        file = open('{0}/plot.dat'.format(workdir),'w')
        file.write( xyrange + '\n')
        numdepths = len(depths.split(','))
        file.write( str(numdepths) + '\n')
        file.write( depths + '\n')
        file.close()

    return 0


#========================================================================
# callPyAverager - create the climatology files by calling the pyAverager
#========================================================================
def callPyAverager(start_year, stop_year, in_dir, htype, tavgdir, case_prefix, averageList, varList, scomm):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       start_year (integer) - starting year for diagnostics
       stop_year (integer) - ending year for diagnositcs
       in_dir (string) - input directory with either history time slice or variable time series files
       htype (string) - 'series' or 'slice' depending on input history file type
       tavgdir (string) - output directory for climatology files
       case_prefix (string) - input filename prefix
       averageList (list) - list of averages to be created
       varList (list) - list of variables. Note: an empty list implies all variables.
       scomm (object) - simple communicator object
    """
    mean_diff_rms_obs_dir = '/glade/p/work/mickelso/PyAvg-OMWG-obs/obs/'
    region_nc_var = 'REGION_MASK'
    regions={1:'Sou',2:'Pac',3:'Ind',6:'Atl',8:'Lab',9:'Gin',10:'Arc',11:'Hud',0:'Glo'}
    region_wgt_var = 'TAREA'
    obs_dir = '/glade/p/work/mickelso/PyAvg-OMWG-obs/obs/'
    obs_file = 'obs.nc'
    reg_obs_file_suffix = '_hor_mean_obs.nc'

    wght = False
    ncfrmt = 'netcdf'
    serial = False
    clobber = True
    date_pattern = 'yyyymm-yyyymm'
    suffix = 'nc'

    scomm.sync()

    if scomm.is_manager() and DEBUG:
        print('DEBUG... calling specification.create_specifier with following args')
        print('DEBUG...... in_directory = {0}'.format(in_dir))
        print('DEBUG...... out_directory = {0}'.format(tavgdir))
        print('DEBUG...... prefix = {0}'.format(case_prefix))
        print('DEBUG...... suffix = {0}'.format(suffix))
        print('DEBUG...... date_pattern = {0}'.format(date_pattern))
        print('DEBUG...... hist_type = {0}'.format(htype))
        print('DEBUG...... avg_list = {0}'.format(averageList))
        print('DEBUG...... weighted = {0}'.format(wght))
        print('DEBUG...... ncformat = {0}'.format(ncfrmt))
        print('DEBUG...... varlist = {0}'.format(varList))
        print('DEBUG...... serial = {0}'.format(serial))
        print('DEBUG...... clobber = {0}'.format(clobber))
        print('DEBUG...... mean_diff_rms_obs_dir = {0}'.format(mean_diff_rms_obs_dir))
        print('DEBUG...... region_nc_var = {0}'.format(region_nc_var))
        print('DEBUG...... regions = {0}'.format(regions))
        print('DEBUG...... region_wgt_var = {0}'.format(region_wgt_var))
        print('DEBUG...... obs_dir = {0}'.format(obs_dir))
        print('DEBUG...... obs_file = {0}'.format(obs_file))
        print('DEBUG...... reg_obs_file_suffix = {0}'.format(reg_obs_file_suffix))
        print('DEBUG...... main_comm = {0}'.format(scomm))
        print('DEBUG...... scomm = {0}'.format(scomm.__dict__))

    scomm.sync()

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
            main_comm = scomm)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

    scomm.sync()

    # call the pyAverager
    if scomm.is_manager() and DEBUG:
        print("DEBUG...  before run_pyAverager")

    try:
        PyAverager.run_pyAverager(pyAveSpecifier)
        scomm.sync()

    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

#==============================================================================
# create_za - generate the global zonal average file used for most of the plots
#==============================================================================
def create_za(workdir, tavgfile, gridfile, toolpath, envDict):
    """generate the global zonal average file used for most of the plots
    """

    # generate the global zonal average file used for most of the plots
    zaFile = '{0}/za_{1}'.format(workdir, tavgfile)
    rc, err_msg = cesmEnvLib.checkFile(zaFile, 'read')
    if not rc:
        # check that the za executable exists
        zaCommand = '{0}/za'.format(toolpath)
        if DEBUG:
            print('DEBUG... zonal average command = {0}'.format(zaCommand))
        rc, err_msg = cesmEnvLib.checkFile(zaCommand, 'exec')
        if not rc:
            raise OSError(err_msg)
        
        # call the za fortran code from within the workdir
        cwd = os.getcwd()
        os.chdir(workdir)
        try:
#            pipe = subprocess.Popen( [zaCommand,'-O','-time_const','-grid_file', gridfile,tavgfile], cwd=workdir, env=envDict, shell=True)
            pipe = subprocess.Popen(['{0} -O -time_const -grid_file {1} {2}'.format(zaCommand,gridfile,tavgfile)], cwd=workdir, env=envDict, shell=True)
            pipe.wait()
        except OSError as e:
            print('ERROR: {0} call to {1} failed with error:'.format(self.name(), zaCommand))
            print('    {0} - {1}'.format(e.errno, e.strerror))
            sys.exit(1)

        if DEBUG:
            print('DEBUG... zonal average created')
        os.chdir(cwd)

    return True


#=======================================================
# checkEcoSysOptions (stub)
#=======================================================
def checkEcoSysOptions(envDict):
    """checkEcoSysOptions - check the ecosystem XML options settings
    """
    return False

#=======================================================
# getEcoSysVars (stub)
#=======================================================
def getEcoSysVars(ecoSysVarsFile, varList):
    """getEcoSysVars - read the appropriate ecosystem text file of variables
    """

    # check in the ecoSysVarsFile exists and is readable
    rc, err_msg = cesmEnvLib.checkFile(ecoSysVarsFile, 'read')
    if not rc:
        raise OSError(err_msg)
    
    shutil.copy2( ecoSysVarsFile, workdir )
    with open( ecoSysVarsFile, 'r' )  as varfile:
        ecoSysVars = []
        ecoSysVars = varfile.read().replace('\n',' ').split()

    return varList.append(ecoSysVars)

#============================================================
# buildOcnAvgList - build the list of averages to be computed
#============================================================
def buildOcnAvgList(start_year, stop_year, avgFileBaseName, tavgdir):
    """buildAvgList - build the list of averages to be computed
    by the pyAverager. Checks if the file exists or not already.

    Arguments:
    start_year (string) - starting year
    stop_year (string) - ending year
    avgFileBaseName (string) - avgFileBaseName (tavgdir/case.[stream].)

    Return:
    avgList (list) - list of averages to be passed to the pyaverager
    """
    avgList = []
    year = int(start_year)

    # start with the annual averages for all variables
    if DEBUG:
        print('DEBUG... enter buildOcnAvgList')
    while year <= int(stop_year):
        # check if file already exists before appending to the avgList
        avgFile = '{0}.{1}.nc'.format(avgFileBaseName, year)
        if DEBUG:
            print('DEBUG... avgFile = {0}'.format(avgFile))
        rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
        if not rc: 
            avgList.append('ya:{0}'.format(year))
        year += 1

    # check if mavg file already exists
    #    avgFile = '{0}_mavg.nc'.format(avgFileBaseName)
    avgFile = '{0}/mavg.{1}-{2}.nc'.format(tavgdir, start_year, stop_year)
    if DEBUG:
        print('DEBUG... mavgFile = {0}'.format(avgFile))
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if not rc:
        avgList.append('mavg:{0}:{1}'.format(int(start_year), int(stop_year)))

    # check if tavg file already exists
    #    avgFile = '{0}_tavg.nc'.format(avgFileBaseName)
    avgFile = '{0}/tavg.{1}-{2}.nc'.format(tavgdir, start_year, stop_year)
    if DEBUG:
        print('DEBUG... tavgFile = {0}'.format(avgFile))
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if not rc:
        avgList.append('tavg:{0}:{1}'.format(int(start_year), int(stop_year)))

    # the following are for timeseries.... TODO - check if timeseries is specified
    # append the MOC and monthly MOC files
##    avgList.append('moc:{0}:{1}'.format(int(start_year), int(stop_year)))
##    avgList.append('mocm:{0}:{1}'.format(int(start_year), int(stop_year)))
    
    # append the horizontal mean concatenation
##    avgList.append('hor.meanConcat:{0}:{1}'.format(int(start_year), int(stop_year)))

    if DEBUG:
        print('DEBUG... exit buildOcnAvgList avgList = {0}'.format(avgList))
    return avgList

#================================================================
# createLinks - create symbolic links between tavgdir and workdir
#================================================================
def createLinks(start_year, stop_year, tavgdir, workdir, case):
    """createLinks - create symbolic links between tavgdir and workdir

    Arguments:
    start_year (string) - starting year
    stop_year (string) - ending year
    tavgdir (string) - output directory for averages
    workdir (string) - working directory for diagnostics
    case (string) - case name
    """
    avgFileBaseName = '{0}/{1}.pop.h'.format(tavgdir,case)
    case_prefix = '{0}.pop.h'.format(case)

    # link to the mavg file for the za and plotting routings
    avgFile = '{0}/mavg.{1}-{2}.nc'.format(tavgdir, start_year, stop_year)
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if rc:
        mavgFile = '{0}/mavg.{1}.{2}.nc'.format(workdir, start_year, stop_year)
        rc1, err_msg1 = cesmEnvLib.checkFile(mavgFile, 'read')
        if not rc1:
            if DEBUG:
                print('DEBUG... before mavg symlink: {0} to {1}'.format(avgFile,mavgFile))
            os.symlink(avgFile, mavgFile)
    else:
        raise OSError(err_msg)

    # link to the tavg file
    avgFile = '{0}/tavg.{1}-{2}.nc'.format(tavgdir, start_year, stop_year)
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if rc:
        tavgFile = '{0}/tavg.{1}.{2}.nc'.format(workdir, start_year, stop_year)
        rc1, err_msg1 = cesmEnvLib.checkFile(tavgFile, 'read')
        if not rc1:
            if DEBUG:
                print('DEBUG... before tavg symlink: {0} to {1}'.format(avgFile,tavgFile))
            os.symlink(avgFile, tavgFile)
    else:
        raise OSError(err_msg)

    # link to all the annual history files 
    year = int(start_year)
    while year <= int(stop_year):
        # check if file already exists before appending to the avgList
        avgFile = '{0}.{1}.nc'.format(avgFileBaseName, year)
        rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
        if rc:
            workAvgFile = '{0}/{1}.{2}.nc'.format(workdir, case_prefix, year)
            rc1, err_msg1 = cesmEnvLib.checkFile(workAvgFile, 'read')
            if not rc1:
                if DEBUG:
                    print('DEBUG... before yearly avg symlink: {0} to {1}'.format(avgFile,workAvgFile))
                os.symlink(avgFile, workAvgFile)
        year += 1

    return 0


#=============================================
# setupPlots - get the list of plots to create
#=============================================
def setupPlots(envDict):
    """setupPlots - read the XML directives on which plots to create
       and return a list of NCL plotting routines to be run in parallel

       Return:
       plots (list) - list of NCL commands to be run in parallel
    """

    # all the plot module XML vars start with PM_ 
    requested_plots = []
    for key, value in envDict.iteritems():
        if (re.search("\APM_", key) and value.upper() in ['T','TRUE']):
            requested_plots.append(key)

    return requested_plots


#=========================================================================
# createClimFiles - create the climatology files by calling the pyAverager
#=========================================================================
def createClimFiles(start_year, stop_year, in_dir, htype, tavgdir, case, inVarList, scomm):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       start_year (integer) - starting year for diagnostics
       stop_year (integer) - ending year for diagnositcs
       in_dir (string) - input directory with either history time slice or variable time series files
       htype (string) - 'series' or 'slice' depending on input history file type
       tavgdir (string) - output directory for averages
       case (string) - case name
       inVarList (list) - if empty, then create climatology files for all vars, RHO, SALT and TEMP
       scomm (object) - simple communicator object
    """
    # create the list of averages to be computed
    avgFileBaseName = '{0}/{1}.pop.h'.format(tavgdir,case)
    case_prefix = '{0}.pop.h'.format(case)
    averageList = []

    # create the list of averages to be computed by the pyAverager
    if scomm.is_manager():
        if DEBUG:
            print('DEBUG... calling buildOcnAvgList')
        averageList = buildOcnAvgList(start_year, stop_year, avgFileBaseName, tavgdir)
    scomm.sync()

    # bcast the averageList
    averageList = scomm.partition(averageList, func=partition.Duplicate(), involved=True)

    # if the averageList is empty, then all the climatology files exist with all variables
    if len(averageList) > 0:
        # call the pyAverager with the inVarList
        if scomm.is_manager():
            if DEBUG:
                print('DEBUG... calling callPyAverager')
        callPyAverager(start_year, stop_year, in_dir, htype, tavgdir, case_prefix, averageList, inVarList, scomm)
        scomm.sync()
    else:
        if scomm.is_manager():
            if DEBUG:
                print('DEBUG... averageList is null')

#===============================================
# setup model vs. observations plotting routines
#===============================================
def model_vs_obs(envDict, scomm):
    """model_vs_obs setup the model vs. observations dirs, generate necessary 
       zonal average climatology files and generate plots in parallel.

       Arguments:
       comm (object) - MPI global communicator object
       envDict (dictionary) - environment dictionary
    """
    if scomm.is_manager():
        if DEBUG:
            print('DEBUG... calling initialize_model_vs_obs')

        # initialize the model vs. obs environment
        envDict = initialize_model_vs_obs(envDict)

        envDict['IMAGEFORMAT'] = 'png'

        if DEBUG:
            print('DEBUG... calling setXmlEnv in model_vs_obs')
    scomm.sync()

    # broadcast envDict to all tasks
    envDict = scomm.partition(data=envDict, func=partition.Duplicate(), involved=True)

    # set the shell env using the values set in the XML and read into the envDict
    # across all ranks
    cesmEnvLib.setXmlEnv(envDict)

    user_plot_list = list()
    full_plot_list = list()

    # setup the plots to be called based on directives in the env_diags_ocn.xml file
    requested_plot_names = []
    local_requested_plots = list()
    
    # define the templatePath for all tasks
    templatePath = '{0}/diagnostics/diagnostics/ocn/Templates'.format(envDict['POSTPROCESS_PATH']) 

    if scomm.is_manager():
        requested_plot_names = setupPlots(envDict)
        print('User requested plots:')
        for plot in requested_plot_names:
            print('  {0}'.format(plot))

        if envDict['DOWEB'].upper() in ['T','TRUE']:
            
            print('Creating plot html header:')

            templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
            templateEnv = jinja2.Environment( loader=templateLoader )

            TEMPLATE_FILE = 'model_vs_obs.tmpl'
            template = templateEnv.get_template( TEMPLATE_FILE )
    
            # Here we add a new input variable containing a list.
            templateVars = { 'casename' : envDict['CASE'],
                             'tagname' : envDict['CCSM_REPOTAG'],
                             'start_year' : envDict['YEAR0'],
                             'stop_year' : envDict['YEAR1']
                             }

            plot_html = template.render( templateVars )

    scomm.sync()

    # broadcast envDict to all tasks
    requested_plot_names = scomm.partition(data=requested_plot_names, func=partition.Duplicate(), involved=True)

    local_requested_plots = scomm.partition(requested_plot_names, func=partition.EqualStride(), involved=True)
    scomm.sync()

    # define the local_html_list
    local_html_list = list()
    for requested_plot in local_requested_plots:
        try:
            plot = ocn_diags_plot_factory.oceanDiagnosticPlotFactory(requested_plot)

            print('Checking prerequisite for {0} on rank {1}:'.format(plot.__class__.__name__, scomm.get_rank()))
            plot.check_prerequisites(envDict)

            print('Generating plots for {0} on rank {1}:'.format(plot.__class__.__name__, scomm.get_rank()))
            plot.generate_plots(envDict)

            print('Converting plots for {0} on rank {1}:'.format(plot.__class__.__name__, scomm.get_rank()))
            plot.convert_plots(envDict['WORKDIR'], envDict['IMAGEFORMAT'])

            html = plot.get_html(envDict['WORKDIR'], templatePath, envDict['IMAGEFORMAT'])
            
            local_html_list.append(str(html))
            print('DEBUG...  on rank {1} local_html_list = {0}'.format(local_html_list, scomm.get_rank()))

        except ocn_diags_plot_bc.RecoverableError as e:
            # catch all recoverable errors, print a message and continue.
            print(e)
            print("Skipped '{0}' and continuing!".format(request_plot))
        except RuntimeError as e:
            # unrecoverable error, bail!
            print(e)
            return 1

    scomm.sync()

    if scomm.get_size() > 1:
        if scomm.is_manager():
            rank, all_html = scomm.collect()
            all_html[:0] = local_html_list
            try:
                print('DEBUG... all_html = {0}'.format(all_html))
            except Exception as e:
                print('all_html: e = {0}, rank = {1}'.format(e, rank))

            try:
                print('DEBUG... rank = {0}'.format(rank))
            except Exception as e:
                print('rank: e = {0}, rank = {1}'.format(e, rank))

        else:
            return_code = scomm.collect(data=local_html_list)

    if scomm.is_manager():
        print('DEBUG... rank = {0}, all_html = {1}'.format(rank, all_html))

    # if envDict['MODEL_VS_OBS_ECOSYS').upper() in ['T','TRUE'] :

    if scomm.is_manager():
        for each_html in all_html:
            if DEBUG:
                print('DEBUG... each_html = {0}'.format(each_html))
            plot_html += each_html

        with open('{0}/footer.tmpl'.format(templatePath), 'r+') as tmpl:
            plot_html += tmpl.read()

            print('Writing plot html:')
        with open( '{0}/index.html'.format(envDict['WORKDIR']), 'w') as index:
            index.write(plot_html)

        print('Copying stylesheet:')
        shutil.copy2('{0}/diag_style.css'.format(templatePath), '{0}/diag_style.css'.format(envDict['WORKDIR']))

        print('Copying logo files:')
        if not os.path.exists('{0}/logos'.format(envDict['WORKDIR'])):
            os.mkdir('{0}/logos'.format(envDict['WORKDIR']))

        for filename in glob.glob(os.path.join('{0}/logos'.format(templatePath), '*.*')):
            shutil.copy(filename, '{0}/logos'.format(envDict['WORKDIR']))

        if len(envDict['WEBDIR']) > 0 and len(envDict['WEBHOST']) > 0 and len(envDict['WEBLOGIN']) > 0:
            # copy over the files to a remote web server and webdir 
            diagUtilsLib.copy_html_files(envDict)
        else:
            print('Web files successfully created in directory {0}'.format(envDict['WORKDIR']))
            print('The env_diags_ocn.xml variable WEBDIR, WEBHOST, and WEBLOGIN were not set.')
            print('You will need to manually copy the web files to a remote web server.')

        print('*******************************************************************************')
        print('Successfully completed generating ocean diagnostics model vs. observation plots')
        print('*******************************************************************************')

    scomm.sync()

#================
# model vs. model
#================
def model_vs_model(envDict, start_year, stop_year, workdir):
    """model_vs_model setup the model vs. model dirs, generate necessary climatology files
       and generate plots in parallel.

       Arguments:
       start_year - starting year for diagnostics
       stop_year - ending year for diagnositcs

    """

    # setup the plots to be called
    plotXMLfile = '{0}/Diagnostics/ocn/config_ocn_model_vs_model_plots.xml'.format(envDict['CASEROOT'])
    setupPlots(workdir, plotXMLfile, start_year, stop_year)

    if envDict['MODEL_VS_MODEL_ECOSYS'].upper() in ['T','TRUE'] :
        plotXMLfile = '{0}/Diagnostics/ocn/config_ocn_model_vs_model_ecosys_plots.xml'.format(envDict['CASEROOT'])
        setupPlots(workdir, plotXMLfile, start_year, stop_year)
    
    return 0

#==================================
# model vs. observation time series
#==================================
def model_vs_ts(envDict, start_year, stop_year, workdir):
    """model_vs_ts setup the model vs. observational time series dirs, generate necessary climatology files
       and generate plots in parallel.

       Arguments:
       start_year - starting year for diagnostics
       stop_year - ending year for diagnositcs

    """

    # setup the plots to be called
    plotXMLfile = '{0}/Diagnostics/ocn/config_ocn_model_ts_plots.xml'.format(envDict['CASEROOT'])
    setupPlots( workdir, plotXMLfile, start_year, stop_year )

    if envDict['TS_ECOSYS'].upper() in ['T','TRUE'] :
        plotXMLfile = '{0}/Diagnostics/ocn/config_ocn_model_ts_ecosys_plots.xml'.format(envDict['CASEROOT'])
        setupPlots(workdir, plotXMLfile, start_year, stop_year)

    return 0

#======
# main
#======

def main(options, scomm):
    """setup the environment for running the diagnostics in parallel. 

    Calls 3 different diagnostics generation types:
    model vs. observation (optional BGC - ecosystem)
    model vs. model (optional BGC - ecosystem)
    model time-series (optional BGC - ecosystem)

    The env_diags_ocn.xml configuration file defines the way the diagnostics are generated. 
    See (modelnl website here...) for a complete desciption of the env_diags_ocn XML options.
    """

    # initialize the environment dictionary
    envDict = dict()

    # CASEROOT is given on the command line as required option --caseroot
    if scomm.is_manager():
        caseroot = options.caseroot[0]
        if DEBUG:
            print('DEBUG... caseroot = {0}'.format(caseroot))

        if DEBUG:
            print('DEBUG...calling initialize_main')
        envDict = initialize_main(envDict, caseroot)

        if DEBUG:
            print('DEBUG...calling check_ncl_nco')
        diagUtilsLib.check_ncl_nco(envDict)

        if checkEcoSysOptions(envDict):
            varList = getEcoSysVars(envDict['ECOSYSVARSFILE'], varList)

    scomm.sync()
    varList = []

    # broadcast envDict to all tasks
    envDict = scomm.partition(data=envDict, func=partition.Duplicate(), involved=True)
    sys.path.append(envDict['PATH'])
    scomm.sync()

    # generate the climatology files used for all plotting types using the pyAverager
    if DEBUG and scomm.is_manager():
        print('DEBUG... calling createClimFiles')
    try:
        createClimFiles(envDict['YEAR0'], envDict['YEAR1'], envDict['in_dir'],
                        envDict['htype'], envDict['TAVGDIR'], envDict['CASE'], varList, scomm)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

    scomm.sync()

    # model vs. observations
    if envDict['MODEL_VS_OBS'].upper() in ['T','TRUE']:
        if DEBUG and scomm.is_manager():
            print('DEBUG... calling model_vs_obs')
        model_vs_obs(envDict, scomm)
    scomm.sync()

    # model vs. model - need  to checkHistoryFiles for the control run
##    if envDict['MODEL_VS_MODEL'].upper() in ['T','TRUE']:
##        rc = model_vs_model(envDict, start_year, stop_year)

    # model timeseries vs. observations - check dt, cpl.log and cesm.log files
##    if envDict['TS'].upper() in ['T','TRUE']:
##        rc = model_vs_ts(envDict, start_year, stop_year)

#===================================


if __name__ == "__main__":
    # initialize simplecomm object
    scomm = simplecomm.create_comm(serial=False)

    options = commandline_options()
    DEBUG = options.debug

    if DEBUG and scomm.is_manager():
        print('DEBUG...Running on {0} cores'.format(scomm.get_size()))
    scomm.sync()

    try:
        status = main(options, scomm)
        scomm.sync()
        if scomm.is_manager():
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

