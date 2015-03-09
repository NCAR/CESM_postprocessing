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
if os.path.isdir('../diag_utils'):
    sys.path.append('../diag_utils')
    import diag_utils
else:
    err_msg = 'ocn_diags_plot_bc.py ERROR: diag_utils.py required and not found in ../../diag_utils'
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
        that are common to all plots?

        """
        print('  Checking generic prerequisites for ocean diagnostics plot.')
        # check that NCL and ncks are installed and accessible
        try:
            subprocess.check_output( ['ncl', '-V'], env=env)
        except subprocess.CalledProcessError as e:
            print('NCL is required to run the ocean diagnostics package')
            print('ERROR: {0} call to ncl failed with error:'.format(self.name()))
            print('    {0} - {1}'.format(e.cmd, e.output))
            sys.exit(1)

        try:
            subprocess.check_output( ['ncks', '--version'], env=env)
        except subprocess.CalledProcessError as e:
            print('NCO ncks is required to run the ocean diagnostics package')
            print('ERROR: {0} call to ncks failed with error:'.format(self.name()))
            print('    {0} - {1}'.format(e.cmd, e.output))
            sys.exit(1)

        # generate the global zonal average file used for most of the plots
        zaFile = '{0}/za_{1}'.format(env['WORKDIR'],env['TAVGFILE'])
        rc, err_msg = diag_utils.checkFile(zaFile, 'read')
        if not rc:
            print('     Checking on the zonal average (za) file compiled fortran code.')
            # check that the za executable exists
            zaCommand = '{0}/za'.format(env['TOOLPATH'])
            rc, err_msg = diag_utils.checkFile(zaCommand, 'exec')
            if not rc:
                raise OSError(err_msg)

            # call the za fortran code from within the workdir
            cwd = os.getcwd()
            os.chdir(env['WORKDIR'])
            try:
                subprocess.check_output( [zaCommand,'-O','-time_const','-grid_file',env['GRIDFILE'],env['TAVGFILE']], env=env)
            except subprocess.CalledProcessError as e:
                print('ERROR: {0} call to {1} failed with error:'.format(self.name(), zaCommand))
                print('    {0} - {1}'.format(e.cmd, e.output))
                sys.exit(1)

            os.chdir(cwd)


    def generate_plots(self, env, nclPlotFile):
        """This method generates the plots described in the class
        """
        cwd = os.getcwd()
        os.chdir(env['WORKDIR'])

        # check if the nclPlotFile exists - 
        # don't exit if it does not exists just print a warning.
        nclFile = '{0}/{1}'.format(env['NCLPATH'],nclPlotFile)
        rc, err_msg = diag_utils.checkFile(nclFile, 'read')
        if rc:
            try:
                subprocess.check_output( ['ncl',nclFile], env=env)
            except subprocess.CalledProcessError as e:
                print('WARNING: {0} call to {1} failed with error:'.format(self.name(), nclfile))
                print('    {0} - {1}'.format(e.cmd, e.output))
        else:
            print('{0}... continuing with additional plots.'.format(err_msg))
        os.chdir(cwd)

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

