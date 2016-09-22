; NCL script
; plot_vertical_zonal_mean_chem.ncl
; Simone Tilmes, Nov 2013
;**************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH
load "$DIAG_CODE/functions_contrib.ncl"
;load "$DIAG_CODE/functions_vertical.ncl"

begin
 compare    = getenv("COMPARE")
 plot_type  = getenv("PLOTTYPE")
 color_type = getenv("COLORTYPE")
 rgb_file   = getenv("RGB_FILE")
 season     = getenv("SEASON")
 version    = getenv("DIAG_VERSION")
 wkdir      = getenv("WKDIR")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename

; plot per season
;print(infile1)
; CASE 1 MODEL
 inptr1 = addfile(infile1,"r")

; if (ncdf_mode .eq. "write") then
;   outptr1 = addfile(outfile1,"w")
; else
;   outptr1 = addfile(outfile1,"c")
; end if

 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case           ; case name
 end if
 case1 = str_strip(case1)

 if (isatt(inptr1,"yrs_averaged")) then
   yrs_ave1 = inptr1@yrs_averaged
 end if

 tmp = inptr1->lat
 if (typeof(tmp).eq."double") then
   lat1 = dble2flt(tmp)
 else
   lat1 = tmp
 end if
 delete(tmp)
 lev1 = inptr1->lev
 lon1 = inptr1->lon
 nlat1 = dimsizes(lat1)
 nlon1 = dimsizes(lon1)
 nlev1 = dimsizes(lev1)
 tmp = inptr1->PS
 if (typeof(tmp).eq."double") then
        ps1 = dble2flt(tmp)
 else
     ps1 = tmp
 end if
 delete(tmp)
 t1 = inptr1->T
 t1s = t1(0,nlev1-1,:,:)
 rho1   = ps1(0,:,:)/(287.04*t1s)
 nca = 1
 delete(t1s)
 delete(ps1)
 
;print("FILE2"+infile2)
; CASE 2 IS OBS OR MODEL
 if (compare .eq. "OBS") then
 else                        ;  CASE 2 IS MODEL
   inptr2 = addfile(infile2,"r")
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case
   end if
   if (isatt(inptr2,"yrs_averaged")) then
     yrs_ave2 = inptr2@yrs_averaged
   end if
   tmp = inptr2->lat
   if (typeof(tmp).eq."double") then
     lat2 = dble2flt(tmp)
   else
     lat2 = tmp
   end if
   delete(tmp)
   nlat2 = dimsizes(lat2)
   lev2 = inptr2->lev
   lon2 = inptr2->lon
   nlon2 = dimsizes(lon2)
   nlev2 = dimsizes(lev2)
   tmp = inptr2->PS
    if (typeof(tmp).eq."double") then
        ps2 = dble2flt(tmp)
   else
     ps2 = tmp
   end if
   delete(tmp)
   t2 = inptr2->T
   t2s = t2(0,nlev2-1,:,:)
   rho2   = ps2(0,:,:)/(287.04*t2s)
   delete(t2s)
   delete(ps2)
   nca = 2
 end if
 vars =(/"SO2","SO4","BC","OC","NH4NO3"/)
 varsn =(/"SO~B~2~N~","SO~B~4~N~","BC","OC","NH~B~4~N~NO~B~3~N~"/)
 vars_data =(/"so2","so4","ec","oc","nh4no3"/)
 data_n =(/"SO2_","SO4_","EC_","OC_","NH4NO3_"/)
 vars_units = (/"ppb","ug/m~S~3~N~","ug/m~S~3~N~","ug/m~S~3~N~","ug/m~S~3~N~"/)
