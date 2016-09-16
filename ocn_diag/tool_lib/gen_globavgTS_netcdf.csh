#!/bin/csh -f

#
# gen_globavgTS_netcdf.csh var infile outfile
#
# This script uses NCO operators to convert a netcdf
# containing POP TEMP or SALT data into one containing 
# volume-weighted globally-averaged TEMP or SALT data.
#	eg, gen_globavgTS_netcdf.csh TEMP g3_5_19.11.pop.h.1980-1985.temp.nc \
#			g3_5_19.11.pop.h.1980-1985.temp.globavg.nc
#
#	(hardwired for gx1v5)
#

set var = $1
set i = $2
set j = $3

ncks -A -v TVOLUME /cgd/oce/yeager/model_dat/gx1v5_tcell_volume.nc $i
ncwa -a z_t,nlat,nlon -w TVOLUME -v $var $i $j

