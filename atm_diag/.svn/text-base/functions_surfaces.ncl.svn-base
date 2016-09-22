; NCL script
; functions_surfaces.ncl
; Mark Stevens, Sept 2001
; last update Nov 4 2005
; surface, constant pressure level, and TOM/A variables
; all functions return 2D arrays (lat,lon)
;******************************************************************
 
; AAM (atmospheric angular momentum) 
; This is really local aam since we do not integrate over space.
; True angular momentum is a full 3D integral and is available from
; the NCL function angmom_atm.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function get_AAM (inptr:file,outptr:file)
begin
 g  = 9.81                     ; m/s^2 
 pi = 3.141592654
 re = 6.37122e+06              ; radius of earth in meters
 deg_to_rad = pi/180.          ; convert degrees to radians
 p0 = 100000.                  ; Pa
 if (isfilevar(outptr,"AAM")) then
   aam = outptr->AAM
 else
   if (inptr@source .eq. "GFDL") then
     lat = inptr->lat
     nlat = dimsizes(lat)
     level = inptr->level
     nlev = dimsizes(level)
     u = inptr->U(0,:,:,:)    ; m/s (level,lat,lon)
     dp=(/7500.,7500.,15000.,10000.,10000.,10000.,10000.,5000.,5000.,5000.,5000.,3000.,2000.,2000.,1000.,1000./)   ; Pa
     Pdp = u(0:nlev-2,:,:)
     Pdp = conform(u(0:nlev-2,:,:),dp,0)
     sum_vert = dim_sum_n(u(0:nlev-2,:,:)*Pdp, 0)
   ;;sum_vert = dim_sum(u(lat|:,lon|:,lev|0:nlev-2)*Pdp(lat|:,lon|:,lev|:))
     tmp = u(0,:,:)
   else
     tmp = inptr->lat
     if (typeof(tmp).eq."double") then
       lat = dble2flt(tmp)
     else
       lat = tmp
     end if
     delete (tmp)
     nlat = dimsizes(lat)
     u = inptr->U(0,:,:,:)    ; m/s (lev,lat,lon)
     ps = inptr->PS(0,:,:)    ; Pa  (lat,lon)    
     hyai = inptr->hyai       ; interface levels
     hybi = inptr->hybi
     dp = u
     dp = dpres_hybrid_ccm (ps,p0,hyai,hybi)  ; Pa (lev,lat,lon)
;    sum over the vertical levels 
     sum_vert = dim_sum_n(u*dp, 0)
   ;;sum_vert = dim_sum(u(lat|:,lon|:,lev|:)*dp(lat|:,lon|:,lev|:))
     tmp = ps                 ; (lat,lon)
   end if
   do j = 0,nlat-1
     tmp(j,:) = (/sum_vert(j,:)*re/g*cos(lat(j)*deg_to_rad)/)  
   end do
   if (typeof(tmp).eq."double") then
     aam = dble2flt(tmp)
   else
     aam = tmp
   end if
   aam@derive_op = "re/g cos(lat) sum_k U DP"
   aam@units     = "kg/s"
   aam@long_name  = "local atmos angular momentum"
   assignFillValue(aam,aam)
   outptr->AAM = aam
 end if
 return (aam)
end

function get_ALBSURF (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ALBSURF")) then
    alb_surf = outptr->ALBSURF
  else
    tmp = inptr->FSDS(0,:,:)
    fsds = tmp
    fsds = mask(tmp,tmp.gt.0.0,True)
    tmp = inptr->FSNS(0,:,:)
    fsns = tmp
    fsns = mask(tmp,tmp.gt.0.0,True)
    tmp = fsds
    tmp = (/(fsds-fsns)/fsds/)
    if (typeof(tmp).eq."double") then
      alb_surf = dble2flt(tmp)
    else
      alb_surf = tmp
    end if
    alb_surf@derive_op = "(FSDS-FSNS)/FSDS"
    alb_surf@units = "dimensionless"
    alb_surf@long_name = "Surface albedo"
    outptr->ALBSURF = alb_surf 
  end if
  return (alb_surf)
end

function get_WIND_MAG_SURF (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"WIND_MAG_SURF")) then
    WIND_MAG_SURF = outptr->WIND_MAG_SURF
  else
    if (isfilevar(inptr,"WIND_MAG_SURF")) then
      WIND_MAG_SURF = inptr->WIND_MAG_SURF(0,:,:)
    else
      if (isfilevar(inptr,"U10")) then
        WIND_MAG_SURF = inptr->U10(0,:,:)
      else
        WIND_MAG_SURF= -999.0
      end if
    end if
  end if
  return (WIND_MAG_SURF)
end


function get_U10 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"U10")) then
    U10 = outptr->U10
  else
    if (isfilevar(inptr,"U10")) then
      U10 = inptr->U10(0,:,:)
    else
      U10= -999.0
    end if
  end if
  return (U10)
end



function get_ALBEDO (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ALBEDO")) then
    albedo = outptr->ALBEDO
  else
    if (isfilevar(inptr,"SOLIN")) then
      fsntoa = inptr->FSNTOA(0,:,:)
      tmp1 = inptr->SOLIN(0,:,:)
      solin = tmp1
      solin = mask(tmp1,tmp1.gt.0.0,True)
      tmp = solin 
      tmp = (/(solin-fsntoa)/solin/)
      if (typeof(tmp).eq."double") then
        albedo = dble2flt(tmp)
      else
        albedo = tmp
      end if
      albedo@derive_op = "(SOLIN-FSNTOA)/SOLIN"
      albedo@units = "dimensionless"
      albedo@long_name = "TOA albedo"
      outptr->ALBEDO = albedo 
    else
      albedo = -999.0
    end if
  end if
  return (albedo)
end

function get_ALBEDOC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ALBEDOC")) then
    albedoc = outptr->ALBEDOC
  else
    if (isfilevar(inptr,"SOLIN")) then
      fsntoac = inptr->FSNTOAC(0,:,:)
      tmp1 = inptr->SOLIN(0,:,:)
      solin = tmp1
      solin = mask(tmp1,tmp1.gt.0.0,True)
      tmp = solin 
      tmp = (/(solin-fsntoac)/solin/)
      if (typeof(tmp).eq."double") then
        albedoc = dble2flt(tmp)
      else
        albedoc = tmp
      end if
      albedoc@derive_op = "(SOLIN-FSNTOAC)/SOLIN"
      albedoc@units = "dimensionless"
      albedoc@long_name = "TOA clearsky albedo"
      outptr->ALBEDOC = albedoc 
    else
      albedoc = -999.0
    end if
  end if
  return (albedoc)
end

function get_AODVIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"AODVIS")) then
    aodvis = outptr->AODVIS
  else
    if (isfilevar(inptr,"AODVIS")) then
      tmp = inptr->AODVIS(0,:,:)

; RBN 11NOv09 - Temp. fix to correct missing data value.

      if(isatt(tmp,"_FillValue")) then
        delete(tmp@_FillValue)
        tmp@_FillValue = 1.e36
      end if

      if (typeof(tmp).eq."double") then
        aodvis = dble2flt(tmp)
      else
        aodvis = tmp
      end if
      aodvis@units = "dimensionless"
      aodvis@long_name = "Aerosol optical depth (550 nm)"
      outptr->AODVIS = aodvis 
    else
      aodvis = -999.0
    end if
  end if
  return (aodvis)
end

function get_AODDUST (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"AODDUST")) then
    aoddust = outptr->AODDUST
  else
    if (isfilevar(inptr,"AODDUST1")) then
      tmp  = inptr->AODDUST1(0,:,:)
      tmp3 = inptr->AODDUST3(0,:,:)
      tmp = tmp+tmp3
      if(isatt(tmp,"_FillValue")) then
        delete(tmp@_FillValue)
        tmp@_FillValue = 1.e36
      end if

      if (typeof(tmp).eq."double") then
        aoddust = dble2flt(tmp)
      else
        aoddust = tmp
      end if
      aoddust@units = "dimensionless"
      aoddust@long_name = "Total dust optical depth"
      outptr->AODDUST = aoddust 
    else
      aoddust = -999.0
    end if
  end if
  return (aoddust)
end

function get_CHI_200 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CHI_200")) then
    chi_200 = outptr->CHI_200
  else
    u = inptr->U(0,:,:,:)     ; (lev,lat,lon)
    v = inptr->V(0,:,:,:)
    psi = u
    chi = u
    if (inptr@source .eq. "GFDL") then
      uv2sfvpf(u,v,psi,chi)
      chi_200 = chi(9,:,:)
    else
      uv2sfvpg(u,v,psi,chi)
      ps = inptr->PS(0,:,:)       ; Pa
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = vinth2p(chi,hyam,hybm,200.,ps,2,1000.,1,False)
      if (typeof(tmp).eq."double") then
        chi_200 = dble2flt(tmp(0,:,:))   
      else
        chi_200 = tmp(0,:,:)
      end if       
    end if
    chi_200 = (/chi_200/1.e6/)
    chi_200@long_name = "200mb vel potential" 
    chi_200@units = "m~S~2~N~/s x 10~S~6~N~"
    chi_200@derive_op = "uv2sfvpg(u,v,psi,chi) divided by 10^6"
    assignFillValue(chi_200,chi_200)
    outptr->CHI_200 = chi_200
  end if
  return (chi_200)
end 

function get_CLDHGH (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDHGH")) then
    cldhgh = outptr->CLDHGH
  else
    if (isfilevar(inptr,"CLDHGH")) then
      tmp = inptr->CLDHGH(0,:,:)
      if (typeof(tmp).eq."double") then
        cldhgh = dble2flt(tmp)
      else
        cldhgh = tmp
      end if
      cldhgh = (/cldhgh*100./)
      cldhgh@long_name = "High-level cloud"
      cldhgh@units = "percent"
      assignFillValue(cldhgh,cldhgh)
      outptr->CLDHGH = cldhgh
    else
      print("CLDHGH: no CLDHGH variable present")
      cldhgh = -999.0
    end if
  end if
  return (cldhgh)
end 

function get_CLDLOW (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDLOW")) then
    cldlow = outptr->CLDLOW
  else
    if (isfilevar(inptr,"CLDLOW")) then
      tmp = inptr->CLDLOW(0,:,:)
      if (typeof(tmp).eq."double") then
        cldlow = dble2flt(tmp)
      else
        cldlow = tmp
      end if
      cldlow = (/cldlow*100./)
      cldlow@long_name = "Low-level cloud"
      cldlow@units = "percent"
      assignFillValue(cldlow,cldlow)
      outptr->CLDLOW = cldlow
    else
      print("CLDLOW: no CLDLOW variable present")
      cldlow = -999.0
    end if    
  end if
  return (cldlow)
end 

function get_CLDMED (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDMED")) then
    cldmed = outptr->CLDMED
  else
     if (isfilevar(inptr,"CLDMED")) then
       tmp = inptr->CLDMED(0,:,:)
       if (typeof(tmp).eq."double") then
         cldmed = dble2flt(tmp)
       else
         cldmed = tmp
       end if
       cldmed = (/cldmed*100./)
       cldmed@long_name = "Mid-level cloud"
       cldmed@units = "percent"
       assignFillValue(cldmed,cldmed)
       outptr->CLDMED = cldmed
     else
       print("CLDMED: no CLDMED variable present")
       cldmed = -999.0
     end if
   end if
   return (cldmed)
end 

function get_CLDTOT (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTOT")) then
    cldtot = outptr->CLDTOT
  else
    if (isfilevar(inptr,"CLDTOT")) then
      tmp = inptr->CLDTOT(0,:,:)
      if (typeof(tmp).eq."double") then
        cldtot = dble2flt(tmp)
      else
        cldtot = tmp
      end if
      cldtot = (/cldtot*100./)
      cldtot@long_name = "Total cloud"
      cldtot@units = "percent"
      assignFillValue(cldtot,cldtot)
      outptr->CLDTOT = cldtot
    else
      print("CLDTOT: no CLDTOT variable present")
      cldtot = -999.0
    end if
  end if
  return (cldtot)
end 

function get_TCLDAREA (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"TCLDAREA")) then
    tcldarea = outptr->TCLDAREA
  else
    if (isfilevar(inptr,"TCLDAREA")) then
      tmp = inptr->TCLDAREA(0,:,:)
      assignFillValue(tmp,tmp)
      if (typeof(tmp).eq."double") then
        tcldarea = dble2flt(tmp)
      else
        tcldarea = tmp
      end if
      tcldarea = (/tcldarea*100./)
      tcldarea@long_name = "Total cloud area"
      tcldarea@units = "percent"
      outptr->TCLDAREA = tcldarea
    else
;     print("TCLDAREA: no TCLDAREA variable present")
      tcldarea = -999.0
    end if
  end if
  return (tcldarea)
end 

function get_CDNUMC (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CDNUMC")) then
    cdnumc = outptr->CDNUMC
  else
   if( (isfilevar(inptr,"CDNUMC")))then
    tmp = inptr->CDNUMC(0,:,:)
    if (typeof(tmp).eq."double") then
      cdnumc = dble2flt(tmp)
    else
      cdnumc = tmp
    end if
    cdnumc = (/cdnumc*1.e-10/)
    cdnumc@long_name = "Cloud Droplet Conc."
    cdnumc@units = "1.e6 cm:S:-2:N:"
    assignFillValue(cdnumc,cdnumc)

    outptr->CDNUMC = cdnumc

   else
     print("CDNUMC: no CDNUMC variable present")
     cdnumc = -999.
   end if 
  end if


  return (cdnumc)
end 


function get_SIWC_226 (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"SIWC_226")) then
    siwc = outptr->SIWC_226
  else
   if( (isfilevar(inptr,"IWC")).and.(isfilevar(inptr,"AQSNOW")) )then
    T = inptr->T(0,13,:,:)
    plev = dble2flt(inptr->lev(13))
    Rd = 287.04
    rho = plev/Rd*T

    lat = inptr->lat
    lon = inptr->lon
    
    tmp = inptr->IWC(0,13,:,:)
    tmp = (/tmp+inptr->AQSNOW(0,13,:,:)*rho/)
    
    if (typeof(tmp).eq."double") then
      siwc = dble2flt(tmp)
    else
      siwc = tmp
    end if
  
    siwc = (/siwc*1.e6/)
    siwc@long_name = "GIWC+SNOW at 226mb"
    siwc@units = "mg/m:S:3:N:"
    assignFillValue(siwc,siwc)
    outptr->SIWC_226 = (/siwc/)
   else
    ;print("hi6")
    print("IWC: no IWC variable present and/or no AQSNOW variable present")
    siwc = -999.
   end if
  end if
  return (siwc)
end 

function get_EKE_850 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"EKE_850")) then
    eke_850 = outptr->EKE_850
  else
    u = inptr->U(0,:,:,:)
    v = inptr->V(0,:,:,:)
    if (isfilevar(inptr,"VVPUU")) then      ; in ccm3.6
      vvpuu = inptr->VVPUU(0,:,:,:)        ; v^2 + u^2
      eke = vvpuu
      eke = (/(vvpuu-(v^2+u^2))/2./) 
    else                                   ; in ccm3.10
      if (isfilevar(inptr,"VV").and.isfilevar(inptr,"UU")) then
        uu = inptr->UU(0,:,:,:)
        vv = inptr->VV(0,:,:,:)
        eke = vv
        eke = (/(vv+uu-(v^2+u^2))/2./)
      else
        eke_850 = -999.0
        return (eke_850)
      end if
    end if
    if (inptr@source .eq. "GFDL") then
      eke_850 = eke(2,:,:)
      eke_850@units = "m^2/s^2"
      eke_850@long_name = "850mb eddy KE"
      outptr->EKE_850 = eke_850
    else
      ps = inptr->PS(0,:,:)       ; Pa
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = vinth2p(eke,hyam,hybm,850.,ps,2,1000.,1,False)
      if (typeof(tmp).eq."double") then
        eke_850 = dble2flt(tmp(0,:,:))
      else
        eke_850 = tmp(0,:,:)
      end if
      eke_850@units = "m~S~2~N~/s~S~2~N~"
      eke_850@long_name = "850mb eddy KE"
      eke_850@derive_op = "EKE=(VV+UU-(V^2+U^2))/2"
      assignFillValue(eke_850,eke_850)
      outptr->EKE_850 = eke_850
    end if
  end if
  return (eke_850)
end

function get_EP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"EP")) then
    ep = outptr->EP
  else
    if (isfilevar(inptr,"QFLX")) then     
      qflx = inptr->QFLX(0,:,:)    ; mm/s 
      precc = inptr->PRECC(0,:,:)  ; m/s
      precl = inptr->PRECL(0,:,:)  ; m/s
      tmp = qflx
      tmp = (/qflx*86400.-(precc+precl)*8.64e7/)   ; convert to mm/day
      if (typeof(tmp).eq."double") then
        ep = dble2flt(tmp)
      else
        ep = tmp
      end if
      ep@long_name = "evap-precip"
      ep@units = "mm/day"
      ep@derive_op = "EP=QFLX*8.64e4-(PRECC+PRECL)*8.64e7"
      assignFillValue(ep,ep)
      outptr->EP = ep
    else
      ep = -999.0
    end if
  end if
  return (ep)
