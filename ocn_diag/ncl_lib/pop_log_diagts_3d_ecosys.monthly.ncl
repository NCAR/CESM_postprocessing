load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  daysperm = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31./)
  daysm = (/30.42,30.42,30.42,30.42,30.42,30.42,30.42,30.42,30.42,30.42,30.42,30.42/)
  dayspermw = daysperm/daysm
; dayspermw = daysperm/stat4(daysperm)(0)
  midmonth = (/15.5,45.,74.5,105.,135.5,166.,196.5,227.5,258.,288.5,319.,349.5/)

  Lv = 2.501e6	; latent heat of vaporisation (J/kg)
  Lf = 3.337e5	; latent heat of fusion (J/kg)

  line = "x"
  a = "string"

  data    = asciiread("diagts_ecosys.asc",-1,"string")
  year    = tofloat(str_get_field(data(1:),4," "))
  mon     = tointeger(str_get_field(data(1:),2," "))
  montime = year + (midmonth(mon-1)/365.)

  diatchl     = tofloat(str_get_field(data(1:),5," "))
  spchl       = tofloat(str_get_field(data(1:),6," "))
  diazchl     = tofloat(str_get_field(data(1:),7," "))
  fe          = tofloat(str_get_field(data(1:),8," "))
  no3         = tofloat(str_get_field(data(1:),9," "))
  nox_flux    = tofloat(str_get_field(data(1:),10," "))
  nh4         = tofloat(str_get_field(data(1:),11," "))
  nhy_flux    = tofloat(str_get_field(data(1:),12," "))
  po4         = tofloat(str_get_field(data(1:),13," "))
  sio3        = tofloat(str_get_field(data(1:),14," "))
  o2          = tofloat(str_get_field(data(1:),15," "))
  aou         = tofloat(str_get_field(data(1:),16," "))
  o2_zmin     = tofloat(str_get_field(data(1:),17," "))
  o2_zmin_depth = tofloat(str_get_field(data(1:),18," "))
  dic_alt_co2 = tofloat(str_get_field(data(1:),19," "))
  dic         = tofloat(str_get_field(data(1:),20," "))
  alk         = tofloat(str_get_field(data(1:),21," "))
  co3         = tofloat(str_get_field(data(1:),22," "))
  zsatcalc    = tofloat(str_get_field(data(1:),23," "))
  zsatarag    = tofloat(str_get_field(data(1:),24," "))
  doc         = tofloat(str_get_field(data(1:),25," "))
  photoC_sp   = tofloat(str_get_field(data(1:),26," "))
  photoC_diat = tofloat(str_get_field(data(1:),27," "))
  photoC_diaz = tofloat(str_get_field(data(1:),28," "))
  denitrif    = tofloat(str_get_field(data(1:),29," "))
  diaz_Nfix   = tofloat(str_get_field(data(1:),30," "))
  fg_alt_co2  = tofloat(str_get_field(data(1:),31," "))
  fg_co2      = tofloat(str_get_field(data(1:),32," "))
  dpco2       = tofloat(str_get_field(data(1:),33," "))
  atm_co2     = tofloat(str_get_field(data(1:),34," "))

; for integral conversions, use gx1v6 volume and surface area as default

 volume = 0.0E+24

  if ( getenv("RESOLUTION") .eq. "gx1v6" ) then
    volume    = 1.32514E+24
    surf_area = 3.61140E+18
  end if

  if ( getenv("RESOLUTION") .eq. "gx3v7" ) then
    volume    = 1.32028E+24
    surf_area = 3.60464E+18
  end if

  if (volume .eq. 0) then
    print(getenv("RESOLUTION")+" not supported by pop_log_diagts_3d_ecosys.monthly.ncl")
    exit
  end if

; convert photoC terms from nmol/cm^3/s to PgC/y
photoC_sp   = photoC_sp   * (volume * 1.0E-9 * 12.0 * 1.0E-15 * 86400.0 * 365.0)
photoC_diat = photoC_diat * (volume * 1.0E-9 * 12.0 * 1.0E-15 * 86400.0 * 365.0)
photoC_diaz = photoC_diaz * (volume * 1.0E-9 * 12.0 * 1.0E-15 * 86400.0 * 365.0)

