;   profiles_aircraft_emmons.ncl
; Plot vertical profiles from model and raobs data.
; Written by Simone Tilmes Dec. 2013
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
;load "$DIAG_CODE/taylor_diagram_bias.ncl"
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
 outfile_air   = getenv("DATA_PLOTVARS")  ; case1 output filename
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 ncdf_mode  = getenv("NCDF_MODE")
 if (compcase .ne. "NONE") then       ; more than one model
  outfile2   = getenv("CNTL_PLOTVARS")  ; case1 output filename
 end if

;********************************************************
; constants
 Cp = 1.00464e3   ; J/(K*kg)
 g  = 9.80616     ; m/s^2
 L  = 2.501e6     ; J/kg
 p0 = 1000.       ; mb required by vinth2p
 kboltz = 1.381e-23  ; J/K
 
 alt10 = ispan(0,20,1)
 nalt10 = dimsizes(alt10) 
; read master list file
;  read asci aircraft data regions and transport to ncdf, include date, latitute region etc
file_master = "$OBS_DATA/cam-chem/aircraft_campaign_dates_master_plot_2013.list"
nre = 161
z1 = asciiread(file_master,(/nre/),"string")
new_str = str_split_csv(z1, ",", 1)
region = new_str(:,0)
part = new_str(:,1)
year1 = stringtoint(new_str(:,2))
month1 = stringtoint(new_str(:,3))
month01 = sprinti("%0.2i",month1) 
month1 = where(month1.eq.12,0,month1)
day1 = stringtoint(new_str(:,4))
year2 = stringtoint(new_str(:,5)) 
month2 = stringtoint(new_str(:,6))
month01 = sprinti("%0.2i",month2) 
month2 = where(month2.eq.12,0,month2)
day2 = stringtoint(new_str(:,7))
alat1n = new_str(:,8)
alat2n = new_str(:,10)
alon1n = new_str(:,9)
alon2n = new_str(:,11)
alat1 = stringtofloat(new_str(:,8))
alon1 = stringtofloat(new_str(:,9))
alat2 = stringtofloat(new_str(:,10))
alon2 = stringtofloat(new_str(:,11)) 


; plot for each specie
;specs = (/"bc","benzene","c2h2","c2h4","c2h5oh","c2h6",("c3h6o"),"c3h8",("c6h6"),("c3h8c2h6"), \
;          "ccl4","cfc113","cfc11","cfc12","ch2brcl","ch3br",\
;          "ch3ccl3","ch3cho","ch3cl","ch3cn","ch3i","ch3oh","h2o2","h2o","hcfc22","hcn","hno3",\
;          "acet","isoprene","methanol","ethanol","toluene","ch4","co2","co",\
;          "n2o","no","noday","no2","nox","noy","o3","oh","pan","so2","so4","temperature"/)
; BC: CB1, CB2, bc_a1
; BENZENE: benzene, c6h6
; ch3oh (methanol)
;c2h5oh (ethonal)

specs = (/"benzene","c2h2","c2h4","c2h5oh","c2h6","c3h8", \
           "ccl4","cfc113","cfc11","cfc12","ch2brcl","ch3br",\
           "ch3ccl3","ch3cho","ch3cl","ch3cn","ch3i","ch3oh",\
           "h2o2","h2o","hcfc22","hcn","hno3", "acet","isoprene","toluene",\
           "ch4","co", "n2o","nox","noy","o3",\
           "oh","pan","so2","so4","temperature"/)
vars = (/"BENZENE","C2H2","C2H4","C2H5OH","C2H6","C3H8","CCL4","CFC113","CFC11","CFC12",\
         "CH2BRCL","CH3BR","CH3CCL3","CH3CHO","CH3CL","CH3CN","CH3I","CH3OH","H2O2","H2O",\
         "HCFC22","HCN","HNO3","CH3COCH3","ISOP","TOLUENE","CH4","CO",\
         "N2O","NOX","NOY","O3","OH","PAN","SO2","SO4","T"/)
variable = (/"Benzene","C~B~2~N~H~B~2~N","C~B~2~N~H~B~4~N","C~B~2~N~H~B~5~N~OH","C~B~2~N~H~B~6~N",\
          "C~B~3~N~H~B~8~N","CCl~B~4~N","CFC113","CFC11","CFC12",\
         "CH~B~2~N~BrCl","CH~B~3~N~Br","CH~B~3~N~CCl~B~3~N~","CH~B~3~N~CHO","CH~B~3~N~Cl","CH~B~3~N~CN","CH~B~3~N~I",\
         "CH~B~3~N~OH","H~B~2~N~O~B~2~N","H~B~2~N~O",\
         "HCFC22","HCN","HNO~B~3~N","CH~B~3~N~COCH~B~3~N","ISOP","TOLUENE","CH~B~4~N","CO",\
         "N~B~2~N~O","NO~B~X~N","NO~B~Y~N","O~B~3~N","OH","PAN","SO~B~2~N","SO~B~4~N","T"/)
units2 = (/"Benzene (ppt)","C~B~2~N~H~B~2~N~ (ppt)","C~B~2~N~H~B~4~N~ (ppt)","C~B~2~N~H~B~5~N~OH (ppt)","C~B~2~N~H~B~6~N~ (ppt)",\
          "C~B~3~N~H~B~8~N~ (ppt)","CCl~B~4~N~ (ppt)","CFC113 (ppt)","CFC11 (ppt)","CFC12 (ppt)",\
         "CH~B~2~N~BrCl (ppt)","CH~B~3~N~Br (ppt)","CH~B~3~N~CCl~B~3~N~ (ppt)","CH~B~3~N~CHO (ppt)","CH~B~3~N~Cl (ppt)","CH~B~3~N~CN (ppt)","CH~B~3~N~I (ppt)",\
         "CH~B~3~N~OH (ppt)","H~B~2~N~O~B~2~N~ (ppt)","H~B~2~N~O (ppb)",\
         "HCFC22 (ppt)","HCN (ppt)","HNO~B~3~N~ (ppb)","CH~B~3~N~COCH~B~3~N~ (ppt)","ISOP (ppt)","TOLUENE (ppt)","CH~B~4~N~ (ppm)","CO (ppb)",\
         "N~B~2~N~O (ppb)","NO~B~X~N~ (ppt)","NO~B~Y~N~ (ppt)","O~B~3~N~ (ppb)","OH (molc/cc)","PAN (ppt)","SO~B~2~N~ (ppt)","SO~B~4~N~ (ppt)","T"/)

units_var= (/"ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppt", "ppm", "ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppb", "ppb", "ppb", "ppt", "ppt", "ppb", \
         "molec/cc", "ppt", "ppt", "ppt", "K" /)
;vars = (/"BC","BENZENE","C2H2","C2H4","C2H5OH","C2H6","C3H8","CCL4","CFC113","CFC11","CFC12"/)
;vars = (/"C2H2","C2H4","O3","H2O2"/)
;variable = (/"C~B~2~N~H~B~2~N","C~B~2~N~H~B~4~N","O~B~3~N","H~B~2~N~O~B~2~N"/)
factor = (/1.e+12,1.e+12,1.e+12,1.e+12,1.e+12,1.e+12, \
           1.e+12,1.e+12,1.e+12,1.e+12,1.e+12,1.e+12, \
           1.e+12,1.e+12,1.e+12,1.e+12,1.e+12,1.e+12, \
           1.e+09,1.e+06,1.e+12,1.e+12,1.e+12, 1.e+12,1.e+12,1.e+12,\
           1.e+06,1.e+09,1.e+09,1.e+12,1.e+12, 1.e+09,\
           1.e-06,1.e+12,1.e+12,1.e+12,1./)
nvars = dimsizes(vars)
units_var= (/"ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppt", "ppm", "ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppb", "ppb", "ppb", "ppt", "ppt", "ppb", \
         "molec/cc", "ppt", "ppt", "ppt", "K" /)
        
         
xlog = (/0,0,0,0,0,0,\
         0,0,0,0,0,0,\
         0,0,0,0,0,0,\
         0,0,0,0,0,0,0,0,\
         0,0,0,0,0,0,\
         0,0,0,0,0 /)
 

; read all monthly  model data
file01_1 = testcase+"_01_climo.nc"
file02_1 = testcase+"_02_climo.nc"
file03_1 = testcase+"_03_climo.nc"
file04_1 = testcase+"_04_climo.nc"
file05_1 = testcase+"_05_climo.nc"
file06_1 = testcase+"_06_climo.nc"
file07_1 = testcase+"_07_climo.nc"
file08_1 = testcase+"_08_climo.nc"
file09_1 = testcase+"_09_climo.nc"
file10_1 = testcase+"_10_climo.nc"
file11_1 = testcase+"_11_climo.nc"
file12_1 = testcase+"_12_climo.nc"

if (compcase .ne. "NONE") then       ; more than one model
file01_2 = compcase+"_01_climo.nc"
file02_2 = compcase+"_02_climo.nc"
file03_2 = compcase+"_03_climo.nc"
file04_2 = compcase+"_04_climo.nc"
file05_2 = compcase+"_05_climo.nc"
file06_2 = compcase+"_06_climo.nc"
file07_2 = compcase+"_07_climo.nc"
file08_2 = compcase+"_08_climo.nc"
file09_2 = compcase+"_09_climo.nc"
file10_2 = compcase+"_10_climo.nc"
file11_2 = compcase+"_11_climo.nc"
file12_2 = compcase+"_12_climo.nc"
end if

