#!/usr/bin/env python
"""
ASAP Python Toolbox -- Setup Script

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from setuptools import setup

exec(open('source/asaptools/version.py').read())

setup(name='ASAPTools',
      version=__version__,
      description='A collection of useful Python modules from the '
                  'Application Scalability And Performance (ASAP) group '
                  'at the National Center for Atmospheric Research',
      author='Kevin Paul',
      author_email='kpaul@ucar.edu',
      url='https://github.com/NCAR/ASAPPyTools',
      download_url='https://github.com/NCAR/ASAPPyTools/tarball/v' + __version__,
      license='https://github.com/NCAR/ASAPPyTools/blob/master/LICENSE.rst',
      packages=['asaptools'],
      package_dir={'asaptools': 'source/asaptools'},
      package_data={'asaptools': ['LICENSE.txt']},
      install_requires=['mpi4py>=1.3']
      )
