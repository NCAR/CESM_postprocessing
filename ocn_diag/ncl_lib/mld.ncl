load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin
  file_obs    = getenv("RHOOBSFILE")
  file_netcdf = getenv("SEASAVGRHO")
  file_tavg   = getenv("TAVGFILE")

  print("mld file_obs = " + file_obs)
  print("mld file_netcdf = " + file_netcdf)
  print("mld file_tavg = " + file_tavg)

  winter_plot = 1 

; in sigma units
  pd_offset = (/ 0.125d, 0.03d /)

  noff = dimsizes(pd_offset)

  ns_max = 1 

  missing_value = default_fillvalue("double")
  nc = 2

  fileid = addfile(file_tavg,"r")

  ocn_comp = getenv("OCN_COMP")
  if (ocn_comp.eq."MOM") then
    gridInfoFilePath = getenv("DIAGOBSROOT")+"/omwg/za_grids/"+getenv("RESOLUTION")+"_grid_info.nc"
    gridInfoFile = addfile(gridInfoFilePath,"r")
    kmt = gridInfoFile->KMT
    region_mask = kmt ; TODO: fix_this !!!
    tarea = gridInfoFile->TAREA
    ht = gridInfoFile->HT
  else ; POP
    kmt = fileid->KMT
    region_mask = fileid->REGION_MASK
    tarea = fileid->TAREA
    ht = fileid->HT
  end if

  fileid = addfile(file_netcdf,"r")
  field = fileid->PD

  n=0

  tlon = fileid->TLONG
  tlon = where(tlon .le. 30, tlon + 360, tlon)

  tlat = fileid->TLAT
  if (isvar("depth")) then
    delete(depth)
  end if
  depth = fileid->z_t
  time = fileid->time

; convert depth and HT to m from cm
  if (ocn_comp.eq."POP") then
    depth = depth * 0.01
    ht    = ht    * 0.01
    tarea = tarea * 1.0e-4
  end if

  size = dimsizes(field)
  nx = size(3)
  ny = size(2)
  nz = size(1)
  nt = size(0)
