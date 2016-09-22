"""
A module for data partitioning functions.

This provides a collection of 'partitioning' functions.  A partitioning
function is a three-argument function that takes, as the first argument, a
given data object and, as the second argument, an index into that object and,
as the third argument, a maximum index.  The operation of the partitioning
function is to return a subset of the data corresponding to the given index.

By design, partitioning functions should keep the data "unchanged" except for
subselecting parts of the data.

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from abc import ABCMeta, abstractmethod
from operator import itemgetter


#==============================================================================
# PartitionFunction -
# Base class for all partitioning functions
#==============================================================================
class PartitionFunction(object):

    """
    The abstract base-class for all Partitioning Function objects.

    A PartitionFunction object is one with a __call__ method that takes
    three arguments.  The first argument is the data to be partitioned, the 
    second argument is the index of the partition (or part) requested, and 
    third argument is the number of partitions to assume when dividing
    the data.
    """
    __metaclass__ = ABCMeta

    @staticmethod
    def _check_types(data, index, size):
        """
        Check the types of the index and size arguments.

        Parameters:
            data: The data to be partitioned
            index (int): The index of the partition to return
            size (int): The number of partitions to make

        Raises:
            TypeError: The size or index arguments are not int
            IndexError: The size argument is less than 1, or the index
                argument is less than 0 or greater than or equal to size
        """

        # Check the type of the index
        if type(index) is not int:
            raise TypeError('Partition index must be an integer')

        # Check the value of index
        if index > size - 1 or index < 0:
            raise IndexError('Partition index out of bounds')

        # Check the type of the size
        if type(size) is not int:
            raise TypeError('Partition size must be an integer')

        # Check the value of size
        if size < 1:
            raise IndexError('Partition size less than 1 is invalid')

    @staticmethod
    def _is_indexable(data):
        """
        Check if the data object is indexable.

        Parameters:
            data: The data to be partitioned

        Returns:
            bool: True, if data is an indexable object. False, otherwise.
        """
        if hasattr(data, '__len__') and hasattr(data, '__getitem__'):
            return True
        else:
            return False

    @staticmethod
    def _are_pairs(data):
        """
        Check if the data object is an indexable list of pairs.

        Parameters:
            data: The data to be partitioned

        Returns:
            bool: True, if data is an indexable list of pairs.
                False, otherwise.
        """
        if PartitionFunction._is_indexable(data):
            return all(map(lambda i: PartitionFunction._is_indexable(i)
                           and len(i) == 2, data))
        else:
            return False

    @abstractmethod
    def __call__(self):
        """
        Implements the partition algorithm.
        """
        return


#==============================================================================
# Duplicate Partitioning Function -
# Grab parts of a list-like object with equal lengths
#==============================================================================
class Duplicate(PartitionFunction):

    """
    Return a copy of the original input data in each partition.
    """

    def __call__(self, data, index=0, size=1):
        """
        Define the common interface for all partitioning functions.

        The abstract base class implements the check on the input for correct
        format and typing.

        Parameters:
            data: The data to be partitioned

        Keyword Arguments:
            index (int): A partition index into a part of the data
            size (int): The largest number of partitions allowed

        Returns:
            The indexed part of the data, assuming the data is divided into
            size parts.
        """
        self._check_types(data, index, size)

        return data


#==============================================================================
# EqualLength Partitioning Function -
# Grab parts of a list-like object with equal lengths
#==============================================================================
class EqualLength(PartitionFunction):

    """
    Partition an indexable object by striding through the data.

    The initial object is "chopped" along its length into roughly equal length
    sublists.  If the partition size is greater than the length of the input 
    data, then it will return an empty list for 'empty' partitions.  If the 
    data is not indexable, then it will return the data for index=0 only, and 
    an empty list otherwise.  
    """

    def __call__(self, data, index=0, size=1):
        """
        Define the common interface for all partitioning functions.

        The abstract base class implements the check on the input for correct
        format and typing.

        Parameters:
            data: The data to be partitioned

        Keyword Arguments:
            index (int): A partition index into a part of the data
            size (int): The largest number of partitions allowed

        Returns:
            The indexed part of the data, assuming the data is divided into
            size parts.
        """
        self._check_types(data, index, size)

        if self._is_indexable(data):
            (lenpart, remdata) = divmod(len(data), size)
            psizes = [lenpart] * size
            for i in xrange(remdata):
                psizes[i] += 1
            ibeg = 0
            for i in xrange(index):
                ibeg += psizes[i]
            iend = ibeg + psizes[index]
            return data[ibeg:iend]
        else:
            if index == 0:
                return [data]
            else:
                return []


#==============================================================================
# EqualStride Partitioning Function -
# Grab parts of a list-like object with equal lengths
#==============================================================================
class EqualStride(PartitionFunction):

    """
    Partition an object by chopping the data into roughly equal lengths.

    This returns a sublist of an indexable object by "striding" through the
    data in steps equal to the partition size.  If the partition size is 
    greater than the length of the input data, then it will return an empty 
    list for "empty" partitions.  If the data is not indexable, then it will
    return the data for index=0 only, and an empty list otherwise.
    """

    def __call__(self, data, index=0, size=1):
        """
        Define the common interface for all partitioning functions.

        The abstract base class implements the check on the input for correct
        format and typing.

        Parameters:
            data: The data to be partitioned

        Keyword Arguments:
            index (int): A partition index into a part of the data
            size (int): The largest number of partitions allowed

        Returns:
            The indexed part of the data, assuming the data is divided into
            size parts.
        """
        self._check_types(data, index, size)

        if self._is_indexable(data):
            if index < len(data):
                return data[index::size]
            else:
                return []
        else:
            if index == 0:
                return [data]
            else:
                return []


#==============================================================================
# SortedStride PartitionFunction -
# Grab parts of an indexable object with equal length  after sorting by weights
#==============================================================================
class SortedStride(PartitionFunction):

    """
    Partition an indexable list of pairs by striding through sorted data.

    The first index of each pair is assumed to be an item of data (which will 
    be partitioned), and the second index in each pair is assumed to be a 
    numeric weight.  The pairs are first sorted by weight, and then partitions 
    are returned by striding through the sorted data.

    The results are partitions of roughly equal length and roughly equal
    total weight.  However, equal length is prioritized over total weight.
    """

    def __call__(self, data, index=0, size=1):
        """
        Define the common interface for all partitioning functions.

        The abstract base class implements the check on the input for correct
        format and typing.

        Parameters:
            data: The data to be partitioned

        Keyword Arguments:
            index (int): A partition index into a part of the data
            size (int): The largest number of partitions allowed

        Returns:
            The indexed part of the data, assuming the data is divided into
            size parts.
        """
        self._check_types(data, index, size)

        if self._are_pairs(data):
            subdata = [q[0] for q in sorted(data, key=itemgetter(1))]
            return EqualStride()(subdata, index=index, size=size)
        else:
            return EqualStride()(data, index=index, size=size)


#==============================================================================
# WeightBalanced PartitionFunction -
# Grab parts of an indexable object that have equal (or roughly equal)
# total weight, though not necessarily equal length
#==============================================================================
class WeightBalanced(PartitionFunction):

    """
    Partition an indexable list of pairs by balancing the total weight.

    The first index of each pair is assumed to be an item of data (which will 
    be partitioned), and the second index in each pair is assumed to be a 
    numeric weight.  The data items are grouped via a "greedy" binning 
    algorithm into partitions of roughly equal total weight.

    The results are partitions of roughly equal length and roughly equal
    total weight.  However, equal total weight is prioritized over length.

    """

    def __call__(self, data, index=0, size=1):
        """
        Define the common interface for all partitioning functions.

        The abstract base class implements the check on the input for correct
        format and typing.

        Parameters:
            data: The data to be partitioned

        Keyword Arguments:
            index (int): A partition index into a part of the data
            size (int): The largest number of partitions allowed

        Returns:
            The indexed part of the data, assuming the data is divided into
            size parts.
        """
        self._check_types(data, index, size)

        if self._are_pairs(data):
            sorted_pairs = sorted(data, key=itemgetter(1), reverse=True)
            partition = []
            weights = [0] * size
            for (item, weight) in sorted_pairs:
                k = min(enumerate(weights), key=itemgetter(1))[0]
                if k == index:
                    partition.append(item)
                weights[k] += weight
            return partition
        else:
            return EqualStride()(data, index=index, size=size)
