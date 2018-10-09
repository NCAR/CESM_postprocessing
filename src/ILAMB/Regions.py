from netCDF4 import Dataset
import numpy as np

class Regions(object):
    """A class for unifying the treatment of regions in ILAMB.

    This class holds a list of all regions currently registered in the
    ILAMB system via a static property of the class. It also comes
    with methods for defining additional regions by lat/lon bounds or
    by a mask specified by a netCDF4 file. A set of regions used in
    the Global Fire Emissions Database (GFED) is included by default.

    """
    _regions = {}

    @property
    def regions(self):
        """Returns a list of region identifiers."""
        return Regions._regions.keys()

    def addRegionLatLonBounds(self,label,name,lats,lons):
        """Add a region by lat/lon bounds.

        Parameters
        ----------
        label : str
            the unique region identifier (lower case, no spaces or special characters)
        name : str
            the name of the region (as will appear in the HTML pull down menu)
        lats : array-like of size 2
            the minimum and maximum latitudes defining the region on the interval (-90,90)
        lons : array-like of size 2
            the minimum and maximum longitudes defining the region on the interval (-180,180)
        
        """
        lat  = np.hstack([[- 90.],np.asarray(lats),[ 90.]])
        lon  = np.hstack([[-180.],np.asarray(lons),[180.]])
        mask = np.asarray([[1,1,1],
                           [1,0,1],
                           [1,1,1]],dtype=bool)
        Regions._regions[label] = [name,lat,lon,mask]

    def addRegionNetCDF4(self,filename):
        """Add regions found in a netCDF4 file.

        This routine will search the target filename's variables for
        2-dimensional datasets which contain indices representing
        distinct non-overlapping regions. Each unique non-masked index
        found in this dataset will be added to the global list of
        regions along with a mask representing the region. The names
        of the regions are taken from a required attribute in the
        variable called 'labels'. This attribute should point to a
        variable which is a string array labeling each index found in
        the two-dimensional dataset.

        For example, the following header represents a dataset encoded
        to represent 50 of the world's largest river basins. The
        'basin_index' variable contains integer indices 0 through 49
        where index 0 is labeled by the 0th label found in the 'label'
        variable::

          dimensions:
  	        lat = 360 ;
  	        lon = 720 ;
	        n = 50 ;
          variables:
	        string label(n) ;
		        label:long_name = "basin labels" ;
	        float lat(lat) ;
		        lat:long_name = "latitude" ;
		        lat:units = "degrees_north" ;
	        float lon(lon) ;
		        lon:long_name = "longitude" ;
		        lon:units = "degrees_east" ;
	        int basin_index(lat, lon) ;
		        basin_index:labels = "label" ;

        Parameters
        ----------
        filename : str
            the full path of the netCDF4 file containing the regions

        Returns
        -------
        regions : list of str
            a list of the keys of the regions added.
        """
        dset = Dataset(filename)

        # look for 2d datasets defined on regular grids
        labels = []
        for var in dset.variables:
            v = dset.variables[var]
            if len(v.dimensions) == 2 and "labels" in v.ncattrs():
                lat = dset.variables[v.dimensions[0]][...]
                lon = dset.variables[v.dimensions[1]][...]
                lbl = dset.variables[v.labels       ][...]
                nam = dset.variables[v.names        ][...] if "names" in v.ncattrs() else lbl
                ids = np.ma.compressed(np.unique(v[...]))
                assert ids.max() < lbl.size
                for i in ids:
                    label = lbl[i].lower()
                    name  = nam[i]
                    mask  = v[...].data != i
                    Regions._regions[label] = [name,lat,lon,mask]
                    labels.append(label)
        return labels
    
    def getRegionName(self,label):
        """Given the region label, return the full name.
        
        Parameters
        ----------
        label : str
            the unique region identifier

        Returns
        -------
        name : str
            the long name of the region
        """
        return Regions._regions[label][0]

    def getMask(self,label,var):
        """Given the region label and a ILAMB.Variable, return a mask appropriate for that variable.

        Parameters
        ----------
        label : str
            the unique region identifier
        var : ILAMB.Variable.Variable
            the variable to which we would like to apply a mask

        Returns
        -------
        mask : numpy.ndarray
            a boolean array appropriate for masking the input variable data
        """
        name,lat,lon,mask = Regions._regions[label]
        if lat.size == 4 and lon.size == 4:
            # if lat/lon bounds, find which bounds we are in
            rows = ((var.lat[:,np.newaxis]>=lat[:-1])*(var.lat[:,np.newaxis]<=lat[1:])).argmax(axis=1)
            cols = ((var.lon[:,np.newaxis]>=lon[:-1])*(var.lon[:,np.newaxis]<=lon[1:])).argmax(axis=1)
        else:
            # if more globally defined, nearest neighbor is fine
            rows = (np.abs(lat[:,np.newaxis]-var.lat)).argmin(axis=0)
            cols = (np.abs(lon[:,np.newaxis]-var.lon)).argmin(axis=0)
        if var.ndata: return mask[np.ix_(rows,cols)].diagonal()
        return mask[np.ix_(rows,cols)]
            
    def hasData(self,label,var):
        """Checks if the ILAMB.Variable has data on the given region.

        Parameters
        ----------
        label : str
            the unique region identifier
        var : ILAMB.Variable.Variable
            the variable to which we would like check for data

        Returns
        -------
        hasdata : boolean
            returns True if variable has data on the given region
        """
        axes = range(var.data.ndim)
        if var.spatial: axes = axes[:-2]
        if var.ndata  : axes = axes[:-1]
        keep = (self.getMask(label,var)==False)
        if var.data.mask.size == 1:
            if var.data.mask: keep *= 0
        else:
            keep *= (var.data.mask == False).any(axis=tuple(axes))
        if keep.sum() > 0: return True
        return False
        
