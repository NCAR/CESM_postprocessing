#!/bin/bash

module load python
module load all-python-libs

# Function to return the absolute path
function abspath {
  cd $1
  echo `pwd`
}

# Add the PyReshaper executable scripts to the path
BIN_DIR=`abspath ../../scripts`
export PATH=$PATH:$BIN_DIR

# Add this (local) PyReshaper module path to the python path
MOD_DIR=`abspath ../../source`
export PYTHONPATH=$MOD_DIR:$PYTHONPATH
