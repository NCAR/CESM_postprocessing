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
import shutil
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
        pipe = subprocess.Popen(cmd , env=envDict)
        pipe.wait()
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
    # check if the nclPlotFile exists - 
    # don't exit if it does not exists just print a warning.
    nclFile = '{0}/{1}'.format(env['NCLPATH'],nclPlotFile)
    print('      calling NCL routine {0}'.format(nclFile))
    rc, err_msg = cesmEnvLib.checkFile(nclFile, 'read')
    if rc:
        try:
            pipe = subprocess.Popen(['ncl {0}'.format(nclFile)], cwd=env['WORKDIR'], env=env, shell=True, stdout=subprocess.PIPE)
            output = pipe.communicate()[0]
            print('NCL routine {0} \n {1}'.format(nclFile,output))            
            while pipe.poll() is None:
                time.sleep(0.5)
        except OSError as e:
            print('WARNING',e.errno,e.strerror)
            # The below warnings are giving runtime tuple errors.  Commented them out for now.
            #print('WARNING: {0} call to {1} failed with error:'.format(self.name(), nclFile))
            #print('    {0} - {1}'.format(e.errno, e.strerror))
    else:
        print('{0}... continuing with additional NCL calls.'.format(err_msg))

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
    i = len(prefix) + 1;

    for k,v in indict.iteritems():
        if k.startswith(prefix):
#            outdict[k[i:]] = v
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
# check_series_years - checks to see if the number of time slices in the file
#                      match the date string
#======================================
def check_series_years(hfstart_year, hfstart_month, hfstop_year, hfstop_month, hfile):

    """ check_series_years - checks to see if the number of time slices in the file match the date string
    """

    import Nio

    # Get the count for how many slices the filename says there should be
    fname_slice_count = ((12 - int(hfstart_month))+1)+((int(hfstop_year) - int(hfstart_year)) * 12) - (12 - int(hfstop_month))

    # Get the actually count within the file
    f = Nio.open_file(hfile)
    file_slice_count = f.dimensions['time']
    f.close()

    # Return True if they counts match, False if they do not match
    return  file_slice_count == fname_slice_count

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
    #if not int(hfstart_year) <= int(rstart_year) <= int(hfstop_year):
    #    err_msg = 'ERROR: diagUtilsLib.checkXMLyears requested XML YEAR0 = {0} does not fall within range of actual available model history file years: {1}-{2}'.format(rstart_year, hfstart_year, hfstop_year)
    #    raise OSError(err_msg)
#
#    if not int(hfstart_year) <= int(rstop_year) <= int(hfstop_year):
#        err_msg = 'ERROR: diagUtilsLib.checkXMLyears requested XML YEAR1 = {0} does not fall within range of actual available model history file years: {1}-{2}'.format(rstop_year, hfstart_year, hfstop_year)
#        raise OSError(err_msg)

#    if int(rstop_year) < int(rstart_year):
#        err_msg = 'ERROR: diagUtilsLib.checkXMLyears requested XML YEAR1 = {0} is less than YEAR0 = {1}'.format(rstop_year, rstart_year)
#        raise OSError(err_msg)

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
    tseries (boolean) - corresponds to XML variable GENERATE_TIMESERIES
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
    fformat = '{0}/{1}*'.format(in_dir, files)
   
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

        if not check_series_years(hfstart_year, hfstart_month, hfstop_year, hfstop_month, hfiles[0]):
            err_msg = 'ERROR: diagUtilsLib.checkHistoryFiles Time series filename does not match file time slice count.'
            raise OSError(err_msg)

    # check if the XML YEAR0 and YEAR1 are within the actual start_year and stop_year bounds 
    # defined by the actual history files
    start_year, stop_year = checkXMLyears(hfstart_year, hfstop_year, rstart_year, rstop_year)

    return (start_year, stop_year, in_dir, htype, hfiles[0])


