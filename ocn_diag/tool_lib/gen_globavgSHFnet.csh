#!/bin/csh -f

#
# gen_globavgSHFnet_netcdf.csh infile outfile
#
# This script uses NCO operators to convert a netcdf
# containing SHF and QFLUX data into one containing 
# area-weighted globally-averaged net SHF data.
#	eg, gen_globavgSHFnet_netcdf.csh g3_5_19.11.pop.h.1980-1985.shf.nc \
#			g3_5_19.11.pop.h.1980-1985.shfnet.globavg.nc
#
#	(hardwired for gx1v5)
#

set i = $1
set j = $2

ncap2 -s 'SHF[time,nlat,nlon]=SHF+QFLUX' $i tmp.nc
ncks -A -v TAREA /cgd/oce/yeager/model_dat/gx1v5_ocn.nc tmp.nc
ncwa -a nlat,nlon -w TAREA -v SHF tmp.nc $j
\rm -f tmp.nc

