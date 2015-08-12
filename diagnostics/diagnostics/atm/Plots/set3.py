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

class Set3(AtmosphereDiagnosticPlot):
    """DIAG Set 3 - ZONAL LINE PLOTS 
    """

    def __init__(self, seas,env):
        super(Set3, self).__init__()
        # Requires a season
        self.seas = seas

        # Derive all of the plot names
        if 'OBS' in env['CNTL']:
            suf = '_obsc.'+env['p_type'] 
        else:
            suf = '_c.'+env['p_type']
        pref = 'set3_'+seas+'_'

        # Obs data: variable names
        mo_vars = {'CRU'       :['TREFHT'],
                   'WILLMOTT'  :['TREFHT'],
                   'LEGATES'   :['TREFHT','PRECT'],
                   'JRA25'     :['TREFHT','PREH2O','PSL','SHFLX','LHFLX'],
                   'GPCP'      :['PRECT'],
                   'XA'        :['PRECT'],
                   'SSMI'      :['PRECT'],
                   'TRMM'      :['PRECT'],
                   'MERRA'     :['PREH2O','PSL'],
                   'ERAI'      :['PREH2O','PSL'],
                   'ERA40'     :['PREH2O','LHFLX'],
                   'NVAP'      :['PREH2O','TGCLDLWP'],
                   'AIRS'      :['PREH2O'],
                   'SSMI'      :['PREH2O'],
                   'LARYEA'    :['SHFLX','QFLX','FLNS','FSNS'],
                   'WHOI'      :['LHFLX','QFLX'],
                   'UWISC'     :['TGCLDLWP'],
                   'ISCCP'     :['FLNS','FSNS','FLDS','FLDSC','FLNSC','FSDS','FSDSC','LWCFSRF','SWCFSRF','CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'CERES-EBAF':['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF'],
                   'CERES'     :['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF'],
                   'ERBE'      :['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF'],
                   'VISIR'     :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'CLOUDSAT'  :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'CAL'       :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
                   'ISCCPCOSP' :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK','MEANPTOP','MEANCLDALB'],
                   'MISR'      :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
                   'MODIS'     :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
                   'WARREN'    :['CLDLOW','CLDTOT'],
                   'CS2'       :['CLDTOT'] }
        mo_extra = ['CLIMODIS','CLWMODIS','IWPMODIS','LWPMODIS','PCTMODIS','REFFCLIMODIS','REFFCLWMODIS',
                    'TAUILOGMODIS','TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS','TAUWMODIS','TAUTMODIS']

        # model vs model variable names
        mm_vars = ['PBLH','PS','PSL','TAUX_OCEAN','TREFHT','TREFHT_LAND','TS','TS_LAND','EP','PRECT','PREH2O',
                   'QFLX','FLDS','FLDSC','FLNS','FLNSC','FSDS','FSDSC','FSNS','FSNSC','LHFLX','RESSURF',
                   'SHFLX','FLNT','FLNTC','FSNT','FSNTC','LWCF','RESTOM','SOLIN','SWCF','CLDHGH','CLDLOW',
                   'CLDMED','CLDTOT','TGCLDIWP','TGCLDLWP','TICLDIWP','TICLDLIQWP','TICLDLWP','VBSTAR_TBSTAR',
                   'VPTP_BAR','VBSTAR_QBSTAR','VPQP_BAR','VBSTAR_UBSTAR','VPUP_BAR','AODVIS','AODDUST',
                   'CLDTOT_CAL','CLDLOW_CAL','CLDMED_CAL','CLDHGH_CAL','CLDTOT_ISCCPCOSP','CLDTHICK_ISCCPCOSP',
                   'CLDTOT_MISR','CLDTHICK_MISR','CLDTOT_MODIS','CLDTHICK_MODIS','CLDTOT_CAL','CLDLOW_CAL',
                   'CLDMED_CAL','CLDHGH_CAL','CLDTOT_CS2','CLDTOT_ISCCPCOSP','CLDLOW_ISCCPCOSP','CLDMED_ISCCPCOSP',
                   'CLDHGH_ISCCPCOSP','CLDTHICK_ISCCPCOSP','MEANPTOP_ISCCPCOSP','MEANCLDALB_ISCCPCOSP',
                   'CLDTOT_MISR','CLDLOW_MISR','CLDMED_MISR','CLDHGH_MISR','CLDTHICK_MISR','CLDTOT_MODIS',
                   'CLDLOW_MODIS','CLDMED_MODIS','CLDHGH_MODIS','CLDTHICK_MODIS','CLIMODIS','CLWMODIS',
                   'IWPMODIS','LWPMODIS','PCTMODIS','REFFCLIMODIS','REFFCLWMODIS','TAUILOGMODIS',
                   'TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS','TAUWMODIS','TAUTMODIS']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        if 'OBS' in env['CNTL']:
            for ob_set,var_list in mo_vars.iteritems():
                for var in var_list:
                    self.expectedPlots.append(pref+var+'_'+ob_set+suf)
            for t in mo_extra:
                self.expectedPlots.append(pref+t+suf)
        else:
            for var in mm_vars:
                self.expectedPlots.append(pref+var+suf)

        # Set plot class description variables
        self._name = 'DIAG Set 3 - ZONAL LINE PLOTS'
        self._shortname = 'SET3'
        self._template_file = 'set3.tmpl'
        self.ncl_scripts = ['plot_zonal_lines.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env = env.copy()
        self.plot_env['SEASON'] = self.seas
        self.plot_env['TEST_INPUT'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'._'+self.seas+'_climo.nc'
        self.plot_env['TEST_PLOTVARS'] = env['test_path_diag']+'/'+env['test_casename']+self.seas+'plot3_plotvars.nc'
        if 'OBS' in env['CNTL']:
            self.plot_env['CNTL_INPUT'] = env['OBS_DATA']
        else:
            self.plot_env['CNTL_INPUT'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'._'+self.seas+'_climo.nc'
            self.plot_env['CNTL_PLOTVARS'] = env['test_path_diag']+'/'+env['cntl_casename']+self.seas+'plot3_plotvars.nc'
        self.plot_env['NCDF_MODE'] = 'create'
