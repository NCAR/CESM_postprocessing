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
import subprocess
import collections
import jinja2

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from ocn_diags_plot_bc import OceanDiagnosticPlot

class PolarTempSalt(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(PolarTempSalt, self).__init__()
        self._expectedPlots_Arctic_TEMP = [ 'Arctic_TEMP0', 'Arctic_TEMP50', 'Arctic_TEMP100', 'Arctic_TEMP200', 'Arctic_TEMP300', 'Arctic_TEMP500', 
                                           'Arctic_TEMP1000', 'Arctic_TEMP1500', 'Arctic_TEMP2000', 'Arctic_TEMP2500', 'Arctic_TEMP3000', 'Arctic_TEMP3500', 'Arctic_TEMP4000' ]
        self._expectedPlots_Arctic_SALT = [ 'Arctic_SALT0', 'Arctic_SALT50', 'Arctic_SALT100', 'Arctic_SALT200', 'Arctic_SALT300', 'Arctic_SALT500', 
                                           'Arctic_SALT1000', 'Arctic_SALT1500', 'Arctic_SALT2000', 'Arctic_SALT2500', 'Arctic_SALT3000', 'Arctic_SALT3500', 'Arctic_SALT4000' ]
        self._expectedPlots_Antarctic_TEMP = [ 'Antarctic_TEMP0', 'Antarctic_TEMP50', 'Antarctic_TEMP100', 'Antarctic_TEMP200', 'Antarctic_TEMP300', 'Antarctic_TEMP500', 
                                           'Antarctic_TEMP1000', 'Antarctic_TEMP1500', 'Antarctic_TEMP2000', 'Antarctic_TEMP2500', 'Antarctic_TEMP3000', 'Antarctic_TEMP3500', 'Antarctic_TEMP4000' ]
        self._expectedPlots_Antarctic_SALT = [ 'Antarctic_SALT0', 'Antarctic_SALT50', 'Antarctic_SALT100', 'Antarctic_SALT200', 'Antarctic_SALT300', 'Antarctic_SALT500', 
                                           'Antarctic_SALT1000', 'Antarctic_SALT1500', 'Antarctic_SALT2000', 'Antarctic_SALT2500', 'Antarctic_SALT3000', 'Antarctic_SALT3500', 'Antarctic_SALT4000' ]

        self._linkNames = [ '0m', '50m', '100m', '200m', '300m', '500m', '1000m', '1500m', '2000m', '2500m', '3000m', '3500m', '4000m' ]

        self._name = 'Polar Temperature and Salinity at Depth Levels'
        self._shortname = 'KAPPAZ'
        self._template_file = 'diffusion_depth.tmpl'

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(PolarTempSalt, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # generate_plots with ncl commands
        diagUtilsLib.generate_ncl_plots(env, 'tempz_arctic.ncl')        
        diagUtilsLib.generate_ncl_plots(env, 'saltz_arctic.ncl')        
        diagUtilsLib.generate_ncl_plots(env, 'tempz_antarctic.ncl')        
        diagUtilsLib.generate_ncl_plots(env, 'saltz_antarctic.ncl')        

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        labels = ['Arctic_TEMP','Arctic_SALT','Antarctic_TEMP','Antarctic_SALT']
        num_cols = 14
        plot_table = []

        for i in range(len(labels)):
            plot_tuple_list = []
            plot_tuple = (0, 'label','{0}:'.format(labels[i]))
            plot_tuple_list.append(plot_tuple)
            plot_list = eval('self._expectedPlots_{0}'.format(labels[i]))

            for j in range(num_cols - 1):
                img_file = '{0}.{1}'.format(plot_list[j], imgFormat)
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                if not rc:
                    plot_tuple = (j+1, self._linkNames[j],'{0} - Error'.format(img_file))
                else:
                    plot_tuple = (j+1, self._linkNames[j], img_file)
                plot_tuple_list.append(plot_tuple)

            print('DEBUG... plot_tuple_list[{0}] = {1}'.format(i, plot_tuple_list))
            plot_table.append(plot_tuple_list)

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
        templateEnv = jinja2.Environment( loader=templateLoader, keep_trailing_newline=False )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'plot_table' : plot_table,
                         'num_rows' : len(labels),
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        return self._html
