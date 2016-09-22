; NCL script
; plot_zonal_lines.ncl
; Mark Stevens, Sept 2001
;*********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
load "$DIAG_CODE/functions_zonal.ncl"
;**********************************************************
begin
 compare    = getenv("COMPARE")
 plot_type  = getenv("PLOTTYPE")
 color_type = getenv("COLORTYPE")
 season     = getenv("SEASON")
 version    = getenv("DIAG_VERSION")
 wkdir      = getenv("WKDIR")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename
 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
 end if

; CASE 1 MODEL
 inptr1 = addfile(infile1,"r")
 if (ncdf_mode .eq. "write") then
   outptr1 = addfile(outfile1,"w")
 else
   outptr1 = addfile(outfile1,"c")
 end if
 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case           ; case name
 end if
 tmp = inptr1->lat
 if (typeof(tmp).eq."double") then
   lat1 = dble2flt(tmp)
 else
   lat1 = tmp
 end if
 nlat1 = dimsizes(lat1)
 delete(tmp) 

; CASE 2 IS MODEL OR OBS
 if (compare .eq. "OBS") then
   ptr_merra = addfile(infile2+"/MERRA_"+season+"_climo.nc","r")
   ptr_erai = addfile(infile2+"/ERAI_"+season+"_climo.nc","r")
   ptr_jra25 = addfile(infile2+"/JRA25_"+season+"_climo.nc","r")
   ptr_era40 = addfile(infile2+"/ERA40_"+season+"_climo.nc","r")
   ptr_leg = addfile(infile2+"/LEGATES_"+season+"_climo.nc","r")
   ptr_gpcp = addfile(infile2+"/GPCP_"+season+"_climo.nc","r")
   ptr_modis = addfile(infile2+"/MODIS_"+season+"_climo.nc","r")
   ptr_nvap = addfile(infile2+"/NVAP_"+season+"_climo.nc","r")
   ptr_airs = addfile(infile2+"/AIRS_"+season+"_climo.nc","r")
   ptr_whoi = addfile(infile2+"/WHOI_"+season+"_climo.nc","r")
   ptr_laryea = addfile(infile2+"/LARYEA_"+season+"_climo.nc","r")
   ptr_ceres = addfile(infile2+"/CERES_"+season+"_climo.nc","r")
   ptr_ceres2 = addfile(infile2+"/CERES-EBAF_"+season+"_climo.nc","r")
   ptr_erbe = addfile(infile2+"/ERBE_"+season+"_climo.nc","r")
   ptr_xa = addfile(infile2+"/XIEARKIN_"+season+"_climo.nc","r")
   ptr_isccp = addfile(infile2+"/ISCCP_"+season+"_climo.nc","r")
   ptr_isccpFD = addfile(infile2+"/ISCCPFD_"+season+"_climo.nc","r")
   ptr_ssmi = addfile(infile2+"/SSMI_"+season+"_climo.nc","r")
   ptr_uwisc = addfile(infile2+"/UWisc_LWP_"+season+"_climo.nc","r")
   ptr_trmm = addfile(infile2+"/TRMM_"+season+"_climo.nc","r")
   ptr_warren = addfile(infile2+"/WARREN_"+season+"_climo.nc","r")
   ptr_cloudsat = addfile(infile2+"/CLOUDSAT_"+season+"_climo.nc","r")
   ptr_will = addfile(infile2+"/WILLMOTT_"+season+"_climo.nc","r")
   ptr_cru = addfile(infile2+"/CRU_"+season+"_climo.nc","r")
   ptr_isccpcosp = addfile(infile2+"/ISCCPCOSP_"+season+"_climo.nc","r")
   ptr_misrcosp = addfile(infile2+"/MISRCOSP_"+season+"_climo.nc","r")
   ptr_modiscosp = addfile(infile2+"/MODISCOSP_"+season+"_climo.nc","r")
   ptr_calipsocosp = addfile(infile2+"/CALIPSOCOSP_"+season+"_climo.nc","r")
   ptr_cloudsatcosp = addfile(infile2+"/CLOUDSATCOSP_"+season+"_climo.nc","r")

   lat2 = ptr_merra->lat      ; merra
   nlat2 = dimsizes(lat2)
 else                        ; model to model comparison
   inptr2 = addfile(infile2,"r")
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
   tmp = inptr2->lat
   if (typeof(tmp).eq."double") then
     lat2 = dble2flt(tmp)
   else
     lat2 = tmp
   end if
   delete(tmp) 
   nlat2 = dimsizes(lat2)
 end if

 if (compare .eq. "OBS") then
   merra_vars = (/"PREH2O_MERRA", "PSL_MERRA"/)
   erai_vars = (/"PREH2O_ERAI", "PSL_ERAI"/)
   era40_vars = (/"PREH2O_ERA40","LHFLX_ERA40"/)
   jra25_vars = (/"PREH2O_JRA25","LHFLX_JRA25","PSL_JRA25","SHFLX_JRA25","TREFHT_JRA25"/)
   leg_vars   = (/"TREFHT_LEGATES","PRECT_LEGATES"/)
   gpcp_vars = (/"PRECT_GPCP"/)
   nvap_vars = (/"PREH2O_NVAP","TGCLDLWP_NVAP"/)
   airs_vars = (/"PREH2O_AIRS"/)
   whoi_vars = (/"LHFLX_WHOI","QFLX_WHOI"/)
   laryea_vars = (/"SHFLX_LARYEA","QFLX_LARYEA","FSNS_LARYEA","FLNS_LARYEA"/)
   ssmi_vars  = (/"TGCLDLWP_SSMI","PRECT_SSMI","PREH2O_SSMI"/)
   uwisc_vars = (/"TGCLDLWP_UWISC"/)
   trmm_vars = (/"PRECT_TRMM"/)
   xa_vars = (/"PRECT_XA"/)
   cru_vars = (/"TREFHT_CRU"/)
   will_vars = (/"TREFHT_WILLMOTT"/)
   ceres_vars = (/"SWCF_CERES","LWCF_CERES","FLUT_CERES","FLUTC_CERES", \
                 "FSNTOA_CERES","FSNTOAC_CERES"/)
   ceres2_vars = (/"SWCF_CERES-EBAF","LWCF_CERES-EBAF","FLUT_CERES-EBAF","FLUTC_CERES-EBAF", \
                 "FSNTOA_CERES-EBAF","FSNTOAC_CERES-EBAF"/)
   erbe_vars = (/"SWCF_ERBE","LWCF_ERBE","FLUT_ERBE","FLUTC_ERBE", \
                 "FSNTOA_ERBE","FSNTOAC_ERBE"/)
   isccp_vars = (/"CLDHGH_ISCCP","CLDLOW_ISCCP","CLDMED_ISCCP", \
               "CLDTOT_ISCCP","CLDHGH_VISIR","CLDLOW_VISIR","CLDMED_VISIR", \
               "CLDTOT_VISIR"/)
   isccpFD_vars = (/"FLDS_ISCCP","FLDSC_ISCCP","FSDS_ISCCP","FSDSC_ISCCP", \
                    "FSNS_ISCCP","FSNSC_ISCCP","FLNS_ISCCP","FLNSC_ISCCP", \
                    "SWCFSRF_ISCCP","LWCFSRF_ISCCP"/)
   warren_vars = (/"CLDLOW_WARREN","CLDTOT_WARREN"/)
   cloudsat_vars = (/"CLDLOW_CLOUDSAT","CLDMED_CLOUDSAT","CLDHGH_CLOUDSAT","CLDTOT_CLOUDSAT"/)
   isccpcosp_vars = (/"CLDTOT_ISCCPCOSP","CLDTHICK_ISCCPCOSP", \
                      "CLDLOW_ISCCPCOSP","CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP"/)
   misrcosp_vars = (/"CLDTOT_MISR","CLDTHICK_MISR", \
                      "CLDLOW_MISR","CLDMED_MISR","CLDHGH_MISR"/)
   modiscosp_vars = (/"CLDTOT_MODIS","CLDTHICK_MODIS", \
                      "CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS"/)
   calipsocosp_vars = (/"CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL"/)
   cloudsatcosp_vars = (/"CLDTOT_CS2","CLDTOT_CS2"/)


