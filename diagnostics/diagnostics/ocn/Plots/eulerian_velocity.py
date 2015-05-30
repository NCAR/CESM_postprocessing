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

        self._name = 'Eulerian Velocity Components at Depth (meters)'
        self._shortname = 'VELZ'
        self._template_file = 'eulerian_velocity.tmpl'

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(EulerianVelocity, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # generate_plots with ncl commands
        diagUtilsLib.generate_ncl_plots(env, 'uvelz.ncl')        
        diagUtilsLib.generate_ncl_plots(env, 'vvelz.ncl')        
        diagUtilsLib.generate_ncl_plots(env, 'wvelz.ncl')        


    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        plot_table = []
        num_cols = 14

        label_list = ['UVEL','VVEL','WVEL']

        for i in range(len(label_list)):
            plot_list = []
            plot_list.append(label_list[i])
            exp_plot_list = eval('self._expectedPlots_{0}'.format(label_list[i]))
            
            for j in range(num_cols - 2):
                plot_file = exp_plot_list[j]
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
                         'label_list' : label_list,
                         'imgFormat' : imgFormat
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        return self._html