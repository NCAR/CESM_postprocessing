; NCL script
; plot_oft.ncl 
; Mark Stevens, Sept 2001
; Rich Neale, Jan 2008
; plot data from model and ECMWF reanalysis
;*****************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
load "$DIAG_CODE/functions_contrib.ncl"   
load "$DIAG_CODE/functions_surfaces.ncl"
load "$DIAG_CODE/functions_transport.ncl"
;*****************************************************************
begin
version    = getenv("DIAG_VERSION")
compare    = getenv("COMPARE") 
wkdir      = getenv("WKDIR")
plot_type  = getenv("PLOTTYPE") 
color_type = getenv("COLORTYPE") 
time_stamp = getenv("TIMESTAMP")
case_names = getenv("CASENAMES")
ncdf_mode  = getenv("NCDF_MODE")
infile1    = getenv("TEST_INPUT")     ; case1 input filename
outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
infile2    = getenv("CNTL_INPUT")     ; case2 input filename
if (compare .ne. "OBS") then
  outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
end if

; ECMWF reanalysis data on T42 grid
; all floats
inptr = addfile("$OBS_DATA/ECMWF_ANN_climo.nc","r")
lat0 = inptr->lat          
nlat0 = dimsizes(lat0)
;jtgw = inptr->gw
if (isfilevar(inptr,"gw")) then
  gw = inptr->gw 
else
  if (isfilevar(inptr,"wgt")) then
    gw = inptr->wgt
  else 
    gwtemp = latRegWgt(lat1,"double",0)  ; no gw in file
    gw = gwtemp
    delete(gwtemp)
    gw!0 = "lat"
    gw&lat = lat1
  end if
end if
oro = inptr->ORO(0,:,:)
ep = inptr->EP(0,:,:)
oft0 = oft_ecmwf (gw,oro,ep)
delete(gw)
delete(oro)

; MODEL 1 
; get the model data
inptr1 = addfile(infile1,"r")
if (ncdf_mode .eq. "write") then
  outptr1 = addfile(outfile1,"w")
else
  outptr1 = addfile(outfile1,"c")
end if
if (case_names .eq. "True") then
  case1 = getenv("CASE1")
else
  case1 = inptr1@case
end if
tmp = inptr1->lat        
if (typeof(tmp).eq."double") then
  lat1 = dble2flt(tmp)
else
  lat1 = tmp
end if
delete(tmp)
nlat1 = dimsizes(lat1)

;jt gw = inptr1->gw
if (isfilevar(inptr1,"gw")) then
  gw = inptr1->gw 
else
  if (isfilevar(inptr1,"wgt")) then
    gw = inptr1->wgt
  else 
    gwtemp = latRegWgt(lat1,"double",0)  ; no gw in file
    gw = gwtemp
    delete(gwtemp)
    gw!0 = "lat"
    gw&lat = lat1
  end if
end if

;if (isfilevar(inptr1,"ORO")) then
;  oro = get_ORO (inptr1,outptr1)
;else
  oro = get_ORO_OCNFRAC (inptr1,outptr1)
;end if
precc = inptr1->PRECC(0,:,:)   ; m/s
precl = inptr1->PRECL(0,:,:)
if (isfilevar(inptr1,"QFLX")) then
  qflx = inptr1->QFLX(0,:,:)
else
  print("QFLX not present in input file")
  exit()
end if
oft1 = oft_model (gw,oro,precc,precl,qflx)
delete(gw)
delete(oro)
delete (precc)
delete (precl)
delete (qflx)

; Model 2 for model-to-model comparisons
if (compare .ne. "OBS") then
  inptr2 = addfile(infile2,"r")
  if (ncdf_mode .eq. "write") then
    outptr2 = addfile(outfile2,"w")
  else
    outptr2 = addfile(outfile2,"c")
  end if
  if (case_names .eq. "True") then
    case2 = getenv("CASE2")
  else
    case2 = inptr2@case
  end if
  tmp = inptr2->lat        
  if (typeof(tmp).eq."double") then
    lat2 = dble2flt(tmp)
  else
    lat2 = tmp
  end if
  delete(tmp)
  nlat2 = dimsizes(lat2)
;jt  gw = inptr2->gw
if (isfilevar(inptr2,"gw")) then
  gw = inptr2->gw 
else
  if (isfilevar(inptr2,"wgt")) then
    gw = inptr2->wgt
  else 
    gwtemp = latRegWgt(lat2,"double",0)  ; no gw in file
    gw = gwtemp
    delete(gwtemp)
    gw!0 = "lat"
    gw&lat = lat2
  end if
end if
;  if (isfilevar(inptr2,"ORO")) then
;    oro = get_ORO (inptr2,outptr2)
;  else
    oro = get_ORO_OCNFRAC (inptr2,outptr2)
;  end if
  precc = inptr2->PRECC(0,:,:)
  precl = inptr2->PRECL(0,:,:)
  if (isfilevar(inptr2,"QFLX")) then
    qflx = inptr2->QFLX(0,:,:)
  else
    print("QFLX not present in input file")
    exit()
  end if
  oft2 = oft_model (gw,oro,precc,precl,qflx)
end if

;*****************************************************************************
; plotting resources
if (compare .eq. "OBS") then
  if (color_type .eq. "COLOR") then
    wks = gsn_open_wks(plot_type,wkdir+"set2_OFT_obsc")   
  else
    wks = gsn_open_wks(plot_type,wkdir+"set2_OFT_obs")   
  end if
