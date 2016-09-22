#!/bin/csh -f

#
# nc_mon_to_ann.csh infile.nc outfile.nc
#
# This script creates annual averages from monthly one. It operates on the
# time axis, which is assumed to be UNLIMITED. It is assumed there are no
# gaps in the time-series.
#

set infile   = $1
set outfile  = $2

set in_rec_cnt = `ncdump -h $infile | grep 'time = ' | awk '{print $6}' | tr '(' ' '`
@ out_rec_cnt = $in_rec_cnt / 12

ls | grep "${outfile:r}_n[0-9][0-9][0-9][0-9].nc" | xargs \rm -f

cat >! days.cdl << EOF
netcdf days {
dimensions:
	time = 12 ;
variables:
	float days(time) ;
data:
 days = 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ;
}
EOF
ncgen -b days.cdl

@ out_rec_ind = 0
while ( $out_rec_ind < $out_rec_cnt)
   @ in_rec_ind0 = $out_rec_ind * 12
   @ in_rec_ind1 = ($out_rec_ind + 1) * 12 - 1

   set out_rec_stamp = $out_rec_ind
   if ($out_rec_ind < 10)    set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 100)   set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 1000)  set out_rec_stamp = 0${out_rec_stamp}

   ncks -O -h -d time,$in_rec_ind0,$in_rec_ind1 $infile tmp_$$.nc
   ncks -A -h days.nc tmp_$$.nc
   ncwa -h -a time -w days -v days -x tmp_$$.nc ${outfile:r}_n${out_rec_stamp}.nc
   \rm -f tmp_$$.nc

   @ out_rec_ind++
end

if (-f /contrib/bin/ncecat) then
   /contrib/bin/ncecat -O -h -n $out_rec_cnt,4,1 ${outfile:r}_n0000.nc $outfile
else
   ncecat -O -h -n $out_rec_cnt,4,1 ${outfile:r}_n0000.nc $outfile
endif

ncrename -h -d record,time $outfile

ls | grep "${outfile:r}_n[0-9][0-9][0-9][0-9].nc" | xargs \rm -f
