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

class Set10(AtmosphereDiagnosticPlot):
    """DIAG Set 10 - Annual cycle line plots 
    """

    def __init__(self,env):
        super(Set10, self).__init__()

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set10_'

        # Obs data: variable names
        mo_vars = {'WILLMOTT'        :['TREFHT'],
                   'TRMM'            :['PRECT'],
                   'HADISST'         :['SST'],
                   'HADISST_NP'      :['ICEFRAC'],
                   'HADISST_SP'      :['ICEFRAC'],
                   'LEGATES'         :['TREFHT','PRECT'],
                   'JRA25'           :['TREFHT','PREH2O','PSL','SHFLX','T_850','T_200','U_200','Z3_500','Z3_300'],
                   'GPCP'            :['PRECT'],
                   'XA'              :['PRECT'],
                   'SSMI'            :['PRECT','PREH2O'],
                   'SSMI_NP'         :['ICEFRAC'],
                   'SSMI_SP'         :['ICEFRAC'],
                   'MERRA'           :['PREH2O','PSL','T_850','T_200','TS','U_200','Z3_500','Z3_300'],
                   'ERAI'            :['PREH2O','T_850','T_200','U_200','Z3_500','Z3_300'],
                   'ERA40'           :['EP','PREH2O','LHFLX','QFLX','T_850','T_200','U_200','Z3_500','Z3_300'],
                   'NVAP'            :['PREH2O','TGCLDLWP'],
                   'AIRS'            :['T_850','T_200'],
                   'LARYEA'          :['SHFLX','QFLX','FLNS','FSNS'],
                   'WHOI'            :['LHFLX','QFLX'],
                   'UWISC'           :['TGCLDLWP'],
                   'ISCCP'           :['FLNS','FSNS','FLDS','FSDS','CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'CERES-EBAF'      :['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF','ALBEDO','ALBEDOC'],
                   'ERBE'            :['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF','RESTOA'],
                   'CERES'           :['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF','ALBEDO','ALBEDOC'],
                   'VISIR'           :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'CAL'             :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'ISCCPCOSP'       :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK','MEANPTOP','MEANCLDALB'],
                   'MISR'            :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
                   'MODIS'           :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
                   'CS2'             :['CLDTOT'] }
        mo_extra = ['CLIMODIS','CLWMODIS','IWPMODIS','LWPMODIS','PCTMODIS','REFFCLIMODIS','REFFCLWMODIS',
                    'TAUILOGMODIS','TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS','TAUWMODIS','TAUTMODIS']

        # model vs model variable names
        mm_vars = ['PBLH','PSL','TREFHT','TS','CHI_200','EKE_850','PSI_200',
                   'T_850','T_200','U_200','VT_850','Z3_500','Z3_300','EP','ICEFRAC_NP','ICEFRAC_SP',
                   'PRECST_NP','PRECST_SP','PRECT','PREH2O','QFLX','SNOWHICE_NP','SNOWHICE_SP',
                   'SNOWHLND_NP','SNOWHLND_SP','FLDS','FLNS','FLNSC','FSDS','FSNS','FSNSC','LHFLX','RESSURF','SHFLX',
                   'LHFLX','RESSURF','SHFLX','FLNT','FLNTC','FSNT','FSNTC',
                   'LWCF','SOLIN','SWCF','CLDHGH','CLDLOW','CLDMED','CLDTOT','TGCLDIWP','TGCLDLWP',
                   'CLDTOT_CAL','CLDLOW_CAL','CLDMED_CAL','CLDHGH_CAL',
                   'CLDTOT_CS2','CLDTOT_ISCCPCOSP','CLDLOW_ISCCPCOSP','CLDMED_ISCCPCOSP',
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
        self._name = 'DIAG Set 10 - LAT/LONG CONTOUR PLOTS'
        self._shortname = 'SET10'
        self._template_file = 'set10.tmpl'
        self.ncl_scripts = []
        self.ncl_scripts = ['plot_seas_cycle.ncl']
        self.plot_env = env.copy() 

        # Since this plot set is computationally intensive, we will add weight to it to load balance properly
        self.weight = 4

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+'plot10_'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+'plot10_'
        self.plot_env['NCDF_MODE'] = 'create'

