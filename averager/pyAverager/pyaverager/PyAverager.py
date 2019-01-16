'''
Contributor License Agreement

This Contributor License Agreement ("Agreement") is a legal agreement between you (in your capacity as an individual and as an agent for your company, institution or other entity) (collectively, "you" or "your" or "Licensee") and the University Corporation for Atmospheric Research ("UCAR").

    License Grant to Technology. UCAR grants to Licensee a restricted, royalty-free, perpetual, nonexclusive, nontransferable, noncommercial license to copy, modify, enhance, improve and use the NCAR PyAverager code set for averaging climate output provided in source code format Technology for research purposes and for collaborating with UCAR only; provided, however, that Licensee does not commercialize, sell, license, distribute, or transfer the Technology, or any work that contains the Technology. Licensee may freely use the data and results from the Technology. Licensee shall note in all publications of data or results that this Technology is provided by UCAR and the NCAR Computational and Information Systems Laboratory. Licensee must reproduce all copyright notices and other proprietary notices on any copies of the Technology, and Licensee shall not remove any copyright information appearing in or on the Technology files.
    Ownership of Technology. UCAR owns and retains all title, copyright, and other proprietary interests in the Technology, including any copies thereof. No ownership rights of any kind are transferred to you.
    Licensee Contributions. Licensee shall submit contributions to the Technology to UCAR through the collaboration tools provided by UCAR. "Contribution" shall mean any independent original work of authorship, including any enhancements, improvements, modifications, additions, bug fixes, patches, or upgrades to the Technology that is intentionally submitted by you to UCAR for inclusion in the Technology. You are the owner of your Contributions, but you acknowledge that UCAR retains ownership of the Technology.
    License Grant to Licensee Contributions. You hereby grant to UCAR, and to any recipients of the Technology distributed by UCAR, a perpetual, worldwide, non-exclusive, royalty-free, irrevocable license to reproduce, incorporate freely into the Technology, sublicense, display, and distribute your Contributions. You represent that you are legally entitled to grant the above license. If your employer(s) has rights to intellectual property that you create that includes your Contributions, you acknowledge that you are allowed to make Contributions on behalf of that employer.
    Disclaimer of Warranty/Noninfringement. THE TECHNOLOGY IS SUPPLIED AS IS WITHOUT WARRANTY OF ANY KIND. UCAR DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION, ANY IMPLIED WARRANTIES OF NONINFRINGEMENT, ORIGINALITY, MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE WITH REGARD TO THE TECHNOLOGY PROVIDED HEREUNDER. UCAR MAKES NO REPRESENTATIONS THAT THE USE, OPERATION, SALE, PERFORMANCE, MODIFICATION, REPRODUCTION, DISPLAY OF THE TECHNOLOGY WILL NOT INFRINGE UPON ANY PROPRIETARY RIGHTS OF ANY THIRD PARTY.
    Limitation of Liability. IN NO EVENT SHALL UCAR BE LIABLE TO LICENSEE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL DAMAGES, INCLUDING LOST OR ANTICIPATED PROFITS OR REVENUE INCURRED BY LICENSEE OR ANY THIRD PARTY, WHETHER IN AN ACTION IN CONTRACT OR TORT, EVEN IF UCAR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES IN THE PERFORMANCE OF THIS LICENSE, OR RELATED TO THE TECHNOLOGY. LICENSEE ALSO ACKNOWLEDGES THAT ANY BREACH OF ITS OBLIGATIONS WITH RESPECT TO PROPRIETARY RIGHTS WILL CAUSE UCAR IRREPARABLE INJURY FOR WHICH THERE ARE INADEQUATE REMEDIES AT LAW. AS SUCH, UCAR SHALL BE ENTITLED TO EQUITABLE RELIEF IN ADDITION TO ALL OTHER REMEDIES AVAILABLE TO IT.
    High Risk Activities. The Technology is research-based, not fault-tolerant, and is not designed, manufactured or intended for use in any operational activities including activities or hazardous environments requiring fail-safe performance, such as in aircraft navigation or communication systems, air traffic control, weapons systems, nuclear power plants or critical 24/7 operations, in which the failure of the Technology could lead directly to death, personal injury, or severe physical or environmental damage (High Risk Activities). Accordingly, UCAR specifically disclaims any express or implied warranties of fitness for High Risk Activities. You agree that UCAR shall not be liable for any claims or damages arising from High Risk Activities.
    Controlling Law. This Agreement shall be governed by the laws of the State of Colorado and of the United States.
'''

