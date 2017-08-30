"""
Parallel Tests for the Reshaper class

Copyright 2017, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

import unittest

import sys
import inspect
from glob import glob
from cStringIO import StringIO
from os import linesep as eol
from os import remove
from os.path import exists
from mpi4py import MPI

from pyreshaper.reshaper import Reshaper, create_reshaper
from pyreshaper.specification import Specifier

from pyreshaper.test import makeTestData

MPI_COMM_WORLD = MPI.COMM_WORLD  # @UndefinedVariable


#=======================================================================================================================
# NetCDF4Tests
#=======================================================================================================================
class NetCDF4Tests(unittest.TestCase):

    def setUp(self):

        # Parallel Management - Just for Tests
        self.rank = MPI_COMM_WORLD.Get_rank()
        self.size = MPI_COMM_WORLD.Get_size()
        
        # Default arguments for testing
        self.spec_args = {'infiles': makeTestData.slices,
                          'ncfmt': 'netcdf4',
                          'compression': 0,
                          'prefix': 'out.',
                          'suffix': '.nc',
                          'timeseries': None,
                          'metadata': [v for v in makeTestData.tvmvars] + ['time'] + [v for v in makeTestData.chvars],
                          'meta1d': False,
                          'backend': 'netCDF4'}
        self.create_args = {'serial': False,
                            'verbosity': 1,
                            'wmode': 'w',
                            'once': False,
                            'simplecomm': None}
        self.convert_args = {'output_limit': 0,
                             'chunks': None}
        
        # Test Data Generation
        self.clean()
        if self.rank == 0:
            makeTestData.generate_data()
        MPI_COMM_WORLD.Barrier()

    def tearDown(self):
        self.clean()

    def clean(self):
        if self.rank == 0:
            for ncfile in glob('*.nc'):
                remove(ncfile)
        MPI_COMM_WORLD.Barrier()

    def header(self):
        if self.rank == 0:
            mf = len(makeTestData.slices)
            mt = len(makeTestData.tsvars)
            nf = len(self.spec_args['infiles'])
            nt = mt if self.spec_args['timeseries'] is None else len(self.spec_args['timeseries'])

            hline = '-' * 100
            hdrstr = ['', hline, '{}.{}:'.format(self.__class__.__name__, inspect.stack()[1][3]), '',
                      '   specifier({}/{} infile(s), {}/{} TSV(s), ncfmt={ncfmt}, compression={compression}, meta1d={meta1d}, backend={backend})'.format(nf, mf, nt, mt, **self.spec_args),
                      '   create(serial={serial}, verbosity={verbosity}, wmode={wmode}, once={once}, simplecomm={simplecomm})'.format(**self.create_args),
                      '   convert(output_limit={output_limit}, chunks={chunks})'.format(**self.convert_args), hline, '']
            print eol.join(hdrstr)

    def check(self, tsvar):
        args = {}
        args.update(self.spec_args)
        args.update(self.create_args)
        args.update(self.convert_args)        
        assertions_dict = makeTestData.check_outfile(tsvar=tsvar, **args)
        failed_assertions = [key for key, value in assertions_dict.iteritems() if value is False]
        assert_msgs = ['Output file check for variable {0!r}:'.format(tsvar)]
        assert_msgs.extend(['   {0}'.format(assrt) for assrt in failed_assertions])
        self.assertEqual(len(failed_assertions), 0, eol.join(assert_msgs))

    def convert(self, print_diags=False):
        if not (self.create_args.get('serial', False) and self.rank > 0):
            if self.create_args.get('verbosity', 1) == 0:
                oldout = sys.stdout
                newout = StringIO()
                sys.stdout = newout

            spec = Specifier(**self.spec_args)
            rshpr = create_reshaper(spec, **self.create_args)
            self.assertEqual(type(rshpr), Reshaper, 'type(reshaper) failure')
            rshpr.convert(**self.convert_args)

            if self.create_args.get('verbosity', 1) == 0:
                actual = newout.getvalue()
                self.assertEqual(actual, '', 'stdout should be empty')
                sys.stdout = oldout

            if print_diags:
                rshpr.print_diagnostics()
        MPI_COMM_WORLD.Barrier()

    def test_defaults(self):
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_I1(self):
        self.spec_args['infiles'] = makeTestData.slices[1:2]
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_V0(self):
        self.create_args['verbosity'] = 0
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_V3(self):
        self.create_args['verbosity'] = 3
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_TSV2(self):
        self.spec_args['timeseries'] = makeTestData.tsvars[1:3] + ['tsvarX']
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in self.spec_args['timeseries']:
                if tsvar in makeTestData.tsvars:
                    self.check(tsvar)
                else:
                    fname = self.spec_args['prefix'] + tsvar + self.spec_args['suffix']
                    self.assertFalse(exists(fname), 'File {0!r} should not exist'.format(fname))
        MPI_COMM_WORLD.Barrier()

    def test_NC3(self):
        self.spec_args['ncfmt'] = 'netcdf'
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_ser(self):
        self.create_args['serial'] = True
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_CL1(self):
        self.spec_args['compression'] = 1
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_meta1d(self):
        self.spec_args['meta1d'] = True
        self.spec_args['metadata'] = [v for v in makeTestData.tvmvars]
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_once(self):
        self.create_args['once'] = True
        self.header()
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_overwrite(self):
        self.create_args['wmode'] = 'o'
        self.header()
        self.create_args['verbosity'] = 0
        self.convert()
        self.create_args['verbosity'] = 1
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_skip(self):
        self.create_args['wmode'] = 's'
        self.header()
        self.create_args['verbosity'] = 0
        self.convert()
        self.create_args['verbosity'] = 1
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_append(self):
        self.create_args['wmode'] = 'a'
        self.header()
        self.create_args['wmode'] = 'w'
        self.spec_args['infiles'] = makeTestData.slices[0:2]
        self.convert()
        self.create_args['wmode'] = 'a'
        self.spec_args['infiles'] = makeTestData.slices[2:]
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_append_missing(self):
        missing = makeTestData.tsvars[2]
        self.create_args['wmode'] = 'a'
        self.header()
        self.create_args['wmode'] = 'w'
        self.spec_args['infiles'] = makeTestData.slices[0:2]
        self.convert()
        if self.rank == 0:
            remove(self.spec_args['prefix'] + missing + self.spec_args['suffix'])
        MPI_COMM_WORLD.Barrier()
        self.create_args['wmode'] = 'a'
        self.spec_args['infiles'] = makeTestData.slices[2:]
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                if tsvar == missing:
                    self.spec_args['infiles'] = makeTestData.slices[2:]
                else:
                    self.spec_args['infiles'] = makeTestData.slices
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()


#=======================================================================================================================
# NioTests
#=======================================================================================================================
class NioTests(NetCDF4Tests):
    """PyNIO tests"""
    
    def setUp(self):
        NetCDF4Tests.setUp(self)
        self.spec_args['backend'] = 'Nio'
    

#=======================================================================================================================
# CLI
#=======================================================================================================================
if __name__ == "__main__":
    hline = '=' * 70
    if MPI_COMM_WORLD.Get_rank() == 0:
        print hline
        print 'STANDARD OUTPUT FROM ALL TESTS:'
        print hline
    MPI_COMM_WORLD.Barrier()

    mystream = StringIO()
    tests = [unittest.TestLoader().loadTestsFromTestCase(NetCDF4Tests),
             unittest.TestLoader().loadTestsFromTestCase(NioTests)]
    suite = unittest.TestSuite(tests)
    unittest.TextTestRunner(stream=mystream).run(suite)
    MPI_COMM_WORLD.Barrier()
    results = MPI_COMM_WORLD.gather(mystream.getvalue())

    if MPI_COMM_WORLD.Get_rank() == 0:
        for rank, result in enumerate(results):
            print hline
            print 'TESTS RESULTS FOR RANK ' + str(rank) + ':'
            print hline
            print str(result)
