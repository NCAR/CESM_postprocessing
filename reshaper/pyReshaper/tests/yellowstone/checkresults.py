#!/usr/bin/env python
#======================================================================
#
#  This script is designed to run cprnc netCDF file comparisons for
#  a given set of PyReshaper tests.
#
#======================================================================

import os
import re
import sys
import glob
import argparse
from subprocess import Popen, PIPE, STDOUT, call

# ASAP Toolbox Modules
from asaptools.simplecomm import create_comm

# Package Modules
from utilities import testtools as tt

#==============================================================================
# Command-Line Interface Definition
#==============================================================================
_DESC_ = 'Check the results of tests found in the rundirs directory.'
_PARSER_ = argparse.ArgumentParser(description=_DESC_)
_PARSER_.add_argument('-c', '--code', default='STDD0002', type=str,
                      help='The name of the project code for charging in '
                           'parallel runs (ignored if running in serial) '
                           '[Default: STDD0002]')
_PARSER_.add_argument('-i', '--infofile', default='testinfo.json',
                      help='Location of the testinfo.json file '
                           '[Default: testinfo.json]')
_PARSER_.add_argument('-l', '--list', default=False,
                      action='store_true', dest='list_tests',
                      help='True or False, indicating whether to list all '
                           'tests that have been run with resulting output, '
                           'instead of actually comparing any tests. '
                           '[Default: False]')
_PARSER_.add_argument('-m', '--multiple', default=False,
                      action='store_true', dest='multispec',
                      help='True or False, indicating whether to look for '
                           'multispec results [Default: False]')
_PARSER_.add_argument('-s', '--serial', default=False,
                      action='store_true', dest='serial',
                      help='True or False, indicating whether to run checks '
                           'serial or not [Default: False]')
_PARSER_.add_argument('-x', '--executable', type=str,
                      default='/glade/p/work/kpaul/installs/intel/12.1.5/cprnc/bin/cprnc',
                      help='The path to the CPRNC executable.')
_PARSER_.add_argument('rundir', type=str, nargs='*',
                      help='Name of a test run directory to check')


#==============================================================================
# CPRNC Class - Compares two NetCDF files
#==============================================================================
class CPRNC(object):
    """
    Compares two NetCDF files against one another
    """

    def __init__(self, executable='cprnc'):
        """
        Initializer

        Parameters:
            executable (str): Path to the cprnc executable.  If not defined,
                it will be assumed that the cprnc executable is in the user's
                path.
        """

        # Check that the executable works
        if call("type " + executable, shell=True, stdout=PIPE, stderr=PIPE) != 0:
            err_msg = "CPRNC executable '{0!s}' does not appear to work".format(
                executable)
            raise ValueError(err_msg)

        # Save the executable location
        self._executable = executable

    def compare(self, nc1, nc2, outfile=None, alltimes=True, verbose=False):
        """
        Compare two NetCDF files

        Parameters:
            nc1 (str): NetCDF file name/path
            nc2 (str): NetCDF file name/path
            outfile (str): Name of output file to log CPRNC output
            alltimes (bool): Whether to compare all times, or not
            verbose (bool): Whether to produce verbose output

        Returns:
            bool: True if the two files are the same, False otherwise
        """

        # Check valid NetCDF files
        if not os.path.isfile(nc1):
            err_msg = "File '{0!s}' does not appear to exist".format(nc1)
            raise ValueError(err_msg)
        if not os.path.isfile(nc2):
            err_msg = "File '{0!s}' does not appear to exist".format(nc2)
            raise ValueError(err_msg)

        # If the output file is set, check that the
        # directory to contain the output file exists
        if outfile:
            outdir = os.path.split(outfile)[0]
            if not os.path.isdir(outdir):
                err_msg = "Directory '{0!s}' ".format(outdir)
                err_msg += "to contain CPRNC output file doesn't exist"
                raise ValueError(err_msg)

        # Arguments for running cprnc
        cprnc_args = [self._executable]
        if alltimes:
            cprnc_args.append('-m')
        if verbose:
            cprnc_args.append('-v')
        cprnc_args.extend([nc1, nc2])

        # Start the CPRNC process
        cprnc_proc = Popen(cprnc_args, stdout=PIPE, stderr=STDOUT)

        # Wait for the process to finish and capture the output
        cprnc_out = cprnc_proc.communicate()[0]

        # Write the output file
        if outfile:
            cprnc_out_file = open(outfile, 'w')
            cprnc_out_file.write(cprnc_out)
            cprnc_out_file.close()

        # Return whether the comparison is identical
        return cprnc_out.rfind("the two files seem to be IDENTICAL") >= 0


