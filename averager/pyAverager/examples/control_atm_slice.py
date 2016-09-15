#!/usr/bin/env python

from pyaverager import PyAverager, specification

#### User modify ####

in_dir='/glade/p/tdd/asap/data/b40.20th.track1.1deg.006/atm/hist/'
out_dir= '/glade/scratch/mickelso/averager_sandbox/results/atm/slice'
pref= 'b40.20th.track1.1deg.006.cam2.h0'
htype= 'slice'
average= ['dep_ann:1850:1859','djf:1850:1858','dep_mam:1850:1859','dep_jja:1850:1859','dep_son:1850:1859',
            'jan:1850:1859','feb:1850:1859','mar:1850:1859','apr:1850:1859','may:1850:1859','jun:1850:1859',
            'jul:1850:1859','aug:1850:1859','sep:1850:1859','oct:1850:1859','nov:1850:1859','dec:1850:1859']
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

