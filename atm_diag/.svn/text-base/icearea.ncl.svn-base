;************************************************************
; Mark Stevens
; compute area of seaice in km^2 x 10^6 from seaice fraction 
; for each hemisphere of regular lat/lon grid

undef("iceareaFIX")
function iceareaFIX (icefrac[*][*]:numeric,hem:integer) 
begin
; icearea is the fractional sea ice area (0.0-1.0)
; icefrac first dimension is latitude, second is longitude
; hem = 0 (SH), 1 (NH)

if (.not.isatt(icefrac,"_FillValue")) then
  icefrac@_FillValue = getFillValue(icefrac)
end if 
lat = icefrac&lat
nlat = dimsizes(lat)
lon = icefrac&lon
nlon = dimsizes(lon)

RE = 6.37122e3             ; radius of earth in km
pi = acos(-1.0)
area = 4.*pi*RE^2          ; surface area of Earth 
d2r = pi/180.0             ; convert degrees to radians

if (typeof(lat) .eq. "double") then
  wgt = doubletofloat(NormCosWgtGlobe(lat))
else
  wgt = NormCosWgtGlobe(lat)
end if
tsum = sum(wgt)            ; sum of all weights
nwgt = wgt/tsum            ; frac of sphere of each lat band
boxarea = area*nwgt/nlon   ; area of each grid box (lat) in km^2
hemarea = new(nlat,float)

if (hem .eq. 0) then       ; Southern Hemisphere
  do j = 0, nlat/2-1 
    hemarea(j) =  sum(boxarea(j)*icefrac(j,:))
  end do
else                       ; Northern Hemisphere
  do j = nlat/2, nlat-1 
    hemarea(j) =  sum(boxarea(j)*icefrac(j,:))
  end do
end if
icearea = sum(hemarea)/1.e6

return(icearea)      ; return area of ice km^2 x 10^6 
end

;************************************************************
; Mark Stevens
; compute area of seaice in km^2 x 10^6 from seaice fraction 
; for each hemisphere of gaussian grid

undef("iceareaGAU")
function iceareaGAU (icefrac[*][*]:numeric,hem:integer) 
begin
; icearea is the fractional sea ice area (0.0-1.0)
; icefrac first dimension is latitude, second is longitude
; hem = 0 (SH), 1 (NH)

if (.not.isatt(icefrac,"_FillValue")) then
  icefrac@_FillValue = getFillValue(icefrac)
end if 
lat = icefrac&lat
nlat = dimsizes(lat)
lon = icefrac&lon
nlon = dimsizes(lon)

RE = 6.37122e3            ; radius of earth in km
pi = acos(-1.0)
area = 4.*pi*RE^2         ; surface area of Earth 

gw = latGauWgt(nlat,"lat","gaussian weights","none")
tsum = sum(gw)            ; sum of all weights
nwgt = gw/tsum            ; frac of sphere of each lat band
boxarea = area*nwgt/nlon  ; area of each grid box (lat) in km^2
hemarea = new(nlat,float)

if (hem .eq. 0) then         ; Southern Hemisphere
  do j = 0, nlat/2-1 
    hemarea(j) =  sum(boxarea(j)*icefrac(j,:))
  end do
else
  do j = nlat/2, nlat-1 
    hemarea(j) =  sum(boxarea(j)*icefrac(j,:))
  end do
end if
icearea = sum(hemarea)/1.e6

return(icearea)      ; return area of ice km^2 x 10^6 
end

