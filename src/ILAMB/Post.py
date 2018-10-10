import pylab as plt
import numpy as np
from constants import space_opts,time_opts
from Regions import Regions
import re

def UseLatexPltOptions(fsize=18):
    params = {'axes.titlesize':fsize,
              'axes.labelsize':fsize,
              'font.size':fsize,
              'legend.fontsize':fsize,
              'xtick.labelsize':fsize,
              'ytick.labelsize':fsize}
    plt.rcParams.update(params)

def UnitStringToMatplotlib(unit,add_carbon=False):
    # replace 1e-6 with micro
    match = re.findall("(1e-6\s)",unit)
    for m in match: unit = unit.replace(m,"$\mu$")
    # raise exponents using Latex
    match = re.findall("(-\d)",unit)
    for m in match: unit = unit.replace(m,"$^{%s}$" % m)
    # add carbon symbol to all mass units
    if add_carbon:
        match = re.findall("(\D*g)",unit)
        for m in match: unit = unit.replace(m,"%s C " % m)
    return unit
        
def ColorBar(ax,**keywords):
    """Plot a colorbar.

    We plot colorbars separately so they can be rendered once and used
    for multiple plots.

    Parameters
    ----------
    ax : matplotlib.axes._subplots.AxesSubplot
        the matplotlib axes object onto which you wish to plot the variable
    vmin : float, optional
        the minimum plotted value
    vmax : float, optional
        the maximum plotted value
    cmap : str, optional
        the name of the colormap to be used in plotting the spatial variable
    label : str, optional
        the text which appears with the colorbar

    """
    from matplotlib import colorbar,colors
    vmin  = keywords.get("vmin",None)
    vmax  = keywords.get("vmax",None)
    cmap  = keywords.get("cmap","jet")
    ticks = keywords.get("ticks",None)
    ticklabels = keywords.get("ticklabels",None)
    label = keywords.get("label",None)
    cb = colorbar.ColorbarBase(ax,cmap=cmap,
                               norm=colors.Normalize(vmin=vmin,vmax=vmax),
                               orientation='horizontal')
    cb.set_label(label)
    if ticks is not None: cb.set_ticks(ticks)
    if ticklabels is not None: cb.set_ticklabels(ticklabels)

def TaylorDiagram(stddev,corrcoef,refstd,fig,colors,normalize=True):
    """Plot a Taylor diagram.

    This is adapted from the code by Yannick Copin found here:

    https://gist.github.com/ycopin/3342888
    
    Parameters
    ----------
    stddev : numpy.ndarray
        an array of standard deviations
    corrcoeff : numpy.ndarray
        an array of correlation coefficients
    refstd : float
        the reference standard deviation
    fig : matplotlib figure
        the matplotlib figure
    colors : array
        an array of colors for each element of the input arrays
    normalize : bool, optional
        disable to skip normalization of the standard deviation

    """
    from matplotlib.projections import PolarAxes
    import mpl_toolkits.axisartist.floating_axes as FA
    import mpl_toolkits.axisartist.grid_finder as GF

    # define transform
    tr = PolarAxes.PolarTransform()

    # correlation labels
    rlocs = np.concatenate((np.arange(10)/10.,[0.95,0.99]))
    tlocs = np.arccos(rlocs)
    gl1   = GF.FixedLocator(tlocs)
    tf1   = GF.DictFormatter(dict(zip(tlocs,map(str,rlocs))))

    # standard deviation axis extent
    if normalize:
        stddev = stddev/refstd
        refstd = 1.
    smin = 0
    smax = max(2.0,1.1*stddev.max())

    # add the curvilinear grid
    ghelper = FA.GridHelperCurveLinear(tr,
                                       extremes=(0,np.pi/2,smin,smax),
                                       grid_locator1=gl1,
                                       tick_formatter1=tf1)
    ax = FA.FloatingSubplot(fig, 111, grid_helper=ghelper)
    fig.add_subplot(ax)

    # adjust axes
    ax.axis["top"].set_axis_direction("bottom")
    ax.axis["top"].toggle(ticklabels=True,label=True)
    ax.axis["top"].major_ticklabels.set_axis_direction("top")
    ax.axis["top"].label.set_axis_direction("top")
    ax.axis["top"].label.set_text("Correlation")
    ax.axis["left"].set_axis_direction("bottom")
    if normalize:
        ax.axis["left"].label.set_text("Normalized standard deviation")
    else:
        ax.axis["left"].label.set_text("Standard deviation")
    ax.axis["right"].set_axis_direction("top")
    ax.axis["right"].toggle(ticklabels=True)
    ax.axis["right"].major_ticklabels.set_axis_direction("left")
    ax.axis["bottom"].set_visible(False)
    ax.grid(True)
    
    ax = ax.get_aux_axes(tr)
    # Plot data
    corrcoef = corrcoef.clip(-1,1)
    for i in range(len(corrcoef)):
        ax.plot(np.arccos(corrcoef[i]),stddev[i],'o',color=colors[i],mew=0,ms=8)
            
    # Add reference point and stddev contour
    l, = ax.plot([0],refstd,'k*',ms=12,mew=0)
    t = np.linspace(0, np.pi/2)
    r = np.zeros_like(t) + refstd
    ax.plot(t,r, 'k--')

    # centralized rms contours
    rs,ts = np.meshgrid(np.linspace(smin,smax),
                        np.linspace(0,np.pi/2))
    rms = np.sqrt(refstd**2 + rs**2 - 2*refstd*rs*np.cos(ts))
    contours = ax.contour(ts,rs,rms,5,colors='k',alpha=0.4)
    ax.clabel(contours,fmt='%1.1f')


    return ax

