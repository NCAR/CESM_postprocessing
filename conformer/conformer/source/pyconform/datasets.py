"""
DatasetDesc Interface Class

This file contains the interface classes to the input and output multi-file
datasets.

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from os import linesep
from os.path import exists
from collections import OrderedDict
from numpy import dtype
from netCDF4 import Dataset as NC4Dataset
from cf_units import Unit
from warnings import warn
from pyconform.physarray import PhysArray


#===================================================================================================
# DefinitionWarning
#===================================================================================================
class DefinitionWarning(Warning):
    """Warning to indicate that a variable definition might be bad"""


#===================================================================================================
# _group_by_name_
#===================================================================================================
def _group_by_name_(*descs):
    """
    Return a dictionary of the objects elements, grouped by name
    
    This is a simple group-by implementation for the Desc objects, used when making the
    objects unique by name.
    
    Parameters:
        descs: A list of Desc objects (with a 'name' attribute)
    """
    grp = OrderedDict()
    for desc in descs:
        if desc.name in grp:
            grp[desc.name].append(desc)
        else:
            grp[desc.name] = [desc]
    return grp


#===================================================================================================
# _is_list_of_type_
#===================================================================================================
def _is_list_of_type_(obj, typ):
    """
    Check that an object is a list/tuple of a given type
    
    Parameters:
        obj:  A list or tuple of objects
        typ:  The type of objects that should be in the list
    """
    if not isinstance(obj, (list, tuple)):
        return False
    return all([isinstance(o, typ) for o in obj])


#===================================================================================================
# DimensionDesc
#===================================================================================================
class DimensionDesc(object):
    """
    Descriptor for a dimension in a DatasetDesc
    
    Contains the name of the dimensions, its size, and whether the dimension is limited or
    unlimited.
    """

    def __init__(self, name, size=None, unlimited=False, stringlen=False):
        """
        Initializer
        
        Parameters:
            name (str): Dimension name
            size (int): Dimension size
            unlimited (bool): Whether the dimension is unlimited or not
            stringlen (bool): Whether the dimension represents a string length or not
        """
        self._name = name
        self._size = int(size) if size is not None else None
        self._unlimited = bool(unlimited)
        self._stringlen = bool(stringlen)

    @property
    def name(self):
        """Name of the dimension"""
        return self._name

    @property
    def size(self):
        """Numeric size of the dimension (if set)"""
        return self._size

    @property
    def unlimited(self):
        """Boolean indicating whether the dimension is unlimited or not"""
        return self._unlimited

    @property
    def stringlen(self):
        """Boolean indicating whether the dimension represents a string length or not"""
        return self._stringlen

    def is_set(self):
        """
        Return True if the dimension size and unlimited status is set, False otherwise
        """
        return self._size is not None

    def unset(self):
        """
        Unset the dimension's size and unlimited status
        """
        self._size = None
        self._unlimited = False

    def set(self, dd):
        """
        Set the size and unlimited status from another DimensionDesc
        
        Parameters:
            dd (DimensionDesc): The DimensionDesc from which to set the size and unlimited status
        """
        if not isinstance(dd, DimensionDesc):
            err_msg = ('Cannot set dimension {!r} from object of type {!r}, needs to be a '
                       'DimensionDesc.').format(self.name, type(dd))
            raise TypeError(err_msg)
        self._size = dd.size
        self._unlimited = dd.unlimited

    def __eq__(self, other):
        if not isinstance(other, DimensionDesc):
            return False
        if self.name != other.name:
            return False
        if self.size != other.size:
            return False
        if self.unlimited != other.unlimited:
            return False
        return True

    def __ne__(self, other):
        return not self.__eq__(other)

    def __str__(self):
        return '{!r} [{}{}]'.format(self.name, self.size, '+' if self.unlimited else '')

    @staticmethod
    def unique(descs):
        """
        Return a mapping of names to unique DimensionDescs
        
        Parameters:
            descs: A list of DimensionDesc objects
        """
        ugrp = OrderedDict()
        if not all([isinstance(d, DimensionDesc) for d in descs]):
            err_msg = 'All arguments to unique must be DimensionDesc objects: {}'.format(descs)
            raise TypeError(err_msg)
        grp = _group_by_name_(*descs)
        for name, ndescs in grp.iteritems():
            setdescs = [d for d in ndescs if d.is_set()]
            if len(setdescs) == 0:
                ugrp[name] = ndescs[0]
            elif len(setdescs) == 1:
                ugrp[name] = setdescs[0]
            else:
                if not all([d == setdescs[0] for d in setdescs[1:]]):
                    err_msg = ('Multiple DimensionDescs of same name but different settings: '
                               '{}').format(', '.join([str(d) for d in setdescs]))
                    raise ValueError(err_msg)
                ugrp[name] = setdescs[0]
        return ugrp


#===================================================================================================
# VariableDesc
#===================================================================================================
class VariableDesc(object):
    """
    Descriptor for a variable in a dataset
    
    Contains the variable name, string datatype, dimensions tuple, attributes dictionary,
    and a string definition (how to construct the data for the variable) or data array (if
    the data is contained in the variable declaration).
    """

    # Elemental NetCDF datatypes
    _NTYPES_ = ('byte', 'ubyte', 'char', 'short', 'ushort', 'int', 'uint',
                'int64', 'uint64', 'float', 'real', 'double')
    _DTYPES_ = (dtype('b'), dtype('u1'), dtype('S1'), dtype('i2'), dtype('u2'), dtype('i4'), dtype('u4'),
                dtype('i8'), dtype('u8'), dtype('f4'), dtype('f4'), dtype('f8'))

    def __init__(self, name, datatype='float', dimensions=(), definition=None, attributes={}):
        """
        Initializer

        Parameters:
            name (str): Name of the variable
            datatype (str): NetCDF datatype or NumPy dtype of the variable data
            dimensions (tuple): Tuple of DimensionDesc objects for the variable
            definition: String or data definition of variable
            attributes (dict): Dictionary of variable attributes
        """
        self._name = name
        
        if isinstance(datatype, basestring) and datatype in VariableDesc._NTYPES_:
            self._ntype = datatype
            self._dtype = VariableDesc._DTYPES_[VariableDesc._NTYPES_.index(datatype)]
        elif isinstance(datatype, dtype) and datatype in VariableDesc._DTYPES_:
            self._ntype = VariableDesc._NTYPES_[VariableDesc._DTYPES_.index(datatype)]
            self._dtype = datatype
        else:
            raise TypeError('Invalid variable datatype {} for variable {}'.format(datatype, name))

        self.definition = definition

        if not _is_list_of_type_(dimensions, DimensionDesc):
            err_msg = ('Dimensions for variable {!r} must be a list or tuple of type '
                       'DimensionDesc').format(name)
            raise TypeError(err_msg)
        self._dimensions = DimensionDesc.unique(dimensions)

        if not isinstance(attributes, dict):
            raise TypeError('Attributes for variable {!r} not dict'.format(name))
        self._attributes = attributes

        self._files = {}

    @property
    def name(self):
        """Name of the variable"""
        return self._name

    @property
    def datatype(self):
        """String datatype of the variable"""
        return self._ntype
    
    @property
    def dtype(self):
        """NumPy dtype of the variable data"""
        return self._dtype
    
    @property
    def attributes(self):
        """Variable attributes dictionary"""
        return self._attributes

    @property
    def dimensions(self):
        """Dictionary of dimension descriptors for dimensions on which the variable depends"""
        return self._dimensions

    @property
    def files(self):
        """Dictionary of file descriptors for files containing this variable"""
        return self._files

    def __eq__(self, other):
        if not isinstance(other, VariableDesc):
            return False
        if self.name != other.name:
            return False
        if self.datatype != other.datatype:
            return False
        if self.dimensions.keys() != other.dimensions.keys():
            return False
        return True

    def __ne__(self, other):
        return not self.__eq__(other)

    def __str__(self):
        strvals = ['Variable: {!r}'.format(self.name)]
        strvals += ['   datatype: {!r}'.format(self.datatype)]
        strvals += ['   dimensions: {!s}'.format(self.dimensions.keys())]
        if self.definition is not None:
            strvals += ['   definition: {!r}'.format(self.definition)]
        if len(self.attributes) > 0:
            strvals += ['   attributes:']
            for aname, avalue in self.attributes.iteritems():
                strvals += ['      {}: {!r}'.format(aname, avalue)]
        if len(self.files) > 0:
            strvals += ['   files:']
            for fname in self.files:
                strvals += ['      {}'.format(fname)]
        return linesep.join(strvals)

    def units(self):
        """Retrieve the units attribute, if it exists, otherwise 1"""
        return self.attributes.get('units', 'no unit')

    def calendar(self):
        """Retrieve the calendar attribute, if it exists, otherwise None"""
        return self.attributes.get('calendar', None)

    def cfunits(self):
        """Construct a cf_units.Unit object from the units/calendar attributes"""
        return Unit(self.units(), calendar=self.calendar())

    @staticmethod
    def unique(descs):
        """
        Return a mapping of names to unique VariableDescs
        
        Parameters:
            descs: A list of VariableDesc objects
        """
        if not all([isinstance(d, VariableDesc) for d in descs]):
            err_msg = 'All arguments to unique must be VariableDesc objects: {}'.format(descs)
            raise TypeError(err_msg)
        ugrp = OrderedDict()
        for name, ndescs in _group_by_name_(*descs).iteritems():
            if len(ndescs) == 0:
                err_msg = 'No VariableDesc objects found with given name {}'.format(name)
                raise ValueError(err_msg)
            elif len(ndescs) == 1:
                ugrp[name] = ndescs[0]
            else:
                if not all([d == ndescs[0] for d in ndescs[1:]]):
                    err_msg = ('Multiple VariableDescs of same name but different settings: '
                               '{}').format(ndescs[0].name)
                    raise ValueError(err_msg)
                ugrp[name] = ndescs[0]
        return ugrp


#===================================================================================================
# FileDesc
#===================================================================================================
class FileDesc(object):
    """
    A class describing the contents of a single dataset file
    
    In simplest terms, the FileDesc contains the header information for a single NetCDF file.  It
    contains the name of the file, the type of the file, a dictionary of global attributes in the
    file, a dict of DimensionDesc objects, and a dict of VariableDesc objects. 
    """

    def __init__(self, name, format='NETCDF4_CLASSIC', deflate=2, variables=(), attributes={}):  # @ReservedAssignment
        """
        Initializer
        
        Parameters:
            name (str): String name of the file (i.e., a path name or file name)
            fmt (str):  String defining the NetCDF file format (one of 'NETCDF4',
                'NETCDF4_CLASSIC', 'NETCDF3_CLASSIC', 'NETCDF3_64BIT_OFFSET' or 
                'NETCDF3_64BIT_DATA')
            deflate (int): Level of lossless compression to use in all variables within the file (0-9)
            variables (tuple):  Tuple of VariableDesc objects describing the file variables            
            attributes (dict):  Dict of global attributes in the file
        """
        self._name = name

        if format not in ('NETCDF4', 'NETCDF4_CLASSIC', 'NETCDF3_CLASSIC',
                          'NETCDF3_64BIT_OFFSET', 'NETCDF3_64BIT_DATA', 'NETCDF3_64BIT'):
            err_msg = 'NetCDF file format {!r} unrecognized in file {!r}'.format(format, name)
            raise TypeError(err_msg)
        self._format = format

        if not isinstance(deflate, int):
            raise TypeError('Deflate value must be an integer, not {}'.format(deflate))
        if deflate < 0 or deflate > 9:
            raise TypeError('Deflate value must be in the range 0-9, not {}'.format(deflate))
        self._deflate = deflate
        
        if not _is_list_of_type_(variables, VariableDesc):
            err_msg = ('Variables in file {!r} must be a list or tuple of type '
                       'VariableDesc').format(name)
            raise TypeError(err_msg)

        dimensions = []
        for vdesc in variables:
            dimensions.extend(vdesc.dimensions.values())
        self._dimensions = DimensionDesc.unique(dimensions)

        for vdesc in variables:
            for dname in vdesc.dimensions:
                vdesc.dimensions[dname] = self._dimensions[dname]
        self._variables = VariableDesc.unique(variables)

        for vdesc in self._variables.itervalues():
            vdesc.files[name] = self

        if not isinstance(attributes, dict):
            err_msg = ('Attributes in file {!r} cannot be of type {!r}, needs to be a '
                       'dict').format(name, type(attributes))
            raise TypeError(err_msg)
        self._attributes = attributes

    @property
    def name(self):
        """Name of the file"""
        return self._name

    def exists(self):
        """Whether the file exists or not"""
        return exists(self.name)

    @property
    def format(self):
        """Format of the file"""
        return self._format

    @property
    def deflate(self):
        """Deflate level for variables in the file"""
        return self._deflate

    @property
    def attributes(self):
        """Dictionary of global attributes of the file"""
        return self._attributes

    @property
    def dimensions(self):
        """Dictionary of dimension descriptors associated with the file"""
        return self._dimensions

    @property
    def variables(self):
        """Dictionary of variable descriptors associated with the file"""
        return self._variables

    def __eq__(self, other):
        if not isinstance(other, FileDesc):
            return False
        if self.name != other.name:
            return False
        if self.dimensions.keys() != other.dimensions.keys():
            return False
        if self.variables.keys() != other.variables.keys():
            return False
        for vname in self.variables:
            if self.variables[vname] != other.variables[vname]:
                return False
        return True

    def __ne__(self, other):
        return not self.__eq__(other)

    @staticmethod
    def unique(descs):
        """
        Return a mapping of names to unique FileDescs
        
        Parameters:
            descs: A list of FileDesc objects
        """
        if not all([isinstance(d, FileDesc) for d in descs]):
            err_msg = 'All arguments to unique must be FileDesc objects: {}'.format(descs)
            raise TypeError(err_msg)
        ugrp = OrderedDict()
        for name, ndescs in _group_by_name_(*descs).iteritems():
            if len(ndescs) == 0:
                err_msg = 'No FileDesc objects found with given name {}'.format(name)
                raise ValueError(err_msg)
            elif len(ndescs) == 1:
                ugrp[name] = ndescs[0]
            else:
                if not all([d == ndescs[0] for d in ndescs[1:]]):
                    err_msg = ('Multiple FileDesc of same name but different settings: '
                               '{}').format(ndescs[0].name)
                    raise ValueError(err_msg)
                ugrp[name] = ndescs[0]
        return ugrp



#===================================================================================================
# DatasetDesc
#===================================================================================================
class DatasetDesc(object):
    """
    A class describing a self-consistent set of dimensions and variables in one or more files
    
    In simplest terms, a single NetCDF file is a dataset.  Hence, the DatasetDesc object can be
    viewed as a simple container for the header information of a NetCDF file.  However, the
    DatasetDesc can span multiple files, as long as dimensions and variables are consistent across
    all of the files in the DatasetDesc.
    
    Self-consistency is defined as:
        1. Dimensions with names that appear in multiple files must all have the same size and
           limited/unlimited status, and
        2. Variables with names that appear in multiple files must have the same datatype and
           dimensions, and they must refer to the same data.
    """

    def __init__(self, name='dataset', files=()):
        """
        Initializer

        Parameters:
            name (str): String name to optionally give to a dataset
            files (tuple): Tuple of FileDesc objects contained in the dataset
        """
        self._name = name

        if not _is_list_of_type_(files, FileDesc):
            err_msg = ('File descriptors in DatasetDesc {!r} must be a list or tuple of type '
                       'FileDesc').format(name)
            raise TypeError(err_msg)

        dimensions = []
        for fdesc in files:
            dimensions.extend(fdesc.dimensions.values())
        self._dimensions = DimensionDesc.unique(dimensions)

        for fdesc in files:
            for dname in fdesc.dimensions:
                fdesc.dimensions[dname] = self._dimensions[dname]
            for vdesc in fdesc.variables.itervalues():
                for dname in vdesc.dimensions:
                    vdesc.dimensions[dname] = self._dimensions[dname]

        variables = []
        for fdesc in files:
            variables.extend(fdesc.variables.values())
        self._variables = VariableDesc.unique(variables)

        for fdesc in files:
            for vname in fdesc.variables:
                fdesc.variables[vname] = self._variables[vname]

        self._files = FileDesc.unique(files)

        for fname, fdesc in self._files.iteritems():
            for vdesc in fdesc.variables.itervalues():
                vdesc.files[fname] = fdesc     

    @property
    def name(self):
        """Name of the dataset (optional)"""
        return self._name

    @property
    def dimensions(self):
        """Dicitonary of dimension descriptors contained in the dataset"""
        return self._dimensions

    @property
    def variables(self):
        """Dictionary of variable descriptors contained in the dataset"""
        return self._variables

    @property
    def files(self):
        """Dictionary of file descriptors contained in the dataset"""
        return self._files


#===================================================================================================
# InputDatasetDesc
#===================================================================================================
class InputDatasetDesc(DatasetDesc):
    """
    DatasetDesc that can be used as input (i.e., can be read from file)
    
    The InputDatasetDesc is a kind of DatasetDesc where all of the DatasetDesc information is read from 
    the headers of existing NetCDF files.  The files must be self-consistent according to the
    standard DatasetDesc definition.
    
    Variables in an InputDatasetDesc must have unset "definition" parameters, and the "filenames"
    parameter will contain the names of files from which the variable data can be read.  
    """

    def __init__(self, name='input', filenames=[]):
        """
        Initializer

        Parameters:
            name (str): String name to optionally give to a dataset
            filenames (list): List of filenames in the dataset
        """
        files = []

        # Loop over all of the input filenames
        for fname in filenames:
            with NC4Dataset(fname) as ncfile:

                # Get file format
                ffmt = ncfile.file_format

                # Get global attributes
                fattrs = OrderedDict()
                for aname in ncfile.ncattrs():
                    fattrs[aname] = ncfile.getncattr(aname)

                # Parse variables and their dimensions
                fvars = []
                fdims = OrderedDict()
                for vname, vobj in ncfile.variables.iteritems():

                    vattrs = OrderedDict()
                    for vattr in vobj.ncattrs():
                        vattrs[vattr] = vobj.getncattr(vattr)

                    for dname in vobj.dimensions:
                        if dname not in fdims:
                            dobj = ncfile.dimensions[dname]
                            size = len(dobj)
                            unlimited = dobj.isunlimited()
                            slen = True if dname == vobj.dimensions[-1] and vobj.dtype == dtype('S1') else False
                            fdims[dname] = DimensionDesc(dname, size=size, unlimited=unlimited, stringlen=slen)

                    vdims = [fdims[dname] for dname in vobj.dimensions]

                    fvars.append(VariableDesc(vname, datatype=vobj.dtype, dimensions=vdims, attributes=vattrs))

                files.append(FileDesc(fname, format=ffmt, attributes=fattrs, variables=fvars))

        # Call the base class initializer to check self-consistency
        super(InputDatasetDesc, self).__init__(name, files=files)


#===================================================================================================
# OutputDatasetDesc
#===================================================================================================
class OutputDatasetDesc(DatasetDesc):
    """
    DatasetDesc that can be used for output (i.e., to be written to files)
    
    The OutputDatasetDesc contains all of the header information needed to write a DatasetDesc to
    files.  Unlike the InputDatasetDesc, it is not assumed that all of the variable and dimension
    information can be found in existing files.  Instead, the OutputDatasetDesc contains a minimal
    subset of the output file headers, and information about how to construct the variable data
    and dimensions by using the 'definition' parameter of the variables.

    The information to define an OutputDatasetDesc must be specified as a nested dictionary,
    where the first level of the dictionary are unique names of variables in the dataset.  Each
    named variable defines another nested dictionary.
    
    Each 'variable' dictionary is assued to contain the following:
        1. 'attributes': A dictionary of the variable's attributes
        2. 'datatype': A string specifying the type of the variable's data
        3. 'dimensions': A tuple of names of dimensions upon which the variable depends
        4. 'definition': Either a string mathematical expression representing how to construct
            the variable's data from input variables or functions, or an array declaring the actual
            data from which to construct the variable
        5. 'file': A dictionary containing a string 'filename', a string 'format' (which can be
            one of 'NETCDF4', 'NETCDF4_CLASSIC', 'NETCDF3_CLASSIC', 'NETCDF3_64BIT_OFFSET' or 
            'NETCDF3_64BIT_DATA'), a dictionary of 'attributes', and a list of 'metavars' specifying
            the names of other variables that should be added to the file, in addition to obvious
            metadata variables and the variable containing the 'file' section.
    """
    _NC_TYPES_ = {3: ['byte', 'char', 'short', 'int', 'float', 'double'],
                  4: ['byte', 'char', 'short', 'ushort', 'int', 'uint', 'int64', 'uint64', 'float', 'real', 'double']}
    _NC_FORMATS_ = {'NETCDF4': 4, 'NETCDF4_CLASSIC': 3, 'NETCDF3_CLASSIC': 3,
                    'NETCDF3_64BIT_OFFSET': 3, 'NETCDF3_64BIT_DATA': 3, 'NETCDF3_64BIT': 3}

    def __init__(self, name='output', dsdict=OrderedDict()):
        """
        Initializer

        Parameters:
            name (str): String name to optionally give to a dataset
            dsdict (dict): Dictionary describing the dataset variables
        """
        # Initialize a dictionary of file sections
        files = {}

        # Look over all variables in the dataset dictionary
        variables = OrderedDict()
        metavars = []
        for vname, vdict in dsdict.iteritems():
            vkwds = {}

            # Get the variable attributes, if they are defined
            if 'attributes' in vdict:
                vkwds['attributes'] = vdict['attributes']

            # Get the datatype of the variable, otherwise defaults to VariableDesc default
            vkwds['datatype'] = 'float'
            if 'datatype' in vdict:
                vkwds['datatype'] = vdict['datatype']

            # Get either the 'definition' (string definition or data) of the variables
            def_wrn = ''
            if 'definition' in vdict:
                vdef = vdict['definition']
                if isinstance(vdef, basestring):
                    if len(vdef.strip()) > 0:
                        vshape = None
                    else:
                        def_wrn = 'Empty definition for output variable {!r} in dataset {!r}.'.format(vname, name)
                else:
                    vshape = PhysArray(vdef).shape
                vkwds['definition'] = vdef
            else:
                def_wrn = 'No definition given for output variable {!r} in dataset {!r}.'.format(vname, name)
            
            if len(def_wrn) > 0:
                warn('{} Skipping output variable {}.'.format(def_wrn, vname), DefinitionWarning)
                continue

            # Get the dimensions of the variable (REQUIRED)
            if 'dimensions' in vdict:
                vdims = vdict['dimensions']
                sldim = vdims[-1] if vkwds['datatype'] == 'char' else None
                if vshape is None:
                    vkwds['dimensions'] = tuple(DimensionDesc(d, stringlen=(sldim==d)) for d in vdims)
                else:
                    vkwds['dimensions'] = tuple(DimensionDesc(d, size=s, stringlen=(sldim==d)) for d, s in zip(vdims, vshape))
            else:
                err_msg = 'Dimensions are required for variable {!r} in dataset {!r}'.format(vname, name)
                raise ValueError(err_msg)

            variables[vname] = VariableDesc(vname, **vkwds)

            # Parse the file section (if present)
            if 'file' in vdict:
                fdict = vdict['file']

                if 'filename' not in fdict:
                    err_msg = ('Filename is required in file section of variable {!r} in dataset '
                               '{!r}').format(vname, name)
                    raise ValueError(err_msg)

                fname = fdict['filename']
                if fname in files:
                    err_msg = ('Variable {!r} in dataset {!r} claims to own file '
                               '{!r}, but this file is already owned by variable '
                               '{!r}').format(vname, name, fname, files[fname]['variables'][0])
                    raise ValueError(err_msg)
                files[fname] = {}

                if 'format' in fdict:
                    files[fname]['format'] = fdict['format']
                
                if 'deflate' in fdict:
                    files[fname]['deflate'] = fdict['deflate']

                if 'attributes' in fdict:
                    files[fname]['attributes'] = fdict['attributes']

                files[fname]['variables'] = [vname]

                if 'metavars' in fdict:
                    for mvname in fdict['metavars']:
                        if mvname not in files[fname]['variables']:
                            files[fname]['variables'].append(mvname)
                
            else:
                metavars.append(vname)

        # Loop through all character type variables and get the 
        # Loop through all found files and create the file descriptors
        filedescs = []
        for fname, fdict in files.iteritems():

            # Get the variable descriptors for each variable required to be in the file
            vlist = OrderedDict([(vname, variables[vname]) for vname in fdict['variables']])

            # Get the unique list of dimension names for required by these variables
            fdims = set()
            for vname in vlist:
                vdesc = vlist[vname]
                for dname in vdesc.dimensions:
                    fdims.add(dname)

            # Loop through all the variable names identified as metadata (i.e., no 'file')
            for mvname in metavars:
                if mvname not in fdict['variables']:
                    vdesc = variables[mvname]

                    # Include this variable in the file only if all of its dimensions are included
                    # (Scalar variables are excluded and must be included as metadata explicitly)
                    if len(vdesc.dimensions) > 0 and set(vdesc.dimensions.keys()).issubset(fdims):
                        vlist[mvname] = vdesc
            
            # Loop through the current list of variables and check for any "bounds" or "coordinates" attributes
            mvnames = set()
            for vname in vlist:
                vdesc = vlist[vname]
                if 'bounds' in vdesc.attributes:
                    mvname = vdesc.attributes['bounds']
                    if mvname not in variables:
                        raise ValueError(('Variable {} references a bounds variable {} that is not '
                                          'found').format(vdesc.name, mvname))
                    mvnames.add(mvname)
                if 'coordinates' in vdesc.attributes:
                    for mvname in vdesc.attributes['coordinates'].split():
                        if mvname not in variables:
                            raise ValueError(('Variable {} references a coordinates variable {} that is not '
                                              'found').format(vdesc.name, mvname))
                        mvnames.add(mvname)
            
            # Add the bounds and coordinates to the list of variables
            for mvname in mvnames:
                if mvname not in vlist:
                    vlist[mvname] = variables[mvname]

            # Create the file descriptor
            fdict['variables'] = [vlist[vname] for vname in vlist]
            fdesc = FileDesc(fname, **fdict)
            
            # Validate the variable types for the file descriptor
            for vname in vlist:
                vdesc = vlist[vname]
                vdtype = vdesc.datatype
                fformat = fdesc.format
                try:
                    OutputDatasetDesc._validate_netcdf_type_(vdtype, fformat)
                except:
                    vname = vdesc.name
                    raise ValueError(('File {!r} of format {!r} cannot write variable {!r} with '
                                      'datatype {!r}').format(fname, fformat, vname, vdtype))
                
            # Append the validated file descriptor to the list
            filedescs.append(fdesc)
                             
        # Call the base class to run self-consistency checks
        super(OutputDatasetDesc, self).__init__(name, files=filedescs)

    @staticmethod
    def _validate_netcdf_type_(t, f):
        """
        Check if a given type is valid for the given file format
        
        Parameters:
            t (str): The string-type to check
            f (str): The file format of the file in whi
        """
        if f in OutputDatasetDesc._NC_FORMATS_:
            NC_VER = OutputDatasetDesc._NC_FORMATS_[f]
        else:
            raise ValueError('Unrecognized NetCDF file format {!r}'.format(f))
        if t not in OutputDatasetDesc._NC_TYPES_[NC_VER]:
            raise ValueError('Data type {!r} unrecognized in NetCDF file format {!r}'.format(t, f))
