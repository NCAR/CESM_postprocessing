""" 
plot module: PM_FLD3DZA
plot name:   3D Fields, Zonally Averaged

classes:
ZonalAverage3dFields:          base class
ZonalAverage3dFields_obs:      defines specific NCL list for model vs. observations plots
ZonalAverage3dFields_control:  defines specific NCL list for model vs. control plots
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

class ZonalAverage3dFields(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(ZonalAverage3dFields, self).__init__()
        self._expectedPlots_Global = [ 'TEMP_GLO_za', 'SALT_GLO_za', 'IAGE_GLO_za', 'KAPPA_ISOP_GLO_za', 'KAPPA_THIC_GLO_za' ]
        self._expectedPlots_Atlantic = [ 'TEMP_ATL_za', 'SALT_ATL_za', 'IAGE_ATL_za', 'KAPPA_ISOP_ATL_za', 'KAPPA_THIC_ATL_za' ]
        self._expectedPlots_Pacific = [ 'TEMP_PAC_za', 'SALT_PAC_za', 'IAGE_PAC_za', 'KAPPA_ISOP_PAC_za', 'KAPPA_THIC_PAC_za' ]
        self._expectedPlots_Indian = [ 'TEMP_IND_za', 'SALT_IND_za', 'IAGE_IND_za', 'KAPPA_ISOP_IND_za', 'KAPPA_THIC_IND_za' ]
        self._expectedPlots_Southern = [ 'TEMP_SOU_za', 'SALT_SOU_za', 'IAGE_SOU_za', 'KAPPA_ISOP_SOU_za', 'KAPPA_THIC_SOU_za' ]
        self._labels = ['Global','Atlantic','Pacific','Indian','Southern']
        self._name = '3D Fields, Zonally Averaged'
        self._shortname = 'PM_FLD3DZA'
        self._template_file = 'zonal_average_3d_fields.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(ZonalAverage3dFields, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

        # check that temperature observation TOBSFILE exists and is readable
        rc, err_msg = cesmEnvLib.checkFile('{0}/{1}'.format(env['TSOBSDIR'], env['TOBSFILE']), 'read')
        if not rc:
            raise OSError(err_msg)

        # check the TEMP observation zonal average file 
        zaTempFile = '{0}/za_{1}'.format( env['WORKDIR'], env['TOBSFILE'] )
        rc, err_msg = cesmEnvLib.checkFile(zaTempFile, 'read')
        if not rc:
            # change to the workdir
            cwd = os.getcwd()
            os.chdir(env['WORKDIR'])

            # copy the TOBSFILE to a tmp file
            shutil.copy2('{0}/{1}'.format(env['TSOBSDIR'], env['TOBSFILE']), '{0}_tmp'.format(env['TOBSFILE']))

            # call ncks to extract the UAREA variable
            za_args = ['ncks','-A','-v','UAREA',env['TAVGFILE'],'{0}_tmp'.format(env['TOBSFILE']) ]
            if env['netcdf_format'] in ['netcdfLarge']:

                za_args = ['ncks','-6','-A','-v','UAREA',env['TAVGFILE'],'{0}_tmp'.format(env['TOBSFILE']) ]
            try:
##                subprocess.check_output( ['ncks','-A','-v','UAREA',env['TAVGFILE'],'{0}_tmp'.format(env['TOBSFILE']) ], env=env)
                subprocess.check_output(za_args, env=env)
            except subprocess.CalledProcessError as e:
                print('ERROR: {0} call to ncks failed with error:'.format(self.name()))
                print('    {0} - {1}'.format(e.cmd, e.output))
                sys.exit(1)

            # call zaCommand 
            zaCommand = '{0}/za'.format(env['TOOLPATH'])
            rc, err_msg = cesmEnvLib.checkFile(zaCommand, 'exec')
            if not rc:
                raise OSError(err_msg)

            try:
                subprocess.check_output( [zaCommand,'-O','-time_const','-grid_file',env['GRIDFILE'],'{0}_tmp'.format(env['TOBSFILE']) ], env=env)
            except subprocess.CalledProcessError as e:
                print('ERROR: {0} call to {1} failed with error:'.format(self.name(), zaCommand))
                print('    {0} - {1}'.format(e.cmd, e.output))
                sys.exit(1)

            # rename the tmp file
            os.renames('za_{0}_tmp'.format(env['TOBSFILE']), 'za_{0}'.format(env['TOBSFILE']))

            os.chdir(cwd)

        # check that salinity observation SOBSFILE exists and is readable
        rc, err_msg = cesmEnvLib.checkFile('{0}/{1}'.format(env['TSOBSDIR'], env['SOBSFILE']), 'read')
        if not rc:
            raise OSError(err_msg)

        # check the SALT observation zonal average file 
        zaSaltFile = '{0}/za_{1}'.format( env['WORKDIR'], env['SOBSFILE'] )
        rc, err_msg = cesmEnvLib.checkFile(zaSaltFile, 'read')
        if not rc:
      
            # change to the workdir
            cwd = os.getcwd()
            os.chdir(env['WORKDIR'])

            # copy the TOBSFILE to a tmp file
            shutil.copy2('{0}/{1}'.format(env['TSOBSDIR'], env['SOBSFILE']), '{0}_tmp'.format(env['SOBSFILE']))

            # call ncks to extract the UAREA variable
            za_args = ['ncks','-A','-v','UAREA',env['TAVGFILE'],'{0}_tmp'.format(env['SOBSFILE']) ]
            if env['netcdf_format'] in ['netcdfLarge']:
                za_args = ['ncks','-6','-A','-v','UAREA',env['TAVGFILE'],'{0}_tmp'.format(env['SOBSFILE']) ]
            try:
##                subprocess.check_output( ['ncks','-A','-v','UAREA',env['TAVGFILE'],'{0}_tmp'.format(env['SOBSFILE']) ], env=env)
                subprocess.check_output(za_args, env=env)
            except subprocess.CalledProcessError as e:
                print('ERROR: {0} call to ncks failed with error:'.format(self.name()))
                print('    {0} - {1}'.format(e.cmd, e.output))
                sys.exit(1)

            # call zaCommand 
            zaCommand = '{0}/za'.format(env['TOOLPATH'])
            rc, err_msg = cesmEnvLib.checkFile(zaCommand, 'exec')
            if not rc:
                raise OSError(err_msg)

            try:
                subprocess.check_output( [zaCommand,'-O','-time_const','-grid_file',env['GRIDFILE'],'{0}_tmp'.format(env['SOBSFILE']) ], env=env)
            except subprocess.CalledProcessError as e:
                print('ERROR: {0} call to {1} failed with error:'.format(self.name(), zaCommand))
                print('    {0} - {1}'.format(e.cmd, e.output))
                sys.exit(1)

            # rename the tmp file
            os.renames('za_{0}_tmp'.format(env['SOBSFILE']), 'za_{0}'.format(env['SOBSFILE']))

            os.chdir(cwd)


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
        plot_table = []
        num_cols = 6

        for i in range(len(self._labels)):
            plot_list = []
            plot_list.append(self._labels[i])
            exp_plot_list = eval('self._expectedPlots_{0}'.format(self._labels[i]))
            
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
                         'label_list' : self._labels,
                         'imgFormat' : imgFormat
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        return self._shortname, self._html


class ZonalAverage3dFields_obs(ZonalAverage3dFields):

    def __init__(self):
        super(ZonalAverage3dFields_obs, self).__init__()
        self._ncl = ['field_3d_za.ncl']

class ZonalAverage3dFields_control(ZonalAverage3dFields):

    def __init__(self):
        super(ZonalAverage3dFields_control, self).__init__()
        self._ncl = ['field_3d_za_diff.ncl']
