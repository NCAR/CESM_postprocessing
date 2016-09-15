#!/usr/bin/env python
#======================================================================
#
#  This script is designed to extract timing data from the scripttest
#  output.  It writes it to a JSON file, adding to the JSON file if the
#  particular log has not been recorded.  Overwrites if the log is already
#  present
#
#======================================================================

import os
import glob
import datetime
import argparse

# Package Modules
from utilities import testtools as tt

#==============================================================================
# Command-Line Interface Definition
#==============================================================================
_DESC_ = """This program is designed to gather statistics for tests and
            test input defined in the testing database file."""

_PARSER_ = argparse.ArgumentParser(description=_DESC_)
_PARSER_.add_argument('-i', '--infofile', default='testinfo.json', type=str,
                      help='Location of the testinfo.json database file '
                           '[Default: testinfo.json]')
_PARSER_.add_argument('-t', '--timefile', default='timings.json', type=str,
                      help='Location of the timings.json database file '
                           '[Default: timings.json]')


#==============================================================================
# find_shortest_str - Helper Function
#==============================================================================
def find_shortest_str(strng, left, right=os.linesep, loc=0):
    sloc = strng.find(left, loc)
    if (sloc < 0):
        return '-1', 0
    sloc += len(left)
    eloc = strng.find(right, sloc)
    return strng[sloc:eloc].strip(), eloc


#==============================================================================
# Command-line Operation
#==============================================================================
if __name__ == '__main__':
    args = _PARSER_.parse_args()

    # Create/read the testing info and stats files
    testdb = tt.TestDB(name=args.infofile).getdb()
    timedb = tt.TimeDB(name=args.timefile)

    # Current working directory
    cwd = os.getcwd()

    # Extract each possible test
    for rundir in glob.iglob(os.path.join('results', '*', '[ser,par]*', '*')):
        print
        print 'Extracting times from test dir:', rundir
        print
        root, ncfmt = os.path.split(rundir)
        root, run_type = os.path.split(root)
        root, test_name = os.path.split(root)
        print '  Test Name:', test_name
        print '  Run Type:', run_type
        print '  NetCDF Format:', ncfmt

        # Skip if not an individual test
        if test_name not in testdb:
            print '  Test name not found in database. Skipping.'
            continue

        # Prepare the timing database information
        common_name = testdb[test_name]['common_name']
        print '  Common Name:', common_name
        method_name = 'pyreshaper4c'
        if ncfmt == 'netcdf':
            method_name = 'pyreshaper'
        elif ncfmt == 'netcdf4':
            method_name = 'pyreshaper4'

        # Get the number of cores and nodes from the run type
        num_cores = 1
        num_nodes = 0
        if run_type[0:3] == 'par':
            num_nodes, nppn = map(int, run_type[3:].split('x'))
            num_cores = num_nodes * nppn

        # Look for log files
        glob_path = os.path.join(rundir, '{0!s}*.log'.format(test_name))
        glob_names = glob.glob(glob_path)

        # Continue if nothing to do here
        if (len(glob_names) == 0):
            print '  No log files found. Skipping.'
            continue

        # For each log file, extract the necessary info
        for log_name in glob_names:

            # Get the JOBID from the log filename
            lognm = os.path.split(log_name)[1]
            print '  Processing log:', lognm

            # Open the log file and read the contents
            log_file = open(log_name)
            log_str = log_file.read()
            log_file.close()

            # Start the search through the file at character 0, and do it in
            # order so that you only need to search through it once...
            loc = 0

            # Look for the successful completion message
            success_str, success_loc = find_shortest_str(
                log_str, 'Successfully completed.', loc=0)
            if success_loc <= 0:
                print '    Unsuccessful or incomplete job.  Skipping.'
                continue

            # Look for the use of a metadata "once" file...
            once_file_str, once_loc = find_shortest_str(
                log_str, 'Closed "once" ', loc=0)
            used_once_file = False
            if once_loc > 0:
                used_once_file = True

            # Find the internal timing data from the run output:
            tot_timing_str, loc = find_shortest_str(
                log_str, 'Complete Conversion Process: ', loc=loc)
            openo_str, loc = find_shortest_str(
                log_str, 'Open Output Files: ', loc=loc)
            closeo_str, loc = find_shortest_str(
                log_str, 'Close Output Files: ', loc=loc)
            openi_str, loc = find_shortest_str(
                log_str, 'Open Input Files: ', loc=loc)
            closei_str, loc = find_shortest_str(
                log_str, 'Close Input Files: ', loc=loc)
            rmetaTI_str, loc = find_shortest_str(
                log_str, 'Read Time-Invariant Metadata: ', loc=loc)
            rmetaTV_str, loc = find_shortest_str(
                log_str, 'Read Time-Variant Metadata: ', loc=loc)
            rTS_str, loc = find_shortest_str(
                log_str, 'Read Time-Series Variables: ', loc=loc)
            wmetaTI_str, loc = find_shortest_str(
                log_str, 'Write Time-Invariant Metadata: ', loc=loc)
            wmetaTV_str, loc = find_shortest_str(
                log_str, 'Write Time-Variant Metadata: ', loc=loc)
            wTS_str, loc = find_shortest_str(
                log_str, 'Write Time-Series Variables: ', loc=loc)

            # Get read/write size amounts
            actual_str, nloc = find_shortest_str(
                log_str, 'Actual Data: ', loc=loc)
            requested_str, nloc = find_shortest_str(
                log_str, 'Requested Data: ', loc=loc)

            # Compute the job number from the log file timestamp
            timestamp = os.path.getmtime(log_name)
            dt = datetime.datetime.fromtimestamp(timestamp)
            job_num = dt.strftime('%y%m%d-%H%M%S')

            # Compute the elapsed time
            elapsed = float(tot_timing_str)

            # Display the internal timing info for comparison
            print '    Elapsed time (INTERNAL):', elapsed, 'sec'

            # Write the JSON data
            print '    Adding job result to timings database.'
            timedb.add_result(common_name, method_name, job_num,
                              tser_read=float(rTS_str),
                              tim_read=float(rmetaTI_str),
                              tvm_read=float(rmetaTV_str),
                              tser_write=float(wTS_str),
                              tim_write=float(wmetaTI_str),
                              tvm_write=float(wmetaTV_str),
                              metadata=True, once=used_once_file,
                              cores=num_cores, nodes=num_nodes,
                              input_open=float(openi_str),
                              output_open=float(openo_str),
                              total=elapsed,
                              actual_mb=float(actual_str),
                              requested_mb=float(requested_str),
                              system='yellowstone')

    # Write the JSON data file
    timedb.save(args.timefile)
