; NCL script
; plot_preccl_scat.ncl
; Mark Stevens Dec 2001
;----------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
begin

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
outfile2   = getenv("CNTL_PLOTVARS") ; case2 output path/prefix 

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
res@trXMaxF = 1.0
res@trYMinF = 0.0
res@trYMaxF = 18.0
;---------------------------------------------------------------------------
; panel plot resources
pan = True
pan@gsnFrame = False
pan@txFontHeightF = 0.018
pan@txString = "Warm Pool PRECC vs PRECL"
pan@gsnMaximize = True
pan@gsnPaperOrientation = "portrait"
;---------------------------------------------------------------------------
; Indonesian Region 
maxlat = 20.0
minlat = -10.0
minlon = 110.0
maxlon = 160.0

plot = new(6,"graphic")
wks = gsn_open_wks(plot_type,wkdir+"set11_PRECC_PRECL")
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
precc1 = get_PRECC (inptr1,outptr1)
precl1 = get_PRECL (inptr1,outptr1)
res@gsnRightString = "ANN"
if (isvar("yrs_ave1")) then
  res@gsnLeftString = case1+" (yrs "+yrs_ave1+")"
else
  res@gsnLeftString = case1
end if
res@tiYAxisString = "PRECC (mm/day)"
y = ndtooned(precc1({minlat:maxlat},{minlon:maxlon}))
x = ndtooned(precl1({minlat:maxlat},{minlon:maxlon}))
x!0 = "precl"
y!0 = "precc"
plot(0) = gsn_csm_xy (wks,x,y,res)

inptr1 = addfile(infile1+"_DJF_climo.nc","r")
if (ncdf_djf_mode .eq. "write") then
  outptr1 = addfile(outfile1+"_DJF_plotvars.nc","w")
else
  outptr1 = addfile(outfile1+"_DJF_plotvars.nc","c")
end if
precc1 = get_PRECC (inptr1,outptr1)
precl1 = get_PRECL (inptr1,outptr1)
res@gsnRightString = "DJF"
y = ndtooned(precc1({minlat:maxlat},{minlon:maxlon}))
x = ndtooned(precl1({minlat:maxlat},{minlon:maxlon}))
plot(2) = gsn_csm_xy (wks,x,y,res)

inptr1 = addfile(infile1+"_JJA_climo.nc","r")
if (ncdf_jja_mode .eq. "write") then
  outptr1 = addfile(outfile1+"_JJA_plotvars.nc","w")
else
  outptr1 = addfile(outfile1+"_JJA_plotvars.nc","c")
end if
precc1 = get_PRECC (inptr1,outptr1)
precl1 = get_PRECL (inptr1,outptr1)
res@gsnRightString = "JJA"
res@tiXAxisString = "PRECL (mm/day)"
y = ndtooned(precc1({minlat:maxlat},{minlon:maxlon}))
x = ndtooned(precl1({minlat:maxlat},{minlon:maxlon}))
plot(4) = gsn_csm_xy (wks,x,y,res)
delete (x)
delete (y)
delete (res@gsnLeftString)
delete (res@tiXAxisString)
delete (res@tiYAxisString)
;----------------------------------------------------------------
; CASE 2 IS MODEL
inptr2 = addfile(infile2+"_ANN_climo.nc","r")
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
precc2 = get_PRECC (inptr2,outptr2)
precl2 = get_PRECL (inptr2,outptr2)
res@gsnRightString = "ANN"
if (isvar("yrs_ave2")) then
  res@gsnLeftString = case2+" (yrs "+yrs_ave2+")"
else
  res@gsnLeftString = case2
end if
y = ndtooned(precc2({minlat:maxlat},{minlon:maxlon}))
x = ndtooned(precl2({minlat:maxlat},{minlon:maxlon}))
x!0 = "precl"
y!0 = "precc"
plot(1) = gsn_csm_xy (wks,x,y,res)

inptr2 = addfile(infile2+"_DJF_climo.nc","r")
if (ncdf_djf_mode .eq. "write") then
  outptr2 = addfile(outfile2+"_DJF_plotvars.nc","w")
else
  outptr2 = addfile(outfile2+"_DJF_plotvars.nc","c")
end if
precc2 = get_PRECC (inptr2,outptr2)
precl2 = get_PRECL (inptr2,outptr2)
res@gsnRightString = "DJF"
y = ndtooned(precc2({minlat:maxlat},{minlon:maxlon}))
x = ndtooned(precl2({minlat:maxlat},{minlon:maxlon}))
plot(3) = gsn_csm_xy (wks,x,y,res)

inptr2 = addfile(infile2+"_JJA_climo.nc","r")
if (ncdf_jja_mode .eq. "write") then
  outptr2 = addfile(outfile2+"_JJA_plotvars.nc","w")
else
  outptr2 = addfile(outfile2+"_JJA_plotvars.nc","c")
end if
precc2 = get_PRECC (inptr2,outptr2)
precl2 = get_PRECL (inptr2,outptr2)
res@gsnRightString = "JJA"
res@tiXAxisString = "PRECL (mm/day)"
y = ndtooned(precc2({minlat:maxlat},{minlon:maxlon}))
x = ndtooned(precl2({minlat:maxlat},{minlon:maxlon}))
plot(5) = gsn_csm_xy (wks,x,y,res)
;----------------------------------------------------------------------
if (time_stamp .eq. "True") then
  pan@gsnPanelBottom = 0.08
  gsn_panel(wks,plot,(/3,2/),pan)
  infoTimeStamp(wks,0.011,"DIAG Version: "+version)
else
  pan@gsnPanelBottom = 0.08
  gsn_panel(wks,plot,(/3,2/),pan)
end if
frame(wks)

end
