load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"

begin

file_netcdf_za   = "za_"+file_netcdf
file_flux_obs_za = "za_"+file_flux_obs
file_wind_obs_za = "za_"+file_wind_obs

;;print("*** file_netcdf_za = "+file_netcdf_za)
;;print("*** file_flux_obs_za = "+file_flux_obs_za)
;;print("*** file_wind_obs_za = "+file_wind_obs_za)

fileid = addfile(file_netcdf,"r")
f_za   = addfile(file_netcdf_za,"r")

yesobs = isfilepresent(file_flux_obs_za)
if (yesobs) then
  f_obs = addfile(file_flux_obs_za,"r")
else
  print("Observational file of zonal average does not exist.")
end if

nlev    = 21
missing = 1.0e30

global   = 0
atlantic = 6
pacific  = 2 
indian   = 3 
southern = 1 

region_index = (/ global, atlantic, pacific, indian, southern /)

n_reg = dimsizes(region_index)

varsinfile = getfilevarnames(f_za)

if (any(varsinfile.eq."SHF") .and. any(varsinfile.eq."SFWF")) then
   field_name = (/ "SHF", "SHF_QSW", "SFWF", "PREC_F",  \
   	      	   "EVAP_F",    "MELT_F",  "ROFF_F",     "SALT_F",  \
		   "SENH_F",    "LWUP_F",  "LWDN_F",     "MELTH_F", \
                   "QFLUX", "SNOW_F" /)
else
   field_name = (/ "SHF_TOTAL", "SHF_QSW", "SFWF_TOTAL", "PREC_F",  \
   	      	   "EVAP_F",    "MELT_F",  "ROFF_F",     "SALT_F",  \
		   "SENH_F",    "LWUP_F",  "LWDN_F",     "MELTH_F", \
                   "QFLUX", "SNOW_F" /)
end if

if ((resolution .eq. "gx1v6") .or. (resolution .eq. "gx1v7")) then
 obsvar_name = (/ "nethflx", "swnet", "netfwflx", "rain", \
                 "evap", "meltw", "roff", "", \
                 "sen", "lwup", "lwdn", "melth", \
                 "", "snow" /)
else if (resolution .eq. "tx0.1v2") then
  obsvar_name = (/ "swnet",   "melth",   "sen",    \
                   "lwup",    "lwdn",    "evap",   "rain", \
                   "meltw",   "",        "snow"    /)
else
 obsvar_name = (/ "", "", "", "", \
                 "", "", "", "", \
                 "", "", "", "", \
                 "", "" /)
end if
end if

n_fields = dimsizes(field_name)

print( " the number of fields to be processed is " +  n_fields)

if (cpl .eq. 6) then
  obs_prefix = "avXc2o_o_"
else
  obs_prefix = "x2oavg_"
end if

;;-- Read details from "fileid" file --;;

sflux_factor = fileid->sflux_factor
if ( sflux_factor .eq. 0. ) then
   sflux_factor = 0.1
   print( "sflux_factor in file is zero. Prescribing new one." )
end if

salinity_factor = fileid->salinity_factor
if ( salinity_factor .eq. 0. ) then
   ocn_ref_salinity = 34.7
   fwflux_factor = 1.e-4
   salinity_factor = -1*ocn_ref_salinity*fwflux_factor
   print( "salinity_factor in file is zero. Computing new one." )
end if

l_f = fileid->latent_heat_fusion
l_f = l_f / 1e4

;;-- Read coordinates from "f_za" file --;;

lat_t = f_za->lat_t

;;-- Loop over fields --;;

