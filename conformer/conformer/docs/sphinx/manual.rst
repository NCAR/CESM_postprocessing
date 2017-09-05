===========================
The PyConform User's Manual
===========================

What is it?
===========

PyConform is a tool for converting standardizing large NetCDF datasets,
such as standardization of model output for a model intercomparison
project like CMIP.

Requirements
------------

PyConform explicitly depends upon the following Python packages:

- netCDF4-python
- ASAPPyTools
- cf_units
- pyparsing
- dreqPy

These packages imply a dependency on the NumPy (v1.4+) and mpi4py (v1.3+) 
packages, and the libraries NetCDF, MPI/MPI-2, and UDUNITS2..

No thorough testing has been done to show whether earlier versions of
these dependencies will work with the PyReshaper. The versions listed
have been shown to work, and it is assumed that later versions will
continue to work.