;  Observations variables
   obsvars = (/"FLUT_ERBE","FLUTC_ERBE","FSNTOA_ERBE","FSNTOAC_ERBE", \
               "LWCF_ERBE","SWCF_ERBE","PRECT_XA","PRECT_SSMI", \
       "PRECT_TRMM","PRECT_GPCP","PREH2O_JRA25","TREFHT_JRA25", \
       "PREH2O_MERRA", "PSL_MERRA", \
       "PREH2O_ERAI", "PSL_ERAI", \
       "PREH2O_ERA40","PREH2O_NVAP","PREH2O_AIRS", \
       "PREH2O_SSMI","TREFHT_LEGATES","PRECT_LEGATES", \
       "CLDHGH_ISCCP","CLDLOW_ISCCP","CLDMED_ISCCP","CLDTOT_ISCCP", \
       "CLDHGH_VISIR","CLDLOW_VISIR","CLDMED_VISIR","CLDTOT_VISIR", \
       "FLDS_ISCCP","FLDSC_ISCCP","FSDS_ISCCP","FSDSC_ISCCP", \
       "FSNS_ISCCP","FSNSC_ISCCP","FLNS_ISCCP","FLNSC_ISCCP", \
       "SWCFSRF_ISCCP","LWCFSRF_ISCCP","CLDLOW_WARREN","CLDTOT_WARREN", \
       "TGCLDLWP_SSMI","TGCLDLWP_NVAP", \
       "LHFLX_WHOI","QFLX_WHOI","SHFLX_JRA25","PSL_JRA25", \
       "LHFLX_JRA25","LHFLX_ERA40","TREFHT_WILLMOTT","TREFHT_CRU", \
       "SWCF_CERES","LWCF_CERES","FLUT_CERES","FLUTC_CERES", \
       "FSNTOA_CERES","FSNTOAC_CERES", \
       "SHFLX_LARYEA","QFLX_LARYEA","FSNS_LARYEA","FLNS_LARYEA", \
       "CLDLOW_CLOUDSAT","CLDMED_CLOUDSAT","CLDHGH_CLOUDSAT","CLDTOT_CLOUDSAT", \
       "SWCF_CERES-EBAF","LWCF_CERES-EBAF","FLUT_CERES-EBAF","FLUTC_CERES-EBAF", "FSNTOA_CERES-EBAF","FSNTOAC_CERES-EBAF",\
       "CLDTOT_ISCCPCOSP","CLDLOW_ISCCPCOSP", \
       "CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP", \
       "CLDTHICK_ISCCPCOSP", \
       "MEANPTOP_ISCCPCOSP","MEANCLDALB_ISCCPCOSP", \
       "CLDTOT_MISR","CLDLOW_MISR","CLDMED_MISR","CLDHGH_MISR", \
       "CLDTHICK_MISR", \
       "CLDTOT_MODIS","CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS", \
       "CLDTHICK_MODIS", \
       "CLWMODIS","CLIMODIS", \
       "IWPMODIS","LWPMODIS", \
       "REFFCLIMODIS","REFFCLWMODIS", \
       "TAUILOGMODIS","TAUWLOGMODIS","TAUTLOGMODIS", \
       "TAUIMODIS","TAUWMODIS","TAUTMODIS", \
       "PCTMODIS", \
       "CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL", \
       "CLDTOT_CS2", "TGCLDLWP_UWISC" /)

