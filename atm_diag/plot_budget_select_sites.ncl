; NCL script
; Cecile Hannay, April 2012
; set 16: plot budget terms for select sites
;**************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  

load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
load "$DIAG_CODE/functions_budget.ncl"

;**********************************************************
begin

; -- get env variables 
 compare    = getenv("COMPARE")
 plot_type  = getenv("PLOTTYPE")
 color_type = getenv("COLORTYPE")
 season     = getenv("SEASON")
 version    = getenv("DIAG_VERSION")
 wkdir      = getenv("WKDIR")
 case_names = getenv("CASENAMES")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename

; --- CASE 1
 inptr1 = addfile(infile1,"r")
 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case           ; case name
 end if
 lat1 = inptr1->lat
 lon1 = inptr1->lon
 
; --- CASE 2 (IFF NOT OBS)
 if (compare .ne. "OBS") then   
   inptr2 = addfile(infile2,"r")
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case
   end if
  lat2 = inptr2->lat
  lon2 = inptr2->lon
 end if

;--- List of Columns
  name_col =(/ "EPIC",  "SGP" /) 
  lon_col = (/ 275.  ,  263.5/) 
  lat_col = (/ -20.  ,  36.3/)
  ncols = dimsizes(lon_col)

;************************************************
 
  res                   = True                       ; plot mods desired
  res@trYReverse        = True                       ; reverse Y-axis
 
  res@gsnFrame = False                          ; don't advance frame
  res@gsnDraw  = False                          ; don't draw
  res@gsnMaximize      = True                   ; use full page

; add a legend
 res@pmLegendDisplayMode    = "Always"              ; turn on legend
 res@pmLegendSide           = "Top"                 ; Change location of 
 res@pmLegendParallelPosF   = .70                   ; move units right
 res@pmLegendOrthogonalPosF = -0.6                  ; more neg = down
 res@pmLegendWidthF         = 0.12                  ; Change width and
 res@pmLegendHeightF        = 0.25                  ; height of legend.
 res@lgLabelFontHeightF     = .02                   ; change font height
 res@lgPerimOn              = False                 ; no box around

; res@xyLineThicknesses      = (/2.,2.,2.,2.,2.,2./)
 res@xyLineThicknessF = 3.
 if (color_type .eq. "COLOR") then
   res@xyLineColors         = (/"black","red","blue", "green"/)
   res@xyLineColor = "black"
 end if

 res@tiYAxisString = "Pressure (mb)"

 ; panel plot ressources
 resP            = True                         ; modify the panel plot
 resP@gsnMaximize      = True                   ; use full page
 ;resP@gsnPaperOrientation = "landscape"
 resP@gsnPaperOrientation = "portrait"
 resP@gsnFrame = False
 resP@gsnPanelTop   = 0.8
 resP@gsnPanelYWhiteSpacePercent = 1.0
 resP@gsnPanelXWhiteSpacePercent = 1.0

 if (compare .ne. "OBS") then  
 
 end if

;******************************************************************

  ; PTEQ = DCQ + VD01 + DMEQ 
  PTEQ1  = vertical_Q_budget_term(inptr1,  "PTEQ" ) 
  DCQ1   = vertical_Q_budget_term(inptr1,  "DCQ" )
  VD01_1 = vertical_Q_budget_term(inptr1,  "VD01" )
  DMEQ1  = vertical_Q_budget_term(inptr1,  "DMEQ" )

 if (compare .ne. "OBS") then   
  PTEQ2  = vertical_Q_budget_term(inptr2,  "PTEQ" )
  DCQ2   = vertical_Q_budget_term(inptr2,  "DCQ" )
  VD01_2 = vertical_Q_budget_term(inptr2,  "VD01" )
  DMEQ2  = vertical_Q_budget_term(inptr2,  "DMEQ" )
 end if

;--------------------------------
 
 do icol = 0,ncols-1
 
  i_lat1 = ind_nearest_coord (lat_col(icol), lat1, 0)
  i_lon1 = ind_nearest_coord (lon_col(icol), lon1, 0)

  if (compare .ne. "OBS") then   
    i_lat2 = ind_nearest_coord (lat_col(icol), lat2, 0)
    i_lon2 = ind_nearest_coord (lon_col(icol), lon2, 0)
  end if

  data1      = new((/4,dimsizes(plvlM)/),float)
  data1(0,:) = PTEQ1( :, i_lat1, i_lon1)
  data1(1,:) = DCQ1(  :, i_lat1, i_lon1)
  data1(2,:) = VD01_1(:, i_lat1, i_lon1)
  data1(3,:) = DMEQ1( :, i_lat1, i_lon1)
 
  if (compare .ne. "OBS") then  
    data2      = new((/4,dimsizes(plvlM)/),float)
    data2(0,:) = PTEQ2( :, i_lat2, i_lon2)
    data2(1,:) = DCQ2(  :, i_lat2, i_lon2)
    data2(2,:) = VD01_2(:, i_lat2, i_lon2)
    data2(3,:) = DMEQ2( :, i_lat2, i_lon2)
  end if 

;-- Plot 

  wks = gsn_open_wks(plot_type,wkdir+"set16_"+season+"_"+name_col(icol)+"_PTEQ")                ; open ps file
  
  res@xyExplicitLegendLabels = (/"PTEQ","DCQ","VD01","DMEQ"/)     ; labels for the legend
  
  if (compare .eq. "OBS") then  
    
    res@tiMainString      = case1           ; add title 
    res@xyLineThicknessF = 4.
    plot  = gsn_csm_xy (wks,data1,plvlM,res)            ; create plot
    gsn_panel(wks,plot,(/1,2/),resP)             ; now draw as one plot

  else

    plot = new(2,graphic)                          ; create a plot array

    ; labels 
    res@tiMainString      = case1           ; add title
    plot(0)  = gsn_csm_xy (wks,data1,plvlM,res)            ; create plot
    res@tiMainString      = case2           ; add title
    plot(1)  = gsn_csm_xy (wks,data2,plvlM,res)            ; create plot
  
    gsn_panel(wks,plot,(/1,2/),resP)             ; now draw as one plot
    
  end if 

    txres               = True
    txres@txFontHeightF = 0.020  
    gsn_text_ndc(wks, name_col(icol)+", "+season ,0.5,0.85,txres)
    txres@txFontHeightF = 0.015
    gsn_text_ndc(wks,"Q: Total Physics Tendency",0.5,0.8,txres)
    gsn_text_ndc(wks,"PTEQ = DCQ + VD01 + DMEQ",0.5,0.77,txres)


end do ; icol

;******************************************************************



end

