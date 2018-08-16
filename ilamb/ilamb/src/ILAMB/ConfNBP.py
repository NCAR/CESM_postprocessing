from Confrontation import Confrontation
from Variable import Variable
from netCDF4 import Dataset
from copy import deepcopy
import ilamblib as il
import pylab as plt
import Post as post
import numpy as np
import os,glob

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
        mod  = m.extractTimeSeries(self.variable,
                                   alt_vars = self.alternate_vars)
        mod  = mod.integrateInSpace().convert(obs.unit)
        tmin = mod.time_bnds[ 0,0]
        tmax = mod.time_bnds[-1,1]        
        obs,mod = il.MakeComparable(obs,mod,clip_ref=True)

        # The obs can go beyond the information which models have
        obs.trim(t=[tmin,tmax])
        mod.trim(t=[tmin,tmax])
        
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
        obs_sum = obs.accumulateInTime().convert("Pg")
        mod_sum = mod.accumulateInTime().convert("Pg")
        
        # End of period information
        yf = np.round(obs.time_bnds[-1,1]/365.+1850.)
        obs_end = Variable(name = "nbp(%4d)" % yf,
                           unit = obs_sum.unit,
                           data = obs_sum.data[-1])
        mod_end = Variable(name = "nbp(%4d)" % yf,
                           unit = mod_sum.unit,
                           data = mod_sum.data[-1])
        mod_diff = Variable(name = "diff(%4d)" % yf,
                            unit = mod_sum.unit,
                            data = mod_sum.data[-1]-obs_sum.data[-1])

        # Difference score normlized by the uncertainty in the
        # accumulation at the end of the time period.
        normalizer = 0.
        if "GCP"     in self.longname: normalizer = 21.6*0.5
        if "Hoffman" in self.longname: normalizer = 84.6*0.5
        dscore = Variable(name = "Difference Score global" % yf,
                          unit = "1",
                          data = np.exp(-0.287*np.abs(mod_diff.data/normalizer)))

        # Temporal distribution
        skip_taylor = self.keywords.get("skip_taylor",False)
        if not skip_taylor:
            np.seterr(over='ignore',under='ignore')
            std0 = obs.data.std()
            std  = mod.data.std()
            np.seterr(over='raise' ,under='raise' )
            R0    = 1.0
            R     = obs.correlation(mod,ctype="temporal")
            std  /= std0
            score = Variable(name = "Temporal Distribution Score global",
                             unit = "1",
                             data = 4.0*(1.0+R.data)/((std+1.0/std)**2 *(1.0+R0)))
        
        # Change names to make things easier to parse later
        obs     .name = "spaceint_of_nbp_over_global"
        mod     .name = "spaceint_of_nbp_over_global"
        obs_sum .name = "accumulate_of_nbp_over_global"
        mod_sum .name = "accumulate_of_nbp_over_global"
        
        # Dump to files
        results = Dataset(os.path.join(self.output_path,"%s_%s.nc" % (self.name,m.name)),mode="w")
        results.setncatts({"name" :m.name, "color":m.color})
        mod       .toNetCDF4(results,group="MeanState")
        mod_sum   .toNetCDF4(results,group="MeanState")
        mod_end   .toNetCDF4(results,group="MeanState")
        mod_diff  .toNetCDF4(results,group="MeanState")
        dscore    .toNetCDF4(results,group="MeanState")
        if not skip_taylor:
            score .toNetCDF4(results,group="MeanState",attributes={"std":std,"R":R.data})
        results.close()
        
        if self.master:
            results = Dataset(os.path.join(self.output_path,"%s_Benchmark.nc" % (self.name)),mode="w")
            results.setncatts({"name" :"Benchmark", "color":np.asarray([0.5,0.5,0.5])})
            obs     .toNetCDF4(results,group="MeanState")
            obs_sum .toNetCDF4(results,group="MeanState")
            obs_end .toNetCDF4(results,group="MeanState")
            results.close()
            
        
    def compositePlots(self):

        # we want to run the original and also this additional plot
        super(ConfNBP,self).compositePlots()

        # get the HTML page
        page = [page for page in self.layout.pages if "MeanState" in page.name][0]

        colors = {}
        corr   = {}
        std    = {}
        accum  = {}
        for fname in glob.glob(os.path.join(self.output_path,"*.nc")):
            dataset = Dataset(fname)
            if "MeanState" not in dataset.groups: continue
            dset  = dataset.groups["MeanState"]
            mname = dataset.getncattr("name")
            colors[mname] = dataset.getncattr("color")
            key = [v for v in dset.groups["scalars"].variables.keys() if ("Temporal Distribution Score" in v)]
            if len(key) > 0:
                sds = dset.groups["scalars"].variables[key[0]]
                corr[mname] = sds.R
                std [mname] = sds.std
            if "accumulate_of_nbp_over_global" in dset.variables.keys():
                accum[mname] = Variable(filename      = fname,
                                        variable_name = "accumulate_of_nbp_over_global",
                                        groupname     = "MeanState")
        
        # temporal distribution Taylor plot
        if len(corr) > 0:
            page.addFigure("Spatially integrated regional mean",
                           "temporal_variance",
                           "temporal_variance.png",
                           side   = "TEMPORAL TAYLOR DIAGRAM",
                           legend = False)       
            fig = plt.figure(figsize=(6.0,6.0))
            keys = corr.keys()
            post.TaylorDiagram(np.asarray([std [key] for key in keys]),
                               np.asarray([corr[key] for key in keys]),
                               1.0,fig,
                               [colors[key] for key in keys])
            fig.savefig(os.path.join(self.output_path,"temporal_variance.png"))
            plt.close()
            

        # composite annual cycle plot
        if len(accum) > 1:
            page.addFigure("Spatially integrated regional mean",
                           "compaccumulation",
                           "RNAME_compaccumulation.png",
                           side   = "ACCUMULATION",
                           legend = False)
            fig,ax = plt.subplots(figsize=(6.8,2.8),tight_layout=True)
            dy = 0.05*(self.limits["accumulate"]["global"]["max"]-self.limits["accumulate"]["global"]["min"])
            for key in accum:
                accum[key].plot(ax,lw=2,color=colors[key],label=key,
                                vmin=self.limits["accumulate"]["global"]["min"]-dy,
                                vmax=self.limits["accumulate"]["global"]["max"]+dy)
            fig.savefig(os.path.join(self.output_path,"global_compaccumulation.png" ))
            plt.close()