;  corresponding model variables
   vars = (/"FLUT","FLUTC","FSNTOA","FSNTOAC", \
            "LWCF", "SWCF","PRECT", "PRECT_OCEAN", \
            "PRECT", "PRECT","PREH2O","TREFHT",\
            "PREH2O", "PSL", \
            "PREH2O", "PSL", \
            "PREH2O","PREH2O","PREH2O", \
            "PREH2O_OCEAN","TREFHT","PRECT", \
            "CLDHGH","CLDLOW","CLDMED","CLDTOT", \
            "CLDHGH","CLDLOW","CLDMED","CLDTOT", \
            "FLDS","FLDSC", "FSDS","FSDSC", \
            "FSNS","FSNSC","FLNS","FLNSC", \
            "SWCFSRF","LWCFSRF","CLDLOW","CLDTOT",\
            "TGCLDLWP_OCEAN","TGCLDLWP_OCEAN", \
            "LHFLX","QFLX","SHFLX","PSL", \
            "LHFLX","LHFLX","TREFHT_LAND", "TREFHT_LAND", \
            "SWCF","LWCF","FLUT","FLUTC", \
            "FSNTOA","FSNTOAC",  \
            "SHFLX","QFLX","FSNS","FLNS", \
            "CLDLOW","CLDMED","CLDHGH","CLDTOT", \
            "SWCF","LWCF","FLUT","FLUTC","FSNTOA","FSNTOAC", \
            "CLDTOT_ISCCPCOSP","CLDLOW_ISCCPCOSP", \
            "CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP", \
            "CLDTHICK_ISCCPCOSP", \
            "MEANPTOP_ISCCPCOSP","MEANCLDALB_ISCCPCOSP", \
            "CLDTOT_MISR","CLDLOW_MISR","CLDMED_MISR","CLDHGH_MISR", \
            "CLDTHICK_MISR", \
            "CLDTOT_MODIS","CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS", \
            "CLDTHICK_MODIS", \
            "CLWMODIS","CLIMODIS", \
            "IWPMODIS","LWPMODIS", \
            "REFFCLIMODIS","REFFCLWMODIS", \
            "TAUILOGMODIS","TAUWLOGMODIS","TAUTLOGMODIS", \
            "TAUIMODIS","TAUWMODIS","TAUTMODIS", \
            "PCTMODIS", \
            "CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL", \
            "CLDTOT_CS2", "TGCLDLWP_OCEAN" /)

 
 else  
;  model-to-model comparisons
   vars = (/"FLNT","FLNTC","FSNT","FSNTC","FLNS","FLNSC","FSNS","FSNSC", \
            "LWCF","SWCF","PRECT","PRECT_LAND","QFLX","PREH2O","TS", \
            "TS_LAND","TAUX_OCEAN","TREFHT","TREFHT_LAND","CLDTOT","CLDLOW", \
            "CLDMED","CLDHGH","RESSURF","TGCLDIWP","TGCLDLWP", \
            "TICLDIWP","TICLDLIQWP","TICLDTWP", \
            "FSDS","FLDS","FLDSC","EP","LHFLX","SHFLX","PSL","PBLH","SOLIN", \
            "FSDSC","PS","RESTOM","VBSTAR_QBSTAR","VBSTAR_TBSTAR", \
            "VBSTAR_UBSTAR","VPQP_BAR","VPTP_BAR","VPUP_BAR","AODVIS","AODDUST", \
            "CLDTOT_ISCCPCOSP","CLDLOW_ISCCPCOSP", \
            "CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP", \
            "CLDTHICK_ISCCPCOSP", \
            "MEANPTOP_ISCCPCOSP","MEANCLDALB_ISCCPCOSP", \
            "CLDTOT_MISR","CLDLOW_MISR","CLDMED_MISR","CLDHGH_MISR", \
            "CLDTHICK_MISR", \
            "CLDTOT_MODIS","CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS", \
            "CLDTHICK_MODIS", \
            "CLWMODIS","CLIMODIS", \
            "IWPMODIS","LWPMODIS", \
            "REFFCLIMODIS","REFFCLWMODIS", \
            "TAUILOGMODIS","TAUWLOGMODIS","TAUTLOGMODIS", \
            "TAUIMODIS","TAUWMODIS","TAUTMODIS", \
            "PCTMODIS", \
            "CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL", \
            "CLDTOT_CS2"/)
 
 end if

 nvars = dimsizes(vars)
