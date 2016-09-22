load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  print( " plotting SALINITY at "+ n_depth + " depth levels")

  fileid_1 = addfile(file_netcdf,"r")
  salt_1 = fileid_1->SALT
  if (isatt(salt_1,"_FillValue"))
    missing = salt_1@_FillValue
  else
    salt_1@_FillValue = default_fillvalue(typeof(salt_t))
    missing = salt_1@_FillValue
  end if
  if (isatt(salt_1,"scale_factor")) then
    salt_1 = salt_1@scale_factor * where(salt_1 .gt. -10 .and. salt_1 .lt. 1e10,salt_1,salt_1@_FillValue)
  end if
  units = "psu"

  tlon = fileid_1->TLONG
  tlat = fileid_1->TLAT
  size = dimsizes(tlon)
  nx = size(1)
  ny = size(0)
  ulon = fileid_1->ULONG
  ulat = fileid_1->ULAT
  kmt = fileid_1->KMT
  kmu = fileid_1->KMU
  region_mask = fileid_1->REGION_MASK
  tarea = fileid_1->TAREA
  uarea = fileid_1->UAREA
  angle = fileid_1->ANGLE
  z_t = fileid_1->z_t
  nz = dimsizes(z_t)
  z_t = z_t / 100.

  fileid_2 = addfile(cntrl_netcdf,"r")
  salt_2 = fileid_2->SALT
  if (isatt(salt_2,"scale_factor")) then
    salt_2 = salt_2@scale_factor * where(salt_2 .gt. -10 .and. salt_2 .lt. 1e10,salt_2,salt_2@_FillValue)
  end if
  delete(fileid_2)

  do l=0, n_depth-1
    dep =  depth(l)
    min_diff = min(abs(z_t - dep))
    klev_arr = ind(abs(dep-z_t) .eq. min_diff) ; if 2 depth are equally distant you get an array
    klev = klev_arr(0)
    delete(klev_arr)
    zdep = z_t(klev)

    if (dimsizes(dimsizes(salt_1)) .eq. 4) then
      field_1 = salt_1(0,klev,:,:)
    else
      field_1 = salt_1(klev,:,:)
    end if
    if (dimsizes(dimsizes(salt_2)) .eq. 4) then
      field_2 = salt_2(0,klev,:,:)
    else
      field_2 = salt_2(klev,:,:)
    end if
    field_diff = field_1
    field_diff = field_1 - field_2
    nlev = 21
    if ( depth(l) .le. 800 ) then
      dmin  =  28.0
      dmax  =  38.0
      dmin2 = -1.0
      dmax2 =  1.0
    else
      dmin  = 33.0
      dmax  = 37.0
      dmin2 = -0.4
      dmax2 =  0.4
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
    opt@contourline = 3
    opt@gsnRightStringParallelPosF = 1.2
    opt@cnLineLabelsOn = True

    plot1 = contour_plot(wks, field_1, tlon, tlat, kmt, region_mask, tarea, case_info, \
                         missing, units, dlev, lev, coltab, opt)
    case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info
    plot2 = contour_plot(wks, field_diff, tlon, tlat, kmt, region_mask, tarea, case_info_diff, \
                         missing, units, dlev2, lev2, coltab, opt)
    
    gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)

  end do

end
