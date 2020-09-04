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

class CSet2(AtmosphereDiagnosticPlot):
    """CSET 2 - LAT/PRESS CONTOUR PLOTS 
    """

    def __init__(self, seas,env):
        super(CSet2, self).__init__()
        # Requires a season
        self.seas = seas

        # Derive all of the plot names
        suf = ['_c.png']
        if 'OBS' in env['CNTL']:
            suf.append('_perc_c.png')
        pref = 'cset2_'+seas+'_'

        # Model vs. obs variables
        mo_vars = ['O3','CO','Q','OH','H2O2','N2O','HNO3','NOY','NOx_NOy','PAN','C2H2','C2H6','C3H6',
                   'SO2','SO4','BC','OC','DUST','SSALT','SAD_TROP']

        # Model vs. model variables
        mm_vars = ['O3','CO','Q','OH','H2O2','N2O','HNO3','NOY','NOX','NOx_NOy','PAN','C3H8','CH3COCH3',
                   'CH3OH','CH2O','C2H2','C2H6','C3H6','SO2','SO4','BC','OC','SOA','DUST','SSALT',
                   'SAD_TROP','SAD_LNAT','SAD_SULFC','SAD_ICE']
        chem_mm_vars = ['jo3_a','jno2','jpan','jh2o2']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        if 'OBS' in env['CNTL']:
            for var in mo_vars:
                self.expectedPlots.append(pref+var+suf[0])
        else:
            for var in mm_vars:
                for s in suf:
                    self.expectedPlots.append(pref+var+s)
            for var in chem_mm_vars:
                self.expectedPlots.append(pref+var+suf[0])

        # Set plot class description variables
        self._name = 'CSET 2 - LAT/PRESS CONTOUR PLOTS'
        self._shortname = 'CSET2'
        self._template_file = 'cset2.tmpl'
        self.ncl_scripts = ['plot_vertical_zonal_mean_chem.ncl','plot_vertical_zonal_mean_chem_perc.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['SEASON'] = self.seas
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_climo.nc'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'cset2_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_climo.nc'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'cset2_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'
