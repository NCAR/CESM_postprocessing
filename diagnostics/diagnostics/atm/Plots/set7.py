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

class Set7(AtmosphereDiagnosticPlot):
    """DIAG Set 7 - POLAR CONTOUR AND VECTOR PLOTS 
    """

    def __init__(self, seas,env):
        super(Set7, self).__init__()
        # Requires a season
        self.seas = seas

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set7_'+seas+'_'

        # Obs data: variable names
        mo_vars = {'CRU'             :['TREFHT'],
                   'WILLMOTT'        :['TREFHT'],
                   'HADISST_CL'      :['SST','ICEFRAC'],
                   'HADISST_PI'      :['SST','ICEFRAC'],
                   'HADISST_PD'      :['SST','ICEFRAC'],
                   'JRA25'           :['PSL','Z3'],
                   'GPCP'            :['PRECT'],
                   'SSMI'            :['ICEFRAC'],
                   'MERRA'           :['PS','PSL','TS','Z3'],
                   'ERAI'            :['PSL','TS','WIND_MAG_SURF','Z3_500'],
                   'ERA40'           :['Z3_500'],
                   'LARYEA'          :['SHFLX','QFLX','FLNS','FSNS'],
                   'ISCCP'           :['FLDS','FLDSC','FLNS','FLNSC','FSDS','FSDSC','FSNS','FSNSC'],
                   'CERES-EBAF'      :['FLUT','FLUTC','FSNTOA','FSNTOAC','ALBEDO','ALBEDOC'],
                   'ERBE'            :['FLUT','FLUTC','FSNTOA','FSNTOAC'],
                   'CLOUDSAT'        :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'CAL'             :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'WARREN'          :['CLDLOW','CLDTOT'],
                   'CS2'             :['CLDTOT'] }

        # model vs model variable names
        mm_vars = ['ALBSURF','PS','PSL','WIND_MAG_SURF','TS','Z3_500','PRECT','PRECST','ICEFRAC','SNOWH','SNOWHICE',
                   'SNOWHLND','FLDS','FLDSC','FLNS','FLNSC','FSDS','FSDSC','FSNS','FSNSC','ALBEDO','ALBEDOC',
                   'FLNT','FSNT','CLDHGH','CLDLOW','CLDMED','CLDTOT','TGCLDIWP','TGCLDLWP','CLDTOT_CAL','CLDLOW_CAL',
                   'CLDMED_CAL','CLDHGH_CAL','CLDTOT_CS2']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        if 'OBS' in env['CNTL']:
            for ob_set,var_list in mo_vars.items():
                for var in var_list:
                    self.expectedPlots.append(pref+var+'_'+ob_set+'_NP_'+suf)
                    self.expectedPlots.append(pref+var+'_'+ob_set+'_SP_'+suf)
        else:
            for var in mm_vars:
                self.expectedPlots.append(pref+var+'_NP_'+suf)
                self.expectedPlots.append(pref+var+'_SP_'+suf)

        # Set plot class description variables
        self._name = 'DIAG Set 7 - POLAR CONTOUR AND VECTOR PLOTS'
        self._shortname = 'SET7'
        self._template_file = 'set7.tmpl'
        self.ncl_scripts = []
        self.ncl_scripts = ['plot_polar_cons.ncl','plot_polar_vecs.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['SEASON'] = self.seas
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_climo.nc'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'plot7_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_climo.nc'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'plot7_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'

        if env['significance'] == 'True':
            self.plot_env['TEST_MEANS'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_means.nc'
            self.plot_env['TEST_VARIANCE'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'plot7_variance.nc'
            self.plot_env['CNTL_MEANS'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_means.nc'
            self.plot_env['CNTL_VARIANCE'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'plot7_variance.nc'
            self.plot_env['VAR_MODE'] = 'create'
        else:
            self.plot_env['TEST_MEANS'] = 'null' 
            self.plot_env['TEST_VARIANCE'] = 'null' 
            self.plot_env['CNTL_MEANS'] = 'null' 
            self.plot_env['CNTL_VARIANCE'] = 'null' 
            self.plot_env['VAR_MODE'] = 'null'
            self.plot_env['SIG_LVL'] = 'null'
