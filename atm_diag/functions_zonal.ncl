; NCL script
; functions_zonal.ncl
; alll functions return 1D arrays (lat)
; Mark Stevens, Sept 2001
;******************************************************************

load "$DIAG_CODE/functions_eddyflux.ncl"

function zonal_AODVIS (inptr:file,outptr:file)
begin
  tmp = get_AODVIS (inptr,outptr)     ; (lat,lon)
  if (all(tmp.eq.-999.)) then
    return (tmp) 
  else
    aodvis = dim_avg_Wrap (tmp)
    return (aodvis)
  end if
end


function zonal_AODDUST (inptr:file,outptr:file)
begin
  tmp = get_AODDUST (inptr,outptr)     ; (lat,lon)
  if (all(tmp.eq.-999.)) then
    return (tmp) 
  else
    aoddust = dim_avg_Wrap (tmp)
    return (aoddust)
  end if
end


function zonal_CLDHGH (inptr:file,outptr:file)
begin
  tmp = get_CLDHGH (inptr,outptr)     ; (lat,lon)
  cldhgh = dim_avg_Wrap (tmp)
  return (cldhgh)
end

function zonal_CLDLOW (inptr:file,outptr:file)
begin
  tmp = get_CLDLOW (inptr,outptr)     ; (lat,lon)
  cldlow = dim_avg_Wrap (tmp)
  return (cldlow)
end

function zonal_CLDMED (inptr:file,outptr:file)
begin
  tmp = get_CLDMED (inptr,outptr)     ; (lat,lon)
  cldmed = dim_avg_Wrap (tmp)
  return (cldmed)
end

function zonal_CLDTOT (inptr:file,outptr:file)
begin
  tmp = get_CLDTOT (inptr,outptr)     ; (lat,lon)
  cldtot = dim_avg_Wrap (tmp)
  return (cldtot)
end

function zonal_EP (inptr:file,outptr:file)
begin
  tmp = get_EP (inptr,outptr)     ; (lat,lon)
  if (all(tmp.eq.-999.)) then
    return (tmp) 
  else
    ep = dim_avg_Wrap (tmp)
    return (ep)
  end if
end

function zonal_FLDS (inptr:file,outptr:file)
begin
  tmp = get_FLDS (inptr,outptr)     ; (lat,lon)
  if (all(tmp.eq.-999.)) then
    return (tmp) 
  else
    flds = dim_avg_Wrap (tmp)
    return (flds)
  end if
end

function zonal_FLDSC (inptr:file,outptr:file)
begin
  tmp = get_FLDSC (inptr,outptr)     ; (lat,lon)
  if (all(tmp.eq.-999.)) then
    return (tmp) 
  else
    fldsc = dim_avg_Wrap (tmp)
    return (fldsc)
  end if
end

function zonal_FLNS (inptr:file,outptr:file)
begin
  tmp = get_FLNS (inptr,outptr)     ; (lat,lon)
  flns = dim_avg_Wrap (tmp)
  return (flns)
end

function zonal_FLNSC (inptr:file,outptr:file)
begin
  tmp = get_FLNSC (inptr,outptr)     ; (lat,lon)
  flnsc = dim_avg_Wrap (tmp)
  return (flnsc)
end

function zonal_FLNT (inptr:file,outptr:file)
begin
  tmp = get_FLNT (inptr,outptr)     ; (lat,lon)
  flnt = dim_avg_Wrap (tmp)
  return (flnt)
end

function zonal_FLNTC (inptr:file,outptr:file)
begin
  tmp = get_FLNTC (inptr,outptr)     ; (lat,lon)
  flntc = dim_avg_Wrap (tmp)
  return (flntc)
end

