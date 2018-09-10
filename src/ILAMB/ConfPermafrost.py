from Confrontation import Confrontation
from mpl_toolkits.basemap import Basemap
from Variable import Variable
from Post import ColorBar
import matplotlib.pyplot as plt
from netCDF4 import Dataset
import ilamblib as il
import numpy as np

def _ALTFromTSL(tsl,dmax=3.5,dres=0.01,Teps=273.15):
    """

    """
    from scipy.interpolate import interp1d
    
    # find the annual cycle
    mask = tsl.data.mask.all(axis=(0,1))
    area = tsl.area
    tsl  = tsl.annualCycle()
    
    # which month is the mean soil temperature maximum?    
    T = tsl.data.mean(axis=1).argmax(axis=0)
    T = T[np.newaxis,np.newaxis,...]*np.ones((1,)+tsl.data.shape[-3:],dtype=int)
    D,X,Y = np.ix_(np.arange(tsl.data.shape[1]),
                   np.arange(tsl.data.shape[2]),
                   np.arange(tsl.data.shape[3]))
    d   = tsl.depth
    tsl = tsl.data[T,D,X,Y]
    tsl = tsl.reshape(tsl.shape[-3:])
    
    # now we interpolate to find a more precise active layer thickness
    D   = np.arange(0,dmax+0.1*dres,dres)
    TSL = interp1d(d,tsl,axis=0,fill_value="extrapolate")
    TSL = TSL(D)
        
    # the active layer thickness is then the sum of all level
    # thicknesses whose temperature is greater than the threshold.
    ALT = np.ma.masked_array((TSL>Teps).sum(axis=0)*dres,mask=mask+(TSL>Teps).all(axis=0))

    return ALT
    
