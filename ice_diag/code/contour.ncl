load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
; Data is not averaged in this script.  Seasonally and
; annually averaged data is read in from netcdf files.

wkdir = getenv("WKDIR")              ; Plots output here
diag_home = getenv("DIAG_HOME")              
p_case = getenv("CASE_TO_CONT")
dir   = getenv("PATH_PLOT")          ; Input data here
frst_avg_yr = getenv("YR_AVG_FRST")
last_avg_yr = getenv("YR_AVG_LAST")
var_name = getenv("VAR_NAMES")
hires = getenv("HIRES")
gridfilename = getenv("GRIDFILECONT")
season = getenv("SEASON")

wks_type = getenv("PLOT_FORMAT")
wks_type@wkWidth  = stringtointeger(getenv("PLOT_RES"))
wks_type@wkHeight = stringtointeger(getenv("PLOT_RES"))

;---------USER DEFINED QUANTITIES------------------
NH_min_lat   = 40               
NH_max_lat   = 90
SH_min_lat   = -90
SH_max_lat   = -45
if (var_name.eq."CICE")then
  ; aice must be read in first for masking
  var_to_plot = (/"aice","hi","hs","Tsfc","flat_ai","fsens_ai", \
                "congel","frazil","snoice","meltb","meltt", \
                "meltl","dvidtt","dvidtd","daidtt","daidtd","fsalt_ai","albsni"/)
else
if (var_name.eq."SIMIP")then
  ; aice must be read in first for masking
  var_to_plot = (/"aice","hi","hs","sitemptop","sifllatstop","siflsenstop", \
                "congel","frazil","sidmasssi","meltb","meltt", \
                "meltl","dvidtt","dvidtd","daidtt","daidtd","siflsaltbot","albsni"/)
else
  var_to_plot = (/"aice","hi","hs","Tsfc","Flat_aice","Fsens_aice", \
                  "growb","frazil","snoice","meltb","meltt", \
                  "meltl","dvidtt","dvidtd","daidtt","daidtd","Fsalt_aice","albsni"/)
end if
end if
nvar = dimsizes(var_to_plot)
NH_Pcntrs = new((/nvar,14/), float)
SH_Pcntrs = new((/nvar,14/), float)

; aice contour levels
NH_Pcntrs(0,:)=(/5,10,15,20,30,40,50, 60, 70, 80,85,90,95, 99/) ; aice
SH_Pcntrs(0,:)=(/5,10,15,20,30,40,50, 60, 70, 80,85,90,95, 99/) ; aice

; hi contour levels
NH_Pcntrs(1,:)=(/0.05,0.1,0.25,0.5,0.75,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0/) ; hi
SH_Pcntrs(1,:)=(/0.05,0.1,0.25,0.5,0.75,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0/) ; hi

; hs contour levels
NH_Pcntrs(2,:)=(/1,3,5,7,10,13,15,20,25,30,35,40,45,50/) ; hs
SH_Pcntrs(2,:)=(/5,10,15,20,25,30,35,40,50,60,80,100,120,140/) ; hs

; Tsfc contour levels
NH_Pcntrs(3,:)=(/-40,-37,-34,-31,-28,-25,-22,-19,-16,-13,-10,-5,-3,-1/) ; Tsfc
SH_Pcntrs(3,:)=(/-17,-15,-13,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1/) ; Tsfc

; Flat_aice contour levels
NH_Pcntrs(4,:)=(/-18,-16,-14,-12,-10,-8,-6,-5,-4,-3,-2,-1,0,2/) ; Flat_aice
SH_Pcntrs(4,:)=(/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18/) ; Flat_aice

; Fsens_aice contour levels
NH_Pcntrs(5,:)=(/-30,-25,-20,-15,-10,-5,-2.5,0,2.5,5,10,15,20,25/) ; Fsens_aice
SH_Pcntrs(5,:)=(/-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/) ; Fsens_aice