function zonal_FLUT (inptr:file,outptr:file)
begin
  tmp = get_FLUT (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    flut = dim_avg_Wrap (tmp)
    return (flut)
  end if
end

function zonal_FLUTC (inptr:file,outptr:file)
begin
  tmp = get_FLUTC (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    flutc = dim_avg_Wrap (tmp)
    return (flutc)
  end if
end

function zonal_FSDS (inptr:file,outptr:file)
begin
  tmp = get_FSDS (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    fsds = dim_avg_Wrap (tmp)
    return (fsds)
  end if
end

function zonal_FSDSC (inptr:file,outptr:file)
begin
  tmp = get_FSDSC (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    fsdsc = dim_avg_Wrap (tmp)
    return (fsdsc)
  end if
end

function zonal_FSNS (inptr:file,outptr:file)
begin
  tmp = get_FSNS (inptr,outptr)     ; (lat,lon)
  fsns = dim_avg_Wrap (tmp)
  return (fsns)
end

function zonal_FSNSC (inptr:file,outptr:file)
begin
  tmp = get_FSNSC (inptr,outptr)     ; (lat,lon)
  fsnsc = dim_avg_Wrap (tmp)
  return (fsnsc)
end

function zonal_FSNT (inptr:file,outptr:file)
begin
  tmp = get_FSNT (inptr,outptr)     ; (lat,lon)
  fsnt = dim_avg_Wrap (tmp)
  return (fsnt)
end

function zonal_FSNTC (inptr:file,outptr:file)
begin
  tmp = get_FSNTC (inptr,outptr)     ; (lat,lon)
  fsntc = dim_avg_Wrap (tmp)
  return (fsntc)
end

function zonal_FSNTOA (inptr:file,outptr:file)
begin
  tmp = get_FSNTOA (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    fsntoa = dim_avg_Wrap (tmp)
    return (fsntoa)
  end if
end

function zonal_FSNTOAC (inptr:file,outptr:file)
begin
  tmp = get_FSNTOAC (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    fsntoac = dim_avg_n_Wrap(tmp,1) 
    return (fsntoac)
  end if
end

function zonal_LHFLX (inptr:file,outptr:file)
begin
  tmp = get_LHFLX (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    lhflx = dim_avg_Wrap (tmp)
    return (lhflx)
  end if
end

function zonal_LWCFSRF (inptr:file,outptr:file)
begin
  tmp = get_LWCFSRF (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    lwcfsrf = dim_avg_Wrap (tmp)
    return (lwcfsrf)
  end if
end

function zonal_LWCFTOA (inptr:file,outptr:file)
begin
  tmp = get_LWCFTOA (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    lwcftoa = dim_avg_Wrap (tmp)
    return (lwcftoa)
  end if
end

function zonal_LWCFTOM (inptr:file,outptr:file)
begin
  tmp = get_LWCFTOM (inptr,outptr)     ; (lat,lon)
  lwcftom = dim_avg_Wrap (tmp)
  return (lwcftom)
end

function zonal_PBLH (inptr:file,outptr:file)
begin
  tmp = get_PBLH (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    pblh = dim_avg_Wrap (tmp)
    return (pblh)
  end if
end

function zonal_PRECT (inptr:file,outptr:file)
begin
  tmp = get_PRECT (inptr,outptr)     ; (lat,lon)
  prect = dim_avg_Wrap (tmp)
  return (prect)
end

function zonal_PRECT_LAND (inptr:file,outptr:file)
begin
  tmp = get_PRECT_LAND (inptr,outptr)     ; (lat,lon)
  prect_land = dim_avg_Wrap (tmp)
  return (prect_land)
end

function zonal_PRECT_OCEAN (inptr:file,outptr:file)
begin
  tmp = get_PRECT_OCEAN (inptr,outptr)     ; (lat,lon)
  prect_ocean = dim_avg_Wrap (tmp)
  return (prect_ocean)
end

function zonal_PREH2O (inptr:file,outptr:file)
begin
  tmp = get_PREH2O (inptr,outptr)     ; (lat,lon)
  preh2o = dim_avg_Wrap (tmp)
  return (preh2o)
end

function zonal_PREH2O_OCEAN (inptr:file,outptr:file)
begin
  tmp = get_PREH2O_OCEAN (inptr,outptr)     ; (lat,lon)
  preh2o_ocean = dim_avg_Wrap (tmp)
  return (preh2o_ocean)
end

function zonal_PS (inptr:file,outptr:file)
begin
  tmp = get_PS (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    ps = dim_avg_Wrap (tmp)
    return (ps)
  end if
end

function zonal_PSL (inptr:file,outptr:file)
begin
  tmp = get_PSL (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    psl = dim_avg_Wrap (tmp)
    return (psl)
  end if
end

function zonal_QFLX (inptr:file,outptr:file)
begin
  tmp = get_QFLX (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    qflx = dim_avg_Wrap (tmp)
    return (qflx)
  end if
end

function zonal_RESSURF (inptr:file,outptr:file)
begin
  tmp = get_RESSURF (inptr,outptr)     ; (lat,lon)
  ressurf = dim_avg_Wrap (tmp)
  return (ressurf)
end

function zonal_RESTOM (inptr:file,outptr:file)
begin
  tmp = get_RESTOM (inptr,outptr)     ; (lat,lon)
  restom = dim_avg_Wrap (tmp)
  return (restom)
end

function zonal_SHFLX (inptr:file,outptr:file)
begin
  tmp = get_SHFLX (inptr,outptr)     ; (lat,lon)
  shflx = dim_avg_Wrap (tmp)
  return (shflx)
end

function zonal_SOLIN (inptr:file,outptr:file)
begin
  tmp = get_SOLIN (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    solin = dim_avg_Wrap (tmp)
    return (solin)
  end if
end

function zonal_SWCFSRF (inptr:file,outptr:file)
begin
  tmp = get_SWCFSRF (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    swcfsrf = dim_avg_Wrap (tmp)
    return (swcfsrf)
  end if
end

function zonal_SWCFTOA (inptr:file,outptr:file)
begin
  tmp = get_SWCFTOA (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    swcftoa = dim_avg_Wrap (tmp)
    return (swcftoa)
  end if
end

function zonal_SWCFTOM (inptr:file,outptr:file)
begin
  tmp = get_SWCFTOM (inptr,outptr)     ; (lat,lon)
  swcftom = dim_avg_Wrap (tmp)
  return (swcftom)
end

function zonal_TAUX_OCEAN (inptr:file,outptr:file)
begin
  taux = get_TAUX_OCEAN (inptr,outptr)     ; (lat,lon)
  if (all(taux .eq. -999.)) then
    return (taux)
  else
    taux_ocean = dim_avg_Wrap (taux)
    return (taux_ocean)
  end if
end

function zonal_TGCLDIWP (inptr:file,outptr:file)
begin
  tmp = get_TGCLDIWP (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    tgcldiwp = dim_avg_Wrap (tmp)
    return (tgcldiwp)
  end if
end

function zonal_TGCLDLWP (inptr:file,outptr:file)
begin
  tmp = get_TGCLDLWP (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    tgcldlwp = dim_avg_Wrap (tmp)
    return (tgcldlwp)
  end if
end

function zonal_TGCLDLWP_OCEAN (inptr:file,outptr:file)
begin
  tmp = get_TGCLDLWP_OCEAN (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    tgcldlwp_ocean = dim_avg_Wrap (tmp)
    return (tgcldlwp_ocean)
  end if
end

function zonal_TICLDIWP (inptr:file,outptr:file)
begin
  tmp = get_TICLDIWP (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    ticldiwp = dim_avg_Wrap (tmp)
    return (ticldiwp)
  end if
end

function zonal_TICLDLIQWP (inptr:file,outptr:file)
begin
  tmp = get_TICLDLIQWP (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    ticldliqwp = dim_avg_Wrap (tmp)
    return (ticldliqwp)
  end if
end

function zonal_TICLDTWP (inptr:file,outptr:file)
begin
  tmp = get_TICLDTWP (inptr,outptr)     ; (lat,lon)
  if (all(tmp .eq. -999.)) then
    return (tmp)
  else
    ticldtwp = dim_avg_Wrap (tmp)
    return (ticldtwp)
  end if
end

function zonal_TREFHT (inptr:file,outptr:file)
begin
  tmp = get_TREFHT (inptr,outptr)     ; (lat,lon)
  trefht = dim_avg_Wrap (tmp)
  return (trefht)
end

function zonal_TREFHT_LAND (inptr:file,outptr:file)
begin
  tmp = get_TREFHT_LAND (inptr,outptr)     ; (lat,lon)
  trefht_land = dim_avg_Wrap (tmp)
  return (trefht_land)
end

function zonal_TS (inptr:file,outptr:file)
begin
  tmp = get_TS (inptr,outptr)     ; (lat,lon)
  ts = dim_avg_Wrap (tmp)
  return (ts)
end

function zonal_TS_LAND (inptr:file,outptr:file)
begin
  tmp = get_TS_LAND (inptr,outptr)     ; (lat,lon)
  ts_land = dim_avg_Wrap (tmp)
  return (ts_land)
end

function zonal_SIWC (inptr:file,outptr:file)
begin
  tmp = get_SIWC (inptr,outptr)     ; (lat,lon)
  siwc = dim_avg_Wrap (tmp)
  return (siwc)
end


;=========================================================
; Eddy fluxes
;=========================================================
; constants
pi = 3.14159265
re = 6.371e6      ; radius of earth (m)
coeff = 2.*pi*re
d2rad = pi/180.   ; degrees to radians
;-----------------------------------------------------
function zonal_VBSTAR_QBSTAR (inptr:file,outptr:file)
begin
  tmp = get_VBSTAR_QBSTAR_2D (inptr,outptr)     ; (lat,lon)
  vbstar_qbstar = dim_avg_Wrap (tmp)            ; (lat)
  return (vbstar_qbstar)
end

function zonal_VBSTAR_TBSTAR (inptr:file,outptr:file)
begin
  tmp = get_VBSTAR_TBSTAR_2D (inptr,outptr)     ; (lat,lon)
  vbstar_tbstar = dim_avg_Wrap (tmp)            ; (lat)
  lat =  inptr->lat
  if (typeof(lat) .eq. "double") then 
    flat = dble2flt(lat)
  else
    flat = lat
  end if
  flat = (/flat*d2rad/)  ; convert to radians
  vbstar_tbstar = (/coeff*cos(flat)*vbstar_tbstar/)
  return (vbstar_tbstar)
end

function zonal_VBSTAR_UBSTAR (inptr:file,outptr:file)
begin
  tmp = get_VBSTAR_UBSTAR_2D (inptr,outptr)     ; (lat,lon)
  vbstar_ubstar = dim_avg_Wrap (tmp)            ; (lat)
  return (vbstar_ubstar)
end

function zonal_VPTP_BAR (inptr:file,outptr:file)
begin
  tmp = get_VPTP_BAR_2D (inptr,outptr)     ; (lat,lon)
  vptp_bar = dim_avg_Wrap (tmp)            ; (lat)
  lat =  inptr->lat
  if (typeof(lat) .eq. "double") then 
    flat = dble2flt(lat)
  else
    flat = lat
  end if
  flat = (/flat*d2rad/)  ; convert to radians
  vptp_bar = (/coeff*cos(flat)*vptp_bar/)
  return (vptp_bar)
end

function zonal_VPQP_BAR (inptr:file,outptr:file)
begin
  tmp = get_VPQP_BAR_2D (inptr,outptr)     ; (lat,lon)
  vpqp_bar = dim_avg_Wrap (tmp)            ; (lat)
  return (vpqp_bar)
end

function zonal_VPUP_BAR (inptr:file,outptr:file)
begin
  tmp = get_VPUP_BAR_2D (inptr,outptr)     ; (lat,lon)
  vpup_bar = dim_avg_Wrap (tmp)            ; (lat)
  return (vpup_bar)
end

function zonal_EKE_BAR (inptr:file,outptr:file)
begin
  tmp = get_EKE_BAR_2D (inptr,outptr)     ; (lat,lon)
  eke_bar = dim_avg_Wrap (tmp)            ; (lat)
  return (eke_bar)
end

; BRH additions for COSP
function zonal_CLDTOT_ISCCPCOSP (inptr:file,outptr:file)
begin
  tmp = get_CLDTOT_ISCCPCOSP (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDLOW_ISCCPCOSP (inptr:file,outptr:file)
begin
  tmp = get_CLDLOW_ISCCPCOSP (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDMED_ISCCPCOSP (inptr:file,outptr:file)
begin
  tmp = get_CLDMED_ISCCPCOSP (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDHGH_ISCCPCOSP (inptr:file,outptr:file)
begin
  tmp = get_CLDHGH_ISCCPCOSP (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDTHICK_ISCCPCOSP (inptr:file,outptr:file)
begin
  tmp = get_CLDTHICK_ISCCPCOSP (inptr,outptr) ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_MEANPTOP_ISCCPCOSP (inptr:file,outptr:file)
begin
  tmp = get_MEANPTOP_ISCCPCOSP (inptr,outptr) ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_MEANTTOP_ISCCPCOSP (inptr:file,outptr:file)
begin
  tmp = get_MEANTTOP_ISCCPCOSP (inptr,outptr) ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_MEANCLDALB_ISCCPCOSP (inptr:file,outptr:file)
begin
  tmp = get_MEANCLDALB_ISCCPCOSP (inptr,outptr) ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDTOT_MISR (inptr:file,outptr:file)
begin
  tmp = get_CLDTOT_MISR (inptr,outptr)    ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDLOW_MISR (inptr:file,outptr:file)
begin
  tmp = get_CLDLOW_MISR (inptr,outptr)    ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDMED_MISR (inptr:file,outptr:file)
begin
  tmp = get_CLDMED_MISR (inptr,outptr)    ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDHGH_MISR (inptr:file,outptr:file)
begin
  tmp = get_CLDHGH_MISR (inptr,outptr)    ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDTHICK_MISR (inptr:file,outptr:file)
begin
  tmp = get_CLDTHICK_MISR (inptr,outptr) ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDTOT_MODIS (inptr:file,outptr:file)
begin
  tmp = get_CLDTOT_MODIS (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDLOW_MODIS (inptr:file,outptr:file)
begin
  tmp = get_CLDLOW_MODIS (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDMED_MODIS (inptr:file,outptr:file)
begin
  tmp = get_CLDMED_MODIS (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDHGH_MODIS (inptr:file,outptr:file)
begin
  tmp = get_CLDHGH_MODIS (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDTHICK_MODIS (inptr:file,outptr:file)
begin
  tmp = get_CLDTHICK_MODIS (inptr,outptr) ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLIMODIS (inptr:file,outptr:file)
begin
  tmp = get_CLIMODIS (inptr,outptr)       ; (lat,lon)
  cloud = dim_avg_Wrap (tmp)              ; (lat)
  return (cloud)
end

function zonal_CLWMODIS (inptr:file,outptr:file)
begin
  tmp = get_CLWMODIS (inptr,outptr)       ; (lat,lon)
  cloud = dim_avg_Wrap (tmp)              ; (lat)
  return (cloud)
end

function zonal_IWPMODIS (inptr:file,outptr:file)
begin
  tmp = get_IWPMODIS (inptr,outptr)       ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_LWPMODIS (inptr:file,outptr:file)
begin
  tmp = get_LWPMODIS (inptr,outptr)       ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_PCTMODIS (inptr:file,outptr:file)
begin
  tmp = get_PCTMODIS (inptr,outptr)       ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_REFFCLIMODIS (inptr:file,outptr:file)
begin
  tmp = get_REFFCLIMODIS (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_REFFCLWMODIS (inptr:file,outptr:file)
begin
  tmp = get_REFFCLWMODIS (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_TAUILOGMODIS (inptr:file,outptr:file)
begin
  tmp = get_TAUILOGMODIS (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_TAUWLOGMODIS (inptr:file,outptr:file)
begin
  tmp = get_TAUWLOGMODIS (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_TAUTLOGMODIS (inptr:file,outptr:file)
begin
  tmp = get_TAUTLOGMODIS (inptr,outptr)   ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_TAUIMODIS (inptr:file,outptr:file)
begin
  tmp = get_TAUIMODIS (inptr,outptr)      ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_TAUWMODIS (inptr:file,outptr:file)
begin
  tmp = get_TAUWMODIS (inptr,outptr)      ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_TAUTMODIS (inptr:file,outptr:file)
begin
  tmp = get_TAUTMODIS (inptr,outptr)      ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDTOT_CAL (inptr:file,outptr:file)
begin
  tmp = get_CLDTOT_CAL (inptr,outptr)     ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDLOW_CAL (inptr:file,outptr:file)
begin
  tmp = get_CLDLOW_CAL (inptr,outptr)     ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDMED_CAL (inptr:file,outptr:file)
begin
  tmp = get_CLDMED_CAL (inptr,outptr)     ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDHGH_CAL (inptr:file,outptr:file)
begin
  tmp = get_CLDHGH_CAL (inptr,outptr)     ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end

function zonal_CLDTOT_CS2 (inptr:file,outptr:file)
begin
  tmp = get_CLDTOT_CS2 (inptr,outptr)      ; (lat,lon)
  var = dim_avg_Wrap (tmp)                ; (lat)
  return (var)
end
