# Plots vertical profile of global and regional zonal averages for selected
# variables. Compares experiment to control.
# Based on vert_sections.py created by Ivan Lima on Thu Dec 16 10:12:37 EST 2004
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - compare experiment to control and calculate difference,
#  - do zonal averages,
#  - use resource file (dictionary),
#  - calculate minimum and maximum,

# Reads input file:
#   za.'case'.'var'.clim.'yrstart'-'yrend'.nc

# Creates output files: 
#   zavg_xsect_'var'_'reg_sname'_diff.png
# or
#   zavg_xsect_'yrstart'-'yrend'_'var'_'reg_sname'_diff.png


import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
from matplotlib import colors
from mpl_utils import *
from res_at_depths_wFe import *
from ccsm_utils import read_region_mask, read_region_mask_popdiag
from scipy.interpolate import interp1d

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

# set some plot resources
pl.rc('contour',negative_linestyle='solid') # solid negative contour lines
pl.rc('font',**{'size':14})

#-----------------------------------------------------------------------------

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

varsm = {}
varso = {}
dataout = {}

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
        nz   = fpmod.dimensions['z_t']
        lat  = fpmod.variables['lat_t'][:]
        zt   = fpmod.variables['z_t'][:] / 100. # cm -> m
        zw   = fpmod.variables['z_w'][:] / 100. # cm -> m
        dz   = fpmod.variables['dz'][:]  / 100. # cm -> m
        zind = N.searchsorted(zt,100).item()    # 100m index
        depth = zw[zind]

        varsm[var] = fpmod.variables[var][:]

        if fpmod.variables[var][:].ndim == 4:    # monthly climatology
           print 'dim1:%s, dim2:%s, dim3:%s, dim4:%s' %(varsm[var].shape[0],
                 varsm[var].shape[1],varsm[var].shape[2],varsm[var].shape[3])
           # compute temporal mean
           varsm[var] = varsm[var].mean(axis=0)
        elif fpmod.variables[var][:].ndim == 3:  # annual average
           print 'dim1:%s, dim2:%s, dim3:%s' %(varsm[var].shape[0],
                 varsm[var].shape[1],varsm[var].shape[2])
        else:
           print('Check %s dimensions'%(var))
           sys.exit()

        # apply unit conversions if any
        if 'cfac' in variables[var]:
            varsm[var] = varsm[var] * variables[var]['cfac']

        fpmod.close()

