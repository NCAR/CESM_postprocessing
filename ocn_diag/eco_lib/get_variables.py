
# Creates list of variables for time-series extraction scripts for given run.
# Created by Ivan Lima on Thu Aug 25 14:07:36 EDT 2011
# Modified by Ernesto Munoz on Fri Dec 7 2012 to include NCAR directories

# Called by extract_tseries.global.sh, extract_tseries.region.sh

import sys, Nio
from ccsm_utils import create_file_list, create_file_list_popdiag

case = sys.argv[1]
WORKDIRPY = sys.argv[2]

#case = 'b40.20th.1deg.bdrd.001'

if WORKDIRPY:
  ftest = create_file_list_popdiag(case,WORKDIRPY)
else:
  ftest = create_file_list(case)

path_2d= 'path="%s"'%((ftest))

if WORKDIRPY:
  fpin = Nio.open_file(create_file_list_popdiag(case,WORKDIRPY)[0])
else:
  fpin = Nio.open_file(create_file_list(case)[0])

varlist_2D = [var for var in fpin.variables.keys()
        if fpin.variables[var].dimensions==('time', 'nlat', 'nlon')]
varlist_3D = [var for var in fpin.variables.keys()
        if fpin.variables[var].dimensions==('time', 'z_t', 'nlat', 'nlon')]
varlist_BIO = [var for var in fpin.variables.keys()
        if fpin.variables[var].dimensions==('time', 'z_t_150m', 'nlat', 'nlon')]
fpin.close()

varlist_2D.sort()
varlist_3D.sort()
varlist_BIO.sort()

strn_2D  = 'varlist2D="%s"'%(','.join(varlist_2D))
strn_3D  = 'varlist3D="%s"'%(','.join(varlist_3D))
strn_BIO = 'varlistBIO="%s"'%(','.join(varlist_BIO))

outfile = 'variables.%s.sh'%case
fpout = open(outfile,'w')
fpout.write('#!/bin/bash\n\n')
fpout.write(strn_2D  + '\n\n')
fpout.write(strn_3D  + '\n\n')
fpout.write(strn_BIO + '\n')
fpout.close()

