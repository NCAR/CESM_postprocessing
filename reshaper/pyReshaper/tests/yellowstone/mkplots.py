#!/usr/bin/env python
#==============================================================================
#
# This script is based on the script used to create the plots used in the
# poster and presentation at the 2014 CESM Workshop in Breckenridge, CO.  It
# is specialized to the data generated for the Workshop presentations, but
# it has been expanded and generalized in some respects.
#
# This script is meant to be run from the command-line with no options. It will
# search all of the tests found in the 'timings.json' data file.  It will pull
# out the timing and throughput data for each test in the data file, but it
# will only plot the timing and throughput data for tests and runs that
# satisfy desired conditions.  Namely, these conditions are that the plotted
# results are for test runs that:
#
#   1. Must include all metadata
#   2. Must use only a set number of cores
#   3. Method must be used in all other datasets
#   4. Pick the most recent test run, if there are multiple test runs
#
#==============================================================================

import optparse
import numpy

from utilities import plottools as pt

#==============================================================================
# Command-Line Interface Definition
#==============================================================================
_USAGE_ = 'Usage:  %prog [options] [DATASET1 [DATASET2 [...]]]'

_DESC_ = """Create throughput and duration plots of timing data"""

_PARSER_ = optparse.OptionParser(description=_DESC_)
_PARSER_.add_option('-d', '--data', action='append', type='string',
                    dest='data', default=[],
                    help=('Only plot jobs that match the given data '
                          '(in the format NAME,TYPE,VALUE, where TYPE '
                          'can be int, float, str, or bool)'))
_PARSER_.add_option('-f', '--func', type='string', default='latest',
                    help=('Which function to use when determining which '
                          'jobs to plot for each dataset and method.  Can '
                          'be average, latest, or first'))
_PARSER_.add_option('-l', '--log', action='store_true', default=False,
                    help='Plot graphs on a log-scale')
_PARSER_.add_option('-m', '--method', action='append', type='string',
                    dest='methods', default=[],
                    help=('Include a method to plot, by name.  If no methods '
                          'are listed, then include all methods found'))
_PARSER_.add_option('-t', '--timefile', type='string',
                    default='timings.json',
                    help=('Path to the timings.json file '
                          '[Default: "timings.json"]'))
_PARSER_.add_option('-x', '--exclusive', action='store_true',
                    dest='exclusive', default=False,
                    help=('Option indicating that datasets that do not '
                          'include all of the desired methods should not '
                          'be plotted [Default: False]'))

#==============================================================================
# Some common data for plotting
#==============================================================================
dataset_labels = {'POP-1.0': 'POP (1 deg)', 'POP-0.1': 'POP (0.1 deg)',
                  'CLM-1.0': 'CLM (1 deg)', 'CLM-0.25': 'CLM (1/4 deg)',
                  'CICE-1.0': 'CICE (1 deg)', 'CICE-0.1': 'CICE (0.1 deg)',
                  'CAMSE-1.0': 'CAM-SE (1 deg)',
                  'CAMSE-0.25': 'CAM-SE (1/4 deg)',
                  'CAMFV-1.0': 'CAM-FV (1 deg)'}
dataset_order = ['CAMFV-1.0', 'CAMSE-1.0', 'CICE-1.0', 'CLM-1.0', 'POP-1.0',
                 'CAMSE-0.25', 'CICE-0.1', 'CLM-0.25', 'POP-0.1']

method_labels = {'ncl': 'NCL 6.1.2',
                 'nco': 'NCO',
                 'ncr': 'ncReshaper',
                 'pynio': 'PyNIO (NetCDF3)',
                 'pynio4_0': 'PyNIO (NetCDF4)',
                 'pynio4_1': 'PyNIO (NetCDF4-CL1)',
                 'pyniompi': 'PyNIO+mpi4py (NetCDF3)',
                 'pyniompi4_0': 'PyNIO+mpi4py (NetCDF4)',
                 'pyniompi4_1': 'PyNIO+mpi4py (NetCDF4-CL1)',
                 'pagoda': 'Pagoda',
                 'cdo': 'CDO',
                 'pyreshaper-v0': 'PyReshaper v0.9 (NetCDF3)',
                 'pyreshaper4-v0': 'PyReshaper v0.9 (NetCDF4)', 
                 'pyreshaper4c-v0': 'PyReshaper v0.9 (NetCDF4-CL1)',
                 'pyreshaper': 'PyReshaper (NetCDF3)',
                 'pyreshaper4': 'PyReshaper (NetCDF4)',
                 'pyreshaper4c': 'PyReshaper (NetCDF4-CL1)'}
