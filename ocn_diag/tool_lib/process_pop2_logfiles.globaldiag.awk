#! /usr/bin/awk -f
#
# process_pop2_logfiles.globaldiag.awk -- 
#	Extracts global mean diagnostics information
#	from pop2 log files; outputs monthly and/or
#	annual time series files.
#
# Usage: process_pop2_logfiles.globaldiag.awk <pop2logfile(s)>
#
# Output files are:
#	"diagts_nino.asc"  , ascii table of monthly/annual Nino diagnostics 
#	"diagts_3d.asc"  , ascii table of monthly/annual 3-d (and some 2-d) field diagnostics 
#	"diagts_hflux.asc"  , ascii table of monthly/annual surface heat flux diagnostics 
#	"diagts_fwflux.asc"  , ascii table of monthly/annual surface freshwater flux diagnostics 
#	"diagts_cfc.asc"  , ascii table of monthly/annual CFC11 & CFC12 diagnostics 
#	"diagts_ecosys.asc"  , ascii table of monthly/annual ecosystem diagnostics 
#	"diagts_precfactor.asc"  , ascii table of annual precip factor
#	"diagts_info.asc"  , ascii table of log file info
#
BEGIN {
  logcnt = 0
  globdiagcnt = 0
  minmodelyear = 100000
  maxmodelyear = -100000
  beginGlobalTimeAvg = "false"
  ladjust_precip = "false"
}
/LOG_FILENAME/ {
   ++logcnt
   logfile[logcnt] = substr($3,index($3,"ocn.log"),21)
   logfilename = substr($3,index($3,"ocn.log"),21)
   logdate[logcnt] = substr($3,index($3,"ocn.log")+8,6)
   logtime[logcnt] = substr($3,index($3,"ocn.log")+15,6)
   firstdate = 1
}
/ Changed precipitation factor/ {
   ladjust_precip = "true"
   log_precip_factor = $5
   precip_factor = $5
}
/Global    diagnostics computed/ {
   globdiagfreq = $5
}
/CFL       diagnostics computed/ {
   cfldiagfreq = $5
}
/Transport diagnostics computed/ {
   transportdiagfreq = $5
}
/ocn date/ {
   #  Set model year for this log file (overwrite if later log
   #  files overwrite a given year)
   #  Set precip factor and log file name for given year
   if (firstdate == 1) { 
    logyear[logcnt] = int(substr($4,1,4))
    if (logyear[logcnt] < minmodelyear) minmodelyear = int(logyear[logcnt])
    if (logyear[logcnt] > maxmodelyear) maxmodelyear = int(logyear[logcnt])
    year = int(logyear[logcnt])
    modelyear[year] = year
    if (ladjust_precip ~ /true/ ) {
	prec_factor[year] = precip_factor
        goodlogfile[year] = logfilename
    }
    firstdate = 0
   }
}
/Global Time Averages:/ {
   # skip over the first instance of this string (avoid the one-time stream output)
   # soas to avoid a problem with parsing output from runs with high-frequency ocean coupling
   if (beginGlobalTimeAvg == "true") {
       globdiagtime = $4
       day = int(substr($4,4,2))
       if (day == 1) {
	   if (! (globdiagtime in globdiagdate)) {
	       ++globdiagcnt
	       globdiagmmddyyyy[globdiagcnt] = $4
	   }
	   globdiagdate[globdiagtime] = $4
	   globdiagmonth[globdiagtime] = int(substr($4,1,2))-1
	   if (globdiagmonth[globdiagtime]==0) globdiagmonth[globdiagtime]=12
	   globdiagday[globdiagtime] = int(substr($4,4,2))
	   globdiagyear[globdiagtime] = int(substr($4,7))
	   if (globdiagday[globdiagtime] == 1 && globdiagmonth[globdiagtime]== 12) {
	       --globdiagyear[globdiagtime]
	   }
       }
   }
   else
   beginGlobalTimeAvg = "true"
}
/ KAPPA_ISOP:/ {
   kappa_isop[globdiagtime] = $2
}
/ KAPPA_THIC:/ {
   kappa_thic[globdiagtime] = $2
}
/ HOR_DIFF:/ {
   hor_diff[globdiagtime] = $2
}
/ DIA_DEPTH:/ {
   dia_depth[globdiagtime] = $2
}
/ TLT:/ {
   tlt[globdiagtime] = $2
}
/ INT_DEPTH:/ {
   int_depth[globdiagtime] = $2
}
/ UISOP:/ {
   uisop[globdiagtime] = $2
}
/ VISOP:/ {
   visop[globdiagtime] = $2
}
/ WISOP:/ {
   wisop[globdiagtime] = $2
}
/ ADVT_ISOP:/ {
   advt_isop[globdiagtime] = $2
}
/ ADVS_ISOP:/ {
   advs_isop[globdiagtime] = $2
}
/ VNT_ISOP:/ {
   vnt_isop[globdiagtime] = $2
}
/ VNS_ISOP:/ {
   vns_isop[globdiagtime] = $2
}
/ HDIFT:/ {
   hdift[globdiagtime] = $2
}
/ HDIFS:/ {
   hdifs[globdiagtime] = $2
}
/ QSW_HBL:/ {
   qsw_hbl[globdiagtime] = $2
}
/ QSW_HTP:/ {
   qsw_htp[globdiagtime] = $2
}
/ KVMIX:/ {
   kvmix[globdiagtime] = $2
}
/ TPOWER:/ {
   tpower[globdiagtime] = $2
}
/ UVEL:/ {
   uvel[globdiagtime] = $2
}
/ VVEL:/ {
   vvel[globdiagtime] = $2
}
/ WVEL:/ {
   wvel[globdiagtime] = $2
}
/ TEMP:/ {
   temp[globdiagtime] = $2
}
/ dTEMP_POS_2D:/ {
   dtemp_pos_2d[globdiagtime] = $2
}
/ dTEMP_NEG_2D:/ {
   dtemp_neg_2d[globdiagtime] = $2
}
/ SALT:/ {
   salt[globdiagtime] = $2
}
/ RHO:/ {
   rho[globdiagtime] = $2
}
/ IAGE:/ {
   iage[globdiagtime] = $2
}
/ RESID_T:/ {
   resid_t[globdiagtime] = $2
}
/ RESID_S:/ {
   resid_s[globdiagtime] = $2
}
/ SU:/ {
   su[globdiagtime] = $2
}
/ SV:/ {
   sv[globdiagtime] = $2
}
/ UET:/ {
   uet[globdiagtime] = $2
}
/ VNT:/ {
   vnt[globdiagtime] = $2
}
/ WTT:/ {
   wtt[globdiagtime] = $2
}
/ UES:/ {
   ues[globdiagtime] = $2
}
/ VNS:/ {
   vns[globdiagtime] = $2
}
/ WTS:/ {
   wts[globdiagtime] = $2
}
/ ADVT:/ {
   advt[globdiagtime] = $2
}
/ ADVS:/ {
   advs[globdiagtime] = $2
}
/ PV:/ {
   pv[globdiagtime] = $2
}
/ PD:/ {
   pd[globdiagtime] = $2
}
/ Q:/ {
   q[globdiagtime] = $2
}
/ SSH:/ {
   if ($2 != "change") {
     ssh[globdiagtime] = sprintf("%16.14E",$2)
   }
}
/ SHF:/ {
   shf[globdiagtime] = sprintf("%14.7f",$2)
}
/ SHF_QSW:/ {
   shf_qsw[globdiagtime] = sprintf("%14.7f",$2)
}
/ SFWF:/ {
   sfwf[globdiagtime] = sprintf("%10.6E",$2)
}
/ TAUX:/ {
   taux[globdiagtime] = $2
}
/ TAUY:/ {
   tauy[globdiagtime] = $2
}
/ FW:/ {
   fw[globdiagtime] = $2
}
/ TFW_T:/ {
   tfw_t[globdiagtime] = $2
}
/ TFW_S:/ {
   tfw_s[globdiagtime] = $2
}
/ EVAP_F:/ {
   evap_f[globdiagtime] = sprintf("%10.6E",$2)
}
/ PREC_F:/ {
   prec_f[globdiagtime] = sprintf("%10.6E",$2)
}
/ SNOW_F:/ {
   snow_f[globdiagtime] = sprintf("%10.6E",$2)
}
/ MELT_F:/ {
   melt_f[globdiagtime] = sprintf("%10.6E",$2)
}
/ ROFF_F:/ {
   roff_f[globdiagtime] = sprintf("%10.6E",$2)
}
/ SALT_F:/ {
   salt_f[globdiagtime] = sprintf("%10.6E",$2)
}
/ SENH_F:/ {
   senh_f[globdiagtime] = sprintf("%14.7f",$2)
}
/ LWDN_F:/ {
   lwdn_f[globdiagtime] = sprintf("%14.7f",$2)
}
/ LWUP_F:/ {
   lwup_f[globdiagtime] = sprintf("%14.7f",$2)
}
/ QFLUX:/ {
   qflux[globdiagtime] = sprintf("%14.7f",$2)
}
/ MELTH_F:/ {
   melth_f[globdiagtime] = sprintf("%14.7f",$2)
}
/ HMXL:/ {
   hmxl[globdiagtime] = sprintf("%14.7f",$2)
}
/ XMXL:/ {
   xmxl[globdiagtime] = sprintf("%14.7f",$2)
}
/ TMXL:/ {
   tmxl[globdiagtime] = sprintf("%14.7f",$2)
}
/ HBLT:/ {
   hblt[globdiagtime] = sprintf("%14.7f",$2)
}
/ XBLT:/ {
   xblt[globdiagtime] = $2
}
/ TBLT:/ {
   tblt[globdiagtime] = $2
}
/ BSF:/ {
   bsf[globdiagtime] = $2
}
/ NINO_1_PLUS_2:/ {
   nino_1_plus_2[globdiagtime] = sprintf("%12.7f",$2)
}
/ NINO_3:/ {
   nino_3[globdiagtime] = sprintf("%12.7f",$2)
}
/ NINO_3_POINT_4:/ {
   nino_3_point_4[globdiagtime] = sprintf("%12.7f",$2)
}
/ NINO_4:/ {
   nino_4[globdiagtime] = sprintf("%12.7f",$2)
}
/ CFC11:/ {
   cfc11[globdiagtime] = sprintf("%10.6E",$2)
}
/ STF_CFC11:/ {
   stf_cfc11[globdiagtime] = sprintf("%10.6E",$2)
}
/ CFC12:/ {
   cfc12[globdiagtime] = sprintf("%10.6E",$2)
}
/ STF_CFC12:/ {
   stf_cfc12[globdiagtime] = sprintf("%10.6E",$2)
}
/ Fe:/ {
   fe[globdiagtime] = sprintf("%10.6E",$2)
}
/ diatChl:/ {
   diatchl[globdiagtime] = sprintf("%10.6E",$2)
}
/ spChl:/ {
   spchl[globdiagtime] = sprintf("%10.6E",$2)
}
/ diazChl:/ {
   diazchl[globdiagtime] = sprintf("%10.6E",$2)
}
/ NO3:/ {
   no3[globdiagtime] = sprintf("%14.7f",$2)
}
/ NOx_FLUX:/ {
   nox_flux[globdiagtime] = sprintf("%14.7f",$2)
}
/ NH4:/ {
   nh4[globdiagtime] = sprintf("%14.7f",$2)
}
/ NHy_FLUX:/ {
   nhy_flux[globdiagtime] = sprintf("%14.7f",$2)
}
/ DENITRIF:/ {
   denitrif[globdiagtime] = sprintf("%10.6E",$2)
}
/ diaz_Nfix:/ {
   nfix[globdiagtime] = sprintf("%10.6E",$2)
}
/ PO4:/ {
   po4[globdiagtime] = sprintf("%14.7f",$2)
}
/ SiO3:/ {
   sio3[globdiagtime] = sprintf("%14.7f",$2)
}
/ O2:/ {
   O2[globdiagtime] = sprintf("%14.7f",$2)
}
/ AOU:/ {
   AOU[globdiagtime] = sprintf("%14.7f",$2)
}
/ O2_ZMIN:/ {
   O2_ZMIN[globdiagtime] = sprintf("%14.7f",$2)
}
/ O2_ZMIN_DEPTH:/ {
   O2_ZMIN_DEPTH[globdiagtime] = sprintf("%14.6f",$2)
}
/ DIC_ALT_CO2:/ {
   DIC_ALT_CO2[globdiagtime] = sprintf("%14.7f",$2)
}
/ DIC:/ {
   DIC[globdiagtime] = sprintf("%14.7f",$2)
}
/ ALK:/ {
   ALK[globdiagtime] = sprintf("%14.7f",$2)
}
/ CO3:/ {
   CO3[globdiagtime] = sprintf("%14.7f",$2)
}
/ zsatcalc:/ {
   zsatcalc[globdiagtime] = sprintf("%14.6f",$2)
}
/ zsatarag:/ {
   zsatarag[globdiagtime] = sprintf("%14.6f",$2)
}
/ DOC:/ {
   DOC[globdiagtime] = sprintf("%14.7f",$2)
}
/ photoC_sp:/ {
   photoC_sp[globdiagtime] = sprintf("%10.6E",$2)
}
/ photoC_diat:/ {
   photoC_diat[globdiagtime] = sprintf("%10.6E",$2)
}
/ photoC_diaz:/ {
   photoC_diaz[globdiagtime] = sprintf("%10.6E",$2)
}
/ FG_ALT_CO2:/ {
   FG_ALT_CO2[globdiagtime] = sprintf("%10.6E",$2)
}
/ FG_CO2:/ {
   FG_CO2[globdiagtime] = sprintf("%10.6E",$2)
}
/ DpCO2:/ {
   DpCO2[globdiagtime] = sprintf("%14.7f",$2)
}
/ ATM_CO2:/ {
   ATM_CO2[globdiagtime] = sprintf("%14.7f",$2)
}


