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
        self._title = 'Base'
        self.scomm = ''

    def name(self):
        return self._name

    def title(self):
        return self._title

    def check_prerequisites(self, env):
        """This method does some generic checks for the prerequisites
        that are common to all diagnostics
        """
        print('  Checking generic prerequisites for ocean diagnostics.')

        # check that temperature observation TOBSFILE exists and is readable
        rc, err_msg = cesmEnvLib.checkFile('{0}/{1}'.format(env['TSOBSDIR'], env['TOBSFILE']), 'read')
        if not rc:
            raise OSError(err_msg)

        # set a link to TSOBSDIR/TOBSFILE
        sourceFile = '{0}/{1}'.format(env['TSOBSDIR'], env['TOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'], env['TOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
        if rc:
            rc1, err_msg1 = cesmEnvLib.checkFile(linkFile, 'read')
            if not rc1:
                os.symlink(sourceFile, linkFile)
        else:
            raise OSError(err_msg)

        # check that salinity observation SOBSFILE exists and is readable
        rc, err_msg = cesmEnvLib.checkFile('{0}/{1}'.format(env['TSOBSDIR'], env['SOBSFILE']), 'read')
        if not rc:
            raise OSError(err_msg)

        # set a link to TSOBSDIR/SOBSFILE
        sourceFile = '{0}/{1}'.format(env['TSOBSDIR'], env['SOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'], env['SOBSFILE'])
        rc, err_msg = cesmEnvLib.checkFile(sourceFile, 'read')
        if rc:
            rc1, err_msg1 = cesmEnvLib.checkFile(linkFile, 'read')
            if not rc1:
                os.symlink(sourceFile, linkFile)
        else:
            raise OSError(err_msg)

    def run_diagnostics(self, env, scomm, debugMsg):
        """ base method for calling diagnostics
        """
        return

# todo move these classes to another file
class RecoverableError(RuntimeError):
    pass

class UnknownDiagType(RecoverableError):
    pass

