#!/usr/bin/env python

from pyaverager import PyAverager, specification
import os

#### User modify ####

in_dir='/glade/p/tdd/asap/data/b.e12.B1850C5CN.ne30_g16.init.ch.027/ocn/mon/tseries/'
out_dir= os.environ.get('RESULTS_DIR')+'/ocn/series/'
pref= 'b.e12.B1850C5CN.ne30_g16.init.ch.027.pop.h'
htype= 'series'
average = ['ya:1', 'ya:2', 'ya:3', 'ya:4', 'ya:5', 'ya:6', 'ya:7', 'ya:8', 'ya:9', 'ya:10']
wght= False
ncfrmt = 'netcdf'
serial=False

var_list = ['TEMP', 'SALT']
mean_diff_rms_obs_dir = '/glade/p/work/mickelso/PyAvg-OMWG-obs/obs/'
region_nc_var = 'REGION_MASK'
regions={1:'Sou',2:'Pac',3:'Ind',6:'Atl',8:'Lab',9:'Gin',10:'Arc',11:'Hud',0:'Glo'}
region_wgt_var = 'TAREA'
obs_dir = '/glade/p/work/mickelso/PyAvg-OMWG-obs/obs/'
obs_file = 'obs.nc'
reg_obs_file_suffix = '_hor_mean_obs.nc'
vertical_levels = 60

clobber = True
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

