#!/bin/csh
# USAGE:  all_plots.csh <casename> <beg_yr> >end_yr>

if ($#argv != 3) then
  echo "usage: all_plots.csh <casename> <beg_yr> <end_yr>"
  exit
endif

set echo on

# User mods
# For difference plots, set DIFF_PLOTS to 1, otherwise just model
# versus obs.
set DIFF_PLOTS = 0
# Set BASE_DIR to current working directory.
set BASE_DIR = .
#

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
  if !(-d obs) mkdir -p -m 0775 ${NEW_DIR}/obs

  # Untar the png files  This will put the *.png file in the
  # same directory as the tar file

  if ($DIFF_PLOTS == 1) then

     tar -xf ${BASE_DIR}/diff_plots.tar 

     mv ${BASE_DIR}/*.png ${NEW_DIR}

     mv ${NEW_DIR}/*icesat*.png  ${NEW_DIR}/obs
     mv ${NEW_DIR}/*ASPeCt*.png  ${NEW_DIR}/obs
     mv ${NEW_DIR}/diff_con_*.png  ${NEW_DIR}/contour
     mv ${NEW_DIR}/diff_vec_*.png  ${NEW_DIR}/vector
     mv ${NEW_DIR}/line*.png   ${NEW_DIR}/line
     mv ${NEW_DIR}/clim*.png   ${NEW_DIR}/line

  else

     tar -xf ${BASE_DIR}/all_plots.tar 

     mv ${BASE_DIR}/*.png ${NEW_DIR}

     mv ${NEW_DIR}/*icesat*.png  ${NEW_DIR}/obs
     mv ${NEW_DIR}/*ASPeCt*.png  ${NEW_DIR}/obs
     mv ${NEW_DIR}/con_*.png  ${NEW_DIR}/contour
     mv ${NEW_DIR}/vec_*.png  ${NEW_DIR}/vector
     mv ${NEW_DIR}/line*.png   ${NEW_DIR}/line
     mv ${NEW_DIR}/clim*.png   ${NEW_DIR}/line

  endif

cat >! ${NEW_DIR}/obs/ICESat.txt << EOF1
Documentation of the satellite based (ICESat) derived sea ice thickness is found in:

Kwok, R., G. F. Cunningham, M. Wensnahan, I. Rigor, H. J. Zwally,
and D. Yi, 2009: Thinning and volume loss of the Arctic Ocean
sea ice cover: 2003–2008. J. Geophys. Res., 114, C07005,
doi:10.1029/2009JC005312.
EOF1

cat >! ${NEW_DIR}/obs/ASPeCt.txt << EOF
The ship-based sea ice and snow thickness data were provided by the SCAR 
Antarctic Sea Ice Processes and Climate (ASPeCt) program (www.aspect.aq).
A full description of the data quality control and processing can be found in 
Worby et al (2008).

Worby, A. P., C. Geiger, M. J. Paget, M. van Woert, S. F Ackley, T. DeLiberty, 
(2008). Thickness distribution of Antarctic sea ice. J. Geophys. Res., 113, 
C05S92, doi:10.1029/2007JC004254.
EOF

  echo "Done moving png files"

  # Move the html file and modify them to include the new case name

  set HTML_FILE = ${NEW_DIR}/index_temp.html
  if !(-e $HTML_FILE) then

    if ($DIFF_PLOTS == 1) then
       cp ${BASE_DIR}/index_diff_temp.html ${HTML_FILE}
       cp ${BASE_DIR}/contour_diff.html ${NEW_DIR}/contour.html
       cp ${BASE_DIR}/vector_diff.html ${NEW_DIR}/vector.html
       cp ${BASE_DIR}/timeseries_diff.html ${NEW_DIR}/timeseries.html
       cp ${BASE_DIR}/regional_diff.html ${NEW_DIR}/regional.html
    else
       cp ${BASE_DIR}/index_temp.html ${HTML_FILE}
       cp ${BASE_DIR}/contour.html ${NEW_DIR}
       cp ${BASE_DIR}/vector.html ${NEW_DIR}
       cp ${BASE_DIR}/timeseries.html ${NEW_DIR}
       cp ${BASE_DIR}/regional.html ${NEW_DIR}
    endif

cat >! ${BASE_DIR}/sed.in << EOF
s#CASENAME#$1#
EOF

    sed -f ${BASE_DIR}/sed.in ${HTML_FILE} >! ${NEW_DIR}/temp.html
    /bin/mv -f ${NEW_DIR}/temp.html ${NEW_DIR}/index.html
    sed -i -f ${BASE_DIR}/sed.in ${NEW_DIR}/contour.html
    sed -i -f ${BASE_DIR}/sed.in ${NEW_DIR}/vector.html
    sed -i -f ${BASE_DIR}/sed.in ${NEW_DIR}/timeseries.html
    sed -i -f ${BASE_DIR}/sed.in ${NEW_DIR}/regional.html
    rm -f ${BASE_DIR}/sed.in

    rm -f ${HTML_FILE}
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



