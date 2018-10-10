from Confrontation import Confrontation
from ConfNBP import ConfNBP
from ConfTWSA import ConfTWSA
from ConfRunoff import ConfRunoff
from ConfEvapFraction import ConfEvapFraction
from ConfIOMB import ConfIOMB
from ConfDiurnal import ConfDiurnal
from ConfPermafrost import ConfPermafrost
import os,re
from netCDF4 import Dataset
import numpy as np
from Post import BenchmarkSummaryFigure
from ilamblib import MisplacedData

global_print_node_string  = ""
global_confrontation_list = []
global_model_list         = []

class Node(object):
    
    def __init__(self, name):
        self.name                = name
        self.children            = []
        self.parent              = None
        self.source              = None
        self.cmap                = None
        self.variable            = None
        self.alternate_vars      = None
        self.derived             = None
        self.land                = False
        self.confrontation       = None
        self.output_path         = None
        self.bgcolor             = "#EDEDED"
        self.table_unit          = None
        self.plot_unit           = None
        self.space_mean          = True
        self.relationships       = None
        self.ctype               = None
        self.regions             = None
        self.skip_rmse           = False
        self.skip_iav            = False
        self.mass_weighting      = False
        self.weight              = 1    # if a dataset has no weight specified, it is implicitly 1
        self.sum_weight_children = 0    # what is the sum of the weights of my children?
        self.normalize_weight    = 0    # my weight relative to my siblings
        self.overall_weight      = 0    # the multiplication my normalized weight by all my parents' normalized weights
        self.score               = 0    # placeholder
        
    def __str__(self):
        if self.parent is None: return ""
        name   = self.name if self.name is not None else ""
        weight = self.weight
        if self.isLeaf():
            s = "%s%s %s" % ("   "*(self.getDepth()-1),name,self.score) 
        else:
            s = "%s%s %s" % ("   "*(self.getDepth()-1),name,self.score)
        return s

    def isLeaf(self):
        if len(self.children) == 0: return True
        return False
    
    def addChild(self, node):
        node.parent = self
        self.children.append(node)

    def getDepth(self):
        depth  = 0
        parent = self.parent
        while parent is not None:
            depth += 1
            parent = parent.parent
        return depth

def TraversePostorder(node,visit):
    for child in node.children: TraversePostorder(child,visit)
    visit(node)
    
def TraversePreorder(node,visit):
    visit(node)
    for child in node.children: TraversePreorder(child,visit)

def PrintNode(node):
    global global_print_node_string
    global_print_node_string += "%s\n" % (node)
    
def ConvertTypes(node):
    def _to_bool(a):
        if type(a) is type(True): return a
        if type(a) is type("")  : return a.lower() == "true"
    node.weight     = float(node.weight)
    node.land       = _to_bool(node.land)
    node.space_mean = _to_bool(node.space_mean)
    if node.regions        is not None: node.regions        = node.regions.split(",")
    if node.relationships  is not None: node.relationships  = node.relationships.split(",")
    if node.alternate_vars is not None:
        node.alternate_vars = node.alternate_vars.split(",")
    else:
        node.alternate_vars = []
        
def SumWeightChildren(node):
    for child in node.children: node.sum_weight_children += child.weight
    
def NormalizeWeights(node):
    if node.parent is not None:
        sumw = 1.
        if node.parent.sum_weight_children > 0: sumw = node.parent.sum_weight_children
        node.normalize_weight = node.weight/sumw

def OverallWeights(node):
    if node.isLeaf():
        node.overall_weight = node.normalize_weight
        parent = node.parent
        while parent.parent is not None:
            node.overall_weight *= parent.normalize_weight
            parent = parent.parent

