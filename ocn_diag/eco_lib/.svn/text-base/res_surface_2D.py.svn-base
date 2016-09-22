
# Resource file to plot surface maps.
# Created by Ernesto Munoz on Fri Dec 7 2012.
# These variables are 2-dimensional (lat,lon).

import numpy as N
import numpy.ma as MA
import os, Nio
from mpl_utils import *

spd = 60.*60.*24. # seconds per day

variables = {
    'SSH' : {
        'label'  : r'Sea Surface Height',
        'slabel' : r'SSH',
        'units'  : r'meters',
        'cfac'   : 1.e-2,
        'clev'   : N.arange(-20,22.5,2.5)/10.,
        'dlev'   : N.array([-10,-8,-6,-4,-2,0.0,2,4,6,8,10]),
        },
    'HMXL' : {
        'label'  : r'Mixed Layer Depth',
        'slabel' : r'ML Depth',
        'units'  : r'meters',
        'cfac'   : 1.e-2,
        'clev'   : N.array([0,20,30,40,50,75,100,150,200,300,400]),
        'dlev'   : N.array([-10,-8,-6,-4,-2,0.0,2,4,6,8,10]),
        },
    'HBLT' : {
        'label'  : r'Boundary Layer Depth',
        'slabel' : r'BL Depth',
        'units'  : r'meters',
        'cfac'   : 1.e-2,
        'clev'   : N.array([0,20,30,40,50,75,100,150,200,250,300,400]),
        'dlev'   : N.array([-10,-8,-6,-4,-2,0.0,2,4,6,8,10]),
        },
    'DpCO2' : {
        'label'  : r'Delta pCO$_2$',
        'slabel' : r'D pCO$_2$',
        'units'  : r'ppmv',
        'clev'   : N.arange(-100,100,20),
        'dlev'   : N.arange(-20,22,2),
        },
    'pCO2SURF' : {
        'label'  : r'pCO$_2$',
        'slabel' : r'pCO$_2$',
        'units'  : r'ppmv',
        'clev'   : N.arange(200,500,20),
        'dlev'   : N.arange(-100,120,20),
        },
    'FG_CO2' : {
        'label'  : r'Air-Sea CO$_2$ Flux',
        'slabel' : r'Air-Sea CO$_2$ Flux',
        'units'  : r'mol m$^{-2}$ y$^{-1}$',
        'cfac'   : 1.e-2 * 1.e-3 * spd * 365, # mmol/m^3*cm/sec -> mol/m^2/year
        'clev'   : N.arange(-7,8),
        'dlev'   : N.arange(-3.5,4,0.5),
        },
    'STF_O2' : {
        'label'  : r'Air-Sea O$_2$ Flux',
        'slabel' : r'Air-Sea O$_2$ Flux',
        'units'  : r'mol m$^{-2}$ y$^{-1}$',
        'cfac'   : 1.e-2 * 1.e-3 * spd * 365, # mmol/m^3*cm/sec -> mol/m^2/year
        'clev'   : N.arange(-30,35,5),
        'dlev'   : N.array([-10,-8,-6,-4,-2,0,2,4,6,8,10]),
        },
    'FvPER_DIC' : {
        'label'  : r'CO$_2$ Virtual Flux (P, E \& R)',
        'slabel' : r'CO$_2$ Virt. Flux (P, E \& R)',
        'units'  : r'mol m$^{-2}$ y$^{-1}$',
        'cfac'   : 1.e-2 * 1.e-3 * spd * 365, # mmol/m^3*cm/sec -> mol/m^2/year
        'clev'   : N.arange(-10,11),
        'dlev'   : N.array([-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4]),
        },
    'FvICE_DIC' : {
        'label'  : r'CO$_2$ Virtual Flux (ice form. \& melt)',
        'slabel' : r'CO$_2$ Virt. Flux (ice form. \& melt)',
        'units'  : r'mol m$^{-2}$ y$^{-1}$',
        'cfac'   : 1.e-2 * 1.e-3 * spd * 365, # mmol/m^3*cm/sec -> mol/m^2/year
        #'clev'  : N.array([-0.1,0.1,1,2,3,4,5,6,7,8]),
        'clev'   : logcscale(0.1,7.5,decimals=2),
        'dlev'   : N.array([-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5]),
        },
    'IRON_FLUX' : {
        'label'  : r'Iron Flux',
        'slabel' : r'Iron Flux',
        'units'  : r'mmol m$^{-2}$ y$^{-1}$',
        'cfac'   : 1.e-3 * 1.e+4 * spd * 365, # nmol/cm^3/sec -> mmol/m^2/year
        #'clev'  : N.arange(2.5,32.5,2.5)/100.,
        'clev'   : N.concatenate((N.array([0,0.05,0.1]),
            N.arange(0.5,3.5,0.5)),0),
        'dlev'   : N.array([-0.08,-0.06,-0.04,-0.02,-0.01,0.0,0.01,0.02,0.04,0.06,0.08]),
        },
}
