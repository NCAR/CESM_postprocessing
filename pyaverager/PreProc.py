import Nio
from asaptools import partition
import rover
import climFileIO
import numpy as np
import os
from numpy import ma as MA
import average_types as ave_t

def run_pre_proc(spec):
    
    return PreProc(spec)

class PreProc(object):

    def __init__(self,spec):

        self.create_pre_proc(spec)


    def read_reg_mask(self,reg_file,reg_name):

        '''
        Reads in the region mask file and returns the mask.

        @param reg_file    The netCDF files that contains a region mask.

        @param reg_name    Name of the ice region to pull.

        @return value      The masked region.

        '''

        file_hndl = Nio.open_file(reg_file,'r') 
        reg_mask = file_hndl.variables[reg_name+'_mask']
        value = reg_mask[0][:]
        file_hndl.close()
        return value


    def get_sum(self,masked_var,var_info,var):

      '''
      Sums the variable across dimensions.

      @param masked_var   The values to sum.

      @param var_info     Contains the factor.

      @param var          Variable name.

      @returns var_val    The sum across dimensions.
      '''

      # Get sums along the lat and lon dimensions and mult by the factor
      masked_var = masked_var
      first_sum = masked_var.sum(axis=1)
      second_sum = first_sum.sum(axis=0)
      var_val = second_sum * var_info['factor']
      return var_val


    def create_pre_proc(self,spec):

        '''
        Creates the CICE pre_proc file.

        @param spec          An instance of the Specification class which holds the user settings
                             that define which averages to compute, directories, file prefixes, etc    
        '''

	variables = {'hi':{'factor':1.0e-13,'units':'1.E+13 m3'},
		     'ai':{'factor':1.0e-14,'units':'1.E+13 m3'},
		     'ext':{'factor':1.0e-12,'units':'1.E+12 m2'},
		     'hs':{'factor':1.0e-13,'units':'1.E+12 m2'},
	}

        #  All of the region names, with 0=Northern Hem and 1=Southern Hem
	regions = {'nh':0, 'sh':1, 'Lab':0,'GIN':0,'Bar':0,'ArcOc':0,'Sib':0,'Beau':0,
                   'CArc':0,'Bering':0,'Okhotsk':0,'Hudson':0,'CAArch':0,
                   'Wed':1,'Ross':1,'Ind':1,'Pac':1,'BAm':1}

        split_hem = spec.split_files.split(',') 

        attributes = {'missing_value':1.e+30, 'coordinates':'time', 'cell_methods':'time:mean','_FillValue':1.e+30}

	poly_masks = {}
        ave_descr = ['preproc',str(spec.year0),str(spec.year1)]

        AVE_TAG = 40
 
        time_dim = 'time'
 
        years = list(range(int(spec.year0),int(spec.year1)+1))
        months = ave_t.average_types[ave_descr[0]]['months_to_average']

	# Initialize simplecomm (MPI wrappers) 
	main_comm = spec.main_comm 

        # If the region mask file doesn't exist, have root call ncl to create it
        if (not os.path.isfile(spec.reg_file) and (main_comm.is_manager() or spec.serial)):
            import subprocess
            os.environ['GRIDFILE'] = spec.ice_obs_file
            os.environ['REGIONFILE'] = spec.reg_file
            ncl_command = 'ncl < '+ spec.ncl_location +'/ice_pre_proc_mask.ncl'
            subprocess.call(ncl_command,shell=True)
        # make sure to have all ranks sync to prevent ranks other than root from continuing on without a region mask file
        main_comm.sync()

	# Get the history dictionary that lists were files are located for each time slice, a variable list, meta list, and a key lookup variable
	if (spec.hist_type == 'series'):
	    hist_dict,file_var_list,meta_list,key = rover.set_slices_and_vars_time_series(spec.in_directory, spec.file_pattern, spec.date_pattern, 
							spec.prefix, spec.suffix, int(spec.year0), int(spec.year1), spec.split, spec.split_files)
	else:
	    hist_dict,file_var_list,meta_list,key = rover.set_slices_and_vars_time_slice(spec.in_directory, spec.file_pattern, spec.prefix, spec.suffix, int(spec.year0), int(spec.year1))

	# Loop over the regions and variable names to get full list of variables
        global_var_list = []
	for reg in regions:
            for var in variables:
                if ('ext' in var):
                    global_var_list.append(var+'_mo_'+reg) 
                else:
	            global_var_list.append('v'+var+'_mo_'+reg)
        global_var_list.append('time') 

	# Partition the global variable list between the MPI ranks
	local_var_list = main_comm.partition(global_var_list,func=partition.EqualLength(),involved=False)
	# If master/root, give it the full variable list
	if main_comm.is_manager() or spec.serial:
	    local_var_list = global_var_list

        meta_list = []

	# Define the netcdf file
        outfile = 'ice_vol_'+spec.prefix[:-7]+'_'+str(spec.year0)+'-'+str(spec.year1)+'.nc'
        ave_date = str(spec.year0)+'-'+str(spec.year1)
	all_files_vars,new_file = climFileIO.define_ave_file(main_comm.is_manager(),spec.serial,global_var_list,local_var_list,meta_list,hist_dict,spec.hist_type,
	    ave_descr,spec.prefix,outfile,spec.split,split_hem[regions['GIN']],spec.out_directory,main_comm,spec.ncformat,
	    ave_t.average_types[ave_descr[0]]['months_to_average'][0],key,spec.clobber,int(spec.year0),int(spec.year1),ave_date,attributes,variables)
       

	# If using time slice files, open all files now
        if (len(local_var_list) > 0):
	    if (spec.hist_type == 'slice' and (spec.serial or not main_comm.is_manager())):
	        file_dict,open_list = climFileIO.open_all_files(hist_dict,ave_t.average_types[ave_descr[0]]['months_to_average'],
		    		        years,local_var_list[0],'null',ave_descr[0],False,int(spec.year0))

	# Loop over each variable in the local list and read/operate on/write
	for nc_var in local_var_list:
	    if not main_comm.is_manager() or spec.serial: # Slave
                print('Computing ice_pre_proc for', nc_var)
              # Get variable/region names
                if ('time' in nc_var):
                    get_var_name = 'aice'
                    var_name = 'time'
                else:
                    var_name,reg = nc_var.split('_mo_')
                    if ('ext' in var_name):
                        var_name = var_name
                    else:
                        var_name = var_name[1:]
                    if ('ext' in var_name or 'ai' in var_name):
                        get_var_name = 'aice'
                    else:
                        get_var_name = var_name
                # Get observation lat,lon,area
                obs_file = spec.ice_obs_file
                tarea = 'TAREA'
                tlong = 'TLONG'
                tlat = 'TLAT'

                # Read in the ice observation file to get area, lat, and lon values.
                obs_file_hndl = Nio.open_file(obs_file,'r')
                o_lat = obs_file_hndl.variables[tlat]
                o_lon = obs_file_hndl.variables[tlong]
                o_area = obs_file_hndl.variables[tarea]
                o_area = o_area[:]*1.0e-4

		# If using time series files, open the variable's file now
		if (spec.hist_type == 'series'):
                    if spec.split:
                        split_name = split_hem[regions[reg]]
                    else:
                        split_name = ''
		    file_dict,open_list = climFileIO.open_all_files(hist_dict,ave_t.average_types[ave_descr[0]]['months_to_average'],
					    years,get_var_name,split_name,ave_descr[0],False,int(spec.year0)) 

	    time_slice = 0
	    for year in years:
              for m in months:
		if not main_comm.is_manager() or spec.serial: # Slave
                    if ('time' in nc_var):
                        var_sum = rover.fetch_slice(hist_dict, year, m, var_name, file_dict)
                    else:
		        # Get month slice
		        var_slice = rover.fetch_slice(hist_dict, year, m, get_var_name, file_dict)
                        lat,lon = var_slice.shape
                        full_lat,full_lon = o_lat.shape
                        if spec.split:
                            fill = full_lat-lat
                            missing_vals = np.zeros((fill,lon))
                            var_slice = np.array(var_slice)
                            var_slice[var_slice >= 1e+20] = 0 
                            if regions[reg] == 1: 
                                var_slice = np.concatenate((var_slice,missing_vals),axis=0)
                            else:
                                var_slice = np.concatenate((missing_vals,var_slice),axis=0)

		        # Get ai factor
		        if ('ext' in var_name or 'ai' in var_name):
			    aimax = np.amax(var_slice)
			    if (aimax < 2):
			        aifac = 100
			    else:
			        aifac = 1
			    var_slice = var_slice*aifac
                       # The ext variable is true/false based on the ai variable.  Set accordingly 
                        if ('ext' in var_name):
                            var_slice = np.array(var_slice)
                            var_slice[var_slice >= 1e+20] = 0
                            var_slice[var_slice < 15] = 0
                            var_slice[var_slice >= 15] = 1

                        # Mult by weight
                        var_slice = var_slice * o_area

                        # Mask the variable to get just this region
                        mask_to_apply = self.read_reg_mask(spec.reg_file,reg)
                        masked_var = MA.masked_where(mask_to_apply==0,var_slice) 

                        # Sum the variable 
		        var_sum = self.get_sum(masked_var,variables[var_name],var_name)

		    # Pass the average results to master rank for writing
		    var_shape = var_sum.shape
		    var_dtype = var_sum.dtype
		    md_message = {'name':nc_var,'shape':var_shape,'dtype':var_dtype,'average':var_sum,'index':time_slice}
		    if not spec.serial:
			main_comm.collect(data=md_message, tag=AVE_TAG)

		if main_comm.is_manager() or spec.serial: # Master
		    # Recv the variable to write
		    if not spec.serial:
			r_rank,results = main_comm.collect(tag=AVE_TAG)
			var_sum_results = results['average']
			v_name = results['name']
			index = results['index']
		    else:
			v_name = nc_var
			var_sum_results = var_sum    
			index = time_slice

		    #Write Var
		    climFileIO.write_averages(all_files_vars, var_sum_results, v_name, index)

		time_slice = time_slice + 1    
	    # Close timeseries files that are open
	    if (spec.hist_type == 'series' and (not main_comm.is_manager() or spec.serial)):
		climFileIO.close_all_files(open_list)

	# Close timeslice files that are open
        if (len(local_var_list) > 0):
	    if (spec.hist_type == 'slice' and (spec.serial or not main_comm.is_manager())):
	        climFileIO.close_all_files(open_list)   
 
        # Make sure everyone gets sync'ed up
        main_comm.sync()

	# Close the file that was just created
	if spec.serial or main_comm.is_manager():
	    new_file.close()
 
