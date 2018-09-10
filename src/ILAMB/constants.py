from numpy import asarray,ones,copy as npcopy
from matplotlib.colors import from_levels_and_colors
from Regions import Regions

__all__ = ['spm','mph','hpd','mpy','dpy_noleap','dpy_gregorian','dpy_360','dpm_noleap','dpm_gregorian','dpm_360','g_per_Pg','g_per_kg','Ar_molar_mass','C_molar_mass','N_molar_mass','O_molar_mass','CO2_molar_mass','dry_air_molar_mass','dry_air_mass','dry_air_moles','co2_g_per_ppm','co2_ppm_per_kg','co2_ppm_per_C_Pg','regions','NCARclrs','NCARcmap','NCARnorm','region_names','dpy','mid_months','spd','spy']

# Time constants
spm              = 60.     # seconds per minute
mph              = 60.     # minutes per hour
hpd              = 24.     # hours per day
spd              = spm*mph*hpd
spy              = spd*365.
mpy              = 12.     # months per year
dpy_noleap       = 365.0   # days per year (for no leap year calendars)
dpy_gregorian    = 365.25  # days per year
dpy_360          = 360.0   # days per year (for 30 days/month)
dpm_noleap       = asarray([31,28,31,30,31,30,31,31,30,31,30,31],dtype='float') # days per month
dpm_gregorian    = npcopy(dpm_noleap) ; dpm_gregorian[1] = dpm_gregorian[1] + 0.25
dpm_360          = ones(int(mpy))*30.
mid_months       = asarray([15.5,45.,74.5,105.,135.5,166.,196.5,227.5,258.,288.5,319.,349.5],dtype='float')
lbl_months       = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
bnd_months       = asarray([0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365],dtype='int')

dpy = {"noleap"    : dpy_noleap,
       "365_day"   : dpy_noleap,
       "360_day"   : dpy_360,
       "gregorian" : dpy_gregorian, 
       "proleptic_gregorian" : dpy_gregorian} 

# Mass unit conversions
g_per_Pg         = 1e+15   # grams per Pg
g_per_kg         = 1e+3    # grams per kg

# Chemical constants
Ar_molar_mass    = 39.948  # grams per mole
C_molar_mass     = 12.0107 # grams per mole
N_molar_mass     = 14.0067 # grams per mole
O_molar_mass     = 15.9994 # grams per mole
CO2_molar_mass   = C_molar_mass + 2. * O_molar_mass # grams per mole

# Atmospheric constants
dry_air_molar_mass = 0.78084*2.*N_molar_mass + 0.20946*2.*O_molar_mass + 0.00934*Ar_molar_mass + 0.00039445*CO2_molar_mass # grams per mole
dry_air_mass       = 5.1352e+21 # grams
dry_air_moles      = dry_air_mass / dry_air_molar_mass
co2_g_per_ppm      = dry_air_moles * CO2_molar_mass / 1.e+6
co2_ppm_per_kg     = g_per_kg / co2_g_per_ppm
co2_ppm_per_C_Pg   = g_per_Pg / co2_g_per_ppm * CO2_molar_mass/C_molar_mass

# Earth constants
earth_rad = 6.371e6 # meters


NCARclrs = asarray([[93,0,135],
                    [196,0,43],
                    [255,35,0],
                    [255,140,0],
                    [255,207,0],
                    [248,255,0],
                    [97,210,0],
                    [0,197,56],
                    [0,242,211],
                    [0,144,255],
                    [0,0,255]],dtype=float)/255.

# Spatial plots and their default options
space_opts = {}
space_opts["timeint"] = { "name"      :"Temporally integrated period mean",
                          "cmap"      :"choose",
                          "sym"       :False,
                          "ticks"     :None,
                          "ticklabels":None,
                          "label"     :"unit",
                          "section"   :"Temporally integrated period mean",
                          "pattern"   :"MNAME_RNAME_timeint.png",
                          "sidelbl"   :"MODEL MEAN",
                          "haslegend" :True }

space_opts["timeintremap"] = { "name"      :"Temporally integrated remapped period mean",
                               "cmap"      :"choose",
                               "sym"       :False,
                               "ticks"     :None,
                               "ticklabels":None,
                               "label"     :"unit",
                               "section"   :"Temporally integrated period mean",
                               "pattern"   :"MNAME_RNAME_timeintremap.png",
                               "sidelbl"   :"MAPPED MODEL MEAN",
                               "haslegend" :True }

space_opts["bias"]    = { "name"      :"Temporally integrated period mean bias",
                          "cmap"      :"bias",
                          "sym"       :True,
                          "ticks"     :None,
                          "ticklabels":None,
                          "label"     :"unit" ,
                          "section"   :"Temporally integrated period mean",
                          "pattern"   :"MNAME_RNAME_bias.png",
                          "sidelbl"   :"BIAS",
                          "haslegend" :True }

space_opts["biasscore"] = { "name"      :"Temporally integrated period mean bias score",
                            "cmap"      :"RdYlGn",
                            "sym"       :False,
                            "ticks"     :None,
                            "ticklabels":None,
                            "label"     :"unit" ,
                            "section"   :"Temporally integrated period mean",
                            "pattern"   :"MNAME_RNAME_biasscore.png",
                            "sidelbl"   :"BIAS SCORE",
                            "haslegend" :True }

