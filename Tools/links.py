#!/usr/bin/env python

import os

for year in ['0001','0002','0003','0004','0005','0006','0007','0008','0009','0010']:
    for month in ['01','02','03','04','05','06','07','08','09','10','11','12']:
        
        srcdir = '/glade/p/cesm0005/archive/b.e20.B1850.f09_g17.pi_control.all.225/ocn/hist'
        linkdir = '/glade/scratch/aliceb/b.e20.B1850.f09_g17.pi_control.all.225/ocn/hist'

        if not os.path.exists(linkdir):
            os.makedirs(linkdir)

        casename = 'b.e20.B1850.f09_g17.pi_control.all.225.pop.h'
        filename = '{0}.{1}-{2}.nc'.format(casename,year,month)
        os.symlink(os.path.join(srcdir, filename), os.path.join(linkdir, filename))

