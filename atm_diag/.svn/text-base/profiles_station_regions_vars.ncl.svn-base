;  profiles_station_regions_vars.ncl
; Plot vertical profiles from model and raobs data.
; Written by Simone Tilmes Jan. 2013
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
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
 
 imon = (/1,4,7,10/)
 month = (/"01","04","07","10"/)
 month_names = (/"JAN","APR","JUL","OCT"/)

;********************************************************
station_names = (/"Alert","Eureka","Ny_Alesund","Resolute","Scoresbysund","Lerwick","Churchill","Edmonton",\
 "Goose_bay", "Legionowo", "Lindenberg", "Debilt", "Uccle", "Praha", "Hohenpeissenberg", "Payerne",\
 "Madrid", "Boulder", "Wallops_Island", "Trinidadhead", "Huntsville", "Sapporo", "Tateno", "Kagoshima", \
"Naha", "Hongkong", "Paramaribo", "Hilo", "Sancristobal", "Nairobi", "Natal", "Ascension" , "Watukosek", \
 "Samoa", "Fiji", "Reunion", "Broadmeadows" , "Lauder", "Macquarie", "Marambio", "Neumayer", "Syowa"/)
region_names =(/"nh_polar_west","nh_polar_east","canada","west_europe","eastern_us", \
              "japan","nh_tropic","tropics1","tropics2","tropics3","sh_midlat","sh_polar","western_us"/)
region_namesn =(/"NH Polar West","NH Polar East","Canada","Western Europe","Eastern US", \
              "Japan","NH SubTropic","W-Pacific/E-Indian Ocean","equat.Americas","Atlantic/Africa","SH MidLatitudes","SH Polar","Western US"/)
station_toregions = (/1,1,1,2,2,2,3,3,3,4,4,4,4,4,4,4,0,13,5,0,5,0,6,6,7,7,9,7,9,10,10,10,8,8,8,0,0,11,11,12,12,12/)
  region_min_lat = (/70.,   58.,  48.,  43.,    34., 30.,   15., -20.,-15., -15., -57.5,-90.,34./)
  region_max_lat = (/90.,   90.,  62.,  57.5,   40., 40.,   30., 0.,   15.,  15., -40., -58.,40./)
  region_min_lon = (/-135.,-45., -135., 0.,    -95., 120.,  90., 90.,  225.,-45., 135.,-180.,-110/)
  region_max_lon = (/-45.,  45.,  -45., 25.,   -75., 150., 225., 225., 315., 45., 180., 180.,-130/)
  region_min_lon = where(region_min_lon.lt.0,360.+region_min_lon,region_min_lon)
  region_max_lon = where(region_max_lon.lt.0,360.+region_max_lon,region_max_lon)


factor = (/1.,1.,1.e+03,1.e+06,1.,1.e+09,1.e+09,1.e+12,1.e+12,1.e+09,1.e+09,1.e+09/)
vars = (/"T","RELHUM","Q","SAD_TROP","CLOUD","O3","CO","OH","NOX","NOY","PAN","H2O2"/)
var_names = (/"Temperature","H2O","Rel.Humidity","SAD Trop","Total Cloud","O3","CO","OH","NOx","NOy","PAN","H2O2"/)
xlog = (/0,0,0,0,0,0,0,0,1,0,0,0/)
;xmax = (/300.,100.,10, 10.,0.5, 200.,200., 0.5, 10., 10, 1.2, 3./)
;xmin = (/200.,0.,  0., 0., 0.,    0., 20.,   0., 0.01,0.,0., 0./)
nvars = dimsizes(vars)

nstations = dimsizes(station_names)
nregions = dimsizes(region_names)
; define plot generals
;********************************************************
 res                 = True
 res@trYReverse      = True
 res@trYMaxF = 1025.0
 res@trYMinF = 125.0
