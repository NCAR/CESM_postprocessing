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
import datetime
import errno
import getopt
import glob
import itertools
import os
import re
import shlex
import shutil
import string
import subprocess
import time
import traceback
import xml.etree.ElementTree as ET

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

    # initialize some global variables needed for all plotting types
    start_year = 0
    stop_year = 1
    htype = 'series'
    in_dir = '{0}/ocn/hist'.format(envDict['DOUT_S_ROOT'])

    # get model history file information from the DOUT_S_ROOT archive location
    debugMsg('calling checkHistoryFiles', header=True)
    start_year, stop_year, in_dir, htype = diagUtilsLib.checkHistoryFiles(
        envDict['GENERATE_TIMESERIES'], envDict['DOUT_S_ROOT'], 
        envDict['CASE'], envDict['YEAR0'], envDict['YEAR1'], 
        'ocn', 'pop.h.*.nc', '.*\.pop\.h\.\d{4,4}-\d{2,2}\.nc')

    envDict['YEAR0'] = start_year
    envDict['YEAR1'] = stop_year
    envDict['in_dir'] = in_dir
    envDict['htype'] = htype

    return envDict


#======================================================================
# seupt_obs - setup common observation symlinks in workdir on rank 0
#======================================================================
def setup_obs(env, debugMsg):
    """initialize_model_vs_obs - initialize settings on rank 0 for model vs. Observations
    
    Arguments:
    env (dictionary) - environment dictionary
    debugMsg (object) - vprinter object for printing debugging messages
    """
    
    # check that temperature observation TOBSFILE exists and is readable
    rc, err_msg = cesmEnvLib.checkFile('{0}/{1}'.format(env['TSOBSDIR'], env['TOBSFILE']), 'read')
    if not rc:
        raise OSError(err_msg)

    # set a link to TSOBSDIR/TOBSFILE
    sourceFile = '{0}/{1}'.format(env['TSOBSDIR'], env['TOBSFILE'])
    linkFile = '{0}/{1}'.format(env['WORKDIR'], env['TOBSFILE'])
    rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
    if rc:
        rc1, err_msg1 = cesmEnvLib.checkFile(linkFile, 'read')
        if not rc1:
            os.symlink(sourceFile, linkFile)
    else:
        raise OSError(err_msg)

    # check that salinity observation SOBSFILE exists and is readable
    rc, err_msg = cesmEnvLib.checkFile('{0}/{1}'.format(env['TSOBSDIR'], env['SOBSFILE']), 'read')
    if not rc:
        raise OSError(err_msg)

    # set a link to TSOBSDIR/SOBSFILE
    sourceFile = '{0}/{1}'.format(env['TSOBSDIR'], env['SOBSFILE'])
    linkFile = '{0}/{1}'.format(env['WORKDIR'], env['SOBSFILE'])
    rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
    if rc:
        rc1, err_msg1 = cesmEnvLib.checkFile(linkFile, 'read')
        if not rc1:
            os.symlink(sourceFile, linkFile)
    else:
        raise OSError(err_msg)



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


