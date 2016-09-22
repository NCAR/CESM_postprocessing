load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/pop_lon_shift.ncl"
load "$NCLPATH/pop_eq_avg.ncl"
begin
   fileid_1 = addfile(file_netcdf,"r")
   uvel_1 = fileid_1->UVEL(0,:,:,:)
   if (isatt(uvel_1,"_FillValue"))
      missing = uvel_1@_FillValue
   else
      missing = 1e30
   end if
   units = uvel_1@units
   ulon = fileid_1->ULONG
   ulat = fileid_1->ULAT
   size = dimsizes(uvel_1)
   nx = size(2)
   ny = size(1)
   nz = size(0)
   ulon = fileid_1->ULONG
   ulat = fileid_1->ULAT
   z_t = fileid_1->z_t
   nz = dimsizes(z_t)
   z_t = z_t / 100.

   fileid_2 = addfile(cntrl_netcdf,"r")
   uvel_2 = fileid_2->UVEL(0,:,:,:)

   z_max = ind_nearest_coord(500.0,z_t,0)
   y_eq = ind_nearest_coord(0,ulat(:,0),0)
   ulon = where(ulon .lt. 0, ulon+ 360, ulon)

   x_gw = ind_nearest_coord(0,ulon(y_eq,:),0)
   x_220 = ind_nearest_coord(220,ulon(y_eq,:),0)
   uvel1 = pop_lon_shift(uvel_1,x_gw)
   uvel2 = pop_lon_shift(uvel_2,x_gw)
   ulon = pop_lon_shift(ulon,x_gw)
   utmp1 = pop_eq_avg(uvel1,y_eq-1,y_eq,missing)
   utmp2 = pop_eq_avg(uvel2,y_eq-1,y_eq,missing)

   u_diff = utmp1
   u_diff = u_diff - utmp2

   fileid_obs = addfile(file_tao_obs,"r")
   if (file_tao_obs .eq. "tao_uv_data_climatology.nc") then
      obsstr = "tao_uv (??)"
      size = getfilevardimsizes(fileid_obs,"U")
      if (dimsizes(size) .eq. 3) then
          uvelo = fileid_obs->U(0,:,:)
          nx_obs = size(2)
          nz_obs = size(1)
      else if (dimsizes(size) .eq. 2) then
          uvelo = f->U
          nx_obs = size(1)
          nz_obs = size(0)
      else
          print("Cannot handle obs var of rank " + dimsizes(size))
      end if
      end if
      ulon_obs = fileid_obs->xint
      z_obs = fileid_obs->z
   else if (file_tao_obs .eq. "meanfit_m.nc") then
      obsstr = "Johnson et al (2002)"
      uvelo = fileid_obs->UM
      misso = min(uvelo)
      uvelo = where(uvelo .eq. misso,uvelo@_FillValue,uvelo)
      uvelo = uvelo * 100.0
      ulat_obs = fileid_obs->YLAT11_101
      ulon_obs = fileid_obs->XLON
      z_obs = fileid_obs->ZDEP1_50
      y_eq_obs = ind_nearest_coord(0,ulat_obs,0)
      if (dimsizes(dimsizes(uvelo)) .eq. 4) then
         u_obs = uvelo(0,:,y_eq_obs,:)
      else
         u_obs = uvelo(:,y_eq_obs,:)
      end if
   else
      print("unrecognized U obs files")
   end if
   end if
   
   dmin      =  -110.
   dmax      =  110.
   nlev      =  23 
   dlev = (dmax-dmin)/(nlev-1) 
   lev  = dmin + ispan(0,nlev-1,1)*dlev
   dmin_diff = -20.
   dmax_diff =  20.
   nlev_diff =  21
   dlev_diff = (dmax_diff-dmin_diff)/(nlev_diff-1)
   lev_diff  = dmin_diff + ispan(0,nlev_diff-1,1)*dlev_diff
   
   coltab = new(nlev + 1,"integer")
   color1 = 2 
   coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
   coltab(0) = 0
   
   coltab_diff = new(nlev_diff + 1,"integer")
   color1 = 2 
   coltab_diff(1:) = ((color2-color1+1)/(nlev_diff-1))*ispan(0,nlev_diff-1,1)+color1
   coltab_diff(0) = 0
   
   case_info = "UVEL AT EQ (cm s~S~-1~N~), " + case_number + " " + time_info

   ;;;;; Pacific
   
   print("plotting equatorial Pacific UVEL")
   ;wks = gsn_open_wks("x11","U_EQ_PAC")
   wks = gsn_open_wks(img_format,"U_EQ_PAC")
   gsn_define_colormap(wks,"table42")
   
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   res@sfYArray = z_t(0:z_max)
   res@sfXArray = ulon(y_eq,:)
   res@cnFillOn = True
   res@cnFillMode = "RasterFill"
   res@cnInfoLabelOn = False
   res@cnLineLabelPlacementMode = "constant"
   res@cnRasterSmoothingOn = True
   res@cnLevelSelectionMode = "explicitLevels"
   res@cnLevels = lev
   res@cnFillColors = coltab
   res@lbLabelBarOn = False
   res@tmEqualizeXYSizes = True
   res@tmXBLabelFontHeightF = 0.02
   res@tmXBLabelsOn = False
   res@tmXBMode = "explicit"
   res@tmXBValues = (/ 150, 200, 250 /)
   res@tmXBMinorValues = (/ 120, 130, 140, 160, 170, 180, 190, 210, 220, 230, 240, 260, 270, 280 /)
   res@tmXBLabels = (/ "150~S~o~N~E", "200~S~o~N~E", "250~S~o~N~E" /)
   res@tiYAxisString = "DEPTH (m)"
   res@tiYAxisFontHeightF = .025
   res@gsnYAxisIrregular2Linear = True
   res@gsnXAxisIrregular2Linear = True
   res@tiMainFontHeightF = .025
   res@tiMainOffsetYF = -0.01
   res@tiMainString = case_info
   res@gsnLeftString = ""
   res@gsnRightString = ""
   res@vpWidthF = 1.
   res@vpHeightF = 0.5
   res@trYReverse = True
   res@trYMaxF = 400.0
   res@trYMinF = 0.0
   res@trXMaxF = 290.0
   res@trXMinF = 110.0
   plot1 = gsn_csm_contour(wks,utmp1(:z_max,:),res)  
 
   case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info
   res@tiMainString = case_info_diff
   delete(res@cnLevels)
   delete(res@cnFillColors)
   res@cnLevels = lev_diff
   res@cnFillColors = coltab_diff
   plot2 = gsn_csm_contour(wks,u_diff(:z_max,:),res)

   case_info_obs = "UVEL AT EQ (cm s~S~-1~N~), " + obsstr
   delete(res@sfYArray)
   delete(res@sfXArray)
   res@sfYArray = z_obs
   res@sfXArray = ulon_obs
   res@tiMainString = case_info_obs
   res@tmXBLabelsOn = True
   res@tiXAxisString  = "Longitude"
   delete(res@cnLevels)
   delete(res@cnFillColors)
   res@cnLevels = lev
   res@cnFillColors = coltab
   plot3 = gsn_csm_contour(wks,u_obs,res)

   panel_res = True
   panel_res@gsnMaximize = True
   panel_res@gsnPaperOrientation = "portrait"
   panel_res@gsnPanelScalePlotIndex = 1
   panel_res@gsnPanelBottom = 0.075
   panel_res@gsnPanelYWhiteSpacePercent = 0.0
   gsn_panel(wks,(/plot1,plot2,plot3/), (/3,1/),panel_res)

   print("plotting equatorial Atlantic UVEL")
   ;;;;; Atlantic
   ;wks = gsn_open_wks("x11","U_EQ_ATL")
   wks = gsn_open_wks(img_format,"U_EQ_ATL")
   gsn_define_colormap(wks,"table42")

   ulon_eq = ulon(y_eq,:)
   ulon_eq(1:) = where(ulon_eq(1:) .lt. ulon_eq(:dimsizes(ulon_eq)-2),ulon_eq(1:)+360,ulon_eq(1:))

   delete(res@sfYArray)
   delete(res@sfXArray)
   res@sfYArray = z_t(0:z_max)
   res@sfXArray = ulon_eq
   res@tiMainString = case_info
   res@tmXBLabelsOn = True
   res@tmXBMode = "explicit"
   delete(res@tmXBValues)
   delete(res@tmXBLabels)
   delete(res@tmXBMinorValues)
   res@tmXBValues = (/ 310, 320, 330, 340, 350, 360 /)
   res@tmXBMinorValues = (/ 310,312,314,316,318,320,322,324,326,328,330,332,334,336,338,340,342,344,346,348,350,352,354,356,358 /)
   res@tmXBLabels = (/ "310~S~o~N~E", "320~S~o~N~E", "330~S~o~N~E", "340~S~o~N~E", "350~S~o~N~E", "0~S~o~N~E"  /)
   res@tiXAxisOn  = False

   res@trXMaxF = 360.0
   res@trXMinF = 310.0
   res@gsnPaperOrientation = "portrait"
   plot1 = gsn_csm_contour(wks,utmp1(:z_max,:),res)  

   case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info
   res@tiMainString = case_info_diff
   delete(res@cnLevels)
   delete(res@cnFillColors)
   res@cnLevels = lev_diff
   res@cnFillColors = coltab_diff
   res@tiXAxisOn  = True
   plot2 = gsn_csm_contour(wks,u_diff(:z_max,:),res)

   delete(panel_res@gsnPanelBottom)
   gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

   print("plotting equatorial Indian UVEL")
   ;;;;; Indian
   ;wks = gsn_open_wks("x11","U_EQ_IND")
   wks = gsn_open_wks(img_format,"U_EQ_IND")
   gsn_define_colormap(wks,"table42")

   ulon_eq = ulon(y_eq,:)
   ulon_eq(1:) = where(ulon_eq(1:) .lt. ulon_eq(:dimsizes(ulon_eq)-2),ulon_eq(1:)+360,ulon_eq(1:))

   res@tmXBLabelsOn = True
   res@tmXBMode = "explicit"
   delete(res@tmXBValues)
   delete(res@tmXBLabels)
   delete(res@tmXBMinorValues)
   res@tmXBValues = (/ 40,50,60,70,80,90, 100 /)
   res@tmXBMinorValues = ispan(42,98,2)
   res@tmXBLabels = (/ "40~S~o~N~E", "50~S~o~N~E", "60~S~o~N~E", "70~S~o~N~E", "80~S~o~N~E", "90~S~o~N~E", "100~S~o~N~E"  /)
   res@tiXAxisOn  = False

   res@trXMaxF = 100.0
   res@trXMinF = 40.0
   res@gsnPaperOrientation = "portrait"
   delete(res@cnLevels)
   delete(res@cnFillColors)
   res@cnLevels = lev
   res@cnFillColors = coltab
   res@tiMainString = case_info
   plot1 = gsn_csm_contour(wks,utmp1(:z_max,:),res)  

   case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info
   res@tiMainString = case_info_diff
   delete(res@cnLevels)
   delete(res@cnFillColors)
   res@cnLevels = lev_diff
   res@cnFillColors = coltab_diff
   res@tiXAxisOn  = True
   plot2 = gsn_csm_contour(wks,u_diff(:z_max,:),res)

   gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

end
