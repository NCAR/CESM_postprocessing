#!/usr/bin/env python
"""
PyReshaper -- Setup Script

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

from setuptools import setup

exec(open('source/pyreshaper/version.py').read())

try:
    import Nio
except ImportError:
    raise ImportError('PyNIO 1.4+ is required to install PyReshaper.')

if Nio.__version__ < 1.4:
    raise ImportError('PyNIO 1.4+ is required to install PyReshaper.')


setup(name='PyReshaper',
      version=__version__,
      description='Python Time-Slice to Time-Series NetCDF Converter',
      author='Kevin Paul',
      author_email='kpaul@ucar.edu',
      url='https://github.com/NCAR-CISL-ASAP/PyReshaper',
      download_url='https://github.com/NCAR-CISL-ASAP/PyReshaper/tarball/v' + __version__,
      license='https://github.com/NCAR-CISL-ASAP/PyReshaper/blob/master/LICENSE.rst',
      packages=['pyreshaper'],
      package_dir={'pyreshaper': 'source/pyreshaper'},
      package_data={'pyreshaper': ['LICENSE.rst']},
      scripts=['scripts/s2smake', 'scripts/s2srun'],
      install_requires=['mpi4py', 'asaptools']
      )
