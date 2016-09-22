; NCL script
; plot_surfaces_cons.ncl
; Mark Stevens Sept 2001
; Rich Neale Jan 2008
; Jan 2002: updated with significance tests
; Mar 2003: isccp fields
; Jan 2008: ERA40 reanalysis
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH added
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
load "$DIAG_CODE/funcs_surf_variance.ncl"
;********************************************************
begin

  compare    = getenv("COMPARE")
  color_type = getenv("COLORTYPE")
  rgb_file   = getenv("RGB_FILE")
  plot_type  = getenv("PLOTTYPE")
  season     = getenv("SEASON")
  version    = getenv("DIAG_VERSION")
  paleo      = getenv("PALEO")
  root       = getenv("WKDIR")
  time_stamp = getenv("TIMESTAMP")
  tick_marks = getenv("TICKMARKS")
  case_names = getenv("CASENAMES")
  ncdf_mode  = getenv("NCDF_MODE")
  infile1    = getenv("TEST_INPUT")     ; case1 climo input filename
  outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
  infile2    = getenv("CNTL_INPUT")     ; case2 climo input filename
  sig_plot   = getenv("SIG_PLOT")
  mg_micro   = getenv("MG_MICRO")

  if( (compare .eq. "OBS").and.(mg_micro.eq."0") )then
    print("Cannot select mg_micro when comparing with obs. Set mg_micro to 1")
    mg_micro = 1 
  end if
  
  if (compare .ne. "OBS") then
    outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
  end if
  
  if (sig_plot .eq. "True") then
    sig_lvl  = getenv("SIG_LVL")
    means1   = getenv("TEST_MEANS")     ; case1 means input filename
    varfile1 = getenv("TEST_VARIANCE")  ; case1 variances output filename
    means2   = getenv("CNTL_MEANS")     ; case2 means input filename
    varfile2 = getenv("CNTL_VARIANCE")  ; case2 variances output filename
    var_mode = getenv("VAR_MODE")
  end if

  if (paleo .eq. "True") then
    PALEO = True
    paleocoast1 = getenv("PALEOCOAST1")
    if (compare .eq. "USER") then
      paleocoast2 = getenv("PALEOCOAST2")
      diffs = getenv("DIFF_PLOTS")
      if (diffs .eq. "True") then
        DIFFS = True
      else
        DIFFS = False
      end if
    end if
  else
    PALEO = False
    DIFFS = True
  end if
    
  ; CASE 1 Model 
  inptr1 = addfile(infile1,"r")

  print("======="+infile1)  ; hannay

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
  if (sig_plot .eq. "True") then      ; significance plots
    meansptr1 = addfile(means1,"r")
    time1 = meansptr1->time   
    nt1 = dimsizes(time1)
    if (var_mode .eq. "write") then
      varptr1 = addfile(varfile1,"w")
    else
      varptr1 = addfile(varfile1,"c")
    end if
  end if
  if (isatt(inptr1,"yrs_averaged")) then
    yrs_ave1 = inptr1@yrs_averaged
  end if
    
  tmp = inptr1->lat             ; latitudes
  if (typeof(tmp).eq."double") then
    lat1 = dble2flt(tmp)
  else
    lat1 = tmp
  end if
  delete(tmp)
  nlat1 = dimsizes(lat1)       ; number of latitudes
  tmp = inptr1->lon            ; longitudes
  if (typeof(tmp).eq."double") then
    lon1 = dble2flt(tmp)
  else
    lon1 = tmp
  end if
  delete(tmp)
  nlon1 = dimsizes(lon1)       ; number of longitudes
;jt  gw1 = inptr1->gw              ; gaussian weights
  if (isfilevar(inptr1,"gw")) then
    gw1 = inptr1->gw 
  else
    if (isfilevar(inptr1,"wgt")) then
      gw1 = inptr1->wgt
    else 
      gw1temp = latRegWgt(lat1,"double",0)  ; no gw1 in file
      gw1 = gw1temp
      delete(gw1temp)
      gw1!0 = "lat"
      gw1&lat = lat1
    end if
  end if

; CASE 2 MODEL OR OBS
  if (compare .eq. "OBS") then
    ptr_cru = addfile(infile2+"/CRU_"+season+"_climo.nc","r")
    ptr_had = addfile(infile2+"/HadISST_CL_"+season+"_climo.nc","r")
    ptr_had_pi = addfile(infile2+"/HadISST_PI_"+season+"_climo.nc","r")
    ptr_had_pd = addfile(infile2+"/HadISST_PD_"+season+"_climo.nc","r")
    ptr_leg = addfile(infile2+"/LEGATES_"+season+"_climo.nc","r")
    ptr_will = addfile(infile2+"/WILLMOTT_"+season+"_climo.nc","r")
    ptr_gpcp = addfile(infile2+"/GPCP_"+season+"_climo.nc","r")
    ptr_precl = addfile(infile2+"/PRECL_"+season+"_climo.nc","r")
    ptr_merra = addfile(infile2+"/MERRA_"+season+"_climo.nc","r")
    ptr_erai = addfile(infile2+"/ERAI_"+season+"_climo.nc","r")
    ptr_era40 = addfile(infile2+"/ERA40_"+season+"_climo.nc","r")
    ptr_jra25 = addfile(infile2+"/JRA25_"+season+"_climo.nc","r")
    ptr_airs = addfile(infile2+"/AIRS_"+season+"_climo.nc","r")
    ptr_ceres_ebaf = addfile(infile2+"/CERES-EBAF_"+season+"_climo.nc","r")
    ptr_erbe = addfile(infile2+"/ERBE_"+season+"_climo.nc","r")
    ptr_xa = addfile(infile2+"/XIEARKIN_"+season+"_climo.nc","r")
    ptr_nvap = addfile(infile2+"/NVAP_"+season+"_climo.nc","r")
    ptr_whoi = addfile(infile2+"/WHOI_"+season+"_climo.nc","r")
    ptr_laryea = addfile(infile2+"/LARYEA_"+season+"_climo.nc","r")
    ptr_isccpD1 = addfile(infile2+"/ISCCPD1_"+season+"_climo.nc","r")
    ptr_isccpFD = addfile(infile2+"/ISCCPFD_"+season+"_climo.nc","r")
    ptr_isccp = addfile(infile2+"/ISCCP_"+season+"_climo.nc","r")
    ptr_ssmi = addfile(infile2+"/SSMI_"+season+"_climo.nc","r")
    ptr_uwisc = addfile(infile2+"/UWisc_LWP_"+season+"_climo.nc","r")
    ptr_trmm = addfile(infile2+"/TRMM_"+season+"_climo.nc","r")
    ptr_warren = addfile(infile2+"/WARREN_"+season+"_climo.nc","r")
    ptr_cloudsat = addfile(infile2+"/CLOUDSAT_"+season+"_climo.nc","r")
    ptr_isccpcosp = addfile(infile2+"/ISCCPCOSP_"+season+"_climo.nc","r")
    ptr_misrcosp = addfile(infile2+"/MISRCOSP_"+season+"_climo.nc","r")
    ptr_modiscosp = addfile(infile2+"/MODISCOSP_"+season+"_climo.nc","r")
    ptr_calipsocosp = addfile(infile2+"/CALIPSOCOSP_"+season+"_climo.nc","r")
    ptr_cloudsatcosp = addfile(infile2+"/CLOUDSATCOSP_"+season+"_climo.nc","r")
  else
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
   if (sig_plot .eq. "True") then      ; significance plots
     meansptr2 = addfile(means2,"r")
     time2 = meansptr2->time   
     nt2 = dimsizes(time2)
     if (var_mode .eq. "write") then
       varptr2 = addfile(varfile2,"w")
     else
       varptr2 = addfile(varfile2,"c")
     end if
   end if
   if (isatt(inptr2,"yrs_averaged")) then
     yrs_ave2 = inptr2@yrs_averaged
   end if
   tmp = inptr2->lat
   if (typeof(tmp).eq."double") then
     lat2 = dble2flt(tmp)
   else
     lat2 = tmp
   end if
   delete(tmp)
   nlat2 = dimsizes(lat2)
   tmp = inptr2->lon
   if (typeof(tmp).eq."double") then
     lon2 = dble2flt(tmp)
   else
     lon2 = tmp
   end if
   delete(tmp)
   nlon2 = dimsizes(lon2)
;jt   gw2 = inptr2->gw 
   if (isfilevar(inptr2,"gw")) then
     gw2 = inptr2->gw 
   else
     if (isfilevar(inptr2,"wgt")) then
       gw2 = inptr2->wgt
     else 
       gw2temp = latRegWgt(lat2,"double",0)  ; no gw2 in file
       gw2 = gw2temp
       delete(gw2temp)
       gw2!0 = "lat"
       gw2&lat = lat2
     end if
   end if
 end if
 
;************************************************
; define variables to plot
;************************************************
; model-to-obs comparisons 

