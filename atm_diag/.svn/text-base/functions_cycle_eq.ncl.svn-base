; NCL script
; functions_cycle_eq.ncl
; Mark Stevens, Jan 2003 
; last update Nov 4 2005
; all functions return 2D arrays (time,lon)
;******************************************************************
month = (/"01","02","03","04","05","06", \
          "07","08","09","10","11","12"/)

function cycle_PRECT_OCEAN (prefix:string)
begin

  inptr = addfile(prefix+"_ANN_climo.nc","r")
  lon = inptr->lon
  nlon = dimsizes(lon)
  precc = inptr->PRECC(0,:,:)
  precl = inptr->PRECL(0,:,:)
  mean = precc
  mean = (/(precc+precl)*8.64e7/)  ; annual mean mm/day 
  prect = new((/12,nlon/),float)
  prect!0 = "time"
  prect&time = ispan(0,11,1)
  prect!1 = "lon"
  prect&lon = lon
  do m = 0, 11
    inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
    precc = inptr->PRECC(0,:,:)     ; (lat,lon) 
    precl = inptr->PRECL(0,:,:)
    precip = precc
    precip = (/(precc+precl)*8.64e7/)  ; mm/day 
    precip = (/precip-mean/)           ; difference
    tmp = precip
    if (isfilevar(inptr,"ORO")) then
      oro = inptr->ORO(0,:,:)
      tmp = (/mask(precip,oro,0)/)         ; mask with ocean
    else
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        tmp = (/mask(precip,ocnfrac.ge.0.65,True)/)
      else
        print("PRECT_OCEAN_EQ: no ORO or OCNFRAC variables")
        prect = -999.
        return (prect)
      end if
    end if
    if (typeof(tmp).eq."double") then
      data = dble2flt(tmp)
    else
      data = tmp
    end if
    prect(m,:) = (/dim_avg_n(data({-5:5},:),0)/)
  ;;prect(m,:) = (/dim_avg(data(lon|:,{lat|-5:5}))/)
  end do
  prect@long_name = "Precipitation rate"
  prect@units = "mm/day"
  return (prect)
end

undef ("cycle_TAUX_OCEAN")
function cycle_TAUX_OCEAN (prefix:string)
begin
  inptr = addfile(prefix+"_ANN_climo.nc","r")
  if (isfilevar(inptr,"TAUX")) then 
    mean = inptr->TAUX(0,:,:)          ; annual mean
    lon = inptr->lon
    nlon = dimsizes(lon)
    taux_ocean = new((/12,nlon/),float)
    taux_ocean!0 = "time"
    taux_ocean&time = ispan(0,11,1)
    taux_ocean!1 = "lon"
    taux_ocean&lon = lon
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tx = inptr->TAUX(0,:,:)
      tx = (/tx-mean/)            ; difference from annual mean
      tmp = tx
      if (isfilevar(inptr,"ORO")) then
        oro = inptr->ORO(0,:,:)
        tmp = (/-1.0*mask(tx,oro,0)/)         ; mask with ocean
      else
        if (isfilevar(inptr,"OCNFRAC")) then
          ocnfrac = inptr->OCNFRAC(0,:,:)
          tmp = (/-1.0*mask(tx,ocnfrac.ge.0.65,True)/)
        else
          print("TAUX_OCEAN_EQ: no ORO or OCNFRAC variables")
          taux_ocean = -999.
          return (taux_ocean)
        end if
      end if
      if (typeof(tmp).eq."double") then
        taux = dble2flt(tmp)
      else
        taux = tmp
      end if
      taux_ocean(m,:) = (/dim_avg_n(taux({-5:5},:),0)/)
    ;;taux_ocean(m,:) = (/dim_avg(taux(lon|:,{lat|-5:5}))/)
    end do
    taux_ocean = (/taux_ocean*100./)            ; scale for plots
    taux_ocean@long_name = "Surface zonal stress"
    taux_ocean@units = "N/m~S~2~N~ x.01"
  else
    taux_ocean = -999.
  end if
  return (taux_ocean)
