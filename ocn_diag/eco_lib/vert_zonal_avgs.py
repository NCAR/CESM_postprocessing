# Plots vertical profiles of global and regional zonal averages for selected
# variables. Matplotlib version. 
# Based on vert_sections.py created by Ivan Lima on Thu Dec 16 10:12:37 EST 2004
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - do zonal averages,
#  - use resource file (dictionary),
#  - calculate minimum and maximum,

# Reads input file:
#   za.'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output files: 
#   zavg_xsect_'var'_'reg_sname'.png
# or:
#   zavg_xsect_'yrstart'-'yrend'_'var'_'reg_sname'.png

import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_utils import *
from res_at_depths_wFe import *
from ccsm_utils import read_region_mask, read_region_mask_popdiag
from scipy.interpolate import interp1d

case      = raw_input('Enter case: \n')
yrstart   = int(raw_input('Enter start year: \n'))
yrend     = int(raw_input('Enter end year: \n'))
POPDIAGPY = raw_input('Enter TRUE or FALSE: \n')
yroffset  = int(raw_input('Enter offset: \n'))
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

#---------------------------------------------------------------------------

# set some plot resources
pl.rc('contour',negative_linestyle='solid') # make negative contour lines solid
pl.rc('font',**{'size':14})

#---------------------------------------------------------------------------

varlist = sorted(variables)

if POPDIAGPY == 'TRUE':
  reg_mask, nreg, reg_lname, reg_sname = read_region_mask_popdiag(mgrid)
else:
  reg_mask, nreg, reg_lname, reg_sname = read_region_mask('gx1v6')

# add global to region names
reg_sname.insert(0,'glo')
reg_lname.insert(0,'Global')
nreg = nreg + 1

if POPDIAGPY == 'TRUE':
    indir = WORKDIRPY
    outdir = WORKDIRPY
else:
    indir  = '/bonaire/data2/ivan/ccsm_output'
    outdir = '/fiji/home/ivan/www/ccsm_log/cases/%s/plots'%case

# create directory for plots if necessary
if (not os.path.isdir(outdir)):
    os.makedirs(outdir)
print('Saving plots in %s'%(outdir))

# regions to plot
region_list = ['Global','Southern Ocean','Pacific Ocean','Indian Ocean',
               'Atlantic Ocean', 'Arctic Ocean']

dataout = {}

# Read processed files
# read model data
for var in varlist:

     if POPDIAGPY == 'TRUE':
         infile = os.path.join(indir,'za.%s.%s.clim.%.4d-%.4d.nc'%
                (case,var,yrstart,yrend))
     else:
         infile = os.path.join(indir,case,'za.%s.%s.clim.%.4d-%.4d.nc'%
                (case,var,yrstart,yrend))

     if os.path.isfile(infile): # does file/variable exist?
        print('reading %s'%(os.path.basename(infile)))
        fpin = Nio.open_file(infile,'r')
        nz   = fpin.dimensions['z_t']
        lat  = fpin.variables['lat_t'][:]
        zt   = fpin.variables['z_t'][:] / 100. # cm -> m
        zw   = fpin.variables['z_w'][:] / 100. # cm -> m
        dz   = fpin.variables['dz'][:]  / 100. # cm -> m
        zind = N.searchsorted(zt,100).item() # 100m index
        depth = zw[zind]
        if fpin.variables[var][:].ndim == 4: # 3-D field
           vars()[var] = fpin.variables[var][:]
           print 'dim1:%s, dim2:%s, dim3:%s, dim4:%s' %(vars()[var].shape[0],
                 vars()[var].shape[1],vars()[var].shape[2],vars()[var].shape[3])
        else:
           print('Check %s dimensions'%(var))
           sys.exit()

        # compute temporal mean
        vars()[var] = vars()[var].mean(axis=0)

        print 'dim1:%s, dim2:%s, dim3:%s' %(vars()[var].shape[0],
              vars()[var].shape[1],vars()[var].shape[2])

        # apply unit conversions if any
        if 'cfac' in variables[var]:
           vars()[var] = vars()[var] * variables[var]['cfac']

        fpin.close()

        # plot figures --------------------------------------------------------

        cmap = pl.cm.jet

        if vars()[var].shape[1] == nz: # indices coords
           zlev = -N.arange(len(zt))
           f    = interp1d(zt,zlev)
           zlab = N.array([50,100,200,500,1000,2000,3000,4000,5000])
           ztic = f(zlab)
        else:
           print 'Check dimensions for %s.'%(var)
           sys.exit()

        for r in range(nreg):

           dataout = vars()[var][r,:,:]

           mdatamin = dataout.min()
           mdatamax = dataout.max()

           print 'dataout dim1:%s, dim2:%s' %(dataout.shape[0],dataout.shape[1])

           if reg_lname[r] in region_list:
              if POPDIAGPY == 'TRUE':
                outfile = os.path.join(outdir,'zavg_xsect_%s_%s.png'%(var,reg_sname[r]))
              else:
                outfile = os.path.join(outdir,'zavg_xsect_%04d-%04d_%s_%s.png'%(
                     yrstart,yrend,var,reg_sname[r]))

              print('plotting %s'%(os.path.basename(outfile)))

              # plot sections -------------------------------------------------------

              fig  = pl.figure()
              ax   = fig.add_subplot(111)
              CF = ax.contourf(lat,zlev,dataout,variables[var]['clev'],
                   norm=colors.BoundaryNorm(variables[var]['clev'],cmap.N),
                   cmap=cmap,extend='both')
              CF.cmap.set_under('black')
              CF.cmap.set_over('black')
              CS = ax.contour(lat,zlev,dataout,CF.levels,colors = 'k',
                      linewidths=0.25)
              CB = fig.colorbar(CF,ax = ax,drawedges = True,aspect = 15,
                  ticks=variables[var]['clev'][1:-1],format='%G')
              CB.set_label(variables[var]['units'])
              for line in CB.ax.get_yticklines(): # remove tick lines
                  line.set_markersize(0)

              ax.set(xlim=(lat.min(),lat.max()),ylim=(zlev.min(),zlev.max()),
                      xlabel='latitude',ylabel='depth (m)',
                      yticks=ztic,yticklabels=zlab)
              top_labels(ax,case.replace('_',' '),'',year_string,fontsize=14)
              titlestrn = '%s %s: Min:%.2f, Max:%.2f'%(
                  reg_lname[r],variables[var]['slabel'],mdatamin,mdatamax)

              ax.text(0.5,1.1,titlestrn,horizontalalignment='center',
                      verticalalignment='bottom',transform=ax.transAxes,
                      fontsize=16)
              fig.savefig(outfile,dpi=100,bbox_inches='tight',pad_inches=0.8)
              pl.close(fig)

#------------------------------------------------------------------------------
