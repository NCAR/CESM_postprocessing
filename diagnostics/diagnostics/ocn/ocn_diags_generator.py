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
import jinja2

if sys.version_info[0] == 2:
    from ConfigParser import SafeConfigParser as config_parser
else:
    from configparser import ConfigParser as config_parser

from cesm_utils import cesmEnvLib
from diagnostics.utils import diag_utils

# import the MPI related module
from pytools import parition, simplecomm

# import the pyaverager
from pyaverager import specification, PyAverager

# import the plot modules 
from diagnostics.ocn.Plots import ocn_diags_plot_bc
from diagnostics.ocn.Plots import ocn_diags_plot_factory

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
        err_msg = 'ocn_diags_generator.py ERROR: invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options


#=======================================================================
# check_ncl_nco - check if NCL and NCO/ncks are installed and accessible
#=======================================================================
def check_ncl_nco(envDict):
    """ check that NCL and NCO/ncks are installed and accessible

    Arguments:
    envDict (dictionary) - environment dictionary
    """
    try:
        subprocess.check_output( ['ncl', '-V'], env=envDict)
    except subprocess.CalledProcessError as e:
        print('NCL is required to run the ocean diagnostics package')
        print('ERROR: {0} call to ncl failed with error:'.format(self.name()))
        print('    {0} - {1}'.format(e.cmd, e.output))
        sys.exit(1)

    try:
        subprocess.check_output( ['ncks', '--version'], env=envDict)
    except subprocess.CalledProcessError as e:
        print('NCO ncks is required to run the ocean diagnostics package')
        print('ERROR: {0} call to ncks failed with error:'.format(self.name()))
        print('    {0} - {1}'.format(e.cmd, e.output))
        sys.exit(1)

    return 0

#============================================
# initialize_main - initialization from main
#============================================
def initialize_main(envDict, options):
    """initialize_main - initialize settings on rank 0 
    
    Arguments:
    options (list) - input options from command line
    envDict (dictionary) - environment dictionary

    Return:
    envDict (dictionary) - environment dictionary
    """
    # CASEROOT is given on the command line as required option --caseroot
    caseroot = options.caseroot[0]

    # check if CCSMROOT is defined - if not, try to get it from the xmlquery in CASEROOT
    diag_utils.checkEnv('CCSMROOT', caseroot)

    # envDict['id'] = 'value' parsed from the CASEROOT/[env_file_list] files
    env_file_list = ['env_case.xml', 'env_run.xml', 'env_build.xml', 'env_mach_pes.xml', 'env_diags_ocn.xml']
    envDict = cesmEnvLib.readXML(caseroot, env_file_list)

    # refer to the caseroot that was specified on the command line instead of what
    # is read in the environment as the caseroot may have changed from what is listed
    # in the env xml
    envDict['CASEROOT'] = caseroot

    # strip the OCNDIAG_ prefix from the envDict entries before setting the 
    # enviroment to allow for compatibility with all the OMWG diag routine calls
    envDict = stripOCNDIAG(envDict)

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
    start_year, stop_year, in_dir, htype = checkHistoryFiles(
        envDict['DOUT_S_GENERATE_TSERIES'], envDict['DOUT_S_ROOT'], 
        envDict['CASE'],
        envDict['YEAR0'], envDict['YEAR1']
        )

    envDict['YEAR0'] = start_year
    envDict['YEAR1'] = stop_year

    # setup the list of variables to compute specific averages - TODO test ecosys vars
    varList = []
    if checkEcoSysOptions(envDict):
        varList = getEcoSysVars(envDict['ECOSYSVARSFILE'], varList)

    # generate the climatology files used for all plotting types using the pyAverager
##    createClimFiles(start_year, stop_year, in_dir, htype, envDict['TAVGDIR'], envDict['CASE'], varList)

    return envDict

