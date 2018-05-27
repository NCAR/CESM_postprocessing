;   profiles_aircraft_noaa.ncl
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
 
 alt10 = ispan(0,9,1)
 nalt10 = 10
 aircraft = (/"SOS1999","TexAQS2000","ITCT2002","NEAQSITCT2004","TexAQS2006","ARCPAC2008","CalNex2010"/)
 monthn = (/"June/July","Aug./Sept","April/May","July/Aug","Sept./Oct.","April","May/June"/)
 monthn1 = (/"JUN","AUG","APR","JUL","SEP","APR","MAY"/)
 monthn2 = (/"JUL","SEP","MAY","AUG","OCT","APR","JUN"/)
 month1 = (/"06","08","04","07","09","04","05"/)
 month2 = (/"07","09","05","08","10","04","06"/)

 year = (/"1999","2000","2002","2004","2006","2008","2010"/)
 region_min_lat =(/32., 28.,  33.,  38., 27.,  64.,  32./)
 region_max_lat =(/40., 35.,  42.,  48., 34.,  75.,  40./)
 region_min_lon =(/-90.,-98.,-125.,-80.,-100.,-170, -125./)
 region_max_lon =(/-80., -94.,-115.,-62.,-92.,-130, -115./)
 region_min_lon = where(region_min_lon.lt.0,360.+region_min_lon,region_min_lon)
 region_max_lon = where(region_max_lon.lt.0,360.+region_max_lon,region_max_lon)
 region_names = (/"Texas","WestCoast","EastCoast","Alaska"/)
 re1 = (/1,2,0,5/)
 re2 = (/4,6,3,5/)
 na = dimsizes(aircraft)
 variable = (/"O3_ppbv","CO_ppbv","SO2_ppbv","NOX_ppbv","NOy_ppbv","PAN_ppbv","C2H2","C2H6","C3H8","OH_ppbv","SAD_TROP","CLOUD"/)     
 variablen = (/"O3","CO","SO2","NOX","NOy","PAN","C2H2","C2H6","C3H8","OH","SAD_TROP","CLOUD"/)              
 specs = (/"o3","co","so2","nox","noy","pan","c2h2","c2h6","ceh8","oh","SAD_TROP","CLOUD"/)              
 vars = (/"O3","CO","SO2","NOX","NOY","PAN","C2H2","C2H6","C3H8","OH","SAD_TROP","CLOUD"/)
 nvar = dimsizes(variable)

 factor = (/1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+12,1.e+06,1./)
 xlog = (/0,0,0,1,0,0,0,0,0,0,0,0/)
 nvars = dimsizes(vars)

 nregions = dimsizes(region_names)
print(region_names)
 
;********************************************************
; define plot generals
;********************************************************
 res                 = True
 res@trYMaxF = 10.0
 res@trYMinF = 0.0
 if (compcase.ne."NONE") then       ; compare 2 models to raobs
   res@xyLineColors    = (/"black","black","red","red","blue","blue"/)
   res@xyLineThicknesses = (/2,1,2,1,2,1/)
   res@xyMarkLineModes   = (/"Lines","Lines","Lines","Lines","Lines","Lines"/)
   res@xyDashPatterns    = (/0,1,0,1,0,1/) 
   res@xyMarkers         = (/0,0,0,0,0,0/)
 else                              ; compare model to raobs
   res@xyLineColors    = (/"black","black","red","red"/)
   res@xyLineThicknesses = (/2,2,2,2/)
   res@xyMarkLineModes   = (/"Lines","Lines","Lines","Lines"/)
   res@xyDashPatterns    = (/0,1,0,1/) 
   res@xyMarkers         = (/0,0,0,0/)
 end if
 res@pmLegendWidthF = 0.15
 res@pmLegendHeightF = 0.22
 res@lgLabelFontHeightF = .022
 res@lgPerimOn = True 
 res@txFontHeightF = 0.022
;*********************************************************************
; get some time and spatially independent data from the model files
 set3_w_1 = 1
 set3_w_2 = 1
