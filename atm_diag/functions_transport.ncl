; transport_funcs.ncl
; functions for computing implied ocean, freshwater, atmospheric transports
; written by Mark Stevens March 2001
;***************************************************************************

function ocean_mask (oroi[*][*]:numeric)

; creates mask file for the pacific, atlantic and indian ocean basins
; oro: orography data array (lat,lon) 
; assumes that lat and lon are attached to oro as coordinates, 
; and oro has values ocean: 0, land: 1, seaice: 2

begin

 if (typeof(oroi) .eq."double") then
   oro = dble2flt(oroi)
 else
   oro = oroi
 end if 



 lat = oro&lat
 lon = oro&lon
 nlat = dimsizes(lat)
 nlon = dimsizes(lon)

; make 2D mask array for ocean grid points
 basins_mask = oro
 if (.not.isatt(basins_mask, "_FillValue" ))  then ; since oro has no _FillValue 
   basins_mask@_FillValue = -999.0 ; 
 end if
 basins_mask = basins_mask@_FillValue 
 basins_mask@long_name = "(1)pacific (2)atlantic (3)indian"

; Pacific ocean basin
 do j = 0, nlat-1
   do i = 0, nlon-1
     if (oro(j,i).lt.0.5) then
       if ((lon(i).gt.100.0 .and. lon(i).lt.260.0 .and. \
          lat(j).lt. 65.0 .and. lat(j).gt. 15.0) .or. \
         (lon(i).gt.100.0 .and. lon(i).lt.275.0 .and. \
          lat(j).le. 15.0 .and. lat(j).gt. 10.0) .or. \
         (lon(i).gt.100.0 .and. lon(i).lt.290.0 .and. \
          lat(j).le. 10.0 .and. lat(j).gt. -5.0) .or. \
         (lon(i).ge.130.0 .and. lon(i).le.290.0 .and. \
          lat(j).le. -5.0)) then
         basins_mask(j,i) = 1       ; pacific
       end if
     end if
   end do
 end do

; Atlantic ocean basin 
 do j = 0, nlat-1
   do i = 0, nlon-1
     if (oro(j,i).lt.0.5) then
       if ((lon(i).gt.290.0 .and. lon(i).lt.360.0 .and. \
          lat(j).le. 65.0 .and. lat(j).gt. 45.0) .or. \
         (lon(i).ge.  0.0 .and. lon(i).lt. 10.0 .and. \
          lat(j).le. 65.0 .and. lat(j).gt. 45.0) .or. \
         (lon(i).gt.260.0 .and. lon(i).lt.360.0 .and. \
          lat(j).le. 45.0 .and. lat(j).gt. 40.0) .or. \
         (lon(i).gt.260.0 .and. lon(i).lt.355.0 .and. \
          lat(j).le. 40.0 .and. lat(j).gt. 15.0) .or. \
         (lon(i).gt.275.0 .and. lon(i).lt.360.0 .and. \
          lat(j).le. 15.0 .and. lat(j).gt. 10.0) .or. \
         (lon(i).ge.  0.0 .and. lon(i).lt. 25.0 .and. \
          lat(j).le. 15.0 .and. lat(j).gt. 10.0) .or. \
         (lon(i).gt.290.0 .and. lon(i).lt.360.0 .and. \
          lat(j).le. 10.0) .or. \
         (lon(i).ge.  0.0 .and. lon(i).lt. 25.0 .and. \
          lat(j).le. 10.0)) then
         basins_mask(j,i) = 2      ; atlantic
       end if
     end if
   end do
 end do

; Indian ocean basin
 do j = 0, nlat-1
   do i = 0, nlon-1
     if (oro(j,i).lt.0.5) then
       if ((lon(i).gt.60.0 .and. lon(i).lt.100.0 .and. \
          lat(j).lt. 25.0 .and. lat(j).gt. 20.0) .or. \
         (lon(i).gt. 45.0 .and. lon(i).lt.100.0 .and. \
          lat(j).le. 20.0 .and. lat(j).gt.  0.0) .or. \
         (lon(i).ge. 25.0 .and. lon(i).lt.100.0 .and. \
          lat(j).le.  0.0 .and. lat(j).gt. -5.0) .or. \
         (lon(i).ge. 25.0 .and. lon(i).le.130.0 .and. \
          lat(j).le. -5.0)) then
         basins_mask(j,i) = 3     ; indian
       end if
     end if
   end do
 end do

 return (basins_mask)     ; returns 2D mask array (lat,lon)
