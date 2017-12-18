load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"
load "$NCLPATH/curl_pop.ncl"

begin
print ( "resolution = " + resolution )

if (resolution .eq. "tx0.1v2") then
  field_name  = (/ "SHF",    "MELTH_F", \
                  "SENH_F",  "LWUP_F",     "LWDN_F",  "EVAP_F",  \
                  "SFWF",    "PREC_F",  "MELT_F",  \
                  "ROFF_F",  "SALT_F", "TAUX", "TAUY",  \
                  "SNOW_F" /)
else
   field_name  = (/ "SHF",     "SHF_TOTAL",  "SHF_QSW", "MELTH_F", \
                  "SENH_F",  "LWUP_F",     "LWDN_F",  "EVAP_F",  \
                  "SFWF",    "SFWF_TOTAL", "PREC_F",  "MELT_F",  \
                  "ROFF_F",  "SALT_F", "TAUX", "TAUY", "CURL",  \
                  "QFLUX",   "SNOW_F" /)
end if


if ((resolution .eq. "gx1v6") .or. (resolution .eq. "gx1v7")) then
  obs_var_name = (/  "", "Foxx_nethflx",  "Foxx_swnet", "", \
		"Foxx_sen", "Foxx_lwup", "Foxx_lwdn","Foxx_evap", \
		"", "Foxx_netfwflx","Foxx_rain","", \
		"", "", "Foxx_taux", "Foxx_tauy", \
		"", "", "Foxx_snow" /)
else
  obs_var_name = (/  "", "",  "", "", \
		"", "", "","", \
		"", "","","", \
		"", "", "", "", \
		"", "", "" /)
end if
		

n_fields = dimsizes(field_name)
print( " the number of fields to be processed is " + n_fields)

missing = default_fillvalue("float")

;;print("file_netcdf = "+file_netcdf)
;;print("file_flux_obs = "+file_flux_obs)
;;print("file_wind_obs = "+file_wind_obs)

fileid     = addfile(file_netcdf,"r")
fileid_obs = addfile(file_flux_obs,"r")
fileid_windobs = addfile(file_wind_obs,"r")

days_in_norm_year = fileid->days_in_norm_year
sflux_factor = fileid->sflux_factor
salinity_factor = fileid->salinity_factor
rho_sw = fileid->rho_sw * 1000.0
l_f = fileid->latent_heat_fusion / 1e4
tlat = fileid->TLAT
tlon = fileid->TLONG
sizes = dimsizes(tlon)
nx = sizes(1)
ny = sizes(0)
dxu = fileid->DXU
dyu = fileid->DYU
kmt = fileid->KMT
kmu = fileid->KMU
region_mask = fileid->REGION_MASK
tarea = fileid->TAREA
uarea = fileid->UAREA
angle = fileid->ANGLE

