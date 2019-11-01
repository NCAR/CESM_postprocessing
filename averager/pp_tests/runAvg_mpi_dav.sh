#! /bin/bash -l

#SBATCH -n 16
#SBATCH -N 4
#SBATCH --ntasks-per-node=4
#SBATCH -t 00:05:00
#SBATCH -p dav
#SBATCH -J atm_averages_dav
#SBATCH -A P93300606
#SBATCH --mem 10G
#SBATCH -e atm_averages_dav.err.%J
#SBATCH -o atm_averages_dav.out.%J
#SBATCH -m block


if [ ! -e /gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_dav/cesm-env2/bin ]; then
    echo "*************************************************************************************"
    echo "CESM atm_averages_dav exiting due to non-existant python virtual environment in"
    echo "    /gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_dav/cesm-env2/bin"
    echo "You must first run:"
    echo "$POSTPROCESS_PATH/create_python_env -machine [machine]"
    echo "*************************************************************************************"
    exit
fi


module purge




## activate the virtualenv that contains all the non-bootstrapped dependencies

cd /gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_dav/cesm-env2/bin
echo "Running from virtualenv directory:"
pwd
. activate

## load the boot-strap modules 


module load python/2.7.14

module load intel/17.0.1

module load ncarenv

module load ncarcompilers

module load impi

module load netcdf/4.6.1

module load nco/4.7.4

module load ncl/6.4.0

export POSTPROCESS_PATH=/gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_dav

srun /gpfs/fs1/work/aliceb/sandboxes/dev/postprocessing_dav/averager/pp_tests/test_atm_series.py


