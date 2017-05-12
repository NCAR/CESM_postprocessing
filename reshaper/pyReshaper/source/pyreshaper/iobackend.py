"""
The module containing the PyReshaper configuration specification class

This is a configuration specification class, through which the input to
the PyReshaper code is specified.  Currently all types of supported
operations for the PyReshaper are specified with derived dypes of the
Specification class.

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

import numpy

try:
    _dict_ = __import__('collections', fromlist=['OrderedDict']).OrderedDict
except:
    try:
        _dict_ = __import__('ordereddict', fromlist=['OrderedDict']).OrderedDict
    except:
        _dict_ = dict


_AVAILABLE_ = []
_BACKEND_MAP_ = {}

_BACKEND_ = None
_IOLIB_ = None

# FIRST PREFERENCE
try:
    _NC4_ = __import__('netCDF4')
except:
    _NC4_ = None
if _NC4_ is not None:
    _AVAILABLE_.append('netCDF4')
    _BACKEND_MAP_['netCDF4'] = _NC4_
    if hasattr(_NC4_, '._netCDF4'):
        _NC4_VAR_ = _NC4_._netCDF4.Variable
    else:
        _NC4_VAR_ = _NC4_.Variable

# SECOND PREFERENCE
try:
    _NIO_ = __import__('Nio')
except:
    _NIO_ = None
if _NIO_ is not None:
    _AVAILABLE_.append('Nio')
    _BACKEND_MAP_['Nio'] = _NIO_


#===============================================================================
# is_available
#===============================================================================
def is_available(name=None):
    if name is None:
        return len(_AVAILABLE_) > 0
    else:
        return name in _BACKEND_MAP_


#===============================================================================
# set_backend - Set the backend to the one named or first preferred
#===============================================================================
def set_backend(name=None):
    global _BACKEND_
    global _IOLIB_
    if name is None:
        if is_available():
            _BACKEND_ = _AVAILABLE_[0]
            _IOLIB_ = _BACKEND_MAP_[_BACKEND_]
        else:
            raise RuntimeError('No I/O Backends available')
    else:
        if is_available(name):
            _BACKEND_ = name
            _IOLIB_ = _BACKEND_MAP_[name]
        else:
            raise KeyError('I/O Backend {0!r} not available'.format(name))

# Set Default backend
set_backend()


#===============================================================================
# get_backend - Get the currently set backend name
#===============================================================================
def get_backend():
    return _BACKEND_


#===============================================================================
# NCFile
#===============================================================================
class NCFile(object):
    """
    Wrapper class for netCDF files/datasets
    """

    def __init__(self, filename, mode='r', ncfmt='netcdf4', compression=0):
        """
        Initializer
        
        Parameters:
            filename (str): Name of netCDF file to open
            mode (str): Write-mode ('r' for read, 'w' for write, 'a' for append)
            ncfmt (str): Format to use of the netcdf file, if being created
                ('netcdf' or 'netcdf4')
            compression (int): Level of compression to use when writing to this
                netcdf file
        """
        if not isinstance(filename, (str, unicode)):
            err_msg = "Netcdf filename must be a string"
            raise TypeError(err_msg)
        if not isinstance(mode, (str, unicode)):
            err_msg = "Netcdf write mode must be a string"
            raise TypeError(err_msg)
        if not isinstance(ncfmt, (str, unicode)):
            err_msg = "Netcdf file format must be a string"
            raise TypeError(err_msg)
        if not isinstance(compression, int):
            err_msg = "Netcdf file compression must be an integer"
            raise TypeError(err_msg)

        if mode not in ['r', 'w', 'a']:
            err_msg = ("Netcdf write mode {0!r} is not one of "
                       "'r', 'w', or 'a'").format(mode)
            raise ValueError(err_msg)
        if ncfmt not in ['netcdf', 'netcdf4', 'netcdf4c']:
            err_msg = ("Netcdf format {0!r} is not one of "
                       "'netcdf', 'netcdf4', or 'netcdf4c'").format(mode)
            raise ValueError(err_msg)
        if compression > 9 or compression < 0:
            err_msg = ("Netcdf compression level {0} is not in range "
                       "0 to 9").format(compression)
            raise ValueError(err_msg)

        self._mode = mode
        self._backend = get_backend()
        self._iolib = _IOLIB_

        self._file_opts = {}
        self._var_opts = {}

        if self._backend == 'Nio':
            file_options = _IOLIB_.options()
            file_options.PreFill = False
            if ncfmt == 'netcdf':
                file_options.Format = 'Classic'
            elif ncfmt == 'netcdf4':
                file_options.Format = 'NetCDF4Classic'
                file_options.CompressionLevel = compression
            elif ncfmt == 'netcdf4c':
                file_options.Format = 'NetCDF4Classic'
                file_options.CompressionLevel = 1
            self._file_opts = {"options": file_options}

            if mode == 'r':
                self._obj = self._iolib.open_file(filename)
            else:
                self._obj = self._iolib.open_file(filename, mode,
                                                  **self._file_opts)

        elif self._backend == 'netCDF4':
            if ncfmt == 'netcdf':
                self._file_opts["format"] = "NETCDF3_64BIT"
            elif ncfmt == 'netcdf4':
                self._file_opts["format"] = "NETCDF4_CLASSIC"
                if compression > 0:
                    self._var_opts["zlib"] = True
                    self._var_opts["complevel"] = int(compression)
            elif ncfmt == 'netcdf4c':
                self._file_opts["format"] = "NETCDF4_CLASSIC"
                self._var_opts["zlib"] = True
                self._var_opts["complevel"] = 1

            if mode == 'r':
                self._obj = self._iolib.Dataset(filename)
            else:
                self._obj = self._iolib.Dataset(filename, mode,
                                                **self._file_opts)

    @property
    def dimensions(self):
        """
        Return the dimension sizes dictionary
        """
        if self._backend == 'Nio':
            return self._obj.dimensions
        elif self._backend == 'netCDF4':
            return _dict_((n, len(d)) for n, d
                          in self._obj.dimensions.iteritems())
        else:
            return _dict_()

    def unlimited(self, name):
        """
        Return whether the dimension named is unlimited
        
        Parameters:
            name (str): Name of dimension
        """
        if self._backend == 'Nio':
            return self._obj.unlimited(name)
        elif self._backend == 'netCDF4':
            return self._obj.dimensions[name].isunlimited()

    @property
    def ncattrs(self):
        if self._backend == 'Nio':
            return self._obj.attributes.keys()
        elif self._backend == 'netCDF4':
            return self._obj.ncattrs()

    def getncattr(self, name):
        if self._backend == 'Nio':
            return self._obj.attributes[name]
        elif self._backend == 'netCDF4':
            return self._obj.getncattr(name)

    def setncattr(self, name, value):
        if self._mode == 'r':
            raise RuntimeError('Cannot set attribute in read mode')
        if self._backend == 'Nio':
            setattr(self._obj, name, value)
        elif self._backend == 'netCDF4':
            self._obj.setncattr(name, value)

    @property
    def variables(self):
        return _dict_((n, NCVariable(v, self._mode)) for n, v
                      in self._obj.variables.iteritems())

    def create_dimension(self, name, value=None):
        if self._mode == 'r':
            raise RuntimeError('Cannot create dimension in read mode')
        if self._backend == 'Nio':
            self._obj.create_dimension(name, value)
        elif self._backend == 'netCDF4':
            self._obj.createDimension(name, value)

    def create_variable(self, name, datatype, dimensions):
        if self._mode == 'r':
            raise RuntimeError('Cannot create variable in read mode')
        if self._backend == 'Nio':
            dt = numpy.dtype(datatype)
            if dt.char == 'S':
                typecode = 'c'
            else:
                typecode = dt.char
            var = self._obj.create_variable(name, typecode, dimensions)
        elif self._backend == 'netCDF4':
            var = self._obj.createVariable(name, datatype, dimensions,
                                           **self._var_opts)
        return NCVariable(var, self._mode)

    def close(self):
        self._obj.close()


#===============================================================================
# NCVariable
#===============================================================================
class NCVariable(object):
    """
    Wrapper class for NetCDF variables
    """

    def __init__(self, vobj, mode='r'):
        self._mode = mode
        self._obj = vobj
        if _NC4_ is not None and isinstance(vobj, _NC4_VAR_):
            self._backend = 'netCDF4'
            self._iolib = _NC4_
        elif _NIO_ is not None:
            self._backend = 'Nio'
            self._iolib = _NIO_
        else:
            self._backend = None
            self._iolib = None

    @property
    def ncattrs(self):
        if self._backend == 'Nio':
            return self._obj.attributes.keys()
        elif self._backend == 'netCDF4':
            return self._obj.ncattrs()

    def getncattr(self, name):
        if self._backend == 'Nio':
            return self._obj.attributes[name]
        elif self._backend == 'netCDF4':
            return self._obj.getncattr(name)

    def setncattr(self, name, value):
        if self._mode == 'r':
            raise RuntimeError('Cannot set attribute in read mode')
        if self._backend == 'Nio':
            setattr(self._obj, name, value)
        elif self._backend == 'netCDF4':
            self._obj.setncattr(name, value)

    @property
    def dimensions(self):
        return self._obj.dimensions

    @property
    def shape(self):
        return self._obj.shape

    @property
    def size(self):
        if self._backend == 'Nio':
            return numpy.prod(self.shape)
        elif self._backend == 'netCDF4':
            return self._obj.size

    @property
    def datatype(self):
        if self._backend == 'Nio':
            return numpy.dtype(self._obj.typecode())
        elif self._backend == 'netCDF4':
            return self._obj.dtype

    def get_value(self):
        if self._backend == 'Nio':
            return self._obj.get_value()
        elif self._backend == 'netCDF4':
            if self._obj.shape == ():
                return self._obj.getValue()
            else:
                return self._obj[...]

    def assign_value(self, value):
        if self._mode == 'r':
            raise RuntimeError('Cannot assign value in read mode')
        if self._backend == 'Nio':
            self._obj.assign_value(value)
        elif self._backend == 'netCDF4':
            if self._obj.shape == ():
                self._obj.assignValue(value)
            else:
                self._obj[:] = value

    def __getitem__(self, key):
        return self._obj[key]

    def __setitem__(self, key, value):
        if self._mode == 'r':
            raise RuntimeError('Cannot set variable in read mode')
        self._obj[key] = value


#===============================================================================
# COMMAND-LINE OPERATION
#===============================================================================
if __name__ == '__main__':
    pass
