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

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from ocn_diags_plot_bc import OceanDiagnosticPlot

class BasinAverages(OceanDiagnosticPlot):
    """Meridional Overturning Circulation plots
    """

    def __init__(self):
        super(BasinAverages, self).__init__()
        self._expectedPlots = [ 'TSprof_Canadabasin', 'TSprof_Eurasianbasin', 'TSprof_Makarovbasin' ]
        self._webPlotsDict = {'TSprof_Canadabasin':'Canada_Basin','TSprof_Eurasianbasin':'Eurasian_Basin','TSprof_Makarovbasin':'Makarov_Basin'}
        self._name = 'Depth Profiles of Basin-average Temperature and Salinity'
        self._shortname = 'BASINAVGTS'
        self._template_file = 'basin_averages.tmpl'

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(BasinAverages, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

        # check that temperature observation TOBSFILE exists and is readable
        rc, err_msg = cesmEnvLib.checkFile('{0}/{1}'.format(env['TSOBSDIR'], env['TOBSFILE']), 'read')
        if not rc:
            raise OSError(err_msg)

        # set a link to TSOBSDIR/TOBSFILE
        sourceFile = '{0}/{1}'.format(env['TSOBSDIR'], env['TOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'], env['TOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
        if rc:
            rc1, err_msg1 = cesmEnvLib.checkFile(linkFile, 'read')
            if not rc1:
                os.symlink(sourceFile, linkFile)
        else:
            raise OSError(err_msg)

        # check that salinity observation SOBSFILE exists and is readable
        rc, err_msg = cesmEnvLib.checkFile('{0}/{1}'.format(env['TSOBSDIR'], env['SOBSFILE']), 'read')
        if not rc:
            raise OSError(err_msg)

        # set a link to TSOBSDIR/SOBSFILE
        sourceFile = '{0}/{1}'.format(env['TSOBSDIR'], env['SOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'], env['SOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
        if rc:
            rc1, err_msg1 = cesmEnvLib.checkFile(linkFile, 'read')
            if not rc1:
                os.symlink(sourceFile, linkFile)
        else:
            raise OSError(err_msg)


    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # generate_plots with ncl command
        diagUtilsLib.generate_ncl_plots(env, 'TS_basinavg_arctic.ncl')        


    def convert_plots(self, workdir, imgFormat):
        """Converts plots for this class
        """
        self._convert_plots(workdir, imgFormat, self._expectedPlots)


    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        plot_table = dict()
        num_cols = 3

        for plot_file, label in self._webPlotsDict.iteritems():
            img_file = '{0}.{1}'.format(plot_file, imgFormat)
            rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
            if not rc:
                plot_table[label] = '{0} - Error'.format(plot_file)
            else:
                plot_table[label] = plot_file

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
        templateEnv = jinja2.Environment( loader=templateLoader, keep_trailing_newline=False )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'cols' : num_cols,
                         'plot_table' : plot_table,
                         'imgFormat' : imgFormat
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        return self._html

