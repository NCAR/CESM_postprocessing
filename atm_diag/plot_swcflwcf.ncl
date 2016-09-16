; NCL script
; plot_swcflwcf_scat.ncl
; Mark Stevens Dec 2001
;----------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
begin

obsdata    = getenv("OBS_DATA")
compare    = getenv("COMPARE")
plot_type  = getenv("PLOTTYPE")
version    = getenv("DIAG_VERSION")
wkdir      = getenv("WKDIR")
time_stamp = getenv("TIMESTAMP") 
case_names = getenv("CASENAMES")
ncdf_ann_mode = getenv("NCDF_ANN_MODE")
ncdf_djf_mode = getenv("NCDF_DJF_MODE")
ncdf_jja_mode = getenv("NCDF_JJA_MODE")
infile1    = getenv("TEST_INPUT")     ; case1 input path/prefix 
outfile1   = getenv("TEST_PLOTVARS")  ; case1 output path/prefix 
infile2    = getenv("CNTL_INPUT")     ; case2 input path/prefix 
if (compare .ne. "OBS") then
  outfile2   = getenv("CNTL_PLOTVARS") ; case2 output path/prefix 
end if

;------------------------------------------------------------------
; contour plot resources
res          = True
res@gsnDraw  = False
res@gsnFrame = False
res@xyMarkLineModes = "Markers"
res@xyMarkers = 16
res@xyMarkerColor = "black"
res@txFontHeightF = 0.025
res@pmLegendDisplayMode = "Never"
res@trXMinF = 0.0
res@trXMaxF = 120.0
res@trYMinF = -120.0
res@trYMaxF = 0.0
;---------------------------------------------------------------------------
; panel plot resources
pan = True
pan@gsnFrame = False
pan@txFontHeightF = 0.018
pan@txFont = "helvetica-bold"
pan@txString = "Warm Pool SWCF vs LWCF"
pan@gsnMaximize = True
pan@gsnPaperOrientation = "portrait"
;---------------------------------------------------------------------------
; Indonesian Region 
maxlat = 20.0
minlat = -10.0
minlon = 110.0
maxlon = 160.0

plot = new(6,"graphic")


if (compare .eq. "OBS") then;end do
  wks = gsn_open_wks(plot_type,wkdir+"set11_SWCF_LWCF_ERBE_obs")
  wks2 = gsn_open_wks(plot_type,wkdir+"set11_SWCF_LWCF_CERES_obs")
  wks3 = gsn_open_wks(plot_type,wkdir+"set11_SWCF_LWCF_CERES-EBAF_obs")
  plot2 = new(6,"graphic")
  plot3 = new(6,"graphic")
else
  wks = gsn_open_wks(plot_type,wkdir+"set11_SWCF_LWCF")
end if


;-------------------------------------------------------------------------
; CASE 1 MODEL
inptr1 = addfile(infile1+"_ANN_climo.nc","r")
if (case_names .eq. "True") then
  case1 = getenv("CASE1")
else
  case1 = inptr1@case      ; case names
end if
if (isatt(inptr1,"yrs_averaged")) then
  yrs_ave1 = inptr1@yrs_averaged
end if
if (ncdf_ann_mode .eq. "write") then
  outptr1 = addfile(outfile1+"_ANN_plotvars.nc","w")
else
  outptr1 = addfile(outfile1+"_ANN_plotvars.nc","c")
end if
if (isfilevar(inptr1,"LWCF") .and. compare.eq."OBS") then
  lwcf1 = get_LWCFTOA (inptr1,outptr1)
  swcf1 = get_SWCFTOA (inptr1,outptr1)
else
  lwcf1 = get_LWCFTOM (inptr1,outptr1)
  swcf1 = get_SWCFTOM (inptr1,outptr1)
end if
res@gsnRightString = "ANN"
if (isvar("yrs_ave1")) then;end do
  res@gsnLeftString = case1+" (yrs "+yrs_ave1+")"
else
  res@gsnLeftString = case1
end if
res@tiYAxisString = "SWCF (W m~S~-2~N~)"
y = ndtooned(swcf1({minlat:maxlat},{minlon:maxlon}))
x = ndtooned(lwcf1({minlat:maxlat},{minlon:maxlon}))
x!0 = "lwcf"
y!0 = "swcf"
plot(0) = gsn_csm_xy (wks,x,y,res)

if (compare .eq. "OBS") then
  plot2(0) = gsn_csm_xy (wks2,x,y,res)
  plot3(0) = gsn_csm_xy (wks3,x,y,res)
