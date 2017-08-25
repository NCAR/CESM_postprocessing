#!/usr/bin/env python
from setuptools import setup
from codecs import open
from os import path

here = path.abspath(path.dirname(__file__))
with open(path.join(here, 'README.rst'), encoding='utf-8') as f:
    long_description = f.read()

setup(
    name='ILAMB',
    version='2.1',
    description='The International Land Model Benchmarking Package',
    long_description=long_description,
    url='https://bitbucket.org/ncollier/ilamb',
    author='Nathan Collier',
    author_email='nathaniel.collier@gmail.com',
    #license='MIT',
    classifiers=[
        'Development Status :: 5 - Production/Stable',
        'Intended Audience :: Science/Research',
        'Topic :: Scientific/Engineering',
        #'License :: OSI Approved :: MIT License',
        'Operating System :: MacOS',
        'Operating System :: POSIX',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
    ],
    keywords=['benchmarking','earth system modeling','climate modeling','model intercomparison'],
    packages=['ILAMB'],
    package_dir={'ILAMB' : 'src/ILAMB'},
    scripts=['bin/ilamb-run'],
    install_requires=['numpy>=1.9.2',
                      'matplotlib>=1.4.3',
                      #'basemap>=1.0.7', # basemap is in pypi but broken, need to manually install
                      'netCDF4>=1.1.4,<=1.2.4', # upper limit is for cfunits
                      'cfunits>=1.1.4',
                      'sympy>=0.7.6',
                      'mpi4py>=1.3.1']
)