#================================================
# initialize_model_vs_obs - initialization on rank 0
#================================================
def initialize_model_vs_obs(envDict, scomm, rank):
    """initialize_model_vs_obs - initialize settings on rank 0 for model vs. Observations
    
    Arguments:
    envDict (dictionary) - environment dictionary

    Return:
    envDict (dictionary) - environment dictionary
    """
    if rank == 0:
        # create the working directory if it doesn't already exists
        subdir = 'pd.{0}_{1}'.format(envDict['YEAR0'], envDict['YEAR1'])
        workdir = '{0}/{1}'.format(envDict['WORKDIR'], subdir)
        if not os.path.exists(workdir):
            os.mkdir(workdir)
        envDict['WORKDIR'] = workdir

        # clean out the old working plot files from the workdir
        if envDict['CLEANUP_FILES'].upper() in ['T','TRUE']:
            diag_utils.purge(workdir, '.*\.pro')
            diag_utils.purge(workdir, '.*\.gif')
            diag_utils.purge(workdir, '.*\.dat')
            diag_utils.purge(workdir, '.*\.ps')
            diag_utils.purge(workdir, '.*\.png')
            diag_utils.purge(workdir, '.*\.html')

        # create the plot.dat file in the workdir used by all NCL plotting routines
        create_plot_dat(envDict['WORKDIR'], envDict['XYRANGE'], envDict['DEPTHS'])

        # create symbolic links between the tavgdir and the workdir
        createLinks(envDict['YEAR0'], envDict['YEAR1'], envDict['TAVGDIR'], envDict['WORKDIR'], envDict['CASE'])

        # setup the gridfile based on the resolution
        os.environ['gridfile'] = '{0}/tool_lib/zon_avg/grids/{1}_grid_info.nc'.format(envDict['DIAGROOTPATH'],envDict['RESOLUTION'])
        if envDict['VERTICAL'] == '42':
            os.environ['gridfile'] = '{0}/tool_lib/zon_avg/grids/{1}_42lev_grid_info.nc'.format(envDict['DIAGROOTPATH'],envDict['RESOLUTION'])

        # check if gridfile exists and is readable
        rc, err_msg = diag_utils.checkFile(os.environ['gridfile'], 'read')
        if not rc:
            raise OSError(err_msg)
        envDict['GRIDFILE'] = os.environ['gridfile']

        # check the resolution and decide if some plot modules should be turned off
        if envDict['RESOLUTION'] == 'tx0.1v2' :
            os.environ['PM_VELISOPZ'] = 'FALSE'
            os.environ['PM_KAPPAZ'] = 'FALSE'

        # create the global zonal average file used by most of the plotting classes
        create_za( envDict['WORKDIR'], envDict['TAVGFILE'], envDict['GRIDFILE'], envDict['TOOLPATH'] )

        # setup of ecosys files
        if envDict['MODEL_VS_OBS_ECOSYS'].upper() in ['T','TRUE'] :
            # setup some ecosys environment settings
            os.environ['POPDIR'] = 'TRUE'
            os.environ['PME'] = '1'
            sys.path.append(envDict['ECOPATH'])

            # check if extract_zavg exists and is executable
            rc, err_msg = diag_utils.checkFile(envDict['{0}/extract_zavg.sh'.format(envDict['ECOPATH'])],'exec')
            if not rc:
                raise OSError(err_msg)

            # call the ecosystem zonal average extraction modules
            zavg_command = '{0}/extract_zavg.sh {1} {2} {3} {4}'.format(envDict['ECOPATH'],envDict['CASE'],str(start_year),str(stop_year),ecoSysVars)
            rc = os.system(zavg_command)
            if rc:
                err_msg = 'ocn_diags_generator.py ERROR: command {0} failed.'.format(zavg_command)
                raise OSError(err_msg)

    comm.Barrier()
    return envDict


#============================================
# stripOCN - strip the 'OCNDIAG_' from the id
#============================================
def stripOCNDIAG(indict):
    """stripOCN - Read the indict and strip off the leading 'OCNDIAG_' from the id element (key).
    
    Arguments:
    indict - dictionary input with OCNDIAG_ from the id element

    Return:
    outdict - dictionary with OCNDIAG_ stripped from the id element
    """
    outdict = dict()

    for k,v in indict.iteritems():
        if k.startswith('OCNDIAG_'):
            outdict[k[8:]] = v
        else:
            outdict[k] = v

    return outdict

#=============================================================
# filterPick - return filenames that match a pattern in a list
#=============================================================
def filterPick(files,regex):
    return [m.group(0) for f in files for m in [regex.search(f)] if m]


#======================================
# checkXMLyears - check run year bounds
#======================================
def checkXMLyears(hfstart_year, hfstop_year, rstart_year, rstop_year):
    """checkXMLyears - check that the years requested in the XML fall within the
    bounds of the actual history files available

    Arguments:
    hfstart_year (string) - model job start year
    hfstop_year (string) -  model job end year
    rstart_year (string) - requested start year for diagnostics
    rstop_year (string) - requested stop year for diagnostics

    Return:
    start_year (string) - for average calculations
    stop_year (string) - for average calculations
    """
    start_year = min(hfstart_year, rstart_year)
    stop_year = min(hfstop_year, rstop_year)
    assert(stop_year > start_year)

    return (start_year, stop_year)

