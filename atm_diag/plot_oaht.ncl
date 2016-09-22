; NCL script
; plot_oaht.ncl
; Mark Stevens, Sept 2001
; ocean and atmospheric heat transport
; plot data from model along with the NCEP derived and ECMWF data
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

;--------------------------------------------------------------------------
; MODEL 1 
; pointer to be passed in
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
fsns = get_FSNS (inptr1,outptr1)
flns = get_FLNS (inptr1,outptr1)
shfl = get_SHFLX (inptr1,outptr1)
lhfl = get_LHFLX (inptr1,outptr1)

; get the model ocean heat transport for the basins and total 
oht1 = oht_model (gw,oro,fsns,flns,shfl,lhfl)

; heat transport
if (compare .ne. "OBS") then
  ht1 = ht_surface (gw,oro,fsns,flns,shfl,lhfl,False)
  ht1c = ht_surface (gw,oro,fsns,flns,shfl,lhfl,True)
end if
delete(fsns)
delete(flns)
delete(shfl)
delete(lhfl)

; get the model required heat transport at TOA
if (isfilevar(inptr1,"FLUT")) then              ; ccm3.10 and later
  flut = get_FLUT (inptr1,outptr1)
  fsntoa = get_FSNTOA (inptr1,outptr1)
  restoa = flut
  restoa = (/fsntoa-flut/)
  rht1 = rht_model(gw,restoa)               ; (nlat1)
  delete(flut)
  delete(fsntoa)
else                                        ; ccm3.6
  flnt = get_FLNT (inptr1,outptr1)
  fsnt = get_FSNT (inptr1,outptr1)
  restoa = flnt
  restoa = (/fsnt-flnt/)
  rht1 = rht_model(gw,restoa)               ; (nlat1)
  delete(flnt)
  delete(fsnt)
end if
delete(gw)
delete(oro)
delete(restoa)

; Compute model atmospheric heat transport from rht and ocean
aht1 = new(nlat1,float)
aht1 = (/rht1-oht1(3,:)/)     ; (nlat1)

; MODEL 2 for model-to-model comparison
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
  fsns = get_FSNS (inptr2,outptr2)
  flns = get_FLNS (inptr2,outptr2)
  shfl = get_SHFLX (inptr2,outptr2)
  lhfl = get_LHFLX (inptr2,outptr2)

; get the model ocean heat transport for the basins and total 
  oht2=oht_model(gw,oro,fsns,flns,shfl,lhfl)

; heat transport
  ht2 = ht_surface (gw,oro,fsns,flns,shfl,lhfl,False)
  ht2c = ht_surface (gw,oro,fsns,flns,shfl,lhfl,True)

; get the model required heat transport at TOA
  if (isfilevar(inptr2,"FLUT")) then              ; ccm3.10 and later
    flut   = get_FLUT (inptr2,outptr2)
    fsntoa = get_FSNTOA (inptr2,outptr2)
    restoa = flut
    restoa = (/fsntoa-flut/)
    rht2 = rht_model (gw,restoa)              ; (nlat2)
  else                                        ; ccm3.6
    flnt = get_FLNT (inptr2,outptr2)
    fsnt = get_FSNT (inptr2,outptr2)
    restoa = flnt
    restoa = (/fsnt-flnt/)
    rht2 = rht_model (gw,restoa)         ; (nlat2)
  end if

; Compute model atmospheric heat transport from rht and ocean
  aht2 = new(nlat2,float)
  aht2 = (/rht2-oht2(3,:)/)     ; (nlat2)
end if

;-------------------------------------------------------------------------
; NCEP REANALYSIS AND ERBE DATA
; read in NCEP meridional transport data by Trenberth and Caron 
; which uses T42 latitudes
ncep_data = "$OBS_DATA/ANNUAL_TRANSPORTS_1985_1989.ascii"
nlatT42 = 64   ; T42 latitudes
i65s = 8       ; index of T42 latitude 65S
i65n = 55      ; index of T42 latitude 65N
ncep = asciiread(ncep_data,(/nlatT42,22/),"integer")

; set missing values to match the old missing values in NCL
ncep@_FillValue = -999 
ncep@missing_value = ncep@_FillValue 

