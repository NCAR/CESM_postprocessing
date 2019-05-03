load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  print( " plotting Antarctic SALINITY at "+ n_depth + " depth levels")

  fileid = addfile(file_netcdf,"r")
; 
; speed up processing by only using data in the range of the plot output
; a loop is needed in order to find the smallest y index in each row 
;

  ocn_comp = getenv("OCN_COMP")
  if (ocn_comp.eq."MOM") then
    dout_s_root = getenv("DOUT_S_ROOT")
    ocn_geo_file = addfile(dout_s_root+"/ocn/hist/ocean_geometry.nc","r")
    tlat = ocn_geo_file->geolat
  else ; POP
    tlat = fileid->TLAT
  end if

  y_max = 0
  do i = 0, dimsizes(tlat(0,:)) - 1
    ytmp =  min(ind(tlat(:,i) .ge. -50))
    if (ytmp .gt. y_max) then
      y_max = ytmp
    end if
  end do
  delete(tlat)

  if (ocn_comp.eq."MOM") then
    tlat = ocn_geo_file->geolat(:y_max,:)
    tlon = ocn_geo_file->geolon(:y_max,:)
    salt = fileid->salt(0,:,:y_max,:)
    delete(salt&xh)
    delete(salt&yh)
  else ; POP
    tlat = fileid->TLAT(:y_max,:)
    tlon = fileid->TLONG(:y_max,:)
    salt = fileid->SALT(0,:,:y_max,:)
  end if

  if (isatt(salt,"_FillValue"))
    missing = salt@_FillValue
  else
    missing = 1e30
  end if
  if (isatt(salt,"scale_factor")) then
    salt = where(salt .gt. -10 .and. salt .lt. 1e10, salt, salt@_FillValue)
    salt = salt * salt@scale_factor
  end if
  units = salt@units
  size = dimsizes(tlon)
  nx = size(1)
  ny = size(0)

  if (ocn_comp.eq."MOM") then
    gridInfoFilePath = getenv("DIAGOBSROOT")+"/omwg/za_grids/"+getenv("RESOLUTION")+"_grid_info.nc"
    gridInfoFile = addfile(gridInfoFilePath,"r")
    kmt = gridInfoFile->KMT(:y_max,:)
    region_mask = gridInfoFile->KMT(:y_max,:) ; TODO: fix_this !!!
    tarea = gridInfoFile->TAREA(:y_max,:)
    z_t = fileid->z_l
    nz = dimsizes(z_t)
  else ; POP
    kmt = fileid->KMT(:y_max,:)
    region_mask = fileid->REGION_MASK(:y_max,:)
    tarea = fileid->TAREA(:y_max,:)
    z_t = fileid->z_t
    nz = dimsizes(z_t)
    z_t = z_t / 100.
  end if

  fileid_obs = addfile(file_S_obs,"r")
  salt_obs = fileid_obs->SALT

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
      field_obs = salt_obs(0,klev,:y_max,:)
    else
      field_obs = salt_obs(klev,:y_max,:)
    end if
    field_diff = field
    field_diff = field - field_obs
    nlev = 21
    if ( depth(l) .le. 180 ) then
      dmin  =  33.0
      dmax  =  36.0
      dmin2 = -2.0
      dmax2 =  2.0
    else if (depth(l) .le. 500) then
      dmin  = 33.0
      dmax  = 36.0
      dmin2 = -1.0
      dmax2 =  1.0
    else 
      dmin  = 33.0
      dmax  = 36.0
      dmin2 = -0.4
      dmax2 =  0.4
    end if
    end if
    dlev = (dmax-dmin)/(nlev-1)
    lev  = dmin + ispan(0,nlev-1,1)*dlev
    dlev2 = (dmax2-dmin2)/(nlev-1)
    lev2  = dmin2 + ispan(0,nlev-1,1)*dlev2

    depstr = sprintf("%.0f",dep)
    zdepstr = sprintf("%6.1fm",zdep)
    case_info = "SALINITY at z="+zdepstr+", " + case_number + " " + time_info 

    ;wks = gsn_open_wks("x11","SALT"+depstr)
    wks = gsn_open_wks(img_format,"Antarctic_SALT"+depstr)
    gsn_define_colormap(wks,"table42")

    coltab = new(nlev + 1,"integer")
    coltab(0) = 1
    color1 = 2 
    coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
    coltab(0) = 0
    units = "psu"

    opt = True
    opt@charsize = 0.9
    opt@landcolor = lndcolor
    opt@xrange = (/ xr0,xr1/)
    opt@yrange = (/ yr0,yr1/)
    opt@do_panel = True
    opt@polar = "south"
    opt@nomean = 1

    plot1 = contour_plot(wks, field, tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev, lev, coltab, opt)
    case_info = "(MODEL - LEVITUS/PHC2)"
    plot2 = contour_plot(wks, field_diff, tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev2, lev2, coltab, opt)
    
    gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)

  end do

end
