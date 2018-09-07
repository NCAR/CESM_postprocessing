#!/usr/bin/env python

from distutils.core import setup

setup(name='PyAverager',
      version='0.9.16',
      description='Parallel Python Averager for Climate Data',
      author='Sheri Mickelson',
      author_email='mickelso@ucar.edu',
      url='https://www2.cisl.ucar.edu/tdd/asap/parallel-python-tools-post-processing-climate-data',
      packages=['pyaverager'],
      requires=['Nio', 'mpi4py']
     )
