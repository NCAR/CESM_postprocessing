;***************************************************************
; NCL script
; tables.ncl
; Mark Stevens, Sept 2001
;***************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
load "$DIAG_CODE/functions_tables.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
 re = 6.3712e6         ; radius of earth
 pi = 3.14159265

 wkdir      = getenv("WKDIR")
 compare    = getenv("COMPARE")
 season     = getenv("SEASON")  
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename
 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
 end if

 region = (/"GLBL","TROP","NEXT","SEXT"/)

 if (compare .eq. "OBS") then
   era40_vars  = (/"LHFLX_ERA40","PREH2O_ERA40"/)
   erai_vars  = (/"PREH2O_ERAI", "PSL_ERAI"/)   
   jra25_vars  = (/"TREFHT_JRA25","PSL_JRA25","SHFLX_JRA25","LHFLX_JRA25", \
                   "PRH2O_JRA25","U_200_JRA25","Z3_500_JRA25","STRESS_MAG_JRA25"/)
   ceres_vars  = (/"SOLIN_CERES","FSNTOA_CERES","FSNTOAC_CERES","FLUT_CERES","FLUTC_CERES", \
                  "LWCF_CERES","SWCF_CERES","RESTOA_CERES"/)
   ceres2_vars = (/"SOLIN_CERES-EBAF","FSNTOA_CERES-EBAF","FSNTOAC_CERES-EBAF","FLUT_CERES-EBAF","FLUTC_CERES-EBAF", \
                  "LWCF_CERES-EBAF","SWCF_CERES-EBAF","RESTOA_CERES-EBAF"/)              
   erbe_vars   = (/"FSNTOA_ERBE","FSNTOAC_ERBE","FLUT_ERBE","FLUTC_ERBE", \
                  "RESTOA_ERBE","LWCF_ERBE","SWCF_ERBE"/)
   ers_vars   = (/"STRESS_MAG_ERS"/)
   gpcp_vars  = (/"PRECT_GPCP"/)
   isccp_vars = (/"CLDTOT_ISCCP"/)
   cloudsat_vars = (/"CLDTOT_CLOUDSAT"/)
   hadisst_vars = (/"SST_HADISST"/)
   hadisst_pi_vars = (/"SST_HADISST_PI"/)
   hadisst_pd_vars = (/"SST_HADISST_PD"/)
   isccpFD_vars = (/"FLDS_ISCCP","FLNS_ISCCP","FSDS_ISCCP","FSNS_ISCCP"/)
   leg_vars   = (/"TREFHT_LEGATES"/)
   ncep_vars  = (/"TS_NCEP","TS_LAND_NCEP"/)
   merra_vars  = (/"PSL_MERRA","TS_MERRA", "U_200_MERRA","Z3_500_MERRA","STRESS_MAG_MERRA" /)
   nvap_vars  = (/"PREH2O_NVAP"/)
   airs_vars  = (/"PREH2O_AIRS"/)
   whoi_vars  = (/"LHFLX_WHOI"/)
   laryea_vars = (/"FSNS_LARYEA","SHFLX_LARYEA","STRESS_MAG_LARYEA"/)
   nobs_vars  =  (/"FLNT_CAM","FSNT_CAM","AODVIS","AODDUST"/)
   obsvars = (/"RESTOM","RESSURF", \
               "RESTOA_CERES-EBAF","RESTOA_ERBE","SOLIN_CERES-EBAF","SOLIN_CERES", \
               "CLDTOT_ISCCP","CLDTOT_CLOUDSAT", \
               "FLDS_ISCCP","FLNS_ISCCP", \
               "FLUT_CERES-EBAF","FLUT_CERES","FLUT_ERBE", \
               "FLUTC_CERES-EBAF","FLUTC_CERES","FLUTC_ERBE","FLNT_CAM", \
               "FSDS_ISCCP","FSNS_ISCCP","FSNS_LARYEA", \
               "FSNTOA_CERES-EBAF","FSNTOA_CERES","FSNTOA_ERBE", \
               "FSNTOAC_CERES-EBAF","FSNTOAC_CERES","FSNTOAC_ERBE","FSNT_CAM", \
               "LHFLX_JRA25","LHFLX_ERA40","LHFLX_WHOI", \
               "LWCF_CERES-EBAF", "LWCF_CERES","LWCF_ERBE", \
               "PRECT_GPCP", \
               "PREH2O_NVAP","PREH2O_AIRS", "PREH2O_JRA25","PREH2O_ERAI","PREH2O_ERA40", \
               "PSL_JRA25","PSL_ERAI", "PSL_MERRA", \
               "SHFLX_JRA25","SHFLX_LARYEA", \
               "STRESS_MAG_ERS", "STRESS_MAG_MERRA", "STRESS_MAG_LARYEA","STRESS_MAG_JRA25", \
               "SWCF_CERES-EBAF","SWCF_CERES", "SWCF_ERBE", \
               "AODVIS","AODDUST", \
               "SST_HADISST","SST_HADISST_PI","SST_HADISST_PD", \
               "TREFHT_LEGATES","TREFHT_JRA25","TS_MERRA","TS_NCEP","TS_LAND_NCEP", \
               "U_200_JRA25", "U_200_MERRA", \
               "Z3_500_JRA25","Z3_500_MERRA" /)