END {
     #  accounting of all log files,dates,times, & years
     #  (shows any redundancy if certain years were run over)
     printf("%21s%9s%9s%9s\n","log_file","log_date","log_time","ocn year") > "diagts_info.asc"
     for (x = 1; x <= logcnt; x++) {
       printf("%21s%9i%9i%9i\n",logfile[x],logdate[x],logtime[x],logyear[x]) >> "diagts_info.asc"
     }
     close("diagts_info.asc")


     #  Precipitation factor time series (yearly)
    if (ladjust_precip ~ /true/) {
	printf("%9s%10s%25s\n","Year","P Factor","Log File") > "diagts_precfactor.asc"
	for (x = minmodelyear; x <= maxmodelyear; x++) {
	    printf("%9i%10.3f%25s\n",x,prec_factor[x],goodlogfile[x]) >> "diagts_precfactor.asc"
	}
	close("diagts_precfactor.asc")
    }


     #  Nino region SST time series 
     printf("%10s%3s%3s%5s%12s%12s%12s%12s\n","Time Stamp","M","D","Y","Nino1+2",\
	"Nino3","Nino3.4","Nino4") > "diagts_nino.asc"
     for (x = 1; x <= globdiagcnt; x++) {
       y = globdiagmmddyyyy[x]
       printf("%10s%3i%3i%5i%12.7f%12.7f%12.7f%12.7f\n",globdiagdate[y],globdiagmonth[y], \
	globdiagday[y],globdiagyear[y],\
	nino_1_plus_2[y],nino_3[y],nino_3_point_4[y],nino_4[y]) >> "diagts_nino.asc"
     }
     close("diagts_nino.asc")


     #  Global mean 3d field time series 
     printf("%10s%3s%3s%5s%12s%12s%12s%15s%14s%14s%2s%13s\n","Time Stamp","M","D","Y","TEMP",\
        "SALT","RHO","IAGE","HBLT","HMXL","  ","SSH") > "diagts_3d.asc"
     for (x = 1; x <= globdiagcnt; x++) {
       y = globdiagmmddyyyy[x]
       printf("%10s%3i%3i%5i%12.8f%12.8f%12.8f%15.8f%14.7f%14.7f%2s%+.6E\n",globdiagdate[y],globdiagmonth[y], \
        globdiagday[y],globdiagyear[y],temp[y],salt[y],rho[y],iage[y],hblt[y],hmxl[y],"  ",ssh[y]) >> "diagts_3d.asc"
     }
     close("diagts_3d.asc")


     #  Global mean surface heat flux time series 
     printf("%10s%3s%3s%5s%14s%14s%14s%14s%14s%14s%2s%13s%14s\n","Time Stamp","M","D","Y","SHF",\
        "SHF_QSW","SENH_F","LWUP_F","LWDN_F","MELTH_F"," ","EVAP_F","QFLUX") > "diagts_hflux.asc"
     for (x = 1; x <= globdiagcnt; x++) {
       y = globdiagmmddyyyy[x]
       printf("%10s%3i%3i%5i%14.7f%14.7f%14.7f%14.7f%14.7f%14.7f%2s%+.6E%14.7f\n",globdiagdate[y],globdiagmonth[y], \
        globdiagday[y],globdiagyear[y],shf[y],shf_qsw[y],senh_f[y],lwup_f[y],lwdn_f[y],melth_f[y],"  ",evap_f[y],qflux[y]) \
	>> "diagts_hflux.asc"
     }
     close("diagts_hflux.asc")


     #  Global mean surface freshwater flux time series
     printf("%10s%3s%3s%5s%2s%13s%2s%13s%2s%13s%2s%13s%2s%13s%2s%13s%2s%13s%14s\n","Time Stamp","M","D","Y","  ","SFWF",\
        "  ","EVAP_F","  ","PREC_F","  ","SNOW_F","  ","MELT_F","  ","ROFF_F","  ","SALT_F","QFLUX") > "diagts_fwflux.asc"
     for (x = 1; x <= globdiagcnt; x++) {
       y = globdiagmmddyyyy[x]
       printf("%10s%3i%3i%5i%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E%14.7f\n",globdiagdate[y],globdiagmonth[y], \
        globdiagday[y],globdiagyear[y],"  ",sfwf[y],"  ",evap_f[y],"  ",prec_f[y],"  ",snow_f[y],"  ",melt_f[y],"  ",roff_f[y],"  ", \
	salt_f[y],qflux[y]) >> "diagts_fwflux.asc"
     }
     close("diagts_fwflux.asc")


     #  Global mean CFC11 & CFC12 time series 
     printf("%10s%3s%3s%5s%2s%13s%2s%13s%2s%13s%2s%13s\n","Time Stamp","M","D","Y","  ", \
	"CFC11","  ","STF_CFC11","  ","CFC12","  ","STF_CFC12") > "diagts_cfc.asc"
     for (x = 1; x <= globdiagcnt; x++) {
       y = globdiagmmddyyyy[x]
       printf("%10s%3i%3i%5i%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E\n",globdiagdate[y],globdiagmonth[y], \
        globdiagday[y],globdiagyear[y],"  ",cfc11[y],"  ",stf_cfc11[y],"  ",cfc12[y],"  ",stf_cfc12[y]) \
	>> "diagts_cfc.asc"
     }
     close("diagts_cfc.asc")

     #  Global mean Ecosystem time series
     printf("%10s%3s%3s%5s%15s%15s%15s%15s%14s%15s%15s%15s%14s%14s%14s%14s%14s%14s%14s%14s%14s%14s%14s%14s%14s%15s%15s%15s%15s%15s%15s%15s%14s%14s\n","Time Stamp","M","D","Y", \
        "diatChl","spChl","diazChl","Fe","NO3","NOx_FLUX","NH4","NHy_FLUX","PO4","SiO3","O2","AOU","O2_ZMIN","O2_ZMIN_DEPTH","DIC_ALT_CO2","DIC","ALK","CO3","zsatcalc","zsatarag","DOC","photoC_sp","photoC_diat","photoC_diaz","DENITRIF","diaz_Nfix","FG_ALT_CO2","FG_CO2","DpCO2","ATM_CO2") > "diagts_ecosys.asc"
     for (x = 1; x <= globdiagcnt; x++) {
       y = globdiagmmddyyyy[x]
       if (DIC_ALT_CO2[y] == 0.0) {
         DIC_ALT_CO2[y] = DIC[y]
       }
       if (FG_ALT_CO2[y] == 0.0) {
         FG_ALT_CO2[y] = FG_CO2[y]
       }
       printf("%10s%3i%3i%5i%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E%14.7f%2s%+.6E%2s%+.6E%2s%+.6E%14.7f%14.7f%14.7f%14.7f%14.7f%14.7f%14.6f%14.7f%14.7f%14.7f%14.6f%14.6f%14.7f%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E%2s%+.6E%14.7f%14.7f\n",\
        globdiagdate[y],globdiagmonth[y], globdiagday[y],globdiagyear[y],"  ",diatchl[y],"  ",spchl[y],"  ",diazchl[y],\
        "  ",fe[y],no3[y],"  ",nox_flux[y],"  ",nh4[y],"  ",nhy_flux[y],po4[y],sio3[y],O2[y],AOU[y],O2_ZMIN[y],O2_ZMIN_DEPTH[y],\
        DIC_ALT_CO2[y],DIC[y],ALK[y],CO3[y],zsatcalc[y],zsatarag[y],DOC[y],\
        "  ",photoC_sp[y],"  ",photoC_diat[y],"  ",photoC_diaz[y],"  ",denitrif[y],"  ",nfix[y],"  ",FG_ALT_CO2[y],"  ",FG_CO2[y],DpCO2[y],ATM_CO2[y]) \
        >> "diagts_ecosys.asc"
     }
     close("diagts_ecosys.asc")

}