; growb contour levels
NH_Pcntrs(6,:)=(/0, 0.5, 1 ,1.5 ,2 ,2.5,3,4,5,6,7,8,9,10/) ; growb
SH_Pcntrs(6,:)=(/0, 0.5, 1 ,1.5 ,2 ,2.5,3,4,5,6,7,8,9,10/) ; growb

; frazil contour levels
NH_Pcntrs(7,:)=(/0.0,0.02,0.04,0.06,0.08,0.10,0.12,0.14,0.16,0.18,0.20,0.22,0.24,0.26/) ;frazil
SH_Pcntrs(7,:)=(/0.0,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.10,0.11,0.12,0.14/) ; frazil

; snoice contour levels
NH_Pcntrs(8,:)=(/0.0,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.10,0.12,0.14,0.16,0.18,0.20/) ;snoice
SH_Pcntrs(8,:)=(/0.0,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.10,0.12,0.14,0.16,0.18,0.20/) ;snoice

NH_Pcntrs(9,:)=(/0.05,0.1,0.25,0.5,0.75,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0/) ; meltb
SH_Pcntrs(9,:)=(/0.05,0.1,0.25,0.5,0.75,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0/) ; meltb

NH_Pcntrs(10,:)=(/0.05,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3/) ;meltt
SH_Pcntrs(10,:)=(/0.01,0.04,0.08,0.12,0.16,0.2,0.24,0.28,0.32,0.36,0.4,0.44,0.48,0.52/) ;meltt

; meltl contour levels
;;NH_Pcntrs(11,:)=(/0, 0.5, 1 ,1.5 ,2 ,2.5,3,4,5,6,7,8,9,10/) ; meltl
;;SH_Pcntrs(11,:)=(/0, 0.5, 1 ,1.5 ,2 ,2.5,3,4,5,6,7,8,9,10/) ; meltl

NH_Pcntrs(11,:)=(/0.01,0.04,0.08,0.12,0.16,0.2,0.24,0.28,0.32,0.36,0.4,0.44,0.48,0.52/) ;meltl
SH_Pcntrs(11,:)=(/0.01,0.04,0.08,0.12,0.16,0.2,0.24,0.28,0.32,0.36,0.4,0.44,0.48,0.52/) ;meltl


