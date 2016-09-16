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
#       This script corrects using the rainent heat of fusion of ice 
#	= 0.3337 (10^6 J/kg).
#
BEGIN {
  matmnet = 0.
  matmroff = 0.
  matmevap = 0.
  matmfrz = 0.
  matmmlt = 0.
  matmrain = 0.
  matmsnow = 0.

  mocnnet = 0.
  mocnroff = 0.
  mocnevap = 0.
  mocnfrz = 0.
  mocnmlt = 0.
  mocnrain = 0.
  mocnsnow = 0.

  mnicenet = 0.
  mniceroff = 0.
  mniceevap = 0.
  mnicefrz = 0.
  mnicemlt = 0.
  mnicerain = 0.
  mnicesnow = 0.

  msicenet = 0.
  msiceroff = 0.
  msiceevap = 0.
  msicefrz = 0.
  msicemlt = 0.
  msicerain = 0.
  msicesnow = 0.

  mlndnet = 0.
  mlndroff = 0.
  mlndevap = 0.
  mlndfrz = 0.
  mlndmlt = 0.
  mlndrain = 0.
  mlndsnow = 0.

  yrcnt = 0

  print  "    YEAR       ATM       LND    ICE_NH    ICE_SH       OCN     NET freshwater (10^-6 kg/s/m^2)"
  print  "--------  --------  --------  --------  --------  --------"
}
/water tavg atm/ {
  if ($6 == 366) {
     atmnet = $14
     atmroff = $13
     atmevap = $12
     atmfrz = $8
     atmmlt = $9
     atmrain = $10
     atmsnow = $11
     ymd = $5 
     year = int(ymd/10000.)
     if (year >= y0 && year <= y1) {
       ++yrcnt
       matmnet = matmnet + atmnet
       matmroff = matmroff + atmroff
       matmevap = matmevap + atmevap
       matmfrz = matmfrz + atmfrz
       matmmlt = matmmlt + atmmlt
       matmrain = matmrain + atmrain 
       matmsnow = matmsnow + atmsnow
     }
  }
}
/water tavg lnd/ {
  if ($6 == 366) {
     lndfrac = $7
     lndnet = $14
     lndroff = $13
     lndevap = $12
     lndfrz = $8
     lndmlt = $9
     lndrain = $10
     lndsnow = $11
     if (year >= y0 && year <= y1) {
       mlndnet = mlndnet + lndnet
       mlndroff = mlndroff + lndroff
       mlndevap = mlndevap + lndevap
       mlndfrz = mlndfrz + lndfrz
       mlndmlt = mlndmlt + lndmlt
       mlndrain = mlndrain + lndrain
       mlndsnow = mlndsnow + lndsnow
     }
  }
}
/water tavg ocn/ {
  if ($6 == 366) {
     ocnfrac = $7
     ocnnet = $14
     ocnroff = $13
     ocnevap = $12
     ocnfrz = $8
     ocnmlt = $9
     ocnrain = $10
     ocnsnow = $11
     if (year >= y0 && year <= y1) {
       mocnnet = mocnnet + ocnnet
       mocnroff = mocnroff + ocnroff
       mocnevap = mocnevap + ocnevap
       mocnfrz = mocnfrz + ocnfrz
       mocnmlt = mocnmlt + ocnmlt
       mocnrain = mocnrain + ocnrain
       mocnsnow = mocnsnow + ocnsnow
     }
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",ymd,atmnet,lndnet/lndfrac,nicenet/nicefrac,sicenet/sicefrac,ocnnet/ocnfrac)
# printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",ymd,atmnet,lndnet,nicenet,sicenet,ocnnet)
  }
}
/water tavg ice_nh/ {
  if ($6 == 366) {
     nicefrac = $7
     nicenet = $14
     niceroff = $13
     niceevap = $12
     nicefrz = $8
     nicemlt = $9
     nicerain = $10
     nicesnow = $11
     if (year >= y0 && year <= y1) {
       mnicenet = mnicenet + nicenet
       mniceroff = mniceroff + niceroff
       mniceevap = mniceevap + niceevap
       mnicefrz = mnicefrz + nicefrz
       mnicemlt = mnicemlt + nicemlt
       mnicerain = mnicerain + nicerain
       mnicesnow = mnicesnow + nicesnow
     }
  }
}
/water tavg ice_sh/ {
  if ($6 == 366) {
     sicefrac = $7
     sicenet = $14
     siceroff = $13
     siceevap = $12
     sicefrz = $8
     sicemlt = $9
     sicerain = $10
     sicesnow = $11
     if (year >= y0 && year <= y1) {
       msicenet = msicenet + sicenet
       msiceroff = msiceroff + siceroff
       msiceevap = msiceevap + siceevap
       msicefrz = msicefrz + sicefrz
       msicemlt = msicemlt + sicemlt
       msicerain = msicerain + sicerain
       msicesnow = msicesnow + sicesnow
     }
  }
}
END {
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",-99,-99,-99,-99,-99,-99)
  matmnet = matmnet/yrcnt
  matmroff = matmroff/yrcnt
  matmevap = matmevap/yrcnt
  matmfrz = matmfrz/yrcnt
  matmmlt = matmmlt/yrcnt
  matmrain = matmrain/yrcnt
  matmsnow = matmsnow/yrcnt

  mlndnet = mlndnet/yrcnt
  mlndroff = mlndroff/yrcnt
  mlndevap = mlndevap/yrcnt
  mlndfrz = mlndfrz/yrcnt
  mlndmlt = mlndmlt/yrcnt
  mlndrain = mlndrain/yrcnt
  mlndsnow = mlndsnow/yrcnt

  mocnnet = mocnnet/yrcnt
  mocnroff = mocnroff/yrcnt
  mocnevap = mocnevap/yrcnt
  mocnfrz = mocnfrz/yrcnt
  mocnmlt = mocnmlt/yrcnt
  mocnrain = mocnrain/yrcnt
  mocnsnow = mocnsnow/yrcnt

  mnicenet = mnicenet/yrcnt
  mniceroff = mniceroff/yrcnt
  mniceevap = mniceevap/yrcnt
  mnicefrz = mnicefrz/yrcnt
  mnicemlt = mnicemlt/yrcnt
  mnicerain = mnicerain/yrcnt
  mnicesnow = mnicesnow/yrcnt

  msicenet = msicenet/yrcnt
  msiceroff = msiceroff/yrcnt
  msiceevap = msiceevap/yrcnt
  msicefrz = msicefrz/yrcnt
  msicemlt = msicemlt/yrcnt
  msicerain = msicerain/yrcnt
  msicesnow = msicesnow/yrcnt

  moilfrz = mocnfrz+mnicefrz+msicefrz+mlndfrz
  moilmlt = mocnmlt+mnicemlt+msicemlt+mlndmlt
  moilroff = mocnroff+mniceroff+msiceroff+mlndroff
  moilevap = mocnevap+mniceevap+msiceevap+mlndevap
  moilrain = mocnrain+mnicerain+msicerain+mlndrain
  moilsnow = mocnsnow+mnicesnow+msicesnow+mlndsnow
  moilNET = mocnnet+mnicenet+msicenet+mlndnet

  printf("\n")
  print "+++++++++++++++++++++++++++++"
  print "CPL6 Mean Surface Freshwater Budget for Years: ", y0,y1
  print "  (+ ==> model gains freshwater, - ==> model loses freshwater)"
  print  "          freeze      melt      rain      snow      evap      roff       NET  (10^-6 kg/s/m^2)"
  print  "        --------  --------  --------  --------  --------  --------  -------- "
  printf("  ATM:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",matmfrz,matmmlt,matmrain,matmsnow,matmevap,matmroff,matmnet)
  printf("  OCN:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mocnfrz,mocnmlt,mocnrain,mocnsnow,mocnevap,mocnroff,mocnnet)
  printf("ICE_N:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mnicefrz,mnicemlt,mnicerain,mnicesnow,mniceevap,mniceroff,mnicenet)
  printf("ICE_S:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",msicefrz,msicemlt,msicerain,msicesnow,msiceevap,msiceroff,msicenet)
  printf("  LND:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mlndfrz,mlndmlt,mlndrain,mlndsnow,mlndevap,mlndroff,mlndnet)
  printf("\n")
  printf("O+I+L:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",moilfrz,moilmlt,moilrain,moilsnow,moilevap,moilroff,moilNET)
  printf("\n")
  printf("  OCN NET renormalized: %10.5f\n",mocnnet/ocnfrac)
  print "+++++++++++++++++++++++++++++"
}

