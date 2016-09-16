# Create time-series plots of global and regional particulate fluxes.
# Created by Ivan Lima on Fri Sep 23 10:53:35 EDT 2011

# Reads input file 
#   tseries.profile.'case'.global.nc
#   tseries.'case'.'rsname'.nc
#   tseries.profile.'case'.'rsname'.nc

# Creates output files 
#   tseries_region_'varname'.png


import numpy as N
import os, sys, Nio
import matplotlib.pyplot as pl
from mpl_utils import *
from ccsm_utils import read_BEC_region_mask, read_BEC_region_mask_popdiag
from scipy import ndimage

case = raw_input('Enter case: \n')
yrstart = int(raw_input('Enter start year: \n'))
yrend = int(raw_input('Enter end year: \n'))
POPDIAGPY = raw_input('Enter TRUE or FALSE: \n')
yroffset = int(raw_input('Enter year offset: \n'))
WORKDIRPY = raw_input('Enter WORKDIR: \n')
mgrid = raw_input('Enter model grid/resolution: \n')
ODATADIR = raw_input('Enter directory of observations: \n')

nyrs = 1 # number of years for running mean

# directory with input processed files
if POPDIAGPY == 'TRUE':
   indir = WORKDIRPY
else:
   indir = '/bonaire/data2/ivan/ccsm_output/%s'%case 

variables = {
    'POC_FLUX_IN' : {
        'label' : r'POC Flux',
        'units' : r'Pg C y$^{-1}$',
        'cfac'  : 1.e-2 * 1.e-3 * spd * 365 # mmol/m^3*cm/sec -> mol/m^2/year
        },
    'CaCO3_FLUX_IN' : {
        'label' : r'CaCO$_3$ Flux',
        'units' : r'Pg C y$^{-1}$',
        'cfac'  : 1.e-2 * 1.e-3 * spd * 365 # mmol/m^3*cm/sec -> mol/m^2/year
        },
    'SiO2_FLUX_IN' : {
        'label' : r'SiO$_3$ Flux',
        'units' : r'Tmol Si y$^{-1}$',
        'cfac'  : 1.e-2 * 1.e-3 * spd * 365 # mmol/m^3*cm/sec -> mol/m^2/year
        },
    #'dust_FLUX_IN' : {
    #    'label' : r'Dust Flux',
    #    'units' : r'Tg y$^{-1}$',
    #    'cfac'  : 1.e+4 * spd * 365 # g/cm^2/sec to g/m^2/year
    #    },
    #'P_iron_FLUX_IN' : {
    #    'label' : r'P Iron Flux',
    #    'units' : r'Tmol Fe y$^{-1}$',
    #    'cfac'  : 1.e-2 * 1.e-3 * spd * 365 # mmol/m^3*cm/sec -> mol/m^2/year
    #    }
    }


if POPDIAGPY == 'TRUE':
   rmask, nreg, rlname, rsname = read_BEC_region_mask_popdiag(mgrid)
elif 'x1' in case:
   rmask, nreg, rlname, rsname = read_BEC_region_mask('gx1v6')
elif 'x3' in case:
   rmask, nreg, rlname, rsname = read_BEC_region_mask('gx3v5')
else:
   print('Unknown grid type')
   sys.exit()

rsname = ['global'] + rsname
rlname = ['Global'] + rlname
nreg = len(rsname)

# get particulate flux variables
if POPDIAGPY == 'TRUE':
  infile = os.path.join(indir,'tseries.profile.%04d-%04d.%s.global.nc'%(yrstart,yrend,case))
else:
  infile = os.path.join(indir,'tseries.profile.%s.global.nc'%case)
fpin     = Nio.open_file(infile,'r')
ntime    = fpin.dimensions['time']
nz       = fpin.dimensions['z_t']
days     = fpin.variables['time'][:]
zw       = fpin.variables['z_w'][:] / 100. # cn -> m
vars_all = [varname for varname in fpin.variables if '_FLUX_IN' in varname]
fpin.close()

if POPDIAGPY == 'TRUE':
  year = yroffset + days/365.
else:
  year = days/365. - 181 + 1948

depth = 100 # fluxes at 100m
zind = N.int(N.searchsorted(zw,depth))

