; profiles.ncl
; Plot vertical profiles from model and raobs data.
; Written by Mark Stevens Feb. 2001
; last update: 07/17/01
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_profiles.ncl"
begin
;********************************************************
; get from diagXXXXXX.csh cshell script
 testcase   = getenv("TEST_CASE")
 compcase   = getenv("STD_CASE")
 version    = getenv("DIAG_VERSION")
 wkdir      = getenv("WKDIR")
 plot_type  = getenv("PLOTTYPE")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")

;********************************************************
; constants
 Cp = 1.00464e3   ; J/(K*kg)
 g  = 9.80616     ; m/s^2
 L  = 2.501e6     ; J/kg
 p0 = 1000.       ; mb required by vinth2p

 month = (/"01","04","07","10"/)
 monthName = (/"JAN","APR","JUL","OCT"/)

;********************************************************
station_names = (/"Ascension_Island","Diego_Garcia","Truk_Island", \
"Western_Europe","Ethiopia","Resolute_Canada","Western_Desert_Australia", \
"Great_Plains_USA","Central_India","Marshall_Islands","Easter_Island", \
"McMurdo_Antarctica","SouthPole_Antarctica","Panama","Western_North_Atlantic",\
"Singapore","Manila","Gilbert_Islands","Hawaii","San_Paulo","Heard_Island", \
"Kagoshima_Japan","Port_Moresby","San_Juan_PR","Western_Alaska", \
"Thule_Greenland","SanFrancisco_CA","Denver_CO","London_UK","Crete", \
"Tokyo","Sydney_Australia","Christchurch_NZ","Lima_Peru","Miami_FL","Samoa", \
"ShipP_GulfofAlaska","ShipC_North_Atlantic","Azores","NewYork_USA", \
"Darwin_Australia","Christmas_Island","Cocos_Islands","Midway_Island", \
"Raoui_Island","Whitehorse_Canada","OklahomaCity_OK","Gibraltor", \
"Mexico_City","Recife_Brazil","Nairobi_Kenya","New_Delhi_India", \
"Madras_India","DaNang_Vietnam","Yap_Island","Falkland_Islands"/)

;vars = (/"T","Q","Z3","S","H","HS"/)
;var_names = (/"Temperature (K)","Specific Humidity (g/kg)", \
;       "Geopotential Height (km)","Dry Static Energy (kJ/kg)", \
;      "Moist Static Energy (kJ/kg)","Saturated Moist Static Energy (kJ/kg)"/)
vars = (/"T","Q","H"/)
var_names = (/"Temperature (K)","Specific Humidity (g/kg)", \
              "Moist Static Energy (kJ/kg)"/)
nvars = dimsizes(vars)
;********************************************************
 res                 = True
 res@trYReverse      = True
 res@trYMaxF = 1025.0
 if (compcase.ne."NONE") then       ; compare 2 models to raobs
   res@xyLineColors    = (/"black","red","blue"/)
   res@xyLineThicknesses = (/2,2,2/)
   res@xyMarkLineModes   = (/"Markers","Lines","Lines"/)
   res@xyDashPatterns    = (/0,1,0/) 
   res@xyMarkers         = (/16,0,0/)
 else                              ; compare model to raobs
   res@xyLineColors    = (/"black","red"/)
   res@xyLineThicknesses = (/2,2/)
   res@xyMarkLineModes   = (/"Markers","Lines"/)
   res@xyDashPatterns    = (/0,0/) 
   res@xyMarkers         = (/16,0/)
 end if
 res@xyMarkerColor     = "maroon" 
 res@xyMarkerSizeF     = 0.01
 res@pmLegendWidthF = 0.15
 res@pmLegendHeightF = 0.11
 res@lgLabelFontHeightF = .022
 res@lgPerimOn = True 
 res@txFontHeightF = 0.022
;*********************************************************************
; open raobs data file
in0 = addfile("$OBS_DATA/RAOBS.nc","r")
slat = in0->slat                    ; raobs station latitudes
slon = in0->slon                    ; raobs station longitudes
plevAtmo = in0->plev_atmo           ; raobs pressure levels 
npAtmo = dimsizes(plevAtmo)
plevTrop = in0->plev_trop           ; raobs pressures in troposphere only
npTrop = dimsizes(plevTrop)