class HtmlFigure():

    def __init__(self,name,pattern,side=None,legend=False,benchmark=False,longname=None):

        self.name      = name
        self.pattern   = pattern
        self.side      = side
        self.legend    = legend
        self.benchmark = benchmark
        self.longname  = longname
        
    def generateClickRow(self,allModels=False):
        name = self.pattern
        if allModels: name = name.replace(self.name,"PNAME")
        for token in ['CNAME','MNAME','RNAME','PNAME']:
            name = name.split(token)
            name = ("' + %s + '" % token).join(name)
        name = "'%s'" % name
        name = name.replace("'' + ","")
        code = """
          document.getElementById('%s').src =  %s""" % (self.name,name)
        if self.benchmark:
            name = self.pattern.replace('MNAME','Benchmark')
            for token in ['CNAME','MNAME','RNAME']:
                name = name.split(token)
                name = ("' + %s + '" % token).join(name)
            name = "'%s'" % name
            name = name.replace("'' + ","")
            code += """
          document.getElementById('benchmark_%s').src =  %s""" % (self.name,name)
        return code

    def __str__(self):

        code = """
        <div class="container" id="%s_div">
          <div class="child">""" % (self.name)
        if self.side is not None:
            code += """
          <center>%s</center>""" % (self.side.replace(" ","&nbsp;"))
        code += """
          <img src="" id="%s" alt="Data not available"></img>""" % (self.name)
        if self.legend:
            code += """
          <center><img src="legend_%s.png" id="leg"  alt="Data not available"></img></center>""" % (self.name.replace("benchmark_",""))
        code += """
          </div>
        </div>"""
        return code


