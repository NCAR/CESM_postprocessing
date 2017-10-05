from scipy.interpolate import NearestNDInterpolator
from constants import dpy,mid_months,bnd_months
from Regions import Regions
from netCDF4 import Dataset,num2date,date2num
from datetime import datetime
from cfunits import Units
from copy import deepcopy
from mpi4py import MPI
import numpy as np
import logging

logger = logging.getLogger("%i" % MPI.COMM_WORLD.rank)

class VarNotInFile(Exception):
    def __str__(self): return "VarNotInFile"
    
class VarNotMonthly(Exception):
    def __str__(self): return "VarNotMonthly"

class VarNotInModel(Exception):
    def __str__(self): return "VarNotInModel"

class VarsNotComparable(Exception):
    def __str__(self): return "VarNotComparable"

class VarNotOnTimeScale(Exception):
    def __str__(self): return "VarNotOnTimeScale"

class UnknownUnit(Exception):
    def __str__(self): return "UnknownUnit"

class AreasNotInModel(Exception):
    def __str__(self): return "AreasNotInModel"

class MisplacedData(Exception):
    def __str__(self): return "MisplacedData"

class NotTemporalVariable(Exception):
    def __str__(self): return "NotTemporalVariable"

class NotSpatialVariable(Exception):
    def __str__(self): return "NotSpatialVariable"

class UnitConversionError(Exception):
    def __str__(self): return "UnitConversionError"

class AnalysisError(Exception):
    def __str__(self): return "AnalysisError"

class NotLayeredVariable(Exception):
    def __str__(self): return "NotLayeredVariable"
    
class NotDatasiteVariable(Exception):
    def __str__(self): return "NotDatasiteVariable"

    
def GenerateDistinctColors(N,saturation=0.67,value=0.67):
    r"""Generates a series of distinct colors.

    Computes N distinct colors using HSV color space, holding the
    saturation and value levels constant and linearly vary the
    hue. Colors are returned as a RGB tuple.

    Parameters
    ----------
    N : int
        number of distinct colors to generate
    saturation : float, optional
        argument of HSV color space
    value : float, optional
        argument of HSV color space

    Returns
    -------
    RGB_tuples : list
       list of N distinct RGB tuples
    """
    from colorsys import hsv_to_rgb
    HSV_tuples = [(x/float(N), saturation, value) for x in range(N)]
    RGB_tuples = map(lambda x: hsv_to_rgb(*x), HSV_tuples)
    return RGB_tuples

def ConvertCalendar(t,tbnd=None):
    r"""Converts calendar representations to a single standard.

    This routine converts the representation of time to the ILAMB
    default: days since 1850-1-1 00:00:00 on a 365-day calendar. This
    is so we can make comparisons with data from other models and
    benchmarks. We use cfunits time conversion capability.

    Parameters
    ----------
    t : netCDF4 variable
        the netCDF4 variable which represents time
    tbnd : netCDF4 variable, optional
        the netCDF4 variable which represents the bounds of time

    Returns
    -------
    ta : numpy.ndarray
        a numpy array of the converted times
    tabnd : numpy.ndarray, optional
        a numpy array of the converted boundary times

    """
    # If not calendar is given, we will assume it is 365_day
    unit     = t.units
    if "calendar" in t.ncattrs():
        calendar = t.calendar.lower()
    else:
        calendar = "365_day"
        
    # If bounds are given, we will use those instead and later compute
    # the time as the midpoint of the bounds.
    if tbnd is None:
        ta = t
    else:
        ta = tbnd
        
    # The datum might be different, use netCDF functions to shift it
    ta = num2date(ta[...],unit                 ,calendar=calendar)
    ta = date2num(ta     ,"days since 1850-1-1",calendar=calendar)

    # Differences in calendars need to be handled differently
    # depending on the intended temporal resolution. Here we introduce
    # special code for different cases.
    if tbnd is None:
        if t[...].size == 1:
            dt = 0
        else:
            dt = (ta[1:]-ta[:-1]).mean()
    else:
        dt = (ta[:,1]-ta[:,0]).mean()
    if np.allclose(dt,30,atol=3): # monthly

        tmid = np.copy(ta)
        if tmid.ndim > 1: tmid = ta.mean(axis=1)
        
        # Determine the month index by finding to which mid_month day
        # the middle time point is closest.
        def _dpyShift(tmid,ta,dpy):
            yrs = np.floor((tmid / float(dpy)))*365.
            ind = np.abs((tmid % float(dpy))[:,np.newaxis]-mid_months).argmin(axis=1)
            if ta.ndim == 1:
                ta      = yrs + mid_months[ind]
            if ta.ndim == 2:
                ta[:,0] = yrs + bnd_months[ind]
                ta[:,1] = yrs + bnd_months[ind+1]
            return ta
        if calendar == "360_day":
            ta = _dpyShift(tmid,ta,360)
        elif calendar == "366_day":
            ta = _dpyShift(tmid,ta,366)
        elif calendar in ["365_day","noleap"]:
            ta = _dpyShift(tmid,ta,365)           
        elif calendar in ["proleptic_gregorian","gregorian","standard","julian"]:
            # we can use datetime to get the Julian day and then find
            # how these line up with mid_months
            tmid = num2date(tmid,"days since 1850-1-1",calendar=calendar)
            yrs  = [float(t.year-1850)*365.      for t in tmid]
            tmid = [float(t.timetuple().tm_yday) for t in tmid]
            tmid = np.asarray(tmid)
            ind  = np.abs(tmid[:,np.newaxis]-mid_months).argmin(axis=1)
            if ta.ndim == 1:
                ta      = yrs + mid_months[ind]
            if ta.ndim == 2:
                ta[:,0] = yrs + bnd_months[ind]
                ta[:,1] = yrs + bnd_months[ind+1]
        else:
            raise ValueError("Unsupported calendar: %s" % calendar)

    if tbnd is None: return ta
    t = ta.mean(axis=1)
    return t,ta

def CellAreas(lat,lon):
    """Given arrays of latitude and longitude, return cell areas in square meters.

    Parameters
    ----------
    lat : numpy.ndarray
        a 1D array of latitudes which represent cell centroids
    lon : numpy.ndarray
        a 1D array of longitudes which represent cell centroids

    Returns
    -------
    areas : numpy.ndarray
        a 2D array of cell areas in [m2]
    """
    from constants import earth_rad

    x = np.zeros(lon.size+1)
    x[1:-1] = 0.5*(lon[1:]+lon[:-1])
    x[ 0]   = lon[ 0]-0.5*(lon[ 1]-lon[ 0])
    x[-1]   = lon[-1]+0.5*(lon[-1]-lon[-2])
    if(x.max() > 181): x -= 180
    x  = x.clip(-180,180)
    x *= np.pi/180.

    y = np.zeros(lat.size+1)
    y[1:-1] = 0.5*(lat[1:]+lat[:-1])
    y[ 0]   = lat[ 0]-0.5*(lat[ 1]-lat[ 0])
    y[-1]   = lat[-1]+0.5*(lat[-1]-lat[-2])
    y       = y.clip(-90,90)
    y *= np.pi/180.

    dx    = earth_rad*(x[1:]-x[:-1])
    dy    = earth_rad*(np.sin(y[1:])-np.sin(y[:-1]))
    areas = np.outer(dx,dy).T

    return areas

