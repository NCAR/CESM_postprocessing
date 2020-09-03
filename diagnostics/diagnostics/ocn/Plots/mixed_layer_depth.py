"""
plot module: PM_MLD
plot name:   Mixed Layer Depth Plots

classes:
MixedLayerDepth:          base class
MixedLayerDepth_obs:      defines specific NCL list for model vs. observations plots
MixedLayerDepth_control:  defines specific NCL list for model vs. control plots
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

import traceback
import os
import shutil
import jinja2

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from .ocn_diags_plot_bc import OceanDiagnosticPlot

class MixedLayerDepth(OceanDiagnosticPlot):
    """Mixed Layer Depth Plots
    """

    def __init__(self):
        super(MixedLayerDepth, self).__init__()
        self._expectedPlots = [ 'mld1', 'mld2' ]
        self._webPlotsDict = { 'mld1' : 'MLD.125', 'mld2' : 'MLD.03' }
        self._name = 'Mixed Layer Depth Plots'
        self._shortname = 'PM_MLD'
        self._template_file = 'mixed_layer_depth.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(MixedLayerDepth, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

        # set SEASAVGRHO env var to the env['SEASAVGRHO'] output file name
        os.environ['SEASAVGRHO'] = env['SEASAVGRHO']

        # set CNTRLSEASAVGRHO env var to the env['CNTRLSEASAVGRHO'] output file name
        os.environ['CNTRLSEASAVGRHO'] = env['CNTRLSEASAVGRHO']

        # set a link to RHOOBSDIR/RHOOBSFILE
        sourceFile = '{0}/{1}'.format(env['RHOOBSDIR'], env['RHOOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'], env['RHOOBSFILE'])
        diagUtilsLib.createSymLink(sourceFile, linkFile)

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))
        # always compute the RHO value regardless of diagnostic type
        diagUtilsLib.generate_ncl_plots(env, 'compute_rho.ncl')
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

        for plot_file, label in self._webPlotsDict.items():
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

        return self._shortname, self._html


class MixedLayerDepth_obs(MixedLayerDepth):

    def __init__(self):
        super(MixedLayerDepth_obs, self).__init__()
        self._ncl = ['mld.ncl']

class MixedLayerDepth_control(MixedLayerDepth):

    def __init__(self):
        super(MixedLayerDepth_control, self).__init__()
        self._ncl = ['compute_rho_cntl.ncl', 'mld_diff.ncl']
