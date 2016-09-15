import Nio
import time,os,sys
import numpy as np

'''
  This file contains functions that are needed to file I/O.
____________________________
Created on November 20, 2014

@author: Sheri Mickelson <mickelso@ucar.edu> 
'''
#==============================================================================
#
# Functions used to Open/Close File(s)
#
#==============================================================================

def open_file(var, month_dict, split, mess='None'):

    '''
    Open the original time series or time slice file one at a time

    @param var          Variable used to identify which timeseries file to open.

    @param month_dict   A dictionary that contains all file references for that year.

    @param split        Look to see if the there is a split name in the file.
  
    @param mess         Optional:  To print an open message.

    @return my_file     Returns a file pointer to the newly opened file.
    '''
    # Parse the filename and datestamp out of the 
    #i_prefix = month_dict['fn']
    #date_stamp = month_dict['date_stamp']
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
            #print 'Opening: ',i_fn 
            if not (os.path.isfile(i_fn)):
                print("ERROR: Cannot find ",i_fn,".  Exiting.") 
                sys.exit(20) 
    # Open the original netcdf file
    if ('None' not in mess):
        print 'Opening: ',mess, i_fn
    my_file = Nio.open_file(i_fn,"r")
    return my_file


def open_all_files(hist_dict,months_to_average,years,var,split,ave_type,depend,fyr):

    '''
    Opens all of the nc files that are needed to compute this portion of the averaging

    @param hist_dict           A lookup table/dictionary that lists all file lookup information
                               for all years/months that will be averaged.

    @param months_to_average   A list that includes all months that are included in this average.

    @param years               A list of the years the average spans.

    @param var		       For timeseries files, this indicates which file needs to be opened.

    @param split               Split filename indicator

    @param ave_type            Key to identify which type of averaging is being calculated.

    @param depend              Boolean variable to indicate if this average will be computed from previously calculated files.

    @returns file_dict         Dictionary that contains all of the file pointers searchable by year/month.

    @returns open_list         A list of all of the open files           
    '''
    # for each year and month that's needed for this average, open the file where that
    # slice is found
    file_dict = {} 
    open_list = []
    last_opened_date = 'null'
    last_opened_file = 'null'
    years_to_open = list(years)
    # check to see if we need to open an extra year
    if(ave_type == 'djf'):
        prev_year = int(years[0])-1
        if (prev_year in hist_dict.keys()):
            if (len(hist_dict[years[0]-1])<1):
                last_index = len(years)-1
                if (len(hist_dict[years[last_index]+1])<2):
                    print 'ERROR: In order to calculate DJF, you must have either December',str(years[0]-1),'or January and February',str(years[last_index]+1),'.  Exiting'
                    sys.exit(21)
    if((ave_type == 'djf' and depend == False) or ave_type == 'next_jan'
                    or ave_type == 'next_feb' or ave_type == 'prev_dec'):
        pull_year = which_winter_year(hist_dict, 11,years[0],fyr)
        if(pull_year not in years):
            years_to_open.append(pull_year)
        pull_year = which_winter_year(hist_dict, 0,years[-1],fyr)
        if(pull_year not in years):
            years_to_open.append(pull_year)
    for yr in years_to_open:
        monthly_dict = {}
        for m in months_to_average:
            if (m in hist_dict[yr]):
                if (hist_dict[yr][m]['date_stamp'] == last_opened_date):
                    monthly_dict[m]={'fp':last_opened_file} 
                else:
                    f = open_file(var,hist_dict[yr][m],split)
                    monthly_dict[m]={'fp':f} 
                    open_list.append(f)
                    last_opened_date = hist_dict[yr][m]['date_stamp']
                    last_opened_file = f
        file_dict[yr] = monthly_dict
    return file_dict,open_list

def close_all_files(open_list):

    '''
    Closes all of the nc files that were used to compute this portion of the averaging

    @param open_list    A list that includes the pointers to all of the open history files.
    '''
    # for each year and month that was opened, close
    for f in open_list:
        Nio.close(f)    