;;  field@_FillValue = missing_value
  field@_FillValue = default_fillvalue(typeof(field))
  field = where(field .eq. field@missing_value,field@_FillValue,field)
  PD = new((/nz,ny,nx/),double)

  MLD = new((/2,nc,nt,ny,nx/),double)

  do n=0,nt-1
    PD(:,:,:) = field(n,:,:,:)
      do off = 0, noff - 1
        MLD(off,0,n,:,:) = mixed_layer_depth(PD,kmt,ht,depth,pd_offset(off))
      end do
      MLD@long_name = "mixed layer depth"
  end do

  delete(field)
  delete(PD)

  fileid = addfile(file_obs,"r")
  if (isfilevar(fileid,"PD")) then
    field = fileid->PD
  else
    field = fileid->POTENTIAL_DENSITY
  end if
  field@missing_value = 0.
  if (.not.isatt(field,"_FillValue")) then
    field@_FillValue = default_fillvalue("float")
  end if
  field = where(field .eq. field@missing_value,field@_FillValue,field)
  PD = new((/nz,ny,nx/),double)

  do n=0,nt-1
    PD(:,:,:) = (/field(n,:,:,:)/)
    do off = 0, noff - 1
      MLD(off,1,n,:,:) = mixed_layer_depth(PD,kmt,ht,depth,pd_offset(off))
    end do
  end do

  delete(field)
  delete(PD)

  lev_0 = (/ 0., 25., 50., 75., 100., 150., 200., 250., 500., 1000., 2000. /)
  lev_mod = (/ 0., 25., 50., 75., 100., 150., 200., 250., 500., 1000., 2000. /)

  coltab_l =   5. + (122./5.)*ispan(0,4,1) 
  coltab_h = 145. + (110./5.)*ispan(0,5,1)
  coltab_0 = new(dimsizes(lev_0) + 1,integer)
  coltab_0(1:) = tointeger(array_append_record( coltab_l, coltab_h,0))
  coltab_0(0) = 0

  lev_1 = (/ -1000., -500., -200., -100., -80., -60., -40., \
  -20.,  -10.,    0.,   10.,   20.,  40.,  60.,  80., \
  100.,  200.,  500., 1000. /)
  delete([/coltab_l,coltab_h/])
  coltab_l =   5. + (122./8.)*ispan(0,8,1)
  coltab_h = 145. + (110./8.)*ispan(0,8,1)

  tmp = array_append_record( tofloat(coltab_l), (/14.,14./),0)
  coltab_1 = tointeger(array_append_record( tmp, coltab_h,0))
  delete(tmp)

  lev_2 = (/ -1000., -500., -400., -300., -200.,-150.,-100., \
  -50.,  -20.,    0.,   20.,   50.,  100., 150., 200., \ 
  300.,  400.,  500.,  1000. /)
  delete([/coltab_l,coltab_h/])

  coltab_l =   5. + (122./8.)*ispan(0,7,1)
  coltab_h = 145. + (110./8.)*ispan(0,8,1)
  coltab_2 = new(dimsizes(lev_2) + 1,integer)
  tmp = array_append_record( coltab_l, (/14.,14./),0)
  coltab_2(1:) = tointeger(array_append_record( tmp, coltab_h,0))
  coltab_2(0) = 0
  delete(tmp)

  do off = 0, noff - 1

    opt = False
    MLD(off,:,:,:,:) = wgt_area_smooth(MLD(off,:,:,:,:),tarea,opt)

    MLD_mean = new((/nc,ny,nx/),double)
    MLD_nw_mean = new((/nc,ny,nx/),double)
    MLD_sw_mean = new((/nc,ny,nx/),double)
    MLD_winter_mean = new((/nc,ny,nx/),double)
    do m = 0,nc-1
      MLD_mean(m,:,:) = dim_avg_n_Wrap(MLD(off,m,:,:,:),0)
      MLD_nw_mean(m,:,:) = dim_avg_n_Wrap(MLD(off,m,0:2,:,:),0)
      MLD_sw_mean(m,:,:) = dim_avg_n_Wrap(MLD(off,m,6:8,:,:),0)
    end do
    tlat_c = conform(MLD_winter_mean,tlat,(/1,2/))
    MLD_winter_mean = where(tlat_c .ge. 0, MLD_nw_mean,MLD_sw_mean)

    MLD_mean_diff = MLD_mean(0,:,:) - MLD_mean(1,:,:)
    MLD_winter_mean_diff = MLD_winter_mean(0,:,:) - MLD_winter_mean(1,:,:)

    mean_diff = wgt_areaave2(MLD_mean_diff,tarea,0)
    mean_rms = sqrt(sum(MLD_mean_diff * MLD_mean_diff * tarea) / sum(tarea))
    mean_rms = wgt_arearmse2(MLD_mean(0,:,:),MLD_mean(1,:,:),tarea,0)

    winter_mean_diff = wgt_areaave2(MLD_winter_mean_diff,tarea,0)
    winter_mean_rms = sqrt(sum(MLD_winter_mean_diff * MLD_winter_mean_diff * tarea) / sum(tarea))
    winter_mean_rms = wgt_arearmse2(MLD_winter_mean(0,:,:),MLD_winter_mean(1,:,:),tarea,0)

    fname = "mld" + (off + 1)

    print("plotting mixed layer depth at " + pd_offset(off))
    ;wks = gsn_open_wks("x11",fname)
    wks = gsn_open_wks(img_format,fname)
    gsn_define_colormap(wks,"table42")

    opt = True
    opt@aspect_ratio = 1.25
    opt@charsize = 0.9
    opt@landcolor = lndcolor
    opt@contourline = 2
    opt@xrange = (/ xr0,xr1/)
    opt@yrange = (/ yr0,yr1/)
    opt@do_panel = True
    opt@nomean = True
    opt@cnInfoLabelOn = False
    opt@tmXBLabelFontHeightF = .02
    opt@lbLabelBarOn = False
    opt@gsnLeftStringFontHeightF = .02
    opt@gsnRightStringFontHeightF = .02
    opt@gsnMajorLonSpacing = 60
    opt@gsnMajorLatSpacing = 45
    units = "sigma"
    case_info = "OBS MEAN"
    opt@gsnRightString = "" + pd_offset(off)

    opt@cnLabelBarEndStyle = "ExcludeOuterBoxes"

    missing = MLD@_FillValue
    dlev = dimsizes(lev_0)

    plot1 = contour_plot(wks, MLD_mean(1,:,:), tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev, lev_0, coltab_0, opt)

    opt@lbLabelBarOn = False
    opt@tmYLLabelsOn = False
    case_info = "OBS WINTER MEAN "
    plot2 = contour_plot(wks, MLD_winter_mean(1,:,:), tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev, lev_0, coltab_0, opt)

    opt@tmYLLabelsOn = True
    opt@tmXBLabelsOn = False
    delete(opt@gsnRightString)

    case_info = "MEAN " + case_number + " " + time_info 
    plot3 = contour_plot(wks, MLD_mean(0,:,:), tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev, lev_0, coltab_0, opt)

    opt@tmYLLabelsOn = False
    opt@lbLabelBarOn = False

    case_info = "WINTER MEAN " + case_number + " " + time_info 
    plot4 = contour_plot(wks, MLD_winter_mean(0,:,:), tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev, lev_0, coltab_0, opt)

    panel_res = True
    panel_res@gsnPanelLabelBar = True
    panel_res@lbAutoManage = False
    panel_res@lbLabelAutoStride = True
    panel_res@pmLabelBarHeightF = .06
    panel_res@pmLabelBarWidthF = .62
    panel_res@lbLabelFontHeightF = 0.012
    panel_res@gsnMaximize = True
    panel_res@gsnPanelYWhiteSpacePercent = 1
    panel_res@gsnPanelScalePlotIndex = 1
    panel_res@gsnPanelTop = 1.
    panel_res@gsnPanelBottom = .385
    panel_res@gsnFrame = False

    gsn_panel(wks,(/plot1,plot2,plot3,plot4/), (/2,2/),panel_res)

    opt@tmYLLabelsOn = True
    opt@tmXBLabelsOn = True