file1 = testcase+"_01_climo.nc"
in1 = addfile(file1,"r")
if isfilevar(in1,"PHIS") .and. isfilevar(in1,"Z3") then
 set3_w_1 = 1
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
else
 set3_w_1 = 0
end if
delete (file1)
delete (in1)
if (compcase .ne. "NONE") then       ; more than one model
  file2 = compcase+"_01_climo.nc"
  in2 = addfile(file2,"r")
  if isfilevar(in2,"PHIS") .and. isfilevar(in2,"Z3") then
   set3_w_2 = 1


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
 else
   set3_w_2 = 0
 end if
 delete (file2)
 delete (in2)
else
; res@xyExplicitLegendLabels = (/"Ozonesondes",case1,case2,"Region","Region"/)
end if
if set3_w_1.eq.1 .and. set3_w_2.eq.1 then

;*********************************************************************
; loop over all regions
do re = 0, nregions-1
 ; do not include pole values
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

; define plot
 wks = gsn_open_wks(plot_type,wkdir+"cset5_noaa_"+region_names(re)+"_varprofiles_comp")
  plot = new(12,"graphic")
  error_bar1 = new((/12,nalt10/),graphic)
  error_bar2 = new((/12,nalt10/),graphic)
  error_bar3 = new((/12,nalt10/),graphic)
  error_bar4 = new((/12,nalt10/),graphic)
  error_bar5 = new((/12,nalt10/),graphic)
  do v = 0, nvars-1                 ; loop over vars 
    res@tiXAxisString = variable(v)
    if xlog(v).eq.0 then 
        res@trXAxisType = "LinearAxis"
    else
        res@trXAxisType = "LogAxis"
    end if
   ;res@trXMaxF =xmax(v) 
   ;res@trXMinF =xmin(v)
    if (compcase .ne. "NONE") then       ; more than one model
       res@xyExplicitLegendLabels = (/aircraft(re1(re)),aircraft(re2(re)),monthn1(re1(re))+" "+case1,monthn1(re2(re))+" "+case1,monthn1(re1(re))+" "+case2,monthn1(re2(re))+" "+case2/)
    else
       res@xyExplicitLegendLabels = (/aircraft(re1(re)),aircraft(re2(re)),monthn1(re1(re))+" "+case1,monthn1(re2(re))+" "+case1/)
    end if
   ;  aircraft(re1(re))
   ; open obs data file
  if (vars(v).ne. "OH" .and. vars(v).ne."SAD_TROP" .and. vars(v).ne."CLOUD") then
 ;  dir_in = "/glade/p/acd/tilmes/amwg/amwg_diag_20131004_work/obs_data/aircraft/"
    dir_in = "$OBS_DATA/cam-chem/"
    print(variable(v))
    ;print(dir_in+variablen(v)+aircraft(re1(re))+".nc")
    r1file = dir_in+aircraft(re1(re))+"_"+specs(v)+"_"+region_names(re)+".nc"
    exists = isfilepresent(r1file)
    if(exists) then
     rin1 = addfile(dir_in+aircraft(re1(re))+"_"+specs(v)+"_"+region_names(re)+".nc","r")
     air1_med = rin1->dmed
     air1_p25 = rin1->d25pt
     air1_p75 = rin1->d75pt
    else
     air1_med = new(nalt10,"float") 
     air1_p25 = new(nalt10,"float") 
     air1_p75 = new(nalt10,"float") 
    end if
    if(exists) then
     rin2 = addfile(dir_in+aircraft(re2(re))+"_"+specs(v)+"_"+region_names(re)+".nc","r")
     air2_med = rin2->dmed
     air2_p25 = rin2->d25pt
     air2_p75 = rin2->d75pt
    else
     air2_med = new(nalt10,"float") 
     air2_p25 = new(nalt10,"float") 
     air2_p75 = new(nalt10,"float") 
    end if
  else
   air1_med = new(nalt10,"float") 
   air2_med = new(nalt10,"float") 
   air1_p25 = new(nalt10,"float") 
   air2_p25 = new(nalt10,"float") 
   air1_p75 = new(nalt10,"float") 
   air2_p75 = new(nalt10,"float") 
  end if 
 
