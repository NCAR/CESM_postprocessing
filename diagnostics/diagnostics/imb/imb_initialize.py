#!/usr/bin/env python
"""Generate input for ILAMB

This script provides an interface between:
1. the CESM case environment and/or postprocessing environment
2. the ilamb diagnostics environment defined in XML files

It is called from the run script and resides in the $SRCROOT/postprocessing/cesm-env2

Assumptions - does own internal averaging and CMOR

Author: CSEG <cseg@cgd.ucar.edu>
"""

from __future__ import print_function
import sys

# check the system python version and require 2.7.x or greater
if sys.hexversion < 0x02070000:
    print(70 * '*')
    print('ERROR: {0} requires python >= 2.7.x. '.format(sys.argv[0]))
    print('It appears that you are running python {0}'.format(
        '.'.join(str(x) for x in sys.version_info[0:3])))
    print(70 * '*')
    sys.exit(1)

# import core python modules
import argparse
import fnmatch
import errno
import os
import re
import shutil
import subprocess
import traceback

# import local modules for postprocessing
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

import jinja2

# define global debug message string variable
debugMsg = ''

#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():
    """Process the command line arguments.
    """
    parser = argparse.ArgumentParser(
        description='imb_generator: CESM post processing tool to generate input for IMB diagnostics runs.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging '
                        'output')

    parser.add_argument('--debug', nargs=1, required=False, type=int, default=[0],
                        help='debugging verbosity level output: 0 = none, 1 = minimum, 2 = maximum. 0 is default')

    parser.add_argument('--caseroot', nargs=1, required=True, 
                        help='fully quailfied path to case root directory')

    parser.add_argument('--standalone', action='store_true',
                        help='switch to indicate stand-alone post processing caseroot')

    parser.add_argument('--imb-name', nargs=1, required=True,
                        help='name of the imb model being run, e.g. ilamb or iomb.')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = ' ERROR: lnd_diags_generator.py invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options


#================================================
# setup_config
#================================================
def setup_config(envDict):
    """setup_diags - read the XML directives on which configuration file to create

    envDict (dictionary) - environment dictionary
    
    Return: none
    """
    config_dir = envDict["CONFIG_DIRECTORY"]
    config_name = envDict["CONFIG_NAME"]
    print(envDict["POSTPROCESS_PATH"])
    config_path = os.path.join(envDict["POSTPROCESS_PATH"], os.path.join(config_dir, config_name))
    dest_name = os.path.join(envDict["PP_CASE_PATH"], config_name)
    print("Copying imb configuration file:")
    print("    from : {0}".format(config_path))
    print("    to : {0}".format(dest_name))
    if not os.path.exists(config_path):
        raise RuntimeError("configuration file does not exist! {0}".format(config_path))
    else:
        shutil.copy2(config_path, dest_name)
    if not os.path.exists(dest_name):
        raise RuntimeError("Copy failed: {0}".format(dest_name))
    
    return None

#============================================
# initialize_main - initialization from main
#============================================
def initialize_main(envDict, caseroot, debugMsg, standalone, imb_name):
    """initialize_main - initialize settings on rank 0 
    
    Arguments:
    envDict (dictionary) - environment dictionary
    caseroot (string) - case root
    debugMsg (object) - vprinter object for printing debugging messages
    standalone (boolean) - specify if postprocess caseroot is standalone (true) of not (false)

    Return:
    envDict (dictionary) - environment dictionary
    """
    env_file_list =  ['./env_postprocess.xml', './env_diags_{0}.xml'.format(imb_name)]

    debugMsg('in initialize_main before readXML', header=True, verbosity=1)

    envDict = cesmEnvLib.readXML(caseroot, env_file_list)

    # debug print out the envDict
    debugMsg('envDict after readXML = {0}'.format(envDict), header=True, verbosity=2)

    # refer to the caseroot that was specified on the command line instead of what
    # is read in the environment as the caseroot may have changed from what is listed
    # in the env xml
    envDict['CASEROOT'] = caseroot

    diag_name = "{0}DIAG".format(imb_name.upper())
    # add the os.environ['PATH'] to the envDict['PATH']
    diag_path = "{0}_PATH".format(diag_name)
    envDict[diag_path] = os.pathsep + os.environ['PATH']

    # strip the ILAMBDIAG_ or IOMBDIAG_ prefix from the envDict entries before setting the 
    # enviroment to allow for compatibility with all the diag routine calls
    envDict = diagUtilsLib.strip_prefix(envDict, '{0}_'.format(diag_name))

    debugMsg('envDict OUTPUTROOT = {0}'.format(envDict['OUTPUTROOT']), header=True, verbosity=1)
    # ILAMB requires output directory to already exist
    if not os.path.exists(envDict['OUTPUTROOT']):
        os.makedirs(envDict['OUTPUTROOT'])

    debugMsg('in initialize_main before path.append', header=True, verbosity=1)
    # setup the working directories
    sys.path.append(envDict['PATH'])

    debugMsg('in initialize_main get machine name', header=True, verbosity=1)
    hostname = cesmEnvLib.get_hostname()
    envDict['MACH'] = cesmEnvLib.get_machine_name(hostname, '{0}/Machines/machine_postprocess.xml'.format(envDict['POSTPROCESS_PATH']))

    return envDict

def expand_batch_vars(envDict, imb_name):
    """Expand the user supplied command line options from the XML file in the batch submission script
    """
    templateVars = {}
    try:
        templateVars['imb_exe'] = envDict["EXENAME"]
    except:
        raise RuntimeError('EXENAME must be specified in the imb env xml file.')

    try:
        templateVars['imb_options'] = envDict["CLI"]
    except:
        raise RuntimeError('CLI_OPTIONS must be specified in the imb env xml file.')

