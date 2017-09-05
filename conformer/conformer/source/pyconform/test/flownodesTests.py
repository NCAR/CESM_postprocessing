"""
FlowNode Unit Tests

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from pyconform.flownodes import FlowNode, DataNode, ReadNode, EvalNode, MapNode, ValidateNode, WriteNode
from pyconform.physarray import PhysArray, DimensionsError, UnitsError
from pyconform.datasets import DimensionDesc, VariableDesc, FileDesc
from pyconform.functions import Function, find_operator
from testutils import print_test_message, print_ncfile
from cf_units import Unit
from os.path import exists
from os import remove
from glob import glob
from collections import OrderedDict

import unittest
import numpy
import netCDF4


#=======================================================================================================================
# FlowNodeTests
#=======================================================================================================================
class FlowNodeTests(unittest.TestCase):
    """
    Unit tests for the flownodes.FlowNode class
    """

    def test_init(self):
        indata = 0
        testname = 'FlowNode.__init__({})'.format(indata)
        N = FlowNode(0)
        actual = type(N)
        expected = FlowNode
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertIsInstance(N, expected, '{} failed'.format(testname))

    def test_label_int(self):
        indata = 0
        testname = 'FlowNode({}).label'.format(indata)
        N = FlowNode(indata)
        actual = N.label
        expected = indata
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_label_str(self):
        indata = 'abcd'
        testname = 'FlowNode({}).label'.format(indata)
        N = FlowNode(indata)
        actual = N.label
        expected = indata
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_inputs(self):
        indata = ['a', 0, 1, 2, 3]
        testname = 'FlowNode{}.inputs'.format(indata)
        N = FlowNode(*indata)
        actual = N.inputs
        expected = indata[1:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))


#=======================================================================================================================
# DataNodeTests
#=======================================================================================================================
class DataNodeTests(unittest.TestCase):
    """
    Unit tests for the flownodes.DataNode class
    """

    def test_getitem_all(self):
        indata = PhysArray(numpy.arange(10), units='m', dimensions=('x',))
        testname = 'DataNode.__getitem__(:)'
        N = DataNode(indata)
        actual = N[:]
        expected = indata
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_slice(self):
        indata = PhysArray(numpy.arange(10), units='m', dimensions=('x',))
        testname = 'DataNode.__getitem__(:5)'
        N = DataNode(indata)
        actual = N[:5]
        expected = PhysArray(indata[:5], units='m', dimensions=('x',))
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_dict(self):
        indata = PhysArray(numpy.arange(10), name=0, units='m', dimensions=('x',))
        indict = {'a': 4, 'x': slice(1, 5, 2)}
        testname = 'DataNode.__getitem__({})'.format(indict)
        N = DataNode(indata)
        actual = N[indict]
        expected = PhysArray(indata[indict['x']], units='m', dimensions=('x',))
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))


#=======================================================================================================================
# ReadNodeTests
#=======================================================================================================================
class ReadNodeTests(unittest.TestCase):
    """
    Unit tests for the flownodes.ReadNode class
    """

    def setUp(self):
        self.filename = 'test.nc'
        self.varname = 'v'
        self.dimensions = ('x', 'y')
        self.shape = {'x': 5, 'y': 10}
        self.vardata = {'x': PhysArray(numpy.arange(self.shape['x'], dtype='f'),
                                       units='m', dimensions=('x',), name='x'),
                        'y': PhysArray(numpy.arange(self.shape['y'], dtype='f'),
                                       units='km', dimensions=('y',), name='x'),
                        'v': PhysArray(numpy.arange(self.shape['x'] * self.shape['y'],
                                                    dtype='d').reshape(self.shape['x'],
                                                                       self.shape['y']),
                                       units='K', dimensions=self.dimensions, name='v')}

        dimdescs = {d:DimensionDesc(d, s) for d, s in self.shape.iteritems()}
        vardescs = {vn:VariableDesc(vn, datatype=vd.dtype, attributes={'units': str(vd.units)},
                                    dimensions=[dimdescs[dd] for dd in vd.dimensions])
                    for vn, vd in self.vardata.iteritems()}
        self.filedesc = FileDesc(self.filename, variables=vardescs.values())
        self.vardesc = self.filedesc.variables[self.varname]

        with netCDF4.Dataset(self.filename, 'w') as ncfile:
            for d in self.dimensions:
                ncfile.createDimension(d, self.shape[d])

            for v in self.vardata:
                ncv = ncfile.createVariable(v, 'f', self.vardata[v].dimensions)
                ncv.setncatts({'units': str(self.vardata[v].units)})
                ncv[:] = self.vardata[v]

    def tearDown(self):
        if exists(self.filename):
            remove(self.filename)

    def test_getitem_all(self):
        testname = 'ReadNode.__getitem__(:)'
        N = ReadNode(self.vardesc)
        actual = N[:]
        expected = self.vardata[self.varname]
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_slice(self):
        testname = 'ReadNode.__getitem__(:2)'
        N = ReadNode(self.vardesc)
        actual = N[:2]
        expected = self.vardata[self.varname][:2]
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_none(self):
        testname = 'ReadNode.__getitem__(None)'
        N = ReadNode(self.vardesc)
        actual = N[None]
        expected = PhysArray(numpy.zeros((0,) * len(self.shape), dtype='d'),
                                       units=self.vardata[self.varname].units,
                                       dimensions=self.vardata[self.varname].dimensions)
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_tuple(self):
        intuple = (3, slice(2, 4))
        testname = 'ReadNode.__getitem__({})'.format(intuple)
        N = ReadNode(self.vardesc)
        actual = N[intuple]
        expected = PhysArray(self.vardata[self.varname][intuple], dimensions=('y',))
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_dict(self):
        indict = {'a': 4, 'x': slice(1, 5, 2)}
        testname = 'ReadNode.__getitem__({})'.format(indict)
        N = ReadNode(self.vardesc)
        actual = N[indict]
        expected = self.vardata[self.varname][slice(1, 5, 2)]
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_dict_2(self):
        indict = {'a': 4, 'y': slice(1, 5, 2)}
        testname = 'ReadNode.__getitem__({})'.format(indict)
        N = ReadNode(self.vardesc)
        actual = N[indict]
        expected = self.vardata[self.varname][:, slice(1, 5, 2)]
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))


#=======================================================================================================================
# EvalNodeTests
#=======================================================================================================================
class EvalNodeTests(unittest.TestCase):
    """
    Unit tests for the flownodes.EvalNode class
    """

    def test_getitem_all(self):
        indata = PhysArray(range(10), units='m', dimensions=('x',))
        testname = 'EvalNode.__getitem__(:)'
        N = EvalNode(0, lambda x: x, indata)
        actual = N[:]
        expected = indata
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_none(self):
        indata = PhysArray(range(10), units='m', dimensions=('x',))
        testname = 'EvalNode.__getitem__(None)'
        N = EvalNode(0, lambda x: x, indata)
        actual = N[None]
        expected = PhysArray(numpy.zeros((0,), dtype=indata.dtype),
                                       units='m', dimensions=('x',))
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_slice(self):
        indata = PhysArray(range(10), units='m', dimensions=('x',))
        testname = 'EvalNode.__getitem__(:5)'
        N = EvalNode(0, lambda x: x, indata)
        actual = N[:5]
        expected = indata[:5]
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_dict(self):
        indata = PhysArray(range(10), units='m', dimensions=('x',))
        testname = "EvalNode.__getitem__({'x': slice(5, None), 'y': 6})"
        N = EvalNode(0, lambda x: x, indata)
        actual = N[{'x': slice(5, None), 'y': 6}]
        expected = indata[slice(5, None)]
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_add(self):
        d1 = PhysArray(numpy.arange(1, 5), name='X1', units='m', dimensions=('x',))
        d2 = PhysArray(numpy.arange(5, 9), name='X2', units='m', dimensions=('x',))
        N1 = DataNode(d1)
        N2 = DataNode(d2)
        N3 = EvalNode(3, find_operator('+', numargs=2), N1, N2)
        testname = 'EvalNode.__getitem__(:)'
        actual = N3[:]
        expected = d1 + d2
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_add_slice(self):
        d1 = PhysArray(numpy.arange(1, 5), name='X1', units='m', dimensions=('x',))
        d2 = PhysArray(numpy.arange(5, 9), name='X2', units='m', dimensions=('x',))
        N1 = DataNode(d1)
        N2 = DataNode(d2)
        N3 = EvalNode(3, find_operator('+', numargs=2), N1, N2)
        testname = 'EvalNode.__getitem__(:2)'
        actual = N3[:2]
        expected = d1[:2] + d2[:2]
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_add_none(self):
        d1 = PhysArray(numpy.arange(1, 5), name='X1', units='m', dimensions=('x',))
        d2 = PhysArray(numpy.arange(5, 9), name='X2', units='m', dimensions=('x',))
        N1 = DataNode(d1)
        N2 = DataNode(d2)
        N3 = EvalNode(3, find_operator('+', numargs=2), N1, N2)
        testname = 'EvalNode.__getitem__(None)'
        actual = N3[None]
        expected = PhysArray([], units='m', dimensions=('x',))
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_sumlike_dimensions(self):
        class myfunc(Function):
            key = 'myfunc'
            def __init__(self, d, *dims):
                super(myfunc, self).__init__(d, *dims)
                self.add_sumlike_dimensions(*dims)
            def __getitem__(self, _):
                return self.arguments[0]
        d = PhysArray(numpy.arange(1, 5), name='d', units='m', dimensions=('x',))
        N = EvalNode(1, myfunc, d, 'x')
        testname = 'EvalNode.sumlike_dimensions'
        actual = N.sumlike_dimensions
        expected = set(['x'])
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        N[0:2]
        actual = N.sumlike_dimensions
        expected = set(['x'])
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
                        

#=======================================================================================================================
# MapNodeTests
#=======================================================================================================================
class MapNodeTests(unittest.TestCase):
    """
    Unit tests for the flownodes.MapNode class
    """

    def setUp(self):
        array = PhysArray(numpy.arange(10), name=0, units='km', dimensions=('x',))
        self.indata = DataNode(array)

    def test_getitem_all(self):
        testname = 'MapNode.__getitem__(:)'
        N = MapNode(0, self.indata, dmap={'x': 'y'})
        actual = N[:]
        expected = PhysArray(self.indata[:], dimensions=('y',))
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_slice(self):
        testname = 'MapNode.__getitem__(:3)'
        N = MapNode(0, self.indata, dmap={'x': 'y'})
        actual = N[:3]
        expected = PhysArray(self.indata[:3], dimensions=('y',))
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_none(self):
        testname = 'MapNode.__getitem__(None)'
        N = MapNode(0, self.indata, dmap={'x': 'y'})
        actual = N[None]
        expected = PhysArray(numpy.arange(0), units='km', dimensions=('y',))
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_getitem_slice_no_dmap(self):
        testname = 'MapNode(dmap={}, dimensions=indims).__getitem__(:3)'
        N = MapNode(0, self.indata)
        actual = N[:3]
        expected = PhysArray(self.indata[:3], dimensions=('x',))
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))


#=======================================================================================================================
# ValidateNodeTests
#=======================================================================================================================
class ValidateNodeTests(unittest.TestCase):
    """
    Unit tests for the flownodes.ValidateNode class
    """

    def test_nothing(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='m', dimensions=('x',)))
        testname = 'OK: ValidateNode().__getitem__(:)'
        N1 = ValidateNode('validate(x)', N0)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_units_ok(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='m', dimensions=('x',)))
        indata = {'units': 'm'}
        testname = ('OK: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_time_units_ok(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='days since 2000-01-01 00:00:00',
                                dimensions=('x',)))
        indata = {'units': 'days since 2000-01-01 00:00:00', 'calendar': 'gregorian'}
        testname = ('OK: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_dimensions_ok(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='m', dimensions=('x',)))
        indata = {'dimensions': ('x',)}
        testname = ('OK: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, **indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_min_ok(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='m', dimensions=('x',)))
        indata = {'valid_min': 0}
        testname = ('OK: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_max_ok(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='m', dimensions=('x',)))
        indata = {'valid_max': 10}
        testname = ('OK: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_minmax_getitem_none(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='m', dimensions=('x',)))
        indata = {'valid_min': 0, 'valid_max': 2}
        testname = ('OK: ValidateNode({}).__getitem__(None)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[None]
        expected = N0[None]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_min_mean_abs_ok(self):
        N0 = DataNode(PhysArray(numpy.arange(-5, 10), name='x', units='m', dimensions=('x',)))
        indata = {'ok_min_mean_abs': 3}
        testname = ('OK: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_max_mean_abs_ok(self):
        N0 = DataNode(PhysArray(numpy.arange(-5, 10), name='x', units='m', dimensions=('x',)))
        indata = {'ok_max_mean_abs': 5}
        testname = ('OK: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_units_convert(self):
        N0 = DataNode(PhysArray(numpy.arange(10.0), name='x', units='m', dimensions=('x',)))
        indata = {'units': 'km'}
        testname = ('CONVERT: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = (Unit('m').convert(N0[:], Unit('km'))).astype(numpy.float64)
        expected.name = 'convert(x, from=m, to=km)'
        expected.units = Unit('km')
        expected.mask = False
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_dimensions_transpose(self):
        N0 = DataNode(PhysArray([[1.,2.],[3.,4.]], name='a', units='m', dimensions=('x', 'y')))
        indata = {'dimensions': ('y', 'x')}
        testname = ('TRANSPOSE: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(a)', N0, **indata)
        actual = N1[:].dimensions
        expected = indata['dimensions']
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_time_units_convert(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='days since 2000-01-01 00:00:00',
                                dimensions=('x',)))
        indata = {'units': 'hours since 2000-01-01 00:00:00', 'calendar': 'gregorian'}
        testname = ('WARN: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:].convert(Unit('hours since 2000-01-01 00:00:00'))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_time_units_convert_nocal(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', dimensions=('x',), 
                                units=Unit('days since 2000-01-01 00:00:00', calendar='noleap')))
        indata = {'units': 'hours since 2000-01-01 00:00:00'}
        testname = ('WARN: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:].convert(Unit('hours since 2000-01-01 00:00:00', calendar='noleap'))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))
        
    def test_time_units_error_calendar(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='days since 2000-01-01 00:00:00', dimensions=('x',)))
        indata = {'units': 'days since 2000-01-01 00:00:00', 'calendar': 'noleap'}
        testname = ('WARN: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        print_test_message(testname, indata=indata, expected=UnitsError)
        self.assertRaises(UnitsError, N1.__getitem__, slice(None))

    def test_dimensions_error(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='m', dimensions=('x',)))
        indata = {'dimensions': ('y',)}
        testname = ('WARN: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        expected = DimensionsError
        print_test_message(testname, indata=indata, expected=expected)
        self.assertRaises(expected, ValidateNode, 'validate(x)', N0, **indata)

    def test_min_warn(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='m', dimensions=('x',)))
        indata = {'valid_min': 2}
        testname = ('WARN: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_max_warn(self):
        N0 = DataNode(PhysArray(numpy.arange(10), name='x', units='m', dimensions=('x',)))
        indata = {'valid_max': 8}
        testname = ('WARN: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_min_mean_abs_warn(self):
        N0 = DataNode(PhysArray(numpy.arange(-5, 10), name='x', units='m', dimensions=('x',)))
        indata = {'ok_min_mean_abs': 5}
        testname = ('WARN: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))

    def test_max_mean_abs_warn(self):
        N0 = DataNode(PhysArray(numpy.arange(-5, 10), name='x', units='m', dimensions=('x',)))
        indata = {'ok_max_mean_abs': 3}
        testname = ('WARN: ValidateNode({}).__getitem__(:)'
                    '').format(', '.join('{!s}={!r}'.format(k, v) for k, v in indata.iteritems()))
        N1 = ValidateNode('validate(x)', N0, attributes=indata)
        actual = N1[:]
        expected = N0[:]
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        numpy.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed'.format(testname))
        self.assertEqual(actual.dimensions, expected.dimensions, '{} failed'.format(testname))


#=======================================================================================================================
# WriteNodeTests
#=======================================================================================================================
class WriteNodeTests(unittest.TestCase):
    """
    Unit tests for the flownodes.WriteNode class
    """

    def setUp(self):
        NX = 15
        X0 = -5
        xdata = PhysArray(numpy.arange(X0, X0+NX, dtype='f'),
                          name='X', units='m', dimensions=('x',))
        
        NY = 8
        Y0 = 0
        ydata = PhysArray(numpy.arange(Y0, Y0+NY, dtype='f'),
                          name='Y', units='m', dimensions=('y',))
        
        vdata = PhysArray(numpy.arange(0, NX*NY, dtype='d').reshape(NX,NY),
                          name='V', units='K', dimensions=('x', 'y'))

        self.data = {'X': xdata, 'Y': ydata, 'V': vdata}
        self.atts = {'X': {'xa1': 'x attribute 1', 'xa2': 'x attribute 2', 'axis': 'X'},
                     'Y': {'ya1': 'y attribute 1', 'ya2': 'y attribute 2', 'axis': 'Y', 
                           'direction': 'decreasing'},
                     'V': {'va1': 'v attribute 1', 'va2': 'v attribute 2'}}
        self.nodes = {n:ValidateNode(n, DataNode(self.data[n]), attributes=self.atts[n])
                      for n in self.data}

        dimdescs = {n:DimensionDesc(n, s) for x in self.data.itervalues()
                    for n, s in zip(x.dimensions, x.shape)}
        vardescs = {n:VariableDesc(n, datatype=self.data[n].dtype, attributes=self.atts[n],
                                   dimensions=[dimdescs[d] for d in self.data[n].dimensions])
                    for n in self.data}
        self.vardescs = vardescs

    def tearDown(self):
        for fname in glob('*.nc'):
            remove(fname)
    
    def test_init(self):
        filename = 'test.nc'
        testname = 'WriteNode.__init__({})'.format(filename)
        filedesc = FileDesc(filename, variables=self.vardescs.values())
        N = WriteNode(filedesc, inputs=self.nodes.values())
        actual = type(N)
        expected = WriteNode
        print_test_message(testname, actual=actual, expected=expected)
        self.assertIsInstance(N, expected, '{} failed'.format(testname))

    def test_chunk_iter_default(self):
        dsizes = OrderedDict([('x', 2), ('y', 3)])
        testname = 'WriteNode._chunk_iter_({})'.format(dsizes)
        actual = [chunk for chunk in WriteNode._chunk_iter_(dsizes)]
        expected = [OrderedDict([('x', slice(0, None, None)), ('y', slice(0, None, None))])]
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_chunk_iter_1D(self):
        dsizes = OrderedDict([('x', 4), ('y', 5)])
        chunks = {'x': 2}
        testname = 'WriteNode._chunk_iter_({}, chunks={})'.format(dsizes, chunks)
        actual = [chunk for chunk in WriteNode._chunk_iter_(dsizes, chunks=chunks)]
        expected = [OrderedDict([('x', slice(0, 2)), ('y', slice(0, None))]),
                    OrderedDict([('x', slice(2, None)), ('y', slice(0, None))])]
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_chunk_iter_1D_unnamed(self):
        dsizes = OrderedDict([('x', 4), ('y', 5)])
        chunks = {'z': 2}
        testname = 'WriteNode._chunk_iter_({}, chunks={})'.format(dsizes, chunks)
        actual = [chunk for chunk in WriteNode._chunk_iter_(dsizes, chunks=chunks)]
        expected = [OrderedDict([('x', slice(0, None, None)), ('y', slice(0, None, None))])]
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_chunk_iter_2D(self):
        dsizes = OrderedDict([('x', 4), ('y', 5)])
        chunks = {'x': 2, 'y': 3}
        testname = 'WriteNode._chunk_iter_({}, chunks={})'.format(dsizes, chunks)
        actual = [chunk for chunk in WriteNode._chunk_iter_(dsizes, chunks=chunks)]
        expected = [OrderedDict([('x', slice(0, 2, None)), ('y', slice(0, 3, None))]),
                    OrderedDict([('x', slice(0, 2, None)), ('y', slice(3, None, None))]),
                    OrderedDict([('x', slice(2, None, None)), ('y', slice(0, 3, None))]),
                    OrderedDict([('x', slice(2, None, None)), ('y', slice(3, None, None))])]
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_chunk_iter_2D_unnamed(self):
        dsizes = OrderedDict([('x', 4), ('y', 5)])
        chunks = {'x': 2, 'z': 3}
        testname = 'WriteNode._chunk_iter_({}, chunks={})'.format(dsizes, chunks)
        actual = [chunk for chunk in WriteNode._chunk_iter_(dsizes, chunks=chunks)]
        expected = [OrderedDict([('x', slice(0, 2, None)), ('y', slice(0, None, None))]),
                    OrderedDict([('x', slice(2, None, None)), ('y', slice(0, None, None))])]
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_chunk_iter_2D_reverse(self):
        dsizes = OrderedDict([('y', 5), ('x', 4)])
        chunks = {'x': 2, 'y': 3}
        testname = 'WriteNode._chunk_iter_({}, chunks={})'.format(dsizes, chunks)
        actual = [chunk for chunk in WriteNode._chunk_iter_(dsizes, chunks=chunks)]
        expected = [OrderedDict([('y', slice(0, 3, None)), ('x', slice(0, 2, None))]),
                    OrderedDict([('y', slice(3, None, None)), ('x', slice(0, 2, None))]),
                    OrderedDict([('y', slice(0, 3, None)), ('x', slice(2, None, None))]),
                    OrderedDict([('y', slice(3, None, None)), ('x', slice(2, None, None))])]
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_invert_dims(self):
        dsizes = OrderedDict([('x', 4), ('y', 5)])
        chunk = OrderedDict([('x', slice(0,2)), ('y', slice(1,3))])
        idims = {'y'}
        testname = 'WriteNode._invert_dims({}, {}, idims={})'.format(dsizes, chunk, idims)
        actual = WriteNode._invert_dims_(dsizes, chunk, idims=idims)
        expected = OrderedDict([('x', slice(0, 2, None)), ('y', slice(3, 1, -1))])
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_execute_simple_default(self):
        filename = 'v_x_y_simple.nc'
        testname = 'WriteNode({}).execute()'.format(filename)
        filedesc = FileDesc(filename, variables=self.vardescs.values(), attributes={'ga': 'global attribute'})
        N = WriteNode(filedesc, inputs=self.nodes.values())
        N.enable_history()
        N.execute()
        actual = exists(filename)
        expected = True
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        print_ncfile(filename)

    def test_execute_simple_nc3(self):
        filename = 'v_x_y_simple_nc3.nc'
        testname = 'WriteNode({}).execute()'.format(filename)
        filedesc = FileDesc(filename, format='NETCDF3_CLASSIC', variables=self.vardescs.values(),
                            attributes={'ga': 'global attribute'})
        N = WriteNode(filedesc, inputs=self.nodes.values())
        N.enable_history()
        N.execute()
        actual = exists(filename)
        expected = True
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        print_ncfile(filename)

    def test_execute_simple_nc4(self):
        filename = 'v_x_y_simple_nc4.nc'
        testname = 'WriteNode({}).execute()'.format(filename)
        filedesc = FileDesc(filename, format='NETCDF4', variables=self.vardescs.values(),
                            attributes={'ga': 'global attribute'})
        N = WriteNode(filedesc, inputs=self.nodes.values())
        N.enable_history()
        N.execute()
        actual = exists(filename)
        expected = True
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        print_ncfile(filename)

    def test_execute_chunk_1D(self):
        filename = 'v_x_y_chunk_1D.nc'
        chunks = {'x': 6}
        testname = 'WriteNode({}).execute(chunks={})'.format(filename, chunks)
        filedesc = FileDesc(filename, variables=self.vardescs.values(), attributes={'ga': 'global attribute'})
        N = WriteNode(filedesc, inputs=self.nodes.values())
        N.enable_history()
        N.execute(chunks=chunks)
        actual = exists(filename)
        expected = True
        print_test_message(testname, actual=actual, expected=expected, chunks=chunks)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        print_ncfile(filename)

    def test_execute_chunk_2D(self):
        filename = 'v_x_y_chunk_2D.nc'
        chunks = {'x': 6, 'y': 3}
        testname = 'WriteNode({}).execute(chunks={})'.format(filename, chunks)
        filedesc = FileDesc(filename, variables=self.vardescs.values(), attributes={'ga': 'global attribute'})
        N = WriteNode(filedesc, inputs=self.nodes.values())
        N.enable_history()
        N.execute(chunks=chunks)
        actual = exists(filename)
        expected = True
        print_test_message(testname, actual=actual, expected=expected, chunks=chunks)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        print_ncfile(filename)

    def test_execute_chunk_3D(self):
        filename = 'v_x_y_chunk_2D.nc'
        chunks = {'x': 6, 'y': 3, 'z': 7}
        testname = 'WriteNode({}).execute(chunks={})'.format(filename, chunks)
        filedesc = FileDesc(filename, variables=self.vardescs.values(), attributes={'ga': 'global attribute'})
        N = WriteNode(filedesc, inputs=self.nodes.values())
        N.enable_history()
        N.execute(chunks=chunks)
        actual = exists(filename)
        expected = True
        print_test_message(testname, actual=actual, expected=expected, chunks=chunks)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        print_ncfile(filename)


#===============================================================================
# Command-Line Operation
#===============================================================================
if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
