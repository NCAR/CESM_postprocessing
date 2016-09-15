import Nio
import climFileIO
import numpy as np
from numpy import ma as MA
import os

def combine_regions(fn1, fn2, outfile, dim1, dimlen1, dim2, dimlen2,  split_dim, clobber):

    '''
    This function stritches together two spatially split files into one file.  It
    will also fill in missing lat values to create a complete grid. 

    @param fn1         The name of the first file (southern).

    @param fn2         The name of the second file (northern).

    @param outfile     The output/combined file name.

    @param dim1        The name of one of the spatial dimensions.

    @param dimlen1     The size of dim1.

    @param dim2        The name of the other spatial dimension.

    @param dimlen2     The size of dim2.

    @param split_dim   The name of the dimension in which the file is split across.
                       Must match the dim name that is in the original split files. 

    @param clobber     Boolean to delete average files if they exist on disk.
    ''' 
    all_files_vars = {}
    temp = {}
 
    # Open the two partial files
    f1 = Nio.open_file(fn1,"r")
    f2 = Nio.open_file(fn2,"r")
   
    # Get the sizes of the partial dimensions
    size1 = f1.dimensions[split_dim]
    size2 = f2.dimensions[split_dim]

    if os.path.isfile(outfile):
        if (clobber):
            print 'Removing older version of:',outfile
            os.remove(outfile)
        else:
            print 'ERROR: ',outfile,' exists.  Please remove and continue.  Or pass clobber=True to PyAverager.  Exiting.'
            sys.exit(40)
    new_file = Nio.open_file(outfile,"w")

    # Define global attributes
    attr = f1.attributes
    for n,v in attr.items():
        setattr(new_file,n,v)

    # Define dimensions
    dims = f1.dimensions
    for var_d,l in dims.items():
        if var_d == "time":
            new_file.create_dimension(var_d, None)
        elif var_d == dim1:
            new_file.create_dimension(var_d,dimlen1)
        elif var_d == dim2:
            new_file.create_dimension(var_d,dimlen2)
        else:
            new_file.create_dimension(var_d,l)

    # Define variable lists
    meta_list = []
    var_list = []
    complete_var_list = list(f1.variables.keys())
    for var in complete_var_list:
        if (split_dim not in f1.variables[var].dimensions):
            meta_list.append(var)
        else:
            var_list.append(var)

    # Define meta vars
    for mv in meta_list:
        temp[mv] = climFileIO.create_meta_var(f1,mv,new_file)
    all_files_vars = temp

    # Define variables
    for vn in var_list:
        var_hndl = f1.variables[vn]
        dimnames = []
        for dimn in var_hndl.dimensions:
            dimnames.append(dimn)
        temp[vn] = climFileIO.create_var(vn, var_hndl.typecode(), dimnames, var_hndl.attributes, new_file)  
    #All vars are defined, Write all meta vars to the file
    for mv in meta_list:
        local_write_time = climFileIO.write_meta(all_files_vars, mv, f1)

    # Find the unlimited dimension that will be used later while writing
    dimNames = list(f1.dimensions.keys())
    for dim in dimNames:
        if (f1.unlimited(dim)):
            unlimited = dim


    # Combine the values from both files
    for vn in var_list:
        var_hndl_1 = f1.variables[vn]
        var_val_1 = var_hndl_1[:]

        var_hndl_2 = f2.variables[vn]
        var_val_2 = var_hndl_2[:]

        new_var_hndl = new_file.variables[vn]
        new_var_val = new_var_hndl
        new_var_shape = new_var_val.shape
 
        # Search to find the axis that was split, then set up a numpy array to fill in the gap
        # between the split 
        fill_shape = list(var_val_1.shape)
        split_dim_size = f1.dimensions[split_dim] 
        split_axis = 0
        for i in range(0,len(fill_shape)):
            if fill_shape[i] == split_dim_size:
                fill_shape[i] = new_file.dimensions[split_dim] - (size1+size2) 
                split_axis = i
        missing_vals = np.empty((fill_shape))
        missing_vals.fill(1.e30) 

        combined_val = np.concatenate((var_val_2,missing_vals), axis=split_axis)
        combined_val = np.concatenate((combined_val,var_val_1), axis=split_axis)

        # Write to the file
        if (unlimited in var_hndl_1.dimensions):
            temp[vn][0] = combined_val[:].astype(np.float32)
        else:
            out_meta = temp[vn]
            out_meta.assign_value(combined_val.astype(np.float32))

    new_file.close()

