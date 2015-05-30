#!/usr/bin/env python2
"""ocean diagnostics factory function
"""

# import the Plot modules
from ocn_diags_plot_bc import UnknownPlotType
import surface_flux_fields
import surface_fields
import zonal_average_3d_fields
import moc_fields
import western_boundary
import seasonal_cycle
import mixed_layer_depth
import temp_salt_depth
import passive_tracers_depth
import eulerian_velocity

def oceanDiagnosticPlotFactory(plot_type):
    """Create and return an object of the requested type.
    """
    plot = None
    if plot_type == "PM_SFC2D":
        plot = surface_flux_fields.SurfaceFluxFields()

    elif plot_type == "PM_FLD2D":
        plot = surface_fields.SurfaceFields()

    elif plot_type == "PM_FLD3DZA":
        plot = zonal_average_3d_fields.ZonalAverage3dFields()

    elif plot_type == "PM_MOC":
        plot = moc_fields.MOCFields()

    elif plot_type == "PM_WBC":
        plot = western_boundary.WesternBoundary()

    elif plot_type == "PM_SEAS":
        plot = seasonal_cycle.SeasonalCycle()

    elif plot_type == "PM_MLD":
        plot = mixed_layer_depth.MixedLayerDepth()

    elif plot_type == "PM_TSZ":
        plot = temp_salt_depth.TempSaltDepth()

    elif plot_type == "PM_PASSIVEZ":
        plot = passive_tracers_depth.PassiveTracersDepth()

    elif plot_type == "PM_VELZ":
        plot = eulerian_velocity.EulerianVelocity()

    else:
        raise UnknownPlotType("WARNING: Unknown plot type requested: '{0}'".format(plot_type))

    return plot
