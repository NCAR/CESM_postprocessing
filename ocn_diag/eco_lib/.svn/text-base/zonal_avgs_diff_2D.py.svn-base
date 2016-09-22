# Plots comparison of seasonal cycle of global and regional zonal averages 
# for selected variables. Matplotlib version.
# Based on zonal_avgs.py created by Ivan Lima on Tue May 19 15:09:53 EDT 2009
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - compare model experiment to control simulation,
#  - choose directories (NCAR or WHOI),
#  - use resource file (dictionary),
#  - select model grid.

# Identical to zonal_avgs_diff_2D.py except for the resource file.
# For plots of 2D variables use resource (dictionary) res_surface_2d.py
# For plots of 3D variables use resource (dictionary) res_vars_3d.py

# Reads input file:
#   za.'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output files: 
#   zavg_'var'_'reg_sname'_diff.png
# or
#   zavg_'yrstart'-'yrend'_'var'_'reg_sname'_diff.png

import numpy as N
import numpy.ma as MA
import os
import Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_utils import *
from res_surface_2D import *
from ccsm_utils import read_region_mask, read_region_mask_popdiag

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

#---------------------------------------------------------------------------

month_name = ['Jan','Feb','Mar','Apr','May','Jun',
              'Jul','Aug','Sep','Oct','Nov','Dec']

# set some plot resources
pl.rc('contour',negative_linestyle='solid') # solid negative contour lines
pl.rc('font',**{'size':14})

#-----------------------------------------------------------------------------
#---------------------------------------------------------------------------

# variables to integrate vertically
vintlist = ['photoC_sp','photoC_diat','photoC_diaz','photoC_tot',
            'diaz_Nfix','CaCO3_form','bSi_form','NITRIF','DENITRIF']

varlist = sorted(variables)

if POPDIAGPY == 'TRUE':
  reg_mask, nreg, reg_lname, reg_sname = read_region_mask_popdiag(mgridexp)
else:
  reg_mask, nreg, reg_lname, reg_sname = read_region_mask('gx1v6')

# add global to region names
reg_sname.insert(0,'glo')
reg_lname.insert(0,'Global')
nreg = nreg + 1

if POPDIAGPY == 'TRUE':
    expdir = WORKDIRPY
    cntrldir = WORKDIRPY
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

varsm = {}
varso = {}

# Read processed files
# read model data
for var in varlist:

     infile_exp = os.path.join(expdir,'za.%s.%s.clim.%.4d-%.4d.nc'%(
            case,var,yrstart,yrend))

     infile_cntrl = os.path.join(cntrldir,'za.%s.%s.clim.%.4d-%.4d.nc'%(
            cntrlcase,var,yr0cntrl,yr1cntrl))

# Open experiment file --------------------------------------------------------
     if os.path.isfile(infile_exp): # does file/variable exist?
        print('reading %s'%(os.path.basename(infile_exp)))
        fpmod = Nio.open_file(infile_exp,'r')
        lat  = fpmod.variables['lat_t'][:]
        zt   = fpmod.variables['z_t'][:] / 100. # cm -> m
        zw   = fpmod.variables['z_w'][:] / 100. # cm -> m
        dz   = fpmod.variables['dz'][:]  / 100. # cm -> m
        zind = N.searchsorted(zt,100).item() # 100m index
        depth = zw[zind]
        if fpmod.variables[var][:].ndim == 3:   # 2-D field
            varsm[var] = fpmod.variables[var][:,:,:]   # global zavgs
        elif fpmod.variables[var][:].ndim == 4: # 3-D field
            if 'FLUX_IN' in var:
                varsm[var] = fpmod.variables[var][:,:,zind,:] #global 100m zavgs
                variables[var]['label'] = '%s at %.2f m'%(variables[var]['slabel'],depth)
            elif var in vintlist: # global full depth zavgs
                varsm[var] = fpmod.variables[var][:,:,:,:]
                nz = varsm[var].shape[2]
                # compute vertical integrals (X/m^3/year -> X/m^2/year)
                varsm[var] = (MA.sum(varsm[var] *
                    dz[N.newaxis,N.newaxis,:nz,N.newaxis],2))
            else:
                varsm[var] = fpmod.variables[var][:,:,0,:] # global surf zavgs
        else:
            print('Check %s dimensions'%(var))
            sys.exit()

        # apply unit conversions if any
        if 'cfac' in variables[var]:
            varsm[var] = varsm[var] * variables[var]['cfac']
        # remove small negative values
        if 'FG_' not in var and 'STF_' not in var and var not in ['NO3_excess','TEMP',
                'FvICE_DIC','FvPER_DIC']:
            varsm[var][varsm[var] < 0] = 0

        fpmod.close()