do n=0, n_fields-1 

  if(.not.any(varsinfile.eq.field_name(n))) then
     print(field_name(n) + " is not in file.")
     continue
  end if

  print(" processing zonal average of " + field_name(n))

  if ( yesobs ) then
    obsfile = f_obs
  end if

  if (obsvar_name(n) .eq. "") then
     obsvar = ""
     print("No observations of " + field_name(n))
  else if (field_name(n) .eq. "ROFF_F") then
     obsvar = obs_prefix + "Forr_" + obsvar_name(n)
     print("ROFF_F obsvar = "+obsvar)
  else
     obsvar = obs_prefix + "Foxx_" + obsvar_name(n)
     print("obsvar = "+obsvar)
  end if
  end if

  ;;-- Read observations from "obsfile" file --;;

  if (obsvar .ne. "" .and. yesobs ) then
     field_obs = obsfile->$obsvar$
  end if
  if ( field_name(n) .eq. "PREC_F" .and. yesobs ) then
     obsvar = obs_prefix + "Foxx_snow"
     snow = obsfile->$obsvar$
;; ASB - error in logic since field_obs is not defined if PREC_F is not in obsfile
     ;;field_obs = where(field_obs .lt. 1.e10 .and. snow .lt. 1.e10, field_obs + snow, field_obs@_FillValue)
     field_obs = where(snow .lt. 1.e10, snow, snow@_FillValue)
  end if

  ;;-- Read model output from "f_za" file --;;

  if ( field_name(n) .ne. "SHF_TOTAL"  .and. \
       field_name(n) .ne. "SFWF_TOTAL"  .and. \
       field_name(n) .ne. "SHF"  .and. \
       field_name(n) .ne. "SFWF") then 
     field = f_za->$field_name(n)$
  else
     if ( field_name(n) .eq. "SHF_TOTAL" .or. \
          field_name(n) .eq. "SHF") then 
;;	print("**************")
;;      print("*** computing SHF_TOTAL")
        field_q = f_za->QFLUX
        ;;field   = f_za->SHF
	field   = f_za->$field_name(n)$
        field   = where(field .lt. 1e10 .and. field_q .lt. 1e10, field + field_q, field@_FillValue)
;;     	printVarSummary(field)
;;	print("**************")
     end if
     if ( field_name(n) .eq. "SFWF_TOTAL" .or. \
          field_name(n) .eq. "SFWF") then
;;	print("**************")
;;      print("*** computing SFWF_TOTAL")
        field_q = f_za->QFLUX
        ;;field   = f_za->SFWF
	field   = f_za->$field_name(n)$
        field   = tofloat(where(field .lt. 1e10 .and. field_q .lt. 1e10, field - field_q/l_f, field@_FillValue))
;;     	printVarSummary(field)
;;	print("**************")
     end if
   end if

   units = "W m~S~-2~N~"
   if ( field_name(n) .eq. "SFWF_TOTAL" .or. \  
        field_name(n) .eq. "SFWF"       .or. \  
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
      if (abs(salinity_factor).gt.0.) then
        field = tofloat(field * sflux_factor / ( salinity_factor * 1.0e-5 ))
      end if
   end if
   if ( field_name(n) .eq. "TAUX" .or. field_name(n) .eq. "TAUY" ) then
      units = "dyn cm~S~-2~N~"
      field_obs = where(field_obs .lt. 1e10,field_obs * 10, field_obs@_FillValue)
   end if

   print( " plotting zonal average of " + field_name(n))

   ;wks = gsn_open_wks("x11",field_name(n))
   wks = gsn_open_wks(img_format,field_name(n)+ "_GLO_za")
   ;;gsn_define_colormap(wks,"table42")

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
   res@xyDashPatterns = (/ 0, 1 /)
   res@xyLineThicknessF = 4
   res@gsnYRefLine = 0.0
   res@gsnPaperOrientation = "portrait"

   if (obsvar .eq. "") then
       ; printVarSummary(field)
       ;;print("*** plot with obsvar is null")
       plot = gsn_csm_xy(wks,lat_t,field(0,global,:),res)
   else
       ;;print("*** plot with obsvar ="+obsvar)
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
       ;;print("**** data var summary")
       ;;printVarSummary(data)
       ;;print("*** before gsn_csm_xy call")
       plot = gsn_csm_xy(wks,lat_t,data,res)
       delete(data)
       delete(field_obs)
    end if

    delete(field)
end do

end
