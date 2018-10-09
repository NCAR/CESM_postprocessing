load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"
load "$NCLPATH/curl_pop.ncl"

begin
  seasavgfile_netcdf = getenv("SEASAVGFILE")

  nm      = 12
  nlev    = 21
  missing = 1.0e30

  fileid = addfile(file_netcdf,"r")
  lon = fileid->TLONG
  lat = fileid->TLAT
  tarea = fileid->TAREA

  fileid = addfile(seasavgfile_netcdf,"r")
  field = fileid->TEMP(:,0,:,:)

  size = dimsizes(field)
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

  shift_needed = False
  if ( (resolution .eq. "tx0.1v2") .or. (resolution .eq. "tx0.1v3") )then
    shift_needed = True

    field_orig = field
    lon_orig = lon
    lat_orig = lat
    tarea_orig = tarea

    field(:,:,:(nx-1-xs)) = field_orig(:,:,xs:nx-1)
    field(:,:,(nx-xs):)   = field_orig(:,:,:xs-1)
    lon(:,:(nx-1-xs))   = lon_orig(:,xs:nx-1)
    lon(:,(nx-xs):)     = lon_orig(:,:xs-1)
    lat(:,:(nx-1-xs))   = lat_orig(:,xs:nx-1)
    lat(:,(nx-xs):)     = lat_orig(:,:xs-1)
    tarea(:,:(nx-1-xs)) = tarea_orig(:,xs:nx-1)
    tarea(:,(nx-xs):)   = tarea_orig(:,:xs-1)

    xs = ind_nearest_coord(115,lon(y_eq,:),0)
    xe = ind_nearest_coord(285,lon(y_eq,:),0)
  end if

  str1 = sprintf("%.1f",abs(lat(y_min,0)))
  str2 = sprintf("%.1f",abs(lat(y_max,0)))
  title_1 = "["+str1+"~S~o~N~S - " + str2 + "~S~o~N~N MEAN]"

  sub_y = y_max - y_min + 1
  tarea_conform = conform_dims((/ nt, sub_y, nx /), tarea(y_min:y_max,:), (/ 1, 2 /))
  tarea_conform = where(ismissing(field(:,y_min:y_max,:)),tarea_conform@_FillValue,tarea_conform)
  subfield = tarea_conform * field(:,y_min:y_max,:) ; time * lat * lon
  anom = dim_sum_n_Wrap(subfield,1)
  tarea_anom = dim_sum_n_Wrap(tarea_conform,1)
  anom = anom / tarea_anom
  delete(tarea_conform)
  delete(subfield)

  mean = dim_avg_n_Wrap(anom,0)

  mean_conform = conform_dims(dimsizes(anom),mean,1)
  anom = anom - mean_conform

  anom_cyc = new((/nm+2,nx/),double)
  anom_cyc(1:nm,:) = anom
  anom_cyc(0,:) = anom_cyc(nm,:)
  anom_cyc(nm+1,:) = anom_cyc(1,:)

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
  title_2 = "[" + str1 + "~S~o~N~S - " + str2 + "~S~o~N~N]"
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
  anom_cyc!1 = "lon"
  lon1d = lon(y_eq,:)
  lon1d = where(lon1d .ge. 320, lon1d - 360, lon1d)
  anom_cyc&lon = lon1d

  res = True
  res@trXMinF = 120
  res@trXMaxF = 280
  res@trYMinF = 22
  res@trYMaxF = 30
  res@vpHeightF = .375
  res@vpWidthF = .763
  res@tiMainString = "EQ SST MEAN"
  res@tiMainFontHeightF = .018
  res@tmXBMode = "explicit"
  res@tmXBValues = (/ 120, 160, 200, 240, 280 /)
  res@tmXBMinorValues = ispan(130,270,10)
  res@tmXBLabels = (/ "120~S~o~N~E", "160~S~o~N~E", "200~S~o~N~E", "240~S~o~N~E", "280~S~o~N~E" /)

  res@gsnDraw = False
  res@gsnFrame = False
  plot1 = gsn_csm_xy(wks,lon(y_eq,xs:xe),mean(xs:xe),res)
  res@xyLineColor = "red"
  plot_add = gsn_csm_xy(wks,lon_obs,mean_obs,res)
  overlay(plot1,plot_add)

  text_array = (/ "R&S CLIM " + title_2, case_number + " " + title_1 + " " + time_info /)
  text_x = (/ 125, 125 /)
  text_y = (/ 23.5, 22.8 /)
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


  delete(res@xyLineColor)
  delete(res@trYMinF)
  delete(res@trYMaxF)
  res@sfYArray = time
  res@trYMinF = 0
  res@trYMaxF = 12
  res@vpHeightF = .6
  res@vpWidthF = .35
  res@cnFillOn = True
  res@cnFillMode = "rasterfill"
  res@cnLineLabelPlacementMode = "constant"
  res@cnLineLabelsOn = True
  res@cnLineLabelFontHeightF = 0.012
  res@cnRasterSmoothingOn = True
  res@cnLevelSelectionMode = "explicitLevels"
  res@cnLevels = lev
  res@cnFillColors = coltab
  res@cnInfoLabelOn = False
  res@lbLabelBarOn = False
  res@cnRasterSmoothingOn = True
  res@tiMainString = "ANOMALY (R&S)"
  res@tiMainFontHeightF = .015
  res@tiYAxisString = "MONTH"
  res@tmYLMode = "explicit"
  values = ispan(0,26,1)/2.0
  res@tmYLValues = values(0:24)
  res@tmYLLabels = (/" ", "J", " ",  "F", " ",  "M"," ",   "A"," ",  "M"," ",  "J", " ", \
                     "J", " ", "A", " ", "S", " ",  "O"," ",  "N"," ",  "D", " "/)
  plot2 = gsn_csm_contour(wks,anom_obs_cyc,res)
  res@tiMainString = "ANOMALY ("+case_number+")"
  res@tmYLLabelsOn = False
  delete(res@tiYAxisString)

  if (shift_needed) then
    delete(res@trXMinF)
    delete(res@trXMaxF)
    xs = ind_nearest_coord(120,lon(y_eq,:),0)
    xe = ind_nearest_coord(280,lon(y_eq,:),0)
    plot3 = gsn_csm_contour(wks,anom_cyc(:,xs-1:xe+1),res)
  else
    plot3 = gsn_csm_contour(wks,anom_cyc,res)
  end if

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  panel_res@gsnPanelScalePlotIndex = 1
  panel_res@gsnPanelRowSpec = True
  panel_res@gsnPanelXF = (/0.24,-1,.52/)
  panel_res@gsnPanelYF = (/.9,.55,.55/)
  gsn_panel(wks,(/plot1,plot2,plot3/), (/1,2/),panel_res)

end
