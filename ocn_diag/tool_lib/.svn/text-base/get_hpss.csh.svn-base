#!/bin/csh -f
# set verbose
#
#-----------------------------------------------------------------
#  Purpose: If a file is on hpss (either gzip'd or ungzip'd), get it.
#           If gzip'd, gunzip it
#  Author:  Nancy Norton March 2013
#-----------------------------------------------------------------
#
#------------------------
#... usage error checking
#------------------------
if ($#argv < 1) then
  cat << EOF 
  ##########################################################################
  #  Name: get_hpss.csh
  #  Purpose: If a file is on the hpss, in ungzip'd or gzip'd form, get it.
  #           If file is gzip'd, gunzip it
  #             if success, return code == 0
  #             if not,     return code == 1 
  #  Usage: get_hpss.csh filename  
  #    
  #  Warning: this script will not work if the filename contains a wildcard. 
  ##########################################################################

EOF
  echo "   get_hpss.csh exiting on usage error: not enough input arguments"
  echo " "
  exit -999
endif

if ($#argv > 1) then
  echo "get_hpss.csh exiting on usage error: too many input arguments ($#argv)"
  echo "               invoke get_hpss.csh without any arguments for usage notes"
  exit -999
endif

#----------------------------------
#... identify file you want to find
#----------------------------------
set filename = $argv[1]

#-----------------------------------
#... initialize flags
#-----------------------------------
set return_code = 1
set gzipd = NA

#------------------------------------------------
#... get the file off from the hpss
#------------------------------------------------
hsi -P "prompt; cget $filename"  >&! /dev/null && set return_code = 0

if ($return_code == 0) then
  set gzipd = no
else
  hsi -P "prompt; cget ${filename}.gz" >&! /dev/null && set return_code = 0
  if ($return_code == 0) then
    set gzipd = yes
    # now gunzip the file
    set return_code = 1 
    gunzip ${filename:t}.gz && set return_code = 0 
  endif
endif

#---------------------
#... report and return
#---------------------
if ($return_code == 0) then
 if ("$gzipd" == "no") then
   echo $filename is on hpss and is now on disk
 else
   echo ${filename}.gz is on hpss and $filename:t is now on disk
 endif
else
    echo neither $filename nor ${filename}.gz is on hpss
endif

exit $return_code
