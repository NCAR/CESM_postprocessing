#!/bin/csh -f
# set verbose
  set debug = false
if ($debug == true) echo start check_disk.csh

#------------------------
#... usage error checking
#------------------------
if ($#argv < 1) then
  cat << EOF 
  ##########################################################################
  #  Name: check_disk.csh
  #  Purpose: Check if a file is on disk (either gzip'd or ungzip'd)
  #           Optionally, gunzip the file
  #             if yes, return code == 0
  #             if no,  return code == 1 
  #
  #  Usage: check_disk.csh filename  [-gunz] [-silent]
  #    
  #  Warning: this script will not work if the filename contains a wildcard. 
  #  Author:  Nancy Norton March 2013
  ##########################################################################

EOF
  echo "(check_disk.csh) FATAL ERROR: incorrect usage -- not enough input arguments"
  echo " "
  exit -999
endif
endif
if ($#argv > 3) then
  echo "(check_disk.csh) FATAL ERROR: incorrect usage -- too many input arguments ($#argv)"
  echo "               invoke check_disk.csh without any arguments for usage notes"
  exit -999
endif

#----------------------------------
#... identify file you want to find
#----------------------------------
set filename = "$argv[1]"
if ($debug == true) echo filename = $filename

#--------------------------------------------------------------
# set default values
#--------------------------------------------------------------
set gunzip_file = false
set silent      = false

#--------------------------------------------------------------
#... parse any optional arguments
#--------------------------------------------------------------
while ( 1 )
  shift argv
  if ( $#argv < 1 ) break;
  set optarg = $argv[1];
  switch ( $optarg )
    case "-gunz"
      set gunzip_file = true
      breaksw
    case "-silent"
      set silent = true
      breaksw
    default:
      echo "unknown input, invoked check_disk with no arguments for usage"
      echo check_disk.csh: unknown input $optarg
      exit -1
      breaksw
  endsw
end # end parsing optional arguments

if ($debug == true) echo begin checking on disk
#-----------------------------
#... is filename(.gz) on disk? 
#-----------------------------
if (-e "${filename}")  then
  set return_code = 0
  set file_exists = yes
  set gzipd = no
else if (-e "${filename}.gz") then
  set return_code = 0
  set file_exists = yes
  set gzipd = yes
else
  set return_code = 1
  set file_exists = no
  set gzipd = NA
endif

if ($file_exists == yes) then
  if ($gzipd == yes && $gunzip_file == true ) then
    set return_code = 1
    gunzip "${filename}.gz" && set return_code = 0
    if ($return_code == 0) set gzipd = no
  endif
endif

#---------------------
#... report and return
#---------------------

if ($return_code == 0) then
 if ($file_exists == yes && $gzipd == no) then
   if ($silent == false || $debug == true) echo "$filename" is on disk
 else if ($file_exists == yes && $gzipd == yes) then
   if ($silent == false || $debug == true) echo "${filename}.gz" is on disk
 endif
else
   if ($silent == false || $debug == true) echo neither "$filename" nor "${filename}.gz" is on disk
endif

if ($debug == true) echo end check_disk.csh
exit $return_code
