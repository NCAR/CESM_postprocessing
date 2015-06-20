#!/usr/bin/env python2
"""Base class for ocean diagnostics
"""
from __future__ import print_function

import sys

if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

import traceback
import os
import subprocess

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

class OceanDiagnostic(object):
    """This is the base class defining the common interface for all
    ocean diagnostics

    """
    def __init__(self):
        self._name = 'Base'

    def name(self):
        return self._name

    def check_prerequisites(self, env):
        """This method does some generic checks for the prerequisites
        that are common to all diagnostics

        """
        print('  Checking generic prerequisites for ocean diagnostics.')
        # check that model  climo files exist as they are needed for all diag types


# todo move these classes to another file
class RecoverableError(RuntimeError):
    pass


class UnknownDiagType(RecoverableError):
    pass

