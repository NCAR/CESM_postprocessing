load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/get_slabavg.ncl"
load "$NCLPATH/footer_text.ncl"

begin

   print( " plotting basin-average TEMP/SALT vs. depth for Arctic")

   fileid = addfile(file_netcdf,"r")
   tlat = fileid->TLAT
   tlon = fileid->TLONG
   
   temp = fileid->TEMP(0,:,:,:)
   if (isatt(temp,"_FillValue"))
      missing = temp@_FillValue
   else
      missing = 1e30
   end if
   salt = fileid->SALT(0,:,:,:)
   size = dimsizes(tlon)
   nx = size(1)
   ny = size(0)
   kmt = fileid->KMT
   kmu = fileid->KMU
   region_mask = fileid->REGION_MASK
   tarea = fileid->TAREA
   uarea = fileid->UAREA
   angle = fileid->ANGLE
   anglet = fileid->ANGLET
   ht = fileid->HT
   z_t = fileid->z_t
   nz = dimsizes(z_t)
   z_t = z_t / 100.
   
   misst = temp@_FillValue
   misss = salt@_FillValue
   fileid_obs = addfile(file_T_obs,"r")
   temp_obs = fileid_obs->TEMP
   depphc = fileid_obs->depth
   fileid_obs = addfile(file_S_obs,"r")
   salt_obs = fileid_obs->SALT
   temp_obs = where(temp_obs .lt. -90.0, temp_obs@_FillValue,temp_obs)
   salt_obs = where(salt_obs .lt. -90.0, salt_obs@_FillValue,salt_obs)
   
   
   ; define regions
   ; Eurasian basin
     ex = (/322.,360./)        ; min/max longitude
     ey = (/84., 90./)         ; min/max latitude
     ex2=(/0.,138./)           ; min/max longitude 2
     ey2=(/82.,90./)           ; min/max latitude 2
   ; ez=50                 ; min depth (using 60-level grid)
   ; Makarov Basin
    mx=(/185.,280./)           ; min/max longitude
    my=(/85.,90./)             ; min/max latitude
    mx2=(/142.,180./)          ; min/max longitude 2
    my2=(/80.,90./)            ; min/max latitude 2
   ;mz=48                  ; min depth (using 60-level grid)
   ; Canadian basin
    cx=(/180.,280./)           ; min/max longitude
    cy=(/70.,85./)             ; min/max latitude
   ;cz=48                  ; min depth (using 60-level grid)

   kmt_expand = conform_dims((/nz,ny,nx/),kmt,(/1,2/))
   kind = ispan(0,nz-1,1)
   kind_expand = conform_dims((/nz,ny,nx/),kind,0)
   kmask = where(kmt_expand .gt. kind_expand, True, False)
   delete([/kmt_expand,kind,kind_expand/])
   tlat_expand = conform_dims((/nz,ny,nx/),tlat,(/1,2/))
   tlon_expand = conform_dims((/nz,ny,nx/),tlon,(/1,2/))
   tarea_expand = conform_dims((/nz,ny,nx/),tarea,(/1,2/))
   tarea_expand = where(kmask,tarea_expand,tarea@_FillValue)
   tarea_expand@_FillValue = tarea@_FillValue
   delete(kmask)
   ; tarea_expand accounts for kmask and can be used for all subsequent calculations

   earea = tarea_expand
   earea = where((tlat_expand .ge. ey(0) .and. tlat_expand .le. ey(1) .and. \
                 tlon_expand .ge. ex(0) .and. tlon_expand .le. ex(1)) .or. \
                 (tlat_expand .ge. ey2(0) .and. tlat_expand .le. ey2(1) .and. \
                 tlon_expand .ge. ex2(0) .and. tlon_expand .le. ex2(1)), earea, earea@_FillValue)

   t_ebasin = dim_sum_n_Wrap(temp*earea,(/1,2/)) / dim_sum_n_Wrap(earea,(/1,2/))
   s_ebasin = dim_sum_n_Wrap(salt*earea,(/1,2/)) / dim_sum_n_Wrap(earea,(/1,2/))
   ephc = dim_sum_n_Wrap(temp_obs*earea,(/1,2/)) / dim_sum_n_Wrap(earea,(/1,2/))
   sephc = dim_sum_n_Wrap(salt_obs*earea,(/1,2/)) / dim_sum_n_Wrap(earea,(/1,2/))
   delete(earea)

   marea = tarea_expand
   marea = where((tlat_expand .ge. my(0) .and. tlat_expand .le. my(1) .and. \
                 tlon_expand .ge. mx(0) .and. tlon_expand .le. mx(1)) .or. \
                 (tlat_expand .ge. my2(0) .and. tlat_expand .le. my2(1) .and. \
                 tlon_expand .ge. mx2(0) .and. tlon_expand .le. mx2(1)), marea, marea@_FillValue)

   t_mbasin = dim_sum_n_Wrap(temp*marea,(/1,2/)) / dim_sum_n_Wrap(marea,(/1,2/))
   s_mbasin = dim_sum_n_Wrap(salt*marea,(/1,2/)) / dim_sum_n_Wrap(marea,(/1,2/))
   mphc = dim_sum_n_Wrap(temp_obs*marea,(/1,2/)) / dim_sum_n_Wrap(marea,(/1,2/))
   smphc = dim_sum_n_Wrap(salt_obs*marea,(/1,2/)) / dim_sum_n_Wrap(marea,(/1,2/))

   carea = tarea_expand
   carea = where(tlat_expand .ge. cy(0) .and. tlat_expand .le. cy(1) .and. \
                 tlon_expand .ge. cx(0) .and. tlon_expand .le. cx(1), carea, carea@_FillValue)

   t_cbasin = dim_sum_n_Wrap(temp*carea,(/1,2/)) / dim_sum_n_Wrap(carea,(/1,2/))
   s_cbasin = dim_sum_n_Wrap(salt*carea,(/1,2/)) / dim_sum_n_Wrap(carea,(/1,2/))
   cphc = dim_sum_n_Wrap(temp_obs*carea,(/1,2/)) / dim_sum_n_Wrap(carea,(/1,2/))
   scphc = dim_sum_n_Wrap(salt_obs*carea,(/1,2/)) / dim_sum_n_Wrap(carea,(/1,2/))

   ;wks = gsn_open_wks("x11","TSprof_Eurasianbasin")
   wks = gsn_open_wks(img_format,"TSprof_Eurasianbasin")
   gsn_define_colormap(wks,"table42")

   data = new((/2,nz/),float)
   data(0,:) = tofloat(t_ebasin)
   data(1,:) = tofloat(ephc)

   res = True
   res@tiMainFontHeightF = 0.022
   res@tiYAxisFontHeightF = 0.02
   res@tiXAxisFontHeightF = 0.02
   res@tiMainString = "Eurasian Basin Temp"
   res@tiXAxisString = "~S~o~N~C"
   res@tiYAxisString = "Depth"
   res@gsnMaximize = True
   res@xyLineColors = (/"black", "red"/)
   res@xyLineThicknessF = 2.0
   res@xyMonoDashPattern = True
   res@xyDashPattern = 0
   res@gsnPaperOrientation = "portrait"
   res@trYMaxF = 3000.0
   res@trYReverse = True
   res@trXMinF = min(data) - .2
   res@trXMaxF = max(data) + .2
   res@gsnDraw = False
   res@gsnFrame = False
   plot1 = gsn_csm_xy(wks,data,z_t,res)

   data(0,:) = tofloat(s_ebasin)
   data(1,:) = tofloat(sephc)
   res@tiMainString = "Eurasian Basin Salinity"
   res@tiXAxisString = "ppt"
   res@trXMinF = min(data) - .2
   res@trXMaxF = max(data) + .2
   plot2 = gsn_csm_xy(wks,data,z_t,res)

   opt = True
   opt@colors = (/ "black", "red" /)
   footer_text(wks,plot2,case_number,"PHC Obs",opt)

   panel_res = True
   panel_res@gsnPanelScalePlotIndex = 1
   ;panel_res@gsnPanelDebug = True
   panel_res@gsnPanelYF = (/-1,.50/)

   gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

   ;wks = gsn_open_wks("x11","TSprof_Canadabasin")
   wks = gsn_open_wks(img_format,"TSprof_Canadabasin")
   gsn_define_colormap(wks,"table42")

   res@tiMainString = "Canada Basin Temp"
   res@tiXAxisString = "~S~o~N~C"

   data(0,:) = tofloat(t_cbasin)
   data(1,:) = tofloat(cphc)
   res@trXMinF = min(data) - .2
   res@trXMaxF = max(data) + .2
   res@gsnDraw = False
   res@gsnFrame = False
   plot1 = gsn_csm_xy(wks,data,z_t,res)

   data(0,:) = tofloat(s_cbasin)
   data(1,:) = tofloat(scphc)

   res@tiMainString = "Canada Basin Salinity"
   res@tiXAxisString = "ppt"
   res@trXMinF = min(data) - .2
   res@trXMaxF = max(data) + .2

   plot2 = gsn_csm_xy(wks,data,z_t,res)

   footer_text(wks,plot2,case_number,"PHC Obs",opt)

   panel_res = True
   panel_res@gsnPanelScalePlotIndex = 1
   ;panel_res@gsnPanelDebug = True
   panel_res@gsnPanelYF = (/-1,.50/)

   gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

   ;wks = gsn_open_wks("x11","TSprof_Makarovbasin")
   wks = gsn_open_wks(img_format,"TSprof_Makarovbasin")
   gsn_define_colormap(wks,"table42")

   data(0,:) = tofloat(t_mbasin)
   data(1,:) = tofloat(mphc)

   res@tiMainString = "Makarov Basin Temp"
   res@tiXAxisString = "~S~o~N~C"
   res@tiYAxisString = "Depth"
   res@gsnMaximize = True
   res@xyLineColors = (/"black", "red"/)
   res@xyLineThicknessF = 2.0
   res@xyMonoDashPattern = True
   res@xyDashPattern = 0
   res@gsnPaperOrientation = "portrait"
   res@trYMaxF = 3000.0
   res@trYReverse = True
   res@trXMinF = min(data) - .2
   res@trXMaxF = max(data) + .2
   res@gsnDraw = False
   res@gsnFrame = False

   plot1 = gsn_csm_xy(wks,data,z_t,res)

   data(0,:) = tofloat(s_mbasin)
   data(1,:) = tofloat(smphc)

   res@tiMainString = "Makarov Basin Salinity"
   res@tiXAxisString = "ppt"
   res@trXMinF = min(data) - .2
   res@trXMaxF = max(data) + .2
   plot2 = gsn_csm_xy(wks,data,z_t,res)

   footer_text(wks,plot2,case_number,"PHC Obs",opt)

   panel_res = True
   panel_res@gsnPanelScalePlotIndex = 1
   ;panel_res@gsnPanelDebug = True
   panel_res@gsnPanelYF = (/-1,.50/)

   gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

end
