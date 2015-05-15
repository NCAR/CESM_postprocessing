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

class SurfaceFluxFields(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(SurfaceFluxFields, self).__init__()
        self._expectedPlots = [ 'SHF_TOTAL', 'SHF_QSW', 'MELTH_F', 'SENH_F', 'LWUP_F',
                                'LWDN_F', 'QFLUX', 'SFWF_TOTAL', 'EVAP_F', 'PREC_F',
                                'SNOW_F', 'MELT_F', 'SALT_F', 'ROFF_F', 'TAUX',
                                'TAUY', 'CURL' ]
        self._za_expectedPlots = [ 'SHF_TOTAL_GLO_za', 'SHF_QSW_GLO_za', 'MELTH_F_GLO_za', 'SENH_F_GLO_za',
                                   'LWUP_F_GLO_za', 'LWDN_F_GLO_za', 'QFLUX_GLO_za', 'SFWF_TOTAL_GLO_za',
                                   'EVAP_F_GLO_za', 'PREC_F_GLO_za', 'SNOW_F_GLO_za', 'MELT_F_GLO_za',
                                   'SALT_F_GLO_za', 'ROFF_F_GLO_za' ]

        self._name = '2D Surface Flux Fields'
        self._shortname = 'SFCFLX'
        self._template_file = 'surface_flux_fields.tmpl'

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(SurfaceFluxFields, self).check_prerequisites(env)
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))

        # setup the fluxobsdir and fluxobsfile based on the coupler version
        fluxobsdir = 'FLUXOBSDIR_CPL{0}'.format(env['CPL'])
        env['FLUXOBSDIR'] = env[fluxobsdir]
        fluxobsfile = 'FLUXOBSFILE_CPL{0}'.format(env['CPL'])
        env['FLUXOBSFILE'] = env[fluxobsfile]

        # check if the flux file exists and is readable
        sourceFile = '{0}/{1}'.format(env['FLUXOBSDIR'],env['FLUXOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
        if not rc:
            raise OSError(err_msg)

        # check if the link to the flux file exists and is readable
        linkFile = '{0}/{1}'.format(env['WORKDIR'],env['FLUXOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(linkFile, 'read')
        if not rc:
            os.symlink(sourceFile, linkFile)

        # check if the zonal average flux file exists and is readable
        sourceFile = '{0}/za_{1}'.format(env['FLUXOBSDIR'],env['FLUXOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
        if not rc:
            raise OSError(err_msg)

        # check if the link to the zonal average flux file exists and is readable
        linkFile = '{0}/za_{1}'.format(env['WORKDIR'],env['FLUXOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(linkFile, 'read')
        if not rc:
            os.symlink(sourceFile, linkFile)

        # check if surface winds and wind stress file exists
        sourceFile = '{0}/{1}'.format(env['WINDOBSDIR'],env['WINDOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
        if not rc:
            raise OSError(err_msg)

        # check if the link to the winds file exists and is readable
        linkFile = '{0}/{1}'.format(env['WORKDIR'],env['WINDOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(linkFile, 'read')
        if not rc:
            os.symlink(sourceFile, linkFile)

        # check if the zonal average wind file exists and is readable
        # commenting out until hear back from Keith Lindsey if this file is needed
        # it does not exist in the popdiag distribution
        #sourceFile = '{0}/za_{1}'.format(env['WINDOBSDIR'],env['WINDOBSFILE'])
        #rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
        #if not rc:
        #    raise OSError(err_msg)

        # check if the link to the zonal average wind file exists and is readable
        #linkFile = '{0}/za_{1}'.format(env['WORKDIR'],env['WINDOBSFILE'])
        #rc, err_msg = cesmEnvLib.checkFile(linkFile, 'read')
        #if not rc:
        #    os.symlink(sourceFile, linkFile)

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # call the generate_plots with sfcflx.ncl command
        diagUtilsLib.generate_ncl_plots(env, 'sfcflx.ncl')        

        # call the generate_plots with sfcflx_za.ncl command
        diagUtilsLib.generate_ncl_plots(env, 'sfcflx_za.ncl')        


    def _create_html(self, workdir, templatePath):
        """Creates and renders html that is returned to the calling wrapper
        """
        plot_table = []
        num_cols = 7

        num_plots = len(self._expectedPlots)
        num_last_row = num_plots % num_cols
        num_rows = num_plots//num_cols
        index = 0

        for i in range(num_rows):
            plot_list = []
            for j in range(num_cols):
                plot_file = self._expectedPlots[index]
                gif_file = '{0}.gif'.format(plot_file)
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, gif_file), 'read' )
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
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, gif_file), 'read' )
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
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, gif_file), 'read' )
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
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, gif_file), 'read' )
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
