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
import chunking

# import the MPI related module
from asaptools import partition, simplecomm, vprinter

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

    parser.add_argument('--completechunk', nargs=1, type=int, required=False, 
                        help='1: do not create incomplete chunks, 0: create an incomplete chunk')

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
def readArchiveXML(caseroot, dout_s_root, casename, standalone, completechunk, debug):
    """ reads the $CASEROOT/env_timeseries.xml file and builds a fully defined list of 
         reshaper specifications to be passed to the pyReshaper tool.

    Arguments:
    caseroot (string) - case root path
    dout_s_root (string) - short term archive root path
    casename (string) - casename
    standalone (boolean) - logical to indicate if postprocessing case is stand-alone or not
    completechunk (boolean) - end on a ragid boundary if True.  Otherwise, do not create incomplete chunks if False
    """
    specifiers = list()
    xml_tree = ET.ElementTree()

    # get path to env_timeseries.xml file
    env_timeseries = '{0}/env_timeseries.xml'.format(caseroot)

    # read tseries log file to see if we've already started converting files, if so, where did we leave off
    log = chunking.read_log('ts_status.log')

    # check if the env_timeseries.xml file exists
    if ( not os.path.isfile(env_timeseries) ):
        err_msg = "cesm_tseries_generator.py ERROR: {0} does not exist.".format(env_timeseries)
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
                            if tseries_output_format not in ["netcdf","netcdf4","netcdf4c","netcdfLarge"]:
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

                        if file_spec.find("tseries_filecat_tper") is not None:
                            tper = file_spec.find("tseries_filecat_tper").text
                        if file_spec.find("tseries_filecat_n") is not None:
                            size = file_spec.find("tseries_filecat_n").text
                        comp_name = comp
                        stream = file_extension.split('.[')[0]

                        stream_dates,file_slices,cal,units = chunking.get_input_dates(in_file_path+'/*'+file_extension+'*.nc')
                        if comp+stream not in log.keys():
                            log[comp+stream] = {'slices':[],'index':0}
                        ts_log_dates = log[comp+stream]['slices']
                        index = log[comp+stream]['index']
                        files,dates,index = chunking.get_chunks(tper, index, size, stream_dates, ts_log_dates, cal, units, completechunk)
                        for d in dates:
                            log[comp+stream]['slices'].append(float(d))
                        log[comp+stream]['index']=index
                        for cn,cf in files.iteritems():

                            history_files = cf['fn']
                            start_time_parts = cf['start']
                            last_time_parts = cf['end']

                            # create the tseries output prefix needs to end with a "."
                            tseries_output_prefix = tseries_output_dir+"/"+casename+"."+comp_name+stream+"."

                            # format the time series variable output suffix based on the 
                            # tseries_tper setting suffix needs to start with a "."
                            if tseries_tper == "yearly":
                                tseries_output_suffix = "."+start_time_parts[0]+"-"+last_time_parts[0]+".nc"
                            elif tseries_tper == "monthly":
                                tseries_output_suffix = "."+start_time_parts[0]+start_time_parts[1]+start_time_parts[2]+"-"+last_time_parts[0]+last_time_parts[1]+last_time_parts[2]+".nc"
                            elif tseries_tper in ["weekly","daily","hourly6","hourly3","hourly1","min30"]:
                                tseries_output_suffix = "."+start_time_parts[0]+start_time_parts[1]+start_time_parts[2]+start_time_parts[3]+"-"+last_time_parts[0]+last_time_parts[1]+last_time_parts[2]+last_time_parts[3]+".nc"

                            # get a reshaper specification object
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
    return specifiers,log


