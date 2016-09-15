#!/usr/bin/env python

from pyaverager import PyAverager, specification
import os

#### User modify ####

in_dir='/glade/p/tdd/asap/data/b.e12.B1850C5CN.ne30_g16.init.ch.027/atm/mon/tseries/'
out_dir= os.environ.get('RESULTS_DIR')+'/atm_se/series/'
pref= 'b.e12.B1850C5CN.ne30_g16.init.ch.027.cam.h0'
htype= 'series'
average= ['dep_ann:1:10','dep_mam:1:10','dep_jja:1:10','dep_son:1:10','zonalavg:1:10',
            'jan:1:10','feb:1:10','mar:1:10','apr:1:10','may:1:10','jun:1:10',
            'jul:1:10','aug:1:10','sep:1:10','oct:1:10','nov:1:10','dec:1:10']
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

