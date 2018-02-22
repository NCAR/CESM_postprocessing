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

class modelVsControl(OceanDiagnostic):
    """model vs. control ocean diagnostics setup
    """
    def __init__(self):
        """ initialize
        """
        super(modelVsControl, self).__init__()

        self._name = 'MODEL_VS_CONTROL'
        self._title = 'Model vs. Control'

    def check_prerequisites(self, env):
        """ check prerequisites
        """
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))
        self._name = '{0}_{1}'.format(self._name, env['CNTRLCASE'])
        super(modelVsControl, self).check_prerequisites(env)

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

        # setup prerequisites for the model
        # setup the gridfile based on the resolution and levels
        os.environ['gridfile'] = '{0}/omwg/za_grids/{1}_grid_info.nc'.format(env['DIAGOBSROOT'],env['RESOLUTION'])
        if env['VERTICAL'] == '42':
            os.environ['gridfile'] = '{0}/omwg/za_grids/{1}_42lev_grid_info.nc'.format(env['DIAGOBSROOT'],env['RESOLUTION'])

        if env['VERTICAL'] == '62':
            os.environ['gridfile'] = '{0}/omwg/za_grids/{1}_62lev_grid_info.nc'.format(env['DIAGOBSROOT'],env['RESOLUTION'])

        # check if gridfile exists and is readable
        rc, err_msg = cesmEnvLib.checkFile(os.environ['gridfile'], 'read')
        if not rc:
            raise OSError(err_msg)
        env['GRIDFILE'] = os.environ['gridfile']

        # check the resolution and decide if some plot modules should be turned off
        if (env['RESOLUTION'] == 'tx0.1v2' or env['RESOLUTION'] == 'tx0.1v3') :
            env['MVC_PM_VELISOPZ'] = os.environ['MVC_PM_VELISOPZ'] = 'FALSE'
            env['MVC_PM_KAPPAZ'] = os.environ['MVC_PM_KAPPAZ'] = 'FALSE'

        # create the global zonal average file used by most of the plotting classes
        print('   model vs. control - calling create_za')
        diagUtilsLib.create_za( env['WORKDIR'], env['TAVGFILE'], env['GRIDFILE'], env['TOOLPATH'], env)

        # setup prerequisites for the model control
        control = True
        env['CNTRL_MAVGFILE'], env['CNTRL_TAVGFILE'] = diagUtilsLib.createLinks(env['CNTRLYEAR0'], env['CNTRLYEAR1'], env['CNTRLTAVGDIR'], env['WORKDIR'], env['CNTRLCASE'], control)
        env['CNTRLFILE'] = env['CNTRL_TAVGFILE']

        # setup the gridfile based on the resolution and vertical levels
        os.environ['gridfilecntrl'] = '{0}/omwg/za_grids/{1}_grid_info.nc'.format(env['DIAGOBSROOT'],env['CNTRLRESOLUTION'])
        if env['VERTICAL'] == '42':
            os.environ['gridfilecntrl'] = '{0}/omwg/za_grids/{1}_42lev_grid_info.nc'.format(env['DIAGOBSROOT'],env['CNTRLRESOLUTION'])

        if env['VERTICAL'] == '62':
            os.environ['gridfilecntrl'] = '{0}/omwg/za_grids/{1}_62lev_grid_info.nc'.format(env['DIAGOBSROOT'],env['CNTRLRESOLUTION'])

        # check if gridfile exists and is readable
        rc, err_msg = cesmEnvLib.checkFile(os.environ['gridfilecntrl'], 'read')
        if not rc:
            raise OSError(err_msg)
        env['GRIDFILECNTRL'] = os.environ['gridfilecntrl']

        # check the resolution and decide if some plot modules should be turned off
        if (env['CNTRLRESOLUTION'] == 'tx0.1v2' or env['CNTRLRESOLUTION'] == 'tx0.1v3') :
            env['MVC_PM_VELISOPZ'] = os.environ['MVC_PM_VELISOPZ'] = 'FALSE'
            env['MVC_PM_KAPPAZ'] = os.environ['MVC_PM_KAPPAZ'] = 'FALSE'

        # create the control global zonal average file used by most of the plotting classes
        print('    model vs. control - calling create_za for control run')
        diagUtilsLib.create_za( env['WORKDIR'], env['CNTRL_TAVGFILE'], env['GRIDFILECNTRL'], env['TOOLPATH'], env)

        return env

    def run_diagnostics(self, env, scomm):
        """ call the necessary plotting routines to generate diagnostics plots
        """
        super(modelVsControl, self).run_diagnostics(env, scomm)
        scomm.sync()

        # setup some global variables
        requested_plots = list()
        local_requested_plots = list()

        # define the templatePath for all tasks
        templatePath = '{0}/diagnostics/diagnostics/ocn/Templates'.format(env['POSTPROCESS_PATH']) 

        # all the plot module XML vars start with MVC_PM_  need to strip off MVC_
        for key, value in env.iteritems():
            if (re.search("\AMVC_PM_", key) and value.upper() in ['T','TRUE']):
                k = key[4:]
                requested_plots.append(k)

        scomm.sync()
        print('model vs. control - after scomm.sync requested_plots = {0}'.format(requested_plots))

        if scomm.is_manager():
            print('model vs. control - User requested plot modules:')
            for plot in requested_plots:
                print('  {0}'.format(plot))

            print('model vs. control - Creating plot html header')
            templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
            templateEnv = jinja2.Environment( loader=templateLoader )
                
            template_file = 'model_vs_control.tmpl'
            template = templateEnv.get_template( template_file )

            # get the current datatime string for the template
            now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

            # set the template variables
            templateVars = { 'casename' : env['CASE'],
                             'username' : env['USER_NAME'],
                             'control_casename' : env['CNTRLCASE'],
                             'tagname' : env['CESM_TAG'],
                             'start_year' : env['YEAR0'],
                             'stop_year' : env['YEAR1'],
                             'control_start_year' : env['CNTRLYEAR0'],
                             'control_stop_year' : env['CNTRLYEAR1'],
                             'today': now
                             }

            print('model vs. control - Rendering plot html header')
            plot_html = template.render( templateVars )

        scomm.sync()

        print('model vs. control - Partition requested plots')
        # partition requested plots to all tasks
        local_requested_plots = scomm.partition(requested_plots, func=partition.EqualStride(), involved=True)
        scomm.sync()

        for requested_plot in local_requested_plots:
            try:
                plot = ocn_diags_plot_factory.oceanDiagnosticPlotFactory('control',requested_plot)

                print('model vs. control - Checking prerequisite for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                plot.check_prerequisites(env)

                print('model vs. control - Generating plots for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                plot.generate_plots(env)

                print('model vs. control - Converting plots for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                plot.convert_plots(env['WORKDIR'], env['IMAGEFORMAT'])

            except RuntimeError as e:
                # unrecoverable error, bail!
                print("Skipped '{0}' and continuing!".format(requested_plot))
                print(e)

        scomm.sync()

        # initialize OrderedDict with plot_order list entries as key
        html_order = collections.OrderedDict()
        for plot in env['MVC_PLOT_ORDER'].split():
            html_order[plot] = '';

        if scomm.is_manager():
            for plot in env['MVC_PLOT_ORDER'].split():
                if plot in requested_plots:
                    print('calling get_html for plot = {0}'.format(plot))
                    plot_obj = ocn_diags_plot_factory.oceanDiagnosticPlotFactory('control', plot)
                    shortname, html = plot_obj.get_html(env['WORKDIR'], templatePath, env['IMAGEFORMAT'])
                    html_order[shortname] = html

            for k, v in html_order.iteritems():
                print('Adding html for plot = {0}'.format(k))
                plot_html += v

            print('model vs. control - Adding footer html')
            with open('{0}/footer.tmpl'.format(templatePath), 'r') as tmpl:
                plot_html += tmpl.read()

            print('model vs. control - Writing plot index.html')
            with open( '{0}/index.html'.format(env['WORKDIR']), 'w') as index:
                index.write(plot_html)

            print('***************************************************************************')
            print('Successfully completed generating ocean diagnostics model vs. control plots')
            print('***************************************************************************')

        scomm.sync()

        # append the web_dir location to the env
        key = 'OCNDIAG_WEBDIR_{0}'.format(self._name)
        env[key] = env['WORKDIR']

        return env


