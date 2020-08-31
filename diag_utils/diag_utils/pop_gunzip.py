#!/usr/bin/env python
""" pop_gunzip parallel util
"""
from __future__ import print_function

import sys

# check the system python version and require 2.7.x or greater
if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

# import additional modules
import os
import glob
import re
import string
import pprint
import argparse

if sys.version_info[0] == 2:
    from ConfigParser import SafeConfigParser as config_parser
else:
    from configparser import ConfigParser as config_parser

#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():
    """Process the command line arguments.

    """
    parser = argparse.ArgumentParser(
        description='ocn_diags_generator: CESM wrapper python program for Ocean Diagnostics packages.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging '
                        'output')

    parser.add_argument('--debug', action='store_true',
                        help='extra debugging output')

    #parser.add_argument('--config', nargs=1, required=True, help='path to config file')

    options = parser.parse_args()
    return options

#==========================
# main
#==========================

def main(options):
    """generate variable time-series files from history time slice CESM output files
    
    Read the CESM case environment to generate variable time series netcdf files using 
    the case output history time slice netcdf files and following the configuration rules
    defined in the $CASE/env_archive.xml file.
    """
    from mpi4py import MPI
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()

    os.chdir("/glade/scratch/aliceb/archive/b.e11.B1850C5CN.f09_g16.005/ocn/hist")
    yearList = [".0620-*.nc.gz", ".0621-*.nc.gz",".0622-*.nc.gz",".0623-*.nc.gz",".0624-*.nc.gz",".0625-*.nc.gz",".0626-*.nc.gz",".0627-*.nc.gz",".0628-*.nc.gz",".0629-*.nc.gz"]

    commandList = []
    if rank == 0:
        for year in yearList:
            command = "gunzip b.e11.B1850C5CN.f09_g16.005" + year
            commandList.append(command)
    else:
        commandList = []

    comm.Barrier()
    comm.Scatter(commandList, 1, root=0)

    for command in commandList:
        os.system(command)

    comm.Disconnect()

    return 0

#===================================

if __name__ == "__main__":
    options = commandline_options()
    try:
        status = main(options)
        sys.exit(status)
    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)
