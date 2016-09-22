load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment_diff.ncl"

begin

  file_netcdf_za = "za_"+file_netcdf
  cntrl_netcdf_za = "za_"+cntrl_netcdf

  nlev    = 21
  missing = 1.0e30

  global   = 0
  atlantic = 6
  pacific  = 2 
  indian   = 3 
  southern = 1 

  region_index = (/ global, atlantic, pacific, indian, southern /)

  n_reg = dimsizes(region_index)

  fileid_1 = addfile(file_netcdf,"r")
  fileid_2 = addfile(cntrl_netcdf,"r")

  if (isfilevar(fileid_1,"QFLUX")) then

  field_name = (/ "SHF_TOTAL", "SHF_QSW", "SFWF_TOTAL", "PREC_F",  \
     "EVAP_F",    "MELT_F",  "ROFF_F",     "SALT_F",  \
     "SENH_F",    "LWUP_F",  "LWDN_F",     "MELTH_F", \
     "QFLUX", "SNOW_F" /)

  else

  field_name = (/ "SHF", "SFWF" /)

  end if

  days_in_norm_year = fileid_1->days_in_norm_year
  sflux_factor = fileid_1->sflux_factor
  salinity_factor = fileid_1->salinity_factor
  l_f = fileid_1->latent_heat_fusion
  l_f = l_f / 1e4
  secperday  = 86400.
  secperyear = days_in_norm_year * secperday
  rho_fw = 1.0
  rho_fw = rho_fw * 1000.

  fileid_1 = addfile(file_netcdf_za,"r")
  fileid_2 = addfile(cntrl_netcdf_za,"r")

  n_fields = dimsizes(field_name)

  print( " the number of fields to be processed is " +  n_fields)
  lat_t = fileid_1->lat_t
  z_t = fileid_1->z_t
  z_t = z_t / 1.0e5

  do n=0, n_fields-1 

    if ( field_name(n) .ne. "SHF_TOTAL"  .and. \
      field_name(n) .ne. "SFWF_TOTAL" ) then 
      field_1 = fileid_1->$field_name(n)$
      field_2 = fileid_2->$field_name(n)$
    else
      field_1q = fileid_1->QFLUX
      field_2q = fileid_2->QFLUX
      if ( field_name(n) .eq. "SHF_TOTAL" ) then 
        field_1 = fileid_1->SHF
        field_1 = where(field_1 .lt. 1e10 .and. field_1q .lt. 1e10, field_1 + field_1q, field_1@_FillValue)
        field_2 = fileid_2->SHF
        field_2 = where(field_2 .lt. 1e10 .and. field_2q .lt. 1e10, field_2 + field_2q, field_2@_FillValue)
      end if
      if ( field_name(n) .eq. "SFWF_TOTAL" ) then
        field_1 = fileid_1->SFWF
        field_1 = tofloat(where(field_1 .lt. 1e10 .and. field_1q .lt. 1e10, field_1 - field_1q/l_f, field_1@_FillValue))
        field_2 = fileid_2->SFWF
        field_2 = tofloat(where(field_2 .lt. 1e10 .and. field_2q .lt. 1e10, field_2 - field_2q/l_f, field_2@_FillValue))
      end if
    end if

    units = "W m~S~-2~N~"
    if ( field_name(n) .eq. "SFWF_TOTAL" .or. \  
      field_name(n) .eq. "PREC_F"     .or. \
      field_name(n) .eq. "EVAP_F"     .or. \
      field_name(n) .eq. "MELT_F"     .or. \
      field_name(n) .eq. "ROFF_F"     .or. \
      field_name(n) .eq. "SNOW_F" ) then 
      units = "x10~S~-5~N~ Kg m~S~-2~N~ s~S~-1~N~"
      field_1 = field_1 / 1.0e-5
      field_2 = field_2 / 1.0e-5
    end if
    if ( field_name(n) .eq. "SALT_F" ) then
      units = "x10~S~-5~N~ Kg m~S~-2~N~ s~S~-1~N~"
      field_1 = tofloat(field_1 * sflux_factor / ( salinity_factor * 1.0e-5 ))
      field_2 = tofloat(field_2 * sflux_factor / ( salinity_factor * 1.0e-5 ))
    end if 
    if ( field_name(n) .eq. "TAUX" .or. field_name(n) .eq. "TAUY" ) then
      units = "dyn cm~S~-2~N~"
    end if 

    print( " plotting zonal average of " + field_name(n))

    ;wks = gsn_open_wks("x11",field_name(n) +"_GLO_za")
    wks = gsn_open_wks(img_format,field_name(n)+ "_GLO_za")
    gsn_define_colormap(wks,"table42")
    
    case_info = field_name(n) +" ZONAL-AVE (GLO) " \
    + case_number + " " + time_info
    subt = cntrl_number+" "+cntrl_time_info+" in red"
    res = True
    res@tiMainFontHeightF = 0.022
    res@tiYAxisFontHeightF = 0.02
    res@tiXAxisFontHeightF = 0.02
    res@tiXAxisOffsetYF = -0.03
    res@tiMainString = case_info
    res@tiXAxisString = subt
    if (isvar("units")) then
      res@tiYAxisString = units
    else
      res@tiYAxisString = field@units
    end if
    res@vpHeightF = .5
    res@vpWidthF = .5 * 1.6
    res@gsnMaximize = True
    res@xyLineColors = (/"blue", "red"/)
    res@xyMonoDashPattern = True
    res@xyDashPattern = 0
    res@gsnYRefLine = 0.0
    res@gsnPaperOrientation = "portrait"

    data = new((/2,dimsizes(lat_t)/),float)
    data(0,:) = field_1(0,global,:)
    data(1,:) = field_2(0,global,:)
    plot = gsn_csm_xy(wks,lat_t,data,res)
    delete([/data,field_1,field_2/])

  end do

end
