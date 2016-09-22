; seasonal_cycle_o3_regions_comp.ncl
; Plot vertical profiles from model and raobs data.
; Written by Simone Tilmes Jan. 2013
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
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
; read seasonal surface CO data:
  fname = "$OBS_DATA/surface_co_seasonal_cycle_cmdl.out"
  data  = readAsciiTable(fname, 4, "float", 0)
  stn_lat   = data(:,0)
  stn_lon   = data(:,1)
  stn_lon = where(stn_lon.lt.0.,stn_lon+360.,stn_lon)
  stn_cycle = data(:,3)
  printVarSummary(stn_cycle)
 
 
 month = sprinti("%0.2i", ispan(1,12,1))
 imon = ispan(1,12,1)
 imon13 = ispan(0,12,1)
 plev_names = (/"900hPa","500hPa","250hPa","50hPa"/)
 plev = (/900.,500.,250.,50./)
 plevn = dimsizes(plev) 


;********************************************************
station_names = (/"Alert","Eureka","Ny_Alesund","Resolute","Scoresbysund","Lerwick","Churchill","Edmonton",\
 "Goose_bay", "Legionowo", "Lindenberg", "Debilt", "Uccle", "Praha", "Hohenpeissenberg", "Payerne",\
 "Madrid", "Boulder", "Wallops_Island", "Trinidadhead", "Huntsville", "Sapporo", "Tateno", "Kagoshima", \
"Naha", "Hongkong", "Paramaribo", "Hilo", "Sancristobal", "Nairobi", "Natal", "Ascension" , "Watukosek", \
 "Samoa", "Fiji", "Reunion", "Broadmeadows" , "Lauder", "Macquarie", "Marambio", "Neumayer", "Syowa"/)
region_names =(/"nh_polar_west","nh_polar_east","canada","west_europe","eastern_us", \
              "japan","nh_tropic","tropics1","tropics2","tropics3","sh_midlat","sh_polar","Boulder"/)
region_namesn =(/"NH Polar West","NH Polar East","Canada","Western Europe","Eastern US", \
              "Japan","NH SubTropic","W-Pacific/E-Indian Ocean","equat.Americas","Atlantic/Africa","SH MidLatitudes","SH Polar","Boulder"/)
station_toregions = (/1,1,1,2,2,2,3,3,3,4,4,4,4,4,4,4,0,13,5,0,5,0,6,6,7,7,9,7,9,10,10,10,8,8,8,0,0,11,11,12,12,12/)
  region_min_lat = (/70.,   58.,  48.,  43.,    34., 30.,   15., -20.,-15., -15., -57.5,-90.,37./)
  region_max_lat = (/90.,   90.,  62.,  57.5,   40., 40.,   30., 0.,   15.,  15., -40., -58.,42./)
  region_min_lon = (/-135.,-45., -135., 0.,    -95., 120.,  90., 90.,  225.,-45., 135.,-180.,-100/)
  region_max_lon = (/-45.,  45.,  -45., 25.,   -75., 150., 225., 225., 315., 45., 180., 180.,-110/)
  region_min_lon = where(region_min_lon.lt.0,360.+region_min_lon,region_min_lon)
  region_max_lon = where(region_max_lon.lt.0,360.+region_max_lon,region_max_lon)


vars = "O3"
var_names = "Ozone (ppb)"
nvars = dimsizes(vars)
nstations = dimsizes(station_names)
nregions = dimsizes(region_names)

 Ymean = new((/3,plevn,nregions/),"float")
 Ydiff =  new((/2,plevn,nregions/),"float")
 Yreldiff =  new((/2,plevn,nregions/),"float")
 Ycorr = new((/2,plevn,nregions/),"float")
 Ymean = 0.
 Ydiff = 0.
 Yreldiff = 0.
 YCorr = 0.

; define plot generals
;********************************************************
 res                 = True
