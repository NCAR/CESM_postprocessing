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
import argparse
import cPickle as pickle

# Package Modules
from utilities import testtools as tt
from utilities import runtools as rt

#==============================================================================
# Command-Line Interface Definition
#==============================================================================
_DESC_ = """This program is designed to run yellowstone-specific
            tests of the PyReshaper.  Each named test (or all tests if
            the -a or --all option is used) will be given a run
            directory in the "rundirs" directory with the same
            name as the test itself.  The run script will be placed
            in this run directory, as will be placed the run output
            error file.  All output data files will be placed in the
            output subdirectory."""

_PARSER_ = argparse.ArgumentParser(description=_DESC_)
_PARSER_.add_argument('-a', '--all', default=False,
                      action='store_true', dest='all_tests',
                      help='True or False, indicating whether to run all '
                           'tests [Default: False]')
_PARSER_.add_argument('-c', '--code', default='STDD0002', type=str,
                      help='The name of the project code for charging in '
                           'parallel runs (ignored if running in serial) '
                           '[Default: STDD0002]')
_PARSER_.add_argument('-i', '--infofile', default='testinfo.json', type=str,
                      help='Location of the testinfo.json database file '
                           '[Default: testinfo.json]')
_PARSER_.add_argument('-f', '--format', default='netcdf4c',
                      type=str, dest='ncformat',
                      help='The NetCDF file format to use for the output '
                           'data produced by the test.  [Default: netcdf4c]')
_PARSER_.add_argument('-l', '--list', default=False,
                      action='store_true', dest='list_tests',
                      help='True or False, indicating whether to list all '
                           'tests, instead of running tests. [Default: False]')
_PARSER_.add_argument('-m', '--multiple', default=False,
                      action='store_true', dest='multispec',
                      help='True or False, indications whether the tests '
                           'should be run from a single Reshaper submission '
                           '(i.e., multiple Specifiers in one run) '
                           '[Default: False]')
_PARSER_.add_argument('-n', '--nodes', default=0, type=int,
                      help='The integer number of nodes to request in parallel'
                           ' runs (0 means run in serial) [Default: 0]')
_PARSER_.add_argument('-o', '--overwrite', default=False,
                      action='store_true', dest='overwrite',
                      help='True or False, indicating whether to force '
                           'deleting any existing test or run directories, '
                           'if found [Default: False]')
_PARSER_.add_argument('-q', '--queue', default='economy', type=str,
                      help='The name of the queue to request in parallel runs '
                           '(ignored if running in serial) '
                           '[Default: economy]')
_PARSER_.add_argument('-s', '--skip_existing', default=False,
                      action='store_true',
                      help='Whether to skip time-series generation for '
                           'variables with existing output files. '
                           '[Default: False]')
_PARSER_.add_argument('-t', '--tiling', default=16, type=int,
                      help='The integer number of processes per node to '
                           'request in parallel runs (ignored if running '
                           'in serial) [Default: 16]')
_PARSER_.add_argument('-w', '--wtime', default=240, type=int,
                      help='The number of minutes to request for the wall '
                           'clock in parallel runs (ignored if running in '
                           'serial) [Default: 240]')
_PARSER_.add_argument('test', type=str, nargs='*',
                      help='Name of test to run')


