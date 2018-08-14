load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
;**************************************************
; contributed.ncl must be loaded before popRemap.ncl
;**************************************************
begin

; This plots 2 scalar fields and their difference from 2
; cases of CCSM output.  Differences are of the form
; new - prev

wkdir = getenv("WKDIR")
diag_home = getenv("DIAG_HOME")
case_prev = getenv("CASE_PREV")
case_new  = getenv("CASE_NEW")
path_prev = getenv("PATH_PREV")
path_new  = getenv("PATH_NEW")
grid_prev = getenv("GRID_DIFF")
grid_new = getenv("GRID_CONT")
gridfilenew = getenv("GRIDFILECONT")
gridfileprev = getenv("GRIDFILEDIFF")
new_frst_avg_yr = getenv("NEW_YR_AVG_FRST")
new_last_avg_yr = getenv("NEW_YR_AVG_LAST")
prev_frst_avg_yr = getenv("PREV_YR_AVG_FRST")
prev_last_avg_yr = getenv("PREV_YR_AVG_LAST")
var_name_new = getenv("VAR_NAME_NEW")
var_name_prev = getenv("VAR_NAME_PREV")
dir   = getenv("PATH_PLOT")          ; Input data here
hires = getenv("HIRES")

wks_type = getenv("PLOT_FORMAT")
wks_type@wkWidth  = stringtointeger(getenv("PLOT_RES"))
wks_type@wkHeight = stringtointeger(getenv("PLOT_RES"))

season = getenv("SEASON")

; debug print statements
print ("NCL debug: wkdir = " + wkdir)
print ("NCL debug: diag_home = " + diag_home)
print ("NCL debug: case_prev = " + case_prev)
print ("NCL debug: case_new = " + case_new)
print ("NCL debug: path_prev = " + path_prev)
print ("NCL debug: path_new = " + path_new)
print ("NCL debug: grid_prev = " + grid_prev)
print ("NCL debug: grid_new = " + grid_new)
print ("NCL debug: new_frst_avg_yr = " + new_frst_avg_yr)
print ("NCL debug: new_last_avg_yr = " + new_last_avg_yr)
print ("NCL debug: prev_frst_avg_yr = " + prev_frst_avg_yr)
print ("NCL debug: prev_last_avg_yr = " + prev_last_avg_yr)
print ("NCL debug: var_name_new = " + var_name_new)
print ("NCL debug: var_name_prev = " + var_name_prev)
print ("NCL debug: dir = " + dir)


;wkdir = "/ptmp/schramm/web_plots/b20.120-Mb58.bills/"
;diag_home = "/fis/cgd/oce/schramm/ice_diag"
;case_new = "b20.120"
;case_prev  = "Mb58.bills"
;path_prev = "/ptmp/schramm/diags/" + case_prev + "/ice"
;path_new = "/ptmp/schramm/diags/" + case_new + "/ice"
;grid_new = "gx3v4"
;grid_prev = "gx1v3"
;new_frst_avg_yr = "11"
;new_last_avg_yr = "15"
;prev_frst_avg_yr = "11"
;prev_last_avg_yr = "15"

;---------USER DEFINED QUANTITIES------------------
c_hemisphere = (/"NH", "SH"/)
min_lat   = (/40., -90./) 
max_lat   = (/90., -45./)

if (var_name_new.eq."NEW".and.var_name_prev.eq."NEW")then
 var_to_plot = (/"aice","hi","hs","Tsfc",\
                 "frazil","snoice","meltb","meltt", \
                 "meltl","dvidtt","dvidtd","daidtt","daidtd", \
                 "congel", "flat_ai", "fsens_ai", "fsalt_ai", "albsni"/)
else 
if (var_name_new.eq."OLD".and.var_name_prev.eq."OLD")then
 var_to_plot = (/"aice","hi","hs","Tsfc", \
                 "frazil","snoice","meltb","meltt", \
                 "meltl","dvidtt","dvidtd","daidtt","daidtd", \
                 "growb", "Flat_aice", "Fsens_aice", "Fsalt_aice", "albsni"/)
else
 var_to_plot = (/"aice","hi","hs","Tsfc", \
                 "frazil","snoice","meltb","meltt", \
                 "meltl","dvidtt","dvidtd","daidtt","daidtd"/)
