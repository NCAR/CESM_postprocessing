load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  daypermon = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31./)
  midmonday = (/15.5,45.,74.5,105.,135.5,166.,196.5,227.5,258.,288.5,319.,349.5/)

  casename = getenv("CASE")
  file_in = getenv("FILE_IN")
  year0str = getenv("TSERIES_YEAR0")
  year1str = getenv("TSERIES_YEAR1")
  img_format = getenv("IMAGEFORMAT")

  year0 = stringtointeger(year0str)
  year1 = stringtointeger(year1str)

  ncol = 10
  data = readAsciiTable(file_in, ncol, "float", 1)
  MON  = floattoint( data(:,0) )
  DAY  = floattoint( data(:,1) )
  YR   = floattoint( data(:,2) )
  mon  = floattoint( data(:,3) )
  day  = floattoint( data(:,4) )
  yr   = floattoint( data(:,5) )

  data@long_name = "nino12"
  nino12  = rmAnnCycle1D(data(:,6))
  data@long_name = "nino3"
  nino3   = rmAnnCycle1D(data(:,7))
  data@long_name = "nino34"
  nino34  = rmAnnCycle1D(data(:,8))
  data@long_name = "nino4"
  nino4   = rmAnnCycle1D(data(:,9))

  nt = dimsizes(nino4)
  time =  new(nt,float)
  do i = 0,nt-1
    time(i) = yr(i) + midmonday(mon(i)-1)/365.
  end do

  nino3!0 = "time"
  nino3@long_name = "Nino 3"
  nino3&time = time
  nino34!0 = "time"
  nino34@long_name = "Nino 3.4"
  nino34&time = time
  time!0 = "time"
  time&time = time

  specavg = ind((time.gt.year0).and.(time.lt.(year1+1)))
  nmonavg = dimsizes(specavg)
  specavg0 = specavg(0)
  specavg1 = specavg(nmonavg-1)
  specnyr = year1-year0+1

  nmons = dimsizes(time)
  first = tointeger(time(0))
  last = tointeger(time(nmons-1))

  nyrs = last-first+1

  if ((nyrs*12).gt.nmons) then
    nyrs = nyrs - 1
    last = last-1
  end if
  year_arr = (/first,last+1/)

; ########################################
;             WAVELETS
; ########################################

;************************************
; set some parameters 
;************************************
  idtrend = 0                      ; 0=no_detrend   ; 1=detrend
  ismooth = 0 			   ; n-month running smoother
  if (idtrend.eq.1) then 
    tmp = dtrend(nino3,False)
    nino3 = tmp
    delete(tmp)
    tmp = dtrend(nino34,False)
    nino34 = tmp
    delete(tmp)
  end if
  if (ismooth.gt.1) then 
    tmp = runave(nino3, ismooth, 1)
    nino3 = tmp
    delete(tmp)
    tmp = runave(nino34, ismooth, 1)
    nino34 = tmp
    delete(tmp)
  end if

;************************************    
; create pointer to file and read in variables
;************************************  
  
  N    = dimsizes(time)       
;************************************
; compute wavelet
;************************************  
  mother  = 0
  param   = 6.0
  dt      = 1./12.              ; in units of years ==> monthly data expected!
  s0      = dt
  dj      = 1./12.
  jtot    = 1+floattointeger(((log10(N*dt/s0))/dj)/log10(2.))
  npad    = N
  nadof   = 0
  noise   = 1 
  siglvl  = .05
  isigtest= 0

  wave3  = wavelet(nino3,mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)
  wave34 = wavelet(nino34,mother,dt,param,s0,dj,jtot,npad,noise,isigtest,siglvl,nadof)


;************************************
; create nino3 coodinate arrays for plot
;************************************
  power3            = onedtond(wave3@power,(/jtot,N/))
  power3!0          = "period"                        ; Y axis
  power3&period     = wave3@period
  power3!1          = "time"                          ; X axis
  power3&time       = time

  gws3 = wave3@gws
  gws3!0          = "period"                        ; Y axis
  gws3&period     = wave3@period

; compute significance ( >= 1 is significant)
  SIG3              = power3                            ; transfer meta data
  SIG3              = power3/conform (power3,wave3@signif,0)
  SIG3@long_name    = "Significance"
  SIG3@units        = " "

