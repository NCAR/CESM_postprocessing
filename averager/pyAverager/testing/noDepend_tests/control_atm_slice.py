#!/usr/bin/env python

from pyaverager import PyAverager, specification
import os

#### User modify ####

in_dir='/glade/p/tdd/asap/data/b40.20th.track1.1deg.006/atm/hist/'
out_dir= os.environ.get('RESULTS_DIR')+'/atm/slice'
pref= 'b40.20th.track1.1deg.006.cam2.h0'
htype= 'slice'
average= ['ann:1850:1859','djf:1850:1858','mam:1850:1859','jja:1850:1859','son:1850:1859','zonalavg:1850:1859']
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

