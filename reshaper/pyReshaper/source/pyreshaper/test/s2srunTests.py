"""
Parallel Tests for the Reshaper class

Copyright 2017, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

import unittest

import imp
import inspect
from glob import glob
from cStringIO import StringIO
from os import linesep as eol
from os import remove
from os.path import exists
from mpi4py import MPI

from pyreshaper.specification import Specifier

from pyreshaper.test import makeTestData

s2srun = imp.load_source('s2srun', '../../../scripts/s2srun')

MPI_COMM_WORLD = MPI.COMM_WORLD  # @UndefinedVariable


#=======================================================================================================================
# CLITests
#=======================================================================================================================
class CLITests(unittest.TestCase):


    def setUp(self):
        self.run_args = {'serial': False,
                         'chunks': None,
                         'limit': 0,
                         'verbosity': 1,
                         'write_mode': 'w',
                         'once': False,
                         'specfile': 'input.s2s'}

    def longargs(self):
        argv = ['--verbosity', str(self.run_args['verbosity']),
                '--write_mode', self.run_args['write_mode']]
        if self.run_args['limit'] > 0:
            argv.extend(['--limit', str(self.run_args['limit'])])
        if self.run_args['once']:
            argv.append('--once')
        if self.run_args['serial']:
            argv.append('--serial')
        if self.run_args['chunks'] is not None and len(self.run_args['chunks']) > 0:
            chunks = []
            for c in self.run_args['chunks']:
                chunks.extend(['--chunk', c])
            argv.extend(chunks)
        argv.append(self.run_args['specfile'])
        return argv
    
    def shortargs(self):
        long_to_short = {'--verbosity': '-v', '--write_mode': '-m', '--limit': '-l',
                         '--once': '-l', '--serial': '-s', '--chunk': '-c'}
        return [long_to_short[a] if a in long_to_short else a for a in self.longargs()]

    def cliassert(self, args):
        opts, specfile = s2srun.cli(args)
        self.assertEqual(opts.once, self.run_args['once'], 'Once-file incorrect')
        self.assertEqual(opts.chunks, self.run_args['chunks'], 'Chunks incorrect')
        self.assertEqual(opts.limit, self.run_args['limit'], 'Output limit incorrect')
        self.assertEqual(opts.write_mode, self.run_args['write_mode'], 'Write mode incorrect')
        self.assertEqual(opts.serial, self.run_args['serial'], 'Serial mode incorrect')
        self.assertEqual(opts.verbosity, self.run_args['verbosity'], 'Verbosity incorrect')
        self.assertEqual(specfile, self.run_args['specfile'], 'Specfile name incorrect')

    def test_empty(self):
        self.assertRaises(ValueError, s2srun.cli, [])

    def test_help(self):
        self.assertRaises(SystemExit, s2srun.cli, ['-h'])

    def test_defaults(self):
        self.cliassert([self.run_args['specfile']])

    def test_short(self):
        self.cliassert(self.shortargs())

    def test_long(self):
        self.cliassert(self.longargs())


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
                          'metadata': [v for v in makeTestData.tvmvars] + ['time'],
                          'meta1d': False,
                          'backend': 'netCDF4'}
        self.run_args = {'serial': False,
                         'chunks': [],
                         'limit': 0,
                         'verbosity': 1,
                         'write_mode': 'w',
                         'once': False,
                         'specfile': 'input.s2s'}
        
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

    def header(self, testname):
        if self.rank == 0:
            mf = len(makeTestData.slices)
            mt = len(makeTestData.tsvars)
            nf = len(self.spec_args['infiles'])
            nt = mt if self.spec_args['timeseries'] is None else len(self.spec_args['timeseries'])

            hline = '-' * 100
            hdrstr = [hline, '{}.{}:'.format(self.__class__.__name__, testname), '',
                      '   specifier({}/{} infile(s), {}/{} TSV(s), ncfmt={ncfmt}, compression={compression}, meta1d={meta1d}, backend={backend})'.format(nf, mf, nt, mt, **self.spec_args),
                      '   s2srun {}'.format(' '.join(str(a) for a in self.runargs())), hline]
            print eol.join(hdrstr)

    def check(self, tsvar):
        args = {}
        args.update(self.spec_args)
        args.update(self.run_args)
        assertions_dict = makeTestData.check_outfile(tsvar=tsvar, **args)
        failed_assertions = [key for key, value in assertions_dict.iteritems() if value is False]
        assert_msgs = ['Output file check for variable {0!r}:'.format(tsvar)]
        assert_msgs.extend(['   {0}'.format(assrt) for assrt in failed_assertions])
        self.assertEqual(len(failed_assertions), 0, eol.join(assert_msgs))
    
    def runargs(self):
        argv = ['-v', str(self.run_args['verbosity']),
                '-m', self.run_args['write_mode'],
                '-l', str(self.run_args['limit'])]
        if self.run_args['once']:
            argv.append('-1')
        if self.run_args['serial']:
            argv.append('-s')
        if len(self.run_args['chunks']) > 0:
            chunks = []
            for c in self.run_args['chunks']:
                chunks.extend(['-c', c])
            argv.extend(chunks)
        argv.append(self.run_args['specfile'])
        return argv

    def convert(self):
        if self.run_args['serial']:
            if self.rank == 0:
                spec = Specifier(**self.spec_args)
                spec.write(self.run_args['specfile'])
                s2srun.main(self.runargs())
                remove(self.run_args['specfile'])
        else:
            if self.rank == 0:
                spec = Specifier(**self.spec_args)
                spec.write(self.run_args['specfile'])
            MPI_COMM_WORLD.Barrier()
            s2srun.main(self.runargs())
            if self.rank == 0:
                remove(self.run_args['specfile'])
        MPI_COMM_WORLD.Barrier()

    def test_defaults(self):
        self.header(inspect.currentframe().f_code.co_name)
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_I1(self):
        self.spec_args['infiles'] = makeTestData.slices[1:2]
        self.header(inspect.currentframe().f_code.co_name)
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_V0(self):
        self.run_args['verbosity'] = 0
        self.header(inspect.currentframe().f_code.co_name)
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_V3(self):
        self.run_args['verbosity'] = 3
        self.header(inspect.currentframe().f_code.co_name)
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_TSV2(self):
        self.spec_args['timeseries'] = makeTestData.tsvars[1:3] + ['tsvarX']
        self.header(inspect.currentframe().f_code.co_name)
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
        self.header(inspect.currentframe().f_code.co_name)
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_ser(self):
        self.run_args['serial'] = True
        self.header(inspect.currentframe().f_code.co_name)
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_CL1(self):
        self.spec_args['compression'] = 1
        self.header(inspect.currentframe().f_code.co_name)
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_meta1d(self):
        self.spec_args['meta1d'] = True
        self.spec_args['metadata'] = [v for v in makeTestData.tvmvars]
        self.header(inspect.currentframe().f_code.co_name)
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_once(self):
        self.run_args['once'] = True
        self.header(inspect.currentframe().f_code.co_name)
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_overwrite(self):
        self.run_args['write_mode'] = 'o'
        self.header(inspect.currentframe().f_code.co_name)
        self.run_args['verbosity'] = 0
        self.convert()
        self.run_args['verbosity'] = 1
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_skip(self):
        self.run_args['write_mode'] = 's'
        self.header(inspect.currentframe().f_code.co_name)
        self.run_args['verbosity'] = 0
        self.convert()
        self.run_args['verbosity'] = 1
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_append(self):
        self.run_args['write_mode'] = 'a'
        self.header(inspect.currentframe().f_code.co_name)
        self.run_args['write_mode'] = 'w'
        self.spec_args['infiles'] = makeTestData.slices[0:2]
        self.convert()
        self.run_args['write_mode'] = 'a'
        self.spec_args['infiles'] = makeTestData.slices[2:]
        self.convert()
        if self.rank == 0:
            for tsvar in makeTestData.tsvars:
                self.check(tsvar)
        MPI_COMM_WORLD.Barrier()

    def test_append_missing(self):
        missing = makeTestData.tsvars[2]
        self.run_args['write_mode'] = 'a'
        self.header(inspect.currentframe().f_code.co_name)
        self.run_args['write_mode'] = 'w'
        self.spec_args['infiles'] = makeTestData.slices[0:2]
        self.convert()
        if self.rank == 0:
            remove(self.spec_args['prefix'] + missing + self.spec_args['suffix'])
        MPI_COMM_WORLD.Barrier()
        self.run_args['write_mode'] = 'a'
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
    
    def setUp(self):
        NetCDF4Tests.setUp(self)
        self.spec_args['backend'] = 'Nio'


#=======================================================================================================================
# CLI
#=======================================================================================================================
if __name__ == "__main__":
    hline = '=' * 100
    if MPI_COMM_WORLD.Get_rank() == 0:
        print hline
        print 'STANDARD OUTPUT FROM ALL TESTS:'
        print hline
    MPI_COMM_WORLD.Barrier()

    if MPI_COMM_WORLD.Get_rank() == 0:
        clistream = StringIO()
        clitests = unittest.TestLoader().loadTestsFromTestCase(CLITests)
        unittest.TextTestRunner(stream=clistream).run(clitests)
        print hline
        print 'CLI TESTS RESULTS:'
        print hline
        print clistream.getvalue()
    MPI_COMM_WORLD.Barrier()

    mainstream = StringIO()
    nc4tests = unittest.TestLoader().loadTestsFromTestCase(NetCDF4Tests)
    tests = [unittest.TestLoader().loadTestsFromTestCase(NetCDF4Tests),
             unittest.TestLoader().loadTestsFromTestCase(NioTests)]
    suite = unittest.TestSuite(tests)
    unittest.TextTestRunner(stream=mainstream).run(suite)
    MPI_COMM_WORLD.Barrier()

    results = MPI_COMM_WORLD.gather(mainstream.getvalue())
    if MPI_COMM_WORLD.Get_rank() == 0:
        for rank, result in enumerate(results):
            print hline
            print 'MAIN TESTS RESULTS FOR RANK ' + str(rank) + ':'
            print hline
            print str(result)