end

;*****************************************************************************
; calculate the ocean heat transport for models

function oht_model (gwi[*]:numeric,oroi[*][*]:numeric,fsnsi[*][*]:numeric, \
                   flnsi[*][*]:numeric,shfli[*][*]:numeric,lhfli[*][*]:numeric)

; gw  : gaussian weights (lat)
; oro : orography data array (lat,lon)
; requires the lat and lon are attached coordinates of oro 
; and that oro and the following variables are 2D arrays (lat,lon).
; fsns: net shortwave solar flux at surface
; flns: net longwave solar flux at surface
; shfl: sensible heat flux at surface 
; lhfl: latent heat flux at surface 

begin

 if (typeof(gwi).eq."double") then
   gw = dble2flt(gwi)
 else
   gw = gwi
 end if
 if (typeof(oroi).eq."double") then
   oro = dble2flt(oroi)
 else
   oro = oroi
 end if
 if (typeof(fsnsi).eq."double") then
   fsns = dble2flt(fsnsi)
 else
   fsns = fsnsi
 end if
 if (typeof(flnsi).eq."double") then
   flns = dble2flt(flnsi)
 else
   flns = flnsi
 end if
 if (typeof(shfli).eq."double") then
   shfl = dble2flt(shfli)
 else
   shfl = shfli
 end if
 if (typeof(lhfli).eq."double") then
   lhfl = dble2flt(lhfli)
 else
   lhfl = lhfli
 end if

; constants
 pi = 3.14159265
 re = 6.371e6            ; radius of earth
 coef = re^2/1.e15       ; scaled by PW
 heat_storage = 0.3      ; W/m^2 adjustment for ocean heat storage 

 nlat = dimsizes(oro(:,0))
 nlon = dimsizes(oro(0,:))
 dlon = 2.*pi/nlon       ; dlon in radians
 lat = oro&lat 
 lat&lat = lat
 i65n = ind(lat.eq.lat({65}))
 i65s = ind(lat.eq.lat({-65}))

; get the mask for the ocean basins
 basins_mask = ocean_mask(oro)    ; returns 2D array(lat,lon) 
; compute net surface energy flux
 netflux = fsns
 netflux = (/fsns-flns-shfl-lhfl-heat_storage/)

; compute the net flux for the basins
 netflux_basin = new((/3,nlat,nlon/),float) 
 netflux_basin(0,:,:) = mask(netflux,basins_mask,1)  ; pacific
 netflux_basin(1,:,:) = mask(netflux,basins_mask,2)  ; atlantic
 netflux_basin(2,:,:) = mask(netflux,basins_mask,3)  ; indian

; sum flux over the longitudes in each basin
 heatflux = new((/3,nlat/),float) 
 heatflux = dim_sum(netflux_basin)  

; compute implied heat transport in each basin
 oft = new((/4,nlat/),float)
 oft!0 = "basin number"   ; 0:pacific, 1:atlantic, 2:indian, 3:total
 oft!1 = "lat"
 oft&lat = lat

 do n = 0, 2
   do j = i65n, i65s, 1      ;start sum at most northern point 
     oft(n,j) = -coef*dlon*sum(heatflux(n,j:i65n)*gw(j:i65n))
   end do
 end do

; compute total implied ocean heat transport at each latitude
; as the sum over the basins at that latitude
 do j = i65s, i65n
   oft(3,j) = sum(oft(:,j))
 end do

 return(oft)     ; 2D array(4,lat)
end

;**************************************************************************
; calculate the heat transport for the entire surface

function ht_surface (gwi[*]:numeric,oroi[*][*]:numeric,fsnsi[*][*]:numeric, \
   flnsi[*][*]:numeric,shfli[*][*]:numeric,lhfli[*][*]:numeric,adjust:logical)

; gw  : gaussian weights (lat)
; oro : orography
; fsns: net shortwave solar flux at surface
; flns: net longwave solar flux at surface
; shfl: sensible heat flux at surface 
; lhfl: latent heat flux at surface 
; adjust: logical switch for applying adjustment

