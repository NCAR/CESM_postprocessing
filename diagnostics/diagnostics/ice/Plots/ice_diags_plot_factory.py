#!/usr/bin/env python2
"""ice diagnostics factory function
"""

# import the Plot modules
from ice_diags_plot_bc import UnknownPlotType
import contour
import contourDiff
import iceSat
import iceSatDiff
import vector
import vectorDiff
import web_hem_avg
import web_hem_avg_wLENS
import web_hem_avgDiff
import web_hem_avg_wLENSDiff
import web_hem_clim
import web_hem_climDiff
import web_reg_avg
import web_reg_avgDiff
import web_reg_clim
import web_reg_climDiff

def iceDiagnosticPlotFactory(plot_type,env):
    """Create and return an object of the requested type.
    """
    plot_set = {}
    if plot_type == "PLOT_CONT":
        for seas in ('jfm', 'amj', 'jas', 'ond', 'ann'):
            plot_set['contour_'+seas] = contour.Contour(seas,env)
        plot_set['iceSat_iceThickness'] = iceSat.IceSat_iceThickness(env)

    elif plot_type == "PLOT_CONT_DIFF":
        for seas in ('jfm', 'amj', 'jas', 'ond', 'ann'):
            plot_set['contour_diff'+seas] = contourDiff.ContourDiff(seas,env)
        plot_set['IceSat_iceThicknessDiff'] = iceSatDiff.IceSat_iceThicknessDiff(env)

    elif plot_type == "PLOT_VECT":
        plot_set['vector'] = vector.Vector(env)

    elif plot_type == "PLOT_VECT_DIFF":
        plot_set['vector_diff'] = vectorDiff.VectorDiff(env)

    elif plot_type == "PLOT_LINE":
        plot_set['web_hem_avg'] = web_hem_avg.Web_Hem_Avg(env)
        plot_set['web_hem_clim'] = web_hem_clim.Web_Hem_Clim(env)
        plot_set['web_hem_avg_wLENS'] = web_hem_avg_wLENS.Web_Hem_Avg_wLENS(env)

    elif plot_type == "PLOT_LINE_DIFF":
        plot_set['web_hem_avgDiff'] = web_hem_avgDiff.Web_Hem_AvgDiff(env)
        plot_set['web_hem_climDiff'] = web_hem_climDiff.Web_Hem_ClimDiff(env)
        plot_set['web_hem_avg_wLENSDiff'] = web_hem_avg_wLENSDiff.Web_Hem_Avg_wLENSDiff(env)

    elif plot_type == "PLOT_REGIONS":
        for reg_num in range(0,16):
            plot_set['web_reg_avg_'+str(reg_num)] = web_reg_avg.Web_Reg_Avg(reg_num, env)
        plot_set['web_reg_clim'] = web_reg_clim.Web_Reg_Clim(env)

    elif plot_type == "PLOT_REGIONS_DIFF":
        for reg_num in range(0,16):
            plot_set['web_reg_avgDiff_'+str(reg_num)] = web_reg_avgDiff.Web_Reg_AvgDiff(reg_num, env)
        plot_set['web_reg_climDiff'] = web_reg_climDiff.Web_Reg_ClimDiff(env)

    else:
        raise UnknownPlotType("WARNING: Unknown plot type requested: '{0}'".format(plot_type))

    return plot_set
