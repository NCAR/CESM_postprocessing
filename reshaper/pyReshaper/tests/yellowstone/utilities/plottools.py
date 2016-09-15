#==============================================================================
#
# This module is designed to contain functions useful for generating plots
# from the PyReshaper timing JSON files.  The JSON data file is assumed to
# be structured in the nested order:
#
#   { DATASET: { ...,
#                'results': { ...,
#                             METHOD: { ...,
#                                       DATESTR: {JOBDATA}
#                                     }
#                           }
#              }
#   }
#
# where the following is true:
#
#   DATASET:  This key is the string name of the dataset.  Its value should
#             be a dictionary containing the 'results' key/dictionary.
#
#   METHOD:  This key is the string name of the method.  Its value should be
#            a dictionary of jobs.
#
#   DATESTR:  This key is the date-based string name of a particular job.
#
#   JOBDATA:  This is a dictionary containing all of the data for the given job.
#
# a particular piece of data, such as the time to perform the job, can be
# found in the dictionary with the call:
#
#   jsondata[DATASET]['results'][METHOD][JOBNUM][datakey]
#
#==============================================================================

import os
import json
import datetime
import numpy
from matplotlib import pyplot as plt
from matplotlib import rc
rc('font', family='serif')
plt.switch_backend('agg')

__MAXTIME__ = datetime.datetime(datetime.MAXYEAR, 12, 31, 23, 59, 59, 999999)
__MINTIME__ = datetime.datetime(datetime.MINYEAR, 1, 1, 0, 0, 0, 0)
__RESULTS__ = 'results'

# Plot Options (Defaults)
default_options = {'figsize': (4, 3),
                   'figadjustments': {'left': 0.175, 'right': 0.98, 'top': 0.915, 'bottom': 0.275},
                   'labelrotation': 35,
                   'titlefontsize': 12,
                   'labelfontsize': 10,
                   'tickfontsize': 9,
                   'legendfontsize': 8,
                   'figformat': 'pdf'}


#==============================================================================
# Convert a date-time string to a datetime object
#==============================================================================

def _dtstring(dtstr):
    return datetime.datetime.strptime(dtstr, '%y%m%d-%H%M%S')


#==============================================================================
# Read the data file, returns a dictionary
#==============================================================================

def read_json_data(file_name='../timings.json'):
    if (not os.path.isfile(file_name)):
        return None
    data_file = open(file_name)
    json_data = dict(json.load(data_file))
    data_file.close()
    return json_data


#==============================================================================
# Return the list of datasets in the dictionary
#==============================================================================
def list_datasets(input_dict):
    return input_dict.keys()


#==============================================================================
# Return the dictionary of methods found for each given dataset
#==============================================================================
def list_methods(input_dict, datasets=None):
    if not datasets:
        datasets = list_datasets(input_dict)
    elif type(datasets) is str:
        datasets = [datasets]
    elif type(datasets) is not list:
        raise TypeError('List of datasets must be of list type.')
    methods = {}
    for dataset in datasets:
        if dataset in input_dict:
            if __RESULTS__ in input_dict[dataset]:
                methods[dataset] = input_dict[dataset][__RESULTS__].keys()
    return methods


#==============================================================================
# Get the 'results' section (as a dictionary) for given dataset(s)
#==============================================================================
def get_results(input_dict, datasets=None):
    if not datasets:
        datasets = list_datasets(input_dict)
    elif type(datasets) is str:
        datasets = [datasets]
    elif type(datasets) is not list:
        raise TypeError('List of datasets must be of list type.')
    results = {}
    for dataset in datasets:
        if dataset in input_dict:
            if __RESULTS__ in input_dict[dataset]:
                results[dataset] = input_dict[dataset][__RESULTS__]
    return results


#==============================================================================
# Get everything but the 'results' section (as a dictionary) for given dataset(s)
#==============================================================================
def get_nonresults(input_dict, datasets=None):
    if not datasets:
        datasets = list_datasets(input_dict)
    elif type(datasets) is str:
        datasets = [datasets]
    elif type(datasets) is not list:
        raise TypeError('List of datasets must be of list type.')
    other = {}
    for dataset in datasets:
        if dataset in input_dict:
            other[dataset] = {}
            for key in input_dict[dataset]:
                if key != __RESULTS__:
                    other[dataset][key] = input_dict[dataset][key]
    return other


