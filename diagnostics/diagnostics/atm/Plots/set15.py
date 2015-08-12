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
from atm_diags_plot_bc import AtmosphereDiagnosticPlot

class Set15(AtmosphereDiagnosticPlot):
    """DIAG Set 15 - Annual Cycle Select Sites Plots 
    """

    def __init__(self, env):
        super(Set15, self).__init__()

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set15_'
   
        # Variable list
        var_list = ['T','Q','CLOUD','MSE','TMQ','FSDS','FLDS','TGCLDLWP','CLDTOT']

        sites = ['SGP','NSA','TWP1','TWP2','TWP3']

        other_combos = ['SHEBA_FSDS','SHEBA_FLDS','SGP_PRECT','SGP_LHFLX','SGP_SHFLX']       

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        for var in var_list:
            for site in sites:
                self.expectedPlots.append(pref+site+'_'+var+suf)
        for combo in other_combos:
            self.expectedPlots.append(pref+combo+suf)
        

        # Set plot class description variables
        self._name = 'DIAG Set 15 - Annual Cycle Select Sites Plots'
        self._shortname = 'SET15'
        self._template_file = 'set15.tmpl'
        self.ncl_scripts = ['plot_ac_select_sites.ncl']
        self.plot_env = env.copy() 

        # Since this plot set is computationally intensive, we will add weight to it to load balance properly
        self.weight = 5

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+'plot15_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+'plot15_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'
