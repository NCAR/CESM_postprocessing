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

class Web_Reg_AvgDiff(IceDiagnosticPlot):
    """Regional Line Difference Plots
    """

    def __init__(self, reg_num, env):
        super(Web_Reg_AvgDiff, self).__init__()
        # Requires a region number 
        self.reg_num = reg_num

        # Derive all of the plot names

        # Set plot class description variables
        self._name = 'Regional Line Plots'
        self._shortname = 'web_reg_avg'
        self._template_file = 'web_reg_avg.tmpl'
        self.ncl_scripts = ['web_reg_avg.ncl']
        self.plot_env = env.copy()
        self.plot_env['MODEL_VS_OBS'] = False

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['REGION_NUMBER'] = self.reg_num