method_colors = {'ncl': 'magenta',
                 'nco': 'red',
                 'ncr': 'orange',
                 'pynio': 'purple',
                 'pynio4_0': 'green',
                 'pynio4_1': 'blue',
                 'pyniompi': 'purple',
                 'pyniompi4_0': 'green',
                 'pyniompi4_1': 'blue',
                 'pagoda': 'yellow',
                 'cdo': 'cyan',
                 'pyreshaper-v0': 'magenta',
                 'pyreshaper4-v0': 'red', 
                 'pyreshaper4c-v0': 'cyan',
                 'pyreshaper': 'purple',
                 'pyreshaper4': 'green',
                 'pyreshaper4c': 'blue'}
method_order = ['ncl', 'nco', 'pagoda', 'cdo',
                'pynio', 'pynio4_0', 'pynio4_1',
                'ncr',
                'pyniompi', 'pyniompi4_0', 'pyniompi4_1',
                'pyreshaper-v0', 'pyreshaper4-v0', 'pyreshaper4c-v0',
                'pyreshaper', 'pyreshaper4', 'pyreshaper4c']

data_types = {'int': int,
              'float': float,
              'str': str,
              'bool': bool}

#==============================================================================
# Command-line Operation
#==============================================================================
if __name__ == '__main__':
    opts, datasets = _PARSER_.parse_args()
    
    # Reduce function
    if opts.func.lower() == 'average':
        reduce_func = numpy.average
    elif opts.func.lower() == 'latest':
        reduce_func = lambda x: x[-1]
    elif opts.func.lower() == 'first':
        reduce_func = lambda x: x[0]
    else:
        raise ValueError('Reduce function {0} is not average, latest, or first'.format(opts.func))

    # Read the data file
    jsondata = pt.read_json_data(opts.timefile)
    if jsondata is None:
        raise ValueError('Could not find timings JSON data file.')
    
    # Parse the subselection data options
    subdata = {}
    for ds in opts.data:
        dname, dtype, dval = ds.split(',')
        subdata[dname] = data_types[dtype.lower()](dval)

    # Initialize the data to the entire file contents
    data = jsondata

    # If datasets are listed, extract only them
    if (len(datasets) > 0):
        datasets_to_plot = []
        for dataset in datasets:
            if dataset in dataset_order:
                datasets_to_plot.append(dataset)
        data = pt.subselect_datasets(data, datasets=datasets_to_plot)

    # If methods are listed, extract only them
    methods = opts.methods
    if (len(methods) > 0):
        methods_to_plot = []
        for method in methods:
            if method in method_order:
                methods_to_plot.append(method)
        data = pt.subselect_methods(data, methods=methods_to_plot,
                                    exclusive=opts.exclusive)
    
    # Subselect the jobs by time and data criteria
    data = pt.subselect_jobs_by_data(data, [subdata])

    # THROUGHPUT PLOTS
    tdata = pt.reduce_pdata(pt.get_throughput_pdata(data), func=reduce_func)
    pt.make_bar_plot(tdata, 'throughput.pdf',
                     title='Throughput', ylabel='Throughput [MB/sec]',
                     dataset_order=dataset_order,
                     method_order=method_order,
                     method_colors=method_colors,
                     dataset_labels=dataset_labels,
                     method_labels=method_labels,
                     logplot=opts.log)

    # DURATION PLOTS
    ddata = pt.reduce_pdata(pt.get_duration_pdata(data), func=reduce_func)
    pt.make_bar_plot(ddata, 'duration.pdf',
                     title='Duration', ylabel='Duration [min]',
                     dataset_order=dataset_order,
                     method_order=method_order,
                     method_colors=method_colors,
                     dataset_labels=dataset_labels,
                     method_labels=method_labels,
                     logplot=opts.log)

    # SPEEDUP PLOTS
    over_method = methods_to_plot[0]
    sdata = pt.get_speedup_pdata(tdata, over_method)
    pt.make_bar_plot(sdata, 'speedup.pdf',
                     title='Speedup over {0}'.format(method_labels[over_method]),
                     ylabel='Speedup',
                     dataset_order=dataset_order,
                     method_order=method_order,
                     method_colors=method_colors,
                     dataset_labels=dataset_labels,
                     method_labels=method_labels,
                     logplot=opts.log)
