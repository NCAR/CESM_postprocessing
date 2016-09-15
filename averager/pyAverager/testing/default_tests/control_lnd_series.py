#!/usr/bin/env python

from pyaverager import PyAverager, specification
import os

#### User modify ####

in_dir='/glade/p/tdd/asap/data/b.e12.B1850C5CN.ne30_g16.init.ch.027/lnd/mon/tseries/'
out_dir= os.environ.get('RESULTS_DIR')+'/lnd/series/'
pref= 'b.e12.B1850C5CN.ne30_g16.init.ch.027.clm2.h0'
htype= 'series'
average= ['mons:1:10','dep_ann:1:10','dep_mam:1:10','dep_jja:1:10','dep_son:1:10','annall:1:10']
wght= True
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
				  weighted=wght,
				  ncformat=ncfrmt,
				  serial=serial,
                                  clobber=clobber)

PyAverager.run_pyAverager(pyAveSpecifier)