class HtmlPage(object):

    def __init__(self,name,title):
        self.name  = name
        self.title = title
        self.cname = ""
        self.pages = []
        self.metric_dict = None
        self.models      = None
        self.regions     = None
        self.metrics     = None
        self.units       = None
        self.priority    = ["original","Model","intersection","complement","Benchmark","Bias","RMSE","Phase","Seasonal","Spatial","Interannual","Score","Overall"]
        self.header      = "CNAME"
        self.sections    = []
        self.figures     = {}
        self.text        = None
        self.inserts     = []
        
    def __str__(self):

        r = Regions()
        def _sortFigures(figure):
            macro = ["timeint","bias","rmse","iav","phase","shift","variance","spaceint","accumulate","cycle"]
            val = 1.
            for i,m in enumerate(macro):
                if m in figure.name: val += 3**i
            if figure.name.startswith("benchmark"): val -= 1.
            if figure.name.endswith("score"): val += 1.
            if figure.name.startswith("legend"):
                if "variance" in figure.name:
                    val += 1.
                else:
                    val  = 0.
            return val        
        
        code = """
    <div data-role="page" id="%s">
      <div data-role="header" data-position="fixed" data-tap-toggle="false">
        <h1 id="%sHead">%s</h1>""" % (self.name,self.name,self.title)
        if self.pages:
	    code += """
        <div data-role="navbar">
	  <ul>""" 
            for page in self.pages:
                opts = ""
                if page == self: opts = " class=ui-btn-active ui-state-persist"
                code += """
            <li><a href='#%s'%s>%s</a></li>""" % (page.name,opts,page.title)
            code += """
	  </ul>"""
        code += """
	</div>
      </div>"""

        if self.regions:
            code += """
      <select id="%sRegion" onchange="changeRegion%s()">""" % (self.name,self.name)
            for region in self.regions:
                try:
                    rname = r.getRegionName(region)
                except:
                    rname = region
                opts  = ''
                if region == "global" or len(self.regions) == 1:
                    opts  = ' selected="selected"'
                code += """
        <option value='%s'%s>%s</option>""" % (region,opts,rname)
            code += """
      </select>"""
            
        if self.models:
            code += """
      <div style="display:none">
      <select id="%sModel">""" % (self.name)
            for i,model in enumerate(self.models):
                opts  = ' selected="selected"' if i == 1 else '' 
                code += """
        <option value='%s'%s>%s</option>""" % (model,opts,model)
            code += """
      </select>
      </div>"""
                
        if self.metric_dict: code += self.metricsToHtmlTables()
        
        if self.text is not None:
            code += """
      %s""" % self.text
            
        for section in self.sections:
            if len(self.figures[section]) == 0: continue
            self.figures[section].sort(key=_sortFigures)
            code += """
        <div data-role="collapsible" data-collapsed="false"><h1>%s</h1>""" % section
            for figure in self.figures[section]:
                if figure.name == "spatial_variance": code += "<br>"
                code += "%s" % (figure)
            code += """
        </div>"""
            
        code += """
    </div>"""
        return code
    
    def setHeader(self,header):
        self.header = header

    def setSections(self,sections):

        assert type(sections) == type([])
        self.sections = sections
        for section in sections: self.figures[section] = []

    def addFigure(self,section,name,pattern,side=None,legend=False,benchmark=False,longname=None):

        assert section in self.sections
        for fig in self.figures[section]:
            if fig.name == name: return
        self.figures[section].append(HtmlFigure(name,pattern,side=side,legend=legend,benchmark=benchmark,longname=longname))
    
    def setMetricPriority(self,priority):
        self.priority = priority

    def metricsToHtmlTables(self):
        if not self.metric_dict: return ""
        regions = self.regions
        metrics = self.metrics
        units   = self.units
        cname   = self.cname.split(" / ")
        if len(cname) == 3:
            cname = cname[1].strip()
        else:
            cname = cname[-1].strip()
        html    = ""
        inserts = self.inserts
        j0 = 0 if "Benchmark" in self.models else -1
        score_sig = 2 # number of significant digits used in the score tables
        other_sig = 3 # number of significant digits used for non-score quantities
        for region in regions:
            html += """
        <center>
        <table class="table-header-rotated" id="%s_table_%s">
           <thead>
             <tr>
               <th></th>
               <th class="rotate"><div><span>Download Data</span></div></th>""" % (self.name,region)
            for i,metric in enumerate(metrics):
                if i in inserts: html += """
               <th></th>"""
                html += """
               <th class="rotate"><div><span>%s [%s]</span></div></th>""" % (metric,units[metric])
            html += """
             </tr>
           </thead>
           <tbody>"""

            for j,model in enumerate(self.models):
                opts = ' onclick="highlightRow%s(this)"' % (self.name) if j > j0 else ''
                html += """
             <tr>
               <td%s class="row-header">%s</td>
               <td%s><a href="%s_%s.nc" download>[-]</a></td>""" % (opts,model,opts,cname,model)
                for i,metric in enumerate(metrics):
                    sig = score_sig if "score" in metric.lower() else other_sig
                    if i in inserts: html += """
               <td%s class="divider"></td>""" % (opts)
                    add = ""
                    try:
                        add = ("%#." + "%d" % sig + "g") % self.metric_dict[model][region][metric].data
                        add = add.lower().replace("nan","")
                    except:
                        pass
                    html += """
               <td%s>%s</td>""" % (opts,add)
                html += """
             </tr>"""
            html += """
          </tbody>
        </table>
        </center>"""
        
        return html
    
    def googleScript(self):
        if not self.metric_dict: return ""
        models   = self.models
        regions  = self.regions
        metrics  = self.metrics
        units    = self.units
        cname    = self.cname.split(" / ")
        if len(cname) == 3:
            cname = cname[1].strip()
        else:
            cname = cname[-1].strip()



        rows = ""
        for section in self.sections:
            for figure in self.figures[section]:
                rows += figure.generateClickRow()
        
        head = """

        function updateImagesAndHeaders%s(){
            var rsel  = document.getElementById("%sRegion");
            var msel  = document.getElementById("%sModel");
            var rid   = rsel.selectedIndex;
            var mid   = msel.selectedIndex;
            var RNAME = rsel.options[rid].value;
            var MNAME = msel.options[mid].value;
            var CNAME = "%s";
            var head  = "%s";
            head      = head.replace("CNAME",CNAME).replace("RNAME",RNAME).replace("MNAME",MNAME);
            $("#%sHead").text(head);
            %s
        }""" % (self.name,self.name,self.name,self.cname,self.header,self.name,rows)

        nscores = len(metrics)
        if len(self.inserts) > 0: nscores -= self.inserts[-1]
        r0      = 2 if "Benchmark" in models else 1

        head += """

	function highlightRow%s(cell) {
	    var select = document.getElementById("%sRegion");
	    for (var i = 0; i < select.length; i++){
		var table = document.getElementById("%s_table_" + select.options[i].value);
		var rows  = table.getElementsByTagName("tr");
		for (var r = %d; r < rows.length; r++) {
        	    for (var c = 0; c < rows[r].cells.length-%d; c++) {
        		rows[r].cells[c].style.backgroundColor = "#ffffff";
        	    }
		}
		var r = cell.closest("tr").rowIndex;
                document.getElementById("%sModel").selectedIndex = r-1;
		for (var c = 0; c < rows[r].cells.length-%d; c++) {
        	    rows[r].cells[c].style.backgroundColor = "#c1c1c1";
		}
	    }
            updateImagesAndHeaders%s();
	}""" % (self.name,self.name,self.name,r0,nscores+1,self.name,nscores+1,self.name)
        
        head += """

        function paintScoreCells%s(RNAME) {
	    var colors = ['#fb6a4a','#fc9272','#fcbba1','#fee0d2','#fff5f0','#f7fcf5','#e5f5e0','#c7e9c0','#a1d99b','#74c476'];
            var table  = document.getElementById("%s_table_" + RNAME);
            var rows   = table.getElementsByTagName("tr");
            for (var c = rows[0].cells.length-%d; c < rows[0].cells.length; c++) {		
		var scores = [];
		for (var r = %d; r < rows.length; r++) {
                    val = rows[r].cells[c].innerHTML;
                    if (val=="") {
      		      scores[r-%d] = 0;
                    }else{
		      scores[r-%d] = parseFloat(val);
                    }
		}
		var mean = math.mean(scores);
		var std  = math.max(0.02,math.std(scores));
		for (var r = %d; r < rows.length; r++) {
		    scores[r-%d] = (scores[r-%d]-mean)/std;
		}
		var smax = math.max(scores);
		var smin = math.min(scores);
                if (math.abs(smax-smin) < 1e-12) {
		    smin = -1.0;
		    smax =  1.0;
		}
		for (var r = %d; r < rows.length; r++) {
		    var clr = math.round((scores[r-%d]-smin)/(smax-smin)*10);
		    clr     = math.min(9,math.max(0,clr));
		    rows[r].cells[c].style.backgroundColor = colors[clr];
		}
	    }
	}""" % (self.name,self.name,nscores,r0,r0,r0,r0,r0,r0,r0,r0)

        head += """

	function pageLoad%s() {
	    var select = document.getElementById("%sRegion");
	    var region = getQueryVariable("region");
	    var model  = getQueryVariable("model");
	    if (region) {
		for (var i = 0; i < select.length; i++){
		    if (select.options[i].value == region) select.selectedIndex = i;
		}
	    }
	    var table = document.getElementById("%s_table_" + select.options[select.selectedIndex].value);
	    var rows  = table.getElementsByTagName("tr");
	    if (model) {
		for (var r = 0; r < rows.length; r++) {
		    if(rows[r].cells[0].innerHTML==model) highlightRow%s(rows[r].cells[0]);
		}
	    }else{
		highlightRow%s(rows[%d]);
	    }
	    for (var i = 0; i < select.length; i++){
		paintScoreCells%s(select.options[i].value);
	    }
	    changeRegion%s();
	}

        function changeRegion%s() {
	    var select = document.getElementById("%sRegion");
	    for (var i = 0; i < select.length; i++){
		RNAME = select.options[i].value;
		if (i == select.selectedIndex) {
		    document.getElementById("%s_table_" + RNAME).style.display = "table";
		}else{
		    document.getElementById("%s_table_" + RNAME).style.display = "none";
		}		
	    }
            updateImagesAndHeaders%s();
	}""" % (self.name,self.name,self.name,self.name,self.name,r0,self.name,self.name,self.name,self.name,self.name,self.name,self.name)
            
        return head,"pageLoad%s" % self.name,""

    def setRegions(self,regions):
        assert type(regions) == type([])
        self.regions = regions
    
    def setMetrics(self,metric_dict):

        # Sorting function        
        def _sortMetrics(name,priority=self.priority):
            val = 1.
            for i,pname in enumerate(priority):
                if pname in name: val += 2**i
            return val

        assert type(metric_dict) == type({})
        self.metric_dict = metric_dict
        
        # Build and sort models, regions, and metrics
        models  = self.metric_dict.keys()
        regions = []
        metrics = []
        units   = {}
        for model in models:
            for region in self.metric_dict[model].keys():
                if region not in regions: regions.append(region)
                for metric in self.metric_dict[model][region].keys():
                    units[metric] = self.metric_dict[model][region][metric].unit
                    if metric not in metrics: metrics.append(metric)
        models.sort(key=lambda key: key.lower())
        if "Benchmark" in models: models.insert(0,models.pop(models.index("Benchmark")))
        regions.sort()
        metrics.sort(key=_sortMetrics)
        self.models  = models
        if self.regions is None: self.regions = regions
        self.metrics = metrics
        self.units   = units

        tmp = [("bias" in m.lower()) for m in metrics]
        if tmp.count(True) > 0: self.inserts.append(tmp.index(True))
        tmp = [("score" in m.lower()) for m in metrics]
        if tmp.count(True) > 0: self.inserts.append(tmp.index(True))
        
    def head(self):
        return ""
    
