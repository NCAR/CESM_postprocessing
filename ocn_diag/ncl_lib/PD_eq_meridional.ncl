load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/pop_lon_shift.ncl"
load "$NCLPATH/pop_eq_avg.ncl"
begin
   file_PD_obs = getenv("TOGATAOFILE")
   fileid = addfile(file_netcdf,"r")
   pd = fileid->PD(0,:,:,:)
   if (isatt(pd,"_FillValue"))
      missing = pd@_FillValue
   else
      missing = 1e30
   end if
   pd = (pd - 1.0) * 1000. 
   units = pd@units
   tlon = fileid->TLONG
   tlat = fileid->TLAT
   size = dimsizes(tlon)
   nx = size(1)
   ny = size(0)
   z_t = fileid->z_t
   nz = dimsizes(z_t)
   z_t = z_t / 100.
   z_max = ind_nearest_coord(500.0,z_t,0)
   y_eq = ind_nearest_coord(0,tlat(:,0),0)

   fileid_obs = addfile(file_PD_obs,"r")
   if (file_PD_obs .eq. "tao_uv_data_climatology.nc") then
      plotobs = 0
   else if (file_PD_obs .eq. "meanfit_m.nc") then
      plotobs = 1
      obsstr = "Johnson et al (2002)"
      pdo = fileid_obs->SIGMAM
      misso = min(pdo)
      pdo = where(pdo .eq. misso,pdo@_FillValue,pdo)
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

   dmin      =  21.0
   dmax      =  27.
   dmin_diff = -3.
   dmax_diff =  3.
   nlev      =  31

   dlev = (dmax-dmin)/(nlev-1) 
   lev  = dmin + ispan(0,nlev-1,1)*dlev
   dlev_diff = (dmax_diff-dmin_diff)/(nlev-1) 
   lev_diff  = dmin_diff + ispan(0,nlev-1,1)*dlev_diff
   
   coltab = new(nlev + 1,"integer")
   coltab(0) = 1
   color1 = 2 
   coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
   coltab(0) = 0

   do ip = 0, nxobs - 1
      olon = lon_obs(ip)
      olonstr = sprinti("%3d",tointeger(olon))
      pd_obs = pdo(:,:,ip)
      xi = ind_nearest_coord(olon,tlon(y_eq,:),0)
      y_max = min(ind(tlat(:,xi) .ge. 10))
      y_min = max(ind(tlat(:,xi) .le. -10))
      mlon = tlon(y_eq,xi)
      mlonstr = sprintf("%5.1f", mlon) + "~S~o~N~E"
      pd1 = pd(:z_max,y_min:y_max,xi)
      pd1!1 = "lat"
      pd1&lat = tlat(y_min:y_max,xi)

      case_info = "PD AT "+mlonstr+" (kg / m~S~3~N~), " + case_number + " " + time_info
      filename="PD_"+olonstr+"E"
      print("plotting equatorial PD at " + olonstr + "E")
      ;wks = gsn_open_wks("x11",filename)
      wks = gsn_open_wks(img_format,filename)
      gsn_define_colormap(wks,"table42")
      
      res = True
      res@gsnDraw = False
      res@gsnFrame = False
      if (isatt(res,"sfYArray")) then
         delete(res@sfXArray)
         delete(res@sfYArray)
      end if
      res@sfYArray = z_t(:z_max)
      res@sfXArray = tlat(y_min:y_max,xi)
      res@cnFillOn = True
      ;res@cnFillMode = "RasterFill"
      res@cnInfoLabelOn = False
      res@cnLineLabelPlacementMode = "constant"
      ;res@cnLineLabelBackgroundColor = "transparent"
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
      plot1 = gsn_csm_contour(wks,pd1,res)  
      delete(pd1)
   
      case_info_obs =  "PD AT "+olonstr+" (kg / m~S~3~N~) "  + obsstr

      delete(res@sfXArray)
      delete(res@sfYArray)
      res@sfYArray = z_obs
      res@sfXArray = lat_obs
      res@gsnCenterString = case_info_obs
      res@tmXBLabelsOn = True
      plot2 = gsn_csm_contour(wks,pd_obs,res)
   
      panel_res = True
      panel_res@gsnMaximize = True
      panel_res@gsnPaperOrientation = "portrait"
      gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

   end do
end