def GlobalLatLonGrid(res,**keywords):
    r"""Generates a latitude/longitude grid at a desired resolution
    
    Computes 1D arrays of latitude and longitude values which
    correspond to cell interfaces and centroids at a given resolution.

    Parameters
    ----------
    res : float
        the desired resolution of the grid in degrees
    from_zero : boolean
        sets longitude convention { True:(0,360), False:(-180,180) }

    Returns
    -------
    lat_bnd : numpy.ndarray
        a 1D array of latitudes which represent cell interfaces
    lon_bnd : numpy.ndarray
        a 1D array of longitudes which represent cell interfaces
    lat : numpy.ndarray
        a 1D array of latitudes which represent cell centroids
    lon : numpy.ndarray
        a 1D array of longitudes which represent cell centroids
    """
    from_zero = keywords.get("from_zero",False)
    res_lat   = keywords.get("res_lat",res)
    res_lon   = keywords.get("res_lon",res)
    nlon    = int(360./res_lon)+1
    nlat    = int(180./res_lat)+1
    lon_bnd = np.linspace(-180,180,nlon)
    if from_zero: lon_bnd += 180
    lat_bnd = np.linspace(-90,90,nlat)
    lat     = 0.5*(lat_bnd[1:]+lat_bnd[:-1])
    lon     = 0.5*(lon_bnd[1:]+lon_bnd[:-1])
    return lat_bnd,lon_bnd,lat,lon

def NearestNeighborInterpolation(lat1,lon1,data1,lat2,lon2):
    r"""Interpolates globally grided data at another resolution

    Parameters
    ----------
    lat1 : numpy.ndarray
        a 1D array of latitudes of cell centroids corresponding to the 
        source data
    lon1 : numpy.ndarray
        a 1D array of longitudes of cell centroids corresponding to the 
        source data
    data1 : numpy.ndarray
        an array of data to be interpolated of shape = (lat1.size,lon1.size,...)
    lat2 : numpy.ndarray
        a 1D array of latitudes of cell centroids corresponding to the 
        target resolution
    lon2 : numpy.ndarray
        a 1D array of longitudes of cell centroids corresponding to the 
        target resolution

    Returns
    -------
    data2 : numpy.ndarray
        an array of interpolated data of shape = (lat2.size,lon2.size,...)
    """
    rows  = np.apply_along_axis(np.argmin,1,np.abs(lat2[:,np.newaxis]-lat1))
    cols  = np.apply_along_axis(np.argmin,1,np.abs(lon2[:,np.newaxis]-lon1))
    data2 = data1[np.ix_(rows,cols)]
    return data2
    
def TrueError(lat1_bnd,lon1_bnd,lat1,lon1,data1,lat2_bnd,lon2_bnd,lat2,lon2,data2):
    r"""Computes the pointwise difference between two sets of gridded data

    To obtain the pointwise error we populate a list of common cell
    interfaces and then interpolate both input arrays to the composite
    grid resolution using nearest-neighbor interpolation.

    Parameters
    ----------
    lat1_bnd, lon1_bnd, lat1, lon1 : numpy.ndarray
        1D arrays corresponding to the latitude/longitudes of the cell 
        interfaces/centroids
    data1 : numpy.ndarray
        an array of data to be interpolated of shape = (lat1.size,lon1.size,...)
    lat2_bnd, lon2_bnd, lat2, lon2 : numpy.ndarray
        1D arrays corresponding to the latitude/longitudes of the cell 
        interfaces/centroids
    data2 : numpy.ndarray
        an array of data to be interpolated of shape = (lat2.size,lon2.size,...)

    Returns
    -------
    lat_bnd, lon_bnd, lat, lon : numpy.ndarray
        1D arrays corresponding to the latitude/longitudes of the cell 
        interfaces/centroids of the resulting error
    error : numpy array
        an array of the pointwise error of shape = (lat.size,lon.size,...)
    """
    # combine limits, sort and remove duplicates
    lat_bnd = np.hstack((lat1_bnd,lat2_bnd)); lat_bnd.sort(); lat_bnd = np.unique(lat_bnd)
    lon_bnd = np.hstack((lon1_bnd,lon2_bnd)); lon_bnd.sort(); lon_bnd = np.unique(lon_bnd)

    # need centroids of new grid for nearest-neighbor interpolation
    lat = 0.5*(lat_bnd[1:]+lat_bnd[:-1])
    lon = 0.5*(lon_bnd[1:]+lon_bnd[:-1])

    # interpolate datasets at new grid
    d1 = NearestNeighborInterpolation(lat1,lon1,data1,lat,lon)
    d2 = NearestNeighborInterpolation(lat2,lon2,data2,lat,lon)
    
    # relative to the first grid/data
    error = d2-d1
    return lat_bnd,lon_bnd,lat,lon,error

def SympifyWithArgsUnits(expression,args,units):
    """Uses symbolic algebra to determine the final unit of an expression.
    
    Parameters
    ----------
    expression : str
        the expression whose units you wish to simplify
    args : dict
        a dictionary of numpy arrays whose keys are the
        variables written in the input expression
    units : dict
        a dictionary of strings representing units whose keys are the
        variables written in the input expression

    """
    from sympy import sympify,postorder_traversal

    expression = sympify(expression)
    
    # We need to do what sympify does but also with unit
    # conversions. So we traverse the expression tree in post order
    # and take actions based on the kind of operation being performed.
    for expr in postorder_traversal(expression):

        if expr.is_Atom: continue        
        ekey = str(expr) # expression key
        
        if expr.is_Add:

            # Addition will require that all args should be the same
            # unit. As a convention, we will try to conform all units
            # to the first variable's units. 
            key0 = None
            for arg in expr.args:
                key = str(arg)
                if not args.has_key(key): continue
                if key0 is None:
                    key0 = key
                else:
                    # Conform these units to the units of the first arg
                    Units.conform(args[key],
                                  Units(units[key]),
                                  Units(units[key0]),
                                  inplace=True)
                    units[key] = units[key0]

            # Now add the result of the addition the the disctionary
            # of arguments.
            args [ekey] = sympify(str(expr),locals=args)
            units[ekey] = units[key0]

        elif expr.is_Pow:

            assert len(expr.args) == 2 # check on an assumption
            power = float(expr.args[1])
            args [ekey] = args[str(expr.args[0])]**power
            units[ekey] = Units(units[str(expr.args[0])])
            units[ekey] = units[ekey]**power
        
        elif expr.is_Mul:

            unit = Units("1")
            for arg in expr.args:
                key   = str(arg)
                if units.has_key(key): unit *= Units(units[key])
        
            args [ekey] = sympify(str(expr),locals=args)
            units[ekey] = Units(unit).formatted()

    return args[ekey],units[ekey]


def ComputeIndexingArrays(lat2d,lon2d,lat,lon):
    """Blah.

    Parameters
    ----------
    lat : numpy.ndarray
        A 1D array of latitudes of cell centroids
    lon : numpy.ndarray
        A 1D array of longitudes of cell centroids

    """
    # Prepare the interpolator
    points   = np.asarray([lat2d.flatten(),lon2d.flatten()]).T
    values   = np.asarray([(np.arange(lat2d.shape[0])[:,np.newaxis]*np.ones  (lat2d.shape[1])).flatten(),
                           (np.ones  (lat2d.shape[0])[:,np.newaxis]*np.arange(lat2d.shape[1])).flatten()]).T
    fcn      = NearestNDInterpolator(points,values)
    LAT,LON  = np.meshgrid(lat,lon,indexing='ij')
    gmap     = fcn(LAT.flatten(),LON.flatten()).astype(int)
    return gmap[:,0].reshape(LAT.shape),gmap[:,1].reshape(LAT.shape)