# Open control file --------------------------------------------------------
     if os.path.isfile(infile_cntrl): # does file/variable exist?
        print('reading %s'%(os.path.basename(infile_cntrl)))
        fpobs = Nio.open_file(infile_cntrl,'r')
        nz   = fpobs.dimensions['z_t']
        lat  = fpobs.variables['lat_t'][:]
        zt   = fpobs.variables['z_t'][:] / 100. # cm -> m
        zw   = fpobs.variables['z_w'][:] / 100. # cm -> m
        dz   = fpobs.variables['dz'][:]  / 100. # cm -> m
        zind = N.searchsorted(zt,100).item()    # 100m index
        depth = zw[zind]

        varso[var] = fpobs.variables[var][:] 

        if fpobs.variables[var][:].ndim == 4:   # 3-D field
           print 'dim1:%s, dim2:%s, dim3:%s, dim4:%s' %(varso[var].shape[0],
                 varso[var].shape[1],varso[var].shape[2],varso[var].shape[3])
           # compute temporal mean
           varso[var] = varso[var].mean(axis=0)
           print 'Dims after t-avg: dim1:%s, dim2:%s, dim3:%s' %(varso[var].shape[0],
                 varso[var].shape[1],varso[var].shape[2])
        else:
           print('Check %s dimensions'%(var))
           sys.exit()

        # apply unit conversions if any
        if 'cfac' in variables[var]:
            varso[var] = varso[var] * variables[var]['cfac']

        fpobs.close()

        # plot figures --------------------------------------------------------
        cmapdiff = CyBuWhRdYl

        if var in ['NO3_excess','FG_CO2','STF_O2','FvPER_DIC']:
            cmap = CyBuWhRdYl
        else:
            cmap = pl.cm.jet

        if varsm[var].shape[1] == nz: # indices coords
           zlev = -N.arange(len(zt))
           f    = interp1d(zt,zlev)
           zlab = N.array([50,100,200,500,1000,2000,3000,4000,5000])
           ztic = f(zlab)
        else:
           print 'Check dimensions for %s.'%(var)
           sys.exit()

        for r in range(nreg):

            datamod = varsm[var][r,:,:]
            dataobs = varso[var][r,:,:]

            mdatamin = datamod.min()
            mdatamax = datamod.max()

            print 'datamod dim1:%s, dim2:%s' %(datamod.shape[0],datamod.shape[1])
            print 'dataobs dim1:%s, dim2:%s' %(dataobs.shape[0],dataobs.shape[1])

            if reg_lname[r] in region_list:
                if POPDIAGPY == 'TRUE':
                  outfile = os.path.join(outdir,'zavg_xsect_%s_%s_diff.png'%(var,reg_sname[r]))
                else:
                  outfile = os.path.join(outdir,'zavg_xsect_%04d-%04d_%s_%s_diff.png'%(
                    yrstart,yrend,var,reg_sname[r]))
                print('plotting %s'%(os.path.basename(outfile)))

                # calculate difference ------------------------------------------
                differnce = datamod - dataobs

                odatamin = differnce.min()
                odatamax = differnce.max()

                # plot ----------------------------------------------------------

                fig = pl.figure(figsize=(8,11))

                # plot experiment ------------------------------------------------
                ax  = fig.add_subplot(211)
                CF  = ax.contourf(lat,zlev,datamod,variables[var]['clev'],cmap=cmap,
                      norm=colors.BoundaryNorm(variables[var]['clev'],cmap.N),extend='both')
		CF.cmap.set_under('black')
		CF.cmap.set_over('black')
                CS  = ax.contour(lat,zlev,datamod,CF.levels,colors='k',
                      linewidths=0.25)
                CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=15,
                      ticks=variables[var]['clev'][1:-1],format='%G')
                CB.set_label(variables[var]['units'])
                for line in CB.ax.get_yticklines(): # remove tick lines
                    line.set_markersize(0)

                ax.set(xlim=(lat.min(),lat.max()),ylim=(zlev.min(),zlev.max()),
                      xlabel='',ylabel='depth (m)',xticklabels='',
                      yticks=ztic,yticklabels=zlab)

                top_labels(ax,'Exp:',case.replace('_',' '),year_string_exp,fontsize=14)
                bottom_labels(ax,'Control:',cntrlcase.replace('_',' '),year_string_cnt,fontsize=14)
                titlestrn = '%s %s from Exp: Min:%.1f, Max:%.1f' %(reg_lname[r],
                      variables[var]['slabel'],mdatamin,mdatamax)
                ax.text(0.5,1.1,titlestrn,horizontalalignment='center',
                      verticalalignment='bottom',transform=ax.transAxes,
                      fontsize=16)

                # plot experiment - control ------------------------------------------------
                ax  = fig.add_subplot(212)
                CF  = ax.contourf(lat,zlev,differnce,variables[var]['dlev'],cmap=cmapdiff,
                      norm=colors.BoundaryNorm(variables[var]['dlev'],cmapdiff.N),extend='both')
		CF.cmap.set_under('black')
		CF.cmap.set_over('black')
                CS  = ax.contour(lat,zlev,differnce,CF.levels,colors='k',
                        linewidths=0.25)
                CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=15,
                    ticks=variables[var]['dlev'][1:-1],format='%G')
                CB.set_label(variables[var]['units'])
                for line in CB.ax.get_yticklines(): # remove tick lines
                    line.set_markersize(0)

                ax.set(xlim=(lat.min(),lat.max()),ylim=(zlev.min(),zlev.max()),
                      xlabel='latitude',ylabel='depth (m)',
                      yticks=ztic,yticklabels=zlab)

                titlestrn = 'Exp-Con: Min:%.1f, Max:%.1f'%(odatamin,odatamax)
                top_labels(ax,'',titlestrn,'',fontsize=14)

                fig.savefig(outfile,dpi=100,bbox_inches='tight',pad_inches=0.8)
                pl.close(fig)

#-----------------------------------------------------------------------------