def InheritVariableNames(node):
    if node.parent             is None: return
    if node.variable           is None:  node.variable       = node.parent.variable
    if node.derived            is None:  node.derived        = node.parent.derived
    if node.cmap               is None:  node.cmap           = node.parent.cmap
    if node.ctype              is None:  node.ctype          = node.parent.ctype
    if node.skip_rmse          is False: node.skip_rmse      = node.parent.skip_rmse
    if node.skip_iav           is False: node.skip_iav       = node.parent.skip_iav 
    if node.mass_weighting     is False: node.mass_weighting = node.parent.mass_weighting
    node.alternate_vars = node.parent.alternate_vars
    
def ParseScoreboardConfigureFile(filename):
    root = Node(None)
    previous_node = root
    current_level = 0
    for line in file(filename).readlines():
        line = line.strip()
        if line.startswith("#"): continue
        m1 = re.search(r"\[h(\d):\s+(.*)\]",line)
        m2 = re.search(r"\[(.*)\]",line)
        m3 = re.search(r"(.*)=(.*)",line)
        if m1:
            level = int(m1.group(1))
            assert level-current_level<=1
            name  = m1.group(2)
            node  = Node(name)
            if   level == current_level:
                previous_node.parent.addChild(node)
            elif level >  current_level:
                previous_node.addChild(node)
                current_level = level
            else:
                addto = root
                for i in range(level-1): addto = addto.children[-1]
                addto.addChild(node)
                current_level = level
            previous_node = node
    
        if not m1 and m2:
            node  = Node(m2.group(1))
            previous_node.addChild(node)

        if m3:
            keyword = m3.group(1).strip()
            value   = m3.group(2).strip().replace('"','')
            #if keyword not in node.__dict__.keys(): continue
            try:
                node.__dict__[keyword] = value
            except:
                pass

    TraversePreorder (root,ConvertTypes)        
    TraversePostorder(root,SumWeightChildren)
    TraversePreorder (root,NormalizeWeights)
    TraversePreorder (root,OverallWeights)
    TraversePostorder(root,InheritVariableNames)
    return root


ConfrontationTypes = { None              : Confrontation,
                       "ConfNBP"         : ConfNBP,
                       "ConfTWSA"        : ConfTWSA,
                       "ConfRunoff"      : ConfRunoff,
                       "ConfEvapFraction": ConfEvapFraction,
                       "ConfIOMB"        : ConfIOMB,
                       "ConfDiurnal"     : ConfDiurnal,
                       "ConfPermafrost"  : ConfPermafrost}