#=======================================================================
# copy_html_files - scp files from workdir to remote directory 
#=======================================================================
def copy_html_files(env, subdir):
    """ copy html files from workdir to remote dir.
        Will prompt user if ssh keys are not set.

    Arguments:
    env (dictionary) - environment dictionary
    subdir (sting) - sub-directory
    """
    # check if ssh key is set for passwordless access to the web host
    sshkey = True
    try:
        output = subprocess.check_output( "ssh -oNumberOfPasswordPrompts=0 {0}@{1} 'echo hello'".format(env['WEBLOGIN'],env['WEBHOST']), 
                                 stderr=subprocess.STDOUT,
                                 shell=True)
    except subprocess.CalledProcessError as e:
        print('WARNING: unable to connect to remote web host {0}@{1} without a password'.format(env['WEBLOGIN'],env['WEBHOST']))
        print('    You will need to copy the files in {0} manually to a web server.'.format(env['WORKDIR']))
        print('    {0} - {1}'.format(e.returncode, e.output))
        sshkey = False

    if sshkey:
        toplevel = False
        if len(subdir) == 0:
            toplevel = True
            subdir = '{0}.{1}-{2}'.format(env['CASE'], env['YEAR0'], env['YEAR1'])
        else:
            subdir = '{0}.{1}-{2}/{3}'.format(env['CASE'], env['YEAR0'], env['YEAR1'], subdir)
        remoteConnect = '{0}@{1}:{2}/{3}'.format(env['WEBLOGIN'], env['WEBHOST'], env['WEBDIR'], subdir)
        print('Secure copying HTML and graphics files from {0} to {1}'.format(env['WORKDIR'], remoteConnect))

        # make sure directory exists
        try:
            pipe = subprocess.Popen( ["ssh {0}@{1} 'mkdir -p {2}/{3}'".format(env['WEBLOGIN'],env['WEBHOST'],env['WEBDIR'],subdir)], env=env, shell=True)
            pipe.wait()
        except OSEerror as e:
            print('WARNING: unable to create remote directory {0}/{1}'.format(env['WEBDIR'],subdir))
            print('    {0} - {1}'.format(e.errno, e.strerror))
            sshkey = False

    if sshkey and toplevel:

        # copy the logos and style sheet to the top level
        localFiles = '{0}/logos'.format(env['WORKDIR'])
        try:
            pipe = subprocess.Popen( ['scp -r {0} {1}'.format(localFiles, remoteConnect)], env=env, shell=True)
            pipe.wait()
        except OSError as e:
            print('WARNING: scp command failed with error::')
            print('    {0} - {1}'.format(e.errno, e.strerror))

        localFiles = '{0}/*.css'.format(env['WORKDIR'])
        try:
            pipe = subprocess.Popen( ['scp -r {0} {1}'.format(localFiles, remoteConnect)], env=env, shell=True)
            pipe.wait()
        except OSError as e:
            print('WARNING: scp command failed with error::')
            print('    {0} - {1}'.format(e.errno, e.strerror))

    if sshkey:

        # copy the html files
        localFiles = '{0}/*.html'.format(env['WORKDIR'])
        try:
            pipe = subprocess.Popen( ['scp -r {0} {1}'.format(localFiles, remoteConnect)], env=env, shell=True)
            pipe.wait()
        except OSError as e:
            print('WARNING: scp command failed with error::')
            print('    {0} - {1}'.format(e.errno, e.strerror))

        # copy the graphics files
        localFiles = '{0}/*.{1}'.format(env['WORKDIR'], env['IMAGEFORMAT'])
        try:
            pipe = subprocess.Popen( ['scp -r {0} {1}'.format(localFiles, remoteConnect)], env=env, shell=True)
            pipe.wait()
        except OSError as e:
            print('WARNING: scp command failed with error::')
            print('    {0} - {1}'.format(e.errno, e.strerror))

        # copy the asc files
        localFiles = '{0}/*.asc'.format(env['WORKDIR'])
        try:
            pipe = subprocess.Popen( ['scp -r {0} {1}'.format(localFiles, remoteConnect)], env=env, shell=True)
            pipe.wait()
        except OSError as e:
            print('WARNING: scp command failed with error::')
            print('    {0} - {1}'.format(e.errno, e.strerror))


