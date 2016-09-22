; NCL script
; funcs_surf_variance.ncl
; Mark Stevens, Jan 2002
; Last update: Dennis Shea, Oct 2010 
; surface, constant pressure level, and TOM/A variables
;******************************************************************
; Update Oct, 2010: DJS: 
; Use more 'modern NCL functions' , use "local" declarations 
; Preparation for 'parallel NCL'
;******************************************************************
; all functions return 2D arrays (lat,lon)
;******************************************************************
undef ("force_float")
function force_float (x:numeric)
local vari
begin
    if (typeof(x).eq."double") then
      vari = dble2flt(x)          ; keep meta data
    else
      vari = x
    end if
    return(vari)
end

function get_SIGNIFICANCE (mean1,var1,dim1,mean2,var2,dim2:numeric)
; mean1 is the climatological mean of variable1
; var1 is the variance of variable1
; mean2 is the climatological mean of variable2
; var2 is the variance of variable2
local nlat1, nlon1, nlat2, nlon2, signif, lat1, lon1, lat2,lon2, mean, var 
begin
  nlat1 = dimsizes(var1&lat)
  nlon1 = dimsizes(var1&lon)
  nlat2 = dimsizes(var2&lat)
  nlon2 = dimsizes(var2&lon)
  if (nlat1 .eq. nlat2) then
    signif = mean1            ; copy coordinates
    signif = ttest(mean1,var1,dim1,mean2,var2,dim2,True,False) 
  else
    lat1 = var1&lat
    lon1 = var1&lon
    lat2 = var2&lat
    lon2 = var2&lon
    if (nlat1 .gt. nlat2) then
      mean   = linint2(lon1,lat1,mean1,False,lon2,lat2,0)
      var    = linint2(lon1,lat1,var1,False,lon2,lat2,0)
      signif = mean2        
      signif = ttest(mean,var,dim1,mean2,var2,dim2,True,False) 
    else
      mean   = linint2(lon2,lat2,mean2,False,lon1,lat1,0)
      var    = linint2(lon2,lat2,var2,False,lon1,lat1,0)
      signif = mean1        
      signif = ttest(mean1,var1,dim1,mean,var,dim2,True,False) 
    end if
  end if
  return (signif)
end

function get_VARIANCE (inptr:file,outptr:file,var:string) 
; inptr is pointer to file of annual or seasonal means
; outptr is pointer to file of computed variances
local vari, tmp, tmp2, tmpvar, vari
begin
 
  if (isfilevar(outptr,var)) then 
    vari = outptr->$var$
  else
    tmp    = inptr->$var$
    tmp2   = dim_variance_n_Wrap (tmp, 0)
  ;;tmp2   = dim_variance_Wrap (tmp(lat|:,lon|:,time|:))  ; original
    tmpvar = tmp2
    if (any(tmp2.le.0)) then    ; set variance = 0.0 to missing
      tmpvar = mask(tmpvar,tmp2.gt.0,True)
    end if
    vari   = force_float(tmpvar)
    outptr->$var$ = vari 
  end if
  return (vari)
end 


