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

class CSet4(AtmosphereDiagnosticPlot):
    """CSET 4 - Column O3/CO comparisionColumn O3/CO comparisionss 
    """

    def __init__(self,seas,env):
        super(CSet4, self).__init__()
        # Requires a season
        self.seas = seas

        # Derive all of the plot names
        suf = '.png'
        pref = 'cset4_o3_column_omi_'+seas+'_'

        # Types
        types = ['total','strat','trop'] 

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        for t in types:
            self.expectedPlots.append(pref+t+suf)
        if 'ANN' in seas:
            for m in range(1,13):
                self.expectedPlots.append('cset4_co_column_mopitt_'+str(m).zfill(2)+suf)

        # Set plot class description variables
        self._name = 'CSET 4 - Column O3/CO comparisions'
        self._shortname = 'CSET4'
        self._template_file = 'cset4.tmpl'
        self.ncl_scripts = ['plot_surface_mean_o3_col.ncl']
        if 'ANN' in seas:
            self.ncl_scripts.append('plot_surface_mean_co_col.ncl')
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['SEASON'] = self.seas
        self.plot_env['TEST_CASE'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'
        if 'OBS' in env['CNTL']:
            self.plot_env['STD_CASE'] = 'NONE'
        else:
            self.plot_env['STD_CASE'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.' 
        self.plot_env['NCDF_MODE'] = 'create'
