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
import collections
import datetime
import errno
import glob
import itertools
import os
import re
import shutil
import traceback

# import modules installed by pip into virtualenv
import jinja2

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# import the diag baseclass module
from ocn_diags_bc import OceanDiagnostic

# import the plot classes
from diagnostics.ocn.Plots import ocn_diags_plot_bc
from diagnostics.ocn.Plots import ocn_diags_plot_factory

class modelVsObs(OceanDiagnostic):
    """model vs. observations ocean diagnostics setup
    """
    def __init__(self):
        """ initialize
        """
        super(modelVsObs, self).__init__()

        self._name = 'MODEL_VS_OBS'
        self._title = 'Model vs. Observations'

    def check_prerequisites(self, env):
        """ check prerequisites
        """
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))
        super(modelVsObs, self).check_prerequisites(env)

        # clean out the old working plot files from the workdir
        if env['CLEANUP_FILES'].upper() in ['T','TRUE']:
            cesmEnvLib.purge(env['WORKDIR'], '.*\.pro')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.gif')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.dat')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.ps')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.png')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.html')

        # create the plot.dat file in the workdir used by all NCL plotting routines
        diagUtilsLib.create_plot_dat(env['WORKDIR'], env['XYRANGE'], env['DEPTHS'])

        # setup the gridfile based on the resolution and vertical levels
        os.environ['gridfile'] = '{0}/omwg/za_grids/{1}_grid_info.nc'.format(env['DIAGOBSROOT'],env['RESOLUTION'])
        if env['VERTICAL'] == '42':
            os.environ['gridfile'] = '{0}/omwg/za_grids/{1}_42lev_grid_info.nc'.format(env['DIAGOBSROOT'],env['RESOLUTION'])

        if env['VERTICAL'] == '62':
            os.environ['gridfile'] = '{0}/omwg/za_grids/{1}_62lev_grid_info.nc'.format(env['DIAGOBSROOT'],env['RESOLUTION'])

        # check if gridfile exists and is readable
        rc, err_msg = cesmEnvLib.checkFile(os.environ['gridfile'], 'read')
        if not rc:
            print('model_vs_obs:  check_prerequisites could not find gridfile = {0}'.format(os.environ['gridfile']))
            raise ocn_diags_bc.PrerequisitesError

        env['GRIDFILE'] = os.environ['gridfile']

        # check the resolution and decide if some plot modules should be turned off
        if (env['RESOLUTION'] == 'tx0.1v2' or env['RESOLUTION'] == 'tx0.1v3'):
            env['MVO_PM_VELISOPZ'] = os.environ['MVO_PM_VELISOPZ'] = 'FALSE'
            env['MVO_PM_KAPPAZ'] = os.environ['MVO_PM_KAPPAZ'] = 'FALSE'

        # create the global zonal average file used by most of the plotting classes
        print('    model vs. obs - calling create_za')
        diagUtilsLib.create_za( env['WORKDIR'], env['TAVGFILE'], env['GRIDFILE'], env['TOOLPATH'], env)

        return env

    def run_diagnostics(self, env, scomm):
        """ call the necessary plotting routines to generate diagnostics plots
        """
        super(modelVsObs, self).run_diagnostics(env, scomm)
        scomm.sync()

        # setup some global variables
        requested_plots = list()
        local_requested_plots = list()

        # define the templatePath for all tasks
        templatePath = '{0}/diagnostics/diagnostics/ocn/Templates'.format(env['POSTPROCESS_PATH']) 

        # all the plot module XML vars start with MVO_PM_  need to strip off the MVO_
        for key, value in env.iteritems():
            if (re.search("\AMVO_PM_", key) and value.upper() in ['T','TRUE']):
                k = key[4:]                
                requested_plots.append(k)

        scomm.sync()
        print('model vs. obs - after scomm.sync requested_plots = {0}'.format(requested_plots))

        if scomm.is_manager():
            print('model vs. obs - User requested plot modules:')
            for plot in requested_plots:
                print('  {0}'.format(plot))

            print('model vs. obs - Creating plot html header')
            templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
            templateEnv = jinja2.Environment( loader=templateLoader )
                
            template_file = 'model_vs_obs.tmpl'
            template = templateEnv.get_template( template_file )
    
            # get the current datatime string for the template
            now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

            # set the template variables
            templateVars = { 'casename' : env['CASE'],
                             'tagname' : env['CESM_TAG'],
                             'username' : env['USER_NAME'],
                             'start_year' : env['YEAR0'],
                             'stop_year' : env['YEAR1'],
                             'today': now
                             }

            print('model vs. obs - Rendering plot html header')
            plot_html = template.render( templateVars )

        scomm.sync()

        print('model vs. obs - Partition requested plots')
        # partition requested plots to all tasks
        local_requested_plots = scomm.partition(requested_plots, func=partition.EqualStride(), involved=True)
        scomm.sync()

        for requested_plot in local_requested_plots:
            try:
                plot = ocn_diags_plot_factory.oceanDiagnosticPlotFactory('obs', requested_plot)

                print('model vs. obs - Checking prerequisite for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                plot.check_prerequisites(env)

                print('model vs. obs - Generating plots for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                plot.generate_plots(env)

                print('model vs. obs - Converting plots for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                plot.convert_plots(env['WORKDIR'], env['IMAGEFORMAT'])

            except RuntimeError as e:
                print(e)
                print("model vs. obs - Skipped '{0}' and continuing!".format(requested_plot))

        scomm.sync()

        # initialize OrderedDict with plot_order list entries as key
        html_order = collections.OrderedDict()
        for plot in env['MVO_PLOT_ORDER'].split():
            html_order[plot] = '';

        if scomm.is_manager():
            for plot in env['MVO_PLOT_ORDER'].split():
                if plot in requested_plots:
                    print('calling get_html for plot = {0}'.format(plot))
                    plot_obj = ocn_diags_plot_factory.oceanDiagnosticPlotFactory('obs', plot)
                    shortname, html = plot_obj.get_html(env['WORKDIR'], templatePath, env['IMAGEFORMAT'])
                    html_order[shortname] = html

            for k, v in html_order.iteritems():
                print('Adding html for plot = {0}'.format(k))
                plot_html += v

            print('model vs. obs - Adding footer html')
            with open('{0}/footer.tmpl'.format(templatePath), 'r') as tmpl:
                plot_html += tmpl.read()

            print('model vs. obs - Writing plot index.html')
            with open( '{0}/index.html'.format(env['WORKDIR']), 'w') as index:
                index.write(plot_html)

            print('*******************************************************************************')
            print('Successfully completed generating ocean diagnostics model vs. observation plots')
            print('*******************************************************************************')

        scomm.sync()

        # append the web_dir location to the env
        key = 'OCNDIAG_WEBDIR_{0}'.format(self._name)
        env[key] = env['WORKDIR']

        return env

