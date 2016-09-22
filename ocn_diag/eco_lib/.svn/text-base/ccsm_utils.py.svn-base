# No shebang

"""
Collection of utilities for processing CCSM/POP model output.
Created by Ivan Lima on Wed Aug 25 10:01:03 EDT 2004

"""

import numpy as N
import numpy.ma as MA
import os, Nio
import numpy.linalg as LA

POPDIAGPY2 = os.environ['POPDIAG']
if POPDIAGPY2 == 'TRUE':
    mappdir = os.environ['ECODATADIR']+'/mapping'
#else:
#    datadir = '/fiji/home/ivan/data'

# days per month
dpm = N.array([31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31.])

month_name = {
    1  : 'January' , 2  : 'February' , 3  : 'March'     ,
    4  : 'April'   , 5  : 'May'      , 6  : 'June'      ,
    7  : 'July'    , 8  : 'August'   , 9  : 'September' ,
    10 : 'October' , 11 : 'November' , 12 : 'December'
    }

# seconds per day
spd = 60. * 60. * 24.

deg2rad = N.pi/180.

# model region indices
region_ind = {
    1   : 'Southern Ocean'    ,
    2   : 'Pacific Ocean'     ,
    3   : 'Indian Ocean'      ,
    -4  : 'Persian Gulf'      ,
    -5  : 'Red Sea'           ,
    6   : 'Atlantic Ocean'    ,
    -7  : 'Mediterranean Sea' ,
    8   : 'Labrador Sea'      ,
    9   : 'GIN Sea'           ,
    10  : 'Arctic Ocean'      ,
    11  : 'Hudson Bay'        ,
    -12 : 'Baltic Sea'        ,
    -13 : 'Black Sea'         ,
    -14 : 'Caspian Sea'
   }

# model region indices for new/alternative region mask
region_ind_new = {
    1 : 'Pacific Ocean'  ,
    2 : 'Indian Ocean'   ,
    3 : 'Atlantic Ocean' ,
   }

def read_BEC_region_mask(grid):
    """
    Read BEC sub-regions mask for given grid (gx3v5 gx1v6).
    Returns:
        region_mask  : mask
        nreg         : number of regions
        region_lname : region long name
        region_sname : region short name
    """
    region_mask_file = '/home/ivan/Python/data/BEC_REGION_MASK_%s.nc'%grid
    fpreg            = Nio.open_file(region_mask_file, 'r')
    nreg             = fpreg.dimensions['nreg']
    region_mask      = fpreg.variables['REGION_MASK'][:]

    # get region long names
    region_lname = [''.join(fpreg.variables['REGION_lname'][n,:])
                for n in range(nreg)]
    # get region short names
    region_sname = [''.join(fpreg.variables['REGION_sname'][n,:])
                for n in range(nreg)]

    fpreg.close()
    return region_mask, nreg, region_lname, region_sname

def read_BEC_region_mask_popdiag(grid):
    """
    Read BEC sub-regions mask for given grid (gx3v5 gx1v6).
    Returns:
        region_mask  : mask
        nreg         : number of regions
        region_lname : region long name
        region_sname : region short name
    """
#   region_mask_file = '/CESM/bgcwg/obgc_diag/mapping/model_grid/BEC_REGION_MASK_%s.nc'%grid
    region_mask_file = '/glade/p/cesm/bgcwg/obgc_diag/mapping/model_grid/BEC_REGION_MASK_%s.nc'%grid
    fpreg            = Nio.open_file(region_mask_file, 'r')
    nreg             = fpreg.dimensions['nreg']
    region_mask      = fpreg.variables['REGION_MASK'][:]

    # get region long names
    region_lname = [''.join(fpreg.variables['REGION_lname'][n,:])
                for n in range(nreg)]
    # get region short names
    region_sname = [''.join(fpreg.variables['REGION_sname'][n,:])
                for n in range(nreg)]

    fpreg.close()
    return region_mask, nreg, region_lname, region_sname

def read_new_region_mask():
    """
    Read alternative CCSM/POP region mask with only the Pacific, Indian and
    Atlantic oceans.
    Returns:
        region_mask  : mask
        nreg         : number of regions
        region_lname : region long name
        region_sname : region short name
    """
    nreg             = len(region_ind_new)
#   region_mask_file = '/home/ivan/Python/new_REGION_MASK_gx3v5.nc'
    region_mask_file = '/glade/home/emunoz/Python/mapping/model_grid/new_REGION_MASK_gx3v5.nc'
    fpreg            = Nio.open_file(region_mask_file, 'r')
    region_mask      = fpreg.variables['REGION_MASK'][:]
    fpreg.close()
    region_lname = (N.take(region_ind_new.values(),
        N.argsort(N.abs(region_ind_new.keys()))).tolist())
    region_sname = [region[:3].lower() for region in region_lname]

    return region_mask, nreg, region_lname, region_sname

