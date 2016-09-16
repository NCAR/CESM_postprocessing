;NCL script
; plot_surfaces_vecs.ncl
; Mark Stevens, Sept 2001
;*************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
;*************************************************************
begin
 compare     = getenv("COMPARE")
 color_type  = getenv("COLORTYPE")
 rgb_file    = getenv("RGB_FILE")
 plot_type   = getenv("PLOTTYPE")
 season      = getenv("SEASON")
 version     = getenv("DIAG_VERSION")
 paleo       = getenv("PALEO")
 wkdir       = getenv("WKDIR")
 time_stamp  = getenv("TIMESTAMP")
 tick_marks  = getenv("TICKMARKS")
 case_names  = getenv("CASENAMES")
 ncdf_mode   = getenv("NCDF_MODE")
 infile1     = getenv("TEST_INPUT")
 outfile1    = getenv("TEST_PLOTVARS")
 infile2     = getenv("CNTL_INPUT")
 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")
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
   case1 = inptr1@case    ; case names
 end if
 if (isatt(inptr1,"yrs_averaged")) then
   yrs_ave1 = inptr1@yrs_averaged
 end if

 lat1 = inptr1->lat       ; latitudes
 nlat1 = dimsizes(lat1)   ; number of latitudes
 lon1 = inptr1->lon       ; longitudes
 nlon1 = dimsizes(lon1)   ; number of longitudes
;jt  gw1 = inptr1->gw              ; gaussian weights
 if (isfilevar(inptr1,"gw")) then
   gw1 = inptr1->gw 
 else
   if (isfilevar(inptr1,"wgt")) then
     gw1 = inptr1->wgt
   else 
     gw1temp = latRegWgt(lat1,"double",0)  ; no gw1 in file
     gw1 = gw1temp
     delete(gw1temp)
     gw1!0 = "lat"
     gw1&lat = lat1
   end if
 end if

; CASE 2 MODEL OR OBS
 if (compare .eq. "OBS") then   ; always T42
   ptr_jra25 = addfile(infile2+"/JRA25_"+season+"_climo.nc","r")
   ptr_merra = addfile(infile2+"/MERRA_"+season+"_climo.nc","r") 
   ptr_ers = addfile(infile2+"/ERS_"+season+"_climo.nc","r") 
   ptr_laryea = addfile(infile2+"/LARYEA_"+season+"_climo.nc","r") 
 else
   inptr2 = addfile(infile2,"r")
   if (ncdf_mode .eq. "write") then
     outptr2 = addfile(outfile2,"w")
   else
     outptr2 = addfile(outfile2,"c")
   end if
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case    ; case names
   end if
   if (isatt(inptr2,"yrs_averaged")) then
     yrs_ave2 = inptr2@yrs_averaged
   end if
 end if


;-------------------------------------------------------------------
 
   ; contours definition (global)
   cntrs_STRESS=(/.01,.02,.03,.04,.06,.08,.1,.12,.14,.16,.18,.2,.24,.28,.32/)
   dcntrs_STRESS=(/-.12,-.09,-.06,-.04,-.03,-.02,-.01,0,.01,.02,.03,.04,.06,.09,.12/)
   cntrs_WIND=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/)  
   dcntrs_WIND=(/-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7/)

if (compare.eq."OBS") then
   
   jra25_vars = (/"STRESS_JRA25"/)
   merra_vars = (/"STRESS_MERRA"/)
   ers_vars   = (/"STRESS_ERS"/)
   laryea_vars = (/"STRESS_LARYEA"/)

   obsvars = (/ "STRESS_ERS", "STRESS_LARYEA", "STRESS_JRA25", "STRESS_MERRA"/)
   vars    = (/ "STRESS_MAG", "STRESS_MAG",    "STRESS_MAG",   "STRESS_MAG"  /)
   cntrs   = (/ cntrs_STRESS,  cntrs_STRESS,    cntrs_STRESS,  cntrs_STRESS  /)
   dcntrs  = (/ dcntrs_STRESS, dcntrs_STRESS,   dcntrs_STRESS, dcntrs_STRESS /)

   nvars = dimsizes(vars)

 else
   vars = (/"STRESS_MAG","WIND_MAG_LEV1"/)
   cntrs   = (/ cntrs_STRESS,   cntrs_WIND/)
   dcntrs  = (/ dcntrs_STRESS,  dcntrs_WIND/)
   nvars = dimsizes(vars)

 end if
