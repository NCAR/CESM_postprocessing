# Maps of comparisons between model and observational climatologies at various depths.
# Based on model_obs_maps.py created by Ivan Lima on Thu Nov 18 11:21:53 EST 2010
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - process various depths given by plot.dat,
#  - use "dictionary" or resource file,
#  - choose directories (NCAR or WHOI),
#  - compute minimum, maximum, spatial mean, and root-mean-square,
#  - consider different color scales for different depth ranges,

# Reads input file:
#  'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output file:
#   mod_obs_map_'var'_'dpthobs'm.png
# or:
#   mod_obs_map_'yrstart'-'yrend'_'var'_z_'dpthobs'.png

import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from mpl_utils import *
from res_at_depths_wFe import *
from ccsm_utils import pop_remap, grid_area, get_grid_data,\
         pop_remap_popdiag, get_grid_data_popdiag

case      = raw_input('Enter case(s): \n')
yrstart   = int(raw_input('Enter start year: \n'))
yrend     = int(raw_input('Enter end year: \n'))
POPDIAGPY = raw_input('Enter TRUE or FALSE: \n')
yroffset  = int(raw_input('Enter year offset: \n'))
WORKDIRPY = raw_input('Enter WORKDIR: \n')
mgrid     = raw_input('Enter model grid/resolution: \n')
ODATADIR  = raw_input('Enter directory of observations: \n')

# Example:
# case    = 'b40.20th.1deg.bdrd.001'
# yrstart = 1991
# yrend   = 1992
# POPDIAGPY = 'TRUE'

# get simulation year
if POPDIAGPY == 'TRUE':
    myrstart = yroffset + yrstart 
    myrend   = yroffset + yrend   
else:
    myrstart = yrstart - 181 + 1948
    myrend   = yrend - 181 + 1948

year_string = '%.0f-%.0f'%(myrstart,myrend)

spd = 60.*60.*24. # seconds per day

if POPDIAGPY == 'TRUE':
    model_grid = mgrid
else:
    model_grid = 'gx1v6'

# get variables to read
varlist = sorted(variables)

# indir: where processed files are located
# outdir: where plots are saved
if POPDIAGPY == 'TRUE':
    indir = WORKDIRPY
    outdir = WORKDIRPY
else:
    indir = '/bonaire/data2/ivan/ccsm_output'
    outdir = '/fiji/home/ivan/www/ccsm_log/cases/%s/plots'%case

# Get plots directory ready 
if (not os.path.isdir(outdir)):
    os.makedirs(outdir)
print('Plots saved in %s'%(outdir))

# some plot settings
pl.rc('font',**{'size':10})
pl.rc('contour',negative_linestyle='solid')
#pl.rc('figure',**{'subplot.hspace':0.1})

cmapdiff = CyBuWhRdYl # colormap for difference plots

# dictionary to hold variables
data        = {}
data['mod'] = {}
data['obs'] = {}
mask        = {}
mask['mod'] = {}
mask['obs'] = {}

# Get the depths to plot
#dpthsfile = os.path.join(indir,'plot.dat')
dpthsfile = os.path.join(indir,'plot_depths.dat')
print('Reading %s'%(os.path.basename(dpthsfile)))
fzin = open(dpthsfile,'r')
# Make sure the depths only are being used


for line in fzin.readlines():
    dpthsin = map(int,line.split(','))

print('Depths are:')
print dpthsin[0:len(dpthsin)]
print('')