;  corresponding model variables
   vars = (/"RESTOM","RESSURF", \
            "RESTOA","RESTOA","SOLIN","SOLIN", \
            "CLDTOT","CLDTOT", \
            "FLDS","FLNS", \
            "FLUT","FLUT","FLUT", \
            "FLUTC","FLUTC","FLUTC","FLNT", \
            "FSDS","FSNS","FSNS", \
            "FSNTOA","FSNTOA","FSNTOA","FSNTOAC","FSNTOAC", \
            "FSNTOAC","FSNT", \
            "LHFLX","LHFLX","LHFLX", \
            "LWCF", "LWCF","LWCF", \
            "PRECT", \
            "PREH2O","PREH2O","PREH2O","PREH2O","PREH2O", \
            "PSL","PSL", "PSL", \
            "SHFLX","SHFLX",\
            "STRESS_MAG", "STRESS_MAG","STRESS_MAG","STRESS_MAG", \
            "SWCF","SWCF","SWCF", \
            "AODVIS","AODDUST", \
            "SST","SST","SST", \
            "TREFHT","TREFHT","TS","TS","TS_LAND", \
            "U_200","U_200", \
            "Z3_500","Z3_500"/)
 else
   vars = (/"RESTOM","RESSURF","SOLIN","AAM","CHI_200","CLDHGH","CLDLOW", \
           "CLDMED","CLDTOT","EKE_850","EP","FLNS","FLNSC","FLNT","FLNTC", \
           "FSDS","FSDSC","FSNS","FSNSC","FSNSC_ICE","FSNSC_LAND","FSNT", \
           "FSNTC","ICEAREA","LHFLX","LWCF","PRECT","PRECT_LAND", \
           "PRECT_OCEAN","PREH2O","PREH2O_OCEAN","PSI_200","PS","PSL","QFLX", \
           "SHFLX","SNOWHLND","SST","STRESS_MAG","SWCF","T_850","TGCLDLWP", \
           "TGCLDIWP","TICLDTWP","AODVIS","AODDUST","TREFHT","TS","TS_LAND","U_200","VT_850", \
           "Z3_500"/)
 end if

 nvars = dimsizes(vars)

 global  = new ((/nvars,4/),"float", -999)   ; global means,diff,rmse
 tropics = new ((/nvars,4/),"float", -999)   ; tropical 
 nextrop = new ((/nvars,4/),"float", -999)   ; northern extratropics 
 sextrop = new ((/nvars,4/),"float", -999)   ; southern extratropics 

 inptr1 = addfile(infile1,"r")       ; pointer to file1

 lat1 = inptr1->lat
 nlat1 = dimsizes(lat1) 
 lon1 = inptr1->lon
 nlon1 = dimsizes(lon1) 
 if (isfilevar(inptr1,"gw")) then
   gw1 = inptr1->gw 
 else
   if (isfilevar(inptr1,"wgt")) then
     gw1 = inptr1->wgt
   else 
     ;print("===== gw1 =====")
     gw1temp = latRegWgt(lat1,"double",0)  ; no gw in file
     gw1 = gw1temp
     delete(gw1temp)
     gw1!0 = "lat"
     gw1&lat = lat1
   end if
 end if

