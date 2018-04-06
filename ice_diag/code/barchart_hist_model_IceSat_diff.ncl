
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
dir   = getenv("PATH_PLOT")          ; Input data here
hires = getenv("HIRES")
new_frst_avg_yr = getenv("NEW_YR_AVG_FRST")
new_last_avg_yr = getenv("NEW_YR_AVG_LAST")
prev_frst_avg_yr = getenv("PREV_YR_AVG_FRST")
prev_last_avg_yr = getenv("PREV_YR_AVG_LAST")
case_prev = getenv("CASE_PREV")
case_new  = getenv("CASE_NEW")
path_prev = getenv("PATH_PREV")
path_new  = getenv("PATH_NEW")
grid_prev = getenv("GRID_DIFF")
grid_new = getenv("GRID_CONT")
gridfilenew = getenv("GRIDFILECONT")
gridfileprev = getenv("GRIDFILEDIFF")
var_name_new = getenv("VAR_NAME_NEW")
var_name_prev = getenv("VAR_NAME_PREV")


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

   b = addfile(gridfileprev,"r")
   llat1 = dble2flt(b->TLAT)
   llon1 = dble2flt(b->TLONG)
   area1 = dble2flt(b->TAREA)
   delete(b)

   b = addfile(gridfilenew,"r")
   llat2 = dble2flt(b->TLAT)
   llon2 = dble2flt(b->TLONG)
   area2 = dble2flt(b->TAREA)
   delete(b)

   inew_frst_yr = stringtointeger(new_frst_avg_yr)
   inew_last_yr = stringtointeger(new_last_avg_yr)
   iprev_frst_yr = stringtointeger(prev_frst_avg_yr)
   iprev_last_yr = stringtointeger(prev_last_avg_yr)

   cnew_frst_yr = sprinti("%0.4i",inew_frst_yr)
   cnew_last_yr = sprinti("%0.4i",inew_last_yr)
   cprev_frst_yr = sprinti("%0.4i",iprev_frst_yr)
   cprev_last_yr = sprinti("%0.4i",iprev_last_yr)

   filename = "fm_avg_" + cnew_frst_yr + "-" + cnew_last_yr + ".nc"
   in1 = addfile(path_new + "/" + filename,"r")
   hi_fm_tmp_new = in1->hi(0,:,:)
   aice_fm_new = in1->aice(0,:,:)

   filename = "fm_avg_" + cprev_frst_yr + "-" + cprev_last_yr + ".nc"
   in2 = addfile(path_prev + "/" + filename,"r")
   hi_fm_tmp_prev = in2->hi(0,:,:)
   aice_fm_prev = in2->aice(0,:,:)

   filename = "on_avg_" + cnew_frst_yr + "-" + cnew_last_yr + ".nc"
   in3 = addfile(path_new + "/" + filename,"r")
   hi_on_tmp_new   = in3->hi(0,:,:)
   aice_on_new   = in3->aice(0,:,:)

   filename = "on_avg_" + cprev_frst_yr + "-" + cprev_last_yr + ".nc"
   in4 = addfile(path_prev + "/" + filename,"r")
   hi_on_tmp_prev   = in4->hi(0,:,:)
   aice_on_prev   = in4->aice(0,:,:)

   aice_fm_new = where(aice_fm_new.gt.0.0,aice_fm_new,aice_fm_new@_FillValue)
   aice_on_new = where(aice_fm_new.gt.0.0,aice_fm_new,aice_fm_new@_FillValue)
   hi_fm_new = where(aice_fm_new.gt.0.0,hi_fm_tmp_new/aice_fm_new,0.)
   hi_on_new = where(aice_on_new.gt.0.0,hi_on_tmp_new/aice_on_new,0.)

   aice_fm_prev = where(aice_fm_prev.gt.0.0,aice_fm_prev,aice_fm_prev@_FillValue)
   aice_on_prev = where(aice_fm_prev.gt.0.0,aice_fm_prev,aice_fm_prev@_FillValue)
   hi_fm_prev = where(aice_fm_prev.gt.0.0,hi_fm_tmp_prev/aice_fm_prev,0.)
   hi_on_prev = where(aice_on_prev.gt.0.0,hi_on_tmp_prev/aice_on_prev,0.)

    nrank1 = dimsizes(dimsizes(llat1))
    dims1 = dimsizes(llat1)
    if (nrank1 .eq. 3) then
       hi_fm_prev@lat2d = llat1(0,:,:)
       hi_fm_prev@lon2d = llon1(0,:,:)
       hi_on_prev@lat2d = llat1(0,:,:)
       hi_on_prev@lon2d = llon1(0,:,:)
       nj1 = dims1(1)
       ni1 = dims1(2)
    else
       hi_fm_prev@lat2d = llat1
       hi_fm_prev@lon2d = llon1
       hi_on_prev@lat2d = llat1
       hi_on_prev@lon2d = llon1
       nj1 = dims1(0)
       ni1 = dims1(1)
    end if

    nrank2 = dimsizes(dimsizes(llat2))
    dims2 = dimsizes(llat2)
    if (nrank2 .eq. 3) then
       hi_fm_new@lat2d = llat2(0,:,:)
       hi_fm_new@lon2d = llon2(0,:,:)
       hi_on_new@lat2d = llat2(0,:,:)
       hi_on_new@lon2d = llon2(0,:,:)
       nj2 = dims2(1)
       ni2 = dims2(2)
    else
       hi_fm_new@lat2d = llat2
       hi_fm_new@lon2d = llon2
       hi_on_new@lat2d = llat2
       hi_on_new@lon2d = llon2
       nj2 = dims2(0)
       ni2 = dims2(1)
    end if

 ; get mask to mask out CAA and Baffin Bay to match data
  in_0 = addfile(diag_obs+"/CCSM4_Arctic_mask.nc","r")
  mask_no_Barents_Kara_CAA_Nares=in_0->CCSM4_Arctic_mask_no_Barents_Kara_CAA_Nares

