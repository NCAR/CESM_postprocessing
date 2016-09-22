load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/yz_plot.ncl"

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
  region_names = (/ "GLO", "ATL", "PAC", "IND", "SOU" /)

  n_reg = dimsizes(region_index)

  field_name = [/ "TEMP",  "SALT"  /] 

  fileid_1 = addfile(file_netcdf,"r")

  days_in_norm_year = fileid_1->days_in_norm_year
  sflux_factor = fileid_1->sflux_factor
  salinity_factor = fileid_1->salinity_factor
  rho_sw = fileid_1->rho_sw * 1000.0
  l_f = fileid_1->latent_heat_fusion / 1e4
  secperday  = 86400.
  secperyear = days_in_norm_year * secperday
  rho_fw = 1.0
  rho_fw = rho_fw * 1000.

  fileid_1 = addfile(file_netcdf_za,"r")
  fileid_2 = addfile(cntrl_netcdf_za,"r")

  if (isfilevar(fileid_1,"IAGE")) then
    ListPush(field_name,"IAGE")
  end if
  if (isfilevar(fileid_1,"KAPPA_ISOP")) then
    ListPush(field_name,"KAPPA_ISOP")
  end if
  if (isfilevar(fileid_1,"KAPPA_THIC")) then
    ListPush(field_name,"KAPPA_THIC")
  end if

  n_fields = ListCount(field_name)

  print( " the number of fields to be processed is " + n_fields)

  lat_t = fileid_1->lat_t
  z_t = fileid_1->z_t
  z_t = z_t / 1.0e5

  coltab = new(nlev + 1,"integer")
  coltab(0) = 1
  color1 = 2 
  coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
  coltab(0) = 0

  do n=0,n_fields-1 

    fname = ListPop(field_name)
    if (dimsizes(getfilevardimsizes(fileid_1,fname)) .eq. 4) then
      field_1 = fileid_1->$fname$(0,:,:,:)
    else
      field_1 = fileid_1->$fname$(:,:,:)
    end if
    if (dimsizes(getfilevardimsizes(fileid_1,fname)) .eq. 4) then
      field_2 = fileid_2->$fname$(0,:,:,:)
    else
      field_2 = fileid_2->$fname$(:,:,:)
    end if

    if ( fname .eq. "TEMP" ) then
      units = "~S~o~N~C"
      dmin  =  -4.0
      dmax  =  36.0
      dmin2 = -5.0
      dmax2 =  5.0
    end if
    if ( fname .eq. "SALT" ) then
      if (isatt(field_1,"scale_factor")) then
        field_1 = field_1 * field_1@scale_factor 
      end if
      if (isatt(field_2,"scale_factor")) then
        field_2 = field_2 * field_2@scale_factor 
      end if
      units = "psu"
      dmin  =  30.0
      dmax  =  38.0
      dmin2 =  -1.0
      dmax2 =   1.0
    end if
    if ( fname .eq. "IAGE" ) then
      units = "year"
      dmin = min(field_1)
      dmax = max(field_1)
      if ( dmax-dmin .le. 20. ) then
        dlev = 20. / (nlev-1)
        dmin2 =  -5.0
        dmax2 =   5.0
      else if (dmax-dmin .le.   50.) then
        dlev =   50. / (nlev-1)
        dmin2 =  -10.0
        dmax2 =   10.0
      else if ( dmax-dmin .le.  100. ) then 
        dlev =  100. / (nlev-1)
        dmin2 =  -20.0
        dmax2 =   20.0
      else if (dmax-dmin .le.  500. ) then
        dlev =  500. / (nlev-1)
        dmin2 =  -80.0
        dmax2 =   80.0
      else if ( dmax-dmin .le. 1000. ) then
        dlev = 1000. / (nlev-1)
        dmin2 =  -100.0
        dmax2 =   100.0
      else if (dmax-dmin .le. 5000.) then
        dlev = 5000. / (nlev-1)
        dmin2 =  -400.0
        dmax2 =   400.0
      else
        dlev = (dmax - dmin) / (nlev-1)
        dmin2 = dmin
        dmax2 = dmax
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
      field_1 = field_1 / 1.0e4
      field_2 = field_2 / 1.0e4
      dlev = 99999.
      lev = (/   0.,  20.,  40.,  60.,   80.,  100.,  200.,  300.,  400.,  500., \
      600., 700., 800., 900., 1000., 1200., 1400., 1600., 1800., 2000., \
      3000. /)
      dmin2 = -500.
      dmax2 =  500.
    else if (fname .ne. "IAGE") then
      dlev = (dmax-dmin)/(nlev-1) 
      lev  = dmin + ispan(0,nlev-1,1)*dlev
    end if
  end if
  dlev2 = (dmax2-dmin2)/(nlev-1) 
  lev2  = dmin2 + ispan(0,nlev-1,1)*dlev2
  field_diff = field_1
  field_diff = field_diff - field_2

  print( " plotting zonal average of " + fname )

  do m=0, n_reg-1

    ;wks = gsn_open_wks("x11",fname + "_" + region_names(m) +"_za")
    wks = gsn_open_wks(img_format,fname + "_" + region_names(m) +"_za")
    gsn_define_colormap(wks,"table42")
    case_info = fname+" ZONAL-AVE ("+region_names(m)+") " \
    + case_number + " " + time_info

    opt = True
    opt@do_panel = True

    plot1 = yz_plot(wks,  field_1(region_index(m),:,:), lat_t, z_t, case_info, \
    missing, units, dlev, lev, coltab, opt)

    if (opt@do_panel) then

      case_info = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info

      plot2 = yz_plot(wks, field_diff(region_index(m),:,:), lat_t, z_t, case_info, \
      missing, units, dlev2, lev2, coltab, opt)
      panel_res = True
      panel_res@gsnMaximize = True
      panel_res@gsnPaperOrientation = "portrait"

      gsn_panel(wks,(/plot1,plot2/),(/2,1/),panel_res)
    end if
  end do
  delete([/field_1,field_2,lev,lev2,field_diff/])

end do

end
