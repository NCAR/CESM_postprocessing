#!/bin/csh -f
#
#  Purpose:
#    Prepare for the creation of an annual averaged pop2 history by
#    collecting 12 equally sized monthly mean ocean history files onto disk. 
#  Functions:
#    o search for monthly files on local disk
#    o if not found locally, search remote disk
#    o if gziped, ungzip
#    o ensure that all monthly files are the same size
#  Usage: get_monthly_files.csh  $MSROOT $CASENAME $year
#  Warning: 
#    o this script will not work if input names contain a wildcard  
#    o send value for year, not the four-digit year string. In
#      most popdiag scripts, this variable is called yr 
#
# set verbose

#------------------------
#... usage error checking
#------------------------
if ($#argv < 3) then
  cat << EOF 
  ##########################################################################
  #  Name: monthly_files.csh
  #  Purpose: 
  #    Collect 12 equally sized monthly mean ocean history files onto disk. 
  #  Functions:
  #    o search for monthly files on local disk
  #    o if not found locally, search hpss
  #    o if not found locally, search remote disk (OPTIONAL 4th argument; specify REMOTE_DISK)
  #    o if gziped, ungzip
  #    o ensure that all monthly files are the same size
  #  Usage: get_monthly_files.csh  $MSROOT $CASENAME $year [$REMOTE_DISK]
  ##########################################################################

EOF
  echo "   get_monthly_files.csh exiting on usage error: not enough input arguments"
  echo " "
  exit -999
endif
if ($#argv == 4) then
  set REMOTE_DISK = $4
else
  set REMOTE_DISK = NULL
endif
if ($#argv > 4) then
  echo "get_monthly_files.csh exiting on usage error: too many input arguments ($#argv)"
  echo "invoke get_monthly_files.csh without any arguments for usage notes"
  exit -999
endif

set debug = false
if ($debug == true) echo start get_monthly_files.csh

#-------------------------------------------------------------------
# define local variables
#-------------------------------------------------------------------
set MSROOT = $1
set CASENAME = $2
@ year = $3

setenv MSP /${MSROOT}/${CASENAME}/ocn/hist
set year4 = `printf "%04d" $year`   # form 4-digit year

#-------------------------------------------------------------------
# define standard filename (can manually change this for nonstandard names)
#-------------------------------------------------------------------
set STANDARD = TRUE
if ($STANDARD == TRUE) then
  set fileroot = ${CASENAME}.pop.h.${year4}   # standard
else
 set string = ecosys.nday1   # ecosystem stream, for example
 set fileroot = ${CASENAME}.pop.h.${string}.${year4}
endif


if ($debug == true) echo  ...  find or read monthly files for year $year4 

#-------------------------------------------------------------------
# 1. Check local disk first: are all monthly files on local disk?
#-------------------------------------------------------------------
     if ($debug == true) echo search local disk for monthly files
     @ file_count = 0
     foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
       set filename = ${fileroot}-${month}.nc
       echo $filename
       check_disk.csh $filename -gunz  && @ file_count++
     end # month

     if ($file_count == 12) then
       #... all files are present
       set available = "all_monthly_files_are_present"
     else if ($file_count == 0) then
       #... no files are present
       set available = "no_monthly_files_are_present"
     else if ($file_count > 0 && $file_count < 12) then
       #... some files are present
       set available = "some_monthly_files_are_present"
     else
       #... error condition
       echo "get_monthly_files.csh error: file_count = $file_count"
     endif
     if ($debug == true) echo after searching local disk, $available for year $year4

#-------------------------------------------------------------------
# 2. If no monthly files are on disk, look elsewhere
#-------------------------------------------------------------------
     #-------------------------------------------------------------------
     # 2a. are monthly files on another disk? 
     #-------------------------------------------------------------------
     if ($available == "no_monthly_files_are_present" && $REMOTE_DISK != NULL) then
echo "search remote disk $REMOTE_DISK for monthly files"
       cp $REMOTE_DISK/${fileroot}-??.nc* . >&! /dev/null
echo "got monthly files"
       # check:
       @ file_count = 0
       foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
         set filename = ${fileroot}-${month}.nc
         check_disk.csh $filename -gunz  && @ file_count++
       end # month
echo "checked file count"
       if ($file_count == 12) then
         #... all files are present
         set available = "all_monthly_files_are_present"
echo $available
       else if ($file_count == 0) then
         #... no files are present
         set available = "no_monthly_files_are_present"
echo $available
       else if ($file_count > 0 && $file_count < 12) then
         #... some files are present
         set available = "some_monthly_files_are_present"
echo $available
       else
         #... error condition
         echo "get_monthly_files.csh error: file_count = $file_count"
       endif
     if ($debug == true) echo after searching remote disk, $available for year $year4
     endif # no_monthly_files_are_present remote disk

   
     #-------------------------------------------------------------------
     # 2b. are all monthly files on hpss?
     #-------------------------------------------------------------------
     if ($available == "no_monthly_files_are_present") then
                                                          if ($debug == true) echo search hpss for monthly files
       hsi -P "prompt; cget $MSP/${fileroot}-??*"  >&! /dev/null && set return_code = 0
       @ file_count = 0
       foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
         set filename = ${fileroot}-${month}.nc
         check_disk.csh $filename -gunz  && @ file_count++
       end # month

       # check:
       if ($file_count == 12) then
         #... all files are present
         set available = "all_monthly_files_are_present"
       else if ($file_count == 0) then
         #... no files are present
         set available = "no_monthly_files_are_present"
       else if ($file_count > 0 && $file_count < 12) then
         #... some files are present
         set available = "some_monthly_files_are_present"
       else
         #... error condition
         echo "get_monthly_files.csh error: file_count = $file_count"
       endif
     if ($debug == true) echo after searching hpss, $available for year $year4
     endif # no_files_are_present hpss

   
     #-------------------------------------------------------------------
     # 2c. are all monthly files on hpss in a tarball? last option (untested)
     #     Last option.
     #-------------------------------------------------------------------
     if ($available == "no_monthly_files_are_present") then
                                                           if ($debug == true) echo search hpss for tarball of monthly files
       get_hpss.csh ${MSP}/${fileroot}.tar 
       if ($status == 0) then
         mssuntar.csh ${MSROOT} ${CASENAME} $yr $yr
       else
         echo  "===================================================================="
         echo  "FATAL ERROR in get_monthly_files.csh: not all monthly files exist"
         echo  "===================================================================="
         exit -999
       endif

     # check:
       @ file_count = 0
       foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
         set filename = ${fileroot}-${month}.nc
         check_disk.csh $filename -gunz  && @ file_count++
       end # month

       if ($file_count == 12) then
         #... all files are present
         set available = "all_monthly_files_are_present"
       else if ($file_count == 0) then
         #... no files are present
         set available = "no_monthly_files_are_present"
       else if ($file_count > 0 && $file_count < 12) then
         #... some files are present
         set available = "some_monthly_files_are_present"
       else
         #... error condition
         echo "get_monthly_files.csh error: file_count = $file_count"
       endif
     if ($debug == true) echo after searching for tarfile on hpss, $available for year $year4
     endif # no_files_are_present

   
#------------------------------------------------------------------------
# 3. if only some monthly files are missing, check month-by-month to find
#    just the missing disk files
#------------------------------------------------------------------------
     if ($available == "some_monthly_files_are_present") then
                                                          if ($debug == true) echo search hpss for missing monthly files
     @ file_count = 0
     foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
       set filename_mon = ${fileroot}-${month}.nc

       set mon_file_exists = no
       check_disk.csh $filename_mon -gunz && set mon_file_exists = yes

       #... check remote disk
       if ($mon_file_exists == no && $REMOTE_DISK != NULL) then
         cp $REMOTE_DISK/${filename_mon}* . && set mon_file_exists = yes
       endif

       #... only look on hpss for files that are not already on disk
       if ($mon_file_exists == no) then
         get_hpss.csh $MSP/$filename_mon && set mon_file_exists = yes
       endif
    
       if ($mon_file_exists == yes) @ file_count++

     end # month

     # check:
       if ($file_count == 12) then
         #... all files are present
         set available = "all_monthly_files_are_present"
       else if ($file_count == 0) then
         #... no files are present
         set available = "no_monthly_files_are_present"
       else if ($file_count > 0 && $file_count < 12) then
         #... some files are present
         set available = "some_monthly_files_are_present"
       else
         #... error condition
         echo "get_monthly_files.csh error: file_count = $file_count"
       endif
     if ($debug == true) echo after checking for individual files on hpss, $available for year $year4
     endif #some_monthly_files_are_present


#-------------------------------------------------------------------
# 4. Are all 12 monthly files available and the same size?
#-------------------------------------------------------------------

     if ($available == "all_monthly_files_are_present") then
                                                          if ($debug == true) echo are all monthly files the same size
     #... enforce requirement for all monthly files to be the same size
     set filesize1 = `ls -l ${fileroot}-01.nc | awk '$5 ~ /^[0-9]+$/{print $5}'`
     set samesize = yes 
     foreach month (02 03 04 05 06 07 08 09 10 11 12)
       set filesize = `ls -l ${fileroot}-${month}.nc | awk '$5 ~ /^[0-9]+$/{print $5}'`
       if ($filesize != $filesize1 ) then
         echo " ==================================================="
         echo " FATAL ERROR: filesize mis-match at month $month"
         ls -la ${fileroot}-01.nc
         ls -la ${fileroot}-${month}.nc
         echo " ==================================================="
         set samesize = no 
       endif
     end # foreach month
     endif #all_monthly_files_are_present

#--------------------------------
# 5. if you get this far, success
#--------------------------------
     if ($debug == true) echo $available for year $year4
     if ($available == "all_monthly_files_are_present") then
       if ($samesize == yes) then
        echo "...  all 12 monthly files for year $year4 are now on disk"
        exit 0
       else
           echo "===================================================================================="
           echo "FATAL ERROR in get_monthly_files.csh: $year4 monthly files are not all the same size"
           echo "                                      CANNOT CREATE ${fileroot}.nc   " 
           echo "===================================================================================="
           exit -999
       endif #samesize
     else
           set mydir = `pwd`
           echo "========================================================================================"
           echo "FATAL ERROR in get_monthly_files.csh: not all $year4 monthly files are available on disk"
           echo "            $mydir                                                                      "
           echo "                                      CANNOT CREATE ${fileroot}.nc       " 
           echo "========================================================================================"
           exit -999
     endif #all_monthly_files_are_present