end

undef("cycle_TAUY_OCEAN")
function cycle_TAUY_OCEAN (prefix:string)
begin
  inptr = addfile(prefix+"_ANN_climo.nc","r")
  if (isfilevar(inptr,"TAUY")) then 
    mean = inptr->TAUY(0,:,:)          ; annual mean
    lon = inptr->lon
    nlon = dimsizes(lon)
    tauy_ocean = new((/12,nlon/),float)
    tauy_ocean!0 = "time"
    tauy_ocean&time = ispan(0,11,1)
    tauy_ocean!1 = "lon"
    tauy_ocean&lon = lon
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      ty = inptr->TAUY(0,:,:)
      ty = (/ty-mean/)            ; difference from annual mean
      tmp = ty
      if (isfilevar(inptr,"ORO")) then
        oro = inptr->ORO(0,:,:)
        tmp = (/-1.0*mask(ty,oro,0)/)         ; mask with ocean
      else
        if (isfilevar(inptr,"OCNFRAC")) then
          ocnfrac = inptr->OCNFRAC(0,:,:)
          tmp = (/-1.0*mask(ty,ocnfrac.ge.0.65,True)/)
        else
          print("TAUY_OCEAN_EQ: no ORO or OCNFRAC variables")
          tauy_ocean = -999.
          return (tauy_ocean)
        end if
      end if
      if (typeof(tmp).eq."double") then
        tauy = dble2flt(tmp)
      else
        tauy = tmp
      end if
      tauy_ocean(m,:) = (/dim_avg_n(tauy({-5:5},:),0)/)
    ;;tauy_ocean(m,:) = (/dim_avg(tauy(lon|:,{lat|-5:5}))/)
    end do
    tauy_ocean = (/tauy_ocean*100./)            ; scale for plots
    tauy_ocean@long_name = "Surface meridional stress"
    tauy_ocean@units = "N/m~S~2~N~ x.01"
  else
    tauy_ocean = -999.
  end if
  return (tauy_ocean)
end

undef("cycle_SST")
function cycle_SST (prefix:string)
begin
  inptr = addfile(prefix+"_ANN_climo.nc","r")
  lon = inptr->lon
  nlon = dimsizes(lon)
  sst = new((/12,nlon/),float)
  sst!0 = "time"
  sst&time = ispan(0,11,1)
  sst!1 = "lon"
  sst&lon = lon
  if (isfilevar(inptr,"TS")) then
    mean = inptr->TS(0,:,:)      ; annual mean
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      ts = inptr->TS(0,:,:)     ; (lat,lon) 
      ts = (/ts-mean/)          ; difference from annual mean
      tmp = ts 
      if (isfilevar(inptr,"ORO")) then
        oro = inptr->ORO(0,:,:)
        tmp = (/mask(ts,oro,0)/)         ; mask with ocean
      else
        if (isfilevar(inptr,"OCNFRAC")) then
          ocnfrac = inptr->OCNFRAC(0,:,:)
          tmp = (/mask(ts,ocnfrac.ge.0.65,True)/)
        else
          print("SST_EQ: no ORO or OCNFRAC variables")
          sst = -999.
          return (sst)
        end if
      end if
      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if
      sst(m,:) = (/dim_avg_n(data({-5:5},:),0)/)
    ;;sst(m,:) = (/dim_avg(data(lon|:,{lat|-5:5}))/)
    end do
    sst@long_name = "Sea surface temperature"
    sst@units = "C"
  else
    sst = -999.0
  end if
  return (sst)
end

