#!/bin/csh -f

#
# nc_mon_anom.csh infile.nc outfile.nc
#
# This script subtracts the mean monthly cycle from a time series of
# monthly values. It operates on the time axis, which is assumed to
# be UNLIMITED. It is assumed there are no gaps in the time-series.
#

set infile   = $1
set outfile  = $2
set outfiler = $outfile:r

set axis_name = `ncdump -h $infile | grep UNLIMITED | awk '{print $1}'`
set in_rec_cnt = `ncdump -h $infile | grep UNLIMITED | awk '{print $6}' | tr '(' ' '`
@ out_rec_cnt = $in_rec_cnt / 12

@ out_rec_ind = 0
while ( $out_rec_ind < $out_rec_cnt)
   @ in_rec_ind0 = $out_rec_ind * 12
   @ in_rec_ind1 = ($out_rec_ind + 1) * 12 - 1

   set out_rec_stamp = $out_rec_ind
   if ($out_rec_ind < 10)    set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 100)   set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 1000)  set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 10000) set out_rec_stamp = 0${out_rec_stamp}

   ncks -O -h -d $axis_name,$in_rec_ind0,$in_rec_ind1 $infile ${outfiler}_${out_rec_stamp}.nc

   @ out_rec_ind++
end

ncea -O -h -n $out_rec_cnt,5,1 ${outfiler}_00000.nc tmp_mean_$outfile.nc

@ out_rec_ind = 0
while ( $out_rec_ind < $out_rec_cnt)
   set out_rec_stamp = $out_rec_ind
   if ($out_rec_ind < 10)    set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 100)   set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 1000)  set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 10000) set out_rec_stamp = 0${out_rec_stamp}

   ncdiff -O -h ${outfiler}_${out_rec_stamp}.nc tmp_mean_$outfile.nc ${outfiler}_anom_${out_rec_stamp}.nc
   \rm -f ${outfiler}_${out_rec_stamp}.nc

   @ out_rec_ind++
end

ncrcat -O -h -n $out_rec_cnt,5,1 ${outfiler}_anom_00000.nc $outfile

@ out_rec_ind = 0
while ( $out_rec_ind < $out_rec_cnt)
   set out_rec_stamp = $out_rec_ind
   if ($out_rec_ind < 10)    set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 100)   set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 1000)  set out_rec_stamp = 0${out_rec_stamp}
   if ($out_rec_ind < 10000) set out_rec_stamp = 0${out_rec_stamp}
   \rm -f ${outfiler}_anom_${out_rec_stamp}.nc
   @ out_rec_ind++
end
\rm -f tmp_mean_$outfile.nc

