load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"

begin

file_netcdf_za = "za_"+file_netcdf
file_flux_obs_za = "za_"+file_flux_obs
file_wind_obs_za = "za_"+file_wind_obs

nlev    = 21
missing = 1.0e30

global   = 0
atlantic = 6
pacific  = 2 
indian   = 3 
southern = 1 

region_index = (/ global, atlantic, pacific, indian, southern /)

n_reg = dimsizes(region_index)

field_name = (/ "SHF_TOTAL", "SHF_QSW", "SFWF_TOTAL", "PREC_F",  \
               "EVAP_F",    "MELT_F",  "ROFF_F",     "SALT_F",  \
               "SENH_F",    "LWUP_F",  "LWDN_F",     "MELTH_F", \
               "QFLUX", "SNOW_F" /)
if (resolution .eq. "gx1v6") then
 obsvar_name = (/ "nethflx", "swnet", "netfwflx", "rain", \
                 "evap", "meltw", "roff", "", \
                 "sen", "lwup", "lwdn", "melth", \
                 "", "snow" /)
else
 obsvar_name = (/ "", "", "", "", \
                 "", "", "", "", \
                 "", "", "", "", \
                 "", "" /)
end if
		 
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

f_za = addfile(file_netcdf_za,"r")
f_obs = addfile(file_flux_obs_za,"r")

n_fields = dimsizes(field_name)

print( " the number of fields to be processed is " +  n_fields)
lat_t = f_za->lat_t
z_t = f_za->z_t
z_t = z_t / 1.0e5

if (cpl .eq. 6) then
  obs_prefix = "avXc2o_o_"
else
  obs_prefix = "x2oavg_"
end if
do n=0, n_fields-1 

  obsfile = f_obs
  
  if (obsvar_name(n) .eq. "") then
     obsvar = ""
  else if (field_name(n) .eq. "ROFF_F") then
     obsvar = obs_prefix + "Forr_" + obsvar_name(n)
  else
     obsvar = obs_prefix + "Foxx_" + obsvar_name(n)
  end if
  end if

  if (obsvar .ne. "") then 
     field_obs = obsfile->$obsvar$
  end if
  if ( field_name(n) .eq. "PREC_F" ) then 
     obsvar = obs_prefix + "Foxx_snow"
     snow = obsfile->$obsvar$
     field_obs = where(field_obs .lt. 1.e10 .and. snow .lt. 1.e10, field_obs + snow, field_obs@_FillValue)
  end if

  if ( field_name(n) .ne. "SHF_TOTAL"  .and. \
       field_name(n) .ne. "SFWF_TOTAL" ) then 
     field = f_za->$field_name(n)$
  else
     field_q = f_za->QFLUX
     if ( field_name(n) .eq. "SHF_TOTAL" ) then 
        field = f_za->SHF
        field = where(field .lt. 1e10 .and. field_q .lt. 1e10, field + field_q, field@_FillValue)
     end if
     if ( field_name(n) .eq. "SFWF_TOTAL" ) then
        field = f_za->SFWF
        field = tofloat(where(field .lt. 1e10 .and. field_q .lt. 1e10, field - field_q/l_f, field@_FillValue))
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
      field = field / 1.0e-5
      if (obsvar .ne. "") then
          field_obs = field_obs / 1.0e-5
      end if
   end if
   if ( field_name(n) .eq. "SALT_F" ) then
      units = "x10~S~-5~N~ Kg m~S~-2~N~ s~S~-1~N~"
      field = tofloat(field * sflux_factor / ( salinity_factor * 1.0e-5 ))
   end if 
   if ( field_name(n) .eq. "TAUX" .or. field_name(n) .eq. "TAUY" ) then
      units = "dyn cm~S~-2~N~"
      field_obs = where(field_obs .lt. 1e10,field_obs * 10, field_obs@_FillValue)
   end if 

   print( " plotting zonal average of " + field_name(n))

   ;wks = gsn_open_wks("x11",field_name(n))
   wks = gsn_open_wks(img_format,field_name(n)+ "_GLO_za")
   gsn_define_colormap(wks,"table42")
  
   case_info = field_name(n) +" ZONAL-AVE (GLO) " \
               + case_number + " " + time_info
   subt = ""
   if ( obsvar .ne. "" ) then 
      subt = "OBS (red), "+file_flux_obs 
   end if
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

   if (obsvar .eq. "") then
       ; printVarSummary(field)
       plot = gsn_csm_xy(wks,lat_t,field(0,global,:),res)
   else
       if (cpl .eq. 7) then
         data = new((/2,dimsizes(lat_t)/),double)
       else
         data = new((/2,dimsizes(lat_t)/),float)
       end if
       data(0,:) = field(0,global,:)
       if (dimsizes(dimsizes(field_obs)) .eq. 3) then
         data(1,:) = field_obs(0,global,:)
       else
         data(1,:) = (/ field_obs(global,:) /)
       end if
       plot = gsn_csm_xy(wks,lat_t,data,res)
       delete(data)
       delete(field_obs)
    end if

    delete(field)
end do

end
