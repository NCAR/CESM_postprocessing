from ILAMB.Confrontation import Confrontation
from ILAMB.Confrontation import getVariableList
from ILAMB.constants import earth_rad,mid_months,lbl_months
from ILAMB.Variable import Variable
from ILAMB.Regions import Regions
import ILAMB.ilamblib as il
import ILAMB.Post as post
from netCDF4 import Dataset
from copy import deepcopy
import pylab as plt
import numpy as np
import os,glob

def VariableReduce(var,region="global",time=None,depth=None,lat=None,lon=None):
    ILAMBregions = Regions()
    out = deepcopy(var)
    out.data.mask += ILAMBregions.getMask(region,out)
    if time  is not None:
        out = out.integrateInTime (t0=time[0] ,tf=time[1] ,mean=True)
    if depth is not None and var.layered:
        out = out.integrateInDepth(z0=depth[0],zf=depth[1],mean=True)
    if lat   is not None:
        lat0        = np.argmin(np.abs(var.lat-lat[0]))
        latf        = np.argmin(np.abs(var.lat-lat[1]))+1
        wgt         = earth_rad*(np.sin(var.lat_bnds[:,1])-np.sin(var.lat_bnds[:,0]))[lat0:latf]
        np.seterr(over='ignore',under='ignore')
        out.data    = np.ma.average(out.data[...,lat0:latf,:],axis=-2,weights=wgt/wgt.sum())
        np.seterr(over='raise',under='raise')
        out.lat     = None
        out.lat_bnd = None
        out.spatial = False
    if lon   is not None:
        lon0        = np.argmin(np.abs(var.lon-lon[0]))
        lonf        = np.argmin(np.abs(var.lon-lon[1]))+1
        wgt         = earth_rad*(var.lon_bnds[:,1]-var.lon_bnds[:,0])[lon0:lonf]
        np.seterr(over='ignore',under='ignore')
        out.data    = np.ma.average(out.data[...,lon0:lonf],axis=-1,weights=wgt/wgt.sum())
        np.seterr(over='raise',under='raise')
        out.lon     = None
        out.lon_bnd = None
        out.spatial = False

    return out

