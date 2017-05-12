#!/usr/bin/env python
#==============================================================================
#
#  runtests.py
#
#  Command-line script to run the Yellowstone test suite (i.e., the "bakeoff").
#  This script can run any number of ways.
#
#==============================================================================

# Builtin Modules
import os
import sys
import stat
import shutil
import optparse
import cPickle as pickle

# Package Modules
from utilities import testtools as tt
from utilities import runtools as rt

#==============================================================================
# Command-Line Interface Definition
#==============================================================================
_USAGE_ = 'Usage:  %prog [options] [TEST1 [TEST2 [...]]]'

_DESC_ = """This program is designed to run yellowstone-specific
tests of the PyReshaper.  Each named test (or all tests if
the -a or --all option is used) will be given a run
directory in the "rundirs" directory with the same
name as the test itself.  The run script will be placed
in this run directory, as will be placed the run output
error file.  All output data files will be placed in the
output subdirectory.
"""

_PARSER_ = optparse.OptionParser(usage=_USAGE_, description=_DESC_)
_PARSER_.add_option('-a', '--all', default=False,
                    action='store_true', dest='all_tests',
                    help=('True or False, indicating whether to run all '
                          'tests [Default: False]'))
_PARSER_.add_option('-c', '--code', default='STDD0002', type=str,
                    help=('The name of the project code for charging in '
                         'parallel runs (ignored if running in serial) '
                         '[Default: STDD0002]'))
_PARSER_.add_option('-i', '--infofile', default='testinfo.json', type=str,
                    help=('Location of the testinfo.json database file '
                          '[Default: testinfo.json]'))
_PARSER_.add_option('-f', '--format', default='netcdf4c',
                    type=str, dest='ncformat',
                    help=('The NetCDF file format to use for the output '
                          'data produced by the test.  [Default: netcdf4c]'))
_PARSER_.add_option('-l', '--list', default=False,
                    action='store_true', dest='list_tests',
                    help=('True or False, indicating whether to list all '
                          'tests, instead of running tests. [Default: False]'))
_PARSER_.add_option('-m', '--wmode', default='o', dest='wmode',
                    help=("Output file write mode: 'o' to overwrite, 'w' for "
                          "normal operation, 'a' to append to existing file, 's' "
                          "to skip existing files [Default: 'o']"))
_PARSER_.add_option('-n', '--nodes', default=0, type=int,
                    help=('The integer number of nodes to request in parallel'
                          ' runs (0 means run in serial) [Default: 0]'))
_PARSER_.add_option('-q', '--queue', default='economy', type=str,
                    help=('The name of the queue to request in parallel runs '
                          '(ignored if running in serial) '
                          '[Default: economy]'))
_PARSER_.add_option('-t', '--tiling', default=16, type=int,
                    help=('The integer number of processes per node to '
                          'request in parallel runs (ignored if running '
                          'in serial) [Default: 16]'))
_PARSER_.add_option('-w', '--wtime', default=240, type=int,
                    help=('The number of minutes to request for the wall '
                          'clock in parallel runs (ignored if running in '
                          'serial) [Default: 240]'))


#==============================================================================
# Write an executable Python script to run the Reshaper
#==============================================================================
def write_pyscript(testnames, scriptname='runscript.py', verbosity=3,
                   serial=False, wmode='o', chunks=None):
    """
    Write an executable Python script to run the PyReshaper with a set of specs

    Parameters:
        testnames (str, list): Name of a single test, or list of tests
        scriptname (str): Name of the Python script to write
        verbosity (int): Level of output verbosity
        serial (bool): Whether to run in serial (True) or not (False)
        wmode (str): The mode to use when writing time-series files ('o'
            to overwrite, 'a' to append to existing files, 'w' to write
            new files, 's' to skip existing files)
        chunks (dict): The dimensional chunking sizes to Read/Write operations
    """

    # Start defining the Python script
    pyscript_list = ['#!/usr/bin/env python',
                     '#',
                     '# Created automatically by runtests.py',
                     '#',
                     '',
                     'import cPickle as pickle',
                     'from pyreshaper import specification',
                     'from pyreshaper import reshaper',
                     '']

    # Check for single or multiple specifiers
    if isinstance(testnames, (str, unicode)):
        pyscript_list.append(
            'specs = pickle.load(open("{0!s}.s2s", "rb"))'.format(testnames))
    elif isinstance(testnames, (list, tuple)):
        pyscript_list.append('specs = {}')
        for testname in testnames:
            pyscript_list.append(
                'specs["{0!s}"] = pickle.load(open("{0!s}.s2s", "rb"))'.format(testname))

    # Read the chunking information
    pyscript_list.extend(['',
                          'chunks = {0!s}'.format(chunks),
                          ''])
    
    # Define the rest of the python script
    pyscript_list.extend([
        ('rshpr = reshaper.create_reshaper(specs, serial={0!s}, '
         'verbosity={1!s}, wmode={2!r})').format(serial, verbosity, wmode),
        'rshpr.convert(chunks=chunks)',
        'rshpr.print_diagnostics()',
        ''])

    # Write the script to file
    pyscript_file = open(scriptname, 'w')
    pyscript_file.write(os.linesep.join(pyscript_list))
    pyscript_file.close()

    # Make the script executable
    os.chmod(scriptname, stat.S_IRWXU | stat.S_IRGRP | stat.S_IROTH)