;------------------------------------------------------------------
; common resources for global vector plots (STRESS and WIND)
 gminlat = -70
 gmaxlat = 70
 res                     = True  
 res@gsnDraw             = False
 res@gsnFrame            = False
 if (tick_marks .eq. "True") then
   res@gsnTickMarksOn = True
 else
   res@gsnTickMarksOn = False
 end if
 res@mpGridAndLimbOn   = False
 res@mpPerimOn = True
 res@mpPerimDrawOrder = "PostDraw"
 res@mpLimitMode        = "LatLon"
 res@mpMinLatF          = gminlat 
 res@mpMaxLatF          = gmaxlat
 res@mpMinLonF          = 0 
 res@mpMaxLonF          = 360 
 res@mpCenterLatF        = 0
 res@mpCenterLonF        = 180
 res@mpGeophysicalLineThicknessF = 1.5
 if (color_type .eq. "COLOR") then
   res@cnLevelSelectionMode="ExplicitLevels"
   res@mpFillOn            = False     ; turn off grey continents
   res@cnFillOn            = True
   res@cnLinesOn           = False
   res@cnLineLabelsOn      = False
   res@cnFillDrawOrder     = "Predraw"
   res@lbTitleOn           = True
   res@lbBoxMinorExtentF    = 0.18
   res@lbOrientation       = "Vertical"
   res@lbLabelFontHeightF  = 0.012
   res@lbTitleFontHeightF  = 0.013
   res@lbLabelStride       = 1        
   res@gsnScalarContour    = True
   res@vcRefAnnoOn         = False
   cmap = RGBtoCmap(rgb_file)
   res@vpWidthF = 0.90
   res@vpHeightF = 0.40
   res@mpShapeMode       = "FreeAspect"
   res@mpLimitMode       = "LatLon"
 else
   res@mpFillOn            = True      ; turn on grey continents
   res@vcRefAnnoOn         = True 
   res@vcRefAnnoFontHeightF = 0.009
 end if
 res@txFontHeightF     = 0.015
 res@tiMainFontHeightF = 0.018
 res@vcRefLengthF      = 0.06     ; increase size of arrows
 res@vcMinDistanceF    = 0.015
;--------------------------------------------------------------------
; common resources for tropical vector plots (STRESS only)
 minlat = -38       ; max lat for TRMM data 
 maxlat = 38
 minlon = -70 
 maxlon = 290 
 rest                   = True  
 rest@gsnDraw           = False     ; Do not draw plot
 rest@gsnFrame          = False     ; Do not advance frame
 rest@mpProjection      = "Mercator"
 rest@mpShapeMode       = "FreeAspect"
 rest@mpLimitMode       = "LatLon"
 rest@mpGridAndLimbOn   = False
 rest@mpPerimOn = True
 rest@mpPerimDrawOrder = "PostDraw"
 rest@mpMinLatF    = minlat 
 rest@mpMaxLatF    = maxlat
 rest@mpMinLonF    = minlon
 rest@mpMaxLonF    = maxlon
 rest@mpCenterLonF = (maxlon-minlon)/2.+ minlon   ; Centers the plot 
 rest@mpCenterLatF = (maxlat-minlat)/2.+ minlat             
 rest@mpGeophysicalLineThicknessF = 2.0
 rest@vpWidthF = 1.00
 rest@vpHeightF = 0.25
 if (color_type .eq. "COLOR") then
   rest@cnLevelSelectionMode="ExplicitLevels"
   rest@mpFillOn          = False     ; turn off grey continents
   rest@lbLabelBarOn = True
   rest@lbLabelStride     = 1
   rest@lbTitleOn = True
   rest@lbOrientation     = "Horizontal"
   rest@lbLabelFontHeightF = 0.012
   rest@lbTitleFontHeightF = 0.013
   rest@cnFillOn         = True
   rest@cnLinesOn        = False
   rest@cnLineLabelsOn   = False
   rest@cnFillDrawOrder  = "Predraw"
   rest@gsnScalarContour = True
   rest@vcRefAnnoOn      = False
 else
   rest@mpFillOn         = True      ; turn on grey continents
   rest@vcRefAnnoOn      = True 
   rest@vcRefAnnoFontHeightF = 0.008
 end if 
 rest@txFontHeightF     = 0.015
 rest@tiMainFontHeightF = 0.018
 rest@vcRefLengthF      = 0.06       ; increase size of arrows
 rest@vcMinDistanceF    = 0.013
