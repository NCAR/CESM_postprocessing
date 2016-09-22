; NCL script
; functions_eddyflux.ncl
;load "$DIAG_HOME/code/contributed.ncl"
;---------------------------------------------------------------------
; constants
p0 = 100000.       ; Pa
g = 9.80616        ; m/s^2
Cp = 1.00464e3     ; J/(K*kg)
coeff = Cp/g    
;-------------------------------------------------------------------
; STATIONARY EDDY FLUXES
;------------------------------------------------------------------
undef ("stationary")
function stationary (a[*][*][*]:numeric,b[*][*][*]:numeric)
; input: a(lev,lat,lon) model variable
;        b(lev,lat,lon) model variable       
begin
  nlon = dimsizes(a&lon)
; zonal average of input variables
  za = dim_avg_Wrap(a)    ; (lev,lat)
  zb = dim_avg_Wrap(b)    ; (lev,lat)
  astar = a       
  bstar = b
  do n = 0, nlon-1
    astar(:,:,n) = (/a(:,:,n) - za/)
    bstar(:,:,n) = (/b(:,:,n) - zb/)
  end do
  astar_bstar = a
  astar_bstar = (/astar*bstar/)   ; (lev,lat,lon)
  return (astar_bstar)
end 
;--------------------------------------------------------------------------

