"""
Unit Testing Utilities

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from re import sub
from os import linesep
from numpy import dtype
from netCDF4 import Dataset

#=======================================================================================================================
# print_test_message
#=======================================================================================================================
def print_test_message(testname, **kwds):
    print '{}:'.format(testname)
    if len(kwds) > 0:
        args = sorted(kwds)
        nlen = max(len(k) for k in kwds)
        for k in args:
            val_str = sub(' +', ' ', repr(kwds[k]).replace(linesep, ' '))
            print ' - {0:<{1}} = {2}'.format(k, nlen, val_str)
    print


#=======================================================================================================================
# print_ncfile
#=======================================================================================================================
def print_ncfile(filename):
    with Dataset(filename, 'r') as ncf:
        print 'File: {!r}'.format(filename)
        print '   Data Model: {!r}'.format(ncf.data_model)
        print '   Disk Format: {!r}'.format(ncf.disk_format)
        print '   Attributes:'
        for a in sorted(ncf.ncattrs()):
            print '      {}: {!r}'.format(a, ncf.getncattr(a))
        print '   Dimensions:'
        for d in sorted(ncf.dimensions):
            dobj = ncf.dimensions[d]
            print '      {}: {} {}'.format(d, dobj.size, '[Unlimited]' if dobj.isunlimited() else '')
        print '   Variables:'
        for v in sorted(ncf.variables):
            vobj = ncf.variables[v]
            vdimstr = ','.join(vobj.dimensions)
            header = '      {!s} {}({}): '.format(vobj.dtype, v, vdimstr)
            vdat = vobj[:]
            if vobj.dtype == dtype('c'):
                vdat = vdat.data.view('S{}'.format(vdat.shape[-1])).reshape(vdat.shape[:-1])
            datastr = str(vdat).replace('\n', '\n{}'.format(' ' * len(header)))
            print '{}{}'.format(header, datastr)
            for vattr in vobj.ncattrs():
                print '         {}: {}'.format(vattr, vobj.getncattr(vattr))

