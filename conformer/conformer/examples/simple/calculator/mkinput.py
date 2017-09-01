#!/usr/bin/env python

import netCDF4 as nc
import numpy as np

input_dir = "input"

# Unlimited dimensions
unlimited = {"TIME"}

# Dimension Sizes
dimsizes = {"HORZ": 10, "VERT": 8, "TIME": 12}

# Variable Dimensions
vardims = {"U": ("TIME", "VERT", "HORZ"),
           "V": ("TIME", "VERT", "HORZ")}

# Data Types
datatypes = {"HORZ": np.float32,
             "VERT": np.float32,
             "TIME": np.float32,
             "U": np.float64,
             "V": np.float64}

# Data
data = {}
for name, datatype in datatypes.iteritems():
    if name in dimsizes:
        data[name] = np.arange(dimsizes[name], dtype=datatype)
    elif name in vardims:
        vshape = tuple(dimsizes[d] for d in vardims[name])
        data[name] = 200.0 * np.random.rand(*vshape).astype(datatype) - 100.0
    else:
        raise "Variable {!r} not found".format(name)

# Attributes
attribs = {"HORZ": {"standard_name": "horizontal distance",
                    "units": "km"},
           "VERT": {"standard_name": "vertical distance",
                    "units": "km"},
           "TIME": {"standard_name": "time",
                    "units": "hours"},
           "U": {"standard_name": "Variable U",
                 "units": "g"},
           "V": {"standard_name": "Variable V",
                 "units": "g"}}

# Output files
varfiles = {"U": "{}/uvariable.nc".format(input_dir),
            "V": "{}/vvariable.nc".format(input_dir)}

# Write the data files
for vname, fname in varfiles.iteritems():
    with nc.Dataset(fname, 'w') as ncf:

        ncf.setncatts({'attrib1': 'Attribute 1',
                       'attrib2': 'Attribute 2'})

        for dname in vardims[vname]:
            if dname in unlimited:
                ncf.createDimension(dname)
            else:
                ncf.createDimension(dname, dimsizes[dname])

        for dname in vardims[vname]:
            var = ncf.createVariable(dname, datatypes[dname], (dname,))
            for aname, aval in attribs[dname].iteritems():
                var.setncattr(aname, aval)
            var[:] = data[dname]

        var = ncf.createVariable(vname, datatypes[vname], vardims[vname])
        for aname, aval in attribs[vname].iteritems():
            var.setncattr(aname, aval)
        var[:] = data[vname]
