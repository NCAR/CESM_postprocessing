The PyReshaper
==============

A package for converting NetCDF files from time-slice (history) format 
to time-series (single-variable) format.

:AUTHORS: John Dennis, Sheri Mickelson, Kevin Paul, Haiying Xu
:COPYRIGHT: 2016, University Corporation for Atmospheric Research
:LICENSE: See the LICENSE.rst file for details

Send questions and comments to Kevin Paul (kpaul@ucar.edu).


Overview
--------

The PyReshaper package is a Python-based package for performing time-slice
to time-series convertion of NetCDF files, compliant with the CF 1.6 
Conventions.  The PyReshaper package is designed to run in parallel to
maximize performance, with the parallelism implemented over variables
(i.e., task parallelism).  This means that the maximum parallelism
achieveable for a given operation is one core/processor per variables in
the time-slice NetCDF files.


Dependencies
------------

The PyReshaper directly depends upon the PyNIO and mpi4py packages.  Access
and manipulation of the NetCDF files is done through PyNIO, and the parallelism
is implimented directly with mpi4py.  Implicit dependencies exists, as PyNIO
has its own dependencies (netCDF, NCL, and numpy) as does mpi4py (numpy and 
MPI).

Currently the explicit dependencies are known to be:

* ASAPTools (>=0.4)
* PyNIO (>=1.4.1)
* mpi4py (>=1.3)

This implies the dependencies:

* PyNIO depends upon numpy (>=1.4), NCL, and netCDF
* mpi4py depends on numpy (>=1.4) and MPI
    
Additionally, the entire package is designed to work with Python v2.6 and up
to (but not including) Python v3.0.
 
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

Check out the most recent stable tag.  The source is available in
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
user installs, and therefore only needs to be added to the PYTHONPATH once.

To install the documentation, you must have Sphinx installed on your system.
Sphinx can be easily installed with pip, via::

    $  pip install Sphinx
    
Once Sphinx is installed, you can build the PyReshaper HTML documentation
with::

    $  cd docs
    $  make html

The resulting HTML documentation will be placed in the docs/build/html
directory, and the main page can be loaded with any browser pointing to
'docs/build/html/index.html'.


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