end

function get_FLDS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FLDS")) then
    flds = outptr->FLDS
  else 
    if (inptr@source .eq. "GFDL") then
      fldsc = inptr->FLDS(0,:,:)
      outptr->FLDS = flds
    else
      if (isfilevar(inptr,"FLDS")) then
        tmp = inptr->FLDS(0,:,:)
        if (typeof(tmp).eq."double") then
          flds = dble2flt(tmp)
        else
          flds = tmp
        end if
        flds@long_name = "Surf downwelling LW"
        flds@units =  "W/m~S~2~N~"
        assignFillValue(flds,flds)
        outptr->FLDS = flds
      else
        print("FLDS: no FLDS variable present")
        flds = -999.0
      end if   
    end if
  end if
  return (flds)
end

function get_FLDSC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FLDSC")) then
    fldsc = outptr->FLDSC
  else
    if (inptr@source .eq. "GFDL") then
      fldsc = inptr->FLDSC(0,:,:)
      outptr->FLDSC = fldsc
    else
      if (isfilevar(inptr,"TS") .and. isfilevar(inptr,"FLNSC")) then
        flnsc = inptr->FLNSC(0,:,:) 
        ts = inptr->TS(0,:,:)
        tmp = flnsc
        tmp = (/5.67e-8*ts^4-flnsc/)
        if (typeof(tmp).eq."double") then
          fldsc = dble2flt(tmp)
        else
          fldsc = tmp
        end if
        fldsc@long_name = "Surf clearsky down LW"
        fldsc@units = "W/m~S~2~N~"
        fldsc@derive_op = "FLDSC = 5.67e-8*TS^4-FLNSC"
        assignFillValue(fldsc,fldsc)
        outptr->FLDSC = fldsc
      else
        fldsc = -999.0
      end if
    end if
  end if
  return (fldsc)
end

function get_FLNS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FLNS")) then
    flns = outptr->FLNS
  else
    tmp = inptr->FLNS(0,:,:) 
    if (typeof(tmp).eq."double") then
      flns = dble2flt(tmp)
    else
      flns = tmp
    end if
    flns@long_name = "Surface net LW flux"
    flns@units = "W/m~S~2~N~"
    assignFillValue(flns,flns)
    outptr->FLNS = flns
  end if
  return (flns)
end

function get_FLNSC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FLNSC")) then
    flnsc = outptr->FLNSC
  else
    tmp = inptr->FLNSC(0,:,:) 
    if (typeof(tmp).eq."double") then
      flnsc = dble2flt(tmp)
    else
      flnsc = tmp
    end if
    flnsc@long_name = "Surf clearsky net LW"
    flnsc@units = "W/m~S~2~N~"
    assignFillValue(flnsc,flnsc)
    outptr->FLNSC = flnsc
  end if
  return (flnsc)
end

function get_FLNT (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FLNT")) then
    flnt = outptr->FLNT
  else
    tmp = inptr->FLNT(0,:,:) 
    if (typeof(tmp).eq."double") then
      flnt = dble2flt(tmp)
    else
      flnt = tmp
    end if
    flnt@long_name = "TOM net LW flux"
    flnt@units = "W/m~S~2~N~"
    assignFillValue(flnt,flnt)
    outptr->FLNT = flnt
  end if
  return (flnt)
end

function get_FLNTC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FLNTC")) then
    flntc = outptr->FLNTC
  else
    tmp = inptr->FLNTC(0,:,:) 
    if (typeof(tmp).eq."double") then
      flntc = dble2flt(tmp)
    else
      flntc = tmp
    end if
    flntc@long_name = "TOM clearsky net LW"
    flntc@units = "W/m~S~2~N~"
    assignFillValue(flntc,flntc)
    outptr->FLNTC = flntc
  end if
  return (flntc)
end

function get_FLUT (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FLUT")) then
    flut = outptr->FLUT
  else
    if (isfilevar(inptr,"FLUT")) then       ; in ccm3.10
      tmp = inptr->FLUT(0,:,:) 
      if (typeof(tmp).eq."double") then
        flut = dble2flt(tmp)
      else
        flut = tmp
      end if
      flut@long_name = "TOA upward LW flux"
      flut@units = "W/m~S~2~N~"
      assignFillValue(flut,flut)
      outptr->FLUT = flut
    else
      flut = -999.0
    end if
  end if
  return (flut)
end

function get_FLUTC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FLUTC")) then
    flutc = outptr->FLUTC
  else
    if (isfilevar(inptr,"FLUTC")) then      ; in ccm3.10
      tmp = inptr->FLUTC(0,:,:) 
      if (typeof(tmp).eq."double") then
        flutc = dble2flt(tmp)
      else
        flutc = tmp
      end if
      flutc@long_name = "TOA clearsky upward LW"
      flutc@units = "W/m~S~2~N~"
      assignFillValue(flutc,flutc)
      outptr->FLUTC = flutc
    else
      flutc = -999.0
    end if
  end if
  return (flutc)
end

function get_FSDS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSDS")) then
    fsds = outptr->FSDS
  else
    if (isfilevar(inptr,"FSDS")) then  
      tmp = inptr->FSDS(0,:,:) 
      if (typeof(tmp).eq."double") then
        fsds = dble2flt(tmp)
      else
        fsds = tmp
      end if
      fsds@long_name = "Surf downwelling SW"
      fsds@units = "W/m~S~2~N~"
      assignFillValue(fsds,fsds)
      outptr->FSDS = fsds
    else
      fsds = -999.0
    end if
  end if
  return (fsds)
end

function get_FSDSC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSDSC")) then
    fsdsc = outptr->FSDSC
  else
    if (isfilevar(inptr,"FSDSC")) then  
      tmp = inptr->FSDSC(0,:,:) 
      if (typeof(tmp).eq."double") then
        fsdsc = dble2flt(tmp)
      else
        fsdsc = tmp
      end if
      fsdsc@long_name = "Clearsky surf down SW"
      fsdsc@units = "W/m~S~2~N~"
      assignFillValue(fsdsc,fsdsc)
      outptr->FSDSC = fsdsc
    else
      fsdsc = -999.0
    end if
  end if
  return (fsdsc)
end

function get_FSNS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSNS")) then
    fsns = outptr->FSNS
  else
    tmp = inptr->FSNS(0,:,:) 
    if (typeof(tmp).eq."double") then
      fsns = dble2flt(tmp)
    else
      fsns = tmp
    end if
    fsns@long_name = "Surface net SW flux"
    fsns@units = "W/m~S~2~N~"
    assignFillValue(fsns,fsns)
    outptr->FSNS = fsns
  end if
  return (fsns)
end

function get_FSNSC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSNSC")) then
    fsnsc = outptr->FSNSC
  else
    tmp = inptr->FSNSC(0,:,:) 
    if (typeof(tmp).eq."double") then
      fsnsc = dble2flt(tmp)
    else
      fsnsc = tmp
    end if
    fsnsc@long_name = "Surf clearsky net SW"
    fsnsc@units = "W/m~S~2~N~"
    assignFillValue(fsnsc,fsnsc)
    outptr->FSNSC = fsnsc
  end if
  return (fsnsc)
end

function get_FSNSC_LAND (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSNSC_LAND")) then
    fsnsc_land = outptr->FSNSC_LAND
  else
    if (isfilevar(inptr,"LANDFRAC")) then
      fsnsc = inptr->FSNSC(0,:,:) 
      landfrac = inptr->LANDFRAC(0,:,:)
      tmp = fsnsc
      tmp = mask(fsnsc,landfrac.eq.1.0,True)  ; land only
      if (typeof(tmp).eq."double") then
        fsnsc_land = dble2flt(tmp)
      else
        fsnsc_land = tmp
      end if
      fsnsc_land@long_name = "Land clearsky net SW"
      fsnsc_land@units = "W/m~S~2~N~"
      assignFillValue(fsnsc_land,fsnsc_land)
      outptr->FSNSC_LAND = fsnsc_land
    else
      fsnsc_land = -999.0
    end if
  end if
  return (fsnsc_land)
end

function get_FSNSC_ICE (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSNSC_ICE")) then
    fsnsc_ice = outptr->FSNSC_ICE
  else
    if (isfilevar(inptr,"ICEFRAC")) then
      fsnsc = inptr->FSNSC(0,:,:) 
      icefrac = inptr->ICEFRAC(0,:,:)
      tmp = fsnsc
      tmp = mask(fsnsc,icefrac.ge.0.65,True)  ; seaice only
      if (typeof(tmp).eq."double") then
        fsnsc_ice = dble2flt(tmp)
      else
        fsnsc_ice = tmp
      end if
      fsnsc_ice@long_name = "Sea-ice clearsky net SW"
      fsnsc_ice@units = "W/m~S~2~N~"
      assignFillValue(fsnsc_ice,fsnsc_ice)
      outptr->FSNSC_ICE = fsnsc_ice
    else
      fsnsc_ice = -999.0
    end if
  end if
  return (fsnsc_ice)
end

function get_FSNT (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSNT")) then
    fsnt = outptr->FSNT
  else
    tmp = inptr->FSNT(0,:,:) 
    if (typeof(tmp).eq."double") then
      fsnt = dble2flt(tmp)
    else
      fsnt = tmp
    end if
    fsnt@long_name = "TOM net SW flux"
    fsnt@units = "W/m~S~2~N~"
    assignFillValue(fsnt,fsnt)
    outptr->FSNT = fsnt
  end if
  return (fsnt)
end

function get_FSNTC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSNTC")) then
    fsntc = outptr->FSNTC
  else
    tmp = inptr->FSNTC(0,:,:) 
    if (typeof(tmp).eq."double") then
      fsntc = dble2flt(tmp)
    else
      fsntc = tmp
    end if
    fsntc@long_name = "TOM clearsky net SW"
    fsntc@units = "W/m~S~2~N~"
    assignFillValue(fsntc,fsntc)
    outptr->FSNTC = fsntc
  end if
  return (fsntc)
end

function get_FSNTOA (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSNTOA")) then
    fsntoa = outptr->FSNTOA
  else
    if (isfilevar(inptr,"FSNTOA")) then
      tmp = inptr->FSNTOA(0,:,:)        ; in ccm3.10 
      if (typeof(tmp).eq."double") then
        fsntoa = dble2flt(tmp)
      else
        fsntoa = tmp
      end if
      fsntoa@long_name = "TOA net SW flux"
      fsntoa@units = "W/m~S~2~N~"
      assignFillValue(fsntoa,fsntoa)
      outptr->FSNTOA = fsntoa
    else
      fsntoa = -999.0
    end if
  end if
  return (fsntoa)
end

function get_FSNTOAC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"FSNTOAC")) then
    fsntoac = outptr->FSNTOAC
  else
    if (isfilevar(inptr,"FSNTOAC")) then
      tmp = inptr->FSNTOAC(0,:,:)        ; in ccm3.10 
      if (typeof(tmp).eq."double") then
        fsntoac = dble2flt(tmp)
      else
        fsntoac = tmp
      end if
      fsntoac@long_name = "TOA clearsky net SW flux"
      fsntoac@units = "W/m~S~2~N~"
      assignFillValue(fsntoac,fsntoac)
      outptr->FSNTOAC = fsntoac
    else
      fsntoac = -999.0
    end if
  end if
  return (fsntoac)
end

function get_ICEFRAC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ICEFRAC")) then
    icefrac = outptr->ICEFRAC
  else
    if (isfilevar(inptr,"ICEFRAC") .and. isfilevar(inptr,"OCNFRAC")) then
      iceconc = inptr->ICEFRAC(0,:,:) 
      tmpice = iceconc
      tmp = iceconc
      tmp = mask(tmpice,iceconc.gt.0.0,True)
      if (typeof(tmp).eq."double") then
        icefrac = dble2flt(tmp)
      else
        icefrac = tmp
      end if
      icefrac@long_name = "Sea ice concentration"
      icefrac@units = "fraction"
      assignFillValue(icefrac,icefrac)
      outptr->ICEFRAC = icefrac 
    else
;     print("ICEFRAC not valid for this model version")
      icefrac = -999.0
    end if
  end if
  return (icefrac)
end

function get_ISCCP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ISCCP")) then
    isccp = outptr->ISCCP
  else
    if (isfilevar(inptr,"FISCCP1")) then     ; in ccm2.0.2
      tmp = inptr->FISCCP1(0,:,:,:)  ; (prstau,lat,lon)
      if (typeof(tmp).eq."double") then
        isccp = dble2flt(tmp)
      else
        isccp = tmp
      end if
      isccp = (/isccp*100./)
      isccp@units = "percent"
      isccp@long_name = "ISCCP cloud amount"
      outptr->ISCCP = isccp
    else
      isccp = -999.0
    end if
  end if
  return (isccp)
end

function get_LHFLX (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"LHFLX")) then
    lhflx = outptr->LHFLX
  else
    qflx = inptr->QFLX(0,:,:)      ; kg/(m^2 s)
    Lv = 2.501e6                   ; J/kg
    if (isfilevar(inptr,"PRECSC").and.isfilevar(inptr,"PRECSL")) then
      Lf = 3.337e5                   ; J/kg
      precc = inptr->PRECC(0,:,:)    ; m/s
      precl = inptr->PRECL(0,:,:)    ; m/s
      precsc = inptr->PRECSC(0,:,:)  ; m/s
      precsl = inptr->PRECSL(0,:,:)  ; m/s
      tmp = qflx
      tmp = (/(Lv+Lf)*qflx - Lf*1.e3*(precc+precl-precsc-precsl)/)
      tmp@derive_op = "(Lv+Lf)*qflx-Lf*(prect-precsc-precl)"
    else
      tmp = qflx
      tmp = (/Lv*qflx/)              ; W/m^2
      tmp@derive_op = "Lv*qflx"
    end if
    tmp@units = "W/m~S~2~N~"
    tmp@long_name = "Surf latent heat flux"
    if (typeof(tmp).eq."double") then
      lhflx = dble2flt(tmp)
    else
      lhflx = tmp
    end if
    outptr->LHFLX = lhflx
  end if
  return (lhflx)
end

function get_LWCFSRF (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"LWCFSRF")) then
    lwcfsrf = outptr->LWCFSRF
  else
    flns = inptr->FLNS(0,:,:) 
    flnsc = inptr->FLNSC(0,:,:) 
    tmp = flnsc
    tmp = (/flnsc-flns/)
    if (typeof(tmp).eq."double") then
      lwcfsrf = dble2flt(tmp)
    else
      lwcfsrf = tmp
    end if
    lwcfsrf@long_name = "Surface LW cloud forcing"
    lwcfsrf@units = "W/m~S~2~N~"
    outptr->LWCFSRF = lwcfsrf
  end if
  return (lwcfsrf)
end

function get_LWCFTOA (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"LWCFTOA")) then
    lwcftoa = outptr->LWCFTOA
  else
    if (isfilevar(inptr,"LWCF")) then
      tmp = inptr->LWCF(0,:,:)          ; in ccm3.10
      if (typeof(tmp).eq."double") then
        lwcftoa = dble2flt(tmp)
      else
        lwcftoa = tmp
      end if
      lwcftoa@long_name = "TOA LW cloud forcing"
      lwcftoa@units = "W/m~S~2~N~"
      assignFillValue(lwcftoa,lwcftoa)
      outptr->LWCFTOA = lwcftoa
    else
      print("LWCFTOA: no LWCF variable present")
      lwcftoa = -999.0
    end if
  end if
  return (lwcftoa)
end

function get_LWCFTOM (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"LWCFTOM")) then
    lwcftom = outptr->LWCFTOM
  else
    if (inptr@source .eq. "GFDL") then
      lwcftom = inptr->LWCF(0,:,:) 
      outptr->LWCFTOM = lwcftom
    else 
      flntc = inptr->FLNTC(0,:,:)
      flnt = inptr->FLNT(0,:,:)
      tmp = flntc
      tmp = (/flntc-flnt/)
      if (typeof(tmp).eq."double") then
        lwcftom = dble2flt(tmp)
      else
        lwcftom = tmp
      end if
      lwcftom@derive_op = "LWCF=FLNTC-FLNT"
      lwcftom@units = "W/m~S~2~N~"
      lwcftom@long_name = "TOM LW cloud forcing"
      assignFillValue(lwcftom,lwcftom)
      outptr->LWCFTOM = lwcftom
    end if
  end if
  return (lwcftom)