;res@trXMaxF = 120.0
 if (compcase.ne."NONE") then       ; compare 2 models to raobs
   res@xyLineColors    = (/"black","red","blue","red","blue"/)
   res@xyLineThicknesses = (/2,2,2,2,2/)
   res@xyMarkLineModes   = (/"Markers","Lines","Lines","Lines","Lines"/)
   res@xyDashPatterns    = (/0,0,0,1,1/) 
   res@xyMarkers         = (/16,0,0,0,0/)
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
 res@pmLegendHeightF = 0.18
 res@lgLabelFontHeightF = .022
 res@lgPerimOn = True 
 res@txFontHeightF = 0.022
;*********************************************************************
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
  lon1 = in1->lon
  nlon1 = dimsizes(lon1) 
  lat1 = in1->lat
  nlat1 = dimsizes(lat1) 
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
    lon2 = in2->lon
    nlon2 = dimsizes(lon2) 
    lat2 = in2->lat
    nlat2 = dimsizes(lat2) 
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
  res@xyExplicitLegendLabels = (/"Ozonesondes",case1,case2,"Region","Region"/)
  delete (file2)
  delete (in2)
else
  res@xyExplicitLegendLabels = (/"Ozonesondes",case1,"Region"/)
end if
;*********************************************************************
; get lat/lon from Stations
slon = new((nstations),float)
slat = new((nstations),float)
; get lon/lat from all station
do  ns = 0, nstations-1         ;   loop over stations 
; open raobs data file
 in0 = addfile("$OBS_DATA/cam-chem/ozonesondes_"+station_names(ns)+"1995_2011.nc","r")
 slat(ns)=in0->lat
 slon1=in0->lon
 slon1 = where(slon1.lt.0.,360.+slon1,slon1)
 slon(ns)=slon1
end do

; start loop over regions
 do  re =  0, nregions-2         ;   loop over stations 
;do  re =  2, 4         ;   loop over stations 
  latmin = region_min_lat(re)
  latmax = region_max_lat(re)
  lonmin = region_min_lon(re)
  lonmax = region_max_lon(re)

  latmax1 = doubletofloat(lat1(nlat1-1))
  latmin1 = doubletofloat(lat1(0))
  dlat1 = doubletofloat(lat1(2)-lat1(1))
  if latmax.ge.latmax1 then
    latmax = latmax1-dlat1
  end if
  if latmin.le.latmin1 then
    latmin = latmin1+dlat1
  end if
 
  if (compcase.ne."NONE") then
    latmax2 = doubletofloat(lat2(nlat2-1))
    latmin2 = doubletofloat(lat2(0))
    dlat2 = doubletofloat(lat2(2)-lat2(1))
   if latmax.ge.latmax2 then
     latmax = latmax2-dlat2
   end if
   if latmin.le.latmin2 then
    latmin = latmin2+dlat2
   end if
  end if

  message = region_names(re)
; open obs data file
 rin0 = addfile("$OBS_DATA/cam-chem/ozonesondes_"+region_names(re)+"1995_2011.nc","r")
 if re.ne.nregions-1 then
  o3press = rin0->levels
 else
  o3press =  rin0->press
 end if
 npress = dimsizes(o3press) 
 ireg_mons = rin0->months
 val0 = rin0->o3_mean 
 std0 = rin0->o3_std 
 TropMinP = 225.0   ; mb

;  loop over seasons
;if (latpt .ge. -87.8638) then ; model can't do South Pole
 do m = 0, 3                 ; loop over months 


; define plot
 wks = gsn_open_wks(plot_type,wkdir+"cset3_"+region_names(re)+month_names(m)+"_varprofiles_comp")
    plot = new(12,"graphic")
;vars = (/"T","RELHUM","Q","ABSORB","SAD_TROP","CLOUD","O3","CO","OH","NOX","NOY","PAN"/)
    do v = 0, nvars-1                 ; loop over vars 
      res@tiXAxisString = var_names(v)
      if xlog(v).eq.0 then 
        res@trXAxisType = "LinearAxis"
      else
        res@trXAxisType = "LogAxis"
      end if
     ;res@trXMaxF =xmax(v)
     ;res@trXMinF =xmin(v)
      file1 = testcase+"_"+month(m)+"_climo.nc"
      in1 = addfile(file1,"r")
      if (compcase.ne."NONE") then
        file2 = compcase+"_"+month(m)+"_climo.nc"
        in2 = addfile(file2,"r")
      end if
