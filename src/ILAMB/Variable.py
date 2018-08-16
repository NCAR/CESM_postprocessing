from constants import spd,dpy,mid_months,bnd_months
from Regions import Regions
from mpl_toolkits.basemap import Basemap
import matplotlib.colors as colors
from pylab import get_cmap
from cf_units import Unit
import ilamblib as il
import Post as post
import numpy as np

def _shiftLon(lon):
    return (lon<=180)*lon + (lon>180)*(lon-360) + (lon<-180)*360
    
class Variable:
    r"""A class for managing variables and their analysis.

    There are two ways to create a Variable object. Because python
    does not support multiple constructors, we will use keyword
    arguments so that the users intent may be captured. The first way
    to specify a Variable is by loading a netCDF4 file. You can
    achieve this by specifying the 'filename' and 'variable_name'
    keywords. The second way is to use the remaining keyword arguments
    to specify data arrays directly. If you use the second way, you
    must specify the keywords 'data' and 'unit'. The rest are truly
    optional and depend on the nature of your data.

    Parameters
    ----------
    filename : str, optional
        Name of the netCDF4 file from which to extract a variable
    variable_name : str, optional
        Name of the variable to extract from the netCDF4 file
    data : numpy.ndarray, optional
        The array which contains the data which constitutes the
        variable
    unit : str, optional
        The unit of the input data
    name : str, optional
        The name of the variable, will be how it is saved in the netCDF4 
        file
    time : numpy.ndarray, optional
        a 1D array of times in days since 1850-01-01 00:00:00
    time_bnds : numpy.ndarray, optional
        a 2D array of time bounds in days since 1850-01-01 00:00:00
    lat : numpy.ndarray, optional
        a 1D array of latitudes of cell centroids
    lon : numpy.ndarray, optional
        a 1D array of longitudes of cell centroids
    area : numpy.ndarray, optional
        a 2D array of the cell areas
    ndata : int, optional
        number of data sites this data represents
    alternate_vars : list of str, optional
        a list of alternate acceptable variable names
    depth_bnds : numpy.ndarray, optional
        a 2D array representing the boundaries of the cells in the vertical dimension

    Examples
    --------

    You can initiate a Variable by specifying the data directly.

    >>> lat = np.linspace(- 90, 90, 91)
    >>> lon = np.linspace(-180,180,181)
    >>> data = np.random.rand(91,181)
    >>> v = Variable(name="some_variable",unit="some_unit",lat=lat,lon=lon,data=data)

    Or you can initiate a variable by extracting a specific field from a netCDF4 file.

    >>> v = Variable(filename="some_netcdf_file.nc",variable_name="name_of_var_to_extract")

    """
    def __init__(self,**keywords):
        r"""Constructor for the variable class by specifying the data arrays.
        """
        # See if the user specified a netCDF4 file and variable
        filename       = keywords.get("filename"     ,None)
        groupname      = keywords.get("groupname"    ,None)
        variable_name  = keywords.get("variable_name",None)
        alternate_vars = keywords.get("alternate_vars",[])
        if filename is None: # if not pull data from other arguments
            data       = keywords.get("data"       ,None)
            unit       = keywords.get("unit"       ,None)
            name       = keywords.get("name"       ,"unnamed")
            time       = keywords.get("time"       ,None)
            time_bnds  = keywords.get("time_bnds"  ,None)
            lat        = keywords.get("lat"        ,None)
            lat_bnds   = keywords.get("lat_bnds"   ,None)
            lon        = keywords.get("lon"        ,None)
            lon_bnds   = keywords.get("lon_bnds"   ,None)
            depth      = keywords.get("depth"      ,None)
            depth_bnds = keywords.get("depth_bnds" ,None)
            ndata      = keywords.get("ndata"      ,None)
            assert data is not None
            assert unit is not None
            cbounds    = None
        else:
            assert variable_name is not None
            t0 = keywords.get("t0",None)
            tf = keywords.get("tf",None)
            out = il.FromNetCDF4(filename,variable_name,alternate_vars,t0,tf,group=groupname)            
            data,unit,name,time,time_bnds,lat,lat_bnds,lon,lon_bnds,depth,depth_bnds,cbounds,ndata = out
            
        if not np.ma.isMaskedArray(data): data = np.ma.masked_array(data)
        self.data  = data 
        self.ndata = ndata
        self.unit  = unit
        self.name  = name
        self.cbounds = cbounds
        
        def _createBnds(x):
            x      = np.asarray(x)
            x_bnds = np.zeros((x.size,2))
            x_bnds[+1:,0] = 0.5*(x[:-1]+x[+1:])
            x_bnds[:-1,1] = 0.5*(x[:-1]+x[+1:])
            if x.size == 1:
                x_bnds[ ...] = x
            else:
                x_bnds[ 0,0] = x[ 0] - 0.5*(x[ 1]-x[ 0])
                x_bnds[-1,1] = x[-1] + 0.5*(x[-1]-x[-2])
            return x_bnds
        
        # Handle time data
        self.time      = time      # time data
        self.time_bnds = time_bnds # bounds on time
        self.temporal  = False     # flag for temporal data
        self.dt        = 0.        # mean temporal spacing
        self.monthly   = False     # flag for monthly means
        if time is not None:
            self.temporal = True
            if self.time_bnds is None: self.time_bnds = _createBnds(self.time)
            self.dt = (self.time_bnds[:,1]-self.time_bnds[:,0]).mean()
            if np.allclose(self.dt,30,atol=3): self.monthly = True
            assert (2*self.time.size) == (self.time_bnds.size)
            
        # Handle space or multimember data
        self.spatial  = False
        self.lat      = lat
        self.lon      = lon
        self.lat_bnds = lat_bnds
        self.lon_bnds = lon_bnds
        self.area     = keywords.get("area",None)
        
        # Shift possible values on [0,360] to [-180,180]
        if self.lon      is not None: self.lon      = _shiftLon(self.lon     )
        if self.lon_bnds is not None: self.lon_bnds = _shiftLon(self.lon_bnds)

        # If the last dimensions are lat and lon, this is spatial data
        if lat is not None and lon is not None and data.ndim >= 2:
            if (data.shape[-2] == lat.size and data.shape[-1] == lon.size): self.spatial = True

        if self.spatial is True:
            if np.all(np.diff(self.lat)<0): # Flip if monotonically decreasing
                self.lat      = self.lat     [::-1     ]
                self.data     = self.data[...,::-1,:   ]
                if self.lat_bnds is not None: self.lat_bnds = self.lat_bnds[::-1,::-1]
                if self.area     is not None: self.area     = self.area    [::-1,:]
            if self.lat_bnds is None: self.lat_bnds = _createBnds(self.lat)
            if self.lon_bnds is None: self.lon_bnds = _createBnds(self.lon)
            if self.area     is None: self.area     = il.CellAreas(self.lat,self.lon)                
            # Some data arrays are arranged such that the first column
            # of data is arranged at the prime meridian. This does not
            # work well with some of the plotting and/or analysis
            # operations we will need to perform. These require that
            # the first column be coincident with the international
            # dateline. Thus we roll the data the required amount.
            shift         = self.lon.argmin()
            self.lon      = np.roll(self.lon     ,-shift)
            self.lon_bnds = np.roll(self.lon_bnds,-shift,axis= 0)
            self.data     = np.roll(self.data    ,-shift,axis=-1)
            self.area     = np.roll(self.area    ,-shift,axis=-1)
            # Fix potential problems with rolling the axes of the lon_bnds
            if self.lon_bnds[ 0,0] > self.lon_bnds[ 0,1]: self.lon_bnds[ 0,0] = -180.
            if self.lon_bnds[-1,0] > self.lon_bnds[-1,1]: self.lon_bnds[-1,1] = +180.
            # Make sure that the value lies within the bounds
            assert np.all((self.lat>=self.lat_bnds[:,0])*(self.lat<=self.lat_bnds[:,1]))
            assert np.all((self.lon>=self.lon_bnds[:,0])*(self.lon<=self.lon_bnds[:,1]))
            
        # Is the data layered
        self.layered    = False
        self.depth      = depth
        self.depth_bnds = depth_bnds
        if (data.ndim > (self.temporal + 2*self.spatial + (self.ndata is not None))) and depth is not None:
            self.layered    = True
            if depth_bnds is None: self.depth_bnds = _createBnds(self.depth)
                
    def __str__(self):
        if self.data  is None: return "Uninitialized Variable"
        if self.ndata is None:
            ndata = "N/A"
        else:
            ndata = str(self.ndata)
        if not self.temporal:
            time = ""
        else:
            time = " (%d)" % self.time.size
        if not self.spatial:
            space = ""
        else:
            space = " (%d,%d)" % (self.lat.size,self.lon.size)
        if not self.layered:
            layer = ""
        else:
            layer = " (%d)" % (self.depth.size)
        s  = "Variable: %s\n" % self.name
        s += "-"*(len(self.name)+10) + "\n"
        s += "{0:>20}: ".format("unit")       + self.unit          + "\n"
        s += "{0:>20}: ".format("isTemporal") + str(self.temporal) + time  + "\n"
        s += "{0:>20}: ".format("isSpatial")  + str(self.spatial)  + space + "\n"
        s += "{0:>20}: ".format("isLayered")  + str(self.layered)  + layer + "\n"
        s += "{0:>20}: ".format("nDatasites") + ndata              + "\n"
        s += "{0:>20}: ".format("dataShape")  + "%s\n" % (self.data.shape,)
        np.seterr(over='ignore',under='ignore')
        s += "{0:>20}: ".format("dataMax")    + "%e\n" % self.data.max()
        s += "{0:>20}: ".format("dataMin")    + "%e\n" % self.data.min()
        s += "{0:>20}: ".format("dataMean")   + "%e\n" % self.data.mean()
        np.seterr(over='warn',under='warn')
        if self.cbounds is not None:
            s += "{0:>20}: ".format("climatology")   + "%d thru %d\n" % (self.cbounds[0],self.cbounds[1])
            
        return s

    def nbytes(self):
        r"""Estimate the memory usage of a variable in bytes.
        """
        nbytes = 0.
        for key in self.__dict__.keys():
            try:
                nbytes += self.__dict__[key].nbytes
            except:
                pass
        return nbytes

    def integrateInTime(self,**keywords):
        r"""Integrates the variable over a given time period.

        Uses nodal integration to integrate to approximate 

        .. math:: \int_{t_0}^{t_f} v(t,\dots)\ dt

        The arguments of the integrand reflect that while it must be
        at least defined in time, the remaining arguments are
        flexible. If :math:`t_0` or :math:`t_f` are not specified, the
        variable will be integrated over the extent of its time
        domain. If the mean function value over time is desired, this
        routine will approximate

        .. math:: \frac{1}{t_f-t_0} \int_{t_0}^{t_f} v(t,\dots)\ dt
        
        again by nodal integration. The amount of time which we divide
        by is the non-masked amount of time. This means that if a
        function has some values masked or marked as invalid, we do
        not penalize the average value by including this as a time at
        which data is expected.

        Parameters
        ----------
        t0 : float, optional
            initial time in days since 1/1/1850
        tf : float, optional
            final time in days since 1/1/1850
        mean : boolean, optional
            enable to divide the integrand to get the mean function value

        Returns
        -------
        integral : ILAMB.Variable.Variable
            a Variable instance with the integrated value along with the
            appropriate name and unit change

        """
        if not self.temporal: raise il.NotTemporalVariable()
        t0   = keywords.get("t0",self.time_bnds[:,0].min())
        tf   = keywords.get("tf",self.time_bnds[:,1].max())
        mean = keywords.get("mean",False)
        
        # find which time bounds are included even partially in the interval [t0,tf]
        time_bnds = np.copy(self.time_bnds)
        ind       = np.where((t0<time_bnds[:,1])*(tf>time_bnds[:,0]))[0]
        time_bnds[(t0>time_bnds[:,0])*(t0<time_bnds[:,1]),0] = t0
        time_bnds[(tf>time_bnds[:,0])*(tf<time_bnds[:,1]),1] = tf
        time_bnds = time_bnds[ind,:]
        dt        = (time_bnds[:,1]-time_bnds[:,0])
        
        # now expand this dt to the other dimensions of the data array (i.e. space or datasites)
        for i in range(self.data.ndim-1): dt = np.expand_dims(dt,axis=-1)

        # approximate the integral by nodal integration (rectangle rule)
        np.seterr(over='ignore',under='ignore')
        integral = (self.data[ind]*dt).sum(axis=0)
        np.seterr(over='raise',under='raise')
        
        # the integrated array should be masked where *all* data in time was previously masked
        mask = False
        if self.data.ndim > 1 and self.data.mask.size > 1:
            mask = np.apply_along_axis(np.all,0,self.data.mask[ind])
        integral = np.ma.masked_array(integral,mask=mask,copy=False)
        
        # handle units
        unit = Unit(self.unit)
        name = self.name + "_integrated_over_time"
        
        if mean:
            
            # divide thru by the non-masked amount of time, the units
            # can remain as input because we integrate over time and
            # then divide by the time interval in the same units
            name     += "_and_divided_by_time_period"
            if self.data.mask.size > 1:
                dt = (dt*(self.data.mask[ind]==0)).sum(axis=0)
            else:
                dt = dt.sum(axis=0)   
            np.seterr(over='ignore',under='ignore')
            integral = integral / dt
            np.seterr(over='raise' ,under='raise' )
            
        else:

            # if not a mean, we need to potentially handle unit conversions
            unit0    = Unit("d")*unit
            unit     = Unit(unit0.format().split()[-1])
            integral = unit0.convert(integral,unit)
        
        return Variable(data       = integral,
                        unit       = "%s" % unit,
                        name       = name,
                        lat        = self.lat,
                        lat_bnds   = self.lat_bnds,
                        lon        = self.lon,
                        lon_bnds   = self.lon_bnds,
                        depth      = self.depth,
                        depth_bnds = self.depth_bnds,
                        area       = self.area,
                        ndata      = self.ndata)

    def integrateInDepth(self,**keywords):
        r"""Integrates the variable over a given layer limits.

        Uses nodal integration to integrate to approximate 

        .. math:: \int_{z_0}^{z_f} v(z,\dots)\ dz

        The arguments of the integrand reflect that while it must be
        at least defined in depth, the remaining arguments are
        flexible. If :math:`z_0` or :math:`z_f` are not specified, the
        variable will be integrated over the extent of its depth
        domain. If the mean function value over depth is desired, this
        routine will approximate

        .. math:: \frac{1}{z_f-z_0} \int_{z_0}^{z_f} v(z,\dots)\ dz
        
        again by nodal integration. The amount of depth which we
        divide by is the non-masked amount of depth. This means that
        if a function has some values masked or marked as invalid, we
        do not penalize the average value by including this as a depth
        at which data is expected.

        Parameters
        ----------
        z0 : float, optional
            initial depth in m
        zf : float, optional
            final depth in m
        mean : boolean, optional
            enable to divide the integrand to get the mean function value

        Returns
        -------
        integral : ILAMB.Variable.Variable
            a Variable instance with the integrated value along with the
            appropriate name and unit change

        """
        if not self.layered: raise il.NotLayeredVariable()
        z0   = keywords.get("z0",self.depth_bnds[:,0].min())
        zf   = keywords.get("zf",self.depth_bnds[:,1].max())
        mean = keywords.get("mean",False)
        
        # find which time bounds are included even partially in the interval [z0,zf]
        depth_bnds = np.copy(self.depth_bnds)
        ind        = np.where((z0<depth_bnds[:,1])*(zf>depth_bnds[:,0]))[0]
        depth_bnds[(z0>depth_bnds[:,0])*(z0<depth_bnds[:,1]),0] = z0
        depth_bnds[(zf>depth_bnds[:,0])*(zf<depth_bnds[:,1]),1] = zf
        depth_bnds = depth_bnds[ind,:]
        dz         = (depth_bnds[:,1]-depth_bnds[:,0])
        
        args = []
        axis = 0
        if self.temporal:
            axis += 1
            dz = np.expand_dims(dz,axis=0)
            args.append(range(self.time.size))
        if self.layered: args.append(ind)
        if self.ndata:
            dz = np.expand_dims(dz,axis=-1)
            args.append(range(self.ndata))
        if self.spatial:
            dz = np.expand_dims(dz,axis=-1)
            dz = np.expand_dims(dz,axis=-1)
            args.append(range(self.lat.size))
            args.append(range(self.lon.size))
        ind = np.ix_(*args)
        
        # approximate the integral by nodal integration (rectangle rule)
        shp = self.data[ind].shape
        np.seterr(over='ignore',under='ignore')
        integral = (self.data[ind]*dz).sum(axis=axis)
        np.seterr(over='raise',under='raise')
        
        # the integrated array should be masked where *all* data in depth was previously masked
        mask = False
        if self.data.ndim > 1 and self.data.mask.size > 1:
            mask = np.apply_along_axis(np.all,axis,self.data.mask[ind])
        integral = np.ma.masked_array(integral,mask=mask,copy=False)
        
        # handle units
        unit = Unit(self.unit)
        name = self.name + "_integrated_over_depth"
        
        if mean:
            
            # divide thru by the non-masked amount of time, the units
            # can remain as input because we integrate over time and
            # then divide by the time interval in the same units
            name     += "_and_divided_by_depth"
            if self.data.mask.size > 1:
                dz = (dz*(self.data.mask[ind]==0)).sum(axis=axis)
            else:
                dz = dz.sum(axis=axis)   
            np.seterr(over='ignore',under='ignore')
            integral = integral / dz
            np.seterr(over='raise' ,under='raise' )
            
        else:

            # if not a mean, we need to potentially handle unit conversions
            unit0    = Unit("m")*unit
            unit     = Unit(unit0.format().split()[-1])
            integral = unit0.convert(integral,unit)
        
        return Variable(data       = integral,
                        unit       = "%s" % unit,
                        name       = name,
                        time       = self.time,
                        time_bnds  = self.time_bnds,
                        lat        = self.lat,
                        lat_bnds   = self.lat_bnds,
                        lon        = self.lon,
                        lon_bnds   = self.lon_bnds,
                        area       = self.area,
                        ndata      = self.ndata)
    
    def integrateInSpace(self,region=None,mean=False,weight=None,intabs=False):
        r"""Integrates the variable over a given region.

        Uses nodal integration to integrate to approximate 

        .. math:: \int_{\Omega} v(\mathbf{x},\dots)\ d\Omega

        The arguments of the integrand reflect that while it must be
        at least defined in space, the remaining arguments are
        flexible. The variable :math:`\Omega` represents the desired
        region over which we will integrate. If no region is
        specified, the variable will be integrated over the extent of
        its spatial domain. If the mean function value over time is
        desired, this routine will approximate

        .. math:: \frac{1}{A(\Omega)} \int_{\Omega} v(\mathbf{x},\dots)\ d\Omega
        
        again by nodal integration. The spatial area which we divide
        by :math:`A(\Omega)` is the non-masked area of the given
        region, also given by

        .. math:: A(\Omega) = \int_{\Omega}\ d\Omega

        This means that if a function has some values masked or marked
        as invalid, we do not penalize the average value by including
        this as a point at which data is expected. 

        We also support the inclusion of an optional weighting
        function :math:`w(\mathbf{x})` which is a function of space
        only. In this case, we approximate the following integral

        .. math:: \int_{\Omega} v(\mathbf{x},\dots)w(\mathbf{x})\ d\Omega

        and if a mean value is desired, 

        .. math:: \frac{1}{\int_{\Omega} w(\mathbf{x})\ d\Omega} \int_{\Omega} v(\mathbf{x},\dots)w(\mathbf{x})\ d\Omega
        
        Parameters
        ----------
        region : str, optional
            name of the region overwhich you wish to integrate
        mean : bool, optional
            enable to divide the integrand to get the mean function value
        weight : numpy.ndarray, optional
            a data array of the same shape as this variable's areas
            representing an additional weight in the integrand
        intabs : bool, optional
            enable to integrate the absolute value 

        Returns
        -------
        integral : ILAMB.Variable.Variable
            a Variable instace with the integrated value along with the
            appropriate name and unit change.

        """
        def _integrate(var,areas):
            op = lambda x : x
            if intabs: op = np.abs
            assert var.shape[-2:] == areas.shape
            np.seterr(over='ignore',under='ignore')
            vbar = (op(var)*areas).sum(axis=-1).sum(axis=-1)
            np.seterr(over='raise',under='raise')
            return vbar

        if not self.spatial: raise il.NotSpatialVariable()

        # determine the measure
        mask = self.data.mask
        while mask.ndim > 2: mask = np.all(mask,axis=0)
        measure = np.ma.masked_array(self.area,mask=mask,copy=True)
        if weight is not None: measure *= weight

        # if we want to integrate over a region, we need add to the
        # measure's mask
        r = Regions()
        if region is not None: measure.mask += r.getMask(region,self)

        # approximate the integral
        integral = _integrate(self.data,measure)
        if mean:
            np.seterr(under='ignore')
            integral = integral / measure.sum()
            np.seterr(under='raise')

        # handle the name and unit
        name = self.name + "_integrated_over_space"
        if region is not None: name = name.replace("space",region)            
        unit = Unit(self.unit)
        if mean:
            
            # we have already divided thru by the non-masked area in
            # units of m^2, which are the same units of the integrand.
            name += "_and_divided_by_area"            
        else:
            
            # if not a mean, we need to potentially handle unit conversions
            unit0    = Unit("m2")*unit
            unit     = Unit(unit0.format().split()[-1])
            integral = unit0.convert(integral,unit)
            
        return Variable(data       = np.ma.masked_array(integral),
                        unit       = "%s" % unit,
                        time       = self.time,
                        time_bnds  = self.time_bnds,
                        depth      = self.depth,
                        depth_bnds = self.depth_bnds,
                        name       = name)

    def siteStats(self,region=None,weight=None,intabs=False):
        """Computes the mean and standard deviation of the variable over all data sites.

        Parameters
        ----------
        region : str, optional
            name of the region overwhich you wish to include stats.
        
        Returns
        -------
        mean : ILAMB.Variable.Variable
            a Variable instace with the mean values

        """
        if self.ndata is None: raise il.NotDatasiteVariable()
        op = lambda x : x
        if intabs: op = np.abs
        rem_mask = np.copy(self.data.mask)
        rname = ""
        r = Regions()
        if region is not None:
            self.data.mask += r.getMask(region,self)
            rname = "_over_%s" % region
        np.seterr(over='ignore',under='ignore')
        mean = np.ma.average(op(self.data),axis=-1,weights=weight)
        np.seterr(over='raise',under='raise')
        self.data.mask = rem_mask
        return Variable(data       = mean,
                        unit       = self.unit,
                        time       = self.time,
                        time_bnds  = self.time_bnds,
                        depth      = self.depth,
                        depth_bnds = self.depth_bnds,
                        name       = "mean_%s%s" % (self.name,rname))
    
    def annualCycle(self):
        """Computes mean annual cycle information (climatology) for the variable.
        
        For each site/cell/depth in the variable, compute the mean annual cycle.
        
        Returns
        -------
        mean : ILAMB.Variable.Variable
            The annual cycle mean values
        """
        if not self.temporal: raise il.NotTemporalVariable()
        assert self.monthly
        assert self.time.size > 11
        begin = np.argmin(self.time[:11]%365)
        end   = begin+int(self.time[begin:].size/12.)*12
        shp   = (-1,12) + self.data.shape[1:]
        v     = self.data[begin:end,...].reshape(shp)
        np.seterr(over='ignore',under='ignore')
        mean  = v.mean(axis=0)
        np.seterr(over='raise',under='raise')
        return Variable(data       = mean,
                        unit       = self.unit,
                        name       = "annual_cycle_mean_of_%s" % self.name,
                        time       = mid_months,
                        time_bnds  = np.asarray([bnd_months[:-1],bnd_months[1:]]).T,
                        lat        = self.lat,
                        lat_bnds   = self.lat_bnds,
                        lon        = self.lon,
                        lon_bnds   = self.lon_bnds,
                        area       = self.area,
                        depth      = self.depth,
                        depth_bnds = self.depth_bnds,
                        ndata      = self.ndata)

    def timeOfExtrema(self,etype="max"):
        """Returns the time of the specified extrema.
        
        Parameters
        ----------
        etype : str, optional
            The type of extrema to compute, either 'max' or 'min'

        Returns
        -------
        extrema : ILAMB.Variable.Variable
            The times of the extrema computed
        """
        if not self.temporal: raise il.NotTemporalVariable()
        fcn = {"max":np.argmax,"min":np.argmin}
        assert etype in fcn.keys()
        tid  = np.apply_along_axis(fcn[etype],0,self.data)
        mask = False
        if self.data.ndim > 1 and self.data.mask.ndim > 0: mask = np.apply_along_axis(np.all,0,self.data.mask) # mask cells where all data is masked
        data = np.ma.masked_array(self.time[tid],mask=mask)
        return Variable(data       = data,
                        unit       = "d",
                        name       = "time_of_%s_%s" % (etype,self.name),
                        lat        = self.lat,
                        lat_bnds   = self.lat_bnds,
                        lon        = self.lon,
                        lon_bnds   = self.lon_bnds,
                        area       = self.area,
                        depth      = self.depth,
                        depth_bnds = self.depth_bnds,
                        ndata      = self.ndata)

    def extractDatasites(self,lat,lon):
        """Extracts a variable at sites defined by a set of latitude and longitude.

        Parameters
        ----------
        lat : numpy.ndarray
            an array with the latitude values, must be same size as the longitude values
        lon : numpy.ndarray
            an array with the longitude values, must be same size as the latitude values

        Returns
        -------
        extracted : ILAMB.Variable.Variable
            The extracted variables
        """
        assert lat.size == lon.size
        if not self.spatial: raise il.NotSpatialVariable()
        ilat = np.apply_along_axis(np.argmin,1,np.abs(lat[:,np.newaxis]-self.lat))
        ilon = np.apply_along_axis(np.argmin,1,np.abs(lon[:,np.newaxis]-self.lon))
        ndata = lat.size
        if self.data.ndim == 2:
            data  = self.data[    ilat,ilon]
        else:
            data  = self.data[...,ilat,ilon]
        return Variable(data       = data,
                        unit       = self.unit,
                        name       = self.name,
                        lat        = lat,
                        lon        = lon,
                        ndata      = ndata,
                        depth      = self.depth,
                        depth_bnds = self.depth_bnds,
                        time       = self.time,
                        time_bnds  = self.time_bnds)
        
    def spatialDifference(self,var):
        """Computes the point-wise difference of two spatially defined variables.
        
        If the variable is spatial or site data and is defined on the
        same grid, this routine will simply compute the difference in
        the data arrays. If the variables are spatial but defined on
        separate grids, the routine will interpolate both variables to
        a composed grid via nearest-neighbor interpolation and then
        return the difference.

        Parameters
        ----------
        var : ILAMB.Variable.Variable
            The variable we wish to compare against this variable

        Returns
        -------
        diff : ILAMB.Variable.Variable
            A new variable object representing the difference
        """
        def _make_bnds(x):
            bnds       = np.zeros(x.size+1)
            bnds[1:-1] = 0.5*(x[1:]+x[:-1])
            bnds[0]    = max(x[0] -0.5*(x[ 1]-x[ 0]),-180)
            bnds[-1]   = min(x[-1]+0.5*(x[-1]-x[-2]),+180)
            return bnds
        assert Unit(var.unit) == Unit(self.unit)
        assert self.temporal == False
        assert self.ndata    == var.ndata
        assert self.layered  == False
        # Perform a check on the spatial grid. If it is the exact same
        # grid, there is no need to interpolate.
        same_grid = False
        try:
            same_grid = np.allclose(self.lat,var.lat)*np.allclose(self.lon,var.lon)
        except:
            pass
        
        if same_grid:
            error = np.ma.masked_array(var.data-self.data,mask=self.data.mask+var.data.mask)
            diff  = Variable(data      = error,
                             unit      = var.unit,
                             lat       = var.lat,
                             lat_bnds  = var.lat_bnds,
                             lon       = var.lon,
                             lon_bnds  = var.lon_bnds,
                             ndata     = var.ndata,
                             name      = "%s_minus_%s" % (var.name,self.name))
        else:
            if not self.spatial: raise il.NotSpatialVariable()
            lat_bnd1 = _make_bnds(self.lat)
            lon_bnd1 = _make_bnds(self.lon)
            lat_bnd2 = _make_bnds( var.lat)
            lon_bnd2 = _make_bnds( var.lon)
            lat_bnd,lon_bnd,lat,lon,error = il.TrueError(lat_bnd1,lon_bnd1,self.lat,self.lon,self.data,
                                                         lat_bnd2,lon_bnd2, var.lat, var.lon, var.data)
            diff = Variable(data      = error,
                            unit      = var.unit,
                            lat       = lat,
                            lat_bnd   = lat_bnd,
                            lon       = lon,
                            lon_bnd   = lon_bnd,
                            name      = "%s_minus_%s" % (var.name,self.name))
        return diff

    def convert(self,unit,density=998.2):
        """Convert the variable to a given unit.

        We use the UDUNITS library via the cf_units python interface to
        convert the variable's unit. Additional support is provided
        for unit conversions in which substance information is
        required. For example, in quantities such as precipitation it
        is common to have data in the form of a mass rate per unit
        area [kg s-1 m-2] yet desire it in a linear rate [m s-1]. This
        can be accomplished if the density of the substance is
        known. We assume here that water is the substance, but this
        can be changed by specifying the density when calling the
        function.

        Parameters
        ----------
        unit : str
            the desired converted unit
        density : float, optional
            the mass density in [kg m-3] to use when converting linear
            rates to area density rates
        
        Returns
        -------
        self : ILAMB.Variable.Variable
            this object with its unit converted

        """
        if unit is None: return self
        src_unit  = Unit(self.unit)
        tar_unit  = Unit(     unit)
        mask      = self.data.mask

        # Define some generic quantities
        linear            = Unit("m")
        linear_rate       = Unit("m s-1")
        area_density      = Unit("kg m-2")
        area_density_rate = Unit("kg m-2 s-1")
        mass_density      = Unit("kg m-3")
        volume_conc       = Unit("mol m-3")
        mass_conc         = Unit("mol kg-1")

        # UDUNITS doesn't handle frequently found temperature expressions
        synonyms = {"K":"degK",
                    "R":"degR",
                    "C":"degC",
                    "F":"degF"}
        for syn in synonyms.keys():
            if src_unit.format() == syn: src_unit = Unit(synonyms[syn])
            if tar_unit.format() == syn: tar_unit = Unit(synonyms[syn])
        
        # Do we need to multiply by density?
        if ( (src_unit.is_convertible(linear_rate) and tar_unit.is_convertible(area_density_rate)) or
             (src_unit.is_convertible(linear     ) and tar_unit.is_convertible(area_density     )) or
             (src_unit.is_convertible(mass_conc  ) and tar_unit.is_convertible(volume_conc      )) ):
            np.seterr(over='ignore',under='ignore')
            self.data *= density
            np.seterr(over='raise',under='raise')
            src_unit *= mass_density
            
        # Do we need to divide by density?
        if ( (tar_unit.is_convertible(linear_rate) and src_unit.is_convertible(area_density_rate)) or
             (tar_unit.is_convertible(linear     ) and src_unit.is_convertible(area_density     )) or
             (tar_unit.is_convertible(mass_conc  ) and src_unit.is_convertible(volume_conc      )) ):
            np.seterr(over='ignore',under='ignore')
            self.data = self.data / density
            np.seterr(over='raise',under='raise')
            src_unit = src_unit / mass_density
            
        # Convert units
        try:
            self.data = src_unit.convert(self.data,tar_unit)
            self.data = np.ma.masked_array(self.data,mask=mask)
            self.unit = unit
        except:
            raise il.UnitConversionError()
        return self
    
    def toNetCDF4(self,dataset,attributes=None,group=None):
        """Adds the variable to the specified netCDF4 dataset.

        Parameters
        ----------
        dataset : netCDF4.Dataset
            a dataset into which you wish to save this variable
        attributes : dict of scalars, optional
            a dictionary of additional scalars to encode as ncattrs
        group : str, optional
            the name of the netCDF4 group to to which we add this variable
        """
        def _checkTime(t,dset):
            """A local function for ensuring the time dimension is saved in the dataset."""
            time_name = "time"
            while True:
                if time_name in dset.dimensions.keys():
                    if (t.shape    == dset.variables[time_name][...].shape and
                        np.allclose(t,dset.variables[time_name][...],atol=0.5*self.dt)): 
                        return time_name
                    else:
                        time_name += "_"
                else:
                    dset.createDimension(time_name)
                    T = dset.createVariable(time_name,"double",(time_name))
                    T.setncattr("units","days since 1850-01-01 00:00:00")
                    T.setncattr("calendar","noleap")
                    T.setncattr("axis","T")
                    T.setncattr("long_name","time")
                    T.setncattr("standard_name","time")
                    T[...] = t
                    if self.time_bnds is not None:
                        bnd_name = time_name.replace("time","time_bnds")
                        T.setncattr("bounds",bnd_name)
                        if "nb" not in dset.dimensions.keys():
                            D = dset.createDimension("nb",size=2)
                        if bnd_name not in dset.variables.keys():
                            B = dset.createVariable(bnd_name,"double",(time_name,"nb"))
                            B.setncattr("units","days since 1850-01-01 00:00:00")
                            B[...] = self.time_bnds                    
                    return time_name

        def _checkLat(lat,dset):
            """A local function for ensuring the lat dimension is saved in the dataset."""
            lat_name = "lat"
            while True:
                if lat_name in dset.dimensions.keys():
                    if (lat.shape == dset.variables[lat_name][...].shape and
                        np.allclose(lat,dset.variables[lat_name][...])): 
                        return lat_name
                    else:
                        lat_name += "_"
                else:
                    dset.createDimension(lat_name,size=lat.size)
                    Y = dset.createVariable(lat_name,"double",(lat_name))
                    Y.setncattr("units","degrees_north")
                    Y.setncattr("axis","Y")
                    Y.setncattr("long_name","latitude")
                    Y.setncattr("standard_name","latitude")
                    Y[...] = lat
                    if self.lat_bnds is not None:
                        bnd_name = lat_name.replace("lat","lat_bnds")
                        Y.setncattr("bounds",bnd_name)
                        if "nb" not in dset.dimensions.keys():
                            D = dset.createDimension("nb",size=2)
                        if bnd_name not in dset.variables.keys():
                            B = dset.createVariable(bnd_name,"double",(lat_name,"nb"))
                            B.setncattr("units","degrees_north")
                            B[...] = self.lat_bnds
                    return lat_name

        def _checkLon(lon,dset):
            """A local function for ensuring the lon dimension is saved in the dataset."""
            lon_name = "lon"
            while True:
                if lon_name in dset.dimensions.keys():
                    if (lon.shape == dset.variables[lon_name][...].shape and
                    np.allclose(lon,dset.variables[lon_name][...])): 
                        return lon_name
                    else:
                        lon_name += "_"
                else:
                    dset.createDimension(lon_name,size=lon.size)
                    X = dset.createVariable(lon_name,"double",(lon_name))
                    X.setncattr("units","degrees_east")
                    X.setncattr("axis","X")
                    X.setncattr("long_name","longitude")
                    X.setncattr("standard_name","longitude")
                    X[...] = lon
                    if self.lon_bnds is not None:
                        bnd_name = lon_name.replace("lon","lon_bnds")
                        X.setncattr("bounds",bnd_name)
                        if "nb" not in dset.dimensions.keys():
                            D = dset.createDimension("nb",size=2)
                        if bnd_name not in dset.variables.keys():
                            B = dset.createVariable(bnd_name,"double",(lon_name,"nb"))
                            B.setncattr("units","degrees_east")
                            B[...] = self.lon_bnds
                    return lon_name

        def _checkData(ndata,dset):
            """A local function for ensuring the data dimension is saved in the dataset."""
            data_name = "data"
            while True:
                if data_name in dset.dimensions.keys():
                    if (ndata == len(dset.dimensions[data_name])): 
                        return data_name
                    else:
                        data_name += "_"
                else:
                    dset.createDimension(data_name,size=ndata)
                    return data_name

        def _checkLayer(layer,dataset):
            """A local function for ensuring the layer dimension is saved in the dataset."""
            layer_name = "layer"
            while True:
                if layer_name in dataset.dimensions.keys():
                    if (layer.shape == dataset.variables[layer_name][...].shape and
                    np.allclose(layer,dataset.variables[layer_name][...])): 
                        return layer_name
                    else:
                        layer_name += "_"
                else:
                    dataset.createDimension(layer_name,size=layer.size)
                    Z = dataset.createVariable(layer_name,"double",(layer_name))
                    Z.setncattr("units","m")
                    Z.setncattr("axis","Z")
                    Z.setncattr("long_name","depth")
                    Z.setncattr("standard_name","depth")
                    Z[...] = layer
                    if self.depth_bnds is not None:
                        bnd_name = layer_name.replace("layer","layer_bnds")
                        Z.setncattr("bounds",bnd_name)
                        if "nb" not in dataset.dimensions.keys():
                            D = dataset.createDimension("nb",size=2)
                        if bnd_name not in dataset.variables.keys():
                            B = dataset.createVariable(bnd_name,"double",(layer_name,"nb"))
                            B.setncattr("units","m")
                            B[...] = self.depth_bnds                    
                    return layer_name
        
        # if not group is desired, just write to the dataset...
        if group is None:
            dset = dataset
        else:
            # if a group is desired, check to see it exists and write into group
            if not dataset.groups.has_key(group):
                dset = dataset.createGroup(group)
            else:
                dset = dataset.groups[group]
                
        dim = []
        if self.temporal: dim.append(_checkTime (self.time ,dset))
        if self.layered:  dim.append(_checkLayer(self.depth,dset))
        if self.ndata is not None:
            dim.append(_checkData (self.ndata,dset))
            _checkLat(self.lat,dset)
            _checkLon(self.lon,dset)
        else:
            if self.lat is not None: dim.append(_checkLat  (self.lat  ,dset))
            if self.lon is not None: dim.append(_checkLon  (self.lon  ,dset))

        grp = dset
        if self.data.size == 1:
            if not dset.groups.has_key("scalars"):
                grp = dset.createGroup("scalars")
            else:
                grp = dset.groups["scalars"]

        V = grp.createVariable(self.name,"double",dim,zlib=True)
        V.setncattr("units",self.unit)
        try:
            V.setncattr("max",self.data.max())
            V.setncattr("min",self.data.min())
        except:
            V.setncattr("max",0)
            V.setncattr("min",1)
            
        if self.data.size == 1:
            # we are dealing with a scalar
            if np.ma.is_masked(self.data): self.data = 0
        else:
            # not a scalar, find the middle 98 percent of the data
            data = np.ma.copy(self.data).compressed().reshape((-1))
            if data.size == 0:
                V.setncattr("up99",1)
                V.setncattr("dn99",0)
            else:
                data.sort()
                V.setncattr("up99",data[min(int(round(0.99*data.size)),data.size-1)])
                V.setncattr("dn99",data[    int(round(0.01*data.size))])
            
        # optionally write out more attributes
        if attributes:
            for key in attributes.keys():
                V.setncattr(key,attributes[key])
            
        if type(self.data) is np.ma.core.MaskedConstant:
            V[...] = np.nan
        else:
            V[...] = self.data

    def plot(self,ax,**keywords):
        """Plots the variable on the given matplotlib axis.

        The behavior of this routine depends on the type of variable
        specified. If the data is purely temporal, then the plot will
        be a scatter plot versus time of the data. If it is purely
        spatial, then the plot will be a global plot of the data. The
        routine supports multiple keywords although some may not apply
        to the type of plot being generated.

        Parameters
        ----------
        ax : matplotlib.axes._subplots.AxesSubplot
            The matplotlib axes object onto which you wish to plot the variable
        lw : float, optional
            The line width to use when plotting
        alpha : float, optional
            The degree of transparency when plotting, alpha \in [0,1]
        color : str or RGB tuple, optional
            The color to plot with in line plots
        label : str, optional
            The label to appear in the legend of line plots
        vmin : float, optional
            The minimum plotted value
        vmax : float, optional
            The maximum plotted value
        region : str, optional
            The region on which to display a spatial variable
        cmap : str, optional
            The name of the colormap to be used in plotting the spatial variable
        ticks : array of floats, optional
            Defines the locations of xtick
        ticklabels : array of strings, optional
            Defines the labels of the xticks
        """
        lw     = keywords.get("lw"    ,1.0)
        alpha  = keywords.get("alpha" ,1.0)
        color  = keywords.get("color" ,"k")
        label  = keywords.get("label" ,None)
        vmin   = keywords.get("vmin"  ,self.data.min())
        vmax   = keywords.get("vmax"  ,self.data.max())
        region = keywords.get("region","global")
        cmap   = keywords.get("cmap"  ,"jet")
        land   = keywords.get("land"  ,0.875)
        water  = keywords.get("water" ,0.750)
        pad    = keywords.get("pad"   ,5.0)
        cbar   = keywords.get("cbar"  ,False)
        
        rem_mask = None
        r = Regions()
        if self.temporal and not self.spatial:
            
            ticks      = keywords.get("ticks",None)
            ticklabels = keywords.get("ticklabels",None)
            t          = self.time/365.+1850
            ax.plot(t,self.data,'-',
                    color = color,
                    lw    = lw,
                    alpha = alpha,
                    label = label)
            if ticks      is not None: ax.set_xticks(ticks)
            if ticklabels is not None: ax.set_xticklabels(ticklabels)
            ax.grid('on')
            ax.set_ylim(vmin,vmax)
            
        elif not self.temporal:

            # Mask out areas outside our region
            rem_mask  = np.copy(self.data.mask)
            self.data.mask += r.getMask(region,self)
            
            # Find the figure geometry
            if self.ndata:
                LAT = np.ma.masked_array(self.lat,mask=self.data.mask,copy=True)
                LON = np.ma.masked_array(self.lon,mask=self.data.mask,copy=True)
                dateline = False
            else:
                LAT,LON = np.meshgrid(self.lat,self.lon,indexing='ij')
                LAT = np.ma.masked_array(LAT,mask=self.data.mask,copy=False)
                LON = np.ma.masked_array(LON,mask=self.data.mask,copy=False)
                    
            lat0 = LAT.min() ; latf = LAT.max()
            lon0 = LON.min() ; lonf = LON.max()
            latm = LAT.mean(); lonm = LON.mean()
            area = (latf-lat0)*(lonf-lon0)
                
            # Setup the plot projection depending on data limits
            bmap = Basemap(projection = 'robin',
                           lon_0      = 0,
                           ax         = ax,
                           resolution = 'c')
            if (lon0 < -170.) and (lonf > 170.):
                if lat0 > 23.5:
                    bmap = Basemap(projection  = 'npstere',
                                   boundinglat = lat0-5.,
                                   lon_0       = 0.,
                                   ax          = ax,
                                   resolution  = 'c')
                elif latf < -23.5:
                    bmap = Basemap(projection  = 'spstere',
                                   boundinglat = latf+5.,
                                   lon_0       = 180.,
                                   ax          = ax,
                                   resolution  = 'c')
            else:
                if area < 10000.:
                    bmap = Basemap(projection = 'cyl',
                                   llcrnrlon  = lon0-2*pad,
                                   llcrnrlat  = lat0-  pad,
                                   urcrnrlon  = lonf+2*pad,
                                   urcrnrlat  = latf+  pad,
                                   ax         = ax,
                                   resolution = 'c')
            try:
                bmap.drawlsmask(land_color  = str(land),
                                ocean_color = str(water),
                                lakes       = True)
            except:
                bmap.drawcoastlines(linewidth = 0.2,
                                    color     = "darkslategrey")

            if self.spatial:
                LAT,LON = np.meshgrid(self.lat,self.lon,indexing='ij')
                ax = bmap.pcolormesh(LON,LAT,self.data,
                                     latlon=True,vmin=vmin,vmax=vmax,cmap=cmap)
            elif self.ndata is not None:
                x,y  = bmap(self.lon[self.data.mask==False],
                            self.lat[self.data.mask==False])
                data = self.data[self.data.mask==False]
                norm = colors.Normalize(vmin,vmax)
                norm = norm(data)
                clmp = get_cmap(cmap)
                clrs = clmp(norm)
                size = 35
                ax   = bmap.scatter(x,y,s=size,color=clrs,ax=ax,linewidths=0,cmap=cmap)
            if cbar:
                cb = bmap.colorbar(ax,location='bottom',pad="5%")
                if label is not None: cb.set_label(label)
            if rem_mask is not None: self.data.mask = rem_mask
        return ax
    

    def interpolate(self,time=None,lat=None,lon=None,lat_bnds=None,lon_bnds=None,itype='nearestneighbor'):
        """Use nearest-neighbor interpolation to interpolate time and/or space at given values.

        Parameters
        ----------
        time : numpy.ndarray, optional
            Array of times at which to interpolate the variable
        lat : numpy.ndarray, optional
            Array of latitudes at which to interpolate the variable
        lon : numpy.ndarray, optional
            Array of longitudes at which to interpolate the variable

        Returns
        -------
        var : ILAMB.Variable.Variable
            The interpolated variable
        """
        if time is None and lat is None and lon is None: return self
        output_time = self.time      if (time is None) else time
        output_tbnd = self.time_bnds if (time is None) else None
        output_lat  = self.lat       if (lat  is None) else lat
        output_lon  = self.lon       if (lon  is None) else lon
        output_area = self.area      if (lat  is None and lon is None) else None
        
        data = self.data
        if self.spatial and (lat is not None or lon is not None):
            if lat is None: lat = self.lat
            if lon is None: lon = self.lon
            if itype == 'nearestneighbor':
                rows  = (np.abs(lat[:,np.newaxis]-self.lat)).argmin(axis=1)
                cols  = (np.abs(lon[:,np.newaxis]-self.lon)).argmin(axis=1)
                args  = []
                if self.temporal: args.append(range(self.time.size))
                if self.layered:  args.append(range(self.depth.size))
                args.append(rows)
                args.append(cols)
                ind   = np.ix_(*args)
                mask  = data.mask[ind]
                data  = data.data[ind]
                data  = np.ma.masked_array(data,mask=mask)
                frac  = self.area / il.CellAreas(self.lat,self.lon,self.lat_bnds,self.lon_bnds).clip(1e-12)
                frac  = frac.clip(0,1)
                frac  = frac[np.ix_(rows,cols)]
                output_area = frac * il.CellAreas(lat,lon,lat_bnds,lon_bnds)
            elif itype == 'bilinear':
                from scipy.interpolate import RectBivariateSpline
                if self.data.ndim == 3:
                    halo = il.LandLinInterMissingValues(self.data)
                    data = np.ma.zeros((self.data.shape[:-2]+(lat.size,lon.size)))
                    for i in range(self.data.shape[0]):
                        dint = RectBivariateSpline(self.lat,self.lon,     halo[i,...],     kx=1,ky=1)
                        mint = RectBivariateSpline(self.lat,self.lon,self.data[i,...].mask,kx=1,ky=1)
                        data[i,...] = np.ma.masked_array(dint(lat,lon,grid=True),
                                                         mint(lat,lon,grid=True)>0.5)
                frac  = self.area / il.CellAreas(self.lat,self.lon).clip(1e-12)
                frac  = frac.clip(0,1)
                frac  = RectBivariateSpline(self.lat,self.lon,frac,kx=1,ky=1)
                output_area = frac(lat,lon,grid=True) * il.CellAreas(lat,lon)
            else:
                raise ValueError("Uknown interpolation type: %s" % itype)
        if self.temporal and time is not None:
            times = np.apply_along_axis(np.argmin,1,np.abs(time[:,np.newaxis]-self.time))
            mask  = data.mask
            if mask.size > 1: mask = data.mask[times,...]
            data  = data.data[times,...]
            data  = np.ma.masked_array(data,mask=mask)
            output_tbnd = self.time_bnds[times]
        return Variable(data = data, unit = self.unit, name = self.name, ndata = self.ndata,
                        lat  = output_lat,
                        lon  = output_lon,
                        area = output_area,
                        time = output_time,
                        time_bnds = output_tbnd)

    def phaseShift(self,var,method="max_of_annual_cycle"):
        """Computes the phase shift between a variable and this variable.
        
        Finds the phase shift as the time between extrema of the
        annual cycles of the variables. Note that if this var and/or
        the given variable are not already annual cycles, they will be
        computed but not returned. 

        Parameters
        ----------
        var : ILAMB.Variable.Variable
            The variable with which we will measure phase shift
        method : str, optional
            The name of the method used to compute the phase shift

        """
        assert method in ["max_of_annual_cycle","min_of_annual_cycle"]
        assert self.temporal == var.temporal
        v1 = self; v2 = var
        if not self.temporal:
            # If the data is not temporal, then the user may have
            # already found the extrema. If the units of the input
            # variable are days, then set the extrema to this data.
            if not (self.unit == "d" and var.unit == "d"): raise il.NotTemporalVariable
            e1 = v1
            e2 = v2
        else:
            # While temporal, the user may have passed in the mean
            # annual cycle as the variable. So if the leading
            # dimension is 12 we assume the variables are already the
            # annual cycles. If not, we compute the cycles and then
            # compute the extrema.
            if self.time.size != 12: v1 = self.annualCycle()
            if  var.time.size != 12: v2 = var .annualCycle()
            e1 = v1.timeOfExtrema(etype=method[:3])
            e2 = v2.timeOfExtrema(etype=method[:3])
        if e1.spatial:
            shift = e1.spatialDifference(e2)
        else:
            data  = e2.data      - e1.data
            mask  = e1.data.mask + e2.data.mask
            shift = Variable(data=data,unit=e1.unit,ndata=e1.ndata,lat=e1.lat,lon=e1.lon)
        shift.name = "phase_shift_of_%s" % e1.name
        shift.data += (shift.data < -0.5*365.)*365.
        shift.data -= (shift.data > +0.5*365.)*365.
        return shift
    
    def correlation(self,var,ctype,region=None):
        """Computes the correlation between two variables.

        Parameters
        ----------
        var : ILAMB.Variable.Variable
            The variable with which we will compute a correlation
        ctype : str
            The correlation type, one of {"spatial","temporal","spatiotemporal"}
        region : str, optional
            The region over which to perform a spatial correlation

        Notes 
        ----- 
        Need to better think about what correlation means when data
        are masked. The sums ignore the data but then the number of
        items *n* is not constant and should be reduced for masked
        values.

        """
        def _correlation(x,y,axes=None):
            if axes is None: axes = range(x.ndim)
            if type(axes) == int: axes = (int(axes),)
            axes = tuple(axes)
            n    = 1
            for ax in axes: n *= x.shape[ax]
            xbar = x.sum(axis=axes)/n # because np.mean() doesn't take axes which are tuples
            ybar = y.sum(axis=axes)/n
            xy   = (x*y).sum(axis=axes)
            x2   = (x*x).sum(axis=axes)
            y2   = (y*y).sum(axis=axes)
            try:
                r = (xy-n*xbar*ybar)/(np.sqrt(x2-n*xbar*xbar)*np.sqrt(y2-n*ybar*ybar))
            except:
                r = np.nan
            return r
        
        # checks on data consistency
        assert region is None
        assert self.data.shape == var.data.shape
        assert ctype in ["spatial","temporal","spatiotemporal"]

        # determine arguments for functions
        axes      = None
        out_time  = None
        out_lat   = None
        out_lon   = None
        out_area  = None
        out_ndata = None
        if ctype == "temporal":
            axes = 0
            if self.spatial:
                out_lat   = self.lat
                out_lon   = self.lon
                out_area  = self.area
            elif self.ndata:
                out_ndata = self.ndata
        elif ctype == "spatial":
            if self.spatial:  axes     = range(self.data.ndim)[-2:]
            if self.ndata:    axes     = self.data.ndim-1
            if self.temporal: out_time = self.time
        out_time_bnds = None
        if out_time is not None: out_time_bnds = self.time_bnds
        r = _correlation(self.data,var.data,axes=axes)
        return Variable(data=r,unit="1",
                        name="%s_correlation_of_%s" % (ctype,self.name),
                        time=out_time,time_bnds=out_time_bnds,ndata=out_ndata,
                        lat=out_lat,lon=out_lon,area=out_area)
    
    def bias(self,var):
        """Computes the bias between a given variable and this variable.

        Parameters
        ----------
        var : ILAMB.Variable.Variable
            The variable with which we will measure bias

        Returns
        -------
        bias : ILAMB.Variable.Variable
            the bias
        """
        # If not a temporal variable, then we assume that the user is
        # passing in mean data and return the difference.
        lat,lon,area = self.lat,self.lon,self.area
        if not self.temporal:
            assert self.temporal == var.temporal
            bias = self.spatialDifference(var)
            bias.name = "bias_of_%s" % self.name
            return bias
        if self.spatial:
            # If the data is spatial, then we interpolate it on a
            # common grid and take the difference.

            same_grid = False
            try:
                same_grid = np.allclose(self.lat,var.lat)*np.allclose(self.lon,var.lon)
            except:
                pass
            if not same_grid:
                lat,lon  = il.ComposeSpatialGrids(self,var)
                area     = None
                self_int = self.interpolate(lat=lat,lon=lon)
                var_int  = var .interpolate(lat=lat,lon=lon)
                data     = var_int.data-self_int.data
                mask     = var_int.data.mask+self_int.data.mask
            else:
                data     = var.data     -self.data
                mask     = var.data.mask+self.data.mask

        elif (self.ndata or self.time.size == self.data.size):
            # If the data are at sites, then take the difference
            data = var.data.data-self.data.data
            mask = var.data.mask+self.data.mask
        else:
            raise il.NotSpatialVariable("Cannot take bias of scalars")
        # Finally we return the temporal mean of the difference
        bias = Variable(data=np.ma.masked_array(data,mask=mask),
                        name="bias_of_%s" % self.name,time=self.time,time_bnds=self.time_bnds,
                        unit=self.unit,ndata=self.ndata,
                        lat=lat,lon=lon,area=area,
                        depth_bnds = self.depth_bnds).integrateInTime(mean=True)
        bias.name = bias.name.replace("_integrated_over_time_and_divided_by_time_period","")
        return bias
    
    def rmse(self,var):
        """Computes the RMSE between a given variable and this variable.

        Parameters
        ----------
        var : ILAMB.Variable.Variable
            The variable with which we will measure RMSE

        Returns
        -------
        RMSE : ILAMB.Variable.Variable
            the RMSE

        """
        # If not a temporal variable, then we assume that the user is
        # passing in mean data and return the difference.
        lat,lon,area = self.lat,self.lon,self.area
        if not self.temporal:
            assert self.temporal == var.temporal
            rmse = self.spatialDifference(var)
            rmse.name = "rmse_of_%s" % self.name
            return rmse
        if self.spatial:
            # If the data is spatial, then we interpolate it on a
            # common grid and take the difference.
            same_grid = False
            try:
                same_grid = np.allclose(self.lat,var.lat)*np.allclose(self.lon,var.lon)
            except:
                pass
            if not same_grid:
                lat,lon  = il.ComposeSpatialGrids(self,var)
                area     = None
                self_int = self.interpolate(lat=lat,lon=lon)
                var_int  = var .interpolate(lat=lat,lon=lon)
                data     = var_int.data-self_int.data
                mask     = var_int.data.mask+self_int.data.mask
            else:
                data     = var.data     -self.data
                mask     = var.data.mask+self.data.mask
        elif (self.ndata or self.time.size == self.data.size):
            # If the data are at sites, then take the difference
            data = var.data.data-self.data.data
            mask = var.data.mask+self.data.mask
        else:
            raise il.NotSpatialVariable("Cannot take rmse of scalars")
        # Finally we return the temporal mean of the difference squared
        np.seterr(over='ignore',under='ignore')
        data *= data
        np.seterr(over='raise',under='raise')
        rmse = Variable(data=np.ma.masked_array(data,mask=mask),
                        name="rmse_of_%s" % self.name,time=self.time,time_bnds=self.time_bnds,
                        unit=self.unit,ndata=self.ndata,
                        lat=lat,lon=lon,area=area,
                        depth_bnds = self.depth_bnds).integrateInTime(mean=True)
        rmse.name = rmse.name.replace("_integrated_over_time_and_divided_by_time_period","")
        rmse.data = np.sqrt(rmse.data)
        return rmse

    def rms(self):
        """Computes the RMS of this variable.

        Returns
        -------
        RMS : ILAMB.Variable.Variable
            the RMS

        """
        if not self.temporal: raise il.NotTemporalVariable()
        unit = self.unit
        np.seterr(over='ignore',under='ignore')
        data = self.data**2
        np.seterr(over='raise',under='raise')        
        rms  = Variable(data  = data,
                        unit  = "1",    # will change later
                        name  = "tmp",  # will change later
                        ndata = self.ndata,
                        lat   = self.lat,
                        lon   = self.lon,
                        area  = self.area,
                        time  = self.time).integrateInTime(mean=True)
        np.seterr(over='ignore',under='ignore')
        rms.data = np.sqrt(rms.data)
        np.seterr(over='raise',under='raise')
        rms.unit = unit
        rms.name = "rms_of_%s" % self.name
        return rms
    
    def interannualVariability(self):
        """Computes the interannual variability.

        The internannual variability in this case is defined as the
        standard deviation of the data in the temporal dimension.

        Returns
        -------
        iav : ILAMB.Variable.Variable
            the interannual variability variable
        """
        if not self.temporal: raise il.NotTemporalVariable
        np.seterr(over='ignore',under='ignore')
        data = self.data.std(axis=0)
        np.seterr(over='raise',under='raise')
        return Variable(data=data,
                        name="iav_of_%s" % self.name,
                        unit=self.unit,ndata=self.ndata,
                        lat=self.lat,lon=self.lon,area=self.area,
                        depth_bnds = self.depth_bnds)

    def spatialDistribution(self,var,region="global"):
        r"""Evaluates how well the input variable is spatially distributed relative to this variable.
        
        This routine returns the normalized standard deviation and
        correlation (needed for a Taylor plot) as well as a score
        given as

        .. math:: \frac{4(1+R)}{((\sigma+\frac{1}{\sigma})^2 (1+R_0))}

        where :math:`R` is the correlation, :math:`R_0=1` is the
        reference correlation, and :math:`\sigma` is the normalized
        standard deviation.

        Parameters
        ----------
        var : ILAMB.Variable.Variable
            the comparison variable
        region : str, optional
            the name of the region over which to check the spatial distribution
        
        Returns
        -------
        std : ILAMB.Variable.Variable
            the normalized standard deviation of the input variable
        R : ILAMB.Variable.Variable
            the correlation of the input variable
        score : ILAMB.Variable.Variable
            the spatial distribution score

        """
        assert self.temporal == var.temporal == False

        r = Regions()
        
        # First compute the observational spatial/site standard deviation
        rem_mask0  = np.copy(self.data.mask)
        self.data.mask += r.getMask(region,self)
            
        np.seterr(over='ignore',under='ignore')
        std0 = self.data.std()
        np.seterr(over='raise',under='raise')

        # Next compute the model spatial/site standard deviation
        rem_mask  = np.copy(var.data.mask)
        var.data.mask += r.getMask(region,var)

        np.seterr(over='ignore',under='ignore')
        std = var.data.std()
        np.seterr(over='raise',under='raise')

        # Interpolate to new grid for correlation
        if self.spatial:
            lat,lon  = il.ComposeSpatialGrids(self,var)
            self_int = self.interpolate(lat=lat,lon=lon)
            var_int  = var .interpolate(lat=lat,lon=lon)
        else:
            self_int = self
            var_int  = var
        R   = self_int.correlation(var_int,ctype="spatial") # add regions
        if type(R.data) is np.ma.core.MaskedConstant: R.data = 0.
        
        # Restore masks
        self.data.mask = rem_mask0
        var.data.mask  = rem_mask

        # Put together scores, we clip the standard deviation of both
        # variables at the same small amount, meant to avoid division
        # by zero errors.
        try:
            R0    = 1.0
            std0  = std0.clip(1e-12)
            std   = std .clip(1e-12)
            std   = std/std0
            score = 4.0*(1.0+R.data)/((std+1.0/std)**2 *(1.0+R0))
        except:
            std   = np.asarray([0.0])
            score = np.asarray([0.0])
        std   = Variable(data=std  ,name="normalized_spatial_std_of_%s_over_%s" % (self.name,region),unit="1")
        score = Variable(data=score,name="spatial_distribution_score_of_%s_over_%s" % (self.name,region),unit="1")
        return std,R,score

    def coarsenInTime(self,intervals,window=0.):
        """Compute the mean function value in each of the input intervals.

        Parameters
        ----------
        intervals : array of shape (n,2) 
            An array of n intervals where the first entry is the
            beginning and the second entry is the end of the interval
        window : float, optional
            Extend each interval before and after by this amount of time

        Returns
        -------
        coarse : ILAMB.Variable.Variable
            The coarsened variable
        """
        if not self.temporal: raise il.NotTemporalVariable
        assert intervals.ndim == 2
        n    = intervals.shape[0]
        shp  = (n,)+self.data.shape[1:]
        time = np.zeros(n)
        data = np.ma.zeros(shp)
        for i in range(n):
            t0          = intervals[i,0]-window
            tf          = intervals[i,1]+window
            time[i]     = 0.5*(t0+tf)
            mean        = self.integrateInTime(mean=True,t0=t0,tf=tf).convert(self.unit)
            data[i,...] = mean.data
        return Variable(name       = "coarsened_%s" % self.name,
                        unit       = self.unit,
                        time       = time,
                        time_bnds  = intervals,
                        data       = data,
                        ndata      = self.ndata,
                        lat        = self.lat,
                        lon        = self.lon,
                        area       = self.area,
                        depth_bnds = self.depth_bnds)
        
    def accumulateInTime(self):
        r"""For each time interval, accumulate variable from the beginning.

        For each time interval :math:`i` in the variable, defined by
        :math:`[t_0^i,t_f^i]`, compute
        
        .. math:: \int_{t_0^0}^{t_f^i} v(t,\dots)\ dt

        This routine is useful, for example, if the variable is a mass
        rate defined over time and we wish to know the mass
        accumulation as a function of time.

        Returns
        -------
        sum : ILAMB.Variable.Variable
            The cumulative sum of this variable

        """
        if not self.temporal: raise il.NotTemporalVariable
        n       = self.time.size
        shp     = (n+1,) + self.data.shape[1:]
        time    = np.zeros(n+1)
        data    = np.ma.zeros(shp)
        time[0] = self.time_bnds[0,0]
        for i in range(n):
            t0   = self.time_bnds[i,0]
            tf   = self.time_bnds[i,1]
            isum = self.integrateInTime(t0=t0,tf=tf)
            time[i+1]     = tf
            data[i+1,...] = data[i,...] + isum.data

        return Variable(name      = "cumulative_sum_%s" % self.name,
                        unit      = isum.unit,
                        time      = time,
                        data      = data,
                        lat       = self.lat,
                        lon       = self.lon,
                        area      = self.area)

    
    def trim(self,lat=None,lon=None,t=None,d=None):
        """Trim away a variable in space/time in place.

        Parameters
        ----------
        lat,lon,t,d : tuple or list
            a 2-tuple containing the lower and upper limits beyond which we trim
        """
        def _whichInterval(val,bnds):
            ind = np.where((val>=bnds[:,0])*(val<=bnds[:,1]))[0]
            assert ind.size <= 2
            ind = ind[0]
            return ind
            
        if lat is not None:
            assert len(lat) == 2
            if not self.spatial: raise il.NotSpatialVariable
            i = _whichInterval(lat[0],self.lat_bnds)
            j = _whichInterval(lat[1],self.lat_bnds)+1
            self.lat      = self.lat     [i:j]
            self.lat_bnds = self.lat_bnds[i:j]
            self.data     = self.data[...,i:j,:]
            self.area     = self.area[    i:j,:]
        if lon is not None:
            assert len(lon) == 2
            if not self.spatial: raise il.NotSpatialVariable
            i = _whichInterval(lon[0],self.lon_bnds)
            j = _whichInterval(lon[1],self.lon_bnds)+1
            self.lon      = self.lon     [i:j]
            self.lon_bnds = self.lon_bnds[i:j]
            self.data     = self.data[...,i:j]
            self.area     = self.area[  :,i:j]
        if t is not None:
            assert len(t) == 2
            if not self.temporal: raise il.NotTemporalVariable
            self = il.ClipTime(self,t[0],t[1])
        if d is not None:
            assert len(d) == 2
            if self.depth_bnds is None: raise ValueError
            keep = (self.depth_bnds[:,1] >= d[0])*(self.depth_bnds[:,0] <= d[1])
            ind  = np.where(keep)[0]
            self.depth_bnds = self.depth_bnds[ind,:]
            self.depth      = self.depth     [ind  ]
            self.data       = self.data[...,ind,:,:]
            
        return self