def open_file_return_var(fn, var):

    '''
    Opens a netCDF file and returns the full variable. 

    @params fn       The netCDF filename to open.

    @params var      The netCDF variable to get values for.

    @return var_val  The values for the netCDF variable.
    '''

    # Open the original netcdf file 
    my_file = Nio.open_file(fn,"r")

    # Get variable
    var_hndl = my_file.variables[var]
    var_val = var_hndl[:]

    return var_val

#==============================================================================
#
# Functions to create and define a new necdf file
#
#==============================================================================

def get_out_fn(ave_type, prefix, date, suffix, reg=-99):
    
    '''
    Puts together the correct output/average filename.

    @param ave_type       Type of average that is being calculated.

    @param prefix         The prefix of the input filenames.

    @param date           Date stamp to be included in the filename.

    @param suffix         The suffix to be appended to the end of the output/average file.

    @param reg		  Used by regional averages.  If not a regional average, -99 is passed

    @return outfile_name  The output/average filename.
    '''
    if (ave_type == 'ya'):
        outfile_name = prefix+"."+date+"."+suffix
    elif (ave_type == 'tavg'):
        outfile_name = ave_type+"."+date+"."+suffix
    elif(ave_type == 'mavg'):
        outfile_name = ave_type+"."+date+"."+suffix
    elif(ave_type == 'hor.meanyr'):
        outfile_name = reg+'_'+ave_type+"."+date+"."+suffix
    elif(ave_type == 'hor.meanConcat'):
        outfile_name = reg+'_hor_mean_'+ave_type+"."+prefix+"_"+date+"."+suffix
    else:
        outfile_name = prefix+"."+date+"."+suffix

    return outfile_name

def create_ave_file(my_file,outfile,hist_string,ncformat,years,collapse_dim=''):
 
    '''
    Opens up/Creates a new file to put the computed averages into.

    @param my_file       A sampled input file pointer.

    @param outfile       Filename of the new output/average file.

    @param hist_string   A string that contains the file history for the history attribute

    @param ncformat      Format to write the NetCDF file out as.

    @param collapse_dim  Dimension to collapse across 

    @return new_file     Returns a file pointer to the newly opened file.
    '''
    dims = my_file.dimensions
    attr = my_file.attributes
    vars = {}

    new_file_name = outfile
    # Set pyNIO netcdf file options
    opt = Nio.options()
    # The netcdf output format
    if (ncformat == 'netcdf4c'):
        opt.Format = 'NetCDF4Classic' 
        opt.CompressionLevel = 1
    elif (ncformat == 'netcdf4'):
        opt.Format = 'NetCDF4Classic'
    elif (ncformat == 'netcdf'):
        opt.Format  = 'Classic'
    elif (ncformat == 'netcdfLarge'):
        opt.Format = '64BitOffset'
    else:
        print "WARNING: Seltected netcdf file format (",ncformat,") is not recongnized."
        print "Defaulting to netcdf3Classic format."
        opt.Format  = 'Classic'
    opt.PreFill = False
    new_file = Nio.open_file(new_file_name, "w", options=opt, history=hist_string)
    #setattr(new_file,'yrs_averaged',years)
 
    # Create attributes, dimensions, and variables
    for n,v in attr.items():
        if n=='history':
            v = hist_string + '\n' + v 
        setattr(new_file,n,v)
    for var_d,l in dims.items():
        if var_d == "time":
            if "time" not in collapse_dim: 
                new_file.create_dimension(var_d, None)
        else:
            if var_d not in collapse_dim:
                new_file.create_dimension(var_d,l)
    setattr(new_file,'yrs_averaged',years)
    return new_file

def create_meta_var(my_file, var_name, new_file,collapse_dim=''):

    '''
    Creeate a meta variable within the average file
    called only by root

    @param my_file   A pointer to the input file in which to get variable info from.

    @param var_name  Meta variable name to be defined

    @param new_file  A pointer to the output file.

    @returns temp    A variable pointer.
    '''

    var_hndl = my_file.variables[var_name]
    typeCode = var_hndl.typecode()

    dimnames = []
    for dimn in var_hndl.dimensions:
        if dimn not in collapse_dim:
            dimnames.append(dimn)
    temp = new_file.create_variable(var_name,typeCode,tuple(dimnames))
    for ka,va in var_hndl.attributes.items():
        setattr(temp,ka,va)

    return temp

