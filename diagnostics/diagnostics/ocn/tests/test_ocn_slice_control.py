#!/usr/bin/env python2

# import the MPI related module
import sys

sys.path.append("/glade/u/home/aliceb/sandboxes/cesm1_4_beta06/postprocessing/averager/pyAverager")
sys.path.append("/glade/u/home/aliceb/sandboxes/cesm1_4_beta06/postprocessing/mpi_utils/pyTools/source")
print(sys.path)

from asaptools import partition, simplecomm

from pyaverager import PyAverager, specification

scomm = simplecomm.create_comm(serial=False)

#### User modify ####

in_dir='/glade/scratch/aliceb/archive/b.e11.B1850C5CN.f09_g16.005/ocn/hist/'
out_dir= '/glade/scratch/aliceb/archive/b.e11.B1850C5CN.f09_g16.005/ocn/proc/tavg/annual'
pref= 'b.e11.B1850C5CN.f09_g16.005.pop.h'
htype= 'slice'
average = ['mavg:0420:0424','tavg:0420:0424']
wght= False
ncfrmt = 'netcdf4'
serial=False

var_list = []
mean_diff_rms_obs_dir = '/glade/p/work/mickelso/PyAvg-OMWG-obs/obs/'
region_nc_var = 'REGION_MASK'
regions={1:'Sou',2:'Pac',3:'Ind',6:'Atl',8:'Lab',9:'Gin',10:'Arc',11:'Hud',0:'Glo'}
region_wgt_var = 'TAREA'
obs_dir = '/glade/p/work/mickelso/PyAvg-OMWG-obs/obs/'
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

