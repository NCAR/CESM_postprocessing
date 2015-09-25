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
import create_lnd_html

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# import the diag baseclass module
from lnd_diags_bc import LandDiagnostic

# import the plot classes
from diagnostics.lnd.Plots import lnd_diags_plot_bc
from diagnostics.lnd.Plots import lnd_diags_plot_factory

class modelVsModel(LandDiagnostic):
    """model vs. model land diagnostics setup
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
        env['WKDIR'] =  envDict['PTMPDIR']+'/diag/'+envDict['caseid_1']+'-obs/'
        env['WORKDIR'] = env['WKDIR']
        if scomm.is_manager():
            if not os.path.exists(env['WKDIR']):
                os.makedirs(env['WKDIR'])
        env['PLOTTYPE']       = env['p_type']
        env['OBS_DATA']       = env['OBS_HOME']
        env['INPUT_FILES']    = env['DIAG_HOME']+'/inputFiles/'
        env['DIAG_RESOURCES'] = env['DIAG_HOME']+'/resources/'

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
            if ("set_" in key and value == 'True'):
                requested_plot_sets.append(key)
        
        scomm.sync()

        # partition requested plots to all tasks
        # first, create plotting classes and get the number of plots each will created 
        requested_plots = {}
        set_sizes = {}
        plots_weights = []
        for plot_set in requested_plot_sets:
            requested_plots.update(lnd_diags_plot_factory.landDiagnosticPlotFactory(plot_set,env))
        for plot_id,plot_class in requested_plots.iteritems(): 
            if hasattr(plot_class, 'weight'):
                factor = plot_class.weight
            else:
                factor = 1
            plots_weights.append((plot_id,len(plot_class.expectedPlots)*factor))
        # partition based on the number of plots each set will create
        local_plot_list = scomm.partition(plots_weights, func=partition.WeightBalanced(), involved=True)  

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
            web_script_1 = 'lnd_create_webpage.pl'
            web_script_2 = 'lnd_lookupTable.pl'

            print('Creating Web Pages')
            # lnd_create_webpage.pl call
            rc1, err_msg = cesmEnvLib.checkFile(web_script_1,'read')
            if rc1:
                try:
                    pipe = subprocess.Popen(['perl {0}'.format((web_script_1)], cwd=env['WORKDIR'], env=env, shell=True, stdout=subprocess.PIPE)
                    output = pipe.communicate()[0]
                    print(output)
                    while pipe.poll() is None:
                        time.sleep(0.5)
                except OSError as e:
                    print('WARNING',e.errno,e.strerror)
            else:
                print('{0}... {1} file not found'.format(err_msg,web_script_1))

            # lnd_lookupTable.pl call          
            rc2, err_msg = cesmEnvLib.checkFile(web_script_2,'read')
            if rc2:
                try:
                    pipe = subprocess.Popen(['perl {0}'.format((web_script_2)], cwd=env['WORKDIR'], env=env, shell=True, stdout=subprocess.PIPE)
                    output = pipe.communicate()[0]
                    print(output)
                    while pipe.poll() is None:
                        time.sleep(0.5)
                except OSError as e:
                    print('WARNING',e.errno,e.strerror)
            else:
                print('{0}... {1} file not found'.format(err_msg,web_script_2))

            if len(env['WEBDIR']) > 0 and len(env['WEBHOST']) > 0 and len(env['WEBLOGIN']) > 0:
                # copy over the files to a remote web server and webdir 
                diagUtilsLib.copy_html_files(env)
            else:
                print('Web files successfully created')
                print('The env_diags_lnd.xml variable WEBDIR, WEBHOST, and WEBLOGIN were not set.')
                print('You will need to manually copy the web files to a remote web server.')

            print('*******************************************************************************')
            print('Successfully completed generating land diagnostics model vs. model plots')
            print('*******************************************************************************')
            
        scomm.sync()