; convert NO NH surface fluxes from nmol/cm^2/s to TgN/y
nhy_flux  = nhy_flux  * (surf_area * 1.0E-9 * 14.0 * 1.0E-12 * 86400.0 * 365.0)
nox_flux  = nox_flux  * (surf_area * 1.0E-9 * 14.0 * 1.0E-12 * 86400.0 * 365.0)

; convert denitrif, nfix terms from nmol/cm^3/s to TgN/y
denitrif  = denitrif  * (volume * 1.0E-9 * 14.0 * 1.0E-12 * 86400.0 * 365.0)
diaz_Nfix = diaz_Nfix * (volume * 1.0E-9 * 14.0 * 1.0E-12 * 86400.0 * 365.0)

; convert fg_co2 terms from nmol/cm^2/s to PgC/y
fg_alt_co2 = fg_alt_co2 * (surf_area * 1.0E-9 * 12.0 * 1.0E-15 * 86400.0 * 365.0)
fg_co2 = fg_co2 * (surf_area * 1.0E-9 * 12.0 * 1.0E-15 * 86400.0 * 365.0)

; convert o2_zmin_depth, zsatcalc, zsatarag from cm to m
o2_zmin_depth = o2_zmin_depth * 0.01
zsatcalc = zsatcalc * 0.01
zsatarag = zsatarag * 0.01

; derived quantities
totchl = diatchl + spchl + diazchl
photoC_tot = photoC_diat + photoC_sp + photoC_diaz


  ny = dimsizes(year)
  nyear = ny /12

  totchlann      = new(nyear,float)
  diatchlann     = new(nyear,float)
  spchlann       = new(nyear,float)
  diazchlann     = new(nyear,float)
  feann          = new(nyear,float)
  no3ann         = new(nyear,float)
  nox_fluxann    = new(nyear,float)
  nh4ann         = new(nyear,float)
  nhy_fluxann    = new(nyear,float)
  po4ann         = new(nyear,float)
  sio3ann        = new(nyear,float)
  o2ann          = new(nyear,float)
  aouann         = new(nyear,float)
  o2_zminann     = new(nyear,float)
  o2_zmin_depthann = new(nyear,float)
  dic_alt_co2ann = new(nyear,float)
  dicann         = new(nyear,float)
  alkann         = new(nyear,float)
  co3ann         = new(nyear,float)
  zsatcalcann    = new(nyear,float)
  zsataragann    = new(nyear,float)
  docann         = new(nyear,float)
  photoC_totann  = new(nyear,float)
  photoC_spann   = new(nyear,float)
  photoC_diatann = new(nyear,float)
  photoC_diazann = new(nyear,float)
  denitrifann    = new(nyear,float)
  diaz_Nfixann   = new(nyear,float)
  fg_alt_co2ann  = new(nyear,float)
  fg_co2ann      = new(nyear,float)
  dpco2ann       = new(nyear,float)
  atm_co2ann     = new(nyear,float)

  yeartime       = new(nyear,float)

  do iy = 0, nyear - 1

    m0 = iy * 12
    m1 = m0 + 11
    totchlann(iy)      = avg(totchl(m0:m1)) 
    diatchlann(iy)     = avg(diatchl(m0:m1)) 
    spchlann(iy)       = avg(spchl(m0:m1)) 
    diazchlann(iy)     = avg(diazchl(m0:m1)) 
    feann(iy)          = avg(fe(m0:m1)) 
    no3ann(iy)         = avg(no3(m0:m1)) 
    nox_fluxann(iy)    = avg(nox_flux(m0:m1)) 
    nh4ann(iy)         = avg(nh4(m0:m1)) 
    nhy_fluxann(iy)    = avg(nhy_flux(m0:m1)) 
    po4ann(iy)         = avg(po4(m0:m1)) 
    sio3ann(iy)        = avg(sio3(m0:m1)) 
    o2ann(iy)          = avg(o2(m0:m1)) 
    aouann(iy)         = avg(aou(m0:m1)) 
    o2_zminann(iy)     = avg(o2_zmin(m0:m1)) 
    o2_zmin_depthann(iy) = avg(o2_zmin_depth(m0:m1)) 
    dic_alt_co2ann(iy) = avg(dic_alt_co2(m0:m1)) 
    dicann(iy)         = avg(dic(m0:m1)) 
    alkann(iy)         = avg(alk(m0:m1)) 
    co3ann(iy)         = avg(co3(m0:m1)) 
    zsatcalcann(iy)    = avg(zsatcalc(m0:m1)) 
    zsataragann(iy)    = avg(zsatarag(m0:m1)) 
    docann(iy)         = avg(doc(m0:m1)) 
    photoC_totann(iy)  = avg(photoC_tot(m0:m1)*dayspermw)
    photoC_spann(iy)   = avg(photoC_sp(m0:m1)*dayspermw)
    photoC_diatann(iy) = avg(photoC_diat(m0:m1)*dayspermw)
    photoC_diazann(iy) = avg(photoC_diaz(m0:m1)*dayspermw)
    denitrifann(iy)    = avg(denitrif(m0:m1)*dayspermw)
    diaz_Nfixann(iy)   = avg(diaz_Nfix(m0:m1)*dayspermw)
    fg_alt_co2ann(iy)  = avg(fg_alt_co2(m0:m1)*dayspermw)
    fg_co2ann(iy)      = avg(fg_co2(m0:m1)*dayspermw)
    dpco2ann(iy)       = avg(dpco2(m0:m1)*dayspermw)
    atm_co2ann(iy)     = avg(atm_co2(m0:m1)*dayspermw)

    yeartime(iy)       = avg(montime(m0:m1)) 

  end do