;   model data
    file1_r1_m1 = testcase+"_"+month1(re1(re))+"_climo.nc"
    file1_r1_m2 = testcase+"_"+month2(re1(re))+"_climo.nc"
    file1_r2_m1 = testcase+"_"+month1(re2(re))+"_climo.nc"
    file1_r2_m2 = testcase+"_"+month2(re2(re))+"_climo.nc"
    in1_r1_m1 = addfile(file1_r1_m1,"r")
    in1_r1_m2 = addfile(file1_r1_m2,"r")
    in1_r2_m1 = addfile(file1_r2_m1,"r")
    in1_r2_m2 = addfile(file1_r2_m2,"r")
      if (compcase.ne."NONE") then
        file2_r1_m1 = compcase+"_"+month1(re1(re))+"_climo.nc"
        file2_r1_m2 = compcase+"_"+month2(re1(re))+"_climo.nc"
        file2_r2_m1 = compcase+"_"+month1(re2(re))+"_climo.nc"
        file2_r2_m2 = compcase+"_"+month2(re2(re))+"_climo.nc"
        in2_r1_m1 = addfile(file2_r1_m1,"r")
        in2_r1_m2 = addfile(file2_r1_m2,"r")
        in2_r2_m1 = addfile(file2_r2_m1,"r")
        in2_r2_m2 = addfile(file2_r2_m2,"r")
      end if
;     get model 1 altitude data
      alt_mo1_re1_m1 = in1_r1_m1->Z3           ; altitude (time,alt,lat,lon) 
      alt_mo1_re1_m2 = in1_r1_m2->Z3                                         
      phis = in1_r1_m1->PHIS   ; (time,lat,lon)
      alt_local = (conform_dims(dimsizes(alt_mo1_re1_m1),phis,(/0,2,3/))/9.81)
      alt_mo1_re1_m1 = alt_mo1_re1_m1-alt_local
      phis = in1_r1_m2->PHIS   ; (time,lat,lon)
      alt_local = (conform_dims(dimsizes(alt_mo1_re1_m2),phis,(/0,2,3/))/9.81)
      alt_mo1_re1_m2 = alt_mo1_re1_m2-alt_local
      alt_mo1_re1 = dim_avg_n_Wrap( array_append_record(alt_mo1_re1_m1,alt_mo1_re1_m2,0), 0 )

      alt_mo1_re2_m1 = in1_r2_m1->Z3           ; altitude (time,alt,lat,lon) 
      alt_mo1_re2_m2 = in1_r2_m2->Z3                                         
      phis = in1_r2_m1->PHIS   ; (time,lat,lon)
      alt_local = (conform_dims(dimsizes(alt_mo1_re2_m1),phis,(/0,2,3/))/9.81)
      alt_mo1_re2_m1 = alt_mo1_re2_m1-alt_local
      phis = in1_r2_m2->PHIS   ; (time,lat,lon)
      alt_local = (conform_dims(dimsizes(alt_mo1_re2_m2),phis,(/0,2,3/))/9.81)
      alt_mo1_re2_m2 = alt_mo1_re2_m2-alt_local
      alt_mo1_re2 = dim_avg_n_Wrap( array_append_record(alt_mo1_re2_m1,alt_mo1_re2_m2,0), 0 )
      delete(alt_local)

