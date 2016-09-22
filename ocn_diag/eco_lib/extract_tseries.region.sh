#!/bin/bash

# Extract time-series of regional averages for model 2D and 3D variables.
# Created by Ivan Lima on Tue Aug 23 15:09:14 EDT 2011
# Modified by Ernesto Munoz on Fri Dec 7 2012 to:
#  - include NCAR directories,
#  - Python NCAR path,
#  - check if file exists,
#  - include module commands


run="$1"
yyyystart=$2
yyyyend=$3

yrstart=`printf "%04d" $yyyystart`
yrend=`printf "%04d" $yyyyend`

rlist="$4 $5 $6 $7 $8 $9"

echo "BEGIN $(date)"
echo "INDIR $indir"

# The process number ($$) has been included as part of the directory 
if [ "$POPDIAG" = "TRUE" ]
 then
  tmpdir="${WORKDIR}/tmp-$$"
  outdir=$WORKDIR
  source /etc/profile.d/modules.sh
  module load nco
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

# suffix for output file name                                                   
declare -a region
region=([1]=south_southern [2]=north_southern [3]=south_subtrop_pac [4]=west_eq_pac [5]=east_eq_pac [6]=north_subtrop_pac [7]=north_pac [8]=south_ind [9]=north_ind [10]=south_atl [11]=north_subtrop_atl [12]=north_atl [13]=arctic [14]=med)

# get variables to be extracted
if [ "$POPDIAG" = "TRUE" ]
 then
  python $ECOPATH/get_variables.py ${run} ${WORKDIR}
 else
  python get_variables.py ${run}
fi
source variables.${run}.sh