for var in varlist:

  if var not in ['Fe']:

    if POPDIAGPY == 'TRUE':
        infile = os.path.join(indir,
            '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))
    else:
        infile = os.path.join(indir,case,
            '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))

    if os.path.isfile(infile): # is file/variable available?

        for kz in range(len(dpthsin)):
            zdpth = dpthsin[kz]

            #----------------------------------------------------------------------
            # read model data
            print('reading %s'%(os.path.basename(infile)))
            fpmod = Nio.open_file(infile,'r')
            zt    = fpmod.variables['z_t'][:] / 100.    # cm -> m
            zw    = fpmod.variables['z_w'][:] / 100.    # cm -> m
            dz    = fpmod.variables['dz'][:] / 100.     # cm -> m
            area  = fpmod.variables['TAREA'][:] * 1.e-4 # cm^2 -> m^2
            variables[var]['fillvalue'] = fpmod.variables[var]._FillValue[0]

            # read specified depth
            zind  = N.searchsorted(zt,zdpth).item()
            dpthmod = int(zt[zind])
            data['mod'][var] = fpmod.variables[var][:,zind,:,:]

            fpmod.close()  # close model file

            # compute temporal mean
            data['mod'][var] = data['mod'][var].mean(axis=0)
            # apply unit conversions if any
            if 'cfac' in variables[var]:
                data['mod'][var] = data['mod'][var] * variables[var]['cfac']

            data['mod'][var] = MA.masked_values(data['mod'][var],variables[var]['fillvalue'])

            # compute min & max of annual (temporal) mean
            mdatamin = data['mod'][var].min()
            mdatamax = data['mod'][var].max()

            # compute spatial mean & R.M.S. of annual (temporal) mean

            mask['mod'][var] = MA.masked_values(data['mod'][var] / data['mod'][var],
                               variables[var]['fillvalue'])

            mdatamean = MA.masked_values(MA.sum( data['mod'][var] * area * mask['mod'][var] ) / 
                        MA.sum( area * mask['mod'][var] ),variables[var]['fillvalue'])

            mdatarms = MA.masked_values(MA.sqrt(MA.sum( data['mod'][var] * data['mod'][var] * area * mask['mod'][var] ) / 
                       MA.sum( area * mask['mod'][var] )),variables[var]['fillvalue'])

            if POPDIAGPY == 'TRUE':
               variables[var]['title_mod'] = '%s at %.0f m Model: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
                  variables[var]['slabel'],dpthmod,mdatamin,mdatamax,mdatamean,mdatarms)
            else:
               variables[var]['title_mod'] = '%s at %.0f m '%(variables[var]['label'],dpthmod)

            #----------------------------------------------------------------------
            # read obs data
            print 'reading %s from %s'%(variables[var]['obsname'],
            os.path.basename(variables[var]['obsfile']))
            obsfile = variables[var]['obsfile']
            fpobs   = Nio.open_file(obsfile,'r')
            zobs    = fpobs.variables['depth'][:]

            # read specified depth
            if var in ['NO3','PO4','SiO3','O2']:
                zind  = N.searchsorted(zobs,zdpth).item()
                dpthobs = int(zobs[zind])
                data['obs'][var] = (fpobs.variables[variables[var]['obsname']][:,zind,:,:])
            # compute temporal mean or integral
                data['obs'][var] = data['obs'][var].mean(axis=0)

            # read specified depth
            elif var in ['DIC','ALK']:
                zind  = N.searchsorted(zobs,zdpth).item()
                dpthobs = int(zobs[zind])
                data['obs'][var] = (fpobs.variables[variables[var]['obsname']][zind,:,:])

            fpobs.close()

            mask['obs'][var] = MA.masked_values(data['obs'][var] / data['obs'][var],
                               variables[var]['obsmiss'])

            # apply unit conversions if any
            if 'obscfac' in variables[var]:
                data['obs'][var] = data['obs'][var] * variables[var]['obscfac']

            #----------------------------------------------------------------------
            # get obs grid info
            if POPDIAGPY == 'TRUE':
               nlon, nlat, tlon, tlat = get_grid_data_popdiag(variables[var]['obsgrid'])
            else:
               nlon, nlat, tlon, tlat = get_grid_data(variables[var]['obsgrid'])

            # compute area of obs grid cells
            dlon = N.diff(tlon)[0]
            ulon = N.arange(tlon[0]-dlon/2., tlon[-1]+dlon,dlon)
            dlat = N.diff(tlat)[0]
            ulat = N.arange(tlat[0]-dlat/2., tlat[-1]+dlat,dlat)
            area_obs = grid_area(ulon,ulat)

            # compute min & max of annual (temporal) mean
            odatamin = data['obs'][var].min()
            odatamax = data['obs'][var].max()

            # compute spatial mean & R.M.S. of annual (temporal) mean

            odatamean = MA.masked_values((MA.sum(data['obs'][var] * area_obs * mask['obs'][var] ) / 
                        MA.sum(area_obs * mask['obs'][var] )),variables[var]['obsmiss'])

            odatarms = MA.masked_values(MA.sqrt(MA.sum(data['obs'][var] * data['obs'][var] * area_obs * mask['obs'][var] ) / 
                       MA.sum(area_obs * mask['obs'][var] )), variables[var]['obsmiss'])

            if POPDIAGPY == 'TRUE':
               variables[var]['title_obs'] = '%s at %.0f m Obs: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
                  variables[var]['slabel'],dpthobs,odatamin,odatamax,odatamean,odatarms)
            else:
               variables[var]['title_obs'] = '%s at %.0f m '%(variables[var]['label'],dpthobs)

            # interpolate model data to observations grid
            if POPDIAGPY == 'TRUE':
                work = pop_remap_popdiag(data['mod'][var],model_grid,variables[var]['obsgrid'],
                      'bilin','',variables[var]['fillvalue'])
            else:
                work = pop_remap(data['mod'][var],model_grid,variables[var]['obsgrid'],
                      'bilin','',variables[var]['fillvalue'])

            data['mod'][var] = MA.masked_values(N.reshape(work,(nlat,nlon)),
                    variables[var]['fillvalue'])

            #----------------------------------------------------------------------
            # plot maps
            cmapmap = pl.cm.jet

            if POPDIAGPY == 'TRUE':
                outfile = os.path.join(outdir,'mod_obs_map_%s_%sm.png'%
                    (var,dpthobs))
            else:
                outfile = os.path.join(outdir,'mod_obs_map_%04d-%04d_%s_z_%sm.png'%
                    (yrstart,yrend,var,dpthobs))
            print('plotting %s'%(os.path.basename(outfile)))
            fig = pl.figure(figsize=(8,11))

            # plot model ----------------------------------------------------------
            ax   = fig.add_subplot(311)
            map  = Basemap(llcrnrlon=30,urcrnrlon=390,llcrnrlat=-85,
                urcrnrlat=85,resolution='l',projection='cyl',ax=ax)
            map.drawcoastlines(linewidth=0.5)
            map.drawrivers(linewidth=0.5,color='lightgrey')
            map.drawparallels(N.arange(-90,120,30),labels=[0,0,0,0],linewidth=0.25)
            map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
            map.fillcontinents(color='lightgrey')
            # pad map on the right to cut it where I want
            work = MA.concatenate((data['mod'][var],data['mod'][var]),1)
            lons = N.concatenate((tlon,tlon+360))
            lon, lat = N.meshgrid(lons,tlat)
            x,y = map(lon,lat)

            CF  = map.contourf(x,y,work,variables[var]['clev'],cmap=cmapmap,
                  norm=colors.BoundaryNorm(variables[var]['clev'],cmapmap.N),extend='both')
            CF.cmap.set_under('black')
            CF.cmap.set_over('black')
            CS  = map.contour(x,y,work,CF.levels,colors = 'k',linewidths = 0.25)
            CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=12,shrink=0.9,
                    ticks=variables[var]['clev'][1:-1],format='%G')

            CB.set_label(variables[var]['units'])
            for line in CB.ax.get_yticklines(): # remove tick lines
                line.set_markersize(0)

            bottom_labels(ax,case.replace('_',' '),'',year_string,fontsize=10)
            ax.set(title=variables[var]['title_mod'])

            # plot obs ------------------------------------------------------------
            ax   = fig.add_subplot(312)
            map  = Basemap(llcrnrlon=30,urcrnrlon=390,llcrnrlat=-85,
                urcrnrlat=85,resolution='l',projection='cyl',ax=ax)
            map.drawcoastlines(linewidth=0.5)
            map.drawrivers(linewidth=0.5,color='lightgrey')
            map.drawparallels(N.arange(-90,120,30),labels=[0,0,0,0],linewidth=0.25)
            map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
            map.fillcontinents(color='lightgrey')
            # pad map on the right to cut it where I want
            work = MA.concatenate((data['obs'][var],data['obs'][var]),1)

            CF  = map.contourf(x,y,work,variables[var]['clev'],cmap=cmapmap,
                  norm=colors.BoundaryNorm(variables[var]['clev'],cmapmap.N),extend='both')
            CF.cmap.set_under('black')
            CF.cmap.set_over('black')
            CS  = map.contour(x,y,work,CF.levels,colors = 'k',linewidths = 0.25)
            CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=12,shrink=0.9,
                    ticks=variables[var]['clev'][1:-1],format='%G')

            CB.set_label(variables[var]['units'])
            for line in CB.ax.get_yticklines(): # remove tick lines
                line.set_markersize(0)

            bottom_labels(ax,variables[var]['obsllabel'],'',
                    variables[var]['obsrlabel'],fontsize=10)
            ax.set(title=variables[var]['title_obs'])

            # plot difference -----------------------------------------------------
            ax   = fig.add_subplot(313)
            map  = Basemap(llcrnrlon=30,urcrnrlon=390,llcrnrlat=-85,
                urcrnrlat=85,resolution='l',projection='cyl',ax=ax)
            map.drawcoastlines(linewidth=0.5)
            map.drawrivers(linewidth=0.5,color='lightgrey')
            map.drawparallels(N.arange(-90,120,30),labels=[0,0,0,0],linewidth=0.25)
            map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
            map.fillcontinents(color='lightgrey')
            if POPDIAGPY == 'TRUE':
               differnce = data['mod'][var] - data['obs'][var]

               # compute min & max of annual (temporal) mean
               ddatamin = differnce.min()
               ddatamax = differnce.max()

               # compute spatial mean & R.M.S. of annual (temporal) mean
               ddatamean = MA.sum(differnce * area_obs ) / MA.sum(area_obs)
               ddatarms = MA.sqrt(MA.sum(differnce * differnce * area_obs ) / MA.sum(area_obs))

               variables[var]['title_diff'] = 'Mod-Obs: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
                   ddatamin,ddatamax,ddatamean,ddatarms)

               ax.set(title=variables[var]['title_diff'])

            else:
               differnce = data['obs'][var] - data['mod'][var]
               ax.set(title='Observations - Model')

            # pad map on the right to cut it where I want
            work = MA.concatenate((differnce,differnce),1)
            CF  = map.contourf(x,y,work,variables[var]['dlevobs'],cmap=cmapdiff,
                  norm=colors.BoundaryNorm(variables[var]['dlevobs'],cmapdiff.N),extend='both')
            CF.cmap.set_under('black')
            CF.cmap.set_over('black')
            CS  = map.contour(x,y,work,CF.levels,colors = 'k',linewidths = 0.25)
            CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=12,shrink=0.9,
#                   ,ticks=variables[var]['dlevobs'][1:-1],format='%G')
                    format='%G')
            CB.set_label(variables[var]['units'])
            for line in CB.ax.get_yticklines(): # remove tick lines
                line.set_markersize(0)

            fig.savefig(outfile,dpi=150,bbox_inches='tight',pad_inches=0.2)
            pl.close(fig)
            #----------------------------------------------------------------------

#----------------------------------------------------------------------------------