;************************************
; create nino3.4 coodinate arrays for plot
;************************************
  power34            = onedtond(wave34@power,(/jtot,N/))
  power34!0          = "period"                        ; Y axis
  power34&period     = wave34@period
  power34!1          = "time"                          ; X axis
  power34&time       = time

  gws34 = wave34@gws
  gws34!0          = "period"                        ; Y axis
  gws34&period     = wave34@period

; compute significance ( >= 1 is significant)
  SIG34              = power34                            ; transfer meta data
  SIG34              = power34/conform (power34,wave34@signif,0)
  SIG34@long_name    = "Significance"
  SIG34@units        = " "


; ########################################
;             AUTOCORRELATIONS
; ########################################
  nmonths = 48

  acorr3  = esacr(nino3(specavg0:specavg1),nmonths)   ; 48 months
  acorr34 = esacr(nino34(specavg0:specavg1),nmonths)   


;########################################
;   MONTHLY VARIANCES
;########################################
  var_mon3  = new(12,"float")
  var_mon34 = new(12,"float")

  do iymons = 0, 11
    stmon = iymons+specavg0
    nymons = ispan(stmon,12*(specnyr-1)+stmon,12)
    var_mon3(iymons)  = variance(nino3(nymons))
    var_mon34(iymons) = variance(nino34(nymons))
  end do

;########################################
;########################################
;        PLOTS
;########################################
;########################################
  print("plotting ENSO nino3 analysis")
  wks = gsn_open_wks(img_format,"ENSO.nino3.analysis")
  gsn_define_colormap(wks,"wh-bl-gr-ye-re")

;1. Nino3.4 Timeseries
  res = True
  res@gsnFrame            = False                 ; don't advance frame yet
  res@tmXTOn              = False
  res@tiYAxisString = "~F33~D~F~ SST (K)"
  res@tiXAxisFontHeightF = 0.018
  res@tiYAxisFontHeightF = 0.018
  res@tmYLLabelFontHeightF = 0.015
  res@tmXBLabelFontHeightF = 0.015
  res@txFontHeightF = 0.018
  res@xyLineThicknessF = 0.2
  res@xyLineColor = "black"
  res@tmYROn              = False
  res@tmXBOn              = False
  res@gsnYRefLine = 0.0
  res@gsnAboveYRefLineColor = "red"
  res@gsnBelowYRefLineColor = "blue"
  res@trYMinF = -3.0 
  res@trYMaxF = 3.0 

  res@tmYLMode = "Explicit"
  res@tmYLValues = (/-3,-2,-1,0,1,2,3/)
  res@tmYLLabels = (/"-3","-2","-1","0","1","2","3"/)

  res@vpXF            = 0.1         
  res@vpYF            = 0.96
  res@vpHeightF       = .25                    ;
  res@vpWidthF        = .7

  res@gsnCenterString = casename+" nino3 Monthly SST Anomalies + Wavelet Power (K~S~2~N~)"
  plot1 = gsn_csm_xy(wks,time,nino3,res)

;-------------------------------------------------------
;2. Wavelet plot

  wave                     = True                  ; plot mods desired 
  wave@gsnFrame            = False                 ; don't advance frame yet
  wave@gsnDraw             = False
  wave@cnFillOn            = True                  ; turn on color
  wave@cnFillMode          = "RasterFill"          ; turn on raster mode
  wave@cnRasterSmoothingOn = True                  ; turn on raster smoothing
  wave@cnLinesOn           = False                 ; turn off contour lines
  wave@gsnSpreadColors     = True                  ; use full colormap
  wave@cnInfoLabelOn       = False
  wave@lbLabelBarOn        = True
  wave@lbAutoManage        = False
  wave@lbOrientation       = "Horizontal"            ; vertical label bar
  wave@lbBoxMinorExtentF   = 0.18
  wave@lbLabelFontHeightF  = 0.012
  wave@tmXTOn              = False
  wave@tmYROn              = False
  wave@tmXBLabelFontHeightF = 0.012
  wave@tmYLLabelFontHeightF = 0.012
  wave@tmXBOn = True
  wave@tmXBMode = "Explicit"
  wave@trYReverse          = True                  ; reverse y-axis
  wave@tmLabelAutoStride   = True
  wave@tiXAxisString = ""
  wave@tiYAxisString = "Period (years)"
  wave@tmXBValues = ispan(first-1,last,5)
  wave@tmXBLabels = ispan(first-1,last,5)
  wave@tmXBMinorValues = ispan(first,last+1,1)
  wave@cnLevelSelectionMode = "ManualLevels"       ; set manual contour levels
  wave@cnMinLevelValF       = 0.0                  ; set min contour level
  wave@cnMaxLevelValF       = 70                 ; set max contour level
  wave@cnLevelSpacingF      = 5.0                  ; set contour spacing
  wave@vpXF            = 0.1         
  wave@vpYF            = 0.71
  wave@vpHeightF       = .25                    ;
  wave@vpWidthF        = .7
  wave@tiXAxisFontHeightF = 0.018
  wave@tiYAxisFontHeightF = 0.018
  wave@txFontHeightF = 0.018
  wave@tmYLOn = True
  wave@tmYLMode = "Explicit"
  wave@tmYLValues = (/1,2,3,4,5,8,10/)
  wave@tmYLLabels = (/"1","2","3","4","5","8","10"/)

