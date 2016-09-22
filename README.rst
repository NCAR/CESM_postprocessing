=======================
The ASAP Python Toolbox
=======================

The ASAP Python Toolbox is a collection of stand-alone tools for doing simple
tasks, from managing print messages with a set verbosity level, to
keeping timing information, to managing simple MPI communication.

:AUTHORS: Kevin Paul, John Dennis, Sheri Mickelson, Haiying Xu
:COPYRIGHT: 2016, University Corporation for Atmospheric Research
:LICENSE: See the LICENSE.rst file for details

Send questions and comments to Kevin Paul (kpaul@ucar.edu).

Overview
--------

The ASAP (Application Scalability And Performance) group at the National
Center for Atmospheric Research maintains this collection of simple
Python tools for managing tasks commonly used with its Python software.
The modules contained in this package include:

:vprinter: For managing print messages with verbosity-level specification
:timekeeper: For managing multiple "stop watches" for timing metrics
:partition: For various data partitioning algorithms
:simplecomm: For simple MPI communication

Only the simplecomm module depends on anything beyond the basic built-in
Python packages.

Dependencies
------------

All of the ASAP Python Toolbox are written to work with Python 2.7+ (but not
Python 3.0+). The vprinter, timekeeper, and partition modules are pure
Python. The simplecomm module depends on mpi4py (>=1.3).

This implies the dependency:

- mpi4py depends on numpy (>-1.4) and MPI

Easy Installation
-----------------

The easiest way to install the ASAP Python Toolbox is from the Python
Package Index (PyPI) with the pip package manager::

    $  pip install [--user] ASAPTools
    
The optional '--user' argument can be used to install the package in the
local user's directory, which is useful if the user doesn't have root
privileges.

Obtaining the Source Code
-------------------------

Currently, the most up-to-date source code is available via git from the
site::

    https://github.com/NCAR/ASAPPyTools

Check out the most recent tag.  The source is available in read-only
mode to everyone, but special permissions can be given to those to make
changes to the source.

Building & Installation
-----------------------

Installation of the ASAP Python Toolbox is very simple. After checking out the
source from the above svn link, via::

    $  git clone https://github.com/NCAR/ASAPPyTools

change into the top-level source directory, check out the most recent tag,
and run the Python distutils setup. On unix, this involves::

    $  cd ASAPPyTools
    $  git checkout [latest tag]
    $  python setup.py install [--prefix-/path/to/install/location]

The prefix is optional, as the default prefix is typically /usr/local on
linux machines. However, you must have permissions to write to the
prefix location, so you may want to choose a prefix location where you
have write permissions. Like most distutils installations, you can
alternatively install the pyTools with the --user option, which will
automatically select (and create if it does not exist) the $HOME/.local
directory in which to install. To do this, type (on unix machines)::

    $  python setup.py install --user

This can be handy since the site-packages directory will be common for
all user installs, and therefore only needs to be added to the
PYTHONPATH once.

To build the documentation for developer use, you will need Sphinx.  Sphinx
can be installed with the pip utility simple::

    $  pip install Sphinx

Once Sphinx is installed, you can build the ASAP Python Toolbox's
HTML documentation with::

    $  cd docs
    $  make html

which will build the documentation in the docs/build/html directory.  If you
wish to build a PDF, do the following::

    $  cd docs
    $  make latexpdf

which requires pdflatex to build a PDF version of the documentation.

Before Using the ASAP Python Toolbox
------------------------------------

Before the ASAP Python Toolbox package can be used, you must make sure that the
site-packages directory containing the 'pytools' source directory is in
your PYTHONPATH. Depending on the PREFIX used during installation, this
path will be::

    $PREFIX/lib/python2.X/site-packages

where X will be 6 or 7 (or other) depending on the version of Python
that you are using to install the package.

Instructions & Use
------------------

For instructions on how to use the ASAP Python Toolbox, see the additional
documentation found in the docs directory.  Please read the
'Building & Installation' section above for instructions on how to build the
HTML documentation. Once built, you will be able to open the
'docs/build/html/index.html' page in any browser.
