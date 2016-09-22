load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  print( " plotting Arctic SALINITY at "+ n_depth + " depth levels")

  fileid_1 = addfile(file_netcdf,"r")

; 
; speed up processing by only using data in the range of the plot output
; a loop is needed in order to find the smallest y index in each row 
;
  tlat = fileid_1->TLAT
  y_min = dimsizes(tlat(:,0)) - 1
  do i = 0, dimsizes(tlat(0,:)) - 1
    ytmp =  max(ind(tlat(:,i) .le. 60))
    if (ytmp .lt. y_min) then
      y_min = ytmp
    end if
  end do
  delete(tlat)
  tlat = fileid_1->TLAT(y_min:,:)
  tlon = fileid_1->TLONG(y_min:,:)

  salt = fileid_1->SALT(0,:,y_min:,:)
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
  ulon = fileid_1->ULONG
  ulat = fileid_1->ULAT
  kmt = fileid_1->KMT(y_min:,:)
  kmu = fileid_1->KMU(y_min:,:)
  region_mask = fileid_1->REGION_MASK(y_min:,:)
  tarea = fileid_1->TAREA(y_min:,:)
  uarea = fileid_1->UAREA(y_min:,:)
  angle = fileid_1->ANGLE(y_min:,:)
  z_t = fileid_1->z_t
  nz = dimsizes(z_t)
  z_t = z_t / 100.

  fileid_2 = addfile(cntrl_netcdf,"r")
  salt_2 = fileid_2->SALT

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
    if (dimsizes(dimsizes(salt_2)) .eq. 4) then
      field_2 = salt_2(0,klev,y_min:,:)
    else
      field_2 = salt_2(klev,y_min:,:)
    end if
    field_diff = field
    field_diff = field - field_2
    nlev = 21
    if ( depth(l) .le. 180 ) then
      dmin  =  28.0
      dmax  =  38.0
      dmin2 = -5.0
      dmax2 =  5.0
    else if (depth(l) .le. 500) then
      dmin  = 32.0
      dmax  = 37.0
      dmin2 = -3.0
      dmax2 =  3.0
    else 
      dmin  = 34.0
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

;   wks = gsn_open_wks("x11","SALT"+depstr)
    wks = gsn_open_wks(img_format,"Arctic_SALT"+depstr)
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
    opt@polar = "north"
    opt@nomean = 1

    plot1 = contour_plot(wks, field, tlon, tlat, kmt, region_mask, tarea, case_info, \
    missing, units, dlev, lev, coltab, opt)

    case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info
    plot2 = contour_plot(wks, field_diff, tlon, tlat, kmt, region_mask, tarea, case_info_diff, \
    missing, units, dlev2, lev2, coltab, opt)
    
    gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)

  end do

end
