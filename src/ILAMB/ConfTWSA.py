from Confrontation import Confrontation
import matplotlib.pyplot as plt
from Variable import Variable
from Regions import Regions
from netCDF4 import Dataset
import ilamblib as il
import Post as post
import numpy as np
import os

class ConfTWSA(Confrontation):
    """A confrontation for examining the terrestrial water storage anomaly.

    """
    def __init__(self,**keywords):

        # Ugly, but this is how we call the Confrontation constructor
        super(ConfTWSA,self).__init__(**keywords)

        # Now we overwrite some things which are different here
        self.weight = {"Diff Score"                    :1.,
                       "RMSE Score"                    :2.,
                       "Seasonal Cycle Score"          :1.,
                       "Interannual Variability Score" :1.,
                       "Spatial Distribution Score"    :1.}
        
        # Now we overwrite some things which are different here
        self.regions        = ['global']
        self.layout.regions = self.regions

        # Adding a member variable called basins, add them as regions
        r = Regions()
        nbasins = self.keywords.get("nbasins",30)
        self.basins = r.addRegionNetCDF4(os.path.join("/".join(self.source.split("/")[:-3]),"runoff/Dai/basins_0.5x0.5.nc"))[:nbasins]

    def stageData(self,m):
        r"""Extracts model data which is comparable to the observations.

        The observational data measure the anomaly in terrestrial
        water storage, 'twsa' in terms of [kg m-2]. We convert this
        unit to [cm] using the density of water. The models are
        expected to provide the terrestrial water storage variable,
        'tws', and we need to find the anomaly. First, the model
        result is trimmed to match the temporal extents of the
        observational data. Then, to get the anomaly, we subtract off
        the temporal mean,

        .. math:: \mathit{twsa}(t,\mathbf{x}) = tws(t,\mathbf{x}) - \frac{1}{t_f-t_0}\int_{t_0}^{t_f} tws(t,\mathbf{x})\ dt 

        We do this for the model 'tws' variable, and optionally for
        the observation, treating its 'twsa' variable as 'tws' in the
        above expression. This is because the observational data can
        have a small mean even though it represents only the anomaly.

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
        # get the observational data
        obs = Variable(filename       = self.source,
                       variable_name  = self.variable,
                       alternate_vars = self.alternate_vars).convert("cm")

        # get the model data, in the units of the obseravtions
        mod = m.extractTimeSeries(self.variable,
                                  alt_vars     = self.alternate_vars,
                                  expression   = self.derived,
                                  initial_time = obs.time_bnds[ 0,0],
                                  final_time   = obs.time_bnds[-1,1])

        # if the derived expression is used, then we get a mass flux
        # rate and need to accumulate
        try:
            mod.convert(obs.unit)
        except:
            mod = mod.accumulateInTime()
            mod.name = obs.name
        obs,mod = il.MakeComparable(obs,mod,clip_ref=True)

        # subtract off the mean
        mean      = obs.integrateInTime(mean=True)
        obs.data -= mean.data
        mean      = mod.integrateInTime(mean=True)
        mod.data -= mean.data

        # compute mean values over each basin
        odata = np.ma.zeros((obs.time.size,len(self.basins)))
        mdata = np.ma.zeros((mod.time.size,len(self.basins)))
        for i,basin in enumerate(self.basins):
            odata[:,i] = obs.integrateInSpace(region=basin,mean=True).data
            mdata[:,i] = mod.integrateInSpace(region=basin,mean=True).data
        obs.data = odata; obs.ndata = odata.shape[1]; obs.spatial = False
        mod.data = mdata; mod.ndata = mdata.shape[1]; mod.spatial = False
        mod.data.mask = obs.data.mask
        
        return obs,mod

    def requires(self):
        return ["tws"],[]
        
    def confront(self,m):
        """Confront the GRACE data by computing a mean over river
        basins. Fine-scale, point comparisons aren't meaningful as the
        underlying resolution of the GRACE data is 300-400 [m]. See
        the following publication for more information.

        Swenson, Sean & National Center for Atmospheric Research Staff
        (Eds). Last modified 08 Oct 2013. "The Climate Data Guide:
        GRACE: Gravity Recovery and Climate Experiment: Surface mass,
        total water storage, and derived variables." Retrieved from
        https://climatedataguide.ucar.edu/climate-data/grace-gravity-recovery-and-climate-experiment-surface-mass-total-water-storage-and.

        """
        obs,mod = self.stageData(m)

        # find the magnitude of the anomaly
        obs_anom     = obs.rms()
        obs_anom_val = obs_anom.siteStats()
        mod_anom     = mod.rms()
        mod_anom_val = mod_anom.siteStats()      
        rmse         = obs.rmse(mod).convert(obs.unit)
        rmse_val     = rmse.siteStats()
        rmse_smap    = Variable(name = "",
                                unit = "1",
                                data = np.exp(-rmse.data/obs_anom.data),
                                ndata = obs.ndata,
                                lat   = obs.lat,
                                lon   = obs.lon)
        rmse_score   = rmse_smap.siteStats()
        iav_score    = Variable(name = "Interannual Variability Score global",
                                unit = "1",
                                data = np.exp(-np.abs(mod_anom_val.data-obs_anom_val.data)/obs_anom_val.data))
        
        # remap for plotting
        obs_anom_map = self._extendSitesToMap(obs_anom )
        mod_anom_map = self._extendSitesToMap(mod_anom )
        rmse_map     = self._extendSitesToMap(rmse     )
        rmse_smap    = self._extendSitesToMap(rmse_smap)
        
        # renames
        obs_anom_val.name = "Anomaly Magnitude global"
        mod_anom_val.name = "Anomaly Magnitude global"
        obs_anom_map.name = "timeint_of_anomaly"
        mod_anom_map.name = "timeint_of_anomaly"
        rmse_map    .name = "rmse_of_anomaly"
        rmse_smap   .name = "rmsescore_of_anomaly"
        rmse_val    .name = "RMSE global"
        rmse_score  .name = "RMSE Score global"
        
        # dump results to a netCDF4 file
        results = Dataset(os.path.join(self.output_path,"%s_%s.nc" % (self.name,m.name)),mode="w")
        results.setncatts({"name" :m.name, "color":m.color})
        mod         .toNetCDF4(results,group="MeanState")
        mod_anom_val.toNetCDF4(results,group="MeanState")
        mod_anom_map.toNetCDF4(results,group="MeanState")
        rmse_map    .toNetCDF4(results,group="MeanState")
        rmse_smap   .toNetCDF4(results,group="MeanState")
        rmse_val    .toNetCDF4(results,group="MeanState")
        rmse_score  .toNetCDF4(results,group="MeanState")
        iav_score   .toNetCDF4(results,group="MeanState")
        results.close()
        if self.master:
            results = Dataset(os.path.join(self.output_path,"%s_Benchmark.nc" % (self.name)),mode="w")
            results.setncatts({"name" :"Benchmark", "color":np.asarray([0.5,0.5,0.5])})
            obs.toNetCDF4(results,group="MeanState")
            obs_anom_val.toNetCDF4(results,group="MeanState")
            obs_anom_map.toNetCDF4(results,group="MeanState")
            results.close()

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
    
    def modelPlots(self,m):

        # some of the plots can be generated using the standard
        # routine, with some modifications
        super(ConfTWSA,self).modelPlots(m)
        for page in self.layout.pages:
            for sec in page.figures.keys():
                for fig in page.figures[sec]:
                    fig.side = fig.side.replace("MEAN","ANOMALY MAGNITUDE")

        # 
        bname = os.path.join(self.output_path,"%s_Benchmark.nc" % (self.name       ))
        fname = os.path.join(self.output_path,"%s_%s.nc"        % (self.name,m.name))
        
        # get the HTML page
        page = [page for page in self.layout.pages if "MeanState" in page.name][0]  

        if not os.path.isfile(bname): return
        if not os.path.isfile(fname): return
        obs = Variable(filename = bname, variable_name = "twsa", groupname = "MeanState")
        mod = Variable(filename = fname, variable_name = "twsa", groupname = "MeanState")
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

