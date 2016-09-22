load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
;load "$NCLPATH/fixed_env.ncl"
load "$NCLPATH/yz_plot.ncl"

begin
  if (isvar("depth")) then
    delete(depth)
  end if
  missing = 1.0e30

  fileid_1 = addfile(file_netcdf,"r")
  fileid_2 = addfile(cntrl_netcdf,"r")

  lat = fileid_1->lat_aux_grid
  depth = fileid_1->moc_z
  depth = depth / 1.0e5	; in km
  moc_components = tostring(fileid_1->moc_components)
  transport_components = tostring(fileid_1->transport_components)
  transport_regions = tostring(fileid_1->transport_regions)
  ocn_ref_salinity = fileid_1->ocn_ref_salinity

  MOC_1 = fileid_1->MOC
  MOC_1 = where(abs(MOC_1) .lt. 1.0e-04,0.0, MOC_1)
  N_HEAT_1 = fileid_1->N_HEAT
  N_SALT_1 = fileid_1->N_SALT
  if (isatt(N_SALT_1,"scale_factor")) then
    N_SALT_1 = N_SALT_1 * N_SALT_1@scale_factor
  end if 

  MOC_2 = fileid_2->MOC
  MOC_2 = where(abs(MOC_2) .lt. 1.0e-04,0.0, MOC_2)
  N_HEAT_2 = fileid_2->N_HEAT
  N_SALT_2 = fileid_2->N_SALT
  if (isatt(N_SALT_2,"scale_factor")) then
    N_SALT_2 = N_SALT_2 * N_SALT_2@scale_factor
  end if 

  sizes = dimsizes(MOC_1)
  ny = sizes(4)
  nz = sizes(3)
  n_comp = sizes(2)
  n_reg = sizes(1)
  n_trans_comp = dimsizes(N_HEAT_1(0,0,:,0))
  if ( n_reg .gt. 2 ) then
    print( " Cannot process more than 2 MOC and tracer transport regions .... ")
  end if

  sizes2 = dimsizes(MOC_2)
  if (any(sizes2 .ne. sizes) .or. n_trans_comp .ne. dimsizes(N_HEAT_2(0,0,:,0))) then
    print( "error: input files must have identical resolutions .... ")
  end if

  em = 0
  if ( n_comp .ge. 2 ) then
    ei = 1
  else
    ei = 0 
  end if

  ttr_total = 0
  ttr_em    = 1
  ttr_diff  = 2
  max_ttr = ttr_diff
  if ( n_trans_comp .ge. 4 ) then  
    ttr_ei = 3
    max_ttr = ttr_ei
  end if

  glo = 0
  atl = 1

  units_moc = "Sv"

  MOC_1(0,:n_reg-1,:n_comp-1,:nz-1,0) = MOC_1@_FillValue
  MOC_2(0,:n_reg-1,:n_comp-1,:nz-1,0) = MOC_1@_FillValue
  MOC_1(0,glo,:,1:,1:ny-2) = \
    where(MOC_1(0,glo,:,1:,1:ny-2) .eq. 0 .and. \
          MOC_1(0,glo,:,1:,2:) .eq. 0 .and. \
          MOC_1(0,glo,:,:nz-2,2:) .eq. 0 .and. \
          (MOC_1(0,glo,:,:nz-2,:ny-3) .eq. 0 .or. \
          ismissing(MOC_1(0,glo,:,:nz-2,:ny-3))), \
          MOC_1@_FillValue,MOC_1(0,glo,:,1:,1:ny-2))
  MOC_2(0,glo,:,1:,1:ny-2) = \
    where(ismissing(MOC_1(0,glo,:,1:,1:ny-2)),MOC_2@_FillValue,MOC_2(0,glo,:,1:,1:ny-2))

  atl_begin = ind_nearest_coord(-33.0,lat,0)
  
  MOC_1(0,atl,0:n_comp-1,0:nz-1,0:atl_begin-1) = MOC_1@_FillValue
  MOC_2(0,atl,0:n_comp-1,0:nz-1,0:atl_begin-1) = MOC_1@_FillValue

  MOC_1(0,atl,:,1:,atl_begin:ny-2) = \
    where(MOC_1(0,atl,:,1:,atl_begin:ny-2) .eq. 0 .and. \
          MOC_1(0,atl,:,1:,atl_begin+1:) .eq. 0 .and. \
          MOC_1(0,atl,:,:nz-2,atl_begin+1:) .eq. 0 .and. \
          (MOC_1(0,atl,:,:nz-2,atl_begin-1:ny-3) .eq. 0 .or. \
          ismissing(MOC_1(0,atl,:,:nz-2,atl_begin-1:ny-3))), \
          MOC_1@_FillValue,MOC_1(0,atl,:,1:,atl_begin:ny-2))

  MOC_2(0,atl,:,1:,atl_begin:ny-2) = \
    where(ismissing(MOC_1(0,atl,:,1:,atl_begin:ny-2)), \
           MOC_2@_FillValue,MOC_2(0,atl,:,1:,atl_begin:ny-2))

  MOC_diff = MOC_1
  MOC_diff = MOC_1 - MOC_2

  nlev =  31 

  coltab = new(nlev + 1,"integer")
  coltab(0) = 1
  color1 = 2 
  coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
  coltab(0) = 0

  dmin = -60.
  dmax =  60.
  dmin_diff =  -7.5
  dmax_diff =   7.5

  dlev = (dmax-dmin)/(nlev-1) 
  lev  = dmin + ispan(0,nlev-1,1)*dlev
  dlev_diff = (dmax_diff-dmin_diff)/(nlev-1) 
  lev_diff  = dmin_diff + ispan(0,nlev-1,1)*dlev_diff

  print ("plotting eulerian-mean MOC")
  ;wks = gsn_open_wks("x11","MOC")
  wks = gsn_open_wks(img_format,"MOC")
  gsn_define_colormap(wks,"table42")

  case_info = "E-M MOC  " + case_number + " " + time_info
  case_info_diff = case_number+" "+time_info+ " - "+cntrl_number+" "+cntrl_time_info

  opt = True
  opt@do_panel = True
  opt@aspect_ratio = 0.787
  opt@tiMainOffsetYF = -0.01
  opt@tiMainJust = "centerleft"
  opt@tiMainPosition = "left"
  opt@tiYAxisString = "DEPTH (km)"
  opt@pmLabelBarDisplayMode = "never"
  opt@cnInfoLabelOn = False
  opt@cnLineLabelsOn = True
  opt@cnLineLabelPlacementMode  = "constant"
  opt@cnLineLabelFontHeightF = .014
  opt@tmXBLabelFontHeightF = 0.016
  opt@tmXBLabelsOn = False
  opt@plot_label = "GLOBAL"

  plot1 = yz_plot(wks,MOC_1(0,glo,em,:,:), lat, depth, case_info, \
                  missing, units_moc, dlev, lev, coltab, opt)

  case_info = ""
  opt@tiYAxisOn = False
  opt@tmYLLabelsOn = False
  opt@plot_label = "ATLANTIC"
  plot2 = yz_plot(wks,MOC_1(0,atl,em,:,:), lat, depth, case_info, \
                  missing, units_moc, dlev, lev, coltab, opt)

  opt@tiYAxisOn = True
  opt@tmYLLabelsOn = True
  opt@tmXBLabelsOn = True
  opt@plot_label = "GLOBAL"
  plot3 = yz_plot(wks,MOC_diff(0,glo,em,:,:), lat, depth, case_info_diff, \
                  missing, units_moc, dlev_diff, lev_diff, coltab, opt)

  opt@tiYAxisOn = False
  opt@tmYLLabelsOn = False
  opt@plot_label = "ATLANTIC"
  case_info_diff = ""
  plot4 = yz_plot(wks,MOC_diff(0,atl,em,:,:), lat, depth, case_info, \
                  missing, units_moc, dlev_diff, lev_diff, coltab, opt)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  panel_res@gsnPanelScalePlotIndex = 3
  panel_res@gsnPanelYF = (/ .962, .962, .475, .475 /)

  gsn_panel(wks,(/plot1,plot2,plot3,plot4/),(/2,2/),panel_res)

  if ( n_comp .ge. 2 ) then

    dmin = -30.
    dmax =  30.
    dmin_diff =  -7.5
    dmax_diff =   7.5

    dlev = (dmax-dmin)/(nlev-1) 
    lev  = dmin + ispan(0,nlev-1,1)*dlev
    dlev_diff = (dmax_diff-dmin_diff)/(nlev-1) 
    lev_diff  = dmin_diff + ispan(0,nlev-1,1)*dlev_diff

    print ("plotting eddy-induced MOC")
    ;wks = gsn_open_wks("x11","MOC_EI")
    wks = gsn_open_wks(img_format,"MOC_EI")
    gsn_define_colormap(wks,"table42")

    case_info = "E-I MOC" + case_number + " " + time_info

    opt@tiYAxisOn = True
    opt@tmYLLabelsOn = True
    opt@tmXBLabelsOn = False
    opt@tiMainPosition = "left"
    opt@plot_label = "GLOBAL"
    plot1 = yz_plot(wks,MOC_1(0,glo,ei,:,:), lat, depth, case_info, \
                    missing, units_moc, dlev, lev, coltab, opt)
    
    case_info = ""

    opt@tiYAxisOn = False
    opt@tmYLLabelsOn = False
    opt@plot_label = "ATLANTIC"
    plot2 = yz_plot(wks,MOC_1(0,atl,ei,:,:), lat, depth, case_info, \
                    missing, units_moc, dlev, lev, coltab, opt)

    case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info

    opt@tiYAxisOn = True
    opt@tmYLLabelsOn = True
    opt@tmXBLabelsOn = True
    opt@plot_label = "GLOBAL"
    plot3 = yz_plot(wks,MOC_diff(0,glo,ei,:,:), lat, depth, case_info_diff, \
                    missing, units_moc, dlev_diff, lev_diff, coltab, opt)
    
    case_info = ""
    
    opt@tiYAxisOn = False
    opt@tmYLLabelsOn = False
    opt@plot_label = "ATLANTIC"
    plot4 = yz_plot(wks,MOC_diff(0,atl,ei,:,:), lat, depth, case_info, \
                    missing, units_moc, dlev_diff, lev_diff, coltab, opt)
    
    panel_res = True
    panel_res@gsnMaximize = True
    panel_res@gsnPaperOrientation = "portrait"
    
    gsn_panel(wks,(/plot1,plot2,plot3,plot4/),(/2,2/),panel_res)

    dmin = -60.
    dmax =  60.
    dmin_diff =  -7.5
    dmax_diff =   7.5

    dlev = (dmax-dmin)/(nlev-1) 
    lev  = dmin + ispan(0,nlev-1,1)*dlev
    dlev_diff = (dmax_diff-dmin_diff)/(nlev-1) 
    lev_diff  = dmin_diff + ispan(0,nlev-1,1)*dlev_diff

    print ("plotting total MOC")
    ;wks = gsn_open_wks("x11","MOC_TOTAL")
    wks = gsn_open_wks(img_format,"MOC_TOTAL")
    gsn_define_colormap(wks,"table42")

    case_info = "TOTAL MOC " + case_number + " " + time_info

    opt@tiYAxisOn = True
    opt@tmYLLabelsOn = True
    opt@tmYLLabelFontHeightF = 0.016
    opt@tmXBLabelsOn = False
    opt@plot_label = "GLOBAL"
    plot1 = yz_plot(wks,MOC_1(0,glo,em,:,:)+ MOC_1(0,glo,ei,:,:), lat, depth, case_info, \
                    missing, units_moc, dlev, lev, coltab, opt)
    
    case_info = ""
    opt@tiYAxisOn = False
    opt@tmYLLabelsOn = False
    opt@plot_label = "ATLANTIC"
    plot2 = yz_plot(wks,MOC_1(0,atl,em,:,:) + MOC_1(0,atl,ei,:,:), lat, depth, case_info, \
                    missing, units_moc, dlev, lev, coltab, opt)

    case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info

    opt@tiYAxisOn = True
    opt@tmYLLabelsOn = True
    opt@tmXBLabelsOn = True
    opt@plot_label = "GLOBAL"
    plot3 = yz_plot(wks,MOC_diff(0,glo,em,:,:) + MOC_diff(0,glo,ei,:,:), lat, depth, case_info_diff, \
                    missing, units_moc, dlev_diff, lev_diff, coltab, opt)
    
    case_info = ""
    
    opt@tiYAxisOn = False
    opt@tmYLLabelsOn = False
    opt@plot_label = "ATLANTIC"
    plot4 = yz_plot(wks,MOC_diff(0,atl,em,:,:) + MOC_diff(0,atl,ei,:,:), lat, depth, case_info, \
                    missing, units_moc, dlev_diff, lev_diff, coltab, opt)
    
    panel_res = True
    panel_res@gsnMaximize = True
    panel_res@gsnPaperOrientation = "portrait"
    
    gsn_panel(wks,(/plot1,plot2,plot3,plot4/),(/2,2/),panel_res)

  end if

  print ("plotting N. heat transport")
  ;wks = gsn_open_wks("x11","HT")
  wks = gsn_open_wks(img_format,"HT")
  gsn_define_colormap(wks,"table42")

  case_info = "N. HEAT TRANSPORT (GLOBAL) " + case_number 
  if (case_number .ne. cntrl_number) then
      case_info = case_info + " " + time_info
  end if
  res = True
  tx_colors =  (/"black","blue", "green", "red"/)
  res@tiMainFontHeightF = 0.022
  res@tiYAxisFontHeightF = 0.02
  res@tiXAxisFontHeightF = 0.02
  res@tiMainString = case_info
  res@tiYAxisString = "PW"
  res@vpHeightF = .5
  res@vpWidthF = .5 * 1.6
  res@xyLineColors = tx_colors
  res@xyMonoDashPattern = False
  res@xyDashPatterns = (/ 0, 0, 0, 0, 2, 2, 2, 2 /)
  res@gsnYRefLine = 0.0
  res@gsnPaperOrientation = "portrait"
  res@trXMinF = -90
  res@trXMaxF = 90
  res@trYMinF = -1.0
  res@trYMaxF = 3.0

  res@gsnDraw = False
  res@gsnFrame = False

  if (n_trans_comp .ge. 4) then
    N_HEAT_1(0,glo,ttr_diff,:) = N_HEAT_1(0,glo,ttr_diff,:) - N_HEAT_1(0,glo,ttr_ei,:)
    N_HEAT_2(0,glo,ttr_diff,:) = N_HEAT_2(0,glo,ttr_diff,:) - N_HEAT_2(0,glo,ttr_ei,:)
    data = new((/8,ny/),typeof(N_HEAT_1))
    data(0:3,:) = N_HEAT_1(0,glo,:3,:)
    data(4:,:) = N_HEAT_2(0,glo,:3,:)
  else
    data = new((/6,ny/),typeof(N_HEAT_1))
    data(0:2,:) = N_HEAT_1(0,glo,:2,:)
    data(3:,:) = N_HEAT_2(0,glo,:2,:)
  end if

  plot1 = gsn_csm_xy(wks,lat,data,res)
  getvalues plot1
  "trYMinF" : y_min
  "trYMaxF" : y_max
  end getvalues
  yspace = (y_max - y_min) / 15.0 
  text_array = (/ "TOTAL","EULERIAN-MEAN", "ISOP. DIFF.","EDDY-INDUCED"/)
  if (n_trans_comp .lt. 4) then
    text_array(2) = "ISOP. DIFF.+EI"
  end if
  text_x = (/ -75., -75., -75, -75 /)
  text_y = y_max - (/ yspace, 2 * yspace, 3 * yspace, 4 * yspace /)
  text_res = True
  text_res@txJust = "centerleft"
  text_res@txFontHeightF = 0.02
  text_add = gsn_add_text(wks,plot1,text_array,text_x,text_y,text_res)

  do i = 0, dimsizes(text_add) - 1
    getvalues text_add(i)
    "amViewId" : id
    end getvalues
    setvalues id
    "txFontColor" : tx_colors(i)
    end setvalues
  end do
  delete([/tx_colors,data/])
  delete(res@xyLineColors)

  case_info = "N. HEAT TRANSPORT (ATLANTIC) " + case_number
  if (case_number .ne. cntrl_number) then
      case_info = case_info + " " + time_info
  end if

  res@tiMainString = case_info

  if (n_trans_comp .ge. 4) then
    tcomp_vec = (/ ttr_total, ttr_em, ttr_ei /)
    tx_colors = (/ "black", "blue", "red" /)
    data = new((/6, ny-atl_begin/),typeof(N_HEAT_1))
    data(0:2,:) = N_HEAT_1(0,atl,tcomp_vec,atl_begin:)
    data(3:,:) = N_HEAT_2(0,atl,tcomp_vec,atl_begin:)
  else
    tcomp_vec = (/ ttr_total, ttr_em /)
    tx_colors = (/ "black", "blue" /)
    data = new((/4,ny/),typeof(N_HEAT_1))
    data(0:1:) = N_HEAT_1(0,atl,tcomp_vec,atl_begin:)
    data(2:,:) = N_HEAT_2(0,atl,tcomp_vec,atl_begin:)
  end if

  res@xyLineColors = tx_colors
  res@trYMinF = -.5
  res@trYMaxF = 2.0
  res@tiXAxisOn = True
  if (case_number .ne. cntrl_number) then
    res@tiXAxisString = "" + case_number + " (solid) " + cntrl_number + " (dotted)"
  else
    res@tiXAxisString = "" + time_info + " (solid) " + cntrl_time_info + " (dotted)"
  end if
  plot2 = gsn_csm_xy(wks,lat(atl_begin:),data,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPanelScalePlotIndex = 1
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

; convert N_SALT to freshwater transport in Sv

  if (isatt(N_SALT_1,"scale_factor")) then
    N_SALT_1 = tofloat(-(1./(1.0e12*ocn_ref_salinity)) * N_SALT_1)
    N_SALT_2 = tofloat(-(1./(1.0e12*ocn_ref_salinity)) * N_SALT_2)
  else
    N_SALT_1 = tofloat(-(1000./(1.0e12*ocn_ref_salinity)) * N_SALT_1)
    N_SALT_2 = tofloat(-(1000./(1.0e12*ocn_ref_salinity)) * N_SALT_2)
  end if

  print ("plotting N. freshwater transport")
  ;wks = gsn_open_wks("x11","FWT")
  wks = gsn_open_wks(img_format,"FWT")
  gsn_define_colormap(wks,"table42")

  case_info = "N. FRESHWATER TR. (GLOBAL) " + case_number
  if (case_number .ne. cntrl_number) then
      case_info = case_info + " " + time_info
  end if


  delete([/tx_colors,data/])
  delete(res@xyLineColors)
  res@tiMainString = case_info
  res@tiYAxisString = "Sv"
  res@tiXAxisOn = False
  tx_colors =  (/"black","blue", "green", "red"/)
  res@xyLineColors = tx_colors
  res@trYMinF = -1.5
  res@trYMaxF = 1.5

  if (n_trans_comp .ge. 4) then
    N_SALT_1(0,glo,ttr_diff,:) = N_SALT_1(0,glo,ttr_diff,:) - N_SALT_1(0,glo,ttr_ei,:)
    N_SALT_2(0,glo,ttr_diff,:) = N_SALT_2(0,glo,ttr_diff,:) - N_SALT_2(0,glo,ttr_ei,:)
    data = new((/8,ny/),typeof(N_SALT_1))
    data(0:3,:) = N_SALT_1(0,glo,:3,:)
    data(4:,:) = N_SALT_2(0,glo,:3,:)
  else
    data = new((/6,ny/),typeof(N_SALT_1))
    data(0:2,:) = N_SALT_1(0,glo,:2,:)
    data(3:,:) = N_SALT_2(0,glo,:2,:)
  end if

  plot1 = gsn_csm_xy(wks,lat,data,res)
  getvalues plot1
  "trYMinF" : y_min
  "trYMaxF" : y_max
  end getvalues
  yspace = (y_max - y_min) / 18.0 
  text_array = (/ "TOTAL","EULERIAN-MEAN", "ISOP. DIFF.","EDDY-INDUCED"/)
  if (n_trans_comp .lt. 4) then
    text_array(2) = "ISOP. DIFF.+EI"
  end if
  text_x = (/ -75., -75., -75, -75 /)
  text_y = y_min + (/ 4 * yspace, 3 * yspace, 2 * yspace, yspace /)
  text_res = True
  text_res@txJust = "centerleft"
  text_res@txFontHeightF = 0.018
  text_add = gsn_add_text(wks,plot1,text_array,text_x,text_y,text_res)
;print(text_add)
  do i = 0, dimsizes(text_add) - 1
    getvalues text_add(i)
    "amViewId" : id
    end getvalues
    setvalues id
    "txFontColor" : tx_colors(i)
    end setvalues
  end do

  delete([/tx_colors,data/])
  delete(res@xyLineColors)

  case_info = "N. FRESHWATER TR. (ATLANTIC) " + case_number
  if (case_number .ne. cntrl_number) then
      case_info = case_info + " " + time_info
  end if
  res@tiMainString = case_info

  if (n_trans_comp .ge. 4) then
    tcomp_vec = (/ ttr_total, ttr_em, ttr_ei /)
    tx_colors = (/ "black", "blue", "red" /)
    data = new((/6, ny-atl_begin/),typeof(N_SALT_1))
    data(0:2,:) = N_SALT_1(0,atl,tcomp_vec,atl_begin:)
    data(3:,:) = N_SALT_2(0,atl,tcomp_vec,atl_begin:)
  else
    tcomp_vec = (/ ttr_total, ttr_em /)
    tx_colors = (/ "black", "blue" /)
    data = new((/4,ny/),typeof(N_SALT_1))
    data(0:1:) = N_SALT_1(0,atl,tcomp_vec,atl_begin:)
    data(2:,:) = N_SALT_2(0,atl,tcomp_vec,atl_begin:)
  end if

  res@xyLineColors = tx_colors
  res@trYMinF = -0.5
  res@trYMaxF = 2.0
  res@tiXAxisOn = True
  plot2 = gsn_csm_xy(wks,lat(atl_begin:),data,res)

  panel_res@gsnPanelScalePlotIndex = 1
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

end
