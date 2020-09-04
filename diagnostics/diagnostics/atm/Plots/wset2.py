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
from .atm_diags_plot_bc import AtmosphereDiagnosticPlot

class WSet2(AtmosphereDiagnosticPlot):
    """WACCM SET 2 - SEASONAL CYCLE LINE PLOTS 
    """

    def __init__(self, env):
        super(WSet2, self).__init__()

        # Derive all of the plot names
        suf = '_c.'+env['p_type']
        pref = 'wset2_'

        # Put plot names together and add to expected plot list
        # Different file lists for OBS and Model to Model
        self.expectedPlots = []
   
        # Variable list
        if 'OBS' in env['CNTL']:
            obs_list = ['ERAI', 'MLS', 'MERRA']
        else:
            obs_list = ['']
            
        var_list = ['H2O','T','T','T','U']
        p_list   = ['85','85', 'TRP','MSP','10']
        rgn_list = ['SP','SM','EQ','NM','NP']
        for obs in obs_list:
            for index, var in enumerate(var_list):
              for rgn in rgn_list:
                  self.expectedPlots.append(pref + obs + '_' + var + '_' + rgn + '_' + p_list[index] + '_obs'+suf)

        # Set plot class description variables
        self._name = 'WACCM SET 2 - SEASONAL CYCLE LINE PLOTS '
        self._shortname = 'WSET2'
        self._template_file = 'wset2.tmpl'
        self.ncl_scripts = ['plot_waccm_cycle.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):

        # Set plot specific variables
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.'
