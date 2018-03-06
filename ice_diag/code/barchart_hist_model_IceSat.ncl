
;******************************************************************************
; Plot ensemble mean sea ice thickness distrubtion compared to IceSat, for 2001-2005
; Written by A. Jahn, 2011
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
  tarea=25000*25000 ; grid boxes are 25km by 25 km 
  tarea@units="m^2"

; *********** Model ****************************************

   b = addfile(gridfilename,"r")
   llat = dble2flt(b->TLAT)
   llon = dble2flt(b->TLONG)
   area = dble2flt(b->TAREA)
   delete(b)

   ifrst_avg_yr = stringtointeger(frst_avg_yr)
   ilast_avg_yr = stringtointeger(last_avg_yr)
   cyear_frst = sprinti("%0.4i", ifrst_avg_yr)   ; Convert integer year to string
   cyear_last = sprinti("%0.4i", ilast_avg_yr)   ; Convert integer year to string

   filename = "fm_avg_" + cyear_frst + "-" + cyear_last + ".nc"
   in1 = addfile(dir + "/" + filename,"r")
   hi_fm_tmp = in1->hi(0,:,:)
   aice_fm = in1->aice(0,:,:)

   filename = "on_avg_" + cyear_frst + "-" + cyear_last + ".nc"
   in2 = addfile(dir + "/" + filename,"r")
   hi_on_tmp   = in2->hi(0,:,:)
   aice_on   = in2->aice(0,:,:)

   aice_fm = where(aice_fm.gt.0.0,aice_fm,aice_fm@_FillValue)
   aice_on = where(aice_fm.gt.0.0,aice_fm,aice_fm@_FillValue)

   hi_fm = where(aice_fm.gt.0.0,hi_fm_tmp/aice_fm,0.)
   hi_on = where(aice_on.gt.0.0,hi_on_tmp/aice_on,0.)

    nrank = dimsizes(dimsizes(llat))
    dims = dimsizes(llat)
    if (nrank .eq. 3) then
       hi_fm@lat2d = llat(0,:,:)
       hi_fm@lon2d = llon(0,:,:)
       hi_on@lat2d = llat(0,:,:)
       hi_on@lon2d = llon(0,:,:)
       nj = dims(1)
       ni = dims(2)
    else
       hi_fm@lat2d = llat
       hi_fm@lon2d = llon
       hi_on@lat2d = llat
       hi_on@lon2d = llon
       nj = dims(0)
       ni = dims(1)
    end if

 ; get mask to mask out CAA and Baffin Bay to match data
  in_0 = addfile(diag_obs+"/CCSM4_Arctic_mask.nc","r")
  mask_no_Barents_Kara_CAA_Nares=in_0->CCSM4_Arctic_mask_no_Barents_Kara_CAA_Nares

; mask out Baffin and CAA and Hudson to make it consistent with ICESat covered area

hi_fm=hi_fm*mask_no_Barents_Kara_CAA_Nares
hi_on=hi_on*mask_no_Barents_Kara_CAA_Nares

area_m=area*mask_no_Barents_Kara_CAA_Nares;

;************; Scale to get fractional area each bin occupies************
level=(/0,0.5,1.,1.5,2.,2.5,3.,3.5,4.0,4.5,5.0,5.5,6.0,6.5,100/)
; bins: 
; 0-0.5
; 0.5-1
; 1-1.5
; 1.5-2
; etc

ice_m_fall=new((/14,nj,ni/),"float")
ice_m_fall_area=new((/14,nj,ni/),"float")
ice_m_spring=new((/14,nj,ni/),"float")
ice_m_spring_area=new((/14,nj,ni/),"float")

thick_fall=new((/14,11118/),"float")
thick_s_fall_area=new((/14,11118/),"float")
thick_spring=new((/14,11118/),"float")
thick_s_spring_area=new((/14,11118/),"float")



do i=0,13
  ice_m_fall(i,:,:)=where(hi_on.gt.level(i) .and. hi_on.le.level(i+1),1,0)
  ice_m_spring(i,:,:)=where(hi_fm.gt.level(i) .and. hi_fm.le.level(i+1),1,0)
  ice_m_fall_area(i,:,:)=ice_m_fall(i,:,:)*area_m;
  ice_m_spring_area(i,:,:)=ice_m_spring(i,:,:)*area_m;
  thick_fall(i,:)=where(thick_on.gt.level(i) .and. thick_on.le.level(i+1),1,0)
  thick_spring(i,:)=where(thick_fm.gt.level(i) .and. thick_fm.le.level(i+1),1,0)
  thick_s_fall_area(i,:)=thick_fall(i,:)*tarea;
  thick_s_spring_area(i,:)=thick_spring(i,:)*tarea;
end do

ice_fall_area=dim_sum_n_Wrap(dim_sum_n_Wrap(ice_m_fall_area,2),1)
ice_spring_area=dim_sum_n_Wrap(dim_sum_n_Wrap(ice_m_spring_area,2),1)

thick_fall_area=dim_sum_n_Wrap(thick_s_fall_area,1)
thick_spring_area=dim_sum_n_Wrap(thick_s_spring_area,1)