T42lat = ncep(::-1,0)/100.           ; T42 latitudes
T42lat!0 = "lat"
T42lat&lat = T42lat
erbe_rht = ncep(::-1,1)/100.         ; global surface RHT from ERBE TOA
ncep_oht = new((/4,nlatT42/),float)
assignFillValue(ncep_oht,ncep_oht)
ncep_oht(0,:) = ncep(::-1,8)/100.    ; NCEP pacific ocean basin transport
ncep_oht(1,:) = ncep(::-1,7)/100.    ; NCEP atlantic ocean basin transport 
ncep_oht(1,i65n+1) = ncep_oht@_FillValue      ; set to missing since > 65N
ncep_oht(2,:) = ncep(::-1,9)/100.    ; NCEP indian ocean basin transport
ncep_oht(3,:) = ncep(::-1,4)/100.    ; NCEP total ocean transport 
ncep_oht(3,0:i65s-1) = ncep_oht@_FillValue   ; set values outside of 65N to 65S
ncep_oht(3,i65n+1:63) = ncep_oht@_FillValue  ; to missing

; atmospheric heat transport from ERBE and NCEP (ocean) 
ncep_aht = new(nlatT42,float)
ncep_aht = (/erbe_rht-ncep_oht(3,:)/) 

;************************************************************************
; OCEAN HEAT TRANSPORT PLOTS 
;************************************************************************
; plot resources
res                        = True
res@gsnFrame               = False
res@gsnDraw                = False
res@pmLegendSide           = "Right"            
res@pmLegendWidthF         = 0.15              
res@pmLegendDisplayMode    = "Always"
res@lgPerimOn              =  True
res@lgLabelFontHeightF     = 0.015
res@trXReverse             = True
if (compare .eq."OBS") then
  res@pmLegendHeightF        = 0.08             
  res@xyExplicitLegendLabels = (/"NCEP Derived",case1/)
  res@xyLineThicknesses      = (/2.,2./)
  if (color_type .eq. "COLOR") then
    res@xyLineColors           = (/"black","red"/)
    res@xyDashPatterns         = (/0,0/)
  else
    res@xyMonoLineColor      = True
    res@xyLineColor          = "black"
    res@xyDashPatterns       = (/0,1/)
  end if
else
  res@pmLegendHeightF        = 0.10             
  res@xyExplicitLegendLabels = (/"NCEP Derived",case1,case2/)
  res@xyLineThicknesses      = (/2.,2.,2./)
  if (color_type .eq. "COLOR") then
    res@xyLineColors           = (/"black","red","blue"/)
    res@xyDashPatterns         = (/0,0,1/)
  else
    res@xyMonoLineColor      = True
    res@xyLineColor          = "black"
    res@xyDashPatterns       = (/0,1,2/)
  end if
end if
res@tiYAxisString          = "Heat Transport (PW)"
res@tiXAxisString          = "Latitude"
res@tiXAxisFontHeightF     = 0.02
res@tiYAxisFontHeightF     = 0.02
res@txFontHeightF          = 0.02
res@gsnYRefLine            = 0.0
;-----------------------------------------------------------------
; allow for models with grids other than T42
if (compare .eq. "OBS") then
  dimXY = (/nlatT42,nlat1/) 
  nMax = max(dimXY)
  data = new((/2,nMax/),float)        ; data to plot 
  plat = new((/2,nMax/),float)        ; latitudes for plotting
  plat(0,0:dimXY(0)-1) = T42lat 
  plat(1,0:dimXY(1)-1) = lat1 
else
  dimXY = (/nlatT42,nlat1,nlat2/) 
  nMax = max(dimXY)
  data = new((/3,nMax/),float)        ; data to plot 
  plat = new((/3,nMax/),float)        ; latitudes for plotting
  plat(0,0:dimXY(0)-1) = T42lat 
  plat(1,0:dimXY(1)-1) = lat1
  plat(2,0:dimXY(2)-1) = lat2
end if
plat!0 = "line"
data!0 = "line"
;------------------------------------------------------------------
if (compare .eq. "OBS") then
  if (color_type .eq. "COLOR") then
    wks = gsn_open_wks(plot_type,wkdir+"set2_OHT_obsc")   
  else
    wks = gsn_open_wks(plot_type,wkdir+"set2_OHT_obs")   
  end if
else
  if (color_type .eq. "COLOR") then
    wks = gsn_open_wks(plot_type,wkdir+"set2_OHT_c")   
  else
    wks = gsn_open_wks(plot_type,wkdir+"set2_OHT")   
  end if
end if
plotO = new(1,"graphic")  
plotP = new(1,"graphic")  
plotA = new(1,"graphic")  
plotI = new(1,"graphic")  

res@pmLegendParallelPosF   =  0.08              
res@pmLegendOrthogonalPosF = -1.02            

; total ocean
res@gsnLeftString = "Total Ocean"
data(0,0:dimXY(0)-1) = (/ncep_oht(3,:)/) ; NCEP 
data(1,0:dimXY(1)-1) = (/oht1(3,:)/)     ; model 1
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oht2(3,:)/)   ; model 2
end if
plotO = gsn_csm_xy(wks,plat,data,res)

