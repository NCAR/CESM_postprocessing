; NCL script
; functions_cycle.ncl
; Mark Stevens, Sept 2001
; last update Nov 4 2005
; all functions return 2D arrays (month,lat)
; set 8
;******************************************************************
month = (/"01","02","03","04","05","06", \
          "07","08","09","10","11","12"/)

function cycle_FLNT (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"FLNT")) then
    flnt = outptr->FLNT
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    flnt = new((/13,nlat/),float)
    flnt!0 = "time"
    flnt&time = ispan(1,13,1)
    flnt!1 = "lat"
    flnt&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->FLNT(0,:,:)
      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if
      flnt(m,:) = (/dim_avg(data)/)
    end do
    flnt(12,:) = (/flnt(0,:)/)        ; wrap around to jan 
    flnt@long_name = "TOM net LW flux"
    flnt@units = "W/m~S~2~N~"
    assignFillValue(flnt,flnt)
    outptr->FLNT = flnt
  end if
  return (flnt)
end

function cycle_FLUT (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"FLUT")) then
    flut = outptr->FLUT
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    if (isfilevar(inptr,"FLUT")) then 
      lat = inptr->lat
      nlat = dimsizes(lat)
      flut = new((/13,nlat/),float)
      flut!0 = "time"
      flut&time = ispan(1,13,1)
      flut!1 = "lat"
      flut&lat = lat
      do m = 0, 11
        inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
        tmp = inptr->FLUT(0,:,:)
        if (typeof(tmp).eq."double") then
          data = dble2flt(tmp)
        else
          data = tmp
        end if
        flut(m,:) = (/dim_avg(data)/)
      end do
      flut(12,:) = (/flut(0,:)/)        ; wrap around to jan 
      flut@long_name = "TOA upward LW flux"
      flut@units = "W/m~S~2~N~"
      assignFillValue(flut,flut)
      outptr->FLUT = flut
    else
      flut = -999.
    end if
  end if
  return (flut)
end

function cycle_SWCF (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"SWCF")) then
    swcf = outptr->SWCF
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    swcf = new((/13,nlat/),float)
    swcf!0 = "time"
    swcf&time = ispan(1,13,1)
    swcf!1 = "lat"
    swcf&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->SWCF(0,:,:)
      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if
      swcf(m,:) = (/dim_avg(data)/)
    end do
    swcf(12,:) = (/swcf(0,:)/)        ; wrap around to jan 
    swcf@long_name = "Shortwave cloud forcing"
    swcf@units = "W/m~S~2~N~"
    outptr->SWCF = swcf
  end if
  return (swcf)
end

function cycle_PRECT (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"PRECT")) then
    prect = outptr->PRECT
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    prect = new((/13,nlat/),float)
    prect!0 = "time"
    prect&time = ispan(1,13,1)
    prect!1 = "lat"
    prect&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      precc = inptr->PRECC(0,:,:)     ; (lat,lon) 
      precl = inptr->PRECL(0,:,:)
      tmp = precc
      tmp = (/(precc+precl)*8.64e7/)  ; mm/day 
      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if
      prect(m,:) = (/dim_avg(data)/)
    end do
    prect(12,:) = (/prect(0,:)/)        ; wrap around to jan 
    prect@long_name = "Precipitation rate"
    prect@units = "mm/day"
    assignFillValue(prect,prect)
    outptr->PRECT = prect
  end if
  return (prect)
end

