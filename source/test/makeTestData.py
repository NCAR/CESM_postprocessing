"""
Copyright 2017, University Corporation for Atmospheric Research
See LICENSE.txt for details
"""

import os
import numpy as np
from pyreshaper import iobackend


# Dataset Information
nlat = 19
nlon = 36
ntime = 10
nchar = 7
slices = ['input{0}.nc'.format(i) for i in xrange(5)]
scalars = ['scalar{0}'.format(i) for i in xrange(2)]
chvars = ['char{0}'.format(i) for i in xrange(1)]
timvars = ['tim{0}'.format(i) for i in xrange(2)]
xtimvars = ['tim{0}'.format(i) for i in xrange(2, 5)]
tvmvars = ['tvm{0}'.format(i) for i in xrange(2)]
tsvars = ['tsvar{0}'.format(i) for i in xrange(4)]
fattrs = {'attr1': 'attribute one',
          'attr2': 'attribute two'}


#=========================================================================
# generate_data
#=========================================================================
def generate_data(backend='netCDF4'):
    """
    Generate dataset for testing purposes
    """
    iobackend.set_backend(backend)

    # Test Data Generation
    for i in xrange(len(slices) + 1):

        # Open the file for writing
        fname = slices[i] if i < len(slices) else 'metafile.nc'
        fobj = iobackend.NCFile(fname, mode='w')

        # Write attributes to file
        for name, value in fattrs.iteritems():
            fobj.setncattr(name, value)

        # Create the dimensions in the file
        fobj.create_dimension('lat', nlat)
        fobj.create_dimension('lon', nlon)
        fobj.create_dimension('time', None)
        fobj.create_dimension('strlen', nchar)

        # Create the coordinate variables & add attributes
        lat = fobj.create_variable('lat', 'f', ('lat',))
        lon = fobj.create_variable('lon', 'f', ('lon',))
        time = fobj.create_variable('time', 'f', ('time',))

        # Set the coordinate variable attributes
        lat.setncattr('long_name', 'latitude')
        lat.setncattr('units', 'degrees_north')

        lon.setncattr('long_name', 'longitude')
        lon.setncattr('units', 'degrees_east')

        time.setncattr('long_name', 'time')
        time.setncattr('units', 'days since 01-01-0001')
        time.setncattr('calendar', 'noleap')

        # Set the values of the coordinate variables
        lat[:] = np.linspace(-90, 90, nlat, dtype=np.float32)
        lon[:] = np.linspace(-180, 180, nlon, endpoint=False, dtype=np.float32)
        time[:] = np.arange(i * ntime, (i + 1) * ntime, dtype=np.float32)

        # Create the scalar variables
        for n in xrange(len(scalars)):
            vname = scalars[n]
            v = fobj.create_variable(vname, 'd', tuple())
            v.setncattr('long_name', 'scalar{0}'.format(n))
            v.setncattr('units', '[{0}]'.format(vname))
            v.assign_value(np.float64(n * 10))

        # Create the time-invariant metadata variables
        all_timvars = timvars + ([] if i < len(slices) else xtimvars)
        for n in xrange(len(all_timvars)):
            vname = all_timvars[n]
            v = fobj.create_variable(vname, 'd', ('lat', 'lon'))
            v.setncattr('long_name', 'time-invariant metadata {0}'.format(n))
            v.setncattr('units', '[{0}]'.format(vname))
            v[:] = np.ones((nlat, nlon), dtype=np.float64) * n

        # Create the time-variant character variables
        for n in xrange(len(chvars)):
            vname = chvars[n]
            v = fobj.create_variable(vname, 'c', ('time', 'strlen'))
            v.setncattr('long_name', 'character array {0}'.format(n))
            vdata = [str((n + 1) * m) * (m + 1) for m in xrange(ntime)]
            v[:] = np.array(vdata, dtype='S{}'.format(
                nchar)).view('S1').reshape(ntime, nchar)

        # Create the time-variant metadata variables
        for n in xrange(len(tvmvars)):
            vname = tvmvars[n]
            v = fobj.create_variable(vname, 'd', ('time', 'lat', 'lon'))
            v.setncattr('long_name', 'time-variant metadata {0}'.format(n))
            v.setncattr('units', '[{0}]'.format(vname))
            v[:] = np.ones((ntime, nlat, nlon), dtype=np.float64) * n

        # Create the time-series variables
        for n in xrange(len(tsvars)):
            vname = tsvars[n]
            v = fobj.create_variable(
                vname, 'd', ('time', 'lat', 'lon'), fill_value=1e36)
            v.setncattr('long_name', 'time-series variable {0}'.format(n))
            v.setncattr('units', '[{0}]'.format(vname))
            v.setncattr('missing_value', 1e36)
            vdata = np.ones((ntime, nlat, nlon), dtype=np.float64) * n
            vmask = np.random.choice(
                [True, False], ntime * nlat * nlon).reshape(ntime, nlat, nlon)
            v[:] = np.ma.MaskedArray(vdata, mask=vmask)


