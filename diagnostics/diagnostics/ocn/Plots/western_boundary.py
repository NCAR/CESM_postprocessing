""" 
plot module: PM_WBC
plot name:   Western Boundary Currents

classes:
WesternBoundary:          base class
WesternBoundary_obs:      defines specific NCL list for model vs. observations plots
WesternBoundary_control:  defines specific NCL list for model vs. control plots
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
from ocn_diags_plot_bc import OceanDiagnosticPlot

class WesternBoundary(OceanDiagnosticPlot):
    """Western Boundary Current & DWBC diagnostics
    """

    def __init__(self):
        super(WesternBoundary, self).__init__()
        self._expectedPlots = [ 'DWBC' ]
        self._name = 'Western Boundary Currents'
        self._shortname = 'DWBC'
        self._template_file = 'western_boundary.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(WesternBoundary, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

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
        plot_table = []
        num_cols = 1
        plot_list = []

        for plot_file in self._expectedPlots:
            img_file = '{0}.{1}'.format(plot_file, imgFormat)
            rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
            if not rc:
                plot_list.append('{0} - Error'.format(plot_file))
            else:
                plot_list.append(plot_file)

        plot_table.append(plot_list)

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

class WesternBoundary_obs(WesternBoundary):

    def __init__(self):
        super(WesternBoundary_obs, self).__init__()
        self._ncl = ['dwbc.ncl']

class WesternBoundary_control(WesternBoundary):

    def __init__(self):
        pass
