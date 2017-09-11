"""
Indexing Functions

The 'index_str' method gives a compact string representation of an indexing object (i.e., an
object returned by the Numpy.index_exp[] method).

    >>> idx = numpy.index_exp[1:2:3, 4]

    >>> index_str(idx)
    '1:2:3, 4'

----------------------------------------------------------------------------------------------------

The 'join' operation in this module is designed to reduce multiple slicing operations, where
consecutive slices are reduced to a single slice:

    A[slice1][slice2] = A[slice12]

Most Python programmers that work with Numpy have been told that slicing an array results in a 
'view' of the array.  Namely, they have been told that slicing the array costs nothing, so multiple
consecutive slices need no reduction.

While this statement is true for in-memory (Numpy) arrays, array-like access to data stored on file
(NetCDF, for example) presents a problem.  The first slice of the file-storaged data results in an
I/O read operation which returns an in-memory (Numpy) array, and the second slice results in a view
of that array.  The I/O operation can be costly, so it is worth our time to invest in a way of
reducing the amount of data read, as well as limiting the possibility of overrunning memory with
a large read.

----------------------------------------------------------------------------------------------------

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from types import EllipsisType
from numpy import index_exp


#===================================================================================================
# index_str
#===================================================================================================
def index_str(index):
    """
    Convert an index expression into a compact string
    """
    if index is None:
        return ':'
    elif isinstance(index, int):
        return str(index)
    elif isinstance(index, EllipsisType):
        return '...'
    elif isinstance(index, slice):
        strrep = ''
        if index.start is not None:
            strrep += str(index.start)
        strrep += ':'
        if index.stop is not None:
            strrep += str(index.stop)
        if index.step is not None:
            strrep += ':{!s}'.format(index.step)
        return strrep
    elif isinstance(index, tuple):
        return ', '.join(index_str(i) for i in index)
    elif isinstance(index, dict):
        dims = sorted(index)
        return ', '.join('{!r}: {}'.format(d, index_str(index[d])) for d in dims)
    else:
        raise TypeError('Unsupported index type {!r}'.format(type(index)))


#===================================================================================================
# index_tuple
#===================================================================================================
def index_tuple(index, ndims):
    """
    Generate an index tuple from a given index expression and number of dimensions
    """
    if ndims == 0:
        return ()

    idx = index_exp[index]

    # Find the locations of all Ellipsis in the index expression
    elocs = [loc for loc, i in enumerate(idx) if isinstance(i, EllipsisType)]
    if len(elocs) == 0:
        nfill = ndims - len(idx)
        if nfill < 0:
            raise IndexError('Too many indices for array with {} dimensions'.format(ndims))
        return idx + (slice(None),) * nfill
    elif len(elocs) == 1:
        eloc = elocs[0]
        prefix = idx[:eloc]
        suffix = idx[eloc + 1:]
        nfill = ndims - len(prefix) - len(suffix)
        if nfill < 0:
            raise IndexError('Too many indices for array with {} dimensions'.format(ndims))
        return prefix + (slice(None),) * nfill + suffix
    else:
        raise IndexError('Too many ellipsis in index expression {}'.format(idx))


#===================================================================================================
# align_index - Align index tuple/dictionary along dimensions
#===================================================================================================
def align_index(index, dimensions):
    """
    Compute an index tuple or dictionary with indices aligned according to dimension name
    
    Parameters:
        index: An index or a dictionary of indices keyed by dimension name
        dimensions (tuple): A tuple of named dimensions for each axis of the data
    """
    if index is None:
        return tuple(slice(0, 0) for d in dimensions)
    elif isinstance(index, dict):
        return tuple(index.get(d, slice(None)) for d in dimensions)
    else:
        return index_tuple(index, len(dimensions))


#===================================================================================================
# join
#===================================================================================================
def join(shape0, index1, index2):
    """
    Join two index expressions into a single index expression
    
    Parameters:
        shape0: The shape of the original array
        index1: The first index expression to apply to the array
        index2: The second index expression to apply to the array
    """
    if not isinstance(shape0, tuple):
        raise TypeError('Array shape must be a tuple')
    for n in shape0:
        if not isinstance(n, int):
            raise TypeError('Array shape must be a tuple of integers')

    ndims0 = len(shape0)
    idx1 = index_tuple(index1, ndims0)
    ndims1 = map(lambda i: isinstance(i, slice), idx1).count(True)
    idx2 = index_tuple(index2, ndims1)

    idx2_l = list(idx2)
    idx12 = []
    for i1, l0 in zip(idx1, shape0):
        if isinstance(i1, slice):
            i2 = idx2_l.pop(0)
            start1, stop1, step1 = i1.indices(l0)
            l1 = (abs(stop1 - start1) - 1) // abs(step1) + 1
            if isinstance(i2, slice):
                if (stop1 - start1) * step1 > 0:
                    start2, stop2, step2 = i2.indices(l1)
                    step12 = step1 * step2
                    start12 = start1 + start2 * step1
                    if (stop2 - start2) * step2 > 0:
                        stop12 = start1 + stop2 * step1
                        if start12 > stop12 and stop12 < 0:
                            stop12 = None
                        idx12.append(slice(start12, stop12, step12))
                    else:
                        idx12.append(slice(0, 0))
                else:
                    idx12.append(slice(0, 0))
            else:
                if i2 < -l1 or i2 >= l1:
                    raise IndexError('Second index out of range in array')
                idx12.append(start1 + i2 * step1)
        else:
            if i1 < -l0 or i1 >= l0:
                raise IndexError('First index out of range in array')
            idx12.append(i1)
    return tuple(idx12)
