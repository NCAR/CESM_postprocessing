# Maps of comparisons between model experiment and control simulations at various depths.
# Based on model_obs_maps.py created by Ivan Lima on Thu Nov 18 11:21:53 EST 2010
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - compare experiment to control and calculate difference,
#  - read resource file (dictionary),
#  - process various depths given by plot.dat,
#  - compute maximum, minimum, spatial mean, and root-mean-square,
#  - consider different color scales for different depth ranges,

# Reads input files: 
#  'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output files:
#   map_'var'_'zdpth'm_diff.png
# or:
#   map_'yrstart'-'yrend'_'var'_z_'zdpth'm_diff.png'

import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_toolkits.basemap import Basemap
from mpl_utils import *
from res_at_depths_wFe import *

case       = raw_input('Enter Experiment: \n')
yrstart    = int(raw_input('Enter start year Experiment: \n'))
yrend      = int(raw_input('Enter end year Experiment: \n'))
cntrlcase  = raw_input('Enter Control: \n')
yr0cntrl   = int(raw_input('Enter start year Control: \n'))
yr1cntrl   = int(raw_input('Enter end year Control: \n'))
POPDIAGPY  = raw_input('Enter TRUE or FALSE: \n')
yroffset   = int(raw_input('Enter year offset: \n'))
WORKDIRPY  = raw_input('Enter WORKDIR: \n')
mgridexp   = raw_input('Enter case grid/resolution: \n')
mgridcntrl = raw_input('Enter control grid/resolution: \n')

# Example:
# case    = 'b40.20th.1deg.bdrd.001'
# yrstart = 1991
# yrend   = 1995

# get simulation year
if POPDIAGPY == 'TRUE':
   eyrstart = yroffset + yrstart
   eyrend   = yroffset + yrend
   cyrstart = yroffset + yr0cntrl
   cyrend   = yroffset + yr1cntrl
   year_string_exp = '[%.0f-%.0f]'%(eyrstart,eyrend)
   year_string_cnt = '[%.0f-%.0f]'%(cyrstart,cyrend)
else:
   myrstart = yrstart - 181 + 1948
   myrend   = yrend   - 181 + 1948
   year_string_exp = '[%.0f-%.0f]'%(myrstart,myrend)

# set some plot resources
pl.rc('font',**{'size':10})
pl.rc('contour',negative_linestyle='solid') # solid negative contour lines

# get variables to read
varlist = sorted(variables)

# indir: where processed files are located
# outdir: where plots are saved
if POPDIAGPY == 'TRUE':
    expdir = WORKDIRPY
    cntrldir = WORKDIRPY
    outdir = WORKDIRPY
else:
    indir = '/bonaire/data2/ivan/ccsm_output'
    outdir = '/fiji/home/ivan/www/ccsm_log/cases/%s/plots'%case

# Get plots directory ready
if (not os.path.isdir(outdir)):
    os.makedirs(outdir)
print('Plots saved in %s'%(outdir))

# Get the depths to plot
#dpthsfile = os.path.join(expdir,'plot.dat')
dpthsfile = os.path.join(expdir,'plot_depths.dat')
print('Reading %s'%(os.path.basename(dpthsfile)))
fzin = open(dpthsfile,'r')
# Make sure the depths only are being used

for line in fzin.readlines():
    dpthsin = map(int,line.split(','))

print('Depths are:')
print dpthsin[0:len(dpthsin)]
print('')

varsm = {}
varso = {}

    # Read processed files
    # read model data
for var in varlist:
    if POPDIAGPY == 'TRUE':
         infile_exp = os.path.join(expdir,'%s.%s.clim.%04d-%04d.nc'%
            (case,var,yrstart,yrend))
         infile_cntrl = os.path.join(cntrldir,'%s.%s.clim.%04d-%04d.nc'%
            (cntrlcase,var,yr0cntrl,yr1cntrl))
    else:
         infile = os.path.join(indir,case,
          '%s.%s.clim.%04d-%04d.nc'%(case,var,yrstart,yrend))