; read station id numbers for plotting 
station_ids = asciiread(wkdir+"station_ids",-1,"integer")
if (station_ids(0).eq.56) then       ; do all stations
  delete (station_ids)
  station_ids = ispan (0,55,1)       ; all station ids
end if
nstations = dimsizes(station_ids)

TropMinP = 225.0   ; mb

; get some time and spatially independent data from the model files
file1 = testcase+"_01_climo.nc"
in1 = addfile(file1,"r")
if (in1@source .eq. "GFDL") then
  lev1 = in1->lev(::-1)
  tmp = in1->Z3(:,::-1,:,:)   ; (time,lev,lat,lon)
else
  lev1 = in1->lev
  hyam1 = in1->hyam
  hybm1 = in1->hybm
  tmp = in1->Z3   ; (time,lev,lat,lon)
end if
nlev1 = dimsizes(lev1)
if (typeof(tmp).eq."double") then
  coord1 = dble2flt(tmp)
else
  coord1 = tmp
end if
delete(tmp)
if (case_names .eq. "True") then
  case1 = getenv("CASE1")
else
  case1 = in1@case            ; case name 
end if
delete (file1)
delete (in1)

if (compcase .ne. "NONE") then       ; more than one model
  file2 = compcase+"_01_climo.nc"
  in2 = addfile(file2,"r")
  if (in2@source .eq. "GFDL") then
    lev2 = in2->lev(::-1)
    tmp = in2->Z3(:,::-1,:,:)  ; (time,lev,lat,lon)
  else
    lev2 = in2->lev
    hyam2 = in2->hyam
    hybm2 = in2->hybm
    tmp = in2->Z3  ; (time,lev,lat,lon)
  end if
  nlev2 = dimsizes(lev2)
  if (typeof(tmp).eq."double") then
    coord2 = dble2flt(tmp)
  else
    coord2 = tmp
  end if 
  delete(tmp)
  if (case_names .eq. "True") then
    case2 = getenv("CASE2")
  else
    case2 = in2@case            ; case name 
  end if
  res@xyExplicitLegendLabels = (/"raobs",case1,case2/)
  delete (file2)
  delete (in2)
else
  res@xyExplicitLegendLabels = (/"raobs",case1/)
end if 

do  ns = 0, nstations-1         ;   loop over stations 

  sid = station_ids(ns)        ; station id number 
  latpt = slat(sid)            ; station latitude
  lonpt = slon(sid)            ; station longitude

  if (sid .eq. 3) then         ; Western Europe 
    latpt = 51.626
  end if
  if (sid .eq. 26) then        ; San Francisco
    lonpt = 236.250
  end if
  if (sid .eq. 31) then        ; Sydney Australia 
    lonpt = 151.875
  end if
  if (sid .eq. 32) then        ; Christchurch NZ 
    lonpt = 174.375
  end if
  if (sid .eq. 34) then        ; Miami FL 
    latpt = 26.511
  end if
  if (sid .eq. 47) then        ; Gibraltor 
    latpt = 37.673
  end if

if (latpt .ge. -87.8638) then ; model can't do South Pole

  do nv = 0, nvars-1          ; loop over variables
    message = station_names(sid)+": "+vars(nv)
;   print((/message/))

    wks = gsn_open_wks(plot_type,wkdir+"set12_"+station_names(sid)+"_"+vars(nv))
    plot = new(4,"graphic")
    res@tiXAxisString = var_names(nv)
    do m = 0, 3                 ; loop over months
      file1 = testcase+"_"+month(m)+"_climo.nc"
      in1 = addfile(file1,"r")
      if (compcase.ne."NONE") then
        file2 = compcase+"_"+month(m)+"_climo.nc"
        in2 = addfile(file2,"r")
      end if

;     get model 1 pressure data
      if (in1@source .eq. "GFDL") then
        p1 = lev1
      else
        tmp1 = in1->PS           ; surf press (time,lat,lon) 
        if (typeof(tmp1).eq."double") then
          tmp = dble2flt(tmp1)
        else
          tmp = tmp1
        end if
        delete(tmp1)
        ps = tmp(0,:,:)
        ps = (/tmp(0,:,:)/100./)    ; scalar psfc in mb (hPa) 
        delete (tmp)
