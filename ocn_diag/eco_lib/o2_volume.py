# Computes and plots the volume of ocean with O2 below a certain level as
# function of O2 concentration for the first and last year of the model run.
# Matplotlib version.
# Created by Ivan Lima on Mon Dec 20 16:03:54 EST 2004
# Last modified on Tue Sep 27 09:30:40 EDT 2011
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - Choose directories (NCAR or WHOI),

# Creates output file o2_volume.png

import numpy as N
import numpy.ma as MA
import matplotlib.pyplot as pl
import os, Nio
from mpl_utils import *
from ccsm_utils import create_file_list, create_file_list_popdiag

case      = raw_input('Enter run/case: \n')
yrstart   = int(raw_input('Read start year: \n'))
yrend     = int(raw_input('Read end year: \n'))
POPDIAGPY = raw_input('Enter TRUE or FALSE: \n')
yroffset  = int(raw_input('Enter year offset: \n'))
WORKDIRPY = raw_input('Enter WORKDIR: \n')
mgrid     = raw_input('Enter model grid/resolution: \n')
ODATADIR  = raw_input('Enter directory of observations: \n')

if POPDIAGPY == 'TRUE':
   file_list = create_file_list_popdiag(case,WORKDIRPY)
else:
   file_list = create_file_list(case)

#o2_scale  = N.concatenate((N.arange(0.1,10,0.1),N.arange(10,445.,5.)),0)
o2_scale = N.logspace(N.log10(0.01),N.log10(445),num=150)

#------------------------------------------------------------------------------
# read first input file (start of run)

infile_first = file_list[0]

print 'reading', os.path.basename(infile_first)
fpin = Nio.open_file(infile_first, 'r')
day  = fpin.variables['time'][0]
dz   = fpin.variables['dz'][:]     / 100. # cm -> m
area = fpin.variables['TAREA'][:]  / 1.e-4 # cm2 -> m2
o2   = fpin.variables['O2'][0,...]
fpin.close()

if POPDIAGPY == 'TRUE':
  yr_first = yroffset + day/365.
else:
  yr_first = day/365. - 181 + 1948

# compute ocean volume (m^3)
volume = MA.array(MA.resize(area,o2.shape),mask=o2.mask) * \
        dz[:,N.newaxis,N.newaxis]

# compute volume of ocean where O2 concentration < o2_min
o2_vol_first = N.array([volume[o2<o2_min].sum() for o2_min in o2_scale])

#------------------------------------------------------------------------------
# read last input file (end of run)

infile_last = file_list[-1]

print 'reading', os.path.basename(infile_last)
fpin = Nio.open_file(infile_last, 'r')
day  = fpin.variables['time'][0]
o2   = fpin.variables['O2'][0,...]
fpin.close()

if POPDIAGPY == 'TRUE':
  yr_last = day/365. + yroffset - 1
else:
  yr_last = day/365. - 181 + 1948 - 1

# compute volume of ocean where O2 concentration < o2_min
o2_vol_last = N.array([volume[o2<o2_min].sum() for o2_min in o2_scale])

#------------------------------------------------------------------------------
# plot

pl.rc('legend',**{'fontsize':10})

# create directory for plots if necessary
if POPDIAGPY == 'TRUE':
  outdir = WORKDIRPY
else:
  outdir = '/fiji/home/ivan/www/ccsm_log/cases/%s/plots'%case

if (not os.path.isdir(outdir)):
    os.makedirs(outdir)

#model_year_first = int(os.path.split(infile_first)[-1][-10:-6])
#model_year_last  = int(os.path.split(infile_last)[-1][-10:-6])

outfile = os.path.join(outdir,'o2_volume.png')
print 'plotting', outfile

fig = pl.figure()
ax = fig.add_subplot(111)
l1, = ax.plot(o2_scale,o2_vol_first,'r-',label='%.0f'%yr_first)
l2, = ax.plot(o2_scale,o2_vol_last ,'b-',label='%.0f'%yr_last)
ax.axis('tight')
ax.loglog()
ax.legend(loc='upper left')
remove_top_right_borders(ax)
#ax.set(xlabel=r'O$_2^{min}$ (mmol m$^{-3}$)',ylabel=r'Volume (m$^3$)')
ax.set(xlabel=r'Oxygen_min (mmol m$^{-3}$)',ylabel=r'Volume (m$^3$)')
top_labels(ax,case.replace('_','\_'),'','')
#ax.text(0.5,1.1,r'Volume of Ocean with O$_2$ < O$_2^{min}$',
ax.text(0.5,1.1,r'Volume of Ocean with oxygen < oxygen_min',
        horizontalalignment='center',verticalalignment='bottom',
        transform=ax.transAxes, fontsize=18)
extent = ax.get_window_extent().transformed(fig.dpi_scale_trans.inverted())
fig.savefig(outfile,dpi=100,bbox_inches=extent.expanded(1.3,1.4))
pl.close(fig)

#---------------------------------------------------------------------------
