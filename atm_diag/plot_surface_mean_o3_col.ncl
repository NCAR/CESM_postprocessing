; NCL script
;   plot_surface_mean_o3_col.ncl
; Simone Tilmes, Nov 2013
;**************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/function_calc_column_o3.ncl"

begin
 compare    = getenv("COMPARE")
 plot_type  = getenv("PLOTTYPE")
 color_type = getenv("COLORTYPE")
 rgb_file   = getenv("RGB_FILE")
 version    = getenv("DIAG_VERSION")
 wkdir      = getenv("WKDIR")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename
 testcase   = getenv("TEST_CASE")
 compcase   = getenv("STD_CASE")
 season     = getenv("SEASON")

;************************************************************************
p0     = 1000.     ; mb required by vinth2p
interp = 2         ; log interpolation
extrap = False     ; no extrapolation past psfc.
;************************************************************************
; get column O3 from OMI:
 f_omi = "$OBS_DATA/cam-chem/OMI_o3column_climo_"+season+".nc"
 omi = addfile(f_omi,"r")
 vars = (/"o3strat","o3strat_rms","o3trop","o3trop_rms"/)
 o3strat  = omi->o3strat  
 o3strat_rms  = omi->o3strat_rms  
 o3trop  = omi->o3trop
 o3trop_rms  = omi->o3trop_rms
 o3strat = where(o3strat.lt.0,-999,o3strat) 
 o3trop = where(o3trop.lt.0,-999,o3trop) 
 o3strat_rms = where(o3strat_rms.lt.0,-999,o3strat_rms) 
 o3trop_rms = where(o3trop_rms.lt.0,-999,o3trop_rms) 

 o3trop@_FillValue = -999
 o3strat@_FillValue = -999
 o3trop_rms@_FillValue = -999
 o3strat_rms@_FillValue = -999
 o3trop_rms  = omi->o3trop_rms
 lat_omi = omi->lat
;tp1 = omi->tp
;tp_rms1 = omi->tp_rms
; apply transpose (y,x) -> (x,y)
;o3strat = transpose(o3strat1)
;o3strat_rms = transpose(o3strat_rms1)
;o3trop = transpose(o3trop1)
;o3trop_rms = transpose(o3trop_rms1)
 gw  = latRegWgt(lat_omi, "double", 0)
;************************************************************************
; loop over stratospheric and tropospheric column (different plots)
o3case = (/0,1,2/)
ca_fact = (/1.,1.,0.1/)
o3case_n = (/"total","strat","trop"/)
do ca = 0, 2 
 if ca.eq.0 then 
   C = o3strat
   C_std = o3strat_rms
   C = (/o3trop+o3strat/)
   C_std = (/o3trop_rms+o3strat_rms/)
   C@long_name = "Total Column" 
 end if
 if ca.eq.1 then 
   C = o3strat 
   C_std = o3strat_rms
 end if
 if ca.eq.2 then 
   C = o3trop
   C_std = o3trop_rms
 end if
 C&lon@units = "degrees_east"
 C&lat@units = "degrees_north"
 C_std&lon@units = "degrees_east"
 C_std&lat@units = "degrees_north"
 gblmean_C = wgt_areaave(C,gw,1.0,0)
 gblmean_C_std = wgt_areaave(C_std,gw,1.0,1)

; get column O3 from the model:
; CASE 1 MODEL
 infile1 = testcase+"_"+season+"_climo.nc"
 inptr1 = addfile(infile1,"r")

 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case           ; case name
 end if
 case1 = str_strip(case1)
  
o3col_climo1 = -1
if (isfilevar(inptr1,"O3")) then
 delete(o3col_climo1)
 o3col_climo1 = function_calc_column_o3(inptr1,o3case(ca))  ;o3case:0 total column, o3case:1 strat column, o3case:2 trop column
 A = o3col_climo1(:,:)
 title_t = A@long_name
 A&LON@units = "degrees_east"
 A&LAT@units = "degrees_north"
