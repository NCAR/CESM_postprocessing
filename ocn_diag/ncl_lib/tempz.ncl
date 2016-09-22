load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  print( " plotting TEMP at "+ n_depth + " depth levels")

  fileid = addfile(file_netcdf,"r")
  temp = fileid->TEMP
  if (isatt(temp,"_FillValue"))
    missing = temp@_FillValue
  else
    missing = 1e30
  end if
  units = temp@units
  tlon = fileid->TLONG
  tlat = fileid->TLAT
  size = dimsizes(tlon)
  nx = size(1)
  ny = size(0)
  ulon = fileid->ULONG
  ulat = fileid->ULAT
  kmt = fileid->KMT
  kmu = fileid->KMU
  region_mask = fileid->REGION_MASK
  tarea = fileid->TAREA
  uarea = fileid->UAREA
  angle = fileid->ANGLE
  z_t = fileid->z_t
  nz = dimsizes(z_t)
  z_t = z_t / 100.

  fileid_obs = addfile(file_T_obs,"r")
  temp_obs = fileid_obs->TEMP
  delete(fileid_obs)

  do l=0, n_depth-1

    dep =  depth(l)
    min_diff = min(abs(z_t - dep))
    klev_arr = ind(abs(dep-z_t) .eq. min_diff) ; if 2 depth are equally distant you get an array
    klev = klev_arr(0)
    delete(klev_arr)
    zdep = z_t(klev)

    if (dimsizes(dimsizes(temp)) .eq. 4) then
      field = temp(0,klev,:,:)
    else
      field = temp(klev,:,:)
    end if
    if (dimsizes(dimsizes(temp_obs)) .eq. 4) then
      field_obs = temp_obs(0,klev,:,:)
    else
      field_obs = temp_obs(klev,:,:)
    end if
    field_diff = field
    field_diff = field - field_obs
    nlev = 21
    if ( depth(l) .le. 1800 ) then
      dmin  =  -4.0
      dmax  =  36.0
      dmin2 = -10.0
      dmax2 =  10.0
    else
      dmin  = -2.0
      dmax  =  8.0
      dmin2 = -5.0
      dmax2 =  5.0
    end if
    dlev = (dmax-dmin)/(nlev-1)
    lev  = dmin + ispan(0,nlev-1,1)*dlev
    dlev2 = (dmax2-dmin2)/(nlev-1)
    lev2  = dmin2 + ispan(0,nlev-1,1)*dlev2
    depstr = sprintf("%.0f",dep)
    zdepstr = sprintf("%6.1fm",zdep)
    case_info = "TEMP at z="+zdepstr+", " + case_number + " " + time_info 

    ;wks = gsn_open_wks("x11","TEMP"+depstr)
    wks = gsn_open_wks(img_format,"TEMP"+depstr)
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