class HtmlAllModelsPage(HtmlPage):

    def __init__(self,name,title):
        
        super(HtmlAllModelsPage,self).__init__(name,title)
        self.plots    = None
        self.nobench  = None
        self.nolegend = []
        
    def _populatePlots(self):

        self.plots   = []
        bench        = []
        for page in self.pages:
            if page.sections is not None:
                for section in page.sections:
                    if len(page.figures[section]) == 0: continue
                    for figure in page.figures[section]:
                        if (figure.name in ["spatial_variance","compcycle","profile",
                                            "legend_spatial_variance","legend_compcycle"]): continue # ignores
                        if "benchmark" in figure.name:
                            if figure.name not in bench: bench.append(figure.name)
                            continue
                        if figure not in self.plots: self.plots.append(figure)
                        if not figure.legend: self.nolegend.append(figure.name)
        self.nobench = [plot.name for plot in self.plots if "benchmark_%s" % (plot.name) not in bench]
        
    def __str__(self):

        if self.plots is None: self._populatePlots()
        r = Regions()
        
        code = """
    <div data-role="page" id="%s">
      <div data-role="header" data-position="fixed" data-tap-toggle="false">
        <h1 id="%sHead">%s</h1>""" % (self.name,self.name,self.title)
        if self.pages:
	    code += """
        <div data-role="navbar">
	  <ul>""" 
            for page in self.pages:
                opts = ""
                if page == self: opts = " class=ui-btn-active ui-state-persist"
                code += """
            <li><a href='#%s'%s>%s</a></li>""" % (page.name,opts,page.title)
            code += """
	  </ul>"""
        code += """
	</div>
      </div>"""

        if self.regions:
            code += """
      <select id="%sRegion" onchange="AllSelect()">""" % (self.name)
            for region in self.regions:
                try:
                    rname = r.getRegionName(region)
                except:
                    rname = region
                opts  = ''
                if region == "global" or len(self.regions) == 1:
                    opts  = ' selected="selected"'
                code += """
        <option value='%s'%s>%s</option>""" % (region,opts,rname)
            code += """
      </select>"""
                
        if self.plots:
            code += """
      <select id="%sPlot" onchange="AllSelect()">""" % (self.name)
            for plot in self.plots:                
                name  = ''
                if space_opts.has_key(plot.name):
                    name = space_opts[plot.name]["name"]
                elif time_opts.has_key(plot.name):
                    name = time_opts[plot.name]["name"]
                elif plot.longname is not None:
                    name = plot.longname
                if "rel_" in plot.name: name = plot.name.replace("rel_","Relationship with ")
                if name == "": continue
                opts  = ''
                if plot.name == "timeint" or len(self.plots) == 1:
                    opts  = ' selected="selected"'
                code += """
        <option value='%s'%s>%s</option>""" % (plot.name,opts,name)
            code += """
      </select>"""
            
            fig        = self.plots[0]
            rem_side   = fig.side
            fig.side   = "MNAME"
            rem_leg    = fig.legend
            fig.legend = True
            img        = "%s" % (fig)
            img        = img.replace('"leg"','"MNAME_legend"').replace("%s" % fig.name,"MNAME")
            fig.side   = rem_side
            fig.legend = rem_leg
            for model in self.pages[0].models:
                code += img.replace("MNAME",model)
                        
        if self.text is not None:
            code += """
      %s""" % self.text
            
        code += """
    </div>"""
        return code

    def googleScript(self):
        head = self.head()
        return head,"",""
    
    def head(self):
        
        if self.plots is None: self._populatePlots()
        
        models  = self.pages[0].models
        regions = self.regions
        try:
            regions.sort()
        except:
            pass
        head    = """
      function AllSelect() {
        var header = "%s";
        var CNAME  = "%s";
        header     = header.replace("CNAME",CNAME);
        var rid    = document.getElementById("%s").selectedIndex;
        var RNAME  = document.getElementById("%s").options[rid].value;
        var pid    = document.getElementById("%s").selectedIndex;
        var PNAME  = document.getElementById("%s").options[pid].value;
        header     = header.replace("RNAME",RNAME);
        $("#%sHead").text(header);""" % (self.header,self.cname,self.name+"Region",self.name+"Region",self.name+"Plot",self.name+"Plot",self.name)
        cond  = " || ".join(['PNAME == "%s"' % n for n in self.nobench])
        if cond == "": cond = "0"
        head += """
        if(%s){
          document.getElementById("Benchmark_div").style.display = 'none';
        }else{
          document.getElementById("Benchmark_div").style.display = 'inline';
        }""" % (cond)

        cond  = " || ".join(['PNAME == "%s"' % n for n in self.nolegend])
        if cond == "": cond = "0"
        head += """
        if(%s){""" % cond
        for model in models:
            head += """
          document.getElementById("%s_legend").style.display = 'none';""" % model
        head += """
        }else{"""
        for model in models:
            head += """
          document.getElementById("%s_legend").style.display = 'inline';""" % model
        head += """
        }"""
        for model in models:
            head += """
        document.getElementById('%s').src = '%s_' + RNAME + '_' + PNAME + '.png';
        document.getElementById('%s_legend').src = 'legend_' + PNAME + '.png';""" % (model,model,model)
        head += """
      }

      $(document).on('pageshow', '[data-role="page"]', function(){ 
        AllSelect()
      });"""
        return head

