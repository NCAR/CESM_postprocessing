; NCL script
; plot_seas_cycle.ncl (set 10)
; Mark Stevens April 2002
;----------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"

begin

compare    = getenv("COMPARE")
plot_type  = getenv("PLOTTYPE")
color_type = getenv("COLORTYPE")
case_names = getenv("CASENAMES")
time_stamp = getenv("TIMESTAMP") 
version    = getenv("DIAG_VERSION")
ncdf_mode  = getenv("NCDF_MODE")
wkdir      = getenv("WKDIR")
infile1    = getenv("TEST_INPUT")     ; case1 input prefix
outfile1   = getenv("TEST_PLOTVARS")
infile2    = getenv("CNTL_INPUT")     ; case2 input prefix
if (compare .ne. "OBS") then
  outfile2   = getenv("CNTL_PLOTVARS")
end if

month = (/"01","02","03","04","05","06","07","08","09","10","11","12"/)

; CASE 1 is model
inptr1 = new(12,file)
outptr1 = new(12,file)

do m = 0,11 
  inptr1(m) = addfile(infile1+"_"+month(m)+"_climo.nc","r")
  if (ncdf_mode .eq. "write") then
    outptr1(m) = addfile(outfile1+"_"+month(m)+"_plotvars.nc","w")
  else
    system("rm -f "+outfile1+"_"+month(m)+"_plotvars.nc")
    outptr1(m) = addfile(outfile1+"_"+month(m)+"_plotvars.nc","c")
  end if 
end do

inptr = inptr1(0)
if (case_names .eq. "True") then
  case1 = getenv("CASE1")
else
  case1 = inptr@case
end if
if (isatt(inptr,"yrs_averaged")) then
  yrs_ave1 = inptr@yrs_averaged
end if

if (compare .eq. "OBS") then
  ptr_jra25 = new(12,file)
  ptr_erai = new(12,file)
  ptr_era40 = new(12,file)
  ptr_airs = new(12,file)
  ptr_ceres = new(12,file)
  ptr_ceres2 = new(12,file)
  ptr_laryea = new(12,file)
  ptr_whoi = new(12,file)
  ptr_erbe = new(12,file)
  ptr_gpcp = new(12,file)
  ptr_had = new(12,file)
  ptr_isccp = new(12,file)
  ptr_isccpFD = new(12,file)
  ptr_leg = new(12,file)
  ptr_merra = new(12,file)
  ptr_nvap = new(12,file)
  ptr_ssmiice = new(12,file)
  ptr_ssmi = new(12,file)
  ptr_uwisc = new(12,file)
  ptr_trmm = new(12,file)
  ptr_will = new(12,file)
  ptr_xa = new(12,file)
  ptr_isccpcosp = new(12,file) 
  ptr_modiscosp = new(12,file) 
  ptr_misrcosp = new(12,file) 
  ptr_calipsocosp = new(12,file) 
  ptr_cloudsatcosp = new(12,file) 

  do m = 0 ,11
    ptr_jra25(m) = addfile(infile2+"/JRA25_"+month(m)+"_climo.nc","r")
    ptr_erai(m) = addfile(infile2+"/ERAI_"+month(m)+"_climo.nc","r")
    ptr_era40(m) = addfile(infile2+"/ERA40_"+month(m)+"_climo.nc","r")
    ptr_airs(m) = addfile(infile2+"/AIRS_"+month(m)+"_climo.nc","r")
    ptr_ceres(m) = addfile(infile2+"/CERES_"+month(m)+"_climo.nc","r")
    ptr_ceres2(m) = addfile(infile2+"/CERES-EBAF_"+month(m)+"_climo.nc","r")
    ptr_laryea(m) = addfile(infile2+"/LARYEA_"+month(m)+"_climo.nc","r")
    ptr_whoi(m) = addfile(infile2+"/WHOI_"+month(m)+"_climo.nc","r")
    ptr_erbe(m) = addfile(infile2+"/ERBE_"+month(m)+"_climo.nc","r")
    ptr_gpcp(m) = addfile(infile2+"/GPCP_"+month(m)+"_climo.nc","r")
    ;ptr_had(m) = addfile(infile2+"/HadISST_"+month(m)+"_climo.nc","r")
    ptr_had(m)  = addfile(infile2+"/HadISST_CL_"+month(m)+"_climo.nc","r")
    ptr_isccp(m) = addfile(infile2+"/ISCCP_"+month(m)+"_climo.nc","r")
    ptr_isccpFD(m) = addfile(infile2+"/ISCCPFD_"+month(m)+"_climo.nc","r")
    ptr_leg(m) = addfile(infile2+"/LEGATES_"+month(m)+"_climo.nc","r")
    ptr_merra(m) = addfile(infile2+"/MERRA_"+month(m)+"_climo.nc","r")
    ptr_nvap(m) = addfile(infile2+"/NVAP_"+month(m)+"_climo.nc","r")
    ptr_ssmi(m) = addfile(infile2+"/SSMI_"+month(m)+"_climo.nc","r")
    ptr_uwisc(m) = addfile(infile2+"/UWisc_LWP_"+month(m)+"_climo.nc","r")
    ptr_ssmiice(m) = addfile(infile2+"/SSMI_SEAICE_"+month(m)+"_climo.nc","r")
    ptr_trmm(m) = addfile(infile2+"/TRMM_"+month(m)+"_climo.nc","r")
    ptr_will(m) = addfile(infile2+"/WILLMOTT_"+month(m)+"_climo.nc","r")
    ptr_xa(m) = addfile(infile2+"/XIEARKIN_"+month(m)+"_climo.nc","r")
    ptr_isccpcosp(m) = addfile(infile2+"/ISCCPCOSP_"+month(m)+"_climo.nc","r") 
    ptr_modiscosp(m) = addfile(infile2+"/MODISCOSP_"+month(m)+"_climo.nc","r") 
    ptr_misrcosp(m) = addfile(infile2+"/MISRCOSP_"+month(m)+"_climo.nc","r") 
    ptr_calipsocosp(m) = addfile(infile2+"/CALIPSOCOSP_"+month(m)+"_climo.nc","r") 
    ptr_cloudsatcosp(m) = addfile(infile2+"/CLOUDSATCOSP_"+month(m)+"_climo.nc","r") 
  end do