function cycle_SWCF_OCEAN (prefix:string)
begin
  inptr = addfile(prefix+"_ANN_climo.nc","r")
  lon = inptr->lon
  nlon = dimsizes(lon)
  mean = inptr->SWCF(0,:,:)      ; annual mean
  swcf = new((/12,nlon/),float)
  swcf!0 = "time"
  swcf&time = ispan(0,11,1)
  swcf!1 = "lon"
  swcf&lon = lon
  do m = 0, 11
    inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
    sw = inptr->SWCF(0,:,:)     ; (lat,lon) 
    sw = (/sw-mean/)            ; difference from annual mean
    tmp = sw
    if (isfilevar(inptr,"ORO")) then
      oro = inptr->ORO(0,:,:)
      tmp = (/mask(sw,oro,0)/)         ; mask with ocean
    else
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        tmp = (/mask(sw,ocnfrac.ge.0.65,True)/)
      else
        print("SWCF_EQ: no ORO or OCNFRAC variables")
        swcf = -999.
        return (swcf)
      end if
    end if
    if (typeof(tmp).eq."double") then
      data = dble2flt(tmp)
    else
      data = tmp
    end if
    swcf(m,:) = (/dim_avg_n(data({-5:5},:),0)/)
  ;;swcf(m,:) = (/dim_avg(data(lon|:,{lat|-5:5}))/)
  end do
  swcf@long_name = "SW Cloud Forcing"
  swcf@units = "W/m~S~2~N~"
  return (swcf)
end

function cycle_LHFLX_OCEAN (prefix:string)
begin
  inptr = addfile(prefix+"_ANN_climo.nc","r")
  lon = inptr->lon
  nlon = dimsizes(lon)
  mean = inptr->QFLX(0,:,:)      ; annual mean
  mean = (/mean*2.501e6/)
  lhflx = new((/12,nlon/),float)
  lhflx!0 = "time"
  lhflx&time = ispan(0,11,1)
  lhflx!1 = "lon"
  lhflx&lon = lon
  do m = 0, 11
    inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
    lh = inptr->QFLX(0,:,:)     ; (lat,lon) 
    lh = (/lh*2.501e6/)
    lh = (/lh-mean/)            ; difference from annual mean
    tmp = lh
    if (isfilevar(inptr,"ORO")) then
      oro = inptr->ORO(0,:,:)
      tmp = (/mask(lh,oro,0)/)         ; mask with ocean
    else
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        tmp = (/mask(lh,ocnfrac.ge.0.65,True)/)
      else
        print("LHFLX_EQ: no ORO or OCNFRAC variables")
        lhflx = -999.
        return (lhflx)
      end if
    end if
    if (typeof(tmp).eq."double") then
      data = dble2flt(tmp)
    else
      data = tmp
    end if
    lhflx(m,:) = (/dim_avg_n(data({-5:5},:),0)/)
  ;;lhflx(m,:) = (/dim_avg(data(lon|:,{lat|-5:5}))/)
  end do
  lhflx@long_name = "Surface latent heat flux"
  lhflx@units = "W/m~S~2~N~"
  return (lhflx)
end

;********************************************************************
; OBSERVATIONAL DATA
;********************************************************************

function cycle_PRECT_OCEAN_OBS (prefix,dataset:string)
begin
  f = addfile(prefix+"/LANDFRAC.T42.nc","r") 
  landmask = f->LANDFRAC    ; lat,lon
  lon_landmask = f->lon
  lat_landmask = f->lat
  inptr = addfile(prefix+dataset+"_ANN_climo.nc","r")
  lon = inptr->lon
  lat = inptr->lat
  nlon = dimsizes(lon)
  mean = inptr->PRECT(0,:,:)      ; annual mean
  prect = new((/12,nlon/),float)
  prect!0 = "time"
  prect&time = ispan(0,11,1)
  prect!1 = "lon"
  prect&lon = lon
  do m = 0, 11
    inptr = addfile(prefix+dataset+"_"+month(m)+"_climo.nc","r")
    precip = inptr->PRECT(0,:,:)     ; (lat,lon) 
    precip = (/precip-mean/)         ; difference from annual mean
    ;landmask_precip=linint2(lat_landmask,lon_landmask,landmask,False,lat,lon,0)
    landmask_precip=linint2(lon_landmask,lat_landmask,landmask,False,lon,lat,0)
    tmp = precip
    tmp = (/mask(precip,landmask_precip.lt.0.35,True)/)   ; mask with ocean
    if (typeof(tmp).eq."double") then
      data = dble2flt(tmp)
    else
      data = tmp
    end if
    prect(m,:) = (/dim_avg_n(data({-5:5},:),0)/)
  ;;prect(m,:) = (/dim_avg(data(lon|:,{lat|-5:5}))/)
  end do
  prect@long_name = "Precipitation rate"
  prect@units = "mm/day"
  return (prect)
