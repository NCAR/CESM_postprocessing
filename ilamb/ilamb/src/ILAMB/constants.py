from numpy import asarray,ones,copy as npcopy
from matplotlib.colors import from_levels_and_colors

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

regions = {}
regions["global"]       = ((-89.75, 89.75),(-179.75, 179.75))
regions["bona"]         = (( 49.75, 79.75),(-170.25,- 60.25))
regions["tena"]         = (( 30.25, 49.75),(-125.25,- 66.25))
regions["ceam"]         = ((  9.75, 30.25),(-115.25,- 80.25))
regions["nhsa"]         = ((  0.25, 12.75),(- 80.25,- 50.25))
regions["shsa"]         = ((-59.75,  0.25),(- 80.25,- 40.25))
regions["euro"]         = (( 35.25, 70.25),(- 10.25,  30.25))
regions["mide"]         = (( 20.25, 40.25),(- 10.25,  60.25))
regions["nhaf"]         = ((  0.25, 20.25),(- 20.25,  45.25))
regions["shaf"]         = ((-34.75,  0.25),(  10.25,  45.25))
regions["boas"]         = (( 54.75, 70.25),(  30.25, 179.75))
regions["ceas"]         = (( 30.25, 54.75),(  30.25, 142.58))
regions["seas"]         = ((  5.25, 30.25),(  65.25, 120.25))
regions["eqas"]         = ((-10.25, 10.25),(  99.75, 150.25))
regions["aust"]         = ((-41.25,-10.50),( 112.00, 154.00))
regions["amazon"]       = ((-12.25,  6.75),(- 75.25,- 50.25))
regions["alaska"]       = (( 50.25, 75.25),(-170.25,-130.25))
regions["us-cornbelt"]  = (( 33.00, 55.00),(-116.00,- 80.00))
regions["arctic"]       = (( 60.00, 90.00),(-179.75, 179.75))

region_names = {"global"     : "Globe",
                "bona"       : "Boreal North America",
                "tena"       : "Temperate North America",
                "ceam"       : "Central America",
                "nhsa"       : "Northern Hemisphere South America",
                "shsa"       : "Southern Hemisphere South America",
                "euro"       : "Europe",
                "mide"       : "Middle East",
                "nhaf"       : "Northern Hemisphere Africa",
                "shaf"       : "Southern Hemisphere Africa",
                "boas"       : "Boreal Asia",
                "ceas"       : "Central Asia",
                "seas"       : "Southeast Asia",
                "eqas"       : "Equatorial Asia",
                "aust"       : "Australia",
                "amazon"     : "Amazon",
                "alaska"     : "Alaska",
                "us-cornbelt": "US Cornbelt",
                "arctic"     : "Arctic"
}
# Make sure we have a long name for each region defined
for key in regions.keys(): assert key in region_names.keys()

four_code_regions = []
for key in regions.keys():
    if len(key) == 4 or key == "global": four_code_regions.append(key)
    
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

space_opts["bias"]    = { "name"      :"Temporally integrated period mean bias",
                          "cmap"      :"seismic",
                          "sym"       :True,
                          "ticks"     :None,
                          "ticklabels":None,
                          "label"     :"unit" ,
                          "section"   :"Temporally integrated period mean",
                          "pattern"   :"MNAME_RNAME_bias.png",
                          "sidelbl"   :"BIAS",
                          "haslegend" :True }

space_opts["shift"]   = { "name"      :"Temporally integrated mean phase shift",
                          "cmap"      :"PRGn",
                          "sym"       :True,
                          "ticks"     :None,
                          "ticklabels":None,
                          "label"     :"d" ,
                          "section"   :"Temporally integrated period mean",
                          "pattern"   :"MNAME_RNAME_shift.png",
                          "sidelbl"   :"SHIFT",
                          "haslegend" :True }

space_opts["phase"]   = { "name"      :"Temporally integrated period mean max month",
                          "cmap"      :"jet",
                          "sym"       :False,
                          "ticks"     :mid_months,
                          "ticklabels":lbl_months,
                          "label"     :" ",
                          "section"   :"Temporally integrated period mean",
                          "pattern"   :"MNAME_RNAME_phase.png",
                          "sidelbl"   :"MODEL MAX MONTH",
                          "haslegend" :True  }


time_opts = {}
time_opts["spaceint"] = { "section"    : "Spatially integrated regional mean",
                          "haslegend"  : False,
                          "pattern"    : "MNAME_RNAME_spaceint.png",
                          "sidelbl"    : "MEAN",
                          "ticks"      : None,
                          "ticklabels" : None,
                          "ylabel"     : "unit"}

time_opts["accumulate"] = { "section"    : "Spatially integrated regional mean",
                          "haslegend"  : False,
                          "pattern"    : "MNAME_RNAME_accumulate.png",
                          "sidelbl"    : "ACCUMULATION",
                          "ticks"      : None,
                          "ticklabels" : None,
                          "ylabel"     : "unit"}

time_opts["cycle"]    = { "section"    : "Spatially integrated regional mean",
                          "haslegend"  : False,
                          "pattern"    : "MNAME_RNAME_cycle.png",
                          "sidelbl"    : "CYCLE",
                          "ticks"      : mid_months/365.+1850.,
                          "ticklabels" : lbl_months,
                          "ylabel"     : "unit"}