do n = 0, n_fields-1

  contourline = 3
  obsvar = ""
  if (field_name(n) .eq. "TAUX" .or. \
      field_name(n) .eq. "TAUY") then
	obsfile = fileid_windobs
	obs_prefix = "avXc2o_o_"
  else
	obsfile = fileid_obs
	if (cpl .eq. 6) then
      	    obs_prefix = "avXc2o_o_"
        else
            obs_prefix = "x2oavg_"
        end if
  end if
  if (obs_var_name(n) .ne. "") then
        ;;print("" + obs_prefix + obs_var_name(n))
	obsvar = obs_prefix + obs_var_name(n)
	field_obs = obsfile->$obsvar$
  end if
  if (field_name(n) .eq. "PREC_F") then
	snow_varname = obs_prefix + "Foxx_snow"
	snow = obsfile->$snow_varname$
        ;printVarSummary(snow)
        ;printVarSummary(field_obs)
        ;printVarSummary(region_mask)
	if (obsvar .ne. "") then
          if (dimsizes(dimsizes(field_obs)) .eq. 3) then
            field_obs(0,:,:) = where(region_mask .ne. 0,field_obs(0,:,:) + snow(0,:,:), field_obs(0,:,:))
          else
            field_obs = where(region_mask .ne. 0,field_obs + snow, field_obs)
          end if
	end if
  end if
 
  if (field_name(n) .eq. "CURL") then	
    if (obsvar .ne. "") then
	obsvar = "curl"
        taux = fileid_windobs->avXc2o_o_Foxx_taux(0,:,:)
        tauy = fileid_windobs->avXc2o_o_Foxx_tauy(0,:,:)
	;printVarSummary(taux)
        ;printVarSummary(tauy)
	;print(min(taux) + " " + max(taux) + " " + min(tauy) + " " + max(tauy)) 
	taux = where(taux .gt. 1.0e29, taux@_FillValue,taux)
	tauy = where(tauy .gt. 1.0e29, tauy@_FillValue,tauy)
	taux = where(abs(taux) .lt. 1.0e10, 10.*taux,taux)
        tauy = where(abs(tauy) .lt. 1.0e10, 10.*tauy,tauy)
	;print(min(taux) + " " + max(taux) + " " + min(tauy) + " " + max(tauy)) 
        k = 1
        field_obs = curl_pop( k, taux, tauy, dxu, dyu, tarea, kmt, missing)
        ;printVarSummary(field_obs)
	field_obs = field_obs / 1.0e-8
        field_obs@units = "10e-8N/m3" 
    
	delete([/taux,tauy/])
    end if
    taux = fileid->TAUX(0,:,:)
    tauy = fileid->TAUY(0,:,:)
    taux = tofloat(taux * cos(angle) + tauy * sin(-angle))
    taux = where(abs(taux) .gt. 1.0e10,taux@_FillValue, taux)
    tauy = tofloat(tauy * cos(angle) - taux * sin(-angle))
    tauy = where(abs(tauy) .gt. 1.0e10,tauy@_FillValue, tauy)
    k = 1
    field = curl_pop(k, taux, tauy, dxu, dyu, tarea, kmt, missing)
    field = field/1.0e-8
    field@units = "10e-8N/m3" 
  else if (field_name(n) .eq. "SHF_TOTAL" ) then 
    if (isfilevar(fileid,"QFLUX")) then
      field_temp = fileid->QFLUX
      field_temp2 = fileid->SHF
      field = field_temp + field_temp2
    end if
  else if ( field_name(n) .eq. "SFWF_TOTAL" ) then 
    if (isfilevar(fileid,"QFLUX")) then
      field_temp = fileid->QFLUX
      field_temp2 = fileid->SFWF
      field = -field_temp/l_f + field_temp2
    end if
  else
    if (isfilevar(fileid,field_name(n))) then
      field = fileid->$field_name(n)$
    else
      field = _Missing
    end if
  end if
  end if
  end if

  if (.not.all(ismissing(field))) then
    if (iscoord(field,"ULONG")) then
       ugrid = True
    else
       ugrid = False
    end if
    ;print(ugrid)

    if (isatt(field,"units")) then
       units = field@units
    else
       units = ""
    end if

    area = tarea
    if ( field_name(n) .eq. "TAUX" ) then 
      field_2 = fileid->TAUY
      ;printVarSummary(field_2)
      ;printVarSummary(angle)
      ;printVarSummary(field)
      field(0,:,:) = tofloat(field(0,:,:) * cos(angle) + field_2(0,:,:) * sin(-angle))
      field = where(abs(field) .gt. 1.0e29, field@_FillValue, field)
      delete(field_2)
      area = uarea
;      obsvar2 = obs_prefix + "Foxx_tauy"
;      field_obs2 = obsfile->$obsvar2$
      if (obsvar .ne. "") then
        field_obs = where(abs(field_obs) .gt. 1.0e10, field_obs@_FillValue, field_obs)
        field_obs = field_obs * 10.0
;      field_obs2 = where(abs(field_obs2) .gt. 1.0e10, field_obs2@_FillValue, field_obs2)
;      field_obs2 = field_obs2 * 10.0
;      field_obs(0,:,:) = field_obs(0,:,:) * cos(angle) + field_obs2(0,:,:) * sin(-angle)
;      delete(field_obs2)
      end if

    else if (field_name(n) .eq. "TAUY" ) then
      field_2 = fileid->TAUX
      field(0,:,:) = tofloat(field(0,:,:) * cos(angle) - field_2(0,:,:) * sin(-angle))
      field = where(abs(field) .gt. 1.0e29, field@_FillValue, field)
      delete(field_2)
      area = uarea
 ;     obsvar2 = obs_prefix + "Foxx_taux"
 ;     field_obs2 = obsfile->$obsvar2$
      if (obsvar .ne. "") then
        field_obs = where(abs(field_obs) .gt. 1.0e10, field_obs@_FillValue, field_obs)
        field_obs = field_obs * 10.0
 ;     field_obs2 = where(abs(field_obs2) .gt. 1.0e10, field_obs2@_FillValue, field_obs2)
 ;     field_obs2 = field_obs2  * 10.0
 ;     field_obs(0,:,:) = field_obs(0,:,:) * cos(angle) - field_obs2(0,:,:) * sin(-angle)
 ;     delete(field_obs2)
      end if
    end if
  end if

  dmin = missing 
  dmax = missing 

  dmin_diff = missing
  dmax_diff = missing

  if ( field_name(n) .eq. "CURL" ) then
    dmin  = -40.0
    dmax  =  40.0 
    dmin_diff = -20.0
    dmax_diff =  20.0