;res@trYMaxF = 1025.0
;res@trXMaxF = 120.0
 if (compcase.ne."NONE") then       ; compare 2 models to raobs
   res@xyLineColors    = (/"black","red","red","blue","blue"/)
   res@xyLineThicknesses = (/2,2,2,2,2/)
   res@xyMarkLineModes   = (/"Markers","Lines","Lines","Lines","Lines"/)
   res@xyDashPatterns    = (/0,0,1,0,1/) 
   res@xyMarkers         = (/16,0,0,0,0/)
 else                              ; compare model to raobs
   res@xyLineColors    = (/"black","red","red"/)
   res@xyLineThicknesses = (/2,2,2/)
   res@xyMarkLineModes   = (/"Markers","Lines","Lines"/)
   res@xyDashPatterns    = (/0,0,1/) 
   res@xyMarkers         = (/16,0,0/)
 end if
 res@xyMarkerColor     = "maroon" 
 res@xyMarkerSizeF     = 0.01
 res@pmLegendWidthF = 0.15
 res@pmLegendHeightF = 0.15
 res@lgLabelFontHeightF = .020
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
  res@xyExplicitLegendLabels = (/"Ozonesondes",case1,"Regional Avg.",case2,"Region Avg."/)
  delete (file2)
  delete (in2)
else
  res@xyExplicitLegendLabels = (/"Ozonesondes",case1,"Regional Avg."/)
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
do re = 0, nregions-1         ;   loop over stations 
; open obs data file
  message = region_names(re)
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

;if (latpt .ge. -87.8638) then ; model can't do South Pole

  nmons = 12 
;  derive seasonal cyle for all pressure levels
   t1_all = new((/nmons,plevn/),"float")
   t1r_all = new((/nmons,plevn/),"float")
   t2_all = new((/nmons,plevn/),"float")
   t2r_all = new((/nmons,plevn/),"float")
   do m = 0, nmons-1                 ; loop over months
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


;     get model ozone data (K)
      if (in1@source .eq. "GFDL") then
        tmp1 = in1->O3(:,::-1,:,:)  ; flip pressure levels 
      else
        tmp1 = in1->O3              ; model 1 (time,lev,lat,lon)
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
      if (.not.all(ismissing(t1i))) then
       t1 = dim_avg_n_Wrap(t1i,1) 
       p1 = dim_avg_n_Wrap(p1i,1) 
      else
       t1 = new(nlev1,"float")
       p1 = new(nlev1,"float")
      end if
      delete(t1i)   
      delete(p1i)   
      ; interpolate t1 to the four pressure levels
      linlog = 0
      t1_all(m,:) = int2p_n_Wrap (p1,t1,plev,linlog,0)
  ;   derive regional average
     
      t11r = tmp(0,:,{latmin:latmax},{lonmin:lonmax})
      p11r = pp1(:,{latmin:latmax},{lonmin:lonmax})
  ;   average over lon/lat
      if (.not.all(ismissing(t11r))) then
       t1r = dim_avg_n_Wrap(t11r,(/1,2/))
       p1r = dim_avg_n_Wrap(p11r,(/1,2/))
      else 
       t1r = new(nlev1,"float")
       p1r = new(nlev1,"float")
      end if
      delete(t11r)
      delete(p11r)
      delete (tmp)
      delete (pp1)
      ; interpolate t1r to the four pressure levels
      linlog = 0
      t1r_all(m,:) = int2p_n_Wrap (p1r,t1r,plev,linlog,0)

 ;    t1 = (/tmp(0,:,{latpt},{lonpt})/)    ; scalar array
 ;    minP = p1({TropMinP})      ; minimum trop pressure for plotting 
 ;    ip1 = ind(p1.eq.minP)      ; index of min trop pressure
 ;    np1 = nlev1-ip1            ; number of trop pressures to plot
 ;    delete (minP)

      if (compcase.ne."NONE") then
        if (in2@source .eq. "GFDL") then
          t1p2 = in2->O3(:,::-1,:,:)  ; flip pressure levels
        else
          tmp2 = in2->O3              ; model 2 (time,lev,lat,lon)
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
        if (.not.all(ismissing(t2i))) then
         t2 = dim_avg_n_Wrap(t2i,1) 
         p2 = dim_avg_n_Wrap(p2i,1) 
        else
          t2 = new(nlev2,"float")
          p2 = new(nlev2,"float")
        end if
        delete(t2i)   
        delete(p2i)   
        linlog = 0
        t2_all(m,:) = int2p_n_Wrap (p2,t2,plev,linlog,0)

  ;   derive regional average
        t21r = tmp(0,:,{latmin:latmax},{lonmin:lonmax})
        p21r = pp2(:,{latmin:latmax},{lonmin:lonmax})
        if (.not.all(ismissing(t21r))) then
          t2r = dim_avg_n_Wrap(t21r,(/1,2/))
          p2r = dim_avg_n_Wrap(p21r,(/1,2/))
        else
          t2r = new(nlev2,"float")
          p2r = new(nlev2,"float")
        end if
        delete(t21r)
        delete(p21r)
     ;  t2 = (/tmp(0,:,{latpt},{lonpt})/)    ; scalar array
        delete (tmp)
        delete (pp2)
      ; interpolate t1r to the four pressure levels
        linlog = 0
        t2r_all(m,:) = int2p_n_Wrap (p2r,t2r,plev,linlog,0)
      end if
      delete(in_st)
      delete(t1)
      delete(p1)
      delete(t1r)
      delete(p1r)
     if (compcase.ne."NONE") then
      delete(t2)
      delete(p2)
      delete(t2r)
      delete(p2r)
     end if
    end do ; loop over months