;******************************************************************
; common resources for xy plots 
 plot = new(2,"graphic")
 res                        = True
 res@gsnDraw                = False               ; Do not draw plot
 res@gsnFrame               = False               ; Do not advance frame
 res@trXReverse             = True  
 res@tiXAxisString          = "latitude" 
 res@tiXAxisFontHeightF     = 0.020
 res@tiYAxisFontHeightF     = 0.020
 res@tiMainFontHeightF      = 0.025
 res@pmLegendSide           = "Right"            ; Change location of 
 res@pmLegendParallelPosF   = 0.10               ; of the legend
 res@pmLegendOrthogonalPosF = 0.02               ; of the legend
 res@pmLegendWidthF         = 0.12               ; Change width and
 res@pmLegendHeightF        = 0.10               ; height of legend.
 res@lgPerimOn              = True
 res@lgLabelFontHeightF     = .020
 res@txFontHeightF = 0.015
 res@xyDashPatterns         = (/0.,1./)          ; solid, dashed 
 res@xyLineThicknesses      = (/2.,2./)
 if (color_type .eq. "COLOR") then
   res@xyLineColors         = (/"black","red","blue","green"/)
   res@xyLineColor = "black"
 end if
;----------------------------------------------
; common resources for panel plots
 pan = True
 pan@gsnMaximize = True
 pan@gsnPaperOrientation = "portrait"
 pan@gsnFrame = False
;----------------------------------------------

do i = 0, nvars-1
 ;print("i = "+i+": "+vars(i)) 
 ;print("i = "+i+": "+obsvars(i)) 
