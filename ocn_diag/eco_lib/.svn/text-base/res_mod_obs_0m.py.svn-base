
# Resource file for script to plot surface difference of model minus observations.
# Created by Ernesto Munoz on Fri Dec 7 2012.
# Based on model_obs_maps.py created by Ivan Lima on Thu Nov 18 11:21:53 EST 2010.

import numpy as N
import numpy.ma as MA
import os, Nio
from mpl_utils import *

POPDIAGPY2 = os.environ['POPDIAG']
if POPDIAGPY2 == 'TRUE':
    datadir = os.environ['ECODATADIR']+'/data/obs_data/'
else:
    datadir = '/fiji/home/ivan/data'

spd = 60.*60.*24. # seconds per day

variables = {
    'pCO2SURF' : {
        'label'  : r'pCO$_2$ at 0m',
        'slabel' : r'pCO$_2$ at 0m',
        'units'  : r'ppmv',
        'clev'   : N.arange(200,500,20),
        'dlev'   : N.arange(-100,120,20),
        'obsfile'   : os.path.join(datadir,
            'Takahashi/Takahashi_2006/pco2_2006_version_7_30_2007_4x5d.nc'),
        'obsname'   : 'PCO2_SW',
        'obsgrid'   : '4x5d',
        'obsllabel' : 'Takahashi 2009',
        'obsrlabel' : ''
        },
    'FG_CO2' : {
        'label'  : r'Air-Sea CO$_2$ Flux',
        'slabel' : r'Air-Sea CO$_2$ Flux',
        'units'  : r'mol m$^{-2}$ y$^{-1}$',
        'cfac'   : 1.e-2 * 1.e-3 * spd * 365, # mmol/m^3*cm/sec -> mol/m^2/year
        'clev'   : N.arange(-7,8),
        'dlev'   : N.arange(-5,6),
        'obsfile'   : os.path.join(datadir,
            'Takahashi/Takahashi_2002/fluxdata_10m.nc'),
        'obsname'   : 'CO2_Flux',
        'obsgrid'   : '4x5d',
        'obsllabel' : 'Takahashi 2002 (940K)',
        'obsrlabel' : ''
        },
    'totChl' : {
        'label'  : r'Total Chlorophyll',
        'slabel' : r'Total Chl',
        'units'  : r'mg Chl m$^{-3}$',
        'clev'   : N.array([0,0.01,0.03,0.05,0.07,0.1,0.125,0.15,0.175,0.2,0.3,
            0.5,1,3,5]),
        'dlev'   : N.array([-1,-0.5,-0.2,-0.1,-0.05,-0.01,0,0.01,0.05,0.1,0.2,0.5,1]),
        'obsfile'   : os.path.join(datadir,'seawifs/seawifs_chl_1x1d_clim.nc'),
        'obsname'   : 'Chl',
        'obsgrid'   : '1x1d',
        'obsllabel' : 'SeaWiFS',
        'obsrlabel' : '1997--2006'
        },
    'photoC_tot': {
        'label'  : r'Primary Production',
        'slabel' : r'Prim Prod',
        'units'  : r'g C m$^{-2}$ y$^{-1}$',
        'cfac'   : 1.e-3 * spd * 365 * 12.01, # mmolC/m^3/sec -> gC/m^3/year
        'clev'   : N.array([0,1,25,50,75,100,125,150,200,250,300,400,500,1000]),
        'dlev'   : N.array([-300,-200,-100,-50,-25,-10,0,10,25,50,100,200,300]),
        'tcfac'     : 1.e-15,
        'tunits'    : 'Pg C y$^{-1}$',
        'obsfile'   : os.path.join(datadir,'seawifs/seawifs_prod_1x1d_clim.nc'),
        'obsname'   : 'Prod',
        'obsgrid'   : '1x1d',
        'obsllabel' : 'SeaWiFS',
        'obsrlabel' : '1997--2006'
        },
    'phytoC' : {
        'label'  : r'Total Phyto Carbon at 0m',
        'slabel' : r'Total Phyto C at 0m',
        'units'  : r'mg C m$^{-3}$',
        'cfac'   : 12.01,
        'clev'   : N.array([1,5,10,15,20,30,40,50,75,100,125]),
        'dlev'   : N.array([-75,-50,-25,-10,-5,-1,0,1,5,10,25,50,75]),
        'obsfile'   : os.path.join(datadir,
            'Behrenfeld_mu/CbPM_monthly_1x1d_clim.nc'),
        'obsname'   : 'phytoC',
        'obsgrid'   : '1x1d',
        'obsllabel' : r'Behrenfeld \& Westberry',
        'obsrlabel' : '1997--2004'
        },
    'phyto_mu' : {
        'label'  : r'Total Phyto Specific Growth at 0m',
        'slabel' : r'Total Phyto Spec. Growth at 0m',
        'units'  : r'd$^{-1}$',
        'cfac'   : spd, # 1/sec -> 1/day
        'clev'   : N.arange(0,2.2,0.2),
        'dlev'   : N.arange(-10,12.5,2.5)/10.,
        'obsfile'   : os.path.join(datadir,
            'Behrenfeld_mu/CbPM_monthly_1x1d_clim.nc'),
        'obsname'   : 'mu',
        'obsgrid'   : '1x1d',
        'obsllabel' : r'Behrenfeld \& Westberry',
        'obsrlabel' : '1997--2004'
        },
}
