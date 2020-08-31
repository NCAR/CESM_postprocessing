#!/usr/bin/env python
"""Create output files that conform to experiment specifications
from CESM time-series files.

This script provides an interface between the CESM CASE environment
and the Python package PyConform.

It resides in the $SRCROOT/postprocessing/cesm-env2
__________________________
Created on November, 2016

@author: CSEG <cseg@cgd.ucar.edu>
"""

#from __future__ import print_function
import sys

# check the system python version and require 2.7.x or greater
if sys.hexversion < 0x02070000:
    print(70 * '*')
    print('ERROR: {0} requires python >= 2.7.x. '.format(sys.argv[0]))
    print('It appears that you are running python {0}'.format(
        '.'.join(str(x) for x in sys.version_info[0:3])))
    print(70 * '*')
    sys.exit(1)

import argparse
import glob
import os
#import pprint
import re
import string
import sys
import traceback
import xml.etree.ElementTree as ET
import fnmatch
import subprocess
import netCDF4 as nc
from collections import OrderedDict
from imp import load_source
from warnings import simplefilter

from cesm_utils import cesmEnvLib

import json
from pyconform.datasets import InputDatasetDesc, OutputDatasetDesc
from pyconform.dataflow import DataFlow
from pyconform.flownodes import ValidationWarning
from pyconform.physarray import UnitsError

#import modules.commonfunctions
#import modules.pnglfunctions


# import the MPI related module
from asaptools import partition, simplecomm, vprinter, timekeeper

external_mods = ['commonfunctions.py', 'pnglfunctions.py', 'CLM_landunit_to_CMIP6_Lut.py',
                 'CLM_pft_to_CMIP6_vegtype.py', 'idl.py', 'dynvarmipdiags.py', 'dynvarmipfunctions.py']

#external_mods = ['commonfunctions.py', 'CLM_landunit_to_CMIP6_Lut.py',
#                 'CLM_pft_to_CMIP6_vegtype.py', 'idl.py', 'dynvarmipdiags.py', 'dynvarmipfunctions.py']


cesmModels = {"atmos":     "cam",
              "land":      "clm2",
              "aerosol":   "cam",
              "atmosChem": "cam",
              "seaIce":    "cice",
              "landIce":   "cism",
              "ocean":     "pop",
              "ocnBgchem": "pop"
}

cesm_tper = ["annual","year_1","month_1","weekly","daily","hour_6","hour_3","hour_1","min_30","month_1"]

cmip6_realms = {
        "aerosol":"atm",
        "atmos":"atm",
        "atmosChem":"atm",
        "land":"lnd,rof",
        "landIce":"glc,lnd",
        "ocean":"ocn",
        "ocnBgchem":"ocn",
        "seaIce":"ice"
}

cesm_realms = {
        "cam":"atm",
        "clm2":"lnd",
        "rtm":"rof",
        "cism":"glc",
        "pop":"ocn",
        "cice":"ice"
}

cesm_cmip6_realms = {
        "cam":"atmos",
        "clm2":"land",
        "mosart":"land",
        "cism":"landIce",
        "pop":"ocean",
        "cice":"seaIce"
}


r2c = {
        "aerosol":"atm",
        "atmos":"atm",
        "atmosChem":"atm",
        "land":"lnd",
        "landIce":"glc",
        "ocean":"ocn",
        "ocnBgchem":"ocn",
        "seaIce":"ice"
}

grids = {
       "atm":{"lat":["lat"],"lon":["lon"],"lev":["lev","ilev"],"time":["time"]},
       "lnd":{"lat":["lat"],"lon":["lon"],"lev":["levdcmp","levgrnd","levsoi","levurb","levlak","numrad","levsno","nlevcan","nvegwcs","natpft"],"time":["time"]},
       "rof":{"lat":["lat"],"lon":["lon"],"lev":[None],"time":["time"]},
       "glc":{"lat":["y0","y1"],"lon":["x0","x1"],"lev":["level","staglevel","stagwbndlevel"],"time":["time"]},
       "ocn":{"lat":["nlat"],"lon":["nlon"],"lev":["z_t","z_t_150m","z_w","z_w_top","z_w_bot","moc_z"],"time":["time"]},
       "ice":{"lat":["nj"],"lon":["ni"],"lev":["nc","nkice","nksnow","nkbio"],"time":["time"]}
}

doub_dim = {
        "atm":"nbnd",
        "lnd":"hist_interval",
        "rof":"hist_interval",
        "lnd,rof":"hist_interval",
        "glc":"hist_interval",
        "ocn":"d2",
        "ice":"d2"
}

no_chunking = ['yeartomonth']
no_time_chunking = ['burntFraction']

failures = 0

#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():
    """Process the command line arguments.
    """
    parser = argparse.ArgumentParser(
        description='cesm_conform_generator:  CESM wrapper python program to create experiment type specified files.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging output')

    parser.add_argument('--debug', nargs=1, required=False, type=int, default=0,
                        help='debugging verbosity level output: 0 = none, 1 = minimum, 2 = maximum. 0 is default')

    parser.add_argument('--caseroot', nargs=1, required=True,
                        help='fully quailfied path to case root directory')

#    parser.add_argument('--ind', nargs=1, required=False, default=False,
#                        help='have the input json specification files been divided up with only one output variable per file, True or False')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = 'cesm_conform_generator.py ERROR: invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options


