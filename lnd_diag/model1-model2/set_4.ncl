; adapted from KOleson's profiles.ncl
; Plot vertical profiles from model and raobs data.
; Written by Mark Stevens Feb. 2001
; last update: 07/17/01
; Modified by K. Oleson Aug 2002 slightly to work 
; within LMWG diagnostics package
; Rewritten by N. Rosenbloom Jan 2005 to work with new
; LMWG diagnostics package
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/functions_contrib.ncl"
load "$DIAG_SHARED/functions_tables.ncl"

begin
 print ("=========================================")
 print ("Starting:  set_4.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
;********************************************************
; get from lwg_diagXXXXXX.csh cshell script
 path       = getenv("DIAG_CODE")
 inputVars  = getenv("INPUT_FILES")
 obsdata    = getenv("OBS_DATA")
 useCommon1 = getenv("UseCommonName_1")
 useCommon2 = getenv("UseCommonName_2")
 if (useCommon1 .eq. "True") then 
     case1  = getenv("commonName_1")
 else 
     case1  = getenv("caseid_1")
 end if 
 if (useCommon2 .eq. "True") then 
     case2  = getenv("commonName_2")
 else 
     case2  = getenv("caseid_2") 
 end if 
 prefix1    = getenv("prefix_1")
 prefix2    = getenv("prefix_2")
 version    = getenv("DIAG_VERSION")
 ptmpdir1    = getenv("PTMPDIR_1")
 ptmpdir2    = getenv("PTMPDIR_2")
 wkdir      = getenv("WKDIR")
 plot_type  = getenv("PLOTTYPE")
;********************************************************
; constants
 Cp = 1.00464e3   ; J/(K*kg)
 g  = 9.80616     ; m/s^2
 L  = 2.501e6     ; J/kg
 p0 = 1000.       ; mb required by vinth2p

 imonth = (/1,4,7,10/)
 month  = (/"01","04","07","10"/)
 month_name = (/"JAN","APR","JUL","OCT"/)

;********************************************************
 station_names = (/"Ascension_Island","Diego_Garcia","Truk_Island", \
 "Western_Europe","Ethiopia","Resolute_Canada","Western_Desert_Australia", \
 "Great_Plains_USA","Central_India","Marshall_Islands","Easter_Island", \
 "McMurdo_Antarctica","SouthPole_Antarctica","Panama","Western_North_Atlantic",\
 "Singapore","Manila","Gilbert_Islands","Hawaii","Sao_Paulo","Heard_Island", \
 "Kagoshima_Japan","Port_Moresby","San_Juan_PR","Western_Alaska", \
 "Thule_Greenland","SanFrancisco_CA","Denver_CO","London_UK","Crete", \
 "Tokyo","Sydney_Australia","Christchurch_NZ","Lima_Peru","Miami_FL","Samoa", \
 "ShipP_GulfofAlaska","ShipC_North_Atlantic","Azores","NewYork_USA", \
 "Darwin_Australia","Christmas_Island","Cocos_Islands","Midway_Island", \
 "Raoui_Island","Whitehorse_Canada","OklahomaCity_OK","Gibraltor", \
 "Mexico_City","Recife_Brazil","Nairobi_Kenya","New_Delhi_India", \
 "Madras_India","DaNang_Vietnam","Yap_Island","Falkland_Islands", \
 "Alaskan_Arctic","Canadian_Arctic", \
 "Greenland","Russian_Arctic","Alaska","Northwest_Canada", \
 "Central_Canada","Eastern_Canada","Northern_Europe", \
 "Western_Siberia","Eastern_Siberia","Western_US","Central_US", \
 "Eastern_US","Europe","Mediterranean","Central_America", \
 "Amazonia","Central_Africa","Indonesia","Brazil","Sahel", \
 "Southern_Africa","India","Indochina","Sahara_Desert", \
 "Arabian_Peninsula","Australia","Central_Asia","Mongolia", \
 "Tibetan_Plateau"/)

 vars = (/"T","Q"/)
 var_names = (/"Temperature (K)","Specific Humidity (g/kg)"/)
 nvars = dimsizes(vars)
;********************************************************
; set shared plot information
;********************************************************
 res                 = True
 res@trYReverse      = True
 res@trYMaxF = 1025.0
 res@xyLineColors    = (/"black","red","blue"/)
 res@xyLineThicknesses = (/2,2,2/)
 res@xyMarkLineModes   = (/"Markers","Lines","Lines"/)
 res@xyDashPatterns    = (/0,1,0/) 
 res@xyMarkers         = (/16,0,0/)
 res@xyMarkerColor     = "maroon" 
 res@xyMarkerSizeF     = 0.01
 res@pmLegendWidthF = 0.15
 res@pmLegendHeightF = 0.11
 res@lgLabelFontHeightF = .022
 res@lgPerimOn = True 
 res@txFontHeightF = 0.022
;*********************************************************************
; open raobs data file
in0 = addfile(obsdata+"/RAOBS_new.nc","r")
slat = in0->slat                    ; raobs station latitudes
slon = in0->slon                    ; raobs station longitudes
plevAtmo = in0->plev_atmo           ; raobs pressure levels 
npAtmo = dimsizes(plevAtmo)
plevTrop = in0->plev_trop           ; raobs pressures in troposphere only
npTrop = dimsizes(plevTrop)

; read station id numbers for plotting 
tmp = stringtocharacter(asciiread(inputVars+"/set4_stationIds.txt",-1,"string"))
nvs = dimsizes(tmp(:,0))
station_ids = new(nvs,"integer")
stations    = new(nvs,"string")
do i=0,nvs-1
        tmp2             = charactertostring(tmp(i,0:1))
        station_ids(i)   = stringtointeger(tmp2)
        stations(i) =  charactertostring(tmp(i,5:))
end do
delete(tmp)
delete(tmp2)

nstations = dimsizes(station_ids)

TropMinP = 225.0   ; mb

; get some time and spatially independent data from the model files
; Read in case1
  file1 = ptmpdir1 +"/"+ "/atm/"+prefix1+"_ANN_climo_atm.nc"
  in1 = addfile(file1,"r")
  lev1 = in1->lev
  nlev1 = dimsizes(lev1)
  hyam1 = in1->hyam
  hybm1 = in1->hybm
  tmp = in1->Z3   ; (time,lev,lat,lon)
  if (typeof(tmp).eq."double") then
    coord1 = dble2flt(tmp)
  else
    coord1 = tmp
  end if
  delete(tmp)
  delete (file1)
  delete (in1)

; Read in case2
  file2 = ptmpdir2 +"/"+ "/atm/"+prefix2+"_ANN_climo_atm.nc"
  in2 = addfile(file2,"r")
  lev2 = in2->lev
  nlev2 = dimsizes(lev2)
  hyam2 = in2->hyam
  hybm2 = in2->hybm
  tmp = in2->Z3  ; (time,lev,lat,lon)
  if (typeof(tmp).eq."double") then
    coord2 = dble2flt(tmp)
  else
    coord2 = tmp
  end if 
  delete(tmp)
  res@xyExplicitLegendLabels = (/"raobs",case1,case2/)
  delete (file2)
  delete (in2)

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

    wks = gsn_open_wks(plot_type,wkdir+"set4_"+station_names(sid)+"_"+vars(nv))
    plot = new(4,"graphic")
    res@tiXAxisString = var_names(nv)

    file1 = ptmpdir1 +"/"+ "/atm/"+prefix1+"_"+"MONS_climo_atm.nc"
    in1   = addfile(file1,"r")
    file2 = ptmpdir2 +"/"+ "/atm/"+prefix2+"_"+"MONS_climo_atm.nc"
    in2   = addfile(file2,"r")

    do m = 0, 3                 ; loop over months
      useMonth = imonth(m) - 1	; adjust to zero-base

;     get model 1 pressure data
      tmp1 = in1->PS(useMonth,:,:)           ; surf press (time,lat,lon) 
      if (typeof(tmp1).eq."double") then
        tmp = dble2flt(tmp1)
      else
        tmp = tmp1
      end if
      delete(tmp1)
      ps = tmp
      ps = (/tmp/100./)    ; scalar psfc in mb (hPa) 
      delete (tmp)
;     compute the pressure on the hybrid levels
      tmp = coord1(0,:,:,:)
      tmp = pres_hybrid_ccm (ps,p0,hyam1,hybm1)  ; returns 3D array (mb)
      p1 = tmp(:,{latpt},{lonpt})
      minP = p1({TropMinP})      ; minimum trop pressure for plotting 
      ip1 = ind(p1.eq.minP)      ; index of min trop pressure
      np1 = nlev1-ip1            ; number of trop pressures to plot
      delete (ps)
      delete (tmp)
      delete (minP)

;     get model 2 pressure data 
      tmp2 = in2->PS(useMonth,:,:)           ; surf press (time,lat,lon) 
      if (typeof(tmp2).eq."double") then
          tmp = dble2flt(tmp2)
      else
          tmp = tmp2
      end if
      delete(tmp2)
      ps = tmp
      ps = (/tmp/100./)    ; scalar psfc in mb (hPa) 
      delete (tmp)
;     compute the pressure on the hybrid levels
      tmp = coord2(0,:,:,:)
      tmp = pres_hybrid_ccm (ps,p0,hyam2,hybm2)  ; returns 3D array (mb)
      p2 = tmp(:,{latpt},{lonpt})
      minP = p2({TropMinP})      ; minimum trop presure for plotting 
      ip2 = ind(p2.eq.minP)      ; index of min trop pressure
      np2 = nlev2-ip2            ; number of trop pressures to plot
      delete (ps)
      delete (tmp)
      delete (minP)

;     get model temperature data (K)
      tmp1 = in1->T(useMonth,:,:,:)            ; model 1 (time,lev,lat,lon)
      if (typeof(tmp1).eq."double") then
        tmp = dble2flt(tmp1)
      else
        tmp = tmp1
      end if
      delete(tmp1)
      t1 = (/tmp(:,{latpt},{lonpt})/)    ; scalar array
      delete (tmp)
      tmp2 = in2->T(useMonth,:,:,:)            ; model 2 (time,lev,lat,lon)
      if (typeof(tmp2).eq."double") then
          tmp = dble2flt(tmp2)
      else
          tmp = tmp2
      end if
      delete(tmp2)
      t2 = (/tmp(:,{latpt},{lonpt})/)    ; scalar array
      delete (tmp)


;---------------------------------------------------------------------
      if (vars(nv).eq."T") then             ; surface to TOA
        dimXY = (/npAtmo,nlev1,nlev2/)
        nMax = max(dimXY)
        Xdata = new((/3,nMax/),"float")
        Ydata = new((/3,nMax/),"float")
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"

;   assign temperature  data (X) 
        t0 = in0->T           ; raobs (station,month,plev_atmo)
        Xdata(0,0:dimXY(0)-1) = (/t0(sid,m,:)/)
;   model temperature data (X)
        Xdata(1,0:dimXY(1)-1) = (/t1/)         ; model 1 
        Xdata(2,0:dimXY(2)-1) = (/t2/)         ; model 2 
;   assign pressure level data (Y)
        Ydata(0,0:dimXY(0)-1) = (/plevAtmo/)   ; raobs
        Ydata(1,0:dimXY(1)-1) = (/p1/)         ; model 1 
        Ydata(2,0:dimXY(2)-1) = (/p2/)         ; model 2 
      end if
;---------------------------------------------------------------------
      if (vars(nv).eq."Q") then
;       get specific humidity data 
        tmp = in0->Q     
        q0 = tmp(sid,m,:)                 ; raobs in g/g
        delete (tmp)
        tmp1 = in1->Q(useMonth,:,:,:)
        if (typeof(tmp1).eq."double") then
          tmp = dble2flt(tmp1)
        else
          tmp = tmp1
        end if
        delete(tmp1)
        q1 = tmp(:,{latpt},{lonpt})     ; model 1 in kg/kg
        delete (tmp)
        tmp2 = in2->Q(useMonth,:,:,:)
        if (typeof(tmp2).eq."double") then
            tmp = dble2flt(tmp2)
        else
            tmp = tmp2
        end if
        delete(tmp2)
        q2 = tmp(:,{latpt},{lonpt})   ; model 2 in kg/kg
        delete (tmp)

        dimXY = (/npTrop,np1,np2/)
        nMax = max(dimXY)
        Xdata = new((/3,nMax/),"float")
        Ydata = new((/3,nMax/),"float")
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"

;       assign X data convert to g/kg
        Xdata(0,0:dimXY(0)-1) = (/q0*1000./)        ; raobs in g/kg
        Xdata(1,0:dimXY(1)-1) = (/q1(ip1:)*1000./)  ; model 1 in g/kg 
        Xdata(2,0:dimXY(2)-1) = (/q2(ip2:)*1000./)  ; model 2 in g/kg
;       assign pressure level data (Y)
        Ydata(0,0:dimXY(0)-1) = (/plevTrop/)       ; raobs
        Ydata(1,0:dimXY(1)-1) = (/p1(ip1:)/)       ; model 1 
        Ydata(2,0:dimXY(2)-1) = (/p2(ip2:)/)       ; model 2 
      end if

;*****************************************************************
      if (month_name(m).eq."JAN" .or. month_name(m).eq."JUL") then
        res@tiYAxisString = "Pressure (mb)"
      else
        delete (res@tiYAxisString)
      end if
      res@gsnLeftString = month_name(m)

      if (month_name(m).eq."APR") then
        res@pmLegendDisplayMode    = "Always"
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
      delete (Xdata)
      delete (Ydata)
      delete (dimXY)
      delete (nMax)
    end do           ; loop over months
    delete (in1)
    delete (file1)
    if (case2.ne."NONE") then
        delete (in2)
        delete (file2)
    end if

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
    gsn_panel (wks,plot,(/2,2/),panres)
    frame(wks)
    delete (title)
    delete (res@tiXAxisString)
  end do             ; loop over variable
end if               ; check for south pole
end do               ; loop over station 

 print ("=========================================")
 print ("Finish Time: "+systemfunc("date") )
 print ("=========================================")

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set4_error_file"                   
  system("/bin/rm -f " + filo)  

end
