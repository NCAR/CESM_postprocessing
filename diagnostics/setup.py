#!/usr/bin/env python
#
# based on template example from:
# https://github.com/hcarvalhoalves/python-package-template
#

from setuptools import setup, find_packages

import sys
import os

BASE_LOCATION = os.path.abspath(os.path.dirname(__file__))

VERSION_FILE = 'VERSION'
REQUIRES_FILE = 'requirements.txt'
DEPENDENCIES_FILE = 'requirements_links.txt'


def readfile(filename, func):
    try:
        with open(os.path.join(BASE_LOCATION, filename)) as f:
            data = func(f)
    except (IOError, IndexError):
        sys.stderr.write(u"""
Unable to open file: {0}
For development run:
    make version
    setup.py develop
To build a valid release, run:
    make release
""".format(filename))
        sys.exit(1)
    return data


def get_version():
    return readfile(VERSION_FILE, lambda f: f.read().strip())


def get_requires():
    return readfile(REQUIRES_FILE, lambda f: f.read().strip())


def get_dependencies():
    return readfile(DEPENDENCIES_FILE, lambda f: f.read().strip())

setup(
    name="diagnostics",
    author="Alice Bertini",
    author_email="aliceb@ucar.edu",
    packages=['diagnostics'],
    version=get_version(),
    scripts=['diagnostics/ocn/ocn_diags_generator.py','diagnostics/ocn/ocn_avg_generator.py',
             'diagnostics/atm/atm_diags_generator.py','diagnostics/atm/atm_avg_generator.py',
             'diagnostics/ice/ice_diags_generator.py','diagnostics/ice/ice_avg_generator.py',
             'diagnostics/lnd/lnd_diags_generator.py','diagnostics/lnd/lnd_avg_generator.py',
             'diagnostics/ilamb/ilamb_diags_generator.py',
             'diagnostics/lnd/lnd_regrid_generator.py'],
    install_requires=get_requires(),
    #dependency_links=get_dependencies(),
    include_package_data=True,
    zip_safe=True,
    test_suite="diagnostics.tests",
    description="CESM Python Diagnostics Tools.",
    use_2to3=True,
)
