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

#------------------------------------------------------------------------------
# compute derived variables

#for var in totChl phytoC photoC_tot NO3_excess phyto_mu; do
for var in NO3_excess; do

   fileclim=${run}.${var}.clim.${yrstart}-${yrend}.nc 
   filezonavg=za.${run}.${var}.clim.${yrstart}-${yrend}.nc

   if [ "$POPDIAG" = "TRUE" ]
     then  # Create softlink
       filemavg=${run}.pop.h.${var}.mavg_${yrstart}-${yrend}.nc
       if [ ! -f "$fileclim" -a -f "$filemavg" ]; then
         ln -s $filemavg $fileclim
       fi
   fi

   if [ ! -f "$fileclim" -o ! -f "$filezonavg" ]; then 

       echo "The climatology of $var and its zonal average are being calculated."

       # compute climatology for each month

       #---------------------------------------------------------------

       if [ "$var" == "totChl" ]; then

           subvar1="spChl"
           subvar2="diatChl"
           subvar3="diazChl"

           file1=$(eval printf '"$run.pop.h.$subvar1.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})
           file2=$(eval printf '"$run.pop.h.$subvar2.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})
           file3=$(eval printf '"$run.pop.h.$subvar3.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})

           echo $file1 $file2 $file3

           # extract necessary variables
           ncks -O -h -a -v ${coordlist},spChl ${file1} \
               $outdir/tmp.${var}.subvars.nc

           ncks -A -v ${coordlist},diatChl ${file2} \
               $outdir/tmp.${var}.subvars.nc

           ncks -A -v ${coordlist},diazChl ${file3} \
               $outdir/tmp.${var}.subvars.nc

           # compute totChl
           ncap -O -h \
               -s "totChl[time,z_t_150m,nlat,nlon]=spChl+diatChl+diazChl" \
               $outdir/tmp.${var}.subvars.nc $outdir/tmp.${var}.subvars.nc

           # add variables attributes
           ncatted -O -h \
               -a long_name,totChl,c,c,"Total Chlorophyll" \
               -a units,totChl,c,c,"mg Chl/m^3" \
               -a coordinates,totChl,c,c,"TLONG TLAT z_t_150m time" \
               $outdir/tmp.${var}.subvars.nc

           # extract totChl to separate file
           ncks -O -h -a -v ${coordlist},totChl $outdir/tmp.${var}.subvars.nc \
               $outdir/tmp_${var}.nc

           # compute zonal avgs
           $TOOLPATH/za -O -v $var -o za_${var}.nc tmp_${var}.nc

           /bin/rm -f $outdir/tmp.${var}.subvars.nc

       #---------------------------------------------------------------

       elif [ "$var" == "phytoC" ]; then

           subvar1="spC"
           subvar2="diatC"
           subvar3="diazC"

           file1=$(eval printf '"$run.pop.h.$subvar1.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})
           file2=$(eval printf '"$run.pop.h.$subvar2.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})
           file3=$(eval printf '"$run.pop.h.$subvar3.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})

           echo $file1 $file2 $file3

           # extract necessary variables
           ncks -O -h -a -v ${coordlist},spC ${file1} \
               $outdir/tmp.${var}.subvars.nc

           ncks -A -v ${coordlist},diatC ${file2} \
               $outdir/tmp.${var}.subvars.nc

           ncks -A -v ${coordlist},diazC ${file3} \
               $outdir/tmp.${var}.subvars.nc

           # compute phytoC
           ncap -O -h \
               -s "phytoC[time,z_t_150m,nlat,nlon]=spC+diatC+diazC" \
               $outdir/tmp.${var}.subvars.nc $outdir/tmp.${var}.subvars.nc

           # add variables attributes
           ncatted -O -h \
               -a long_name,phytoC,c,c,"Total Phytoplankton Carbon" \
               -a units,phytoC,c,c,"mmol C/m^3" \
               -a coordinates,phytoC,c,c,"TLONG TLAT z_t_150m time" \
               $outdir/tmp.${var}.subvars.nc

           # extract phytoC to separate file
           ncks -O -h -a -v ${coordlist},phytoC $outdir/tmp.${var}.subvars.nc \
               $outdir/tmp_${var}.nc

           # compute zonal avgs
           $TOOLPATH/za -O -v $var -o za_${var}.nc tmp_${var}.nc

           /bin/rm -f $outdir/tmp.${var}.subvars.nc

       #---------------------------------------------------------------

       elif [ "$var" == "photoC_tot" ]; then

           subvar1="photoC_sp"
           subvar2="photoC_diat"

           file1=$(eval printf '"$run.pop.h.$subvar1.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})
           file2=$(eval printf '"$run.pop.h.$subvar2.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})

           echo $file1 $file2

           # extract necessary variables
           ncks -O -h -a -v ${coordlist},photoC_sp ${file1} \
               $outdir/tmp.${var}.subvars.nc

           ncks -A -v ${coordlist},photoC_diat ${file2} \
               $outdir/tmp.${var}.subvars.nc

           # compute photoC_tot
           ncap -O -h \
               -s "photoC_tot[time,z_t_150m,nlat,nlon]=photoC_sp+photoC_diat" \
               $outdir/tmp.${var}.subvars.nc $outdir/tmp.${var}.subvars.nc

           # add variables attributes
           ncatted -O -h \
               -a long_name,photoC_tot,c,c,"Total C uptake by Phytoplankton" \
               -a units,photoC_tot,c,c,"mmol C/m^3/sec" \
               -a coordinates,photoC_tot,c,c,"TLONG TLAT z_t_150m time" \
               $outdir/tmp.${var}.subvars.nc

           # extract photoC_tot to separate file
           ncks -O -h -a -v ${coordlist},photoC_tot $outdir/tmp.${var}.subvars.nc \
               $outdir/tmp_${var}.nc

           # compute zonal avgs
           $TOOLPATH/za -O -v $var -o za_${var}.nc tmp_${var}.nc

           /bin/rm -f $outdir/tmp.${var}.subvars.nc

       #---------------------------------------------------------------

       elif [ "$var" == "NO3_excess" ]; then

           subvar1="NO3"
           subvar2="PO4"

           file1=$(eval printf '"$run.pop.h.$subvar1.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})
           file2=$(eval printf '"$run.pop.h.$subvar2.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})

           echo $file1 $file2

           # extract necessary variables
           ncks -O -h -a -v ${coordlist},NO3 ${file1} \
               $outdir/tmp.${var}.subvars.nc

           ncks -A -v ${coordlist},PO4 ${file2} \
               $outdir/tmp.${var}.subvars.nc

           # compute NO3_excess
           ncap -O -h \
               -s "NO3_excess[time,z_t,nlat,nlon]=NO3-(16.*PO4)" \
               $outdir/tmp.${var}.subvars.nc $outdir/tmp.${var}.subvars.nc

           # add variables attributes
           ncatted -O -h \
               -a long_name,NO3_excess,c,c,"Excess NO3" \
               -a units,NO3_excess,c,c,"mmol N/m^3" \
               -a coordinates,NO3_excess,c,c,"TLONG TLAT z_t time" \
               $outdir/tmp.${var}.subvars.nc

           # extract NO3_excess to separate file
           ncks -O -h -a -v ${coordlist},NO3_excess $outdir/tmp.${var}.subvars.nc \
               $outdir/tmp_${var}.nc

           # compute zonal avgs
           $TOOLPATH/za -O -v $var -o za_${var}.nc tmp_${var}.nc

           /bin/rm -f $outdir/tmp.${var}.subvars.nc

       #---------------------------------------------------------------

       elif [ "$var" == "phyto_mu" ]; then

           subvar1="spC"
           subvar2="diatC"
           subvar3="photoC_sp"
           subvar4="photoC_diat"

           file1=$(eval printf '"$run.pop.h.$subvar1.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})
           file2=$(eval printf '"$run.pop.h.$subvar2.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})
           file3=$(eval printf '"$run.pop.h.$subvar3.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})
           file4=$(eval printf '"$run.pop.h.$subvar4.mavg_%04d-%04d.nc "' {$yyyystart,$yyyyend})

           echo $file1 $file2 $file3 $file4

           # extract necessary variables
           ncks -O -h -a -v ${coordlist},spC ${file1} \
               $outdir/tmp.${var}.subvars.nc

           ncks -A -v ${coordlist},diatC ${file2} \
               $outdir/tmp.${var}.subvars.nc

           ncks -A -v ${coordlist},photoC_sp ${file3} \
               $outdir/tmp.${var}.subvars.nc

           ncks -A -v ${coordlist},photoC_diat ${file4} \
               $outdir/tmp.${var}.subvars.nc

           # compute phyto_mu
           ncap -O -h \
               -s "phytoC[time,z_t_150m,nlat,nlon]=spC+diatC" \
               -s "photoC_tot[time,z_t_150m,nlat,nlon]=photoC_sp+photoC_diat" \
               -s "phyto_mu[time,z_t_150m,nlat,nlon]=photoC_tot/phytoC" \
               $outdir/tmp.${var}.subvars.nc $outdir/tmp.${var}.subvars.nc

           # add variables attributes
           ncatted -O -h \
               -a long_name,phyto_mu,c,c,"Total Phytoplankton Growth Rate" \
               -a units,phyto_mu,c,c,"1/sec" \
               -a coordinates,phyto_mu,c,c,"TLONG TLAT z_t_150m time" \
               $outdir/tmp.${var}.subvars.nc

           # extract photoC_tot to separate file
           ncks -O -h -a -v ${coordlist},phyto_mu $outdir/tmp.${var}.subvars.nc \
               $outdir/tmp_${var}.nc

           # compute zonal avgs
           $TOOLPATH/za -O -v $var -o za_${var}.nc tmp_${var}.nc

           /bin/rm -f $outdir/tmp.${var}.subvars.nc

       fi

       #---------------------------------------------------------------

   # Modify names
   mv $outdir/tmp_${var}.nc $outdir/$fileclim
   mv $outdir/za_${var}.nc $outdir/$filezonavg

   # add dz to zonal averages file
   ncks -A -h -v z_t,z_t_150m,z_w,dz,dzw \
       $outdir/$fileclim \
       $outdir/$filezonavg

   fi 

done

cd -
echo ""

#------------------------------------------------------------------------
#234567890123456789012345678901234567890123456789012345678901234567890123
