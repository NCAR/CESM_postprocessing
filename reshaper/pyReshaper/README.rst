The PyReshaper
==============

A package for converting NetCDF files from time-slice (history) format 
to time-series (single-variable) format.

:AUTHORS: John Dennis, Sheri Mickelson, Kevin Paul, Haiying Xu
:COPYRIGHT: 2017, University Corporation for Atmospheric Research
:LICENSE: See the LICENSE.rst file for details

Send questions and comments to Kevin Paul (kpaul@ucar.edu).


Overview
--------

The PyReshaper is a tool for converting time-slice (or history-file
or synoptically) formatted NetCDF files into time-series (or single-field)
format.  The PyReshaper package is designed to run in parallel (MPI) to
maximize performance, with the parallelism implemented over variables
(i.e., task parallelism).  This means that the maximum parallelism
achieveable for a given operation is one core/processor per variables in
the time-slice NetCDF files.


Dependencies
------------

The PyReshaper directly depends upon the ASAP Python Toolbox (ASAPTools)
and either PyNIO or netcdf4-python.  Access and manipulation of the NetCDF
files is done through PyNIO or netcdf4-python, and the parallelism is 
implimented using the ASAPTools SimpleComm, which uses mpi4py.  Implicit
dependencies exist as a result of these direct dependencies.

The PyReshaper explicitly depends upon the following Python packages:

-  PyNIO (v1.5+) or netCDF4-python (v1.2+)
-  ASAPPyTools (v0.4+)

These packages imply a dependency on the NumPy (v1.4+) and mpi4py (v1.3+) 
packages, and the  libraries NetCDF and MPI/MPI-2.
 
The version requirements have not been rigidly tested, so earlier versions
may actually work.  No version requirement is made during installation, though,
so problems might occur if an earlier versions of these packages have been
installed.


Easy Installation with PIP
--------------------------

The easiest way to install the ASAP Python Toolbox is from the Python
Package Index (PyPI) with the pip package manager::

    $  pip install [--user] PyReshaper
    
The optional '--user' argument can be used to install the package in the
local user's directory, which is useful if the user doesn't have root
privileges.

One should be careful, however, as the PyPI packages may not always be up
to date.  We recommend obtaining the most recent versions of the PyReshaper
from the GitHub site shown in the section below.


Obtaining the Source Code
-------------------------

Currently, the most up-to-date development source code is available
via git from the site::

    https://github.com/NCAR/PyReshaper

You may then check out the most recent stable tag.  The source is available in
read-only mode to everyone.  Developers are welcome to update the source
and submit Pull Requests via GitHub.


Building & Installing from Source
---------------------------------

Installation of the PyReshaper is very simple.  After checking out the source
from the above svn link, via::

    $ git clone https://github.com/NCAR/PyReshaper
    
Enter the newly cloned directory::

    $ cd PyReshaper

Then, run the Python setuptools setup script.  On unix, this involves::

    $  python setup.py install [--prefix=/path/to/install/location]
    
The prefix is optional, as the default prefix is typically /usr/local on
linux machines.  However, you must have permissions to write to the prefix
location, so you may want to choose a prefix location where you have write
permissions.  Like most distutils installations, you can alternatively
install the PyReshaper with the '--user' option, which will automatically
select (and create if it does not exist) the $HOME/.local directory in which
to install.  To do this, type (on unix machines)::

    $  python setup.py install --user
    
This can be handy since the site-packages directory will be common for all
user installs, and therefore only needs to be added to the ``PYTHONPATH`` once.


Before Using the PyReshaper Package
-----------------------------------

Before the PyReshaper package can be used, you must make sure that the 
site-packages directory containing the 'pyreshaper' source directory is in
your PYTHONPATH.  Depending on the PREFIX used during installation, this
path will be::

    $PREFIX/lib/python2.X/site-packages

where X will be 6 or 7 (or other) depending on the version of Python that you
are using to install the package.

To use the PyReshaper scripts (e.g., 's2smake' and 's2srun'), you must add the
script binary directory to your PATH.  Depending on the PREFIX used during
installation, this path will be::

    $PREFIX/bin/
    
Once the script binary directory has been added to your PATH and the 
site-packages directory has been added to your PYTHONPATH, you may use the
PyReshaper package without issue.


Instructions & Use
------------------

Please see the more detailed instructions found in the docs/ directory for
usage and examples.  See the 'Building & Installing from Source' section 
for how to build the documentation with Sphinx. 