#==============================================================================
# Return the subset of the input dictionary that contains only the listed
# datasets.
#==============================================================================
def subselect_datasets(input_dict, datasets):
    if (type(datasets) is not list):
        raise TypeError('List of datasets must be of list type.')
    input_datasets = set(list_datasets(input_dict))
    subset_datasets = set(datasets)
    subset_datasets.intersection_update(input_datasets)
    subset_dict = {}
    for dataset in subset_datasets:
        subset_dict[dataset] = input_dict[dataset]
    return subset_dict


#==============================================================================
# Return the subset of the input dictionary that contains only the listed
# methods.  If a dataset does not use a listed method, the dataset is removed.
#
# When False (default), the exclusive option will include a dataset if it
# contains ANY of the listed methods.
#
# When True, the exclusive option will include a dataset only if it contains
# ALL of the listed methods.
#==============================================================================
def subselect_methods(input_dict, methods, exclusive=False):
    if (type(methods) is not list):
        raise TypeError('List of methods must be of list type.')
    methods_set = set(methods)
    methods_by_dataset = {}
    for dataset, methods_list in list_methods(input_dict).items():
        this_set = set(methods_list)
        methods_to_use = set()
        if exclusive:
            if methods_set.issubset(this_set):
                methods_to_use = methods_set
        else:
            if not methods_set.isdisjoint(this_set):
                methods_to_use = methods_set.intersection(this_set)
        methods_by_dataset[dataset] = list(methods_to_use)
    subset_dict = {}
    for dataset in methods_by_dataset:
        if methods_by_dataset[dataset]:
            subset_dict[dataset] = get_nonresults(
                input_dict, datasets=[dataset])[dataset]
            subset_dict[dataset][__RESULTS__] = {}
        for method in methods_by_dataset[dataset]:
            subset_dict[dataset][__RESULTS__][method] = \
                input_dict[dataset][__RESULTS__][method]
    return subset_dict


#==============================================================================
# Return the subset of the input dictionary with jobs that satisfy various
# date-time standards:
#
#    before: A datetime object.  If not specified, it is assumed to be equal
#            to __MAXTIME__.  If specified, then only jobs with date-time strings
#            corresponding to date-times BEFORE this date-time are kept.
#
#    after:  A datetime object.  If not specified, it is assumed to be equal
#            to __MINTIME__.  If specified, then only jobs with date-time strings
#            corresponding to date-times AFTER or EQUAL to this date-time are kept.
#
#    exclusive:  Indicates whether to assume BOTH (True) before and after
#                conditions must be met for the job to be kept or whether
#                EITHER (False) before or after conditions must be met for the
#                job to be kept.
#==============================================================================
def subselect_jobs_by_time(input_dict, before=__MAXTIME__, after=__MINTIME__, exclusive=True):
    subset_dict = {}
    for dataset in input_dict:
        if __RESULTS__ in input_dict[dataset]:
            results = input_dict[dataset][__RESULTS__]
            for method in results:
                for job_id in results[method]:
                    job_dt = _dtstring(job_id)
                    before_val = (job_dt < before)
                    after_val = (job_dt >= after)
                    good_job = False
                    if exclusive:
                        good_job = before_val and after_val
                    else:
                        good_job = before_val or after_val
                    if good_job:
                        if dataset not in subset_dict:
                            subset_dict[dataset] = get_nonresults(
                                input_dict, datasets=[dataset])[dataset]
                        if __RESULTS__ not in subset_dict[dataset]:
                            subset_dict[dataset][__RESULTS__] = {}
                        if method not in subset_dict[dataset][__RESULTS__]:
                            subset_dict[dataset][__RESULTS__][method] = {}
                        subset_dict[dataset][__RESULTS__][method][job_id] = \
                            input_dict[dataset][__RESULTS__][method][job_id]
    return subset_dict


