; NCL script
; plot_polar_vecs.ncl
; Mark Stevens, Sept 2001
;*************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
;*************************************************************
begin
 compare    = getenv("COMPARE")
 color_type = getenv("COLORTYPE")
 rgb_file   = getenv("RGB_FILE")
 plot_type  = getenv("PLOTTYPE")
 season     = getenv("SEASON")
 version    = getenv("DIAG_VERSION")
 paleo      = getenv("PALEO")
 wkdir      = getenv("WKDIR")
 time_stamp = getenv("TIMESTAMP")
 tick_marks = getenv("TICKMARKS")
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename
 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
 end if

 if (paleo .eq. "True") then
   PALEO = True
   paleocoast1 = getenv("PALEOCOAST1")
   if (compare .eq. "USER") then
     paleocoast2 = getenv("PALEOCOAST2")
     diffs = getenv("DIFF_PLOTS")
     if (diffs .eq. "True") then
       DIFFS = True
     else
       DIFFS = False
     end if
   end if
 else
   PALEO = False
   DIFFS = True
 end if

; CASE 1 MODEL
 inptr1 = addfile(infile1,"r")
 if (ncdf_mode .eq. "write") then
   outptr1 = addfile(outfile1,"w")
 else
   outptr1 = addfile(outfile1,"c")
 end if
 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case        ; case names
 end if
 if (isatt(inptr1,"yrs_averaged")) then
   yrs_ave1 = inptr1@yrs_averaged
 end if
 lat1 = inptr1->lat           ; latitudes
 nlat1 = dimsizes(lat1)       ; number of latitudes
 lon1 = inptr1->lon           ; longitudes
 nlon1 = dimsizes(lon1)       ; number of longitudes

; CASE 2 MODEL OR OBS
 if (compare .eq. "OBS") then   ; always T42
   ptr_merra = addfile(infile2+"/MERRA_"+season+"_climo.nc","r") 
   lat2 = ptr_merra->lat
   nlat2 = dimsizes(lat2)
   lon2 = ptr_merra->lon
   nlon2 = dimsizes(lon2)
 else
   inptr2 = addfile(infile2,"r")
   if (ncdf_mode .eq. "write")
     outptr2 = addfile(outfile2,"w")
   else
     outptr2 = addfile(outfile2,"c")
   end if
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case         ; case names
   end if
   if (isatt(inptr2,"yrs_averaged")) then
     yrs_ave2 = inptr2@yrs_averaged
   end if
   lat2 = inptr2->lat
   nlat2 = dimsizes(lat2)
   lon2 = inptr2->lon
   nlon2 = dimsizes(lon2)
 end if
;-------------------------------------------------------------------
  Pcntrs_WIND=(/.5,1,1.5,2,2.5,3,4,5,6,7,8,9,10,11,12/) 
  dPcntrs_WIND=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/)
  Pcntrs_STRESS=(/.01,.02,.03,.04,.06,.08,.1,.12,.14,.16,.18,.2,.24,.28,.32/)
  dPcntrs_STRESS=(/-.12,-.09,-.06,-.04,-.03,-.02,-.01,0,.01,.02,.03,.04,.06,.09,.12/)

 if (compare.eq."OBS") then
   merra_vars = (/"STRESS_MERRA"/)
   obsvars = (/"STRESS_MERRA"/)
   vars = (/"STRESS_MAG"/)
   nvars = dimsizes(vars)
   Pcntrs = new((/nvars,15/),float)
   dPcntrs = new((/nvars,15/),float)
   Pcntrs(0,:)   = (/  Pcntrs_STRESS/)
   dPcntrs(0,:)  = (/  dPcntrs_STRESS/)
 else
   vars    = (/"WIND_MAG_LEV1","STRESS_MAG"/)
   Pcntrs   = (/ Pcntrs_WIND,  Pcntrs_STRESS/)
   dPcntrs  = (/ dPcntrs_WIND, dPcntrs_STRESS/)
   nvars = dimsizes(vars)
 end if