def create_var(var_name, typeCode, dimnames, attr, new_file):

    '''
    Creeate a variable within the average file
    called only by root

    @param var_name  Meta variable name to be defined.

    @param typeCode  Variable type.

    @param dimnames  Dimension names for that variable.

    @param attr      The variable's attributes.

    @param new_file  A pointer to the output file.

    @return temp     A variable pointer.
    '''
    temp = new_file.create_variable(var_name,typeCode,tuple(dimnames))
    for ka,va in attr.items():
      if ka != 'scale_factor':
          setattr(temp,ka,va)

    return temp

def get_var_info(my_file, var_name, ave_descr, collapse_dim=''):

    '''
    Gets the variable information that is needed for the rank to pass this
    information on to the root and have root create the variable in the nc file
    correctly.

    @param my_file     A pointer to the sampled input file.

    @param var_name    Name of the variable to retr. info on.

    @return typeCode   Type of the variable.

    @return dimnames   The name of the variable's dimensions.

    @return attributes The attributes for the variable.
    '''

    var_hndl = my_file.variables[var_name]
    typeCode = var_hndl.typecode()

    dimnames = []
    for dimn in var_hndl.dimensions:
        if('preproc' in ave_descr):
            if (my_file.unlimited(dimn)):
                dimnames.append(dimn)
        else:
            if dimn not in collapse_dim:
                dimnames.append(dimn)
    return typeCode,dimnames,var_hndl.attributes