if (compare .eq. "OBS") then

  cru_vars = (/"TREFHT_CRU"/)
  erai_vars = (/"PREH2O_ERAI","T_850_ERAI","T_200_ERAI", \
                 "Z3_300_ERAI","Z3_500_ERAI","U_200_ERAI", \
                 "PRECT_ERAI", "LHFLX_ERAI" /)
  era40_vars = (/"PREH2O_ERA40","T_850_ERA40","T_200_ERA40", \
                 "Z3_300_ERA40","Z3_500_ERA40","U_200_ERA40", \
                 "LHFLX_ERA40"/)
  jra25_vars = (/"SHFLX_JRA25","PSL_JRA25","TREFHT_JRA25","PREH2O_JRA25","T_850_JRA25", \
            "T_200_JRA25","U_200_JRA25","Z3_300_JRA25","Z3_500_JRA25","LHFLX_JRA25"/)
  airs_vars = (/"T_850_AIRS","T_200_AIRS"/)
  ceres_ebaf_vars = (/"FSNTOA_CERES-EBAF","FSNTOAC_CERES-EBAF","FLUT_CERES-EBAF","FLUTC_CERES-EBAF", \
                "LWCF_CERES-EBAF","SWCF_CERES-EBAF","ALBEDO_CERES-EBAF","ALBEDOC_CERES-EBAF"/)
  erbe_vars = (/"FSNTOA_ERBE","FSNTOAC_ERBE","FLUT_ERBE","FLUTC_ERBE", \
                "LWCF_ERBE","SWCF_ERBE"/)
  gpcp_vars = (/"PRECT_GPCP"/)
  precl_vars = (/"PRECT_PRECL"/)
  had_vars = (/"SST_HADISST"/)
  had_pi_vars = (/"SST_HADISST_PI"/)
  had_pd_vars = (/"SST_HADISST_PD"/)
  isccp_vars = (/"CLDHGH_ISCCP","CLDLOW_ISCCP","CLDMED_ISCCP","CLDTOT_ISCCP", \
                 "CLDHGH_VISIR","CLDLOW_VISIR","CLDMED_VISIR","CLDTOT_VISIR"/)
  isccpD1_vars = (/"MEANPTOP_ISCCP","MEANTTOP_ISCCP","MEANTAU_ISCCP", \
                   "TCLDAREA_ISCCP"/)
  isccpFD_vars = (/"FLDS_ISCCP","FLDSC_ISCCP","FSDS_ISCCP","FSDSC_ISCCP", \
                   "FSNS_ISCCP","FSNSC_ISCCP","FLNS_ISCCP","FLNSC_ISCCP", \
                   "SWCFSRF_ISCCP","LWCFSRF_ISCCP"/)
  leg_vars = (/"TREFHT_LEGATES","PRECT_LEGATES"/)
  merra_vars = (/"PSL_MERRA","PREH2O_MERRA","Z3_300_MERRA", "Z3_500_MERRA", "T_850_MERRA", \
                 "T_200_MERRA", "TS_MERRA", "U_200_MERRA"/)
  nvap_vars = (/"PREH2O_NVAP","TGCLDLWP_NVAP"/)
  whoi_vars = (/"LHFLX_WHOI","QFLX_WHOI"/)
  laryea_vars = (/"FLNS_LARYEA","FSNS_LARYEA","SHFLX_LARYEA","QFLX_LARYEA"/)
  ssmi_vars = (/"PREH2O_SSMI","PRECT_SSMI"/)
  uwisc_vars = (/"TGCLDLWP_UWISC"/)
  trmm_vars = (/"PRECT_TRMM"/)
  warren_vars = (/"CLDLOW_WARREN","CLDTOT_WARREN"/)
  cloudsat_vars = (/"CLDLOW_CLOUDSAT","CLDMED_CLOUDSAT","CLDHGH_CLOUDSAT","CLDTOT_CLOUDSAT"/)
  will_vars = (/"TREFHT_WILLMOTT","PRECIP_WILLMOTT"/)
  xa_vars = (/"PRECT_XA"/)
  isccpcosp_vars = (/"CLDTOT_ISCCPCOSP","CLDTHICK_ISCCPCOSP", \
                     "CLDLOW_ISCCPCOSP","CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP", \
                     "MEANPTOP_ISCCPCOSP","MEANCLDALB_ISCCPCOSP"/) 
  misrcosp_vars = (/"CLDTOT_MISR","CLDTHICK_MISR", \
                     "CLDLOW_MISR","CLDMED_MISR","CLDHGH_MISR"/) 
  modiscosp_vars = (/"CLDTOT_MODIS","CLDTHICK_MODIS", \
                     "CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS", \
                     "CLWMODIS","CLIMODIS","IWPMODIS","LWPMODIS", \
                     "REFFCLIMODIS","REFFCLWMODIS", \
                     "TAUILOGMODIS","TAUWLOGMODIS","TAUTLOGMODIS", \
                     "TAUIMODIS","TAUWMODIS","TAUTMODIS", \
                     "PCTMODIS"/) 
  calipsocosp_vars = (/"CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL"/) 
  cloudsatcosp_vars = (/"CLDTOT_CS2","CLDTOT_CS2"/) 


  ; contours definition (global)
  cntrs_FSNTOA=(/0,30,60,90,120,150,180,210,240,270,300,330,360,390,420/)
  dcntrs_FSNTOA=(/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/)  
  cntrs_FSNTOAC=(/0,25,50,75,100,125,150,175,200,240,280,320,360,400,440/)
  dcntrs_FSNTOAC=(/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/) 
  cntrs_FSDS=(/25,50,75,100,125,150,175,200,225,250,275,300,325,350,375/)
  dcntrs_FSDS=(/-90,-70,-50,-40,-30,-20,-10,0,10,20,30,40,50,70,90/) 
  cntrs_FSDSC=(/25,50,75,100,125,150,175,200,225,250,275,300,325,350,375/)
  dcntrs_FSDSC=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/) 
  cntrs_FSNS=(/0,25,50,75,100,125,150,175,200,220,240,260,280,300,320/) 
  dcntrs_FSNS=(/-100,-75,-50,-40,-30,-20,-10,0,10,20,30,40,50,75,100/)  
  cntrs_FSNSC=(/0,25,50,75,100,125,150,175,200,225,250,275,300,325,350/) 
  dcntrs_FSNSC=(/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/)      
  cntrs_FLUT=(/100,115,130,145,160,175,190,205,220,235,250,265,280,295,310/)
  dcntrs_FLUT=(/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/)  
  cntrs_FLDS=(/75,100,125,150,175,200,225,250,275,300,325,350,375,400,425/)
  dcntrs_FLDS=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/) 
  cntrs_FLDSC=(/75,100,125,150,175,200,225,250,275,300,325,350,375,400,425/)
  dcntrs_FLDSC=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/) 
  cntrs_FLNS=(/10,20,30,40,50,60,70,80,90,100,110,120,130,140,150/)    
  dcntrs_FLNS=(/-70,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,70/)      
  cntrs_FLNSC=(/50,60,70,75,80,85,90,100,110,120,130,140,160,180,200/)   
  dcntrs_FLNSC=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
  cntrs_FLUTC=(/120,135,150,165,180,195,210,225,240,255,270,280,290,300,310/)
  dcntrs_FLUTC=(/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/) 
  cntrs_LWCF=(/-45,-30,-20,-10,0,10,20,30,40,50,60,70,85,100,115/) 
  dcntrs_LWCF=(/-35,-30,-15,-10,-6,-4,-2, 0, 2,4,6,10,15,30,35/) 
  cntrs_SWCF=(/-170,-150,-135,-120,-105,-90,-75,-60,-45,-30,-15,0,15,30,45/)
  dcntrs_SWCF=(/-80,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,80/) 
  cntrs_SHFLX=(/-100,-75,-50,-25,-10,0,10,25,50,75,100,125,150,175,200/) 
  dcntrs_SHFLX=(/-100,-80,-60,-40,-20,-10,-5,0,5,10,20,40,60,80,100/)
  cntrs_LHFLX=(/0,15,30,60,90,120,150,180,210,240,270,300,330,360,390/) 
  dcntrs_LHFLX=(/-150,-120,-90,-60,-30,-20,-10,0,10,20,30,60,90,120,150/)
  cntrs_QFLX=(/0,.5,1,2,3,4,5,6,7,8,9,10,11,12,13/)      
  dcntrs_QFLX=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/) 
  cntrs_PRECT=(/.2,.5,1,2,3,4,5,6,7,8,9,10,12,14,17/)   
  dcntrs_PRECT=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/) 
  cntrs_PRECT_OCEAN = (/.2,.5,1,2,3,4,5,6,7,8,9,10,12,14,17/)     
  dcntrs_PRECT_OCEAN = (/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/)  
  cntrs_PRECIP_LAND=(/5,10,20,30,40,55,70,85,100,125,150,175,200,250,300/)
  dcntrs_PRECIP_LAND=(/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/)
  cntrs_PSL=(/984,988,992,996,1000,1004,1008,1012,1016,1020,1024,1028,1032,1036,1040/) 
  dcntrs_PSL=(/-15,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,15/)
  cntrs_TS=(/210,220,230,240,250,260,270,275,280,285,290,295,300,305,310/)
  dcntrs_TS= (/-5,-4,-3,-2,-1,-.5,-.2,0,.2,.5,1,2,3,4,5/) 
  cntrs_TREFHT=(/210,220,230,240,250,260,270,275,280,285,290,295,300,305,310/)
  dcntrs_TREFHT= (/-5,-4,-3,-2,-1,-.5,-.2,0,.2,.5,1,2,3,4,5/) 
  cntrs_PREH2O=(/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/) 
  dcntrs_PREH2O=(/-12,-9,-6,-4,-3,-2,-1,0,1,2,3,4,6,9,12/)
  cntrs_PREH2O_OCEAN = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)       
  dcntrs_PREH2O_OCEAN = (/-12,-9,-6,-4,-3,-2,-1,0,1,2,3,4,6,9,12/)
  cntrs_T_850=(/230,235,240,245,250,255,260,265,270,275,280,285,290,295,300/)
  dcntrs_T_850=(/-8,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,8/)  ; 
  cntrs_U_200=(/-20,-15,-10,-5,0,5,10,15,20,25,30,40,50,60,70/) 
  dcntrs_U_200=(/-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28/)
  cntrs_Z3_500=(/48,49,50,51,52,53,54,55,56,57,58,58.5,59,59.5,60/)  
  dcntrs_Z3_500=(/-1.2,-1,-.8,-.6,-.4,-.2,-.1,0,.1,.2,.4,.6,.8,1,1.2/)
  cntrs_Z3_300=(/83,84,85,86,87,88,89,90,91,92,93,94,95,96,97/) 
  dcntrs_Z3_300=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
  cntrs_T_200=(/190,193,196,199,202,205,208,211,214,217,220,223,226,229,232/)
  dcntrs_T_200=(/-10,-8,-6,-4,-3,-2,-1,0,1,2,3,4,6,8,10/)  
  cntrs_TGCLDLWP=(/10,30,50,70,90,130,170,210,250,290,330,360,380,400,420/) 
  dcntrs_TGCLDLWP=(/-200,-150,-100,-80,-60,-40,-20,0,20,40,60,80,100,150,200/)
  cntrs_EP=(/-10,-8,-6,-4,-3,-2,-1,0,1,2,3,4,6,8,10/) 
  dcntrs_EP=(/-7,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,7/) 
  cntrs_SST = (/-1,0,1,3,6,9,12,15,18,20,22,24,26,28,29/) 
  dcntrs_SST = (/-5,-4,-3,-2,-1,-.5,-.2,0,.2,.5,1,2,3,4,5/) 
  cntrs_CLDHGH=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) 
  dcntrs_CLDHGH=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDLOW=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) 
  dcntrs_CLDLOW=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDMED=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) 
  dcntrs_CLDMED=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDTOT=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) 
  dcntrs_CLDTOT=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_TCLDAREA=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) 
  dcntrs_TCLDAREA=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  dcntrs_TCLDAREA=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_MEANPTOP=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/)
  dcntrs_MEANPTOP=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200,250,300/) 
  cntrs_MEANTTOP=(/200,206,212,218,224,231,238,245,252,259,266,272,278,284,290/)
  dcntrs_MEANTTOP=(/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/) 
  cntrs_MEANTAU=(/2,4,6,8,10,12,14,16,18,20,25,30,35,40,45/)
  dcntrs_MEANTAU=(/-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/) 
  cntrs_SWCFSRF=(/-195,-180,-165,-150,-135,-120,-105,-90,-75,-60,-45,-30,-15,-5,0/)
  dcntrs_SWCFSRF=(/-80,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,80/) 
  cntrs_LWCFSRF=(/5,10,15,20,25,30,40,50,60,70,80,90,95,100,105/)   
  dcntrs_LWCFSRF=(/-35,-30,-15,-10,-6,-4,-2, 0, 2,4,6,10,15,30,35/) 
  cntrs_ALBEDO=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/) 
  dcntrs_ALBEDO=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
  cntrs_ALBEDOC = (/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/)   
  dcntrs_ALBEDOC = (/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
  cntrs_TTRP =(/186,188,190,192,194,196,198,200,202,204,206,208,210,212,214/)
  dcntrs_TTRP =(/-8,-6,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,6,8/)
  cntrs_CLDTOT_COSP=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  
  dcntrs_CLDTOT_COSP=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)   
  cntrs_CLDLOW_COSP = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)  
  dcntrs_CLDLOW_COSP = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)    
  cntrs_CLDMED_COSP = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)  
  dcntrs_CLDMED_COSP = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)    
  cntrs_CLDHGH_COSP = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)  
  dcntrs_CLDHGH_COSP = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)    
  cntrs_CLDTHICK_COSP = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)  
  dcntrs_CLDTHICK_COSP = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)    
  cntrs_MEANPTOP_COSP=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/) 
  dcntrs_MEANPTOP_COSP=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200,250,300/)
  cntrs_MEANCLDALB_COSP=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/)
  dcntrs_MEANCLDALB_COSP=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
  cntrs_CLWMODIS=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  
  dcntrs_CLWMODIS=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)   
  cntrs_CLIMODIS=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  
  dcntrs_CLIMODIS=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)   
  cntrs_IWPMODIS = (/50,100,150,200,250,300,350,400,450,500,550,600,650,700,800/) ;
  dcntrs_IWPMODIS = (/-700,-600,-500,-400,-300,-200,-100,0,100,200,300,400,500,600,700/)
  cntrs_LWPMODIS = (/40,80,120,160,200,240,280,320,360,400,440,480,520,560,600/) 
  dcntrs_LWPMODIS = (/-200,-150,-100,-80,-60,-40,-20,0,20,40,60,80,100,150,200/)
  cntrs_REFFCLIMODIS = (/5,10,15,20,25,30,35,40,45,50,55,60,65,70,75/) 
  dcntrs_REFFCLIMODIS = (/-70,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70/)
  cntrs_REFFCLWMODIS = (/1.5,3.0,4.5,6.0,7.5,9.0,10.5,12.0,13.5,15.0,16.5,18.0,19.5,21.0,22.5/) 
  dcntrs_REFFCLWMODIS = (/-10.5,-9.0,-7.5,-6.0,-4.5,-3.0,-1.5,0,1.5,3.0,4.5,6.0,7.5,9.0,10.5/)
  cntrs_TAU = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/) 
  dcntrs_TAU = (/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
  cntrs_PCTMODIS=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/) 
  dcntrs_PCTMODIS=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200,250,300/)
 
  ; observations: list of variables to plot
  obsvars = (/"PSL_MERRA", "PREH2O_MERRA", "T_850_MERRA", "T_200_MERRA", "TS_MERRA", "U_200_MERRA","Z3_300_MERRA","Z3_500_MERRA", \
              "FSNTOA_ERBE","FLUT_ERBE","PRECT_XA","TREFHT_LEGATES", \
              "PREH2O_NVAP", "PREH2O_ERAI","PREH2O_ERA40", \
              "LWCF_ERBE","SWCF_ERBE", \
              "T_850_ERAI","T_850_ERA40", \
              "U_200_ERAI","U_200_ERA40", \
              "Z3_500_ERAI","Z3_500_ERA40","Z3_300_ERAI","Z3_300_ERA40", \
              "TREFHT_WILLMOTT", "PRECT_TRMM", \
              "T_200_ERAI","T_200_ERA40", \
              "PRECT_SSMI", "PREH2O_SSMI", \
              "TGCLDLWP_SSMI","TREFHT_CRU","PRECT_GPCP", \
              "PRECT_LEGATES","TGCLDLWP_NVAP","EP_ERAI","FSNTOAC_ERBE", \
              "FLUTC_ERBE","SST_HADISST","CLDHGH_ISCCP","CLDLOW_ISCCP", \
              "CLDMED_ISCCP","CLDTOT_ISCCP","CLDLOW_WARREN","CLDTOT_WARREN", \
              "PRECIP_WILLMOTT","LHFLX_ERAI","LHFLX_ERA40","QFLX_ERAI","MEANPTOP_ISCCP", \
              "MEANTTOP_ISCCP","MEANTAU_ISCCP","TCLDAREA_ISCCP", \
              "FLDS_ISCCP","FLDSC_ISCCP","FSDS_ISCCP","FSDSC_ISCCP", \
              "FSNS_ISCCP","FSNSC_ISCCP","FLNS_ISCCP","FLNSC_ISCCP", \
              "SWCFSRF_ISCCP","LWCFSRF_ISCCP", \
              "TTRP_ERAI", \
              "PRECT_PRECL","CLDHGH_VISIR","CLDLOW_VISIR","CLDMED_VISIR", \
              "CLDTOT_VISIR","TCLDAREA_MODIS","LHFLX_WHOI","QFLX_WHOI", \
              "FLNS_LARYEA","FSNS_LARYEA","SHFLX_LARYEA","QFLX_LARYEA", \
              "CLDLOW_CLOUDSAT","CLDMED_CLOUDSAT","CLDHGH_CLOUDSAT","CLDTOT_CLOUDSAT", \
              "T_850_AIRS","T_200_AIRS",\
              "FSNTOA_CERES-EBAF","FSNTOAC_CERES-EBAF","FLUT_CERES-EBAF","FLUTC_CERES-EBAF", \
              "LWCF_CERES-EBAF","SWCF_CERES-EBAF","ALBEDO_CERES-EBAF","ALBEDOC_CERES-EBAF" ,\
              "SHFLX_JRA25","PSL_JRA25","TREFHT_JRA25","PREH2O_JRA25","T_850_JRA25", \
              "T_200_JRA25","U_200_JRA25","Z3_300_JRA25","Z3_500_JRA25","LHFLX_JRA25", \
              "SST_HADISST_PI","SST_HADISST_PD", \
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
              "CLDTOT_CS2", "TGCLDLWP_UWISC", \
              "PRECT_ERAI", "LHFLX_ERAI"/) 
  

; corresponding model variables
  vars = (/"PSL","PREH2O", "T_850","T_200", "TS","U_200","Z3_300", "Z3_500",  \
           "FSNTOA","FLUT","PRECT","TREFHT", \
           "PREH2O","PREH2O","PREH2O",\
           "LWCF","SWCF", \
           "T_850","T_850", \
           "U_200","U_200", \
           "Z3_500","Z3_500","Z3_300","Z3_300", \
           "TREFHT_LAND", "PRECT", \
           "T_200", "T_200", \
           "PRECT_OCEAN","PREH2O_OCEAN", \
           "TGCLDLWP_OCEAN","TREFHT_LAND","PRECT","PRECT","TGCLDLWP_OCEAN", \
           "EP","FSNTOAC","FLUTC","SST","CLDHGH","CLDLOW","CLDMED","CLDTOT", \
           "CLDLOW","CLDTOT","PRECIP_LAND","LHFLX","LHFLX","QFLX","MEANPTOP", \
           "MEANTTOP","MEANTAU","TCLDAREA","FLDS","FLDSC","FSDS","FSDSC", \
           "FSNS","FSNSC","FLNS","FLNSC", \
           "SWCFSRF","LWCFSRF",\
           "TTRP","PRECT_LAND","CLDHGH","CLDLOW","CLDMED","CLDTOT","TCLDAREA", \
           "LHFLX","QFLX","FLNS","FSNS","SHFLX","QFLX","CLDLOW","CLDMED","CLDHGH","CLDTOT", \
           "T_850","T_200","FSNTOA","FSNTOAC","FLUT","FLUTC","LWCF","SWCF","ALBEDO","ALBEDOC", \
           "SHFLX","PSL","TREFHT","PREH2O","T_850", \
           "T_200","U_200","Z3_300","Z3_500","LHFLX",\
           "SST","SST", \
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
           "CLDTOT_CS2", "TGCLDLWP_OCEAN", \
           "PRECT", "LHFLX" /) 

