#!/usr/bin/env python

from pyaverager import PyAverager, specification

#### User modify ####

in_dir='/glade/p/work/mickelso/pyAverager/data/orig/'
out_dir= '/glade/p/work/mickelso/pyAverager/data/new/'
pref= 'f.e15.FAMIPW6SC.f09_f09.misc_cam5_4_75.001.cam.h0'
htype= 'slice'
average= ['zonalavg:2004:2005']
collapse_dim = 'lon'
wght= False
ncfrmt = 'netcdf'
serial=False
suffix = 'nc'
clobber = True
date_pattern= 'yyyymm-yyyymm'

#### End user modify ####

pyAveSpecifier = specification.create_specifier(in_directory=in_dir,
			          out_directory=out_dir,
				  prefix=pref,
                                  suffix=suffix,
                                  date_pattern=date_pattern,
				  hist_type=htype,
				  avg_list=average,
                                  collapse_dim=collapse_dim,
				  weighted=wght,
				  ncformat=ncfrmt,
				  serial=serial,
                                  clobber=clobber)

PyAverager.run_pyAverager(pyAveSpecifier)

