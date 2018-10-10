from Confrontation import Confrontation
from mpl_toolkits.basemap import Basemap
from Variable import Variable
from Post import ColorBar
import matplotlib.pyplot as plt
from netCDF4 import Dataset
import ilamblib as il
import numpy as np

class ConfPermafrost(Confrontation):

    def __init__(self,**keywords):

        # Ugly, but this is how we call the Confrontation constructor
        super(ConfPermafrost,self).__init__(**keywords)

        # Now we overwrite some things which are different here
        self.layout
        self.regions        = ["global"]
        self.layout.regions = self.regions
        self.weight         = { "Obs Score" : 1.,
                                "Mod Score" : 1. }
        for page in self.layout.pages:
            page.setMetricPriority(["Total Area"  ,
                                    "Overlap Area",
                                    "Missed Area" ,
                                    "Excess Area" ,
                                    "Obs Score"   ,
                                    "Mod Score"   ,
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
                 d   = [0            ,dmax])
        mod          = mod.annualCycle()
        Tmax         = mod.data.max(axis=0)
        table        = np.zeros(Tmax.shape[-2:])
        table[...]   = np.NAN
        thaw         = np.zeros(table.shape,dtype=bool)
        for i in range(mod.depth_bnds.shape[0]-1,-1,-1):
            thaw  += (Tmax[i]>=Teps)
            frozen = np.where((Tmax[i]<Teps)*(thaw==0))
            table[frozen] = mod.depth_bnds[i,0]
        table = np.ma.masked_invalid(table)
        table.data[table.mask==0] = 1
        mod = Variable(name = "permafrost_extent",
                       unit = "1",
                       data = table,
                       lat  = mod.lat,
                       lon  = mod.lon,
                       area = mod.area)
        return obs,mod
        
    def confront(self,m):

        obs,mod  = self.stageData(m)        
        obs_area = obs.integrateInSpace().convert("1e6 km2")
        mod_area = mod.integrateInSpace().convert("1e6 km2")
        
        # interpolate to a composed grid
        lat,lon = il.ComposeSpatialGrids(obs,mod)
        iobs    = obs.interpolate(lat=lat,lon=lon)
        imod    = mod.interpolate(lat=lat,lon=lon)
        
        # compute the intersection of obs and mod
        data = (iobs.data.mask==0)*(imod.data.mask==0)
        obs_and_mod = Variable(name = "obs_and_mod",
                               unit = "1",
                               data = np.ma.masked_values(data,0).astype(float),
                               lat  = lat,
                               lon  = lon)

        # compute the obs that is not the mod
        data = (iobs.data.mask==0)*(imod.data.mask==1)
        obs_not_mod = Variable(name = "obs_not_mod",
                               unit = "1",
                               data = np.ma.masked_values(data,0).astype(float),
                               lat  = lat,
                               lon  = lon)

        # compute the mod that is not the obs
        data = (iobs.data.mask==1)*(imod.data.mask==0)
        mod_not_obs = Variable(name = "mod_not_obs",
                               unit = "1",
                               data = np.ma.masked_values(data,0).astype(float),
                               lat  = lat,
                               lon  = lon)

        # compute areas
        obs_and_mod_area = obs_and_mod.integrateInSpace().convert("1e6 km2")
        obs_not_mod_area = obs_not_mod.integrateInSpace().convert("1e6 km2")
        mod_not_obs_area = mod_not_obs.integrateInSpace().convert("1e6 km2")
        
        # determine score
        obs_score = Variable(name = "Obs Score global",
                             unit = "1",
                             data = obs_and_mod_area.data / obs_area.data)
        mod_score = Variable(name = "Mod Score global",
                             unit = "1",
                             data = obs_and_mod_area.data / mod_area.data)
                
        # Write to datafiles --------------------------------------

        obs_area.name         = "Total Area"
        mod_area.name         = "Total Area"
        obs_and_mod_area.name = "Overlap Area"
        obs_not_mod_area.name = "Missed Area"
        mod_not_obs_area.name = "Excess Area"
        
        results = Dataset("%s/%s_%s.nc" % (self.output_path,self.name,m.name),mode="w")
        results.setncatts({"name" :m.name, "color":m.color})
        mod             .toNetCDF4(results,group="MeanState")
        obs_and_mod     .toNetCDF4(results,group="MeanState")
        obs_not_mod     .toNetCDF4(results,group="MeanState")
        mod_not_obs     .toNetCDF4(results,group="MeanState")        
        mod_area        .toNetCDF4(results,group="MeanState")
        obs_and_mod_area.toNetCDF4(results,group="MeanState")
        obs_not_mod_area.toNetCDF4(results,group="MeanState")
        mod_not_obs_area.toNetCDF4(results,group="MeanState")
        obs_score       .toNetCDF4(results,group="MeanState")
        mod_score       .toNetCDF4(results,group="MeanState")
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
                       side   = "SPATIAL BIAS",
                       legend = True)
        
        plt.figure(figsize=(10,10),dpi=60)
        mp  = Basemap(projection='ortho',lat_0=90.,lon_0=180.,resolution='c')
        X,Y = np.meshgrid(mod.lat,mod.lon,indexing='ij')
        mp.pcolormesh(Y,X,mod.data,latlon=True,cmap="Blues",vmin=0,vmax=2)
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
        
        plt.figure(figsize=(10,10),dpi=60)
        mp  = Basemap(projection='ortho',lat_0=90.,lon_0=180.,resolution='c')
        X,Y = np.meshgrid(tmp.lat,tmp.lon,indexing='ij')
        mp.pcolormesh(Y,X,bias,latlon=True,cmap="seismic",vmin=-1.5,vmax=+1.5)
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
            mp.pcolormesh(Y,X,obs.data,latlon=True,cmap="Blues",vmin=0,vmax=2)
            mp.drawlsmask(land_color='lightgrey',ocean_color='grey',lakes=True)
            plt.savefig("%s/Benchmark_global_timeint.png" % (self.output_path),dpi='figure')
            plt.close()

            # plot legend for bias
            fig,ax = plt.subplots(figsize=(6.8,1.0),tight_layout=True)
            ColorBar(ax,
                     vmin = -1.5,
                     vmax = +1.5,
                     cmap = "seismic",
                     ticks = [-1,0,1],
                     ticklabels = ["Obs $\\backslash$ Mod","Obs $\cap$ Mod","Mod $\\backslash$ Obs"],
                     label = "Spatial Extent Bias")
            fig.savefig("%s/legend_%s.png" % (self.output_path,"bias"))
            plt.close()

