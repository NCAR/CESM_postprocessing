from __future__ import print_function

import sys

if sys.hexversion < 0x03070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 3.7.x. ".format(sys.argv[0]))
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

try:
    import lxml.etree as etree
except:
    import xml.etree.ElementTree as etree

# import modules installed into virtualenv
from cesm_utils import cesmEnvLib, processXmlLib
from diag_utils import diagUtilsLib
from . import create_atm_html

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# import the diag baseclass module
from .atm_diags_bc import AtmosphereDiagnostic

# import the plot classes
from diagnostics.atm.Plots import atm_diags_plot_bc
from diagnostics.atm.Plots import atm_diags_plot_factory

class modelVsObs(AtmosphereDiagnostic):
    """model vs. observations atmosphere diagnostics setup
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
        env['DIAG_CODE'] = env['NCLPATH']
        env['test_path_diag'] = '{0}/{1}-{2}/'.format(env['test_path_diag'], env['test_casename'], 'obs')
        env['WKDIR'] = env['test_path_diag']
        env['WORKDIR'] = env['test_path_diag']
        if scomm.is_manager():
            if not os.path.exists(env['WKDIR']):
                os.makedirs(env['WKDIR'])
        env['COMPARE'] = env['CNTL']
        env['PLOTTYPE'] = env['p_type']
        env['COLORTYPE'] = env['c_type']
        env['MG_MICRO'] = env['microph']
        env['TIMESTAMP'] = env['time_stamp']
        env['TICKMARKS'] = env['tick_marks']
        if env['custom_names'] == 'True':
            env['CASENAMES'] = 'True'
            env['CASE1'] = env['test_name']
            env['CASE2'] = env['cntl_name']
        else:
            env['CASENAMES'] = 'False'
            env['CASE1'] = 'null'
            env['CASE2'] = 'null'
            env['CNTL_PLOTVARS'] = 'null'
        env['test_in'] = env['test_path_climo'] + env['test_casename']
        env['test_out'] = env['test_path_climo'] + env['test_casename']
        env['cntl_in'] = env['OBS_DATA']

        env['seas'] = []
        if env['plot_ANN_climo'] == 'True':
            env['seas'].append('ANN')
        if env['plot_DJF_climo'] == 'True':
            env['seas'].append('DJF')
        if env['plot_MAM_climo'] == 'True':
            env['seas'].append('MAM')
        if env['plot_JJA_climo'] == 'True':
            env['seas'].append('JJA')
        if env['plot_SON_climo'] == 'True':
            env['seas'].append('SON')

        # Significance vars
        if env['significance'] == 'True':
            env['SIG_PLOT'] = 'True'
            env['SIG_LVL'] = env['sig_lvl']
        else:
            env['SIG_PLOT'] = 'False'
            env['SIG_LVL'] = 'null'

        # Set the rgb file name
        env['RGB_FILE'] = env['DIAG_HOME']+'/rgb/amwg.rgb'
        if 'default' in env['color_bar']:
            env['RGB_FILE'] = env['DIAG_HOME']+'/rgb/amwg.rgb'
        elif 'blue_red' in env['color_bar']:
            env['RGB_FILE'] = env['DIAG_HOME']+'/rgb/bluered.rgb'
        elif 'blue_yellow_red' in env['color_bar']:
            env['RGB_FILE'] = env['DIAG_HOME']+'/rgb/blueyellowred.rgb'


        # Set Paleo variables and create paleo coastline files
        env['PALEO'] = env['paleo']
        if env['PALEO'] == 'True':
            env['DIFF_PLOTS'] = env['diff_plots']
            env['MODELFILE'] = env['test_path_climo']+'/'+env['test_casename']+'_ANN_climo.nc'
            env['LANDMASK'] = env['land_mask1']
            env['PALEODATA'] = env['test_path_climo']+'/'+env['test_casename']
            if scomm.is_manager():
                rc, err_msg = cesmEnvLib.checkFile(env['PALEODATA'],'read')
                if not rc:
                    diagUtilsLib.generate_ncl_plots(env,'plot_paleo.ncl')
            env['PALEOCOAST1'] = env['PALEODATA']
            env['PALEOCOAST2'] = 'null'
        else:
            env['PALEOCOAST1'] = 'null'
            env['PALEOCOAST2'] = 'null'
            env['DIFF_PLOTS'] = 'False'

        env['USE_WACCM_LEVS'] = 'False'

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

        # define the templatePath for all tasks
        templatePath = '{0}/diagnostics/diagnostics/atm/Templates'.format(env['POSTPROCESS_PATH'])

        # all the plot module XML vars start with 'set_'  need to strip that off
        for key, value in env.items():
            if   ("wset_"in key and (value == 'True' or env['all_waccm_sets'] == 'True')):
                requested_plot_sets.append(key)
            elif ("cset_"in key and (value == 'True' or env['all_chem_sets'] == 'True')):
                requested_plot_sets.append(key)
            elif ("set_" in key and (value == 'True' or env['all_sets'] == 'True')):
                if ("wset_" not in key and "cset_" not in key):
                    requested_plot_sets.append(key)
        scomm.sync()

        # partition requested plots to all tasks
        # first, create plotting classes and get the number of plots each will created
        requested_plots = {}
        set_sizes = {}
        plots_weights = []
        for plot_set in requested_plot_sets:
            requested_plots.update(atm_diags_plot_factory.atmosphereDiagnosticPlotFactory(plot_set,env))
        for plot_id,plot_class in requested_plots.items():
            if hasattr(plot_class, 'weight'):
                factor = plot_class.weight
            else:
                factor = 1
            plots_weights.append((plot_id,len(plot_class.expectedPlots)*factor))
        # partition based on the number of plots each set will create

#        local_plot_list = scomm.partition(plots_weights, func=partition.WeightBalanced(), involved=True)
#        print("plots_weights {} requested_plots {} local_plot_list {}".format(plots_weights,requested_plots, local_plot_list))
        requested_plots_list = list(requested_plots.keys())
        local_plot_list = scomm.partition(requested_plots_list, func=partition.EqualStride(), involved=True)
        scomm.sync()
#        print("requested_plots {} local_plot_list {}".format(requested_plots, local_plot_list))


        timer = timekeeper.TimeKeeper()
        # loop over local plot lists - set env and then run plotting script
        #for plot_id,plot_class in local_plot_list.interitems():
        timer.start(str(scomm.get_rank())+"ncl total time on task")
        for plot_set in local_plot_list:
            timer.start(str(scomm.get_rank())+plot_set)
            plot_class = requested_plots[plot_set]
            # set all env variables (global and particular to this plot call
            plot_class.check_prerequisites(env)
            # Stringify the env dictionary
            for name,value in plot_class.plot_env.items():
                plot_class.plot_env[name] = str(value)
            # call script to create plots
            for script in plot_class.ncl_scripts:
                 diagUtilsLib.generate_ncl_plots(plot_class.plot_env,script)
                 plot_class.plot_env['NCDF_MODE'] = 'write'
                 plot_class.plot_env['VAR_MODE'] = 'write'
            timer.stop(str(scomm.get_rank())+plot_set)
        timer.stop(str(scomm.get_rank())+"ncl total time on task")

        scomm.sync()
        print(timer.get_all_times())
        w = 0
        for p in plots_weights:
            if p[0] in local_plot_list:
                w = w + p[1]
        print(str(scomm.get_rank())+' weight:'+str(w))

        # set html files
        if scomm.is_manager():
            env['HTML_HOME'] = env['DIAG_HOME']+'/html/model-obs/'
            # Get web dir name and create it if it does not exist
            #web_dir = '{0}/{1}-{2}'.format(env['test_path_diag'], env['test_casename'], 'obs')
            web_dir = env['test_path_diag']
            #if not os.path.exists(web_dir):
            #    os.makedirs(web_dir)
            # Copy over some files needed by web pages
            if not os.path.exists(web_dir+'/images'):
                os.mkdir(web_dir+'/images')

            for img in glob.iglob(env['DIAG_HOME']+'/html/images/*'):
                shutil.copy(img,web_dir+'/images/')

            # Create set dirs, copy plots to set dir, and create html file for set
            requested_plot_sets.append('sets') # Add 'sets' to create top level html files
            glob_set = list()
            for plot_set in requested_plot_sets:
                 if 'set_5' == plot_set or 'set_6' == plot_set:
                     glob_set.append(plot_set.replace('_',''))
                     plot_set = 'set5_6'
                 elif 'cset_1' == plot_set:
                     glob_set.append('table_soa')
                     glob_set.append('table_chem')
                     plot_set = plot_set.replace('_','')
                 elif 'set_1' == plot_set:
                     glob_set.append('table_GLBL')
                     glob_set.append('table_NEXT')
                     glob_set.append('table_SEXT')
                     glob_set.append('table_TROP')
                     plot_set = plot_set.replace('_','')
                 elif 'sets' == plot_set:
                     set_dir = web_dir + '/'
                 else:
                     glob_set.append(plot_set.replace('_',''))
                     plot_set = plot_set.replace('_','')

                 if 'sets' not in plot_set: #'sets' is top level, don't create directory or copy images files
                     set_dir = web_dir + '/' + plot_set
                     # Create the plot set web directory
                     if not os.path.exists(set_dir):
                         os.makedirs(set_dir)
                     # Copy plots into the correct web dir
                     for gs in glob_set:
                         glob_string = env['test_path_diag']+'/'+gs+'*.*'
                         for img in glob.iglob(glob_string):
                             new_fn = set_dir + '/' + os.path.basename(img)
                             os.rename(img,new_fn)

                 # Copy/Process html files
                 if 'sets' in plot_set:
                     orig_html = env['HTML_HOME']+'/'+plot_set
                 else:
                     orig_html = env['HTML_HOME']+'/'+plot_set+'/'+plot_set
                 create_atm_html.create_plotset_html(orig_html,set_dir,plot_set,env,'model_vs_obs')

            # Remove any plotvar netcdf files that exists in the diag directory
            if env['save_ncdfs'] == 'False':
                cesmEnvLib.purge(env['test_path_diag'], '.*\.nc')
                cesmEnvLib.purge(env['test_path_diag'], '/station_ids')

            # move all the plots to the diag_path with the years appended to the path
            endYr = (int(env['test_first_yr']) + int(env['test_nyrs'])) - 1
            diag_path = '{0}/diag/{1}-obs.{2}_{3}'.format(env['OUTPUT_ROOT_PATH'], env['test_casename'],
                                                      env['test_first_yr'], str(endYr))
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
                    print('WARNING: {0} exists and is not empty and ATMDIAG_CLEANUP_FILES = False. Leaving new diagnostics files in {1}'.format(diag_path, web_dir))
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

            # setup the unique ATMDIAG_WEBDIR_MODEL_VS_OBS output file
            env_file = '{0}/env_diags_atm.xml'.format(env['PP_CASE_PATH'])
            key = 'ATMDIAG_WEBDIR_{0}'.format(self._name)
            value = diag_path
            web_file = '{0}/web_dirs/{1}.{2}'.format(env['PP_CASE_PATH'], key, datetime.datetime.now().strftime('%Y-%m-%d_%H%M%S'))
            try:
                diagUtilsLib.write_web_file(web_file, 'atm', key, value)
            except:
                print('WARNING atm model_vs_obs unable to write {0}={1} to {2}'.format(key, value, web_file))

            print('*******************************************************************************')
            print('Successfully completed generating atmosphere diagnostics model vs. observation plots')
            print('*******************************************************************************')
