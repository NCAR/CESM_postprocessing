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
import jinja2

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from ocn_diags_plot_bc import OceanDiagnosticPlot

class BolusVelocity(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(BolusVelocity, self).__init__()
        self._expectedPlots_UISOP = [ 'UISOP0', 'UISOP50', 'UISOP100', 'UISOP200', 'UISOP300', 'UISOP500', 'UISOP1000', 'UISOP1500', 'UISOP2000', 'UISOP2500', 'UISOP3000', 'UISOP3500', 'UISOP4000' ]
        self._expectedPlots_VISOP = [ 'VISOP0', 'VISOP50', 'VISOP100', 'VISOP200', 'VISOP300', 'VISOP500', 'VISOP1000', 'VISOP1500', 'VISOP2000', 'VISOP2500', 'VISOP3000', 'VISOP3500', 'VISOP4000' ]
        self._expectedPlots_WISOP = [ 'WISOP0', 'WISOP50', 'WISOP100', 'WISOP200', 'WISOP300', 'WISOP500', 'WISOP1000', 'WISOP1500', 'WISOP2000', 'WISOP2500', 'WISOP3000', 'WISOP3500', 'WISOP4000' ]
        self._linkNames = [ '0m', '50m', '100m', '200m', '300m', '500m', '1000m', '1500m', '2000m', '2500m', '3000m', '3500m', '4000m' ]
        self._labels = ['UISOP','VISOP','WISOP']
        self._name = 'Bolus Velocity Components at Depth Levels'
        self._shortname = 'VELISOPZ'
        self._template_file = 'bolus_velocity.tmpl'

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(BolusVelocity, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # generate_plots with ncl commands
        diagUtilsLib.generate_ncl_plots(env, 'uisopz.ncl')        
        diagUtilsLib.generate_ncl_plots(env, 'visopz.ncl')        
        diagUtilsLib.generate_ncl_plots(env, 'wisopz.ncl')        

    def convert_plots(self, workdir, imgFormat):
        """Converts plots for this class
        """
        my_plot_list = list()
        for i in range(len(self._labels)):
            my_plot_list.extend(eval('self._expectedPlots_{0}'.format(self._labels[i])))

        self._convert_plots(workdir, imgFormat, my_plot_list)

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        num_cols = 14
        plot_table = []

        for i in range(len(self._labels)):
            plot_tuple_list = []
            plot_tuple = (0, 'label','{0}:'.format(self._labels[i]))
            plot_tuple_list.append(plot_tuple)
            plot_list = eval('self._expectedPlots_{0}'.format(self._labels[i]))

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
                         'num_rows' : len(self._labels),
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        return self._html
