#!/usr/bin/env python

import os

# link the b.e11.B20TRC5CNBDRD.f09_g16 files
for ens in ['002','003','004','005','006']:
    for comp in ['atm','ice','lnd','ocn','rof']:
        
        srcdir = '/glade/p/cesmLE/CESM-CAM5-BGC-LE/'+comp+'/proc/tseries/monthly'

        linkdir = '/glade/scratch/aliceb/b.e11.B20TRC5CNBDRD.f09_g16.'+ens+'/'+comp+'/proc/tseries/monthly'
        casename = 'b.e11.B20TRC5CNBDRD.f09_g16.'+ens

        if not os.path.exists(linkdir):
            os.makedirs(linkdir)

        for subdir, dirs, files in os.walk(srcdir):
            for file in files:
                if casename in file:
                    os.symlink(os.path.join(subdir, file), os.path.join(linkdir, file))

        # link the b.e11.BRCP85C5CNBDRD.f09_g16 files
        linkdir = '/glade/scratch/aliceb/b.e11.BRCP85C5CNBDRD.f09_g16.'+ens+'/'+comp+'/proc/tseries/monthly'
        casename = 'b.e11.BRCP85C5CNBDRD.f09_g16.'+ens

        if not os.path.exists(linkdir):
            os.makedirs(linkdir)

        for subdir, dirs, files in os.walk(srcdir):
            for file in files:
                if casename in file:
                    os.symlink(os.path.join(subdir, file), os.path.join(linkdir, file))
