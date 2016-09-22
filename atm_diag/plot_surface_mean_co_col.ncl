; NCL script
;   plot_surface_mean_co_col.ncl
; Simone Tilmes, Nov 2013
;**************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH
load "$DIAG_CODE/functions_contrib.ncl"
 load "$DIAG_CODE/function_calc_mopitt_column_co.ncl"

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
;mg_micro   = getenv("MG_MICRO")

;************************************************************************
p0     = 1000.     ; mb required by vinth2p
interp = 2         ; log interpolation
extrap = False     ; no extrapolation past psfc.
;************************************************************************
; calculate column CO and apply MOPITT averaging kernel:
 ; get MOPITT information
 f_mopitt = "$OBS_DATA/cam-chem/mopitt_v6j_co_colm_clim.2003_2012.nc"
 mopitt = addfile(f_mopitt,"r")
 var = "retrieved CO total column"
 cocol_retr = mopitt->$var$
 var = "retrieved CO total column standard deviation"
 cocol_retr_std = mopitt->$var$ 
;************************************************************************

nmonths = 12
month =  sprinti("%0.2i", ispan(1,12,1))
; read climo
 do mo = 0,nmonths-1
 C = transpose(cocol_retr(mo,:,:)) 
 C@_FillValue=-999
 C = where(C .le.0,C@_FillValue,C)
 C = C*1.e-17
 C&longitude@units = "degrees_east"
 C&latitude@units = "degrees_north"
 C_std = transpose(cocol_retr_std(mo,:,:))
 C_std@_FillValue=-999
 C_std = where(C_std .le.0,C_std@_FillValue,C_std)
 C_std = C_std*1.e-17
 copy_VarMeta(C,C_std)
 
; CASE 1 MODEL
 infile1 = testcase+"_"+month(mo)+"_climo.nc"
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
 co_col_climo1 = function_calc_mopitt_column_co(inptr1,mopitt,mo) 
 A = transpose(co_col_climo1)*1.e-17
 copy_VarMeta(C,A)
 A&longitude@units = "degrees_east"
 A&latitude@units = "degrees_north"
 delete(co_col_climo1)
 
; CASE 2 IS OBS OR MODEL
 if (compare .eq. "OBS") then
 else                        ;  CASE 2 IS MODEL
   infile2 = compcase+"_"+month(mo)+"_climo.nc"
   inptr2 = addfile(infile2,"r")
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case
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
   co_col_climo2 = function_calc_mopitt_column_co(inptr2,mopitt,mo) 
   B = transpose(co_col_climo2)*1.e-17
   delete( co_col_climo2)
   copy_VarMeta(C,B)
   B&longitude@units = "degrees_east"
   A&latitude@units = "degrees_north"
   E = B-C
   copy_VarMeta(C,E)
  end if
 D = A-C
   copy_VarMeta(C,D)


; define plot
 wks = gsn_open_wks(plot_type,wkdir+"cset4_co_column_mopitt_"+month(mo))
 
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
   res@lbTitleString = "10~S~17~N~ mol/cm~S~2~N" 
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
 con = new(14,float)
 dcon = new (14,float)
 plev = fspan(1000.,100.,10)
 ptop = 100.
 con=2*(/1,2,3,4,5,6,7,8,9,10,11,12,13,14/)
 dcon=5*(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,1,.3,.6,.9,1.2,1.5,1.8/)

;**********************************************************************
 maintitle = "Test" 
 units = "1.e+17 molec."
 res@txString =month(mo) 
   res@cnLevels = con(:)

  res@cnFillColors   = (/3,4,5,6,7,8,9,10,11,12,13,14,15,16/)
  res@gsnLeftString = "MOPITT"
  plot(0) = gsn_csm_contour_map_ce(wks,C,res)   ; plot model data
  res@cnLevels = 0.25*con(:)
  res@gsnLeftString = "MOPITT STD"
  plot(1) = gsn_csm_contour_map_ce(wks,C_std,res)   ; plot model data
  res@cnLevels = con(:)
  res@gsnLeftString = case1 
  plot(2) = gsn_csm_contour_map_ce(wks,A,res)   ; plot model data
  res@cnLevels = dcon(:)
  res@cnFillColors   = (/19,20,21,22,23,24,25,0,27,28,29,30,31,32/) 
  res@gsnLeftString = case1+" - MOPITT"
  plot(3) = gsn_csm_contour_map_ce(wks,D,res)   ; plot model data
 if (compare .ne. "OBS") then
  res@cnFillColors   = (/3,4,5,6,7,8,9,10,11,12,13,14,15,16/)
  res@cnLevels = con(:)
  res@gsnLeftString = case2 
  plot(4) = gsn_csm_contour_map_ce(wks,B,res)   ; plot model data
  res@cnLevels = dcon(:)
  res@gsnLeftString = case2+" - MOPITT"
  res@cnFillColors   = (/19,20,21,22,23,24,25,0,27,28,29,30,31,32/) 
  plot(5) = gsn_csm_contour_map_ce(wks,E,res)   ; plot model data
 end if

; res@tiMainString = "MOPITT Column CO"
; res@gsnRightString = A@units
; res@gsnLeftString = "mean = "+sprintf("%6.2f",gblmean_C)
; res@gsnCenterString = "rmse = "+sprintf("%6.2f",gblrmse)
;*********************************************
; add lat long info to plot
    txres               = True
    txres@txFontHeightF = 0.017

;   if (latpt.lt.0) then
;     prntlat = fabs(latpt)+ " S"
;   else
;     prntlat = latpt + " N"
;   end if
;   if (lonpt.gt.180) then
;     prntlon = 360-lonpt + " W"
;   else
;     prntlon = lonpt + " E"
;   end if
    title = "MOPITT Column CO Climo 2003-2012 "+month(mo)
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

end do

end