def read_region_mask(grid):
    """
    Read standard CCSM/POP region mask.
    Returns:
        region_mask  : mask
        nreg         : number of regions
        region_lname : region long name
        region_sname : region short name
    """
    nreg             = len(region_ind)
    region_mask_file = '/home/ivan/Python/data/%s.nc'%grid
    fpreg            = Nio.open_file(region_mask_file, 'r')
    region_mask      = fpreg.variables['REGION_MASK'][:]
    fpreg.close()
    region_lname = (N.take(region_ind.values(),
        N.argsort(N.abs(region_ind.keys()))).tolist())
    region_sname = [region[:3].lower() for region in region_lname]

    return region_mask, nreg, region_lname, region_sname

def read_region_mask_popdiag(grid):
    """
    Read standard CCSM/POP region mask.
    Returns:
        region_mask  : mask
        nreg         : number of regions
        region_lname : region long name
        region_sname : region short name
    """
    nreg             = len(region_ind)
#   region_mask_file = '/CESM/bgcwg/obgc_diag/mapping/model_grid/%s.nc'%grid
    region_mask_file = '/glade/p/cesm/bgcwg/obgc_diag/mapping/model_grid/%s.nc'%grid
    fpreg            = Nio.open_file(region_mask_file, 'r')
    region_mask      = fpreg.variables['REGION_MASK'][:]
    fpreg.close()
    region_lname = (N.take(region_ind.values(),
        N.argsort(N.abs(region_ind.keys()))).tolist())
    region_sname = [region[:3].lower() for region in region_lname]

    return region_mask, nreg, region_lname, region_sname

def gc_dist(ref_lon, ref_lat, tlon, tlat):
    """
    Compute great circle distance in degrees between the
    point at ref_lon, ref_lat and point(s) at tlon, tlat.

    ref_lon, ref_lat are scalars and tlon, tlat can be scalars or arrays

    """
    dlon = (tlon - ref_lon) * deg2rad
    dlat = (tlat - ref_lat) * deg2rad
    a = ((N.sin(dlat/2))**2 + N.cos(ref_lat*deg2rad) *
        N.cos(tlat*deg2rad) * (N.sin(dlon/2))**2)
    a[a>1] = 1. # avoid roundoff errors
    dist = 2. * N.arcsin(N.sqrt(a)) / deg2rad
    return dist

def find_closest_pt(ref_lon, ref_lat, tlon, tlat):
    """
    Find the [i,j] indices of the closest grid point to a
    given location.

    Input:
        ref_lon = longitude of location
        ref_lat = latitude of location
        tlon    = model longitude grid (numpy array)
        tlat    = model latitude grid  (numpy array)

    Output:
        ii = i index
        jj = j index

    """

    # compute great circle distance from location to model grid points
    dist = gc_dist(ref_lon, ref_lat, tlon, tlat)

    # find j index of closest grid point
    work = N.take(dist,N.argmin(dist,0),0).diagonal()
    jj   = N.argsort(work)[0]

    # find i index of closest grid point
    work = N.take(dist,N.argmin(dist,1),1).diagonal()
    ii   = N.argsort(work)[0]

    return ii, jj

def find_stn_idx(ref_lon, ref_lat, tlon, tlat):
    """
    Finds the [i,j] indices of the 4 model grid points around
    a given location.

    Input:
        ref_lon = longitude of location
        ref_lat = latitude of location
        tlon    = model longitude grid (numpy array)
        tlat    = model latitude grid  (numpy array)

    Output:
        Ilist = list of i indices
        Jlist = list of j indices
    """

    # compute great circle distance from location to model grid points
    dist =  gc_dist(ref_lon, ref_lat, tlon, tlat)

    # find the indices of the two closest grid points with distinct longitudes
    work  = N.take(dist,N.argmin(dist,0),0).diagonal()
    Jlist = N.argsort(work)[:2]
    del work

    # find the indices of the two closest grid points with distinct latitudes
    work  = N.take(dist,N.argmin(dist,1),1).diagonal()
    Ilist = N.argsort(work)[:2]
    del work

    return Ilist, Jlist

