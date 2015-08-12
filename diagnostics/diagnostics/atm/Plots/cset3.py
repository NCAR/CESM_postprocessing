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

class CSet3(AtmosphereDiagnosticPlot):
    """CSET 3 - Ozonesonde comparisions 
    """

    def __init__(self,env):
        super(CSet3, self).__init__()

        # Derive all of the plot names
        suf = '.png'
        pref = 'cset3_'

        # Regions
        regions = ['nh_polar_west','nh_polar_east','canada','west_europe','eastern_us','Boulder',
                   'japan','nh_tropic','tropics1','tropics2','tropics3','sh_midlat','sh_polar']

        # Types
        types = ['o3profiles_comp','o3profiles_strat','o3seasonal_comp'] 

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        for region in regions:
            for t in types:
                self.expectedPlots.append(pref+region+'_'+t+suf)
        #  Append extra plot that did not follow the naming rule
        self.expectedPlots.append('cset3_regions_taylor.png')

        # Set plot class description variables
        self._name = 'CSET 3 - Ozonesonde comparisions'
        self._shortname = 'CSET3'
        self._template_file = 'cset3.tmpl'
        self.ncl_scripts = ['profiles_station_regions_comp.ncl','profiles_station_regions_comp_strat.ncl',
                            'seasonal_cycle_o3_regions_comp.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['TEST_CASE'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'
        if 'OBS' in env['CNTL']:
            self.plot_env['STD_CASE'] = 'NONE'
        else:
            self.plot_env['STD_CASE'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.' 
        self.plot_env['NCDF_MODE'] = 'create'