#==============================================================================================
# readArchiveXML
#==============================================================================================
def readArchiveXML(caseroot, dout_s_root, casename, debug):
    """ reads the $CASEROOT/env_postprocess and env_conform files and creates a dictionary of json spec files to cesm files

    Arguments:
    caseroot (string) - case root path
    dout_s_root (string) - short term archive root path
    casename (string) - casename
    """
    specifiers = list()
    xml_tree = ET.ElementTree()

    # get path to env_pp.xml file
    env_postprocess = '{0}/config_postprocess.xml'.format(caseroot)

    # check if the env_postprocess.xml file exists
    if ( not os.path.isfile(env_postprocess) ):
        err_msg = "cesm_conform_generator.py ERROR: {0} does not exist.".format(env_postprocess)
        raise OSError(err_msg)
    else:
        # parse the xml
        xml_tree.parse(env_postprocess)
        look_for = []
        if xml_tree.find("STANDARDIZE_TIMESERIES").text.upper() in ["T","TRUE"]:
            for comp_archive_spec in xml_tree.findall("components/comp_archive_spec"):
                comp = comp_archive_spec.get("name")
                rootdir = comp_archive_spec.find("rootdir").text
                for file_spec in comp_archive_spec.findall("files/file_extension"):
                    if file_spec.find("tseries_create").text.upper() in ["T","TRUE"]:

                        file_extension = file_spec.get("suffix").replace('.[0-9]','')

                        tseries_output_subdir = file_spec.find("tseries_tper").text
                        tseries_output_dir = '/'.join( [dout_s_root,rootdir,'proc/tseries',tseries_output_subdir,'*'+file_extension+'*'])

                        look_for.append(tseries_output_dir)
                        files = glob.glob(tseries_output_dir)
                        chunks = []
                        for f in files:
                            fn = os.path.basename(f)
                            dates = fn.split('.')[-2]
                            if dates not in chunks:
                                 chunks.append(dates)
#### Add loop around chunks here - need a new stream name for each date range - also need to create fake data to test this against
                        for chunk in chunks:
                            tseries_tper = file_spec.find("tseries_tper").text

                            stream_name = comp+'_'+tseries_tper+'_'+file_extension+'_'+chunk
                            tseries_output_dir = tseries_output_dir + chunk + '*'


def find_nc_files(root_dir):

    nc_files = []
    #streams = []
    for root, dirs, filenames in os.walk(root_dir):
       for fn in fnmatch.filter(filenames, '*.nc'):
           #if 'hist' in root:
           #    if fn.split('.')[:-2] not in streams:
           #streams.append(fn.split('.')[:-2])
           if 'tseries' in root:
               nc_files.append(os.path.join(root, fn))
    print 'Found ',len(nc_files), " in ", root_dir
    return nc_files

def fill_list(nc_files, root_dir, extra_dir, comm, rank, size):

    grds = {
        'atm':'192x288',
        'lnd':'192x288',
        'glc':'192x288',
        'rof':'192x288',
        'ice':'384x320',
        'ocn':'384x320'
    }

    constants = ['bheatflx','volo']

    variablelist = {}
    gridfile = None
    nc_files.append(extra_dir+"/ocn_constants.nc")
    nc_files.append(extra_dir+"/glc_constants.nc")
    nc_files_l = comm.partition(nc_files,func=partition.EqualLength(),involved=True)
    for fn in nc_files_l:
        f = nc.Dataset(fn, "r")
        mt = fn.replace(root_dir,"").split("/")[-5]
        stri = fn
        model_type = mt
        if len(fn.split('.'))>3:
            fvn = v_dims = fn.split('.')[-3]
            # Added for decadals
            if 'sh' == fvn.split('_')[-1]:
                fvn = fvn.replace('_sh','')
            elif 'nh' == fvn.split('_')[-1]:
                fvn = fvn.replace('_nh','')
        else:
            for c in constants:
                if c in f.variables.keys():
                    fvn = c
        if "ocn_constants" in fn:
            model_type = "ocn"
            mt = "ocn"
        if "glc_constants" in fn:
            model_type = "glc"
            mt = "glc"
        if "lnd" in model_type or "rof" in model_type:
            model_type = 'lnd,rof'
        if "glc" in model_type:
            model_type = 'glc,lnd'
        if ("time" not in f.variables.keys() and "tseries" not in fn and "_constants" not in fn):
            variablelist["skip"] = {}
        else:
            lt = "none"
            ln = "none"
            lv = "none"
            lat_name = None
            lon_name = None
            lev_name = None
            time_name = None
            # Find which dim variables to use
            v_dims = f.variables[fvn].dimensions
            for i in grids[mt]['lat']:
              if i in v_dims:
                  if 'nlat' in i or 'nj' in i:
                      if hasattr(f.variables[fvn], 'coordinates'):
                          if 'LAT' in str(f.variables[fvn].coordinates.split()[1]):
                              lat_name = str(f.variables[fvn].coordinates.split()[1])
                          else:
                              lat_name = 'TLAT'
                      else:
                          lat_name = 'TLAT'
                  else:
                      lat_name = i
                  lt = len(f.dimensions[i])
            for i in grids[mt]['lon']:
              if i in v_dims:
                  if 'nlon' in i or 'ni' in i:
                      if hasattr(f.variables[fvn], 'coordinates'):
                          if 'LON' in str(f.variables[fvn].coordinates.split()[0]):
                              lon_name = str(f.variables[fvn].coordinates.split()[0])
                          else:
                              lon_name = 'TLONG'
                      else:
                          lon_name = 'TLONG'
                      if 'ULON' in lon_name:
                          ln = str(len(f.dimensions[i]))+"_UGRID"
                      else:
                          ln = str(len(f.dimensions[i]))+"_TGRID"
                  else:
                      lon_name = i
                      ln = len(f.dimensions[i])
            for i in grids[mt]['lev']:
              if i in v_dims:
                  lev_name = i
                  lv = len(f.dimensions[i])
