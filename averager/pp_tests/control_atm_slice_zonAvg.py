#!/usr/bin/env python2

from __future__ import print_function
import sys

# check the system python version and require 2.7.x or greater                                                                                                              
if sys.hexversion < 0x02070000:
    print(70 * '*')
    print('ERROR: {0} requires python >= 2.7.x. '.format(sys.argv[0]))
    print('It appears that you are running python {0}'.format(
            '.'.join(str(x) for x in sys.version_info[0:3])))
    print(70 * '*')
    sys.exit(1)

import os

#
# check the POSTPROCESS_PATH which must be set
#
try:
    os.environ["POSTPROCESS_PATH"]
except KeyError:
    err_msg = ('create_postprocess ERROR: please set the POSTPROCESS_PATH environment variable.' \
                   ' For example on yellowstone: setenv POSTPROCESS_PATH /glade/p/cesm/postprocessing')
    raise OSError(err_msg)

cesm_pp_path = os.environ["POSTPROCESS_PATH"]

#
# activate the virtual environment that was created by create_python_env
#
if not os.path.isfile('{0}/cesm-env2/bin/activate_this.py'.format(cesm_pp_path)):
    err_msg = ('create_postprocess ERROR: the virtual environment cesm-env2 does not exist.' \
                   ' Please run $POSTPROCESS_PATH/create_python_env -machine [machine name]')
    raise OSError(err_msg)

execfile('{0}/cesm-env2/bin/activate_this.py'.format(cesm_pp_path), dict(__file__='{0}/cesm-env2/bin/activate_this.py'.format(cesm_pp_path)))

from pyaverager import PyAverager, specification

#### User modify ####

in_dir='/glade/scratch/bardeenc/archive/mike_simone_trop/atm/hist'
out_dir= '/glade/scratch/aliceb/mike_simone_trop/atm/proc/climo'
pref= 'mike_simone_trop.cam.h0'
htype= 'slice'
##average= ['zonalavg:2011:2011']
average = ['dep_ann:2011:2011', 'dep_djf:2011:2011', 'dep_mam:2011:2011', 'dep_jja:2011:2011', 'dep_son:2011:2011', 'jan:2011:2011', 'feb:2011:2011', 'mar:2011:2011', 'apr:2011:2011', 'may:2011:2011', 'jun:2011:2011', 'jul:2011:2011', 'aug:2011:2011', 'sep:2011:2011', 'oct:2011:2011', 'nov:2011:2011', 'dec:2011:2011', 'zonalavg:2011:2011']
##average = ['dep_ann:2011:2011', 'dep_djf:2011:2011', 'dep_mam:2011:2011', 'dep_jja:2011:2011', 'dep_son:2011:2011', 'jan:2011:2011', 'feb:2011:2011', 'mar:2011:2011', 'apr:2011:2011', 'may:2011:2011', 'jun:2011:2011', 'jul:2011:2011', 'aug:2011:2011', 'sep:2011:2011', 'oct:2011:2011', 'nov:2011:2011', 'dec:2011:2011']
collapse_dim = 'lon'
wght= False
ncfrmt = 'netcdfLarge'
serial=False
suffix = 'nc'
clobber = True
date_pattern= 'yyyymm-yyyymm'


required_vars =    ['AODVIS','AODDUST','AODDUST1','AODDUST2','AODDUST3','ANRAIN','ANSNOW','AQRAIN','AQSNOW',
                    'AREI','AREL','AWNC','AWNI','CCN3','CDNUMC','CLDHGH','CLDICE','CLDLIQ','CLDMED','CLDLOW',
                    'CLDTOT','CLOUD','DCQ','DTCOND','DTV','FICE','FLDS','FLNS','FLNSC','FLNT','FLNTC','FLUT',
                    'FLUTC','FREQI','FREQL','FREQR','FREQS','FSDS','FSDSC','FSNS','FSNSC','FSNTC','FSNTOA',
                    'FSNTOAC','FSNT','ICEFRAC','ICIMR','ICWMR','IWC','LANDFRAC','LHFLX','LWCF','NUMICE','NUMLIQ',
                    'OCNFRAC','OMEGA','OMEGAT','PBLH','PRECC','PRECL','PRECSC','PRECSL','PS','PSL','Q',
                    'QFLX','QRL','QRS','RELHUM','SHFLX','SNOWHICE','SNOWHLND','SOLIN','SWCF','T','TAUX','TAUY',
                    'TGCLDIWP','TGCLDLWP','TMQ','TREFHT','TS','U','UU','V','VD01','VQ','VT','VU','VV','WSUB','Z3',
                    'CLD_MISR','FMISR1','FISCCP1_COSP','FISCCP1','CLDTOT_ISCCP','MEANPTOP_ISCCP','MEANCLDALB_ISCCP',
                    'CLMODIS','FMODIS1','CLTMODIS','CLLMODIS','CLMMODIS','CLHMODIS','CLWMODIS','CLIMODIS','IWPMODIS',
                    'LWPMODIS','REFFCLIMODIS','REFFCLWMODIS','TAUILOGMODIS','TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS',
                    'TAUWMODIS','TAUTMODIS','PCTMODIS','CFAD_DBZE94_CS','CFAD_SR532_CAL','CLDTOT_CAL','CLDLOW_CAL',
                    'CLDMED_CAL','CLDHGH_CAL','CLDTOT_CS2','U10','ICLDTWP','ICLDIWP']
