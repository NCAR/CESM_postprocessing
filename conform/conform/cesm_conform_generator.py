#!/usr/bin/env python2
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

from json import load as json_load
from pyconform.datasets import InputDatasetDesc, OutputDatasetDesc
from pyconform.dataflow import DataFlow
from pyconform.flownodes import ValidationWarning
from pyconform.physarray import UnitsError

#import modules.commonfunctions
#import modules.pnglfunctions


# import the MPI related module
from asaptools import partition, simplecomm, vprinter

external_mods = ['commonfunctions.py', 'pnglfunctions.py']


cesmModels = {"atmos":     "cam", 
              "land":      "clm2",
              "aerosol":   "cam",
              "atmosChem": "cam",
              "seaIce":    "cice",
              "landIce":   "cism",
              "ocean":     "pop",
              "ocnBgchem": "pop"
}

cesm_tper = ["annual","yearly","month_1","weekly","daily","hour_6","hour_3","hour_1","min_30","month_1"]

cmip6_realms = {
        "aerosol":"atm",
        "atmos":"atm",
        "atmosChem":"atm",
        "land":"lnd,rof",
        "landIce":"glc,lnd",
        "ocean":"ocn",
        "ocnBgChem":"ocn",
        "seaIce":"ice"
}

r2c = {
        "aerosol":"atm",
        "atmos":"atm",
        "atmosChem":"atm",
        "land":"lnd",
        "landIce":"glc",
        "ocean":"ocn",
        "ocnBgChem":"ocn",
        "seaIce":"ice"
}
grids = {
       "atm":{"lat":"lat","lon":"lon","lev":"lev"},
       "lnd":{"lat":"lat","lon":"lon","lev":"levgrnd"},
       "rof":{"lat":"lat","lon":"lon","lev":None},
       "glc":{"lat":"x0","lon":"y0","lev":"staglevel"},
       "ocn":{"lat":"nlat","lon":"nlon","lev":"z_t"},
       "ice":{"lat":"nj","lon":"ni","lev":"nc"}
}

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
    return nc_files

def fill_list(nc_files, root_dir, extra_dir, comm, rank, size):

    variablelist = {}
    gridfiles = {}
    nc_files_l = comm.partition(nc_files,func=partition.EqualLength(),involved=True)
    for fn in nc_files_l:
        f = nc.Dataset(fn, "r")
        mt = fn.replace(root_dir,"").split("/")[-5]         
        str = fn
        model_type = mt
        if "lnd" in model_type or "rof" in model_type:
            model_type = 'lnd,rof'
        if "glc" in model_type:
            model_type = 'glc,lnd'
        if ("time" not in f.variables.keys() or "tseries" not in fn):
            variablelist["skip"] = {}
        else:
            lt = "none"
            ln = "none"
            lv = "none"
            if grids[mt]['lat'] != None:
                lt = len(f.dimensions[grids[mt]['lat']])
            if grids[mt]['lon'] != None:
                ln = len(f.dimensions[grids[mt]['lon']])
            if grids[mt]['lev'] != None:
                lv = len(f.dimensions[grids[mt]['lev']])
            gridfiles[mt] = '{0}/{1}x{2}x{3}.nc'.format(extra_dir,lt,ln,lv)

            for vn,ob in f.variables.iteritems():
                if model_type not in variablelist.keys():
                    variablelist[model_type] = {}
                if vn not in variablelist[model_type].keys():
                     variablelist[model_type][vn] = {}
                if hasattr(f,"time_period_freq"):
                    if f.time_period_freq not in variablelist[model_type][vn].keys():
                        variablelist[model_type][vn][f.time_period_freq] = {}
                    date = str.split('.')[-2]      
                    if date not in variablelist[model_type][vn][f.time_period_freq].keys():
                        variablelist[model_type][vn][f.time_period_freq][date] = []
                    if str not in variablelist[model_type][vn][f.time_period_freq][date]:
                        variablelist[model_type][vn][f.time_period_freq][date].append(str);
                else:
                    if "unknown" not in variablelist[model_type][vn].keys():
                        variablelist[model_type][vn]["unknown"] = {}
                    if str not in variablelist[model_type][vn]["unknown"]:
                        variablelist[model_type][vn]["unknown"]["unknown"] = str;
        f.close()
    VL_TAG = 30
    GF_TAG = 31
    variable_list = {}
    grid_files = {}
    if size > 1:
        if rank==0:
            variable_list = variablelist
            grid_files = gridfiles
            for i in range(0,size-1): 
                r,lvarList = comm.collect(data=None, tag=VL_TAG)
                for model_type,d1 in lvarList.iteritems():
                    if model_type not in variable_list.keys():
                        variable_list[model_type] = {}
                    for vn,d2 in d1.iteritems():
                        if vn not in variable_list[model_type].keys():
                            variable_list[model_type][vn] = {}
                        for tp,d3 in d2.iteritems():
                            if tp not in variable_list[model_type][vn].keys():
                                variable_list[model_type][vn][tp] = {}
                            for date,l in d3.iteritems():
                                if date not in variable_list[model_type][vn][tp].keys():
                                    variable_list[model_type][vn][tp][date] = []
                                variable_list[model_type][vn][tp][date] = variable_list[model_type][vn][tp][date]+lvarList[model_type][vn][tp][date]          

                r,lgridfiles = comm.collect(data=None, tag=GF_TAG)
                for k,d in lgridfiles.iteritems():
                    if k not in grid_files.keys():
                        grid_files[k] = d                    