;    units = " x10!e-8!n N m!e-3!n"
    contourline = 2
  end if

  if ( field_name(n) .eq. "SHF" ) then
    dmin  = -200.0
    dmax  =  200.0 
;    units = " W m!e-2!n" 
  end if

  if ( field_name(n) .eq. "SHF_TOTAL" ) then
    dmin      = -200.0
    dmax      =  200.0
    dmin_diff = -100.0
    dmax_diff =  100.0
;    units     = " W m!e-2!n"
    contourline = 1
  end if

  if ( field_name(n) .eq. "SENH_F" ) then
    dmin      = -100.0
    dmax      =  40.0
    dmin_diff =  -50.0
    dmax_diff =   50.0
;    units     = " W m!e-2!n"
  end if

  if ( field_name(n) .eq. "SHF_QSW" ) then
    dmin      =   0.0
    dmax      = 400.0 
    dmin_diff = -50.0
    dmax_diff =  50.0
;    units     = " W m!e-2!n"
  end if

  if ( field_name(n) .eq. "LWUP_F" ) then
    dmin      = -600.0
    dmax      =    0.0
    dmin_diff = -100.0
    dmax_diff =  100.0
;    units     = " W m!e-2!n"
  end if

  if ( field_name(n) .eq. "LWDN_F" ) then
    dmin      =    0.0
    dmax      =  500.0
    dmin_diff = -100.0
    dmax_diff =  100.0
;    units     = " W m!e-2!n"
  end if

  if ( field_name(n) .eq. "MELTH_F" ) then
    dmin      = -50.0
    dmax      =   0.0
    dmin_diff =  -50.0
    dmax_diff =   50.0
;    units     = " W m!e-2!n"
    contourline = 2
  end if

  if ( field_name(n) .eq. "SFWF"   ) then 
    dmin  = -10.0
    dmax  =  10.0
;    units = " x10!e-5!n Kg m!e-2!n s!e-1!n"
    field = field / 1.0e-5
  end if

  if ( field_name(n) .eq. "SFWF_TOTAL" ) then
    dmin      = -10.0
    dmax      =  10.0
    dmin_diff =  -8.0
    dmax_diff =   8.0
;    units     = " x10!e-5!n Kg m!e-2!n s!e-1!n"
    field     = field     / 1.0e-5
   if (obsvar .ne. "") then
    field_obs = field_obs / 1.0e-5
   end if
    contourline = 2
  end if

  if ( field_name(n) .eq. "MELT_F" ) then
    dmin      = 0.0
    dmax      = 20.0
    dmin_diff =  -8.0
    dmax_diff =   8.0
;    units     = " x10!e-5!n Kg m!e-2!n s!e-1!n"
    field     = field     / 1.0e-5
   if (obsvar .ne. "") then
    field_obs = field_obs / 1.0e-5
   end if
    contourline = 2
  end if

  if ( field_name(n) .eq. "ROFF_F" ) then
    dmin      = 0.0
    dmax      = 30.0
    dmin_diff =  -4.0
    dmax_diff =   4.0
;    units     = " x10!e-5!n Kg m!e-2!n s!e-1!n"
    field     = field     / 1.0e-5
   if (obsvar .ne. "") then
    field_obs = field_obs / 1.0e-5
   end if
    contourline = 2
  end if

  if ( field_name(n) .eq. "EVAP_F" ) then
    dmin      = -14.0
    dmax      =   1.0
    dmin_diff =  -4.0
    dmax_diff =   4.0
;    units     = " x10!e-5!n Kg m!e-2!n s!e-1!n"
    field     = field     / 1.0e-5
   if (obsvar .ne. "") then
    field_obs = field_obs / 1.0e-5
   end if
  end if

  if ( field_name(n) .eq. "PREC_F" ) then
    dmin      =  0.0
    dmax      =  14.0
    dmin_diff =  -8.0
    dmax_diff =   8.0
;    units     = " x10!e-5!n Kg m!e-2!n s!e-1!n"
    field     = field     / 1.0e-5
   if (obsvar .ne. "") then
    field_obs = field_obs / 1.0e-5
   end if
    contourline=2
  end if

  if ( field_name(n) .eq. "SNOW_F" ) then
    dmin      = 0.
    dmax      = 3.
    dmin_diff =  -2.0
    dmax_diff =   2.0
;    units     = " x10!e-5!n Kg m!e-2!n s!e-1!n"
    field     = field     / 1.0e-5
   if (obsvar .ne. "") then
    field_obs = field_obs / 1.0e-5
   end if
    contourline=2
  end if

  if ( field_name(n) .eq. "SALT_F" ) then
    dmin  = -3.0
    dmax  =  3.0 
