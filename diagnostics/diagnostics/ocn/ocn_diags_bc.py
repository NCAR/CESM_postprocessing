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

import errno
import os
import traceback

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# import the helper utility modules
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

    def setup_workdir(self, env):
        """This method sets up the unique working directory for a given diagnostic type
        """
        # create the working directory first before calling the base class prerequisites 
##        subdir = '{0}'.format(self._name.lower())
        subdir = '{0}'.format(self._name)
        workdir = '{0}/{1}'.format(env['WORKDIR'], subdir)
        print('working directory = {0}'.format(workdir))

        try:
            os.makedirs(workdir)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                err_msg = 'ERROR: {0} problem accessing the working directory {1}'.format(self.__class__.__name__, workdir)
                raise OSError(err_msg)

        # create symbolic links between the tavgdir and the workdir and set the names of the mavg and tavg files for the diagnostics
        control = False
        env['WORKDIR'] = workdir
        env['MAVGFILE'], env['TAVGFILE'] = diagUtilsLib.createLinks(env['YEAR0'], env['YEAR1'], env['TAVGDIR'], env['WORKDIR'], env['CASE'], control)

        return env

    def check_prerequisites(self, env):
        """This method does some generic checks for the prerequisites
        that are common to all diagnostics
        """
        print('  Checking generic prerequisites for ocean diagnostics.')
        # setup the working directory for each diagnostics class
        env = self.setup_workdir(env)

        # check that temperature observation TOBSFILE exists and is readable
        sourceFile = '{0}/{1}'.format(env['TSOBSDIR'], env['TOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'], env['TOBSFILE'])
        diagUtilsLib.createSymLink(sourceFile, linkFile)

        # check that salinity observation SOBSFILE exists and is readable
        sourceFile = '{0}/{1}'.format(env['TSOBSDIR'], env['SOBSFILE'])
        linkFile = '{0}/{1}'.format(env['WORKDIR'], env['SOBSFILE'])
        diagUtilsLib.createSymLink(sourceFile, linkFile)

    def run_diagnostics(self, env, scomm):
        """ base method for calling diagnostics
        """
        return

# todo move these classes to another file
class RecoverableError(RuntimeError):
    pass

class UnknownDiagType(RecoverableError):
    pass

class PrerequisitesError(RecoverableError):
    pass

