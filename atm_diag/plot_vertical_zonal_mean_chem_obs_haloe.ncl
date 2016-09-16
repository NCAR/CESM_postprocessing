; NCL script
; plot_vertical_zonal_mean_chem_obs_haloe.ncl
; Simone Tilmes, Oct 2015
;**************************************
; compare to HALOE observations

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_vertical.ncl"

begin
 compare    = getenv("COMPARE")
 plot_type  = getenv("PLOTTYPE")
 color_type = getenv("COLORTYPE")
 rgb_file   = getenv("RGB_FILE")
 season     = getenv("SEASON")
 version    = getenv("DIAG_VERSION")
 wkdir      = getenv("WKDIR")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename
 testcase   = getenv("TEST_CASE")
 compcase   = getenv("STD_CASE")
;mg_micro   = getenv("MG_MICRO")

 use_waccm_levs = getenv("USE_WACCM_LEVS")
 use_chem_levs = getenv("USE_CHEM_LEVS")

;************************************************************************
p0     = 1000.     ; mb required by vinth2p
interp = 2         ; log interpolation
extrap = False     ; no extrapolation past psfc.
;************************************************************************
vars = (/"H2O","HCL","CH4","NO","NO2","O3","HF"/)
vars_haloe = (/"H2O","HCl","CH4","NO","NO2","O3","HF"/)
units = (/"ppm","ppb","ppm","ppb","ppb","ppm","ppb"/)
factor =  (/1.e+06,1.e+09,1.e+06,1.e+09,1.e+09,1.e+06,1.e+09/) 
; con(:)=cfactor(v)*(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,16/)+offset(v)   
; dcon(:)=dfactor(v)*(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
cfactor = (/0.5,1.,0.2,0.7,0.7,0.5,10./)
dfactor = (/20.,20.,20.,20.,20.,20.,20.,20./)
offset = (/2.,0.,0.,0.,0.,0.,0.,0./)
nvars = dimsizes(vars)
; contour levels
  con = new((/15/),float)
  dcon = new ((/15/),float)

; loop over variables
do v = 0,nvars-1
;do v = 5,5
;************************************************************************
 ; read HALOE climatology:
  ; get HALOE information
; haloe = "$OBS_DATA/HALOE_"+season+"_climo.nc"
  f_haloe = "/glade/p/acd/tilmes/climos/haloe/HALOE_"+season+"_climo.nc"
  haloe = addfile(f_haloe,"r")
  haloe_var = haloe->$vars_haloe(v)$
  haloe_lev = haloe->lev
  haloe_lat = haloe->lat
  haloe_var@units = units(v)
  haloe_var@long_name = vars(v) 
;************************************************************************

; CASE 1 MODEL
  nc=1 
  inptr1 = addfile(infile1,"r")
  if (case_names .eq. "True") then
   case1 = getenv("CASE1")
  else
   case1 = inptr1@case           ; case name
  end if
  case1 = str_strip(case1)

  if (isatt(inptr1,"yrs_averaged")) then
   yrs_ave1 = inptr1@yrs_averaged
  end if
  tmp = inptr1->lat
  if (typeof(tmp).eq."double") then
   lat1 = dble2flt(tmp)
  else
   lat1 = tmp
  end if
  delete(tmp) 
 
  lev1 = inptr1->lev
  lon1 = inptr1->lon
  nlat1 = dimsizes(lat1)
  nlon1 = dimsizes(lon1)
  nlev1 = dimsizes(lev1)
  hyam1 = inptr1->hyam
  hybm1 = inptr1->hybm
  tmp = inptr1->PS
  if (typeof(tmp).eq."double") then
        ps1 = dble2flt(tmp)
  else
     ps1 = tmp
  end if
  delete(tmp)
 model1= haloe_var
 model1_diff = haloe_var
 if (isfilevar(inptr1,vars(v))) then
  var1_model  = inptr1->$vars(v)$

; interpolate to  measurement levels
  press1 = pres_hybrid_ccm(ps1,p0,hyam1,hybm1)
  pp1 = press1 ; mbar
  var1 = int2p_n_Wrap (pp1,var1_model,haloe_lev,interp,1)
  ; zonal mean
  var_zm1 = dim_avg_n_Wrap(var1,3)
  ; regrid to haloe latitudes
  var_zmlat1 = linint1_n_Wrap(lat1,var_zm1,False,haloe_lat,0,2)
  var_zm_lat1 = (var_zmlat1(0,:,:))
  delete(var1_model)
  delete(var1)
  delete(var_zm1)
  delete(var_zmlat1)
 else
 var_zm_lat1=haloe_var
 end if
 delete(lat1)
 delete(lev1)
 delete(hyam1)
 delete(hybm1)
  model1 = (/var_zm_lat1*factor(v)/)
 if vars(v).ne."T" then
  model1_diff = (/(100*(model1-haloe_var)/haloe_var)/)
  model1_diff@units = "%" 
 else
  model1_diff = (/model1-haloe_var/)
  model1_diff@units = units(v)
 end if
  model1@units = units(v)
  model1@long_name = vars(v) 

; CASE 2 IS OBS (OR MODEL)
  nc=2
  if (compare .ne. "OBS") then
   ; CASE 2 MODEL
   inptr2 = addfile(infile2,"r")
   if (case_names .eq. "True") then
    case2 = getenv("CASE2")
   else
    case2 = inptr2@case           ; case name
   end if
   case2 = str_strip(case2)
 
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
 
   lev2 = inptr2->lev
   lon2 = inptr2->lon
   nlat2 = dimsizes(lat2)
   nlon2 = dimsizes(lon2)
   nlev2 = dimsizes(lev2)
   hyam2 = inptr2->hyam
   hybm2 = inptr2->hybm
   tmp = inptr2->PS
   if (typeof(tmp).eq."double") then
         ps2 = dble2flt(tmp)
   else
      ps2 = tmp
   end if
  delete(tmp)
  model2 = haloe_var
  model2_diff = haloe_var
  if (isfilevar(inptr2,vars(v))) then
   var2_model  = inptr2->$vars(v)$
   ; interpolate to  measurement levels
   press2 = pres_hybrid_ccm(ps2,p0,hyam2,hybm2)
   pp2 = press2 ; mbar
   var2 = int2p_n_Wrap (pp2,var2_model,haloe_lev,interp,1)
   ; zonal mean
   var_zm2 = dim_avg_n_Wrap(var2,3)
   ; regrid to haloe latitudes
   var_zmlat2 = linint1_n_Wrap(lat2,var_zm2,False,haloe_lat,0,2)
   var_zm_lat2 = (var_zmlat2(0,:,:))
   delete(var2_model)
   delete(var2)
   delete(var_zm2)
   delete(var_zmlat2)
  else
   var_zm_lat2=haloe_var
  end if
  delete(lat2)
  delete(lev2)
  delete(hyam2)
  delete(hybm2)
  model2 = (/var_zm_lat2*factor(v)/)
  if vars(v).ne."T" then
   model2_diff = (/(100*(model2-haloe_var)/haloe_var)/)
   model2_diff@units = "%" 
  else
   model2_diff = (/model2-haloe_var /)
   model2_diff@units = units(v)
  end if
  model2@units = units(v)
  model2@long_name = vars(v) 
 end if
 
;**********************************************************************
; common resources for contour plots
 cnplot = new(nc*3,"graphic")
 cres                        = True        
 cres@gsnDraw                = False      
 cres@gsnFrame               = False
 cres@trXReverse             = False
 cres@tiYAxisString          = "Pressure (mb)"  
 cres@txFontHeightF = 0.023
 if (color_type .eq. "COLOR") then
   cres@cnLevelSelectionMode = "ExplicitLevels" 
   cres@cnFillOn             = True
   cres@cnLinesOn            = False
   cres@cnLineLabelsOn       = False
   cres@lbTitleOn = True
   cres@lbLabelFontHeightF = 0.018
   cres@lbTitleFontHeightF = 0.02
   cmap = RGBtoCmap(rgb_file)
 else
   cres@cnLevelSelectionMode = "ManualLevels" 
   cres@cnLinesOn              = True 
   cres@cnLineLabelsOn         = True 
   cres@cnLineLabelInterval    = 1
   cres@cnLineLabelFontHeightF = .02
   cres@cnInfoLabelFontHeightF = .02
   cnlvls = 15
   diffcnlvls = 12
 end if
;-------------------------------------------
; common resoureces for panel plot 
 pan = True
 pan@gsnMaximize = True
 ;if nc.eq.2 then
  ;pan@gsnPaperOrientation = "landscape"
 ;else
  pan@gsnPaperOrientation = "portrait"
 ;end if
 pan@txFontHeightF = 0.018
 pan@gsnFrame = False
;***********************************************************

  pan@txString = vars(v)+" "+season
  con(:)=cfactor(v)*(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,16/)+offset(v)   
  dcon(:)=dfactor(v)*(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)

  cres@trYMinF = min(haloe_lev)   
  cres@trYMaxF = max(haloe_lev)
  cres@trYMaxF = 100. 
  cres@trYMinF = 1. 
  data_haloe = haloe_var                  ; model data(lev,lat)
  data_haloe&lev@units = "hPa"



;------------------------- Open files for plots -----------------------------
  set_prefix = "wset2_haloe_"
  if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+vars(v)+"_c")
      gsn_define_colormap(wks,cmap)
  else
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+vars(v))
  end if
