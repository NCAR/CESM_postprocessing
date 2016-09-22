; NCL script
; functions_vertical.ncl
; Mark Stevens, Sept 2001
;************************************************************************
p0     = 1000.     ; mb required by vinth2p
interp = 2         ; log interpolation
extrap = False     ; no extrapolation past psfc.
; for comparison with OBS data interpolate the model data to these 
; 16 constant pressure levels 
plvlO = (/30.,50.,70.,100.,150.,200.,250.,300.,400.,500.,600.,700., \
          775.,850.,925.,1000./)
plvlO@units = "mb"
nplvlO = 16
; These are the GFDL model level pressure levels 
plvlG = (/1000.,925.,850.,700.,600.,500.,400.,300.,250.,200.,150.,100.,70.,50.,30.,20.,10./)
plvlG@units = "mb"
nplvlG = 17
; for comparison with another model interpolate the model data to these
; 25 constant pressure levels
plvlM = (/30.,50.,70.,100.,150.,200.,250.,300.,350.,400.,450.,500.,550., \
          600.,650.,700.,750.,800.,850.,875.,900.,925.,950.,975.,1000./)
plvlM@units = "mb"
nplvlM = 25
; TOM to bottom is the order of the model data
; bottom to TOM is the order of the OBS data
; flip levels before returning for plots and comparison with OBS data
;-----------------------------------------------------------------------

