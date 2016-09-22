load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
;load "$NCLPATH/fixed_env.ncl"
load "$NCLPATH/yz_plot.ncl"

begin
  if (isvar("depth")) then
    delete(depth)
  end if
  missing = 1.0e30

  fileid = addfile(file_netcdf,"r")
  lat = fileid->lat_aux_grid
  depth = fileid->moc_z
  depth = depth / 1.0e5	; in km
  moc_components = tostring(fileid->moc_components)

  transport_components = tostring(fileid->transport_components)
  transport_regions = tostring(fileid->transport_regions)
  MOC = fileid->MOC
  MOC&$MOC!3$ = depth
  MOC = where(abs(MOC) .lt. 1.0e-04,0.0, MOC)
  N_HEAT = fileid->N_HEAT
  N_SALT = fileid->N_SALT
  if (isatt(N_SALT,"scale_factor")) then
    N_SALT = N_SALT * N_SALT@scale_factor
  end if 

  ocn_ref_salinity = fileid->ocn_ref_salinity
  sizes = dimsizes(MOC)
  ny = sizes(4)
  nz = sizes(3)
  n_comp = sizes(2)
  n_reg = sizes(1)
  n_trans_comp = dimsizes(N_HEAT(0,0,:,0))

  if ( n_reg .gt. 2 ) then
    print( " Cannot process more than 2 MOC and tracer transport regions .... ")
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

  MOC(0,:n_reg-1,:n_comp-1,:nz-1,0) = MOC@_FillValue
  MOC(0,glo,:,1:,1:ny-2) =  \
    where(MOC(0,glo,:,1:,1:ny-2) .eq. 0 .and. \
    MOC(0,glo,:,1:,2:) .eq. 0 .and. \
    MOC(0,glo,:,:nz-2,2:) .eq. 0 .and. \
    (MOC(0,glo,:,:nz-2,:ny-3) .eq. 0 .or. \
    ismissing(MOC(0,glo,:,:nz-2,:ny-3))), \
    MOC@_FillValue,MOC(0,glo,:,1:,1:ny-2))

  atl_begin = ind_nearest_coord(-33.0,lat,0)
  
  MOC(0,atl,0:n_comp-1,0:nz-1,0:atl_begin-1) = MOC@_FillValue
  MOC(0,atl,:,1:,atl_begin:ny-2) = \
    where(MOC(0,atl,:,1:,atl_begin:ny-2) .eq. 0 .and. \
    MOC(0,atl,:,1:,atl_begin+1:) .eq. 0 .and. \
    MOC(0,atl,:,:nz-2,atl_begin+1:) .eq. 0 .and. \
    (MOC(0,atl,:,:nz-2,atl_begin-1:ny-3) .eq. 0 .or. \
    ismissing(MOC(0,atl,:,:nz-2,atl_begin-1:ny-3))), \
    MOC@_FillValue,MOC(0,atl,:,1:,atl_begin:ny-2))


  nlev =  31 

  coltab = new(nlev + 1,"integer")
  coltab(0) = 1
  color1 = 2 
  coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
  coltab(0) = 0

  dmin = -60.
  dmax =  60.

  dlev = (dmax-dmin)/(nlev-1) 
  lev  = dmin + ispan(0,nlev-1,1)*dlev


  print ("plotting eulerian-mean MOC")
  ;wks = gsn_open_wks("x11","MOC")
  wks = gsn_open_wks(img_format,"MOC")
  gsn_define_colormap(wks,"table42")

  opt = True
  opt@do_panel = True
  opt@tiMainOffsetYF = 0.0
  opt@tiYAxisString = "DEPTH (km)"

  case_info = "EULERIAN-MEAN MOC (GLOBAL) ~C~" + case_number + " " + time_info

  plot1 = yz_plot(wks,MOC(0,glo,em,:,:), lat, depth, case_info, \
  missing, units_moc, dlev, lev, coltab, opt)

  case_info = "EULERIAN-MEAN MOC (ATLANTIC) ~C~" + case_number + " " + time_info

  plot2 = yz_plot(wks,MOC(0,atl,em,:,:), lat, depth, case_info, \
  missing, units_moc, dlev, lev, coltab, opt)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"

  gsn_panel(wks,(/plot1,plot2/),(/2,1/),panel_res)

  if ( n_comp .ge. 2 ) then

    dmin = -30.
    dmax =  30.

    dlev = (dmax-dmin)/(nlev-1) 
    lev  = dmin + ispan(0,nlev-1,1)*dlev

    print ("plotting eddy-induced MOC")
    ;wks = gsn_open_wks("x11","MOC_EI")
    wks = gsn_open_wks(img_format,"MOC_EI")
    gsn_define_colormap(wks,"table42")

    case_info = "EDDY-INDUCED MOC (GLOBAL) ~C~" + case_number + " " + time_info

    plot1 = yz_plot(wks,MOC(0,glo,ei,:,:), lat, depth, case_info, \
    missing, units_moc, dlev, lev, coltab, opt)
    
    case_info = "EDDY-INDUCED MOC (ATLANTIC) ~C~" + case_number + " " + time_info
    
    plot2 = yz_plot(wks,MOC(0,atl,ei,:,:), lat, depth, case_info, \
    missing, units_moc, dlev, lev, coltab, opt)
    
    panel_res = True
    panel_res@gsnMaximize = True
    panel_res@gsnPaperOrientation = "portrait"
    
    gsn_panel(wks,(/plot1,plot2/),(/2,1/),panel_res) 

    dmin = -60.
    dmax =  60.

    dlev = (dmax-dmin)/(nlev-1) 
    lev  = dmin + ispan(0,nlev-1,1)*dlev

    print ("plotting total MOC")
    ;wks = gsn_open_wks("x11","MOC_TOTAL")
    wks = gsn_open_wks(img_format,"MOC_TOTAL")
    gsn_define_colormap(wks,"table42")

    case_info = "TOTAL MOC (GLOBAL) ~C~ " + case_number + " " + time_info

    plot1 = yz_plot(wks,MOC(0,glo,em,:,:)+ MOC(0,glo,ei,:,:), lat, depth, case_info, \
    missing, units_moc, dlev, lev, coltab, opt)
    
    case_info = "TOTAL MOC (ATLANTIC) ~C~" + case_number + " " + time_info
    
    plot2 = yz_plot(wks,MOC(0,atl,em,:,:) + MOC(0,atl,ei,:,:), lat, depth, case_info, \
    missing, units_moc, dlev, lev, coltab, opt)
    
    panel_res = True
    panel_res@gsnMaximize = True
    panel_res@gsnPaperOrientation = "portrait"
    
    gsn_panel(wks,(/plot1,plot2/),(/2,1/),panel_res) 

  end if

  print ("plotting N. heat transport")
  ;wks = gsn_open_wks("x11","HT")
  wks = gsn_open_wks(img_format,"HT")
  gsn_define_colormap(wks,"table42")

  case_info = "N. HEAT TRANSPORT (GLOBAL) " + case_number + " " + time_info

  res = True
  tx_colors =  (/"black","blue", "green", "red"/)
  res@tiMainFontHeightF = 0.022
  res@tiYAxisFontHeightF = 0.02
  res@tiXAxisFontHeightF = 0.02
  res@tiXAxisOffsetYF = -0.03
  res@tiMainString = case_info
  res@tiYAxisString = "PW"
  res@vpHeightF = .5
  res@vpWidthF = .5 * 1.6
  res@gsnMaximize = True
  res@xyLineColors = tx_colors
  res@xyMonoDashPattern = True
  res@xyDashPattern = 0
  res@gsnYRefLine = 0.0
  res@gsnPaperOrientation = "portrait"
  res@trXMinF = -90
  res@trXMaxF = 90
  res@trYMinF = -1.0
  res@trYMaxF = 3.0

  res@gsnDraw = False
  res@gsnFrame = False
  if (n_trans_comp .ge. 4) then
    N_HEAT(0,glo,ttr_diff,:) = N_HEAT(0,glo,ttr_diff,:) - N_HEAT(0,glo,ttr_ei,:)
  end if
  plot1 = gsn_csm_xy(wks,lat,N_HEAT(0,glo,:,:),res)
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
  delete(tx_colors)
  delete(res@xyLineColors)

  case_info = "N. HEAT TRANSPORT (ATLANTIC) " + case_number + " " + time_info
  res@tiMainString = case_info

  if (n_trans_comp .ge. 4) then
    tcomp_vec = (/ ttr_total, ttr_em, ttr_ei /)
    tx_colors = (/ "black", "blue", "red" /)
  else
    tcomp_vec = (/ ttr_total, ttr_em /)
    tx_colors = (/ "black", "blue" /)
  end if
  res@xyLineColors = tx_colors
  res@trYMinF = -.5
  res@trYMaxF = 2.0
  plot2 = gsn_csm_xy(wks,lat(atl_begin:),N_HEAT(0,atl,tcomp_vec,atl_begin:),res)

  gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)


