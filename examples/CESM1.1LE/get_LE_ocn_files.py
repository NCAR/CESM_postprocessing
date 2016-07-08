#!/usr/bin/env python

import os
import subprocess

cwd = os.getcwd()

path1 = '/glade/scratch/aliceb/b.e11.BRCP85C5CNBDRD.f09_g16.002/ocn/proc/tseries/monthly'
file1 = cwd+'/files_to_get_model.txt'

path2 = '/glade/scratch/aliceb/b.e11.B20TRC5CNBDRD.f09_g16.002/ocn/proc/tseries/monthly'
file2 = cwd+'/files_to_get_control.txt'

os.chdir(path1)
lines = [line.rstrip('\n') for line in open(file1)]
for line in lines:
    cmd = ['hsi','get',line]
    subprocess.call(cmd)

os.chdir(path2)
lines = [line.rstrip('\n') for line in open(file2)]
for line in lines:
    cmd = ['hsi','get',line]
    subprocess.call(cmd)
        