def run_pyAverager(spec):

    '''
    A callable routine users call to start computing averages.  Returns an
    instance of the PyAverager when all averages have been computed.

    @param spec          An instance of the Specification class which holds the user settings
                         that define which averages to compute, directories, file prefixes, etc

    @return PyAverager   An instance of the PyAverager class.
    '''    
    
    return PyAverager(spec)


class PyAverager(object):

    def __init__(self,spec):

        '''
        Calls the compute_averages function to setup and compute the needed averages.

        @param spec          An instance of the Specification class which holds the user settings
                             that define which averages to compute, directories, file prefixes, etc    
        '''
        self.compute_averages(spec)


    def compute_averages(self,spec):

        '''
        Sets up the run information and computes the averages.

        @param spec          An instance of the Specification class which holds the user settings
                             that define which averages to compute, directories, file prefixes, etc
        '''
        import os,sys
        import rover
        import climAverager
        import climFileIO
        import average_types as ave_t
        import regionOpts
        import string
        import collections
        from asaptools import timekeeper
        from asaptools import partition 
#==============================================================================
#
# Initialize 
#
#==============================================================================
        # Initialize the timekeeper class and start 'total' timer
        timer = timekeeper.TimeKeeper()
        timer.start("Total Time")
        # Initialize some timers that are not used by all tasks
        timer.reset("Send Average Time")
        timer.reset("Variable fetch time")
        timer.reset("Recv Average Time")
        timer.reset("Write Netcdf Averages")
        timer.reset("Variable fetch time")
        timer.reset("Time to compute Average")

        # Check average list to make sure it complies with the standards
        ave_t.average_compliance(spec.avg_list)

        # Check if I'm the global master
        g_master = spec.main_comm.is_manager()

        for tag in spec.m_id:
    
            file_pattern = list(spec.file_pattern)

            if ('-999' not in tag):
                prefix = spec.prefix + '_' + tag
                p_index = file_pattern.index('$prefix')
                t_index = file_pattern.index('$m_id')
 
                for i in range(p_index+1,t_index+1):
                    del file_pattern[p_index+1]
            else:
                prefix = spec.prefix

	    # Sort through the average list and figure out dependencies and do
	    # averages in steps if need be.
	    avg_dict = {0:spec.avg_list}
	    for i in range(1,20):
		avg_dict[i] = []
	    avg_dict = ave_t.sort_depend(avg_dict,0,spec.out_directory,prefix,spec.regions)
            print avg_dict

	    # Initialize the tag for the average send/recv
	    AVE_TAG = 40
            VNAME_TAG = 41	   
 
	    #start_level = 0
            start_level = min(avg_dict.keys())
	    found_level = False
	    #for i in range(0,len(avg_dict)):