end if
end if

nvar = dimsizes(var_to_plot)
;span =      (/1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1/)
;span_diff = (/1,1,1,1,1,1,1,1,2,1,2,1,1,1,1,1,1,1/)

ncntrs = 14
NH_Pcntrs = new((/nvar,ncntrs/), float)
SH_Pcntrs = new((/nvar,ncntrs/), float)

; aice contour levels
NH_Pcntrs(0,:)=(/1,5,10,15,20,30,40,50, 60, 70, 80,90,95, 99/) ; aice
SH_Pcntrs(0,:)=(/1,5,10,15,20,30,40,50, 60, 70, 80,90,95, 99/) ; aice

; hi contour levels
NH_Pcntrs(1,:)=(/0.05,0.1,0.25,0.5,0.75,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0/) ; hi 
SH_Pcntrs(1,:)=(/0.05,0.1,0.25,0.5,0.75,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0/) ; hi

; hs contour levels
NH_Pcntrs(2,:)=(/1,3,5,7,10,13,15,20,25,30,35,40,45,50/) ; hs
SH_Pcntrs(2,:)=(/5,10,15,20,25,30,35,40,50,60,80,100,120,140/) ; hs

; Tsfc contour levels
NH_Pcntrs(3,:)=(/-40,-37,-34,-31,-28,-25,-22,-19,-16,-13,-10,-5,-3,-1/) ; Tsfc
SH_Pcntrs(3,:)=(/-17,-15,-13,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1/) ; Tsfc

; frazil contour levels
NH_Pcntrs(4,:)=(/0.0,0.02,0.04,0.06,0.08,0.10,0.12,0.14,0.16,0.18,0.20,0.22,0.24,0.26/) ;frazil
SH_Pcntrs(4,:)=(/0.0,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.10,0.11,0.12,0.14/) ; frazil

; snoice contour levels
NH_Pcntrs(5,:)=(/0.0,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.10,0.12,0.14,0.16,0.18,0.20/) ;snoice
SH_Pcntrs(5,:)=(/0.0,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.10,0.12,0.14,0.16,0.18,0.20/) ;snoice

NH_Pcntrs(6,:)=(/0.05,0.1,0.25,0.5,0.75,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0/) ; meltb
SH_Pcntrs(6,:)=(/0.05,0.1,0.25,0.5,0.75,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0/) ; meltb

NH_Pcntrs(7,:)=(/0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3/) ;meltt
SH_Pcntrs(7,:)=(/0.01,0.04,0.08,0.12,0.16,0.2,0.24,0.28,0.32,0.36,0.4,0.44,0.48,0.52/) ;meltt

; meltl contour levels
NH_Pcntrs(8,:)=(/0, 0.5, 1 ,1.5 ,2 ,2.5,3,4,5,6,7,8,9,10/) ; meltl
SH_Pcntrs(8,:)=(/0, 0.5, 1 ,1.5 ,2 ,2.5,3,4,5,6,7,8,9,10/) ; meltl

