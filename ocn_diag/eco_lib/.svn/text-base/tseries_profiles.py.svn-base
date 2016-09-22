
# Plot time series of global and regional average profiles of selected
# variables (depth x time)
# Created by Ivan Lima on Thu Jun 25 16:20:13 EDT 2009
# Modified by Ernesto Munoz

# Reads input files:
#  tseries.profile.'case'.global.nc
#  tseries.profile.'case'.'regname'.nc
#  tseries.'case'.'regname'.nc

# Creates output files:
#  tseries_profile_'varname'_'regname'.png

import numpy as N
import numpy.ma as MA
import os, Nio
import matplotlib.pyplot as pl
import matplotlib.transforms as transforms
from matplotlib import colors
from matplotlib.ticker import MultipleLocator, FormatStrFormatter
from res_tseries_profiles import *
from mpl_utils import *
from ccsm_utils import read_BEC_region_mask, read_BEC_region_mask_popdiag
from scipy.interpolate import interp1d

case = raw_input('Enter case: \n')
yrstart = int(raw_input('Enter start year: \n'))
yrend = int(raw_input('Enter end year: \n'))
POPDIAGPY = raw_input('Enter TRUE or FALSE: \n')
yroffset = int(raw_input('Enter year offset: \n'))
WORKDIRPY = raw_input('Enter WORKDIR: \n')
mgrid = raw_input('Enter model grid/resolution: \n')
ODATADIR = raw_input('Enter directory of observations: \n')

nyrs = 1 # number of years for running mean

# directory with input processed files
if POPDIAGPY == 'TRUE':
   indir = WORKDIRPY
else:
   indir = '/bonaire/data2/ivan/ccsm_output/%s'%case 

if POPDIAGPY == 'TRUE':
   rmask, nreg, rlname, rsname = read_BEC_region_mask_popdiag(mgrid)
elif 'x1' in case:
   rmask, nreg, rlname, rsname = read_BEC_region_mask('gx1v6')
elif 'x3' in case:
   rmask, nreg, rlname, rsname = read_BEC_region_mask('gx3v5')
else:
   print('Unknown grid type')
   sys.exit()

rsname = ['global'] + rsname
rlname = ['Global'] + rlname
nreg = len(rsname)

# Get type of field average (full depth, upper 150m)

vars_fulldepth, vars_zt150m = [], []
if POPDIAGPY == 'TRUE':
   infile = os.path.join(indir,'tseries.profile.%04d-%04d.%s.global.nc'%(yrstart,yrend,case))
else:
   infile = os.path.join(indir,'tseries.profile.%s.global.nc'%case)
fpin   = Nio.open_file(infile,'r')
ntime  = fpin.dimensions['time']
nz     = fpin.dimensions['z_t']
nz150  = fpin.dimensions['z_t_150m']
days   = fpin.variables['time'][:]
zt     = fpin.variables['z_t'][:]      / 100. # cm -> m
zt150  = fpin.variables['z_t_150m'][:] / 100. # cm -> m
for varname in sorted(fpin.variables):
    if hasattr(fpin.variables[varname],'coordinates'):
        if fpin.variables[varname].coordinates == "TLONG TLAT z_t time":
            vars_fulldepth.append(varname)
        elif fpin.variables[varname].coordinates == "TLONG TLAT z_t_150m time":
            vars_zt150m.append(varname)

fpin.close()

# Read global and resional averages into one array per variable

# all variables in the file
vars_all = vars_fulldepth + vars_zt150m
# use only variables that are in dictionary
varlist  = [varname for varname in vars_all if varname in variables]
for varname in varlist:
    if varname in vars_fulldepth:
        vars()[varname] = N.ones((nreg,ntime,nz),dtype=N.float) * 1.e+20
    elif varname in vars_zt150m:
        vars()[varname] = N.ones((nreg,ntime,nz150),dtype=N.float) * 1.e+20
    else:
        print('Error: check %s dimensions.'%varname)
        os.sys.exit()

for r in range(nreg):
    if POPDIAGPY == 'TRUE':
        infile = os.path.join(indir,'tseries.profile.%04d-%04d.%s.%s.nc'%(yrstart,yrend,case,rsname[r]))
    else:
        infile = os.path.join(indir,'tseries.profile.%s.%s.nc'%(case,rsname[r]))
    print('reading %s'%os.path.basename(infile))
    fpin       = Nio.open_file(infile,'r')
    for varname in varlist:
        vars()[varname][r,...] = fpin.variables[varname][:]

    fpin.close()