;---------------------------------------------------------------------
; define plot
 wks = gsn_open_wks(plot_type,wkdir+"cset3_"+region_names(re)+"_o3seasonal_comp")
    plot = new(4,"graphic")
    res@tiXAxisString = "months" 
    error_bar = new((/4,nmons/),graphic)


   do pr = 0, 3                 ; loop over pressure levels 
     dimXY = nmons+1
     if (compcase.ne."NONE") then
          Xdata = new((/5,dimXY/),"float")
          Ydata = new((/5,dimXY/),"float")
     else
          Xdata = new((/3,dimXY/),"float")
          Ydata = new((/3,dimXY/),"float")
     end if

        Xdata!0 = "months"
        Xdata!1 = "line"
        Ydata!0 = "months"
        Ydata!1 = "line"


        inpress = ind(o3press.eq.plev(pr))
;       assign ozone data (Y) 
        Ydata(0,1:dimXY-1) = (/val0(inpress,:)/)
        Ydata(0,0) = (/val0(inpress,11)/)
;       model ozone data (X)
        Ydata(1,1:dimXY-1) = (/t1_all(:,pr)/)*1.e+09       ; model 1 
        Ydata(1,0) = (/t1_all(11,pr)/)*1.e+09       ; model 1 
        Ydata(2,1:dimXY-1) = (/t1r_all(:,pr)/)*1.e+09       ; model 1 
        Ydata(2,0) = (/t1r_all(11,pr)/)*1.e+09       ; model 1 
      if (.not.all(ismissing(val0(inpress,:)))) then
        Ymean(0,pr,re) = avg((/val0(inpress,:)/))
      end if 
      if (.not.all(ismissing(t1_all(:,pr)))) then
        Ymean(1,pr,re) = avg((/t1_all(:,pr)/))*1.e+09
      end if
      if (.not.all(ismissing(t2_all(:,pr)))) then
        Ymean(2,pr,re) = avg((/t2_all(:,pr)/))*1.e+09
      end if
        Ydiff(:,pr,re) =  Ymean(1:2,pr,re) -  Ymean(0,pr,re) 
        if Ymean(0,pr,re).ne.0 then
         Yreldiff(:,pr,re) =  1 + (Ymean(1:2,pr,re)-Ymean(0,pr,re))/Ymean(0,pr,re) 
        else  
         Yreldiff(:,pr,re) = 0.
        end if
        Ycorr(0,pr,re) = escorc((/val0(inpress,:)/),(/t1_all(:,pr)/))
        Ycorr(1,pr,re) = escorc((/val0(inpress,:)/),(/t2_all(:,pr)/))

        if (compcase.ne."NONE") then
          Ydata(3,1:dimXY-1) = (/t2_all(:,pr)/)*1.e+09     ; model 2 
          Ydata(3,0) = (/t2_all(11,pr)/)*1.e+09     ; model 2 
          Ydata(4,1:dimXY-1) = (/t2r_all(:,pr)/)*1.e+09     ; model 2 
          Ydata(4,0) = (/t2r_all(11,pr)/)*1.e+09     ; model 2 
        end if