function get_SST_VARIANCE (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SST")) then
    sst = outptr->SST
  else
    if (isfilevar(inptr,"TS")) then 
      temp = inptr->TS(0,:,:) 
      if (typeof(temp).eq."double") then
        ts = dble2flt(temp)
      else
        ts = temp
      end if
      ts = (/ts-273.15/)                ; convert to degrees C
      sst = ts
      if (isfilevar(inptr,"OCNFRAC")) then  ; newer models
        ocnfrac = inptr->OCNFRAC(0,:,:)
        sst = mask(ts,ocnfrac.ge.0.9,True)        
      else
        if (isfilevar(inptr,"ORO")) then  ; for older models
          oro = inptr->ORO(0,:,:)
          sst = mask(ts,oro,0)            ; mask with ocean
        else
          print("SST: no ORO or OCNFRAC variables")
          sst = -999.0
          return (sst)
        end if
      end if
      sst@long_name = "Sea surface temperature"
      sst@units = "C"
      assignFillValue(sst,sst)
      tmp    = dim_variance_n_Wrap(sst, 0)
      vari   = force_float(tmp)
      outptr->SST = vari 
    else
      sst = -999.0
    end if 
  end if
  return (sst)
end


function get_ALBEDO_VARIANCE (inptr:file,outptr:file)
local vari, fsntoa, sol, solin, albedo, tmp
begin
  if (isfilevar(outptr,"ALBEDO")) then
    vari = outptr->ALBEDO
  else
    if (isfilevar(inptr,"SOLIN")) then
      fsntoa = inptr->FSNTOA
      sol    = inptr->SOLIN
      solin  = sol 
      solin  = mask(sol,sol.gt.0.0,True)
      albedo = solin
      albedo = (/(solin-fsntoa)/solin/)
      tmp    = dim_variance_n_Wrap(albedo, 0)
    ;;tmp    = dim_variance_Wrap (albedo(lat|:,lon|:,time|:))  ; original
      vari   = force_float(tmp)
      outptr->ALBEDO = vari 
    else
      vari = -999.0
    end if
  end if

  return (vari)
end


function get_SIWC_226_VARIANCE (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"SIWC_226")) then
    siwc = outptr->SIWC_226
  else
   if( (isfilevar(inptr,"IWC")).and.(isfilevar(inptr,"AQSNOW")) )then
    T = inptr->T(:,13,:,:)
    plev = dble2flt(inptr->lev(13))
    Rd = 287.04
    rho = plev/Rd*T

    lat = inptr->lat
    lon = inptr->lon
    
    tmp = inptr->IWC(:,13,:,:)
    tmp = (/tmp+inptr->AQSNOW(:,13,:,:)*rho/)
    
    if (typeof(tmp).eq."double") then
      siwc = dble2flt(tmp)
    else
      siwc = tmp
    end if
  
    siwc = (/siwc*1.e6/)
    siwc@long_name = "GIWC+SNOW at 226mb"
    siwc@units = "mg/m:S:3:N:"
    assignFillValue(siwc,siwc)


    tmp2 = dim_variance_n_Wrap (siwc, 0)
    vari = force_float(tmp2)

    outptr->SIWC_226 = vari

   else
   
    vari = -999.
   end if
  end if
 
  return (vari)
end 



function get_ALBEDOC_VARIANCE (inptr:file,outptr:file)
local vari, fsntoac, sol, solin, albedoc, tmp
begin
  if (isfilevar(outptr,"ALBEDOC")) then
    vari = outptr->ALBEDOC
  else
    if (isfilevar(inptr,"SOLIN")) then
      fsntoac = inptr->FSNTOAC
      sol     = inptr->SOLIN
      solin   = sol 
      solin   = mask(sol,sol.gt.0.0,True)
      albedoc = solin
      albedoc = (/(solin-fsntoac)/solin/)
      tmp     = dim_variance_n_Wrap(albedoc, 0)
    ;;tmp     = dim_variance_Wrap(albedoc(lat|:,lon|:,time|:))  ; original
      vari   = force_float(tmp)
      outptr->ALBEDOC = vari 
    else
      vari = -999.0
    end if
  end if
  return (vari)
end

function get_ALBSURF_VARIANCE (inptr:file,outptr:file)
local vari, tmp1, tmp2, fsds, fsns, albsurf, tmp
begin
  if (isfilevar(outptr,"ALBSURF")) then
    vari = outptr->ALBSURF
  else
    tmp1 = inptr->FSDS
    fsds = tmp1
    fsds = mask(tmp1,tmp1.gt.0.0,True)
    tmp2 = inptr->FSNS
    fsns = tmp2
    fsns = mask(tmp2,tmp2.gt.0.0,True)
    albsurf = fsds
    albsurf = (/(fsds-fsns)/fsds/)
    tmp     = dim_variance_n_Wrap(albsurf, 0)
  ;;tmp     = dim_variance_Wrap(albsurf(lat|:,lon|:,time|:))
    vari   = force_float(tmp)
    outptr->ALBSURF = vari  
  end if
  return (vari)