begin

 if (typeof(gwi).eq."double") then
   gw = dble2flt(gwi)
 else
   gw = gwi
 end if
 if (typeof(oroi).eq."double") then
   oro = dble2flt(oroi)
 else
   oro = oroi
 end if
 if (typeof(fsnsi).eq."double") then
   fsns = dble2flt(fsnsi)
 else
   fsns = fsnsi
 end if
 if (typeof(flnsi).eq."double") then
   flns = dble2flt(flnsi)
 else
   flns = flnsi
 end if
 if (typeof(shfli).eq."double") then
   shfl = dble2flt(shfli)
 else
   shfl = shfli
 end if
 if (typeof(lhfli).eq."double") then
   lhfl = dble2flt(lhfli)
 else
   lhfl = lhfli
 end if

; constants
 pi = 3.14159265
 re = 6.371e6            ; radius of earth
 coef = re^2/1.e15       ; scaled by PW
 heat_storage = 0.3      ; W/m^2 adjustment for ocean heat storage 

 nlat = dimsizes(oro(:,0))
 nlon = dimsizes(oro(0,:))
 dlon = 2.*pi/nlon       ; dlon in radians
 lat = oro&lat 
 lat&lat = lat

; compute net surface energy flux
 tmp = fsns
 tmp = (/fsns-flns-shfl-lhfl/)   ; (lat,lon) 

; zonally average entire surface 
 heatflux = dim_avg(tmp)         ; (lat) 

; global mean
 if (adjust) then
   gbl = sum(heatflux*gw)/sum(gw)
 end if

 ht = new(nlat,float)
 ht!0 = "lat"
 ht&lat = lat

 do j = nlat-1,0, 1      ;start sum at most northern point 
   if (adjust) then
     ht(j) = -coef*2.*pi*sum((heatflux(j:nlat-1)-gbl)*gw(j:nlat-1))
   else
     ht(j) = -coef*2.*pi*sum(heatflux(j:nlat-1)*gw(j:nlat-1))
   end if
 end do

 return(ht)     ; 1D array(lat)
end

;***************************************************************************
; calculate the ocean freshwater transport for models

function oft_model (gwi[*]:numeric,oroi[*][*]:numeric,precci[*][*]:numeric, \
                    precli[*][*]:numeric,qflxi[*][*]:numeric)

; gw  : gaussian weights (lat)
; oro : orography data array (lat,lon)
; requires the lat and lon are attached coordinates of oro 
; and that oro and the following variables are 2D arrays (lat,lon).
; precc : convective precipitation (m/s)
; precl : large-scale precipitation (m/s)
; qflx  : surface water flux (kg/s)

begin

 if (typeof(gwi).eq."double") then
   gw = dble2flt(gwi)
 else
   gw = gwi
 end if
 if (typeof(oroi).eq."double") then
   oro = dble2flt(oroi)
 else
   oro = oroi
 end if
 if (typeof(precci).eq."double") then
   precc = dble2flt(precci)
 else
   precc = precci
 end if
 if (typeof(precli).eq."double") then
   precl = dble2flt(precli)
 else
   precl = precli
 end if
 if (typeof(qflxi).eq."double") then
   qflx = dble2flt(qflxi)
 else
   qflx = qflxi 
 end if

; constants
 pi = 3.14159265
 re = 6.371e6            ; radius of earth
 coef = re^2/1.e6        ; scaled for Sverdrups 

 nlat = dimsizes(oro(:,0))
 nlon = dimsizes(oro(0,:))
 dlon = 2.*pi/nlon       ; dlon in radians
 lat = oro&lat 
 lat&lat = lat
 i65n = ind(lat.eq.lat({65}))
 i65s = ind(lat.eq.lat({-65}))

; get the mask for the ocean basins
 
 basins_mask = ocean_mask(oro)    ; returns 2D array(lat,lon) 

; compute net surface freshwater flux
 netflux = precc
 netflux = (/(precc+precl)-qflx/1000./)   ; units of m^3/s

; compute the net flux for the basins
 netflux_basin = new((/3,nlat,nlon/),float) 
 netflux_basin(0,:,:) = mask(netflux,basins_mask,1)  ; pacific
 netflux_basin(1,:,:) = mask(netflux,basins_mask,2)  ; atlantic
 netflux_basin(2,:,:) = mask(netflux,basins_mask,3)  ; indian

; sum flux over the longitudes in each basin
 heatflux = new((/3,nlat/),float) 
 heatflux = dim_sum(netflux_basin)  

; compute implied freshwater transport in each basin
 oft = new((/4,nlat/),float)
 oft!0 = "basin number"   ; 0:pacific, 1:atlantic, 2:indian, 3:total
 oft!1 = "lat"
 oft&lat = lat

 do n = 0, 2
   do j = i65n, i65s, 1      ;start sum at most northern point 
     oft(n,j) = -coef*dlon*sum(heatflux(n,j:i65n)*gw(j:i65n))
   end do
 end do