#                variable_list.update(lvarList)
            comm.partition(variable_list, func=partition.Duplicate(), involved=True)
            comm.partition(grid_files, func=partition.Duplicate(), involved=True)
        else:
            comm.collect(data=variablelist, tag=VL_TAG)
            comm.collect(data=gridfiles, tag=GF_TAG)
            variable_list = comm.partition(func=partition.Duplicate(), involved=True)
            grid_files = comm.partition(func=partition.Duplicate(), involved=True)
        comm.sync()
    return variable_list,grid_files

def match_tableSpec_to_stream(ts_dir, variable_list, grid_files):

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
        var_defs[j] = {}
        missing = {}
        dims = []
        no_def = []
        rl = None
        freql = None
        dates = []

        # get the cesm var names from the defs in json file
        cmd = "vardeps -f -n "+j
        #print '---------------------------------------'
        #print cmd
        p = subprocess.Popen([cmd], stderr=subprocess.PIPE, stdout=subprocess.PIPE, shell=True)
        end = False
        output = p.stdout.read().split('\n')
        print p.stderr.read()
        for l in output:
            if '[' in l and ']' in l and ':' in l:
                split = l.split();
                var_defs[j][split[0]] = {}
                var_defs[j][split[0]]["freq"] = split[1].replace("[","").replace("]","").replace(":","").split(",")[0]
                if 'fx' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'mon'
                elif '6hr' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'hour_6'
                elif '3hr' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'hour_3'
                elif '1hr' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'hour_1'
                elif 'subhr' in var_defs[j][split[0]]["freq"]:
                    var_defs[j][split[0]]["freq"] = 'min_30'
                var_defs[j][split[0]]["realm"] = split[1].replace("[","").replace("]","").replace(":","").split(",")[1]
                var_defs[j][split[0]]["vars"] = l.split(":")[1].split()
                var_defs[j][split[0]]["var_check"] = {}
                #Look up
                for v in var_defs[j][split[0]]["vars"]:
                    var_defs[j][split[0]]["var_check"][v] = []
                    r = var_defs[j][split[0]]["realm"]
                    f = var_defs[j][split[0]]["freq"]
                    found_r = None
                    if cmip6_realms[r] not in variable_list.keys(): 
                        print "Could not find ",cmip6_realms[r]," in ",variable_list.keys()
                    else:
                        if v in variable_list[cmip6_realms[r]].keys():
                            found_r = cmip6_realms[r]
                        elif ',' in cmip6_realms[r]:
                            if 'glc' in cmip6_realms[r]:
                                if v in variable_list['lnd,rof'].keys(): 
                                    found_r = 'lnd,rof'                       
                    if found_r != None:     
                            for freq in variable_list[found_r][v].keys():
                                if f in freq:
                                    var_defs[j][split[0]]["var_check"][v] = variable_list[found_r][v][freq]
                                    rl = r
                                    freql = freq
                                    for date in variable_list[found_r][v][freq].keys():
                                        fl1 = variable_list[found_r][v][freq][date][0]
                                        if (j+">>"+date) not in spec_streams.keys():
                                            spec_streams[j+">>"+date] = []
                                        if fl1 not in spec_streams[j+">>"+date]:
                                            spec_streams[j+">>"+date].append(fl1)
                                        if grid_files[r2c[r]] not in spec_streams[j+">>"+date]:
                                            spec_streams[j+">>"+date].append(grid_files[r2c[r]])

                    if len(var_defs[j][split[0]]["var_check"][v]) < 1:
                        if v not in missing.keys():
                            missing[v] = "(",f,",",r,")"
            elif len(l.split(':')) > 1:
                if 'No dependencies' in l:
                    no_def.append(l.split(':')[0].strip())
                else:
                    if l.split(':')[1] != '':
                        dims.append(l.split(':')[1].strip())
            #if end:
            #    print l
            if 'Complete Specification Requires the Following Input Variables:' in l:
                print 'Requires these variables:'
                end = True

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

    ## Used the main function in pyconform to prepare the call

    spec_fn = spec.split(">>")[0]
    spec_d = spec.split(">>")[1]

    # get infiles
    infiles = []
    for v in sorted(file_glob):
        infiles.append(v)
    
    # load spec json file
    dsdict = json_load(open(spec_fn,'r'), object_pairs_hook=OrderedDict)

    try:
        # Parse the output dataset
        outds = OutputDatasetDesc(dsdict=dsdict)

        # Parse the input dataset
        inpds = InputDatasetDesc(filenames=infiles)

        # Setup the PyConform data flow
        dataflow = DataFlow(inpds, outds)

        # Execute
        dataflow.execute(serial=True, scomm=comm) 

    except UnitsError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
    except IndexError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
    except ValueError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
    except KeyError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
    except IOError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
    except NameError as e:
        print ("ooo ERROR IN ",os.path.basename(spec_fn),str(e))
