from ILAMB.Confrontation import Confrontation,FileContextManager
from mpl_toolkits.basemap import Basemap
from ILAMB.Variable import Variable
from netCDF4 import Dataset
import ILAMB.ilamblib as il
import numpy as np
import os
from mpi4py import MPI

import logging
logger = logging.getLogger("%i" % MPI.COMM_WORLD.rank)

def _albedo(dn,up,vname,energy_threshold):
    mask    = (dn.data < energy_threshold)
    dn.data = np.ma.masked_array(dn.data,mask=mask)
    up.data = np.ma.masked_array(up.data,mask=mask)
    np.seterr(over='ignore',under='ignore')
    al      = np.ma.masked_array(up.data/dn.data,mask=mask)
    np.seterr(over='warn',under='warn')
    al      = Variable(name      = vname,
                       unit      = "1",
                       data      = al,
                       lat       = dn.lat,
                       lat_bnds  = dn.lat_bnds,
                       lon       = dn.lon,
                       lon_bnds  = dn.lon_bnds,
                       time      = dn.time,
                       time_bnds = dn.time_bnds)
    return dn,up,al
    
class ConfAlbedo(Confrontation):

    def stageData(self,m):

        energy_threshold = float(self.keywords.get("energy_threshold",10))

        # Handle obs data
        dn_obs = Variable(filename      = self.source.replace("albedo","rsds"),
                          variable_name = "rsds")
        up_obs = Variable(filename      = self.source.replace("albedo","rsus"),
                          variable_name = "rsus")
        dn_obs,up_obs,obs = _albedo(dn_obs,up_obs,self.variable,energy_threshold)

        # Prune out uncovered regions
        if obs.time is None: raise il.NotTemporalVariable()
        self.pruneRegions(obs)

        # Handle model data
        dn_mod = m.extractTimeSeries("rsds",
                                     initial_time = obs.time_bnds[ 0,0],
                                     final_time   = obs.time_bnds[-1,1],
                                     lats         = None if obs.spatial else obs.lat,
                                     lons         = None if obs.spatial else obs.lon)
        up_mod = m.extractTimeSeries("rsus",
                                     initial_time = obs.time_bnds[ 0,0],
                                     final_time   = obs.time_bnds[-1,1],
                                     lats         = None if obs.spatial else obs.lat,
                                     lons         = None if obs.spatial else obs.lon)
        dn_mod,up_mod,mod = _albedo(dn_mod,up_mod,self.variable,energy_threshold)
        
        # Make variables comparable
        obs,mod = il.MakeComparable(obs,mod,
                                    mask_ref  = True,
                                    clip_ref  = True,
                                    logstring = "[%s][%s]" % (self.longname,m.name))
        dn_obs,dn_mod = il.MakeComparable(dn_obs,dn_mod,
                                          mask_ref  = True,
                                          clip_ref  = True,
                                          logstring = "[%s][%s]" % (self.longname,m.name))
        up_obs,up_mod = il.MakeComparable(up_obs,up_mod,
                                          mask_ref  = True,
                                          clip_ref  = True,
                                          logstring = "[%s][%s]" % (self.longname,m.name))
        
        # Compute the mean albedo
        dn_obs = dn_obs.integrateInTime(mean=True)
        up_obs = up_obs.integrateInTime(mean=True)
        np.seterr(over='ignore',under='ignore')
        obs_timeint = np.ma.masked_array(up_obs.data/dn_obs.data,mask=(dn_obs.data.mask+up_obs.data.mask))
        np.seterr(over='warn',under='warn')
        obs_timeint = Variable(name      = self.variable,
                               unit      = "1",
                               data      = obs_timeint,
                               lat       = dn_obs.lat,
                               lat_bnds  = dn_obs.lat_bnds,
                               lon       = dn_obs.lon,
                               lon_bnds  = dn_obs.lon_bnds)
        dn_mod = dn_mod.integrateInTime(mean=True)
        up_mod = up_mod.integrateInTime(mean=True)
        np.seterr(over='ignore',under='ignore')
        mod_timeint = np.ma.masked_array(up_mod.data/dn_mod.data,mask=(dn_mod.data.mask+up_mod.data.mask))
        np.seterr(over='warn',under='warn')
        mod_timeint = Variable(name      = self.variable,
                               unit      = "1",
                               data      = mod_timeint,
                               lat       = dn_mod.lat,
                               lat_bnds  = dn_mod.lat_bnds,
                               lon       = dn_mod.lon,
                               lon_bnds  = dn_mod.lon_bnds)
        
        return obs,mod,obs_timeint,mod_timeint
    
    def requires(self):
        return ['rsus','rsds'],[]

    def confront(self,m):
        r"""Confronts the input model with the observational data.

        This routine is exactly the same as Confrontation except that
        user-provided period means are passed as options to the analysis.

        Parameters
        ----------
        m : ILAMB.ModelResult.ModelResult
            the model results

        """
        # Grab the data
        obs,mod,obs_timeint,mod_timeint = self.stageData(m)
        
        mod_file = os.path.join(self.output_path,"%s_%s.nc"        % (self.name,m.name))
        obs_file = os.path.join(self.output_path,"%s_Benchmark.nc" % (self.name,      ))
        with FileContextManager(self.master,mod_file,obs_file) as fcm:

            # Encode some names and colors
            fcm.mod_dset.setncatts({"name" :m.name,
                                    "color":m.color})
            if self.master:
                fcm.obs_dset.setncatts({"name" :"Benchmark",
                                        "color":np.asarray([0.5,0.5,0.5])})
                
            # Read in some options and run the mean state analysis
            mass_weighting = self.keywords.get("mass_weighting",False)
            skip_rmse      = self.keywords.get("skip_rmse"     ,False)
            skip_iav       = self.keywords.get("skip_iav"      ,False)
            skip_cycle     = self.keywords.get("skip_cycle"    ,False)
            if obs.spatial:
                il.AnalysisMeanStateSpace(obs,mod,dataset   = fcm.mod_dset,
                                          regions           = self.regions,
                                          benchmark_dataset = fcm.obs_dset,
                                          table_unit        = self.table_unit,
                                          plot_unit         = self.plot_unit,
                                          space_mean        = self.space_mean,
                                          skip_rmse         = skip_rmse,
                                          skip_iav          = skip_iav,
                                          skip_cycle        = skip_cycle,
                                          mass_weighting    = mass_weighting,
                                          ref_timeint       = obs_timeint,
                                          com_timeint       = mod_timeint)
            else:
                il.AnalysisMeanStateSites(obs,mod,dataset   = fcm.mod_dset,
                                          regions           = self.regions,
                                          benchmark_dataset = fcm.obs_dset,
                                          table_unit        = self.table_unit,
                                          plot_unit         = self.plot_unit,
                                          space_mean        = self.space_mean,
                                          skip_rmse         = skip_rmse,
                                          skip_iav          = skip_iav,
                                          skip_cycle        = skip_cycle,
                                          mass_weighting    = mass_weighting)

        logger.info("[%s][%s] Success" % (self.longname,m.name))