;     get model variable data 
      tr1_1 = new(nlev1,"float") 
      tr1_1!0 =  "lev" 
      tr2_1 = new(nlev1,"float") 
      tr2_1!0 =  "lev" 

      zr1_1 = new(nlev1,"float") 
      zr1_1!0 =  "lev" 
      zr2_1 = new(nlev1,"float") 
      zr2_1!0 =  "lev" 
      zr1_1(:) = 0.
      zr2_1(:) = 0.
      if isfilevar(in1_r1_m1, vars(v)) then 
         var_mo1_re1_m1 = in1_r1_m1->$vars(v)$    ; altitude (time,alt,lat,lon) 
         var_mo1_re1_m2 = in1_r1_m2->$vars(v)$                                  
         var_mo1_re1 = dim_avg_n_Wrap( array_append_record(var_mo1_re1_m1,var_mo1_re1_m2,0), 0 )
         var_mo1_re2_m1 = in1_r2_m1->$vars(v)$    ; altitude (time,alt,lat,lon) 
         var_mo1_re2_m2 = in1_r2_m2->$vars(v)$                                  
         var_mo1_re2 = dim_avg_n_Wrap( array_append_record(var_mo1_re2_m1,var_mo1_re2_m2,0), 0 )
        if (typeof(var_mo1_re1).eq."double") then
          var_mo1_re1 = dble2flt(var_mo1_re1)
          var_mo1_re2 = dble2flt(var_mo1_re2)
        end if
       if vars(v).eq."SO2" then
        ; convert mmr to  kg/kg
         if var_mo1_re1@units.ne."kg/kg" then
          var_mo1_re1= var_mo1_re1* 64./28.97
          var_mo1_re2= var_mo1_re2* 64./28.97
         end if
        end if
        t1r1 = var_mo1_re1(:,{latmin:latmax},{lonmin:lonmax})
        t1r2 = var_mo1_re2(:,{latmin:latmax},{lonmin:lonmax})
        z1r1 = alt_mo1_re1(:,{latmin:latmax},{lonmin:lonmax})
        z1r2 = alt_mo1_re2(:,{latmin:latmax},{lonmin:lonmax})
  ;   average over lon/lat
        tr1_1 = dim_avg_n_Wrap(t1r1,(/1,2/))
        tr2_1 = dim_avg_n_Wrap(t1r2,(/1,2/))
        zr1_1 = dim_avg_n_Wrap(z1r1,(/1,2/))
        zr2_1 = dim_avg_n_Wrap(z1r2,(/1,2/))
        delete(t1r1)
        delete(t1r2)
        delete(z1r1)
        delete(z1r2)
      else 
        if vars(v) .eq. "NOX" .and. isfilevar(in1_r1_m1, "NO") .and. isfilevar(in1_r1_m1, "NO2") then 
           var_mo1_re1_m11 = in1_r1_m1->NO    ; altitude (time,alt,lat,lon)
           var_mo1_re1_m12 = in1_r1_m1->NO2    ; altitude (time,alt,lat,lon)
           var_mo1_re1_m21 = in1_r1_m2->NO
           var_mo1_re1_m22 = in1_r1_m2->NO2
           var_mo1_re1_m1=var_mo1_re1_m11
           var_mo1_re1_m2=var_mo1_re1_m12
           var_mo1_re1_m1=var_mo1_re1_m11+var_mo1_re1_m12
           var_mo1_re1_m2=var_mo1_re1_m21+var_mo1_re1_m22
           
           delete(var_mo1_re1_m11)
           delete(var_mo1_re1_m12)
           delete(var_mo1_re1_m21)
           delete(var_mo1_re1_m22)
           var_mo1_re1 = dim_avg_n_Wrap( array_append_record(var_mo1_re1_m1,var_mo1_re1_m2,0), 0 )
           var_mo1_re2_m11 = in1_r2_m1->NO    ; altitude (time,alt,lat,lon)
           var_mo1_re2_m12 = in1_r2_m1->NO2    ; altitude (time,alt,lat,lon)
           var_mo1_re2_m21 = in1_r2_m2->NO
           var_mo1_re2_m22 = in1_r2_m2->NO2
           var_mo1_re2_m1=var_mo1_re2_m11
           var_mo1_re2_m2=var_mo1_re2_m12
           var_mo1_re2_m1=var_mo1_re2_m11+var_mo1_re2_m12
           var_mo1_re2_m2=var_mo1_re2_m21+var_mo1_re2_m22
           delete(var_mo1_re2_m11)
           delete(var_mo1_re2_m12)
           delete(var_mo1_re2_m21)
           delete(var_mo1_re2_m22)
           var_mo1_re2 = dim_avg_n_Wrap( array_append_record(var_mo1_re2_m1,var_mo1_re2_m2,0), 0 )
           if (typeof(var_mo1_re1).eq."double") then
              var_mo1_re1 = dble2flt(var_mo1_re1)
              var_mo1_re2 = dble2flt(var_mo1_re2)
            end if
            t1r1 = var_mo1_re1(:,{latmin:latmax},{lonmin:lonmax})
            t1r2 = var_mo1_re2(:,{latmin:latmax},{lonmin:lonmax})
            z1r1 = alt_mo1_re1(:,{latmin:latmax},{lonmin:lonmax})
            z1r2 = alt_mo1_re2(:,{latmin:latmax},{lonmin:lonmax})
        ;   average over lon/lat
            tr1_1 = dim_avg_n_Wrap(t1r1,(/1,2/))
            tr2_1 = dim_avg_n_Wrap(t1r2,(/1,2/))
            zr1_1 = dim_avg_n_Wrap(z1r1,(/1,2/))
            zr2_1 = dim_avg_n_Wrap(z1r2,(/1,2/))
            delete(t1r1)
            delete(t1r2)
            delete(z1r1)
            delete(z1r2)
        end if
       end if