else
  inptr2 = new(12,file)
  outptr2 = new(12,file)
  do m = 0,11 
    inptr2(m) = addfile(infile2+"_"+month(m)+"_climo.nc","r")
    if (ncdf_mode .eq. "write") then
      outptr2(m) = addfile(outfile2+"_"+month(m)+"_plotvars.nc","w")
    else
     system("rm -f " + outfile2+"_"+month(m)+"_plotvars.nc")
     outptr2(m) = addfile(outfile2+"_"+month(m)+"_plotvars.nc","c")
    end if 
  end do
  inptr = inptr2(0)
  if (case_names .eq. "True") then
    case2 = getenv("CASE2")
  else
    case2 = inptr@case
  end if
  if (isatt(inptr,"yrs_averaged")) then
    yrs_ave2 = inptr@yrs_averaged
  end if
end if
;--------------------------------------------------------------
; common plot resources
res = True
res@gsnMaximize = True
res@gsnPaperOrientation = "portrait"
res@tiMainString = "Annual Cycle Global Mean Climatology"
res@tiMainFontHeightF = 0.022
res@tiMainFont = "helvetica-bold"
res@tiYAxisFontHeightF = 0.015
if (color_type .eq. "COLOR") then
  res@xyLineColors    = (/"red","blue"/)
else
  res@xyMonoLineColor = True
  res@xyLineColor = "black"
end if
res@xyLineThicknesses = (/2,2/)
res@xyDashPatterns    = (/1,0/) 
res@xyMarkLineModes = (/"MarkLines","MarkLines"/)
res@xyMarker = 16
res@xyMarkerSizeF = 0.01
res@pmLegendDisplayMode = "Always"
res@pmLegendSide = "Bottom"
res@pmLegendWidthF = 0.15
res@pmLegendHeightF = 0.08
res@pmLegendOrthogonalPosF = -.018
res@pmLegendParallelPosF = 0.5
res@lgLabelFontHeightF = .018
res@lgPerimOn = True 
res@txFontHeightF = 0.020
res@tmXBMode = "Explicit"
res@tmXBLabelFontHeightF = 0.015
res@tmXBLabels=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                 "Oct","Nov","Dec","Jan"/) 
res@tmXBValues = ispan(0,12,1)

;--------------------------------------------------------------------
months = new((/2,13/),integer)    
months(0,:) = ispan(0,12,1) 
months(1,:) = ispan(0,12,1) 
months!0 = "month"
months!1 = "month"
gblmean = new((/2,13/),float)  ; case1 and case2
gblmean!0 = "line"
gblmean!1 = "month"
nhmean = new((/2,13/),float)   ; case1 and case2
shmean = new((/2,13/),float)
nhmean!0 = "line"
nhmean!1 = "month"
shmean!0 = "line"
shmean!1 = "month"

if (compare .eq. "OBS") then
; OBS varaibles
  merra_vars = (/"PSL_MERRA","TS_MERRA","PREH2O_MERRA","T_850_MERRA", \
                "T_200_MERRA","U_200_MERRA","Z3_300_MERRA","Z3_500_MERRA"/)
  erbe_vars = (/"FSNTOA_ERBE","FSNTOAC_ERBE","FLUT_ERBE","FLUTC_ERBE", \
                "LWCF_ERBE","SWCF_ERBE","RESTOA_ERBE"/)
  erai_vars = (/"PREH2O_ERAI","T_850_ERAI","T_200_ERAI","Z3_300_ERAI", \
           "Z3_500_ERAI","U_200_ERAI"/)
  era40_vars = (/"PREH2O_ERA40","T_850_ERA40","T_200_ERA40","Z3_300_ERA40", \
           "Z3_500_ERA40","U_200_ERA40","LHFLX_ERA40"/)
  jra25_vars = (/"LHFLX_JRA25","SHFLX_JRA25","PSL_JRA25","TREFHT_JRA25","PREH2O_JRA25","T_850_JRA25", \
                "T_200_JRA25","U_200_JRA25","Z3_300_JRA25","Z3_500_JRA25"/) 
  airs_vars = (/"T_850_AIRS","T_200_AIRS"/)
  laryea_vars = (/"FLNS_LARYEA","FSNS_LARYEA","SHFLX_LARYEA","QFLX_LARYEA"/)
  whoi_vars = (/"LHFLX_WHOI","QFLX_WHOI"/)
  ceres_vars = (/"FSNTOA_CERES","FSNTOAC_CERES","FLUT_CERES","FLUTC_CERES", \
                "LWCF_CERES","SWCF_CERES","ALBEDO_CERES","ALBEDOC_CERES"/)
  ceres2_vars = (/"FSNTOA_CERES-EBAF","FSNTOAC_CERES-EBAF","FLUT_CERES-EBAF","FLUTC_CERES-EBAF", \
                "LWCF_CERES-EBAF","SWCF_CERES-EBAF","ALBEDO_CERES-EBAF","ALBEDOC_CERES-EBAF"/)

  had_vars = (/"SST_HADISST","ICEFRAC_HADISST"/)
  leg_vars = (/"TREFHT_LEGATES","PRECT_LEGATES"/)
  will_vars = (/"TREFHT_WILLMOTT"/)
  gpcp_vars = (/"PRECT_GPCP"/)
  xa_vars = (/"PRECT_XA"/)
  ssmiice_vars = (/"ICEFRAC_SSMI"/)
  ssmi_vars = (/"PREH2O_SSMI","PRECT_SSMI"/)
  uwisc_vars = (/"TGCLDLWP_UWISC"/)
  trmm_vars = (/"PRECT_TRMM"/)
  nvap_vars = (/"PREH2O_NVAP","TGCLDLWP_NVAP"/)
  isccp_vars =(/"CLDHGH_ISCCP","CLDLOW_ISCCP","CLDMED_ISCCP","CLDTOT_ISCCP", \
                "CLDHGH_VISIR","CLDLOW_VISIR","CLDMED_VISIR","CLDTOT_VISIR"/)
  isccpFD_vars = (/"FLDS_ISCCP","FSDS_ISCCP","FLNS_ISCCP","FSNS_ISCCP"/)
  isccpcosp_vars = (/"CLDTOT_ISCCPCOSP","CLDLOW_ISCCPCOSP", \
                     "CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP", \
                     "CLDTHICK_ISCCPCOSP","MEANCLDALB_ISCCPCOSP", \
                     "MEANPTOP_ISCCPCOSP","MEANTTOP_ISCCPCOSP"/) ; BRH
  misrcosp_vars = (/"CLDTOT_MISR","CLDLOW_MISR","CLDMED_MISR", \
                    "CLDHGH_MISR","CLDTHICK_MISR"/) ; BRH
  modiscosp_vars = (/"CLDTOT_MODIS","CLDTHICK_MODIS", \
                     "CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS", \
                     "CLWMODIS","CLIMODIS","IWPMODIS","LWPMODIS", \
                     "REFFCLIMODIS","REFFCLWMODIS", \
                     "TAUILOGMODIS","TAUWLOGMODIS","TAUTLOGMODIS", \                                 "TAUIMODIS","TAUWMODIS","TAUTMODIS", \
                     "PCTMODIS"/) ; BRH
  calipsocosp_vars = (/"CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL"/) ; BRH
  cloudsatcosp_vars = (/"CLDTOT_CS2","CLDTOT_CS2"/) ; BRH
  obsvars=(/"ICEFRAC_HADISST","ICEFRAC_SSMI","PRECT_GPCP","SST_HADISST", \
        "CLDHGH_ISCCP","CLDLOW_ISCCP","CLDMED_ISCCP","CLDTOT_ISCCP", \
        "CLDHGH_VISIR","CLDLOW_VISIR","CLDMED_VISIR","CLDTOT_VISIR", \
        "PRECT_XA","PREH2O_NVAP","LWCF_ERBE","SWCF_ERBE","TGCLDLWP_NVAP", \
        "FSNTOA_ERBE","FSNTOAC_ERBE","FLUT_ERBE","FLUTC_ERBE","RESTOA_ERBE", \
        "TREFHT_WILLMOTT","PRECT_TRMM","PRECT_SSMI","PREH2O_SSMI", \
        "TGCLDLWP_SSMI","PRECT_LEGATES","TREFHT_LEGATES", \
        "PSL_MERRA","TS_MERRA","PREH2O_MERRA","T_850_MERRA", \
        "T_200_MERRA","U_200_MERRA","Z3_300_MERRA","Z3_500_MERRA", \
        "PREH2O_ERAI","T_850_ERAI","T_200_ERAI","Z3_300_ERAI", \
        "Z3_500_ERAI","U_200_ERAI", \
        "FLDS_ISCCP","FSDS_ISCCP","FLNS_ISCCP","FSNS_ISCCP","PREH2O_ERA40", \
        "T_850_ERA40","T_200_ERA40","Z3_300_ERA40", \
        "Z3_500_ERA40","U_200_ERA40","LHFLX_ERA40", \
        "T_850_AIRS","T_200_AIRS", \
        "FLNS_LARYEA","FSNS_LARYEA","SHFLX_LARYEA","QFLX_LARYEA", \
        "LHFLX_WHOI","QFLX_WHOI", \
        "FSNTOA_CERES","FSNTOAC_CERES","FLUT_CERES","FLUTC_CERES", \
        "LWCF_CERES","SWCF_CERES","ALBEDO_CERES","ALBEDOC_CERES", \
        "FSNTOA_CERES-EBAF","FSNTOAC_CERES-EBAF","FLUT_CERES-EBAF","FLUTC_CERES-EBAF", \
        "LWCF_CERES-EBAF","SWCF_CERES-EBAF","ALBEDO_CERES-EBAF","ALBEDOC_CERES-EBAF", \
        "LHFLX_JRA25","SHFLX_JRA25","PSL_JRA25","TREFHT_JRA25","PREH2O_JRA25","T_850_JRA25", \
        "T_200_JRA25","U_200_JRA25","Z3_300_JRA25","Z3_500_JRA25", \
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
        "CLDTOT_CS2", "TGCLDLWP_UWISC"/) ; BRH