# Open experiment file ----------------------------------------------------
    if os.path.isfile(infile_exp): # is file/variable available?
         print('reading %s'%(os.path.basename(infile_exp)))
         fpin  = Nio.open_file(infile_exp,'r')
         ztm   = fpin.variables['z_t'][:] / 100.    # cm -> m
         dzm   = fpin.variables['dz'][:]  / 100.    # cm -> m
         aream = fpin.variables['TAREA'][:] * 1.e-4 # cm^2 -> m^2
         tlonm = fpin.variables['TLONG'][:]
         tlatm = fpin.variables['TLAT'][:]

# Open control file ----------------------------------------------------
    if os.path.isfile(infile_cntrl): # is file/variable available?
         print('reading %s'%(os.path.basename(infile_cntrl)))
         fpon  = Nio.open_file(infile_cntrl,'r')
         zto   = fpon.variables['z_t'][:] / 100.    # cm -> m
         dzo   = fpon.variables['dz'][:]  / 100.    # cm -> m
         areao = fpon.variables['TAREA'][:] * 1.e-4 # cm^2 -> m^2
         tlono = fpon.variables['TLONG'][:]
         tlato = fpon.variables['TLAT'][:]

        # Depth loop -------------------------------------
         for kz in range(len(dpthsin)):
              zdpth  = dpthsin[kz]

        #-- Read experiment file -------------------------------------
              zindm  = N.searchsorted(ztm,zdpth).item() # 100m index
              depthm = int(ztm[zindm])

              if fpin.variables[var][:].ndim == 3:   # 2-D field
                  varsm[var] = fpin.variables[var][:]
              elif fpin.variables[var][:].ndim == 4: # 3-D field
                      varsm[var] = fpin.variables[var][:,zindm,:,:]
              else:
                  print('Check %s dimensions'%(var))
                  sys.exit()

        # compute temporal mean (for experiment)
              varsm[var] = varsm[var].mean(axis=0)
              if 'cfac' in variables[var]: # apply unit conversions if any
                  varsm[var] = varsm[var] * variables[var]['cfac']

              variables[var]['label2'] = '%s at %.0f m Exp:'%(
                  variables[var]['label'],depthm)
              print('Plotting %s'%(variables[var]['label2']))

        # compute max & min
              mdatamin = varsm[var].min()
              mdatamax = varsm[var].max()

        # compute mean & rms
              mdatamean = MA.sum(varsm[var] * aream) / MA.sum(aream)
              mdatarms = MA.sqrt(MA.sum(varsm[var] * varsm[var] * aream) / MA.sum(aream))

              variables[var]['title_exp'] = '%s at %.0f m Exp: Min:%.2f, Max:%.2f, Mean:%.1f, RMS:%.1f'%(
                  variables[var]['label'],depthm,mdatamin,mdatamax,mdatamean,mdatarms)

        #-- Read control file -------------------------------------
              zindo = N.searchsorted(zto,zdpth).item() # 100m index
              deptho = int(zto[zindo])

              if fpon.variables[var][:].ndim == 3:   # 2-D field
                  varso[var] = fpon.variables[var][:]
              elif fpon.variables[var][:].ndim == 4: # 3-D field
                      varso[var] = fpon.variables[var][:,zindo,:,:]
              else:
                  print('Check %s dimensions'%(var))
                  sys.exit()

        # compute temporal mean (for control)
              varso[var] = varso[var].mean(axis=0)
              if 'cfac' in variables[var]: # apply unit conversions if any
                  varso[var] = varso[var] * variables[var]['cfac']

              variables[var]['label3'] = '%s at %.0f m '%(
                  variables[var]['label'],deptho)
              print('Plotting %s'%(variables[var]['label3']))

        # plot maps -----------------------------------------------------------
              if POPDIAGPY == 'TRUE':
                  outfile = os.path.join(outdir,'map_%s_%sm_diff.png'%(var,zdpth))
              else:
                  outfile = os.path.join(outdir,
                  'map_%04d-%04d_%s_z_%sm_diff.png'%(yrstart,yrend,var,zdpth))
              print('plotting %s'%(os.path.basename(outfile)))

              cmap = pl.cm.jet
              cmapdiff = CyBuWhRdYl

              fig = pl.figure()

        # plot experiment -----------------------------------------------------------
              ax  = fig.add_subplot(211)
              lon, lat, datam = fix_pop_grid(tlonm,tlatm,varsm[var])
              map = Basemap(llcrnrlon=-330,urcrnrlon=30,llcrnrlat=-85,
                  urcrnrlat=85,resolution='l',projection='cyl',ax=ax)
              map.drawcoastlines(linewidth=0.5)
              map.drawrivers(linewidth=0.75,color='lightgrey')
              map.drawparallels(N.arange(-90,120,30) ,labels=[0,0,0,0],linewidth=0.25)
              map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
              map.fillcontinents('lightgrey')
              x,y = map(lon,lat)

              CF  = map.contourf(x,y,datam,variables[var]['clev'],cmap=cmap,
                    norm=colors.BoundaryNorm(variables[var]['clev'],cmap.N),extend='both')
              CF.cmap.set_under('black')
              CF.cmap.set_over('black')
              CS  = map.contour(x,y,datam,CF.levels,colors = 'k',linewidths = 0.25)
              CB  = fig.colorbar(CF,ax=ax,drawedges=True,shrink=0.8,aspect=11,
                      ticks=variables[var]['clev'][1:-1],format='%G')
              CB.set_label(variables[var]['units'])
              for line in CB.ax.get_yticklines(): # remove tick lines
                  line.set_markersize(0)

              bottom_labels(ax,'Experiment:',case.replace('_',' '),year_string_exp,fontsize=10)