class Scoreboard():
    """
    A class for managing confrontations
    """
    def __init__(self,filename,regions=["global"],verbose=False,master=True,build_dir="./_build",extents=None,rel_only=False):
        
        if not os.environ.has_key('ILAMB_ROOT'):
            raise ValueError("You must set the environment variable 'ILAMB_ROOT'")
        self.build_dir = build_dir
        self.rel_only  = rel_only
        
        if (master and not os.path.isdir(self.build_dir)): os.mkdir(self.build_dir)        

        self.tree = ParseScoreboardConfigureFile(filename)
        max_name_len = 45

        def _initConfrontation(node):
            if not node.isLeaf(): return

            # if the user hasn't set regions, use the globally defined ones
            if node.regions is None: node.regions = regions
            
            # pick the confrontation to use, is it a built-in confrontation?
            if ConfrontationTypes.has_key(node.ctype):
                Constructor = ConfrontationTypes[node.ctype]
            else:
                # try importing the confrontation
                conf = __import__(node.ctype)
                Constructor = conf.__dict__[node.ctype]                    
                
            try:
                if node.cmap is None: node.cmap = "jet"
                node.source = os.path.join(os.environ["ILAMB_ROOT"],node.source)
                node.confrontation = Constructor(**(node.__dict__))
                node.confrontation.extents = extents
                
                if verbose and master: print ("    {0:>%d}\033[92m Initialized\033[0m" % max_name_len).format(node.confrontation.longname)
                
            except MisplacedData:

                if (master and verbose): 
                    longname = node.output_path
                    longname = longname.replace("//","/").replace(self.build_dir,"")
                    if longname[-1] == "/": longname = longname[:-1]
                    longname = "/".join(longname.split("/")[1:])
                    print ("    {0:>%d}\033[91m MisplacedData\033[0m" % max_name_len).format(longname)
                
        def _buildDirectories(node):
            if node.name is None: return
            path   = ""
            parent = node
            while parent.name is not None:
                path   = os.path.join(parent.name.replace(" ",""),path)
                parent = parent.parent
            path = os.path.join(self.build_dir,path)
            if not os.path.isdir(path) and master: os.mkdir(path)
            node.output_path = path

        TraversePreorder(self.tree,_buildDirectories)
        TraversePreorder(self.tree,_initConfrontation)

    def __str__(self):
        global global_print_node_string
        global_print_node_string = ""
        TraversePreorder(self.tree,PrintNode)
        return global_print_node_string

    def list(self):
        def _hasConfrontation(node):
            global global_confrontation_list
            if node.confrontation is not None:
                global_confrontation_list.append(node.confrontation)
        global global_confrontation_list
        global_confrontation_list = []
        TraversePreorder(self.tree,_hasConfrontation)
        return global_confrontation_list
        
    def createHtml(self,M,filename="index.html"):

        # Create html assets
        from pylab import imsave
        arrows = np.zeros((32,16,4))
        for i in range(7):
            arrows[ 4+i,(7-i):(7+i+1),3] = 1
            arrows[27-i,(7-i):(7+i+1),3] = 1
        imsave("%s/arrows.png" % self.build_dir,arrows)

        # Create a tree for relationship scores (hack)
        rel_tree = GenerateRelationshipTree(self,M)
        has_rel  = np.asarray([len(rel.children) for rel in rel_tree.children]).sum() > 0
        nav      = ""
        if has_rel:
            GenerateRelSummaryFigure(rel_tree,M,"%s/overview_rel.png" % self.build_dir,rel_only=self.rel_only)
            nav = """
	    <li><a href="#pageRel">Relationship</a></li>"""
            #global global_print_node_string
            #global_print_node_string = ""
            #TraversePreorder(rel_tree,PrintNode)
            #print global_print_node_string

        from ILAMB.generated_version import version as ilamb_version
        html = r"""
<html>
  <head>
    <title>ILAMB Benchmark Results</title>
    <link rel="stylesheet" href="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css"></link>
    <script src="https://code.jquery.com/jquery-1.11.2.min.js"></script>
    <script>
      $(document).bind('mobileinit',function(){
      $.mobile.changePage.defaults.changeHash = false;
      $.mobile.hashListeningEnabled = false;
      $.mobile.pushStateEnabled = false;
      });
    </script>
    <script src="https://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">  
      $(document).ready(function(){
      function getChildren($row) {
      var children = [];
      while($row.next().hasClass('child')) {
      children.push($row.next());
      $row = $row.next();
      }            
      return children;
      }
      $('.parent').on('click', function() {
      $(this).find(".arrow").toggleClass("up");
      var children = getChildren($(this));
      $.each(children, function() {
      $(this).toggle();
      })
      });
      $('.child').toggle();
      });
    </script>"""
        html += """
    <style>
      div.arrow {
        background:transparent url(arrows.png) no-repeat scroll 0px -16px;
        width:16px;
        height:16px; 
        display:block;
      }
      div.up {
        background-position:0px 0px;
      }
      .child {
      }
      .parent {
        cursor:pointer;
      }
      th {
        border-bottom: 1px solid #d6d6d6;
      }
      img.displayed {
        display: block;
        margin-left: auto;
        margin-right: auto
      }
    </style>"""
        html += """
  </head>

  <body>"""
        
        html += """
    <div data-role="page" id="pageOverview">
      <div data-role="header" data-position="fixed" data-tap-toggle="false">
	<h1>ILAMB Benchmark Results</h1>
	<div data-role="navbar">
	  <ul>
	    <li><a href="#pageOverview" class="ui-btn-active ui-state-persist">Mean State</a></li>%s
	    <li><a href="#pageTable">Results Table</a></li>
	  </ul>
	</div>
      </div>
      <div data-role="main" class="ui-content">
	<img class="displayed" src="./overview.png"></img>
      </div>
      <div data-role="footer">
	<center>ILAMB %s</center>
      </div>
    </div>""" % (nav,ilamb_version)

        if has_rel:
            html += """
    <div data-role="page" id="pageRel">
      <div data-role="header" data-position="fixed" data-tap-toggle="false">
	<h1>ILAMB Benchmark Results</h1>
	<div data-role="navbar">
	  <ul>
	    <li><a href="#pageOverview">Mean State</a></li>
            <li><a href="#pageRel" class="ui-btn-active ui-state-persist">Relationship</a></li>
	    <li><a href="#pageTable">Results Table</a></li>
	  </ul>
	</div>
      </div>
      <div data-role="main" class="ui-content">
	<img class="displayed" src="./overview_rel.png"></img>
      </div>
      <div data-role="footer">
      </div>
    </div>"""
        
        html += """
    <div data-role="page" id="pageTable">
      <div data-role="header" data-position="fixed" data-tap-toggle="false">
	<h1>ILAMB Benchmark Results</h1>
	<div data-role="navbar">
	  <ul>
	    <li><a href="#pageOverview">Mean State</a></li>%s
	    <li><a href="#pageTable" class="ui-btn-active ui-state-persist">Results Table</a></li>
	  </ul>
	</div>
      </div>

      <div data-role="main" class="ui-content">
        <div data-role="collapsible" data-collapsed="false"><h1>Mean State Scores</h1>
	<table data-role="table" data-mode="columntoggle" class="ui-responsive ui-shadow" id="meanTable">
	  <thead>
	    <tr>
              <th> </th>""" % nav
        for m in M:
            html += """
              <th data-priority="1">%s</th>""" % m.name
        html += """
              <th style="width:20px"></th>
	    </tr>
	  </thead>
          <tbody>"""
            
        html += GenerateTable(self.tree,M,self)
        
        html += """
          </tbody>
        </table>
        </div>"""
            
        if has_rel:
            html += """
        <div data-role="collapsible" data-collapsed="false"><h1>Relationship Scores</h1>
	<table data-role="table" data-mode="columntoggle" class="ui-responsive ui-shadow" id="relTable">
	  <thead>
	    <tr>
              <th> </th>"""
            for m in M:
                html += """
              <th data-priority="1">%s</th>""" % m.name
            html += """
              <th style="width:20px"></th>
	    </tr>
	  </thead>
          <tbody>"""
            html += GenerateTable(rel_tree,M,self,composite=False)
            html += """
          </tbody>
        </table>
        </div>"""
        
        html += """
      </div>
      <div data-role="footer"></div>
    </div>

</body>
</html>""" 
        file("%s/%s" % (self.build_dir,filename),"w").write(html)
        
    def createBarCharts(self,M):
        html = GenerateBarCharts(self.tree,M)

    def createSummaryFigure(self,M):
        GenerateSummaryFigure(self.tree,M,"%s/overview.png" % self.build_dir,rel_only=self.rel_only)

    def dumpScores(self,M,filename):
        out = file("%s/%s" % (self.build_dir,filename),"w")
        out.write("Variables,%s\n" % (",".join([m.name for m in M])))
        for cat in self.tree.children:
            for v in cat.children:
                try:
                    out.write("%s,%s\n" % (v.name,','.join([str(s) for s in v.score])))
                except:
                    out.write("%s,%s\n" % (v.name,','.join(["~"]*len(M))))
        out.close()

