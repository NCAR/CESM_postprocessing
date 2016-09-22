#!/bin/bash

# Extract 12-month climatology and zonal averages for given period from gx1
# model runs for analysis and plotting.
# Created by Ivan Lima on Wed Nov  3 14:37:21 EDT 2010
# Modified by Ernesto Munoz and finalized on Mon Dec 7 2012 to:
#    - read list of input variables,
#    - choose directories (NCAR or WHOI),
#    - create symbolic (soft) link,
#    - use comprehensive file names,
#    - use environment variables from popdiag.csh or popdiagdiff.csh

# Uses:
#  za which is a code to do zonal averages

# Creates files with names:
#    ${run}.${var}.clim.${yrstart}-${yrend}.nc
#    za.${run}.${var}.clim.${yrstart}-${yrend}.nc


run=$1
yyyystart=$2
yyyyend=$3
allvars=$*
nvars=$#
nvarsm3=$(( $nvars - 3 ))

if [ $nvars -gt 3 ]
   then
       echo "Variable list passed to extract_zavg.sh"
fi

varlist=${!4}
for ((i = 4; i <= $nvars; i++)); do
  varlist=$(eval echo ${varlist} ${!i})
done

echo "Entire variable list is $varlist"

if [ "$POPDIAG" = "TRUE" ]
   then  # NCAR directories
       indir=$WORKDIR
       outdir=$WORKDIR
       echo "POPDIAG environment variable equals TRUE. Using NCAR directories."
   else  # WHOI directories
       indir="/caiapo/data0/${run}/ocn"
       outdir='/bonaire/data2/ivan/ccsm_output'/$run
       echo "Input/Output directories as in WHOI."
       echo "If at NCAR, declare POPDIAG environment variable to TRUE."
fi

yrstart=`printf "%04d" $yyyystart`
yrend=`printf "%04d" $yyyyend`

mod_year=$yrstart

if [ ! -d "$outdir" ]
then
   echo "creating $outdir"
   mkdir -p $outdir
fi

# vars to extract
coordlist='z_t,z_w,z_t_150m,ULAT,ULONG,TLAT,TLONG,dz,dzw,KMT,KMU,REGION_MASK,UAREA,TAREA,HU,HT,DXU,DYU,DXT,DYT,HTN,HTE,HUS,HUW,ANGLE,ANGLET'

cd $outdir 

for var in ${varlist}; do

   fileclim=${run}.${var}.clim.${yrstart}-${yrend}.nc 

   if [ "$POPDIAG" = "TRUE" ]
     then  # Create softlink
       filemavg=${run}.pop.h.${var}.mavg_${yrstart}-${yrend}.nc
       if [ ! -f "$fileclim" -a -f "$filemavg" ]; then 
         ln -s $filemavg $fileclim
       fi
   fi

   if [ ! -f "$fileclim" ]; then 

       echo "The climatology of $var is being calculated."

       for mm in {01..12}; do

#          Modified line to account for octal numbers
           if [ "$POPDIAG" = "TRUE" ]
            then
              month=`echo 0$mm | tail -c3`
            else
              month=`printf "%02d" $mm`
           fi

           filelist=$(eval printf '"$indir/$run.pop.h.%04d-${month}.nc "' {$yyyystart..$yyyyend})

           # compute climatology for each month
           ncra -O -h -C -v ${coordlist},${var} ${filelist} \
               $outdir/tmp_${var}.${month}.nc

       done

       # concatenate monthly averages into 12-month climatology
       filelist=$(/bin/ls $outdir/tmp_${var}.??.nc)
       ncrcat -O -h ${filelist} $outdir/${run}.${var}.clim.${yrstart}-${yrend}.nc
       /bin/rm -f ${filelist}

   fi

   filezonavg=za.${run}.${var}.clim.${yrstart}-${yrend}.nc

   if [ ! -f "$filezonavg" ]; then 

       echo "The zonal average of the climatology of $var is being calculated."

       $TOOLPATH/za -O -o $filezonavg $outdir/${run}.${var}.clim.${yrstart}-${yrend}.nc

       # add dz to zonal averages file
       ncks -A -h -v z_t,z_t_150m,z_w,dz,dzw \
           $outdir/${run}.${var}.clim.${yrstart}-${yrend}.nc \
           $outdir/za.${run}.${var}.clim.${yrstart}-${yrend}.nc
   fi

done

#------------------------------------------------------------------------------
# compute derived variables

for var in totChl phytoC photoC_tot NO3_excess phyto_mu; do

   fileclim=${run}.${var}.clim.${yrstart}-${yrend}.nc 
   filezonavg=za.${run}.${var}.clim.${yrstart}-${yrend}.nc

   if [ ! -f "$fileclim" -o ! -f "$filezonavg" ]; then 

       echo "The climatology of $var and its zonal average are being calculated."

       # compute climatology for each month

       #---------------------------------------------------------------
       if [ "$var" == "totChl" ]; then

       for mm in {01..12}; do