;     get model 2 pressure data 
    if (compcase.ne."NONE") then
      alt_mo2_re1_m1 = in2_r1_m1->Z3           ; altitude (time,alt,lat,lon)
      alt_mo2_re1_m2 = in2_r1_m2->Z3                                 
      phis = in2_r1_m1->PHIS   ; (time,lat,lon)
      alt_local = (conform_dims(dimsizes(alt_mo2_re1_m1),phis,(/0,2,3/))/9.81)
      alt_mo2_re1_m1 = alt_mo2_re1_m1-alt_local
      phis = in2_r1_m2->PHIS   ; (time,lat,lon)
      alt_local = (conform_dims(dimsizes(alt_mo2_re1_m2),phis,(/0,2,3/))/9.81)
      alt_mo2_re1_m2 = alt_mo2_re1_m2-alt_local

      alt_mo2_re1 = dim_avg_n_Wrap( array_append_record(alt_mo2_re1_m1,alt_mo2_re1_m2,0), 0 )
      alt_mo2_re2_m1 = in2_r2_m1->Z3           ; altitude (time,alt,lat,lon)
      alt_mo2_re2_m2 = in2_r2_m2->Z3
      phis = in2_r2_m1->PHIS   ; (time,lat,lon)
      alt_local = (conform_dims(dimsizes(alt_mo2_re2_m1),phis,(/0,2,3/))/9.81)
      alt_mo2_re2_m1 = alt_mo2_re2_m1-alt_local
      phis = in2_r2_m2->PHIS   ; (time,lat,lon)
      alt_local = (conform_dims(dimsizes(alt_mo2_re2_m2),phis,(/0,2,3/))/9.81)
      alt_mo2_re2_m2 = alt_mo2_re2_m2-alt_local
      alt_mo2_re2 = dim_avg_n_Wrap( array_append_record(alt_mo2_re2_m1,alt_mo2_re2_m2,0), 0 )
      delete(alt_local)

