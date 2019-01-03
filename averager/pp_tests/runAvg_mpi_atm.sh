#!/bin/bash

#PBS -N atm_averages
#PBS -q regular
#PBS -l select=2:ncpus=9:mpiprocs=9
#PBS -l walltime=00:05:00
#PBS -A P93300606

source /etc/profile.d/modules.sh

export MPI_UNBUFFERED_STDIO=true
export TMPDIR=$TMPDIR


##########
##
## See https://github.com/NCAR/CESM_postprocessing/wiki for details
## regarding settings for optimal performance for CESM postprocessing tools.
##
##########

if [ ! -e /gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_new/cesm-env2/bin ]; then
    echo "*************************************************************************************"
    echo "CESM atm_averages exiting due to non-existant python virtual environment in"
    echo "    /gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_new/cesm-env2/bin"
    echo "You must first run:"
    echo "$POSTPROCESS_PATH/create_python_env -machine [machine]"
    echo "*************************************************************************************"
    exit
fi


module purge




## activate the virtualenv that contains all the non-bootstrapped dependencies

cd /gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_new/cesm-env2/bin
echo "Running from virtualenv directory:"
pwd
. activate

## load the boot-strap modules 


module load python/2.7.14

module load intel/17.0.1

module load ncarenv

module load ncarcompilers

module load mpt/2.15f

module load netcdf/4.6.1

module load nco/4.7.4

module load ncl/6.4.0

export POSTPROCESS_PATH=/gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_new

mpiexec_mpt dplace -s 1 /gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_new/averager/pp_tests/test_atm_series.py >> /gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_new/averager/pp_tests/atm_series.log 2>&1


