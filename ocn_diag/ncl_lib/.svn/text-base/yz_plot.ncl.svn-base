function yz_plot( wks, field, lat, z, case_info, missing, units, \
                  dlev, levels, colors, opt)

local res,res2,anno_res,nlev,size,ny,nz,field_min,field_max,\
      div_ix,div_val,attnames,i,in
begin

  nlev = dimsizes(levels)
  size = dimsizes(field)
  ny = size(1)
  nz = size(0)

  field_min = min(field)
  field_max = max(field)
  div_ix = min(ind(z .gt. 1.0))
  div_val = z(div_ix)

  res = True
; set coordinate arrays
  if (isdimnamed(field,1) .and. iscoord(field,field!1)) then
    res@sfXArray = field&$field!1$ 
  else
    res@sfXArray = lat
  end if
  res@sfYArray = z(:div_ix)
; set contour resources
  res@cnFillOn = True
  res@cnFillMode = "rasterfill"
  res@cnRasterSmoothingOn = True
  res@cnLevelSelectionMode = "explicitlevels"
  res@cnLevels = levels
  res@cnLineLabelsOn = False
  res@cnFillColors = colors
  res@gsnYAxisIrregular2Linear = True
  res@gsnXAxisIrregular2Linear = True
  res@trYReverse = True

; LabelBar resources
  res@lbLabelAutoStride = True
  res@pmLabelBarSide = "right"
  res@lbOrientation = "vertical"
  res@lbAutoManage = False
  res@lbLabelFontHeightF = .02
  res@cnLabelBarEndStyle = "excludeOuterBoxes"
;;  res@pmLabelBarDisplayMode = "always"
  res@pmLabelBarDisplayMode = "nocreate"
  res@lbPerimOn = False

; contour informational label resources -- top plot does not have Info Label
  res@cnInfoLabelOn = False
  res@cnInfoLabelJust = "TopCenter"
  res@cnInfoLabelParallelPosF = .5
  res@cnInfoLabelOrthogonalPosF = .05
  res@cnInfoLabelFontHeightF = 0.018
  res@cnInfoLabelString = sprintf("%0.3g",field_min) + " to " + sprintf("%0.3g",field_max) + \
  " by " + sprintf("%0.3g",dlev) + " "  + units
  res@gsnDraw = False
  res@gsnFrame = False
  
  res@trYMinF = 0.0
  res@trXMinF = -90.
  res@trXMaxF = 90.
  if (isatt(opt,"aspect_ratio")) then
    res@vpWidthF = 0.6 * opt@aspect_ratio
  else
    res@vpWidthF = .8
  end if
                                ; the height changes between the top and the second plot
  res@vpHeightF = .225

; title resources
  res@tiMainString = case_info
;;  res@tiMainFontHeightF = 0.02
  res@tiMainFontHeightF = 0.025
  if (isatt(opt,"tiMainOffsetYF")) then
    res@tiMainOffsetYF = opt@tiMainOffsetYF
  else
    res@tiMainOffsetYF = -0.015
  end if
  res@tiYAxisString = "DEPTH (km)"
;;  res@tiYAxisFontHeightF = .02
  res@tiYAxisFontHeightF = .025

; tickmark resources
  res@tmYLLabelFontHeightF = 0.02
  res@tmYLMode = "explicit"
  res@tmEqualizeXYSizes = True
  res@tmYLValues = (/ 1.0 , 0.5 , 0 /)
  res@tmYLLabels = (/ "1.0", "0.5", "0.0" /)
  res@tmXBOn = False
  res@tmXTOn = False
  res@tmYROn = False

  if (.not. opt@do_panel) then
    res@gsnMaximize = True
    res@gsnPaperOrientation = "portrait"
  end if

;
; allow for other relevant resources set by the calling routine
;
  attnames = getvaratts(opt)
  do i = 0, dimsizes(attnames) -1
    in = str_index_of_substr(attnames(i),"tm",1)
    if ((.not. ismissing(in)) .and. in .eq. 0) then
      res@$attnames(i)$ = opt@$attnames(i)$
    end if
    in = str_index_of_substr(attnames(i),"lb",1)
    if ((.not. ismissing(in)) .and. in .eq. 0) then
      res@$attnames(i)$ = opt@$attnames(i)$
    end if
    in = str_index_of_substr(attnames(i),"cn",1)
    if ((.not. ismissing(in)) .and. in .eq. 0) then
      res@$attnames(i)$ = opt@$attnames(i)$
    end if
    in = str_index_of_substr(attnames(i),"vp",1)
    if ((.not. ismissing(in)) .and. in .eq. 0) then
      res@$attnames(i)$ = opt@$attnames(i)$
    end if
    in = str_index_of_substr(attnames(i),"ti",1)
    if ((.not. ismissing(in)) .and. in .eq. 0) then
      res@$attnames(i)$ = opt@$attnames(i)$
    end if
    in = str_index_of_substr(attnames(i),"gsn",1)
    if ((.not. ismissing(in)) .and. in .eq. 0) then
      res@$attnames(i)$ = opt@$attnames(i)$
    end if
    in = str_index_of_substr(attnames(i),"pm",1)
    if ((.not. ismissing(in)) .and. in .eq. 0) then
      res@$attnames(i)$ = opt@$attnames(i)$
    end if
  end do

