"""
The module containing the PyReshaper configuration specification class

This is a configuration specification class, through which the input to
the PyReshaper code is specified.  Currently all types of supported
operations for the PyReshaper are specified with derived dypes of the
Specification class.

Copyright 2017, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

import numpy
from copy import deepcopy

try:
    _dict_ = __import__('collections', fromlist=['OrderedDict']).OrderedDict
except:
    try:
        _dict_ = __import__('ordereddict', fromlist=[
                            'OrderedDict']).OrderedDict
    except:
        _dict_ = dict


_AVAILABLE_ = []
_BACKEND_MAP_ = {}

_BACKEND_ = None

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


#=========================================================================
# is_available
#=========================================================================
def is_available(name=None):
    if name is None:
        return len(_AVAILABLE_) > 0
    else:
        return name in _BACKEND_MAP_


#=========================================================================
# set_backend - Set the backend to the one named or first preferred
#=========================================================================
def set_backend(name=None):
    global _BACKEND_
    if name is None:
        if is_available():
            _BACKEND_ = _AVAILABLE_[0]
        else:
            raise RuntimeError('No I/O Backends available')
    else:
        if is_available(name):
            _BACKEND_ = name
        else:
            raise KeyError('I/O Backend {0!r} not available'.format(name))


# Set Default backend
set_backend()


#=========================================================================
# get_backend - Get the currently set backend name
#=========================================================================
def get_backend():
    return _BACKEND_


#=========================================================================
# get_backend_version
#=========================================================================
def get_backend_version(name=None):
    if name is None:
        backend = _BACKEND_MAP_[_BACKEND_]
    else:
        backend = _BACKEND_MAP_[name]
    return tuple(int(i) for i in backend.__version__.split('.'))


#=========================================================================
# NCFile
#=========================================================================
class NCFile(object):
    """
    Wrapper class for netCDF files/datasets
    """

    def __init__(self, filename, mode='r', ncfmt='netcdf4', compression=0, least_significant_digit=None):
        """
        Initializer

        Parameters:
            filename (str): Name of netCDF file to open
            mode (str): Write-mode ('r' for read, 'w' for write, 'a' for append)
            ncfmt (str): Format to use of the netcdf file, if being created ('netcdf' or 'netcdf4')
            compression (int): Level of compression to use when writing to this netcdf file
            least_significant_digit (int): If not None, specifies the digit after the decimal to which
                precision must be kept when applying lossy truncation before compression
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
            err_msg = "Netcdf write mode {0!r} is not one of 'r', 'w', or 'a'".format(
                mode)
            raise ValueError(err_msg)
        if ncfmt not in ['netcdf', 'netcdf4', 'netcdf4c']:
            err_msg = "Netcdf format {0!r} is not one of 'netcdf', 'netcdf4', or 'netcdf4c'".format(
                mode)
            raise ValueError(err_msg)
        if compression > 9 or compression < 0:
            err_msg = "Netcdf compression level {0} is not in range 0 to 9".format(
                compression)
            raise ValueError(err_msg)

        self._mode = mode
        self._backend = deepcopy(get_backend())
        self._iolib = _BACKEND_MAP_[self._backend]

        self._file_opts = {}
        self._var_opts = {}

        if self._backend == 'Nio':
            file_options = self._iolib.options()
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
                self._obj = self._iolib.open_file(
                    filename, mode, **self._file_opts)

            self._dimensions = _dict_(
                (d, self._obj.dimensions[d]) for d in self._obj.dimensions)

        elif self._backend == 'netCDF4':
            if ncfmt == 'netcdf':
                self._file_opts["format"] = "NETCDF3_64BIT"
            elif ncfmt == 'netcdf4':
                self._file_opts["format"] = "NETCDF4_CLASSIC"
                if compression > 0:
                    self._var_opts["zlib"] = True
                    self._var_opts["complevel"] = int(compression)
                    if least_significant_digit:
                        self._var_opts["least_significant_digit"] = least_significant_digit
            elif ncfmt == 'netcdf4c':
                self._file_opts["format"] = "NETCDF4_CLASSIC"
                self._var_opts["zlib"] = True
                self._var_opts["complevel"] = 1

            if mode == 'r':
                self._obj = self._iolib.Dataset(filename)
            else:
                self._obj = self._iolib.Dataset(
                    filename, mode, **self._file_opts)

            self._dimensions = _dict_(
                (d, len(self._obj.dimensions[d])) for d in self._obj.dimensions)

        self._variables = _dict_((v, NCVariable(
            v, self._obj.variables[v], mode=mode)) for v in self._obj.variables)

    @property
    def dimensions(self):
        """
        Return the dimension sizes dictionary
        """
        return self._dimensions

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
        return self._variables

    def create_dimension(self, name, value=None):
        if self._mode == 'r':
            raise RuntimeError('Cannot create dimension in read mode')
        if self._backend == 'Nio':
            self._obj.create_dimension(name, value)
        elif self._backend == 'netCDF4':
            self._obj.createDimension(name, value)
        self._dimensions[name] = value

    def create_variable(self, name, datatype, dimensions, fill_value=None, chunksizes=None):
        if self._mode == 'r':
            raise RuntimeError('Cannot create variable in read mode')
        dt = datatype if isinstance(
            datatype, numpy.dtype) else numpy.dtype(datatype)
        if dt.char in ('S', 'U', 'c'):
            fill_value = None
        if self._backend == 'Nio':
            dtc = 'c' if dt.char in ('S', 'U') else dt.char
            var = self._obj.create_variable(name, dtc, dimensions)
            if fill_value is not None:
                setattr(var, '_FillValue', numpy.array(fill_value, dtype=dt))
        elif self._backend == 'netCDF4':
            if fill_value is not None:
                self._var_opts['fill_value'] = numpy.array(
                    fill_value, dtype=dt)
            self._var_opts['chunksizes'] = chunksizes
            var = self._obj.createVariable(
                name, datatype, dimensions, **self._var_opts)
        new_var = NCVariable(name, var, self._mode)
        self._variables[name] = new_var
        return new_var

    def close(self):
        self._obj.close()


