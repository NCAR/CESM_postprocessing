load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/yz_plot.ncl"

begin
  file_netcdf_za = "za_"+file_netcdf
  file_T_obs_za = "za_"+file_T_obs
  file_S_obs_za = "za_"+file_S_obs

  nlev    = 21
  missing = 1.0e30

;; NOTE - for pop, the basin regions are always
;; referenced by an index number, 1-14, with the
;; region areas defined in the POP source code
;; input_templates/[grid]_region_ids
;; We are only interested in the regions listed
;; below so want to subset the input fields 
;; for just these basin index for these regions

  global   = 0
  atlantic = 6
  pacific  = 2 
  indian   = 3 
  southern = 1 

  region_index = (/ global, atlantic, pacific, indian, southern /)
  region_names = (/ "GLO", "ATL", "PAC", "IND", "SOU" /)

  n_reg = dimsizes(region_index)

  field_name = [/ "TEMP",  "SALT" , "IAGE" /] 

  fileid = addfile(file_netcdf,"r")
  fileidtobs = addfile(file_T_obs_za,"r")
  fileidsobs = addfile(file_S_obs_za,"r")

  days_in_norm_year = fileid->days_in_norm_year
  sflux_factor = fileid->sflux_factor
  salinity_factor = fileid->salinity_factor
  rho_sw = fileid->rho_sw * 1000.0
  l_f = fileid->latent_heat_fusion / 1e4
  secperday  = 86400.
  secperyear = days_in_norm_year * secperday
  rho_fw = 1.0
  rho_fw = rho_fw * 1000.

  f_za = addfile(file_netcdf_za,"r")

  if (isfilevar(f_za,"KAPPA_ISOP")) then
    ListPush(field_name,"KAPPA_ISOP")
  end if
  if (isfilevar(f_za,"KAPPA_THIC")) then
    ListPush(field_name,"KAPPA_THIC")
  end if

  n_fields = ListCount(field_name)

  print( " the number of fields to be processed is " + n_fields)

  lat_t = f_za->lat_t
  z_t = f_za->z_t
  z_t = z_t / 1.0e5

  coltab = new(nlev + 1,"integer")
  coltab(0) = 1
  color1 = 2 
  coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
  coltab(0) = 0

  do n=0,n_fields-1 

    fname = ListPop(field_name)
;; just need the subset basin index of the second dimension
;;    field = f_za->$fname$(0,:,:,:)
    field = f_za->$fname$(0,0:6,:,:)
    field&z_t = z_t
    field@units = "km"

    if ( fname .eq. "TEMP" ) then
      field_obs = fileidtobs->TEMP
      if (dimsizes(z_t) .ne. dimsizes(field_obs&$field_obs!1$)) then
        ind_z_obs = ind_nearest_coord(z_t*1000.,field_obs&$field_obs!1$,0)
      end if	
      field_obs = where(field_obs .lt. -50. .or. field_obs .gt. 1.e10,field_obs@_FillValue,field_obs)
      field_diff = field
;; get just the basin index (region) in the first dimension
      if (isvar("ind_z_obs")) then
        field_diff = field - field_obs(0:6,ind_z_obs,:)
      else
        field_diff = field - field_obs(0:6,:,:)
      end if
      units = "~S~o~N~C"
      dmin  =  -4.0
      dmax  =  36.0
      dmin2 = -10.0
      dmax2 =  10.0
      dlev = (dmax-dmin)/(nlev-1) 
      lev  = dmin + ispan(0,nlev-1,1)*dlev
      dlev2 = (dmax2-dmin2)/(nlev-1) 
      lev2  = dmin2 + ispan(0,nlev-1,1)*dlev2
    end if
    if ( fname .eq. "SALT" ) then
      if (isatt(field,"scale_factor")) then
        field = field * field@scale_factor 
      end if
      field_obs = fileidsobs->SALT
      if (isatt(field_obs,"scale_factor")) then
        field_obs = field_obs * field@scale_factor 
      end if

      field_obs = where(field_obs .lt. -50. .or. field_obs .gt. 1.e10, field_obs@_FillValue,field_obs)
      field_diff = field
      if (dimsizes(z_t) .ne. dimsizes(field_obs&$field_obs!1$)) then
        ind_z_obs = ind_nearest_coord(z_t*1000.,field_obs&$field_obs!1$,0)
