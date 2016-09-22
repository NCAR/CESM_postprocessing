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
; constant pressure levels (67 for WACCM, otherwise 25)
use_waccm_levs = getenv("USE_WACCM_LEVS")
if (use_waccm_levs .eq. "False") then
  nplvlM = 25
  plvlM = (/ 30., 50., 70.,100.,150.,200.,250.,300.,350.,400.,450.,500., 550., \
            600.,650.,700.,750.,800.,850.,875.,900.,925.,950.,975.,1000. /)
else
;if (use_waccm_levs .eq. "True") then
  nplvlM = 67
  ; Last 25 are same in both cases.
  plvlM = (/ 4.5005e-6,   7.4201e-6,   1.22337e-5, 2.017e-5,   3.32545e-5, \
             5.48275e-5,  9.0398e-5,   1.4904e-4,  2.4572e-4,  4.05125e-4, \
             6.6794e-4,   1.101265e-3, 1.81565e-3, 2.9935e-3,  4.963e-3,   \
             8.150651e-3, 1.3477e-2,   2.2319e-2,  3.67965e-2, 6.0665e-2,  \
             9.91565e-2,  0.15739,     0.23885,    0.3452,     0.475135,   \
             0.631805,    0.829155,    1.08274,    1.40685,    1.81885,    \
             2.3398,      2.99505,     3.8147,     4.83445,    6.09635,    \
             7.64935,     9.5501,      11.864,     14.6655,    18.038,     \
             22.0755,     26.8825, \
           30., 50., 70.,100.,150.,200.,250.,300.,350.,400.,450.,500., 550., \
          600.,650.,700.,750.,800.,850.,875.,900.,925.,950.,975.,1000. /)
;else
;  nplvlM = 34
;  plvlM = (/ 4.83445,  6.09635, 7.64935,   9.5501,  11.864, 14.6655,  18.038,     \
;            22.0755,     26.8825, \
;          30., 50., 70.,100.,150.,200.,250.,300.,350.,400.,450.,500., 550., \
;         600.,650.,700.,750.,800.,850.,875.,900.,925.,950.,975.,1000. /)
;end if
end if
plvlM@units = "mb"
; TOM to bottom is the order of the model data
; bottom to TOM is the order of the OBS data
; flip levels before returning for plots and comparison with OBS data
;-----------------------------------------------------------------------

;threholds for cloud liqud and ice
lthrsh=3.e-7
ithrsh=1.e-8

