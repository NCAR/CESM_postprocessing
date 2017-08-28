from Confrontation import Confrontation
from Variable import Variable
from netCDF4 import Dataset
from copy import deepcopy
import ilamblib as il
import Post as post
import numpy as np
import os

class ConfNBP(Confrontation):
    """A confrontation for examining the global net ecosystem carbon balance.

    """
    def __init__(self,**keywords):
        
        # Ugly, but this is how we call the Confrontation constructor
        super(ConfNBP,self).__init__(**keywords)

        # Now we overwrite some things which are different here
        self.regions        = ['global']
        self.layout.regions = self.regions
        
    def stageData(self,m):
        r"""Extracts model data and integrates it over the globe to match the confrontation dataset.

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
                       alternate_vars = self.alternate_vars)

        # the model data needs integrated over the globe
        mod = m.extractTimeSeries(self.variable,
                                  alt_vars = self.alternate_vars)
        mod = mod.integrateInSpace().convert(obs.unit)
        
        obs,mod = il.MakeComparable(obs,mod,clip_ref=True)

        # sign convention is backwards
        obs.data *= -1.
        mod.data *= -1.
        
        return obs,mod

    def confront(self,m):
        r"""Confronts the input model with the observational data.
        
        Parameters
        ----------
        m : ILAMB.ModelResult.ModelResult
            the model results

        """
        # Grab the data
        obs,mod = self.stageData(m)
        
        obs_sum  = obs.accumulateInTime().convert("Pg")
        mod_sum  = mod.accumulateInTime().convert("Pg")        
        obs_mean = obs.integrateInTime(mean=True)
        mod_mean = mod.integrateInTime(mean=True)
        bias     = obs.bias(mod)
        rmse     = obs.rmse(mod)

        # bias score = exp( abs( relative L1 norm of obs-mod ) )
        obs_L1       = obs.integrateInTime()
        dif_L1       = deepcopy(obs)
        dif_L1.data -= mod.data
        dif_L1       = dif_L1.integrateInTime()
        bias_score   = Variable(name = "Bias Score global",
                                unit = "1",
                                data = np.exp(-np.abs(dif_L1.data/obs_L1.data)))

        # rmse score = exp( relative L2 norm of obs-mod )
        obs_L2       = deepcopy(obs)
        obs_L2.data *= obs_L2.data
        obs_L2       = obs_L2.integrateInTime()
        dif_L2       = deepcopy(obs)
        dif_L2.data  = (dif_L2.data-mod.data)**2
        dif_L2       = dif_L2.integrateInTime()
        rmse_score   = Variable(name = "RMSE Score global",
                                unit = "1",
                                data = np.exp(-np.sqrt(dif_L2.data/obs_L2.data)))
        
        # change names to make things easier to parse later
        obs     .name = "spaceint_of_nbp_over_global"
        mod     .name = "spaceint_of_nbp_over_global"
        obs_sum .name = "accumulate_of_nbp_over_global"
        mod_sum .name = "accumulate_of_nbp_over_global"
        obs_mean.name = "Period Mean global"
        mod_mean.name = "Period Mean global"
        bias    .name = "Bias global"       
        rmse    .name = "RMSE global"       

        # Dump to files
        results = Dataset("%s/%s_%s.nc" % (self.output_path,self.name,m.name),mode="w")
        results.setncatts({"name" :m.name, "color":m.color})
        mod       .toNetCDF4(results,group="MeanState")
        mod_sum   .toNetCDF4(results,group="MeanState")
        mod_mean  .toNetCDF4(results,group="MeanState")
        bias      .toNetCDF4(results,group="MeanState")
        rmse      .toNetCDF4(results,group="MeanState")
        bias_score.toNetCDF4(results,group="MeanState")
        rmse_score.toNetCDF4(results,group="MeanState")
        results.close()
        
        if self.master:
            results = Dataset("%s/%s_Benchmark.nc" % (self.output_path,self.name),mode="w")
            results.setncatts({"name" :"Benchmark", "color":np.asarray([0.5,0.5,0.5])})
            obs     .toNetCDF4(results,group="MeanState")
            obs_sum .toNetCDF4(results,group="MeanState")
            obs_mean.toNetCDF4(results,group="MeanState")
            results.close()
            
        