;     get model variable data
       tr1_2 = new(nlev2,"float") 
       tr1_2!0 =  "lev" 
       tr2_2 = new(nlev2,"float") 
       tr2_2!0 =  "lev" 
       zr1_2 = new(nlev2,"float")
       zr1_2!0 =  "lev"
       zr2_2 = new(nlev2,"float")
       zr2_2!0 =  "lev"
       zr1_2(:) = 0.
       zr2_2(:) = 0.
      if isfilevar(in2_r1_m1, vars(v)) then
         var_mo2_re1_m1 = in2_r1_m1->$vars(v)$    ; altitude (time,alt,lat,lon)
         var_mo2_re1_m2 = in2_r1_m2->$vars(v)$
         var_mo2_re1 = dim_avg_n_Wrap( array_append_record(var_mo2_re1_m1,var_mo2_re1_m2,0), 0 )
         var_mo2_re2_m1 = in2_r2_m1->$vars(v)$    ; altitude (time,alt,lat,lon)
         var_mo2_re2_m2 = in2_r2_m2->$vars(v)$
         var_mo2_re2 = dim_avg_n_Wrap( array_append_record(var_mo2_re2_m1,var_mo2_re2_m2,0), 0 )
        if (typeof(var_mo2_re1).eq."double") then
          var_mo2_re1 = dble2flt(var_mo2_re1)
          var_mo2_re2 = dble2flt(var_mo2_re2)
        end if
       if vars(v).eq."SO2" then
        ; convert mmr to  kg/kg
         if var_mo2_re1@units.ne."kg/kg" then
          var_mo2_re1= var_mo2_re1* 64./28.97
          var_mo2_re2= var_mo2_re2* 64./28.97
         end if
        end if
        t2r1 = var_mo2_re1(:,{latmin:latmax},{lonmin:lonmax})
        t2r2 = var_mo2_re2(:,{latmin:latmax},{lonmin:lonmax})
        z2r1 = alt_mo2_re1(:,{latmin:latmax},{lonmin:lonmax})
        z2r2 = alt_mo2_re2(:,{latmin:latmax},{lonmin:lonmax})
  ;   average over lon/lat
      printVarSummary(t2r1)
      printVarSummary(tr1_2)
        tr1_2 = dim_avg_n_Wrap(t2r1,(/1,2/))
        tr2_2 = dim_avg_n_Wrap(t2r2,(/1,2/))
        zr1_2 = dim_avg_n_Wrap(z2r1,(/1,2/))
        zr2_2 = dim_avg_n_Wrap(z2r2,(/1,2/))
        delete(t2r1)
        delete(t2r2)
        delete(z2r1)
        delete(z2r2)
     else 
      if vars(v) .eq. "NOX" .and. isfilevar(in2_r1_m1, "NO") .and. isfilevar(in2_r1_m1, "NO2") then
           var_mo2_re1_m11 = in2_r1_m1->NO    ; altitude (time,alt,lat,lon)
           var_mo2_re1_m12 = in2_r1_m1->NO2    ; altitude (time,alt,lat,lon)
           var_mo2_re1_m21 = in2_r1_m2->NO
           var_mo2_re1_m22 = in2_r1_m2->NO2
           var_mo2_re1_m1=var_mo2_re1_m11
           var_mo2_re1_m2=var_mo2_re1_m12
           var_mo2_re1_m1=var_mo2_re1_m11+var_mo2_re1_m12
           var_mo2_re1_m2=var_mo2_re1_m21+var_mo2_re1_m22
           delete(var_mo2_re1_m11)
           delete(var_mo2_re1_m12)
           delete(var_mo2_re1_m21)
           delete(var_mo2_re1_m22)
           var_mo2_re2_m11 = in2_r2_m1->NO    ; altitude (time,alt,lat,lon)
           var_mo2_re2_m12 = in2_r2_m1->NO2    ; altitude (time,alt,lat,lon)
           var_mo2_re2_m21 = in2_r2_m2->NO
           var_mo2_re2_m22 = in2_r2_m2->NO2
           var_mo2_re2_m1=var_mo2_re2_m11
           var_mo2_re2_m2=var_mo2_re2_m12
           var_mo2_re2_m1=var_mo2_re2_m11+var_mo2_re2_m12
           var_mo2_re2_m2=var_mo2_re2_m21+var_mo2_re2_m22
           delete(var_mo2_re2_m11)
           delete(var_mo2_re2_m12)
           delete(var_mo2_re2_m21)
           delete(var_mo2_re2_m22)
           var_mo2_re2 = dim_avg_n_Wrap( array_append_record(var_mo2_re2_m1,var_mo2_re2_m2,0), 0 )

           if (typeof(var_mo2_re1).eq."double") then
             var_mo2_re1 = dble2flt(var_mo2_re1)
             var_mo2_re2 = dble2flt(var_mo2_re2)
           end if
           t2r1 = var_mo2_re1(:,{latmin:latmax},{lonmin:lonmax})
           t2r2 = var_mo2_re2(:,{latmin:latmax},{lonmin:lonmax})
           z2r1 = alt_mo2_re1(:,{latmin:latmax},{lonmin:lonmax})
           z2r2 = alt_mo2_re2(:,{latmin:latmax},{lonmin:lonmax})
     ;   average over lon/lat
           tr1_2 = dim_avg_n_Wrap(t2r1,(/1,2/))
           tr2_2 = dim_avg_n_Wrap(t2r2,(/1,2/))
           zr1_2 = dim_avg_n_Wrap(z2r1,(/1,2/))
           zr2_2 = dim_avg_n_Wrap(z2r2,(/1,2/))
      end if
     end if
   end if


