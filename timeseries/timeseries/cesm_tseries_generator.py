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
import re
import string
import sys
import traceback
import warnings
import xml.etree.ElementTree as ET

from cesm_utils import cesmEnvLib
import chunking

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# load the pyReshaper modules
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

    return options.caseroot[0], options.debug[0], options.standalone, options.backtrace

#==============================================================================================
# readArchiveXML - read the $CASEROOT/env_timeseries.xml file and build the pyReshaper classes
#==============================================================================================
def readArchiveXML(caseroot, input_rootdir, output_rootdir, casename, standalone, completechunk,
                   generate_all, debug, debugMsg, comm, rank, size):
    """ reads the $CASEROOT/env_timeseries.xml file and builds a fully defined list of
         reshaper specifications to be passed to the pyReshaper tool.

    Arguments:
    caseroot (string) - case root path
    input_rootdir (string) - rootdir to input raw history files
    output_rootdir (string) - rootdir to output single variable time series files
    casename (string) - casename
    standalone (boolean) - logical to indicate if postprocessing case is stand-alone or not
    completechunk (boolean) - end on a ragid boundary if True.  Otherwise, do not create incomplete chunks if False
    generate_all (boolean) - generate timeseries for all streams if True.  Otherwise, use the tseries_create setting.
    """
    specifiers = list()
    xml_tree = ET.ElementTree()

    # get path to env_timeseries.xml file
    env_timeseries = '{0}/env_timeseries.xml'.format(caseroot)

    # read tseries log file to see if we've already started converting files, if so, where did we leave off
    log = chunking.read_log('{0}/logs/ts_status.log'.format(caseroot))

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
            default_calendar = comp_archive_spec.find("default_calendar").text
            if rank == 0:
                debugMsg("default_calendar = {0}".format(default_calendar), header=True, verbosity=1)

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
                    if tseries_create.upper() in ["T","TRUE"] or generate_all.upper() in ["T","TRUE"]:

                        # check if tseries_format is an element for this file_spec and if it is valid
                        if file_spec.find("tseries_output_format") is not None:
                            tseries_output_format = file_spec.find("tseries_output_format").text
                            if tseries_output_format not in ["netcdf","netcdf4","netcdf4c","netcdfLarge"]:
                                err_msg = "cesm_tseries_generator.py error: tseries_output_format invalid for data stream {0}.*.{1}".format(comp,file_extension)
                                raise TypeError(err_msg)
                        else:
                            err_msg = "cesm_tseries_generator.py error: tseries_output_format undefined for data stream {0}.*.{1}".format(comp,file_extension)
                            raise TypeError(err_msg)

                        # load the tseries_time_variant_variables into a list
                        variable_list = list()
                        if comp_archive_spec.find("tseries_time_variant_variables") is not None:
                            for variable in comp_archive_spec.findall("tseries_time_variant_variables/variable"):
                                variable_list.append(variable.text)

                        # load the tseries_exclude_variables into a list
                        exclude_list = list()
                        if comp_archive_spec.find("tseries_exclude_variables") is not None:
                            for variable in comp_archive_spec.findall("tseries_exclude_variables/variable"):
                                exclude_list.append(variable.text)

                        # get a list of all the input files for this stream from the archive location
                        history_files = list()
                        in_file_path = '/'.join( [input_rootdir,rootdir,subdir] )

                        # get XML tseries elements for chunking
                        if file_spec.find("tseries_tper") is not None:
                            tseries_tper = file_spec.find("tseries_tper").text
                        if file_spec.find("tseries_filecat_tper") is not None:
                            tper = file_spec.find("tseries_filecat_tper").text
                        if file_spec.find("tseries_filecat_n") is not None:
                            size_n = file_spec.find("tseries_filecat_n").text
                        comp_name = comp
                        stream = file_extension.split('.[')[0]

                        stream_dates,file_slices,cal,units,time_period_freq = chunking.get_input_dates(in_file_path+'/*'+file_extension+'*.nc', comm, rank, size)
                        # check if the calendar attribute was read or not
                        if cal is None or cal == "none":
                            cal = default_calendar
                        if rank == 0:
                            debugMsg("calendar = {0}".format(cal), header=True, verbosity=1)

                        # the tseries_tper should be set in using the time_period_freq global file attribute if it exists
                        if time_period_freq is not None:
                            tseries_tper = time_period_freq
                        tseries_output_dir = '/'.join( [output_rootdir, rootdir, 'proc/tseries', tseries_tper] )
                        if rank == 0:
                            debugMsg("tseries_output_dir = {0}".format(tseries_output_dir), header=True, verbosity=1)

                        if comp+stream not in log.keys():
                            log[comp+stream] = {'slices':[],'index':0}
                        ts_log_dates = log[comp+stream]['slices']
                        index = log[comp+stream]['index']
                        files,dates,index = chunking.get_chunks(tper, index, size_n, stream_dates, ts_log_dates, cal, units, completechunk, tseries_tper)
                        for d in dates:
                            log[comp+stream]['slices'].append(float(d))
                        log[comp+stream]['index']=index
                        for cn,cf in files.iteritems():

                            if rank == 0:
                                if not os.path.exists(tseries_output_dir):
                                    os.makedirs(tseries_output_dir)
                            comm.sync()

                            history_files = cf['fn']
                            start_time_parts = cf['start']
                            last_time_parts = cf['end']

                            # create the tseries output prefix needs to end with a "."
                            tseries_output_prefix = "{0}/{1}.{2}{3}.".format(tseries_output_dir,casename,comp_name,stream)
                            if rank == 0:
                                debugMsg("tseries_output_prefix = {0}".format(tseries_output_prefix), header=True, verbosity=1)

                            # format the time series variable output suffix based on the
                            # tseries_tper setting suffix needs to start with a "."
                            freq_array = ["week","day","hour","min"]
                            if "year" in tseries_tper:
                                tseries_output_suffix = "."+start_time_parts[0]+"-"+last_time_parts[0]+".nc"
                            elif "month" in tseries_tper:
                                tseries_output_suffix = "."+start_time_parts[0]+start_time_parts[1]+"-"+last_time_parts[0]+last_time_parts[1]+".nc"
                            elif "day" in tseries_tper:
                                tseries_output_suffix = "."+start_time_parts[0]+start_time_parts[1]+start_time_parts[2]+"-"+last_time_parts[0]+last_time_parts[1]+last_time_parts[2]+".nc"
                            elif any(freq_string in tseries_tper for freq_string in freq_array):
                                tseries_output_suffix = "."+start_time_parts[0]+start_time_parts[1]+start_time_parts[2]+start_time_parts[3]+"-"+last_time_parts[0]+last_time_parts[1]+last_time_parts[2]+last_time_parts[3]+".nc"
                            else:
                                err_msg = "cesm_tseries_generator.py error: invalid tseries_tper = {0}.".format(tseries_tper)
                                raise TypeError(err_msg)
                            if rank == 0:
                                debugMsg("tseries_output_suffix = {0}".format(tseries_output_suffix), header=True, verbosity=1)

                            # get a reshaper specification object/
                            spec = specification.create_specifier()

                            # populate the spec object with data for this history stream
                            spec.input_file_list = history_files
                            spec.netcdf_format = tseries_output_format
                            spec.output_file_prefix = tseries_output_prefix
                            spec.output_file_suffix = tseries_output_suffix
                            spec.time_variant_metadata = variable_list
                            spec.exclude_list = exclude_list
                            # setting the default backend; netCDF4 or pynio
                            spec.backend = 'netCDF4'

                            if rank == 0:
                                debugMsg("specifier: comp_name = {0}".format(comp_name), header=True, verbosity=1)
                                debugMsg("    input_file_list = {0}".format(spec.input_file_list), header=True, verbosity=1)
                                debugMsg("    netcdf_format = {0}".format(spec.netcdf_format), header=True, verbosity=1)
                                debugMsg("    output_file_prefix = {0}".format(spec.output_file_prefix), header=True, verbosity=1)
                                debugMsg("    output_file_suffix = {0}".format(spec.output_file_suffix), header=True, verbosity=1)
                                debugMsg("    time_variant_metadata = {0}".format(spec.time_variant_metadata), header=True, verbosity=1)
                                debugMsg("    exclude_list = {0}".format(spec.exclude_list), header=True, verbosity=1)

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
    min_procs_per_spec = 36
    size = scomm.get_size()
    rank = scomm.get_rank()

    if l_spec == 1:
        num_of_groups = 1
    else:
        num_of_groups = size/min_procs_per_spec
    if l_spec < num_of_groups:
        num_of_groups = l_spec

    # the global master needs to be in its own subcommunicator
    # ideally it would not be in any, but the divide function
    # requires all ranks to participate in the call
    if rank == 0:
        temp_color = 0
    else:
        temp_color = (rank % num_of_groups)+1
    groups = []
    for g in range(0,num_of_groups+1):
        groups.append(g)
    group = groups[temp_color]

    inter_comm,multi_comm = scomm.divide(group)

    return inter_comm,num_of_groups

