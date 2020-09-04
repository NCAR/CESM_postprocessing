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

class WSet1(AtmosphereDiagnosticPlot):
    """WAWG SET 1 - TABLE OF REGIONAL MIN, MAX, MEANS 
    """

    def __init__(self, env):
        super(WSet1, self).__init__()

        # Derive all of the plot names
        suf = '.asc'
        pref = 'wset1_'
   
        # Variable list
        rgn_list = ['SP','EQ','NP']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []

        for rgn in rgn_list:
            self.expectedPlots.append(pref + 'table' + rgn +'_obs' + suf)

        for rgn in rgn_list:
            self.expectedPlots.append(pref + 'table' + rgn + suf)

        # Set plot class description variables
        self._name = 'WAWG SET 1 - TABLE OF REGIONAL MIN, MAX, MEANS'
        self._shortname = 'WSET1'
        self._template_file = 'wset1.tmpl'
        self.ncl_scripts = ['tables_waccm.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):

        # Set plot specific variables
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.'
