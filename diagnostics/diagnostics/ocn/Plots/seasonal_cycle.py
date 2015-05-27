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

class SeasonalCycle(OceanDiagnosticPlot):
    """Seasonal Cycle Plots
    """

    def __init__(self):
        super(SeasonalCycle, self).__init__()
        self._expectedPlots = [ 'EQ_PAC_SST_SEASONAL_CYCLE' ]
        self._name = 'Seasonal Cycle Plots'
        self._shortname = 'SCP'
        self._template_file = 'seasonal_cycle.tmpl'

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(SeasonalCycle, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

        # set SEASAVGFILE env var to the envDict['SEASAVGTEMP'] file
        os.environ['SEASAVGFILE'] = env['SEASAVGTEMP']

        # set a link to SSTOBSDIR/SSTOBSFILE
        sourceFile = '{0}/{1}'.format(env['SSTOBSDIR'], env['SSTOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'], env['SSTOBSFILE'])
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
            
        # generate_plots with field_3d_za.ncl command
        diagUtilsLib.generate_ncl_plots(env, 'sst_eq_pac_seasonal_cycle.ncl')        

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        plot_table = []
        num_cols = 1
        plot_list = []

        for plot_file in self._expectedPlots:
            img_file = '{0}.{1}'.format(plot_file, imgFormat)
            rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
            if not rc:
                plot_list.append('{0} - Error'.format(plot_file))
            else:
                plot_list.append(plot_file)

        plot_table.append(plot_list)

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
        templateEnv = jinja2.Environment( loader=templateLoader )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'cols' : num_cols,
                         'plot_table' : plot_table,
                         'imgFormat' : imgFormat
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        # remove the extra newlines
        self._html = self._html.replace('\n','')

        return self._html