function vertical_CLOUD (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CLOUD")) then 
    cloud = outptr->CLOUD
  else
    cld = inptr->CLOUD(0,:,:,:)
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,cld,plvlM(::-1),2,0)
      cloud = dim_avg_n_Wrap(tmp, 1)
      cloud@units = "fraction"
      cloud@long_name = "Cloud fraction"
      outptr->CLOUD = cloud(::-1,:)          
      return (cloud)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt     ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      tmp = vinth2p(cld,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        cloud3 = dble2flt(tmp)
      else
        cloud3 = tmp                  ; 3D array (lev,lat,lon)
      end if
      cloud = dim_avg_Wrap(cloud3)     ; zonal ave -->(lev,lat) 
      cloud@units = "fraction"
      cloud@long_name = "Cloud fraction"
      assignFillValue(cloud,cloud)
      outptr->CLOUD = cloud          
    end if
  end if
  return (cloud(::-1,:))   ; bottom to TOM for plots
end

function vertical_CWAT (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CWAT")) then
    cwat = outptr->CWAT
  else
    if (isfilevar(inptr,"CWAT")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt     ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      cw = inptr->CWAT(0,:,:,:)   ; kg/kg
      tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        cwat3 = dble2flt(tmp)
      else
        cwat3 = tmp
      end if
      cwat = dim_avg_Wrap(cwat3)
      cwat = (/cwat*1000./)   ; convert to g/kg
      cwat@derive_op = "CWAT*1000."
      cwat@long_name = "Cloud water"
      cwat@units = "g/kg"
      outptr->CWAT = cwat
    else
      if (isfilevar(inptr,"CLDICE").and.isfilevar(inptr,"CLDLIQ")) then
        cldice = inptr->CLDICE(0,:,:,:)   ; kg/kg
        cldliq = inptr->CLDLIQ(0,:,:,:)   ; kg/kg
        cw = cldice              
        cw = (/cldice+cldliq/)
        if (inptr@source .eq. "GFDL") then
          tmp = int2p_n_Wrap(plvlG,cw,plvlM(::-1),2,0)
          cwat = dim_avg_n_Wrap(tmp, 1)
          cwat = (/cwat*1000./)   ; convert to g/kg
          cwat@long_name = "Cloud ice+liquid"
          cwat@units = "g/kg"
          outptr->CWAT = cwat(::-1,:)
          return (cwat)
        else
          hyam = inptr->hyam
          hybm = inptr->hybm
;jt       ps = inptr->PS(0,:,:)
          tmp = inptr->PS(0,:,:)
          if (typeof(tmp).eq."double") then
            ps = dble2flt(tmp)
          else
            ps = tmp
          end if 
          delete(tmp)
          tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
          if (typeof(tmp).eq."double") then
            cwat3 = dble2flt(tmp)
          else
            cwat3 = tmp
          end if
          cwat = dim_avg_Wrap(cwat3)
          cwat = (/cwat*1000./)   ; convert to g/kg
          cwat@derive_op = "(CLDICE+CLDLIQ)*1000."
          cwat@long_name = "Cloud ice+liquid"
          cwat@units = "g/kg"
          outptr->CWAT = cwat
        end if
      else
        cwat = -999.
        return (cwat)
      end if
    end if
  end if
  return (cwat(::-1,:))
end

function vertical_CLDLIQ (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CLDLIQ")) then
    cldliq = outptr->CLDLIQ
  else
    if (isfilevar(inptr,"CLDLIQ")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt   ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      cw = inptr->CLDLIQ(0,:,:,:)   ; kg/kg
      tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        cldliq3 = dble2flt(tmp)
      else
        cldliq3 = tmp
      end if
      cldliq = dim_avg_Wrap(cldliq3)
      cldliq = (/cldliq*1000./)   ; convert to g/kg
      cldliq@derive_op = "CLDLIQ*1000."
      cldliq@long_name = "Grid-box average liquid"
      cldliq@units = "g/kg"
      outptr->CLDLIQ = cldliq 
    else
      cldliq = -999.
      return (cldliq)
    end if
  end if
  return (cldliq(::-1,:))
end

function vertical_CLDICE (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CLDICE")) then
    cldice = outptr->CLDICE
  else
    if (isfilevar(inptr,"CLDICE")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt   ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      cw = inptr->CLDICE(0,:,:,:)   ; kg/kg
      tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        cldice3 = dble2flt(tmp)
      else
        cldice3 = tmp
      end if
      cldice = dim_avg_Wrap(cldice3)
      cldice = (/cldice*1000./)   ; convert to g/kg
      cldice@derive_op = "CLDICE*1000."
      cldice@long_name = "Grid-box average ice"
      cldice@units = "g/kg"
      outptr->CLDICE = cldice 
    else
      cldice = -999.
      return (cldice)
    end if
  end if
  return (cldice(::-1,:))
end


function vertical_ICWMR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ICWMR")) then
    icwmr = outptr->ICWMR
  else
    if (isfilevar(inptr,"ICWMR")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt   ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      cw = inptr->ICWMR(0,:,:,:)   ; kg/kg
      tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        icwmr3 = dble2flt(tmp)
      else
        icwmr3 = tmp
      end if
      icwmr = dim_avg_Wrap(icwmr3)
      icwmr = (/icwmr*1000./)   ; convert to g/kg
      icwmr@derive_op = "ICWMR*1000."
      icwmr@long_name = "In-Cloud liquid"
      icwmr@units = "g/kg"
      outptr->ICWMR = icwmr 
    else
      icwmr = -999.
      return (icwmr)
    end if
  end if
  return (icwmr(::-1,:))

end
function vertical_ICIMR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ICIMR")) then
    icimr = outptr->ICIMR
  else
    if (isfilevar(inptr,"ICIMR")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt   ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      cw = inptr->ICIMR(0,:,:,:)   ; kg/kg
      tmp = vinth2p(cw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        icimr3 = dble2flt(tmp)
      else
        icimr3 = tmp
      end if
      icimr = dim_avg_Wrap(icimr3)
      icimr = (/icimr*1000./)   ; convert to g/kg
      icimr@derive_op = "ICIMR*1000."
      icimr@long_name = "In-Cloud ice"
      icimr@units = "g/kg"
      outptr->ICIMR = icimr 
    else
      icimr = -999.
      return (icimr)
    end if
  end if
  return (icimr(::-1,:))

end

function vertical_GCLDLWP_ICE (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"GCLDLWP_ICE")) then
    gcldlwp_ice = outptr->GCLDLWP_ICE
    gcldlwp_ice = (/1000.*gcldlwp_ice/) ; convert to g/kg
  else
    if (isfilevar(inptr,"FICE").and.isfilevar(inptr,"GCLDLWP")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt   ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      ice = inptr->FICE(0,:,:,:)
      cld = inptr->GCLDLWP(0,:,:,:) 
      gcld = ice
      gcld = (/cld*ice*1000./) ; convert to g/kg
      tmp = vinth2p(gcld,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        gcldlwp3 = dble2flt(tmp)
      else
        gcldlwp3 = tmp
      end if
      gcldlwp_ice = dim_avg_Wrap(gcldlwp3)
      gcldlwp_ice@long_name = "Grd-box cloud LWP (ice only)"
      gcldlwp_ice@units = "g/m~S~2~N~"
      assignFillValue(gcldlwp_ice,gcldlwp_ice)
      outptr->GCLDLWP_ICE = gcldlwp_ice 
    else
;     print ("GCLDLWP_ICE: missing FICE or GCLDLWP variables")
      gcldlwp_ice = -999.
      return (gcldlwp_ice)
    end if
  end if
  return (gcldlwp_ice(::-1,:))
end

function vertical_GCLDLWP_LIQUID (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"GCLDLWP_LIQUID")) then
    gcldlwp_lqd = outptr->GCLDLWP_LIQUID
    gcldlwp_lqd = (/1000.*gcldlwp_lqd/) ; convert to g/kg
  else
    if (isfilevar(inptr,"FICE").and.isfilevar(inptr,"GCLDLWP")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt   ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      ice = inptr->FICE(0,:,:,:)
      cld = inptr->GCLDLWP(0,:,:,:) 
      gcld = ice 
      gcld = (/1000.*cld*(1.-ice)/)
      tmp = vinth2p(gcld,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        gcldlwp3 = dble2flt(tmp)
      else
        gcldlwp3 = tmp
      end if
      gcldlwp_lqd = dim_avg_Wrap(gcldlwp3)
      gcldlwp_lqd@long_name = "Grd-box cloud LWP (lqd only)"
      gcldlwp_lqd@units = "g/m~S~2~N~"
      assignFillValue(gcldlwp_lqd,gcldlwp_lqd)
      outptr->GCLDLWP_LIQUID = gcldlwp_lqd 
    else
;     print ("GCLDLWP_LIQUID: missing FICE or GCLDLWP variables")
      gcldlwp_lqd = -999.
      return (gcldlwp_lqd)
    end if
  end if
  return (gcldlwp_lqd(::-1,:))
end

function vertical_ICLDIWP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ICLDIWP")) then 
    icldiwp = outptr->ICLDIWP
    icldiwp = (/icldiwp*1000./) ;kg/m3->g/m3
  else
    if (isfilevar(inptr,"ICLDIWP")) then 
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt   ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      ice = inptr->ICLDIWP(0,:,:,:)
      ice = (/ice*1000./)
      tmp = vinth2p(ice,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        icldiwp3 = dble2flt(tmp)
      else
        icldiwp3 = tmp
      end if
      icldiwp = dim_avg_Wrap(icldiwp3)
      icldiwp@long_name = "In-cloud ice WP"
      icldiwp@units = "g/m~S~2~N~"
      assignFillValue(icldiwp,icldiwp)
      outptr->ICLDIWP = icldiwp
    else
      icldiwp = -999.
    end if
  end if
  return (icldiwp(::-1,:))
end

function vertical_ICLDTWP (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ICLDTWP")) then 
    icldtwp = outptr->ICLDTWP
    icldtwp = (/icldtwp*1000./) ;kg/m3->g/m3
  else
    if (isfilevar(inptr,"ICLDIWP") .and. isfilevar(inptr,"ICLDTWP")) then 
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt   ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
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
      icldtwp = dim_avg_Wrap(icldtwp3)
      icldtwp@long_name = "In-cloud liquid WP"
      icldtwp@units = "g/m~S~2~N~"
      assignFillValue(icldtwp,icldtwp)
      outptr->ICLDTWP = icldtwp
    else
      if (isfilevar(inptr,"ICLDTWP")) then    ; ice+liquid
        hyam = inptr->hyam
        hybm = inptr->hybm
;jt     ps = inptr->PS(0,:,:)
        tmp = inptr->PS(0,:,:)
        if (typeof(tmp).eq."double") then
          ps = dble2flt(tmp)
        else
          ps = tmp
        end if 
        delete(tmp)
        ic = inptr->ICLDTWP(0,:,:,:)
        tmp = vinth2p(ic,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
        if (typeof(tmp).eq."double") then
          icldtwp3 = dble2flt(tmp)
        else
          icldtwp3 = tmp
        end if
        icldtwp = dim_avg_Wrap(icldtwp3)
        icldtwp@long_name = "In-cloud ice+liquid WP"
        icldtwp@units = "g/m~S~2~N~"
        assignFillValue(icldtwp,icldtwp)
        outptr->ICLDTWP = icldtwp
        icldtwp =  icldtwp(::-1,:,:)
      else
        icldtwp = -999.
      end if
    end if
  end if

  return (icldtwp)
end


function vertical_SIWC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"SIWC_ZM")) then 
    siwc_zm = outptr->SIWC_ZM
  else
    if (isfilevar(inptr,"IWC") .and. isfilevar(inptr,"AQSNOW")) then 
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      iwc = inptr->IWC(0,:,:,:)   
      aqsnow = inptr->AQSNOW(0,:,:,:)
      tmp = vinth2p(iwc,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      
      tmp2 = vinth2p(aqsnow,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      temp = inptr->T(0,:,:,:)
      T = vinth2p(temp,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      Rd = 287.05
      p = new( (/dimsizes(T)/), typeof(T))
            
      do ilev = 0, dimsizes(plvlM)-1
       p(ilev,:,:) = plvlM(ilev)
      end do
      tmp2 = tmp2*(p/(Rd*T))
      delete(p) 
      tmp = (tmp + tmp2)*1.e6

      if (typeof(tmp).eq."double") then
        siwc = dble2flt(tmp)
      else
        siwc = tmp
      end if

      siwc_zm = dim_avg_Wrap(siwc)

      siwc_zm@long_name = "GSIWP"
      siwc_zm@units = "mg/m:S:3:N:"
      assignFillValue(siwc_zm,siwc_zm)

      siwc_zm!0 = "lev"
      siwc_zm!1 = "lat"
      siwc_zm&lev = plvlM
      siwc_zm&lat = lat


      outptr->SIWC_ZM = (/siwc_zm/)
     else
        siwc_zm = -999.
    end if
  end if
  return (siwc_zm)
end


function vertical_WSUB (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"WSUB_ZM")) then 
    wsub_zm = outptr->WSUB_ZM
  else
    if (isfilevar(inptr,"WSUB")) then 
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      tmpin = inptr->WSUB(0,:,:,:)   

      tmp = vinth2p(tmpin,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      if (typeof(tmp).eq."double") then
        wsub = dble2flt(tmp)
      else
        wsub = tmp
      end if

      wsub_zm = dim_avg_Wrap(wsub)
      wsub_zm@long_name = "Sub_Grid Vertical Velocity"
      wsub_zm@units = "m/s"
      assignFillValue(wsub_zm,wsub_zm)

      wsub_zm!0 = "lev"
      wsub_zm!1 = "lat"
      wsub_zm&lev = plvlM
      wsub_zm&lat = lat

      outptr->WSUB_ZM = (/wsub_zm/)
     else
        wsub_zm = -999.
    end if
  end if

  return (wsub_zm)
end

function vertical_CCN3 (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"CCN3_ZM")) then 
    ccn3_zm = outptr->CCN3_ZM
  else
    if (isfilevar(inptr,"CCN3")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      tmpin = inptr->CCN3(0,:,:,:)   

      tmp = vinth2p(tmpin,hyam,hybm,plvlM,ps,interp,p0,1,extrap) 

      if (typeof(tmp).eq."double") then
        ccn3 = dble2flt(tmp)
      else
        ccn3 = tmp
      end if

      ccn3_zm = dim_avg_Wrap(ccn3)    
      ccn3_zm@long_name = "CCN Concentration"
      ccn3_zm@units = "#/cm:S:3:N:"
      assignFillValue(ccn3_zm,ccn3_zm)

      ccn3_zm!0 = "lev"
      ccn3_zm!1 = "lat"
      ccn3_zm&lev = plvlM
      ccn3_zm&lat = lat

      outptr->CCN3_ZM = (/ccn3_zm/)
     else
        ccn3_zm = -999.
    end if
  end if
  return (ccn3_zm)
end

function vertical_AWNC (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"AWNC_ZM")) then 
    awnc_zm = outptr->AWNC_ZM
  else
    if (isfilevar(inptr,"AWNC")) then
      msv = -999.
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)

      tmpin = inptr->AWNC(0,:,:,:)
      tmpin=tmpin*1.e-6  

      frq = inptr->FREQL(0,:,:,:)
      frq = where(frq.ne.0,frq,msv)

      tmpin = tmpin/frq
      tmp = vinth2p(tmpin,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      tmp@_FillValue = msv
      tmp@missing_value = msv

      cldliq = inptr->CLDLIQ(0,:,:,:)

      cld = vinth2p(cldliq,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      tmp = where(cld.gt.lthrsh,tmp,msv)

      if (typeof(tmp).eq."double") then
        awnc = dble2flt(tmp)
      else
        awnc = tmp
      end if

      awnc_zm = dim_avg_Wrap(awnc)          
      awnc_zm@long_name = "Avg. Cloud Water # Conc."
      awnc_zm@units = "cm:S:-3:N:"
      assignFillValue(awnc_zm,awnc_zm)

      awnc_zm!0 = "lev"
      awnc_zm!1 = "lat"
      awnc_zm&lev = plvlM
      awnc_zm&lat = lat

      outptr->AWNC_ZM = awnc_zm
     else
        awnc_zm = -999.
    end if
  end if
  return (awnc_zm)
end


function vertical_AWNI (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"AWNI_ZM")) then 
    awni_zm = outptr->AWNI_ZM
  else
    if ((isfilevar(inptr,"AWNI")).and.(isfilevar(inptr,"FREQI"))) then
      msv = -999.
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)

      tmpin = inptr->AWNI(0,:,:,:)
      tmpin=tmpin*1.e-6  

      frq = inptr->FREQI(0,:,:,:)
      frq = where(frq.ne.0,frq,msv)

      tmpin = tmpin/frq
      tmp = vinth2p(tmpin,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      tmp@_FillValue = msv
      tmp@missing_value = msv

      cldice = inptr->CLDICE(0,:,:,:)

      cld = vinth2p(cldice,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      tmp = where(cld.gt.ithrsh,tmp,msv)

      if (typeof(tmp).eq."double") then
        awni = dble2flt(tmp)
      else
        awni = tmp
      end if

      awni_zm = dim_avg_Wrap(awni)
      awni_zm@long_name = "Avg. Cloud Ice # Conc."
      awni_zm@units = "cm:S:-3:N:"
      assignFillValue(awni_zm,awni_zm)

      awni_zm!0 = "lev"
      awni_zm!1 = "lat"
      awni_zm&lev = plvlM
      awni_zm&lat = lat

      outptr->AWNI_ZM = awni_zm
     else
        awni_zm = -999.
    end if
  end if

  return (awni_zm)
end


function vertical_AREL (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"AREL_ZM")) then 
    arel_zm = outptr->AREL_ZM
  else
    if ((isfilevar(inptr,"AREL")).and.(isfilevar(inptr,"FREQL")).and.(isfilevar(inptr,"CLDLIQ"))) then
      msv = -999.
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)

      tmpin = inptr->AREL(0,:,:,:)

      frq = inptr->FREQL(0,:,:,:)
      frq = where(frq.ne.0,frq,msv)

      tmpin = tmpin/frq

      tmp = vinth2p(tmpin,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      cldliq = inptr->CLDLIQ(0,:,:,:)
      cld = vinth2p(cldliq,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      tmp@_FillValue = msv
      tmp@missing_value = msv

      tmp = where(cld.gt.lthrsh,tmp,msv)

      if (typeof(tmp).eq."double") then
        arel = dble2flt(tmp)
      else
        arel = tmp
      end if

      arel_zm = dim_avg_Wrap(arel)

      arel_zm@long_name = "Avg. Droplet Eff. Radius"
      arel_zm@units = "microns"
      assignFillValue(arel_zm,arel_zm)

      arel_zm!0 = "lev"
      arel_zm!1 = "lat"
      arel_zm&lev = plvlM
      arel_zm&lat = lat

      outptr->AREL_ZM = arel_zm
     else
        arel_zm = -999.
    end if
  end if

  return (arel_zm)
end


function vertical_AREI (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"AREI_ZM")) then 
    arei_zm = outptr->AREI_ZM
  else
    if ((isfilevar(inptr,"AREI")).and.(isfilevar(inptr,"FREQI")).and.(isfilevar(inptr,"CLDICE"))) then
      msv = -999.
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)

      tmpin = inptr->AREI(0,:,:,:)
      frq = inptr->FREQI(0,:,:,:)
      frq = where(frq.ne.0,frq,msv)

      tmpin = tmpin/frq
      tmp = vinth2p(tmpin,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      cldice = inptr->CLDICE(0,:,:,:)
      cld = vinth2p(cldice,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      tmp@_FillValue = msv
      tmp@missing_value = msv

      tmp = where(cld.gt.ithrsh,tmp,msv)

      if (typeof(tmp).eq."double") then
        arei = dble2flt(tmp)
      else
        arei = tmp
      end if

      arei_zm = dim_avg_Wrap(arei)
      arei_zm@long_name = "Avg. Ice Eff. Radius"
      arei_zm@units = "microns"
      assignFillValue(arei_zm,arei_zm)

      arei_zm!0 = "lev"
      arei_zm!1 = "lat"
      arei_zm&lev = plvlM
      arei_zm&lat = lat

      outptr->AREI_ZM = arei_zm
     else
        arei_zm = -999.
    end if
  end if

  return (arei_zm)
end

function vertical_AQRAIN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"AQRAIN_ZM")) then 
    aqrain_zm = outptr->AQRAIN_ZM
  else
    if ( (isfilevar(inptr,"AQRAIN")).and.(isfilevar(inptr,"FREQR"))) then
      msv = -999
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)

      tmpin = inptr->AQRAIN(0,:,:,:)*1.e6

      frq = inptr->FREQR(0,:,:,:)

      frq = where(frq.ne.0,frq,msv)
      tmpin2 = tmpin/frq

      tmp = vinth2p(tmpin2,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      if (typeof(tmp).eq."double") then
        aqrain = dble2flt(tmp)
      else
        aqrain = tmp
      end if

      aqrain_zm = dim_avg(aqrain)
      aqrain_zm@long_name = "Avg. Rain Mixing Ratio"
      aqrain_zm@units = "mg/kg"
      assignFillValue(aqrain_zm,aqrain_zm)

      aqrain_zm!0 = "lev"
      aqrain_zm!1 = "lat"
      aqrain_zm&lev = plvlM
      aqrain_zm&lat = lat

      outptr->AQRAIN_ZM = aqrain_zm
     else
        aqrain_zm = -999.
    end if
  end if

  return (aqrain_zm)
end


function vertical_ANRAIN (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ANRAIN_ZM")) then 
    anrain_zm = outptr->ANRAIN_ZM
  else
    if ( (isfilevar(inptr,"ANRAIN")).and.(isfilevar(inptr,"FREQR"))) then
      msv = -999
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)

      tmpin = inptr->ANRAIN(0,:,:,:)
      tmpin@_FillValue = msv
      tmpin@missing_value = tmpin@_FillValue

      tmpin = tmpin*1.e-3

      frq = inptr->FREQR(0,:,:,:)
      frq = where(frq.ne.0,frq,msv)

      tmpin2 = tmpin/frq

      tmp = vinth2p(tmpin2,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      
      tmp@_FillValue = msv
      tmp@missing_value = tmp@_FillValue

      if (typeof(tmp).eq."double") then
        anrain = dble2flt(tmp)
      else
        anrain = tmp
      end if

      anrain_zm = dim_avg(anrain)
      anrain_zm@long_name = "Avg. Rain Number Conc."
      anrain_zm@units = "L:S:-1:N:"
      assignFillValue(anrain_zm,anrain_zm)

      anrain_zm!0 = "lev"
      anrain_zm!1 = "lat"
      anrain_zm&lev = plvlM
      anrain_zm&lat = lat

      outptr->ANRAIN_ZM = anrain_zm
     else
        anrain_zm = -999.
    end if
  end if

  return (anrain_zm)
end

function vertical_AQSNOW (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"AQSNOW_ZM")) then 
    aqsnow_zm = outptr->AQSNOW_ZM
  else
    if ( (isfilevar(inptr,"AQSNOW")).and.(isfilevar(inptr,"FREQS"))) then
      msv = -999
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)

      tmpin = inptr->AQSNOW(0,:,:,:)*1.e6

      frq = inptr->FREQS(0,:,:,:)
      frq = where(frq.ne.0,frq,msv)

      tmpin2 = tmpin
      tmpin2 = (/tmpin/frq/)

      tmp = vinth2p(tmpin2,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      
 
      if (typeof(tmp).eq."double") then
        aqsnow = dble2flt(tmp)
      else
        aqsnow = tmp
      end if

      aqsnow_zm = dim_avg(aqsnow)
      aqsnow_zm@long_name = "Avg. Snow Mixing Ratio"
      aqsnow_zm@units = "mg/kg"
      assignFillValue(aqsnow_zm,aqsnow_zm)
      
      aqsnow_zm!0 = "lev"
      aqsnow_zm!1 = "lat"
      aqsnow_zm&lev = plvlM
      aqsnow_zm&lat = lat

      outptr->AQSNOW_ZM = aqsnow_zm
     else
        aqsnow_zm = -999.
    end if
  end if

  return (aqsnow_zm)
end

function vertical_ANSNOW (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ANSNOW_ZM")) then 
    ansnow_zm = outptr->ANSNOW_ZM
  else
    if ( (isfilevar(inptr,"ANSNOW")).and.(isfilevar(inptr,"FREQS"))) then
      msv = -999
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)

      tmpin = (/inptr->ANSNOW(0,:,:,:)/)
      tmpin = tmpin*1.e-3

      frq = inptr->FREQS(0,:,:,:)
      frq = where(frq.ne.0,frq,msv)

      tmpin2 = tmpin/frq

      tmp = vinth2p(tmpin2,hyam,hybm,plvlM,ps,interp,p0,1,extrap)      

      if (typeof(tmp).eq."double") then
        ansnow = dble2flt(tmp)
      else
        ansnow = tmp
      end if

      ansnow_zm = dim_avg(ansnow)
      ansnow_zm@long_name = "Avg. Snow Number Conc."
      ansnow_zm@units = "L:S:-1:N:"
      assignFillValue(ansnow_zm,ansnow_zm)

      ansnow_zm!0 = "lev"
      ansnow_zm!1 = "lat"
      ansnow_zm&lev = plvlM
      ansnow_zm&lat = lat

      outptr->ANSNOW_ZM = (/ansnow_zm/)
     else
        ansnow_zm = -999.
    end if
  end if

  return (ansnow_zm)
end

function vertical_OMEGA (inptr:file,outptr:file,compare:string)
begin
  if (isfilevar(outptr,"OMEGA")) then 
    omega = outptr->OMEGA      
  else
    om = inptr->OMEGA(0,:,:,:)
    if (inptr@source .eq. "GFDL") then
      if (compare .eq. "OBS")
        tmp = int2p_n_Wrap(plvlG,om,plvlO(::-1),2,0)
      else
        tmp = int2p_n_Wrap(plvlG,om,plvlM(::-1),2,0)
      end if
      omega = dim_avg_n_Wrap(tmp, 1)
      omega = (/omega*864./)     ; 86400/100 to convert to mb/day
      omega@units = "mb/day"
      omega@long_name = "Vertical pressure velocity"
      outptr->OMEGA = omega(::-1,:)           ; Top to botom 
      return (omega)                          ; bottom to TOP  for plots
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
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
      omega = dim_avg_Wrap(omega3)
      omega = (/omega*864./)     ; 86400/100 to convert to mb/day
      omega@derive_op = "OMEGA*864."
      omega@units = "mb/day"
      omega@long_name = "Vertical pressure velocity"
      assignFillValue(omega,omega)
      outptr->OMEGA = omega
    end if
  end if
  return (omega(::-1,:))
end

function vertical_QRL (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"QRL")) then 
    qrl = outptr->QRL
  else
    qlw = inptr->QRL(0,:,:,:)
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,qlw,plvlM(::-1),2,0)
      qrl = dim_avg_n_Wrap(tmp, 1)
      qrl = (/qrl*86400./)     ; convert to K/day
      qrl@units = "K/day"
      qrl@long_name = "LW heating rate"
      outptr->QRL = qrl(::-1,:)          
      return (qrl)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      tmp = vinth2p(qlw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        qrl3 = dble2flt(tmp)
      else
        qrl3 = tmp
      end if
      qrl = dim_avg_Wrap(qrl3)
      qrl = (/qrl*86400./)     ; convert to K/day
      qrl@derive_op = "QRL*86400."
      qrl@units = "K/day"
      qrl@long_name = "LW heating rate"
      assignFillValue(qrl,qrl)
      outptr->QRL = qrl
    end if
  end if
  return (qrl(::-1,:))
end

function vertical_QRS (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"QRS")) then 
    qrs = outptr->QRS
  else
    qsw = inptr->QRS(0,:,:,:)
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,qsw,plvlM(::-1),2,0)
      qrs = dim_avg_n_Wrap(tmp, 1)
      qrs = (/qrs*86400./)     ; convert to K/day
      qrs@units = "K/day"
      qrs@long_name = "SW heating rate"
      outptr->QRS = qrs(::-1,:)          
      return (qrs)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      tmp = vinth2p(qsw,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        qrs3 = dble2flt(tmp)
      else
        qrs3 = tmp
      end if
      qrs = dim_avg_Wrap(qrs3)
      qrs = (/qrs*86400./)     ; convert to K/day
      qrs@derive_op = "QRS*86400."
      qrs@units = "K/day"
      qrs@long_name = "SW heating rate"
      assignFillValue(qrs,qrs)
      outptr->QRS = qrs
    end if
  end if
  return (qrs(::-1,:))
end

function vertical_RELHUM (inptr:file,outptr:file,compare:string)
begin
  if (isfilevar(outptr,"RELHUM")) then
    rhum = outptr->RELHUM
  else
    rh = inptr->RELHUM(0,:,:,:)
    if (inptr@source .eq. "GFDL") then
      if (compare .eq. "OBS")
        tmp = int2p_n_Wrap(plvlG,rh,plvlO(::-1),2,0)
      else
        tmp = int2p_n_Wrap(plvlG,rh,plvlM(::-1),2,0)
      end if
      rhum = dim_avg_n_Wrap(tmp, 1)
      rhum@long_name = "Relative humidity"
      rhum@units = "percent"
      outptr->RELHUM = rhum(::-1,:)
      return (rhum)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
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
      rhum = dim_avg_Wrap(rhum3)
      rhum@long_name = "Relative humidity"
      rhum@units = "percent"
      assignFillValue(rhum,rhum)
      outptr->RELHUM = rhum
    end if
  end if
  return (rhum(::-1,:))
end

function vertical_SHUM (inptr:file,outptr:file,compare:string)
begin
  if (isfilevar(outptr,"SHUM")) then 
    shum = outptr->SHUM
  else
    q = inptr->Q(0,:,:,:)
    if (inptr@source .eq. "GFDL") then
      if (compare .eq. "OBS")
        tmp = int2p_n_Wrap(plvlG,q,plvlO(::-1),2,0)
      else
        tmp = int2p_n_Wrap(plvlG,q,plvlM(::-1),2,0)
      end if
      shum = dim_avg_n_Wrap(tmp, 1)
      shum = (/shum*1000./)             ; convert to g/kg
      shum@units = "g/kg"
      shum@long_name = "Specific humidity"
      outptr->SHUM = shum(::-1,:)            ; Top to botom 
      return (shum)                          ; bottom to TOP  for plots
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
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
    shum = dim_avg_Wrap(shum3)
    shum = (/shum*1000./)             ; convert to g/kg
    shum@derive_op = "SHUM=Q*1000."
    shum@units = "g/kg"
    shum@long_name = "Specific humidity"
    assignFillValue(shum,shum)
    outptr->SHUM = shum         
  end if
  return (shum(::-1,:))  ; bottom to TOM for plots
end

function vertical_T (inptr:file,outptr:file,compare:string)
begin
  if (isfilevar(outptr,"T")) then 
    temp = outptr->T
  else
    t = inptr->T(0,:,:,:)
    if (inptr@source .eq. "GFDL") then
      if (compare .eq. "OBS")
        tmp = int2p_n_Wrap(plvlG,t,plvlO(::-1),2,0)
      else
        tmp = int2p_n_Wrap(plvlG,t,plvlM(::-1),2,0)
      end if
      temp = dim_avg_n_Wrap(tmp, 1)
      temp@long_name = "Temperature"
      temp@units = "K"
      outptr->T = temp(::-1,:) 
      return (temp)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
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
      temp = dim_avg_Wrap(temp3)
      temp@long_name = "Temperature"
      temp@units = "K"
      assignFillValue(temp,temp)
      outptr->T = temp    
   end if
  end if
  return (temp(::-1,:))
end

function vertical_TDH (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TDH")) then 
    tdh = outptr->TDH
  else
    if (isfilevar(inptr,"DTCOND") .and. isfilevar(inptr,"DTV")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
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
      tdh = dim_avg_Wrap(tdh3)
      tdh = (/tdh*86400./)    ; convert to K/day
      tdh@long_name = "Total diabatic heating"
      tdh@units = "K/day" 
      assignFillValue(tdh,tdh)
      outptr->TDH = tdh 
    else
;     print("TDH: missing DTCOND or DTV variables")
      tdh = -999.
      return (tdh)
    end if
  end if
  return (tdh(::-1,:))
end

function vertical_TDM (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"TDM")) then 
    tdm = outptr->TDM
  else
    if (isfilevar(inptr,"VD01")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
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
      tdm = dim_avg_Wrap(tdm3)
      tdm = (/tdm*8.64e7/)    ; convert to g(kg*day) 
      tdm@long_name = "Total diabatic moistening"
      tdm@units = "g/kg day~S~-1~N~"
      tdm@derive_op = "(DC01+VD01)*8.64e7"
      assignFillValue(tdm,tdm)
      outptr->TDM = tdm 
    else
;     print ("TDM: missing VD01 variable")
      tdm = -999.
      return (tdm)
    end if
  end if
  return (tdm(::-1,:))
end

function vertical_U (inptr:file,outptr:file,compare:string)
begin
  if (isfilevar(outptr,"U")) then 
    uwind = outptr->U
  else
    u = inptr->U(0,:,:,:)
    if (inptr@source .eq. "GFDL") then
      if (compare .eq. "OBS")
        tmp = int2p_n_Wrap(plvlG,u,plvlO(::-1),2,0)
      else
        tmp = int2p_n_Wrap(plvlG,u,plvlM(::-1),2,0)
      end if
      uwind = dim_avg_n_Wrap(tmp, 1)
      uwind@long_name = "Zonal Wind"
      uwind@units = "m/s"
      outptr->U = uwind(::-1,:)
      return (uwind)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
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
      uwind = dim_avg_Wrap(uwind3)
      uwind@long_name = "Zonal wind"
      uwind@units = "m/s" 
      assignFillValue(uwind,uwind)
      outptr->U = uwind
    end if
  end if
  return (uwind(::-1,:))
end

function vertical_VQ (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VQ")) then 
    vq = outptr->VQ
  else
    if (isfilevar(inptr,"VQ")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      vqt = inptr->VQ(0,:,:,:)
      tmp = vinth2p(vqt,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        vq3 = dble2flt(tmp)
      else
        vq3 = tmp
      end if
      vq = dim_avg_Wrap(vq3)
      vq = (/vq*1000./)       ; convert to m/s g/kg
      assignFillValue(vq,vq)
      vq@long_name = "Meridional water transport"
      vq@units = "m/s g/kg"
      outptr->VQ = vq
    else
      vq = -999.
      return (vq)
    end if
  end if
  return (vq(::-1,:))
end

function vertical_VT (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VT")) then 
    vt = outptr->VT
  else
    if (isfilevar(inptr,"VT")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      vtt = inptr->VT(0,:,:,:)
      tmp = vinth2p(vtt,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        vt3 = dble2flt(tmp)
      else
        vt3 = tmp
      end if
      vt = dim_avg_Wrap(vt3)
      vt = (/vt/100./)       ; scale for plots 
      assignFillValue(vt,vt)
      vt@long_name = "Meridional heat transport"
      vt@units = "K m/s x 100"
      outptr->VT = vt
    else
      vt = -999.
      return (vt)
    end if
  end if
  return (vt(::-1,:))
end

function vertical_ZMMSF (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"ZMMSF")) then 
    zmmsf = outptr->ZMMSF
  else
;jt    lat = inptr->lat
      tmp = inptr->lat
      if (typeof(tmp).eq."double") then
        lat = dble2flt(tmp)
      else
        lat = tmp
      end if 
      delete(tmp)
    v = inptr->V(0,:,:,:)
;jt    ps = inptr->PS(0,:,:)
    tmp = inptr->PS(0,:,:)
    if (typeof(tmp).eq."double") then
      ps = dble2flt(tmp)
    else
      ps = tmp
    end if 
    delete(tmp)
    presPa = plvlM*100.            ; convert to Pa
    presPa@units = "Pa"
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,v(lat|:,lon|:,lev|::-1),plvlM,2,0)
      zmmsf = zonal_mpsi(tmp(lev|:,lat|:,lon|:),lat,presPa,ps)   
      zmmsf!0 = "lev"
      zmmsf&lev = tmp&lev
      zmmsf!1 = "lat"
      zmmsf&lat = tmp&lat
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
      vp = vinth2p(v,hyam,hybm,plvlM,ps,interp,p0,1,extrap)  
      tmp = vp(:,:,0)                      ; (lev,lat) 
      tmp = zonal_mpsi(vp,lat,presPa,ps)   
      if (typeof(tmp).eq."double") then
        zmmsf = dble2flt(tmp)
      else
        zmmsf = tmp       
      end if
      assignFillValue(zmmsf,zmmsf)
    end if
    zmmsf = (/zmmsf/1.e9/)      ; scaled for plots
    zmmsf@long_name = "Merid stream function"
    zmmsf@units = "kg/s x 10~S~9~N~"
    outptr->ZMMSF = zmmsf
  end if
  return (zmmsf(::-1,:))
end
 
;-------------------------------------------------------------------
; STATIONARY EDDY FLUXES
;------------------------------------------------------------------
undef("stationary")
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

; OBSTAR_TBSTAR (stationary vertcal eddy heat flux)
function vertical_OBSTAR_TBSTAR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"OBSTAR_TBSTAR")) then
    obstar_tbstar = outptr->OBSTAR_TBSTAR
  else
    omega = inptr->OMEGA(0,:,:,:)  ; Pa/s
    t = inptr->T(0,:,:,:)
    otstar = omega
    otstar = stationary(omega,t)
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,otstar,plvlM(::-1),2,0)
      obstar_tbstar = dim_avg_n_Wrap(tmp, 1)
      obstar_tbstar = (/obstar_tbstar*864./)    ; convert to mb/day 
      obstar_tbstar@long_name = "Stat eddy vert heat"
      obstar_tbstar@units = "K mb/day"
      outptr->OBSTAR_TBSTAR = obstar_tbstar(::-1,:)
      return (obstar_tbstar)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      tmp = vinth2p(otstar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        obstar_tbstar3 = dble2flt(tmp)
      else
        obstar_tbstar3 = tmp
      end if 
      obstar_tbstar = dim_avg_Wrap(obstar_tbstar3)
      obstar_tbstar = (/obstar_tbstar*864./)    ; convert to mb/day 
      obstar_tbstar@long_name = "Stat eddy vert heat"
      obstar_tbstar@units = "K mb/day"
      assignFillValue(obstar_tbstar,obstar_tbstar)
      outptr->OBSTAR_TBSTAR = obstar_tbstar
    end if
  end if
  return (obstar_tbstar(::-1,:))
end

; VBSTAR_QBSTAR (meridional stationary eddy moisture flux)
function vertical_VBSTAR_QBSTAR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VBSTAR_QBSTAR")) then
    vbstar_qbstar = outptr->VBSTAR_QBSTAR
  else
    v = inptr->V(0,:,:,:)
    q = inptr->Q(0,:,:,:)    ; kg/kg
    vqstar = v
    vqstar = stationary(v,q) 
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,vqstar,plvlM(::-1),2,0)
      vbstar_qbstar = dim_avg_Wrap(tmp(lev|:,lat|:,lon|:))
      vbstar_qbstar = (/vbstar_qbstar*1000./)     ; convert to g/kg
      vbstar_qbstar@long_name = "Stat eddy moisture"
      vbstar_qbstar@units = "m/s g/kg"
      outptr->VBSTAR_QBSTAR = vbstar_qbstar(::-1,:)
      return (vbstar_qbstar)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      tmp = vinth2p(vqstar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        vbstar_qbstar3 = dble2flt(tmp)
      else
        vbstar_qbstar3 = tmp
      end if 
      vbstar_qbstar = dim_avg_Wrap(vbstar_qbstar3)
      vbstar_qbstar = (/vbstar_qbstar*1000./)     ; convert to g/kg
      vbstar_qbstar@long_name = "Stat eddy moisture"
      vbstar_qbstar@units = "m/s g/kg"
      assignFillValue(vbstar_qbstar,vbstar_qbstar)
      outptr->VBSTAR_QBSTAR = vbstar_qbstar
    end if
  end if
  return (vbstar_qbstar(::-1,:))
end

; VBSTAR_TBSTAR (meridional stationary eddy heat flux)
function vertical_VBSTAR_TBSTAR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VBSTAR_TBSTAR")) then
    vbstar_tbstar = outptr->VBSTAR_TBSTAR
  else
    t = inptr->T(0,:,:,:)
    v = inptr->V(0,:,:,:)
    vtstar = v            
    vtstar = stationary(v,t)
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,vtstar,plvlM(::-1),2,0)
      vbstar_tbstar = dim_avg_n_Wrap(tmp, 1)
      vbstar_tbstar@long_name = "Stationary eddy heat"
      vbstar_tbstar@units = "K m/s"
      outptr->VBSTAR_TBSTAR = vbstar_tbstar(::-1,:)
      return (vbstar_tbstar)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      tmp = vinth2p(vtstar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        vbstar_tbstar3 = dble2flt(tmp)
      else
        vbstar_tbstar3 = tmp
      end if 
      vbstar_tbstar = dim_avg_Wrap(vbstar_tbstar3)
      vbstar_tbstar@long_name = "Stationary eddy heat"
      vbstar_tbstar@units = "K m/s"
      assignFillValue(vbstar_tbstar,vbstar_tbstar)
      outptr->VBSTAR_TBSTAR = vbstar_tbstar
    end if
  end if
  return (vbstar_tbstar(::-1,:))
end

; VBSTAR_UBSTAR (meridional stationary eddy momentum flux)
function vertical_VBSTAR_UBSTAR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VBSTAR_UBSTAR")) then
    vbstar_ubstar = outptr->VBSTAR_UBSTAR
  else
    u = inptr->U(0,:,:,:)
    v = inptr->V(0,:,:,:)
    vustar = u            
    vustar = stationary(v,u)
    if (inptr@source .eq. "GFDL") then
      tmp = int2p_n_Wrap(plvlG,vustar,plvlM(::-1),2,0)
      vbstar_ubstar = dim_avg_Wrap(tmp(lev|:,lat|:,lon|:))
      vbstar_ubstar@long_name = "Stationary eddy momentum"
      vbstar_ubstar@units ="m~S~2~N~/s~S~2~N~"
      outptr->VBSTAR_UBSTAR = vbstar_ubstar(::-1,:)
      return (vbstar_ubstar)
    else
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      tmp = vinth2p(vustar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        vbstar_ubstar3 = dble2flt(tmp)
      else
        vbstar_ubstar3 = tmp
      end if 
      vbstar_ubstar = dim_avg_Wrap(vbstar_ubstar3)
      vbstar_ubstar@long_name = "Stationary eddy momentum"
      vbstar_ubstar@units ="m~S~2~N~/s~S~2~N~"
      assignFillValue(vbstar_ubstar,vbstar_ubstar)
      outptr->VBSTAR_UBSTAR = vbstar_ubstar
    end if
  end if
  return (vbstar_ubstar(::-1,:))
end

;-------------------------------------------------------------------
; TRANSIENT EDDY FLUXES
;------------------------------------------------------------------
; EKE (transient eddy kinetic energy)
function vertical_EKE (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"EKE")) then
    eke = outptr->EKE
  else
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
      eke = dim_avg_n_Wrap(tmp, 1)
      eke@units = "m~S~2~N~/s~S~2~N~"
      eke@long_name = "Transient eddy KE"
      outptr->EKE = eke(::-1,:)
      return (eke)
    else
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      hyam = inptr->hyam
      hybm = inptr->hybm
      tmp = vinth2p(ke,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        eke3 = dble2flt(tmp)
      else
        eke3 = tmp
      end if
      eke = dim_avg_Wrap(eke3)
      eke@units = "m~S~2~N~/s~S~2~N~"
      eke@long_name = "Transient eddy KE"
      eke@derive_op = "(VV+UU-(V^2+U^2))/2"
      assignFillValue(eke,eke)
      outptr->EKE = eke
    end if
  end if
  return (eke(::-1,:))
end

; OPTP_BAR (transient eddy vertical heat flux)
function vertical_OPTP_BAR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"OPTP_BAR")) then
    optp_bar = outptr->OPTP_BAR
  else
    if (isfilevar(inptr,"OMEGAT")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
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
      optp_bar = dim_avg_Wrap(optp_bar3)
      optp_bar = (/optp_bar*864./)       ; convert to K mb/day 
      optp_bar@long_name = "Transient eddy vert heat"
      optp_bar@units = "K mb/day"
      optp_bar@derive_op = "(OMEGAT-OMEGA*T)*86400/100"
      assignFillValue(optp_bar,optp_bar)
      outptr->OPTP_BAR = optp_bar 
    else
;     print("OPTP_BAR: missing OMEGAT variable")
      optp_bar = -999.
      return (optp_bar)
    end if
  end if
  return (optp_bar(::-1,:))
end

; VPQP_BAR (meridional transient eddy moisture flux)
function vertical_VPQP_BAR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VPQP_BAR")) then
    vpqp_bar = outptr->VPQP_BAR
  else
    if (isfilevar(inptr,"VQ")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      vq = inptr->VQ(0,:,:,:)   ; m/s kg/kg
      v = inptr->V(0,:,:,:)     ; m/s
      q = inptr->Q(0,:,:,:)     ; kg/kg
      vqbar = vq
      vqbar = (/vq-v*q/)
      tmp = vinth2p(vqbar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        vpqp_bar3 = dble2flt(tmp)
      else
        vpqp_bar3 = tmp
      end if 
      vpqp_bar = dim_avg_Wrap(vpqp_bar3)
      vpqp_bar = (/vpqp_bar*1000./)       ; units m/s g/kg
      vpqp_bar@long_name = "Transient eddy moisture"
      vpqp_bar@units = "m/s g/kg"
      vpqp_bar@derive_op = "(VQ-V*Q)*1000"
      assignFillValue(vpqp_bar,vpqp_bar)
      outptr->VPQP_BAR = vpqp_bar 
    else
;     print ("VPQP_BAR: missing VQ variable")
      vpqp_bar = -999.
      return (vpqp_bar)
    end if
  end if
  return (vpqp_bar(::-1,:))
end

; VPTP_BAR (meridional transient eddy heat flux)
function vertical_VPTP_BAR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VPTP_BAR")) then
    vptp_bar = outptr->VPTP_BAR
  else
    if (isfilevar(inptr,"VT")) then
      hyam = inptr->hyam
      hybm = inptr->hybm
;jt    ps = inptr->PS(0,:,:)
      tmp = inptr->PS(0,:,:)
      if (typeof(tmp).eq."double") then
        ps = dble2flt(tmp)
      else
        ps = tmp
      end if 
      delete(tmp)
      vt = inptr->VT(0,:,:,:)      ; m/s K
      v = inptr->V(0,:,:,:)
      t = inptr->T(0,:,:,:)
      vtbar = vt
      vtbar = (/vt-v*t/)
      tmp = vinth2p(vtbar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        vptp_bar3 = dble2flt(tmp)
      else
        vptp_bar3 = tmp
      end if 
      vptp_bar = dim_avg_Wrap(vptp_bar3)
      vptp_bar@long_name = "Transient eddy heat"
      vptp_bar@units ="K m/s"
      vptp_bar@derive_op = "VT-V*T"
      assignFillValue(vptp_bar,vptp_bar)
      outptr->VPTP_BAR = vptp_bar 
    else
;     print("VPTP_BAR: missing VT variable")
      vptp_bar = -999.
      return (vptp_bar)
    end if
  end if
  return (vptp_bar(::-1,:))
end

; VPUP_BAR (meridional transient eddy momentum flux)
function vertical_VPUP_BAR (inptr:file,outptr:file)
begin
  if (isfilevar(outptr,"VPUP_BAR")) then
    vpup_bar = outptr->VPUP_BAR
  else
    if (isfilevar(inptr,"VU")) then
      u = inptr->U(0,:,:,:)
      v = inptr->V(0,:,:,:)
      vu = inptr->VU(0,:,:,:)   ; m^2/s^2
      vubar = vu
      vubar = (/vu-u*v/)
      if (inptr@source .eq. "GFDL") then
        tmp = int2p_n_Wrap(plvlG,vubar,plvlM(::-1),2,0)
        vpup_bar = dim_avg_n_Wrap(tmp, 1)
        vpup_bar@long_name = "Transient eddy momentum"
        vpup_bar@units ="m~S~2~N~/s~S~2~N~"
        outptr->VPUP_BAR = vpup_bar(::-1,:) 
        return (vpup_bar)
      else
        hyam = inptr->hyam
        hybm = inptr->hybm
;jt     ps = inptr->PS(0,:,:)
        tmp = inptr->PS(0,:,:)
        if (typeof(tmp).eq."double") then
          ps = dble2flt(tmp)
        else
          ps = tmp
        end if 
        delete(tmp)
        tmp = vinth2p(vubar,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
        if (typeof(tmp).eq."double") then
          vpup_bar3 = dble2flt(tmp)
        else
          vpup_bar3 = tmp
        end if 
        vpup_bar = dim_avg_Wrap(vpup_bar3)
        vpup_bar@long_name = "Transient eddy momentum"
        vpup_bar@units ="m~S~2~N~/s~S~2~N~"
        vpup_bar@derive_op = "VU-U*V"
        assignFillValue(vpup_bar,vpup_bar)
        outptr->VPUP_BAR = vpup_bar 
      end if
    else
;     print ("VPUP_BAR: missing VU variable")
      vpup_bar = -999.
      return (vpup_bar)
    end if
  end if
  return (vpup_bar(::-1,:))
end

; BRH additions for COSP
load "$DIAG_CODE/functions_matrix.ncl"
undef("vertical_CFAD_DBZE94_CS")
function vertical_CFAD_DBZE94_CS (inptr:file,outptr:file)
local var,cfad
begin
  if (isfilevar(outptr,"VCFAD_DBZE94_CS")) then
    var = outptr->VCFAD_DBZE94_CS
  else
    if (isfilevar(inptr,"CFAD_DBZE94_CS")) then
      cfad = get_CFAD_DBZE94_CS(inptr,outptr)
      if (all(cfad.eq.-999.0)) then
        var = -999.0
      else
        var = dim_avg_Wrap( \
        dim_sum_Wrap(cfad(cosp_ht|:,lat|:,lon|:,{cosp_dbze|-25:})) \
        )
        var@long_name = "Hydrometeor occurrence"
        var@units = "percent"
        outptr->VCFAD_DBZE94_CS = var
      end if 
    end if
    var = -999.0     
  end if
  return (var)
end