;       assign pressure level data (Y)
        Xdata(0,0:dimXY-1) = (/imon13/)  ; raobs
        Xdata(1,0:dimXY-1) = (/imon13/)       ; model 1 
        Xdata(2,0:dimXY-1) = (/imon13/)        ; model 1 
        if (compcase.ne."NONE") then
          Xdata(3,0:dimXY-1) = (/imon13/)       ; model 2 
          Xdata(4,0:dimXY-1) = (/imon13/)      ; model 2 
        end if

      std_mon = (/std0(inpress,:)/)
      val_mon = (/val0(inpress,:)/)
      u_up = val_mon+std_mon
      u_down = val_mon-std_mon 

      ymax1 = max(u_up)
      ymin1 = min(u_down)
      ymax2 = max(Ydata)
      ymin2 = min(Ydata)
      if pr.le.1 then
        ymax = 120.
        ymin = 0.
      else 
        ymax = max((/ymax1,ymax2/))
        ymin = min((/ymin1,ymin2/))
      end if 
      res@trYMaxF =ymax 
      res@trYMinF =ymin 
      

;*****************************************************************
      if (plev_names(pr).eq."900hPa" .or. plev_names(pr).eq."250hPa") then
        res@tiYAxisString = "Ozone (ppb)"
      else
        delete (res@tiYAxisString)
      end if
      res@gsnLeftString = plev_names(pr)

      if (plev_names(pr).eq."500hPa") then
        res@pmLegendDisplayMode    = "Always"
          res@pmLegendSide           = "Right"
      ;  if re.lt.6 .or. re.gt.9 then
          res@pmLegendParallelPosF   =  .15
          res@pmLegendOrthogonalPosF =  -.70
      ;  else
      ;   res@pmLegendParallelPosF   =  .10
      ;   res@pmLegendOrthogonalPosF =  -.70
      ;  end if
      else
        res@pmLegendDisplayMode    = "Never"
      end if
        
      res@gsnDraw = False
      res@gsnFrame = False
      plot(pr) = gsn_csm_xy(wks,Xdata,Ydata,res)  ; create the plot

      polyres = True
    ; error_bar = new(nmons,graphic)
      yt = (/imon/)
      yt!0 = "months"
      do t = 0, nmons-1 
        error_bar(pr,t) = gsn_add_polyline(wks,plot(pr),(/yt(t),yt(t)/),(/u_up(t),u_down(t)/),polyres)
      end do
      delete (res@gsnLeftString)
      delete (Xdata)
      delete (Ydata)
      delete (dimXY)
    ; delete (u_up)
    ; delete (u_down)
    ; delete (std_mon)
    ; delete (val_mon)
      if (compcase.ne."NONE") then
      end if
      
;*****************************************************************
;   ; add mean 
      tres   = True
      tres@txFontHeightF = 0.015
      tres@txFont = 0.015
      tres@txFontColor = "black" 
      tres@txJust        = "CenterLeft"
      if pr.le.2 then
         frac = 0.1
      else 
         frac = 0.05
      end if
      dum = gsn_add_text(wks,plot(pr),"Mean: "+sprintf("%5.1f",(/Ymean(0,pr,re)/)), 4.5,ymax-frac*ymax,tres)
      dum = gsn_add_text(wks,plot(pr),"Abs.Diff:",4.5,ymax-1.5*frac*ymax,tres)
      dum = gsn_add_text(wks,plot(pr),"r:",4.5,ymax-2.*frac*ymax,tres)
      tres@txFontColor = "red" 
      dum = gsn_add_text(wks,plot(pr),sprintf("%5.1f",Ymean(1,pr,re)), 8.,ymax-frac*ymax,tres)
      dum = gsn_add_text(wks,plot(pr),sprintf("%5.2f",Ydiff(0,pr,re)), 8.,ymax-1.5*frac*ymax,tres)
      dum = gsn_add_text(wks,plot(pr),sprintf("%4.2f",Ycorr(0,pr,re)), 8.,ymax-2.*frac*ymax,tres)
  if (compcase .ne. "NONE") then 
      tres@txFontColor = "blue" 
      dum = gsn_add_text(wks,plot(pr),sprintf("%5.1f",Ymean(2,pr,re)), 10.,ymax-frac*ymax,tres)
      dum = gsn_add_text(wks,plot(pr),sprintf("%5.2f",Ydiff(1,pr,re)), 10.,ymax-1.5*frac*ymax,tres)
      dum = gsn_add_text(wks,plot(pr),sprintf("%4.2f",Ycorr(1,pr,re)), 10.,ymax-2.*frac*ymax,tres)
  end if