;    units = " x10!e-5!n Kg m!e-2!n s!e-1!n"
    ;printVarSummary(sflux_factor)
    ;printVarSummary(salinity_factor)
   if (abs(salinity_factor).gt.0.) then
    field = field * tofloat(sflux_factor) / ( tofloat(salinity_factor) * 1.0e-5 )
   end if
  end if

  if ( field_name(n) .eq. "TAUX" ) then 
    dmin      = -4.0
    dmax      =  4.0
    dmin_diff = -2.0
    dmax_diff =  2.0
;    units     = " dyn cm!e-2!n"
;    field_obs = field_obs * 10.
  end if

  if ( field_name(n) .eq. "TAUY" ) then 
    dmin      = -2.0
    dmax      =  2.0
    dmin_diff = -1.0
    dmax_diff =  1.0 
;    units     = " dyn cm!e-2!n"
;    field_obs = field_obs * 10. 
  end if

  if ( field_name(n) .eq. "QFLUX" ) then
    dmin  =    0.0
    dmax  =  40.0
;    units = " W m!e-2!n"
    contourline = 2
  end if


  if ( dmin .eq. missing  .or.  dmax .eq. missing ) then \ 
    print( " user must set the contour limits .... " )
  end if

  if (dimsizes(dimsizes(field)) .eq. 3) then
	tmp = field(0,:,:)
	delete(field)
	field = tmp
	delete(tmp)
  end if
  
  if (isvar("field_obs") .and. dimsizes(dimsizes(field_obs)) .eq. 3) then
	tmp = field_obs(0,:,:)
	delete(field_obs)
	field_obs = tmp
	delete(tmp)
  end if
  
   if ( obsvar .ne. "") then 
    ;;print("*** before field")
    ;;printVarSummary(field)
    ;;print("*** before field_obs")
    ;;printVarSummary(field_obs)
    field_diff = field - field_obs
    if ( dmin_diff .eq. missing  .or.  dmax_diff .eq. missing ) then \ 
        print(" user must set the contour limits .... ")
    end if
    if (isatt(field,"units")) then
        field_diff@units = field@units
    end if
   end if
  
  nlev = 21
  dlev = (dmax-dmin)/(nlev-1) 
  lev  = dmin + ispan(0,nlev-1,1)*dlev
  ;print(lev)
  if (obsvar .ne. "") then
    dlev_diff = (dmax_diff-dmin_diff)/(nlev-1)
    lev_diff  = dmin_diff + ispan(0,nlev-1,1)*dlev_diff
  end if
  
;  wks = gsn_open_wks("x11",field_name(n))
  wks = gsn_open_wks(img_format,field_name(n))
  gsn_define_colormap(wks,"table42")
 ; gsn_draw_colormap(wks)

  coltab = new(nlev + 1,"integer")
  coltab(0) = 1
  color1 = 2 
  coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
  coltab(0) = 0
  ;print (coltab)

  print( " plotting ..... " + field_name(n))

  case_info = field_name(n)+" " + case_number + " " + time_info

  case_info_diff = "MODEL - OBS ("+ file_flux_obs+")"
  if ( field_name(n) .eq. "TAUX" .or. field_name(n) .eq. "TAUY" .or. \
	field_name(n) .eq. "CURL" ) then \
    case_info_diff = "MODEL - OBS ("+ file_wind_obs+")"
  end if

  opt = True
  opt@charsize = 0.9
  opt@landcolor = lndcolor
  opt@contourline = contourline
  opt@xrange = (/ xr0,xr1/)
  opt@yrange = (/ yr0,yr1/)
  if (obsvar .ne. "")
     opt@do_panel = True
  else
     opt@do_panel = False
  end if
  ;;print("drawing plot1")
  plot1 = contour_plot(wks, field, tlon, tlat, kmt, region_mask, area, case_info, \
      	               missing, units, dlev, lev, coltab, opt)

  if (opt@do_panel) then
  ;;print("drawing plot2")
  if (field_name(n) .eq. "CURL") then
      opt@contourline = 2
  else
      opt@contourline = 1
  end if
  plot2 = contour_plot(wks, field_diff, tlon, tlat, kmt, region_mask, area, case_info_diff, \
                      missing, units, dlev_diff, lev_diff, coltab, opt)
    
  ;;print("panelling")
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)
  end if

 delete([/field,obsvar,lev,coltab/])
 if (isvar("field_obs")) then
   delete([/field_obs,field_diff,lev_diff/])
 end if

 end if

end do

end
