
# Common resources for time-series plots.
# Created by Ivan Lima on Fri Aug 26 14:59:59 EDT 2005
# Last modified on Mon Jun 15 15:55:43 EDT 2009

import numpy as N
import numpy.ma as MA
import Nio
from ccsm_utils import dpm

spd = 60.*60.*24. # seconds per day

variables = {
    'TEMP' : {
        'label' : r'Temperature',
        'units' : r'$^{o}$C'
        },
    'SALT' : {
        'label' : r'Salinity',
        'units' : r'PSU',
        #'cfac'  : 1.e+3 # g/kg -> PSU
        },
    'NO3' : {
        'label' : r'NO$_3$',
        'units' : r'mmol m${-3}$'
        },
    'NH4' : {
        'label' : r'NH$_4$',
        'units' : r'mmol m$^{-3}$'
        },
    'PO4' : {
        'label' : r'PO$_4$',
        'units' : r'mmol m$^{-3}$'
        },
    'SiO3' : {
        'label' : r'SiO$_3$',
        'units' : r'mmol m$^{-3}$'
        },
    'Fe' : {
        'label' : r'Fe',
        'units' : r'$\rho$M',
        'cfac'  : 1.e+6 # mmol/m^3 -> pico molar
        },
    'NO3_excess' : {
        'label' : r'Excess NO$_3$',
        'units' : r'mmol m$^{-3}$'
        },
    'DIC' : {
        'label' : r'DIC',
        'units' : r'mmol m$^{-3}$'
        },
    'ALK' : {
        'label' : r'Alkalinity',
        'units' : r'meq m$^{-3}$'
        },
    'O2' : {
        'label' : r'O$_2$',
        'units' : r'mmol m$^{-3}$'
        },
    'spChl' : {
        'label' : r'Small Phyto. Chlorophyll',
        'units' : r'mg Chl m$^{-3}$'
        },
    'diatChl' : {
        'label' : r'Diatom Chlorophyll',
        'units' : r'mg Chl m$^{-3}$'
        },
    'diazChl' : {
        'label' : r'Diazotrophs Chlorophyll',
        'units' : r'mg Chl m$^{-3}$'
        },
    'totChl' : {
        'label' : r'Total Chlorophyll',
        'units' : r'mg Chl m$^{-3}$',
        },
    #'spC' : {
    #    'label' : r'Small Phyto. Carbon',
    #    'units' : r'mg C m$^{-3}$',
    #    'cfac'  : 12.01
    #    },
    #'diatC' : {
    #    'label' : r'Diatom Carbon',
    #    'units' : r'mg C m$^{-3}$',
    #    'cfac'  : 12.01
    #    },
    #'diazC' : {
    #    'label' : r'Diazotrophs Carbon',
    #    'units' : r'mg C m$^{-3}$',
    #    'cfac'  : 12.01
    #    },
    'phytoC' : {
        'label' : r'Total Phyto Carbon',
        'units' : r'mg C m$^{-3}$',
        'cfac'  : 12.01
        },
    #'phyto_mu' : {
    #    'label' : r'Phyto $\mu$',
    #    'units' : r'd$^{-1}',
    #    'cfac'  : spd # 1/sec -> 1/day
    #    },
    'pCO2SURF' : {
        'label' : r'Surface pCO$_2$',
        'units' : r'ppmv'
        },
    'STF_O2' : {
        'label' : r'Air-Sea O$_2$ Flux',
        'units' : r'mol m$^{-2}$ y$^{-1}$',
        'cfac'  : 1.e-2 * 1.e-3 * spd * 365 # mmol/m^3*cm/sec -> mol/m^2/year
        },
    'FG_CO2' : {
        'label' : r'Air-Sea CO$_2$ Flux',
        'units' : r'mol m$^{-2}$ y$^{-1}$',
        'cfac'  : 1.e-2 * 1.e-3 * spd * 365 # mmol/m^3*cm/sec -> mol/m^2/year
        },
    'IRON_FLUX' : {
        'label' : r'Surface Iron Flux',
        'units' : r'mmol m$^{-2}$ y$^{-1}$',
        'cfac'  : 1.e-3 * 1.e+4 * spd * 365 # nmol/cm^3/sec -> mmol/m^2/year
        },
    'o2_min_vol' : {
        'label' : r'Ocean Volume with oxygen < oxygen_min',
        'units' : r'Percent'
#       'label' : r'Ocean Volume with O$_2$ $<$ O$_{2}^{min}$',
#       'units' : r'\%'
        },
    'photoC_sp' : {
        'label' : r'Small Phyto. Primary Production',
        'units' : r'Pg C y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 # mmol/m^3/sec -> mol/m^3/year
        },
    'photoC_diat' : {
        'label' : r'Diatom Primary Production',
        'units' : r'Pg C y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 # mmol/m^3/sec -> mol/m^3/year
        },
    'photoC_diaz' : {
        'label' : r'Diazotroph Primary Production',
        'units' : r'Pg C y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 # mmol/m^3/sec -> mol/m^3/year
        },
    'photoC_tot' : {
        'label' : r'Total Primary Production',
        'units' : r'Pg C y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 # mmol/m^3/sec -> mol/m^3/year
        },
    'diaz_Nfix' : {
        'label' : r'Nitrogen Fixation',
        'units' : r'Tg N y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 # mmol/m^3/sec -> mol/m^3/year
        },
    'DENITRIF' : {
        'label' : r'Denitrification',
        'units' : r'Tg N y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 # mmol/m^3/sec -> mol/m^3/year
        },
    'NITRIF' : {
        'label' : r'Nitrification',
        'units' : r'Tmol N y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 # mmol/m^3/sec -> mol/m^3/year
        },
    'CaCO3_form' : {
        'label' : r'CaCO$_3$ Production',
        'units' : r'Pg C y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 # mmol/m^3/sec -> mol/m^3/year
        },
    'bSi_form' : {
        'label' : r'SiO$_3$ Production',
        'units' : r'Tmol Si y$^{-1}$',
        'cfac'  : 1.e-3 * spd * 365 # mmol/m^3/sec -> mol/m^3/year
        },
    'ATM_CO2' : {
        'label' : 'Atmospheric CO$_2$',
        'units' : 'ppmv'
        },
}

