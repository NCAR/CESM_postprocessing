import glob,sys,os
import Nio
import time
import numpy.ma as ma

def fn_split(name_fp, prefix, suffix, split_fn, date_pattern, file_pattern):

    '''
    Puts together a split filename

    @param name_fp        The filename including path. 

    @param prefix         The prefix that matches the input filenames.

    @param suffix         The suffix that matches the input filenames.

    @param split_fn       The name of the split key.

    @param date_pattern   The pattern of the date string.

    @param file_pattern   The file pattern that matches the input filenames.
   
    @return fn_decode     The name of the file.

    '''

    path,name = os.path.split(name_fp)

    hems = split_fn.split(",")
    index = 0
    current_pattern = 0
    passed_prefix = False
    fn_decode = {}
    for p in file_pattern:
        if p[0] == '$':
            if p=='$prefix':
                fn_decode['prefix'] = prefix
                index = len(prefix) + index
                passed_prefix = True
            elif p=='$suffix':
                fn_decode['suffix'] = suffix
                index = len(suffix) + index
            elif p=='$hem':
                for h in hems:
                    if (file_pattern[current_pattern-1]+h+file_pattern[current_pattern+1]) in name:
                        fn_decode['hem'] = h
                        index = len(h) + index     
            else:
                if passed_prefix: 
                    name_loc = [n for (n,e) in enumerate(name[index:]) if e == file_pattern[current_pattern+1]] 
                else:
                    no_prefix = name.replace(prefix,'')
                    name_loc = [n for (n,e) in enumerate(no_prefix[index:]) if e == file_pattern[current_pattern+1]] 
                similar_left = 0
                for m in range(current_pattern+1, len(file_pattern)):
                    if file_pattern[m] == file_pattern[current_pattern+1]:
                        similar_left = similar_left+1
                stop_index = name_loc[len(name_loc)-similar_left]+index 
                value = name[index:stop_index] 
                fn_decode[p[1:]] = value
                index = len(value) + index 
        else:
            index = len(p) + index

        current_pattern = current_pattern + 1

    return fn_decode

def get_slice_fn(file_pattern, directory, prefix, suffix, stamp):

    '''
    Puts together a time slice filename

    @param file_pattern   The file pattern that matches the input filenames.

    @param directory      The directory where the input data is located.

    @param prefix         The prefix that matches the input filenames.

    @param suffix         The suffix that matches the input filenames.

    @param stamp          The timestamp that matches the input filename.

    @return filename      The name of the file.

    @return file_prefix   The prefix of the file.

    '''

    filename = ''
    file_prefix = directory+'/'
    stop = False

    for p in file_pattern:
        if p[0] == '$':
            if p=='$prefix': 
                filename = filename+prefix
                if not stop:
                    file_prefix = file_prefix+prefix
            if p=='$date_pattern':    
                filename = filename+stamp
                stop = True
            if p=='$suffix':
                filename = filename+suffix
        else:
            filename = filename+p       
            if not stop:
                file_prefix = file_prefix+p        
    
    return filename,file_prefix