function vertical_xz_CLOUD (inptr:file,outptr:file,latlim:float)
begin
  
  cld = inptr->CLOUD(0,:,:,:)
  if (inptr@source .eq. "GFDL") then
    tmp = int2p_n_Wrap(plvlG,cld,plvlM(::-1),2,0)
    cloud = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    cloud@units = "fraction"
    cloud@long_name = "Cloud fraction"
    return (cloud)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    tmp = vinth2p(cld,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      cloud3 = dble2flt(tmp)
    else
      cloud3 = tmp                  ; 3D array (lev,lat,lon)
    end if
    cloud = dim_avg_Wrap(cloud3(lev_p|:,lon|:,{lat|-latlim:latlim}))     ; zonal ave -->(lev,lat) 
    cloud@units = "fraction"
    cloud@long_name = "Cloud fraction"
    assignFillValue(cloud,cloud)
  end if

  return (cloud(::-1,:))   ; bottom to TOM for plots
end

function vertical_xz_CWAT (inptr:file,outptr:file,latlim:float)
begin
  if (isfilevar(inptr,"CWAT")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    cw = inptr->CWAT(0,:,:,:)   ; kg/kg
    tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      cwat3 = dble2flt(tmp)
    else
      cwat3 = tmp
    end if
    cwat = dim_avg_Wrap(cwat3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    cwat = (/cwat*1000./)   ; convert to g/kg
    cwat@derive_op = "CWAT*1000."
    cwat@long_name = "Cloud water"
    cwat@units = "g/kg"
    
  else
    if (isfilevar(inptr,"CLDICE").and.isfilevar(inptr,"CLDLIQ")) then
      cldice = inptr->CLDICE(0,:,:,:)   ; kg/kg
      cldliq = inptr->CLDLIQ(0,:,:,:)   ; kg/kg
      cw = cldice              
      cw = (/cldice+cldliq/)
      if (inptr@source .eq. "GFDL") then
        tmp = int2p_n_Wrap(plvlG,cw,plvlM(::-1),2,0)
        cwat = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
        cwat = (/cwat*1000./)   ; convert to g/kg
        cwat@long_name = "Cloud ice+liquid"
        cwat@units = "g/kg"
        return (cwat)
      else
        hyam = inptr->hyam
        hybm = inptr->hybm
        ps = inptr->PS(0,:,:) 
        tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
        if (typeof(tmp).eq."double") then
          cwat3 = dble2flt(tmp)
        else
          cwat3 = tmp
        end if
        cwat = dim_avg_Wrap(cwat3(lev_p|:,lon|:,{lat|-latlim:latlim}))
        cwat = (/cwat*1000./)   ; convert to g/kg
        cwat@derive_op = "(CLDICE+CLDLIQ)*1000."
        cwat@long_name = "Cloud ice+liquid"
        cwat@units = "g/kg"
        
      end if
    else
      cwat = -999.
      return (cwat)
    end if
  end if
  
  return (cwat(::-1,:))
end


function vertical_xz_ICWMR (inptr:file,outptr:file,latlim:float)
begin
  if (isfilevar(inptr,"ICWMR")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    cw = inptr->ICWMR(0,:,:,:)   ; kg/kg
    tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      icwmr3 = dble2flt(tmp)
    else
      icwmr3 = tmp
    end if
    icwmr = dim_avg_Wrap(icwmr3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    icwmr = (/icwmr*1000./)   ; convert to g/kg
    icwmr@derive_op = "ICWMR*1000."
    icwmr@long_name = "In-Cloud liquid"
    icwmr@units = "g/kg"
  else
    icwmr = -999.
    return (icwmr)
  end if
  return (icwmr(::-1,:))
end

function vertical_xz_ICIMR (inptr:file,outptr:file,latlim:float)
begin
  if (isfilevar(inptr,"ICIMR")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    cw = inptr->ICIMR(0,:,:,:)   ; kg/kg
    tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      icimr3 = dble2flt(tmp)
    else
      icimr3 = tmp
    end if
    icimr = dim_avg_Wrap(icimr3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    icimr = (/icimr*1000./)   ; convert to g/kg
    icimr@derive_op = "ICIMR*1000."
    icimr@long_name = "In-Cloud ice"
    icimr@units = "g/kg"
  else
    icimr = -999.
    return (icimr)
  end if
  return (icimr(::-1,:))
end

function vertical_xz_GCLDLWP_ICE (inptr:file,outptr:file,latlim:float)
begin

  if (isfilevar(inptr,"FICE").and.isfilevar(inptr,"GCLDLWP")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    ice = inptr->FICE(0,:,:,:)
    cld = inptr->GCLDLWP(0,:,:,:) 
    gcld = ice
    gcld = (/1000.*cld*ice/)
    tmp = vinth2p(gcld,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      gcldlwp3 = dble2flt(tmp)
    else
      gcldlwp3 = tmp
    end if
    gcldlwp_ice = dim_avg_Wrap(gcldlwp3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    gcldlwp_ice@long_name = "Grd-box cloud LWP (ice only)"
    gcldlwp_ice@units = "g/m~S~2~N~"
    assignFillValue(gcldlwp_ice,gcldlwp_ice)
  else
    print ("GCLDLWP_ICE: missing FICE or GCLDLWP variables")
    gcldlwp_ice = -999.
    return (gcldlwp_ice)
  end if
  
  return (gcldlwp_ice(::-1,:))
end

function vertical_xz_GCLDLWP_LIQUID (inptr:file,outptr:file,latlim:float)
begin

  if (isfilevar(inptr,"FICE").and.isfilevar(inptr,"GCLDLWP")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    ice = inptr->FICE(0,:,:,:)
    cld = inptr->GCLDLWP(0,:,:,:) 
    gcld = ice 
    gcld = (/1000.*cld*(1.-ice)/) ; kg/m3->g/m3
    tmp = vinth2p(gcld,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      gcldlwp3 = dble2flt(tmp)
    else
      gcldlwp3 = tmp
    end if
    gcldlwp_lqd = dim_avg_Wrap(gcldlwp3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    gcldlwp_lqd@long_name = "Grd-box cloud LWP (lqd only)"
    gcldlwp_lqd@units = "g/m~S~2~N~"
    assignFillValue(gcldlwp_lqd,gcldlwp_lqd)
    
  else
;     print ("GCLDLWP_LIQUID: missing FICE or GCLDLWP variables")
    gcldlwp_lqd = -999.
    return (gcldlwp_lqd)
  end if
  
  return (gcldlwp_lqd(::-1,:))
end

function vertical_xz_ICLDIWP (inptr:file,outptr:file,latlim:float)
begin

  if (isfilevar(inptr,"ICLDIWP")) then 
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    ice = inptr->ICLDIWP(0,:,:,:)
    tmp = vinth2p(ice,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      icldiwp3 = dble2flt(tmp)
    else
      icldiwp3 = tmp
    end if
    icldiwp = dim_avg_Wrap(icldiwp3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    icldiwp@long_name = "In-cloud ice WP"
    icldiwp@units = "g/m~S~2~N~"
    assignFillValue(icldiwp,icldiwp)
    
  else
    icldiwp = -999.
    return(icldiwp)
  end if

  return (icldiwp(::-1,:))
end

function vertical_xz_ICLDTWP (inptr:file,outptr:file,latlim:float)
begin

  if (isfilevar(inptr,"ICLDIWP") .and. isfilevar(inptr,"ICLDTWP")) then 
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    total = inptr->ICLDTWP(0,:,:,:)   ; ice+liquid
    ice = inptr->ICLDIWP(0,:,:,:)
    liq = total
    liq = (/1000.*(total-ice)/)               ; (lev,lat,lon)
    tmp = vinth2p(liq,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      icldtwp3 = dble2flt(tmp)
    else
      icldtwp3 = tmp
    end if
    icldtwp = dim_avg_Wrap(icldtwp3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    icldtwp@long_name = "In-cloud liquid WP"
    icldtwp@units = "g/m~S~2~N~"
    assignFillValue(icldtwp,icldtwp)
    
  else
    if (isfilevar(inptr,"ICLDTWP")) then    ; ice+liquid
      hyam = inptr->hyam
      hybm = inptr->hybm
      ps = inptr->PS(0,:,:) 
      ic = inptr->ICLDTWP(0,:,:,:)
      tmp = vinth2p(ic,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        icldtwp3 = dble2flt(tmp)
      else
        icldtwp3 = tmp
      end if
      icldtwp = dim_avg_Wrap(icldtwp3(lev_p|:,lon|:,{lat|-latlim:latlim}))
      icldtwp@long_name = "In-cloud ice+liquid WP"
      icldtwp@units = "g/m~S~2~N~"
      assignFillValue(icldtwp,icldtwp)
      
    else
      icldtwp = -999.
      return (icldtwp)
    end if
  end if
  
  return (icldtwp(::-1,:))
end

function vertical_xz_OMEGA (inptr:file,outptr:file,latlim:float,compare:string)
begin
  
  om = inptr->OMEGA(0,:,:,:)
  if (inptr@source .eq. "GFDL") then
    if (compare .eq. "OBS")
      tmp = int2p_n_Wrap(plvlG,om,plvlO(::-1),2,0)
    else
      tmp = int2p_n_Wrap(plvlG,om,plvlM(::-1),2,0)
    end if
    omega = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    omega = (/omega*864./)     ; 86400/100 to convert to mb/day
    omega@units = "mb/day"
    omega@long_name = "Vertical pressure velocity"
    
    return (omega)                          ; bottom to TOP  for plots
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    if (compare .eq. "OBS") then
      tmp = vinth2p(om,hyam,hybm,plvlO,ps,interp,p0,1,extrap)
    else
      tmp = vinth2p(om,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    end if
    if (typeof(tmp).eq."double") then
      omega3 = dble2flt(tmp)
    else
      omega3 = tmp
    end if
    omega = dim_avg_Wrap(omega3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    omega = (/omega*864./)     ; 86400/100 to convert to mb/day
    omega@derive_op = "OMEGA*864."
    omega@units = "mb/day"
    omega@long_name = "Vertical pressure velocity"
    assignFillValue(omega,omega)
    
  end if

  return (omega(::-1,:))
end

function vertical_xz_QRL (inptr:file,outptr:file,latlim:float)
begin
  qlw = inptr->QRL(0,:,:,:)
  if (inptr@source .eq. "GFDL") then
    tmp = int2p_n_Wrap(plvlG,qlw,plvlM(::-1),2,0)
    qrl = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    qrl = (/qrl*86400./)     ; convert to K/day
    qrl@units = "K/day"
    qrl@long_name = "LW heating rate"
    
    return (qrl)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    tmp = vinth2p(qlw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      qrl3 = dble2flt(tmp)
    else
      qrl3 = tmp
    end if
    qrl = dim_avg_Wrap(qrl3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    qrl = (/qrl*86400./)     ; convert to K/day
    qrl@derive_op = "QRL*86400."
    qrl@units = "K/day"
    qrl@long_name = "LW heating rate"
    assignFillValue(qrl,qrl)
    
  end if
  
  return (qrl(::-1,:))
end

function vertical_xz_QRS (inptr:file,outptr:file,latlim:float)
begin
  
  qsw = inptr->QRS(0,:,:,:)
  if (inptr@source .eq. "GFDL") then
    tmp = int2p_n_Wrap(plvlG,qsw,plvlM(::-1),2,0)
    qrs = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    qrs = (/qrs*86400./)     ; convert to K/day
    qrs@units = "K/day"
    qrs@long_name = "SW heating rate"
    
    return (qrs)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    tmp = vinth2p(qsw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      qrs3 = dble2flt(tmp)
    else
      qrs3 = tmp
    end if
    qrs = dim_avg_Wrap(qrs3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    qrs = (/qrs*86400./)     ; convert to K/day
    qrs@derive_op = "QRS*86400."
    qrs@units = "K/day"
    qrs@long_name = "SW heating rate"
    assignFillValue(qrs,qrs)
    
  end if

  return (qrs(::-1,:))
end

function vertical_xz_RELHUM (inptr:file,outptr:file,latlim:float,compare:string)
begin
  
  rh = inptr->RELHUM(0,:,:,:)
  if (inptr@source .eq. "GFDL") then
    if (compare .eq. "OBS")
      tmp = int2p_n_Wrap(plvlG,rh,plvlO(::-1),2,0)
    else
      tmp = int2p_n_Wrap(plvlG,rh,plvlM(::-1),2,0)
    end if
    rhum = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    rhum@long_name = "Relative humidity"
    rhum@units = "percent"
    
    return (rhum)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    if (compare .eq. "OBS") then
      tmp = vinth2p(rh,hyam,hybm,plvlO,ps,interp,p0,1,extrap)
    else
      tmp = vinth2p(rh,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    end if
    if (typeof(tmp).eq."double") then
      rhum3 = dble2flt(tmp)
    else
      rhum3 = tmp
    end if
    rhum = dim_avg_Wrap(rhum3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    rhum@long_name = "Relative humidity"
    rhum@units = "percent"
    assignFillValue(rhum,rhum)
    
  end if

  return (rhum(::-1,:))
end

function vertical_xz_SHUM (inptr:file,outptr:file,latlim:float,compare:string)
begin
  
  q = inptr->Q(0,:,:,:)
  if (inptr@source .eq. "GFDL") then
    if (compare .eq. "OBS")
      tmp = int2p_n_Wrap(plvlG,q,plvlO(::-1),2,0)
    else
      tmp = int2p_n_Wrap(plvlG,q,plvlM(::-1),2,0)
    end if
    shum = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    shum = (/shum*1000./)             ; convert to g/kg
    shum@units = "g/kg"
    shum@long_name = "Specific humidity"
    
    return (shum)                          ; bottom to TOP  for plots
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    if (compare .eq. "OBS")
      tmp = vinth2p(q,hyam,hybm,plvlO,ps,interp,p0,1,extrap)
    else
      tmp = vinth2p(q,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    end if
  end if
  if (typeof(tmp).eq."double") then
    shum3 = dble2flt(tmp)
  else
    shum3 = tmp
  end if
  shum = dim_avg_Wrap(shum3(lev_p|:,lon|:,{lat|-latlim:latlim}))
  shum = (/shum*1000./)             ; convert to g/kg
  shum@derive_op = "SHUM=Q*1000."
  shum@units = "g/kg"
  shum@long_name = "Specific humidity"
  assignFillValue(shum,shum)
  
  return (shum(::-1,:))  ; bottom to TOM for plots
end

function vertical_xz_T (inptr:file,outptr:file,latlim:float,compare:string)
begin
  
  t = inptr->T(0,:,:,:)
  if (inptr@source .eq. "GFDL") then
    if (compare .eq. "OBS")
      tmp = int2p_n_Wrap(plvlG,t,plvlO(::-1),2,0)
    else
      tmp = int2p_n_Wrap(plvlG,t,plvlM(::-1),2,0)
    end if
    temp = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    temp@long_name = "Temperature"
    temp@units = "K"
    
    return (temp)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    if (compare .eq. "OBS")
      tmp = vinth2p(t,hyam,hybm,plvlO,ps,interp,p0,1,extrap)
    else
      tmp = vinth2p(t,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    end if
    if (typeof(tmp).eq."double") then
      temp3 = dble2flt(tmp)
    else
      temp3 = tmp
    end if
    temp = dim_avg_Wrap(temp3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    temp@long_name = "Temperature"
    temp@units = "K"
    assignFillValue(temp,temp)
    
  end if
  
  return (temp(::-1,:))
end

function vertical_xz_TDH (inptr:file,outptr:file,latlim:float)
begin
  
  if (isfilevar(inptr,"DTCOND") .and. isfilevar(inptr,"DTV")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    dtcond = inptr->DTCOND(0,:,:,:)
    dtv = inptr->DTV(0,:,:,:)
    qrs = inptr->QRS(0,:,:,:)
    qrl = inptr->QRL(0,:,:,:)
    dh = dtcond
    if (isfilevar(inptr,"DTH")) then
      dth = inptr->DTH(0,:,:,:)
      dh = (/dtcond + qrs + qrl + dtv + dth/)
    else
      dh = (/dtcond + qrs + qrl + dtv/)    ; finite volume
    end if
    tmp = vinth2p(dh,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      tdh3 = dble2flt(tmp)
    else
      tdh3 = tmp
    end if
    tdh = dim_avg_Wrap(tdh3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    tdh = (/tdh*86400./)    ; convert to K/day
    tdh@long_name = "Total diabatic heating"
    tdh@units = "K/day" 
    assignFillValue(tdh,tdh)
    
  else
;     print("TDH: missing DTCOND or DTV variables")
    tdh = -999.
    return (tdh)
  end if
  
  return (tdh(::-1,:))
end

function vertical_xz_TDM (inptr:file,outptr:file,latlim:float)
begin
  
  if (isfilevar(inptr,"VD01")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    vd = inptr->VD01(0,:,:,:)
    if (isfilevar(inptr,"DCQ")) then
      dc = inptr->DCQ(0,:,:,:)
    else
      if (isfilevar(inptr,"DC01")) then
        dc = inptr->DC01(0,:,:,:)
      else
;         print ("TDM: missing DCQ and DC01 variable")
        tdm = -999.
        return (tdm)
      end if
    end if
    dm = dc
    dm = (/(dc+vd)/)
    tmp = vinth2p(dm,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      tdm3 = dble2flt(tmp)
    else
      tdm3 = tmp
    end if
    tdm = dim_avg_Wrap(tdm3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    tdm = (/tdm*8.64e7/)    ; convert to g(kg*day) 
    tdm@long_name = "Total diabatic moistening"
    tdm@units = "g/kg day~S~-1~N~"
    tdm@derive_op = "(DC01+VD01)*8.64e7"
    assignFillValue(tdm,tdm)
    
  else
;     print ("TDM: missing VD01 variable")
    tdm = -999.
    return (tdm)
  end if

  return (tdm(::-1,:))
end

function vertical_xz_U (inptr:file,outptr:file,latlim:float,compare:string)
begin
  u = inptr->U(0,:,:,:)
  if (inptr@source .eq. "GFDL") then
    if (compare .eq. "OBS")
      tmp = int2p_n_Wrap(plvlG,u,plvlO(::-1),2,0)
    else
      tmp = int2p_n_Wrap(plvlG,u,plvlM(::-1),2,0)
    end if
    uwind = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    uwind@long_name = "Zonal Wind"
    uwind@units = "m/s"
    
    return (uwind)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    if (compare .eq. "OBS")
      tmp = vinth2p(u,hyam,hybm,plvlO,ps,interp,p0,1,extrap)
    else
      tmp = vinth2p(u,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    end if
    if (typeof(tmp).eq."double") then
      uwind3 = dble2flt(tmp)
    else
      uwind3 = tmp
    end if
    uwind = dim_avg_Wrap(uwind3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    uwind@long_name = "Zonal wind"
    uwind@units = "m/s" 
    assignFillValue(uwind,uwind)
    
  end if
  
  return (uwind(::-1,:))
end

function vertical_xz_UQ (inptr:file,outptr:file,latlim:float)
begin
  if (isfilevar(inptr,"UQ")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    uqt = inptr->UQ(0,:,:,:)
    tmp = vinth2p(uqt,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      uq3 = dble2flt(tmp)
    else
      uq3 = tmp
    end if
    uq = dim_avg_Wrap(uq3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    uq = (/uq*1000./)       ; convert to m/s g/kg
    assignFillValue(uq,uq)
    uq@long_name = "Zononal water transport"
    uq@units = "m/s g/kg"
    
  else
    uq = -999.
    return (uq)
  end if

  return (uq(::-1,:))
end

function vertical_xz_UT (inptr:file,outptr:file,latlim:float)
begin
  
  if (isfilevar(inptr,"UT")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    utt = inptr->UT(0,:,:,:)
    tmp = vinth2p(utt,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      ut3 = dble2flt(tmp)
    else
      ut3 = tmp
    end if
    ut = dim_avg_Wrap(ut3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    ut = (/ut/100./)       ; scale for plots 
    assignFillValue(ut,ut)
    ut@long_name = "Zonal heat transport"
    ut@units = "K m/s x 100"
    
  else
    ut = -999.
    return (ut)
  end if
  
  return (ut(::-1,:))
end

;-------------------------------------------------------------------
; STATIONARY EDDY FLUXES
;------------------------------------------------------------------
function stationary_xz (a[*][*][*]:numeric,b[*][*][*]:numeric,latlim)
; input: a(lev,lat,lon) model variable
;        b(lev,lat,lon) model variable       
begin
  nlat = dimsizes(a&lat)
; zonal average of input variables
  za = dim_avg_Wrap(a(lev|:,lon|:,{lat|-latlim:latlim}))    ; (lev,lat)
  zb = dim_avg_Wrap(b(lev|:,lon|:,{lat|-latlim:latlim}))    ; (lev,lat)
  astar = a       
  bstar = b
  do n = 0, nlat-1
    astar(:,n,:) = (/a(:,n,:) - za/)
    bstar(:,n,:) = (/b(:,n,:) - zb/)
  end do
  astar_bstar = a
  astar_bstar = (/astar*bstar/)   ; (lev,lat,lon)
  return (astar_bstar)
end 
;--------------------------------------------------------------------------

; OBSTAR_TBSTAR (stationary vertcal eddy heat flux)
function vertical_xz_OBSTAR_TBSTAR (inptr:file,outptr:file,latlim:float)
begin

  omega = inptr->OMEGA(0,:,:,:)  ; Pa/s
  t = inptr->T(0,:,:,:)
  otstar = omega
  otstar = stationary_xz(omega,t,latlim)
  if (inptr@source .eq. "GFDL") then
    tmp = int2p_n_Wrap(plvlG,otstar,plvlM(::-1),2,0)
    obstar_tbstar = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    obstar_tbstar = (/obstar_tbstar*864./)    ; convert to mb/day 
    obstar_tbstar@long_name = "Stat eddy vert heat"
    obstar_tbstar@units = "K mb/day"
    
    return (obstar_tbstar)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:)
    tmp = vinth2p(otstar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      obstar_tbstar3 = dble2flt(tmp)
    else
      obstar_tbstar3 = tmp
    end if 
    obstar_tbstar = dim_avg_Wrap(obstar_tbstar3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    obstar_tbstar = (/obstar_tbstar*864./)    ; convert to mb/day 
    obstar_tbstar@long_name = "Stat eddy vert heat"
    obstar_tbstar@units = "K mb/day"
    assignFillValue(obstar_tbstar,obstar_tbstar)
    
  end if
  
  return (obstar_tbstar(::-1,:))
end

; UBSTAR_QBSTAR (zonal stationary eddy moisture flux)
function vertical_xz_UBSTAR_QBSTAR (inptr:file,outptr:file,latlim:float)
begin
  
  u = inptr->U(0,:,:,:)
  q = inptr->Q(0,:,:,:)    ; kg/kg
  uqstar = u
  uqstar = stationary_xz(u,q,latlim) 
  if (inptr@source .eq. "GFDL") then
    tmp = int2p_n_Wrap(plvlG,uqstar,plvlM(::-1),2,0)
    ubstar_qbstar = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    ubstar_qbstar = (/ubstar_qbstar*1000./)     ; convert to g/kg
    ubstar_qbstar@long_name = "Stat eddy moisture"
    ubstar_qbstar@units = "m/s g/kg"
    
    return (ubstar_qbstar)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:)
    tmp = vinth2p(uqstar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      ubstar_qbstar3 = dble2flt(tmp)
    else
      ubstar_qbstar3 = tmp
    end if 
    ubstar_qbstar = dim_avg_Wrap(ubstar_qbstar3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    ubstar_qbstar = (/ubstar_qbstar*1000./)     ; convert to g/kg
    ubstar_qbstar@long_name = "Stat eddy moisture"
    ubstar_qbstar@units = "m/s g/kg"
    assignFillValue(ubstar_qbstar,ubstar_qbstar)
    
  end if

  return (ubstar_qbstar(::-1,:))
end

; UBSTAR_TBSTAR (zonal stationary eddy heat flux)
function vertical_xz_UBSTAR_TBSTAR (inptr:file,outptr:file,latlim:float)
begin

  t = inptr->T(0,:,:,:)
  u = inptr->U(0,:,:,:)
  utstar = u            
  utstar = stationary_xz(u,t,latlim)
  if (inptr@source .eq. "GFDL") then
    tmp = int2p_n_Wrap(plvlG,utstar,plvlM(::-1),2,0)
    ubstar_tbstar = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    ubstar_tbstar@long_name = "Stationary eddy heat"
    ubstar_tbstar@units = "K m/s"
    
    return (ubstar_tbstar)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:)
    tmp = vinth2p(utstar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      ubstar_tbstar3 = dble2flt(tmp)
    else
      ubstar_tbstar3 = tmp
    end if 
    ubstar_tbstar = dim_avg_Wrap(ubstar_tbstar3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    ubstar_tbstar@long_name = "Stationary eddy heat"
    ubstar_tbstar@units = "K m/s"
    assignFillValue(ubstar_tbstar,ubstar_tbstar)
    
  end if

  return (ubstar_tbstar(::-1,:))
end

; VBSTAR_UBSTAR (zonal stationary eddy momentum flux)
function vertical_xz_VBSTAR_UBSTAR (inptr:file,outptr:file,latlim:float)
begin

  u = inptr->U(0,:,:,:)
  v = inptr->V(0,:,:,:)
  vustar = u            
  vustar = stationary_xz(v,u,latlim)
  if (inptr@source .eq. "GFDL") then
    tmp = int2p_n_Wrap(plvlG,vustar,plvlM(::-1),2,0)
    vbstar_ubstar = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    vbstar_ubstar@long_name = "Stationary eddy momentum"
    vbstar_ubstar@units ="m~S~2~N~/s~S~2~N~"
    
    return (vbstar_ubstar)
  else
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:)
    tmp = vinth2p(vustar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      vbstar_ubstar3 = dble2flt(tmp)
    else
      vbstar_ubstar3 = tmp
    end if 
    vbstar_ubstar = dim_avg_Wrap(vbstar_ubstar3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    vbstar_ubstar@long_name = "Stationary eddy momentum"
    vbstar_ubstar@units ="m~S~2~N~/s~S~2~N~"
    assignFillValue(vbstar_ubstar,vbstar_ubstar)
    
  end if

  return (vbstar_ubstar(::-1,:))
end

;-------------------------------------------------------------------
; TRANSIENT EDDY FLUXES
;------------------------------------------------------------------
; EKE (transient eddy kinetic energy)
function vertical_xz_EKE (inptr:file,outptr:file,latlim:float)
begin
  u = inptr->U(0,:,:,:)
  v = inptr->V(0,:,:,:)
  if (isfilevar(inptr,"VVPUU")) then      ; in ccm3.6
    vvpuu = inptr->VVPUU(0,:,:,:)      ; v^2 + u^2
    ke = vvpuu
    ke = (/(vvpuu-(v^2+u^2))/2./) 
  else                                   ; in ccm3.10
    if (isfilevar(inptr,"VV").and.isfilevar(inptr,"UU")) then
      uu = inptr->UU(0,:,:,:)
      vv = inptr->VV(0,:,:,:)
      ke = vv
      ke = (/(vv+uu-(v^2+u^2))/2./)
    else
;       print("EKE: missing VVPUU or UU and VV variables")
      eke = -999.
      return (eke)
    end if
  end if
  if (inptr@source .eq. "GFDL") then
    tmp = int2p_n_Wrap(plvlG,ke,plvlM(::-1),2,0)
    eke = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
    eke@units = "m~S~2~N~/s~S~2~N~"
    eke@long_name = "Transient eddy KE"
    
    return (eke)
  else
    ps = inptr->PS(0,:,:)       ; Pa
    hyam = inptr->hyam
    hybm = inptr->hybm
    tmp = vinth2p(ke,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      eke3 = dble2flt(tmp)
    else
      eke3 = tmp
    end if
    eke = dim_avg_Wrap(eke3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    eke@units = "m~S~2~N~/s~S~2~N~"
    eke@long_name = "Transient eddy KE"
    eke@derive_op = "(VV+UU-(V^2+U^2))/2"
    assignFillValue(eke,eke)
    
  end if

  return (eke(::-1,:))
end

; OPTP_BAR (transient eddy vertical heat flux)
function vertical_xz_OPTP_BAR (inptr:file,outptr:file,latlim:float)
begin
  
  if (isfilevar(inptr,"OMEGAT")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:)
    omegat = inptr->OMEGAT(0,:,:,:)     ; Pa/s K
    omega = inptr->OMEGA(0,:,:,:)       ; Pa/s
    t = inptr->T(0,:,:,:)
    otbar = omegat
    otbar = (/omegat-omega*t/)
    tmp = vinth2p(otbar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      optp_bar3 = dble2flt(tmp)
    else
      optp_bar3 = tmp
    end if 
    optp_bar = dim_avg_Wrap(optp_bar3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    optp_bar = (/optp_bar*864./)       ; convert to K mb/day 
    optp_bar@long_name = "Transient eddy vert heat"
    optp_bar@units = "K mb/day"
    optp_bar@derive_op = "(OMEGAT-OMEGA*T)*86400/100"
    assignFillValue(optp_bar,optp_bar)
    
  else
;     print("OPTP_BAR: missing OMEGAT variable")
    optp_bar = -999.
    return (optp_bar)
  end if

  return (optp_bar(::-1,:))
end

; UPQP_BAR (zonal transient eddy moisture flux)
function vertical_xz_UPQP_BAR (inptr:file,outptr:file,latlim:float)
begin
  if (isfilevar(inptr,"UQ")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:)
    uq = inptr->UQ(0,:,:,:)   ; m/s kg/kg
    u = inptr->U(0,:,:,:)     ; m/s
    q = inptr->Q(0,:,:,:)     ; kg/kg
    uqbar = uq
    uqbar = (/uq-u*q/)
    tmp = vinth2p(uqbar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      upqp_bar3 = dble2flt(tmp)
    else
      upqp_bar3 = tmp
    end if 
    upqp_bar = dim_avg_Wrap(upqp_bar3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    upqp_bar = (/upqp_bar*1000./)       ; units m/s g/kg
    upqp_bar@long_name = "Transient eddy moisture"
    upqp_bar@units = "m/s g/kg"
    upqp_bar@derive_op = "(UQ-U*Q)*1000"
    assignFillValue(upqp_bar,upqp_bar)
    
  else
;     print ("UPQP_BAR: missing UQ variable")
    upqp_bar = -999.
    return (upqp_bar)
  end if
  
  return (upqp_bar(::-1,:))
end

; UPTP_BAR (zonal transient eddy heat flux)
function vertical_xz_UPTP_BAR (inptr:file,outptr:file,latlim:float)
begin
  if (isfilevar(inptr,"UT")) then
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:)
    ut = inptr->UT(0,:,:,:)      ; m/s K
    u = inptr->U(0,:,:,:)
    t = inptr->T(0,:,:,:)
    utbar = ut
    utbar = (/ut-u*t/)
    tmp = vinth2p(utbar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
    if (typeof(tmp).eq."double") then
      uptp_bar3 = dble2flt(tmp)
    else
      uptp_bar3 = tmp
    end if 
    uptp_bar = dim_avg_Wrap(uptp_bar3(lev_p|:,lon|:,{lat|-latlim:latlim}))
    uptp_bar@long_name = "Transient eddy heat"
    uptp_bar@units ="K m/s"
    uptp_bar@derive_op = "UT-U*T"
    assignFillValue(uptp_bar,uptp_bar)
    
  else
;     print("UPTP_BAR: missing UT variable")
    uptp_bar = -999.
    return (uptp_bar)
  end if
  
  return (uptp_bar(::-1,:))
end

; VPUP_BAR (zonal transient eddy momentum flux)
function vertical_xz_VPUP_BAR (inptr:file,outptr:file,latlim:float)
begin
  
  if (isfilevar(inptr,"VU")) then
    u = inptr->U(0,:,:,:)
    v = inptr->V(0,:,:,:)
    vu = inptr->VU(0,:,:,:)   ; m^2/s^2
    vubar = vu
    vubar = (/vu-u*v/)
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,vubar,plvlM(::-1),2,0)
      vpup_bar = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))
      vpup_bar@long_name = "Transient eddy momentum"
      vpup_bar@units ="m~S~2~N~/s~S~2~N~"
      
      return (vpup_bar)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
      ps = inptr->PS(0,:,:)
      tmp = vinth2p(vubar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        vpup_bar3 = dble2flt(tmp)
      else
        vpup_bar3 = tmp
      end if 
      vpup_bar = dim_avg_Wrap(vpup_bar3(lev_p|:,lon|:,{lat|-latlim:latlim}))
      vpup_bar@long_name = "Transient eddy momentum"
      vpup_bar@units ="m~S~2~N~/s~S~2~N~"
      vpup_bar@derive_op = "VU-U*V"
      assignFillValue(vpup_bar,vpup_bar)
      
    end if
  else
;     print ("VPUP_BAR: missing VU variable")
    vpup_bar = -999.
    return (vpup_bar)
  end if

  return (vpup_bar(::-1,:))
end
