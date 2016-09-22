#!/usr/bin/env python
#==============================================================================
#
#  getstats.py
#
#  Analyse test input and gather statistics.
#
#==============================================================================

# Builtin Modules
import sys
import argparse

# Package Modules
from utilities import testtools as tt

#==============================================================================
# Command-Line Interface Definition
#==============================================================================
_DESC_ = """This program is designed to gather statistics for tests and
            test input defined in the testing database file."""

_PARSER_ = argparse.ArgumentParser(description=_DESC_)
_PARSER_.add_argument('-a', '--all', default=False,
                      action='store_true', dest='all_tests',
                      help='True or False, indicating whether to run all '
                           'tests [Default: False]')
_PARSER_.add_argument('-i', '--infofile', default='testinfo.json', type=str,
                      help='Location of the testinfo.json database file '
                           '[Default: testinfo.json]')
_PARSER_.add_argument('-l', '--list', default=False,
                      action='store_true', dest='list_tests',
                      help='True or False, indicating whether to list all '
                           'tests, instead of running tests. [Default: False]')
_PARSER_.add_argument('-o', '--overwrite', default=False,
                      action='store_true', dest='overwrite',
                      help='True or False, indicating whether to force '
                           'deleting any existing test or run directories, '
                           'if found [Default: False]')
_PARSER_.add_argument('-s', '--statsfile', default='teststats.json', type=str,
                      help='Location of the teststats.json database file '
                           '[Default: teststats.json]')
_PARSER_.add_argument('test', type=str, nargs='*',
                      help='Name of test to analyze')

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
    statdb = tt.StatDB(name=args.statsfile)

    # List tests if only listing
    if args.list_tests:
        testdb.display()
        sys.exit(1)

    # Generate the list of tests to run/analyze
    if args.all_tests:
        test_list = testdb.getdb().keys()
    else:
        test_list = [t for t in args.test if t in testdb.getdb()]

    # Analyze test input, if requested (overwrite forces re-analysis)
    statdb.analyze(testdb, tests=test_list, force=args.overwrite)

    # Save to the stats file
    statdb.save(name=args.statsfile)
