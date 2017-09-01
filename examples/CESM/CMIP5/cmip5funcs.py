#!/usr/bin/env python

from Ngl import vinth2p
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
            

#=======================================================================================================================
# VertInterpFunction
#=======================================================================================================================
class VertInterpFunction(Function):
    key = 'vinth2p'

    def __init__(self, datai, hbcofa, hbcofb, plevo, psfc, p0, intyp=1, ixtrp=0):
        super(VertInterpFunction, self).__init__(datai, hbcofa, hbcofb, plevo, psfc, p0, intyp=intyp, ixtrp=ixtrp)
        datai_info = datai if is_constant(datai) else datai[None]
        hbcofa_info = hbcofa if is_constant(hbcofa) else hbcofa[None]
        hbcofb_info = hbcofb if is_constant(hbcofb) else hbcofb[None]
        plevo_info = plevo if is_constant(plevo) else plevo[None]
        psfc_info = psfc if is_constant(psfc) else psfc[None]
        p0_info = p0 if is_constant(p0) else p0[None]

        if not all(isinstance(obj, PhysArray)
                   for obj in (datai_info, hbcofa_info, hbcofb_info, plevo_info, psfc_info, p0_info)):
            raise TypeError('vinth2p: arrays must be PhysArrays')
        
        if len(datai_info.dimensions) != 3 and len(datai_info.dimensions) != 4:
            raise DimensionsError('vinth2p: interpolated data must be 3D or 4D')
        if len(hbcofa_info.dimensions) != 1 or len(hbcofb_info.dimensions) != 1:
            raise DimensionsError('vinth2p: hybrid a/b coefficients must be 1D')
        if len(plevo_info.dimensions) != 1:
            raise DimensionsError('vinth2p: output pressure levels must be 1D')
        if len(p0_info.dimensions) != 0:
            raise DimensionsError('vinth2p: reference pressure must be scalar')

        dlevi = hbcofa_info.dimensions[0]
        if dlevi != hbcofb_info.dimensions[0]:
            raise DimensionsError('vinth2p: hybrid a/b coefficients do not have same dimensions')
        dlevo = plevo_info.dimensions[0]
        self.add_sumlike_dimensions(dlevi, dlevo)

        for d in psfc_info.dimensions:
            if d not in datai_info.dimensions:
                raise DimensionsError(('vinth2p: surface pressure dimension {!r} not found '
                                       'in input data dimensions').format(d))
        dlat, dlon = psfc_info.dimensions[-2:]

        if (dlevi, dlat, dlon) != datai_info.dimensions[-3:]:
            raise DimensionsError(('vinth2p: input data dimensions {} inconsistent with the '
                                   'dimensions of surface pressure {} and hybrid coefficients {}'
                                   '').format(datai_info.dimensions, psfc_info.dimensions, hbcofa_info.dimensions))

        ilev = datai_info.dimensions.index(dlevi)

        new_dims = [d for d in datai_info.dimensions]
        new_dims[ilev] = dlevo
        self._new_dims = tuple(new_dims)
        
        self._new_name = 'vinth2p({}, plevs={})'.format(datai_info.name, plevo_info.name)

    def __getitem__(self, index):
        datai = self.arguments[0][index]
        hbcofa = self.arguments[1][index]
        hbcofb = self.arguments[2][index]
        plevo = self.arguments[3][index].convert('mbar')
        psfc = self.arguments[4][index].convert('Pa')
        p0 = self.arguments[5][index].convert('mbar')
        intyp = self.keywords['intyp']
        ixtrp = self.keywords['ixtrp']
        
        return PhysArray(vinth2p(datai.data, hbcofa.data, hbcofb.data, plevo.data,
                                 psfc.data, intyp, p0.data, 1, bool(ixtrp)), name=self._new_name,
                         dimensions=self._new_dims, units=datai.units, positive=datai.positive)
