#!/bin/csh -f

#
# nc_time_detrend.csh infile.nc outfile.nc
#
# This script removes the temporal linear trend from each time-dependent
# variable that isn't time in infile.nc and places the result in outfile.nc.
# The detrending is only done if time is the first dimension.
#

set infile   = $1
set outfile  = $2

#
# first copy infile to outfile
#

ncks -O $infile $outfile

ncl << EOF
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
  fid = addfile("$outfile","w")
  vars = getfilevarnames(fid)
  nvars = dimsizes(vars)
  do i = 0, nvars-1
    if (vars(i) .eq. "time")
      continue
    end if
    vardims = getfilevardims(fid, vars(i))
    if (vardims(0) .eq. "time")
       var = fid->\$vars(i)\$
       var_detrend = dtrend(var,False)
       fid->\$vars(i)\$ = dtrend(var,False)
       delete(var)
    end if
    delete(vardims)
  end do
end
EOF