end

function get_MEANPTOP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"MEANPTOP")) then
    meanptop = outptr->MEANPTOP
  else
    if (isfilevar(inptr,"MEANPTOP")) then     ; in ccm2.0.2
      tmp = inptr->MEANPTOP(0,:,:)
      if (typeof(tmp).eq."double") then
        meanptop = dble2flt(tmp)
      else
        meanptop = tmp
      end if
      meanptop@long_name = "Mean cloud top pressure"
      meanptop@units = "mb"
      outptr->MEANPTOP = meanptop
    else
;     print("MEANPTOP: no MEANPTOP variable present")
      meanptop = -999.0
    end if
  end if
  return (meanptop)
end

function get_MEANTTOP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"MEANTTOP")) then
    meanttop = outptr->MEANTTOP
  else
    if (isfilevar(inptr,"MEANTTOP")) then     ; in ccm2.0.2
      tmp = inptr->MEANTTOP(0,:,:)
      if (typeof(tmp).eq."double") then
        meanttop = dble2flt(tmp)
      else
        meanttop = tmp
      end if
      meanttop@long_name = "Mean cloud top temperature"
      meanttop@units = "K"
      outptr->MEANTTOP = meanttop
    else
;     print("MEANTTOP: no MEANTTOP variable present")
      meanttop = -999.0
    end if
  end if
  return (meanttop)
end

function get_MEANTAU (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"MEANTAU")) then
    meantau = outptr->MEANTAU
  else
    if (isfilevar(inptr,"MEANTAU")) then     ; in ccm2.0.2
      tmp = inptr->MEANTAU(0,:,:)
      if (typeof(tmp).eq."double") then
        meantau = dble2flt(tmp)
      else
        meantau = tmp
      end if
      meantau@long_name = "Mean optical thickness"
      meantau@units = "dimensionless"
      outptr->MEANTAU = meantau
    else
;     print("MEANTAU: no MEANTAU variable present")
      meantau = -999.0
    end if
  end if
  return (meantau)
end

function get_ORO (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ORO")) then
    oro = outptr->ORO
  else
    tmp = inptr->ORO(0,:,:)    
    if (typeof(tmp).eq."double") then
      oro = dble2flt(tmp)
    else
      oro = tmp
    end if
    oro@units = "dimensionless"
    oro@long_name = "orography (0=ocean,1=land,2=seaice)"
    outptr->ORO = oro
  end if
  return (oro)
end

function get_ORO_OCNFRAC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ORO_OCNFRAC")) then
    oro_ocnfrac = outptr->ORO_OCNFRAC
  else
    tmp = inptr->OCNFRAC(0,:,:)
    oro = tmp
    oro = (/fabs(tmp-1.)/)            ; ocnfrac = 1 becomes 0
    if (typeof(oro).eq."double") then
      oro_ocnfrac = dble2flt(oro)
    else
      oro_ocnfrac = oro
    end if
    oro_ocnfrac@units = "dimensionless"
    oro_ocnfrac@long_name = "orography from ocnfrac"
    outptr->ORO_OCNFRAC = oro_ocnfrac
  end if
  return (oro_ocnfrac)
end

function get_QFLX (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"QFLX")) then
    qflx = outptr->QFLX
  else
    if (isfilevar(inptr,"QFLX")) then     
      tmp = inptr->QFLX(0,:,:)   ; mm/s
      tmp = (/tmp*86400./)    ; convert to mm/day
      if (typeof(tmp).eq."double") then
        qflx = dble2flt(tmp)
      else
        qflx = tmp
      end if
      qflx@units = "mm/day"
      qflx@long_name = "Surf water flux"
      qflx@derive_op = "QFLX multiplied by 86400."
      assignFillValue(qflx,qflx)
      outptr->QFLX = qflx
    else
      qflx = -999.0
    end if
  end if
  return (qflx)
end