#======
# main
#======

def main(options, scomm, rank, size):
    """
    """
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
        load_source('user{}'.format(i), conform_module_path+"/"+m)

    # create the cesm stream to table mapping
#    if rank == 0:
    dout_s_root = cesmEnv['DOUT_S_ROOT']
    case = cesmEnv['CASE']
    pc_inpur_dir = cesmEnv['CONFORM_JSON_DIRECTORY']+'/PyConform_input/'
    #readArchiveXML(caseroot, dout_s_root, case, debug)
    nc_files = find_nc_files(dout_s_root)
    variable_list,grid_files = fill_list(nc_files, pc_inpur_dir, cesmEnv["CONFORM_EXTRA_FIELD_NETCDF_DIR"], scomm, rank, size)
    print "Using grid files: ",grid_files

    mappings = {}
    if rank == 0:
        mappings = match_tableSpec_to_stream(pc_inpur_dir, variable_list, grid_files)
        for k,v in sorted(mappings.iteritems()):
            print k
            for f in sorted(v):
                print f
            print len(v),'\n\n'
    scomm.sync()

    # Pass the stream and mapping information to the other procs
    mappings = scomm.partition(mappings, func=partition.Duplicate(), involved=True)

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
            for i in range(0,lsubcomms): # complete, signal this to all subcomms
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
                    run_PyConform(i, mappings[i], inter_comm)
                    print "(",rank,"/",lrank,")","  finished running ",i
                inter_comm.sync()

        # all subcomm ranks - recv the specifier to work on and call the reshaper
        else:
            i = -999
            while i != -99:
                i = inter_comm.ration(tag=LWORK_TAG) # recv from local root    
                if i != -99:
                    print "(",rank,"/",lrank,")","  start running ",i
                    run_PyConform(i, mappings[i], inter_comm)
                    print "(",rank,"/",lrank,")","  finished running ",i
                inter_comm.sync()
    #print "(",rank,"/",lrank,")","  FINISHED"
    scomm.sync()

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