#========================================
# checkHistoryFiles - check history files
#========================================
def checkHistoryFiles(tseries, dout_s_root, case, rstart_year, rstop_year):
    """checkHistoryFiles - check if variable history time-series 
    files or history time-slice files exist
    in the DOUT_S_ROOT location. Then check the actual run files 
    to get the start and stop years to compare against
    the XML specified YEAR0 and YEAR1. The OMWG diags 
    package only works with monthly average history files
    to generate annual mean history files. 

    Arguments:
    tseries (boolean) - corresponds to XML variable DOUT_S_TSERIES_GENERATE
    dout_s_root (string) - corresponds to XML variable DOUT_S_ROOT disk archive location
    case (string) - corresponds to XML variable CASE name
    rstart_year (string) - requested diagnostics model start year from XML env_diags_ocn.xml
    rstop_year (string) - requested diagnostics model stop year from XML env_diags_ocn.xml

    Return:
    start_year (string) - start year as defined by the history files
    stop_year (string) - last year as defined by the history files
    in_dir (string) - directory location of history files
    hType (string) - history file type (slice or series)
    """
    if tseries.upper() in ['T','TRUE'] :
        htype = 'series'
        in_dir = '{0}/ocn/proc/tseries/monthly'.format(dout_s_root)
    else :
        htype = 'slice'
        in_dir = '{0}/ocn/hist'.format(dout_s_root)

    # check the in_dir directory exists 
    if not os.path.isdir(in_dir) :
        err_msg = 'ocn_diags_generator.py ERROR: {0} directory is not available.'.format(in_dir)
        raise OSError(err_msg)

    # get the file paths and formats - TO DO may need to get this from namelist var or env_archive
    files = '{0}.pop.h.*.nc'.format(case)
    fformat = '{0}/{1}'.format(in_dir, files)

    if htype == 'slice':
        # get the first and last years from the first and last monthly history files
        allHfiles = sorted(glob.glob(fformat))
        pattern = re.compile('.*\.pop\.h\.\d{4,4}-\d{2,2}\.nc')
        hfiles = filterPick(allHfiles, pattern)

        # TO-DO open a history time-slice file and make sure it's monthly data

        # the first element of the hfiles list has the start year
        tlist = hfiles[0].split('.')
        slist = tlist[-2].split('-')
        hfstart_year = slist[0]
        hfstart_month = slist[1]

        # the last element of the hfiles list has the stop year
        tlist = hfiles[-1].split('.')
        slist = tlist[-2].split('-')
        hfstop_year = slist[0]
        hfstop_month = slist[1]

    elif htype == 'series':
        hfiles = sorted(glob.glob(fformat))

        # TO-DO open a history time-series file and make sure it's monthly data

        # the first variable time series file has the stop and start years
        tlist = hfiles[0].split('.')
        slist = tlist[-2].split('-')
        hfstart_year = slist[0][:4]
        hfstart_month = slist[0][4:6]
        hfstop_year = slist[1][:4]
        hfstop_month = slist[1][4:6]

    # check if the XML YEAR0 and YEAR1 are within the actual start_year and stop_year bounds 
    # defined by the actual history files
    start_year, stop_year = checkXMLyears(hfstart_year, hfstop_year, rstart_year, rstop_year)

    return (start_year, stop_year, in_dir, htype)


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
    cwd = os.getcwd()
    os.chdir(workdir)
    rc, err_msg = diag_utils.checkFile('plot.dat', 'read')
    if not rc:
        file = open('plot.dat','w')
        file.write( xyrange + '\n')
        numdepths = len(depths.split(','))
        file.write( str(numdepths) + '\n')
        file.write( depths + '\n')
        file.close()
    os.chdir(cwd)

    return 0

