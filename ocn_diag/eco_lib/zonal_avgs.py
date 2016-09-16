# Plots seasonal cycle of global and regional zonal averages for selected
# variables. Matplotlib version.
# Created by Ivan Lima on Tue May 19 15:09:53 EDT 2009
# Last modified on Tue Sep 27 09:55:08 EDT 2011
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - choose directories (NCAR or WHOI),
#  - use resource file (dictionary),
#  - select model grid,

# Identical to zonal_avgs_2D.py except for the resource file.
# For plots of 2D variables use resource (dictionary) res_surface_2d.py
# For plots of 3D variables use resource (dictionary) res_vars_3d.py

# Reads input file:
#   za.'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output files: 
#   zavg_'var'_'reg_sname'.png
# or
#   zavg_'yrstart'-'yrend'_'var'_'reg_sname'.png


import numpy as N
import numpy.ma as MA
import os
import Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_utils import *
from res_vars_3D import *
from ccsm_utils import read_region_mask, read_region_mask_popdiag

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

#---------------------------------------------------------------------------

month_name = ['Jan','Feb','Mar','Apr','May','Jun',
              'Jul','Aug','Sep','Oct','Nov','Dec']

# set some plot resources
pl.rc('contour',negative_linestyle='solid') # solid negative contour lines
pl.rc('font',**{'size':14})

#---------------------------------------------------------------------------

year_string = '%.0f-%.0f'%(myrstart,myrend)

# variables to integrate vertically
vintlist = ['photoC_sp','photoC_diat','photoC_diaz','photoC_tot',
            'diaz_Nfix','CaCO3_form','bSi_form','NITRIF','DENITRIF']

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

mon = N.arange(12)+1

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
        lat  = fpin.variables['lat_t'][:]
        zt   = fpin.variables['z_t'][:] / 100. # cm -> m
        zw   = fpin.variables['z_w'][:] / 100. # cm -> m
        dz   = fpin.variables['dz'][:]  / 100. # cm -> m
        zind = N.searchsorted(zt,100).item() # 100m index
        depth = zw[zind]
        if fpin.variables[var][:].ndim == 3:   # 2-D field
            vars()[var] = fpin.variables[var][:,:,:]   # global zavgs
        elif fpin.variables[var][:].ndim == 4: # 3-D field
            if 'FLUX_IN' in var:
                vars()[var] = fpin.variables[var][:,:,zind,:] #global 100m zavgs
                variables[var]['label'] = '%s at %.2f m'%(variables[var]['slabel'],depth)
            elif var in vintlist: # global full depth zavgs
                vars()[var] = fpin.variables[var][:,:,:,:]
                nz = vars()[var].shape[2]
                # compute vertical integrals (X/m^3/year -> X/m^2/year)
                vars()[var] = (MA.sum(vars()[var] *
                    dz[N.newaxis,N.newaxis,:nz,N.newaxis],2))
            else:
                vars()[var] = fpin.variables[var][:,:,0,:] # global surf zavgs
        else:
            print('Check %s dimensions'%(var))
            sys.exit()

        # apply unit conversions if any
        if 'cfac' in variables[var]:
            vars()[var] = vars()[var] * variables[var]['cfac']
        # remove small negative values
        if 'FG_' not in var and 'STF_' not in var and var not in ['NO3_excess','TEMP',
                 'FvICE_DIC','FvPER_DIC']:
            vars()[var][vars()[var] < 0] = 0

        fpin.close()

        # plot figures --------------------------------------------------------
        if var in ['NO3_excess','FG_CO2','STF_O2','FvPER_DIC']:
            cmap = CyBuWhRdYl
        else:
            cmap = pl.cm.jet

        for r in range(nreg):
            if reg_lname[r] in region_list:
                if POPDIAGPY == 'TRUE':
                  outfile = os.path.join(outdir,'zavg_%s_%s.png'%(var,reg_sname[r]))
                else:
                  outfile = os.path.join(outdir,'zavg_%04d-%04d_%s_%s.png'%(
                    yrstart,yrend,var,reg_sname[r]))
                print('plotting %s'%(os.path.basename(outfile)))
                data = MA.transpose(vars()[var][:,r,:])

                fig = pl.figure()
                ax  = fig.add_subplot(111)

                if var in vintlist: # vertically integrated
                   CF  = ax.contourf(mon,lat,data,variables[var]['cklev'],cmap=cmap,
                           norm=colors.BoundaryNorm(variables[var]['cklev'],cmap.N),extend='both')
                   CF.cmap.set_under('black')
                   CF.cmap.set_over('black')
                   CS  = ax.contour(mon,lat,data,CF.levels,colors='k',
                           linewidths=0.25)
                   CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=15,
                       ticks=variables[var]['cklev'][1:-1],format='%G')
                   CB.set_label(variables[var]['kunits'])
                   for line in CB.ax.get_yticklines(): # remove tick lines
                       line.set_markersize(0)
                   titlestrn = '%s %s'%(reg_lname[r],variables[var]['klabel'])
                else:
                   CF  = ax.contourf(mon,lat,data,variables[var]['clev'],cmap=cmap,
                           norm=colors.BoundaryNorm(variables[var]['clev'],cmap.N),extend='both')
                   CF.cmap.set_under('black')
                   CF.cmap.set_over('black')
                   CS  = ax.contour(mon,lat,data,CF.levels,colors='k',
                           linewidths=0.25)
                   CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=15,
                       ticks=variables[var]['clev'][1:-1],format='%G')
                   CB.set_label(variables[var]['units'])
                   for line in CB.ax.get_yticklines(): # remove tick lines
                       line.set_markersize(0)
                   if 'FLUX_IN' in var:
                      titlestrn = '%s %s at %.2f m'%(reg_lname[r],variables[var]['slabel'],depth)
                   else:
                      titlestrn = '%s %s'%(reg_lname[r],variables[var]['slabel'])

                ax.set(xlim=(mon.min(),mon.max()),ylim=(lat.min(),lat.max()),
                        xlabel='month',ylabel='latitude')
                ##ax.set_xticks(mon,minor=True)
                ax.set_xticks(mon)
                ax.set_xticklabels(month_name,rotation=45,
                        horizontalalignment='right')
                top_labels(ax,case.replace('_',' '),'',year_string,fontsize=14)
                ax.text(0.5,1.1,titlestrn,horizontalalignment='center',
                        verticalalignment='bottom',transform=ax.transAxes,
                        fontsize=18)
                fig.savefig(outfile,dpi=100,bbox_inches='tight',pad_inches=0.8)
                pl.close(fig)

#-----------------------------------------------------------------------------
