Installation
============

The ILAMB benchmarking software is written in python 2.7x and depends
on a few packages which extend the language's usefulness in scientific
applications. The easiest way to install the ILAMB package and its
dependencies is to get them from the Python Package Index (pypi_) using
pip_. To do so, type::

  pip install ILAMB --user

at the commandline and pip_ will install most everything
automatically. Please note that I have post-pended a ``--user`` flag
to the command. This is not strictly necessary yet recommended as it
will cause the packages to be installed to a *local* directory in
place of the *system* directory. This allows packages to be installed
without administrator privileges, and leaves your system installation
untouched, which may be important if you need to revert to a previous
state. You should see that a number of packages in addition to ILAMB
had their versions checked or were upgraded/installed as needed. These
include:

* numpy_, the fundamental package for scientific computing with python
* matplotlib_, a 2D plotting library which produces publication quality figures
* netCDF4_, a python/numpy interface to the netCDF C library (you must have the C library installed)
* sympy_, a python library for symbolic mathematics
* mpi4py_, a python wrapper around the MPI library (you must have a MPI implementation installed)
* cfunits_, a python interface to UNIDATA’s Udunits-2 library with CF extensions (you must have the Udunits library installed)

I have designated that a few of these dependencies are python
interfaces to C libraries and so the library must also be installed
separately. See the individual package websites for more
details. Ideally, pip_ would be able to install all our dependencies
automatically.

Unfortunately, one of our dependencies must be installed
manually. Despite being listed in the Python Package Index, basemap_
cannot be installed with pip_. The meta information is listed, but the
package source is too large to be hosted and so installation fails. We
will need to install basemap_ from the source hosted on github_. This
is a useful process to understand as any python package can be
installed in this way. First, clone the git repository::

  git clone https://github.com/matplotlib/basemap.git

This will take some time as the repository is large (>100Mb) due to it
including some high resolution map data used in plotting. Enter into
the cloned directory and take note of a file called ``setup.py``. All
python packages will contain a file called ``setup.py`` in the top
level directory. This is where a developer tells python how to install
the package. Now we type::

  python setup.py install --user

and the package should install. Hopefully in the future basemap_ will
improve their installation process in pypi_, but in the meantime it
must be installed as we have detailed here.

You can test your installation by the following command::
  
  python -c "import ILAMB; print ILAMB.__version__"

If you get a numerical output, then the package has been successfully
installed.

Now what?
---------

If you got the installation to work, then you should proceed to
working on the next tutorial. Before leaving this page, there are a
few extra steps we recommend you perform. If you installed ILAMB using
the ``--user`` option, the executeable script ``ilamb-run`` will be
placed inside ``${HOME}/.local/bin``. You may need to postpend this
location to your ``PATH`` environment variable::

  export PATH=${PATH}:${HOME}/.local/bin

assuming you are using a ``bash`` environment. This will make the
``ilamb-run`` script executeable from any directory. Also, if you are
connecting to a machine remotely in order to run ILAMB, you may wish
to change the matplotlib_ backend to something that does not generate
interactive graphics::

  export MPLBACKEND=Agg

This will allow ILAMB to run without needing to connect with the
``-X`` option.
  
What can go wrong?
------------------

In an ideal world, this will work just as I have typed it to
you. However, if you are here, something has happened and you need
help. Installing software is frequently all about making sure things
get put in the correct place. You may be unaware of it, but you may
have several versions of python floating around your machine. The pip_
software we used to install packages needs to match the version of
python that we are using. Try typing::

  pip --version
  which python
  python --version

where you should see something like::

  pip 9.0.1 from /usr/local/lib/python2.7/site-packages (python 2.7)
  /usr/local/bin/python
  Python 2.7.13
  
Notice that in my case the pip_ I am using matches the version and
location of the python. This is important as pip_ will install
packages into the locations which my python will find. If your pip_
is, say, for python 3 but you are using python 2.7 then you will
install packages successfully, but they will seem to not be available
to you. The same thing can happen if you have the right version of
python, but it is installed in some other location.

Now we provide some interpretation of the possible output you got from
the test. If you ran::

  python -c "import ILAMB; print ILAMB.__version__"

and you see something like::

  Traceback (most recent call last):
    File "<string>", line 1, in <module>
  ImportError: No module named ILAMB

Then the package did not correctly install and you need to look at the
screen output from the install process to see what went wrong. You may
also have observed an import error of a different sort. When you
import the ILAMB package, we check the version of all the packages on
which we depend. You could see an error text like the following::

  Traceback (most recent call last):
    File "<string>", line 1, in <module>
    File "/usr/local/lib/python2.7/site-packages/ILAMB/__init__.py", line 29, in <module>
      (key,__version__,key,requires[key],pkg.__version__))
  ImportError: Bad numpy version: ILAMB 0.1 requires numpy >= 1.9.2 got 1.7

