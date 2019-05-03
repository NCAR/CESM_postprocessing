load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  print( " plotting SALINITY at "+ n_depth + " depth levels")

  fileid = addfile(file_netcdf,"r")

  ocn_comp = getenv("OCN_COMP")
  if (ocn_comp.eq."MOM") then
    salt = fileid->salt
    delete(salt&xh)
    delete(salt&yh)
    dout_s_root = getenv("DOUT_S_ROOT")
    ocn_geo_file = addfile(dout_s_root+"/ocn/hist/ocean_geometry.nc","r")
    tlon = ocn_geo_file->geolon
    tlat = ocn_geo_file->geolat
  else ; POP
    salt = fileid->SALT
    tlon = fileid->TLONG
    tlat = fileid->TLAT
  end if

  if (isatt(salt,"scale_factor")) then
    salt = salt@scale_factor * where(salt .gt. -10 .and. salt .lt. 1e10,salt,salt@_FillValue)
  end if
  if (isatt(salt,"_FillValue"))
    missing = salt@_FillValue
  else
    missing = 1e30
  end if
  units = salt@units

  size = dimsizes(tlon)
  nx = size(1)
  ny = size(0)

  if (ocn_comp.eq."MOM") then
    diagobsroot = getenv("DIAGOBSROOT")
    resolution = getenv("RESOLUTION")
    gridInfoFilePath = diagobsroot+"/omwg/za_grids/"+resolution+"_grid_info.nc"
    gridInfoFile = addfile(gridInfoFilePath,"r")
    kmt = gridInfoFile->KMT
    region_mask = kmt ; TODO: fix_this !!!
    tarea = gridInfoFile->TAREA
    z_t = fileid->z_l
    nz = dimsizes(z_t)
  else ; POP
    kmt = fileid->KMT
    region_mask = fileid->REGION_MASK
    tarea = fileid->TAREA
    z_t = fileid->z_t
    nz = dimsizes(z_t)
    z_t = z_t / 100.
  end if

  fileid_obs = addfile(file_S_obs,"r")
  salt_obs = fileid_obs->SALT
  if (isatt(salt_obs,"scale_factor")) then
    salt_obs = salt_obs@scale_factor * where(salt_obs .gt. -10 .and. salt_obs .lt. 1e10,salt_obs,salt_obs@_FillValue)
  end if
  delete(fileid_obs)

  do l=0, n_depth-1

    dep =  depth(l)
    min_diff = min(abs(z_t - dep))
    klev_arr = ind(abs(dep-z_t) .eq. min_diff) ; if 2 depth are equally distant you get an array
    klev = klev_arr(0)
    delete(klev_arr)
    zdep = z_t(klev)

    if (dimsizes(dimsizes(salt)) .eq. 4) then
      field = salt(0,klev,:,:)
    else
      field = salt(klev,:,:)
    end if
    if (dimsizes(dimsizes(salt_obs)) .eq. 4) then
      field_obs = salt_obs(0,klev,:,:)
    else
      field_obs = salt_obs(klev,:,:)
    end if
    field_diff = field
    field_diff = field - field_obs
    nlev = 21
    if ( depth(l) .le. 800 ) then
      dmin  =  28.0
      dmax  =  38.0
      dmin2 = -2.0
      dmax2 =  2.0
    else
      dmin  = 33.0
      dmax  = 37.0
      dmin2 = -0.8
      dmax2 =  0.8
    end if
    dlev = (dmax-dmin)/(nlev-1)
    lev  = dmin + ispan(0,nlev-1,1)*dlev
    dlev2 = (dmax2-dmin2)/(nlev-1)
    lev2  = dmin2 + ispan(0,nlev-1,1)*dlev2
    depstr = sprintf("%.0f",dep)
    zdepstr = sprintf("%6.1fm",zdep)
    case_info = "SALINITY at z="+zdepstr+", " + case_number + " " + time_info 

    ;wks = gsn_open_wks("x11","SALT"+depstr)
    wks = gsn_open_wks(img_format,"SALT"+depstr)
    gsn_define_colormap(wks,"table42")

    coltab = new(nlev + 1,"integer")
    coltab(0) = 1
    color1 = 2 
    coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
    coltab(0) = 0

    opt = True
    opt@charsize = 0.9
    opt@landcolor = lndcolor
    opt@xrange = (/ xr0,xr1/)
    opt@yrange = (/ yr0,yr1/)
    opt@do_panel = True

    plot1 = contour_plot(wks, field, tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev, lev, coltab, opt)
    case_info = "(MODEL - LEVITUS/PHC2)"
    plot2 = contour_plot(wks, field_diff, tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev2, lev2, coltab, opt)
    
    gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)

  end do

end
