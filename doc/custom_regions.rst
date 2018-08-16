Defining Custom Regions
=======================

In the `tutorial <./ilamb_run.html>`_ explaining the options of
``ilamb-run``, we highlight that custom regions may be defined in two
ways. The first is region definition by latitude and longitude bounds
which can be done in the form of a text file in the following comma
delimited format::

  #label,name          ,lat_min,lat_max,lon_min,lon_max
  usa   ,Continental US,     24,     50,   -126,    -66
  alaska,Alaska        ,     53,     72,   -169,   -129
  
The first column is the label to be used, followed by the region
name. Then the minimum and maximum bounds on the latitude and
longitude are specified. Note that longitude values are expected on
the [-180,180] interval. In this current iteration regions cannot be
specified which span the international dateline.

The second method is by creating a netCDF4 file which will be used
internally to create a mask for each region. This we will demonstrate
by encoding the above regions but in this format. First we create the
spatial grid on which we will define the regions.

.. code-block:: python

    from netCDF4 import Dataset
    import numpy as np
    
    # Create the lat/lon dimensions
    res    = 0.5
    latbnd = np.asarray([np.arange(- 90    , 90     ,res),
                         np.arange(- 90+res, 90+0.01,res)]).T
    lonbnd = np.asarray([np.arange(-180    ,180     ,res),
                         np.arange(-180+res,180+0.01,res)]).T
    lat    = latbnd.mean(axis=1)
    lon    = lonbnd.mean(axis=1)

Next we create an array of integers which we will use to mark the
regions we wish to encode. This is essentially painting by numbers. We
initialize the array to a missing value which we will encode later.

.. code-block:: python

    # Create the number array, initialize to a missing value
    miss   = -999
    ids    = np.ones((lat.size,lon.size),dtype=int)*miss

Then we paint the regions we wish to encode using the latitude and
longitude bounds which were in the sample text file above. This part
will vary depending on how you wish to define regions. For example,
our regions here will still appear to be defined by latitude and
longitude bounds because that is how we are creating the mask. You may
find other sources for your region definitions which will allow more
precise representations. Note that this method of definition means
that regions cannot overlap in a single file. If you need to define
overlapping regions, put each region in a separate file.
    
.. code-block:: python

    # Paint the Continental US with a `0`
    ids[np.where(np.outer((lat>=  24)*(lat<=  50),
                          (lon>=-126)*(lon<=- 66)))] = 0
    
    # Paint Alaska with a `1`
    ids[np.where(np.outer((lat>=  53)*(lat<=  72),
                          (lon>=-169)*(lon<=-129)))] = 1

Next we convert the ``numpy`` integer array to a masked array where we
mask by the missing value we defined above. Then we create an array of
labels to use as indentifiers for the integer numbers we defined. A
``0`` in the ``ids`` array will correspond to the ``USA`` region and a
``1`` to the ``Alaska`` region. These lower case version of these
names will be used as region labels.

.. code-block:: python
			  
    # Convert the ids to a masked array
    ids = np.ma.masked_values(ids,miss)
    
    # Create the array of labels
    lbl = np.asarray(["USA","Alaska"])

Finally we encode the netCDF4 dataset. There are a few important
details in this code. The first is to use the ``numpy`` datatypes of
the arrays when creating netCDF4 variables. This is especially
important in encoding the ``labels`` array as it will ensure the
string array is created properly. The other important detail is to
encode the ``labels`` attribute of the ``I`` variable. This is what
tells the ILAMB system where to find the labels for the integers
defined in the array.

.. code-block:: python

    # Create netCDF dimensions
    dset = Dataset("regions.nc",mode="w")
    dset.createDimension("lat" ,size=lat.size)
    dset.createDimension("lon" ,size=lon.size)
    dset.createDimension("nb"  ,size=2       )
    dset.createDimension("n"   ,size=lbl.size)
    
    # Create netCDF variables
    X  = dset.createVariable("lat"        ,lat.dtype,("lat"      ))
    XB = dset.createVariable("lat_bounds" ,lat.dtype,("lat","nb" ))
    Y  = dset.createVariable("lon"        ,lon.dtype,("lon"      ))
    YB = dset.createVariable("lon_bounds" ,lon.dtype,("lon","nb" ))
    I  = dset.createVariable("ids"        ,ids.dtype,("lat","lon"))
    L  = dset.createVariable("labels"     ,lbl.dtype,("n"        ))
    
    # Load data and encode attributes
    X [...] = lat
    X.units = "degrees_north"
    XB[...] = latbnd
    
    Y [...] = lon
    Y.units = "degrees_east"
    YB[...] = lonbnd
    
    I[...]  = ids
    I.labels= "labels"
    
    L[...]  = lbl

    dset.close()