def divide_comm(scomm, l_spec):
  
    '''
    Divide the communicator into subcommunicators, leaving rank one to hand out reshaper jobs to run.
    The part of the parallelization will be handled by this script, with the parallelization now over
    CESM output streams and chunks.  The reshaper will the compute the variables in parallel.

    Input:
    scomm (simplecomm) - communicator to be divided (currently MIP_COMM_WORLD)
    l_spec(int) - the number of reshaper specifiers(# of output stream and # of chunks)

    Output:
    inter_comm(simplecomm) - this rank's subcommunicator it belongs to
    num_of_groups(int) - the total number of subcommunicators
    '''
    min_procs_per_spec = 16
    size = scomm.get_size()
    rank = scomm.get_rank()-1

    # the global master needs to be in its own subcommunicator
    # ideally it would not be in any, but the divide function 
    # requires all ranks to participate in the call
    if rank == -1:
        group = ((size/min_procs_per_spec)%l_spec)+1
        if l_spec == 1:
            num_of_groups = 1
        else:
            num_of_groups = (size/min_procs_per_spec)
    else:
        temp_color = (rank // min_procs_per_spec) % l_spec
        if l_spec == 1:
            num_of_groups = 1
        else:
            num_of_groups = (size/min_procs_per_spec)
        if (temp_color == num_of_groups):
            temp_color = temp_color - 1
        groups = []
        for g in range(0,num_of_groups+1):
            groups.append(g)
        group = groups[temp_color]
    
    inter_comm,multi_comm = scomm.divide(group)

    return inter_comm,num_of_groups
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

    # get the XML variables loaded into a hash
    env_file_list = ['env_postprocess.xml']
    cesmEnv = cesmEnvLib.readXML(caseroot, env_file_list);

    # initialize the specifiers list to contain the list of specifier classes
    specifiers = list()

    # loading the specifiers from the env_timeseries.xml  only needs to run on the master task (rank=0) 
    if rank == 0:
        dout_s_root = cesmEnv['DOUT_S_ROOT'] 
        case = cesmEnv['CASE']
        specifiers,log = readArchiveXML(caseroot, dout_s_root, case, options.standalone, options.completechunk[0], debug)
    scomm.sync()

    # specifiers is a list of pyreshaper specification objects ready to pass to the reshaper
    specifiers = scomm.partition(specifiers, func=partition.Duplicate(), involved=True)

    if len(specifiers) > 0:
        # setup subcommunicators to do streams and chunks in parallel
        # everyone participates except for root
        inter_comm, lsubcomms = divide_comm(scomm, len(specifiers))
        color = inter_comm.get_color()
        lsize = inter_comm.get_size()
        lrank = inter_comm.get_rank()

        GWORK_TAG = 10 # global comm mpi tag
        LWORK_TAG = 20 # local comm mpi tag
        # global root - hands out specifiers to work on.  When complete, it must tell each subcomm all work is done.
        if (rank == 0):
            for i in range(0,len(specifiers)): # hand out all specifiers
                scomm.ration(data=i, tag=GWORK_TAG)
            for i in range(0,lsubcomms): # complete, signal this to all subcomms
                scomm.ration(data=-99, tag=GWORK_TAG)

        # subcomm root - performs the same tasks as other subcomm ranks, but also gets the specifier to work on and sends
        # this information to all ranks within subcomm
        elif (lrank == 0):
            i = -999
            while i != -99:
                i = scomm.ration(tag=GWORK_TAG) # recv from global
                for x in range(1,lsize):
                    inter_comm.ration(i, LWORK_TAG) # send to local ranks  
                if i != -99:
                    # create the PyReshaper object - uncomment when multiple specifiers is allowed
                    reshpr = reshaper.create_reshaper(specifiers[i], serial=False, verbosity=debug, simplecomm=inter_comm)
                    # Run the conversion (slice-to-series) process 
                    reshpr.convert()
                    # Print timing diagnostics
                    reshpr.print_diagnostics()

        # all subcomm ranks - recv the specifier to work on and call the reshaper
        else:
            i = -999
            while i != -99:
                i = inter_comm.ration(tag=LWORK_TAG) # recv from local root    
                if i != -99:
                    # create the PyReshaper object - uncomment when multiple specifiers is allowed
                    reshpr = reshaper.create_reshaper(specifiers[i], serial=False, verbosity=debug, simplecomm=inter_comm)
                    # Run the conversion (slice-to-series) process 
                    reshpr.convert()

    if rank == 0:
        chunking.write_log('ts_status.log', log) # Update system log with the dates that were just converted 

    scomm.sync()
#===================================

if __name__ == "__main__":
    # initialize simplecomm object
    scomm = simplecomm.create_comm(serial=False)

    # get commandline options
    options = commandline_options()

    rank = scomm.get_rank()
    size = scomm.get_size()

    if rank == 0:
        print('cesm_tseries_generator INFO Running on {0} cores'.format(size))

    main(options, scomm, rank, size)
    if rank == 0:
        print('************************************************************')
        print('Successfully completed generating variable time-series files')
        print('************************************************************')

