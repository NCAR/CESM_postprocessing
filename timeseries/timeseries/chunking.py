#!/usr/bin/env python2

import glob, json, os
import netCDF4 as nc
import cf_units
import datetime

def get_input_dates(glob_str):

    '''
    Open up all of the files that match the search string and get
    the dates within the files.  Also get the number of slices within
    each file, what calendar it uses and the time unit.

    Input:
    glob_str(string) - the search path to get files

    Output:
    stream_dates(dictionary) - keys->date, values->the file where this slice is located
    file_slices(dictionary) - keys->filename, values->the number of slices found in the file 
    calendar(string) - the name of the calendar type (ie, noleap, ...)
    units(string) - the calendar unit (possibly in the form 'days since....')
    '''
    stream_files = glob.glob(glob_str)

    stream_dates = {}
    file_slices = {}
    att = {}
    print glob_str

    if len(stream_files) < 1:
        return stream_dates, file_slices, None, None

    for fn in sorted(stream_files):
        print 'opening ',fn
        # open file and get time dimension
        f = nc.Dataset(fn,"r")    
        all_t = f.variables['time']

        # add the file name are how many slices it contains
        file_slices[fn] = len(all_t)

        # add all dates and which file they are located in
        for t in all_t:
            stream_dates[t] = fn

        # get all attributes of time in order to get cal and units 
        for a in all_t.ncattrs():
            att[a] = all_t.__getattribute__(a)

    return stream_dates,file_slices,att['calendar'],att['units']

def get_cesm_date(fn,t=None):

    '''
    Open a netcdf file and return its datestamp

    Input:
    fn(string) - the filename to get date from
    t(string) - string indicating if the file is a beiginning or end (optional)

    Output:
    an array that includes year,month,day,hour is string format with correct number of digits
    '''

    f = nc.Dataset(fn,"r")
    all_t = f.variables['time']

    att={}
    for a in all_t.ncattrs():
        att[a] = all_t.__getattribute__(a)

    if ('bounds' in att.keys()):
        if t == 'b':
           d = f.variables[att['bounds']][0][0]
        elif t == 'e':
           l = len(f.variables[att['bounds']])
           d = (f.variables[att['bounds']][l-1][1])-1
        elif t == 'ee':
           l = len(f.variables[att['bounds']])
           d = (f.variables[att['bounds']][l-1][1])
    else:
        d = f.variables['time'][1]    

    d1 = cf_units.num2date(d,att['units'],att['calendar'])

    return [str(d1.year).zfill(4),str(d1.month).zfill(2),str(d1.day).zfill(2),str(d1.hour).zfill(2)]


def get_chunk_range(tper, size, start, cal, units):

    '''
    Figures out the end date of the chunk based on the start date

    Input:
    tper(string) - the time period to use when figuring out chunk size (year, month, day, hour)
    size(int) - the size of the chunk used in coordination with tper
    start(float) - the date stamp to start count from
    cal(string) - the calendar to use to figure out chunk size
    units(string) - the units to use to figure out chunk size

    Output:
    start(float) - the start date of the chunk
    end(float) - the end date of the chunk
    '''

    # Get the first date
    d1 = cf_units.num2date(start, units, cal)

    # Figure out how many days each chunk should be
    if 'day' in tper: #day
        end = float(start) + int(size)

    elif 'hour' in tper: #hour
        end = (float(size)/24.0) + float(start)

    elif 'month' in tper: #month
        m2 = (int(d1.month)+(int(size)%12))
        y2 = (int(d1.year)+(int(size)/12))
        if m2 > 12:
            y2 = y2 + 1
            m2 = m2 - 12
        d2 = datetime.datetime(y2, m2, d1.day, d1.hour, d1.minute)
        end = cf_units.date2num(d2, units, cal)

    elif 'year' in tper: #year
        d2 = datetime.datetime(int(size)+d1.year, d1.month, d1.day, d1.hour, d1.minute)
        end = cf_units.date2num(d2, units, cal)

    return start, end 