function cycle_PRECT_PT(prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "PRECT_"+site

  if (isfilevar(outptr,VNAME)) then
    prect = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    prect = new((/13/),float)
    prect!0 = "time"
    prect&time = ispan(1,13,1)

    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      precc = inptr->PRECC(0,{latv},{lonv})
      precl = inptr->PRECL(0,{latv},{lonv})
      tmp = precc
      tmp = (/(precc+precl)*8.64e7/)  ; mm/day 
      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if
      prect(m) = data
    end do
    prect(12) = (/prect(0)/)        ; wrap around to jan 
    prect@long_name = "Precipitation rate"
    prect@units = "mm/day"
    assignFillValue(prect,prect)
    outptr->$VNAME$ = prect
  end if
  return (prect)
end


function cycle_T (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "T_"+site

  if (isfilevar(outptr,VNAME)) then
    t = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    plev = (/25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350,\
     375, 400, 425, 450, 475, 500, 525, 550, 575, 600, 625, 650, 675, 700,\
     725, 750, 775, 800, 825, 850, 875, 900, 925, 950, 975, 1000/)

    plev = plev (::-1)
    nlev = dimsizes(plev)
 
    plev@units = "mb"

    t = new((/13,nlev/),float)
    t!0 = "time"
    t&time = ispan(1,13,1)
    t!1 = "lev"
    t&lev = plev
    

    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->T(0,:,:,:)     
      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

      ;interp to arm plevs
       hyam = inptr->hyam
       hybm = inptr->hybm
       p0 = inptr->P0
       ps = inptr->PS(0,:,:)

       dat2 = vinth2p(data,hyam,hybm,plev,ps,2,p0/100.,1,False)
       t(m,:) = (/dat2(:,{latv},{lonv})/)
       delete(dat2) 

    end do
    t(12,:) = (/t(0,:)/)        ; wrap around to jan 
    t@long_name = "Temperature"
    t@units = "K"
    assignFillValue(t,t)
    outptr->$VNAME$ = t
  end if
  return (t)
end

function cycle_Q (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "Q_"+site

  if (isfilevar(outptr,VNAME)) then
    q = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    plev = (/25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350,\
     375, 400, 425, 450, 475, 500, 525, 550, 575, 600, 625, 650, 675, 700,\
     725, 750, 775, 800, 825, 850, 875, 900, 925, 950, 975, 1000/)
    plev = plev (::-1)

    nlev = dimsizes(plev)
 
    plev@units = "mb"

    q = new((/13,nlev/),float)
    q!0 = "time"
    q&time = ispan(1,13,1)
    q!1 = "lev"
    q&lev = plev
    

    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->Q(0,:,:,:)     
      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

      ;interp to arm plevs
       hyam = inptr->hyam
       hybm = inptr->hybm
       p0 = inptr->P0
       ps = inptr->PS(0,:,:)

       dat2 = vinth2p(data,hyam,hybm,plev,ps,2,p0/100.,1,False)
       dat2 = dat2*1000.
       q(m,:) = (/dat2(:,{latv},{lonv})/)
       delete(dat2) 

    end do
    q(12,:) = (/q(0,:)/)        ; wrap around to jan 
    q@long_name = "Specific Humidity"
    q@units = "g/kg"
    assignFillValue(q,q)
    outptr->$VNAME$ = q
  end if
  return (q)
end


function cycle_CLOUD (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "CLOUD_"+site

  if (isfilevar(outptr,VNAME)) then
    cloud = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    plev = (/25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350,\
     375, 400, 425, 450, 475, 500, 525, 550, 575, 600, 625, 650, 675, 700,\
     725, 750, 775, 800, 825, 850, 875, 900, 925, 950, 975, 1000/)
    plev = plev (::-1)
    nlev = dimsizes(plev)
 
    plev@units = "mb"

    cloud = new((/13,nlev/),float)
    cloud!0 = "time"
    cloud&time = ispan(1,13,1)
    cloud!1 = "lev"
    cloud&lev = plev
    
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->CLOUD(0,:,:,:)

      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

      ;interp to arm plevs
       hyam = inptr->hyam
       hybm = inptr->hybm
       p0 = inptr->P0
       ps = inptr->PS(0,:,:)

       dat2 = vinth2p(data,hyam,hybm,plev,ps,2,p0/100.,1,False)

       dat2 = dat2*100.

       dat2!0 = "lev"
       dat2!1 = "lat"
       dat2!2 = "lon"

       dat2@lat = inptr->lat
       dat2@lon = inptr->lon

       cloud(m,:) = (/dat2(:,{latv},{lonv})/)
       delete(dat2) 

    end do
    cloud(12,:) = (/cloud(0,:)/)        ; wrap around to jan 
    cloud@long_name = "Cloud Fraction"
    cloud@units = "%"
    assignFillValue(cloud,cloud)
    outptr->$VNAME$ = cloud
  end if
  return (cloud)
end

function cycle_CLDTOT (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "CLDTOT_"+site

  if (isfilevar(outptr,VNAME)) then
    cldtot = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")

    cldtot = new((/13/),float)
    cldtot!0 = "time"
    cldtot&time = ispan(1,13,1)
    
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->CLDTOT(0,:,:)

      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if
       
       dat2 = data
       dat2 = dat2*100.

;       dat2!0 = "lat"
;       dat2!1 = "lon"

;       dat2@lat = inptr->lat
;       dat2@lon = inptr->lon

       cldtot(m) = (/dat2({latv},{lonv})/)
       delete(dat2) 

    end do
    cldtot(12) = (/cldtot(0)/)        ; wrap around to jan 
    cldtot@long_name = "Total Cloud"
    cldtot@units = "%"
    assignFillValue(cldtot,cldtot)
    outptr->$VNAME$ = cldtot
  end if
  return (cldtot)
end

function cycle_MSE (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "MSE_"+site

  if (isfilevar(outptr,VNAME)) then
    mse = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    plev = (/25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350,\
     375, 400, 425, 450, 475, 500, 525, 550, 575, 600, 625, 650, 675, 700,\
     725, 750, 775, 800, 825, 850, 875, 900, 925, 950, 975, 1000/)
    plev = plev (::-1)

    nlev = dimsizes(plev)
 
    plev@units = "mb"

    mse = new((/13,nlev/),float)
    mse!0 = "time"
    mse&time = ispan(1,13,1)
    mse!1 = "lev"
    mse&lev = plev
    
    g = 9.81 ; gravity
    lhf =  2.501e6 ; latent heat of vaporization
    cp = 1.00464e3 ; specific heat of dry air


    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp_q = inptr->Q(0,:,:,:)     
      tmp_t = inptr->T(0,:,:,:)     
      tmp_z3 = inptr->Z3(0,:,:,:)     
      tmp = tmp_q
      tmp = (/cp*tmp_t+g*tmp_z3+lhf*tmp_q/)

      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

      ;interp to arm plevs
       hyam = inptr->hyam
       hybm = inptr->hybm
       p0 = inptr->P0
       ps = inptr->PS(0,:,:)

       dat2 = vinth2p(data,hyam,hybm,plev,ps,2,p0/100.,1,False)
       dat2 = dat2/1000.
       mse(m,:) = (/dat2(:,{latv},{lonv})/)
       delete(dat2) 

    end do
    mse(12,:) = (/mse(0,:)/)        ; wrap around to jan 
    mse@long_name = "Moist Static Energy"
    mse@units = "kJ/kg"
    assignFillValue(mse,mse)
    outptr->$VNAME$ = mse
  end if
  return (mse)
end

function cycle_TMQ (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "TMQ_"+site

  if (isfilevar(outptr,VNAME)) then
    tmq = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")

    tmq = new((/13/),float)
    tmq!0 = "time"
    tmq&time = ispan(1,13,1)
    
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->TMQ(0,:,:)     

      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

       tmq(m) = (/tmp({latv},{lonv})/)

    end do
    tmq(12) = (/tmq(0)/)        ; wrap around to jan 
    tmq@long_name = "Precipitable Water"
    tmq@units = "mm"
    assignFillValue(tmq,tmq)
    outptr->$VNAME$ = tmq
  end if
  return (tmq)
end

function cycle_TGCLDLWP (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "TGCLDLWP_"+site

  if (isfilevar(outptr,VNAME)) then
    tgcldlwp = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")

    tgcldlwp = new((/13/),float)
    tgcldlwp!0 = "time"
    tgcldlwp&time = ispan(1,13,1)
    
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->TGCLDLWP(0,:,:)     
      tmp =       tmp * 1000.  ;+++ ceh: change to kg/kg to g/kg
      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

       tgcldlwp(m) = (/tmp({latv},{lonv})/)

    end do
    tgcldlwp(12) = (/tgcldlwp(0)/)        ; wrap around to jan 
    tgcldlwp@long_name = "Cloud Liquid Water Path"
    tgcldlwp@units = "g/m:S:2:N:"
    assignFillValue(tgcldlwp,tgcldlwp)
    outptr->$VNAME$ = tgcldlwp
  end if
  return (tgcldlwp)
end


function cycle_LHFLX (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "LHFLX_"+site

  if (isfilevar(outptr,VNAME)) then
    lhflx = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")

    lhflx = new((/13/),float)
    lhflx!0 = "time"
    lhflx&time = ispan(1,13,1)
    
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->LHFLX(0,:,:)     

      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

       lhflx(m) = (/tmp({latv},{lonv})/)

    end do
    lhflx(12) = (/lhflx(0)/)        ; wrap around to jan 
    lhflx@long_name = "Latent Heat Flux"
    lhflx@units = "W/m:S:2:N:"
    assignFillValue(lhflx,lhflx)
    outptr->$VNAME$ = lhflx
  end if
  return (lhflx)
end


function cycle_SHFLX (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "SHFLX_"+site

  if (isfilevar(outptr,VNAME)) then
    shflx = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")

    shflx = new((/13/),float)
    shflx!0 = "time"
    shflx&time = ispan(1,13,1)
    
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->SHFLX(0,:,:)     

      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

       shflx(m) = (/tmp({latv},{lonv})/)

    end do
    shflx(12) = (/shflx(0)/)        ; wrap around to jan 
    shflx@long_name = "Sensible Heat Flux"
    shflx@units = "W/m:S:2:N:"
    assignFillValue(shflx,shflx)
    outptr->$VNAME$ = shflx
  end if
  return (shflx)
end


function cycle_FSDS (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "FSDS_"+site

  if (isfilevar(outptr,VNAME)) then
    fsds = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")

    fsds = new((/13/),float)
    fsds!0 = "time"
    fsds&time = ispan(1,13,1)
    
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp = inptr->FSDS(0,:,:)     

      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

       fsds(m) = (/tmp({latv},{lonv})/)

    end do
    fsds(12) = (/fsds(0)/)        ; wrap around to jan 
    fsds@long_name = "Downwelling SW at Surface"
    fsds@units = "W/m:S:2:N:"
    assignFillValue(fsds,fsds)
    outptr->$VNAME$ = fsds
  end if
  return (fsds)
end



function cycle_FLDS (prefix:string,outptr:file,latv:float,lonv:float,site:string)
begin

  VNAME = "FLDS_"+site

  sigma = 5.67e-8 ; Sigma


  if (isfilevar(outptr,VNAME)) then
    flds = outptr->$VNAME$
  else
    inptr = addfile(prefix+"_01_climo.nc","r")

    flds = new((/13/),float)
    flds!0 = "time"
    flds&time = ispan(1,13,1)
    
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      tmp_flns = inptr->FLNS(0,:,:)     
      tmp_ts = inptr->TS(0,:,:)     
      tmp = tmp_flns
      tmp = (/sigma*tmp_ts^4-tmp_flns/)

      if (typeof(tmp).eq."double") then
        data = dble2flt(tmp)
      else
        data = tmp
      end if

       flds(m) = (/tmp({latv},{lonv})/)

    end do
    flds(12) = (/flds(0)/)        ; wrap around to jan 
    flds@long_name = "Downwelling LW at Surface"
    flds@units = "W/m:S:2:N:"
    assignFillValue(flds,flds)
    outptr->$VNAME$ = flds
  end if
  return (flds)
end








function cycle_PREH2O (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"PREH2O")) then
    preh2o = outptr->PREH2O
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    preh2o = new((/13,nlat/),float)
    preh2o!0 = "time"
    preh2o&time = ispan(1,13,1)
    preh2o!1 = "lat"
    preh2o&lat = lat
    if (isfilevar(inptr,"TMQ") .or. isfilevar(inptr,"MQ")) then
      do m = 0, 11
        inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
        if (isfilevar(inptr,"TMQ")) then
          tmp = inptr->TMQ(0,:,:)
        else
          mq = inptr->MQ(0,:,:,:)
          tmp = mq(0,:,:)                       ; (lat,lon)
          tmp = dim_sum_n(mq, 0)                ; sum over levels
        ;;tmp = dim_sum(mq(lat|:,lon|:,lev|:))  ; sum over levels
        end if
        if (typeof(tmp).eq."double") then
          data = dble2flt(tmp)
        else
          data = tmp
        end if
        preh2o(m,:) = (/dim_avg(data)/)
      end do
      preh2o(12,:) = (/preh2o(0,:)/)          ; wrap around to jan 
      preh2o@long_name = "Precipitable water"
      preh2o@units = "mm"
      assignFillValue(preh2o,preh2o)
      outptr->PREH2O = preh2o
    else
      preh2o = -999.0
    end if
  end if
  return (preh2o)
end

function cycle_SOLIN (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"SOLIN")) then
    solin = outptr->SOLIN
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    if (isfilevar(inptr,"SOLIN")) then
      lat = inptr->lat
      nlat = dimsizes(lat)
      solin = new((/13,nlat/),float)
      solin!0 = "time"
      solin&time = ispan(1,13,1)
      solin!1 = "lat"
      solin&lat = lat
      do m = 0, 11
        inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
        tmp = inptr->SOLIN(0,:,:)
        if (typeof(tmp).eq."double") then
          data = dble2flt(tmp)
        else
          data = tmp
        end if
        solin(m,:) = (/dim_avg(data)/)
      end do
      solin(12,:) = (/solin(0,:)/)        ; wrap around to jan 
      solin@long_name = "Incoming solar radiation"
      solin@units = "W/m~S~2~N~"
      assignFillValue(solin,solin)
      outptr->SOLIN = solin
    else
      solin = -999.
    end if
  end if
  return (solin)
end

function cycle_SST (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"SST")) then
    sst = outptr->SST
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    sst = new((/13,nlat/),float)
    sst!0 = "time"
    sst&time = ispan(1,13,1)
    sst!1 = "lat"
    sst&lat = lat
    if (isfilevar(inptr,"TS")) then 
      do m = 0, 11
        inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
        ts = inptr->TS(0,:,:)
        ts = (/ts-273.15/)
        tmp = ts
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = mask(ts,oro,0)         ; mask with ocean
        else
          if (isfilevar(inptr,"OCNFRAC")) then
            ocnfrac = inptr->OCNFRAC(0,:,:)
            tmp = mask(ts,ocnfrac.ge.0.5,True)
          else
            print("SST: no ORO or OCNFRAC variables")
            sst = -999.
            return (sst)
          end if
        end if
        if (typeof(tmp).eq."double") then
          data = dble2flt(tmp)
        else
          data = tmp
        end if
        sst(m,:) = (/dim_avg(data)/)
      end do
      sst(12,:) = (/sst(0,:)/)      ; wrap around to jan 
      sst@long_name = "Sea surface temperature"
      sst@units = "C"
      outptr->SST = sst 
    else
      sst = -999.
    end if
  end if
  return (sst)
end

function cycle_TAUX_OCEAN (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"TAUX_OCEAN")) then
    taux_ocean = outptr->TAUX_OCEAN
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    if (isfilevar(inptr,"TAUX")) then 
      lat = inptr->lat
      nlat = dimsizes(lat)
      taux_ocean = new((/13,nlat/),float)
      taux_ocean!0 = "time"
      taux_ocean&time = ispan(1,13,1)
      taux_ocean!1 = "lat"
      taux_ocean&lat = lat
      do m = 0, 11
        inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
        tx = inptr->TAUX(0,:,:)
        tmp = tx
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = (/-1.0*mask(tx,oro,0)/)         ; mask with ocean
        else
          if (isfilevar(inptr,"OCNFRAC")) then
            ocnfrac = inptr->OCNFRAC(0,:,:)
            tmp = (/-1.0*mask(tx,ocnfrac.ge.0.5,True)/)
          else
            print("TAUX_OCEAN: no ORO or OCNFRAC variables")
            taux_ocean = -999.
            return (taux_ocean)
          end if
        end if
        if (typeof(tmp).eq."double") then
          taux = dble2flt(tmp)
        else
          taux = tmp
        end if
        taux_ocean(m,:) = (/dim_avg(taux)/)
      end do
      taux_ocean(12,:) = (/taux_ocean(0,:)/)      ; wrap around to jan 
      taux_ocean = (/taux_ocean*100./)            ; scale for plots
      taux_ocean@long_name = "Ocean zonal stress"
      taux_ocean@units = "N/m~S~2~N~ x.01"
      assignFillValue(taux_ocean,taux_ocean)
      outptr->TAUX_OCEAN = taux_ocean
    else
      taux_ocean = -999.
    end if
  end if
  return (taux_ocean)
end

function cycle_TAUY_OCEAN (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"TAUY_OCEAN")) then
    tauy_ocean = outptr->TAUY_OCEAN
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    if (isfilevar(inptr,"TAUY")) then 
      lat = inptr->lat
      nlat = dimsizes(lat)
      tauy_ocean = new((/13,nlat/),float)
      tauy_ocean!0 = "time"
      tauy_ocean&time = ispan(1,13,1)
      tauy_ocean!1 = "lat"
      tauy_ocean&lat = lat
      do m = 0, 11
        inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
        ty = inptr->TAUY(0,:,:)
        tmp = ty
        if (isfilevar(inptr,"ORO")) then
          oro = inptr->ORO(0,:,:)
          tmp = (/-1.0*mask(ty,oro,0)/)         ; mask with ocean
        else
          if (isfilevar(inptr,"OCNFRAC")) then
            ocnfrac = inptr->OCNFRAC(0,:,:)
            tmp = (/-1.0*mask(ty,ocnfrac.ge.0.5,True)/)
          else
            print("TAUY_OCEAN: no ORO or OCNFRAC variables")
            tauy_ocean = -999.
            return (tauy_ocean)
          end if
        end if
        if (typeof(tmp).eq."double") then
          tauy = dble2flt(tmp)
        else
          tauy = tmp
        end if
        tauy_ocean(m,:) = (/dim_avg(tauy)/)
      end do
      tauy_ocean(12,:) = (/tauy_ocean(0,:)/)      ; wrap around to jan 
      tauy_ocean = (/tauy_ocean*100./)            ; scale for plots
      tauy_ocean@long_name = "Ocean meridional stress"
      tauy_ocean@units = "N/m~S~2~N~ x.01"
      assignFillValue(tauy_ocean,tauy_ocean)
      outptr->TAUY_OCEAN = tauy_ocean
    else
      tauy_ocean = -999.
    end if
  end if
  return (tauy_ocean)
end

function cycle_U_200 (prefix:string,outptr:file)
begin
  if (isfilevar(outptr,"U_200")) then
     u_200 = outptr->U_200
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    if (inptr@source .ne. "GFDL") then
      hyam = inptr->hyam
      hybm = inptr->hybm
    end if
    lat = inptr->lat
    nlat = dimsizes(lat)
    u_200 = new((/13,nlat/),float)
    u_200!0 = "time"
    u_200&time = ispan(1,13,1)
    u_200!1 = "lat"
    u_200&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      if (inptr@source .eq. "GFDL") then
        u = inptr->U(0,9,:,:)             ; 200mb
        u_200(m,:) = (/dim_avg(u)/)
      else
        u = inptr->U(0,:,:,:)
        ps = inptr->PS(0,:,:)
        tmp = vinth2p (u,hyam,hybm,200.,ps,2,1000.,1,False) 
        if (typeof(tmp).eq."double") then
          u3 = dble2flt(tmp(0,:,:))
        else
          u3 = tmp(0,:,:)          ; (lat,lon)
        end if
        u_200(m,:) = (/dim_avg(u3)/)
      end if
    end do
    u_200(12,:) = (/u_200(0,:)/)        ; wrap around to jan 
    u_200@long_name = "200mb zonal wind"
    u_200@units = "m/s"
;   assignFillValue(u_200,u_200)
    outptr->U_200 = u_200
  end if
  return (u_200)
end

; BRH additions for COSP
load "$DIAG_CODE/functions_surfaces.ncl"

; ISCCP diagnostics
function cycle_CLDTOT_ISCCPCOSP (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDTOT_ISCCPCOSP")) then
    var = outptr->CLDTOT_ISCCPCOSP
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDTOT_ISCCPCOSP(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDTOT_ISCCPCOSP = var
  end if
  return (var)
end

function cycle_CLDLOW_ISCCPCOSP (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDLOW_ISCCPCOSP")) then
    var = outptr->CLDLOW_ISCCPCOSP
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDLOW_ISCCPCOSP(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDLOW_ISCCPCOSP = var
  end if
  return (var)
end

function cycle_CLDMED_ISCCPCOSP (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDMED_ISCCPCOSP")) then
    var = outptr->CLDMED_ISCCPCOSP
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDMED_ISCCPCOSP(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDMED_ISCCPCOSP = var
  end if
  return (var)
end

function cycle_CLDHGH_ISCCPCOSP (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDHGH_ISCCPCOSP")) then
    var = outptr->CLDHGH_ISCCPCOSP
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDHGH_ISCCPCOSP(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDHGH_ISCCPCOSP = var
  end if
  return (var)
end

function cycle_CLDTHICK_ISCCPCOSP (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDTHICK_ISCCPCOSP")) then
    var = outptr->CLDTHICK_ISCCPCOSP
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDTHICK_ISCCPCOSP(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDTHICK_ISCCPCOSP = var
  end if
  return (var)
end

function cycle_MEANCLDALB_ISCCPCOSP (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"MEANCLDALB_ISCCPCOSP")) then
    var = outptr->MEANCLDALB_ISCCPCOSP
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_MEANCLDALB_ISCCPCOSP(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->MEANCLDALB_ISCCPCOSP = var
  end if
  return (var)
end

function cycle_MEANPTOP_ISCCPCOSP (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"MEANPTOP_ISCCPCOSP")) then
    var = outptr->MEANPTOP_ISCCPCOSP
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_MEANPTOP_ISCCPCOSP(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->MEANPTOP_ISCCPCOSP = var
  end if
  return (var)
end

function cycle_MEANTTOP_ISCCPCOSP (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"MEANTTOP_ISCCPCOSP")) then
    var = outptr->MEANTTOP_ISCCPCOSP
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_MEANTTOP_ISCCPCOSP(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->MEANTTOP_ISCCPCOSP = var
  end if
  return (var)
end

; MISR diagnostics
function cycle_CLDTOT_MISR (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDTOT_MISR")) then
    var = outptr->CLDTOT_MISR
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDTOT_MISR(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDTOT_MISR = var
  end if
  return (var)
end

function cycle_CLDLOW_MISR (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDLOW_MISR")) then
    var = outptr->CLDLOW_MISR
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDLOW_MISR(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDLOW_MISR = var
  end if
  return (var)
end

function cycle_CLDMED_MISR (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDMED_MISR")) then
    var = outptr->CLDMED_MISR
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDMED_MISR(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDMED_MISR = var
  end if
  return (var)
end

function cycle_CLDHGH_MISR (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDHGH_MISR")) then
    var = outptr->CLDHGH_MISR
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDHGH_MISR(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDHGH_MISR = var
  end if
  return (var)
end

function cycle_CLDTHICK_MISR (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDTHICK_MISR")) then
    var = outptr->CLDTHICK_MISR
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDTHICK_MISR(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDTHICK_MISR = var
  end if
  return (var)
end

; MODIS diagnostics
function cycle_CLDTOT_MODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDTOT_MODIS")) then
    var = outptr->CLDTOT_MODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDTOT_MODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDTOT_MODIS = var
  end if
  return (var)
end

function cycle_CLDLOW_MODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDLOW_MODIS")) then
    var = outptr->CLDLOW_MODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDLOW_MODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDLOW_MODIS = var
  end if
  return (var)
end

function cycle_CLDMED_MODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDMED_MODIS")) then
    var = outptr->CLDMED_MODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDMED_MODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDMED_MODIS = var
  end if
  return (var)
end

function cycle_CLDHGH_MODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDHGH_MODIS")) then
    var = outptr->CLDHGH_MODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDHGH_MODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDHGH_MODIS = var
  end if
  return (var)
end

function cycle_CLDTHICK_MODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDTHICK_MODIS")) then
    var = outptr->CLDTHICK_MODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDTHICK_MODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDTHICK_MODIS = var
  end if
  return (var)
end

function cycle_CLWMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLWMODIS")) then
    var = outptr->CLWMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLWMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLWMODIS = var
  end if
  return (var)
end

function cycle_CLIMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLIMODIS")) then
    var = outptr->CLIMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLIMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLIMODIS = var
  end if
  return (var)
end

function cycle_LWPMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"LWPMODIS")) then
    var = outptr->LWPMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_LWPMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->LWPMODIS = var
  end if
  return (var)
end

function cycle_IWPMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"IWPMODIS")) then
    var = outptr->IWPMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_IWPMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->IWPMODIS = var
  end if
  return (var)
end

function cycle_REFFCLWMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"REFFCLWMODIS")) then
    var = outptr->REFFCLWMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_REFFCLWMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->REFFCLWMODIS = var
  end if
  return (var)
end

function cycle_REFFCLIMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"REFFCLIMODIS")) then
    var = outptr->REFFCLIMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_REFFCLIMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->REFFCLIMODIS = var
  end if
  return (var)
end

function cycle_TAUTLOGMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"TAUTLOGMODIS")) then
    var = outptr->TAUTLOGMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_TAUTLOGMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->TAUTLOGMODIS = var
  end if
  return (var)
end

function cycle_TAUWLOGMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"TAUWLOGMODIS")) then
    var = outptr->TAUWLOGMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_TAUWLOGMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->TAUWLOGMODIS = var
  end if
  return (var)
end

function cycle_TAUILOGMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"TAUILOGMODIS")) then
    var = outptr->TAUILOGMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_TAUILOGMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->TAUILOGMODIS = var
  end if
  return (var)
end

function cycle_TAUIMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"TAUIMODIS")) then
    var = outptr->TAUIMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_TAUIMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->TAUIMODIS = var
  end if
  return (var)
end

function cycle_TAUWMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"TAUWMODIS")) then
    var = outptr->TAUWMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_TAUWMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->TAUWMODIS = var
  end if
  return (var)
end

function cycle_TAUTMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"TAUTMODIS")) then
    var = outptr->TAUTMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_TAUTMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->TAUTMODIS = var
  end if
  return (var)
end

function cycle_PCTMODIS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"PCTMODIS")) then
    var = outptr->PCTMODIS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_PCTMODIS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->PCTMODIS = var
  end if
  return (var)
end

; CALIPSO diagnostics
function cycle_CLDTOT_CAL (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDTOT_CAL")) then
    var = outptr->CLDTOT_CAL
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDTOT_CAL(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDTOT_CAL = var
  end if
  return (var)
end

function cycle_CLDLOW_CAL (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDLOW_CAL")) then
    var = outptr->CLDLOW_CAL
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDLOW_CAL(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDLOW_CAL = var
  end if
  return (var)
end

function cycle_CLDMED_CAL (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDMED_CAL")) then
    var = outptr->CLDMED_CAL
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDMED_CAL(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDMED_CAL = var
  end if
  return (var)
end

function cycle_CLDHGH_CAL (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDHGH_CAL")) then
    var = outptr->CLDHGH_CAL
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDHGH_CAL(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDHGH_CAL = var
  end if
  return (var)
end

; CLOUDSAT diagnostics
function cycle_CLDTOT_CS2 (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDTOT_CS2")) then
    var = outptr->CLDTOT_CS2
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDTOT_CS2(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDTOT_CS2 = var
  end if
  return (var)
end

function cycle_CLDTOT_CS (prefix:string,outptr:file)
local var,inptr,lat,m,outptrDummy,data
begin
  if (isfilevar(outptr,"CLDTOT_CS")) then
    var = outptr->CLDTOT_CS
  else
    inptr = addfile(prefix+"_01_climo.nc","r")
    lat = inptr->lat
    nlat = dimsizes(lat)
    var = new((/13,nlat/),float)
    var!0 = "time"
    var&time = ispan(1,13,1)
    var!1 = "lat"
    var&lat = lat
    do m = 0, 11
      inptr = addfile(prefix+"_"+month(m)+"_climo.nc","r")
      system("rm -f dummy.nc")
      outptrDummy = addfile("dummy.nc","c")
      data = get_CLDTOT_CS(inptr,outptrDummy)
      system("rm -f dummy.nc")
      if (all(data.eq.-999.0)) then
        var = -999.0         
        return(var)
      else
        var(m,:) = (/dim_avg(data)/)
      end if 
    end do
    var(12,:) = (/var(0,:)/)        ; wrap around to jan 
    var@long_name = data@long_name
    var@units = data@units
    assignFillValue(var,var)
    outptr->CLDTOT_CS = var
  end if
  return (var)
end

