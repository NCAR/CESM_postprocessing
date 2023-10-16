#!/usr/bin/env python
"""lnd diagnostics factory function
"""

# import the Plot modules
from .lnd_diags_plot_bc import UnknownPlotType
from . import set_1_lnd
from . import set_1DiffPlot_lnd
from . import set_1AnomPlot_lnd
from . import set_2_lnd
from . import set_2_seas_lnd
from . import set_3_lnd
from . import set_4_lnd
from . import set_5_lnd
from . import set_6_lnd
from . import set_7_lnd
from . import set_8_ann_cycle_lnd
from . import set_8_ann_cycle
from . import set_8_contour
from . import set_8_DJF_JJA_contour
from . import set_8_trends
from . import set_8_zonal_lnd
from . import set_8_zonal
from . import set_9_lnd
from . import set_10_lnd
from . import set_10_seas_lnd
from . import set_11_lnd
from . import set_11_seas_lnd
from . import set_12_lnd

def LandDiagnosticPlotFactory(plot_type,env):
    """Create and return an object of the requested type.
    """
    plot_set = {}
    if plot_type == "set_1":
        plot_set['set_1'] = set_1_lnd.set_1(env)
        if (env['MODEL_VS_MODEL'] == 'True'):
            plot_set['set_1DiffPlot_lnd'] = set_1DiffPlot_lnd.set_1DiffPlot(env)
            plot_set['set_1AnomPlot_lnd'] = set_1AnomPlot_lnd.set_1AnomPlot(env)
    elif plot_type == "set_2":
        plot_set['set_2'] = set_2_lnd.set_2(env)
       # if (env['MODEL_VS_MODEL'] == 'True'):
       #     plot_set['set_2_seas_lnd'] = set_2_seas_lnd.set_2_seas(env)
    elif plot_type == "set_3":
        plot_set['set_3'] = set_3_lnd.set_3(env)
    elif plot_type == "set_4":
        plot_set['set_4'] = set_4_lnd.set_4(env)
    elif plot_type == "set_5":
        plot_set['set_5'] = set_5_lnd.set_5(env)
    elif plot_type == "set_6":
        plot_set['set_6'] = set_6_lnd.set_6(env)
    elif plot_type == "set_7":
        plot_set['set_7'] = set_7_lnd.set_7(env)
    elif plot_type == "set_8":
        plot_set['set_8_zonal'] = set_8_zonal.set_8_zonal(env)
        plot_set['set_8_trends'] = set_8_trends.set_8_trends(env)
        plot_set['set_8_contour'] = set_8_contour.set_8_contour(env)
        plot_set['set_8_ann_cycle'] = set_8_ann_cycle.set_8_ann_cycle(env)
        plot_set['set_8_DJF_JJA_contour'] = set_8_DJF_JJA_contour.set_8_DJF_JJA_contour(env)
    elif plot_type == "set_8_lnd":
        plot_set['set_8_ann_cycle_lnd'] = set_8_ann_cycle_lnd.set_8_ann_cycle_lnd(env)
        plot_set['set_8_zonal_lnd'] = set_8_zonal_lnd.set_8_zonal_lnd(env)
    elif plot_type == "set_9":
        plot_set['set_9'] = set_9_lnd.set_9(env)
    elif plot_type == "set_10":
        plot_set['set_10'] = set_10_lnd.set_10(env)
    elif plot_type == "set_11":
        plot_set['set_11'] = set_11_lnd.set_11(env)
    elif plot_type == "set_12":
        plot_set['set_12'] = set_12_lnd.set_12(env)
    else:
        raise UnknownPlotType("WARNING: Unknown plot type requested: '{0}'".format(plot_type))

    return plot_set
