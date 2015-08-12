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

class Set4a(AtmosphereDiagnosticPlot):
    """DIAG Set 4a - LON/PRESS CONTOUR PLOTS (10N-10S) 
    """

    def __init__(self, seas,env):
        super(Set4a, self).__init__()
        # Requires a season
        self.seas = seas

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set4a_'+seas+'_'

        # Obs data: variable names
        mo_vars = {'JRA25'     :['SHUM','T','U'],
                   'MERRA'     :['OMEGA','RELHUM','SHUM','T','U'],
                   'ERAI'      :['OMEGA','RELHUM','SHUM','T'],
                   'ERA40'     :['OMEGA','RELHUM','SHUM','T','U'],
                   'AIRS'      :['RELHUM','SHUM','T'] }

        # model vs model variable names
        mm_vars = ['CLOUD','CWAT','EKE','GCLDLWP_ICE','GCLDLWP_LIQUID','ICLDTWP','OBSTAR_TBSTAR','OMEGA',
                    'OPTP_BAR','RELHUM','SHUM','T','TDH','TDM','UBSTAR_QBSTAR','UBSTAR_TBSTAR',
                    'U','VBSTAR_UBSTAR','VPUP_BAR']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        if 'OBS' in env['CNTL']:
            for ob_set,var_list in mo_vars.iteritems():
                for var in var_list:
                    self.expectedPlots.append(pref+var+'_'+ob_set+suf)
        else:
            for var in mm_vars:
                self.expectedPlots.append(pref+var+suf)

        # Set plot class description variables
        self._name = 'DIAG Set 4a - LON/PRESS CONTOUR PLOTS (10N-10S)'
        self._shortname = 'SET4a'
        self._template_file = 'set4a.tmpl'
        self.ncl_scripts = ['plot_vertical_xz_cons.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['SEASON'] = self.seas
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_climo.nc'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'plot4a_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_climo.nc'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'plot4a_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'
