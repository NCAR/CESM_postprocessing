"""
Parallel Tests with communicator division for the SimpleComm class

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from __future__ import print_function

import unittest

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


class SimpleCommParDivTests(unittest.TestCase):

    def setUp(self):
        # COMM_WORLD Communicator and its size and
        # this MPI process's world rank
        self.gcomm = simplecomm.create_comm()
        self.gsize = MPI_COMM_WORLD.Get_size()
        self.grank = MPI_COMM_WORLD.Get_rank()

        # The group names to assume when dividing COMM_WORLD
        self.groups = ['a', 'b', 'c']

        # This MPI process's rank, color, and group after division
        self.rank = int(self.grank // len(self.groups))
        self.color = int(self.grank % len(self.groups))
        self.group = self.groups[self.color]

        # The divided communicators (monocolor and multicolor)
        self.monocomm, self.multicomm = self.gcomm.divide(self.group)

        # Every MPI process's color, group, and grank after division
        self.all_colors = [i % len(self.groups) for i in range(self.gsize)]
        self.all_groups = [self.groups[i] for i in self.all_colors]
        self.all_ranks = [int(i // len(self.groups)) for i in range(self.gsize)]

    def tearDown(self):
        pass

    def testGlobalRanksMatch(self):
        actual = self.gcomm.get_rank()
        expected = self.grank
        msg = test_info_msg(self.grank, self.gsize, 'comm.get_rank() == COMM_WORLD.Get_rank()',
                            None, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoGetRank(self):
        actual = self.monocomm.get_rank()
        expected = self.rank
        msg = test_info_msg(self.grank, self.gsize, 'mono.get_rank()',
                            None, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMultiGetRank(self):
        actual = self.multicomm.get_rank()
        expected = self.color
        msg = test_info_msg(self.grank, self.gsize, 'multi.get_rank()',
                            None, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
  
    def testMonoGetSize(self):
        actual = self.monocomm.get_size()
        expected = self.all_colors.count(self.color)
        msg = test_info_msg(self.grank, self.gsize, 'mono.get_size()',
                            None, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
  
    def testMultiGetSize(self):
        actual = self.multicomm.get_size()
        expected = self.all_ranks.count(self.rank)
        msg = test_info_msg(self.grank, self.gsize, 'multi.get_size()',
                            None, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoIsManager(self):
        actual = self.monocomm.is_manager()
        expected = (self.rank == 0)
        msg = test_info_msg(self.grank, self.gsize, 'mono.is_manager()',
                            None, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMultiIsManager(self):
        actual = self.multicomm.is_manager()
        expected = (self.color == 0)
        msg = test_info_msg(self.grank, self.gsize, 'multi.is_manager()',
                            None, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoSumInt(self):
        data = self.color + 1
        actual = self.monocomm.allreduce(data, 'sum')
        expected = self.monocomm.get_size() * data
        msg = test_info_msg(self.grank, self.gsize, 'mono.sum(int)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMultiSumInt(self):
        data = (self.rank + 1)
        actual = self.multicomm.allreduce(data, 'sum')
        expected = self.multicomm.get_size() * data
        msg = test_info_msg(self.grank, self.gsize, 'multi.sum(int)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoSumList(self):
        data = list(range(5))
        actual = self.monocomm.allreduce(data, 'sum')
        expected = self.monocomm.get_size() * sum(data)
        msg = test_info_msg(self.grank, self.gsize, 'mono.sum(list)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMultiSumList(self):
        data = list(range(5))
        actual = self.multicomm.allreduce(data, 'sum')
        expected = self.multicomm.get_size() * sum(data)
        msg = test_info_msg(self.grank, self.gsize, 'multi.sum(list)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoSumDict(self):
        data = {'a': list(range(3)), 'b': [5, 7]}
        actual = self.monocomm.allreduce(data, 'sum')
        expected = {'a': self.monocomm.get_size() * sum(range(3)),
                    'b': self.monocomm.get_size() * sum([5, 7])}
        msg = test_info_msg(self.grank, self.gsize, 'mono.sum(dict)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMultiSumDict(self):
        data = {'a': list(range(3)), 'b': [5, 7]}
        actual = self.multicomm.allreduce(data, 'sum')
        expected = {'a': self.multicomm.get_size() * sum(range(3)),
                    'b': self.multicomm.get_size() * sum([5, 7])}
        msg = test_info_msg(self.grank, self.gsize, 'multi.sum(dict)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoPartitionInt(self):
        data = self.grank
        actual = self.monocomm.partition(data, func=Duplicate())
        if self.monocomm.is_manager():
            expected = None
        else:
            expected = self.color  # By chance!
        msg = test_info_msg(self.grank, self.gsize, 'mono.partition(int)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMultiPartitionInt(self):
        data = self.grank
        actual = self.multicomm.partition(data, func=Duplicate())
        if self.multicomm.is_manager():
            expected = None
        else:
            expected = self.rank * len(self.groups)
        msg = test_info_msg(self.grank, self.gsize, 'multi.partition(int)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoPartitionIntInvolved(self):
        data = self.grank
        actual = self.monocomm.partition(data, func=Duplicate(), involved=True)
        expected = self.color  # By chance!
        msg = test_info_msg(self.grank, self.gsize, 'mono.partition(int,T)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMultiPartitionIntInvolved(self):
        data = self.grank
        actual = self.multicomm.partition(
            data, func=Duplicate(), involved=True)
        expected = self.rank * len(self.groups)
        msg = test_info_msg(self.grank, self.gsize, 'multi.partition(int,T)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoPartitionList(self):
        if self.monocomm.is_manager():
            data = list(range(10 + self.grank))
        else:
            data = None
        actual = self.monocomm.partition(data)
        if self.monocomm.is_manager():
            expected = None
        else:
            expected = list(range(self.rank - 1, 10 + self.color,
                                  self.monocomm.get_size() - 1))
        msg = test_info_msg(self.grank, self.gsize, 'mono.partition(list)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMultiPartitionList(self):
        if self.multicomm.is_manager():
            data = list(range(10 + self.grank))
        else:
            data = None
        actual = self.multicomm.partition(data)
        if self.multicomm.is_manager():
            expected = None
        else:
            expected = list(range(self.color - 1, 10 + self.rank * len(self.groups),
                                  self.multicomm.get_size() - 1))
        msg = test_info_msg(self.grank, self.gsize, 'multi.partition(list)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoPartitionListInvolved(self):
        if self.monocomm.is_manager():
            data = list(range(10 + self.grank))
        else:
            data = None
        actual = self.monocomm.partition(data, func=EqualStride(),
                                         involved=True)
        expected = list(range(self.rank, 10 + self.color, self.monocomm.get_size()))
        msg = test_info_msg(self.grank, self.gsize, 'mono.partition(list,T)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMultiPartitionListInvolved(self):
        if self.multicomm.is_manager():
            data = list(range(10 + self.grank))
        else:
            data = None
        actual = self.multicomm.partition(data, func=EqualStride(),
                                          involved=True)
        expected = list(range(self.color, 10 + self.rank * len(self.groups),
                              self.multicomm.get_size()))
        msg = test_info_msg(self.grank, self.gsize, 'multi.partition(list,T)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testMonoCollectInt(self):
        if self.monocomm.is_manager():
            data = None
            actual = [self.monocomm.collect()
                      for _ in range(1, self.monocomm.get_size())]
            expected = [i for i in
                        enumerate(range(len(self.groups) + self.color,
                                        self.gsize,
                                        len(self.groups)), 1)]
        else:
            data = self.grank
            actual = self.monocomm.collect(data)
            expected = None
        self.monocomm.sync()
        msg = test_info_msg(self.grank, self.gsize, 'mono.collect(int)',
                            data, actual, expected)
        print(msg)
        if self.monocomm.is_manager():
            for a in actual:
                self.assertTrue(a in expected, msg)
        else:
            self.assertEqual(actual, expected, msg)
 
    def testMultiCollectInt(self):
        if self.multicomm.is_manager():
            data = None
            actual = [self.multicomm.collect()
                      for _ in range(1, self.multicomm.get_size())]
            expected = [i for i in
                        enumerate([j + self.rank * len(self.groups) for j in
                                   range(1, self.multicomm.get_size())], 1)]
        else:
            data = self.grank
            actual = self.multicomm.collect(data)
            expected = None
        self.multicomm.sync()
        msg = test_info_msg(self.grank, self.gsize, 'multi.collect(int)',
                            data, actual, expected)
        print(msg)
        if self.multicomm.is_manager():
            for a in actual:
                self.assertTrue(a in expected, msg)
        else:
            self.assertEqual(actual, expected, msg)
 
    def testMonoCollectList(self):
        if self.monocomm.is_manager():
            data = None
            actual = [self.monocomm.collect()
                      for _ in range(1, self.monocomm.get_size())]
            expected = [(i, list(range(x))) for i, x in
                        enumerate(range(len(self.groups) + self.color,
                                        self.gsize,
                                        len(self.groups)), 1)]
        else:
            data = list(range(self.grank))
            actual = self.monocomm.collect(data)
            expected = None
        self.monocomm.sync()
        msg = test_info_msg(self.grank, self.gsize, 'mono.collect(list)',
                            data, actual, expected)
        print(msg)
        if self.monocomm.is_manager():
            for a in actual:
                self.assertTrue(a in expected, msg)
        else:
            self.assertEqual(actual, expected, msg)
 
    def testMultiCollectList(self):
        if self.multicomm.is_manager():
            data = None
            actual = [self.multicomm.collect()
                      for _ in range(1, self.multicomm.get_size())]
            expected = [(i, list(range(x))) for (i, x) in
                        enumerate([j + self.rank * len(self.groups) for j in
                                   range(1, self.multicomm.get_size())], 1)]
        else:
            data = list(range(self.grank))
            actual = self.multicomm.collect(data)
            expected = None
        self.multicomm.sync()
        msg = test_info_msg(self.grank, self.gsize, 'multi.collect(list)',
                            data, actual, expected)
        print(msg)
        if self.multicomm.is_manager():
            for a in actual:
                self.assertTrue(a in expected, msg)
        else:
            self.assertEqual(actual, expected, msg)
 
    def testMonoRationInt(self):
        if self.monocomm.is_manager():
            data = [100 * self.color + i
                    for i in range(1, self.monocomm.get_size())]
            actual = [self.monocomm.ration(d) for d in data]
            expected = [None] * (self.monocomm.get_size() - 1)
        else:
            data = None
            actual = self.monocomm.ration()
            expected = [100 * self.color + i
                        for i in range(1, self.monocomm.get_size())]
        self.monocomm.sync()
        msg = test_info_msg(self.grank, self.gsize, 'mono.ration(int)',
                            data, actual, expected)
        print(msg)
        if self.monocomm.is_manager():
            self.assertEqual(actual, expected, msg)
        else:
            self.assertTrue(actual in expected, msg)
 
    def testMultiRationInt(self):
        if self.multicomm.is_manager():
            data = [100 * self.rank + i
                    for i in range(1, self.multicomm.get_size())]
            actual = [self.multicomm.ration(d) for d in data]
            expected = [None] * (self.multicomm.get_size() - 1)
        else:
            data = None
            actual = self.multicomm.ration()
            expected = [100 * self.rank + i
                        for i in range(1, self.multicomm.get_size())]
        self.multicomm.sync()
        msg = test_info_msg(self.grank, self.gsize, 'multi.ration(int)',
                            data, actual, expected)
        print(msg)
        if self.multicomm.is_manager():
            self.assertEqual(actual, expected, msg)
        else:
            self.assertTrue(actual in expected, msg)
 
    def testTreeScatterInt(self):
        if self.gcomm.is_manager():
            data = 10
        else:
            data = None
 
        if self.monocomm.is_manager():
            mydata = self.multicomm.partition(
                data, func=Duplicate(), involved=True)
        else:
            mydata = None
 
        actual = self.monocomm.partition(
            mydata, func=Duplicate(), involved=True)
        expected = 10
        msg = test_info_msg(self.grank, self.gsize, 'TreeScatter(int)',
                            data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)
 
    def testTreeGatherInt(self):
        data = self.grank
 
        if self.monocomm.is_manager():
            mydata = [data]
            for _ in range(1, self.monocomm.get_size()):
                mydata.append(self.monocomm.collect()[1])
        else:
            mydata = self.monocomm.collect(data)
 
        if self.gcomm.is_manager():
            actual = [mydata]
            for _ in range(1, self.multicomm.get_size()):
                actual.append(self.multicomm.collect()[1])
        elif self.monocomm.is_manager():
            actual = self.multicomm.collect(mydata)
        else:
            actual = None
 
        expected = 10
        msg = test_info_msg(self.grank, self.gsize, 'TreeGather(int)',
                            data, actual, expected)
        print(msg)


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
    tests = unittest.TestLoader().loadTestsFromTestCase(SimpleCommParDivTests)
    unittest.TextTestRunner(stream=mystream).run(tests)
    MPI_COMM_WORLD.Barrier()

    results = MPI_COMM_WORLD.gather(mystream.getvalue())
    if MPI_COMM_WORLD.Get_rank() == 0:
        for rank, result in enumerate(results):
            print(hline)
            print('TESTS RESULTS FOR RANK ' + str(rank) + ':')
            print(hline)
            print(str(result))
