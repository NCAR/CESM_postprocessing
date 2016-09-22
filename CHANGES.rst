Change Log
==========

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details

Version 0.3
-----------

30 March 2015:

- Repackaging the pyTools repo into a Python package with
  installation software and Sphinx-style documentation

Version 0.4
-----------

10 June 2015:

- Updating install to include LICENSE
- Restructured source directory
- Upload to PyPI

Version 0.4.1
-------------

15 June 2015:

- Bugfixes

Version 0.4.2
-------------

29 June 2015:

- Update setup script to setuptools (instead of distutils)

Version 0.5.0
-------------

23 September 2015:

- Now requires Python >=2.7 and <3.0
- Using more advanced features of Python 2.7 (over 2.6)

2 March 2016:

- Changed Numpy NDArray type-checking to allow for masked arrays, instead of
  just NDArrays
 
Version 0.5.1
-------------

2 March 2016:

- Checking dtype of Numpy NDArrays before determing if buffered send/recv
  calls can be used.
 
Version 0.5.2
-------------

2 March 2016:

- Improved testing for send/recv data types

3 March 2016:

- Backwards compatability with mpi4py version 1.3.1 

Version 0.5.3
-------------

3 March 2016:

- Updates just for PyPI release


Version 0.5.4
-------------

4 March 2016:

- Bugfix: Special catch for dtype='c' (C-type char arrays) in check for 
  Numpy arrays being bufferable