end if

inptr1 = addfile(infile1+"_DJF_climo.nc","r")
if (ncdf_djf_mode .eq. "write") then
  outptr1 = addfile(outfile1+"_DJF_plotvars.nc","w")
else
  outptr1 = addfile(outfile1+"_DJF_plotvars.nc","c")
end if
if (isfilevar(inptr1,"LWCF") .and. compare.eq."OBS") then
  lwcf1 = get_LWCFTOA (inptr1,outptr1)
  swcf1 = get_SWCFTOA (inptr1,outptr1)
else
  lwcf1 = get_LWCFTOM (inptr1,outptr1)
  swcf1 = get_SWCFTOM (inptr1,outptr1)
end if
res@gsnRightString = "DJF"
y = ndtooned(swcf1({minlat:maxlat},{minlon:maxlon}))
x = ndtooned(lwcf1({minlat:maxlat},{minlon:maxlon}))
plot(2) = gsn_csm_xy (wks,x,y,res)

if (compare .eq. "OBS") then
  plot2(2) = gsn_csm_xy (wks2,x,y,res)
  plot3(2) = gsn_csm_xy (wks3,x,y,res)
end if

inptr1 = addfile(infile1+"_JJA_climo.nc","r")
if (ncdf_jja_mode .eq. "write") then
  outptr1 = addfile(outfile1+"_JJA_plotvars.nc","w")
else
  outptr1 = addfile(outfile1+"_JJA_plotvars.nc","c")
end if
if (isfilevar(inptr1,"LWCF") .and. compare.eq."OBS") then
  lwcf1 = get_LWCFTOA (inptr1,outptr1)
  swcf1 = get_SWCFTOA (inptr1,outptr1)
else
  lwcf1 = get_LWCFTOM (inptr1,outptr1)
  swcf1 = get_SWCFTOM (inptr1,outptr1)
end if
res@gsnRightString = "JJA"
res@tiXAxisString = "LWCF (W m~S~-2~N~)"

y = ndtooned(swcf1({minlat:maxlat},{minlon:maxlon}))
x = ndtooned(lwcf1({minlat:maxlat},{minlon:maxlon}))
plot(4) = gsn_csm_xy (wks,x,y,res)


if (compare .eq. "OBS") then
  plot2(4) = gsn_csm_xy (wks2,x,y,res)
  plot3(4) = gsn_csm_xy (wks3,x,y,res)
end if


delete (x)
delete (y)
delete (res@gsnLeftString)
delete (res@tiXAxisString)
delete (res@tiYAxisString)
;----------------------------------------------------------------

; CASE 2 IS MODEL
if (compare .ne. "OBS") then
  inptr2 = addfile(infile2+"_ANN_climo.nc","r")
  landfrac = inptr2->LANDFRAC
  if (case_names .eq. "True") then
    case2 = getenv("CASE2")
  else
    case2 = inptr2@case         ; case names
  end if
  if (isatt(inptr2,"yrs_averaged")) then
    yrs_ave2 = inptr2@yrs_averaged
  end if
  if (ncdf_ann_mode .eq. "write") then
    outptr2 = addfile(outfile2+"_ANN_plotvars.nc","w")
  else
    outptr2 = addfile(outfile2+"_ANN_plotvars.nc","c")
  end if
  if (isfilevar(inptr2,"LWCF") .and. compare.eq."OBS") then
    lwcf2 = get_LWCFTOA (inptr2,outptr2)
    swcf2 = get_SWCFTOA (inptr2,outptr2)
  else
    lwcf2 = get_LWCFTOM (inptr2,outptr2)
    swcf2 = get_SWCFTOM (inptr2,outptr2)
  end if
  res@gsnRightString = "ANN"
  if (isvar("yrs_ave2")) then
    res@gsnLeftString = case2+" (yrs "+yrs_ave2+")"
  else
    res@gsnLeftString = case2
  end if
  y = ndtooned(swcf2({minlat:maxlat},{minlon:maxlon}))
  x = ndtooned(lwcf2({minlat:maxlat},{minlon:maxlon}))
  x!0 = "lwcf"
  y!0 = "swcf"
  plot(1) = gsn_csm_xy (wks,x,y,res)

  inptr2 = addfile(infile2+"_DJF_climo.nc","r")
  if (ncdf_djf_mode .eq. "write") then
    outptr2 = addfile(outfile2+"_DJF_plotvars.nc","w")
  else
    outptr2 = addfile(outfile2+"_DJF_plotvars.nc","c")
  end if
  if (isfilevar(inptr2,"LWCF") .and. compare.eq."OBS") then
    lwcf2 = get_LWCFTOA (inptr2,outptr2)
    swcf2 = get_SWCFTOA (inptr2,outptr2)
  else
    lwcf2 = get_LWCFTOM (inptr2,outptr2)
    swcf2 = get_SWCFTOM (inptr2,outptr2)
  end if
  res@gsnRightString = "DJF"
  y = ndtooned(swcf2({minlat:maxlat},{minlon:maxlon}))
  x = ndtooned(lwcf2({minlat:maxlat},{minlon:maxlon}))
  plot(3) = gsn_csm_xy (wks,x,y,res)

  inptr2 = addfile(infile2+"_JJA_climo.nc","r")
  if (ncdf_jja_mode .eq. "write") then
    outptr2 = addfile(outfile2+"_JJA_plotvars.nc","w")
  else
    outptr2 = addfile(outfile2+"_JJA_plotvars.nc","c")
  end if
  if (isfilevar(inptr2,"LWCF") .and. compare.eq."OBS") then
    lwcf2 = get_LWCFTOA (inptr2,outptr2)
    swcf2 = get_SWCFTOA (inptr2,outptr2)
  else
    lwcf2 = get_LWCFTOM (inptr2,outptr2)
    swcf2 = get_SWCFTOM (inptr2,outptr2)
  end if
  res@gsnRightString = "JJA"
  res@tiXAxisString = "LWCF (W m~S~-2~N~)"
  y = ndtooned(swcf2({minlat:maxlat},{minlon:maxlon}))
  x = ndtooned(lwcf2({minlat:maxlat},{minlon:maxlon}))
  plot(5) = gsn_csm_xy (wks,x,y,res)
