#!/usr/bin/env python
"""atmosphere diagnostics factory function
"""

# import the Plot modules
from .atm_diags_bc import UnknownDiagType
from . import model_vs_obs
from . import model_vs_model

def atmosphereDiagnosticsFactory(diag_type, env):
    """Create and return an object of the requested type.
    """
    diag = None
    if diag_type == 'MODEL_VS_OBS':
        env['CNTL'] = 'OBS'
        env['plot_MAM_climo'] = False
        env['plot_SON_climo'] = False
        diag = model_vs_obs.modelVsObs()

    elif diag_type == 'MODEL_VS_MODEL':
        env['CNTL'] = 'USER'
        diag = model_vs_model.modelVsModel()

    else:
        raise UnknownDiagType('WARNING: Unknown diagnostics type requested: "{0}"'.format(diag_type))

    return diag