for r in ${rlist}; do

 echo -e "Checking time-series for region ${r} (${region[${r}]})"
 reg=$(printf "reg-%02d" $r)

 fileregts="${outdir}/tseries.${yrstart}-${yrend}.${run}.${region[${r}]}.nc"
 fileregtsp="${outdir}/tseries.profile.${yrstart}-${yrend}.${run}.${region[${r}]}.nc"

 if [ ! -f $fileregts -o ! -f $fileregtsp ]; then
 echo -e "The time-series file for region ${r} (${region[${r}]}) is being assembled."

 yr=$yyyystart
 echo "yr is $yr."
 echo "yyyyend is $yyyyend."

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

  filemonregts="${outdir}/tseries.${cnt}.${reg}.nc"
  filemonregtsp="${outdir}/tseries.profile.${cnt}.${reg}.nc"

  echo "Checking file $filemonregts."
  echo "Checking file $filemonregtsp."

   if [ ! -f $filemonregts -o ! -f $filemonregtsp ]; then

    file="${indir}/${run}.pop.h.${yrin}-${month}.nc"
    tmpfile="${tmpdir}/tmp.${cnt}.nc"

    echo "processing ${file}"

    /bin/cp ${file} ${tmpfile}
    ncks -A -h -v REGION_MASK_BEC,TVOLUME,TVOLUME_150m ${maskfile} ${tmpfile}

        # 2-D variables
        ncwa -O -h -y ttl -v TAREA -a nlat,nlon -B "REGION_MASK_BEC == ${r}"\
            ${tmpfile} ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncwa -A -h -v ${varlist2D} -a nlat,nlon -B "REGION_MASK_BEC == ${r}"\
            -w TAREA ${tmpfile} ${tmpdir}/tseries.${cnt}.${reg}.nc
        # 3-D variables 
        ncwa -A -h -y ttl -v TVOLUME -a z_t,nlat,nlon \
            -B "REGION_MASK_BEC == ${r}"\
            ${tmpfile} ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncwa -A -h -v ${varlist3D} -a z_t,nlat,nlon \
            -B "REGION_MASK_BEC == ${r}" -w TVOLUME ${tmpfile} \
            ${tmpdir}/tseries.${cnt}.${reg}.nc
        if [ -n "${varlistBIO}" ]
        then
            # 3-D bio variables 
            ncwa -A -h -y ttl -v TVOLUME_150m -a z_t_150m,nlat,nlon \
                -B "REGION_MASK_BEC == ${r}" ${tmpfile} \
                ${tmpdir}/tseries.${cnt}.${reg}.nc
            ncwa -A -h -v ${varlistBIO} -a z_t_150m,nlat,nlon \
                -B "REGION_MASK_BEC == ${r}" -w TVOLUME_150m ${tmpfile} \
                ${tmpdir}/tseries.${cnt}.${reg}.nc
            # 3-D variables vertical profiles
            ncwa -O -h -v ${varlist3D},${varlistBIO} -a nlat,nlon \
                -B "REGION_MASK_BEC == ${r}" -w TAREA ${tmpfile} \
                ${tmpdir}/tseries.profile.${cnt}.${reg}.nc
        else
            # 3-D variables vertical profiles
            ncwa -O -h -v ${varlist3D} -a nlat,nlon \
                -B "REGION_MASK_BEC == ${r}" -w TAREA ${tmpfile} \
                ${tmpdir}/tseries.profile.${cnt}.${reg}.nc
        fi
        # append additional coordinate variables
        ncks -A -h -v z_w,dz,dzw ${tmpfile} \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc

        # compute derived variables

        # compute totChl and set attributes
        ncap -O -h \
            -s "totChl[time,z_t_150m,nlat,nlon]=spChl+diatChl+diazChl" \
            ${tmpdir}/tseries.${cnt}.${reg}.nc \
            ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncatted -O -h \
            -a long_name,totChl,c,c,"Total Chlorophyll" \
            -a units,totChl,c,c,"mg Chl/m^3" \
            -a coordinates,totChl,c,c,"TLONG TLAT z_t_150m time" \
            ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncap -O -h \
            -s "totChl[time,z_t_150m,nlat,nlon]=spChl+diatChl+diazChl" \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc
        ncatted -O -h \
            -a long_name,totChl,c,c,"Total Chlorophyll" \
            -a units,totChl,c,c,"mg Chl/m^3" \
            -a coordinates,totChl,c,c,"TLONG TLAT z_t_150m time" \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc
        # compute phytoC and set attributes
        ncap -O -h \
            -s "phytoC[time,z_t_150m,nlat,nlon]=spC+diatC+diazC" \
            ${tmpdir}/tseries.${cnt}.${reg}.nc \
            ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncatted -O -h \
            -a long_name,phytoC,c,c,"Total Phytoplankton Carbon" \
            -a units,phytoC,c,c,"mmol C/m^3" \
            -a coordinates,phytoC,c,c,"TLONG TLAT z_t_150m time" \
            ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncap -O -h \
            -s "phytoC[time,z_t_150m,nlat,nlon]=spC+diatC+diazC" \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc
        ncatted -O -h \
            -a long_name,phytoC,c,c,"Total Phytoplankton Carbon" \
            -a units,phytoC,c,c,"mmol C/m^3" \
            -a coordinates,phytoC,c,c,"TLONG TLAT z_t_150m time" \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc
        # compute photoC_tot and set attributes
        ncap -O -h -s \
            "photoC_tot[time,z_t_150m,nlat,nlon]=photoC_sp+photoC_diat+photoC_diaz" \
            ${tmpdir}/tseries.${cnt}.${reg}.nc \
            ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncatted -O -h \
            -a long_name,photoC_tot,c,c,"Total C uptake by Phytoplankton" \
            -a units,photoC_tot,c,c,"mmol C/m^3/sec" \
            -a coordinates,photoC_tot,c,c,"TLONG TLAT z_t_150m time" \
            ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncap -O -h -s \
            "photoC_tot[time,z_t_150m,nlat,nlon]=photoC_sp+photoC_diat+photoC_diaz" \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc
        ncatted -O -h \
            -a long_name,photoC_tot,c,c,"Total C uptake by Phytoplankton" \
            -a units,photoC_tot,c,c,"mmol C/m^3/sec" \
            -a coordinates,photoC_tot,c,c,"TLONG TLAT z_t_150m time" \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc
        # compute NO3_excess and set attributes
        ncap -O -h \
            -s "NO3_excess[time,z_t,nlat,nlon]=NO3-(16.*PO4)" \
            ${tmpdir}/tseries.${cnt}.${reg}.nc \
            ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncatted -O -h \
            -a long_name,NO3_excess,c,c,"Excess NO3" \
            -a units,NO3_excess,c,c,"mmol N/m^3" \
            -a coordinates,NO3_excess,c,c,"TLONG TLAT z_t time" \
            ${tmpdir}/tseries.${cnt}.${reg}.nc
        ncap -O -h \
            -s "NO3_excess[time,z_t,nlat,nlon]=NO3-(16.*PO4)" \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc
        ncatted -O -h \
            -a long_name,NO3_excess,c,c,"Excess NO3" \
            -a units,NO3_excess,c,c,"mmol N/m^3" \
            -a coordinates,NO3_excess,c,c,"TLONG TLAT z_t time" \
            ${tmpdir}/tseries.profile.${cnt}.${reg}.nc

    rm -f ${tmpfile}

    cp ${tmpdir}/tseries.${cnt}.${reg}.nc ${outdir}/tseries.${cnt}.${reg}.nc
    cp ${tmpdir}/tseries.profile.${cnt}.${reg}.nc ${outdir}/tseries.profile.${cnt}.${reg}.nc

   fi  #- Conditional of monthly file
  done #- Month loop

  yr=$(( $yr + 1 ))

  done  #- Year loop

# concatenate monthly averages into time-series files

    echo "writing ${fileregts}"
    ncrcat -O -h $(/bin/ls ${outdir}/tseries.????-??.${run}.${reg}.nc) \
        ${fileregts}

  if [ "$POPDIAG" = "TRUE" ]
   then
    ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by <${LOGNAME}@ucar.edu>" ${fileregts}
   else
    ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by Ivan Lima <ivan@ucar.edu>" ${outdir}/tseries.${run}.${region[${r}]}.nc
  fi

    echo "writing ${fileregtsp}"
    ncrcat -O -h $(/bin/ls ${outdir}/tseries.profile.????-??.${run}.${reg}.nc) \
        ${fileregtsp}

  if [ "$POPDIAG" = "TRUE" ]
   then
    ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by <${LOGNAME}@ucar.edu>" ${fileregtsp}
   else
    ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by Ivan Lima <ivan@ucar.edu>" ${outdir}/tseries.profile.${run}.${region[${r}]}.nc
  fi

  fi #- Conditional of time series file

done #- Region loop

# Remove temporary directories
if [ "$POPDIAG" != "TRUE" ]
 then
  rm -rf ${tmpdir}
fi

echo "END $(date)"

