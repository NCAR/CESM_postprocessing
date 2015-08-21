#!/bin/csh
#BSUB -n 124
#BSUB -q regular
#BSUB -N 
#BSUB -W 0:10
#BSUB -R "span[ptile=8]"
#BSUB -P P93300606
#BSUB -o pyAve.%J.out         # output file name in which %J is replaced by the job ID
#BSUB -e pyAve.%J.err         # error file name in which %J is replaced by the job ID

source /glade/u/home/aliceb/sandboxes/cesm1_4_beta06/postprocessing/cesm-env2/bin/activate.csh

module load python/2.7.7
module load numpy/1.8.1
module load scipy/0.15.1
module load mpi4py/1.3.1
module load pynio/1.4.1
module load matplotlib/1.4.3
module load intel/15.0.3
module load netcdf
module load ncl/6.3.0

mpirun.lsf ./test_ocn_series.py

deactivate


