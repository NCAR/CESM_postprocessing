from Confrontation import Confrontation
from Variable import Variable
from netCDF4 import Dataset
from copy import deepcopy
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
                                  alt_vars = self.alternate_vars).convert(obs.unit)
        obs,mod   = il.MakeComparable(obs,mod,clip_ref=True)

        # subtract off the mean
        mean      = obs.integrateInTime(mean=True)
        obs.data -= mean.data
        mean      = mod.integrateInTime(mean=True)
        mod.data -= mean.data
        
        return obs,mod

    def requires(self):
        return ["tws"],[]
        
    def confront(self,m):
        """Confront

        .. math:: \sigma(\mathbf{x}) = \sqrt{\frac{1}{t_f-t_0}\int_{t_0}^{t_f} (twsa(t,\mathbf{x})-0)^2\ dt }

        """

        obs,mod = self.stageData(m)
        assert obs.spatial == mod.spatial == True
        
        # Get the standard deviation of the anomaly for both the
        # observation and the model
        obs_std       = deepcopy(obs)
        np.seterr(under='ignore',over='ignore')
        obs_std.data *= obs_std.data
        np.seterr(under='raise',over='raise')
        obs_std       = obs_std.integrateInTime(mean=True)
        obs_std.data  = np.ma.sqrt(obs_std.data)
        mod_std       = deepcopy(mod)
        np.seterr(under='ignore',over='ignore')
        mod_std.data *= mod_std.data
        np.seterr(under='raise',over='raise')
        mod_std       = mod_std.integrateInTime(mean=True)
        mod_std.data  = np.ma.sqrt(mod_std.data)

        # Difference map of the standard deviations
        diff          = obs_std.spatialDifference(mod_std)
        diff.name     = "diff"
        
        # RMSE of the anomaly
        rmse          = obs.rmse(mod)

        # Diff and RMSE score maps
        obs_std_int  = obs_std.interpolate(lat=diff.lat,lon=diff.lon)
        diff_score   = il.Score(diff,obs_std_int)
        rmse_mean    = rmse.integrateInSpace(mean=True)
        rmse_score   = il.Score(rmse,rmse_mean)
        
        # Compute quantities over regions
        obs_s         = {}
        obs_s["std"]  = {}
        obs_spaceint  = {}
        mod_s         = {}
        mod_s["std"]  = {}
        mod_s["diff"] = {}
        mod_s["rmse"] = {}
        mod_s["diff score"] = {}
        mod_s["rmse score"] = {}
        mod_spaceint  = {}
        for region in self.regions:

            # Scalars
            obs_s["std"       ][region] = obs_std   .integrateInSpace(region=region,mean=True)
            mod_s["std"       ][region] = mod_std   .integrateInSpace(region=region,mean=True)
            mod_s["diff"      ][region] = diff      .integrateInSpace(region=region,mean=True)
            mod_s["rmse"      ][region] = rmse      .integrateInSpace(region=region,mean=True)
            mod_s["diff score"][region] = diff_score.integrateInSpace(region=region,mean=True)
            mod_s["rmse score"][region] = rmse_score.integrateInSpace(region=region,mean=True)

            # Spatial integrals
            obs_spaceint[region]  = obs    .integrateInSpace(region=region,mean=True)
            mod_spaceint[region]  = mod    .integrateInSpace(region=region,mean=True)
            
            # Change names
            obs_s["std" ]      [region].name = "Period Mean Anomaly Std %s" % region
            mod_s["std" ]      [region].name = "Period Mean Anomaly Std %s" % region
            mod_s["diff"]      [region].name = "Std Difference %s"          % region
            mod_s["rmse"]      [region].name = "Anomaly RMSE %s"            % region
            mod_s["diff score"][region].name = "Diff Score %s"              % region
            mod_s["rmse score"][region].name = "RMSE Score %s"              % region
            obs_spaceint       [region].name = "spaceint_of_twsa_over_%s"   % region
            mod_spaceint       [region].name = "spaceint_of_twsa_over_%s"   % region
        
        # Change names
        obs_std.name = "timeint_of_twsa"
        mod_std.name = "timeint_of_twsa"
        diff   .name = "bias_of_twsa"
        
        # Dump results to a netCDF4 file
        results = Dataset(os.path.join(self.output_path,"%s_%s.nc" % (self.name,m.name)),mode="w")
        results.setncatts({"name" :m.name, "color":m.color})
        mod_std     .toNetCDF4(results,group="MeanState")
        diff        .toNetCDF4(results,group="MeanState")
        for region in self.regions: mod_spaceint[region].toNetCDF4(results,group="MeanState")
        for key in mod_s.keys():
            for region in self.regions: mod_s[key][region].toNetCDF4(results,group="MeanState")
        results.close()

        # If you are the master, dump Benchmark quantities too
        if self.master:
            results = Dataset(os.path.join(self.output_path,"%s_Benchmark.nc" % (self.name)),mode="w")
            results.setncatts({"name" :"Benchmark", "color":np.asarray([0.5,0.5,0.5])})
            obs_std     .toNetCDF4(results,group="MeanState")
            for region in self.regions: obs_spaceint[region].toNetCDF4(results,group="MeanState")
            for key in obs_s.keys():
                for region in self.regions:
                    obs_s[key][region].toNetCDF4(results,group="MeanState")
            results.close()

    def modelPlots(self,m):
        
        super(ConfTWSA,self).modelPlots(m)

        for page in self.layout.pages:
            for sec in page.figures.keys():
                for fig in page.figures[sec]:
                    fig.side = fig.side.replace("MEAN","ANOMALY")
                    fig.side = fig.side.replace("BIAS","DIFFERENCE")
