""" 
plot module: PM_ENSOWVLT
plot name:   ENSO Wavelet Analysis

classes:           
EnsoWavelet:            base class
EnsoWavelet_timeseries: defines specific NCL list for model timeseries plots
"""

from __future__ import print_function

import sys

if sys.hexversion < 0x03070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 3.7.x. ".format(sys.argv[0]))
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

class EnsoWavelet(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(EnsoWavelet, self).__init__()
        self._expectedPlots = ['ENSO.nino3.analysis', 'ENSO.nino3.4.analysis']
        self._webPlotsDict = {'Nino3':'ENSO.nino3.analysis', 'Nino3.4':'ENSO.nino3.4.analysis'}
        self._name = 'ENSO Wavelet Analysis'
        self._shortname = 'ENSOWVLT'
        self._template_file = 'enso_wavelet_timeseries.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(EnsoWavelet, self).check_prerequisites(env)
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))

        # set the FILE_IN env var to point to the diagts_nino.asc file in the workdir
        # may need to modify the NCL to only look at years specified.
        diagts_nino = '{0}/diagts_nino.asc'.format(env['WORKDIR'])
        rc, err_msg = cesmEnvLib.checkFile(diagts_nino, 'read')
        if not rc:
            print('{0}... continuing with additional plots.'.format(err_msg))
        else:
            env['FILE_IN'] = os.environ['FILE_IN'] = diagts_nino

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))
        for ncl in self._ncl:
            diagUtilsLib.generate_ncl_plots(env, ncl)

    def convert_plots(self, workdir, imgFormat):
        """Converts plots for this class
        """
        self._convert_plots(workdir, imgFormat, self._expectedPlots)

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        num_cols = 2
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

class EnsoWavelet_timeseries(EnsoWavelet):

    def __init__(self):
        super(EnsoWavelet_timeseries, self).__init__()
        self._ncl = ['pop_log_diagts_nino.monthly.ncl','enso_wavelet_asc.ncl']