else 
; CASE 2 IS OBS DATA 
; ERBE

  res@gsnLeftString = "ERBE"
  res@gsnRightString = "ANN"
  f=addfile(infile2+"/ERBE_ANN_climo.nc","r")
  swcf = f->SWCF                      ; (time,lat,lon)
  y = ndtooned(swcf(0,{minlat:maxlat},{minlon:maxlon}))
  lwcf = f->LWCF                      ; (time,lat,lon)
  x = ndtooned(lwcf(0,{minlat:maxlat},{minlon:maxlon}))
  x!0 = "lwcf"
  y!0 = "swcf"
  plot(1) = gsn_csm_xy (wks,x,y,res)
  delete(f)
  res@gsnRightString = "DJF"
  f=addfile(obsdata+"/ERBE_DJF_climo.nc","r")
  swcf = f->SWCF                      ; (time,lat,lon)
  y = ndtooned(swcf(0,{minlat:maxlat},{minlon:maxlon}))
  lwcf = f->LWCF                      ; (time,lat,lon)
  x = ndtooned(lwcf(0,{minlat:maxlat},{minlon:maxlon}))
  plot(3) = gsn_csm_xy (wks,x,y,res)
  delete(f)
  res@gsnRightString = "JJA"
  res@tiXAxisString = "LWCF (W m~S~-2~N~)"
  f=addfile(obsdata+"/ERBE_JJA_climo.nc","r")
  swcf = f->SWCF                      ; (time,lat,lon)
  y = ndtooned(swcf(0,{minlat:maxlat},{minlon:maxlon}))
  lwcf = f->LWCF                      ; (time,lat,lon)
  x = ndtooned(lwcf(0,{minlat:maxlat},{minlon:maxlon}))
  plot(5) = gsn_csm_xy (wks,x,y,res)
  
  delete(f)
  delete(y)
  delete(x)
  delete(swcf)
  delete(lwcf)