def FromNetCDF4(filename,variable_name,alternate_vars=[],t0=None,tf=None,group=None):
    """Extracts data from a netCDF4 datafile for use in a Variable object.
    
    Intended to be used inside of the Variable constructor. Some of
    the return arguments will be None depending on the contents of the
    netCDF4 file.

    Parameters
    ----------
    filename : str
        Name of the netCDF4 file from which to extract a variable
    variable_name : str
        Name of the variable to extract from the netCDF4 file
    alternate_vars : list of str, optional
        A list of possible alternate variable names to find
    t0 : float, optional
        If temporal, specifying the initial time can reduce memory
        usage and speed up access time.
    tf : float, optional
        If temporal, specifying the final time can reduce memory
        usage and speed up access time.

    Returns
    -------
    data : numpy.ma.masked_array
        The array which contains the data which constitutes the variable
    unit : str
        The unit of the input data
    name : str
        The name of the variable, will be how it is saved in an output netCDF4 file
    time : numpy.ndarray
        A 1D array of times in days since 1850-01-01 00:00:00
    time_bnds : numpy.ndarray
        A 1D array of time bounds in days since 1850-01-01 00:00:00
    lat : numpy.ndarray
        A 1D array of latitudes of cell centroids
    lon : numpy.ndarray
        A 1D array of longitudes of cell centroids
    area : numpy.ndarray
        A 2D array of the cell areas
    ndata : int
        Number of data sites this data represents
    depth_bnds : numpy.ndarray
        A 1D array of the depth boundaries of each cell
    """
    try:
        dset = Dataset(filename,mode="r")
        if group is None:
            grp = dset
        else:
            grp = dset.groups[group]
    except RuntimeError:
        raise RuntimeError("Unable to open the file: %s" % filename)

    found     = False
    if variable_name in grp.variables.keys():
        found = True
        var   = grp.variables[variable_name]
    else:
        while alternate_vars.count(None) > 0: alternate_vars.pop(alternate_vars.index(None))
        for var_name in alternate_vars:
            if var_name in grp.variables.keys():
                found = True
                var   = grp.variables[var_name]
    if found == False:
        alternate_vars.insert(0,variable_name)
        raise RuntimeError("Unable to find [%s] in the file: %s" % (",".join(alternate_vars),filename))
    
    # Initialize names/values of dimensions to None
    time_name  = None; time_bnd_name  = None; t     = None; t_bnd     = None
    lat_name   = None; lat_bnd_name   = None; lat   = None; lat_bnd   = None
    lon_name   = None; lon_bnd_name   = None; lon   = None; lon_bnd   = None
    depth_name = None; depth_bnd_name = None; depth = None; depth_bnd = None
    data_name  = None;                        data  = None;

    # Read in possible dimension information and their bounds
    def _get(key,dset):
        dim_name = key
        try:
            v = dset.variables[key]
            dim_bnd_name = v.getncattr("bounds")
        except:
            dim_bnd_name = None
        return dim_name,dim_bnd_name    
    for key in var.dimensions:
        if  "time"  in key.lower():  time_name ,time_bnd_name  = _get(key,grp)
        if  "lat"   in key.lower():  lat_name  ,lat_bnd_name   = _get(key,grp)
        if  "lon"   in key.lower():  lon_name  ,lon_bnd_name   = _get(key,grp)
        if  "data"  in key.lower():  data_name ,junk           = _get(key,grp)
        if ("layer" in key.lower() or
            "lev"   in key.lower() or
            "z_t"   in key.lower() or
            "depth" in key.lower()): depth_name,depth_bnd_name = _get(key,grp)

    # It is possible that lat and lon are just the sizes of the data
    # array, and the real latitude and longitude arrays are 2D. Then
    # we need to interpolate.
    inter = False
    if (lat_name is not None and lat_name not in grp.variables):
        inter    = True
        possible = [key for key in grp.variables if ((key   not in grp.dimensions) and
                                                     ("lat"     in key.lower()   ) and
                                                     ("_"   not in key           ))]
        if len(possible)==1:
            lat_name = possible[0]
        else:
            raise RuntimeError("Unable to find latitudes in the file: %s" % (filename))
    if (lon_name is not None and lon_name not in grp.variables):
        inter    = True
        possible = [key for key in grp.variables if ((key   not in grp.dimensions) and
                                                     ("lon"     in key.lower()   ) and
                                                     ("_"   not in key           ))]
        if len(possible)==1:
            lon_name = possible[0]
        else:
            raise RuntimeError("Unable to find longitudes in the file: %s" % (filename))
    
    # Based on present values, get dimensions and bounds
    cbounds = None
    if time_name is not None:
        if time_bnd_name is None:
            t       = ConvertCalendar(grp.variables[time_name])
        else:
            t,t_bnd = ConvertCalendar(grp.variables[time_name],grp.variables[time_bnd_name])
        if "climatology" in grp.variables[time_name].ncattrs():
            cbounds = grp.variables[grp.variables[time_name].climatology]
            if not np.allclose(cbounds.shape,[12,2]):
                raise RuntimeError("ILAMB only supports annual cycle style climatologies")
            cbounds = np.round(cbounds[0,:]/365.+1850.)
    if lat_name       is not None: lat       = grp.variables[lat_name]      [...]
    if lat_bnd_name   is not None: lat_bnd   = grp.variables[lat_bnd_name]  [...]
    if lon_name       is not None: lon       = grp.variables[lon_name]      [...]
    if lon_bnd_name   is not None: lon_bnd   = grp.variables[lon_bnd_name]  [...]
    if depth_name     is not None: depth     = grp.variables[depth_name]    [...]
    if depth_bnd_name is not None: depth_bnd = grp.variables[depth_bnd_name][...]
    if data_name      is not None:
        data = len(grp.dimensions[data_name])
        # if we have data sites, there may be lat/lon data to come
        # along with them although not a dimension of the variable
        for key in grp.variables.keys():
            if "lat" in key: lat_name = key
            if "lon" in key: lon_name = key
        if lat_name is not None: lat = grp.variables[lat_name][...]
        if lon_name is not None: lon = grp.variables[lon_name][...]
        if lat.size != data: lat = None
        if lon.size != data: lon = None

    
    # read in data array, roughly subset in time if bounds are
    # provided for added effciency, what do we do if no time in this
    # file falls within the time bounds?
    if (t is not None) and (t0 is not None or tf is not None):
        begin = 0; end = t.size
        if t0 is not None: begin = max(t.searchsorted(t0)-1,begin)
        if tf is not None: end   = min(t.searchsorted(tf)+1,end)
        v = var[begin:end,...]
        t = t  [begin:end]
        if t_bnd is not None:
            t_bnd = t_bnd[begin:end,:]
    else:
        v = var[...]

    # If lat and lon are 2D, then we will need to interpolate things
    if inter:
        if lat.ndim == 2 and lon.ndim == 2:
            assert lat.shape == lon.shape
            
            # Create the grid
            res          = 1.0
            lat_bnds     = np.arange(- 90, 90+res/2.,res)
            lon_bnds     = np.arange(round(lon.min(),0),
                                     round(lon.max(),0)+res/2.,res)
            lats         = 0.5*(lat_bnds[:-1]+lat_bnds[1:])
            lons         = 0.5*(lon_bnds[:-1]+lon_bnds[1:])
            ilat,ilon    = ComputeIndexingArrays(lat,lon,lats,lons)
            v            = v[...,ilat,ilon]
            lat          = lats
            lon          = lons
            lat_bnd      = np.zeros((lat.size,2))
            lat_bnd[:,0] = lat_bnds[:-1]
            lat_bnd[:,1] = lat_bnds[+1:]
            lon_bnd      = lon_bnds
            lon_bnd      = np.zeros((lon.size,2))
            lon_bnd[:,0] = lon_bnds[:-1]
            lon_bnd[:,1] = lon_bnds[+1:]
        
    # handle incorrect or absent masking of arrays
    if type(v) != type(np.ma.empty(1)):
        mask = np.zeros(v.shape,dtype=int)
        if "_FillValue"    in var.ncattrs(): mask += (np.abs(v-var._FillValue   )<1e-12)
        if "missing_value" in var.ncattrs(): mask += (np.abs(v-var.missing_value)<1e-12)
        v = np.ma.masked_array(v,mask=mask,copy=False)

    # handle units problems that cfunits doesn't
    if "units" in var.ncattrs():
        units = var.units.replace("unitless","1")
    else:
        units = "1"
    dset.close()
    
    return v,units,variable_name,t,t_bnd,lat,lat_bnd,lon,lon_bnd,depth,depth_bnd,cbounds,data

        