end

function get_EP_VARIANCE (inptr:file,outptr:file) 
local vari, qflx, precc, precl, ep, tmp
begin
  if (isfilevar(outptr,"EP")) then
    vari  = outptr->EP
  else
    qflx  = inptr->QFLX
    precc = inptr->PRECC
    precl = inptr->PRECL
    ep    = qflx 
    ep    = (/qflx*8.64e4-(precc+precl)*8.64e7/)  ; mm/day
    ep@units = "mm/day"                        ; DJS added
    tmp   = dim_variance_n_Wrap (ep, 0)
  ;;tmp   = dim_variance_Wrap (ep(lat|:,lon|:,time|:))
    vari  = force_float(tmp)
    outptr->EP = vari 
  end if

;;wallClockElapseTime(wcStrt, "get_EP_VARIANCE", 0)
  return (vari)
end 

function get_FLDS_VARIANCE (inptr:file,outptr:file) 
local vari, flns, ts, flds, tmp
begin
  if (isfilevar(outptr,"FLDS")) then
    vari   = outptr->FLDS
  else
    if (isfilevar(inptr,"FLNS") .and. isfilevar(inptr,"TS")) then
      flns = inptr->FLNS
      ts   = inptr->TS
      flds = flns 
      flds = (/(5.67e-8)*ts^4 - flns/)         ; W/m^2
      flds@units = "W/m^2"                     ; DJS added
      tmp  = dim_variance_n_Wrap (flds, 0)
    ;;tmp  = dim_variance_Wrap (flds(lat|:,lon|:,time|:))
      vari = force_float(tmp)
      outptr->FLDS = vari 
    else
      vari = -999.0
    end if
  end if
  return (vari)
end 

function get_FLDSC_VARIANCE (inptr:file,outptr:file) 
local vari, flnsc, ts, fldsc
begin
  if (isfilevar(outptr,"FLDSC")) then
    vari = outptr->FLDSC
  else
    if (isfilevar(inptr,"FLNSC") .and. isfilevar(inptr,"TS")) then
      flnsc = inptr->FLNSC
      ts    = inptr->TS
      fldsc = flnsc 
      fldsc = (/(5.67e-8)*ts^4 - flnsc/)       ; W/m^2
      fldsc@units = "W/m^2"                    ; DJS added
      tmp   = dim_variance_n_Wrap (fldsc, 0)
    ;;tmp   = dim_variance_Wrap (fldsc(lat|:,lon|:,time|:))
      vari  = force_float(tmp)
      outptr->FLDSC = vari 
    else
      vari = -999.0
    end if
  end if
  return (vari)
end 

function get_LWCFTOM_VARIANCE (inptr:file,outptr:file) 
local vari, flntc, flnt, lwcf, tmp
begin
  if (isfilevar(outptr,"LWCFTOM")) then
    vari  = outptr->LWCFTOM
  else
    flntc = inptr->FLNTC
    flnt  = inptr->FLNT
    lwcf  = flnt
    lwcf  = (/flntc-flnt/) 
    tmp   = dim_variance_n_Wrap (lwcf, 0)
  ;;tmp   = dim_variance_Wrap (lwcf(lat|:,lon|:,time|:))
    vari  = force_float(tmp)
    outptr->LWCFTOM = vari 
  end if
  return (vari)
end 

