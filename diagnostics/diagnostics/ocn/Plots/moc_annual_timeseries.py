""" 
plot module: PM_MOCANN
plot name:   Annual MOC Maximum

classes:           
MOCAnnual:            base class
MOCAnnual_timeseries: defines specific NCL list for model timeseries plots
"""

from __future__ import print_function

import sys

if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

import glob
import jinja2
import os
import shutil
import subprocess
import traceback


# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from ocn_diags_plot_bc import OceanDiagnosticPlot

class MOCAnnual(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(MOCAnnual, self).__init__()
        self._expectedPlots = ['maxmoc0']
        self._webPlotsDict = {'MOC':'maxmoc0'}
        self._name = 'Annual MOC Maximum'
        self._shortname = 'MOCANN'
        self._template_file = 'moc_annual_timeseries.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(MOCAnnual, self).check_prerequisites(env)
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))

        # create link to MOC average file
        sourceFile = '{0}/{1}.pop.h.{2}-{3}.moc.nc'.format(env['TAVGDIR'], env['CASE'], env['TSERIES_YEAR0'].zfill(4), env['TSERIES_YEAR1'].zfill(4))
        linkFile = '{0}/{1}.pop.h.MOC.{2}_cat_{3}.nc'.format(env['WORKDIR'], env['CASE'], env['TSERIES_YEAR0'].zfill(4), env['TSERIES_YEAR1'].zfill(4))
        diagUtilsLib.createSymLink(sourceFile, linkFile)
        env['MOCTSANNFILE'] = os.environ['MOCTSANNFILE'] = linkFile

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # chdir into the  working directory
        os.chdir(env['WORKDIR'])

        for nclPlotFile in self._ncl:
            # copy the NCL command to the workdir
            shutil.copy2('{0}/{1}'.format(env['NCLPATH'],nclPlotFile), '{0}/{1}'.format(env['WORKDIR'], nclPlotFile))

            nclFile = '{0}/{1}'.format(env['WORKDIR'],nclPlotFile)
            rc, err_msg = cesmEnvLib.checkFile(nclFile, 'read')
            if rc:
                try:
                    print('      calling NCL plot routine {0}'.format(nclPlotFile))
                    subprocess.check_call(['ncl', '{0}'.format(nclFile)], env=env)
                except subprocess.CalledProcessError as e:
                    print('WARNING: {0} call to {1} failed with error:'.format(self.name(), nclFile))
                    print('    {0}'.format(e.cmd))
                    print('    rc = {0}'.format(e.returncode))
            else:
                print('{0}... continuing with additional plots.'.format(err_msg))

    def convert_plots(self, workdir, imgFormat):
        """Converts plots for this class
        """
        self._convert_plots(workdir, imgFormat, self._expectedPlots)

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        num_cols = 1
        plot_table = dict()

        for label, plot_file in self._webPlotsDict.items():
            img_file = '{0}.{1}'.format(plot_file, imgFormat)
            rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
            if not rc:
                plot_table[label] = '{0} - Error'.format(plot_file)
            else:
                plot_table[label] = plot_file

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
        templateEnv = jinja2.Environment( loader=templateLoader, keep_trailing_newline=False )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'cols' : num_cols,
                         'plot_table' : plot_table,
                         'imgFormat' : imgFormat
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        return self._html

class MOCAnnual_timeseries(MOCAnnual):

    def __init__(self):
        super(MOCAnnual_timeseries, self).__init__()
        self._ncl = ['moc_annual_timeseries.ncl']
