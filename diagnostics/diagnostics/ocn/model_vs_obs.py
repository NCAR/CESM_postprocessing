from __future__ import print_function

import sys

if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

import traceback
import os

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the diag baseclass module
from ocn_diags_bc import OceanDiagnostic

class modelVsObs(OceanDiagnostic):
    """model vs. observations ocean diagnostics setup
    """
    def __init__(self):
        super(modelVsObs, self).__init__()

        self._name = 'Model vs. Observations'

    def check_prerequisties(self, env, debugMsg):
        super(modelVsObs, self).check_prerequisites(env)
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))

        # create the working directory if it doesn't already exists
        subdir = 'model_vs_obs.{0}_{1}'.format(env['YEAR0'], env['YEAR1'])
        workdir = '{0}/{1}'.format(env['WORKDIR'], subdir)
        debugMsg('workdir = {0}'.format(workdir), header=True)

        try:
            os.makedirs(workdir)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                err_msg = 'ERROR: {0} problem accessing the working directory {1}'.format(self.__class__.__name__),workdir)
            raise OSError(err_msg)

#start here...
    env['WORKDIR'] = workdir

    # clean out the old working plot files from the workdir
    if env['CLEANUP_FILES'].upper() in ['T','TRUE']:
        cesmEnvLib.purge(workdir, '.*\.pro')
        cesmEnvLib.purge(workdir, '.*\.gif')
        cesmEnvLib.purge(workdir, '.*\.dat')
        cesmEnvLib.purge(workdir, '.*\.ps')
        cesmEnvLib.purge(workdir, '.*\.png')
        cesmEnvLib.purge(workdir, '.*\.html')

    # create the plot.dat file in the workdir used by all NCL plotting routines
    create_plot_dat(env['WORKDIR'], env['XYRANGE'], env['DEPTHS'])

    # create symbolic links between the tavgdir and the workdir and get the real names of the mavg and tavg files
    env['MAVGFILE'], env['TAVGFILE'] = createLinks(env['YEAR0'], env['YEAR1'], env['TAVGDIR'], env['WORKDIR'], env['CASE'], debugMsg)

    # setup the gridfile based on the resolution
    os.environ['gridfile'] = '{0}/tool_lib/zon_avg/grids/{1}_grid_info.nc'.format(env['DIAGROOTPATH'],env['RESOLUTION'])
    if env['VERTICAL'] == '42':
        os.environ['gridfile'] = '{0}/tool_lib/zon_avg/grids/{1}_42lev_grid_info.nc'.format(env['DIAGROOTPATH'],env['RESOLUTION'])

    # check if gridfile exists and is readable
    rc, err_msg = cesmEnvLib.checkFile(os.environ['gridfile'], 'read')
    if not rc:
        raise OSError(err_msg)

    env['GRIDFILE'] = os.environ['gridfile']

    # check the resolution and decide if some plot modules should be turned off
    if env['RESOLUTION'] == 'tx0.1v2' :
        env['PM_VELISOPZ'] = os.environ['PM_VELISOPZ'] = 'FALSE'
        env['PM_KAPPAZ'] = os.environ['PM_KAPPAZ'] = 'FALSE'

    # create the global zonal average file used by most of the plotting classes
    debugMsg('calling create_za', header=True)
    create_za( env['WORKDIR'], env['TAVGFILE'], env['GRIDFILE'], env['TOOLPATH'], env, debugMsg )

    debugMsg('calling setup_obs', header=True)
    setup_obs(env, debugMsg)

    # setup of ecosys files
    if env['MODEL_VS_OBS_ECOSYS'].upper() in ['T','TRUE'] :
        # setup some ecosys environment settings
        os.environ['POPDIR'] = 'TRUE'
        os.environ['PME'] = '1'
        sys.path.append(env['ECOPATH'])

        # check if extract_zavg exists and is executable
        rc, err_msg = cesmEnvLib.checkFile(env['{0}/extract_zavg.sh'.format(env['ECOPATH'])],'exec')
        if not rc:
            raise OSError(err_msg)

        # call the ecosystem zonal average extraction modules
        zavg_command = '{0}/extract_zavg.sh {1} {2} {3} {4}'.format(env['ECOPATH'],env['CASE'],str(start_year),str(stop_year),ecoSysVars)
        rc = os.system(zavg_command)
        if rc:
            err_msg = 'ERROR: ocn_diags_generator.py command {0} failed.'.format(zavg_command)
            raise OSError(err_msg)
 
    return env


#==============================================================================
# create_za - generate the global zonal average file used for most of the plots
#==============================================================================
def create_za(workdir, tavgfile, gridfile, toolpath, env, debugMsg):
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
            raise OSError(err_msg)
        
        # call the za fortran code from within the workdir
        cwd = os.getcwd()
        os.chdir(workdir)
        testCmd = '{0} -O -time_const -grid_file {1} {2}'.format(zaCommand,gridfile,tavgfile)
        debugMsg('zonal average command = {0}'.format(testCmd), header=True)
        try:
            subprocess.check_call(['{0}'.format(zaCommand), '-O', '-time_const', '-grid_file', '{0}'.format(gridfile), '{0}'.format(tavgfile)])
        except CalledProcessError as e:
            print('ERROR: {0} subprocess call to {1} failed with error:'.format(self.name(), e.cmd))
            print('    {0} - {1}'.format(e.returncode, e.output))
            sys.exit(1)

        debugMsg('zonal average created', header=True)
        os.chdir(cwd)

    return True
