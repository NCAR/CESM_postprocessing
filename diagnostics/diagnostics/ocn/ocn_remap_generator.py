#!/usr/bin/env python
# This wrapper script calls the ocean_remap class to remap CESM CMIP6 conformed variables
# on the native 1-degree Greenland displace pole grid (gx1v7) to a regular lat-lon grid.

from __future__ import print_function
import sys

# check the system python version and require 3.7.x or greater
if sys.hexversion < 0x03070000:
    print(70 * '*')
    print('ERROR: {0} requires python >= 3.7.x. '.format(sys.argv[0]))
    print('It appears that you are running python {0}'.format(
        '.'.join(str(x) for x in sys.version_info[0:3])))
    print(70 * '*')
    sys.exit(1)

import argparse
import glob, sys, os, fnmatch
import netCDF4 as nc

from asaptools import partition, simplecomm, vprinter, timekeeper
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

from ocean_remap import ocean_remap as remap


#=====================================================
# commandline_options - parse any command line options
#=====================================================
def commandline_options():
    """Process the command line arguments.
    """
    parser = argparse.ArgumentParser(
        description='ocn_remap_generator: CESM wrapper python program for ocean remap package.')

    parser.add_argument('--backtrace', action='store_true',
                        help='show exception backtraces as extra debugging '
                        'output')

    parser.add_argument('--debug', nargs=1, required=False, type=int, default=0,
                        help='debugging verbosity level output: 0 = none, 1 = minimum, 2 = maximum. 0 is default')

    parser.add_argument('--caseroot', nargs=1, required=True, 
                        help='fully quailfied path to case root directory')

    parser.add_argument('--standalone', action='store_true',
                        help='switch to indicate stand-alone post processing caseroot')

    options = parser.parse_args()

    # check to make sure CASEROOT is a valid, readable directory
    if not os.path.isdir(options.caseroot[0]):
        err_msg = ' ERROR: ocn_remap_generator.py invalid option --caseroot {0}'.format(options.caseroot[0])
        raise OSError(err_msg)

    return options

#======
# main
#======