class HtmlSitePlotsPage(HtmlPage):

    def __init__(self,name,title):
        
        super(HtmlSitePlotsPage,self).__init__(name,title)

    def __str__(self):

        # setup page navigation
        code = """
    <div data-role="page" id="%s">
      <div data-role="header" data-position="fixed" data-tap-toggle="false">
        <h1 id="%sHead">%s</h1>""" % (self.name,self.name,self.title)
        if self.pages:
	    code += """
        <div data-role="navbar">
	  <ul>""" 
            for page in self.pages:
                opts = ""
                if page == self: opts = " class=ui-btn-active ui-state-persist"
                code += """
            <li><a href='#%s'%s>%s</a></li>""" % (page.name,opts,page.title)
            code += """
	  </ul>"""
        code += """
	</div>
      </div>"""

        code += """
      <select id="%sModel" onchange="%sMap()">""" % (self.name,self.name)
        for model in self.models:
            code += """
        <option value='%s'>%s</option>""" % (model,model)
        code += """
      </select>"""

        code += """
      <select id="%sSite" onchange="%sMap()">""" % (self.name,self.name)
        for site in self.sites:
            code += """
        <option value='%s'>%s</option>""" % (site,site)
        code += """
      </select>"""
        
        code += """
      <center>
        <div id='map_canvas'></div>
        <div><img src="" id="time" alt="Data not available"></img></div>
      </center>"""

        code += """
    </div>"""
        
        return code
    
    def setMetrics(self,metric_dict):
        self.models.sort()
        
    def googleScript(self):

        callback = "%sMap()" % (self.name)
        head = """
      function %sMap() {
        var sitedata = google.visualization.arrayToDataTable(
          [['Latitude', 'Longitude', '%s [%s]'],\n""" % (self.name,self.vname,self.unit)

        for lat,lon,val in zip(self.lat,self.lon,self.vals):
            if val is np.ma.masked:
                sval = "null"
            else:
                sval = "%.2f" % val
            head += "           [%.3f,%.3f,%s],\n" % (lat,lon,sval)
        head = head[:-2] + "]);\n"
        head += ("        var names = %s;" % (self.sites)).replace("u'","'").replace(", '",",'")
        head += """
        var options = {
          dataMode: 'markers',
          magnifyingGlass: {enable: true, zoomFactor: 3.},
        };
        var container = document.getElementById('map_canvas');
        var geomap    = new google.visualization.GeoChart(container);
        function updateMap() {
          var mid    = document.getElementById("%sModel").selectedIndex;
          var MNAME  = document.getElementById("%sModel").options[mid].value;
          var rid    = document.getElementById("%sSite" ).selectedIndex;
          var RNAME  = document.getElementById("%sSite" ).options[rid].value;
          document.getElementById('time').src = MNAME + '_' + RNAME + '_time.png';
        }
        function clickMap() {
          var select = geomap.getSelection();
          if (Object.keys(select).length == 1) {
            var site = $("select#SitePlotsSite");
            site[0].selectedIndex = select[0].row;
            site.selectmenu('refresh');         
          }
          updateMap();
        }
        google.visualization.events.addListener(geomap,'select',clickMap);
        geomap.draw(sitedata, options);
        updateMap();
      };""" % (self.name,self.name,self.name,self.name)
        
        return head,callback,"geomap"

    def head(self):
        return ""
    
