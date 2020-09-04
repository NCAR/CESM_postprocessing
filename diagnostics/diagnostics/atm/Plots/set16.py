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

class Set16(AtmosphereDiagnosticPlot):
    """DIAG Set 16 - Budget Terms Select Sites Plots 
    """

    def __init__(self, seas,env):
        super(Set16, self).__init__()
        # Requires a season
        self.seas = seas

        # Derive all of the plot names
        suf = '.'+env['p_type']
        pref = 'set16_'+seas+'_'
   
        # Variable list
        var_list = ['PTEQ']

        # Regions
        sites = ['lll']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        for var in var_list:
            for site in sites:
                self.expectedPlots.append(pref+site+'_'+var+suf)

        # Set plot class description variables
        self._name = 'DIAG Set 16 - Budget Terms Select Sites Plots'
        self._shortname = 'SET16'
        self._template_file = 'set16.tmpl'
        self.ncl_scripts = ['plot_budget_select_sites.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['SEASON'] = self.seas
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_climo.nc'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'plot16_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_climo.nc'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'plot16_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'
