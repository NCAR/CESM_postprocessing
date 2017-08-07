from Confrontation import Confrontation
from ConfNBP import ConfNBP
from ConfTWSA import ConfTWSA
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
        self.bgcolor             = None
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
            s = "%s%s %d %.2f%%" % ("   "*(self.getDepth()-1),name,weight,100*self.overall_weight)
        else:
            s = "%s%s %f" % ("   "*(self.getDepth()-1),name,weight)
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


ConfrontationTypes = { None      : Confrontation,
                       "ConfNBP" : ConfNBP,
                       "ConfTWSA": ConfTWSA}

class Scoreboard():
    """
    A class for managing confrontations
    """
    def __init__(self,filename,regions=["global"],verbose=False,master=True,build_dir="./_build"):
        
        if not os.environ.has_key('ILAMB_ROOT'):
            raise ValueError("You must set the environment variable 'ILAMB_ROOT'")
        self.build_dir = build_dir
        
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
                node.source = "%s/%s" % (os.environ["ILAMB_ROOT"],node.source)
                node.confrontation = Constructor(**(node.__dict__))
                
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
                path   = "%s/%s" % (parent.name.replace(" ",""),path)
                parent = parent.parent
            path = "%s/%s" % (self.build_dir,path)
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
    <div data-role="page" id="page1">
      <div data-role="header" data-position="fixed" data-tap-toggle="false">
	<h1>ILAMB Benchmark Results</h1>
	<div data-role="navbar">
	  <ul>
	    <li><a href="#page1" class="ui-btn-active ui-state-persist">Overview</a></li>
	    <li><a href="#page2">Results Table</a></li>
	  </ul>
	</div>
      </div>
      <div data-role="main" class="ui-content">
	<img class="displayed" src="./overview.png"></img>
      </div>
      <div data-role="footer">
	<h1> </h1>
      </div>
    </div>"""

        html += """
    <div data-role="page" id="page2">
      <div data-role="header" data-position="fixed" data-tap-toggle="false">
	<h1>ILAMB Benchmark Results</h1>
	<div data-role="navbar">
	  <ul>
	    <li><a href="#page1">Overview</a></li>
	    <li><a href="#page2" class="ui-btn-active ui-state-persist">Results Table</a></li>
	  </ul>
	</div>
      </div>

      <div data-role="main" class="ui-content">
	<table data-role="table" data-mode="columntoggle" class="ui-responsive ui-shadow" id="myTable">
	  <thead>
	    <tr>
              <th style="width:300px"> </th>"""
        for m in M:
            html += """
              <th style="width:80px" data-priority="1">%s</th>""" % m.name
        html += """
              <th style="width:20px"></th>
	    </tr>
	  </thead>
          <tbody>"""
        
        for tree in self.tree.children: html += GenerateTable(tree,M,self)
        html += """
          </tbody>
        </table>
      </div>
      <div data-role="footer">
        <h1> </h1>
      </div>
    </div>

</body>
</html>"""
        file("%s/%s" % (self.build_dir,filename),"w").write(html)
        
    def createBarCharts(self,M):
        html = GenerateBarCharts(self.tree,M)

    def createSummaryFigure(self,M):
        GenerateSummaryFigure(self.tree,M,self.build_dir)

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
    def _genHTML(node):
        global global_html
        global global_table_color
        ccolor = DarkenRowColor(global_table_color,fraction=0.95)
        if node.isLeaf():
            weight = np.round(100.0*node.normalize_weight,1)
            if node.confrontation is None:
                global_html += """
      <tr class="child" bgcolor="%s">
        <td>&nbsp;&nbsp;&nbsp;%s&nbsp;(%.1f%%)</td>""" % (ccolor,node.name,weight)
                for m in global_model_list: global_html += '\n        <td>~</td>'
            else:                
                c = node.confrontation
                global_html += """
      <tr class="child" bgcolor="%s">
        <td>&nbsp;&nbsp;&nbsp;<a href="%s/%s.html" rel="external" target="_blank">%s</a>&nbsp;(%.1f%%)</td>""" % (ccolor,
                                                                                                                  c.output_path.replace(build_dir,"").lstrip("/"),
                                                                                                                  c.name,c.name,weight)
                try:
                    for ind in range(node.score.size):
                        if node.score.mask[ind]:
                            global_html += '\n        <td>~</td>'
                        else:
                            global_html += '\n        <td>%.2f</td>' % (node.score[ind])
                except:
                    for ind in range(len(global_model_list)):
                        global_html += '\n        <td>~</td>'
            global_html += """
        <td></td>
      </tr>"""
        else:
            global_html += """
      <tr class="parent" bgcolor="%s">
        <td>%s</td>""" % (global_table_color,node.name)
            for ind,m in enumerate(global_model_list):
                try:
                    if node.score.mask[ind]: raise ValueError()
                    global_html += '\n        <td>%.2f</td>' % (node.score[ind])
                except:
                    global_html += '\n        <td>~</td>' 
            global_html += """
        <td><div class="arrow"></div></td>
      </tr>"""
    TraversePreorder(tree,_genHTML)
    
def GenerateTable(tree,M,S):
    global global_html
    global global_model_list
    global global_table_color
    CompositeScores(tree,M)
    global_model_list = M
    global_table_color = tree.bgcolor
    global_html = ""
    for cat in tree.children: BuildHTMLTable(cat,M,S.build_dir)
    return global_html

"""
def GenerateBarCharts(tree,M):
    return
    table = []
    row   = [m.name for m in M] 
    row.insert(0,"Variables")
    table.append(row)
    for cat in tree.children:
        for var in cat.children:
            row = [var.name]
            try:
                for i in range(var.score.size): row.append(var.score[i])
            except:
                for i in range(len(M)): row.append(0)
            table.append(row)
    from jinja2 import FileSystemLoader,Environment
    templateLoader = FileSystemLoader(searchpath="./")
    templateEnv    = Environment(loader=templateLoader)
    template       = templateEnv.get_template("tmp.html")
    templateVars   = { "table" : table }
    outputText     = template.render( templateVars )
    file('gen.html',"w").write(outputText)
"""

def GenerateSummaryFigure(tree,M,build_dir):

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

    BenchmarkSummaryFigure(models,variables,data,"%s/overview.png" % build_dir,vcolor=vcolors)
