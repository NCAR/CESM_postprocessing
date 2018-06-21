#!/usr/bin/env python
"""
PyConform -- Setup Script

Copyright 2017, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

from setuptools import setup

exec(open('source/pyconform/version.py').read())

setup(name='PyConform',
      version=__version__,
      description='Parallel Python NetCDF Dataset Standardization Tool',
      author='Kevin Paul',
      author_email='kpaul@ucar.edu',
      url='https://github.com/NCAR/PyConform',
      download_url='https://github.com/NCAR/PyConform/tarball/v' + __version__,
      license='https://github.com/NCAR/PyConform/blob/master/LICENSE.rst',
      packages=['pyconform'],
      package_dir={'pyconform': 'source/pyconform'},
      package_data={'pyconform': ['LICENSE.rst']},
      scripts=['scripts/iconform', 'scripts/xconform', 'scripts/vardeps'],
      install_requires=['asaptools', 'netCDF4', 'ply']
      )