in_f01_1 = addfile(file01_1,"r")
in_f02_1 = addfile(file02_1,"r")
in_f03_1 = addfile(file03_1,"r")
in_f04_1 = addfile(file04_1,"r")
in_f05_1 = addfile(file05_1,"r")
in_f06_1 = addfile(file06_1,"r")
in_f07_1 = addfile(file07_1,"r")
in_f08_1 = addfile(file08_1,"r")
in_f09_1 = addfile(file09_1,"r")
in_f10_1 = addfile(file10_1,"r")
in_f11_1 = addfile(file11_1,"r")
in_f12_1 = addfile(file12_1,"r")

if (compcase .ne. "NONE") then       ; more than one model
in_f01_2 = addfile(file01_2,"r")
in_f02_2 = addfile(file02_2,"r")
in_f03_2 = addfile(file03_2,"r")
in_f04_2 = addfile(file04_2,"r")
in_f05_2 = addfile(file05_2,"r")
in_f06_2 = addfile(file06_2,"r")
in_f07_2 = addfile(file07_2,"r")
in_f08_2 = addfile(file08_2,"r")
in_f09_2 = addfile(file09_2,"r")
in_f10_2 = addfile(file10_2,"r")
in_f11_2 = addfile(file11_2,"r")
in_f12_2 = addfile(file12_2,"r")
end if


; get some time and spatially independent data from the model files
in1 = in_f01_1
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
 ; get press, temp
 ; xval1 = oh*pres_ac*100./kboltz /temp_k *1.e-6 * 1.e-12 (in ppt)
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

exists = isfilepresent(outfile_air)
if(exists) then
 outptr_air = addfile(outfile_air,"w")
else
 outptr_air = addfile(outfile_air,"c")
end if

exists = isfilepresent(outfile1)
if(exists) then
   outptr1 = addfile(outfile1,"w")
 else
   outptr1 = addfile(outfile1,"c")
end if
if (compcase .ne. "NONE") then       ; more than one model
 exists2 = isfilepresent(outfile2)
 if(exists2) then
   outptr2 = addfile(outfile2,"w")
 else
   outptr2 = addfile(outfile2,"c")
 end if
end if

if (compcase .ne. "NONE") then       ; more than one model
  in2 = in_f01_2
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
 
end if

factor_air = new(nalt10,"float")
factor_air(:) = 1.
units_air = new(nre,"string")

;  read model data and interpolate to region/date
  ;   model data
; for all months:
; loop through test and control case 
 if (compcase .eq. "NONE") then       ; more than one model
  lo = 1
 else 
  lo = 2
 end if
 do l = 0, lo -1 
 if l .eq. 0 then 
   outptr = outptr1
   outfile =outfile1 
   nlev = nlev1
   hyam = hyam1 
   hybm = hybm1 
   in_f01 = in_f01_1
   in_f02 = in_f02_1
   in_f03 = in_f03_1
   in_f04 = in_f04_1
   in_f05 = in_f05_1
   in_f06 = in_f06_1
   in_f07 = in_f07_1
   in_f08 = in_f08_1
   in_f09 = in_f09_1
   in_f10 = in_f10_1
   in_f11 = in_f11_1
   in_f12 = in_f12_1
 else 
   outptr = outptr2
   outfile =outfile2 
   nlev = nlev2
   hyam = hyam2 
   hybm = hybm2 
   in_f01 = in_f01_2
   in_f02 = in_f02_2
   in_f03 = in_f03_2
   in_f04 = in_f04_2
   in_f05 = in_f05_2
   in_f06 = in_f06_2
   in_f07 = in_f07_2
   in_f08 = in_f08_2
   in_f09 = in_f09_2
   in_f10 = in_f10_2
   in_f11 = in_f11_2
   in_f12 = in_f12_2
 end if

 if isfilevar(outptr,"profiles10_model_dmn1") .or. isfilevar(outptr,"profiles10_model_dmn2") then
  if l.eq.0 then
     profiles_model_alt1 = outptr1->profiles_model_alt1
     profiles_model_dmn1 = outptr1->profiles_model_dmn1
     profiles10_model_dmn1 = outptr1->profiles10_model_dmn1
     profiles10_model_press1 = outptr1->profiles10_model_press1
     profiles10_model_temp1 = outptr1->profiles10_model_temp1
  else
     profiles_model_alt2 = outptr2->profiles_model_alt2
     profiles_model_dmn2 = outptr2->profiles_model_dmn2
     profiles10_model_dmn2 = outptr2->profiles10_model_dmn2
     profiles10_model_press2 = outptr2->profiles10_model_press2
     profiles10_model_temp2 = outptr2->profiles10_model_temp2
  end if
else
 print(outfile+" calculate aircraft averages for model regions, takes a while....")
 profiles10_model_dmn = new((/nvars,nre,nalt10/),"float")
; unit conversion
 profiles10_model_temp = new((/nvars,nre,nalt10/),"float")
 profiles10_model_press = new((/nvars,nre,nalt10/),"float")
 profiles_model_dmn = new((/nvars,nre,nlev/),"float")
 profiles_model_alt = new((/nvars,nre,nlev/),"float")
do v = 0,nvars-1 
  do re = 0,nre -1 
  if vars(v) .eq. "NOX" then
    if isfilevar(in_f01, "NOX") then
    else 
     if isfilevar(in_f01, "NO") .AND. isfilevar(in_f01, "NO2") then
      vars(v) = "NO2"
     end if
    end if
  end if
  if isfilevar(in_f01, vars(v)) then
   lonmin = alon1(re)
   lonmax = alon2(re)
   latmin = alat1(re)
   latmax = alat2(re)
   if month1(re).eq.1 then
    in11 = in_f01  ; testcase
   end if
   if month1(re).eq.2 then
    in11 = in_f02  ; testcase
   end if
   if month1(re).eq.3 then
    in11 = in_f03  ; testcase
   end if
   if month1(re).eq.4 then
    in11 = in_f04  ; testcase
   end if
   if month1(re).eq.5 then
    in11 = in_f05 ; testcase
   end if
   if month1(re).eq.6 then
    in11 = in_f06  ; testcase
   end if
   if month1(re).eq.7 then
    in11 = in_f07  ; testcase
   end if
   if month1(re).eq.8 then
    in11 = in_f08  ; testcase
   end if
   if month1(re).eq.9 then
    in11 = in_f09 ; testcase
   end if
   if month1(re).eq.10 then
    in11 = in_f10  ; testcase
   end if
   if month1(re).eq.11 then
    in11 = in_f11  ; testcase
   end if
   if month1(re).eq.0 then
    in11 = in_f12  ; testcase
   end if

 if isfilevar(in11, "PHIS") .and. isfilevar(in11, "PS") then
 else
  print("can't continue")
  exit
 end if
   
   var11 = in11->$vars(v)$
   if vars(v) .eq. "NO2"  then
     var111 = in11->NO
     var112 = in11->NO2
     var11 = var111+var112
     delete(var111)
     delete(var112)
   end if

   alt_mo11 = in11->Z3           ; altitude (time,alt,lat,lon)
  
   phis = in11->PHIS   ; (time,lat,lon)
   ps1 = in11->PS   ; (time,lat,lon)
   temp_mo11 = in11->T  ; (time,lat,lon)
   press_mo11 = pres_hybrid_ccm (ps1,p0,hyam,hybm)
