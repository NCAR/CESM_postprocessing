#!/usr/bin/env python
"""
make_stdfile

Command-Line Utility to make a standardization file from a set of "correct" output files

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

import json
import numpy
from netCDF4 import Dataset
from glob import glob
from os import listdir, linesep
from os.path import isdir, join as pjoin
from argparse import ArgumentParser

__PARSER__ = ArgumentParser(description='Create a standardization file from a set of output files')
__PARSER__.add_argument('-c', '--ccps', default=False, action='store_true',
                        help='Assume CCPS-style data output')
__PARSER__.add_argument('-s', '--skip', default=[], action='append',
                        help='Skip writing attributes with the given name')
__PARSER__.add_argument('root', help='Root directory where output files can be found')

#===================================================================================================
# cli - Command-Line Interface
#===================================================================================================
def cli(argv=None):
    """
    Command-Line Interface
    """
    return __PARSER__.parse_args(argv)


#===================================================================================================
# StandardizationEncoder
#===================================================================================================
class StandardizationEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, numpy.integer):
            return int(obj)
        elif isinstance(obj, numpy.floating):
            return float(obj)
        elif isinstance(obj, numpy.ndarray):
            return obj.tolist()
        else:
            return super(MyEncoder, self).default(obj)


#===================================================================================================
# write_standardization
#===================================================================================================
def write_standardization(name, info):
    with open(name, 'w') as f:
        json.dump(info, f, indent=4, cls=StandardizationEncoder, sort_keys=True)


#===================================================================================================
# main - Main Program
#===================================================================================================
def main(argv=None):
    """
    Main program
    """
    args = cli(argv)

    ROOT = args.root.rstrip('/')
    if not isdir(ROOT):
        raise ValueError('Root must be a directory')

    # CCPS-Style of CMIP5 data output (lowest directory where NetCDF files are found):
    # <root>/<table>/CMOR/CMIP5/output/<institution>/<model>/<experiment>/<frequency>/<realm>/<variable>/<ensemble>
    
    # ESGF-Style of CMIP5 data output (lowest directory where NetCDF files are found):
    # <root>/CMIP5/output1/<institution>/<model>/<experiment>/<frequency>/<realm>/<table>/<ensemble>/latest/<variable>
    
    # Note: <ensemble> and <variable> are in a different order, so we have to automate the way
    # that the <ensemble> is chosen.  For this purpose, we take the <ensemble> that has the lowest
    # alphanumeric sort order.
    
    # Hence, the ROOT directory that is supplied should stop before <variable> or <ensemble>:
    # CCPS: <root>/<table>/CMOR/CMIP5/output/<institution>/<model>/<experiment>/<frequency>/<realm>/
    # ESGF: <root>/CMIP5/output1/<institution>/<model>/<experiment>/<frequency>/<realm>/<table>/
    
    # From both of these ROOT strings, we can extract <institution>, <model>, <experiment>,
    # <frequency>, <realm>, and <table>:
    if args.ccps:
        root, table, CMOR, CMIP5, output, inst, model, expt, freq, realm = ROOT.rsplit('/', 9)
    else:
        root, inst, model, expt, freq, realm, table = ROOT.rsplit('/', 6)
    
    # Check for consistency
    if inst != 'NCAR' and model != 'CCSM4':
        raise ValueError('Root appears to be malformed')
    
    print 'Institution:     {}'.format(inst)
    print 'Model:           {}'.format(model)
    print 'Experiment:      {}'.format(expt)
    print 'Frequency:       {}'.format(freq)
    print 'Realm:           {}'.format(realm)
    print 'Table:           {}'.format(table)
    
    # Pick a common ensemble member for all variables
    vardirs = {}
    if args.ccps:
        rips = None
        for var in listdir(ROOT):
            vdir = pjoin(ROOT, var)
            vrips = set(listdir(vdir))
            if len(vrips) > 0:
                vardirs[var] = vdir
                if rips is None:
                    rips = vrips
                else:
                    rips.intersection_update(vrips)
        rip = sorted(rips)[0]
        for var in vardirs:
            vardirs[var] = pjoin(vardirs[var], rip)
    else:
        rip = sorted(listdir(ROOT))[0]
        vdir = pjoin(ROOT, rip, 'latest')
        for var in listdir(vdir):
            vardirs[var] = pjoin(vdir, var)
        
    print 'Ensemble Member: {}'.format(rip)
    print
    
    skipatts = set(args.skip)
    
    stdinfo = {}
    for var in vardirs:
        vdir = vardirs[var]
        vfile = sorted(glob(pjoin(vdir,'*.nc')))[0]
        vds = Dataset(vfile)
        fattrs = {str(a):vds.getncattr(a) for a in vds.ncattrs() if a not in skipatts}
        for v in vds.variables:
            vobj = vds.variables[v]
            if v not in stdinfo:
                stdinfo[v] = {"attributes": {str(a):vobj.getncattr(a)
                                             for a in vobj.ncattrs() if a not in skipatts},
                              "datatype": str(vobj.dtype),
                              "dimensions": [str(d) for d in vobj.dimensions]}
                if 'comment' in vobj.ncattrs():
                    stdinfo[v]["definition"] = vobj.getncattr('comment')
                else:
                    stdinfo[v]["definition"] = ''
                if v == var:
                    fname = '{}_{}_{}_{}_{}_YYYYMM.nc'.format(v,table,model,expt,rip)
                    stdinfo[v]["file"] = {"filename": fname,
                                          "attributes": fattrs}
    
    stdname = '{}_{}_{}_{}.json'.format(model, expt, realm, table)
    write_standardization(stdname, stdinfo)
    print "Done."
    

#===================================================================================================
# Command-line Operation
#===================================================================================================
if __name__ == '__main__':
    main()
