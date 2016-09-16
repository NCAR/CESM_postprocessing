#!/bin/bash

# Extract time-series of global averages for model 2D and 3D variables.
# Created by Ivan Lima on Mon Aug 22 11:58:54 EDT 2011
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - include NCAR directories,
#  - Python NCAR path,
#  - check if file exists,
#  - include module commands,


run="$1"
yyyystart=$2
yyyyend=$3

yrstart=`printf "%04d" $yyyystart`
yrend=`printf "%04d" $yyyyend`

echo "BEGIN $(date)"
echo "INDIR $indir"

# The process number ($$) has been included as part of the directory
if [ "$POPDIAG" = "TRUE" ]
 then 
  tmpdir="${WORKDIR}/tmp-$$"
  outdir=$WORKDIR
  source /etc/profile.d/modules.sh
  module load ncl
  module load python
 else
  tmpdir="/mnt/ramdisk/tmp-$$"
  outdir="/bonaire/data2/ivan/ccsm_output/${run}"
fi

if [ ! -d "$tmpdir" ]
then
    mkdir -p $tmpdir
fi

if [ ! -d "$outdir" ]
then
    mkdir -p $outdir
fi

# Get variables to be extracted
if [ "$POPDIAG" = "TRUE" ]
 then 
  python $ECOPATH/get_variables.py ${run} ${WORKDIR}
 else
  python get_variables.py ${run}
fi
source variables.${run}.sh

filets="${WORKDIR}/tseries.${yrstart}-${yrend}.${run}.global.nc"
filetsp="${WORKDIR}/tseries.profile.${yrstart}-${yrend}.${run}.global.nc"

if [ ! -f $filets -o ! -f $filetsp ]; then

 echo "The global time series are being calculated."

 yr=$yyyystart

 while [ $yr -le $yyyyend ]; do

  yrin=`printf "%04d" $yr`

  for mm in {01..12}; do

