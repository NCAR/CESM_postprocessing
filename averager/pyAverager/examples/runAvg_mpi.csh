#!/bin/csh
#BSUB -n 160 
#BSUB -q regular 
#BSUB -N 
#BSUB -W 4:00
#BSUB -R "span[ptile=8]"
#BSUB -P STDD0002 
#BSUB -o pyAve.%J.out         # output file name in which %J is replaced by the job ID
#BSUB -e pyAve.%J.err         # error file name in which %J is replaced by the job ID

module load python 
module load all-python-libs

rm /glade/scratch/mickelso/averager_sandbox/results/atm/slice/*
rm /glade/scratch/mickelso/averager_sandbox/results/atm/series/*
rm /glade/scratch/mickelso/averager_sandbox/results/atm_se/slice/*
rm /glade/scratch/mickelso/averager_sandbox/results/atm_se/series/*
rm /glade/scratch/mickelso/averager_sandbox/results/ocn/slice/*
rm /glade/scratch/mickelso/averager_sandbox/results/ocn/series/*
rm /glade/scratch/mickelso/averager_sandbox/results/lnd/slice/*
rm /glade/scratch/mickelso/averager_sandbox/results/lnd/series/*
rm /glade/scratch/mickelso/averager_sandbox/results/ice/slice/*
rm /glade/scratch/mickelso/averager_sandbox/results/ice/series/*
rm /glade/scratch/mickelso/averager_sandbox/results/other/gfdl/*

mpirun.lsf ./control_atm_series.py
mpirun.lsf ./control_atm_slice.py 

mpirun.lsf ./control_atm_se_series.py
mpirun.lsf ./control_atm_se_slice.py

mpirun.lsf ./control_ice_series.py
mpirun.lsf ./control_ice_slice.py

mpirun.lsf ./control_lnd_series.py
mpirun.lsf ./control_lnd_slice.py

mpirun.lsf ./control_ocn_series.py
mpirun.lsf ./control_ocn_slice.py

mpirun.lsf ./control_other.py