def set_slices_and_vars_time_series(directory, file_pattern, date_pattern, prefix, suffix, start_yr, end_yr, split, split_fn):

    '''
    Create a  dictionary lookup based on time series files
    Also creates a list of variables to average and a list of meta vars

    @param directory      The directory where the input data is located.

    @param file_pattern   The file pattern to glob the input directory on.

    @param date_pattern   The pattern for the date string.

    @param prefix         The prefix to glob the input directory on.

    @param suffix         The suffix to glob the input directory on.

    @param start_yr       The first year that will be needed by the average(s).

    @param end_yr         The last year that will be needed by the average(s).

    @param split          Boolean, if input files are spit spatially.        

    @param split_fn       The key used to indicate which part of the split.

    @return hist_dict     A dictionary that lists all input file references for each
                          year/month needed by all averages.

    @return series_list   A list of all the variables within the input files that can
                          be averaged.

    @return meta_list     A list of the metadata that will not be averaged, but should be
                          included in the averaged/output file.
    
    @return key           A variable to use that has a specific file attached to that name.
                          Used as the file to retreive meta data from.
    '''  


    # We want to search for the previous year and the year after the last 
    # in case the averaging needs them
    if start_yr > 1:
        start_yr = start_yr - 1
    end_yr = end_yr + 1

    # Glob the directory and get a list of all matching names
    glob_string = directory+ "/"# + prefix + "*.nc"
    for p in file_pattern:
        if p =='$prefix':
            glob_string = glob_string + prefix
        elif ('$' in p):
            glob_string = glob_string + '*'
        else:
            glob_string = glob_string + p
    file_list = glob.glob(glob_string)

    # Foreach of the files, get date strings and get var list
    dates = []
    var_list = []
    for f in file_list:
        name_parts = fn_split(f, prefix, suffix, split_fn, date_pattern, file_pattern)
        dates.append(name_parts['date_pattern'])
        var_list.append(name_parts['var'])
    # remove duplicates by converting to a set
    date_list = set(dates)
    series_list = set(var_list)
    key = var_list[0]

    # Go through date_list and create a dictionary of the date breakdown
    date_lookup = {}
    for date in date_list:
        date_breakdown = {}
        date_split = date.split("-")
        date_breakdown["year1"] = int(date_split[0][0:4])
        date_breakdown["month1"] = int(date_split[0][4:6])
        date_breakdown["year2"] = int(date_split[1][0:4])
        date_breakdown["month2"] = int(date_split[1][4:6]) 
        date_lookup[date] = date_breakdown

    # Go through each year to average and make sure it exists within a found date range
    years = list(range(start_yr,end_yr+1))
    year_list = {}
    for yr in years:
        found = 0
        for stamp,date in date_lookup.items():
            if (yr >= date["year1"] and yr <= date["year2"]):
                if (found == 0):
                    found = 1
                    previousMonth = date["month2"] 
                    year_list[yr] = [stamp]
                else:
                    if (yr == date["year1"]):
                        if (previousMonth == (date["month1"]-1)):
                            year_list[yr].append(stamp)
                        #else:
                        #    print("ERROR: Split year -- doesn't look contiguous. Exiting.") 
                        #    sys.exit(22)
                    else:
                        print("ERROR: Found more than 1 file that contains year ", yr, ".  Exiting.")
                        sys.exit(23)
            else:
                if (found == 0):    
                    year_list[yr] = []
    # Are file dates contiguous?
    first = 1
    previous_year = 0
    previous_month = 0
    for stamp,date in date_lookup.items():
        if first == 1:
            previous_year = date["year2"]
            previous_month = date["month2"]
            first = 0 
        else:
            if ((previous_year == (date["year1"]-1) and (previous_month == 12 and date["month1"] == 1)) or 
		((previous_year == date["year1"]) and (previous_month == (date["month1"] - 1)))):
                previous_year = date["year2"]
                previous_month = date["month2"]
            #else:
            #    print("ERROR: There's a break in the sequence -- date stamps do not appear contiguous. Exiting.")
            #    sys.exit(22)
    # Create date/slice lookup table
    hist_dict = {}
    for yr in years:
        year_dict = {}
        if (len(year_list[yr]) < 1):
            if (yr != start_yr and yr != end_yr):
                print("ERROR: Did not find file for year",yr,".  Exiting.")
                sys.exit(20)
        for stamp in year_list[yr]:
            found = 0
            start_month = 1
            end_month = 12
            yr1 = date_lookup[stamp]["year1"]
            yr2 = date_lookup[stamp]["year2"]
            m1 = date_lookup[stamp]["month1"]
            m2 = date_lookup[stamp]["month2"]
            file_prefix = prefix
            
            # Find the start and end months on the files for indexing
            if (yr > yr1 and yr < yr2):
                found = 1
            elif(yr == yr1):
                if (m1 == 1):
                    found = 1
                else:
                    found = 1
                    start_month = m1
            elif(yr == yr2):
                if (m2 == 12):
                    found = 1
                else:
                    found = 1
                    end_month = m2


            # Set index for that month
            if (found == 1):
                months = list(range(start_month,end_month+1))     
                for m in months:
                    if (m1 == 1):
                        startIndex = (((yr - yr1)*12)+m)-1
                    else:
                        if(m < m1):
                            startIndex = ((((yr - yr1)-1)*12)+(12-m1+1)+m)-1
                        else:
                            startIndex = (((yr-yr1)*12)+(m-m1)+1)-1
                    # set the information for this month slice
                    year_dict[m-1] = {'directory':directory, 'fn':file_prefix, 'index':startIndex, 'date_stamp':stamp, 'pattern':file_pattern, 'suffix':suffix}
        # Add the year's info to the master dictionary
        hist_dict[yr] = year_dict

    # Now we just need to create a meta_list.  
    # Open first file from the file names we globbed earlier,
    # create a list of all variables in the file, 
    # take out the series var that is used in the file name, 
    # and list should be complete then.
    f = Nio.open_file(file_list[1],"r")
    temp_meta_list = list(f.variables.keys())
    name_parts = fn_split(file_list[1], prefix, suffix, split_fn, date_pattern, file_pattern)
    series_var = name_parts['var']
    temp_meta_list.remove(series_var)

    # find the unlimited dimesnion
    dimNames = list(f.dimensions.keys())
    for dim in dimNames:
        if (f.unlimited(dim)):
            unlimited = dim

    # Construct of meta var list
    meta_list = []  
    for var in temp_meta_list:
        if_series,if_variant,if_char = check_if_series_var(f,var,unlimited)
        if (if_series == False and if_variant == False):
            meta_list.append(var)
        elif (var in unlimited):
            series_list.add(var+'__meta')
        else:
            if if_char:
                if if_variant == False:
                    series_list.add(var+'__metaChar')
            else:
                series_list.add(var+'__meta')

    return hist_dict,list(series_list),list(meta_list),key