if "global" not in Regions().regions:
    
    # Populate some regions
    r = Regions()    
    r.addRegionLatLonBounds("global","Globe",(-89.999, 89.999),(-179.999, 179.999))
    Regions._regions["global"][3][...] = 0. # ensure global mask is null
    
    # GFED regions
    r.addRegionLatLonBounds("bona","Boreal North America",             ( 49.75, 79.75),(-170.25,- 60.25))
    r.addRegionLatLonBounds("tena","Temperate North America",          ( 30.25, 49.75),(-125.25,- 66.25))
    r.addRegionLatLonBounds("ceam","Central America",                  (  9.75, 30.25),(-115.25,- 80.25))
    r.addRegionLatLonBounds("nhsa","Northern Hemisphere South America",(  0.25, 12.75),(- 80.25,- 50.25))
    r.addRegionLatLonBounds("shsa","Southern Hemisphere South America",(-59.75,  0.25),(- 80.25,- 33.25))
    r.addRegionLatLonBounds("euro","Europe",                           ( 35.25, 70.25),(- 10.25,  30.25))
    r.addRegionLatLonBounds("mide","Middle East",                      ( 20.25, 40.25),(- 10.25,  60.25))
    r.addRegionLatLonBounds("nhaf","Northern Hemisphere Africa",       (  0.25, 20.25),(- 20.25,  45.25))
    r.addRegionLatLonBounds("shaf","Southern Hemisphere Africa",       (-34.75,  0.25),(  10.25,  45.25))
    r.addRegionLatLonBounds("boas","Boreal Asia",                      ( 54.75, 70.25),(  30.25, 179.75))
    r.addRegionLatLonBounds("ceas","Central Asia",                     ( 30.25, 54.75),(  30.25, 142.58))
    r.addRegionLatLonBounds("seas","Southeast Asia",                   (  5.25, 30.25),(  65.25, 120.25))
    r.addRegionLatLonBounds("eqas","Equatorial Asia",                  (-10.25, 10.25),(  99.75, 150.25))
    r.addRegionLatLonBounds("aust","Australia",                        (-41.25,-10.50),( 112.00, 154.00))