def Score(var,normalizer,FC=0.999999):
    """Remaps a normalized variable to the interval [0,1].

    Parameters
    ----------
    var : ILAMB.Variable.Variable
        The variable to normalize, usually represents an error of some sort
    normalizer : ILAMB.Variable.Variable
        The variable by which we normalize 
    """
    from Variable import Variable
    name = var.name.replace("bias","bias_score")
    name =     name.replace("diff","diff_score")
    name =     name.replace("rmse","rmse_score")
    name =     name.replace("iav" ,"iav_score")
    np.seterr(over='ignore',under='ignore')

    data = None
    if "bias" in var.name or "diff" in var.name:
        deno = np.ma.copy(normalizer.data)
        if (deno.size - deno.mask.sum()) > 1: deno -= deno.min()*FC       
        data = np.exp(-np.abs(var.data/deno))
    elif "rmse" in var.name:
        data = np.exp(-var.data/normalizer.data)
    elif "iav" in var.name:
        data = np.exp(-np.abs(var.data/normalizer.data))
    data[data<1e-16] = 0.
    np.seterr(over='raise',under='raise')
    return Variable(name  = name,
                    data  = data,
                    unit  = "1",
                    ndata = var.ndata,
                    lat   = var.lat, lat_bnds = var.lat_bnds,
                    lon   = var.lon, lon_bnds = var.lon_bnds,
                    area  = var.area)

def ComposeSpatialGrids(var1,var2):
    """Creates a grid which conforms the boundaries of both variables.
    
    This routine takes the union of the latitude and longitude
    cell boundaries of both grids and returns a new set of
    latitudes and longitudes which represent cell centers of the
    new grid.
    
    Parameters
    ----------
    var1,var2 : ILAMB.Variable.Variable
        The two variables for which we wish to find a common grid
    
    Returns
    -------
    lat : numpy.ndarray
        a 1D array of latitudes of cell centroids
    lon : numpy.ndarray
        a 1D array of longitudes of cell centroids
    """
    if not var1.spatial: il.NotSpatialVariable()
    if not var2.spatial: il.NotSpatialVariable()
    def _make_bnds(x):
        bnds       = np.zeros(x.size+1)
        bnds[1:-1] = 0.5*(x[1:]+x[:-1])
        bnds[ 0]   = max(x[ 0]-0.5*(x[ 1]-x[ 0]),-180)
        bnds[-1]   = min(x[-1]+0.5*(x[-1]-x[-2]),+180)
        return bnds
    lat1_bnd = _make_bnds(var1.lat)
    lon1_bnd = _make_bnds(var1.lon)
    lat2_bnd = _make_bnds(var2.lat)
    lon2_bnd = _make_bnds(var2.lon)
    lat_bnd  = np.hstack((lat1_bnd,lat2_bnd)); lat_bnd.sort(); lat_bnd = np.unique(lat_bnd)
    lon_bnd  = np.hstack((lon1_bnd,lon2_bnd)); lon_bnd.sort(); lon_bnd = np.unique(lon_bnd)
    lat      = 0.5*(lat_bnd[1:]+lat_bnd[:-1])
    lon      = 0.5*(lon_bnd[1:]+lon_bnd[:-1])
    return lat,lon

def ScoreSeasonalCycle(phase_shift):
    """Computes the seasonal cycle score from the phase shift.

    Possible remove this function as we do not compute other score
    components via a ilamblib function.
    """
    from Variable import Variable
    return Variable(data  = (1+np.cos(np.abs(phase_shift.data)/365*2*np.pi))*0.5,
                    unit  = "1",
                    name  = phase_shift.name.replace("phase_shift","phase_shift_score"),
                    ndata = phase_shift.ndata,
                    lat   = phase_shift.lat,
                    lon   = phase_shift.lon,
                    area  = phase_shift.area)