def read_region_names(infile):
    """
    Read sub-regions mask names.
    Returns:
        nreg         : number of regions
        region_lname : region long name
        region_sname : region short name
    """
    fpreg = Nio.open_file(infile, 'r')
    nreg  = fpreg.dimensions['nreg']

    # get region long names
    worklist = [fpreg.variables['REGION_lname'][n,:].tostring()
                for n in range(nreg)]
    region_lname = [strn.rstrip('\x00') for strn in worklist]

    # get region short names
    worklist = [fpreg.variables['REGION_sname'][n,:].tostring()
                for n in range(nreg)]
    region_sname = [strn.rstrip('\x00') for strn in worklist]

    fpreg.close()
    return nreg, region_lname, region_sname

def extract_same_period(day,tseries):
    """
    Extract overlaping periods from two time-series.
    day     : list containing two "time" arrays
    tseries : list containing two time-series arrays

    """
    day_beg = max([d[0] for d in day])
    day_end = min([d[-1] for d in day])
    for n in range(len(day)):
        ibeg = day[n].searchsorted(day_beg)
        iend = day[n].searchsorted(day_end) + 1
        tseries[n] = tseries[n][ibeg:iend]

    day_new = day[n][ibeg:iend]
    return day_new, MA.array(tseries)

def make_same_size(day_list,tseries_list):
    """
    Make all time-series the same size as longest time-series and
    combine them into one [ncases,ntime,...] array for plotting.
    """
    # find beg and end of period that encompasses all time-series
    day_beg = min([d.min() for d in day_list])
    day_end = max([d.max() for d in day_list])

    # find indices in 1000 year time array
    thousand_years = N.resize(dpm,12*1000).cumsum()
    ibeg = thousand_years.searchsorted(day_beg)
    iend = thousand_years.searchsorted(day_end)

    # set new array dimensions and create array
    day    = thousand_years[ibeg:iend+1]
    ncases = len(tseries_list)
    ntime  = iend -  ibeg + 1
    if tseries_list[0].ndim == 2: # regional time-series [ntime,nreg]
        data = MA.masked_all((ncases,ntime,tseries_list[0].shape[-1]),float)
    else:
        data = MA.masked_all((ncases,ntime),float)

    # fill new array according to time index
    for n in range(ncases):
        i1 = day.searchsorted(day_list[n].min())
        i2 = day.searchsorted(day_list[n].max()) + 1
        data[n,i1:i2,...] = tseries_list[n]

    return day, data

def set_legend_labels(caselist,nyrs,pres,avgs=False):
    ncase = len(caselist)
    if ncase > 1:
        prefix = 'comp_tseries_'
    else:
        prefix = 'tseries_'

    if avgs:
        pres.xyLineColors = color_list[:ncase]
        pres.xyExplicitLegendLabels = ['%s %d-year running mean'%(case,nyrs)
            for case in caselist]
    else:
        pres.xyLineColors = color_list[:ncase] + color_list[:ncase]
        pres.xyExplicitLegendLabels = (
            ['%s monthly mean'%(case) for case in caselist] +
            ['%s %d-year running mean'%(case,nyrs) for case in caselist])

    return prefix