; Keep values for resetting after grid equalization computation for SST
 gw1_keep   = gw1
 lat1_keep  = lat1
 nlat1_keep = nlat1
 lon1_keep  = lon1
 nlon1_keep = nlon1

 if (ncdf_mode .eq. "write") then
   outptr1 = addfile(outfile1,"w")
 else
   outptr1 = addfile(outfile1,"c")
 end if
 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case         ; case names
 end if
 if (isatt(inptr1,"yrs_averaged")) then
   label1 = case1+" (yrs "+inptr1@yrs_averaged+")"
 else
   label1 = case1
 end if

 if (compare .eq. "OBS") then
   ptr_jra25  = addfile(infile2+"/JRA25_"+season+"_climo.nc","r")
   ptr_era40  = addfile(infile2+"/ERA40_"+season+"_climo.nc","r")
   ptr_erai  = addfile(infile2+"/ERAI_"+season+"_climo.nc","r")
   ptr_ceres  = addfile(infile2+"/CERES_"+season+"_climo.nc","r")
   ptr_ceres2 = addfile(infile2+"/CERES-EBAF_"+season+"_climo.nc","r")
   ptr_erbe  = addfile(infile2+"/ERBE_"+season+"_climo.nc","r")
   ptr_ers   = addfile(infile2+"/ERS_"+season+"_climo.nc","r")
   ptr_gpcp  = addfile(infile2+"/GPCP_"+season+"_climo.nc","r")
   ptr_hadisst  = addfile(infile2+"/HadISST_CL_"+season+"_climo.nc","r")
   ptr_hadisst_pi = addfile(infile2+"/HadISST_PI_"+season+"_climo.nc","r")
   ptr_hadisst_pd = addfile(infile2+"/HadISST_PD_"+season+"_climo.nc","r")
   ptr_isccp = addfile(infile2+"/ISCCP_"+season+"_climo.nc","r")
   ptr_isccpFD = addfile(infile2+"/ISCCPFD_"+season+"_climo.nc","r")
   ptr_leg   = addfile(infile2+"/LEGATES_"+season+"_climo.nc","r")
   ptr_ncep  = addfile(infile2+"/NCEP_"+season+"_climo.nc","r")
   ptr_merra  = addfile(infile2+"/MERRA_"+season+"_climo.nc","r")
   ptr_nvap  = addfile(infile2+"/NVAP_"+season+"_climo.nc","r")
   ptr_airs  = addfile(infile2+"/AIRS_"+season+"_climo.nc","r")
   ptr_whoi  = addfile(infile2+"/WHOI_"+season+"_climo.nc","r")
   ptr_laryea  = addfile(infile2+"/LARYEA_"+season+"_climo.nc","r")
   ptr_cloudsat = addfile(infile2+"/CLOUDSAT_"+season+"_climo.nc","r")
   ptr_t42   = addfile(infile2+"/T42_ORO_"+season+"_climo.nc","r")
   oro = ptr_t42->ORO   
   case2 = "OBS data"
   label2 = case2
 else
   inptr2 = addfile(infile2,"r")       ; pointer to infile2
   lat2 = inptr2->lat
   nlat2 = dimsizes(lat2) 
   lon2 = inptr2->lon
   nlon2 = dimsizes(lon2) 

   if (isfilevar(inptr2,"gw")) then
     gw2 = inptr2->gw 
   else
     if (isfilevar(inptr2,"wgt")) then
       gw2 = inptr2->wgt
     else 
       ;print("===== gw2 =====")
       gw2temp = latRegWgt(lat2,"double",0)  ; no gw in file
       gw2 = gw2temp
       gw2!0 = "lat"
       gw2&lat = lat2
       delete(gw2temp)
     end if
   end if

; Keep values for resetting after grid equalization computation for SST
   gw2_keep   = gw2
   lat2_keep  = lat2
   nlat2_keep = nlat2
   lon2_keep  = lon2
   nlon2_keep = nlon2
   if (ncdf_mode .eq. "write")
     outptr2 = addfile(outfile2,"w")
   else
     outptr2 = addfile(outfile2,"c")
   end if
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case
   end if
   if (isatt(inptr2,"yrs_averaged")) then
     label2 = case2+" (yrs "+inptr2@yrs_averaged+")"
   else
     label2 = case2
   end if
 end if


;****************************************************************
; For each variable in the list compute the means
; of the two fields and thenn the difference between
; the means.
  
do i = 0, nvars-1