;; only want the first 6 basin regions from the field_obs
        field_diff = field - field_obs(0:6,ind_z_obs,:)
      else
        field_diff = field - field_obs(0:6,:,:)
      end if	

      units = "psu"
      dmin  =  30.0
      dmax  =  38.0
      dmin2 =  -2.0
      dmax2 =   2.0
      dlev = (dmax-dmin)/(nlev-1) 
      lev  = dmin + ispan(0,nlev-1,1)*dlev
      dlev2 = (dmax2-dmin2)/(nlev-1) 
      lev2  = dmin2 + ispan(0,nlev-1,1)*dlev2
    end if
    if ( fname .eq. "IAGE" ) then
      units = "year"
      dmin = min(field)
      dmax = max(field)
      if ( dmax-dmin .le. 20. ) then
        dlev = 20. / (nlev-1)
      else if (dmax-dmin .le.   50.) then
        dlev =   50. / (nlev-1)
      else if ( dmax-dmin .le.  100. ) then 
        dlev =  100. / (nlev-1)
      else if (dmax-dmin .le.  500. ) then
        dlev =  500. / (nlev-1)
      else if ( dmax-dmin .le. 1000. ) then
        dlev = 1000. / (nlev-1)
      else if (dmax-dmin .le. 5000.) then
        dlev = 5000. / (nlev-1)
      else 
        dlev = (dmax - dmin) / (nlev-1)
      end if
      end if
      end if
      end if
      end if
      end if
      dmin = tointeger(dmin/dlev)*dlev
      if ( dmin .lt. 0. ) then
        dmin = dmin - dlev
      end if
      lev  = dmin + ispan(0,nlev-1,1)*dlev
    end if
    if ( fname .eq. "KAPPA_ISOP"  .or. \
      fname .eq. "KAPPA_THIC" ) then
      units = "m~S~2~N~ s~S~-1~N~"
      field = field / 1.0e4
      dlev = 99999.
      lev = (/   0.,  20.,  40.,  60.,   80.,  100.,  200.,  300.,  400.,  500., \
      600., 700., 800., 900., 1000., 1200., 1400., 1600., 1800., 2000., \
      3000. /)
    end if
    print( " plotting zonal average of " + fname )

    do m=0, n_reg-1

      ;wks = gsn_open_wks("x11",fname + "_" + region_names(m) +"_za")
      wks = gsn_open_wks(img_format,fname + "_" + region_names(m) +"_za")
      gsn_define_colormap(wks,"table42")
      case_info = fname+" ZONAL-AVE ("+region_names(m)+") " \
      + case_number + " " + time_info

      opt = True
      if ( fname .eq. "TEMP" .or. \
        fname .eq. "SALT" ) then
        opt@do_panel = True
      else 
        opt@do_panel = False
      end if

;; field now has only 1 dimension 
      plot1 = yz_plot(wks,  field(region_index(m),:,:), lat_t, z_t, case_info, \
      missing, units, dlev, lev, coltab, opt)

      if (opt@do_panel) then
        case_info = "(MODEL - OBS)"

        plot2 = yz_plot(wks, field_diff(region_index(m),:,:), lat_t, z_t, case_info, \
        missing, units, dlev2, lev2, coltab, opt)
        panel_res = True
        panel_res@gsnMaximize = True
        panel_res@gsnPaperOrientation = "portrait"

        gsn_panel(wks,(/plot1,plot2/),(/2,1/),panel_res)
      end if
    end do
    delete([/field,lev/])
    if (isvar("lev2")) then
      delete(lev2)
    end if
    if (isvar("field_diff")) then
      delete(field_diff)
    end if   
  end do

end
