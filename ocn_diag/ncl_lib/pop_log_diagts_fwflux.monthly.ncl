load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  daysperm = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31./)
  midmonth = (/15.5,45.,74.5,105.,135.5,166.,196.5,227.5,258.,288.5,319.,349.5/)

  Lv = 2.501e6	; latent heat of vaporisation (J/kg)
  Lf = 3.337e5	; latenet heat of fusion (J/kg)

  fwf_factor = 2628000. ; converts kg/sm^2 to mm/month

  line="x"
  a = "string"

;; grab data from 2: in order to skip the first line (which is 0)
  data = asciiread("diagts_fwflux.asc",-1,"string")
  year = tofloat(str_get_field(data(2:),4," "))
  mon = tointeger(str_get_field(data(2:),2," "))
  montime =  year + (midmonth(mon-1)/365.)
  sfwf = tofloat(str_get_field(data(2:),5," ")) * fwf_factor
  evap_f = tofloat(str_get_field(data(2:),6," ")) * fwf_factor
  prec_f = tofloat(str_get_field(data(2:),7," ")) * fwf_factor
  snow_f = tofloat(str_get_field(data(2:),8," ")) * fwf_factor
  melt_f = tofloat(str_get_field(data(2:),9," ")) * fwf_factor
  roff_f = tofloat(str_get_field(data(2:),10," ")) * fwf_factor
  salt_f = tofloat(str_get_field(data(2:),11," ")) * fwf_factor
  qflux = -(tofloat(str_get_field(data(2:),12," ")) / Lf) * fwf_factor
  sfwfnet = sfwf + qflux

  ny = dimsizes(year)
  nyear = ny /12

  sfwfann = new(nyear,float)
  evapann = new(nyear,float)
  precann = new(nyear,float)
  snowann = new(nyear,float)
  meltann = new(nyear,float)
  roffann = new(nyear,float)
  saltann = new(nyear,float)
  qfluxann = new(nyear,float)
  sfwfnetann = new(nyear,float)
  yeartime = new(nyear,float)

  do iy = 0, nyear - 1
    m0 = iy * 12
    m1 = m0 + 11
    sfwfann(iy) = avg(sfwf(m0:m1)) 
    evapann(iy) = avg(evap_f(m0:m1)) 
    precann(iy) = avg(prec_f(m0:m1)) 
    snowann(iy) = avg(snow_f(m0:m1)) 
    meltann(iy) = avg(melt_f(m0:m1)) 
    roffann(iy) = avg(roff_f(m0:m1)) 
    saltann(iy) = avg(salt_f(m0:m1)) 
    qfluxann(iy) = avg(qflux(m0:m1)) 
    sfwfnetann(iy) = avg(sfwfnet(m0:m1)) 
    yeartime(iy) = avg(montime(m0:m1)) 
  end do

;;; Net SFWF

  print("plotting time series total SFWF")
  fname = "diagts_SFWF_TOTAL"
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
  ytitle = "Net SFWF (mm/month)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title
  res@xyLineColor = "black"

  plot1 = gsn_csm_xy(wks,montime,sfwfnet,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,sfwfnetann,res)
  overlay(plot1,plotadd)
  plot2 = gsn_csm_xy(wks,yeartime,sfwfnetann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; EVAP_F
  print("plotting time series EVAP_F")
  fname = "diagts_EVAP_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "EVAP_F (mm/month)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,evap_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,evapann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,evapann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; PREC_F
  print("plotting time series PREC_F")
  fname = "diagts_PREC_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "PREC_F (mm/month)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,prec_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,precann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,precann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)


;;;; SNOW_F
  print("plotting time series SNOW_F")
  fname = "diagts_SNOW_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "SNOW_F (mm/month)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,snow_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,snowann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,snowann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; MELT_F
  print("plotting time series MELT_F")
  fname = "diagts_MELT_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "MELT_F (mm/month)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,melt_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,meltann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,meltann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; ROFF_F
  print("plotting time series ROFF_F")
  fname = "diagts_ROFF_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "ROFF_F (mm/month)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,roff_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,roffann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,roffann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; SALT_F
  print("plotting time series SALT_F")
  fname = "diagts_SALT_F"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "SALT_F (mm/month)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,salt_f,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,saltann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,saltann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; SFWF_QFLUX
  print("plotting time series SFWF QFLUX")
  fname = "diagts_SFWF_QFLUX"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "SFWF_QFLUX (mm/month)"
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