#==============================================================================
# Run tests individually
#==============================================================================
def runtests(tests, testdb, nodes=0, tiling=16, minutes=120, queue='economy',
             project='STDD0002', wmode='o', ncformat='netcdf4c'):
    """
    Run a set of tests

    Parameters:
        tests (list, tuple): List or tuple of test names to run
        testdb (TestDB): The testing database
        nodes (int): Number of nodes to run the test(s) with
        tiling (int): Number of processes per node to run the test(s) with
        minutes (int): Number of minutes to run the test(s) for
        queue (str): Name of the queue to submit the job(s) to
        project (str): Name of the project to charge the job time to
        wmode (str): The mode to use when writing time-series files ('o'
            to overwrite, 'a' to append to existing files, 'w' to write
            new files, 's' to skip existing files)
        ncformat (str): NetCDF format for the output
    """

    cwd = os.getcwd()
    for test_name in test_list:

        print 'Running test: {0!s}'.format(test_name)

        # Set the test directory
        if nodes > 0:
            runtype = 'par{0!s}x{1!s}'.format(nodes, tiling)
        else:
            runtype = 'ser'
        testdir = os.path.abspath(
            os.path.join('results', str(test_name), runtype, ncformat))

        # If the test directory doesn't exist, make it and move into it
        if os.path.exists(testdir):
            if wmode == 'w':
                shutil.rmtree(testdir)
            elif wmode == 's':
                print "   Already exists.  Skipping."
                continue
        if not os.path.exists(testdir):
            os.makedirs(testdir)
        os.chdir(testdir)

        # Set the output directory
        outputdir = os.path.join(testdir, 'output')

        # If the output directory doesn't exists, create it
        if not os.path.exists(outputdir):
            os.mkdir(outputdir)

        # Create the specifier and write to file (specfile)
        testspec = testdb.create_specifier(test_name=str(test_name),
                                           ncfmt=ncformat,
                                           outdir=outputdir)
        testspecfile = '{0!s}.s2s'.format(test_name)
        pickle.dump(testspec, open(testspecfile, 'wb'))

        # Get chunk sizes
        chunks = testdb.getdb()[test_name].get('chunks', None)
        
        # Write the Python executable to be run
        pyscript_name = '{0!s}.py'.format(test_name)
        write_pyscript(testnames=test_name, scriptname=pyscript_name,
                       serial=(nodes <= 0), wmode=wmode, chunks=chunks)

        # Generate the command and arguments
        if nodes > 0:
            runcmd = 'poe ./{0!s}'.format(pyscript_name)
        else:
            runcmd = './{0!s}'.format(pyscript_name)

        # Create and start the job
        job = rt.Job(runcmds=[runcmd], nodes=nodes,
                     name=str(test_name), tiling=tiling,
                     minutes=minutes, queue=queue,
                     project=project)
        job.start()

        os.chdir(cwd)


#==============================================================================
# Main Command-line Operation
#==============================================================================
if __name__ == '__main__':
    opts, args = _PARSER_.parse_args()

    # Check for tests to analyze
    if len(args) == 0 and not opts.all_tests and not opts.list_tests:
        _PARSER_.print_help()
        sys.exit(1)

    # Create/read the testing info and stats files
    testdb = tt.TestDB(name=opts.infofile)

    # List tests if only listing
    if opts.list_tests:
        testdb.display()
        sys.exit(1)

    # Generate the list of tests to run/analyze
    if opts.all_tests:
        test_list = testdb.getdb().keys()
    else:
        test_list = [t for t in args if t in testdb.getdb()]

    runtests(test_list, testdb, nodes=opts.nodes, tiling=opts.tiling,
             minutes=opts.wtime, queue=opts.queue, project=opts.code,
             wmode=opts.wmode, ncformat=opts.ncformat)