;-------------------------------------------------------------------------
; case plots of latitude(x) vs. pressure/height(y)

; if (any(vars(v) .eq. linear)) then
;   cres@trYLog = False
; else
    cres@trYLog = True
; end if

  min1 = min(data_haloe)
  max1 = max(data_haloe)
  min2 = min(model1)
  max2 = max(model1)
  min3 = min(model2)
  max3 = max(model2)

  if (color_type .eq. "COLOR") then
    cres@lbLabelStride  = 2
    cres@lbOrientation = "Horizontal"
    cres@cnLevels = con(:)
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                       "  MAX = "+sprintf("%6.2f",max1)
  else
    minab = min((/min1,min2/))
    maxab = min((/max1,max2/))
    mnmxint = nice_mnmxintvl (minab,maxab,cnlvls,False)
    cres@cnMinLevelValF = mnmxint(0)
    cres@cnMaxLevelValF = mnmxint(1)
    cres@cnLevelSpacingF = mnmxint(2)
  end if

  if (isvar("yrs_ave1")) then
    main_case1 = case1+" (yrs "+yrs_ave1+")"
  else  
    main_case1 = case1
  end if

  cres@cnLevels = con(:)
  cres@tiMainString = "HALOE 1991-2005" 
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                       "  MAX = "+sprintf("%6.2f",max1)
  cnplot(0)  = gsn_csm_pres_hgt(wks,data_haloe,cres)
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                       "  MAX = "+sprintf("%6.2f",max2)
  cres@tiMainString = main_case1
  cnplot(1)  = gsn_csm_pres_hgt(wks,model1,cres)
   cres@tiMainString = case1+" - HALOE"
    cres@lbTitleString = "% Difference"
  cres@cnLevels = dcon(:)
  cnplot(2)  = gsn_csm_pres_hgt(wks,model1_diff,cres)

  if nc.eq.2 then
   if (isvar("yrs_ave1")) then
    main_case2 = case2+" (yrs "+yrs_ave2+")"
   else  
    main_case2 = case2
   end if
  cres@cnLevels = con(:)
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                       "  MAX = "+sprintf("%6.2f",max1)
   cres@tiMainString = "HALOE 1991-2005" 
   cnplot(1)  = gsn_csm_pres_hgt(wks,data_haloe,cres)
   cres@tiMainString = main_case1
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                       "  MAX = "+sprintf("%6.2f",max2)
   cnplot(2)  = gsn_csm_pres_hgt(wks,model1,cres)
   cres@tiMainString = main_case2
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min3)+ \
                       "  MAX = "+sprintf("%6.2f",max3)
   cnplot(3)  = gsn_csm_pres_hgt(wks,model2,cres)
    cres@lbTitleString = "% Difference"
   cres@tiMainString = case1+" - HALOE"
  cres@cnLevels = dcon(:)
   cnplot(4)  = gsn_csm_pres_hgt(wks,model1_diff,cres)
   cres@tiMainString = case2+" - HALOE"
   cnplot(5)  = gsn_csm_pres_hgt(wks,model2_diff,cres)
  end if

