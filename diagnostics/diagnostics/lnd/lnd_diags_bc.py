#!/usr/bin/env python2
"""Base class for land diagnostics
"""
from __future__ import print_function

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

class LandDiagnostic(object):
    """This is the base class defining the common interface for all
    land diagnostics
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
        endYr = (int(env['clim_first_yr_'+t]) + int(env['clim_num_yrs_'+t])) - 1  
        subdir = '{0}.{1}-{2}/{3}.{4}_{5}'.format(env['caseid_'+t], env['clim_first_yr_'+t], endYr,self._name.lower(), env['clim_first_yr_'+t], endYr)
        workdir = '{0}/climo/{1}/{2}'.format(env['PTMPDIR_'+t], env['caseid_'+t], subdir)

        if (scomm.is_manager()):
            print('DEBUG lnd_diags_bc.setup_workdir t = {0}'.format(t))
            print('DEBUG lnd_diags_bc.setup_workdir subdir = {0}'.format(subdir))
            print('DEBUG lnd_diags_bc.setup_workdir first workdir = {0}'.format(workdir))

            try:
                os.makedirs(workdir)
                os.makedirs(workdir+'/atm')
                os.makedirs(workdir+'/rof')
            except OSError as exception:
                if exception.errno != errno.EEXIST:
                    err_msg = 'ERROR: {0} problem accessing the working directory {1}'.format(self.__class__.__name__, workdir)
                    raise OSError(err_msg)

            for model in ('lnd', 'atm', 'rtm'):
                if ('rtm' in model):
                    m_dir = 'rof'
                else:
                    m_dir = model
                # create symbolic links between the old and new workdir and get the real names of the files
                old_workdir = env['PTMPDIR_'+t]+'/climo/'+env['caseid_'+t]+'/'+env['caseid_'+t]+'.'+str(env['clim_first_yr_'+t])+'-'+str(endYr)+'/'+m_dir
                env['case'+t+'_path_climo'] = workdir

                print('DEBUG lnd_diags_bc.setup_workdir old_workdir = {0}'.format(old_workdir))
                print('DEBUG lnd_diags_bc.setup_workdir case_t_path_climo = {0}'.format(env['case'+t+'_path_climo']))

                if 'lnd' in model:
                   workdir_mod = workdir
                else:
                    workdir_mod = workdir + '/' + m_dir
                # Add links to the new wkrdir that use the expected file names (existing climos have dates, the NCL do not like dates)
                print('DEBUG lnd_diags_bc.setup_workdir workdir_mod = {0}'.format(workdir_mod))
                
                climo_files = glob.glob(old_workdir+'/*.nc') 
                for climo_file in climo_files:
                    name_split = climo_file.split('.') # Split on '.'
                    if ('-' in name_split[-3]):
                        fn = str.join('.',name_split[:len(name_split)-3] + name_split[-2:]) #Piece together w/o the date, but still has old path 
                        path_split = fn.split('/') # Remove the path
                        new_fn = workdir_mod + '/' +path_split[-1] # Take file name and add it to new path
                        rc1, err_msg1 = cesmEnvLib.checkFile(new_fn, 'read')
                        if not rc1:
                            try:
                                os.symlink(climo_file,new_fn)
                            except:
                                print('INFO lnd_diags_bc.setup_workdir symlink {0} to {1} already exists.'.format(new_fn, climo_file))

        env['DIAG_BASE'] = env['PTMPDIR_1'] 
        env['PTMPDIR_'+t] = '{0}/climo/{1}/{2}'.format(env['PTMPDIR_'+t], env['caseid_'+t], subdir)

        if (scomm.is_manager()):
            print('DEBUG lnd_diags_bc.setup_workdir DIAG_BASE = {0}'.format(env['DIAG_BASE']))
            print('DEBUG lnd_diags_bc.setup_workdir PTMPDIR_t {0}'.format(env['PTMPDIR_'+t]))

        return env

    def check_prerequisites(self, env, scomm):
        """This method does some generic checks for the prerequisites
        that are common to all diagnostics
        """
        print('  Checking generic prerequisites for land diagnostics.')
        # setup the working directory for each diagnostics class
        env = self.setup_workdir(env, '1', scomm)
        if (env['MODEL_VS_MODEL'] == 'True'):
            env = self.setup_workdir(env, '2', scomm)

    def run_diagnostics(self, env, scomm):
        """ base method for calling diagnostics
        """
        return

# todo move these classes to another file
class RecoverableError(RuntimeError):
    pass

class UnknownDiagType(RecoverableError):
    pass