;--------------------------------------------------------------------
; common resources for vector polar plots
npminlat = 60
spmaxlat = -55
polar   = True
polar@gsnDraw  = False
polar@gsnFrame = False
if (tick_marks .eq. "True") then
  polar@gsnTickMarksOn = True 
else
  polar@gsnTickMarksOn = False
end if
polar@mpGridAndLimbOn = False
polar@tiMainFontHeightF = 0.025
;polar@txFont = "helvetica"
polar@txFontHeightF = 0.022
polar@mpGeophysicalLineThicknessF = 1.5
if (color_type .eq. "COLOR") then
  polar@cnLevelSelectionMode = "ExplicitLevels"
  polar@mpFillOn        = False        ; turn off grey continents
  polar@cnFillOn        = True
  polar@cnLinesOn       = False
  polar@cnLineLabelsOn = False
  polar@cnFillDrawOrder = "Predraw"
  polar@lbLabelBarOn = True
  polar@lbTitleOn    = True
  polar@lbLabelFontHeightF = 0.017
  polar@lbTitleFontHeightF = 0.018
  polar@lbLabelStride = 1
  polar@lbBoxMinorExtentF = 0.18
  polar@gsnScalarContour  = True
  polar@vcRefAnnoOn  = False
  cmap = RGBtoCmap(rgb_file)
else
  polar@mpFillOn       = True          ; turn on grey continents
  polar@vcRefAnnoOn  = True 
  polar@vcRefAnnoFontHeightF = 0.016
end if
polar@vcRefLengthF = 0.08
polar@vcMinDistanceF = 0.025
;--------------------------------------------------------------------
; common panel plot resources
panP = True
panP@gsnMaximize = True
panP@gsnFrame = False
panP@gsnPaperOrientation = "portrait"
;------------------------------------------------
plotNP0 = new(1,"graphic")     ; north polar 
plotSP0 = new(1,"graphic")     ; south polar 
plotNP1 = new(1,"graphic")     ; north polar 
plotSP2 = new(1,"graphic")     ; south polar 
;-------------------------------------------------------------------

do i = 0, nvars-1

  ;print("======== vecs ==== "+vars(i))

  if (vars(i) .eq. "WIND_MAG_LEV1") then     ; case 1 is model
    A = get_WIND_MAG_LEV1 (inptr1,outptr1)
    U1 = get_U_LEV1 (inptr1,outptr1)
    V1 = get_V_LEV1 (inptr1,outptr1)
  end if
  if (vars(i).eq."STRESS_MAG") then
    A = get_STRESS_MAG(inptr1,outptr1)
    U1 = get_TAUX_OCEAN(inptr1,outptr1)
    V1 = get_TAUY_OCEAN(inptr1,outptr1)
  end if

  if (compare .eq. "OBS") then               ; case 2 is obs
    if (any(obsvars(i) .eq. merra_vars)) then
      inptr2 = ptr_merra  
      case2 = "MERRA"
    end if 
    if (vars(i).eq."STRESS_MAG") then 
      B = inptr2->STRESS_MAG(0,{-90:90},:)
      U2 = inptr2->TAUX(0,{-90:90},:) 
      V2 = inptr2->TAUY(0,{-90:90},:) 
    end if
  else
    if (vars(i) .eq. "WIND_MAG_LEV1") then   ; case 2 is model
      B = get_WIND_MAG_LEV1 (inptr2,outptr2)
      U2 = get_U_LEV1 (inptr2,outptr2)
      V2 = get_V_LEV1 (inptr2,outptr2)
    end if
   if (vars(i).eq."STRESS_MAG") then 
      B = get_STRESS_MAG(inptr2,outptr2)
      U2 = get_TAUX_OCEAN(inptr2,outptr2) 
      V2 = get_TAUY_OCEAN(inptr2,outptr2) 
    end if
 
  end if

