#!/bin/csh -f
#
#  Checks to see if a file is on the hpss. 
#    if yes, return code == 0
#    if no,  return code == 1 
#
#  Usage
#   check_hpss.csh filename          (check hpss for $filename only)
#    
#   check_hpss.csh filename  get     (check hpss for $filename and get)
#
#   check_hpss.csh filename  get  gz (check hpss for ${filename}.gz and get)
#
# set verbose

set filename = $1
set return_code = 1

if ($2 == get) then
  #... is $filename on hpss? if so, get it
  hsi -P "prompt; cget $filename" && set return_code = 0

  #... if $filename doesn't exist, is it gzip'd?
  if ($return_code == 1 && $3 == gz) then
    hsi -P "prompt; cget ${filename}.gz" && set return_code = 0
  endif
else
  #... just checking for existence
  hsi -P "prompt; ls $filename" && set return_code = 0
endif

if ($return_code == 0) echo $filename is on hpss

exit $return_code