;*********************************************
  end do           ; loop over pressure
; add lat long info to plot
    txres               = True                   
    txres@txFontHeightF = 0.017                  

;   if (latpt.lt.0) then
;     prntlat = fabs(latpt)+ " S"
;   else
;     prntlat = latpt + " N"
;   end if
;   if (lonpt.gt.180) then
;     prntlon = 360-lonpt + " W"
;   else
;     prntlon = lonpt + " E"
;   end if
    title = region_namesn(re)
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
  ; delete (res@tiXAxisString)
    delete(lonmin)
    delete(latmin)
    delete(lonmax)
    delete(latmax)
    delete(o3press)
    delete(ireg_mons)
    delete (val0)
    delete (std0)
end do               ; loop over regions 
delete(plot)

; add Taylor diagram
;Ymean = new((/3,plevn,nregions/),"float")
;Yreldiff =  new((/2,plevn,nregions/),"float")
;Ycorr = new((/2,plevn,nregions/),"float")
;region_names =(/"nh_polar_west","nh_polar_east","canada","west_europe","eastern_us", \
;             "japan","nh_tropic","tropics1","tropics2","tropics3","sh_midlat","sh_polar","Boulder"/)

  ta_regions =  (/ "Tropics","Mid-Latitudes","High Latitudes"/)
  ta_regionn =  (/ "tropics","midLat","highlat"/)
  ta_nre = dimsizes(ta_regions)


;**********************************
; create plot
;**********************************
  wks = gsn_open_wks(plot_type,wkdir+"cset3_regions_taylor")
  plot = new(12,"graphic")

do tre = 0, ta_nre-1         ;   loop over region
 do tpr= 0, 3                     ; loop over pressure levels 
   l = tpr*3+tre
   if(tre.eq.0) re_index = (/6, 7, 8, 9/)
   end if
   if(tre.eq.1) re_index = (/3, 4, 5, 10/)
   end if
   if(tre.eq.2) re_index = (/0, 1, 2, 11/)
   end if

  ; variables compared
  var1= region_namesn(re_index)
  var = var1(:)
  nVar      = dimsizes(var)                   ; # of Variables
  if (compcase .ne. "NONE") then 
   nCase = 2 
  else 
   nCase = 1
  end if

; "Case A"
  CA_ratio = Yreldiff(0,tpr,re_index)
  CA_cc = Ycorr(0,tpr,re_index)
  A_bias = sum(CA_ratio(:))/nVar

if (compcase .ne. "NONE") then       ; more than one model
; "Case B"
  CB_ratio =  Yreldiff(1,tpr,re_index)
  CB_cc = Ycorr(1,tpr,re_index)
  B_bias = sum(CB_ratio(:))/nVar
end if

; arrays to be passed to taylor plot
  ratio      = new ((/nCase, nVar/),typeof(CA_cc) )
  cc         = new ((/nCase, nVar/),typeof(CA_cc) )
  bias         = new ((/nCase/),typeof(A_bias) )

  ratio(0,:) = CA_ratio
  cc(0,:)    = CA_cc
  bias(0)    = A_bias

if (compcase .ne. "NONE") then       ; more than one model
  ratio(1,:) = CB_ratio
  cc(1,:)    = CB_cc
  bias(1)    = B_bias
end if

  ;**********************************
; create plot
;**********************************


  res   = True                           ; default taylor diagram
  res@tiMainString  = ta_regions(tre)+" "+plev(tpr)
if (compcase .ne. "NONE") then       ; more than one model
  res@Markers      = (/16, 16/)               ; make all solid fill
  res@gsMarkerSizeF = (/0.0055,0.0055/)
  res@Colors       = (/"red", "blue"/)
  res@caseLabels   = (/case1,case2/) 
else
  res@Markers      = (/16/)               ; make all solid fill
  res@gsMarkerSizeF = (/0.0055/)
  res@Colors       = (/"red"/)
  res@caseLabels   = (/case1/) 
end if
  res@varLabels    = var
  res@taylorFrame  = False 
  res@taylorDraw   = False 
  plot(l)  = taylor_diagram_bias(wks,ratio,cc,bias,res)
  end do
end do

   title = "Comparison to Ozonesondes" 
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

end
  printVarSummary(stn_cycle)
