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
  data = asciiread("diagts_hflux.asc",-1,"string")
  year = tofloat(str_get_field(data(2:),4," "))
  mon = tointeger(str_get_field(data(2:),2," "))
  montime =  year + (midmonth(mon-1)/365.)
  shf = tofloat(str_get_field(data(2:),5," "))
  shf_qsw = tofloat(str_get_field(data(2:),6," "))
  senh_f = tofloat(str_get_field(data(2:),7," "))
  lwup_f = tofloat(str_get_field(data(2:),8," "))
  lwdn_f = tofloat(str_get_field(data(2:),9," "))
  lwnet = lwup_f + lwdn_f
  melth_f = tofloat(str_get_field(data(2:),10," "))
  evap_f = tofloat(str_get_field(data(2:),11," "))
  latent = evap_f * Lv
  qflux = tofloat(str_get_field(data(2:),12," "))
  shfnet = shf + qflux

  ny = dimsizes(year)
  nyear = ny /12

  shfann = new(nyear,float)
  shf_qswann = new(nyear,float)
  senh_fann = new(nyear,float)
  lwnetann = new(nyear,float)
  lwup_fann = new(nyear,float)
  lwdn_fann = new(nyear,float)
  melth_fann = new(nyear,float)
  evap_fann = new(nyear,float)
  latentann = new(nyear,float)
  qfluxann = new(nyear,float)
  shfnetann = new(nyear,float)
  yeartime = new(nyear,float)

  do iy = 0, nyear - 1
    m0 = iy * 12
    m1 = m0 + 11
    shfann(iy) = avg(shf(m0:m1)) 
    shf_qswann(iy) = avg(shf_qsw(m0:m1)) 
    senh_fann(iy) = avg(senh_f(m0:m1)) 
    lwnetann(iy) = avg(lwnet(m0:m1)) 
    lwup_fann(iy) = avg(lwup_f(m0:m1)) 
    lwdn_fann(iy) = avg(lwdn_f(m0:m1)) 
    melth_fann(iy) = avg(melth_f(m0:m1)) 
    evap_fann(iy) = avg(evap_f(m0:m1)) 
    latentann(iy) = avg(latent(m0:m1)) 
    qfluxann(iy) = avg(qflux(m0:m1)) 
    shfnetann(iy) = avg(shfnet(m0:m1)) 
    yeartime(iy) = avg(montime(m0:m1)) 
  end do

;;; Net SHF

  print("plotting time series SHF TOTAL")
  fname = "diagts_SHF_TOTAL"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  units = "W/m~S~2~N~"
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
  ytitle = "Net SHF (W/m~S~2~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title
  res@xyLineColor = "black"

  plot1 = gsn_csm_xy(wks,montime,shfnet,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,shfnetann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,shfnetann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; Net SW
  print("plotting time series SW NET")
  fname = "diagts_SWNET"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "Net SW (W/m~S~2~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,shf_qsw,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,shf_qswann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,shf_qswann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; Net LW
  
  print("plotting time series LW NET")
  fname = "diagts_LWNET"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "Net LW (W/m~S~2~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,lwnet,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,lwnetann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,lwnetann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; LWUP_F
  print("plotting time series LWUP_F")
  fname = "diagts_LWUP_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "Upwelling LW (W/m~S~2~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,lwup_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,lwup_fann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,lwup_fann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; LWDN_F
  print("plotting time series LWDN_F")
  fname = "diagts_LWDN_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "Downwelling LW (W/m~S~2~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,lwdn_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,lwdn_fann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,lwdn_fann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; LATENT
  print("plotting time series LATENT")
  fname = "diagts_LATENT"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "Latent (W/m~S~2~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,latent,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,latentann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,latentann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; SENH_F
  print("plotting time series SENH_F")
  fname = "diagts_SENH_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "Sensible (W/m~S~2~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,senh_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,senh_fann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,senh_fann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; MELTH_F
  print("plotting time series MELTH_F")
  fname = "diagts_MELTH_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "MELTH_F (W/m~S~2~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,melth_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,melth_fann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,melth_fann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; QFLUX
  print("plotting time series QFLUX")
  fname = "diagts_QFLUX"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "QFLUX (W/m~S~2~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,qflux,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,qfluxann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,qfluxann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

end
