#!/bin/csh -f
#
#  Generates a monthly seasonal climatology netcdf file 
#  from monthly mean POP history files.  If variables are
#  indicated, only those variables will be kept, otherwise
#  will generate a climatology for all existing variables.
#
#  Invoke as
#   gen_mavg_netcdf.csh MSROOT CASENAME startyear endyear variables
#


set MSROOT = $1
set CASENAME = $2
@ yr0 = $3
@ yr1 = $4

if ($#argv > 4) then
 @ doall = 0
 set vars = ($argv[5-$#argv])
 set nvar = $#vars
 set varstr = $argv[5]
 if ($nvar > 1) then
  foreach i ($argv[6-$#argv])
    set varstr = ${varstr},${i}
  end
 endif
else
 @ doall = 1
endif

setenv MSP /${MSROOT}/${CASENAME}/ocn/hist
setenv MSPY /${MSROOT}/${CASENAME}/ocn/proc/tavg/annual
setenv MSPM /${MSROOT}/${CASENAME}/ocn/proc/tavg/monthly

set year0 = `printf "%04d" $yr0`
set year1 = `printf "%04d" $yr1`

setenv SEASCLIM ${CASENAME}.pop.h.${year0}-01_mavg_${year1}-12.nc

hsi -P "ls ${MSPM}/${SEASCLIM}"
if ($status == 0) then
 echo "reading ${SEASCLIM} from HPSS"
 hsi -P "get ${MSPM}/${SEASCLIM}"
 if ($doall == 0) ncks -O -h -v ${varstr} ${SEASCLIM} ${SEASCLIM}
else
  echo "generating ${SEASCLIM}"
  @ yr = $yr0
  @ cnt = 0
  set janfiles = ()
  set febfiles = ()
  set marfiles = ()
  set aprfiles = ()
  set mayfiles = ()
  set junfiles = ()
  set julfiles = ()
  set augfiles = ()
  set sepfiles = ()
  set octfiles = ()
  set novfiles = ()
  set decfiles = ()
  while ($yr <= $yr1)

    set year = `printf "%04d" $yr`
  
    set janfiles = ( $janfiles ${CASENAME}.pop.h.${year}-01.nc )
    set febfiles = ( $febfiles ${CASENAME}.pop.h.${year}-02.nc )
    set marfiles = ( $marfiles ${CASENAME}.pop.h.${year}-03.nc )
    set aprfiles = ( $aprfiles ${CASENAME}.pop.h.${year}-04.nc )
    set mayfiles = ( $mayfiles ${CASENAME}.pop.h.${year}-05.nc )
    set junfiles = ( $junfiles ${CASENAME}.pop.h.${year}-06.nc )
    set julfiles = ( $julfiles ${CASENAME}.pop.h.${year}-07.nc )
    set augfiles = ( $augfiles ${CASENAME}.pop.h.${year}-08.nc )
    set sepfiles = ( $sepfiles ${CASENAME}.pop.h.${year}-09.nc )
    set octfiles = ( $octfiles ${CASENAME}.pop.h.${year}-10.nc )
    set novfiles = ( $novfiles ${CASENAME}.pop.h.${year}-11.nc )
    set decfiles = ( $decfiles ${CASENAME}.pop.h.${year}-12.nc )

    hsi -P "ls ${MSP}/${CASENAME}.pop.h.${year}-01.nc"
    if ($status == 0) then
    set filesize = `hsi -P ls -l ${MSP}/${CASENAME}.pop.h.${year}-01.nc | awk '$5 ~ /^[0-9]+$/{print $5}'`
    hsi -P "get ${MSP}/${CASENAME}.pop.h.${year}-{01,02,03,04,05,06,07,08,09,10,11,12}.nc"
    else
      mssuntar.csh ${MSROOT} ${CASENAME} $yr $yr
      set filesize =  `ls -l ${CASENAME}.pop.h.${year}-01.nc | awk '{print $5}'`
    endif

    if ($doall == 0) then
      foreach mon (01 02 03 04 05 06 07 08 09 10 11 12)
          ncks -O -h -v ${varstr} ${CASENAME}.pop.h.${year}-${mon}.nc  \
		${CASENAME}.pop.h.${year}-${mon}.nc
      end
    endif
  @ yr++
  end
  if ($yr1 == $yr0) then
    ncrcat ${CASENAME}.pop.h.${yr0}-??.nc $SEASCLIM
  else
    ncea -O $janfiles jan.nc && \rm -f $janfiles
    ncea -O $febfiles feb.nc && \rm -f $febfiles
    ncea -O $marfiles mar.nc && \rm -f $marfiles
    ncea -O $aprfiles apr.nc && \rm -f $aprfiles
    ncea -O $mayfiles may.nc && \rm -f $mayfiles
    ncea -O $junfiles jun.nc && \rm -f $junfiles
    ncea -O $julfiles jul.nc && \rm -f $julfiles
    ncea -O $augfiles aug.nc && \rm -f $augfiles
    ncea -O $sepfiles sep.nc && \rm -f $sepfiles
    ncea -O $octfiles oct.nc && \rm -f $octfiles
    ncea -O $novfiles nov.nc && \rm -f $novfiles
    ncea -O $decfiles dec.nc && \rm -f $decfiles
    ncrcat -O jan.nc feb.nc mar.nc apr.nc may.nc jun.nc jul.nc aug.nc \
	sep.nc oct.nc nov.nc dec.nc $SEASCLIM
  endif
  if ($doall == 1 && $CPY_TO_HSI == 1) hsi -P "mkdir -p $MSPM; put $SEASCLIM:${MSPM}/$SEASCLIM 
  \rm -f jan.nc feb.nc mar.nc apr.nc may.nc jun.nc jul.nc aug.nc \
        sep.nc oct.nc nov.nc dec.nc
endif
exit 0
