#!/bin/csh -f
#
#  Untars POP history files which have been tarred into
#    annual chunks, then writes back monthly files to MSS.
#    shell:  MSPROJ, MSRPD
#
#  Invoke as
#	mssuntar.csh MSROOT CASENAME startyear endyear
#

set MSROOT = $1
set CASENAME = $2
@ yr0 = $3
@ yr1 = $4

setenv MSP /${MSROOT}/${CASENAME}/ocn/hist

@ yr = $yr0
while ($yr <= $yr1)

    set year = `printf "%04d" $yr`
    hsi -P "ls ${MSP}/${CASENAME}.pop.h.${year}.tar"

    if ($status == 0) then
      echo "untarring mss:${MSP}/${CASENAME}.pop.h.${year}.tar"
      hsi -P "get ${MSP}/${CASENAME}.pop.h.${year}.tar"
    else
      echo "tar file not found ${MSP}/${CASENAME}.pop.h.${year}.tar"
      exit 1
    endif
    tar xf ${CASENAME}.pop.h.${year}.tar 
    if ($status == 1) then
      echo "ERROR untarring ${CASENAME}.pop.h.${year}.tar"
      exit 1
    else
      \rm -f ${CASENAME}.pop.h.${year}.tar
    endif
  @ yr++
end
wait
exit 0