;--------------------------------------------------------------------
; common resources for global panel plots
 pan = True
 pan@gsnMaximize = True
 pan@gsnFrame = False
 pan@gsnPaperOrientation = "portrait"
; common resources for tropical panel plots
 panT = True
 panT@gsnMaximize = True
 panT@gsnFrame = False
 panT@gsnPaperOrientation = "portrait"
;--------------------------------------------------------------------
 plot1 = new(1,"graphic")
 plot2 = new(1,"graphic")
 plot3 = new(1,"graphic")
 plotT1 = new(1,"graphic")     ; global tropics
 plotT2 = new(1,"graphic")     ; global tropics
 plotT3 = new(1,"graphic")     ; global tropics
;--------------------------------------------------------------------

do i = 0, nvars-1
  ;print("====="+vars(i))

  if (compare .eq. "OBS") then
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+"set6_"+season+"_"+obsvars(i)+"_obsc")
      gsn_define_colormap (wks,cmap)
      if ( obsvars(i).eq."STRESS_ERS".or. obsvars(i).eq."STRESS_LARYEA"\
        .or. obsvars(i).eq."STRESS_JRA25".or. obsvars(i).eq."STRESS_MERRA") then
         wksT=gsn_open_wks(plot_type,wkdir+"set6_"+season+"_"+obsvars(i)+"_TROP_obsc")
         gsn_define_colormap (wksT,cmap)
      end if
    else
      wks = gsn_open_wks(plot_type,wkdir+"set6_"+season+"_"+obsvars(i)+"_obs")
      if ( obsvars(i).eq."STRESS_ERS".or. obsvars(i).eq."STRESS_LARYEA"\
        .or. obsvars(i).eq."STRESS_JRA25".or. obsvars(i).eq."STRESS_MERRA") then
         wksT=gsn_open_wks(plot_type,wkdir+"set6_"+season+"_"+obsvars(i)+"_TROP_obs")
      end if
    end if
  else
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+"set6_"+season+"_"+vars(i)+"_c")
      gsn_define_colormap (wks,cmap)
      if (vars(i).eq."STRESS_MAG") then
        wksT = gsn_open_wks(plot_type,wkdir+"set6_"+season+"_"+vars(i)+"_TROP_c")
        gsn_define_colormap (wksT,cmap)
      end if
    else
      wks = gsn_open_wks(plot_type,wkdir+"set6_"+season+"_"+vars(i))
      if (vars(i).eq."STRESS_MAG") then
        wksT = gsn_open_wks(plot_type,wkdir+"set6_"+season+"_"+vars(i)+"_TROP")
      end if
    end if
  end if