;+ cone of influence
  wavecoi = True
  wavecoi@gsFillColor = "black"
  wavecoi@gsFillIndex = 17

  wavesig = True                            ; wavesig probability plots
  wavesig@trYReverse          = True
  wavesig@tmYLMode = "Explicit"
  wavesig@tmYLValues = (/1,2,4,8,16,32,64,128/)
  wavesig@tmYLLabels = (/"1","2","4","8","16","32","64","128"/)
  wavesig@gsnDraw             = False       ; Do not draw plot
  wavesig@gsnFrame            = False       ; Do not advance frome
  wavesig@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  wavesig@cnMinLevelValF      = 0.00        ; set min contour level
  wavesig@cnMaxLevelValF      = 2.00        ; set max contour level
  wavesig@cnLevelSpacingF     = 1.00        ; set contour spacing
  wavesig@cnInfoLabelOn       = False
  wavesig@cnLinesOn           = False       ; do not draw contour lines
  wavesig@cnLineLabelsOn      = False       ; do not draw contour labels
  wavesig@cnFillScaleF        = 0.5         ; add extra density
  wavesig@gsnLeftString = ""
  wavesig@gsnRightString = ""

  wavegws = True
  wavegws@gsnFrame = False
  wavegws@tmYLLabelFontHeightF = 0.015
  wavegws@tmXBLabelFontHeightF = 0.015
  wavegws@tiXAxisString = "K~S~2~N~"
  wavegws@tiYAxisString = ""
  wavegws@tiXAxisFontHeightF = 0.018
  wavegws@tiYAxisFontHeightF = 0.018
  wavegws@gsnLeftString = ""
  wavegws@gsnRightString = ""
  wavegws@gsnCenterString = "GWS" 
  wavegws@txFontHeightF = 0.014
  wavegws@xyLineThicknesses = (/2.,2.,1.,1./) 
  wavegws@xyDashPatterns = (/0,0,1,1/)
  wavegws@xyLineColors = (/"black","red","red","red"/)
  wavegws@trYReverse          = True 
  wavegws@trYAxisType = "LogAxis"
  wavegws@tmYLOn = True
  wavegws@tmYLMode = "Explicit"
  wavegws@tmYLValues = (/1,2,3,4,5,8,10/)
  wavegws@tmYLLabels = (/"","","","","","",""/)
  wavegws@tmXBOn = True
  wavegws@tmXBMode = "Explicit"
  wavegws@tmXBValues = (/0,5,10,15,20,25,30/)
  wavegws@tmXBLabels = (/"","","10","","20","","30"/)
  wavegws@trXMinF = 0.
  wavegws@trXMaxF = 30.
  wavegws@tmXTOn              = False
  wavegws@tmYROn              = False
  wavegws@trYMinF = 0.516
  wavegws@trYMaxF = 10.4
  wavegws@vpXF            = 0.81       
  wavegws@vpYF            = 0.71
  wavegws@vpHeightF       = .25 
  wavegws@vpWidthF        = .12


