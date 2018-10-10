from scipy.interpolate import NearestNDInterpolator
from constants import dpy,mid_months,bnd_months
from Regions import Regions
from netCDF4 import Dataset,num2date,date2num
from datetime import datetime
from cf_units import Unit
from copy import deepcopy
from mpi4py import MPI
import numpy as np
import logging,re

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

def FixDumbUnits(unit):
    r"""Try to fix the dumb units people insist on using.
    
    Parameters
    ----------
    unit : str
        the trial unit

    Returns
    -------
    unit : str
        the fixed unit
    """
    # Various synonyms for 1
    if unit.lower().strip() in ["unitless",
                                "n/a",
                                "none"]: unit = "1"
    # Remove the C which so often is used to mean carbon but actually means coulomb
    tokens = re.findall(r"[\w']+", unit)
    for token in tokens:
        if token.endswith("C") and Unit(token[:-1]).is_convertible(Unit("g")):
            unit = unit.replace(token,token[:-1])
    return unit

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
    benchmarks. 

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

def CellAreas(lat,lon,lat_bnds=None,lon_bnds=None):
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

    if (lat_bnds is not None and lon_bnds is not None):
        return earth_rad**2*np.outer((np.sin(lat_bnds[:,1]*np.pi/180.)-
                                      np.sin(lat_bnds[:,0]*np.pi/180.)),
                                     (lon_bnds[:,1]-lon_bnds[:,0])*np.pi/180.)

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

    # try to convert all arguments to same units if possible, it
    # catches most use cases
    keys = args.keys()
    for i,key0 in enumerate(keys):
        for key in keys[(i+1):]:
            try:
                Unit(units[key]).convert(args[key],Unit(units[key0]),inplace=True)
                units[key] = units[key0]
            except:
                pass

    for expr in postorder_traversal(expression):
        ekey = str(expr)
        if expr.is_Add:

            # if there are scalars in the expression, these will not
            # be in the units dictionary. Add them and give them an
            # implicit unit of 1
            keys = [str(arg) for arg in expr.args]
            for key in keys:
                if not units.has_key(key): units[key] = "1"

            # if we are adding, all arguments must have the same unit.
            key0 = keys[0]
            for key in keys:
                Unit(units[key]).convert(np.ones(1),Unit(units[key0]))                    
                units[key] = units[key0]
            units[ekey] = "%s" % (units[key0])

        elif expr.is_Pow:

            # if raising to a power, just create the new unit
            keys = [str(arg) for arg in expr.args]
            units[ekey] = "(%s)%s" % (units[keys[0]],keys[1])

        elif expr.is_Mul:
            
            # just create the new unit
            keys = [str(arg) for arg in expr.args]
            units[ekey] = " ".join(["(%s)" % units[key] for key in keys if units.has_key(key)])
    return sympify(str(expression),locals=args),units[ekey]            

            
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

    # Check on dimensions
    time_name = [name for name in var.dimensions if "time" in name.lower()]
    lat_name  = [name for name in var.dimensions if "lat"  in name.lower()]
    lon_name  = [name for name in var.dimensions if "lon"  in name.lower()]
    data_name = [name for name in var.dimensions if "data" in name.lower()]
    missed    = [name for name in var.dimensions if name not in (time_name +
                                                                 lat_name  +
                                                                 lon_name  +
                                                                 data_name)]

    # Lat/lon might be indexing arrays, find their shape
    shp = None
    if (len(lat_name) == 0 and len(lon_name) == 0 and len(missed) >= 2 and len(data_name) == 0):
        # remove these dimensions from the missed variables
        i,j = var.dimensions[-2],var.dimensions[-1]
        if i in missed: missed.pop(missed.index(i))
        if j in missed: missed.pop(missed.index(j))
        i = grp.variables[i]
        j = grp.variables[j]
        if (np.issubdtype(i.dtype,np.integer) and
            np.issubdtype(j.dtype,np.integer)): shp = [len(i),len(j)]

    # Lat/lon might just be sizes
    if (len(lat_name) == 1 and len(lon_name) == 1):
        if not (lat_name[0] in grp.variables and lon_name[0] in grp.variables):
            shp = [len(grp.dimensions[lat_name[0]]),len(grp.dimensions[lon_name[0]])]

    # If these were sizes, then we need to find the correct 2D lat/lon arrays
    if shp is not None:

        # We want to remove any false positives we might find. I don't
        # want to consider variables which are 'bounds' or dimensions
        # of others, nor those that don't have the correct shape.
        bnds = [grp.variables[v].bounds for v in grp.variables if "bounds" in grp.variables[v].ncattrs()]
        dims = [v for v in grp.variables if (v in grp.dimensions)]
        poss = [v for v in grp.variables if (v not in dims and
                                             v not in bnds and
                                             np.allclose(shp,grp.variables[v].shape) if len(shp) == len(grp.variables[v].shape) else False)]
        lat_name = [name for name in poss if "lat" in name.lower()]
        lon_name = [name for name in poss if "lon" in name.lower()]
        
        # If still ambiguous, look inside the variable attributes for
        # the presence of the variable name to give further
        # preference.
        attrs = [str(var.getncattr(attr)) for attr in var.ncattrs()]
        if len(lat_name) == 0: raise ValueError("Unable to find values for the latitude dimension in %s" % (filename))
        if len(lat_name) > 1:
            tmp_name = [name for name in lat_name if np.any([name in attr for attr in attrs])]
            if len(tmp_name) > 0: lat_name = tmp_name
        if len(lon_name) == 0: raise ValueError("Unable to find values for the longitude dimension in %s" % (filename))
        if len(lon_name) > 1:
            tmp_name = [name for name in lon_name if np.any([name in attr for attr in attrs])]
            if len(tmp_name) > 0: lon_name = tmp_name

    # Time dimension
    if len(time_name) == 1:
        time_name     = time_name[0]
        time_bnd_name = grp.variables[time_name].bounds if (time_name in grp.variables and
                                                            "bounds" in grp.variables[time_name].ncattrs()) else None
        if time_bnd_name not in grp.variables: time_bnd_name = None
    elif len(time_name) >= 1:
        raise ValueError("Ambiguous choice of values for the time dimension [%s] in %s" % (",".join(time_name),filename))
    else:
        time_name     = None
        time_bnd_name = None

    # Lat dimension
    if len(lat_name) == 1:
        lat_name     = lat_name[0]
        lat_bnd_name = grp.variables[lat_name].bounds if (lat_name in grp.variables and
                                                          "bounds" in grp.variables[lat_name].ncattrs()) else None
        if lat_bnd_name not in grp.variables: lat_bnd_name = None
    elif len(lat_name) >= 1:
        raise ValueError("Ambiguous choice of values for the latitude dimension [%s] in %s" % (",".join(lat_name),filename))
    else:
        lat_name     = None
        lat_bnd_name = None

    # Lon dimension
    if len(lon_name) == 1:
        lon_name     = lon_name[0]
        lon_bnd_name = grp.variables[lon_name].bounds if (lon_name in grp.variables and
                                                          "bounds" in grp.variables[lon_name].ncattrs()) else None
        if lon_bnd_name not in grp.variables: lon_bnd_name = None
    elif len(lon_name) >= 1:
        raise ValueError("Ambiguous choice of values for the longitude dimension [%s] in %s" % (",".join(lon_name),filename))
    else:
        lon_name     = None
        lon_bnd_name = None

    # Data dimension
    if len(data_name) == 1:
        data_name     = data_name[0]
    elif len(data_name) >= 1:
        raise ValueError("Ambiguous choice of values for the data dimension [%s] in %s" % (",".join(data_name),filename))
    else:
        data_name     = None

    # The layered dimension is whatever is leftover since its name
    # could be many things
    if len(missed) == 1:
        depth_name = missed[0]
        depth_bnd_name = grp.variables[depth_name].bounds if (depth_name in grp.variables and
                                                              "bounds" in grp.variables[depth_name].ncattrs()) else None
        if depth_bnd_name not in grp.variables: depth_bnd_name = None
    elif len(missed) >= 1:
        raise ValueError("Ambiguous choice of values for the layered dimension [%s] in %s" % (",".join(missed),filename))
    else:
        depth_name     = None
        depth_bnd_name = None
    
    # Based on present values, get dimensions and bounds
    t       = None; t_bnd     = None
    lat     = None; lat_bnd   = None
    lon     = None; lon_bnd   = None
    depth   = None; depth_bnd = None
    data    = None;
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
    if depth_name     is not None:
        dunit = None
        if "units" in grp.variables[depth_name].ncattrs(): dunit = grp.variables[depth_name].units
        depth = grp.variables[depth_name][...]
        if depth_bnd_name is not None:
            depth_bnd = grp.variables[depth_bnd_name][...]
        if dunit is not None:
            if not Unit(dunit).is_convertible(Unit("m")):
                raise ValueError("Non-linear units [%s] of the layered dimension [%s] in %s" % (dunit,depth_name,filename))
            depth = Unit(dunit).convert(depth,Unit("m"),inplace=True)
            if depth_bnd is not None:
                depth_bnd = Unit(dunit).convert(depth_bnd,Unit("m"),inplace=True)
                
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
    # provided for added effciency
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
    if lat is not None and lon is not None:
        if lat.ndim == 2 and lon.ndim == 2:
            assert lat.shape == lon.shape
            
            # Create the grid
            res          = 1.0
            lat_bnds     = np.arange(round(lat.min(),0),
                                     round(lat.max(),0)+res/2.,res)
            lon_bnds     = np.arange(round(lon.min(),0),
                                     round(lon.max(),0)+res/2.,res)
            lats         = 0.5*(lat_bnds[:-1]+lat_bnds[1:])
            lons         = 0.5*(lon_bnds[:-1]+lon_bnds[1:])
            ilat,ilon    = ComputeIndexingArrays(lat,lon,lats,lons)
            r            = np.sqrt( (lat[ilat,ilon]-lats[:,np.newaxis])**2 +
                                    (lon[ilat,ilon]-lons[np.newaxis,:])**2 )
            v            = v[...,ilat,ilon]
            v            = np.ma.masked_array(v,mask=v.mask+(r>2*res))
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

    if "units" in var.ncattrs():
        units = FixDumbUnits(var.units)
    else:
        units = "1"
    dset.close()
    
    return v,units,variable_name,t,t_bnd,lat,lat_bnd,lon,lon_bnd,depth,depth_bnd,cbounds,data
        