cam_chem_vars =    ['CH4','CH4_CHML','SFCH4','CO','CO_CHMP','CO_CHML','SFCO','DCOCHM','DF_CO','O3','O3_Prod','O3_Loss',
                    'O3_CHMP','O3_CHML','DF_O3','CH3CCL3','CH3CCL3_CHML','ISOP','C10H16','LNO_COL_PROD','SFISOP','SFC10H16',
                    'SFCH3OH','SFC2H2','SFCH3COCH3','PHIS','ODV_DST01','ODV_DST02','ODV_DST03','ODV_DST04','AODDUST1',
                    'AODDUST2','AODDUST3','AEROD_v','SFO3','DO3CHM','NO','NO2','NOX','NOY','H2O','Q','OH','H2O2','N2O','HNO3',
                    'PAN','C3H8','CH3COCH3','CH2O','CH3OH','C2H2','C2H6','C3H6','SO2','SO4','CB1','CB2','OC1','OC2','SOA',
                    'SOAI','SOAM','SOAX','SOAB','SOAT','NH4NO3','SOAI_PROD','SOAM_PROD','SOAX_PROD','SOAB_PROD','SOAT_PROD',
                    'CB2SFWET','OC2SFWET','OC2WET','SO4SFWET','SOAISFWET','SOATSFWET','SOABSFWET','SOAXSFWET','SOAMSFWET',
                    'DST01','DST02','DST03','DST04','SSLT01','SSLT02','SSLT03','SSLT04','SAD_TROP','SAD_ICE','SAD_LNAT',
                    'SAD_SULFC','SAD_SO4NIT','SAD_SOA','SAD_BC','jo3_a','jno2','jpan','jh2o2','SFSSLT01','SFSSLT02','SFSSLT03',
                    'SFSSLT04','SFDST01','SFDST02','SFDST03','SFDST04','DST01SFWET','','DST02SFWET','','DST03SFWET','',
                    'DST04SFWET','SSLT01SFWET','SSLT02SFWET','SSLT03SFWET','SSLT04SFWET','SFSO4','SO4_CHMP','SO4_CHML','DSO4CHM',
                    'DTWR_SO2','DF_DST01','DF_DST02','DF_DST03','DF_DST04','DF_SSLT01','DF_SSLT02','DF_SSLT03','DF_SSLT04','DF_OC1',
                    'DF_OC2','DF_CB1','DF_CB2','DF_SOAM','DF_SOAI','DF_SOAT','DF_SOAB','DF_SOAX','DF_SO4','a2x_DSTWET1',
                    'a2x_DSTWET2','a2x_DSTWET3','a2x_DSTWET4','CB1_CLXF','SFCB1','SFCB2','SFOC1','SFOC2','AQSO4_H2O2',
                    'AQSO4_O3','soa_a1','soa_a2','soa_c1','soa_c2','dst_a1','dst_a3','dst_a5','dst_a7','dst_c1','dst_c3','dst_c5',
                    'dst_c7','ncl_a1','ncl_a2','ncl_a3','ncl_a4','ncl_a6','ncl_c1','ncl_a2','ncl_c3','ncl_c4','ncl_c6','pom_a1',
                    'pom_c1','pom_a3','pom_c3','pom_a4','pom_c4','bc_a1','bc_a3','bc_a4','bc_c1','bc_c3','bc_c4','so4_a1','so4_a2',
                    'so4_a3','so4_a4','so4_a5','so4_a6','so4_a7','so4_c1','so4_c2','so4_c3','so4_c4','so4_c5','so4_c6','so4_c7',
                    'SFpom_a1','SFpom_a3','SFpom_a4','pom_a1_CLXF','pom_a2_CLXF','pom_a4_CLXF','pom_a1DDF','pom_a2DDF','pom_a4DDF',
                    'pom_a1SFWET','pom_a2SFWET','pom_a4SFWET','pom_c1DDF','pom_c2DDF','pom_c4DDF','','pom_c1SFWET','pom_c2SFWET',
                    'pom_c4SFWET','SFbc_a1','SFbc_a3','SFbc_a4','bc_a1_CLXF','bc_a2_CLXF','bc_a4_CLXF','bc_a1DDF',
                    'bc_a2DDF','bc_a4DDF','','bc_a1SFWET','bc_a2SFWET','bc_a4SFWET','bc_c1DDF','bc_c2DDF','bc_c4DDF','bc_c1SFWET',
                    'bc_c2SFWET','bc_c4SFWET','soa_a1_sfgaex1','soa_a2_sfgaex1','','soa_a1DDF','soa_a2DDF','soa_a1SFWET',
                    'soa_a2SFWET','soa_c1DDF','soa_c2DDF','soa_c1SFWET','soa_c2SFWET','dst_a1SFWET','dst_a3SFWET','dst_a5SFWET',
                    'dst_a7SFWET','dst_a1DDF','dst_a3DDF','dst_a5DDF','dst_a7DDF','dst_c1SFWET','dst_c3SFWET','dst_c5SFWET',
                    'dst_c7SFWET','dst_c1DDF','dst_c3DDF','dst_c5DDF','dst_c7DDF','ncl_a1SFWET','ncl_a2SFWET','ncl_a3SFWET',
                    'ncl_a4SFWET','ncl_a6SFWET','ncl_a1DDF','ncl_a3DDF','ncl_a4DDF','ncl_a6DDF','ncl_c1SFWET','ncl_c2SFWET',
                    'ncl_c3SFWET','ncl_c4SFWET','ncl_c6SFWET','ncl_c1DDF','ncl_c3DDF','ncl_c4DDF','ncl_c6DDF','SFdst_a1',
                    'SFdst_a3','SFdst_a5','SFdst_a7','SFncl_a1','SFncl_a2','SFncl_a3','SFncl_a4','SFncl_a6','so4_a1_CHMP','so4_a2_CHMP',
                    'so4_a3_CHMP','so4_a4_CHMP','so4_a5_CHMP','so4_a6_CHMP','so4_a7_CHMP','SFso4_a1','SFso4_a2','SFso4_a3','SFso4_a4',
                    'SFso4_a5','SFso4_a6','SFso4_a7','so4_a1_CLXF','so4_a2_CLXF','so4_a3_CLXF','so4_a4_CLXF','so4_a5_CLXF','so4_a6_CLXF',
                    'so4_a7_CLXF','so4_a1_sfgaex1','so4_a2_sfgaex1','so4_a3_sfgaex1','so4_a4_sfgaex1','so4_a5_sfgaex1','so4_a6_sfgaex1',
                    'so4_a7_sfgaex1','so4_a1_sfnnuc1','so4_a2_sfnnuc1','so4_a3_sfnnuc1','so4_a4_sfnnuc1','so4_a5_sfnnuc1','so4_a6_sfnnuc1',
                    'so4_a7_sfnnuc1','so4_a1DDF','so4_a2DDF','so4_a3DDF','so4_a4DDF','so4_a5DDF','so4_a6DDF','so4_a7DDF','so4_a1SFWET',
                    'so4_a2SFWET','so4_a3SFWET','so4_a4SFWET','so4_a5SFWET','so4_a6SFWET','so4_a7SFWET','so4_c1DDF','so4_c2DDF',
                    'so4_c3DDF','so4_c4DDF','so4_c5DDF','so4_c6DDF','so4_c7DDF','so4_c1SFWET','so4_c2SFWET','so4_c3SFWET','so4_c4SFWET',
                    'so4_c5SFWET','so4_c6SFWET','so4_c7SFWET']