# Modified line to account for octal numbers
   if [ "$POPDIAG" = "TRUE" ]
    then 
     month=`echo 0$mm | tail -c3`
    else
     month=`printf "%02d" $mm`
   fi

   cnt=${yrin}-${month}.${run}

  filemonts="${WORKDIR}/tseries.${cnt}.global.nc"
  filemontsp="${WORKDIR}/tseries.profile.${cnt}.global.nc"

  echo "Checking file $filemonts."
  echo "Checking file $filemontsp."

   if [ ! -f $filemonts -o ! -f $filemontsp ]; then

    file="${indir}/${run}.pop.h.${yrin}-${month}.nc"
    tmpfile="${tmpdir}/tmp.${cnt}.nc"

    echo "processing ${file}"

    /bin/cp ${file} ${tmpfile}
    ncks -A -h -v REGION_MASK_BEC,TVOLUME,TVOLUME_150m ${maskfile} ${tmpfile}

    # compute global averages

    # 2-D variables
    ncwa -O -h -y ttl -a nlat,nlon -v TAREA -B "REGION_MASK_BEC != 0" \
        ${tmpfile} ${tmpdir}/tseries.${cnt}.global.nc
    ncwa -A -h -a nlat,nlon -v ${varlist2D} -w TAREA ${tmpfile} \
        ${tmpdir}/tseries.${cnt}.global.nc
    # 3-D variables 
    ncwa -A -h -y ttl -a z_t,nlat,nlon -v TVOLUME ${tmpfile} \
        ${tmpdir}/tseries.${cnt}.global.nc
    ncwa -A -h -a z_t,nlat,nlon -v ${varlist3D} -w TVOLUME ${tmpfile} \
        ${tmpdir}/tseries.${cnt}.global.nc
    if [ -n "${varlistBIO}" ]
    then
        # 3-D bio variables 
        ncwa -A -h -y ttl -a z_t_150m,nlat,nlon -v TVOLUME_150m \
            ${tmpfile} ${tmpdir}/tseries.${cnt}.global.nc
        ncwa -A -h -a z_t_150m,nlat,nlon -v ${varlistBIO} -w TVOLUME_150m \
            ${tmpfile} ${tmpdir}/tseries.${cnt}.global.nc
        # 3-D variables vertical profiles
        ncwa -O -h -a nlat,nlon -v ${varlist3D},${varlistBIO} \
            -w TAREA ${tmpfile} ${tmpdir}/tseries.profile.${cnt}.global.nc
    else
        # 3-D variables vertical profiles
        ncwa -O -h -a nlat,nlon -v ${varlist3D} -w TAREA ${tmpfile} \
            ${tmpdir}/tseries.profile.${cnt}.global.nc
    fi
    # append additional coordinate variables to vertical profiles file
    ncks -A -h -v z_w,dz,dzw ${tmpfile} \
        ${tmpdir}/tseries.profile.${cnt}.global.nc

    # compute derived variables

    # compute totChl and set attributes
    ncap -O -h \
        -s "totChl[time,z_t_150m,nlat,nlon]=spChl+diatChl+diazChl" \
        ${tmpdir}/tseries.${cnt}.global.nc ${tmpdir}/tseries.${cnt}.global.nc
    ncatted -O -h \
        -a long_name,totChl,c,c,"Total Chlorophyll" \
        -a units,totChl,c,c,"mg Chl/m^3" \
        -a coordinates,totChl,c,c,"TLONG TLAT z_t_150m time" \
        ${tmpdir}/tseries.${cnt}.global.nc
    ncap -O -h \
        -s "totChl[time,z_t_150m,nlat,nlon]=spChl+diatChl+diazChl" \
        ${tmpdir}/tseries.profile.${cnt}.global.nc \
        ${tmpdir}/tseries.profile.${cnt}.global.nc
    ncatted -O -h \
        -a long_name,totChl,c,c,"Total Chlorophyll" \
        -a units,totChl,c,c,"mg Chl/m^3" \
        -a coordinates,totChl,c,c,"TLONG TLAT z_t_150m time" \
        ${tmpdir}/tseries.profile.${cnt}.global.nc
    # compute phytoC and set attributes
    ncap -O -h \
        -s "phytoC[time,z_t_150m,nlat,nlon]=spC+diatC+diazC" \
        ${tmpdir}/tseries.${cnt}.global.nc ${tmpdir}/tseries.${cnt}.global.nc
    ncatted -O -h \
        -a long_name,phytoC,c,c,"Total Phytoplankton Carbon" \
        -a units,phytoC,c,c,"mmol C/m^3" \
        -a coordinates,phytoC,c,c,"TLONG TLAT z_t_150m time" \
        ${tmpdir}/tseries.${cnt}.global.nc
    ncap -O -h \
        -s "phytoC[time,z_t_150m,nlat,nlon]=spC+diatC+diazC" \
        ${tmpdir}/tseries.profile.${cnt}.global.nc \
        ${tmpdir}/tseries.profile.${cnt}.global.nc
    ncatted -O -h \
        -a long_name,phytoC,c,c,"Total Phytoplankton Carbon" \
        -a units,phytoC,c,c,"mmol C/m^3" \
        -a coordinates,phytoC,c,c,"TLONG TLAT z_t_150m time" \
        ${tmpdir}/tseries.profile.${cnt}.global.nc
    # compute photoC_tot and set attributes
    ncap -O -h -s \
        "photoC_tot[time,z_t_150m,nlat,nlon]=photoC_sp+photoC_diat+photoC_diaz"\
        ${tmpdir}/tseries.${cnt}.global.nc ${tmpdir}/tseries.${cnt}.global.nc
    ncatted -O -h \
        -a long_name,photoC_tot,c,c,"Total C uptake by Phytoplankton" \
        -a units,photoC_tot,c,c,"mmol C/m^3/sec" \
        -a coordinates,photoC_tot,c,c,"TLONG TLAT z_t_150m time" \
        ${tmpdir}/tseries.${cnt}.global.nc
    ncap -O -h -s \
        "photoC_tot[time,z_t_150m,nlat,nlon]=photoC_sp+photoC_diat+photoC_diaz"\
        ${tmpdir}/tseries.profile.${cnt}.global.nc \
        ${tmpdir}/tseries.profile.${cnt}.global.nc
    ncatted -O -h \
        -a long_name,photoC_tot,c,c,"Total C uptake by Phytoplankton" \
        -a units,photoC_tot,c,c,"mmol C/m^3/sec" \
        -a coordinates,photoC_tot,c,c,"TLONG TLAT z_t_150m time" \
        ${tmpdir}/tseries.profile.${cnt}.global.nc
    # compute NO3_excess and set attributes
    ncap -O -h \
        -s "NO3_excess[time,z_t,nlat,nlon]=NO3-(16.*PO4)" \
        ${tmpdir}/tseries.${cnt}.global.nc ${tmpdir}/tseries.${cnt}.global.nc
    ncatted -O -h \
        -a long_name,NO3_excess,c,c,"Excess NO3" \
        -a units,NO3_excess,c,c,"mmol N/m^3" \
        -a coordinates,NO3_excess,c,c,"TLONG TLAT z_t time" \
        ${tmpdir}/tseries.${cnt}.global.nc
    ncap -O -h \
        -s "NO3_excess[time,z_t,nlat,nlon]=NO3-(16.*PO4)" \
        ${tmpdir}/tseries.profile.${cnt}.global.nc \
        ${tmpdir}/tseries.profile.${cnt}.global.nc
    ncatted -O -h \
        -a long_name,NO3_excess,c,c,"Excess NO3" \
        -a units,NO3_excess,c,c,"mmol N/m^3" \
        -a coordinates,NO3_excess,c,c,"TLONG TLAT z_t time" \
        ${tmpdir}/tseries.profile.${cnt}.global.nc

    rm -f ${tmpfile}

     cp ${tmpdir}/tseries.${cnt}.global.nc ${outdir}/tseries.${cnt}.global.nc
     cp ${tmpdir}/tseries.profile.${cnt}.global.nc ${outdir}/tseries.profile.${cnt}.global.nc

   fi #- Conditional of monthly file
 done #- Month loop

 yr=$(( $yr + 1 ))

done #- Year loop

# contatenate monthly averages into time-series files
echo "writing ${filets}"
ncrcat -O -h $(/bin/ls ${outdir}/tseries.????-??.${run}.global.nc) \
    ${filets}

if [ "$POPDIAG" = "TRUE" ]
 then 
  ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by <${LOGNAME}@ucar.edu>" ${filets}
 else
  ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by Ivan Lima <ivan@whoi.edu>" ${outdir}/tseries.${run}.global.nc
fi

echo "writing ${filetsp}"
ncrcat -O -h $(/bin/ls ${outdir}/tseries.profile.????-??.${run}.global.nc) \
    ${filetsp}

if [ "$POPDIAG" = "TRUE" ]
 then 
  ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by <${LOGNAME}@ucar.edu>" ${filetsp}
 else
  ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by Ivan Lima <ivan@whoi.edu>" ${outdir}/tseries.profile.${run}.global.nc
fi

fi #- Conditional of time series file

# remove temporary directories
if [ "$POPDIAG" != "TRUE" ]
 then
  rm -rf ${tmpdir}
fi

echo "END $(date)"