def define_ave_file(l_master,serial,var_list,lvar_list,meta_list,hist_dict,hist_type,ave_descr,prefix,
                        outfile,split,split_name,out_dir,simplecomm,nc_formt,month,key,clobber,firstYr,
			endYr,ave_date,pre_proc_attr=None, pre_proc_variables=None,collapse_dim=''):

    '''
    The function controls the defining of a new NetCDF file.

    @param l_master      Boolean, if this task is a local master.

    @param serial        Boolean, if we are running in serial mode.

    @param var_list      Global list of variables to be included in this output file.

    @param lvar_list     Local list of variables that this mpitask is responsible for.

    @param meta_list     A list of meta variables to be included in the output file.

    @param hist_dict     A lookup table with input file references for each year/month.

    @param hist_type     Output format of the NetCDF file.

    @param ave_descr     Code for which average is being calculated.

    @param prefix        Input and output filename prefix.

    @param outfile       Full name of the output/averaged file.

    @param split         Boolean, if input file is split spacially.

    @param split_name    File name indicator for spatially split files.

    @param out_dir       Directory to create the NetCDF in.

    @param simplecomm    Class that controls the MPI communication.

    @param nc_formt      File format for the output/average file.

    @param month         Indicates which month index of the file to open to retreive meta/dimensional values

    @param key           A variable to use that has a specific file attached to that name.
                         Used as the file to retreive meta data from. 

    @param clobber       Boolean to remove an already existing average file.

    @param firstYr       The first year in the average range.

    @param endYr         The last year in the average range.

    @param pre_proc_attr  Optional: used in the pre_proc calculations to specify specific attributes to use.

    @param pre_proc_variable Optional:  (used in the pre_proc calculations) variable names that need to be created.

    @param collapse_dim Optional: dimension to collapse/average on 

    @return all_files_vars  All of the variable pointers.

    @return new_file        Pointer to the new output file.
    '''
    VAR_INFO_TAG = 30

    my_file = {}
    all_files_vars = {}
    new_file = 'null'

    yr = int(ave_descr[1])

    # Open/create the average files.  Then get variable information from other procs and add these variables to the files. 
    if serial or l_master:
    # We need to retreive coord data from an original time series file.  Since particular file doesn't matter, just open the first one in the variable list
        first_fn = var_list[0]
        if ('__meta' in first_fn):
             first_fn = key 
        if ('preproc' in ave_descr):
            vn_split = first_fn.split('_')
            if ('ext' in vn_split[0] or 'ai' in vn_split[0]):
                first_fn = 'aice'
            else:
                first_fn = vn_split[0][1:]

        if hist_type == 'slice' and '__d' not in ave_descr:
            my_file[first_fn] = open_file(first_fn, hist_dict[firstYr][0],split_name)
        else:
            my_file[first_fn] = open_file(first_fn, hist_dict[yr][month],split_name)
        year_slice = yr
        if split and 'preproc' not in ave_descr:
            new_file_name = out_dir+"/"+split_name+"_"+outfile
        else:
            new_file_name = out_dir+"/"+outfile
        hist_string = time.strftime("%c")+': pyAverager ' + ':'.join(ave_descr) + ' ' + prefix +'* ' + outfile
        if os.path.isfile(new_file_name):
            if (clobber):
                print 'Removing older version of:',new_file_name
                os.remove(new_file_name)
            else:
                print 'ERROR: ',new_file_name,' exists.  Please remove and continue.  Or pass clobber=True to PyAverager.  Exiting.'
                sys.exit(40)
        years = ave_date 
        new_file = create_ave_file(my_file[first_fn],new_file_name,hist_string,nc_formt,years,collapse_dim)
        # Remove extra dims from meta_list
        if collapse_dim is not None:
            dim_orig = my_file[first_fn].dimensions
            for d in dim_orig:
                if d in collapse_dim:
                    meta_list.remove(d)
        # Add meta variables
        temp = {}
        for mv in meta_list:
            temp[mv] = create_meta_var(my_file[first_fn],mv,new_file,collapse_dim)
        all_files_vars = temp

    # Have each rank open it's own variable file(s), retreive variable info, and send to root to create variable 
    if ((hist_type == 'slice' or ('__d' in ave_descr)) and (serial or not l_master) and len(lvar_list) > 0): # Open just once because all vars are located in one file
        f = open_file(lvar_list[0], hist_dict[yr][month],split_name)
    for orig_var_name in lvar_list:
        if ('__meta' in orig_var_name):
            var_fn = key 
        else:
            var_fn = orig_var_name
        if ('hor.meanConcat' in ave_descr or 'preproc' in ave_descr):
            vn_split = var_fn.split('_')
            if ('preproc' in ave_descr):
                if ('time' in var_fn):
                    var_fn = 'aice'
                    lookup_vn = orig_var_name
                    unit_var = orig_var_name
                    write_var = orig_var_name
                else:
                    if ('ext' in vn_split[0]):
                        lookup_vn = vn_split[0]
                        unit_var = vn_split[0]
                    else:
                        lookup_vn = vn_split[0][1:]
                        unit_var = vn_split[0][1:]
                    write_var = orig_var_name
                    var_fn = vn_split[0][1:]
            else:
                lookup_vn = vn_split[0]
                write_var = orig_var_name
            if ('ext' in lookup_vn or 'ai' in lookup_vn):
                lookup_vn = 'aice'
                var_fn = 'aice'
        else:
            lookup_vn = var_fn
            write_var = orig_var_name
        if (hist_type == 'series' and (serial or not l_master)): # Open each file because there is only one series variable per file
            f = open_file(var_fn, hist_dict[yr][month],split_name)
        if ('__meta' in orig_var_name):
            parts = orig_var_name.split('__')
            lookup_vn = parts[0] 
            write_var = parts[0]        
 
        if(serial or not l_master):
            type_code,dimnames,attr = get_var_info(f,lookup_vn,ave_descr,collapse_dim)
            if (pre_proc_attr is not None and 'time' not in unit_var):
                pre_proc_attr['units'] = pre_proc_variables[unit_var]['units']
                attr = pre_proc_attr
            var_info = {'varname':write_var, 'origname':orig_var_name, 'type_code':type_code, 'dim_names':dimnames, 'attr':attr}
            if (not serial):
                simplecomm.collect(data=var_info,tag=VAR_INFO_TAG)
        if (serial or l_master):
            if (not serial):
                r_rank,var_info = simplecomm.collect(tag=VAR_INFO_TAG)
            temp = {}
            vn = var_info['varname']
            orig = var_info['origname']
            #  Add variable to file.  If vn is 'hor.meanyr', we need to add a _DIFF and _RMS variable per variable in loop.
            if ('hor.meanyr' in ave_descr and '__meta' not in orig):
                for var in (vn,vn+'_DIFF',vn+'_RMS'):
                    temp[var] = create_var(var, var_info['type_code'], ['time','z_t'], var_info['attr'],new_file)
            else:
                temp[vn] = create_var(var_info['varname'], var_info['type_code'], var_info['dim_names'], var_info['attr'],new_file)
        if (hist_type == 'series' and (serial or not l_master)):
            f.close()
    if (hist_type == 'slice' and (serial or not l_master) and len(lvar_list) > 0):
        f.close()
    if serial or l_master:
        all_files_vars.update(new_file.variables)
        # All vars are defined, Write all meta vars to the files
        for mv in meta_list:
            write_meta(all_files_vars, mv, my_file[first_fn])
    return all_files_vars,new_file

