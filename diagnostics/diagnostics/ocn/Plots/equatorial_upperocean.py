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

class EquatorialUpperocean(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(EquatorialUpperocean, self).__init__()
        self._expectedPlots_Longitude_Depth = [ 'T_EQ', 'S_EQ', 'U_EQ_PAC', 'U_EQ_ATL', 'U_EQ_IND' ]
        self._longitude_linkNames = ['TEMP (Glo)', 'SALT (Glo)', 'UVEL (Pac)', 'UVEL (Atl)', 'UVEL (Ind)']

        self._expectedPlots_Latitude_Depth_143 = [ 'T_143E', 'S_143E', 'PD_143E', 'U_143E' ]  
        self._expectedPlots_Latitude_Depth_156 = [ 'T_156E', 'S_156E', 'PD_156E', 'U_156E' ]  
        self._expectedPlots_Latitude_Depth_165 = [ 'T_165E', 'S_165E', 'PD_165E', 'U_165E' ]  
        self._expectedPlots_Latitude_Depth_180 = [ 'T_180E', 'S_180E', 'PD_180E', 'U_180E' ]  
        self._expectedPlots_Latitude_Depth_190 = [ 'T_190E', 'S_190E', 'PD_190E', 'U_190E' ]  
        self._expectedPlots_Latitude_Depth_205 = [ 'T_205E', 'S_205E', 'PD_205E', 'U_205E' ]  
        self._expectedPlots_Latitude_Depth_220 = [ 'T_220E', 'S_220E', 'PD_220E', 'U_220E' ]  
        self._expectedPlots_Latitude_Depth_235 = [ 'T_235E', 'S_235E', 'PD_235E', 'U_235E' ]  
        self._expectedPlots_Latitude_Depth_250 = [ 'T_250E', 'S_250E', 'PD_250E', 'U_250E' ]  
        self._expectedPlots_Latitude_Depth_265 = [ 'T_265E', 'S_265E', 'PD_265E', 'U_265E' ]  
        self._latitude_linkNames = [ 'TEMP', 'SALT', 'PD', 'UVEL' ]

        self._suffix = ['Longitude_Depth','Latitude_Depth_143','Latitude_Depth_156', 'Latitude_Depth_165','Latitude_Depth_180', 'Latitude_Depth_190','Latitude_Depth_205', 'Latitude_Depth_220','Latitude_Depth_235', 'Latitude_Depth_250','Latitude_Depth_265']

        self._name = 'Equatorial Upperocean'
        self._shortname = 'UOEQ'
        self._template_file = 'equatorial_upperocean.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(EquatorialUpperocean, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

        # check in the PHC2 files exist based on the number of vertical levels
        # check temp
        phcTemp = env['TOBSFILE']
        if env['VERTICAL'] == 42:
            phcTemp = env['TOBSFILE_V42']

        # check if the link to the PHC temp file exists and is readable
        sourceFile = '{0}/{1}'.format(env['TSOBSDIR'],phcTemp)
        linkFile = '{0}/{1}'.format(env['WORKDIR'],phcTemp)
        diagUtilsLib.createSymLink(sourceFile, linkFile)

        # check salt
        phcSalt = env['SOBSFILE']
        if env['VERTICAL'] == 42:
            phcTemp = env['SOBSFILE_V42']

        # check if the link to the PHC salt file exists and is readable
        sourceFile = '{0}/{1}'.format(env['TSOBSDIR'],phcSalt)
        linkFile = '{0}/{1}'.format(env['WORKDIR'],phcSalt)
        diagUtilsLib.createSymLink(sourceFile, linkFile)

        # check if the link to the TOGA-TAO exists and is readable
        sourceFile = '{0}/{1}'.format(env['TOGATAODIR'],env['TOGATAOFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'],env['TOGATAOFILE'])
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
        my_plot_list = list()
        for i in range(len(self._suffix)):
            my_plot_list.extend(eval('self._expectedPlots_{0}'.format(self._suffix[i])))

        self._convert_plots(workdir, imgFormat, my_plot_list)

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        labels = ['143&deg;E','156&deg;E','165&deg;E','180&deg;E','190&deg;E','205&deg;E','220&deg;E','235&deg;E','250&deg;E','265&deg;E']
        depths = ['143', '156', '165', '180', '190', '205', '220', '235', '250', '265']
        num_cols = 5
        long_plot_table = []
        lat_plot_table = []

        # generate the longitude table
        plot_tuple_list = []
        plot_list = eval('self._expectedPlots_Longitude_Depth')

        for j in range(len(plot_list)):
            img_file = '{0}.{1}'.format(plot_list[j], imgFormat)
            rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
            if not rc:
                plot_tuple = (j, self._longitude_linkNames[j],'{0} - Error'.format(img_file))
            else:
                plot_tuple = (j, self._longitude_linkNames[j], img_file)
            plot_tuple_list.append(plot_tuple)

        print('DEBUG... plot_tuple_list = {0}'.format(plot_tuple_list))
        long_plot_table.append(plot_tuple_list)

        # generate the latitude table
        for i in range(len(labels)):
            plot_tuple_list = []
            plot_tuple = (0, 'label','{0}:'.format(labels[i]))
            plot_tuple_list.append(plot_tuple)
            plot_list = eval('self._expectedPlots_Latitude_Depth_{0}'.format(depths[i]))

            for j in range(num_cols - 1):
                img_file = '{0}.{1}'.format(plot_list[j], imgFormat)
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                if not rc:
                    plot_tuple = (j+1, self._latitude_linkNames[j],'{0} - Error'.format(img_file))
                else:
                    plot_tuple = (j+1, self._latitude_linkNames[j], img_file)
                plot_tuple_list.append(plot_tuple)

            print('DEBUG... plot_tuple_list[{0}] = {1}'.format(i, plot_tuple_list))
            lat_plot_table.append(plot_tuple_list)

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
        templateEnv = jinja2.Environment( loader=templateLoader, keep_trailing_newline=False )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'long_plot_table' : long_plot_table,
                         'lat_plot_table' : lat_plot_table,
                         'num_rows' : len(labels),
                         'cols' : num_cols
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        return self._html

class EquatorialUpperocean_obs(EquatorialUpperocean):

    def __init__(self):
        super(EquatorialUpperocean_obs, self).__init__()
        self._ncl = ['T_eq.ncl', 'S_eq.ncl', 'U_eq.ncl', 'U_eq_meridional.ncl', 'S_eq_meridional.ncl', 'T_eq_meridional.ncl', 'PD_eq_meridional.ncl']

class EquatorialUpperocean_model(EquatorialUpperocean):

    def __init__(self):
        super(EquatorialUpperocean_model, self).__init__()
        self._ncl = ['T_eq_diff.ncl', 'S_eq_diff.ncl', 'U_eq_diff.ncl', 'U_eq_meridional_diff.ncl', 'S_eq_meridional_diff.ncl', 'T_eq_meridional_diff.ncl', 'PD_eq_meridional_diff.ncl']
