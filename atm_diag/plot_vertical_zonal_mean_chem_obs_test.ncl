; NCL script
; plot_vertical_zonal_mean_chem_obs.ncl
; Simone Tilmes, Oct 2013
;**************************************
; compare to HALOE observations

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_vertical.ncl"

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
;mg_micro   = getenv("MG_MICRO")

 use_waccm_levs = getenv("USE_WACCM_LEVS")
 use_chem_levs = getenv("USE_CHEM_LEVS")

;************************************************************************
p0     = 1000.     ; mb required by vinth2p
interp = 2         ; log interpolation
extrap = False     ; no extrapolation past psfc.
;************************************************************************

; CASE 1 MODEL
 inptr1 = addfile(infile1,"r")

 if (ncdf_mode .eq. "write") then
   outptr1 = addfile(outfile1,"w")
 else
   outptr1 = addfile(outfile1,"c")
 end if

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

 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
 end if


 lev1 = inptr1->lev
 lon1 = inptr1->lon
 nlat1 = dimsizes(lat1)
 nlon1 = dimsizes(lon1)
 nlev1 = dimsizes(lev1)
 hyam1 = inptr1->hyam
 hybm1 = inptr1->hybm
 tmp = inptr1->PS
 if (typeof(tmp).eq."double") then
        ps1 = dble2flt(tmp)
 else
     ps1 = tmp
 end if
 t1 = inptr1->T
 delete(tmp)
 tmp = conform(t1,ps1,(/0,2,3/))
 press1 = pres_hybrid_ccm(ps1,p0,hyam1,hybm1)
 rho1   = press1/(287.04*t1)
 kboltz = 1.381e-23  ; J/K
 dens1 = press1/(kboltz*t1) * 1.e-06  ; ;cm-3
 delete(tmp)

; CASE 2 IS OBS (OR MODEL)
 if (compare .eq. "OBS") then
   case2 = "HALOE"
   ptr_haloe = addfile(infile2+"/haloe_climatology_V19a_climo.nc","r")
   press2= ptr_haloe->press; km
   o3_haloe = ptr_haloe->o3_climo
   h2o_haloe = ptr_haloe->h2o_climo
   ch4_haloe = ptr_haloe->ch4_climo
   hcl_haloe = ptr_haloe->hcl_climo
   no_haloe = ptr_haloe->no_climo
   no2_haloe = ptr_haloe->no2_climo
   lat_h = ptr_haloe->latitude
   nlat2 = dimsizes(lat_h)
   press2@units = "mb"
   npress2 = dimsizes(press2)
 else                        ;  CASE 2 IS MODEL
 end if

;----------------------------------------------------------------------
 if (compare .eq. "OBS") then
  vars_haloe =(/"O3","H2O","CH4","HCl","HF","NO","NO2"/) 
  vars =(/"O3","Q","CH4","HCl","HF","NO","NO2"/) 
  units = (/"%","%","ppbv","ppbv","ppbv","ppbv","ppbv"/)
  offset = (/0.,0.,0.,0.,0., 0., 0./)
  cfactor = (/10.,20.,1.,1.,1.,0.05,0.05/)
  dfactor = (/10.,20.,1.,1.,1.,0.05,0.05/)
  factor = (/1.e+06,1.e+06,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09/)
 else
 end if
  nvars = dimsizes(vars)
; contour levels
  con = new((/nvars,15/),float)
  dcon = new ((/nvars,15/),float)

; for comparison with another model interpolate the model data to  haloe
; pressure levels
 
 if (use_waccm_levs .eq. "True") then
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
 else
  delete(plvlM)
   nplvlM = 34
   plvlM = (/ 4.83445,  6.09635, 7.64935,   9.5501,  11.864, 14.6655,  18.038,     \
             22.0755,     26.8825, \
           30., 50., 70.,100.,150.,200.,250.,300.,350.,400.,450.,500., 550., \
          600.,650.,700.,750.,800.,850.,875.,900.,925.,950.,975.,1000. /)
 end if
plvlM@units = "mb"

