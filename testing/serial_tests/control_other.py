#!/usr/bin/env python

from pyaverager import PyAverager, specification
import os

in_dir = '/glade/p/tdd/asap/bakeoff/other_models/gfdl/'
out_dir= os.environ.get('RESULTS_DIR')+'/other/gfdl/'
prefix= 'Amon_GFDL-FLORB01_FLORB01-P1-ECDA-v3.1-011980'
m_id = ['r1i1p1','r2i1p1','r3i1p1','r4i1p1','r5i1p1','r6i1p1','r7i1p1','r8i1p1','r9i1p1','r10i1p1','r11i1p1','r12i1p1']
file_pattern= ['$var','_','$prefix','_','$m_id','_','$date_pattern','.','$suffix']
average=['ya:1980']
suffix= 'nc'


#in_dir = '/glade/p/tdd/asap/bakeoff/other_models/HadCM3/'
#out_dir= os.environ.get('RESULTS_DIR')+'/other/HadCM3/'
#prefix= 'Amon_HadCM3_decadal1960_r4i3p1'
#file_pattern= ['$var','_','$prefix','_','$date_pattern','.','$suffix']
#average=['dep_ann:1961:1965','djf:1961:1965','dep_mam:1961:1965','dep_jja:1961:1965','dep_son:1961:1965']
#suffix= 'nc'


date_pattern= 'yyyymm-yyyymm'

htype= 'series'
wght= False
ncfrmt = 'netcdf4c'
serial=True

clobber = True

pyAveSpecifier = specification.create_specifier(in_directory=in_dir,
                                  out_directory=out_dir,
                                  prefix=prefix,
                                  suffix=suffix,
                                  file_pattern=file_pattern,
                                  date_pattern=date_pattern,
                                  m_id = m_id,
                                  hist_type=htype,
                                  avg_list=average,
                                  weighted=wght,
                                  ncformat=ncfrmt,
                                  serial=serial,
                                  clobber=clobber)

PyAverager.run_pyAverager(pyAveSpecifier)