def Score(var,normalizer):
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
                    lat   = phase_shift.lat, lat_bnds = phase_shift.lat_bnds,
                    lon   = phase_shift.lon, lon_bnds = phase_shift.lon_bnds,
                    area  = phase_shift.area)

def _composeGrids(v1,v2):
    lat_bnds = np.unique(np.hstack([v1.lat_bnds.flatten(),v2.lat_bnds.flatten()]))
    lon_bnds = np.unique(np.hstack([v1.lon_bnds.flatten(),v2.lon_bnds.flatten()]))
    lat_bnds = lat_bnds[(lat_bnds>=- 90)*(lat_bnds<=+ 90)]
    lon_bnds = lon_bnds[(lon_bnds>=-180)*(lon_bnds<=+180)]
    lat_bnds = np.vstack([lat_bnds[:-1],lat_bnds[+1:]]).T
    lon_bnds = np.vstack([lon_bnds[:-1],lon_bnds[+1:]]).T
    lat      = lat_bnds.mean(axis=1)
    lon      = lon_bnds.mean(axis=1)
    return lat,lon,lat_bnds,lon_bnds

def AnalysisMeanStateSites(ref,com,**keywords):
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

    from Variable import Variable
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
    ILAMBregions      = Regions()
    spatial           = False
    normalizer        = None
    
    # Only study the annual cycle if it makes sense
    if    not ref.monthly: skip_cycle = True
    if ref.time.size < 12: skip_cycle = True
    if skip_rmse         : skip_iav   = True
    
    if spatial:
        lat,lon,lat_bnds,lon_bnds = _composeGrids(ref,com)
        REF = ref.interpolate(lat=lat,lon=lon,lat_bnds=lat_bnds,lon_bnds=lon_bnds)
        COM = com.interpolate(lat=lat,lon=lon,lat_bnds=lat_bnds,lon_bnds=lon_bnds)
        
    # We find the mean values over the time period on the original
    # grid/datasites of each dataset
    ref_timeint = ref.integrateInTime(mean=True)
    com_timeint = com.integrateInTime(mean=True)
    if spatial:
        
        REF_timeint = REF.integrateInTime(mean=True)
        COM_timeint = COM.integrateInTime(mean=True)

        # Masks 
        ref_mask    = REF_timeint.data.mask
        com_mask    = COM_timeint.data.mask
        ref_and_com = (ref_mask == False) * (com_mask == False)
        ref_not_com = (ref_mask == False) * (com_mask == True )
        com_not_ref = (ref_mask == True ) * (com_mask == False)        
        ref_and_COM = Variable(name = "ref_and_COM", unit = ref.unit,
                               data = np.ma.masked_array(COM_timeint.data,mask=(ref_and_com==False)),
                               lat  = lat, lat_bnds = lat_bnds,
                               lon  = lon, lon_bnds = lon_bnds,
                               area = COM_timeint.area)
        COM_not_ref = Variable(name = "COM_not_ref", unit = ref.unit,
                               data = np.ma.masked_array(COM_timeint.data,mask=(com_not_ref==False)),
                               lat  = lat, lat_bnds = lat_bnds,
                               lon  = lon, lon_bnds = lon_bnds,
                               area = COM_timeint.area)
        REF_and_com = Variable(name = "REF_and_com", unit = REF.unit,
                               data = np.ma.masked_array(REF_timeint.data,mask=(ref_and_com==False)),
                               lat  = lat, lat_bnds = lat_bnds,
                               lon  = lon, lon_bnds = lon_bnds,
                               area = REF_timeint.area)
        REF_not_com = Variable(name = "REF_not_com", unit = REF.unit,
                               data = np.ma.masked_array(REF_timeint.data,mask=(ref_not_com==False)),
                               lat  = lat, lat_bnds = lat_bnds,
                               lon  = lon, lon_bnds = lon_bnds,
                               area = REF_timeint.area)
        
        # Apply intersection mask
        REF.data.mask += np.ones(REF.time.size,dtype=bool)[:,np.newaxis,np.newaxis] * (ref_and_com==False)
        COM.data.mask += np.ones(COM.time.size,dtype=bool)[:,np.newaxis,np.newaxis] * (ref_and_com==False)
        REF_timeint.data.mask = (ref_and_com==False)
        COM_timeint.data.mask = (ref_and_com==False)
        
    else:
        
        REF         = ref
        COM         = com
        REF_timeint = ref_timeint
        COM_timeint = com_timeint
    if mass_weighting: normalizer = REF_timeint.data
    
    # Compute the bias, RMSE, and RMS maps using the interpolated
    # quantities
    bias = REF_timeint.bias(COM_timeint)
    cREF = Variable(name = "centralized %s" % REF.name, unit = REF.unit,
                    data = np.ma.masked_array(REF.data-REF_timeint.data[np.newaxis,...],mask=REF.data.mask),
                    time = REF.time, time_bnds = REF.time_bnds,
                    lat  = REF.lat , lat_bnds  = REF.lat_bnds,
                    lon  = REF.lon , lon_bnds  = REF.lon_bnds,
                    area = REF.area, ndata     = REF.ndata)   
    crms = cREF.rms ()
    bias_score_map = Score(bias,crms)
    if spatial:
        bias_score_map.data.mask = (ref_and_com==False) # for some reason I need to explicitly force the mask
    if not skip_rmse:
        cCOM = Variable(name = "centralized %s" % COM.name, unit = COM.unit,
                        data = np.ma.masked_array(COM.data-COM_timeint.data[np.newaxis,...],mask=COM.data.mask),
                        time = COM.time, time_bnds = COM.time_bnds,
                        lat  = COM.lat , lat_bnds  = COM.lat_bnds,
                        lon  = COM.lon , lon_bnds  = COM.lon_bnds,
                        area = COM.area, ndata     = COM.ndata)
        rmse  =  REF.rmse( COM)
        crmse = cREF.rmse(cCOM)
        rmse_score_map = Score(crmse,crms)
    if not skip_iav:
        ref_iav = Variable(name = "centralized %s" % ref.name, unit = ref.unit,
                           data = np.ma.masked_array(ref.data-ref_timeint.data[np.newaxis,...],mask=ref.data.mask),
                           time = ref.time, time_bnds = ref.time_bnds,
                           lat  = ref.lat , lat_bnds  = ref.lat_bnds,
                           lon  = ref.lon , lon_bnds  = ref.lon_bnds,
                           area = ref.area, ndata     = ref.ndata).rms()
        com_iav = Variable(name = "centralized %s" % com.name, unit = com.unit,
                           data = np.ma.masked_array(com.data-com_timeint.data[np.newaxis,...],mask=com.data.mask),
                           time = com.time, time_bnds = com.time_bnds,
                           lat  = com.lat , lat_bnds  = com.lat_bnds,
                           lon  = com.lon , lon_bnds  = com.lon_bnds,
                           area = com.area, ndata     = com.ndata).rms()
        REF_iav = Variable(name = "centralized %s" % REF.name, unit = REF.unit,
                           data = np.ma.masked_array(REF.data-REF_timeint.data[np.newaxis,...],mask=REF.data.mask),
                           time = REF.time, time_bnds = REF.time_bnds,
                           lat  = REF.lat , lat_bnds  = REF.lat_bnds,
                           lon  = REF.lon , lon_bnds  = REF.lon_bnds,
                           area = REF.area, ndata     = REF.ndata).rms()
        COM_iav = Variable(name = "centralized %s" % COM.name, unit = COM.unit,
                           data = np.ma.masked_array(COM.data-COM_timeint.data[np.newaxis,...],mask=COM.data.mask),
                           time = COM.time, time_bnds = COM.time_bnds,
                           lat  = COM.lat , lat_bnds  = COM.lat_bnds,
                           lon  = COM.lon , lon_bnds  = COM.lon_bnds,
                           area = COM.area, ndata     = COM.ndata).rms()
        iav_score_map = Score(Variable(name = "diff %s" % REF.name, unit = REF.unit,
                                       data = (COM_iav.data-REF_iav.data),
                                       lat  = REF.lat , lat_bnds  = REF.lat_bnds,
                                       lon  = REF.lon , lon_bnds  = REF.lon_bnds,
                                       area = REF.area, ndata     = REF.ndata),
                              REF_iav)
        
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
    bias_val  = {}; bias_score = {}; rmse_val = {}; rmse_score = {}
    space_std = {}; space_cor  = {}; sd_score = {}; shift = {}; shift_score = {}; iav_score = {}
    ref_union_mean = {}; ref_comp_mean = {}
    com_union_mean = {}; com_comp_mean = {}
    for region in regions:
        if spatial:
            ref_period_mean[region] = ref_timeint    .integrateInSpace(region=region,mean=space_mean)
            ref_union_mean [region] = REF_and_com    .integrateInSpace(region=region,mean=space_mean)
            com_union_mean [region] = ref_and_COM    .integrateInSpace(region=region,mean=space_mean)
            ref_comp_mean  [region] = REF_not_com    .integrateInSpace(region=region,mean=space_mean)
            com_comp_mean  [region] = COM_not_ref    .integrateInSpace(region=region,mean=space_mean)
            ref_spaceint   [region] = REF            .integrateInSpace(region=region,mean=True)
            com_period_mean[region] = com_timeint    .integrateInSpace(region=region,mean=space_mean)
            com_spaceint   [region] = COM            .integrateInSpace(region=region,mean=True)
            bias_val       [region] = bias           .integrateInSpace(region=region,mean=True)
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
                rmse_val   [region] = rmse           .integrateInSpace(region=region,mean=True)
                rmse_score [region] = rmse_score_map .integrateInSpace(region=region,mean=True,weight=normalizer)
            if not skip_iav:
                iav_score  [region] = iav_score_map .integrateInSpace(region=region,mean=True,weight=normalizer)
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
            if not skip_iav:
                iav_score  [region] = iav_score_map .siteStats(region=region,weight=normalizer)
                
        ref_period_mean[region].name = "Period Mean (original grids) %s" % (region)
        ref_spaceint   [region].name = "spaceint_of_%s_over_%s"        % (ref.name,region)
        com_period_mean[region].name = "Period Mean (original grids) %s" % (region)
        com_spaceint   [region].name = "spaceint_of_%s_over_%s"        % (ref.name,region)
        bias_val       [region].name = "Bias %s"                       % (region)
        bias_score     [region].name = "Bias Score %s"                 % (region)
        if not skip_rmse:
            rmse_val   [region].name = "RMSE %s"                       % (region)
            rmse_score [region].name = "RMSE Score %s"                 % (region)
        if not skip_iav:
            iav_score  [region].name = "Interannual Variability Score %s" % (region)
        if not skip_cycle:
            ref_mean_cycle[region].name = "cycle_of_%s_over_%s"           % (ref.name,region)
            ref_dtcycle   [region].name = "dtcycle_of_%s_over_%s"         % (ref.name,region)
            com_mean_cycle[region].name = "cycle_of_%s_over_%s"           % (ref.name,region)
            com_dtcycle   [region].name = "dtcycle_of_%s_over_%s"         % (ref.name,region)
            shift         [region].name = "Phase Shift %s"                % (region)
            shift_score   [region].name = "Seasonal Cycle Score %s"       % (region)
        if spatial:
            ref_union_mean[region].name = "Benchmark Period Mean (intersection) %s" % (region)
            com_union_mean[region].name = "Model Period Mean (intersection) %s"     % (region)        
            ref_comp_mean [region].name = "Benchmark Period Mean (complement) %s"   % (region)
            com_comp_mean [region].name = "Model Period Mean (complement) %s"       % (region)        
            sd_score      [region].name = "Spatial Distribution Score %s"           % (region)
        
    # Unit conversions
    def _convert(var,unit):
        if type(var) == type({}):
            for key in var.keys(): var[key].convert(unit)
        else:
            var.convert(unit)

    if table_unit is not None:
        for var in [ref_period_mean,com_period_mean,ref_union_mean,com_union_mean,ref_comp_mean,com_comp_mean]:
            _convert(var,table_unit)
    if plot_unit is not None:
        plot_vars = [com_timeint,ref_timeint,bias,com_spaceint,ref_spaceint,bias_val]
        if not skip_rmse:  plot_vars += [rmse,rmse_val]
        if not skip_cycle: plot_vars += [com_mean_cycle,ref_mean_cycle,com_dtcycle,ref_dtcycle]
        if not skip_iav:   plot_vars += [com_iav]
        for var in plot_vars: _convert(var,plot_unit)
            
    # Rename and optionally dump out information to netCDF4 files
    com_timeint    .name = "timeint_of_%s"        % ref.name
    bias           .name = "bias_map_of_%s"       % ref.name
    bias_score_map .name = "biasscore_map_of_%s"  % ref.name
    
    out_vars = [com_period_mean,
                ref_union_mean,
                com_union_mean,
                ref_comp_mean,
                com_comp_mean,
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
    if not skip_cycle:
        com_maxt_map   .name = "phase_map_of_%s"      % ref.name
        shift_map      .name = "shift_map_of_%s"      % ref.name
        shift_score_map.name = "shiftscore_map_of_%s" % ref.name
        out_vars.append(com_maxt_map)
        out_vars.append(shift_map)
        out_vars.append(shift_score_map)
    if not skip_rmse:
        rmse          .name = "rmse_map_of_%s"       % ref.name
        rmse_score_map.name = "rmsescore_map_of_%s"  % ref.name
        out_vars.append(rmse)
        out_vars.append(rmse_score_map)
        out_vars.append(rmse_val)
        out_vars.append(rmse_score)
    if not skip_iav:
        com_iav.name       = "iav_map_of_%s" % ref.name
        iav_score_map.name = "iavscore_map_of_%s"  % ref.name
        out_vars.append(com_iav)
        out_vars.append(iav_score_map)
        out_vars.append(iav_score)
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
    if not skip_iav:
        ref_iav.name      = "iav_map_of_%s" % ref.name
        out_vars.append(ref_iav)
    if benchmark_dataset is not None:
        for var in out_vars:
            if type(var) == type({}):
                for key in var.keys(): var[key].toNetCDF4(benchmark_dataset,group="MeanState")
            else:
                var.toNetCDF4(benchmark_dataset,group="MeanState")
                
    return 
    
        
def AnalysisMeanStateSpace(ref,com,**keywords):
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
    from Variable import Variable
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
    ILAMBregions      = Regions()
    spatial           = ref.spatial

    # Convert str types to booleans
    if type(skip_rmse) == type(""):
        skip_rmse = (skip_rmse.lower() == "true")
    if type(skip_iav ) == type(""):
        skip_iav  = (skip_iav .lower() == "true")
    if type(skip_cycle) == type(""):
        skip_cycle = (skip_cycle.lower() == "true")
    
    # Check if we need to skip parts of the analysis
    if not ref.monthly   : skip_cycle = True
    if ref.time.size < 12: skip_cycle = True
    if ref.time.size == 1: skip_rmse  = True
    if skip_rmse         : skip_iav   = True        
    name = ref.name

    # Interpolate both reference and comparison to a grid composed of
    # their cell breaks
    ref.convert(plot_unit)
    com.convert(plot_unit)
    lat,lon,lat_bnds,lon_bnds = _composeGrids(ref,com)
    REF   = ref.interpolate(lat=lat,lon=lon,lat_bnds=lat_bnds,lon_bnds=lon_bnds)
    COM   = com.interpolate(lat=lat,lon=lon,lat_bnds=lat_bnds,lon_bnds=lon_bnds)
    unit  = REF.unit
    area  = REF.area
    ndata = REF.ndata

    # Find the mean values over the time period
    ref_timeint = ref.integrateInTime(mean=True).convert(plot_unit)
    com_timeint = com.integrateInTime(mean=True).convert(plot_unit)
    REF_timeint = REF.integrateInTime(mean=True).convert(plot_unit)
    COM_timeint = COM.integrateInTime(mean=True).convert(plot_unit)
    normalizer  = REF_timeint.data if mass_weighting else None

    # Report period mean values over all possible representations of
    # land
    ref_and_com = (REF_timeint.data.mask == False) * (COM_timeint.data.mask == False)
    ref_not_com = (REF_timeint.data.mask == False) * (COM_timeint.data.mask == True )
    com_not_ref = (REF_timeint.data.mask == True ) * (COM_timeint.data.mask == False)
    if benchmark_dataset is not None:

        ref_timeint.name = "timeint_of_%s" % name
        ref_timeint.toNetCDF4(benchmark_dataset,group="MeanState")
        for region in regions:

            # reference period mean on original grid
            ref_period_mean = ref_timeint.integrateInSpace(region=region,mean=space_mean).convert(table_unit)
            ref_period_mean.name = "Period Mean (original grids) %s" % region
            ref_period_mean.toNetCDF4(benchmark_dataset,group="MeanState")

    if dataset is not None:

        com_timeint.name = "timeint_of_%s" % name
        com_timeint.toNetCDF4(dataset,group="MeanState")
        for region in regions:

            # reference period mean on intersection of land
            ref_union_mean = Variable(name = "REF_and_com", unit = REF_timeint.unit,
                                      data = np.ma.masked_array(REF_timeint.data,mask=(ref_and_com==False)),
                                      lat  = lat, lat_bnds = lat_bnds, lon  = lon, lon_bnds = lon_bnds,
                                      area = REF_timeint.area).integrateInSpace(region=region,mean=space_mean).convert(table_unit)
            ref_union_mean.name = "Benchmark Period Mean (intersection) %s" % region
            ref_union_mean.toNetCDF4(dataset,group="MeanState")

            # reference period mean on complement of land
            ref_comp_mean = Variable(name = "REF_not_com", unit = REF_timeint.unit,
                                     data = np.ma.masked_array(REF_timeint.data,mask=(ref_not_com==False)),
                                     lat  = lat, lat_bnds = lat_bnds, lon  = lon, lon_bnds = lon_bnds,
                                     area = REF_timeint.area).integrateInSpace(region=region,mean=space_mean).convert(table_unit)
            ref_comp_mean.name = "Benchmark Period Mean (complement) %s" % region
            ref_comp_mean.toNetCDF4(dataset,group="MeanState")

            # comparison period mean on original grid
            com_period_mean = com_timeint.integrateInSpace(region=region,mean=space_mean).convert(table_unit)
            com_period_mean.name = "Period Mean (original grids) %s" % region
            com_period_mean.toNetCDF4(dataset,group="MeanState")

            # comparison period mean on intersection of land
            com_union_mean = Variable(name = "ref_and_COM", unit = COM_timeint.unit,
                                      data = np.ma.masked_array(COM_timeint.data,mask=(ref_and_com==False)),
                                      lat  = lat, lat_bnds = lat_bnds, lon  = lon, lon_bnds = lon_bnds,
                                      area = COM_timeint.area).integrateInSpace(region=region,mean=space_mean).convert(table_unit)
            com_union_mean.name = "Model Period Mean (intersection) %s" % region
            com_union_mean.toNetCDF4(dataset,group="MeanState")

            # comparison period mean on complement of land
            com_comp_mean = Variable(name = "COM_not_ref", unit = COM_timeint.unit,
                                     data = np.ma.masked_array(COM_timeint.data,mask=(com_not_ref==False)),
                                     lat  = lat, lat_bnds = lat_bnds, lon  = lon, lon_bnds = lon_bnds,
                                     area = COM_timeint.area).integrateInSpace(region=region,mean=space_mean).convert(table_unit)
            com_comp_mean.name = "Model Period Mean (complement) %s" % region
            com_comp_mean.toNetCDF4(dataset,group="MeanState")
            
    # Now that we are done reporting on the intersection / complement,
    # set all masks to the intersection
    REF.data.mask += np.ones(REF.time.size,dtype=bool)[:,np.newaxis,np.newaxis] * (ref_and_com==False)
    COM.data.mask += np.ones(COM.time.size,dtype=bool)[:,np.newaxis,np.newaxis] * (ref_and_com==False)
    REF_timeint.data.mask = (ref_and_com==False)
    COM_timeint.data.mask = (ref_and_com==False)
    if mass_weighting: normalizer.mask = (ref_and_com==False)

    # Spatial Distribution: scalars and scores
    if dataset is not None:
        for region in regions:
            space_std,space_cor,sd_score = REF_timeint.spatialDistribution(COM_timeint,region=region)
            sd_score.name = "Spatial Distribution Score %s" % region
            sd_score.toNetCDF4(dataset,group="MeanState",
                               attributes={"std":space_std.data,
                                           "R"  :space_cor.data})
    
    # Cycle: maps, scalars, and scores
    if not skip_cycle:
        ref_cycle         = REF.annualCycle()
        ref_maxt_map      = ref_cycle.timeOfExtrema(etype="max")
        ref_maxt_map.name = "phase_map_of_%s" % name
        com_cycle         = COM.annualCycle()
        com_maxt_map      = com_cycle.timeOfExtrema(etype="max")
        com_maxt_map.name = "phase_map_of_%s" % name
        shift_map         = ref_maxt_map.phaseShift(com_maxt_map)
        shift_map.name    = "shift_map_of_%s" % name
        shift_score_map   = ScoreSeasonalCycle(shift_map)
        shift_score_map.name  = "shiftscore_map_of_%s" % name
        shift_map.data   /= 30.; shift_map.unit = "months"        
        if benchmark_dataset is not None:
            ref_maxt_map.toNetCDF4(benchmark_dataset,group="MeanState")
            for region in regions:
                ref_mean_cycle      = ref_cycle.integrateInSpace(region=region,mean=True)
                ref_mean_cycle.name = "cycle_of_%s_over_%s" % (name,region)
                ref_mean_cycle.toNetCDF4(benchmark_dataset,group="MeanState")
                ref_dtcycle       = deepcopy(ref_mean_cycle)
                ref_dtcycle.data -= ref_mean_cycle.data.mean()
                ref_dtcycle.name  = "dtcycle_of_%s_over_%s" % (name,region)
                ref_dtcycle.toNetCDF4(benchmark_dataset,group="MeanState")
        if dataset is not None:
            com_maxt_map.toNetCDF4(dataset,group="MeanState")
            shift_map      .toNetCDF4(dataset,group="MeanState")
            shift_score_map.toNetCDF4(dataset,group="MeanState")
            for region in regions:
                com_mean_cycle      = com_cycle.integrateInSpace(region=region,mean=True)
                com_mean_cycle.name = "cycle_of_%s_over_%s" % (name,region)
                com_mean_cycle.toNetCDF4(dataset,group="MeanState")
                com_dtcycle       = deepcopy(com_mean_cycle)
                com_dtcycle.data -= com_mean_cycle.data.mean()
                com_dtcycle.name  = "dtcycle_of_%s_over_%s" % (name,region)
                com_dtcycle.toNetCDF4(dataset,group="MeanState")
                shift       = shift_map.integrateInSpace(region=region,mean=True,intabs=True)
                shift_score = shift_score_map.integrateInSpace(region=region,mean=True,weight=normalizer) 
                shift      .name = "Phase Shift %s" % region
                shift      .toNetCDF4(dataset,group="MeanState")
                shift_score.name = "Seasonal Cycle Score %s" % region
                shift_score.toNetCDF4(dataset,group="MeanState")
                
        del ref_cycle,com_cycle,shift_map,shift_score_map
        
    # Bias: maps, scalars, and scores
    bias = REF_timeint.bias(COM_timeint).convert(plot_unit)
    cREF = Variable(name = "centralized %s" % name, unit = REF.unit,
                    data = np.ma.masked_array(REF.data-REF_timeint.data[np.newaxis,...],mask=REF.data.mask),
                    time = REF.time, time_bnds = REF.time_bnds, ndata = REF.ndata,
                    lat  = lat, lat_bnds = lat_bnds, lon = lon, lon_bnds = lon_bnds, area = REF.area).convert(plot_unit)
    REF_iav = cREF.rms()
    if skip_rmse: del cREF
    bias_score_map = Score(bias,REF_iav if REF.time.size > 1 else REF_timeint)
    bias_score_map.data.mask = (ref_and_com==False) # for some reason I need to explicitly force the mask
    if dataset is not None:
        bias.name = "bias_map_of_%s" % name
        bias.toNetCDF4(dataset,group="MeanState")
        bias_score_map.name = "biasscore_map_of_%s" % name
        bias_score_map.toNetCDF4(dataset,group="MeanState")
        for region in regions:
            bias_val = bias.integrateInSpace(region=region,mean=True).convert(plot_unit)
            bias_val.name = "Bias %s" % region
            bias_val.toNetCDF4(dataset,group="MeanState")
            bias_score = bias_score_map.integrateInSpace(region=region,mean=True,weight=normalizer)
            bias_score.name = "Bias Score %s" % region
            bias_score.toNetCDF4(dataset,group="MeanState")
    del bias,bias_score_map

    # Spatial mean: plots
    if REF.time.size > 1:
        if benchmark_dataset is not None:
            for region in regions:
                ref_spaceint = REF.integrateInSpace(region=region,mean=True)
                ref_spaceint.name = "spaceint_of_%s_over_%s" % (name,region)
                ref_spaceint.toNetCDF4(benchmark_dataset,group="MeanState")
        if dataset is not None:
            for region in regions:
                com_spaceint = COM.integrateInSpace(region=region,mean=True)
                com_spaceint.name = "spaceint_of_%s_over_%s" % (name,region)
                com_spaceint.toNetCDF4(dataset,group="MeanState")
 
    # RMSE: maps, scalars, and scores
    if not skip_rmse:
        rmse = REF.rmse(COM).convert(plot_unit)
        del REF
        cCOM = Variable(name = "centralized %s" % name, unit = unit,
                        data = np.ma.masked_array(COM.data-COM_timeint.data[np.newaxis,...],mask=COM.data.mask),
                        time = COM.time, time_bnds = COM.time_bnds,
                        lat  = lat, lat_bnds = lat_bnds, lon = lon, lon_bnds = lon_bnds,
                        area = COM.area, ndata = COM.ndata).convert(plot_unit)
        del COM
        crmse = cREF.rmse(cCOM).convert(plot_unit)
        del cREF
        if skip_iav: del cCOM
        rmse_score_map = Score(crmse,REF_iav)
        if dataset is not None:
            rmse.name = "rmse_map_of_%s" % name
            rmse.toNetCDF4(dataset,group="MeanState")
            rmse_score_map.name = "rmsescore_map_of_%s" % name
            rmse_score_map.toNetCDF4(dataset,group="MeanState")
            for region in regions:
                rmse_val = rmse.integrateInSpace(region=region,mean=True).convert(plot_unit)
                rmse_val.name = "RMSE %s" % region
                rmse_val.toNetCDF4(dataset,group="MeanState")
                rmse_score = rmse_score_map.integrateInSpace(region=region,mean=True,weight=normalizer)
                rmse_score.name = "RMSE Score %s" % region
                rmse_score.toNetCDF4(dataset,group="MeanState")
        del rmse,crmse,rmse_score_map

        # IAV: maps, scalars, scores
        if not skip_iav:
            COM_iav = cCOM.rms()
            del cCOM
            iav_score_map = Score(Variable(name = "diff %s" % name, unit = unit,
                                           data = (COM_iav.data-REF_iav.data),
                                           lat  = lat, lat_bnds = lat_bnds, lon = lon, lon_bnds = lon_bnds,
                                           area = area, ndata = ndata),
                                  REF_iav)
            if benchmark_dataset is not None:
                REF_iav.name = "iav_map_of_%s" % name
                REF_iav.toNetCDF4(benchmark_dataset,group="MeanState")
            if dataset is not None:
                COM_iav.name = "iav_map_of_%s" % name
                COM_iav.toNetCDF4(dataset,group="MeanState")
                iav_score_map.name = "iavscore_map_of_%s"  % name
                iav_score_map.toNetCDF4(dataset,group="MeanState")
                for region in regions:
                    iav_score = iav_score_map.integrateInSpace(region=region,mean=True,weight=normalizer)
                    iav_score.name = "Interannual Variability Score %s" % region
                    iav_score.toNetCDF4(dataset,group="MeanState")
            del COM_iav,iav_score_map
    del REF_iav
               
    return 

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
        ref  = ref.extractDatasites(com.lat,com.lon)
        msg  = "%s The reference dataset is spatial but the comparison is site-based. " % logstring
        msg += "Extracted %s sites from the reference to match the comparison." % ref.ndata
        logger.info(msg)

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

    # If assembled from single slice files and no time bounds were
    # provided, they will not be reflective of true bounds here. If
    # any dt's are 0, make time_bounds none and recompute in the
    # constructor.
    if np.any((time_bnds[:,1]-time_bnds[:,0])<1e-12): time_bnds = None
    
    v = V[0]
    return Variable(data       = np.ma.masked_array(data,mask=mask),
                    unit       = v.unit,
                    name       = v.name,
                    time       = time,
                    time_bnds  = time_bnds,
                    depth      = v.depth,
                    depth_bnds = v.depth_bnds,
                    lat        = v.lat,
                    lon        = v.lon,
                    area       = v.area,
                    ndata      = v.ndata)

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
