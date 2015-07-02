#!/usr/bin/env python2
"""ocean diagnostics factory function
"""

# import the Plot modules
from ocn_diags_bc import UnknownDiagType
import model_vs_obs
#import model_vs_obs_ecosys
import model_vs_model
#import model_vs_model_ecosys
#import modelts
#import modelts_ecosys

def oceanDiagnosticsFactory(diag_type):
    """Create and return an object of the requested type.
    """
    diag = None
    if diag_type == 'MODEL_VS_OBS':
        diag = model_vs_obs.modelVsObs()

    elif diag_type == 'MODEL_VS_OBS_ECOSYS':
        diag = model_vs_obs_ecosys.modelVsObsEcosys()

    elif diag_type == 'MODEL_VS_MODEL':
        diag = model_vs_model.modelVsModel()

    elif diag_type == 'MODEL_VS_MODEL_ECOSYS':
        diag = model_vs_model_ecosys.modelVsModelEcosys()

    elif diag_type == 'TS':
        diag = modelts.modelTS()

    elif diag_type == 'TS_ECOSYS':
        diag = modelts_ecosys.modelTSEcosys()

    else:
        raise UnknownDiagType('WARNING: Unknown diagnostics type requested: "{0}"'.format(diag_type))

    return diag