#==============================================================================
# Write an executable Python script to run the Reshaper
#==============================================================================
def write_pyscript(testnames, scriptname='runscript.py', verbosity=3,
                   serial=False, skip_existing=False, overwrite=False):
    """
    Write an executable Python script to run the PyReshaper with a set of specs

    Parameters:
        testnames (str, list): Name of a single test, or list of tests
        scriptname (str): Name of the Python script to write
        verbosity (int): Level of output verbosity
        serial (bool): Whether to run in serial (True) or not (False)
        skip_existing (bool): Whether to skip the generation of existing
            time-series files (True) or not (False)
        overwrite (bool): Whether to overwrite existing time-series files
             (True) or not (False)
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
            'specs = pickle.load(open("{0!s}.spec", "rb"))'.format(testnames))
    elif isinstance(testnames, (list, tuple)):
        pyscript_list.append('specs = {}')
        for testname in testnames:
            pyscript_list.append(
                'specs["{0!s}"] = pickle.load(open("{0!s}.spec", "rb"))'.format(testname))

    # Define the rest of the python script
    pyscript_list.extend([
        'rshpr = reshaper.create_reshaper(specs, serial={0!s}, '
        'verbosity={1!s}, skip_existing={2!s}, overwrite={3!s})'.format(
            serial, verbosity, skip_existing, overwrite),
        'rshpr.convert()',
        'rshpr.print_diagnostics()',
        ''])

    # Write the script to file
    pyscript_file = open(scriptname, 'w')
    pyscript_file.write(os.linesep.join(pyscript_list))
    pyscript_file.close()

    # Make the script executable
    os.chmod(scriptname, stat.S_IRWXU | stat.S_IRGRP | stat.S_IROTH)


#==============================================================================
# Run a single multitest (using a MultiSpecReshaper)
#==============================================================================
def runmultitest(tests, nodes=0, tiling=16, minutes=120,
                 queue='economy', project='STDD0002',
                 skip_existing=False, overwrite=False, ncformat='netcdf4c'):
    """
    Run a set of tests

    Parameters:
        tests (list, tuple): List or tuple of test names to run
        nodes (int): Number of nodes to run the test(s) with
        tiling (int): Number of processes per node to run the test(s) with
        minutes (int): Number of minutes to run the test(s) for
        queue (str): Name of the queue to submit the job(s) to
        project (str): Name of the project to charge the job time to
        skip_existing (bool): Whether to skip the generation of existing
            time-series files (True) or not (False)
        overwrite (bool): Whether to overwrite existing time-series files
             (True) or not (False)
        ncformat (str): NetCDF format for the output
    """

    print 'Running tests in single submission:'
    for test_name in tests:
        print '   {0!s}'.format(test_name)
    print

    # Set the test directory
    if nodes > 0:
        runtype = 'par{0!s}x{1!s}'.format(nodes, tiling)
    else:
        runtype = 'ser'
    testdir = os.path.abspath(
        os.path.join('results', 'multitest', runtype, ncformat))

    # If the test directory doesn't exist, make it and move into it
    cwd = os.getcwd()
    if os.path.exists(testdir):
        if overwrite:
            shutil.rmtree(testdir)
        else:
            print "Already exists.  Skipping."
            return
    if not os.path.exists(testdir):
        os.makedirs(testdir)
    os.chdir(testdir)

    # Create a separate output directory and specifier for each test
    for test_name in tests:

        # Set the output directory
        outputdir = os.path.join(testdir, 'output', str(test_name))

        # If the output directory doesn't exists, create it
        if not os.path.exists(outputdir):
            os.makedirs(outputdir)

        # Create the specifier and write to file (specfile)
        testspec = testdb.create_specifier(test_name=str(test_name),
                                           ncfmt=ncformat,
                                           outdir=outputdir)
        testspecfile = str(test_name) + '.spec'
        pickle.dump(testspec, open(testspecfile, 'wb'))

    # Write the Python executable to be run
    pyscript_name = 'multitest.py'
    write_pyscript(testnames=tests, scriptname=pyscript_name,
                   serial=(nodes <= 0), skip_existing=skip_existing,
                   overwrite=overwrite)

    # Generate the command and arguments
    if nodes > 0:
        runcmd = 'poe ./{0!s}'.format(pyscript_name)
    else:
        runcmd = './{0!s}'.format(pyscript_name)

    # Create and start the job
    job = rt.Job(runcmds=[runcmd], nodes=nodes,
                 name='multitest', tiling=tiling,
                 minutes=minutes, queue=queue,
                 project=project)
    job.start()

    os.chdir(cwd)


#==============================================================================
# Run tests individually
#==============================================================================
def runindivtests(tests, nodes=0, tiling=16, minutes=120,
                  queue='economy', project='STDD0002',
                  skip_existing=False, overwrite=False, ncformat='netcdf4c'):
    """
    Run a set of tests

    Parameters:
        tests (list, tuple): List or tuple of test names to run
        nodes (int): Number of nodes to run the test(s) with
        tiling (int): Number of processes per node to run the test(s) with
        minutes (int): Number of minutes to run the test(s) for
        queue (str): Name of the queue to submit the job(s) to
        project (str): Name of the project to charge the job time to
        skip_existing (bool): Whether to skip the generation of existing
            time-series files (True) or not (False)
        overwrite (bool): Whether to overwrite existing time-series files
             (True) or not (False)
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
            if overwrite:
                shutil.rmtree(testdir)
            else:
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
        testspecfile = '{0!s}.spec'.format(test_name)
        pickle.dump(testspec, open(testspecfile, 'wb'))

        # Write the Python executable to be run
        pyscript_name = '{0!s}.py'.format(test_name)
        write_pyscript(testnames=test_name, scriptname=pyscript_name,
                       serial=(nodes <= 0), skip_existing=skip_existing,
                       overwrite=overwrite)

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
    args = _PARSER_.parse_args()

    # Check for tests to analyze
    if len(args.test) == 0 and not args.all_tests and not args.list_tests:
        _PARSER_.print_help()
        sys.exit(1)

    # Create/read the testing info and stats files
    testdb = tt.TestDB(name=args.infofile)

    # List tests if only listing
    if args.list_tests:
        testdb.display()
        sys.exit(1)

    # Generate the list of tests to run/analyze
    if args.all_tests:
        test_list = testdb.getdb().keys()
    else:
        test_list = [t for t in args.test if t in testdb.getdb()]

    if args.multispec:
        runmultitest(test_list, nodes=args.nodes, tiling=args.tiling,
                     minutes=args.wtime, queue=args.queue, project=args.code,
                     skip_existing=args.skip_existing, overwrite=args.overwrite,
                     ncformat=args.ncformat)
    else:
        runindivtests(test_list, nodes=args.nodes, tiling=args.tiling,
                      minutes=args.wtime, queue=args.queue, project=args.code,
                      skip_existing=args.skip_existing, overwrite=args.overwrite,
                      ncformat=args.ncformat)
