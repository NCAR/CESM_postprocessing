#! /usr/bin/awk -f
#
# Prints global mean heat budget components for each 
# model from cpl7 log files over a given time period.
#
# Usage: process_cpl7_logfiles_heat.awk y0=year0 y1=year1 <cpl6logfile(s)>
#
#     	Use this version for cpl logs which DO take into account the
#	heat flux associated with snow flux of water, BUT which DO NOT
#	take into account the heat flux associated with frozen runoff flux.
#       This script computes the heat flux associated with frozen runoff flux
#	using the latent heat of fusion of ice = 0.3337 (10^6 J/kg).
#
BEGIN {
  mlndfrac = 0.
  mnicefrac = 0.
  msicefrac = 0.
  mocnfrac = 0.

  matmnet = 0.
  matmSW = 0.
  matmLW = 0.
  matmFRZ = 0.
  matmMLT = 0.
  matmLAT = 0.
  matmSEN = 0.
  madjatmnet = 0.

  mocnnet = 0.
  mocnnetrenorm = 0.
  mocnSW = 0.
  mocnLW = 0.
  mocnFRZ = 0.
  mocnFRZROF = 0.
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
  mlndFRZROF = 0.
  mlndMLT = 0.
  mlndLAT = 0.
  mlndSEN = 0.
  madjlndnet = 0.

  yrcnt = 0

  print  "    YEAR       ATM       LND    ICE_NH    ICE_SH       OCN     NET heat(W/m^2)"
  print  "--------  --------  --------  --------  --------  --------"
}
/NET AREA BUDGET/ {
  period = $8
  ymd = $11
  year = int(ymd/10000.)
  if (period ~ /annual:/) {
   --year
  }
}
$2 ~ /NET/ {
  budget = $3
}
/hfreeze/ {
  if (period ~ /annual:/) {
     atmfrz = $2
     lndfrz = $3
     ocnfrz = $4
     nicefrz = $5
     sicefrz = $6
     sumfrz = $7
  }
}
/hmelt/ {
  if (period ~ /annual:/) {
     atmmlt = $2
     lndmlt = $3
     ocnmlt = $4
     nicemlt = $5
     sicemlt = $6
     summlt = $7
  }
}
/hnetsw/ {
  if (period ~ /annual:/) {
     atmsw = $2
     lndsw = $3
     ocnsw = $4
     nicesw = $5
     sicesw = $6
     sumsw = $7
  }
}
/hlwdn/ {
  if (period ~ /annual:/) {
     atmlwdn = $2
     lndlwdn = $3
     ocnlwdn = $4
     nicelwdn = $5
     sicelwdn = $6
     sumlwdn = $7
  }
}
/hlwup/ {
  if (period ~ /annual:/) {
     atmlwup = $2
     lndlwup = $3
     ocnlwup = $4
     nicelwup = $5
     sicelwup = $6
     sumlwup = $7
  }
}
/hlatvap/ {
  if (period ~ /annual:/) {
     atmlatvap = $2
     lndlatvap = $3
     ocnlatvap = $4
     nicelatvap = $5
     sicelatvap = $6
     sumlatvap = $7
  }
}
/hlatfus/ {
  if (period ~ /annual:/) {
     atmlatfus = $2
     lndlatfus = $3
     ocnlatfus = $4
     nicelatfus = $5
     sicelatfus = $6
     sumlatfus = $7
  }
}
/hsen/ {
  if (period ~ /annual:/) {
     atmsen = $2
     lndsen = $3
     ocnsen = $4
     nicesen = $5
     sicesen = $6
     sumsen = $7
  }
}
/hiroff/ {
  if (period ~ /annual:/) {
     lndfrzrof = $3
     ocnfrzrof = $4
     sumfrzrof = $7
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
  if (period ~ /annual:/ && budget ~ /HEAT/) {
     atmsum = $2
     lndsum = $3
     ocnsum = $4
     nicesum = $5
     sicesum = $6
     sumsum = $7
  }
}
#/wfrzrof/ {
#  if (period ~ /annual:/) {
#     lndfrzrof = $3
#     lndfrzrof = -lndfrzrof*0.3337
#     ocnfrzrof = $3
#     ocnfrzrof = ocnfrzrof*0.3337
#  }
#}
$1 ~ /*SUM*/ {
  if (period ~ /annual:/ && budget ~ /WATER/) {
     if (year >= y0 && year <= y1) {
       ++yrcnt

       mlndfrac = mlndfrac + lndfrac 
       mnicefrac = mnicefrac + nicefrac
       msicefrac = msicefrac + sicefrac
       mocnfrac = mocnfrac + ocnfrac

       matmnet = matmnet + atmsum
       matmSW = matmSW + atmsw
       matmLW = matmLW + atmlwup + atmlwdn
       matmFRZ = matmFRZ + atmfrz
       matmMLT = matmMLT + atmmlt
       matmLAT = matmLAT + atmlatfus + atmlatvap
       matmSEN = matmSEN + atmsen

       mocnnet = mocnnet + ocnsum
       mocnnetrenorm = mocnnetrenorm + ocnsum/(1.-lndfrac)
       mocnSW = mocnSW + ocnsw
       mocnLW = mocnLW + ocnlwup + ocnlwdn
       mocnFRZ = mocnFRZ + ocnfrz
       mocnFRZROF = mocnFRZROF + ocnfrzrof
       mocnMLT = mocnMLT + ocnmlt
       mocnLAT = mocnLAT + ocnlatfus + ocnlatvap
       mocnSEN = mocnSEN + ocnsen

       mlndnet = mlndnet + lndsum
       mlndSW = mlndSW + lndsw
       mlndLW = mlndLW + lndlwup + lndlwdn
       mlndFRZ = mlndFRZ + lndfrz
       mlndFRZROF = mlndFRZROF + lndfrzrof
       mlndMLT = mlndMLT + lndmlt
       mlndLAT = mlndLAT + lndlatfus + lndlatvap
       mlndSEN = mlndSEN + lndsen

       mnicenet = mnicenet + nicesum
       mniceSW = mniceSW + nicesw
       mniceLW = mniceLW + nicelwup + nicelwdn
       mniceFRZ = mniceFRZ + nicefrz
       mniceMLT = mniceMLT + nicemlt
       mniceLAT = mniceLAT + nicelatfus + nicelatvap
       mniceSEN = mniceSEN + nicesen

       msicenet = msicenet + sicesum
       msiceSW = msiceSW + sicesw
       msiceLW = msiceLW + sicelwup + sicelwdn
       msiceFRZ = msiceFRZ + sicefrz
       msiceMLT = msiceMLT + sicemlt
       msiceLAT = msiceLAT + sicelatfus + sicelatvap
       msiceSEN = msiceSEN + sicesen
     }
# printf("%8i%10.3f%10.3f\n",ymd,ocnsum,(ocnsw+ocnlwup+ocnlwdn+ocnfrz+ocnfrzrof+ocnmlt+ocnsen+ocnlatfus+ocnlatvap))
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",ymd,atmsum,lndsum/lndfrac,nicesum/nicefrac,sicesum/sicefrac,ocnsum/ocnfrac)
# printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",ymd,atmsum,lndsum,nicesum,sicesum,ocnsum,atmsum+(lndsum+nicesum+sicesum+ocnsum))
  }

}


END {
  printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f\n",-99,-99,-99,-99,-99,-99)
  mlndfrac = mlndfrac/yrcnt
  mnicefrac = mnicefrac/yrcnt
  msicefrac = msicefrac/yrcnt
  mocnfrac = mocnfrac/yrcnt

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
  mlndFRZROF = mlndFRZROF/yrcnt
  mlndMLT = mlndMLT/yrcnt
  mlndLAT = mlndLAT/yrcnt
  mlndSEN = mlndSEN/yrcnt

  mocnnet = mocnnet/yrcnt
  mocnnetrenorm = mocnnetrenorm/yrcnt
  mocnSW = mocnSW/yrcnt
  mocnLW = mocnLW/yrcnt
  mocnFRZ = mocnFRZ/yrcnt
  mocnFRZROF = mocnFRZROF/yrcnt
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
  print "CPL7 Surface Energy Budget for Years: ", y0,y1
  print "  (+ ==> model gains heat, - ==> model loses heat)"
  print  "          FREEZE      MELT    RUNOFF        SW        LW       LAT       SEN       NET  (W/m^2)"
  print  "        --------  --------  --------  --------  --------  --------  --------  -------- "
  printf("  ATM:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",matmFRZ,matmMLT,0.0,matmSW,matmLW,matmLAT,matmSEN,matmnet)
  printf("  OCN:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mocnFRZ,mocnMLT,mocnFRZROF,mocnSW,mocnLW,mocnLAT,mocnSEN,mocnnet)
  printf("ICE_N:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mniceFRZ,mniceMLT,0.0,mniceSW,mniceLW,mniceLAT,mniceSEN,mnicenet)
  printf("ICE_S:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",msiceFRZ,msiceMLT,0.0,msiceSW,msiceLW,msiceLAT,msiceSEN,msicenet)
  printf("  LND:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mlndFRZ,mlndMLT,mlndFRZROF,mlndSW,mlndLW,mlndLAT,mlndSEN,mlndnet)
  printf("\n")
  printf("O+I+L:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",moilFRZ,moilMLT,0.0,moilSW,moilLW,moilLAT,moilSEN,moilNET)
  printf("\n")
  printf("  OCN NET renormalized: %10.5f\n",mocnnetrenorm)
  printf("\n")
  printf("    Mean ATM frac: %10.5f\n",1.0)
  printf("    Mean OCN frac: %10.5f\n",mocnfrac)
  printf("  Mean ICE_N frac: %10.5f\n",mnicefrac)
  printf("  Mean ICE_S frac: %10.5f\n",msicefrac)
  printf("    Mean LND frac: %10.5f\n",mlndfrac)

  print "+++++++++++++++++++++++++++++"
}