function get_PRECIP_VARIANCE (inptr:file,outptr:file) 
local vari, ndays, precc, precl, prect, tmp
begin
  if (isfilevar(outptr,"PRECIP")) then
    vari = outptr->PRECT
  else
    season = getenv("SEASON")
    if (season .eq. "DJF") then
      ndays = 90.
    end if
    if (season .eq. "JJA") then
      ndays = 92.
    end if
    if ( season .eq. "MAM") then
      ndays = 92.
    end if
    if (season .eq. "SON") then
      ndays = 91.
    end if
    if (season .eq. "ANN") then
      ndays = 365.
    end if
    precc = inptr->PRECC
    precl = inptr->PRECL
    prect = precc
    prect = (/(precc+precl)*86400.*100.*ndays/)   ; cm per season
    prect@units = "cm per season"                 ; DJS added
    tmp   = dim_variance_n_Wrap (prect, 0)
  ;;tmp   = dim_variance_Wrap (prect(lat|:,lon|:,time|:))
    vari  = force_float(tmp)
    outptr->PRECIP = vari 
  end if
  return (vari)
end 



function get_TTRP_VARIANCE (inptr:file,outptr:file)
local vari, temp, ttrp, tmp
begin
  if (isfilevar(outptr,"TTRP")) then
    vari = outptr->TTRP
  else
    temp = inptr->T   ; (time,lev,lat,lon)
    ttrp = (/dim_min_n(temp, 1) /)     ; (time,lat,lon)  
    tmp  = dim_variance_n_Wrap (ttrp, 0)  ; DJS added
    vari = force_float(tmp)
    vari!0 = "lat"
    vari!1 = "lon"
    vari&lat = temp&lat
    vari&lon = temp&lon
    outptr->TTRP = vari
  end if
  return (vari)
end


function get_PRECT_VARIANCE (inptr:file,outptr:file) 
local vari, precc, precl, prect, tmp
begin
  if (isfilevar(outptr,"PRECT")) then
    vari = outptr->PRECT
  else
    precc = inptr->PRECC
    precl = inptr->PRECL
    prect = precc
    prect = (/(precc+precl)*8.64e7/)   ; mm/day
    prect@units = "mm/day"             ; DJS added
    tmp   = dim_variance_n_Wrap (prect, 0)
  ;;tmp   = dim_variance_Wrap (prect(lat|:,lon|:,time|:))
    vari  = force_float(tmp)
    outptr->PRECT = vari 
  end if
  return (vari)
end 

function get_PRECT_OCEAN_VARIANCE (inptr:file,outptr:file) 
local vari, oro, ocnfrac
begin
  if (isfilevar(outptr,"PRECT_OCEAN")) then
    vari  = outptr->PRECT_OCEAN
  else
    prect = get_PRECT_VARIANCE (inptr,outptr)
    if (isfilevar(inptr,"ORO")) then
      oro  = inptr->ORO
      vari = mask(prect,oro,0) 
    else
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC
        vari    = mask(prect, ocnfrac.ge.0.5, True) 
      else
        print("PRECT_OCEAN_VARIANCE: no ORO or OCNFRAC variables") 
        vari = -999.
        return (vari)
      end if
    end if
    outptr->PRECT_OCEAN = vari 
  end if
  return (vari)
end 

function get_PRECST_VARIANCE (inptr:file,outptr:file) 
local vari, precsc, precsl, precst
begin
  if (isfilevar(outptr,"PRECST")) then
    vari = outptr->PRECST
  else
    if (isfilevar(inptr,"PRECSC")) then
      precsc = inptr->PRECSC
      precsl = inptr->PRECSL
      precst = precsc
      precst = (/(precsc+precsl)*8.64e7/)   ; mm/day
      precst@units = "mm/day"               ; DJS added
      tmp    = dim_variance_n_Wrap (precst, 0)
    ;;tmp    = dim_variance_Wrap (precst(lat|:,lon|:,time|:))
      vari   = force_float(tmp)
      outptr->PRECST = vari 
    else
      vari = -999.0
    end if
  end if
  return (vari)
end 

