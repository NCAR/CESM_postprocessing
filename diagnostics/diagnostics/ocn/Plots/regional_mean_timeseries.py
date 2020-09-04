"""
plot module: PM_HORZMN
plot name:   Regional mean T,S(z,t) w/ diff&rms from observations

classes:
RegionalMean:             base class
RegionalMean_timeseries:  defines specific NCL list for model timeseries plots
"""

from __future__ import print_function

import sys

if sys.hexversion < 0x03070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 3.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

import glob
import jinja2
import os
import shutil
import subprocess
import traceback

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from .ocn_diags_plot_bc import OceanDiagnosticPlot

class RegionalMeanTS(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(RegionalMeanTS, self).__init__()
        self._expectedPlots_TEMP_diff = [ 'Glo_hor_mean_Tdiff_timeseries', 'Arc_hor_mean_Tdiff_timeseries', 'Atl_hor_mean_Tdiff_timeseries', 'Gin_hor_mean_Tdiff_timeseries',
                                          'Hud_hor_mean_Tdiff_timeseries', 'Ind_hor_mean_Tdiff_timeseries', 'Lab_hor_mean_Tdiff_timeseries', 'Pac_hor_mean_Tdiff_timeseries',
                                          'Sou_hor_mean_Tdiff_timeseries' ]
        self._expectedPlots_TEMP_rms =  [ 'Glo_hor_mean_Trms_timeseries', 'Arc_hor_mean_Trms_timeseries', 'Atl_hor_mean_Trms_timeseries', 'Gin_hor_mean_Trms_timeseries',
                                          'Hud_hor_mean_Trms_timeseries', 'Ind_hor_mean_Trms_timeseries', 'Lab_hor_mean_Trms_timeseries', 'Pac_hor_mean_Trms_timeseries',
                                          'Sou_hor_mean_Trms_timeseries' ]
        self._expectedPlots_SALT_diff = [ 'Glo_hor_mean_Sdiff_timeseries', 'Arc_hor_mean_Sdiff_timeseries', 'Atl_hor_mean_Sdiff_timeseries', 'Gin_hor_mean_Sdiff_timeseries',
                                          'Hud_hor_mean_Sdiff_timeseries', 'Ind_hor_mean_Sdiff_timeseries', 'Lab_hor_mean_Sdiff_timeseries', 'Pac_hor_mean_Sdiff_timeseries',
                                          'Sou_hor_mean_Sdiff_timeseries' ]
        self._expectedPlots_SALT_rms = [ 'Glo_hor_mean_Srms_timeseries', 'Arc_hor_mean_Srms_timeseries', 'Atl_hor_mean_Srms_timeseries', 'Gin_hor_mean_Srms_timeseries',
                                         'Hud_hor_mean_Srms_timeseries', 'Ind_hor_mean_Srms_timeseries', 'Lab_hor_mean_Srms_timeseries', 'Pac_hor_mean_Srms_timeseries',
                                         'Sou_hor_mean_Srms_timeseries' ]
        self._linkNames = [ 'Global', 'Arctic', 'Atlantic', 'Gin', 'Hudson', 'Indian', 'Labrador', 'Pacific', 'Southern' ]
        self._labels = ['TEMP_diff', 'TEMP_rms', 'SALT_diff', 'SALT_rms']
        self._regions = ['Glo','Arc','Atl','Gin','Hud','Ind','Lab','Pac','Sou']
        self._name = 'Horizontal Mean & Diff/RMS compared to obs'
        self._shortname = 'HORZMN'
        self._template_file = 'regional_mean_timeseries.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(RegionalMeanTS, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

        # create links to the regional horizontal mean average files
        for region in self._regions:
            sourceFile = '{0}/{1}_hor_mean_hor.meanConcat.{2}.pop.h_{3}-{4}.nc'.format(env['TAVGDIR'], region, env['CASE'], env['TSERIES_YEAR0'].zfill(4), env['TSERIES_YEAR1'].zfill(4))
            linkFile = '{0}/{1}_hor_mean_{2}.pop.h_{3}-{4}.nc'.format(env['WORKDIR'], region, env['CASE'], env['TSERIES_YEAR0'].zfill(4), env['TSERIES_YEAR1'].zfill(4))
            diagUtilsLib.createSymLink(sourceFile, linkFile)

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # chdir into the  working directory
        os.chdir(env['WORKDIR'])

        for nclPlotFile in self._ncl:
            # copy the NCL command to the workdir
            shutil.copy2('{0}/{1}'.format(env['NCLPATH'],nclPlotFile), '{0}/{1}'.format(env['WORKDIR'], nclPlotFile))

            nclFile = '{0}/{1}'.format(env['WORKDIR'],nclPlotFile)
            rc, err_msg = cesmEnvLib.checkFile(nclFile, 'read')
            if rc:
                try:
                    print('      calling NCL plot routine {0}'.format(nclPlotFile))
                    subprocess.check_call(['ncl', '{0}'.format(nclFile)], env=env)
                except subprocess.CalledProcessError as e:
                    print('WARNING: {0} call to {1} failed with error:'.format(self.name(), nclFile))
                    print('    {0}'.format(e.cmd))
                    print('    rc = {0}'.format(e.returncode))
            else:
                print('{0}... continuing with additional plots.'.format(err_msg))


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
        num_cols = 10
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

class RegionalMeanTS_timeseries(RegionalMeanTS):

    def __init__(self):
        super(RegionalMeanTS_timeseries, self).__init__()
        self._ncl = ['TS_profiles_diff_plot.ncl']
