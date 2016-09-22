#!/usr/bin/env python

from pyaverager import PyAverager, specification
import PreProc
import os

#### User modify ####

in_dir='/glade/p/tdd/asap/data/b.e12.B1850C5CN.ne30_g16.init.ch.027/ice/hist/'
out_dir= os.environ.get('RESULTS_DIR')+'/ice/slice/'
pref= 'b.e12.B1850C5CN.ne30_g16.init.ch.027.cice.h'
htype= 'slice'
average= ['ya:1','jfm:1:10']
wght= False
ncfrmt = 'netcdf'
serial=True

suffix= 'nc'
date_pattern= 'yyyymm-yyyymm'
clobber = True

ice_obs_file = '/glade/p/work/mickelso/PyAvg-IceDiag-obs/gx1v6_grid.nc'
reg_file ='/glade/p/work/mickelso/PyAvg-IceDiag-obs/REGION_MASK.nc'
year0 = 1
year1 = 10
ncl_location = '/glade/scratch/mickelso/pyAverager_trunk/trunk/pyaverager'

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