##    diag_root = "{0}_ROOT".format(imb_name.upper()) 
    # The ROOT env var should always be set to ILAMB_ROOT regardless of whether running ILAMB or IOMB
    diag_root = "ILAMB_ROOT"
    env_vars = []
    env_vars.append("export {0}={1}".format('MPLBACKEND', envDict['MPLBACKEND']))
    env_vars.append("export {0}={1}".format(diag_root, envDict[diag_root]))
    templateVars['imb_env_vars'] = env_vars

    template_filename = '{0}_diagnostics.tmpl'.format(imb_name)
    templateLoader = jinja2.FileSystemLoader( searchpath='{0}'.format(envDict["CASEROOT"]) )
    templateEnv = jinja2.Environment( loader=templateLoader )
    template = templateEnv.get_template( template_filename )
    
    # render this template into the runScript string
    runScript = template.render( templateVars )

    # write the runScript to the outFile
    batch_filename = '{0}_diagnostics'.format(imb_name)
    outFile = os.path.join(envDict["CASEROOT"], batch_filename)
    with open( outFile, 'w') as fh:
        fh.write(runScript)

    # make batch script permission executable?
    try:
        subprocess.check_call( ['chmod', '+x', outFile ] )
    except subprocess.CalledProcessError as e:
        print('imb_initialize: {0} could not be made executable'.format(outFile))
        print('WARNING: manually add execute permission to {0}'.format(outFile))
        print('    {0} - {1}'.format(e.cmd, e.output))


    # create a template and batch for DAV slurm
    if envDict['MACH'] == 'cheyenne' or envDict['MACH'] == 'dav':
        hostname = 'dav'
        template_filename = '{0}_diagnostics_{1}.tmpl'.format(imb_name, hostname)
        templateLoader = jinja2.FileSystemLoader( searchpath='{0}'.format(envDict["CASEROOT"]) )
        templateEnv = jinja2.Environment( loader=templateLoader )
        template = templateEnv.get_template( template_filename )
    
        # render this template into the runScript string
        runScript = template.render( templateVars )

        # write the runScript to the outFile
        batch_filename = '{0}_diagnostics_{1}'.format(imb_name, hostname)
        outFile = os.path.join(envDict["CASEROOT"], batch_filename)
        with open( outFile, 'w') as fh:
            fh.write(runScript)

        # make batch script permission executable?
        try:
            subprocess.check_call( ['chmod', '+x', outFile ] )
        except subprocess.CalledProcessError as e:
            print('imb_initialize: {0} could not be made executable'.format(outFile))
            print('WARNING: manually add execute permission to {0}'.format(outFile))
            print('    {0} - {1}'.format(e.cmd, e.output))


#======
# main
#======

def main(options, main_comm, debugMsg, timer):
    """Unlike the NCL based diagnostics, IMB has it's own
    parallelization and partitioning infrastructure.

    The master processor is the only task that is needed by this
    script. We need to open the env_imb_diags.xml file, setup the
    configuration file, then exit. The batch script will launch
    ilamb-run in parallel.

    Arguments:
    options (object) - command line options
    main_comm (object) - MPI simple communicator object
    debugMsg (object) - vprinter object for printing debugging messages
    timer (object) - timer object for keeping times

    """

    # initialize the environment dictionary
    envDict = dict()

    imb_name = options.imb_name[0]
    known_models = ['ilamb', 'iomb' ]
    if imb_name not in known_models:
        msg = "ERROR: unknown imb '{0}'. Known values are: {1}".format(imb_name, known_models)
        raise RuntimeError(msg)

    # CASEROOT is given on the command line as required option --caseroot
    if main_comm.is_manager():
        caseroot = options.caseroot[0]
        print(caseroot)
        debugMsg('caseroot = {0}'.format(caseroot), header=True, verbosity=1)

        debugMsg('calling initialize_main', header=True, verbosity=1)
        envDict = initialize_main(envDict, caseroot, debugMsg, options.standalone, imb_name)

        debugMsg('calling setup_config', header=True, verbosity=1)
        setup_config(envDict)

        debugMsg('expanding variables in batch script', header=True, verbosity=1)
        expand_batch_vars(envDict, imb_name)

    main_comm.sync()



#===================================


if __name__ == "__main__":
    # initialize simplecomm object
    main_comm = simplecomm.create_comm(serial=True)

    # setup an overall timer
    timer = timekeeper.TimeKeeper()

    # get commandline options
    options = commandline_options()

    # initialize global vprinter object for printing debug messages
    print("debug level = {0}".format(options.debug[0]))
    if options.debug:
        header = "[" + str(main_comm.get_rank()) + "/" + str(main_comm.get_size()) + "]: DEBUG... "
        debugMsg = vprinter.VPrinter(header=header, verbosity=options.debug[0])
   
    try:
        timer.start("Total Time")
        status = main(options, main_comm, debugMsg, timer)
        main_comm.sync()
        timer.stop("Total Time")
        if main_comm.is_manager():
            name = options.imb_name[0]
            print('***************************************************')
            print('Successfully completed generating {0} configuration file.'.format(name))
            print('Total Time: {0} seconds'.format(timer.get_time("Total Time")))
            print('Now you can sumbit {0}_diagnostics to the batch system.'.format(name))
            print('***************************************************')
        sys.exit(status)

    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)

