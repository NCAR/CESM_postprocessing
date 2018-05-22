; NCL script
; plot_vertical_zonal_mean_chem.ncl
; Simone Tilmes, Feb 2013
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
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename
;mg_micro   = getenv("MG_MICRO")

 use_waccm_levs = getenv("USE_WACCM_LEVS")

;************************************************************************
p0     = 100000.     ; mb required by vinth2p
interp = 2         ; log interpolation
extrap = False     ; no extrapolation past psfc.
;************************************************************************

; CASE 1 MODEL
 inptr1 = addfile(infile1,"r")

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
   hyam2 = inptr2->hyam
   hybm2 = inptr2->hybm
   tmp = inptr2->PS
   if (typeof(tmp).eq."double") then
        ps2 = dble2flt(tmp)
   else
     ps2 = tmp
   end if
   t2 = inptr2->T
   delete(tmp)
    tmp = conform(t2,ps2,(/0,2,3/))
   press2 = pres_hybrid_ccm(ps2,p0,hyam2,hybm2)
   rho2   = press2/(287.04*t2)
;   rho2   = tmp/(287.04*t2)
   dens2 = press2/(kboltz*t2) * 1.e-06  ; ;cm-3
   delete(tmp)
 end if

;----------------------------------------------------------------------
 if (compare .eq. "OBS") then
 else
  vars =(/"O3","Q","CO","OH","NOY","N2O","PAN", \
           "HNO3","H2O2","C2H2","C2H6","C3H6","SO2","SO4","BC","OC","DUST","SSALT","SAD_TROP","NOx_NOy","SOA","NOX","jo3_a","SAD_SO4NIT","SAD_SOA","SAD_BC", "C3H8","CH3COCH3","CH3OH","CH2O","SAD_ICE","SAD_LNAT","SAD_SULFC"/)
  units1 = (/"ppbv","ppbv","ppbv","ppbt","ppbv","ppbv","ppbv","ppbv","ppbv","ppbv","ppbv","ppbv","ppbv","ug/m3","ug/m3","ug/m3","ug/m3","ug/m3","um2/cm3","fraction","ug/m3","ppbv","1/s","um2/cm3","um2/cm3","um2/cm3", "ppbt","ppbt","ppbt","ppbt","um2/cm3","um2/cm3","um2/cm3"/)
  units = (/"%","%","%","%","%","%","%","%","%","%","%","%","%","%","%","%","%","%","%","fraction","%","%","%","%","%","%","%","%","%","%","%","%","%"/)
  offset = (/0.,0.,0.,0.,0.,     250.,  0., \
         0.,  0., 0.,  0., 0., 0., 0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0./)
  cfactor = (/10.,40.,10.,0.02,0.1,  4,   0.03,\
            0.1,0.2,0.02,0.05,0.005, 0.02,0.1,0.1,0.1,1.,0.5,5.,0.10,0.02,0.1,1.,5.,5.,5.,0.02,0.04,0.10,0.02,0.5,0.01,0.2/)
  dfactor = (/30.,30.,30.,30.,30,  30,   50,30,30.,30.,30.,30.,  30,50,30,30,30.,30,30,0.2,30,30.,1.,30.,30.,30.,30.,30.,50.,30.,30.,30.,30./)
  factor = (/1.e+09,1.e+06,1.e+09,1.e+12,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+09,1.e+08,1.,1.e+09,1.e+09,1.e+06,1.e+08,1.e+08,1.e+08,1.e+09,1.e+09,1.e+09,1.e+09,1.e+08,1.e+08,1.e+08/)
  end if
   nvars = dimsizes(vars)
; contour levels
   con = new((/nvars,15/),float)
   dcon = new ((/nvars,15/),float)

; for comparison with another model interpolate the model data to these
; 25 constant pressure levels
 if (use_waccm_levs .eq. "True") then
; delete(plvlM)
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
     ptop  =  0.5                     ; topmost pressure level
   end if
 ; vars_top  =(/"jo3_a","O3","OH","N2O","HNO3","NOY","NOx_NOy","Q","NOX","SAD_ICE","SAD_LNAT","SAD_SULFC"/)
   vars_top  =(/""/)
   itop   = ind(plev.eq.ptop)         ; index of top level