;-------------------------------------------------------------------------
   plev = plvlM(::-1)                 ; flip to bottom to top
   ; topmost pressure level
   if (use_waccm_levs .eq. "False") then
     ptop  =  4.83445                      ; topmost pressure level
   else
     ptop = 2.9935e-3
   end if
   vars_top  =(/"O3","Q","N2O","Q","HNO3"/)
   itop   = ind(plev.eq.ptop)         ; index of top level
;-------------------------------------------------------------------------
;  plot these below 100mb
  vars_trop1 =(/""/)
   ptrop1 = 100.0                             ; tropopause pressure level  1 
   itrop1 = ind(plev.eq.ptrop1)        ; index of tropopause level 1
;------------------------------------------------------------------------- 
;  plot these below 300mb
   vars_trop2=(/""/)
   ptrop2 = 300.0                      ; tropopause pressure level 2 
   itrop2 = ind(plev.eq.ptrop2)        ; index of tropopause level 2
;------------------------------------------------------------------------- 

; all model data is interpolated to the same 16 pressure levels for
; comparison to obs data, or 25 levels for model-to-model comparisons
 
; linear vertical scale
  linear =(/""/) 

;**********************************************************************
; common resources for contour plots
 cnplot = new(3,"graphic")
 cres                        = True        
 cres@gsnDraw                = False      
 cres@gsnFrame               = False
 cres@trXReverse             = True
 cres@tiYAxisString          = "Pressure (mb)"  
 cres@txFontHeightF = 0.023
 if (color_type .eq. "COLOR") then
   cres@cnLevelSelectionMode = "ExplicitLevels" 
   cres@cnFillOn             = True
   cres@cnLinesOn            = False
   cres@cnLineLabelsOn       = False
   cres@lbTitleOn = True
   cres@lbLabelFontHeightF = 0.018
   cres@lbTitleFontHeightF = 0.02
   cmap = RGBtoCmap(rgb_file)
 else
   cres@cnLevelSelectionMode = "ManualLevels" 
   cres@cnLinesOn              = True 
   cres@cnLineLabelsOn         = True 
   cres@cnLineLabelInterval    = 1
   cres@cnLineLabelFontHeightF = .02
   cres@cnInfoLabelFontHeightF = .02
   cnlvls = 15
   diffcnlvls = 12
 end if
;-------------------------------------------
; common resoureces for panel plot 
 pan = True
 pan@gsnMaximize = True
 pan@gsnPaperOrientation = "portrait"
 pan@txFontHeightF = 0.018
 pan@gsnFrame = False
;***********************************************************

do i = 0,nvars-1
; print(vars(i))
 pan@txString = vars(i)+" "+season
