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

class Set5(AtmosphereDiagnosticPlot):
    """DIAG Set 5 - LAT/LONG CONTOUR PLOTS 
    """

    def __init__(self, seas,env):
        super(Set5, self).__init__()
        # Requires a season
        self.seas = seas

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set5_'+seas+'_'

        # Obs data: variable names
        mo_vars = {'CRU'             :['TREFHT'],
                   'WILLMOTT'        :['TREFHT','PRECIP'],
                   'HADISST'         :['SST'],
                   'HADISST_PI'      :['SST'],
                   'HADISST_PD'      :['SST'],
                   'PRECL'           :['PRECT'],
                   'LEGATES'         :['TREFHT','PRECT'],
                   'LEGATES_TROP'    :['PRECT'],
                   'JRA25'           :['TREFHT','PREH2O','PSL','SHFLX','LHFLX','T_850','T_200','U_200','Z3_500','Z3_300'],
                   'JRA25_TROP'      :['PREH2O'],
                   'GPCP'            :['PRECT'],
                   'GPCP_TROP'       :['PRECT'],
                   'XA'              :['PRECT'],
                   'XA_TROP'         :['PRECT'],
                   'SSMI'            :['PRECT','PREH2O'],
                   'SSMI_TROP'       :['PRECT','PREH2O'],
                   'TRMM_TROP'       :['PRECT'],
                   'MERRA'           :['PREH2O','PSL','T_850','T_200','TS','U_200','Z3_500','Z3_300'],
                   'MERRA_TROP'      :['PREH2O'], 
                   'ERAI'            :['PREH2O','T_850','T_200','U_200','Z3_500','Z3_300','PRECT','LHFLX'],
                   'ERAI_TROP'       :['PREH2O','TTRP'],
                   'ERA40'           :['PREH2O','LHFLX','T_850','T_200','U_200','Z3_500','Z3_300'],
                   'ERA40_TROP'      :['PREH2O'],
                   'NVAP'            :['PREH2O','TGCLDLWP'],
                   'NVAP_TROP'       :['PREH2O','TGCLDLWP'],
                   'AIRS'            :['T_850','T_200'],
                   'LARYEA'          :['SHFLX','QFLX','FLNS','FSNS'],
                   'WHOI'            :['LHFLX','QFLX'],
                   'UWISC'           :['TGCLDLWP'],
                   'UWISC_TROP'      :['TGCLDLWP'],
                   'ISCCP'           :['FLNS','FLNSC','FSNS','FSNSC','FLDS','FLDSC','FLNSC','FSDS','FSDSC','LWCFSRF','SWCFSRF',
				       'CLDHGH','CLDLOW','CLDMED','CLDTOT','MEANPTOP','MEANTTOP','MEANTAU','TCLDAREA'],
                   'CERES-EBAF'      :['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF','ALBEDO','ALBEDOC'],
                   'CERES-EBAF_TROP' :['SWCF'],
                   'ERBE'            :['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF'],
                   'ERBE_TROP'       :['SWCF'],
                   'VISIR'           :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'CLOUDSAT'        :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'CAL'             :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'ISCCPCOSP'       :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK','MEANPTOP','MEANCLDALB'],
                   'MISR'            :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
                   'MODIS'           :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
                   'WARREN'          :['CLDLOW','CLDTOT'],
                   'CS2'             :['CLDTOT'] }
        mo_extra = ['CLIMODIS','CLWMODIS','IWPMODIS','LWPMODIS','PCTMODIS','REFFCLIMODIS','REFFCLWMODIS',
                    'TAUILOGMODIS','TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS','TAUWMODIS','TAUTMODIS']

        # model vs model variable names
        mm_vars = ['ALBSURF','PBLH','PS','PSL','TREFHT','TS','SST','CHI_200','EKE_850','PSI_200','TTRP_TROP',
                   'T_850','T_200','U_200','VT_850','Z3_500','Z3_300','EP','PRECIP','PRECT','PRECT_TROP',
                   'PREH2O','PREH2O_TROP','QFLX','FLDS','FLDSC','FLNS','FLNSC','FSDS','FSNS','FSNS_TROP',
                   'FSNSC','LHFLX','RESSURF','RESSURF_TROP','SHFLX','ALBEDO','ALBEDOC',
                   'FLNT','FLNTC','FSNT','FSNTC','LWCF','SOLIN','SWCF','SWCF_TROP','CLDHGH','CLDLOW',
                   'CLDMED','CLDTOT','TGCLDIWP','TGCLDLWP','TGCLDLWP_TROP','TICLDIWP','TICLDLIQWP',
                   'TICLDLWP','MEANPTOP','MEANTTOP','MEANTAU','TCLDAREA','AODVIS','AODDUST','SIWC_226','CDNUMC',
                   'CLDTOT_CAL','CLDLOW_CAL','CLDMED_CAL','CLDHGH_CAL','CLDTOT_ISCCPCOSP','CLDTHICK_ISCCPCOSP',
                   'CLDTOT_MISR','CLDTHICK_MISR','CLDTOT_MODIS','CLDTHICK_MODIS','CLDTOT_CS2'
                   'CLDTOT_ISCCPCOSP','CLDLOW_ISCCPCOSP','CLDMED_ISCCPCOSP',
                   'CLDHGH_ISCCPCOSP','CLDTHICK_ISCCPCOSP','MEANPTOP_ISCCPCOSP','MEANCLDALB_ISCCPCOSP',
                   'CLDTOT_MISR','CLDLOW_MISR','CLDMED_MISR','CLDHGH_MISR','CLDTHICK_MISR','CLDTOT_MODIS',
                   'CLDLOW_MODIS','CLDMED_MODIS','CLDHGH_MODIS','CLDTHICK_MODIS','CLIMODIS','CLWMODIS',
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
        self._name = 'DIAG Set 5 - LAT/LONG CONTOUR PLOTS'
        self._shortname = 'SET5'
        self._template_file = 'set5.tmpl'
        self.ncl_scripts = []
        self.ncl_scripts = ['plot_surfaces_cons.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['SEASON'] = self.seas
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_climo.nc'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'plot5_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_climo.nc'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'plot5_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'

        if env['significance'] == 'True':
            self.plot_env['TEST_MEANS'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_means.nc'
            self.plot_env['TEST_VARIANCE'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'plot5_variance.nc'
            self.plot_env['CNTL_MEANS'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_means.nc'
            self.plot_env['CNTL_VARIANCE'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'plot5_variance.nc'
            self.plot_env['VAR_MODE'] = 'create'
        else:
            self.plot_env['TEST_MEANS'] = 'null' 
            self.plot_env['TEST_VARIANCE'] = 'null' 
            self.plot_env['CNTL_MEANS'] = 'null' 
            self.plot_env['CNTL_VARIANCE'] = 'null' 
            self.plot_env['VAR_MODE'] = 'null'
            self.plot_env['SIG_LVL'] = 'null'
