#!/usr/bin/env python
"""
ncdiff

Command-Line Utility to show the differences between two NetCDF files

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from os import linesep
from os.path import isfile
from argparse import ArgumentParser
from netCDF4 import Dataset, Dimension, Variable
from random import randint
from numpy import ndarray, allclose

#=======================================================================================================================
# Argument Parser
#=======================================================================================================================
__PARSER__ = ArgumentParser(description='Difference two NetCDF files')
__PARSER__.add_argument('--header', default=False, action='store_true',
                        help='Difference header information only')
__PARSER__.add_argument('-f', '--full', default=False, action='store_true',
                        help='Perform full data comparison')
__PARSER__.add_argument('-s', '--spot', default=0, type=int,
                        help='Number of spot checks in data to difference')
__PARSER__.add_argument('-r', '--rtol', default=1e-5, type=float,
                        help='Relative tolerance when comparing numbers')
__PARSER__.add_argument('-a', '--atol', default=1e-8, type=float,
                        help='Absolute tolerance when comparing numbers')
__PARSER__.add_argument('file1', type=str, help='Name of first NetCDF file')
__PARSER__.add_argument('file2', type=str, help='Name of second NetCDF file')


#=======================================================================================================================
# cli - Command-Line Interface
#=======================================================================================================================
def cli(argv=None):
    """
    Command-Line Interface
    """
    return __PARSER__.parse_args(argv)


#=======================================================================================================================
# _cmp - Comparison function
#=======================================================================================================================
def _cmp(a1,a2,rtol=1e-5,atol=1e-8):
    if a1 is None or a2 is None:
        return True
    elif isinstance(a1, Dimension):
        if a1._name != a2._name:
            return True
        elif len(a1) != len(a2):
            return True
        else:
            return a1.isunlimited() != a2.isunlimited()
    elif isinstance(a1, Variable):
        if a1._name != a2._name:
            return True
        elif a1.dtype != a2.dtype:
            return True
        else:
            return a1.dimensions != a2.dimensions
    elif isinstance(a1, ndarray):
        return not allclose(a1, a2, rtol=rtol, atol=atol)
    elif isinstance(a1, basestring):
        return a1 != a2
    else:
        try:
            res = not allclose(a1, a2, rtol=rtol, atol=atol)
        except:
            res = a1 != a2
        return res


#=======================================================================================================================
# _str - String producing function
#=======================================================================================================================
def _str(a):
    if a is None:
        return '_'*10
    elif isinstance(a, Dimension):
        return '{}({}{})'.format(a._name, len(a), '+' if a.isunlimited() else '')
    elif isinstance(a, Variable):
        dstr = '({})'.format(','.join(a.dimensions))
        return '{} {}{}'.format(a.dtype, a._name, dstr)
    elif isinstance(a, ndarray):
        sa = str(a)
        n1 = sa.find(linesep)
        n2 = sa.rfind(linesep)
        return sa[:n1] + ' ... ' + sa[n2+1:] if n2 > n1 else sa.replace(linesep, '')
    else:
        return str(a)

        
#=======================================================================================================================
# diff_dicts
#=======================================================================================================================
def diff_dicts(d1, d2, name='object', rtol=1e-5, atol=1e-8):
    d12union = set.union(set(d1), set(d2))
    diffs = []
    for k in sorted(d12union):
        d1k = d1.get(k, None)
        d2k = d2.get(k, None)
        if _cmp(d1k, d2k, rtol=rtol, atol=atol):
            diffs.append((str(k), _str(d1k), _str(d2k)))
    if len(diffs) > 0:
        print
        print 'Differences found in {}:'.format(name)
        klen = max([len(ks) for ks, _, _ in diffs])
        d1len = max([len(d1s) for _, d1s, _ in diffs])
        d2len = max([len(d2s) for _, _, d2s in diffs])
        for ks, d1s, d2s in diffs:
            print ('   {:{kl}s}:   {:>{d1}s}   <===>   {:{d2}s}'
                   ''.format(ks, d1s, d2s, kl=klen, d1=d1len, d2=d2len))


#=======================================================================================================================
# _int_to_indices
#=======================================================================================================================
def _int_to_indices(n, shape):
    indices = []
    strides = reversed([reduce(lambda x,y: x*y, shape[:i], 1) for i in xrange(len(shape))])
    for s in strides:
        indices.append(n // s)
        n = n % s
    return tuple(reversed(indices))


#=======================================================================================================================
# _rand_interior_indices
#=======================================================================================================================
def _rand_interior_indices(shape):
    indices = []
    for s in shape:
        if s > 2:
            indices.append(randint(1,s-2))
        elif s==2:
            indices.append(randint(0,1))
        else:
            indices.append(0)
    return tuple(indices)


#=======================================================================================================================
# _sample_indices
#=======================================================================================================================
def _sample_indices(shape, nspot=0):
    samples = []
    size = 2**len(shape)
    for i in xrange(size):
        samples.append(tuple([n*(s-1) for n,s in zip(_int_to_indices(i, [2]*size), shape)]))
    for i in xrange(nspot):
        samples.append(_rand_interior_indices(shape))
    return samples

    
#=======================================================================================================================
# main - Main Program
#=======================================================================================================================
def main(argv=None):
    """
    Main program
    """
    args = cli(argv)

    FILE1 = args.file1
    if not isfile(FILE1):
        raise ValueError('NetCDF file {} not found'.format(FILE1))
    shortf1 = FILE1.split('/')[-1]

    FILE2 = args.file2
    if not isfile(FILE2):
        raise ValueError('NetCDF file {} not found'.format(FILE2))
    shortf2 = FILE2.split('/')[-1]

    rtol = args.rtol
    atol = args.atol
    
    ncf1 = Dataset(FILE1)
    ncf2 = Dataset(FILE2)
    
    print
    print 'Displaying differences between the contents of files:'
    print '   {}   <===>   {}'.format(shortf1, shortf2)
    
    # Global file attributes
    f1atts = {a:ncf1.getncattr(a) for a in ncf1.ncattrs()}
    f2atts = {a:ncf2.getncattr(a) for a in ncf2.ncattrs()}
    diff_dicts(f1atts, f2atts, name='Global File Attributes')
    
    # Dimensions
    f1dims = {d:ncf1.dimensions[d] for d in ncf1.dimensions}
    f2dims = {d:ncf2.dimensions[d] for d in ncf2.dimensions}
    diff_dicts(f1dims, f2dims, name='File Dimensions')
    
    # Variable Header Info
    f1vars = {v:ncf1.variables[v] for v in ncf1.variables}
    f2vars = {v:ncf2.variables[v] for v in ncf2.variables}
    diff_dicts(f1vars, f2vars, name='Variable Headers')
    
    f12vars = [v for v in ncf1.variables if v in ncf2.variables]
    vars = [v for v in f12vars if ncf1.variables[v].shape == ncf2.variables[v].shape]

    # Variable Attributes
    for v in vars:
        v1 = ncf1.variables[v]
        v2 = ncf2.variables[v]
        v1atts = {attr:v1.getncattr(attr) for attr in v1.ncattrs()}
        v2atts = {attr:v1.getncattr(attr) for attr in v1.ncattrs()}
        diff_dicts(v1atts, v2atts, name='Variable {!s} Attributes'.format(v))
    
    # Variable Data
    if not args.header:
        for v in vars:
            v1 = ncf1.variables[v]
            v2 = ncf2.variables[v]
            if args.full:
                v1data = {'[:]': v1[:]}
                v2data = {'[:]': v2[:]}
            else:
                idxs = _sample_indices(v1.shape, nspot=args.spot)
                v1data = {idx:v1[idx] for idx in idxs}
                v2data = {idx:v2[idx] for idx in idxs}
            vdims = ','.join(str(d) for d in v1.dimensions)
            diff_dicts(v1data, v2data, name='Variable {!s}({}) Data'.format(v, vdims), rtol=rtol, atol=atol)


#=======================================================================================================================
# Command-line Operation
#=======================================================================================================================
if __name__ == '__main__':
    main()
