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

class CSet5(AtmosphereDiagnosticPlot):
    """CSET 5 - COMPARISON TO NOAA Aircraft 
    """

    def __init__(self,env):
        super(CSet5, self).__init__()
        # Requires a season, but as of now, it only uses ANN
        self.seas = 'ANN'

        # Put plot names together and add to expected plot list
        self.expectedPlots = ['cset5_noaa_EastCoast_varprofiles_comp.png',
                              'cset5_noaa_WestCoast_varprofiles_comp.png',
                              'cset5_noaa_Texas_varprofiles_comp.png',
                              'cset5_noaa_Alaska_varprofiles_comp.png']

        # Set plot class description variables
        self._name = 'CSET 5 - COMPARISON TO NOAA Aircraft'
        self._shortname = 'CSET5'
        self._template_file = 'cset5.tmpl'
        self.ncl_scripts = ['profiles_aircraft_noaa.ncl']

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