space_opts["rmse"]    = { "name"      :"Temporally integrated period mean rmse",
                          "cmap"      :"YlOrRd",
                          "sym"       :False,
                          "ticks"     :None,
                          "ticklabels":None,
                          "label"     :"unit" ,
                          "section"   :"Temporally integrated period mean",
                          "pattern"   :"MNAME_RNAME_rmse.png",
                          "sidelbl"   :"RMSE",
                          "haslegend" :True }

space_opts["rmsescore"] = { "name"      :"Temporally integrated period mean rmse score",
                            "cmap"      :"RdYlGn",
                            "sym"       :False,
                            "ticks"     :None,
                            "ticklabels":None,
                            "label"     :"unit" ,
                            "section"   :"Temporally integrated period mean",
                            "pattern"   :"MNAME_RNAME_rmsescore.png",
                            "sidelbl"   :"RMSE SCORE",
                            "haslegend" :True }

space_opts["iav"]    = { "name"      :"Interannual variability",
                          "cmap"      :"Reds",
                          "sym"       :False,
                          "ticks"     :None,
                          "ticklabels":None,
                          "label"     :"unit" ,
                          "section"   :"Temporally integrated period mean",
                          "pattern"   :"MNAME_RNAME_iav.png",
                          "sidelbl"   :"MODEL INTERANNUAL VARIABILITY",
                          "haslegend" :True }

space_opts["iavscore"] = { "name"      :"Interannual variability score",
                           "cmap"      :"RdYlGn",
                           "sym"       :False,
                           "ticks"     :None,
                           "ticklabels":None,
                           "label"     :"unit" ,
                           "section"   :"Temporally integrated period mean",
                           "pattern"   :"MNAME_RNAME_iavscore.png",
                           "sidelbl"   :"INTERANNUAL VARIABILITY SCORE",
                           "haslegend" :True }

space_opts["shift"]   = { "name"      :"Temporally integrated mean phase shift",
                          "cmap"      :"PRGn",
                          "sym"       :True,
                          "ticks"     :None,
                          "ticklabels":None,
                          "label"     :"unit" ,
                          "section"   :"Temporally integrated period mean",
                          "pattern"   :"MNAME_RNAME_shift.png",
                          "sidelbl"   :"DIFFERENCE IN MAX MONTH",
                          "haslegend" :True }

space_opts["shiftscore"] = { "name"      :"Temporally integrated mean phase shift score",
                             "cmap"      :"RdYlGn",
                             "sym"       :False,
                             "ticks"     :None,
                             "ticklabels":None,
                             "label"     :"unit" ,
                             "section"   :"Temporally integrated period mean",
                             "pattern"   :"MNAME_RNAME_shiftscore.png",
                             "sidelbl"   :"SEASONAL CYCLE SCORE",
                             "haslegend" :True }

space_opts["phase"]   = { "name"      :"Temporally integrated period mean max month",
                          "cmap"      :"jet",
                          "sym"       :False,
                          "ticks"     :mid_months,
                          "ticklabels":lbl_months,
                          "label"     :"month",
                          "section"   :"Temporally integrated period mean",
                          "pattern"   :"MNAME_RNAME_phase.png",
                          "sidelbl"   :"MODEL MAX MONTH",
                          "haslegend" :True  }


time_opts = {}
time_opts["spaceint"] = { "name"       : "Spatially integrated regional mean",
                          "section"    : "Spatially integrated regional mean",
                          "haslegend"  : False,
                          "pattern"    : "MNAME_RNAME_spaceint.png",
                          "sidelbl"    : "REGIONAL MEAN",
                          "ticks"      : None,
                          "ticklabels" : None,
                          "ylabel"     : "unit"}

time_opts["accumulate"] = { "name"       : "Accumulated mean",
                            "section"    : "Spatially integrated regional mean",
                            "haslegend"  : False,
                            "pattern"    : "MNAME_RNAME_accumulate.png",
                            "sidelbl"    : "ACCUMULATION",
                            "ticks"      : None,
                            "ticklabels" : None,
                            "ylabel"     : "unit"}

time_opts["cycle"]    = { "name"       : "Spatially integrated regional mean cycle",
                          "section"    : "Spatially integrated regional mean",
                          "haslegend"  : False,
                          "pattern"    : "MNAME_RNAME_cycle.png",
                          "sidelbl"    : "ANNUAL CYCLE",
                          "ticks"      : mid_months/365.+1850.,
                          "ticklabels" : lbl_months,
                          "ylabel"     : "unit"}

time_opts["dtcycle"]  = { "name"       : "Spatially integrated regional mean detrended cycle",
                          "section"    : "Spatially integrated regional mean",
                          "haslegend"  : False,
                          "pattern"    : "MNAME_RNAME_dtcycle.png",
                          "sidelbl"    : "MONTHLY ANOMALY",
                          "ticks"      : mid_months/365.+1850.,
                          "ticklabels" : lbl_months,
                          "ylabel"     : "unit"}