#          Modified line to account for octal numbers
           if [ "$POPDIAG" = "TRUE" ]
            then
              month=`echo 0$mm | tail -c3`
            else
              month=`printf "%02d" $mm`
           fi
           filelist=$(eval printf '"$indir/$run.pop.h.%04d-${month}.nc "' {$yyyystart..$yyyyend})

           # extract necessary variables
           ncra -O -h -C -v ${coordlist},spChl,diatChl,diazChl ${filelist} \
               $outdir/tmp.${month}.nc
           # compute totChl
           ncap -O -h \
               -s "totChl[time,z_t_150m,nlat,nlon]=spChl+diatChl+diazChl" \
               $outdir/tmp.${month}.nc $outdir/tmp.${month}.nc
           # add variables attributes
           ncatted -O -h \
               -a long_name,totChl,c,c,"Total Chlorophyll" \
               -a units,totChl,c,c,"mg Chl/m^3" \
               -a coordinates,totChl,c,c,"TLONG TLAT z_t_150m time" \
               $outdir/tmp.${month}.nc
           # extract totChl to separate file
           ncks -O -h -a -v ${coordlist},totChl $outdir/tmp.${month}.nc \
               $outdir/tmp_totChl.${month}.nc
           # compute zonal avgs for each month
           $TOOLPATH/za -O -o za_totChl.${month}.nc \
               tmp_totChl.${month}.nc
           /bin/rm -f $outdir/tmp.${month}.nc

       done

       #---------------------------------------------------------------
       elif [ "$var" == "phytoC" ]; then

       for mm in {01..12}; do

#          Modified line to account for octal numbers
           if [ "$POPDIAG" = "TRUE" ]
            then
              month=`echo 0$mm | tail -c3`
            else
              month=`printf "%02d" $mm`
           fi

           filelist=$(eval printf '"$indir/$run.pop.h.%04d-${month}.nc "' {$yyyystart..$yyyyend})

           # extract necessary variables
           ncra -O -h -C -v ${coordlist},spC,diatC,diazC ${filelist} \
               $outdir/tmp.${month}.nc
           # compute phytoC
           ncap -O -h \
               -s "phytoC[time,z_t_150m,nlat,nlon]=spC+diatC+diazC" \
               $outdir/tmp.${month}.nc $outdir/tmp.${month}.nc
           # add variables attributes
           ncatted -O -h \
               -a long_name,phytoC,c,c,"Total Phytoplankton Carbon" \
               -a units,phytoC,c,c,"mmol C/m^3" \
               -a coordinates,phytoC,c,c,"TLONG TLAT z_t_150m time" \
               $outdir/tmp.${month}.nc
           # extract phytoC to separate file
           ncks -O -h -a -v ${coordlist},phytoC $outdir/tmp.${month}.nc \
               $outdir/tmp_phytoC.${month}.nc
           # compute zonal avgs for each month
           $TOOLPATH/za -O -o za_phytoC.${month}.nc \
               tmp_phytoC.${month}.nc
           /bin/rm -f $outdir/tmp.${month}.nc

       done

       #---------------------------------------------------------------
       elif [ "$var" == "photoC_tot" ]; then

       for mm in {01..12}; do

#          Modified line to account for octal numbers
           if [ "$POPDIAG" = "TRUE" ]
            then
              month=`echo 0$mm | tail -c3`
            else
              month=`printf "%02d" $mm`
           fi

           filelist=$(eval printf '"$indir/$run.pop.h.%04d-${month}.nc "' {$yyyystart..$yyyyend})
    
           # extract necessary variables
           ncra -O -h -C -v ${coordlist},photoC_sp,photoC_diat ${filelist} \
               $outdir/tmp.${month}.nc
           # compute photoC_tot
           ncap -O -h \
               -s "photoC_tot[time,z_t_150m,nlat,nlon]=photoC_sp+photoC_diat" \
               $outdir/tmp.${month}.nc $outdir/tmp.${month}.nc
           # add variables attributes
           ncatted -O -h \
               -a long_name,photoC_tot,c,c,"Total C uptake by Phytoplankton" \
               -a units,photoC_tot,c,c,"mmol C/m^3/sec" \
               -a coordinates,photoC_tot,c,c,"TLONG TLAT z_t_150m time" \
               $outdir/tmp.${month}.nc
           # extract photoC_tot to separate file
           ncks -O -h -a -v ${coordlist},photoC_tot $outdir/tmp.${month}.nc \
               $outdir/tmp_photoC_tot.${month}.nc
           # compute zonal avgs for each month
           $TOOLPATH/za -O -o za_photoC_tot.${month}.nc \
               tmp_photoC_tot.${month}.nc
           /bin/rm -f $outdir/tmp.${month}.nc

       done

       #---------------------------------------------------------------
       elif [ "$var" == "NO3_excess" ]; then

       for mm in {01..12}; do