#            for i in grids[mt]['time']:
#              if i in v_dims:
#                  time_name = i
#                  lv = len(f.dimensions[i])
            if 'none' == lt or 'none' == ln:
                gridfile = '{0}/{1}x{2}.nc'.format(extra_dir,mt,grds[mt])
            else:
                if 'atm' in mt:
                    gridfile = '{0}/{1}x{2}x{3}x{4}.nc'.format(extra_dir,mt,lt,ln,lv)
                else:
                    gridfile = '{0}/{1}x{2}x{3}.nc'.format(extra_dir,mt,lt,ln)
            if gridfile is not None:
                if not os.path.isfile(gridfile):
                    print 'not found: ',gridfile
                    gridfile = None

            for vn,ob in f.variables.items():


                lt = "none"
                ln = "none"
                lv = "none"
                lat_name = None
                lon_name = None
                lev_name = None
                time_name = None
                # Find which dim variables to use
                v_dims = f.variables[vn].dimensions
                for i in grids[mt]['lat']:
                  if i in v_dims:
                      if 'nlat' in i or 'nj' in i:
                          if hasattr(f.variables[fvn], 'coordinates'):
                              if 'LAT' in str(f.variables[fvn].coordinates.split()[1]):
                                  lat_name = str(f.variables[fvn].coordinates.split()[1])
                              else:
                                  lat_name = 'TLAT'
                          else:
                              lat_name = 'TLAT'
                      else:
                          lat_name = i
                      lt = len(f.dimensions[i])
                for i in grids[mt]['lon']:
                  if i in v_dims:
                      if 'nlon' in i or 'ni' in i:
                          if hasattr(f.variables[fvn], 'coordinates'):
                              if 'LON' in str(f.variables[fvn].coordinates.split()[0]):
                                  lon_name = str(f.variables[fvn].coordinates.split()[0])
                              else:
                                  lon_name = 'TLONG'
                          else:
                              lon_name = 'TLONG'
                          if 'ULON' in lon_name:
                              ln = str(len(f.dimensions[i]))+"_UGRID"
                          else:
                              ln = str(len(f.dimensions[i]))+"_TGRID"
                      else:
                          lon_name = i
                          ln = len(f.dimensions[i])
                for i in grids[mt]['lev']:
                  if i in v_dims:
                      lev_name = i
                      lv = len(f.dimensions[i])

                if model_type not in variablelist.keys():
                    variablelist[model_type] = {}
                if vn not in variablelist[model_type].keys():
                     variablelist[model_type][vn] = {}
                if hasattr(f,"time_period_freq"):
                    if 'day_365' in f.time_period_freq:
                        time_period_freq = 'year_1'
                    else:
                        time_period_freq = f.time_period_freq
                    if time_period_freq not in variablelist[model_type][vn].keys():
                        variablelist[model_type][vn][time_period_freq] = {}
                    if 'ocn_constants' in stri or 'glc_constants' in stri:
                        date = "0000"
                    else:
                        date = stri.split('.')[-2]
                    if date not in variablelist[model_type][vn][time_period_freq].keys():
                        variablelist[model_type][vn][time_period_freq][date] = {}
                    if 'files' not in variablelist[model_type][vn][time_period_freq][date].keys():
                        variablelist[model_type][vn][time_period_freq][date]['files']=[stri,gridfile]
                        variablelist[model_type][vn][time_period_freq][date]['lat']=lat_name
                        variablelist[model_type][vn][time_period_freq][date]['lon']=lon_name
                        variablelist[model_type][vn][time_period_freq][date]['lev']=lev_name
                        variablelist[model_type][vn][time_period_freq][date]['time']=time_name
                else:
                    if "unknown" not in variablelist[model_type][vn].keys():
                        variablelist[model_type][vn]["unknown"] = {}
                    if stri not in variablelist[model_type][vn]["unknown"]:
                        # Modified for decadals
                        #variablelist[model_type][vn]["unknown"]["unknown"] = {}
                        time_period_freq = fn.split("/")[-2]
                        if 'ocn_constants' in stri or 'glc_constants' in stri:
                            date = "0000"
                        else:
                            date = stri.split('.')[-2]
                        if model_type not in variablelist.keys():
                            variablelist[model_type] = {}
                        if vn not in variablelist[model_type].keys():
                            variablelist[model_type][vn] = {}
                        if time_period_freq not in variablelist[model_type][vn].keys():
                            variablelist[model_type][vn][time_period_freq] = {}
                        if date not in variablelist[model_type][vn][time_period_freq].keys():
                            variablelist[model_type][vn][time_period_freq][date] = {}
                        variablelist[model_type][vn][time_period_freq][date]['files']=[stri,gridfile]
                        variablelist[model_type][vn][time_period_freq][date]['lat']=lat_name
                        variablelist[model_type][vn][time_period_freq][date]['lon']=lon_name
                        variablelist[model_type][vn][time_period_freq][date]['lev']=lev_name
                        variablelist[model_type][vn][time_period_freq][date]['time']=time_name
        f.close()
    VL_TAG = 30
    variable_list = {}
    if size > 1:
        if rank==0:
            variable_list = variablelist
            for i in range(0,size-1):
                r,lvarList = comm.collect(data=None, tag=VL_TAG)
                for model_type,d1 in lvarList.items():
                    if model_type not in variable_list.keys():
                        variable_list[model_type] = {}
                    for vn,d2 in d1.items():
                        if vn not in variable_list[model_type].keys():
                            variable_list[model_type][vn] = {}
                        for tp,d3 in d2.items():
                            if tp not in variable_list[model_type][vn].keys():
                                variable_list[model_type][vn][tp] = {}
                            for date,l in d3.items():
                                if date not in variable_list[model_type][vn][tp].keys():
                                    variable_list[model_type][vn][tp][date] = {}
                                if 'files' in variable_list[model_type][vn][tp][date].keys():
                                    if len(lvarList[model_type][vn][tp][date]['files'])>0:
                                        if lvarList[model_type][vn][tp][date]['files'][0] is not None:
                                            variable_list[model_type][vn][tp][date]['files'].append(lvarList[model_type][vn][tp][date]['files'][0])
                                else:
                                    variable_list[model_type][vn][tp][date] = lvarList[model_type][vn][tp][date]