def AnalysisMeanState(ref,com,**keywords):
    """Perform a mean state analysis.

    This mean state analysis examines the model mean state in space
    and time. We compute the mean variable value over the time period
    at each spatial cell or data site as appropriate, as well as the
    bias and RMSE relative to the observational variable. We will
    output maps of the period mean values and bias. For each spatial
    cell or data site we also estimate the phase of the variable by
    finding the mean time of year when the maximum occurs and the
    phase shift by computing the difference in phase with respect to
    the observational variable. In the spatial dimension, we compute a
    spatial mean for each of the desired regions and an average annual
    cycle.    

    Parameters
    ----------
    obs : ILAMB.Variable.Variable
        the observational (reference) variable
    mod : ILAMB.Variable.Variable
        the model (comparison) variable
    regions : list of str, optional
        the regions overwhich to apply the analysis
    dataset : netCDF4.Dataset, optional
        a open dataset in write mode for caching the results of the
        analysis which pertain to the model
    benchmark_dataset : netCDF4.Dataset, optional
        a open dataset in write mode for caching the results of the
        analysis which pertain to the observations
    space_mean : bool, optional
        disable to compute sums of the variable over space instead of
        mean values
    table_unit : str, optional
        the unit to use when displaying output in tables on the HTML page
    plots_unit : str, optional
        the unit to use when displaying output on plots on the HTML page

    """
    regions           = keywords.get("regions"          ,["global"])
    dataset           = keywords.get("dataset"          ,None)
    benchmark_dataset = keywords.get("benchmark_dataset",None)
    space_mean        = keywords.get("space_mean"       ,True)
    table_unit        = keywords.get("table_unit"       ,None)
    plot_unit         = keywords.get("plot_unit"        ,None)
    mass_weighting    = keywords.get("mass_weighting"   ,False)
    skip_rmse         = keywords.get("skip_rmse"        ,False)
    skip_iav          = keywords.get("skip_iav"         ,False)
    skip_cycle        = keywords.get("skip_cycle"       ,False)
    res               = keywords.get("res"              ,0.5)
    ILAMBregions      = Regions()
    spatial           = ref.spatial
    normalizer        = None
    
    # Only study the annual cycle if it makes sense
    if    not ref.monthly: skip_cycle = True
    if ref.time.size < 12: skip_cycle = True
    
    # In order to deal with differences in grids and representation of
    # land, we will interpolate both datasets to a fixed
    # resolution. While not perfect we interpolate to a grid
    # resolution higher than models are typically run. By convention,
    # I will use capital letters for the interpolated quantities.
    if spatial:
        junk,junk,lat,lon = GlobalLatLonGrid(res)
        REF = ref.interpolate(lat=lat,lon=lon,itype='bilinear')
        COM = com.interpolate(lat=lat,lon=lon,itype='bilinear')
        
    # We find the mean values over the time period on the original
    # grid/datasites of each dataset
    ref_timeint = ref.integrateInTime(mean=True)
    com_timeint = com.integrateInTime(mean=True)
    if spatial:
        REF_timeint = REF.integrateInTime(mean=True)
        COM_timeint = COM.integrateInTime(mean=True)
    else:
        REF         = ref
        COM         = com
        REF_timeint = ref_timeint
        COM_timeint = com_timeint
    if mass_weighting: normalizer = REF_timeint.data
    
    # Compute the bias, RMSE, and RMS maps using the interpolated
    # quantities
    bias = REF_timeint.bias(COM_timeint)
    bias_score_map = Score(bias,REF_timeint)
    if not skip_rmse:
        rmse = REF.rmse(COM)
        rms  = REF.rms ()
        rmse_score_map = Score(rmse,rms)

    # The phase shift comes from the interpolated quantities
    if not skip_cycle:
        ref_cycle       = REF.annualCycle()
        com_cycle       = COM.annualCycle()
        ref_maxt_map    = ref_cycle.timeOfExtrema(etype="max")
        com_maxt_map    = com_cycle.timeOfExtrema(etype="max")
        shift_map       = ref_maxt_map.phaseShift(com_maxt_map)
        shift_score_map = ScoreSeasonalCycle(shift_map)
        shift_map.data /= 30.; shift_map.unit = "months"
    
    # Scalars
    ref_period_mean = {}; ref_spaceint = {}; ref_mean_cycle = {}; ref_dtcycle = {}
    com_period_mean = {}; com_spaceint = {}; com_mean_cycle = {}; com_dtcycle = {}
    bias_val = {}; bias_score = {}; rmse_val = {}; rmse_score = {}
    space_std = {}; space_cor = {}; sd_score = {}; shift = {}; shift_score = {}
    for region in regions:
        if spatial:
            ref_period_mean[region] = REF_timeint    .integrateInSpace(region=region,mean=space_mean)
            ref_spaceint   [region] = REF            .integrateInSpace(region=region,mean=True)
            com_period_mean[region] = COM_timeint    .integrateInSpace(region=region,mean=space_mean)
            com_spaceint   [region] = COM            .integrateInSpace(region=region,mean=True)
            bias_val       [region] = bias           .integrateInSpace(region=region,mean=space_mean)
            bias_score     [region] = bias_score_map .integrateInSpace(region=region,mean=True,weight=normalizer)
            if not skip_cycle:
                ref_mean_cycle[region] = ref_cycle   .integrateInSpace(region=region,mean=True)
                ref_dtcycle   [region] = deepcopy(ref_mean_cycle[region])
                ref_dtcycle   [region].data -= ref_mean_cycle[region].data.mean()
                com_mean_cycle[region] = com_cycle  .integrateInSpace(region=region,mean=True)
                com_dtcycle   [region] = deepcopy(com_mean_cycle[region])
                com_dtcycle   [region].data -= com_mean_cycle[region].data.mean()        
                shift         [region] = shift_map      .integrateInSpace(region=region,mean=True,intabs=True)
                shift_score   [region] = shift_score_map.integrateInSpace(region=region,mean=True,weight=normalizer)            
            if not skip_rmse:
                rmse_val   [region] = rmse           .integrateInSpace(region=region,mean=space_mean)
                rmse_score [region] = rmse_score_map .integrateInSpace(region=region,mean=True,weight=normalizer)
            space_std[region],space_cor[region],sd_score[region] = REF_timeint.spatialDistribution(COM_timeint,region=region)
        else:
            ref_period_mean[region] = ref_timeint    .siteStats(region=region)
            ref_spaceint   [region] = ref            .siteStats(region=region)            
            com_period_mean[region] = com_timeint    .siteStats(region=region)
            com_spaceint   [region] = com            .siteStats(region=region)
            bias_val       [region] = bias           .siteStats(region=region)
            bias_score     [region] = bias_score_map .siteStats(region=region,weight=normalizer)
            if not skip_cycle:
                ref_mean_cycle [region] = ref_cycle  .siteStats(region=region)
                ref_dtcycle    [region] = deepcopy(ref_mean_cycle[region])
                ref_dtcycle    [region].data -= ref_mean_cycle[region].data.mean()
                com_mean_cycle [region] = com_cycle  .siteStats(region=region)
                com_dtcycle    [region] = deepcopy(com_mean_cycle[region])
                com_dtcycle    [region].data -= com_mean_cycle[region].data.mean()
                shift          [region] = shift_map  .siteStats(region=region,intabs=True)
                shift_score    [region] = shift_score_map.siteStats(region=region,weight=normalizer)
            if not skip_rmse:
                rmse_val   [region] = rmse           .siteStats(region=region)
                rmse_score [region] = rmse_score_map .siteStats(region=region,weight=normalizer)
                
        ref_period_mean[region].name = "Period Mean %s"                % (region)
        ref_spaceint   [region].name = "spaceint_of_%s_over_%s"        % (ref.name,region)
        com_period_mean[region].name = "Period Mean %s"                % (region)
        com_spaceint   [region].name = "spaceint_of_%s_over_%s"        % (ref.name,region)
        bias_val       [region].name = "Bias %s"                       % (region)
        bias_score     [region].name = "Bias Score %s"                 % (region)
        if not skip_rmse:
            rmse_val   [region].name = "RMSE %s"                       % (region)
            rmse_score [region].name = "RMSE Score %s"                 % (region)
        if not skip_cycle:
            ref_mean_cycle[region].name = "cycle_of_%s_over_%s"           % (ref.name,region)
            ref_dtcycle   [region].name = "dtcycle_of_%s_over_%s"         % (ref.name,region)
            com_mean_cycle[region].name = "cycle_of_%s_over_%s"           % (ref.name,region)
            com_dtcycle   [region].name = "dtcycle_of_%s_over_%s"         % (ref.name,region)
            shift         [region].name = "Phase Shift %s"                % (region)
            shift_score   [region].name = "Seasonal Cycle Score %s"       % (region)
        if spatial:
            sd_score   [region].name = "Spatial Distribution Score %s" % (region)
        
    # Unit conversions
    def _convert(var,unit):
        if type(var) == type({}):
            for key in var.keys(): var[key].convert(unit)
        else:
            var.convert(unit)

    if table_unit is not None:
        for var in [ref_period_mean,com_period_mean,bias_val,rmse_val]:
            _convert(var,table_unit)
    if plot_unit is not None:
        plot_vars = [com_timeint,COM_timeint,ref_timeint,REF_timeint,bias,com_spaceint,ref_spaceint]
        if not skip_rmse: plot_vars.append(rmse)
        if not skip_cycle: plot_vars +=[com_mean_cycle,ref_mean_cycle,com_dtcycle,ref_dtcycle]
        for var in plot_vars: _convert(var,plot_unit)
            
    # Rename and optionally dump out information to netCDF4 files
    com_timeint    .name = "timeint_of_%s"        % ref.name
    bias           .name = "bias_map_of_%s"       % ref.name
    bias_score_map .name = "biasscore_map_of_%s"  % ref.name
    
    out_vars = [com_period_mean,
                com_timeint,
                com_mean_cycle,
                com_dtcycle,
                bias,
                bias_score_map,
                bias_val,
                bias_score,
                shift,
                shift_score]
    if com_spaceint[com_spaceint.keys()[0]].data.size > 1: out_vars.append(com_spaceint)
    if spatial:
        COM_timeint.name = "timeintremap_of_%s"  % ref.name
        out_vars.append(COM_timeint)
    if not skip_cycle:
        com_maxt_map   .name = "phase_map_of_%s"      % ref.name
        shift_map      .name = "shift_map_of_%s"      % ref.name
        shift_score_map.name = "shiftscore_map_of_%s" % ref.name
        out_vars.append(com_maxt_map)
        out_vars.append(shift_map)
        out_vars.append(shift_score_map)
    if not skip_rmse:
        rmse          .name = "rmse_map_of_%s"       % ref.name
        rms           .name = "rms_map_of_%s"        % ref.name
        rmse_score_map.name = "rmsescore_map_of_%s"  % ref.name
        out_vars.append(rmse)
        out_vars.append(rms )
        out_vars.append(rmse_score_map)
        out_vars.append(rmse_val)
        out_vars.append(rmse_score)
    if dataset is not None:
        for var in out_vars:
            if type(var) == type({}):
                for key in var.keys(): var[key].toNetCDF4(dataset,group="MeanState")
            else:
                var.toNetCDF4(dataset,group="MeanState")
    for key in sd_score.keys():
        sd_score[key].toNetCDF4(dataset,group="MeanState",
                                attributes={"std":space_std[key].data,
                                            "R"  :space_cor[key].data})
        
    # Rename and optionally dump out information to netCDF4 files
    out_vars = [ref_period_mean,ref_timeint]
    if ref_spaceint[ref_spaceint.keys()[0]].data.size > 1: out_vars.append(ref_spaceint)
    ref_timeint .name = "timeint_of_%s"        % ref.name
    if not skip_cycle:
        ref_maxt_map.name = "phase_map_of_%s"      % ref.name
        out_vars += [ref_maxt_map,ref_mean_cycle,ref_dtcycle]
    if spatial:
        REF_timeint.name = "timeintremap_of_%s"  % ref.name
        out_vars.append(REF_timeint)
    if benchmark_dataset is not None:
        for var in out_vars:
            if type(var) == type({}):
                for key in var.keys(): var[key].toNetCDF4(benchmark_dataset,group="MeanState")
            else:
                var.toNetCDF4(benchmark_dataset,group="MeanState")
                
    return 

    