#=========================================================================
# NCVariable
#=========================================================================
class NCVariable(object):
    """
    Wrapper class for NetCDF variables
    """

    def __init__(self, vname, vobj, mode='r'):
        self._name = vname
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
            return [a for a in self._obj.attributes if a != '_FillValue']
        elif self._backend == 'netCDF4':
            return [a for a in self._obj.ncattrs() if a != '_FillValue']

    def getncattr(self, name):
        if self._backend == 'Nio':
            return self._obj.attributes[name]
        elif self._backend == 'netCDF4':
            return self._obj.getncattr(name)

    def setncattr(self, name, value):
        if self._mode == 'r':
            raise RuntimeError('Cannot set attribute in read mode')
        if name == '_FillValue':
            raise AttributeError('Cannot set fill value of NCVariable')
        elif name == 'missing_value':
            value = numpy.array(value, dtype=self.datatype)[()]
        if self._backend == 'Nio':
            if isinstance(value, unicode):
                value = str(value)
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
    def name(self):
        return self._name

    @property
    def ndim(self):
        return len(self.shape)

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

    @property
    def fill_value(self):
        if self._backend == 'Nio':
            return self._obj.attributes['_FillValue'] if '_FillValue' in self._obj.attributes else None
        elif self._backend == 'netCDF4':
            return self._obj.getncattr('_FillValue') if '_FillValue' in self._obj.ncattrs() else None

    @property
    def chunk_sizes(self):
        if self._backend == 'Nio':
            return None
        elif self._backend == 'netCDF4':
            return self._obj.chunking()

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
        if self.shape == ():
            return self.get_value()
        elif self.size == 0:
            return numpy.zeros(self.shape, dtype=self.datatype)
        else:
            return self._obj[key]

    def __setitem__(self, key, value):
        if self._mode == 'r':
            raise RuntimeError('Cannot set variable in read mode')
        if self.shape == ():
            self.assign_value(value)
        elif self.datatype == numpy.dtype('c') and self._backend == 'Nio' and get_backend_version(self._backend) < (1, 5, 0):
            print get_backend_version()
            key_t = numpy.index_exp[key]
            if self.ndim < len(key_t):
                raise KeyError('Too many indices specified for variable')
            key_t += (slice(None),) * (self.ndim - len(key_t))

            varray = numpy.ma.asarray(value)
            if varray.dtype.char not in ('c', 'S', 'U'):
                raise TypeError('Incompatible type for string variable')
            if self.ndim != varray.ndim:
                raise ValueError(
                    'Incompatible array dimensions for string variable')

            def lenslice(l, s):
                start, stop, step = s.indices(l)
                return (stop - start) // step + int((stop - start) % step > 0)
            strlen = lenslice(
                self.shape[-1], key_t[-1]) if isinstance(key_t[-1], slice) else 1

            rarray = numpy.squeeze(varray.view('S{}'.format(strlen)), axis=-1)

            it = numpy.nditer(rarray, flags=['multi_index'])
            while not it.finished:
                item = it[0].tostring().replace('\x00', '')
                minlen = strlen if strlen < len(item) else len(item)
                #lidx = key_t[:-1] + (slice(minlen),)
                lidx = it.multi_index + (slice(minlen),)
                self._obj[lidx] = item[:minlen]
                it.iternext()
        else:
            self._obj[key] = value


#=========================================================================
# COMMAND-LINE OPERATION
#=========================================================================
if __name__ == '__main__':
    pass