; pacific ocean
res@gsnLeftString = "Pacific Ocean"
delete(res@tiYAxisString)
data(0,0:dimXY(0)-1) = (/ncep_oht(0,:)/) ; NCEP
data(1,0:dimXY(1)-1) = (/oht1(0,:)/)     ; model 1

if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oht2(0,:)/)   ; model 2
end if
plotP = gsn_csm_xy(wks,plat,data,res)

res@pmLegendParallelPosF   =  0.92             
res@pmLegendOrthogonalPosF = -.42             

; atlantic ocean
res@gsnLeftString = "Atlantic Ocean"
res@tiYAxisString = "Heat Transport (PW)"
data(0,0:dimXY(0)-1) = (/ncep_oht(1,:)/)   ; NCEP
data(1,0:dimXY(1)-1) = (/oht1(1,:)/)       ; model 1
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oht2(1,:)/)     ; model 2
end if
plotA = gsn_csm_xy(wks,plat,data,res)

res@pmLegendParallelPosF   =  0.08              
res@pmLegendOrthogonalPosF = -1.02             

; indian ocean
res@gsnLeftString = "Indian Ocean"
delete(res@tiYAxisString)
data(0,0:dimXY(0)-1) = (/ncep_oht(2,:)/)  ; NCEP
data(1,0:dimXY(1)-1) = (/oht1(2,:)/)      ; model 1
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oht2(2,:)/)    ; model 2
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
gsn_text_ndc(wks,"Annual Implied Northward Ocean Heat Transport",0.5,0.98,txres)
frame (wks)
delete (wks)
delete (data)
delete (plat)
delete(res@xyExplicitLegendLabels)
delete(res@xyLineThicknesses)
delete(res@xyDashPatterns)
delete (res@gsnLeftString)
if (color_type .eq. "COLOR") then
  delete (res@xyLineColors)
end if
;***********************************************************************
; ATMOSPHERIC HEAT TRANSPORT 
;***********************************************************************
res@pmLegendHeightF   = 0.10             
res@xyLineThicknesses = (/2.,2.,2./)
if (color_type .eq. "COLOR") then
  res@xyLineColors    = (/"black","blue","red"/)
  res@xyDashPatterns  = (/0,1,0/)
else
  res@xyMonoLineColor = True
  res@xyLineColor     = "black"
  res@xyDashPatterns  = (/0,1,2/)
end if
res@pmLegendParallelPosF   =  0.91              
res@pmLegendOrthogonalPosF = -.42            
res@xyExplicitLegendLabels = (/"TOA Required","Ocean","Atmosphere"/)
res@gsnYRefLine = 0.0

if (compare .eq."OBS") then
  if (color_type .eq. "COLOR") then
    wks = gsn_open_wks(plot_type,wkdir+"set2_AHT_obsc")   
  else
    wks = gsn_open_wks(plot_type,wkdir+"set2_AHT_obs")   
  end if
else
  if (color_type .eq. "COLOR") then
    wks = gsn_open_wks(plot_type,wkdir+"set2_AHT_c")   
  else
    wks = gsn_open_wks(plot_type,wkdir+"set2_AHT")   
  end if
end if

; MODEL 1
plotM1 = new(1,"graphic")  
res@tiYAxisString = "Heat Transport (PW)"
res@gsnLeftString= case1
data = new((/3,nlat1/),float)      ; data to plot 
data!0 = "line"
plat = new(nlat1,float)            ; latitudes for plotting
plat = lat1 
data(0,:) = (/rht1/)              ; model 1 required transport 
data(1,:) = (/oht1(3,:)/)         ; model 1 ocean transport 
data(2,:) = (/aht1/)              ; model 1 atmosphere transport 
plotM1 = gsn_csm_xy(wks,plat,data,res)
delete (data)
delete (plat)

; ERBE/NCEP
plotN = new(1,"graphic")  
if (compare .eq. "OBS") then
  delete (res@tiYAxisString)
end if
res@gsnLeftString= "NCEP Derived"
data = new((/3,nlatT42/),float)      ; data to plot 
data!0 = "line"
plat = new(nlatT42,float)            ; latitudes for plotting
plat = T42lat 
data(0,:) = (/erbe_rht/)           ; ERBE required transport 
data(1,:) = (/ncep_oht(3,:)/)      ; NCEP ocean transport 
data(2,:) = (/ncep_aht/)           ; NCEP atmosphere transport 
plotN = gsn_csm_xy(wks,plat,data,res)
delete (data)
delete (plat)

