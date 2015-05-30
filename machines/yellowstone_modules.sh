#!/bin/sh

echo "Python boot-strap modules for machine yellowstone"
. /glade/apps/opt/lmod/lmod/init/bash

module unload all-python-libs

module load python/2.7.7
module load numpy/1.8.1
module load scipy/0.15.1
module load mpi4py/1.3.1
module load pynio/1.4.1
module load matplotlib/1.4.3
module load nco/4.4.4
module load ncl/6.3.0
module load intel
module load netcdf

# may need basemap for ocn ecosys

module list