def find_stn(ref_lon, ref_lat, tlon, tlat):
    """
    Finds the logitude and latitude of the 4 model grid points
    around a given location.

    Input:
        ref_lon = longitude of location
        ref_lat = latitude of location
        tlon    = model longitude grid (numpy array)
        tlat    = model latitude grid  (numpy array)

    Output:
        lonlist = list of latitudes
        latlist = list of longitudes
    """

    # find the indices of the 4 model grid points around the location
    Ilist, Jlist = find_stn_idx(ref_lon, ref_lat, tlon, tlat)

    # get the 4 model grid points longitudes and latitudes
    lonlist = []
    latlist = []
    for i in Ilist:
        for j in Jlist:
            lonlist.append(tlon[i,j])
            latlist.append(tlat[i,j])

    # convert Python lists to numpy arrays
    lonlist = N.array(lonlist)
    latlist = N.array(latlist)

    return lonlist, latlist

def extract_loc(ref_lon, ref_lat, tlon, tlat, var):
    """
    Extract CCSM/POP model output for a given location (lat, lon).
    It finds the 4 model grid points around the location and computes
    their weighted average (weights = inverse of the distance). If a
    location is next to land, the function returns the weighted
    average of the closest grid points that are not on land.

    Input:
        ref_lon = longitude of position to be extracted (scalar)
        ref_lat = latitude of position to be extracted  (scalar)
        tlon    = model longitude grid (numpy array)
        tlat    = model latitude grid  (numpy array)
        var     = variable to be extracted (Masked 2-D or 3-D array)

    Output:
        wavg    = weighted average (scalar or 1-D array)
    """

    if var.ndim == 3: # 3D variable
        zmax, imax, jmax = var.shape
        threeD = True
    elif var.ndim == 2: # 2D variable
        imax, jmax = var.shape
        threeD = False
    else:
        print 'extract_loc: check variable dimensions'
        return

    # find the indices of the 4 model grid points around the location
    Ilist, Jlist = find_stn_idx(ref_lon, ref_lat, tlon, tlat)

    # compute great circle distance from location to model grid points
    dist =  gc_dist(ref_lon, ref_lat, tlon, tlat)
    dist[dist==0] = 1.e-15 # avoid division by zero

    # arrays to store weights and data to be averaged
    if threeD: # 3D variable
        wghts  = MA.zeros((zmax,len(Ilist)*len(Jlist)),float)
        data   = MA.zeros((zmax,len(Ilist)*len(Jlist)),float)
        if MA.isMA(var): # mask weights
            dist_m = MA.array(N.resize(dist,var.shape),mask=var.mask)
        else:
            dist_m = N.array(N.resize(dist,var.shape))
    else:      # 2D variable
        wghts  = MA.zeros((len(Ilist)*len(Jlist)),float)
        data   = MA.zeros((len(Ilist)*len(Jlist)),float)
        if MA.isMA(var):
            dist_m = MA.array(dist,mask=var.mask) # mask weights
        else:
            dist_m = N.array(dist)

    # get the 4 model grid points and compute weights
    n = 0
    for i in Ilist:
        for j in Jlist:
            wghts[...,n] = 1./dist_m[...,i,j]
            data[...,n]  = var[...,i,j]
            n += 1

    # compute weighted average
    wavg = MA.average(data,axis=-1,weights=wghts)
    return wavg

def extract_loc_vec(ref_lon, ref_lat, tlon, tlat, indata):
    """
    Vectorized version of extract_loc. Extracts full time series
    simultaneously. Much faster that original version above.

    Inputs:
        ref_lon : longitude of point to be extracted
        ref_lat : latitude of point to be extracted
        tlon    : grid longitudes
        tlat    : grid latitudes
        indata  : array/field to extract point from

    Output:
        wavg : weighted average of the 4 model grid points around position
    """

    # find the indices of the 4 model grid points around the location
    Ilist, Jlist = find_stn_idx(ref_lon, ref_lat, tlon, tlat)

    # compute great circle distance from location to model grid points
    dist =  gc_dist(ref_lon, ref_lat, tlon, tlat)
    dist[dist==0] = 1.e-15 # avoid division by zero

    ibeg, iend = Ilist.min(), Ilist.max()
    jbeg, jend = Jlist.min(), Jlist.max()
    work = indata[...,ibeg:iend+1,jbeg:jend+1]
    dist = dist[...,ibeg:iend+1,jbeg:jend+1]
    wghts = 1./N.resize(dist,work.shape)
    wavg = MA.average(work.reshape(work.shape[:-2]+(-1,)),
            weights=wghts.reshape(work.shape[:-2]+(-1,)),axis=-1)

    return wavg