#==============================================================================
# Return the subset of the input dictionary with jobs that satisfy various
# data key/value standards:
#
#    criteria:  A list of dictionaries containing keys that must be present
#               in the job data for the job to be considered valid (and kept).
#
#               For each dictionary in the list, the keys in the dictionary
#               are checked.  If the key does not exists in the job data, a
#               non-valid result is returned for the given dictionary in the
#               list.  If the key exists in the job data, then the corresponding
#               values are compared.  If the dictionary in the list's value is
#               None, then any job-data value is considered valid.  If the
#               dictionary in the list's value is another list, then any
#               job-data value in this list is considered valid.  If the
#               dictionary in the list's value is anything else, then validity
#               is only returned if the job-data value is the same.  If a
#               valid result is returned for ALL keys in the dictionary, then
#               the dictionary's criteria is considered valid.
#
#               If ANY of the dictionaries' criteria return a valid result,
#               then the job is considered valid.
#==============================================================================
def subselect_jobs_by_data(input_dict, criteria_list):
    if type(criteria_list) is not list:
        raise TypeError('Data criteria list must be of type list.')
    for criteria in criteria_list:
        if type(criteria) is not dict:
            raise TypeError('Data criteria items must be of type dict.')
    if len(criteria_list) == 0:
        raise ValueError('Data criteria list cannot be empty.')
    subset_dict = {}
    for dataset in input_dict:
        if __RESULTS__ in input_dict[dataset]:
            results = input_dict[dataset][__RESULTS__]
            for method in results:
                for job_id in results[method]:
                    good_jobs = [True] * len(criteria_list)
                    job_data = results[method][job_id]
                    for ic in range(len(criteria_list)):
                        for ckey, cval in criteria_list[ic].items():
                            if ckey in job_data:
                                if cval is not None:
                                    if type(cval) is list:
                                        if job_data[ckey] not in cval:
                                            good_jobs[ic] = False
                                    elif job_data[ckey] != cval:
                                        good_jobs[ic] = False
                            else:
                                good_jobs[ic] = False
                    good_job = reduce(lambda x, y: x or y, good_jobs)
                    if good_job:
                        if dataset not in subset_dict:
                            subset_dict[dataset] = get_nonresults(
                                input_dict, datasets=[dataset])[dataset]
                        if __RESULTS__ not in subset_dict[dataset]:
                            subset_dict[dataset][__RESULTS__] = {}
                        if method not in subset_dict[dataset][__RESULTS__]:
                            subset_dict[dataset][__RESULTS__][method] = {}
                        subset_dict[dataset][__RESULTS__][method][job_id] = \
                            input_dict[dataset][__RESULTS__][method][job_id]
    return subset_dict


#==============================================================================
# Create a union of 2 nested dictionaries
#==============================================================================
def union(dict1, dict2):
    if type(dict1) is dict and type(dict2) is dict:
        udict = dict1.copy()
        for key in dict2:
            if key in dict1:
                udict[key] = union(dict1[key], dict2[key])
            else:
                udict[key] = dict2[key]
        return udict
    else:
        return dict1


#==============================================================================
# Create the intersection of 2 nested dictionaries
#==============================================================================
def intersect(dict1, dict2):
    if type(dict1) is dict and type(dict2) is dict:
        udict = {}
        for key in dict2:
            if key in dict1:
                kintersection = intersect(dict1[key], dict2[key])
                if kintersection is not None:
                    udict[key] = kintersection
        return udict
    else:
        if dict1 == dict2:
            return dict1
        else:
            return None


#==============================================================================
# Gather duration data from a data dictionary and return a plot dictionary
#==============================================================================
def get_duration_pdata(data_dict):
    plot_dict = {}
    for dataset in data_dict:
        if __RESULTS__ in data_dict[dataset]:
            plot_dict[dataset] = {}
            for method in data_dict[dataset][__RESULTS__]:
                plot_dict[dataset][method] = []
                for job_data in data_dict[dataset][__RESULTS__][method].values():
                    real_time = float(job_data['real']) / 60.0
                    plot_dict[dataset][method].append(real_time)
    return plot_dict