class HtmlLayout():

    def __init__(self,pages,cname,years=None):
        
        self.pages = pages
        self.cname = cname.replace("/"," / ")
        if years is not None:
            try:
                self.cname += " / %d-%d" % (years)
            except:
                pass
        for page in self.pages:
            page.pages = self.pages
            page.cname = self.cname
                
    def __str__(self):
        code = """<html>
  <head>"""

        code += """
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css">
    <script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/mathjs/3.16.5/math.min.js"></script>
    <script>
        function getQueryVariable(variable) {
	    var query = window.location.search.substring(1);
	    var vars = query.split("&");
	    for (var i=0;i<vars.length;i++) {
		var pair = vars[i].split("=");
		if(pair[0] == variable){return pair[1];}
	    }
	    return(false);
	}
    </script>"""

        functions = []
        callbacks = []
        packages  = []
        for page in self.pages:
            out = page.googleScript()
            if len(out) == 3:
                f,c,p = out
                if f != "": functions.append(f)
                if c != "": callbacks.append(c)
                if p != "": packages.append(p)

        code += """
    <script type='text/javascript'>
        function pageLoad() {"""
        for c in callbacks:
            code += """
           %s();""" % c
        code += """
        }
    </script>"""
        
        code += """
    <script type='text/javascript'>"""
        for f in functions:
            code += f
        code += """
    </script>"""

        max_height = 280 # will be related to max column header length across all pages
        code += """
    <style type="text/css">
      .container{
        display:inline;
      }
      .child{
        margin-bottom:10px;
        display:inline-block;
        padding:5px;
        font-size: 20px;
        font-weight: bold;
      }   
      table.table-header-rotated {
          border-collapse: collapse;
      }
      td {
          width: 30px;
          text-align: center;
          padding: 10px 5px;
          border: 1px solid #ccc;
      }
      th {
          padding: 5px 10px;
      }
      th.rotate {
          height: %dpx;
          white-space: nowrap;    
      }
      th.rotate > div {
          transform: translate(10px, %dpx) rotate(-45deg);
          width: 0px;
      }
      th.rotate > div > span {
      }
      th.row-header {
          padding: 0px 10px;
          text-align: right;
      }
      td.divider {
          width: 0px;
          border: 0px solid #ccc;
          padding: 0px 0px
      }
    </style>""" % (max_height,max_height/2-5)

        code += """
  </head>
  <body onload="pageLoad()">"""

        ### loop over pages
        for page in self.pages: code += "%s" % (page)

        code += """
  </body>
</html>"""
        return code