;     get model 1 pressure data
      if (in1@source .eq. "GFDL") then
     ;  p1 = lev1
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
        pp1 = coord1(0,:,:,:)
        pp1 = pres_hybrid_ccm (ps,p0,hyam1,hybm1)  ; returns 3D array (mb)
       ;p1 = tmp(:,{latpt},{lonpt})
        delete (ps)
      end if

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
          pp2 = coord2(0,:,:,:)
          pp2 = pres_hybrid_ccm (ps,p0,hyam2,hybm2)  ; returns 3D array (mb)
       ;  p2 = tmp(:,{latpt},{lonpt})
          delete (ps)
        end if
      end if

;     get model variable data (K)
     if isfilevar(in1, vars(v)) then 
      if (in1@source .eq. "GFDL") then
        tmp1 = in1->$vars(v)$(:,::-1,:,:)  ; flip pressure levels 
      else
        tmp1 = in1->$vars(v)$              ; model 1 (time,lev,lat,lon)
      end if
      if (typeof(tmp1).eq."double") then
        tmp = dble2flt(tmp1)
      else
        tmp = tmp1
      end if
      delete(tmp1)
     ; loop over station latitudes 
      in_st = ind(station_toregions.eq.(re+1))
      nst_re = dimsizes(in_st)
      t1i = new((/dimsizes(lev1),dimsizes(in_st)/),"float")
      p1i = new((/dimsizes(lev1),dimsizes(in_st)/),"float")
      t1i!0= "lev"
      p1i!0= "lev"
      t1i!1= "station"
      p1i!1= "station"
      do s=0,nst_re-1
        latpt = slat(in_st(s))
        lonpt = slon(in_st(s))
        lonmax1 = doubletofloat(lon1(nlon1-1))
        lonpt = where(lonpt.gt.lonmax1,lonmax1,lonpt)
        tmp1 = tmp(0,:,{latpt},{lonpt})
        t1i(:,s) =tmp1 
        pmp1 = pp1(:,{latpt},{lonpt})
        p1i(:,s) = pmp1 
        delete(tmp1)
        delete(pmp1)
      end do  
      t1 = dim_avg_n_Wrap(t1i,1) 
      p1 = dim_avg_n_Wrap(p1i,1) 
      delete(t1i)   
      delete(p1i)   
  ;   derive regional average
     
      t11r = tmp(0,:,{latmin:latmax},{lonmin:lonmax})
      p11r = pp1(:,{latmin:latmax},{lonmin:lonmax})
  ;   average over lon/lat
      t1r = dim_avg_n_Wrap(t11r,(/1,2/))
      p1r = dim_avg_n_Wrap(p11r,(/1,2/))
      delete(t11r)
      delete(p11r)
      delete (tmp)
      delete (pp1)
       delete(in_st)

     else 
       t1 = new(nlev1,"float") 
       t1!0 =  "lev" 
       t1r = new(nlev1,"float") 
       t1r!0 =  "lev" 
       p1 = new(nlev1,"float") 
       p1!0 =  "lev" 
       p1r = new(nlev1,"float") 
       p1r!0 =  "lev" 
     end if

     if (compcase.ne."NONE") then
      if isfilevar(in2, vars(v)) then 
        if (in2@source .eq. "GFDL") then
          t1p2 = in2->$vars(v)$(:,::-1,:,:)  ; flip pressure levels
        else
          tmp2 = in2->$vars(v)$              ; model 2 (time,lev,lat,lon)
        end if
        if (typeof(tmp2).eq."double") then
          tmp = dble2flt(tmp2)
        else
          tmp = tmp2
        end if
        delete(tmp2)

         ; loop over station latitudes
        in_st = ind(station_toregions.eq.(re+1))
        nst_re = dimsizes(in_st)
        t2i = new((/dimsizes(lev2),dimsizes(in_st)/),"float")
        p2i = new((/dimsizes(lev2),dimsizes(in_st)/),"float")
        t2i!0= "lev"
        p2i!0= "lev"
        t2i!1= "station"
        p2i!1= "station"
        do s=0,nst_re-1
         latpt = slat(in_st(s))
         lonpt = slon(in_st(s))
         lonmax2 = doubletofloat(lon2(nlon2-1))
         lonpt = where(lonpt.gt.lonmax2,lonmax2,lonpt)
         tmp2 = tmp(0,:,{latpt},{lonpt})
         t2i(:,s) =tmp2
         pmp2 = pp2(:,{latpt},{lonpt})
         p2i(:,s) = pmp2
         delete(tmp2)
         delete(pmp2)
        end do
        t2 = dim_avg_n_Wrap(t2i,1)
        p2 = dim_avg_n_Wrap(p2i,1)
  ;   derive regional average
        delete(t2i)
        delete(p2i)
        t21r = tmp(0,:,{latmin:latmax},{lonmin:lonmax})
        p21r = pp2(:,{latmin:latmax},{lonmin:lonmax})
        t2r = dim_avg_n_Wrap(t21r,(/1,2/))
        p2r = dim_avg_n_Wrap(p21r,(/1,2/))
        delete(t21r)
        delete(p21r)
     ;  t2 = (/tmp(0,:,{latpt},{lonpt})/)    ; scalar array
        delete (tmp)
        delete (pp2)
        delete(in_st)
      else 
       t2 = new(nlev2,"float") 
       t2!0 =  "lev" 
       t2r = new(nlev2,"float") 
       t2r!0 =  "lev" 
       p2 = new(nlev2,"float") 
       p2!0 =  "lev" 
       p2r = new(nlev2,"float") 
       p2r!0 =  "lev" 
     end if
    end if

