#! /usr/bin/awk -f
#
# process_cpl6_logfiles.awk -- 
#	prints global mean heat budget components for each 
#	model from cpl6 log files over a given time period.
#
# Usage: process_cpl6_logfiles.awk y0=year0 y1=year1 <cpl6logfile(s)>
#
# NB: This version for cpl logs which DO take into account the
#	heat flux associated with fluxes of water in ice(snow) phase.
#       This script corrects using the latent heat of fusion of ice 
#	= 0.3337 (10^6 J/kg).
#
BEGIN {
  matmnet = 0.
  matmSW = 0.
  matmLW = 0.
  matmFRZ = 0.
  matmMLT = 0.
  matmLAT = 0.
  matmSEN = 0.
  madjatmnet = 0.

  mocnnet = 0.
  mocnSW = 0.
  mocnLW = 0.
  mocnFRZ = 0.
  mocnMLT = 0.
  mocnLAT = 0.
  mocnSEN = 0.
  madjocnnet = 0.

  mnicenet = 0.
  mniceSW = 0.
  mniceLW = 0.
  mniceFRZ = 0.
  mniceMLT = 0.
  mniceLAT = 0.
  mniceSEN = 0.
  madjnicenet = 0.

  msicenet = 0.
  msiceSW = 0.
  msiceLW = 0.
  msiceFRZ = 0.
  msiceMLT = 0.
  msiceLAT = 0.
  msiceSEN = 0.
  madjsicenet = 0.

  mlndnet = 0.
  mlndSW = 0.
  mlndLW = 0.
  mlndFRZ = 0.
  mlndMLT = 0.
  mlndLAT = 0.
  mlndSEN = 0.
  madjlndnet = 0.

  yrcnt = 0

  print  "    YEAR       ATM       LND    ICE_NH    ICE_SH       OCN     NET heat(W/m^2)"
  print  "--------  --------  --------  --------  --------  --------"
}
/heat  tavg atm/ {
  if ($6 == 366) {
     atmnet = $16
     atmSW = $10
     atmLW = $11 + $12
     atmFRZ = $8
     atmMLT = $9
     atmLAT = $13 + $14
     atmSEN = $15
  }
}
/heat  tavg lnd/ {
  if ($6 == 366) {
     lndfrac = $7
     lndnet = $16
     lndSW = $10
     lndLW = $11 + $12
     lndFRZ = $8
     lndMLT = $9
     lndLAT = $13 + $14
     lndSEN = $15
  }
}
/heat  tavg ocn/ {
  if ($6 == 366) {
     ocnfrac = $7
     ocnnet = $16
     ocnSW = $10
     ocnLW = $11 + $12
     ocnFRZ = $8
     ocnMLT = $9
     ocnLAT = $13 + $14
     ocnSEN = $15
  }
}
/heat  tavg ice_nh/ {
  if ($6 == 366) {
     nicefrac = $7
     nicenet = $16
     niceSW = $10
     niceLW = $11 + $12
     niceFRZ = $8
     niceMLT = $9
     niceLAT = $13 + $14
     niceSEN = $15
  }
}
/heat  tavg ice_sh/ {
  if ($6 == 366) {
     sicefrac = $7
     sicenet = $16
     siceSW = $10
     siceLW = $11 + $12
     siceFRZ = $8
     siceMLT = $9
     siceLAT = $13 + $14
     siceSEN = $15
  }
}
/water tavg atm/ {
  if ($6 == 366) {
     ymd = $5 
     year = int(ymd/10000.)
     if (year >= y0 && year <= y1) {
       ++yrcnt
       matmnet = matmnet + atmnet
       matmSW = matmSW + atmSW
       matmLW = matmLW + atmLW
       matmFRZ = matmFRZ + atmFRZ
       matmMLT = matmMLT + atmMLT
       matmLAT = matmLAT + atmLAT
       matmSEN = matmSEN + atmSEN
     }
  }
}
/water tavg lnd/ {
  if ($6 == 366) {
     ymd = $5
     year = int(ymd/10000.)
     if (year >= y0 && year <= y1) {
       mlndnet = mlndnet + lndnet
       mlndSW = mlndSW + lndSW
       mlndLW = mlndLW + lndLW
       mlndFRZ = mlndFRZ + lndFRZ
       mlndMLT = mlndMLT + lndMLT
       mlndLAT = mlndLAT + lndLAT
       mlndSEN = mlndSEN + lndSEN
     }
  }
}
/water tavg ice_nh/ {
  if ($6 == 366) {
     ymd = $5
     year = int(ymd/10000.)
     if (year >= y0 && year <= y1) {
       mnicenet = mnicenet + nicenet
       mniceSW = mniceSW + niceSW
       mniceLW = mniceLW + niceLW
       mniceFRZ = mniceFRZ + niceFRZ
       mniceMLT = mniceMLT + niceMLT
       mniceLAT = mniceLAT + niceLAT
       mniceSEN = mniceSEN + niceSEN
     }
  }
}
/water tavg ice_sh/ {
  if ($6 == 366) {
     ymd = $5
     year = int(ymd/10000.)
     if (year >= y0 && year <= y1) {
       msicenet = msicenet + sicenet
       msiceSW = msiceSW + siceSW
       msiceLW = msiceLW + siceLW
       msiceFRZ = msiceFRZ + siceFRZ
       msiceMLT = msiceMLT + siceMLT
       msiceLAT = msiceLAT + siceLAT
       msiceSEN = msiceSEN + siceSEN
     }
  }
}
/water tavg ocn/ {
  if ($6 == 366) {
     ymd = $5
     year = int(ymd/10000.)
     if (year >= y0 && year <= y1) {
       mocnnet = mocnnet + ocnnet
       mocnSW = mocnSW + ocnSW
       mocnLW = mocnLW + ocnLW
       mocnFRZ = mocnFRZ + ocnFRZ
       mocnMLT = mocnMLT + ocnMLT
       mocnLAT = mocnLAT + ocnLAT
       mocnSEN = mocnSEN + ocnSEN
     }
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",ymd,atmnet,lndnet/lndfrac,nicenet/nicefrac,sicenet/sicefrac,ocnnet/ocnfrac)
  }
}
END {
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",-99,-99,-99,-99,-99,-99)
  matmnet = matmnet/yrcnt
  matmSW = matmSW/yrcnt
  matmLW = matmLW/yrcnt
  matmFRZ = matmFRZ/yrcnt
  matmMLT = matmMLT/yrcnt
  matmLAT = matmLAT/yrcnt
  matmSEN = matmSEN/yrcnt

  mlndnet = mlndnet/yrcnt
  mlndSW = mlndSW/yrcnt
  mlndLW = mlndLW/yrcnt
  mlndFRZ = mlndFRZ/yrcnt
  mlndMLT = mlndMLT/yrcnt
  mlndLAT = mlndLAT/yrcnt
  mlndSEN = mlndSEN/yrcnt

  mocnnet = mocnnet/yrcnt
  mocnSW = mocnSW/yrcnt
  mocnLW = mocnLW/yrcnt
  mocnFRZ = mocnFRZ/yrcnt
  mocnMLT = mocnMLT/yrcnt
  mocnLAT = mocnLAT/yrcnt
  mocnSEN = mocnSEN/yrcnt

  mnicenet = mnicenet/yrcnt
  mniceSW = mniceSW/yrcnt
  mniceLW = mniceLW/yrcnt
  mniceFRZ = mniceFRZ/yrcnt
  mniceMLT = mniceMLT/yrcnt
  mniceLAT = mniceLAT/yrcnt
  mniceSEN = mniceSEN/yrcnt

  msicenet = msicenet/yrcnt
  msiceSW = msiceSW/yrcnt
  msiceLW = msiceLW/yrcnt
  msiceFRZ = msiceFRZ/yrcnt
  msiceMLT = msiceMLT/yrcnt
  msiceLAT = msiceLAT/yrcnt
  msiceSEN = msiceSEN/yrcnt

  moilFRZ = mocnFRZ+mniceFRZ+msiceFRZ+mlndFRZ
  moilMLT = mocnMLT+mniceMLT+msiceMLT+mlndMLT
  moilSW = mocnSW+mniceSW+msiceSW+mlndSW
  moilLW = mocnLW+mniceLW+msiceLW+mlndLW
  moilLAT = mocnLAT+mniceLAT+msiceLAT+mlndLAT
  moilSEN = mocnSEN+mniceSEN+msiceSEN+mlndSEN
  moilNET = mocnnet+mnicenet+msicenet+mlndnet

  printf("\n")
  print "+++++++++++++++++++++++++++++"
  print "CPL6 Surface Energy Budget for Years: ", y0,y1
  print "  (+ ==> model gains heat, - ==> model loses heat)"
  print  "          freeze      melt        SW        LW       LAT       SEN       NET  (W/m^2)"
  print  "        --------  --------  --------  --------  --------  --------  -------- "
  printf("  ATM:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",matmFRZ,matmMLT,matmSW,matmLW,matmLAT,matmSEN,matmnet)
  printf("  OCN:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mocnFRZ,mocnMLT,mocnSW,mocnLW,mocnLAT,mocnSEN,mocnnet)
  printf("ICE_N:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mniceFRZ,mniceMLT,mniceSW,mniceLW,mniceLAT,mniceSEN,mnicenet)
  printf("ICE_S:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",msiceFRZ,msiceMLT,msiceSW,msiceLW,msiceLAT,msiceSEN,msicenet)
  printf("  LND:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mlndFRZ,mlndMLT,mlndSW,mlndLW,mlndLAT,mlndSEN,mlndnet)
  printf("\n")
  printf("O+I+L:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",moilFRZ,moilMLT,moilSW,moilLW,moilLAT,moilSEN,moilNET)
  printf("\n")
  printf("  OCN NET renormalized: %10.5f\n",mocnnet/ocnfrac)
  print "+++++++++++++++++++++++++++++"
}

