#!/usr/bin/env python
"""Base class for ocean diagnostics plots
"""
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
import subprocess

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

class OceanDiagnosticPlot(object):
    """This is the base class defining the common interface for all
    ocean diagnostic plots

    """
    def __init__(self):
        self._html = ''
        self._name = 'Base'
        self._shortname = 'Base'
        self._template_file = 'base.tmpl'
        self._files = list()

    def name(self):
        return self._name

    def shortname(self):
        return self._shortname

    def check_prerequisites(self, env):
        """This method does some generic checks for the plots prerequisites
        that are common to all plots

        """
        print('  Checking generic prerequisites for ocean diagnostics plot.')

        # set SEASAVGFILE env var to the envDict['MAVGFILE'] file
        env['SEASAVGFILE'] = env['MAVGFILE']

        # set SEASAVGTEMP env var to the envDict['MAVGFILE'] file
        env['SEASAVGTEMP'] = env['MAVGFILE']

        # set SEASAVGSALT env var to the envDict['MAVGFILE'] file
        env['SEASAVGSALT'] = env['MAVGFILE']

        cesmEnvLib.setXmlEnv(env)

    def generate_plots(self, env):
        """This is the base class for calling plots
        """
        raise RuntimeError ('Generate plots must be implimented in the sub-class')

    def get_html(self, workdir, templatePath, imgFormat):
        """This method returns the html snippet for the plot.
        """
        self._create_html(workdir, templatePath, imgFormat)
        return self._shortname, self._html

    def _convert_plots(self, workdir, imgFormat, files):
        """ This method converts the postscript plots to imgFormat
        """
        splitPath = list()
        psFiles = list()
        psFiles = sorted(files)

        # check if the convert command exists
        rc = cesmEnvLib.which('convert')
        if rc is not None and imgFormat.lower() in ['png','gif']:
            for psFile in psFiles:

                sourceFile = '{0}/{1}.ps'.format(workdir, psFile)
##                print('...... convert source file {0}'.format(sourceFile))
                # check if the sourceFile exists
                rc, err_msg = cesmEnvLib.checkFile(sourceFile,'read')

                # check if the image file already exists and remove it to regen
                imgFile = '{0}/{1}.{2}'.format(workdir, psFile, imgFormat)
                rc1, err_msg1 = cesmEnvLib.checkFile(imgFile,'write')
                if rc and rc1:
                    print('...... removing {0} before recreating'.format(imgFile))
                    os.remove(imgFile)

                    # convert the image from ps to imgFormat
                    try:
                        pipe = subprocess.check_call( ['convert', '-trim', '-bordercolor', 'white', '-border', '5x5', '-density', '95', '{0}'.format(sourceFile),'{0}'.format(imgFile)])
##                   print('...... created {0} size = {1}'.format(imgFile, os.path.getsize(imgFile)))
                    except subprocess.CalledProcessError as e:
                        print('...... failed to create {0}'.format(imgFile))
                        print('WARNING: convert_plots call to convert failed with error:')
                        print('    {0}'.format(e.output))
                else:
                    continue
        else:
            print('WARNING: convert_plots unable to find convert command in path.')
            print('     Unable to convert ps formatted plots to {0}'.format(imgFormat))
        
# todo move these classes to another file
class RecoverableError(RuntimeError):
    pass


class UnknownPlotType(RecoverableError):
    pass

