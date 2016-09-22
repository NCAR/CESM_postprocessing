#!/bin/bash

# Run the various time-series extraction scripts for given case.
# Created by Ivan Lima on Tue Aug 23 14:50:28 EDT 2011
# Last modified on Tue Sep 27 08:36:09 EDT 2011
# Modified by Ernesto Munoz on Fri Dec 7 2012 to include NCAR directories.

# NOTE: Before starting script, needs to create ramdisk that is used as
# temporary storage to speed up IO.
#sudo mount -t tmpfs -o size=66% tmpfs /mnt/ramdisk
# The note above is from Ivan Lima (WHOI)

run=$1
yyyystart=$2
yyyyend=$3
mgrid=$4

echo ' '
echo Computing global, regional and o2min_vol time series.

if [ "$POPDIAG" != "TRUE" ]; then
    rmaskfile="/home/ivan/Python/data/BEC_REGION_MASK_gx1v6.nc"
    gridfile="/home/ivan/Python/data/gx1v6.nc"
else
  if [ "$mgrid" = "gx1v6" ]; then
    rmaskfile="${ECODATADIR}/mapping/model_grid/BEC_REGION_MASK_gx1v6.nc"
    gridfile="${ECODATADIR}/mapping/model_grid/gx1v6.nc"
  else
    if [ "$mgrid" = "gx3v7" ]; then
      rmaskfile="${ECODATADIR}/mapping/model_grid/BEC_REGION_MASK_gx3v5.nc"
      gridfile="${ECODATADIR}/mapping/model_grid/gx3v5.nc"
    fi
  fi
fi

if [ "$POPDIAG" = "TRUE" ]
  then  # NCAR directories
    export indir=$WORKDIR
    export maskfile="${WORKDIR}/rmask.nc"
    echo Using NCAR directories.
    echo The maskfile is: 
    echo $maskfile
  else  # WHOI directories
    export indir="/caiapo/data0/${run}/ocn"
    export maskfile="/mnt/ramdisk/rmask.nc"
    echo Input/Output directories as in WHOI. Create RAMDISK for storage.
    echo If at NCAR, initialize POPDIAG environment variable to TRUE.
fi

filelist=($(/bin/ls ${indir}/${run}.pop.h.*.nc))
#if ($status != 0) then
# set yr = `printf "%04d" $yyyystart`
# if ($REMOTE_DISK ~= NULL) then
#   cp $REMOTE_DISK/$run.pop.h.${yr}-01.nc" $WORKDIR/.
#   if ($status != 0) cp ${REMOTE_DISK}/${run}.pop.h.${yr}.nc $WORKDIR.
# else
#   hsi "ls /$MSROOT/$run/ocn/hist/$run.pop.h.*.nc"
#   if ($status = 0) hsi "get /$MSROOT/$run/ocn/hist/$run.pop.h.$yr-01.nc"
#   if ($status != 0) hsi "get /$MSROOT/$run/ocn/proc/tavg/annual/$run.pop.h.$yr.nc"
# fi
# filelist=($(/bin/ls ${indir}/${run}.pop.h.*.nc))
# if ($status != 0) echo Trouble getting run output. You may need to copy a monthly or annual file to WORKDIR mannually and restarting the script.
#fi 
 

# Remove maskfile if exists
 if [ -f maskfile ]
   then
     rm -f maskfile
     echo An old maskfile has been removed.
   else
     echo The maskfile does not exist. Will be created.
 fi

#------------------------------------------------------------------------------
# create masked volume for computing total global & regional ocean volumes

ncwa -O -h -a time -v dz,TAREA,DIC ${filelist[0]} ${maskfile}
ncap2 -O -h -s "VMASK[z_t,nlat,nlon]=DIC/DIC" ${maskfile} ${maskfile}
ncap2 -O -h -s "TVOLUME[z_t,nlat,nlon]=dz*TAREA*VMASK" ${maskfile} ${maskfile}

# compute volume for variables with dimension z_t_150m
ncks -O -h -v TVOLUME -d z_t,0,14 ${maskfile} vmask150m.nc
ncrename -h -v TVOLUME,TVOLUME_150m vmask150m.nc
ncrename -h -v z_t,z_t_150m vmask150m.nc
ncrename -h -d z_t,z_t_150m vmask150m.nc
ncks -A -h -v TVOLUME_150m vmask150m.nc ${maskfile}
rm -f vmask150m.nc

# add variables attributes
ncatted -O -h -a long_name,TVOLUME,c,c,"volume of T cells" \
    -a units,TVOLUME,c,c,"centimeter^3" ${maskfile}
ncatted -O -h -a long_name,TVOLUME_150m,c,c,"volume of T cells in upper 150m" \
    -a units,TVOLUME_150m,c,c,"centimeter^3" ${maskfile}

# add region mask for computing regional time-series
ncks -A -h -v REGION_MASK ${rmaskfile} ${maskfile}
ncrename -h -v REGION_MASK,REGION_MASK_BEC ${maskfile}

#------------------------------------------------------------------------------

# This part is running the same script but for the different regions.

echo Computing global time series.
$ECOPATH/extract_tseries.global.sh ${run} ${yyyystart} ${yyyyend} >& log.global.jump &
sleep 60
echo Computing regional time series.
$ECOPATH/extract_tseries.region.sh ${run} ${yyyystart} ${yyyyend} 1  2  3  >& log.reg.skip.001 &
sleep 60
$ECOPATH/extract_tseries.region.sh ${run} ${yyyystart} ${yyyyend} 4  5  6  >& log.reg.skip.002 &
sleep 60
$ECOPATH/extract_tseries.region.sh ${run} ${yyyystart} ${yyyyend} 7  8  9  >& log.reg.skip.003 &
sleep 60
$ECOPATH/extract_tseries.region.sh ${run} ${yyyystart} ${yyyyend} 10 11 12 >& log.reg.skip.004 &
sleep 60
$ECOPATH/extract_tseries.region.sh ${run} ${yyyystart} ${yyyyend} 13 14    >& log.reg.skip.005 &
sleep 60
echo Computing o2min_vol time series.
$ECOPATH/extract_tseries.o2min_vol.sh ${run} ${yyyystart} ${yyyyend} >& log.o2min.hop &
wait 

#------------------------------------------------------------------------------
