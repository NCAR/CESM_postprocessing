"""
Parallel-1-Serial Tests for the SimpleComm class

The 'P1S' Test Suite specificially tests whether the serial behavior is the
same as the 1-rank parallel behavior.  If the 'Par' test suite passes with
various communicator sizes (1, 2, ...), then this suite should be run to make
sure that serial communication behaves consistently.

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from __future__ import print_function

import unittest
import numpy as np

from asaptools import simplecomm
from asaptools.partition import EqualStride, Duplicate
from os import linesep
from mpi4py import MPI
MPI_COMM_WORLD = MPI.COMM_WORLD  # @UndefinedVariable


def test_info_msg(name, data, sresult, presult):
    spcr = ' ' * len(name)
    msg = ''.join([linesep,
                   name, ' - Input: ', str(data), linesep,
                   spcr, ' - Serial Result:   ', str(sresult), linesep,
                   spcr, ' - Parallel Result: ', str(presult)])
    return msg


class SimpleCommP1STests(unittest.TestCase):

    def setUp(self):
        self.scomm = simplecomm.create_comm(serial=True)
        self.pcomm = simplecomm.create_comm(serial=False)
        self.size = MPI_COMM_WORLD.Get_size()
        self.rank = MPI_COMM_WORLD.Get_rank()

    def tearDown(self):
        pass

    def testIsSerialLike(self):
        self.assertEqual(
            self.rank, 0, 'Rank not consistent with serial-like operation')
        self.assertEqual(
            self.size, 1, 'Size not consistent with serial-like operation')

    def testGetSize(self):
        sresult = self.scomm.get_size()
        presult = self.pcomm.get_size()
        msg = test_info_msg('get_size()', None, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testIsManager(self):
        sresult = self.scomm.is_manager()
        presult = self.pcomm.is_manager()
        msg = test_info_msg('is_manager()', None, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testSumInt(self):
        data = 5
        sresult = self.scomm.allreduce(data, 'sum')
        presult = self.pcomm.allreduce(data, 'sum')
        msg = test_info_msg('sum(int)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testSumList(self):
        data = range(5)
        sresult = self.scomm.allreduce(data, 'sum')
        presult = self.pcomm.allreduce(data, 'sum')
        msg = test_info_msg('sum(list)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testSumDict(self):
        data = {'rank': self.rank, 'range': range(3 + self.rank)}
        sresult = self.scomm.allreduce(data, 'sum')
        presult = self.pcomm.allreduce(data, 'sum')
        msg = test_info_msg('sum(list)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testSumArray(self):
        data = np.arange(5)
        sresult = self.scomm.allreduce(data, 'sum')
        presult = self.pcomm.allreduce(data, 'sum')
        msg = test_info_msg('sum(array)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testMaxInt(self):
        data = 13 + self.rank
        sresult = self.scomm.allreduce(data, 'max')
        presult = self.pcomm.allreduce(data, 'max')
        msg = test_info_msg('max(int)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testMaxList(self):
        data = range(5 + self.rank)
        sresult = self.scomm.allreduce(data, 'max')
        presult = self.pcomm.allreduce(data, 'max')
        msg = test_info_msg('max(list)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testMaxDict(self):
        data = {'rank': self.rank, 'range': range(3 + self.rank)}
        sresult = self.scomm.allreduce(data, 'max')
        presult = self.pcomm.allreduce(data, 'max')
        msg = test_info_msg('max(dict)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testMaxArray(self):
        data = np.arange(5 + self.rank)
        sresult = self.scomm.allreduce(data, 'max')
        presult = self.pcomm.allreduce(data, 'max')
        msg = test_info_msg('max(array)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testPartitionInt(self):
        data = 13 + self.rank
        sresult = self.scomm.partition(data, func=Duplicate())
        presult = self.pcomm.partition(data, func=Duplicate())
        msg = test_info_msg('partition(int)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testPartitionIntInvolved(self):
        data = 13 + self.rank
        sresult = self.scomm.partition(data, func=Duplicate(), involved=True)
        presult = self.pcomm.partition(data, func=Duplicate(), involved=True)
        msg = test_info_msg('partition(int, T)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testPartitionList(self):
        data = range(5 + self.rank)
        sresult = self.scomm.partition(data, func=EqualStride())
        presult = self.pcomm.partition(data, func=EqualStride())
        msg = test_info_msg('partition(list)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testPartitionListInvolved(self):
        data = range(5 + self.rank)
        sresult = self.scomm.partition(data, func=EqualStride(), involved=True)
        presult = self.pcomm.partition(data, func=EqualStride(), involved=True)
        msg = test_info_msg('partition(list, T)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testPartitionArray(self):
        data = np.arange(2 + self.rank)
        sresult = self.scomm.partition(data)
        presult = self.pcomm.partition(data)
        msg = test_info_msg('partition(array)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testPartitionArrayInvolved(self):
        data = np.arange(2 + self.rank)
        sresult = self.scomm.partition(data, involved=True)
        presult = self.pcomm.partition(data, involved=True)
        msg = test_info_msg('partition(array, T)', data, sresult, presult)
        print(msg)
        np.testing.assert_array_equal(sresult, presult, msg)

    def testPartitionStrArray(self):
        data = np.array([c for c in 'abcdefghijklmnopqrstuvwxyz'])
        sresult = self.scomm.partition(data)
        presult = self.pcomm.partition(data)
        msg = test_info_msg('partition(string-array)', data, sresult, presult)
        print(msg)
        self.assertEqual(sresult, presult, msg)

    def testPartitionStrArrayInvolved(self):
        data = np.array([c for c in 'abcdefghijklmnopqrstuvwxyz'])
        sresult = self.scomm.partition(data, involved=True)
        presult = self.pcomm.partition(data, involved=True)
        msg = test_info_msg('partition(string-array, T)', data, sresult, presult)
        print(msg)
        np.testing.assert_array_equal(sresult, presult, msg)
        
    def testRationError(self):
        data = 10
        self.assertRaises(RuntimeError, self.scomm.ration, data)
        self.assertRaises(RuntimeError, self.pcomm.ration, data)

    def testCollectError(self):
        data = 10
        self.assertRaises(RuntimeError, self.scomm.collect, data)
        self.assertRaises(RuntimeError, self.pcomm.collect, data)


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
    tests = unittest.TestLoader().loadTestsFromTestCase(SimpleCommP1STests)
    unittest.TextTestRunner(stream=mystream).run(tests)
    MPI_COMM_WORLD.Barrier()

    results = MPI_COMM_WORLD.gather(mystream.getvalue())
    if MPI_COMM_WORLD.Get_rank() == 0:
        for rank, result in enumerate(results):
            print(hline)
            print('TESTS RESULTS FOR RANK ' + str(rank) + ':')
            print(hline)
            print(str(result))