def pop_remap(x, gridsrc, griddst, method, areatype, fillvalue):
    """
    Remap from one grid to another. Uses remap files produced by SCRIP.
    Mapping is done by wrapped Fortran code so it's fast.

    Input:
        x        = 2-D array to be remaped
        gridsrc  = source grid
        griddst  = destination grid
        method   = interpolation method
        areatype = normalization option

    Output:
        xout     = remaped array
    """
    import remap # Fortran subroutine

    # create name and path of remap file from user input
    dir = '/home/ivan/Tools/scrip/mapping/scrip1.3/'
    if (len(areatype)==0):
        remap_file = (os.path.join(dir, 'map_' + gridsrc + '_to_'
            + griddst + '_' + method + '.nc'))
    else:
        remap_file = os.path.join(dir, 'map_' + gridsrc + '_to_'
            + griddst + '_' + method + '_' + areatype + '.nc')

    # read remap file
    fpin = Nio.open_file(remap_file,'r')
    src_grid_size = fpin.dimensions['src_grid_size']
    dst_grid_size = fpin.dimensions['dst_grid_size']
    num_wgts      = fpin.dimensions['num_wgts']
    num_links     = fpin.dimensions['num_links']
    dst_address   = fpin.variables['dst_address'][:]
    src_address   = fpin.variables['src_address'][:]
    remap_matrix  = fpin.variables['remap_matrix'][:]
    fpin.close()

    #nlink, nw = remap_matrix.shape

    xin  = N.ravel(x)
    xout = N.ones((dst_grid_size),N.float)
    xout.fill(fillvalue)

    if (len(xin)!=src_grid_size):
        print 'WARNING: input grid size does not match'

    # Fortran is column major so transpose input array
    remap_matrix = N.transpose(remap_matrix)
    nw, nlink    = remap_matrix.shape

    # call wrapped Fortran subroutine
    xout = (remap.dpopremap(remap_matrix,dst_address,src_address,xin,
        dst_grid_size,nlink,nw,len(xin),fillvalue))

    return xout

def pop_remap_popdiag(x, gridsrc, griddst, method, areatype, fillvalue):
    """
    Remap from one grid to another. Uses remap files produced by SCRIP.
    Mapping is done by wrapped Fortran code so it's fast.

    Input:
        x        = 2-D array to be remaped
        gridsrc  = source grid
        griddst  = destination grid
        method   = interpolation method
        areatype = normalization option

    Output:
        xout     = remaped array
    """
    import remap # Fortran subroutine

    # create name and path of remap file from user input
#   dir = '/CESM/bgcwg/obgc_diag/mapping/ncremaps/'
    dir = '/glade/p/cesm/bgcwg/obgc_diag/mapping/ncremaps/'
    if (len(areatype)==0):
        remap_file = (os.path.join(dir, 'map_' + gridsrc + '_to_'
            + griddst + '_' + method + '.nc'))
    else:
        remap_file = os.path.join(dir, 'map_' + gridsrc + '_to_'
            + griddst + '_' + method + '_' + areatype + '.nc')

    # read remap file
    fpin = Nio.open_file(remap_file,'r')
    src_grid_size = fpin.dimensions['src_grid_size']
    dst_grid_size = fpin.dimensions['dst_grid_size']
    num_wgts      = fpin.dimensions['num_wgts']
    num_links     = fpin.dimensions['num_links']
    dst_address   = fpin.variables['dst_address'][:]
    src_address   = fpin.variables['src_address'][:]
    remap_matrix  = fpin.variables['remap_matrix'][:]
    fpin.close()

    #nlink, nw = remap_matrix.shape

    xin  = N.ravel(x)
    xout = N.ones((dst_grid_size),N.float)
    xout.fill(fillvalue)

    if (len(xin)!=src_grid_size):
        print 'WARNING: input grid size does not match'

    # Fortran is column major so transpose input array
    remap_matrix = N.transpose(remap_matrix)
    nw, nlink    = remap_matrix.shape

    # call wrapped Fortran subroutine
    xout = (remap.dpopremap(remap_matrix,dst_address,src_address,xin,
        dst_grid_size,nlink,nw,len(xin),fillvalue))

    return xout

def unfold_grid(var):
    """
    Unfolds the POP grid moving the Gulf of Mexico to the right place.

    """
    if (len(var.shape)==2): # 2-D variable
        work = N.concatenate((N.zeros((var.shape[0],24),float),var),1)
        work[39:68,0:24] = work[39:68,var.shape[1]:]
        work[39:68,var.shape[1]:] = 0.0
    elif (len(var.shape)==3): # 3-D variable
        work = (N.concatenate((N.zeros((var.shape[0],var.shape[1],24),float),
                var),2))
        work[:,39:68,0:24] = work[:,39:68,var.shape[2]:]
        work[:,39:68,var.shape[2]:] = 0.0

    return work

#------------------------------------------------------------------------------
# IO functions

