"""
Parallel Tests for the SimpleComm class

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from __future__ import print_function, unicode_literals

import unittest
import numpy as np

from asaptools import simplecomm
from asaptools.partition import EqualStride, Duplicate
from os import linesep as eol
from mpi4py import MPI
MPI_COMM_WORLD = MPI.COMM_WORLD  # @UndefinedVariable


def test_info_msg(rank, size, name, data, actual, expected):
    rknm = ''.join(['[', str(rank), '/', str(size), '] ', str(name)])
    spcr = ' ' * len(rknm)
    msg = ''.join([eol,
                   rknm, ' - Input: ', str(data), eol,
                   spcr, ' - Actual:   ', str(actual), eol,
                   spcr, ' - Expected: ', str(expected)])
    return msg


class SimpleCommParTests(unittest.TestCase):

    def setUp(self):
        self.gcomm = simplecomm.create_comm()
        self.size = MPI_COMM_WORLD.Get_size()
        self.rank = MPI_COMM_WORLD.Get_rank()

    def tearDown(self):
        pass
 
    def testGetSize(self):
        actual = self.gcomm.get_size()
        expected = self.size
        msg = test_info_msg(
            self.rank, self.size, 'get_size()', None, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
   
    def testIsManager(self):
        actual = self.gcomm.is_manager()
        expected = (self.rank == 0)
        msg = test_info_msg(
            self.rank, self.size, 'is_manager()', None, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
    
    def testSumInt(self):
        data = 5
        actual = self.gcomm.allreduce(data, 'sum')
        expected = self.size * 5
        msg = test_info_msg(
            self.rank, self.size, 'sum(int)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
    
    def testSumList(self):
        data = range(5)
        actual = self.gcomm.allreduce(data, 'sum')
        expected = self.size * sum(data)
        msg = test_info_msg(
            self.rank, self.size, 'sum(list)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
    
    def testSumArray(self):
        data = np.arange(5)
        actual = self.gcomm.allreduce(data, 'sum')
        expected = self.size * sum(data)
        msg = test_info_msg(
            self.rank, self.size, 'sum(array)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
    
    def testSumDict(self):
        data = {'a': range(3), 'b': [5, 7]}
        actual = self.gcomm.allreduce(data, 'sum')
        expected = {
            'a': self.size * sum(range(3)), 'b': self.size * sum([5, 7])}
        msg = test_info_msg(
            self.rank, self.size, 'sum(dict)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
   
    def testMaxInt(self):
        data = self.rank
        actual = self.gcomm.allreduce(data, 'max')
        expected = self.size - 1
        msg = test_info_msg(
            self.rank, self.size, 'max(int)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
   
    def testMaxList(self):
        data = range(2 + self.rank)
        actual = self.gcomm.allreduce(data, 'max')
        expected = self.size
        msg = test_info_msg(
            self.rank, self.size, 'max(list)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMaxArray(self):
        data = np.arange(2 + self.rank)
        actual = self.gcomm.allreduce(data, 'max')
        expected = self.size
        msg = test_info_msg(
            self.rank, self.size, 'max(array)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMaxDict(self):
        data = {'rank': self.rank, 'range': range(2 + self.rank)}
        actual = self.gcomm.allreduce(data, 'max')
        expected = {'rank': self.size - 1, 'range': self.size}
        msg = test_info_msg(
            self.rank, self.size, 'max(dict)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
   
    def testPartitionInt(self):
        if self.gcomm.is_manager():
            data = 10
        else:
            data = None
        actual = self.gcomm.partition(data, func=Duplicate())
        if self.gcomm.is_manager():
            expected = None
        else:
            expected = 10
        msg = test_info_msg(
            self.rank, self.size, 'partition(int)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
   
    def testPartitionIntInvolved(self):
        if self.gcomm.is_manager():
            data = 10
        else:
            data = None
        actual = self.gcomm.partition(data, func=Duplicate(), involved=True)
        expected = 10
        msg = test_info_msg(
            self.rank, self.size, 'partition(int, T)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
   
    def testPartitionList(self):
        if self.gcomm.is_manager():
            data = range(10)
        else:
            data = None
        actual = self.gcomm.partition(data)
        if self.gcomm.is_manager():
            expected = None
        else:
            expected = range(self.rank - 1, 10, self.size - 1)
        msg = test_info_msg(
            self.rank, self.size, 'partition(list)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
    
    def testPartitionListInvolved(self):
        if self.gcomm.is_manager():
            data = range(10)
        else:
            data = None
        actual = self.gcomm.partition(data, involved=True)
        expected = range(self.rank, 10, self.size)
        msg = test_info_msg(
            self.rank, self.size, 'partition(list, T)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testPartitionArray(self):
        if self.gcomm.is_manager():
            data = np.arange(10)
        else:
            data = None
        actual = self.gcomm.partition(data, func=EqualStride())
        if self.gcomm.is_manager():
            expected = None
        else:
            expected = np.arange(self.rank - 1, 10, self.size - 1)
        msg = test_info_msg(
            self.rank, self.size, 'partition(array)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            self.assertEqual(actual, expected, msg)
        else:
            np.testing.assert_array_equal(actual, expected, msg)
 
    def testPartitionStrArray(self):
        indata = list('abcdefghi')
        if self.gcomm.is_manager():
            data = data = np.array(indata)
        else:
            data = None
        actual = self.gcomm.partition(data, func=EqualStride())
        if self.gcomm.is_manager():
            expected = None
        else:
            expected = np.array(indata[self.rank - 1::self.size - 1])
        msg = test_info_msg(
            self.rank, self.size, 'partition(string-array)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            self.assertEqual(actual, expected, msg)
        else:
            np.testing.assert_array_equal(actual, expected, msg)
 
    def testPartitionCharArray(self):
        indata = list('abcdefghi')
        if self.gcomm.is_manager():
            data = data = np.array(indata, dtype='c')
        else:
            data = None
        actual = self.gcomm.partition(data, func=EqualStride())
        if self.gcomm.is_manager():
            expected = None
        else:
            expected = np.array(indata[self.rank - 1::self.size - 1], dtype='c')
        msg = test_info_msg(
            self.rank, self.size, 'partition(char-array)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            self.assertEqual(actual, expected, msg)
        else:
            np.testing.assert_array_equal(actual, expected, msg)
             
    def testPartitionArrayInvolved(self):
        if self.gcomm.is_manager():
            data = np.arange(10)
        else:
            data = None
        actual = self.gcomm.partition(data, func=EqualStride(), involved=True)
        expected = np.arange(self.rank, 10, self.size)
        msg = test_info_msg(
            self.rank, self.size, 'partition(array, T)', data, actual, expected)
        print(msg)
        np.testing.assert_array_equal(actual, expected, msg)
   
    def testCollectInt(self):
        if self.gcomm.is_manager():
            data = None
            actual = [self.gcomm.collect() for _ in range(1, self.size)]
            expected = [i for i in enumerate(range(1, self.size), 1)]
        else:
            data = self.rank
            actual = self.gcomm.collect(data)
            expected = None
        self.gcomm.sync()
        msg = test_info_msg(
            self.rank, self.size, 'collect(int)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            for a in actual:
                self.assertTrue(a in expected, msg)
        else:
            self.assertEqual(actual, expected, msg)
 
    def testCollectList(self):
        if self.gcomm.is_manager():
            data = None
            actual = [self.gcomm.collect() for _ in range(1, self.size)]
            expected = [(i, range(i)) for i in range(1, self.size)]
        else:
            data = range(self.rank)
            actual = self.gcomm.collect(data)
            expected = None
        self.gcomm.sync()
        msg = test_info_msg(
            self.rank, self.size, 'collect(list)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            for a in actual:
                self.assertTrue(a in expected, msg)
        else:
            self.assertEqual(actual, expected, msg)
  
    def testCollectArray(self):
        if self.gcomm.is_manager():
            data = None
            actual = [(i, list(x)) for (i, x) in [self.gcomm.collect()
                                                  for _ in range(1, self.size)]]
            expected = [(i, list(np.arange(self.size) + i))
                        for i in range(1, self.size)]
        else:
            data = np.arange(self.size) + self.rank
            actual = self.gcomm.collect(data)
            expected = None
        self.gcomm.sync()
        msg = test_info_msg(
            self.rank, self.size, 'collect(array)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            for a in actual:
                self.assertTrue(a in expected, msg)
        else:
            self.assertEqual(actual, expected, msg)
  
    def testCollectStrArray(self):
        if self.gcomm.is_manager():
            data = None
            actual = [(i, list(x)) for (i, x) in [self.gcomm.collect()
                                                  for _ in range(1, self.size)]]
            expected = [(i, list(map(str, list(np.arange(self.size) + i))))
                        for i in range(1, self.size)]
        else:
            data = np.array([str(i + self.rank) for i in range(self.size)])
            actual = self.gcomm.collect(data)
            expected = None
        self.gcomm.sync()
        msg = test_info_msg(
            self.rank, self.size, 'collect(string-array)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            for a in actual:
                self.assertTrue(a in expected, msg)
        else:
            self.assertEqual(actual, expected, msg)
  
    def testCollectCharArray(self):
        if self.gcomm.is_manager():
            data = None
            actual = [(i, list(x)) for (i, x) in [self.gcomm.collect()
                                                  for _ in range(1, self.size)]]
            expected = [(i, list(map(lambda c: str(c).encode(), list(np.arange(self.size) + i))))
                        for i in range(1, self.size)]
        else:
            data = np.array([str(i + self.rank) for i in range(self.size)],
                            dtype='c')
            actual = self.gcomm.collect(data)
            expected = None
        self.gcomm.sync()
        msg = test_info_msg(
            self.rank, self.size, 'collect(char-array)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            for a in actual:
                self.assertTrue(a in expected, msg)
        else:
            self.assertEqual(actual, expected, msg)
 
    def testRationInt(self):
        if self.gcomm.is_manager():
            data = range(1, self.size)
            actual = [self.gcomm.ration(d) for d in data]
            expected = [None] * (self.size - 1)
        else:
            data = None
            actual = self.gcomm.ration()
            expected = range(1, self.size)
        self.gcomm.sync()
        msg = test_info_msg(
            self.rank, self.size, 'ration(int)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            self.assertEqual(actual, expected, msg)
        else:
            self.assertTrue(actual in expected, msg)
  
    def testRationArray(self):
        if self.gcomm.is_manager():
            data = np.arange(3 * (self.size-1))
            actual = [
                self.gcomm.ration(data[3 * i:3 * (i + 1)]) for i in range(0, self.size-1)]
            expected = [None] * (self.size - 1)
        else:
            data = None
            actual = self.gcomm.ration()
            expected = np.arange(3 * (self.size-1))
        self.gcomm.sync()
        msg = test_info_msg(
            self.rank, self.size, 'ration(array)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            self.assertEqual(actual, expected, msg)
        else:
            contained = any([np.all(actual == expected[i:i + actual.size])
                             for i in range(expected.size - actual.size + 1)])
            self.assertTrue(contained, msg)
 
    def testRationStrArray(self):
        if self.gcomm.is_manager():
            data = np.array(list(map(str, range(3 * (self.size-1)))), dtype='c')
            actual = [self.gcomm.ration(data[3 * i:3 * (i + 1)])
                      for i in range(0, (self.size-1))]
            expected = [None] * (self.size - 1)
        else:
            data = None
            actual = self.gcomm.ration()
            expected = np.array(list(map(str, range(3 * (self.size-1)))), dtype='c')
        self.gcomm.sync()
        msg = test_info_msg(
            self.rank, self.size, 'ration(string-array)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            self.assertEqual(actual, expected, msg)
        else:
            contained = any([np.all(actual == expected[i:i + actual.size])
                             for i in range(expected.size - actual.size + 1)])
            self.assertTrue(contained, msg)
   
    def testRationCharArray(self):
        if self.gcomm.is_manager():
            data = np.array(list(map(str, range(3 * (self.size-1)))), dtype='c')
            actual = [
                self.gcomm.ration(data[3 * i:3 * (i + 1)]) 
                for i in range(0, (self.size-1))]
            expected = [None] * (self.size - 1)
        else:
            data = None
            actual = self.gcomm.ration()
            expected = np.array(list(map(str, range(3 * (self.size-1)))), dtype='c')
        self.gcomm.sync()
        msg = test_info_msg(
            self.rank, self.size, 'ration(char-array)', data, actual, expected)
        print(msg)
        if self.gcomm.is_manager():
            self.assertEqual(actual, expected, msg)
        else:
            contained = any([np.all(actual == expected[i:i + actual.size])
                             for i in range(expected.size - actual.size + 1)])
            self.assertTrue(contained, msg)

if __name__ == "__main__":
    hline = '=' * 70
    if MPI_COMM_WORLD.Get_rank() == 0:
        print(hline)
        print('STANDARD OUTPUT FROM ALL TESTS:')
        print(hline)
    MPI_COMM_WORLD.Barrier()

    try:
        from cStringIO import StringIO
    except ImportError:
        from io import StringIO
    
    mystream = StringIO()
    tests = unittest.TestLoader().loadTestsFromTestCase(SimpleCommParTests)
    unittest.TextTestRunner(stream=mystream).run(tests)
    MPI_COMM_WORLD.Barrier()

    results = MPI_COMM_WORLD.gather(mystream.getvalue())
    if MPI_COMM_WORLD.Get_rank() == 0:
        for rank, result in enumerate(results):
            print(hline)
            print('TESTS RESULTS FOR RANK ' + str(rank) + ':')
            print(str(result))