;-------------------------- Open files for plots ---------------------
  if (compare .eq. "OBS") then
    if (color_type .eq. "COLOR") then
      wksNP=gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+obsvars(i)+"_NP_obsc")
      gsn_define_colormap (wksNP,cmap)
      wksSP=gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+obsvars(i)+"_SP_obsc")
      gsn_define_colormap (wksSP,cmap)
    else
      wksNP= gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+obsvars(i)+"_NP_obs")
      wksSP= gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+obsvars(i)+"_SP_obs")
    end if
  else
    if (color_type .eq. "COLOR") then
      wksNP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+vars(i)+"_NP_c")
      gsn_define_colormap (wksNP,cmap)
      wksSP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+vars(i)+"_SP_c")
      gsn_define_colormap (wksSP,cmap)
    else
      wksNP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+vars(i)+"_NP")
      wksSP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+vars(i)+"_SP")
    end if
  end if

;------------------------ North Pole Plots ---------------------------
  polar@gsnPolar = "NH"
  polar@mpMinLatF = npminlat
  polar@gsnLeftString = A@long_name
  polar@gsnRightString = A@units

; min and max of vector magnitudes
  minnp1 = min(A({npminlat:},:))
  maxnp1 = max(A({npminlat:},:))
  minnp2 = min(B({npminlat:},:))
  maxnp2 = max(B({npminlat:},:))
  maxnp  = max((/maxnp1,maxnp2/))   ; max of A and B
  polar@vcRefMagnitudeF = maxnp     ; scale for vector lengths

; CASE 1 
  if (isvar("yrs_ave1")) then
    polar@tiMainString = case1+" (yrs "+yrs_ave1+")"
  else
    polar@tiMainString = case1
  end if
  if (PALEO) then
    polar@mpDataBaseVersion = "Ncarg4_1"
    polar@mpDataSetName = paleocoast1
  end if

  if (color_type .eq. "COLOR") then
    polar@lbOrientation = "Horizontal"
    polar@cnLevels = Pcntrs(i,:)
    polar@lbTitleOffsetF = -0.25
    polar@lbTitleString = "MIN = "+sprintf("%6.2f",minnp1)+ \
                         " MAX = "+sprintf("%6.2f",maxnp1)
    plotNP0 = gsn_csm_vector_scalar_map_polar (wksNP,U1,V1,A,polar)
  else
    polar@vcRefAnnoParallelPosF = 0.25
    plotNP0 = gsn_csm_vector_map_polar (wksNP,U1,V1,polar)
  end if

; CASE 2
  if (isvar("yrs_ave2")) then
    polar@tiMainString = case2+" (yrs "+yrs_ave2+")"
  else
    polar@tiMainString = case2
  end if
  if (PALEO) then
    if (compare.eq."USER") then
      polar@mpDataSetName = paleocoast2
    else
      delete(polar@mpDataBaseVersion)
      delete(polar@mpDataSetName)
    end if
  end if

  if (color_type .eq. "COLOR") then
    polar@lbTitleString = "MIN = "+sprintf("%6.2f",minnp2)+ \
                         " MAX = "+sprintf("%6.2f",maxnp2)
    plotNP1 = gsn_csm_vector_scalar_map_polar(wksNP,U2,V2,B,polar)
  else
    polar@vcRefAnnoParallelPosF = 0.9
    plotNP1 = gsn_csm_vector_map_polar(wksNP,U2,V2,polar)
  end if
  delete (polar@mpMinLatF)
  delete (polar@vcRefMagnitudeF)

;------------------------ South Pole Plots ---------------------------
  polar@gsnPolar = "SH"
  polar@mpMaxLatF = spmaxlat

