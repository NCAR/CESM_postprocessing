load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"

begin

  file_netcdf_za = "za_"+file_netcdf

  nlev    = 21
  missing = 1.0e30

  global   = 0
  atlantic = 6
  pacific  = 2 
  indian   = 3 
  southern = 1 

  region_index = (/ global, atlantic, pacific, indian, southern /)
  n_reg = dimsizes(region_index)

  field_name = [/ "SSH", "HBLT", "HMXL" /] 

  f_za = addfile(file_netcdf_za,"r")
  if (isfilevar(f_za,"DIA_DEPTH")) then
    ListPush(field_name,"DIA_DEPTH")
  end if
  if (isfilevar(f_za,"TLT")) then
    ListPush(field_name,"TLT")
  end if
  if (isfilevar(f_za,"INT_DEPTH")) then
    ListPush(field_name,"INT_DEPTH")
  end if

  n_fields = ListCount(field_name)
  print( " the number of fields to be processed is " +  n_fields)

  fileid = addfile(file_netcdf,"r")
  days_in_norm_year = fileid->days_in_norm_year
  sflux_factor = fileid->sflux_factor
  salinity_factor = fileid->salinity_factor
  l_f = fileid->latent_heat_fusion
  l_f = l_f / 1e4
  secperday  = 86400.
  secperyear = days_in_norm_year * secperday
  rho_fw = 1.0
  rho_fw = rho_fw * 1000.
  lat_t = f_za->lat_t
  z_t = f_za->z_t
  z_t = z_t / 1.0e5


  do n=0,n_fields-1

    fname = ListPop(field_name)
    field = f_za->$fname$

    if ( fname .eq. "SSH" ) then
      units = "cm" 
    else
      units = "m"
      field = field / 100.0
    end if

    print( " plotting zonal average of " + fname)

    ;wks = gsn_open_wks("x11",fname)
    wks = gsn_open_wks(img_format,fname+ "_GLO_za")
    gsn_define_colormap(wks,"table42")
    
    case_info = fname +" ZONAL-AVE (GLO) " \
    + case_number + " " + time_info
    res = True
    res@tiMainFontHeightF = 0.022
    res@tiYAxisFontHeightF = 0.02
    res@tiXAxisFontHeightF = 0.02
    res@tiXAxisOffsetYF = -0.03
    res@tiMainString = case_info
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

    plot = gsn_csm_xy(wks,lat_t,field(0,global,:),res)

  end do

end
