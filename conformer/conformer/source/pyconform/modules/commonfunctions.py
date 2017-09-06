#!/usr/bin/env python

from pyconform.physarray import PhysArray, UnitsError, DimensionsError
from pyconform.functions import Function, is_constant
from cf_units import Unit
from numpy import diff, empty

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


