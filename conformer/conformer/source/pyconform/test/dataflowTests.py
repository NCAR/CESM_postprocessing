"""
DataFlow Unit Tests

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from os import remove
from os.path import exists
from pyconform import dataflow, datasets
from testutils import print_test_message, print_ncfile
from collections import OrderedDict
from netCDF4 import Dataset as NCDataset

import unittest
import numpy


#=======================================================================================================================
# DataFlowTests
#=======================================================================================================================
class DataFlowTests(unittest.TestCase):
    """
    Unit tests for the flownodes.FlowNode class
    """

    def setUp(self):
        self.filenames = OrderedDict([('u1', 'u1.nc'),
                                      ('u2', 'u2.nc'),
                                      ('u3', 'u3.nc')])
        self.cleanInputFiles()

        self.fattribs = OrderedDict([('a1', 'attribute 1'),
                                     ('a2', 'attribute 2')])
        self.dims = OrderedDict([('time', 4), ('lat', 7), ('lon', 9), ('strlen', 6), ('ncat', 3), ('bnds', 2)])
        self.vdims = OrderedDict([('time', ('time',)),
                                  ('time_bnds', ('time', 'bnds')),
                                  ('lat', ('lat',)),
                                  ('lon', ('lon',)),
                                  ('cat', ('ncat', 'strlen')),
                                  ('u1', ('time', 'lat', 'lon')),
                                  ('u2', ('time', 'lat', 'lon')),
                                  ('u3', ('time', 'lat', 'lon'))])
        self.vattrs = OrderedDict([('lat', {'units': 'degrees_north',
                                            'standard_name': 'latitude'}),
                                   ('lon', {'units': 'degrees_east',
                                            'standard_name': 'longitude'}),
                                   ('time', {'units': 'days since 1979-01-01 0:0:0',
                                             'calendar': 'noleap',
                                             'standard_name': 'time'}),
                                   ('time_bnds', {'units': 'days since 1979-01-01 0:0:0'}),
                                   ('cat', {'standard_name': 'categories'}),
                                   ('u1', {'units': 'km',
                                           'standard_name': 'u variable 1'}),
                                   ('u2', {'units': 'm',
                                           'standard_name': 'u variable 2'}),
                                   ('u3', {'units': 'kg',
                                           'standard_name': 'u variable 3',
                                           'positive': 'down'})])
        self.dtypes = {'lat': 'd', 'lon': 'd', 'time': 'd', 'time_bnds': 'd', 'cat': 'c', 'u1': 'f', 'u2': 'f', 'u3': 'f'}
        
        ulen = reduce(lambda x, y: x * y, (self.dims[d] for d in self.vdims['u1']), 1)
        ushape = tuple(self.dims[d] for d in self.vdims['u1'])
        self.vdat = {'lat': numpy.linspace(-90, 90, num=self.dims['lat'], endpoint=True, dtype=self.dtypes['lat']),
                     'lon': -numpy.linspace(-180, 180, num=self.dims['lon'], dtype=self.dtypes['lon'])[::-1],
                     'time': numpy.arange(self.dims['time'], dtype=self.dtypes['time']),
                     'time_bnds': numpy.array([[i,i+1] for i in range(self.dims['time'])], dtype=self.dtypes['time_bnds']),
                     'cat': numpy.asarray(['left', 'middle', 'right'], dtype='S').view(self.dtypes['cat']),
                     'u1': numpy.linspace(0, ulen, num=ulen, dtype=self.dtypes['u1']).reshape(ushape),
                     'u2': numpy.linspace(0, ulen, num=ulen, dtype=self.dtypes['u2']).reshape(ushape),
                     'u3': numpy.linspace(0, ulen, num=ulen, dtype=self.dtypes['u3']).reshape(ushape)}

        for vname in self.filenames:
            fname = self.filenames[vname]
            ncf = NCDataset(fname, 'w')
            ncf.setncatts(self.fattribs)
            ncvars = {}
            for dname in self.dims:
                dsize = self.dims[dname] if dname != 'time' else None
                ncf.createDimension(dname, dsize)
            for uname in [u for u in self.vdims if u not in self.filenames]:
                ncvars[uname] = ncf.createVariable(uname, self.dtypes[uname], self.vdims[uname])
            ncvars[vname] = ncf.createVariable(vname, self.dtypes[vname], self.vdims[vname])
            for vnam in ncvars:
                vobj = ncvars[vnam]
                for aname in self.vattrs[vnam]:
                    setattr(vobj, aname, self.vattrs[vnam][aname])
                vobj[:] = self.vdat[vnam]
            ncf.close()
            print_ncfile(fname)
            print

        self.inpds = datasets.InputDatasetDesc('inpds', self.filenames.values())

        vdicts = OrderedDict()

        vdicts['L'] = OrderedDict()
        vdicts['L']['datatype'] = 'float'
        vdicts['L']['dimensions'] = ('l',)
        vdicts['L']['definition'] = tuple(range(5))
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'level'
        vattribs['units'] = '1'
        vattribs['axis'] = 'Z'
        vdicts['L']['attributes'] = vattribs

        vdicts['C'] = OrderedDict()
        vdicts['C']['datatype'] = 'char'
        vdicts['C']['dimensions'] = ('c','n')
        vdicts['C']['definition'] = 'cat'
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'category'
        vdicts['C']['attributes'] = vattribs

        vdicts['B'] = OrderedDict()
        vdicts['B']['datatype'] = 'char'
        vdicts['B']['dimensions'] = ('b', 'n')
        vdicts['B']['definition'] = ['a', 'bc', 'def']
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'category'
        vdicts['B']['attributes'] = vattribs

        vdicts['X'] = OrderedDict()
        vdicts['X']['datatype'] = 'double'
        vdicts['X']['dimensions'] = ('x',)
        vdicts['X']['definition'] = 'lon'
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'longitude'
        vattribs['units'] = 'degrees_east'
        vattribs['axis'] = 'X'
        vdicts['X']['attributes'] = vattribs

        vdicts['Y'] = OrderedDict()
        vdicts['Y']['datatype'] = 'double'
        vdicts['Y']['dimensions'] = ('y',)
        vdicts['Y']['definition'] = 'lat'
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'latitude'
        vattribs['units'] = 'degrees_north'
        vattribs['direction'] = 'decreasing'
        vattribs['axis'] = 'Y'
        vdicts['Y']['attributes'] = vattribs

        vdicts['T'] = OrderedDict()
        vdicts['T']['datatype'] = 'double'
        vdicts['T']['dimensions'] = ('t',)
        vdicts['T']['definition'] = 'mean(chunits(time_bnds, units=time), "bnds")'
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'time'
        vattribs['units'] = 'days since 0001-01-01 00:00:00'
        vattribs['calendar'] = 'noleap'
        vattribs['bounds'] = 'T_bnds'
        vattribs['axis'] = 'T'
        vdicts['T']['attributes'] = vattribs

        vdicts['T_bnds'] = OrderedDict()
        vdicts['T_bnds']['datatype'] = 'double'
        vdicts['T_bnds']['dimensions'] = ('t', 'd')
        vdicts['T_bnds']['definition'] = 'time_bnds'
        vdicts['T_bnds']['attributes'] = OrderedDict()

        vdicts['V1'] = OrderedDict()
        vdicts['V1']['datatype'] = 'double'
        vdicts['V1']['dimensions'] = ('t', 'y', 'x')
        vdicts['V1']['definition'] = '0.5*(u1 + u2)'
        fdict = OrderedDict()
        fdict['filename'] = 'var1_{%Y%m%d-%Y%m%d}.nc'
        fdict['attributes'] = {'variable': 'V1'}
        fdict['metavars'] = ['L', 'C']
        vdicts['V1']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'element-wise average of u1 and u2'
        vattribs['units'] = 'cm'
        vdicts['V1']['attributes'] = vattribs

        vdicts['V2'] = OrderedDict()
        vdicts['V2']['datatype'] = 'double'
        vdicts['V2']['dimensions'] = ('t', 'y', 'x')
        vdicts['V2']['definition'] = 'u2 - u1'
        fdict = OrderedDict()
        fdict['filename'] = 'var2_{%Y%m%d-%Y%m%d}.nc'
        fdict['attributes'] = {'variable': 'V2'}
        fdict['metavars'] = ['L', 'B']
        vdicts['V2']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'difference of u2 and u1'
        vattribs['units'] = 'cm'
        vdicts['V2']['attributes'] = vattribs

        vdicts['V3'] = OrderedDict()
        vdicts['V3']['datatype'] = 'double'
        vdicts['V3']['dimensions'] = ('x', 'y', 't')
        vdicts['V3']['definition'] = 'u2'
        fdict = OrderedDict()
        fdict['filename'] = 'var3_{%Y%m%d-%Y%m%d}.nc'
        fdict['attributes'] = {'variable': 'V3'}
        fdict['metavars'] = ['L']
        vdicts['V3']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'originally u2'
        vattribs['units'] = 'cm'
        vdicts['V3']['attributes'] = vattribs

        vdicts['V4'] = OrderedDict()
        vdicts['V4']['datatype'] = 'double'
        vdicts['V4']['dimensions'] = ('t', 'x', 'y')
        vdicts['V4']['definition'] = 'u1'
        fdict = OrderedDict()
        fdict['filename'] = 'var4_{%Y%m%d-%Y%m%d}.nc'
        fdict['attributes'] = {'variable': 'V4'}
        fdict['metavars'] = ['L']
        vdicts['V4']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'transposed u1'
        vattribs['units'] = 'km'
        vattribs['valid_min'] = 1.0
        vattribs['valid_max'] = 200.0
        vdicts['V4']['attributes'] = vattribs
        
        vdicts['V5'] = OrderedDict()
        vdicts['V5']['datatype'] = 'double'
        vdicts['V5']['dimensions'] = ('t', 'y')
        vdicts['V5']['definition'] = 'mean(u1, "lon")'
        fdict = OrderedDict()
        fdict['filename'] = 'var5_{%Y%m%d-%Y%m%d}.nc'
        fdict['attributes'] = {'variable': 'V5'}
        vdicts['V5']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'mean of u1 along the lon dimension'
        vattribs['units'] = 'km'
        vattribs['valid_min'] = 5.0
        vattribs['valid_max'] = 220.0
        vdicts['V5']['attributes'] = vattribs

        vdicts['V6'] = OrderedDict()
        vdicts['V6']['datatype'] = 'double'
        vdicts['V6']['dimensions'] = ('t', 'y')
        vdicts['V6']['definition'] = 'u2[:,:,0]'
        fdict = OrderedDict()
        fdict['filename'] = 'var6_{%Y%m%d-%Y%m%d}.nc'
        fdict['attributes'] = {'variable': 'V6'}
        vdicts['V6']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'u2 at lowest x-level'
        vattribs['units'] = 'km'
        vattribs['valid_min'] = 0.01
        vattribs['valid_max'] = 0.2
        vdicts['V6']['attributes'] = vattribs

        vdicts['V7'] = OrderedDict()
        vdicts['V7']['datatype'] = 'double'
        vdicts['V7']['dimensions'] = ('t', 'x', 'y')
        vdicts['V7']['definition'] = 'down(u2)'
        fdict = OrderedDict()
        fdict['filename'] = 'var7_{%Y%m%d-%Y%m%d}.nc'
        fdict['attributes'] = {'variable': 'V7'}
        vdicts['V7']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'u2 in upward direction'
        vattribs['units'] = 'm'
        vattribs['valid_min'] = -200.0
        vattribs['valid_max'] = 0.0
        vattribs['positive'] = 'up'
        vdicts['V7']['attributes'] = vattribs

        vdicts['V8'] = OrderedDict()
        vdicts['V8']['datatype'] = 'double'
        vdicts['V8']['dimensions'] = ('t', 'x', 'y')
        vdicts['V8']['definition'] = 'u3'
        fdict = OrderedDict()
        fdict['filename'] = 'var8_{%Y%m%d-%Y%m%d}.nc'
        fdict['attributes'] = {'variable': 'V8'}
        vdicts['V8']['file'] = fdict
        vattribs = OrderedDict()
        vattribs['standard_name'] = 'u3 in upward direction'
        vattribs['units'] = 'kg'
        vattribs['valid_min'] = -200.0
        vattribs['valid_max'] = -1.0
        vattribs['positive'] = 'up'
        vdicts['V8']['attributes'] = vattribs
        
        self.dsdict = vdicts

        self.outds = datasets.OutputDatasetDesc('outds', self.dsdict)

        self.outfiles = dict((vname, vdict['file']['filename'].replace('{%Y%m%d-%Y%m%d}', '19790101-19790104'))
                             for vname, vdict in vdicts.iteritems() if 'file' in vdict)
        self.cleanOutputFiles()

    def cleanInputFiles(self):
        for fname in self.filenames.itervalues():
            if exists(fname):
                remove(fname)

    def cleanOutputFiles(self):
        for fname in self.outfiles.itervalues():
            if exists(fname):
                remove(fname)

    def tearDown(self):
        self.cleanInputFiles()
        self.cleanOutputFiles()

    def test_init(self):
        testname = 'DataFlow.__init__()'
        df = dataflow.DataFlow(self.inpds, self.outds)
        actual = type(df)
        expected = dataflow.DataFlow
        print_test_message(testname, actual=actual, expected=expected)
        self.assertIsInstance(df, expected, '{} failed'.format(testname))

    def test_dimension_map(self):
        testname = 'DataFlow().dimension_map'
        df = dataflow.DataFlow(self.inpds, self.outds)
        actual = df.dimension_map
        expected = {'lat': 'y', 'strlen': 'n', 'lon': 'x', 'ncat': 'c', 'time': 't', 'bnds': 'd'}
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_execute_all(self):
        testname = 'DataFlow().execute()'
        df = dataflow.DataFlow(self.inpds, self.outds)
        df.execute()
        actual = all(exists(f) for f in self.outfiles.itervalues())
        expected = True
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        for f in self.outfiles:
            print_ncfile(self.outfiles[f])
            print

    def test_execute_chunks_1D_x(self):
        testname = 'DataFlow().execute()'
        df = dataflow.DataFlow(self.inpds, self.outds)
        expected = ValueError
        print_test_message(testname, expected=expected)
        self.assertRaises(expected, df.execute, chunks={'x': 4})

    def test_execute_chunks_1D_y(self):
        testname = 'DataFlow().execute()'
        df = dataflow.DataFlow(self.inpds, self.outds)
        df.execute(chunks={'y': 3})
        actual = all(exists(f) for f in self.outfiles.itervalues())
        expected = True
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        for f in self.outfiles:
            print_ncfile(self.outfiles[f])
            print

    def test_execute_chunks_2D_x_y(self):
        testname = 'DataFlow().execute()'
        df = dataflow.DataFlow(self.inpds, self.outds)
        expected = ValueError
        print_test_message(testname, expected=expected)
        self.assertRaises(expected, df.execute, chunks=OrderedDict([('x', 4), ('y', 3)]))

    def test_execute_chunks_2D_t_y(self):
        testname = 'DataFlow().execute()'
        df = dataflow.DataFlow(self.inpds, self.outds)
        df.execute(chunks=OrderedDict([('t', 2), ('y', 3)]))
        actual = all(exists(f) for f in self.outfiles.itervalues())
        expected = True
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        for f in self.outfiles:
            print_ncfile(self.outfiles[f])
            print


#===============================================================================
# Command-Line Operation
#===============================================================================
if __name__ == "__main__":
    unittest.main()
