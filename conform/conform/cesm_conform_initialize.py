#!/usr/bin/env python
"""Create the input specification for the tool that 
conforms data to experiment specifications 
from CESM time-series files. 

This script provides an interface between the CESM CASE environment 
and the Python package PyConform.

It resides in the $SRCROOT/postprocessing/cesm-env2
__________________________
Created on November, 2016

@author: CSEG <cseg@cgd.ucar.edu>
"""

#from __future__ import print_function
import sys

# check the system python version and require 3.7.x or greater
if sys.hexversion < 0x03070000:
    print(70 * '*')
    print('ERROR: {0} requires python >= 3.7.x. '.format(sys.argv[0]))
    print('It appears that you are running python {0}'.format(
        '.'.join(str(x) for x in sys.version_info[0:3])))
    print(70 * '*')
    sys.exit(1)

import argparse
import glob
import os
import sys
import traceback
import xml.etree.ElementTree as ET
import fnmatch
import subprocess
import netCDF4 as nc

from cesm_utils import cesmEnvLib


#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():

    """Process the command line arguments.
    """
    parser = argparse.ArgumentParser(
        description='cesm_conform_initialize:  CESM wrapper python program to create the input specification for the conform tool.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging output')

    parser.add_argument('--debug', nargs=1, required=False, type=int, default=0,
                        help='debugging verbosity level output: 0 = none, 1 = minimum, 2 = maximum. 0 is default')

    parser.add_argument('--caseroot', nargs=1, required=True,
                        help='fully quailfied path to case root directory')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = 'cesm_conform_generator.py ERROR: invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options

#============================================
# run_initialization - run the conform intialization to generate the input json files used by the conform tool
#============================================
def run_initialization(caseroot, debug):
    """initialize_main - initialize settings on rank 0 
    
    Arguments:
    caseroot (string) - case root
    debugMsg (object) - vprinter object for printing debugging messages

    """
    # setup envDict['id'] = 'value' parsed from the CASEROOT/[env_file_list] files
    env_file_list =  ['env_conform.xml','env_postprocess.xml']
    envDict = cesmEnvLib.readXML(caseroot, env_file_list)

    # debug print out the envDict
    #debugMsg('envDict after readXML = {0}'.format(envDict), header=True, verbosity=2)

    # get the variables needed to send to iconform
    global_attributes = envDict['CONFORM_GLOBAL_ATTRIBUTES']+","+caseroot+"/../archive_files/db.json"
    definitions = envDict['CONFORM_CESM_DEFINITIONS']
    exp_name = envDict['CONFORM_EXP_NAME']
    json_dir = envDict['CONFORM_JSON_DIRECTORY']+"/PyConform_input/"
    output_dir = envDict['CONFORM_OUTPUT_DIR']
    extra_field_json = envDict['CONFORM_EXTRA_FIELD_JSON']

    try:
        pipe = subprocess.Popen(['iconform -g {0} -d {1} -tt xml -e {2} -p {3} -o {4} -to True'.format(
            global_attributes, definitions, exp_name, output_dir, json_dir)], env=envDict, shell=True, stdout=subprocess.PIPE)
        output = pipe.communicate()[0]
        print('iconform:  {0}'.format(output))
        while pipe.poll() is None:
            time.sleep(0.5)
    except OSError as e:
        print('WARNING',e.errno,e.strerror)  
   
    try:
        pipe = subprocess.Popen(['cesm_extras -e {0} {1}/*'.format(
            extra_field_json, json_dir)], env=envDict, shell=True, stdout=subprocess.PIPE)
        output = pipe.communicate()[0]
        print('cesm_extras:  {0}'.format(output))
        while pipe.poll() is None:
            time.sleep(0.5)
    except OSError as e:
        print('WARNING',e.errno,e.strerror)
#======
# main
#======

def main(options):

   caseroot = options.caseroot[0]
   debug = options.debug
 
   run_initialization(caseroot, debug) 


if __name__ == "__main__":

    options = commandline_options()
    main(options)

    print('************************************************************')
    print("Successfully created the conform tool's input.")
    print('************************************************************') 