; corresponding model variables
  vars=(/"ICEFRAC","ICEFRAC","PRECT","SST","CLDHGH","CLDLOW","CLDMED", \
      "CLDTOT","CLDHGH","CLDLOW","CLDMED","CLDTOT","PRECT","PREH2O","LWCF", \
      "SWCF","TGCLDLWP_OCEAN","FSNTOA","FSNTOAC","FLUT","FLUTC","RESTOA", \
      "TREFHT_LAND","PRECT","PRECT_OCEAN","PREH2O_OCEAN","TGCLDLWP_OCEAN", \
      "PRECT","TREFHT","PSL","TS","PREH2O","T_850","T_200","U_200", \
      "Z3_300","Z3_500","PREH2O","T_850","T_200","Z3_300","Z3_500","U_200", \
      "FLDS","FSDS","FLNS","FSNS","PREH2O","T_850", \
      "T_200","Z3_300","Z3_500","U_200","LHFLX", \
      "T_850","T_200", \
      "FLNS","FSNS","SHFLX","QFLX",\
      "LHFLX","QFLX",\
      "FSNTOA","FSNTOAC","FLUT","FLUTC","LWCF","SWCF","ALBEDO","ALBEDOC", \
      "FSNTOA","FSNTOAC","FLUT","FLUTC","LWCF","SWCF","ALBEDO","ALBEDOC", \
      "LHFLX","SHFLX","PSL","TREFHT","PREH2O","T_850", \
      "T_200","U_200","Z3_300","Z3_500", \
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
      "CLDTOT_CS2", "TGCLDLWP_OCEAN"/) ; BRH
else
; model-to-model comparisons
  vars = (/"CHI_200","CLDHGH","CLDLOW","CLDMED","CLDTOT","EKE_850","EP", \
           "FLDS","FLNS","FLNSC","FLNT","FLNTC","FSDS","FSNS","FSNSC", \
           "FSNT","FSNTC","ICEFRAC","LHFLX","LWCF","PBLH","PRECT","PREH2O", \
           "PSI_200","PSL","QFLX","RESSURF","SHFLX","SOLIN","SWCF", \
           "T_200","T_850","TGCLDIWP","TGCLDLWP","TREFHT","TS","U_200", \
           "VT_850","Z3_300","Z3_500","SNOWHICE","SNOWHLND","PRECST", \
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
           "CLDTOT_CS2"/) ; BRH
end if
nvars = dimsizes(vars)

do i = 0, nvars-1      ; loop over variables

