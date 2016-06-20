#!/usr/bin/env python2
"""ocean diagnostics factory function
"""

# import the Plot modules
from ocn_diags_bc import UnknownDiagType
import model_vs_obs
import model_vs_obs_ecosys
import model_vs_control
#import model_vs_control_ecosys
import model_timeseries
#import modelts_ecosys

def oceanDiagnosticsFactory(diag_type):
    """Create and return an object of the requested type.
    """
    diag = None
    if diag_type == 'MODEL_VS_OBS':
        diag = model_vs_obs.modelVsObs()

    elif diag_type == 'MODEL_VS_OBS_ECOSYS':
        diag = model_vs_obs_ecosys.modelVsObsEcosys()

    elif diag_type == 'MODEL_VS_CONTROL':
        diag = model_vs_control.modelVsControl()

    elif diag_type == 'MODEL_VS_CONTROL_ECOSYS':
        diag = model_vs_control_ecosys.modelVsControlEcosys()

    elif diag_type == 'MODEL_TIMESERIES':
        diag = model_timeseries.modelTimeseries()

    elif diag_type == 'MODEL_TIMESERIES_ECOSYS':
        diag = modelts_ecosys.modelTSEcosys()

    else:
        raise UnknownDiagType('WARNING: Unknown diagnostics type requested: "{0}"'.format(diag_type))

    return diag
