#! /usr/bin/awk -f
#
# process_pop2_logfiles.awk -- 
#	prints global mean heat budget components  
#	over a given time period as recorded in pop2 log files.
#
# Usage: process_pop2_logfiles.awk y0=year0 y1=year1 <cpl6logfile(s)>
#
# NB:   Lf = latent heat of fusion of ice (J/kg)
#       Lv = latent heat of vaporisation (J/kg)
#
BEGIN {
  mocnnet = 0.
  mocnSW = 0.
  mocnLW = 0.
  mocnFRZ = 0.
  mocnMLT = 0.
  mocnLAT = 0.
  mocnSEN = 0.
  Lv = 2.501e6 
  Lf = 3.337e5
  Earthrad =  6.37122e6
  PI = 3.14159265358979323846
  Eartharea = 4*PI*(Earthrad*Earthrad)

  tavgcnt = 0
  meancnt = 0
  mocnt = 0
  yrcnt = 0
}
/T-area,   U-area/ {
   OCNarea = $4
   OCNarea = OCNarea*1.e6
}
/tavg diagnostics every/ {
   tavg_freq = $4
   tavg_freq_opt = $5
}
/Global Time Averages:/ {
   ++tavgcnt
   mmddyyyy[tavgcnt] = $4
   mm[tavgcnt] = int(substr($4,1,2))-1
   if (mm[tavgcnt]==0) mm[tavgcnt]=12
   dd[tavgcnt] = int(substr($4,4,2))
   yyyy[tavgcnt] = int(substr($4,7))
#  print tavgcnt,mmddyyyy[tavgcnt]
   if (dd[tavgcnt] == 1 && mm[tavgcnt]== 12) {
     --yyyy[tavgcnt]  
   }
}
/SHF:/ {
   shf[tavgcnt] = $2
}
/SHF_QSW:/ {
   shf_qsw[tavgcnt] = $2
}
/SENH_F:/ {
   senh_f[tavgcnt] = $2
}
/LWDN_F:/ {
   lwdn_f[tavgcnt] = $2
}
/LWUP_F:/ {
   lwup_f[tavgcnt] = $2
}
/EVAP_F:/ {
   evap_f[tavgcnt] = $2
}
/QFLUX:/ {
   qflux[tavgcnt] = $2
}
/MELTH_F:/ {
   melth_f[tavgcnt] = $2
}

END {
  print  "    YEAR       FRZ       MLT        SW        LW       SEN       LAT       NET (W/m^2)"
  print  "--------  --------  --------  --------  --------  --------  --------  --------"
for (x = 1; x <= tavgcnt; x++) {
  if (mm[x] == 1) {
    annfrz = 0.
    annmlt = 0.
    annsw = 0.
    annlw = 0.
    annsen = 0.
    annlat = 0.
    annnet = 0.
  }
  annnet = annnet+shf[x]+qflux[x]
  annfrz = annfrz+qflux[x]
  annmlt = annmlt+melth_f[x]
  annsw = annsw+shf_qsw[x]
  annlw = annlw+lwup_f[x]+lwdn_f[x]
  annsen = annsen+senh_f[x]
  annlat = annlat+Lv*evap_f[x]
  if (mm[x] == 12) {
    annnet = annnet/12.
    annfrz = annfrz/12.
    annmlt = annmlt/12.
    annsw = annsw/12.
    annlw = annlw/12.
    annsen = annsen/12.
    annlat = annlat/12.
    printf("%8i%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",yyyy[x],annfrz,annmlt,annsw,annlw,annsen,annlat,annnet)
  }
  if (yyyy[x] >= y0 && yyyy[x] <= y1) {
    ++meancnt
    mocnnet = mocnnet + shf[x]+qflux[x]
    mocnFRZ = mocnFRZ + qflux[x]
    mocnMLT = mocnMLT + melth_f[x]
    mocnSW = mocnSW + shf_qsw[x]
    mocnLW = mocnLW + lwup_f[x]+lwdn_f[x]
    mocnSEN = mocnSEN +senh_f[x]
    mocnLAT = mocnLAT + Lv*evap_f[x]
#   print "including in mean : ",mmddyyyy[x]
  }
}
  renorm = (OCNarea/Eartharea)
  mocnnet = mocnnet/meancnt
  mocnSW = mocnSW/meancnt
  mocnLW = mocnLW/meancnt
  mocnFRZ = mocnFRZ/meancnt
  mocnMLT = mocnMLT/meancnt
  mocnSEN = mocnSEN/meancnt
  mocnLAT = mocnLAT/meancnt
  m1 = mocnFRZ*renorm
  m2 = mocnMLT*renorm
  m3 = mocnSW*renorm
  m4 = mocnLW*renorm
  m5 = mocnLAT*renorm
  m6 = mocnSEN*renorm
  m7 = mocnnet*renorm
  printf("\n")
  print "+++++++++++++++++++++++++++++"
  print "OCN Energy Budget for Years: ", y0,y1
  print "  (+ for DOWNWARD flux, - for UPWARD flux)"
  print  "          freeze      melt        SW        LW       LAT       SEN       NET  (W/m^2)"
  print  "        --------  --------  --------  --------  --------  --------  -------- "
  printf("  OCN:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",mocnFRZ,mocnMLT,mocnSW,mocnLW,mocnLAT,mocnSEN,mocnnet)
  printf("\n")
  printf("renormalized using whole Earth area:\n")
  printf("  OCN:%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f\n",m1,m2,m3,m4,m5,m6,m7)
  print "+++++++++++++++++++++++++++++"
}