# use only variables that are in dictionary
varlist  = [varname for varname in vars_all if varname in variables]
for varname in varlist:
    vars()[varname] = N.ones((nreg,ntime),dtype=N.float) * 1.e+20
    variables[varname]['label'] = '%s at %.0f m'%(
            variables[varname]['label'],depth)

area = N.ones((nreg,),dtype = N.float) * 1.e+20

# read global and regional grid areas
for r in range(nreg):
    if POPDIAGPY == 'TRUE':
       infile = os.path.join(indir,'tseries.%04d-%04d.%s.%s.nc'%(yrstart,yrend,case,rsname[r]))
    else:
       infile = os.path.join(indir,'tseries.%s.%s.nc'%(case,rsname[r]))
    fpin    = Nio.open_file(infile,'r')
    area[r] = fpin.variables['TAREA'].get_value().item() * 1.e-4 # cm2->m2
    fpin.close()

# read particulate fluxes at 100 m
for r in range(nreg):
    if POPDIAGPY == 'TRUE':
       infile = os.path.join(indir,'tseries.profile.%04d-%04d.%s.%s.nc'%(yrstart,yrend,case,rsname[r]))
    else:
       infile = os.path.join(indir,'tseries.profile.%s.%s.nc'%(case,rsname[r]))
    print('reading %s'%os.path.basename(infile))
    fpin       = Nio.open_file(infile,'r')
    for varname in varlist:
        vars()[varname][r,:] = fpin.variables[varname][:,zind]

    fpin.close()

for varname in varlist:
    # do some basic unit conversions
    if 'cfac' in variables[varname]:
        vars()[varname] = vars()[varname] * variables[varname]['cfac']

    # convert from mol/m^2/year to Peta g C/year
    if varname in ['POC_FLUX_IN','CaCO3_FLUX_IN']:
        vars()[varname] = (vars()[varname] * area[...,N.newaxis]
                * 12.01 * 1.e-15)

    # convert from (mol or g)/m^2/year to Tera (mol or g)/year
    if varname in ['dust_FLUX_IN','SiO2_FLUX_IN','P_iron_FLUX_IN']:
        vars()[varname] = vars()[varname] * area[...,N.newaxis] * 1.e-12

    # compute 12-month running averages
    for r in range(nreg):
        #vars()[varname][r,:] = ndimage.uniform_filter1d(
        #        vars()[varname][r,:],12,mode='nearest')
        vars()[varname][r,:] = ndimage.gaussian_filter1d(
                vars()[varname][r,:],7,mode='nearest')

# create directory for plots if necessary
if POPDIAGPY == 'TRUE':
  outdir = WORKDIRPY
else:
  outdir = '/fiji/home/ivan/www/ccsm_log/cases/%s/plots'%case

if (not os.path.isdir(outdir)):
    os.makedirs(outdir)

color_list = pl.cm.gist_ncar(range(0,256+18,18))[:,0:3].tolist()

# Create plots

for varname in sorted(varlist):
    outfile = os.path.join(outdir,'tseries_region_%s.png'%(varname))
    print 'plotting', outfile
    fig = pl.figure()
    ax  = fig.add_subplot(111)
    y = vars()[varname][:,12:-12]
    varlabel = '%s (%s)'%(variables[varname]['label'],
            variables[varname]['units'])
    tlist = []
    for r in range(nreg):
        line, = ax.plot(year[12:-12],y[r,:],color=color_list[r])
        text  = rsname[r].replace('_',' ')
        tlist.append(ax.text(year.max(),y[r,-12],text,
            horizontalalignment='left',verticalalignment='center',
            color=color_list[r],fontsize=8))

    adjust_spines(ax)
    ax.set(xlim=(N.floor(year.min()),N.ceil(year.max())),xlabel='time',
            ylim=(y.min(),y.max()), ylabel=varlabel)
    top_labels(ax,case.replace('_','\_'),'','%d-year moving avg'%(nyrs))
    #fig.savefig(outfile,dpi=125,bbox_inches='tight',pad_inches=1)
    extent = ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted())
    fig.savefig(outfile,dpi=100,bbox_inches=extent.expanded(1.4,1.3))
    pl.close(fig)