;---------------------------------------------------------------------
     if (compcase.ne."NONE") then
          dimXY = (/nalt10,nalt10,nlev1,nlev1,nlev2,nlev2/)
          nMax = max(dimXY)
          Xdata = new((/6,nMax/),"float")
          Ydata = new((/6,nMax/),"float")
          Xp25 = new((/2,nMax/),"float")
          Xp75 = new((/2,nMax/),"float")
     else
          dimXY = (/nalt10,nalt10,nlev1,nlev1/)
          nMax = max(dimXY)
          Xdata = new((/6,nMax/),"float")
          Ydata = new((/6,nMax/),"float")
          Xp25 = new((/2,nMax/),"float")
          Xp75 = new((/2,nMax/),"float")
     end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"
        Xp25!0 = "line"
        Xp75!1 = "lev"

        if v.ge.6 .and. v.le.8 then
         factor_air = 1.e-03
        else
         factor_air = 1.
        end if
        if re.eq.2 then
         factor_air = 1.
        end if
    
;       assign tracer data (X) 
        Xdata(0,0:dimXY(0)-1) = (/air1_med/)*factor_air
        Xdata(1,0:dimXY(1)-1) = (/air2_med/)*factor_air
        Xp25(0,0:dimXY(0)-1) = (/air1_p25/)*factor_air
        Xp75(0,0:dimXY(0)-1) = (/air1_p75/)*factor_air
        Xp25(1,0:dimXY(1)-1) = (/air2_p25/)*factor_air
        Xp75(1,0:dimXY(1)-1) = (/air2_p75/)*factor_air

;       model ozone data (X)
        Xdata(2,0:dimXY(2)-1) = (/tr1_1/)*factor(v)       ; model 1 
        Xdata(3,0:dimXY(3)-1) = (/tr2_1/)*factor(v)    ; model 1 
        if (compcase.ne."NONE") then
          Xdata(4,0:dimXY(4)-1) = (/tr1_2/)*factor(v)  ; model 2 
          Xdata(5,0:dimXY(5)-1) = (/tr2_2/)*factor(v)  ; model 2 
        end if
