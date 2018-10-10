from ILAMB.Confrontation import Confrontation
from mpl_toolkits.basemap import Basemap
from ILAMB.Variable import Variable
from netCDF4 import Dataset
import ILAMB.ilamblib as il
import numpy as np
import os

class ConfEvapFraction(Confrontation):

    def stageData(self,m):

        energy_threshold = float(self.keywords.get("energy_threshold",20.))
        sh  = Variable(filename       = os.path.join(os.environ["ILAMB_ROOT"],"DATA/sh/GBAF/sh_0.5x0.5.nc"),
                       variable_name  = "sh")
        le  = Variable(filename       = os.path.join(os.environ["ILAMB_ROOT"],"DATA/le/GBAF/le_0.5x0.5.nc"),
                       variable_name  = "le")
        obs = Variable(name      = self.variable,
                       unit      = "1",
                       data      = np.ma.masked_array(le.data/(le.data+sh.data),
                                                      mask=((le.data<0)+
                                                            (sh.data<0)+
                                                            ((le.data+sh.data)<energy_threshold))),
                       lat       = sh.lat,
                       lat_bnds  = sh.lat_bnds,
                       lon       = sh.lon,
                       lon_bnds  = sh.lon_bnds,
                       time      = sh.time,
                       time_bnds = sh.time_bnds)
        
        if obs.time is None: raise il.NotTemporalVariable()
        self.pruneRegions(obs)
        
        sh  = m.extractTimeSeries("hfss",
                                  initial_time = obs.time_bnds[ 0,0],
                                  final_time   = obs.time_bnds[-1,1],
                                  lats         = None if obs.spatial else obs.lat,
                                  lons         = None if obs.spatial else obs.lon)
        le  = m.extractTimeSeries("hfls",
                                  initial_time = obs.time_bnds[ 0,0],
                                  final_time   = obs.time_bnds[-1,1],
                                  lats         = None if obs.spatial else obs.lat,
                                  lons         = None if obs.spatial else obs.lon)
        mod = Variable(name      = self.variable,
                       unit      = "1",
                       data      = np.ma.masked_array(le.data/(le.data+sh.data),
                                                      mask=((le.data<0)+
                                                            (sh.data<0)+
                                                            ((le.data+sh.data)<energy_threshold))),
                       lat       = sh.lat,
                       lat_bnds  = sh.lat_bnds,
                       lon       = sh.lon,
                       lon_bnds  = sh.lon_bnds,
                       time      = sh.time,
                       time_bnds = sh.time_bnds)
        
        obs,mod = il.MakeComparable(obs,mod,
                                    mask_ref  = True,
                                    clip_ref  = True,
                                    logstring = "[%s][%s]" % (self.longname,m.name))
        
        return obs,mod
    
    def requires(self):
        return ['hfss','hfls'],[]