;CERES

  res@gsnLeftString = "CERES"
  res@gsnRightString = "ANN"
  f=addfile(infile2+"/CERES_ANN_climo.nc","r")
  swcf = f->SWCF                      ; (time,lat,lon)
  y = ndtooned(swcf(0,{minlat:maxlat},{minlon:maxlon}))
  lwcf = f->LWCF                      ; (time,lat,lon)
  x = ndtooned(lwcf(0,{minlat:maxlat},{minlon:maxlon}))
  x!0 = "lwcf"
  y!0 = "swcf"
  plot2(1) = gsn_csm_xy (wks2,x,y,res)
  delete(f)
  res@gsnRightString = "DJF"
  f=addfile(obsdata+"/CERES_DJF_climo.nc","r")
  swcf = f->SWCF                      ; (time,lat,lon)
  y = ndtooned(swcf(0,{minlat:maxlat},{minlon:maxlon}))
  lwcf = f->LWCF                      ; (time,lat,lon)
  x = ndtooned(lwcf(0,{minlat:maxlat},{minlon:maxlon}))
  plot2(3) = gsn_csm_xy (wks2,x,y,res)
  delete(f)
  res@gsnRightString = "JJA"
  res@tiXAxisString = "LWCF (W m~S~-2~N~)"
  f=addfile(obsdata+"/CERES_JJA_climo.nc","r")
  swcf = f->SWCF                      ; (time,lat,lon)
  y = ndtooned(swcf(0,{minlat:maxlat},{minlon:maxlon}))
  lwcf = f->LWCF                      ; (time,lat,lon)
  x = ndtooned(lwcf(0,{minlat:maxlat},{minlon:maxlon}))
  plot2(5) = gsn_csm_xy (wks2,x,y,res)


  delete(f)
  delete(y)
  delete(x)
  delete(swcf)
  delete(lwcf)


;CERES-EBAF

  res@gsnLeftString = "CERES-EBAF"
  res@gsnRightString = "ANN"
  f=addfile(infile2+"/CERES-EBAF_ANN_climo.nc","r")
  swcf = f->SWCF                      ; (time,lat,lon)
  y = ndtooned(swcf(0,{minlat:maxlat},{minlon:maxlon}))
  lwcf = f->LWCF                      ; (time,lat,lon)
  x = ndtooned(lwcf(0,{minlat:maxlat},{minlon:maxlon}))
  x!0 = "lwcf"
  y!0 = "swcf"
  plot3(1) = gsn_csm_xy (wks3,x,y,res)
  delete(f)
  res@gsnRightString = "DJF"
  f=addfile(obsdata+"/CERES-EBAF_DJF_climo.nc","r")
  swcf = f->SWCF                      ; (time,lat,lon)
  y = ndtooned(swcf(0,{minlat:maxlat},{minlon:maxlon}))
  lwcf = f->LWCF                      ; (time,lat,lon)
  x = ndtooned(lwcf(0,{minlat:maxlat},{minlon:maxlon}))
  plot3(3) = gsn_csm_xy (wks3,x,y,res)
  delete(f)
  res@gsnRightString = "JJA"
  res@tiXAxisString = "LWCF (W m~S~-2~N~)"
  f=addfile(obsdata+"/CERES-EBAF_JJA_climo.nc","r")
  swcf = f->SWCF                      ; (time,lat,lon)
  y = ndtooned(swcf(0,{minlat:maxlat},{minlon:maxlon}))
  lwcf = f->LWCF                      ; (time,lat,lon)
  x = ndtooned(lwcf(0,{minlat:maxlat},{minlon:maxlon}))
  plot3(5) = gsn_csm_xy (wks3,x,y,res)

end if
;----------------------------------------------------------------------

; add diagonal lines
diag = new(6,"graphic")
if (compare.eq."OBS") then
  diag2 = new(6,"graphic")
  diag3 = new(6,"graphic")
end if
dres = True
dres@gsLineThicknessF = 1.5
xdiag = fspan(0.,120.,121)
ydiag = fspan(0.,-120.,121)

do n = 0, 5
  diag(n) = gsn_add_polyline(wks,plot(n),xdiag,ydiag,dres)

  if (compare.eq."OBS") then
     diag2(n) = gsn_add_polyline(wks2,plot2(n),xdiag,ydiag,dres)
     diag3(n) = gsn_add_polyline(wks3,plot3(n),xdiag,ydiag,dres)
  end if
end do

if (time_stamp .eq. "True") then
  pan@gsnPanelBottom = 0.08
  gsn_panel(wks,plot,(/3,2/),pan)
  infoTimeStamp(wks,0.011,"DIAG Version: "+version)
  if (compare.eq."OBS") then
    gsn_panel(wks2,plot2,(/3,2/),pan)
    gsn_panel(wks3,plot3,(/3,2/),pan)
    infoTimeStamp(wks2,0.011,"DIAG Version: "+version)
    infoTimeStamp(wks3,0.011,"DIAG Version: "+version)
  end if
else
  pan@gsnPanelBottom = 0.08
  gsn_panel(wks,plot,(/3,2/),pan)
  if (compare.eq."OBS") then
    gsn_panel(wks2,plot2,(/3,2/),pan)
    gsn_panel(wks3,plot3,(/3,2/),pan)
  end if
end if

frame(wks)
if (compare.eq."OBS") then
  frame(wks2)
  frame(wks3)
end if

end