#======
# main
#======

def main(caseroot, standalone, scomm, rank, size, debug, debugMsg):
    """
    """
    # initialize the CASEROOT environment dictionary
    cesmEnv = dict()

    # get the XML variables loaded into a hash
    env_file_list = ['env_postprocess.xml']
    cesmEnv = cesmEnvLib.readXML(caseroot, env_file_list);

    # initialize the specifiers list to contain the list of specifier classes
    specifiers = list()

    tseries_input_rootdir = cesmEnv['TIMESERIES_INPUT_ROOTDIR']
    tseries_output_rootdir = cesmEnv['TIMESERIES_OUTPUT_ROOTDIR']
    case = cesmEnv['CASE']
    completechunk = cesmEnv['TIMESERIES_COMPLETECHUNK']
    generate_all = cesmEnv['TIMESERIES_GENERATE_ALL']
    if completechunk.upper() in ['T','TRUE']:
        completechunk = 1
    else:
        completechunk = 0
    specifiers,log = readArchiveXML(caseroot, tseries_input_rootdir, tseries_output_rootdir,
                                    case, standalone, completechunk, generate_all,
                                    debug, debugMsg, scomm, rank, size)
    scomm.sync()

    # specifiers is a list of pyreshaper specification objects ready to pass to the reshaper
    if rank == 0:
        debugMsg("# of Specifiers: "+str(len(specifiers)), header=True, verbosity=1)

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
                inter_comm.sync()

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
                inter_comm.sync()

    if rank == 0:
        # Update system log with the dates that were just converted
        debugMsg('before chunking.write_log', header=True, verbosity=1)
        chunking.write_log('{0}/logs/ts_status.log'.format(caseroot), log)
        debugMsg('after chunking.write_log', header=True, verbosity=1)

    scomm.sync()

    return 0