;Wavelets 
  plot2 = gsn_csm_contour(wks,power3({11:0.5},:),wave)  
  plot2 = ShadeCOI(wks,plot2,wave3,time&time,wavecoi)
  plot2a=gsn_csm_xy(wks,gws3,gws3&period,wavegws)

;+ Specific year lines
  plres                   = True 
  plres@gsLineColor       = "Black" 
  plres@gsLineDashPattern = 2
  dum1 = gsn_add_polyline(wks, plot2, year_arr, (/2,2/), plres)
  dum2 = gsn_add_polyline(wks, plot2, year_arr, (/3,3/), plres)
  dum3 = gsn_add_polyline(wks, plot2, year_arr, (/4,4/), plres)
  dum4 = gsn_add_polyline(wks, plot2, year_arr, (/5,5/), plres)

  draw(plot2)

  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.018                     ; font smaller. default big
  gsn_text_ndc(wks,"Averaged over years "+year0str+" to "+year1str+":",0.36,0.3,txres) 

;------------------------------------------------------
;-----------------------------------------------------
;3; Spectral Plot
  spec = True 
  spec@gsnFrame = False
  spec@tmYLLabelFontHeightF = 0.015
  spec@tmXBLabelFontHeightF = 0.015
  spec@tiYAxisString = "Variance (K~S~2~N~/unit freq.)"
  spec@tiXAxisString = "Period (years)"
  spec@tiXAxisFontHeightF = 0.018
  spec@tiYAxisFontHeightF = 0.018
  spec@gsnLeftString = ""
  spec@gsnRightString = ""
  spec@gsnCenterString = "Power Spectrum" 
  spec@txFontHeightF = 0.014
  spec@xyLineThicknesses = (/2.,2.,1.,1./) 
  spec@xyDashPatterns = (/0,0,1,1/)
  spec@xyLineColors = (/"black","red","red","red"/)
  spec@tmXTOn              = False
  spec@tmYROn              = False
  spec@tmXBOn              = True
  spec@tmXBMode            = "Explicit"
  spec@tmXBValues = (/0,1,2,3,4,5,6,7,8,9,10/)
  spec@tmXBLabels = (/"0","1","2","3","4","5","6","7","8","9","10"/)
  spec@trXMinF = 0.083333
  spec@trXMaxF = 8
  spec@trYMaxF = 60.
  spec@vpXF            = 0.1         
  spec@vpYF            = 0.25
  spec@vpHeightF       = .2                    ;
  spec@vpWidthF        = .2

  opt = 1  ; 1 == remove mean & linear trend
  jave = 7 ; number of periodograms to average
  pct = 0.10  ; percent taper
  dof = specx_anal (nino3(specavg0:specavg1),opt,jave,pct)
  spectrum = specx_ci(dof,0.05,0.95)
  plot3=gsn_csm_xy(wks,1./(dof@frq*12.),spectrum,spec)
  delete(dof)
  delete(spectrum)

;4. Autocorrelation plot.
  autoc          = True
  autoc@gsnFrame = False
  autoc@tmYLLabelFontHeightF = 0.015
  autoc@tmXBLabelFontHeightF = 0.015
  autoc@tiXAxisString = "Lag (months)"
  autoc@tiXAxisFontHeightF = 0.018
  autoc@tiYAxisFontHeightF = 0.018
  autoc@txFontHeightF = 0.014
  autoc@gsnLeftString = ""
  autoc@gsnRightString = ""
  autoc@gsnCenterString = "Autocorrelation"
  autoc@gsnYRefLine = 0.0
  autoc@gsnAboveYRefLineColor = "red"
  autoc@gsnBelowYRefLineColor = "blue"
  autoc@trYMinF = -1. 
  autoc@trYMaxF = 1.
  autoc@tmYROn              = False
  autoc@tmXTOn              = False
  autoc@tmYLOn = True
  autoc@tmYLMode = "Explicit"
  autoc@tmYLValues = (/-1,0,1/)
  autoc@tmYLLabels = (/"-1","0","1"/)
  autoc@tmXBOn = True
  autoc@tmXBMode = "Explicit"
  autoc@tmXBValues = (/0,12,24,36,48/)
  autoc@tmXBLabels = (/"0","12","24","36","48"/)
  autoc@vpXF            = 0.35         
  autoc@vpYF            = 0.25
  autoc@vpHeightF       = .2                    ;
  autoc@vpWidthF        = .2

  mlag = ispan(0,nmonths,1)
  plot4 = gsn_csm_xy(wks,mlag,acorr3,autoc)

