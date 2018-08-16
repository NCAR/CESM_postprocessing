from ILAMB.Confrontation import Confrontation
from ILAMB.Regions import Regions
from mpl_toolkits.basemap import Basemap
from ILAMB.Variable import Variable
from netCDF4 import Dataset
import ILAMB.ilamblib as il
import ILAMB.Post as post
import pylab as plt
import numpy as np
import os

class ConfRunoff(Confrontation):
    """A confrontation for examining the runoff in 50 of the world's largest river basins.

    """
    def __init__(self,**keywords):
        
        # Ugly, but this is how we call the Confrontation constructor
        super(ConfRunoff,self).__init__(**keywords)
        
        # Now we overwrite some things which are different here
        self.regions        = ['global']
        self.layout.regions = self.regions

        # Adding a member variable called basins, add them as regions
        r = Regions()
        self.basins = r.addRegionNetCDF4(self.source.replace("runoff.nc","basins_0.5x0.5.nc"))
        
    def stageData(self,m):
        """Extracts model data and transforms it to make it comparable to the runoff dataset.

        Parameters
        ----------
        m : ILAMB.ModelResult.ModelResult
            the model result context

        Returns
        -------
        obs : ILAMB.Variable.Variable
            the variable context associated with the observational dataset
        mod : ILAMB.Variable.Variable
            the variable context associated with the model result
        """
        # Extract the observational data for basins
        obs = Variable(filename      = self.source,
                       variable_name = self.variable).convert("mm d-1")

        # Extract the globally gridded runoff
        mod = m.extractTimeSeries(self.variable,
                                  alt_vars     = self.alternate_vars,
                                  initial_time = obs.time_bnds[ 0,0],
                                  final_time   = obs.time_bnds[-1,1])

        # We want annual mean, not monthly mean
        years = np.asarray([obs.time_bnds[  ::12,0],
                            obs.time_bnds[11::12,1]]).T
        obs   = obs.coarsenInTime(years)
        mod   = mod.coarsenInTime(years)
        obs.name = "runoff"
        mod.name = "runoff"
        
        # Operate on model data to compute mean runoff values in each basin.
        data   = np.ma.zeros(obs.data.shape)
        for i,basin in enumerate(self.basins):
            b = il.ClipTime(mod.integrateInSpace(region=basin,mean=True),
                            obs.time_bnds[ 0,0],
                            obs.time_bnds[-1,1]).convert(obs.unit)
            data[:,i] = b.data

        # Create a variable to return for the model
        mod  = Variable(name      = obs.name,
                        unit      = obs.unit,
                        data      = np.ma.masked_array(data,mask=obs.data.mask),
                        time      = obs.time,
                        time_bnds = obs.time_bnds,
                        ndata     = obs.ndata,
                        lat       = obs.lat,
                        lat_bnds  = obs.lat_bnds,
                        lon       = obs.lon,
                        lon_bnds  = obs.lon_bnds)
        return obs,mod

    def _extendSitesToMap(self,var):
        """A local function to extend site data to the basins.
        
        Parameters
        ----------
        var : ILAMB.Variable.Variable
            the site-based variable we wish to extend to basins

        Returns
        -------
        extended : ILAMB.Variable.Variable
            the spatial variable which is the extended version of the
            input variable
        """
        
        # determine the global mask
        global_mask = None
        global_data = None
        for i,basin in enumerate(self.basins):
            name,lat,lon,mask = Regions._regions[basin]
            keep = (mask == False)
            if global_mask is None:
                global_mask  = np.copy(mask)
                global_data  = keep*var.data[i]
            else:
                global_mask *= mask
                global_data += keep*var.data[i]
        return Variable(name      = var.name,
                        unit      = var.unit,
                        data      = np.ma.masked_array(global_data,mask=global_mask),
                        lat       = lat,
                        lon       = lon)

    def confront(self,m):
        """The analysis portion applied to basins as if they were datasites

        Parameters
        ----------
        m : ILAMB.ModelResult.ModelResult
            the model result context
        """
        # Grab the data
        obs,mod = self.stageData(m)
        
        # Basic analysis from ilamblib.AnalysisMeanState() for
        # datasites and only the global region
        obs_timeint     = obs.integrateInTime(mean=True)
        mod_timeint     = mod.integrateInTime(mean=True)
        bias_map        = obs_timeint.bias(mod_timeint)
        normalizer      = obs_timeint.data
        bias_score_map  = il.Score(bias_map,obs_timeint)
        obs_period_mean = obs_timeint    .siteStats()
        mod_period_mean = mod_timeint    .siteStats()
        bias            = bias_map       .siteStats()
        bias_score      = bias_score_map .siteStats(weight=normalizer)
        std,R,sd_score  = obs_timeint.spatialDistribution(mod_timeint)
        obs_iav_map     = obs.interannualVariability()
        mod_iav_map     = mod.interannualVariability()
        iav_score_map   = obs_iav_map.spatialDifference(mod_iav_map)
        iav_score_map   = il.Score(iav_score_map,obs_iav_map)
        iav_score       = iav_score_map.siteStats()

        # Extend a few quantities from datasites to their
        # corresponding basins (plotting only)
        obs_timeint     = self._extendSitesToMap(obs_timeint)
        mod_timeint     = self._extendSitesToMap(mod_timeint)
        bias_map        = self._extendSitesToMap(bias_map)

        # Rename some quantities for parsing later in the HTML
        # generation
        obs_period_mean.name = "Period Mean global"
        mod_period_mean.name = "Period Mean global"
        bias           .name = "Bias global"
        bias_score     .name = "Bias Score global"
        sd_score       .name = "Spatial Distribution Score global"
        obs_timeint    .name = "timeint_of_runoff"
        mod_timeint    .name = "timeint_of_runoff"
        bias_map       .name = "bias_map_of_runoff"
        iav_score      .name = "Interannual Variability Score global"

        # Dump to files
        results = Dataset(os.path.join(self.output_path,"%s_%s.nc" % (self.name,m.name)),mode="w")
        results.setncatts({"name" :m.name, "color":m.color})
        for var in [mod,
                    mod_period_mean,
                    mod_timeint,
                    bias,
                    bias_score,
                    bias_map,
                    iav_score]:
            var.toNetCDF4(results,group="MeanState")
        sd_score.toNetCDF4(results,group="MeanState",attributes={"std":std.data,"R":R.data})
        results.close()
        if self.master:
            results = Dataset(os.path.join(self.output_path,"%s_Benchmark.nc" % self.name),mode="w")
            results.setncatts({"name" :"Benchmark", "color":np.asarray([0.5,0.5,0.5])})
            for var in [obs,
                        obs_period_mean,
                        obs_timeint]:
                var.toNetCDF4(results,group="MeanState")
            results.close()

    def modelPlots(self,m):

        # some of the plots can be generated using the standard
        # routine, with some modifications
        super(ConfRunoff,self).modelPlots(m)

        # 
        bname = os.path.join(self.output_path,"%s_Benchmark.nc" % (self.name       ))
        fname = os.path.join(self.output_path,"%s_%s.nc"        % (self.name,m.name))
        
        # get the HTML page
        page = [page for page in self.layout.pages if "MeanState" in page.name][0]  
    
        if not os.path.isfile(bname): return
        if not os.path.isfile(fname): return
        obs = Variable(filename = bname, variable_name = "runoff", groupname = "MeanState")
        mod = Variable(filename = fname, variable_name = "runoff", groupname = "MeanState")
        for i,basin in enumerate(self.basins):

            page.addFigure("Spatially integrated regional mean",
                           basin,
                           "MNAME_global_%s.png" % basin,
                           basin,False,longname=basin)
            
            fig,ax = plt.subplots(figsize=(6.8,2.8),tight_layout=True)
            ax.plot(obs.time/365+1850,obs.data[:,i],lw=2,color='k',alpha=0.5)
            ax.plot(mod.time/365+1850,mod.data[:,i],lw=2,color=m.color      )
            ax.grid()
            ax.set_ylabel(post.UnitStringToMatplotlib(obs.unit))
            fig.savefig(os.path.join(self.output_path,"%s_global_%s.png" % (m.name,basin)))
            plt.close()