else
  if (color_type .eq. "COLOR") then
    wks = gsn_open_wks(plot_type,wkdir+"set2_OFT_c")   
  else
    wks = gsn_open_wks(plot_type,wkdir+"set2_OFT")   
  end if
end if
plotO = new(1,"graphic")  
plotP = new(1,"graphic")  
plotA = new(1,"graphic")  
plotI = new(1,"graphic")  

res                        = True
res@gsnFrame               = False
res@gsnDraw                = False
res@pmLegendSide           = "Right"            
res@pmLegendWidthF         = 0.13              
res@pmLegendDisplayMode    = "Always"
res@lgPerimOn              =  True
res@lgLabelFontHeightF     = 0.015
res@trXReverse             = True
if (compare.eq."OBS") then
  res@pmLegendHeightF        = 0.08             
  res@xyExplicitLegendLabels = (/"ECMWF",case1/)
  res@xyLineThicknesses      = (/2.,2./)
  if (color_type .eq. "COLOR") then
    res@xyLineColors           = (/"black","red"/)
    res@xyDashPatterns         = (/0,0/)
  else
    res@xyMonoLineColor       = True
    res@xyLineColor           = "black" 
    res@xyDashPatterns         = (/0,1/)
  end if
else
  res@pmLegendHeightF        = 0.10             
  res@xyExplicitLegendLabels = (/"ECMWF",case1,case2/)
  res@xyLineThicknesses      = (/2.,2.,2./)
  if (color_type .eq. "COLOR") then
    res@xyLineColors           = (/"black","red","blue"/)
    res@xyDashPatterns         = (/0,0,1/)
  else
    res@xyMonoLineColor       = True
    res@xyLineColor           = "black" 
    res@xyDashPatterns         = (/0,1,2/)
  end if
end if
res@tiYAxisString          = "Freshwater Transport (Sv)"
res@tiXAxisString          = "Latitude"
res@tiXAxisFontHeightF     = 0.017
res@tiYAxisFontHeightF     = 0.017
res@txFontHeightF          = 0.02
res@pmLegendParallelPosF   =  0.91              
res@pmLegendOrthogonalPosF = -1.03             
res@gsnYRefLine            = 0.0
;-----------------------------------------------------------------
; allow for models with grids other than T42
if (compare.eq."OBS") then
  dimXY = (/nlat0,nlat1/) 
  nMax = max(dimXY)
  data = new((/2,nMax/),float)        ; oft to plot 
  plat = new((/2,nMax/),float)        ; latitudes for plotting
  plat(0,0:dimXY(0)-1) = lat0 
  plat(1,0:dimXY(1)-1) = lat1 
else
  dimXY = (/nlat0,nlat1,nlat2/) 
  nMax = max(dimXY)
  data = new((/3,nMax/),float)        ; oft to plot 
  plat = new((/3,nMax/),float)        ; latitudes for plotting
  plat(0,0:dimXY(0)-1) = lat0 
  plat(1,0:dimXY(1)-1) = lat1 
  plat(2,0:dimXY(2)-1) = lat2 
end if
plat!0 = "line"
plat!1 = "lat"
data!0 = "line"

; total ocean
res@gsnLeftString = "Total Ocean"
data(0,0:dimXY(0)-1) = (/oft0(3,:)/)    ; ECMWF 
data(1,0:dimXY(1)-1) = (/oft1(3,:)/)    ; model 1 
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oft2(3,:)/)  ; model 2 
end if
plotO = gsn_csm_xy(wks,plat,data,res)

; pacific ocean
res@gsnLeftString = "Pacific Ocean"
delete(res@tiYAxisString)
data(0,0:dimXY(0)-1) = (/oft0(0,:)/)     ; ECMWF 
data(1,0:dimXY(1)-1) = (/oft1(0,:)/)     ; model 1 
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oft2(0,:)/)   ; model 2 
end if
plotP = gsn_csm_xy(wks,plat,data,res)

; atlantic ocean
res@gsnLeftString = "Atlantic Ocean"
res@tiYAxisString = "Freshwater Transport (Sv)"
data(0,0:dimXY(0)-1) = (/oft0(1,:)/)      ; ECMWF
data(1,0:dimXY(1)-1) = (/oft1(1,:)/)      ; model 1 
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oft2(1,:)/)    ; model 2 
end if
plotA = gsn_csm_xy(wks,plat,data,res)

; indian ocean
res@gsnLeftString = "Indian Ocean"
delete(res@tiYAxisString)
data(0,0:dimXY(0)-1) = (/oft0(2,:)/)      ; ECMWF 
data(1,0:dimXY(1)-1) = (/oft1(2,:)/)      ; model 1
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oft2(2,:)/)    ; model 2 
end if
plotI = gsn_csm_xy(wks,plat,data,res)

pan = True
pan@gsnMaximize = True
pan@gsnPaperOrientation = "portrait"
pan@gsnFrame = False
pan@gsnPanelTop = 0.96
if (time_stamp .eq. "True") then
  pan@gsnPanelBottom = 0.05
  gsn_panel(wks,(/plotO,plotP,plotA,plotI/),(/2,2/),pan)
  infoTimeStamp(wks,0.011,"DIAG Version: "+version)
else
  gsn_panel(wks,(/plotO,plotP,plotA,plotI/),(/2,2/),pan)
end if
txres = True
txres@txFontHeightF = 0.016
gsn_text_ndc(wks,"Annual Implied Northward Freshwater Transport",0.5,0.98,txres)
frame (wks)

end
