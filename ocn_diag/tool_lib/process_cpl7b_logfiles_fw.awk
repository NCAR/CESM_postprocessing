#! /usr/bin/awk -f
#
# process_cpl7b_logfiles.awk -- 
# Prints global mean heat budget components for each 
# model from cpl7b log files over a given time period.
#
# Usage: process_cpl7b_logfiles.awk y0=year0 y1=year1 <cpl7blogfile(s)>
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
  
  mrofnet = 0.
  mrofroff = 0.
  mroffrzroff = 0.
  mrofevap = 0.
  mroffrz = 0.
  mrofmlt = 0.
  mrofrain = 0.
  mrofsnow = 0.

  yrcnt = 0

  print  "  YEAR        ATM         LND       ICE_NH      ICE_SH       OCN          ROF     NET freshwater (10^-6 kg/s/m^2)"
  print  "--------    --------    --------    --------    --------    --------     -------  -----------------"
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
/wfreeze/ {
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
/wmelt/ {
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
/wrain/ {
  if (period ~ /annual:/) {
     atmrain = $2
     lndrain = $3
     rofrain = $4
     ocnrain = $5
     nicerain = $6
     sicerain = $7
     sumrain = $9
  }
}
/wsnow/ {
  if (period ~ /annual:/) {
     atmsnow = $2
     lndsnow = $3
     rofsnow = $4
     ocnsnow = $5
     nicesnow = $6
     sicesnow = $7
     sumsnow = $9
  }
}
/wevap/ {
  if (period ~ /annual:/) {
     atmevap = $2
     lndevap = $3
     rofevap = $4
     ocnevap = $5
     niceevap = $6
     siceevap = $7
     sumevap = $9
  }
}
/wrunoff/ {
  if (period ~ /annual:/) {
     atmroff = $2
     lndroff = $3
     rofroff = $4
     ocnroff = $5
     niceroff = $6
     siceroff = $7
     sumroff = $9
  }
}
/wfrzrof/ {
  if (period ~ /annual:/) {
     atmfrzroff = $2
     lndfrzroff = $3
     roffrzroff = $4
     ocnfrzroff = $5
     nicefrzroff = $6
     sicefrzroff = $7
     sumfrzroff = $9
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
  if (period ~ /annual:/ && budget ~ /WATER/) {
     atmsum = $2
     lndsum = $3
     rofsum = $4
     ocnsum = $5
     nicesum = $6
     sicesum = $7
     sumsum = $9
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
       
       mrofnet = mrofnet + rofsum
       mrofroff = mrofroff + rofroff
       mroffrzroff = mroffrzroff + roffrzroff
       mrofevap = mrofevap + rofevap
       mroffrz = mroffrz + roffrz
       mrofmlt = mrofmlt + rofmlt
       mrofrain = mrofrain + rofrain
       mrofsnow = mrofsnow + rofsnow

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
  matmroff = matmroff/yrcnt
  matmevap = matmevap/yrcnt
  matmfrz = matmfrz/yrcnt
  matmmlt = matmmlt/yrcnt
  matmrain = matmrain/yrcnt
  matmsnow = matmsnow/yrcnt

  mlndnet = mlndnet/yrcnt
  mlndroff = mlndroff/yrcnt
  mlndfrzroff = mlndfrzroff/yrcnt
  mlndevap = mlndevap/yrcnt
  mlndfrz = mlndfrz/yrcnt
  mlndmlt = mlndmlt/yrcnt
  mlndrain = mlndrain/yrcnt
  mlndsnow = mlndsnow/yrcnt
  
  mrofnet = mrofnet/yrcnt
  mrofroff = mrofroff/yrcnt
  mrofevap = mrofevap/yrcnt
  mroffrzroff = mroffrzroff/yrcnt
  mroffrz = mroffrz/yrcnt
  mrofmlt = mrofmlt/yrcnt
  mrofrain = mrofrain/yrcnt
  mrofsnow = mrofsnow/yrcnt

  mocnnet = mocnnet/yrcnt
  mocnnetrenorm = mocnnetrenorm/yrcnt
  mocnroff = mocnroff/yrcnt
  mocnfrzroff = mocnfrzroff/yrcnt
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
  
  moilfrz = mocnfrz+mnicefrz+msicefrz+mlndfrz+mroffrz
  moilmlt = mocnmlt+mnicemlt+msicemlt+mlndmlt+mrofmlt
  moilroff = mocnroff+mniceroff+msiceroff+mlndroff+mrofroff
  moifroff = mocnfrzroff+mnicefrzroff+msicefrzroff+mlndfrzroff+mroffrzroff
  moilevap = mocnevap+mniceevap+msiceevap+mlndevap+mrofevap
  moilrain = mocnrain+mnicerain+msicerain+mlndrain+mrofrain
  moilsnow = mocnsnow+mnicesnow+msicesnow+mlndsnow+mrofsnow
  moilnet = mocnnet+mnicenet+msicenet+mlndnet+mrofnet

  printf("\n")
  print "+++++++++++++++++++++++++++++"
  print "CPL7 Mean Surface Freshwater Budget for Years: ", y0,y1
  print "  (+ ==> model gains freshwater, - ==> model loses freshwater)"
  print  "            freeze        melt        rain        snow        evap        roff       frzroff         NET  (10^-6 kg/s/m^2)"
  print  "          --------    --------    --------    --------    --------    --------      --------    -------- "
  printf("    ATM:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",matmfrz,matmmlt,matmrain,matmsnow,matmevap,matmroff,matmfrzroff,matmnet)
  printf("    OCN:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",mocnfrz,mocnmlt,mocnrain,mocnsnow,mocnevap,mocnroff,mocnfrzroff,mocnnet)
  printf("  ICE_N:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",mnicefrz,mnicemlt,mnicerain,mnicesnow,mniceevap,mniceroff,mnicefrzroff,mnicenet)
  printf("  ICE_S:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",msicefrz,msicemlt,msicerain,msicesnow,msiceevap,msiceroff,msicefrzroff,msicenet)
  printf("    LND:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",mlndfrz,mlndmlt,mlndrain,mlndsnow,mlndevap,mlndroff,mlndfrzroff,mlndnet)
  printf("    ROF:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",mroffrz,mrofmlt,mrofrain,mrofsnow,mrofevap,mrofroff,mroffrzroff,mrofnet)

  printf("\n")
  printf("O+I+L+R:%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f%12.5f\n",moilfrz,moilmlt,moilrain,moilsnow,moilevap,moilroff,moifroff,moilnet)
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