#==============================================================================
#
# Functions used to write out netcdf variables
#
#==============================================================================

def write_meta(temp, var_name, my_file):

    '''
    Write a meta variable within the average file
    Called only by root

    @param temp        A pointer to the meta variable within the new output file.

    @param var_name    The meta variable name.

    @param my_file     A pointer to the input file from where to copy the meta variable from. 
    '''
    in_meta = my_file.variables[var_name]
    out_meta = temp[var_name]
    typeCode = in_meta.typecode()
    if in_meta.rank > 0:
        out_meta[:] = in_meta[:]
    else:
        out_meta.assign_value(in_meta.get_value())


def write_averages(temp, averages, var_name, index=-99):

    '''
    Write a variable within the average file
    Called only by root

    @param temp       A pointer to the variable within the new output file.

    @param averages   A numPy array that holds the averaged values.

    @param var_name   The variable name that is being written.

    @param index      Optional: Insert at a certain time index.
    '''

    if (temp[var_name].typecode() == 'i'):
        t = np.long
    else:
        t = np.float32

    if not averages.shape:
        if (index == -99):
            temp[var_name][0] = averages.astype(t)
        else:
            temp[var_name][index] = averages.astype(t)
    else:
        if 'time' ==  var_name:
            temp[var_name][0] = averages[0].astype(t)
        else:
            if (index == -99):
                temp[var_name][:] = averages[:].astype(t)
            else:
                temp[var_name][index] = averages[:].astype(t)

#==============================================================================
#
# Misc climate/netcdf file functions
#
#==============================================================================

def which_winter_year(hist_dict, month, year, start_year):

    '''
    Function to figure out for a given winter month (December, January, or February), 
    which year to grab the data from.  

    @param hist_dict     A dictionary that holds file references for all years/months.

    @param month         The month in which we are looking for the correct year.

    @param year          The current indexed year.

    @param start_year    The first year that is being averaged.

    @return new_yr        Returns the correct year to get input data for this month.
    '''
    # Figure out if we need to use the previous dec or the next jan/feb
    # Check if this is a djf ave.  If so, find correct year to pull the slice from

    # Start with the new_yr equal to the current indexed year 
    new_yr = year

    if (month == 11): # Dec average (python indexing starts at 0)
        # next two lines check if a dictionary entry exists for the previous year and if it has entries
        # if it does, then pull from the previous year
        if ((start_year-1) in hist_dict):
            if (len(hist_dict[start_year-1]) > 0):
                new_yr = year-1
    else: # Either a Jan or Feb average
        # next two lines check if a dictionary entry exists for the previous year and if it has entries
        # if it does, then pull from this year for Jan and Feb
        if ((start_year-1) in hist_dict):
            if (len(hist_dict[start_year-1]) > 0):
                new_yr = year
            else:
                new_yr = year + 1
        else:
            new_yr = year + 1
    #print month,": "," old year: ",year," new year: ",new_yr,(len(hist_dict[start_year-1]))   
    return new_yr