def get_file_year(filepath):
    """
    Get year string from file name
    Output: year, month
    """
    filename = os.path.split(filepath)[-1]
    date     = filename.split('.')[-2]
    year     = int(date.split('-')[0])
    month    = int(date.split('-')[1])
    return year, month

def create_file_list(case):
    """
    Create a list of model output files for given case.

    Output: list of file names
    """
    for server in ['bonaire','barbados','caiapo']:
        for basedir in ['data0/ivan/archive','data1/ivan/archive',
                        'data2/ivan/archive','data3/ivan/archive',
                        '/bonaire/data2/data/SODA-POP','data0',
                        '/barbados/data3/CCSM3-BGC']:
            if 'SODA-POP' in basedir:
                path = os.path.join('/',server,basedir,case)
            elif 'CCSM3-BGC' in basedir:
                path = os.path.join('/',server,basedir,case,'ocn/hist')
            else:
                path = os.path.join('/',server,basedir,case,'ocn2')

            if os.path.isdir(path):
 		indir    = path
 		allfiles = os.listdir(indir)
            else:
                continue

    filelist = [os.path.join(indir,file) for file in allfiles
                 if file.endswith('.nc')]
    filelist.sort()
    return filelist

def create_file_list_popdiag(case,workdir):
    """
    Create a list of model output files for given case.

    Output: list of file names
    """
    indir = os.path.join('/',workdir)
    allfiles = os.listdir(indir)

    suffix = ('-01.nc','-02.nc','-03.nc','-04.nc','-05.nc','-06.nc', \
              '-07.nc','-08.nc','-09.nc','-10.nc','-11.nc','-12.nc')

    filelist = [os.path.join(indir,file) for file in allfiles
                if file.startswith(case) and file.endswith(suffix)]

    filelist.sort()
    return filelist

def create_file_list_period(case,mod_year0,mod_year1,month0=1,month1=12):
    """
    Create a list of model output files for time period from mon0/year0
    to mon1/year1 for given case. Default is 01/year0 to 12/year1. Uses
    model years and assumes monthly output files.

    Output: list of file names
    """
    filelist = create_file_list(case)
    dates = [get_file_year(file) for file in filelist]
    ind_beg = dates.index((mod_year0,month0)) # index of start of period
    ind_end = dates.index((mod_year1,month1)) # index of end   of period

    filelist = filelist[ind_beg:ind_end+1]
    return filelist

def read_model_coord_var(case,varname):
    """
    Read coordinate variables (not time varying) from a given model case.

    Output: array
    """
    filelist = create_file_list(case)
    fpin = Nio.open_file(filelist[0],'r')
    data = fpin.variables[varname][:]
    fpin.close()
    return data

def read_model_var_period_fast(case,varlist,year0,year1,month0=1,month1=12,
    fulldepth=True,zlev=0):
    """
    Read 2-D or 3-D variable from given case for time period
    from mon0/year0 to mon1/year1. If variable is 3-D it reads
    full depth by default. Set fulldepth=False and zlev to
    desired z level index To read values at given depth.

    Test using list comprehensions.

    Output: arrays time and dictionary containing arrays.
    """
    print ('reading case %-24s (%d/%.2d-%d/%.2d)'%
        (case,year0,month0,year1,month1))
    #print varlist

    filelist = create_file_list_period(case,year0,year1,month0,month1)
    days = N.array([Nio.open_file(file,'r').variables['time'][:]
        for file in filelist])
    vardict  = {} # container for variables
    for var in varlist:
        print var
        fpin = Nio.open_file(filelist[0],'r')
        if fpin.variables[var][0,...].ndim == 2: # 2-D field
            vardict[var] = MA.array([Nio.open_file(file,'r').variables[var]
                [0,...] for file in filelist])
        elif fpin.variables[var][0,...].ndim == 3: # 3-D field
            if fulldepth: # read full depth
                vardict[var] = MA.array([Nio.open_file(file,'r').variables[var]
                    [0,...] for file in filelist])
            else:         # read level zlev
                vardict[var] = MA.array([Nio.open_file(file,'r').variables[var]
                    [0,zlev,...] for file in filelist])

    return days, vardict