def AnalysisRelationship(dep_var,ind_var,dataset,rname,**keywords):
    """Perform a relationship analysis.
    
    Expand to provide details of what exactly is done.

    Parameters
    ----------
    dep_var : ILAMB.Variable.Variable
        the dependent variable
    ind_var : ILAMB.Variable.Variable
        the independent variable
    dataset : netCDF4.Dataset
        a open dataset in write mode for caching the results of the
        analysis which pertain to the model
    rname : str
        the name of the relationship under study
    regions : list of str, optional
        a list of units over which to apply the analysis
    dep_plot_unit,ind_plot_unit : str, optional
        the name of the unit to use in the plots found on the HTML output
        
    """    
    def _extractMaxTemporalOverlap(v1,v2):  # should move?
        t0 = max(v1.time.min(),v2.time.min())
        tf = min(v1.time.max(),v2.time.max())
        for v in [v1,v2]:
            begin = np.argmin(np.abs(v.time-t0))
            end   = np.argmin(np.abs(v.time-tf))+1
            v.time = v.time[begin:end]
            v.data = v.data[begin:end,...]
        mask = v1.data.mask + v2.data.mask
        v1 = v1.data[mask==0].flatten()
        v2 = v2.data[mask==0].flatten()
        return v1,v2

    # grab regions
    regions = keywords.get("regions",["global"])
    
    # convert to plot units
    dep_plot_unit = keywords.get("dep_plot_unit",dep_var.unit)
    ind_plot_unit = keywords.get("ind_plot_unit",ind_var.unit)    
    if dep_plot_unit is not None: dep_var.convert(dep_plot_unit)
    if ind_plot_unit is not None: ind_var.convert(ind_plot_unit)

    # if the variables are temporal, we need to get period means
    if dep_var.temporal: dep_var = dep_var.integrateInTime(mean=True)
    if ind_var.temporal: ind_var = ind_var.integrateInTime(mean=True)
    mask = dep_var.data.mask + ind_var.data.mask

    # analysis over regions
    for region in regions:

        lats,lons = ILAMBregions[region]
        rmask     = (np.outer((dep_var.lat>lats[0])*(dep_var.lat<lats[1]),
                              (dep_var.lon>lons[0])*(dep_var.lon<lons[1]))==0)
        rmask    += mask
        x    = ind_var.data[rmask==0].flatten()
        y    = dep_var.data[rmask==0].flatten()

        # Compute 2D histogram, normalized by number of datapoints
        Nx = 50
        Ny = 50
        counts,xedges,yedges = np.histogram2d(x,y,[Nx,Ny])
        counts = np.ma.masked_values(counts,0)/float(x.size)

        # Compute mean relationship function
        nudge = 1e-15
        xedges[0] -= nudge; xedges[-1] += nudge
        xbins = np.digitize(x,xedges)-1
        xmean = []
        ymean = []
        ystd  = []
        for i in range(xedges.size-1):
            ind = (xbins==i)
            if ind.sum() < max(x.size*1e-4,10): continue
            xtmp = x[ind]
            ytmp = y[ind]
            xmean.append(xtmp.mean())
            ymean.append(ytmp.mean())
            try:        
                ystd.append(ytmp. std())
            except:
                ystd.append(np.sqrt((((ytmp-ytmp.mean())**2).sum())/float(ytmp.size-1)))
        xmean = np.asarray(xmean)
        ymean = np.asarray(ymean)
        ystd  = np.asarray(ystd )

        # Write histogram to the dataset
        grp = dataset.createGroup("%s_relationship_%s" % (region,rname))
        grp.createDimension("nv",size=2)
        for d_bnd,dname in zip([xedges,yedges],["ind","dep"]):
            d = 0.5*(d_bnd[:-1]+d_bnd[1:])
            dbname = dname + "_bnd"
            grp.createDimension(dname,size=d.size)
            D = grp.createVariable(dname,"double",(dname))
            D.setncattr("standard_name",dname)
            D.setncattr("bounds",dbname)
            D[...] = d
            B = grp.createVariable(dbname,"double",(dname,"nv"))
            B.setncattr("standard_name",dbname)
            B[:,0] = d_bnd[:-1]
            B[:,1] = d_bnd[+1:]
        H = grp.createVariable("histogram","double",("ind","dep"))
        H.setncattr("standard_name","histogram")
        H[...] = counts
        
        # Write relationship to the dataset
        grp.createDimension("ndata",size=xmean.size)
        X = grp.createVariable("ind_mean","double",("ndata"))
        X.setncattr("unit",ind_plot_unit)
        M = grp.createVariable("dep_mean","double",("ndata"))
        M.setncattr("unit",dep_plot_unit)
        S = grp.createVariable("dep_std" ,"double",("ndata"))
        X[...] = xmean
        M[...] = ymean
        S[...] = ystd

