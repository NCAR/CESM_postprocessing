from __future__ import print_function

import sys

if sys.hexversion < 0x03070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 3.7.x. ".format(sys.argv[0]))
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
from atm_diags_plot_bc import AtmosphereDiagnosticPlot

class Set14(AtmosphereDiagnosticPlot):
    """DIAG Set 14 - Taylor Diagram Plots 
    """

    def __init__(self,env):
        super(Set14, self).__init__()

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set14'

        variables = ['_ANN_SPACE_TIME','_ANN_SPACE','_DJF_SPACE','_MAM_SPACE','_JJA_SPACE','_SON_SPACE',
                     '.METRICS_CC_SPACE_TIME','.METRICS_VAR_SPACE_TIME','.METRICS_BIAS_SPACE_TIME',
                     '.METRICS_CC_SPACE','.METRICS_VAR_SPACE','.METRICS_BIAS_SPACE','.METRICS_CC_TIME']
        
        self.expectedPlots = []
        for var in variables:
            self.expectedPlots.append(pref+var+suf)

        # Set plot class description variables
        self._name = 'DIAG Set 14 - Taylor Diagram Plots' 
        self._shortname = 'SET14'
        self._template_file = 'set14.tmpl'
        self.ncl_scripts = []
        self.ncl_scripts = ['plot_taylor.ncl']
        self.plot_env = env.copy() 

        # Since this plot set is computationally intensive, we will add weight to it to load balance properly
        self.weight = 250

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+'_plot14_'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+'_plot14_'
        
