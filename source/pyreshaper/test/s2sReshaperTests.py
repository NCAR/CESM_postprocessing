"""
Parallel Tests for the Reshaper class

Copyright 2015, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

import unittest

import sys
from glob import glob
from cStringIO import StringIO
from os import linesep as eol
from os import remove
from mpi4py import MPI

from pyreshaper.reshaper import Slice2SeriesReshaper, create_reshaper
from pyreshaper.specification import Specifier

import mkTestData

MPI_COMM_WORLD = MPI.COMM_WORLD


class S2SReshaperTests(unittest.TestCase):

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

    def _run_convert(self, infiles, prefix, suffix, metadata,
                     ncfmt, clevel, serial, verbosity, wmode, once,
                     print_diags=False):
        if not (serial and self.rank > 0):
            spec = Specifier(infiles=infiles, ncfmt=ncfmt, compression=clevel,
                             prefix=prefix, suffix=suffix, metadata=metadata)
            rshpr = create_reshaper(spec, serial=serial,
                                    verbosity=verbosity,
                                    wmode=wmode, once=once)
            rshpr.convert()
            if print_diags:
                rshpr.print_diagnostics()
        MPI_COMM_WORLD.Barrier()

    def _run_convert_assert_no_output(self, infiles, prefix, suffix, metadata,
                                      ncfmt, clevel, serial, verbosity, wmode,
                                      once, print_diags=False):
        oldout = sys.stdout
        newout = StringIO()
        sys.stdout = newout
        self._run_convert(infiles, prefix, suffix, metadata, ncfmt, clevel,
                          serial, 0, wmode, once, print_diags=False)
        actual = newout.getvalue()
        self._assertion("stdout empty", actual, '')
        sys.stdout = oldout

    def _test_create_reshaper(self, serial, verbosity, wmode):
        self._test_header(("create_reshaper(serial={0}, verbosity={1}, "
                           "wmode={2!r})").format(serial, verbosity, wmode))
        if not (serial and self.rank > 0):
            spec = Specifier(infiles=mkTestData.slices, ncfmt='netcdf',
                             compression=0, prefix='output.', suffix='.nc',
                             metadata=[])
            rshpr = create_reshaper(spec, serial=serial, verbosity=verbosity,
                                    wmode=wmode)
            self._assertion("type(reshaper)", type(rshpr),
                            Slice2SeriesReshaper)

    def test_create_reshaper_serial_V0_W(self):
        self._test_create_reshaper(serial=True, verbosity=0, wmode='w')

    def test_create_reshaper_serial_V1_W(self):
        self._test_create_reshaper(serial=True, verbosity=1, wmode='w')

    def test_create_reshaper_serial_V2_W(self):
        self._test_create_reshaper(serial=True, verbosity=2, wmode='w')

    def test_create_reshaper_serial_V1_O(self):
        self._test_create_reshaper(serial=True, verbosity=1, wmode='o')

    def test_create_reshaper_serial_V1_S(self):
        self._test_create_reshaper(serial=True, verbosity=1, wmode='s')

    def test_create_reshaper_serial_V1_A(self):
        self._test_create_reshaper(serial=True, verbosity=1, wmode='a')

    def test_create_reshaper_parallel_V1_W(self):
        self._test_create_reshaper(serial=False, verbosity=1, wmode='w')

    def test_convert_All_NC3_CL0_SER_V0_W(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': True, 'verbosity': 0, 'wmode': 'w', 'once': False,
                'print_diags': False}
        self._convert_header(**args)
        self._run_convert_assert_no_output(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_1_NC3_CL0_SER_V0_W(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices[0:1], 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': True, 'verbosity': 0, 'wmode': 'w', 'once': False,
                'print_diags': False}
        self._convert_header(**args)
        self._run_convert_assert_no_output(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC4_CL1_SER_V0_W(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf4', 'clevel': 1,
                'serial': True, 'verbosity': 0, 'wmode': 'w', 'once': False,
                'print_diags': False}
        self._convert_header(**args)
        self._run_convert_assert_no_output(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC3_CL0_PAR_V1_W(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 'w', 'once': False,
                'print_diags': False}
        self._convert_header(**args)
        self._run_convert(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC3_CL0_PAR_V1_W_ONCE(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 'w', 'once': True,
                'print_diags': False}
        self._convert_header(**args)
        self._run_convert(**args)
        if self.rank == 0:
            mkTestData.check_outfile(tsvar='once', **args)
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC3_CL0_PAR_V1_O(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 'o', 'once': False,
                'print_diags': False}
        self._convert_header(**args)
        self._run_convert(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC3_CL0_PAR_V1_O_ONCE(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 'o', 'once': True,
                'print_diags': False}
        self._convert_header(**args)
        self._run_convert(**args)
        if self.rank == 0:
            mkTestData.check_outfile(tsvar='once', **args)
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC3_CL0_PAR_V1_S(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 's', 'once': False,
                'print_diags': False}
        self._convert_header(**args)
        self._run_convert(**args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC3_CL0_PAR_V1_S_ONCE(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'infiles': mkTestData.slices, 'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'wmode': 's', 'once': True,
                'print_diags': False}
        self._convert_header(**args)
        self._run_convert(**args)
        if self.rank == 0:
            mkTestData.check_outfile(tsvar='once', **args)
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC3_CL0_PAR_V3_A(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'once': False,
                'print_diags': False}
        self._convert_header(infiles=mkTestData.slices, wmode='a', **args)
        self._run_convert(infiles=[mkTestData.slices[0]], wmode='w', **args)
        for infile in mkTestData.slices[1:]:
            self._run_convert(infiles=[infile], wmode='a', **args)
        if self.rank == 0:
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(infiles=mkTestData.slices, tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC3_CL0_PAR_V3_A_ONCE(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'once': True,
                'print_diags': False}
        self._convert_header(infiles=mkTestData.slices, wmode='a', **args)
        self._run_convert(infiles=[mkTestData.slices[0]], wmode='w', **args)
        for infile in mkTestData.slices[1:]:
            self._run_convert(infiles=[infile], wmode='a', **args)
        if self.rank == 0:
            mkTestData.check_outfile(infiles=mkTestData.slices, tsvar='once', **args)
            for tsvar in mkTestData.tsvars:
                mkTestData.check_outfile(infiles=mkTestData.slices, tsvar=tsvar, **args)
        MPI_COMM_WORLD.Barrier()

    def test_convert_All_NC3_CL0_PAR_V3_A_MISSING(self):
        mdata = [v for v in mkTestData.tvmvars]
        mdata.append('time')
        args = {'prefix': 'out.', 'suffix': '.nc',
                'metadata': mdata, 'ncfmt': 'netcdf', 'clevel': 0,
                'serial': False, 'verbosity': 1, 'once': False,
                'print_diags': False}
        missingvar = mkTestData.tsvars[2]
        self._convert_header(infiles=mkTestData.slices, wmode='a', **args)
        self._run_convert(infiles=[mkTestData.slices[0]], wmode='w', **args)
        self._run_convert(infiles=[mkTestData.slices[1]], wmode='a', **args)
        remove(args['prefix'] + missingvar + args['suffix'])
        for infile in mkTestData.slices[2:]:
            self._run_convert(infiles=[infile], wmode='a', **args)
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
    tests = unittest.TestLoader().loadTestsFromTestCase(S2SReshaperTests)
    unittest.TextTestRunner(stream=mystream).run(tests)
    MPI_COMM_WORLD.Barrier()

    results = MPI_COMM_WORLD.gather(mystream.getvalue())
    if MPI_COMM_WORLD.Get_rank() == 0:
        for rank, result in enumerate(results):
            print hline
            print 'TESTS RESULTS FOR RANK ' + str(rank) + ':'
            print hline
            print str(result)