function get_PREH2O_VARIANCE (inptr:file,outptr:file) 
local vari, preh2o, mq, tmp
begin
  if (isfilevar(outptr,"PREH2O")) then
    vari = outptr->PREH2O
  else
    if (isfilevar(inptr,"TMQ") .or. isfilevar(inptr,"MQ")) then
      if (isfilevar(inptr,"TMQ")) then
        preh2o = inptr->TMQ
      else
        mq     = inptr->MQ
        preh2o = mq(:,0,:,:)  ; time,lev,lat,lon
        preh2o = dim_sum(mq(time|:,lat|:,lon|:,lev|:))
      end if
      tmp  = dim_variance_n_Wrap (preh2o, 0)
    ;;tmp  = dim_variance_Wrap (preh2o(lat|:,lon|:,time|:))
      vari = force_float(tmp)
      outptr->PREH2O = vari 
    else
      vari = -999.0
    end if
  end if
  return (vari)
end 

function get_PREH2O_OCEAN_VARIANCE (inptr:file,outptr:file) 
local vari, oro, ocnfrac
begin
  if (isfilevar(outptr,"PREH2O_OCEAN")) then
    vari   = outptr->PREH2O_OCEAN
  else
    preh2o = get_PREH2O_VARIANCE (inptr,outptr)
    if (isfilevar(inptr,"ORO")) then
      oro  = inptr->ORO
      vari = mask(preh2o,oro,0) 
    else
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC
        vari    = mask(preh2o,ocnfrac.ge.0.5,rue) 
      else
        print("PREH2O_OCEAN_VARIANCE: no ORO or OCNFRAC variables") 
        vari = -999.
        return (vari)
      end if
    end if
    outptr->PREH2O_OCEAN = vari 
  end if

;;wallClockElapseTime(wcStrt, "get_PREH2O_OCEAN_VARIANCE", 0)
  return (vari)
end 

function get_PS_VARIANCE (inptr:file,outptr:file) 
local vari, ps, tmp
begin
  if (isfilevar(outptr,"PS")) then
    vari = outptr->PS
  else
    ps   = inptr->PS
    ps   = (/ps/100./)   ; mb 
    ps@units = "hPa"
    tmp  = dim_variance_n_Wrap (ps, 0)
  ;;tmp  = dim_variance_Wrap (ps(lat|:,lon|:,time|:))
    vari = force_float(tmp)
    outptr->PS = vari 
  end if
  return (vari)
end 

function get_PSL_VARIANCE (inptr:file,outptr:file) 
local vari, psl, tmp
begin
  if (isfilevar(outptr,"PSL")) then
    vari = outptr->PSL
  else
    psl  = inptr->PSL
    psl  = (/psl/100./)   ; mb 
    psl@units = "hPa"
    tmp  = dim_variance_n_Wrap (psl, 0)
  ;;tmp  = dim_variance_Wrap (psl(lat|:,lon|:,time|:))
    vari = force_float(tmp)
    outptr->PSL = vari 
  end if
  return (vari)
end 

function get_QFLX_VARIANCE (inptr:file,outptr:file) 
local vari, qflx, tmp
begin
  if (isfilevar(outptr,"QFLX")) then
    vari = outptr->QFLX
  else
    qflx = inptr->QFLX
    qflx = (/qflx*8.64e4/)   ; mm/day
    qflx@units = "mm/day"
    tmp  = dim_variance_n_Wrap (qflx, 0)
  ;;tmp  = dim_variance_Wrap (qflx(lat|:,lon|:,time|:))
    vari = force_float(tmp)
    outptr->QFLX = vari 
  end if
  return (vari)
end 

function get_RESSURF_VARIANCE (inptr:file,outptr:file) 
local vari, fsns, flns, shflx, qflx, Lv \
    , Lf, precc, precl, precsc, precsl, lhflx, ressurf, tmp