#==============================================================================
# create_za - generate the ocean global zonal average file used for most of the plots
#==============================================================================
def create_za(workdir, tavgfile, gridfile, toolpath, env):
    """generate the global zonal average file used for most of the plots
    """
    # generate the global zonal average file used for most of the plots
    zaFile = '{0}/za_{1}'.format(workdir, tavgfile)
    rc, err_msg = cesmEnvLib.checkFile(zaFile, 'read')
    if not rc:
        # check that the za executable exists
        zaCommand = '{0}/za'.format(toolpath)
        rc, err_msg = cesmEnvLib.checkFile(zaCommand, 'exec')
        if not rc:
            print('ERROR: create_za failed to verify executable za command = {0}'.format(zaCommand))
            print('    {0}'.format(err_msg))
            sys.exit(1)
        
        # call the za fortran code from within the workdir
        cwd = os.getcwd()
        os.chdir(workdir)
        testCmd = '{0} -O -time_const -grid_file {1} {2}'.format(zaCommand,gridfile,tavgfile)
        print('zonal average command = {0}'.format(testCmd))
        try:
            subprocess.check_call(['{0}'.format(zaCommand), '-O', '-time_const', '-grid_file', '{0}'.format(gridfile), '{0}'.format(tavgfile)])
        except subprocess.CalledProcessError as e:
            print('ERROR: create_za subprocess call to {1} failed with error:'.format(e.cmd))
            print('    {0} - {1}'.format(e.returncode, e.output))
            sys.exit(1)

        print('zonal average created')
        os.chdir(cwd)



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
def createLinks(start_year, stop_year, tavgdir, workdir, case, control):
    """createLinks - create symbolic links between tavgdir and workdir

    Arguments:
    start_year (string) - starting year
    stop_year (string) - ending year
    tavgdir (string) - output directory for averages
    workdir (string) - working directory for diagnostics
    case (string) - case name
    control (boolean) - indicates if this is a control run or not which will change the mavg and tavg filenames
    """
    padding = 4
    avgFileBaseName = '{0}/{1}.pop.h'.format(tavgdir,case)
    case_prefix = '{0}.pop.h'.format(case)

    # prepend the years with 0's for some of the plotting routines
    zstart_year = start_year.zfill(padding)
    zstop_year = stop_year.zfill(padding)

    # check if this is a control run or not
    cntrl = ''
    if control:
        cntrl = 'cntrl.'

    # link to the mavg file for the za and plotting routines
    mavgFileBase = 'mavg.{0}.{1}.{2}nc'.format(zstart_year, zstop_year, cntrl)
    avgFile = '{0}/mavg.{1}-{2}.nc'.format(tavgdir, zstart_year, zstop_year)
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if rc:
        zmavgFile = '{0}/mavg.{1}.{2}.{3}nc'.format(workdir, zstart_year, zstop_year, cntrl)
        mavgFile = '{0}/mavg.{1}.{2}.{3}nc'.format(workdir, start_year, stop_year, cntrl)

        rc1, err_msg1 = cesmEnvLib.checkFile(zmavgFile, 'read')
        if not rc1:
            os.symlink(avgFile, zmavgFile)

        rc1, err_msg1 = cesmEnvLib.checkFile(mavgFile, 'read')
        if not rc1:
            os.symlink(avgFile, mavgFile)
    else:
        raise OSError(err_msg)

    # link to the tavg file
    tavgFileBase = 'tavg.{0}.{1}.{2}nc'.format(zstart_year, zstop_year, cntrl)
    avgFile = '{0}/tavg.{1}-{2}.nc'.format(tavgdir, zstart_year, zstop_year)
    rc, err_msg = cesmEnvLib.checkFile(avgFile, 'read')
    if rc:
        ztavgFile = '{0}/tavg.{1}.{2}.{3}nc'.format(workdir, zstart_year, zstop_year, cntrl)
        tavgFile = '{0}/tavg.{1}.{2}.{3}nc'.format(workdir, start_year, stop_year, cntrl)

        rc1, err_msg1 = cesmEnvLib.checkFile(ztavgFile, 'read')
        if not rc1:
            os.symlink(avgFile, ztavgFile)

        rc1, err_msg1 = cesmEnvLib.checkFile(tavgFile, 'read')
        if not rc1:
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
                os.symlink(avgFile, workAvgFile)
        year += 1

    return mavgFileBase, tavgFileBase

