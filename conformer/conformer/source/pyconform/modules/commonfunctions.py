#!/usr/bin/env python

from pyconform.physarray import PhysArray, UnitsError, DimensionsError
from pyconform.functions import Function, is_constant
from cf_units import Unit
from numpy import diff, empty, mean
import numpy as np

#===================================================================================================
# ZonalMeanFunction
#===================================================================================================
class ZonalMeanFunction(Function):
    key = 'zonalmean'

    def __init__(self, data):
        super(ZonalMeanFunction, self).__init__(data)
        data_info = data if is_constant(data) else data[None]
        if not isinstance(data_info, PhysArray):
            raise TypeError('mean: Data must be a PhysArray')

    def __getitem__(self, index):
        data = self.arguments[0][index]
        m = mean(data, axis=3)
        return m
        #return mean(data, axis=3)


#=======================================================================================================================
# BoundsFunction
#=======================================================================================================================
class BoundsFunction(Function):
    key = 'bounds'

    def __init__(self, data, bdim='bnds', location=1, endpoints=1, idata=None):
        super(BoundsFunction, self).__init__(data, bdim=bdim, location=location, endpoints=endpoints, idata=idata)
        data_info = data if is_constant(data) else data[None]
        if not isinstance(data_info, PhysArray):
            raise TypeError('bounds: data must be a PhysArray')
        if not isinstance(bdim, basestring):
            raise TypeError('bounds: bounds dimension name must be a string')
        if location not in [0,1,2]:
            raise ValueError('bounds: location must be 0, 1, or 2')
        if len(data_info.dimensions) != 1:
            raise DimensionsError('bounds: data can only be 1D')
        self._mod_end = bool(endpoints)
        self.add_sumlike_dimensions(data_info.dimensions[0])
        if idata is None:
            self._compute_idata = True
        else:
            self._compute_idata = False
            idata_info = idata if is_constant(idata) else idata[None]
            if not isinstance(idata_info, PhysArray):
                raise TypeError('bounds: interface-data must be a PhysArray')
            if len(idata_info.dimensions) != 1:
                raise DimensionsError('bounds: interface-data can only be 1D')
            self.add_sumlike_dimensions(idata_info.dimensions[0])

    def __getitem__(self, index):
        data = self.arguments[0][index]
        bdim = self.keywords['bdim']
        location = self.keywords['location']

        bnds = PhysArray([1, 1], dimensions=(bdim,))
        new_data = PhysArray(data * bnds, name='bounds({})'.format(data.name))
        if index is None:
            return new_data

        if self._compute_idata:
            dx = diff(data.data)
            if location == 0:
                new_data[:-1,1] = data.data[:-1] + dx
                if self._mod_end:
                    new_data[-1,1] = data.data[-1] + dx[-1]
            elif location == 1:
                hdx = 0.5 * dx
                new_data[1:,0] = data.data[1:] - hdx
                new_data[:-1,1] = data.data[:-1] + hdx
                if self._mod_end:
                    new_data[0,0] = data.data[0] - hdx[0]
                    new_data[-1,1] = data.data[-1] + hdx[-1]
            elif location == 2:
                new_data[1:,0] = data.data[1:] - dx
                if self._mod_end:
                    new_data[0,0] = data.data[0] - dx[0]
            return new_data

        else:
            ddim = data.dimensions[0]
            dslice = index[ddim] if ddim in index else slice(None)
            islice = slice(None, None, dslice.step)
            idata = self.keywords['idata'][islice]

            ifc_len = len(data) + 1
            ifc_data = empty(ifc_len, dtype=data.dtype)
            if len(idata) == ifc_len:
                ifc_data[:] = idata.data[:]
            elif len(idata) == ifc_len - 2:
                ifc_data[1:-1] = idata.data[:]
                if location == 0:
                    ifc_data[0] = data.data[0]
                    ifc_data[-1] = 2*data.data[-1] - data.data[-2]
                elif location == 1:
                    ifc_data[0] = 2*data.data[0] - idata.data[0]
                    ifc_data[-1] = 2*data.data[-1] - idata.data[-1]
                else:
                    ifc_data[0] = 2*data.data[0] - data.data[1]
                    ifc_data[-1] = data.data[-1]
            else:
                raise ValueError('bounds: interface-data length is {} but should be {} or '
                                 '{}'.format(len(idata), ifc_len, ifc_len-2))

            new_data[:,0] = ifc_data[:-1]
            new_data[:,1] = ifc_data[1:]

        return new_data