; compute total implied ocean freshwater transport at each latitude
; as the sum over the basins at that latitude
 do j = i65s, i65n
   oft(3,j) = sum(oft(:,j))
 end do

 return(oft)     ; 2D array(4,lat)
end

;***************************************************************************
; calculate the ocean freshwater transport for ecmwf era15 data

function oft_ecmwf (gwi[*]:numeric,oroi[*][*]:numeric,epi[*][*]:numeric)

; gw  : gaussian weights (lat)
; oro : orography data array (lat,lon)
; requires the lat and lon are attached coordinates of oro 
; and that oro and the following variables are 2D arrays (lat,lon).
; ep : evaporation-precipitation (lat,lon) units:mm/day

begin

 if (typeof(gwi).eq."double") then
   gw = dble2flt(gwi)
 else
   gw = gwi
 end if
 if (typeof(oroi).eq."double") then
   oro = dble2flt(oroi)
 else
   oro = oroi
 end if
 if (typeof(epi).eq."double") then
   ep = dble2flt(epi)
 else
   ep = epi 
 end if

; constants
 pi = 3.14159265
 re = 6.371e6            ; radius of earth
 coef = re^2/1.e6        ; scaled for Sverdrups 

 nlat = dimsizes(oro(:,0))
 nlon = dimsizes(oro(0,:))
 dlon = 2.*pi/nlon       ; dlon in radians
 lat = oro&lat 
 lat&lat = lat
 i65n = ind(lat.eq.lat({65}))
 i65s = ind(lat.eq.lat({-65}))

; get the mask for the ocean basins
 
 basins_mask = ocean_mask(oro)    ; returns 2D array(lat,lon) 

; compute net surface freshwater flux
 netflux = -ep/8.64e7           ; convert from mm/day to m/s

; compute the net flux for the basins
 netflux_basin = new((/3,nlat,nlon/),float) 
 netflux_basin(0,:,:) = mask(netflux,basins_mask,1)  ; pacific
 netflux_basin(1,:,:) = mask(netflux,basins_mask,2)  ; atlantic
 netflux_basin(2,:,:) = mask(netflux,basins_mask,3)  ; indian

; sum flux over the longitudes in each basin
 heatflux = new((/3,nlat/),float) 
 heatflux = dim_sum(netflux_basin)  

; compute implied freshwater transport in each basin
 oft = new((/4,nlat/),float)
 oft!0 = "basin number"   ; 0:pacific, 1:atlantic, 2:indian, 3:total
 oft!1 = "lat"
 oft&lat = lat

 do n = 0, 2
   do j = i65n, i65s, 1      ;start sum at most northern point 
     oft(n,j) = -coef*dlon*sum(heatflux(n,j:i65n)*gw(j:i65n))
   end do
 end do

; compute total implied ocean freshwater transport at each latitude
; as the sum over the basins at that latitude
 do j = i65s, i65n
   oft(3,j) = sum(oft(:,j))
 end do

 return(oft)     ; 2D array(4,lat)
end

;***************************************************************************
; calculate the required heat transport from data at TOA 

function rht_model (gwi[*]:numeric,restoai[*][*]:numeric)

; gw : gaussian weights (lat)
; restoa : residual energy at TOA = fsntoa-flut  

begin

 if (typeof(gwi).eq."double") then
   gw = dble2flt(gwi)
 else
   gw = gwi
 end if
 if (typeof(restoai).eq."double") then
  restoa  = dble2flt(restoai)
 else
   restoa = restoai 
 end if

; constants
 pi = 3.14159265
 re = 6.371e6            ; radius of earth
 coef = re^2/1.e15       ; scaled for PW 

 nlat = dimsizes(restoa(:,0))
 nlon = dimsizes(restoa(0,:))
 dlon = 2.*pi/nlon       ; dlon in radians
 lat = restoa&lat 
 lat&lat = lat

; sum flux over the longitudes 
 heatflux = dim_sum(restoa)  

; compute required heat transport 
 rht = new(nlat,float)
 rht!0 = "lat"
 rht&lat = lat

 do j = nlat-1, 0, 1      ;start sum at most northern point 
   rht(j) = -coef*dlon*sum(heatflux(j:nlat-1)*gw(j:nlat-1))
 end do

 return(rht)     ; 1D array(nlat)

end