; low-pass filter on annual mean with frequency of num2sm
  num2sm = 15
  if (nyear .gt. num2sm ) then
    fg_alt_co2ann_lp = new(nyear-num2sm+1,float)
    fg_co2ann_lp = new(nyear-num2sm+1,float)
    yeartime_lp  = new(nyear-num2sm+1,float)
      do iy = 0, nyear - num2sm 
        iy0 = iy 
        iy1 = iy0 + num2sm - 1
        fg_alt_co2ann_lp(iy) = avg(fg_alt_co2ann(iy0:iy1)) 
        fg_co2ann_lp(iy) = avg(fg_co2ann(iy0:iy1)) 
        yeartime_lp(iy) = avg(yeartime(iy0:iy1)) 
      end do
  end if

;;; totChl

  print("plotting time series totChl")
  fname = "diagts_totChl"
  ;wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  units = "mg/m~S~3~N~"
  res = True
  res@tiMainFontHeightF = 0.018
  res@tiMainOffsetYF = -0.015
  res@tiYAxisFontHeightF = 0.018
  res@tiXAxisFontHeightF = 0.018
  res@tmEqualizeXYSizes = True
  res@tmXBLabelFontHeightF = 0.015
  if (isvar("units")) then
    res@tiYAxisString = units
  end if
  res@vpHeightF = .375
  res@vpWidthF = .6
  res@xyMonoDashPattern = True
  res@xyDashPattern = 0
  res@xyMonoLineColor = True
  res@xyLineColor = "black"
  res@gsnYRefLine = 0.0
  res@gsnPaperOrientation = "portrait"
  res@gsnDraw = False
  res@gsnFrame = False

  xtitle = "Model Year"
  res@tiXAxisString = xtitle
  ytitle = "totChl (mg/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title
  res@xyLineColor = "black"

  plot1 = gsn_csm_xy(wks,montime,totchl,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,totchlann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,totchlann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; diatChl

  print("plotting time series diatChl")
  fname = "diagts_diatChl"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "diatChl (mg/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,diatchl,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,diatchlann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,diatchlann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; spChl

  print("plotting time series spChl")
  fname = "diagts_spChl"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "spChl (mg/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,spchl,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,spchlann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,spchlann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; diazChl

  print("plotting time series diazChl")
  fname = "diagts_diazChl"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "diazChl (mg/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,diazchl,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,diazchlann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,diazchlann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; NO3

  print("plotting time series NO3")
  fname = "diagts_NO3"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "NO3 (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,no3,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,no3ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,no3ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; NH4

  print("plotting time series NH4")
  fname = "diagts_NH4"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "NH4 (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,nh4,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,nh4ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,nh4ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; PO4

  print("plotting time series PO4")
  fname = "diagts_PO4"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "PO4 (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,po4,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,po4ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,po4ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; SiO3

  print("plotting time series SiO3")
  fname = "diagts_SiO3"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "SiO3 (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,sio3,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,sio3ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,sio3ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; Fe

  print("plotting time series Fe")
  fname = "diagts_Fe"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "Fe (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,fe,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,feann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,feann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; O2

  print("plotting time series O2")
  fname = "diagts_O2"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "O2 (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,o2,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,o2ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,o2ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; AOU

  print("plotting time series AOU")
  fname = "diagts_AOU"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "AOU (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,aou,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,aouann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,aouann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; O2_ZMIN

  print("plotting time series O2_ZMIN")
  fname = "diagts_O2_ZMIN"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "O2_ZMIN (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,o2_zmin,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,o2_zminann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,o2_zminann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; O2_ZMIN_DEPTH

  print("plotting time series O2_ZMIN_DEPTH")
  fname = "diagts_O2_ZMIN_DEPTH"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "O2_ZMIN_DEPTH (m)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,o2_zmin_depth,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,o2_zmin_depthann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,o2_zmin_depthann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; DIC

  print("plotting time series DIC")
  fname = "diagts_DIC"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "DIC (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,dic,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,dicann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,dicann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; DIC_ALT_CO2

  print("plotting time series DIC_ALT_CO2")
  fname = "diagts_DIC_ALT_CO2"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "DIC_ALT_CO2 (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,(dic_alt_co2),res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,(dic_alt_co2ann),res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,(dic_alt_co2ann),res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; DIC_ANTH_CO2

  print("plotting time series DIC_ANTH_CO2")
  fname = "diagts_DIC_ANTH_CO2"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "DIC_ANTH_CO2 (PgC)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,(dic-dic_alt_co2)*(volume * 1.0E-9 * 12.0 * 1.0E-15),res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,(dicann-dic_alt_co2ann)*(volume * 1.0E-9 * 12.0 * 1.0E-15),res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,(dicann-dic_alt_co2ann)*(volume * 1.0E-9 * 12.0 * 1.0E-15),res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; ALK

  print("plotting time series ALK")
  fname = "diagts_ALK"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "ALK (meq/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,alk,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,alkann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,alkann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; CO3

if (max(co3) .gt. 0. ) then
  print("plotting time series CO3")
  fname = "diagts_CO3"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "CO3 (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,co3,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,co3ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,co3ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)
end if

;;;; zsatcalc

  print("plotting time series zsatcalc")
  fname = "diagts_zsatcalc"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "zsatcalc (m)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,zsatcalc,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,zsatcalcann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,zsatcalcann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; zsatarag

if (max(zsatarag) .gt. 0. ) then
  print("plotting time series zsatarag")
  fname = "diagts_zsatarag"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "zsatarag (m)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,zsatarag,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,zsataragann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,zsataragann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)
end if

;;;; DOC

  print("plotting time series DOC")
  fname = "diagts_DOC"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "DOC (mmol/m~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,doc,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,docann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,docann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; photoC_tot

  print("plotting time series photoC_tot")
  fname = "diagts_photoC_tot"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "photoC_tot (PgC/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,photoC_tot,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,photoC_totann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,photoC_totann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; photoC_sp

  print("plotting time series photoC_sp")
  fname = "diagts_photoC_sp"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "photoC_sp (PgC/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,photoC_sp,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,photoC_spann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,photoC_spann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; photoC_diat

  print("plotting time series photoC_diat")
  fname = "diagts_photoC_diat"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "photoC_diat (PgC/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,photoC_diat,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,photoC_diatann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,photoC_diatann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; photoC_diaz

  print("plotting time series photoC_diaz")
  fname = "diagts_photoC_diaz"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "photoC_diaz (PgC/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,photoC_diaz,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,photoC_diazann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,photoC_diazann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; DpCO2

  print("plotting time series DpCO2")
  fname = "diagts_dpco2"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "dpco2 (PgC/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,dpco2,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,dpco2ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,dpco2ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; atm_CO2

  print("plotting time series ATM_CO2")
  fname = "diagts_atm_co2"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "atm_co2 (PgC/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,atm_co2,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,atm_co2ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,atm_co2ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; N_FLUX

  print("plotting time series N_FLUX")
  fname = "diagts_N_FLUX"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "NO & NH Surface Flux (TgN/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@trYMinF = 0
; res@trYMaxF = max((/max(nox_flux),max(nhy_flux)/))
  res@trYMaxF = max((/max(nox_flux),max(nhy_flux),max(nox_flux+nhy_flux)/))

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,nox_flux,res)

  res@xyLineColor = "red"
  res@tiMainOn = False
  plot1add1 = gsn_csm_xy(wks,yeartime,nox_fluxann,res)

  overlay(plot1,plot1add1)

  res@xyLineColor = "RoyalBlue"
  res@tiMainOn = False
  plot1add2 = gsn_csm_xy(wks,montime,nhy_flux,res)

  overlay(plot1,plot1add2)

  res@xyLineColor = "magenta"
  res@tiMainOn = False
  plot1add3 = gsn_csm_xy(wks,yeartime,nhy_fluxann,res)

  overlay(plot1,plot1add3)

  res@xyLineColor = "red"
  plot2 = gsn_csm_xy(wks,yeartime,nox_fluxann,res)

  res@xyLineColor = "magenta"
  res@tiMainOn = False
  plot2add1 = gsn_csm_xy(wks,yeartime,nhy_fluxann,res)

  overlay(plot2,plot2add1)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

  delete(res@trYMinF)
  delete(res@trYMaxF)

