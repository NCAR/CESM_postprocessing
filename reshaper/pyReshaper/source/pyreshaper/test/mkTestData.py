"""
Copyright 2015, University Corporation for Atmospheric Research
See LICENSE.txt for details
"""

import os
import numpy as np
import Nio

# Dataset Information
nlat = 19
nlon = 36
ntime = 10
slices = ['input{0}.nc'.format(i) for i in xrange(5)]
scalars = ['scalar{0}'.format(i) for i in xrange(2)]
timvars = ['tim{0}'.format(i) for i in xrange(2)]
tvmvars = ['tvm{0}'.format(i) for i in xrange(2)]
tsvars = ['tsvar{0}'.format(i) for i in xrange(4)]
fattrs = {'attr1': 'attribute one',
          'attr2': 'attribute two'}


def generate_data():
    """
    Generate dataset for testing purposes
    """

    # Test Data Generation
    for i in xrange(len(slices)):

        # Open the file for writing
        fname = slices[i]
        fobj = Nio.open_file(fname, 'w')

        # Write attributes to file
        for name, value in fattrs.iteritems():
            setattr(fobj, name, value)

        # Create the dimensions in the file
        fobj.create_dimension('lat', nlat)
        fobj.create_dimension('lon', nlon)
        fobj.create_dimension('time', None)

        # Create the coordinate variables & add attributes
        lat = fobj.create_variable('lat', 'f', ('lat',))
        lon = fobj.create_variable('lon', 'f', ('lon',))
        time = fobj.create_variable('time', 'f', ('time',))

        # Set the coordinate variable attributes
        setattr(lat, 'long_name', 'latitude')
        setattr(lon, 'long_name', 'longitude')
        setattr(time, 'long_name', 'time')
        setattr(lat, 'units', 'degrees north')
        setattr(lon, 'units', 'degrees east')
        setattr(time, 'units', 'days from 01-01-0001')

        # Set the values of the coordinate variables
        lat[:] = np.linspace(-90, 90, nlat, dtype=np.float32)
        lon[:] = np.linspace(-180, 180, nlon, endpoint=False, dtype=np.float32)
        time[:] = np.arange(i * ntime, (i + 1) * ntime, dtype=np.float32)

        # Create the scalar variables
        for n in xrange(len(scalars)):
            vname = scalars[n]
            v = fobj.create_variable(vname, 'd', ())
            setattr(v, 'long_name', 'scalar{0}'.format(n))
            setattr(v, 'units', '[{0}]'.format(vname))
            v.assign_value(np.float64(n * 10))

        # Create the time-invariant metadata variables
        for n in xrange(len(timvars)):
            vname = timvars[n]
            v = fobj.create_variable(vname, 'd', ('lat', 'lon'))
            setattr(v, 'long_name', 'time-invariant metadata {0}'.format(n))
            setattr(v, 'units', '[{0}]'.format(vname))
            v[:] = np.ones((nlat, nlon), dtype=np.float64) * n

        # Create the time-variant metadata variables
        for n in xrange(len(tvmvars)):
            vname = tvmvars[n]
            v = fobj.create_variable(vname, 'd', ('time', 'lat', 'lon'))
            setattr(v, 'long_name', 'time-variant metadata {0}'.format(n))
            setattr(v, 'units', '[{0}]'.format(vname))
            v[:] = np.ones((ntime, nlat, nlon), dtype=np.float64) * n

        # Create the time-series variables
        for n in xrange(len(tsvars)):
            vname = tsvars[n]
            v = fobj.create_variable(vname, 'd', ('time', 'lat', 'lon'))
            setattr(v, 'long_name', 'time-series variable {0}'.format(n))
            setattr(v, 'units', '[{0}]'.format(vname))
            v[:] = np.ones((ntime, nlat, nlon), dtype=np.float64) * n


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
    ncout = Nio.open_file(outfile, 'r')

    series_step = 0
    for infile in infiles:
        _assert('{0!r} exists'.format(infile), os.path.exists(infile))
        if not os.path.exists(infile):
            return assertions
        ncinp = Nio.open_file(infile, 'r')
        nsteps = ncinp.dimensions['time']
        if infile == infiles[0]:
            scalars = [v for v in ncinp.variables
                       if ncinp.variables[v].dimensions == ()]
            tivars = [v for v in ncinp.variables
                      if 'time' not in ncinp.variables[v].dimensions]
            tsvars = [v for v in ncinp.variables
                      if 'time' in ncinp.variables[v].dimensions and
                      v not in metadata]
            if once:
                tsvars.append('once')

            outdims = {'lat': ncinp.dimensions['lat'],
                       'lon': ncinp.dimensions['lon']}

            outmeta = [v for v in ncinp.variables if v not in tsvars]

            _assert('{0}: variable {1!r} exists'.format(outfile, tsvar),
                    tsvar in tsvars)
            _assert('{0}: attributes equal'.format(outfile),
                    ncout.attributes == ncinp.attributes)
            for d, v in outdims.iteritems():
                _assert("{0}: {1!r} in dimensions".format(outfile, d),
                        d in ncout.dimensions)
                _assert("{0}: dimensions[{1!r}]".format(outfile, d),
                        ncout.dimensions[d] == v)
            _assert("{0}: 'time' in dimensions".format(outfile),
                    'time' in ncout.dimensions)
            _assert("{0}: 'time' unlimited".format(outfile),
                    ncout.unlimited('time'))
            if once:
                all_vars = outmeta if tsvar == 'once' else [tsvar]
            else:
                all_vars = [tsvar] + outmeta
            _assert("{0}: variable set".format(outfile),
                    set(ncout.variables.keys()) == set(all_vars))
            for v in all_vars:
                if v in scalars:
                    expected = ()
                elif v in ncinp.dimensions:
                    expected = (v,)
                elif v in tivars:
                    expected = ('lat', 'lon')
                else:
                    expected = ('time', 'lat', 'lon')
                _assert("{0}: {1}.dimemsions equal".format(outfile, v),
                        ncout.variables[v].dimensions == expected)

        for v in all_vars:
            expected = ncinp.variables[v].get_value()
            if v == 'time':
                oslice = slice(series_step, series_step + nsteps)
                actual = ncout.variables[v][oslice]
            elif 'time' in ncout.variables[v].dimensions:
                oslice = [slice(None)] * 3
                oslice[0] = slice(series_step, series_step + nsteps)
                actual = ncout.variables[v][tuple(oslice)]
            else:
                actual = ncout.variables[v].get_value()
            _assert(("{0}: {1!r} values equal").format(outfile, v),
                    np.all(actual == expected))

        series_step += nsteps
        ncinp.close()
    ncout.close()

    return assertions