class ConfPermafrost(Confrontation):

    def __init__(self,**keywords):

        # Ugly, but this is how we call the Confrontation constructor
        super(ConfPermafrost,self).__init__(**keywords)

        # Now we overwrite some things which are different here
        self.layout
        self.regions        = ["global"]
        self.layout.regions = self.regions
        self.weight         = { "Missed Score" : 1.,
                                "Excess Score" : 1. }
        for page in self.layout.pages:
            page.setMetricPriority(["Total Area"  ,
                                    "Overlap Area",
                                    "Missed Area" ,
                                    "Excess Area" ,
                                    "Missed Score"   ,
                                    "Excess Score"   ,
                                    "Overall Score"])
                
    def stageData(self,m):

        obs = Variable(filename      = self.source,
                       variable_name = "permafrost_extent")

        # These parameters may be changed from the configure file
        y0   = float(self.keywords.get("y0"  ,1970.))  # [yr]      beginning year to include in analysis
        yf   = float(self.keywords.get("yf"  ,2000.))  # [yr]      end year to include in analysis
        dmax = float(self.keywords.get("dmax",3.5))    # [m]       consider layers where depth in is the range [0,dmax]
        Teps = float(self.keywords.get("Teps",273.15)) # [K]       temperature below which we assume permafrost occurs
        
        t0  = (y0  -1850.)*365.
        tf  = (yf+1-1850.)*365.
        mod = m.extractTimeSeries(self.variable,
                                  initial_time = t0,
                                  final_time   = tf)
        mod.trim(t   = [t0           ,tf  ],
                 lat = [obs.lat.min(),90  ],
                 d   = [0            ,dmax]) #.annualCycle()

        alt = _ALTFromTSL(mod)
        mod = Variable(name = "permafrost_extent",
                       unit = "1",
                       data = np.ma.masked_array((alt>=0).astype(float),mask=alt.mask),
                       lat  = mod.lat,
                       lon  = mod.lon,
                       area = mod.area)
        return obs,mod
        
    def confront(self,m):

        obs,mod  = self.stageData(m)
        obs_area = obs.integrateInSpace().convert("1e6 km2")
        mod_area = mod.integrateInSpace().convert("1e6 km2")
        
        # Interpolate to a composed grid
        lat,lon,lat_bnds,lon_bnds = il._composeGrids(obs,mod)
        OBS = obs.interpolate(lat=lat,lon=lon,lat_bnds=lat_bnds,lon_bnds=lon_bnds)
        MOD = mod.interpolate(lat=lat,lon=lon,lat_bnds=lat_bnds,lon_bnds=lon_bnds)

        # Compute the different extent areas
        o_mask       =  OBS.data.mask
        o_land       = (OBS.area > 1e-12)*(o_mask==0)
        o_data       =  np.copy(OBS.data.data)
        o_data[np.where(OBS.data.mask)] = 0.

        m_mask       =  MOD.data.mask
        m_land       = (MOD.area > 1e-12)
        m_data       =  np.copy(MOD.data.data)
        m_data[np.where(MOD.data.mask)] = 0.

        o_and_m      = (np.abs(o_data-1)<1e-12)*(np.abs(m_data-1)<1e-12)
        o_not_m_land = (np.abs(o_data-1)<1e-12)*(np.abs(m_data  )<1e-12)*(m_land==0)
        o_not_m_miss = (np.abs(o_data-1)<1e-12)*(np.abs(m_data  )<1e-12)*(m_land==1)
        o_zones      = 1.*o_and_m
        o_zones     += 2.*o_not_m_land
        o_zones     += 4.*o_not_m_miss
        o_zones = np.ma.masked_array(o_zones,mask=o_mask)

        m_and_o      = (np.abs(m_data-1)<1e-12)*(np.abs(o_data-1)<1e-12)
        m_not_o_land = (np.abs(m_data-1)<1e-12)*(np.abs(o_data  )<1e-12)*(o_land==0)
        m_not_o_miss = (np.abs(m_data-1)<1e-12)*(np.abs(o_data  )<1e-12)*(o_land==1)
        m_zones      = 1.*m_and_o
        m_zones     += 2.*m_not_o_land
        m_zones     += 4.*m_not_o_miss
        m_zones = np.ma.masked_array(m_zones,mask=m_mask)

        zones  = 1.*o_and_m
        zones += 2.*o_not_m_miss
        zones += 4.*m_not_o_miss
        zones += 8.*m_not_o_land
        zones  = np.ma.masked_less(zones,1)
        for i,u in enumerate(np.unique(zones.compressed())):
            zones[np.where(zones==u)] = i

        # compute the intersection of obs and mod
        obs_and_mod = Variable(name = "obs_and_mod",
                               unit = "1",
                               data = np.ma.masked_values(zones==0,0).astype(float),
                               lat  = lat, lon = lon, area = MOD.area)

        # compute the obs that is not the mod
        data = (OBS.data.mask==0)*(MOD.data.mask==1)
        obs_not_mod = Variable(name = "obs_not_mod",
                               unit = "1",
                               data = np.ma.masked_values(zones==1,0).astype(float),
                               lat  = lat, lon  = lon, area = OBS.area)

        # compute the mod that is not the obs
        data = (OBS.data.mask==1)*(MOD.data.mask==0)
        mod_not_obs = Variable(name = "mod_not_obs",
                               unit = "1",
                               data = np.ma.masked_values(zones==2,0).astype(float),
                               lat  = lat, lon  = lon, area = MOD.area)
        
        # compute the mod that is not the obs but because of land representation
        data = (OBS.data.mask==1)*(MOD.data.mask==0)
        mod_not_obs_land = Variable(name = "mod_not_obs_land",
                                    unit = "1",
                                    data = np.ma.masked_values(zones==3,0).astype(float),
                                    lat  = lat, lon  = lon, area = MOD.area)

        # compute areas
        obs_and_mod_area = obs_and_mod.integrateInSpace().convert("1e6 km2")
        obs_not_mod_area = obs_not_mod.integrateInSpace().convert("1e6 km2")
        mod_not_obs_area = mod_not_obs.integrateInSpace().convert("1e6 km2")
        mod_not_obs_land_area = mod_not_obs_land.integrateInSpace().convert("1e6 km2")
        
        # determine score
        obs_score = Variable(name = "Missed Score global",
                             unit = "1",
                             data = obs_and_mod_area.data / (obs_and_mod_area.data + obs_not_mod_area.data))
        mod_score = Variable(name = "Excess Score global",
                             unit = "1",
                             data = obs_and_mod_area.data / (obs_and_mod_area.data + mod_not_obs_area.data))
                
        # Write to datafiles --------------------------------------

        obs_area.name         = "Total Area"
        mod_area.name         = "Total Area"
        obs_and_mod_area.name = "Overlap Area"
        obs_not_mod_area.name = "Missed Area"
        mod_not_obs_area.name = "Excess Area"
        mod_not_obs_land_area.name = "Excess Area (Land Representation)"
        
        results = Dataset("%s/%s_%s.nc" % (self.output_path,self.name,m.name),mode="w")
        results.setncatts({"name" :m.name, "color":m.color})
        mod                  .toNetCDF4(results,group="MeanState")
        obs_and_mod          .toNetCDF4(results,group="MeanState")
        obs_not_mod          .toNetCDF4(results,group="MeanState")
        mod_not_obs          .toNetCDF4(results,group="MeanState")        
        mod_not_obs_land     .toNetCDF4(results,group="MeanState")        
        mod_area             .toNetCDF4(results,group="MeanState")
        obs_and_mod_area     .toNetCDF4(results,group="MeanState")
        obs_not_mod_area     .toNetCDF4(results,group="MeanState")
        mod_not_obs_area     .toNetCDF4(results,group="MeanState")
        mod_not_obs_land_area.toNetCDF4(results,group="MeanState")
        obs_score            .toNetCDF4(results,group="MeanState")
        mod_score            .toNetCDF4(results,group="MeanState")
        results.close()

        if self.master:
            results = Dataset("%s/%s_Benchmark.nc" % (self.output_path,self.name),mode="w")
            results.setncatts({"name" :"Benchmark", "color":np.asarray([0.5,0.5,0.5])})
            obs_area.toNetCDF4(results,group="MeanState")
            results.close()
        
    def modelPlots(self,m):
        
        fname   = "%s/%s_%s.nc" % (self.output_path,self.name,m.name)
        try:
            mod = Variable(filename      = fname,
                           variable_name = "permafrost_extent",
                           groupname     = "MeanState")
        except:
            return

        page = [page for page in self.layout.pages if "MeanState" in page.name][0]
        
        page.addFigure("Temporally integrated period mean",
                       "benchmark_timeint",
                       "Benchmark_global_timeint.png",
                       side   = "BENCHMARK EXTENT",
                       legend = False)
        page.addFigure("Temporally integrated period mean",
                       "timeint",
                       "MNAME_global_timeint.png",
                       side   = "MODEL EXTENT",
                       legend = False)
        page.addFigure("Temporally integrated period mean",
                       "bias",
                       "MNAME_global_bias.png",
                       side   = "BIAS",
                       legend = True)
        
        plt.figure(figsize=(10,10),dpi=60)
        mp  = Basemap(projection='ortho',lat_0=90.,lon_0=180.,resolution='c')
        X,Y = np.meshgrid(mod.lat,mod.lon,indexing='ij')
        mp.pcolormesh(Y,X,np.ma.masked_values(mod.data,0),latlon=True,cmap="Blues",vmin=0,vmax=2)
        mp.drawlsmask(land_color='lightgrey',ocean_color='grey',lakes=True)
        plt.savefig("%s/%s_global_timeint.png" % (self.output_path,m.name),dpi='figure')
        plt.close()

        tmp = Variable(filename = fname,variable_name = "obs_not_mod",groupname = "MeanState")
        bias = np.zeros(tmp.data.shape)
        bias[...] = np.NAN
        bias[tmp.data.mask==0] = -1.0
        tmp = Variable(filename = fname,variable_name = "obs_and_mod",groupname = "MeanState")
        bias[tmp.data.mask==0] =  0.0
        tmp = Variable(filename = fname,variable_name = "mod_not_obs",groupname = "MeanState")
        bias[tmp.data.mask==0] = +1.0
        bias = np.ma.masked_invalid(bias)

        cmap = plt.get_cmap('bwr',3)
        plt.figure(figsize=(10,10),dpi=60)
        mp  = Basemap(projection='ortho',lat_0=90.,lon_0=180.,resolution='c')
        X,Y = np.meshgrid(tmp.lat,tmp.lon,indexing='ij')
        mp.pcolormesh(Y,X,bias,latlon=True,cmap=cmap,vmin=-1.5,vmax=+1.5)
        mp.drawlsmask(land_color='lightgrey',ocean_color='grey',lakes=True)
        plt.savefig("%s/%s_global_bias.png" % (self.output_path,m.name),dpi='figure')
        plt.close()

        if self.master:
            obs = Variable(filename      = self.source,
                           variable_name = "permafrost_extent")
            # plot result
            plt.figure(figsize=(10,10),dpi=60)
            mp  = Basemap(projection='ortho',lat_0=90.,lon_0=180.,resolution='c')
            X,Y = np.meshgrid(obs.lat,obs.lon,indexing='ij')
            mp.pcolormesh(Y,X,np.ma.masked_values(obs.data,0),latlon=True,cmap="Blues",vmin=0,vmax=2)
            mp.drawlsmask(land_color='lightgrey',ocean_color='grey',lakes=True)
            plt.savefig("%s/Benchmark_global_timeint.png" % (self.output_path),dpi='figure')
            plt.close()

            # plot legend for bias
            fig,ax = plt.subplots(figsize=(6.8,0.8),tight_layout=True)
            ColorBar(ax,
                     vmin = -1.5,
                     vmax = +1.5,
                     cmap = cmap,
                     ticks = [-1,0,1],
                     ticklabels = ["Missed Area","Shared Area","Excess Area"],
                     label = "")
            fig.savefig("%s/legend_%s.png" % (self.output_path,"bias"))
            plt.close()