;  copy_VarCoords(temp_mo11,press_mo11)

   if vars(v).eq."OH" then 
   ; convert to molec/cc
      kboltz = 1.381e-23  ; J/K
      var11 = var11*press_mo11/kboltz /temp_mo11 *1.e-6 
   end if
   
   alt_local = (conform_dims(dimsizes(alt_mo11),phis,(/0,2,3/))/9.81)
   alt_mo11 = alt_mo11-alt_local
   
   delete(phis)
   delete(ps1)
   delete(alt_local)

   if month2(re).ne.month1(re) then
   if month2(re).eq.1 then
    in21 = in_f01  ; testcase
   end if
   if month2(re).eq.2 then
    in21 = in_f02  ; testcase
   end if
   if month2(re).eq.3 then
    in21 = in_f03  ; testcase
   end if
   if month2(re).eq.4 then
    in21 = in_f04  ; testcase
   end if
   if month2(re).eq.5 then
    in21 = in_f05  ; testcase
   end if
   if month2(re).eq.6 then
    in21 = in_f06 ; testcase
   end if
   if month2(re).eq.7 then
    in21 = in_f07  ; testcase
   end if
   if month2(re).eq.8 then
    in21 = in_f08  ; testcase
   end if
   if month2(re).eq.9 then
    in21 = in_f09  ; testcase
   end if
   if month2(re).eq.10 then
    in21 = in_f10  ; testcase
   end if
   if month2(re).eq.11 then
    in21 = in_f11  ; testcase
   end if
   if month2(re).eq.0 then
    in21 = in_f12  ; testcase
   end if
   if isfilevar(in21, "PHIS") .and. isfilevar(in21, "PS") then
    else
       print("can't continue")
        exit
    end if

   var21 = in21->$vars(v)$
   if vars(v) .eq. "NO2"  then
     var211 = in21->NO
     var212 = in21->NO2
     var21 = var211+var212
     delete(var211)
     delete(var212)
   end if
   alt_mo21 = in21->Z3           ; altitude (time,alt,lat,lon)
   phis = in21->PHIS   ; (time,lat,lon)
   alt_local = (conform_dims(dimsizes(alt_mo21),phis,(/0,2,3/))/9.81)
   alt_mo21 = alt_mo21-alt_local
   ps2 = in21->PS   ; (time,lat,lon)
   temp_mo21 = in21->T  ; (time,lat,lon)
   press_mo21 = pres_hybrid_ccm (ps2,p0,hyam,hybm)
   if vars(v).eq."OH" then
   ; convert to molec/cc
      kboltz = 1.381e-23  ; J/K
      var21 = var21*press_mo21/kboltz /temp_mo21 *1.e-6
   end if

   delete(ps2)
   delete(phis)
   delete(alt_local)

   var_1 = array_append_record (var11,var21, 0)
   delete(var21)
   var11 = dim_avg_n_Wrap(var_1, 0)
   alt_1 = array_append_record (alt_mo11,alt_mo21, 0)
   press_1 = array_append_record (press_mo11,press_mo21, 0)
   temp_1 = array_append_record (temp_mo11,temp_mo21, 0)
   alt_mo11 = dim_avg_n_Wrap(alt_1, 0)
   press_mo11 = dim_avg_n_Wrap(press_1, 0)
   temp_mo11 = dim_avg_n_Wrap(temp_1, 0)
   delete(alt_mo21)
   delete(press_mo21)
   delete(temp_mo21)
   delete(var_1)
   delete(alt_1)
   delete(temp_1)
   delete(press_1)
   end if ; month1.ne.month2
   copy_VarCoords(alt_mo11,temp_mo11)
   copy_VarCoords(alt_mo11,press_mo11)

  ; interpolate and average over region 
  ;     get model variable data
      ; if (typeof(var_mo1_re1).eq."double") then
      ;   var_mo1_re1 = dble2flt(var_mo1_re1)
      ;   var_mo1_re2 = dble2flt(var_mo1_re2)
      ; end if
   t1r = var11(0,:,{latmin:latmax},{lonmin:lonmax})
   z1r = alt_mo11(0,:,{latmin:latmax},{lonmin:lonmax})
   p1r = press_mo11(0,:,{latmin:latmax},{lonmin:lonmax})
   temp1r = temp_mo11(0,:,{latmin:latmax},{lonmin:lonmax})
   delete(alt_mo11)
   delete(press_mo11)
   delete(temp_mo11)
    
  ;   average over lon/lat
   tr = dim_avg_n_Wrap(t1r,(/1,2/))*factor(v)
   zr = dim_avg_n_Wrap(z1r,(/1,2/))/1000.  ; in km
   pr = dim_avg_n_Wrap(p1r,(/1,2/))/1000.  ; in km
   tempr = dim_avg_n_Wrap(temp1r,(/1,2/))/1000.  ; in km
   tr = tr(::-1)
   zr = zr(::-1)
   pr = pr(::-1)
   tempr = tempr(::-1)
 ; interpolate to aircraft altitudes alt10
   tr_alt10 = linint1_n_Wrap(zr,tr,False,alt10,0,0)
   pr_alt10 = linint1_n_Wrap(zr,pr,False,alt10,0,0)
   tempr_alt10 = linint1_n_Wrap(zr,tempr,False,alt10,0,0)
   delete(t1r)
   delete(z1r)
   delete(p1r)
   delete(pr)
   delete(temp1r)
   delete(tempr)
   delete(var11)
  else 
   tr = new(nlev,"float")
   tr!0 =  "lev"
   zr = new(nlev,"float")
   zr!0 =  "lev"
   tr_alt10 = new(nalt10,"float")
   tr_alt10!0 =  "lev"
   pr_alt10 = new(nalt10,"float")
   pr_alt10!0 =  "lev"
   tempr_alt10 = new(nalt10,"float")
   tempr_alt10!0 =  "lev"
  end if  ; if var exists
  
  profiles_model_dmn(v,re,:) = (/tr/)
  profiles10_model_dmn(v,re,:) = (/tr_alt10/)
  profiles10_model_press(v,re,:) = (/pr_alt10/)
  profiles10_model_temp(v,re,:) = (/tempr_alt10/)
  profiles_model_alt(v,re,:) = (/zr/)
  delete(tr)
  delete(zr)
  delete(tr_alt10)
  delete(pr_alt10)
  delete(tempr_alt10)
; delete(in11)
 end do ; loop region 
 if (vars(v).eq."NO2") then
   vars(v) = "NOX"
 end if
 end do ; v
  if l.eq.0 then 
     profiles_model_dmn1 = profiles_model_dmn
     profiles_model_alt1 = profiles_model_alt
     profiles10_model_dmn1 = profiles10_model_dmn
     profiles10_model_press1 = profiles10_model_press
     profiles10_model_temp1 = profiles10_model_temp
     outptr1->profiles_model_alt1=profiles_model_alt1
     outptr1->profiles_model_dmn1=profiles_model_dmn1
     outptr1->profiles10_model_dmn1=profiles10_model_dmn1
     outptr1->profiles10_model_press1=profiles10_model_press1
     outptr1->profiles10_model_temp1=profiles10_model_temp1
  else
     profiles_model_alt2 = profiles_model_alt
     profiles_model_dmn2 = profiles_model_dmn
     profiles10_model_dmn2 = profiles10_model_dmn
     profiles10_model_press2 = profiles10_model_press
     profiles10_model_temp2 = profiles10_model_temp
     outptr2->profiles_model_alt2=profiles_model_alt2
     outptr2->profiles_model_dmn2=profiles_model_dmn2
     outptr2->profiles10_model_dmn2=profiles10_model_dmn2
     outptr2->profiles10_model_press2=profiles10_model_press2
     outptr2->profiles10_model_temp2=profiles10_model_temp2
  end if
 delete(profiles_model_dmn)
 delete(profiles10_model_dmn)
 delete(profiles10_model_press)
 delete(profiles10_model_temp)
 delete(profiles_model_alt)
 end if ; calc model 
 delete(hyam)
 delete(hybm)
end do ; l loop

 ; create plots for different species
 if isfilevar(outptr_air, "profiles_dmn") then
     profiles_dmn = outptr_air->profiles_dmn
     profiles_alt = outptr_air->profiles_alt
     profiles_p25 = outptr_air->profiles_p25
     profiles_p75 = outptr_air->profiles_p75
     avail = outptr_air->avail
 else
 profiles_dmn = new((/nvars,nre,nalt10/),"float")
 profiles_alt = new((/nvars,nre,nalt10/),"float")
 profiles_p25 = new((/nvars,nre,nalt10/),"float")
 profiles_p75 = new((/nvars,nre,nalt10/),"float")
 avail = new((/nvars,nre/),"integer")
 avail(:,:) = 0

 do v = 0,nvars-1