;       compute the pressure on the hybrid levels
        tmp = coord1(0,:,:,:)
        tmp = pres_hybrid_ccm (ps,p0,hyam1,hybm1)  ; returns 3D array (mb)
        p1 = tmp(:,{latpt},{lonpt})
        delete (ps)
        delete (tmp)
      end if
      minP = p1({TropMinP})      ; minimum trop pressure for plotting 
      ip1 = ind(p1.eq.minP)      ; index of min trop pressure
      np1 = nlev1-ip1            ; number of trop pressures to plot
      delete (minP)

;     get model 2 pressure data 
      if (compcase.ne."NONE") then
        if (in2@source .eq. "GFDL") then
          p2 = lev2
        else
          tmp2 = in2->PS           ; surf press (time,lat,lon) 
          if (typeof(tmp2).eq."double") then
            tmp = dble2flt(tmp2)
          else
            tmp = tmp2
          end if
          delete(tmp2)
          ps = tmp(0,:,:)
          ps = (/tmp(0,:,:)/100./)    ; scalar psfc in mb (hPa) 
          delete (tmp)
;         compute the pressure on the hybrid levels
          tmp = coord2(0,:,:,:)
          tmp = pres_hybrid_ccm (ps,p0,hyam2,hybm2)  ; returns 3D array (mb)
          p2 = tmp(:,{latpt},{lonpt})
          delete (ps)
          delete (tmp)
        end if
        minP = p2({TropMinP})      ; minimum trop presure for plotting 
        ip2 = ind(p2.eq.minP)      ; index of min trop pressure
        np2 = nlev2-ip2            ; number of trop pressures to plot
        delete (minP)
      end if

;     get model temperature data (K)
      if (in1@source .eq. "GFDL") then
        tmp1 = in1->T(:,::-1,:,:)  ; flip pressure levels 
      else
        tmp1 = in1->T              ; model 1 (time,lev,lat,lon)
      end if
      if (typeof(tmp1).eq."double") then
        tmp = dble2flt(tmp1)
      else
        tmp = tmp1
      end if
      delete(tmp1)
      t1 = (/tmp(0,:,{latpt},{lonpt})/)    ; scalar array
      delete (tmp)
      if (compcase.ne."NONE") then
        if (in2@source .eq. "GFDL") then
          tmp2 = in2->T(:,::-1,:,:)  ; flip pressure levels
        else
          tmp2 = in2->T              ; model 2 (time,lev,lat,lon)
        end if
        if (typeof(tmp2).eq."double") then
          tmp = dble2flt(tmp2)
        else
          tmp = tmp2
        end if
        delete(tmp2)
        t2 = (/tmp(0,:,{latpt},{lonpt})/)    ; scalar array
        delete (tmp)
      end if

;     get model geopotential height data (meters)
      if (in1@source .eq. "GFDL") then
        tmp1 = in1->Z3(:,::-1,:,:) 
      else
        tmp1 = in1->Z3           ; model 1 (time,lev,lat,lon)
      end if
      if (typeof(tmp1).eq."double") then
        tmp = dble2flt(tmp1)
      else
        tmp = tmp1
      end if
      delete(tmp1)
      z1 = (/tmp(0,:,{latpt},{lonpt})/)    ; scalar array
      delete (tmp)
      if (compcase.ne."NONE") then
        if (in2@source .eq. "GFDL") then
          tmp2 = in2->Z3(:,::-1,:,:)
        else
          tmp2 = in2->Z3           ; model 2 (time,lev,lat,lon)
        end if
        if (typeof(tmp2).eq."double") then
          tmp = dble2flt(tmp2)
        else
          tmp = tmp2
        end if
        delete(tmp2)
        z2 = (/tmp(0,:,{latpt},{lonpt})/)    ; scalar array
        delete (tmp)
      end if

;---------------------------------------------------------------------
      if (vars(nv).eq."T") then             ; surface to TOA
        if (compcase.ne."NONE") then
          dimXY = (/npAtmo,nlev1,nlev2/)
          nMax = max(dimXY)
          Xdata = new((/3,nMax/),"float")
          Ydata = new((/3,nMax/),"float")
        else
          dimXY = (/npAtmo,nlev1/)
          nMax = max(dimXY)
          Xdata = new((/2,nMax/),"float")
          Ydata = new((/2,nMax/),"float")
        end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"