for varname in varlist:
    # do some basic unit conversions
    if 'cfac' in variables[varname]:
        vars()[varname] = vars()[varname] * variables[varname]['cfac']
    # remove small negative values
    if varname not in ['NO3_excess','TEMP']:
        vars()[varname][vars()[varname] < 0] = 0
    # compute annual averages
    if vars()[varname].shape[-1] == nz150:
        vars()[varname] = vars()[varname].reshape(nreg,-1,12,nz150).mean(axis=2)
    elif vars()[varname].shape[-1] == nz:
        vars()[varname] = vars()[varname].reshape(nreg,-1,12,nz).mean(axis=2)
    else:
        print('Error: check %s dimensions.'%varname)
        os.sys.exit()

# read mixed layer depth
HMXL = N.ones((nreg,ntime),dtype = N.float) * 1.e+20
for r in range(nreg):
    if POPDIAGPY == 'TRUE':
       infile = os.path.join(indir,'tseries.%04d-%04d.%s.%s.nc'%(yrstart,yrend,case,rsname[r]))
    else:
       infile = os.path.join(indir,'tseries.%s.%s.nc'%(case,rsname[r]))
    fpin      = Nio.open_file(infile,'r')
    HMXL[r,:] = fpin.variables['HMXL'][:] * 1.e-2 # cm -> m
    fpin.close()

HMXL = HMXL.reshape(nreg,-1,12).mean(axis=-1) # compute annual average

# convert to calendar years
days = days.reshape(-1,12).mean(axis=1) # annual averages

if POPDIAGPY == 'TRUE':
   year = yroffset + days/365.
else:
   year = days/365. - 181 + 1948

#-----------------------------------------------------------------------------
# plot figures

# create directory for plots if necessary
if POPDIAGPY == 'TRUE':
  outdir = WORKDIRPY
else:
  outdir = '/fiji/home/ivan/www/ccsm_log/cases/%s/plots'%case
if (not os.path.isdir(outdir)):
    os.makedirs(outdir)

# make negative contour lines solid
pl.rc('contour',negative_linestyle='solid')

for varname in varlist:
    if vars()[varname].shape[-1] == nz:
        # use indices coords instead of linear depth
        zlev = -N.arange(len(zt))
        f    = interp1d(zt,zlev)
        zlab = N.array([50,100,200,500,1000,2000,3000,4000,5000])
        ztic = f(zlab)
        mld  = f(HMXL) # remap mixed layer depth
    else:
        zlev = -zt150
        ztic = N.arange(-140,0,20)
        zlab = -ztic
        mld  = -HMXL

    if varname in ['NO3_excess']:
        cmap = CyBuWhRdYl
    else:
        cmap = pl.cm.jet

    for r in range(nreg):
        outfile = os.path.join(outdir,'tseries_profile_%s_%s.png'%
            (varname,rsname[r]))
        print 'plotting', outfile
        fig  = pl.figure()
        ax   = fig.add_subplot(111)
        data = N.transpose(vars()[varname][r,:,:])
        CF   = ax.contourf(year,zlev,data,variables[varname]['clev'],
                norm=colors.BoundaryNorm(variables[varname]['clev'],cmap.N),
                cmap=cmap)
        CS  = ax.contour(year,zlev,data,CF.levels,colors='k',linewidths=0.25)
        CB  = fig.colorbar(CF,ax=ax,drawedges=True,aspect=15,
            ticks=variables[varname]['clev'][1:-1],format='%G')
        CB.set_label(variables[varname]['units'])
        for line in CB.ax.get_yticklines(): # remove tick lines
            line.set_markersize(0)

        line, = ax.plot(year,mld[r,:],'-w',linewidth=2) # plot MLD
        ax.set(xlim=(year.min(),year.max()),ylim=(zlev.min(),zlev.max()),
                xlabel='year',ylabel='depth (m)',yticks=ztic,yticklabels=zlab)
        ax.xaxis.set_minor_locator(MultipleLocator(1)) # added to test
        ax.xaxis.set_major_formatter(FormatStrFormatter('%d')) # added to test
        top_labels(ax,case.replace('_',' '),'','Annual Averages',fontsize=14)
        titlestrn = '%s %s'%(rlname[r],variables[varname]['label'])
        tt = ax.text(0.5,1.1,titlestrn,horizontalalignment='center',
                verticalalignment='bottom',transform=ax.transAxes,
                fontsize=16)
        fig.savefig(outfile,dpi=100,bbox_inches='tight',pad_inches=0.8)

        #extent = ax.get_window_extent().transformed(
        #        fig.dpi_scale_trans.inverted())
        #fig.savefig(outfile,dpi=100,bbox_inches=extent.expanded(1.4,1.3))
        #bbox = transforms.Bbox([[0,0.1],[7.5,6.25]])
        #fig.savefig(outfile,dpi=100,bbox_inches=bbox)
        #fig.savefig(outfile,dpi=100,bbox_extra_artists=[tt])

        pl.close(fig)

#-----------------------------------------------------------------------------

