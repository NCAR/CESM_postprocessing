""" 
plot module: PM_SFC2D
plot name:   2D Surface Flux Fields

classes:
SurfaceFluxFields:          base class
SurfaceFluxFields_obs:      defines specific NCL list for model vs. observations plots
SurfaceFluxFields_control:  defines specific NCL list for model vs. control plots
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

# this becomes the bass class
class SurfaceFluxFields(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(SurfaceFluxFields, self).__init__()
        self._expectedPlots = [ 'SHF_TOTAL', 'SHF_QSW', 'MELTH_F', 'SENH_F', 'LWUP_F',
                                'LWDN_F', 'QFLUX', 'SFWF_TOTAL', 'EVAP_F', 'PREC_F',
                                'SNOW_F', 'MELT_F', 'SALT_F', 'ROFF_F', 'TAUX',
                                'TAUY', 'CURL' ]
        self._expectedPlots_za = [ 'SHF_GLO_za', 'SHF_QSW_GLO_za', 'MELTH_F_GLO_za', 'SENH_F_GLO_za',
                                   'LWUP_F_GLO_za', 'LWDN_F_GLO_za', 'QFLUX_GLO_za', 'SFWF_GLO_za',
                                   'EVAP_F_GLO_za', 'PREC_F_GLO_za', 'SNOW_F_GLO_za', 'MELT_F_GLO_za',
                                   'SALT_F_GLO_za', 'ROFF_F_GLO_za' ]

        self._name = '2D Surface Flux Fields'
        self._shortname = 'PM_SFC2D'
        self._template_file = 'surface_flux_fields.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))
        super(SurfaceFluxFields, self).check_prerequisites(env)

        # setup the fluxobsdir and fluxobsfile based on the coupler version
        fluxobsdir = 'FLUXOBSDIR_CPL{0}'.format(env['CPL'])
        env['FLUXOBSDIR'] = env[fluxobsdir]
        fluxobsfile = 'FLUXOBSFILE_CPL{0}'.format(env['CPL'])
        env['FLUXOBSFILE'] = env[fluxobsfile]

        # create symbolic link to the flux observation file in the workdir
        sourceFile = '{0}/{1}'.format(env['FLUXOBSDIR'],env['FLUXOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'],env['FLUXOBSFILE'])
        diagUtilsLib.createSymLink(sourceFile, linkFile)
   
        # create symbolic link to zonal average flux file in the workdir
        sourceFile = '{0}/za_{1}'.format(env['FLUXOBSDIR'],env['FLUXOBSFILE'])
        linkFile = '{0}/za_{1}'.format(env['WORKDIR'],env['FLUXOBSFILE'])
        diagUtilsLib.createSymLink(sourceFile, linkFile)

        # create symbolic link to wind file in the workdir
        sourceFile = '{0}/{1}'.format(env['WINDOBSDIR'],env['WINDOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'],env['WINDOBSFILE'])
        diagUtilsLib.createSymLink(sourceFile, linkFile)

        # check if the zonal average wind file exists and is readable
        # this file does not exist - and not sure it is used in the ncl
        #sourceFile = '{0}/za_{1}'.format(env['WINDOBSDIR'],env['WINDOBSFILE'])
        #linkFile = '{0}/za_{1}'.format(env['WORKDIR'],env['WINDOBSFILE'])
        #diagUtilsLib.createSymLink(sourceFile, linkFile)

    def generate_plots(self, env):
        """generate list of NCL plotting routines 
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
        num_cols = 7

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
    
class SurfaceFluxFields_obs(SurfaceFluxFields):

    def __init__(self):
        super(SurfaceFluxFields_obs, self).__init__()
        self._ncl = ['sfcflx.ncl', 'sfcflx_za.ncl']

class SurfaceFluxFields_control(SurfaceFluxFields):

    def __init__(self):
        super(SurfaceFluxFields_control, self).__init__()
        self._ncl = ['sfcflx_diff.ncl', 'sfcflx_za_diff.ncl']