; VBSTAR_QBSTAR_2D (meridional stationary eddy moisture flux)
function get_VBSTAR_QBSTAR_2D (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VBSTAR_QBSTAR_2D")) then
    vbstar_qbstar = outptr->VBSTAR_QBSTAR_2D
  else
    v = inptr->V(0,:,:,:)
    q = inptr->Q(0,:,:,:)    ; kg/kg
    vqstar = v
    vqstar = stationary(v,q) 
    hyai = inptr->hyai
    hybi = inptr->hybi
;jt    ps = inptr->PS(0,:,:)
    tmp = inptr->PS(0,:,:)
    if (typeof(tmp).eq."double") then
      ps = dble2flt(tmp)
    else
      ps = tmp
    end if 
    dph = dpres_hybrid_ccm (ps,p0,hyai,hybi)   ; Pa (lev,lat,lon)
    vqstardph = vqstar
    vqstardph = (/vqstar*dph/)                        ; kg/kg m/s Pa  
    tmp = dim_sum_n_Wrap(vqstardph, 0)                ; (lat,lon)
  ;;tmp = dim_sum_Wrap(vqstardph(lat|:,lon|:,lev|:))  ; (lat,lon)
    if (typeof(tmp).eq."double") then
      vbstar_qbstar = dble2flt(tmp)
    else
      vbstar_qbstar = tmp
    end if 
    vbstar_qbstar = (/vbstar_qbstar/ps/)        ; divide by surface pressure   
    vbstar_qbstar = (/vbstar_qbstar*1000./)     ; convert to g/kg m/s
    vbstar_qbstar@long_name = "Merid Stationary Eddy Moisture"
    vbstar_qbstar@units = "m/s g/kg"
    assignFillValue(vbstar_qbstar,vbstar_qbstar)
    outptr->VBSTAR_QBSTAR_2D = vbstar_qbstar
  end if
  return (vbstar_qbstar)
end

; VBSTAR_TBSTAR_2D (meridional stationary eddy heat flux)
function get_VBSTAR_TBSTAR_2D (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VBSTAR_TBSTAR_2D")) then
    vbstar_tbstar = outptr->VBSTAR_TBSTAR_2D
  else
    t = inptr->T(0,:,:,:)
    v = inptr->V(0,:,:,:)
    vtstar = v            
    vtstar = stationary(v,t)  ; K*m/s (lev,lat,lon)
    hyai = inptr->hyai
    hybi = inptr->hybi
;jt    ps = inptr->PS(0,:,:)                    ; Pa
    tmp = inptr->PS(0,:,:)                    ; Pa
    if (typeof(tmp).eq."double") then
      ps = dble2flt(tmp)
    else
      ps = tmp
    end if 
    dph = dpres_hybrid_ccm(ps,p0,hyai,hybi)  ; Pa (lev,lat,lon)
    vtstardph = vtstar
    vtstardph = (/vtstar*dph*coeff/)        ;  W/m 
    tmp = dim_sum_n_Wrap(vtstardph, 0)      ; (lat,lon)
  ;;tmp = dim_sum_Wrap(vtstardph(lat|:,lon|:,lev|:))  ; (lat,lon)
    if (typeof(tmp).eq."double") then
      vbstar_tbstar = dble2flt(tmp)
    else
      vbstar_tbstar = tmp
    end if 
    vbstar_tbstar = (/vbstar_tbstar/ps/)      ; divide by surface pressure
    vbstar_tbstar = (/vbstar_tbstar/1.e15/)   ; convert to PW
    vbstar_tbstar@long_name = "Merid Stationary Eddy Heat Flux"
    vbstar_tbstar@units = "PW"
    assignFillValue(vbstar_tbstar,vbstar_tbstar)
    outptr->VBSTAR_TBSTAR_2D = vbstar_tbstar
  end if
  return (vbstar_tbstar)
end

; VBSTAR_UBSTAR_2D (meridional stationary eddy momentum flux)
function get_VBSTAR_UBSTAR_2D (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VBSTAR_UBSTAR_2D")) then
    vbstar_ubstar = outptr->VBSTAR_UBSTAR_2D
  else
    u = inptr->U(0,:,:,:)
    v = inptr->V(0,:,:,:)
    vustar = u            
    vustar = stationary(v,u)  ; m^2/s^2
    hyai = inptr->hyai
    hybi = inptr->hybi
;jt    ps = inptr->PS(0,:,:)                    ; Pa
    tmp = inptr->PS(0,:,:)                    ; Pa
    if (typeof(tmp).eq."double") then
      ps = dble2flt(tmp)
    else
      ps = tmp
    end if 
    dph = dpres_hybrid_ccm(ps,p0,hyai,hybi)  ; Pa (lev,lat,lon)
    vustardph = vustar
    vustardph = (/vustar*dph/)        
    tmp = dim_sum_n_Wrap(vustardph, 0)       ; (lat,lon)
  ;;tmp = dim_sum_Wrap(vustardph(lat|:,lon|:,lev|:))  ; (lat,lon)
    if (typeof(tmp).eq."double") then
      vbstar_ubstar = dble2flt(tmp)
    else
      vbstar_ubstar = tmp
    end if 
    vbstar_ubstar = (/vbstar_ubstar/ps/)      ; divide by surface pressure
    vbstar_ubstar@long_name = "Merid Stationary Eddy Momentum"
    vbstar_ubstar@units ="m~S~2~N~/s~S~2~N~"
    assignFillValue(vbstar_ubstar,vbstar_ubstar)
    outptr->VBSTAR_UBSTAR_2D = vbstar_ubstar
  end if
  return (vbstar_ubstar)
end

;-------------------------------------------------------------------
; TRANSIENT EDDY FLUXES
;------------------------------------------------------------------
; EKE (transient eddy kinetic energy)
function get_EKE_BAR_2D (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"EKE_BAR_2D")) then
    eke = outptr->EKE_BAR_2D
  else
    u = inptr->U(0,:,:,:)
    v = inptr->V(0,:,:,:)
    if (isfilevar(inptr,"VVPUU")) then      ; in ccm3.6
      vvpuu = inptr->VVPUU(0,:,:,:)      ; v^2 + u^2
      kebar = vvpuu
      kebar = (/(vvpuu-(v^2+u^2))/2./) 
    else                                   ; in ccm3.10
      if (isfilevar(inptr,"VV").and.isfilevar(inptr,"UU")) then
        uu = inptr->UU(0,:,:,:)
        vv = inptr->VV(0,:,:,:)
        kebar = vv
        kebar = (/(vv+uu-(v^2+u^2))/2./)
      else
;       print("EKE: missing VVPUU or UU and VV variables")
        eke = -999.
        return (eke)
      end if
    end if
;jt    ps = inptr->PS(0,:,:)       ; Pa
    tmp = inptr->PS(0,:,:)                    ; Pa
    if (typeof(tmp).eq."double") then
      ps = dble2flt(tmp)
    else
      ps = tmp
    end if 
    hyai = inptr->hyai
    hybi = inptr->hybi
    dph = dpres_hybrid_ccm(ps,p0,hyai,hybi)  ; Pa (lev,lat,lon)
    kebardph = kebar 
    kebardph = (/kebar*dph/)        
    tmp = dim_sum_n_Wrap(kebardph, 0)  ; (lat,lon)
  ;;tmp = dim_sum_Wrap(kebardph(lat|:,lon|:,lev|:))  ; (lat,lon)
    if (typeof(tmp).eq."double") then
      eke = dble2flt(tmp)
    else
      eke = tmp
    end if
    eke = (/eke/ps/)
    eke@units = "m~S~2~N~/s~S~2~N~"
    eke@long_name = "Transient eddy KE"
    eke@derive_op = "(VV+UU-(V^2+U^2))/2"
    assignFillValue(eke,eke)
    outptr->EKE_BAR_2D = eke
  end if
  return (eke)
end

; VPQP_BAR_2D (meridional transient eddy moisture flux)
function get_VPQP_BAR_2D (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VPQP_BAR_2D")) then
    vpqp_bar = outptr->VPQP_BAR_2D
  else
    if (isfilevar(inptr,"VQ")) then
      hyai = inptr->hyai
      hybi = inptr->hybi
;jt    ps = inptr->PS(0,:,:)       ; Pa
      tmp = inptr->PS(0,:,:)                    ; Pa
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      vq = inptr->VQ(0,:,:,:)   ; m/s kg/kg
      v = inptr->V(0,:,:,:)     ; m/s
      q = inptr->Q(0,:,:,:)     ; kg/kg
      vqbar = vq
      vqbar = (/vq-v*q/)        ; (lev,lat,lon)
      dph = dpres_hybrid_ccm(ps,p0,hyai,hybi)  ; Pa (lev,lat,lon)
      vqbardph = vqbar
      vqbardph = (/vqbar*dph/)        
      tmp = dim_sum_n_Wrap(vqbardph, 0)  ; (lat,lon)
    ;;tmp = dim_sum_Wrap(vqbardph(lat|:,lon|:,lev|:))  ; (lat,lon)
      if (typeof(tmp).eq."double") then
        vpqp_bar = dble2flt(tmp)
      else
        vpqp_bar = tmp
      end if 
      vpqp_bar = (/vpqp_bar/ps/)          ; divide by surface pressure
      vpqp_bar = (/vpqp_bar*1000./)     ; units m/s g/kg
      vpqp_bar@long_name = "Merid Transient Eddy Moisture"
      vpqp_bar@units = "m/s g/kg"
      vpqp_bar@derive_op = "(VQ-V*Q)*1000"
      assignFillValue(vpqp_bar,vpqp_bar)
      outptr->VPQP_BAR_2D = vpqp_bar 
    else
;     print ("VPQP_BAR: missing VQ variable")
      vpqp_bar = -999.
      return (vpqp_bar)
    end if
  end if
  return (vpqp_bar)
end

; VPTP_BAR_2D (meridional transient eddy heat flux)
function get_VPTP_BAR_2D (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VPTP_BAR_2D")) then
    vttp_bar = outptr->VPTP_BAR_2D
  else
    if (isfilevar(inptr,"VT")) then
      hyai = inptr->hyai
      hybi = inptr->hybi
;jt    ps = inptr->PS(0,:,:)       ; Pa
      tmp = inptr->PS(0,:,:)                    ; Pa
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      vt = inptr->VT(0,:,:,:)      ; m/s K
      v = inptr->V(0,:,:,:)
      t = inptr->T(0,:,:,:)
      vtbar = vt
      vtbar = (/vt-v*t/)
      dph = dpres_hybrid_ccm(ps,p0,hyai,hybi)  ; Pa (lev,lat,lon)
      vtbardph = vtbar
      vtbardph = (/vtbar*dph*coeff/)        ;  W/m 
      tmp = dim_sum_n_Wrap(vtbardph, 0)     ; (lat,lon)
    ;;tmp = dim_sum_Wrap(vtbardph(lat|:,lon|:,lev|:))  ; (lat,lon)
      if (typeof(tmp).eq."double") then
        vptp_bar = dble2flt(tmp)
      else
        vptp_bar = tmp
      end if 
      vptp_bar = (/vptp_bar/ps/)      ; divide by surface pressure
      vptp_bar = (/vptp_bar/1.e15/)   ; convert to PW
      vptp_bar@long_name = "Merid Transient Eddy Heat Flux"
      vptp_bar@units ="PW"
      vptp_bar@derive_op = "VT-V*T"
      assignFillValue(vptp_bar,vptp_bar)
      outptr->VPTP_BAR_2D = vptp_bar 
    else
;     print("VPTP_BAR: missing VT variable")
      vptp_bar = -999.
      return (vptp_bar)
    end if
  end if
  return (vptp_bar)
end

; VPUP_BAR_2D (meridional transient eddy momentum flux)
function get_VPUP_BAR_2D (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VPUP_BAR_2D")) then
    vpup_bar = outptr->VPUP_BAR_2D
  else
    if (isfilevar(inptr,"VU")) then
      u = inptr->U(0,:,:,:)
      v = inptr->V(0,:,:,:)
      vu = inptr->VU(0,:,:,:)   ; m^2/s^2
      vubar = vu
      vubar = (/vu-u*v/)
      hyai = inptr->hyai
      hybi = inptr->hybi
;jt    ps = inptr->PS(0,:,:)       ; Pa
      tmp = inptr->PS(0,:,:)                    ; Pa
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      dph = dpres_hybrid_ccm(ps,p0,hyai,hybi)  ; Pa (lev,lat,lon)
      vubardph = vubar
      vubardph = (/vubar*dph/)        
      tmp = dim_sum_n_Wrap(vubardph, 0)  ; (lat,lon)
    ;;tmp = dim_sum_Wrap(vubardph(lat|:,lon|:,lev|:))  ; (lat,lon)
      if (typeof(tmp).eq."double") then
        vpup_bar = dble2flt(tmp)
      else
        vpup_bar = tmp
      end if 
      vpup_bar = (/vpup_bar/ps/)   ; divide by surface pressure
      vpup_bar@long_name = "Merid Transient Eddy Momentum"
      vpup_bar@units ="m~S~2~N~/s~S~2~N~"
      vpup_bar@derive_op = "VU-U*V"
      assignFillValue(vpup_bar,vpup_bar)
      outptr->VPUP_BAR_2D = vpup_bar 
    else
;     print ("VPUP_BAR: missing VU variable")
      vpup_bar = -999.
      return (vpup_bar)
    end if
  end if
  return (vpup_bar)
end