#===================================

if __name__ == "__main__":
    # initialize simplecomm object
    scomm = simplecomm.create_comm(serial=False)
    sys.argv.extend([] if "ARGS_FOR_SCRIPT" not in os.environ else os.environ["ARGS_FOR_SCRIPT"].split())
    # setup an overall timer
    timer = timekeeper.TimeKeeper()
    timer.start("Total Time")

    # get commandline options
    caseroot, debug, standalone, backtrace = commandline_options()

    # initialize global vprinter object for printing debug messages
    debugMsg = vprinter.VPrinter(header='', verbosity=0)
    if debug:
        header = 'cesm_tseries_generator: DEBUG... '
        debugMsg = vprinter.VPrinter(header=header, verbosity=debug)

    rank = scomm.get_rank()
    size = scomm.get_size()

    if rank == 0:
        debugMsg('Running on {0} cores'.format(size), header=True)

    try:
        status = main(caseroot, standalone, scomm, rank, size, debug, debugMsg)
        scomm.sync()
        timer.stop("Total Time")
        if rank == 0:
            print('************************************************************')
            print('Successfully completed generating variable time-series files')
            print('Total Time: {0} seconds'.format(timer.get_time("Total Time")))
            print('************************************************************')
        sys.exit(0)
    except Exception as error:
        print(str(error))
        if backtrace:
            traceback.print_exc()
        sys.exit(1)
