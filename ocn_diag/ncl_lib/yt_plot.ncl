function yt_plot( wks, field,  z, time, case_info, missing, units, \
                  dlev, levels, colors, opt)

local res,res2,anno_res,nlev,size,nt,nz,field_min,field_max,\
      div_ix,div_val,attnames,i,in
begin

  nlev = dimsizes(levels)
  size = dimsizes(field)
  nt = size(1)
  nz = size(0)

  field_min = min(field)
  field_max = max(field)
  if (isatt(opt,"max_depth") .and. opt@max_depth .lt. 1) then
    div_ix = min(ind(z .gt. opt@max_depth))
  else
    div_ix = min(ind(z .gt. 1.0))
  end if
  div_val = z(div_ix)

  res = True
; set coordinate arrays
  if (isdimnamed(field,1) .and. iscoord(field,field!1)) then
    res@sfXArray = field&$field!1$ 
  else
    res@sfXArray = time
  end if
  res@sfYArray = z(:div_ix)

; set contour resources
  res@cnFillOn = True
  res@cnFillMode = "rasterfill"
  res@cnRasterSmoothingOn = True
  res@cnLevelSelectionMode = "explicitlevels"
  res@cnLevels = levels
  res@cnLineLabelsOn = True
  res@cnLineLabelPlacementMode = "constant"
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
  res@pmLabelBarDisplayMode = "always"
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

  if (isatt(opt,"aspect_ratio")) then
    res@vpWidthF = 0.6 * opt@aspect_ratio
  else
    res@vpWidthF = .8
  end if
                                ; the height changes between the top and the second plot
  res@vpHeightF = .375

; title resources
  res@tiMainString = case_info
  res@tiMainFontHeightF = 0.02
  if (isatt(opt,"tiMainOffsetYF")) then
    res@tiMainOffsetYF = opt@tiMainOffsetYF
  else
    res@tiMainOffsetYF = -0.0
  end if
  res@tiYAxisString = "DEPTH (km)"
  res@tiYAxisFontHeightF = .02

; tickmark resources
  res@tmYLLabelFontHeightF = 0.02
  res@tmEqualizeXYSizes = True

  if (div_val .ge. 1)  then  
    res@tmYLMode = "explicit"
    res@tmYLValues = (/ 1.0 , 0.5 , 0 /)
    res@tmYLLabels = (/ "1.0", "0.5", "0.0" /)
  end if
  res@tmXBOn = False
  res@tmXTOn = False
  res@tmYROn = False

  if (.not. opt@do_panel) then
    res@gsnMaximize = True
    res@gsnPaperOrientation = "portrait"
  end if

;
; allow resources set from calling routine
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
  res@tiXAxisOn = False
  plot = gsn_contour(wks,field(0:div_ix,:),res)
  
; delete attributes that change dimension size or should not be set for second plot
  delete(res@sfYArray)
  if (isatt(res,"tmYLMode")) then
    delete(res@tmYLLabels)
    delete(res@tmYLValues)
    delete(res@tmYLMode)
  end if
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
  res2@tmXBLabelFontHeightF = 0.02
  res2@tmYLMinorOn = False
; height difference based on the desired relative size of top and bottom plot
  res2@vpHeightF = 0.225
  if (.not. isatt(res2,"cnInfoLabelOn")) then
    res2@cnInfoLabelOn = True
  end if
  res2@tiMainOn = False
  res2@tiYAxisOn = False
  res2@pmLabelBarDisplayMode = "nocreate"
  res2@trYMinF = div_val
  res2@trYMaxF = 6.0
  if (isatt(opt,"tiXAxisString")) then
    res2@tiXAxisOn = True
    res2@tiXAxisFontHeightF = 0.02
  end if
  anno_plot = gsn_contour(wks,field(div_ix:,:),res2)

  if (isatt(opt,"plot_label")) then
    text_res = True
    text_res@txJust = "centerleft"
    text_res@txFontHeightF = 0.017
    text_add = gsn_add_text(wks,anno_plot,opt@plot_label,-85.,5.65,text_res)
  end if

; the bottom plot becomes an annotation of the first to create the intgrated composite plot
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

  if (opt@do_panel) then
    setvalues plot@contour
      "pmLabelBarHeightF" : lbarheight * 2
      "lbJustification" : "bottomleft"
      "pmLabelBarParallelPosF" : -1.85
      "pmLabelBarOrthogonalPosF" : -0.04
      "tiYAxisJust" : "topcenter"
      "tiYAxisPosition" : "bottom"
      "tiYAxisOffsetYF" : -0.0
    end setvalues  
  else
    setvalues plot@contour
      "tmYLLabelFontHeightF" : 0.018
      "pmLabelBarHeightF" : lbarheight * 1.95
      "lbJustification" : "bottomleft"
      "lbLabelAutoStride" : False
      "pmLabelBarParallelPosF" : -.915
      "pmLabelBarOrthogonalPosF" : -0.04
      "tiYAxisJust" : "topcenter"
      "tiYAxisPosition" : "center"
      "tiYAxisOffsetYF" : -0.12
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
  if (.not. (isatt(opt,"do_panel") .and. opt@do_panel .eq. True))
    draw(plot)
    frame(wks)
  end if

  return( plot)

end
