load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/pop_lon_shift.ncl"
load "$NCLPATH/pop_eq_avg.ncl"
begin
   file_T_obs = getenv("TOGATAOFILE")
   fileid_1 = addfile(file_netcdf,"r")
   temp_1 = fileid_1->TEMP(0,:,:,:)
   if (isatt(temp_1,"_FillValue"))
      missing = temp_1@_FillValue
   else
      missing = 1e30
   end if
   units = temp_1@units
   tlon = fileid_1->TLONG
   tlat = fileid_1->TLAT
   size = dimsizes(tlon)
   nx = size(1)
   ny = size(0)
   z_t = fileid_1->z_t
   nz = dimsizes(z_t)
   z_t = z_t / 100.
   z_max = ind_nearest_coord(500.0,z_t,0)
   y_eq = ind_nearest_coord(0,tlat(:,0),0)

   fileid_2 = addfile(cntrl_netcdf,"r")
   temp_2 = fileid_2->TEMP(0,:,:,:)

   fileid_obs = addfile(file_T_obs,"r")
   if (file_tao_obs .eq. "tao_uv_data_climatology.nc") then
      plotobs = 0
   else if (file_tao_obs .eq. "meanfit_m.nc") then
      plotobs = 1
      obsstr = "Johnson et al (2002)"
      tempo = fileid_obs->POTEMPM
      misso = min(tempo)
      tempo = where(tempo .eq. misso,tempo@_FillValue,tempo)
      lat_obs = fileid_obs->YLAT11_101
      lon_obs = fileid_obs->XLON
      z_obs = fileid_obs->ZDEP1_50
      nxobs = dimsizes(lon_obs)
      nyobs = dimsizes(lat_obs)
      nzobs = dimsizes(z_obs)
   else
      print("unrecognized U obs files")
   end if
   end if

   dmin      =   2.
   dmax      =  32.
   dmin_diff = -5.
   dmax_diff =  5.
   nlev      =  31
   nlev_diff =  21

   dlev = (dmax-dmin)/(nlev-1) 
   lev  = dmin + ispan(0,nlev-1,1)*dlev
   dlev_diff = (dmax_diff-dmin_diff)/(nlev_diff-1) 
   lev_diff  = dmin_diff + ispan(0,nlev_diff-1,1)*dlev_diff
   
   coltab = new(nlev + 1,"integer")
   color1 = 2 
   coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
   coltab(0) = 0

   coltab_diff = new(nlev_diff + 1,"integer")
   coltab_diff(1:) = ((color2-color1+1)/(nlev_diff-1))*ispan(0,nlev_diff-1,1)+color1
   coltab_diff(0) = 0

   do ip = 0, nxobs - 1
      olon = lon_obs(ip)
      olonstr = sprinti("%3d",tointeger(olon))
      t_obs = tempo(:,:,ip)
      xi = ind_nearest_coord(olon,tlon(y_eq,:),0)
      y_max = min(ind(tlat(:,xi) .ge. 10))
      y_min = max(ind(tlat(:,xi) .le. -10))
      mlon = tlon(y_eq,xi)
      mlonstr = sprintf("%5.1f", mlon) + "~S~o~N~E"
      temp1 = temp_1(:z_max,y_min:y_max,xi)
      temp1!1 = "lat"
      temp1&lat = tlat(y_min:y_max,xi)
      temp2 = temp_2(:z_max,y_min:y_max,xi)
      temp2!1 = "lat"
      temp2&lat = tlat(y_min:y_max,xi)
      temp_diff = temp1
      temp_diff = temp_diff - temp2

      case_info = "TEMP AT "+mlonstr+" (~S~o~N~C), " + case_number + " " + time_info
      filename="T_"+olonstr+"E"

      ;wks = gsn_open_wks("x11",filename)
      wks = gsn_open_wks(img_format,filename)
      gsn_define_colormap(wks,"table42")
      
      res = True
      res@gsnDraw = False
      res@gsnFrame = False
      res@vpWidthF = .9
      res@vpHeightF = 0.5
      if (isatt(res,"sfYArray")) then
         delete(res@sfXArray)
         delete(res@sfYArray)
      end if
      res@sfYArray = z_t(:z_max)
      res@sfXArray = tlat(y_min:y_max,xi)
      res@cnFillOn = True
      res@cnInfoLabelOn = False
      res@cnLineLabelPlacementMode = "constant"
      res@cnRasterSmoothingOn = True
      res@cnLevelSelectionMode = "explicitLevels"
      res@cnLevels = lev
      res@cnFillColors = coltab
      res@lbLabelBarOn = False
      res@tmXBLabelsOn = True
      res@tmXBMode = "explicit"
      res@tmXBValues = (/ -10,-5,0,5,10 /)
      res@tmXBMinorValues = ispan(-9,9,1)
      res@tmXBLabels = (/ "10~S~o~N~S", "5~S~o~N~S", "EQ", "5~S~o~N~N", "10~S~o~N~N" /)
      res@tmXBLabelFontHeightF = .02
      res@tiYAxisString = "DEPTH (m)"
      res@tiYAxisFontHeightF = .025
      res@gsnYAxisIrregular2Linear = True
      res@gsnXAxisIrregular2Linear = True
      res@gsnCenterString = case_info
      res@gsnLeftString = ""
      res@gsnRightString = ""
      res@vpWidthF = 0.9
      res@trYReverse = True
      res@trYMaxF = 400.0
      res@trYMinF = 0.0
      res@trXMaxF = 10.0
      res@trXMinF = -10.0
      res@tiXAxisOn = False
      plot1 = gsn_csm_contour(wks,temp1,res)  

      case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info
      res@gsnCenterString = case_info_diff
      delete(res@cnLevels)
      delete(res@cnFillColors)
      res@cnLevels = lev_diff
      res@cnFillColors = coltab_diff
      plot2 = gsn_csm_contour(wks,temp_diff,res)  

      case_info_obs =  "TEMP AT "+olonstr+" (~S~o~N~C), "  + obsstr
      delete(res@sfXArray)
      delete(res@sfYArray)
      res@sfYArray = z_obs
      res@sfXArray = lat_obs
      res@gsnCenterString = case_info_obs
      res@tmXBLabelsOn = True
      delete(res@cnLevels)
      delete(res@cnFillColors)
      res@cnLevels = lev
      res@cnFillColors = coltab
      res@tiXAxisString = "Latitude"
      res@tiXAxisOn = True
      plot3 = gsn_csm_contour(wks,t_obs,res)
   
      panel_res = True
      panel_res@gsnMaximize = True
      panel_res@gsnPaperOrientation = "portrait"
      panel_res@gsnPanelBottom = .04
      gsn_panel(wks,(/plot1,plot2,plot3/), (/3,1/),panel_res)
      delete([/temp1,temp2,temp_diff,t_obs/])

   end do
end
