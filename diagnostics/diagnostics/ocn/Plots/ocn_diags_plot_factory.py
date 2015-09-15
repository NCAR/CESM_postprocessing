#!/usr/bin/env python2
"""ocean diagnostics plots factory function
"""

# import the Plot modules
from ocn_diags_plot_bc import UnknownPlotType
import basin_averages
import bolus_velocity
import cpllog_timeseries
import diffusion_depth
import ecosystem_maps
import enso_wavelet_timeseries
import equatorial_upperocean
import eulerian_velocity
import horizontal_vector_fields
import mixed_layer_depth
import moc_annual_timeseries
import moc_fields
import moc_monthly_timeseries
import passive_tracers_depth
import polar_temp_salt
import poplog_timeseries
import regional_area
import regional_mean_timeseries
import seasonal_cycle
import surface_fields
import surface_flux_fields
import temp_salt_depth
import western_boundary
import zonal_average_3d_fields

plot_map = {'PM_BASINAVGTS': 'basin_averages.BasinAverages_{0}()',
            'PM_VELISOPZ': 'bolus_velocity.BolusVelocity_{0}()',
            'PM_CPLLOG': 'cpllog_timeseries.CplLog_{0}()',
            'PM_KAPPAZ': 'diffusion_depth.DiffusionDepth_{0}()',
            'PM_E_MAPS' : 'ecosystem_maps.EcosystemMaps_{0}()',
            'PM_ENSOWVLT': 'enso_wavelet_timeseries.EnsoWavelet_{0}()',
            'PM_UOEQ': 'equatorial_upperocean.EquatorialUpperocean_{0}()',
            'PM_VELZ': 'eulerian_velocity.EulerianVelocity_{0}()',
            'PM_VECV': 'horizontal_vector_fields.HorizontalVectorFields_{0}()',
            'PM_MLD': 'mixed_layer_depth.MixedLayerDepth_{0}()',
            'PM_MOC': 'moc_fields.MOCFields_{0}()',
            'PM_MOCANN': 'moc_annual_timeseries.MOCAnnual_{0}()',
            'PM_MOCMON': 'moc_monthly_timeseries.MOCMonthly_{0}()',
            'PM_PASSIVEZ': 'passive_tracers_depth.PassiveTracersDepth_{0}()',
            'PM_POLARTS': 'polar_temp_salt.PolarTempSalt_{0}()',
            'PM_REGIONALTS': 'regional_area.RegionalArea_{0}()',
            'PM_HORZMN': 'regional_mean_timeseries.RegionalMeanTS_{0}()',
            'PM_SEAS': 'seasonal_cycle.SeasonalCycle_{0}()',
            'PM_FLD2D': 'surface_fields.SurfaceFields_{0}()',
            'PM_SFC2D': 'surface_flux_fields.SurfaceFluxFields_{0}()',
            'PM_TSZ': 'temp_salt_depth.TempSaltDepth_{0}()',
            'PM_FLD3DZA': 'zonal_average_3d_fields.ZonalAverage3dFields_{0}()',
            'PM_WBC': 'western_boundary.WesternBoundary_{0}()',
            'PM_YPOPLOG': 'poplog_timeseries.PopLog_{0}()',}

# TODO diag_type must be 'obs' or 'model' or whatever to match the classname in the plot class
def oceanDiagnosticPlotFactory(diag_type, plot_type):
    """Create and return an object of the requested type.
    """
    plot = None

    try:
        plot_string = plot_map[plot_type].format(diag_type)
    except KeyError:
        # TODO throw a warning that diag type does not exist
        print('WARNING: diag type does not exist')
        pass

    try:
        plot = eval(plot_string)
    except NameError:
        # TODO throw a warning that plot class does not exist
        print('WARNING: plot class does not exist')
        pass

    return plot
