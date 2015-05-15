#!/usr/bin/env python2
"""
This module provides utility functions for the diagnostics wrapper python scripts.
__________________________
Created on Apr 01, 2015

@author: NCAR - CSEG
"""

import os
import re
import subprocess
from cesm_utils import cesmEnvLib

#============================================================
# generate_ncl_plots - call a nclPlotFile via subprocess call
#============================================================
def generate_ncl_plots(env, nclPlotFile):
    """generate_plots_call - call a nclPlotFile via subprocess call

    Arguments:
    env (dictionary) - diagnostics system environment 
    nclPlotFile (string) - ncl plotting file name
    """
    cwd = os.getcwd()
    os.chdir(env['WORKDIR'])

    # check if the nclPlotFile exists - 
    # don't exit if it does not exists just print a warning.
    nclFile = '{0}/{1}'.format(env['NCLPATH'],nclPlotFile)
    rc, err_msg = cesmEnvLib.checkFile(nclFile, 'read')
    if rc:
        try:
            print('      calling NCL plot routine {0}'.format(nclPlotFile))
            subprocess.check_output( ['ncl',nclFile], env=env)
        except subprocess.CalledProcessError as e:
            print('WARNING: {0} call to {1} failed with error:'.format(self.name(), nclfile))
            print('    {0} - {1}'.format(e.cmd, e.output))
    else:
        print('{0}... continuing with additional plots.'.format(err_msg))
    os.chdir(cwd)

    return 0