;;    case_info =  case_number + "- OBS MEAN"
    case_info = "OBS MEAN"
    plot5 = contour_plot(wks, MLD_mean_diff(:,:), tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev, lev_1, coltab_2, opt)

    mean_diff = decimalPlaces(mean_diff,2,True)
    mean_rms = decimalPlaces(mean_rms,2,True)
    winter_mean_diff = decimalPlaces(winter_mean_diff,2,True)
    winter_mean_rms = decimalPlaces(winter_mean_rms,2,True)

    text_array = (/ "mean = " + mean_diff , "rms = " + mean_rms /)

    text_x = (/ 40, 40 /)
    text_y = (/ 65, 55 /)
    text_res = True
    text_res@txJust = "centerleft"
    text_res@txFontHeightF = 0.02
    text_add = gsn_add_text(wks,plot5,text_array,text_x,text_y,text_res)

    opt@tmYLLabelsOn = False
    opt@lbLabelBarOn = False
;;    case_info =  case_number + "- WINTER OBS MEAN"
    case_info = "WINTER OBS MEAN"
    plot6 = contour_plot(wks, MLD_winter_mean_diff(:,:), tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev, lev_1, coltab_2, opt)

    text_array = (/ "mean = " + winter_mean_diff , "rms = " + winter_mean_rms /)
    text_x = (/ 40, 40 /)
    text_y = (/ 65, 55 /)
    text_res = True
    text_res@txJust = "centerleft"
    text_res@txFontHeightF = 0.02
    text_add = gsn_add_text(wks,plot6,text_array,text_x,text_y,text_res)

    panel_res@txString = case_number
    panel_res@txFontHeightF = 0.012
    panel_res@gsnPanelBottom = 0.01
    panel_res@gsnFrame = True
    panel_res@gsnPanelTop = .385
    panel_res@gsnPanelScalePlotIndex = 1
    panel_res@gsnPanelXWhiteSpacePercent = 1
    panel_res@pmLabelBarWidthF = .62

    gsn_panel(wks,(/plot5,plot6/), (/1,2/),panel_res)

  end do

end
