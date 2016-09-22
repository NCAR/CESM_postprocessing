
;******************************************************************************
; Plot MY ice area for individual ensemble members, for 2001-2005
; Written by Alexandra Jahn
; Modified by D. Bailey for ice diagnostics
;******************************************************************************;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; Data is not averaged in this script.  Seasonally and
; annually averaged data is read in from netcdf files.

wkdir = getenv("WKDIR")
diag_home = getenv("DIAG_HOME")
diag_obs = getenv("DIAGOBSROOT")
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

wks_type = getenv("PLOT_FORMAT")
wks_type@wkWidth  = stringtointeger(getenv("PLOT_RES"))
wks_type@wkHeight = stringtointeger(getenv("PLOT_RES"))

;***************************************************
; read in data
;***************************************************
; ICE SAT
;***************************************************
  ncols = 8    
  nrows = 11118  ; 
  ksoi  = asciiread(diag_obs+"/icesat_10prods/icesat_icethk_spring_regular_grid.dat",(/nrows,ncols/),"float")
  lat_fm   = ksoi(:,0)
  lon_fm   = ksoi(:,1)
  thick_fm = ksoi(:,7)
  thick_fm = thick_fm/100

  thick_fm@long_name = "ice thickness from icesat fir fm04"
  thick_fm@name      = "ice thickness"
  thick_fm@units     = "m"

  ksoi  = asciiread(diag_obs+"/icesat_10prods/icesat_icethk_fall_regular_grid.dat",(/nrows,ncols/),"float")
  lat_on   = ksoi(:,0)
  lon_on   = ksoi(:,1)
  thick_on = ksoi(:,7) ; column 8 is the mean
  thick_on = thick_on/100

  thick_on@long_name = "ice thickness from icesat fir on04"
  thick_on@name      = "ice thickness"
  thick_on@units     = "m"
 
; *********** Model ****************************************


   inew_frst_yr = stringtointeger(new_frst_avg_yr)
   inew_last_yr = stringtointeger(new_last_avg_yr)
   iprev_frst_yr = stringtointeger(prev_frst_avg_yr)
   iprev_last_yr = stringtointeger(prev_last_avg_yr)

   cnew_frst_yr = sprinti("%0.4i",inew_frst_yr)
   cnew_last_yr = sprinti("%0.4i",inew_last_yr)
   cprev_frst_yr = sprinti("%0.4i",iprev_frst_yr)
   cprev_last_yr = sprinti("%0.4i",iprev_last_yr)

   b = addfile(gridfilenew,"r")
   llat1 = dble2flt(b->TLAT)
   llon1 = dble2flt(b->TLONG)
   delete(b)
   b = addfile(gridfileprev,"r")
   llat2 = dble2flt(b->TLAT)
   llon2 = dble2flt(b->TLONG)
   delete(b)

   filename = "fm_avg_" + cnew_frst_yr + "-" + cnew_last_yr + ".nc"
   in1 = addfile(path_new + "/" + filename,"r")
   hi_fm_new = in1->hi(0,:,:)

   filename = "fm_avg_" + cprev_frst_yr + "-" + cprev_last_yr + ".nc"
   in2 = addfile(path_prev + "/" + filename,"r")
   hi_fm_prev = in2->hi(0,:,:)

   filename = "on_avg_" + cnew_frst_yr + "-" + cnew_last_yr + ".nc"
   in3 = addfile(path_new + "/" + filename,"r")
   hi_on_new   = in3->hi(0,:,:)

   filename = "on_avg_" + cprev_frst_yr + "-" + cprev_last_yr + ".nc"
   in4 = addfile(path_prev + "/" + filename,"r")
   hi_on_prev   = in4->hi(0,:,:)

    nrank = dimsizes(dimsizes(llat1))
    if (nrank .eq. 3) then
       hi_fm_new@lat2d = llat1(0,:,:)
       hi_fm_new@lon2d = llon1(0,:,:)
       hi_fm_prev@lat2d = llat2(0,:,:)
       hi_fm_prev@lon2d = llon2(0,:,:)
       hi_on_new@lat2d = llat1(0,:,:)
       hi_on_new@lon2d = llon1(0,:,:)
       hi_on_prev@lat2d = llat2(0,:,:)
       hi_on_prev@lon2d = llon2(0,:,:)
    else
       hi_fm_new@lat2d = llat1
       hi_fm_new@lon2d = llon1
       hi_fm_prev@lat2d = llat2
       hi_fm_prev@lon2d = llon2
       hi_on_new@lat2d = llat1
       hi_on_new@lon2d = llon1
       hi_on_prev@lat2d = llat2
       hi_on_prev@lon2d = llon2
    end if


