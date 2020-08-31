#!/usr/bin/env python
"""Base class for ice diagnostics
"""
from __future__ import print_function

import shutil
import sys
import glob

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

class IceDiagnostic(object):
    """This is the base class defining the common interface for all
    ice diagnostics
    """
    def __init__(self):
        self._name = 'Base'
        self._title = 'Base'
        self.scomm = ''

    def name(self):
        return self._name

    def title(self):
        return self._title

    def setup_workdir(self, env, t, scomm):
        """This method sets up the unique working directory for a given diagnostic type
        """
        # create the working directory first before calling the base class prerequisites
        avg_BEGYR = (int(env['ENDYR_'+t]) - int(env['YRS_TO_AVG'])) + 1
        subdir = '{0}.{1}-{2}/{3}.{4}_{5}'.format(env['CASE_TO_'+t], avg_BEGYR, env['ENDYR_'+t],self._name.lower(), str(avg_BEGYR), env['ENDYR_'+t])
        workdir = '{0}/{1}'.format(env['PATH_CLIMO_'+t], subdir)
        env['CLIMO_'+t] = workdir

        if (scomm.is_manager()):
            if env['CLEANUP_FILES'].lower() in ['t','true'] and os.path.exists(workdir):
                shutil.rmtree(workdir)
            try:
                os.makedirs(workdir)
            except OSError as exception:
                if exception.errno != errno.EEXIST:
                    err_msg = 'ERROR: {0} problem accessing the working directory {1}'.format(self.__class__.__name__, workdir)
                    raise OSError(err_msg)

        # create symbolic links between the old and new workdir and get the real names of the files
        old_workdir = env['PATH_CLIMO_'+t]+'/'+env['CASE_TO_'+t]+'.'+str(avg_BEGYR)+'-'+env['ENDYR_'+t]
        env['PATH_CLIMO_'+t] = workdir

        if (scomm.is_manager()):
            print('calling name = {0}'.format(self._name))
            print('subdir = {0}'.format(subdir))
            print('workdir = {0}'.format(workdir))
            print('old_workdir = {0}'.format(old_workdir))

        # Add links to the new wkdir that use the expected file names (existing climos have dates, the NCL do not like dates)
        if (scomm.is_manager()):
            climo_files = glob.glob(old_workdir+'/*.nc') 
            for climo_file in climo_files:
                if ('ice_vol_' in climo_file):
                    new_fn = workdir + '/' + os.path.basename(climo_file)
##                    if (scomm.is_manager()):
##                        print('1. ice_diags_bc.py: new_fn = {0}'.format(new_fn))
                else:
                    name_split = climo_file.split('.') # Split on '.'
                    if ('-' in name_split[-3]):
                        fn = str.join('.',name_split[:len(name_split)-3] + name_split[-2:]) #Piece together w/o the date, but still has old path 
                        if (scomm.is_manager()):
                            print('1. fn = {0}'.format(fn))
                        path_split = fn.split('/') # Remove the path
                        if ('jfm_climo' in path_split[-1]):
                            s = 'jfm'
                        elif ('amj_climo' in path_split[-1]):
                            s = 'amj'
                        elif ('jas_climo' in path_split[-1]):
                            s = 'jas'
                        elif ('ond_climo' in path_split[-1]):
                            s = 'ond'
                        elif ('fm_climo' in path_split[-1]):
                            s = 'fm'
                        elif ('on_climo' in path_split[-1]):
                            s = 'on'
                        elif ('_ANN_climo' in path_split[-1]):
                            s = 'ann'
                        else:
                            s = None
                        if s is not None:
                            new_fn = workdir + '/' + s + '_avg_' + str(avg_BEGYR).zfill(4) + '-' + env['ENDYR_'+t].zfill(4) + '.nc' 
##                            if (scomm.is_manager()):
##                                print('2. ice_diags_bc.py s = {0}: new_fn = {1}'.format(s, new_fn))
                        else:
                            new_fn = workdir + '/' +path_split[-1] # Take file name and add it to new path
##                            if (scomm.is_manager()):
##                                print('3. ice_diags_bc.py: new_fn = {0}'.format(new_fn))
                    else:
                        new_fn = workdir + '/' + os.path.basename(climo_file)
##                        if (scomm.is_manager()):
##                            print('4. ice_diags_bc.py: new_fn = {0}'.format(new_fn))
                rc1, err_msg1 = cesmEnvLib.checkFile(new_fn, 'read')
                if not rc1:
                    os.symlink(climo_file,new_fn)
                else:
                    print('ice_diags_bc.py: unable to create link to file {0}'.format(new_fn))
        return env

    def check_prerequisites(self, env, scomm):
        """This method does some generic checks for the prerequisites
        that are common to all diagnostics
        """
        print('  Checking generic prerequisites for ice diagnostics.')
        # setup the working directory for each diagnostics class
        env = self.setup_workdir(env, 'CONT', scomm)
        if (env['MODEL_VS_MODEL'] == 'True'):
            env = self.setup_workdir(env, 'DIFF', scomm)

    def run_diagnostics(self, env, scomm):
        """ base method for calling diagnostics
        """
        return

# todo move these classes to another file
class RecoverableError(RuntimeError):
    pass

class UnknownDiagType(RecoverableError):
    pass

