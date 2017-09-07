#!/usr/bin/env python

import os

# link the b.e20.BHIST.f09_g17.20thC.195_01 ocn history files
for year in ['1960','1961','1962','1963']:
    for month in ['01','02','03','04','05','06','07','08','09','10','11','12']:
        
        srcdir = '/glade/p/cesm0005/archive/b.e20.BHIST.f09_g17.20thC.195_01/ocn/hist'
        linkdir = '/glade/scratch/aliceb/b.e20.BHIST.f09_g17.20thC.195_01/ocn/hist'

        if not os.path.exists(linkdir):
            os.makedirs(linkdir)

        casename = 'b.e20.BHIST.f09_g17.20thC.195_01.pop.h'
        filename = '{0}.{1}-{2}.nc'.format(casename,year,month)
        os.symlink(os.path.join(srcdir, filename), os.path.join(linkdir, filename))
