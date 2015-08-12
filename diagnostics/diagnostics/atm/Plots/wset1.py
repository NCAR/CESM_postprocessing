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

class WSet1(AtmosphereDiagnosticPlot):
    """WACCM SET 1 - LAT/PRESS CONTOUR PLOTS (VERTICAL LOG SCALE) 
    """

    def __init__(self, seas,env):
        super(WSet1, self).__init__()
        # Requires a season
        self.seas = seas

        # Derive all of the plot names
        suf = '_c.'+env['p_type']
        pref = 'wset1_'+seas+'_'
   
        # Variable list
        var_list = ['QRL','QRS','RELHUM','T','U','EKE','VPTP_BAR','VBSTAR_UBSTAR',
                    'VPUP_BAR','CLOUD']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        for var in var_list:
            self.expectedPlots.append(pref+var+suf)

        # Set plot class description variables
        self._name = 'WACCM SET 1 - LAT/PRESS CONTOUR PLOTS (VERTICAL LOG SCALE)'
        self._shortname = 'WSET1'
        self._template_file = 'wset1.tmpl'
        self.ncl_scripts = ['plot_vertical_cons.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):

        # Set plot specific variables
        self.plot_env['USE_WACCM_LEVS'] = 'True'
        self.plot_env['SEASON'] = self.seas
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_climo.nc'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'waccm_1_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_climo.nc'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'waccm_1_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'