NH_Pcntrs(12,:)=(/-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0.0,0.3,0.6,0.9,1.2,1.5,1.8,2.0/) ;dvidtt
SH_Pcntrs(12,:)=(/-1.8,-1.5,-1.2,-0.9,-0.6,-0.3,0.0,0.3,0.6,0.9,1.2,1.5,1.8,2.0/) ;dvidtt
NH_Pcntrs(13,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;dvidtd
SH_Pcntrs(13,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;dvidtd
NH_Pcntrs(14,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;daidtt
SH_Pcntrs(14,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;daidtt
NH_Pcntrs(15,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;daidtd
SH_Pcntrs(15,:)=(/-3.6,-3.0,-2.4,-1.8,-1.2,-0.6,0.0,0.6,1.2,1.8,2.4,3.0,3.6,4.0/) ;daidtd

; Fsalt_aice contour levels
NH_Pcntrs(16,:)=(/-0.015,-0.012,-0.009,-0.006,-0.003,-0.001,0.0,0.001,0.003, \
                   0.006,0.009,0.012,0.015,0.018/) ; Fsalt
SH_Pcntrs(16,:)=(/-0.015,-0.012,-0.009,-0.006,-0.003,-0.001,0.0,0.001,0.003, \
                   0.006,0.009,0.012,0.015,0.018/) ; Fsalt
; albsni contour levels
NH_Pcntrs(17,:)=(/5,10,15,20,30,40,50, 60, 65, 70, 75, 80,85, 90/) ; albsni
SH_Pcntrs(17,:)=(/5,10,15,20,30,40,50, 60, 65, 70, 75, 80,85, 90/) ; albsni

;-------END USER DEFINED QUANTITIES----------------

nvar = dimsizes(var_to_plot)
ifrst_avg_yr = stringtointeger(frst_avg_yr) 
ilast_avg_yr = stringtointeger(last_avg_yr)
cyear_frst = sprinti("%0.4i", ifrst_avg_yr)   ; Convert integer year to string
cyear_last = sprinti("%0.4i", ilast_avg_yr)   ; Convert integer year to string

left_label = new((/nvar/), string)
right_label = new((/nvar/), string)

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
; Caclulate seasonal and annual means of SSMI data
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
   j = 0
end if
if (season.eq."jfm")then
   main_label = "JFM Mean "
   j = 1
end if
if (season.eq."amj")then
   main_label = "AMJ Mean"
   j = 2
end if
if (season.eq."jas")then
   main_label = "JAS Mean"
   j = 3
end if
if (season.eq."ond")then
   main_label =  "OND Mean"
   j = 4
end if

;----------------------------------------------------------------
; Read in ASPeCt data
;---------------------------------------------------------------
file_name = "ASPeCt_monthly_1x1.nc"            ; Contains 12 months of data
obs_data = addfile(dir + "/" + file_name,"r")

Zr_ice_regrid_avg = obs_data->Zr_ice_regrid_avg
Sz_ice_regrid_avg = obs_data->Sz_ice_regrid_avg
Sz_ice_regrid_avg = 100.*Sz_ice_regrid_avg              ; convert from m to cm

;--------------------------------------------------------------------
; create plots
;--------------------------------------------------------------------

b = addfile(gridfilename,"r")
lat2d = dble2flt(b->TLAT)
lon2d = dble2flt(b->TLONG)
delete(b)

do k = 0,nvar-1                ; Loop through variables to be plotted

    file_name = season + "_avg_" + cyear_frst + "-" + cyear_last + ".nc"
    b = addfile(dir + "/" + file_name,"r")
    
    if (isfilevar(b,var_to_plot(k))) then

    var_mean = b->$var_to_plot(k)$(0,:,:)      ; Read variable into memory
    delete(var_mean@coordinates)
    delete(var_mean@cell_measures)

    get_dims = dimsizes(var_mean)       ; Get approximate index for equator

; Save seasonal averaged ice area for masking
    if (var_to_plot(k).eq."aice") then
      aimax = max(var_mean)

      if (aimax .lt. 2.) then
         aifac = 100.
      else
         aifac = 1.
      end if

      var_mean = var_mean*aifac

      ;if (j .eq. 0) then
      fice_for_mask = new((/get_dims(0),get_dims(1),5/), float)
      ;end if
      fice_for_mask(:,:,j) = var_mean
    end if

    ; Convert salt units if necessary
    if (var_to_plot(k).eq."fsalt_ai".or.var_to_plot(k).eq."siflsaltbot") then
    if (var_mean@units .eq. "kg/m2/s".or.var_mean@units .eq. "kg/m^2/s".or. \
        var_mean@units .eq. "kg m-2 s-1") then
       print(var_mean@units)
       var_mean = var_mean*86400.
       var_mean@units = "kg/m2/day"
    end if
    end if

    if (var_to_plot(k).eq."sidmasssi") then
    if (var_mean@units .eq. "kg m-2 s-1") then
;   Convert to cm/day
       print(var_mean@units)
       var_mean = var_mean*86400.*100./917.
       var_mean@units = "cm/day"
    end if
    end if

    nrank = dimsizes(dimsizes(lat2d))
    if (nrank .eq. 3) then
       var_mean@lat2d = lat2d(0,:,:)
       var_mean@lon2d = lon2d(0,:,:)
    else
       var_mean@lat2d = lat2d
       var_mean@lon2d = lon2d
    end if

; Mask variables using seasonally averaged ice area
    var_mean = mask(var_mean, fice_for_mask(:,:,j).gt.1, True)

    left_label(k) = var_mean@long_name
    right_label(k) = var_mean@units
 
    if (var_to_plot(k).eq."hs") then
       var_mean = var_mean*100.     ; Convert snow depth from m to cm
       right_label = "cm"
     end if
 
    nlat     = get_dims(0)-1            ; for calculating max/min for hem
    ihalf    = get_dims(0)/2            ; for calculating max/min for hem

    NH_min = min(var_mean(ihalf:nlat,:))   ; This isn't very accurate on a
    NH_max = max(var_mean(ihalf:nlat,:))   ; rotated grid, but  close enough
    SH_min = min(var_mean(0:ihalf,:))
    SH_max = max(var_mean(0:ihalf,:))

    print (season + " NH Min " + var_to_plot(k) + "=" +  NH_min)
    print (season + " NH Max " + var_to_plot(k) + "=" +  NH_max)
    print (season + " SH Min " + var_to_plot(k) + "=" +  SH_min)
    print (season + " SH Max " + var_to_plot(k) + "=" +  SH_max)

    if (var_name.eq."CICE".or.var_name.eq."SIMIP")then
       wks = gsn_open_wks(wks_type, wkdir + "con_"+season \
                  + "_" + var_to_plot(k) + "_cice")      ; open ps file
    else
       wks = gsn_open_wks(wks_type, wkdir + "con_"+season \
                  + "_" + var_to_plot(k) + "_csim")      ; open ps file
    end if

    print (" Plotting " + var_to_plot(k) + " " + season)

; 2->102 is first colormap, 102->103 is second colormap
    n_colors_one = 102
    n_colors_two = 102

    cmap = RGBtoCmap(diag_home + "/rgb/julies.rgb")
    gsn_define_colormap(wks,cmap)

    i = NhlNewColor(wks,0.7,0.7,0.7)                   ; add gray to colormap
    plot = new(2,graphic)

    res                      = True

    res@gsnDraw              = False        ; do not draw picture
    res@gsnFrame             = False        ; do not advance frame
    res@gsnPolar             = "NH"
    res@gsnTickMarksOn       = False        ; Turn off longitude labels
    res@cnFillOn             = True 
    res@cnLinesOn            = False        ; Don't draw lines between
                                            ; color contours
    res@cnLineLabelInterval  = 0            ; More labels on lines
    res@cnLevelSelectionMode = "ExplicitLevels"     ; set manual contour levels
    res@cnFillColors = (/2,3,4,5,6,7,8,9,10,11,12,13,14,15,16/)

    if (hires .eq. 1) then
       res@cnFillMode           = "RasterFill" ; Raster Mode
       res@trGridType           = "TriangularMesh"  ; Define the mesh type
    end if

    res@mpMinLatF            = NH_min_lat   ; specify min lat
    res@mpMaxLatF            = NH_max_lat   ; specify max lat
    res@mpLandFillColor  = "grey"           ; choose color of continents.
    res@mpFillDrawOrder  = "PostDraw"       ; Fill continents later to cover up lines
    res@mpPerimDrawOrder  = "PostDraw"      ; Perimeter gets covered up by land
    res@lbLabelFontHeightF   = 0.018
    res@lbLabelBarOn        = True          ; Turns on the individual label bars
    res@lbOrientation        = "Vertical"

    res@txFontHeightF  = 0.02
    res@cnLevels      =  NH_Pcntrs(k,:)
    if (var_to_plot(k).eq."Tsfc" .or. var_to_plot(k).eq."sitemptop") then
       if (var_mean@units .eq. "K") then
          print(var_mean@units)
          var_mean = var_mean - 273.15
          var_mean@units = "degC"
       end if
      if (season.eq."ann".or.season.eq."jas") then 
        res@cnLevels      =  SH_Pcntrs(k,:)
      end if
    end if
    if (var_to_plot(k).eq."Flat_aice".or.var_to_plot(k).eq."flat_ai".or. \
        var_to_plot(k).eq."sifllatstop".or.var_to_plot(k).eq."growb".or. \
        var_to_plot(k).eq."frazil".or.var_to_plot(k).eq."meltl") then
      if (season.eq."jas") then
        res@cnLevels      =  SH_Pcntrs(k,:)
      end if
    end if
    if (var_to_plot(k).eq."meltt") then
      if (season.ne."jas") then res@cnLevels      =  SH_Pcntrs(k,:)
      end if
    end if
  
    res@gsnLeftString       = left_label(k)
    res@gsnRightString      = right_label(k)
    res@gsnAddCyclic        = True

    if (var_to_plot(k).eq."aice") then
; Set resources for 15% SSMI contour
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

    plot(0) = gsn_csm_contour_map_polar(wks,var_mean(:,:), res)
    if (var_to_plot(k).eq."aice") then
      plot_15per = gsn_csm_contour(wks,SSMI_1x1(j,:,:),res15per)
      overlay(plot(0), plot_15per)
    end if

   res@gsnPolar   = "SH"
   res@mpMinLatF  = SH_min_lat                ; minimum lat to plot
   res@mpMaxLatF  = SH_max_lat                ; maximum lat to plot
   res@cnLevels   =  SH_Pcntrs(k,:)
   if (var_to_plot(k).eq."Tsfc".or.var_to_plot(k).eq."sitemptop") then
       if (var_mean@units .eq. "K") then
          print(var_mean@units)
          var_mean = var_mean - 273.15
          var_mean@units = "degC"
       end if
     if (season.eq."jas") then
       res@cnLevels      =  NH_Pcntrs(k,:)
     end if
   end if
    if (var_to_plot(k).eq."Flat_aice".or.var_to_plot(k).eq."flat_ai".or. \
        var_to_plot(k).eq."sifllatstop".or.var_to_plot(k).eq."growb".or. \
        var_to_plot(k).eq."frazil".or.var_to_plot(k).eq."meltl") then
     if (season.ne."jfm") then
       res@cnLevels      =  NH_Pcntrs(k,:)
     end if
   end if

   plot(1) = gsn_csm_contour_map_polar(wks,var_mean(:,:), res) 
   if (var_to_plot(k).eq."aice") then
      plot_15per = gsn_csm_contour(wks,SSMI_1x1(j,:,:),res15per)
      overlay(plot(1), plot_15per)
   end if

; draw panel without white space
   resP = True
   resP@gsnPaperOrientation = "portrait"
   resP@gsnMaximize      = True             ; maximize plot area
   resP@gsnPanelYWhiteSpacePercent = 5
   resP@txFontHeightF    = 0.02             ; Font height of top label
   resP@txFontColor      = "black"                ; Font color of top label
   resP@txFuncCode = "~"
   resP@txString   = "     Case "+p_case+"~C~   "+main_label \
                   + "   Years "+cyear_frst+"-"+cyear_last+"~C~ "
   print("BEFORE")
   gsn_panel(wks,plot,(/2,1/),resP)
   print("AFTER")
    if ((season.ne."ann") .and. ((var_to_plot(k).eq."hi") .or. (var_to_plot(k).eq."hs"))) then
       wks = gsn_open_wks(wks_type, wkdir + var_to_plot(k)+"_ASPeCt_"+season)
       n_colors_one = 102
       n_colors_two = 102

       cmap = RGBtoCmap(diag_home + "/rgb/julies.rgb")
       gsn_define_colormap(wks,cmap)

       i = NhlNewColor(wks,0.7,0.7,0.7)                   ; add gray to colormap

       plot(0) = gsn_csm_contour_map_polar(wks,var_mean(:,:), res)

       m1 = (j-1)*3
       m2 = m1+2
       res@cnFillMode = "RasterFill"
       if (var_to_plot(k).eq."hi") then
          res@gsnLeftString = "ASPeCt 1x1 grid mean sea ice thickness"
          plot(1)=gsn_csm_contour_map_polar(wks,dim_avg_Wrap(Zr_ice_regrid_avg(lat|:,lon|:,time|m1:m2)),res)
       else
          res@gsnLeftString = "ASPeCt 1x1 grid mean snow depth"
          plot(1)=gsn_csm_contour_map_polar(wks,dim_avg_Wrap(Sz_ice_regrid_avg(lat|:,lon|:,time|m1:m2)),res)
       end if

       gsn_panel(wks,plot,(/2,1/),resP)
       delete(res@cnFillMode)
    end if
  
    delete(var_mean)

  end if   ; If var_to_plot exists
end do   ; End loop through variables

end
