#! /usr/bin/awk -f
#
# Prints global mean heat budget components for each 
# model from cpl7b log files over a given time period.
#
# Usage: process_cpl7b_logfiles_heat.awk y0=year0 y1=year1 <cpl7logfile(s)>
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
  
  mrofnet = 0.
  mrofSW = 0.
  mrofLW = 0.
  mrofFRZ = 0.
  mrofFRZROF = 0.
  mrofMLT = 0.
  mrofLAT = 0.
  mrofSEN = 0.
  madjrofnet = 0.

  yrcnt = 0

  print  "    YEAR         ATM         LND      ICE_NH      ICE_SH         OCN         ROF    NET heat(W/m^2)"
  print  "--------    --------    --------    --------    --------    --------     -------    -------"
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
     roffrz = $4
     ocnfrz = $5
     nicefrz = $6
     sicefrz = $7
     sumfrz = $9
  }
}
/hmelt/ {
  if (period ~ /annual:/) {
     atmmlt = $2
     lndmlt = $3
     rofmlt = $4
     ocnmlt = $5
     nicemlt = $6
     sicemlt = $7
     summlt = $9
  }
}
/hnetsw/ {
  if (period ~ /annual:/) {
     atmsw = $2
     lndsw = $3
     rofsw = $4
     ocnsw = $5
     nicesw = $6
     sicesw = $7
     sumsw = $9
  }
}
/hlwdn/ {
  if (period ~ /annual:/) {
     atmlwdn = $2
     lndlwdn = $3
     roflwdn = $4
     ocnlwdn = $5
     nicelwdn = $6
     sicelwdn = $7
     sumlwdn = $9
  }
}
/hlwup/ {
  if (period ~ /annual:/) {
     atmlwup = $2
     lndlwup = $3
     roflwup = $4
     ocnlwup = $5
     nicelwup = $6
     sicelwup = $7
     sumlwup = $9
  }
}
/hlatvap/ {
  if (period ~ /annual:/) {
     atmlatvap = $2
     lndlatvap = $3
     roflatvap = $4
     ocnlatvap = $5
     nicelatvap = $6
     sicelatvap = $7
     sumlatvap = $9
  }
}
/hlatfus/ {
  if (period ~ /annual:/) {
     atmlatfus = $2
     lndlatfus = $3
     roflatfus = $4
     ocnlatfus = $5
     nicelatfus = $6
     sicelatfus = $7
     sumlatfus = $9
  }
}
/hiroff/ {
  if (period ~ /annual:/) {
     lndfrzrof = $3
     roffrzrof = $4
     ocnfrzrof = $5
     sumfrzrof = $9
  }
}
/hsen/ {
  if (period ~ /annual:/) {
     atmsen = $2
     lndsen = $3
     rofsen = $4
     ocnsen = $5
     nicesen = $6
     sicesen = $7
     sumsen = $9
  }
}
$1 ~ /area/ {
  if (period ~ /annual:/ && budget ~ /AREA/) {
    atmfrac = $2
# for G cases, lndfrac can be 0 so check first
    lndfrac = $3 
    if (lndfrac == 0) {
	lndfrac = -$7
    }
    ocnfrac = $4
    nicefrac = $5
    sicefrac = $6
  }
}
$1 ~ /*SUM*/ {
  if (period ~ /annual:/ && budget ~ /HEAT/) {
     atmsum = $2
     lndsum = $3
     rofsum = $4
     ocnsum = $5
     nicesum = $6
     sicesum = $7
     sumsum = $9
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
       
       mrofnet = mrofnet + rofsum
       mrofSW = mrofSW + rofsw
       mrofLW = mrofLW + roflwup + roflwdn
       mrofFRZ = mrofFRZ + roffrz
       mrofFRZROF = mrofFRZROF + roffrzrof
       mrofMLT = mrofMLT + rofmlt
       mrofLAT = mrofLAT + roflatfus + roflatvap
       mrofSEN = mrofSEN + rofsen

     }
#     printf("%8i%10.5f%10.5f\n",ymd,ocnsum,(ocnsw+ocnlwup+ocnlwdn+ocnfrz+ocnfrzrof+ocnmlt+ocnsen+ocnlatfus+ocnlatvap))
#     printf("%8i%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",ymd,atmsum,lndsum/lndfrac,nicesum/nicefrac,sicesum/sicefrac,ocnsum/ocnfrac,rofsum,)
     printf("%8i%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",ymd,atmsum,lndsum,nicesum,sicesum,ocnsum,rofsum,atmsum+lndsum+nicesum+sicesum+ocnsum+rofsum)
  }

}