begin
  if (isfilevar(outptr,"RESSURF")) then
    vari = outptr->RESSURF
  else
    fsns  = inptr->FSNS      ; W/m^2
    flns  = inptr->FLNS      ; W/m^2
    shflx = inptr->SHFLX     ; W/m^2
    qflx  = inptr->QFLX      ; kg/(m^2 s)
    Lv    = 2.501e6          ; J/kg
    if (isfilevar(inptr,"PRECSC").and.isfilevar(inptr,"PRECSL")) then
      precc  = inptr->PRECC    ; m/s
      precl  = inptr->PRECL    ; m/s
      precsc = inptr->PRECSC   ; m/s
      precsl = inptr->PRECSL   ; m/s
      Lf     = 3.337e5         ; J/kg
      lhflx  = qflx
      lhflx  = (/(Lv+Lf)*qflx - Lf*1.e3*(precc+precl-precsc-precsl)/)
      lhflx@derive_op = "(Lv+Lf)*qflx-Lf*(prect-precsc-precl)"
    else
      lhflx  = qflx
      lhflx  = (/Lv*qflx/)              ; W/m^2
      lhflx@derive_op = "Lv*qflx"
    end if
    ressurf  = fsns
    ressurf  = (/fsns-flns-shflx-lhflx/)
    tmp      = dim_variance_n_Wrap (ressurf, 0)
  ;;tmp      = dim_variance_Wrap (ressurf(lat|:,lon|:,time|:))
    vari     = force_float(tmp)
    outptr->RESSURF = vari 
  end if

;;wallClockElapseTime(wcStrt, "get_RESSURF_VARIANCE", 0)
  return (vari)
end 

function get_SNOWFALL_VARIANCE (inptr:file,outptr:file) 
local vari, snowc, snowl, snowfall, tmp2, tmpvar
begin
  if (isfilevar(outptr,"SNOWFALL")) then
    vari = outptr->SNOWFALL
  else
    snowc    = inptr->CPLSNOWC
    snowl    = inptr->CPLSNOWL
    snowfall = snowc
    snowfall = (/(snowc+snowl)*86400./)   ;  convert to mm/day
    snowfall@units = "mm/day"
    tmp2     = dim_variance_n_Wrap (snowfall, 0)
  ;;tmp2     = dim_variance_Wrap (snowfall(lat|:,lon|:,time|:))
    tmpvar   = tmp2
    if (any(tmp2.le.0)) then    ; set variance = 0.0 to missing
      tmpvar = mask(tmpvar,tmp2.gt.0,True)
    end if
    vari     = force_float(tmpvar)
    outptr->SNOWFALL = vari 
  end if
  return (vari)
end 

function get_SNOWH_VARIANCE (inptr:file,outptr:file,var:string) 
local vari, snowh, tmp, icefrac, lndfrac, tmp2, tmpvar
begin
  if (isfilevar(outptr,var)) then
    vari  = outptr->$var$
  else
    snowh = inptr->$var$
    tmp   = snowh            ; meters
    if (var .eq. "SNOWH") then
      tmp = (/snowh*100./)   ;  convert to cm 
      tmp@units = "cm"       ; DJS added
    else
      if (var .eq. "SNOWHICE") then
        icefrac = inptr->ICEFRAC
        tmp     = (/mask(snowh,icefrac.gt.0,True)*1000./) ; convert to mm 
        tmp@units = "mm"
      else        ; SNOWHLND
        lndfrac = inptr->LANDFRAC
        tmp = (/mask(snowh,lndfrac.gt.0,True)*100./)  ; convert to cm 
        tmp@units = "cm"
      end if
    end if
    tmp2   = dim_variance_n_Wrap (tmp, 0)
  ;;tmp2   = dim_variance_Wrap (tmp(lat|:,lon|:,time|:))
    tmpvar = tmp2
    if (any(tmp2.le.0)) then    ; set variance = 0.0 to missing
      tmpvar = mask(tmpvar,tmp2.gt.0,True)
    end if
    vari     = force_float(tmpvar)
    outptr->$var$ = vari 
  end if
  return (vari)
end 

