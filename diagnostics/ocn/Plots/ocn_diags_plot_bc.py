#!/usr/bin/env python2
"""Base class for ocean diagnostics plots
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

# import the diag_utils module
#if os.path.isdir('../diag_utils'):
#    sys.path.append('../diag_utils')
#    import diag_utils
#else:
#    err_msg = 'ocn_diags_plot_bc.py ERROR: diag_utils.py required and not found in ../diag_utils'
#    raise OSError(err_msg)

# import the cesm_utils module
if os.path.isdir('../../cesm_utils'):
    sys.path.append('../../cesm_utils')
    import cesmEnvLib
else:
    err_msg = 'ocn_diags_plot_bc.py ERROR: cesmEnvLib.py required and not found in ../../cesm_utils'
    raise OSError(err_msg)


class OceanDiagnosticPlot(object):
    """This is the base class defining the common interface for all
    ocean diagnostic plots

    """
    def __init__(self):
        self._html = ''
        self._name = 'Base'
        self._shortname = 'Base'
        self._template_file = 'base.tmpl'

    def name(self):
        return self._name

    def shortname(self):
        return self._shortname

    def check_prerequisites(self, env):
        """This method does some generic checks for the plots prerequisites
        that are common to all plots

        """
        print('  Checking generic prerequisites for ocean diagnostics plot.')
        print('  Setup the environment for NCL')
        cesmEnvLib.setXmlEnv(env)

    def generate_plots(self, env):
        """This is the base class for calling plots
        """
        raise RuntimeError ('Generate plots must be implimented in the sub-class')
    
    def get_html(self, workdir):
        """This method returns the html snippet for the plot.
        """
        self._create_html(workdir)
        return self._html

# todo move these classes to another file
class RecoverableError(RuntimeError):
    pass


class UnknownPlotType(RecoverableError):
    pass