;       assign altitude level data (Y)
        Ydata(0,0:dimXY(0)-1) = (/alt10/)   ; raobs
        Ydata(1,0:dimXY(1)-1) = (/alt10/)   ; raobs
        Ydata(2,0:dimXY(2)-1) = (/zr1_1/)*1e-03         ; model 1 
        Ydata(3,0:dimXY(3)-1) = (/zr2_1/)*1e-03         ; model 1 
        if (compcase.ne."NONE") then
          Ydata(4,0:dimXY(4)-1) = (/zr1_2/)*1e-03       ; model 2 
          Ydata(5,0:dimXY(5)-1) = (/zr2_2/)*1e-03       ; model 2 
        end if

     inp0 = ind(Ydata(0,:) .le.12)
     inp1 = ind(Ydata(1,:) .le.12)
     inp2 = ind(Ydata(2,:) .le.12)
     inp3 = ind(Ydata(3,:) .le.12)
    if (compcase.ne."NONE") then
     inp4 = ind(Ydata(4,:) .le.12)
     inp5 = ind(Ydata(5,:) .le.12)
    end if
    if (compcase.ne."NONE") then
     xmax = max((/max(Xdata(0,inp0)),max(Xdata(1,inp1)),max(Xdata(2,inp2)),max(Xdata(3,inp3)),max(Xdata(4,inp4)),max(Xdata(5,inp5))/))
     xmin = min((/min(Xdata(0,inp0)),min(Xdata(1,inp1)),min(Xdata(2,inp2)),min(Xdata(3,inp3)),min(Xdata(4,inp4)),min(Xdata(5,inp5))/))
    else
     xmax = max((/max(Xdata(0,inp0)),max(Xdata(1,inp1)),max(Xdata(2,inp2)),max(Xdata(3,inp3))/))
     xmin = min((/min(Xdata(0,inp0)),min(Xdata(1,inp1)),min(Xdata(2,inp2)),min(Xdata(3,inp3))/))
    end if
     res@trXMaxF =xmax
     res@trXMinF =xmin
     delete (inp0)
     delete (inp1)
     delete (inp2)
     delete (inp3)
    if (compcase.ne."NONE") then
     delete (inp4)
     delete (inp5)
    end if
;*****************************************************************
     res@tiYAxisString = "Altitude (km)"
      if (vars(v).eq."O3" .or. vars(v).eq."SO2" .or. vars(v).eq."PAN") then
        res@tiYAxisString = "Altitude (km)"
      else
        delete (res@tiYAxisString)
      end if
      res@gsnLeftString = variable(v)

      if (vars(v).eq."SO2") then
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

      polyres = True
      polyres@NhlRemovePrimitive=-1 

      do t = 0, nalt10-1 
        if (.not.all(ismissing(Xp25(0,t))) .and. .not.all(ismissing(Xp75(0,t)))) then
        error_bar1(v,t) = gsn_add_polyline(wks,plot(v),(/Xp25(0,t),Xp75(0,t)/),(/alt10(t)+0.1,alt10(t)+0.1/),polyres)
        error_bar2(v,t) = gsn_add_polyline(wks,plot(v),(/Xp25(0,t),Xp75(0,t)/),(/alt10(t)-0.1,alt10(t)-0.1/),polyres)
        error_bar3(v,t) = gsn_add_polyline(wks,plot(v),(/Xp25(0,t),Xp25(0,t)/),(/alt10(t)-0.1,alt10(t)+0.1/),polyres)
        error_bar4(v,t) = gsn_add_polyline(wks,plot(v),(/Xp75(0,t),Xp75(0,t)/),(/alt10(t)-0.1,alt10(t)+0.1/),polyres)
        error_bar5(v,t) = gsn_add_polyline(wks,plot(v),(/Xp25(1,t),Xp75(0,t)/),(/alt10(t),alt10(t)/),polyres)
        end if
      end do
      delete (res@gsnLeftString)
      delete (res@trXMaxF) 
      delete (res@trXMinF) 
      delete (xmax)
      delete (xmin)
      delete (Xdata)
      delete (Ydata)
      delete (Xp25)
      delete (Xp75)
      delete (dimXY)
      delete (nMax)
      if (compcase.ne."NONE") then
      end if
    end do           ; loop over vars 

;*********************************************
; add lat long info to plot
    txres               = True                   
    txres@txFontHeightF = 0.017                  
    title = region_names(re)
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
    delete(lonmin)
    delete(latmin)
    delete(lonmax)
    delete(latmax)
end do               ; loop over regions 
else
print("not calculated")
end if

end
