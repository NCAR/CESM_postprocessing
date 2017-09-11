PyConform
=========

A package for transforming a NetCDF dataset into a defined format 
suitable for publication according to a defined publication standard.

:AUTHORS: Sheri Mickelson, Kevin Paul
:COPYRIGHT: 2017, University Corporation for Atmospheric Research
:LICENSE: See the LICENSE.rst file for details

Send questions and comments to Kevin Paul (kpaul@ucar.edu) or
Sheri Mickelson (mickelso@ucar.edu).


Overview
--------

The PyConform package is a Python-based package for ...


Dependencies
------------

The PyConform package directly depends upon ...

The major dependencies are known to be:

* ASAPTools (>=0.6)
* netCDF4-python

These dependencies imply the dependencies:

* numpy (>=1.5)
* netCDF4
* MPI

Additionally, the entire package is designed to work with Python v2.7 and up
to (but not including) Python v3.0.

The version requirements have not been rigidly tested, so earlier versions
may actually work.  No version requirement is made during installation, though,
so problems might occur if an earlier versions of these packages have been
installed.


Obtaining the Source Code
-------------------------

Currently, the most up-to-date development source code is available
via git from the site::

    https://github.com/NCAR/PyConform

Check out the most recent stable tag.  The source is available in
read-only mode to everyone.  Developers are welcome to update the source
and submit Pull Requests via GitHub.


Building & Installing from Source
---------------------------------

Installation of the PyConform package is very simple.  After checking out the source
from the above svn link, via::

    $ git clone https://github.com/NCAR/PyConform

Enter the newly cloned directory::

    $ cd PyConform

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


Before Using the PyConform Package
----------------------------------

Before the PyConform package can be used, you must make sure that the
site-packages directory containing the 'pyconform' source directory is in
your PYTHONPATH.  Depending on the PREFIX used during installation, this
path should look like be::

    $PREFIX/lib/python2.7/site-packages

depending on the version of Python that you
are using to install the package.

To use the PyConform scripts (e.g., ...), you must add the
script binary directory to your PATH.  Depending on the PREFIX used during
installation, this path will be::

    $PREFIX/bin/

Once the script binary directory has been added to your PATH and the
site-packages directory has been added to your PYTHONPATH, you may use the
PyConform package without issue.


Instructions & Use
------------------

Please see the more detailed instructions found in the docs/ directory for
usage and examples.  See the 'Building & Installing from Source' section
for how to build the documentation with Sphinx.