end

function cycle_TAUX_OCEAN_OBS (prefix,dataset:string)
begin
; already masked for ocean
  inptr = addfile(prefix+dataset+"_ANN_climo.nc","r")
  if (isfilevar(inptr,"TAUX")) then 
    mean = inptr->TAUX(0,:,:)          ; annual mean
    lon = inptr->lon
    nlon = dimsizes(lon)
    taux_ocean = new((/12,nlon/),float)
    taux_ocean!0 = "time"
    taux_ocean&time = ispan(0,11,1)
    taux_ocean!1 = "lon"
    taux_ocean&lon = lon
    do m = 0, 11
      inptr = addfile(prefix+dataset+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->TAUX(0,:,:)
      tmp = (/tmp-mean/)            ; difference from annual mean
      if (typeof(tmp).eq."double") then
        taux = dble2flt(tmp)
      else
        taux = tmp
      end if
      taux_ocean(m,:) = (/dim_avg_n(taux({-5:5},:),0)/)
    ;;taux_ocean(m,:) = (/dim_avg(taux(lon|:,{lat|-5:5}))/)
    end do
    taux_ocean = (/taux_ocean*100./)            ; scale for plots
    taux_ocean@long_name = "Ocean zonal stress"
    taux_ocean@units = "N/m~S~2~N~ x.01"
  else
    taux_ocean = -999.
  end if
  return (taux_ocean)
end

function cycle_TAUY_OCEAN_OBS (prefix,dataset:string)
begin
; already masked for ocean
  inptr = addfile(prefix+dataset+"_ANN_climo.nc","r")
  if (isfilevar(inptr,"TAUY")) then 
    mean = inptr->TAUY(0,:,:)          ; annual mean
    lon = inptr->lon
    nlon = dimsizes(lon)
    tauy_ocean = new((/12,nlon/),float)
    tauy_ocean!0 = "time"
    tauy_ocean&time = ispan(0,11,1)
    tauy_ocean!1 = "lon"
    tauy_ocean&lon = lon
    do m = 0, 11
      inptr = addfile(prefix+dataset+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->TAUY(0,:,:)
      tmp = (/tmp-mean/)            ; difference from annual mean
      if (typeof(tmp).eq."double") then
        tauy = dble2flt(tmp)
      else
        tauy = tmp
      end if
      tauy_ocean(m,:) = (/dim_avg_n(tauy({-5:5},:),0)/)
    ;;tauy_ocean(m,:) = (/dim_avg(tauy(lon|:,{lat|-5:5}))/)
    end do
    tauy_ocean = (/tauy_ocean*100./)            ; scale for plots
    tauy_ocean@long_name = "Ocean meridional stress"
    tauy_ocean@units = "N/m~S~2~N~ x.01"
  else
    tauy_ocean = -999.
  end if
  return (tauy_ocean)
end

function cycle_SST_OBS (prefix,dataset:string)
begin
; already masked for ocean
  inptr = addfile(prefix+dataset+"_ANN_climo.nc","r")
  lon = inptr->lon
  nlon = dimsizes(lon)
  mean = inptr->SST(0,:,:)
  sst = new((/12,nlon/),float)
  sst!0 = "time"
  sst&time = ispan(0,11,1)
  sst!1 = "lon"
  sst&lon = lon
  do m = 0, 11
    inptr = addfile(prefix+dataset+"_"+month(m)+"_climo.nc","r")
    tmp = inptr->SST(0,:,:)     ; (lat,lon) 
    tmp = (/tmp-mean/)          ; difference from annual mean
    if (typeof(tmp).eq."double") then
      data = dble2flt(tmp)
    else
      data = tmp
    end if
    sst(m,:) = (/dim_avg_n(data({-5:5},:),0)/)
  ;;sst(m,:) = (/dim_avg(data(lon|:,{lat|-5:5}))/)
  end do
  sst@long_name = "Sea surface temperature"
  sst@units = "C"
  return (sst)
end

function cycle_SWCF_OCEAN_OBS (prefix,dataset:string)
begin
  f = addfile(prefix+"/LANDFRAC.T42.nc","r") 
  landmask = f->LANDFRAC  ; lat,lon
  inptr = addfile(prefix+dataset+"_ANN_climo.nc","r")
  lon = inptr->lon
  nlon = dimsizes(lon)
  mean = inptr->SWCF(0,:,:)      ; annual mean
  swcf = new((/12,nlon/),float)
  swcf!0 = "time"
  swcf&time = ispan(0,11,1)
  swcf!1 = "lon"
  swcf&lon = lon
  do m = 0, 11
    inptr = addfile(prefix+dataset+"_"+month(m)+"_climo.nc","r")
    sw = inptr->SWCF(0,:,:)     ; (lat,lon) 
    sw = (/sw-mean/)            ; difference from annual mean
    tmp = sw 
    tmp = (/mask(sw,landmask.lt.0.35,True)/)   ; mask with ocean
    if (typeof(tmp).eq."double") then
      data = dble2flt(tmp)
    else
      data = tmp
    end if
    swcf(m,:) = (/dim_avg_n(data({-5:5},:),0)/)
  ;;swcf(m,:) = (/dim_avg(data(lon|:,{lat|-5:5}))/)
  end do
  swcf@long_name = "SW Cloud Forcing"
  swcf@units = "W/m~S~2~N~"
  return (swcf)
end

function cycle_LHFLX_OCEAN_OBS (prefix,dataset:string)
begin
  inptr = addfile(prefix+dataset+"_ANN_climo.nc","r")
  lon = inptr->lon
  nlon = dimsizes(lon)
  lat = inptr->lat
  nlat = dimsizes(lat)
  mean = inptr->LHFLX(0,:,:)      ; annual mean
  lhflx = new((/12,nlon/),float)
  lhflx!0 = "time"
  lhflx&time = ispan(0,11,1)
  lhflx!1 = "lon"
  lhflx&lon = lon
  if (nlat.eq.64) then ; Use T42 landmask
    f = addfile(prefix+"/LANDFRAC.T42.nc","r")
    landmask = f->LANDFRAC   ; (lat,lon)
  end if
  do m = 0, 11
    inptr = addfile(prefix+dataset+"_"+month(m)+"_climo.nc","r")
    lh = inptr->LHFLX(0,:,:)     ; (lat,lon) 
    lh = (/lh-mean/)            ; difference from annual mean
    tmp = lh
    if (nlat.eq.64) then ; Use T42 landmask
      tmp = (/mask(lh,landmask.lt.0.35,True)/)   ; mask with ocean
    end if
    if (typeof(tmp).eq."double") then
      data = dble2flt(tmp)
    else
      data = tmp
    end if
    lhflx(m,:) = (/dim_avg_n(data({5:5},:),0)/)
  ;;lhflx(m,:) = (/dim_avg(data(lon|:,{lat|-5:5}))/)
  end do
  lhflx@long_name = "Surface latent heat flux"
  lhflx@units = "W/m~S~2~N~"
  return (lhflx)
end

