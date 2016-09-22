
# Resource file for script to plot maps at various depths.
# Created by Ernesto Munoz on Fri Dec 7 2012.

import numpy as N
import numpy.ma as MA
import os, Nio
from mpl_utils import *

POPDIAGPY2 = os.environ['POPDIAG']
if POPDIAGPY2 == 'TRUE':
  datadir = os.environ['ECODATADIR']+'/data/obs_data'
else:
  datadir = '/fiji/home/ivan/data'

variables = {
    'NO3' : {
        'label'  : r'NO$_3$',
        'slabel' : r'NO$_3$',
        'units'  : r'mmol m$^{-3}$',
        'clev'       : N.array([0,0.01,0.1,0.25,0.5,1.,2.5,5,10,15,20,25,35,40]),
        'dlev'       : N.array([-10,-5,-3,-2,-1,-0.5,-0.1,0,0.1,0.5,1,2,3,5,10]),
        'dlevobs'    : N.array([-10,-5,-3,-2,-1,-0.5,-0.1,0,0.1,0.5,1,2,3,5,10]),
        'obsfile'    : os.path.join(datadir,'WOA2005/WOA05nc/annual/n00an1.nc'),
        'obsname'    : 'n00an1',
        'obsgrid'    : '1x1d',
        'obsmiss'    : 1.e+20,
        'obsllabel'  : 'WOA 2005',
        'obsrlabel'  : ''
        },
    'PO4' : {
        'label'  : r'PO$_4$',
        'slabel' : r'PO$_4$',
        'units'  : r'mmol m$^{-3}$',
        'clev'       : N.array([0,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.75,1,2,3]),
        'dlev'       : N.array([-1.2,-0.8,-0.6,-0.2,-0.1,0,0.1,0.2,0.6,0.8,1.2]),
        'dlevobs'    : N.array([-1.2,-0.8,-0.6,-0.2,-0.1,0,0.1,0.2,0.6,0.8,1.2]),
        'obsfile'    : os.path.join(datadir,'WOA2005/WOA05nc/annual/p00an1.nc'),
        'obsname'    : 'p00an1',
        'obsgrid'    : '1x1d',
        'obsmiss'    : 1.e+20,
        'obsllabel'  : 'WOA 2005',
        'obsrlabel'  : ''
        },
    'SiO3' : {
        'label'  : r'SiO$_3$',
        'slabel' : r'SiO$_3$',
        'units'  : r'mmol m$^{-3}$',
        'clev'       : N.array([0,0.1,0.25,0.5,1,2.5,5,10,25,50,75,100,125,150]),
        'dlev'       : N.array([-75,-50,-25,-10,-5,-2.5,-1,0,1,2.5,5,10,25,50,75]),
        'dlevobs'    : N.array([-75,-50,-25,-10,-5,-2.5,-1,0,1,2.5,5,10,25,50,75]),
        'obsfile'    : os.path.join(datadir,'WOA2005/WOA05nc/annual/i00an1.nc'),
        'obsname'    : 'i00an1',
        'obsgrid'    : '1x1d',
        'obsmiss'    : 1.e+20,
        'obsllabel'  : 'WOA 2005',
        'obsrlabel'  : ''
        },
    'Fe' : {
        'label'  : r'Fe',
        'slabel' : r'Fe',
        'units'  : r'pM',
        'cfac'   : 1.e+6, # mmol/m^3 -> pico molar
        'clev'       : logcscale(5,35000,decimals=0),
        'dlev'       : N.array([-200,-150,-100,-50,-25,-10,0,10,25,50,100,150,200]),
        },
    'O2' : {
        'label'  : r'O$_2$',
        'slabel' : r'O$_2$',
        'units'  : r'mmol m$^{-3}$',
        'clev'       : N.arange(20,440,30),
        'dlev'       : N.arange(-80,90,10),
        'dlevobs'    : N.arange(-80,90,10),
        'obsfile'    : os.path.join(datadir,'WOA2005/WOA05nc/annual/o00an1.nc'),
        'obsname'    : 'o00an1',
        'obscfac'    : 1./22.3916 * 1000., # ml/l -> mmol/m^3
        'obsgrid'    : '1x1d',
        'obsmiss'    : 1.e+20,
        'obsllabel'  : 'WOA 2005',
        'obsrlabel'  : ''
        },
    'DIC' : {
        'label'  : r'DIC',
        'slabel' : r'DIC',
        'units'  : r'mmol m$^{-3}$',
        'clev'       : N.arange(1750,2400,50),
        'dlev'       : N.array([-250,-200,-150,-100,-50,-30,-10,0,10,30,50,100,150,200,250]),
        'dlevobs'    : N.array([-250,-200,-150,-100,-50,-30,-10,0,10,30,50,100,150,200,250]),
        'obsfile'    : os.path.join(datadir,'GLODAP_COARDS/TCO2.nc'),
        'obsname'    : 'TCO2',
        'obscfac'    : 1.025, # umol/kg -> mmol/m^3
        'obsgrid'    : '1x1d',
        'obsmiss'    : -999.0,
        'obsllabel'  : 'GLODAP',
        'obsrlabel'  : ''
        },
    'ALK' : {
        'label'  : r'Alkalinity',
        'slabel' : r'Alk',
        'units'  : r'meq m$^{-3}$',
        'clev'       : N.arange(2000,2600,50),
        'dlev'       : N.arange(-80,90,10),
        'dlevobs'    : N.arange(-80,90,10),
        'obsfile'    : os.path.join(datadir,'GLODAP_COARDS/Alk.nc'),
        'obsname'    : 'Alk',
        'obscfac'    : 1.025, # umol/kg -> mmol/m^3
        'obsgrid'    : '1x1d',
        'obsmiss'    : -999.0,
        'obsllabel'  : 'GLODAP',
        'obsrlabel'  : ''
        },
}
