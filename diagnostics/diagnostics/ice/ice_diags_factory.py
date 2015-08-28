#!/usr/bin/env python2
"""ice diagnostics factory function
"""

# import the Plot modules
from ice_diags_bc import UnknownDiagType
import model_vs_obs
import model_vs_model

def iceDiagnosticsFactory(diag_type, env):
    """Create and return an object of the requested type.
    """
    diag = None
    if diag_type == 'MODEL_VS_OBS':
        diag = model_vs_obs.modelVsObs()

    elif diag_type == 'MODEL_VS_MODEL':
        diag = model_vs_model.modelVsModel()

    else:
        raise UnknownDiagType('WARNING: Unknown diagnostics type requested: "{0}"'.format(diag_type))

    return diag