def set_slices_and_vars_time_slice(directory, file_pattern, prefix, suffix, start_yr, end_yr):

    '''
    Create the dictionary to look up slices based on history time slice files
    Also creates a list of vars to average over and a list of meta vars

    @param directory      The directory where the input data is located.

    @param file_pattern   The file pattern to glob the input directory on.

    @param prefix         The prefix to glob the input directory on.

    @param suffix         The suffix to glob the input directory on.

    @param start_yr       The first year that will be needed by the average(s).

    @param end_yr         The last year that will be needed by the average(s).

    @return hist_dict     A dictionary that lists all input file references for each
                          year/month needed by all averages.

    @return series_list   A list of all the variables within the input files that can
                          be averaged.

    @return meta_list     A list of the metadata that will not be averaged, but should be
                          included in the averaged/output file.

    @return key           A variable to use that has a specific file attached to that name.
                          Used more in when using time series files.
    '''
    # We want to extend the start and stop years by one year on both sides in case
    # extra months are needed  
    if start_yr > 1:
        yr1 = start_yr - 1
    else:
        yr1 = start_yr
    yr2 = end_yr + 1

    hist_dict = {}
    years = list(range(yr1,yr2+1))
    months = list(range(1,13)) 
    for yr in years:
        year_dict = {}
        for m in months:
            # Check to see if the file exists before adding info to dictionary
            startIndex = 0 # Slice index will always be 1 in history time slice files
            #file_prefix = directory+"/"+prefix
            yrS = str(yr)
            mS = str(m)
            stamp = yrS.zfill(4)+"-"+mS.zfill(2)
            filename,file_prefix = get_slice_fn(file_pattern, directory, prefix, suffix, stamp)
            filename = directory+"/"+filename
            if (os.path.isfile(filename)):
                # If exists, add it    
                year_dict[m-1] = {'directory':directory, 'fn':prefix, 'index':startIndex, 'date_stamp':stamp, 'pattern':file_pattern, 'suffix':suffix}
            else:
                if (yr > yr1 and yr < yr2):
                    print("ERROR: Could not find file: ",filename,"  Exiting.")
                    sys.exit(20)
        hist_dict[yr] = year_dict 

  
    # Grab variable list from a file.
    yrS = str(start_yr).zfill(4)
    #test_file = directory+"/"+prefix+"."+yrS+"-01.nc" 
    stamp = yrS+"-01"
    test_file,file_prefix = get_slice_fn(file_pattern, directory, prefix, suffix, stamp)
    test_file = directory+'/'+test_file
    f = Nio.open_file(test_file,"r")
    var_list = list(f.variables.keys())

    # Get the unlimited dimension and loop through all variables to check and see if it's a time series var
    dimNames = list(f.dimensions.keys())
    for dim in dimNames:
        if (f.unlimited(dim)):
            unlimited = dim

    series_list = []
    meta_list = []
    for var in var_list:
        if_series,if_variant,if_char = check_if_series_var(f,var,unlimited)
        if (if_series == False and if_variant == False):
            meta_list.append(var)
        elif (if_series == True and if_variant == True):
           if (var in unlimited):
               series_list.append(var+'__meta')
           else:
               series_list.append(var)
    f.close()
    key = series_list[0]

    return hist_dict,series_list,meta_list,key