NH_Pcntrs(9,:)=(/-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0.0,0.3,0.6,0.9,1.2,1.5,1.8,2.0/) ;dvidtt
SH_Pcntrs(9,:)=(/-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0.0,0.3,0.6,0.9,1.2,1.5,1.8,2.0/) ;dvidtt
NH_Pcntrs(10,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;dvidtd
SH_Pcntrs(10,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;dvidtd
NH_Pcntrs(11,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;daidtt
SH_Pcntrs(11,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;daidtt
NH_Pcntrs(12,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;daidtd
SH_Pcntrs(12,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;daidtd

if (nvar .gt. 13) then

; growb contour levels
NH_Pcntrs(13,:)=(/0, 0.5, 1 ,1.5 ,2 ,2.5,3,4,5,6,7,8,9,10/) ; growb
SH_Pcntrs(13,:)=(/0, 0.5, 1 ,1.5 ,2 ,2.5,3,4,5,6,7,8,9,10/) ; growb

; Flat_aice contour levels
NH_Pcntrs(14,:)=(/-18,-16,-14,-12,-10,-8,-6,-5,-4,-3,-2,-1,0,2/) ; Flat_aice
SH_Pcntrs(14,:)=(/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18/) ; Flat_aice

; Fsens_aice contour levels
NH_Pcntrs(15,:)=(/-30,-25,-20,-15,-10,-5,-2.5,0,2.5,5,10,15,20,25/) ; Fsens_aice
SH_Pcntrs(15,:)=(/-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/) ; Fsens_aice

; Fsalt_aice contour levels
NH_Pcntrs(16,:)=(/-0.015,-0.012,-0.009,-0.006,-0.003,-0.001,0.0,0.001,0.003, \
                   0.006,0.009,0.012,0.015,0.018/) ; Fsalt_aice
SH_Pcntrs(16,:)=(/-0.015,-0.012,-0.009,-0.006,-0.003,-0.001,0.0,0.001,0.003, \
                   0.006,0.009,0.012,0.015,0.018/) ; Fsalt_aice
; albsni contour levels
NH_Pcntrs(17,:)=(/5,10,15,20,30,40,50, 60, 65, 70, 75, 80,85, 90/) ; albsni
SH_Pcntrs(17,:)=(/5,10,15,20,30,40,50, 60, 65, 70, 75, 80,85, 90/) ; albsni

end if

;-------END USER DEFINED QUANTITIES----------------

inew_frst_yr = stringtointeger(new_frst_avg_yr)
inew_last_yr = stringtointeger(new_last_avg_yr)
iprev_frst_yr = stringtointeger(prev_frst_avg_yr)
iprev_last_yr = stringtointeger(prev_last_avg_yr)

cnew_frst_yr = sprinti("%0.4i",inew_frst_yr)
cnew_last_yr = sprinti("%0.4i",inew_last_yr)
cprev_frst_yr = sprinti("%0.4i",iprev_frst_yr)
cprev_last_yr = sprinti("%0.4i",iprev_last_yr)

main_labels = (/"ANN Mean ", "JFM Mean ", "AMJ Mean", "JAS Mean", "OND Mean"/)

cnew_yr_range = "  Yrs " + cnew_frst_yr + " - " + cnew_last_yr
cprev_yr_range = "  Yrs " + cprev_frst_yr + " - " + cprev_last_yr
center_labels = (/case_new + cnew_yr_range, \
                  case_prev+ cprev_yr_range, \
                  case_new + " - " + case_prev /)

;--------------------------------------------------------------------
; Read in SSMI data
;--------------------------------------------------------------------
file_name = "SSMI.ifrac.1979-2000monthlymean.gx1v5.nc"            ; Contains 12 months of data
b = addfile(dir + "/" + file_name,"r")
SSMI_mean = b->monthly_ifrac      ; Read variable into memory (time,lat,lon)
;------------------------------------------------------------
; newer ifrac data are on a 2d grid - need to change grid info
;----------------------------------------------------------
;nlon_1x1 = 360
;nlat_1x1 = 180 

tlat = b->tlat
tlon = b->tlon
SSMI_mean!0 = "time"
SSMI_mean@lat2d = tlat
SSMI_mean@lon2d = tlon

ifrac_ndims = dimsizes(SSMI_mean)

SSMI_1x1 = new((/5, ifrac_ndims(1),ifrac_ndims(2)/), float)

;--------------------------------------------------------------------
; Calculate seasonal and annual means of SSMI data
;--------------------------------------------------------------------
SSMI_1x1(0,:,:) = SSMI_mean(0,:,:)   ; Copy coordinate variables
SSMI_1x1(0,:,:) = dim_avg(SSMI_mean(nlat | :,nlon | :,time | :))  ; Ann mean
fi_jfm = SSMI_mean(0:2, :,:)       ; Extract JFM of SSMI_mean for averaging
fi_amj = SSMI_mean(3:5, :,:)       ; Extract AMJ of SSMI_mean for averaging
fi_jas = SSMI_mean(6:8, :,:)       ; Extract JAS of SSMI_mean for averaging
fi_ond = SSMI_mean(9:11, :,:)      ; Extract OND of SSMI_mean for averaging
SSMI_1x1(1,:,:) = dim_avg(fi_jfm(nlat | :,nlon | :, time | :))
SSMI_1x1(2,:,:) = dim_avg(fi_amj(nlat | :,nlon | :, time | :))
SSMI_1x1(3,:,:) = dim_avg(fi_jas(nlat | :,nlon | :, time | :))
SSMI_1x1(4,:,:) = dim_avg(fi_ond(nlat | :,nlon | :, time | :))
delete(fi_jas)
delete(fi_jfm)
delete(fi_amj)
delete(fi_ond)
delete(SSMI_mean)

;--------------------------------------------------------------------
; Set seasonal variables
;--------------------------------------------------------------------
if (season.eq."ann")then
   main_label = "ANN Mean "
   jj = 0
end if
if (season.eq."jfm")then
   main_label = "JFM Mean "
   jj = 1
end if
if (season.eq."amj")then
   main_label = "AMJ Mean"
   jj = 2
end if
if (season.eq."jas")then
   main_label = "JAS Mean"
   jj = 3
end if
if (season.eq."ond")then
   main_label =  "OND Mean"
   jj = 4
end if

;----------------------------------------------------------------
; Read in observational data
;---------------------------------------------------------------
file_name = "ASPeCt_monthly_1x1.nc"            ; Contains 12 months of data
obs_data = addfile(dir + "/" + file_name,"r")

Zr_ice_regrid_avg = obs_data->Zr_ice_regrid_avg
Sz_ice_regrid_avg = obs_data->Sz_ice_regrid_avg
Sz_ice_regrid_avg = 100.*Sz_ice_regrid_avg              ; convert from m to cm

;--------------------------------------------------------------------
; Decide which grid to use for plotting
;--------------------------------------------------------------------

if (grid_new.eq.grid_prev) then   ; Grids are identical, use native grid
  plot_grid = "native"
else
  plot_grid = "1x1d"              ; Grids differ, remap to 1x1 grid
end if

f1 = addfile(gridfilenew,"r")
lat2d_new   = dble2flt(f1->TLAT)
lon2d_new   = dble2flt(f1->TLONG)
f2 = addfile(gridfileprev,"r")
lat2d_prev  = dble2flt(f2->TLAT)
lon2d_prev  = dble2flt(f2->TLONG)
delete(f1)
delete(f2)

 do k = 0,nvar-1                      ; Loop through variables to be plotted
  ;--------------------------------------------------------------------
  ; Construct file name
  ;--------------------------------------------------------------------
    new_file_name =season+"_avg_"+cnew_frst_yr +"-"+ cnew_last_yr+".nc"
    prev_file_name=season+"_avg_"+cprev_frst_yr+"-"+cprev_last_yr+".nc"

  ;--------------------------------------------------------------------
  ; Read variables into memory
  ;--------------------------------------------------------------------
    a = addfile(path_prev + "/" + prev_file_name,"r")     ; Read in both cases
    b = addfile(path_new  + "/" + new_file_name ,"r")
    if (isfilevar(a,var_to_plot(k)).and.isfilevar(b,var_to_plot(k))) then
    var_prev    = a->$var_to_plot(k)$(0,:,:)
    var_new     = b->$var_to_plot(k)$(0,:,:)

    if (var_to_plot(k) .eq. "aice") then

      aimax1 = max(var_new)
      aimax2 = max(var_prev)

      if (aimax1 .lt. 2.) then
         aifac1 = 100.
      else
         aifac1 = 1.
      end if
      if (aimax2 .lt. 2.) then
         aifac2 = 100.
      else
         aifac2 = 1.
      end if

      var_new = var_new*aifac1
      var_prev = var_prev*aifac2

    end if

    nrank = dimsizes(dimsizes(lat2d_new))
    if (nrank .eq. 3) then
       var_new@lat2d  = lat2d_new(0,:,:)   ; Assign coordinate attributes
       var_new@lon2d  = lon2d_new(0,:,:)
    else
       var_new@lat2d  = lat2d_new   ; Assign coordinate attributes
       var_new@lon2d  = lon2d_new
    end if

    nrank = dimsizes(dimsizes(lat2d_prev))
    if (nrank .eq. 3) then
       var_prev@lat2d = lat2d_prev(0,:,:)
       var_prev@lon2d = lon2d_prev(0,:,:)
    else
       var_prev@lat2d = lat2d_prev
       var_prev@lon2d = lon2d_prev
    end if

  ;--------------------------------------------------------------------
  ; Remap the data to a 1x1 grid for difference plot if necessary
  ;--------------------------------------------------------------------
    if (plot_grid.eq."1x1d") then

      var_new_1x1  = PopLatLon2(var_new(:,:),grid_new,plot_grid, \
                           "bilin", "da")
      var_prev_1x1 = PopLatLon2(var_prev(:,:),grid_prev,plot_grid, \
                           "bilin", "da")

    ;--------------------------------------------------------------------
    ; Calculate differences on 1x1 grid
    ;--------------------------------------------------------------------
      var_diff = var_new_1x1             ; Copy coordinate variables
      var_diff = var_new_1x1 - var_prev_1x1

    ;--------------------------------------------------------------------
    ; Save ice areas on 1x1 grid for masking difference
    ;--------------------------------------------------------------------
      if (var_to_plot(k).eq."aice") then
        get_dims_1x1 = dimsizes(var_new_1x1) 
        ;if (jj .eq. 0) then
          fice_mask_new_1x1 = new((/get_dims_1x1(0),get_dims_1x1(1),5/), float)
          fice_mask_prev_1x1= new((/get_dims_1x1(0),get_dims_1x1(1),5/), float)
        ;end if
        fice_mask_new_1x1(:,:,jj) = var_new_1x1
        fice_mask_prev_1x1(:,:,jj) = var_prev_1x1
      end if

      delete(var_diff@lat2d)
      delete(var_diff@lon2d)
      delete(var_new_1x1)
      delete(var_prev_1x1)

      var_diff = mask(var_diff, fice_mask_new_1x1(:,:,jj).gt.1.or. \
                                fice_mask_prev_1x1(:,:,jj).gt.1, True)
    else

    ; Convert salt units if necessary
    if (var_to_plot(k).eq."fsalt_ai") then
    if (var_prev@units .eq. "kg/m2/s") then
       print(var_prev@units)
       var_prev = var_prev*86400.
       var_prev@units = "kg/m2/day"
    end if
    if (var_new@units .eq. "kg/m2/s") then
       print(var_new@units)
       var_new = var_new*86400.
       var_new@units = "kg/m2/day"
    end if
    if (var_prev@units .eq. "kg/m^2/s") then
       print(var_prev@units)
       var_prev = var_prev*86400.
       var_prev@units = "kg/m2/day"
    end if
    if (var_new@units .eq. "kg/m^2/s") then
       print(var_new@units)
       var_new = var_new*86400.
       var_new@units = "kg/m2/day"
    end if
    end if

    ;--------------------------------------------------------------------
    ; Plot the difference on the native grid if both cases are on same grid
    ;--------------------------------------------------------------------
      var_diff = var_new                 ; Copy coordinate attributes
      var_diff = var_new - var_prev

      get_dims_new = dimsizes(var_new) 
      get_dims_prev = dimsizes(var_prev) 

    ;--------------------------------------------------------------------
    ; Save seasonal averaged ice area for masking
    ;--------------------------------------------------------------------
      if (var_to_plot(k).eq."aice") then
        ;if (jj .eq. 0) then
          fice_mask_new = new((/get_dims_new(0),get_dims_new(1),5/), float)
          fice_mask_prev = new((/get_dims_prev(0),get_dims_prev(1),5/), float)
        ;end if
        fice_mask_new(:,:,jj) = var_new
        fice_mask_prev(:,:,jj) = var_prev
      end if

    ; Mask variables using seasonally averaged ice area
      var_new = mask(var_new, fice_mask_new(:,:,jj).gt.1, True)
      var_prev = mask(var_prev, fice_mask_prev(:,:,jj).gt.1, True)
      var_diff = mask(var_diff, fice_mask_new(:,:,jj).gt.1.or. \
                                fice_mask_prev(:,:,jj).gt.1, True)

    end if

    get_dims_diff = dimsizes(var_diff) 

    left_label  = var_prev@long_name
    right_label = var_prev@units

    nlat     = get_dims_diff(0)-1            ; for calculating max/min
    ihalf    = get_dims_diff(0)/2            ; for calculating max/min

;--------------------------------------------------------------------
; Convert some variables to more convenient units for contouring
;--------------------------------------------------------------------

    if (var_to_plot(k).eq."hs") then
      var_new = var_new*100.     ; Convert snow depth from m to cm
      var_prev = var_prev*100.    ; Convert snow depth from m to cm
      var_diff = var_diff*100.     ; Convert snow depth from m to cm
      right_label = "cm"
    end if

;--------------------------------------------------------------------
; Loop through the hemispheres to create plots
;--------------------------------------------------------------------

    do ihem = 0,1         ; Loop through hemispheres

      if (ihem.eq.0) then   ; NH
        avg_got_ice = avg(var_diff(ihalf:nlat,:))
        stddev_got_ice = stddev(var_diff(ihalf:nlat,:))
        min_diff = min(var_diff(ihalf:nlat,:))   ; This isn't very accurate on a
        max_diff = max(var_diff(ihalf:nlat,:))   ; rotated grid, but  close enough
      else
        avg_got_ice = avg(var_diff(0:ihalf,:))
        stddev_got_ice = stddev(var_diff(0:ihalf,:))
        min_diff = min(var_diff(0:ihalf,:)) 
        max_diff = max(var_diff(0:ihalf,:))
      end if

      print (season + " " + c_hemisphere(ihem) + " Min diff " + \
                  var_to_plot(k) + "=" +  min_diff)
      print (season + " " + c_hemisphere(ihem) + " Max diff " + \
                var_to_plot(k) + "=" + max_diff)
      print (season + " " + c_hemisphere(ihem) + " Avg    " + \
                  var_to_plot(k) + "=" +  avg_got_ice)
      print (season + " " + c_hemisphere(ihem) + " Stddev " + \
                var_to_plot(k) + "=" + stddev_got_ice)

;      if (min_diff.eq.0 .and. max_diff.eq.0) then
      if (1.eq.0) then
        print ("Skipping plot since fields are identical")
      else

      if (var_name_new.eq."NEW".or.var_name_prev.eq."NEW")then
         wks = gsn_open_wks(wks_type, wkdir + "diff_con_"+season + "_" + \
                           var_to_plot(k) + "_cice_"+c_hemisphere(ihem))
      else
         wks = gsn_open_wks(wks_type, wkdir + "diff_con_"+season + "_" + \
                           var_to_plot(k) + "_csim4_"+c_hemisphere(ihem))
      end if

; 2->102 is first colormap, 102->103 is second colormap
      n_colors_one = 16
      n_colors_two = 101

      cmap = RGBtoCmap(diag_home + "/rgb/julies.rgb")
      gsn_define_colormap(wks,cmap)
      gsn_merge_colormaps(wks,cmap, "BlWhRe") ; merge 2 colormaps

      i = NhlNewColor(wks,0.7,0.7,0.7)              ; add gray to colormap
      plot = new(3,graphic)  

      res                      = True

      res@gsnDraw              = False            ; do not draw picture
      res@gsnFrame             = False            ; do not advance frame
      res@gsnPolar             = c_hemisphere(ihem)
      res@gsnTickMarksOn       = False            ; don't write long. labels

      res@cnFillOn             = True 
      res@cnLinesOn            = False            ; Don't draw lines between color contours
      res@cnLineLabelInterval  = 0                ; More labels on lines
      res@cnLevelSelectionMode = "ExplicitLevels" ; set manual contour levels
      res@cnFillColors = (/2,3,4,5,6,7,8,9,10,11,12,13,14,15,16/)

      if (hires .eq. 1) then
         res@cnFillMode           = "RasterFill" ; Raster Mode
         res@trGridType           = "TriangularMesh"  ; Define the mesh type
      end if

      res@mpFillOn             = True
      res@mpMinLatF            = min_lat(ihem)    ; specify min lat
      res@mpMaxLatF            = max_lat(ihem)    ; specify max lat
      res@mpLandFillColor      = "grey"           ; choose color of continents.
      res@mpFillDrawOrder      = "PostDraw"       ; Fill continents later to cover up lines
      res@mpPerimDrawOrder     = "PostDraw"       ; Perimeter gets covered up by land
      res@lbLabelFontHeightF   = 1.3
;      res@lbLabelStride        = span(k)          ; Label every other box
      res@lbOrientation        = "Vertical"
  
      res@txFontHeightF        = 0.02
; Set contour levels for NH
      if (c_hemisphere(ihem).eq."NH") then
        res@cnLevels             =  NH_Pcntrs(k,:)
        if (var_to_plot(k).eq."Tsfc") then
          if (season.ne."jfm") then
            res@cnLevels         = SH_Pcntrs(k,:)
          end if
        end if
        if (var_to_plot(k).eq."Flat_aice".or.var_to_plot(k).eq."growb".or. \
            var_to_plot(k).eq."frazil".or.var_to_plot(k).eq."meltl") then
          if (season.ne."jfm") then
            res@cnLevels         = SH_Pcntrs(k,:)
          end if
        end if
        if (var_to_plot(k).eq."meltt") then
          if (season.ne."jas") then
            res@cnLevels         = SH_Pcntrs(k,:)
          end if
        end if
      end if
; Set contour levels for SH
      if (c_hemisphere(ihem).eq."SH") then
        res@cnLevels   =  SH_Pcntrs(k,:)
        if (var_to_plot(k).eq."Tsfc") then
          if (season.ne."jfm") then
            res@cnLevels         =  NH_Pcntrs(k,:)
          end if
        end if
        if (var_to_plot(k).eq."Flat_aice".or.var_to_plot(k).eq."growb".or. \
            var_to_plot(k).eq."frazil".or.var_to_plot(k).eq."meltl") then
         if (season.ne."jfm") then
           res@cnLevels          =  NH_Pcntrs(k,:)
         end if
        end if
      end if

      res@gsnLeftString       = left_label
      res@gsnRightString      = right_label
      res@gsnAddCyclic        = True

      res@txFontHeightF        = 0.025

      res@lbLabelBarOn         = False            ; Turns off label bar for first plot
      res@lbLabelStride        = 1                ; Label bar stride
      res@lbLabelFontHeightF   = 0.02             ; Label bar font height

      res@tiMainString         = center_labels(0)
      res@tiMainFontHeightF    = 0.03             ; size of title main string

    if (var_to_plot(k).eq."aice") then
; Set resources for 10% SSMI contour
      res15per = True
      res15per@gsnDraw          = False     ; don't draw
      res15per@gsnFrame         = False     ; don't advance frame
      res15per@cnLevelSelectionMode =  "ExplicitLevels"
      res15per@cnInfoLabelOn    =  False
      res15per@gsnLeftString    =  ""
      res15per@cnLevels         =  (/0.15/)
      res15per@tiXAxisString    = ""
      res15per@tiYAxisString    = ""
      res15per@cnLineThicknessF = 5.0       ; thicker contours
      res15per@cnLineLabelsOn   = False     ; no line labels
    end if

      plot(0) = gsn_csm_contour_map_polar (wks,var_new(:,:), res)
      if (var_to_plot(k).eq."aice") then
         plot_15per = gsn_csm_contour(wks,SSMI_1x1(jj,:,:),res15per)
         overlay(plot(0), plot_15per)
      end if
;---------------------------------------------------
; Define resource for ASPeCt plot
;---------------------------------------------------
      if ((jj.gt.0).and.(c_hemisphere(ihem).eq."SH").and.((var_to_plot(k).eq."hi") .or. (var_to_plot(k).eq."hs"))) then
         resASPeCt = True
         resASPeCt = res
      end if

      res@lbLabelBarOn         = True            ; Turn on label bar for second plot
      res@tiMainString  = center_labels(1)
      plot(1) = gsn_csm_contour_map_polar (wks,var_prev(:,:), res)
      if (var_to_plot(k).eq."aice") then
         plot_15per = gsn_csm_contour(wks,SSMI_1x1(jj,:,:),res15per)
        overlay(plot(1), plot_15per)
      end if
;---------------------------------------------------
; Define new scale and colormap for difference plots
;---------------------------------------------------

      delete(res@cnLevels)
      delete(res@cnLevelSelectionMode)

;     minXY   = avg_got_ice - 2*stddev_got_ice
;     maxXY   = avg_got_ice + 2*stddev_got_ice
      minXY   = - 2*stddev_got_ice
      maxXY   = 2*stddev_got_ice
      mnmxint = nice_mnmxintvl( minXY, maxXY, ncntrs, False)
      print("Contouring from "+mnmxint(0)+" to "+ mnmxint(1)+" by "+mnmxint(2))

      res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
      res@cnMinLevelValF       = mnmxint(0)
      res@cnMaxLevelValF       = mnmxint(1) 
      res@cnLevelSpacingF      = mnmxint(2) 
      color_start              = n_colors_one + 1
      color_end                = n_colors_one+n_colors_two-1
      delete(res@cnFillColors)
      res@gsnSpreadColors     = True              ; use full colormap
      res@gsnSpreadColorStart  = color_start
      res@gsnSpreadColorEnd    = color_end-1
;      res@lbLabelStride        = span_diff(k)       ; Label every other box

      mid_pt                   = floattointeger((color_start+color_end)/2)
; This puts the white color near the 0 contour
      min_con                  = mnmxint(0)
      max_con                  = mnmxint(1)
;     if (max_con+min_con.ge.0) then
;       new_color_start        = (min_con*(color_end-mid_pt) +  \
;                                 max_con*mid_pt)/max_con
;       res@gsnSpreadColorStart= floattointeger(new_color_start)
;     else
;       new_color_end          = (max_con*(color_start-mid_pt) +  \
;                                 min_con*mid_pt)/min_con
;       res@gsnSpreadColorEnd  = floattointeger(new_color_end)
;     end if
   
      res@tiMainString         = center_labels(2)
      res@lbTitleFontHeightF = 0.02
      res@lbTitleString = "MIN = "+sprintf("%6.2f",min_diff)+ \
                         " MAX = "+sprintf("%6.2f",max_diff)

      plot(2) = gsn_csm_contour_map_polar (wks,var_diff(:,:), res)

; Set panel parameters; draw panel without white space

      resP = True
      resP@gsnPaperOrientation = "portrait"  
      resP@gsnMaximize         = True              ; maximize plot area
      resP@txFontHeightF       = 0.02              ; Font height of top label
      resP@txFontColor         = "black"           ; Font color of top label
      resP@txString            = main_label

      resP@gsnPanelYWhiteSpacePercent = 5
      gsn_panel(wks,plot,(/2,2/),resP)

      delete(res@lbTitleString)

      if ((jj.gt.0).and.(c_hemisphere(ihem).eq."SH").and.((var_to_plot(k).eq."hi") .or. (var_to_plot(k).eq."hs"))) then
         wks = gsn_open_wks(wks_type, wkdir + var_to_plot(k)+"_ASPeCt_"+season)
         n_colors_one = 16
         n_colors_two = 101

         cmap = RGBtoCmap(diag_home + "/rgb/julies.rgb")
         gsn_define_colormap(wks,cmap)
         gsn_merge_colormaps(wks,cmap, "BlWhRe") ; merge 2 colormaps

         i = NhlNewColor(wks,0.7,0.7,0.7)              ; add gray to colormap
         plot(0) = gsn_csm_contour_map_polar (wks,var_new(:,:), resASPeCt)
         resASPeCt@lbLabelBarOn         = True            ; Turn on label bar for second plot
         resASPeCt@tiMainString  = center_labels(1)
         plot(1) = gsn_csm_contour_map_polar (wks,var_prev(:,:), resASPeCt)
         m1 = (jj-1)*3
         m2 = m1+2
         resASPeCt@tiMainString ="ASPeCt"

         resASPeCt@cnFillMode = "RasterFill"
         if (var_to_plot(k).eq."hi") then
            resASPeCt@gsnLeftString = "1x1 gridded mean sea ice thickness"
            plot(2)=gsn_csm_contour_map_polar(wks,dim_avg_Wrap(Zr_ice_regrid_avg(lat|:,lon|:,time|m1:m2)),resASPeCt)
         else
            resASPeCt@gsnLeftString = "1x1 gridded mean snow depth"
            plot(2)=gsn_csm_contour_map_polar(wks,dim_avg_Wrap(Sz_ice_regrid_avg(lat|:,lon|:,time|m1:m2)),resASPeCt)
         end if
         gsn_panel(wks,plot,(/2,2/),resP)

         delete(resASPeCt)
      end if

    end if  ; skip plot if fields are identical

  end do    ; Loop through hemispheres

  delete(var_new)
  delete(var_prev)
  delete(var_diff)

  end if

end do   ; End loop through variables

end