;---------------------------------------------------------------------
     if (compcase.ne."NONE") then
          dimXY = (/npress,nlev1,nlev2/)
          nMax = max(dimXY)
          Xdata = new((/5,nMax/),"float")
          Ydata = new((/5,nMax/),"float")
     else
          dimXY = (/npress,nlev1/)
          nMax = max(dimXY)
          Xdata = new((/3,nMax/),"float")
          Ydata = new((/3,nMax/),"float")
     end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"

;       assign ozone data (X) 
        if v.eq.5 then
           Xdata(0,0:dimXY(0)-1) = (/val0(:,imon(m))/)
        end if
;       model ozone data (X)
        Xdata(1,0:dimXY(1)-1) = (/t1/)*factor(v)       ; model 1 
        Xdata(3,0:dimXY(1)-1) = (/t1r/)*factor(v)    ; model 1 
        if (compcase.ne."NONE") then
          Xdata(2,0:dimXY(2)-1) = (/t2/)*factor(v)  ; model 2 
          Xdata(4,0:dimXY(2)-1) = (/t2r/)*factor(v)  ; model 2 
        end if
;       assign pressure level data (Y)
        if v.eq.5 then
          Ydata(0,0:dimXY(0)-1) = (/o3press/)   ; raobs
        end if
        Ydata(1,0:dimXY(1)-1) = (/p1/)         ; model 1 
        Ydata(3,0:dimXY(1)-1) = (/p1r/)         ; model 1 
        if (compcase.ne."NONE") then
          Ydata(2,0:dimXY(2)-1) = (/p2/)       ; model 2 
          Ydata(4,0:dimXY(2)-1) = (/p2r/)       ; model 2 
        end if
     inp1 = ind(Ydata(1,:) .ge.200)
     inp2 = ind(Ydata(2,:) .ge.200)
     inp3 = ind(Ydata(3,:) .ge.200)
     inp4 = ind(Ydata(4,:) .ge.200)
    if (compcase.eq."NONE") then
      xmax = max((/max(Xdata(1,inp1)),max(Xdata(2,inp2))/))
      xmin = min((/min(Xdata(1,inp1)),min(Xdata(2,inp2))/))
    else
      xmax = max((/max(Xdata(1,inp1)),max(Xdata(2,inp2)),max(Xdata(3,inp3)),max(Xdata(4,inp4))/))
      xmin = min((/min(Xdata(1,inp1)),min(Xdata(2,inp2)),min(Xdata(3,inp3)),min(Xdata(4,inp4))/))
    end if
     res@trXMaxF =xmax
     res@trXMinF =xmin