#=======================================================
# convert_plots - convert plots from ps to gif
#=======================================================
def convert_plots(workdir, scomm):
    """convert_plots - convert plot files from ps to gif

    """
    cwd = os.getcwd()
    os.chdir(workdir)

    # check if the convert command exists
    rc = diag_utils.which('convert')
    if rc in ['None']:
        print('ocn_diags_generator.py WARNING: unable to find convert command in path. Skipping plot conversion from ps to gif')
    else:
        psFiles = sorted(glob.glob('*.ps'))

        # partition the list of psFiles across the available tasks
        local_psFiles = scomm.partition(psFiles, func=partition.EqualStride(), involved=True)

        for ps in local_psFiles:
            plotname = ps.split('.')
            psFile = '{0}.ps'.format(plotname[0])
            print('..... converting {0}'.format(psFile))
            
            # check if the GIF file alreay exists and remove it to regen
            gifFile = '{0}.gif'.format(plotname[0])
            rc, err_msg = diag_utils.checkFile(gifFile,'write')
            if rc:
                os.remove(gifFile)
        
            # convert the image from ps to gif - these should be done in parallel
            try:
                subprocess.check_output( ['convert','-trim','-bordercolor','white','-border','5x5','-density','95',psFile,gifFile] )
            except subprocess.CalledProcessError as e:
                print('WARNING: convert_plots call to convert failed with error:')
                print('    {0} - {1}'.format(e.cmd, e.output))
            else:
                continue
        scomm.sync()

    os.chdir(cwd)

    return True

#==============================================================================
# create_za - generate the global zonal average file used for most of the plots
#==============================================================================
def create_za(workdir, tavgfile, gridfile, toolpath):
    """generate the global zonal average file used for most of the plots
    """

    # generate the global zonal average file used for most of the plots
    zaFile = '{0}/za_{1}'.format(workdir, tavgfile)
    rc, err_msg = diag_utils.checkFile(zaFile, 'read')
    if not rc:
        print('     Checking on the zonal average (za) file compiled fortran code.')
        # check that the za executable exists
        zaCommand = '{0}/za'.format(toolpath)
        rc, err_msg = diag_utils.checkFile(zaCommand, 'exec')
        if not rc:
            raise OSError(err_msg)
        
        # call the za fortran code from within the workdir
        cwd = os.getcwd()
        os.chdir(workdir)
        try:
            subprocess.check_output( [zaCommand,'-O','-time_const','-grid_file',gridfile, tavgfile], env=env)
        except subprocess.CalledProcessError as e:
            print('ERROR: {0} call to {1} failed with error:'.format(self.name(), zaCommand))
            print('    {0} - {1}'.format(e.cmd, e.output))
            sys.exit(1)

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
    rc, err_msg = diag_utils.checkFile(ecoSysVarsFile, 'read')
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
def buildOcnAvgList(start_year, stop_year, avgFileBaseName):
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

    # start with the annual averages with all variables
    while year <= int(stop_year):
        # check if file already exists before appending to the avgList
        avgFile = '{0}.{1}.nc'.format(avgFileBaseName, year)
        rc, err_msg = diag_utils.checkFile(avgFile, 'read')
        if not rc: 
            avgList.append('ya:{0}'.format(year))
            year += 1

    # check if mavg file already exist
    avgFile = '{0}_mavg.nc'.format(avgFileBaseName)
    rc, err_msg = diag_utils.checkFile(avgFile, 'read')
    if not rc:
        avgList.append('mavg:{0}:{1}'.format(int(start_year), int(stop_year)))

    # check if tavg file already exist
    avgFile = '{0}_tavg.nc'.format(avgFileBaseName)
    rc, err_msg = diag_utils.checkFile(avgFile, 'read')
    if not rc:
        avgList.append('tavg:{0}:{1}'.format(int(start_year), int(stop_year)))

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
    avgFile = '{0}_mavg.nc'.format(avgFileBaseName)
    rc, err_msg = diag_utils.checkFile(avgFile, 'read')
    if rc:
        mavgFile = '{0}/mavg.{1}.{2}.nc'.format(workdir, start_year, stop_year)
        rc1, err_msg1 = diag_utils.checkFile(mavgFile, 'read')
        if not rc1:
            print('...before mavg symlink: {0} to {1}'.format(avgFile,mavgFile))
            os.symlink(avgFile, mavgFile)
    else:
        raise OSError(err_msg)

    # link to the tavg file
    avgFile = '{0}_tavg.nc'.format(avgFileBaseName)
    rc, err_msg = diag_utils.checkFile(avgFile, 'read')
    if rc:
        tavgFile = '{0}/tavg.{1}.{2}.nc'.format(workdir, start_year, stop_year)
        rc1, err_msg1 = diag_utils.checkFile(tavgFile, 'read')
        if not rc1:
            print('...before tavg symlink: {0} to {1}'.format(avgFile,tavgFile))
            os.symlink(avgFile, tavgFile)
    else:
        raise OSError(err_msg)

    # link to all the annual history files 
    year = int(start_year)
    while year <= int(stop_year):
        # check if file already exists before appending to the avgList
        avgFile = '{0}.{1}.nc'.format(avgFileBaseName, year)
        rc, err_msg = diag_utils.checkFile(avgFile, 'read')
        if rc:
            workAvgFile = '{0}/{1}.{2}.nc'.format(workdir, case_prefix, year)
            rc1, err_msg1 = diag_utils.checkFile(workAvgFile, 'read')
            if not rc1:
                print('...before yearly avg symlink: {0} to {1}'.format(avgFile,workAvgFile))
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


