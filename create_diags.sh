#!/usr/bin/env bash
#
# script to show how to setup environment during diagnostrics workflow 
#

echo "load modules for hpc machine here"

module load python/2.7.7
module load numpy/1.8.1
module load scipy/0.15.1
module load mpi4py/1.3.1

# create the virtual environment. Makefile checks to see if it is
# already setup, so only done once per case.
make env

# activate it for this script
. test-env/bin/activate

# install post processing packages
make all

# run some self tests
echo "Testing post processing installation."
# run unit tests here?

# is one of our installed executables in the path?
diag_util_test.py

# generate the run script
echo "pretend like the run script was generate here...."

# cleanup and deactivate the virtualenv. probably not strictly necessary
deactivate
