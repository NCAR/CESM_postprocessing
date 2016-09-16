#!/bin/csh -f
#
#  Generates a time-average netcdf file from annual average 
#  POP history files.  
#
#  Invoke as
#	pop_tavg_netcdf.csh MSROOT CASENAME startyear endyear OUTFILE
#
#set verbose

set MSROOT = $1
set CASENAME = $2
@ yr0 = $3
@ yr1 = $4
set OTFILE = $5

setenv MSP /${MSROOT}/${CASENAME}/ocn/hist
setenv MSPY /${MSROOT}/${CASENAME}/ocn/proc/tavg/annual

@ yr = $yr0
@ cnt = 0
set files = ()
echo "generating time-average netcdf for years $yr0 to $yr1 of $CASENAME"
while ($yr <= $yr1)

    set year = `printf "%04d" $yr`
    set files = ( $files ${CASENAME}.pop.h.${year}.nc )

    if !(-e ${CASENAME}.pop.h.${year}.nc) then
      hsi -P "get ${MSPY}/${CASENAME}.pop.h.${year}.nc"
    endif
 
    if ($cnt >= 15) then
      wait
      @ cnt = 0
    endif
  @ yr++
  @ cnt++
end
  wait
  if ($yr1 == $yr0) then
    mv $files[1] $OTFILE
  else
    ncra $files $OTFILE
  endif
  if ($CLEANUP_FILES == 1) \rm -f $files
exit 0
