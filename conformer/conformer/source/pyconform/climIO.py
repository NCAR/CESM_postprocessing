"""
Climate I/O Facade

This defines the facade for netCDF I/O operations, either with netCDF4 or
PyNIO.

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

import os,sys
try:
    import Nio
    import netCDF4
except ImportError:
    check = False    


#=============================================
# Initializes the correct I/O version to use
#=============================================
def init_climIO(override=None):
    """
    Function will first test if PyNIO is available.  If it is,
    it will initialize the Nio port.  If PyNIO is not available,
    it will see if netCDF4 is available.  If it is, it will
    initialize the netCDF4 port.  If not, the code will exit. 

    Returns:
        io_ver (climIO port object): A pointer to a climIO port object. 
    """
    if override is None:
        try:
            import Nio
            use = 'Nio'
            io_ver = PyNioPort()
        except ImportError:
            try:
                import netCDF4
                use = 'netCDF4'
                io_ver = NetCDF4PyPort() 
            except ImportError:
                print 'ERROR: Could not find PyNio or netCDF4 in PYTHONPATH'
                sys.exit(10)
    elif override == 'Nio':
        import Nio
        use = 'Nio'
        io_ver = PyNioPort()
    elif override == 'netCDF4':
        import netCDF4
        use = 'netCDF4'
        io_ver = NetCDF4PyPort()
    print 'I/O Library: ',use
    return io_ver


##########################
#  THIS FUNC IS ONLY TEMP
##########################
def get_filename(var, month_dict, split):

    # Derive the input file name
    i_fn = month_dict['directory']+'/'+month_dict['fn']
    if not (os.path.isfile(i_fn)):
        i_fn = month_dict['fn']
        if not (os.path.isfile(i_fn)):
            i_fn = month_dict['directory']+'/'
            for p in month_dict['pattern']:
                if p == '$prefix':
                    i_fn = i_fn + month_dict['fn']
                elif p == '$var':
                    i_fn = i_fn + var
                elif p == '$date_pattern':
                    i_fn = i_fn + month_dict['date_stamp']
                elif p == '$hem':
                    i_fn = i_fn + split
                elif p == '$suffix':
                    i_fn = i_fn + month_dict['suffix']
                else:
                    i_fn = i_fn + p
            if not (os.path.isfile(i_fn)):
                return None
    return i_fn



#=============================================
# PyNIO I/O
#=============================================
class PyNioPort(object):

    def __init__(self):
        super(PyNioPort, self).__init__()

    def open_file(self, file_name):
        """
        Open a NetCDF file for reading. 

        Parameters:
            file_name (str): Name, including full path, of existing NetCDF file
                             to open for reading.

        Returns:
            open_file (NioFile): A pointer to a NioFile object. 
        """
        open_file = Nio.open_file(file_name,"r")
        return open_file

    def read_slice(self, open_file, var, index, all_values=False):
        """
        Retreives a chunk of data. 

        Parameters:
            open_file (NioFile): A pointer to an open NioFile object.
            var (str): Name of variable to retreive.
            index (int): Time dimension idndex to retreive.
            all_values (bool): Optional argument to retreive all dimensions.

        Returns:
            var_val (numPy array): The retreived values. 
        """
        var_hndl = open_file.variables[var]
        if all_values:
            var_val = var_hndl[:]
        else:
            var_val = var_hndl[index]
        return var_val

    #=============================================
    # PyNIO: Close an open NetCDF file
    #=============================================
    def close_file(self, open_file):
        """                     
        Close an open NetCDF file. 

        Parameters:
            open_file (NioFile): A pointer to an open NioFile object.
        """ 
        Nio.close(open_file)

    #=============================================
    # PyNIO: Create a  NetCDF file
    #=============================================
    def create_file(self, new_file_name,ncformat,hist_string=None):
        """
        Create a NetCDF file for writing. 

        Parameters:
            new_file_name (str): Name, including full path, of the new
                                 NetCDF file to create.
            ncformat (str): Type of NetCDF file to create.  
                            Options:
                            'netcdf4c': NetCDF4 with Level 1 compression
                            'NetCDF4Classic': NetCDF4 Classic
                            'Classic': NetCDF3
                            'netcdfLarge': NetCDF 64bit Offset
            hist_string (str): Optional.  A string to append to the histroy attribute.

        Returns:
            new_file (NioFile): A pointer to a NioFile object. 
        """
        # Set pyNIO netcdf file options
        opt = Nio.options()
        # The netcdf output format
        if ('netcdf4c' in ncformat):
            opt.Format = 'NetCDF4Classic'
            if (ncformat[-1].isdigit()):
                opt.CompressionLevel = ncformat[-1]
        elif (ncformat == 'netcdf4'):
            opt.Format = 'NetCDF4Classic'
        elif (ncformat == 'netcdf'):
            opt.Format  = 'Classic'
        elif (ncformat == 'netcdfLarge'):
            opt.Format = '64BitOffset'
        else:
            print "WARNING: Selected netcdf file format (",ncformat,") is not recongnized."
            print "Defaulting to netcdf4Classic format."
            opt.Format  = 'NetCDF4Classic'
        opt.PreFill = False
        if hist_string is None:
            hist_string = 'clim-convert'+new_file_name
        # Open new output file
        new_file = Nio.open_file(new_file_name, "w", options=opt, history=hist_string)

        return new_file

    #=============================================
    # PyNIO: Define a  NetCDF variable
    #=============================================
    def create_var(self, new_file,var_name,typeCode,dims,attrib):
        """
        Define a NetCDF variable

        Parameters:
            new_file (NioFile): A pointer to a NioFile object.
            var_name (str): The name of the variable to create.
            typeCode (str): Type of variable.  
                            Valid values:
                            'd': 64 bit float 
                            'f': 32 bit float 
                            'l': long 
                            'i': 32 bit integer 
                            'h': 16 bit integer 
                            'b': 8 bit integer 
                            'S1': character
            dims (tuple): A tuple that contains the names of the dimensions 
                          for the variable.
            attrib (list): A list of strings to add as attributes for the variable. 

        Returns:
            var (NioVariable): Returns a NioVariable object.    
        """
        var = new_file.create_variable(var_name,typeCode,tuple(dims))
        for k,v in attrib.items():
            setattr(var,k,v)
        return var

    #=============================================
    # PyNIO: Retreive a variable's type, dims, attribs
    #=============================================
    def get_var_info(self, template_file,var_name):
        """
        Retreive a variable's type, dimensions, and attributes

        Parameters:
            template_file (NioFile): A pointer to a NioFile object.
            var_name (str): The name of the variable to read from.

        Returns:
            typeCode (str): Type of variable. 
            dimnames (tuple): A tuple that contains the names of the dimensions.
            var_hndl.attributes (list): A list of attributes for the variable.    
        """
        var_hndl = template_file.variables[var_name]
        typeCode = var_hndl.typecode()

        dimnames = []
        for dimn in var_hndl.dimensions:
            dimnames.append(dimn)

        return typeCode,dimnames,var_hndl.attributes

    #=============================================
    # PyNIO: Define a NetCDF file from an existing NetCDF file
    #=============================================
    def define_file(self, new_file,var_name,meta_list,template_file,template_var):   
        """
        Define a NetCDF file from an existing NetCDF file.  Will also write meta vars.

        Parameters:
            new_file (NioFile): A pointer to a NioFile object.
            var_name (str): The name of the variable to read from.
            meta_list (list): A list of meta variable names as strings.
            template_file (str): The full path and file name of a template file to copy.
            template_var (str): Name to copy variable from the template file. 

        Returns:
            all_vars (dict): A dictionary containing variable names as keys and their corresponding
                             NioVariable object as the value.
            new_file (NioFile): A pointer to a NioFile object.
         
        """
        all_vars = {}
        temp_file = self.open_file(template_file)
        # Create attributes, dimensions, and variables
        attr = temp_file.attributes
        dims = temp_file.dimensions
        for n,v in attr.items():
            if n=='history':
                v = 'Standardized' + '\n' + v
            setattr(new_file,n,v)
        for var_d,l in dims.items():
            if var_d == "time":
                new_file.create_dimension(var_d, None)
            else:
                new_file.create_dimension(var_d,l)
        # define meta vars
        for meta_name in meta_list: 
            typeCode,dims,attribs = self.get_var_info(temp_file,meta_name)
            all_vars[meta_name] = self.create_var(new_file,meta_name,typeCode,dims,attribs)
        # define var
        typeCode,dims,attribs = self.get_var_info(temp_file,template_var)
        all_vars[var_name] = self.create_var(new_file,var_name,typeCode,dims,attribs)
        # Write meta vars
        for meta_name in meta_list:
            self.write_meta_var(all_vars[meta_name],meta_name,temp_file.variables[meta_name])        

        return all_vars,new_file

    #=============================================
    # PyNIO: Write meta data information to the file
    #=============================================
    def write_meta_var(self, out_meta,var_name,in_meta):
        """
        Write the meta data information to the file

        Parameters:
            out_meta (NioVariable): Meta variable to write the output to.
            var_name (str): The name of the meta variable.
            in_meta (NioVariable): Meta variable to read/copy from.
        """
        if in_meta.rank > 0:
            out_meta[:] = in_meta[:]
        else:
            out_meta.assign_value(in_meta.get_value()) 

    #=============================================
    # PyNIO: Write variable data to the file
    #=============================================
    def write_var(self, all_vars, values, var_name, index=-99):
        """
        Write variable data to the file.

        Parameters:
            all_vars (dict): A dictionary containing variable names as keys and their corresponding
                             NioVariable object as the value.
            values (numPy array): The values to write to the netCDF file.
            var_name (str): The name of the variable.
            index (int): Optional.  The time index to write.  Default time index is set to 0.
        """
        import numpy as np
   
        if (all_vars[var_name].typecode() == 'i'):
            t = np.long
        else:
            t = np.float32

        if not values.shape:
            if (index == -99):
                all_vars[var_name][0] = values.astype(t)
            else:
                all_vars[var_name][index] = values.astype(t)
        else:
            if 'time' ==  var_name:
                all_vars[var_name][0] = values[0].astype(t)
            else:
                if (index == -99):
                    all_vars[var_name][:] = values[:].astype(t)
                else:
                    all_vars[var_name][index] = values[:].astype(t)


#=============================================
# NetCDF4-Python I/O
#=============================================
class NetCDF4PyPort(object):

    def __init__(self):
        super(NetCDF4PyPort, self).__init__()
        self.compressionLevel = 0

    #=============================================
    # NetCDF4Py: Open an existing NetCDF file
    #=============================================
    def open_file(self, file_name):
        """
        Open a NetCDF file for reading. 

        Parameters:
            file_name (str): Name, including full path, of existing NetCDF file
                             to open for reading.

        Returns:
            open_file (netCDF4.Dataset): A pointer to a netCDF4.Dataset object. 
        """
        open_file = netCDF4.Dataset(file_name,"r+")
        return open_file

    #=============================================
    # NetCDF4Py: Reads and returns a chunk of data
    #=============================================
    def read_slice(self, open_file, var, index, all_values=False):
        """
        Retreives a chunk of data. 

        Parameters:
            open_file (netCDF4.Dataset): A pointer to an open netCDF4.Dataset object.
            var (str): Name of variable to retreive.
            index (int): Time dimension idndex to retreive.
            all_values (bool): Optional argument to retreive all dimensions.

        Returns:
            var_val (numPy array): The retreived values. 
        """
        var_hndl = open_file.variables[var]
        if all_values:
            var_val = var_hndl[:]
        else:
            var_val = var_hndl[index]
        return var_val

    #=============================================
    # NetCDF4Py: Close an open NetCDF file
    #=============================================
    def close_file(self, open_file):
        """                     
        Close an open NetCDF file. 

        Parameters:
            open_file (netCDF4.Dataset): A pointer to an open netCDF4.Dataset object.
        """
        open_file.close()

    #=============================================
    # NetCDF4Py: Create a  NetCDF file
    #=============================================
    def create_file(self, new_file_name,ncformat,hist_string=None):
        """
        Create a NetCDF file for writing. 

        Parameters:
            new_file_name (str): Name, including full path, of the new
                                 NetCDF file to create.
            ncformat (str): Type of NetCDF file to create.  
                            Options:
                            'netcdf4c': NetCDF4 with Level 1 compression
                            'NetCDF4Classic': NetCDF4 Classic
                            'Classic': NetCDF3
                            'netcdfLarge': NetCDF 64bit Offset
            hist_string (str): Optional.  A string to append to the histroy attribute.

        Returns:
            new_file (netCDF4.Dataset): A pointer to a netCDF4.Dataset object. 
        """
        # The netcdf output format
        if ('netcdf4c' in ncformat):
            Format = 'NETCDF4_CLASSIC'
            if (ncformat[-1].isdigit()):
                self.compressionLevel = ncformat[-1]
        elif (ncformat == 'netcdf4'):
            Format = 'NETCDF4_CLASSIC'
        elif (ncformat == 'netcdf'):
            Format  = 'NETCDF3_CLASSIC'
        elif (ncformat == 'netcdfLarge'):
            Format = 'NETCDF3_64BIT'
        else:
            print "WARNING: Selected netcdf file format (",ncformat,") is not recongnized."
            print "Defaulting to netcdf4Classic format."
            Format  = 'NETCDF4_CLASSIC'
        if hist_string is None:
           hist_string = 'clim-convert'+new_file_name
        # Open new output file
        new_file = netCDF4.Dataset(new_file_name, "w", format=Format)
        new_file.history = hist_string

        return new_file

    #=============================================
    # NetCDF4Py: Define a  NetCDF variable
    #=============================================
    def create_var(self, new_file,var_name,typeCode,dims,attrib):
        """
        Define a NetCDF variable

        Parameters:
            new_file (netCDF4.Dataset): A pointer to a netCDF4.Dataset object.
            var_name (str): The name of the variable to create.
            typeCode (str): Type of variable.  
                            Valid values:
                            'd': 64 bit float 
                            'f': 32 bit float 
                            'l': long 
                            'i': 32 bit integer 
                            'h': 16 bit integer 
                            'b': 8 bit integer 
                            'S1': character
            dims (tuple): A tuple that contains the names of the dimensions 
                          for the variable.
            attrib (list): A list of strings to add as attributes for the variable. 

        Returns:
            var (netCDF4.Variable): Returns a netCDF4.Variable object.    
        """
        if self.compressionLevel > 0:
            var = new_file.createVariable(var_name,typeCode,tuple(dims),zlib=True,complevel=int(self.compressionLevel))
        else:
            var = new_file.createVariable(var_name,typeCode,tuple(dims))
        for att in attrib:
            var.setncattr(var_name, att)
        return var

    #=============================================
    # NetCDF4Py: Retreive a variable's type, dims, attribs
    #=============================================
    def get_var_info(self, template_file,var_name):
        """
        Retreive a variable's type, dimensions, and attributes

        Parameters:
            template_file (netCDF4.Dataset): A pointer to a netCDF4.Dataset object.
            var_name (str): The name of the variable to read from.

        Returns:
            typeCode (str): Type of variable. 
            dimnames (tuple): A tuple that contains the names of the dimensions.
            var_hndl.attributes (list): A list of attributes for the variable.    
        """
        var_hndl = template_file.variables[var_name]
        typeCode = var_hndl.datatype

        dimnames = []
        for dimn in var_hndl.dimensions:
            dimnames.append(dimn)
        
        attribs={}
        for n in var_hndl.ncattrs():
           attribs[n] = var_hndl.__getattribute__(n)

        return typeCode,dimnames,attribs

    #=============================================
    # NetCDF4Py: Define a NetCDF file from an existing NetCDF file
    #=============================================
    def define_file(self, new_file,var_name,meta_list,template_file,template_var):
        """
        Define a NetCDF file from an existing NetCDF file.  Will also write meta vars.

        Parameters:
            new_file (netCDF4.Dataset): A pointer to a netCDF4.Dataset object.
            var_name (str): The name of the variable to read from.
            meta_list (list): A list of meta variable names as strings.
            template_file (str): The full path and file name of a template file to copy.
            template_var (str): Name to copy variable from the template file. 

        Returns:
            all_vars (dict): A dictionary containing variable names as keys and their corresponding
                             netCDF4.Variable object as the value.
            new_file (netCDF4.Dataset): A pointer to a netCDF4.Dataset object.
         
        """
        all_vars = {}
        temp_file = self.open_file(template_file)
        # Create attributes, dimensions, and variables
        attr = temp_file.ncattrs()
        dims = temp_file.dimensions
        for n in attr:
            v = temp_file.getncattr(n)
            if n=='history':
                v = 'Standardized' + '\n' + v
            new_file.setncattr(n,v)
        for var_d,l in dims.items():
            if var_d == "time":
                new_file.createDimension(var_d, None)
            else:
                new_file.createDimension(var_d,len(l))
        # define meta vars
        for meta_name in meta_list:
            typeCode,dims,attribs = self.get_var_info(temp_file,meta_name)
            all_vars[meta_name] = self.create_var(new_file,meta_name,typeCode,dims,attribs)
        # define var
        typeCode,dims,attribs = self.get_var_info(temp_file,template_var)
        all_vars[var_name] = self.create_var(new_file,var_name,typeCode,dims,attribs)
        # Write meta vars
        for meta_name in meta_list:
            self.write_meta_var(all_vars[meta_name],meta_name,temp_file.variables[meta_name])

        return all_vars,new_file

    #=============================================
    # NetCDF4Py: Write meta data information to the file
    #=============================================
    def write_meta_var(self, out_meta,var_name,in_meta):
        """
        Write the meta data information to the file

        Parameters:
            out_meta (netCDF4.Variable): Meta variable to write the output to.
            var_name (str): The name of the meta variable.
            in_meta (netCDF4.Variable): Meta variable to read/copy from.
        """
        out_meta[:] = in_meta[:]

    #=============================================
    # NetCDF4Py: Write variable data to the file
    #=============================================
    def write_var(self, all_vars, values, var_name, index=-99):
        """
        Write variable data to the file.

        Parameters:
            all_vars (dict): A dictionary containing variable names as keys and their corresponding
                             netCDF4.Variable object as the value.
            values (numPy array): The values to write to the netCDF file.
            var_name (str): The name of the variable.
            index (int): Optional.  The time index to write.  Default time index is set to 0.
        """
        import numpy as np

        if (all_vars[var_name].datatype == 'i'):
            t = np.long
        else:
            t = np.float32

        if not values.shape:
            if (index == -99):
                all_vars[var_name][0] = values.astype(t)
            else:
                all_vars[var_name][index] = values.astype(t)
        else:
            if 'time' ==  var_name:
                all_vars[var_name][0] = values[0].astype(t)
            else:
                if (index == -99):
                    all_vars[var_name][0,:] = values[:].astype(t)
                else:
                    all_vars[var_name][index,:] = values[:].astype(t)


    