; convert N_SALT to freshwater transport in Sv

  if (isatt(N_SALT,"scale_factor")) then
    N_SALT = tofloat(-(1./(1.0e12*ocn_ref_salinity)) * N_SALT)
  else
    N_SALT = tofloat(-(1000./(1.0e12*ocn_ref_salinity)) * N_SALT)
  end if

  print ("plotting N. freshwater transport")

  ;wks = gsn_open_wks("x11","FWT")
  wks = gsn_open_wks(img_format,"FWT")
  gsn_define_colormap(wks,"table42")

  case_info = "N. FRESHWATER TR. (GLOBAL) " + case_number + " " + time_info

  delete(tx_colors)
  delete(res@xyLineColors)
  res@tiMainString = case_info
  res@tiYAxisString = "Sv"
  tx_colors =  (/"black","blue", "green", "red"/)
  res@xyLineColors = tx_colors
  res@trYMinF = -1.5
  res@trYMaxF = 1.5

  if (n_trans_comp .ge. 4) then
    N_SALT(0,glo,ttr_diff,:) = N_SALT(0,glo,ttr_diff,:) - N_SALT(0,glo,ttr_ei,:)
  end if

  plot1 = gsn_csm_xy(wks,lat,N_SALT(0,glo,:,:),res)
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

  delete(tx_colors)
  delete(res@xyLineColors)

  case_info = "N. FRESHWATER TR. (ATLANTIC) " + case_number + " " + time_info
  res@tiMainString = case_info

  if (n_trans_comp .ge. 4) then
    tcomp_vec = (/ ttr_total, ttr_em, ttr_ei /)
    tx_colors = (/ "black", "blue", "red" /)
  else
    tcomp_vec = (/ ttr_total, ttr_em /)
    tx_colors = (/ "black", "blue" /)
  end if
  res@xyLineColors = tx_colors
  res@trYMinF = -0.5
  res@trYMaxF = 2.0
  plot2 = gsn_csm_xy(wks,lat(atl_begin:),N_SALT(0,atl,tcomp_vec,atl_begin:),res)

  gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)

end
