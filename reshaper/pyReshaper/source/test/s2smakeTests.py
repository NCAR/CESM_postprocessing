"""
Copyright 2017, University Corporation for Atmospheric Research
See LICENSE.txt for details
"""

import os
import imp
import unittest
import cPickle as pickle

from pyreshaper.specification import Specifier

top_dir = os.getcwd().split('/source')[0]
s2smake = imp.load_source('s2smake', top_dir + '/scripts/s2smake')


#=========================================================================
# CLITest
#=========================================================================
class CLITest(unittest.TestCase):

    def test_empty(self):
        argv = []
        self.assertRaises(ValueError, s2smake.cli, argv)

    def test_help(self):
        argv = ['-h']
        self.assertRaises(SystemExit, s2smake.cli, argv)

    def test_defaults(self):
        argv = ['s2smakeTests.py']
        opts, args = s2smake.cli(argv)
        self.assertEqual(opts.compression_level, 1,
                         'Default compression level is not 1')
        self.assertEqual(opts.least_significant_digit, None,
                         'Default least significant digit is not None')
        for i1, i2 in zip(args, argv):
            self.assertEqual(
                i1, i2, 'Default infiles list is not {0}'.format(argv))
        self.assertEqual(len(opts.metadata), 0,
                         'Default metadata list is not []')
        self.assertEqual(opts.netcdf_format, 'netcdf4',
                         'Default NetCDF format is not "netcdf4"')
        self.assertEqual(opts.output_prefix, 'tseries.',
                         'Default output prefix is not "tseries."')
        self.assertEqual(opts.output_suffix, '.nc',
                         'Default output suffix is not ".nc"')
        self.assertEqual(opts.time_series, None,
                         'Default time series names is not None')
        self.assertEqual(opts.specfile, 'input.s2s',
                         'Default output suffix is not ".nc"')
        self.assertEqual(opts.meta1d, False,
                         'Default 1D metadata flag is not False')
        self.assertEqual(opts.metafile, None,
                         'Default metadata filename')
        self.assertEqual(opts.exclude, [],
                         'Default exclude list')

    def test_set_all_short(self):
        clevel = 3
        lsigfig = 2
        ncfmt = 'netcdf'
        metadata = ['meta1', 'meta2']
        specfile = 'myspec.s2s'
        prefix = 'prefix.'
        suffix = '.suffix'
        xlist = ['x', 'y', 'z']
        infiles = ['s2smakeTests.py', 'specificationTests.py']

        argv = ['-1']
        argv.extend(['-c', str(clevel), '-d', str(lsigfig), '-f', ncfmt])
        for md in metadata:
            argv.extend(['-m', md])
        for x in xlist:
            argv.extend(['-x', x])
        argv.extend(['-o', specfile, '-p', prefix, '-s', suffix])
        argv.extend(infiles)
        opts, args = s2smake.cli(argv)

        self.assertEqual(opts.compression_level, clevel,
                         'Default compression level is not {0!r}'.format(clevel))
        self.assertEqual(opts.least_significant_digit, lsigfig,
                         'Default least significant digit is not {0!r}'.format(lsigfig))
        self.assertEqual(len(args), len(
            infiles), 'Default infiles is not of length {0}'.format(len(infiles)))
        for i1, i2 in zip(args, infiles):
            self.assertEqual(
                i1, i2, 'Default infiles list is not {0}'.format(infiles))
        self.assertEqual(len(opts.metadata), len(
            metadata), 'Default metadata list is not of length {0}'.format(len(metadata)))
        for i1, i2 in zip(opts.metadata, metadata):
            self.assertEqual(
                i1, i2, 'Default metadata list is not {0}'.format(metadata))
        self.assertEqual(opts.netcdf_format, ncfmt,
                         'Default NetCDF format is not {0!r}'.format(ncfmt))
        self.assertEqual(opts.output_prefix, prefix,
                         'Default output prefix is not {0!r}'.format(prefix))
        self.assertEqual(opts.output_suffix, suffix,
                         'Default output suffix is not {0!r}'.format(suffix))
        self.assertEqual(opts.time_series, None,
                         'Default time-series list is not None')
        self.assertEqual(opts.specfile, specfile,
                         'Default output suffix is not {0!r}'.format(specfile))
        self.assertEqual(opts.meta1d, True,
                         'Default 1D metadata flag is not False')
        self.assertEqual(opts.exclude, xlist,
                         'Exclude list is not {0!r}'.format(xlist))

    def test_set_all_long(self):
        clevel = 3
        lsigfig = 2
        ncfmt = 'netcdf'
        metadata = ['meta1', 'meta2']
        xlist = ['x', 'y', 'z']
        specfile = 'myspec.s2s'
        prefix = 'prefix.'
        suffix = '.suffix'
        tseries = ['tsvar1', 'tsvar2']
        infiles = ['s2smakeTests.py', 'specificationTests.py']

        argv = ['--meta1d']
        argv.extend(['--compression_level', str(clevel),
                     '--least_significant_digit', str(lsigfig),
                     '--netcdf_format', ncfmt])
        for md in metadata:
            argv.extend(['--metadata', md])
        for x in xlist:
            argv.extend(['--exclude', x])
        argv.extend(['--specfile', specfile, '--output_prefix', prefix,
                     '--output_suffix', suffix])
        for ts in tseries:
            argv.extend(['--time_series', ts])
        argv.extend(infiles)
        opts, args = s2smake.cli(argv)

        self.assertEqual(opts.compression_level, clevel,
                         'Default compression level is not {0!r}'.format(clevel))
        self.assertEqual(opts.least_significant_digit, lsigfig,
                         'Default least significant digit is not {0!r}'.format(lsigfig))
        self.assertEqual(len(args), len(
            infiles), 'Default infiles list is not of length {0}'.format(len(infiles)))
        for i1, i2 in zip(args, infiles):
            self.assertEqual(
                i1, i2, 'Default infiles has no {0}'.format(infiles))
        for i1, i2 in zip(opts.metadata, metadata):
            self.assertEqual(
                i1, i2, 'Default metadata list is not {0}'.format(metadata))
        self.assertEqual(opts.netcdf_format, ncfmt,
                         'Default NetCDF format is not {0!r}'.format(ncfmt))
        self.assertEqual(opts.output_prefix, prefix,
                         'Default output prefix is not {0!r}'.format(prefix))
        self.assertEqual(opts.output_suffix, suffix,
                         'Default output suffix is not {0!r}'.format(suffix))
        for i1, i2 in zip(opts.time_series, tseries):
            self.assertEqual(
                i1, i2, 'Default time-series list is not {0}'.format(tseries))
        self.assertEqual(opts.specfile, specfile,
                         'Default output suffix is not {0!r}'.format(specfile))
        self.assertEqual(opts.meta1d, True,
                         'Default 1D metadata flag is not False')
        self.assertEqual(opts.exclude, xlist,
                         'Exclude list is not {0!r}'.format(xlist))