; find cases where variables are observed:
 do re = 0,nre -1
  lonmin = alon1(re)
  lonmax = alon2(re)
  latmin = alat1(re)
  latmax = alat2(re)
  file_ncdf = "$OBS_DATA/cam-chem/"+region(re)+"_"+specs(v)+"_"+str_split(part(re), " ")+".nc"
  exists = isfilepresent(file_ncdf)
  no2 = 0
  if specs(v).eq."nox" .and. .not.exists then
    file_ncdf2 = "$OBS_DATA/cam-chem/"+region(re)+"_no2_"+str_split(part(re), " ")+".nc"
    file_ncdf3 = "$OBS_DATA/cam-chem/"+region(re)+"_no_"+str_split(part(re), " ")+".nc"
    exists = isfilepresent(file_ncdf2)
    file_ncdf = file_ncdf2
    exists3 = isfilepresent(file_ncdf3)
    no2 = 1 
  end if
  
  if(exists) then
    avail(v,re) = 1
    a = addfile(file_ncdf,"r")
    alt_air = a->alt
    dmn_air = a->dmed

    units_air(re) = dmn_air@units
    p25_air = a->d25pt
    p75_air = a->d75pt
   if specs(v).eq."nox" .and. no2.eq.1 then
     if(exists3) then
      a3 = addfile(file_ncdf,"r")
      dmn_air3 = a->dmed
      p25_air3 = a->d25pt
      p75_air3 = a->d75pt
      dmn_air = dmn_air + dmn_air3
      p25_air = p25_air + p25_air3
      p75_air = p75_air + p75_air3
      delete(dmn_air3)
      delete(p25_air3)
      delete(p75_air3)
     end if
   end if

    nalt_air = dimsizes(alt_air)

    if specs(v).eq."oh" then
      if units_air(re).eq."[ppt]" then
        factor_air = profiles10_model_press1(v,re,:)/kboltz /profiles10_model_temp1(v,re,:)*1.e-6 * 1.e-12 *1.e-06
      else
         if max(dmn_air).gt.1.e+04 then 
          factor_air(:) = 1.e-06
         else
          factor_air(:) = 0.1
         end if
      end if
    else
      factor_air(:) = 1.
    end if
    if specs(v).eq."nox" .and. no2.eq.0 then
    if ((units_air(re).eq."[ppb]".or.units_air(re).eq."ppbv") .and. units_var(v).eq."ppt") then
      factor_air = 1.e+03
    else
      factor_air(:) = 1.
    end if
    end if
    if specs(v).eq."noy" .or. specs(v).eq."hno3" .or. specs(v).eq."so2" .or. specs(v).eq."so4" then
    if region(re) .eq. "CalNex2010" .or. region(re) .eq. "ARCPAC2008" .or. region(re).eq. "TexAQS2006"  .or.  region(re) .eq. "SOS1999" .or. region(re) .eq. "TexAQS2000" .or. region(re) .eq. "ITCT2002" .or. region(re) .eq. "NEAQSITCT2004" then
    if ((units_air(re).eq."[ppb]".or.units_air(re).eq."ppbv") .and. units_var(v).eq."ppt") then
      factor_air = 1.e+03
    else
      factor_air(:) = 1.
    end if
    end if
    end if
    if specs(v).eq."so4" then
    if region(re) .eq. "CalNex2010" .or. region(re) .eq. "ARCPAC2008" .or. region(re).eq. "TexAQS2006"  .or.  region(re) .eq. "SOS1999" .or. region(re) .eq. "TexAQS2000" .or. region(re) .eq. "ITCT2002" .or. region(re) .eq. "NEAQSITCT2004" .or. region(re) .eq. "ARCTAS" then
      factor_air = 1.e+03
    else
      factor_air(:) = 1.
    end if
    end if

    if specs(v).eq."pan" then
    if region(re) .eq. "TexAQS2000" .or. region(re) .eq. "SOS1999" then
      factor_air = 1.e+03
    else
      factor_air(:) = 1.
    end if
    end if
    

    if specs(v).eq."h2o2" then
     factor_air(:) = 1.e-03
    end if
    if specs(v).eq."ch4" then
     factor_air(:) = 1.e-03
    end if

   dmn_air = dmn_air*factor_air(0:nalt_air-1)
   p25_air = p25_air*factor_air(0:nalt_air-1)
   p75_air = p75_air*factor_air(0:nalt_air-1)
   profiles_dmn(v,re,0:nalt_air-1) = dmn_air
   profiles_p25(v,re,0:nalt_air-1) = p25_air
   profiles_p75(v,re,0:nalt_air-1) = p75_air
   profiles_alt(v,re,0:nalt_air-1) = alt_air
   delete(alt_air)
   delete(dmn_air)
   delete(p25_air)
   delete(p75_air)
  end if
  end do ; re
  end do ;v
   outptr_air->profiles_dmn=profiles_dmn
   outptr_air->profiles_p25=profiles_p25
   outptr_air->profiles_p75=profiles_p75
   outptr_air->profiles_alt=profiles_alt
   outptr_air->avail=avail
  end if
;aircraft

; sort in years and  region, season
season = (/"DJF","MAM","JJA","SON"/)
la_region = (/"SH","Tropics","NH_Midlat","NH_Polar"/)
la_region_n = (/"Southern Hemisphere","Tropics","Northern Hemisphere Midlat","Northern Hemisphere Polar"/)
;inv_1995 = ind(avail.eq.1 .and. year1.ge.1995)
lat_mean = (alat1+alat2)/2.
min_lat = (/-90,-30,30,60/)
max_lat = (/-30,30,60,90/)
zdim = (/8,16,10,8/)

; plot region, and season for each specie:
do v = 0, nvars - 1
mean_re_se_trop_air = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
mean_re_se_trop1 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
reldiff_re_se_trop1 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
corr_re_se_trop1 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
mean_re_se_surf_air = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
mean_re_se_surf1 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
corr_re_se_surf1 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
reldiff_re_se_surf1 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
mean_re_se_trop_air@_FillValue = -999.
mean_re_se_surf_air@_FillValue = -999.
mean_re_se_trop1@_FillValue = -999.
mean_re_se_surf1@_FillValue = -999.
corr_re_se_trop1@_FillValue = -999.
corr_re_se_surf1@_FillValue = -999.
reldiff_re_se_trop1@_FillValue = -999.
reldiff_re_se_surf1@_FillValue = -999.

mean_re_se_trop_air(:,:,:) = mean_re_se_trop_air@_FillValue
mean_re_se_surf_air(:,:,:) = mean_re_se_surf_air@_FillValue
mean_re_se_trop1(:,:,:) = mean_re_se_trop1@_FillValue
mean_re_se_surf1(:,:,:) = mean_re_se_surf1@_FillValue
corr_re_se_trop1(:,:,:) = corr_re_se_trop1@_FillValue
corr_re_se_surf1(:,:,:) = corr_re_se_surf1@_FillValue
reldiff_re_se_trop1(:,:,:) = reldiff_re_se_trop1@_FillValue
reldiff_re_se_surf1(:,:,:) = reldiff_re_se_surf1@_FillValue

if (compcase.ne."NONE") then       ; compare 2 models to raobs
  mean_re_se_trop2 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
  corr_re_se_trop2 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
  reldiff_re_se_trop2 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
  mean_re_se_surf2 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
  corr_re_se_surf2 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
  reldiff_re_se_surf2 = new((/4,4,25/),"float") ; four regions, four seasons, up to 25 profiles 
  mean_re_se_trop2@_FillValue = -999.
  mean_re_se_surf2@_FillValue = -999.
  corr_re_se_trop2@_FillValue = -999.
  corr_re_se_surf2@_FillValue = -999.
  reldiff_re_se_trop2@_FillValue = -999.
  reldiff_re_se_surf2@_FillValue = -999.
  mean_re_se_trop2(:,:,:) = mean_re_se_trop2@_FillValue
  mean_re_se_surf2(:,:,:) = mean_re_se_surf2@_FillValue
  corr_re_se_trop2(:,:,:) = corr_re_se_trop2@_FillValue
  corr_re_se_surf2(:,:,:) = corr_re_se_surf2@_FillValue
  reldiff_re_se_trop2(:,:,:) = reldiff_re_se_trop2@_FillValue
  reldiff_re_se_surf2(:,:,:) = reldiff_re_se_surf2@_FillValue
end if
trop_max = (/7,9,8,7/) ; hight of averaged tropospheric profile
surf_max = (/3,3,2,3/) ; hight of averaged tropospheric profile

se1 = (/2,5,8,11/)
se2 = (/0,3,6,9/)
do se = 0, 3 
 do la_re = 0, 3 
   inv_1995_lat_re = ind(avail(v,:).eq.1 .and. year1.ge.1995 .and. lat_mean.ge.min_lat(la_re) .and. lat_mean.le.max_lat(la_re) .and. month1.le.se1(se)  .and. month1.ge.se2(se)-1)

; inv_1995_lat_re_DJF = ind(avail(v,:).eq.1 .and. year1.ge.1995 .and. lat_mean.ge.min_lat(la_re) .and. lat_mean.le.max_lat(la_re) .and. month1.le.2 .and. month2.le.3)
; inv_1995_lat_re_MAM = ind(avail(v,:).eq.1 .and. year1.ge.1995 .and. lat_mean.ge.min_lat(la_re) .and. lat_mean.le.max_lat(la_re) .and. month1.le.5 .and. month2.le.6 .and. month1.ge.2 .and. month2.ge.3)
; inv_1995_lat_re_JJA = ind(avail(v,:).eq.1 .and. year1.ge.1995 .and. lat_mean.ge.min_lat(la_re) .and. lat_mean.le.max_lat(la_re) .and. month1.le.8 .and. month2.le.9 .and. month1.ge.5 .and. month2.ge.6)
; inv_1995_lat_re_SON = ind(avail(v,:).eq.1 .and. year1.ge.1995 .and. lat_mean.ge.min_lat(la_re) .and. lat_mean.le.max_lat(la_re) .and. month1.le.11 .and. month2.le.12 .and. month1.ge.8 .and. month2.ge.9)

 nall = 0
 nm = 9
 n = 3
 m = 3
 if (.not.all(ismissing(inv_1995_lat_re))) then
   nall = dimsizes(inv_1995_lat_re)
   if (nall .gt. 9) then    
      n = 4
      m = 3
   end if
   if (nall .gt. 12) then    
      n = 4
      m = 4
   end if
   if (nall .gt. 16) then    
      n = 5
      m = 4
   end if
   if (nall .gt. 20) then    
      n = 5
      m = 5
   end if
   nm = n*m
 end if


if nall.gt.0 then
; setup plot
;********************************************************
; define plot generals
;********************************************************
 res                 = True
 res@trYMaxF = zdim(la_re) 
 res@trYMinF = 0.0
 if (compcase.ne."NONE") then       ; compare 2 models to raobs
   res@xyLineColors    = (/"black","red","blue"/)
   res@xyLineThicknesses = (/2,2,2/)
   res@xyMarkLineModes   = (/"Lines","Lines","Lines"/)
   res@xyDashPatterns    = (/0,0,0/)
   res@xyMarkers         = (/0,0,0/)
 else                              ; compare model to raobs
   res@xyLineColors    = (/"black","red"/)
   res@xyLineThicknesses = (/2,2/)
   res@xyMarkLineModes   = (/"Lines","Lines"/)
   res@xyDashPatterns    = (/0,1/)
   res@xyMarkers         = (/0,0/)
 end if
 res@pmLegendWidthF = 0.15
 res@pmLegendHeightF = 0.15
 res@lgLabelFontHeightF = .025
 res@lgPerimOn = True
 res@txFontHeightF = 0.024

