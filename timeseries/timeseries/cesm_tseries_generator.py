#!/usr/bin/env python2
"""Generate variable time-series files from a CESM case

This script provides an interface between the CESM CASE environment 
and the Python package for time slice-to-series operation, pyReshaper.

It resides in the $SRCROOT/postprocessing/cesm-env2
__________________________
Created on May, 2014

@author: CSEG <cseg@cgd.ucar.edu>
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

import argparse
import glob
import os
import pprint
import re
import string
import sys
import traceback
import xml.etree.ElementTree as ET

from cesm_utils import cesmEnvLib

# import the MPI related module
from asaptools import partition, simplecomm

# load the pyreshaper modules
from pyreshaper import specification, reshaper

#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():
    """Process the command line arguments.
    """
    parser = argparse.ArgumentParser(
        description='cesm_tseries_generator: CESM wrapper python program to create variable time series files from history time slice files.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging output')

    parser.add_argument('--debug', nargs=1, required=False, type=int, default=0,
                        help='debugging verbosity level output: 0 = none, 1 = minimum, 2 = maximum. 0 is default')

    parser.add_argument('--caseroot', nargs=1, required=True, 
                        help='fully quailfied path to case root directory')

    parser.add_argument('--standalone', action='store_true',
                        help='switch to indicate stand-alone post processing caseroot')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = 'cesm_tseries_generator.py ERROR: invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options

#==============================================================================================
# readArchiveXML - read the $CASEROOT/env_timeseries.xml file and build the pyReshaper classes
#==============================================================================================
def readArchiveXML(caseroot, dout_s_root, casename, standalone, debug):
    """ reads the $CASEROOT/env_timeseries.xml file and builds a fully defined list of 
         reshaper specifications to be passed to the pyReshaper tool.

    Arguments:
    caseroot (string) - case root path
    dout_s_root (string) - short term archive root path
    casename (string) - casename
    standalone (boolean) - logical to indicate if postprocessing case is stand-alone or not
    """
    specifiers = list()
    xml_tree = ET.ElementTree()

    # get path to env_timeseries.xml file
    env_timeseries = '{0}/postprocess/env_timeseries.xml'.format(caseroot)
    if standalone:
        env_timeseries = '{0}/env_timeseries.xml'.format(caseroot)

    # check if the env_timeseries.xml file exists
    if ( not os.path.isfile(env_timeseries) ):
        err_msg = "cesm_tseries_generator.py ERROR: {0}/env_timeseries.xml does not exist.".format(caseroot)
        raise OSError(err_msg)
    else:
        # parse the xml
        xml_tree.parse(env_timeseries)

        # loop through all the comp_archive_spec elements to find the tseries related elements
        for comp_archive_spec in xml_tree.findall("components/comp_archive_spec"):
            comp = comp_archive_spec.get("name")
            rootdir = comp_archive_spec.find("rootdir").text
            multi_instance = comp_archive_spec.find("multi_instance").text

            # for now, set instance value to empty string implying only 1 instance
            instance = ""

            # loop through all the files/file_spec elements
            for file_spec in comp_archive_spec.findall("files/file_extension"):
                file_extension = file_spec.get("suffix")
                subdir = file_spec.find("subdir").text

                # check if tseries_create is an element for this file_spec
                if file_spec.find("tseries_create") is not None:
                    tseries_create = file_spec.find("tseries_create").text

                    # check if the tseries_create element is set to TRUE            
                    if tseries_create.upper() in ["T","TRUE"]:

                        # check if tseries_format is an element for this file_spec and if it is valid
                        if file_spec.find("tseries_output_format") is not None:
                            tseries_output_format = file_spec.find("tseries_output_format").text
                            if tseries_output_format not in ["netcdf","netcdf4","netcdf4c"]:
                                err_msg = "cesm_tseries_generator.py error: tseries_output_format invalid for data stream {0}.*.{1}".format(comp,file_extension)
                                raise TypeError(err_msg)
                        else:
                            err_msg = "cesm_tseries_generator.py error: tseries_output_format undefined for data stream {0}.*.{1}".format(comp,file_extension)
                            raise TypeError(err_msg)


                        # check if the tseries_output_subdir is specified and create the tseries_output_dir
                        if file_spec.find("tseries_output_subdir") is not None:
                            tseries_output_subdir = file_spec.find("tseries_output_subdir").text
                            tseries_output_dir = '/'.join( [dout_s_root, rootdir,tseries_output_subdir] )
                            if not os.path.exists(tseries_output_dir):
                                os.makedirs(tseries_output_dir)
                        else:
                            err_msg = "cesm_tseries_generator.py error: tseries_output_subdir undefined for data stream {0}.*.{1}".format(comp,file_extension)
                            raise TypeError(err_msg)

                        # check if tseries_tper is specified and is valid 
                        if file_spec.find("tseries_tper") is not None:
                            tseries_tper = file_spec.find("tseries_tper").text
                            if tseries_tper not in ["annual","yearly","monthly","weekly","daily","hourly6","hourly3","hourly1","min30"]:
                                err_msg = "cesm_tseries_generator.py error: tseries_tper invalid for data stream {0}.*.{1}".format(comp,file_extension)
                                raise TypeError(err_msg)
                        else:
                            err_msg = "cesm_tseries_generator.py error: tseries_tper undefined for data stream {0}.*.{1}".format(comp,file_extension)
                            raise TypeError(err_msg)

                        # load the tseries_time_variant_variables into a list
                        if comp_archive_spec.find("tseries_time_variant_variables") is not None:
                            variable_list = list()
                            for variable in comp_archive_spec.findall("tseries_time_variant_variables/variable"):
                                variable_list.append(variable.text)

                        # get a list of all the input files for this stream from the archive location
                        history_files = list()
                        in_file_path = '/'.join( [dout_s_root,rootdir,subdir] )                        
                        all_in_files = os.listdir(in_file_path)

                        # check that there are actually a list of history files to work with
                        for in_file in all_in_files:
                            if re.search(file_extension, in_file):
                                history_files.append(in_file_path+"/"+in_file)

                        # sort the list of input history files in order to get the output suffix 
                        # from the first and last file
                        if len(history_files) > 0:
                            history_files.sort()

                            start_file = history_files[0]
                            start_file_parts = list()
                            start_file_parts = start_file.split( "." )
                            start_file_time = start_file_parts[-2]

                            last_file = history_files[-1]
                            last_file_parts = list()
                            last_file_parts = last_file.split( "." )
                            last_file_time = last_file_parts[-2]

                            # get the actual component name from the history file 
                            # will also need to deal with the instance numbers based on the comp_name
                            comp_name = last_file_parts[-4]
                            stream = last_file_parts[-3]

                            # check for pop.h nday1 and nyear1 history streams
                            if last_file_parts[-3] in ["nday1","nyear1"]:
                                comp_name = last_file_parts[-5]
                                stream = last_file_parts[-4]+"."+last_file_parts[-3]

                            # create the tseries output prefix needs to end with a "."
                            tseries_output_prefix = tseries_output_dir+"/"+casename+"."+comp_name+"."+stream+"."

                            # format the time series variable output suffix based on the 
                            # tseries_tper setting suffix needs to start with a "."
                            if tseries_tper == "yearly":
                                tseries_output_suffix = "."+start_file_time+"-"+last_file_time+".nc"
                            elif tseries_tper == "monthly":
                                start_time_parts = start_file_time.split( "-" )
                                last_time_parts = last_file_time.split( "-" )
                                tseries_output_suffix = "."+start_time_parts[0]+start_time_parts[1]+"-"+last_time_parts[0]+last_time_parts[1]+".nc"
                            elif tseries_tper in ["weekly","daily","hourly6","hourly3","hourly1","min30"]:
                                start_time_parts = start_file_time.split( "-" )
                                last_time_parts = last_file_time.split( "-" )
                                tseries_output_suffix = "."+start_time_parts[0]+start_time_parts[1]+start_time_parts[2]+"-"+last_time_parts[0]+last_time_parts[1]+last_time_parts[2]+".nc"

                            # get a reshpaer specification object
                            spec = specification.create_specifier()

                            # populate the spec object with data for this history stream
                            spec.input_file_list = history_files
                            spec.netcdf_format = tseries_output_format
                            spec.output_file_prefix = tseries_output_prefix
                            spec.output_file_suffix = tseries_output_suffix
                            spec.time_variant_metadata = variable_list

                            # print the specifier
                            if debug:
                                dbg = list()
                                pp = pprint.PrettyPrinter(indent=5)
                                dbg = [comp_name, spec.input_file_list, spec.netcdf_format, spec.output_file_prefix, spec.output_file_suffix, spec.time_variant_metadata]
                                pp.pprint(dbg)
                            
                            # append this spec to the list of specifiers
                            specifiers.append(spec)

    return specifiers

#======
# main
#======

def main(options, scomm, rank, size):
    """
    """
    # initialize the CASEROOT environment dictionary
    cesmEnv = dict()

    # CASEROOT is given on the command line as required option --caseroot
    caseroot = options.caseroot[0]

    # set the debug level 
    debug = options.debug[0]

    # cesmEnv["id"] = "value" parsed from the CASEROOT/env_*.xml files
    env_file_list = ['env_case.xml', 'env_run.xml', 'env_build.xml', 'env_mach_pes.xml']

    # check if the standalone option is set
    if options.standalone:
        env_file_list = ['env_postprocess.xml']
    cesmEnv = cesmEnvLib.readXML(caseroot, env_file_list)

    # initialize the specifiers list to contain the list of specifier classes
    specifiers = list()

    # loading the specifiers from the env_timeseries.xml  only needs to run on the master task (rank=0) 
    if rank == 0:
        specifiers = readArchiveXML(caseroot, cesmEnv['DOUT_S_ROOT'], cesmEnv['CASE'], options.standalone, debug)
    scomm.sync()

    # specifiers is a list of pyreshaper specification objects ready to pass to the reshaper
    specifiers = scomm.partition(specifiers, func=partition.Duplicate(), involved=True)

    # create the PyReshaper object - uncomment when multiple specifiers is allowed
    reshpr = reshaper.create_reshaper(specifiers, serial=False, verbosity=debug)

    # Run the conversion (slice-to-series) process 
    reshpr.convert()

    # Print timing diagnostics
    reshpr.print_diagnostics()

# TO-DO check if DOUT_S_SAVE_HISTORY_FILES is true or false and 
# delete history files accordingly

    return 0

#===================================

if __name__ == "__main__":
    # initialize simplecomm object
    scomm = simplecomm.create_comm(serial=False)

    rank = scomm.get_rank()
    size = scomm.get_size()

    if rank == 0:
        print('...Running on {0} cores'.format(size))

    options = commandline_options()
    try:
        status = main(options, scomm, rank, size)
        if rank == 0:
            print('************************************************************')
            print('Successfully completed generating variable time-series files')
            print('************************************************************')
        sys.exit(status)

##    except RunTimeError as error:
        
    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)
