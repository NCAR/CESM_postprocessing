#!/bin/csh
# USAGE:  diff_plots.csh <casename> <beg_yr> >end_yr>

if ($#argv != 3) then
  echo "usage: diff_plots.csh <casename> <beg_yr> <end_yr>"
  exit
endif

set echo on
set BASE_DIR = /web/web-data/oce/dbailey/coupled
set NEW_DIR = ${BASE_DIR}/$1/ice/yrs$2-$3

# Explicitly make the directories so that intermediate directories
# can get group writable permissions

if !(-d $NEW_DIR) then
  mkdir -p -m 0775 ${BASE_DIR}/$1
  mkdir -p -m 0775 ${BASE_DIR}/$1/ice
  mkdir -p -m 0775 ${BASE_DIR}/$1/ice/yrs$2-$3

  if !(-d contour) mkdir -p -m 0775 ${NEW_DIR}/contour
  if !(-d vector) mkdir -p -m 0775 ${NEW_DIR}/vector
  if !(-d line) mkdir -p -m 0775 ${NEW_DIR}/line

  # Untar the png files  This will put the *.png file in the
  # same directory as the tar file

  tar -xf ${BASE_DIR}/diff_plots.tar 

  mv ${BASE_DIR}/*.png ${NEW_DIR}

  mv ${NEW_DIR}/diff_con_*.png  ${NEW_DIR}/contour
  mv ${NEW_DIR}/diff_vec_*.png  ${NEW_DIR}/vector
  mv ${NEW_DIR}/line*diff.png   ${NEW_DIR}/line

  echo "Done moving png files"

  # Move the html file and modify them to include the new case name

  set HTML_FILE = ${NEW_DIR}/diff_plots.html
  if !(-e $HTML_FILE) then

    cp ${BASE_DIR}/diff_plots_new1.html $HTML_FILE

cat >! ${BASE_DIR}/sed.in << EOF
s#CASENAME#$1#
EOF

    sed -f ${BASE_DIR}/sed.in ${HTML_FILE} >! ${NEW_DIR}/temp.html
    /bin/mv -f ${NEW_DIR}/temp.html ${NEW_DIR}/diff_plots.html
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



