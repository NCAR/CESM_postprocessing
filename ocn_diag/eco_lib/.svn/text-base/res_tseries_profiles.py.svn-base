
# No hashbang

# Common resources for time-series plots.
# Created by Ivan Lima on Fri Sep 16 15:02:22 EDT 2011
# Last modified on Fri Sep 16 15:02:22 EDT 2011

import numpy as N
import numpy.ma as MA
from mpl_utils import *

spd = 60.*60.*24. # seconds per day

clevprod = logcscale(0.1,11,decimals=2)
clevchl  = logcscale(0.01,1,decimals=3)

variables = {
    'TEMP' : {
        'label' : r'Temperature',
        'units' : r'$^{o}$C',
        'clev'  : N.arange(-2,32,2),
        },
    'SALT' : {
        'label' : r'Salinity',
        'units' : r'PSU',
        #'cfac'  : 1.e+3, # g/kg -> PSU
        'clev'  : N.arange(30,40.5,0.5)
        },
    'NO3' : {
        'label' : r'NO$_3$',
        'units' : r'mmol m$^{-3}$',
        'clev'  : N.concatenate((N.array([0,0.01,0.1,0.25,0.5,1.,2.5]),
            N.arange(5,50,5)),0)
        },
    'NH4' : {
        'label' : r'NH$_4$',
        'units' : r'mmol m$^{-3}$',
        'clev'  : N.arange(0,40,2.5)/100.
        },
    'PO4' : {
        'label' : r'PO$_4$',
        'units' : r'mmol m$^{-3}$',
        'clev'  : N.concatenate((N.array([0,0.01,0.1,0.25,0.5]),
            N.arange(1,4,0.25)),0)
        },
    'SiO3' : {
        'label' : r'SiO$_3$',
        'units' : r'mmol m$^{-3}$',
        'clev'  : N.concatenate((N.array([0,0.1,0.25,0.5,1.,2.,5.,10.]),
            N.arange(20.,200.,20.)),0)
        },
    'Fe' : {
        'label' : r'Fe',
        'units' : r'pM',
        'cfac'  : 1.e+6, # mmol/m^3 -> pico molar
        'clev'  : logcscale(50,11100,decimals=0)
        },
    'NO3_excess' : {
        'label' : r'Excess NO$_3$',
        'units' : r'mmol m$^{-3}$',
        'clev'  : [-35,-20,-15,-10,-5,-4,-3,-2,-1,-0.5,0,
            0.5,1,2,3,4,5,10,15,20,35]
        },
    'DIC' : {
        'label' : r'DIC',
        'units' : r'mmol m$^{-3}$',
        'clev'  : N.arange(1875,2500,25)
        },
    'ALK' : {
        'label' : r'Alkalinity',
        'units' : r'meq m$^{-3}$',
        'clev'  : N.arange(2025,2575,25)
        },
    'O2' : {
        'label' : r'O$_2$',
        'units' : r'mmol m$^{-3}$',
        'clev'  : N.concatenate((N.array([-5,5,10]),N.arange(25,400,25)))
        },
    'spChl' : {
        'label' : r'Small Phyto. Chlorophyll',
        'units' : r'mg Chl m$^{-3}$',
        'clev'  : clevchl
        },
    'diatChl' : {
        'label' : r'Diatom Chlorophyll',
        'units' : r'mg Chl m$^{-3}$',
        'clev'  : clevchl
        },
    'diazChl' : {
        'label' : r'Diazotrophs Chlorophyll',
        'units' : r'mg Chl m$^{-3}$',
        'clev'  : N.concatenate((N.array([-0.001]),N.arange(1,22)/1000.))
        },
    'totChl' : {
        'label' : r'Total Chlorophyll',
        'units' : r'mg Chl m$^{-3}$',
        'clev'  : clevchl
        },
    #'spC' : {
    #    'label' : r'Small Phyto. Carbon',
    #    'units' : r'mg C m$^{-3}$',
    #    'cfac'  : 12.01,
    #    'clev'  : [1,2,3,4,5,8,9,10,15,20,30,40,50]
    #    },
    #'diatC' : {
    #    'label' : r'Diatom Carbon',
    #    'units' : r'mg C m$^{-3}$',
    #    'cfac'  : 12.01,
    #    'clev'  : [1,2,3,4,5,8,9,10,15,20,30,40,50]
    #    },
    #'diazC' : {
    #    'label' : r'Diazotrophs Carbon',
    #    'units' : r'mg C m$^{-3}$',
    #    'cfac'  : 12.01,
    #    'clev'  : N.arange(1,10)/10.
    #    },
    #'phytoC' : {
    #    'label' : r'Total Phyto Carbon',
    #    'units' : r'mg C m$^{-3}$',
    #    'cfac'  : 12.01,
    #    'clev'  : [1,2,3,4,5,8,9,10,15,20,30,40,50]
    #    },
    #'phyto_mu' : {
    #    'label' : r'Phyto ~F33~m~F~',
    #    'units' : r'd$^{-1}$',
    #    'cfac'  : spd, # 1/sec -> 1/day
    #    #'clev'  : N.concatenate((N.arange(5,80,5)/100.,N.arange(1,2.25,0.25)))
    #    'clev'  : N.arange(5,105,5)/100.
    #    },
    'photoC_sp' : {
        'label' : r'S. Phyto. Primary Production',
        'units' : r'g C m$^{-3}$ y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 * 12.01, # mmolC/m^3/sec -> gC/m^3/year
        'clev'  : clevprod
        },
    'photoC_diat' : {
        'label' : r'Diatom Primary Production',
        'units' : r'g C m$^{-3}$ y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 * 12.01, # mmolC/m^3/sec -> gC/m^3/year
        'clev'  : clevprod
        },
    'photoC_diaz' : {
        'label' : r'Diazotrophs Primary Production',
        'units' : r'g C m$^{-3}$ y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 * 12.01, # mmolC/m^3/sec -> gC/m^3/year
        'clev'  : logcscale(0.01,0.19,decimals=3)
        },
    'photoC_tot': {
        'label' : r'Primary Production',
        'units' : r'g C m$^{-3}$ y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 * 12.01, # mmolC/m^3/sec -> gC/m^3/year
        'clev'  : clevprod
        },
    'diaz_Nfix' : {
        'label' : r'Diazotrophs Nitrogen Fixation',
        'units' : r'mmol N m$^{-3}$ y$^{-1}$',
        'cfac'  : spd * 365, # mmolC/m^3/sec -> mmol/m^3/year
        'clev'  : logcscale(0.01,2.5,decimals=3)
        },
    'CaCO3_form': {
        'label' : r'CaCO$_3$ Production',
        'units' : r'g C m$^{-3}$ y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 * 12.01, # mmolC/m^3/sec -> gC/m^3/year
        'clev'  : N.arange(0,16)/100.
        },
    'bSi_form' : {
        'label' : r'SiO$_3$ Production',
        'units' : r'mol m$^{-3}$ y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365, # mmol/m^3/sec -> mol/m^3/year
        'clev'  : N.arange(0,50,2.5)/1000.
        },
    'NITRIF' : {
        'label' : r'Nitrification',
        'units' : r'mmol N m$^{-3}$ y$^{-1}$',
        'cfac'  : spd * 365, # mmolN/m^3/sec -> mmolN/m^3/year
        'clev'  : N.arange(0,80,5)/10.,
        },
    'DENITRIF' : {
        'label' : r'Denitrification',
        'units' : r'mmol N m$^{-3}$ y$^{-1}$',
        'cfac'  : spd * 365, # mmolN/m^3/sec -> mmolN/m^3/year
        'clev'  : logcscale(0.01,1.8,decimals=3)
        },
    'POC_FLUX_IN' : {
        'label' : r'POC Flux',
        'units' : r'g C m$^{-2}$ y$^{-1}$',
        'cfac'  : 1.e-2*1.e-3*spd*365*12.01, # mmol/m^3*cm/sec -> gC/m^2/year
        'clev'  : logcscale(1,65,decimals=1)
        },
    'CaCO3_FLUX_IN' : {
        'label' : r'CaCO$_3$ Flux',
        'units' : r'g C m$^{-2}$ y$^{-1}$',
        'cfac'  : 1.e-2*1.e-3*spd*365*12.01, # mmol/m^3*cm/sec -> gC/m^2/year
        'clev'  : logcscale(1,4,decimals=1)
        },
    'SiO2_FLUX_IN' : {
        'label' : r'SiO$_3$ Flux',
        'units' : r'mol m$^{-2}$ y$^{-1}$',
        'cfac'  : 1.e-2 * 1.e-3 * spd * 365, # mmol/m^3*cm/sec -> mol/m^2/year
        'clev'  : N.arange(0,1,0.05)
        },
    #'dust_FLUX_IN' : {
    #    'label' : r'Dust Flux',
    #    'units' : r'g m$^{-2}$ y$^{-1}$',
    #    'cfac'  : 1.e+4 * spd * 365, # g/cm^2/sec -> g/m^2/year
    #    'clev'  : N.concatenate((N.arange(5,55,5)/100.,N.arange(1,17)))
    #    }
}