; CASE 1 MODEL
  if (vars(i) .eq. "CLDHGH") then
    A = zonal_CLDHGH (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDLOW") then
    A = zonal_CLDLOW (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDMED") then
    A = zonal_CLDMED (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDTOT") then
    A = zonal_CLDTOT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "EKE_BAR") then
    A = zonal_EKE_BAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "EP") then
    A = zonal_EP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLDS") then
    A = zonal_FLDS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLDSC") then
    A = zonal_FLDSC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLNS") then
    A = zonal_FLNS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLNSC") then
    A = zonal_FLNSC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLNT") then
    A = zonal_FLNT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLNTC") then
    A = zonal_FLNTC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLUT") then
    A = zonal_FLUT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FLUTC") then
    A = zonal_FLUTC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSDS") then
    A = zonal_FSDS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSDSC") then
    A = zonal_FSDSC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNS") then
    A = zonal_FSNS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNSC") then
    A = zonal_FSNSC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNT") then
    A = zonal_FSNT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNTC") then
    A = zonal_FSNTC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNTOA") then
    A = zonal_FSNTOA (inptr1,outptr1)
  end if
  if (vars(i) .eq. "FSNTOAC") then
    A = zonal_FSNTOAC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "LHFLX") then
    A = zonal_LHFLX (inptr1,outptr1)
  end if
  if (vars(i) .eq. "LWCFSRF") then
    A = zonal_LWCFSRF (inptr1,outptr1)
  end if
  if (vars(i) .eq. "LWCF") then
    if (compare .eq. "OBS") then
      A = zonal_LWCFTOA (inptr1,outptr1)
    else
      A = zonal_LWCFTOM (inptr1,outptr1)
    end if
  end if
  if (vars(i) .eq. "PBLH") then
    A = zonal_PBLH (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PRECT") then
    A = zonal_PRECT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PRECT_LAND") then
    A = zonal_PRECT_LAND (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PRECT_OCEAN") then
    A = zonal_PRECT_OCEAN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PREH2O") then
    A = zonal_PREH2O (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PREH2O_OCEAN") then
    A = zonal_PREH2O_OCEAN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PS") then
    A = zonal_PS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PSL") then
    A = zonal_PSL (inptr1,outptr1)
  end if
  if (vars(i) .eq. "QFLX") then
    A = zonal_QFLX (inptr1,outptr1)
  end if
  if (vars(i) .eq. "RESSURF") then
    A = zonal_RESSURF (inptr1,outptr1)
  end if
  if (vars(i) .eq. "RESTOM") then
    A = zonal_RESTOM (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SHFLX") then
    A = zonal_SHFLX (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SOLIN") then
    A = zonal_SOLIN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AODVIS") then
    A = zonal_AODVIS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AODDUST") then
    A = zonal_AODDUST (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SWCFSRF") then
    A = zonal_SWCFSRF (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SWCF") then
    if (compare .eq. "OBS") then
      A = zonal_SWCFTOA (inptr1,outptr1)
    else
      A = zonal_SWCFTOM (inptr1,outptr1)
    end if
  end if
  if (vars(i) .eq. "TAUX_OCEAN") then
    A = zonal_TAUX_OCEAN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TGCLDIWP") then
    A = zonal_TGCLDIWP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TGCLDLWP") then
    A = zonal_TGCLDLWP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TGCLDLWP_OCEAN") then
    A = zonal_TGCLDLWP_OCEAN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TICLDIWP") then
    A = zonal_TICLDIWP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TICLDLIQWP") then
    A = zonal_TICLDLIQWP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TICLDTWP") then
    A = zonal_TICLDTWP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TREFHT") then
    A = zonal_TREFHT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TREFHT_LAND") then
    A = zonal_TREFHT_LAND (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TS") then
    A = zonal_TS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TS_LAND") then
    A = zonal_TS_LAND (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VBSTAR_QBSTAR") then
    A = zonal_VBSTAR_QBSTAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VBSTAR_TBSTAR") then
    A = zonal_VBSTAR_TBSTAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VBSTAR_UBSTAR") then
    A = zonal_VBSTAR_UBSTAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VPQP_BAR") then
    A = zonal_VPQP_BAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VPTP_BAR") then
    A = zonal_VPTP_BAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VPUP_BAR") then
    A = zonal_VPUP_BAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDTOT_ISCCPCOSP") then
    A = zonal_CLDTOT_ISCCPCOSP (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDLOW_ISCCPCOSP") then
    A = zonal_CLDLOW_ISCCPCOSP (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDMED_ISCCPCOSP") then
    A = zonal_CLDMED_ISCCPCOSP (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDHGH_ISCCPCOSP") then
    A = zonal_CLDHGH_ISCCPCOSP (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDTHICK_ISCCPCOSP") then
    A = zonal_CLDTHICK_ISCCPCOSP (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "MEANPTOP_ISCCPCOSP") then
    A = zonal_MEANPTOP_ISCCPCOSP (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "MEANCLDALB_ISCCPCOSP") then
    A = zonal_MEANCLDALB_ISCCPCOSP (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDTOT_MISR") then
    A = zonal_CLDTOT_MISR (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDLOW_MISR") then
    A = zonal_CLDLOW_MISR (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDMED_MISR") then
    A = zonal_CLDMED_MISR (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDHGH_MISR") then
    A = zonal_CLDHGH_MISR (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDTHICK_MISR") then
    A = zonal_CLDTHICK_MISR (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDTOT_MODIS") then
    A = zonal_CLDTOT_MODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDLOW_MODIS") then
    A = zonal_CLDLOW_MODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDMED_MODIS") then
    A = zonal_CLDMED_MODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDHGH_MODIS") then
    A = zonal_CLDHGH_MODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDTHICK_MODIS") then
    A = zonal_CLDTHICK_MODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLWMODIS") then
    A = zonal_CLWMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLIMODIS") then
    A = zonal_CLIMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "IWPMODIS") then
    A = zonal_IWPMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "LWPMODIS") then
    A = zonal_LWPMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "REFFCLIMODIS") then
    A = zonal_REFFCLIMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "REFFCLWMODIS") then
    A = zonal_REFFCLWMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "TAUTLOGMODIS") then
    A = zonal_TAUTLOGMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "TAUILOGMODIS") then
    A = zonal_TAUILOGMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "TAUWLOGMODIS") then
    A = zonal_TAUWLOGMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "TAUTMODIS") then
    A = zonal_TAUTMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "TAUIMODIS") then
    A = zonal_TAUIMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "TAUWMODIS") then
    A = zonal_TAUWMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "PCTMODIS") then
    A = zonal_PCTMODIS (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDTOT_CAL") then
    A = zonal_CLDTOT_CAL (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDLOW_CAL") then
    A = zonal_CLDLOW_CAL (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDMED_CAL") then
    A = zonal_CLDMED_CAL (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDHGH_CAL") then
    A = zonal_CLDHGH_CAL (inptr1,outptr1)
  end if 
  if (vars(i) .eq. "CLDTOT_CS2") then
    A = zonal_CLDTOT_CS2 (inptr1,outptr1)
  end if 

  if (all(A.eq.-999.)) then
    print (vars(i)+" not present in test case input file.")
    delete(A)
    continue       ; procede to next variable in do loop
  end if

  if (compare .eq. "OBS") then            ; CASE 2 IS OBS
    if (any(obsvars(i).eq.jra25_vars)) then
      inptr2 = ptr_jra25
      case2 = "JRA25"
      delete(lat2)
      lat2 = ptr_jra25->lat     
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.erai_vars)) then
      inptr2 = ptr_erai
      case2 = "ERAI"
      delete(lat2)
      lat2 = ptr_erai->lat     
      nlat2 = dimsizes(lat2)
    end if
  if (any(obsvars(i).eq.merra_vars)) then
      inptr2 = ptr_merra
      case2 = "MERRA"
      delete(lat2)
      lat2 = ptr_merra->lat     
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.era40_vars)) then
      inptr2 = ptr_era40
      case2 = "ERA40"
      delete(lat2)
      lat2 = ptr_era40->lat     
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.leg_vars)) then
      inptr2 = ptr_leg
      case2 = "LEGATES"
    end if
    if (any(obsvars(i).eq.gpcp_vars)) then
      inptr2 = ptr_gpcp
      case2 = "GPCP"
      delete(lat2)
      lat2 = ptr_gpcp->lat      ; 1x1 degree
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.nvap_vars)) then
      inptr2 = ptr_nvap
      case2 = "NVAP"
      delete(lat2)
      lat2 = ptr_nvap->lat      ; 1x1 degree
      nlat2 = dimsizes(lat2)
    end if
     if (any(obsvars(i).eq.airs_vars)) then
      inptr2 = ptr_airs
      case2 = "AIRS"
      delete(lat2)
      lat2 = ptr_airs->lat      ; 1x1 degree
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.whoi_vars)) then
      inptr2 = ptr_whoi
      case2 = "WHOI"
      delete(lat2)
      lat2 = ptr_whoi->lat      ; 1x1 degree
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.laryea_vars)) then
      inptr2 = ptr_laryea
      case2 = "LARGE-YEAGER"
      delete(lat2)
      lat2 = ptr_laryea->lat      ; 1x1 degree
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.ssmi_vars)) then
      inptr2 = ptr_ssmi
      case2 = "SSMI"
      delete(lat2)
      lat2 = ptr_ssmi->lat      ; 1x1 degree
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.uwisc_vars)) then
      inptr2 = ptr_uwisc
      case2 = "UWISC"
      delete(lat2)
      lat2 = ptr_uwisc->lat      ; 1x1 degree
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.trmm_vars)) then
      inptr2 = ptr_trmm
      case2 = "TRMM"
      delete(lat2)
      lat2 = ptr_trmm->lat      ; 1x1 degrees 
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.ceres_vars)) then
      inptr2 = ptr_ceres
      case2 = "CERES"
      delete(lat2)
      lat2 = ptr_ceres->lat      ; 2.5x2.5 degrees 
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.ceres2_vars)) then
      inptr2 = ptr_ceres2
      case2 = "CERES-EBAF"
      delete(lat2)
      lat2 = ptr_ceres2->lat      ; 1x1 degrees 
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.erbe_vars)) then
      inptr2 = ptr_erbe
      case2 = "ERBE"
      delete(lat2)
      lat2 = ptr_erbe->lat      
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.isccp_vars)) then
      inptr2 = ptr_isccp
      case2 = "ISCCP D2"
      delete(lat2)
      lat2 = ptr_isccp->lat      
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.isccpFD_vars)) then
      inptr2 = ptr_isccpFD
      case2 = "ISCCP FD"
      delete(lat2)
      lat2 = ptr_isccpFD->lat      
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.warren_vars)) then
      inptr2 = ptr_warren
      case2 = "WARREN"
      delete(lat2)
      lat2 = ptr_warren->lat      
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.cloudsat_vars)) then
      inptr2 = ptr_cloudsat
      case2 = "CLOUDSAT"
      delete(lat2)
      lat2 = ptr_cloudsat->lat      
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.xa_vars)) then
      inptr2 = ptr_xa
      case2 = "XIE-ARKIN"
      delete(lat2)
      lat2 = ptr_xa->lat      
      nlat2 = dimsizes(lat2)
   end if
    if (any(obsvars(i).eq.cru_vars)) then
      inptr2 = ptr_cru
      case2 = "IPCC/CRU"
      delete(lat2)
      lat2 = ptr_cru->lat      ; 1x1 degree 
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i).eq.will_vars)) then
      inptr2 = ptr_will
      case2 = "WILLMOTT"
      delete(lat2)
      lat2 = ptr_will->lat      ; 1x1 degree 
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i) .eq. isccpcosp_vars)) then
      inptr2 = ptr_isccpcosp
      case2 = "ISCCP-COSP"
      delete(lat2)
      lat2 = ptr_isccpcosp->lat     
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i) .eq. modiscosp_vars)) then
      inptr2 = ptr_modiscosp
      case2 = "MODIS-COSP"
      delete(lat2)
      lat2 = ptr_modiscosp->lat
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i) .eq. misrcosp_vars)) then
      inptr2 = ptr_misrcosp
      case2 = "MISR L3 CTH-OD V5"
      delete(lat2)
      lat2 = ptr_misrcosp->lat     
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i) .eq. calipsocosp_vars)) then
      inptr2 = ptr_calipsocosp
      case2 = "CALIPSO GOCCP"
      delete(lat2)
      lat2 = ptr_calipsocosp->lat
      nlat2 = dimsizes(lat2)
    end if
    if (any(obsvars(i) .eq. cloudsatcosp_vars)) then
      inptr2 = ptr_cloudsatcosp
      case2 = "CLOUDSAT COSP"
      delete(lat2)
      lat2 = ptr_cloudsatcosp->lat
      nlat2 = dimsizes(lat2)
    end if


    if (vars(i).eq."TREFHT_LAND" .or. obsvars(i).eq."CLDLOW_WARREN" \
        .or. obsvars(i).eq."CLDTOT_WARREN"    \
        .or. obsvars(i).eq."CLDLOW_CLOUDSAT"  \
        .or. obsvars(i).eq."CLDMED_CLOUDSAT"  \
        .or. obsvars(i).eq."CLDHGH_CLOUDSAT"  \
        .or. obsvars(i).eq."CLDTOT_CLOUDSAT") then
      tmp = inptr2->$vars(i)$           ; no time variable
    else
      if (isfilevar(inptr2,obsvars(i))) then 
