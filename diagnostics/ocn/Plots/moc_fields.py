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

# import the diag_utils module
if os.path.isdir('../diag_utils'):
    sys.path.append('../diag_utils')
    import diag_utils
else:
    err_msg = 'moc_fields.py ERROR: diag_utils.py required and not found in ../../diag_utils'
    raise OSError(err_msg)

# import the plot baseclass module
from ocn_diags_plot_bc import OceanDiagnosticPlot

class MOCFields(OceanDiagnosticPlot):
    """Meridional Overturning Circulation plots
    """

    def __init__(self):
        super(MOCFields, self).__init__()
        self._expectedPlots = [ 'MOC', 'MOC_TOTAL', 'MOC_EI', 'HT', 'FWT' ]
        self._name = 'Meridional Overturning Circulation'
        self._shortname = 'MOC'
        self._template_file = './Templates/{0}'.format('moc_fields.tmpl')

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(MOCFields, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # generate_plots with field_3d_za.ncl command
        diag_utils.generate_ncl_plots(env, 'moc_netcdf.ncl')        


    def _create_html(self, workdir):
        """Creates and renders html that is returned to the calling wrapper
        """
        plot_table = []
        num_cols = 5
        plot_list = []

        for plot_file in self._expectedPlots:
            gif_file = '{0}.gif'.format(plot_file)
            rc, err_msg = diag_utils.checkFile( '{0}/{1}'.format(workdir, gif_file), 'read' )
            if not rc:
                plot_list.append('{0} - Error'.format(plot_file))
            else:
                plot_list.append(plot_file)

        plot_table.append(plot_list)

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath='.' )
        templateEnv = jinja2.Environment( loader=templateLoader )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'cols' : num_cols,
                         'plot_table' : plot_table
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        # remove the extra newlines
        self._html = self._html.replace('\n','')

        return self._html

