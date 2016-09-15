"""
Copyright 2015, University Corporation for Atmospheric Research
See LICENSE.txt for details
"""

import imp
import unittest
import cPickle as pickle
from glob import glob
from cStringIO import StringIO
from os import linesep as eol
from os import remove
from mpi4py import MPI

from pyreshaper.specification import Specifier

import mkTestData

s2srun = imp.load_source('s2srun', '../../../scripts/s2srun')

MPI_COMM_WORLD = MPI.COMM_WORLD


class s2srunTest(unittest.TestCase):

    def setUp(self):

        # Parallel Management - Just for Tests
        self.rank = MPI_COMM_WORLD.Get_rank()
        self.size = MPI_COMM_WORLD.Get_size()

        # Test Data Generation
        self._clean_directory()
        if self.rank == 0:
            mkTestData.generate_data()
        MPI_COMM_WORLD.Barrier()

    def tearDown(self):
        self._clean_directory()

    def _clean_directory(self):
        if self.rank == 0:
            for ncfile in glob('*.nc'):
                remove(ncfile)
        MPI_COMM_WORLD.Barrier()

    def _test_header(self, testname):
        if self.rank == 0:
            hline = '-' * 70
            print hline
            print testname
            print hline

    def _convert_header(self, infiles, prefix, suffix, metadata,
                        ncfmt, clevel, serial, verbosity, wmode, once,
                        print_diags=False):
        nfiles = len(infiles)
        ncvers = '3' if ncfmt == 'netcdf' else ('4c' if ncfmt == 'netcdf4c'
                                                else '4')
        self._test_header(("convert() - {0} infile(s), NC{1}-CL{2}, serial={3},{4}"
                           "            verbosity={5}, wmode={6!r}, once={7}"
                           "").format(nfiles, ncvers, clevel, serial, eol,
                                      verbosity, wmode, once))

    def _assertion(self, name, actual, expected,
                   data=None, show=True, assertion=None):
        rknm = '[{0}/{1}] {2}'.format(self.rank, self.size, name)
        spcr = ' ' * len(rknm)
        msg = eol + rknm
        if data:
            msg += ' - Input:    {0}'.format(data) + eol + spcr
        msg += ' - Actual:   {0}'.format(actual) + eol + spcr
        msg += ' - Expected: {0}'.format(expected)
        if show:
            print msg
        if assertion:
            assertion(actual, expected, msg)
        else:
            self.assertEqual(actual, expected, msg)

    def _run_main(self, infiles, prefix, suffix, metadata,
                  ncfmt, clevel, serial, verbosity, wmode, once):
        if not (serial and self.rank > 0):
            spec = Specifier(infiles=infiles, ncfmt=ncfmt, compression=clevel,
                             prefix=prefix, suffix=suffix, metadata=metadata)
            specfile = 'input.s2s'
            pickle.dump(spec, open(specfile, 'wb'))
            argv = ['-v', str(verbosity), '-m', wmode]
            if once:
                argv.append('-s')
            argv.append(specfile)
            s2srun.main(argv)
            remove(specfile)
        MPI_COMM_WORLD.Barrier()

    def test_CLI_empty(self):
        argv = []
        self.assertRaises(ValueError, s2srun.cli, argv)

    def test_CLI_help(self):
        argv = ['-h']
        self.assertRaises(SystemExit, s2srun.cli, argv)

    def test_CLI_defaults(self):
        argv = ['s2srunTests.py']
        opts, opts_specfile = s2srun.cli(argv)
        self.assertFalse(opts.once,
                         'Once-file is set')
        self.assertEqual(opts.limit, 0,
                         'Output limit is set')
        self.assertEqual(opts.write_mode, 'w',
                         'Write mode is not "w"')
        self.assertFalse(opts.serial,
                         'Serial mode is set')
        self.assertEqual(opts.verbosity, 1,
                         'Verbosity is not 1')
        self.assertEqual(opts_specfile, argv[0],
                         'Specfile name is not set')

    def test_CLI_set_all_short(self):
        once = True
        limit = 3
        write_mode = 'x'
        serial = True
        verbosity = 5
        specfile = 'myspec.s2s'

        argv = []
        if once:
            argv.append('-1')
        argv.extend(['-l', str(limit)])
        argv.extend(['-m', str(write_mode)])
        if serial:
            argv.append('-s')
        argv.extend(['-v', str(verbosity)])
        argv.append(specfile)
        opts, opts_specfile = s2srun.cli(argv)

        self.assertEqual(opts.once, once,
                         'Once-file is not {0!r}'.format(once))
        self.assertEqual(opts.limit, limit,
                         'Output limit is not {0!r}'.format(limit))
        self.assertEqual(opts.write_mode, write_mode,
                         'Write mode is not {0!r}'.format(write_mode))
        self.assertEqual(opts.serial, serial,
                         'Serial mode is not {0!r}'.format(serial))
        self.assertEqual(opts.verbosity, verbosity,
                         'Verbosity is not {0!r}'.format(verbosity))
        self.assertEqual(opts_specfile, specfile,
                         'Specfile name is not {0!r}'.format(specfile))

    def test_CLI_set_all_long(self):
        once = True
        limit = 3
        write_mode = 'x'
        serial = True
        verbosity = 5
        specfile = 'myspec.s2s'

        argv = []
        if once:
            argv.append('--once')
        argv.extend(['--limit', str(limit)])
        argv.extend(['--write_mode', str(write_mode)])
        if serial:
            argv.append('--serial')
        argv.extend(['--verbosity', str(verbosity)])
        argv.append(specfile)
        opts, opts_specfile = s2srun.cli(argv)

        self.assertEqual(opts.once, once,
                         'Once-file is not {0!r}'.format(once))
        self.assertEqual(opts.limit, limit,
                         'Output limit is not {0!r}'.format(limit))
        self.assertEqual(opts.write_mode, write_mode,
                         'Write mode is not {0!r}'.format(write_mode))
        self.assertEqual(opts.serial, serial,
                         'Serial mode is not {0!r}'.format(serial))
        self.assertEqual(opts.verbosity, verbosity,
                         'Verbosity is not {0!r}'.format(verbosity))
        self.assertEqual(opts_specfile, specfile,
                         'Specfile name is not {0!r}'.format(specfile))

    def test_main_All_NC3_CL0_SER_V0_W(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': True, 'verbosity': 0, 'wmode': 'w', 'once': False}
        self._convert_header(**args)
        self._run_main(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_1_NC3_CL0_SER_V0_W(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices[0:1], 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': True, 'verbosity': 0, 'wmode': 'w', 'once': False}
        self._convert_header(**args)
        self._run_main(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC4_CL1_SER_V0_W(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf4', 'clevel': 1,
                'serial': True, 'verbosity': 0, 'wmode': 'w', 'once': False}
        self._convert_header(**args)
        self._run_main(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC3_CL0_PAR_V1_W(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 'w', 'once': False}
        self._convert_header(**args)
        self._run_main(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC3_CL0_PAR_V1_W_ONCE(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 'w', 'once': True}
        self._convert_header(**args)
        self._run_main(**args)
        if self.rank == 0:
            mkTestData.check_outfile(tsvar='once', **args)
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC3_CL0_PAR_V1_O(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 'o', 'once': False}
        self._convert_header(**args)
        self._run_main(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC3_CL0_PAR_V1_O_ONCE(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 'o', 'once': True}
        self._convert_header(**args)
        self._run_main(**args)
        if self.rank == 0:
            mkTestData.check_outfile(tsvar='once', **args)
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC3_CL0_PAR_V1_S(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 's', 'once': False}
        self._convert_header(**args)
        self._run_main(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC3_CL0_PAR_V1_S_ONCE(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 's', 'once': True}
        self._convert_header(**args)
        self._run_main(**args)
        if self.rank == 0:
            mkTestData.check_outfile(tsvar='once', **args)
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC3_CL0_PAR_V3_A(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'once': False}
        self._convert_header(infiles=mkTestData.slices, wmode='a', **args)
        self._run_main(infiles=[mkTestData.slices[0]], wmode='w', **args)
        for infile in mkTestData.slices[1:]:
            self._run_main(infiles=[infile], wmode='a', **args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(infiles=mkTestData.slices, tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC3_CL0_PAR_V3_A_ONCE(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'once': True}
        self._convert_header(infiles=mkTestData.slices, wmode='a', **args)
        self._run_main(infiles=[mkTestData.slices[0]], wmode='w', **args)
        for infile in mkTestData.slices[1:]:
            self._run_main(infiles=[infile], wmode='a', **args)
        if self.rank == 0:
            mkTestData.check_outfile(infiles=mkTestData.slices, tsvar='once', **args)
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(infiles=mkTestData.slices, tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_main_All_NC3_CL0_PAR_V3_A_MISSING(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'once': False}
        missingvar = mkTestData.tsvars[2]
        self._convert_header(infiles=mkTestData.slices, wmode='a', **args)
        self._run_main(infiles=[mkTestData.slices[0]], wmode='w', **args)
        self._run_main(infiles=[mkTestData.slices[1]], wmode='a', **args)
        remove(args['prefix'] + missingvar + args['suffix'])
        for infile in mkTestData.slices[2:]:
            self._run_main(infiles=[infile], wmode='a', **args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                if tsvar == missingvar:
                    mkTestData.check_outfile(infiles=mkTestData.slices[2:], tsvar=tsvar, **args)
                else:
                    mkTestData.check_outfile(infiles=mkTestData.slices, tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()


if __name__ == "__main__":
    hline = '=' * 70
    if MPI_COMM_WORLD.Get_rank() == 0:
        print hline
        print 'STANDARD OUTPUT FROM ALL TESTS:'
        print hline
    MPI_COMM_WORLD.Barrier()

    mystream = StringIO()
    tests = unittest.TestLoader().loadTestsFromTestCase(s2srunTest)
    unittest.TextTestRunner(stream=mystream).run(tests)
    MPI_COMM_WORLD.Barrier()

    results = MPI_COMM_WORLD.gather(mystream.getvalue())
    if MPI_COMM_WORLD.Get_rank() == 0:
        for rank, result in enumerate(results):
            print hline
            print 'TESTS RESULTS FOR RANK ' + str(rank) + ':'
            print hline
            print str(result)