; MODEL 2
if (compare.ne."OBS") then
  plotM2 = new(1,"graphic")  
  delete (res@tiYAxisString)
  res@gsnLeftString= case2
  data = new((/3,nlat2/),float)      ; data to plot 
  data!0 = "line"
  plat = new(nlat2,float)            ; latitudes for plotting
  plat = lat2
  data(0,:) = (/rht2/)              ; model 2 required transport 
  data(1,:) = (/oht2(3,:)/)         ; model 2 ocean transport 
  data(2,:) = (/aht2/)              ; model 2 atmosphere transport 
  plotM2 = gsn_csm_xy(wks,plat,data,res)
  delete (data)
  delete (plat)
end if

pan = True
pan@gsnMaximize = True
pan@gsnPaperOrientation = "portrait"
pan@gsnFrame = False
txres = True
txres@txFontHeightF = 0.016

if (compare .eq. "OBS") then
  gsn_panel(wks,(/plotM1,plotN/),(/1,2/),pan)
else
  pan@gsnPanelTop = 0.94
  gsn_panel(wks,(/plotM1,plotM2,plotN/),(/2,2/),pan)
end if
if (time_stamp .eq. "True") then
  infoTimeStamp(wks,0.011,"DIAG Version: "+version)
end if
if (compare .eq. "OBS") then
  gsn_text_ndc(wks,"Annual Implied Northward Heat Transports",0.5,0.84,txres)
  gsn_text_ndc(wks,"Atmosphere = (TOA Required - Ocean) Heat Transports",0.5,0.81,txres)
else
  gsn_text_ndc(wks,"Annual Implied Northward Heat Transports",0.5,0.985,txres)
  gsn_text_ndc(wks,"Atmosphere = (TOA Required - Ocean) Heat Transports",0.5,0.955,txres)
end if
frame (wks)

delete (dimXY)
delete (wks)
delete(res@xyExplicitLegendLabels)
delete(res@xyLineThicknesses)
if (color_type .eq. "COLOR") then
  delete(res@xyLineColors)
end if
delete(res@xyDashPatterns)
delete (res@gsnLeftString)

;***********************************************************************
; HEAT TRANSPORT 
;***********************************************************************
if (compare .ne. "OBS") then
  res@pmLegendHeightF   = 0.09             
  res@xyLineThicknesses = (/2.,2./)
  if (color_type .eq. "COLOR") then
    res@xyLineColors    = (/"blue","red"/)
    res@xyDashPatterns  = (/1,0/)
  else
    res@xyMonoLineColor = True
    res@xyLineColor     = "black"
    res@xyDashPatterns  = (/1,0/)
  end if
  res@xyExplicitLegendLabels = (/case1,case2/)
  res@pmLegendParallelPosF   =  0.91              
  res@pmLegendOrthogonalPosF = -.42            
  res@txFontHeightF          = 0.020
  res@tiYAxisString = "Heat Transport (PW)"
  res@gsnYRefLine = 0.0

  dimXY = (/nlat1,nlat2/) 
  nMax = max(dimXY)
  data = new((/4,nMax/),float)        ; data to plot 
  data!0 = "line"
  plat = new((/2,nMax/),float)        ; latitudes for plotting
  plat(0,0:dimXY(0)-1) = lat1 
  plat(1,0:dimXY(1)-1) = lat2
  plat!0 = "line"

  if (color_type .eq. "COLOR") then
    wks = gsn_open_wks(plot_type,wkdir+"set2_HT_c")   
  else
    wks = gsn_open_wks(plot_type,wkdir+"set2_HT")   
  end if

  plot = new(2,"graphic")  
  data(0,0:dimXY(0)-1) = (/ht1/)   ; model 1 heat transport 
  data(1,0:dimXY(1)-1) = (/ht2/)   ; model 2 heat transport 
  data(2,0:dimXY(0)-1) = (/ht1c/)  ; model 1 corrected heat transport 
  data(3,0:dimXY(1)-1) = (/ht2c/)  ; model 2 corrected heat transport 

  res@gsnCenterString = "No adjustment made"
  res@tiXAxisString = " "
  plot(0) = gsn_csm_xy(wks,plat,data(0:1,:),res)
  delete(res@gsnCenterString)

  res@gsnCenterString = "Global mean flux subtracted"
  res@tiXAxisString          = "Latitude"
  plot(1) = gsn_csm_xy(wks,plat,data(2:3,:),res)

  pan = True
  pan@gsnMaximize = True
  pan@gsnPaperOrientation = "portrait"
  pan@gsnFrame = False
  pan@txFontHeightF = 0.015
  pan@txString = "Annual Implied Northward Heat Transport"
  if (time_stamp.eq."True") then
    pan@gsnPanelBottom = 0.06
    gsn_panel(wks,plot,(/2,1/),pan)
    infoTimeStamp(wks,0.011,"DIAG Version: "+version)
  else
    gsn_panel(wks,plot,(/2,1/),pan)
  end if
  frame (wks)
end if

end