; define contour intervals
  cntrs = (/cntrs_PSL, cntrs_PREH2O, cntrs_T_850,  cntrs_T_200, cntrs_TS,cntrs_U_200, cntrs_Z3_300, cntrs_Z3_500,\
           cntrs_FSNTOA, cntrs_FLUT, cntrs_PRECT, cntrs_TREFHT, \
           cntrs_PREH2O, cntrs_PREH2O, \
           cntrs_PREH2O, cntrs_LWCF, cntrs_SWCF, \
           cntrs_T_850, cntrs_T_850, \
           cntrs_U_200, cntrs_U_200, \
           cntrs_Z3_500, cntrs_Z3_500, cntrs_Z3_300, cntrs_Z3_300, \
           cntrs_TREFHT, cntrs_PRECT, \
           cntrs_T_200, cntrs_T_200, \
           cntrs_PRECT_OCEAN, cntrs_PREH2O_OCEAN, \
           cntrs_TGCLDLWP, cntrs_TREFHT, cntrs_PRECT, cntrs_PRECT, cntrs_TGCLDLWP, \
           cntrs_EP, cntrs_FSNTOAC, cntrs_FLUTC, cntrs_SST, cntrs_CLDHGH, cntrs_CLDLOW, cntrs_CLDMED, cntrs_CLDTOT, \
           cntrs_CLDLOW, cntrs_CLDTOT, cntrs_PRECIP_LAND, cntrs_LHFLX, cntrs_LHFLX, cntrs_QFLX, cntrs_MEANPTOP, \
           cntrs_MEANTTOP, cntrs_MEANTAU, cntrs_TCLDAREA, cntrs_FLDS, cntrs_FLDSC, cntrs_FSDS, cntrs_FSDSC, \
           cntrs_FSNS, cntrs_FSNSC, cntrs_FLNS, cntrs_FLNSC, \
           cntrs_SWCFSRF, cntrs_LWCFSRF,  \
           cntrs_TTRP, cntrs_PRECIP_LAND, cntrs_CLDHGH, cntrs_CLDLOW, cntrs_CLDMED, cntrs_CLDTOT, cntrs_TCLDAREA, \
           cntrs_LHFLX, cntrs_QFLX, cntrs_FLNS, cntrs_FSNS, cntrs_SHFLX, cntrs_QFLX, cntrs_CLDLOW, cntrs_CLDMED, cntrs_CLDHGH, cntrs_CLDTOT, \
           cntrs_T_850, cntrs_T_200, cntrs_FSNTOA, cntrs_FSNTOAC, cntrs_FLUT, cntrs_FLUTC, cntrs_LWCF, cntrs_SWCF, cntrs_ALBEDO, cntrs_ALBEDOC, \
           cntrs_SHFLX, cntrs_PSL, cntrs_TREFHT, cntrs_PREH2O, cntrs_T_850, \
           cntrs_T_200, cntrs_U_200, cntrs_Z3_300, cntrs_Z3_500, cntrs_LHFLX, \
           cntrs_SST, cntrs_SST, \
           cntrs_CLDTOT_COSP, cntrs_CLDLOW_COSP, \
           cntrs_CLDMED_COSP, cntrs_CLDHGH_COSP, \
           cntrs_CLDTHICK_COSP, \
           cntrs_MEANPTOP_COSP, cntrs_MEANCLDALB_COSP, \
           cntrs_CLDTOT_COSP, cntrs_CLDLOW_COSP, cntrs_CLDMED_COSP, cntrs_CLDHGH_COSP, \
           cntrs_CLDTHICK_COSP, \
           cntrs_CLDTOT_COSP, cntrs_CLDLOW_COSP, cntrs_CLDMED_COSP, cntrs_CLDHGH_COSP, \
           cntrs_CLDTHICK_COSP, \
           cntrs_CLWMODIS, cntrs_CLIMODIS, \
           cntrs_IWPMODIS, cntrs_LWPMODIS, \
           cntrs_REFFCLIMODIS, cntrs_REFFCLWMODIS, \
           cntrs_TAU, cntrs_TAU, cntrs_TAU, \
           cntrs_TAU, cntrs_TAU, cntrs_TAU, \
           cntrs_PCTMODIS, \
           cntrs_CLDTOT_COSP, cntrs_CLDLOW_COSP, cntrs_CLDMED_COSP, cntrs_CLDHGH_COSP, \
           cntrs_CLDTOT_COSP, cntrs_TGCLDLWP, \
           cntrs_PRECT, cntrs_LHFLX/) 


  dcntrs = (/dcntrs_PSL, dcntrs_PREH2O, dcntrs_T_850, dcntrs_T_200, dcntrs_TS, dcntrs_U_200, dcntrs_Z3_300, dcntrs_Z3_300,\
             dcntrs_FSNTOA, dcntrs_FLUT, dcntrs_PRECT, dcntrs_TREFHT, \
             dcntrs_PREH2O, dcntrs_PREH2O, dcntrs_PREH2O, \
           dcntrs_LWCF, dcntrs_SWCF, \
           dcntrs_T_850, dcntrs_T_850, \
           dcntrs_U_200, dcntrs_U_200, \
           dcntrs_Z3_500, dcntrs_Z3_500,  dcntrs_Z3_300, dcntrs_Z3_300, \
           dcntrs_TREFHT, dcntrs_PRECT, \
           dcntrs_T_200, dcntrs_T_200, \
           dcntrs_PRECT_OCEAN, dcntrs_PREH2O_OCEAN, \
           dcntrs_TGCLDLWP, dcntrs_TREFHT, dcntrs_PRECT, dcntrs_PRECT, dcntrs_TGCLDLWP, \
           dcntrs_EP, dcntrs_FSNTOAC, dcntrs_FLUTC, dcntrs_SST, dcntrs_CLDHGH, dcntrs_CLDLOW, dcntrs_CLDMED, dcntrs_CLDTOT, \
           dcntrs_CLDLOW, dcntrs_CLDTOT, dcntrs_PRECIP_LAND, dcntrs_LHFLX, dcntrs_LHFLX, dcntrs_QFLX, dcntrs_MEANPTOP, \
           dcntrs_MEANTTOP, dcntrs_MEANTAU, dcntrs_TCLDAREA, dcntrs_FLDS, dcntrs_FLDSC, dcntrs_FSDS, dcntrs_FSDSC, \
           dcntrs_FSNS, dcntrs_FSNSC, dcntrs_FLNS, dcntrs_FLNSC, \
           dcntrs_SWCFSRF, dcntrs_LWCFSRF,  \
           dcntrs_TTRP, dcntrs_PRECIP_LAND, dcntrs_CLDHGH, dcntrs_CLDLOW, dcntrs_CLDMED, dcntrs_CLDTOT, dcntrs_TCLDAREA, \
           dcntrs_LHFLX, dcntrs_QFLX, dcntrs_FLNS, dcntrs_FSNS, dcntrs_SHFLX, dcntrs_QFLX, dcntrs_CLDLOW, dcntrs_CLDMED, dcntrs_CLDHGH, dcntrs_CLDTOT, \
           dcntrs_T_850, dcntrs_T_200, dcntrs_FSNTOA, dcntrs_FSNTOAC, dcntrs_FLUT, dcntrs_FLUTC, dcntrs_LWCF, dcntrs_SWCF, dcntrs_ALBEDO, dcntrs_ALBEDOC, \
           dcntrs_SHFLX, dcntrs_PSL, dcntrs_TREFHT, dcntrs_PREH2O, dcntrs_T_850, \
           dcntrs_T_200, dcntrs_U_200, dcntrs_Z3_300, dcntrs_Z3_500, dcntrs_LHFLX, \
           dcntrs_SST, dcntrs_SST, \
           dcntrs_CLDTOT_COSP, dcntrs_CLDLOW_COSP, \
           dcntrs_CLDMED_COSP, dcntrs_CLDHGH_COSP, \
           dcntrs_CLDTHICK_COSP, \
           dcntrs_MEANPTOP_COSP, dcntrs_MEANCLDALB_COSP, \
           dcntrs_CLDTOT_COSP, dcntrs_CLDLOW_COSP, dcntrs_CLDMED_COSP, dcntrs_CLDHGH_COSP, \
           dcntrs_CLDTHICK_COSP, \
           dcntrs_CLDTOT_COSP, dcntrs_CLDLOW_COSP, dcntrs_CLDMED_COSP, dcntrs_CLDHGH_COSP, \
           dcntrs_CLDTHICK_COSP, \
           dcntrs_CLWMODIS, dcntrs_CLIMODIS, \
           dcntrs_IWPMODIS, dcntrs_LWPMODIS, \
           dcntrs_REFFCLIMODIS, dcntrs_REFFCLWMODIS, \
           dcntrs_TAU, dcntrs_TAU, dcntrs_TAU, \
           dcntrs_TAU, dcntrs_TAU, dcntrs_TAU, \
           dcntrs_PCTMODIS, \
           dcntrs_CLDTOT_COSP, dcntrs_CLDLOW_COSP, dcntrs_CLDMED_COSP, dcntrs_CLDHGH_COSP, \
           dcntrs_CLDTOT_COSP, dcntrs_TGCLDLWP, \
           dcntrs_PRECT, dcntrs_LHFLX /) 


  nvars = dimsizes(vars)

;------------------------------------------------------------------------
; global tropics plots


  tropvars = (/"PRECT","PRECT_OCEAN","PREH2O","PREH2O_OCEAN","SWCF", \
               "TGCLDLWP_OCEAN","TTRP"/) ; tropics 

; it is difficult to use different contour for tropical and global.
; This would need to be rewritten a different way
  Tcntrs = cntrs
  dTcntrs = dcntrs