;qmin = (/0.01,0.01,0.005
;qmax = (/5.,   10.,
 nvars = dimsizes(vars)

; plot per variable
; each plot includes scatter plot (seasonal mean)
 lat_obs_all = new((/nvars,500/), float)
 lat_obs_all@_FillValue = -999.
 lat_obs_all(:,:) = lat_obs_all@_FillValue 
 lon_obs_all = new((/nvars,500/), float)
 lon_obs_all@_FillValue = -999.
 lon_obs_all(:,:) = lon_obs_all@_FillValue
 stn_ann_avg_obs = new((/nvars,500/), double)
 stn_ann_avg_obs@_FillValue = -999.
 stn_ann_avg_obs(:,:) = stn_ann_avg_obs@_FillValue 
 stn_ann_avg_mod1 = new((/nvars,500/), double)
 stn_ann_avg_mod1@_FillValue = -999.
 stn_ann_avg_mod1(:,:) = stn_ann_avg_mod1@_FillValue 

 if (compare .eq. "OBS") then
 else                        ;  CASE 2 IS MODEL
  stn_ann_avg_mod2 = new((/nvars,500/), double)
  stn_ann_avg_mod2@_FillValue = -999.
  stn_ann_avg_mod2(:,:) = stn_ann_avg_mod2@_FillValue 
 end if

; calculate plotting values
do i = 0, nvars-2
  if (compare .eq. "OBS") then
   nca = 1
  else                        ;  CASE 2 IS MODEL
   nca = 2
  ; go through 2 cases
  end if
  do ca = 0, nca-1
   if ca.eq.0 then
    inptr = inptr1
    nlev = nlev1
    nlat = nlat1
    nlon = nlon1
    var1 = new((/nlat,nlon/),"float") 
    var1@_FillValue = -999 
   else
    inptr = inptr2
    nlev = nlev2
    nlat = nlat2
    nlon = nlon2
    var2 = new((/nlat,nlon/),"float") 
    var2@_FillValue = -999 
   end if
  var11 = new((/nlat,nlon/),"float") 
  var11@_FillValue = -999 

  varsoa = -1
   if vars(i).eq."SO2" then
     if (isfilevar(inptr,"SO2") ) then
        delete(varsoa)
        varsoa = (/"SO2"/)
      end if
   end if
   if vars(i).eq."SO4" then
         if (isfilevar(inptr,"SO4") ) then
         delete(varsoa)
          varsoa = (/"SO4"/)
         else
          delete(varsoa)
          varsoa = (/"so4_a1","so4_a2","so4_a3"/)
         end if
    end if
    if vars(i).eq."BC" then
         if (isfilevar(inptr,"CB1") .and. isfilevar(inptr,"CB2")) then
          delete(varsoa)
          varsoa = (/"CB1","CB2"/)
         else
           if (isfilevar(inptr,"bc_a1")) then
            delete(varsoa)
            varsoa = (/"bc_a1"/)
           end if
           if (isfilevar(inptr,"bc_a1") .and. isfilevar(inptr,"bc_a4")) then
            delete(varsoa)
            varsoa = (/"bc_a1","bc_a4"/)
           end if
           if (isfilevar(inptr,"bc_a1") .and. isfilevar(inptr,"bc_a3")) then
            delete(varsoa)
            varsoa = (/"bc_a1","bc_a3"/)
           end if
         end if
   end if
   varsoa1 = -1
   varsoa2 = -1
   if vars(i).eq."OC" then
         if (isfilevar(inptr,"OC1") .and. isfilevar(inptr,"OC2")) then
          delete(varsoa1)
          varsoa1 = (/"OC1","OC2"/)
         else
           if (isfilevar(inptr,"pom_a1")) then
            delete(varsoa1)
            varsoa1 = (/"pom_a1"/)
           end if
           if (isfilevar(inptr,"pom_a1") .and. isfilevar(inptr,"pom_a4")) then
            delete(varsoa1)
            varsoa1 = (/"pom_a1","pom_a4"/)
           end if
           if (isfilevar(inptr,"pom_a1") .and. isfilevar(inptr,"pom_a3")) then
            delete(varsoa1)
            varsoa1 = (/"pom_a1","pom_a3"/)
           end if
         end if
        ; function SOA Colette
        if (isfilevar(inptr,"SOAI") .and. isfilevar(inptr,"SOAT") .and. isfilevar(inptr,"SOAB") .and. isfilevar(inptr,"SOAX") .and. isfilevar(inptr,"SOAM")) then
          delete(varsoa2)
          varsoa2 = (/"SOAI","SOAT","SOAB","SOAX","SOAM"/)
        else 
          if (isfilevar(inptr,"soa_a1") .and. isfilevar(inptr,"soa_a2")) then
            delete(varsoa2)
            varsoa2 =  (/"soa_a1","soa_a2"/)
          else 
            if (isfilevar(inptr,"SOA")) then
                delete(varsoa2)
                varsoa2 =  (/"SOA"/)
            end if
          end if
        end if
        delete(varsoa)
        varsoa = array_append_record(varsoa1,varsoa2,0)
        delete(varsoa1)
        delete(varsoa2)
   end if
   if vars(i).eq."NH4NO3" then
        if (isfilevar(inptr,"NH4NO3")) then
          delete(varsoa)
          varsoa = (/"NH4NO3"/)
        else
          delete(varsoa)
          varsoa = (/""/)
         end if
   end if

  
 if varsoa(0) .ne. -1 then  
   nvarsoa = dimsizes(varsoa)
   do si = 0, nvarsoa-1
    if (isfilevar(inptr,varsoa(si))) then
      vinta = (/varsoa(si)/)      
      var11a =inptr->$vinta$
      var11 = var11a(0,nlev-1,:,:)
      delete(var11a)
      if vars(i).eq."SO2" then
        ; convert mmr to  kg/kg
        var11 = var11* 64./28.97 
      end if
      if vars(i).eq."SO4" .and. (vinta .eq. "so4_a1" .or. vinta .eq. "so4_a2" .or. vinta .eq. "so4_3") then 
         var11 = var11*96.06/115.11  ; adjust that SO4 is really SO4NO3
      end if
      if vars(i).eq."pom_a1" then
        var11 = var11* 0.714286 
      end if
;     if vars(i).eq."SOA" .and. (vinta .eq. "SOAI" .or. vinta .eq. "SOAM" .or. vinta .eq. "SOAB" .or. vinta .eq. "SOAT" .or. vinta .eq. "SOAX") then 
;         var11 = var11*mwsoa_c(si)/mwsoa(si) 
    else
     var11 = var11@_FillValue 
    end if
   if ca.eq.0 then
     if si.eq.0 then
      var1 = var11
     else
      var1 = var1 + var11
     end if
   else
     if si.eq.0 then
      var2 = var11
     else
      var2 = var2 + var11
     end if
   end if
   end do ;si
  end if
  delete(varsoa)
  delete(var11)
 end do ; ca
 var1 = var1 * rho1 * 1.e9 ; convert from kg/kg to ug/m3 ; ppb for SO2
 var1@_FillValue = -999 
 var1!0 = "lat"
 var1!1 = "lon"
 var1&lon= lon1 
 var1&lat= lat1 


 if (compare .eq. "OBS") then
 else                        ;  CASE 2 IS MODEL
 var2 = var2 * rho2 * 1.e9 ; convert from kg/kg to ug/m3
 var2!0 = "lat"
 var2!1 = "lon"
 var2&lon= lon2 
 var2&lat= lat2 
 var2@_FillValue = -999 
 end if


; load data and interpolate model to station location
;dir = "$OBS_DATA/cam-chem/"
  
 stn_name = systemfunc("ls $OBS_DATA/cam-chem/"+data_n(i)+"IMPROVE*nc")
 do nstn=0,dimsizes(stn_name)-1
     file_name = stn_name(nstn)
     in = addfile(file_name,"r")
     var_obs  = in->$vars_data(i)$
     date_obs = in->date
     lat_obs  = in->lat(0) 
     lon_obs  = in->lon(0)
     if ( lon_obs .lt. 0 )
        lon_obs = lon_obs + 360.
     end if
     lat_obs_all(i,nstn) = lat_obs
     lon_obs_all(i,nstn) = lon_obs
     year_obs = date_obs/10000
     date_obs = date_obs - year_obs * 10000
     mon_obs  = date_obs/100
     day_obs  = date_obs - mon_obs * 100
;
     if ( lon_obs .gt. max(lon1) )
        var_1_stn = var1({lat_obs},0)
     else
        var_1_stn = var1({lat_obs},{lon_obs})
     end if

     if (compare .eq. "OBS") then
     else                        ;  CASE 2 IS MODEL
       if ( lon_obs .gt. max(lon2) )
          var_2_stn = var2({lat_obs},0)
        else                        ;  CASE 2 IS MODEL
          var_2_stn = var2({lat_obs},{lon_obs})
        end if
     end if
     
    if season.eq."ANN" then
      stn_ann_avg_obs(i,nstn) = dim_avg(var_obs)
    else
     if season.eq."DJF" then
      index_se = ind(mon_obs.le.2.or.mon_obs.eq.12)
     end if
     if season.eq."MAM" then
      index_se = ind(mon_obs.ge.3.and.mon_obs.le.5)
     end if 
     if season.eq."JJA" then
      index_se = ind(mon_obs.ge.6.and.mon_obs.le.8)
     end if 
     if season.eq."SON" then
      index_se = ind(mon_obs.le.9.or.mon_obs.eq.11)
     end if
     if dimsizes(index_se) .gt.1 then 
      stn_ann_avg_obs(i,nstn) = dim_avg(var_obs(index_se))
     else
      stn_ann_avg_obs(i,nstn) = stn_ann_avg_obs@_FillValue
     end if
     delete(index_se)
    end if
    if (.not.all(ismissing(var_1_stn))) then
     stn_ann_avg_mod1(i,nstn) = dim_avg(var_1_stn)
    else
      stn_ann_avg_mod1(i,nstn) = stn_ann_avg_mod1@_FillValue
    end if
    if (compare .eq. "OBS") then
    else                        ;  CASE 2 IS MODEL
     if (.not.all(ismissing(var_2_stn))) then
      stn_ann_avg_mod2(i,nstn) = dim_avg(var_2_stn)
     else
       stn_ann_avg_mod2(i,nstn) = stn_ann_avg_mod2@_FillValue
     end if
    end if
    delete(var_obs)
    delete(date_obs)
    delete(year_obs)
    delete(mon_obs)
    delete(day_obs)
    delete(var_1_stn)
    if (compare .eq. "OBS") then
    else                        ;  CASE 2 IS MODEL
        delete(var_2_stn)
    end if
  end do
  delete(stn_name)
  delete(var1)
    if (compare .ne. "OBS") then
        delete(var2)
    end if
 end do
 stn_ann_avg_obs = where(stn_ann_avg_obs.le.0,stn_ann_avg_obs@_FillValue,stn_ann_avg_obs)
 stn_ann_avg_mod1 = where(stn_ann_avg_mod1.le.0,stn_ann_avg_mod1@_FillValue,stn_ann_avg_mod1)
 if (compare .eq. "OBS") then
 else
  stn_ann_avg_mod2 = where(stn_ann_avg_mod2.le.0,stn_ann_avg_mod2@_FillValue,stn_ann_avg_mod2)
 end if


  nstd  = 500
; define plot
  ; define plot generals
;********************************************************
 res                 = True
res@trYAxisType = "LogAxis"
res@trXAxisType = "LogAxis"
 if (compare .eq. "OBS") then
   res@xyMarkerColor    = (/"blue"/)
   res@xyMarkLineMode   = (/"Markers"/)
   res@xyMarker         = (/16/)
 else                              ; compare model to raobs
   res@xyMarkerColors    = (/"blue","red"/)
   res@xyMarkLineModes   = (/"Markers","Markers"/)
   res@xyMarkers         = (/16,16/)
 end if
 res@xyMarkerSizeF     = 0.01
 res@pmLegendWidthF = 0.10
 res@pmLegendHeightF = 0.10
 res@lgLabelFontHeightF = .015
 res@lgPerimOn = True
 res@txFontHeightF = 0.022
;*********************************************************************

  wks = gsn_open_wks(plot_type,wkdir+"cset7_IMPROVE_"+season+"_scatter")
     plot = new(5,"graphic")
     pline1 = new(5,"graphic")
     pline2 = new(5,"graphic")
     pline3 = new(5,"graphic")

     if (compare .eq. "OBS") then
          dimXY = (/1,nstd/)
          Xdata = new((/1,nstd/),"double")
          Ydata = new((/1,nstd/),"double")
     else
          dimXY = (/2,nstd/)
          Xdata = new((/2,nstd/),"double")
          Ydata = new((/2,nstd/),"double")
     end if

   
  ;  loop over variables     
   do i  = 0, nvars -2
     Xdata(0,:) = (/stn_ann_avg_obs(i,:)/)
     Ydata(0,:) = (/stn_ann_avg_mod1(i,:)/)
     
    if (.not.all(ismissing(Xdata(0,:)))) then
     ccro=esccr(Xdata(0,:),Xdata(0,:),0)
     avg_obs = dim_median(Xdata(0,:))
    else
      ccro = 0.
      avg_obs = 0.
    end if
    if (.not.all(ismissing(Ydata(0,:)))) then
     ccr1=esccr(Xdata(0,:),Ydata(0,:),0)
     avg_mod1=dim_median(Ydata(0,:))
  ;  avg_mod1=avg(Ydata(0,:))
    else
     avg_mod1 = 0.
     ccr1 = 0.
    end if
     if (compare .eq. "OBS") then
     else
      Xdata(1,:) = (/stn_ann_avg_obs(i,:)/)
      Ydata(1,:) = (/stn_ann_avg_mod2(i,:)/)
      if (.not.all(ismissing(Xdata(1,:)))) then
       ccr2=esccr(Xdata(1,:),Ydata(1,:),0)
   ;   ins = ind(Xdata(1,:).gt.0)
       avg_mod2=dim_median(Ydata(1,:))
     ; avg_mod2=stat_medrng(Ydata(1,:))
  ;    print(Ydata(0,ins))
  ;    print(Ydata(1,ins))
  ;  print(avg_obs)
  ;  print(avg_mod1)
  ;  print(avg_mod2)
      else
       ccr2 = 0.
       avg_mod2 = 0.
      end if
     end if
     res@trYMinF = min((/min(Xdata),min(Ydata)/))
     res@trXMinF = min((/min(Xdata),min(Ydata)/))
     if res@trYMinF.le.0 then 
      res@trYMinF = 0.001
      res@trXMinF = 0.001
     end if
     res@trYMaxF = max((/max(Xdata),max(Ydata)/))
     res@trXMaxF = max((/max(Xdata),max(Ydata)/))

     res@tiXAxisString = "Observed "+vars(i)+" ("+vars_units(i)+")"
     res@tiYAxisString = "Simulated "+vars(i)+" ("+vars_units(i)+")"
     res@gsnLeftString = varsn(i)+" ("+vars_units(i)+")" 


        res@pmLegendDisplayMode    = "Always"
          res@pmLegendSide           = "Right"
       ; if re.lt.6 .or. re.gt.9 then
       ;  res@pmLegendParallelPosF   =  .85
       ;  res@pmLegendOrthogonalPosF =  -.70
       ; else
          res@pmLegendParallelPosF   =  .15
          res@pmLegendOrthogonalPosF =  -.50
       ; end if
     if (compare .eq. "OBS") then
       res@xyExplicitLegendLabels = (/case1/)
     else
       res@xyExplicitLegendLabels = (/case1,case2/)
     end if

    res@gsnDraw = False
    res@gsnFrame = False
    plot(i) = gsn_csm_xy(wks,Xdata,Ydata,res)  ; create the plot
    qmin =  res@trYMinF
    qmax =  res@trYMaxF
    resp2                  = True                      ; polyline mods desired
    resp2@gsLineColor      = 1
    resp2@gsLineThicknessF = 2.0                       ; thickness of lines
    resp2@gsLineDashPattern= 0
    pline1(i) =  gsn_add_polyline(wks,plot(i),(/qmin,qmax/),(/qmin,qmax/),resp2)
    resp2@gsLineDashPattern= 2
    pline2(i) = gsn_add_polyline(wks,plot(i),(/qmin*2,qmax/),(/qmin,qmax*0.5/),resp2)
    pline3(i) = gsn_add_polyline(wks,plot(i),(/qmin,qmax*0.5/),(/qmin*2,qmax/),resp2)

    txres                       = True
    txres@txPerimOn             = False
    txres@txJust        = "CenterLeft"
    txres@txBackgroundFillColor = 0
    txres@txFontHeightF         = 0.015
    aaa=log10(qmax)
    bbb=log10(qmin)
    aba=(aaa-bbb)/2

    txid3 = gsn_add_text(wks, plot(i), "Median Obs="+sprintf("%5.2f",avg_obs),qmin+qmin*.2, 10.^(aaa-0.1*aba),txres)
    txres@txFontColor = "blue"
    txid2 = gsn_add_text(wks, plot(i), "Median ="+sprintf("%5.2f",avg_mod1)+" R="+sprintf("%5.2f",ccr1), qmin+qmin*0.2, 10.^(aaa-0.2*aba),txres)
    if (compare .eq. "OBS") then
    else
     txres@txFontColor = "red"
     txid1 = gsn_add_text(wks, plot(i),  "Median ="+sprintf("%5.2f",avg_mod2)+" R="+sprintf("%5.2f",ccr2), qmin+qmin*0.2, 10.^(aaa-0.3*aba), txres)
    end if
    txres@txFontColor = "black"

   end do
;*********************************************
    txres               = True
    txres@txFontHeightF = 0.017
    title = "IMPROVE "+season   
    gsn_text_ndc(wks,title,.45,.98,txres)

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
;   delete (res@tiXAxisString)


 
end

      

 




 