function get_PBLH (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PBLH")) then
    pblh = outptr->PBLH
  else
    if (isfilevar(inptr,"PBLH")) then     
      tmp = inptr->PBLH(0,:,:)
      if (typeof(tmp).eq."double") then
        pblh = dble2flt(tmp)
      else
        pblh = tmp
      end if
      pblh@long_name = "Planet bndry layer hgt"
      pblh@units = "meters"
      assignFillValue(pblh,pblh)
      outptr->PBLH = pblh
    else
      pblh = -999.0
    end if
  end if
  return (pblh)
end

function get_PRECIP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECIP")) then
    prect = outptr->PRECIP
  else
    season = getenv("SEASON")
    if (season .eq. "DJF") then
      ndays = 90.
    end if
    if (season .eq. "SON") then
      ndays = 91.
    end if
    if (season .eq. "JJA".or.season .eq. "MAM") then
      ndays = 92.
    end if
    if (season .eq. "ANN") then
      ndays = 365.
    end if
    precc = inptr->PRECC(0,:,:)   ; m/s
    precl = inptr->PRECL(0,:,:)   ; m/s
    tmp = precc                
    tmp = (/(precc+precl)*86400.*100.*ndays/)  ; cm per season
    if (typeof(tmp).eq."double") then
      precip = dble2flt(tmp)
    else
      precip = tmp
    end if
    precip@units = "cm"
    precip@long_name = "Cumulative precipitation" 
    outptr->PRECIP = precip
  end if
  return (precip)
end

function get_PRECIP_LAND (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECIP_LAND")) then
    prect = outptr->PRECIP_LAND
  else
    season = getenv("SEASON")
    if (season .eq. "DJF") then
      ndays = 90.
    end if
    if (season .eq. "JJA") then
      ndays = 92.
    end if
    if (season .eq. "ANN") then
      ndays = 365.
    end if
    precc = inptr->PRECC(0,:,:)   ; m/s
    precl = inptr->PRECL(0,:,:)   ; m/s
    precip = precc                
    precip = (/(precc+precl)*86400.*100.*ndays/)  ; cm per season
    tmp = precip
    if (isfilevar(inptr,"OCNFRAC") .and. isfilevar(inptr,"ICEFRAC")) then
      icefrac = inptr->ICEFRAC(0,:,:)
      ocnfrac = inptr->OCNFRAC(0,:,:)
      landfrac = ocnfrac
      landfrac = (/1.0-(ocnfrac+icefrac)/) 
      tmp = mask(precip,landfrac.ge.0.65,True)
    else
      if (isfilevar(inptr,"ORO")) then
        oro = inptr->ORO(0,:,:)
        tmp = mask(precip,oro,1)            ; mask with land 
      else
        precip_land = -999.0
        return (precip_land)
      end if
    end if
    if (typeof(tmp).eq."double") then
      precip_land = dble2flt(tmp)
    else
      precip_land = tmp
    end if
    precip_land@units = "cm"
    precip_land@long_name = "Cumulative precipitation (land)" 
  end if
  return (precip_land)
end

function get_PRECSC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECSC")) then
    precsc = outptr->PRECSC
  else
    if (isfilevar(inptr,"PRECSC")) then     
      precsc = inptr->PRECSC(0,:,:)   ; m/s
      tmp = precsc               
      tmp = (/precsc*8.64e7/)  ; convert to mm/day
      if (typeof(tmp).eq."double") then
        precsc = dble2flt(tmp)
      else
        precsc = tmp
      end if
      precsc@units = "mm/day"
      precsc@long_name = "Snowfall rate (convective)" 
      precsc@derive_op = "PRECSC*8.64e7"
      outptr->PRECSC = precsc
    else
      precsc = -999.0
    end if
  end if
  return (precsc)
end

function get_PRECSL (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECSL")) then
    precsl = outptr->PRECSL
  else
    if (isfilevar(inptr,"PRECSL")) then     
      precsl = inptr->PRECSL(0,:,:)   ; m/s
      tmp = precsl               
      tmp = (/precsl*8.64e7/)  ; convert to mm/day
      if (typeof(tmp).eq."double") then
        precsl = dble2flt(tmp)
      else
        precsl = tmp
      end if
      precsl@units = "mm/day"
      precsl@long_name = "Snowfall rate (stratiform)" 
      precsl@derive_op = "PRECSL*8.64e7"
      outptr->PRECSL = precsl
    else
      precsl = -999.0
    end if
  end if
  return (precsl)
end

function get_PRECST (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECST")) then
    precst = outptr->PRECST
  else
    if (isfilevar(inptr,"PRECSL").and.isfilevar(inptr,"PRECSC")) then     
      precsl = inptr->PRECSL(0,:,:)   ; m/s
      precsc = inptr->PRECSC(0,:,:)   ; m/s
      tmp = precsc               
      tmp = (/(precsc+precsl)*8.64e7/)  ; convert to mm/day
      if (typeof(tmp).eq."double") then
        precst = dble2flt(tmp)
      else
        precst = tmp
      end if
      precst@units = "mm/day"
      precst@long_name = "Snowfall rate" 
      precst@derive_op = "(PRECSL+PRECSC)*8.64e7"
      outptr->PRECST = precst
    else
      precst = -999.0
    end if
  end if
  return (precst)
end

function get_PRECC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECC")) then
    precc = outptr->PRECC
  else
    if (isfilevar(inptr,"PRECC")) then     
      precc = inptr->PRECC(0,:,:)   ; m/s
      tmp = precc               
      tmp = (/precc*8.64e7/)  ; convert to mm/day
      if (typeof(tmp).eq."double") then
        precc = dble2flt(tmp)
      else
        precc = tmp
      end if
      precc@units = "mm/day"
      precc@long_name = "Precipitation rate (convective)" 
      precc@derive_op = "PRECC*8.64e7"
      outptr->PRECC = precc
    else
      precc = -999.0
    end if
  end if
  return (precc)
end

function get_PRECL (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECL")) then
    precl = outptr->PRECL
  else
    if (isfilevar(inptr,"PRECL")) then     
      precl = inptr->PRECL(0,:,:)   ; m/s
      tmp = precl               
      tmp = (/precl*8.64e7/)  ; convert to mm/day
      if (typeof(tmp).eq."double") then
        precl = dble2flt(tmp)
      else
        precl = tmp
      end if
      precl@units = "mm/day"
      precl@long_name = "Precipitation rate (stratiform)" 
      precl@derive_op = "PRECL*8.64e7"
      outptr->PRECL = precl
    else
      precl = -999.0
    end if
  end if
  return (precl)
end

function get_PRECT (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECT")) then
    prect = outptr->PRECT
  else
    precc = inptr->PRECC(0,:,:)   ; m/s
    precl = inptr->PRECL(0,:,:)   ; m/s
    tmp = precc                
    tmp = (/(precc+precl)*8.64e7/)  ; convert to mm/day
    if (typeof(tmp).eq."double") then
      prect = dble2flt(tmp)
    else
      prect = tmp
    end if
    prect@units = "mm/day"
    prect@long_name = "Precipitation rate" 
    prect@derive_op = "(PRECC+PRECL)*8.64e7"
    assignFillValue(prect,prect)
    outptr->PRECT = prect
  end if
  return (prect)
end

function get_PRECT_LAND (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECT_LAND")) then
    prect_land = outptr->PRECT_LAND
  else
    if (inptr@source .eq. "GFDL") then
      prect_land = inptr->PRECT_LAND(0,:,:)
      outptr->PRECT_LAND = prect_land
    else
      precc = inptr->PRECC(0,:,:)   ; m/s
      precl = inptr->PRECL(0,:,:)   ; m/s
      prect = precc                
      prect  = (/(precc+precl)*8.64e7/)  ; convert to mm/day
      tmp = prect
      if (isfilevar(inptr,"LANDFRAC")) then
        landfrac = inptr->LANDFRAC(0,:,:)
        tmp = mask(prect,landfrac.ge.0.50,True)
      else
        if (isfilevar(inptr,"OCNFRAC") .and. isfilevar(inptr,"ICEFRAC")) then
          icefrac = inptr->ICEFRAC(0,:,:)
          ocnfrac = inptr->OCNFRAC(0,:,:)
          landfrac = ocnfrac
          landfrac = (/1.0-(ocnfrac+icefrac)/) 
          tmp = mask(prect,landfrac.ge.0.50,True)
        else
          if (isfilevar(inptr,"ORO")) then
            oro = inptr->ORO(0,:,:)
            tmp = mask(prect,oro,1)            ; mask with land 
          else
            print("PRECT_LAND: no ORO or LANDFRAC variables")
            prect_land = -999.0
            return (prect_land)
          end if
        end if
      end if
      if (typeof(tmp).eq."double") then
        prect_land = dble2flt(tmp)
      else
        prect_land = tmp
      end if
      prect_land@units = "mm/day"
      prect_land@long_name = "Precipitation rate"
      prect_land@derive_op = "(PRECC+PRECL)*8.64e7 masked for land"
      assignFillValue(prect_land,prect_land)
      outptr->PRECT_LAND = prect_land
    end if
  end if
  return (prect_land)
end

function get_PRECT_OCEAN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PRECT_OCEAN")) then
    prect_ocean = outptr->PRECT_OCEAN
  else
    precc = inptr->PRECC(0,:,:)   ; m/s
    precl = inptr->PRECL(0,:,:)   ; m/s
    prect = precc                
    prect  = (/(precc+precl)*8.64e7/)  ; convert to mm/day
    tmp = prect
    if (isfilevar(inptr,"OCNFRAC")) then
      ocnfrac = inptr->OCNFRAC(0,:,:)
      tmp = mask(prect,ocnfrac.ge.0.65,True)
    else
      if (isfilevar(inptr,"ORO")) then
        oro = inptr->ORO(0,:,:)
        tmp = mask(prect,oro,0) 
      else
        print("PRECT_OCEAN: no ORO or OCNFRAC variables")
        prect_ocean = -999.0
        return (prect_ocean)
      end if
    end if
    if (typeof(tmp).eq."double") then
      prect_ocean = dble2flt(tmp)
    else
      prect_ocean = tmp
    end if
    prect_ocean@units = "mm/day"
    prect_ocean@long_name = "Precipitation rate"
    prect_ocean@derive_op = "(PRECC+PRECL)*8.64e7 masked by ocean"
    assignFillValue(prect_ocean,prect_ocean)
    outptr->PRECT_OCEAN = prect_ocean
  end if
  return (prect_ocean)
end

function get_PREH2O (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PREH2O")) then
    preh2o = outptr->PREH2O
  else
    if (isfilevar(inptr,"TMQ") .or. isfilevar(inptr,"MQ")) then
      if (isfilevar(inptr,"TMQ")) then        ; in ccm3.10
        tmp = inptr->TMQ(0,:,:) 
      else
        mq = inptr->MQ(0,:,:,:)  ; (lev,lat,lon) in ccm3.6 
        tmp = mq(0,:,:)          ; (lat,lon)
        tmp = dim_sum_n (mq, 0)
      ;;tmp = dim_sum (mq(lat|:,lon|:,lev|:))
      end if
      if (typeof(tmp).eq."double") then
        preh2o = dble2flt(tmp)
      else
        preh2o = tmp
      end if
      preh2o@units = "mm"
      preh2o@long_name = "Precipitable water"
      assignFillValue(preh2o,preh2o)
      outptr->PREH2O = preh2o
    else
      print("PREH2O: no TMQ or MQ variables")
      preh2o = -999.0
    end if
  end if
  return (preh2o)
end

function get_PREH2O_OCEAN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PREH2O_OCEAN")) then
    preh2o_ocean = outptr->PREH2O_OCEAN
  else
    if (isfilevar(inptr,"TMQ") .or. isfilevar(inptr,"MQ")) then
      if (isfilevar(inptr,"TMQ")) then        ; in ccm3.10
        tmq = inptr->TMQ(0,:,:) 
      else
        mq = inptr->MQ(0,:,:,:)   ; (lev,lat,lon) in ccm3.6 
        tmq = mq(0,:,:)           ; (lat,lon)
        tmq = dim_sum_n (mq, 0)
      ;;tmq = dim_sum (mq(lat|:,lon|:,lev|:))
      end if
      tmp = tmq
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        tmp = mask(tmq,ocnfrac.ge.0.65,True)
      else
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = mask(tmq,oro,0)            ; mask with ocean
        else
          print("PREH2O_OCEAN: no ORO or OCNFRAC variables")
          preh2o_ocean = -999.0
          return (preh2o_ocean)
        end if
      end if
      if (typeof(tmp).eq."double") then
        preh2o_ocean = dble2flt(tmp)
      else
        preh2o_ocean = tmp
      end if
      preh2o_ocean@units = "mm"
      preh2o_ocean@long_name = "Precipitable water"
      preh2o_ocean@derive_op = "PREH2O masked by ocean"
      assignFillValue(preh2o_ocean,preh2o_ocean)
      outptr->PREH2O_OCEAN = preh2o_ocean
    else
      print("PREH2O_OCEAN: no TMQ or MQ variables")
      preh2o_ocean = -999.0
    end if
  end if
  return (preh2o_ocean)
end

function get_PSI_200 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PSI_200")) then
    psi_200 = outptr->PSI_200
  else
    u = inptr->U(0,:,:,:)     ; (lev,lat,lon)
    v = inptr->V(0,:,:,:)
    psi = u
    chi = u
    if (inptr@source .eq. "GFDL") then
      uv2sfvpf(u,v,psi,chi)
      psi_200 = psi(9,:,:)
    else
      uv2sfvpg(u,v,psi,chi)
      ps = inptr->PS(0,:,:)       ; Pa
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = vinth2p(psi,hyam,hybm,200.,ps,2,1000.,1,False)
      if (typeof(tmp).eq."double") then
        psi_200 = dble2flt(tmp(0,:,:))   
      else
        psi_200 = tmp(0,:,:)
      end if       
    end if
    psi_200 = (/psi_200/1.e7/)   ; divided by 10^7 
    psi_200@units = "m~S~2~N~/s x 10~S~7~N~"
    psi_200@long_name = "200mb stream function"
    psi_200@derive_op = "uv2sfvpg(u,v,psi,chi) divided by 10^7"
    assignFillValue(psi_200,psi_200)
    outptr->PSI_200 = psi_200
  end if
  return (psi_200)
end 

function get_PS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PS")) then
    ps = outptr->PS
  else
    tmp = inptr->PS(0,:,:)   ; Pa
    tmp = (/tmp/100./)       ; convert to mb
    if (typeof(tmp).eq."double") then
      ps = dble2flt(tmp)
    else
      ps = tmp
    end if
    ps@long_name = "surface pressure"
    ps@units = "millibars"
    ps@derive_op = "PS divided by 100."
    assignFillValue(ps,ps)
    outptr->PS = ps
  end if
  return (ps)
end

function get_PSL (inptr:file,outptr:file)
begin
 if (isfilevar(outptr,"PSL")) then
    psl = outptr->PSL
  else
    if (isfilevar(inptr,"PSL")) then
      tmp = inptr->PSL(0,:,:)  ; Pa
      tmp = (/tmp/100./)       ; convert to mb
      if (typeof(tmp).eq."double") then
        psl = dble2flt(tmp)
      else
        psl = tmp
      end if
      psl@long_name = "Sea-level pressure"
      psl@units = "millibars"
      psl@derive_op = "PSL divided by 100."
      assignFillValue(psl,psl)
      outptr->PSL = psl
    else
      psl = -999.0
    end if
  end if
  return (psl)
end

function get_RESSURF (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"RESSURF")) then
    ressurf = outptr->RESSURF
  else
    fsns = inptr->FSNS(0,:,:)      ; W/m^2
    flns = inptr->FLNS(0,:,:)      ; W/m^2
    shflx = inptr->SHFLX(0,:,:)    ; W/m^2
    qflx = inptr->QFLX(0,:,:)      ; kg/(m^2 s)
    Lv = 2.501e6                   ; J/kg
    if (isfilevar(inptr,"PRECSC").and.isfilevar(inptr,"PRECSL")) then
      Lf = 3.337e5                   ; J/kg
      precc = inptr->PRECC(0,:,:)    ; m/s
      precl = inptr->PRECL(0,:,:)    ; m/s
      precsc = inptr->PRECSC(0,:,:)  ; m/s
      precsl = inptr->PRECSL(0,:,:)  ; m/s
      lhflx = qflx
      lhflx = (/(Lv+Lf)*qflx - Lf*1.e3*(precc+precl-precsc-precsl)/)
      lhflx@derive_op = "(Lv+Lf)*qflx-Lf*(prect-precsc-precl)"
    else
      lhflx = qflx
      lhflx = (/Lv*qflx/)              ; W/m^2
      lhflx@derive_op = "Lv*qflx"
    end if
    tmp = fsns
    tmp = (/fsns-flns-shflx-lhflx/)
    if (typeof(tmp).eq."double") then
      ressurf = dble2flt(tmp)
    else
      ressurf = tmp
    end if
    ressurf@long_name = "Residual surf energy"
    ressurf@units = "W/m~S~2~N~"
    ressurf@derive_op = "fsns-flns-shflx-"+lhflx@derive_op
    outptr->RESSURF = ressurf
  end if
  return (ressurf)
end

function get_RESTOA (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"RESTOA")) then
    restoa = outptr->RESTOA
  else
    if (isfilevar(inptr,"FLUT")) then
      fsntoa = inptr->FSNTOA(0,:,:)
      flut = inptr->FLUT(0,:,:)
      tmp = flut
      tmp = (/fsntoa-flut/)
      if (typeof(tmp).eq."double") then
        restoa = dble2flt(tmp)
      else
        restoa = tmp
      end if
      restoa@units = "W/m~S~2~N~"
      restoa@long_name = "TOA residual energy"
      restoa@derive_op = "FSNTOA-FLUT"
      assignFillValue(restoa,restoa)
      outptr->RESTOA = restoa
    else
      print("RESTOA: no FLUT or FSNTOA variables present")
      restoa = -999.0
    end if
  end if
  return (restoa)
end

function get_RESTOM (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"RESTOM")) then
    restom = outptr->RESTOM
  else
    fsnt = inptr->FSNT(0,:,:)
    flnt = inptr->FLNT(0,:,:)
    tmp = fsnt
    tmp = (/fsnt-flnt/)
    if (typeof(tmp).eq."double") then
      restom = dble2flt(tmp)
    else
      restom = tmp
    end if
    restom@units = "W/m~S~2~N~"
    restom@long_name = "TOM residual energy"
    restom@derive_op = "FSNT-FLNT"
    assignFillValue(restom,restom)
    outptr->RESTOM = restom
  end if
  return (restom)
end

function get_SHFLX (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SHFLX")) then
    shflx = outptr->SHFLX
  else
    tmp = inptr->SHFLX(0,:,:)
    if (typeof(tmp).eq."double") then
      shflx = dble2flt(tmp)
    else
      shflx = tmp
    end if
    shflx@units = "W/m~S~2~N~"
    shflx@long_name = "Surf sensible heat"
    assignFillValue(shflx,shflx)
    outptr->SHFLX = shflx
  end if
  return (shflx)
end

function get_SNOWFALL (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SNOWFALL")) then
    snowfall = outptr->SNOWFALL
  else
    if (isfilevar(inptr,"CPLSNOWC")) then
      snowc = inptr->CPLSNOWC(0,:,:)
      snowl = inptr->CPLSNOWL(0,:,:)
      tmp = snowc
      tmp = (/(snowc+snowl)*86400./)
      if (typeof(tmp).eq."double") then
        snowfall = dble2flt(tmp)
      else
        snowfall = tmp
      end if
      snowfall@long_name = "Snowfall sent to coupler"
      snowfall@units = "mm/day"
      snowfall@derive_op = "(SNOWC+SNOWL)*86400."
      assignFillValue(snowfall,snowfall)
      outptr->SNOWFALL = snowfall
    else
;     print ("SNOWFALL valid for coupled model only") 
      snowfall = -999.0
    end if
    return (snowfall)
  end if
end

function get_SNOWH (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SNOWH")) then
    snowh = outptr->SNOWH
  else
    if (isfilevar(inptr,"SNOWH")) then
      tmp = inptr->SNOWH(0,:,:)  ; meters 
      tmp = (/tmp*100./)         ; convert to cm
      if (typeof(tmp).eq."double") then
        snowh = dble2flt(tmp)
      else
        snowh = tmp
      end if
      snowh@long_name = "Snow depth water equiv"
      snowh@units = "cm"
      snowh@derive_op = "SNOWH multiplied by 100."
      assignFillValue(snowh,snowh)
      outptr->SNOWH = snowh
    else
;     print ("SNOWH not present in this model version") 
      snowh = -999.0
    end if
  end if
  return (snowh)
end

function get_SNOWHICE (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SNOWHICE")) then
    snowhice = outptr->SNOWHICE
  else
    if (isfilevar(inptr,"SNOWHICE")) then
      icefrac = inptr->ICEFRAC(0,:,:)
      tmp = inptr->SNOWHICE(0,:,:)    ; meters 
      sdice = tmp 
      sdice = (/mask(tmp,icefrac.gt.0,True)*100./)  ; convert to cm
      if (typeof(sdice).eq."double") then
        snowhice = dble2flt(sdice)
      else
        snowhice = sdice
      end if
      snowhice@long_name = "Seaice snow depth water equiv"
      snowhice@units = "cm"
      snowhice@derive_op = "SNOWHICE multiplied by 100."
      assignFillValue(snowhice,snowhice)
      outptr->SNOWHICE = snowhice
    else
;     print ("SNOWHICE not present in this model version") 
      snowhice = -999.0
    end if
  end if
  return (snowhice)
end

function get_SNOWHLND (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SNOWHLND")) then
    snowhlnd = outptr->SNOWHLND
  else
    if (isfilevar(inptr,"SNOWHLND")) then
      landfrac = inptr->LANDFRAC(0,:,:)
      tmp = inptr->SNOWHLND(0,:,:)      ; meters 
      sdlnd = tmp
      sdlnd = (/mask(tmp,landfrac.gt.0,True)*100./) ; convert to cm
      if (typeof(sdlnd).eq."double") then
        snowhlnd = dble2flt(sdlnd)
      else
        snowhlnd = sdlnd
      end if
      snowhlnd@long_name = "Land snow depth water equiv"
      snowhlnd@units = "cm"
      snowhlnd@derive_op = "SNOWHLND multiplied by 100."
      assignFillValue(snowhlnd,snowhlnd)
      outptr->SNOWHLND = snowhlnd
    else
;     print ("SNOWHLND not present in this model version") 
      snowhlnd = -999.0
    end if
  end if
  return (snowhlnd)
end

function get_SOLIN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SOLIN")) then
    solin = outptr->SOLIN
  else
    if (isfilevar(inptr,"SOLIN")) then
      tmp = inptr->SOLIN(0,:,:) 
      if (typeof(tmp).eq."double") then
        solin = dble2flt(tmp)
      else
        solin = tmp
      end if
      solin@long_name = "Insolation"
      solin@units = "W/m~S~2~N~"
      assignFillValue(solin,solin)
      outptr->SOLIN = solin
    else
      solin = -999.0
    end if
  end if
  return (solin)
end

function get_SST (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SST")) then
    sst = outptr->SST
  else
    if (isfilevar(inptr,"TS")) then 
      tmp = inptr->TS(0,:,:) 
      if (typeof(tmp).eq."double") then
        ts = dble2flt(tmp)
      else
        ts = tmp
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
      outptr->SST = sst
    else
      sst = -999.0
    end if 
  end if
  return (sst)
end

function get_STRESS_MAG (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"STRESS_MAG")) then
    stress_mag = outptr->STRESS_MAG
  else
    if (isfilevar(inptr,"TAUX") .and. isfilevar(inptr,"TAUY")) then
      tx = inptr->TAUX(0,:,:)
      ty = inptr->TAUY(0,:,:)
      taux = tx
      tauy = ty
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        taux = (/-1.0*mask(tx,ocnfrac.ge.0.5,True)/)
        tauy = (/-1.0*mask(ty,ocnfrac.ge.0.5,True)/)
      else
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          taux = (/-1.0*mask(tx,oro,0)/)         ; mask with ocean
          tauy = (/-1.0*mask(ty,oro,0)/)         ; mask with ocean
        else
          print("STRESS_MAG: no ORO or OCNFRAC variables")
          stress_mag = -999.0
          return (stress_mag)
        end if
      end if
      tmp = taux
      tmp = (/sqrt(taux^2+tauy^2)/)
      if (typeof(tmp).eq."double") then
        stress_mag = dble2flt(tmp)
      else
        stress_mag = tmp
      end if
      stress_mag@units = "N/m~S~2~N~"
      stress_mag@long_name = "Surface stress magnitude"
      stress_mag@derive_op = "sqrt(taux^2+tauy^2)"
      assignFillValue(stress_mag,stress_mag)
      outptr->STRESS_MAG = stress_mag
    else
      stress_mag = -999.0
    end if
  end if
  return (stress_mag)
end

function get_SWCFSRF (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SWCFSRF")) then
    swcfsrf = outptr->SWCFSRF
  else
    fsns = inptr->FSNS(0,:,:) 
    fsnsc = inptr->FSNSC(0,:,:) 
    tmp = fsns
    tmp = (/fsns-fsnsc/)
    if (typeof(tmp).eq."double") then
      swcfsrf = dble2flt(tmp)
    else
      swcfsrf = tmp
    end if
    swcfsrf@long_name = "Surface SW cloud forcing"
    swcfsrf@units = "W/m~S~2~N~"
    outptr->SWCFSRF = swcfsrf
  end if
  return (swcfsrf)
end

function get_SWCFTOA (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SWCFTOA")) then
    swcftoa = outptr->SWCFTOA
  else
    if (isfilevar(inptr,"SWCF")) then     ; in ccm3.10
      tmp = inptr->SWCF(0,:,:)
      if (typeof(tmp).eq."double") then
        swcftoa = dble2flt(tmp)
      else
        swcftoa = tmp
      end if
      swcftoa@long_name = "TOA SW cloud forcing"
      swcftoa@units = "W/m~S~2~N~"
      assignFillValue(swcftoa,swcftoa)
      outptr->SWCFTOA = swcftoa
    else
      print("SWCFTOA: no SWCF variable present")
      swcftoa = -999.0
    end if
  end if
  return (swcftoa)
end

function get_SWCFTOM (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SWCFTOM")) then
    swcftom = outptr->SWCFTOM
  else
    fsnt = inptr->FSNT(0,:,:)
    fsntc = inptr->FSNTC(0,:,:)
    tmp = fsnt
    tmp = (/fsnt-fsntc/)
    if (typeof(tmp).eq."double") then
      swcftom = dble2flt(tmp)
    else
      swcftom = tmp
    end if
    swcftom@derive_op = "SWCFTOM=FSNT-FSNTC"
    swcftom@units = "W/m~S~2~N~"
    swcftom@long_name = "TOM SW cloud forcing"
    assignFillValue(swcftom,swcftom)
    outptr->SWCFTOM = swcftom
  end if
  return (swcftom)
end

function get_T_200 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"T_200")) then
    t_200 = outptr->T_200
  else
    if (inptr@source .eq. "GFDL") then
      t_200 = inptr->T(0,9,:,:)        ; 200 mb
      t_200@long_name = "200 mb Temp"
      t_200@units = "K"
      outptr->T_200 = t_200
    else
      t = inptr->T(0,:,:,:)     ; (lev,lat,lon)
      ps = inptr->PS(0,:,:)     ; Pa 
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = vinth2p(t,hyam,hybm,200.,ps,2,1000.,1,False) 
      if (typeof(tmp).eq."double") then
        t_200 = dble2flt(tmp(0,:,:))
      else
        t_200 = tmp(0,:,:)
      end if
      t_200@long_name = "200 mb Temp"
      t_200@units = "K"
      assignFillValue(t_200,t_200)
      outptr->T_200 = t_200
    end if
  end if
  return (t_200)
end

function get_T_850 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"T_850")) then
    t_850 = outptr->T_850
  else
    if (inptr@source .eq. "GFDL") then
      t_850 = inptr->T(0,2,:,:)        ; 850 mb
      t_850@long_name = "850 mb Temp"
      t_850@units = "K"
      outptr->T_850 = t_850
    else
      t = inptr->T(0,:,:,:)     ; (lev,lat,lon)
      ps = inptr->PS(0,:,:)       ; Pa 
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = vinth2p(t,hyam,hybm,850.,ps,2,1000.,1,False) 
      if (typeof(tmp).eq."double") then
        t_850 = dble2flt(tmp(0,:,:))
      else
        t_850 = tmp(0,:,:)
      end if
      t_850@long_name = "850 mb Temp"
      t_850@units = "K"
      assignFillValue(t_850,t_850)
      outptr->T_850 = t_850
    end if
  end if
  return (t_850)
end

function get_T_900 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"T_900")) then
    t_900 = outptr->T_900
  else
    t = inptr->T(0,:,:,:)     ; (lev,lat,lon)
    ps = inptr->PS(0,:,:)     ; Pa 
    hyam = inptr->hyam
    hybm = inptr->hybm
    tmp = vinth2p(t,hyam,hybm,900.,ps,2,1000.,1,False) 
    if (typeof(tmp).eq."double") then
      t_900 = dble2flt(tmp(0,:,:))
    else
      t_900 = tmp(0,:,:)
    end if
    t_900@long_name = "900 mb Temp"
    t_900@units = "K"
    assignFillValue(t_900,t_900)
    outptr->T_900 = t_900
  end if
  return (t_900)
end

function get_T_950 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"T_950")) then
    t_950 = outptr->T_950
  else
    t = inptr->T(0,:,:,:)     ; (lev,lat,lon)
    ps = inptr->PS(0,:,:)     ; Pa 
    hyam = inptr->hyam
    hybm = inptr->hybm
    tmp = vinth2p(t,hyam,hybm,950.,ps,2,1000.,1,False) 
    if (typeof(tmp).eq."double") then
      t_950 = dble2flt(tmp(0,:,:))
    else
      t_950 = tmp(0,:,:)
    end if
    t_950@long_name = "950 mb Temp"
    t_950@units = "K"
    assignFillValue(t_950,t_950)
    outptr->T_950 = t_950
  end if
  return (t_950)
end

function get_TAUX_OCEAN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUX")) then
    taux = outptr->TAUX
  else
    if (isfilevar(inptr,"TAUX")) then
      tx = inptr->TAUX(0,:,:)
      tmp = tx
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        tmp = (/-1.0*mask(tx,ocnfrac.ge.0.5,True)/)
      else
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = (/-1.0*mask(tx,oro,0)/)         ; mask with ocean
        else
          print("TAUX: no ORO or OCNFRAC variables")
          taux = -999.0
          return (taux)
        end if
      end if
      if (typeof(tmp).eq."double") then
        taux = dble2flt(tmp)
      else
        taux = tmp
      end if
      taux@units = "N/m~S~2~N~"
      taux@long_name = "Surface zonal stress"
      taux@derive_op = "-TAUX masked by ocean"
      assignFillValue(taux,taux)
      outptr->TAUX = taux
    else
      taux = -999.0
    end if
  end if
  return (taux)
end

function get_TAUY_OCEAN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUY")) then
    tauy = outptr->TAUY
  else
    if (isfilevar(inptr,"TAUY")) then
      ty = inptr->TAUY(0,:,:)
      tmp = ty
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        tmp = (/-1.0*mask(ty,ocnfrac.ge.0.5,True)/)
      else
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = (/-1.0*mask(ty,oro,0)/)         ; mask with ocean
        else
          print("TAUY: no ORO or OCNFRAC variables")
          tauy = -999.0
          return (tauy)
        end if
      end if
      if (typeof(tmp).eq."double") then
        tauy = dble2flt(tmp)
      else
        tauy = tmp
      end if
      tauy@units = "N/m~S~2~N~"
      tauy@long_name = "Surface merid stress"
      tauy@derive_op = "-TAUY masked by ocean"
      assignFillValue(tauy,tauy)
      outptr->TAUY = tauy
    else
      tauy = -999.0
    end if
  end if
  return (tauy)
end

function get_TGCLDIWP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TGCLDIWP")) then
    tgcldiwp = outptr->TGCLDIWP
  else
    if (isfilevar(inptr,"TGCLDIWP")) then
      tmp = inptr->TGCLDIWP(0,:,:)
      ;  "kg/m2" -> "gram/m2"
      if (isfilevaratt(inptr,"TGCLDIWP", "units") ) then
        wp_units = tmp@units
        if (wp_units .eq. "kg/m2" ) then
           tmp = (/tmp*1000./)   
        end if 
      end if 
      if (typeof(tmp).eq."double") then
        tgcldiwp = dble2flt(tmp)
      else
        tgcldiwp = tmp
      end if
      tgcldiwp@long_name = "Total grd-box cloud IWP"
      tgcldiwp@units = "g/m~S~2~N~"
      assignFillValue(tgcldiwp,tgcldiwp)
      outptr->TGCLDIWP = tgcldiwp 
    else
      tgcldiwp = -999.0
    end if
  end if
  return (tgcldiwp)
end 

function get_TGCLDLWP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TGCLDLWP")) then
    tgcldlwp = outptr->TGCLDLWP
  else 
    if (isfilevar(inptr,"TGCLDLWP")) then
      tmp = inptr->TGCLDLWP(0,:,:)
      ;  "kg/m2" -> "gram/m2"
      if (isfilevaratt(inptr,"TGCLDLWP", "units") ) then
        wp_units = tmp@units
        if (wp_units .eq. "kg/m2" ) then
           tmp = (/tmp * 1000./)   
        end if 
      end if 
      if (typeof(tmp).eq."double") then
        tgcldlwp = dble2flt(tmp)
      else
        tgcldlwp = tmp
      end if
      tgcldlwp@long_name = "Total grd-box cloud LWP"
      tgcldlwp@units = "g/m~S~2~N~"
      assignFillValue(tgcldlwp,tgcldlwp)
      outptr->TGCLDLWP = tgcldlwp 
    else
      tgcldlwp = -999.0
    end if
  end if
  return (tgcldlwp)
end 

function get_TGCLDLWP_OCEAN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TGCLDLWP_OCEAN")) then
    tgcldlwp_ocean = outptr->TGCLDLWP_OCEAN
  else
    if (isfilevar(inptr,"TGCLDLWP")) then    ; in ccm3.10
      tmp1 = inptr->TGCLDLWP(0,:,:) 
      ;  "kg/m2" -> "gram/m2"
      if (isfilevaratt(inptr,"TGCLDLWP", "units") ) then
        wp_units = tmp1@units
        if (wp_units .eq. "kg/m2" ) then
           tmp1 = (/tmp1 * 1000./)   
        end if 
      end if 
      tmp = tmp1
      if (isfilevar(inptr,"OCNFRAC")) then
        ocnfrac = inptr->OCNFRAC(0,:,:)
        tmp = mask(tmp1,ocnfrac.ge.0.65,True)
      else
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = mask(tmp1,oro,0)            ; mask with ocean
        else
          print("TGCLDLWP_OCEAN: no ORO or OCNFRAC variables")
          tgcldlwp_ocean = -999.0
          return (tgcldlwp_ocean)
        end if
      end if
      if (typeof(tmp).eq."double") then
        tgcldlwp_ocean = dble2flt(tmp)
      else
        tgcldlwp_ocean = tmp
      end if
      tgcldlwp_ocean@long_name = "Total grd-box cloud LWP"
      tgcldlwp_ocean@units = "g/m~S~2~N~"
      tgcldlwp_ocean@derive_op = "TGCLDLWP masked by ocean"
      assignFillValue(tgcldlwp_ocean,tgcldlwp_ocean)
      outptr->TGCLDLWP_OCEAN = tgcldlwp_ocean 
    else
      tgcldlwp_ocean = -999.0
    end if
  end if
  return (tgcldlwp_ocean)
end 

function get_TICLDIWP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TICLDIWP")) then
    ticldiwp = outptr->TICLDIWP
    ;  "kg/m2" -> "gram/m2"
    if (isfilevaratt(inptr,"TICLDIWP", "units") ) then
      wp_units = ticldiwp@units
      if (wp_units .eq. "kg/m2" ) then
        ticldiwp = (/ticldiwp * 1000./)   
      end if 
    end if 
  else
    if (isfilevar(inptr,"ICLDIWP")) then
      tmp = inptr->ICLDIWP(0,:,:,:)      ; (lev,lat,lon)
      ;  "kg/m2" -> "gram/m2"
      if (isfilevaratt(inptr,"ICLDIWP", "units") ) then
        wp_units = tmp@units
        if (wp_units .eq. "kg/m2" ) then
          tmp = (/tmp * 1000./)   
        end if 
      end if 
      icldiwp = tmp(0,:,:)               ; (lat,lon)
      icldiwp = dim_sum_n(tmp, 0)
    ;;icldiwp = dim_sum(tmp(lat|:,lon|:,lev|:))
      if (typeof(icldiwp).eq."double") then
        ticldiwp = dble2flt(icldiwp)
      else
        ticldiwp = icldiwp
      end if
      ticldiwp@units = "g/m~S~2~N~"
      ticldiwp@long_name = "In-cloud ice WP"
      assignFillValue(ticldiwp,ticldiwp)
      outptr->TICLDIWP = ticldiwp 
    else
      ticldiwp = -999.0
    end if
  end if
  return (ticldiwp)
end

function get_TICLDTWP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TICLDTWP")) then
    ticldtwp = outptr->TICLDTWP ; kg/m2->g/m2
    ;  "kg/m2" -> "gram/m2"
    if (isfilevaratt(inptr,"TICLDTWP", "units") ) then
      wp_units = ticldtwp@units
      if (wp_units .eq. "kg/m2" ) then
        ticldtwp = (/ticldtwp * 1000./)   
      end if 
    end if 
  else   ; total condensate (ice+liquid)
    if (isfilevar(inptr,"ICLDTWP")) then
      tmp = inptr->ICLDTWP(0,:,:,:)      ; (lev,lat,lon)
      ; kg/m2->g/m2
      if (isfilevaratt(inptr,"ICLDTWP", "units") ) then
        wp_units = tmp@units
        if (wp_units .eq. "kg/m2" ) then
          tmp = (/tmp * 1000./)   
        end if 
      end if 
      icldtwp = tmp(0,:,:)               ; (lat,lon)
      icldtwp = dim_sum_n(tmp, 0)
    ;;icldtwp = dim_sum(tmp(lat|:,lon|:,lev|:))
      if (typeof(icldtwp).eq."double") then
        ticldtwp = dble2flt(icldtwp)
      else
        ticldtwp = icldtwp
      end if
      ticldtwp@units = "g/m~S~2~N~"
      ticldtwp@long_name = "In-cloud ice+liquid WP"
      assignFillValue(ticldtwp,ticldtwp)
      outptr->TICLDTWP = ticldtwp 
    else
      ticldtwp = -999.0
    end if
  end if
  return (ticldtwp)
end

function get_TICLDLIQWP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TICLDLIQWP")) then
    ticldliqwp = outptr->TICLDLIQWP
    ;  "kg/m2" -> "gram/m2"
      if (isfilevaratt(inptr,"TICLDLIQWP", "units") ) then
        wp_units = tmp@units
        if (wp_units .eq. "kg/m2" ) then
          ticldliqwp = (/ticldliqwp * 1000./)   
        end if 
      end if 
  else
    if (isfilevar(inptr,"ICLDTWP") .and. isfilevar(inptr,"ICLDIWP")) then
      total = inptr->ICLDTWP(0,:,:,:)      ; (lev,lat,lon) liquid+ice
      ice = inptr->ICLDIWP(0,:,:,:)        ; (lev,lat,lon) ice
      liq = total                          ; (lev,lat,lon)
      liq = (/(total-ice)/)                  ; (lev,lat,lon)
     ;  "kg/m2" -> "gram/m2"
      if (isfilevaratt(inptr,"ICLDTWP", "units") ) then
        wp_units = liq@units
        if (wp_units .eq. "kg/m2" ) then
          liq = (/1000.*liq/)    
        end if 
      end if 

      icldliqwp = liq(0,:,:)                 ; (lat,lon)
      icldliqwp = dim_sum_n(liq, 0)
    ;;icldliqwp = dim_sum(liq(lat|:,lon|:,lev|:))
      if (typeof(icldliqwp).eq."double") then
        ticldliqwp = dble2flt(icldliqwp)
      else
        ticldliqwp = icldliqwp
      end if
      ticldliqwp@units = "g/m~S~2~N~"
      ticldliqwp@long_name = "In-cloud liquid WP"
      assignFillValue(ticldliqwp,ticldliqwp)
      outptr->TICLDLIQWP = ticldliqwp 
    else
      ticldliqwp = -999.0
    end if
  end if
  return (ticldliqwp)
end

function get_TREFHT (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TREFHT")) then
    trefht = outptr->TREFHT
  else
    tmp = inptr->TREFHT(0,:,:)
    if (typeof(tmp).eq."double") then
      trefht = dble2flt(tmp)
    else
      trefht = tmp
    end if
    trefht@long_name = "2-meter Air Temp"
    trefht@units = "K"
    assignFillValue(trefht,trefht)
    outptr->TREFHT = trefht
  end if
  return (trefht)
end 

function get_TREFHT_LAND (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TREFHT_LAND")) then
    trefht_land = outptr->TREFHT_LAND
  else
    trefht = inptr->TREFHT(0,:,:)
    tmp = trefht
    if (isfilevar(inptr,"LANDFRAC")) then
      landfrac = inptr->LANDFRAC(0,:,:)
      tmp = mask(trefht,landfrac.ge.0.65,True)
    else
      if (isfilevar(inptr,"OCNFRAC") .and. isfilevar(inptr,"ICEFRAC")) then
        icefrac = inptr->ICEFRAC(0,:,:)
        ocnfrac = inptr->OCNFRAC(0,:,:)
        landfrac = ocnfrac
        landfrac = (/1.0-(ocnfrac+icefrac)/) 
        tmp = mask(trefht,landfrac.ge.0.65,True)
      else
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = mask(trefht,oro,1)            ; mask with land 
        else
          print("TREFHT_LAND: no ORO or LANDFRAC variables")
          trefht_land = -999.0
          return (trefht_land)
        end if
      end if
    end if
    if (typeof(tmp).eq."double") then
      trefht_land = dble2flt(tmp)
    else
      trefht_land = tmp
    end if
    trefht_land@long_name = "2-meter Temp (land)"
    trefht_land@units = "K"
    trefht_land@derive_op = "TREFHT masked by land"
    assignFillValue(trefht_land,trefht_land)
    outptr->TREFHT_LAND = trefht_land
  end if
  return (trefht_land)
end 

function get_TS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TS")) then
    ts = outptr->TS
  else
    if (isfilevar(inptr,"TS")) then
      tmp = inptr->TS(0,:,:)
      if (typeof(tmp).eq."double") then
        ts = dble2flt(tmp)
      else
        ts = tmp
      end if
      assignFillValue(ts,ts)
      ts@long_name = "Surf Temp (radiative)"
      outptr->TS = ts
    else
      ts = -999.0
    end if
  end if
  return (ts)
end 

function get_TS_LAND (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TS_LAND")) then
    ts_land = outptr->TS_LAND
  else
    if (isfilevar(inptr,"TS")) then
      ts = inptr->TS(0,:,:)
      tmp = ts
      if (isfilevar(inptr,"LANDFRAC")) then
        landfrac = inptr->LANDFRAC(0,:,:)
        tmp = mask(ts,landfrac.ge.0.65,True)
      else
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = mask(ts,oro,1)            ; mask with land 
        else
          print("TS_LAND: no ORO or LANDFRAC variables")
          ts_land = -999.0
          return (ts_land)
        end if
      end if
      if (typeof(tmp).eq."double") then
        ts_land = dble2flt(tmp)
      else
        ts_land = tmp
      end if
      ts_land@long_name = "Surface Temp (land)"
      ts_land@units = "K"
      ts_land@derive_op = "TS masked by land"
      assignFillValue(ts_land,ts_land)
      outptr->TS_LAND = ts_land
    else
      ts_land = -999.0
    end if
  end if
  return (ts_land)
end 

function get_TTRP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TTRP")) then
    ttrp = outptr->TTRP
  else
    temp = inptr->T(0,{50:250},:,:)  ; (lev,lat,lon)
    tmp = temp(0,:,:)                ; (lat,lon)
    nlat = dimsizes(tmp&lat)
    nlon = dimsizes(tmp&lon)
    do lt = 0, nlat-1 
      do ln = 0, nlon-1
        tmp(lt,ln) = min(temp(:,lt,ln)) 
      end do
    end do
    if (typeof(tmp).eq."double") then
      ttrp = dble2flt(tmp)
    else
      ttrp = tmp
    end if
    ttrp@long_name = "Tropopause Temperature"
    ttrp@units = "K"
    outptr->TTRP = ttrp
  end if
  return (ttrp)
end 

function get_U_200 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"U_200")) then
    u_200 = outptr->U_200
  else
    if (inptr@source .eq. "GFDL") then
      u_200 = inptr->U(0,9,:,:)        ; 200 mb zonal wind
      u_200@long_name = "200mb zonal wind"
      u_200@units = "m/s"
      outptr->U_200 = u_200 
    else
      u = inptr->U(0,:,:,:)     ; (lev,lat,lon)
      ps = inptr->PS(0,:,:)       ; Pa 
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = vinth2p(u,hyam,hybm,200.,ps,2,1000.,1,False) 
      if (typeof(tmp).eq."double") then
        u_200 = dble2flt(tmp(0,:,:))
      else
        u_200 = tmp(0,:,:)
      end if
      u_200@long_name = "200mb Zonal Wind"
      u_200@units = "m/s"
      assignFillValue(u_200,u_200)
      outptr->U_200 = u_200
    end if
  end if
  return (u_200)
end

function get_U_LEV1 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"U_LEV1")) then
    u_lev1 = outptr->U_LEV1
  else
    nlev = dimsizes(inptr->lev)
    tmp = inptr->U(0,nlev-1,:,:)
    if (typeof(tmp).eq."double") then
      u_lev1 = dble2flt(tmp)
    else
      u_lev1 = tmp
    end if
    u_lev1@long_name = "Zonal wind on first model level"
    u_lev1@units = "m/s"
    assignFillValue(u_lev1,u_lev1)
  end if
  outptr->U_LEV1 = u_lev1
  return (u_lev1)
end

function get_V_LEV1 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"V_LEV1")) then
    v_lev1 = outptr->V_LEV1
  else
    nlev = dimsizes(inptr->lev)
    tmp = inptr->V(0,nlev-1,:,:)
    if (typeof(tmp).eq."double") then
      v_lev1 = dble2flt(tmp)
    else
      v_lev1 = tmp
    end if
    v_lev1@long_name = "Meriodinal wind on first model level"
    v_lev1@units = "m/s"
    assignFillValue(v_lev1,v_lev1)
  end if
  outptr->V_LEV1 = v_lev1
  return (v_lev1)
end


function get_U_SURF (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"U_SURF")) then
    u_surf = outptr->U_SURF
  else
    if (inptr@source .eq. "GFDL") then
      u_surf = inptr->U_REF(0,:,:)
      u_surf@long_name = "surf zonal wind at 10m"
      u_surf@units = "m/s"
    else
      nlev = dimsizes(inptr->lev)
      tmp = inptr->U(0,nlev-1,:,:)
      if (typeof(tmp).eq."double") then
        u_surf = dble2flt(tmp)
      else
        u_surf = tmp
      end if
      u_surf@long_name = "Near surf zonal wind"
      u_surf@units = "m/s"
      assignFillValue(u_surf,u_surf)
    end if
    outptr->U_SURF = u_surf
  end if
  return (u_surf)
end

function get_V_SURF (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"V_SURF")) then
    v_surf = outptr->V_SURF
  else
    if (inptr@source .eq. "GFDL") then
      v_surf = inptr->V_REF(0,:,:)
      v_surf@long_name = "surf merid wind at 10m"
      v_surf@units = "m/s"
    else
      nlev = dimsizes(inptr->lev)
      tmp = inptr->V(0,nlev-1,:,:)
      if (typeof(tmp).eq."double") then
        v_surf = dble2flt(tmp)
      else
        v_surf = tmp
      end if
      v_surf@long_name = "Near surf merid wind"
      v_surf@units = "m/s"
      assignFillValue(v_surf,v_surf)
    end if
    outptr->V_SURF = v_surf
  end if
  return (v_surf)