#======================================================================
# create a single symbolic link to a given file checking the file first
#======================================================================
def createSymLink(sourceFile, linkFile):
    """ create a symbolic link between the sourceFile and the linkFile
    """
    # check if the sourceFile exists
    rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
    if not rc:
# these should be raise RuntimeError instead of OSError
        raise RuntimeError(err_msg)

    # check if the linkFile exists and is readable
    rc, err_msg = cesmEnvLib.checkFile(linkFile, 'read')
    if not rc:
        try:
            os.symlink(sourceFile, linkFile)
        except Exception as e:
            print('...createSymLink error = {0}'.format(e))
            raise OSError(e)
    return

#================================================================
# TODO checkAvgFiles - check that the climotology average files exist
#================================================================
def checkAvgFiles(filelist):
    """ check if the climatology files exist in the list of files passed in
    """
    rc = True
    return rc

#======================================================================
# Function to regrid the atm climatology files
#======================================================================
def atm_regrid(climo_file, regrid_script, in_grid, out_grid, env):
    """ Regrid the climatology file that was passed in
    """
    if '30' in in_grid:
       in_grid = '30'
    elif '120' in in_grid:
       in_grid = '120'
    elif '240' in in_grid:
       in_grid = '240'
    else:
        raise RuntimeError('The in grid resolution is not a valid option: ',in_grid)

    se_file = climo_file[:-3] + '_r_' + in_grid + climo_file[-3:] # Create a new name for the existing se climo file
    env['INGRID'] = in_grid
    env['OUTGRID'] = out_grid

    # Move the existing file to a new name
    shutil.move(climo_file, se_file)    
 
    env['TEST_INPUT'] = se_file
    env['TEST_PLOTVARS'] = climo_file

    # Stringify the env dictionary
    env_copy = env.copy()
    for name,value in env_copy.iteritems():
        env_copy[name] = str(value)

    # Call ncl to regrid the climo file
    generate_ncl_plots(env_copy,regrid_script)


#======================================================================
# Function to regrid the lnd climatology files
#======================================================================
def lnd_regrid(climo_file, regrid_script, t, outdir, env):
    """ Regrid the climatology file that was passed in
    """
    env['method']   = env['method_'+t]
    env['wgt_dir']  = env['wgt_dir_'+t]
    env['wgt_file'] = env['old_res_'+t]+'_to_'+env['new_res_'+t]+'.'+env['method_'+t]+'.nc'
    env['area_dir'] = env['area_dir_'+t]
    env['area_file']= env['new_res_'+t]+'_area.nc' 
    env['procDir']  = outdir
    env['oldres']   = env['old_res_'+t]
    env['InFile']   = os.path.basename(climo_file)
    env['OutFile']  = env['new_res_'+t]+'_'+os.path.basename(climo_file)
    env['newfn']    = env['old_res_'+t]+'_'+os.path.basename(climo_file)
     
    # Stringify the env dictionary
    env_copy = env.copy()
    for name,value in env_copy.iteritems():
        env_copy[name] = str(value)

    # Call ncl to regrid the climo file
    generate_ncl_plots(env_copy,regrid_script)
    in_f = os.path.basename(climo_file)
    os.rename(outdir+'/'+in_f, outdir+'/'+env['oldres']+in_f)
    os.rename(outdir+'/'+env['OutFile'], outdir+'/'+in_f)


