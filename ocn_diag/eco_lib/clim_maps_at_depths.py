# Plot maps of climatological means of selected variables. If more than one
# case is given it plots the map for the fist case and the difference with
# respect to the second case entered. Modified to process output from couple
# ocean-ice runs on the gx1v6 grid. Matplotlib version.
# Based on clim_maps.py created by Ivan Lima on Mon Nov  8 14:30:01 EST 2010
# Modified by Ernesto Munoz and finalized on Dec 7 2012 to:
#  - process various depths indicated by plot.dat,
#  - use "dictionary" or resource file,
#  - choose directories (NCAR or WHOI),
#  - compute minimum, maximum, spatial mean, and root-mean-square,
#  - consider different colorscales for different depth ranges,

# Reads input file: 
#  'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output file:
#   map_'var'_'depth'.png
# or:
#   'map_'yrstart'-'yrend'_'var'_z_'depth'm.png'


import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from mpl_utils import *
from res_at_depths_wFe import *

case      = raw_input('Enter case(s): \n')
yrstart   = int(raw_input('Enter starting year: \n'))
yrend     = int(raw_input('Enter ending year: \n'))
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

# set some plot resources
pl.rc('font',**{'size':10})
pl.rc('contour',negative_linestyle='solid') # solid negative contour lines

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

# Get the depths to plot
#dpthsfile = os.path.join(indir,'plot.dat')
dpthsfile = os.path.join(indir,'plot_depths.dat')
print('Reading %s'%(os.path.basename(dpthsfile)))
fzin = open(dpthsfile,'r')
# Make sure only the depths are being used

for line in fzin.readlines():
    dpthsin = map(int,line.split(','))

print('Depths are:')
print dpthsin[0:len(dpthsin)]
print('')

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
         dz    = fpin.variables['dz'][:]  / 100.    # cm -> m
         area  = fpin.variables['TAREA'][:] * 1.e-4 # cm^2 -> m^2
         tlon  = fpin.variables['TLONG'][:]
         tlat  = fpin.variables['TLAT'][:]
         variables[var]['fillvalue'] = fpin.variables[var]._FillValue[0]

         for kz in range(len(dpthsin)):
              zdpth = dpthsin[kz]
              zind  = N.searchsorted(zt,zdpth).item() # 100m index
              depth = int(zt[zind])

              variables[var]['label2'] = '%s at %.0f m '%(variables[var]['slabel'],depth)

              print('Plotting %s'%(variables[var]['label2']))

              if fpin.variables[var][:].ndim == 3:   # 2-D field
                  vars()[var] = fpin.variables[var][:]
              elif fpin.variables[var][:].ndim == 4: # 3-D field
                  vars()[var] = fpin.variables[var][:,zind,:,:]
              else:
                  print('Check %s dimensions'%(var))
                  sys.exit()

              # compute temporal mean
              vars()[var] = vars()[var].mean(axis=0)
              if 'cfac' in variables[var]: # apply unit conversions if any
                  vars()[var] = vars()[var] * variables[var]['cfac']

              vars()[var] = MA.masked_values(vars()[var],variables[var]['fillvalue'])

              # compute min & max
              mdatamin = vars()[var].min()
              mdatamax = vars()[var].max()

              # compute spatial mean & R.M.S. of annual (temporal) mean
              mmask = MA.masked_values(vars()[var]/vars()[var],variables[var]['fillvalue'])

              mdatamean = MA.masked_values(MA.sum(vars()[var]*area*mmask)/MA.sum(area*mmask),
                          variables[var]['fillvalue'])

              mdatarms = MA.masked_values(MA.sqrt(MA.sum(vars()[var]*vars()[var]*area*mmask)/
                         MA.sum(area*mmask)),variables[var]['fillvalue'])

              variables[var]['title_mod'] = '%s: Min:%.2f, Max:%.2f, Mean:%.2f, RMS:%.2f '%(
                     variables[var]['label2'],mdatamin,mdatamax,mdatamean,mdatarms)

        # plot maps -----------------------------------------------------------
              if POPDIAGPY == 'TRUE':
                  outfile = os.path.join(outdir,'map_%s_%sm.png'%(var,zdpth))
              else:
                  outfile = os.path.join(outdir,
                  'map_%04d-%04d_%s_z_%sm.png'%(yrstart,yrend,var,depth))
              print('plotting %s'%(os.path.basename(outfile)))

              cmap = pl.cm.jet

              fig = pl.figure()
              ax  = fig.add_subplot(111)
              lon, lat, data = fix_pop_grid(tlon,tlat,vars()[var])
              map = Basemap(llcrnrlon=-330,urcrnrlon=30,llcrnrlat=-85,
                  urcrnrlat=85,resolution='l',projection='cyl',ax=ax)
              map.drawcoastlines(linewidth=0.5)
              map.drawrivers(linewidth=0.75,color='lightgrey')
              map.drawparallels(N.arange(-90,120,30) ,labels=[0,0,0,0],linewidth=0.25)
              map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
              map.fillcontinents('lightgrey')
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
              if POPDIAGPY == 'TRUE':
                ax.set(title=variables[var]['title_mod'])
              else:
                ax.set(title=variables[var]['label2'])
              fig.savefig(outfile,dpi=150,bbox_inches='tight',pad_inches=0.2)
              pl.close(fig)

         print('closing %s'%(os.path.basename(infile)))
         fpin.close()

#-----------------------------------------------------------------------------