; CASE 1 MODEL
  if (vars(i).eq."WIND_MAG_LEV1") then 
    A = get_WIND_MAG_LEV1(inptr1,outptr1)
    U1 = get_U_LEV1(inptr1,outptr1)
    V1 = get_V_LEV1(inptr1,outptr1)
    res@gsnLeftString = "First model level wind"
    res@gsnRightString = "m/s"
  end if   
  if (vars(i).eq."STRESS_MAG") then
    A = get_STRESS_MAG(inptr1,outptr1)
    U1 = get_TAUX_OCEAN(inptr1,outptr1)
    V1 = get_TAUY_OCEAN(inptr1,outptr1)
    res@gsnLeftString = "Surface stress"
    res@gsnRightString = "N/m~S~2~N~"
  end if

  if (compare.eq."OBS") then       ; CASE 2 IS OBS
    if (any(obsvars(i) .eq. jra25_vars)) then
      inptr2 = ptr_jra25  
      case2 = "JRA25"
    end if 
    if (any(obsvars(i) .eq. merra_vars)) then
      inptr2 = ptr_merra  
      case2 = "MERRA"
    end if 
    if (any(obsvars(i) .eq. ers_vars)) then
      inptr2 = ptr_ers  
      case2 = "ERS"
    end if 
    if (any(obsvars(i) .eq. laryea_vars)) then
      inptr2 = ptr_laryea  
      case2 = "LARGE-YEAGER"
    end if 
    if (vars(i).eq."STRESS_MAG") then 
      B = inptr2->STRESS_MAG(0,{-90:90},:)
      U2 = inptr2->TAUX(0,{-90:90},:) 
      V2 = inptr2->TAUY(0,{-90:90},:) 
    end if
  else                             ; CASE 2 IS MODEL
    if (vars(i).eq."WIND_MAG_LEV1") then 
      B = get_WIND_MAG_LEV1(inptr2,outptr2)
      U2 = get_U_LEV1(inptr2,outptr2) 
      V2 = get_V_LEV1(inptr2,outptr2) 
    end if
    if (vars(i).eq."STRESS_MAG") then 
      B = get_STRESS_MAG(inptr2,outptr2)
      U2 = get_TAUX_OCEAN(inptr2,outptr2) 
      V2 = get_TAUY_OCEAN(inptr2,outptr2) 
    end if
  end if
  lat2 = inptr2->lat
  nlat2 = dimsizes(lat2)
  lon2 = inptr2->lon
  nlon2 = dimsizes(lon2)
;jt   gw2 = inptr2->gw 
  if (isfilevar(inptr2,"gw")) then
    gw2 = inptr2->gw 
  else
    if (isfilevar(inptr2,"wgt")) then
      gw2 = inptr2->wgt
    else 
      gw2temp = latRegWgt(lat2,"double",0)  ; no gw2 in file
      gw2 = gw2temp
      delete(gw2temp)
      gw2!0 = "lat"
      gw2&lat = lat2
    end if
  end if
    

;********************* Global plots ***************************
; global min and max
  min1 = min(A)
  max1 = max(A)
  min2 = min(B)
  max2 = max(B)
  res@vcRefMagnitudeF = max((/max1,max2/))   ; scale for vector lengths

; compute global mean of the magnitudes (STRESS or WIND) 
  gblmean1 = wgt_areaave (A,gw1,1.0,0)
  gblmean2 = wgt_areaave (B,gw2,1.0,0)

; CASE 1 
  if (isvar("yrs_ave1")) then
    res@tiMainString = case1+" (yrs "+yrs_ave1+")"
  else
    res@tiMainString = case1
  end if
  res@gsnCenterString = "mean= "+sprintf("%6.2f",gblmean1) 

  if (PALEO) then
    res@mpDataBaseVersion = "Ncarg4_1"
    res@mpDataSetName = paleocoast1
  end if

  if (color_type .eq. "COLOR") then
    res@cnLevels = cntrs(i,:)
    res@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                       " MAX = "+sprintf("%6.2f",max1)
    plot1 = gsn_csm_vector_scalar_map_ce (wks,U1,V1,A,res)
  else
    plot1 = gsn_csm_vector_map_ce (wks,U1,V1,res)
  end if

  delete (res@tiMainString)
  delete (res@gsnCenterString)

; CASE 2 
  if (isvar("yrs_ave2")) then
    res@tiMainString = case2+" (yrs "+yrs_ave2+")"
  else
    res@tiMainString = case2
  end if
  res@gsnCenterString = "mean= "+sprintf("%6.2f",gblmean2) 

  if (PALEO) then
    if (compare.eq."USER") then
      res@mpDataSetName = paleocoast2
    else
      delete(res@mpDataBaseVersion)
      delete(res@mpDataSetName)
    end if
  end if

  if (color_type .eq. "COLOR") then
    res@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                       " MAX = "+sprintf("%6.2f",max2)
                       
    plot2 = gsn_csm_vector_scalar_map_ce (wks,U2,V2,B,res)
  else
    plot2 = gsn_csm_vector_map_ce (wks,U2,V2,res)
  end if
  delete (res@tiMainString)
  delete (res@gsnCenterString)
  delete (res@vcRefMagnitudeF)

