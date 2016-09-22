

#########################################################################################################
#
# Create specifier factory function
#
#########################################################################################################

def create_specifier(**kwargs):

  '''
  Factory function for Specifier class objects

  @param kwargs Optional agruments to be passed to the newly created Specifier constructor.

  @return An instantiation of the Specifier class

  '''

  return pyAveragerSpecifier(**kwargs)


#########################################################################################################
#
# Specifier Base Class
#
#########################################################################################################

class Specifier(object):
    '''
    This is the base class for the pyAverager input specification.
    '''

    def __init__(self):
        '''
        Constructor
        '''

        ## String specifier type
        self.specifier_type = 'undetermined'



#########################################################################################################
#
# Input Specification Class for the pyAverager
#
#########################################################################################################

class pyAveragerSpecifier(Specifier):
  '''
  This class is a container for the input data required by the pyAverager

  '''

  def __init__(self,in_directory,
	       out_directory,
	       prefix,
               suffix,
    	       file_pattern='null',
               date_pattern='null',
               m_id = ['-999'],
	       hist_type='slice',
	       avg_list=[],
  	       weighted=False,
               split=False,
               split_files='null',
	       split_orig_size='null',
	       ncformat='netcdf4c',
	       varlist=[],
	       serial=False,
               mean_diff_rms_obs_dir='null',
               region_nc_var='null',
               regions={},
	       region_wgt_var='null',
               obs_file='null',
               reg_obs_file_suffix='null',
               obs_dir='null',
               main_comm=None,
               clobber=False,
	       ice_obs_file='null',
               reg_file = 'null',
               ncl_location='null',
               year0=-99,
               year1=-99,
               collapse_dim=''):
    '''
    Initializes the internal data with optional arguments

    @param in_directory     Where the input directory resides (needs full path).

    @param out_directory    Where the output will be produced (needs full path).

    @param prefix           String specifying the full file name before the date string.

    @param suffix           String specifying the suffix of the file names

    @param file_pattern     File pattern used put the prefix, date, and suffix together for input files.

    @param date_pattern     The pattern used to decipher the date string within the file name.  

    @param m_id             Array of member identifiers.  All averages will be done on each member individually and then across all members.

    @param hist_type	    Type of file ('slice' or 'series').  Default is 'slice'.

    @param avg_list	    List of averages that need to be computed.  Elements should contain aveType:year0:year1.
	                    year2 is only required for multi year averaging.

    @param weighted         Boolean variable to selected if weights will be applied to the averaging.  
			    True = weights will be applied.  Default is False.

    @param split            Boolean variable.  True = the file is split spatially and the final average needs to be pieced together.
			    (ie. CICE times series files) Default is False. 

    @param split_files	    The strings indicating the naming difference between split files.  Expects a string with elements separated by a comma.
         	            Defualt is 'null'.  

    @param split_orig_size  A string listing the lat and lon values of the origianl grid size.  Needed in case some of the grid has been deleted.
		            (example: 'lon=288,lat=192').  Default is 'null'.

    @param ncformat	    Format to output the averaged file(s) in.  Default is 'netcdf4c'.  Other options: 'netcdf','netcdf4','netcdf4c'

    @param varlist	    Optional variables list, if not averaging all variables
 
    @param serial	    Boolean to run in serial mode.  True=serial (without MPI) False=run in parallel(with MPI) False requires mpi4py to be installed.
                            Default is False.

    @param regions          Dictionary that contains regions to average over.  Fromat is 'string region name: int region value'.  Default is an empty dictionary. 

    @param region_nc_var    String that identifies the netcdf variable that contains the region mask used by a regional average.

    @param region_wgt_var   String that identifies the netcdf variable that contains the weights.

    @param obs_file         Observational file used for the creation of the mean_diff_rms file. This file must contain all of the variables within the
                            variable list (or if a variable list is not specified, must contain all hist file variables).  Dimension must be nlon and nlat. 

    @param reg_obs_file_suffix The suffix of the regional, weighted averages of the 'obs_file'.  Used for the creation of the mean_diff_rms file.  

    @param obs_dir          Full path to the observational files used for the mean_diff_rms file.

    @param main_comm        A simplecomm to be used by the PyAverager.  If not specified, one will be created by this specifier. Default None.

    @param clobber          Remove netcdf output file(s) if they exist.  Default False - will exit if an output file of the same name exists. 

    @param ice_obs_file     Full path to the observational file used to create the cice model pre_proc file

    @param reg_file         Full path to the regional file used to create the cice model pre_proc file

    @param ncl_location     Location of where the ncl scripts reside

    @param year0            The first year - only used to create the cice pre_proc file.  

    @param year1            The last year - only used to create the cice pre_proc file. 

    @param collapse_dims    Used to collapse/average over one dim.
    '''

    # Where the input is located
    self.in_directory = in_directory

    # Where the output should be produced
    self.out_directory = out_directory

    # Full file name up to the date string
    self.prefix = prefix

    # The suffix of the data files
    self.suffix = suffix

    # Type of file
    self.hist_type = hist_type

    # List of averages to compute
    self.avg_list = avg_list

    # Should weights be applied?
    self.weighted = weighted

    # Are files split spatially?
    self.split = split

    # Split file name indicators
    self.split_files = split_files

    # The original grid size of the split files
    self.split_orig_size = split_orig_size

    # The netcdf output format 
    self.ncformat = ncformat

    # Varlist to average (if not all variables)
    self.varlist = varlist

    # Run in serial mode?  If True, will be ran without MPI
    self.serial = serial

    # Directory where to find the regional obds files for the mean_diff_rms climo file
    self.mean_diff_rms_obs_dir = mean_diff_rms_obs_dir

    # Regions to average over
    self.regions = regions

    # Netcdf variable name that contains a region mask
    self.region_nc_var = region_nc_var

    # Netcdf variable name that contains the weights
    self.region_wgt_var = region_wgt_var

    # String that indicates the suffix of the regional obs files used for the mean_diff_rms file
    self.reg_obs_file_suffix = reg_obs_file_suffix

    # String that indicates the name of the observational file
    self.obs_file = obs_file

    # String indicating the path to the observational files used for the mean_diff_rms file
    self.obs_dir = obs_dir

    # File pattern used to piece together a full file name
    if (file_pattern == 'null'):
        if (hist_type == 'slice'):
            self.file_pattern = ['$prefix','.','$date_pattern','.','$suffix']
        if (hist_type == 'series'):
            if split:
                self.file_pattern = ['$prefix','.','$var','_','$hem','.','$date_pattern','.','$suffix']
            else:
                self.file_pattern = ['$prefix','.','$var','.','$date_pattern','.','$suffix']
    else: 
        self.file_pattern = file_pattern

    # The date pattern to decipher the date within the file name
    self.date_pattern = date_pattern

    self.m_id = m_id

    # Get first and last years used in the averaging by parsing the avg_list
    dates = []
    for avg in avg_list:
      avg_descr = avg.split(':')
      for yr in avg_descr[1:]:
        dates.append(int(yr))
    if (year0 == -99 and year1 == -99):
        self.year0 = int(min(dates))
        self.year1 = int(max(dates)) 
    else:
        self.year0 = int(year0)
        self.year1 = int(year1)     

    # Initialize a simple_comm object if one was not passed in by the user
    if (main_comm is None):
        from asaptools import simplecomm
        self.main_comm = simplecomm.create_comm(serial=serial)
    else:
        self.main_comm = main_comm

    # True/False, rm average file(s) is it has already been created
    self.clobber = clobber

    # File that contains the weight/area information
    self.ice_obs_file = ice_obs_file

    # File that exists or will be created that contains a region mask for ice
    self.reg_file = reg_file

    # Location of the ncl script that will be used to create reg_file if it doesn't exist
    self.ncl_location = ncl_location

    # Used to collapse/average over one dim.
    self.collapse_dim = collapse_dim
