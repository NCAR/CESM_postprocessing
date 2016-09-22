#!/bin/csh -f

#
# gen_maxmoc_netcdf.csh infile outfile
#
# This script uses NCO operators to convert a netcdf
# containing POP MOC data into one containing max MOC
# data.
#	eg, gen_maxmoc_netcdf.csh g3_5_19.11.pop.h.1980-1985.moc.nc \
#			g3_5_19.11.pop.h.1980-1985.maxmoc.nc
#
# Computes max within region moc_z > 500.m  & lat_aux_grid > 28N
#	(hardwired for gx1v5)
#

set i = $1
set j = $2

ncwa -d moc_z,32, -d lat_aux_grid,278, -a moc_z,lat_aux_grid -v MOC -y max $i $j