;       assign temperature  data (X) 
        t0 = in0->T           ; raobs (station,month,plev_atmo)
        Xdata(0,0:dimXY(0)-1) = (/t0(sid,m,:)/)
;       model temperature data (X)
        Xdata(1,0:dimXY(1)-1) = (/t1/)       ; model 1 
        if (compcase.ne."NONE") then
          Xdata(2,0:dimXY(2)-1) = (/t2/)     ; model 2 
        end if
;       assign pressure level data (Y)
        Ydata(0,0:dimXY(0)-1) = (/plevAtmo/)   ; raobs
        Ydata(1,0:dimXY(1)-1) = (/p1/)         ; model 1 
        if (compcase.ne."NONE") then
          Ydata(2,0:dimXY(2)-1) = (/p2/)       ; model 2 
        end if
      end if
;---------------------------------------------------------------------
      if (vars(nv).eq."Z3") then             ; surface to TOA
        if (compcase.ne."NONE") then
          dimXY = (/npAtmo,nlev1,nlev2/)
          nMax = max(dimXY)
          Xdata = new((/3,nMax/),"float")
          Ydata = new((/3,nMax/),"float")
        else
          dimXY = (/npAtmo,nlev1/)
          nMax = max(dimXY)
          Xdata = new((/2,nMax/),"float")
          Ydata = new((/2,nMax/),"float")
        end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"

;       assign geopotential height data (X) convert to km for plot 
        z0 = in0->Z3          ; raobs (station,month,plev_atmo)
        Xdata(0,0:dimXY(0)-1) = (/z0(sid,m,:)/1000./)
;       model geopotential height data (X)
        Xdata(1,0:dimXY(1)-1) = (/z1/1000./)       ; model 1 
        if (compcase.ne."NONE") then
          Xdata(2,0:dimXY(2)-1) = (/z2/1000./)     ; model 2 
        end if
;       assign pressure level data (Y)
        Ydata(0,0:dimXY(0)-1) = (/plevAtmo/)   ; raobs
        Ydata(1,0:dimXY(1)-1) = (/p1/)         ; model 1 
        if (compcase.ne."NONE") then
          Ydata(2,0:dimXY(2)-1) = (/p2/)       ; model 2 
        end if
      end if
;-------------------------------------------------------------------
      if (vars(nv).eq."HS") then            ; surface to 250 mb
        if (compcase.ne."NONE") then
          dimXY = (/npTrop,np1,np2/)
          nMax = max(dimXY)
          Xdata = new((/3,nMax/),"float")
          Ydata = new((/3,nMax/),"float")
        else
          dimXY = (/npTrop,np1/)
          nMax = max(dimXY)
          Xdata = new((/2,nMax/),"float")
          Ydata = new((/2,nMax/),"float")
        end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"

;       assign HS data (X) 
        hs0 = in0->HS           ; raobs (station,month,plev_trop)
        Xdata(0,0:dimXY(0)-1) = (/hs0(sid,m,:)/)
;       model saturated moist static energy 
        Xdata(1,0:dimXY(1)-1) = smse_hybrid(t1(ip1:),z1(ip1:),p1(ip1:)) 
        if (compcase.ne."NONE") then
          Xdata(2,0:dimXY(2)-1) = smse_hybrid(t2(ip2:),z2(ip2:),p2(ip2:))
        end if
;       assign pressure level data (Y)
        Ydata(0,0:dimXY(0)-1) = (/plevTrop/)         ; raobs
        Ydata(1,0:dimXY(1)-1) = (/p1(ip1:)/)         ; model 1 
        if (compcase.ne."NONE") then
          Ydata(2,0:dimXY(2)-1) = (/p2(ip2:)/)       ; model 2 
        end if
      end if
;------------------------------------------------------------------------
      if (vars(nv).eq."Q" .or. vars(nv).eq."H") then
