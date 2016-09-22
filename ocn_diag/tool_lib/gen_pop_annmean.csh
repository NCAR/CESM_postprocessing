#!/bin/csh -f
#
#  Computes annual means from monthly POP history files, with
#    mass store read checks.  Must inherit the
#    following environment variables from parent
#    shell:  MSPROJ, MSRPD
#
#  Invoke as
#	gen_pop_annmean.csh MSROOT REMOTE_DISK CASENAME startyear endyear
#

set MSROOT = $1
set REMOTE_DISK = $2
set CASENAME = $3
@ yr0 = $4
@ yr1 = $5

setenv MSP /${MSROOT}/${CASENAME}/ocn/hist
setenv MSPY /${MSROOT}/${CASENAME}/ocn/proc/tavg/annual

@ yr = $yr0
set files = ()
while ($yr <= $yr1)

  set year = `printf "%04d" $yr`
  set filename_yr = ${CASENAME}.pop.h.${year}.nc
  set yr_file_exists = no

  set files = ( $files $filename_yr)
  
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

  if ($yr_file_exists == no) then

    #... make the hpss directory
    if ($CPY_TO_HSI == 1) hsi -P "mkdir -p $MSPY "

    #-------------------------------------------------------------------
    # gather monthly files to create annual average or climatologies
    #-------------------------------------------------------------------
    if ($debug == true) echo "...  find or read monthly files for year $year"
    get_monthly_files.csh $MSROOT $CASENAME $yr $REMOTE_DISK
    if ($status != 0) exit -999
    echo "after get_monthly_files"

    #-----------------------------------------------------------------------------------
    # if annual average does not exist, create it and write it to the hpss if requested
    #-----------------------------------------------------------------------------------
    
    if ($debug == true) echo "... create new $year annual file"
    ncra ${CASENAME}.pop.h.${year}-??.nc ${CASENAME}.pop.h.${year}.nc 
    if ($status == 0 && $CPY_TO_HSI == 1)  hsi "cput ${CASENAME}.pop.h.${year}.nc : ${MSPY}/${CASENAME}.pop.h.${year}.nc"

  endif
  @ yr++
end

#  check that all files were created successfully
set allgood = 1
@ yr = $yr0
while ($yr <= $yr1)
  set year = `printf "%04d" $yr`
  if (! -e ${CASENAME}.pop.h.${year}.nc) set allgood = 0
  @ yr++
end
if ($allgood == 1) then
  exit 0
#  if ($CLEANUP_FILES == 1) rm -f $files
else
  echo "ERROR in gen_pop_annmean.csh"
  exit 1
endif
