#!/usr/bin/env python2
"""
This module provides utility functions for the diagnostics wrapper python scripts.
__________________________
Created on Apr 01, 2015

@author: NCAR - CSEG
"""

import os
import re
import glob
import subprocess
import time
from cesm_utils import cesmEnvLib


#=======================================================================
# check_ncl_nco - check if NCL and NCO/ncks are installed and accessible
#=======================================================================
def check_ncl_nco(envDict):
    """ check that NCL and NCO/ncks are installed and accessible

    Arguments:
    envDict (dictionary) - environment dictionary
    """

    cmd = ['ncl', '-V']
    try:
        pipe = subprocess.Popen(cmd, env=envDict)
        pipe.wait()
    except OSError as e:
        print('NCL is required to run the ocean diagnostics package')
        print('ERROR: {0} call to "{1}" failed with error:'.format('check_ncl_nco', ' '.join(cmd)))
        print('    {0} - {1}'.format(e.errno, e.strerror))
        sys.exit(1)

    cmd = ['ncks', '--version']
    try:
        print('DEBUG... before ncks check')
        pipe = subprocess.Popen(cmd , env=envDict)
        pipe.wait()
        print('DEBUG... after ncks check')
    except OSError as e:
        print('NCO ncks is required to run the ocean diagnostics package')
        print('ERROR: {0} call to "{1}" failed with error:'.format('check_ncl_nco', ' '.join(cmd)))
        print('    {0} - {1}'.format(e.errno, e.strerror))
        sys.exit(1)

#============================================================
# generate_ncl_plots - call a nclPlotFile via subprocess call
#============================================================
def generate_ncl_plots(env, nclPlotFile):
    """generate_plots_call - call a nclPlotFile via subprocess call

    Arguments:
    env (dictionary) - diagnostics system environment 
    nclPlotFile (string) - ncl plotting file name
    """
#    cwd = os.getcwd()
#    os.chdir(env['WORKDIR'])

    # check if the nclPlotFile exists - 
    # don't exit if it does not exists just print a warning.
    nclFile = '{0}/{1}'.format(env['NCLPATH'],nclPlotFile)
    rc, err_msg = cesmEnvLib.checkFile(nclFile, 'read')
    if rc:
        try:
            print('      calling NCL plot routine {0}'.format(nclPlotFile))
#            pipe = subprocess.Popen( ['ncl',nclFile], cwd=env['WORKDIR'], env=env, shell=True)
            pipe = subprocess.Popen(['ncl {0}'.format(nclFile)], cwd=env['WORKDIR'], env=env, shell=True)
            pipe.wait()
#            while pipe.poll() is None:
#                time.sleep(0.5)
        except OSError as e:
            print('WARNING: {0} call to {1} failed with error:'.format(self.name(), nclfile))
            print('    {0} - {1}'.format(e.errno, e.strerror))
    else:
        print('{0}... continuing with additional plots.'.format(err_msg))
#    os.chdir(cwd)

    return 0


#============================================
# strip_prefix - strip the prefix from the id
#============================================
def strip_prefix(indict, prefix):
    """strip_prefix - Read the indict and strip off the leading prefix from the id element (key).
    
    Arguments:
    indict (dictionary) - input with OCNDIAG_ from the id element
    prefix (string) - prefix string to be stripped

    Return:
    outdict (dictionary) with prefix stripped from the id element
    """
    outdict = dict()

    for k,v in indict.iteritems():
        if k.startswith(prefix):
            outdict[k[8:]] = v
        else:
            outdict[k] = v

    return outdict


#=============================================================
# filter_pick - return filenames that match a pattern in a list
#=============================================================
def filter_pick(files,regex):
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
    # make sure the requested years from the XML are in range with the actual history files
    if not int(hfstart_year) <= int(rstart_year) <= int(hfstop_year):
        err_msg = 'ERROR: diagUtilsLib.checkXMLyears requested XML YEAR0 = {0} does not fall within range of actual available model history file years: {1}-{2}'.format(rstart_year, hfstart_year, hfstop_year)
        raise OSError(err_msg)

    if not int(hfstart_year) <= int(rstop_year) <= int(hfstop_year):
        err_msg = 'ERROR: diagUtilsLib.checkXMLyears requested XML YEAR1 = {0} does not fall within range of actual available model history file years: {1}-{2}'.format(rstop_year, hfstart_year, hfstop_year)
        raise OSError(err_msg)

    if int(rstop_year) < int(rstart_year):
        err_msg = 'ERROR: diagUtilsLib.checkXMLyears requested XML YEAR1 = {0} is less than YEAR0 = {1}'.format(rstop_year, rstart_year)
        raise OSError(err_msg)

    start_year = rstart_year
    stop_year = rstop_year

    return (start_year, stop_year)


#========================================
# checkHistoryFiles - check history files
#========================================
def checkHistoryFiles(tseries, dout_s_root, case, rstart_year, rstop_year, comp, suffix, filep):
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
    comp (string) - component one of atm, ice, lnd, or ocn
    suffix (string) - suffix for history files
    filep (string) - file pattern to match filenames

    Return:
    start_year (string) - start year as defined by the history files
    stop_year (string) - last year as defined by the history files
    in_dir (string) - directory location of history files
    hType (string) - history file type (slice or series)
    """
    if tseries.upper() in ['T','TRUE'] :
        htype = 'series'
        in_dir = '{0}/{1}/proc/tseries/monthly'.format(dout_s_root, comp)
    else :
        htype = 'slice'
        in_dir = '{0}/{1}/hist'.format(dout_s_root, comp)

    # check the in_dir directory exists 
    if not os.path.isdir(in_dir):
        err_msg = 'ERROR: diagUtilsLib.checkHistoryFiles {0} directory is not available.'.format(in_dir)
        raise OSError(err_msg)

    # get the file paths and formats - TO DO may need to get this from namelist var or env_archive
    files = '{0}.{1}'.format(case, suffix)
    fformat = '{0}/{1}'.format(in_dir, files)

    if htype == 'slice':
        # get the first and last years from the first and last monthly history files
        allHfiles = sorted(glob.glob(fformat))
        pattern = re.compile(filep)
        hfiles = filter_pick(allHfiles, pattern)

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