end

function get_VT_850 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VT_850")) then
    vt_850 = outptr->VT_850
  else
    if (isfilevar(inptr,"VT")) then   ; in ccm3.6
      vt = inptr->VT(0,:,:,:)        ; (lev,lat,lon)
      ps = inptr->PS(0,:,:)           ; Pa 
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = vinth2p(vt,hyam,hybm,850.,ps,2,1000.,1,False) 
      if (typeof(tmp).eq."double") then
        vt_850 = dble2flt(tmp(0,:,:))
      else
        vt_850 = tmp(0,:,:)
      end if
      vt_850 = (/vt_850/100./)
      vt_850@derive_op = "VT_850 divided by 100."
      vt_850@long_name = "850mb merid heat trnspt"
      vt_850@units = "K m/s x 100"
      assignFillValue(vt_850,vt_850)
      outptr->VT_850 = vt_850
    else
;     print("VT_850: no VT variable present")
      vt_850 = -999.0
    end if
  end if
  return (vt_850)
end


function get_WIND_MAG_LEV1 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"WIND_MAG_LEV1")) then
    wind_mag_lev1 = outptr->WIND_MAG_LEV1
  else
    nlev = dimsizes(inptr->lev)
    u_lev1 = inptr->U(0,nlev-1,:,:)
    v_lev1 = inptr->V(0,nlev-1,:,:)
    tmp = u_lev1
    tmp = (/sqrt(u_lev1^2 + v_lev1^2)/)
    if (typeof(tmp).eq."double") then
      wind_mag_lev1 = dble2flt(tmp)
    else
      wind_mag_lev1 = tmp
    end if
    wind_mag_lev1@units = "m/s"
    wind_mag_lev1@long_name = "First model level wind"
    wind_mag_lev1@derive_op = "sqrt(u_lev1^2+v_lev1^2)"
    assignFillValue(wind_mag_lev1,wind_mag_lev1)
  end if
  outptr->WIND_MAG_LEV1 = wind_mag_lev1 
  return (wind_mag_lev1)