con(i,:)=cfactor(i)*(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,16/)+offset(i)   
dcon(i,:)=dfactor(i)*(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
;if i.eq.16 .or. i.eq.17 then
; con(i,:)=cfactor(i)*(/0.1,0.2,0.4,0.6, 0.8, 1.,2.,3.,4,8,12,24,48,92,180/)+offset(i)   
; dcon(i,:)=cfactor(i)*(/0.1,0.2,0.4,0.6, 0.8, 1.,2.,3.,4,8,12,24,48,92,180/)+offset(i)   
;end if 
if (isfilevar(inptr1,vars(i))) then
     vars1 = inptr1->$vars(i)$
else 
    vars1 = new((/1,nlev1,nlat1,nlon1/),"float")
end if

; CASE 1 MODEL
; interpolate variables
      tmp = vinth2p(vars1,hyam1,hybm1,plvlM,ps1,interp,p0,1,extrap)
      if (typeof(tmp).eq."double") then
        var3= dble2flt(tmp(0,:,:,:))
      else
        var3 = tmp(0,:,:,:)                  ; 3D array (lev,lat,lon)
      end if
      var1 = dim_avg_Wrap(var3)     ; zonal ave -->(lev,lat)
      var1 = (/var1*factor(i)/)
      delete(tmp)
      delete(var3)

 if (compare .eq. "OBS") then                                ; CASE 2 IS MODEL
   if vars(i).eq."O3" then
    var2_mon = o3_haloe 
   end if
   if vars(i).eq."Q" then
    var2_mon = h2o_haloe 
   end if
   if vars(i).eq."CH4" then
    var2_mon = ch4_haloe 
   end if
   if vars(i).eq."HCl" then
    var2_mon = hcl_haloe 
   end if
   if vars(i).eq."HF" then
    var2_mon = hf_haloe 
   end if
   if vars(i).eq."NO" then
    var2_mon = no_haloe 
   end if
   if vars(i).eq."NO2" then
    var2_mon = no2_haloe 
   end if
   if season.eq."ANN" then
    ins = (/0,1,2,3,4,5,6,7,8,9,10,11/)    
   end if
   if season.eq."DJF" then
    ins = (/0,1,11/)    
   end if
   if season.eq."MAM" then
    ins = (/2,3,4/)    
   end if
   if season.eq."JJA" then
    ins = (/5,6,7/)    
   end if
   if season.eq."SON" then
    ins = (/8,9,10/)    
   end if
   var2 = dim_avg_n_Wrap(var2_mon(:,:,ins),2)
 else
 end if

  if (any(vars(i) .eq. vars_top)) then  ; change top level plotted 
    cres@trYMinF = ptop   
    itop1 = itop               ; model 1 top
    if (compare .ne. "OBS") then                                ; CASE 2 IS MODEL
     itop2 = itop             ; model 2 top
    end if
  end if
  if (any(vars(i) .eq. vars_trop1)) then  ; change top level plotted 
    cres@trYMinF = ptrop1
    cres@trYMaxF = 1000. 
    itop1 = itrop1              ; model 1 trop1 
    if (compare .ne. "OBS") then                              
      itop2 = itrop2             ; model 1 top
    end if
  end if
  if (any(vars(i) .eq. vars_trop2)) then  ; change top level plotted 
    cres@trYMinF = ptrop2
    cres@trYMaxF = 1000.
    itop1 = itrop2              ; model 1 trop1 
    if (compare .ne. "OBS") then                              
      itop2 = itrop2             ; model 2 top
    end if
  end if
  data1 = var1(0:itop1,:)                   ; model data(lev,lat)
  data2 = var2(itop1:npress2-1,:)                   ; model data(lev,lat)
  printVarSummary(data1)
  printVarSummary(data2)
; data2(0:itop1,:) =  (/var2(0:itop1,:)/)                    ; model or obs data(lev,lat)
; data1 = var1                   ; model data(lev,lat)
; data2 = var2                     ; model or obs data(lev,lat)
  data1!0 = "lev"
  data1!1 = "lat"
  data1@units = units(i)
  data2!0 = "lev"
  data2!1 = "lat"
  data2@units = units(i)


;------------------------- Open files for plots -----------------------------
  if (use_waccm_levs .eq. "False") then
    set_prefix = "cset2_haloe_"
  else
    set_prefix = "wset2_haloe_"
  end if

  if (compare.eq."OBS") then
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+vars(i)+"_c")
      gsn_define_colormap(wks,cmap)
    else
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+vars(i))
    end if
  else
  end if 
;-------------------------------------------------------------------------
; case plots of latitude(x) vs. pressure/height(y)

  if (any(vars(i) .eq. linear)) then
    cres@trYLog = False
  else
    cres@trYLog = True
  end if

  min1 = min(data1)
  max1 = max(data1)
  min2 = min(data2)
  max2 = max(data2)
 ;print(min1)
 ;print(max1)

  if (color_type .eq. "COLOR") then
    cres@lbLabelStride  = 2
    cres@lbOrientation = "Horizontal"
    cres@cnLevels = con(i,:)
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                       "  MAX = "+sprintf("%6.2f",max1)
  else
    minab = min((/min1,min2/))
    maxab = min((/max1,max2/))
    mnmxint = nice_mnmxintvl (minab,maxab,cnlvls,False)
    cres@cnMinLevelValF = mnmxint(0)
    cres@cnMaxLevelValF = mnmxint(1)
    cres@cnLevelSpacingF = mnmxint(2)
  end if

  if (isvar("yrs_ave1")) then
    cres@tiMainString = case1+" (yrs "+yrs_ave1+")"
  else  
    cres@tiMainString = case1
  end if
  cnplot(0)  = gsn_csm_pres_hgt(wks,data1,cres)
