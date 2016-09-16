load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/pop_lon_shift.ncl"
load "$NCLPATH/pop_eq_avg.ncl"

begin
   file_T_obs = getenv("TOGATAOFILE")
   fileid_1 = addfile(file_netcdf,"r")
   salt_1 = fileid_1->SALT(0,:,:,:)
   salt_1 = where(salt_1 .gt. -10 .and. salt_1 .lt. 1e10,salt_1,salt_1@_FillValue)
   if (isatt(salt_1,"scale_factor")) then
      salt_1 = salt_1 * salt_1@scale_factor
   end if
   if (isatt(salt_1,"_FillValue"))
      missing = salt_1@_FillValue
   else
      missing = 1e30
   end if
   units = salt_1@units
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
   salt_2 = fileid_2->SALT(0,:,:,:)
   salt_2 = where(salt_2 .gt. -10 .and. salt_2 .lt. 1e10,salt_2,salt_2@_FillValue)
   if (isatt(salt_2,"scale_factor")) then
      salt_2 = salt_2 * salt_2@scale_factor
   end if

   fileid_obs = addfile(file_T_obs,"r")
   if (file_tao_obs .eq. "tao_uv_data_climatology.nc") then
      plotobs = 0
   else if (file_tao_obs .eq. "meanfit_m.nc") then
      plotobs = 1
      obsstr = "Johnson et al (2002)"
      salto = fileid_obs->SALINITYM
      misso = min(salto)
      salto = where(salto .eq. misso,salto@_FillValue,salto)
      lat_obs = fileid_obs->YLAT11_101
      lon_obs = fileid_obs->XLON
      z_obs = fileid_obs->ZDEP1_50
      nxobs = dimsizes(lon_obs)
      nyobs = dimsizes(lat_obs)
      nzobs = dimsizes(z_obs)
   else
      print("unrecognized salt obs files")
   end if
   end if

   dmin      =  32.0
   dmax      =  38.
   nlev      =  31

   dlev = (dmax-dmin)/(nlev-1) 
   lev  = dmin + ispan(0,nlev-1,1)*dlev

   dmin_diff = -1.
   dmax_diff =  1.
   nlev_diff = 21
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
      s_obs = salto(:,:,ip)
      xi = ind_nearest_coord(olon,tlon(y_eq,:),0)
      y_max = min(ind(tlat(:,xi) .ge. 10))
      y_min = max(ind(tlat(:,xi) .le. -10))
      mlon = tlon(y_eq,xi)
      mlonstr = sprintf("%5.1f", mlon) + "~S~o~N~E"
      salt1 = salt_1(:z_max,y_min:y_max,xi)
      salt1!1 = "lat"
      salt1&lat = tlat(y_min:y_max,xi)
      salt2 = salt_2(:z_max,y_min:y_max,xi)
      salt2!1 = "lat"
      salt2&lat = tlat(y_min:y_max,xi)

      salt_diff = salt1
      salt_diff = salt_diff - salt2

      print("plotting equatorial SALT at " + olonstr +"E")
      case_info = "SALT AT "+mlonstr+" (psu), " + case_number + " " + time_info
      filename="S_"+olonstr+"E"
      ;wks = gsn_open_wks("x11",filename)
      wks = gsn_open_wks(img_format,filename)
      gsn_define_colormap(wks,"table42")
      
      res = True
      res@vpWidthF = .9
      res@vpHeightF = 0.5
      res@gsnDraw = False
      res@gsnFrame = False
      if (isatt(res,"sfYArray")) then
         delete(res@sfXArray)
         delete(res@sfYArray)
      end if
      res@sfYArray = z_t(:z_max)
      res@sfXArray = tlat(y_min:y_max,xi)
      res@cnFillOn = True
      res@cnFillMode = "RasterFill"
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
      res@trYReverse = True
      res@trYMaxF = 400.0
      res@trYMinF = 0.0
      res@trXMaxF = 10.0
      res@trXMinF = -10.0
      res@tiXAxisOn = False
      plot1 = gsn_csm_contour(wks,salt1,res)  
   
      case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info
      res@gsnCenterString = case_info_diff
      delete(res@cnLevels)
      delete(res@cnFillColors)
      res@cnLevels = lev_diff
      res@cnFillColors = coltab_diff
      plot2 = gsn_csm_contour(wks,salt_diff,res)  

      if (plotobs .eq. 1) then
        case_info_obs =  "SALT AT "+olonstr+" (psu), "  + obsstr

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
        plot3 = gsn_csm_contour(wks,s_obs,res)
        
        panel_res = True
        panel_res@gsnMaximize = True
        panel_res@gsnPaperOrientation = "portrait"
        panel_res@gsnPanelBottom = .04
        gsn_panel(wks,(/plot1,plot2,plot3/), (/3,1/),panel_res)
        delete([/salt1,salt2,salt_diff,s_obs/])
      else
        gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)
        delete([/salt1,salt2,salt_diff/])
      end if
   end do
end