#		if found_level == False:    
#		    if (i in avg_dict): 
#			start_level = i
#			found_level = True

            ordered_avg_dict =  collections.OrderedDict(avg_dict)
	    #for i in range(start_level,len(avg_dict)):
            for i,value in ordered_avg_dict.items():
	     
		# Initialize some containers 
		var_list = []
		full_hist_dict = {}
		hist_dict = {}

    #==============================================================================
    #
    # Set the hist_dict up with file references for all years/months.
    # Create a list of all variables and meta variables within the file
    # and set the final variable list passed on user preferences. 
    #
    #==============================================================================

		## Set var_list and file info dictionary
		timer.start("Define history dictionary")
		if (spec.hist_type == 'series'):
		    full_hist_dict,full_var_list,meta_list,key = rover.set_slices_and_vars_time_series(spec.in_directory, file_pattern, spec.date_pattern, 
								    prefix, spec.suffix, spec.year0, spec.year1, spec.split, spec.split_files)
		else:
		    full_hist_dict,full_var_list,meta_list,key = rover.set_slices_and_vars_time_slice(spec.in_directory, file_pattern, prefix, spec.suffix, spec.year0, spec.year1)
		timer.stop("Define history dictionary")

		# Set variable list.  If there was a variable list passed to the averager, use this list.  Other wise,
		# use all variables within the file.
		if (len(spec.varlist)>0):
		    var_list = spec.varlist
                    for v in full_var_list:
                        if '__meta' in v:
                            var_list.append(v)
		else:
		    var_list = full_var_list
                meta_list = list(set(meta_list))
                var_list = list(set(var_list))

    #==============================================================================
    #
    # Workload Distribution
    #
    #==============================================================================

		# Each intercommunicator recieves a list of averages it's responsible for
		# Each mpi task within that intercommunicator gets a portion of the variable list 
     		num_of_avg = len(avg_dict[i])
		min_procs_per_ave = min(4,spec.main_comm.get_size())

		# Override user selection if they picked less than 2 or
		# the variable list is less than the min procs per sub-communicator
		if (min_procs_per_ave < 2 or len(var_list) <= (min_procs_per_ave-1)):
		    min_procs_per_ave = 2

		# If running in paralllel mode, split the communicator and partition the averages
		if (spec.serial == False):
		    size = spec.main_comm.get_size()
		    rank = spec.main_comm.get_rank()

		    # split mpi comm world
                    temp_color = (rank // min_procs_per_ave) % num_of_avg
		    num_of_groups = size/min_procs_per_ave
                    if (temp_color == num_of_groups):
                        temp_color = temp_color - 1
		    groups = []
		    for g in range(0,num_of_groups):
			groups.append(g)
                    #print 'g_rank:',rank,'size:',size,'#of ave:',num_of_avg,'min_procs:',min_procs_per_ave,'temp_color:',temp_color,'#of groups',num_of_groups,'groups:',groups 
		    group = groups[temp_color]
		    inter_comm,multi_comm = spec.main_comm.divide(group)
		    color = inter_comm.get_color()
		    lsize = inter_comm.get_size()
		    lrank = inter_comm.get_rank()

		    #g_master = spec.main_comm.is_manager()
		    l_master = inter_comm.is_manager()
	  
		    #print 'global rank: ',rank,'local rank: ',lrank,'color: ',color,'tempcolor: ',temp_color,'group: ',group,'is local master: ',l_master
                    laverages = []
                    AVE_LIST_TAG = 50
		    # Partion the average task list amoung the inter/split communicators
                    if (l_master):
		        laverages = multi_comm.partition(avg_dict[i],func=partition.EqualStride(),involved=True)
                        for b in range(1,lsize):
                            laverages_send = inter_comm.ration(data=laverages,tag=AVE_LIST_TAG) 
                    else:
                        laverages = inter_comm.ration(tag=AVE_LIST_TAG)
		else: 
		    # Running in serial mode.  Just copy the average list.
		    laverages = avg_dict[i]
		    inter_comm = spec.main_comm
		    lsize = inter_comm.get_size()
		    #g_master = spec.main_comm.is_manager()
		    l_master = inter_comm.is_manager()

		# Partition the variable list between the tasks of each communicator
		if (lsize > 1 and spec.serial == False):
		    lvar_list = inter_comm.partition(var_list,func=partition.EqualStride(),involved=False) 
		    if (l_master):
			lvar_list = var_list
		else:
		    lvar_list = var_list
		#print rank,lvar_list

		#print(rank,'averages :',laverages, ' vars :',lvar_list)
 
    #==============================================================================
    #
    # Create the output directory if it doesn't exist
    #
    #==============================================================================

		if spec.serial or g_master:
		    if not os.path.exists(spec.out_directory):
			os.makedirs(spec.out_directory)
                spec.main_comm.sync() 
    #==============================================================================
    #
    # Main Averaging Loop
    #
    #==============================================================================
		# Files are only split for the first loop.  When the depend averages start, they will operate on files
		# that are already stiched together.
		if (i != 0):
		    spec.split_name = 'null'
		    spec.split = False
		    spec.split_files = 'null'
		# Toggle to incate that extra variables were added to the local file list (only do once per average level
		added_extra_vars = False

		for ave in laverages:
		    for split_name in spec.split_files.split(","): 
			# Split apart the average info to get type of average and year(s) 
			ave_descr = ave.split(':')
			if ('hor.meanyr' in ave_descr[0] or 'hor.meanConcat' in ave_descr[0]):
			    ave_name_split = ave_descr[0].split('_')
			    region_num = ave_name_split[len(ave_name_split)-1]
			    region_name = spec.regions[int(region_num)]
			    # Remove the region number as part of the average name
			    ave_descr[0] = ave_name_split[0]
			else:
			    region_name = 'null'
			    region_num = -99

			# If the average depends on other averages that have to be computed, create a new temporary dictionary
			if '__d' in ave_descr:
			    yr0 = ave_descr[1]
			    if (len(ave_descr) > 2 and '_d' not in ave_descr[2]):
			       yr1 = ave_descr[2]
			    else:
			       yr1 = ave_descr[1]
                            
			    hist_dict = rover.set_slices_and_vars_depend(spec.out_directory, file_pattern, prefix, yr0, yr1,
										ave_t.average_types[ave_descr[0]],ave_descr[0],region_name)
			else:
			    hist_dict = dict(full_hist_dict)   

			# If concat' mean_diff_rms files, for each var, also add the _DIFF and _RMS variables.
			if ('hor.meanConcat' in ave_descr and added_extra_vars==False):
			    new_vars = []
			    for v in lvar_list:
                                if '__meta' not in v:
				    new_vars.append(v+'_DIFF')
				    new_vars.append(v+'_RMS')
			    lvar_list = lvar_list + new_vars
			    added_extra_vars = True

			# Create and define the average file 
			timer.start("Create/Define Netcdf File")
                        if (len(ave_descr)<3 or 'hor.meanyr' in ave_descr):
                            ave_date = string.zfill(ave_descr[1],4)
                            ave_date2 = str(ave_descr[1])
                        else:
                            date1 = string.zfill(ave_descr[1],4)
                            date2 = string.zfill(ave_descr[2],4)
                            ave_date = date1+'-'+date2
                            ave_date2 = str(ave_descr[1])+'-'+str(ave_descr[2])
			outfile_name = climFileIO.get_out_fn(ave_descr[0],prefix,ave_date,ave_t.average_types[ave_descr[0]]['fn'],region_name)
                        if 'zonalavg' in ave_descr:
                            l_collapse_dim = spec.collapse_dim
                        else:
                            l_collapse_dim = ''
			all_files_vars,new_file = climFileIO.define_ave_file(l_master,spec.serial,var_list,lvar_list,meta_list,hist_dict,
									     spec.hist_type,ave_descr,prefix,outfile_name,
									     spec.split,split_name,spec.out_directory,inter_comm,
									     spec.ncformat,ave_t.average_types[ave_descr[0]]['months_to_average'][0],
                                                                             key,spec.clobber,spec.year0,spec.year1,ave_date2,collapse_dim=l_collapse_dim) 
			timer.stop("Create/Define Netcdf File")
		       
			# Start loops to compute averages
			# create a list of years that are needed for this average
			years = []
			if '__d' in ave_descr:
			    if (ave_t.average_types[ave_descr[0]]['depend_type'] == 'month' or '_d' in ave_descr[2]):
				years.append(int(ave_descr[1]))
			    else:
				years = list(range(int(ave_descr[1]),int(ave_descr[2])+1))
			    depend = True
			else: 
			    if (len(ave_descr) == 2):
				years.append(int(ave_descr[1]))
			    else:
				years = list(range(int(ave_descr[1]),int(ave_descr[2])+1))
			    depend = False

                        # Get the first year.  If part of a sig avg, this will be the sig first year, not year of indiv average
                        fyr = years[0]
                        if i+1 in avg_dict.keys():
                            for a in avg_dict[i+1]:
                                if (ave_descr[0]+'_sig') in a:
                                    spl = a.split(':') 
                                    fyr = int(spl[1]) 

			file_dict = []
			open_list = []
			# Open all of the files that this rank will need for this average (for time slice files)
			if ((spec.hist_type == 'slice' or '__d' in ave_descr)  and (spec.serial or not l_master) and len(lvar_list) > 0):
			    file_dict = []
			    open_list = []
			    file_dict,open_list = climFileIO.open_all_files(hist_dict,ave_t.average_types[ave_descr[0]]['months_to_average'],
								    years,lvar_list[0],'null',ave_descr[0],depend,fyr)
			# If concat of file instead of average, piece file together here.  If not, enter averaging loop
			if (('mavg' in ave_descr or 'moc' in ave_descr or 'annall' in ave_descr or 'mons' in ave_descr or
                             '_mean' in ave_descr[0]) and len(lvar_list) > 0):
			    file_dict = []
			    open_list = []
			    if (spec.serial or not l_master):
				# Open files
				file_dict,open_list = climFileIO.open_all_files(hist_dict,ave_t.average_types[ave_descr[0]]['months_to_average'],
								    years,lvar_list[0],'null',ave_descr[0],depend,fyr)
			# Loop through variables and compute the averages
			for orig_var in lvar_list:
			    # Some variable names were suffixed with a meta label indicaticating that the variable exists in all files,
			    # but there isn't a didicated ts file to open.  Pick the first variable off the list and get values from there
			    if ('__meta' in orig_var):
				var = key 
			    else:
				var = orig_var
			    # Open all of the files that this rank will need for this average (for time series files)
			    if ((spec.hist_type == 'series' and '__d' not in ave_descr) and (spec.serial or not l_master)):
				if ('mavg' not in ave_descr or 'moc' not in ave_descr or 'annall' not in ave_descr or 
      				    'mons' not in ave_descr or '_mean' not in ave_descr[0]):
				    file_dict = []
				    open_list = []
				    file_dict,open_list = climFileIO.open_all_files(hist_dict,ave_t.average_types[ave_descr[0]]['months_to_average'],
											years,var,split_name,ave_descr[0],depend,fyr)
			    # We now have open files to pull values from.  Now reset var name
			    if ('__meta' in orig_var):
				parts = orig_var.split('__')
				var = parts[0]
			    # If concat, all of the procs will participate in this call
			    if ('mavg' in ave_descr or 'moc' in ave_descr or 'mocm' in ave_descr or 'hor.meanConcat' in ave_descr 
                                or 'annall' in ave_descr or 'mons' in ave_descr or '_mean' in ave_descr[0] or 'zonalavg' in ave_descr):
                                        if 'zonalavg' in ave_descr:
                                            l_collapse_dim = spec.collapse_dim
                                        else:
                                            l_collapse_dim = ''
					# Concat
					var_avg_results =  climAverager.time_concat(var,years,hist_dict,ave_t.average_types[ave_descr[0]],
								    file_dict,ave_descr[0],inter_comm,all_files_vars,spec.serial,timer,collapse_dim=spec.collapse_dim)
			    # Else (not concat), each slave will compute averages and each master will collect and write
			    else:
				if spec.serial or not l_master:
				    # mean_diff_rsm file
				    if ('hor.meanyr' in ave_descr and '__meta' not in orig_var):
					obs_file = spec.obs_dir+"/"+spec.obs_file
					reg_obs_file = spec.obs_dir+"/"+region_name+spec.reg_obs_file_suffix
					# The mean diff rsm function will send the variables once they are created 
					var_avg_results,var_DIFF_results,var_RMS_results = climAverager.mean_diff_rms(var,region_name,region_num,spec.region_nc_var,
					    spec.region_wgt_var,years,hist_dict,ave_t.average_types[ave_descr[0]],file_dict,obs_file,
					    reg_obs_file,inter_comm,spec.serial,VNAME_TAG,AVE_TAG,spec.vertical_levels)
				    else:
					if ('__metaChar' in orig_var):
					    # Handle special meta
					    var_avg_results =  climAverager.get_metaCharValue(var,years,hist_dict,ave_t.average_types[ave_descr[0]],
						    file_dict,timer)
					else: 
					    # Average
					    if (spec.weighted == True and 'weights' in ave_t.average_types[ave_descr[0]]):
						var_avg_results =  climAverager.weighted_avg_var(var,years,hist_dict,
						      ave_t.average_types[ave_descr[0]],file_dict,ave_descr[0],timer,depend,fyr)
					    else:
						var_avg_results =  climAverager.avg_var(var,years,hist_dict,
						    ave_t.average_types[ave_descr[0]],file_dict,ave_descr[0],timer,depend,fyr)
      
					# Close all open files (for time series files)
					if ((spec.hist_type == 'series' and '__d' not in ave_descr) and (spec.serial or not l_master)):
					    climFileIO.close_all_files(open_list)

					# Pass the average results to master rank for writing
					var_shape = var_avg_results.shape
					var_dtype = var_avg_results.dtype
                                        var_type = type(var_avg_results)
					md_message = {'name':var,'shape':var_shape,'dtype':var_dtype,'average':var_avg_results,'type':var_type}
					if not spec.serial:
					    timer.start("Send Average Time")
					    #inter_comm.collect(data=md_message, tag=AVE_TAG)
                                            inter_comm.collect(data=var, tag=VNAME_TAG)
                                            inter_comm.collect(data=var_avg_results, tag=AVE_TAG)
					    timer.stop("Send Average Time")
	
				if spec.serial or l_master:
				    # If ave_descr is hor.meanyr, there will be three variables to write for each variable.  
				    # Other wise, there will only be 1
				    if ('hor.meanyr' in ave_descr and '__meta' not in orig_var):
					var_cnt = 3
				    else:
					var_cnt = 1
				    for r in range(0,var_cnt):
					if not spec.serial:
					    timer.start("Recv Average Time")
					    #r_rank,results = inter_comm.collect(tag=AVE_TAG)
					    #r_var_avg_results = results['average']
                                            r_rank,var_name = inter_comm.collect(tag=VNAME_TAG)
                                            r_rank,r_var_avg_results = inter_comm.collect(tag=AVE_TAG)
					    #var_name = results['name']
					    timer.start("Recv Average Time") 
					else:
					    var_name = var
					    r_var_avg_results = var_avg_results 
				    
					timer.start("Write Netcdf Averages")
					climFileIO.write_averages(all_files_vars, r_var_avg_results, var_name)
					if ('hor.meanyr' in ave_descr and spec.serial) and '__meta' not in orig_var:
					    climFileIO.write_averages(all_files_vars, var_DIFF_results, var_name+'_DIFF')
					    climFileIO.write_averages(all_files_vars, var_RMS_results, var_name+'_RMS')
					timer.stop("Write Netcdf Averages")

			# Close all open files (for time slice files)
			if (('mavg' in ave_descr or 'moc__d'==ave_descr[0] or 'annall' in ave_descr or 'mons' in ave_descr or
                            '_mean' in ave_descr[0]) and len(lvar_list) > 0):
			    if (spec.serial or not l_master):
				climFileIO.close_all_files(open_list)
			elif ((spec.hist_type == 'slice' or '__d' in ave_descr)and (spec.serial or not l_master) and len(lvar_list) > 0):
			    climFileIO.close_all_files(open_list)  
       
			# Sync the local communicator before closing the averaged netcdf file and moving to the next average          
			inter_comm.sync()

		    # Close the newly created average file
		    if spec.serial or l_master:
			new_file.close()

		    # If needed, stitch spatially split files together.
		    if spec.serial or l_master:
			if (len(spec.split_files.split(",")) > 1):
			    fn1 = spec.out_directory+'/nh_'+outfile_name
			    fn2 = spec.out_directory+'/sh_'+outfile_name
			    out_fn = spec.out_directory+'/'+outfile_name
			    dim_info = spec.split_orig_size.split(",")
			    dim1 = dim_info[0].split("=")
			    dim2 = dim_info[1].split("=")
			    regionOpts.combine_regions(fn1, fn2,  out_fn, dim1[0], int(dim1[1]), dim2[0], int(dim2[1]), "nj", spec.clobber) 
		
		if not spec.serial:
		    # Free the inter-communicators
		    #intercomm.Free()
		    # Sync all mpi tasks / All averages should have been computed at this point 
		    spec.main_comm.sync()

    #==============================================================================
    #
    # Collect and print timing information
    #
    #==============================================================================

        timer.stop("Total Time")
	my_times = spec.main_comm.allreduce(timer.get_all_times(),'max')

	if g_master:
	    print("==============================================")
            print "COMPLETED SUCCESSFULLY"
	    print my_times
	    print("==============================================") 