#          Modified line to account for octal numbers
           if [ "$POPDIAG" = "TRUE" ]
            then
              month=`echo 0$mm | tail -c3`
            else
              month=`printf "%02d" $mm`
           fi

           filelist=$(eval printf '"$indir/$run.pop.h.%04d-${month}.nc "' {$yyyystart..$yyyyend})

           # extract necessary variables
           ncra -O -h -C -v ${coordlist},NO3,PO4 ${filelist} \
               $outdir/tmp.${month}.nc
           # compute NO3_excess
           ncap -O -h \
               -s "NO3_excess[time,z_t,nlat,nlon]=NO3-(16.*PO4)" \
               $outdir/tmp.${month}.nc $outdir/tmp.${month}.nc
           # add variables attributes
           ncatted -O -h \
               -a long_name,NO3_excess,c,c,"Excess NO3" \
               -a units,NO3_excess,c,c,"mmol N/m^3" \
               -a coordinates,NO3_excess,c,c,"TLONG TLAT z_t time" \
               $outdir/tmp.${month}.nc
           # extract NO3_excess to separate file
           ncks -O -h -a -v ${coordlist},NO3_excess $outdir/tmp.${month}.nc \
               $outdir/tmp_NO3_excess.${month}.nc
           # compute zonal avgs for each month
           $TOOLPATH/za -O -o za_NO3_excess.${month}.nc \
               tmp_NO3_excess.${month}.nc
           /bin/rm -f $outdir/tmp.${month}.nc

       done

       #---------------------------------------------------------------
       elif [ "$var" == "phyto_mu" ]; then

       for mm in {01..12}; do

#          Modified line to account for octal numbers
           if [ "$POPDIAG" = "TRUE" ]
            then
              month=`echo 0$mm | tail -c3`
            else
              month=`printf "%02d" $mm`
           fi

           filelist=$(eval printf '"$indir/$run.pop.h.%04d-${month}.nc "' {$yyyystart..$yyyyend})

           # extract necessary variables
           ncra -O -h -C -v ${coordlist},spC,diatC,photoC_sp,photoC_diat ${filelist} \
               $outdir/tmp.${month}.nc
           # compute phyto_mu
           ncap -O -h \
               -s "phytoC[time,z_t_150m,nlat,nlon]=spC+diatC" \
               -s "photoC_tot[time,z_t_150m,nlat,nlon]=photoC_sp+photoC_diat" \
               -s "phyto_mu[time,z_t_150m,nlat,nlon]=photoC_tot/phytoC" \
               $outdir/tmp.${month}.nc $outdir/tmp.${month}.nc
           # add variables attributes
           ncatted -O -h \
               -a long_name,phyto_mu,c,c,"Total Phytoplankton Growth Rate" \
               -a units,phyto_mu,c,c,"1/sec" \
               -a coordinates,phyto_mu,c,c,"TLONG TLAT z_t_150m time" \
               $outdir/tmp.${month}.nc
           # extract phyto_mu to separate file
           ncks -O -h -a -v ${coordlist},phyto_mu $outdir/tmp.${month}.nc \
               $outdir/tmp_phyto_mu.${month}.nc
           # compute zonal avgs for each month
           $TOOLPATH/za -O -o za_phyto_mu.${month}.nc \
               tmp_phyto_mu.${month}.nc
           /bin/rm -f $outdir/tmp.${month}.nc

       done

       #---------------------------------------------------------------

       fi

       #---------------------------------------------------------------

   # concatenate monthly averages into 12-month climatology
   filelist=$(/bin/ls $outdir/tmp_${var}.??.nc)
   ncrcat -O -h ${filelist} $outdir/${run}.${var}.clim.${yrstart}-${yrend}.nc
   /bin/rm -f ${filelist}

   # concatenate zonal avgs into 12-month climatology
   filelist=$(/bin/ls $outdir/za_${var}.??.nc)
   ncrcat -O -h ${filelist} \
       $outdir/za.${run}.${var}.clim.${yrstart}-${yrend}.nc
   /bin/rm -f ${filelist}

   # add dz to zonal averages file
   ncks -A -h -v z_t,z_t_150m,z_w,dz,dzw \
       $outdir/${run}.${var}.clim.${yrstart}-${yrend}.nc \
       $outdir/za.${run}.${var}.clim.${yrstart}-${yrend}.nc

   fi 

done

cd -
echo ""

#------------------------------------------------------------------------
#234567890123456789012345678901234567890123456789012345678901234567890123
