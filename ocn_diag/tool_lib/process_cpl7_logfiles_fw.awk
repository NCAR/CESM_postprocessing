#! /usr/bin/awk -f
#
# process_cpl7_logfiles.awk -- 
#	prints global mean heat budget components for each 
#	model from cpl7 log files over a given time period.
#
# Usage: process_cpl7_logfiles.awk y0=year0 y1=year1 <cpl7logfile(s)>
#
# NB: This version for cpl logs which DO take into account the
#	heat flux associated with fluxes of water in ice(snow) phase.
#       This script corrects using the rainent heat of fusion of ice 
#	= 0.3337 (10^6 J/kg).
#
BEGIN {
  mlndfrac = 0.
  mnicefrac = 0.
  msicefrac = 0.
  mocnfrac = 0.
  
  matmnet = 0.
  matmroff = 0.
  matmfrzroff = 0.
  matmevap = 0.
  matmfrz = 0.
  matmmlt = 0.
  matmrain = 0.
  matmsnow = 0.

  mocnnet = 0.
  mocnnetrenorm = 0.
  mocnroff = 0.
  mocnfrzroff = 0.
  mocnevap = 0.
  mocnfrz = 0.
  mocnmlt = 0.
  mocnrain = 0.
  mocnsnow = 0.

  mnicenet = 0.
  mniceroff = 0.
  mnicefrzroff = 0.
  mniceevap = 0.
  mnicefrz = 0.
  mnicemlt = 0.
  mnicerain = 0.
  mnicesnow = 0.

  msicenet = 0.
  msiceroff = 0.
  msicefrzroff = 0.
  msiceevap = 0.
  msicefrz = 0.
  msicemlt = 0.
  msicerain = 0.
  msicesnow = 0.

  mlndnet = 0.
  mlndroff = 0.
  mlndfrzroff = 0.
  mlndevap = 0.
  mlndfrz = 0.
  mlndmlt = 0.
  mlndrain = 0.
  mlndsnow = 0.

  yrcnt = 0

  print  "    YEAR       ATM       LND    ICE_NH    ICE_SH       OCN     NET freshwater (10^-6 kg/s/m^2)"
  print  "--------  --------  --------  --------  --------  --------"
}
/NET AREA BUDGET/ {
  period = $8
  ymd = $11
  year = int(ymd/10000.)
}
$2 ~ /NET/ {
  budget = $3
}
/wfreeze/ {
  if (period ~ /annual:/) {
     atmfrz = $2
     lndfrz = $3
     ocnfrz = $4
     nicefrz = $5
     sicefrz = $6
     sumfrz = $7
  }
}
/wmelt/ {
  if (period ~ /annual:/) {
     atmmlt = $2
     lndmlt = $3
     ocnmlt = $4
     nicemlt = $5
     sicemlt = $6
     summlt = $7
  }
}
/wrain/ {
  if (period ~ /annual:/) {
     atmrain = $2
     lndrain = $3
     ocnrain = $4
     nicerain = $5
     sicerain = $6
     sumrain = $7
  }
}
/wsnow/ {
  if (period ~ /annual:/) {
     atmsnow = $2
     lndsnow = $3
     ocnsnow = $4
     nicesnow = $5
     sicesnow = $6
     sumsnow = $7
  }
}
/wevap/ {
  if (period ~ /annual:/) {
     atmevap = $2
     lndevap = $3
     ocnevap = $4
     niceevap = $5
     siceevap = $6
     sumevap = $7
  }
}
/wrunoff/ {
  if (period ~ /annual:/) {
     atmroff = $2
     lndroff = $3
     ocnroff = $4
     niceroff = $5
     siceroff = $6
     sumroff = $7
  }
}
/wfrzrof/ {
  if (period ~ /annual:/) {
     atmfrzroff = $2
     lndfrzroff = $3
     ocnfrzroff = $4
     nicefrzroff = $5
     sicefrzroff = $6
     sumfrzroff = $7
  }
}
$1 ~ /area/ {
  if (period ~ /annual:/ && budget ~ /AREA/) {
    atmfrac = $2 
    lndfrac = $3 
    ocnfrac = $4 
    nicefrac = $5
    sicefrac = $6
  }
}
$1 ~ /*SUM*/ {
  if (period ~ /annual:/ && budget ~ /WATER/) {
     atmsum = $2
     lndsum = $3
     ocnsum = $4
     nicesum = $5
     sicesum = $6
     sumsum = $7
     if (year >= y0 && year <= y1) {
       ++yrcnt

       mlndfrac = mlndfrac + lndfrac 
       mnicefrac = mnicefrac + nicefrac
       msicefrac = msicefrac + sicefrac
       mocnfrac = mocnfrac + ocnfrac
       
       matmnet = matmnet + atmsum
       matmroff = matmroff + atmroff
       matmfrzroff = matmfrzroff + atmfrzroff
       matmevap = matmevap + atmevap
       matmfrz = matmfrz + atmfrz
       matmmlt = matmmlt + atmmlt
       matmrain = matmrain + atmrain
       matmsnow = matmsnow + atmsnow

       mlndnet = mlndnet + lndsum
       mlndroff = mlndroff + lndroff
       mlndfrzroff = mlndfrzroff + lndfrzroff
       mlndevap = mlndevap + lndevap
       mlndfrz = mlndfrz + lndfrz
       mlndmlt = mlndmlt + lndmlt
       mlndrain = mlndrain + lndrain
       mlndsnow = mlndsnow + lndsnow

       mocnnet = mocnnet + ocnsum
       mocnnetrenorm = mocnnetrenorm + ocnsum/(1.-lndfrac)
       mocnroff = mocnroff + ocnroff
       mocnfrzroff = mocnfrzroff + ocnfrzroff
       mocnevap = mocnevap + ocnevap
       mocnfrz = mocnfrz + ocnfrz
       mocnmlt = mocnmlt + ocnmlt
       mocnrain = mocnrain + ocnrain
       mocnsnow = mocnsnow + ocnsnow

       mnicenet = mnicenet + nicesum
       mniceroff = mniceroff + niceroff
       mnicefrzroff = mnicefrzroff + nicefrzroff
       mniceevap = mniceevap + niceevap
       mnicefrz = mnicefrz + nicefrz
       mnicemlt = mnicemlt + nicemlt
       mnicerain = mnicerain + nicerain
       mnicesnow = mnicesnow + nicesnow

       msicenet = msicenet + sicesum
       msiceroff = msiceroff + siceroff
       msicefrzroff = msicefrzroff + sicefrzroff
       msiceevap = msiceevap + siceevap
       msicefrz = msicefrz + sicefrz
       msicemlt = msicemlt + sicemlt
       msicerain = msicerain + sicerain
       msicesnow = msicesnow + sicesnow
     }
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",ymd,atmsum,lndsum/lndfrac,nicesum/nicefrac,sicesum/sicefrac,ocnsum/ocnfrac)
  }
}

END {
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",-99,-99,-99,-99,-99,-99)
  mlndfrac = mlndfrac/yrcnt
  mnicefrac = mnicefrac/yrcnt
  msicefrac = msicefrac/yrcnt
  mocnfrac = mocnfrac/yrcnt

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
  mocnnetrenorm = mocnnetrenorm/yrcnt
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
  print "CPL7 Mean Surface Freshwater Budget for Years: ", y0,y1
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
  printf("  OCN NET renormalized: %10.5f\n",mocnnetrenorm)
  print "+++++++++++++++++++++++++++++"
}