function get_SWCFTOM_VARIANCE (inptr:file,outptr:file) 
local vari, fsntc, fsnt, swcf, mp, tmpvar
begin
  if (isfilevar(outptr,"SWCFTOM")) then
    vari = outptr->SWCFTOM
  else
    fsntc = inptr->FSNTC
    fsnt  = inptr->FSNT
    swcf  = fsnt
    swcf  = (/fsnt-fsntc/) 
    tmp   = dim_variance_n_Wrap (swcf, 0)
  ;;tmp   = dim_variance_Wrap (swcf(lat|:,lon|:,time|:))
    tmpvar = tmp
    if (any(tmp.le.0)) then    ; set variance <= 0.0 to missing
      tmpvar = mask(tmpvar,tmp.gt.0,True)
    end if
    vari     = force_float(tmpvar)
    outptr->SWCFTOM = vari 
  end if
  return (vari)
end 

function get_TGCLDLWP_OCEAN_VARIANCE (inptr:file,outptr:file) 
local vari, tgcldlwp, oro, ocnfrac
begin
  if (isfilevar(outptr,"TGCLDLWP_OCEAN")) then
    vari = outptr->TGCLDLWP_OCEAN
  else
    tgcldlwp = get_VARIANCE (inptr,outptr,"TGCLDLWP")
    if (isfilevar(inptr,"ORO")) then
      oro  = inptr->ORO
      vari = mask(tgcldlwp,oro,0) 
    else
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC
        vari    = mask(tgcldlwp,ocnfrac.ge.0.5,True) 
      else
        print("TGCLDLWP_OCEAN_VARIANCE: no ORO or OCNFRAC variables") 
        vari = -999.
        return (vari)
      end if
    end if
    outptr->TGCLDLWP_OCEAN = vari 
  end if
  return (vari)
end 

function get_TICLDIWP_VARIANCE (inptr:file,outptr:file)
local vari, icldiwp, ticldiwp, tmp
begin
  if (isfilevar(outptr,"TICLDIWP")) then
    vari = outptr->TICLDIWP
  else
    if (isfilevar(inptr,"ICLDIWP")) then
      icldiwp  = inptr->ICLDIWP               ; (time,lev,lat,lon)
      ticldiwp = dim_sum_n_Wrap(icldiwp,1)    ; (time,lat,lon)
    ;;ticldiwp = icldiwp(:,0,:,:)             ; (time,lat,lon)
    ;;ticldiwp = dim_sum(icldiwp(time|:,lat|:,lon|:,lev|:))
      tmp      = dim_variance_n_Wrap (ticldiwp, 0)
    ;;tmp      = dim_variance_Wrap (ticldiwp(lat|:,lon|:,time|:))
      vari     = force_float(tmp)
      outptr->TICLDIWP = vari 
    else
      vari = -999.0
    end if
  end if
  return (vari)
end

function get_TICLDLIQWP_VARIANCE (inptr:file,outptr:file)
local vari, icldiwp, liq, ticldliqwp, tmp
begin
  if (isfilevar(outptr,"TICLDLIQWP")) then
    vari = outptr->TICLDLIQWP
  else
    if (isfilevar(inptr,"ICLDIWP") .and. isfilevar(inptr,"ICLDLWP")) then
      icldiwp = inptr->ICLDIWP                ; (time,lev,lat,lon)
      icldlwp = inptr->ICLDLWP                ; (time,lev,lat,lon)
      liq     = icldiwp
      liq     = (/icldlwp-icldiwp/)           ; liquid = total - ice
      ticldliqwp = dim_sum_n_Wrap(liq, 1)
      ticldliqwp@long_name  = "liquid only total"    ; DJS added
      ticldliqwp@derived_op = "(/ICLDLWP-ICLDIWP/)"  ; DJS added
    ;;ticldliqwp = liq(:,0,:,:)   ; (time,lat,lon)
    ;;ticldliqwp = dim_sum(liq(time|:,lat|:,lon|:,lev|:))
      tmp     = dim_variance_n_Wrap (ticldliqwp, 0)
    ;;tmp = dim_variance_Wrap (ticldliqwp(lat|:,lon|:,time|:))
      vari       = force_float(tmp)
      outptr->TICLDLIQWP = vari 
    else
      vari = -999.0
    end if
  end if
  return (vari)
end


