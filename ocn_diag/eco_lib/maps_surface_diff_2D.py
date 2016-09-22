# Maps of comparisons between model experiment and control simulations at the surface.
# Based on model_obs_maps.py created by Ivan Lima on Thu Nov 18 11:21:53 EST 2010
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - compare experiment to control and calculate difference,
#  - read resource file (dictionary),
#  - compute maximum, minimum, spatial mean, and root-mean-square,

# Identical to maps_surface_diff.py
# For plots of 2D variables use resource (dictionary) res_surface_2D.py
# For plots of 3D variables use resource (dictionary) res_vars_3D.py

# Reads input file: 
#  'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output file:
#   map_'var'_diff.png
# or:
#   map_exp_cntrl_'yrstart'-'yrend'_'var'.png

import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from mpl_utils import *
from res_surface_2D import *
from ccsm_utils import pop_remap, grid_area, get_grid_data,\
           pop_remap_popdiag, get_grid_data_popdiag

case       = raw_input('Read Experiment: \n')
yrstart    = int(raw_input('Read start year Experiment: \n'))
yrend      = int(raw_input('Read end year Experiment: \n'))
cntrlcase  = raw_input('Read Control: \n')
yr0cntrl   = int(raw_input('Read start year Control: \n'))
yr1cntrl   = int(raw_input('Read end year Control: \n'))
POPDIAGPY  = raw_input('Read TRUE or FALSE: \n')
yroffset   = int(raw_input('Read year offset: \n'))
WORKDIRPY  = raw_input('Read WORKDIR: \n')
mgridexp   = raw_input('Read case grid/resolution: \n')
mgridcntrl = raw_input('Read control grid/resolution: \n')

# Example:
# case    = 'b40.20th.1deg.bdrd.001'
# yrstart = 1991
# yrend   = 1992
# POPDIAGPY = 'TRUE'

# get simulation year
if POPDIAGPY == 'TRUE':
   eyrstart = yroffset + yrstart
   eyrend   = yroffset + yrend  
   cyrstart = yroffset + yr0cntrl
   cyrend   = yroffset + yr1cntrl
   year_string_exp = '[%.0f-%.0f]'%(eyrstart,eyrend)
   year_string_cnt = '[%.0f-%.0f]'%(cyrstart,cyrend)
   model_grid = mgridexp
else:
   myrstart = yrstart - 181 + 1948
   myrend   = yrend   - 181 + 1948
   year_string_exp = '[%.0f-%.0f]'%(myrstart,myrend)
   model_grid = 'gx1v6'

# set some plot resources
pl.rc('font',**{'size':10})
pl.rc('contour',negative_linestyle='solid') # solid negative contour lines

cmapdiff = CyBuWhRdYl

# get variables to read
varlist = sorted(variables)

# variables to integrate vertically
vintlist = ['photoC_sp','photoC_diat','photoC_diaz','photoC_tot',
            'diaz_Nfix','CaCO3_form','bSi_form','NITRIF','DENITRIF']

# indir: where processed files are located
# outdir: where plots are saved
if POPDIAGPY == 'TRUE':
   expdir = WORKDIRPY
   print('Experiment dir: %s'%(expdir))
   cntrldir = WORKDIRPY
   print('Control dir: %s'%(cntrldir))
   outdir = WORKDIRPY
   print('Output dir: %s'%(outdir))
else:
   expdir = '/bonaire/data2/ivan/ccsm_output'
   cntrldir = '/bonaire/data2/ivan/ccsm_output'
   outdir = '/fiji/home/ivan/www/ccsm_log/cases/%s/plots'%case

# Get plots directory ready
if (not os.path.isdir(outdir)):
    os.makedirs(outdir)
print('plots saved in %s'%(outdir))

# Read processed files
# read model data

# Dictionary to hold variables
datam = {}
datao = {}
differnce = {}

