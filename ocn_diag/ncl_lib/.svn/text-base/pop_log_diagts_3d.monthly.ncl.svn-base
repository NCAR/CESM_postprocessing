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
;;skip the first line because there is no data for the first month
;;read lines 2 to the end to get the data
  data = asciiread("diagts_3d.asc",-1,"string")
  data = asciiread("diagts_3d.asc",-1,"string")
  year = tofloat(str_get_field(data(2:),4," "))
  mon = tointeger(str_get_field(data(2:),2," "))
  montime =  year + (midmonth(mon-1)/365.)
  temp = tofloat(str_get_field(data(2:),5," "))
  salt = tofloat(str_get_field(data(2:),6," "))
  rho = tofloat(str_get_field(data(2:),7," "))
  iage = tofloat(str_get_field(data(2:),8," "))
  hblt = tofloat(str_get_field(data(2:),9," "))/100.0
  hmxl = tofloat(str_get_field(data(2:),10," "))/100.0
  ssh = tofloat(str_get_field(data(2:),11," "))

  ny = dimsizes(year)
  nyear = ny /12

  tempann = new(nyear,float)
  saltann = new(nyear,float)
  rhoann = new(nyear,float)
  hbltann = new(nyear,float)
  hmxlann = new(nyear,float)
  sshann = new(nyear,float)
  iageann = new(nyear,float)
  yeartime = new(nyear,float)

  do iy = 0, nyear - 1
    m0 = iy * 12
    m1 = m0 + 11
    tempann(iy) = avg(temp(m0:m1)) 
    saltann(iy) = avg(salt(m0:m1)) 
    rhoann(iy) = avg(rho(m0:m1)) 
    hbltann(iy) = avg(hblt(m0:m1)) 
    hmxlann(iy) = avg(hmxl(m0:m1)) 
    sshann(iy) = avg(ssh(m0:m1)) 
    iageann(iy) = avg(iage(m0:m1)) 
    yeartime(iy) = avg(montime(m0:m1)) 
  end do

;;; TEMP

  print("plotting time series TEMP")
  fname = "diagts_TEMP"
  ;wks = gsn_open_wks("x11",fname)
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
  ytitle = "TEMP (~S~o~N~C)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title
  res@xyLineColor = "black"

  plot1 = gsn_csm_xy(wks,montime,temp,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,tempann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,tempann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; SALT
  print("plotting time series SALT")
  fname = "diagts_SALT"
;  wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "SALT (msu)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,salt*1000,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,saltann*1000,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,saltann*1000,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

;;;; RHO
  
  print("plotting time series RHO")
  fname = "diagts_RHO"
  ;wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "RHO (g/cm~S~3~N~)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title
  res@xyLineColor = "black"

  ;
  ; kludge to handle the limited range of RHO. It pushes the limit of NCL's float plotting code resolution.
  ; offset the values by by the min value,  but then add it back on to the label strings
  ;
   
  min_rho = min(rho)
  rho = rho - min_rho
  rhoann = rhoann - min_rho
  res@trYMinF = min(rho)
  res@trYMaxF = max(rho)
  plot1 = gsn_csm_xy(wks,montime,rho,res)
  getvalues plot1
   "tmYLValues" : vals
   "tmYLLabels" : labels
   "tmYLMinorValues" : mvals
  end getvalues
  res@tmYLValues = vals
  res@tmYLLabels = tostring(vals + min_rho)
  res@tmYLMinorValues = mvals
  res@tmYLMode = "explicit"

  plot1 = gsn_csm_xy(wks,montime,rho,res)

  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,rhoann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,rhoann,res)
  getvalues plot2
   "tmYLValues" : vals
   "tmYLLabels" : labels
   "tmYLMinorValues" : mvals
   "tmYLMode" : mode
  end getvalues

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)
  delete(res@trYMinF)
  delete(res@trYMaxF)
  delete(res@tmYLMode)
  delete(res@tmYLLabels)
  delete(res@tmYLMinorValues)

;;;; 
  print("plotting time series IAGE")
  fname = "diagts_IAGE"
  ;wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "IAGE (year)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,iage,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,iageann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,iageann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

  print("plotting time series HBLT")
  fname = "diagts_HBLT"
  ;wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "HBLT (m)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,hblt,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,hbltann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,hbltann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

  print("plotting time series HMXL")
  fname = "diagts_HMXL"
  ;wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "HMXL (m)"
  res@tiYAxisString = ytitle
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  res@xyLineColor = "black"
  plot1 = gsn_csm_xy(wks,montime,hmxl,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,hmxlann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,hmxlann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

  print("plotting time series SSH")
  fname = "diagts_SSH"
  ;wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")

  ytitle = "SSH (cm)"
  res@tiYAxisString = ytitle
  res@xyLineColor = "black"
  title = "Global Diagnostics Timeseries "+case_number
  res@tiMainOn = True
  res@tiMainString = title

  plot1 = gsn_csm_xy(wks,montime,ssh,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,yeartime,sshann,res)
  overlay(plot1,plotadd)

  plot2 = gsn_csm_xy(wks,yeartime,sshann,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

end