;*********************************************************************
; define plot
 wks = gsn_open_wks(plot_type,wkdir+"cset6_emmons_"+la_region(la_re)+"_"+season(se)+"_"+vars(v)+"_profiles")
  plot = new(nm,"graphic")
  error_bar1 = new((/nall,nalt10/),graphic)
  error_bar2 = new((/nall,nalt10/),graphic)
  error_bar3 = new((/nall,nalt10/),graphic)
  error_bar4 = new((/nall,nalt10/),graphic)
; error_bar5 = new((/nall,nalt10/),graphic)

  do re = 0, nall-1                 ; loop over aircraft campaigns in that region
    
    res@tiXAxisString = units2(v)
  ; res@tiXAxisString = variable(v)
    if xlog(v).eq.0 then
        res@trXAxisType = "LinearAxis"
    else
        res@trXAxisType = "LogAxis"
    end if
   ;res@trXMaxF =xmax(v)
   ;res@trXMinF =xmin(v)
    if (compcase .ne. "NONE") then       ; more than one model
       res@xyExplicitLegendLabels = (/"Data",case1,case2/)
    else
       res@xyExplicitLegendLabels = (/"Data",case1/)
    end if
   ;  aircraft(re1(re))
   ; obs data file
 ; if (.not.all(ismissing(inv_1995_lat_re))) then
    air_dmn = profiles_dmn(v,inv_1995_lat_re(re),:)
    air_p25 = profiles_p25(v,inv_1995_lat_re(re),:)
    air_p75 = profiles_p75(v,inv_1995_lat_re(re),:)
    air_alt = profiles_alt(v,inv_1995_lat_re(re),:)
    model_dmn1 = profiles_model_dmn1(v,inv_1995_lat_re(re),:) 
    model10_dmn1 = profiles10_model_dmn1(v,inv_1995_lat_re(re),:) 
    model_alt1 = profiles_model_alt1(v,inv_1995_lat_re(re),:)
    model10_press1 = profiles10_model_press1(v,inv_1995_lat_re(re),:)
    model10_temp1 = profiles10_model_temp1(v,inv_1995_lat_re(re),:)

    if (.not.all(ismissing(air_dmn(surf_max(la_re):trop_max(la_re))))) then 
     mean_re_se_trop_air(la_re,se,re) = dim_avg_Wrap(air_dmn(surf_max(la_re):trop_max(la_re)))
    end if
    if (.not.all(ismissing(model10_dmn1(surf_max(la_re):trop_max(la_re))))) then 
     mean_re_se_trop1(la_re,se,re) = dim_avg_Wrap(model10_dmn1(surf_max(la_re):trop_max(la_re))) 
    end if
    if (.not.all(ismissing(mean_re_se_trop1(la_re,se,re)))) .and. (.not.all(ismissing(mean_re_se_trop_air(la_re,se,re)))) then
     reldiff_re_se_trop1(la_re,se,re) = 1+ (mean_re_se_trop1(la_re,se,re)-mean_re_se_trop_air(la_re,se,re))/mean_re_se_trop_air(la_re,se,re) 
 ;   corr_re_se_trop1(la_re,se,re) = escorc(air_dmn(surf_max(la_re):trop_max(la_re)),model10_dmn1(surf_max(la_re):trop_max(la_re)))
    end if
    if (.not.all(ismissing(air_dmn(0:surf_max(la_re))))) then 
     mean_re_se_surf_air(la_re,se,re) = dim_avg_Wrap(air_dmn(0:surf_max(la_re))) 
    end if
    if (.not.all(ismissing(model10_dmn1(0:surf_max(la_re))))) then 
     mean_re_se_surf1(la_re,se,re) = dim_avg_Wrap(model10_dmn1(0:surf_max(la_re))) 
    end if
    if (.not.all(ismissing(mean_re_se_surf1(la_re,se,re)))) .and. (.not.all(ismissing(mean_re_se_surf_air(la_re,se,re)))) then
     reldiff_re_se_surf1(la_re,se,re) = 1+ (mean_re_se_surf1(la_re,se,re)-mean_re_se_surf_air(la_re,se,re))/mean_re_se_surf_air(la_re,se,re) 
 ;   corr_re_se_surf1(la_re,se,re) = escorc(air_dmn(0:surf_max(la_re)),model10_dmn1(0:surf_max(la_re)))
    end if
    if (compcase .ne. "NONE") then       ; more than one model
     model_dmn2 = profiles_model_dmn2(v,inv_1995_lat_re(re),:) 
     model10_dmn2 = profiles10_model_dmn2(v,inv_1995_lat_re(re),:) 
     model_alt2 = profiles_model_alt2(v,inv_1995_lat_re(re),:)
     model10_press2 = profiles10_model_press2(v,inv_1995_lat_re(re),:)
     model10_temp2 = profiles10_model_temp2(v,inv_1995_lat_re(re),:)
      
      if (.not.all(ismissing(model10_dmn2(surf_max(la_re):trop_max(la_re))))) then
        mean_re_se_trop2(la_re,se,re) = dim_avg_Wrap(model10_dmn2(surf_max(la_re):trop_max(la_re)))
      end if
      if (.not.all(ismissing(mean_re_se_trop2(la_re,se,re)))) .and. (.not.all(ismissing(mean_re_se_trop_air(la_re,se,re)))) then
        reldiff_re_se_trop2(la_re,se,re) = 1+ (mean_re_se_trop2(la_re,se,re)-mean_re_se_trop_air(la_re,se,re))/mean_re_se_trop_air(la_re,se,re)
  ;     corr_re_se_trop2(la_re,se,re) = escorc(air_dmn(surf_max(la_re):trop_max(la_re)),model10_dmn2(surf_max(la_re):trop_max(la_re)))
      end if
      if (.not.all(ismissing(model10_dmn2(0:surf_max(la_re))))) then           
        mean_re_se_surf2(la_re,se,re) = dim_avg_Wrap(model10_dmn2(0:surf_max(la_re)))
      end if
      if (.not.all(ismissing(mean_re_se_surf2(la_re,se,re)))) .and. (.not.all(ismissing(mean_re_se_surf_air(la_re,se,re)))) then
       reldiff_re_se_surf2(la_re,se,re) = 1+ (mean_re_se_surf2(la_re,se,re)-mean_re_se_surf_air(la_re,se,re))/mean_re_se_surf_air(la_re,se,re)
  ;    corr_re_se_surf2(la_re,se,re) = escorc(air_dmn(0:surf_max(la_re)),model10_dmn2(0:surf_max(la_re)))
      end if
    end if

; read model data


;---------------------------------------------------------------------
   maxlat = nalt10
   if (compcase.ne."NONE") then
          nMax = max((/maxlat,nlev1,nlev2/) )
          Xdata = new((/3,nMax/),"float")
          Ydata = new((/3,nMax/),"float")
          Xp25 = new((/1,nMax/),"float")
          Xp75 = new((/1,nMax/),"float")
   else
          nMax = max((/maxlat,nlev1/)) 
          Xdata = new((/2,nMax/),"float")
          Ydata = new((/2,nMax/),"float")
          Xp25 = new((/1,nMax/),"float")
          Xp75 = new((/1,nMax/),"float")
   end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"
        Xp25!0 = "line"
        Xp75!1 = "lev"

       Xdata@_FillValue = -999.
       Xdata@_FillValue = -999.
       Xdata(:,:) = Xdata@_FillValue
       Ydata(:,:) = Ydata@_FillValue
       

    
      ; end if
;       assign tracer data (X)
        Xdata(0,0:zdim(la_re)-1) = (/air_dmn(0:zdim(la_re)-1)/)
        Xp25(0,0:zdim(la_re)-1) = (/air_p25(0:zdim(la_re)-1)/)
        Xp75(0,0:zdim(la_re)-1) = (/air_p75(0:zdim(la_re)-1)/)

;       model ozone data (X)
        nlmax1 = ind(model_alt1.le.zdim(la_re))
        if (.not.all(ismissing(model_alt1))) then
         Xdata(1,nlmax1) = (/model_dmn1(nlmax1)/)
        end if
        if (compcase.ne."NONE") then
          nlmax2 = ind(model_alt2.le.zdim(la_re))
          if (.not.all(ismissing(model_alt2))) then
          Xdata(2,nlmax2) = (/model_dmn2(nlmax2)/)
          end if
        end if
