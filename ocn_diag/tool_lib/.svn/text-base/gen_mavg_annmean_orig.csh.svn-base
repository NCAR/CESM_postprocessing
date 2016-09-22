#!/bin/csh -f
#
#  Generates a monthly seasonal climatology netcdf file 
#  from monthly mean POP history files.  If variables are
#  indicated, only those variables will be kept, otherwise
#  will generate a climatology for all existing variables.
#
#  Invoke as
#   gen_mavg_netcdf.csh MSROOT CASENAME startyear endyear TAVGFILE variables
#
#set verbose

set MSROOT = $1
set CASENAME = $2
@ yr0 = $3
@ yr1 = $4
set OUTFILE = $5
set nvars = $#argv

if (${nvars} < 6) then
  echo "Missing variable names for gen_mavg_netcdf.csh" && exit 1
endif

setenv MSP /${MSROOT}/${CASENAME}/ocn/hist
setenv MSPY /${MSROOT}/${CASENAME}/ocn/proc/tavg/annual
setenv MSPM /${MSROOT}/${CASENAME}/ocn/proc/tavg/monthly

set year0 = `printf "%04d" $yr0`
set year1 = `printf "%04d" $yr1`

if ($NEED_CLIM == 1) then
 @ count = 0
 foreach i ($argv[6-$#argv])
 echo 'i='$i
  
   setenv SEASCLIM ${CASENAME}.pop.h.${i}.mavg_${year0}-${year1}.nc
   echo $SEASCLIM
   hsi -P "ls ${MSPM}/${SEASCLIM}"
   if ( $status == 0 ) then
     echo "File ${MSPM}/${SEASCLIM} already exists...reading from HPSS"
     hsi -P "get ${MSPM}/${SEASCLIM}"
   else
     @ count++
       if ($count == 1) then
         set varstr = ${i}
       else
         set varstr = ${varstr},${i}
       endif
   endif
 end
 if ($count == 0) then
   echo "all requested climatologies exist and have been read from MSS"
   setenv NEED_CLIM 0
 endif
endif

if ($NEED_CLIM == 1) then
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
 
endif

@ yr = $yr0
set files = ()
while ($yr <= $yr1) 

   set year = `printf "%04d" $yr`
   set files = ( $files ${CASENAME}.pop.h.${year}.nc )
  
  if ($NEED_CLIM == 1)  then
   set janfiles = ( $janfiles ${CASENAME}.pop.h.vars.${year}-01.nc )
   set febfiles = ( $febfiles ${CASENAME}.pop.h.vars.${year}-02.nc )
   set marfiles = ( $marfiles ${CASENAME}.pop.h.vars.${year}-03.nc )
   set aprfiles = ( $aprfiles ${CASENAME}.pop.h.vars.${year}-04.nc )
   set mayfiles = ( $mayfiles ${CASENAME}.pop.h.vars.${year}-05.nc )
   set junfiles = ( $junfiles ${CASENAME}.pop.h.vars.${year}-06.nc )
   set julfiles = ( $julfiles ${CASENAME}.pop.h.vars.${year}-07.nc )
   set augfiles = ( $augfiles ${CASENAME}.pop.h.vars.${year}-08.nc )
   set sepfiles = ( $sepfiles ${CASENAME}.pop.h.vars.${year}-09.nc )
   set octfiles = ( $octfiles ${CASENAME}.pop.h.vars.${year}-10.nc )
   set novfiles = ( $novfiles ${CASENAME}.pop.h.vars.${year}-11.nc )
   set decfiles = ( $decfiles ${CASENAME}.pop.h.vars.${year}-12.nc ) 
  endif

  setenv INANN 0
  setenv INMON 0
  setenv CREATE 0
   hsi -P "ls ${MSPY}/${CASENAME}.pop.h.${year}.nc"
   if ($status == 0 ) setenv INANN 1
   hsi -P "ls ${MSP}/${CASENAME}.pop.h.${year}.nc"
   if ($status == 0 ) setenv INMON 1
  if ($INANN == 0 && $INMON == 0) setenv CREATE 1
  
  if ($NEEDTAVG == 1 && $INANN == 1) then
    hsi -P "get ${MSPY}/${CASENAME}.pop.h.${year}.nc"
  endif
  if ($NEEDTAVG == 1 && $INANN == 0 && $INMON == 1) then
    hsi "get ${MSP}/${CASENAME}.pop.h.${year}.nc"
  endif
  
  if (($NEEDTAVG == 1 && $CREATE == 1) || $NEED_CLIM == 1 ) then
   hsi -P "ls ${MSP}/${CASENAME}.pop.h.${year}-01.nc"
   if ($status == 0) then
     set filesize = `hsi -P ls -l ${MSP}/${CASENAME}.pop.h.${year}-01.nc | awk '$5 ~ /^[0-9]+$/{print $5}'`
     hsi -P  "prompt; mget ${MSP}/${CASENAME}.pop.h.${year}-{01,02,03,04,05,06,07,08,09,10,11,12}.nc"  &
    wait
   else
     hsi -P "${MSP}/${CASENAME}.pop.h.${year}.tar"
     if ($status == 0) then
       mssuntar.csh ${MSROOT} ${CASENAME} $yr $yr
       set filesize =  `ls -l ${CASENAME}.pop.h.${year}-01.nc | awk '{print $5}'`
     else
       echo "no monthly files exist...cannot create climatology" && exit 1
     endif
   endif
  

       set sizes = `ls -l ${CASENAME}.pop.h.${year}-??.nc | awk '{print $5}'`
       if ( $#sizes == 12 && \
         $sizes[1] == $filesize && \
         $sizes[2] == $filesize && \
         $sizes[3] == $filesize && \
         $sizes[4] == $filesize && \
         $sizes[5] == $filesize && \
         $sizes[6] == $filesize && \
         $sizes[7] == $filesize && \
         $sizes[8] == $filesize && \
         $sizes[9] == $filesize && \
         $sizes[10] == $filesize && \
         $sizes[11] == $filesize && \
         $sizes[12] == $filesize ) then
	  
	  ls ${CASENAME}.pop.h.${year}.nc
          if !( $status == 0 ) then
             ncra ${CASENAME}.pop.h.${year}-??.nc ${CASENAME}.pop.h.${year}.nc &
	     wait
	      hsi -P "ls ${MSPY}/${CASENAME}.pop.h.${year}.nc"
	      if !( $status == 0 ) then
	       hsi "ls ${MSP}/${CASENAME}.pop.h.${year}.nc"
	       if !(status == 0 ) then
                 hsi -P "mkdir -p $MSPY ; put ${CASENAME}.pop.h.${year}.nc : ${MSPY}/${CASENAME}.pop.h.${year}.nc"
               endif
	      endif
	    if ( $NEED_CLIM == 0 ) then 
	      rm ${CASENAME}.pop.h.${year}-*.nc
	    endif
	  endif
	  
	  if ( $NEED_CLIM == 1 ) then
	     set mn = 1
             while ($mn <= 12)
               if ($mn < 10) then
	         ls ${CASENAME}.pop.h.vars.${year}-0$mn.nc
		 if !( $status == 0 ) then
                   ncks -v $varstr ${CASENAME}.pop.h.${year}-0$mn.nc ${CASENAME}.pop.h.vars.${year}-0$mn.nc
		 endif
               else 
	         ls ${CASENAME}.pop.h.vars.${year}-$mn.nc
		 if !( $status == 0 ) then
                   ncks -v $varstr ${CASENAME}.pop.h.${year}-$mn.nc ${CASENAME}.pop.h.vars.${year}-$mn.nc
		 endif
               endif
             @ mn++
             end
	     
	     rm ${CASENAME}.pop.h.${year}-*.nc
	   endif
        else

          echo "CANNOT CREATE ${CASENAME}.pop.h.${year}.nc" && exit 1

        endif
  endif
    
  @ yr++
end
wait
   
   if ( $NEED_CLIM == 1) then
     if ($yr0 == $yr1) then
      ncrcat -v ${varstr} ${CASENAME}.pop.h.vars.${year0}-??.nc ${CASENAME}.clim.${year0}-${year1}.nc
     else
      ncea -O -v ${varstr} $janfiles jan.nc && \rm -f $janfiles &
      ncea -O -v ${varstr} $febfiles feb.nc && \rm -f $febfiles &
      ncea -O -v ${varstr} $marfiles mar.nc && \rm -f $marfiles &
      ncea -O -v ${varstr} $aprfiles apr.nc && \rm -f $aprfiles &
      ncea -O -v ${varstr} $mayfiles may.nc && \rm -f $mayfiles &
      ncea -O -v ${varstr} $junfiles jun.nc && \rm -f $junfiles &
      ncea -O -v ${varstr} $julfiles jul.nc && \rm -f $julfiles &
      ncea -O -v ${varstr} $augfiles aug.nc && \rm -f $augfiles &
      ncea -O -v ${varstr} $sepfiles sep.nc && \rm -f $sepfiles &
      ncea -O -v ${varstr} $octfiles oct.nc && \rm -f $octfiles &
      ncea -O -v ${varstr} $novfiles nov.nc && \rm -f $novfiles &
      ncea -O -v ${varstr} $decfiles dec.nc && \rm -f $decfiles &
      wait
      ncrcat -O jan.nc feb.nc mar.nc apr.nc may.nc jun.nc jul.nc aug.nc \
    	sep.nc oct.nc nov.nc dec.nc ${CASENAME}.clim.${year0}-${year1}.nc
     endif
   endif


if ($NEED_CLIM == 1) then

 foreach i ($argv[6-$#argv])
  
  setenv SEASCLIM ${CASENAME}.pop.h.${i}.mavg_${year0}-${year1}.nc
  hsi -P "ls ${MSPM}/${SEASCLIM}"
  if (! $status == 0) then
  
    if (! -e ${SEASCLIM}) then
     ncks -h -v ${i} ${CASENAME}.clim.${year0}-${year1}.nc ${SEASCLIM}
    endif
    hsi -P "mkdir -p $MSPM ; put ${SEASCLIM} : ${MSPM}/${SEASCLIM}"
  endif
 end
   
  \rm -f jan.nc feb.nc mar.nc apr.nc may.nc jun.nc jul.nc aug.nc \
        sep.nc oct.nc nov.nc dec.nc
  \rm -f ${CASENAME}.clim.${year0}-${year1}.nc

endif

#  check that all annual mean files were created successfully and create TAVGFILE if needed
if ($NEEDTAVG == 1) then
  @ allgood = 0
  @ yr = $yr0
  while ($yr <= $yr1)
    echo "allgood="$allgood
    set year = `printf "%04d" $yr`
    if (! -e ${CASENAME}.pop.h.${year}.nc) @ allgood++
    @ yr++
  end
  if ($allgood == 0) then
    gen_tavg_netcdf.csh $MSROOT $CASENAME $yr0 $yr1 $OUTFILE
  else
    echo "ERROR in gen_mavg_annmean.csh"
    exit 1
  endif
else
  rm -f $files
endif

exit 0
