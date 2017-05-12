#! /usr/bin/env bash
#
# template to activate the virtualenv, call post process program, deactivate virtualenv
#

#BSUB -n 4
#BSUB -R "span[ptile=2]"
#BSUB -q geyser
#BSUB -N
#BSUB -a poe
#BSUB -J ration_script
#BSUB -W 00:02
#BSUB -P P93300606 

. /glade/apps/opt/lmod/lmod/init/bash

export MP_LABELIO=yes

module load python/2.7.7

. /glade/p/work/aliceb/sandboxes/dev/postprocessing/cesm-env2/bin/activate

module load mpi4py/2.0.0

mpirun.lsf ./ration_example.py >> ./ration.log

status=$?
echo $status

deactivate

echo $status