This means that while the ``numpy`` package is installed on your
system, its version is too old and you need to use pip_ to upgrade it
to at least the version listed. You may also see a message like the
following::

  Traceback (most recent call last):
    File "<string>", line 1, in <module>
    File "/usr/local/lib/python2.7/site-packages/ILAMB/__init__.py", line 25, in <module>
      pkg = __import__(key)
  ImportError: No module named numpy

This means that we require the ``numpy`` package but you do not have
it installed at all. This should not happen, but if it does, use pip_
to resolve this problem. It is possible that despite a seemingly
smooth installation of basemap_, ILAMB complains about there not being
a module called basemap::

  Traceback (most recent call last):
    File "<string>", line 1, in <module>
    File "/usr/local/lib/python2.7/site-packages/ILAMB/__init__.py", line 24, in <module>
      pkg = __import__(key, globals(), locals(), [froms[key]])
  ImportError: No module named basemap

Basemap is a little trickier than other python packages because it is
a *plugin* to the maplotlib package. My recommendation if you are
seeing this message is to install matplotlib in a local location and
upgrade it to the most up to date version::

  pip install matplotlib --user --upgrade

and then install basemap also using the ``--user`` option. This should
ensure that matplotlib toolkits find the basemap extension.

Institutional machines
----------------------

While ILAMB is portable and runs on your laptop or workstation, you
may be working remotely on an institutional machine where you have
modeling output results. Many times these machines already have our
dependencies installed and we only have need to load them using
environment modules. See your computing center usage tutorials for
more information on how these work. Typically, you can search for
available software by::

  module avail search_term

for example. And then is loaded by::

  module load software_name

In an effort to make it simpler for users to get ILAMB running, we are
listing installation instructions here for a number of machines with
which we have experience. In each case, we have tried to start with
only the default software enabled. Your mileage may vary as the
software stacks at these centers frequently change.

It is relevant to note that ILAMB uses MPI to parallelize the
benchmarking process. Thus MPI is called even if you are running on
just one process. Because of this, many if not all institutional
machines will then require you to launch a job though a submission
script. See your computing center for details.

Edison @ NERSC
~~~~~~~~~~~~~~

.. code-block:: bash

  module load python
  module load numpy
  module load matplotlib
  module load basemap
  module load mpi4py
  module load netcdf
  module load netcdf4-python
  module load udunits 
  pip install ILAMB --user
  export PATH=${PATH}:${HOME}/.local/edison/2.7.9/bin/

The matplotlib on Edison is pretty old and control of the backend is
not possible using the ``MPLBACKEND`` environment variable. If you
want to run without needing to connect with the ``-X`` option, you
will need to change the backend through the ``matplotlibrc``
file. First, copy this file from the system level, into your local
configure directory::
  
  cp /usr/common/software/python/matplotlib/1.4.3/lib/python2.7/site-packages/matplotlib-1.4.3-py2.7-linux-x86_64.egg/matplotlib/mpl-data/matplotlibrc ${HOME}/.config/matplotlib/

Next open the local copy of the file with a editor and search for
``backend`` changing the value to the right of the colon to ``Agg``.
  
Rhea @ OLCF
~~~~~~~~~~~

.. code-block:: bash
		
  module rm PE-intel
  module load PE-gnu
  module load netcdf
  module load udunits
  module load geos
  module load python
  module load python_setuptools
  module load python_pip
  module load python_numpy
  module load python_matplotlib
  module load python_matplotlib_basemap_toolkit
  module load python_netcdf4
  module load python_mpi4py
  pip install ILAMB --user
  export PATH=${PATH}:${HOME}/.local/bin/
  # The udunits module file should do this but doesn't
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/sw/rhea/udunits/2.1.24/rhel6.6_gnu4.4.7/lib/
   
The matplotlib on Rhea is pretty old and control of the backend is
not possible using the ``MPLBACKEND`` environment variable. If you
want to run without needing to connect with the ``-X`` option, you
will need to change the backend through the ``matplotlibrc``
file. First, copy this file from the system level, into your local
configure directory::

  cp /sw/rhea/python_matplotlib/1.4.3/python2.7.9_numpy1.9.2_gnu4.8.2/lib64/python2.7/site-packages/matplotlib-1.4.3-py2.7-linux-x86_64.egg/matplotlib/mpl-data/matplotlibrc ${HOME}/.config/matplotlib/

Next open the local copy of the file with a editor and search for
``backend`` changing the value to the right of the colon to ``Agg``.



.. _pypi:       https://pypi.python.org/pypi
.. _pip:        https://pip.pypa.io/en/stable/
.. _repository: https://bitbucket.org/ncollier/ilamb
.. _numpy:      https://www.numpy.org/
.. _matplotlib: https://matplotlib.org/
.. _netCDF4:    https://github.com/Unidata/netcdf4-python
.. _cfunits:    https://bitbucket.org/cfpython/cfunits-python/
.. _basemap:    https://github.com/matplotlib/basemap
.. _sympy:      https://www.sympy.org/
.. _mpi4py:     https://pythonhosted.org/mpi4py/
.. _github:     https://github.com
