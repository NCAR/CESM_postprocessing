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
from .atm_diags_plot_bc import AtmosphereDiagnosticPlot

class Set4(AtmosphereDiagnosticPlot):
    """DIAG Set 4 - LAT/PRESS CONTOUR PLOTS 
    """

    def __init__(self, seas,env):
        super(Set4, self).__init__()
        # Requires a season
        self.seas = seas

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set4_'+seas+'_'

        # Obs data: variable names
        mo_vars = {'JRA25'     :['OMEGA','SHUM','T','U'],
                   'MERRA'     :['OMEGA','RELHUM','SHUM','T','U'],
                   'ERAI'      :['OMEGA','RELHUM','SHUM','T'],
                   'ERA40'     :['OMEGA','RELHUM','SHUM','T','U'],
                   'AIRS'      :['RELHUM','SHUM','T'],
                   'DBZE94_CS' :['CFAD'] }

        # model vs model variable names
        mm_vars = ['OMEGA','QRL','QRS','RELHUM','SHUM','T','TDH','TDM','U','VQ','VT','ZMMSF','EKE','OBSTAR_TBSTAR',
                    'OPTP_BAR','VBSTAR_QBSTAR','VPQP_BAR','VBSTAR_TBSTAR','VPTP_BAR','VBSTAR_UBSTAR','VPUP_BAR',
                    'CLOUD','CWAT','CLDLIQ','CLDICE','GCLDLWP_ICE','GCLDLWP_LIQUID','ICLDTWP','ICWMR','ICIMR',
                    'SIWC','WSUB','CCN3','AWNC','AWNI','AREL','AREI','AQRAIN','AQSNOW','ANRAIN','ANSNOW','CFAD_DBZE94_CS']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        if 'OBS' in env['CNTL']:
            for ob_set,var_list in mo_vars.items():
                for var in var_list:
                    self.expectedPlots.append(pref+var+'_'+ob_set+suf)
        else:
            for var in mm_vars:
                self.expectedPlots.append(pref+var+suf)
 
        # Set plot class description variables
        self._name = 'DIAG Set 4 - LAT/PRESS CONTOUR PLOTS'
        self._shortname = 'SET4'
        self._template_file = 'set4.tmpl'
        self.ncl_scripts = ['plot_vertical_cons.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['SEASON'] = self.seas
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_climo.nc'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'plot4_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_climo.nc'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'plot4_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'