waccm_vars =       ['QRS_TOT', 'QRL_TOT']

var_list = []
fileVars = []

key_infile = '{0}/mike_simone_trop.cam.h0.2011-01.nc'.format(in_dir)

# Get a list of variables that we have input data for
import Nio
    
# Open file and get all variable names 
f = Nio.open_file(key_infile,'r')
fileVars = f.variables.keys()

# Loop through the requried vars to see which are located in the files
for var in required_vars:
    if var in fileVars:
            var_list.append(var) # Found in in_files, add to the var_list

    # Loop through cam_chem_vars if users are plotting these sets, then add those variables to the list if we have data for them
    #if all_chem_sets or cset_1 or cset_2 or cset_3 or cset_4 or cset_5 or cset_6 or cset_7:
for var in cam_chem_vars:
    if var in fileVars:
        var_list.append(var) # Found in in_files, add to the var_list 

for var in waccm_vars:
    if var in fileVars:
        var_list.append(var) # Found in in_files, add to the var_list 

#### End user modify ####

pyAveSpecifier = specification.create_specifier(in_directory=in_dir,
			          out_directory=out_dir,
				  prefix=pref,
                                  suffix=suffix,
                                  date_pattern=date_pattern,
				  hist_type=htype,
				  avg_list=average,
				  varlist=var_list,
                                  collapse_dim=collapse_dim,
				  weighted=wght,
				  ncformat=ncfrmt,
				  serial=serial,
                                  clobber=clobber)

PyAverager.run_pyAverager(pyAveSpecifier)

