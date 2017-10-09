Formatting a Benchmark Dataset
==============================

The ILAMB system is designed to accept files in the form of netCDF4
datasets which follow the `CF Conventions
<http://cfconventions.org/>`_. These conventions define metadata that
provide a definitive description of what the data in each variable
represents, and the spatial and temporal properties of the data. This
enables ILAMB to decide how to create a commensurate quantity from a
model's output results.

While it is sufficient to follow the CF conventions when building your
observational dataset, ILAMB does not rigidly require full adherence
to this standard. That is to say, it is only necessary to have some of
the required fields and attributes. In this tutorial we will
demonstrate encoding a few demonstration files using python. However,
the samples only demonstrate what is needed for ILAMB to function and
can be replicated using other tools (i.e. Matlab, NCL).

Globally gridded data
---------------------

In this sample we will create a random variable representing monthly
mean values from 1950-1960 on a 2 degree global grid. First we open a
dataset for writing and then create the time dimension data.

.. code-block:: python
   
    from netCDF4 import Dataset
    import numpy as np

    # Open a dataset for writing
    dset = Dataset("global_sample.nc",mode="w")

    # Create temporal dimension
    nyears    = 10
    month_bnd = np.asarray([0,31,59,90,120,151,181,212,243,273,304,334,365],dtype=float)
    tbnd  = np.asarray([((np.arange(nyears)*365)[:,np.newaxis]+month_bnd[:-1]).flatten(),
                        ((np.arange(nyears)*365)[:,np.newaxis]+month_bnd[+1:]).flatten()]).T
    tbnd += (1950-1850)*365
    t     = tbnd.mean(axis=1)

While the ``numpy`` portion of this code may be confusing, in concept
we are creating a ``tbnd`` array with a shape ``(120,2)`` which
contains the beginning and ending day of each month from 1950
to 1960. Subsequently we compute a time array ``t`` of shape ``(120)``
as the mean value between each of these bounds.

Encoding the bounds of the time dimension is an important part of
creating the dataset for ILAMB. Many modeling centers have different
conventions as to where a given ``t`` is reported relative to the
interval ``tbnd``. By specifying the time bounds, ILAMB can precisely
match model output to the correct time interval.

Consider encoding the time dimension even if your data is only
spatial. Many times the observational data we have may be a sparse
collection of points across a decade of observations. We mean to
compare these observations to a mean of the model result across some
time span. In this case, you can build a ``tbnd`` array of shape
``(1,2)`` where the bounds defines the span across which it is
appropriate to compare models. When ILAMB reads in this dataset, it
will detect a mistmatch is the temporal resolution of the model output
and your observational dataset and automatically coarsen the model
output across the specified time bounds.

Now we move on to the spatial grid and the data itself.

.. code-block:: python
    
    # Create spatial dimension
    res    = 2.
    latbnd = np.asarray([np.arange(- 90    , 90     ,res),
                         np.arange(- 90+res, 90+0.01,res)]).T
    lonbnd = np.asarray([np.arange(-180    ,180     ,res),
                         np.arange(-180+res,180+0.01,res)]).T
    lat    = latbnd.mean(axis=1)
    lon    = lonbnd.mean(axis=1)

    # Create some fake data
    data    = np.ma.masked_array(np.random.rand(t.size,lat.size,lon.size))

In this case we again use ``numpy`` to create bounding arrays for the
latitude and longitude. As with the temporal dimension, this is
preferred as it removes ambiguity and improves the accuracy which
ILAMB can deliver. The fake data here is just full of random numbers
in this case with no mask. Normally this data would come from some
other source. This is typically the most time consuming part of the
dataset creation process as data providers seldom provide their
datasets in netCDF format.

Once you have all the information in memory, then we turn to encoding
the netCDF4 file. First we create all the dimensions and variables we
will use. For more information on these functions, consult the
`netcdf4-python <http://unidata.github.io/netcdf4-python/>`_
documentation.
    
.. code-block:: python
    
    # Create netCDF dimensions
    dset.createDimension("time",size=  t.size)
    dset.createDimension("lat" ,size=lat.size)
    dset.createDimension("lon" ,size=lon.size)
    dset.createDimension("nb"  ,size=2       )

    # Create netCDF variables
    T  = dset.createVariable("time"       ,t.dtype   ,("time"     ))
    TB = dset.createVariable("time_bounds",t.dtype   ,("time","nb"))
    X  = dset.createVariable("lat"        ,lat.dtype ,("lat"      ))
    XB = dset.createVariable("lat_bounds" ,lat.dtype ,("lat","nb" ))
    Y  = dset.createVariable("lon"        ,lon.dtype ,("lon"      ))
    YB = dset.createVariable("lon_bounds" ,lon.dtype ,("lon","nb" ))
    D  = dset.createVariable("var"        ,data.dtype,("time","lat","lon"))