;*****************************************************************
     res@tiYAxisString = "Pressure (hPa)"
 ;     vars = (/"T","RELHUM","Q","APSORB","SAD_TROP","CLOUD","O3","CO","OH","NOX","NOY","PAN"/)
      if (vars(v).eq."T" .or. vars(v).eq."ABSORB" .or. vars(v).eq."O3" .or. vars(v).eq."NOX" ) then
        res@tiYAxisString = "Pressure (hPa)"
      else
        delete (res@tiYAxisString)
      end if
;     if v.eq.6 then 
;     res@trXMaxF = 200. 
;     end if
;     if v.eq.8 then 
;     res@trXMaxF =0.5 
;     end if
      res@gsnLeftString = var_names(v)

      if (vars(v).eq."Q") then
        res@pmLegendDisplayMode    = "Always"
          res@pmLegendSide           = "Right"
       ; if re.lt.6 .or. re.gt.9 then
          res@pmLegendParallelPosF   =  .80
          res@pmLegendOrthogonalPosF =  -.80
       ; else
       ;  res@pmLegendParallelPosF   =  .10
       ;  res@pmLegendOrthogonalPosF =  -.70
       ; end if
      else
        res@pmLegendDisplayMode    = "Never"
      end if
        
      res@gsnDraw = False
      res@gsnFrame = False
      plot(v) = gsn_csm_xy(wks,Xdata,Ydata,res)  ; create the plot

  ; if v.eq.5 then
  ;   polyres = True
  ;   polyres@NhlRemovePrimitive=-1 
  ;   std_mon = (/std0(:,imon(m))/)
  ;   val_mon = (/val0(:,imon(m))/)
  ;   error_bar = new(dimsizes(std_mon),graphic)
  ;   u_up = val_mon+std_mon
  ;   u_down = val_mon-std_mon 
  ;   u_up!0 = "lev"
  ;   u_down!0 = "lev"
  ;   yt = (/o3press/)
  ;   yt!0 = "lev"
  ;   do t = 0, npress-1 
  ;     error_bar(t) = gsn_add_polyline(wks,plot(m),(/u_up(t),u_down(t)/),(/yt(t),yt(t)/),polyres)
  ;   end do
  ;  end if
      delete (res@gsnLeftString)
    ; if v.eq.6 .or. v.eq.8 
    ;  delete (res@trXMaxF) 
    ; end if
      delete (in1)
      delete (file1)
      delete (Xdata)
      delete (Ydata)
      delete (dimXY)
      delete (nMax)
      delete (res@trXMaxF)
      delete (res@trXMinF)
      delete (xmax)
      delete (xmin)
      if (compcase.ne."NONE") then
        delete (in2)
        delete (file2)
      end if
    end do           ; loop over vars 

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
    title = region_namesn(re)+" "+month_names(m)
    gsn_text_ndc(wks,title,.50,.98,txres)

    panres = True
    panres@gsnFrame = False
    panres@gsnMaximize = True
    panres@gsnPanelTop = 0.96
    if (time_stamp .eq. "True") then
      panres@gsnPanelBottom = 0.05
      gsn_panel (wks,plot,(/4,3/),panres)
      infoTimeStamp(wks,0.011,"DIAG Version: "+version)
    else
      gsn_panel (wks,plot,(/4,3/),panres)
    end if
    frame(wks)
    delete (title)
    delete (res@tiXAxisString)
 end do           ; loop over months
    delete(lonmin)
    delete(latmin)
    delete(lonmax)
    delete(latmax)
end do               ; loop over regions 

end