def get_chunks(tper, index, size, stream_dates, ts_log_dates, cal, units, s):

    '''
    Figure out what chunks there are to do for a particular CESM output stream

    Input:
    tper(string) - the time period to use when figuring out chunk size (year, month, day, hour)
    index(int) - an integer indicating which index in the tper and size list to start from.  
                 this option gives users to specify different chunk sizes.
    size(int) - the size of the chunk used in coordination with tper
    stream_dates(dictionary) - keys->date, values->the file where this slice is located
    ts_log_dates(list) - a list of all of the dates that have been converted already - used to 
                         avoid duplication
    cal(string) - the calendar to use to figure out chunk size
    units(string) - the units to use to figure out chunk size
    s(string) - flag to determine if we need to wait until we have all data before we create a chunk or
                if it's okay to do an incomplete chunk

    Output:
    files(dictionary) - keys->chunk, values->a list of all files needed for this chunk and the start and end dates 
    dates(list) - all of the dates that will be in this chunk
    index(int) - the last index to be used in the tper and size list
    '''

    # remove the times in ts_log_dates from stream_dates because
    # these have already been created
    du = cf_units.Unit(units)  
    to_do = []
    for d in sorted(stream_dates.keys()): 
        if d not in ts_log_dates:
            to_do.append(d)

    files = {}
    dates = []
    i = 0
    e = False
    chunk_n = 0

    tper_list = tper.split(",")
    size_list = size.split(",")
    if len(tper_list) != len(size_list):
        print 'Error: The length of requested time periods for chunks does not match the length of requested chunk sizes', tper_list, size_list

    if len(to_do)>1:
        while e is False:
            # get the new range
            start,end = get_chunk_range(tper_list[index], size_list[index], to_do[i], cal, units)
            if index != len(tper_list)-1:
                index = index + 1
            #walk through and map dates within this range to files
            cfiles = []
            cdates = []
            while to_do[i] < end and e is False:  
                fn = stream_dates[to_do[i]]
                if fn not in cfiles:
                    cfiles.append(fn) 
                cdates.append(to_do[i])
                print 'adding ',fn,to_do[i]
                i = i + 1
                # am I passed the dates I have?  If so, exit loop and don't add to list.
                # these will be converted when more data exists
                if i >= len(to_do)-1:
                    fn = stream_dates[to_do[i]]
                    if fn not in cfiles:
                        cfiles.append(fn)
                    cdates.append(to_do[i])
                    print 'adding ',fn,to_do[i]
                    if s==1:
                        print '#################################'
                        print 'Not appending: '
                        print cfiles
                        print 'dates:(',cdates,')'
                        print '#################################'
                    else: # user indicated that they would like to end with an incomplete chunk
                        files[chunk_n] = {}
                        files[chunk_n]['fn'] = sorted(cfiles)
                        files[chunk_n]['start'] = get_cesm_date(cfiles[0],t='b')
                        files[chunk_n]['end'] = get_cesm_date(cfiles[-1],t='e')
                        for cd in sorted(cdates):
                            dates.append(cd)
                    e = True
            # Have a complete set.  Append file and date info.
            if e is False:
                files[chunk_n] = {}
                s_cdates = sorted(cdates)
                files[chunk_n]['fn'] = sorted(cfiles)
                files[chunk_n]['start'] = get_cesm_date(cfiles[0],t='b')  
                files[chunk_n]['end'] = get_cesm_date(cfiles[-1],t='e') 
                for cd in sorted(cdates):
                    dates.append(cd)
            chunk_n = chunk_n+1

    return files, dates, index


def write_log(log_fn, log):

    '''
    Write (or append) a json file with the date stamps that have been coverted 
    and what tper and size list index to next start on.
    
    Input:
    log_fn(string) - the name of the log file to write to
    log(dictionary) - keys->file streams, values->the dates that have been 
                         converted and next indexes to use for size and tper lists 
    '''
    with open(log_fn, 'w') as f:
        json.dump(log, f)


def read_log(log_fn):
  
    '''
    Read in the json log file in order to know which files have already been converted

    Input:
    log_fn(string) - the name of the log file to write to

    Output:
    d(dictionary) - will be empty if it the file doesn't exist or contain a dictionary
                    with keys->file streams, values->the dates that have been 
                    converted and next indexes to use for size and tper lists
    '''
    if os.path.isfile(log_fn):
        with open(log_fn, 'r') as f:
            d = json.load(f)
        return d
    else:
        return {}

