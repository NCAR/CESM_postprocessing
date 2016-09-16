# Computes temporal means of nutrient limitation patterns in the mixed layer
# and make plots. Matplotlib version.
# Created by Ivan Lima on Fri Jul 30 14:56:00 EDT 2004
# Last modified on Thu Sep 15 11:41:20 EDT 2011
# Modified by Ernesto Munoz to: 
#  - update light limitation factors to compensate for diurnal cycle

# Reads input files: 
#   'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output files:
#   map_nutlim_sp.png
#   map_nutlim_diat.png
#   map_nutlim_diaz.png
# or
#   map_'yrstart'-'yrend'_nutlim_sp.png
#   map_'yrstart'-'yrend'_nutlim_diat.png
#   map_'yrstart'-'yrend'_nutlim_diaz.png

import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from mpl_utils import *
from ccsm_utils import pop_remap, grid_area, get_grid_data,\
	pop_remap_popdiag, get_grid_data_popdiag

case      = raw_input('Enter case(s): \n')
yrstart   = int(raw_input('Enter starting year: \n'))
yrend     = int(raw_input('Enter ending year: \n'))
POPDIAGPY = raw_input('Enter TRUE or FALSE: \n')
yroffset  = int(raw_input('Enter year offset: \n'))
WORKDIRPY = raw_input('Read WORKDIR: \n')
mgrid     = raw_input('Enter model grid/resolution: \n')
ODATADIR  = raw_input('Enter directory of observations: \n')

# Example:
# case    = 'GECO.IAF.x1.CESM1.001'
# case    = 'GECO.IAF.20th.x1.CESM1.001'
# yrstart = 231
# yrend   = 240
# POPDIAGPY = 'TRUE'

# get simulation year
if POPDIAGPY == 'TRUE':
    myrstart = yroffset + yrstart
    myrend   = yroffset + yrend
else:
    myrstart = yrstart - 181 + 1948
    myrend   = yrend - 181 + 1948

year_string = '%.0f-%.0f'%(myrstart,myrend)

varlist = [
    'diat_Fe_lim','diat_N_lim','diat_P_lim','diat_SiO3_lim','diat_light_lim',
    'diaz_Fe_lim','diaz_P_lim','diaz_light_lim',
    'sp_Fe_lim','sp_N_lim','sp_P_lim','sp_light_lim'
    ]

# where input files are located
if POPDIAGPY == 'TRUE':
    indir = WORKDIRPY 
    outdir = WORKDIRPY 
else:
    indir = '/bonaire/data2/ivan/ccsm_output'
    outdir = '/fiji/home/ivan/www/ccsm_log/cases/%s/plots'%case

zref = 20 # upper zref m

# get regular grid info
if POPDIAGPY == 'TRUE':
   nlon, nlat, tlon, tlat = get_grid_data_popdiag('1x1d')
else:
   nlon, nlat, tlon, tlat = get_grid_data('1x1d')