;       assign altitude level data (Y)
        Ydata(0,0:nalt10-1) = (/alt10/)   ; raobs
        if (.not.all(ismissing(model_alt1))) then
         Ydata(1,nlmax1) = (/model_alt1(nlmax1)/)   ; raobs
        end if
        if (compcase.ne."NONE") then
          if (.not.all(ismissing(model_alt2))) then
           Ydata(2,nlmax2) = (/model_alt2(nlmax2)/)   ; raobs
          end if
           delete(nlmax2)
        end if
       delete(nlmax1)

  ;  inp0 = ind(Ydata(0,:) .le.12)
  ;  inp1 = ind(Ydata(1,:) .le.12)
  ;  inp2 = ind(Ydata(2,:) .le.12)
     if (.not.all(ismissing(Xdata))) then
      if (.not.all(ismissing(Xdata(0,:)))) then
         max1 = max(Xdata(0,:))
         min1 = min(Xdata(0,:))
      else
         max1 = Xdata@_FillValue
         min1 = Xdata@_FillValue
      end if
      if (.not.all(ismissing(Xdata(1,:)))) then
         max2 = max(Xdata(1,:))
         min2 = min(Xdata(1,:))
      else
         max2 = Xdata@_FillValue
         min2 = Xdata@_FillValue
      end if
    if (compcase.ne."NONE") then
      if (.not.all(ismissing(Xdata(2,:)))) then
         max3 = max(Xdata(2,:))
         min3 = min(Xdata(2,:))
      else
         max3 = Xdata@_FillValue
         min3 = Xdata@_FillValue
      end if
    end if
      if (.not.all(ismissing(Xp75(0,:)))) then
         max4 = max(Xp75(0,:))
         min4 = min(Xp25(0,:))
      else
         max4 = Xdata@_FillValue
         min4 = Xdata@_FillValue
      end if
      if (compcase.ne."NONE") then
       xmax = max((/max1,max2,max3,max(Xp75(0,:))/))
       xmin = min((/min1,min2,min3,min(Xp25(0,:))/))
      else
       xmax = max((/max1,max2,max(Xp75(0,:))/))
       xmin = min((/min1,min2,min(Xp25(0,:))/))
      end if
     else
     xmax = Xdata@_FillValue 
     xmin = Xdata@_FillValue 
     end if
     xmax = xmax + 0.05*xmax
     xmin = xmin - 0.05*xmin
     res@trXMaxF =xmax
     res@trXMinF =xmin
  ;  delete (inp0)
  ;  delete (inp1)
  ;  delete (inp2)
;*****************************************************************
     res@tiYAxisString = "Altitude (km)"
      if (re.eq.0 .or. re.eq.m .or. re.eq.2*m .or. re.eq.3*m .or. re.eq.4*m) then
        res@tiYAxisString = "Altitude (km)"
      else
        delete (res@tiYAxisString)
      end if
      res@gsnLeftString = year1(inv_1995_lat_re(re))+", Lat:"+alat1n(inv_1995_lat_re(re))+"-"+alat2n(inv_1995_lat_re(re))+", Lon:"+alon1n(inv_1995_lat_re(re))+"-"+alon2n(inv_1995_lat_re(re))
    ; res@gsnRightString = False 
      

      if (re.eq.m-1) then
        res@pmLegendDisplayMode    = "Always"
          res@pmLegendSide           = "Right"
       ; if re.lt.6 .or. re.gt.9 then
          res@pmLegendParallelPosF   =  .70
          res@pmLegendOrthogonalPosF =  -.90
       ;  res@pmLegendOrthogonalPosF =  -.10
       ; else
       ;  res@pmLegendParallelPosF   =  .10
       ;  res@pmLegendOrthogonalPosF =  -.70
       ; end if
      else
        res@pmLegendDisplayMode    = "Never"
      end if

      res@gsnDraw = False
      res@gsnFrame = False
      plot(re) = gsn_csm_xy(wks,Xdata,Ydata,res)  ; create the plot

      polyres = True
    ; polyres@NhlRemovePrimitive=-1

      do t = 0, nalt10-1
        if (.not.all(ismissing(Xp25(0,t))) .and. .not.all(ismissing(Xp75(0,t)))) then
        error_bar1(re,t) = gsn_add_polyline(wks,plot(re),(/Xp25(0,t),Xp75(0,t)/),(/alt10(t)+0.1,alt10(t)+0.1/),polyres)
        error_bar2(re,t) = gsn_add_polyline(wks,plot(re),(/Xp25(0,t),Xp75(0,t)/),(/alt10(t)-0.1,alt10(t)-0.1/),polyres)
        error_bar3(re,t) = gsn_add_polyline(wks,plot(re),(/Xp25(0,t),Xp25(0,t)/),(/alt10(t)-0.1,alt10(t)+0.1/),polyres)
        error_bar4(re,t) = gsn_add_polyline(wks,plot(re),(/Xp75(0,t),Xp75(0,t)/),(/alt10(t)-0.1,alt10(t)+0.1/),polyres)
        end if
      end do

  ;   ; add mean
      tres   = True
      tres@txFontHeightF = 0.025
      tres@txFont = 0.025
      tres@txFontColor = "black"
      tres@txJust        = "CenterLeft"
      if la_re.ne.1 then
         frac = 0.5
      else
         frac = 1.
      end if
      dum = gsn_add_text(wks,plot(re),region(inv_1995_lat_re(re)),xmin+0.1*xmax,zdim(la_re)-frac,tres)

      delete (res@gsnLeftString)
      delete (res@trXMaxF)
      delete (res@trXMinF)
      delete (xmax)
      delete (xmin)
      delete (Xdata)
      delete (Ydata)
      delete (Xp25)
      delete (Xp75)
;     delete (zdim)
      delete (nMax)
      delete (dum)
  end do ; re
   ;*********************************************
; add lat long info to plot
    txres               = True
    txres@txFontHeightF = 0.017
    title = la_region_n(la_re)+" "+season(se)+" "+variable(v)
    gsn_text_ndc(wks,title,.50,.98,txres)

    panres = True
    panres@gsnFrame = False
    panres@gsnMaximize = True
    panres@gsnPanelTop = 0.96
    if (time_stamp .eq. "True") then
      panres@gsnPanelBottom = 0.05
      gsn_panel (wks,plot,(/n,m/),panres)
      infoTimeStamp(wks,0.011,"DIAG Version: "+version)
    else
      gsn_panel (wks,plot,(/n,m/),panres)
    end if
    frame(wks)
    delete (title)
    delete (res@tiXAxisString)
  
 ; end plot
  delete(plot)
  delete(res)
  delete(tres)
  delete(error_bar1)
  delete(error_bar2)
  delete(error_bar3)
  delete(error_bar4)
  end if ;(nall eq 0)
  delete(inv_1995_lat_re)
 end do; la_re
end do; se 
  
; plot taylor like diagram
; derive mean and correlation for different altitutdes (2-6km/8km/9km) 
;**********************************
; create plot
;**********************************
; loop over 2 for trop and surf
;do s = 0, 1
;if s.eq.0 then 
;  title_s = "Troposphere"
;  ta_name = "cset6_regions_taylor_trop_"
;  mean_re_se1 = mean_re_se_trop1
;  corr_re_se1 = corr_re_se_trop1
;  reldiff_re_se1 = reldiff_re_se_trop1
; if (compcase .ne. "NONE") then       ; more than one model
;  mean_re_se2 = mean_re_se_trop2
;  corr_re_se2 = corr_re_se_trop2
;  reldiff_re_se2 = reldiff_re_se_trop2
; end if
;else
;  title_s = "Boundary Layer"
;  ta_name = "cset6_regions_taylor_surf_"
;  mean_re_se1 = mean_re_se_surf1
;  corr_re_se1 = corr_re_se_surf1
;  reldiff_re_se1 = reldiff_re_se_surf1
; if (compcase .ne. "NONE") then       ; more than one model
;  mean_re_se2 = mean_re_se_surf2
;  corr_re_se2 = corr_re_se_surf2
;  reldiff_re_se2 = reldiff_re_se_surf2
; end if
;end if
;corr_re_se1 = where(corr_re_se1.lt.0,0.05,corr_re_se1)
;reldiff_re_se1 = where(reldiff_re_se1.gt.1.7,1.60,reldiff_re_se1)
; if (compcase .ne. "NONE") then       ; more than one model
;   corr_re_se2 = where(corr_re_se1.lt.0.,0.05,corr_re_se1)
;   reldiff_re_se2 = where(reldiff_re_se2.gt.1.7,1.60,reldiff_re_se2)
; end if

; wks = gsn_open_wks(plot_type,wkdir+ta_name+vars(v))
; plot = new(16,"graphic")

;nVar25 = 25
;do la_re = 0, 3        ;   loop over region
;do se = 0, 3        ;   loop over region
; l = se*4+la_re
; 
;  mmean_trop1 = mean_re_se1(la_re,se,:)
;  corr_trop1 = corr_re_se1(la_re,se,:)
;  reldiff_trop1 = reldiff_re_se1(la_re,se,:)

  ; variables compared
; if (compcase .ne. "NONE") then
;  nCase = 2
; else
;  nCase = 1
; end if
  ; "Case A"
