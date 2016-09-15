#!/usr/bin/env python

from pyaverager import PyAverager, specification
import PreProc
import os

#### User modify ####

in_dir='/glade/p/tdd/asap/data/b.e12.B1850C5CN.ne30_g16.init.ch.027/ice/mon/tseries/'
out_dir= os.environ.get('RESULTS_DIR')+'/ice/series/'
pref= 'b.e12.B1850C5CN.ne30_g16.init.ch.027.cice.h'
htype= 'series'
average= ['ya:1', 'ya:2', 'ya:3', 'ya:4', 'ya:5', 'ya:6', 'ya:7', 'ya:8', 'ya:9', 'ya:10',
            'dep_jfm:1:10','dep_fm:1:10','dep_amj:1:10','dep_jas:1:10','dep_ond:1:10','dep_on:1:10']
wght= False
spl= True
split_fn= 'nh,sh'
split_size= 'nj=384,ni=320'
ncfrmt = 'netcdf'
serial=False

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
				  split=spl,
				  split_files=split_fn,
				  split_orig_size=split_size,
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