#==============================================================================
# Command-Line Operation
#==============================================================================
if __name__ == '__main__':
    args = _PARSER_.parse_args()

    # Create/read the testing info and stats files
    testdb = tt.TestDB(name=args.infofile).getdb()

    # Get a list of valid rundir names to look for
    if len(args.rundir) > 0:
        rundirs = args.rundir
    else:
        rundirs = glob.glob(os.path.join('results', '*', '[ser,par]*', '*'))

    # Get the list of valid run names and the output directory pattern
    if args.multispec:
        valid_runnames = ['multitest']
        outdir_pattern = os.path.join('output', '*')
    else:
        valid_runnames = testdb.keys()
        outdir_pattern = 'output'

    # Find valid tests for comparison
    tests_to_check = {}
    for rdir in rundirs:
        if not os.path.isdir(rdir):
            continue
        rundir = os.path.realpath(rdir)
        tempdir, ncfmt = os.path.split(rundir)
        tempdir, runtype = os.path.split(tempdir)
        tempdir, runname = os.path.split(tempdir)

        # Look for the newest log file
        logfiles = glob.glob(
            os.path.join(rundir, '{0!s}*.log'.format(runname)))
        if len(logfiles) == 0:
            continue
        lastlog = max(logfiles, key=os.path.getctime)
        successful = False
        for logline in open(lastlog, 'r'):
            if re.search(r'Successfully completed.', logline):
                successful = True
                continue
        if not successful:
            continue

        # Check if the runname is a valid name
        if runname in valid_runnames:

            # Look for the new output directories
            for newdir in glob.iglob(os.path.join(rundir, outdir_pattern)):

                # Get the test name (allowing for multitest results)
                # and generate the cprnc output directory
                if runname in testdb:
                    test_name = runname
                    cprncdir = os.path.join(rundir, 'compare')
                else:
                    tempdir, test_name = os.path.split(newdir)
                    cprncdir = os.path.join(rundir, 'compare', test_name)

                # Get the output directory to compare against
                olddir = str(testdb[test_name]['results_dir'])

                # Put together comparison info
                tests_to_check[test_name] = {}
                tests_to_check[test_name]['run'] = rundir
                tests_to_check[test_name]['new'] = newdir
                tests_to_check[test_name]['old'] = olddir
                tests_to_check[test_name]['cpr'] = cprncdir

    # Expand the test directories into individual file-test dictionaries
    items_to_check = []
    unchecked_new_items = []
    unchecked_old_items = []
    for test_name, test_info in tests_to_check.items():
        newdir = test_info['new']
        olddir = test_info['old']
        newfiles = set(glob.glob(os.path.join(newdir, '*.nc')))
        oldfiles = set(glob.glob(os.path.join(olddir, '*.nc')))
        for newfile in newfiles:
            item_dict = {'test': test_name}
            item_dict['new'] = newfile
            filename = os.path.split(newfile)[1]
            oldfile = os.path.join(olddir, filename)
            if oldfile in oldfiles:
                item_dict['old'] = oldfile
                oldfiles.remove(oldfile)
                items_to_check.append(item_dict)
            else:
                item_dict['old'] = None
                unchecked_new_items.append(item_dict)
        for oldfile in oldfiles:
            item_dict = {'test': test_name}
            item_dict['new'] = None
            item_dict['old'] = oldfile
            unchecked_old_items.append(item_dict)

    # Get a basic MPI comm
    comm = create_comm(serial=(args.serial or args.list_tests))

    # Print tests that will be checked
    if comm.is_manager():
        if args.multispec:
            print 'Checking multitest results.'
        else:
            print 'Checking individual test results.'
        print

        for test_name in tests_to_check:
            print 'Test {0!s}:'.format(test_name)
            num_chk = sum(1 for i in items_to_check if i['test'] == test_name)
            num_new = num_chk + sum(1 for i in unchecked_new_items
                                    if i['test'] == test_name)
            num_old = num_chk + sum(1 for i in unchecked_old_items
                                    if i['test'] == test_name)
            print '   Checking {0!s} of {1!s}'.format(num_chk, num_new),
            print 'new files generated against {0!s}'.format(num_old),
            print 'old files found.'

    # Quit now, if just listing tests to be checked
    if args.list_tests:
        sys.exit(1)

    # For each test to be compared, generate the cprnc output directories
    if comm.is_manager():
        print
        print "Results:"
        for test_name, test_info in tests_to_check.items():
            if not os.path.isdir(test_info['cpr']):
                os.makedirs(test_info['cpr'])

    # Wait for processes to sync
    comm.sync()

    # Create the CPRNC object
    cprnc = CPRNC(args.executable)

    # For each file on this partition, do the CPRNC Comparison
    local_results = []
    local_items_to_check = comm.partition(items_to_check, involved=True)
    for item_dict in local_items_to_check:

        # Name the cprnc output file
        cprncdir = tests_to_check[item_dict['test']]['cpr']
        filename = os.path.split(item_dict['new'])[1]
        outfile = os.path.join(cprncdir, filename + '.cprnc')

        # Compare the files with CPRNC
        rslt = cprnc.compare(
            item_dict['new'], item_dict['old'], outfile=outfile)

        # Save the result in the result dictionary
        rslt_dict = {}
        rslt_dict['test'] = item_dict['test']
        rslt_dict['file'] = filename
        rslt_dict['result'] = rslt
        local_results.append(rslt_dict)

        # Print results to screen
        str_rslt = '  GOOD:' if rslt else '   BAD:'
        print str_rslt, filename, '({0!s})'.format(rslt_dict['test'])

    # Wait for processes to sync
    comm.sync()

    # Send results from workers
    if not comm.is_manager():
        comm.collect(local_results)

    # Collect results
    if comm.is_manager():
        results = local_results
        for i in range(comm.get_size() - 1):
            results.extend(comm.collect()[1])

        for test_name, test_info in tests_to_check.items():
            summfile = os.path.join(test_info['run'], test_name + '.cprnc')
            sfile = open(summfile, 'w')
            for result in results:
                if result['test'] == test_name:
                    str_rslt = '  GOOD:' if result['result'] else '   BAD:'
                    summ = str_rslt + ' ' + \
                        result['file'] + ' ({0!s})'.format(rslt_dict['test'])
                    sfile.write(summ + os.linesep)
            sfile.close()

    # Wait for processes to sync
    comm.sync()

    # Finished
    if comm.is_manager():
        print
        print "Done."