;************************************************
; create plots
;************************************************

  wks1 = gsn_open_wks(wks_type,wkdir+"diff_hi_icesat_fm")            ; open first ps file  
  gsn_define_colormap(wks1,"wh-bl-gr-ye-re") 
  i = NhlNewColor(wks1,0.7,0.7,0.7)              ; add gray to colormap
 
  wks2 = gsn_open_wks(wks_type,wkdir+"diff_hi_icesat_on")            ; open secon ps file  
  gsn_define_colormap(wks2,"wh-bl-gr-ye-re") 
  i = NhlNewColor(wks2,0.7,0.7,0.7)              ; add gray to colormap
 
  ;***************************************************************************
; setup of filled MYarea contour plot                   
;***************************************************************************
 
   res                       = True
   res@gsnPolar              = "NH"               ; choose hemisphere
   res@gsnPaperOrientation   = "landscape"        ; force landscape plot
;  res@gsnMaximize           = True               ;maximize plot size on page
   res@gsnPolarLabelFontHeightF = 0.03          ; changes size of lat/lon labels
   res@gsnPolarLabelDistance    = 1.08            ; determines how fat lat/lon labels are from plot
   res@gsnAddCyclic = True 
   res@gsnDraw                  = False           ; don't draw yet
   res@gsnFrame                 = False           ; don't advance frame
   res@gsnTickMarksOn           = False
   res@gsnLeftString            = " "             ; no left string
   res@gsnRightString           = " "             ; no right string  
  
   res@mpFillOn               = True             ; turn on filles land --> needed to fill hole over Pole with grey, and then plot missing values grey as well later
   res@mpLandFillColor        = "grey"           
   res@mpOutlineOn            = False           ; turn on continental outline
   res@mpMinLatF             = 50                 ; adjust map limit
;  res@mpGridLatSpacingF    = 45.                ; change latitude  line spacing
   res@mpGridLonSpacingF    = 90.                 ; change longitude line spacing
;  res@mpFillDrawOrder  = "PostDraw"       ; Fill continents later to cover up lines
;  res@mpPerimDrawOrder  = "PostDraw"      ; Perimeter gets covered up by land
  
   
   res@cnMissingValPerimOn     = True     ; draw boarder of missing value areas  
   res@cnMissingValPerimColor  = "black"  ; make the missing value boarder black
   res@cnMissingValPerimThicknessF  = 1.0 ; sets the thickness of the missing value perimeter (factor of x)
   res@cnMissingValFillColor   = "grey" ;color  ; color of missing value 
   res@cnMissingValFillPattern =  0     ; 0 fills missing value area with solid color, 1 makes it transparent
 
   res@cnFillOn                = True             ; color fill
   res@cnLinesOn               = False            ; no contour lines
   res@cnLineLabelsOn          = False             ; no line labels
 
  
   res@lbLabelBarOn             = False           ; turn off individual cb's
   res@lbLabelAutoStride    = True                 ; nice label bar labels
 
 
   res@cnLevelSelectionMode = "ExplicitLevels"    
   res@cnLevels    = (/0.5,1.,1.5,2.,2.5,3.,3.5,4.0,4.5,5.0,5.5,6.0/)
   res@cnFillColors = (/2,11,32,47,66,90,111,133,145,162,176,187,200/) 
 

;***************************************************************************
; setup of plot  for data (marker plot)                 
;***************************************************************************

   res1                       = True
   res1@gsnPolar              = "NH"               ; choose hemisphere
   res1@gsnPaperOrientation   = "landscape"        ; force landscape plot
;  res1@gsnMaximize           = True               ;maximize plot size on page


   res1@gsnDraw                  = False           ; don't draw yet
   res1@gsnFrame                 = False           ; don't advance frame
   res1@gsnTickMarksOn           = False
;   res1@lbLabelBarOn             = False           ; turn off individual cb's
   res1@gsnLeftString            = " "             ; no left string
   res1@gsnRightString           = " "             ; no right string
 
   res1@gsnPolarLabelFontHeightF = 0.03          ; changes size of lat/lon labels
   res1@gsnPolarLabelDistance    = 1.08            ; determines how fat lat/lon labels are from plot
;  res1@gsnAddCyclic = True 

 
  res1@mpFillOn               = True             ; turn on filles land
  res1@mpLandFillColor        = "grey" 
  res1@mpOutlineOn            = True             ; turn on continental outline
  res1@mpMinLatF             = 50                 ; adjust map limit
;  res1@mpGridLatSpacingF    = 45.                ; change latitude  line spacing
  res1@mpGridLonSpacingF    = 90.                 ; change longitude line spacing
  res1@mpFillDrawOrder  = "PostDraw"       ; Fill continents later to cover up lines
  res1@mpPerimDrawOrder  = "PostDraw"      ; Perimeter gets covered up by land


; Marker set up
  pmres = True
  pmres@gsMarkerIndex      = 17             ; Filled circle
  pmres@gsMarkerSizeF      = 0.0125

