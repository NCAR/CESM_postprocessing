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

class Set9(AtmosphereDiagnosticPlot):
    """DIAG Set 9 - DJF-JJA LAT/LONG PLOTS 
    """

    def __init__(self,env):
        super(Set9, self).__init__()

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set9_'

        # Obs data: variable names
        mo_vars = {'JRA25'           :['PREH2O','T_850'],
                   'LEGATES'         :['TREFHT'],
                   'AIRS'            :['T_850'],
                   'XA'              :['PRECT'],
                   'MERRA'           :['PREH2O','PSL','T_850'],
                   'ERAI'            :['PREH2O','T_850'],
                   'ERA40'           :['PREH2O','T_850'],
                   'NVAP'            :['PREH2O'],
                   'GPCP'            :['PRECT'],
                   'CERES-EBAF'      :['LWCF','SWCF'],
                   'CERES'           :['LWCF','SWCF'],
                   'ERBE'            :['LWCF','SWCF'],
                   'CLOUDSAT'        :['CLDTOT'],
                   'ISCCP'           :['CLDTOT'] }

        # model vs model variable names
        mm_vars = ['CLDTOT','LWCF','PRECT','PREH2O','PSL','SWCF','T_850','TREFHT']

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
        self._name = 'DIAG Set 9 - DJF-JJA LAT/LONG PLOTS'
        self._shortname = 'SET9'
        self._template_file = 'set9.tmpl'
        self.ncl_scripts = []
        self.ncl_scripts = ['plot_seasonal_diff.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename'] + '.'+env['test_modelstream']+'.'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+'_plot9_'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+'_plot9_'
        self.plot_env['NCDF_DJF_MODE'] = 'create'
        self.plot_env['NCDF_JJA_MODE'] = 'create'