#================================================================
# createLinks - create symbolic links between tavgdir and workdir
#================================================================
def createLinks(start_year, stop_year, tavgdir, workdir, case, debugMsg):
    """createLinks - create symbolic links between tavgdir and workdir

    Arguments:
    start_year (string) - starting year
    stop_year (string) - ending year
    tavgdir (string) - output directory for averages
    workdir (string) - working directory for diagnostics
    case (string) - case name
    """
    padding = 4
    avgFileBaseName = '{0}/{1}.pop.h'.format(tavgdir,case)
    case_prefix = '{0}.pop.h'.format(case)

    # prepend the years with 0's
    zstart_year = start_year.zfill(padding)
    zstop_year = stop_year.zfill(padding)

    # link to the mavg file for the za and plotting routings
    mavgFileBase = 'mavg.{0}.{1}.nc'.format(zstart_year, zstop_year)
    avgFile = '{0}/mavg.{1}-{2}.nc'.format(tavgdir, zstart_year, zstop_year)
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if rc:
        mavgFile = '{0}/mavg.{1}.{2}.nc'.format(workdir, zstart_year, zstop_year)
        rc1, err_msg1 = cesmEnvLib.checkFile(mavgFile, 'read')
        if not rc1:
            debugMsg('before mavg symlink: {0} to {1}'.format(avgFile,mavgFile), header=True)
            os.symlink(avgFile, mavgFile)
    else:
        raise OSError(err_msg)

    # link to the tavg file
    tavgFileBase = 'tavg.{0}.{1}.nc'.format(zstart_year, zstop_year)
    avgFile = '{0}/tavg.{1}-{2}.nc'.format(tavgdir, zstart_year, zstop_year)
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if rc:
        tavgFile = '{0}/tavg.{1}.{2}.nc'.format(workdir, zstart_year, zstop_year)
        rc1, err_msg1 = cesmEnvLib.checkFile(tavgFile, 'read')
        if not rc1:
            debugMsg('before tavg symlink: {0} to {1}'.format(avgFile,tavgFile), header=True)
            os.symlink(avgFile, tavgFile)
    else:
        raise OSError(err_msg)

    # link to all the annual history files 
    year = int(start_year)
    while year <= int(stop_year):
        # check if file already exists before appending to the avgList
        syear = str(year)
        zyear = syear.zfill(padding)
        avgFile = '{0}.{1}.nc'.format(avgFileBaseName, zyear)
        rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
        if rc:
            workAvgFile = '{0}/{1}.{2}.nc'.format(workdir, case_prefix, zyear)
            rc1, err_msg1 = cesmEnvLib.checkFile(workAvgFile, 'read')
            if not rc1:
                debugMsg('before yearly avg symlink: {0} to {1}'.format(avgFile,workAvgFile), header=True)
                os.symlink(avgFile, workAvgFile)
        year += 1

    return mavgFileBase, tavgFileBase

#=============================================
# setup_plots - get the list of plots to create
#=============================================
def setup_plots(envDict):
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

#===============================================
# setup model vs. observations plotting routines
#===============================================
def model_vs_obs(envDict, scomm, debugMsg):
    """model_vs_obs setup the model vs. observations dirs, generate necessary 
       zonal average climatology files and generate plots in parallel.

       Arguments:
       comm (object) - MPI global communicator object
       envDict (dictionary) - environment dictionary
       debugMsg (object) - vprinter object for printing debugging messages
    """
    if scomm.is_manager():
        debugMsg('calling initialize_model_vs_obs', header=True)

        # initialize the model vs. obs environment
        envDict = initialize_model_vs_obs(envDict, debugMsg)

        envDict['IMAGEFORMAT'] = 'png'

        debugMsg('calling setXmlEnv in model_vs_obs', header=True)
    scomm.sync()

    # broadcast envDict to all tasks
    envDict = scomm.partition(data=envDict, func=partition.Duplicate(), involved=True)

    # set the shell env using the values set in the XML and read into the envDict
    # across all ranks
    cesmEnvLib.setXmlEnv(envDict)

    # setup the plots to be called based on directives in the env_diags_ocn.xml file
    requested_plot_names = []
    local_requested_plots = list()
    
    # define the templatePath for all tasks
    templatePath = '{0}/diagnostics/diagnostics/ocn/Templates'.format(envDict['POSTPROCESS_PATH']) 

    if scomm.is_manager():
        requested_plot_names = setup_plots(envDict)
        print('User requested plots:')
        for plot in requested_plot_names:
            print('  {0}'.format(plot))

        if envDict['DOWEB'].upper() in ['T','TRUE']:
            
            debugMsg('Creating plot html header', header=True)

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

            debugMsg('Checking prerequisite for {0}'.format(plot.__class__.__name__), header=True)
            plot.check_prerequisites(envDict)

            debugMsg('Generating plots for {0}'.format(plot.__class__.__name__), header=True)
            plot.generate_plots(envDict)

            debugMsg('Converting plots for {0}'.format(plot.__class__.__name__), header=True)
            plot.convert_plots(envDict['WORKDIR'], envDict['IMAGEFORMAT'])

            html = plot.get_html(envDict['WORKDIR'], templatePath, envDict['IMAGEFORMAT'])
            
            local_html_list.append(str(html))
            debugMsg('local_html_list = {0}'.format(local_html_list), header=True, verbosity=2)

        except ocn_diags_plot_bc.RecoverableError as e:
            # catch all recoverable errors, print a message and continue.
            print(e)
            print("Skipped '{0}' and continuing!".format(request_plot))
        except RuntimeError as e:
            # unrecoverable error, bail!
            print(e)
            return 1

    scomm.sync()

    # define a tag for the MPI collection of all local_html_list variables
    html_msg_tag = 1

    if scomm.get_size() > 1:
        if scomm.is_manager():
            all_html  = [local_html_list]

            for n in range(1,scomm.get_size()):
                rank, temp_html = scomm.collect(tag=html_msg_tag)
                all_html.append(temp_html)

            debugMsg('all_html = {0}'.format(all_html), header=True, verbosity=2)
        else:
            return_code = scomm.collect(data=local_html_list, tag=html_msg_tag)

    scomm.sync()

    # if envDict['MODEL_VS_OBS_ECOSYS').upper() in ['T','TRUE'] :

    if scomm.is_manager():

        # merge the all_html list of lists into a single list
        all_html = list(itertools.chain.from_iterable(all_html))
        for each_html in all_html:
            debugMsg('each_html = {0}'.format(each_html), header=True, verbosity=2)
            plot_html += each_html

        debugMsg('Adding footer html', header=True)
        with open('{0}/footer.tmpl'.format(templatePath), 'r+') as tmpl:
            plot_html += tmpl.read()

        debugMsg('Writing plot html', header=True)
        with open( '{0}/index.html'.format(envDict['WORKDIR']), 'w') as index:
            index.write(plot_html)

        debugMsg('Copying stylesheet', header=True)
        shutil.copy2('{0}/diag_style.css'.format(templatePath), '{0}/diag_style.css'.format(envDict['WORKDIR']))

        debugMsg('Copying logo files', header=True)
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