;       BRH addition to deal with other obs files that don't have time dim
        if (dimsizes(getfilevardimsizes(inptr2,obsvars(i))).eq.3) then
          tmp = inptr2->$obsvars(i)$(0,:,:)
        else
         tmp = inptr2->$obsvars(i)$
        end if
;       end BRH addition
      else
       tmp = inptr2->$vars(i)$(0,:,:)     
      end if
    end if


 
    B = dim_avg_Wrap(tmp)          ; zonal ave
    delete(tmp)
  else                              
;   CASE 2 IS MODEL
    if (vars(i) .eq. "CLDHGH") then
      B = zonal_CLDHGH (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDLOW") then
      B = zonal_CLDLOW (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDMED") then
      B = zonal_CLDMED (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDTOT") then
      B = zonal_CLDTOT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "EKE_BAR") then
      B = zonal_EKE_BAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "EP") then
      B = zonal_EP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLDS") then
      B = zonal_FLDS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLDSC") then
      B = zonal_FLDSC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLNS") then
      B = zonal_FLNS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLNSC") then
      B = zonal_FLNSC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLNT") then
      B = zonal_FLNT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLNTC") then
      B = zonal_FLNTC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLUT") then
      B = zonal_FLUT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FLUTC") then
      B = zonal_FLUTC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSDS") then
      B = zonal_FSDS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSDSC") then
      B = zonal_FSDSC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNS") then
      B = zonal_FSNS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNSC") then
      B = zonal_FSNSC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNT") then
      B = zonal_FSNT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNTC") then
      B = zonal_FSNTC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNTOA") then
      B = zonal_FSNTOA (inptr2,outptr2)
    end if
    if (vars(i) .eq. "FSNTOAC") then
      B = zonal_FSNTOAC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "LHFLX") then
      B = zonal_LHFLX (inptr2,outptr2)
    end if
    if (vars(i) .eq. "LWCFSRF") then 
      B = zonal_LWCFSRF (inptr2,outptr2)
    end if
    if (vars(i) .eq. "LWCF") then 
      B = zonal_LWCFTOM (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PBLH") then
      B = zonal_PBLH (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PRECT") then
      B = zonal_PRECT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PRECT_LAND") then
      B = zonal_PRECT_LAND (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PRECT_OCEAN") then
      B = zonal_PRECT_OCEAN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PREH2O") then
      B = zonal_PREH2O (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PREH2O_OCEAN") then
      B = zonal_PREH2O_OCEAN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PS") then
      B = zonal_PS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PSL") then
      B = zonal_PSL (inptr2,outptr2)
    end if
    if (vars(i) .eq. "QFLX") then
      B = zonal_QFLX (inptr2,outptr2)
    end if
    if (vars(i) .eq. "RESSURF") then
      B = zonal_RESSURF (inptr2,outptr2)
    end if
    if (vars(i) .eq. "RESTOM") then
      B = zonal_RESTOM (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SHFLX") then
      B = zonal_SHFLX (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SOLIN") then
      B = zonal_SOLIN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AODVIS") then
      B = zonal_AODVIS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AODDUST") then
      B = zonal_AODDUST (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SWCFSRF") then
      B = zonal_SWCFSRF (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SWCF") then
      B = zonal_SWCFTOM (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TAUX_OCEAN") then
      B = zonal_TAUX_OCEAN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TGCLDIWP") then
      B = zonal_TGCLDIWP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TGCLDLWP") then
      B = zonal_TGCLDLWP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TGCLDLWP_OCEAN") then
      B = zonal_TGCLDLWP_OCEAN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TICLDIWP") then
      B = zonal_TICLDIWP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TICLDLIQWP") then
      B = zonal_TICLDLIQWP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TICLDTWP") then
      B = zonal_TICLDTWP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TREFHT") then
      B = zonal_TREFHT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TREFHT_LAND") then
      B = zonal_TREFHT_LAND (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TS") then
      B = zonal_TS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TS_LAND") then
      B = zonal_TS_LAND (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VBSTAR_QBSTAR") then
      B = zonal_VBSTAR_QBSTAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VBSTAR_TBSTAR") then
      B = zonal_VBSTAR_TBSTAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VBSTAR_UBSTAR") then
      B = zonal_VBSTAR_UBSTAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VPQP_BAR") then
      B = zonal_VPQP_BAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VPTP_BAR") then
      B = zonal_VPTP_BAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VPUP_BAR") then
      B = zonal_VPUP_BAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDTOT_ISCCPCOSP") then
      B = zonal_CLDTOT_ISCCPCOSP (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDLOW_ISCCPCOSP") then
      B = zonal_CLDLOW_ISCCPCOSP (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDMED_ISCCPCOSP") then
      B = zonal_CLDMED_ISCCPCOSP (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDHGH_ISCCPCOSP") then
      B = zonal_CLDHGH_ISCCPCOSP (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDTHICK_ISCCPCOSP") then
      B = zonal_CLDTHICK_ISCCPCOSP (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "MEANPTOP_ISCCPCOSP") then
      B = zonal_MEANPTOP_ISCCPCOSP (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "MEANCLDALB_ISCCPCOSP") then
      B = zonal_MEANCLDALB_ISCCPCOSP (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDTOT_MISR") then
      B = zonal_CLDTOT_MISR (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDLOW_MISR") then
      B = zonal_CLDLOW_MISR (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDMED_MISR") then
      B = zonal_CLDMED_MISR (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDHGH_MISR") then
      B = zonal_CLDHGH_MISR (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDTHICK_MISR") then
      B = zonal_CLDTHICK_MISR (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDTOT_MODIS") then
      B = zonal_CLDTOT_MODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDLOW_MODIS") then
      B = zonal_CLDLOW_MODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDMED_MODIS") then
      B = zonal_CLDMED_MODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDHGH_MODIS") then
      B = zonal_CLDHGH_MODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDTHICK_MODIS") then
      B = zonal_CLDTHICK_MODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLWMODIS") then
      B = zonal_CLWMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLIMODIS") then
      B = zonal_CLIMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "IWPMODIS") then
      B = zonal_IWPMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "LWPMODIS") then
      B = zonal_LWPMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "REFFCLIMODIS") then
      B = zonal_REFFCLIMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "REFFCLWMODIS") then
      B = zonal_REFFCLWMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "TAUTLOGMODIS") then
      B = zonal_TAUTLOGMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "TAUILOGMODIS") then
      B = zonal_TAUILOGMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "TAUWLOGMODIS") then
      B = zonal_TAUWLOGMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "TAUTMODIS") then
      B = zonal_TAUTMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "TAUIMODIS") then
      B = zonal_TAUIMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "TAUWMODIS") then
      B = zonal_TAUWMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "PCTMODIS") then
      B = zonal_PCTMODIS (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDTOT_CAL") then
      B = zonal_CLDTOT_CAL (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDLOW_CAL") then
      B = zonal_CLDLOW_CAL (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDMED_CAL") then
      B = zonal_CLDMED_CAL (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDHGH_CAL") then
      B = zonal_CLDHGH_CAL (inptr2,outptr2)
    end if 
    if (vars(i) .eq. "CLDTOT_CS2") then
      B = zonal_CLDTOT_CS2 (inptr2,outptr2)
    end if 
  end if

  if (all(B.eq.-999.)) then
    print (vars(i)+" not present in control case input file.")
    delete(A)
    delete(B)
    continue       ; procede to next variable in do loop
  end if

; check for different number of latitudes and thenn
; lineary interpolate to the smaller number of latitudes
  
  if (nlat1 .ne. nlat2) then           ; lat grids different
    if (nlat1 .gt. nlat2) then
      ydata = new((/2,nlat2/),"float")
      ydata(0,:) = linint1 (lat1,A,False,lat2,0)   ; case1
      ydata(1,:) = (/B/)                           ; case2
      plat = lat2
    else
      ydata = new((/2,nlat1/),"float")
      ydata(0,:) = (/A/)                           ; case1
      ydata(1,:) = linint1 (lat2,B,False,lat1,0)   ; case2
      plat = lat1
    end if
  else                                 ; same grid latitudes
    ydata = new((/2,nlat1/),"float")
    ydata(0,:) = (/A/)                      ; case1
    ydata(1,:) = (/B/)                      ; case2
    plat = lat1
  end if

  ydata!0 = "line"
  ydata!1 = "lat"
  ydata&lat = plat
  C = ydata(0,:)
  C = (/ydata(0,:)-ydata(1,:)/)        ; case difference
 
;------------------------ Open files for plots -----------------------
  if (compare .eq.  "OBS") then
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+"set3_"+season+"_"+obsvars(i)+"_obsc")
    else
      wks = gsn_open_wks(plot_type,wkdir+"set3_"+season+"_"+obsvars(i)+"_obs")
    end if
  else
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+"set3_"+season+"_"+vars(i)+"_c")
    else
      wks = gsn_open_wks(plot_type,wkdir+"set3_"+season+"_"+vars(i))
    end if
  end if 
;--------------------------------------------------------------------
  res@tiMainString = season 
  res@pmLegendDisplayMode = "Always"

  res@tiYAxisString = A@long_name + " ("+ A@units + ")"
  res@xyExplicitLegendLabels = (/case1,case2/)
  res@xyMonoLineColor = False

  plot(0) = gsn_csm_xy(wks,plat,ydata,res)   ; cases line plot   
  delete(res@tiMainString)
  delete (res@xyExplicitLegendLabels)       ; no label
  delete (res@pmLegendDisplayMode)          ; default is off

  res@xyMonoLineColor = True 
  res@tiMainString = case1+" - "+case2
  plot(1) = gsn_csm_xy(wks,plat,C,res)      ; diff line plot
  delete(res@tiMainString)

  if (time_stamp .eq. "True") then
    pan@gsnPanelBottom = 0.05
    gsn_panel(wks,plot,(/2,1/),pan)         ; panel plot
    infoTimeStamp(wks, 0.011, "AMWG Diagnostics Version: "+version)
  else
    gsn_panel(wks,plot,(/2,1/),pan)         ; panel plot
  end if
  frame (wks)

  delete(ydata)
  delete(plat)
  delete(A)
  delete(B)
  delete(C)
end do        

end