;;;; nfix_denitrif

  res@trYMinF = min((/min(diaz_Nfix),min(denitrif)/))
  res@trYMaxF = max((/max(diaz_Nfix),max(denitrif)/))

  print("plotting time series nfix_denitrif")
  fname = "diagts_nfix_denitrif"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "N Fixation & Denitrifcation (TgN/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,diaz_Nfix,res)

  res@xyLineColor = "red"
  res@tiMainOn = False
  plot1add1 = gsn_csm_xy(wks,yeartime,diaz_Nfixann,res)

  overlay(plot1,plot1add1)

  res@xyLineColor = "RoyalBlue"
  res@tiMainOn = False
  plot1add2 = gsn_csm_xy(wks,montime,denitrif,res)

  overlay(plot1,plot1add2)

  res@xyLineColor = "magenta"
  res@tiMainOn = False
  plot1add3 = gsn_csm_xy(wks,yeartime,denitrifann,res)

  overlay(plot1,plot1add3)

  res@xyLineColor = "red"
  plot2 = gsn_csm_xy(wks,yeartime,diaz_Nfixann,res)

  res@xyLineColor = "magenta"
  res@tiMainOn = False
  plot2add1 = gsn_csm_xy(wks,yeartime,denitrifann,res)

  overlay(plot2,plot2add1)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

  delete(res@trYMinF)
  delete(res@trYMaxF)