Finally we load the netCDF4 Variables (``T,TB,X,XB,Y,YB,D``) with the
corresponding numerical values (``t,tbnd,lat,latbnd,lon,lonbnd,data``)
we computed in previous steps. We also encode a few attributes which
ILAMB will need as a bare minimum to correctly interpret the
values. Any units provided will need to adhere to the CF convention, see
`here
<http://cfconventions.org/cf-conventions/cf-conventions.html#units>`_. 

.. code-block:: python
    
    # Load data and encode attributes
    T [...]    = t
    T.units    = "days since 1850-01-01"
    T.calendar = "noleap"
    T.bounds   = "time_bounds"
    TB[...]    = tbnd
    
    X [...]    = lat
    X.units    = "degrees_north"
    XB[...]    = latbnd
    
    Y [...]    = lon
    Y.units    = "degrees_east"
    YB[...]    = lonbnd

    D[...]     = data
    D.units    = "kg m-2 s-1"
    dset.close()
    
Site data
---------

Encoding data from a site or collection of sites is similar with two
main distinctions. First, there is a ``data`` dimension referring to
the number of sites in the set. The latitude and longitude arrays are
of this dimension. Second, the time array must span the maximum
coverage of the site collection. Consider a sample set here consisting
of two sites: site A which has monthly mean data from 1950 and site B
with monthly mean data from 1951. One thing to emphasize is that while
not part of the units description, these times need to be in UTC
format. This can be problematic as sites tend to store their data in a
local time coordinate. The time portion of our script is similar.

.. code-block:: python
   
    from netCDF4 import Dataset
    import numpy as np

    # Open a dataset for writing
    dset = Dataset("global_sample.nc",mode="w")

    # Create temporal dimension
    nyears    = 2
    month_bnd = np.asarray([0,31,59,90,120,151,181,212,243,273,304,334,365],dtype=float)
    tbnd  = np.asarray([((np.arange(nyears)*365)[:,np.newaxis]+month_bnd[:-1]).flatten(),
                        ((np.arange(nyears)*365)[:,np.newaxis]+month_bnd[+1:]).flatten()]).T
    tbnd += (1950-1850)*365
    t     = tbnd.mean(axis=1)

However the spatial portion just consists of two locations and
contains no bounds. The data array is then a 2D array where the first
dimension is the total number of time intervals represented and the
second dimension is the number of sites. The data array itself needs
to be masked over regions where each site contains no data. ILAMB will
apply this mask to the model results which it extracts.

.. code-block:: python

    lat = np.asarray([- 35.655,-25.0197])
    lon = np.asarray([ 148.152, 31.4969])

    data = np.ma.masked_array(np.zeros((t.size,2)),mask=True) # masked array of zeros
    data[:12,0] = np.random.rand(12) # site A's random data
    data[12:,1] = np.random.rand(12) # site B's random data

As before this is the step that is the most complicated as it involves parsing text files into this format. Finally we output again the dimensions and variables to the netCDF4 file. 

.. code-block:: python
    
    # Create netCDF dimensions
    dset.createDimension("time",size=t.size)
    dset.createDimension("data",size=2     )
    dset.createDimension("nb"  ,size=2     )

    # Create netCDF variables
    T  = dset.createVariable("time"       ,t.dtype   ,("time"       ))
    TB = dset.createVariable("time_bounds",t.dtype   ,("time","nb"  ))
    X  = dset.createVariable("lat"        ,lat.dtype ,("data"       ))
    Y  = dset.createVariable("lon"        ,lon.dtype ,("data"       ))
    D  = dset.createVariable("var"        ,data.dtype,("time","data"))

    # Load data and encode attributes
    T [...]    = t
    T.units    = "days since 1850-01-01"
    T.calendar = "noleap"
    T.bounds   = "time_bounds"
    TB[...]    = tbnd
    
    X [...]    = lat
    X.units    = "degrees_north"
    
    Y [...]    = lon
    Y.units    = "degrees_east"

    D[...]     = data
    D.units    = "kg m-2 s-1"
    dset.close()