;       get specific humidity data 
        tmp = in0->Q     
        q0 = tmp(sid,m,:)                 ; raobs in g/g
        delete (tmp)
        if (in1@source .eq. "GFDL") then
          tmp1 = in1->Q(:,::-1,:,:)          
        else
          tmp1 = in1->Q
        end if
        if (typeof(tmp1).eq."double") then
          tmp = dble2flt(tmp1)
        else
          tmp = tmp1
        end if
        delete(tmp1)
        q1 = tmp(0,:,{latpt},{lonpt})     ; model 1 in kg/kg
        delete (tmp)
        if (compcase.ne."NONE") then
          if (in2@source .eq. "GFDL") then
            tmp2 = in2->Q(:,::-1,:,:)
          else
            tmp2 = in2->Q
          end if
          if (typeof(tmp2).eq."double") then
            tmp = dble2flt(tmp2)
          else
            tmp = tmp2
          end if
          delete(tmp2)
          q2 = tmp(0,:,{latpt},{lonpt})   ; model 2 in kg/kg
          delete (tmp)
        end if

        if (vars(nv).eq."Q") then         ; surface to 250 mb
          if (compcase.ne."NONE") then
            dimXY = (/npTrop,np1,np2/)
            nMax = max(dimXY)
            Xdata = new((/3,nMax/),"float")
            Ydata = new((/3,nMax/),"float")
          else
            dimXY = (/npTrop,np1/)
            nMax = max(dimXY)
            Xdata = new((/2,nMax/),"float")
            Ydata = new((/2,nMax/),"float")
          end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"

;         assign X data convert to g/kg
          Xdata(0,0:dimXY(0)-1) = (/q0*1000./)        ; raobs in g/kg
          Xdata(1,0:dimXY(1)-1) = (/q1(ip1:)*1000./)  ; model 1 in g/kg 
          if (compcase.ne."NONE") then
            Xdata(2,0:dimXY(2)-1) = (/q2(ip2:)*1000./)  ; model 2 in g/kg
          end if
;         assign pressure level data (Y)
          Ydata(0,0:dimXY(0)-1) = (/plevTrop/)       ; raobs
          Ydata(1,0:dimXY(1)-1) = (/p1(ip1:)/)       ; model 1 
          if (compcase.ne."NONE") then
            Ydata(2,0:dimXY(2)-1) = (/p2(ip2:)/)     ; model 2 
          end if
        end if
      end if
;--------------------------------------------------------------------------
      if (vars(nv).eq."S" .or. vars(nv).eq."H") then
;       compute dry static energy
        tmp = in0->S             
        s0 = tmp(sid,m,:)             ; raobs in kJ/kg 
        delete(tmp)
        s1 = (Cp*t1 + g*z1)/1000.     ; model 1 converted to kJ/kg
        if (compcase.ne."NONE") then
          s2 = (Cp*t2 + g*z2)/1000.   ; model 2 in kJ/kg
        end if

        if (vars(nv).eq."S") then         ; surface to TOA 
          if (compcase.ne."NONE") then
            dimXY = (/npAtmo,nlev1,nlev2/)
            nMax = max(dimXY)
            Xdata = new((/3,nMax/),"float")
            Ydata = new((/3,nMax/),"float")
          else
            dimXY = (/npAtmo,nlev1/)
            nMax = max(dimXY)
            Xdata = new((/2,nMax/),"float")
            Ydata = new((/2,nMax/),"float")
          end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"

;         assign dry static energy data (X)
          Xdata(0,0:dimXY(0)-1) = (/s0/)     ; raobs
          Xdata(1,0:dimXY(1)-1) = (/s1/)     ; model 1 
          if (compcase.ne."NONE") then
            Xdata(2,0:dimXY(2)-1) = (/s2/)   ; model 2 
          end if
;         assign pressure level data (Y)
          Ydata(0,0:dimXY(0)-1) = (/plevAtmo/)   ; raobs
          Ydata(1,0:dimXY(1)-1) = (/p1/)         ; model 1 
          if (compcase.ne."NONE") then
            Ydata(2,0:dimXY(2)-1) = (/p2/)       ; model 2 
          end if
        end if

        if (vars(nv).eq."H") then           ; surface to 250 mb
          if (compcase.ne."NONE") then
            dimXY = (/npTrop,np1,np2/)
            nMax = max(dimXY)
            Xdata = new((/3,nMax/),"float")
            Ydata = new((/3,nMax/),"float")
          else
            dimXY = (/npTrop,np1/)
            nMax = max(dimXY)
            Xdata = new((/2,nMax/),"float")
            Ydata = new((/2,nMax/),"float")
          end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"

