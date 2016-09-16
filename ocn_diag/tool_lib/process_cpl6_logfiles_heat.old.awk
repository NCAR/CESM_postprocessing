#! /usr/bin/awk -f
#
# process_cpl6_logfiles.awk -- 
#	prints global mean heat budget components for each 
#	model from cpl6 log files over a given time period.
#
# Usage: process_cpl6_logfiles.awk y0=year0 y1=year1 <cpl6logfile(s)>
#
# NB: This version for cpl logs which do NOT take into account the
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
     atmnet = $15
     atmSW = $10
     atmLW = $11 + $12
     atmFRZ = $8
     atmMLT = $9
     atmLAT = $13
     atmSEN = $14
  }
}
/heat  tavg lnd/ {
  if ($6 == 366) {
     lndfrac = $7
     lndnet = $15
     lndSW = $10
     lndLW = $11 + $12
     lndFRZ = $8
     lndMLT = $9
     lndLAT = $13
     lndSEN = $14
  }
}
/heat  tavg ocn/ {
  if ($6 == 366) {
     ocnfrac = $7
     ocnnet = $15
     ocnSW = $10
     ocnLW = $11 + $12
     ocnFRZ = $8
     ocnMLT = $9
     ocnLAT = $13
     ocnSEN = $14
  }
}
/heat  tavg ice_nh/ {
  if ($6 == 366) {
     nicefrac = $7
     nicenet = $15
     niceSW = $10
     niceLW = $11 + $12
     niceFRZ = $8
     niceMLT = $9
     niceLAT = $13
     niceSEN = $14
  }
}
/heat  tavg ice_sh/ {
  if ($6 == 366) {
     sicefrac = $7
     sicenet = $15
     siceSW = $10
     siceLW = $11 + $12
     siceFRZ = $8
     siceMLT = $9
     siceLAT = $13
     siceSEN = $14
  }
}
/water tavg atm/ {
  if ($6 == 366) {
     ymd = $5 
     atmsnow = $11
     year = int(ymd/10000.)
     adjatmnet = atmnet-(atmsnow*0.3337)
     if (year >= y0 && year <= y1) {
       ++yrcnt
       matmnet = matmnet + atmnet
       madjatmnet = madjatmnet + adjatmnet
       matmSW = matmSW + atmSW
       matmLW = matmLW + atmLW
       matmFRZ = matmFRZ + atmFRZ
       matmMLT = matmMLT + atmMLT
       matmLAT = matmLAT + atmLAT - (atmsnow*0.3337)
       matmSEN = matmSEN + atmSEN
     }
  }
}
/water tavg lnd/ {
  if ($6 == 366) {
     ymd = $5
     lndsnow = $11
     year = int(ymd/10000.)
     adjlndnet = lndnet-(lndsnow*0.3337)
     if (year >= y0 && year <= y1) {
       mlndnet = mlndnet + lndnet
       madjlndnet = madjlndnet + adjlndnet
       mlndSW = mlndSW + lndSW
       mlndLW = mlndLW + lndLW
       mlndFRZ = mlndFRZ + lndFRZ
       mlndMLT = mlndMLT + lndMLT
       mlndLAT = mlndLAT + lndLAT - (lndsnow*0.3337)
       mlndSEN = mlndSEN + lndSEN
     }
  }
}
/water tavg ice_nh/ {
  if ($6 == 366) {
     ymd = $5
     nicesnow = $11
     year = int(ymd/10000.)
     adjnicenet = nicenet-(nicesnow*0.3337)
     if (year >= y0 && year <= y1) {
       mnicenet = mnicenet + nicenet
       madjnicenet = madjnicenet + adjnicenet
       mniceSW = mniceSW + niceSW
       mniceLW = mniceLW + niceLW
       mniceFRZ = mniceFRZ + niceFRZ
       mniceMLT = mniceMLT + niceMLT
       mniceLAT = mniceLAT + niceLAT - (nicesnow*0.3337)
       mniceSEN = mniceSEN + niceSEN
     }
  }
}
/water tavg ice_sh/ {
  if ($6 == 366) {
     ymd = $5
     sicesnow = $11
     year = int(ymd/10000.)
     adjsicenet = sicenet-(sicesnow*0.3337)
     if (year >= y0 && year <= y1) {
       msicenet = msicenet + sicenet
       madjsicenet = madjsicenet + adjsicenet
       msiceSW = msiceSW + siceSW
       msiceLW = msiceLW + siceLW
       msiceFRZ = msiceFRZ + siceFRZ
       msiceMLT = msiceMLT + siceMLT
       msiceLAT = msiceLAT + siceLAT - (sicesnow*0.3337)
       msiceSEN = msiceSEN + siceSEN
     }
  }
}
/water tavg ocn/ {
  if ($6 == 366) {
     ymd = $5
     ocnsnow = $11
     year = int(ymd/10000.)
     adjocnnet = ocnnet-(ocnsnow*0.3337)
     if (year >= y0 && year <= y1) {
       mocnnet = mocnnet + ocnnet
       madjocnnet = madjocnnet + adjocnnet
       mocnSW = mocnSW + ocnSW
       mocnLW = mocnLW + ocnLW
       mocnFRZ = mocnFRZ + ocnFRZ
       mocnMLT = mocnMLT + ocnMLT
       mocnLAT = mocnLAT + ocnLAT - (ocnsnow*0.3337)
       mocnSEN = mocnSEN + ocnSEN
     }
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",ymd,adjatmnet,adjlndnet/lndfrac,adjnicenet/nicefrac,adjsicenet/sicefrac,adjocnnet/ocnfrac)
  }
}
END {
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",-99,-99,-99,-99,-99,-99)
  matmnet = matmnet/yrcnt
  madjatmnet = madjatmnet/yrcnt
  matmSW = matmSW/yrcnt
  matmLW = matmLW/yrcnt
  matmFRZ = matmFRZ/yrcnt
  matmMLT = matmMLT/yrcnt
  matmLAT = matmLAT/yrcnt
  matmSEN = matmSEN/yrcnt

  mlndnet = mlndnet/yrcnt
  madjlndnet = madjlndnet/yrcnt
  mlndSW = mlndSW/yrcnt
  mlndLW = mlndLW/yrcnt
  mlndFRZ = mlndFRZ/yrcnt
  mlndMLT = mlndMLT/yrcnt
  mlndLAT = mlndLAT/yrcnt
  mlndSEN = mlndSEN/yrcnt

  mocnnet = mocnnet/yrcnt
  madjocnnet = madjocnnet/yrcnt
  mocnSW = mocnSW/yrcnt
  mocnLW = mocnLW/yrcnt
  mocnFRZ = mocnFRZ/yrcnt
  mocnMLT = mocnMLT/yrcnt
  mocnLAT = mocnLAT/yrcnt
  mocnSEN = mocnSEN/yrcnt

  mnicenet = mnicenet/yrcnt
  madjnicenet = madjnicenet/yrcnt
  mniceSW = mniceSW/yrcnt
  mniceLW = mniceLW/yrcnt
  mniceFRZ = mniceFRZ/yrcnt
  mniceMLT = mniceMLT/yrcnt
  mniceLAT = mniceLAT/yrcnt
  mniceSEN = mniceSEN/yrcnt

  msicenet = msicenet/yrcnt
  madjsicenet = madjsicenet/yrcnt
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
  moilNET = madjocnnet+madjnicenet+madjsicenet+madjlndnet

  printf("\n")
  print "+++++++++++++++++++++++++++++"
  print "CPL6 Surface Energy Budget for Years: ", y0,y1
  print "  (+ ==> model gains heat, - ==> model loses heat)"
  print  "          freeze      melt        SW        LW       LAT       SEN       NET  (W/m^2)"
  print  "        --------  --------  --------  --------  --------  --------  -------- "
  printf("  ATM:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",matmFRZ,matmMLT,matmSW,matmLW,matmLAT,matmSEN,madjatmnet)
  printf("  OCN:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mocnFRZ,mocnMLT,mocnSW,mocnLW,mocnLAT,mocnSEN,madjocnnet)
  printf("ICE_N:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mniceFRZ,mniceMLT,mniceSW,mniceLW,mniceLAT,mniceSEN,madjnicenet)
  printf("ICE_S:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",msiceFRZ,msiceMLT,msiceSW,msiceLW,msiceLAT,msiceSEN,madjsicenet)
  printf("  LND:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mlndFRZ,mlndMLT,mlndSW,mlndLW,mlndLAT,mlndSEN,madjlndnet)
  printf("\n")
  printf("O+I+L:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",moilFRZ,moilMLT,moilSW,moilLW,moilLAT,moilSEN,moilNET)
  printf("\n")
  printf("  OCN NET renormalized: %10.5f\n",madjocnnet/ocnfrac)
  print "+++++++++++++++++++++++++++++"
}