def CompositeScores(tree,M):
    global global_model_list
    global_model_list = M
    def _loadScores(node):
        if node.isLeaf():
            if node.confrontation is None: return
            data = np.zeros(len(global_model_list))
            mask = np.ones (len(global_model_list),dtype=bool)
            for ind,m in enumerate(global_model_list):
                fname = "%s/%s_%s.nc" % (node.confrontation.output_path,node.confrontation.name,m.name)
                if os.path.isfile(fname):
                    try:
                        dataset = Dataset(fname)
                        grp     = dataset.groups["MeanState"].groups["scalars"]
                    except:
                        continue
                    if grp.variables.has_key("Overall Score global"):
                        data[ind] = grp.variables["Overall Score global"][0]
                        mask[ind] = 0
                    else:
                        data[ind] = -999.
                        mask[ind] = 1
                    node.score = np.ma.masked_array(data,mask=mask)
        else:
            node.score  = 0
            sum_weights = 0
            for child in node.children:
                node.score  += child.score*child.weight
                sum_weights += child.weight
            np.seterr(over='ignore',under='ignore')
            node.score /= sum_weights
            np.seterr(over='raise',under='raise')
    TraversePostorder(tree,_loadScores)

global_html = ""
global_table_color = ""

def DarkenRowColor(clr,fraction=0.9):
    from colorsys import rgb_to_hsv,hsv_to_rgb
    def hex_to_rgb(value):
        value = value.lstrip('#')
        lv  = len(value)
        rgb = tuple(int(value[i:i + lv // 3], 16) for i in range(0, lv, lv // 3))
        rgb = np.asarray(rgb)/255.
        return rgb
    def rgb_to_hex(rgb):
        return '#%02x%02x%02x' % rgb
    rgb = hex_to_rgb(clr)
    hsv = rgb_to_hsv(rgb[0],rgb[1],rgb[2])
    rgb = hsv_to_rgb(hsv[0],hsv[1],fraction*hsv[2])
    rgb = tuple(np.asarray(np.asarray(rgb)*255.,dtype=int))
    return rgb_to_hex(rgb)

def BuildHTMLTable(tree,M,build_dir):
    global global_model_list
    global_model_list = M
    global global_table_color    
    def _genHTML(node):
        global global_html
        global global_table_color
        ccolor = DarkenRowColor(global_table_color,fraction=0.95)

        # setup a html table row
        if node.isLeaf():
            row = '<tr class="child" bgcolor="%s">'  % ccolor
        else:
            row = '<tr class="parent" bgcolor="%s">' % global_table_color

        # first table column
        tab = ''
        if node.isLeaf(): tab = '&nbsp;&nbsp;&nbsp;'
        name = node.name
        if node.confrontation:
            conf = node.confrontation
            if type(conf) == str:
                path = conf.replace(build_dir,"").lstrip("/")
            else:
                path = os.path.join(conf.output_path.replace(build_dir,"").lstrip("/"),conf.name + ".html")
            name = '<a href="%s" rel="external" target="_blank">%s</a>' % (path,node.name)
        if node.isLeaf():
            row += '<td>%s%s&nbsp;(%.1f%%)</td>' % (tab,name,100*node.normalize_weight)
        else:
            row += '<td>%s%s</td>' % (tab,name)

        # populate the rest of the columns
        if type(node.score) != type(np.ma.empty(0)): node.score = np.ma.masked_array(np.zeros(len(global_model_list)),mask=True)
        for i,m in enumerate(global_model_list):
            if not node.score.mask[i]:
                row += '<td>%.2f</td>' % node.score[i]
            else:
                row += '<td>~</td>'

        # end the table row
        row += '<td><div class="arrow"></div></td></tr>'
        global_html += row

    for cat in tree.children:
        global_table_color = cat.bgcolor
        for var in cat.children:
            TraversePreorder(var,_genHTML)
        cat.name += " Summary"
        _genHTML(cat)
        cat.name.replace(" Summary","")
    global_table_color = tree.bgcolor
    tree.name = "Overall Summary"
    _genHTML(tree)
    
def GenerateTable(tree,M,S,composite=True):
    global global_html
    global global_model_list
    if composite: CompositeScores(tree,M)
    global_model_list = M
    global_html = ""
    BuildHTMLTable(tree,M,S.build_dir)
    return global_html

def GenerateSummaryFigure(tree,M,filename,rel_only=False):

    models    = [m.name for m in M]
    variables = []
    vcolors   = []
    for cat in tree.children:
        for var in cat.children:
            variables.append(var.name)
            vcolors.append(cat.bgcolor)
            
    data = np.ma.zeros((len(variables),len(models)))
    row  = -1
    for cat in tree.children:
        for var in cat.children:
            row += 1
            if type(var.score) == float:
                data[row,:] = np.nan
            else:
                data[row,:] = var.score

    BenchmarkSummaryFigure(models,variables,data,filename,vcolor=vcolors,rel_only=rel_only)

def GenerateRelSummaryFigure(S,M,figname,rel_only=False):

    # reorganize the relationship data
    scores  = {}
    counts  = {}
    rows    = []
    vcolors = []
    for h1 in S.children:
        for dep in h1.children:
            dname = dep.name.split("/")[0]
            for ind in dep.children:
                iname = ind.name.split("/")[0]
                key   = "%s/%s" % (dname,iname)
                if scores.has_key(key):
                    scores[key] += ind.score
                    counts[key] += 1.
                else:
                    scores[key]  = np.copy(ind.score)
                    counts[key]  = 1.
                    rows   .append(key)
                    vcolors.append(h1.bgcolor)
    if len(rows) == 0: return
    data = np.ma.zeros((len(rows),len(M)))
    for i,row in enumerate(rows):
        data[i,:] = scores[row] / counts[row]
    BenchmarkSummaryFigure([m.name for m in M],rows,data,figname,rel_only=rel_only,vcolor=vcolors)
    
def GenerateRelationshipTree(S,M):

    # Create a tree which mimics the scoreboard for relationships, but
    # we need
    #
    # root -> category -> datasets -> relationships
    #
    # instead of
    #
    # root -> category -> variable -> datasets
    #    
    rel_tree = Node("root")
    for cat in S.tree.children:
        h1 = Node(cat.name)
        h1.bgcolor = cat.bgcolor
        h1.parent  = rel_tree
        rel_tree.children.append(h1)
        for var in cat.children:
            for data in var.children:
                if data               is None: continue
                if data.relationships is None: continue

                # build tree
                h2 = Node(data.confrontation.longname)
                h1.children.append(h2)
                h2.parent = h1
                h2.score  = np.ma.masked_array(np.zeros(len(M)),mask=True)
                for rel in data.relationships:
                    try:
                        longname = rel.longname
                    except:
                        longname = rel
                    v = Node(longname)
                    h2.children.append(v)
                    v.parent = h2
                    v.score  = np.ma.masked_array(np.zeros(len(M)),mask=True)
                    v.normalize_weight = 1./len(data.relationships)
                    path = data.confrontation.output_path
                    path = os.path.join(path,data.confrontation.name + ".html#Relationships")
                    v.confrontation = path
                    
                # load scores
                for i,m in enumerate(M):
                    fname = os.path.join(data.output_path,"%s_%s.nc" % (data.name,m.name))
                    if not os.path.isfile(fname): continue
                    with Dataset(fname) as dset:
                        grp = dset.groups["Relationships"]["scalars"]
                        for rel,v in zip(data.relationships,h2.children):
                            try:
                                longname = rel.longname
                            except:
                                longname = rel
                            rs  = [key for key in grp.variables.keys() if (longname.split("/")[0] in key and
                                                                           "global"               in key and
                                                                           "RMSE"                 in key)]
                            if len(rs) != 1: continue
                            v.score[i] = grp.variables[rs[0]][...]
                        if "Overall Score global" not in grp.variables.keys(): continue
                        h2.score[i] = grp.variables["Overall Score global"][...]

    return rel_tree

    
