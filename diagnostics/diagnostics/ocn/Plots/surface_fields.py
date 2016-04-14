""" 
plot module: PM_FLD2D
plot name:   2D Surface Fields

classes:
SurfaceFields:          base class
SurfaceFields_obs:      defines specific NCL list for model vs. observations plots
SurfaceFields_control:  defines specific NCL list for model vs. control plots
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
import jinja2


# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from ocn_diags_plot_bc import OceanDiagnosticPlot

class SurfaceFields(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(SurfaceFields, self).__init__()
        self._expectedPlots = [ 'SSH', 'HBLT', 'HMXL', 'DIA_DEPTH', 'TLT', 'INT_DEPTH', 'SU', 'SV', 'BSF' ]
        self._expectedPlots_za = [ 'SSH_GLO_za', 'HBLT_GLO_za', 'HMXL_GLO_za', 'DIA_DEPTH_GLO_za', 'TLT_GLO_za', 'INT_DEPTH_GLO_za' ]

        self._name = '2D Surface Fields'
        self._shortname = 'PM_FLD2D'
        self._template_file = 'surface_fields.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(SurfaceFields, self).check_prerequisites(env)
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))

        # check the observation sea surface height file
        sourceFile = '{0}/{1}'.format( env['SSHOBSDIR'], env['SSHOBSFILE'] )
        linkFile = '{0}/{1}'.format(env['WORKDIR'],env['SSHOBSFILE'])
        diagUtilsLib.createSymLink(sourceFile, linkFile)

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
        self._convert_plots(workdir, imgFormat, self._expectedPlots_za)

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        plot_table = []
        num_cols = 6

        num_plots = len(self._expectedPlots)
        num_last_row = num_plots % num_cols
        num_rows = num_plots//num_cols
        index = 0

        for i in range(num_rows):
            plot_list = []
            for j in range(num_cols):
                plot_file = self._expectedPlots[index]
                img_file = '{0}.{1}'.format(plot_file, imgFormat)
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                if not rc:
                    plot_list.append('{0} - Error'.format(plot_file))
                else:
                    plot_list.append(plot_file)
                index += 1                    
            plot_table.append(plot_list)

        # pad out the last row
        if num_last_row > 0:
            plot_list = []
            for i in range(num_last_row):
                plot_file = self._expectedPlots[index]
                img_file = '{0}.{1}'.format(plot_file, imgFormat)
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                if not rc:
                    plot_list.append('{0} - Error'.format(plot_file))
                else:
                    plot_list.append(plot_file)
                index += 1                    

            for i in range(num_cols - num_last_row):
                plot_list.append('')

            plot_table.append(plot_list)

        # work on the global zonal average 2d flux plots
        plot_za_table = []

        num_plots = len(self._expectedPlots_za)
        num_last_row = num_plots % num_cols
        num_rows = num_plots//num_cols
        index = 0

        for i in range(num_rows):
            plot_list = []
            for j in range(num_cols):
                plot_file = self._expectedPlots_za[index]
                img_file = '{0}.{1}'.format(plot_file, imgFormat)
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                if not rc:
                    plot_list.append('{0} - Error'.format(plot_file))
                else:
                    plot_list.append(plot_file)
                index += 1                    
            plot_za_table.append(plot_list)

        # pad out the last row
        if num_last_row > 0:
            plot_list = []
            for i in range(num_last_row):
                plot_file = self._expectedPlots_za[index]
                img_file = '{0}.{1}'.format(plot_file, imgFormat)
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                if not rc:
                    plot_list.append('{0} - Error'.format(plot_file))
                else:
                    plot_list.append(plot_file)
                index += 1                    

            for i in range(num_cols - num_last_row):
                plot_list.append('')

            plot_za_table.append(plot_list)

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
        templateEnv = jinja2.Environment( loader=templateLoader, keep_trailing_newline=False )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'cols' : num_cols,
                         'plot_table' : plot_table,
                         'plot_za_table' : plot_za_table,
                         'imgFormat' : imgFormat
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        return self._shortname, self._html

class SurfaceFields_obs(SurfaceFields):

    def __init__(self):
        super(SurfaceFields_obs, self).__init__()
        self._ncl = ['ssh.ncl', 'field_2d.ncl', 'field_2d_za.ncl']

class SurfaceFields_control(SurfaceFields):

    def __init__(self):
        super(SurfaceFields_control, self).__init__()
        self._ncl = ['field_2d_diff.ncl', 'field_2d_za_diff.ncl']
