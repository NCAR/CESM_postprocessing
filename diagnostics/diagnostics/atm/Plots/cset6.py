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

class CSet6(AtmosphereDiagnosticPlot):
    """CSET 6 - COMPARISON TO EMMONS Aircraft Climatology 
    """

    def __init__(self,env):
        super(CSet6, self).__init__()

        # Derive all of the plot names
        suf = '.png'
        pref = 'cset6_emmons_'

        # Types
        regions = ['SH','Tropics','NH_Midlat','NH_Polar']
       
        # Variables
        var_list = ['O3','OH','H2O2','H2O','CH4','N2O','CO','C2H2','C2H4','C2H6','C3H8','C2H5OH',
                    'HCFC22','CCL4','CFC11','CFC12','CFC113','CH2BRCL','CH3CL','CH3BR','CH3I',
                    'CH3CCL3','CH3CHO','CH3OH','CH3CN','HCN','NOX','NOY','PAN','HNO3',
                    'CH3COCH3','ISOP','TOLUENE','SO2','SO4'] 
        summary_list = ['cset6_emmons_O3_HOx_summary_2_7.png',
                        'cset6_emmons_O3_HOx_summary_0_3.png',
                        'cset6_emmons_NOY_summary_2_7.png',
                        'cset6_emmons_NOY_summary_0_3.png',
                        'cset6_emmons_CO_HDC_summary_2_7.png',
                        'cset6_emmons_CO_HDC_summary_0_3.png',
                        'cset6_emmons_VOC_Aerosol_summary_2_7.png',
                        'cset6_emmons_VOC_Aerosol_summary_0_3.png']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        for region in regions:
            for var in var_list:
                #for seas in env['seas']: #The original set loops over seasons, but only ANN is currently called
                self.expectedPlots.append(pref+region+'_ANN_'+var+'_profiles'+suf)
        for name in summary_list:
            self.expectedPlots.append(name)

        # Set plot class description variables
        self._name = 'CSET 6 - COMPARISON TO EMMONS Aircraft Climatology'
        self._shortname = 'CSET6'
        self._template_file = 'cset6.tmpl'
        self.ncl_scripts = ['profiles_aircraft_emmons.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['DATA_PLOTVARS'] = env['test_path_diag']+'/data_aircraft_plotvars.nc'
        self.plot_env['TEST_CASE'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+'_aircraft_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['STD_CASE'] = 'NONE' 
        else:
            self.plot_env['STD_CASE'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.' 
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+'_aircraft_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'
