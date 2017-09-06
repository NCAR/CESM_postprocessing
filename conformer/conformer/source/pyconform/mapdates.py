"""
Date Evaluator

This evaluates the time slices in the file(s) to define the time period
between steps and verifies consistancy and sequential steps between files.

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

import climIO
from dateutil import parser
import os
import cf_units


#=============================================
#  Get time information from the time slices
#=============================================
def __get_time_info__(f, io):
    """
    Evaluates the time slices in the input files to verify
    that there are the correct number of slices in the file 
    and that the slices are contiguous.  It also pulls off
    other information, such as start/en times, time period/spacing,
    slice count, and the average of the slices (for ordering purposes). 

    Parameters:
        f (climIO file): A pointer to an open netCDF file.
        io (climIO): An object that contains a setof io commands to use.

    Returns:
        date_info (dict): Contains file information, such as time period(t_per), time step(t_step), 
            first/last step(t0 and tn), slice counts(cnt). 
        average (int): The average of all time slices.
    """
    date_info = {}
    _tc, _dim, att = io.get_var_info(f, 'time')
    stand_cal = cf_units.Unit('days since 1-1-1 0:0:0', calendar=att['calendar'])
    cal_unit = cf_units.Unit(att['units'], calendar=att['calendar'])
    if ('bounds' in att.keys()):
        # print 'Using bounds'
        tb = f.variables[att['bounds']]
        l = len(tb)
        d0 = tb[0, 0]
        d1 = tb[1, 0]
        d2 = tb[2, 0]
        dn = tb[l - 1, 1] - 1
        time = tb[:, 0]
    else:
        # print 'Using time'
        tb = f.variables['time']
        l = len(tb)
        d0 = tb[0]
        d1 = tb[1]
        d2 = tb[2]
        dn = tb[l - 1]
        time = tb[:]
    date_info['time'] = time

    # Get second and third time bounds to figure out the time period
    t1 = (parser.parse(
        str(cf_units.num2date(d1, att['units'], calendar=att['calendar']))).timetuple())
    t2 = (parser.parse(
        str(cf_units.num2date(d2, att['units'], calendar=att['calendar']))).timetuple())
    # Get time difference between the steps
    t_step = d2 - d1
    h = t2[3] - t1[3]
    if (t1[3] != t2[3]):
        t_per = str(h) + 'hour'
    elif (t1[2] != t2[2]):
        t_per = 'day'
    elif (t1[1] != t2[1]):
        t_per = 'mon'
    elif (t1[0] != t2[0]):
        t_per = 'year'
    else:
        t_per = 'UNKNOWN'
    date_info['t_per'] = t_per
    date_info['t_step'] = t_step
    # Get first and last dates
    t0 = (parser.parse(str(cf_units.num2date(d0, att['units'], 
                                             calendar=att['calendar']))).timetuple())
    tn = (parser.parse(str(cf_units.num2date(dn, att['units'], 
                                             calendar=att['calendar']))).timetuple())
    date_info['t0'] = cal_unit.convert(d0, stand_cal)
    date_info['tn'] = cal_unit.convert(dn, stand_cal)
    date_info['cnt'] = l
    average = (date_info['t0'] + date_info['tn']) / 2
    date_info['units'] = att['units']
    date_info['calendar'] = att['calendar']

    # Check to see if the number of slices matches how many should be in the
    # date range
    if t_per == 'year':
        _ok = (tn[0] - t0[0] == l)
    elif t_per == 'mon':
        _ok = (((tn[0] - t0[0]) * 12) + (tn[1] - t0[1] + 1) == l)
    elif t_per == 'day':
        _ok = ((dn - d0 + 1) == l)
    elif 'hour' in t_per:
        cnt_per_day = 24.0 / h
        _ok = (((dn - d0) * cnt_per_day + 1) == l)

    return average, date_info


#=============================================
# Verify that there are no gaps in time from
# one file to the next
#=============================================
def __check_date_alignment__(keys, date_info):
    """
    Evaluates the dates between files to verify that
    no gaps are found in the time dimension.

    Parameters:
        keys (list): A list of time slice references that are in correct time order.
        date_info (dict): Contains file information, such as time period(t_per), time step(t_step), 
            first/last step(t0 and tn), slice counts(cnt).
    """
    prev_last = date_info[keys[0]]['tn']
    t_step = date_info[keys[0]]['t_step']

    if date_info[keys[0]]['t_per'] == 'mon':
        date = (parser.parse(str(cf_units.num2date(date_info[keys[0]]['tn'],
                                                   date_info[keys[0]]['units'], calendar=date_info[keys[0]]['calendar']))).timetuple())
        if date[1] == 12:
            next_val = 1
        else:
            next_val = date[1] + 1

    else:
        next_val = prev_last + t_step

    for i in range(1, len(keys)):
        if date_info[keys[i]]['t_per'] == 'mon':
            new_date = (parser.parse(str(cf_units.num2date(date_info[keys[i]]['t0'],
                                                           date_info[keys[i]]['units'], calendar=date_info[keys[i]]['calendar']))).timetuple())
            if (next_val == new_date[1]):
                date = (parser.parse(str(cf_units.num2date(date_info[keys[i]]['tn'],
                                                           date_info[keys[i]]['units'], calendar=date_info[keys[i]]['calendar']))).timetuple())
                if date[1] == 12:
                    next_val = 1
                else:
                    next_val = date[1] + 1
            else:
                print "Disconnect? Expected: ", next_val, " Got: ", new_date[1]
                return 1
        else:
            if (next_val == date_info[keys[i]]['t0']):
                # print "Looks
                # okay",date_info[keys[i]]['t0'],'-',date_info[keys[i]]['tn']
                prev_last = date_info[keys[i]]['tn']
                next_val = prev_last + t_step
            else:
                print "Disconnect? Expected: ", next_val, " Got: ", date_info[keys[i]]['t0']
                return 1

    return 0


#=============================================
# Verify that there are no gaps in time from
# one time step to the next in the same file.
#=============================================
def __check_date_alignment_in_file__(date):
    """
    Evaluates the dates between time steps to verify that
    no gaps are found in the time dimension.

    Parameters:
        date (dict): Contains file information, such as time period(t_per), time step(t_step), 
                          first/last step(t0 and tn), slice counts(cnt).

    """
    t_step = date['t_step']
    t_per = date['t_per']
    t = date['time']
    prev_time = t[0]

    # If the time period in monthly, then the time difference between slices is not uniform and
    # requires looking into the month length array to get correct day #'s
    # between slices.
    if t_per == 'mon':
        if t_per == 'mon':
            date1 = (parser.parse(str(cf_units.num2date(t[0],
                                                        date['units'], calendar=date['calendar']))).timetuple())
            if date1[1] == 12:
                next_val = 1
            else:
                next_val = date1[1] + 1
        for i in range(1, len(t)):
            new_date = (parser.parse(str(cf_units.num2date(t[i],
                                                           date['units'], calendar=date['calendar']))).timetuple())
            if (next_val == new_date[1]):
                date1 = (parser.parse(str(cf_units.num2date(t[i],
                                                            date['units'], calendar=date['calendar']))).timetuple())
                if date1[1] == 12:
                    next_val = 1
                else:
                    next_val = date1[1] + 1
            else:
                print "Disconnect? Expected: ", next_val, " Got: ", new_date[1], ' around time step: ', i
                return 1
    # All other time periods should have the same number of days between
    # slices.
    else:
        for i in range(1, len(t)):
            if (prev_time + t_step == t[i]):
                # Time step looks okay
                prev_time = t[i]
            else:
                print "Disconnect? Expected: ", str(prev_time + t_step), " Got: ", t[i], ' around time step: ', i
                return 1
    return 0


#=============================================
# Examine the file list and put them in sequential
# order.
#=============================================
def get_files_in_order(files, alignment=True):
    """
    Examine the file list and put the files in 
    sequential order.

    Parameters:
        files (list): A list of file names to put into sequential order.

    Returns:
        file_list (list): A list that contains the file names in sequential
            order.
        counts (list): A list containing the time slice counts for each of the 
            files.  The order should match the order in which the
            file_list lists the files.
    """
    ncdf = climIO.init_climIO(override='netCDF4')

    date_info = {}
    counts = []
    file_list = []

    for fl in files:
        fn = os.path.basename(fl)
        f = ncdf.open_file(fl)
        ave, date = __get_time_info__(f, ncdf)
        date['fn'] = fn
        date_info[ave] = date
        if alignment:
            error = __check_date_alignment_in_file__(date)
            if error != 0:
                return file_list, counts, error

    for d in sorted(date_info.keys()):
        file_list.append(date_info[d]['fn'])
        counts.append(date_info[d]['cnt'])

    # If there are more than 1 files, make sure the dates are aligned correctly
    if len(fl) > 1:
        error = __check_date_alignment__(sorted(date_info.keys()), date_info)
        if error != 0:
            return file_list, counts, error

    return file_list, counts, error