#                variable_list.update(lvarList)
            comm.partition(variable_list, func=partition.Duplicate(), involved=True)
        else:
            comm.collect(data=variablelist, tag=VL_TAG)
            variable_list = comm.partition(func=partition.Duplicate(), involved=True)
        comm.sync()
    return variable_list

def match_tableSpec_to_stream(ts_dir, variable_list, dout_s_root, case):

    spec_streams = {}
    var_defs = {}

    res_mapping = {
                  "atm":{
                        "0.9x1.25": "f09"
                        },
                  "lnd,rof":{
                        "0.9x1.25": "f09"
                        },
                  "glc,lnd":{
                        "0.9x1.25": "f09"
                        },
                  "ocn":{
                        "gx1v6": "g16",
                        "gx1v7": "g17"
                        },
                  "ice":{
                        "gx1v6": "g16",
                        "gx1v7": "g17"
                        }
    }

    js = glob.glob(ts_dir+"/*.json")
    for j in js:

        # Read in the json file and add the correct dimension definitions
        js_fo = json.load(open(j,'r'))
        js_f = js_fo.copy()

        var_defs[j] = {}
        missing = {}
        dims = []
        no_def = []
        rl = None
        freql = None
        dates = []

        # get the cesm var names from the defs in json file
        cmd = "vardeps -f -n "+j
        print '---------------------------------------'
        print cmd
        p = subprocess.Popen([cmd], stderr=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        end = False
        found_all = True
        missing_vars = []
        output = p.stdout.read().split('\n')
        for l in output:
            if '[' in l and ']' in l and ':' in l:
                split = l.split();
                var_defs[j][split[0]] = {}
                var_defs[j][split[0]]["freq"] = split[1].replace("[","").replace("]","").replace(":","").split(",")[0]
                if 'fx' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'month_1'
                elif 'mon' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'month_1'
                elif 'day' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'day_1'
                elif '6hr' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'hour_6'
                elif '3hr' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'hour_3'
                elif '1hr' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'hour_1'
                elif 'subhr' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'min_30'
                elif 'yr' in var_defs[j][split[0]]["freq"]:
                    if 'Eyr' in j and 'land' in j:
                        var_defs[j][split[0]]["freq"] = 'year_1'
                    else:
                        var_defs[j][split[0]]["freq"] = 'year_1'
                var_defs[j][split[0]]["realm"] = split[1].replace("[","").replace("]","").replace(":","").split(",")[1]
                var_defs[j][split[0]]["vars"] = l.split(":")[1].split()
                var_defs[j][split[0]]["var_check"] = {}
                if 'landUse' in var_defs[j][split[0]]["vars"]:
                    var_defs[j][split[0]]["vars"].remove('landUse')
                elif 'levsoi' in var_defs[j][split[0]]["vars"]:
                    var_defs[j][split[0]]["vars"].remove('levsoi')
                elif 'siline' in var_defs[j][split[0]]["vars"]:
                    var_defs[j][split[0]]["vars"].remove('siline')
                elif 'basin'  in var_defs[j][split[0]]["vars"]:
                    var_defs[j][split[0]]["vars"].remove('basin')
                elif 'iceband'  in var_defs[j][split[0]]["vars"]:
                    var_defs[j][split[0]]["vars"].remove('iceband')
                elif 'soilpools' in var_defs[j][split[0]]["vars"]:
                    var_defs[j][split[0]]["vars"].remove('soilpools')
                # check to see if we have all before we start
                for v in var_defs[j][split[0]]["vars"]:
                    var_defs[j][split[0]]["var_check"][v] = []
                    var_name = j.split("_")[-2]
                    if "input_glob" in js_fo[var_name].keys():
                        stream = js_fo[var_name]["input_glob"].split(".")
                        r = cesm_cmip6_realms[stream[0]]
                        if 'landIce' in r:
                            f = 'year_1'
                        else:
                            if 'land' in r and 'h3' in js_fo[var_name]["input_glob"]:
                                f = 'year_1'
                            elif 'pop' in stream:
                                f = 'month_1'
                            else:
                                f = var_defs[j][split[0]]["freq"]
                    elif 'Odec' in j:
                        f = 'month_1'
                        r = 'ocean'
                        stream = None
                    else:
                        stream = None
                        r = var_defs[j][split[0]]["realm"]
                        f = var_defs[j][split[0]]["freq"]
                    if cmip6_realms[r] not in variable_list.keys():
                        found_all = False
                        missing_vars.append(v)
                    else:
                        if v in variable_list[cmip6_realms[r]].keys():
                            l_found_all = False
                            for freq in variable_list[cmip6_realms[r]][v].keys():
                                if f in freq:
                                    l_found_all = True
                            if not l_found_all:
                                found_all = False
                                missing_vars.append(v)
                        elif ',' in cmip6_realms[r]:
                            l_found_all = False
                            if 'glc' in cmip6_realms[r]:
                                if 'lnd,rof' in variable_list.keys():
                                  if v in variable_list['lnd,rof'].keys():
                                    l_found_all = False
                                    for freq in variable_list['lnd,rof'][v].keys():
                                        if f in freq:
                                            l_found_all = True
                                    if not l_found_all:
                                        found_all = False
                                        missing_vars.append(v)
                                  elif v in variable_list['glc,lnd'].keys():
                                    l_found_all = False
                                    for freq in variable_list['glc,lnd'][v].keys():
                                        if f in freq:
                                            l_found_all = True
                                    if not l_found_all:
                                        found_all = False
                                        missing_vars.append(v)
                            else:
                                found_all = False
                                missing_vars.append(v)
                        elif 'plev' in v:
                            l_found_all = True
                        else:
                            found_all = False
                            missing_vars.append(v)
                #Look up
                for v in var_defs[j][split[0]]["vars"]:
                    print "TRYING TO FIND: ",v
                    var_defs[j][split[0]]["var_check"][v] = []
                    var_name = j.split("_")[-2]
                    if "input_glob" in js_fo[var_name].keys():
                        stream = js_fo[var_name]["input_glob"].split(".")
                        r = cesm_cmip6_realms[stream[0]]
                        if 'landIce' in r:
                            f = 'year_1'
                        else:
                            if 'land' in r and 'h3' in js_fo[var_name]["input_glob"]:
                                f = 'year_1'
                            elif 'pop' in stream:
                                f = 'month_1'
                            else:
                                f = var_defs[j][split[0]]["freq"]
                    elif 'Odec' in j:
                        f = 'month_1'
                    else:
                        stream = None
                        r = var_defs[j][split[0]]["realm"]
                        f = var_defs[j][split[0]]["freq"]
                    if "mon" in f:
                        f = "month_1"
                    if "day" in f and 'day_365' not in f:
                        f = "day_1"
                    found_r = None
                    if cmip6_realms[r] not in variable_list.keys():
                        print "Could not find ",cmip6_realms[r]," in ",variable_list.keys()
                    else:
                        if v in variable_list[cmip6_realms[r]].keys():
                            found_r = cmip6_realms[r]
                        elif ',' in cmip6_realms[r]:
                            if 'glc' in cmip6_realms[r]:
                              if 'lnd,rof' in variable_list.keys():
                                if v in variable_list['lnd,rof'].keys():
                                    found_r = 'lnd,rof'
                                elif v in variable_list['glc,lnd'].keys():
                                    found_r = 'glc,lnd'
                        elif 'plev' in v:
                            l_found_all = True
                        #else:
                            #found_all = False
                            #missing_vars.append(v)
                    if found_r != None and found_all:
                        for freq in variable_list[found_r][v].keys():
                            if f in freq:
                                var_name = j.split("_")[-2]

                                var_defs[j][split[0]]["var_check"][v] = variable_list[found_r][v][freq]
                                rl = r
                                freql = freq
                                for date in variable_list[found_r][v][freq].keys():
                                    if stream is None:
                                        fl1 = variable_list[found_r][v][freq][date]['files']
                                    else:
                                        if 'year' in freq and 'lnd' in cesm_realms[stream[0]]:
                                            freq_n = 'day_365'
                                        else:
                                            freq_n = freq
                                        filename = dout_s_root+"/"+cesm_realms[stream[0]]+"/proc/tseries/"+freq_n+"/"+case+"."+stream[0]+"."+stream[1]+"."+v+"."+date+".nc"
                                        if not os.path.exists(filename):
                                            if ('_constant' in variable_list[found_r][v][freq][date]['files'][0]):
                                                filename = variable_list[found_r][v][freq][date]['files'][0]
                                        if "lnd" in cesm_realms[stream[0]] or "rof" in cesm_realms[stream[0]]:
                                            gridname = variable_list['lnd,rof'][v][freq][date]['files'][1]
                                        elif "glc" in cesm_realms[stream[0]]:
                                            gridname = variable_list['glc,lnd'][v][freq][date]['files'][1]
                                        else:
                                            gridname = variable_list[cesm_realms[stream[0]]][v][freq][date]['files'][1]
                                        fl1 = [filename,gridname]
#                                        if 'atm' in cesm_realms[stream[0]]:
#                                            ps_fn = dout_s_root+"/"+cesm_realms[stream[0]]+"/proc/tseries/"+freq_n+"/"+case+"."+stream[0]+"."+stream[1]+".PS."+date+".nc"
#                                            if os.path.exists(ps_fn):
#                                                spec_streams[j+">>"+date].append(ps_fn)
                                    if os.path.exists(fl1[0]):
                                        if (j+">>"+date) not in spec_streams.keys():
                                            spec_streams[j+">>"+date] = []
                                        # Add input file name
                                        if fl1[0] not in spec_streams[j+">>"+date]:
                                            spec_streams[j+">>"+date].append(fl1[0])
                                        # Add the grid file name
                                        if fl1[1] not in spec_streams[j+">>"+date] and fl1[1] is not None:
                                            spec_streams[j+">>"+date].append(fl1[1])
                                        if 'atm' in fl1[0].split('/')[-5]:
                                            ps_fn = fl1[0].replace(v,'PS')
                                            if os.path.exists(ps_fn):
                                                spec_streams[j+">>"+date].append(ps_fn)
                                    # Add the correct dimension definitions
                                    for k,var in js_fo.items():
                                        if ('ocean' in j or 'ocn' in j) and 'seaIce' not in j:
                                            if k in j.split("_")[-2]:
                                                if 'lat' in js_f[k]['dimensions'] and 'basin' not in  js_f[k]['dimensions']:
                                                    js_f[k]['dimensions'][js_f[k]['dimensions'].index('lat')] = 'nlat'
                                                if 'lon' in js_f[k]['dimensions']:
                                                    js_f[k]['dimensions'][js_f[k]['dimensions'].index('lon')] = 'nlon'
                                        if 'seaIce' in j:
                                            go = True
                                            if stream is not None:
                                                if 'cam' in stream:
                                                    go = False
                                            if go:
                                                if 'ocean_seaIce' in j:
                                                    if k in j.split("_")[-2]:
                                                        if 'lat' in js_f[k]['dimensions'] and 'basin' not in  js_f[k]['dimensions']:
                                                            js_f[k]['dimensions'][js_f[k]['dimensions'].index('lat')] = 'nlat'
                                                        if 'lon' in js_f[k]['dimensions']:
                                                            js_f[k]['dimensions'][js_f[k]['dimensions'].index('lon')] = 'nlon'
                                                else:
                                                    if k in j.split("_")[-2]:
                                                        if 'lat' in js_f[k]['dimensions']:
                                                            js_f[k]['dimensions'][js_f[k]['dimensions'].index('lat')] = 'nj'
                                                        if 'lon' in js_f[k]['dimensions']:
                                                            js_f[k]['dimensions'][js_f[k]['dimensions'].index('lon')] = 'ni'

                                        if 'definition' in var.keys():
                                            if 'xxlatxx' in var['definition']:
                                              if variable_list[found_r][v][freq][date]['lat'] != None:
                                                 js_f[k]['definition'] = var['definition'].replace('xxlatxx',variable_list[found_r][v][freq][date]['lat'])
                                                 if 'TLAT' in variable_list[found_r][v][freq][date]['lat'] or 'ULAT' in variable_list[found_r][v][freq][date]['lat']:
                                                     if 'seaIce' in j:
                                                         if 'ocean_seaIce' in j:
                                                             js_f[k]['dimensions']=['nlat','nlon']
                                                         else:
                                                             js_f[k]['dimensions']=['nj','ni']
                                                     elif 'landIce' in j and 'Gre' in j:
                                                         js_f[k]['dimensions']=['xgre','ygre']
                                                     elif 'landIce' in j and 'Ant' in j:
                                                         js_f[k]['dimensions']=['xant','yant']
                                                     else:
                                                         js_f[k]['dimensions']=['nlat','nlon']
                                              else:
                                                js_f[k]['definition'] = 'lat'

                                            if 'xxlonxx' in var['definition']:
                                              if variable_list[found_r][v][freq][date]['lon'] != None:
                                                 js_f[k]['definition'] = var['definition'].replace('xxlonxx',variable_list[found_r][v][freq][date]['lon'])
                                                 if 'TLONG' in variable_list[found_r][v][freq][date]['lon'] or 'ULONG' in variable_list[found_r][v][freq][date]['lon']:
                                                     js_f[k]['dimensions']=['nlat','nlon']
                                                 elif 'TLON' in variable_list[found_r][v][freq][date]['lon'] or 'ULON' in variable_list[found_r][v][freq][date]['lon']:
                                                     js_f[k]['dimensions']=['nj','ni']
                                              else:
                                                js_f[k]['definition'] = 'lon'
                                            if 'xxxgrexx' in var['definition']:
                                                if variable_list[found_r][v][freq][date]['lon'] != None:
                                                    js_f[k]['definition'] = var['definition'].replace('xxxgrexx',variable_list[found_r][v][freq][date]['lon'])
                                            if 'xxygrexx' in var['definition']:
                                                if variable_list[found_r][v][freq][date]['lat'] != None:
                                                    js_f[k]['definition'] = var['definition'].replace('xxygrexx',variable_list[found_r][v][freq][date]['lat'])

                                            if 'xxlevxx' in var['definition'] and variable_list[found_r][v][freq][date]['lev'] != None:
                                                js_f[k]['definition'] = variable_list[found_r][v][freq][date]['lev']

                                            if 'xxlevbndxx' in var['definition'] and variable_list[found_r][v][freq][date]['lev'] != None:
                                                js_f[k]['definition'] = "bounds("+variable_list[found_r][v][freq][date]['lev']+ ", bdim=\""+doub_dim[found_r]+"\")"

                                            if 'xxtimexx' in var['definition'] and variable_list[found_r][v][freq][date]['time'] != None:
                                                js_f[k]['definition'] = variable_list[found_r][v][freq][date]['time']

                                            if 'xxtimebndsxx' in var['definition']:
                                                if 'Imon' in j and 'cism' in fl1[0]:
                                                    js_f[k]['definition'] = "bounds(yeartomonth_time(chunits(time * 365, units=\"days since 0001-01-01\", calendar=\"noleap\")), bdim=\"hist_interval\")"
                                                elif 'cism' in fl1[0]:
                                                    js_f[k]['definition'] = "bounds(chunits(time * 365, units=\"days since 0001-01-01\", calendar=\"noleap\"), bdim=\"hist_interval\")"
                                                else:
                                                    js_f[k]['definition'] = "bounds(time, bdim=\"hist_interval\")"
                                            if 'time' == var['definition'] and 'Iyr' in j and 'cism' in fl1[0]:
                                                js_f[k]['definition'] = 'chunits(time * 365, units=\"days since 0001-01-01\", calendar=\"noleap\")'
                                            if 'diff_axis1_ind0bczero_4d' in var['definition']:
                                                js_f['lev']['definition'] = "z_t"
                                                js_f['lev_bnds']['definition'] = "bounds(z_t, bdim=\"d2\")"
                                            if 'rsdoabsorb' in var['definition']:
                                                js_f['lev']['definition'] = "z_t"
                                                js_f['lev_bnds']['definition'] = "bounds(z_t, bdim=\"d2\")"

                                    with open(j,'w') as fp:
                                        json.dump(js_f, fp, sort_keys=True, indent=4)

                    if len(var_defs[j][split[0]]["var_check"][v]) < 1:
                        if v not in missing.keys():
                            missing[v] = "(",f,",",r,")"

            elif len(l.split(':')) > 1:
                if 'No dependencies' in l:
                    if len(js_fo[l.split(':')[0].strip()]["definition"])>0:
                        print "PROBLEM DEFINITION: ",l.split(':')[0].strip(),": ",js_fo[l.split(':')[0].strip()]["definition"]
                    else:
                        print "NO DEFINITION FOUND: ",l.split(':')[0].strip(),": ",js_fo[l.split(':')[0].strip()]["definition"]
                    found_all = False
                    no_def.append(l.split(':')[0].strip())
                else:
                    if l.split(':')[1] != '':
                        dims.append(l.split(':')[1].strip())
            #if end:
            #    print l
            if 'Complete Specification Requires the Following Input Variables:' in l:
                end = True

        if not found_all:
            print ('Missing these variables: ',missing_vars)
        else:
            print ('Found all needed files')

    print "Total Size: ",len(spec_streams.keys())
    return spec_streams


def divide_comm(scomm, l_spec, ind):

    '''
    Divide the communicator into subcommunicators, leaving rank one to hand out reshaper jobs to run.
    The part of the parallelization will be handled by this script, with the parallelization now over
    CESM output streams and chunks.  The reshaper will the compute the variables in parallel.

    Input:
    scomm (simplecomm) - communicator to be divided (currently MIP_COMM_WORLD)
    l_spec(int) - the number of reshaper specifiers(# of output stream and # of chunks)

    Output:
    inter_comm(simplecomm) - this rank's subcommunicator it belongs to
    num_of_groups(int) - the total number of subcommunicators
    '''
    size = scomm.get_size()
    rank = scomm.get_rank()
    if 'True' in ind:
        num_of_groups = size
    else:
        min_procs_per_spec = 16
        if size < min_procs_per_spec:
            min_procs_per_spec = size

        if l_spec == 1:
            num_of_groups = 1
        else:
            num_of_groups = size/min_procs_per_spec
        if l_spec < num_of_groups:
            num_of_groups = l_spec


    # the global master needs to be in its own subcommunicator
    # ideally it would not be in any, but the divide function
    # requires all ranks to participate in the call
    if rank == 0:
        temp_color = 0
    else:
        temp_color = (rank % num_of_groups)+1
    groups = []
    for g in range(0,num_of_groups+1):
        groups.append(g)
    group = groups[temp_color]

    inter_comm,multi_comm = scomm.divide(group)

    return inter_comm,num_of_groups


def run_PyConform(spec, file_glob, comm):

    failures = 0
    ## Used the main function in pyconform to prepare the call

    spec_fn = spec.split(">>")[0]
    spec_d = spec.split(">>")[1]

    # get infiles
    infiles = []
    for v in sorted(file_glob):
        infiles.append(v)

    # load spec json file
    dsdict = json.load(open(spec_fn,'r'), object_pairs_hook=OrderedDict)

    # look through each file to see if there are any functions in defs we can't chunk over
    chunking_ok = True
    for v in dsdict.keys():
        for f in no_chunking:
           if f in dsdict[v]['definition']:
               chunking_ok = False

    try:
        # Parse the output dataset
        outds = OutputDatasetDesc(dsdict=dsdict)

        # Parse the input dataset
        inpds = InputDatasetDesc(filenames=infiles)

        # Setup the PyConform data flow
        dataflow = DataFlow(inpds, outds)

        # Execute
        time = None
        for k in dsdict.keys():
            if 'time'==k or 'time1'==k or 'time2'==k or 'time3'==k:
                time = k
        if time is not None:
            if "Oclim" in spec_fn or "oclim" in spec_fn or "Oyr" in spec_fn or "oyr" in spec_fn:
                dataflow.execute(chunks={'nlat':10}, serial=True, debug=True, scomm=comm)
            elif not chunking_ok:
                dataflow.execute(chunks={'lat':10}, serial=True, debug=True, scomm=comm)
            else:
                dataflow.execute(chunks={time:48},serial=True, debug=True, scomm=comm)
        else:
            dataflow.execute(serial=True, debug=True, scomm=comm)

    except UnitsError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
        failures = failures+1
    except IndexError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
        failures = failures+1
    except ValueError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
        failures = failures+1
    except KeyError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
        failures = failures+1
    except IOError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
        failures = failures+1
    except NameError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
        failures = failures+1
    except RuntimeError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
        failures = failures+1
    except TypeError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
        failures = failures+1
    return failures
#======
# main
#======

def main(options, scomm, rank, size):
    """
    """
    # setup an overall timer
    timer = timekeeper.TimeKeeper()
    timer.start("Total Time")

    # initialize the CASEROOT environment dictionary
    cesmEnv = dict()

    # CASEROOT is given on the command line as required option --caseroot
    caseroot = options.caseroot[0]

    # set the debug level
    debug = options.debug[0]

    # is there only one mip definition in each file?
    ind = "True"

    # get the XML variables loaded into a hash
    env_file_list = ['env_postprocess.xml','env_conform.xml']
    cesmEnv = cesmEnvLib.readXML(caseroot, env_file_list);

    # We want to have warnings and not errors (at least for the first sets of cmip simulations)
    simplefilter("default", ValidationWarning)

    # Get the extra modules pyconform needs
    pp_path = cesmEnv["POSTPROCESS_PATH"]
    conform_module_path = pp_path+'/conformer/conformer/source/pyconform/modules/'
    for i, m in enumerate(external_mods):
        print("Loading: "+conform_module_path+"/"+m)
        load_source('user{}'.format(i), conform_module_path+"/"+m)

    # create the cesm stream to table mapping
#    if rank == 0:
    dout_s_root = cesmEnv['TIMESERIES_OUTPUT_ROOTDIR']
    case = cesmEnv['CASE']
    pc_inpur_dir = cesmEnv['CONFORM_JSON_DIRECTORY']+'/PyConform_input/'
    #readArchiveXML(caseroot, dout_s_root, case, debug)
    nc_files = find_nc_files(dout_s_root)
    variable_list = fill_list(nc_files, pc_inpur_dir, cesmEnv["CONFORM_EXTRA_FIELD_NETCDF_DIR"], scomm, rank, size)

    mappings = {}
    if rank == 0:
        mappings = match_tableSpec_to_stream(pc_inpur_dir, variable_list, dout_s_root, case)
        for k,v in sorted(mappings.items()):
            print k
            for f in sorted(v):
                print f
            print len(v),'\n\n'
    scomm.sync()

    # Pass the stream and mapping information to the other procs
    mappings = scomm.partition(mappings, func=partition.Duplicate(), involved=True)
    print("I CAN RUN ",len(mappings.keys())," json files")
    failures = 0

    if len(mappings.keys()) > 0:
        # setup subcommunicators to do streams and chunks in parallel
        # everyone participates except for root
        inter_comm, lsubcomms = divide_comm(scomm, len(mappings.keys()), ind)
        color = inter_comm.get_color()
        lsize = inter_comm.get_size()
        lrank = inter_comm.get_rank()
        print "MPI INFO: ",color," ",lrank,"/",lsize,"  ",rank,"/",size

        GWORK_TAG = 10 # global comm mpi tag
        LWORK_TAG = 20 # local comm mpi tag
        # global root - hands out mappings to work on.  When complete, it must tell each subcomm all work is done.
        if (rank == 0):
            #for i in range(0,len(mappings.keys())): # hand out all mappings
            for i in mappings.keys():
                scomm.ration(data=i, tag=GWORK_TAG)
            for i in range(1,lsubcomms): # complete, signal this to all subcomms
                scomm.ration(data=-99, tag=GWORK_TAG)

        # subcomm root - performs the same tasks as other subcomm ranks, but also gets the specifier to work on and sends
        # this information to all ranks within subcomm
        elif (lrank == 0):
            i = -999
            while i != -99:
                i = scomm.ration(tag=GWORK_TAG) # recv from global
                for x in range(1,lsize):
                    inter_comm.ration(i, LWORK_TAG) # send to local ranks
                if i != -99:
                    print "(",rank,"/",lrank,")","  start running ",i
                    failures += run_PyConform(i, mappings[i], inter_comm)
                    print "(",rank,"/",lrank,")","  finished running ",i
                    print "(",rank,"/",lrank,")","FAILURES: ",failures
                inter_comm.sync()

        # all subcomm ranks - recv the specifier to work on and call the reshaper
        else:
            i = -999
            while i != -99:
                i = inter_comm.ration(tag=LWORK_TAG) # recv from local root
                if i != -99:
                    print "(",rank,"/",lrank,")","  start running ",i
                    failures += run_PyConform(i, mappings[i], inter_comm)
                    print "(",rank,"/",lrank,")","  finished running ",i
                    print "(",rank,"/",lrank,")","FAILURES: ",failures
                inter_comm.sync()
    print "(",rank,"/",lrank,")","  FINISHED"
    scomm.sync()

    timer.stop("Total Time")
    if rank == 0:
        print('************************************************************')
        print('Total Time: {0} seconds'.format(timer.get_time("Total Time")))
        print('************************************************************')

#===================================

if __name__ == "__main__":
    # initialize simplecomm object
####    scomm = simplecomm.create_comm(serial=False)
    scomm = simplecomm.create_comm(serial=False)

    # get commandline options
    options = commandline_options()

    rank = scomm.get_rank()
    size = scomm.get_size()

    if rank == 0:
        print('cesm_conform_generator INFO Running on {0} cores'.format(size))

    main(options, scomm, rank, size)
    if rank == 0:
        print('************************************************************')
        print('Successfully completed converting all files')
        print('************************************************************')
