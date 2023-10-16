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

class Set2(AtmosphereDiagnosticPlot):
    """DIAG Set 2 - ANNUAL LINE PLOTS OF IMPLIED FLUXES 
    """

    def __init__(self,env):
        super(Set2, self).__init__()
      
        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set2_' 
        self.expectedPlots = [pref+'OHT'+suf, pref+'AHT'+suf, pref+'OFT'+suf]
        if 'OBS' in env['CNTL']:
            self.expectedPlots.append(pref+'HT'+suf)

        # Set plot class description variables
        self._name = 'DIAG Set 2 - ANNUAL LINE PLOTS OF IMPLIED FLUXES'
        self._shortname = 'SET2'
        self._template_file = 'set2.tmpl'
        self.ncl_scripts = ['plot_oft.ncl','plot_oaht.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'+'_ANN_climo.nc'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+'ANNplot2_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.'+'_ANN_climo.nc'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+'ANNplot2_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'