; levels plotted by Markers
cnLevels = (/0.5,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5/)  ; meters of ice thickness 
colors = (/2,11,32,47,66,90,111,133,145,162,176,187,200/)

;
;****************************************************************
; make multiple panels
;****************************************************************
  plot1  = new(3,graphic)
  plot2  = new(3,graphic)
 
  res@gsnDraw                  = False           ; don't draw yet
  res@gsnFrame                 = False           ; don't advance frame
  res@lbLabelBarOn             = False           ; turn off individual cb's
  res@gsnLeftString            = " "             ; no left string
  res@gsnRightString           = " "             ; no right string
  
  resP                  = True                ; modify the panel plot
  resP@gsnFrame         = False              ; don't advance panel plot

  resP@gsnPanelFigureStringsBackgroundFillColor = "white"  ; makes background of label box white
  resP@gsnPanelFigureStringsFontHeightF = 0.015   ; text height of label
  resP@amJust = "TopRight"                 ; put label in top right corner


  resP@gsnPanelLabelBar = True                    ; adds common colorbar
  resP@lbLabelFontHeightF  = 0.013                 ; make labels smaller
  resP@pmLabelBarWidthF  = 0.5                      ;make Labelbar wider


  resP@gsnMaximize        = True        ; maximize area plot takes up on page
  resP@gsnPanelYWhiteSpacePercent = 5    ; add some white space between panels
  resP@txString = "Ice Thickness (m)"

 
;*************************************************************************

   res@gsnStringFontHeightF = 0.02
   res@gsnCenterString             = case_new + " (FM) "+cnew_frst_yr+"-"+cnew_last_yr
   plot1(0)=gsn_csm_contour_map_polar(wks1,hi_fm_new,res)
  
   res@gsnCenterString             = case_prev + " (FM) "+cprev_frst_yr+"-"+cprev_last_yr
   plot1(1)=gsn_csm_contour_map_polar(wks1,hi_fm_prev,res)

; ************* Plot IceSat data
  res1@gsnStringFontHeightF = 0.02
  res1@gsnCenterString             = "IceSat (FM) 2001-2005"
  plot1(2)=gsn_csm_map_polar(wks1,res1)  
 
; February March
 lon_fm_b=new((/12,dimsizes(lon_fm)/),"float")
  lat_fm_b=new((/12,dimsizes(lat_fm)/),"float")
  dum = new(12,graphic) ;  When adding polymarkers,each variable name has to be unique, so we create it here using "graphic"

 do i=0,11
    lon_fm_b(i,:)=where(thick_fm.gt.cnLevels(i) .and. thick_fm.lt.cnLevels(i+1),lon_fm,-999)
    lat_fm_b(i,:)=where(thick_fm.gt.cnLevels(i) .and. thick_fm.lt.cnLevels(i+1),lat_fm,-999)
    pmres@gsMarkerColor      =colors(i)
    dum(i)=gsn_add_polymarker(wks1, plot1(2), lon_fm_b(i,:), lat_fm_b(i,:), pmres) ; add polymarkers for original grid, but only for points > a certail contour level
 end do

; October-November

   res@gsnCenterString             = case_new + " (ON) "+cnew_frst_yr+"-"+cnew_last_yr
   plot2(0)=gsn_csm_contour_map_polar(wks2,hi_on_new,res)

   res@gsnCenterString             = case_prev + " (ON) "+cprev_frst_yr+"-"+cprev_last_yr
   plot2(1)=gsn_csm_contour_map_polar(wks2,hi_on_prev,res)

  res1@gsnCenterString             = "IceSat (ON) 2001-2005"
  plot2(2)=gsn_csm_map_polar(wks2,res1)  

 lon_on_b=new((/12,dimsizes(lon_on)/),"float")
  lat_on_b=new((/12,dimsizes(lat_on)/),"float")
  dum1 = new(12,graphic) ;  When adding polymarkers,each variable name has to be unique, so we create it here using "graphic"

  do i=0,11
    lon_on_b(i,:)=where(thick_on.gt.cnLevels(i) .and. thick_on.lt.cnLevels(i+1),lon_on,-999)
    lat_on_b(i,:)=where(thick_on.gt.cnLevels(i) .and. thick_on.lt.cnLevels(i+1),lat_on,-999)
    pmres@gsMarkerColor      =colors(i)
    dum1(i)=gsn_add_polymarker(wks2, plot2(2), lon_on_b(i,:), lat_on_b(i,:), pmres)  ; add polymarkers for original grid, but only for points > a certain contour level
 end do


;**************************************
   gsn_panel(wks1,plot1,(/2,2/),resP)
   gsn_panel(wks2,plot2,(/2,2/),resP)
   frame(wks1)
   frame(wks2)

  
;**************************************************************************


end

