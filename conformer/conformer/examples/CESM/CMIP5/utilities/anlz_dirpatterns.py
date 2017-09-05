#!/usr/bin/env python
"""
anlz_dirpatterns

Command-Line Utility to analyze data directory patterns in CMIP5 data

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from glob import glob
from os import listdir, linesep
from os.path import isfile, join as pjoin
from argparse import ArgumentParser

__PARSER__ = ArgumentParser(description='Analyze file-directory patterns of CMIP5 data')

#===================================================================================================
# cli - Command-Line Interface
#===================================================================================================
def cli(argv=None):
    """
    Command-Line Interface
    """
    return __PARSER__.parse_args(argv)


#===================================================================================================
# main - Main Program
#===================================================================================================
def main(argv=None):
    """
    Main program
    """
    args = cli(argv)

    if not isfile('cmip5_patterns.txt'):
        raise ValueError('Patterns file not found')

    # Read the patterns file
    with open('cmip5_patterns.txt') as f:
        ncvars = [line.split() for line in f]
                    
    # Analyze freq/realm/table correlations
    frtcorr = {}
    for ncvar in ncvars:
        frt = tuple(ncvar[1:4])
        table = frt[-1]
        if table in frtcorr:
            frtcorr[table].add(frt)
        else:
            frtcorr[table] = {frt}

    print 'Tables with multiple freq/realm/table patterns:'
    multfrt = [table for table in frtcorr if len(frtcorr[table]) > 1]
    if len(multfrt) > 0:
        for table in multfrt:
            print "  Table {}:  {}".format(table,', '.join('/'.join(frt) for frt in frtcorr[table]))
    else:
        print "  None"
    print
    
    # Analyze freq/table correlations
    ftcorr = {}
    for ncvar in ncvars:
        ft = tuple([ncvar[1], ncvar[3]])
        table = ft[-1]
        if table in ftcorr:
            ftcorr[table].add(ft)
        else:
            ftcorr[table] = {ft}

    print 'Tables with multiple freq/table patterns:'
    multft = [table for table in ftcorr if len(ftcorr[table]) > 1]
    if len(multft) > 0:
        for table in multft:
            print "  Table {}:  {}".format(table,', '.join('/'.join(ft) for ft in ftcorr[table]))
    else:
        print "  None"
    print

    print 'Unique freq/table patterns:'
    uniqft = [table for table in ftcorr if len(ftcorr[table]) == 1]
    if len(uniqft) > 0:
        for table in uniqft:
            print "  Table {}:  {}".format(table,', '.join('/'.join(ft) for ft in ftcorr[table]))
    else:
        print "  None"
    print
    
    # Group variables by table 
    vtcorr = {}
    vrcorr = {}
    for ncvar in ncvars:
        expt, freq, realm, table, ens = ncvar[:5]
        vars = ncvar[5:]
        for var in vars:
            if var in vtcorr:
                vtcorr[var].add(table)
            else:
                vtcorr[var] = {table}
            if var in vrcorr:
                vrcorr[var].add(realm)
            else:
                vrcorr[var] = {realm}

    print 'Variables in multiple tables:'
    multvt = [var for var in vtcorr if len(vtcorr[var]) > 1]
    if len(multvt) > 0:
        for var in multvt:
            print "  Variable {}:  {}".format(var,', '.join(vtcorr[var]))
    else:
        print "  None"
    print
    
    print 'Variables in multiple realms:'
    multvr = [var for var in vrcorr if len(vrcorr[var]) > 1]
    if len(multvr) > 0:
        for var in multvr:
            print "  Variable {}:  {}".format(var,', '.join(vrcorr[var]))
    else:
        print "  None"
    print
    
    # Analyze variable groups by freq/realm/table patterns
    vgroups = {}
    for ncvar in ncvars:
        frt = '/'.join(ncvar[1:4])
        vars = ncvar[5:]
        if frt not in vgroups:
            vgroups[frt] = [set(vars)]
        else:
            vgroups[frt].append(set(vars))
    
    # Determine if all variable groups are subsets of the largest set
    vgsubsets = {}
    vgsuperset = {}
    for frt in vgroups:
        vgs = vgroups[frt]
        largest = set()
        for vg in vgroups[frt]:
            if len(vg) > len(largest):
                largest = vg
            elif len(vg) == len(largest):
                largest.update(vg)
        vgsuperset[frt] = largest
        vgsubsets[frt] = set()
        for vg in vgroups[frt]:
            if not vg.issubset(largest):
                unmatched = vg - largest
                for v in unmatched:
                    vgsubsets[frt].add(v)
    
    print 'Variables in groups that can not represent a single freq/realm/table set:'
    uniqsubsets = [frt for frt in vgsubsets if len(vgsubsets[frt]) > 0]
    if len(uniqsubsets) > 0:
        for frt in uniqsubsets:
            print "  {}: {}".format(frt, ', '.join(sorted(vgsubsets[frt])))
    else:
        print "  None"
    print

    print 'Variable groups representing a single freq/realm/table set:'
    for frt in vgsuperset:
        print "  {}: {}".format(frt, ', '.join(sorted(vgsuperset[frt])))
    print
             

#===================================================================================================
# Command-line Operation
#===================================================================================================
if __name__ == '__main__':
    main()