end


function get_Z3_300 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"Z3_300")) then
    z3_300 = outptr->Z3_300
  else
    if (inptr@source .eq. "GFDL") then
      z3_300 = inptr->Z3(0,7,:,:)        ; 300 mb
      z3_300 = (/z3_300/100./)
      z3_300@long_name = "300mb geop height"
      z3_300@units = "hectometers"
      outptr->Z3_300 = z3_300 
    else
      if (isfilevar(inptr,"Z3")) then
        z3 = inptr->Z3(0,:,:,:)   ; (lev,lat,lon) m
        ps = inptr->PS(0,:,:)       ; Pa 
        hyam = inptr->hyam
        hybm = inptr->hybm
        tmp = vinth2p(z3,hyam,hybm,300.,ps,2,1000.,1,False) 
        if (typeof(tmp).eq."double") then
          z3_300 = dble2flt(tmp(0,:,:))
        else
          z3_300 = tmp(0,:,:)
        end if
        z3_300 = (/z3_300/100./)        ; convert to hectometers
        z3_300@long_name = "300mb geop height"
        z3_300@units = "hectometers"
        assignFillValue(z3_300,z3_300)
        outptr->Z3_300 = z3_300
      else
        z3_300 = -999.0
      end if
    end if
  end if
  return (z3_300)
