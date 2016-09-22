#!/bin/csh -f
#
#  Reads monthly POP netcdfs and creates a concatenated
#  time series netcdf containing specified variables.
#
#  Usage:  
#    gen_pop_monthly_timeseries.csh OUTFILE MSROOT REMOTE_DISK CASE YEAR0 YEAR1 variables
#

set TSFILE = $1
set MSROOT = $2
set REMOTE_DISK = $3
set CASENAME = $4
@ yr0 = $5
@ yr1 = $6

if ($#argv > 6) then
 @ doall = 0
 set vars = ($argv[7-$#argv])
 set nvar = $#vars
 set varstr = $argv[7]
 if ($nvar > 1) then
  foreach i ($argv[7-$#argv])
    set varstr = ${varstr},${i}
  end
 endif
else
 echo "gen_pop_monthly_timeseries.csh:  must specify which variables!"
 exit 1
endif

set year0 = `printf "%04d" $yr0`
set year1 = `printf "%04d" $yr1`

setenv MSP /${MSROOT}/${CASENAME}/ocn/hist
setenv MSPTSM /${MSROOT}/${CASENAME}/ocn/proc/tseries/monthly

set max_msread_cnt  = 15

if (! -e ${TSFILE}) then
hsi -P "ls ${MSPTSM}/${TSFILE}"
if ($status == 0) then
 echo "reading ${TSFILE} from HPSS"
 hsi -P "get ${MSPTSM}/${TSFILE}"
else
  echo "generating monthly time series netcdf from $year0 to $year1 of $CASENAME"
  @ yr = $yr0
  @ msread_cnt = 0
  while ($yr <= $yr1)

    set year = `printf "%04d" $yr`
    hsi -P "ls ${MSP}/${CASENAME}.pop.h.${year}-01.nc"
    if ($status == 0) then
      foreach mon (01 02 03 04 05 06 07 08 09 10 11 12)
        if !(-e ${CASENAME}.pop.h.${year}-${mon}.nc) then
	hsi -P "get ${MSP}/${CASENAME}.pop.h.${year}-${mon}.nc" &
        endif
      end
    else
      mssuntar.csh ${MSROOT} ${CASENAME} $yr $yr
    endif
    wait
    foreach mon (01 02 03 04 05 06 07 08 09 10 11 12)
        ncks -O -v ${varstr} ${CASENAME}.pop.h.${year}-${mon}.nc  \
                ${CASENAME}.pop.h.${year}-${mon}.nc
    end
    ncrcat ${CASENAME}.pop.h.${year}-??.nc ${CASENAME}.pop.h.${year}.nc.ts
    \rm -f ${CASENAME}.pop.h.${year}-??.nc
  @ yr++
  end
  ncrcat ${CASENAME}*.ts ${TSFILE} && \rm -f ${CASENAME}*.ts
  if ($CPY_TO_HSI == 1) hsi -P "mkdir -p $MSPTSM ; put ${TSFILE} : ${MSPTSM}/${TSFILE}"
endif

endif

exit 0