;;;; FG_CO2

  print("plotting time series fg_co2")
  fname = "diagts_fg_co2"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "fg_co2 (PgC/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,fg_co2,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,fg_co2ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,fg_co2ann,res)
  res@xyLineColor = "RoyalBlue"
  if (nyear .gt. num2sm ) then
    plot2add = gsn_csm_xy(wks,yeartime_lp,fg_co2ann_lp,res)
    overlay(plot2,plot2add)
  end if

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; FG_ALT_CO2

  print("plotting time series fg_alt_co2")
  fname = "diagts_fg_alt_co2"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "fg_alt_co2 (PgC/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,fg_alt_co2,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,fg_alt_co2ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,fg_alt_co2ann,res)
  res@xyLineColor = "RoyalBlue"
  if (nyear .gt. num2sm ) then
    plot2add = gsn_csm_xy(wks,yeartime_lp,fg_alt_co2ann_lp,res)
    overlay(plot2,plot2add)
  end if

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; FG_ANTH_CO2

  print("plotting time series fg_anth_co2")
  fname = "diagts_fg_anth_co2"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "fg_anth_co2 (PgC/y)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,fg_co2-fg_alt_co2,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,fg_co2ann-fg_alt_co2ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,fg_co2ann-fg_alt_co2ann,res)
  res@xyLineColor = "RoyalBlue"
  if (nyear .gt. num2sm ) then
    plot2add = gsn_csm_xy(wks,yeartime_lp,fg_co2ann_lp-fg_alt_co2ann_lp,res)
    overlay(plot2,plot2add)
  end if

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

end
