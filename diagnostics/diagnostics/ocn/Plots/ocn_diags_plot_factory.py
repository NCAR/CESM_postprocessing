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
import bolus_velocity
import diffusion_depth
import equatorial_upperocean
import horizontal_vector_fields
import polar_temp_salt
import basin_averages
import regional_area


plot_map = {'PM_SFC2D': 'surface_flux_fields.SurfaceFluxFields_{0}()',
           'PM_FLD2D': 'surface_fields.SurfaceFields_{0}()'}

# TODO diag_type must be 'obs' or 'control' or whatever to match the classname in the plot class
def oceanDiagnosticPlotFactory(diag_type, plot_type):
    """Create and return an object of the requested type.
    """
    plot = None

    try:
        plot_string = plot_map[plot_type].format(diag_type)
    except KeyError:
        # TODO throw a warning that plot type does not 
        pass

    try:
        plot = eval(plot_string)
    except NameError:
        # TODO throw a warning that plot class does not exist
        pass

#******


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

    elif plot_type == "PM_VELISOPZ":
        plot = bolus_velocity.BolusVelocity()

    elif plot_type == "PM_KAPPAZ":
        plot = diffusion_depth.DiffusionDepth()

    elif plot_type == "PM_UOEQ":
        plot = equatorial_upperocean.EquatorialUpperocean()

    elif plot_type == "PM_VECV":
        plot = horizontal_vector_fields.HorizontalVectorFields()

    elif plot_type == "PM_POLARTS":
        plot = polar_temp_salt.PolarTempSalt()

    elif plot_type == "PM_BASINAVGTS":
        plot = basin_averages.BasinAverages()

    elif plot_type == "PM_REGIONALTS":
        plot = regional_area.RegionalArea()

    else:
        raise UnknownPlotType("WARNING: Unknown plot type requested: '{0}'".format(plot_type))

    return plot
