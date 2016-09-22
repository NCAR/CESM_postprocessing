load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/contour_plot.ncl"
load "$NCLPATH/curl_pop.ncl"

begin

  seasavgfile_netcdf = getenv("SEASAVGFILE")
  seasavgcntrl_netcdf = getenv("CNTRLSEASAVGFILE")

  nm      = 12
  nlev    = 21
  missing = 1.0e30

  fileid = addfile(file_netcdf,"r")
  lon = fileid->TLONG
  lat = fileid->TLAT
  tarea = fileid->TAREA
  delete(fileid)

  fileid_1 = addfile(seasavgfile_netcdf,"r")
  fileid_2 = addfile(seasavgcntrl_netcdf,"r")
  if (dimsizes(getfilevardimsizes(fileid_1,"TEMP")) .gt. 3) then
    field_1 = fileid_1->TEMP(:,0,:,:)
  else
    field_1 = fileid_1->TEMP
  end if
  if (dimsizes(getfilevardimsizes(fileid_2,"TEMP")) .gt. 3) then
    field_2 = fileid_2->TEMP(:,0,:,:)
  else
    field_2 = fileid_2->TEMP
  end if


  size = dimsizes(field_1)
  nx = size(2)
  ny = size(1)
  nt = size(0)
  if ( nt .ne. 12 ) then \
    print( " ERROR: SST field must have time dimension 12....")
  end if

  y_eq = ind_nearest_coord(0,lat(:,0),0)
  xs = ind_nearest_coord(115,lon(y_eq,:),0)
  xe = ind_nearest_coord(285,lon(y_eq,:),0)
  y_min = ind_nearest_coord(-1.5,lat(:,0),0)
  y_max = ind_nearest_coord(1.5,lat(:,0),0)
  sub_y = y_max - y_min + 1

  str1 = sprintf("%.1f",abs(lat(y_min,0)))
  str2 = sprintf("%.1f",abs(lat(y_max,0)))
  title_1 = "["+str1+"~S~o~N~S - " + str2 + "~S~o~N~N MEAN]"


  tarea_conform = conform_dims((/ nt, sub_y, nx /), tarea(y_min:y_max,:), (/ 1, 2 /))
  tarea_conform = where(ismissing(field_1(:,y_min:y_max,:)),tarea_conform@_FillValue,tarea_conform)
  subfield = tarea_conform * field_1(:,y_min:y_max,:) ; time * lat * lon
  anom_1 = dim_sum_n_Wrap(subfield,1)
  tarea_anom = dim_sum_n_Wrap(tarea_conform,1)
  anom_1 = anom_1 / tarea_anom
  tarea_conform = conform_dims((/ nt, sub_y, nx /), tarea(y_min:y_max,:), (/ 1, 2 /))
  tarea_conform = where(ismissing(field_2(:,y_min:y_max,:)),tarea_conform@_FillValue,tarea_conform)
  subfield = tarea_conform * field_2(:,y_min:y_max,:) ; time * lat * lon
  anom_2 = dim_sum_n_Wrap(subfield,1)
  tarea_anom = dim_sum_n_Wrap(tarea_conform,1)
  anom_2 = anom_2 / tarea_anom


  mean_1 = dim_avg_n_Wrap(anom_1,0)
  mean_2 = dim_avg_n_Wrap(anom_2,0)

  mean_conform = conform_dims(dimsizes(anom_1),mean_1,1)
  anom_1 = anom_1 - mean_conform
  mean_conform = conform_dims(dimsizes(anom_2),mean_2,1)
  anom_2 = anom_2 - mean_conform

  anom_cyc_1 = new((/nm+2,nx/),double)
  anom_cyc_1(1:nm,:) = anom_1
  anom_cyc_1(0,:) = anom_cyc_1(nm,:)
  anom_cyc_1(nm+1,:) = anom_cyc_1(1,:)
  anom_cyc_2 = new((/nm+2,nx/),double)
  anom_cyc_2(1:nm,:) = anom_2
  anom_cyc_2(0,:) = anom_cyc_2(nm,:)
  anom_cyc_2(nm+1,:) = anom_cyc_2(1,:)

  fileid = addfile(file_SST_obs,"r")
  lon_obs = fileid->x
  lat_obs = fileid->y
  area_wt_obs = fileid->T_area_wt
  TEMP_obs = fileid->T(:,0,:,:)
  y_min = ind_nearest_coord(-1.5,lat_obs,0)
  y_max = ind_nearest_coord(1.5,lat_obs,0)
  sub_y = y_max - y_min + 1
  str1 = sprintf("%3.1f",abs(lat_obs(y_min)))
  str2 = sprintf("%3.1f",abs(lat_obs(y_max)))
  title_2 = "[" + str1 + "~S~o~N~S - " + str2 + "~S~o~N~N MEAN]"
  obs_size = dimsizes(TEMP_obs)

  nx_obs = obs_size(2)
  nt_obs = obs_size(0)

  if ( nt_obs .ne. nm ) then  
    print( " ERROR: R&S SST data set is not monthly-mean .... ")
  end if

  if (.not. isatt(area_wt_obs,"_FillValue")) then
    area_wt_obs@_FillValue = default_fillvalue(typeof(area_wt_obs))
  end if
  area_wt_obs_conform = conform_dims((/ nt_obs, sub_y, nx_obs /), area_wt_obs(y_min:y_max,:), (/ 1, 2 /))
  area_wt_obs_conform = where(ismissing(TEMP_obs(:,y_min:y_max,:)),area_wt_obs_conform@_FillValue,area_wt_obs_conform)
  temp_obs_wgt = TEMP_obs(:,y_min:y_max,:) * area_wt_obs_conform
  anom_obs = dim_sum_n_Wrap(temp_obs_wgt,1)
  area_sum = dim_sum_n_Wrap(area_wt_obs_conform,1)
  anom_obs = anom_obs / area_sum

  mean_obs = dim_avg_n_Wrap(anom_obs,0)
  mean_obs_conform = conform_dims(dimsizes(anom_obs),mean_obs,1)
  anom_obs = anom_obs - mean_obs_conform
  mean_obs!0 = "lon"
  mean_obs&lon = lon_obs

  anom_obs_cyc = new((/nm+2,nx_obs/),double)
  anom_obs_cyc(1:nm,:) = anom_obs
  anom_obs_cyc(0,:) = anom_obs_cyc(nm,:)
  anom_obs_cyc(nm+1,:) = anom_obs_cyc(1,:)

  time = ispan(-5,(nm+1)*10,10) / 10.0
  dmin = -4.0
  dmax =  4.0 
  dlev = (dmax-dmin) / (nlev - 1)
  lev  = dmin + ispan(0,nlev-1,1)*dlev

  coltab = new(nlev + 1,"integer")
  color1 = 2 
  coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
  coltab(0) = 0
  
  print("plotting equatorial pacific seasonal cycle SST")  
  ;wks = gsn_open_wks("x11","EQ_PAC_SST_SEASONAL_CYCLE")
  wks = gsn_open_wks(img_format,"EQ_PAC_SST_SEASONAL_CYCLE")
  gsn_define_colormap(wks,"table42")
  anom_cyc_1!1 = "lon"
  anom_cyc_2!1 = "lon"
  lon1d = lon(y_eq,:)
  lon1d = where(lon1d .ge. 320, lon1d - 360, lon1d)
  anom_cyc_1&lon = lon1d
  anom_cyc_2&lon = lon1d

  res = True
  res@trXMinF = 120
  res@trXMaxF = 280
  res@trYMinF = 22
  res@trYMaxF = 30
  res@vpXF = .168
  res@vpYF = .95
  res@vpHeightF = .305
  res@vpWidthF = .678
  res@tiMainString = "EQ SST MEAN"
  res@tiMainFontHeightF = .012
  res@tmEqualizeXYSizes = True
  res@tmXBLabelFontHeightF = 0.012
  res@tmXBMajorLengthF = 0.012
  res@tmXBMode = "explicit"
  res@tmXBValues = (/ 120, 160, 200, 240, 280 /)
  res@tmXBMinorValues = ispan(130,270,10)
  res@tmXBLabels = (/ "120~S~o~N~E", "160~S~o~N~E", "200~S~o~N~E", "240~S~o~N~E", "280~S~o~N~E" /)

  res@gsnDraw = False
  res@gsnFrame = False
  plot1 = gsn_csm_xy(wks,lon(y_eq,xs:xe),mean_1(xs:xe),res)

  res@xyLineColor = "blue"
  plot_add = gsn_csm_xy(wks,lon(y_eq,xs:xe),mean_2(xs:xe),res)
  overlay(plot1,plot_add)

  res@xyLineColor = "red"
  plot_add2 = gsn_csm_xy(wks,lon_obs,mean_obs,res)
  overlay(plot1,plot_add2)

  text_array = (/ "R&S CLIM " + title_2, \
  case_number + " " + title_1 + " " + time_info, \
  cntrl_number + " " + title_2 + " " + cntrl_time_info/)
  text_x = (/ 125, 125, 125 /)
  text_y = (/ 24, 23.5, 23. /)
  text_res = True
  text_res@txJust = "centerleft"
  text_res@txFontHeightF = 0.012
  text_add = gsn_add_text(wks,plot1,text_array,text_x,text_y,text_res)
  getvalues text_add(0)
  "amViewId" : id
  end getvalues
  setvalues id
  "txFontColor" : "red"
  end setvalues
  getvalues text_add(2)
  "amViewId" : id
  end getvalues
  setvalues id
  "txFontColor" : "blue"
  end setvalues
  draw(plot1)

  delete(res@xyLineColor)
  delete(res@trYMinF)
  delete(res@trYMaxF)

  res@sfYArray = time
  res@trYMinF = 0
  res@trYMaxF = 12
  res@vpHeightF = 1.0
  res@vpWidthF = .36
  res@cnFillOn = True
  res@cnFillMode = "rasterfill"
  res@cnLineLabelPlacementMode = "constant"
  res@cnLineLabelsOn = True
  res@cnLineLabelFontHeightF = 0.02
  res@cnRasterSmoothingOn = True
  res@cnLevelSelectionMode = "explicitLevels"
  res@cnLevels = lev
  res@cnFillColors = coltab
  res@cnInfoLabelOn = False
  res@lbLabelBarOn = False
  res@cnRasterSmoothingOn = True
  res@tiMainString = "SSTA (obs)"
  res@tiMainFontHeightF = .025
  res@tiYAxisString = "MONTH"
  res@tiYAxisFontHeightF = 0.02
  res@tmXBLabelFontHeightF = 0.02
  res@tmXBMajorLengthF = 0.015
  res@tmYLMode = "explicit"
  values = ispan(0,26,1)/2.0
  res@tmYLValues = values(0:24)
  res@tmYLLabels = (/" ", "J", " ",  "F", " ",  "M"," ", \
                     "A"," ",  "M"," ",  "J", " ", "J", " ", \
                     "A", " ", "S", " ",  "O"," ",  "N"," ",  "D", " "/)
  plot2 = gsn_csm_contour(wks,anom_obs_cyc,res)

  delete(res@tiYAxisString)
  if (case_number .eq. cntrl_number) then
    res@tiMainString = time_info
    res@tmYLLabelsOn = False
  else
    res@tiMainString = "("+case_number+")"
    res@tmYLLabelsOn = False
  end if
  plot3 = gsn_csm_contour(wks,anom_cyc_1,res)

  if (case_number .eq. cntrl_number) then
    res@tiMainString = cntrl_time_info
    res@tmYLLabelsOn = False
  else
    res@tiMainString = "("+cntrl_number+")"
    res@tmYLLabelsOn = False
  end if
  plot4 = gsn_csm_contour(wks,anom_cyc_2,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  panel_res@gsnPanelScalePlotIndex = 1
  panel_res@gsnPanelTop = .6

  gsn_panel(wks,(/plot2,plot3, plot4/), (/1,3/),panel_res)

end