; min and max of vector magnitudes
  minsp1 = min(A({:spmaxlat},:))
  maxsp1 = max(A({:spmaxlat},:))
  minsp2 = min(B({:spmaxlat},:))
  maxsp2 = max(B({:spmaxlat},:))
  maxsp  = max((/maxsp1,maxsp2/))   ; max of A and B
  polar@vcRefMagnitudeF = maxsp     ; scale for vector lengths

; CASE 1
  polar@tiMainString = case1
  if (PALEO) then
    polar@mpDataBaseVersion = "Ncarg4_1"
    polar@mpDataSetName = paleocoast1
  end if

  if (color_type .eq. "COLOR") then
    polar@lbTitleString = "MIN = "+sprintf("%6.2f",minsp1)+ \
                         " MAX = "+sprintf("%6.2f",maxsp1)
    plotSP0 = gsn_csm_vector_scalar_map_polar (wksSP,U1,V1,A,polar)
    delete(polar@lbTitleString)
  else
    polar@vcRefAnnoParallelPosF = 0.25
    plotSP0 = gsn_csm_vector_map_polar (wksSP,U1,V1,polar)
  end if

; CASE 2
  polar@tiMainString = case2
  if (PALEO) then
    if (compare.eq."USER") then
      polar@mpDataSetName = paleocoast2
    else
      delete(polar@mpDataBaseVersion)
      delete(polar@mpDataSetName)
    end if
  end if

  if (color_type .eq. "COLOR") then
    polar@lbTitleString = "MIN = "+sprintf("%6.2f",minsp2)+ \
                         " MAX = "+sprintf("%6.2f",maxsp2)
    plotSP1 = gsn_csm_vector_scalar_map_polar(wksSP,U2,V2,B,polar)
    delete(polar@lbTitleString)
    delete(polar@lbTitleOffsetF)
  else
    polar@vcRefAnnoParallelPosF = 0.9
    plotSP1 = gsn_csm_vector_map_polar(wksSP,U2,V2,polar)
  end if

  delete (polar@mpMaxLatF)
  delete (polar@tiMainString)
  delete (polar@vcRefMagnitudeF)

;-----------------------------------------------------------------------
; Interpolate data to coarser grid if needed before computing
; difference of case1 and case2 and then plot it
;--------------------------------------------------------------------

  if (nlat1 .eq. nlat2) then            ; same grids
    Udiff = U1                 ; no interpolation needed
    Udiff = (/U1 - U2/)
    Vdiff = V1
    Vdiff = (/V1 - V2/)
    C = A 
    C = (/A - B/)
  else
    if (nlat1 .gt. nlat2) then          ; interp nlat1 to nlat2
      tmp_u1 = linint2(lon1,lat1,U1,False,lon2,lat2,0)
      tmp_v1 = linint2(lon1,lat1,V1,False,lon2,lat2,0)
      Udiff = U2
      Udiff = (/tmp_u1 - U2/)
      Vdiff = V2
      Vdiff = (/tmp_v1 - V2/)
      delete (tmp_u1)
      delete (tmp_v1)
      tmp = linint2(lon1,lat1,A,False,lon2,lat2,0)
      C = B 
      C = (/tmp - B/)
      delete (tmp)
    else                                ; interp nlat2 to nlat1       
      tmp_u2 = linint2(lon2,lat2,U2,False,lon1,lat1,0)
      tmp_v2 = linint2(lon2,lat2,V2,False,lon1,lat1,0)
      Udiff = U1
      Udiff = (/U1 - tmp_u2/)
      Vdiff = V1
      Vdiff = (/V1 - tmp_v2/)
      delete (tmp_u2)
      delete (tmp_v2)
      tmp = linint2(lon2,lat2,B,False,lon1,lat1,0)
      C = A 
      C = (/A - tmp/)
      delete (tmp)
    end if
  end if

  delete(A)
  delete(B)
  delete(U1)
  delete(V1)
  delete(U2)
  delete(V2)