def read_model_var_period(case,varlist,year0,year1,month0=1,month1=12,
    fulldepth=True,zlev=0):
    """
    Read 2-D or 3-D variable from given case for time period
    from mon0/year0 to mon1/year1. If variable is 3-D it reads
    full depth by default. Set fulldepth=False and zlev to
    desired z level index To read values at given depth.

    Output: arrays time and dictionary containing arrays.
    """
    print ('reading case %-24s (%d/%.2d-%d/%.2d)'%
        (case,year0,month0,year1,month1))
    #for var in varlist:
    #    print var,
    #print ''

    filelist = create_file_list_period(case,year0,year1,month0,month1)
    ntime    = len(filelist)

    fpin = Nio.open_file(filelist[0],'r')
    nz   = fpin.dimensions['z_t']
    nlon = fpin.dimensions['nlon']
    nlat = fpin.dimensions['nlat']
    vardict = {} # container for variables
    for var in varlist:
        if fpin.variables[var][0,...].ndim == 2 or not fulldepth:
            vardict[var] = MA.zeros((ntime,nlat,nlon),float)
        elif fpin.variables[var][0,...].ndim == 3 and fulldepth:
            vardict[var] = MA.zeros((ntime,nz,nlat,nlon),float)

    fpin.close()

    days = N.zeros((ntime),float)

    for t in range(ntime):
        fpin = Nio.open_file(filelist[t],'r')
        days[t] = fpin.variables['time'][:]
        for var in varlist:
            if fpin.variables[var][0,...].ndim == 2:
                vardict[var][t,:,:] = fpin.variables[var][0,...]
            elif fpin.variables[var][0,...].ndim == 3:
                if fulldepth:
                    vardict[var][t,:,:,:] = fpin.variables[var][0,...]
                else: # read zlev
                    vardict[var][t,:,:] = fpin.variables[var][0,zlev,...]
            else:
                print 'Unknown number of dimensions.'
                os.sys.exit()

        fpin.close()

    return days, vardict

#------------------------------------------------------------------------------

def grid_area(ulon,ulat):
    """
    Compute area of grid cells in square meters.
    ulon and ulat are 1-D arrays containing the edges of the grid cells
    in degrees.

    Note: total Earth area ~ 5.10e+14 m^2.
    Output: array with grid cell areas
    """
    R    = 6371. * 1000.    # radius of Earth in meters
    dlon = N.diff(ulon)
    dlat = N.diff(ulat)
    dx   = N.outer(deg2rad * R * N.cos(deg2rad * ulat),dlon) # dx (meters)
    dy   = 60. * 1852. *  dlat                               # dy (meters)
    area = (dx[1:] + dx[:-1]) / 2. * dy[:,N.newaxis] # area of grid cells
    return area

def get_grid_data(grid):
    """
    Read grid dimensions and lat & lon.
    """
    indir      = '/home/ivan/Tools/scrip/mapping/grids'
    infile     = os.path.join(indir, grid + '.nc')
    fp         = Nio.open_file(infile,'r')
    nlon, nlat = fp.variables['grid_dims'][:]
    tlat       = fp.variables['grid_center_lat'][:]
    tlon       = fp.variables['grid_center_lon'][:]
    fp.close()
    tlat = N.reshape(tlat,(nlat,nlon))[:,0]
    tlon = N.reshape(tlon,(nlat,nlon))[0,:]
    return nlon, nlat, tlon, tlat

def get_grid_data_popdiag(grid):
    """
    Read grid dimensions and lat & lon.
    """
#   indir      = '/CESM/bgcwg/obgc_diag/mapping/grids'
    indir      = '/glade/p/cesm/bgcwg/obgc_diag/mapping/grids'
    infile     = os.path.join(indir, grid + '.nc')
    fp         = Nio.open_file(infile,'r')
    nlon, nlat = fp.variables['grid_dims'][:]
    tlat       = fp.variables['grid_center_lat'][:]
    tlon       = fp.variables['grid_center_lon'][:]
    fp.close()
    tlat = N.reshape(tlat,(nlat,nlon))[:,0]
    tlon = N.reshape(tlon,(nlat,nlon))[0,:]
    return nlon, nlat, tlon, tlat

def zonal_avg(data,Log=False):
    """
    Compute the zonal average of field on POP gx3v5 grid.
    Shape of input data is expected to be either [nfoo,nlat,nlon]
    or [nlat,nlon]. Log=True computes the geometric average.

    Output: arrays zavg and lat
    """
    print 'computing zonal average'
    # get lat and lon for new regular grid
#   fpin        = Nio.open_file('/home/ivan/Python/data/lat_t.nc','r')
    fpin        = Nio.open_file('/home/emunoz/Python/mapping/model_grid/lat_t.nc','r')
    lat_t       = fpin.variables['lat_t'][:]
    lat_t_edges = fpin.variables['lat_t_edges'][:]
    fpin.close()