def RegisterCustomColormaps():
    """Adds the 'stoplight' and 'RdGn' colormaps to matplotlib's database

    """
    import colorsys as cs
    
    # stoplight colormap
    Rd1    = [1.,0.,0.]; Rd2 = Rd1
    Yl1    = [1.,1.,0.]; Yl2 = Yl1
    Gn1    = [0.,1.,0.]; Gn2 = Gn1
    val    = 0.65
    Rd1    = cs.rgb_to_hsv(Rd1[0],Rd1[1],Rd1[2])
    Rd1    = cs.hsv_to_rgb(Rd1[0],Rd1[1],val   )
    Yl1    = cs.rgb_to_hsv(Yl1[0],Yl1[1],Yl1[2])
    Yl1    = cs.hsv_to_rgb(Yl1[0],Yl1[1],val   )
    Gn1    = cs.rgb_to_hsv(Gn1[0],Gn1[1],Gn1[2])
    Gn1    = cs.hsv_to_rgb(Gn1[0],Gn1[1],val   )
    p      = 0
    level1 = 0.5
    level2 = 0.75
    RdYlGn = {'red':   ((0.0     , 0.0   ,Rd1[0]),
                        (level1-p, Rd2[0],Rd2[0]),
                        (level1+p, Yl1[0],Yl1[0]),
                        (level2-p, Yl2[0],Yl2[0]),
                        (level2+p, Gn1[0],Gn1[0]),
                        (1.00    , Gn2[0],  0.0)),
              
              'green': ((0.0     , 0.0   ,Rd1[1]),
                        (level1-p, Rd2[1],Rd2[1]),
                        (level1+p, Yl1[1],Yl1[1]),
                        (level2-p, Yl2[1],Yl2[1]),
                        (level2+p, Gn1[1],Gn1[1]),
                        (1.00    , Gn2[1],  0.0)),
              
              'blue':  ((0.0     , 0.0   ,Rd1[2]),
                        (level1-p, Rd2[2],Rd2[2]),
                        (level1+p, Yl1[2],Yl1[2]),
                        (level2-p, Yl2[2],Yl2[2]),
                        (level2+p, Gn1[2],Gn1[2]),
                        (1.00    , Gn2[2],  0.0))}
    plt.register_cmap(name='stoplight', data=RdYlGn)
    
    # RdGn colormap
    val = 0.8
    Rd  = cs.rgb_to_hsv(1,0,0)
    Rd  = cs.hsv_to_rgb(Rd[0],Rd[1],val)
    Gn  = cs.rgb_to_hsv(0,1,0)
    Gn  = cs.hsv_to_rgb(Gn[0],Gn[1],val)
    RdGn = {'red':   ((0.0, 0.0,   Rd[0]),
                      (0.5, 1.0  , 1.0  ),
                      (1.0, Gn[0], 0.0  )),
            'green': ((0.0, 0.0,   Rd[1]),
                      (0.5, 1.0,   1.0  ),
                      (1.0, Gn[1], 0.0  )),
            'blue':  ((0.0, 0.0,   Rd[2]),
                      (0.5, 1.0,   1.0  ),
                      (1.0, Gn[2], 0.0  ))}
    plt.register_cmap(name='RdGn', data=RdGn)


def BenchmarkSummaryFigure(models,variables,data,figname,vcolor=None,rel_only=False):
    """Creates a summary figure for the benchmark results contained in the
    data array.

    Parameters
    ----------
    models : list
        a list of the model names 
    variables : list
        a list of the variable names
    data : numpy.ndarray or numpy.ma.ndarray
        data scores whose shape is ( len(variables), len(models) )
    figname : str
        the full path of the output file to write
    vcolor : list, optional
        an array parallel to the variables array containing background 
        colors for the labels to be displayed on the y-axis.
    """
    from mpl_toolkits.axes_grid1 import make_axes_locatable
    
    # data checks
    assert  type(models)    is type(list())
    assert  type(variables) is type(list())
    assert (type(data)      is type(np   .empty(1)) or
            type(data)      is type(np.ma.empty(1)))
    assert data.shape[0] == len(variables)
    assert data.shape[1] == len(models   )
    assert  type(figname)   is type("")
    if vcolor is not None:
        assert type(vcolor) is type(list())
        assert len(vcolor) == len(variables)
        
    # define some parameters
    nmodels    = len(models)
    nvariables = len(variables)
    maxV       = max([len(v) for v in variables])
    maxM       = max([len(m) for m in models])
    wpchar     = 0.15
    wpcell     = 0.19
    hpcell     = 0.25
    w          = maxV*wpchar + max(4,nmodels)*wpcell
    if not rel_only: w += (max(4,nmodels)+1)*wpcell
    h          = maxM*wpchar + nvariables*hpcell + 1.0

    bad        = 0.5
    if "stoplight" not in plt.colormaps(): RegisterCustomColormaps()
    
    # plot the variable scores
    if rel_only:
        fig,ax = plt.subplots(figsize=(w,h),ncols=1,tight_layout=True)
        ax     = [ax]
    else:
        fig,ax = plt.subplots(figsize=(w,h),ncols=2,tight_layout=True)

    # absolute score
    if not rel_only:
        cmap   = plt.get_cmap('stoplight')
        cmap.set_bad('k',bad)
        qc     = ax[0].pcolormesh(np.ma.masked_invalid(data[::-1,:]),cmap=cmap,vmin=0,vmax=1,linewidth=0)
        div    = make_axes_locatable(ax[0])
        fig.colorbar(qc,
                     ticks=(0,0.25,0.5,0.75,1.0),
                     format="%g",
                     cax=div.append_axes("bottom", size="5%", pad=0.05),
                     orientation="horizontal",
                     label="Absolute Score")
        plt.tick_params(which='both', length=0)
        ax[0].xaxis.tick_top()
        ax[0].set_xticks     (np.arange(nmodels   )+0.5)
        ax[0].set_xticklabels(models,rotation=90)
        ax[0].set_yticks     (np.arange(nvariables)+0.5)
        ax[0].set_yticklabels(variables[::-1])
        ax[0].tick_params('both',length=0,width=0,which='major')
        ax[0].tick_params(axis='y',pad=10)
        ax[0].set_xlim(0,nmodels)
        ax[0].set_ylim(0,nvariables)
        if vcolor is not None:
            for i,t in enumerate(ax[0].yaxis.get_ticklabels()):
                t.set_backgroundcolor(vcolor[::-1][i])

    # relative score
    i = 0 if rel_only else 1
    np.seterr(invalid='ignore',under='ignore')
    data = np.ma.masked_invalid(data)
    data.data[data.mask] = 1.
    data = np.ma.masked_values(data,1.)
    mean = data.mean(axis=1)
    std  = data.std (axis=1).clip(0.02)
    np.seterr(invalid='ignore',under='ignore')
    Z    = (data-mean[:,np.newaxis])/std[:,np.newaxis]
    Z    = np.ma.masked_invalid(Z)
    np.seterr(invalid='warn',under='raise')
    cmap = plt.get_cmap('RdGn')
    cmap.set_bad('k',bad)
    qc   = ax[i].pcolormesh(Z[::-1],cmap=cmap,vmin=-2,vmax=2,linewidth=0)
    div  = make_axes_locatable(ax[i])
    fig.colorbar(qc,
                 ticks=(-2,-1,0,1,2),
                 format="%+d",
                 cax=div.append_axes("bottom", size="5%", pad=0.05),
                 orientation="horizontal",
                 label="Relative Score")
    plt.tick_params(which='both', length=0)
    ax[i].xaxis.tick_top()
    ax[i].set_xticks(np.arange(nmodels)+0.5)
    ax[i].set_xticklabels(models,rotation=90)
    ax[i].tick_params('both',length=0,width=0,which='major')
    ax[i].set_yticks([])
    ax[i].set_xlim(0,nmodels)
    ax[i].set_ylim(0,nvariables)
    if rel_only:
        ax[i].set_yticks     (np.arange(nvariables)+0.5)
        ax[i].set_yticklabels(variables[::-1])
        if vcolor is not None:
            for i,t in enumerate(ax[i].yaxis.get_ticklabels()):
                t.set_backgroundcolor(vcolor[::-1][i])

    # save figure
    fig.savefig(figname)

