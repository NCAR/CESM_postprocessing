import os
import re
import subprocess

#==============================================
# checkEnv - check if a XML env var is defined
#==============================================
def checkEnv(varname, relpath):
    """checkEnv - check if an env var is defined
    and if not, try to retrieve it from the casedir xmlquery 

    @param varname env var name to check

    @param relpath relative path to the casedir xmlquery 
    """
    if not os.environ.get(varname) :
        cwd = os.getcwd()
        os.chdir(relpath)
        command = 'xmlquery -valonly {0}'.format(varname)
        output = os.popen(command).read()
        xmllist = output.split(' ')
        os.environ[varname] = (xmllist.pop()).rstrip('\n')
        if not os.path.isdir(os.environ[varname]) :
            err_msg = 'diags_generator.py ERROR: {0} enviroment variable does not point to a valid directory.'.format(varname)
            raise OSError(err_msg)
        os.chdir(cwd)

    return True


#=======================================================
# checkFile - check if a file exists and mode is allowed
#=======================================================
def checkFile(filename, mode):
    """checkFile - check if a file exists and if it is readable
    
    Arguments:
    filename (string) - input full path filename
    mode (string) - checks for access mode - valid values are read, write, exec
    
    Returns:
    rc - return True if file exists and is accessible by mode
         return False if file does not exist or is not accessible by mode
    err_msg (string) - error message
    """
    modedict = {'read':os.R_OK, 'write':os.W_OK, 'exec':os.X_OK}
    rc = True
    err_msg = ''
    if not os.path.isfile(filename):
        rc = False
        err_msg = 'ocn_diags_generator.py ERROR: {0} file is not available.'.format(filename)
    elif not os.access(filename, modedict[mode] ):
        rc = False
        err_msg = 'ocn_diags_generator.py ERROR: {0} file does not allow mode {1}.'.format(filename,mode)

    return (rc, err_msg)


#==========================================
# purge - delete files that match a pattern
#==========================================
def purge(dir, pattern):
    """purge - Remove files that match RE pattern in dir

    Arguments:
    dir (string) - directory name to work in
    pattern (string) - RE file pattern to delete from dir
    """
    for f in os.listdir(dir) :
        if re.search(pattern, f) :
            os.remove(os.path.join(dir, f))
    return


#===========================================
# which - check if a file is in the sys.path
#===========================================   
def which(program):
    import os
    def is_exe(fpath):
        return os.path.isfile(fpath) and os.access(fpath, os.X_OK)

    fpath, fname = os.path.split(program)
    if fpath:
        if is_exe(program):
            return program
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            path = path.strip('"')
            exe_file = os.path.join(path, program)
            if is_exe(exe_file):
                return exe_file

    return None


#============================================================
# generate_ncl_plots - call a nclPlotFile via subprocess call
#============================================================
def generate_ncl_plots(env, nclPlotFile):
    """generate_plots_call - call a nclPlotFile via subprocess call

    Arguments:
    env (dictionary) - diagnostics system environment 
    nclPlotFile (string) - ncl plotting file name
    """
    cwd = os.getcwd()
    os.chdir(env['WORKDIR'])

    # check if the nclPlotFile exists - 
    # don't exit if it does not exists just print a warning.
    nclFile = '{0}/{1}'.format(env['NCLPATH'],nclPlotFile)
    rc, err_msg = checkFile(nclFile, 'read')
    if rc:
        try:
            print('      calling NCL plot routine {0}'.format(nclPlotFile))
            subprocess.check_output( ['ncl',nclFile], env=env)
        except subprocess.CalledProcessError as e:
            print('WARNING: {0} call to {1} failed with error:'.format(self.name(), nclfile))
            print('    {0} - {1}'.format(e.cmd, e.output))
    else:
        print('{0}... continuing with additional plots.'.format(err_msg))
    os.chdir(cwd)

    return 0