;------------------------------------------------------------------
; plot difference (case1-case2) and then do panel plot
;------------------------------------------------------------------
  if (PALEO .and. \
    (compare.ne."USER" .or. (compare.eq."USER" .and. .not.DIFFS))) then
;   NO DIFFERENCE PLOTS MADE

    panP@txString = season
    if (time_stamp .eq. "True") then
      panP@gsnPanelBottom = 0.05
      gsn_panel(wksNP,(/plotNP0,plotNP1/),(/2,1/),panP)
      infoTimeStamp(wksNP, 0.011, "DIAG Version: "+version)
      gsn_panel(wksSP,(/plotSP0,plotSP1/),(/2,1/),panP)
      infoTimeStamp(wksSP, 0.011, "DIAG Version: "+version)
    else
      gsn_panel(wksNP,(/plotNP0,plotNP1/),(/2,1/),panP)
      gsn_panel(wksSP,(/plotSP0,plotSP1/),(/2,1/),panP)
    end if
    frame(wksNP)
    frame(wksSP)
  else                     
;   MAKE DIFFERENCE PLOTS
    if (PALEO) then
      polar@mpDataBaseVersion = "Ncarg4_1"
      polar@mpDataSetName = paleocoast1
    end if
    polar@lbOrientation = "Vertical"
    polar@tiMainString = case1+" - "+case2

    ; north pole
    polar@gsnPolar = "NH"
    polar@mpMinLatF = npminlat
    mind = min(C({npminlat:},:))
    maxd = max(C({npminlat:},:))
    polar@vcRefMagnitudeF = maxd 

    if (color_type .eq. "COLOR") then
      polar@cnLevels = dPcntrs(i,:)
      polar@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                           " MAX = "+sprintf("%6.2f",maxd)
      plotNP2 = gsn_csm_vector_scalar_map_polar(wksNP,Udiff,Vdiff,C,polar)
      delete(polar@lbTitleString)
    else
      polar@vcRefAnnoParallelPosF = 0.9
      plotNP2 = gsn_csm_vector_map_polar(wksNP,Udiff,Vdiff,polar)
    end if
    delete (polar@mpMinLatF)
    delete (polar@vcRefMagnitudeF)

    ; south pole
    polar@gsnPolar = "SH"
    polar@mpMaxLatF = spmaxlat
    mind = min(C({:spmaxlat},:))
    maxd = max(C({:spmaxlat},:))
    polar@vcRefMagnitudeF = maxd 

    if (color_type .eq. "COLOR") then
      polar@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                           " MAX = "+sprintf("%6.2f",maxd)
      plotSP2 = gsn_csm_vector_scalar_map_polar(wksSP,Udiff,Vdiff,C,polar)
      delete(polar@lbTitleString)
    else
      polar@vcRefAnnoParallelPosF = 0.9
      plotSP2 = gsn_csm_vector_map_polar(wksSP,Udiff,Vdiff,polar)
    end if
    delete(polar@mpMaxLatF)
    delete(polar@tiMainString)
    delete (polar@vcRefMagnitudeF)

    panP@txString = season
    if (time_stamp .eq. "True") then
      panP@gsnPanelBottom = 0.05
      gsn_panel(wksNP,(/plotNP0,plotNP1,plotNP2/),(/2,2/),panP)
      infoTimeStamp(wksNP, 0.011, "DIAG Version: "+version)
      gsn_panel(wksSP,(/plotSP0,plotSP1,plotSP2/),(/2,2/),panP)
      infoTimeStamp(wksSP, 0.011, "DIAG Version: "+version)
    else
      gsn_panel(wksNP,(/plotNP0,plotNP1,plotNP2/),(/2,2/),panP)
      gsn_panel(wksSP,(/plotSP0,plotSP1,plotSP2/),(/2,2/),panP)
    end if
    frame(wksSP)
    frame(wksNP)
  end if
  delete(polar@gsnLeftString)
  delete(polar@gsnRightString)

end do        

end