;-------------------------------------------------------------------------
;  plot these below 100mb
; vars_trop1 =(/"CO","PAN","OH","Q", \
  vars_trop1 =(/"CO","PAN",  \
                "jo3_a","O3","N2O","HNO3","NOY","NOx_NOy","Q","NOX", \
           "H2O2","C2H2","C2H6","C3H6","SO2","SO4","BC","OC", \
           "C3H8","CH3COCH3","CH3OH","CH2O"/)
   ptrop1 = 9.0                             ; tropopause pressure level  1 
   itrop1 = ind(plev.eq.ptrop1)        ; index of tropopause level 1
;------------------------------------------------------------------------- 
;  plot these below 300mb
   vars_trop2=(/"SOA","OH"/)
   ptrop2 = 100.0                      ; tropopause pressure level 2 
   itrop2 = ind(plev.eq.ptrop2)        ; index of tropopause level 2
;------------------------------------------------------------------------- 

; all model data is interpolated to the same 16 pressure levels for
; comparison to obs data, or 25 levels for model-to-model comparisons
 
; linear vertical scale
;linear =(/"SSALT","SO2","SO4","BC","OC","SOA"/) 
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
 pan@txString = vars(i)+" "+season
con(i,:)=cfactor(i)*(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,16/)+offset(i)   
dcon(i,:)=dfactor(i)*(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
 if i.ge.14 .and. i.le.17 then
  con(i,:)=cfactor(i)*(/0.1,0.2,0.4,0.6, 0.8, 1.,2.,3.,4,8,12,24,48,92,180/)+offset(i)   
; dcon(i,:)=cfactor(i)*(/0.1,0.2,0.4,0.6, 0.8, 1.,2.,3.,4,8,12,24,48,92,180/)+offset(i)   
 end if 

vars1 = t1
vars1@_FillValue = -999
if vars(i).eq."SO4" then
; bam 
   if (isfilevar(inptr1,"SO4")) then 
     vars1 = inptr1->$vars(i)$
; mam
   else  
     if (isfilevar(inptr1,"so4_a1") .and. isfilevar(inptr1,"so4_a2") .and. isfilevar(inptr1,"so4_a3") ) then 
      vars11 = inptr1->so4_a1 
      vars12 = inptr1->so4_a2 
      vars13 = inptr1->so4_a3 
      vars1 = vars11 + vars12 + vars13
      vars1 = vars1* 96./115.  ; SO4 is actually  NH4HSO4 in MAM3 (needs to be converted) 
      delete (vars11)
      delete (vars12)
      delete (vars13)
     end if
     if (isfilevar(inptr1,"so4_a1") .and. isfilevar(inptr1,"so4_a2") .and. isfilevar(inptr1,"so4_a4") .and. isfilevar(inptr1,"so4_a5") .and. isfilevar(inptr1,"so4_a6") .and. isfilevar(inptr1,"so4_a7") )  then 
         vars11 = inptr1->so4_a1 
         vars12 = inptr1->so4_a2 
         vars13 = inptr1->so4_a4 
         vars14 = inptr1->so4_a5 
         vars15 = inptr1->so4_a6 
         vars16 = inptr1->so4_a7 
         vars1 = vars11 + vars12 + vars13 + vars14 + vars15 + vars16
         delete (vars11)
         delete (vars12)
         delete (vars13)
         delete (vars14)
         delete (vars15)
         delete (vars16)
      end if
   end if
else if vars(i).eq."BC" then
; bam
   if (isfilevar(inptr1,"CB1") .and. isfilevar(inptr1,"CB2")) then
     vars11 = inptr1->CB1
     vars12 = inptr1->CB2
     vars1 = vars11 + vars12 
     delete (vars11)
     delete (vars12)
   else
; mam
     if (isfilevar(inptr1,"bc_a1"))  then
       vars1 = inptr1->bc_a1
      end if
     if (isfilevar(inptr1,"bc_a1") .and. isfilevar(inptr1,"bc_a3") )  then
         vars11 = inptr1->bc_a1
         vars12 = inptr1->bc_a3
         vars1 = vars11 + vars12
     end if
     if (isfilevar(inptr1,"bc_a1") .and. isfilevar(inptr1,"bc_a4") )  then
         vars11 = inptr1->bc_a1
         vars12 = inptr1->bc_a4
         vars1 = vars11 + vars12
     end if
   end if
else if vars(i).eq."OC" then
; bam
   if (isfilevar(inptr1,"OC1") .and. isfilevar(inptr1,"OC2")) then
     vars11 = inptr1->OC1
     vars12 = inptr1->OC2
     vars1 = vars11 + vars12 
     delete (vars11)
     delete (vars12)
   else 
; mam 
     if (isfilevar(inptr1,"pom_a1"))  then
      vars1 = inptr1->pom_a1
     end if
     if (isfilevar(inptr1,"pom_a1") .and. isfilevar(inptr1,"pom_a3") )  then
         vars11 = inptr1->pom_a1
         vars12 = inptr1->pom_a3
         vars1 = vars11 + vars12
         delete (vars11)
         delete (vars12)
     end if
     if (isfilevar(inptr1,"pom_a1") .and. isfilevar(inptr1,"pom_a4") )  then
         vars11 = inptr1->pom_a1
         vars12 = inptr1->pom_a4
         vars1 = vars11 + vars12
         delete (vars11)
         delete (vars12)
     end if

   end if
else if vars(i).eq."SOA" then
; bam
   if (isfilevar(inptr1,"SOA")) then
     vars1 = inptr1->SOA  ; kg/kg
   end if
;collette
    if (isfilevar(inptr1,"SOAI") .and. isfilevar(inptr1,"SOAT") .and. isfilevar(inptr1,"SOAB") .and. isfilevar(inptr1,"SOAX") .and. isfilevar(inptr1,"SOAM")) then
     
     mw_dryair = 28.97e-3  ;kg/mole
     mwsoa_c = (/60.05500,    84.077000,    72.06600,    96.088000,   120.11000/)
     mwsoa = (/ 136.141400,   141.141800,   127.116000,   155.167600,   200.226000 /)
     varsoa = (/"SOAI","SOAT","SOAB","SOAX","SOAM"/)
 ;   varsoa = (/"SOAI_dens","SOAT_dens","SOAB_dens","SOAX_dens","SOAX_dens"/)

     vars11=inptr1->$varsoa(0)$
  ;  vars11 = vars11*mwsoa_c(0)/mwsoa(0) ;mol/mol kg/mol / kg/mol
     vars12=inptr1->$varsoa(1)$
     vars12 = vars12*mwsoa_c(1)/mwsoa(1) ;.e-03 ;mol/mol kg/mol / kg/mol
     vars13=inptr1->$varsoa(2)$
     vars13 = vars13*mwsoa_c(2)/mwsoa(2) ;.e-03 ;mol/mol kg/mol / kg/mol
     vars14=inptr1->$varsoa(3)$
     vars14 = vars14*mwsoa_c(3)/mwsoa(3) ;.e-03 ;mol/mol kg/mol / kg/mol
     vars15=inptr1->$varsoa(4)$
     vars15 = vars15*mwsoa_c(4)/mwsoa(4) ;.e-03 ;mol/mol kg/mol / kg/mol
     vars1 = vars11 + vars12 + vars13 + vars14 + vars15
   ; vars1 = vars15
     delete (vars11)
     delete (vars12)
     delete (vars13)
     delete (vars14)
     delete (vars15)
     delete(varsoa)
   else
     if (isfilevar(inptr1,"soa_a1") .and. isfilevar(inptr1,"soa_a2")) then
     varsoa =  (/"soa_a1","soa_a2"/)
     vars11=inptr1->$varsoa(0)$
     vars12=inptr1->$varsoa(1)$
     vars1 = vars11 + vars12 
     delete (vars11)
     delete (vars12)
     delete(varsoa)
     end if
     if (isfilevar(inptr1,"soaff1_a1") .and. isfilevar(inptr1,"soaff1_a2")) then
     varsoa =  (/"soaff1_a1","soaff1_a2","soaff2_a1","soaff2_a2","soaff3_a1","soaff3_a2","soaff4_a1","soaff4_a2","soaff5_a1","soaff5_a2",\
               "soabb1_a1","soabb1_a2","soabb2_a1","soabb2_a2","soabb3_a1","soabb3_a2","soabb4_a1","soabb4_a2","soabb5_a1","soabb5_a2",\
               "soabg1_a1","soabg1_a2","soabg2_a1","soabg2_a2","soabg3_a1","soabg3_a2","soabg4_a1","soabg4_a2","soabg5_a1","soabg5_a2" /)
     nvarsoa = dimsizes(varsoa)
     vars1 = 0.
     do si = 0, nvarsoa-1
      vars1=vars1 + inptr1->$varsoa(si)$
     end do
     delete(varsoa)
     end if
     if (isfilevar(inptr1,"soa1_a1") .and. isfilevar(inptr1,"soa1_a2")) then
     varsoa =  (/"soa1_a1","soa1_a2","soa2_a1","soa2_a2","soa3_a1","soa3_a2","soa4_a1","soa4_a2","soa5_a1","soa5_a2"/)
     nvarsoa = dimsizes(varsoa)
     vars1 = 0.
     do si = 0, nvarsoa-1
      vars1=vars1 + inptr1->$varsoa(si)$
     end do
     delete(varsoa)
    end if
   end if
; mam
else if vars(i).eq."DUST" then
; bam
   if (isfilevar(inptr1,"DST01") .and. isfilevar(inptr1,"DST02") .and. isfilevar(inptr1,"DST03") .and. isfilevar(inptr1,"DST04")) then
     vars11 = inptr1->DST01
     vars12 = inptr1->DST02
     vars13 = inptr1->DST03
     vars14 = inptr1->DST04
     vars1 = vars11 + vars12 + vars13 + vars14
     delete (vars11)
     delete (vars12)
     delete (vars13)
     delete (vars14)
   else
; mam
     if (isfilevar(inptr1,"dst_a1") .and. isfilevar(inptr1,"dst_a3"))  then
      vars11 = inptr1->dst_a1
      vars12 = inptr1->dst_a3
      vars1 = vars11 + vars12
      delete (vars11)
      delete (vars12)
     end if
     if (isfilevar(inptr1,"dst_a5") .and. isfilevar(inptr1,"dst_a7"))  then
      vars11 = inptr1->dst_a5
      vars12 = inptr1->dst_a7
      vars1 = vars11 + vars12
      delete (vars11)
      delete (vars12)
     end if
   end if
else if vars(i).eq."SSALT" then
; bam
   if (isfilevar(inptr1,"SSLT01") .and. isfilevar(inptr1,"SSLT02") .and. isfilevar(inptr1,"SSLT03") .and. isfilevar(inptr1,"SSLT04")) then
     vars11 = inptr1->SSLT01
     vars12 = inptr1->SSLT02
     vars13 = inptr1->SSLT03
     vars14 = inptr1->SSLT04
     vars1 = vars11 + vars12 + vars13 + vars14
     delete (vars11)
     delete (vars12)
     delete (vars13)
     delete (vars14)
   else
; mam
     if (isfilevar(inptr1,"ncl_a1") .and. isfilevar(inptr1,"ncl_a2") .and. isfilevar(inptr1,"ncl_a3"))  then
      vars11 = inptr1->ncl_a1
      vars12 = inptr1->ncl_a2
      vars13 = inptr1->ncl_a3
      vars1 = vars11 + vars12 + vars13 
      delete (vars11)
      delete (vars12)
      delete (vars13)
     end if
     if (isfilevar(inptr1,"ncl_a1") .and. isfilevar(inptr1,"ncl_a2") .and. isfilevar(inptr1,"ncl_a4") .and. isfilevar(inptr1,"ncl_a6") )  then
      vars11 = inptr1->ncl_a1
      vars12 = inptr1->ncl_a2
      vars13 = inptr1->ncl_a4
      vars14 = inptr1->ncl_a6
      vars1 = vars11 + vars12 + vars13 + vars14
      delete (vars11)
      delete (vars12)
      delete (vars13)
      delete (vars14)
     end if
   end if
else if vars(i).eq."NOX" then
    if (isfilevar(inptr1,"NOX"))  then
     vars1 = inptr1->NOX
    else  
     if  (isfilevar(inptr1,"NO") .and. isfilevar(inptr1,"NO2") ) then
     vars11 = inptr1->NO
     vars12 = inptr1->NO2
     vars1 = vars11+vars12
     delete (vars11)
     delete (vars12)
     end if
   end if
else if vars(i).eq."NOx_NOy" then
    if (isfilevar(inptr1,"NOX") .and. isfilevar(inptr1,"NOY"))   then
     vars11 = inptr1->NOX
     vars12 = inptr1->NOY
     vars1 = vars11/vars12
    else  
     if  (isfilevar(inptr1,"NO") .and. isfilevar(inptr1,"NO2") .and. isfilevar(inptr1,"NOY") ) then
     vars11 = inptr1->NO
     vars12 = inptr1->NO2
     vars13 = inptr1->NOY
     vars1 = (vars11+vars12)/vars13
     delete (vars11)
     delete (vars12)
     end if
   end if
else if vars(i).eq."OH" then
    if (isfilevar(inptr1,"OH"))  then
     vars1 = inptr1->$vars(i)$
;    vars1 = vars1*dens1 
   end if
else 
  if (isfilevar(inptr1,vars(i))) then
     vars1 = inptr1->$vars(i)$
  else 
    vars1 = vars1@_FillValue
  end if
end if
end if
end if
end if
end if
end if
end if
end if
end if
 if units1(i).eq."ug/m3"  then
  vars1 = vars1 * rho1  ; convert from mmr to ug/m3
 end if
;if i.ge.13 .and. i.le.15. then
;  vars1 = vars1 * rho1 * 1.e9 ; convert from mmr to ug/m3
;end if


; CASE 1 MODEL
; interpolate variables
      ptmp = press1/100.
      tmp = int2p_n_Wrap(ptmp,vars1,plvlM,interp,1)
      delete(ptmp)
      if (typeof(tmp).eq."double") then
        var3= dble2flt(tmp(0,:,:,:))
      else
        var3 = tmp(0,:,:,:)                  ; 3D array (lev,lat,lon)
      end if
      var1 = dim_avg_Wrap(var3)     ; zonal ave -->(lev,lat)
      var1 = (/var1*factor(i)/)
      delete(tmp)
      delete(var3)
      delete(vars1)

 if (compare .ne. "OBS") then                                ; CASE 2 IS MODEL
   vars2 = t2
   vars2@_FillValue = -999
  if vars(i).eq."SO4" then
  ; bam
     if (isfilevar(inptr2,"SO4")) then
       vars2 = inptr2->$vars(i)$
  ; mam
     else
       if (isfilevar(inptr2,"so4_a1") .and. isfilevar(inptr2,"so4_a2") .and. isfilevar(inptr2,"so4_a3") ) then
        vars21 = inptr2->so4_a1
        vars22 = inptr2->so4_a2
        vars23 = inptr2->so4_a3
        vars2 = vars21 + vars22 + vars23
        vars2 = vars2* 96./115.  ; SO4 is actually  NH4HSO4 in MAM3 (needs to be converted) 
        delete (vars21)
        delete (vars22)
        delete (vars23)
       end if
       if (isfilevar(inptr2,"so4_a1") .and. isfilevar(inptr2,"so4_a2") .and. isfilevar(inptr2,"so4_a4") .and. isfilevar(inptr2,"so4_a5") .and. isfilevar(inptr2,"so4_a6") .and. isfilevar(inptr2,"so4_a7") )  then 
         vars21 = inptr2->so4_a1 
         vars22 = inptr2->so4_a2 
         vars23 = inptr2->so4_a4 
         vars24 = inptr2->so4_a5 
         vars25 = inptr2->so4_a6 
         vars26 = inptr2->so4_a7 
         vars2 = vars21 + vars22 + vars23 + vars24 + vars25 + vars26
         delete (vars21)
         delete (vars22)
         delete (vars23)
         delete (vars24)
         delete (vars25)
         delete (vars26)
        end if
     end if
  else if vars(i).eq."BC" then
  ; bam
     if (isfilevar(inptr2,"CB1") .and. isfilevar(inptr2,"CB2")) then
       vars21 = inptr2->CB1
       vars22 = inptr2->CB2
       vars2 = vars21 + vars22
        delete (vars21)
        delete (vars22)
     else
  ; mam
       if (isfilevar(inptr2,"bc_a1"))  then
         vars2 = inptr2->bc_a1
        end if
       if (isfilevar(inptr2,"bc_a1") .and. isfilevar(inptr2,"bc_a3") )  then
         vars21 = inptr2->bc_a1
         vars22 = inptr2->bc_a3
         vars2 = vars21 + vars22
        end if
       if (isfilevar(inptr2,"bc_a1") .and. isfilevar(inptr2,"bc_a4") )  then
         vars21 = inptr2->bc_a1
         vars22 = inptr2->bc_a4
         vars2 = vars21 + vars22
        end if
     end if
  else if vars(i).eq."OC" then
  ; bam
     if (isfilevar(inptr2,"OC1") .and. isfilevar(inptr2,"OC2")) then
       vars21 = inptr2->OC1
       vars22 = inptr2->OC2
       vars2 = vars21 + vars22
        delete (vars21)
        delete (vars22)
     else
  ; mam
       if (isfilevar(inptr2,"pom_a1"))  then
        vars2 = inptr2->pom_a1
       end if
       if (isfilevar(inptr2,"pom_a1") .and. isfilevar(inptr2,"pom_a3") )  then
         vars21 = inptr2->pom_a1
         vars22 = inptr2->pom_a3
         vars2 = vars21 + vars22
        end if
       if (isfilevar(inptr2,"pom_a1") .and. isfilevar(inptr2,"pom_a4") )  then
         vars21 = inptr2->pom_a1
         vars22 = inptr2->pom_a4
         vars2 = vars21 + vars22
        end if
     end if
   else if vars(i).eq."SOA" then
; bam
   if (isfilevar(inptr2,"SOA")) then
     vars2 = inptr2->SOA  ; kg/kg
   end if
;collette
   if (isfilevar(inptr2,"SOAI") .and. isfilevar(inptr2,"SOAT") .and. isfilevar(inptr2,"SOAB") .and. isfilevar(inptr2,"SOAX") .and. isfilevar(inptr2,"SOAM")) then
     mwsoa = (/ 136.141400,   141.141800,   127.116000,   155.167600,   200.226000 /)
     mwsoa_c = (/60.05500,    84.077000,    72.06600,    96.088000,   120.11000/)
     varsoa = (/"SOAI","SOAT","SOAB","SOAX","SOAM"/)
 ;   varsoa = (/"SOAI_dens","SOAT_dens","SOAB_dens","SOAX_dens","SOAM_dens"/)
     vars21=inptr2->$varsoa(0)$
  ;  vars21 = vars21*mwsoa_c(0)/mwsoa(0) ;mol/mol kg/mol / kg/mol
     vars22=inptr2->$varsoa(1)$
     vars22 = vars22*mwsoa_c(1)/mwsoa(1) ;.e-03 ;mol/mol kg/mol / kg/mol
     vars23=inptr2->$varsoa(2)$
     vars23 = vars23*mwsoa_c(2)/mwsoa(2) ;.e-03 ;mol/mol kg/mol / kg/mol
     vars24=inptr2->$varsoa(3)$
     vars24 = vars24*mwsoa_c(3)/mwsoa(3) ;.e-03 ;mol/mol kg/mol / kg/mol
     vars25=inptr2->$varsoa(4)$
     vars25 = vars25*mwsoa_c(4)/mwsoa(4) ;.e-03 ;mol/mol kg/mol / kg/mol
     vars2 = vars21 + vars22 + vars23 + vars24 + vars25
  ;   vars2 = vars2 * rho2 * 1.e-9 
  ;  vars2 = vars2 * rho2 * 1.e9 ; convert from mmr to ug/m3
     delete(varsoa)
  ; carbon fraction:
    else
     if (isfilevar(inptr2,"soa_a1") .and. isfilevar(inptr2,"soa_a2")) then
     varsoa =  (/"soa_a1","soa_a2"/)
     vars21=inptr2->$varsoa(0)$
     vars22=inptr2->$varsoa(1)$
     vars2 = vars21 + vars22
     delete (vars21)
     delete (vars22)
     delete(varsoa)
     end if
      if (isfilevar(inptr2,"soaff1_a1") .and. isfilevar(inptr2,"soaff1_a2")) then
     varsoa =  (/"soaff1_a1","soaff1_a2","soaff2_a1","soaff2_a2","soaff3_a1","soaff3_a2","soaff4_a1","soaff4_a2","soaff5_a1","soaff5_a2",\
               "soabb1_a1","soabb1_a2","soabb2_a1","soabb2_a2","soabb3_a1","soabb3_a2","soabb4_a1","soabb4_a2","soabb5_a1","soabb5_a2",\
               "soabg1_a1","soabg1_a2","soabg2_a1","soabg2_a2","soabg3_a1","soabg3_a2","soabg4_a1","soabg4_a2","soabg5_a1","soabg5_a2" /)
     nvarsoa = dimsizes(varsoa)
     vars2 = 0.
     do si = 0, nvarsoa-1
      vars2=vars2 + inptr2->$varsoa(si)$
     end do
     delete(varsoa)
     end if
    if (isfilevar(inptr2,"soa1_a1") .and. isfilevar(inptr2,"soa1_a2")) then
     varsoa =  (/"soa1_a1","soa1_a2","soa2_a1","soa2_a2","soa3_a1","soa3_a2","soa4_a1","soa4_a2","soa5_a1","soa5_a2"/)
     nvarsoa = dimsizes(varsoa)
     vars2 = 0.
     do si = 0, nvarsoa-1
      vars2=vars2 + inptr2->$varsoa(si)$
     end do
     delete(varsoa)
    end if

  end if
   else if vars(i).eq."DUST" then
  ; bam
     if (isfilevar(inptr2,"DST01") .and. isfilevar(inptr2,"DST02") .and. isfilevar(inptr2,"DST03") .and. isfilevar(inptr2,"DST04")) then
       vars21 = inptr2->DST01
       vars22 = inptr2->DST02
       vars23 = inptr2->DST03
       vars24 = inptr2->DST04
       vars2 = vars21 + vars22 + vars23 + vars24
       delete (vars21)
       delete (vars22)
       delete (vars23)
       delete (vars24)
     else
  ; mam
       if (isfilevar(inptr2,"dst_a1") .and. isfilevar(inptr2,"dst_a3"))  then
        vars21 = inptr2->dst_a1
        vars22 = inptr2->dst_a3
        vars2 = vars21 + vars22
        delete (vars21)
        delete (vars22)
       end if
       if (isfilevar(inptr2,"dst_a5") .and. isfilevar(inptr2,"dst_a7"))  then
        vars21 = inptr2->dst_a5
        vars22 = inptr2->dst_a7
        vars2 = vars21 + vars22
        delete (vars21)
        delete (vars22)
       end if
     end if
  else if vars(i).eq."SSALT" then
  ; bam
     if (isfilevar(inptr2,"SSLT01") .and. isfilevar(inptr2,"SSLT02") .and. isfilevar(inptr2,"SSLT03") .and. isfilevar(inptr2,"SSLT04")) then
       vars21 = inptr2->SSLT01
       vars22 = inptr2->SSLT02
       vars23 = inptr2->SSLT03
       vars24 = inptr2->SSLT04
       vars2 = vars21 + vars22 + vars23 + vars24
       delete (vars21)
       delete (vars22)
       delete (vars23)
       delete (vars24)
     else
  ; mam
       if (isfilevar(inptr2,"ncl_a1") .and. isfilevar(inptr2,"ncl_a2") .and. isfilevar(inptr2,"ncl_a3"))  then
        vars21 = inptr2->ncl_a1
        vars22 = inptr2->ncl_a2
        vars23 = inptr2->ncl_a3
        vars2 = vars21 + vars22 + vars23
        delete (vars21)
        delete (vars22)
        delete (vars23)
       end if
       if (isfilevar(inptr2,"ncl_a1") .and. isfilevar(inptr2,"ncl_a2") .and. isfilevar(inptr2,"ncl_a4") .and. isfilevar(inptr2,"ncl_a6"))  then
        vars21 = inptr2->ncl_a1
        vars22 = inptr2->ncl_a2
        vars23 = inptr2->ncl_a4
        vars24 = inptr2->ncl_a6
        vars2 = vars21 + vars22 + vars23 + vars24
        delete (vars21)
        delete (vars22)
        delete (vars23)
        delete (vars24)
       end if
     end if
  else if vars(i).eq."NOx_NOy" then
    if (isfilevar(inptr2,"NOX") .and. isfilevar(inptr2,"NOY"))   then
     vars21 = inptr2->NOX
     vars22 = inptr2->NOY
     vars2 = vars21/vars22
    else  
     if  (isfilevar(inptr2,"NO") .and. isfilevar(inptr2,"NO2") .and. isfilevar(inptr2,"NOY") ) then
     vars21 = inptr2->NO
     vars22 = inptr2->NO2
     vars23 = inptr2->NOY
     vars2 = (vars21+vars22)/vars23
     delete (vars21)
     delete (vars22)
     delete (vars23)
     end if
   end if
   else if vars(i).eq."OH" then
    if (isfilevar(inptr2,"OH"))  then
     vars2 = inptr2->$vars(i)$
;    vars2 = vars2*dens2 
   end if
   else 
   if (isfilevar(inptr2,vars(i))) then
     vars2 = inptr2->$vars(i)$
    else
     vars2 = vars2@_FillValue 
    end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
  end if
 if units1(i).eq."ug/m3"  then
  vars2 = vars2 * rho2  ; convert from mmr to ug/m3
 end if

      ptmp = press2/100.
      tmp = int2p_n_Wrap(ptmp,vars2,plvlM,interp,1)
      delete(ptmp)
      if (typeof(tmp).eq."double") then
        var3= dble2flt(tmp(0,:,:,:))          
      else
        var3 = tmp(0,:,:,:)                  ; 3D array (lev,lat,lon)
      end if
      var2 = dim_avg_Wrap(var3)               ; zonal ave -->(lev,lat)
      var2 = (/var2*factor(i)/)
      delete(tmp)
      delete(var3)
      delete(vars2)
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
      itop1 = itrop2             ; model 1 top
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
; data1 = var1(0:itop1,:)                   ; model data(lev,lat)
; data2 = var2(0:itop1,:)                    ; model or obs data(lev,lat)
  data1 = var1                   ; model data(lev,lat)
  data2 = var2                    ; model or obs data(lev,lat)
  data1!0 = "lev"
  data1!1 = "lat"
  data1@units = units(i)
  data2!0 = "lev"
  data2!1 = "lat"
  data2@units = units(i)
  
if (.not.all(ismissing(data1))) .and. (.not.all(ismissing(data2))) then
;------------------------- Open files for plots -----------------------------
    set_prefix = "cset2_"
  if (compare.eq."OBS") then
  else
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+vars(i)+"_perc_c")
      gsn_define_colormap(wks,cmap)
    else
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+vars(i))
    end if
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
  cres@gsnLeftString = vars(i) 
  cres@gsnRightString = units1(i)
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

  if (compare.ne."OBS") then   ; both are models on same pressure levels
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
    else                 
      C = data1                          ; copy dims,coords
      D = data1                          ; copy dims,coords


      data1 = where(data1.le.0.,data1@_FillValue,data1) 
      data2 = where(data2.le.0.,data2@_FillValue,data2) 
      C = (/data1-data2/)                ; get diff values 
      D = (/ 100*(data1-data2)/(0.5*(data2+data1)) /)                ; get diff values 
    end if
  ; if vars(i).eq."O3" .or. vars(i).eq."N2O" .or. vars(i).eq."HNO3" .or. vars(i).eq."NOY" then
    if vars(i).ne."NOx_NOy" then
    ;dcon(i,:)=30*(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
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
  cres@gsnRightString = units(i)
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
  delete (C)
  delete (mind)
  delete (maxd)
end if


;  delete (cres@trYMinF)
  delete (var1)
  delete (var2)
  delete (data1)
  delete (data2)
  if (compare.eq."OBS") then
    delete (lat2)
    delete (nlat2)
  end if
end do

end
