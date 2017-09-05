"""
DatasetDesc Unit Tests

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from os import remove
from os.path import exists
from pyconform.datasets import DimensionDesc, VariableDesc, FileDesc
from pyconform.datasets import DatasetDesc, InputDatasetDesc, OutputDatasetDesc
from collections import OrderedDict
from netCDF4 import Dataset as NCDataset
from cf_units import Unit
from testutils import print_test_message

import numpy as np
import unittest


#===============================================================================
# DimensionDescTests
#===============================================================================
class DimensionDescTests(unittest.TestCase):
    """
    Unit tests for DimensionDesc objects
    """

    def test_type(self):
        ddesc = DimensionDesc('x')
        actual = type(ddesc)
        expected = DimensionDesc
        print_test_message('type(DimensionDesc)', actual=str(actual), expected=str(expected))
        self.assertEqual(actual, expected, 'DimensionDesc has wrong type')

    def test_name(self):
        indata = 'x'
        ddesc = DimensionDesc(indata)
        actual = ddesc.name
        expected = indata
        print_test_message('DimensionDesc.name', indata=indata, actual=str(actual), expected=str(expected))
        self.assertEqual(actual, expected, 'DimensionDesc.name does not match')

    def test_size_default(self):
        ddesc = DimensionDesc('x')
        actual = ddesc.size
        expected = None
        print_test_message('DimensionDesc.size == None', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default DimensionDesc.size is not None')

    def test_size(self):
        indata = 1
        ddesc = DimensionDesc('x', size=indata)
        actual = ddesc.size
        expected = indata
        print_test_message('DimensionDesc.size', input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DimensionDesc.size is not set properly')

    def test_limited_default(self):
        ddesc = DimensionDesc('x', size=1)
        actual = ddesc.unlimited
        expected = False
        print_test_message('DimensionDesc.unlimited', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default DimensionDesc.unlimited is wrong')

    def test_limited(self):
        ddesc = DimensionDesc('x', size=1, unlimited=True)
        actual = ddesc.unlimited
        expected = True
        print_test_message('DimensionDesc.unlimited == True', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DimensionDesc.unlimited is not True')

    def test_is_set_false(self):
        ddesc = DimensionDesc('x')
        actual = ddesc.is_set()
        expected = False
        print_test_message('DimensionDesc.is_set == False', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DimensionDesc is set when it should not be')

    def test_is_set_true(self):
        ddesc = DimensionDesc('x', 1)
        actual = ddesc.is_set()
        expected = True
        print_test_message('DimensionDesc.is_set == True', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DimensionDesc is not set when it should be')

    def test_set(self):
        expected = DimensionDesc('x', 1)
        actual = DimensionDesc('y')
        actual.set(expected)
        print_test_message('DimensionDesc.set()', actual=str(actual), expected=str(expected))
        self.assertEqual(actual.name, 'y', 'DimensionDesc name not correct after set')
        self.assertEqual(actual.size, expected.size, 'DimensionDesc size not correct after set')

    def test_reset(self):
        expected = DimensionDesc('x', 1)
        actual = DimensionDesc('y', 2)
        actual.set(expected)
        print_test_message('DimensionDesc.set()', actual=str(actual), expected=str(expected))
        self.assertEqual(actual.name, 'y', 'DimensionDesc name not correct after set')
        self.assertEqual(actual.size, expected.size, 'DimensionDesc size not correct after set')
        
    def test_set_bad(self):
        indata = 'z'
        ddesc = DimensionDesc('y')
        print_test_message('DimensionDesc.set({})'.format(indata), indata=indata, desc=str(ddesc))
        self.assertRaises(TypeError, ddesc.set, indata)

    def test_unset(self):
        ddesc = DimensionDesc('x', 1, True)
        before = str(ddesc)
        self.assertTrue(ddesc.is_set(), 'DimensionDesc not initially set')
        ddesc.unset()
        after = str(ddesc)
        print_test_message('DimensionDesc.unset()', before=before, after=after)
        self.assertFalse(ddesc.is_set(), 'DimensionDesc not unset properly')

    def test_equals_same(self):
        ddesc1 = DimensionDesc('x', size=1, unlimited=True)
        ddesc2 = DimensionDesc('x', size=1, unlimited=True)
        actual = ddesc1
        expected = ddesc2
        print_test_message('DimensionDesc == DimensionDesc', actual=str(actual), expected=str(expected))
        self.assertEqual(actual, expected, 'Identical DimensionDesc objects not equal')

    def test_equals_diff_name(self):
        ddesc1 = DimensionDesc('a', size=1, unlimited=True)
        ddesc2 = DimensionDesc('b', size=1, unlimited=True)
        actual = ddesc1
        expected = ddesc2
        print_test_message('DimensionDesc(a) != DimensionDesc(b)', actual=str(actual), expected=str(expected))
        self.assertNotEqual(actual, expected, 'Differently named DimensionDesc objects equal')

    def test_equals_diff_size(self):
        ddesc1 = DimensionDesc('x', size=1, unlimited=True)
        ddesc2 = DimensionDesc('x', size=2, unlimited=True)
        actual = ddesc1
        expected = ddesc2
        print_test_message('DimensionDesc(1) != DimensionDesc(2)', actual=str(actual), expected=str(expected))
        self.assertNotEqual(actual, expected, 'Differently sized DimensionDesc objects equal')

    def test_equals_diff_ulim(self):
        ddesc1 = DimensionDesc('x', size=1, unlimited=False)
        ddesc2 = DimensionDesc('x', size=1, unlimited=True)
        actual = ddesc1
        expected = ddesc2
        print_test_message('DimensionDesc(1) != DimensionDesc(2)', actual=str(actual), expected=str(expected))
        self.assertNotEqual(actual, expected, 'Differently limited DimensionDesc objects equal')

    def test_equals_diff_1set(self):
        ddesc1 = DimensionDesc('x', 1, True)
        ddesc2 = DimensionDesc('x')
        actual = ddesc1
        expected = ddesc2
        print_test_message('DimensionDesc(1) == DimensionDesc(2)', actual=str(actual), expected=str(expected))
        self.assertNotEqual(actual, expected, 'Set DimensionsDesc equals unset DimensionDesc')

    def test_equals_same_unset(self):
        ddesc1 = DimensionDesc('x')
        ddesc2 = DimensionDesc('x')
        actual = ddesc1
        expected = ddesc2
        print_test_message('DimensionDesc(1) == DimensionDesc(2)', actual=str(actual), expected=str(expected))
        self.assertEqual(actual, expected, 'Unset DimensionsDesc not equal to unset DimensionDesc')

    def test_unique_empty(self):
        indata = []
        actual = DimensionDesc.unique(indata)
        expected = OrderedDict()
        print_test_message('DimensionDesc.unique([])', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DimensionDesc.unique fails with empty list')

    def test_unique_single(self):
        indata = [DimensionDesc('x', 1)]
        actual = DimensionDesc.unique(indata)
        expected = OrderedDict((d.name, d) for d in indata)
        print_test_message('DimensionDesc.unique([d1])', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DimensionDesc.unique fails with single-item list')

    def test_unique_all_unique(self):
        indata = [DimensionDesc('x', 1), DimensionDesc('y', 1)]
        actual = DimensionDesc.unique(indata)
        expected = OrderedDict((d.name, d) for d in indata)
        print_test_message('DimensionDesc.unique([d1, d2])', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DimensionDesc.unique fails with all-unqiue list')

    def test_unique_same_names_unset(self):
        indata = [DimensionDesc('x'), DimensionDesc('x')]
        actual = DimensionDesc.unique(indata)
        expected = OrderedDict([(indata[0].name, indata[0])])
        print_test_message('DimensionDesc.unique([d1, d1])', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DimensionDesc.unique fails with same names, all unset')

    def test_unique_same_names_1set(self):
        indata = [DimensionDesc('x'), DimensionDesc('x', 2)]
        actual = DimensionDesc.unique(indata)
        expected = OrderedDict([(indata[1].name, indata[1])])
        print_test_message('DimensionDesc.unique([d1, d1+])', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DimensionDesc.unique fails with same names, 1 set')

    def test_unique_same_names_2set_diff(self):
        indata = [DimensionDesc('x', 1), DimensionDesc('x', 2)]
        print_test_message('DimensionDesc.unique([d1a, d1b])', indata=indata)
        self.assertRaises(ValueError, DimensionDesc.unique, indata)


#===============================================================================
# VariableDescTests
#===============================================================================
class VariableDescTests(unittest.TestCase):
    """
    Unit tests for VariableDesc objects
    """

    def test_type(self):
        vdesc = VariableDesc('x')
        actual = type(vdesc)
        expected = VariableDesc
        print_test_message('type(VariableDesc)', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'VariableDesc has wrong type')

    def test_name(self):
        indata = 'x'
        vdesc = VariableDesc(indata)
        actual = vdesc.name
        expected = indata
        print_test_message('VariableDesc.name', indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'VariableDesc.name does not match')

    def test_datatype_default(self):
        vdesc = VariableDesc('x')
        actual = vdesc.datatype
        expected = 'float'
        print_test_message('VariableDesc.datatype == float', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.datatype is not float')

    def test_dimensions_default(self):
        vdesc = VariableDesc('x')
        actual = vdesc.dimensions
        expected = OrderedDict()
        print_test_message('VariableDesc.dimensions == ()', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.dimensions is not ()')

    def test_attributes_default(self):
        vdesc = VariableDesc('x')
        actual = vdesc.attributes
        expected = {}
        print_test_message('VariableDesc.attributes == ()', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.attributes is not OrderedDict()')

    def test_definition_default(self):
        vdesc = VariableDesc('x')
        actual = vdesc.definition
        expected = None
        print_test_message('VariableDesc.definition == ()', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.definition is not None')

    def test_datatype(self):
        vdesc = VariableDesc('x', datatype='float')
        actual = vdesc.datatype
        expected = 'float'
        print_test_message('VariableDesc.datatype == float64', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.datatype is not float64')

    def test_dimensions(self):
        indata = (DimensionDesc('y'), DimensionDesc('z'))
        vdesc = VariableDesc('x', dimensions=indata)
        actual = vdesc.dimensions
        expected = OrderedDict((d.name, d) for d in indata)
        print_test_message('VariableDesc.dimensions == ()', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Default VariableDesc.dimensions is not {}'.format(indata))

    def test_attributes(self):
        indata = OrderedDict([('a1', 'attrib1'), ('a2', 'attrib2')])
        vdesc = VariableDesc('x', attributes=indata)
        actual = vdesc.attributes
        expected = indata
        print_test_message('VariableDesc.attributes', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Default VariableDesc.attributes is not {}'.format(indata))

    def test_definition(self):
        indata = 'y + z'
        vdesc = VariableDesc('x', definition=indata)
        actual = vdesc.definition
        expected = indata
        print_test_message('VariableDesc.definition', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Default VariableDesc.definition is not {!r}'.format(indata))

    def test_data(self):
        indata = (1, 2, 3, 4, 5, 6)
        vdesc = VariableDesc('x', definition=indata)
        actual = vdesc.definition
        expected = indata
        print_test_message('VariableDesc.definition', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Default VariableDesc.definition is not {!r}'.format(indata))

    def test_equals_same(self):
        kwargs = {'datatype': 'double',
                  'dimensions': tuple(DimensionDesc(d) for d in ('a', 'b')),
                  'attributes': {'a1': 'at1', 'a2': 'at2'},
                  'definition': 'y + z'}
        actual = VariableDesc('x', **kwargs)
        expected = VariableDesc('x', **kwargs)
        print_test_message('VariableDesc == VariableDesc',
                           actual=str(actual), expected=str(expected))
        self.assertEqual(actual, expected, 'Identical VariableDesc objects not equal')

    def test_equals_diff_name(self):
        kwargs = {'datatype': 'double',
                  'dimensions': tuple(DimensionDesc(d) for d in ('a', 'b')),
                  'attributes': {'a1': 'at1', 'a2': 'at2'},
                  'definition': 'y + z'}
        actual = VariableDesc('a', **kwargs)
        expected = VariableDesc('b', **kwargs)
        print_test_message('VariableDesc(a) != VariableDesc(b)',
                           actual=str(actual), expected=str(expected))
        self.assertNotEqual(actual, expected, 'Differently named VariableDesc objects equal')

    def test_equals_diff_dtype(self):
        actual = VariableDesc('x', datatype='double')
        expected = VariableDesc('x', datatype='float')
        print_test_message('VariableDesc(d) != VariableDesc(f)',
                           actual=str(actual), expected=str(expected))
        self.assertNotEqual(actual, expected, 'Differently typed VariableDesc objects equal')

    def test_equals_diff_dims(self):
        vdims1 = tuple(DimensionDesc(d) for d in ('a', 'b'))
        vdims2 = tuple(DimensionDesc(d) for d in ('a', 'b', 'c'))
        actual = VariableDesc('x', dimensions=vdims1)
        expected = VariableDesc('x', dimensions=vdims2)
        print_test_message('VariableDesc(dims1) != VariableDesc(dims2)',
                           actual=str(actual), expected=str(expected))
        self.assertNotEqual(actual, expected, 'Differently dimensioned VariableDesc objects equal')

    def test_units_default(self):
        vdesc = VariableDesc('x')
        actual = vdesc.units()
        expected = Unit('no unit')
        print_test_message('VariableDesc.units() == nounit', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.units() not None')

    def test_units(self):
        indata = 'm'
        vdesc = VariableDesc('x', attributes={'units': indata})
        actual = vdesc.units()
        expected = indata
        print_test_message('VariableDesc.units()', indata=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.units() not {}'.format(indata))

    def test_calendar_default(self):
        vdesc = VariableDesc('x')
        actual = vdesc.calendar()
        expected = None
        print_test_message('VariableDesc.calendar()', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.calendar() not None')

    def test_calendar(self):
        indata = 'noleap'
        vdesc = VariableDesc('x', attributes={'units': 'days', 'calendar': indata})
        actual = vdesc.calendar()
        expected = indata
        print_test_message('VariableDesc.calendar()', indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'VariableDesc.calendar() not {}'.format(indata))

    def test_cfunits_default(self):
        vdesc = VariableDesc('time')
        actual = vdesc.cfunits()
        expected = Unit('no unit')
        print_test_message('VariableDesc.cfunits() == None', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.cfunits() not None')

    def test_cfunits(self):
        units = 'days'
        calendar = 'noleap'
        vdesc = VariableDesc('x', attributes={'units': units, 'calendar': calendar})
        actual = vdesc.cfunits()
        expected = Unit(units, calendar=calendar)
        print_test_message('VariableDesc.cfunits()', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Default VariableDesc.cfunits() not {}'.format(expected))

    def test_unique_empty(self):
        indata = []
        actual = VariableDesc.unique(indata)
        expected = OrderedDict()
        print_test_message('VariableDesc.unique()', input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'VariableDesc.unique failes with empty list')

    def test_unique_single(self):
        indata = [VariableDesc('x')]
        actual = VariableDesc.unique(indata)
        expected = OrderedDict((d.name, d) for d in indata)
        print_test_message('VariableDesc.unique()', input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'VariableDesc.unique failes with single-item list')

    def test_unique_same_names(self):
        indata = [VariableDesc('x'), VariableDesc('x')]
        actual = VariableDesc.unique(indata)
        expected = OrderedDict([(indata[0].name, indata[0])])
        print_test_message('VariableDesc.unique()', input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'VariableDesc.unique failes with all-same list')

    def test_unique_diff_names(self):
        indata = [VariableDesc('x'), VariableDesc('y')]
        actual = VariableDesc.unique(indata)
        expected = OrderedDict((d.name, d) for d in indata)
        print_test_message('VariableDesc.unique()', input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'VariableDesc.unique failes with all-same list')

    def test_unique_same_names_same_dims(self):
        indata = [VariableDesc('x', dimensions=[DimensionDesc('x')]),
                  VariableDesc('x', dimensions=[DimensionDesc('x')])]
        actual = VariableDesc.unique(indata)
        expected = OrderedDict([(indata[0].name, indata[0])])
        print_test_message('VariableDesc.unique()', input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'VariableDesc.unique failes with all-same list')

    def test_unique_same_names_diff_dims(self):
        indata = [VariableDesc('x', dimensions=[DimensionDesc('x')]),
                  VariableDesc('x', dimensions=[DimensionDesc('y')])]
        expected = ValueError
        print_test_message('VariableDesc.unique()', input=indata, expected=expected)
        self.assertRaises(expected, VariableDesc.unique, indata)


#===================================================================================================
# FileDescTests
#===================================================================================================
class FileDescTests(unittest.TestCase):
    """
    Unit Tests for the pyconform.datasets module
    """

    def test_type(self):
        indata = 'test.nc'
        fdesc = FileDesc(indata)
        actual = type(fdesc)
        expected = FileDesc
        print_test_message('FileDesc.__init__({})'.format(indata),
                           input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'No FileDesc created')

    def test_name(self):
        indata = 'test.nc'
        fdesc = FileDesc(indata)
        actual = fdesc.name
        expected = indata
        print_test_message('FileDesc.name == {}'.format(indata),
                           input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.name failed')

    def test_exists_false(self):
        indata = 'test.nc'
        if exists(indata):
            remove(indata)
        fdesc = FileDesc(indata)
        actual = fdesc.exists()
        expected = False
        print_test_message('FileDesc.exists() == {}'.format(expected),
                           input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.exists() failed')

    def test_exists_true(self):
        indata = 'test.nc'
        if not exists(indata):
            open(indata, 'w').close()
        fdesc = FileDesc(indata)
        actual = fdesc.exists()
        expected = True
        print_test_message('FileDesc.exists() == {}'.format(expected),
                           input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.exists() failed')
        if exists(indata):
            remove(indata)

    def test_format_default(self):
        indata = 'test.nc'
        fdesc = FileDesc(indata)
        actual = fdesc.format
        expected = 'NETCDF4_CLASSIC'
        print_test_message('FileDesc.format == {}'.format(expected),
                           input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.format failed')

    def test_format_valid(self):
        indata = 'NETCDF4'
        fdesc = FileDesc('test.nc', format=indata)
        actual = fdesc.format
        expected = indata
        print_test_message('FileDesc.format == {}'.format(expected),
                           input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.format failed')

    def test_format_invalid(self):
        indata = 'STUFF'
        expected = TypeError
        print_test_message('FileDesc(format={})'.format(indata),
                           input=indata, expected=expected)
        self.assertRaises(expected, FileDesc, 'test.nc', format=indata)

    def test_attributes_default(self):
        fdesc = FileDesc('test.nc')
        actual = fdesc.attributes
        expected = {}
        print_test_message('FileDesc.attributes == {}'.format(expected),
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.attributes failed')

    def test_attributes_valid(self):
        indata = {'a': 'attribute 1', 'b': 'attribute 2'}
        fdesc = FileDesc('test.nc', attributes=indata)
        actual = fdesc.attributes
        expected = indata
        print_test_message('FileDesc.attributes == {}'.format(expected),
                           input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.attributes failed')

    def test_attributes_invalid(self):
        indata = [('a', 'attribute 1'), ('b', 'attribute 2')]
        expected = TypeError
        print_test_message('FileDesc.attributes == {}'.format(expected),
                           input=indata, expected=expected)
        self.assertRaises(expected, FileDesc, 'test.nc', attributes=indata)

    def test_variables_scalar(self):
        indata = [VariableDesc('a'), VariableDesc('b')]
        fdesc = FileDesc('test.nc', variables=indata)
        actual = fdesc.variables
        expected = OrderedDict((d.name, d) for d in indata)
        print_test_message('FileDesc.variables', input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.variables failed')
        actual = fdesc.dimensions
        expected = OrderedDict()
        print_test_message('FileDesc.dimensions', input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.dimensions failed')

    def test_variables_same_dims(self):
        indata = [VariableDesc('a', dimensions=[DimensionDesc('x', 4)]),
                  VariableDesc('b', dimensions=[DimensionDesc('x', 4)])]
        fdesc = FileDesc('test.nc', variables=indata)
        actual = fdesc.variables
        expected = OrderedDict((d.name, d) for d in indata)
        print_test_message('FileDesc.variables', input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.variables failed')
        adim = fdesc.variables['a'].dimensions['x']
        bdim = fdesc.variables['b'].dimensions['x']
        print_test_message('FileDesc.dimensions', adim=adim, bdim=bdim)
        self.assertEqual(adim, bdim, 'FileDesc.dimensions failed')
        actual = fdesc.dimensions
        expected = OrderedDict([(adim.name, adim)])
        print_test_message('FileDesc.dimensions', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'FileDesc.dimensions failed')


#=========================================================================
# DatasetDescTests - Tests for the datasets module
#=========================================================================
class DatasetDescTests(unittest.TestCase):
    """
    Unit Tests for the pyconform.datasets module
    """

    def setUp(self):
        self.filenames = OrderedDict([('u1', 'u1.nc'), ('u2', 'u2.nc')])
        self._clear_()

        self.fattribs = OrderedDict([('a1', 'attribute 1'),
                                     ('a2', 'attribute 2')])
        self.dims = OrderedDict([('time', 4), ('lat', 3), ('lon', 2)])
        self.vdims = OrderedDict([('u1', ('time', 'lat', 'lon')),
                                  ('u2', ('time', 'lat', 'lon'))])
        self.vattrs = OrderedDict([('lat', {'units': 'degrees_north',
                                            'standard_name': 'latitude'}),
                                   ('lon', {'units': 'degrees_east',
                                            'standard_name': 'longitude'}),
                                   ('time', {'units': 'days since 1979-01-01 0:0:0',
                                             'calendar': 'noleap',
                                             'standard_name': 'time'}),
                                   ('u1', {'units': 'm',
                                           'standard_name': 'u variable 1'}),
                                   ('u2', {'units': 'm',
                                           'standard_name': 'u variable 2'})])
        self.dtypes = {'lat': 'f', 'lon': 'f', 'time': 'f', 'u1': 'd', 'u2': 'd'}
        ydat = np.linspace(-90, 90, num=self.dims['lat'],
                           endpoint=True, dtype=self.dtypes['lat'])
        xdat = np.linspace(-180, 180, num=self.dims['lon'],
                           endpoint=False, dtype=self.dtypes['lon'])
        tdat = np.linspace(0, self.dims['time'], num=self.dims['time'],
                           endpoint=False, dtype=self.dtypes['time'])
        ulen = reduce(lambda x, y: x * y, self.dims.itervalues(), 1)
        ushape = tuple(d for d in self.dims.itervalues())
        u1dat = np.linspace(0, ulen, num=ulen, endpoint=False,
                            dtype=self.dtypes['u1']).reshape(ushape)
        u2dat = np.linspace(0, ulen, num=ulen, endpoint=False,
                            dtype=self.dtypes['u2']).reshape(ushape)
        self.vdat = {'lat': ydat, 'lon': xdat, 'time': tdat,
                     'u1': u1dat, 'u2': u2dat}

        for vname, fname in self.filenames.iteritems():
            ncf = NCDataset(fname, 'w')
            ncf.setncatts(self.fattribs)
            ncvars = {}
            for dname, dvalue in self.dims.iteritems():
                dsize = dvalue if dname != 'time' else None
                ncf.createDimension(dname, dsize)
                ncvars[dname] = ncf.createVariable(dname, 'd', (dname,))
            ncvars[vname] = ncf.createVariable(vname, 'd', self.vdims[vname])
            for vnam, vobj in ncvars.iteritems():
                for aname, avalue in self.vattrs[vnam].iteritems():
                    setattr(vobj, aname, avalue)
                vobj[:] = self.vdat[vnam]
            ncf.close()

        vdicts = OrderedDict()

        vdicts['W'] = OrderedDict()
        vdicts['W']['datatype'] = 'double'
        vdicts['W']['dimensions'] = ('w',)
        vdicts['W']['definition'] = np.array([1., 2., 3., 4., 5., 6., 7., 8.], dtype='float64')
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'something'
        vattribs['units'] = '1'
        vdicts['W']['attributes'] = vattribs

        vdicts['X'] = OrderedDict()
        vdicts['X']['datatype'] = 'double'
        vdicts['X']['dimensions'] = ('x',)
        vdicts['X']['definition'] = 'lon'
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'longitude'
        vattribs['units'] = 'degrees_east'
        vdicts['X']['attributes'] = vattribs

        vdicts['Y'] = OrderedDict()
        vdicts['Y']['datatype'] = 'double'
        vdicts['Y']['dimensions'] = ('y',)
        vdicts['Y']['definition'] = 'lat'
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'latitude'
        vattribs['units'] = 'degrees_north'
        vdicts['Y']['attributes'] = vattribs

        vdicts['T'] = OrderedDict()
        vdicts['T']['datatype'] = 'double'
        vdicts['T']['dimensions'] = ('t',)
        vdicts['T']['definition'] = 'time'
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'time'
        vattribs['units'] = 'days since 01-01-0001 00:00:00'
        vattribs['calendar'] = 'noleap'
        vdicts['T']['attributes'] = vattribs

        vdicts['V1'] = OrderedDict()
        vdicts['V1']['datatype'] = 'double'
        vdicts['V1']['dimensions'] = ('t', 'y', 'x')
        vdicts['V1']['definition'] = 'u1 + u2'
        fdict = OrderedDict()
        fdict['filename'] = 'var1.nc'
        fdict['format'] = 'NETCDF4'
        fdict['attributes'] = {'A': 'some attribute', 'B': 'another attribute'}
        fdict['metavars'] = ['W']
        vdicts['V1']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'variable 1'
        vattribs['units'] = 'm'
        vdicts['V1']['attributes'] = vattribs

        vdicts['V2'] = OrderedDict()
        vdicts['V2']['datatype'] = 'double'
        vdicts['V2']['dimensions'] = ('t', 'y', 'x')
        vdicts['V2']['definition'] = 'u2 - u1'
        fdict = OrderedDict()
        fdict['filename'] = 'var2.nc'
        fdict['format'] = 'NETCDF4_CLASSIC'
        fdict['attributes'] = {'Z': 'this attribute', 'Y': 'that attribute'}
        fdict['metavars'] = ['V1']
        vdicts['V2']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'variable 2'
        vattribs['units'] = 'm'
        vdicts['V2']['attributes'] = vattribs

        self.dsdict = vdicts

    def tearDown(self):
        self._clear_()

    def _clear_(self):
        for fname in self.filenames.itervalues():
            if exists(fname):
                remove(fname)

    def test_dataset_type(self):
        ds = DatasetDesc()
        actual = type(ds)
        expected = DatasetDesc
        print_test_message('type(DatasetDesc)', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'DatasetDesc has wrong type')

    def test_input_dataset_type(self):
        inds = InputDatasetDesc('myinds', self.filenames.values())
        actual = type(inds)
        expected = InputDatasetDesc
        print_test_message('type(InputDatasetDesc)', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'InputDatasetDesc has wrong type')

    def test_input_dataset_files(self):
        inds = InputDatasetDesc('myinds', self.filenames.values())
        actual = sorted(inds.files.keys())
        expected = sorted(self.filenames.values())
        print_test_message('InputDatasetDesc.files', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'InputDatasetDesc has wrong files')

    def test_input_dataset_variables(self):
        inds = InputDatasetDesc('myinds', self.filenames.values())
        actual = sorted(inds.variables.keys())
        expected = sorted(self.vdat.keys())
        print_test_message('InputDatasetDesc.variables', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'InputDatasetDesc has wrong variables')

    def test_input_dataset_variable_files(self):
        inds = InputDatasetDesc('myinds', self.filenames.values())
        actual = {v.name:v.files.keys() for v in inds.variables.itervalues()}
        expected = {'lat': ['u1.nc', 'u2.nc'],
                    'lon': ['u1.nc', 'u2.nc'],
                    'time': ['u1.nc', 'u2.nc'],
                     'u1': ['u1.nc'],
                     'u2': ['u2.nc']}
        print_test_message('InputDatasetDesc.variables.files', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'InputDatasetDesc has wrong variable files')

    def test_input_dataset_dimensions(self):
        inds = InputDatasetDesc('myinds', self.filenames.values())
        actual = sorted(inds.dimensions.keys())
        expected = sorted(self.dims.keys())
        print_test_message('InputDatasetDesc.dimensions', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'InputDatasetDesc has wrong dimensions')

    def test_output_dataset_type(self):
        outds = OutputDatasetDesc('myoutds', self.dsdict)
        actual = type(outds)
        expected = OutputDatasetDesc
        print_test_message('type(OutputDatasetDesc)', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'OutputDatasetDesc has wrong type')

    def test_output_dataset_files(self):
        outds = OutputDatasetDesc('myoutds', self.dsdict)
        actual = sorted(outds.files.keys())
        expected = sorted(['var1.nc', 'var2.nc'])
        print_test_message('OutputDatasetDesc.files', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'OutputDatasetDesc has wrong files')

    def test_output_dataset_variables(self):
        outds = OutputDatasetDesc('myoutds', self.dsdict)
        actual = sorted(outds.variables.keys())
        expected = sorted(self.dsdict.keys())
        print_test_message('OutputDatasetDesc.variables', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'OutputDatasetDesc has wrong variables')

    def test_output_dataset_variable_files(self):
        outds = OutputDatasetDesc('myoutds', self.dsdict)
        actual = {v.name:v.files.keys() for v in outds.variables.itervalues()}
        expected = {'X': ['var1.nc', 'var2.nc'],
                    'Y': ['var1.nc', 'var2.nc'],
                    'T': ['var1.nc', 'var2.nc'],
                    'W': ['var1.nc'],
                    'V1': ['var1.nc', 'var2.nc'],
                    'V2': ['var2.nc']}
        print_test_message('OutputDatasetDesc.variables.files', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'OutputDatasetDesc has wrong variable files')

    def test_output_dataset_dimensions(self):
        outds = OutputDatasetDesc('myoutds', self.dsdict)
        actual = sorted(outds.dimensions.keys())
        expected = sorted(['t', 'x', 'y', 'w'])
        print_test_message('OutputDatasetDesc.dimensions', actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'OutputDatasetDesc has wrong dimensions')
    
    def test_output_dataset_validate_type_str(self):
        nc3_type_strs = OutputDatasetDesc._NC_TYPES_[3]
        nc4_type_strs = [t for t in OutputDatasetDesc._NC_TYPES_[4] if t not in nc3_type_strs]
        nc4_formats = ['NETCDF4']
        nc3_formats = ['NETCDF4_CLASSIC', 'NETCDF3_CLASSIC', 'NETCDF3_64BIT_OFFSET', 'NETCDF3_64BIT_DATA']
        for f in nc3_formats:
            for t in nc3_type_strs:
                msghdr = 'OutputDatasetDesc._validate_netcdf_type_({}, {})'.format(t,f)
                try:
                    OutputDatasetDesc._validate_netcdf_type_(t, f)
                except:
                    self.fail('{}: Failed'.format(msghdr))
                print '{}: Good'.format(msghdr)

            for t in nc4_type_strs:
                msghdr = 'OutputDatasetDesc._validate_netcdf_type_({}, {})'.format(t,f)                
                self.assertRaises(ValueError, OutputDatasetDesc._validate_netcdf_type_, t, f)
                print '{}: Failed properly'.format(msghdr)

        for f in nc4_formats:
            for t in nc3_type_strs + nc4_type_strs:
                msghdr = 'OutputDatasetDesc._validate_netcdf_type_({}, {})'.format(t,f)
                try:
                    OutputDatasetDesc._validate_netcdf_type_(t, f)
                except:
                    self.fail('{}: Failed'.format(msghdr))
                print '{}: Good'.format(msghdr)

        
#===============================================================================
# Command-Line Execution
#===============================================================================
if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