#   fpin        = Nio.open_file('/home/ivan/Python/data/gx3v5.nc','r')
    fpin        = Nio.open_file('/home/emunoz/Python/mapping/model_grid/gx3v5.nc','r')
    lon_t       = N.sort(fpin.variables['TLONG'][0,:])
    ulon        = N.sort(fpin.variables['ULONG'][0,:])
    lon_t_edges = N.concatenate((ulon,ulon[0,N.newaxis]+360.),0)
    # get gx3v5 lat and lon
    tlon        = fpin.variables['TLONG'][:]
    tlat        = fpin.variables['TLAT'][:]
    fpin.close()

    # compute area of cells in new regular grid
    area = grid_area(lon_t_edges,lat_t_edges)

    nlat = lat_t.shape[0]
    nlon = lon_t.shape[0]

    if data.ndim == 3:
        new_data = MA.zeros((data.shape[0],nlat,nlon),dtype=float)
    elif data.ndim == 2:
        new_data = MA.zeros((nlat,nlon),dtype=float)
    else:
        print 'Check field dimensions'
        sys.exit()

    # geometric mean?
    if Log:
        work = MA.log(data)
    else:
        work = data

    # remap data to new regular grid
    for i in range(nlat):
        #print 'lat = %.2f'%(lat_t[i])
        for j in range(nlon):
            new_data[:,i,j] = extract_loc(lon_t[j],lat_t[i],tlon,tlat,work)

    # compute zonal average
    if Log:
        za_data = (MA.exp(MA.average(new_data,axis=-1,
            weights=N.resize(area,new_data.shape))))
    else:
        za_data = (MA.average(new_data,axis=-1,
            weights=N.resize(area,new_data.shape)))

    return za_data, lat_t

def zonal_avg2(data,Log=False):
    """
    Compute the zonal average of field on POP gx3v5 grid.
    Shape of input data is expected to be either [nfoo,nlat,nlon]
    or [nlat,nlon]. Log=True computes the geometric average.

    Output: arrays zavg and lat

    Trying to make it faster
    The steps are:
        1) set up the destination grid
        2) compute averaging weights for each grid cell
        3) compute normalizing weights for each basin (if required)
        4) compute basin zonal averages
    """
    print 'setting up the destination grid'
    # get lat and lon for new regular grid
#   fpin        = Nio.open_file('/home/ivan/Python/data/lat_t.nc','r')
    fpin        = Nio.open_file('/home/emunoz/Python/mapping/model_grid/lat_t.nc','r')
    lat_t       = fpin.variables['lat_t'][:]
    lat_t_edges = fpin.variables['lat_t_edges'][:]
    fpin.close()
#   fpin        = Nio.open_file('/home/ivan/Python/data/gx3v5.nc','r')
    fpin        = Nio.open_file('/home/emunoz/Python/mapping/model_grid/gx3v5.nc','r')
    lon_t       = N.sort(fpin.variables['TLONG'][0,:])
    ulon        = N.sort(fpin.variables['ULONG'][0,:])
    lon_t_edges = N.concatenate((ulon,ulon[0,N.newaxis]+360.),0)
    # get gx3v5 lat and lon
    tlon        = fpin.variables['TLONG'][:]
    tlat        = fpin.variables['TLAT'][:]
    fpin.close()

    # compute area of cells in new regular grid
    area = grid_area(lon_t_edges,lat_t_edges)

    nlat = lat_t.shape[0]
    nlon = lon_t.shape[0]

    print 'computing weights for grid cell'
    ilist   = []
    jlist   = []
    wghts2D = []
    wghts3D = []
    for i in range(nlat):
        for j in range(nlon):
            i_inds, j_inds = find_stn_idx(lon_t[j], lat_t[i], tlon, tlat)
            ilist.append(i_inds)
            jlist.append(j_inds)
            dist = gc_dist(lon_t[i], lat_t[i], tlon, tlat)
            # make weights=0 on land
            work2D = 1./MA.array(dist,mask=data[0,...].mask)
            wghts2D.append(MA.filled(N.take(N.take(work2D,i_inds,0),j_inds,1)
                ,0))

            work3D = 1./MA.array(N.resize(dist,data.shape),mask=data.mask)
            wghts3D.append(MA.filled(N.take(N.take(work3D,i_inds,-2),j_inds,-1)
                ,0))

    #print 'computing zonal average'
    return lon_t, lat_t, ilist, jlist, wghts2D, wghts3D

def mean_annual_cycle(data):
    """
    Compute the mean annual cycle of variable.
    Assumes data is masked array with shape [nmonth,nlat,nlon].

    Output: array
    """
    ntime, nlat, nlon = data.shape
    # reshape from [nmonth,nlat,nlon] to [nyear,12,nlat,nlon]
    work = MA.reshape(data,(-1,12,nlat,nlon))
    # compute mean annual cycle
    mean_data = MA.average(work,0)
    return mean_data

