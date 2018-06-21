#!/usr/bin/env python

from Ngl import vinth2p
from pyconform.physarray import PhysArray, UnitsError, DimensionsError
from pyconform.functions import Function, is_constant
from cf_units import Unit
from numpy import diff, empty

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

        v = vinth2p(datai.data, hbcofa.data, hbcofb.data, plevo.data,
                                 psfc.data, intyp, p0.data, 1, bool(ixtrp))

        v[v==1e+30] = 1e+20

        return PhysArray(v, name=self._new_name, dimensions=self._new_dims, units=datai.units, positive=datai.positive)
