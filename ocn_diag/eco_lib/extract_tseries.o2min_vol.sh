#!/bin/bash

# Extract time-series of percentage of global ocean volume with O2 < O2 min
#(4 mmol/m^3).
# Created by Ivan Lima on Thu Sep 22 09:35:56 EDT 2011
# Modified by Ernesto Munoz on Fri Dec 7 2012
#  - include NCAR directories,
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
  module load nco
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

nreg=${#region[*]}

r=1
while [ $r -le $nreg ]; do

 echo -e "Checking oxygen time-series for region ${r} (${region[${r}]})"
 reg=$(printf "reg-%02d" $r)

 fileregtso2="${outdir}/tseries.${yrstart}-${yrend}.${run}.o2_min_vol.${region[${r}]}.nc"
 fileglotso2="${outdir}/tseries.${yrstart}-${yrend}.${run}.o2_min_vol.global.nc"

 if [ ! -f $fileregtso2 -o ! -f $fileglotso2 ]; then

  echo -e "The oxygen time-series for region ${r} (${region[${r}]}) is being assembled."

  yr=$yyyystart

  while [ $yr -le $yyyyend ]; do

   yrin=`printf "%04d" $yr`

   for mm in {01..12}; do

#   Modified line to account for octal numbers
    if [ "$POPDIAG" = "TRUE" ]
     then
      month=`echo 0$mm | tail -c3`
     else
      month=`printf "%02d" $mm`
    fi

    cnt=${yrin}-${month}.${run}

    filemonregts="${outdir}/vol.${cnt}.${reg}.nc"
    filemonglots="${outdir}/vol.${cnt}.global.nc"

    if [ ! -f $filemonregts -o ! -f $filemonglots ]; then

    file="${indir}/${run}.pop.h.${yrin}-${month}.nc"
    tmpfile="${tmpdir}/tmp.${cnt}.nc"

    echo "Processing ${file}"

    ncks -O -h -v dz,TAREA,O2,DIC ${file} ${tmpfile}
    ncap2 -O -h -s "VMASK[time,z_t,nlat,nlon]=DIC/DIC" ${tmpfile} ${tmpfile}
    ncap2 -O -h -s "TVOLUME[time,z_t,nlat,nlon]=dz*TAREA*VMASK" ${tmpfile} \
        ${tmpfile}
    ncwa -O -h -y ttl -a z_t,nlat,nlon -v TVOLUME -B "O2 < 4" ${tmpfile} \
        ${tmpdir}/vol.${cnt}.global.nc
    ncrename -h -v TVOLUME,TVOL_O2 ${tmpdir}/vol.${cnt}.global.nc
    ncwa -A -C -h -y ttl -a z_t,nlat,nlon -v TVOLUME ${tmpfile} \
        ${tmpdir}/vol.${cnt}.global.nc >& /dev/null
    ncap2 -O -h -s "o2_min_vol[time]=TVOL_O2/TVOLUME*100." \
        ${tmpdir}/vol.${cnt}.global.nc ${tmpdir}/vol.${cnt}.global.nc
    ncatted -O -h \
    -a long_name,o2_min_vol,c,c,"% volume of ocean with O2 < 4 mmol/m^3" \
    -a units,o2_min_vol,c,c,"%" \
    ${tmpdir}/vol.${cnt}.global.nc

    # compute regional volumes
        echo -e "computing average for region ${r} (${region[${r}]})"

        ncks -A -h -v REGION_MASK_BEC ${maskfile} ${tmpfile}
        ncap2 -O -h -s \
            "msk[time,z_t,nlat,nlon]=((O2<4) && (REGION_MASK_BEC==${r}));" \
            ${tmpfile} ${tmpdir}/mask.${cnt}.${reg}.nc
        ncap2 -O -h -s "TVOL_O2=(TVOLUME*msk).ttl()" \
            ${tmpdir}/mask.${cnt}.${reg}.nc ${tmpdir}/mask.${cnt}.${reg}.nc
        ncwa -O -C -h -y ttl -a z_t,nlat,nlon -v TVOLUME \
            -B "REGION_MASK_BEC == ${r}" ${tmpfile} \
            ${tmpdir}/vol.${cnt}.${reg}.nc 
        ncks -A -h -v TVOL_O2 ${tmpdir}/mask.${cnt}.${reg}.nc \
            ${tmpdir}/vol.${cnt}.${reg}.nc
        ncap2 -O -h -s "o2_min_vol[time]=TVOL_O2/TVOLUME*100." \
            ${tmpdir}/vol.${cnt}.${reg}.nc ${tmpdir}/vol.${cnt}.${reg}.nc
        ncatted -O -h \
            -a long_name,o2_min_vol,c,c,"% volume of ocean with O2 < 4 mmol/m3"\
            -a units,o2_min_vol,c,c,"%" \
            ${tmpdir}/vol.${cnt}.${reg}.nc

        /bin/rm -f ${tmpdir}/mask.${cnt}.${reg}.nc
        /bin/rm -f ${tmpfile}

        cp ${tmpdir}/vol.${cnt}.global.nc ${outdir}/vol.${cnt}.global.nc 
        cp ${tmpdir}/vol.${cnt}.${reg}.nc ${outdir}/vol.${cnt}.${reg}.nc 

       fi #- Conditional of monthly file 
     done #- Month loop

     yr=$(( $yr + 1 ))

     done #- Year loop

# concatenate monthly averages into time-series files

    echo "writing ${fileglotso2}"
    ncrcat -O -h -v o2_min_vol $(/bin/ls ${outdir}/vol.????-??.${run}.global.nc) \
        ${fileglotso2}

    if [ "$POPDIAG" = "TRUE" ]
     then
      ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by <${LOGNAME}@ucar.edu>" ${fileglotso2}
     else
      ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by Ivan Lima <ivan@ucar.edu>" ${outdir}/tseries.${run}.o2_min_vol.global.nc
    fi

    echo "writing ${fileregtso2}"
    ncrcat -O -h -v o2_min_vol $(/bin/ls ${outdir}/vol.????-??.${run}.${reg}.nc) \
        ${fileregtso2}
    if [ "$POPDIAG" = "TRUE" ]
     then
      ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by <${LOGNAME}@ucar.edu>" ${fileregtso2}
     else
      ncatted -h -a history,global,a,c,"\nCreated on $(date "+%F %R") by Ivan Lima <ivan@ucar.edu>" ${outdir}/tseries.${run}.o2_min_vol.${region[${r}]}.nc
    fi

  fi #- Conditional of time-series file

  let r=r+1

done #- Region loop

rm -rf ${tmpdir}

echo "END $(date)"