def set_slices_and_vars_depend(directory, file_pattern, prefix, start_yr, end_yr, ave_type, ave, region):

    '''
    Create the dictionary to look up slices based on history time slice files
    Also creates a list of vars to average over and a list of meta vars

    @param directory      The directory where the input data is located.

    @param file_pattern   The file pattern to glob the input directory on.

    @param prefix         The prefix to glob the input directory on.

    @param start_yr       The first year that will be needed by the average(s).

    @param end_yr         The last year that will be needed by the average(s).

    @param ave_type       The average type key that indicated which type of average will be done.

    @param ave            The average type name string.
 
    @param region         The string idenitfing the region to calculate over (used in hor.mean* averages).

    @return hist_dict     A dictionary that lists all input file references for each
                          year/month needed by all averages.

    '''

    import average_types as ave_t
    import string
   
    yr1_str = string.zfill(start_yr,4)
    yr2_str = string.zfill(end_yr,4)

    hist_dict = {}
    if (ave_type['depend_type'] == 'month'):
        # If depend_type relies on monthly averaged files, define a hist dictionary with only 1 year
        # with non-null values for any average it will use for this new average.
        months_in_year = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
        m = 0 # month index
        year_dict = {}
        yr = int(start_yr)
        for mon in months_in_year:
            if (mon in ave_type['depend']):
                if ('djf' in ave):
                    if (mon == 'jan' or mon == 'feb'): 
                        glob_string = directory + "/" + prefix + '*' + yr1_str + '-' + yr2_str + '*next' + ave_t.average_types[mon]['fn']
                    else:
                        glob_string = directory + "/" + prefix + '*' + yr1_str + '-' + yr2_str + '*prev' + ave_t.average_types[mon]['fn']
                else:
                    glob_string = directory + "/" + prefix + '*' + yr1_str + '-' + yr2_str + '*.' + ave_t.average_types[mon]['fn']
                file_list = glob.glob(glob_string)
                year_dict[m] = {'directory':directory, 'fn': file_list[0], 'index':0, 'date_stamp':mon, 'pattern':None, 'suffix':'.nc'}
            else:
                year_dict[m] = {'directory':directory, 'fn': 'null', 'index':0, 'date_stamp':mon, 'pattern':None, 'suffix':'.nc'}            
            m = m + 1 #increase the month index
        hist_dict[yr] = year_dict
    else:
        # depend_type instead relies on yearly averaged files.  The dictionary will contain
        # keys for all years needed in the average, with each month set to the same yearly
        # averaged file.
        years = list(range(int(start_yr),int(end_yr)+1)) 
        for yr in years:
            year_dict = {}    
            yr_fmt = string.zfill(yr,4)
            if (ave == 'hor.meanConcat'):
                glob_string = directory + "/" + region + '_hor.meanyr.' +  yr_fmt + ".*"
            else:
                if '_sig' in ave or '_mean' in ave:
                    ave_split = ave.split('_')
                    seas = ave_split[0].upper()
                    glob_string = directory + "/" + prefix + "." + yr_fmt + "._" + seas + "*"
                else:
                    glob_string = directory + "/" + prefix + "." + yr_fmt + ".nc"
            file_list = glob.glob(glob_string)
            if len(file_list) > 0:
                for m in range(0,12):
                    year_dict[m] = {'directory':directory, 'fn': file_list[0], 'index':0, 'date_stamp':yr_fmt, 'pattern':None, 'suffix':'.nc'}
                hist_dict[yr] = year_dict
            else:
                print('NO DICTIONARY ENTRY FOR YR ',yr)
    return hist_dict

 
def check_if_series_var(f, vn, unlimited):

    '''
     Check to see if the variable if a time series variable or meta variable.
     This is only called by the slice routine.  By nature, a time series file
     should already have this sorted out based on it's file name.    

    @param f            The pointer to an input file.

    @param vn           The name of the variable to determine if it's a series variable.

    @param unlimited    The name of the unlimited dimension within the input NetCDF file.

    @return if_series   Boolean, if the variable has characteristics of a series variable.
 
    @return if_variant  Boolean, if the variable contains the time dimension.
    '''

    if_series = True
    if_char = False
    var = f.variables[vn]

    if (var.typecode() == 'S1'):
        if_series = False
        if_char = True
    elif (vn == unlimited):
        if_series = True
    # if number of dims is less than or equal to one, not a series var
    elif (var.rank<2):
        if_series = False
    # if it doesn't contain the unlimited dimension (time), not a series var
    elif (unlimited not in var.dimensions):
        if_series = False  
    elif (var.typecode() == 'S1'):
        if_series = False
        if_char = True

    if (unlimited in var.dimensions):
        if_variant = True
    else:
        if_variant = False

    if (vn == 'landmask' or vn == 'pftmask'):
        if_series = False
        if_variant = False
        if_char    = False

    return if_series,if_variant,if_char 

def fetch_slice(hist_dict, yr, month, var, file_dict, time=True, ext_select=None):

    '''
    Based on indexing found within the file_dictionary, return the correct data slice

    @param hist_dict      A dictionary of file references for all years/months that will be averaged.

    @param yr             The year to retrv.

    @param month          The month to retrv.

    @param var            The variable to retrv.

    @param file_dict      Dictionary containing file pointers to the open NetCDF files.

    @param time           A particular index to pull.   

    @param ext_select     String of dimension info for PyNIO's extended subsection method 

    @return var_val       The time slice that was requested in numPy array format.
    '''

    var_hndl = file_dict[yr][month]['fp'].variables[var]

    if (time):
        var_val = var_hndl[hist_dict[yr][month]['index']]
    elif (ext_select != None):
        var_val = var_hndl[ext_select]
    else:
        var_val = var_hndl[:]

    # Check to see if scale_factor exists.  If it does, apply the scale factor.
    if hasattr(var_hndl,'scale_factor'):
        scale_factor = getattr(var_hndl,'scale_factor')
        var_val = scale_factor * var_val
    
    return var_val