#=========================================================================
# MainTest
#=========================================================================
class MainTest(unittest.TestCase):

    def setUp(self):
        self.cwd = os.path.dirname(os.path.realpath(__file__))

    def test_defaults(self):
        argv = [self.cwd + '/s2smakeTests.py']
        specfile = 'input.s2s'
        if os.path.exists(specfile):
            os.remove(specfile)
        s2smake.main(argv)
        self.assertTrue(os.path.exists(specfile), 'Specfile not found')
        spec = pickle.load(open(specfile, 'rb'))
        os.remove(specfile)
        self.assertTrue(isinstance(spec, Specifier),
                        'Specfile does not contain a Specifier')
        self.assertEqual(spec.compression_level, 1,
                         'Default compression level is not 1')
        self.assertEqual(spec.least_significant_digit, None,
                         'Default least significant digit is not {0!r}'.format(None))
        self.assertEqual(len(spec.input_file_list), len(
            argv), 'Default infiles is not of lenght {0}'.format(len(argv)))
        for i1, i2 in zip(spec.input_file_list, argv):
            self.assertEqual(
                i1, i2, 'Default infiles list is not {0}'.format(argv))
        self.assertEqual(len(spec.time_variant_metadata), 0,
                         'Default metadata list is not of length 0')
        self.assertEqual(spec.netcdf_format, 'netcdf4',
                         'Default NetCDF format is not "netcdf4"')
        self.assertEqual(spec.output_file_prefix, os.path.abspath(
            'tseries.'), 'Default output prefix is not "tseries."')
        self.assertEqual(spec.output_file_suffix, '.nc',
                         'Default output suffix is not ".nc"')
        self.assertEqual(spec.time_series, None,
                         'Default NetCDF format is not None')
        self.assertEqual(spec.assume_1d_time_variant_metadata, False,
                         'Default 1D time-variant metadata flag is not False')

    def test_set_all_short(self):
        clevel = 3
        lsigfig = 2
        ncfmt = 'netcdf'
        metadata = ['meta1', 'meta2']
        xlist = ['x', 'y', 'z']
        specfile = 'myspec.s2s'
        prefix = 'prefix.'
        suffix = '.suffix'
        infiles = [self.cwd +
                   f for f in ['/s2smakeTests.py', '/specificationTests.py']]

        argv = ['-1', '-c', str(clevel), '-d', str(lsigfig), '-f', ncfmt]
        for md in metadata:
            argv.extend(['-m', md])
        for x in xlist:
            argv.extend(['-x', x])
        argv.extend(['-o', specfile, '-p', prefix, '-s', suffix])
        argv.extend(infiles)

        if os.path.exists(specfile):
            os.remove(specfile)
        s2smake.main(argv)

        self.assertTrue(os.path.exists(specfile), 'Specfile not found')
        spec = pickle.load(open(specfile, 'rb'))
        os.remove(specfile)

        self.assertTrue(isinstance(spec, Specifier),
                        'Specfile does not contain a Specifier')
        self.assertEqual(spec.compression_level, clevel,
                         'Default compression level is not {0!r}'.format(clevel))
        self.assertEqual(spec.least_significant_digit, lsigfig,
                         'Default least significant digit is not {0!r}'.format(lsigfig))
        self.assertEqual(len(spec.input_file_list), len(
            infiles), 'Default infiles is not of lenght {0}'.format(len(infiles)))
        for i1, i2 in zip(spec.input_file_list, infiles):
            self.assertEqual(
                i1, i2, 'Default infiles list is not {0}'.format(argv))
        self.assertEqual(len(spec.time_variant_metadata), len(
            metadata), 'Default metadata list is not of length {0}'.format(len(metadata)))
        for i1, i2 in zip(spec.time_variant_metadata, metadata):
            self.assertEqual(
                i1, i2, 'Default metadata list is not {0}'.format(metadata))
        self.assertEqual(spec.netcdf_format, ncfmt,
                         'Default NetCDF format is not {0!r}'.format(ncfmt))
        self.assertEqual(spec.output_file_prefix, os.path.abspath(
            prefix), 'Default output prefix is not {0!r}'.format(prefix))
        self.assertEqual(spec.output_file_suffix, suffix + '.nc',
                         'Default output suffix is not {0!r}'.format(suffix))
        self.assertEqual(spec.time_series, None,
                         'Default time series names is not None')
        self.assertEqual(spec.assume_1d_time_variant_metadata, True,
                         'Default 1D time-variant metadata flag is not True')
        self.assertEqual(spec.exclude_list, xlist,
                         'Exclude list is not {0!r}'.format(xlist))

    def test_set_all_long(self):
        clevel = 3
        lsigfig = 2
        ncfmt = 'netcdf'
        metadata = ['meta1', 'meta2']
        specfile = 'myspec.s2s'
        prefix = 'prefix.'
        suffix = '.suffix'
        tseries = ['tsvar1', 'tsvar2']
        infiles = [self.cwd +
                   f for f in ['/s2smakeTests.py', '/specificationTests.py']]

        argv = ['--meta1d',
                '--compression_level', str(clevel),
                '--least_significant_digit', str(lsigfig),
                '--netcdf_format', ncfmt]
        for md in metadata:
            argv.extend(['--metadata', md])
        argv.extend(['--specfile', specfile, '--output_prefix',
                     prefix, '--output_suffix', suffix])
        for ts in tseries:
            argv.extend(['--time_series', ts])
        argv.extend(infiles)

        if os.path.exists(specfile):
            os.remove(specfile)
        s2smake.main(argv)

        self.assertTrue(os.path.exists(specfile), 'Specfile not found')
        spec = pickle.load(open(specfile, 'rb'))
        os.remove(specfile)

        self.assertTrue(isinstance(spec, Specifier),
                        'Specfile does not contain a Specifier')
        self.assertEqual(spec.compression_level, clevel,
                         'Default compression level is not {0!r}'.format(clevel))
        self.assertEqual(spec.least_significant_digit, lsigfig,
                         'Default least significant digit is not {0!r}'.format(lsigfig))
        self.assertEqual(len(spec.input_file_list), len(
            infiles), 'Default infiles is not of lenght {0}'.format(len(infiles)))
        for i1, i2 in zip(spec.input_file_list, infiles):
            self.assertEqual(
                i1, i2, 'Default infiles list is not {0}'.format(argv))
        self.assertEqual(len(spec.time_variant_metadata), len(
            metadata), 'Default metadata list is not of length {0}'.format(len(metadata)))
        for i1, i2 in zip(spec.time_variant_metadata, metadata):
            self.assertEqual(
                i1, i2, 'Default metadata list is not {0}'.format(metadata))
        self.assertEqual(spec.netcdf_format, ncfmt,
                         'Default NetCDF format is not {0!r}'.format(ncfmt))
        self.assertEqual(spec.output_file_prefix, os.path.abspath(
            prefix), 'Default output prefix is not {0!r}'.format(prefix))
        self.assertEqual(spec.output_file_suffix, suffix + '.nc',
                         'Default output suffix is not {0!r}'.format(suffix))
        for i1, i2 in zip(spec.time_series, tseries):
            self.assertEqual(
                i1, i2, 'Default time-series list is not {0}'.format(tseries))
        self.assertEqual(spec.assume_1d_time_variant_metadata, True,
                         'Default 1D time-variant metadata flag is not True')


#=========================================================================
# CLI
#=========================================================================
if __name__ == "__main__":
    unittest.main()
