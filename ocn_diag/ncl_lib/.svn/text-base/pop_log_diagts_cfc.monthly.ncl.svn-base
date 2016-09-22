load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  daysperm = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31./)
  midmonth = (/15.5,45.,74.5,105.,135.5,166.,196.5,227.5,258.,288.5,319.,349.5/)

  Lv = 2.501e6	; latent heat of vaporisation (J/kg)
  Lf = 3.337e5	; latenet heat of fusion (J/kg)

  line="x"
  a = "string"

;; grab data from 2: in order to skip the first line (which is 0)
  data = asciiread("diagts_cfc.asc",-1,"string")
  year = tofloat(str_get_field(data(2:),4," "))
  mon = tointeger(str_get_field(data(2:),2," "))
  montime =  year + (midmonth(mon-1)/365.)
  cfc11 = tofloat(str_get_field(data(2:),5," "))
  cfc11_f = tofloat(str_get_field(data(2:),6," "))
  cfc12 = tofloat(str_get_field(data(2:),7," "))
  cfc12_f = tofloat(str_get_field(data(2:),8," "))

  ny = dimsizes(year)
  nyear = ny /12

  cfc11ann = new(nyear,float)
  cfc11_fann = new(nyear,float)
  cfc12ann = new(nyear,float)
  cfc12_fann = new(nyear,float)
  yeartime = new(nyear,float)

  do iy = 0, nyear - 1
    m0 = iy * 12
    m1 = m0 + 11
    cfc11ann(iy) = avg(cfc11(m0:m1)) 
    cfc11_fann(iy) = avg(cfc11_f(m0:m1)) 
    cfc12ann(iy) = avg(cfc12(m0:m1)) 
    cfc12_fann(iy) = avg(cfc12_f(m0:m1)) 
    yeartime(iy) = avg(montime(m0:m1)) 
  end do

;;; CFC11

  print("plotting time series CFC11")
  fname = "diagts_CFC11"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  res = True
  res@tiMainFontHeightF = 0.018
  res@tiMainOffsetYF = -0.015
  res@tiYAxisFontHeightF = 0.018
  res@tiXAxisFontHeightF = 0.018
  res@tmEqualizeXYSizes = True
  res@tmXBLabelFontHeightF = 0.015
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
  ytitle = "CFC11 (fmol cm~S~-3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainString = title
  res@xyLineColor = "black"

  plot1 = gsn_csm_xy(wks,montime,cfc11,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,cfc11ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,cfc11ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;; CFC12

  print("plotting time series CFC12")
  fname = "diagts_CFC12"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  res = True

  ytitle = "CFC12 (fmol cm~S~-3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title
  res@xyLineColor = "black"

  plot1 = gsn_csm_xy(wks,montime,cfc12,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,cfc12ann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,cfc12ann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;; STF_CFC11

  print("plotting time series STF CFC11")
  fname = "diagts_STF_CFC11"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  res = True

  ytitle = "STF_CFC11 (fmol cm~S~-2~N~ s~S~-1~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title
  res@xyLineColor = "black"

  plot1 = gsn_csm_xy(wks,montime,cfc11_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,cfc11_fann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,cfc11_fann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;; STF_CFC12

  print("plotting time series STF CFC12")
  fname = "diagts_STF_CFC12"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  res = True

  ytitle = "STF_CFC12 (fmol cm~S~-2~N~ s~S~-1~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title
  res@xyLineColor = "black"

  plot1 = gsn_csm_xy(wks,montime,cfc12_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,cfc12_fann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,cfc12_fann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)


end