;  CA_ratio = reldiff_trop1
;  CA_cc = corr_trop1 
;;  valid1 = ind(.not.ismissing(reldiff_trop1).ne.False)
;  if( .not.all(ismissing(valid1))) then 
;    nVar = dimsizes(valid1)
;    A_bias = sum(CA_ratio(valid1))/nVar
;   else 
;    A_bias = 0.
;   end if
;   delete(valid1)
;
;if (compcase .ne. "NONE") then       ; more than one model
;   mmean_trop2 = mean_re_se2(la_re,se,:)
;   corr_trop2 = corr_re_se2(la_re,se,:)
;   reldiff_trop2 = reldiff_re_se2(la_re,se,:)
;; "Case B"
;    CB_ratio = reldiff_trop2
;    CB_cc = corr_trop2
;  valid2 = ind(.not.ismissing(reldiff_trop2).ne.False)
;  if( .not.all(ismissing(valid2))) then 
;    nVar = dimsizes(valid2)
;    B_bias = sum(CB_ratio(valid2))/nVar
;   else 
;    B_bias = 0.
;   end if
;   delete(valid2)
;end if
;
;; arrays to be passed to taylor plot
;  ratio      = new ((/nCase, nVar25/),typeof(CA_cc) )
;  cc         = new ((/nCase, nVar25/),typeof(CA_cc) )
;  bias         = new ((/nCase/),typeof(A_bias) )
;
;  ratio(0,:) = CA_ratio
;  cc(0,:)    = CA_cc
;  bias(0)    = A_bias
;
;if (compcase .ne. "NONE") then       ; more than one model
;  ratio(1,:) = CB_ratio
;  cc(1,:)    = CB_cc
;  bias(1)    = B_bias
;end if

  ;**********************************
; create plot
;**********************************
;
;  res   = True                           ; default taylor diagram
;  res@tiMainString  = la_region_n(la_re)+" "+season(se)
;if (compcase .ne. "NONE") then       ; more than one model
;  res@Markers      = (/16, 16/)               ; make all solid fill
;  res@gsMarkerSizeF = (/0.0055,0.0055/)
;  res@Colors       = (/"red", "blue"/)
;  res@caseLabels   = (/case1,case2/)
;else
;  res@Markers      = (/16/)               ; make all solid fill
;  res@gsMarkerSizeF = (/0.0055/)
;  res@Colors       = (/"red"/)
;  res@caseLabels   = (/case1/)
;end if
;; res@varLabels    = var
;  res@taylorFrame  = False
;  res@taylorDraw   = False
;  plot(l)  = taylor_diagram_bias(wks,ratio,cc,bias,res)
; end do 
;end do 
;   title = "Comparison to Aircraft Climatology "+title_s+" "+variable(v)
;   gsn_text_ndc(wks,title,.50,.98,txres)
;
;    panres = True
;    panres@gsnFrame = False
;    panres@gsnMaximize = True
;    panres@gsnPanelTop = 0.96
;    if (time_stamp .eq. "True") then
;      panres@gsnPanelBottom = 0.05
;      gsn_panel (wks,plot,(/4,4/),panres)
;      infoTimeStamp(wks,0.011,"DIAG Version: "+version)
;    else
;      gsn_panel (wks,plot,(/4,4/),panres)
;    end if
;
;    frame(wks)
;    delete (title)
;    delete(res@tiMainString)
;delete(plot)
;delete(res)
;end do  ; s

end do; variable 

; plot all species
; sort species
;vars = (/"BENZENE","C2H2","C2H4","C2H5OH","C2H6","C3H8","CCL4","CFC113","CFC11","CFC12",\
;         "CH2BRCL","CH3BR","CH3CCL3","CH3CHO","CH3CL","CH3CN","CH3I","CH3OH","H2O2","H2O",\
;         "HCFC22","HCN","HNO3","CH3COCH3","ISOP","TOLUENE","CH4","CO",\
;         "N2O","NOX","NOY","O3","OH","PAN","SO2","SO4","T"/)
ylog = (/0,1,1,1,1,1,0,0,0,0, 0,0,0,0,0,0,0,0,0,1, 0,0,1,0,0,0,0,0, 0,0,1,0,0,0,0,0,0/)
ymin_s = (/0.,1.,0.1,0.1,10.,1.,0.,10.,100.,300., 0.,0.,0.,0.,0.,0.,0.,0.,0.,0.1, 80.,0.,1.,0.,0.,0.,0.,0., 0.,0.,10.,0.,0.,0.,0.,0.,0./)
vars_list1 = (/"O3","OH","H2O2","H2O","CH4"/)
vars_list2 = (/"CO","C2H6","C3H8","C2H2","C2H6","CH3OH","C2H5OH"/)
vars_list3 = (/"O3","NOX","NOY","PAN","HNO3"/)
vars_list4 = (/"SO2","SO4","ISOP","TOLUENE","BENZENE"/)
;vars_list4 = (/"N2O","HCFC22","CCL4","CFC113","CFC11","CFC12"/)
;vars_list5 =(/"CH2BRCL","CH3BR","CH3CCL3","CH3CHO","CH3CL","CH3CN","CH3I","CH3OH","HCN"/)
;vars_list6 = (/"BENZENE","CH3COCH3","ISOP","TOLUENE","SO2","SO4"/)

; different altitude levels 
altmin = (/0,2/)
altmax = (/3,7/)

do al = 0, 1
 
; find regions and seasons
se1 = (/2,5,8,11/)
se2 = (/0,3,6,9/)
do vlist = 0, 3 
 if  vlist.eq.0 then 
  vars_list = vars_list1
; list_name = "H2O2_SO2"
  list_name = "O3_HOx"
 end if
 if  vlist.eq.1 then 
  vars_list = vars_list2
  list_name = "CO_HDC"
 end if
 if  vlist.eq.2 then 
  vars_list = vars_list3
  list_name = "NOY"
 end if
 if  vlist.eq.3 then 
  vars_list = vars_list4
  list_name = "VOC_Aerosol"
; list_name = "Long_Lived"
 end if
 if  vlist.eq.4 then 
  vars_list = vars_list5
  list_name = "VSL"
 end if
 if  vlist.eq.5 then 
  vars_list = vars_list6
 end if
; plot all regions, seasons in one line
 nvarl = dimsizes(vars_list)

units_var= (/"ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppt", "ppm", "ppt", "ppt", "ppt", "ppt", "ppt", "ppt", \
         "ppb", "ppb", "ppb", "ppt", "ppt", "ppb", \
         "molec/cc", "ppt", "ppt", "ppt", "K" /)

; setup plot
;********************************************************
; define plot generals
;********************************************************
 res                 = True
;res@trYMaxF = zdim(la_re)
;res@trYMinF = 0.0
 res@vpHeightF = 0.2
 res@vpWidthF = 0.9
 if (compcase.ne."NONE") then       ; compare 2 models to raobs
   res@xyMarkerColors    = (/"black","red","blue"/)
   res@xyLineThicknesses = (/2,2,2/)
   res@xyMarkerThicknesses = (/2,2,2/)
   res@xyMarkLineModes   = (/"Markers","Markers","Markers"/)
   res@xyDashPatterns    = (/0,0,0/)
   res@xyMarkers         = (/4,0,0/)
 else                              ; compare model to raobs
   res@xyMarkerColors    = (/"black","red"/)
   res@xyLineThicknesses = (/2,2/)
   res@xyMarkerThicknesses = (/2,2/)
   res@xyMarkLineModes   = (/"Markers","Markers"/)
   res@xyDashPatterns    = (/0,0/)
   res@xyMarkers         = (/4,0/)
 end if
   res@tiMainFont           = "times-roman"
   res@tiXAxisFont           = "times-roman"
   res@tiYAxisFont           = "times-roman"
   res@tmXTLabelFont        = "times-roman"
   res@tmYLLabelFont        = "times-roman"

 res@pmLegendWidthF = 0.15
 res@pmLegendHeightF = 0.15
 res@lgLabelFontHeightF = .030
 res@lgPerimOn = True
 res@txFontHeightF = 0.024