; delete (cres@lbTitleString)
; delete (cres@tiMainString)

  if (color_type .eq. "MONO") then
    cnplot(0) = ZeroNegDashLineContour(cnplot(0))
  else
    delete (cres@lbTitleString)
  end if
  delete (cres@tiMainString)

  if (isvar("yrs_ave2")) then
    cres@tiMainString = case2+" (yrs "+yrs_ave2+")"
  else  
    cres@tiMainString = case2
  end if
  if (color_type .eq. "COLOR") then
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                       "  MAX = "+sprintf("%6.2f",max2)
  end if

   
  cnplot(1)  = gsn_csm_pres_hgt(wks,data2,cres)

  if (color_type .eq. "MONO") then
    cnplot(1) = ZeroNegDashLineContour(cnplot(1))
  else
    delete (cres@cnLevels)
    delete (cres@lbLabelStride)
    delete (cres@lbOrientation)
    delete (cres@lbTitleString)
  end if
  delete (cres@tiMainString)
  delete (min1)
  delete (max1)
  delete (min2)
  delete (max2)

; difference plot of latitude(x) vs. pressure(y)
; check for different number of latitudes and thenn
; lineary interpolate to the smaller number of latitudes
 nlat2 = dimsizes(lat_h)
 lat2 = lat_h

  if (compare.eq."OBS") then   ; both are models on same pressure levels
                               ; but not necessarily the same grids

    if (nlat1 .ne. nlat2) then         ; lat grids different
      if (nlat1 .gt. nlat2) then     
        tmp1 = linint1 (lat1,data1,False,lat2,0)
        C = data2
        D = data2
        C = (/tmp1-data2/)               ; get diff values
        D = (/ 100*(tmp1-data2)/(0.5*(tmp1+data2)) /)
        delete (tmp1)
      else
        tmp2 = linint1 (lat2,data2,False,lat1,0)
        C = data1                        ; copy dims,coords
        D = data1                        ; copy dims,coords
        C = (/data1-tmp2/)               ; get diff values
        D = (/ 100*(data1-tmp2)/(0.5*(tmp2+data1)) /)
        delete (tmp2)
      end if
    else                                 ; same grid latitudes
      C = data1                          ; copy dims,coords
      D = data1                          ; copy dims,coords
      C = (/data1-data2/)                ; get diff values 
      D = (/ 100*(data1-data2)/(0.5*(data2+data1)) /)                ; get diff values 
    end if
    if vars(i).eq."O3" .or. vars(i).eq."Q" then
      C = D
    end if
    delete(D)
  else                                   ; case 2 is OBS data on T42
  end if
  ; print("========================")
  mind = min(C)
  maxd = max(C)

  cres@tiMainString = case1+" - "+case2
  if (color_type .eq. "COLOR") then
    cres@lbLabelStride = 1
    cres@lbOrientation = "Vertical"
    cres@lbBoxMinorExtentF = 0.18
    cres@cnLevels = dcon(i,:)
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                       "  MAX = "+sprintf("%6.2f",maxd)
  else
    mnmxint = nice_mnmxintvl (mind,maxd,diffcnlvls,False)
    cres@cnMinLevelValF = mnmxint(0)
    cres@cnMaxLevelValF = mnmxint(1)
    cres@cnLevelSpacingF = mnmxint(2)
  end if
  cnplot(2)= gsn_csm_pres_hgt(wks,C,cres)    ; contour plot

  if (color_type .eq. "COLOR") then
    delete (cres@lbTitleString)
    delete (cres@lbOrientation)
    delete (cres@lbLabelStride)
    delete (cres@lbBoxMinorExtentF)
    delete (cres@cnLevels)
  else
    cnplot(2) = ZeroNegDashLineContour(cnplot(2))
  end if

  if (time_stamp .eq. "True") then
    pan@gsnPanelBottom = 0.05
    gsn_panel(wks,cnplot,(/2,2/),pan)         ; panel plot
    infoTimeStamp(wks,0.011,"DIAG Version: "+version)
  else
    gsn_panel(wks,cnplot,(/2,2/),pan)         ; panel plot
  end if
  frame (wks)


;  delete (cres@trYMinF)
  delete (var1)
  delete (var2)
  delete (C)
  delete (data1)
  delete (data2)
  delete (mind)
  delete (maxd)
  if (compare.eq."OBS") then
    delete (lat2)
    delete (nlat2)
  end if
end do

end
