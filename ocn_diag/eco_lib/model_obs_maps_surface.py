# Maps of comparisons between model and observational climatologies at the surface.
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
#   mod_obs_map_'var'_0m.png
# or:
#   mod_obs_map_'yrstart'-'yrend'_'var'.png

import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from mpl_utils import *
from res_mod_obs_0m import *
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
    myrstart = yrstart + yroffset 
    myrend   = yrend + yroffset 
else:
    myrstart = yrstart - 181 + 1948
    myrend   = yrend - 181 + 1948

year_string = '%.0f-%.0f'%(myrstart,myrend)

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
print('plots saved in %s'%(outdir))

# some plot settings
pl.rc('font',**{'size':10})
pl.rc('contour',negative_linestyle='solid')
#pl.rc('figure',**{'subplot.hspace':0.1})

cmapdiff = CyBuWhRdYl # colormap for difference plots

# dictionary to hold variables
data        = {}
data['mod'] = {}
data['obs'] = {}

for var in varlist:

    if POPDIAGPY == 'TRUE':
        infile = os.path.join(indir,
            '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))
    else:
        infile = os.path.join(indir,case,
            '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))

    if os.path.isfile(infile): # is file/variable available?
        #----------------------------------------------------------------------
        # read model data
        print('reading %s'%(os.path.basename(infile)))
        fpmod = Nio.open_file(infile,'r')
        dz    = fpmod.variables['dz'][:]  / 100.    # cm -> m
        area  = fpmod.variables['TAREA'][:] * 1.e-4 # cm^2 -> m^2
        variables[var]['fillvalue'] = fpmod.variables[var]._FillValue[0]
        if var in ['pCO2SURF','FG_CO2','photoC_tot']:
            data['mod'][var] = fpmod.variables[var][:]
            if var in ['photoC_tot']: # integrate vertically
                nz = data['mod'][var].shape[1]
                data['mod'][var] = MA.sum(data['mod'][var] *
                        dz[N.newaxis,:nz,N.newaxis,N.newaxis],1)
        else: # read surface values
            data['mod'][var] = fpmod.variables[var][:,0,:,:]

        fpmod.close()

        # compute temporal mean
        data['mod'][var] = data['mod'][var].mean(axis=0)
        # apply unit conversions if any
        if 'cfac' in variables[var]:
            data['mod'][var] = data['mod'][var] * variables[var]['cfac']

        # compute min & max
        mdatamin = data['mod'][var].min()
        mdatamax = data['mod'][var].max()

        # compute mean & r.m.s.
        mdatamean = MA.sum(data['mod'][var] * area) / MA.sum(area)
        mdatarms = MA.sqrt(MA.sum(data['mod'][var] * data['mod'][var] * area) / MA.sum(area))

        #----------------------------------------------------------------------
        # read obs data
        print 'reading %s from %s'%(variables[var]['obsname'],
        os.path.basename(variables[var]['obsfile']))
        obsfile = variables[var]['obsfile']
        fpobs   = Nio.open_file(obsfile,'r')
        if var in ['NO3','PO4','SiO3','O2',]: # read surface values
            data['obs'][var] = (
                    fpobs.variables[variables[var]['obsname']][:,0,:,:])
        else:
            data['obs'][var] = fpobs.variables[variables[var]['obsname']][:]

        if var == 'FG_CO2': # invert sign of obs flux so it is same as model
            data['obs'][var] = data['obs'][var] * -1.
        # compute temporal mean or integral
        if var in ['photoC_tot']:
            # gC/m^2/mon -> gC/m^2/yr
            data['obs'][var] = data['obs'][var].sum(axis=0)
        else:
            data['obs'][var] = data['obs'][var].mean(axis=0)

        # apply unit conversions if any
        if 'obscfac' in variables[var]:
            data['obs'][var] = data['obs'][var] * variables[var]['obscfac']

        fpobs.close()

        #print var, data['mod'][var].shape, data['obs'][var].shape
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

        # compute min & max
        odatamin = data['obs'][var].min()
        odatamax = data['obs'][var].max()

        # compute mean & r.m.s.
        odatamean = MA.sum(data['obs'][var] * area_obs) / MA.sum(area_obs)
        odatarms = MA.sqrt(MA.sum(data['obs'][var] * data['obs'][var] * area_obs) / MA.sum(area_obs))

        # compute annual totals and add totals to plot labels from model and obs data
        if 'tcfac' in variables[var]:
            total = MA.sum(data['mod'][var] * area) * variables[var]['tcfac']
            if POPDIAGPY == 'TRUE':
               variables[var]['title_mod'] = '%s: Total: %.2f %s, Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
                   variables[var]['slabel'],total,variables[var]['tunits'],mdatamin,mdatamax,mdatamean,mdatarms)
            else:
               variables[var]['title_mod'] = 'Total %s = %.2f %s'%(
                   variables[var]['label'],total,variables[var]['tunits'])

            print 'Model', variables[var]['title_mod']

            total = MA.sum(data['obs'][var] * area_obs)*variables[var]['tcfac']
            if POPDIAGPY == 'TRUE':
               variables[var]['title_obs'] = '%s: Total: %.2f %s, Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
                   variables[var]['slabel'],total,variables[var]['tunits'],odatamin,odatamax,odatamean,odatarms)
            else:
               variables[var]['title_obs'] = 'Total %s = %.2f %s'%(
                   variables[var]['label'],total,variables[var]['tunits'])

            print 'Obs', variables[var]['title_obs']
        else:
            variables[var]['title_mod'] = '%s: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
                variables[var]['slabel'],mdatamin,mdatamax,mdatamean,mdatarms)

            variables[var]['title_obs'] = '%s: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
                variables[var]['slabel'],odatamin,odatamax,odatamean,odatarms)

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
        if var in ['FG_CO2']:
            cmapmap = CyBuWhRdYl
        else:
            cmapmap = pl.cm.jet

        if POPDIAGPY == 'TRUE':
           outfile = os.path.join(outdir,'mod_obs_map_%s_0m.png'%var)
        else:
           outfile = os.path.join(outdir,'mod_obs_map_%04d-%04d_%s.png'%
                (yrstart,yrend,var))
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
        map.fillcontinents('lightgrey')
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
        map.fillcontinents('lightgrey')

        if POPDIAGPY == 'TRUE':
           differnce = data['mod'][var] - data['obs'][var] 

           # compute max & min
           ddatamin = differnce.min()
           ddatamax = differnce.max()

           # compute mean & r.m.s.
           ddatamean = MA.sum(differnce * area_obs) / MA.sum(area_obs)
           ddatarms = MA.sqrt(MA.sum(differnce * differnce * area_obs) / MA.sum(area_obs))

           variables[var]['title_diff'] = 'Mod-Obs: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
               ddatamin,ddatamax,ddatamean,ddatarms)

           ax.set(title=variables[var]['title_diff'])

        else:
           differnce = data['obs'][var] - data['mod'][var]
           ax.set(title='Observations - Model')

        # pad map on the right to cut it where I want
        work = MA.concatenate((differnce,differnce),1)
        CF  = map.contourf(x,y,work,variables[var]['dlev'],cmap=cmapdiff,
              norm=colors.BoundaryNorm(variables[var]['dlev'],cmapdiff.N),extend='both')
        CF.cmap.set_under('black')
        CF.cmap.set_over('black')
        CS  = map.contour(x,y,work,CF.levels,colors = 'k',linewidths = 0.25)
        CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=12,shrink=0.9,
                ticks=variables[var]['dlev'][1:-1],format='%G')
        CB.set_label(variables[var]['units'])
        for line in CB.ax.get_yticklines(): # remove tick lines
            line.set_markersize(0)

        fig.savefig(outfile,dpi=150,bbox_inches='tight',pad_inches=0.2)
        pl.close(fig)
        #----------------------------------------------------------------------

#-----------------------------------------------------------------------------
