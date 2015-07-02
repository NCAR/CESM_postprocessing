#!/usr/bin/env python2
"""ocean diagnostics plots factory function
"""

# import the Plot modules
from ocn_diags_plot_bc import UnknownPlotType
import surface_flux_fields
import surface_fields
#import zonal_average_3d_fields
#import moc_fields
#import western_boundary
#import seasonal_cycle
#import mixed_layer_depth
#import temp_salt_depth
#import passive_tracers_depth
#import eulerian_velocity
#import bolus_velocity
#import diffusion_depth
#import equatorial_upperocean
#import horizontal_vector_fields
#import polar_temp_salt
#import basin_averages
#import regional_area

plot_map = {'PM_SFC2D': 'surface_flux_fields.SurfaceFluxFields_{0}()',
            'PM_FLD2D': 'surface_fields.SurfaceFields_{0}()'}

# TODO diag_type must be 'obs' or 'model' or whatever to match the classname in the plot class
def oceanDiagnosticPlotFactory(diag_type, plot_type):
    """Create and return an object of the requested type.
    """
    plot = None

    try:
        plot_string = plot_map[plot_type].format(diag_type)
    except KeyError:
        # TODO throw a warning that plot type does not exist
        print('WARNING: diag type does not exist')
        pass

    try:
        plot = eval(plot_string)
    except NameError:
        # TODO throw a warning that plot class does not exist
        print('WARNING: plot class does not exist')
        pass

    return plot
