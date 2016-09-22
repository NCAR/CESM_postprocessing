"""
Unit tests for the Specifier class

Copyright 2015, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

import os
import unittest
import cPickle as pickle

from pyreshaper import specification


class SpecifierTests(unittest.TestCase):

    """
    SpecifierTests Class

    This class defines all of the unit tests for the specification module.
    """

    def test_init(self):
        spec = specification.Specifier()
        self.assertEqual(len(spec.input_file_list), 0,
                             'Input file list not initialized to empty')
        self.assertEqual(spec.netcdf_format, 'netcdf4',
                         'NetCDF format not initialized to netcdf4')
        self.assertEqual(spec.compression_level, 0,
                         'NetCDF compression level not initialized to 0')
        self.assertEqual(spec.output_file_prefix, 'tseries.',
                         'Output file prefix not initialized to tseries.')
        self.assertEqual(spec.output_file_suffix, '.nc',
                         'Output file prefix not initialized to .nc')
        self.assertEqual(len(spec.time_variant_metadata), 0,
                             'Time variant metadata list not initialized to empty')

    def test_init_full(self):
        in_list = ['a', 'b', 'c']
        fmt = 'netcdf4c'
        cl = 4
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = ['x', 'y', 'z']
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        for i1, i2 in zip(spec.input_file_list, in_list):
            self.assertEqual(i1, i2,
                             'Input file list not initialized properly')
        self.assertEqual(spec.netcdf_format, fmt,
                         'NetCDF format not initialized properly')
        self.assertEqual(spec.compression_level, cl,
                         'NetCDF compression level not initialized properly')
        self.assertEqual(spec.output_file_prefix, prefix,
                         'Output file prefix not initialized properly')
        self.assertEqual(spec.output_file_suffix, suffix,
                         'Output file prefix not initialized properly')
        for i1,i2 in zip(spec.time_variant_metadata, metadata):
            self.assertEqual(i1, i2,
                             'Time variant metadata list not initialized properly')

    def test_validate_types(self):
        in_list = ['a', 'b', 'c']
        fmt = 'netcdf'
        cl = 3
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = ['x', 'y', 'z']
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        spec.validate_types()

    def test_validate_types_fail_input(self):
        in_list = ['a', 2, 'c']
        fmt = 'netcdf'
        cl = 5
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = ['x', 'y', 'z']
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        self.assertRaises(TypeError, spec.validate_types)

    def test_validate_types_fail_format(self):
        in_list = ['a', 'b', 'c']
        fmt = 2342
        cl = 5
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = ['x', 'y', 'z']
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        self.assertRaises(TypeError, spec.validate_types)

    def test_validate_types_fail_cl(self):
        in_list = ['a', 'b', 'c']
        fmt = 'netcdf'
        cl = '6'
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = ['x', 'y', 'z']
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        self.assertRaises(TypeError, spec.validate_types)

    def test_validate_types_fail_prefix(self):
        in_list = ['a', 'b', 'c']
        fmt = 'netcdf'
        cl = 5
        prefix = dict()
        suffix = '.suf.nc'
        metadata = ['x', 'y', 'z']
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        self.assertRaises(TypeError, spec.validate_types)

    def test_validate_types_fail_suffix(self):
        in_list = ['a', 'b', 'c']
        fmt = 'netcdf'
        cl = 5
        prefix = 'pre.'
        suffix = list()
        metadata = ['x', 'y', 'z']
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        self.assertRaises(TypeError, spec.validate_types)

    def test_validate_types_fail_metadata(self):
        in_list = ['a', 'b', 'c']
        fmt = 'netcdf'
        cl = 5
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = ['x', 'y', 2]
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        self.assertRaises(TypeError, spec.validate_types)

    def test_validate_values_fail_input(self):
        in_list = ['a', 'b', 'c']
        fmt = 'netcdf'
        cl = 5
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = []
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        spec.validate_types()
        self.assertRaises(ValueError, spec.validate_values)

    def test_validate_values_fail_format(self):
        in_list = ['timekeeperTests.py', 'messengerTests.py']
        fmt = 'netcdf9'
        cl = 5
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = []
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        spec.validate_types()
        self.assertRaises(ValueError, spec.validate_values)

    def test_validate_values_fail_cl(self):
        in_list = ['timekeeperTests.py', 'messengerTests.py']
        fmt = 'netcdf4'
        cl = 111
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = []
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        spec.validate_types()
        self.assertRaises(ValueError, spec.validate_values)

    def test_validate_values_fail_prefix(self):
        in_list = ['timekeeperTests.py', 'messengerTests.py']
        fmt = 'netcdf4'
        prefix = '/sfcsrytsdfv/pre.'
        suffix = '.suf.nc'
        metadata = []
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, prefix=prefix,
            suffix=suffix, metadata=metadata)
        spec.validate_types()
        self.assertRaises(ValueError, spec.validate_values)

    def test_validate_values_suffix(self):
        in_list = ['specificationTests.py']
        fmt = 'netcdf4'
        prefix = 'pre.'
        suffix = '.suf'
        metadata = []
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, prefix=prefix,
            suffix=suffix, metadata=metadata)
        spec.validate_types()
        spec.validate_values()
        self.assertEqual(spec.output_file_suffix, suffix + '.nc',
                         'Suffix was not changed to .nc extension')

    def test_write(self):
        in_list = ['specificationTests.py']
        fmt = 'netcdf4'
        cl = 8
        prefix = 'pre.'
        suffix = '.suf.nc'
        metadata = ['time']
        spec = specification.Specifier(
            infiles=in_list, ncfmt=fmt, compression=cl, prefix=prefix,
            suffix=suffix, metadata=metadata)
        fname = 'test_write.s2s'
        spec.write(fname)
        self.assertTrue(os.path.exists(fname), 'Specfile failed to write')
        spec2 = pickle.load(open(fname, 'r'))
        for i1,i2 in zip(spec2.input_file_list, in_list):
            self.assertEqual(i1, i2,
                             'Input file list not initialized properly')
        self.assertEqual(spec2.netcdf_format, fmt,
                         'NetCDF format not initialized properly')
        self.assertEqual(spec2.compression_level, cl,
                         'NetCDF compression level not initialized properly')
        self.assertEqual(spec2.output_file_prefix, prefix,
                         'Output file prefix not initialized properly')
        self.assertEqual(spec2.output_file_suffix, suffix,
                         'Output file prefix not initialized properly')
        for i1,i2 in zip(spec2.time_variant_metadata, metadata):
            self.assertEqual(i1, i2,
                             'Time variant metadata list not initialized properly')
        os.remove(fname)


if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