#=========================================================================
# check_outfile
#=========================================================================
def check_outfile(infiles, prefix, tsvar, suffix, metadata, once, **kwds):
    """
    Check that a PyReshaper generated output file is correct
    """

    assertions = {}

    def _assert(key, value):
        assertions[key] = value

    outfile = '{0}{1}{2}'.format(prefix, tsvar, suffix)
    _assert('{0!r} exists'.format(outfile), os.path.exists(outfile))
    if not os.path.exists(outfile):
        return assertions
    ncout = iobackend.NCFile(outfile)

    if 'meta1d' in kwds and kwds['meta1d'] is True:
        metadata.append('time')

    if 'metafile' in kwds and kwds['metafile']:
        metafile = iobackend.NCFile('metafile.nc')
        _assert('{0}: Extra time-invariant metadata found'.format(outfile),
                set(xtimvars).issubset(set(ncout.variables.keys())))
        for v in xtimvars:
            _assert('{0}: Extra time-invariant metadata dimensions'.format(outfile),
                    ncout.variables[v].dimensions == ('lat', 'lon'))
    else:
        metafile = None

    series_step = 0
    for infile in infiles:
        _assert('{0!r} exists'.format(infile), os.path.exists(infile))
        if not os.path.exists(infile):
            return assertions

        ncinp = iobackend.NCFile(infile)
        nsteps = ncinp.dimensions['time']
        if infile == infiles[0]:
            scvars = [
                v for v in ncinp.variables if ncinp.variables[v].dimensions == ()]
            tivars = [
                v for v in ncinp.variables if 'time' not in ncinp.variables[v].dimensions]
            tsvars = [
                v for v in ncinp.variables if 'time' in ncinp.variables[v].dimensions and v not in metadata]
            if once:
                tsvars.append('once')

            outdims = {
                'lat': ncinp.dimensions['lat'], 'lon': ncinp.dimensions['lon'], 'strlen': ncinp.dimensions['strlen']}

            outmeta = [v for v in ncinp.variables if v not in tsvars]

            _assert('{0}: variable {1!r} found in input'.format(
                outfile, tsvar), tsvar in tsvars)
            _assert('{0}: global attribute names equal'.format(
                outfile), ncout.ncattrs == ncinp.ncattrs)
            for a in set(ncout.ncattrs).intersection(set(ncinp.ncattrs)):
                _assert('{0}: global attribute {1} values equal'.format(
                    outfile, a), ncout.getncattr(a) == ncinp.getncattr(a))
            for d, v in outdims.iteritems():
                _assert("{0}: {1!r} in dimensions".format(
                    outfile, d), d in ncout.dimensions)
                _assert("{0}: dimensions[{1!r}]".format(
                    outfile, d), ncout.dimensions[d] == v)
            _assert("{0}: 'time' in dimensions".format(
                outfile), 'time' in ncout.dimensions)
            _assert("{0}: 'time' unlimited".format(
                outfile), ncout.unlimited('time'))
            if once:
                all_vars = outmeta if tsvar == 'once' else [tsvar]
            else:
                all_vars = [tsvar] + outmeta
            if metafile:
                all_vars += xtimvars
            _assert("{0}: variable names same".format(outfile),
                    set(ncout.variables.keys()) == set(all_vars))
            for v in all_vars:
                if v in scvars:
                    expected = ()
                elif v in ncinp.dimensions:
                    expected = (v,)
                elif v in tivars + xtimvars:
                    expected = ('lat', 'lon')
                elif v in chvars:
                    expected = ('time', 'strlen')
                else:
                    expected = ('time', 'lat', 'lon')
                _assert("{0}: {1}.dimemsions equal".format(outfile, v),
                        ncout.variables[v].dimensions == expected)

        for v in all_vars:
            if v in xtimvars:
                expected = metafile.variables[v].get_value()
            else:
                expected = ncinp.variables[v].get_value()
            if v == 'time':
                oslice = slice(series_step, series_step + nsteps)
                actual = ncout.variables[v][oslice]
            elif 'time' in ncout.variables[v].dimensions:
                oslice = [slice(None)] * (2 if v in chvars else 3)
                oslice[0] = slice(series_step, series_step + nsteps)
                actual = ncout.variables[v][tuple(oslice)]
            else:
                actual = ncout.variables[v].get_value()
            _assert(("{0}: {1!r} values equal").format(
                outfile, v), np.all(actual == expected))

        series_step += nsteps
        ncinp.close()
    if metafile:
        metafile.close()
    ncout.close()

    return assertions


def check_var_in(var, fname):
    ncf = iobackend.NCFile(fname)
    value = var in ncf.variables
    ncf.close()
    return value