; if (color_type .eq. "MONO") then
;   cnplot(0) = ZeroNegDashLineContour(cnplot(0))
; else
;   delete (cres@lbTitleString)
; end if

; if (color_type .eq. "COLOR") then
;   cres@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
;                      "  MAX = "+sprintf("%6.2f",max2)
; end if

  if (color_type .eq. "MONO") then
    cnplot(1) = ZeroNegDashLineContour(cnplot(1))
  else
    delete (cres@cnLevels)
    delete (cres@lbLabelStride)
    delete (cres@lbOrientation)
    delete (cres@lbTitleString)
  end if
  delete (cres@tiMainString)
  delete (min1)
  delete (max1)
  delete (min2)
  delete (max2)

  if (time_stamp .eq. "True") then
    pan@gsnPanelBottom = 0.05
    gsn_panel(wks,cnplot,(/nc*3,2/),pan)         ; panel plot
    infoTimeStamp(wks,0.011,"DIAG Version: "+version)
  else
    gsn_panel(wks,cnplot,(/nc*3,2/),pan)         ; panel plot
  end if
  frame (wks)


  delete (cres@trYMinF)
  delete (cres@trYMaxF)
  delete(var_zm_lat1)
  delete (model1)
  delete (model1_diff)
  delete (data_haloe)
  if (compare.ne."OBS") then
   delete (model2)
   delete(var_zm_lat2)
   delete (model2_diff)
  end if
  delete(haloe_var)
  delete(haloe_lev)
end do ;v

end