for var in varlist:
    infile_exp = os.path.join(expdir,
      '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))
    infile_cntrl = os.path.join(cntrldir,
      '%s.%s.clim.%04d-%04d.nc'%(cntrlcase,var,yr0cntrl,yr1cntrl))

    # experiment file --------------------------------------------------
    if os.path.isfile(infile_exp): # is file/variable available?
        print('reading %s'%(os.path.basename(infile_exp)))
        fpmod  = Nio.open_file(infile_exp,'r')
        zt    = fpmod.variables['z_t'][:] / 100.    # cm -> m
        zw    = fpmod.variables['z_w'][:] / 100.    # cm -> m
        dz    = fpmod.variables['dz'][:]  / 100.    # cm -> m
        area  = fpmod.variables['TAREA'][:] * 1.e-4 # cm^2 -> m^2
        tlon  = fpmod.variables['TLONG'][:]
        tlat  = fpmod.variables['TLAT'][:]
        zind  = N.searchsorted(zt,100).item() # 100m index
        depth = zw[zind]
        variables[var]['fillvalue'] = fpmod.variables[var]._FillValue[0]

        if fpmod.variables[var][:].ndim == 3:   # 2-D field
            datam[var] = fpmod.variables[var][:]
        elif fpmod.variables[var][:].ndim == 4: # 3-D field
            if 'FLUX_IN' in var:  # particle flux at 100 m
                datam[var] = fpmod.variables[var][:,zind,:,:]
            elif var in vintlist: # integrate vertically
                datam[var] = fpmod.variables[var][:]
                nz = datam[var].shape[1]
                datam[var] = MA.sum(datam[var] *
                    dz[N.newaxis,:nz,N.newaxis,N.newaxis],1)
            else: # surface field
                datam[var] = fpmod.variables[var][:,0,:,:]
        else:
            print('Check %s dimensions'%(var))
            sys.exit()

        fpmod.close()

        # compute temporal mean
        datam[var] = datam[var].mean(axis=0)
        if 'cfac' in variables[var]: # apply unit conversions if any
            datam[var] = datam[var] * variables[var]['cfac']

        # compute max & min
        mdatamin = datam[var].min()
        mdatamax = datam[var].max()

        # compute mean & r.m.s.
        mdatamean = MA.sum(datam[var] * area) / MA.sum(area)
        mdatarms = MA.sqrt(MA.sum(datam[var] * datam[var] * area) / MA.sum(area))

        # compute annual totals and include them in plot labels
        if 'tcfac' in variables[var]:
            totalm = MA.sum(datam[var] * area) * variables[var]['tcfac']
            if 'FLUX_IN' in var: # particle flux
                variables[var]['title_exp'] = 'Total %s at %.0f m = %.2f %s'%(
                    variables[var]['label'],depth,totalm,variables[var]['tunits'])
            else: # vertical integrals
                variables[var]['title_exp'] = 'Total %s = %.2f %s'%(
                    variables[var]['label'],totalm,variables[var]['tunits'])

        if POPDIAGPY == 'TRUE':
            variables[var]['title_exp'] = '%s: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
                variables[var]['slabel'],mdatamin,mdatamax,mdatamean,mdatarms)

        print('%s'%(variables[var]['title_exp']))

    # control file -----------------------------------------------------
    if os.path.isfile(infile_cntrl): # is file/variable available?
        print('reading %s'%(os.path.basename(infile_cntrl)))
        fpobs  = Nio.open_file(infile_cntrl,'r')
        zt    = fpobs.variables['z_t'][:] / 100.    # cm -> m
        zw    = fpobs.variables['z_w'][:] / 100.    # cm -> m
        dz    = fpobs.variables['dz'][:]  / 100.    # cm -> m
        area  = fpobs.variables['TAREA'][:] * 1.e-4 # cm^2 -> m^2
        tlon  = fpobs.variables['TLONG'][:]
        tlat  = fpobs.variables['TLAT'][:]
        zind  = N.searchsorted(zt,100).item() # 100m index
        depth = zw[zind]
        variables[var]['fillvalue'] = fpobs.variables[var]._FillValue[0]

        if fpobs.variables[var][:].ndim == 3:   # 2-D field
            datao[var] = fpobs.variables[var][:]
        elif fpobs.variables[var][:].ndim == 4: # 3-D field
            if 'FLUX_IN' in var:  # particle flux at 100 m
                datao[var] = fpobs.variables[var][:,zind,:,:]
            elif var in vintlist: # integrate vertically
                datao[var] = fpobs.variables[var][:]
                nz = datao[var].shape[1]
                datao[var] = MA.sum(datao[var] *
                    dz[N.newaxis,:nz,N.newaxis,N.newaxis],1)
            else: # surface field
                datao[var] = fpobs.variables[var][:,0,:,:]
        else:
            print('Check %s dimensions'%(var))
            sys.exit()

        fpobs.close()

        # compute temporal mean
        datao[var] = datao[var].mean(axis=0)
        if 'cfac' in variables[var]: # apply unit conversions if any
            datao[var] = datao[var] * variables[var]['cfac']

        # compute annual totals and include them in plot labels
        if 'tcfac' in variables[var]:
            totalo = MA.sum(datao[var] * area) * variables[var]['tcfac']
            totaldiff = totalm - totalo
            if 'FLUX_IN' in var: # particle flux
                variables[var]['title_cntrl'] = 'Experiment - Control (Delta total = %.2f %s)'%(
                    totaldiff,variables[var]['tunits'])
            else: # vertical integrals
                variables[var]['title_cntrl'] = 'Experiment - Control (Delta total = %.2f %s)'%(
                    totaldiff,variables[var]['tunits'])

            print('%s'%(variables[var]['title_cntrl']))

        # plot maps -----------------------------------------------------------
        if POPDIAGPY == 'TRUE':
           outfile = os.path.join(outdir,'map_%s_diff.png'%var)
        else:
           outfile = os.path.join(outdir,
            'map_exp_cntrl_%04d-%04d_%s.png'%(yrstart,yrend,var))
        print('plotting %s'%(os.path.basename(outfile)))

        if var in ['SSH','NO3_excess','FG_CO2','STF_O2','FvPER_DIC']:
            cmapmap = CyBuWhRdYl
        else:
            cmapmap = pl.cm.jet

        # -----------------------------------------------------------

        fig = pl.figure(figsize=(8,11))

        # plot experiment -------------------------------------------------
        ax  = fig.add_subplot(311)
        lon, lat, expdata = fix_pop_grid(tlon,tlat,datam[var])
        map = Basemap(llcrnrlon=-330,urcrnrlon=30,llcrnrlat=-85,
            urcrnrlat=85,resolution='l',projection='cyl',ax=ax)
        map.drawcoastlines(linewidth=0.5)
        map.drawrivers(linewidth=0.1,color='white')
        map.drawparallels(N.arange(-90,120,30) ,labels=[0,0,0,0],linewidth=0.25)
        map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
        map.fillcontinents('white')
        x,y = map(lon,lat)
        CF  = map.contourf(x,y,expdata,variables[var]['clev'],cmap=cmapmap,
              norm=colors.BoundaryNorm(variables[var]['clev'],cmapmap.N),extend='both')
        CF.cmap.set_under('black')
        CF.cmap.set_over('black')
        CS  = map.contour(x,y,expdata,CF.levels,colors = 'k',linewidths = 0.25)
        CB  = fig.colorbar(CF,ax=ax,drawedges=True,shrink=0.8,aspect=11,
                ticks=variables[var]['clev'][1:-1],format='%G')
        CB.set_label(variables[var]['units'])
        for line in CB.ax.get_yticklines(): # remove tick lines
            line.set_markersize(0)

        bottom_labels(ax,'Experiment:',case.replace('_',' '),year_string_exp,fontsize=10)
        ax.set(title=variables[var]['title_exp'])

        # calculate difference -------------------------------------------------

        differnce[var] = datam[var] - datao[var]
        lon, lat, diffdata = fix_pop_grid(tlon,tlat,differnce[var])
        x,y = map(lon,lat)

        # compute max & min
        odatamin = differnce[var].min()
        odatamax = differnce[var].max()

        # compute mean & rms
        odatamean = MA.sum(differnce[var] * area) / MA.sum(area)
        odatarms = MA.sqrt(MA.sum(differnce[var] * differnce[var] * area) / MA.sum(area))

        variables[var]['title_cntrl'] = 'Exp-Con: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
            odatamin,odatamax,odatamean,odatarms)

        # plot difference -------------------------------------------------
        ax  = fig.add_subplot(312)
        map = Basemap(llcrnrlon=-330,urcrnrlon=30,llcrnrlat=-85,
            urcrnrlat=85,resolution='l',projection='cyl',ax=ax)
        map.drawcoastlines(linewidth=0.5)
        map.drawrivers(linewidth=0.1,color='white')
        map.drawparallels(N.arange(-90,120,30) ,labels=[0,0,0,0],linewidth=0.25)
        map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
        map.fillcontinents('white')
#       ax.set(title='Experiment - Control')
        ax.set(title=variables[var]['title_cntrl'])
        CF  = map.contourf(x,y,diffdata,variables[var]['dlev'],cmap=cmapdiff,
              norm=colors.BoundaryNorm(variables[var]['dlev'],cmapdiff.N),extend='both')
        CF.cmap.set_under('black')
        CF.cmap.set_over('black')
        CS  = map.contour(x,y,diffdata,CF.levels,colors = 'k',linewidths = 0.25)
        CB  = fig.colorbar(CF,ax=ax,drawedges=True,shrink=0.8,aspect=11,
                ticks=variables[var]['dlev'][1:-1],format='%G')
        CB.set_label(variables[var]['units'])
        for line in CB.ax.get_yticklines(): # remove tick lines
            line.set_markersize(0)

        bottom_labels(ax,'Control:',cntrlcase.replace('_',' '),year_string_cnt,fontsize=10)

        # save figure and close -----------------------------------------------
        fig.savefig(outfile,dpi=150,bbox_inches='tight',pad_inches=0.2)
        pl.close(fig)

#-----------------------------------------------------------------------------
