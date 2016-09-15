"""
Copyright 2015, University Corporation for Atmospheric Research
See LICENSE.txt for details
"""

import os
import imp
import unittest
import cPickle as pickle

from pyreshaper.specification import Specifier

s2smake = imp.load_source('s2smake', '../../../scripts/s2smake')


class s2smakeTest(unittest.TestCase):

    def test_CLI_empty(self):
        argv = []
        self.assertRaises(ValueError, s2smake.cli, argv)

    def test_CLI_help(self):
        argv = ['-h']
        self.assertRaises(SystemExit, s2smake.cli, argv)

    def test_CLI_defaults(self):
        argv = ['s2smakeTests.py']
        opts, args = s2smake.cli(argv)
        self.assertEqual(opts.compression_level, 1,
                         'Default compression level is not 1')
        for i1, i2 in zip(args, argv):
            self.assertEqual(i1, i2,
                             'Default infiles list is not {0}'.format(argv))
        self.assertEqual(len(opts.metadata), 0,
                         'Default metadata list is not []')
        self.assertEqual(opts.netcdf_format, 'netcdf4',
                         'Default NetCDF format is not "netcdf4"')
        self.assertEqual(opts.output_prefix, 'tseries.',
                         'Default output prefix is not "tseries."')
        self.assertEqual(opts.output_suffix, '.nc',
                         'Default output suffix is not ".nc"')
        self.assertEqual(opts.specfile, 'input.s2s',
                         'Default output suffix is not ".nc"')

    def test_CLI_set_all_short(self):
        clevel = 3
        ncfmt = 'netcdf'
        metadata = ['meta1', 'meta2']
        specfile = 'myspec.s2s'
        prefix = 'prefix.'
        suffix = '.suffix'
        infiles = ['s2smakeTests.py', 'specificationTests.py']

        argv = ['-c', str(clevel), '-f', ncfmt]
        for md in metadata:
            argv.extend(['-m', md])
        argv.extend(['-o', specfile, '-p', prefix, '-s', suffix])
        argv.extend(infiles)
        opts, args = s2smake.cli(argv)
        print opts.metadata

        self.assertEqual(opts.compression_level, clevel,
                         'Default compression level is not {0!r}'.format(clevel))
        self.assertEqual(len(args), len(infiles),
                         'Default infiles is not of length {0}'.format(len(infiles)))
        for i1, i2 in zip(args, infiles):
            self.assertEqual(i1, i2,
                             'Default infiles list is not {0}'.format(infiles))
        self.assertEqual(len(opts.metadata), len(metadata),
                         'Default metadata list is not of length {0}'.format(len(metadata)))
        for i1, i2 in zip(opts.metadata, metadata):
            self.assertEqual(i1, i2,
                             'Default metadata list is not {0}'.format(metadata))
        self.assertEqual(opts.netcdf_format, ncfmt,
                         'Default NetCDF format is not {0!r}'.format(ncfmt))
        self.assertEqual(opts.output_prefix, prefix,
                         'Default output prefix is not {0!r}'.format(prefix))
        self.assertEqual(opts.output_suffix, suffix,
                         'Default output suffix is not {0!r}'.format(suffix))
        self.assertEqual(opts.specfile, specfile,
                         'Default output suffix is not {0!r}'.format(specfile))

    def test_CLI_set_all_long(self):
        clevel = 3
        ncfmt = 'netcdf'
        metadata = ['meta1', 'meta2']
        specfile = 'myspec.s2s'
        prefix = 'prefix.'
        suffix = '.suffix'
        infiles = ['s2smakeTests.py', 'specificationTests.py']

        argv = ['--compression_level', str(clevel), '--netcdf_format', ncfmt]
        for md in metadata:
            argv.extend(['--metadata', md])
        argv.extend(['--specfile', specfile, '--output_prefix', prefix,
                     '--output_suffix', suffix])
        argv.extend(infiles)
        opts, args = s2smake.cli(argv)

        self.assertEqual(opts.compression_level, clevel,
                         'Default compression level is not {0!r}'.format(clevel))
        self.assertEqual(len(args), len(infiles),
                         'Default infiles list is not of length {0}'.format(len(infiles)))
        for i1, i2 in zip(args, infiles):
            self.assertEqual(i1, i2,
                             'Default infiles has no {0}'.format(infiles))
        for i1, i2 in zip(opts.metadata, metadata):
            self.assertEqual(i1, i2,
                             'Default metadata list is not {0}'.format(metadata))
        self.assertEqual(opts.netcdf_format, ncfmt,
                         'Default NetCDF format is not {0!r}'.format(ncfmt))
        self.assertEqual(opts.output_prefix, prefix,
                         'Default output prefix is not {0!r}'.format(prefix))
        self.assertEqual(opts.output_suffix, suffix,
                         'Default output suffix is not {0!r}'.format(suffix))
        self.assertEqual(opts.specfile, specfile,
                         'Default output suffix is not {0!r}'.format(specfile))

    def test_main_defaults(self):
        argv = ['s2smakeTests.py']
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
        self.assertEqual(len(spec.input_file_list), len(argv),
                        'Default infiles is not of lenght {0}'.format(len(argv)))
        for i1, i2 in zip(spec.input_file_list, argv):
            self.assertEqual(i1, i2,
                             'Default infiles list is not {0}'.format(argv))
        self.assertEqual(len(spec.time_variant_metadata), 0,
                         'Default metadata list is not of length 0')
        self.assertEqual(spec.netcdf_format, 'netcdf4',
                         'Default NetCDF format is not "netcdf4"')
        self.assertEqual(spec.output_file_prefix, os.path.abspath('tseries.'),
                         'Default output prefix is not "tseries."')
        self.assertEqual(spec.output_file_suffix, '.nc',
                         'Default output suffix is not ".nc"')

    def test_main_set_all_short(self):
        clevel = 3
        ncfmt = 'netcdf'
        metadata = ['meta1', 'meta2']
        specfile = 'myspec.s2s'
        prefix = 'prefix.'
        suffix = '.suffix'
        infiles = ['s2smakeTests.py', 'specificationTests.py']

        argv = ['-c', str(clevel), '-f', ncfmt]
        for md in metadata:
            argv.extend(['-m', md])
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
        self.assertEqual(len(spec.input_file_list), len(infiles),
                        'Default infiles is not of lenght {0}'.format(len(infiles)))
        for i1, i2 in zip(spec.input_file_list, infiles):
            self.assertEqual(i1, i2,
                             'Default infiles list is not {0}'.format(argv))
        self.assertEqual(len(spec.time_variant_metadata), len(metadata),
                         'Default metadata list is not of length {0}'.format(len(metadata)))
        for i1, i2 in zip(spec.time_variant_metadata, metadata):
            self.assertEqual(i1, i2,
                             'Default metadata list is not {0}'.format(metadata))
        self.assertEqual(spec.netcdf_format, ncfmt,
                         'Default NetCDF format is not {0!r}'.format(ncfmt))
        self.assertEqual(spec.output_file_prefix, os.path.abspath(prefix),
                         'Default output prefix is not {0!r}'.format(prefix))
        self.assertEqual(spec.output_file_suffix, suffix + '.nc',
                         'Default output suffix is not {0!r}'.format(suffix))

    def test_main_set_all_long(self):
        clevel = 3
        ncfmt = 'netcdf'
        metadata = ['meta1', 'meta2']
        specfile = 'myspec.s2s'
        prefix = 'prefix.'
        suffix = '.suffix'
        infiles = ['s2smakeTests.py', 'specificationTests.py']

        argv = ['--compression_level', str(clevel), '--netcdf_format', ncfmt]
        for md in metadata:
            argv.extend(['--metadata', md])
        argv.extend(['--specfile', specfile, '--output_prefix', prefix,
                     '--output_suffix', suffix])
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
        self.assertEqual(len(spec.input_file_list), len(infiles),
                        'Default infiles is not of lenght {0}'.format(len(infiles)))
        for i1, i2 in zip(spec.input_file_list, infiles):
            self.assertEqual(i1, i2,
                             'Default infiles list is not {0}'.format(argv))
        self.assertEqual(len(spec.time_variant_metadata), len(metadata),
                         'Default metadata list is not of length {0}'.format(len(metadata)))
        for i1, i2 in zip(spec.time_variant_metadata, metadata):
            self.assertEqual(i1, i2,
                             'Default metadata list is not {0}'.format(metadata))
        self.assertEqual(spec.netcdf_format, ncfmt,
                         'Default NetCDF format is not {0!r}'.format(ncfmt))
        self.assertEqual(spec.output_file_prefix, os.path.abspath(prefix),
                         'Default output prefix is not {0!r}'.format(prefix))
        self.assertEqual(spec.output_file_suffix, suffix + '.nc',
                         'Default output suffix is not {0!r}'.format(suffix))

if __name__ == "__main__":
    unittest.main()
