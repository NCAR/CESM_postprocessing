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

# import the diag_utils module
if os.path.isdir('../diag_utils'):
    sys.path.append('../diag_utils')
    import diag_utils
else:
    err_msg = 'surface_fields.py ERROR: diag_utils.py required and not found in ../diag_utils'
    raise OSError(err_msg)

# import the plot baseclass module
from ocn_diags_plot_bc import OceanDiagnosticPlot

class SurfaceFields(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(SurfaceFields, self).__init__()
        self._expectedPlots = [ 'SSH', 'HBLT', 'HMXL', 'DIA_DEPTH', 'TLT', 'INT_DEPTH', 'SU', 'SV', 'BSF' ]
        self._za_expectedPlots = [ 'SSH_GLO_za', 'HBLT_GLO_za', 'HMXL_GLO_za', 'DIA_DEPTH_GLO_za', 'TLT_GLO_za', 'INT_DEPTH_GLO_za' ]

        self._name = '2D Surface Fields'
        self._shortname = 'FLD2D'
        self._template_file = './Templates/{0}'.format('surface_fields.tmpl')

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(SurfaceFields, self).check_prerequisites(env)
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))

        # check the observation sea surface height file
        sshFile = '{0}/{1}'.format( env['SSHOBSDIR'], env['SSHOBSFILE'] )
        rc, err_msg = diag_utils.checkFile(sshFile, 'read')
        if not rc:
            raise OSError(err_msg)

        # check if the link to the observation sea surface height file exists and is readable
        linkFile = '{0}/{1}'.format(env['WORKDIR'],env['SSHOBSFILE'])
        rc, err_msg = diag_utils.checkFile(linkFile, 'read')
        if not rc:
            os.symlink(sshFile, linkFile)

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # generate_plots with ssh.ncl command
        diag_utils.generate_ncl_plots(env, 'ssh.ncl')        

        # generate_plots with field_2d.ncl command
        diag_utils.generate_ncl_plots(env, 'field_2d.ncl')        

        # generate_plots with field_2d_za.ncl command
        diag_utils.generate_ncl_plots(env, 'field_2d_za.ncl')        


    def _create_html(self, workdir):
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
                gif_file = '{0}.gif'.format(plot_file)
                rc, err_msg = diag_utils.checkFile( '{0}/{1}'.format(workdir, gif_file), 'read' )
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
                gif_file = '{0}.gif'.format(plot_file)
                rc, err_msg = diag_utils.checkFile( '{0}/{1}'.format(workdir, gif_file), 'read' )
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

        num_plots = len(self._za_expectedPlots)
        num_last_row = num_plots % num_cols
        num_rows = num_plots//num_cols
        index = 0

        for i in range(num_rows):
            plot_list = []
            for j in range(num_cols):
                plot_file = self._za_expectedPlots[index]
                gif_file = '{0}.gif'.format(plot_file)
                rc, err_msg = diag_utils.checkFile( '{0}/{1}'.format(workdir, gif_file), 'read' )
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
                plot_file = self._za_expectedPlots[index]
                gif_file = '{0}.gif'.format(plot_file)
                rc, err_msg = diag_utils.checkFile( '{0}/{1}'.format(workdir, gif_file), 'read' )
                if not rc:
                    plot_list.append('{0} - Error'.format(plot_file))
                else:
                    plot_list.append(plot_file)
                index += 1                    

            for i in range(num_cols - num_last_row):
                plot_list.append('')

            plot_za_table.append(plot_list)

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath='.' )
        templateEnv = jinja2.Environment( loader=templateLoader )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'cols' : num_cols,
                         'plot_table' : plot_table,
                         'plot_za_table' : plot_za_table
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        # remove the extra newlines
        self._html = self._html.replace('\n','')

        return self._html
