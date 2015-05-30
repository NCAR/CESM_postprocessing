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

class MixedLayerDepth(OceanDiagnosticPlot):
    """Mixed Layer Depth Plots
    """

    def __init__(self):
        super(MixedLayerDepth, self).__init__()
        self._expectedPlots = [ 'mld1', 'mld2' ]
        self._webPlotsDict = { 'mld1' : 'MLD.125', 'mld2' : 'MLD.03' }
        self._name = 'Mixed Layer Depth Plots'
        self._shortname = 'MLD'
        self._template_file = 'mixed_layer_depth.tmpl'

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(MixedLayerDepth, self).check_prerequisites(env)
        print('  Checking prerequisites for : {0}'.format(self.__class__.__name__))

        # set SEASAVGRHO env var to the envDict['SEASAVGRHO'] file
        os.environ['SEASAVGRHO'] = env['SEASAVGRHO']

        # set a link to RHOOBSDIR/RHOOBSFILE
        sourceFile = '{0}/{1}'.format(env['RHOOBSDIR'], env['RHOOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'], env['RHOOBSFILE'])
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
            
        # generate_plots with compute_rho.ncl command
        diagUtilsLib.generate_ncl_plots(env, 'compute_rho.ncl')        

        # generate_plots with mld.ncl command
        diagUtilsLib.generate_ncl_plots(env, 'mld.ncl')        

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        num_cols = 2
        plot_table = dict()

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
