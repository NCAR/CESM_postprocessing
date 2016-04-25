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
import errno
import glob
import itertools
import os
import re
import shutil
import traceback

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# import the diag baseclass module
from ice_diags_bc import IceDiagnostic

# import the plot classes
from diagnostics.ice.Plots import ice_diags_plot_bc
from diagnostics.ice.Plots import ice_diags_plot_factory
import create_ice_html

class modelVsModel(IceDiagnostic):
    """model vs. model ice diagnostics setup
    """
    def __init__(self):
        """ initialize
        """
        super(modelVsModel, self).__init__()

        self._name = 'MODEL_VS_MODEL'
        self._title = 'Model vs. Model'

    def check_prerequisites(self, env, scomm):
        """ check prerequisites
        """
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))
        super(modelVsModel, self).check_prerequisites(env, scomm)

        # clean out the old working plot files from the workdir
        #if env['CLEANUP_FILES'] in ['T',True]:
        #    cesmEnvLib.purge(env['test_path_diag'], '.*\.gif')
        #    cesmEnvLib.purge(env['test_path_diag'], '.*\.ps')
        #    cesmEnvLib.purge(env['test_path_diag'], '.*\.png')
        #    cesmEnvLib.purge(env['test_path_diag'], '.*\.html')
            

        # create the plot.dat file in the workdir used by all NCL plotting routines
        #diagUtilsLib.create_plot_dat(env['WORKDIR'], env['XYRANGE'], env['DEPTHS'])

        # Set some new env variables
        env['DIAG_CODE'] = env['NCLPATH']
        env['DIAG_HOME'] = env['NCLPATH']

        print('DEBUG: model_vs_model env[DIAG_HOME] = {0}'.format(env['DIAG_HOME']))

        env['DIAG_ROOT'] = '{0}/{1}-{2}/'.format(env['DIAG_ROOT'], env['CASE_TO_CONT'], env['CASE_TO_DIFF'])
        env['WKDIR'] = env['DIAG_ROOT']
        env['WORKDIR'] = env['WKDIR']
        if scomm.is_manager():
            if not os.path.exists(env['WKDIR']):
                os.makedirs(env['WKDIR'])
        env['CASE_PREV'] = env['CASE_TO_DIFF']
        env['CASE_NEW'] = env['CASE_TO_CONT']
        env['VAR_NAME_PREV'] = env['VAR_NAME_TYPE_DIFF']
        env['VAR_NAME_NEW'] = env['VAR_NAME_TYPE_CONT']
        env['PATH_PREV'] = env['CLIMO_DIFF']
        env['PATH_NEW'] = env['CLIMO_CONT']
        env['PREV_YR_AVG_FRST'] = str((int(env['ENDYR_DIFF']) - int(env['YRS_TO_AVG'])) + 1)
        env['PREV_YR_AVG_LAST'] = env['ENDYR_DIFF']
        env['NEW_YR_AVG_FRST'] = str((int(env['ENDYR_CONT']) - int(env['YRS_TO_AVG'])) + 1)
        env['NEW_YR_AVG_LAST'] = env['ENDYR_CONT']
        env['YR1'] = env['BEGYR_CONT']
        env['YR2'] = env['ENDYR_CONT'] 
        env['YR1_DIFF'] = env['BEGYR_DIFF']
        env['YR2_DIFF'] = env['ENDYR_DIFF']
        env['PRE_PROC_ROOT_CONT'] = env['PATH_CLIMO_CONT']
        env['PRE_PROC_ROOT_DIFF'] = env['PATH_CLIMO_DIFF']
        env['PATH_PLOT']= env['PATH_CLIMO_CONT']

        # Link obs files into the climo directory
        if (scomm.is_manager()):
            # SSMI
            # CONT CASE
            new_ssmi_fn = env['PATH_CLIMO_CONT'] + '/' + os.path.basename(env['SSMI_PATH'])
            rc1, err_msg1 = cesmEnvLib.checkFile(new_ssmi_fn, 'read')
            if not rc1:
                os.symlink(env['SSMI_PATH'],new_ssmi_fn)
            # DIFF CASE
            new_ssmi_fn = env['PATH_CLIMO_DIFF'] + '/' + os.path.basename(env['SSMI_PATH'])
            rc1, err_msg1 = cesmEnvLib.checkFile(new_ssmi_fn, 'read')
            if not rc1:
                os.symlink(env['SSMI_PATH'],new_ssmi_fn)
            # ASPeCt
            #CONT CASE
            new_ssmi_fn = env['PATH_CLIMO_CONT'] + '/' + os.path.basename(env['ASPeCt_PATH'])
            rc1, err_msg1 = cesmEnvLib.checkFile(new_ssmi_fn, 'read')
            if not rc1:
                os.symlink(env['ASPeCt_PATH'],new_ssmi_fn)
            #DIFF CASE
            new_ssmi_fn = env['PATH_CLIMO_DIFF'] + '/' + os.path.basename(env['ASPeCt_PATH'])
            rc1, err_msg1 = cesmEnvLib.checkFile(new_ssmi_fn, 'read')
            if not rc1:
                os.symlink(env['ASPeCt_PATH'],new_ssmi_fn)
        scomm.sync()

        return env

    def run_diagnostics(self, env, scomm):
        """ call the necessary plotting routines to generate diagnostics plots
        """
        super(modelVsModel, self).run_diagnostics(env, scomm)
        scomm.sync()

        # setup some global variables
        requested_plot_sets = list()
        local_requested_plots = list()
        local_html_list = list()

        # all the plot module XML vars start with 'set_'  need to strip that off
        for key, value in env.iteritems():
            if   ("PLOT_"in key and value == 'True'):
                if ("DIFF" in key or 'PLOT_REGIONS' in key):
                    requested_plot_sets.append(key)        
        scomm.sync()

        # partition requested plots to all tasks
        # first, create plotting classes and get the number of plots each will created 
        requested_plots = {}
        set_sizes = {}
        for plot_set in requested_plot_sets:
            requested_plots.update(ice_diags_plot_factory.iceDiagnosticPlotFactory(plot_set,env))
        # partition based on the number of plots each set will create
        local_plot_list = scomm.partition(requested_plots.keys(), func=partition.EqualStride(), involved=True)  

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
            for name,value in plot_class.plot_env.iteritems():
                plot_class.plot_env[name] = str(value)
            # call script to create plots
            for script in plot_class.ncl_scripts:
                diagUtilsLib.generate_ncl_plots(plot_class.plot_env,script)
            timer.stop(str(scomm.get_rank())+plot_set) 
        timer.stop(str(scomm.get_rank())+"ncl total time on task")
        scomm.sync() 
        print(timer.get_all_times())

        # set html files
        if scomm.is_manager():
            # Setup (local) web directories
            env['HTML_HOME'] = env['POSTPROCESS_PATH']+'/ice_diag/web/'
            web_dir = env['WKDIR']+'/yrs'+env['BEGYR_CONT']+'-'+env['ENDYR_CONT']
            if not os.path.exists(web_dir):
                os.mkdir(web_dir)
            if not os.path.exists(web_dir+'/contour'):
                os.mkdir(web_dir+'/contour')
            if not os.path.exists(web_dir+'/vector'):
                os.mkdir(web_dir+'/vector')
            if not os.path.exists(web_dir+'/line'):
                os.mkdir(web_dir+'/line')
            if not os.path.exists(web_dir+'/obs'):
                os.mkdir(web_dir+'/obs')

            # Move images tot the oppropriate directories
            plot_dir_map = {'icesat':'obs', 'ASPeCt':'obs', 'diff_con_':'contour', 'diff_vec_':'vector', 'line':'line', 'clim':'line'}
            for key,dir in plot_dir_map.iteritems():
                glob_string = env['WKDIR']+'/*'+key+'*.png'
                imgs = glob.glob(glob_string)
                if imgs > 0:
                    for img in imgs:
                        new_fn = web_dir + '/' + dir + '/' + os.path.basename(img)
                        os.rename(img,new_fn)

            # Create/format the html files and copy txt and map files
            shutil.copy(env['HTML_HOME']+'/ICESat.txt', web_dir+'/obs/ICESat.txt')
            shutil.copy(env['HTML_HOME']+'/ASPeCt.txt', web_dir+'/obs/ASPeCt.txt')
            glob_string = env['HTML_HOME']+'/maps/*'
            maps = glob.glob(glob_string)
            for map in maps:
                mn = os.path.basename(map)
                shutil.copy(map,web_dir+'/'+mn)

            print('DEBUG: model_vs_model web_dir = {0}'.format(web_dir))

            html_dir = env['HTML_HOME']
            create_ice_html.create_plotset_html(html_dir+'/index_diff_temp.html',web_dir+'/index.html',env)
            create_ice_html.create_plotset_html(html_dir+'/contour_diff.html',web_dir+'/contour.html',env)
            create_ice_html.create_plotset_html(html_dir+'/timeseries_diff.html',web_dir+'/timeseries.html',env)
            create_ice_html.create_plotset_html(html_dir+'/regional_diff.html',web_dir+'/regional.html',env)
            create_ice_html.create_plotset_html(html_dir+'/vector_diff.html',web_dir+'/vector.html',env)

            # append the web_dir location to the env
            key = 'ICEDIAG_WEBDIR_{0}'.format(self._name)
            env[key] = web_dir

            print('*******************************************************************************')
            print('Successfully completed generating ice diagnostics model vs. model plots')
            print('*******************************************************************************')
            
        scomm.sync()
        return env