#========================================================================
# callPyAverager - create the climatology files by calling the pyAverager
#========================================================================
def callPyAverager(start_year, stop_year, in_dir, htype, tavgdir, case_prefix, averageList, varList):
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
    """
    # pyAveSpecifier is a pyAverage specifier
    pyAveSpecifier = specification.create_specifier(
        in_directory = in_dir,
        out_directory = tavgdir,
        prefix = case_prefix,
        file_pattern = 'prefix*-*.nc',
        hist_type = htype,
        avg_list = averageList,
        weighted = False,
        split = False,
        split_files = 'null',
        split_orig_size = 'lon=288,lat=192',
        ncformat = 'netcdf',
        varlist = varList,
        serial = False)

    # call the pyAverager
    print("... before run_pyAverager scomm rank={0}, size={1}".format(scomm.get_rank(), scomm.get_size())
    PyAverager.run_pyAverager(pyAveSpecifier, simplecomm=scomm)

    return 0

#=========================================================================
# createClimFiles - create the climatology files by calling the pyAverager
#=========================================================================
def createClimFiles(start_year, stop_year, in_dir, htype, tavgdir, case, inVarList):
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
    """
    # create the list of averages to be computed
    avgFileBaseName = '{0}/{1}.pop.h'.format(tavgdir,case)
    case_prefix = '{0}.pop.h'.format(case)
    averageList = []

    # create the list of averages to be computed by the pyAverager
    averageList = buildOcnAvgList(start_year, stop_year, avgFileBaseName)

    # if the averageList is empty, then all the climatology files exist with all variables
    if len(averageList) > 0:
        # call the pyAverager with the inVarList
        rc = callPyAverager(start_year, stop_year, in_dir, htype, tavgdir, case_prefix, averageList, inVarList)

    return 0


#===============================================
# setup model vs. observations plotting routines
#===============================================
def model_vs_obs(envDict, scomm, rank, size):
    """model_vs_obs setup the model vs. observations dirs, generate necessary 
       zonal average climatology files and generate plots in parallel.

       Arguments:
       comm (object) - MPI global communicator object
       envDict (dictionary) - environment dictionary
       pp (object) - prettyPrinter object
    """
    if rank == 0:
        print('...calling initialize_model_vs_obs')
    # initialize the model vs. obs environment
    envDict = initialize_model_vs_obs(envDict, scomm, rank)

    user_plot_list = list()
    if rank == 0:

    # set the shell env using the values set in the XML and read into the envDict
##    print('...calling setXmlEnv in model_vs_obs')
##    cesmEnvLib.setXmlEnv(envDict)

        # setup the plots to be called based on directives in the env_diags_ocn.xml file
        requested_plots = []
        requested_plots = setupPlots(envDict)

        print('Generating list of plots:')

        for request_plot in requested_plots:
            try:
                plot = ocn_diags_plot_factory.oceanDiagnosticPlotFactory(request_plot)
                user_plot_list.append(plot)
            except ocn_diags_plot_bc.RecoverableError as e:
                # catch all recoverable errors, print a message and continue.
                print(e)
                print("Skipped '{0}' and continuing!".format(request_plot))
            except RuntimeError as e:
                # unrecoverable error, bail!
                print(e)
                return 1

        print('User requested plots:')
        for plot in user_plot_list:
            print('  {0}'.format(plot.__class__.__name__))

        print('Checking prerequisite:')
        for plot in user_plot_list:
            plot.check_prerequisites(envDict)

        # dispatch mpi plotting jobs here
        print('Generating plots in parallel:')
    scomm.sync()
    user_plot_list = scomm.partition(user_plot_list, func=partition.EqualStride(), involved=True)
    
    for user_plot in user_plot_list:
        user_plot.generate_plots(envDict)  
    scomm.sync()
            
    # if envDict['MODEL_VS_OBS_ECOSYS').upper() in ['T','TRUE'] :

    # convert ps plots to gif for html in parallel
