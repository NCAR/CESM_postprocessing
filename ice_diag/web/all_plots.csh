#!/bin/csh

if ($#argv != 3) then
  echo "usage: all_plots.csh <casename> <beg_yr> <end_yr>"
  exit
endif

set echo on
set BASE_DIR = /web/web-data/oce/dbailey/coupled
set NEW_DIR = ${BASE_DIR}/$1/ice/yrs$2-$3

# Explicitly make the directories so that the intermediate directories
# will get group writable permissions

if !(-d $NEW_DIR ) then
  mkdir -p -m 0775 ${BASE_DIR}/$1
  mkdir -p -m 0775 ${BASE_DIR}/$1/ice
  mkdir -p -m 0775 ${BASE_DIR}/$1/ice

  if !(-d contour) mkdir -p -m 0775 ${NEW_DIR}/contour
  if !(-d vector) mkdir -p -m 0775 ${NEW_DIR}/vector
  if !(-d line) mkdir -p -m 0775 ${NEW_DIR}/line

  # Untar the gif files  This will put the *.gif file in the
  # same directory as the tar file

  tar -xf ${BASE_DIR}/all_plots.tar 

  mv ${BASE_DIR}/*.gif ${NEW_DIR}

  mv ${NEW_DIR}/con_*.gif  ${NEW_DIR}/contour
  mv ${NEW_DIR}/vec_*.gif  ${NEW_DIR}/vector
  mv ${NEW_DIR}/line_*.gif ${NEW_DIR}/line

  echo "Done moving gif files"

  # Move the html file and modify them to include the new case name

  # if !(-e ${NEW_DIR}/descript.html) cp ${BASE_DIR}/descript.html ${NEW_DIR}

  set HTML_FILE = ${NEW_DIR}/all_plots.html
  if !(-e $HTML_FILE) then 

    cp ${BASE_DIR}/all_plots.html $HTML_FILE

cat >! ${BASE_DIR}/sed.in << EOF
s#CASENAME#$1#
EOF

    sed -f ${BASE_DIR}/sed.in ${HTML_FILE} >! ${NEW_DIR}/temp.html
    mv ${NEW_DIR}/temp.html ${NEW_DIR}/plots.html
    rm -f ${BASE_DIR}/sed.in
  endif

  echo "Done moving html files"

else
  echo"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "Plots for case $1, years $2 to $3 already exist in $NEW_DIR."
  echo "No files were copied to these directories to avoid "
  echo "writing over desired files. Delete this directory and "
  echo "resubmit this script to replace the files."
  echo"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
endif