else 
 A = C 
 A@_FillValue = -999.
 A = A@_FillValue 
 title_t = A@long_name
end if
gblmean_A = wgt_areaave(A,gw,1.0,0)

D = A
D = (/A-C/)
gblmean_D = wgt_areaave(D,gw,1.0,0)
delete(o3col_climo1)
 
; CASE 2 IS OBS OR MODEL
 if (compare .eq. "OBS") then
 else                        ;  CASE 2 IS MODEL
   infile2 = compcase+"_"+season+"_climo.nc"
   inptr2 = addfile(infile2,"r")

  if (case_names .eq. "True") then
    case2 = getenv("CASE2")
  else
    case2 = inptr2@case           ; case name
  end if
  case2 = str_strip(case2)

o3col_climo2 = -1
  if (isfilevar(inptr2,"O3")) then
   delete(o3col_climo2)
   o3col_climo2 = function_calc_column_o3(inptr2,o3case(ca))  ;o3case:0 total column, o3case:1 strat column, o3case:2 trop column
   B = o3col_climo2(:,:)
   B&LON@units = "degrees_east"
   B&LAT@units = "degrees_north"
  else 
   B = C 
   B@_FillValue = -999.
   B = B@_FillValue 
  end if
  E = B
  E = (/B-C/)
  gblmean_B = wgt_areaave(B,gw,1.0,0)
  gblmean_E = wgt_areaave(E,gw,1.0,0)
  delete(o3col_climo2)
 end if

; define plot
 wks = gsn_open_wks(plot_type,wkdir+"cset4_o3_column_omi_"+season+"_"+o3case_n(ca))
 
 if (compare .eq. "OBS") then
    plot = new(4,"graphic")
 else
    plot = new(6,"graphic")
 end if
; define plot generals
;********************************************************
 res                 = True
 gsn_merge_colormaps(wks,"amwg","amwg_blueyellowred") ; merge two color maps
 res@gsnDraw                = False      
 res@gsnFrame               = False
 res@gsnMaximize = False
  res@cnFillOn             = True                  ; turn on color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLineLabelsOn    = False
  res@tmXTOn    = False
  res@tmXBOn = False 
  res@tmYLLabelFontHeightF = 0.015
  res@tmYRMode             = "Automatic"          ; turn off special labels on right axis
  res@lbLabelBarOn      = True
  res@lbOrientation     = "Vertical"
  res@cnInfoLabelOn        = False
  res@cnLevelSelectionMode      = "ExplicitLevels"       ; manual levels
  res@cnMissingValFillColor = 0
  res@txFontHeightF = 0.020
  res@txFont = "helvetica-bold"
  res@gsnPaperOrientation = "landscape"
  res@pmLegendWidthF = 0.15
  res@pmLegendHeightF = 0.15
  res@lgLabelFontHeightF = .022
  res@lgPerimOn = True
  res@txFontHeightF = 0.022
;*********************************************************************
if (color_type .eq. "COLOR") then
   res@cnLevelSelectionMode = "ExplicitLevels"
   res@cnFillOn             = True
   res@cnLinesOn            = False
   res@cnLineLabelsOn       = False
   res@lbTitleOn = True
   res@lbTitleString = "DU" 
   res@lbLabelFontHeightF = 0.018
   res@lbTitleFontHeightF = 0.02
   res@lbLabelStride  = 2
   res@lbOrientation = "Horizontal"
 else
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnLinesOn              = True
   res@cnLineLabelsOn         = True
   res@cnLineLabelInterval    = 1
   res@cnLineLabelFontHeightF = .02
   res@cnInfoLabelFontHeightF = .02
   cnlvls = 15
   diffcnlvls = 12
 end if