;********************* Tropical plots ***************************
  if (vars(i).eq."STRESS_MAG") then   
    tmin1 = min(A({minlat:maxlat},:))
    tmax1 = max(A({minlat:maxlat},:))
    tmin2 = min(B({minlat:maxlat},:))
    tmax2 = max(B({minlat:maxlat},:))
    rest@vcRefMagnitudeF = max((/tmax1,tmax2/))  ; scale for vector lengths

;   CASE 1
    tropmean1=wgt_areaave(A({minlat:maxlat},:),gw1({minlat:maxlat}),1.0,0)
    if (isvar("yrs_ave1")) then
      rest@tiMainString = case1+" (yrs "+yrs_ave1+")"
    else
      rest@tiMainString = case1
    end if
    rest@gsnCenterString = "mean= "+sprintf("%6.2f",tropmean1) 
 
    if (PALEO) then
      rest@mpDataBaseVersion = "Ncarg4_1"
      rest@mpDataSetName = paleocoast1
    end if

    if (color_type .eq. "COLOR") then
      rest@cnLevels = cntrs(i,:)
      rest@lbTitleString = "MIN = "+sprintf("%6.2f",tmin1)+ \
                          " MAX = "+sprintf("%6.2f",tmax1)
      plotT1=gsn_csm_vector_scalar_map_other(wksT,U1,V1,A,rest)
    else
      plotT1 = gsn_csm_vector_map_other(wksT,U1,V1,rest)
    end if
    delete (rest@tiMainString)
    delete (rest@gsnCenterString)

;   CASE 2
    tropmean2=wgt_areaave(B({minlat:maxlat},:),gw2({minlat:maxlat}),1.0,0)
    if (isvar("yrs_ave2")) then
      rest@tiMainString = case2+" (yrs "+yrs_ave2+")"
    else
      rest@tiMainString = case2
    end if
    rest@gsnCenterString = "mean= "+sprintf("%6.2f",tropmean2) 

    if (PALEO) then
      if (compare.eq."USER") then
        rest@mpDataSetName = paleocoast2
      else
        delete(rest@mpDataBaseVersion)
        delete(rest@mpDataSetName)
      end if
    end if

    if (color_type .eq. "COLOR") then
      rest@lbTitleString = "MIN = "+sprintf("%6.2f",tmin2)+ \
                          " MAX = "+sprintf("%6.2f",tmax2)
      plotT2=gsn_csm_vector_scalar_map_other(wksT,U2,V2,B,rest)
    else
      plotT2 = gsn_csm_vector_map_other(wksT,U2,V2,rest)
    end if
    delete (rest@tiMainString)
    delete (rest@gsnCenterString)
    delete (rest@vcRefMagnitudeF)
  end if
;-----------------------------------------------------------------------
; Interpolate data to coarser grid if needed before computing
; difference of case1 and case2 and then plot it
;--------------------------------------------------------------------

  if (nlat1 .eq. nlat2) then      ; same grids
    Udiff = U1                    ; no interpolation needed
    Udiff = (/U1 - U2/)
    Vdiff = V1
    Vdiff = (/V1 - V2/)
    C = A
    C = (/A - B/)
    gw = gw1
  else
    if (nlat1 .gt. nlat2) then          ; interp a to nlat2
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
      gw = gw2
    else                                ; interp b to nlat1       
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
      gw = gw1
    end if
  end if

  delete(A)
  delete(B)
  delete(U1)
  delete(V1)
  delete(U2)
  delete(V2)
  delete(gw2)
  delete(lat2)
  delete(lon2)

;------------------------------------------------------------------
; plot difference (case1-case2) and then do panel plot
;------------------------------------------------------------------
  if (PALEO .and. \
    (compare.ne."USER" .or. (compare.eq."USER" .and. .not.DIFFS))) then
