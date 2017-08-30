#!/usr/bin/env python
"""
PyReshaper -- Setup Script

Copyright 2017, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

from setuptools import setup

exec(open('source/pyreshaper/version.py').read())

setup(name='PyReshaper',
      version=__version__,
      description='Python Time-Slice to Time-Series NetCDF Converter',
      author='Kevin Paul',
      author_email='kpaul@ucar.edu',
      url='https://github.com/NCAR/PyReshaper',
      download_url='https://github.com/NCAR/PyReshaper/tarball/v' + __version__,
      license='https://github.com/NCAR/PyReshaper/blob/master/LICENSE.rst',
      packages=['pyreshaper'],
      package_dir={'pyreshaper': 'source/pyreshaper'},
      package_data={'pyreshaper': ['LICENSE.rst']},
      scripts=['scripts/s2smake', 'scripts/s2srun'],
      install_requires=['mpi4py', 'asaptools']
      )
