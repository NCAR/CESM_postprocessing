function contour_plot(wks, field, lon, lat, kmt, rmask, area, case_info, missing, units, dlev, \
                     levels, colors, opt)

local size,nx,ny,nlev,mod_field,plon,plan,dims,coord_rank,xrng,yrng,\
      landcolor,field_min,field_max,larea,mean,rms,res,units_str,info_str,\
      attnames,in,i
begin

  size = dimsizes(field)
  nx = size(1)
  ny = size(0)

  nlev = dimsizes(levels)

  mod_field = field
  if (isatt(field,"_FillValue")) then
    mod_field = where(rmask .lt. 0, field@_FillValue, mod_field)
  else
    mod_field = where(rmask .lt. 0, missing, mod_field)
    mod_field@_FillValue = missing
  end if

  plon = lon		; plot longitude
  plat = lat		; plot latitude
  dims = dimsizes(plon)
  coord_rank = dimsizes(dims)
  xrng = (/0.,360./)
  yrng = (/-90.,90./)
  if (isatt(opt,"landcolor")) then
    landcolor = opt@landcolor
  else
    landcolor = 0
  end if

  if (isatt(opt,"xrange")) then 
    xrng = opt@xrange 
    if (xrng(0) .lt. 0.) then
      plon = where(plon .gt. 180, plon - 360, plon)
    end if
    if (xrng(1) .gt. 180.) then 
      plon = where(plon .lt. 0, plon+360.,plon)
    end if
    if (xrng(1) .gt. 360) then
      dx = xrng(1) - 360
      plon = where(plon .ge. 0 .and. plon .le. dx, plon + 360, plon)
    end if
  end if
  if (isatt(opt,"yrange")) then
    yrng = opt@yrange
  end if

  mod_field = where(plon .ge. xrng(0) .and. plon .le. xrng(1) .and. \
  plat .ge. yrng(0) .and. plat .le. yrng(1), \
  mod_field, mod_field@_FillValue)
  field_min = min(mod_field)
  field_max = max(mod_field)

  if ((.not. isatt(opt,"nomean")) .or. opt@nomean .ne. 1) then
    larea = where(ismissing(mod_field),area@_FillValue,area)
    mean = wgt_areaave2(mod_field,larea,0)
    rms = sqrt(sum (mod_field * mod_field * larea) / sum(larea)) 
  end if

  mod_field@lon2d = plon
  mod_field@lat2d = plat

  res = True
  res@cnFillOn = True
  res@cnFillMode = "rasterfill"
  res@cnRasterSmoothingOn = True
  res@trGridType = "triangularmesh"
  if (isatt(opt,"lbLabelBarOn") .and. opt@lbLabelBarOn .eq. False) then
    res@lbLabelBarOn = False
  else
    res@lbLabelBarOn = True
    res@cnLabelBarEndStyle = "excludeOuterBoxes"
    res@pmLabelBarSide = "right"
    res@lbOrientation = "vertical"
    res@lbLabelAutoStride = True
  end if

  if (isatt(opt,"polar") .or. (isatt(opt,"cnInfoLabelOn") .and. opt@cnInfoLabelOn .eq. False)) then
    res@cnInfoLabelOn = False
  else
    res@cnInfoLabelOn = True
    res@cnInfoLabelJust = "TopCenter"
    res@cnInfoLabelParallelPosF = .5
    if (units .eq. "" .and. isatt(mod_field,"units")) then
      units_str = mod_field@units
    else
      units_str = units
    end if
    if (ismissing(dlev)) then
      info_string = "$ZMN$ to $ZMX$ " + units_str
    else
      info_string = "$ZMN$ to $ZMX$ by $CIU$ " + units_str
    end if
    res@cnInfoLabelString = info_string
  end if 
  
  res@mpOutlineOn = False
  res@mpFillOn = False
  res@mpLimitMode = "latlon"
  res@mpMinLatF = yrng(0)
  res@mpMaxLatF = yrng(1)
  res@mpMinLonF = xrng(0)
  res@mpMaxLonF = xrng(1)
  if (isatt(opt,"aspect_ratio")) then
    res@mpShapeMode = "FreeAspect"
    res@vpWidthF = .6
    res@vpHeightF = .6 / opt@aspect_ratio
  else
    res@mpShapeMode = "FixedAspectFitBB"
  end if
  if (.not. isatt(opt,"polar")) then
     if (isatt(opt,"gsnMajorLonSpacing")) then
       res@gsnMajorLonSpacing = opt@gsnMajorLonSpacing
     else
       res@gsnMajorLonSpacing = 30
     end if
  end if

  res@gsnLeftString = case_info
  if (isatt(opt,"gsnLeftStringFontHeightF")) then
    res@gsnLeftStringFontHeightF = opt@gsnLeftStringFontHeightF
  end if
  if (isatt(opt,"gsnRightStringFontHeightF")) then
    res@gsnRightStringFontHeightF = opt@gsnRightStringFontHeightF
  end if
  if (isatt(opt,"gsnRightStringParallelPosF")) then
    res@gsnRightStringParallelPosF = opt@gsnRightStringParallelPosF
  else 
    res@gsnRightStringParallelPosF = 1.025
  end if  
  if (isatt(opt,"nomean") .and. opt@nomean .eq. 1) then
    res@gsnRightString = ""
  else
    res@gsnRightString = "mean = " + sprintf("%.4g",mean) + "~C~rms = " + sprintf("%.4g",rms)
  end if
  res@gsnAddCyclic = True
  res@mpCenterLonF = 210
  res@cnLevelSelectionMode = "explicitlevels"
  res@cnLevels = levels
  res@cnFillColors = colors

  if (isatt(opt,"noxticklab")) then
    res@tmXBLabelsOn = False
  else
    res@tmXBLabelsOn = True
  end if
  if (isatt(opt,"noyticklab")) then
    res@tmYLLabelsOn = False
  else
    res@tmYLLabelsOn = True
  end if
  res@tmEqualizeXYSizes = True
  res@tmXBLabelFontHeightF = .012

  if (isatt(opt,"noline") .and. opt@noline .eq. 1) then
    res@cnLinesOn = False
  else if (isatt(opt,"contourline")) then
    if (dimsizes(opt@contourline) .gt. 1) then
      res@cnLevelFlags = where(opt@contourline .eq. 0, 0, 1)
    else if (opt@contourline .eq. 2) then
      res@cnLinesOn = False
    else if (opt@contourline .eq. 3) then
      res@cnLinesOn = True
    else if (opt@contourline .eq. 1) then
                                ; lines at 0 only
      lflags = new(nlev,integer)
      lflags = 0
      lflags = where(levels .eq. 0, 1, 0)
      res@cnLevelFlags = lflags     
    end if
  end if
  end if
  end if
  end if
  end if

  if (isatt(opt,"cnLineLabelsOn")) then
    res@cnLineLabelsOn = opt@cnLineLabelsOn
    res@cnLineLabelPlacementMode  = "constant"
    res@cnLineLabelFontHeightF = .008
  end if

  if (isatt(opt,"do_panel") .and. opt@do_panel .eq. True)
    res@gsnDraw = False
    res@gsnFrame = False
  else
    res@gsnDraw = True
    res@gsnFrame = True
    res@gsnMaximize = True
    res@gsnPaperOrientation = "portrait"
  end if