;   NO DIFFERENCE PLOTS MADE
    if (time_stamp .eq. "True") then      ; global plot
      pan@gsnPanelBottom = 0.05
      gsn_panel(wks,(/plot1,plot2/),(/2,1/),pan)
      infoTimeStamp(wks, 0.011, "DIAG Version: "+version)
    else
      gsn_panel(wks,(/plot1,plot2/),(/2,1/),pan)
    end if
    txres = True
    txres@txFontHeightF = 0.025
    gsn_text_ndc(wks,season,0.78,0.97,txres)
    frame(wks)

    if (vars(i).eq."STRESS_MAG") then      ; tropics plot
      panT@txString = season
      if (time_stamp .eq. "True") then
        panT@gsnPanelBottom = 0.05
        gsn_panel(wksT,(/plotT1,plotT2/),(/2,1/),panT)
        infoTimeStamp(wksT, 0.011, "DIAG Version: "+version)
      else
        gsn_panel(wksT,(/plotT1,plotT2/),(/2,1/),panT)
      end if
      frame(wksT)
    end if
  else               
;   MAKE DIFFERENCE PLOTS
    mind = min(C)
    maxd = max(C)
    res@vcRefMagnitudeF = maxd

    gblmean = wgt_areaave (C,gw,1.0,0)

    res@tiMainString = case1+" - "+case2
    res@gsnCenterString = "mean= "+sprintf("%6.2f",gblmean)

    if (PALEO) then
      res@mpDataBaseVersion = "Ncarg4_1"
      res@mpDataSetName = paleocoast1
    end if

    if (color_type .eq. "COLOR") then
      res@cnLevels = dcntrs(i,:)
      res@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                         " MAX = "+sprintf("%6.2f",maxd)
      plot3 = gsn_csm_vector_scalar_map_ce (wks,Udiff,Vdiff,C,res)
    else
      plot3 = gsn_csm_vector_map_ce (wks,Udiff,Vdiff,res)
    end if
    delete (res@gsnCenterString)
    delete (res@tiMainString)
    delete (res@vcRefMagnitudeF)

    ; tropical difference plots
    if (vars(i).eq."STRESS_MAG") then
      mind = min(C({minlat:maxlat},:))
      maxd = max(C({minlat:maxlat},:))
      rest@vcRefMagnitudeF = maxd

      tropmean = wgt_areaave(C({minlat:maxlat},:),gw({minlat:maxlat}),1.0,0)

      rest@gsnCenterString = "mean= "+sprintf("%6.2f",tropmean)
      rest@tiMainString = case1+" - "+case2

      if (PALEO) then
        rest@mpDataBaseVersion = "Ncarg4_1"
        rest@mpDataSetName = paleocoast1
      end if

      if (color_type .eq. "COLOR") then
        rest@cnLevels = dcntrs(i,:)
        rest@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                            " MAX = "+sprintf("%6.2f",maxd)
        plotT3 = gsn_csm_vector_scalar_map_other (wksT,Udiff,Vdiff,C,rest)
      else
        plotT3 = gsn_csm_vector_map_other (wksT,Udiff,Vdiff,rest)
      end if
      delete(rest@gsnCenterString)
      delete(rest@tiMainString)
      delete (rest@vcRefMagnitudeF)
    end if

    ; global panel plot
    if (color_type .eq. "MONO") then
      pan@txString = season
      pan@txFontHeightF = 0.015
    end if
    if (time_stamp .eq. "True") then
      pan@gsnPanelBottom = 0.05
      gsn_panel(wks,(/plot1,plot2,plot3/),(/3,1/),pan)
      infoTimeStamp(wks, 0.011, "DIAG Version: "+version)
    else
      gsn_panel(wks,(/plot1,plot2,plot3/),(/3,1/),pan)
    end if
    if (color_type .eq. "COLOR") then
      txres = True
      txres@txFontHeightF = 0.020
      gsn_text_ndc(wks,season,0.78,0.97,txres)
    end if
    frame(wks)

    ; tropical panel plot
    if (vars(i).eq."STRESS_MAG") then
      panT@txString = season
      if (time_stamp .eq. "True") then
        panT@gsnPanelBottom = 0.05
        gsn_panel(wksT,(/plotT1,plotT2,plotT3/),(/3,1/),panT)
        infoTimeStamp(wksT, 0.011, "DIAG Version: "+version)
      else
        gsn_panel(wksT,(/plotT1,plotT2,plotT3/),(/3,1/),panT)
      end if
      frame(wksT)
    end if
  end if
  delete(Udiff)
  delete(Vdiff)
  delete(C)
  delete(gw)
end do        

end
