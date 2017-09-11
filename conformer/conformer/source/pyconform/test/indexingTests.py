"""
Indexing Unit Tests

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from pyconform.indexing import index_str, index_tuple, join, align_index
from testutils import print_test_message

import unittest
import numpy


#===================================================================================================
# IndexStrTests
#===================================================================================================
class IndexStrTests(unittest.TestCase):
    """
    Unit tests for the indexing.index_str function
    """

    def test_index_str_int(self):
        indata = 3
        testname = 'index_str({!r})'.format(indata)
        actual = index_str(indata)
        expected = str(indata)
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_index_str_slice(self):
        indata = slice(1, 2, 3)
        testname = 'index_str({!r})'.format(indata)
        actual = index_str(indata)
        expected = '1:2:3'
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_index_str_tuple(self):
        indata = (4, slice(3, 1, -4))
        testname = 'index_str({!r})'.format(indata)
        actual = index_str(indata)
        expected = '4, 3:1:-4'
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_index_str_dict(self):
        indata = {'x': 4, 'y': slice(3, 1, -4)}
        testname = 'index_str({!r})'.format(indata)
        actual = index_str(indata)
        expected = "'x': 4, 'y': 3:1:-4"
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))


#===================================================================================================
# IndexTupleTests
#===================================================================================================
class IndexTupleTests(unittest.TestCase):
    """
    Unit tests for the indexing.index_tuple function
    """

    def test_int(self):
        indata = (4, 3)
        testname = 'index_tuple({}, {})'.format(*indata)
        actual = index_tuple(*indata)
        expected = (indata[0], slice(None), slice(None))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_slice(self):
        indata = (slice(1, 6, 3), 3)
        testname = 'index_tuple({}, {})'.format(*indata)
        actual = index_tuple(*indata)
        expected = (indata[0], slice(None), slice(None))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_tuple(self):
        indata = ((4, slice(1, 6, 3)), 3)
        testname = 'index_tuple({}, {})'.format(*indata)
        actual = index_tuple(*indata)
        expected = indata[0] + (slice(None),)
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_tuple_too_large(self):
        indata = ((4, slice(1, 6, 3), 6, 7), 3)
        testname = 'index_tuple({}, {})'.format(*indata)
        expected = IndexError
        print_test_message(testname, indata=indata, expected=expected)
        self.assertRaises(expected, index_tuple, *indata)


#===================================================================================================
# AlignIndexTests
#===================================================================================================
class AlignIndexTests(unittest.TestCase):
    """
    Unit tests for the indexing.align_index function
    """

    def test_int(self):
        indata = (4, ('a', 'b', 'c'))
        testname = 'align_index({}, {})'.format(*indata)
        actual = align_index(*indata)
        expected = (indata[0], slice(None), slice(None))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_slice(self):
        indata = (slice(1, 5, 2), ('a', 'b', 'c'))
        testname = 'align_index({}, {})'.format(*indata)
        actual = align_index(*indata)
        expected = (indata[0], slice(None), slice(None))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_tuple(self):
        indata = ((4, slice(1, 5, 2)), ('a', 'b', 'c'))
        testname = 'align_index({}, {})'.format(*indata)
        actual = align_index(*indata)
        expected = indata[0] + (slice(None),)
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_tuple_too_long(self):
        indata = ((4, slice(1, 5, 2), 5, 9), ('a', 'b', 'c'))
        testname = 'align_index({}, {})'.format(*indata)
        expected = IndexError
        print_test_message(testname, indata=indata, expected=expected)
        self.assertRaises(expected, align_index, *indata)

    def test_dict(self):
        indata = ({'a': slice(1, 5, 2), 'b': 6}, ('a', 'b', 'c'))
        testname = 'align_index({}, {})'.format(*indata)
        actual = align_index(*indata)
        expected = (indata[0]['a'], indata[0]['b'], slice(None))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))


#===================================================================================================
# JoinTests
#===================================================================================================
class JoinTests(unittest.TestCase):
    """
    Unit tests for the indexing.join function
    """

    def setUp(self):
        indices = [None, -100, -10, -1, 0, 1, 10, 100]
        steps = [None, -100, -2, -1, 1, 2, 100]
        self.slices = [slice(i, j, k) for i in indices for j in indices for k in steps]

    def test_join_20_slice_slice(self):
        indata = 20
        A = numpy.arange(indata)
        nfailures = 0
        ntests = len(self.slices) ** 2
        for s1 in self.slices:
            for s2 in self.slices:
                good = numpy.array_equal(A[s1][s2], A[join((indata,), s1, s2)])
                if not good:
                    print 'Failure: join(({},), {}, {})'.format(indata, s1, s2)
                    nfailures += 1
        testname = 'join(({},), slice, slice)'.format(indata)
        print_test_message(testname, num_failures=nfailures, num_success=ntests - nfailures)
        self.assertEqual(nfailures, 0, '{} failures'.format(nfailures))

#===============================================================================
# Command-Line Operation
#===============================================================================
if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