def monthly_anom(data):
    """
    Compute monthly anomalies from mean annual cycle.
    Assumes data is masked array with shape [nmonth,nlat,nlon]

    Output: array
    """
    ntime, nlat, nlon = data.shape
    # reshape from [nmonth,nlat,nlon] to [nyear,nmonth,nlat,nlon]
    work = MA.reshape(data,(-1,12,nlat,nlon))
    # compute mean annual cycle
    mean_work = MA.average(work,0)
    # compute anomalies from mean annual cycle
    #anom = MA.reshape(work-mean_work[N.newaxis,...],(-1,nlat,nlon))
    anom = work-mean_work[N.newaxis,...]
    return anom

#------------------------------------------------------------------------------
# Tools for multi-variate analysis (EOF, PCA)

def standardize(data,weights,mode=None):
    """
    Standardize data Xnew = (X - mean) / std.
    mode = 'col': use column-wise (time) means and stds.
    mode = 'row': use row-wise (space) means and stds.
    Otherwise use total space-time mean and std of data.
    Assumes data is masked array with shape [ntime,nspace] and
    weights is array with shape [nspace,]

    NOTE on standardization:

    In a temporal EOF, time is your dependent variable. Therefore,
    standardization of your [ntime X nspace] data matrix, should be
    done across space (row-wise): for each time (row) subtract the
    spatial (row-wise) mean and divide it by the spatial (row-wise)
    std. [ntime X ntime] covariance matrix = covariance between time
    slices.

    Conversely, in a spatial EOF, space is your dependent variable,
    and standardization of your [ntime X nspace] data matrix should be
    done across time (column-wise): for each point in space (column)
    subtract the temporal (column-wise) mean and divide it by the
    temporal (column-wise) std. [nspace X nspace] covariance matrix =
    covariance between spatial fields.

    Ivan Lima - Thu Mar 17 16:11:56 EDT 2011

    """
    wght = MA.resize(weights,data.shape)
    if mode == 'row':   # space
        mean = MA.average(data,weights=wght,axis=1)
        std  = MA.sqrt(MA.average((data-mean[:,N.newaxis])**2,weights=wght,
            axis=1))
        norm_data = ((data-mean[:,N.newaxis])/std[:,N.newaxis])
    elif mode == 'col': # time
        mean      = MA.average(data,weights=wght,axis=0)
        std       = MA.sqrt(MA.average((data-mean)**2,weights=wght,axis=0))
        norm_data = (data - mean) / std
    else:               # total space-time
        mean      = MA.average(data,weights=wght)
        std       = MA.sqrt(MA.average((data-mean)**2,weights=wght))
        norm_data = (data - mean) / std

    return norm_data

def temporal_eof(data):
    """
    Compute EOFs in time and Principal Components in space.
    Assumes input data is masked array with shape [ntime,nspace].
    """
    mat = N.matrix(data.filled(0))
    # compute covariance matrix
    covm = (mat * N.transpose(mat)) / mat.shape[1]
    # compute EOFS
    eigval, eigvec = LA.eig(covm)
    # sort by in decreasing order of eigenvalues
    inds = N.argsort(eigval)[::-1]
    eigvec = eigvec[:,inds]
    eigval = eigval[inds]
    # compute percentage of explained variances by each EOF mode
    var = eigval.real / N.sum(eigval.real) * 100.
    # compute principal components
    pc = N.transpose(mat) * eigvec
    # eigvec and pc are matrices, NOT numpy arrays!
    return eigvec, pc, var

def temporal_eof_w(data,weights):
    """
    Compute EOFs in time and Principal Components in space.
    Covariance matrix is computed using weights (area).
    Assumes input data is masked array with shape [ntime,nspace]
    and weights has shape [nspace,].
    """
    wght = MA.filled(MA.array(MA.resize(weights,data.shape),mask=data.mask),0)
    mat1 = N.matrix(MA.filled(data*wght,0))
    mat2 = N.matrix(MA.filled(data,0))
    # compute covariance matrix
    covm = (mat1 * N.transpose(mat2)) / wght[0,...].sum()
    # compute EOFS
    eigval, eigvec = LA.eig(covm)
    # sort by in decreasing order of eigenvalues
    inds = N.argsort(eigval)[::-1]
    eigvec = eigvec[:,inds]
    eigval = eigval[inds]
    # compute percentage of explained variances by each EOF mode
    var = eigval.real / N.sum(eigval.real) * 100.
    # compute principal components
    pc = N.transpose(mat2) * eigvec
    # eigvec and pc are matrices, NOT numpy arrays!
    return eigvec, pc, var

#------------------------------------------------------------------------------