def main(options, main_comm, debugMsg):
    """
    read env_ocn_remap.xml settings to call the ocean_remap class
    """
    # initialize the environment dictionary
    envDict = dict()


    # Get rank and size
    rank = main_comm.get_rank()
    size = main_comm.get_size()

    # CASEROOT is given on the command line as required option --caseroot
    if rank == 0:
        caseroot = options.caseroot[0]
        envDict['CASEROOT'] = options.caseroot[0]
        debugMsg('caseroot = {0}'.format(envDict['CASEROOT']), header=True, verbosity=2)

        env_file_list =  ['./env_postprocess.xml', './env_ocn_remap.xml']
        envDict = cesmEnvLib.readXML(caseroot, env_file_list)

        # strip the OCNREMAP_ prefix from the envDict entries before setting the 
        # enviroment to allow for compatibility with all the diag routine calls
        envDict = diagUtilsLib.strip_prefix(envDict, 'OCNREMAP_')

        print ("cmip6: {0}".format(envDict['cmip6']))
        print ("filelist: {0}".format(envDict['filelist']))
        print ("matrix_2d_fname: {0}".format(envDict['matrix_2d_fname']))
        print ("matrix_3d_fname: {0}".format(envDict['matrix_3d_fname']))
        print ("indir: {0}".format(envDict['indir']))
        print ("outdir: {0}".format(envDict['outdir']))
        print ("chunk size: {0}".format(envDict['chunk']))

    # broadcast envDict to all tasks
    envDict = main_comm.partition(data=envDict, func=partition.Duplicate(), involved=True)
    main_comm.sync()

    files = []
    if rank == 0:
        # Find files to regrid
        #Do we have a cmip6 variable list?
        if envDict['cmip6'] is not None:
            if envDict['indir'] is not None:
                with open(envDict['cmip6']) as f:
                    for l in f:
                        t = l.strip().split(':')[0]
                        v = l.strip().split(':')[1]
                        print ("Trying to find: {0}_{1}*.nc".format(v,t))
                        for root, dirs, fns in os.walk(envDict['indir']):
                            for fn in fnmatch.filter(fns, v+'_'+t+"*.nc"):
                                if 'tmp.nc' not in fn and 'gr' not in fn.split('_'):
                                    print ("Found: {0}".format(fn.split('/')))
                                    files.append(os.path.join(root, fn))
            else:
                print ("You need to specify an indir argument with the cmip6 argument")
                file = None
        elif envDict['filelist'] is not None:
            with open(envDict['filelist']) as f:
                for l in f:
                    files.append(l.strip())
        elif envDict['indir'] is not None:
            for root, dirs, fns in os.walk(envDict['indir']):
                for fn in fnmatch.filter(fns, "*.nc"):
                    files.append(os.path.join(root, fn))
        else:
            print ('Exiting because no input path or files where given')
            files = None

    # All call this
    main_comm.sync()
    files = main_comm.partition(files, func=partition.Duplicate(), involved=True)
    if files is None:
        sys.exit()

    #matrix_2d_fname = 'POP_gx1v7_to_latlon_1x1_0E_mask_conserve_20181015.nc'
    matrix_2d = remap.ocean_remap(envDict['matrix_2d_fname'])

    #matrix_3d_fname = 'POP_gx1v7_to_latlon_1x1_0E_fulldepth_conserve_20181015.nc'
    matrix_3d = remap.ocean_remap(envDict['matrix_3d_fname'])

    # names of coordinate dimensions in output files
    dim_names = {'depth': 'olevel', 'lat': 'latitude', 'lon': 'longitude'}
    dim_names = {'depth': 'lev', 'lat': 'lat', 'lon': 'lon'}

    main_comm.sync()
    # Have only root create these files
    if rank == 0:
        if len(files) > 0 and envDict['cmip6'] is not None:
            temp = files[0]
            # create CMIP Ofx files
            for var_name in ('areacello', 'deptho', 'thkcello', 'volcello'):
                new_outdir = temp.replace(temp.split('/')[-4],var_name).replace(temp.split('/')[-5],'Ofx').replace(temp.split('/')[-3],'gr').replace('_'+temp.split('_')[-1],'')+'.nc' 
                d = os.path.dirname(new_outdir)
                if not os.path.exists(d):
                    os.makedirs(d)
                fptr_out = nc.Dataset(new_outdir, 'w') # pylint: disable=E1101
                matrix_3d.dst_grid.def_dims_common(fptr_out, dim_names)
                matrix_3d.dst_grid.write_vars_common(fptr_out, dim_names)
                matrix_3d.dst_grid.write_var_CMIP_Ofx(fptr_out, dim_names, var_name)

    # Create a master slave parallel protocol
    GWORK_TAG = 10 # global comm mpi tag
    if (rank == 0):
        for i in files:
            main_comm.ration(data=i, tag=GWORK_TAG)
        for i in range(1,size):
            main_comm.ration(data=-99, tag=GWORK_TAG)
    else:
        f = -999
        while f != -99:
            f = main_comm.ration(tag=GWORK_TAG)
            if f != -99:
                print ("working on: {0}".format(f))
                testfile_in_fname = f
                testfile_out_fname = f.replace(f.split('/')[-3],'gr')
                if not os.path.exists(testfile_out_fname):
                  d = os.path.dirname(testfile_out_fname)
                  if not os.path.exists(d): 
                      os.makedirs(d) 
                  fptr_in = nc.Dataset(testfile_in_fname, 'r') # pylint: disable=E1101
                  if (len(fptr_in[f.split('/')[-4]].dimensions) == 4 or len(fptr_in[f.split('/')[-4]].dimensions) == 3):
                    fptr_out = nc.Dataset(testfile_out_fname+'.tmp', 'w') # pylint: disable=E1101

                    remap.copy_time(fptr_in, fptr_out)
                    remap.copy_gAttr(fptr_in, fptr_out)

                    if dim_names['depth'] in fptr_in.dimensions:
                        matrix_3d.dst_grid.def_dims_common(fptr_out, dim_names)
                        matrix_3d.dst_grid.write_vars_common(fptr_out, dim_names)
                    else:
                        matrix_2d.dst_grid.def_dims_common(fptr_out, dim_names)
                        matrix_2d.dst_grid.write_vars_common(fptr_out, dim_names)

                    field_names = []
                    for v in fptr_in.variables:
                        if v not in ['lat', 'lat_bnds', 'lon', 'lon_bnds', 'lev', 'lev_bnds', 'time', 'time_bnds', 'nlat', 'nlon']:
                            field_names.append(v)            

                    for field_name in field_names:

                        varid_out = remap.def_var(field_name, fptr_in, fptr_out, dim_names)

                        # use appropriate matrix for regridding
                        c = envDict['chunk']
                        if c is None:
                            c = 1
                        else:
                            c = int(c)  
                        try: 
                            if dim_names['depth'] in varid_out.dimensions:
                                #print ("Running a 3D variable")
                                b = 0
                                for i in range(0,fptr_in.dimensions['time'].size,c):
                                    if b+c >= fptr_in.dimensions['time'].size:
                                        c = fptr_in.dimensions['time'].size - b
                                    varid_out[b:(b+c),:,:,:] = matrix_3d.remap_var(fptr_in.variables[field_name][b:(b+c),:,:,:])#,
                                                                       #fill_value=getattr(varid_out, 'missing_value'))
                                    b = b+c
                            else:
                                #print ("Running a 2D variable")
                                b = 0
                                for i in range(0,fptr_in.dimensions['time'].size,c):
                                    if b+c >= fptr_in.dimensions['time'].size:
                                        c = fptr_in.dimensions['time'].size - b
                                    varid_out[b:(b+c),:,:] = matrix_2d.remap_var(fptr_in.variables[field_name][b:(b+c),:,:])#,
                                                                   #fill_value=getattr(varid_out, 'missing_value'))
                                    b = b+c
                        except TypeError as e:
                            print ('Type Error for variable {0} '.format(field_name))
                    fptr_in.close()
                    fptr_out.close()
                    try:
                        os.rename(testfile_out_fname+'.tmp',testfile_out_fname)
                    except OSError as e:
                        print ('Could not create {0}'.format(testfile_out_fname))
                  else: 
                    print ("Not creating {0}".format(testfile_out_fname))
    main_comm.sync()

#===================================================================================================
if __name__ == "__main__":
    # initialize simplecomm object
    main_comm = simplecomm.create_comm(serial=False)

    # setup an overall timer
    timer = timekeeper.TimeKeeper()

    # get commandline options
    options = commandline_options()

    # initialize global vprinter object for printing debug messages
    if options.debug:
        header = "[" + str(main_comm.get_rank()) + "/" + str(main_comm.get_size()) + "]: DEBUG... "
        debugMsg = vprinter.VPrinter(header=header, verbosity=options.debug[0])
    
    try:
        timer.start("Total Time")
        status = main(options, main_comm, debugMsg)
        main_comm.sync()
        timer.stop("Total Time")
        if main_comm.is_manager():
            print('***************************************************')
            print('Total Time: {0} seconds'.format(timer.get_time("Total Time")))
            print('Successfully completed generating ocean remapped files')
            print('***************************************************')
        sys.exit(status)

    except Exception as error:
        print(str(error))
        if options.backtrace:
            traceback.print_exc()
        sys.exit(1)