; CASE 1 MODEL
  if (vars(i) .eq. "SOLIN") then
    A = get_SOLIN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AODVIS") then
    A = get_AODVIS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AODDUST") then
    A = get_AODDUST (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AAM") then
    A = get_AAM (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CHI_200") then
    A = get_CHI_200 (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDHGH") then
    A = get_CLDHGH (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDLOW") then
    A = get_CLDLOW (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDMED") then
    A = get_CLDMED (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDTOT") then
    A = get_CLDTOT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "EKE_850") then
    A = get_EKE_850 (inptr1,outptr1)
  end if
  if (vars(i) .eq. "EP") then
    A = get_EP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLDS") then
    A = get_FLDS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLNS") then
    A = get_FLNS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLNSC") then
    A = get_FLNSC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLNT") then
    A = get_FLNT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLNTC") then
    A = get_FLNTC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLUT") then
    A = get_FLUT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLUTC") then
    A = get_FLUTC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSDS") then
    A = get_FSDS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSDSC") then
    A = get_FSDSC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNS") then
    A = get_FSNS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNSC") then
    A = get_FSNSC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNSC_ICE") then
    A = get_FSNSC_ICE (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNSC_LAND") then
    A = get_FSNSC_LAND (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNT") then
    A = get_FSNT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNTC") then
    A = get_FSNTC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNTOA") then
    A = get_FSNTOA (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNTOAC") then
    A = get_FSNTOAC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "ICEAREA") then
    A = get_ICEFRAC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "LHFLX") then
    A = get_LHFLX (inptr1,outptr1)
  end if
  if (vars(i) .eq. "LWCF") then
    if (compare .eq. "OBS") then
      A = get_LWCFTOA (inptr1,outptr1)
    else
      A = get_LWCFTOM (inptr1,outptr1)
    end if
  end if
  if (vars(i) .eq. "PRECT") then
    A = get_PRECT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PRECT_LAND") then
    A = get_PRECT_LAND (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PRECT_OCEAN") then
    A = get_PRECT_OCEAN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PREH2O") then
    A = get_PREH2O (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PREH2O_OCEAN") then
    A = get_PREH2O_OCEAN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PSI_200") then
    A = get_PSI_200 (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PS") then
    A = get_PS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PSL") then
    A = get_PSL (inptr1,outptr1)
  end if
  if (vars(i) .eq. "QFLX") then
    A = get_QFLX (inptr1,outptr1)
  end if
  if (vars(i) .eq. "RESSURF") then
    A = get_RESSURF (inptr1,outptr1)
  end if
  if (vars(i) .eq. "RESTOA") then
    A = get_RESTOA (inptr1,outptr1)
  end if
  if (vars(i) .eq. "RESTOM") then
    A = get_RESTOM (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SHFLX") then
    A = get_SHFLX (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SNOWHLND") then
    A = get_SNOWHLND (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SST") then
    A = get_SST (inptr1,outptr1)
  end if
  if (vars(i) .eq. "STRESS_MAG") then
    A = get_STRESS_MAG (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SWCF") then
    if (compare .eq. "OBS") then
      A = get_SWCFTOA (inptr1,outptr1)
    else
      A = get_SWCFTOM (inptr1,outptr1)
    end if
  end if
  if (vars(i) .eq. "TGCLDIWP") then
    A = get_TGCLDIWP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TGCLDLWP") then
    A = get_TGCLDLWP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TICLDTWP") then
    A = get_TICLDTWP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "T_850") then
    A = get_T_850 (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TREFHT") then
    A = get_TREFHT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TS") then
    A = get_TS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TS_LAND") then
    A = get_TS_LAND (inptr1,outptr1)
  end if
  if (vars(i) .eq. "U_200") then
    A = get_U_200 (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VT_850") then
    A = get_VT_850 (inptr1,outptr1)
  end if
  if (vars(i) .eq. "Z3_500") then
    A = get_Z3_500 (inptr1,outptr1)
  end if

  if (all(A.eq.-999.)) then
    print (vars(i)+" not present in test case input file.")
    delete(A)
    continue       ; procede to next variable in do loop
  end if
  
  if (compare .eq. "OBS") then
    
    if (vars(i).eq."RESTOM" .or. vars(i).eq."RESSURF") then
      global(i,0) = wgt_areaave(A,gw1,1.0,0)  ; case1
      tropics(i,0) = wgt_areaave(A({-20:20},:),gw1({-20:20}),1.0,0)  
      nextrop(i,0) = wgt_areaave(A({20:90},:),gw1({20:90}),1.0,0)  
      sextrop(i,0) = wgt_areaave(A({-90:-20},:),gw1({-90:-20}),1.0,0)  
      continue
    else
      if (any(obsvars(i) .eq. erai_vars)) then
        inptr2 = ptr_erai
      end if
      if (any(obsvars(i) .eq. era40_vars)) then
        inptr2 = ptr_era40
      end if
      if (any(obsvars(i) .eq. jra25_vars)) then
        inptr2 = ptr_jra25
      end if
      if (any(obsvars(i) .eq. ceres_vars)) then
        inptr2 = ptr_ceres
      end if
      if (any(obsvars(i) .eq. ceres2_vars)) then
        inptr2 = ptr_ceres2
      end if
      if (any(obsvars(i) .eq. erbe_vars)) then
        inptr2 = ptr_erbe 
      end if
      if (any(obsvars(i) .eq. ers_vars)) then
        inptr2 = ptr_ers 
      end if
      if (any(obsvars(i) .eq. gpcp_vars)) then
        inptr2 = ptr_gpcp 
      end if
      if (any(obsvars(i) .eq. hadisst_vars)) then
        inptr2 = ptr_hadisst 
      end if
      if (any(obsvars(i) .eq. hadisst_pi_vars)) then
        inptr2 = ptr_hadisst_pi 
      end if
      if (any(obsvars(i) .eq. hadisst_pd_vars)) then
        inptr2 = ptr_hadisst_pd 
      end if
      if (any(obsvars(i) .eq. isccp_vars)) then
        inptr2 = ptr_isccp
      end if
      if (any(obsvars(i) .eq. isccpFD_vars)) then
        inptr2 = ptr_isccpFD
      end if
      if (any(obsvars(i) .eq. leg_vars)) then
        inptr2 = ptr_leg 
      end if
      if (any(obsvars(i) .eq. ncep_vars)) then
        inptr2 = ptr_ncep       
      end if
      if (any(obsvars(i) .eq. merra_vars)) then
        inptr2 = ptr_merra       
      end if
      if (any(obsvars(i) .eq. nvap_vars)) then
        inptr2 = ptr_nvap 
      end if
      if (any(obsvars(i) .eq. airs_vars)) then
        inptr2 = ptr_airs 
      end if
      if (any(obsvars(i) .eq. whoi_vars)) then
        inptr2 = ptr_whoi 
      end if
      if (any(obsvars(i) .eq. laryea_vars)) then
        inptr2 = ptr_laryea 
      end if
      if (any(obsvars(i) .eq. cloudsat_vars)) then
        inptr2 = ptr_cloudsat 
      end if

      if (vars(i).eq."T_850" .or. vars(i).eq."U_200" .or. \
          vars(i).eq."Z3_300" .or. vars(i).eq."Z3_500" .or. \
          vars(i).eq."TS_LAND") then
        if (vars(i).eq."T_850") then
          B = inptr2->T(0,{850},:,:)   
          B@long_name = "850mb temperature" 
          B@units = "K"
        end if
        if (vars(i).eq."TS_LAND") then
          ts = inptr2->TS(0,:,:)
          B = ts
          B = mask(ts,oro,1) 
          B@long_name = "Surface temp (land)"
          B@units = "K"
        end if
        if (vars(i).eq."U_200") then
          B = inptr2->U(0,{200},:,:)
          B@long_name = "200mb zonal wind"
          B@units = "m/s"
        end if
        if (vars(i).eq."Z3_300") then
          B = inptr2->Z3(0,{300},:,:)
          B = (/B/100./)
          B@long_name = "300mb geop height"
          B@units = "hectometers"
        end if
        if (vars(i).eq."Z3_500") then
          B = inptr2->Z3(0,{500},:,:)
          B = (/B/100./)
          B@long_name = "500mb geop height"
          B@units = "hectometers"
        end if
        
         
      else
; Skip to next variable if there is no observed variable.
        if (any(obsvars(i).eq.nobs_vars)) then 
          global(i,0) = wgt_areaave(A,gw1,1.0,0)  ; case1
          tropics(i,0) = wgt_areaave(A({-20:20},:),gw1({-20:20}),1.0,0)  
          nextrop(i,0) = wgt_areaave(A({20:90},:),gw1({20:90}),1.0,0)  
          sextrop(i,0) = wgt_areaave(A({-90:-20},:),gw1({-90:-20}),1.0,0)  
          continue
        else

          if (obsvars(i).eq."CLDTOT_CLOUDSAT"  .or. obsvars(i).eq."SST_HADISST" \
            .or. obsvars(i).eq."SST_HADISST_PI" .or. obsvars(i).eq."SST_HADISST_PD") then
            B = inptr2->$vars(i)$           
          else
            B = inptr2->$vars(i)$(0,:,:)        ; all other obsvars
          end if

        end if
      end if
    end if
    lat2 = inptr2->lat
    nlat2 = dimsizes(lat2)
    lon2 = inptr2->lon
    nlon2 = dimsizes(lon2) 
    if (isfilevar(inptr2,"gw")) then
      gw2 = inptr2->gw 
    else
      if (isfilevar(inptr2,"wgt")) then
        gw2 = inptr2->wgt
      else 
        gw2temp = latRegWgt(lat2,"float",0)  ; no gw in file
        gw2 = gw2temp
        delete(gw2temp)
      end if
    end if
    if (all(B.eq.-999.).and.(.not.any(obsvars(i).eq.nobs_vars))) then
      print (vars(i)+" not present in control case input file.")
      delete(A)
      delete(B)
      continue      ; procede to next variable in do loop 
    end if
  else    
;   CASE 2 IS MODEL

    if (vars(i) .eq. "SOLIN") then
      B = get_SOLIN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AODVIS") then
      B = get_AODVIS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AODDUST") then
      B = get_AODDUST (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AAM") then
      B = get_AAM (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CHI_200") then
      B = get_CHI_200 (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDHGH") then
      B = get_CLDHGH (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDLOW") then
      B = get_CLDLOW (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDMED") then
      B = get_CLDMED (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDTOT") then
      B = get_CLDTOT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "EKE_850") then
      B = get_EKE_850 (inptr2,outptr2)
    end if
    if (vars(i) .eq. "EP") then
      B = get_EP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLNS") then
      B = get_FLNS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLNSC") then
      B = get_FLNSC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLNT") then
      B = get_FLNT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLNTC") then
      B = get_FLNTC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLUT") then
      B = get_FLUT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLUTC") then
      B = get_FLUTC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSDS") then
      B = get_FSDS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSDSC") then
      B = get_FSDSC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNS") then
      B = get_FSNS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNSC") then
      B = get_FSNSC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNSC_ICE") then
      B = get_FSNSC_ICE (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNSC_LAND") then
      B = get_FSNSC_LAND (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNT") then
      B = get_FSNT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNTC") then
      B = get_FSNTC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNTOA") then
      B = get_FSNTOA (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNTOAC") then
      B = get_FSNTOAC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "ICEAREA") then
      B = get_ICEFRAC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "LHFLX") then
      B = get_LHFLX (inptr2,outptr2)
    end if
    if (vars(i) .eq. "LWCF") then
      B = get_LWCFTOM (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PRECT") then
      B = get_PRECT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PRECT_LAND") then
      B = get_PRECT_LAND (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PRECT_OCEAN") then
      B = get_PRECT_OCEAN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PREH2O") then
      B = get_PREH2O (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PREH2O_OCEAN") then
      B = get_PREH2O_OCEAN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PSI_200") then
      B = get_PSI_200 (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PS") then
      B = get_PS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PSL") then
      B = get_PSL (inptr2,outptr2)
    end if
    if (vars(i) .eq. "QFLX") then
      B = get_QFLX (inptr2,outptr2)
    end if
    if (vars(i) .eq. "RESSURF") then
      B = get_RESSURF (inptr2,outptr2)
    end if
    if (vars(i) .eq. "RESTOA") then
      B = get_RESTOA (inptr2,outptr2)
    end if
    if (vars(i) .eq. "RESTOM") then
      B = get_RESTOM (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SHFLX") then
      B = get_SHFLX (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SNOWHLND") then
      B = get_SNOWHLND (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SST") then
      B = get_SST (inptr2,outptr2)
    end if
    if (vars(i) .eq. "STRESS_MAG") then
      B = get_STRESS_MAG (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SWCF") then
      B = get_SWCFTOM (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TGCLDIWP") then
      B = get_TGCLDIWP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TGCLDLWP") then
      B = get_TGCLDLWP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TICLDTWP") then
      B = get_TICLDTWP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "T_850") then
      B = get_T_850 (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TREFHT") then
      B = get_TREFHT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TS") then
      B = get_TS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TS_LAND") then
      B = get_TS_LAND (inptr2,outptr2)
    end if
    if (vars(i) .eq. "U_200") then
      B = get_U_200 (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VT_850") then
      B = get_VT_850 (inptr2,outptr2)
    end if
    if (vars(i) .eq. "Z3_500") then
      B = get_Z3_500 (inptr2,outptr2)
    end if

    if (all(B.eq.-999.)) then
      print (vars(i)+" not present in control case input file.")
      delete(A)
      delete(B)
      continue      ; procede to next variable in do loop 
    end if
  end if

 
;  if (all(B.eq.-999.).and.(.not.any(obsvars(i).eq.nobs_vars))) then
;    print (vars(i)+" not present in control case input file.")
;    delete(A)
;    delete(B)
;    continue      ; procede to next variable in do loop 
;  end if

;--------------------------------------------------------------------
; AT THIS POINT WE HAVE A AND B
; GLOBAL MEANS AND DIFFERENCES
  if (vars(i).eq."AAM") then
    global(i,0) = wgt_areaave(A,gw1,1.0,0)*4.*pi*re^2   ; case1
    global(i,1) = wgt_areaave(B,gw2,1.0,0)*4.*pi*re^2   ; case2
    global(i,2) = global(i,0) - global(i,1)             ; diff
    continue     ; procede to next variable in do loop
  else
    if (vars(i).eq."ICEAREA") then
      if (isfilevar(inptr1,"slat")) then   ; finite volume lat/lon grid
        global(i,0) = iceareaFIX(A,0)+iceareaFIX(A,1)     ; north+south
      else
        global(i,0) = iceareaGAU(A,0)+iceareaGAU(A,1)     ; north+south
      end if
      if (isfilevar(inptr2,"slat")) then   ; finite volume lat/lon grid
        global(i,1) = iceareaFIX(B,0)+iceareaFIX(B,1)
      else
        global(i,1) = iceareaGAU(B,0)+iceareaGAU(B,1)
      end if
      global(i,2) = global(i,0) - global(i,1)           ; diff
    else
      if (vars(i).eq."SST") then ; Have to be careful about masking for differences.

        if (nlat1 .ge. nlat2) then           ; interp A to nlat2          
       
          AonB = B
          AonB = linint2(lon1,lat1,A,False,lon2,lat2,0)
          Amask = B
          Bmask = B
          Amask = (/AonB-B+B/)
          Bmask = (/AonB+B-AonB/)
          delete(A)
          delete(B)
          
          A = Amask
          B = Bmask

          delete(AonB)
          delete(gw1)
          delete(nlat1)
          delete(nlon1)
          delete(lat1)
          delete(lon1)

          ; These are altered now for the grid equalization techniques but
          ; are reset for the next variable
          gw1 = gw2
          nlat1 = nlat2
          nlon1 = nlon2
          lat1 = lat2
          lon1 = lon2

        else
          
          BonA = A
          BonA = linint2(lon2,lat2,B,False,lon1,lat1,0)
          Amask = A
          Bmask = A
          Amask = (/BonA+A-BonA/)
          Bmask = (/BonA+A-A/)
          delete(A)
          delete(B)
          
          A = Amask
          B = Bmask

          delete(BonA)
          delete(gw2)
          delete(nlat2)
          delete(nlon2)
          delete(lat2)
          delete(lon2)

          ; These are altered now for the grid equalization techniques but
          ; are reset for the next variable iff model v. model plots
          gw2 = gw1
          nlat2 = nlat1
          nlon2 = nlon1
          lat2 = lat1
          lon2 = lon1

        end if
        delete(Amask)
        delete(Bmask)

     end if
    
      global(i,0) = wgt_areaave(A,gw1,1.0,0)            ; case1
      global(i,1) = wgt_areaave(B,gw2,1.0,0)            ; case2
      global(i,2) = global(i,0) - global(i,1)           ; diff

    end if
  end if

; TROPICAL, EXTRATROPICAL MEANS AND DIFFERENCES
  if (vars(i).eq."ICEAREA" .or. vars(i).eq."SNOWHLND") then
    tropics(i,0) = 0.0
    tropics(i,1) = 0.0
    tropics(i,2) = 0.0 
    if (vars(i).eq."ICEAREA") then
      if (isfilevar(inptr1,"slat")) then ; finite volume lat/lon grid
        sextrop(i,0) = iceareaFIX(A,0) 
        nextrop(i,0) = iceareaFIX(A,1) 
      else
        sextrop(i,0) = iceareaGAU(A,0) 
        nextrop(i,0) = iceareaGAU(A,1) 
      end if
      if (isfilevar(inptr2,"slat")) then ; finite volume lat/lon grid
        sextrop(i,1) = iceareaFIX(B,0) 
        nextrop(i,1) = iceareaFIX(B,1) 
      else
        sextrop(i,1) = iceareaGAU(B,0) 
        nextrop(i,1) = iceareaGAU(B,1) 
      end if
      sextrop(i,2) = sextrop(i,0) - sextrop(i,1)
      nextrop(i,2) = nextrop(i,0) - nextrop(i,1) 
    else
      nextrop(i,0) = wgt_areaave(A({20:90},:),gw1({20:90}),1.0,0)
      nextrop(i,1) = wgt_areaave(B({20:90},:),gw2({20:90}),1.0,0)
      nextrop(i,2) = nextrop(i,0) - nextrop(i,1)
      sextrop(i,0) = wgt_areaave(A({-90:-20},:),gw1({-90:-20}),1.0,0)
      sextrop(i,1) = wgt_areaave(B({-90:-20},:),gw2({-90:-20}),1.0,0)
      sextrop(i,2) = sextrop(i,0) - sextrop(i,1)
    end if
  else
    tropics(i,0) = wgt_areaave(A({-20:20},:),gw1({-20:20}),1.0,0)
    tropics(i,1) = wgt_areaave(B({-20:20},:),gw2({-20:20}),1.0,0)
    tropics(i,2) = tropics(i,0) - tropics(i,1)
    nextrop(i,0) = wgt_areaave(A({20:90},:),gw1({20:90}),1.0,0)
    nextrop(i,1) = wgt_areaave(B({20:90},:),gw2({20:90}),1.0,0)
    nextrop(i,2) = nextrop(i,0) - nextrop(i,1)
    sextrop(i,0) = wgt_areaave(A({-90:-20},:),gw1({-90:-20}),1.0,0)
    sextrop(i,1) = wgt_areaave(B({-90:-20},:),gw2({-90:-20}),1.0,0)
    sextrop(i,2) = sextrop(i,0) - sextrop(i,1)
  end if

; RMSE
;  if (nlat1 .eq. nlat2) then             ; same size grids
	
;    global(i,3) = wgt_arearmse (A,B,gw1,1.0,0)
;    tropics(i,3) = wgt_arearmse (A({-20:20},:),B({-20:20},:), \
;                                 gw1({-20:20}),1.0,0)
;    nextrop(i,3) = wgt_arearmse (A({20:90},:),B({20:90},:), \
;                                 gw1({20:90}),1.0,0)
;	print (gw1-gw2)
;    sextrop(i,3) = wgt_arearmse (A({-90.:-20.},:),B({-90.:-20.},:), \
;                                 gw1({-90:-20}),1.0,0)

;  else                                   ; different size grids
    if (nlat1 .ge. nlat2) then           ; interp A to nlat2
 
;      tmp = new((/nlat2,nlon2/),float)


      tmp = B


      tmp = linint2(lon1,lat1,A,False,lon2,lat2,0)

       
      global(i,3)  = wgt_arearmse (tmp,B,gw2,1.0,0)
      tropics(i,3) = wgt_arearmse (tmp({-20:20},:),B({-20:20},:), \
                                   gw2({-20:20}),1.0,0)
      nextrop(i,3) = wgt_arearmse (tmp({20:90},:),B({20:90},:), \
                                   gw2({20:90}),1.0,0)
      sextrop(i,3) = wgt_arearmse (tmp({-90:-20},:),B({-90:-20},:), \
                                   gw2({-90:-20}),1.0,0)

    else                                 ; interp B to nlat1

;      tmp = new((/nlat1,nlon1/),float)
      tmp = A
      tmp = linint2(lon2,lat2,B,False,lon1,lat1,0)
      global(i,3)  = wgt_arearmse (A,tmp,gw1,1.0,0)
      tropics(i,3) = wgt_arearmse (A({-20:20},:),tmp({-20:20},:), \
                                   gw1({-20:20}),1.0,0)
      nextrop(i,3) = wgt_arearmse (A({20:90},:),tmp({20:90},:), \
                                   gw1({20:90}),1.0,0)
      sextrop(i,3) = wgt_arearmse (A({-90:-20},:),tmp({-90:-20},:), \
                                   gw1({-90:-20}),1.0,0)
        
 
                                end if
    delete (tmp)
;  end if


  if (compare .eq. "OBS") then
    delete(gw2)
    delete(lat2)
    delete(lon2)
  else

; Reset model lat/lon iff altered for SST grid equalization calculations.
; Case 2 model in model v. model only.
    if (nlat2.ne.nlat2_keep.and.nlon2.ne.nlon2_keep) then
      delete(gw2)
      delete(nlat2)
      delete(nlon2)
      delete(lat2)
      delete(lon2)
      gw2  = gw2_keep
      lat2  = lat2_keep
      nlat2 = nlat2_keep
      lon2  = lon2_keep
      nlon2 = nlon2_keep
    end if
  end if

; Reset model lat/lon iff altered for SST grid equalization calculations.
; Case 1 is always model
  if (nlat1.ne.nlat1_keep.and.nlon1.ne.nlon1_keep) then
    delete(gw1)
    delete(nlat1)
    delete(nlon1)
    delete(lat1)
    delete(lon1)
    gw1  = gw1_keep
    lat1  = lat1_keep
    nlat1 = nlat1_keep
    lon1  = lon1_keep
    nlon1 = nlon1_keep
  end if
  

  delete(A)
  delete(B)
end do     

; PRINTT THE TABLES
do n = 0, 3
  if (compare .eq. "OBS") then
    tablename = wkdir+"table_"+region(n)+"_"+season+"_obs.asc"
    if (region(n) .eq. "GLBL") then
      title = (/"DIAG SET 1: "+season+" MEANS GLOBAL"/)
      make_table(case1,label1,case2,label2,obsvars,global,title,tablename)
    end if
    if (region(n) .eq. "TROP") then
      title = (/"DIAG SET 1: "+season+" MEANS TROPICS (20N-20S)"/)
      make_table(case1,label1,case2,label2,obsvars,tropics,title,tablename)
    end if
    if (region(n) .eq. "NEXT") then
      title = (/"DIAG SET 1: "+season+" MEANS NORTHERN EXTRATROPICS (90N-20N)"/)
      make_table(case1,label1,case2,label2,obsvars,nextrop,title,tablename)
    end if
    if (region(n) .eq. "SEXT") then
      title = (/"DIAG SET 1: "+season+" MEANS SOUTHERN EXTRATROPICS (90S-20S)"/)
      make_table(case1,label1,case2,label2,obsvars,sextrop,title,tablename)
    end if
  else
    tablename = wkdir+"table_"+region(n)+"_"+season+".asc"
    if (region(n) .eq. "GLBL") then
      title = (/"DIAG SET 1: "+season+" MEANS GLOBAL"/)
      make_table(case1,label1,case2,label2,vars,global,title,tablename)
    end if
    if (region(n) .eq. "TROP") then
      title = (/"DIAG SET 1: "+season+" MEANS TROPICS (20N-20S)"/)
      make_table(case1,label1,case2,label2,vars,tropics,title,tablename)
    end if
    if (region(n) .eq. "NEXT") then
      title = (/"DIAG SET 1: "+season+" MEANS NORTHERN EXTRATROPICS (90N-20N)"/)
      make_table(case1,label1,case2,label2,vars,nextrop,title,tablename)
    end if
    if (region(n) .eq. "SEXT") then
      title = (/"DIAG SET 1: "+season+" MEANS SOUTHERN EXTRATROPICS (90S-20S)"/)
      make_table(case1,label1,case2,label2,vars,sextrop,title,tablename)
    end if
  end if
end do 
end