# Open control file --------------------------------------------------------
     if os.path.isfile(infile_cntrl): # does file/variable exist?
        print('reading %s'%(os.path.basename(infile_cntrl)))
        fpobs = Nio.open_file(infile_cntrl,'r')
        lat  = fpobs.variables['lat_t'][:]
        zt   = fpobs.variables['z_t'][:] / 100. # cm -> m
        zw   = fpobs.variables['z_w'][:] / 100. # cm -> m
        dz   = fpobs.variables['dz'][:]  / 100. # cm -> m
        zind = N.searchsorted(zt,100).item() # 100m index
        depth = zw[zind]
        if fpobs.variables[var][:].ndim == 3:   # 2-D field
            varso[var] = fpobs.variables[var][:,:,:]   # global zavgs
        elif fpobs.variables[var][:].ndim == 4: # 3-D field
            if 'FLUX_IN' in var:
                varso[var] = fpobs.variables[var][:,:,zind,:] #global 100m zavgs
                variables[var]['label'] = '%s at %.2f m'%(variables[var]['slabel'],depth)
            elif var in vintlist: # global full depth zavgs
                varso[var] = fpobs.variables[var][:,:,:,:]
                nz = varso[var].shape[2]
                # compute vertical integrals (X/m^3/year -> X/m^2/year)
                varso[var] = (MA.sum(varso[var] *
                    dz[N.newaxis,N.newaxis,:nz,N.newaxis],2))
            else:
                varso[var] = fpobs.variables[var][:,:,0,:] # global surf zavgs
        else:
            print('Check %s dimensions'%(var))
            sys.exit()

        # apply unit conversions if any
        if 'cfac' in variables[var]:
            varso[var] = varso[var] * variables[var]['cfac']
        # remove small negative values
        if 'FG_' not in var and 'STF_' not in var and var not in ['NO3_excess','TEMP',
                'FvICE_DIC','FvPER_DIC']:
            varso[var][varso[var] < 0] = 0

        fpobs.close()

        # plot figures --------------------------------------------------------
        cmapdiff = CyBuWhRdYl

        if var in ['NO3_excess','FG_CO2','STF_O2','FvPER_DIC']:
            cmap = CyBuWhRdYl
        else:
            cmap = pl.cm.jet

        for r in range(nreg):
            if reg_lname[r] in region_list:
                if POPDIAGPY == 'TRUE':
                  outfile = os.path.join(outdir,'zavg_%s_%s_diff.png'%(var,reg_sname[r]))
                else:
                  outfile = os.path.join(outdir,'zavg_%04d-%04d_%s_%s_diff.png'%(
                    yrstart,yrend,var,reg_sname[r]))
                print('plotting %s'%(os.path.basename(outfile)))
                datam = MA.transpose(varsm[var][:,r,:])
                datao = MA.transpose(varso[var][:,r,:])

                # calculate difference ------------------------------------------
                differnce = datam - datao

                # plot ----------------------------------------------------------

                fig = pl.figure(figsize=(8,11))

                # plot experiment ------------------------------------------------
                ax  = fig.add_subplot(211)
                CF  = ax.contourf(mon,lat,datam,variables[var]['clev'],cmap=cmap,
                        norm=colors.BoundaryNorm(variables[var]['clev'],cmap.N),extend='both')
		CF.cmap.set_under('black')
		CF.cmap.set_over('black')
                CS  = ax.contour(mon,lat,datam,CF.levels,colors='k',
                        linewidths=0.25)
                CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=15,
                    ticks=variables[var]['clev'][1:-1],format='%G')
                CB.set_label(variables[var]['units'])
                for line in CB.ax.get_yticklines(): # remove tick lines
                    line.set_markersize(0)

                ax.set(xlim=(mon.min(),mon.max()),ylim=(lat.min(),lat.max()),
                        xlabel='',ylabel='latitude',xticklabels='')
                ##ax.set_xticks(mon,minor=True)
                ax.set_xticks(mon)
#               ax.set_xticklabels(month_name,rotation=45,horizontalalignment='right')
                top_labels(ax,'Exp:',case.replace('_',' '),year_string_exp,fontsize=14)
                bottom_labels(ax,'Control:',cntrlcase.replace('_',' '),year_string_cnt,fontsize=14)
                titlestrn = '%s %s from Experiment'%(reg_lname[r],variables[var]['slabel'])
                ax.text(0.5,1.1,titlestrn,horizontalalignment='center',
                        verticalalignment='bottom',transform=ax.transAxes,
                        fontsize=16)

                # plot experiment - control ------------------------------------------------
                ax  = fig.add_subplot(212)
                CF  = ax.contourf(mon,lat,differnce,variables[var]['dlev'],cmap=cmapdiff,
                        norm=colors.BoundaryNorm(variables[var]['dlev'],cmapdiff.N),extend='both')
		CF.cmap.set_under('black')
		CF.cmap.set_over('black')
                CS  = ax.contour(mon,lat,differnce,CF.levels,colors='k',
                        linewidths=0.25)
                CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=15,
                    ticks=variables[var]['dlev'][1:-1],format='%G')
                CB.set_label(variables[var]['units'])
                for line in CB.ax.get_yticklines(): # remove tick lines
                    line.set_markersize(0)

                ax.set(xlim=(mon.min(),mon.max()),ylim=(lat.min(),lat.max()),
                        xlabel='month',ylabel='latitude')
                ##ax.set_xticks(mon,minor=True)
                ax.set_xticks(mon)
                ax.set_xticklabels(month_name,rotation=45,
                        horizontalalignment='right')
#               titlestrn = '%s %s'%(reg_lname[r],variables[var]['label'])
                titlestrn = 'Experiment-Control'
                top_labels(ax,'',titlestrn,'',fontsize=14)
#               ax.text(0.5,1.1,titlestrn,horizontalalignment='center',
#                       verticalalignment='bottom',transform=ax.transAxes,
#                       fontsize=16)

                fig.savefig(outfile,dpi=100,bbox_inches='tight',pad_inches=0.8)
                pl.close(fig)

#-----------------------------------------------------------------------------