; CASE 1 IS MODEL
  do m = 0, 11         ; loop over months
    inptr = inptr1(m)
    if (isfilevar(inptr,"gw")) then
      gw1 = inptr->gw
    else
      lat1 = inptr->lat
      nlat1 = dimsizes(lat1)
      ;gw1 = latGauWgt(nlat1,"lat","gaussian_weights","none")
      gw1 = latRegWgt (lat1, "double", 0)   ; +++ hannay - regular grid 
      delete(lat1)
    end if

    ;print("=== "+obsvars(i))

    if (vars(i) .eq. "CHI_200") then
      A = get_CHI_200 (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "CLDHGH") then
      A = get_CLDHGH (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "CLDLOW") then
      A = get_CLDLOW (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "CLDMED") then
      A = get_CLDMED (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "CLDTOT") then
      A = get_CLDTOT (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "EKE_850") then
      A = get_EKE_850 (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "EP") then
      A = get_EP (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FLDS") then
      A = get_FLDS (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FLNS") then
      A = get_FLNS (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FLNSC") then
      A = get_FLNSC (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FLNT") then
      A = get_FLNT (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FLNTC") then
      A = get_FLNTC (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FLUT") then
      A = get_FLUT (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FLUTC") then
      A = get_FLUTC (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FSDS") then
      A = get_FSDS (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FSNS") then
      A = get_FSNS (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FSNSC") then
      A = get_FSNSC (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FSNT") then
      A = get_FSNT (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FSNTC") then
      A = get_FSNTC (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FSNTOA") then
      A = get_FSNTOA (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "FSNTOAC") then
      A = get_FSNTOAC (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "ICEFRAC") then
      if (isfilevar(inptr1(m),"ICEFRAC") .and. \
          isfilevar(inptr1(m),"OCNFRAC")) then 
        inptr = inptr1(m)
        A = get_ICEFRAC (inptr1(m),outptr1(m)) 
      else
        A = -999.
        continue
      end if
    end if
    if (vars(i) .eq. "LHFLX") then
      A = get_LHFLX (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "LWCF") then
      if (compare .eq. "OBS") then
        A = get_LWCFTOA (inptr1(m),outptr1(m))
      else
        A = get_LWCFTOM (inptr1(m),outptr1(m))
      end if
    end if
    if (vars(i) .eq. "PBLH") then
      A = get_PBLH (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "PRECST") then
      A = get_PRECST (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "PRECT") then
      A = get_PRECT (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "PRECT_OCEAN") then
      A = get_PRECT_OCEAN (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "PREH2O") then
      A = get_PREH2O (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "PREH2O_OCEAN") then
      A = get_PREH2O_OCEAN (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "PSI_200") then
      A = get_PSI_200 (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "PSL") then
      A = get_PSL (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "QFLX") then
      A = get_QFLX (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "RESSURF") then
      A = get_RESSURF (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "RESTOA") then
      A = get_RESTOA (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "SHFLX") then
      A = get_SHFLX (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "SNOWHICE") then
      A = get_SNOWHICE (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "SNOWHLND") then
      A = get_SNOWHLND (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "SOLIN") then
      A = get_SOLIN (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "SST") then
      A = get_SST (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "SWCF") then
      if (compare .eq. "OBS") then
        A = get_SWCFTOA (inptr1(m),outptr1(m))
      else
        A = get_SWCFTOM (inptr1(m),outptr1(m))
      end if
    end if
    if (vars(i) .eq. "T_200") then
      A = get_T_200 (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "T_850") then
      A = get_T_850 (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "TGCLDIWP") then
      A = get_TGCLDIWP (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "TGCLDLWP") then
      A = get_TGCLDLWP (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "TGCLDLWP_OCEAN") then
      A = get_TGCLDLWP_OCEAN (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "TREFHT") then
      A = get_TREFHT (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "TREFHT_LAND") then
      A = get_TREFHT_LAND (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "TS") then
      A = get_TS (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "U_200") then
      A = get_U_200 (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "VT_850") then
      A = get_VT_850 (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "Z3_300") then
      A = get_Z3_300 (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "Z3_500") then
      A = get_Z3_500 (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "ALBEDO") then
      A = get_ALBEDO (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "ALBEDOC") then
      A = get_ALBEDOC (inptr1(m),outptr1(m))
    end if
    if (vars(i) .eq. "CLDTOT_ISCCPCOSP") then
      A = get_CLDTOT_ISCCPCOSP (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDLOW_ISCCPCOSP") then
      A = get_CLDLOW_ISCCPCOSP (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDMED_ISCCPCOSP") then
      A = get_CLDMED_ISCCPCOSP (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDHGH_ISCCPCOSP") then
      A = get_CLDHGH_ISCCPCOSP (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDTHICK_ISCCPCOSP") then
      A = get_CLDTHICK_ISCCPCOSP (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "MEANPTOP_ISCCPCOSP") then
      A = get_MEANPTOP_ISCCPCOSP (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "MEANTTOP_ISCCPCOSP") then
      A = get_MEANTTOP_ISCCPCOSP (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "MEANCLDALB_ISCCPCOSP") then
      A = get_MEANCLDALB_ISCCPCOSP (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDTOT_MISR") then
      A = get_CLDTOT_MISR (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDLOW_MISR") then
      A = get_CLDLOW_MISR (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDMED_MISR") then
      A = get_CLDMED_MISR (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDHGH_MISR") then
      A = get_CLDHGH_MISR (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDTHICK_MISR") then
      A = get_CLDTHICK_MISR (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDTOT_MODIS") then
      A = get_CLDTOT_MODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDLOW_MODIS") then
      A = get_CLDLOW_MODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDMED_MODIS") then
      A = get_CLDMED_MODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDHGH_MODIS") then
      A = get_CLDHGH_MODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDTHICK_MODIS") then
      A = get_CLDTHICK_MODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLWMODIS") then
      A = get_CLWMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLIMODIS") then
      A = get_CLIMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "LWPMODIS") then
      A = get_LWPMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "IWPMODIS") then
      A = get_IWPMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "REFFCLWMODIS") then
      A = get_REFFCLWMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "REFFCLIMODIS") then
      A = get_REFFCLIMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "TAUTLOGMODIS") then
      A = get_TAUTLOGMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "TAUWLOGMODIS") then
      A = get_TAUWLOGMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "TAUILOGMODIS") then
      A = get_TAUILOGMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "TAUTMODIS") then
      A = get_TAUTMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "TAUWMODIS") then
      A = get_TAUWMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "TAUIMODIS") then
      A = get_TAUIMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "PCTMODIS") then
      A = get_PCTMODIS (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDTOT_CAL") then
      A = get_CLDTOT_CAL (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDLOW_CAL") then
      A = get_CLDLOW_CAL (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDMED_CAL") then
      A = get_CLDMED_CAL (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDHGH_CAL") then
      A = get_CLDHGH_CAL (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDTOT_CS2") then
      A = get_CLDTOT_CS2 (inptr1(m),outptr1(m))
    end if    
    if (vars(i) .eq. "CLDTOT_CS") then
      A = get_CLDTOT_CS (inptr1(m),outptr1(m))
    end if    

    if (any(A .eq. -999.)) then
      continue
    else

      if (vars(i).eq."ICEFRAC" .or. vars(i).eq."SNOWHICE" .or. \
          vars(i).eq."SNOWHLND" .or. vars(i).eq."PRECST") then
        if (vars(i).eq."ICEFRAC") then
          if (isfilevar(inptr1(m),"slat")) then ; finite volume lat/lon grid
            shmean(0,m) = iceareaFIX (A,0)
            nhmean(0,m) = iceareaFIX (A,1)
          else                                  ; gaussian lat/lon grid
            shmean(0,m) = iceareaGAU (A,0)
            nhmean(0,m) = iceareaGAU (A,1)
          end if
        end if
        if (vars(i).eq."PRECST") then
          shmean(0,m) = wgt_areaave(A({-90:-30},:),gw1({-90:-30}),1.,0) 
          nhmean(0,m) = wgt_areaave(A({30:90},:),gw1({30:90}),1.,0) 
        end if
        if (vars(i).eq."SNOWHICE") then
          shmean(0,m) = wgt_areaave(A({-90:-30},:),gw1({-90:-30}),1.,0) 
          nhmean(0,m) = wgt_areaave(A({30:90},:),gw1({30:90}),1.,0) 
        end if
        if (vars(i).eq."SNOWHLND") then
          shmean(0,m) = wgt_areaave(A({-90:-1},:),gw1({-90:-1}),1.,0) 
          nhmean(0,m) = wgt_areaave(A({1:90},:),gw1({1:90}),1.,0) 
        end if
      else
 

        if (compare.eq."OBS" .and. obsvars(i).eq."PRECT_TRMM") then
          ;printVarSummary(A({-38:38},:))
          ;printVarSummary(gw1({-38:38}))
          gblmean(0,m) = wgt_areaave(A({-38:38},:),gw1({-38:38}),1.,0)
        else
          gblmean(0,m) = wgt_areaave(A,gw1,1.,0)
        end if

      end if
    end if
    delete(gw1)
  end do       ; loop over month 


  if (any(A .eq. -999.)) then
    print(vars(i)+" not present in test model input")
    delete (A)
    continue
  else
    if (vars(i).eq."ICEFRAC" .or. vars(i).eq."SNOWHICE" .or. \
        vars(i).eq."SNOWHLND" .or. vars(i).eq."PRECST") then
      nhmean(0,12) = nhmean(0,0)       ; wrap around
      shmean(0,12) = shmean(0,0)       ; for plot
    else
      gblmean(0,12) = gblmean(0,0)
    end if
  end if

; CASE 2 IS OBS
  if (compare .eq. "OBS") then

    ;print("=====>"+obsvars(i))

    do m = 0, 11            ; loop over month
      if (any(obsvars(i) .eq. jra25_vars)) then
        inptr2 = ptr_jra25(m)
        case2 = "JRA25"
      end if
      if (any(obsvars(i) .eq. erai_vars)) then
        inptr2 = ptr_erai(m)
        case2 = "ERAI"
      end if
      if (any(obsvars(i) .eq. era40_vars)) then
        inptr2 = ptr_era40(m)
        case2 = "ERA40"
      end if
      if (any(obsvars(i) .eq. airs_vars)) then
        inptr2 = ptr_airs(m)
        case2 = "AIRS"
      end if
      if (any(obsvars(i) .eq. laryea_vars)) then
        inptr2 = ptr_laryea(m)
        case2 = "LARGE-YEAGER"
      end if
      if (any(obsvars(i) .eq. whoi_vars)) then
        inptr2 = ptr_whoi(m)
        case2 = "WHOI"
      end if
      if (any(obsvars(i) .eq. ceres_vars)) then
        inptr2 = ptr_ceres(m)
        case2 = "CERES"
      end if
      if (any(obsvars(i) .eq. ceres2_vars)) then
        inptr2 = ptr_ceres2(m)
        case2 = "CERES-EBAF"
      end if
      if (any(obsvars(i) .eq. erbe_vars)) then
        inptr2 = ptr_erbe(m)
        case2 = "ERBE"
      end if
      if (any(obsvars(i) .eq. gpcp_vars)) then
        inptr2 = ptr_gpcp(m)
        case2 = "GPCP"
      end if
      if (any(obsvars(i) .eq. had_vars)) then
        inptr2 = ptr_had(m)
        case2 = "HadISST"
      end if
      if (any(obsvars(i) .eq. isccp_vars)) then
        inptr2 = ptr_isccp(m)
        case2 = "ISCCP D2"
      end if
      if (any(obsvars(i) .eq. isccpFD_vars)) then
        inptr2 = ptr_isccpFD(m)
        case2 = "ISCCP FD"
      end if
      if (any(obsvars(i) .eq. leg_vars)) then
        inptr2 = ptr_leg(m)
        case2 = "LEGATES"
      end if
      if (any(obsvars(i) .eq. merra_vars)) then
        inptr2 = ptr_merra(m)
        case2 = "MERRA"
      end if
      if (any(obsvars(i) .eq. nvap_vars)) then
        inptr2 = ptr_nvap(m)
        case2 = "NVAP"
      end if
      if (any(obsvars(i) .eq. uwisc_vars)) then
        inptr2 = ptr_uwisc(m)
        case2 = "UWISC"
      end if
      if (any(obsvars(i) .eq. ssmi_vars)) then
        inptr2 = ptr_ssmi(m)
        case2 = "SSM/I"
      end if
      if (any(obsvars(i) .eq. ssmiice_vars)) then
        inptr2 = ptr_ssmiice(m)
        case2 = "SMMR & SSM/I"
      end if
      if (any(obsvars(i) .eq. trmm_vars)) then
        inptr2 = ptr_trmm(m)
        case2 = "TRMM"
      end if
      if (any(obsvars(i) .eq. will_vars)) then
        inptr2 = ptr_will(m)
        case2 = "WILLMOTT"
      end if
      if (any(obsvars(i) .eq. xa_vars)) then
        inptr2 = ptr_xa(m)
        case2 = "XIE-ARKIN"
      end if
      if (any(obsvars(i) .eq. isccpcosp_vars)) then
        inptr2 = ptr_isccpcosp(m)
        case2 = "ISCCP-COSP"
      end if
      if (any(obsvars(i) .eq. misrcosp_vars)) then
        inptr2 = ptr_misrcosp(m)
        case2 = "MISR L3 CTH-OD V5"
      end if
      if (any(obsvars(i) .eq. modiscosp_vars)) then
        inptr2 = ptr_modiscosp(m)
        case2 = "MODIS-COSP"
      end if
      if (any(obsvars(i) .eq. calipsocosp_vars)) then
        inptr2 = ptr_calipsocosp(m)
        case2 = "CALIPSO-GOCCP"
      end if
      if (any(obsvars(i) .eq. cloudsatcosp_vars)) then
        inptr2 = ptr_cloudsatcosp(m)
        case2 = "CLOUDSAT-COSP"
      end if

      if (isfilevar(inptr2,"gw")) then
        gw2 = inptr2->gw
      else
        lat2 = inptr2->lat
        nlat2 = dimsizes(lat2)
        ;gw2 = latGauWgt(nlat2,"lat","gaussian_weights","none")
        gw2 = latRegWgt (lat2, "double", 0)   ; +++ hannay - regular grid 
        delete(lat2)
      end if

      if (vars(i).eq."T_850" .or. vars(i).eq."T_200" .or. \
        vars(i).eq."U_200" .or. vars(i).eq."Z3_300" .or. \
        vars(i).eq."Z3_500" .or. vars(i).eq."TREFHT_LAND") then
        if (vars(i).eq."T_850") then
          B = inptr2->T(0,{850},:,:)
          B@long_name = "850mb temperature"
        end if
        if (vars(i).eq."T_200") then
          B = inptr2->T(0,{200},:,:)
          B@long_name = "200mb temperature"
        end if
        if (vars(i).eq."U_200") then
          B = inptr2->U(0,{200},:,:)
          B@long_name = "200mb zonal wind"
          B@units = "m/s"
        end if
        if (vars(i).eq."Z3_500") then
          B = inptr2->Z3(0,{500},:,:)
          B = (/B/100./)       ; convert to hectometers
          B@long_name = "500mb geop height"
          B@units = "hectometers"
        end if
        if (vars(i).eq."Z3_300") then
          B = inptr2->Z3(0,{300},:,:)
          B = (/B/100./)       ; convert to hectometers
          B@long_name = "300mb geop height"
          B@units = "hectometers"
        end if
        if (vars(i).eq."TREFHT_LAND") then
          B = inptr2->TREFHT_LAND   ; no time dimension
        end if
      else
        if (isfilevar(inptr2,obsvars(i))) then
          if (dimsizes(getfilevardimsizes(inptr2,obsvars(i))).eq.3) then
            B = inptr2->$obsvars(i)$(0,:,:)
          else
            B = inptr2->$obsvars(i)$
          end if
        else
           if (dimsizes(getfilevardimsizes(inptr2,vars(i))).eq.3) then
            B = inptr2->$vars(i)$(0,:,:)
          else
            B = inptr2->$vars(i)$
          end if
        end if
      end if
      
      if (vars(i) .eq. "ICEFRAC") then
        if (case2 .eq. "SMMR & SSM/I") then  ; 1x1 degree grid
          shmean(1,m) = iceareaFIX (B,0)
          nhmean(1,m) = iceareaFIX (B,1)
        else                                 ; gaussian grid
          shmean(1,m) = iceareaGAU (B,0)
          nhmean(1,m) = iceareaGAU (B,1)
        end if
;      print(obsvars(i))
;      print("obs nhmean= "+nhmean(1,m))
;      print("obs shmean= "+shmean(1,m))
      else
        if (obsvars(i).eq."PRECT_TRMM") then
          gblmean(1,m) = wgt_areaave(B({-38:38},:),gw2({-38:38}),1.,0)
        else
          gblmean(1,m) = wgt_areaave(B,gw2,1.,0)
        end if
      end if
      delete (gw2)

    end do       ; loop over month

    if (vars(i) .eq. "ICEFRAC") then
;     print("obs nhmean= "+avg(nhmean(1,0:11)))
;     print("obs shmean= "+avg(shmean(1,0:11)))
      nhmean(1,12) = nhmean(1,0)       ; wrap around
      shmean(1,12) = shmean(1,0)       ; for plot
    else
      gblmean(1,12) = gblmean(1,0)
    end if

; CASE 2 IS MODEL
  else
    do m = 0, 11            ; loop over month
      inptr = inptr2(m)
      if (isfilevar(inptr,"gw")) then
        gw2 = inptr->gw
      else
        lat2 = inptr->lat
        nlat2 = dimsizes(lat2)
        gw2 = latGauWgt(nlat2,"lat","gaussian_weights","none")
        delete(lat2)
      end if
      if (vars(i) .eq. "CHI_200") then
        B = get_CHI_200 (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "CLDHGH") then
        B = get_CLDHGH (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "CLDLOW") then
        B = get_CLDLOW (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "CLDMED") then
        B = get_CLDMED (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "CLDTOT") then
        B = get_CLDTOT (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "EKE_850") then
        B = get_EKE_850 (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "EP") then
        B = get_EP (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FLDS") then
        B = get_FLDS (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FLNS") then
        B = get_FLNS (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FLNSC") then
        B = get_FLNSC (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FLNT") then
        B = get_FLNT (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FLNTC") then
        B = get_FLNTC (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FLUT") then
        B = get_FLUT (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FLUTC") then
        B = get_FLUTC (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FSDS") then
        B = get_FSDS (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FSNS") then
        B = get_FSNS (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FSNSC") then
        B = get_FSNSC (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FSNT") then
        B = get_FSNT (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FSNTC") then
        B = get_FSNTC (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FSNTOA") then
        B = get_FSNTOA (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "FSNTOAC") then
        B = get_FSNTOAC (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "ICEFRAC") then
        if (isfilevar(inptr2(m),"ICEFRAC") .and. \
            isfilevar(inptr2(m),"OCNFRAC")) then 
          B = get_ICEFRAC (inptr2(m),outptr2(m)) 
        else
          B = -999.
          continue
        end if
      end if
      if (vars(i) .eq. "LHFLX") then
        B = get_LHFLX (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "LWCF") then
        if (compare .eq. "OBS") then
          B = get_LWCFTOA (inptr2(m),outptr2(m))
        else
          B = get_LWCFTOM (inptr2(m),outptr2(m))
        end if
      end if
      if (vars(i) .eq. "PBLH") then
        B = get_PBLH (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "PRECST") then
        B = get_PRECST (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "PRECT") then
        B = get_PRECT (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "PRECT_OCEAN") then
        B = get_PRECT_OCEAN (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "PREH2O") then
        B = get_PREH2O (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "PREH2O_OCEAN") then
        B = get_PREH2O_OCEAN (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "PSI_200") then
        B = get_PSI_200 (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "PSL") then
        B = get_PSL (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "QFLX") then
        B = get_QFLX (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "RESTOA") then
        B = get_RESTOA (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "RESSURF") then
        B = get_RESSURF (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "SHFLX") then
        B = get_SHFLX (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "SNOWHICE") then
        B = get_SNOWHICE (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "SNOWHLND") then
        B = get_SNOWHLND (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "SOLIN") then
        B = get_SOLIN (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "SST") then
        B = get_SST (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "SWCF") then
        if (compare .eq. "OBS") then
          B = get_SWCFTOA (inptr2(m),outptr2(m))
        else
          B = get_SWCFTOM (inptr2(m),outptr2(m))
        end if
      end if
      if (vars(i) .eq. "T_200") then
        B = get_T_200 (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "T_850") then
        B = get_T_850 (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "TGCLDIWP") then
        B = get_TGCLDIWP (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "TGCLDLWP") then
        B = get_TGCLDLWP (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "TGCLDLWP_OCEAN") then
        B = get_TGCLDLWP (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "TREFHT") then
        B = get_TREFHT (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "TREFHT_LAND") then
        B = get_TREFHT_LAND (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "TS") then
        B = get_TS (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "U_200") then
        B = get_U_200 (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "VT_850") then
        B = get_VT_850 (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "Z3_300") then
        B = get_Z3_300 (inptr2(m),outptr2(m))
      end if
      if (vars(i) .eq. "Z3_500") then
        B = get_Z3_500 (inptr2(m),outptr2(m))
      end if
;   BRH additions for COSP
;   ISCCP diagnostics
    if (vars(i) .eq. "CLDTOT_ISCCPCOSP") then
      B = get_CLDTOT_ISCCPCOSP (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDLOW_ISCCPCOSP") then
      B = get_CLDLOW_ISCCPCOSP (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDMED_ISCCPCOSP") then
      B = get_CLDMED_ISCCPCOSP (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDHGH_ISCCPCOSP") then
      B = get_CLDHGH_ISCCPCOSP (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDTHICK_ISCCPCOSP") then
      B = get_CLDTHICK_ISCCPCOSP (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "MEANPTOP_ISCCPCOSP") then
      B = get_MEANPTOP_ISCCPCOSP (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "MEANTTOP_ISCCPCOSP") then
      B = get_MEANTTOP_ISCCPCOSP (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "MEANCLDALB_ISCCPCOSP") then
      B = get_MEANCLDALB_ISCCPCOSP (inptr2(m),outptr2(m))
    end if    
;   MISR diagnostics
    if (vars(i) .eq. "CLDTOT_MISR") then
      B = get_CLDTOT_MISR (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDLOW_MISR") then
      B = get_CLDLOW_MISR (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDMED_MISR") then
      B = get_CLDMED_MISR (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDHGH_MISR") then
      B = get_CLDHGH_MISR (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDTHICK_MISR") then
      B = get_CLDTHICK_MISR (inptr2(m),outptr2(m))
    end if    
;   MODIS diagnostics
    if (vars(i) .eq. "CLDTOT_MODIS") then
      B = get_CLDTOT_MODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDLOW_MODIS") then
      B = get_CLDLOW_MODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDMED_MODIS") then
      B = get_CLDMED_MODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDHGH_MODIS") then
      B = get_CLDHGH_MODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDTHICK_MODIS") then
      B = get_CLDTHICK_MODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLWMODIS") then
      B = get_CLWMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLIMODIS") then
      B = get_CLIMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "LWPMODIS") then
      B = get_LWPMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "IWPMODIS") then
      B = get_IWPMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "REFFCLWMODIS") then
      B = get_REFFCLWMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "REFFCLIMODIS") then
      B = get_REFFCLIMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "TAUTLOGMODIS") then
      B = get_TAUTLOGMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "TAUWLOGMODIS") then
      B = get_TAUWLOGMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "TAUILOGMODIS") then
      B = get_TAUILOGMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "TAUTMODIS") then
      B = get_TAUTMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "TAUWMODIS") then
      B = get_TAUWMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "TAUIMODIS") then
      B = get_TAUIMODIS (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "PCTMODIS") then
      B = get_PCTMODIS (inptr2(m),outptr2(m))
    end if    
;   CALIPSO diagnostics
    if (vars(i) .eq. "CLDTOT_CAL") then
      B = get_CLDTOT_CAL (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDLOW_CAL") then
      B = get_CLDLOW_CAL (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDMED_CAL") then
      B = get_CLDMED_CAL (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDHGH_CAL") then
      B = get_CLDHGH_CAL (inptr2(m),outptr2(m))
    end if    
;   CLOUDSAT diagnostics
    if (vars(i) .eq. "CLDTOT_CS2") then
      B = get_CLDTOT_CS2 (inptr2(m),outptr2(m))
    end if    
    if (vars(i) .eq. "CLDTOT_CS") then
      B = get_CLDTOT_CS (inptr2(m),outptr2(m))
    end if    
;   end BRH additions

      if (any(B .eq. -999.)) then
        continue
      else
        if (vars(i).eq."ICEFRAC" .or. vars(i).eq."SNOWHICE" .or. \
            vars(i).eq."SNOWHLND" .or. vars(i).eq."PRECST") then
          if (vars(i).eq."ICEFRAC") then
            if (isfilevar(inptr2(m),"slat")) then ; finite volume lat/lon grid
              shmean(1,m) = iceareaFIX (B,0)
              nhmean(1,m) = iceareaFIX (B,1)
            else                                  ; gaussian lat/lon grid
              shmean(1,m) = iceareaGAU (B,0)
              nhmean(1,m) = iceareaGAU (B,1)
            end if
          end if
          if (vars(i).eq."PRECST") then
            shmean(1,m) = wgt_areaave(B({-90:-30},:),gw2({-90:-30}),1.,0) 
            nhmean(1,m) = wgt_areaave(B({30:90},:),gw2({30:90}),1.,0) 
          end if
          if (vars(i).eq."SNOWHICE") then
            shmean(1,m) = wgt_areaave(B({-90:-30},:),gw2({-90:-30}),1.,0) 
            nhmean(1,m) = wgt_areaave(B({30:90},:),gw2({30:90}),1.,0) 
          end if
          if (vars(i).eq."SNOWHLND") then
            shmean(1,m) = wgt_areaave(B({-90:-1},:),gw2({-90:-1}),1.,0) 
            nhmean(1,m) = wgt_areaave(B({1:90},:),gw2({1:90}),1.,0) 
          end if
        else
          gblmean(1,m) = wgt_areaave(B,gw2,1.,0)
        end if
      end if 

      delete(gw2)
    end do            ; loop over month

    if (any(B .eq. -999.)) then
      print(vars(i)+" not present in control model input")
      delete (B)
      continue
    else
      if (vars(i).eq."ICEFRAC" .or. vars(i).eq."SNOWHICE" .or. \
          vars(i).eq."SNOWHLND" .or. vars(i).eq."PRECST") then
        nhmean(1,12) = nhmean(1,0)      ; wrap around
        shmean(1,12) = shmean(1,0)      ; for plot
      else
        gblmean(1,12) = gblmean(1,0)
      end if
    end if
  end if
;-------------------------------------------------------------------------
  if (compare .eq. "OBS") then
    if (isvar("yrs_ave1")) then
      res@xyExplicitLegendLabels=(/case1+" ("+yrs_ave1+")",case2/)
    else
      res@xyExplicitLegendLabels=(/case1,case2/)
    end if
    if (color_type .eq. "COLOR") then
      if (vars(i).eq."ICEFRAC") then
        wksNP = gsn_open_wks(plot_type,wkdir+"set10_"+obsvars(i)+"_NP_obsc")
        wksSP = gsn_open_wks(plot_type,wkdir+"set10_"+obsvars(i)+"_SP_obsc")
      else
        wks = gsn_open_wks(plot_type,wkdir+"set10_"+obsvars(i)+"_obsc")
      end if
    else
      wks = gsn_open_wks(plot_type,wkdir+"set10_"+obsvars(i)+"_obs")
    end if
  else
    if (isvar("yrs_ave1") .and. isvar("yrs_ave2")) then
      res@xyExplicitLegendLabels=(/case1+" ("+yrs_ave1+")",case2+" ("+yrs_ave2+")"/)
    end if
    if (.not.isvar("yrs_ave1") .and. isvar("yrs_ave2")) then
      res@xyExplicitLegendLabels=(/case1,case2+" ("+yrs_ave2+")"/)
    end if
    if (isvar("yrs_ave1") .and. .not.isvar("yrs_ave2")) then
      res@xyExplicitLegendLabels=(/case1+" ("+yrs_ave1+")",case2/)
    end if
    if (.not.isvar("yrs_ave1") .and. .not.isvar("yrs_ave2")) then
      res@xyExplicitLegendLabels=(/case1,case2/)
    end if
    if (color_type .eq. "COLOR") then
      if (vars(i).eq."ICEFRAC" .or. vars(i).eq."SNOWHICE" .or. \
          vars(i).eq."SNOWHLND" .or. vars(i).eq."PRECST") then
        wksNP = gsn_open_wks(plot_type,wkdir+"set10_"+vars(i)+"_NP_c")
        wksSP = gsn_open_wks(plot_type,wkdir+"set10_"+vars(i)+"_SP_c")
      else
        wks = gsn_open_wks(plot_type,wkdir+"set10_"+vars(i)+"_c")
      end if
    else
      wks = gsn_open_wks(plot_type,wkdir+"set10_"+vars(i))
    end if
  end if
;-------------------------------------------------------------------------

  if (vars(i).eq."ICEFRAC" .or. vars(i).eq."SNOWHICE" .or. \
      vars(i).eq."SNOWHLND" .or. vars(i).eq."PRECST") then
    if (vars(i).eq."ICEFRAC") then
      res@tiYAxisString = "Area x 10~S~6~N~ km~S~2~N~"
      if (time_stamp .eq. "True") then
        res@gsnLeftString = "Northern Hemisphere Sea-ice area" 
        infoTimeStamp(wksNP,0.012,"DIAG Version: "+version)
        plotNP = gsn_csm_xy(wksNP,months,nhmean,res)
        res@gsnLeftString = "Southern Hemisphere Sea-ice area" 
        infoTimeStamp(wksSP,0.012,"DIAG Version: "+version)
        plotSP = gsn_csm_xy(wksSP,months,shmean,res)
      else
        res@gsnLeftString = "Northern Hemisphere Sea-ice area" 
        plotNP = gsn_csm_xy(wksNP,months,nhmean,res)
        res@gsnLeftString = "Southern Hemisphere Sea-ice area" 
        plotSP = gsn_csm_xy(wksSP,months,shmean,res)
      end if
    end if
    if (vars(i).eq."PRECST") then
      res@tiYAxisString = "mm/day"
      if (time_stamp .eq. "True") then
        res@gsnLeftString = "NH snowfall rate" 
        infoTimeStamp(wksNP,0.012,"DIAG Version: "+version)
        plotNP = gsn_csm_xy(wksNP,months,nhmean,res)
        res@gsnLeftString = "SH snowfall rate" 
        infoTimeStamp(wksSP,0.012,"DIAG Version: "+version)
        plotSP = gsn_csm_xy(wksSP,months,shmean,res)
      else
        res@gsnLeftString = "NH snowfall rate" 
        plotNP = gsn_csm_xy(wksNP,months,nhmean,res)
        res@gsnLeftString = "SH snowfall rate" 
        plotSP = gsn_csm_xy(wksSP,months,shmean,res)
      end if
    end if
    if (vars(i).eq."SNOWHICE") then
      res@tiYAxisString = "centimeters"
      if (time_stamp .eq. "True") then
        res@gsnLeftString = "NH depth of snow on seaice" 
        infoTimeStamp(wksNP,0.012,"DIAG Version: "+version)
        plotNP = gsn_csm_xy(wksNP,months,nhmean,res)
        res@gsnLeftString = "SH depth of snow on seaice" 
        infoTimeStamp(wksSP,0.012,"DIAG Version: "+version)
        plotSP = gsn_csm_xy(wksSP,months,shmean,res)
      else
        res@gsnLeftString = "NH depth of snow on seaice" 
        plotNP = gsn_csm_xy(wksNP,months,nhmean,res)
        res@gsnLeftString = "SH depth of snow on seaice" 
        plotSP = gsn_csm_xy(wksSP,months,shmean,res)
      end if
    end if
    if (vars(i).eq."SNOWHLND") then
      res@tiYAxisString = "centimeters"
      if (time_stamp .eq. "True") then
        res@gsnLeftString = "NH depth of snow on land" 
        infoTimeStamp(wksNP,0.012,"DIAG Version: "+version)
        plotNP = gsn_csm_xy(wksNP,months,nhmean,res)
        res@gsnLeftString = "SH depth of snow on land" 
        infoTimeStamp(wksSP,0.012,"DIAG Version: "+version)
        plotSP = gsn_csm_xy(wksSP,months,shmean,res)
      else
        res@gsnLeftString = "NH depth of snow on land" 
        plotNP = gsn_csm_xy(wksNP,months,nhmean,res)
        res@gsnLeftString = "SH depth of snow on land" 
        plotSP = gsn_csm_xy(wksSP,months,shmean,res)
      end if
    end if
  else
    res@tiYAxisString = A@units
    res@gsnLeftString = A@long_name 
    if (time_stamp .eq. "True") then
      infoTimeStamp(wks,0.012,"DIAG Version: "+version)
      plot = gsn_csm_xy(wks,months,gblmean,res)
    else
      plot = gsn_csm_xy(wks,months,gblmean,res)
    end if
  end if
  delete(A)
  delete(B)
end do      ; loop over variable

end
