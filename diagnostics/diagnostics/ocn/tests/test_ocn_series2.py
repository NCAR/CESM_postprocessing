#!/usr/bin/env python

# import the MPI related module
import sys

sys.path.append("/glade/u/home/aliceb/sandboxes/cesm1_4_beta06/postprocessing/averager/pyAverager")
sys.path.append("/glade/u/home/aliceb/sandboxes/cesm1_4_beta06/postprocessing/mpi_utils/pyTools/source")
print(sys.path)

# import the MPI related module
from asaptools import partition, simplecomm

from pyaverager import PyAverager, specification

scomm = simplecomm.create_comm(serial=False)

#### User modify ####

in_dir='/glade/scratch/aliceb/archive/b.e13.B1850C5CN.f19_g16.01/ocn/proc/tseries/monthly'
out_dir= '/glade/scratch/aliceb/archive/b.e13.B1850C5CN.f19_g16.01/ocn/proc/tavg/annual-standalone'
pref= 'b.e13.B1850C5CN.f19_g16.01.pop.h'
htype= 'series'
##average = ['mavg:1850:1854','tavg:1850:1854']
average = ['moc:1850:1854', 'mocm:1850:1854', 'hor.meanConcat:1850:1854']
wght= False
ncfrmt = 'netcdf4'
serial=False

#var_list = []
var_list = ['TEMP', 'SALT', 'MOC']
mean_diff_rms_obs_dir = '~/sandboxes/cesm1_4_beta06/postprocessing/ocn_diag/timeseries_obs'
region_nc_var = 'REGION_MASK'
regions={1:'Sou',2:'Pac',3:'Ind',6:'Atl',8:'Lab',9:'Gin',10:'Arc',11:'Hud',0:'Glo'}
region_wgt_var = 'TAREA'
obs_dir = '~/sandboxes/cesm1_4_beta06/postprocessing/ocn_diag/timeseries_obs'
obs_file = 'obs.nc'
reg_obs_file_suffix = '_hor_mean_obs.nc'

clobber = True
suffix = 'nc'
date_pattern= 'yyyymm-yyyymm'

#### End user modify ####

scomm.sync()

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
                                  main_comm=scomm)

scomm.sync()

PyAverager.run_pyAverager(pyAveSpecifier)