function get_TICLDLWP_VARIANCE (inptr:file,outptr:file)
local vari, icldlwp, ticldlwp, tmp
begin
  if (isfilevar(outptr,"TICLDLWP")) then
    vari = outptr->TICLDLWP
  else
    if (isfilevar(inptr,"ICLDLWP")) then
      icldlwp  = inptr->ICLDLWP                ; (time,lev,lat,lon)
      ticldlwp = dim_sum_n_Wrap(icldlwp, 1)    ; (time,lat,lon)
      tmp      = dim_variance_n_Wrap (ticldlwp, 0)
      vari     = force_float(tmp)
      outptr->TICLDLWP = vari 
    else
      vari = -999.0
    end if
  end if
  return (vari)
end


function get_TREFHT_LAND_VARIANCE (inptr:file,outptr:file) 
local vari, trefht, oro, landfrac
begin
  if (isfilevar(outptr,"TREFHT_LAND")) then
    vari = outptr->TREFHT_LAND
  else
    trefht = get_VARIANCE (inptr,outptr,"TREFHT")
    if (isfilevar(inptr,"ORO")) then
      oro  = inptr->ORO
      vari = mask(trefht,oro,1) 
    else
      if (isfilevar(inptr,"LANDFRAC")) then
        landfrac = inptr->LANDFRAC
        vari     = mask(trefht,landfrac.ge.0.5,True) 
      else
        print("TREFHT_LAND_VARIANCE: no ORO or LANDFRAC variables") 
        vari = -999.
        return (vari)
      end if
    end if
    outptr->TREFHT_LAND = vari 
  end if
  return (vari)
end 

function get_PLEVEL_VARIANCE (inptr:file,outptr:file,var:string,plev:numeric)
local vari, hyam, hybm, ps, u, v, psi, chi, tmp, vvpuu, uu, vv
begin
  if (isfilevar(outptr,var)) then
    vari  = outptr->$var$
  else
    hyam  = inptr->hyam
    hybm  = inptr->hybm
    ps    = inptr->PS   ; Pa 
    if (var.eq."CHI_200" .or. var.eq."PSI_200") then
      u   = inptr->U
      v   = inptr->V
      psi = u
      chi = u
      uv2sfvpg(u,v,psi,chi)
      if (var.eq."CHI_200") then
        tmp = chi
      else
        tmp = psi
      end if
    end if
    if (var.eq."EKE_850") then
      u = inptr->U
      v = inptr->V
      if (isfilevar(inptr,"VVPUU")) then
        vvpuu = inptr->VVPUU
        tmp   = vvpuu
        tmp   = (/(vvpuu - (v^2+u^2))/2./) 
      else
        uu    = inptr->UU
        vv    = inptr->VV
        tmp   = vv
        tmp   = (/(vv+uu-(v^2+u^2))/2./)
      end if
    end if
    if (var.eq."T_200" .or. var.eq."T_850") then
      tmp = inptr->T
    end if
    if (var .eq. "U_200") then
      tmp = inptr->U
    end if
    if (var .eq. "VT_850") then
      tmp = inptr->VT
    end if
    if (var.eq."Z3_300" .or. var.eq."Z3_500") then
      tmp = inptr->Z3         ; (time,lev,lat,lon)
    end if

    tmp_lev = vinth2p (tmp,hyam,hybm,plev,ps,2,1000.,1,False) 

    if (var .eq. "CHI_200") then
      tmp_lev = (/tmp_lev/1.e6/)
    end if
    if (var .eq. "PSI_200") then
      tmp_lev = (/tmp_lev/1.e7/)
    end if
    if (var.eq."Z3_300" .or. var.eq."Z3_500" .or. var.eq."VT_850") then
      tmp_lev = (/tmp_lev/100./)      
    end if

    tmpvar = dim_variance_n_Wrap (tmp_lev, 0)
  ;;tmpvar = dim_variance_Wrap (tmp_lev(lev_p|:,lat|:,lon|:,time|:))

    vari   = force_float(tmpvar(0,:,:))
    outptr->$var$ = vari 
  end if
  return (vari)
end