; contour levels
 con = new(13,float)
 dcon = new (13,float)
 fact = ca_fact(ca)
 con=fact*(/150.,175.,200.,225.,250.,275.,300.,325.,350.,375.,400.,425.,450./)
 con=fact*(/150.,175.,200.,225.,250.,275.,300.,325.,350.,375.,400.,425.,450./)
 dcon=fact*(/-80.,-60.,-50.,-40.,-30.,-20.,20.,30.,40.,50.,60.,80.,100./)

;**********************************************************************
 maintitle = "Test" 
 units = A@units 
 res@txString = title_t 
 res@tiMainString = title_t 
   res@cnLevels = con(:)

  res@cnFillColors   = (/3,4,5,6,7,8,9,10,11,12,13,14,15/)
  res@gsnLeftString = "OMI/MLS"
  res@gsnRightString = "mean = "+sprintf("%6.2f",gblmean_C)
  plot(0) = gsn_csm_contour_map_ce(wks,C,res)   ; plot model data
  res@cnLevels = 0.04*con(:)
  res@gsnLeftString = "OMI/MLS STD"
  res@gsnRightString = "mean = "+sprintf("%6.2f",gblmean_C_std)
  plot(1) = gsn_csm_contour_map_ce(wks,C_std,res)   ; plot model data
  res@cnLevels = con(:)
  res@gsnLeftString = case1 
  res@gsnRightString = "mean = "+sprintf("%6.2f",gblmean_A)
  plot(2) = gsn_csm_contour_map_ce(wks,A,res)   ; plot model data
  res@cnLevels = dcon(:)
  res@cnFillColors   = (/20,21,22,23,24,25,0,27,28,29,30,31,32/) 
  res@gsnLeftString = case1+" - OMI/MLS"
  res@gsnRightString = "mean = "+sprintf("%6.2f",gblmean_D)
  plot(3) = gsn_csm_contour_map_ce(wks,D,res)   ; plot model data
 if (compare .ne. "OBS") then
  res@cnFillColors   = (/3,4,5,6,7,8,9,10,11,12,13,14,15/)
  res@cnLevels = con(:)
  res@gsnLeftString = case2 
  res@gsnRightString = "mean = "+sprintf("%6.2f",gblmean_B)
  plot(4) = gsn_csm_contour_map_ce(wks,B,res)   ; plot model data
  res@cnLevels = dcon(:)
  res@gsnLeftString = case2+" - OMI/MLS"
  res@cnFillColors   = (/20,21,22,23,24,25,0,27,28,29,30,31,32/) 
  res@gsnRightString = "mean = "+sprintf("%6.2f",gblmean_E)
  plot(5) = gsn_csm_contour_map_ce(wks,E,res)   ; plot model data
  delete(B)
  delete(E)
 end if

  res@tiMainString = title_t 
  res@gsnRightString = A@units
; res@gsnCenterString = "rmse = "+sprintf("%6.2f",gblrmse)
;*********************************************
; add lat long info to plot
    txres               = True
    txres@txFontHeightF = 0.017

    title = "OMI/MLS Column Ozone Climo 2004-2010 "+season
    gsn_text_ndc(wks,title,.50,.98,txres)

    panres = True
    panres@gsnFrame = False
    panres@gsnMaximize = True
    panres@gsnPanelTop = 0.96
    if (time_stamp .eq. "True") then
      panres@gsnPanelBottom = 0.05
      if (compare .eq. "OBS") then
       gsn_panel (wks,plot,(/2,2/),panres)
      else
       gsn_panel (wks,plot,(/3,2/),panres)
      end if
      infoTimeStamp(wks,0.011,"DIAG Version: "+version)
    else
      if (compare .eq. "OBS") then
       gsn_panel (wks,plot,(/2,2/),panres)
      else
       gsn_panel (wks,plot,(/3,2/),panres)
      end if
    end if
    frame(wks)
;-------------------------------------------------------------------------
 delete(plot)
 delete(res@txString)
 delete(res@tiMainString)
 delete(A)
 delete(C)
 delete(D)
end do ; cases

end