; total area
thick_fall_total_area=dim_sum_n_Wrap(thick_fall_area,0)
thick_spring_total_area=dim_sum_n_Wrap(thick_spring_area,0)
ice_fall_total_area=dim_sum_n_Wrap(ice_fall_area,0)
ice_spring_total_area=dim_sum_n_Wrap(ice_spring_area,0)


; fraction of total ice area
ice_fall_area_fraction=ice_fall_area/ice_fall_total_area
ice_spring_area_fraction=ice_spring_area/ice_spring_total_area

thick_fall_area_fraction=thick_fall_area/thick_fall_total_area
thick_spring_area_fraction=thick_spring_area/thick_spring_total_area

fall=(/thick_fall_area_fraction,ice_fall_area_fraction/)
spring=(/thick_spring_area_fraction,ice_spring_area_fraction/)

 labels = (/"ICESat",p_case/)

;************************************************
; create plots
;************************************************

  wks1 = gsn_open_wks(wks_type,wkdir+"fm_icesat_barchart")            ; open first ps file  
  gsn_define_colormap(wks1,"wh-bl-gr-ye-re") 
  i = NhlNewColor(wks1,0.7,0.7,0.7)              ; add gray to colormap
  wks2 = gsn_open_wks(wks_type,wkdir+"on_icesat_barchart")            ; open first ps file  
  gsn_define_colormap(wks2,"wh-bl-gr-ye-re") 
  i = NhlNewColor(wks2,0.7,0.7,0.7)              ; add gray to colormap
 
 ;*******************************************************
; Plot
;********************************************************
  plot = new(2,graphic)
  plot1 = new(2,graphic)
  res   = True
  res@gsnXYBarChart = True            ; Create bar plot
 
  res@gsnDraw                  = False           ; don't draw yet
  res@gsnFrame                 = False           ; don't advance frame
   res@xyLineColors       = (/"gray55"/)
  res@gsnXYBarChartColors = (/"gray55"/)	
 res@tiYAxisString = "Fraction of total ice area"
 res@tiXAxisString = "ice thickness [m]"
     
;************* panel settings *************
  
; resP                  = True                ; modify the panel plot
; resP@gsnFrame         = False              ; don't advance panel plot
; resP@gsnPanelFigureStrings = (/"(a) Spring","(b) Fall"/);; adds labels to subplots
; resP@gsnPanelFigureStringsBackgroundFillColor = "white"  ; makes background of label box white
; resP@gsnPanelFigureStringsFontHeightF = 0.015   ; text height of label
; resP@amJust = "TopRight"                 ; put label in top right corner
; resP@gsnMaximize        = True        ; maximize area plot takes up on page
; resP@gsnPanelYWhiteSpacePercent = 5    ; add some white space between panels
; resP@gsnPanelFigureStringsPerimOn = False ; no box around labels

  res@tmXBMode          = "Explicit"         ; explicit labels
  res@tmXBValues        = (/0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5/)
  res@tmXBLabels = (/0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5/)
  res@tmXBLabelFontHeightF = 0.0205
  res@trXMinF = 0
  res@trXMaxF = 7.0
  res@trYMinF = 0
  res@trYMaxF = 0.5

;************ PLOT**************************
; need to add 0.25 as bars are drawn centered on level, the outline is drawn up to the level, 
; and we want them both to be plotted on the same x-axis
  plot(0) = gsn_csm_xy (wks1,level(0:13)+0.25,spring(0,:),res) 
  delete(res@tiYAxisString)
  res@trYMaxF = 0.5
  plot(1) = gsn_csm_xy (wks2,level(0:13)+0.25,fall(0,:),res)

  res@gsnXYBarChartOutlineOnly = True
  delete(res@xyLineColors)
  delete(res@gsnXYBarChartColors)
  res@xyMonoLineColor    = False             ; want colored lines
  res@xyLineColors       = (/"black"/) ; colors chosen
  res@xyLineThicknesses	 = (/5./)      ; line thicknesses
  res@xyDashPatterns	 = (/0/)      ; make all lines solid
  res@trYMaxF = 0.5
;
; Add a legend.
;
  gres = True
  gres@YPosPercent = 95.    ; expressed as %, 0->100, sets position of top border of legend
                            ;  when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres@XPosPercent = 30.    ; expressed as %, 0->100, sets position of left border of legend(Default = 5.)

  lineres = True
  lineres@lgLineColors = (/"gray55","black"/) ; line colors
  lineres@lgLineThicknesses = (/30,3/)                    ; line thicknesses
  lineres@LineLengthPercent = 9.                         ; expressed as %, 0->100, length of line

  textres = True
  textres@lgLabels = labels  ; legend labels (required)

  res@tiMainString = "Spring (FM)"
  plot1(0) = gsn_csm_xy (wks1,level(0:13),spring(1,:),res)
  res@trYMaxF = 0.5
  res@tiMainString = "Fall (ON)"
  plot1(1) = gsn_csm_xy (wks2,level(0:13),fall(1,:),res)

  plot1(0) = simple_legend(wks1,plot1(0),gres,lineres,textres)
  plot1(1) = simple_legend(wks2,plot1(1),gres,lineres,textres)

  draw(plot(0))
  draw(plot(1))
  draw(plot1(0))
  draw(plot1(1))

  overlay(plot(0),plot1(0))
  overlay(plot(1),plot1(1))

  frame(wks1)
  frame(wks2)

;**************************************************************************


end