def WhittakerDiagram(X,Y,Z,**keywords):
    """Creates a Whittaker diagram.
    
    Parameters
    ----------
    X : ILAMB.Variable.Variable
       the first independent axis, classically representing temperature
    Y : ILAMB.Variable.Variable
       the second independent axis, classically representing precipitation
    Z : ILAMB.Variable.Variable
       the dependent axis
    X_plot_unit,Y_plot_unit,Z_plot_unit : str, optional
       the string representing the units of the corresponding variable
    region : str, optional
       the string representing the region overwhich to plot the diagram
    X_min,Y_min,Z_min : float, optional
       the minimum plotted value of the corresponding variable
    X_max,Y_max,Z_max : float, optional
       the maximum plotted value of the corresponding variable
    X_label,Y_label,Z_label : str, optional
       the labels of the corresponding variable
    filename : str, optional
       the output filename
    """
    from mpl_toolkits.axes_grid1 import make_axes_locatable
    
    # possibly integrate in time
    if X.temporal: X = X.integrateInTime(mean=True)
    if Y.temporal: Y = Y.integrateInTime(mean=True)
    if Z.temporal: Z = Z.integrateInTime(mean=True)
    
    # convert to plot units
    X_plot_unit = keywords.get("X_plot_unit",X.unit)
    Y_plot_unit = keywords.get("Y_plot_unit",Y.unit)
    Z_plot_unit = keywords.get("Z_plot_unit",Z.unit)
    if X_plot_unit is not None: X.convert(X_plot_unit)
    if Y_plot_unit is not None: Y.convert(Y_plot_unit)
    if Z_plot_unit is not None: Z.convert(Z_plot_unit)
    
    # flatten data, if any data is masked all the data is masked
    mask   = (X.data.mask + Y.data.mask + Z.data.mask)==0

    # mask outside region
    from constants import regions as ILAMBregions
    region    = keywords.get("region","global")
    lats,lons = ILAMBregions[region]
    mask     += (np.outer((X.lat>lats[0])*(X.lat<lats[1]),
                          (X.lon>lons[0])*(X.lon<lons[1]))==0)
    x    = X.data[mask].flatten()
    y    = Y.data[mask].flatten()
    z    = Z.data[mask].flatten()

    # make plot
    fig,ax = plt.subplots(figsize=(6,5.25),tight_layout=True)
    sc     = ax.scatter(x,y,c=z,linewidths=0,
                        vmin=keywords.get("Z_min",z.min()),
                        vmax=keywords.get("Z_max",z.max()))
    div    = make_axes_locatable(ax)
    fig.colorbar(sc,cax=div.append_axes("right",size="5%",pad=0.05),
                 orientation="vertical",
                 label=keywords.get("Z_label","%s %s" % (Z.name,Z.unit)))
    X_min = keywords.get("X_min",x.min())
    X_max = keywords.get("X_max",x.max())
    Y_min = keywords.get("Y_min",y.min())
    Y_max = keywords.get("Y_max",y.max())
    ax.set_xlim(X_min,X_max)
    ax.set_ylim(Y_min,Y_max)
    ax.set_xlabel(keywords.get("X_label","%s %s" % (X.name,X.unit)))
    ax.set_ylabel(keywords.get("Y_label","%s %s" % (Y.name,Y.unit)))
    #ax.grid()
    fig.savefig(keywords.get("filename","whittaker.png"))
    plt.close()

    
