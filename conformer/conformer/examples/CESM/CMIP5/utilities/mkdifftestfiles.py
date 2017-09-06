#!/usr/bin/env python

import netCDF4 as nc

fdesc = {'a.nc': [{'ga1': 'global attrib 1',
                   'ga2': 'global attrib 2',
                   'ga3': 'global attrib 3'},
                  {'x': 4, 't': None},
                  {'x': ('d', ('x',), {'name': 'space', 'units': 'm'}, range(4)),
                   't': ('d', ('t',), {'name': 'time', 'units': 's'}, range(3)),
                   'v': ('f', ('x','t'), {'name': 'var', 'units': 'K'}, [range(3)]*4)}],
         'b.nc': [{'ga1': 'global attrib 1',
                   'ga2': 'Global Attrib 2'},
                  {'x': 4, 'y': 2, 't': None},
                  {'x': ('d', ('x',), {'name': 'space', 'units': 'm'}, [0,1,2,5]),
                   'y': ('d', ('y',), {'name': 'space2', 'units': 'm'}, range(2)),
                   't': ('f', ('t',), {'name': 'Time', 'units': 's'}, range(3)),
                   'v': ('f', ('x','t'), {'name': 'var', 'units': 'K', 'type': 'vartype'}, [range(3)]*4),
                   'u': ('f', ('x','y','t'), {'name': 'var2', 'units': 'Pa'}, [[range(3)]*2]*4)}]}

for fname in fdesc:
    f = nc.Dataset(fname, 'w')
    fatts, fdims, fvars = fdesc[fname]
    for a in fatts:
        f.setncattr(a, fatts[a])
    for d in fdims:
        f.createDimension(d, fdims[d])
    for v in fvars:
        vobj = f.createVariable(v, fvars[v][0], fvars[v][1])
        for va in fvars[v][2]:
            vobj.setncattr(va, fvars[v][2][va])
        vobj[:] = fvars[v][3]
    f.close()