#             ax.set(title=variables[var]['label2'])
              ax.set(title=variables[var]['title_exp'])

        # plot experiment - control ------------------------------------------------
              ax  = fig.add_subplot(212)
              lon, lat, datao = fix_pop_grid(tlono,tlato,varso[var])
              differnce = datam - datao

        # compute max & min
              odatamin = differnce.min()
              odatamax = differnce.max()

        # compute mean & rms
              odatamean = MA.sum(varsm[var] * areao) / MA.sum(areao)
              odatarms = MA.sqrt(MA.sum(varsm[var] * varsm[var] * areao) / MA.sum(areao))

              variables[var]['title_cntrl'] = 'Exp-Con: Min:%.2f, Max:%.2f, Mean:%.1f, RMS:%.1f'%(
                  odatamin,odatamax,odatamean,odatarms)

        # do plot
              map = Basemap(llcrnrlon=-330,urcrnrlon=30,llcrnrlat=-85,
                  urcrnrlat=85,resolution='l',projection='cyl',ax=ax)
              map.drawcoastlines(linewidth=0.5)
              map.drawrivers(linewidth=0.75,color='lightgrey')
              map.drawparallels(N.arange(-90,120,30) ,labels=[0,0,0,0],linewidth=0.25)
              map.drawmeridians(N.arange(-720,750,30),labels=[0,0,0,0],linewidth=0.25)
              map.fillcontinents('lightgrey')
              x,y = map(lon,lat)

              CF  = map.contourf(x,y,differnce,variables[var]['dlev'],cmap=cmapdiff,
                    norm=colors.BoundaryNorm(variables[var]['dlev'],cmapdiff.N),extend='both')
              CF.cmap.set_under('black')
              CF.cmap.set_over('black')
              CS  = map.contour(x,y,differnce,CF.levels,colors = 'k',linewidths = 0.25)
              CB  = fig.colorbar(CF,ax=ax,drawedges=True,shrink=0.8,aspect=11,
                      ticks=variables[var]['dlev'][1:-1],format='%G')
              CB.set_label(variables[var]['units'])
              for line in CB.ax.get_yticklines(): # remove tick lines
                  line.set_markersize(0)

              bottom_labels(ax,'Control:',cntrlcase.replace('_',' '),year_string_cnt,fontsize=10)
#             ax.set(title='Experiment - Control')
              ax.set(title=variables[var]['title_cntrl'])

              fig.savefig(outfile,dpi=150,bbox_inches='tight',pad_inches=0.2)

              pl.close(fig)

         print('closing %s'%(os.path.basename(infile_exp)))
         fpin.close()

         print('closing %s'%(os.path.basename(infile_cntrl)))
         fpon.close()

#-----------------------------------------------------------------------------
