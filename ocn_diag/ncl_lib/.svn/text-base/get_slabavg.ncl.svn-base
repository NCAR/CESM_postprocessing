;*************************************************************************
; PRO GET_SLABAVG
;
; This program computes regional averages for a given POP depth level.
;
; The regions are based on latitude, longitude, and ocean mask. 
;
; INPUT:
;       field   - the field (data) to be averaged (needs to be a 2 or 3d array)
;       lat     - the latitude of the field
;       lon     - the longitude of the field
;       tarea   - the area of each grid cell
;       k       - depth index of field
;       kmt	- ocean KMT array
;       [x0,x1] - longitude boundaries of region (0..360)
;       [y0,y1] - latitude boundaries of region  (-90..90)
;
; OUTPUT:
;       basin  - Area-weighted basin average value of field
;       abasin - Basin total area for this depth level
;
; OPTIONS:
;       itot    - if 1 then return the total instead of an average
;       missing - values larger than this are assumed to be missing
;               - the default missing value is set to 1.e29
;
; NOTES:
;       This routine is based on M. Holland's get_avg_aobas_60lev
;
;***************************************************************************************
;

procedure get_slabavg (field,lat,lon,tarea,k,kmt,x0,x1,y0,y1,itot,missing,\
                       basinavg : float, basinarea : float)

begin

  ; get dimensions of field
  fsize = dimsizes(field)
  if (dimsizes(fsize) .eq. 3) then
    jdim = fsize(1)
    idim = fsize(2)
    field2d = field(k,:,:) 
  else
    jdim = fsize(0)
    idim = fsize(1)
    field2d = field
  end if 

  lsize = dimsizes(lat)
  if (dimsizes(lsize) .eq. 1) then
    ;   get a 2d lon and lat
    lon0 = conform_dims((/jdim,idim/),lon,1)
    lat0 = conform_dims((/jdim,idim/),lat,0)
  else if (dimsizes(lsize) .eq. 2) then
    lon0 = lon
    lat0 = lat
    lon0 = where(lon0 .lt. 0,lon0 + 360,lon0)
  else
    print ("Can not handle dimensions of lat")
    return
  end if
  end if
  lon1d = ndtooned(lon0)
  lat1d = ndtooned(lat0)
  kmt1d = ndtooned(kmt)
  tarea1d = ndtooned(tarea)
  field1d = ndtooned(field)
  valid1d = ind(lat1d .ge. y0 .and. lat1d .le. y1.and. \
  lon1d .ge. x0 .and. lon1d .le. x1 .and. kmt1d .gt. k)
  basinarea = 0.0
  if (.not. any(ismissing(valid1d))) then
    basinarea = tofloat(sum(tarea1d(valid1d)))
    basinavg = tofloat(sum(field1d(valid1d) * tarea1d(valid1d)))
  end if

  if (basinarea .gt. 0) then
    if (itot .eq. 0) then
      basinavg = basinavg / basinarea
    end if
  else
    basinarea = 0.0
    basinavg = missing
    print("no good values found")
  end if

end

