#!/bin/csh
#BSUB -n 160
#BSUB -q regular
#BSUB -N 
#BSUB -W 2:00
##BSUB -R "span[ptile=8]"
#BSUB -P P93300606
#BSUB -o pyAve.%J.out         # output file name in which %J is replaced by the job ID
#BSUB -e pyAve.%J.err         # error file name in which %J is replaced by the job ID

#source /glade/u/home/aliceb/sandboxes/cesm1_4_alpha05/postprocessing/cesm-env2/bin/activate.csh

module load python 
module load all-python-libs

mpirun.lsf ./test_ocn_slice.py

#deactivate


