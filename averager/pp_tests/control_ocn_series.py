#!/usr/bin/env python

from __future__ import print_function
import sys

# check the system python version and require 3.7.x or greater                                                                                                              
if sys.hexversion < 0x03070000:
    print(70 * '*')
    print('ERROR: {0} requires python >= 3.7.x. '.format(sys.argv[0]))
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

in_dir='/glade/scratch/aliceb/BRCP85C5CN_ne120_t12_pop62.c13b17.asdphys.001/ocn/proc/tseries/monthly'
out_dir= '/glade/scratch/aliceb/BRCP85C5CN_ne120_t12_pop62.c13b17.asdphys.001/ocn/proc/tavg.2041.2050'
pref= 'BRCP85C5CN_ne120_t12_pop62.c13b17.asdphys.001.pop.h'
htype= 'series'
average = ['hor.meanConcat:2041:2050']
wght= False
ncfrmt = 'netcdfLarge'
serial=False

#var_list = ['TEMP','SALT','PD','UVEL','VVEL','WVEL','IAGE','TAUX','TAUY','SSH','HMXL','HBLT','SFWF','PREC_F','MELT_F','MELTH_F','SHF','SHF_QSW','SENH_F','QFLUX','SNOW_F','SALT_F','EVAP_F','ROFF_F','LWUP_F','LWDN_F']
region_nc_var = 'REGION_MASK'
regions={1:'Sou',2:'Pac',3:'Ind',6:'Atl',8:'Lab',9:'Gin',10:'Arc',11:'Hud',0:'Glo'}
region_wgt_var = 'TAREA'
var_list = ['TEMP', 'SALT']
mean_diff_rms_obs_dir = '/glade/p/cesm/omwg/timeseries_obs_tx0.1v2_62lev/'
region_nc_var = 'REGION_MASK'
obs_dir = '/glade/p/cesm/omwg/timeseries_obs_tx0.1v2_62lev/'
obs_file = 'obs.nc'
reg_obs_file_suffix = '_hor_mean_obs.nc'
vertical_levels = 62

clobber = False
suffix = 'nc'
date_pattern= 'yyyymm-yyyymm'

#### End user modify ####

pyAveSpecifier = specification.create_specifier(in_directory=in_dir,
			          out_directory=out_dir,
				  prefix=pref,
                                  suffix=suffix,
                                  date_pattern=date_pattern,
				  hist_type=htype,
				  avg_list=average,
				  weighted=wght,
				  ncformat=ncfrmt,
                                  varlist=var_list,
                                  serial=serial,
                                  clobber=clobber,
                                  mean_diff_rms_obs_dir=mean_diff_rms_obs_dir,
                                  region_nc_var=region_nc_var,
                                  regions=regions,
                                  region_wgt_var=region_wgt_var,
                                  obs_dir=obs_dir,
                                  obs_file=obs_file,
                                  reg_obs_file_suffix=reg_obs_file_suffix,
                                  vertical_levels=vertical_levels)
PyAverager.run_pyAverager(pyAveSpecifier)

