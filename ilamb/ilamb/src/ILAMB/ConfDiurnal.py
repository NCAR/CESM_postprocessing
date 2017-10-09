from ILAMB.Confrontation import Confrontation
from ILAMB.Confrontation import getVariableList
import matplotlib.pyplot as plt
import ILAMB.Post as post
from scipy.interpolate import CubicSpline
from mpl_toolkits.basemap import Basemap
from ILAMB.Variable import Variable
from netCDF4 import Dataset
import ILAMB.ilamblib as il
import numpy as np
import os,glob

def DiurnalReshape(var):
    dt    = (var.time_bnds[:,1]-var.time_bnds[:,0]).mean()
    spd   = int(round(1./dt))
    begin = np.argmin(var.time[:(spd-1)]%spd)
    end   = begin+int(var.time[begin:].size/float(spd))*spd
    shp   = (-1,spd) + var.data.shape[1:]
    cycle = var.data[begin:end].reshape(shp)
    tbnd  = var.time_bnds[begin:end,:].reshape((-1,spd,2)) % 1
    tbnd  = tbnd[0,...]
    tbnd[-1,1] = 1.
    t     = tbnd.mean(axis=1)
    return cycle,t,tbnd

class ConfDiurnal(Confrontation):
    """A confrontation for examining the diurnal 
    """
    def __init__(self,**keywords):

        # Calls the regular constructor
        super(ConfDiurnal,self).__init__(**keywords)

        # Setup a html layout for generating web views of the results
        pages = []

        # Mean State page
        pages.append(post.HtmlPage("MeanState","Mean State"))
        pages[-1].setHeader("CNAME / RNAME / MNAME")
        pages[-1].setSections(["Diurnal cycle"])
        pages.append(post.HtmlAllModelsPage("AllModels","All Models"))
        pages[-1].setHeader("CNAME / RNAME")
        pages[-1].setSections([])
        pages[-1].setRegions(self.regions)
        pages.append(post.HtmlPage("DataInformation","Data Information"))
        pages[-1].setSections([])
        pages[-1].text = "\n"
        with Dataset(self.source) as dset:
            for attr in dset.ncattrs():
                pages[-1].text += "<p><b>&nbsp;&nbsp;%s:&nbsp;</b>%s</p>\n" % (attr,dset.getncattr(attr).encode('ascii','ignore'))
        self.layout = post.HtmlLayout(pages,self.longname)
        
    def stageData(self,m):

        obs = Variable(filename       = self.source,
                       variable_name  = self.variable,
                       alternate_vars = self.alternate_vars)
        if obs.time is None: raise il.NotTemporalVariable()
        self.pruneRegions(obs)
        
        # Try to extract a commensurate quantity from the model
        mod = m.extractTimeSeries(self.variable,
                                  alt_vars     = self.alternate_vars,
                                  expression   = self.derived,
                                  initial_time = obs.time_bnds[ 0,0],
                                  final_time   = obs.time_bnds[-1,1],
                                  lats         = None if obs.spatial else obs.lat,
                                  lons         = None if obs.spatial else obs.lon).convert(obs.unit)
        return obs,mod

    def confront(self,m):

        # get the HTML page
        page = [page for page in self.layout.pages if "MeanState" in page.name][0]
        
        # Grab the data
        obs,mod      = self.stageData(m)
        odata,ot,otb = DiurnalReshape(obs)
        mdata,mt,mtb = DiurnalReshape(mod)

        n            = len(self.lbls)
        obs_amp      = np.zeros(n)
        mod_amp      = np.zeros(n)
        amp_score    = np.zeros(n)
        obs_phase    = np.zeros(n)
        mod_phase    = np.zeros(n)
        phase_score  = np.zeros(n)
        for site in range(n):

            # Site name
            lbl   = self.lbls[site]
            skip  = False
            
            # Observational diurnal cycle
            tobs  = ot + obs.lon[site]/360
            vobs  = odata[...,site]
            vobs  = np.roll(vobs,-tobs.searchsorted(0),axis=1)
            tobs  = np.roll(tobs,-tobs.searchsorted(0))
            tobs += (tobs<0)
            aobs  = (vobs.max(axis=1)-vobs.min(axis=1)).mean()
            vobs  = vobs.mean(axis=0)
            if vobs.size == vobs.mask.sum(): skip = True
            if not skip:
                acyc  = CubicSpline(np.hstack([tobs,tobs[0]+1.]),
                                    np.hstack([vobs,vobs[0]   ]),
                                    bc_type="periodic")
                troot = acyc.derivative().solve()
                troot = troot[(troot>=0)*(troot<=1.)]
                otmx  = troot[acyc(troot).argmax()]
        
            # Model diurnal cycle
            tmod  = mt + mod.lon[site]/360
            vmod  = mdata[...,site]
            vmod  = np.roll(vmod,-tmod.searchsorted(0),axis=1)
            tmod  = np.roll(tmod,-tmod.searchsorted(0))
            tmod += (tmod<0)
            amod  = (vmod.max(axis=1)-vmod.min(axis=1)).mean()
            vmod  = vmod.mean(axis=0)
            mcyc  = CubicSpline(np.hstack([tmod,tmod[0]+1.]),
                                np.hstack([vmod,vmod[0]   ]),
                                bc_type="periodic")
            troot = mcyc.derivative().solve()
            troot = troot[(troot>=0)*(troot<=1.)]
            mtmx  = troot[mcyc(troot).argmax()]

            # Scalars and scores
            if skip:
                obs_amp    [site] = np.nan
                obs_phase  [site] = np.nan
                amp_score  [site] = np.nan
                phase_score[site] = np.nan
            else:
                obs_amp    [site] = aobs
                obs_phase  [site] = otmx
                amp_score  [site] = np.exp(-np.abs(amod-aobs)/aobs)
                phase_score[site] =       1-np.abs(mtmx-otmx)/0.5 
            mod_amp    [site] = amod
            mod_phase  [site] = mtmx

            # Plot
            ts     = np.linspace(0,1,100)
            fig,ax = plt.subplots(figsize=(6.8,2.8),tight_layout=True)
            if not skip:
                ax.plot(tobs,vobs,'o',mew=0,markersize=3,color='k')
                ax.plot(ts,acyc(ts),'-',color='k')
                ax.plot(otmx,acyc(otmx),'o',mew=0,markersize=5,color='k')
            ax.plot(tmod,vmod,'o',mew=0,markersize=3,color=m.color)
            ax.plot(ts,mcyc(ts),'-',color=m.color)
            ax.plot(mtmx,mcyc(mtmx),'o',mew=0,markersize=5,color=m.color)
            xt  = np.arange(25)[::3]
            xtl = ["%02d:00" % xx for xx in xt]
            ax.set_xticks     (xt/24.)
            ax.set_xticklabels(xtl   )
            ax.grid(True)
            ax.set_xlabel("Mean solar time")
            ax.set_ylabel("[%s]" % obs.unit)
            plt.savefig(os.path.join(self.output_path,"%s_diurnal_%s.png" % (m.name,lbl)))
            plt.close()

            obs_amp     = np.ma.masked_invalid(obs_amp)
            obs_phase   = np.ma.masked_invalid(obs_phase)
            amp_score   = np.ma.masked_invalid(amp_score)
            phase_score = np.ma.masked_invalid(phase_score)
            
            results = Dataset(os.path.join(self.output_path,"%s_%s.nc" % (self.name,m.name)),mode="w")
            results.setncatts({"name" :m.name, "color":m.color})
            Variable(name="Amplitude global"      ,unit=obs.unit,data=   mod_amp  .mean()).toNetCDF4(results,group="MeanState")
            Variable(name="Max time global"       ,unit="h"     ,data=24*mod_phase.mean()).toNetCDF4(results,group="MeanState")
            Variable(name="Amplitude Score global",unit="1"     ,data=   amp_score.mean()).toNetCDF4(results,group="MeanState")
            Variable(name="Phase Score global"    ,unit="1"     ,data= phase_score.mean()).toNetCDF4(results,group="MeanState")
            results.close()
            if self.master:
                results = Dataset(os.path.join(self.output_path,"%s_Benchmark.nc" % self.name),mode="w")
                results.setncatts({"name" :"Benchmark", "color":np.asarray([0.5,0.5,0.5])})
                Variable(name="Amplitude global"      ,unit=obs.unit,data=   obs_amp  .mean()).toNetCDF4(results,group="MeanState")
                Variable(name="Max time global"       ,unit="h"     ,data=24*obs_phase.mean()).toNetCDF4(results,group="MeanState")
                results.close()
                
    def modelPlots(self,m):
        
        bname  = "%s/%s_Benchmark.nc" % (self.output_path,self.name)
        fname  = "%s/%s_%s.nc" % (self.output_path,self.name,m.name)
        if not os.path.isfile(bname): return
        if not os.path.isfile(fname): return

        # get the HTML page
        page = [page for page in self.layout.pages if "MeanState" in page.name][0]
        page.priority = ["Amplitude","Max","Min","Max time","Bias","RMSE","Shift","Score","Overall"]

        for site in range(len(self.lbls)):

            # Site name
            lbl   = self.lbls[site]
            page.addFigure("Diurnal cycle",
                           lbl,
                           "MNAME_diurnal_%s.png" % lbl,
                           side   = lbl,
                           legend = False)