END {
#    printf("%8i%12.5f\n",yrcnt,lndfrac+nicefrac+sicefrac+ocnfrac)
  printf("%8i%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",-99,-99,-99,-99,-99,-99,-99)
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
  
  mrofnet = mrofnet/yrcnt
  mrofSW = mrofSW/yrcnt
  mrofLW = mrofLW/yrcnt
  mrofFRZ = mrofFRZ/yrcnt
  mrofFRZROF = mrofFRZROF/yrcnt
  mrofMLT = mrofMLT/yrcnt
  mrofLAT = mrofLAT/yrcnt
  mrofSEN = mrofSEN/yrcnt
  
  moilFRZ = mocnFRZ+mniceFRZ+msiceFRZ+mlndFRZ+mrofFRZ
  moilMLT = mocnMLT+mniceMLT+msiceMLT+mlndMLT+mrofMLT
  moilSW = mocnSW+mniceSW+msiceSW+mlndSW+mrofSW
  moilLW = mocnLW+mniceLW+msiceLW+mlndLW+mrofLW
  moilLAT = mocnLAT+mniceLAT+msiceLAT+mlndLAT+mrofLAT
  moilSEN = mocnSEN+mniceSEN+msiceSEN+mlndSEN+mrofSEN
  moilNET = mocnnet+mnicenet+msicenet+mlndnet+mrofnet

  printf("\n")
  print "+++++++++++++++++++++++++++++"
  print "CPL7 Surface Energy Budget for Years: ", y0,y1
  print "  (+ ==> model gains heat, - ==> model loses heat)"
  print  "            FREEZE        MELT      RUNOFF          SW          LW         LAT         SEN         NET  (W/m^2)"
  print  "          --------    --------    --------    --------    --------    --------      --------    -------- "
  printf("    ATM:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",matmFRZ,matmMLT,0.0,matmSW,matmLW,matmLAT,matmSEN,matmnet)
  printf("    OCN:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",mocnFRZ,mocnMLT,mocnFRZROF,mocnSW,mocnLW,mocnLAT,mocnSEN,mocnnet)
  printf("  ICE_N:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",mniceFRZ,mniceMLT,0.0,mniceSW,mniceLW,mniceLAT,mniceSEN,mnicenet)
  printf("  ICE_S:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",msiceFRZ,msiceMLT,0.0,msiceSW,msiceLW,msiceLAT,msiceSEN,msicenet)
  printf("    LND:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",mlndFRZ,mlndMLT,mlndFRZROF,mlndSW,mlndLW,mlndLAT,mlndSEN,mlndnet)
  printf("    ROF:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",mrofFRZ,mrofMLT,mrofFRZROF,mrofSW,mrofLW,mrofLAT,mrofSEN,mrofnet)
  printf("\n")
  printf("O+I+L+R:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",moilFRZ,moilMLT,0.0,moilSW,moilLW,moilLAT,moilSEN,moilNET)
  printf("\n")
  printf("  OCN NET renormalized: %12.5f\n",mocnnetrenorm)
  printf("\n")
  printf("     Mean ATM frac: %12.5f\n",1.0)
  printf("Mean open OCN frac: %12.5f\n",mocnfrac)
  printf("     Mean OCN frac: %12.5f\n",1-mlndfrac)
  printf("   Mean ICE_N frac: %12.5f\n",mnicefrac)
  printf("   Mean ICE_S frac: %12.5f\n",msicefrac)
  printf("     Mean LND frac: %12.5f\n",mlndfrac)

  print "+++++++++++++++++++++++++++++"
}