;---------------------------------------------------------------------------
; model-to-model comparisons only
else
  
  cntrs_FSNT=(/0,30,60,90,120,150,180,210,240,270,300,330,360,390,420/) 
  dcntrs_FSNT=(/-75,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,75/)  
  cntrs_FLNT=(/100,115,130,145,160,175,190,205,220,235,250,265,280,295,310/)
  dcntrs_FLNT=(/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/)  
  cntrs_FSNS=(/0,25,50,75,100,125,150,175,200,220,240,260,280,300,320/) 
  dcntrs_FSNS=(/-100,-75,-50,-40,-30,-20,-10,0,10,20,30,40,50,75,100/)  
  cntrs_FLNS=(/10,20,30,40,50,60,70,80,90,100,110,120,130,140,150/) 
  dcntrs_FLNS=(/-70,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,70/)  
  cntrs_LHFLX=(/0,15,30,60,90,120,150,180,210,240,270,300,330,360,390/) 
  dcntrs_LHFLX=(/-150,-120,-90,-60,-30,-20,-10,0,10,20,30,60,90,120,150/)
  cntrs_SHFLX=(/-100,-75,-50,-25,-10,0,10,25,50,75,100,125,150,175,200/) 
  dcntrs_SHFLX=(/-100,-80,-60,-40,-20,-10,-5,0,5,10,20,40,60,80,100/)
  cntrs_PRECT=(/.2,.5,1,2,3,4,5,6,7,8,9,10,12,14,17/)    
  dcntrs_PRECT=(/-8,-6,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,6,8/) 
  cntrs_QFLX=(/0,.5,1,2,3,4,5,6,7,8,9,10,11,12,13/)      
  dcntrs_QFLX=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/) 
  cntrs_PSL=(/984,988,992,996,1000,1004,1008,1012,1016,1020,1024,1028,1032,1036,1040/)
  dcntrs_PSL=(/-15,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,15/)
  cntrs_TREFHT=(/210,220,230,240,250,260,270,275,280,285,290,295,300,305,310/)
  dcntrs_TREFHT=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/) 
  cntrs_TS=(/210,220,230,240,250,260,270,275,280,285,290,295,300,305,310/)
  dcntrs_TS=(/-5,-4,-3,-2,-1,-.5,-.2,0,.2,.5,1,2,3,4,5/) 
  cntrs_PREH2O=(/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/) ; PREH2O
  dcntrs_PREH2O=(/-12,-9,-6,-4,-3,-2,-1,0,1,2,3,4,6,9,12/)
  ;cntrs_RESSURF=(/-400,-350,-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200/) ;RESSURF
  cntrs_RESSURF=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200, 250, 300/) ;RESSURF  ++ hannay
  dcntrs_RESSURF=(/-80,-60,-40,-20,-10,-5,-1,0,1,5,10,20,40,60,80/)
  cntrs_LWCF=(/-45,-30,-20,-10,0,10,20,30,40,50,60,70,85,100,115/) ; LWCF
  dcntrs_LWCF=(/-35,-30,-25,-20,-15,-10,-5, 0, 5,10,15,20,25,30,35/) ; LWCF  ++ ceh
  cntrs_SWCF=(/-170,-150,-135,-120,-105,-90,-75,-60,-45,-30,-15,0,15,30,45/)
  dcntrs_SWCF=(/-80,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,80/) ; SWCF
  cntrs_Z3_300=(/83,84,85,86,87,88,89,90,91,92,93,94,95,96,97/)  ; Z at 300
  dcntrs_Z3_300=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
  cntrs_Z3_500=(/48,49,50,51,52,53,54,55,56,57,58,58.5,59,59.5,60/)  ; Z at 500
  dcntrs_Z3_500=(/-1.2,-1,-.8,-.6,-.4,-.2,-.1,0,.1,.2,.4,.6,.8,1,1.2/)
  cntrs_CHI_200=(/-18,-15,-12,-9,-6,-3,-1,0,1,3,6,9,12,15,18/) ; CHI at 200
  dcntrs_CHI_200=(/-8,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,8/)
  cntrs_PSI_200=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/) ; PSI at 200
  dcntrs_PSI_200=(/-3,-2.5,-2,-1.5,-1,-.5,-.3,0,.3,.5,1,1.5,2,2.5,3/)
  cntrs_U_200=(/-20,-15,-10,-5,0,5,10,15,20,25,30,40,50,60,70/) ; U at 200
  dcntrs_U_200=(/-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28/)
  cntrs_VT=(/-28,-24,-20,-16,-12,-8,-4,0,4,8,12,16,20,24,28/) ; VT
  dcntrs_VT=(/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
  cntrs_EKE_850=(/5,10,15,20,30,40,50,60,70,80,90,100,110,120,130/) ; EKE
  dcntrs_EKE_850=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
  cntrs_TGCLDIWP=(/1,5,10,15,20,25,30,35,40,45,50,55,60,70,80/) ; TGCLDIWP
  dcntrs_TGCLDIWP=(/-15,-12,-9,-7,-5,-3,-1,0,1,3,5,7,9,12,15/)
  cntrs_TGCLDLWP=(/10,25,50,75,100,150,175,200,250,300,350,400,450,500,550/);TGCLDLWP
  dcntrs_TGCLDLWP=(/-120,-100,-80,-60,-40,-20,-10,0,10,20,40,60,80,100,120/)
  cntrs_FLNSC=(/50,60,70,75,80,85,90,100,110,120,130,140,160,180,200/) ; FLNSC
  dcntrs_FLNSC=(/-25,-20,-15,-12,-9,-6,-3,0,3,6,9,12,15,20,25/)
  cntrs_FLNTC=(/120,135,150,165,180,195,210,225,240,255,270,280,290,300,310/)
  dcntrs_FLNTC=(/-15,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,15/) ; FLNTC
  cntrs_CLDTOT=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; 
  dcntrs_CLDTOT=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDLOW=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; 
  dcntrs_CLDLOW=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDMED=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; 
  dcntrs_CLDMED=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDHGH=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; 
  dcntrs_CLDHGH=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_TCLDAREA=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; 
  dcntrs_TCLDAREA=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_EP=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/)    ; EP
  dcntrs_EP=(/-7,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,7/) 
  cntrs_T_200=(/190,193,196,199,202,205,208,211,214,217,220,223,226,229,232/)
  dcntrs_T_200=(/-10,-8,-6,-4,-3,-2,-1,0,1,2,3,4,6,8,10/)  ; T at 200
  cntrs_T_850=(/230,235,240,245,250,255,260,265,270,275,280,285,290,295,300/)
  dcntrs_T_850=(/-8,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,8/)  ; T at 850
  cntrs_PBLH=(/50,100,150,200,250,300,350,400,450,500,600,700,800,1000,1200/)
  dcntrs_PBLH=(/-400,-300,-200,-150,-100,-50,-25,0,25,50,100,150,200,300,400/)   ;
  cntrs_FSNSC=(/0,25,50,75,100,125,150,175,200,225,250,275,300,325,350/) ;FSNSC
  dcntrs_FSNSC=(/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/)  ;FSNSC
  cntrs_FSNTC=(/0,25,50,75,100,125,150,175,200,225,250,300,350,400,450/) ;FSNTC
  dcntrs_FSNTC=(/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/)  ;FSNTC
  cntrs_SOLIN=(/30,60,90,120,150,180,210,240,270,300,330,360,390,420,450/);SOLIN
  dcntrs_SOLIN=(/-30,-25,-20,-15,-10,-5,-2,0,2,5,10,15,20,25,30/)  ;SOLIN
  cntrs_FLDS=(/75,100,125,150,175,200,225,250,275,300,325,350,375,400,425/)
  dcntrs_FLDS=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/) ; FLDS
  cntrs_FLDSC=(/75,100,125,150,175,200,225,250,275,300,325,350,375,400,425/)
  dcntrs_FLDSC=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/) ; FLDSC
  cntrs_FSDS=(/25,50,75,100,125,150,175,200,225,250,275,300,325,350,375/)
  dcntrs_FSDS=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/) ; FSDS
  cntrs_PRECIP=(/5,10,20,30,40,55,70,85,100,125,150,175,200,250,300/) ;PRECIP
  dcntrs_PRECIP=(/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/)
  cntrs_MEANPTOP=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/)
  dcntrs_MEANPTOP=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/) ; MEANPTOP
  cntrs_MEANTTOP=(/200,206,212,218,224,231,238,245,252,259,266,272,278,284,290/)
  dcntrs_MEANTTOP=(/-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/) ; 
  cntrs_MEANTAU=(/1,2,3,4,5,6,7,8,10,12,14,16,18,20,22/)
  dcntrs_MEANTAU=(/-4,-3,-2.5,-2,-1.5,-1,-.5,0,.5,1,1.5,2,2.5,3,4/) ; 
  cntrs_ALBSURF=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/) ; 
  dcntrs_ALBSURF=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
  cntrs_ALBEDO=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/) ; 
  dcntrs_ALBEDO=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
  cntrs_ALBEDOC=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/) ; 
  dcntrs_ALBEDOC=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
  cntrs_TICLDTWP=(/50,100,200,400,600,800,1000,1500,2000,2500,3000,3500,4000,4500,5000/)
  dcntrs_TICLDTWP=(/-6000,-4000,-3000,-2000,-1000,-500,-100,0,100,500,1000,2000,3000,4000,6000/);TICLDTWP
  cntrs_TTRP=(/186,188,190,192,194,196,198,200,202,204,206,208,210,212,214/)
  dcntrs_TTRP=(/-8,-6,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,6,8/) ; TTRP
  cntrs_PS=(/600,630,660,690,720,750,780,810,840,870,900,930,960,990,1020/)
  dcntrs_PS= (/-15,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,15/); PS
  cntrs_TICLDIWP=(/5,15,30,45,60,75,90,105,120,135,150,165,180,195,210/)
  dcntrs_TICLDIWP=(/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/);TICLDIWP
  cntrs_TICLDLIQWP=(/50,100,200,400,600,800,1000,1500,2000,2500,3000,3500,4000,4500,5000/)
  dcntrs_TICLDLIQWP=(/-6000,-4000,-3000,-2000,-1000,-500,-100,0,100,500,1000,2000,3000,4000,6000/);TICLDLIQWP
  cntrs_AODVIS=(/0.005,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.12,0.15,0.20,0.25,0.30,0.40/)
  dcntrs_AODVIS=(/-0.1,-0.05,-0.04,-0.03,-0.02,-0.01,-0.005,0,0.005,0.01,0.02,0.03,0.04,0.05,0.1/) ; AODVIS
  cntrs_AODDUST=(/0.005,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.12,0.15,0.20,0.25,0.30,0.40/)
  dcntrs_AODDUST=(/-0.1,-0.05,-0.04,-0.03,-0.02,-0.01,-0.005,0,0.005,0.01,0.02,0.03,0.04,0.05,0.1/) ; AODDUST
  cntrs_SST = (/-1,0,1,3,6,9,12,15,18,20,22,24,26,28,29/) ; SST 
  dcntrs_SST = (/-5,-4,-3,-2,-1,-.5,-.2,0,.2,.5,1,2,3,4,5/)  
  cntrs_CDNUMC=(/0.0,0.5,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,12.0,14.0,16.0/)
  dcntrs_CDNUMC=(/-14.,-12.,-10.,-8.,-6.,-4.,-2.,0.,2.,4.,6.,8.,10.,12.,14./)/2.;CDNUMC
  cntrs_SIWC_226=(/0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0/)*100.
  dcntrs_SIWC_226=(/-7.0,-6.0,-5.0,-4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0/)*100.;SIWC_226
  cntrs_CLDTOT_COSP=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; 
  dcntrs_CLDTOT_COSP=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDLOW_COSP=(/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/) 
  dcntrs_CLDLOW_COSP=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDMED_COSP=(/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/) 
  dcntrs_CLDMED_COSP=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDHGH_COSP=(/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/) 
  dcntrs_CLDHGH_COSP=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLDTHICK_COSP=(/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/) 
  dcntrs_CLDTHICK_COSP=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_MEANPTOP_COSP=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/) ; MEANPTOP_ISCCPCOSP
  dcntrs_MEANPTOP_COSP=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200,250,300/)
  cntrs_MEANCLDALB_COSP=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/) ; MEANCLDALB_ISCCPCOSP
  dcntrs_MEANCLDALB_COSP=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
  cntrs_CLW_COSP=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; 
  dcntrs_CLW_COSP=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_CLI_COSP=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; 
  dcntrs_CLI_COSP=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  cntrs_IWP_COSP = (/50,100,150,200,250,300,350,400,450,500,550,600,650,700,800/) ; IWPMODIS
  dcntrs_IWP_COSP = (/-700,-600,-500,-400,-300,-200,-100,0,100,200,300,400,500,600,700/)
  cntrs_LWP_COSP = (/40,80,120,160,200,240,280,320,360,400,440,480,520,560,600/) ; LWPMODIS
  dcntrs_LWP_COSP = (/-200,-150,-100,-80,-60,-40,-20,0,20,40,60,80,100,150,200/)
  cntrs_REFFCLI_COSP = (/5,10,15,20,25,30,35,40,45,50,55,60,65,70,75/) ; REFFCLIMODIS
  dcntrs_REFFCLI_COSP  = (/-70,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70/)
  cntrs_REFFCLW_COSP = (/1.5,3.0,4.5,6.0,7.5,9.0,10.5,12.0,13.5,15.0,16.5,18.0,19.5,21.0,22.5/) ; REFFCLWMODIS
  dcntrs_REFFCLW_COSP = (/-10.5,-9.0,-7.5,-6.0,-4.5,-3.0,-1.5,0,1.5,3.0,4.5,6.0,7.5,9.0,10.5/)
  cntrs_TAU_COSP = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/) ; TAUILOGMODIS
  dcntrs_TAU_COSP  = (/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
  cntrs_PCT_COSP=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/) ; PCTMODIS
  dcntrs_PCT_COSP=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200,250,300/)

  vars=(/"FSNT","FLNT","FSNS","FLNS","LHFLX","SHFLX", \
     "PRECT","QFLX","PSL","TREFHT","TS","PREH2O","RESSURF","LWCF", \
     "SWCF","Z3_300","Z3_500","CHI_200","PSI_200","U_200","VT_850", \
     "EKE_850","TGCLDIWP","TGCLDLWP","FLNSC","FLNTC","CLDTOT","CLDLOW", \
     "CLDMED","CLDHGH","EP","T_200","T_850","PBLH","FSNSC","FSNTC","SOLIN", \
     "FLDS","FLDSC","FSDS","PRECIP","MEANPTOP","MEANTTOP","MEANTAU", \
     "TCLDAREA","ALBSURF","ALBEDO","ALBEDOC","TICLDTWP","TTRP","PS", \
     "TICLDIWP","TICLDLIQWP","AODVIS","AODDUST","SST","CDNUMC","SIWC_226", \
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


  cntrs=(/cntrs_FSNT, cntrs_FLNT, cntrs_FSNS, cntrs_FLNS, cntrs_LHFLX, cntrs_SHFLX, \
     cntrs_PRECT, cntrs_QFLX, cntrs_PSL, cntrs_TREFHT, cntrs_TS, cntrs_PREH2O, cntrs_RESSURF, cntrs_LWCF, \
     cntrs_SWCF, cntrs_Z3_300, cntrs_Z3_500, cntrs_CHI_200, cntrs_PSI_200, cntrs_U_200, cntrs_VT, \
     cntrs_EKE_850, cntrs_TGCLDIWP, cntrs_TGCLDLWP, cntrs_FLNSC, cntrs_FLNTC, cntrs_CLDTOT, cntrs_CLDLOW, \
     cntrs_CLDMED, cntrs_CLDHGH, cntrs_EP, cntrs_T_200, cntrs_T_850, cntrs_PBLH, cntrs_FSNSC, cntrs_FSNTC, cntrs_SOLIN, \
     cntrs_FLDS, cntrs_FLDSC, cntrs_FSDS, cntrs_PRECIP, cntrs_MEANPTOP, cntrs_MEANTTOP, cntrs_MEANTAU, \
     cntrs_TCLDAREA, cntrs_ALBSURF, cntrs_ALBEDO, cntrs_ALBEDOC, cntrs_TICLDTWP, cntrs_TTRP, cntrs_PS, \
     cntrs_TICLDIWP, cntrs_TICLDLIQWP, cntrs_AODVIS, cntrs_AODDUST, cntrs_SST, cntrs_CDNUMC, cntrs_SIWC_226, \
     cntrs_CLDTOT_COSP, cntrs_CLDLOW_COSP, \
     cntrs_CLDMED_COSP, cntrs_CLDHGH_COSP, \
     cntrs_CLDTHICK_COSP, \
     cntrs_MEANPTOP_COSP, cntrs_MEANCLDALB_COSP, \
     cntrs_CLDTOT_COSP, cntrs_CLDLOW_COSP, cntrs_CLDMED_COSP, cntrs_CLDHGH_COSP, \
     cntrs_CLDTHICK_COSP, \
     cntrs_CLDTOT_COSP, cntrs_CLDLOW_COSP, cntrs_CLDMED_COSP, cntrs_CLDHGH_COSP, \
     cntrs_CLDTHICK_COSP, \
     cntrs_CLW_COSP, cntrs_CLI_COSP, \
     cntrs_IWP_COSP, cntrs_LWP_COSP, \
     cntrs_REFFCLI_COSP, cntrs_REFFCLW_COSP, \
     cntrs_TAU_COSP, cntrs_TAU_COSP, cntrs_TAU_COSP, \
     cntrs_TAU_COSP, cntrs_TAU_COSP, cntrs_TAU_COSP, \
     cntrs_PCT_COSP, \
     cntrs_CLDTOT_COSP, cntrs_CLDLOW_COSP, cntrs_CLDMED_COSP, cntrs_CLDHGH_COSP, \
     cntrs_CLDTOT_COSP/)

 dcntrs=(/dcntrs_FSNT, dcntrs_FLNT, dcntrs_FSNS, dcntrs_FLNS, dcntrs_LHFLX, dcntrs_SHFLX, \
     dcntrs_PRECT, dcntrs_QFLX, dcntrs_PSL, dcntrs_TREFHT, dcntrs_TS, dcntrs_PREH2O, dcntrs_RESSURF, dcntrs_LWCF, \
     dcntrs_SWCF, dcntrs_Z3_300, dcntrs_Z3_500, dcntrs_CHI_200, dcntrs_PSI_200, dcntrs_U_200, dcntrs_VT, \
     dcntrs_EKE_850, dcntrs_TGCLDIWP, dcntrs_TGCLDLWP, dcntrs_FLNSC, dcntrs_FLNTC, dcntrs_CLDTOT, dcntrs_CLDLOW, \
     dcntrs_CLDMED, dcntrs_CLDHGH, dcntrs_EP, dcntrs_T_200, dcntrs_T_850, dcntrs_PBLH, dcntrs_FSNSC, dcntrs_FSNTC, dcntrs_SOLIN, \
     dcntrs_FLDS, dcntrs_FLDSC, dcntrs_FSDS, dcntrs_PRECIP, dcntrs_MEANPTOP, dcntrs_MEANTTOP, dcntrs_MEANTAU, \
     dcntrs_TCLDAREA, dcntrs_ALBSURF, dcntrs_ALBEDO, dcntrs_ALBEDOC, dcntrs_TICLDTWP, dcntrs_TTRP, dcntrs_PS, \
     dcntrs_TICLDIWP, dcntrs_TICLDLIQWP, dcntrs_AODVIS, dcntrs_AODDUST, dcntrs_SST, dcntrs_CDNUMC, dcntrs_SIWC_226, \
     dcntrs_CLDTOT_COSP, dcntrs_CLDLOW_COSP, \
     dcntrs_CLDMED_COSP, dcntrs_CLDHGH_COSP, \
     dcntrs_CLDTHICK_COSP, \
     dcntrs_MEANPTOP_COSP, dcntrs_MEANCLDALB_COSP, \
     dcntrs_CLDTOT_COSP, dcntrs_CLDLOW_COSP, dcntrs_CLDMED_COSP, dcntrs_CLDHGH_COSP, \
     dcntrs_CLDTHICK_COSP, \
     dcntrs_CLDTOT_COSP, dcntrs_CLDLOW_COSP, dcntrs_CLDMED_COSP, dcntrs_CLDHGH_COSP, \
     dcntrs_CLDTHICK_COSP, \
     dcntrs_CLW_COSP, dcntrs_CLI_COSP, \
     dcntrs_IWP_COSP, dcntrs_LWP_COSP, \
     dcntrs_REFFCLI_COSP, dcntrs_REFFCLW_COSP, \
     dcntrs_TAU_COSP, dcntrs_TAU_COSP, dcntrs_TAU_COSP, \
     dcntrs_TAU_COSP, dcntrs_TAU_COSP, dcntrs_TAU_COSP, \
     dcntrs_PCT_COSP, \
     dcntrs_CLDTOT_COSP, dcntrs_CLDLOW_COSP, dcntrs_CLDMED_COSP, dcntrs_CLDHGH_COSP, \
     dcntrs_CLDTOT_COSP/)

;----------------------------------------------------------------------
; global tropics plots
  tropvars = (/"FSNS","PRECT","PREH2O","RESSURF","SWCF","TGCLDLWP","TTRP"/)
  Tcntrs = cntrs 
  dTcntrs = dcntrs    

  nvars = dimsizes(vars)

end if
;-------------------------------------------------------------
; common resources for global contour plots 

res = True      
res@mpCenterLonF = 180 
;res@mpCenterLonF = 270 
res@mpGeophysicalLineThicknessF = 1.0
res@gsnDraw = False           ; Do not draw plot
res@gsnFrame = False          ; Do not advance frame
if (tick_marks .eq. "True") then
  res@gsnTickMarksOn = True
else
  res@gsnTickMarksOn = False
end if
res@tiMainFont = "Helvetica"
res@vpXF = 0.05
res@vpWidthF = 1.00
res@vpHeightF = 0.70
res@mpPerimOn = True
res@mpPerimDrawOrder = "PostDraw"
if (color_type .eq. "COLOR") then
  res@mpFillOn = False
  res@lbLabelBarOn = True
  res@lbTitleOn = True
  res@lbBoxMinorExtentF = 0.15
  res@lbLabelStride = 1
  if (sig_plot .eq. "True") then
    res@txFontHeightF  = 0.024
    res@tiMainFontHeightF = 0.030
    res@pmLabelBarWidthF = 0.97
    res@lbOrientation = "Horizontal"
    res@lbLabelFontHeightF = 0.022
    res@lbTitleFontHeightF = 0.022
  else
    res@txFontHeightF = 0.020
    res@tiMainFontHeightF = 0.025
    res@lbOrientation = "Vertical"
    res@lbLabelFontHeightF = 0.015
    res@lbTitleFontHeightF = 0.018
  end if
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnMissingValFillColor = "Background"
  res@cnLineLabelsOn = False
  cmap = RGBtoCmap(rgb_file)
else
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnLinesOn = True 
  res@cnLineLabelsOn = True 
  res@cnLineLabelInterval = 1
  res@cnLineLabelFontHeightF = .010
  res@cnInfoLabelOrthogonalPosF = -0.06
  if (sig_plot .eq. "True") then
    res@cnInfoLabelFontHeightF = .012
    res@txFontHeightF  = 0.022
    res@tiMainFontHeightF = 0.027
  else
    res@cnInfoLabelFontHeightF = .010
    res@txFontHeightF = 0.020
    res@tiMainFontHeightF = 0.025
  end if
  gblcnlvls  = 15
  diffcnlvls = 12
end if 


;---------------------------------------------
; common resources for global tropics plots
minlat = -38
maxlat = 38
minlon = -70 
maxlon = 290
trop = True
trop@gsnDraw  = False
trop@gsnFrame = False
trop@mpProjection = "Mercator"
trop@mpShapeMode = "FreeAspect"
trop@mpLimitMode = "LatLon"
trop@mpMaxLatF = maxlat
trop@mpMinLatF = minlat
trop@mpMaxLonF = maxlon
trop@mpMinLonF = minlon
trop@mpCenterLatF = (maxlat-minlat)/2+minlat 
trop@mpCenterLonF = (maxlon-minlon)/2+minlon 
trop@vpWidthF = 1.00
trop@vpHeightF = 0.27
trop@vpXF = 0.05
trop@mpGridAndLimbOn = False
trop@mpPerimOn = True
trop@mpPerimDrawOrder = "PostDraw"
trop@mpGeophysicalLineThicknessF = 1.0
trop@tiMainFont = "Helvetica"
if (sig_plot .eq. "True") then
  trop@txFontHeightF = 0.020
  trop@tiMainFontHeightF = 0.025
else
  trop@txFontHeightF = 0.018
  trop@tiMainFontHeightF = 0.022
end if
if (color_type .eq. "COLOR") then
  trop@lbLabelBarOn = True
  trop@lbLabelStride = 1
  trop@lbTitleOn = True
  trop@lbOrientation = "Horizontal"
  trop@pmLabelBarWidthF = 0.95
  trop@lbLabelFontHeightF = 0.022
  trop@lbTitleFontHeightF = 0.022
  trop@mpFillOn = False 
  trop@cnLevelSelectionMode = "ExplicitLevels"
  trop@cnFillOn = True
  trop@cnLinesOn = False
  trop@cnLineLabelsOn = False
  trop@cnMissingValFillColor = "Background"
else
  trop@cnLevelSelectionMode = "ManualLevels"
  trop@mpFillOn = True 
  trop@cnLinesOn = True 
  trop@cnLineLabelsOn = True 
  trop@cnLineLabelInterval = 1
  trop@cnLineLabelFontHeightF = .008
  trop@cnInfoLabelFontHeightF = .010
  trop@cnInfoLabelOrthogonalPosF = 0.0
  tropcnlvls = 15
end if 
;--------------------------------------------------------------
; common resources for panel plots
pan = True
pan@gsnMaximize = True
pan@gsnFrame = False
if (sig_plot .eq. "True") then
  pan@gsnPaperOrientation = "landscape"
  if (color_type .eq. "COLOR") then
    pan@gsnPanelYWhiteSpacePercent = 2
  else
    pan@gsnPanelYWhiteSpacePercent = 4
  end if
else
  pan@gsnPaperOrientation = "portrait"
  pan@gsnPanelYWhiteSpacePercent = 2
end if

; common resources for tropics panel plots
panT = True
panT@gsnMaximize = True
panT@gsnFrame = False
panT@txFontHeightF = 0.020
panT@txFont = "helvetica-bold"
if (sig_plot .eq. "True") then
  panT@gsnPanelYWhiteSpacePercent = 2
  if (color_type .eq. "COLOR") then
    panT@gsnPaperOrientation = "landscape"
  else
    panT@gsnPaperOrientation = "portrait"
  end if
else
  panT@gsnPaperOrientation = "portrait"
end if
;--------------------------------------------------------------
if (sig_plot .eq. "True") then
  plot = new((/4/),"graphic")      ; global plots
  plotT = new((/4/),"graphic")     ; tropics plots
  SigLvl = sig_lvl                 ; significance level
else
  plot = new((/3/),"graphic")      ; global plots
  plotT = new((/3/),"graphic")     ; tropics plots
end if
;--------------------------------------------------------------


do i = 0,  nvars-1

  print("==================")  ; hannay
  print("====="+ i+"==="+ vars(i)) ; hannay
  print("====="+infile1)
  print("====="+outfile1

;----------------------------
; Test case: CASE 1 MODEL
;----------------------------

  if (vars(i) .eq. "ALBEDO") then
    A = get_ALBEDO (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_ALBEDO_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "ALBEDOC") then
    A = get_ALBEDOC (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_ALBEDOC_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "ALBSURF") then
    A = get_ALBSURF (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_ALBSURF_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "CHI_200") then
    A = get_CHI_200 (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"CHI_200",200.)
    end if
  end if
  if (vars(i) .eq. "CLDHGH") then
    A = get_CLDHGH (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDHGH")
    end if
  end if
  if (vars(i) .eq. "CLDLOW") then
    A = get_CLDLOW (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDLOW")
    end if
  end if
  if (vars(i) .eq. "CLDMED") then
    A = get_CLDMED (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDMED")
    end if
  end if
  if (vars(i) .eq. "CLDTOT") then
    A = get_CLDTOT (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTOT")
    end if
  end if

  if (vars(i) .eq. "EKE_850") then
    A = get_EKE_850 (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"EKE_850",850.)
    end if
  end if
  if (vars(i) .eq. "EP") then
    A = get_EP (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_EP_VARIANCE (meansptr1,varptr1)
    end if
  end if

  if (vars(i) .eq. "FLDS") then
    A = get_FLDS (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_FLDS_VARIANCE (meansptr1,varptr1)
    end if
  end if

  if (vars(i) .eq. "SIWC_226") then
    A = get_SIWC_226 (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("SIWC_226 not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
        A_var = get_SIWC_226_VARIANCE (meansptr1,varptr1)
      end if
    end if
  end if

  if (vars(i) .eq. "FLDSC") then
    A = get_FLDSC (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_FLDSC_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "FLNS") then
    A = get_FLNS (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FLNS")
    end if
  end if
  if (vars(i) .eq. "FLNSC") then
    A = get_FLNSC (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FLNSC")
    end if
  end if
  if (vars(i) .eq. "FLNT") then
    A = get_FLNT (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FLNT")
    end if
  end if
  if (vars(i) .eq. "FLNTC") then
    A = get_FLNTC (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FLNTC")
    end if
  end if
  if (vars(i) .eq. "FLUT") then
    A = get_FLUT (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("FLUT not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"FLUT")
      end if
    end if
  end if
  if (vars(i) .eq. "FLUTC") then
    A = get_FLUTC (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("FLUTC not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"FLUTC")
      end if
    end if
  end if
  if (vars(i) .eq. "FSDS") then
    A = get_FSDS (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSDS")
    end if
  end if
  if (vars(i) .eq. "FSDSC") then
    A = get_FSDSC (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSDSC")
    end if
  end if
  if (vars(i) .eq. "FSNS") then
    A = get_FSNS (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSNS")
    end if
  end if
  if (vars(i) .eq. "FSNSC") then
    A = get_FSNSC (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSNSC")
    end if
  end if
  if (vars(i) .eq. "FSNT") then
    A = get_FSNT (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSNT")
    end if
  end if
  if (vars(i) .eq. "FSNTC") then
    A = get_FSNTC (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSNTC")
    end if
  end if
  if (vars(i) .eq. "FSNTOA") then
    A = get_FSNTOA (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("FSNTOA not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"FSNTOA")
      end if
    end if
  end if
  if (vars(i) .eq. "FSNTOAC") then
    A = get_FSNTOAC (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("FSNTOAC not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"FSNTOAC")
      end if
    end if
  end if
  if (vars(i) .eq. "LHFLX") then
    A = get_LHFLX (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"LHFLX")
    end if
  end if

  if (vars(i) .eq. "LWCFSRF") then
    A = get_LWCFSRF (inptr1,outptr1)
  end if

  if (vars(i) .eq. "LWCF") then
    if (compare .eq. "OBS") then
      A = get_LWCFTOA (inptr1,outptr1)
    else
      A = get_LWCFTOM (inptr1,outptr1)
      if (sig_plot .eq. "True") then
        A_var = get_LWCFTOM_VARIANCE (meansptr1,varptr1)
      end if
    end if
  end if

  if (vars(i) .eq. "MEANPTOP") then   ; cam2.2
    A = get_MEANPTOP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("MEANPTOP not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"MEANPTOP")
      end if
    end if
  end if
  if (vars(i) .eq. "MEANTTOP") then   ; cam2.2
    A = get_MEANTTOP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("MEANTTOP not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"MEANTTOP")
      end if
    end if
  end if
  if (vars(i) .eq. "MEANTAU") then   ; cam2.2
    A = get_MEANTAU (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("MEANTAU not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"MEANTAU")
      end if
    end if
  end if

  if (vars(i) .eq. "PBLH") then
    A = get_PBLH (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"PBLH")
    end if
  end if
  if (vars(i) .eq. "PRECIP") then
    A = get_PRECIP (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PRECIP_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PRECIP_LAND") then
    A = get_PRECIP_LAND (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PRECT") then
    A = get_PRECT (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PRECT_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PRECT_LAND") then
    A = get_PRECT_LAND (inptr1,outptr1)
  end if
  if (vars(i) .eq. "PRECT_OCEAN") then
    A = get_PRECT_OCEAN (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PRECT_OCEAN_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PREH2O") then
    A = get_PREH2O (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PREH2O_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PREH2O_OCEAN") then
    A = get_PREH2O_OCEAN (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PRECT_OCEAN_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PSI_200") then
    A = get_PSI_200 (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"PSI_200",200.)
    end if
  end if
  if (vars(i) .eq. "PS") then
    A = get_PS (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PS_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PSL") then
    A = get_PSL (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PSL_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "QFLX") then
    A = get_QFLX (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_QFLX_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "RESSURF") then
    A = get_RESSURF (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_RESSURF_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "SHFLX") then
    A = get_SHFLX (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"SHFLX")
    end if
  end if
  if (vars(i) .eq. "SOLIN") then
    A = get_SOLIN (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"SOLIN")
    end if
  end if
  if (vars(i) .eq. "AODVIS") then
    A = get_AODVIS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AODDUST") then
    A = get_AODDUST (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SST") then
    A = get_SST (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_SST_VARIANCE (meansptr1,varptr1)
    end if
  end if

  if (vars(i) .eq. "SWCFSRF") then
    A = get_SWCFSRF (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SWCF") then
    if (compare .eq. "OBS") then
      A = get_SWCFTOA (inptr1,outptr1)
    else
      A = get_SWCFTOM (inptr1,outptr1)
      if (sig_plot .eq. "True") then
        A_var = get_SWCFTOM_VARIANCE (meansptr1,varptr1)
      end if
    end if
  end if

  if (vars(i) .eq. "TCLDAREA") then   ; cam2.2
    A = get_TCLDAREA (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("TCLDAREA not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"TCLDAREA")
      end if
    end if
  end if

  if (vars(i) .eq. "TGCLDIWP") then
    A = get_TGCLDIWP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("TGCLDIWP not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"TGCLDIWP")
      end if
    end if
  end if
  if (vars(i) .eq. "TGCLDLWP") then
    A = get_TGCLDLWP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("TGCLDLWP not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"TGCLDLWP")
      end if
    end if
  end if
  if (vars(i) .eq. "TGCLDLWP_OCEAN") then
    A = get_TGCLDLWP_OCEAN (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("TGCLDLWP not present in test case input file.")
      delete (A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_TGCLDLWP_OCEAN_VARIANCE (meansptr1,varptr1)
      end if
    end if
  end if
  if (vars(i) .eq. "TICLDIWP") then
    A = get_TICLDIWP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("TICLDIWP not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
        A_var = get_TICLDIWP_VARIANCE (meansptr1,varptr1)
      end if
    end if
  end if
  if (vars(i) .eq. "TICLDLIQWP") then
    A = get_TICLDLIQWP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("TICLDLIQWP not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
        A_var = get_TICLDLIQWP_VARIANCE (meansptr1,varptr1)
      end if
    end if
  end if
  if (vars(i) .eq. "TICLDTWP") then
    A = get_TICLDTWP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("TICLDTWP not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
        A_var = get_TICLDTWP_VARIANCE (meansptr1,varptr1)
      end if
    end if
  end if
  if (vars(i) .eq. "T_200") then
    A = get_T_200 (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"T_200",200.)
    end if
  end if
  if (vars(i) .eq. "T_850") then
    A = get_T_850 (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"T_850",850.)
    end if
  end if
  if (vars(i).eq."TREFHT") then
    A = get_TREFHT (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"TREFHT")
    end if
  end if
  if (vars(i) .eq. "TREFHT_LAND") then
    A = get_TREFHT_LAND (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_TREFHT_LAND_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "TS") then
    A = get_TS (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"TS")
    end if
  end if
  if (vars(i) .eq. "TTRP") then
    A = get_TTRP (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_TTRP_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "U_200") then
    A = get_U_200 (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"U_200",200.)
    end if
  end if
  if (vars(i) .eq. "VT_850") then
    A = get_VT_850 (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"VT_850",850.)
    end if
  end if
  if (vars(i) .eq. "Z3_300") then
    A = get_Z3_300 (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"Z3_300",300.)
    end if
  end if
  if (vars(i) .eq. "Z3_500") then
    A = get_Z3_500 (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"Z3_500",500.)
    end if
  end if
  if (vars(i) .eq. "CDNUMC") then
    A = get_CDNUMC (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("CDNUMC not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"CDNUMC")
      end if
    end if
  end if


  if (vars(i) .eq. "CLDTOT_ISCCPCOSP") then
    A = get_CLDTOT_ISCCPCOSP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("CLDTOT_ISCCPCOSP not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTOT_ISCCPCOSP")
      end if
    end if
  end if 

  if (vars(i) .eq. "CLDLOW_ISCCPCOSP") then
    A = get_CLDLOW_ISCCPCOSP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("CLDLOW_ISCCPCOSP not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDLOW_ISCCPCOSP")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDMED_ISCCPCOSP") then
    A = get_CLDMED_ISCCPCOSP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("CLDMED_ISCCPCOSP not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDMED_ISCCPCOSP")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDHGH_ISCCPCOSP") then
    A = get_CLDHGH_ISCCPCOSP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("CLDHGH_ISCCPCOSP not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDHGH_ISCCPCOSP")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDTHICK_ISCCPCOSP") then
    A = get_CLDTHICK_ISCCPCOSP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDTHICK_ISCCPCOSP: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTHICK_ISCCPCOSP")
      end if
    end if
  end if
  if (vars(i) .eq. "MEANPTOP_ISCCPCOSP") then
    A = get_MEANPTOP_ISCCPCOSP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_MEANPTOP_ISCCPCOSP: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"MEANPTOP_ISCCPCOSP")
      end if
    end if
  end if
  if (vars(i) .eq. "MEANCLDALB_ISCCPCOSP") then
    A = get_MEANCLDALB_ISCCPCOSP (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_MEANCLDALB_ISCCPCOSP: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"MEANCLDALB_ISCCPCOSP")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDTOT_MISR") then
    A = get_CLDTOT_MISR (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDTOT_MISR: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTOT_MISR")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDLOW_MISR") then
    A = get_CLDLOW_MISR (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDLOW_MISR: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDLOW_MISR")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDMED_MISR") then
    A = get_CLDMED_MISR (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDMED_MISR: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDMED_MISR")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDHGH_MISR") then
    A = get_CLDHGH_MISR (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDHGH_MISR: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDHGH_MISR")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDTHICK_MISR") then
    A = get_CLDTHICK_MISR (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDTHICK_MISR: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTHICK_MISR")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDTOT_MODIS") then
    A = get_CLDTOT_MODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDTOT_MODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTOT_MODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDLOW_MODIS") then
    A = get_CLDLOW_MODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDLOW_MODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDLOW_MODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDMED_MODIS") then
    A = get_CLDMED_MODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDMED_MODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDMED_MODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDHGH_MODIS") then
    A = get_CLDHGH_MODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDHGH_MODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDHGH_MODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDTHICK_MODIS") then
    A = get_CLDTHICK_MODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDTHICK_MODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTHICK_MODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "CLWMODIS") then
    A = get_CLWMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLWMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLWMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "CLIMODIS") then
    A = get_CLIMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLIMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLIMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "IWPMODIS") then
    A = get_IWPMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_IWPMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"IWPMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "LWPMODIS") then
    A = get_LWPMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_LWPMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"LWPMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "REFFCLIMODIS") then
    A = get_REFFCLIMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_REFFCLIMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"REFFCLIMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "REFFCLWMODIS") then
    A = get_REFFCLWMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_REFFCLWMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"REFFCLWMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "TAUTLOGMODIS") then
    A = get_TAUTLOGMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_TAUTLOGMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"TAUTLOGMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "TAUILOGMODIS") then
    A = get_TAUILOGMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_TAUILOGMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"TAUILOGMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "TAUWLOGMODIS") then
    A = get_TAUWLOGMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_TAUWLOGMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"TAUWLOGMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "TAUTMODIS") then
    A = get_TAUTMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_TAUTMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"TAUTMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "TAUIMODIS") then
    A = get_TAUIMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_TAUIMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"TAUIMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "TAUWMODIS") then
    A = get_TAUWMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_TAUWMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"TAUWMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "PCTMODIS") then
    A = get_PCTMODIS (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_PCTMODIS: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"PCTMODIS")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDTOT_CAL") then
    A = get_CLDTOT_CAL (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDTOT_CAL: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTOT_CAL")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDLOW_CAL") then
    A = get_CLDLOW_CAL (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDLOW_CAL: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDLOW_CAL")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDMED_CAL") then
    A = get_CLDMED_CAL (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDMED_CAL: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDMED_CAL")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDHGH_CAL") then
    A = get_CLDHGH_CAL (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDHGH_CAL: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDHGH_CAL")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDTOT_CS2") then
    A = get_CLDTOT_CS2 (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print ("get_CLDTOT_CS2: not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTOT_CS2")
      end if
    end if
  end if

  if (all(A.eq.-999.)) then
    print (vars(i)+" not present in test case input file.")
    delete(A)
    continue       ; procede to next variable in do loop
  end if

;----------------------------
; Control case (if model to model comparison)
; or observation (if model to obs comparison)
;----------------------------
 
 ;-------------
 ; Observation (if model to obs comparison)
 ;-------------
  if (compare .eq. "OBS") then            ; CASE 2 IS OBS DATA

   
   print("====="+ obsvars(i))   ;+++ hannay

   if (any(obsvars(i) .eq. cru_vars)) then
     inptr2 = ptr_cru
      case2 = "IPCC/CRU"
    end if
    if (any(obsvars(i) .eq. had_vars)) then
      inptr2 = ptr_had
      case2 = "HadISST (climatology)"
    end if
    if (any(obsvars(i) .eq. had_pi_vars)) then
      inptr2 = ptr_had_pi
      case2 = "HadISST (pre-industrial)"
    end if
    if (any(obsvars(i) .eq. had_pd_vars)) then
      inptr2 = ptr_had_pd
      case2 = "HadISST (present-day)"
    end if
    if (any(obsvars(i) .eq. leg_vars)) then
      inptr2 = ptr_leg
      case2 = "LEGATES"
    end if
    if (any(obsvars(i) .eq. erai_vars)) then
      inptr2 = ptr_erai
      case2 = "ERAI"
    end if
    if (any(obsvars(i) .eq. era40_vars)) then
      inptr2 = ptr_era40
      case2 = "ERA40"
    end if
     if (any(obsvars(i) .eq. jra25_vars)) then
      inptr2 = ptr_jra25
      case2 = "JRA25"
    end if
    if (any(obsvars(i) .eq. airs_vars)) then
      inptr2 = ptr_airs
      case2 = "AIRS"
    end if
    if (any(obsvars(i) .eq. gpcp_vars)) then
      inptr2 = ptr_gpcp
      case2 = "GPCP"
    end if
    if (any(obsvars(i) .eq. precl_vars)) then
      inptr2 = ptr_precl
      case2 = "PREC/L"
    end if
    if (any(obsvars(i) .eq. merra_vars)) then
      inptr2 = ptr_merra
      case2 = "MERRA"
    end if
    if (any(obsvars(i) .eq. ceres_ebaf_vars)) then
      inptr2 = ptr_ceres_ebaf
      case2 = "CERES-EBAF"
    end if
    if (any(obsvars(i) .eq. erbe_vars)) then
      inptr2 = ptr_erbe
      case2 = "ERBE"
    end if
    if (any(obsvars(i) .eq. xa_vars)) then
      inptr2 = ptr_xa
      case2 = "XIE-ARKIN"
    end if
    if (any(obsvars(i) .eq. ssmi_vars)) then
      inptr2 = ptr_ssmi
      case2 = "SSM/I"
    end if
    if (any(obsvars(i) .eq. uwisc_vars)) then
      inptr2 = ptr_uwisc
      case2 = "UWisc"
    end if
    if (any(obsvars(i) .eq. trmm_vars)) then
      inptr2 = ptr_trmm
      case2 = "TRMM"
    end if
  
    if (any(obsvars(i) .eq. nvap_vars)) then
      inptr2 = ptr_nvap
      case2 = "NVAP"
    end if
    if (any(obsvars(i) .eq. whoi_vars)) then
      inptr2 = ptr_whoi
      case2 = "WHOI"
    end if
    if (any(obsvars(i) .eq. laryea_vars)) then
      inptr2 = ptr_laryea
      case2 = "LARGE-YEAGER"
    end if
    if (any(obsvars(i) .eq. isccpD1_vars)) then
      inptr2 = ptr_isccpD1
      case2 = "ISCCP D1"
    end if
    if (any(obsvars(i) .eq. isccp_vars)) then
      inptr2 = ptr_isccp
      case2 = "ISCCP D2"
    end if
    if (any(obsvars(i) .eq. isccpFD_vars)) then
      inptr2 = ptr_isccpFD
      case2 = "ISCCP FD"
    end if
    if (any(obsvars(i) .eq. warren_vars)) then
      inptr2 = ptr_warren
      case2 = "WARREN"
    end if
    if (any(obsvars(i) .eq. cloudsat_vars)) then
      inptr2 = ptr_cloudsat
      case2 = "CLOUDSAT"
    end if
    if (any(obsvars(i) .eq. will_vars)) then
      inptr2 = ptr_will
      case2 = "WILLMOTT"
    end if
    if (any(obsvars(i) .eq. isccpcosp_vars)) then
      inptr2 = ptr_isccpcosp
      case2 = "ISCCP-COSP"
    end if
    if (any(obsvars(i) .eq. misrcosp_vars)) then
      inptr2 = ptr_misrcosp
      case2 = "MISR L3 CTH-OD V5"
    end if
    if (any(obsvars(i) .eq. modiscosp_vars)) then
      inptr2 = ptr_modiscosp
      case2 = "MODIS-COSP"
    end if
    if (any(obsvars(i) .eq. calipsocosp_vars)) then
      inptr2 = ptr_calipsocosp
      case2 = "CALIPSO-GOCCP"
    end if
    if (any(obsvars(i) .eq. cloudsatcosp_vars)) then
      inptr2 = ptr_cloudsatcosp
      case2 = "CLOUDSAT-COSP"
    end if
 
;   get latitudes,longitudes, and weights
    lat2 = inptr2->lat
    nlat2 = dimsizes(lat2) 
    lon2 = inptr2->lon
    nlon2 = dimsizes(lon2)

    if (any(obsvars(i).eq.isccp_vars) .or. any(obsvars(i).eq.warren_vars)) then
      gw2 = latGauWgt(64,"lat","gaussian weights","none")  ; no gw in file
      print("Gaussian weights are not present") ; hannay
      ;print("Check: plot_surfaces_cons.ncl" ; hannay
      ;exit   ; hannay
    else
      if (isfilevar(inptr2,"wgt")) then
        gw2 = inptr2->wgt          ; non-gaussian weights (1x1 degree) 
      else
        if (isfilevar(inptr2,"gw")) then
          gw2 = inptr2->gw           ; gaussian weights 
        else
          gw2 = latGauWgt(nlat2,"lat","gaussian weights","none") 
          print("Gaussian weights are not present") ; hannay
          ;print("Check: plot_surfaces_cons.ncl" ; hannay
          ;exit   ; hannay
        end if
      end if
    end if

; get the variable

    if (vars(i).eq."T_850"  .or. vars(i).eq."T_200" .or. \
        vars(i).eq."U_200"  .or. vars(i).eq."Z3_300" .or. \
        vars(i).eq."Z3_500" .or. vars(i).eq."TREFHT_LAND" .or. \
        vars(i).eq."PRECIP_LAND" .or. \
        obsvars(i).eq."CLDLOW_WARREN" .or. obsvars(i).eq."CLDTOT_WARREN" .or. \
        obsvars(i).eq."CLDLOW_CLOUDSAT".or. \
        obsvars(i).eq."CLDMED_CLOUDSAT".or. \
        obsvars(i).eq."CLDHGH_CLOUDSAT".or. \
        obsvars(i).eq."CLDTOT_CLOUDSAT".or. \
        obsvars(i).eq."SST_HADISST".or. \
        obsvars(i).eq."SST_HADISST_PD".or. \
        obsvars(i).eq."SST_HADISST_PI" ) then
      if (vars(i).eq."T_850") then
        B = inptr2->T(0,{850},:,:)
        B@long_name = "850 mb Temp"
      end if
      if (vars(i).eq."T_200") then
        B = inptr2->T(0,{200},:,:)
        B@long_name = "200 mb Temp"
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

      if (vars(i).eq."TREFHT_LAND" .or. vars(i).eq."PRECIP_LAND" .or. \
        obsvars(i).eq."CLDLOW_WARREN" .or. obsvars(i).eq."CLDTOT_WARREN" .or. \
        obsvars(i).eq."CLDLOW_CLOUDSAT".or. \
        obsvars(i).eq."CLDMED_CLOUDSAT".or. \
        obsvars(i).eq."CLDHGH_CLOUDSAT".or. \
        obsvars(i).eq."CLDTOT_CLOUDSAT".or. \
        obsvars(i).eq."SST_HADISST".or. \
        obsvars(i).eq."SST_HADISST_PI".or. \
        obsvars(i).eq."SST_HADISST_PD") then
        B = inptr2->$vars(i)$      ; no time dimension
      end if
    else
       
      if (isfilevar(inptr2,vars(i))) then 
        if (dimsizes(getfilevardimsizes(inptr2,vars(i))).eq.3) then
          B = inptr2->$vars(i)$(0,:,:)
        else
          B = inptr2->$vars(i)$
        end if   
      else
        B=-999.   ; the variable is not present in thefile 
        delete(gw2)
        delete(lat2)
        delete(nlat2)
        delete(lon2)
        delete(nlon2)
      end if


;      if (isfilevar(inptr2,obsvars(i))) then
;        if (dimsizes(getfilevardimsizes(inptr2,obsvars(i))).eq.3) then
;          B = inptr2->$obsvars(i)$(0,:,:)
;        else
;          B = inptr2->$obsvars(i)$
;        end if
;      else 
;        
;        if (isfilevar(inptr2,vars(i))) then 
;          B = inptr2->$vars(i)$(0,:,:) ; other obsvars with time dimension 
;        else
;          B=-999.   ; the variable is not present 
;          delete(gw2)
;          delete(lat2)
;          delete(nlat2)
;          delete(lon2)
;          delete(nlon2)
;        end if
;      end if
      
    end if

 ;-------------
 ; Control case (if model to model comparison)
 ;-------------

  else                               ; CASE 2 IS MODEL
  
    if (vars(i) .eq. "ALBEDO") then
      B = get_ALBEDO (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_ALBEDO_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "ALBEDOC") then
      B = get_ALBEDOC (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_ALBEDOC_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "ALBSURF") then
      B = get_ALBSURF (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_ALBSURF_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "CHI_200") then
      B = get_CHI_200 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"CHI_200",200.)
      end if
    end if
    if (vars(i) .eq. "CLDHGH") then
      B = get_CLDHGH (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDHGH")
      end if
    end if
    if (vars(i) .eq. "CLDLOW") then
      B = get_CLDLOW (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDLOW")
      end if
    end if
    if (vars(i) .eq. "CLDMED") then
      B = get_CLDMED (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDMED")
      end if
    end if
    if (vars(i) .eq. "CLDTOT") then
      B = get_CLDTOT (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTOT")
      end if
    end if
    if (vars(i) .eq. "EKE_850") then
      B = get_EKE_850 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"EKE_850",850.)
      end if
    end if
    if (vars(i) .eq. "EP") then
      B = get_EP (inptr2,outptr2)
      print("+++ reading EP")
      if (sig_plot .eq. "True") then
        B_var = get_EP_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "FLDS") then
      B = get_FLDS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_FLDS_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "FLDSC") then
      B = get_FLDSC (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_FLDSC_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "FLNS") then
      B = get_FLNS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FLNS")
      end if
    end if
    if (vars(i) .eq. "FLNSC") then
      B = get_FLNSC (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FLNSC")
      end if
    end if
    if (vars(i) .eq. "FLNT") then
      B = get_FLNT (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FLNT")
      end if
    end if
    if (vars(i) .eq. "FLNTC") then
      B = get_FLNTC (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FLNTC")
      end if
    end if
    if (vars(i) .eq. "FLUT") then
      B = get_FLUT (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("FLUT not present in control case input file.")
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"FLUT")
        end if
      end if
    end if
    if (vars(i) .eq. "FLUTC") then
      B = get_FLUTC (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("FLUTC not present in control case input file.")
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"FLUTC")
        end if
      end if
    end if
    if (vars(i) .eq. "FSDS") then
      B = get_FSDS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSDS")
      end if
    end if
    if (vars(i) .eq. "FSDSC") then
      B = get_FSDSC (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSDSC")
      end if
    end if
    if (vars(i) .eq. "FSNS") then
      B = get_FSNS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSNS")
      end if
    end if
    if (vars(i) .eq. "FSNSC") then
      B = get_FSNSC (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSNSC")
      end if
    end if
    if (vars(i) .eq. "FSNT") then
      B = get_FSNT (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSNT")
      end if
    end if
    if (vars(i) .eq. "FSNTC") then
      B = get_FSNTC (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSNTC")
      end if
    end if
    if (vars(i) .eq. "FSNTOA") then
      B = get_FSNTOA (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("FSNTOA not present in control case input file.")
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"FSNTOA")
        end if
      end if
    end if
    if (vars(i) .eq. "FSNTOAC") then
      B = get_FSNTOAC (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("FSNTOAC not present in control case input file.")
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"FSNTOAC")
        end if
      end if
    end if
    if (vars(i) .eq. "LHFLX") then
      B = get_LHFLX (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"LHFLX")
      end if
    end if
    if (vars(i) .eq. "LWCFSRF") then
      B = get_LWCFSRF (inptr2,outptr2)
    end if
    if (vars(i) .eq. "LWCF") then
      B = get_LWCFTOM (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_LWCFTOM_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "MEANPTOP") then   ; cam2.2
      B = get_MEANPTOP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"MEANPTOP")
      end if
    end if
    if (vars(i) .eq. "MEANTTOP") then  ; cam2.2
      B = get_MEANTTOP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"MEANTTOP")
      end if
    end if
    if (vars(i) .eq. "MEANTAU") then   ; cam2.2
      B = get_MEANTAU (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"MEANTAU")
      end if
    end if
    if (vars(i) .eq. "PBLH") then
      B = get_PBLH (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"PBLH")
      end if
    end if
    if (vars(i) .eq. "PRECIP") then
      B = get_PRECIP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PRECIP_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "PRECIP_LAND") then
      B = get_PRECIP_LAND (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PRECT") then
      B = get_PRECT (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PRECT_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "PRECT_LAND") then
      B = get_PRECT_LAND (inptr2,outptr2)
    end if
    if (vars(i) .eq. "PRECT_OCEAN") then
      B = get_PRECT_OCEAN (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PRECT_OCEAN_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "PREH2O") then
      B = get_PREH2O (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PREH2O_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "PREH2O_OCEAN") then
      B = get_PREH2O_OCEAN (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PREH2O_OCEAN_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "PSI_200") then
      B = get_PSI_200 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"PSI_200",200.)
      end if
    end if
    if (vars(i) .eq. "PS") then
      B = get_PS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PS_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "PSL") then
      B = get_PSL (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PSL_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "QFLX") then
      B = get_QFLX (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_QFLX_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "RESSURF") then
      B = get_RESSURF (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_RESSURF_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "SHFLX") then
      B = get_SHFLX (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"SHFLX")
      end if
    end if
    if (vars(i) .eq. "SOLIN") then
      B = get_SOLIN (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"SOLIN")
      end if
    end if
    if (vars(i) .eq. "AODVIS") then
      B = get_AODVIS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AODDUST") then
      B = get_AODDUST (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SST") then
      B = get_SST (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_SST_VARIANCE (meansptr2,varptr2)
      end if
    end if
  
    if (vars(i) .eq. "SWCFSRF") then
      B = get_SWCFSRF (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SWCF") then
      B = get_SWCFTOM (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_SWCFTOM_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "TCLDAREA") then   ; cam2.2
      B = get_TCLDAREA (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TCLDAREA")
      end if
    end if
    if (vars(i) .eq. "TGCLDIWP") then
      B = get_TGCLDIWP (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("TGCLDIWP not present in control case input file.")
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"TGCLDIWP")
        end if
      end if
    end if
    if (vars(i) .eq. "TGCLDLWP") then
      B = get_TGCLDLWP (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("TGCLDLWP not present in control case input file.")
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"TGCLDLWP")
        end if
      end if
    end if
    if (vars(i) .eq. "TGCLDLWP_OCEAN") then
      B = get_TGCLDLWP_OCEAN (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("TGCLDLWP not present in control case input file.")
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_TGCLDLWP_OCEAN_VARIANCE (meansptr2,varptr2)
        end if
      end if
    end if
    if (vars(i) .eq. "TICLDIWP") then
      B = get_TICLDIWP (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("TICLDIWP not present in test case input file.")
        delete (A)
        delete (B)
        continue
      else  
        if (sig_plot .eq. "True") then
          B_var = get_TICLDIWP_VARIANCE (meansptr2,varptr2)
        end if
      end if
    end if
    if (vars(i) .eq. "TICLDLIQWP") then
      B = get_TICLDLIQWP (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("TICLDLIQWP not present in test case input file.")
        delete (A)
        delete (B)
        continue
      else  
        if (sig_plot .eq. "True") then
          B_var = get_TICLDLIQWP_VARIANCE (meansptr2,varptr2)
        end if
      end if
    end if
    if (vars(i) .eq. "TICLDTWP") then
      B = get_TICLDTWP (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("TICLDTWP not present in test case input file.")
        delete (A)
        delete (B)
        continue
      else  
        if (sig_plot .eq. "True") then
          B_var = get_TICLDTWP_VARIANCE (meansptr2,varptr2)
        end if
      end if
    end if
    if (vars(i) .eq. "T_200") then
      B = get_T_200 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"T_200",200.)
      end if
    end if
    if (vars(i) .eq. "T_850") then
      B = get_T_850 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"T_850",850.)
      end if
    end if
    if (vars(i) .eq. "TREFHT") then
      B = get_TREFHT (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TREFHT")
      end if
    end if
    if (vars(i) .eq. "TS") then
      B = get_TS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TS")
      end if
    end if
    if (vars(i) .eq. "TTRP") then
      B = get_TTRP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_TTRP_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "U_200") then
      B = get_U_200 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"U_200",200.)
      end if
    end if
    if (vars(i) .eq. "VT_850") then
      B = get_VT_850 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"VT_850",850.)
      end if
    end if
    if (vars(i) .eq. "Z3_300") then
      B = get_Z3_300 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"Z3_300",300.)
      end if
    end if
    if (vars(i) .eq. "Z3_500") then
      B = get_Z3_500 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"Z3_500",500.)
      end if
    end if
    if (vars(i) .eq. "CLDTOT_ISCCPCOSP") then
      B = get_CLDTOT_ISCCPCOSP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTOT_ISCCPCOSP")
      end if
    end if 
    if (vars(i) .eq. "CLDLOW_ISCCPCOSP") then
      B = get_CLDLOW_ISCCPCOSP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDLOW_ISCCPCOSP")
      end if
    end if 
    if (vars(i) .eq. "CLDMED_ISCCPCOSP") then
      B = get_CLDMED_ISCCPCOSP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDMED_ISCCPCOSP")
      end if
    end if 
    if (vars(i) .eq. "CLDHGH_ISCCPCOSP") then
      B = get_CLDHGH_ISCCPCOSP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDHGH_ISCCPCOSP")
      end if
    end if 
    if (vars(i) .eq. "CLDTHICK_ISCCPCOSP") then
      B = get_CLDTHICK_ISCCPCOSP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTHICK_ISCCPCOSP")
      end if
    end if 
    if (vars(i) .eq. "MEANPTOP_ISCCPCOSP") then
      B = get_MEANPTOP_ISCCPCOSP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"MEANPTOP_ISCCPCOSP")
      end if
    end if 
    if (vars(i) .eq. "MEANCLDALB_ISCCPCOSP") then
      B = get_MEANCLDALB_ISCCPCOSP (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"MEANCLDALB_ISCCPCOSP")
      end if
    end if 
    if (vars(i) .eq. "CLDTOT_MISR") then
      B = get_CLDTOT_MISR (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTOT_MISR")
      end if
    end if 
    if (vars(i) .eq. "CLDLOW_MISR") then
      B = get_CLDLOW_MISR (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDLOW_MISR")
      end if
    end if 
    if (vars(i) .eq. "CLDMED_MISR") then
      B = get_CLDMED_MISR (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDMED_MISR")
      end if
    end if 
    if (vars(i) .eq. "CLDHGH_MISR") then
      B = get_CLDHGH_MISR (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDHGH_MISR")
      end if
    end if 
    if (vars(i) .eq. "CLDTHICK_MISR") then
      B = get_CLDTHICK_MISR (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTHICK_MISR")
      end if
    end if 
    if (vars(i) .eq. "CLDTOT_MODIS") then
      B = get_CLDTOT_MODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTOT_MODIS")
      end if
    end if 
    if (vars(i) .eq. "CLDLOW_MODIS") then
      B = get_CLDLOW_MODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDLOW_MODIS")
      end if
    end if 
    if (vars(i) .eq. "CLDMED_MODIS") then
      B = get_CLDMED_MODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDMED_MODIS")
      end if
    end if 
    if (vars(i) .eq. "CLDHGH_MODIS") then
      B = get_CLDHGH_MODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDHGH_MODIS")
      end if
    end if 
    if (vars(i) .eq. "CLDTHICK_MODIS") then
      B = get_CLDTHICK_MODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTHICK_MODIS")
      end if
    end if 
    if (vars(i) .eq. "CLWMODIS") then
      B = get_CLWMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLWMODIS")
      end if
    end if 
    if (vars(i) .eq. "CLIMODIS") then
      B = get_CLIMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLIMODIS")
      end if
    end if 
    if (vars(i) .eq. "IWPMODIS") then
      B = get_IWPMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"IWPMODIS")
      end if
    end if 
    if (vars(i) .eq. "LWPMODIS") then
      B = get_LWPMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"LWPMODIS")
      end if
    end if 
    if (vars(i) .eq. "REFFCLIMODIS") then
      B = get_REFFCLIMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"REFFCLIMODIS")
      end if
    end if 
    if (vars(i) .eq. "REFFCLWMODIS") then
      B = get_REFFCLWMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"REFFCLWMODIS")
      end if
    end if 
    if (vars(i) .eq. "TAUTLOGMODIS") then
      B = get_TAUTLOGMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TAUTLOGMODIS")
      end if
    end if 
    if (vars(i) .eq. "TAUILOGMODIS") then
      B = get_TAUILOGMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TAUILOGMODIS")
      end if
    end if 
    if (vars(i) .eq. "TAUWLOGMODIS") then
      B = get_TAUWLOGMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TAUWLOGMODIS")
      end if
    end if 
    if (vars(i) .eq. "TAUTMODIS") then
      B = get_TAUTMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TAUTMODIS")
      end if
    end if 
    if (vars(i) .eq. "TAUIMODIS") then
      B = get_TAUIMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TAUIMODIS")
      end if
    end if 
    if (vars(i) .eq. "TAUWMODIS") then
      B = get_TAUWMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TAUWMODIS")
      end if
    end if 
    if (vars(i) .eq. "PCTMODIS") then
      B = get_PCTMODIS (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"PCTMODIS")
      end if
    end if 
    if (vars(i) .eq. "CLDTOT_CAL") then
      B = get_CLDTOT_CAL (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTOT_CAL")
      end if
    end if 
    if (vars(i) .eq. "CLDLOW_CAL") then
      B = get_CLDLOW_CAL (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDLOW_CAL")
      end if
    end if 
    if (vars(i) .eq. "CLDMED_CAL") then
      B = get_CLDMED_CAL (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDMED_CAL")
      end if
    end if 
    if (vars(i) .eq. "CLDHGH_CAL") then
      B = get_CLDHGH_CAL (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDHGH_CAL")
      end if
    end if 
    if (vars(i) .eq. "CLDTOT_CS2") then
      B = get_CLDTOT_CS2 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTOT_CS2")
      end if
    end if 

    if (vars(i) .eq. "CDNUMC") then
      B = get_CDNUMC (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("CDNUMC not present in test case input file.")
        delete (B)
        continue
      else  
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"CDNUMC")
        end if
      end if
    end if
    if (vars(i) .eq. "SIWC_226") then
      B = get_SIWC_226 (inptr2,outptr2)
      if (all(B.eq.-999.)) then
        print ("SIWC_226 not present in test case input file.")
        delete (B)
        continue
      else  
        if (sig_plot .eq. "True") then
          B_var = get_SIWC_226_VARIANCE (meansptr2,varptr2)
        end if
      end if
    end if   
  end if
 
  if (all(B.eq.-999.)) then
    print (vars(i)+" not present in control case input file.")
    delete(A)
    delete(B)
    continue       ; procede to next variable in do loop
  else
    if (sig_plot .eq. "True") then
      SIG = get_SIGNIFICANCE (A,A_var,nt1,B,B_var,nt2)
    end if
  end if

; compute area weighted mean of the fields
; after masking higher res data with lower res grid.

;  gblmean_A = wgt_areaave (A,gw1,1.0,0)
;  gblmean_B = wgt_areaave (B,gw2,1.0,0)

; compute RMSE of the two fields after interpolating to the
; same grid iff needed, and the mean of the difference of the
; interpolated fields


  if (nlat1 .eq. nlat2) then            ; same grids
    gblmean_A = wgt_areaave (A,gw1,1.0,0)
    gblmean_B = wgt_areaave (B,gw2,1.0,0)

    gblrmse = wgt_arearmse(A,B,gw1,1.0,0)
    troprmse = wgt_arearmse(A({minlat:maxlat},:),B({minlat:maxlat},:), \
                            gw1({minlat:maxlat}),1.0,0)
    C = A
    C = (/A - B/)
    gblmean_C = wgt_areaave(C,gw1,1.0,0)
    tropmean_C = wgt_areaave(C({minlat:maxlat},:),gw1({minlat:maxlat}),1.0,0)
  else                                   ; different grids
    if (nlat1 .gt. nlat2) then           ; interp A to nlat2

      tmp = B
      tmp = linint2(lon1,lat1,A,True,lon2,lat2,0)

      Amask = B             ; *RBN - The following lines are a cheat to make sure the printed
      Amask = (/B+tmp-B/)   ; means on the plots are consistant with the masking 
      Bmask = B             ; used in the difference of means, C. whenever
      Bmask = (/B-tmp+tmp/) ; there is anyy land/ice masking in the plots

      gblmean_A = wgt_areaave (Amask,gw2,1.0,0)
      gblmean_B = wgt_areaave (Bmask,gw2,1.0,0)

      
      gblrmse = wgt_arearmse(Amask,Bmask,gw2,1.0,0)
      troprmse = wgt_arearmse(Amask({minlat:maxlat},:),Bmask({minlat:maxlat},:), \
                              gw2({minlat:maxlat}),1.0,0)
      C = B
      C = (/tmp - B/)
      gblmean_C = wgt_areaave(C,gw2,1.0,0)
      tropmean_C = wgt_areaave(C({minlat:maxlat},:),gw2({minlat:maxlat}),1.0,0)

    else                                ; interp B to nlat1       
      
      tmp = A
      tmp = linint2(lon2,lat2,B,True,lon1,lat1,0)

      Bmask = A             ; *RBN - The following lines are a cheat to make sure the printed
      Bmask = (/A+tmp-A/)   ; means on the plots are consistant with the masking 
      Amask = A             ; used in the difference of means, C  whenever
      Amask = (/A-tmp+tmp/) ; there is anyy land/ice masking in the plots

      gblmean_A = wgt_areaave (Amask,gw1,1.0,0)
      gblmean_B = wgt_areaave (Bmask,gw1,1.0,0)

      gblrmse = wgt_arearmse(Amask,Bmask,gw1,1.0,0)
      troprmse = wgt_arearmse(Amask({minlat:maxlat},:),Bmask({minlat:maxlat},:), \
                              gw1({minlat:maxlat}),1.0,0)
      C = A
      C = (/A - tmp/)
      gblmean_C = wgt_areaave(C,gw1,1.0,0)
      
      tropmean_C = wgt_areaave(C({minlat:maxlat},:),gw1({minlat:maxlat}),1.0,0)
    end if
    delete (tmp)
    delete(Bmask)
    delete(Amask)
  end if


;--------------------- Open files for plots ------------------------------
  if (color_type .eq. "COLOR") then
    if (compare .eq. "OBS") then
      wks = gsn_open_wks(plot_type,root+"set5_"+season+"_"+obsvars(i)+"_obsc")
      if (any(vars(i).eq.tropvars)) then
        wksT = gsn_open_wks(plot_type,root+"set5_"+season+"_"+obsvars(i)+ \
               "_TROP_obsc")
        gsn_define_colormap (wksT,cmap)
      end if
    else
      wks = gsn_open_wks(plot_type,root+"set5_"+season+"_"+vars(i)+"_c") 
      if (any(vars(i).eq.tropvars)) then
        wksT = gsn_open_wks(plot_type,root+"set5_"+season+"_"+vars(i)+"_TROP_c")
        gsn_define_colormap (wksT,cmap)
      end if
    end if
    gsn_define_colormap (wks,cmap)
  else     ; MONO
    if (compare .eq. "OBS") then
      wks = gsn_open_wks(plot_type,root+"set5_"+season+"_"+obsvars(i)+"_obs") 
      if (any(vars(i).eq.tropvars)) then
        wksT=gsn_open_wks(plot_type,root+"set5_"+season+"_"+obsvars(i)+"_TROP_obs")
      end if
    else
      wks = gsn_open_wks(plot_type,root+"set5_"+season+"_"+vars(i)) 
      if (any(vars(i).eq.tropvars)) then
        wksT = gsn_open_wks(plot_type,root+"set5_"+season+"_"+vars(i)+"_TROP")
      end if
    end if
  end if

;------------------------ GLOBAL TROPICAL PLOTS ------------------------
  if (any(vars(i).eq.tropvars)) then
    tropmean = wgt_areaave(A({minlat:maxlat},:),gw1({minlat:maxlat}),1.0,0)
    min1 = min(A({minlat:maxlat},:))
    max1 = max(A({minlat:maxlat},:))
    min2 = min(B({minlat:maxlat},:))
    max2 = max(B({minlat:maxlat},:))
    if (color_type .eq. "COLOR") then
      trop@cnLevels = Tcntrs(i,:)
      trop@lbTitleString = "Min = "+sprintf("%6.2f",min1)+ \
                          " Max = "+sprintf("%6.2f",max1)
    else
      minab = min((/min1,min2/))
      maxab = min((/max1,max2/))
      mnmxint = nice_mnmxintvl(minab,maxab,tropcnlvls,False)
      trop@cnMinLevelValF = mnmxint(0)
      trop@cnMaxLevelValF = mnmxint(1)
      trop@cnLevelSpacingF = mnmxint(2)
    end if
    if (isvar("yrs_ave1")) then
      trop@tiMainString = case1+" (yrs "+yrs_ave1+")"
    else  
      trop@tiMainString = case1
    end if
    trop@gsnCenterString = "mean= "+sprintf("%6.2f",tropmean)
    trop@gsnLeftString = A@long_name
    trop@gsnRightString = A@units
    
    if (PALEO) then
      trop@mpDataBaseVersion = "Ncarg4_1"
      trop@mpDataSetName = paleocoast1
    end if

    plotT(0) = gsn_csm_contour_map_other(wksT,A,trop)  

    if (color_type .eq. "MONO") then
      plotT(0) = ZeroNegDashLineContour (plotT(0))
    else
      delete (trop@lbTitleString)
    end if
    delete (trop@tiMainString)
    delete (trop@gsnCenterString)

    tropmean = wgt_areaave(B({minlat:maxlat},:),gw2({minlat:maxlat}),1.0,0)
    if (isvar("yrs_ave2")) then
      trop@tiMainString = case2+" (yrs "+yrs_ave2+")"
    else  
      trop@tiMainString = case2
    end if
    trop@gsnCenterString = "mean= "+sprintf("%6.2f",tropmean)
    if (color_type .eq. "COLOR") then
      trop@lbTitleString = "Min = "+sprintf("%6.2f",min2)+ \
                          " Max = "+sprintf("%6.2f",max2)
    end if
    if (PALEO) then
      if (compare.eq."USER") then
        trop@mpDataSetName = paleocoast2
      else  
        delete(trop@mpDataBaseVersion)
        delete(trop@mpDataSetName)
      end if
    end if

    plotT(1) = gsn_csm_contour_map_other(wksT,B,trop)  

    if (color_type .eq. "MONO") then
      plotT(1) = ZeroNegDashLineContour (plotT(1))
    else
      delete (trop@lbTitleString)
      delete (trop@cnLevels)
    end if
    delete (trop@tiMainString)
    delete (trop@gsnCenterString)
  end if

  if (compare .eq. "OBS") then
    delete(gw2)
    delete(lat2)
    delete(nlat2)
    delete(lon2)
    delete(nlon2)
  end if
;------------------------- GLOBAL CE PLOTS ------------------------
  min1 = min(A)
  max1 = max(A)
  min2 = min(B)
  max2 = max(B)
  if (color_type .eq. "COLOR") then
    res@cnLevels = cntrs(i,:)
    res@lbTitleString = "Min = "+sprintf("%6.2f",min1)+ \
                       " Max = "+sprintf("%6.2f",max1)
    if (vars(i) .eq. "TREFHT_LAND" .or. vars(i).eq."PRECIP_LAND" .or. \
        vars(i) .eq. "PRECT_LAND") then
      res@cnRasterModeOn = True
    else
      res@cnRasterModeOn = False
    end if
  else
    minab = min((/min1,min2/))
    maxab = min((/max1,max2/))
    mnmxint = nice_mnmxintvl(minab,maxab,gblcnlvls,False)
    res@cnMinLevelValF = mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)
  end if
  if (PALEO) then
    res@mpDataBaseVersion = "Ncarg4_1"
    res@mpDataSetName = paleocoast1
  end if

  if (isvar("yrs_ave1")) then
    res@tiMainString = case1+" (yrs "+yrs_ave1+")"
  else  
    res@tiMainString = case1
  end if
  res@gsnLeftString = A@long_name
  res@gsnRightString = A@units
  res@gsnCenterString = "mean= "+sprintf("%6.2f",gblmean_A)


  plot(0) = gsn_csm_contour_map_ce(wks,A,res)   ; plot model data  
  if (color_type .eq. "MONO") then
    plot(0) = ZeroNegDashLineContour (plot(0))
  else
    delete (res@lbTitleString)
  end if
  delete (res@tiMainString)
  delete (res@gsnCenterString)
  if (isvar("yrs_ave2")) then
    res@tiMainString = case2+" (yrs "+yrs_ave2+")"
  else  
    res@tiMainString = case2
  end if


  if (color_type .eq. "COLOR") then
    res@gsnCenterString = "mean= "+sprintf("%6.2f",gblmean_B)
    res@lbTitleString = "Min = "+sprintf("%6.2f",min2)+ \
                       " Max = "+sprintf("%6.2f",max2)
  else
    res@gsnCenterString = "mean= "+sprintf("%6.2f",gblmean_B)
  end if
  if (PALEO) then
    if (compare.eq."USER") then
      res@mpDataSetName = paleocoast2
    else
      delete(res@mpDataBaseVersion)
      delete(res@mpDataSetName)
    end if
  end if


  plot(1) = gsn_csm_contour_map_ce(wks,B,res)   ; plot model or obs
  if (color_type .eq. "MONO") then
    plot(1) = ZeroNegDashLineContour (plot(1))
  else
    delete (res@lbTitleString)
    delete (res@cnLevels)
  end if
  delete (res@tiMainString)
  delete (res@gsnCenterString)
  delete (res@gsnLeftString)
  delete (min1)
  delete (max1)
  delete (min2)
  delete (max2)


;------------------------ DIFFERENCE PLOTS --------------------------
  if (PALEO .and. (compare.ne."USER" .or. \
    (compare.eq."USER" .and. .not.DIFFS))) then
;   NO DIFFERENCE PLOTS MADE
    if (any(vars(i).eq.tropvars)) then    ; Tropical region
      panT@txString = season
      if (time_stamp .eq. "True") then
        panT@gsnPanelBottom = 0.05
        gsn_panel(wksT,plotT(0:1),(/2,1/),panT)
        infoTimeStamp(wksT, 0.011, "DIAG Version: "+version)
      else
        gsn_panel(wksT,plotT(0:1),(/2,1/),panT)
      end if
      frame(wksT)
      delete (trop@gsnLeftString)
      delete (trop@gsnRightString)
    end if
    if (color_type .eq. "MONO") then
      pan@txString = season
    end if
    if (time_stamp .eq. "True") then
      pan@gsnPanelBottom = 0.05
      gsn_panel(wks,plot(0:1),(/2,1/),pan)
      infoTimeStamp(wks, 0.011, "DIAG Version: "+version)
    else
      gsn_panel(wks,plot(0:1),(/2,1/),pan)
    end if
    if (color_type .eq. "COLOR") then
      txres = True
      txres@txFont = "helvetica-bold"
      txres@txFontHeightF = 0.025
      gsn_text_ndc (wks,season,0.85,0.97,txres)
    end if
    frame(wks)
    delete(A)
    delete(B)
  else                                     
;   MAKE DIFFERENCE PLOTS
    ; tropical plots
    if (any(vars(i).eq.tropvars)) then
      mind = min(C({minlat:maxlat},:))
      maxd = max(C({minlat:maxlat},:))
      trop@tiMainString = case1+" - "+case2
      trop@gsnLeftString = "mean = "+sprintf("%6.2f",tropmean_C)
      trop@gsnCenterString = "rmse = "+sprintf("%6.2f",troprmse)

      if (PALEO) then
        trop@mpDataBaseVersion = "Ncarg4_1"
        trop@mpDataSetName = paleocoast1
      end if

      if (color_type .eq. "COLOR") then
        trop@lbTitleString = "Min = "+sprintf("%6.2f",mind)+ \
                            " Max = "+sprintf("%6.2f",maxd)
        trop@cnLevels = dTcntrs(i,:) 
        plotT(2) = gsn_csm_contour_map_other(wksT,C,trop)
        delete (trop@cnLevels)
        delete (trop@lbTitleString)
      else
        mnmxint = nice_mnmxintvl(mind,maxd,diffcnlvls,False)
        trop@cnMinLevelValF = mnmxint(0)
        trop@cnMaxLevelValF = mnmxint(1)
        trop@cnLevelSpacingF = mnmxint(2)
        plotT(2) = gsn_csm_contour_map_other(wksT,C,trop)  
        plotT(2) = ZeroNegDashLineContour (plotT(2))
      end if
      delete (trop@tiMainString)
      delete (trop@gsnLeftString)
      delete (trop@gsnCenterString)
      delete (trop@gsnRightString)
 
      ; SIGNIFICANCE PLOT
      if (sig_plot .eq. "True") then
        trop@gsnLeftString = ""
        trop@gsnRightString = ""
        trop@tiMainString = "T-test of the two means at each grid point"
        trop@cnLevels =  SigLvl
        if (color_type .eq. "COLOR") then
          trop@cnFillColors = (/13,0/)
          trop@gsnCenterString="Colored cells are significant at the "+SigLvl+" level"
          trop@lbLabelBarOn = False
          trop@cnRasterModeOn = True
          plotT(3) = gsn_csm_contour_map_other(wksT,SIG,trop)
          delete (trop@cnFillColors)
          trop@cnRasterModeOn = False
          trop@lbLabelBarOn = True
        else
          trop@cnLevelSelectionMode = "ExplicitLevels"
          trop@gsnCenterString="Hatched areas are significant at the "+SigLvl+" level"
          trop@cnInfoLabelOn = False 
          trop@cnLineThicknessF = 2.0
          plotT(3) = gsn_csm_contour_map_other(wksT,SIG,trop)
          plotT(3) = SigPattern (plotT(3),SigLvl,5)
          trop@cnLevelSelectionMode = "ManualLevels"
          trop@cnInfoLabelOn = True
          trop@cnLineThicknessF = 1.0
        end if
        delete (trop@tiMainString)
        delete (trop@gsnCenterString)
        delete (trop@gsnLeftString)
        delete (trop@gsnRightString)
        delete (trop@cnLevels)
      end if
      delete (mind)
      delete (maxd)
    end if

;   Global CE plots
    mind = min(C)
    maxd = max(C)
    res@tiMainString = case1+" - "+case2
    res@gsnLeftString = "mean = "+sprintf("%6.2f",gblmean_C)
    res@gsnCenterString = "rmse = "+sprintf("%6.2f",gblrmse)

    if (PALEO) then
      res@mpDataBaseVersion = "Ncarg4_1"
      res@mpDataSetName = paleocoast1
    end if

    if (color_type .eq. "COLOR") then
      res@lbTitleString = "Min = "+sprintf("%6.2f",mind)+ \
                         " Max = "+sprintf("%6.2f",maxd)
      res@cnLevels = dcntrs(i,:) 
      plot(2) = gsn_csm_contour_map_ce(wks,C,res)   ; plot differences 
      delete (res@cnLevels)
    else
      mnmxint = nice_mnmxintvl(mind,maxd,diffcnlvls,False)
      res@cnMinLevelValF = mnmxint(0)
      res@cnMaxLevelValF = mnmxint(1)
      res@cnLevelSpacingF = mnmxint(2)
      plot(2) = gsn_csm_contour_map_ce(wks,C,res)  
      plot(2) = ZeroNegDashLineContour(plot(2))
    end if
    delete (res@tiMainString)
    delete (res@gsnLeftString)
    delete (res@gsnRightString)
    delete (res@gsnCenterString)

    ; SIGNIFICANCE PLOT
    if (sig_plot .eq. "True") then
      res@gsnLeftString = ""
      res@gsnRightString = ""
      res@tiMainString = "T-test of the two means at each grid point"
      res@cnLevels =  SigLvl
      if (color_type .eq. "COLOR") then
        res@cnFillColors = (/13,0/)
        res@gsnCenterString="Colored cells are significant at the "+SigLvl+" level"
        res@lbLabelBarOn = False
        res@cnRasterModeOn = True
        plot(3) = gsn_csm_contour_map_ce(wks,SIG,res)
        delete (res@cnFillColors)
        res@cnRasterModeOn = False
        res@lbLabelBarOn = True
      else
        res@cnLevelSelectionMode = "ExplicitLevels"
        res@gsnCenterString="Hatched areas are significant at the "+SigLvl+" level"
        res@cnInfoLabelOn = False 
        res@cnLineThicknessF = 2.0
        plot(3) = gsn_csm_contour_map_ce(wks,SIG,res)
        plot(3) = SigPattern (plot(3),SigLvl,5)
        res@cnLevelSelectionMode = "ManualLevels"
        res@cnInfoLabelOn = True
        res@cnLineThicknessF = 1.0
      end if
      delete (res@tiMainString)
      delete (res@gsnCenterString)
      delete (res@gsnLeftString)
      delete (res@gsnRightString)
      delete (res@cnLevels)
      delete (SIG)
    end if

    delete (mind)
    delete (maxd)
    delete (C)
    delete (A)
    delete (B)


;   Panel plots
    if (any(vars(i).eq.tropvars)) then    ; Tropics
      panT@txString = season
      if (time_stamp .eq. "True") then
        panT@gsnPanelBottom = 0.06
      end if
      if (sig_plot .eq. "True") then
        if (color_type .eq. "COLOR") then
          gsn_panel(wksT,plotT,(/2,2/),panT)
        else
          gsn_panel(wksT,plotT,(/4,1/),panT)
        end if
      else
        gsn_panel(wksT,plotT,(/3,1/),panT)
      end if
      if (time_stamp .eq. "True") then
        infoTimeStamp(wksT, 0.011, "DIAG Version: "+version)
      end if
      frame(wksT)
    end if

    if (color_type .eq. "MONO") then
      pan@txFontHeightF = 0.015
      pan@txString = season
    end if
    if (time_stamp .eq. "True") then
      pan@gsnPanelBottom = 0.06
    end if
    if (sig_plot .eq. "True") then
      gsn_panel(wks,plot,(/2,2/),pan)
    else
      gsn_panel(wks,plot,(/3,1/),pan)
    end if
    if (time_stamp .eq. "True") then
      infoTimeStamp(wks, 0.011, "DIAG Version: "+version)
    end if
    if (color_type .eq. "COLOR") then
      txres = True
      txres@txFontHeightF = 0.022
      txres@txFont = "helvetica-bold"
      if (sig_plot .eq. "True") then
        gsn_text_ndc (wks,season,0.50,0.94,txres)
      else
        gsn_text_ndc (wks,season,0.76,0.97,txres)
      end if
    end if
    frame(wks)

  end if      ; difference plots
end do        ; variable 


end
