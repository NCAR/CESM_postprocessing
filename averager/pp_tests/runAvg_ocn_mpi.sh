#! /usr/bin/env bash

#BSUB -n 6
#BSUB -q geyser
#BSUB -N 
#BSUB -W 12:00
#BSUB -R "span[ptile=1]"
#BSUB -P P93300606
#BSUB -o pyAve.%J.out         # output file name in which %J is replaced by the job ID
#BSUB -e pyAve.%J.err         # error file name in which %J is replaced by the job ID

. /glade/apps/opt/lmod/lmod/init/bash

module restore system
module load python/2.7.7

cd /glade/p/work/aliceb/sandboxes/dev/postprocessing/cesm-env2/bin
pwd
. activate

module load python/2.7.7
module load numpy/1.8.1
module load scipy/0.15.1
module load mpi4py/2.0.0
module load pynio/1.4.1
module load matplotlib/1.4.3
module load intel/12.1.5
module load netcdf/4.3.0
module load nco/4.4.4
module use /glade/apps/contrib/ncl-nightly/modules
module load ncltest-intel

export POSTPROCESS_PATH=/glade/p/work/aliceb/sandboxes/dev/postprocessing

mpirun.lsf /glade/p/work/aliceb/sandboxes/dev/postprocessing/averager/pp_tests/control_ocn_series.py 

deactivate

