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

class Set8(AtmosphereDiagnosticPlot):
    """DIAG Set 8 - ZONAL ANNUAL CYCLE PLOTS 
    """

    def __init__(self,env):
        super(Set8, self).__init__()

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set8_'

        # Obs data: variable names
        mo_vars = {'JRA25'           :['PREH2O','U_200'],
                   'XA'              :['PRECT'],
                   'MERRA'           :['PREH2O','U_200'],
                   'ERAI'            :['PREH2O','U_200'],
                   'ERA40'           :['PREH2O','U_200'],
                   'NVAP'            :['PREH2O'],
                   'GPCP'            :['PRECT'],
                   'CERES-EBAF'      :['FLUT'],
                   'CERES'           :['FLUT'],
                   'ERBE'            :['FLUT'],
                   'CAL'             :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'ISCCPCOSP'       :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK','MEANPTOP','MEANCLDALB'],
                   'MODIS'           :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
                   'MISR'            :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
                   'CS2'             :['CLDTOT'] }
        mo_extra = ['CLIMODIS','CLWMODIS','IWPMODIS','LWPMODIS','PCTMODIS','REFFCLIMODIS','REFFCLWMODIS',
                    'TAUILOGMODIS','TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS','TAUWMODIS','TAUTMODIS']

        # model vs model variable names
        mm_vars = ['FLNT','PRECT','PREH2O','SOLIN','TAUX_OCEAN','U_200','CLDTOT_CAL','CLDLOW_CAL',
                   'CLDMED_CAL','CLDHGH_CAL','CLDTOT_CS2','CLDTOT_ISCCPCOSP','CLDLOW_ISCCPCOSP',
                   'CLDMED_ISCCPCOSP','CLDHGH_ISCCPCOSP','CLDTHICK_ISCCPCOSP','MEANPTOP_ISCCPCOSP',
                   'MEANCLDALB_ISCCPCOSP','CLDTOT_MISR','CLDLOW_MISR','CLDMED_MISR','CLDHGH_MISR',
                   'CLDTHICK_MISR','CLDTOT_MODIS','CLDLOW_MODIS','CLDMED_MODIS','CLDHGH_MODIS',
                   'CLDTHICK_MODIS', 'CLIMODIS','CLWMODIS',
                   'IWPMODIS','LWPMODIS','PCTMODIS','REFFCLIMODIS','REFFCLWMODIS','TAUILOGMODIS',
                   'TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS','TAUWMODIS','TAUTMODIS']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        if 'OBS' in env['CNTL']:
            for ob_set,var_list in mo_vars.items():
                for var in var_list:
                    self.expectedPlots.append(pref+var+'_'+ob_set+suf)
            for t in mo_extra:
                self.expectedPlots.append(pref+t+suf)
        else:
            for var in mm_vars:
                self.expectedPlots.append(pref+var+suf)

        # Set plot class description variables
        self._name = 'DIAG Set 8 - ZONAL ANNUAL CYCLE PLOTS'
        self._shortname = 'SET8'
        self._template_file = 'set8.tmpl'
        self.ncl_scripts = []
        self.ncl_scripts = ['plot_ann_cycle.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+ '.'+env['test_modelstream']+'.'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+'_MONTHS_plot8_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+'_MONTHS_plot8_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'