;5. Monthly averaged variances.
  mvar    = True
  mvar@gsnFrame              = False                ; don't advance frame yet
  mvar@tmYLLabelFontHeightF = 0.015
  mvar@tmXBLabelFontHeightF = 0.015
  mvar@tiXAxisString = "Month"
  mvar@tiXAxisFontHeightF = 0.018
  mvar@tiYAxisFontHeightF = 0.018
  mvar@txFontHeightF = 0.014
  mvar@gsnLeftString = ""
  mvar@gsnRightString = ""
  mvar@gsnCenterString = "Variance (K~S~2~N~)"
  mvar@trYMinF = 0
  mvar@trYMaxF = 3
  mvar@tmYROn              = False
  mvar@tmXTOn              = False
  mvar@tmXBOn = True
  mvar@tmXBMode = "Explicit"
  mvar@tmXBValues = (/0,1,2,3,4,5,6,7,8,9,10,11/)
  mvar@tmXBLabels = (/"J","F","M","A","M","J","J","A","S","O","N","D"/)
  mvar@vpXF            = 0.625         
  mvar@vpYF            = 0.25
  mvar@vpHeightF       = .2                    ;
  mvar@vpWidthF        = .275
  mvar@gsnXYBarChart         = True                 ; turn on bar chart
  mvar@gsnXYBarChartBarWidth = 0.75                 ; change bar widths
  mvar@gsnXYBarChartColors   = "Black"            ; choose colors
  mvar@tmXBOn                = True                ; turn off tickmarks at bot
  mvar@trYMinF               = 0                    ; bring bars down to zero
  mvar@trXMinF               = -1                    ; adds space on either end
  mvar@trXMaxF               = 12                    ; of the 1st and last bars

  ymons = ispan(0,11,1)
  plot5 = gsn_csm_xy (wks,ymons,var_mon3,mvar)                  ; create plot


  frame(wks)             ; advance frame to 'finish' plot


  delete(plot1)
  delete(plot2)
  delete(plot3)
  delete(plot4)
  delete(plot5)

;##########################################
;###########  NINO 3.4 ####################
;##########################################
  print("plotting ENSO nino3.4 analysis")
  wks = gsn_open_wks(img_format,"ENSO.nino3.4.analysis")
  gsn_define_colormap(wks,"wh-bl-gr-ye-re")

;1. Timeseries
  res@gsnCenterString = casename+" nino3.4 Monthly SST Anomalies + Wavelet Power (K~S~2~N~)"
  plot1 = gsn_csm_xy(wks,time,nino34,res)

;2. Wavelets
  plot2 = gsn_csm_contour(wks,power34({11:0.5},:),wave)  
  plot2 = ShadeCOI(wks,plot2,wave34,time&time,wavecoi)
  plot2a=gsn_csm_xy(wks,gws34,gws34&period,wavegws)
  dum1 = gsn_add_polyline(wks, plot2, year_arr, (/2,2/), plres)
  dum2 = gsn_add_polyline(wks, plot2, year_arr, (/3,3/), plres)
  dum3 = gsn_add_polyline(wks, plot2, year_arr, (/4,4/), plres)
  dum4 = gsn_add_polyline(wks, plot2, year_arr, (/5,5/), plres)
  draw(plot2)

  txres               = True                     ; text mods desired
  txres@txFontHeightF = 0.02                     ; font smaller. default big
  gsn_text_ndc(wks,"Averaged over years "+year0str+" to "+year1str+":",0.5,0.30,txres) 

;3. Power spectra
  dof = specx_anal (nino34(specavg0:specavg1),opt,jave,pct)
  spectrum = specx_ci(dof,0.05,0.95)
  plot3=gsn_csm_xy(wks,1./(dof@frq*12.),spectrum,spec)
  delete(dof)
  delete(spectrum)

;4. Autocorrelation
  plot4 = gsn_csm_xy(wks,mlag,acorr34,autoc)

;5. Monthly averaged variances.
  plot5 = gsn_csm_xy (wks,ymons,var_mon34,mvar)                  ; create plot

  frame(wks)

end
