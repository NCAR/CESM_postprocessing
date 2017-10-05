import ilamblib as il
from Variable import *
from Regions import Regions
from constants import space_opts,time_opts,mid_months,bnd_months
import os,glob,re
from netCDF4 import Dataset
import Post as post
import pylab as plt
from matplotlib.colors import LogNorm
from mpl_toolkits.axes_grid1 import make_axes_locatable
from mpi4py import MPI
from sympy import sympify

import logging
logger = logging.getLogger("%i" % MPI.COMM_WORLD.rank)	

def getVariableList(dataset):
    """Extracts the list of variables in the dataset that aren't
    dimensions or the bounds of dimensions.

    """
    variables = [v for v in dataset.variables.keys() if v not in dataset.dimensions.keys()]
    for d in dataset.dimensions.keys():
        try:
            variables.pop(variables.index(dataset.variables[d].getncattr("bounds")))
        except:
            pass
    return variables

class Confrontation(object):
    """A generic class for confronting model results with observational data.

    This class is meant to provide the user with a simple way to
    specify observational datasets and compare them to model
    results. A generic analysis routine is called which checks mean
    states of the variables, afterwhich the results are tabulated and
    plotted automatically. A HTML page is built dynamically as plots
    are created based on available information and successful
    analysis.

    Parameters
    ----------
    name : str
        a name for the confrontation
    source : str
        full path to the observational dataset
    variable_name : str
        name of the variable to extract from the source dataset
    output_path : str, optional
        path into which all output from this confrontation will be generated
    alternate_vars : list of str, optional
        other accepted variable names when extracting from models
    derived : str, optional
        an algebraic expression which captures how the confrontation variable may be generated
    regions : list of str, optional
        a list of regions over which the spatial analysis will be performed (default is global)
    table_unit : str, optional
        the unit to use in the output HTML table
    plot_unit : str, optional
        the unit to use in the output images
    space_mean : bool, optional
        enable to take spatial means (as opposed to spatial integrals) in the analysis (enabled by default)
    relationships : list of ILAMB.Confrontation.Confrontation, optional
        a list of confrontations with whose data we use to study relationships
    cmap : str, optional
        the colormap to use in rendering plots (default is 'jet')
    land : str, bool
        enable to force the masking of areas with no land (default is False)
    limit_type : str
        change the types of plot limits, one of ['minmax', '99per' (default)]
    """
    def __init__(self,**keywords):
        
        # Initialize
        self.master         = True
        self.name           = keywords.get("name",None)
        self.source         = keywords.get("source",None)
        self.variable       = keywords.get("variable",None)
        self.output_path    = keywords.get("output_path","./")
        self.alternate_vars = keywords.get("alternate_vars",[])
        self.derived        = keywords.get("derived",None)
        self.regions        = list(keywords.get("regions",["global"]))
        self.data           = None
        self.cmap           = keywords.get("cmap","jet")
        self.land           = keywords.get("land",False)
        self.limits         = None
        self.longname       = self.output_path
        self.longname       = "/".join(self.longname.replace("//","/").rstrip("/").split("/")[-2:])
        self.table_unit     = keywords.get("table_unit",None)
        self.plot_unit      = keywords.get("plot_unit",None)
        self.space_mean     = keywords.get("space_mean",True)        
        self.relationships  = keywords.get("relationships",None)
        self.keywords       = keywords
        self.extents        = np.asarray([[-90.,+90.],[-180.,+180.]])
        
        # Make sure the source data exists
        try:
            os.stat(self.source)
        except:
            msg  = "\n\nI am looking for data for the %s confrontation here\n\n" % self.name
            msg += "%s\n\nbut I cannot find it. " % self.source
            msg += "Did you download the data? Have you set the ILAMB_ROOT envronment variable?\n"
            raise il.MisplacedData(msg)
                
        # Setup a html layout for generating web views of the results
        pages = []
        
        # Mean State page
        pages.append(post.HtmlPage("MeanState","Mean State"))
        pages[-1].setHeader("CNAME / RNAME / MNAME")
        pages[-1].setSections(["Temporally integrated period mean",
                              "Spatially integrated regional mean"])

        # Datasites page
        self.hasSites = False
        self.lbls     = None
        y0 = None; yf = None
        with Dataset(self.source) as dataset:
            if dataset.dimensions.has_key("data"):
                #self.hasSites = True
                if "site_name" in dataset.ncattrs():
                    self.lbls = dataset.site_name.split(",")
                else:
                    self.lbls = ["site%d" % s for s in range(len(dataset.dimensions["data"]))]
            if dataset.dimensions.has_key("time"):
                t = dataset.variables["time"]
                if "bounds" in t.ncattrs():
                    t  = dataset.variables[t.bounds][...]
                    y0 = int(t[ 0,0]/365.+1850.)
                    yf = int(t[-1,1]/365.+1850.)-1
                else:
                    y0 = int(round(t[ 0]/365.)+1850.)
                    yf = int(round(t[-1]/365.)+1850.)-1

        if self.hasSites:
            pages.append(post.HtmlSitePlotsPage("SitePlots","Site Plots"))
            pages[-1].setHeader("CNAME / RNAME / MNAME")
            pages[-1].setSections([])
            var = Variable(filename       = self.source,
                           variable_name  = self.variable,
                           alternate_vars = self.alternate_vars).integrateInTime(mean=True)
            if self.plot_unit is not None: var.convert(self.plot_unit)
            pages[-1].lat   = var.lat
            pages[-1].lon   = var.lon
            pages[-1].vname = self.variable
            pages[-1].unit  = var.unit
            pages[-1].vals  = var.data
            pages[-1].sites = self.lbls
            
        # Relationships page
        if self.relationships is not None:
            pages.append(post.HtmlPage("Relationships","Relationships"))
            pages[-1].setHeader("CNAME / RNAME / MNAME")
            pages[-1].setSections(list(self.relationships))
        pages.append(post.HtmlAllModelsPage("AllModels","All Models"))
        pages[-1].setHeader("CNAME / RNAME / MNAME")
        pages[-1].setSections([])
        pages[-1].setRegions(self.regions)
        pages.append(post.HtmlPage("DataInformation","Data Information"))
        pages[-1].setSections([])
        pages[-1].text = "\n"
        with Dataset(self.source) as dset:
            for attr in dset.ncattrs():
                pages[-1].text += "<p><b>&nbsp;&nbsp;%s:&nbsp;</b>%s</p>\n" % (attr,dset.getncattr(attr).encode('ascii','ignore'))
        self.layout = post.HtmlLayout(pages,self.longname,years=(y0,yf))

        # Define relative weights of each score in the overall score
        # (FIX: need some way for the user to modify this)
        self.weight = {"Bias Score"                    :1.,
                       "RMSE Score"                    :2.,
                       "Seasonal Cycle Score"          :1.,
                       "Interannual Variability Score" :1.,
                       "Spatial Distribution Score"    :1.}

    def requires(self):
        if self.derived is not None:
            ands = [arg.name for arg in sympify(self.derived).free_symbols]
            ors  = []
        else:
            ands = []
            ors  = [self.variable] + self.alternate_vars
        return ands,ors
    
    def stageData(self,m):
        r"""Extracts model data which matches the observational dataset.
        
        The datafile associated with this confrontation defines what
        is to be extracted from the model results. If the
        observational data represents sites, as opposed to spatially
        defined over a latitude/longitude grid, then the model results
        will be sampled at the site locations to match. The spatial
        grids need not align, the analysis will handle the
        interpolations when necesary.

        If both datasets are defined on the same temporal scale, then
        the maximum overlap time is computed and the datasets are
        clipped to match. If there is some disparity in the temporal
        scale (e.g. annual mean observational data and monthly mean
        model results) then we coarsen the model results automatically
        to match the observational data.

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
                                  lons         = None if obs.spatial else obs.lon)
        obs,mod = il.MakeComparable(obs,mod,
                                    mask_ref  = True,
                                    clip_ref  = True,
                                    extents   = self.extents,
                                    logstring = "[%s][%s]" % (self.longname,m.name))
        
        # Check the order of magnitude of the data and convert to help avoid roundoff errors
        def _reduceRoundoffErrors(var):
            if "s-1" in var.unit: return var.convert(var.unit.replace("s-1","d-1"))
            if "kg"  in var.unit: return var.convert(var.unit.replace("kg" ,"g"  ))
            return var
        def _getOrder(var):
            return np.log10(np.abs(var.data).clip(1e-16)).mean()
        order = _getOrder(obs)
        count = 0
        while order < -2 and count < 2:
            obs    = _reduceRoundoffErrors(obs)
            order  = _getOrder(obs)
            count += 1
            
        # convert the model data to the same unit
        mod = mod.convert(obs.unit)

        return obs,mod

    def pruneRegions(self,var):
        # remove regions if there is no data from the input variable
        r = Regions()
        self.regions = [region for region in self.regions if r.hasData(region,var)]

    def confront(self,m):
        r"""Confronts the input model with the observational data.

        This routine performs a mean-state analysis the details of
        which may be found in the documentation of
        ILAMB.ilamblib.AnalysisMeanState. If relationship information
        was provided, it will also perform the analysis documented in
        ILAMB.ilamblib.AnalysisRelationship. Output from the analysis
        is stored in a netCDF4 file in the output path.

        Parameters
        ----------
        m : ILAMB.ModelResult.ModelResult
            the model results
        """
        # Grab the data
        obs,mod = self.stageData(m)
        
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
            il.AnalysisMeanState(obs,mod,dataset   = fcm.mod_dset,
                                 regions           = self.regions,
                                 benchmark_dataset = fcm.obs_dset,
                                 table_unit        = self.table_unit,
                                 plot_unit         = self.plot_unit,
                                 space_mean        = self.space_mean,
                                 skip_rmse         = skip_rmse,
                                 skip_iav          = skip_iav,
                                 mass_weighting    = mass_weighting)

        logger.info("[%s][%s] Success" % (self.longname,m.name))
                
    def determinePlotLimits(self):
        """Determine the limits of all plots which are inclusive of all ranges.

        The routine will open all netCDF files in the output path and
        add the maximum and minimum of all variables which are
        designated to be plotted. If legends are desired for a given
        plot, these are rendered here as well. This routine should be
        called before calling any plotting routine.

        """
        max_str = "up99"
        min_str = "dn99"
        if self.keywords.get("limit_type","99per") == "minmax":
            max_str = "max"
            min_str = "min"
            
        # Determine the min/max of variables over all models
        limits = {}
        prune  = False
        for fname in glob.glob(os.path.join(self.output_path,"*.nc")):
            with Dataset(fname) as dataset:
                if "MeanState" not in dataset.groups: continue
                group     = dataset.groups["MeanState"]
                variables = [v for v in group.variables.keys() if v not in group.dimensions.keys()]
                for vname in variables:
                    var    = group.variables[vname]
                    pname  = vname.split("_")[0]
                    region = vname.split("_")[-1]
                    if var[...].size <= 1: continue
                    if space_opts.has_key(pname):
                        if not limits.has_key(pname):
                            limits[pname] = {}
                            limits[pname]["min"]  = +1e20
                            limits[pname]["max"]  = -1e20
                            limits[pname]["unit"] = post.UnitStringToMatplotlib(var.getncattr("units"))
                        limits[pname]["min"] = min(limits[pname]["min"],var.getncattr(min_str))
                        limits[pname]["max"] = max(limits[pname]["max"],var.getncattr(max_str))
                    elif time_opts.has_key(pname):
                        if not limits.has_key(pname): limits[pname] = {}
                        if not limits[pname].has_key(region):
                            limits[pname][region] = {}
                            limits[pname][region]["min"]  = +1e20
                            limits[pname][region]["max"]  = -1e20
                            limits[pname][region]["unit"] = post.UnitStringToMatplotlib(var.getncattr("units"))
                        limits[pname][region]["min"] = min(limits[pname][region]["min"],var.getncattr("min"))
                        limits[pname][region]["max"] = max(limits[pname][region]["max"],var.getncattr("max"))
                    if not prune and "Benchmark" in fname and pname == "timeint":
                        prune = True
                        self.pruneRegions(Variable(filename      = fname,
                                                   variable_name = vname,
                                                   groupname     = "MeanState"))
        
        # Second pass to plot legends (FIX: only for master?)
        for pname in limits.keys():

            try:
                opts = space_opts[pname]
            except:
                continue
            
            # Determine plot limits and colormap
            if opts["sym"]:
                vabs =  max(abs(limits[pname]["min"]),abs(limits[pname]["min"]))
                limits[pname]["min"] = -vabs
                limits[pname]["max"] =  vabs
            limits[pname]["cmap"] = opts["cmap"]
            if limits[pname]["cmap"] == "choose": limits[pname]["cmap"] = self.cmap

            # Plot a legend for each key
            if opts["haslegend"]:
                fig,ax = plt.subplots(figsize=(6.8,1.0),tight_layout=True)
                label  = opts["label"]
                if label == "unit": label = limits[pname]["unit"]
                post.ColorBar(ax,
                              vmin = limits[pname]["min"],
                              vmax = limits[pname]["max"],
                              cmap = limits[pname]["cmap"],
                              ticks = opts["ticks"],
                              ticklabels = opts["ticklabels"],
                              label = label)
                fig.savefig(os.path.join(self.output_path,"legend_%s.png" % (pname)))                
                plt.close()

        # Determine min/max of relationship variables
        for fname in glob.glob(os.path.join(self.output_path,"*.nc")):
            with Dataset(fname) as dataset:
                for g in dataset.groups.keys():
                    if "relationship" not in g: continue
                    grp = dataset.groups[g]
                    if not limits.has_key(g):
                        limits[g] = {}
                        limits[g]["xmin"] = +1e20
                        limits[g]["xmax"] = -1e20
                        limits[g]["ymin"] = +1e20
                        limits[g]["ymax"] = -1e20
                    limits[g]["xmin"] = min(limits[g]["xmin"],grp.variables["ind_bnd"][ 0, 0])
                    limits[g]["xmax"] = max(limits[g]["xmax"],grp.variables["ind_bnd"][-1,-1])
                    limits[g]["ymin"] = min(limits[g]["ymin"],grp.variables["dep_bnd"][ 0, 0])
                    limits[g]["ymax"] = max(limits[g]["ymax"],grp.variables["dep_bnd"][-1,-1])

            
        self.limits = limits

    def computeOverallScore(self,m):
        """Computes the overall composite score for a given model.

        This routine opens the netCDF results file associated with
        this confrontation-model pair, and then looks for a "scalars"
        group in the dataset as well as any subgroups that may be
        present. For each grouping of scalars, it will blend any value
        with the word "Score" in the name to render an overall score,
        overwriting the existing value if present.

        Parameters
        ----------
        m : ILAMB.ModelResult.ModelResult
            the model results

        """
        
        def _computeOverallScore(scalars):
            """Given a netCDF4 group of scalars, blend them into an overall score"""
            scores     = {}
            variables = [v for v in scalars.variables.keys() if "Score" in v and "Overall" not in v]
            for region in self.regions:
                overall_score  = 0.
                sum_of_weights = 0.
                for v in variables:
                    if region not in v: continue
                    score = v.replace(region,"").strip()
                    weight = 1.
                    if self.weight.has_key(score): weight = self.weight[score]
                    overall_score  += weight*scalars.variables[v][...]
                    sum_of_weights += weight
                overall_score /= max(sum_of_weights,1e-12)
                scores["Overall Score %s" % region] = overall_score
            return scores

        fname = os.path.join(self.output_path,"%s_%s.nc" % (self.name,m.name))
        if not os.path.isfile(fname): return
        with Dataset(fname,mode="r+") as dataset:
            datasets = [dataset.groups[grp] for grp in dataset.groups if "scalars" not in grp]
            groups   = [grp                 for grp in dataset.groups if "scalars" not in grp]
            datasets.append(dataset)
            groups  .append(None)
            for dset,grp in zip(datasets,groups):
                if "scalars" in dset.groups:
                    scalars = dset.groups["scalars"]
                    score = _computeOverallScore(scalars)
                    for key in score.keys():
                        if key in scalars.variables:
                            scalars.variables[key][0] = score[key]
                        else:
                            Variable(data=score[key],name=key,unit="1").toNetCDF4(dataset,group=grp)


    def compositePlots(self):
        """Renders plots which display information of all models.

        This routine renders plots which contain information from all
        models. Thus only the master process will run this routine,
        and only after all analysis has finished.

        """
        if not self.master: return

        # get the HTML page
        page = [page for page in self.layout.pages if "MeanState" in page.name][0]
        
        models = []
        colors = []
        corr   = {}
        std    = {}
        cycle  = {}
        has_cycle = False
        has_std   = False
        for fname in glob.glob(os.path.join(self.output_path,"*.nc")):
            dataset = Dataset(fname)
            if "MeanState" not in dataset.groups: continue
            dset    = dataset.groups["MeanState"]
            models.append(dataset.getncattr("name"))
            colors.append(dataset.getncattr("color"))
            for region in self.regions:
                
                if not cycle.has_key(region): cycle[region] = []
                key = [v for v in dset.variables.keys() if ("cycle_"  in v and region in v)]
                if len(key)>0:
                    has_cycle = True
                    cycle[region].append(Variable(filename=fname,groupname="MeanState",variable_name=key[0]))

                if not std.  has_key(region): std  [region] = []
                if not corr. has_key(region): corr [region] = []

                key = []
                if "scalars" in dset.groups:
                    key = [v for v in dset.groups["scalars"].variables.keys() if ("Spatial Distribution Score" in v and region in v)]
                if len(key) > 0:
                    has_std = True
                    sds     = dset.groups["scalars"].variables[key[0]]
                    corr[region].append(sds.getncattr("R"  ))
                    std [region].append(sds.getncattr("std"))

        # composite annual cycle plot
        if has_cycle and len(models) > 2:
            page.addFigure("Spatially integrated regional mean",
                           "compcycle",
                           "RNAME_compcycle.png",
                           side   = "ANNUAL CYCLE",
                           legend = False)

        for region in self.regions:
            if not cycle.has_key(region): continue
            fig,ax = plt.subplots(figsize=(6.8,2.8),tight_layout=True)
            for name,color,var in zip(models,colors,cycle[region]):
                dy = 0.05*(self.limits["cycle"][region]["max"]-self.limits["cycle"][region]["min"])
                var.plot(ax,lw=2,color=color,label=name,
                         ticks      = time_opts["cycle"]["ticks"],
                         ticklabels = time_opts["cycle"]["ticklabels"],
                         vmin       = self.limits["cycle"][region]["min"]-dy,
                         vmax       = self.limits["cycle"][region]["max"]+dy)
                ylbl = time_opts["cycle"]["ylabel"]
                if ylbl == "unit": ylbl = post.UnitStringToMatplotlib(var.unit)
                ax.set_ylabel(ylbl)
            fig.savefig(os.path.join(self.output_path,"%s_compcycle.png" % (region)))
            plt.close()

        # plot legends with model colors (sorted with Benchmark data on top)
        page.addFigure("Spatially integrated regional mean",
                       "legend_compcycle",
                       "legend_compcycle.png",
                       side   = "MODEL COLORS",
                       legend = False)
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
        fig.savefig(os.path.join(self.output_path,"legend_compcycle.png"))
        fig.savefig(os.path.join(self.output_path,"legend_spatial_variance.png"))
        fig.savefig(os.path.join(self.output_path,"legend_temporal_variance.png"))
        plt.close()
        
        # spatial distribution Taylor plot
        if has_std:
            page.addFigure("Temporally integrated period mean",
                           "spatial_variance",
                           "RNAME_spatial_variance.png",
                           side   = "SPATIAL TAYLOR DIAGRAM",
                           legend = False)
            page.addFigure("Temporally integrated period mean",
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
            fig.savefig(os.path.join(self.output_path,"%s_spatial_variance.png" % region))
            plt.close()
            
    def modelPlots(self,m):
        """For a given model, create the plots of the analysis results.

        This routine will extract plotting information out of the
        netCDF file which results from the analysis and create
        plots. Note that determinePlotLimits should be called before
        this routine.

        """
        self._relationship(m)
        bname     = os.path.join(self.output_path,"%s_Benchmark.nc" % (self.name       ))
        fname     = os.path.join(self.output_path,"%s_%s.nc"        % (self.name,m.name))
        if not os.path.isfile(bname): return
        if not os.path.isfile(fname): return

        # get the HTML page
        page = [page for page in self.layout.pages if "MeanState" in page.name][0]  
        
        with Dataset(fname) as dataset:
            group     = dataset.groups["MeanState"]
            variables = getVariableList(group)
            color     = dataset.getncattr("color")
            for vname in variables:
	                
	            # is this a variable we need to plot?
	            pname = vname.split("_")[0]
	            if group.variables[vname][...].size <= 1: continue
	            var = Variable(filename=fname,groupname="MeanState",variable_name=vname)
                    
	            if (var.spatial or (var.ndata is not None)) and not var.temporal:
	
	                # grab plotting options
	                if pname not in self.limits.keys(): continue
	                opts = space_opts[pname]
	
	                # add to html layout
	                page.addFigure(opts["section"],
	                               pname,
	                               opts["pattern"],
	                               side   = opts["sidelbl"],
	                               legend = opts["haslegend"])
	
	                # plot variable
	                for region in self.regions:
	                    fig = plt.figure(figsize=(6.8,2.8))
	                    ax  = fig.add_axes([0.06,0.025,0.88,0.965])
	                    var.plot(ax,
	                             region = region,
	                             vmin   = self.limits[pname]["min"],
	                             vmax   = self.limits[pname]["max"],
	                             cmap   = self.limits[pname]["cmap"])
	                    fig.savefig(os.path.join(self.output_path,"%s_%s_%s.png" % (m.name,region,pname)))
	                    plt.close()
                            
	                # Jumping through hoops to get the benchmark plotted and in the html output
	                if self.master and (pname == "timeint" or pname == "phase"):
	
	                    opts = space_opts[pname]
	
	                    # add to html layout
	                    page.addFigure(opts["section"],
	                                   "benchmark_%s" % pname,
	                                   opts["pattern"].replace("MNAME","Benchmark"),
	                                   side   = opts["sidelbl"].replace("MODEL","BENCHMARK"),
	                                   legend = True)
	
	                    # plot variable
	                    obs = Variable(filename=bname,groupname="MeanState",variable_name=vname)
	                    for region in self.regions:
	                        fig = plt.figure(figsize=(6.8,2.8))
	                        ax  = fig.add_axes([0.06,0.025,0.88,0.965])
	                        obs.plot(ax,
	                                 region = region,
	                                 vmin   = self.limits[pname]["min"],
	                                 vmax   = self.limits[pname]["max"],
	                                 cmap   = self.limits[pname]["cmap"])
	                        fig.savefig(os.path.join(self.output_path,"Benchmark_%s_%s.png" % (region,pname)))
	                        plt.close()
	                    
	            if not (var.spatial or (var.ndata is not None)) and var.temporal:
	                
	                # grab the benchmark dataset to plot along with
	                obs = Variable(filename=bname,groupname="MeanState",variable_name=vname).convert(var.unit)
	                
	                # grab plotting options
	                opts = time_opts[pname]
	
	                # add to html layout
	                page.addFigure(opts["section"],
	                               pname,
	                               opts["pattern"],
	                               side   = opts["sidelbl"],
	                               legend = opts["haslegend"])
	
	                # plot variable
	                for region in self.regions:
	                    if region not in vname: continue
	                    fig,ax = plt.subplots(figsize=(6.8,2.8),tight_layout=True)
	                    obs.plot(ax,lw=2,color='k',alpha=0.5)
	                    var.plot(ax,lw=2,color=color,label=m.name,
	                             ticks     =opts["ticks"],
	                             ticklabels=opts["ticklabels"])

                            dy = 0.05*(self.limits[pname][region]["max"]-self.limits[pname][region]["min"])
	                    ax.set_ylim(self.limits[pname][region]["min"]-dy,
	                                self.limits[pname][region]["max"]+dy)
	                    ylbl = opts["ylabel"]
	                    if ylbl == "unit": ylbl = post.UnitStringToMatplotlib(var.unit)
	                    ax.set_ylabel(ylbl)
	                    fig.savefig(os.path.join(self.output_path,"%s_%s_%s.png" % (m.name,region,pname)))
	                    plt.close()

        logger.info("[%s][%s] Success" % (self.longname,m.name))

    def sitePlots(self,m):
        """

        """
        if not self.hasSites: return

        obs,mod = self.stageData(m)
        for i in range(obs.ndata):
	    fig,ax = plt.subplots(figsize=(6.8,2.8),tight_layout=True)
            tmask  = np.where(mod.data.mask[:,i]==False)[0]
            if tmask.size > 0:
                tmin,tmax = tmask[[0,-1]]
            else:                
                tmin = 0; tmax = mod.time.size-1
                
            t = mod.time[tmin:(tmax+1)  ]
            x = mod.data[tmin:(tmax+1),i]
            y = obs.data[tmin:(tmax+1),i]
            ax.plot(t,y,'-k',lw=2,alpha=0.5)
            ax.plot(t,x,'-',color=m.color)

            ind        = np.where(t % 365 < 30.)[0]
            ticks      = t[ind] - (t[ind] % 365)
            ticklabels = (ticks/365.+1850.).astype(int)
            ax.set_xticks     (ticks     )
            ax.set_xticklabels(ticklabels)
            ax.set_ylabel(post.UnitStringToMatplotlib(mod.unit))
	    fig.savefig(os.path.join(self.output_path,"%s_%s_%s.png" % (m.name,self.lbls[i],"time")))
	    plt.close()
            
            
    def generateHtml(self):
        """Generate the HTML for the results of this confrontation.

        This routine opens all netCDF files and builds a table of
        metrics. Then it passes the results to the HTML generator and
        saves the result in the output directory. This only occurs on
        the confrontation flagged as master.

        """
        # only the master processor needs to do this
        if not self.master: return

        for page in self.layout.pages:
        
            # build the metric dictionary
            metrics = {}
            page.models = []
            for fname in glob.glob(os.path.join(self.output_path,"*.nc")):
                with Dataset(fname) as dataset:
                    mname = dataset.getncattr("name")
                    if mname != "Benchmark": page.models.append(mname)
                    if not dataset.groups.has_key(page.name): continue
                    group = dataset.groups[page.name]

                    # if the dataset opens, we need to add the model (table row)
                    metrics[mname] = {}
        
                    # each model will need to have all regions
                    for region in self.regions: metrics[mname][region] = {}
                    
                    # columns in the table will be in the scalars group
                    if not group.groups.has_key("scalars"): continue
        
                    # we add scalars to the model/region based on the region
                    # name being in the variable name. If no region is found,
                    # we assume it is the global region.
                    grp = group.groups["scalars"]
                    for vname in grp.variables.keys():
                        found = False
                        for region in self.regions:
                            if region in vname: 
                                found = True
                                var   = grp.variables[vname]
                                name  = vname.replace(region,"")
                                metrics[mname][region][name] = Variable(name = name,
                                                                        unit = var.units,
                                                                        data = var[...])
                        if not found:
                            var = grp.variables[vname]
                            metrics[mname]["global"][vname] = Variable(name = vname,
                                                                       unit = var.units,
                                                                       data = var[...])
            page.setMetrics(metrics)
                        
        # write the HTML page
        f = file(os.path.join(self.output_path,"%s.html" % (self.name)),"w")
        f.write(str(self.layout))
        f.close()

    def _relationship(self,m,nbin=25):
        """This needs moved somehow into ilamblib to replace the current
        function. But too much of this is tied to the confrontation
        object and so for now it is more helpful here.

        """
        
        def _retrieveData(filename):
            key = None
            with Dataset(filename,mode="r") as dset:
                key  = [v for v in dset.groups["MeanState"].variables.keys() if "timeint_" in v]
            return Variable(filename      = filename,
                            groupname     = "MeanState",
                            variable_name = key[0])
            
        # if there are no relationships, get out of here
        if self.relationships is None: return            
        r = Regions()
        
        # get the HTML page
        page = [page for page in self.layout.pages if "Relationships" in page.name]
        if len(page) == 0: return
        page = page[0]
        
        # try to get the dependent data from the model and obs
        try:
            obs_dep  = _retrieveData(os.path.join(self.output_path,"%s_%s.nc" % (self.name,"Benchmark")))
            mod_dep  = _retrieveData(os.path.join(self.output_path,"%s_%s.nc" % (self.name,m.name     )))
            dep_name = self.longname.split("/")[0]
            dep_min  = self.limits["timeint"]["min"]
            dep_max  = self.limits["timeint"]["max"]
        except:
            return

        # open a dataset for recording the results of this
        # confrontation (FIX: should be a with statement)
        results = Dataset(os.path.join(self.output_path,"%s_%s.nc" % (self.name,m.name)),mode="r+")

        # grab/create a relationship and scalars group
        group = None
        if "Relationships" not in results.groups:
            group = results.createGroup("Relationships")
        else:
            group = results.groups["Relationships"]
        if "scalars" not in group.groups:
            scalars = group.createGroup("scalars")
        else:
            scalars = group.groups["scalars"]

        # for each relationship...
        for c in self.relationships:

            # try to get the independent data from the model and obs
            try:
                obs_ind  = _retrieveData(os.path.join(c.output_path,"%s_%s.nc" % (c.name,"Benchmark")))
                mod_ind  = _retrieveData(os.path.join(c.output_path,"%s_%s.nc" % (c.name,m.name     )))
                ind_name = c.longname.split("/")[0]          
                ind_min  = c.limits["timeint"]["min"]-1e-12
                ind_max  = c.limits["timeint"]["max"]+1e-12
            except:
                continue

            # for each reigon...
            for region in self.regions:

                # loop over dep/ind pairs of the obs and mod
                obs_dist = None; mod_dist = None
                xedges   = None; yedges   = None
                obs_x    = None; obs_y    = None; obs_e    = None
                mod_x    = None; mod_y    = None; mod_e    = None
                delta    = None
                for dep_var,ind_var,name,xlbl,ylbl in zip([obs_dep    ,mod_dep],
                                                          [obs_ind    ,mod_ind],
                                                          ["Benchmark",m.name ],
                                                          [c   .name  ,m.name ],
                                                          [self.name  ,m.name ]):

                    # build the data masks: only count where we have
                    # both dep and ind variable data inside the region
                    mask      = dep_var.data.mask + ind_var.data.mask
                    mask     += r.getMask(region,dep_var)
                    x         = ind_var.data[mask==0].flatten()
                    y         = dep_var.data[mask==0].flatten()

                    # determine the 2D discrete distribution
                    counts,xedges,yedges = np.histogram2d(x,y,
                                                          bins  = [nbin,nbin],
                                                          range = [[ind_min,ind_max],[dep_min,dep_max]])
                    counts  = np.ma.masked_values(counts.T,0)
                    counts /= float(counts.sum())
                    if name == "Benchmark":
                        obs_dist = counts
                    else:
                        mod_dist = counts
                                            
                    # render the figure
                    fig,ax = plt.subplots(figsize=(6,5.25),tight_layout=True)
                    cmap   = 'plasma'
                    if not plt.cm.cmap_d.has_key(cmap): cmap = 'summer'
                    pc     = ax.pcolormesh(xedges,
                                           yedges,
                                           counts,
                                           norm = LogNorm(),
                                           cmap = cmap,
                                           vmin = 1e-4,
                                           vmax = 1e-1)
                    div    = make_axes_locatable(ax)
                    fig.colorbar(pc,cax=div.append_axes("right",size="5%",pad=0.05),
                                 orientation="vertical",
                                 label="Fraction of total datasites")
                    ax.set_xlabel("%s/%s,  %s" % (ind_name,xlbl,post.UnitStringToMatplotlib(ind_var.unit)))
                    ylabel = "%s/%s,  %s" % (dep_name,ylbl,post.UnitStringToMatplotlib(dep_var.unit))
                    fsize  = 12
                    if len(ylabel) > 60: fsize = 10
                    ax.set_ylabel(ylabel,fontsize=fsize)
                    ax.set_xlim(ind_min,ind_max)
                    ax.set_ylim(dep_min,dep_max)
                    short_name = "rel_%s" % ind_name
                    fig.savefig(os.path.join(self.output_path,"%s_%s_%s.png" % (name,region,short_name)))
                    plt.close()

                    # add the figure to the HTML layout
                    if name == "Benchmark" and region == "global":
                        short_name = short_name.replace("global_","")
                        page.addFigure(c.longname,
                                       "benchmark_" + short_name,
                                       "Benchmark_RNAME_%s.png" % (short_name),
                                       legend = False,
                                       benchmark = False)
                        page.addFigure(c.longname,
                                       short_name,
                                       "MNAME_RNAME_%s.png" % (short_name),
                                       legend = False,
                                       benchmark = False)

                    # determine the 1D relationship curves
                    bins  = np.linspace(ind_min,ind_max,nbin+1)
                    delta = 0.1*(bins[1]-bins[0])
                    inds  = np.digitize(x,bins)
                    ids   = np.unique(inds).clip(1,bins.size-1)
                    xb = []
                    yb = []
                    eb = []
                    for i in ids:
                        yt = y[inds==i]
                        xi = 0.5
                        xb.append(xi*bins[i-1]+(1.-xi)*bins[i])
                        yb.append(yt.mean())
                        try:
                            eb.append(yt.std()) # for some reason this fails sometimes
                        except:
                            eb.append(np.sqrt(((yt-yb[-1])**2).sum()/float(yt.size)))
                            
                    if name == "Benchmark":
                        obs_x = np.asarray(xb)
                        obs_y = np.asarray(yb)
                        obs_e = np.asarray(eb)
                    else:
                        mod_x = np.asarray(xb)
                        mod_y = np.asarray(yb)
                        mod_e = np.asarray(eb)
                        
                # compute and plot the difference
                O = np.array(obs_dist.data)
                M = np.array(mod_dist.data)
                O[np.where(obs_dist.mask)] = 0.
                M[np.where(mod_dist.mask)] = 0.
                dif_dist = np.ma.masked_array(M-O,mask=obs_dist.mask*mod_dist.mask)
                lim      = np.abs(dif_dist).max()
                fig,ax   = plt.subplots(figsize=(6,5.25),tight_layout=True)
                pc       = ax.pcolormesh(xedges,
                                         yedges,
                                         dif_dist,
                                         cmap = "Spectral_r",
                                         vmin = -lim,
                                         vmax = +lim)
                div      = make_axes_locatable(ax)
                fig.colorbar(pc,cax=div.append_axes("right",size="5%",pad=0.05),
                             orientation="vertical",
                             label="Distribution Difference")
                ax.set_xlabel("%s, %s" % (   c.longname.split("/")[0],post.UnitStringToMatplotlib(obs_ind.unit)))
                ax.set_ylabel("%s, %s" % (self.longname.split("/")[0],post.UnitStringToMatplotlib(obs_dep.unit)))
                ax.set_xlim(ind_min,ind_max)
                ax.set_ylim(dep_min,dep_max)
                short_name = "rel_diff_%s" % ind_name
                fig.savefig(os.path.join(self.output_path,"%s_%s_%s.png" % (name,region,short_name)))
                plt.close()
                page.addFigure(c.longname,
                               short_name,
                               "MNAME_RNAME_%s.png" % (short_name),
                               legend = False,
                               benchmark = False)
                
                # score the distributions = 1 - Hellinger distance
                score = 1.-np.sqrt(((np.sqrt(obs_dist)-np.sqrt(mod_dist))**2).sum())/np.sqrt(2)
                vname = '%s Score %s' % (c.longname.split('/')[0],region)
                #if vname in scalars.variables:
                #    scalars.variables[vname][0] = score
                #else:
                #    Variable(name = vname, 
                #             unit = "1",
                #             data = score).toNetCDF4(results,group="Relationships")

                # plot the 1D curve
                fig,ax = plt.subplots(figsize=(6,5.25),tight_layout=True)
                ax.errorbar(obs_x-delta,obs_y,yerr=obs_e,fmt='-o',color='k')
                ax.errorbar(mod_x+delta,mod_y,yerr=mod_e,fmt='-o',color=m.color)
                ax.set_xlabel("%s, %s" % (   c.longname.split("/")[0],post.UnitStringToMatplotlib(obs_ind.unit)))
                ax.set_ylabel("%s, %s" % (self.longname.split("/")[0],post.UnitStringToMatplotlib(obs_dep.unit)))
                ax.set_xlim(ind_min,ind_max)
                ax.set_ylim(dep_min,dep_max)
                short_name = "rel_func_%s" % ind_name
                fig.savefig(os.path.join(self.output_path,"%s_%s_%s.png" % (name,region,short_name)))
                plt.close()
                page.addFigure(c.longname,
                               short_name,
                               "MNAME_RNAME_%s.png" % (short_name),
                               legend = False,
                               benchmark = False)

                # score the relationship
                i0,i1 = np.where(np.abs(obs_x[:,np.newaxis]-mod_x)<1e-12)
                score = np.exp(-np.linalg.norm(obs_y[i0]-mod_y[i1])/np.linalg.norm(obs_y[i0]))
                vname = '%s RMSE Score %s' % (c.longname.split('/')[0],region)
                if vname in scalars.variables:
                    scalars.variables[vname][0] = score
                else:
                    Variable(name = vname, 
                             unit = "1",
                             data = score).toNetCDF4(results,group="Relationships")
                    
                
        results.close()

class FileContextManager():

    def __init__(self,master,mod_results,obs_results):
        
        self.master       = master
        self.mod_results  = mod_results
        self.obs_results  = obs_results
        self.mod_dset     = None
        self.obs_dset     = None
        
    def __enter__(self):

        # Open the file on entering, both if you are the master
        self.mod_dset                 = Dataset(self.mod_results,mode="w")
        if self.master: self.obs_dset = Dataset(self.obs_results,mode="w")
        return self
    
    def __exit__(self, exc_type, exc_value, traceback):

        # Always close the file(s) on exit
        self.mod_dset.close()
        if self.master: self.obs_dset.close()

        # If an exception occurred, also remove the files
        if exc_type is not None:
            os.system("rm -f %s" % self.mod_results)

    
