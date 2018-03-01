""" 
plot module: PM_VELZ
plot name:   Eulerian Velocity Components at Depth Levels'

classes:
EulerianVelocity:          base class
EulerianVelocity_obs:      defines specific NCL list for model vs. observations plots
EulerianVelocity_control:  defines specific NCL list for model vs. control plots
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
import subprocess
import jinja2

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from ocn_diags_plot_bc import OceanDiagnosticPlot

class EulerianVelocity(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(EulerianVelocity, self).__init__()
        self._expectedPlots_UVEL = [ 'UVEL0', 'UVEL50', 'UVEL100', 'UVEL200', 'UVEL300', 'UVEL500', 'UVEL1000', 'UVEL1500', 'UVEL2000', 'UVEL2500', 'UVEL3000', 'UVEL3500', 'UVEL4000' ]
        self._expectedPlots_VVEL = [ 'VVEL0', 'VVEL50', 'VVEL100', 'VVEL200', 'VVEL300', 'VVEL500', 'VVEL1000', 'VVEL1500', 'VVEL2000', 'VVEL2500', 'VVEL3000', 'VVEL3500', 'VVEL4000' ]
        self._expectedPlots_WVEL = [ 'WVEL0', 'WVEL50', 'WVEL100', 'WVEL200', 'WVEL300', 'WVEL500', 'WVEL1000', 'WVEL1500', 'WVEL2000', 'WVEL2500', 'WVEL3000', 'WVEL3500', 'WVEL4000' ]
        self._linkNames = [ '0m', '50m', '100m', '200m', '300m', '500m', '1000m', '1500m', '2000m', '2500m', '3000m', '3500m', '4000m' ]

        self._labels = ['UVEL','VVEL','WVEL']
        self._name = 'Eulerian Velocity Components at Depth Levels'
        self._shortname = 'PM_VELZ'
        self._template_file = 'eulerian_velocity.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(EulerianVelocity, self).check_prerequisites(env)
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
        
        return self._shortname, self._html

class EulerianVelocity_obs(EulerianVelocity):

    def __init__(self):
        super(EulerianVelocity_obs, self).__init__()
        self._ncl = ['uvelz.ncl', 'vvelz.ncl', 'wvelz.ncl']

class EulerianVelocity_control(EulerianVelocity):

    def __init__(self):
        super(EulerianVelocity_control, self).__init__()
        self._ncl = ['uvelz_diff.ncl', 'vvelz_diff.ncl', 'wvelz_diff.ncl']