; mask out Baffin and CAA and Hudson to make it consistent with ICESat covered area

hi_fm_new=hi_fm_new*mask_no_Barents_Kara_CAA_Nares
hi_on_new=hi_on_new*mask_no_Barents_Kara_CAA_Nares
hi_fm_prev=hi_fm_prev*mask_no_Barents_Kara_CAA_Nares
hi_on_prev=hi_on_prev*mask_no_Barents_Kara_CAA_Nares

area_m_prev=area1*mask_no_Barents_Kara_CAA_Nares;
area_m_new=area2*mask_no_Barents_Kara_CAA_Nares;

;************; Scale to get fractional area each bin occupies************
level=(/0,0.5,1.,1.5,2.,2.5,3.,3.5,4.0,4.5,5.0,5.5,6.0,6.5,100/)
; bins: 
; 0-0.5
; 0.5-1
; 1-1.5
; 1.5-2
; etc

ice_m_fall_new=new((/14,nj2,ni2/),"float")
ice_m_fall_area_new=new((/14,nj2,ni2/),"float")
ice_m_fall_prev=new((/14,nj1,ni1/),"float")
ice_m_fall_area_prev=new((/14,nj1,ni1/),"float")
ice_m_spring_new=new((/14,nj2,ni2/),"float")
ice_m_spring_area_new=new((/14,nj2,ni2/),"float")
ice_m_spring_prev=new((/14,nj1,ni1/),"float")
ice_m_spring_area_prev=new((/14,nj1,ni1/),"float")

thick_fall=new((/14,11118/),"float")
thick_s_fall_area=new((/14,11118/),"float")
thick_spring=new((/14,11118/),"float")
thick_s_spring_area=new((/14,11118/),"float")



do i=0,13
  ice_m_fall_new(i,:,:)=where(hi_on_new.gt.level(i) .and. hi_on_new.le.level(i+1),1,0)
  ice_m_spring_new(i,:,:)=where(hi_fm_new.gt.level(i) .and. hi_fm_new.le.level(i+1),1,0)
  ice_m_fall_area_new(i,:,:)=ice_m_fall_new(i,:,:)*area_m_new;
  ice_m_spring_area_new(i,:,:)=ice_m_spring_new(i,:,:)*area_m_new;
  ice_m_fall_prev(i,:,:)=where(hi_on_prev.gt.level(i) .and. hi_on_prev.le.level(i+1),1,0)
  ice_m_spring_prev(i,:,:)=where(hi_fm_prev.gt.level(i) .and. hi_fm_prev.le.level(i+1),1,0)
  ice_m_fall_area_prev(i,:,:)=ice_m_fall_prev(i,:,:)*area_m_prev;
  ice_m_spring_area_prev(i,:,:)=ice_m_spring_prev(i,:,:)*area_m_prev;
  thick_fall(i,:)=where(thick_on.gt.level(i) .and. thick_on.le.level(i+1),1,0)
  thick_spring(i,:)=where(thick_fm.gt.level(i) .and. thick_fm.le.level(i+1),1,0)
  thick_s_fall_area(i,:)=thick_fall(i,:)*tarea;
  thick_s_spring_area(i,:)=thick_spring(i,:)*tarea;
