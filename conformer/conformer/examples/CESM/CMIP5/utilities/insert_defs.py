#!/usr/bin/env python
"""
insert_defs

Command-Line Utility to push definitions into a standardization file

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

import json
from os.path import isfile
from argparse import ArgumentParser
from make_stdfile import write_standardization

__PARSER__ = ArgumentParser(description='Push definitions into a JSON standardization file')
__PARSER__.add_argument('stdfile', help='Name of the standardization file')
__PARSER__.add_argument('deffile', help='Name of the definitions file')

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

    STDFILE = args.stdfile
    if not isfile(STDFILE):
        raise ValueError('Standardization file {} not found'.format(STDFILE))
    with open(STDFILE) as f:
        stdinfo = json.load(f)
    
    DEFFILE = args.deffile
    if not isfile(DEFFILE):
        raise ValueError('Definitions file {} not found'.format(DEFFILE))
    with open(DEFFILE) as f:
        vardefs = {}
        for line in f:
            cline = line.split('#')[0].strip()
            if len(cline) > 0 and '=' in cline:
                var, vardef = [s.strip() for s in cline.split('=')[:2]]
                if len(vardef) > 0 and len(var) > 0:
                    vardefs[var] = vardef
    
    overwrites = []
    unchanged = []
    for v in stdinfo:
        if v in vardefs:
            if 'definition' in stdinfo[v]:
                if (isinstance(stdinfo[v]['definition'], basestring) and 
                    vardefs[v] != stdinfo[v]['definition']):
                    overwrites.append((v,vardefs[v]))
                else:
                    unchanged.append(v)
    
    for v, vdef in overwrites:
        print 'Overwritting: {} = {!r} --> {!r}'.format(v, stdinfo[v]['definition'], vdef)
        stdinfo[v]['definition'] = vdef
        print
    if len(unchanged) > 0:
        print 'Not overwriting definitions for {}'.format(', '.join(unchanged))

    write_standardization(STDFILE, stdinfo)
    

#===================================================================================================
# Command-line Operation
#===================================================================================================
if __name__ == '__main__':
    main()