;         assign moist static energy data
          h0 = in0->H                        ; raobs in kJ/kg 
          Xdata(0,0:dimXY(0)-1) = (/h0(sid,m,:)/)   
          h1 = s1 + L*q1/1000.               ; model 1 in kJ/kg
          Xdata(1,0:dimXY(1)-1) = (/h1(ip1:)/)   
          if (compcase.ne."NONE") then
            h2 = s2 + L*q2/1000.             ; model 2 in kJ/kg 
            Xdata(2,0:dimXY(2)-1) = (/h2(ip2:)/)   
          end if
;         assign pressure level data (Y)
          Ydata(0,0:dimXY(0)-1) = (/plevTrop/)       ; raobs
          Ydata(1,0:dimXY(1)-1) = (/p1(ip1:)/)       ; model 1 
          if (compcase.ne."NONE") then
            Ydata(2,0:dimXY(2)-1) = (/p2(ip2:)/)     ; model 2 
          end if
        end if
      end if

;*****************************************************************
      if (monthName(m).eq."JAN" .or. monthName(m).eq."JUL") then
        res@tiYAxisString = "Pressure (mb)"
      else
        delete (res@tiYAxisString)
      end if
      res@gsnLeftString = monthName(m)

      if (monthName(m).eq."APR") then
        res@pmLegendDisplayMode    = "Always"
        if (vars(nv).eq."H" .or. vars(nv).eq."HS") then
          res@pmLegendSide           = "Right"
          res@pmLegendParallelPosF   =   .30
          res@pmLegendOrthogonalPosF =  -.58
        end if
        if (vars(nv).eq."Z3" .or. vars(nv).eq."S") then
          res@pmLegendSide           = "Right"
          res@pmLegendParallelPosF   =   .10
          res@pmLegendOrthogonalPosF =  -.58
        end if
        if (vars(nv).eq."T") then
          res@pmLegendSide           = "Right"
          res@pmLegendParallelPosF   =   .10
          res@pmLegendOrthogonalPosF =  -1.04
        end if
        if (vars(nv).eq."Q") then
          res@pmLegendSide           = "Right"
          res@pmLegendParallelPosF   =  .90
          res@pmLegendOrthogonalPosF =  -.60
        end if
      else
        res@pmLegendDisplayMode    = "Never"
      end if
        
      res@gsnDraw = False
      res@gsnFrame = False
      plot(m) = gsn_csm_xy(wks,Xdata,Ydata,res)  ; create the plot

      delete (res@gsnLeftString)
      delete (in1)
      delete (file1)
      delete (Xdata)
      delete (Ydata)
      delete (dimXY)
      delete (nMax)
      if (compcase.ne."NONE") then
        delete (in2)
        delete (file2)
      end if
    end do           ; loop over months

;*********************************************
; add lat long info to plot
    txres               = True                   
    txres@txFontHeightF = 0.017                  

    if (latpt.lt.0) then
      prntlat = fabs(latpt)+ " S"
    else
      prntlat = latpt + " N"
    end if
    if (lonpt.gt.180) then
      prntlon = 360-lonpt + " W"
    else
      prntlon = lonpt + " E"
    end if
    title = station_names(sid)+"  latitude= "+prntlat+" longitude= "+prntlon
    gsn_text_ndc(wks,title,.50,.98,txres)

    panres = True
    panres@gsnFrame = False
    panres@gsnMaximize = True
    panres@gsnPanelTop = 0.96
    if (time_stamp .eq. "True") then
      panres@gsnPanelBottom = 0.05
      gsn_panel (wks,plot,(/2,2/),panres)
      infoTimeStamp(wks,0.011,"DIAG Version: "+version)
    else
      gsn_panel (wks,plot,(/2,2/),panres)
    end if
    frame(wks)
    delete (title)
    delete (res@tiXAxisString)
  end do             ; loop over variable
end if               ; check for south pole
end do               ; loop over station 

end