def ClipTime(v,t0,tf):
    """Remove time from a variable based on input bounds.

    Parameters
    ----------
    v : ILAMB.Variable.Variable
        the variable to trim
    t0,tf : float
        the times at which to trim

    Returns
    -------
    vtrim : ILAMB.Variable.Variable
        the trimmed variable
    """
    begin = np.argmin(np.abs(v.time_bnds[:,0]-t0))
    end   = np.argmin(np.abs(v.time_bnds[:,1]-tf))
    while v.time_bnds[begin,0] > t0:
        begin    -= 1
        if begin <= 0:
            begin = 0
            break
    while v.time_bnds[end,  1] < tf:
        end      += 1
        if end   >= v.time.size-1:
            end   = v.time.size-1
            break
    v.time      = v.time     [begin:(end+1)    ]
    v.time_bnds = v.time_bnds[begin:(end+1),...]
    v.data      = v.data     [begin:(end+1),...]
    return v
    
def MakeComparable(ref,com,**keywords):
    r"""Make two variables comparable.

    Given a reference variable and a comparison variable, make the two
    variables comparable or raise an exception explaining why they are
    not.

    Parameters
    ----------
    ref : ILAMB.Variable.Variable
        the reference variable object
    com : ILAMB.Variable.Variable
        the comparison variable object
    clip_ref : bool, optional
        enable in order to clip the reference variable time using the
        limits of the comparison variable (defult is False)
    mask_ref : bool, optional
        enable in order to mask the reference variable using an
        interpolation of the comparison variable (defult is False)
    eps : float, optional
        used to determine how close you can be to a specific time
        (expressed in days since 1-1-1850) and still be considered the
        same time (default is 30 minutes)
    window : float, optional
        specify to extend the averaging intervals (in days since
        1-1-1850) when a variable must be coarsened (default is 0)

    Returns
    -------
    ref : ILAMB.Variable.Variable
        the modified reference variable object
    com : ILAMB.Variable.Variable
        the modified comparison variable object

    """    
    # Process keywords
    clip_ref  = keywords.get("clip_ref" ,False)
    mask_ref  = keywords.get("mask_ref" ,False)
    eps       = keywords.get("eps"      ,30./60./24.)
    window    = keywords.get("window"   ,0.)
    extents   = keywords.get("extents"  ,np.asarray([[-90.,+90.],[-180.,+180.]]))
    logstring = keywords.get("logstring","")
    
    # If one variable is temporal, then they both must be
    if ref.temporal != com.temporal:
        msg  = "%s Datasets are not uniformly temporal: " % logstring
        msg += "reference = %s, comparison = %s" % (ref.temporal,com.temporal)
        logger.debug(msg)
        raise VarsNotComparable()

    # If the reference is spatial, the comparison must be
    if ref.spatial and not com.spatial:
        msg  = "%s Datasets are not uniformly spatial: " % logstring
        msg += "reference = %s, comparison = %s" % (ref.spatial,com.spatial)
        logger.debug(msg)
        raise VarsNotComparable()

    # If the reference is layered, the comparison must be
    if ref.layered and not com.layered:
        if ref.depth.size == 1:
            com.layered    = True
            com.depth      = ref.depth
            com.depth_bnds = ref.depth_bnds
            shp            = list(com.data.shape)
            insert         = 0
            if com.temporal: insert = 1
            shp.insert(insert,1)
            com.data       = com.data.reshape(shp)
        else:
            msg  = "%s Datasets are not uniformly layered: " % logstring
            msg += "reference = %s, comparison = %s" % (ref.layered,com.layered)
            logger.debug(msg)
            raise NotLayeredVariable()
        
    # If the reference represents observation sites, extract them from
    # the comparison
    if ref.ndata is not None and com.spatial: com = com.extractDatasites(ref.lat,ref.lon)

    # If both variables represent observations sites, make sure you
    # have the same number of sites and that they represent the same
    # location. Note this is after the above extraction so at this
    # point the ndata field of both variables should be equal.
    if ref.ndata != com.ndata:
        msg  = "%s One or both datasets are understood as site data but differ in number of sites: " % logstring
        msg += "reference = %d, comparison = %d" % (ref.ndata,com.ndata)
        logger.debug(msg)
        raise VarsNotComparable()
    if ref.ndata is not None:
        if not (np.allclose(ref.lat,com.lat) or np.allclose(ref.lon,com.lon)):
            msg  = "%s Datasets represent sites, but the locations are different: " % logstring
            msg += "maximum difference lat = %.f, lon = %.f" % (np.abs((ref.lat-com.lat)).max(),
                                                                np.abs((ref.lon-com.lon)).max())
            logger.debug(msg)
            raise VarsNotComparable()

    # If the datasets are both spatial, ensure that both represent the
    # same spatial area and trim the datasets if not.
    if ref.spatial and com.spatial:

        lat_bnds = (max(ref.lat_bnds[ 0,0],com.lat_bnds[ 0,0],extents[0,0]),
                    min(ref.lat_bnds[-1,1],com.lat_bnds[-1,1],extents[0,1]))
        lon_bnds = (max(ref.lon_bnds[ 0,0],com.lon_bnds[ 0,0],extents[1,0]),
                    min(ref.lon_bnds[-1,1],com.lon_bnds[-1,1],extents[1,1]))

        # Clip reference
        diff     = np.abs([ref.lat_bnds[[0,-1],[0,1]]-lat_bnds,
                           ref.lon_bnds[[0,-1],[0,1]]-lon_bnds])
        if diff.sum() >= 5.:
            shp0 = np.asarray(np.copy(ref.data.shape),dtype=int)
            ref.trim(lat=lat_bnds,lon=lon_bnds)
            shp  = np.asarray(np.copy(ref.data.shape),dtype=int)
            msg  = "%s Spatial data was clipped from the reference: " % logstring
            msg += " before: %s" % (shp0)
            msg +=  " after: %s" % (shp )
            logger.info(msg)

        # Clip comparison
        diff     = np.abs([com.lat_bnds[[0,-1],[0,1]]-lat_bnds,
                           com.lon_bnds[[0,-1],[0,1]]-lon_bnds])
        if diff.sum() >= 5.:
            shp0 = np.asarray(np.copy(com.data.shape),dtype=int)
            com.trim(lat=lat_bnds,lon=lon_bnds)
            shp  = np.asarray(np.copy(com.data.shape),dtype=int)
            msg  = "%s Spatial data was clipped from the comparison: " % logstring
            msg += " before: %s" % (shp0)
            msg +=  " after: %s" % (shp )
            logger.info(msg)
            
        
    if ref.temporal:

        # If the reference time scale is significantly larger than the
        # comparison, coarsen the comparison
        if np.log10(ref.dt/com.dt) > 0.5:
            com = com.coarsenInTime(ref.time_bnds,window=window)
        
        # Time bounds of the reference dataset
        t0  = ref.time_bnds[ 0,0]
        tf  = ref.time_bnds[-1,1]

        # Find the comparison time range which fully encompasses the reference
        com = ClipTime(com,t0,tf)
        
        if clip_ref:

            # We will clip the reference dataset too
            t0  = max(t0,com.time_bnds[ 0,0])
            tf  = min(tf,com.time_bnds[-1,1])
            ref = ClipTime(ref,t0,tf)

        else:
            
            # The comparison dataset needs to fully cover the reference in time
            if (com.time_bnds[ 0,0] > (t0+eps) or
                com.time_bnds[-1,1] < (tf-eps)):
                msg  = "%s Comparison dataset does not cover the time frame of the reference: " % logstring
                msg += " t0: %.16e <= %.16e (%s)" % (com.time_bnds[0, 0],t0+eps,com.time_bnds[0, 0] <= (t0+eps))
                msg += " tf: %.16e >= %.16e (%s)" % (com.time_bnds[1,-1],tf-eps,com.time_bnds[1,-1] >= (tf-eps))
                logger.debug(msg)
                raise VarsNotComparable()

        # Check that we now are on the same time intervals
        if ref.time.size != com.time.size:
            msg  = "%s Datasets have differing numbers of time intervals: " % logstring
            msg += "reference = %d, comparison = %d" % (ref.time.size,com.time.size)
            logger.debug(msg)
            raise VarsNotComparable()        
        if not np.allclose(ref.time_bnds,com.time_bnds,atol=0.75*ref.dt):
            msg  = "%s Datasets are defined at different times" % logstring
            logger.debug(msg)
            raise VarsNotComparable()

    if ref.layered:

        # Try to resolve if the layers from the two quantities are
        # different
        if ref.depth.size == com.depth.size == 1:
            ref = ref.integrateInDepth(mean = True) 
            com = com.integrateInDepth(mean = True) 
        elif ref.depth.size != com.depth.size:
            # Compute the mean values from the comparison over the
            # layer breaks of the reference.
            if ref.depth.size == 1 and com.depth.size > 1:
                com = com.integrateInDepth(z0=ref.depth_bnds[ 0,0],
                                           zf=ref.depth_bnds[-1,1],
                                           mean = True)
                ref = ref.integrateInDepth(mean = True) # just removing the depth dimension         
        else:
            if not np.allclose(ref.depth,com.depth):
                msg  = "%s Datasets have a different layering scheme" % logstring
                logger.debug(msg)
                raise VarsNotComparable()

    # Apply the reference mask to the comparison dataset and
    # optionally vice-versa
    if not ref.layered:
        mask = ref.interpolate(time=com.time,lat=com.lat,lon=com.lon)
        com.data.mask += mask.data.mask
        if mask_ref:
            mask = com.interpolate(time=ref.time,lat=ref.lat,lon=ref.lon)
            ref.data.mask += mask.data.mask

    # Convert the comparison to the units of the reference
    com = com.convert(ref.unit)
    
    return ref,com


