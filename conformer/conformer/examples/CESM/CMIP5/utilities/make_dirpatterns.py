#!/usr/bin/env python
"""
make_dirpatterns

Command-Line Utility to write all CMIP5 file directory patterns to a file

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from glob import glob
from os import listdir, linesep
from os.path import isdir, join as pjoin
from argparse import ArgumentParser

__PARSER__ = ArgumentParser(description='Write file-directory patterns of CMIP5 data to file')
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

    # Assume that ROOT directory is of the form:
    # ROOT = <root>/<institution>/<model>
    root, inst, model = ROOT.rsplit('/', 2)
    
    # Check for consistency
    if inst != 'NCAR' and model != 'CCSM4':
        raise ValueError('Root appears to be malformed')
    
    # Standard output
    print 'Institution: {}'.format(inst)
    print 'Model: {}'.format(model)
    
    # Fill out a list of CMIP5 directory patterns found on disk
    ncvars = []
    for expt in listdir(ROOT):
        for freq in listdir(pjoin(ROOT, expt)):
            for realm in listdir(pjoin(ROOT, expt, freq)):
                for table in listdir(pjoin(ROOT, expt, freq, realm)):
                    
                    # Pick an ensemble member (doesn't matter which)
                    for ens in listdir(pjoin(pjoin(ROOT, expt, freq, realm, table))):
    
                        # Find list of all latest-version variables
                        vars = listdir(pjoin(ROOT, expt, freq, realm, table, ens, 'latest'))
                    
                        ncvars.append([expt, freq, realm, table, ens] + vars)
    
    # Save to file
    with open('dirpatterns.txt', 'w') as f:
        for ncvar in ncvars:
            line = ' '.join(ncvar)
            f.write(line + linesep)
        

#===================================================================================================
# Command-line Operation
#===================================================================================================
if __name__ == '__main__':
    main()