end

function get_Z3_500 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"Z3_500")) then
    z3_500 = outptr->Z3_500
  else
    if (inptr@source .eq. "GFDL") then
      z3_500 = inptr->Z3(0,5,:,:)        ; 500 mb
      z3_500 = (/z3_500/100./)
      z3_500@long_name = "500mb geop height"
      z3_500@units = "hectometers"
      outptr->Z3_500 = z3_500 
    else
      if (isfilevar(inptr,"Z3")) then
        z3 = inptr->Z3(0,:,:,:)   ; (lev,lat,lon) m
        ps = inptr->PS(0,:,:)     ; Pa 
        hyam = inptr->hyam
        hybm = inptr->hybm
        tmp = vinth2p(z3,hyam,hybm,500.,ps,2,1000.,1,False) 
        if (typeof(tmp).eq."double") then
          z3_500 = dble2flt(tmp(0,:,:))
        else
          z3_500 = tmp(0,:,:)
        end if
        z3_500 = (/z3_500/100./)        ; convert to hectometers
        z3_500@long_name = "500mb geop height"
        z3_500@units = "hectometers"
        assignFillValue(z3_500,z3_500)
        outptr->Z3_500 = z3_500
      else
        z3_500 = -999.0
      end if
    end if
  end if
  return (z3_500)
end

; Code additions by BRH for COSP
load "$DIAG_CODE/functions_matrix.ncl"

function get_CLDLOW_ISCCPCOSP (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDLOW_ISCCPCOSP")) then
    var = outptr->CLDLOW_ISCCPCOSP
  else
    if (isfilevar(inptr,"CLDLOW_ISCCPCOSP")) then
      tmp = inptr->CLDLOW_ISCCPCOSP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Low-topped cloud"
      var@units = "percent"
      outptr->CLDLOW_ISCCPCOSP = var
    else
      clisccp = get_CLISCCP(inptr,outptr)
      if (all(clisccp .eq. -999.0)) then
        var = -999.0
        delete(clisccp)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clisccp(lat|:,lon|:,{isccp_prs|:680.0},{isccp_tau|3.0:})))
        var@long_name = "Low-topped cloud"
        var@units = "percent"
        delete(clisccp)
        outptr->CLDLOW_ISCCPCOSP = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDMED_ISCCPCOSP (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDMED_ISCCPCOSP")) then
    var = outptr->CLDMED_ISCCPCOSP
  else
    if (isfilevar(inptr,"CLDMED_ISCCPCOSP")) then
      tmp = inptr->CLDMED_ISCCPCOSP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mid-topped cloud"
      var@units = "percent"
      outptr->CLDMED_ISCCPCOSP = var
    else
      clisccp = get_CLISCCP(inptr,outptr) 
      if (all(clisccp .eq. -999.0)) then
        var = -999.0
        delete(clisccp)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clisccp(lat|:,lon|:,{isccp_prs|680:440},{isccp_tau|0.3:})))
        var@long_name = "Mid-topped cloud"
        var@units = "percent"
        delete(clisccp)
        outptr->CLDMED_ISCCPCOSP = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDHGH_ISCCPCOSP (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDHGH_ISCCPCOSP")) then
    var = outptr->CLDHGH_ISCCPCOSP
  else
    if (isfilevar(inptr,"CLDHGH_ISCCPCOSP")) then
      tmp = inptr->CLDHGH_ISCCPCOSP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "High-topped cloud"
      var@units = "percent"
      outptr->CLDHGH_ISCCPCOSP = var
    else
      clisccp = get_CLISCCP(inptr,outptr)
      if (all(clisccp .eq. -999.0)) then
        var = -999.0
        delete(clisccp)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clisccp(lat|:,lon|:,{isccp_prs|440:},{isccp_tau|0.3:})))
        var@long_name = "High-topped cloud"
        var@units = "percent"
        delete(clisccp)
        outptr->CLDHGH_ISCCPCOSP = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDTOT_ISCCPCOSP (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTOT_ISCCPCOSP")) then
    var = outptr->CLDTOT_ISCCPCOSP
  else
    if (isfilevar(inptr,"CLDTOT_ISCCPCOSP")) then
      tmp = inptr->CLDTOT_ISCCPCOSP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Total cloud"
      var@units = "percent"
      outptr->CLDTOT_ISCCPCOSP = var
    else
      clisccp = get_CLISCCP(inptr,outptr)
      if (all(clisccp .eq. -999.0)) then
        var = -999.0
        delete(clisccp)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clisccp(lat|:,lon|:,isccp_prs|:,{isccp_tau|0.3:})))
        var@long_name = "Total cloud"
        var@units = "percent"
        delete(clisccp)
        outptr->CLDTOT_ISCCPCOSP = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDTHN_ISCCPCOSP (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTHN_ISCCPCOSP")) then
    var = outptr->CLDTHN_ISCCPCOSP
  else
    if (isfilevar(inptr,"CLDTHN_ISCCPCOSP")) then
      tmp = inptr->CLDTHN_ISCCPCOSP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Optically thin cloud"
      var@units = "percent"
      outptr->CLDTHN_ISCCPCOSP = var
    else
      clisccp = get_CLISCCP(inptr,outptr)
      if (all(clisccp .eq. -999.0)) then
        var = -999.0
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clisccp(lat|:,lon|:,isccp_prs|:,{isccp_tau|0.0:3.6})))
        var@long_name = "Optically thin cloud"
        var@units = "percent"
        delete(clisccp)
        outptr->CLDTHN_ISCCPCOSP = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDINT_ISCCPCOSP (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDINT_ISCCPCOSP")) then
    var = outptr->CLDINT_ISCCPCOSP
  else
    if (isfilevar(inptr,"CLDINT_ISCCPCOSP")) then
      tmp = inptr->CLDINT_ISCCPCOSP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Optically intermediate cloud"
      var@units = "percent"
      outptr->CLDINT_ISCCPCOSP = var
    else
      clisccp = get_CLISCCP(inptr,outptr)
      if (all(clisccp .eq. -999.0)) then
        var = -999.0
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clisccp(lat|:,lon|:,isccp_prs|:,{isccp_tau|3.6:23.0})))
        var@long_name = "Optically intermediate cloud"
        var@units = "percent"
        delete(clisccp)
        outptr->CLDINT_ISCCPCOSP = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDTHICK_ISCCPCOSP (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTHICK_ISCCPCOSP")) then
    var = outptr->CLDTHICK_ISCCPCOSP
  else
    if (isfilevar(inptr,"CLDTHICK_ISCCPCOSP")) then
      tmp = inptr->CLDTHICK_ISCCPCOSP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Optically thick cloud"
      var@units = "percent"
      outptr->CLDTHICK_ISCCPCOSP = var
    else
      clisccp = get_CLISCCP(inptr,outptr)
      if (all(clisccp .eq. -999.0)) then
        var = -999.0
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clisccp(lat|:,lon|:,isccp_prs|:,{isccp_tau|23:})))
        var@long_name = "Optically thick cloud"
        var@units = "percent"
        delete(clisccp)
        outptr->CLDTHICK_ISCCPCOSP = var
      end if
    end if
  end if
  return (var)
end 

function get_MEANCLDALB_ISCCPCOSP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"MEANCLDALB_ISCCPCOSP")) then
    var = outptr->MEANCLDALB_ISCCPCOSP
  else
    if (isfilevar(inptr,"MEANCLDALB_ISCCP")) then     ; in ccm2.0.2
      tmp = inptr->MEANCLDALB_ISCCP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mean cloud albedo"
      var@units = "none"
      if (isfilevar(inptr,"CLDTOT_ISCCP")) then
        tmp = inptr->CLDTOT_ISCCP(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->MEANCLDALB_ISCCPCOSP = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_MEANPTOP_ISCCPCOSP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"MEANPTOP_ISCCPCOSP")) then
    var = outptr->MEANPTOP_ISCCPCOSP
  else
    if (isfilevar(inptr,"MEANPTOP_ISCCP")) then     ; in ccm2.0.2
      tmp = inptr->MEANPTOP_ISCCP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var = var/100.0
      var@long_name = "Mean cloud top pressure"
      var@units = "mb"
      if (isfilevar(inptr,"CLDTOT_ISCCP")) then
        tmp = inptr->CLDTOT_ISCCP(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->MEANPTOP_ISCCPCOSP = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_MEANTTOP_ISCCPCOSP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"MEANTTOP_ISCCPCOSP")) then
    var = outptr->MEANTTOP_ISCCPCOSP
  else
    if (isfilevar(inptr,"MEANTTOP_ISCCP")) then     ; in ccm2.0.2
      tmp = inptr->MEANTTOP_ISCCP(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mean cloud top temperature"
      var@units = "K"
      if (isfilevar(inptr,"CLDTOT_ISCCP")) then
        tmp = inptr->CLDTOT_ISCCP(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->MEANTTOP_ISCCPCOSP = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

; MISR diagnostics
function get_CLDLOW_MISR (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDLOW_MISR")) then
    var = outptr->CLDLOW_MISR
  else
    if (isfilevar(inptr,"CLDLOW_MISR")) then
      tmp = inptr->CLDLOW_MISR(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Low-topped cloud"
      var@units = "percent"
      outptr->CLDLOW_MISR = var
    else
      clmisr = get_CLMISR(inptr,outptr)
      if (all(clmisr .eq. -999.0)) then
        var = -999.0
        delete(clmisr)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmisr(lat|:,lon|:,{misr_cth|0:3},{misr_tau|0.3:})))
        var@long_name = "Low-topped cloud"
        var@units = "percent"
        delete(clmisr)
        outptr->CLDLOW_MISR = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDMED_MISR (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDMED_MISR")) then
    var = outptr->CLDMED_MISR
  else
    if (isfilevar(inptr,"CLDMED_MISR")) then
      tmp = inptr->CLDMED_MISR(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mid-topped cloud"
      var@units = "percent"
      outptr->CLDMED_MISR = var
    else
      clmisr = get_CLMISR(inptr,outptr)
      if (all(clmisr .eq. -999.0)) then
        var = -999.0
        delete(clmisr)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmisr(lat|:,lon|:,{misr_cth|3:7},{misr_tau|0.3:})))
        var@long_name = "Mid-topped cloud"
        var@units = "percent"
        delete(clmisr)
        outptr->CLDMED_MISR = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDHGH_MISR (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDHGH_MISR")) then
    var = outptr->CLDHGH_MISR
  else
    if (isfilevar(inptr,"CLDHGH_MISR")) then
      tmp = inptr->CLDHGH_MISR(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "High-topped cloud"
      var@units = "percent"
      outptr->CLDHGH_MISR = var
    else
      clmisr = get_CLMISR(inptr,outptr)
      if (all(clmisr .eq. -999.0)) then
        var = -999.0
        delete(clmisr)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmisr(lat|:,lon|:,{misr_cth|7:},{misr_tau|0.3:})))
        var@long_name = "High-topped cloud"
        var@units = "percent"
        delete(clmisr)
        outptr->CLDHGH_MISR = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDTOT_MISR (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTOT_MISR")) then
    var = outptr->CLDTOT_MISR
  else
    if (isfilevar(inptr,"CLDTOT_MISR")) then
      tmp = inptr->CLDTOT_MISR(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Total cloud"
      var@units = "percent"
      outptr->CLDTOT_MISR = var
    else
      clmisr = get_CLMISR(inptr,outptr)
      if (all(clmisr .eq. -999.0)) then
        var = -999.0
        delete(clmisr)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmisr(lat|:,lon|:,misr_cth|:,{misr_tau|0.3:})))
        var@long_name = "Total cloud"
        var@units = "percent"
        delete(clmisr)
        outptr->CLDTOT_MISR = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDTHN_MISR (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTHN_MISR")) then
    var = outptr->CLDTHN_MISR
  else
    if (isfilevar(inptr,"CLDTHN_MISR")) then
      tmp = inptr->CLDTHN_MISR(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Optically thin cloud"
      var@units = "percent"
      outptr->CLDTHN_MISR = var
    else
      clmisr = get_CLMISR(inptr,outptr)
      if (all(clmisr .eq. -999.0)) then
        var = -999.0
        delete(clmisr)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmisr(lat|:,lon|:,misr_cth|:,{misr_tau|0.0:3.6})))
        var@long_name = "Optically thin cloud"
        var@units = "percent"
        delete(clmisr)
        outptr->CLDTHN_MISR = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDINT_MISR (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDINT_MISR")) then
    var = outptr->CLDINT_MISR
  else
    if (isfilevar(inptr,"CLDINT_MISR")) then
      tmp = inptr->CLDINT_MISR(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Optically intermediate cloud"
      var@units = "percent"
      outptr->CLDINT_MISR = var
    else
      clmisr = get_CLMISR(inptr,outptr)
      if (all(clmisr .eq. -999.0)) then
        var = -999.0
        delete(clmisr)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmisr(lat|:,lon|:,misr_cth|:,{misr_tau|3.6:23.0})))
        var@long_name = "Optically intermediate cloud"
        var@units = "percent"
        delete(clmisr)
        outptr->CLDINT_MISR = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDTHICK_MISR (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTHICK_MISR")) then
    var = outptr->CLDTHICK_MISR
  else
    if (isfilevar(inptr,"CLDTHICK_MISR")) then
      tmp = inptr->CLDTHICK_MISR(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Optically thick cloud"
      var@units = "percent"
      outptr->CLDTHICK_MISR = var
    else
      clmisr = get_CLMISR(inptr,outptr)
      if (all(clmisr .eq. -999.0)) then
        var = -999.0
        delete(clmisr)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmisr(lat|:,lon|:,misr_cth|:,{misr_tau|23:})))
        var@long_name = "Optically thick cloud"
        var@units = "percent"
        delete(clmisr)
        outptr->CLDTHICK_MISR = var
      end if
    end if
  end if
  return (var)
end 

; MODIS diagnostics
function get_CLDLOW_MODIS (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDLOW_MODIS")) then
    var = outptr->CLDLOW_MODIS
  else
    if (isfilevar(inptr,"CLLMODIS")) then
      tmp = inptr->CLLMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Low-topped cloud"
      var@units = "percent"
      outptr->CLDLOW_MODIS = var
    else
      clmodis = get_CLMODIS(inptr,outptr)
      if (all(clmodis .eq. -999.0)) then
        var = -999.0
        delete(clmodis)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmodis(lat|:,lon|:,{modis_prs|:680},{modis_tau|0.3:})))
        var@long_name = "Low-topped cloud"
        var@units = "percent"
        delete(clmodis)
        outptr->CLDLOW_MODIS = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDMED_MODIS (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDMED_MODIS")) then
    var = outptr->CLDMED_MODIS
  else
    if (isfilevar(inptr,"CLMMODIS")) then
      tmp = inptr->CLMMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mid-topped cloud"
      var@units = "percent"
      outptr->CLDMED_MODIS = var
    else
      clmodis = get_CLMODIS(inptr,outptr) 
      if (all(clmodis .eq. -999.0)) then
        var = -999.0
        delete(clmodis)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmodis(lat|:,lon|:,{modis_prs|680:440},{modis_tau|0.3:})))
        var@long_name = "Mid-topped cloud"
        var@units = "percent"
        delete(clmodis)
        outptr->CLDMED_MODIS = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDHGH_MODIS (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDHGH_MODIS")) then
    var = outptr->CLDHGH_MODIS
  else
    if (isfilevar(inptr,"CLHMODIS")) then
      tmp = inptr->CLHMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "High-topped cloud"
      var@units = "percent"
      outptr->CLDHGH_MODIS = var
    else
      clmodis = get_CLMODIS(inptr,outptr)
      if (all(clmodis .eq. -999.0)) then
        var = -999.0
        delete(clmodis)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmodis(lat|:,lon|:,{modis_prs|440:},{modis_tau|0.3:})))
        var@long_name = "High-topped cloud"
        var@units = "percent"
        delete(clmodis)
        outptr->CLDHGH_MODIS = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDTOT_MODIS (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTOT_MODIS")) then
    var = outptr->CLDTOT_MODIS
  else
    if (isfilevar(inptr,"CLTMODIS")) then
      tmp = inptr->CLTMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Total cloud"
      var@units = "percent"
      outptr->CLDTOT_MODIS = var
    else
      clmodis = get_CLMODIS(inptr,outptr)
      if (all(clmodis .eq. -999.0)) then
        var = -999.0
        delete(clmodis)
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmodis(lat|:,lon|:,modis_prs|:,{modis_tau|0.3:})))
        var@long_name = "Total cloud"
        var@units = "percent"
        delete(clmodis)
        outptr->CLDTOT_MODIS = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDTHN_MODIS (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTHN_MODIS")) then
    var = outptr->CLDTHN_MODIS
  else
    if (isfilevar(inptr,"CLDTHN_MODIS")) then
      tmp = inptr->CLDTHN_MODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Optically thin cloud"
      var@units = "percent"
      outptr->CLDTHN_MODIS = var
    else
      clmodis = get_CLMODIS(inptr,outptr)
      if (all(clmodis .eq. -999.0)) then
        var = -999.0
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmodis(lat|:,lon|:,modis_prs|:,{modis_tau|0.0:3.6})))
        var@long_name = "Optically thin cloud"
        var@units = "percent"
        delete(clmodis)
        outptr->CLDTHN_MODIS = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDINT_MODIS (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDINT_MODIS")) then
    var = outptr->CLDINT_MODIS
  else
    if (isfilevar(inptr,"CLDINT_MODIS")) then
      tmp = inptr->CLDINT_MODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Optically intermediate cloud"
      var@units = "percent"
      outptr->CLDINT_MODIS = var
    else
      clmodis = get_CLMODIS(inptr,outptr)
      if (all(clmodis .eq. -999.0)) then
        var = -999.0
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmodis(lat|:,lon|:,modis_prs|:,{modis_tau|3.6:23.0})))
        var@long_name = "Optically intermediate cloud"
        var@units = "percent"
        delete(clmodis)
        outptr->CLDINT_MODIS = var
      end if
    end if
  end if
  return (var)