#    convert_plots(envDict['WORKDIR'], messenger)

    if rank == 0:
        print('... before convert_plots')
    convert_plots(envDict['WORKDIR'], scomm)
    scomm.sync()

    if rank == 0:
        print('Creating plot html header:')
#        templateLoader = jinja2.FileSystemLoader( searchpath='.' )
        templateLoader = jinja2.PackageLoader('diagnostics', 'Templates' )
        templateEnv = jinja2.Environment( loader=templateLoader )

#        TEMPLATE_FILE = './Templates/model_vs_obs.tmpl'
        TEMPLATE_FILE = 'model_vs_obs.tmpl'
        template = templateEnv.get_template( TEMPLATE_FILE )
    
        # Here we add a new input variable containing a list.
        templateVars = { 'casename' : envDict['CASE'],
                         'tagname' : envDict['CCSM_REPOTAG'],
                         'start_year' : envDict['YEAR0'],
                         'stop_year' : envDict['YEAR1']
                         }

        plot_html = template.render( templateVars )
    
        for plot in user_plot_list:
            plot_html += plot.get_html(envDict['WORKDIR'])

        with open('./Templates/footer.tmpl', 'r+') as tmpl:
            plot_html += tmpl.read()

            print('Writing plot html:')
        with open( '{0}/index.html'.format(envDict['WORKDIR']), 'w') as index:
            index.write(plot_html)

        print('Copying stylesheet:')
        shutil.copy2('./Templates/diag_style.css', '{0}/diag_style.css'.format(envDict['WORKDIR']))

        print('Copying logo files:')
        if not os.path.exists('{0}/logos'.format(envDict['WORKDIR'])):
            os.mkdir('{0}/logos'.format(envDict['WORKDIR']))

        for filename in glob.glob(os.path.join('./Templates/logos', '*.*')):
            shutil.copy(filename, '{0}/logos'.format(envDict['WORKDIR']))

        print('Successfully completed generating ocean diagnostics model vs. observation plots')

    comm.Barrier()
    return 0

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

def main(options, scomm, rank, size):
    """setup the environment for running the diagnostics in parallel. 

    Calls 3 different diagnostics generation types:
    model vs. observation (optional BGC - ecosystem)
    model vs. model (optional BGC - ecosystem)
    model time-series (optional BGC - ecosystem)

    The env_ocn_diags_settings.xml configuration file defines the way the diagnostics are generated. 
    See (modelnl website here...) for a complete desciption of the env_ocn_diags_settings XML options.
    """
    # initialize the environment dictionary
    envDict = dict()

    if rank == 0:
        print('...calling initialize_main')
    envDict = initialize_main(envDict, options)
    scomm.sync()

    if rank == 0:
        print('...checking NCL and NCO')
        rc = check_ncl_nco(envDict)
    scomm.sync()

    # the PATH variable needs to be handled uniquely because of name conflicts
    if rank == 0:
        print('...calling sys.path.append')
    sys.path.append(envDict['PATH'])
    sys.path.append(envDict['OCN_DIAG_PATH'])
    scomm.sync()

    # set the shell env using the values set in the XML and read into the envDict
##    print('...calling setXmlEnv')
##    cesmEnvLib.setXmlEnv(envDict)

    # model vs. observations
    if envDict['MODEL_VS_OBS'].upper() in ['T','TRUE']:
        if rank == 0:
            print('...calling model_vs_obs')
        rc = model_vs_obs(envDict, scomm, rank, size)

    # model vs. model - need  to checkHistoryFiles for the control run
##    if envDict['MODEL_VS_MODEL'].upper() in ['T','TRUE']:
##        rc = model_vs_model(envDict, start_year, stop_year)

    # model timeseries vs. observations - check dt, cpl.log and cesm.log files
##    if envDict['TS'].upper() in ['T','TRUE']:
##        rc = model_vs_ts(envDict, start_year, stop_year)

    return 0

#===================================


if __name__ == "__main__":
    # initialize simplecomm object
    scomm = simplecomm.create_comm(serial=False)

    rank = scomm.get_rank()
    size = scomm.get_size()

    if rank == 0:
        print('...Running on {0} cores'.format(size))

    options = commandline_options()
    try:
        status = main(options, scomm, rank, size)
        if rank == 0:
            print('Successfully completed generating ocean diagnostics')
        sys.exit(status)

##    except RunTimeError as error:
        
    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)