; top plot (0 - 1 km)
  plot = gsn_contour(wks,field(0:div_ix,:),res)

  
; delete attributes that change dimension size or should not be set for second plot
  delete(res@sfYArray)
  delete(res@tmYLLabels)
  delete(res@tmYLValues)
  delete(res@tmYLMode)
  delete(res@lbLabelAutoStride)
  delete(res@pmLabelBarSide)
  delete(res@lbOrientation)
  delete(res@cnLabelBarEndStyle)
  delete(res@lbPerimOn)
  delete(res@lbLabelFontHeightF)
  delete(res@lbAutoManage)

; second plot 
  res2 = res

  res2@sfYArray = z(div_ix:)
  res2@tmXBOn = True
  res2@tmXBMode = "explicit"
  res2@tmXBValues = (/ -90, -60, -30, 0, 30, 60, 90 /)
  res2@tmXBLabels = (/ "90~S~o~N~S", "60~S~o~N~S", "30~S~o~N~S", "0~S~o~N~", "30~S~o~N~N", "60~S~o~N~N", "90~S~o~N~N" /)
  res2@tmXBLabelFontHeightF = 0.02
  res2@tmYLMinorOn = False
; height difference based on the desired relative size of top and bottom plot
  res2@vpHeightF = 0.375
  if (.not. isatt(res2,"cnInfoLabelOn")) then
    res2@cnInfoLabelOn = True
  end if
  res2@tiMainOn = False
  res2@tiYAxisOn = False

  res2@pmLabelBarDisplayMode = "always"
  res2@lbPerimOn = False
  res2@pmLabelBarHeightF = .7
  res2@trYMinF = div_val
  res2@trYMaxF = 6.0
  anno_plot = gsn_contour(wks,field(div_ix:,:),res2)

  if (isatt(opt,"plot_label")) then
    text_res = True
    text_res@txJust = "centerleft"
    text_res@txFontHeightF = 0.017
    text_add = gsn_add_text(wks,anno_plot,opt@plot_label,-85.,5.65,text_res)
  end if

; the bottom plot becomes an annotation of the first to create the integrated composite plot
  anno_res = True
  anno_res@amOrthogonalPosF = 0.05
  anno_res@amSide = "bottom"
  anno_res@amZone = 2
  anno_res@amJust = "topleft"
  anno_id = gsn_add_annotation(plot,anno_plot,anno_res)

  getvalues plot@contour
    "vpYF" : y1
    "vpWidthF" : width1
    "pmLabelBarHeightF" : lbarheight
  end getvalues
;
; Adjust the label bar to align with the composite plot. Adjustments must be tailored 
; differently depending on whether a panel plot is produced.
; 
  if (opt@do_panel) then
    setvalues plot@contour
      "pmLabelBarHeightF" : lbarheight * 2.95
;;      "lbJustification" : "bottomleft"
      "lbJustification" : "topleft"
      "pmLabelBarParallelPosF" : -1.85
      "pmLabelBarOrthogonalPosF" : -0.04
      "tiYAxisJust" : "topcenter"
      "tiYAxisPosition" : "bottom"
      "tiYAxisOffsetYF" : -0.05
    end setvalues  
  else
    setvalues plot@contour
      "tmYLLabelFontHeightF" : 0.018
      "pmLabelBarHeightF" : lbarheight * 3.45
;;      "lbJustification" : "bottomleft"
      "lbJustification" : "topleft"
      "lbLabelAutoStride" : False
      "pmLabelBarParallelPosF" : -2.35
      "pmLabelBarOrthogonalPosF" : -0.04
      "tiYAxisJust" : "topcenter"
      "tiYAxisPosition" : "bottom"
      "tiYAxisOffsetYF" : -0.15
    end setvalues  
    setvalues plot@contour
      "lbLabelAutoStride" : True
    end setvalues  
  end if
  getvalues plot
    "vpWidthF" : width
  end getvalues
  setvalues plot
    "vpYF" : .8
  end setvalues
  setvalues anno_plot
    "vpWidthF" : width
  end setvalues
;
; draw the plot here if not panelling
;
  if (.not. (isatt(opt,"do_panel") .and. opt@do_panel .eq. True))
    draw(plot)
    frame(wks)
  end if

  return( plot)

end