end do

ice_fall_area_new=dim_sum_n_Wrap(dim_sum_n_Wrap(ice_m_fall_area_new,2),1)
ice_spring_area_new=dim_sum_n_Wrap(dim_sum_n_Wrap(ice_m_spring_area_new,2),1)
ice_fall_area_prev=dim_sum_n_Wrap(dim_sum_n_Wrap(ice_m_fall_area_prev,2),1)
ice_spring_area_prev=dim_sum_n_Wrap(dim_sum_n_Wrap(ice_m_spring_area_prev,2),1)

thick_fall_area=dim_sum_n_Wrap(thick_s_fall_area,1)
thick_spring_area=dim_sum_n_Wrap(thick_s_spring_area,1)

; total area
ice_fall_total_area_new=dim_sum_n_Wrap(ice_fall_area_new,0)
ice_spring_total_area_new=dim_sum_n_Wrap(ice_spring_area_new,0)
ice_fall_total_area_prev=dim_sum_n_Wrap(ice_fall_area_prev,0)
ice_spring_total_area_prev=dim_sum_n_Wrap(ice_spring_area_prev,0)

thick_fall_total_area=dim_sum_n_Wrap(thick_fall_area,0)
thick_spring_total_area=dim_sum_n_Wrap(thick_spring_area,0)


; fraction of total ice area
ice_fall_area_fraction_new=ice_fall_area_new/ice_fall_total_area_new
ice_spring_area_fraction_new=ice_spring_area_new/ice_spring_total_area_new
ice_fall_area_fraction_prev=ice_fall_area_prev/ice_fall_total_area_prev
ice_spring_area_fraction_prev=ice_spring_area_prev/ice_spring_total_area_prev

thick_fall_area_fraction=thick_fall_area/thick_fall_total_area
thick_spring_area_fraction=thick_spring_area/thick_spring_total_area

fall=(/thick_fall_area_fraction,ice_fall_area_fraction_new,ice_fall_area_fraction_prev/)
spring=(/thick_spring_area_fraction,ice_spring_area_fraction_new,ice_spring_area_fraction_prev/)

 labels = (/"ICESat (2001-2005)",case_new+" ("+new_frst_avg_yr+"-"+new_last_avg_yr+")",case_prev+" ("+prev_frst_avg_yr+"-"+prev_last_avg_yr+")"/)

;************************************************
; create plots
;************************************************

  wks1 = gsn_open_wks(wks_type,wkdir+"fm_icesat_barchart_diff")            ; open first ps file  
  gsn_define_colormap(wks1,"wh-bl-gr-ye-re") 
  i = NhlNewColor(wks1,0.7,0.7,0.7)              ; add gray to colormap
  wks2 = gsn_open_wks(wks_type,wkdir+"on_icesat_barchart_diff")            ; open first ps file  
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
  res@trYMaxF = 0.5
  plot(1) = gsn_csm_xy (wks2,level(0:13)+0.25,fall(0,:),res)
  delete(res@tiYAxisString)

  res@gsnXYBarChartOutlineOnly = True
  delete(res@xyLineColors)
  delete(res@gsnXYBarChartColors)
  res@xyMonoLineColor    = False             ; want colored lines
  res@xyLineColors       = (/"black","red"/) ; colors chosen
  res@xyLineThicknesses	 = (/5.,5./)      ; line thicknesses
  res@xyDashPatterns	 = (/0,0/)      ; make all lines solid
  res@trYMaxF = 0.5
;
; Add a legend.
;
  gres = True
  gres@YPosPercent = 95.    ; expressed as %, 0->100, sets position of top border of legend
                            ;  when gres@Position is set to its default setting of "Top" (Default = 95.)
  gres@XPosPercent = 30.    ; expressed as %, 0->100, sets position of left border of legend(Default = 5.)

  lineres = True
  lineres@lgLineColors = (/"gray55","black","red"/) ; line colors
  lineres@lgLineThicknesses = (/30,3,3/)                    ; line thicknesses
  lineres@LineLengthPercent = 9.                         ; expressed as %, 0->100, length of line

  textres = True
  textres@lgLabels = labels  ; legend labels (required)
  textres@lgLabelFontHeights = (/0.010,0.010,0.010/)

  res@tiMainString = "Spring (FM)"
  plot1(0) = gsn_csm_xy (wks1,level(0:13),spring(1:2,:),res)
  res@trYMaxF = 0.5
  res@tiMainString = "Fall (ON)"
  plot1(1) = gsn_csm_xy (wks2,level(0:13),fall(1:2,:),res)

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

