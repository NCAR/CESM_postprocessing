"""
Unit tests for the iobackend module

Copyright 2017, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

import unittest
import numpy as np
import numpy.testing as npt
import netCDF4
import Nio
import inspect

from pyreshaper import iobackend
from os import linesep, remove
from os.path import exists


#=========================================================================
# print_test_msg
#=========================================================================
def print_test_msg(testname, **kwds):
    msg = ['{} (backend={}):'.format(testname, iobackend.get_backend())]
    for kwd in sorted(kwds):
        msg.append('   - {}: {}'.format(kwd, kwds[kwd]))
    msg.append('')
    print linesep.join(msg)


#=========================================================================
# test_func
#=========================================================================
def test_func(testname, func, expected, msg, kwds={}):
    try:
        actual = func(**kwds)
        print_test_msg(testname, actual=actual, expected=expected, **kwds)
    except Exception, err:
        actual = type(err)
        errmsg = str(err)
        print_test_msg(testname, actual=actual, errmsg=errmsg,
                       expected=expected, **kwds)
    npt.assert_equal(actual, expected, '{}'.format(msg))


#=========================================================================
# test_func_avail
#=========================================================================
def test_func_avail(testname, func, expected, msg, kwds={}):
    for backend in iobackend._AVAILABLE_:
        iobackend.set_backend(backend)
        npt.assert_equal(iobackend.get_backend(), backend,
                         'Cannot set backend {}'.format(backend))
        test_func(testname, func, expected,
                  msg='{}: {}'.format(backend, msg), kwds=kwds)


#=========================================================================
# test_name
#=========================================================================
def test_name():
    frame = inspect.stack()[1][0]
    fclass = frame.f_locals["self"].__class__.__name__
    fmethod = frame.f_code.co_name
    return '{}.{}'.format(fclass, fmethod)


#=========================================================================
# ReadTests
#=========================================================================
class ReadTests(unittest.TestCase):

    """
    ReadTests Class

    This class defines all of the unit tests for the iobackend module.
    """

    def setUp(self):
        self.ncfrname = 'readtest.nc'
        self.ncattrs = {'a1': 'attribute 1', 'a2': 'attribute 2'}
        self.ncdims = {'t': 10, 'x': 5, 'c': 14}
        self.vdims = {'t': ('t',), 'x': ('x',), 'v': ('t', 'x'), 's': ('c',)}
        self.vdtype = {'t': 'd', 'x': 'd', 'v': 'f', 's': 'c'}
        self.vshape = {'t': (self.ncdims['t'],), 'x': (self.ncdims['x'],),
                       'v': (self.ncdims['t'], self.ncdims['x']), 's': (self.ncdims['c'],)}
        self.ncvars = {'t': np.arange(0, self.ncdims['t'], dtype=self.vdtype['t']),
                       'x': np.random.ranf(self.ncdims['x']).astype(self.vdtype['x']),
                       'v': np.random.ranf(self.ncdims['t'] * self.ncdims['x']).reshape(10, 5).astype(self.vdtype['v']),
                       's': np.array([c for c in 'this is a stri'])}
        self.vattrs = {'t': {'long_name': u'time', 'units': u'days'},
                       'x': {'long_name': u'space', 'units': u'meters'},
                       'v': {'long_name': u'variable', 'units': u'kg', 'missing_value': np.float32(1e20)},
                       's': {'long_name': u'string'}}
        self.vfill = {'t': None, 'x': None, 'v': np.float32(1e20), 's': None}

        ncfile = netCDF4.Dataset(self.ncfrname, 'w')
        for a in self.ncattrs:
            setattr(ncfile, a, self.ncattrs[a])
        for d in self.ncdims:
            if d == 't':
                ncfile.createDimension(d)
            else:
                ncfile.createDimension(d, self.ncdims[d])
        for v in self.ncvars:
            vobj = ncfile.createVariable(
                v, self.vdtype[v], self.vdims[v], fill_value=self.vfill[v])
            for a in self.vattrs[v]:
                vobj.setncattr(a, self.vattrs[v][a])
            vobj[:] = self.ncvars[v]
        ncfile.close()

    def tearDown(self):
        if exists(self.ncfrname):
            remove(self.ncfrname)

    def test_set_get(self):
        test_func_avail(test_name(), lambda: True, True, 'Cannot set backend')

    def test_set_failure(self):
        test_func(test_name(), iobackend.set_backend, KeyError,
                  'Expected failure', kwds={'name': 'x'})

    def test_NCFile_init_mode_failure(self):
        test_func(test_name(), iobackend.NCFile, ValueError, 'Expected failure',
                  kwds={'filename': self.ncfrname, 'mode': 'x'})

    def test_NCFile_init(self):
        def func():
            ncf = iobackend.NCFile(self.ncfrname)
            actual = type(ncf)
            ncf.close()
            return actual
        expected = iobackend.NCFile
        test_func_avail(test_name(), func, expected,
                        'NCFile not created with correct type')

    def test_NCFile_dimensions(self):
        def func():
            ncf = iobackend.NCFile(self.ncfrname)
            actual = ncf.dimensions
            ncf.close()
            return actual
        expected = self.ncdims
        test_func_avail(test_name(), func, expected,
                        'NCFile dimensions incorrect')

    def test_NCFile_unlimited(self):
        def func(dimension=''):
            ncf = iobackend.NCFile(self.ncfrname)
            actual = ncf.unlimited(dimension)
            ncf.close()
            return actual
        for d, x in [('t', True), ('x', False)]:
            test_func_avail(test_name(), func, x, 'NCFile dimension {} unlimited is {}'.format(d, x),
                            kwds={'dimension': d})

    def test_NCFile_ncattrs(self):
        def func():
            ncf = iobackend.NCFile(self.ncfrname)
            actual = ncf.ncattrs
            ncf.close()
            return actual
        test_func_avail(test_name(), func, self.ncattrs.keys(),
                        'NCFile ncattrs incorrect')

    def test_NCFile_variables(self):
        def func():
            ncf = iobackend.NCFile(self.ncfrname)
            actual = {v: type(ncf.variables[v]) for v in ncf.variables}
            ncf.close()
            return actual
        expected = {v: iobackend.NCVariable for v in self.ncvars}
        test_func_avail(test_name(), func, expected,
                        'NCFile variables incorrect')

    def test_NCFile_variable_data(self):
        def func():
            ncf = iobackend.NCFile(self.ncfrname)
            actual = {v: ncf.variables[v][:] for v in ncf.variables}
            ncf.close()
            return actual
        test_func_avail(test_name(), func, self.ncvars,
                        'NCFile variables incorrect')

    def test_NCVariable_ncattrs_getncattr(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfrname)
            actual = {a: ncf.variables[variable].getncattr(
                a) for a in ncf.variables[variable].ncattrs}
            ncf.close()
            return actual
        for v in self.vattrs:
            expected = self.vattrs[v]
            test_func_avail(test_name(), func, expected, 'NCVariable {} ncattrs incorrect'.format(v),
                            kwds={'variable': v})

    def test_NCVariable_dimensions(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfrname)
            actual = ncf.variables[variable].dimensions
            ncf.close()
            return actual
        for v in self.vdtype:
            expected = self.vdims[v]
            test_func_avail(test_name(), func, expected, 'NCVariable {} dimensions incorrect'.format(v),
                            kwds={'variable': v})

    def test_NCVariable_datatype(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfrname)
            actual = ncf.variables[variable].datatype
            ncf.close()
            return actual
        for v in self.vdtype:
            expected = np.dtype(self.vdtype[v])
            test_func_avail(test_name(), func, expected, 'NCVariable {} datatype incorrect'.format(v),
                            kwds={'variable': v})

    def test_NCVariable_shape(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfrname)
            actual = ncf.variables[variable].shape
            ncf.close()
            return actual
        for v in self.vshape:
            expected = self.vshape[v]
            test_func_avail(test_name(), func, expected, 'NCVariable {} shape incorrect'.format(v),
                            kwds={'variable': v})

    def test_NCVariable_fill_value(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfrname)
            actual = ncf.variables[variable].fill_value
            ncf.close()
            return actual
        for v in self.vfill:
            expected = self.vfill[v]
            test_func_avail(test_name(), func, expected, 'NCVariable {} fill value incorrect'.format(v),
                            kwds={'variable': v})

    def test_NCVariable_size(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfrname)
            actual = ncf.variables[variable].size
            ncf.close()
            return actual
        for v in self.vdims:
            expected = reduce(lambda x, y: x * y,
                              (self.ncdims[d] for d in self.vdims[v]), 1)
            test_func_avail(test_name(), func, expected, 'NCVariable {} size incorrect'.format(v),
                            kwds={'variable': v})

    def test_NCVariable_getitem(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfrname)
            actual = ncf.variables[variable][:]
            ncf.close()
            return actual
        for v in self.vdims:
            expected = self.ncvars[v]
            test_func_avail(test_name(), func, expected, 'NCVariable {} getitem incorrect'.format(v),
                            kwds={'variable': v})


#=========================================================================
# WriteTests
#=========================================================================
class WriteTests(unittest.TestCase):

    """
    WriteTests Class

    This class defines all of the unit tests for the iobackend module.
    """

    def setUp(self):
        self.ncfwname = 'writetest.nc'
        self.ncattrs = {'a1': 'attribute 1', 'a2': 'attribute 2'}
        self.ncdims = {'t': 10, 'x': 5, 'c': 14, 'n': 2}
        self.vdims = {'t': ('t',), 'x': ('x',), 'v': ('t', 'x'),
                      's': ('n', 'c'), 'c': ('c',)}
        self.vdtype = {'t': 'd', 'x': 'd', 'v': 'f', 's': 'c', 'c': 'c'}
        self.vshape = {v: tuple(self.ncdims[d]
                                for d in self.vdims[v]) for v in self.vdims}
        self.ncvars = {'t': np.arange(0, self.ncdims['t'], dtype=self.vdtype['t']),
                       'x': np.random.ranf(self.ncdims['x']).astype(self.vdtype['x']),
                       'v': np.random.ranf(self.ncdims['t'] * self.ncdims['x']).reshape(10, 5).astype(self.vdtype['v']),
                       's': np.array(['a string', 'another string'], dtype='S14').view('S1').reshape(self.vshape['s']),
                       'c': np.array('scalar str', dtype='S14').reshape(1).view('S1')}
        self.vattrs = {'t': {'long_name': u'time', 'units': u'days'},
                       'x': {'long_name': u'space', 'units': u'meters'},
                       'v': {'long_name': u'variable', 'units': u'kg', 'missing_value': np.float32(1e20)},
                       's': {'long_name': u'vector of strings'},
                       'c': {'long_name': u'scalar string'}}
        self.vfill = {'t': None, 'x': None,
                      'v': np.float32(1e20), 's': '', 'c': None}
        self.chunks = {'t': [5], 'x': None,
                       'v': [2, 3], 's': None, 'c': None}

    def tearDown(self):
        if exists(self.ncfwname):
            remove(self.ncfwname)

    def test_NCFile_init_write(self):
        def func():
            ncf = iobackend.NCFile(self.ncfwname, mode='w')
            actual = type(ncf)
            ncf.close()
            remove(self.ncfwname)
            return actual
        expected = iobackend.NCFile
        test_func_avail(test_name(), func, expected,
                        'NCFile not created with correct type')

    def test_NCFile_setncattr(self):
        def func():
            ncf = iobackend.NCFile(self.ncfwname, mode='w')
            for a in self.ncattrs:
                ncf.setncattr(a, self.ncattrs[a])
            ncf.close()
            ncfr = iobackend.NCFile(self.ncfwname)
            actual = {a: ncfr.getncattr(a) for a in ncfr.ncattrs}
            ncfr.close()
            remove(self.ncfwname)
            return actual
        expected = self.ncattrs
        test_func_avail(test_name(), func, expected,
                        'NCFile attributes incorrect')

    def test_NCFile_create_dimension(self):
        def func():
            ncf = iobackend.NCFile(self.ncfwname, mode='w')
            for d in self.ncdims:
                ncf.create_dimension(d, self.ncdims[d])
            ncf.close()
            ncfr = iobackend.NCFile(self.ncfwname)
            actual = ncfr.dimensions
            ncfr.close()
            remove(self.ncfwname)
            return actual
        expected = self.ncdims
        test_func_avail(test_name(), func, expected,
                        'NCFile dimensions incorrect')

    def test_NCFile_create_dimension_unlimited(self):
        def func():
            ncf = iobackend.NCFile(self.ncfwname, mode='w')
            ncf.create_dimension('t')
            ncf.create_dimension('x', 3)
            ncf.close()
            ncfr = iobackend.NCFile(self.ncfwname)
            actual = {d: (ncfr.dimensions[d], ncfr.unlimited(d))
                      for d in ncfr.dimensions}
            ncfr.close()
            remove(self.ncfwname)
            return actual
        expected = {'t': (0, True), 'x': (3, False)}
        test_func_avail(test_name(), func, expected,
                        'NCFile unlimited dimensions incorrect')

    def test_NCFile_create_variable(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfwname, mode='w')
            for d in self.vdims[variable]:
                if d == 't':
                    ncf.create_dimension(d)
                else:
                    ncf.create_dimension(d, self.ncdims[d])
            ncf.create_variable(
                variable, self.vdtype[variable], self.vdims[variable])
            ncf.close()
            ncfr = iobackend.NCFile(self.ncfwname)
            actual = type(ncfr.variables[variable])
            ncfr.close()
            remove(self.ncfwname)
            return actual
        for v in self.ncvars:
            expected = iobackend.NCVariable
            test_func_avail(test_name(), func, expected,
                            'NCFile variables incorrect', kwds={'variable': v})

    def test_NCFile_create_variable_fill(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfwname, mode='w')
            for d in self.vdims[variable]:
                if d == 't':
                    ncf.create_dimension(d)
                else:
                    ncf.create_dimension(d, self.ncdims[d])
            ncf.create_variable(
                variable, self.vdtype[variable], self.vdims[variable], fill_value=self.vfill[variable])
            ncf.close()
            ncfr = iobackend.NCFile(self.ncfwname)
            actual = ncfr.variables[variable].fill_value
            ncfr.close()
            remove(self.ncfwname)
            return actual
        for v in self.ncvars:
            expected = None if v == 's' else self.vfill[v]
            test_func_avail(test_name(), func, expected,
                            'NCFile variables incorrect', kwds={'variable': v})

    def test_NCFile_create_variable_chunksizes(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfwname, mode='w')
            for d in self.vdims[variable]:
                if d == 't':
                    ncf.create_dimension(d)
                else:
                    ncf.create_dimension(d, self.ncdims[d])
            ncf.create_variable(variable, self.vdtype[variable], self.vdims[variable],
                                chunksizes=self.chunks[variable])
            ncf.close()
            ncfr = iobackend.NCFile(self.ncfwname)
            actual = ncfr.variables[variable].chunk_sizes
            ncfr.close()
            remove(self.ncfwname)
            return actual
        iobackend.set_backend('netCDF4')
        npt.assert_equal(iobackend.get_backend(), 'netCDF4',
                         'Cannot set backend {}'.format(netCDF4))
        for v in self.ncvars:
            expected = self.chunks[v] if self.chunks[v] else 'contiguous'
            test_func(test_name(), func, expected,
                      msg='{}: {}'.format('netCDF4', 'NCFile variables incorrect'), kwds={'variable': v})

    def test_NCVariable_setncattr(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfwname, mode='w')
            for d in self.vdims[variable]:
                if d == 't':
                    ncf.create_dimension(d)
                else:
                    ncf.create_dimension(d, self.ncdims[d])
            vobj = ncf.create_variable(
                variable, self.vdtype[variable], self.vdims[variable])
            for attr in self.vattrs[variable]:
                vobj.setncattr(attr, self.vattrs[variable][attr])
            ncf.close()
            ncfr = iobackend.NCFile(self.ncfwname)
            actual = {a: ncfr.variables[variable].getncattr(
                a) for a in ncfr.variables[variable].ncattrs}
            ncfr.close()
            remove(self.ncfwname)
            return actual
        for v in self.vattrs:
            expected = self.vattrs[v]
            test_func_avail(test_name(), func, expected,
                            'NCFile variables incorrect', kwds={'variable': v})

    def test_NCVariable_setitem_getitem(self):
        def func(variable=''):
            ncf = iobackend.NCFile(self.ncfwname, mode='w')
            for d in self.vdims[variable]:
                if d == 't':
                    ncf.create_dimension(d)
                else:
                    ncf.create_dimension(d, self.ncdims[d])
            vobj = ncf.create_variable(
                variable, self.vdtype[variable], self.vdims[variable])
            vobj[:] = self.ncvars[variable]
            ncf.close()
            ncfr = iobackend.NCFile(self.ncfwname)
            actual = ncfr.variables[variable][:]
            ncfr.close()
            remove(self.ncfwname)
            return actual
        for v in self.ncvars:
            expected = self.ncvars[v]
            test_func_avail(test_name(), func, expected,
                            'NCFile variables incorrect', kwds={'variable': v})


#=========================================================================
# AppendTests
#=========================================================================
class AppendTests(unittest.TestCase):

    """
    AppendTests Class

    This class defines all of the unit tests for the iobackend module.
    """

    def setUp(self):
        self.ncfaname = 'appendtest.nc'
        self.ncattrs = {'a1': 'attribute 1', 'a2': 'attribute 2'}
        self.ncdims = {'t': 10, 'x': 5}
        self.t = np.arange(self.ncdims['t'], dtype='d')
        self.x = np.arange(self.ncdims['x'], dtype='d')
        self.v = np.arange(self.ncdims['t'] * self.ncdims['x'],
                           dtype='f').reshape(self.ncdims['t'], self.ncdims['x'])
        self.vattrs = {'long_name': 'variable', 'units': 'meters'}
        self.fattrs2 = {'a3': 'attribute 3', 'a4': 'attribute 4'}
        self.t2 = np.arange(self.ncdims['t'], 2 * self.ncdims['t'], dtype='d')
        self.v2 = np.arange(self.ncdims['t'] * self.ncdims['x'],
                            dtype='f').reshape(self.ncdims['t'], self.ncdims['x'])
        self.vattrs2 = {'standard_name': 'variable'}

        ncfile = netCDF4.Dataset(self.ncfaname, 'w')
        for a, v in self.ncattrs.iteritems():
            setattr(ncfile, a, v)
        ncfile.createDimension('t')
        ncfile.createDimension('x', self.ncdims['x'])
        t = ncfile.createVariable('t', 'd', ('t',))
        t[:] = self.t
        x = ncfile.createVariable('x', 'd', ('x',))
        x[:] = self.x
        v = ncfile.createVariable('v', 'f', ('t', 'x'))
        for a, val in self.vattrs.iteritems():
            v.setncattr(a, val)
        v[:, :] = self.v

        ncfile.close()

    def tearDown(self):
        if exists(self.ncfaname):
            remove(self.ncfaname)

    def test_nio_NCFile_init_append(self):
        iobackend.set_backend('Nio')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        actual = type(ncf)
        ncf.close()
        expected = iobackend.NCFile
        print_test_msg('NCFile.__init__()', actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'NCFile not created with correct type')

    def test_nc4_NCFile_init_append(self):
        iobackend.set_backend('netCDF4')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        actual = type(ncf)
        ncf.close()
        expected = iobackend.NCFile
        print_test_msg('NCFile.__init__()', actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'NCFile not created with correct type')

    def test_nio_NCFile_setncattr(self):
        iobackend.set_backend('Nio')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        for a, v in self.fattrs2.iteritems():
            ncf.setncattr(a, v)
        ncf.close()
        ncfr = Nio.open_file(self.ncfaname)
        actual = ncfr.attributes
        expected = self.ncattrs
        expected.update(self.fattrs2)
        ncfr.close()
        print_test_msg('NCFile.setncattr()', actual=actual, expected=expected)
        for a, v in expected.iteritems():
            self.assertTrue(
                a in actual, 'NCFile attribute {0!r} not found'.format(a))
            self.assertEqual(
                actual[a], v, 'NCFile attribute {0!r} incorrect'.format(a))

    def test_nc4_NCFile_setncattr(self):
        iobackend.set_backend('netCDF4')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        for a, v in self.fattrs2.iteritems():
            ncf.setncattr(a, v)
        ncf.close()
        ncfr = Nio.open_file(self.ncfaname)
        actual = ncfr.attributes
        expected = self.ncattrs
        expected.update(self.fattrs2)
        ncfr.close()
        print_test_msg('NCFile.setncattr()', actual=actual, expected=expected)
        for a, v in expected.iteritems():
            self.assertTrue(
                a in actual, 'NCFile attribute {0!r} not found'.format(a))
            self.assertEqual(
                actual[a], v, 'NCFile attribute {0!r} incorrect'.format(a))

    def test_nio_NCFile_create_variable_ndim(self):
        iobackend.set_backend('Nio')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        v2 = ncf.create_variable('v2', np.dtype('f'), ('t', 'x'))
        v2[:] = self.v2
        ncf.close()
        ncfr = Nio.open_file(self.ncfaname)
        actual = ncfr.variables['v2'][:]
        expected = self.v2
        ncfr.close()
        print_test_msg('NCFile.create_variable()',
                       actual=actual, expected=expected)
        npt.assert_array_equal(
            actual, expected, 'NCFile 2d-variable incorrect')

    def test_nc4_NCFile_create_variable_ndim(self):
        iobackend.set_backend('netCDF4')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        v2 = ncf.create_variable('v2', np.dtype('f'), ('t', 'x'))
        v2[:] = self.v2
        ncf.close()
        ncfr = Nio.open_file(self.ncfaname)
        actual = ncfr.variables['v2'][:]
        expected = self.v2
        ncfr.close()
        print_test_msg('NCFile.create_variable()',
                       actual=actual, expected=expected)
        npt.assert_array_equal(
            actual, expected, 'NCFile 2d-variable incorrect')

    def test_nio_NCFile_variable_append(self):
        iobackend.set_backend('Nio')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        nt = self.ncdims['t']
        t = ncf.variables['t']
        t[nt:] = self.t2
        v = ncf.variables['v']
        v[nt:, :] = self.v2
        ncf.close()
        ncfr = Nio.open_file(self.ncfaname)
        actual = ncfr.variables['t'][:]
        expected = np.concatenate((self.t, self.t2))
        print_test_msg('NCVariable append', actual=actual, expected=expected)
        npt.assert_array_equal(actual, expected, 'NCFile t-variable incorrect')
        actual = ncfr.variables['v'][:]
        expected = np.concatenate((self.v, self.v2))
        print_test_msg('NCVariable append', actual=actual, expected=expected)
        npt.assert_array_equal(
            actual, expected, 'NCFile 2d-variable incorrect')
        ncfr.close()

    def test_nc4_NCFile_variable_append(self):
        iobackend.set_backend('netCDF4')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        nt = self.ncdims['t']
        t = ncf.variables['t']
        t[nt:] = self.t2
        v = ncf.variables['v']
        v[nt:, :] = self.v2
        ncf.close()
        ncfr = Nio.open_file(self.ncfaname)
        actual = ncfr.variables['t'][:]
        expected = np.concatenate((self.t, self.t2))
        print_test_msg('NCVariable append', actual=actual, expected=expected)
        npt.assert_array_equal(actual, expected, 'NCFile t-variable incorrect')
        actual = ncfr.variables['v'][:]
        expected = np.concatenate((self.v, self.v2))
        print_test_msg('NCVariable append', actual=actual, expected=expected)
        npt.assert_array_equal(
            actual, expected, 'NCFile 2d-variable incorrect')
        ncfr.close()

    def test_nio_NCVariable_setncattr(self):
        iobackend.set_backend('Nio')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        v = ncf.variables['v']
        for attr, value in self.vattrs2.iteritems():
            v.setncattr(attr, value)
        ncf.close()
        ncfr = Nio.open_file(self.ncfaname)
        actual = ncfr.variables['v'].attributes
        expected = self.vattrs
        expected.update(self.vattrs2)
        ncfr.close()
        print_test_msg('NCVariable.setncattr()',
                       actual=actual, expected=expected)
        for attr, value in expected.iteritems():
            self.assertTrue(
                attr in actual, 'Variable attribute {0!r} not found'.format(attr))
            self.assertEqual(
                actual[attr], value, 'Variable attribute {0!r} incorrect'.format(attr))

    def test_nc4_NCVariable_setncattr(self):
        iobackend.set_backend('netCDF4')
        ncf = iobackend.NCFile(self.ncfaname, mode='a')
        v = ncf.variables['v']
        for attr, value in self.vattrs2.iteritems():
            v.setncattr(attr, value)
        ncf.close()
        ncfr = Nio.open_file(self.ncfaname)
        actual = ncfr.variables['v'].attributes
        expected = self.vattrs
        expected.update(self.vattrs2)
        ncfr.close()
        print_test_msg('NCVariable.setncattr()',
                       actual=actual, expected=expected)
        for attr, value in expected.iteritems():
            self.assertTrue(
                attr in actual, 'Variable attribute {0!r} not found'.format(attr))
            self.assertEqual(
                actual[attr], value, 'Variable attribute {0!r} incorrect'.format(attr))


#=========================================================================
# CLI
#=========================================================================
if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
