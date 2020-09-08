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
from .ice_diags_plot_bc import IceDiagnosticPlot

class Web_Hem_Avg_wLENS(IceDiagnosticPlot):
    """Web_Hem_Avg_wLENS Plots
    """

    def __init__(self, env):
        super(Web_Hem_Avg_wLENS, self).__init__()

        # Derive all of the plot names

        # Set plot class description variables
        self._name = 'Web_Hem_Avg_wLENS Plots'
        self._shortname = 'Web_Hem_Avg_wLENS'
        self._template_file = 'web_hem_avg_wLENS.tmpl'
        self.ncl_scripts = ['web_hem_avg_wLENS.ncl']
        self.plot_env = env.copy()
        self.plot_env['MODEL_VS_MODEL'] = False

    def check_prerequisites(self, env):
        # Set plot specific variables
        preq = 'No variables to set'
