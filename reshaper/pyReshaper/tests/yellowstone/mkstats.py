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
import optparse

# Package Modules
from utilities import testtools as tt

#==============================================================================
# Command-Line Interface Definition
#==============================================================================
_USAGE_ = 'Usage:  %prog [options] [TEST1 [TEST2 [...]]]'

_DESC_ = """This program is designed to gather statistics for tests and
test input defined in the testing database file.
"""

_PARSER_ = optparse.OptionParser(description=_DESC_)
_PARSER_.add_option('-a', '--all', default=False,
                    action='store_true', dest='all_tests',
                    help=('True or False, indicating whether to run all '
                          'tests [Default: False]'))
_PARSER_.add_option('-i', '--infofile', default='testinfo.json', type='string',
                    help=('Location of the testinfo.json database file '
                          '[Default: testinfo.json]'))
_PARSER_.add_option('-l', '--list', default=False,
                    action='store_true', dest='list_tests',
                    help=('True or False, indicating whether to list all '
                          'tests, instead of running tests. [Default: False]'))
_PARSER_.add_option('-o', '--overwrite', default=False,
                    action='store_true', dest='overwrite',
                    help=('True or False, indicating whether to force '
                          'deleting any existing test or run directories, '
                          'if found [Default: False]'))
_PARSER_.add_option('-s', '--statsfile', default='teststats.json', type='string',
                    help=('Location of the teststats.json database file '
                          '[Default: teststats.json]'))

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
    statdb = tt.StatDB(name=opts.statsfile)

    # List tests if only listing
    if opts.list_tests:
        testdb.display()
        sys.exit(1)

    # Generate the list of tests to run/analyze
    if opts.all_tests:
        test_list = testdb.getdb().keys()
    else:
        test_list = [t for t in args if t in testdb.getdb()]

    # Analyze test input, if requested (overwrite forces re-analysis)
    statdb.analyze(testdb, tests=test_list, force=opts.overwrite)

    # Save to the stats file
    statdb.save(name=opts.statsfile)