end 

function get_CLDTHICK_MODIS (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTHICK_MODIS")) then
    var = outptr->CLDTHICK_MODIS
  else
    if (isfilevar(inptr,"CLDTHICK_MODIS")) then
      tmp = inptr->CLDTHICK_MODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Optically thick cloud"
      var@units = "percent"
      outptr->CLDTHICK_MODIS = var
    else
      clmodis = get_CLMODIS(inptr,outptr)
      if (all(clmodis .eq. -999.0)) then
        var = -999.0
      else
        var = dim_sum_Wrap(dim_sum_Wrap(clmodis(lat|:,lon|:,modis_prs|:,{modis_tau|23:})))
        var@long_name = "Optically thick cloud"
        var@units = "percent"
        delete(clmodis)
        outptr->CLDTHICK_MODIS = var
      end if
    end if
  end if
  return (var)
end 

function get_CLTMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CLTMODIS")) then
    var = outptr->CLTMODIS
  else
    if (isfilevar(inptr,"CLTMODIS")) then
      tmp = inptr->CLTMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Total cloud"
      var@units = "percent"
      outptr->CLTMODIS = var
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_CLLMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CLLMODIS")) then
    var = outptr->CLLMODIS
  else
    if (isfilevar(inptr,"CLLMODIS")) then
      tmp = inptr->CLLMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Low cloud"
      var@units = "percent"
      outptr->CLLMODIS = var
    else
      cloud = -999.0
    end if
  end if
  return (var)
end

function get_CLMMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CLMMODIS")) then
    var = outptr->CLMMODIS
  else
    if (isfilevar(inptr,"CLMMODIS")) then
      tmp = inptr->CLMMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Middle cloud"
      var@units = "percent"
      outptr->CLMMODIS = var
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_CLHMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CLHMODIS")) then
    var = outptr->CLHMODIS
  else
    if (isfilevar(inptr,"CLHMODIS")) then
      tmp = inptr->CLHMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "High cloud"
      var@units = "percent"
      outptr->CLHMODIS = var
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_CLIMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CLIMODIS")) then
    var = outptr->CLIMODIS
  else
    if (isfilevar(inptr,"CLIMODIS")) then
      tmp = inptr->CLIMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Ice cloud"
      var@units = "percent"
      outptr->CLIMODIS = var
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_CLWMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CLWMODIS")) then
    var = outptr->CLWMODIS
  else
    if (isfilevar(inptr,"CLWMODIS")) then
      tmp = inptr->CLWMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Liquid cloud"
      var@units = "percent"
      outptr->CLWMODIS = var
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_IWPMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"IWPMODIS")) then
    var = outptr->IWPMODIS
  else
    if (isfilevar(inptr,"IWPMODIS")) then
      tmp = inptr->IWPMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mean ice water path"
      var = var*1000.0
      var@units = "g/m2"
      if (isfilevar(inptr,"CLIMODIS")) then
        tmp = inptr->CLIMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->IWPMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_LWPMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"LWPMODIS")) then
    var = outptr->LWPMODIS
  else
    if (isfilevar(inptr,"LWPMODIS")) then
      tmp = inptr->LWPMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mean liquid water path"
      var = var*1000.0
      var@units = "g/m2"
      if (isfilevar(inptr,"CLWMODIS")) then
        tmp = inptr->CLWMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->LWPMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_PCTMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"PCTMODIS")) then
    var = outptr->PCTMODIS
  else
    if (isfilevar(inptr,"PCTMODIS")) then
      tmp = inptr->PCTMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mean cloud top pressure"
      var = var/100.0
      var@units = "hPa"
      if (isfilevar(inptr,"CLTMODIS")) then
        tmp = inptr->CLTMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->PCTMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_REFFCLIMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"REFFCLIMODIS")) then
    var = outptr->REFFCLIMODIS
  else
    if (isfilevar(inptr,"REFFCLIMODIS")) then
      tmp = inptr->REFFCLIMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Ice cloud particle size"
      var = var*1.0e6
      var@units = "microns"
      if (isfilevar(inptr,"CLIMODIS")) then
        tmp = inptr->CLIMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->REFFCLIMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_REFFCLWMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"REFFCLWMODIS")) then
    var = outptr->REFFCLWMODIS
  else
    if (isfilevar(inptr,"REFFCLWMODIS")) then
      tmp = inptr->REFFCLWMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Liquid cloud particle size"
      var = var*1.0e6
      var@units = "microns"
      if (isfilevar(inptr,"CLWMODIS")) then
        tmp = inptr->CLWMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->REFFCLWMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_TAUILOGMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUILOGMODIS")) then
    var = outptr->TAUILOGMODIS
  else
    if (isfilevar(inptr,"TAUILOGMODIS")) then
      tmp = inptr->TAUILOGMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Log-weighted mean tau (ice)"
      var@units = "none"
      if (isfilevar(inptr,"CLIMODIS")) then
        tmp = inptr->CLIMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          var = 10^var
          outptr->TAUILOGMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_TAUWLOGMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUWLOGMODIS")) then
    var = outptr->TAUWLOGMODIS
  else
    if (isfilevar(inptr,"TAUWLOGMODIS")) then
      tmp = inptr->TAUWLOGMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Log-weighted mean tau (liquid)"
      var@units = "none"
      if (isfilevar(inptr,"CLWMODIS")) then
        tmp = inptr->CLWMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          var = 10^var
          outptr->TAUWLOGMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_TAUTLOGMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUTLOGMODIS")) then
    var = outptr->TAUTLOGMODIS
  else
    if (isfilevar(inptr,"TAUTLOGMODIS")) then
      tmp = inptr->TAUTLOGMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Log-weighted mean tau (all)"
      var@units = "none"
      if (isfilevar(inptr,"CLTMODIS")) then
        tmp = inptr->CLTMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          var = 10^var
          outptr->TAUTLOGMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_TAUIMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUIMODIS")) then
    var = outptr->TAUIMODIS
  else
    if (isfilevar(inptr,"TAUIMODIS")) then
      tmp = inptr->TAUIMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mean optical depth (ice clouds)"
      var@units = "none"
      if (isfilevar(inptr,"CLIMODIS")) then
        tmp = inptr->CLIMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->TAUIMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_TAUWMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUWMODIS")) then
    var = outptr->TAUWMODIS
  else
    if (isfilevar(inptr,"TAUWMODIS")) then
      tmp = inptr->TAUWMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mean optical depth (liquid clouds)"
      var@units = "none"
      if (isfilevar(inptr,"CLWMODIS")) then
        tmp = inptr->CLWMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->TAUWMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

function get_TAUTMODIS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TAUTMODIS")) then
    var = outptr->TAUTMODIS
  else
    if (isfilevar(inptr,"TAUTMODIS")) then
      tmp = inptr->TAUTMODIS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mean optical depth (all clouds)"
      var@units = "none"
      if (isfilevar(inptr,"CLTMODIS")) then
        tmp = inptr->CLTMODIS(0,:,:)
        if (typeof(tmp).eq."double") then 
          cld = dble2flt(tmp)
        else
          cld = tmp
        end if
        delete(tmp)
        cld = where(cld.le.0.0,cld@_FillValue,cld)
        cld = where(cld.gt.100.0,cld@_FillValue,cld)
        if (all(ismissing(cld))) then
          var = -999.0
        else
          var = where(cld.gt.0.0,var/cld,var@_FillValue)
          outptr->TAUTMODIS = var
        end if
      else
        var = -999.0
      end if
    else
      var = -999.0
    end if
  end if
  return (var)
end

; CALIPSO diagnostics
function get_CLDTOT_CAL (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTOT_CAL")) then
    var = outptr->CLDTOT_CAL
  else
    if (isfilevar(inptr,"CLDTOT_CAL")) then
      tmp = inptr->CLDTOT_CAL(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Total cloud"
      var@units = "percent"
      outptr->CLDTOT_CAL = var
     else
      var = -999.0
    end if
  end if
  return (var)
end 

function get_CLDLOW_CAL (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDLOW_CAL")) then
    var = outptr->CLDLOW_CAL
  else
    if (isfilevar(inptr,"CLDLOW_CAL")) then
      tmp = inptr->CLDLOW_CAL(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Low-topped cloud"
      var@units = "percent"
      outptr->CLDLOW_CAL = var
    else
      var = -999.0
    end if
  end if
  return (var)
end 

function get_CLDMED_CAL (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDMED_CAL")) then
    var = outptr->CLDMED_CAL
  else
    if (isfilevar(inptr,"CLDMED_CAL")) then
      tmp = inptr->CLDMED_CAL(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "Mid-topped cloud"
      var@units = "percent"
      outptr->CLDMED_CAL = var
    else
      var = -999.0
    end if
  end if
  return (var)
end 

function get_CLDHGH_CAL (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDHGH_CAL")) then
    var = outptr->CLDHGH_CAL
  else
    if (isfilevar(inptr,"CLDHGH_CAL")) then
      tmp = inptr->CLDHGH_CAL(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var@long_name = "High-topped cloud"
      var@units = "percent"
      outptr->CLDHGH_CAL = var
    else
      var = -999.0
    end if
  end if
  return (var)
end 

; CLOUDSAT diagnostics
function get_CLDTOT_CS2 (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTOT_CS2")) then
    var = outptr->CLDTOT_CS2
  else
    if (isfilevar(inptr,"CLDTOT_CS2")) then
      tmp = inptr->CLDTOT_CS2(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var = var*100.0
      var@long_name = "Total cloud"
      var@units = "percent"
      outptr->CLDTOT_CS2 = var
    else
      var = -999.0
    end if
  end if
  return (var)
end 

function get_CLDTOT_CS (inptr:file,outptr:file) 
begin
  if (isfilevar(outptr,"CLDTOT_CS")) then
    var = outptr->CLDTOT_CS
  else
    if (isfilevar(inptr,"CLDTOT_CS")) then
      tmp = inptr->CLDTOT_CS(0,:,:)
      if (typeof(tmp).eq."double") then 
        var = dble2flt(tmp)
      else
        var = tmp
      end if
      delete(tmp)
      var = var*100.0
      var@long_name = "Total cloud"
      var@units = "percent"
      outptr->CLDTOT_CS = var
    else
      var = -999.0
    end if
  end if
  return (var)
end 
