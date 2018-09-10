#!/usr/bin/env python

from pyaverager import PyAverager, specification, PreProc
import os

#### User modify ####

in_dir='/glade/scratch/aliceb/b.e21.B1850.f09_g17.CMIP6-piControl.001/ice/hist/'
out_dir= '/glade/scratch/aliceb/b.e21.B1850.f09_g17.CMIP6-piControl.001/ice/slice/'
pref= 'b.e21.B1850.f09_g17.CMIP6-piControl.001.cice.h'
htype= 'slice'
average= ['ya:355','jfm:351:355']
wght= False
ncfrmt = 'netcdf'
serial=True

suffix= 'nc'
date_pattern= 'yyyymm-yyyymm'
clobber = True

ice_obs_file = '/glade/p/cesm/omwg/grids/gx1v7_grid.nc'
reg_file ='/glade/p/cesm/pcwg/ice/data/REGION_MASK_gx1v7.nc'
year0 = 351
year1 = 355
ncl_location = '/glade/work/aliceb/sandboxes/dev/postprocessing_new/ice_diag//code/'

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
				  serial=serial,
                                  ice_obs_file=ice_obs_file,
                                  reg_file=reg_file,
                                  year0=year0,
                                  year1=year1,
                                  clobber=clobber,
				  ncl_location=ncl_location)

PreProc.run_pre_proc(pyAveSpecifier)
PyAverager.run_pyAverager(pyAveSpecifier)

