from __future__ import print_function

import sys

if sys.hexversion < 0x03070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 3.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

import traceback
import os
import shutil
import jinja2

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from .lnd_diags_plot_bc import LandDiagnosticPlot

class set_7(LandDiagnosticPlot):
    """Set 7 Plots
    """

    def __init__(self, env):
        super(set_7, self).__init__()

        # Set plot class description variables
        self._name = 'Set 7 Plots'
        self._shortname = 'set_7'
        self._template_file = 'set_7.tmpl'
        self.ncl_scripts = ['set_7.ncl']
        self.plot_env = env.copy()

    def check_prerequisites(self, env):
        # Set plot specific variables
        if (env['rtm_1'] == 'True'):
            env['rtm_1'] = 1
        else:
            env['rtm_1'] = 0
