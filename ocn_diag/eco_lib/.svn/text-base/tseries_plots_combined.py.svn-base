# Create time-series plots of global and regional averages and integrals.
# Created by Ivan Lima on Wed Sep 14 11:47:11 EDT 2011

# Reads files: 
#   tseries.'case'.global.nc
#   tseries.'case'.'regname'.nc
#   tseries.'case'.o2_min_vol.'regname'.nc

# Creates files 
#   tseries_region_'varname'.png

import numpy as N
import os, sys, Nio
import matplotlib.pyplot as pl
from res_tseries import *
from mpl_utils import *
from ccsm_utils import read_BEC_region_mask, read_BEC_region_mask_popdiag
from scipy import ndimage

case      = raw_input('Enter case: \n')
yrstart   = int(raw_input('Enter start year: \n'))
yrend     = int(raw_input('Enter end year: \n'))
POPDIAGPY = raw_input('Enter TRUE or FALSE: \n')
yroffset  = int(raw_input('Enter year offset: \n'))
WORKDIRPY = raw_input('Enter WORKDIR: \n')
mgrid     = raw_input('Enter model grid/resolution: \n')
ODATADIR  = raw_input('Enter directory of observations: \n')

nyrs = 1 # number of years for running mean

# Make nyrs a factor of the -12 in the running average

# directory with input processed files
if POPDIAGPY == 'TRUE':
   indir = WORKDIRPY
else:
   indir = '/bonaire/data2/ivan/ccsm_output/%s'%case 

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

# Get type of field average (surface, full depth, upper 150m)

vars_surf, vars_fulldepth, vars_zt150m = [], [], []
if POPDIAGPY == 'TRUE':
   infile = os.path.join(indir,'tseries.%04d-%04d.%s.global.nc'%(yrstart,yrend,case))
else:
   infile = os.path.join(indir,'tseries.%s.global.nc'%case)
fpin   = Nio.open_file(infile,'r')
ntime  = fpin.dimensions['time']
days   = fpin.variables['time'][:]
vars_surf = [varname for varname in sorted(fpin.variables) if
        hasattr(fpin.variables[varname],'coordinates') and
        fpin.variables[varname].coordinates == "TLONG TLAT time"]
vars_fulldepth = [varname for varname in sorted(fpin.variables) if
        hasattr(fpin.variables[varname],'coordinates') and
        fpin.variables[varname].coordinates == "TLONG TLAT z_t time"]
vars_zt150m = [varname for varname in sorted(fpin.variables) if
        hasattr(fpin.variables[varname],'coordinates') and
        fpin.variables[varname].coordinates == "TLONG TLAT z_t_150m time"]
vars_pfluzes = [varname for varname in fpin.variables if '_FLUX_IN' in varname]
fpin.close()

if POPDIAGPY == 'TRUE':
   year = yroffset + days/365.
else:
   year = days/365. - 181 + 1948

# Read global and resional averages into one array per variable

# all variables in the file
vars_all = vars_surf + vars_fulldepth + vars_zt150m

# use only variables that are in dictionary
varlist  = [varname for varname in vars_all if varname in variables]
for varname in varlist:
    vars()[varname] = N.ones((nreg,ntime),dtype=N.float) * 1.e+20

area       = N.ones((nreg,),dtype=N.float) * 1.e+20
vol        = N.ones((nreg,),dtype=N.float) * 1.e+20
vol150m    = N.ones((nreg,),dtype=N.float) * 1.e+20
o2_min_vol = N.ones((nreg,ntime),dtype=N.float) * 1.e+20

# read time-series data

for r in range(nreg):
    if POPDIAGPY == 'TRUE':
       infile = os.path.join(indir,'tseries.%04d-%04d.%s.%s.nc'%(yrstart,yrend,case,rsname[r]))
    else:
       infile = os.path.join(indir,'tseries.%s.%s.nc'%(case,rsname[r]))
    print('reading %s'%os.path.basename(infile))
    fpin       = Nio.open_file(infile,'r')
    area[r]    = fpin.variables['TAREA'].get_value().item() * 1.e-4 # cm2->m2
    vol[r]     = fpin.variables['TVOLUME'].get_value().item() * 1.e-6 # cm3->m3
    vol150m[r] = fpin.variables['TVOLUME_150m'].get_value().item() * 1.e-6
    for varname in varlist:
        vars()[varname][r,:] = fpin.variables[varname][:]

    fpin.close()