;
; allow caller to set resources via the opt argument
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
    in = str_index_of_substr(attnames(i),"mp",1)
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

  if (isatt(opt,"polar") .and. opt@polar .eq. "north") then
    res@mpProjection = "stereographic"
    res@mpCenterLatF = 90
    res@mpCenterLonF = 0
    res@mpLimitMode = "latlon"
    res@mpMinLatF = 60
    res@gsnPolar = "NH"
    res@mpOutlineOn = True
    res@mpPerimDrawOrder = "postdraw"
    delete(res@mpMinLonF)
    delete(res@mpMaxLonF)
    plot = gsn_csm_contour_map_polar(wks,mod_field,res)
  else if (isatt(opt,"polar") .and. opt@polar .eq. "south") then
    res@mpProjection = "stereographic"
    res@mpCenterLatF = -90
    res@mpCenterLonF = 0
    res@gsnPolar = "SH"
    res@mpLimitMode = "latlon"
    res@mpMaxLatF = -50
    delete(res@mpMinLonF)
    delete(res@mpMaxLonF)
    res@mpOutlineOn = True
    res@mpPerimDrawOrder = "postdraw"
    plot = gsn_csm_contour_map_polar(wks,mod_field,res)
  else
      plot = gsn_csm_contour_map(wks,mod_field,res)
  end if
  end if

  return (plot)

end