class ConfIOMB(Confrontation):

    def __init__(self,**keywords):

        # Calls the regular constructor
        super(ConfIOMB,self).__init__(**keywords)

        # Setup a html layout for generating web views of the results
        pages = []

        # Mean State page
        pages.append(post.HtmlPage("MeanState","Mean State"))
        pages[-1].setHeader("CNAME / RNAME / MNAME")
        pages[-1].setSections(["Period mean at surface",
                               "Mean regional depth profiles"])
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
        t0 = obs.time_bnds[ 0,0]
        tf = obs.time_bnds[-1,1]
        climatology = False if obs.cbounds is None else True
        if climatology:
            t0 = (obs.cbounds[0]  -1850)*365.
            tf = (obs.cbounds[1]+1-1850)*365.
        mod = m.extractTimeSeries(self.variable,
                                  alt_vars     = self.alternate_vars,
                                  expression   = self.derived,
                                  initial_time = t0,
                                  final_time   = tf,
                                  lats         = None if obs.spatial else obs.lat,
                                  lons         = None if obs.spatial else obs.lon)
        if obs.layered and not mod.layered: obs = obs.integrateInDepth(z0=0,zf=0.1,mean=True)
        if climatology:
            mod           = mod.annualCycle()
            mod.time      = obs.time     .copy()
            mod.time_bnds = obs.time_bnds.copy()
        obs,mod = il.MakeComparable(obs,mod,
                                    mask_ref  = True,
                                    clip_ref  = True,
                                    extents   = self.extents,
                                    logstring = "[%s][%s]" % (self.longname,m.name))
              
        return obs,mod
        
    def confront(self,m):

        def _profileScore(ref,com,region):
            db  = np.unique(np.hstack([np.unique(ref.depth_bnds),np.unique(com.depth_bnds)]))
            d   = 0.5*(db[:-1]+db[1:])
            w   = np.diff(db)
            r   = ref.data[np.argmin(np.abs(d[:,np.newaxis]-ref.depth),axis=1)]
            c   = com.data[np.argmin(np.abs(d[:,np.newaxis]-com.depth),axis=1)]
            err = np.sqrt( (((r-c)**2)*w).sum() / ((r**2)*w).sum() ) # relative L2 error
            return Variable(name = "Profile Score %s" % region,
                            unit = "1",
                            data = np.exp(-err))
        
        # get the data
        obs,mod = self.stageData(m)
        layered = obs.layered
        
        # Reduction 1: Surface states
        ds   = [   0.,  10.]
        ts   = [-1e20,+1e20]
        o1   = VariableReduce(obs,time=ts,depth=ds)
        m1   = VariableReduce(mod,time=ts,depth=ds)
        d1   = o1.bias(m1)
        if layered:
            oint = obs.integrateInDepth(z0=ds[0],zf=ds[1],mean=True)
            mint = mod.integrateInDepth(z0=ds[0],zf=ds[1],mean=True)
        else:
            oint = obs
            mint = mod
        r1   = oint.rmse(mint)
        s1   = il.Score(d1,o1        .interpolate(lat=d1.lat,lon=d1.lon))
        s2   = il.Score(r1,oint.rms().interpolate(lat=r1.lat,lon=r1.lon))
        m1.name = "timeint_surface_%s"    % self.variable
        d1.name = "bias_surface_%s"       % self.variable
        r1.name = "rmse_surface_%s"       % self.variable
        o1.name = "timeint_surface_%s"    % self.variable
        s1.name = "biasscore_surface_%s"  % self.variable
        s2.name = "rmsescore_surface_%s"  % self.variable

        o2 = {}; m2 = {}; o3 = {}; m3 = {}; o4 = {}; m4 = {}
        op = {}; mp = {}; mb = {}; mr = {}; sb = {}; sr = {}; sp = {}
        sd = {}; cr = {}; ds = {}
        obsout = [o1,op]        
        modout = [m1,d1,r1,s1,s2,sb,mp,mb,mr,sr]
        for region in self.regions:

            op[region] = o1.integrateInSpace(mean=True,region=region)
            mp[region] = m1.integrateInSpace(mean=True,region=region)
            mb[region] = d1.integrateInSpace(mean=True,region=region)
            mr[region] = r1.integrateInSpace(mean=True,region=region)
            sb[region] = s1.integrateInSpace(mean=True,region=region,weight=o1.interpolate(lat=s1.lat,lon=s1.lon).data)
            sr[region] = s2.integrateInSpace(mean=True,region=region,weight=o1.interpolate(lat=s1.lat,lon=s1.lon).data)
            sd[region],cr[region],ds[region] = o1.spatialDistribution(m1,region=region)
            op[region].name = "Period Mean %s" % region
            mp[region].name = "Period Mean %s" % region
            mb[region].name = "Bias %s"        % region
            sb[region].name = "Bias Score %s"  % region
            mr[region].name = "RMSE %s"        % region
            sr[region].name = "RMSE Score %s"  % region
            ds[region].name = "Spatial Distribution Score %s" % (region)
            
            if layered:
                
                # Reduction 2/3: Zonal depth profiles
                o2[region] = VariableReduce(obs,region,time=ts,lon=[-180.,180.])
                m2[region] = VariableReduce(mod,region,time=ts,lon=[-180.,180.])
                o3[region] = obs.integrateInSpace(region=region,mean=True).integrateInTime(t0=ts[0],tf=ts[1],mean=True)
                m3[region] = mod.integrateInSpace(region=region,mean=True).integrateInTime(t0=ts[0],tf=ts[1],mean=True)
                sp[region] = _profileScore(o3[region],m3[region],region)
                o2[region].name = "timelonint_of_%s_over_%s" % (self.variable,region)
                m2[region].name = "timelonint_of_%s_over_%s" % (self.variable,region)
                o3[region].name = "profile_of_%s_over_%s"    % (self.variable,region)
                m3[region].name = "profile_of_%s_over_%s"    % (self.variable,region)
            
                # Reduction 4: Temporal depth profile
                o4[region] = obs.integrateInSpace(region=region,mean=True)
                m4[region] = mod.integrateInSpace(region=region,mean=True)
                o4[region].name = "latlonint_of_%s_over_%s" % (self.variable,region)
                m4[region].name = "latlonint_of_%s_over_%s" % (self.variable,region)

        if layered:
            obsout += [o2,o3,o4]
            modout += [m2,m3,m4,sp]

        # Unit conversions
        def _convert(var,unit):
            if type(var) == type({}):
                for key in var.keys(): var[key].convert(unit)
            else:
                var.convert(unit)
        table_unit = self.keywords.get("table_unit",None)
        plot_unit  = self.keywords.get("plot_unit" ,None)
        if table_unit is not None:
            for var in [op,mp,mb,mr]:
                _convert(var,table_unit)
        if plot_unit is not None:
            for var in [o1,m1,d1,r1,o2,m2,o3,m3,o4,m4]:
                _convert(var,plot_unit)
                
        # Dump to files
        def _write(out_vars,results):
            for var in out_vars:
                if type(var) == type({}):
                    for key in var.keys(): var[key].toNetCDF4(results,group="MeanState")
                else:
                    var.toNetCDF4(results,group="MeanState")

        results = Dataset("%s/%s_%s.nc" % (self.output_path,self.name,m.name),mode="w")
        results.setncatts({"name" :m.name, "color":m.color})
        _write(modout,results)
        for key in ds.keys():
            ds[key].toNetCDF4(results,group="MeanState",
                              attributes={"std":sd[key].data,
                                          "R"  :cr[key].data})
        results.close()
        if self.master:
            results = Dataset("%s/%s_Benchmark.nc" % (self.output_path,self.name),mode="w")
            results.setncatts({"name" :"Benchmark", "color":np.asarray([0.5,0.5,0.5])})
            _write(obsout,results)
            results.close()

    def compositePlots(self):

        if not self.master: return
        
        # get the HTML page
        page = [page for page in self.layout.pages if "MeanState" in page.name][0]

        # composite profile plot
        f1     = {}
        a1     = {}
        u1     = None
        for fname in glob.glob("%s/*.nc" % self.output_path):
            with Dataset(fname) as dset:
                if "MeanState" not in dset.groups: continue
                group     = dset.groups["MeanState"]
                variables = getVariableList(group)
                for region in self.regions:

                    vname = "profile_of_%s_over_%s" % (self.variable,region)
                    if vname in variables:
                        if not f1.has_key(region):
                            f1[region],a1[region] = plt.subplots(figsize=(5,5),tight_layout=True)
                        var = Variable(filename=fname,variable_name=vname,groupname="MeanState")
                        u1  = var.unit
                        page.addFigure("Mean regional depth profiles",
                                       "profile",
                                       "RNAME_profile.png",
                                       side   = "REGIONAL MEAN PROFILE",
                                       legend = False)
                        a1[region].plot(var.data,var.depth,'-',
                                        color = dset.getncattr("color"))
        for key in f1.keys():
            a1[key].set_xlabel("%s [%s]" % (self.variable,u1))
            a1[key].set_ylabel("depth [m]")
            a1[key].invert_yaxis()
            f1[key].savefig("%s/%s_profile.png" % (self.output_path,key))
        plt.close()

        # spatial distribution Taylor plot
        models  = []
        colors  = []
        corr    = {}
        std     = {}
        has_std = False
        for fname in glob.glob("%s/*.nc" % self.output_path):
            with Dataset(fname) as dset:
                models.append(dset.getncattr("name"))
                colors.append(dset.getncattr("color"))
                if "MeanState" not in dset.groups: continue
                dset = dset.groups["MeanState"]
                for region in self.regions:
                    if not std. has_key(region): std [region] = []
                    if not corr.has_key(region): corr[region] = []
                    key = []
                    if "scalars" in dset.groups:
                        key = [v for v in dset.groups["scalars"].variables.keys() if ("Spatial Distribution Score" in v and region in v)]
                    if len(key) > 0:
                        has_std = True
                        sds     = dset.groups["scalars"].variables[key[0]]
                        corr[region].append(sds.getncattr("R"  ))
                        std [region].append(sds.getncattr("std"))
                
        if has_std:

            # Legends
            def _alphabeticalBenchmarkFirst(key):
                key = key[0].upper()
                if key == "BENCHMARK": return 0
                return key
            tmp = sorted(zip(models,colors),key=_alphabeticalBenchmarkFirst)
            fig,ax = plt.subplots()
            for model,color in tmp:
                ax.plot(0,0,'o',mew=0,ms=8,color=color,label=model)
            handles,labels = ax.get_legend_handles_labels()
            plt.close()
            ncol   = np.ceil(float(len(models))/11.).astype(int)
            fig,ax = plt.subplots(figsize=(3.*ncol,2.8),tight_layout=True)
            ax.legend(handles,labels,loc="upper right",ncol=ncol,fontsize=10,numpoints=1)
            ax.axis('off')
            fig.savefig("%s/legend_spatial_variance.png" % self.output_path)
            plt.close()

            
            page.addFigure("Period mean at surface",
                           "spatial_variance",
                           "RNAME_spatial_variance.png",
                           side   = "SPATIAL TAYLOR DIAGRAM",
                           legend = False)
            page.addFigure("Period mean at surface",
                           "legend_spatial_variance",
                           "legend_spatial_variance.png",
                           side   = "MODEL COLORS",
                           legend = False) 
            if "Benchmark" in models: colors.pop(models.index("Benchmark"))
            for region in self.regions:
                if not (std.has_key(region) and corr.has_key(region)): continue
                if len(std[region]) != len(corr[region]): continue
                if len(std[region]) == 0: continue
                fig = plt.figure(figsize=(6.0,6.0))
                post.TaylorDiagram(np.asarray(std[region]),np.asarray(corr[region]),1.0,fig,colors)
                fig.savefig("%s/%s_spatial_variance.png" % (self.output_path,region))
                plt.close()

        
    def modelPlots(self,m):

        def _fheight(region):
            if region in ["arctic","southern"]: return 6.8
            return 2.8
        
        bname  = "%s/%s_Benchmark.nc" % (self.output_path,self.name)
        fname  = "%s/%s_%s.nc" % (self.output_path,self.name,m.name)
        if not os.path.isfile(bname): return
        if not os.path.isfile(fname): return

        # get the HTML page
        page = [page for page in self.layout.pages if "MeanState" in page.name][0]

        with Dataset(fname) as dataset:
            group     = dataset.groups["MeanState"]
            variables = getVariableList(group)
            color     = dataset.getncattr("color")

            vname = "timeint_surface_%s" % self.variable
            if vname in variables:
                var = Variable(filename=fname,variable_name=vname,groupname="MeanState")
                page.addFigure("Period mean at surface",
                               "timeint",
                               "MNAME_RNAME_timeint.png",
                               side   = "MODEL SURFACE MEAN",
                               legend = True)
                for region in self.regions:
                    fig = plt.figure()
                    ax  = fig.add_axes([0.06,0.025,0.88,0.965])
                    var.plot(ax,
                             region = region,
                             vmin   = self.limits["timeint"]["min"],
                             vmax   = self.limits["timeint"]["max"],
                             cmap   = self.cmap,
                             land   = 0.750,
                             water  = 0.875)
                    fig.savefig("%s/%s_%s_timeint.png" % (self.output_path,m.name,region))
                    plt.close()

            vname = "bias_surface_%s" % self.variable
            if vname in variables:
                var = Variable(filename=fname,variable_name=vname,groupname="MeanState")
                page.addFigure("Period mean at surface",
                               "bias",
                               "MNAME_RNAME_bias.png",
                               side   = "SURFACE MEAN BIAS",
                               legend = True)
                for region in self.regions:
                    fig = plt.figure()
                    ax  = fig.add_axes([0.06,0.025,0.88,0.965])
                    var.plot(ax,
                             region = region,
                             vmin   = self.limits["bias"]["min"],
                             vmax   = self.limits["bias"]["max"],
                             cmap   = "seismic",
                             land   = 0.750,
                             water  = 0.875)
                    fig.savefig("%s/%s_%s_bias.png" % (self.output_path,m.name,region))
                    plt.close()

            vname = "biasscore_surface_%s" % self.variable
            if vname in variables:
                var = Variable(filename=fname,variable_name=vname,groupname="MeanState")
                page.addFigure("Period mean at surface",
                               "biasscore",
                               "MNAME_RNAME_biasscore.png",
                               side   = "SURFACE MEAN BIAS SCORE",
                               legend = True)
                for region in self.regions:
                    fig = plt.figure()
                    ax  = fig.add_axes([0.06,0.025,0.88,0.965])
                    var.plot(ax,
                             region = region,
                             vmin   = 0,
                             vmax   = 1,
                             cmap   = "RdYlGn",
                             land   = 0.750,
                             water  = 0.875)
                    fig.savefig("%s/%s_%s_biasscore.png" % (self.output_path,m.name,region))
                    plt.close()
                    
            vname = "rmse_surface_%s" % self.variable
            if vname in variables:
                var = Variable(filename=fname,variable_name=vname,groupname="MeanState")
                page.addFigure("Period mean at surface",
                               "rmse",
                               "MNAME_RNAME_rmse.png",
                               side   = "SURFACE MEAN RMSE",
                               legend = True)
                for region in self.regions:
                    fig = plt.figure()
                    ax  = fig.add_axes([0.06,0.025,0.88,0.965])
                    var.plot(ax,
                             region = region,
                             vmin   = self.limits["rmse"]["min"],
                             vmax   = self.limits["rmse"]["max"],
                             cmap   = "YlOrRd",
                             land   = 0.750,
                             water  = 0.875)
                    fig.savefig("%s/%s_%s_rmse.png" % (self.output_path,m.name,region))
                    plt.close()

            vname = "rmsescore_surface_%s" % self.variable
            if vname in variables:
                var = Variable(filename=fname,variable_name=vname,groupname="MeanState")
                page.addFigure("Period mean at surface",
                               "rmsescore",
                               "MNAME_RNAME_rmsescore.png",
                               side   = "SURFACE MEAN RMSE SCORE",
                               legend = True)
                for region in self.regions:
                    fig = plt.figure()
                    ax  = fig.add_axes([0.06,0.025,0.88,0.965])
                    var.plot(ax,
                             region = region,
                             vmin   = 0,
                             vmax   = 1,
                             cmap   = "RdYlGn",
                             land   = 0.750,
                             water  = 0.875)
                    fig.savefig("%s/%s_%s_rmsescore.png" % (self.output_path,m.name,region))
                    plt.close()

            for region in self.regions:

                vname = "timelonint_of_%s_over_%s" % (self.variable,region)
                if vname in variables:
                    var = Variable(filename=fname,variable_name=vname,groupname="MeanState")
                    if region == "global":
                        page.addFigure("Mean regional depth profiles",
                                       "timelonint",
                                       "MNAME_RNAME_timelonint.png",
                                       side     = "MODEL DEPTH PROFILE",
                                       legend   = True,
                                       longname = "Time/longitude averaged profile")
                    fig,ax = plt.subplots(figsize=(6.8,2.8),tight_layout=True)
                    l   = np.hstack([var.lat_bnds  [:,0],var.lat_bnds  [-1,1]])
                    d   = np.hstack([var.depth_bnds[:,0],var.depth_bnds[-1,1]])
                    ind = np.all(var.data.mask,axis=0)
                    ind = np.ma.masked_array(range(ind.size),mask=ind,dtype=int)
                    b   = ind.min()
                    e   = ind.max()+1
                    ax.pcolormesh(l[b:(e+1)],d,var.data[:,b:e],
                                  vmin = self.limits["timelonint"]["global"]["min"],
                                  vmax = self.limits["timelonint"]["global"]["max"],
                                  cmap = self.cmap)
                    ax.set_xlabel("latitude")
                    ax.set_ylim((d.max(),d.min()))
                    ax.set_ylabel("depth [m]")
                    fig.savefig("%s/%s_%s_timelonint.png" % (self.output_path,m.name,region))
                    plt.close()

        if not self.master: return

        with Dataset(bname) as dataset:
            group     = dataset.groups["MeanState"]
            variables = getVariableList(group)
            color     = dataset.getncattr("color")

            vname = "timeint_surface_%s" % self.variable
            if vname in variables:
                var = Variable(filename=bname,variable_name=vname,groupname="MeanState")
                page.addFigure("Period mean at surface",
                               "benchmark_timeint",
                               "Benchmark_RNAME_timeint.png",
                               side   = "BENCHMARK SURFACE MEAN",
                               legend = True)
                for region in self.regions:
                    fig = plt.figure()
                    ax  = fig.add_axes([0.06,0.025,0.88,0.965])
                    var.plot(ax,
                             region = region,
                             vmin   = self.limits["timeint"]["min"],
                             vmax   = self.limits["timeint"]["max"],
                             cmap   = self.cmap,
                             land   = 0.750,
                             water  = 0.875)
                    fig.savefig("%s/Benchmark_%s_timeint.png" % (self.output_path,region))
                    plt.close()

            for region in self.regions:

                vname = "timelonint_of_%s_over_%s" % (self.variable,region)
                if vname in variables:
                    var = Variable(filename=bname,variable_name=vname,groupname="MeanState")
                    if region == "global":
                        page.addFigure("Mean regional depth profiles",
                                       "benchmark_timelonint",
                                       "Benchmark_RNAME_timelonint.png",
                                       side   = "BENCHMARK DEPTH PROFILE",
                                       legend = True,
                                       longname = "Time/longitude averaged profile")
                    fig,ax = plt.subplots(figsize=(6.8,2.8),tight_layout=True)
                    l   = np.hstack([var.lat_bnds  [:,0],var.lat_bnds  [-1,1]])
                    d   = np.hstack([var.depth_bnds[:,0],var.depth_bnds[-1,1]])
                    ind = np.all(var.data.mask,axis=0)
                    ind = np.ma.masked_array(range(ind.size),mask=ind,dtype=int)
                    b   = ind.min()
                    e   = ind.max()+1
                    ax.pcolormesh(l[b:(e+1)],d,var.data[:,b:e],
                                  vmin = self.limits["timelonint"]["global"]["min"],
                                  vmax = self.limits["timelonint"]["global"]["max"],
                                  cmap = self.cmap)
                    ax.set_xlabel("latitude")
                    ax.set_ylim((d.max(),d.min()))
                    ax.set_ylabel("depth [m]")
                    fig.savefig("%s/Benchmark_%s_timelonint.png" % (self.output_path,region))
                    plt.close()
                    
    def determinePlotLimits(self):

        # Pick limit type
        max_str = "up99"; min_str = "dn99"
        if self.keywords.get("limit_type","99per") == "minmax":
            max_str = "max"; min_str = "min"
            
        # Determine the min/max of variables over all models
        limits = {}
        for fname in glob.glob("%s/*.nc" % self.output_path):
            with Dataset(fname) as dataset:
                if "MeanState" not in dataset.groups: continue
                group     = dataset.groups["MeanState"]
                variables = [v for v in group.variables.keys() if (v not in group.dimensions.keys() and
                                                                   "_bnds" not in v                 and
                                                                   group.variables[v][...].size > 1)]
                for vname in variables:
                    var    = group.variables[vname]
                    pname  = vname.split("_")[ 0]
                    if "_over_" in vname:
                        region = vname.split("_over_")[-1]
                        if not limits.has_key(pname): limits[pname] = {}
                        if not limits[pname].has_key(region):
                            limits[pname][region] = {}
                            limits[pname][region]["min"]  = +1e20
                            limits[pname][region]["max"]  = -1e20
                            limits[pname][region]["unit"] = post.UnitStringToMatplotlib(var.getncattr("units"))
                        limits[pname][region]["min"] = min(limits[pname][region]["min"],var.getncattr("min"))
                        limits[pname][region]["max"] = max(limits[pname][region]["max"],var.getncattr("max"))
                    else:
                        if not limits.has_key(pname):
                            limits[pname] = {}
                            limits[pname]["min"]  = +1e20
                            limits[pname]["max"]  = -1e20
                            limits[pname]["unit"] = post.UnitStringToMatplotlib(var.getncattr("units"))
                        limits[pname]["min"] = min(limits[pname]["min"],var.getncattr(min_str))
                        limits[pname]["max"] = max(limits[pname]["max"],var.getncattr(max_str))

        # Another pass to fix score limits
        for pname in limits.keys():
            if "score" in pname:
                if "min" in limits[pname].keys():
                    limits[pname]["min"] = 0.
                    limits[pname]["max"] = 1.
                else:
                    for region in limits[pname].keys():
                        limits[pname][region]["min"] = 0.
                        limits[pname][region]["max"] = 1.
        self.limits = limits
        
        # Second pass to plot legends
        cmaps = {"bias":"seismic",
                 "rmse":"YlOrRd"}
        for pname in limits.keys():

            # Pick colormap
            cmap = self.cmap
            if cmaps.has_key(pname):
                cmap = cmaps[pname]
            elif "score" in pname:
                cmap = "RdYlGn"

            # Need to symetrize?
            if pname in ["bias"]:
                vabs =  max(abs(limits[pname]["min"]),abs(limits[pname]["min"]))
                limits[pname]["min"] = -vabs
                limits[pname]["max"] =  vabs

            # Some plots need legends
            if pname in ["timeint","bias","biasscore","rmse","rmsescore","timelonint"]:
                if limits[pname].has_key("min"):
                    fig,ax = plt.subplots(figsize=(6.8,1.0),tight_layout=True)
                    post.ColorBar(ax,
                                  vmin  = limits[pname]["min" ],
                                  vmax  = limits[pname]["max" ],
                                  label = limits[pname]["unit"],
                                  cmap  = cmap)
                    fig.savefig("%s/legend_%s.png" % (self.output_path,pname))
                    plt.close()
                else:
                    fig,ax = plt.subplots(figsize=(6.8,1.0),tight_layout=True)
                    post.ColorBar(ax,
                                  vmin  = limits[pname]["global"]["min" ],
                                  vmax  = limits[pname]["global"]["max" ],
                                  label = limits[pname]["global"]["unit"],
                                  cmap  = cmap)
                    fig.savefig("%s/legend_%s.png" % (self.output_path,pname))
                    plt.close()
                        

            