;*********************************************************************
; define plot
  wks = gsn_open_wks(plot_type,wkdir+"cset6_emmons_"+list_name+"_summary_"+altmin(al)+"_"+altmax(al))
  plot = new(nvarl,"graphic")
  line_seas = new((/nvarl,16/),graphic)


  do v = 0, nvarl-1                 ; loop over variables in that list 
    vl = ind(vars.eq.vars_list(v))
    if v.eq.0 then
     vl1 = vl
    end if
   res@tiYAxisString = units2(vl)
    res@tmXBOn = False 
 ;  if v.eq.5 then
 ;   res@tmXBBorderOn = True 
 ;  else
 ;   res@tmXBBorderOn = False 
 ;  end if
      
    if ylog(vl).eq.0 then
        res@trYAxisType = "LinearAxis"
    else
        res@trYAxisType = "LogAxis"
    end if
   ;res@trXMaxF =xmax(v)
   ;res@trXMinF =xmin(v)
    if (compcase .ne. "NONE") then       ; more than one model
       res@xyExplicitLegendLabels = (/"Data",case1,case2/)
    else
       res@xyExplicitLegendLabels = (/"Data",case1/)
    end if
  if (compcase.ne."NONE") then
          Xdata = new((/3,145/),"float")
          Ydata = new((/3,145/),"float")
   else
          Xdata = new((/2,145/),"float")
          Ydata = new((/2,145/),"float")
   end if
        Xdata!0 = "line"
        Xdata!1 = "lev"
        Ydata!0 = "line"
        Ydata!1 = "lev"
       Xdata@_FillValue = -999.
       Ydata@_FillValue = -999.
       Xdata(:,:) = Xdata@_FillValue
       Ydata(:,:) = Ydata@_FillValue
       

 re_loop = 0
 anz = 0
 re_loop_na = new(16,"integer")
 re_loop_se = new(16,"string")
 re_loop_re = new(16,"string")
 do la_re = 0, 3 
  do se = 0, 3 
   inv_1995_lat_re = ind(avail(vl1,:).eq.1 .and. year1.ge.1995 .and. lat_mean.ge.min_lat(la_re) .and. lat_mean.le.max_lat(la_re) .and. month1.le.se1(se) .and. month2.le.se1(se)+1 .and. month1.ge.se2(se)-1 .and. month2.ge.se2(se))
   if (.not.all(ismissing(inv_1995_lat_re))) then
    re_loop_na(anz) = re_loop 
    re_loop_se(anz) = season(se) 
    re_loop_re(anz) = la_region(la_re) 
    ninv = dimsizes(inv_1995_lat_re)   ; 
    mean_air_2_7 = new(ninv,"float")
    mean_air_2_7@_FillValue = -999.
    mean_mod1_2_7 = new(ninv,"float")
    mean_mod1_2_7@_FillValue = -999.
    if (compcase.ne."NONE") then
     mean_mod2_2_7 = new(ninv,"float")
     mean_mod2_2_7@_FillValue = -999.
    end if
    xl = ispan(re_loop,re_loop+ninv-1,1)
    do re = 0, ninv-1
     almin = altmin(al)
     almax = altmax(al)
     ind_air = ind(.not.ismissing(profiles_dmn(vl,inv_1995_lat_re(re),:)) .and. alt10.ge.almin .and. alt10.le.almax)
     if .not.all(ismissing(ind_air))
      mean_air_2_7(re) = dim_avg_Wrap(profiles_dmn(vl,inv_1995_lat_re(re),ind_air))
      mean_mod1_2_7(re) = dim_avg_Wrap(profiles10_model_dmn1(vl,inv_1995_lat_re(re),ind_air))
      if (compcase.ne."NONE") then
        mean_mod2_2_7(re) = dim_avg_Wrap(profiles10_model_dmn2(vl,inv_1995_lat_re(re),ind_air))
      end if
     else
      mean_air_2_7(re) = mean_air_2_7@_FillValue 
      mean_mod1_2_7(re) = mean_mod1_2_7@_FillValue 
      if (compcase.ne."NONE") then
       mean_mod2_2_7(re) = mean_mod2_2_7@_FillValue 
      end if
     end if
     delete(ind_air) 
    end do
     Ydata(0,re_loop:re_loop+ninv-1) = (/mean_air_2_7/)
     Ydata(1,re_loop:re_loop+ninv-1) = (/mean_mod1_2_7/)
     Xdata(0,re_loop:re_loop+ninv-1) = (/xl/)
     Xdata(1,re_loop:re_loop+ninv-1) = (/xl/)
     delete(mean_air_2_7)
     delete(mean_mod1_2_7)
    if (compcase.ne."NONE") then
     Ydata(2,re_loop:re_loop+ninv-1) = (/mean_mod2_2_7/)
     Xdata(2,re_loop:re_loop+ninv-1) = (/xl/) 
     delete(mean_mod2_2_7)
    end if
     re_loop = re_loop+ninv 
     anz = anz+1
     delete(xl)
   end if    
   if v.eq.0 then
     re_loop1 = re_loop
   end if
   delete(inv_1995_lat_re)
  end do ;se
 end do ;la_re
Xdata1 = Xdata(:,0:re_loop1-1)
Ydata1 = Ydata(:,0:re_loop1-1)
 if (.not.all(ismissing(Ydata))) then
  if (compcase.ne."NONE") then
    ymax = max((/max(Ydata1(0,:)),max(Ydata1(1,:)),max(Ydata(2,:))/))
  else
    ymax = max((/max(Ydata1(0,:)),max(Ydata1(1,:))/))
  end if
;ymin = min((/min(Ydata1(0,:)),min(Ydata1(1,:)),min(Ydata(2,:))/))
 else 
 ymax = 1.
 end if
 ymin = ymin_s(vl) 
 ymax = ymax + 0.05*ymax
 ymin = ymin - 0.05*ymin
     res@trYMaxF =ymax
     res@trYMinF =ymin


if v.eq.0 then
    re_loop_na1 = re_loop_na(0:anz-1)
    re_loop_se1 = re_loop_se(0:anz-1)
    re_loop_re1 = re_loop_re(0:anz-1)

   
    inre = ind(re_loop_se1.eq."DJF" .or. re_loop_na1.eq.0)
    re_loop_re2 = re_loop_re1(inre)
    re_loop_na2 = re_loop_na1(inre)
    delete(inre)
     res@tmXTOn = True
  ;  res@tmXTLabelAngleF = 45.
     res@tmXTMode = "Explicit" 
     res@tmXUseBottom = False 
     res@tmXTLabelsOn= True 
     res@tmXTValues =  re_loop_na2
     res@tmXUseBottom= False 
     res@tmXTLabelJust= "BottomLeft" 
     res@tmXTLabels=  re_loop_re2
     res@tmXTLabelFontHeightF = 0.014
;    res@tmLabelAutoStride = True
     delete(re_loop_re2)
     delete(re_loop_na2)
  else
    res@tmXTLabelsOn= False 
    res@tmXTOn = False 
end if

res@gsnDraw = False
res@gsnFrame = False

    if (v.eq.0) then
      res@pmLegendDisplayMode    = "Always"
        res@pmLegendSide           = "Right"
       ; if re.lt.6 .or. re.gt.9 then
          res@pmLegendParallelPosF   =  .60
          res@pmLegendOrthogonalPosF =  0.0
       ;  res@pmLegendOrthogonalPosF =  -.10
       ; else
       ;  res@pmLegendParallelPosF   =  .10
       ;  res@pmLegendOrthogonalPosF =  -.70
       ; end if
      else
        res@pmLegendDisplayMode    = "Never"
      end if

plot(v) = gsn_csm_xy(wks,Xdata1,Ydata1,res)  ; create the plot

  ;   ; add mean
      tres   = True
      tres@txFontHeightF = 0.015
      tres@txFontColor = "black"
      tres@txFont              = "helvetica"
      tres@txJust        = "CenterLeft"

nre_loop_na1 = dimsizes(re_loop_na1)
dum1 = new(nre_loop_na1,"graphic") 
dum2 = new(nre_loop_na1,"graphic") 
do t = 0, nre_loop_na1-1
    ; if re_loop_se1(t).eq."DJF" then 
    ;    frac = 0.2*ymax
    ; else
         frac = 0.1*ymax
    ; end if

    if re_loop_re1(t) .ne. "SH" then
      if ylog(vl).eq.0 then
      dum1(t) = gsn_add_text(wks,plot(v),re_loop_se1(t),re_loop_na1(t),ymax-frac,tres)
      else
      dum1(t) = gsn_add_text(wks,plot(v),re_loop_se1(t),re_loop_na1(t),2*ymin,tres)
      end if
     end if

      polyres = True
  ;   yt = (/imon/)
  ;   yt!0 = "months"
    ; if re_loop_re1(t).ne."SH" then
        line_seas(v,t) = gsn_add_polyline(wks,plot(v),(/re_loop_na1(t),re_loop_na1(t)/),(/ymin,ymax/),polyres)
    ; end if
end do

  delete(res@trYMaxF)
  delete(res@trYMinF)
end do ;v
    delete(re_loop_na1)
    delete(re_loop_se1)
    delete(re_loop_re1)

title = "Comparison to Aircraft Climatology  "+altmin(al)+"km to "+altmax(al)+"km"
   gsn_text_ndc(wks,title,.50,.98,txres)

    panres = True
    panres@gsnMaximize         = True
    panres@gsnPaperOrientation = "portrait"
    panres@txFont              = "helvetica"
    panres@txFuncCode          = "~"
    panres@tiMainFont          = "helvetica"
    panres@tiMainFuncCode          = "~"
    panres@tiXAxisFont          = "helvetica"
    panres@tiXAxisFuncCode          = "~"
    panres@tiYAxisFont          = "helvetica"
    panres@tiYAxisFuncCode          = "~"
    panres@tmXBLabelFont          = "helvetica"
    panres@tmYLLabelFont          = "helvetica"
    panres@tmXTLabelFont          = "helvetica"
    panres@gsnPanelYWhiteSpacePercent = 0.0

    panres@gsnPanelTop = 0.96
    panres@gsnFrame = False
    if (time_stamp .eq. "True") then
      panres@gsnPanelBottom = 0.05
      gsn_panel (wks,plot,(/nvarl,1/),panres)
      infoTimeStamp(wks,0.011,"DIAG Version: "+version)
    else
      gsn_panel (wks,plot,(/nvarl,1/),panres)
    end if

    frame(wks)
    delete (title)
    delete(plot)
    delete(line_seas)
    delete(dum1)
    delete(dum2)
    delete(vars_list)
    delete(Xdata)
    delete(Ydata)
    delete(Xdata1)
    delete(Ydata1)
delete(res@tmXTValues)
delete(res@tmXTLabels)

end do  ; vlist
end do ; altitude ranges
  




end
