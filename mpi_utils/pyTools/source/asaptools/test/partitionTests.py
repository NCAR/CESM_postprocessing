"""
These are the unit tests for the partition module functions

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from __future__ import print_function

import unittest
from asaptools import partition
from os import linesep


def test_info_msg(name, data, index, size, actual, expected):
    spcr = ' ' * len(name)
    msg = ''.join([linesep,
                   name, ' - Data: ', str(data), linesep,
                   spcr, ' - Index/Size: ', str(
                       index), '/', str(size), linesep,
                   spcr, ' - Actual:   ', str(actual), linesep,
                   spcr, ' - Expected: ', str(expected)])
    return msg


class partitionTests(unittest.TestCase):

    """
    Unit tests for the partition module
    """

    def setUp(self):
        data = [list(range(3)), list(range(5)), list(range(7))]
        indices_sizes = [(0, 1), (1, 3), (5, 9)]
        self.inputs = []
        for d in data:
            for (i, s) in indices_sizes:
                self.inputs.append((d, i, s))

    def tearDown(self):
        pass

    def testOutOfBounds(self):
        self.assertRaises(
            IndexError, partition.EqualLength(), [1, 2, 3], 3, 3)
        self.assertRaises(
            IndexError, partition.EqualLength(), [1, 2, 3], 7, 3)

    def testDuplicate(self):
        for inp in self.inputs:
            pfunc = partition.Duplicate()
            actual = pfunc(*inp)
            expected = inp[0]
            msg = test_info_msg(
                'Duplicate', inp[0], inp[1], inp[2], actual, expected)
            print(msg)
            self.assertEqual(actual, expected, msg)

    def testEquallength(self):
        results = [list(range(3)), [1], [],
                   list(range(5)), [2, 3], [],
                   list(range(7)), [3, 4], [5]]
        for (ii, inp) in enumerate(self.inputs):
            pfunc = partition.EqualLength()
            actual = pfunc(*inp)
            expected = results[ii]
            msg = test_info_msg(
                'EqualLength', inp[0], inp[1], inp[2], actual, expected)
            print(msg)
            self.assertEqual(actual, expected, msg)

    def testEqualStride(self):
        for inp in self.inputs:
            pfunc = partition.EqualStride()
            actual = pfunc(*inp)
            expected = list(inp[0][inp[1]::inp[2]])
            msg = test_info_msg(
                'EqualStride', inp[0], inp[1], inp[2], actual, expected)
            print(msg)
            self.assertEqual(actual, expected, msg)

    def testSortedStride(self):
        for inp in self.inputs:
            weights = [(20 - i) for i in inp[0]]
            pfunc = partition.SortedStride()
            actual = pfunc(list(zip(inp[0], weights)), inp[1], inp[2])
            expected = list(inp[0][:])
            expected.reverse()
            expected = expected[inp[1]::inp[2]]
            msg = test_info_msg(
                'SortedStride', zip(inp[0], weights), inp[1], inp[2], actual, expected)
            print(msg)
            self.assertEqual(actual, expected, msg)

    def testWeightBalanced(self):
        results = [set([0, 1, 2]), set([1]), set(),
                   set([3, 2, 4, 1, 0]), set([1]), set(),
                   set([3, 2, 4, 1, 5, 0, 6]), set([3, 6]), set([4])]
        for (ii, inp) in enumerate(self.inputs):
            weights = [(3 - i) ** 2 for i in inp[0]]
            pfunc = partition.WeightBalanced()
            actual = set(pfunc(list(zip(inp[0], weights)), inp[1], inp[2]))
            expected = results[ii]
            msg = test_info_msg(
                'WeightBalanced', zip(inp[0], weights), inp[1], inp[2], actual, expected)
            print(msg)
            self.assertEqual(actual, expected, msg)


if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testBasicInt']
    unittest.main()
