from __future__ import print_function

import sys

if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

import traceback
import os
import shutil
import jinja2

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from atm_diags_plot_bc import AtmosphereDiagnosticPlot

class Set12(AtmosphereDiagnosticPlot):
    """DIAG Set 12 - Vertical profiles 
    """

    def __init__(self,env):
        super(Set12, self).__init__()

        # Derive all of the plot names
        suf = '.'+env['p_type'] 
        pref = 'set12_'

        # Station Information 
        self.stations= {"Ascension_Island":        {'id':0,  'name':'ascension_island'},
			"Diego_Garcia":            {'id':1,  'name':'diego_garcia'},
			"Truk_Island":             {'id':2,  'name':'truk_island'},
			"Western_Europe":          {'id':3,  'name':'western_europe'},
			"Ethiopia":                {'id':4,  'name':'ethiopia'},
			"Resolute_Canada":         {'id':5,  'name':'resolute_canada'},
			"Western_Desert_Australia":{'id':6,  'name':'w_desert_australia'}, 
			"Great_Plains_USA":	   {'id':7,  'name':'great_plains_usa'},
			"Central_India":	   {'id':8,  'name':'central_india'},
			"Marshall_Islands":	   {'id':9,  'name':'marshall_islands'},
			"Easter_Island":	   {'id':10, 'name':'easter_island'},
			"McMurdo_Antarctica":	   {'id':11, 'name':'mcmurdo_antarctica'},
			#"SouthPole_Antarctica":    {'id':12, 'name':'N/A'},
			"Panama":		   {'id':13, 'name':'panama'},
			"Western_North_Atlantic":  {'id':14, 'name':'w_north_atlantic'},
			"Singapore":		   {'id':15, 'name':'singapore'},
			"Manila":		   {'id':16, 'name':'manila'},
			"Gilbert_Islands":	   {'id':17, 'name':'gilbert_islands'},
			"Hawaii":	  	   {'id':18, 'name':'hawaii'},
			"San_Paulo":		   {'id':19, 'name':'san_paulo_brazil'},
			"Heard_Island": 	   {'id':20, 'name':'heard_island'},
			"Kagoshima_Japan":	   {'id':21, 'name':'kagoshima_japan'},
			"Port_Moresby":	 	   {'id':22, 'name':'port_moresby'},
			"San_Juan_PR":		   {'id':23, 'name':'san_juan_pr'},
			"Western_Alaska": 	   {'id':24, 'name':'western_alaska'},
			"Thule_Greenland":	   {'id':25, 'name':'thule_greenland'},
			"SanFrancisco_CA":	   {'id':26, 'name':'san_francisco_ca'},
			"Denver_CO":		   {'id':27, 'name':'denver_colorado'},
			"London_UK":		   {'id':28, 'name':'london_england'},
			"Crete": 	           {'id':29, 'name':'crete'},
			"Tokyo":		   {'id':30, 'name':'tokyo_japan'},
			"Sydney_Australia":	   {'id':31, 'name':'sydney_australia'},
			"Christchurch_NZ":	   {'id':32, 'name':'christchurch_nz'},
			"Lima_Peru":		   {'id':33, 'name':'lima_peru'},
			"Miami_FL":		   {'id':34, 'name':'miami_florida'},
			"Samoa": 		   {'id':35, 'name':'samoa'},
			"ShipP_GulfofAlaska":	   {'id':36, 'name':'shipP_gulf_alaska'},
			"ShipC_North_Atlantic":	   {'id':37, 'name':'shipC_n_atlantic'},
			"Azores":		   {'id':38, 'name':'azores'},
			"NewYork_USA": 		   {'id':39, 'name':'new_york_usa'},
			"Darwin_Australia":	   {'id':40, 'name':'darwin_australia'},
			"Christmas_Island":	   {'id':41, 'name':'christmas_island'},
			"Cocos_Islands":	   {'id':42, 'name':'cocos_islands'},
			"Midway_Island": 	   {'id':43, 'name':'midway_island'},
			"Raoui_Island":		   {'id':44, 'name':'raoui_island'},
			"Whitehorse_Canada":	   {'id':45, 'name':'whitehorse_canada'},
			"OklahomaCity_OK":	   {'id':46, 'name':'oklahoma_city_ok'},
			"Gibraltor": 		   {'id':47, 'name':'gibraltor'},
			"Mexico_City":		   {'id':48, 'name':'mexico_city'},
			"Recife_Brazil":	   {'id':49, 'name':'recife_brazil'},
			"Nairobi_Kenya":	   {'id':50, 'name':'nairobi_kenya'},
			"New_Delhi_India": 	   {'id':51, 'name':'new_dehli_india'},
			"Madras_India":	 	   {'id':52, 'name':'madras_india'},
			"DaNang_Vietnam":	   {'id':53, 'name':'danang_vietnam'},
			"Yap_Island":		   {'id':54, 'name':'yap_island'},
			"Falkland_Islands":	   {'id':55, 'name':'falkland_islands'}
                  }

        # variables
        variables = ['T','Q','H']

        # Put plot names together and add to expected plot list
        self.expectedPlots = []
        for name,info in self.stations.iteritems():
            for var in variables:
                self.expectedPlots.append(pref+name+'_'+var+suf)

        # Set plot class description variables
        self._name = 'DIAG Set 12 - Vertical profiles'
        self._shortname = 'SET12'
        self._template_file = 'set12.tmpl'
        self.ncl_scripts = []
        self.ncl_scripts = ['profiles.ncl']
        self.plot_env = env.copy() 

    def check_prerequisites(self, env):
        # Set plot specific variables
        self.plot_env['TEST_CASE'] = env['test_path_climo']+'/'+env['test_casename']+'.'+env['test_modelstream']+'.'
        if 'OBS' in env['CNTL']:
            self.plot_env['STD_CASE'] = 'NONE'
        else:
            self.plot_env['STD_CASE'] = env['cntl_path_climo']+'/'+env['cntl_casename']+'.'+env['cntl_modelstream']+'.'
        
        # Create the station id text file that will indicate which stations to create plots for
        station_file = open(env['test_path_diag']+'station_ids','w')
        for station,info in self.stations.iteritems(): 
            if env[info['name']] == 'True':
                station_file.write(str(info['id'])+'\n')
        station_file.close()
        
