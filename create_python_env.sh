#!/bin/sh
#
# script to show how to setup environment during diagnostrics workflow 
#
echo "load modules for hpc machine here"
echo $1
# TODO - there is an arg 1 and it exists
. $1

# TODO - check if cesm-env2 already exists, if so exit

# create the virtual environment. Makefile checks to see if it is
# already setup, so only done once per case.
make env

# activate it for this script
. cesm-env2/bin/activate

# install post processing packages
make all

# run some self tests
echo "Testing post processing installation."
# run unit tests here?

# is one of our installed executables in the path?
module_check.py

# generate the run script
echo "pretend like the run script was generate here...."

# cleanup and deactivate the virtualenv. probably not strictly necessary
deactivate
