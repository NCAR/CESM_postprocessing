from __future__ import print_function

import sys

if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

# import core python modules
import datetime
import errno
import glob
import itertools
import os
import re
import shutil
import traceback
import subprocess

try:
    import lxml.etree as etree
except:
    import xml.etree.ElementTree as etree

# import modules installed by pip into virtualenv
import jinja2

# import the helper utility module
from cesm_utils import cesmEnvLib, processXmlLib
from diag_utils import diagUtilsLib

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# import the diag baseclass module
from lnd_diags_bc import LandDiagnostic

# import the plot classes
from diagnostics.lnd.Plots import lnd_diags_plot_bc
from diagnostics.lnd.Plots import lnd_diags_plot_factory

class modelVsObs(LandDiagnostic):
    """model vs. observations land diagnostics setup
    """
    def __init__(self):
        """ initialize
        """
        super(modelVsObs, self).__init__()

        self._name = 'MODEL_VS_OBS'
        self._title = 'Model vs. Observations'

    def check_prerequisites(self, env, scomm):
        """ check prerequisites
        """
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))
        super(modelVsObs, self).check_prerequisites(env, scomm)

        # Set some new env variables
        env['WKDIR'] =  env['DIAG_BASE']+'/diag/'+env['caseid_1']+'-obs/'
        env['WORKDIR'] = env['WKDIR']
        if scomm.is_manager():
            if not os.path.exists(env['WKDIR']):
                os.makedirs(env['WKDIR'])
        env['PLOTTYPE']       = env['p_type']
        env['OBS_DATA']       = env['OBS_HOME']
        env['INPUT_FILES']    = env['POSTPROCESS_PATH']+'/lnd_diag/inputFiles/'
        env['DIAG_RESOURCES'] = env['DIAGOBSROOT']+'/resources/'
        env['RUNTYPE'] = 'model-obs'

        # Create variable files
        if scomm.is_manager():
            script = env['DIAG_SHARED']+'/create_var_lists.csh'
            rc1, err_msg = cesmEnvLib.checkFile(script,'read')
            if rc1:
                try:
                    pipe = subprocess.Popen([script], cwd=env['WORKDIR'], env=env, shell=True, stdout=subprocess.PIPE)
                    output = pipe.communicate()[0]
                    print(output)
                    while pipe.poll() is None:
                        time.sleep(0.5)
                except OSError as e:
                    print('WARNING',e.errno,e.strerror)
            else:
                print('{0}... {1} file not found'.format(err_msg,script))

        scomm.sync()
        return env

    def run_diagnostics(self, env, scomm):
        """ call the necessary plotting routines to generate diagnostics plots
        """
        super(modelVsObs, self).run_diagnostics(env, scomm)
        scomm.sync()

        # setup some global variables
        requested_plot_sets = list()
        local_requested_plots = list()
        local_html_list = list()

        # all the plot module XML vars start with 'set_' 
        for key, value in env.iteritems():
            if ("set_" in key and value == 'True'):
                requested_plot_sets.append(key)
        scomm.sync()

        if scomm.is_manager():
            print('DEBUG model_vs_obs requested_plot_sets = {0}'.format(requested_plot_sets))

        # partition requested plots to all tasks
        # first, create plotting classes and get the number of plots each will created 
        requested_plots = {}
        set_sizes = {}
        #plots_weights = []
        for plot_set in requested_plot_sets:
            requested_plots.update(lnd_diags_plot_factory.LandDiagnosticPlotFactory(plot_set,env))

        #for plot_id,plot_class in requested_plots.iteritems():
        #    if hasattr(plot_class, 'weight'):
        #        factor = plot_class.weight
        #    else:
        #        factor = 1
        #    plots_weights.append((plot_id,len(plot_class.expectedPlots)*factor))
        # partition based on the number of plots each set will create
        #local_plot_list = scomm.partition(plots_weights, func=partition.WeightBalanced(), involved=True)  

        local_plot_list = scomm.partition(requested_plots.keys(), func=partition.EqualStride(), involved=True)
        scomm.sync()

        timer = timekeeper.TimeKeeper()
        # loop over local plot lists - set env and then run plotting script         
        timer.start(str(scomm.get_rank())+"ncl total time on task")

        for plot_set in local_plot_list:
            timer.start(str(scomm.get_rank())+plot_set)
            plot_class = requested_plots[plot_set]

            print('DEBUG model vs. obs - Checking prerequisite for {0} on rank {1}'.format(plot_class.__class__.__name__, scomm.get_rank()))
            plot_class.check_prerequisites(env)

            # Stringify the env dictionary
            for name, value in plot_class.plot_env.iteritems():
                plot_class.plot_env[name] = str(value)

            # call script to create plots
            for script in plot_class.ncl_scripts:
                print('DEBUG model vs. obs - Generating plots for {0} on rank {1} with script {2}'.format(plot_class.__class__.__name__, scomm.get_rank(),script))
                diagUtilsLib.generate_ncl_plots(plot_class.plot_env, script)

            timer.stop(str(scomm.get_rank())+plot_set)
        timer.stop(str(scomm.get_rank())+"ncl total time on task") 

        scomm.sync()
        print(timer.get_all_times())
        #w = 0
        #for p in plots_weights:
        #    if p[0] in local_plot_list:
        #        w = w + p[1]
        #print(str(scomm.get_rank())+' weight:'+str(w))

        # set html files
        if scomm.is_manager():

            # Create web dirs and move images/tables to that web dir
            for n in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'):
                web_dir = env['WKDIR'] 
                set_dir = web_dir + '/set' + n
                # Create the plot set web directory
                if not os.path.exists(set_dir):
                    os.makedirs(set_dir)
                # Copy plots into the correct web dir
                glob_string = web_dir+'/set'+n+'_*'
                imgs = glob.glob(glob_string)
                if len(imgs) > 0:
                    for img in imgs:
                        new_fn = set_dir + '/' + os.path.basename(img)
                        os.rename(img,new_fn)
            env['WEB_DIR'] = web_dir
            shutil.copy2(env['POSTPROCESS_PATH']+'/lnd_diag/inputFiles/'+env['VAR_MASTER'],web_dir+'/variable_master.ncl')
            web_script_1 = env['POSTPROCESS_PATH']+'/lnd_diag/shared/lnd_create_webpage.pl'
            web_script_2 = env['POSTPROCESS_PATH']+'/lnd_diag/shared/lnd_lookupTable.pl'

            print('Creating Web Pages')

            # set the shell environment
            cesmEnvLib.setXmlEnv(env)

            # lnd_create_webpage.pl call
            rc1, err_msg = cesmEnvLib.checkFile(web_script_1,'read')
            if rc1:
                try:
                    subprocess.check_call(web_script_1)
                except subprocess.CalledProcessError as e:
                    print('WARNING: {0} error executing command:'.format(web_script_1))
                    print('    {0}'.format(e.cmd))
                    print('    rc = {0}'.format(e.returncode))
            else:
                print('{0}... {1} file not found'.format(err_msg,web_script_1))

            # lnd_lookupTable.pl call          
            rc2, err_msg = cesmEnvLib.checkFile(web_script_2,'read')
            if rc2:
                try:
                    subprocess.check_call(web_script_2)
                except subprocess.CalledProcessError as e:
                    print('WARNING: {0} error executing command:'.format(web_script_2))
                    print('    {0}'.format(e.cmd))
                    print('    rc = {0}'.format(e.returncode))
            else:
                print('{0}... {1} file not found'.format(err_msg,web_script_2))

            # move all the plots to the diag_path with the years appended to the path
            endYr = (int(env['clim_first_yr_1']) + int(env['clim_num_yrs_1'])) - 1  
            diag_path = '{0}/diag/{1}-obs.{2}_{3}'.format(env['OUTPUT_ROOT_PATH'], env['caseid_1'],
                                                      env['clim_first_yr_1'], str(endYr))
            move_files = True
            try:
                os.makedirs(diag_path)
            except OSError as exception:
                if exception.errno != errno.EEXIST:
                    err_msg = 'ERROR: {0} problem accessing directory {1}'.format(self.__class__.__name__, diag_path)
                    raise OSError(err_msg)
                    move_files = False

                elif env['CLEANUP_FILES'].lower() in ['t','true']:
                    # delete all the files in the diag_path directory
                    for root, dirs, files in os.walk(diag_path):
                        for f in files:
                            os.unlink(os.path.join(root, f))
                        for d in dirs:
                            shutil.rmtree(os.path.join(root, d))

                elif env['CLEANUP_FILES'].lower() in ['f','false']:
                    print('WARNING: {0} exists and is not empty and LNDDIAG_CLEANUP_FILES = False. Leaving new diagnostics files in {1}'.format(diag_path, web_dir))
                    diag_path = web_dir
                    move_files = False

            print('DEBUG: model vs. obs web_dir = {0}'.format(web_dir))
            print('DEBUG: model vs. obs diag_path = {0}'.format(diag_path))

            # move the files to the new diag_path 
            if move_files:
                try:
                    print('DEBUG: model_vs_obs renaming web files')
                    os.rename(web_dir, diag_path)
                except OSError as e:
                    print ('WARNING: Error renaming %s to %s: %s' % (web_dir, diag_path, e))
                    diag_path = web_dir

            # setup the LNDDIAG_WEBDIR_MODEL_VS_OBS output file
            env_file = '{0}/env_diags_lnd.xml'.format(env['PP_CASE_PATH'])
            key = 'LNDDIAG_WEBDIR_{0}'.format(self._name)
            value = diag_path
            web_file = '{0}/web_dirs/{1}.{2}'.format(env['PP_CASE_PATH'], key, datetime.datetime.now().strftime('%Y-%m-%d_%H%M%S'))
            try:
                diagUtilsLib.write_web_file(web_file, 'lnd', key, value)
            except:
                print('WARNING lnd model_vs_obs unable to write {0}={1} to {2}'.format(key, value, web_file))

            print('*******************************************************************************')
            print('Successfully completed generating land diagnostics model vs. observation plots')
            print('*******************************************************************************')