#======
# main
#======

def main(options, scomm, debugMsg):
    """setup the environment for running the diagnostics in parallel. 

    Calls 3 different diagnostics generation types:
    model vs. observation (optional BGC - ecosystem)
    model vs. model (optional BGC - ecosystem)
    model time-series (optional BGC - ecosystem)

    Arguments:
    options (object) - command line options
    scomm (object) - MPI simple communicator object
    debugMsg (object) - vprinter object for printing debugging messages

    The env_diags_ocn.xml configuration file defines the way the diagnostics are generated. 
    See (website URL here...) for a complete desciption of the env_diags_ocn XML options.
    """

    # initialize the environment dictionary
    envDict = dict()

    # CASEROOT is given on the command line as required option --caseroot
    if scomm.is_manager():
        caseroot = options.caseroot[0]
        debugMsg('caseroot = {0}'.format(caseroot), header=True)

        debugMsg('calling initialize_main', header=True)
        envDict = initialize_main(envDict, caseroot, debugMsg)

        debugMsg('calling check_ncl_nco', header=True)
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
    debugMsg('calling createClimFiles', header=True)
    try:
        createClimFiles(envDict['YEAR0'], envDict['YEAR1'], envDict['in_dir'],
                        envDict['htype'], envDict['TAVGDIR'], envDict['CASE'], varList, scomm, debugMsg)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

    scomm.sync()

    # model vs. observations
    if envDict['MODEL_VS_OBS'].upper() in ['T','TRUE']:
        debugMsg('calling model_vs_obs',header=True)
        model_vs_obs(envDict, scomm, debugMsg)
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

    # get commandline options
    options = commandline_options()

    # initialize global vprinter object for printing debug messages
    if options.debug:
        header = "[" + str(scomm.get_rank()) + "/" + str(scomm.get_size()) + "]: DEBUG... "
        debugMsg = vprinter.VPrinter(header=header, verbosity=options.debug[0])
    
    try:
        status = main(options, scomm, debugMsg)
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

