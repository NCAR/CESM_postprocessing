#!/usr/bin/env python
"""
anlz_stdfile

Command-Line Utility to show attributes/definitions/etc in a standardization file

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

import json
from os.path import isfile
from argparse import ArgumentParser
from tornado.options import define

__PARSER__ = ArgumentParser(description='Pull out information from a JSON standardization file')
__PARSER__.add_argument('-v', '--variable', default=None, help='Name of variable to pull from')
__PARSER__.add_argument('-a', '--attribute', default=None, help='Name of attribute to pull')
__PARSER__.add_argument('-d', '--definition', default=False, action='store_true',
                        help='Pull the definitions (instead of attributes).  '
                             'Attribute argument ignored, if specified.')
__PARSER__.add_argument('specfile', help='Name of specfile to pull from')

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

    SPECFILE = args.specfile
    if not isfile(SPECFILE):
        raise ValueError('Specfile {} not found'.format(SPECFILE))
    
    with open(SPECFILE) as f:
        spec = json.load(f)
    
    if args.variable is None:
        vars = [v for v in spec]
    else:
        if args.variable in spec:
            vars = [args.variable]
        else:
            raise ValueError('Variable {} not found in specfile'.format(args.variable))
    
    undefined = []
    missingdfns = []
    defined = []
    for v in sorted(vars):
        if args.definition:
            if 'definition' in spec[v]:
                vdef = spec[v]['definition']
                if vdef == '':
                    undefined.append(v)
                else:
                    defined.append((v, vdef))
            else:
                missing.append(v)
        else:
            if args.attribute is not None:
                vatts = spec[v]['attributes']
            else:
                vatts = {}
                if args.attribute in spec[v]['attributes']:
                    vatts = {args.attribute:  spec[v]['attributes'][args.attribute]}
            print '{}:'.format(v)
            for a in vatts:
                print '   {}: {}'.format(a, vatts[a])
    
    if args.definition:
        for v, vdef in defined:
            print '{} = {}'.format(v, vdef)
        print
        print 'Undefined Variables: {}'.format(', '.join(undefined))
        if len(missingdfns) > 0:
            print
            print 'NO DEFINITIONS: {}'.format(', '.join(missingdfns))
    

#===================================================================================================
# Command-line Operation
#===================================================================================================
if __name__ == '__main__':
    main()
