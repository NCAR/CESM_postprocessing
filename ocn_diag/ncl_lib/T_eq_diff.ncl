load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/pop_lon_shift.ncl"
load "$NCLPATH/pop_eq_avg.ncl"
begin

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
   ulon = fileid_1->ULONG
   ulat = fileid_1->ULAT
   kmt = fileid_1->KMT
   kmu = fileid_1->KMU
   region_mask = fileid_1->REGION_MASK
   tarea = fileid_1->TAREA
   uarea = fileid_1->UAREA
   angle = fileid_1->ANGLE
   anglet = fileid_1->ANGLET
   z_t = fileid_1->z_t
   nz = dimsizes(z_t)
   z_t = z_t / 100.
   z_max = ind_nearest_coord(500.0,z_t,0)
   
   fileid_2 = addfile(cntrl_netcdf,"r")
   temp_2 = fileid_2->TEMP(0,:,:,:)

   y_eq = ind_nearest_coord(0,tlat(:,0),0)
   east30 = ind_nearest_coord(30,tlon(y_eq,:),0)

   tlat = pop_lon_shift(tlat,east30)
   tlon =  pop_lon_shift(tlon,east30)
   field_1 =  pop_lon_shift(temp_1,east30)
   field_2 = pop_lon_shift(temp_2,east30)

   temp1 = pop_eq_avg(field_1,y_eq-1,y_eq,missing)
   temp2 = pop_eq_avg(field_2,y_eq-1,y_eq,missing)
   
   temp1_diff = temp1
   temp1_diff = temp1 - temp2

   tlon_eq = tlon(y_eq,:)
   tlon_eq = where(tlon_eq .lt. 30, tlon_eq + 360, tlon_eq)
   
   dmin      =   2.
   dmax      =  32.
   dmin_diff = -6.
   dmax_diff =  6.
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
   
   case_info = "TEMP AT EQ " + case_number + " " + time_info
   case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info
   
   ;wks = gsn_open_wks("x11","T_EQ")
   wks = gsn_open_wks(img_format,"T_EQ")
   gsn_define_colormap(wks,"table42")
   
   res = True
   res@gsnDraw = False
   res@gsnFrame = False
   res@sfYArray = z_t(:z_max)
   res@sfXArray = tlon_eq
   res@cnFillOn = True
   res@cnFillMode = "RasterFill"
   res@cnInfoLabelOn = False
   res@cnLineLabelPlacementMode = "constant"
   res@cnRasterSmoothingOn = True
   res@cnLevelSelectionMode = "explicitLevels"
   res@cnLevels = lev
   res@cnFillColors = coltab
   res@lbLabelBarOn = False
   res@tmXBLabelsOn = False
   res@tiYAxisString = "DEPTH (m)"
   res@tiYAxisFontHeightF = .025
   res@gsnYAxisIrregular2Linear = True
   res@gsnCenterString = case_info
   res@vpWidthF = 0.9
   res@trYReverse = True
   res@trYMaxF = 400.0
   res@trYMinF = 0.0
   plot1 = gsn_csm_contour(wks,temp1(:z_max,:),res)  

   res@cnLevels = lev_diff
   res@gsnCenterString = case_info_diff
   res@tmXBLabelsOn = True
   res@tmXBMode = "explicit"
   res@tmXBValues = (/ 100, 200, 300 /)
   res@tmXBMinorValues = (/ 40, 60, 80, 120, 140, 160, 180, 220, 240, 260, 280, 320, 340, 360, 380 /)
   res@tmXBLabels = (/ "100~S~o~N~E", "200~S~o~N~E", "300~S~o~N~E" /)
   plot2 = gsn_csm_contour(wks,temp1_diff(:z_max,:),res)

   panel_res = True
   panel_res@gsnMaximize = True
   panel_res@gsnPaperOrientation = "portrait"
   panel_res@gsnPanelScalePlotIndex = 1
   panel_res@gsnPanelYF = (/-1,.50/)
   gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

end