def CombineVariables(V):
    """Combines a list of variables into a single variable.

    This routine is intended to be used to merge variables when
    separate moments in time are scattered over several files.

    Parameters
    ----------
    V : list of ILAMB.Variable.Variable
        a list of variables to merge into a single variable
    
    Returns
    -------
    v : ILAMB.Variable.Variable
        the merged variable
    """
    from Variable import Variable
    
    # checks on data
    assert type(V) == type([])
    for v in V: assert v.temporal
    if len(V) == 1: return V[0]
    
    # Put list in order by initial time
    V.sort(key=lambda v: v.time[0])

    # Check the beginning and ends times for monotonicity
    nV  = len(V)
    t0  = np.zeros(nV)
    tf  = np.zeros(nV)
    nt  = np.zeros(nV,dtype=int)
    ind = [0]
    for i,v in enumerate(V):
        t0[i] = v.time[ 0]
        tf[i] = v.time[-1]
        nt[i] = v.time.size
        ind.append(nt[:(i+1)].sum())
        
    # Checks on monotonicity
    assert (t0[1:]-t0[:-1]).min() >= 0
    assert (tf[1:]-tf[:-1]).min() >= 0
    assert (t0[1:]-tf[:-1]).min() >= 0

    # Assemble the data
    shp       = (nt.sum(),)+V[0].data.shape[1:]
    time      = np.zeros(shp[0])
    time_bnds = np.zeros((shp[0],2))
    data      = np.zeros(shp)
    mask      = np.zeros(shp,dtype=bool)
    for i,v in enumerate(V):
        time     [ind[i]:ind[i+1]]     = v.time
        time_bnds[ind[i]:ind[i+1],...] = v.time_bnds
        data     [ind[i]:ind[i+1],...] = v.data
        mask     [ind[i]:ind[i+1],...] = v.data.mask
    v = V[0]
    return Variable(data      = np.ma.masked_array(data,mask=mask),
                    unit      = v.unit,
                    name      = v.name,
                    time      = time,
                    time_bnds = time_bnds,
                    lat       = v.lat,
                    lon       = v.lon,
                    area      = v.area,
                    ndata     = v.ndata)

def ConvertBoundsTypes(x):
    y = None
    if x.ndim == 2:
        y = np.zeros(x.shape[0]+1)
        y[:-1] = x[ :, 0]
        y[ -1] = x[-1,-1]
    if x.ndim == 1:
        y = np.zeros((x.shape[0]-1,2))
        y[:,0] = x[:-1]
        y[:,1] = x[+1:]
    return y
        
def LandLinInterMissingValues(mdata):
    land = np.any(mdata.mask,axis=0)==False
    data = np.ma.masked_array(mdata)
    data.data[data.mask] = 0.
    data.fill_value      = 0.
    data = data.data
    land = land.astype(int)
    smooth               = data*land[np.newaxis,...]
    suml                 = np.copy(land)
    smooth[:,1:-1,1:-1] += data[:, :-2, :-2]*land[np.newaxis, :-2, :-2]
    suml  [  1:-1,1:-1] +=                   land[            :-2, :-2]
    smooth[:,1:-1,1:-1] += data[:, :-2,1:-1]*land[np.newaxis, :-2,1:-1]
    suml  [  1:-1,1:-1] +=                   land[            :-2,1:-1]
    smooth[:,1:-1,1:-1] += data[:, :-2, +2:]*land[np.newaxis, :-2, +2:]
    suml  [  1:-1,1:-1] +=                   land[            :-2, +2:]
    smooth[:,1:-1,1:-1] += data[:,1:-1, :-2]*land[np.newaxis,1:-1, :-2]
    suml  [  1:-1,1:-1] +=                   land[           1:-1, :-2]
    smooth[:,1:-1,1:-1] += data[:,1:-1, +2:]*land[np.newaxis,1:-1, +2:]
    suml  [  1:-1,1:-1] +=                   land[           1:-1, +2:]
    smooth[:,1:-1,1:-1] += data[:, +2:, :-2]*land[np.newaxis, +2:, :-2]
    suml  [  1:-1,1:-1] +=                   land[            +2:, :-2]
    smooth[:,1:-1,1:-1] += data[:, +2:,1:-1]*land[np.newaxis, +2:,1:-1]
    suml  [  1:-1,1:-1] +=                   land[            +2:,1:-1]
    smooth[:,1:-1,1:-1] += data[:, +2:, +2:]*land[np.newaxis, +2:, +2:]
    suml  [  1:-1,1:-1] +=                   land[            +2:, +2:]
    smooth /= suml.clip(1)
    smooth  = (mdata.mask==True)*smooth + (mdata.mask==False)*mdata.data
    return smooth