#===================================================================================================
# AgeofAirFunction
#===================================================================================================
class AgeofAirFunction(Function):
    key = 'ageofair'

    def __init__(self, spc_zm,date,time,lat,lev):
        super(AgeofAirFunction, self).__init__(spc_zm,date,time,lat,lev)

    def __getitem__(self, index):
        p_spc_zm = self.arguments[0][index]
        p_date = self.arguments[1][index]
        p_time = self.arguments[2][index]
        p_lat = self.arguments[3][index]
        p_lev = self.arguments[4][index]

        if index is None:
            return PhysArray(np.zeros((0,0,0)), dimensions=[p_time.dimensions[0],p_lev.dimensions[0],p_lat.dimensions[0]])
      
        spc_zm = p_spc_zm.data
        date = p_date.data
        time = p_time.data
        lat = p_lat.data
        lev = p_lev.data
 
        a = np.zeros((len(time),len(lev),len(lat)))

        # Unpack month and year.  Adjust to compensate for the output convention in h0 files
        year = date/10000
        month = (date/100 % 100)
        day   = date - 10000*year - 100*month

        month = month - 1
        for m in range(len(month)):
            if month[m] == 12:
                year[m] = year[m]-1
                month[m] = 0

        timeyr = year + (month-0.5)/12.

        spc_ref = spc_zm[:,0,0]
        for iy in range(len(lat)):
            for iz in range(len(lev)):
                spc_local = spc_zm[:,iz,iy]
                time0 = np.interp(spc_local,spc_ref,timeyr)
                a[:,iz,iy] = timeyr - time0


        new_name = 'ageofair({}{}{}{}{})'.format(p_spc_zm.name,p_date.name,p_time.name,p_lat.name,p_lev.name)

        return PhysArray(a, name = new_name, units="yr")


#===================================================================================================
# yeartomonth_dataFunction
#===================================================================================================
class YeartoMonth_dataFunction(Function):
    key = 'yeartomonth_data'

    def __init__(self, data, time, lat, lon):
        super(YeartoMonth_dataFunction, self).__init__(data, time, lat, lon)

    def __getitem__(self, index):
        p_data = self.arguments[0][index]
        p_time = self.arguments[1][index]
        p_lat = self.arguments[2][index]
        p_lon = self.arguments[3][index]

        if index is None:
            return PhysArray(np.zeros((0,0,0)), dimensions=[p_time.dimensions[0],p_lat.dimensions[0],p_lon.dimensions[0]])

        data = p_data.data
        time = p_time.data
        lat = p_lat.data
        lon = p_lon.data

        a = np.zeros((len(time)*12,len(lat),len(lon)))
        for i in range(len(time)):
            for j in range(12):
                a[((i*12)+j),:,:] = data[i,:,:]

        new_name = 'yeartomonth_data({}{}{}{})'.format(p_data.name, p_time.name, p_lat.name, p_lon.name)

        return PhysArray(a, name = new_name, units=p_data.units)                 

#===================================================================================================
# yeartomonth_timeFunction
#===================================================================================================
class YeartoMonth_timeFunction(Function):
    key = 'yeartomonth_time'

    def __init__(self, time):
        super(YeartoMonth_timeFunction, self).__init__(time)

    def __getitem__(self, index):
        p_time = self.arguments[0][index]

        if index is None:
            return PhysArray(np.zeros((0)), dimensions=[p_time.dimensions[0]], units=p_time.units, calendar='noleap')

        time = p_time.data
        monLens = [31.0,28.0,31.0,30.0,31.0,30.0,31.0,31.0,30.0,31.0,30.0,31.0]

        a = np.zeros((len(time)*12))
        for i in range(len(time)):
            prev = 0
            for j in range(12):
                a[((i*12)+j)] = float((time[i]-365)+prev+float(monLens[j]/2.0))
                prev += monLens[j]

        new_name = 'yeartomonth_time({})'.format(p_time.name)

        return PhysArray(a, name = new_name, dimensions=[p_time.dimensions[0]], units=p_time.units, calendar='noleap')


