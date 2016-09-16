# Plots maps of climatological means of selected variables. If more than one
# case is given it plots the map for the fist case and the difference with
# respect to the second case entered. Modified to process output from couple
# ocean-ice runs on the gx1v6 grid. Matplotlib version.
# Based on clim_maps.py created by Ivan Lima on Mon Nov  8 14:30:01 EST 2010
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - choose directories: NCAR or WHOI,
#  - read resource file (dictionary),
#  - apply mask,
#  - compute minimum, maximum, spatial mean and root-mean-square,

# Identical to clim_maps_surface.py except for the resource file.
# For plots of 2D variables use resource (dictionary) res_surface_2D.py
# For plots of 3D variables use resource (dictionary) res_vars_3D.py

# Reads input files: 
#  'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output files:
#   map_yrstart-yrend_'var'.png
# or
#   map_'var'.png


import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from mpl_utils import *
from res_surface_2D import *

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
   myrend   = yrend   - 181 + 1948

year_string = '%.0f-%.0f'%(myrstart,myrend)

spd = 60.*60.*24. # seconds per day

# set some plot resources
pl.rc('font',**{'size':10})
pl.rc('contour',negative_linestyle='solid') # solid negative contour lines

# get variables to read
varlist = sorted(variables)

# variables to integrate vertically
vintlist = ['photoC_sp','photoC_diat','photoC_diaz','photoC_tot',
            'diaz_Nfix','CaCO3_form','bSi_form','NITRIF','DENITRIF']

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

# Read processed files
# read model data

for var in varlist:

    if POPDIAGPY == 'TRUE':
       infile = os.path.join(indir,
         '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))
    else:
       infile = os.path.join(indir,case,
         '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))

    if os.path.isfile(infile): # is file/variable available?
        print('reading %s'%(os.path.basename(infile)))
        fpin  = Nio.open_file(infile,'r')
        zt    = fpin.variables['z_t'][:] / 100.    # cm -> m
        zw    = fpin.variables['z_w'][:] / 100.    # cm -> m
        dz    = fpin.variables['dz'][:]  / 100.    # cm -> m
        area  = fpin.variables['TAREA'][:] * 1.e-4 # cm^2 -> m^2
        tlon  = fpin.variables['TLONG'][:]
        tlat  = fpin.variables['TLAT'][:]
        zind  = N.searchsorted(zt,100).item() # 100m index
        depth = zw[zind]
        variables[var]['fillvalue'] = fpin.variables[var]._FillValue[0]

        if fpin.variables[var][:].ndim == 3:   # 2-D field
            vars()[var] = fpin.variables[var][:]
        elif fpin.variables[var][:].ndim == 4: # 3-D field
            if 'FLUX_IN' in var:  # particle flux at 100 m
                vars()[var] = fpin.variables[var][:,zind,:,:]
            elif var in vintlist: # integrate vertically
                vars()[var] = fpin.variables[var][:]
                nz = vars()[var].shape[1]
                vars()[var] = MA.sum(vars()[var] *
                    dz[N.newaxis,:nz,N.newaxis,N.newaxis],1)
            else: # surface field
                vars()[var] = fpin.variables[var][:,0,:,:]
        else:
            print('Check %s dimensions'%(var))
            sys.exit()

        fpin.close()

        # compute temporal mean
        vars()[var] = vars()[var].mean(axis=0)

        # apply unit conversions if any
        if 'cfac' in variables[var]: 
            vars()[var] = vars()[var] * variables[var]['cfac']

        # Re-apply missing value to mask
        vars()[var] = MA.masked_values(vars()[var],variables[var]['fillvalue'])

        # compute annual totals and include them in plot labels
        if 'tcfac' in variables[var]:
            total = MA.sum(vars()[var] * area) * variables[var]['tcfac']
            if 'FLUX_IN' in var: # particle flux
                variables[var]['label'] = 'Total %s at %.0f m = %.2f %s'%(
                    variables[var]['slabel'],depth,total,variables[var]['tunits'])
            else: # vertical integrals
                variables[var]['label'] = 'Total %s = %.2f %s'%(
                    variables[var]['slabel'],total,variables[var]['tunits'])

            print('%s'%(variables[var]['label']))

        # compute min & max of annual (temporal) mean
        mdatamin = vars()[var].min()
        mdatamax = vars()[var].max()

        # compute spatial mean & R.M.S. of annual (temporal) mean

        mmask = MA.masked_values(vars()[var]/vars()[var],variables[var]['fillvalue'])

        mdatamean = MA.masked_values(MA.sum(vars()[var] * area * mmask) / MA.sum(area * mmask),
                    variables[var]['fillvalue'])

        mdatarms = MA.masked_values(MA.sqrt(MA.sum(vars()[var] * vars()[var] * area * mmask) / 
                    MA.sum(area * mmask)),variables[var]['fillvalue'])

        if POPDIAGPY == 'TRUE':
           variables[var]['title_mod'] = '%s: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
             variables[var]['slabel'],mdatamin,mdatamax,mdatamean,mdatarms)
        else:
           variables[var]['title_mod'] = variables[var]['label']

        # plot maps -----------------------------------------------------------
        if POPDIAGPY == 'TRUE':
           outfile = os.path.join(outdir,'map_%s.png'%(var))
        else:
           outfile = os.path.join(outdir,
            'map_%04d-%04d_%s.png'%(yrstart,yrend,var))
        print('plotting %s'%(os.path.basename(outfile)))
        if var in ['SSH','NO3_excess','FG_CO2','STF_O2','FvPER_DIC']:
            cmap = CyBuWhRdYl
        else:
            cmap = pl.cm.jet

        fig = pl.figure()
        ax  = fig.add_subplot(111)
        lon, lat, data = fix_pop_grid(tlon,tlat,vars()[var])
        map = Basemap(llcrnrlon=-330,urcrnrlon=30,llcrnrlat=-85,
            urcrnrlat=85,resolution='l',projection='cyl',ax=ax)
        map.drawcoastlines(linewidth=0.5)
        map.drawrivers(linewidth=0.75,color='white')
        map.drawparallels(N.arange(-90,120,30) ,labels=[0,0,0,0],linewidth=0.25)
        map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
        map.fillcontinents('white')
        x,y = map(lon,lat)
        CF  = map.contourf(x,y,data,variables[var]['clev'],cmap=cmap,
              norm=colors.BoundaryNorm(variables[var]['clev'],cmap.N),extend='both')
        CF.cmap.set_under('black')
        CF.cmap.set_over('black')
        CS  = map.contour(x,y,data,CF.levels,colors = 'k',linewidths = 0.25)
        CB  = fig.colorbar(CF,ax=ax,drawedges=True,shrink=0.5,aspect=12,
                ticks=variables[var]['clev'][1:-1],format='%G')
        CB.set_label(variables[var]['units'])
        for line in CB.ax.get_yticklines(): # remove tick lines
            line.set_markersize(0)

        bottom_labels(ax,case.replace('_',' '),'',year_string,fontsize=10)
        ax.set(title=variables[var]['title_mod'])
        fig.savefig(outfile,dpi=150,bbox_inches='tight',pad_inches=0.2)
        pl.close(fig)

#-----------------------------------------------------------------------------
