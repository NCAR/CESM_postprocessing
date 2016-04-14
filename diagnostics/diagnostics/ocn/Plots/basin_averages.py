""" 
plot module: PM_BASINAVGTS 
plot name:   Depth Profiles of Basin-average Temperature and Salinity

classes:
BasinAverages:          base class
BasinAverages_obs:      defines specific NCL list for model vs. observations plots
BasinAverages_control:  defines specific NCL list for model vs. control plots
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

class BasinAverages(OceanDiagnosticPlot):
    """Meridional Overturning Circulation plots
    """

    def __init__(self):
        super(BasinAverages, self).__init__()
        self._expectedPlots = [ 'TSprof_Canadabasin', 'TSprof_Eurasianbasin', 'TSprof_Makarovbasin' ]
        self._webPlotsDict = {'TSprof_Canadabasin':'Canada_Basin','TSprof_Eurasianbasin':'Eurasian_Basin','TSprof_Makarovbasin':'Makarov_Basin'}
        self._name = 'Depth Profiles of Basin-average Temperature and Salinity'
        self._shortname = 'PM_BASINAVGTS'
        self._template_file = 'basin_averages.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(BasinAverages, self).check_prerequisites(env)
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
        plot_table = dict()
        num_cols = 3

        for plot_file, label in self._webPlotsDict.iteritems():
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

class BasinAverages_obs(BasinAverages):
    def __init__(self):
        super(BasinAverages_obs, self).__init__()
        self._ncl = ['TS_basinavg_arctic.ncl']

class BasinAverages_control(BasinAverages):
    pass