#==============================================================================
# Gather throughput data from a data dictionary and return a plot dictionary
#==============================================================================
def get_throughput_pdata(data_dict):
    plot_dict = {}
    for dataset in data_dict:
        isize = float(data_dict[dataset]['isize'])
        if __RESULTS__ in data_dict[dataset]:
            plot_dict[dataset] = {}
            for method in data_dict[dataset][__RESULTS__]:
                plot_dict[dataset][method] = []
                for job_data in data_dict[dataset][__RESULTS__][method].values():
                    throughput = isize / float(job_data['real'])
                    plot_dict[dataset][method].append(throughput)
    return plot_dict


#==============================================================================
# Compute the reduction of data for multiple jobs in a plot dicitonary
#==============================================================================
def reduce_pdata(plot_dict, func=numpy.average):
    for dataset in plot_dict:
        for method in plot_dict[dataset]:
            reduced_data = func(plot_dict[dataset][method])
            plot_dict[dataset][method] = reduced_data
    return plot_dict


#==============================================================================
# Make a bar plot from a REDUCED plot dictionary
#==============================================================================
def make_bar_plot(pdata, filename,
                  dataset_order, method_order, method_colors,
                  dataset_labels, method_labels,
                  title=None, xlabel=None, ylabel=None,
                  figsize=(4, 3),
                  figadjustments={
                      'left': 0.175, 'right': 0.98, 'top': 0.915, 'bottom': 0.275},
                  labelrotation=35,
                  titlefontsize=12,
                  labelfontsize=10,
                  tickfontsize=9,
                  legendfontsize=8,
                  figformat='pdf'):

    # Reduce the data first (if already reduced, does nothing)
    pdata = reduce_pdata(pdata)

    # Get the names of the datasets and the methods
    dataset_names = set(pdata.keys())
    method_names = set()
    for dataset in dataset_names:
        new_set = set(pdata[dataset].keys())
        method_names.update(new_set)

    # Check that the order and colors lists contain enough names
    if not set(dataset_order).issubset(dataset_names):
        raise ValueError(
            'Dataset order must contain all dataset names found in the plot dictionary')
    if not set(dataset_labels).issubset(dataset_names):
        raise ValueError(
            'Dataset labels must contain all dataset names found in the plot dictionary')
    if not set(method_order).issubset(method_names):
        raise ValueError(
            'Method order must contain all method names found in the plot dictionary')
    if not set(method_colors).issubset(method_names):
        raise ValueError(
            'Method colors must contain all method names found in the plot dictionary')
    if not set(method_labels).issubset(method_names):
        raise ValueError(
            'Method labels must contain all method names found in the plot dictionary')

    # Number of datasets and methods (for convenience)
    n_methods = len(method_names)
    n_datasets = len(dataset_names)

    # Plot-sizing data
    base_width = 0.8
    width = base_width / n_methods
    offset = -base_width / 2
    xbase = numpy.arange(n_datasets) + 1

    # Create the figure
    plt.figure(figsize=figsize)
    plt.subplots_adjust(**figadjustments)

    # Plot every method and dataset in the plot dictionary
    for method in method_order:
        if method in method_names:
            yvalues = numpy.zeros(n_datasets)
            xvalues = xbase + offset

            i_dataset = 0
            for dataset in dataset_order:
                if dataset in dataset_names:
                    if method in pdata[dataset]:
                        yvalues[i_dataset] = pdata[dataset][method]
                    i_dataset += 1

            clr = method_colors[str(method)]
            lab = method_labels[str(method)]
            plt.bar(xvalues, yvalues, width, color=clr, label=lab)
            offset += width

    # Label the x-axis values
    xlabels = []
    for dataset in dataset_order:
        if dataset in dataset_names:
            xlabels.append(dataset_labels[str(dataset)])

    if title is not None:
        plt.title(title, fontsize=titlefontsize, ha='center', va='bottom')
    if ylabel is not None:
        plt.ylabel(ylabel, fontsize=labelfontsize, ha='center', va='bottom')
    plt.yticks(fontsize=tickfontsize)
    if xlabel is not None:
        plt.xlabel(xlabel, fontsize=labelfontsize, ha='center', va='top')
    plt.xticks(xbase, xlabels, rotation=labelrotation,
               ha='right', fontsize=tickfontsize)
    plt.legend(loc=2, fontsize=legendfontsize)
    plt.savefig(filename, format=figformat)
