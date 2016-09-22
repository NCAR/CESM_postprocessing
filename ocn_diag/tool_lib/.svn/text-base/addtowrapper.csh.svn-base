#!/bin/csh -f
#
#  Adds a call to a particular analysis routine to the wrapper routine
#  for the appropriate analysis package.  Checks whether modified
#  or standard version is needed.
#
#  Usage:
#	addtowrapper.csh routinename wrappername
#


set routine = $2
set wrapper = $3
set package = $1

if ($package == 'idl' || $package == 'IDL') then 
  if (-e $MODPATH/$routine) then
    echo ".run $MODPATH/$routine" >> $wrapper
  else
    echo ".run $IDLPATH/$routine" >> $wrapper
  endif
endif
if ($package == 'ncl' || $package == 'NCL') then
  if (-e $MODPATH/$routine) then
    echo "${MODPATH}/${routine}" >> $wrapper
  else
    echo "${NCLPATH}/${routine}" >> $wrapper
  endif
endif


