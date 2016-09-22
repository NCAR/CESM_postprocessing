#!/bin/csh -f
#
#  Generates a monthly seasonal climatology netcdf file 
#  from monthly mean POP history files.  If variables are
#  indicated, only those variables will be kept, otherwise
#  will generate a climatology for all existing variables.
#
#  Invoke as
#   gen_mavg_annmean.csh MSROOT CASENAME startyear endyear TAVGFILE variables
#
#  set verbose


#------------------------
# usage error checking
#------------------------
if (${#argv} < 7) then
  echo "Missing variable names for gen_mavg_netcdf.csh" && exit 1
endif

set MSROOT = $1
set REMOTE_DISK = $2
set CASENAME = $3
@ yr0 = $4
@ yr1 = $5
set OUTFILE = $6
set nvars = $#argv

setenv MSP /${MSROOT}/${CASENAME}/ocn/hist
setenv MSPY /${MSROOT}/${CASENAME}/ocn/proc/tavg/annual
setenv MSPM /${MSROOT}/${CASENAME}/ocn/proc/tavg/monthly
setenv MSPD /${MSROOT}/${CASENAME}/ocn/proc/tavg/decadal
setenv MSPB /${MSROOT}/${CASENAME}/ocn/proc/tavg/mean


set year0 = `printf "%04d" $yr0`
set year1 = `printf "%04d" $yr1`

if ($NEED_CLIM == 1) then
 set coordlist = 'z_t,z_w,z_t_150m,ULAT,ULONG,TLAT,TLONG,dz,dzw,KMT,KMU,REGION_MASK,UAREA,TAREA,HU,HT,DXU,DYU,DXT,DYT,HTN,HTE,HUS,HUW,ANGLE,ANGLET'
 set varstr = ${coordlist}
  @ count = 0
  foreach i ($argv[7-$#argv])
    echo 'i='$i
  
    setenv SEASCLIM ${CASENAME}.pop.h.${i}.mavg_${year0}-${year1}.nc
    set clim_file_exists = no

    if ($debug == true) echo "... search for existing climatology file $SEASCLIM"
   
    #... is $SEASCLIM on disk?
    check_disk.csh ${SEASCLIM} -gunz && set clim_file_exists = yes

    #... is $SEASCLIM on hpss?
    if ($clim_file_exists == no) \
      get_hpss.csh ${MSPM}/${SEASCLIM} && set clim_file_exists = yes

    if ( $clim_file_exists == no ) then
      if ($debug == true) echo "... file ${SEASCLIM} is not on disk or hpss"
      @ count++
#      if ($count == 1) then
#        set varstr = ${i}
#      else
        set varstr = ${varstr},${i}
#      endif
    endif
  end # foreach i

  if ($count == 0) then
   if ($debug == true) echo "... all requested climatologies exist and have been read from HPSS"
   setenv NEED_CLIM 0
  endif
endif # NEED_CLIM

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

#------------------------------------
# loop over all years in the interval
#------------------------------------
@ yr = $yr0
set files = ()
while ($yr <= $yr1) 

  set year = `printf "%04d" $yr`
  set filename_yr = ${CASENAME}.pop.h.${year}.nc
  set yr_file_exists = no

  set files = ( $files $filename_yr)
  
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

  #-------------------------------------------------------
  # if annual time-averaged file does not exist, create it
  #-------------------------------------------------------
  if ($debug == true) echo "... search for existing annual average file for year $year"

  #.... is file on disk? 
    check_disk.csh $filename_yr -gunz && set yr_file_exists = yes

  #.... is file on hpss in standard location? 
  if ($yr_file_exists == no) \
    get_hpss.csh $MSPY/$filename_yr && set yr_file_exists = yes

  #.... is file on hpss in alternate location?
  if ($yr_file_exists == no) \
    get_hpss.csh $MSP/$filename_yr && set yr_file_exists = yes

  if (($NEEDTAVG == 1 && $yr_file_exists == no) || $NEED_CLIM == 1 || $PME == 0 ) then

    #... make the hpss directory
    if ($CPY_TO_HSI == 1) hsi -P "mkdir -p $MSPY "

    #-------------------------------------------------------------------
    # gather monthly files to create annual average or climatologies
    #-------------------------------------------------------------------
    if ($debug == true) echo "...  find or read monthly files for year $year"
    get_monthly_files.csh $MSROOT $CASENAME $yr $REMOTE_DISK
    if ($status != 0) exit -999

    #-----------------------------------------------------------------------------------
    # if annual average does not exist, create it and write it to the hpss if requested
    #-----------------------------------------------------------------------------------

    if ($yr_file_exists == no) then
      if ($debug == true) echo "... create new $year annual file"
      ncra ${CASENAME}.pop.h.${year}-??.nc ${CASENAME}.pop.h.${year}.nc 
      if ($status == 0 && $CPY_TO_HSI == 1)  hsi "cput ${CASENAME}.pop.h.${year}.nc : ${MSPY}/${CASENAME}.pop.h.${year}.nc"
      if ($CLEANUP_FILES == 1 && NEED_CLIM == 0 && $PME == 0 ) rm ${CASENAME}.pop.h.${year}-*.nc
    endif
	  
    #-------------------------------------------------------------------
    # create climatologies
    #-------------------------------------------------------------------
    if ( $NEED_CLIM == 1 ) then
      if ($debug == true) echo "...  begin creating climatology files"
      set mn = 1
      while ($mn <= 12)
        if ($mn < 10) then
          set ymstring = ${year}-0$mn
        else
          set ymstring = ${year}-$mn
        endif

        #... always create $filename_clim; older versions with the same
        #    filename might not contain all of the variables in the 
        #    current $varstr 
        ncks -v $varstr ${CASENAME}.pop.h.${ymstring}.nc ${CASENAME}.pop.h.vars.${ymstring}.nc
        
        @ mn++
      end #while $mn
    endif # NEED_CLIM

    #--------------------------------------------
    # rm intermediate files only if requested
    #--------------------------------------------
    if ($CLEANUP_FILES == 1 && $PME == 0 ) rm ${CASENAME}.pop.h.${year}-*.nc

  endif #  (($NEEDTAVG == 1 && $yr_file_exists == no) || $NEED_CLIM == 1 )
    
  @ yr++
end # while ($yr <= $yr1)
wait
   
if ( $NEED_CLIM == 1) then
  if ($yr0 == $yr1) then
    ncrcat -v ${varstr} ${CASENAME}.pop.h.vars.${year0}-??.nc ${CASENAME}.clim.${year0}-${year1}.nc
  else
    ncea -O -v ${varstr} $janfiles jan.nc &&  \rm -f $janfiles &
    ncea -O -v ${varstr} $febfiles feb.nc &&  \rm -f $febfiles &
    ncea -O -v ${varstr} $marfiles mar.nc &&  \rm -f $marfiles &
    ncea -O -v ${varstr} $aprfiles apr.nc &&  \rm -f $aprfiles &
    ncea -O -v ${varstr} $mayfiles may.nc &&  \rm -f $mayfiles &
    ncea -O -v ${varstr} $junfiles jun.nc &&  \rm -f $junfiles &
    ncea -O -v ${varstr} $julfiles jul.nc &&  \rm -f $julfiles &
    ncea -O -v ${varstr} $augfiles aug.nc &&  \rm -f $augfiles &
    ncea -O -v ${varstr} $sepfiles sep.nc &&  \rm -f $sepfiles &
    ncea -O -v ${varstr} $octfiles oct.nc &&  \rm -f $octfiles &
    ncea -O -v ${varstr} $novfiles nov.nc &&  \rm -f $novfiles &
    ncea -O -v ${varstr} $decfiles dec.nc &&  \rm -f $decfiles &
    wait
    ncrcat -O jan.nc feb.nc mar.nc apr.nc may.nc jun.nc jul.nc aug.nc \
              sep.nc oct.nc nov.nc dec.nc ${CASENAME}.clim.${year0}-${year1}.nc
  endif
  if ($CLEANUP_FILES == 1 ) rm -f $CASENAME.pop.h.vars*nc

  #-------------------------------------------------------
  # create any climatology files that do not already exist
  #-------------------------------------------------------
  foreach i ($argv[7-$#argv])
  
    setenv SEASCLIM ${CASENAME}.pop.h.${i}.mavg_${year0}-${year1}.nc
    set clim_file_exists = no

    #... is $SEASCLIM on disk?
    check_disk.csh ${SEASCLIM} && set clim_file_exists = yes

     #... is $SEASCLIM on hpss?
     if ($clim_file_exists == no) \
       get_hpss.csh ${MSPM}/${SEASCLIM} && set clim_file_exists = yes

     if ( $clim_file_exists == no ) then
       ncks -A -h -v ${coordlist},${i} ${CASENAME}.clim.${year0}-${year1}.nc ${SEASCLIM}
       if ($CPY_TO_HSI == 1) hsi -P "mkdir -p $MSPM ; put ${SEASCLIM} : ${MSPM}/${SEASCLIM}"
     endif
  end
   
  \rm -f jan.nc feb.nc mar.nc apr.nc may.nc jun.nc jul.nc aug.nc \
                                    sep.nc oct.nc nov.nc dec.nc
  if ($CLEANUP_FILES == 1) \rm -f ${CASENAME}.*.clim.${year0}-${year1}.nc
endif

#------------------------------------------------------------------------------------------
#  check that all annual mean files were created successfully and create TAVGFILE if needed
#------------------------------------------------------------------------------------------
if ($NEEDTAVG == 1) then
  @ allgood = 0
  @ yr = $yr0
  while ($yr <= $yr1)
    set year = `printf "%04d" $yr`
    set filename_yr = ${CASENAME}.pop.h.${year}.nc
    set yr_file_exists  = no
    set yr_file_on_hpss = no

    #.... is file on disk? It should be!
    check_disk.csh $filename_yr -silent && set yr_file_exists = yes
    if ($yr_file_exists == yes ) then
      if ($CPY_TO_HSI == 1) then
        #.... is file already on hpss in standard location? 
        check_hpss.csh $MSPY/$filename_yr && set yr_file_on_hpss = yes
        if ($yr_file_on_hpss == no) hsi -P "mkdir -p $MSPY ; cput $filename_yr : $MSPY/$filename_yr"
      endif 
    else
       @ allgood++
    endif
    @ yr++
  end
  if ($allgood == 0) then
    gen_tavg_netcdf.csh $MSROOT $CASENAME $yr0 $yr1 $OUTFILE
    #.... is file already on hpss?
    set filename_mavg = ${CASENAME}.${year0}_tavg_${year1}.nc
    if (CPY_TO_HSI == 1) then
      set mavg_file_on_hpss = no
      check_hpss.csh $MSPD/$filename_mavg && set mavg_file_on_hpss = yes
      if ($mavg_file_on_hpss == no) hsi -P "mkdir -p $MSPD ; put $OUTFILE : $MSPD/$filename_mavg"
    endif 
  else
    echo "ERROR in gen_mavg_annmean.csh"
    exit 4
  endif
else
  if ( $CLEANUP_FILES == 1 ) rm -f $files
endif

exit 0