for var in varlist:
    if POPDIAGPY == 'TRUE':
       infile = os.path.join(indir,
              '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))
    else:
       infile = os.path.join(indir,case,
              '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))
    print('reading %s'%(os.path.basename(infile)))
    fpin      = Nio.open_file(infile,'r')
    nz        = fpin.dimensions['z_t_150m']
    zt        = fpin.variables['z_t_150m'][:]   / 100. # cm -> m
    zw        = fpin.variables['z_w'][:nz]      / 100. # cm -> m
    zind      = N.searchsorted(zw,zref)
    fillvalue = fpin.variables[var]._FillValue[0]
    datain    = fpin.variables[var][:].mean(0)    # compute annual mean
    datain    = datain[:zind,...].mean(0)         # mean for upper 50m
    fpin.close()
    # interpolate 2D field to regular 1x1d grid so I can use imshow
    if POPDIAGPY == 'TRUE':
       work = pop_remap_popdiag(datain,mgrid,'1x1d','bilin','',fillvalue)
    else:
       work = pop_remap(datain,'gx1v6','1x1d','bilin','',fillvalue)
    vars()[var] = MA.masked_values(N.reshape(work,(nlat,nlon)),fillvalue)

if POPDIAGPY == 'TRUE':
   infile = os.path.join(indir,
          '%s.TEMP.clim.%04d-%04d.nc'%(case,yrstart,yrend))
else:
   infile = os.path.join(indir,case,
          '%s.TEMP.clim.%04d-%04d.nc'%(case,yrstart,yrend))
fpin = Nio.open_file(infile,'r')
temp = fpin.variables['TEMP'][:,:nz,:,:].mean(0)   # annual mean
temp = temp[:zind,...].mean(0)                     # mean for upper 50m
fpin.close()
# interpolate to regular 1x1d grid
if POPDIAGPY == 'TRUE':
   work = pop_remap_popdiag(temp,mgrid,'1x1d','bilin','',fillvalue)
else:
   work = pop_remap(temp,'gx1v6','1x1d','bilin','',fillvalue)
temp = MA.masked_values(N.reshape(work,(nlat,nlon)),fillvalue)

# compute limiting nutrient indices
# Fe = 1, N = 2, P = 3, Si = 4, light = 5, temperature = 6, replete = 7
nFe = 1; nN = 2; nP = 3; nSi = 4; nlight = 5; ntemp = 6; nrepl = 7

# value above which growth is 'replete'
ref = 0.9

# NOTE: the light limitation factor seems to be low in most of the domain,
# masking the effect of the other nutrients. So it's set to 1 here so the maps
# can show the limiting effects of nutrients.
#sp_light_lim   = 1
#diat_light_lim = 1
#diaz_light_lim = 1

# modify light limitation factors to compensate for diurnal cycle
sp_light_lim = sp_light_lim * 2.0
diat_light_lim = diat_light_lim * 2.0
diaz_light_lim = diaz_light_lim * 2.0

#------------- small phyto -------------
sp_lim = MA.masked_all((nlat,nlon),dtype=N.int)

# Fe limitation
sp_lim[((sp_Fe_lim < sp_N_lim)   *
        (sp_Fe_lim < sp_P_lim) *
        (sp_Fe_lim < sp_light_lim))] = nFe
# N limitation
sp_lim[((sp_N_lim < sp_Fe_lim)   *
        (sp_N_lim < sp_P_lim)  *
        (sp_N_lim < sp_light_lim))] = nN
# PO4 limitation
sp_lim[((sp_P_lim < sp_Fe_lim) *
        (sp_P_lim < sp_N_lim)  *
        (sp_P_lim < sp_light_lim))] = nP
# light limitation
sp_lim[((sp_light_lim < sp_Fe_lim) *
        (sp_light_lim < sp_N_lim)  *
        (sp_light_lim < sp_P_lim))] = nlight
# replete
#sp_lim[((sp_Fe_lim > ref) * (sp_N_lim > ref) * (sp_P_lim > ref) *
#    (sp_light_lim > ref))] = nrepl

#------------- diatoms -------------
diat_lim = MA.masked_all((nlat,nlon),dtype=N.int)

# Fe limitation
diat_lim[((diat_Fe_lim < diat_N_lim)    *
          (diat_Fe_lim < diat_P_lim)  *
          (diat_Fe_lim < diat_SiO3_lim) *
          (diat_Fe_lim < diat_light_lim))] = nFe
# N limitation
diat_lim[((diat_N_lim < diat_Fe_lim)   *
          (diat_N_lim < diat_P_lim)  *
          (diat_N_lim < diat_SiO3_lim) *
          (diat_N_lim < diat_light_lim))] = nN
# PO4 limitation
diat_lim[((diat_P_lim < diat_Fe_lim)   *
          (diat_P_lim < diat_N_lim)    *
          (diat_P_lim < diat_SiO3_lim) *
          (diat_P_lim < diat_light_lim))] = nP
# SiO3 limitation
diat_lim[((diat_SiO3_lim < diat_Fe_lim)  *
          (diat_SiO3_lim < diat_N_lim)   *
          (diat_SiO3_lim < diat_P_lim) *
          (diat_SiO3_lim < diat_light_lim))] = nSi
# light limitation
diat_lim[((diat_light_lim < diat_Fe_lim)  *
          (diat_light_lim < diat_N_lim)   *
          (diat_light_lim < diat_P_lim) *
          (diat_light_lim < diat_SiO3_lim))] = nlight
# replete
#diat_lim[((diat_Fe_lim    > ref) *
#          (diat_N_lim     > ref) *
#          (diat_P_lim   > ref) *
#          (diat_SiO3_lim  > ref) *
#          (diat_light_lim > ref))] = nrepl

#------------- diazotrophs -------------
diaz_lim = MA.masked_all((nlat,nlon),dtype=N.int)

min_temp = 15

# Fe limitation
diaz_lim[((diaz_Fe_lim < diaz_P_lim) * (diaz_Fe_lim < diaz_light_lim))] = nFe
# PO4 limitation
diaz_lim[((diaz_P_lim < diaz_Fe_lim) * (diaz_P_lim < diaz_light_lim))] = nP
# light limitation
diaz_lim[((diaz_light_lim < diaz_Fe_lim) *
          (diaz_light_lim < diaz_P_lim))] = nlight
# temperature limitation
diaz_lim[temp < min_temp] = ntemp

# replete
#diaz_lim[((diaz_Fe_lim    > ref) *
#          (diaz_P_lim     > ref) *
#          (diaz_light_lim > ref))] = nrepl

#------------------------------------------------------------------------------
# plot maps

# create directory for plots if necessary
if (not os.path.isdir(outdir)):
    os.makedirs(outdir)

cbticks      = [nFe, nN, nP, nSi, nlight, ntemp]#,nrepl]
cbticklabels = ['Fe','N','P','Si','Light','Temp.']#'Replete']
cblevels     = [0,1.5,2.5,3.5,4.5,5.5,6.5]

cmap = pl.cm.jet

# Small phyto nutrient limitation plot
if POPDIAGPY == 'TRUE':
  outfile = os.path.join(outdir,'map_nutlim_sp.png')
else:
  outfile = os.path.join(outdir,'map_%04d-%04d_nutlim_sp.png'%(yrstart,yrend))

print('plotting %s'%(outfile))
fig = pl.figure()
ax  = fig.add_subplot(111)
map = Basemap(llcrnrlon=30,urcrnrlon=360+30,llcrnrlat=-85,urcrnrlat=85,
        resolution='l',projection='cyl',ax=ax)
map.drawcoastlines(linewidth=0.5)
map.drawrivers(linewidth=0.75,color='white')
map.drawparallels(N.arange(-90,120,30),labels=[0,0,0,0],linewidth=0.25)
map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
map.fillcontinents('white')
data, x, y = map.transform_scalar(sp_lim,tlon,tlat,nlon,nlat,returnxy=True)
IM  = map.imshow(data,norm=colors.normalize(vmin=0,vmax=6.5),cmap=cmap)
CB  = fig.colorbar(IM,ax=ax,shrink=0.5,aspect=12,drawedges=True,ticks=cbticks,
        boundaries=cblevels,values=cbticks)
CB.ax.set_yticklabels(cbticklabels)
for line in CB.ax.get_yticklines(): # remove tick lines
    line.set_markersize(0)

bottom_labels(ax,case.replace('_',' '),'',year_string,fontsize=10)
ax.set(title='Small Phyto. growth limitation factor in upper %.0f m'%(zref))
fig.savefig(outfile,dpi=150,bbox_inches='tight',pad_inches=0.2)
pl.close(fig)

# Diatom nutrient limitation plot
if POPDIAGPY == 'TRUE':
  outfile = os.path.join(outdir,'map_nutlim_diat.png')
else:
  outfile = os.path.join(outdir,'map_%04d-%04d_nutlim_diat.png'%(yrstart,yrend))

print('plotting %s'%(outfile))
fig = pl.figure()
ax  = fig.add_subplot(111)
map = Basemap(llcrnrlon=30,urcrnrlon=360+30,llcrnrlat=-85,urcrnrlat=85,
        resolution='l',projection='cyl',ax=ax)
map.drawcoastlines(linewidth=0.5)
map.drawrivers(linewidth=0.75,color='white')
map.drawparallels(N.arange(-90,120,30),labels=[0,0,0,0],linewidth=0.25)
map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
map.fillcontinents('white')
data, x, y = map.transform_scalar(diat_lim,tlon,tlat,nlon,nlat,returnxy=True)
IM  = map.imshow(data,norm=colors.normalize(vmin=0,vmax=6.5),cmap=cmap)
CB  = fig.colorbar(IM,ax=ax,shrink=0.5,aspect=12,drawedges=True,ticks=cbticks,
        boundaries=cblevels,values=cbticks)
CB.ax.set_yticklabels(cbticklabels)
for line in CB.ax.get_yticklines(): # remove tick lines
    line.set_markersize(0)

bottom_labels(ax,case.replace('_',' '),'',year_string,fontsize=10)
ax.set(title='Diatom growth limitation factor in upper %.0f m'%(zref))
fig.savefig(outfile,dpi=150,bbox_inches='tight',pad_inches=0.2)
pl.close(fig)

# Diazotrophs nutrient limitation plot
if POPDIAGPY == 'TRUE':
  outfile = os.path.join(outdir,'map_nutlim_diaz.png')
else:
  outfile = os.path.join(outdir,'map_%04d-%04d_nutlim_diaz.png'%(yrstart,yrend))

print('plotting %s'%(outfile))
fig = pl.figure()
ax  = fig.add_subplot(111)
map = Basemap(llcrnrlon=30,urcrnrlon=360+30,llcrnrlat=-85,urcrnrlat=85,
        resolution='l',projection='cyl',ax=ax)
map.drawcoastlines(linewidth=0.5)
map.drawrivers(linewidth=0.75,color='white')
map.drawparallels(N.arange(-90,120,30),labels=[0,0,0,0],linewidth=0.25)
map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
map.fillcontinents('white')
data, x, y = map.transform_scalar(diaz_lim,tlon,tlat,nlon,nlat,returnxy=True)
IM  = map.imshow(data,norm=colors.normalize(vmin=0,vmax=6.5),cmap=cmap)
CB  = fig.colorbar(IM,ax=ax,shrink=0.5,aspect=12,drawedges=True,ticks=cbticks,
        boundaries=cblevels,values=cbticks)
CB.ax.set_yticklabels(cbticklabels)
for line in CB.ax.get_yticklines(): # remove tick lines
    line.set_markersize(0)

bottom_labels(ax,case.replace('_',' '),'',year_string,fontsize=10)
ax.set(title='Diazotrophs growth limitation factor in upper %.0f m'%(zref))
fig.savefig(outfile,dpi=150,bbox_inches='tight',pad_inches=0.2)
pl.close(fig)

#------------------------------------------------------------------------------
