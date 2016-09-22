load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/contour_plot.ncl"
load "$NCLPATH/curl_pop.ncl"

begin

  fileid_1     = addfile(file_netcdf,"r")
  fileid_2     = addfile(cntrl_netcdf,"r")

  if (isfilevar(fileid_1,"QFLUX")) then

  field_name  = (/ "SHF",     "SHF_TOTAL",  "SHF_QSW", "MELTH_F", \
                   "SENH_F",  "LWUP_F",     "LWDN_F",  "EVAP_F",  \
                   "SFWF",    "SFWF_TOTAL", "PREC_F",  "MELT_F",  \
                   "ROFF_F",  "SALT_F", "TAUX", "TAUY", "CURL",  \
                   "QFLUX",   "SNOW_F" /)

  else
   
  field_name  = (/ "SHF", "SFWF", "TAUX", "TAUY", "CURL" /)

  end if

  n_fields = dimsizes(field_name)
  print( " the number of fields to be processed is " + n_fields)

  missing = default_fillvalue("float")

  days_in_norm_year = fileid_1->days_in_norm_year
  sflux_factor = fileid_1->sflux_factor
  salinity_factor = fileid_1->salinity_factor
  rho_sw = fileid_1->rho_sw * 1000.0
  l_f = fileid_1->latent_heat_fusion / 1e4
  tlat = fileid_1->TLAT
  tlon = fileid_1->TLONG
  sizes = dimsizes(tlon)
  nx = sizes(1)
  ny = sizes(0)
  dxu = fileid_1->DXU
  dyu = fileid_1->DYU
  kmt = fileid_1->KMT
  kmu = fileid_1->KMU
  region_mask = fileid_1->REGION_MASK
  tarea = fileid_1->TAREA
  uarea = fileid_1->UAREA
  angle = fileid_1->ANGLE

  sizes = getfilevardimsizes(fileid_2,"TLONG") 
  if (.not. (sizes(0) .eq. ny .and. sizes(1) .eq. nx)) then
    print("error: input files must have the same resolution")
  end if
  do n = 0, n_fields-1

    contourline = 3
    if (field_name(n) .eq. "CURL") then
      taux = fileid_1->TAUX(0,:,:)
      tauy = fileid_1->TAUY(0,:,:)
      taux = tofloat(taux * cos(angle) + tauy * sin(-angle))
      taux = where(abs(taux) .gt. 1.0e10,taux@_FillValue, taux)
      tauy = tofloat(tauy * cos(angle) - taux * sin(-angle))
      tauy = where(abs(tauy) .gt. 1.0e10,tauy@_FillValue, tauy)
      k = 1
      field_1 = curl_pop(k, taux, tauy, dxu, dyu, tarea, kmt, missing)
      field_1 = field_1/1.0e-8
      delete([/taux,tauy/])

      taux = fileid_2->TAUX(0,:,:)
      tauy = fileid_2->TAUY(0,:,:)
      taux = tofloat(taux * cos(angle) + tauy * sin(-angle))
      taux = where(abs(taux) .gt. 1.0e10,taux@_FillValue, taux)
      tauy = tofloat(tauy * cos(angle) - taux * sin(-angle))
      tauy = where(abs(tauy) .gt. 1.0e10,tauy@_FillValue, tauy)
      k = 1
      field_2 = curl_pop(k, taux, tauy, dxu, dyu, tarea, kmt, missing)
      field_2 = field_2/1.0e-8
      delete([/taux,tauy/])

    else if (field_name(n) .eq. "SHF_TOTAL" ) then 
      field_temp = fileid_1->QFLUX
      field_temp2 = fileid_1->SHF
      field_1 = field_temp + field_temp2
      field_temp = fileid_2->QFLUX
      field_temp2 = fileid_2->SHF
      field_2 = field_temp + field_temp2
    else if ( field_name(n) .eq. "SFWF_TOTAL" ) then 
      field_temp = fileid_1->QFLUX
      field_temp2 = fileid_1->SFWF
      field_1 = -field_temp/l_f + field_temp2
      field_temp = fileid_2->QFLUX
      field_temp2 = fileid_2->SFWF
      field_2 = -field_temp/l_f + field_temp2
    else
      field_1 = fileid_1->$field_name(n)$
      field_2 = fileid_2->$field_name(n)$
    end if
    end if
    end if

    if (iscoord(field_1,"ULONG")) then
      ugrid = True
    else
      ugrid = False
    end if

    if (isatt(field_1,"units")) then
      units = field_1@units
    else
      units = ""
    end if
 
    area = tarea

    if ( field_name(n) .eq. "TAUX" ) then 
      area = uarea
      tmp_field = fileid_1->TAUY
      field_1(0,:,:) = tofloat(field_1(0,:,:) * cos(angle) + tmp_field(0,:,:) * sin(-angle))
      field_1 = where(abs(field_1) .gt. 1.0e10, field_1@_FillValue, field_1)
      delete(tmp_field)

      tmp_field = fileid_2->TAUY
      field_2(0,:,:) = tofloat(field_2(0,:,:) * cos(angle) + tmp_field(0,:,:) * sin(-angle))
      field_2 = where(abs(field_2) .gt. 1.0e10, field_2@_FillValue, field_2)
      delete(tmp_field)
    else if (field_name(n) .eq. "TAUY" ) then
      area = uarea
      tmp_field = fileid_1->TAUX
      field_1(0,:,:) = tofloat(field_1(0,:,:) * cos(angle) + tmp_field(0,:,:) * sin(-angle))
      field_1 = where(abs(field_1) .gt. 1.0e10, field_1@_FillValue, field_1)
      delete(tmp_field)

      tmp_field = fileid_2->TAUX
      field_2(0,:,:) = tofloat(field_2(0,:,:) * cos(angle) + tmp_field(0,:,:) * sin(-angle))
      field_2 = where(abs(field_2) .gt. 1.0e10, field_2@_FillValue, field_2)
      delete(tmp_field)
    end if
  end if

  dmin = missing 
  dmax = missing 
  dmin_diff = missing
  dmax_diff = missing

  contourline = 2
  units = ""
  if ( field_name(n) .eq. "CURL" ) then
    dmin  = -40.0
    dmax  =  40.0 
    dmin_diff = -10.0
    dmax_diff =  10.0
    units     = "x10~S~-5~N~ Kg m~S~-2~N~ s~S~-1~N~"
    contourline = 2
  end if

  if ( field_name(n) .eq. "SHF" ) then
    dmin  = -200.0
    dmax  =  200.0 
    dmin_diff = -100.0
    dmax_diff =  100.0
    units = " W m~S~-2~N~" 
    contourline = 1
  end if

  if ( field_name(n) .eq. "SHF_TOTAL" ) then
    dmin      = -200.0
    dmax      =  200.0
    dmin_diff = -100.0
    dmax_diff =  100.0
    units = " W m~S~-2~N~" 
    contourline = 1
  end if

  if ( field_name(n) .eq. "SENH_F" ) then
    dmin      = -100.0
    dmax      =  40.0
    dmin_diff =  -50.0
    dmax_diff =   50.0
    units = " W m~S~-2~N~" 
  end if

  if ( field_name(n) .eq. "SHF_QSW" ) then
    dmin      =   0.0
    dmax      = 400.0 
    dmin_diff = -50.0
    dmax_diff =  50.0
    units = " W m~S~-2~N~" 
    contourline = 3
  end if

  if ( field_name(n) .eq. "LWUP_F" ) then
    dmin      = -600.0
    dmax      =    0.0
    dmin_diff = -100.0
    dmax_diff =  100.0
    units = " W m~S~-2~N~" 
    contourline = 3
  end if

  if ( field_name(n) .eq. "LWDN_F" ) then
    dmin      =    0.0
    dmax      =  500.0
    dmin_diff = -100.0
    dmax_diff =  100.0
    contourline = 3
    units = " W m~S~-2~N~" 
  end if

  if ( field_name(n) .eq. "MELTH_F" ) then
    dmin      = -50.0
    dmax      =   0.0
    dmin_diff =  -50.0
    dmax_diff =   50.0
    contourline = 2
    units = " W m~S~-2~N~" 
  end if

  if ( field_name(n) .eq. "SFWF"   ) then 
    dmin  = -10.0
    dmax  =  10.0
    dmin_diff =  -8.0
    dmax_diff =   8.0
    field_1 = field_1 / 1.0e-5
    field_2 = field_2 / 1.0e-5
    units     = "x10~S~-5~N~ Kg m~S~-2~S~ s~S~-1~N~"
  end if

  if ( field_name(n) .eq. "SFWF_TOTAL" ) then
    dmin      = -10.0
    dmax      =  10.0
    dmin_diff =  -8.0
    dmax_diff =   8.0
    units     = "x10~S~-5~N~ Kg m~S~-2~S~ s~S~-1~N~"
    field_1 = field_1 / 1.0e-5
    field_2 = field_2 / 1.0e-5
    contourline = 2
  end if

  if ( field_name(n) .eq. "MELT_F" ) then
    dmin      = 0.0
    dmax      = 20.0
    dmin_diff =  -8.0
    dmax_diff =   8.0
    units     = "x10~S~-5~N~ Kg m~S~-2~S~ s~S~-1~N~"
    field_1     = field_1     / 1.0e-5
    field_2     = field_2     / 1.0e-5
    contourline = 2
  end if

  if ( field_name(n) .eq. "ROFF_F" ) then
    dmin      = 0.0
    dmax      = 30.0
    dmin_diff =  -4.0
    dmax_diff =   4.0
    units     = "x10~S~-5~N~ Kg m~S~-2~S~ s~S~-1~N~"
    field_1     = field_1     / 1.0e-5
    field_2     = field_2     / 1.0e-5
    contourline = 2
  end if

  if ( field_name(n) .eq. "EVAP_F" ) then
    dmin      = -14.0
    dmax      =   1.0
    dmin_diff =  -4.0
    dmax_diff =   4.0
    units     = "x10~S~-5~N~ Kg m~S~-2~S~ s~S~-1~N~"
    field_1     = field_1     / 1.0e-5
    field_2     = field_2     / 1.0e-5
    contourline = 3
  end if

  if ( field_name(n) .eq. "PREC_F" ) then
    dmin      =  0.0
    dmax      =  14.0
    dmin_diff =  -8.0
    dmax_diff =   8.0

    units     = "x10~S~-5~N~ Kg m~S~-2~S~ s~S~-1~N~"
    field_1     = field_1     / 1.0e-5
    field_2     = field_2     / 1.0e-5
    contourline=2
  end if

  if ( field_name(n) .eq. "SNOW_F" ) then
    dmin      = 0.
    dmax      = 3.
    dmin_diff =  -2.0
    dmax_diff =   2.0
    units     = "x10~S~-5~N~ Kg m~S~-2~N~ s~S~-1~N~"
    field_1     = field_1     / 1.0e-5
    field_2     = field_2     / 1.0e-5
    contourline=2
  end if

  if ( field_name(n) .eq. "SALT_F" ) then
    dmin  = -3.0
    dmax  =  3.0 
    dmin_diff = -2.0
    dmax_diff =  2.0
    units     = "x10~S~-5~N~ Kg m~S~-2~N~ s~S~-1~N~"
    field_1 = field_1 * tofloat(sflux_factor) / ( tofloat(salinity_factor) * 1.0e-5 )
    field_2 = field_2 * tofloat(sflux_factor) / ( tofloat(salinity_factor) * 1.0e-5 )
    contourline = 3
  end if

  if ( field_name(n) .eq. "TAUX" ) then 
    dmin      = -4.0
    dmax      =  4.0
    dmin_diff = -1.0
    dmax_diff =  1.0
    units     = "dyn cm~S~-2~N~"
    contourline = 3
  end if

  if ( field_name(n) .eq. "TAUY" ) then 
    dmin      = -2.0
    dmax      =  2.0
    dmin_diff = -1.0
    dmax_diff =  1.0 
    units     = "dyn cm~S~-2~N~"
    contourline = 3
  end if

  if ( field_name(n) .eq. "QFLUX" ) then
    dmin  =    0.0
    dmax  =  40.0
    dmin_diff =  -20.0
    dmax_diff =   20.0
    units = " W m~S~-2~N~" 
    contourline = 2
  end if


  if ( dmin      .eq. missing  .or.  dmax      .eq. missing ) then \ 
    print( " user must set the contour limits .... " )
  end if

  if (dimsizes(dimsizes(field_1)) .eq. 3) then
	tmp = field_1(0,:,:)
	delete(field_1)
	field_1 = tmp
	delete(tmp)
  end if
  if (dimsizes(dimsizes(field_2)) .eq. 3) then
	tmp = field_2(0,:,:)
	delete(field_2)
	field_2 = tmp
	delete(tmp)
  end if
  field_diff = field_1 - field_2
  
  if ( dmin_diff .eq. missing  .or.  dmax_diff .eq. missing ) then \ 
    print(" user must set the contour limits .... ")
  end if
  if (isatt(field_1,"units")) then
	    field_diff@units = field_1@units
  end if

  nlev = 21
  dlev = (dmax-dmin)/(nlev-1) 
  lev  = dmin + ispan(0,nlev-1,1)*dlev
  dlev_diff = (dmax_diff-dmin_diff)/(nlev-1)
  lev_diff  = dmin_diff + ispan(0,nlev-1,1)*dlev_diff

  ;wks = gsn_open_wks("x11",field_name(n))
  wks = gsn_open_wks(img_format,field_name(n))
  gsn_define_colormap(wks,"table42")

  coltab = new(nlev + 1,"integer")
  color1 = 2 
  coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
  coltab(0) = 0

  print( " plotting ..... " + field_name(n))

  case_info = field_name(n)+" " + case_number + " " + time_info
  case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info

  opt = True
  opt@charsize = 0.9
  opt@landcolor = lndcolor
  if (field_name(n) .eq. "CURL") then
    opt@contourline = 2
  else
    opt@contourline = contourline
  end if
  opt@xrange = (/ xr0,xr1/)
  opt@yrange = (/ yr0,yr1/)
  opt@do_panel = True
  opt@gsnRightStringParallelPosF = 1.2
  lon = tlon
  lat = tlat

  if (ugrid) then
     lon = fileid_1->ULONG
     lat = fileid_1->ULAT
     area = uarea
  end if

  plot1 = contour_plot(wks, field_1, lon, lat, kmt, region_mask, area, case_info, \
            	       missing, units, dlev, lev, coltab, opt)

  if (opt@do_panel) then
     opt@contourline = 2
     plot2 = contour_plot(wks, field_diff, lon, lat, kmt, region_mask, area, case_info_diff, \
                          missing, units, dlev_diff, lev_diff, coltab, opt)
    
     gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)
 end if

 delete([/field_1,field_2,field_diff,lev,lev_diff,coltab,lon,lat/])

end do

end