#===================================================================================================
# POP_bottom_layerFunction
#===================================================================================================
class POP_bottom_layerFunction(Function):
    key = 'POP_bottom_layer'

    def __init__(self, KMT, data):
        super(POP_bottom_layerFunction, self).__init__(KMT, data)

    def __getitem__(self, index):
        p_KMT = self.arguments[0][index]
        p_data = self.arguments[1][index]

        if index is None:
            return PhysArray(np.zeros((0,0,0)), dimensions=[p_data.dimensions[0],p_data.dimensions[2],p_data.dimensions[3]])

        data = p_data.data
        KMT = p_KMT.data

        a = np.zeros((p_data.shape[0],p_data.shape[2],p_data.shape[3]))

        for j in range(KMT.shape[0]):
            for i in range(KMT.shape[1]):
                a[:,j,i] = data[:,KMT[j,i]-1,j,i] 

        new_name = 'POP_bottom_layer({}{})'.format( p_KMT.name, p_data.name)

        return PhysArray(a, name = new_name, units=p_data.units)


#===================================================================================================
# masked_invalidFunction
#===================================================================================================
class masked_invalidFunction(Function):
    key = 'masked_invalid'

    def __init__(self, data):
        super(masked_invalidFunction, self).__init__(data)

    def __getitem__(self, index):
        p_data = self.arguments[0][index]

        if index is None:
            return PhysArray(np.zeros((0,0,0)), dimensions=[p_data.dimensions[0],p_data.dimensions[1],p_data.dimensions[2]])

        data = p_data.data

        a = np.ma.masked_invalid(data)

        new_name = 'masked_invalid({})'.format(p_data.name)

        return PhysArray(a, name = new_name, units=p_data.units)


#===================================================================================================
# hemisphereFunction
#===================================================================================================
class hemisphereFunction(Function):
    key = 'hemisphere'

    def __init__(self, data, dim='dim', dr='dr'):
        super(hemisphereFunction, self).__init__(data, dim=dim, dr=dr)

    def __getitem__(self, index):
        p_data = self.arguments[0][index]
        dim = self.keywords['dim']
        dr = self.keywords['dr']

        data = p_data.data

        a = None

        # dim0?
        if dim in p_data.dimensions[0]:
            if ">" in dr:
                return p_data[(data.shape[0]/2):data.shape[0],:,:]
            elif "<" in dr:
                return p_data[0:(data.shape[0]/2),:,:]
        # dim1?
        if dim in p_data.dimensions[1]:
            if ">" in dr:
               return p_data[:,(data.shape[1]/2):data.shape[1],:]
            elif "<" in dr:
                return p_data[:,0:(data.shape[1]/2),:]
        # dim2?
        if dim in p_data.dimensions[2]:
            if ">" in dr:
                return p_data[:,:,(data.shape[2]/2):data.shape[2]]
            elif "<" in dr:
                return p_data[:,:,0:(data.shape[2]/2)]


#===================================================================================================
# cice_whereFunction
#===================================================================================================
class cice_whereFunction(Function):
    key = 'cice_where'

    # np.where(x < 5, x, -1) 

    def __init__(self, a1, condition, a2, var, value):
        super(cice_whereFunction, self).__init__(a1, condition, a2, var, value)

    def __getitem__(self, index):
        a1 = self.arguments[0][index]
        condition = self.arguments[1]
        a2 = self.arguments[2]
        var = self.arguments[3][index]
        value = self.arguments[4]

        if index is None:
            return PhysArray(a1.data, dimensions=[a1.dimensions[0],a1.dimensions[1],a1.dimensions[2]])
        
        a = np.ma.zeros(a1.shape)
        for t in range(a1.data.shape[0]):
            if '>=' in condition:
                a[t,:,:] = np.ma.where(a1[t,:,:] >= a2, var, value)
            elif '<=' in condition:
                a[t,:,:] = np.ma.where(a1[t,:,:] <= a2, var, value) 
            elif '==' in condition:
                a[t,:,:] = np.ma.where(a1[t,:,:] == a2, var, value)
            elif '<' in condition:
                a[t,:,:] = np.ma.where(a1[t,:,:] < a2, var, value)
            elif '>' in condition:
                a[t,:,:] = np.ma.where(a1[t,:,:] > a2, var, value)
        return PhysArray(a, dimensions=[a1.dimensions[0],a1.dimensions[1],a1.dimensions[2]], units=var.units) 



