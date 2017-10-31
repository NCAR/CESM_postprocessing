#!/usr/bin/env python

import os

# link the b.e20.BHIST.f09_g17.20thC.195_01 ocn monthly history files
##for year in ['1964','1965','1966','1967','1968','1969']:
##    for month in ['01','02','03','04','05','06','07','08','09','10','11','12']:
        
##        srcdir = '/glade/p/cesm0005/archive/b.e20.BHIST.f09_g17.20thC.195_01/ocn/hist'
##        linkdir = '/glade/scratch/aliceb/b.e20.BHIST.f09_g17.20thC.195_01/ocn/hist'

##        if not os.path.exists(linkdir):
##            os.makedirs(linkdir)

##        casename = 'b.e20.BHIST.f09_g17.20thC.195_01.pop.h'
##        filename = '{0}.{1}-{2}.nc'.format(casename,year,month)
##        os.symlink(os.path.join(srcdir, filename), os.path.join(linkdir, filename))

##for year in ['1960','1961','1962','1963','1964','1965','1966','1967','1968','1969']:
##    for month in ['01','02','03','04','05','06','07','08','09','10','11','12']:
        
##        srcdir = '/glade/p/cesm0005/archive/b.e20.BHIST.f09_g17.20thC.195_01/ocn/hist'
##        linkdir = '/glade/scratch/aliceb/b.e20.BHIST.f09_g17.20thC.195_01/ocn/hist'

##        if not os.path.exists(linkdir):
##            os.makedirs(linkdir)

##        casename = 'b.e20.BHIST.f09_g17.20thC.195_01.pop.h.nday1'
##        filename = '{0}.{1}-{2}-01.nc'.format(casename,year,month)
##        os.symlink(os.path.join(srcdir, filename), os.path.join(linkdir, filename))

##for year in ['1960','1961','1962','1963','1964','1965','1966','1967','1968','1969']:
##    for month in ['01','02','03','04','05','06','07','08','09','10','11','12']:
        
##        srcdir = '/glade/p/cesm0005/archive/b.e20.BHIST.f09_g17.20thC.195_01/lnd/hist'
##        linkdir = '/glade/scratch/aliceb/b.e20.BHIST.f09_g17.20thC.195_01/lnd/hist'

##        if not os.path.exists(linkdir):
##            os.makedirs(linkdir)

##        casename = 'b.e20.BHIST.f09_g17.20thC.195_01.clm2.h0'
##        filename = '{0}.{1}-{2}.nc'.format(casename,year,month)
##        os.symlink(os.path.join(srcdir, filename), os.path.join(linkdir, filename))

for year in ['0101','0102','0103','0104','0105','0106','0107','0108','0109','0110','0111','0112','0113','0114','0115','0116','0117','0118','0119','0120']:
    for month in ['01','02','03','04','05','06','07','08','09','10','11','12']:
        
        srcdir = '/glade/p/cesm0005/archive/b.e20.B1850.f09_g17.pi_control.all.197/ocn/hist'
        linkdir = '/glade/scratch/aliceb/b.e20.B1850.f09_g17.pi_control.all.197/ocn/hist'
        casename = 'b.e20.B1850.f09_g17.pi_control.all.197.pop.h'
        filename = '{0}.{1}-{2}.nc'.format(casename,year,month)
        os.symlink(os.path.join(srcdir, filename), os.path.join(linkdir, filename))

for year in ['0101','0102','0103','0104','0105','0106','0107','0108','0109','0110','0111','0112','0113','0114','0115','0116','0117','0118','0119','0120']:
    for month in ['01','02','03','04','05','06','07','08','09','10','11','12']:
        
        srcdir = '/glade/p/cesm0005/archive/b.e20.B1850.f09_g17.pi_control.all.201/ocn/hist'
        linkdir = '/glade/scratch/aliceb/b.e20.B1850.f09_g17.pi_control.all.201/ocn/hist'

        if not os.path.exists(linkdir):
            os.makedirs(linkdir)

        casename = 'b.e20.B1850.f09_g17.pi_control.all.201.pop.h'
        filename = '{0}.{1}-{2}.nc'.format(casename,year,month)
        os.symlink(os.path.join(srcdir, filename), os.path.join(linkdir, filename))

