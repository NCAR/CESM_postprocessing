
#=========================================================================
# createClimFiles - create the climatology files by calling the pyAverager
#=========================================================================
def createClimFiles(start_year, stop_year, in_dir, htype, tavgdir, case, inVarList, scomm):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       start_year (integer) - starting year for diagnostics
       stop_year (integer) - ending year for diagnositcs
       in_dir (string) - input directory with either history time slice or variable time series files
       htype (string) - 'series' or 'slice' depending on input history file type
       tavgdir (string) - output directory for averages
       case (string) - case name
       inVarList (list) - if empty, then create climatology files for all vars, RHO, SALT and TEMP
       scomm (object) - simple communicator object
    """
    # create the list of averages to be computed
    avgFileBaseName = '{0}/{1}.pop.h'.format(tavgdir,case)
    case_prefix = '{0}.pop.h'.format(case)
    averageList = []

    # create the list of averages to be computed by the pyAverager
    if scomm.is_manager():
        if DEBUG:
            print('DEBUG... calling buildOcnAvgList')
        averageList = buildOcnAvgList(start_year, stop_year, avgFileBaseName, tavgdir)
    scomm.sync()

    # need to bcast the averageList
    averageList = scomm.partition(averageList, func=partition.Duplicate(), involved=True)
    if scomm.is_manager():
        if DEBUG:
            print('DEBUG... averageList after partition = {0}'.format(averageList))

    # if the averageList is empty, then all the climatology files exist with all variables
    if len(averageList) > 0:
        # call the pyAverager with the inVarList
        if scomm.is_manager():
            if DEBUG:
                print('DEBUG... calling callPyAverager')
        callPyAverager(start_year, stop_year, in_dir, htype, tavgdir, case_prefix, averageList, inVarList, scomm)
        scomm.sync()
    else:
        if scomm.is_manager():
            if DEBUG:
                print('DEBUG... averageList is null')


#========================================================================
# callPyAverager - create the climatology files by calling the pyAverager
#========================================================================
def callPyAverager(start_year, stop_year, in_dir, htype, tavgdir, case_prefix, averageList, varList, scomm):
    """setup the pyAverager specifier class with specifications to create
       the climatology files in parallel.

       Arguments:
       start_year (integer) - starting year for diagnostics
       stop_year (integer) - ending year for diagnositcs
       in_dir (string) - input directory with either history time slice or variable time series files
       htype (string) - 'series' or 'slice' depending on input history file type
       tavgdir (string) - output directory for climatology files
       case_prefix (string) - input filename prefix
       averageList (list) - list of averages to be created
       varList (list) - list of variables. Note: an empty list implies all variables.
       scomm (object) - simple communicator object
    """
    mean_diff_rms_obs_dir = '/glade/p/work/mickelso/PyAvg-OMWG-obs/obs/'
    region_nc_var = 'REGION_MASK'
    regions={1:'Sou',2:'Pac',3:'Ind',6:'Atl',8:'Lab',9:'Gin',10:'Arc',11:'Hud',0:'Glo'}
    region_wgt_var = 'TAREA'
    obs_dir = '/glade/p/work/mickelso/PyAvg-OMWG-obs/obs/'
    obs_file = 'obs.nc'
    reg_obs_file_suffix = '_hor_mean_obs.nc'

    wght = False
    ncfrmt = 'netcdf'
    serial = False
    clobber = True
    date_pattern = 'yyyymm-yyyymm'
    suffix = 'nc'

    scomm.sync()

    if scomm.is_manager() and DEBUG:
        print('DEBUG... calling specification.create_specifier with following args')
        print('DEBUG...... in_directory = {0}'.format(in_dir))
        print('DEBUG...... out_directory = {0}'.format(tavgdir))
        print('DEBUG...... prefix = {0}'.format(case_prefix))
        print('DEBUG...... suffix = {0}'.format(suffix))
        print('DEBUG...... date_pattern = {0}'.format(date_pattern))
        print('DEBUG...... hist_type = {0}'.format(htype))
        print('DEBUG...... avg_list = {0}'.format(averageList))
        print('DEBUG...... weighted = {0}'.format(wght))
        print('DEBUG...... ncformat = {0}'.format(ncfrmt))
        print('DEBUG...... varlist = {0}'.format(varList))
        print('DEBUG...... serial = {0}'.format(serial))
        print('DEBUG...... clobber = {0}'.format(clobber))
        print('DEBUG...... mean_diff_rms_obs_dir = {0}'.format(mean_diff_rms_obs_dir))
        print('DEBUG...... region_nc_var = {0}'.format(region_nc_var))
        print('DEBUG...... regions = {0}'.format(regions))
        print('DEBUG...... region_wgt_var = {0}'.format(region_wgt_var))
        print('DEBUG...... obs_dir = {0}'.format(obs_dir))
        print('DEBUG...... obs_file = {0}'.format(obs_file))
        print('DEBUG...... reg_obs_file_suffix = {0}'.format(reg_obs_file_suffix))
        print('DEBUG...... main_comm = {0}'.format(scomm))
        print('DEBUG...... scomm = {0}'.format(scomm.__dict__))

    scomm.sync()

    try: 
        pyAveSpecifier = specification.create_specifier(
            in_directory = in_dir,
            out_directory = tavgdir,
            prefix = case_prefix,
            suffix=suffix,
            date_pattern=date_pattern,
            hist_type = htype,
            avg_list = averageList,
            weighted = wght,
            ncformat = ncfrmt,
            varlist = varList,
            serial = serial,
            clobber = clobber,
            mean_diff_rms_obs_dir = mean_diff_rms_obs_dir,
            region_nc_var = region_nc_var,
            regions = regions,
            region_wgt_var = region_wgt_var,
            obs_dir = obs_dir,
            obs_file = obs_file,
            reg_obs_file_suffix = reg_obs_file_suffix,
            main_comm = scomm)
    except Exception as error:
        print(str(error))
        traceback.print_exc()
        sys.exit(1)

    scomm.sync()

    # call the pyAverager
    if scomm.is_manager() and DEBUG:
        print("DEBUG...  before run_pyAverager")

    try:
        PyAverager.run_pyAverager(pyAveSpecifier)
        scomm.sync()

    except Exception as error:
        print('DEBUG... exception on rank = {0}:'.format(scomm.get_rank()))
        print(str(error))
        traceback.print_exc()
        sys.exit(1)