for r in range(nreg):
    if POPDIAGPY == 'TRUE':
       infile = os.path.join(indir,'tseries.%04d-%04d.%s.o2_min_vol.%s.nc'%(yrstart,yrend,case,rsname[r]))
    else:
       infile = os.path.join(indir,'tseries.%s.o2_min_vol.%s.nc'%(case,rsname[r]))
    print('reading %s'%os.path.basename(infile))
    fpin            = Nio.open_file(infile,'r')
    o2_min_vol[r,:] = fpin.variables['o2_min_vol'][:]
    fpin.close()

varlist.append('o2_min_vol')

for varname in varlist:
    # do some basic unit conversions
    if 'cfac' in variables[varname]:
        vars()[varname] = vars()[varname] * variables[varname]['cfac']

    # convert CO2 flux from mol/m^2/year to Peta g C/year
    if varname == 'FG_CO2':
        vars()[varname] = vars()[varname] * area[...,N.newaxis] * 12.01 * 1.e-15
        variables[varname]['units'] = r'Pg C y$^{-1}$'
        # compute cumulative flux
        vars()[varname+'_cum'] = vars()[varname] / 365 # Pg C/day
        vars()[varname+'_cum'] = (vars()[varname+'_cum'] *
            N.resize(dpm,vars()[varname].shape[-1])[N.newaxis,:]
            ).cumsum(axis=-1)
        variables['FG_CO2_cum'] = {
            'label' : 'Cumulative Air-Sea CO$_2$ Flux',
            'units' : 'Pg C'
            }

    # convert from molC/year to Peta gC/year
    if varname in ['photoC_sp','photoC_diat',
            'photoC_diaz','photoC_tot','CaCO3_form']:
        if varname in vars_fulldepth:
            vars()[varname] = (vars()[varname] * vol[...,N.newaxis]
                    * 12.01 * 1.e-15)
        elif varname in vars_zt150m:
            vars()[varname] = (vars()[varname] * vol150m[...,N.newaxis]
                    * 12.01 * 1.e-15)

    # convert from molN/year to Tera gN/year
    if varname in ['diaz_Nfix','DENITRIF']:
        if varname in vars_fulldepth:
            vars()[varname] = (vars()[varname] * vol[...,N.newaxis] * 14.
                    * 1.e-12)
        elif varname in vars_zt150m:
            vars()[varname] = (vars()[varname] * vol150m[...,N.newaxis] * 14.
                    * 1.e-12)

    # convert from mol/year to Tmol/year
    if varname in ['NITRIF','bSi_form']:
        if varname in vars_fulldepth:
            vars()[varname] = vars()[varname] * vol[...,N.newaxis] * 1.e-12
        elif varname in vars_zt150m:
            vars()[varname] = vars()[varname] * vol150m[...,N.newaxis] * 1.e-12

    # compute 12-month running averages
    for r in range(nreg):
        if 'Chl' in varname:
            vars()[varname][r,:] = ndimage.gaussian_filter1d(
                    vars()[varname][r,:],7,mode='nearest')
        else:
            vars()[varname][r,:] = ndimage.uniform_filter1d(
                    vars()[varname][r,:],12,mode='nearest')

if 'FG_CO2' in varlist: varlist.append('FG_CO2_cum') # update variable list

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
    if varname in vars_fulldepth:
        note = 'Full Depth'
    elif varname in vars_zt150m:
        note = 'Upper 150 m'
    elif varname == 'o2_min_vol':
        note = r'$.\;\;\;\;\;$O$_2^{min}$= 4 mmol m$^{-3}$'
    else:
        note = ''

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
#   top_labels(ax,case.replace('_','\_'),note,'%d-year moving avg'%(nyrs))
    #fig.savefig(outfile,dpi=125,bbox_inches='tight',pad_inches=1)
    extent = ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted())
    fig.savefig(outfile,dpi=100,bbox_inches=extent.expanded(1.4,1.3))
    pl.close(fig)

