
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

wkdir = getenv("WKDIR")              ; Plots output here
diag_home = getenv("DIAG_HOME")              
diag_obs = getenv("DIAGOBSROOT")
p_case = getenv("CASE_TO_CONT")
dir   = getenv("PATH_PLOT")          ; Input data here
frst_avg_yr = getenv("YR_AVG_FRST")
last_avg_yr = getenv("YR_AVG_LAST")
var_name = getenv("VAR_NAMES")
hires = getenv("HIRES")
gridfilename = getenv("GRIDFILECONT")

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


   b = addfile(gridfilename,"r")
   llat = dble2flt(b->TLAT)
   llon = dble2flt(b->TLONG)
   delete(b)

   ifrst_avg_yr = stringtointeger(frst_avg_yr)
   ilast_avg_yr = stringtointeger(last_avg_yr)
   cyear_frst = sprinti("%0.4i", ifrst_avg_yr)   ; Convert integer year to string
   cyear_last = sprinti("%0.4i", ilast_avg_yr)   ; Convert integer year to string

   filename = "fm_avg_" + cyear_frst + "-" + cyear_last + ".nc"
   in1 = addfile(dir + "/" + filename,"r")
   hi_fm = in1->hi(0,:,:)

   filename = "on_avg_" + cyear_frst + "-" + cyear_last + ".nc"
   in2 = addfile(dir + "/" + filename,"r")
   hi_on   = in2->hi(0,:,:)

    nrank = dimsizes(dimsizes(llat))
    if (nrank .eq. 3) then
       hi_fm@lat2d = llat(0,:,:)
       hi_fm@lon2d = llon(0,:,:)
       hi_on@lat2d = llat(0,:,:)
       hi_on@lon2d = llon(0,:,:)
    else
       hi_fm@lat2d = llat
       hi_fm@lon2d = llon
       hi_on@lat2d = llat
       hi_on@lon2d = llon
    end if


;************************************************
; create plots
;************************************************

  wks1 = gsn_open_wks(wks_type,wkdir+"con_hi_icesat_fm")            ; open first ps file  
  gsn_define_colormap(wks1,"wh-bl-gr-ye-re") 
  i = NhlNewColor(wks1,0.7,0.7,0.7)              ; add gray to colormap
 
  wks2 = gsn_open_wks(wks_type,wkdir+"con_hi_icesat_on")            ; open secon ps file  
  gsn_define_colormap(wks2,"wh-bl-gr-ye-re") 
  i = NhlNewColor(wks2,0.7,0.7,0.7)              ; add gray to colormap
 
  ;***************************************************************************
; setup of filled MYarea contour plot                   
;***************************************************************************
 
   res                       = True
   res@gsnPolar              = "NH"               ; choose hemisphere
   res@gsnPaperOrientation   = "landscape"        ; force landscape plot
   res@gsnMaximize           = True               ;maximize plot size on page
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
   res@trGridType           = "TriangularMesh"  ; Define the mesh type
  
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
   res1@gsnMaximize           = True               ;maximize plot size on page


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
  plot1  = new(2,graphic)
  plot2  = new(2,graphic)
 
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
   res@tiMainString             = p_case+" (FM) "+cyear_frst+"-"+cyear_last
   plot1(0)=gsn_csm_contour_map_polar(wks1,hi_fm,res)
  

; ************* Plot IceSat data
  res1@gsnStringFontHeightF = 0.02
  res1@tiMainString             = "IceSat (FM) 2001-2005"
  plot1(1)=gsn_csm_map_polar(wks1,res1)  
 
; February March
 lon_fm_b=new((/12,dimsizes(lon_fm)/),"float")
  lat_fm_b=new((/12,dimsizes(lat_fm)/),"float")
  dum = new(12,graphic) ;  When adding polymarkers,each variable name has to be unique, so we create it here using "graphic"

 do i=0,11
    lon_fm_b(i,:)=where(thick_fm.gt.cnLevels(i) .and. thick_fm.lt.cnLevels(i+1),lon_fm,-999)
    lat_fm_b(i,:)=where(thick_fm.gt.cnLevels(i) .and. thick_fm.lt.cnLevels(i+1),lat_fm,-999)
    pmres@gsMarkerColor      =colors(i)
    dum(i)=gsn_add_polymarker(wks1, plot1(1), lon_fm_b(i,:), lat_fm_b(i,:), pmres) ; add polymarkers for original grid, but only for points > a certail contour level
 end do

; October-November

   res@tiMainString             = p_case+" (ON) "+cyear_frst+"-"+cyear_last
   plot2(0)=gsn_csm_contour_map_polar(wks2,hi_on,res)

  res1@tiMainString             = "IceSat (ON) 2001-2005"
  plot2(1)=gsn_csm_map_polar(wks2,res1)  

 lon_on_b=new((/12,dimsizes(lon_on)/),"float")
  lat_on_b=new((/12,dimsizes(lat_on)/),"float")
  dum1 = new(12,graphic) ;  When adding polymarkers,each variable name has to be unique, so we create it here using "graphic"

  do i=0,11
    lon_on_b(i,:)=where(thick_on.gt.cnLevels(i) .and. thick_on.lt.cnLevels(i+1),lon_on,-999)
    lat_on_b(i,:)=where(thick_on.gt.cnLevels(i) .and. thick_on.lt.cnLevels(i+1),lat_on,-999)
    pmres@gsMarkerColor      =colors(i)
    dum1(i)=gsn_add_polymarker(wks2, plot2(1), lon_on_b(i,:), lat_on_b(i,:), pmres)  ; add polymarkers for original grid, but only for points > a certain contour level
 end do


;**************************************
   gsn_panel(wks1,plot1,(/2,1/),resP)
   gsn_panel(wks2,plot2,(/2,1/),resP)
   frame(wks1)
   frame(wks2)

  
;**************************************************************************


end

