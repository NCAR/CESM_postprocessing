#!/usr/bin/env python2
"""atmosphere diagnostics factory function
"""

# import the Plot modules
from atm_diags_plot_bc import UnknownPlotType
import set1
import set2
import set3
import set4
import set4a
import set5
import set6
import set7
import set8
import set9
import set10
import set11
import set12
import set13
import set14
import set15
import set16
import wset1
import wset2
import wset3
import wset4
import wset5
import cset1
import cset2
import cset3
import cset4
import cset5
import cset6
import cset7

def atmosphereDiagnosticPlotFactory(plot_type,env):
    """Create and return an object of the requested type.
    """
    plot_set = {}
    if plot_type == "set_1":
        for seas in env['seas']:
            plot_set[plot_type+seas] = set1.Set1(seas,env)
    elif plot_type == "set_2":
        plot_set[plot_type] = set2.Set2(env)
    elif plot_type == "set_3":
        for seas in env['seas']:
            plot_set[plot_type+seas] = set3.Set3(seas,env)      
    elif plot_type == "set_4":
        for seas in env['seas']:
            plot_set[plot_type+seas] = set4.Set4(seas,env)
    elif plot_type == "set_4a":
        for seas in env['seas']:
            plot_set[plot_type+seas] = set4a.Set4a(seas,env)
    elif plot_type == "set_5":
        for seas in env['seas']:
            plot_set[plot_type+seas] = set5.Set5(seas,env)
    elif plot_type == "set_6":
        for seas in env['seas']:
            plot_set[plot_type+seas] = set6.Set6(seas,env)
    elif plot_type == "set_7":
        for seas in env['seas']:
            plot_set[plot_type+seas] = set7.Set7(seas,env)
    elif plot_type == "set_8":
        plot_set[plot_type] = set8.Set8(env)
    elif plot_type == "set_9":
        plot_set[plot_type] = set9.Set9(env)
    elif plot_type == "set_10":
        plot_set[plot_type] = set10.Set10(env)
    elif plot_type == "set_11":
        plot_set[plot_type] = set11.Set11(env)
    elif plot_type == "set_12":
        plot_set[plot_type] = set12.Set12(env)
    elif plot_type == "set_13":
        for seas in env['seas']:
            plot_set[plot_type+seas] = set13.Set13(seas,env)
    elif plot_type == "set_14":
        plot_set[plot_type] = set14.Set14(env)
    elif plot_type == "set_15":
        plot_set[plot_type] = set15.Set15(env)
    elif plot_type == "set_16":
        for seas in env['seas']:
            plot_set[plot_type+seas] = set16.Set16(seas,env)
    elif plot_type == "wset_1":
        plot_set[plot_type] = wset1.WSet1(env)
    elif plot_type == "wset_2":
        plot_set[plot_type] = wset2.WSet2(env)
    elif plot_type == "wset_3":
        plot_set[plot_type] = wset3.WSet3(env)
    elif plot_type == "wset_4":
        plot_set[plot_type] = wset4.WSet4(env)
    elif plot_type == "wset_5":
        plot_set[plot_type] = wset5.WSet5(env)
    elif plot_type == "cset_1":
        for seas in env['seas']:
            plot_set[plot_type+seas] = cset1.CSet1(seas,env)
    elif plot_type == "cset_2":
        if 'OBS' not in env['CNTL']:
            for seas in env['seas']:
                plot_set[plot_type+seas] = cset2.CSet2(seas,env)
    elif plot_type == "cset_3":
        plot_set[plot_type] = cset3.CSet3(env)
    elif plot_type == "cset_4":
        for seas in env['seas']:
            plot_set[plot_type+seas] = cset4.CSet4(seas,env)
    elif plot_type == "cset_5":
        plot_set[plot_type] = cset5.CSet5(env)
    elif plot_type == "cset_6":
        plot_set[plot_type] = cset6.CSet6(env)
    elif plot_type == "cset_7":
        for seas in env['seas']:
            plot_set[plot_type+seas] = cset7.CSet7(seas,env)
    else:
        raise UnknownPlotType("WARNING: Unknown plot type requested: '{0}'".format(plot_type))

    return plot_set
