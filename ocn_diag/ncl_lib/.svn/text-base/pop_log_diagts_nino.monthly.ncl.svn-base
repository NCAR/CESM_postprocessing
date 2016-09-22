load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  daysperm = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31./)
  midmonth = (/15.5,45.,74.5,105.,135.5,166.,196.5,227.5,258.,288.5,319.,349.5/)

  Lv = 2.501e6	; latent heat of vaporisation (J/kg)
  Lf = 3.337e5	; latenet heat of fusion (J/kg)
  nsmooth = 5
  line="x"
  a = "string"

;; grab data from 2: in order to skip the first line (which is 0)
  data = asciiread("diagts_nino.asc",-1,"string")
  year = tofloat(str_get_field(data(2:),4," "))
  mon = tointeger(str_get_field(data(2:),2," "))
  montime =  year + (midmonth(mon-1)/365.)
  nino12 = tofloat(str_get_field(data(2:),5," "))
  nino3 = tofloat(str_get_field(data(2:),6," "))
  nino34 = tofloat(str_get_field(data(2:),7," "))
  nino4 = tofloat(str_get_field(data(2:),8," "))

  ny = dimsizes(year)
  nyear = ny /12

  nino12ann = new(nyear,float)
  nino3ann = new(nyear,float)
  nino34ann = new(nyear,float)
  nino4ann = new(nyear,float)
  yeartime = new(nyear,float)

  do iy = 0, nyear - 1
    m0 = iy * 12
    m1 = m0 + 11
    nino12ann(iy) = avg(nino12(m0:m1)) 
    nino3ann(iy) = avg(nino3(m0:m1)) 
    nino34ann(iy) = avg(nino34(m0:m1)) 
    nino4ann(iy) = avg(nino4(m0:m1)) 
    yeartime(iy) = avg(montime(m0:m1)) 
  end do

  nino12anom = nino12 - avg(nino12)
  nino3anom = nino3 - avg(nino3)
  nino34anom = nino34 - avg(nino34)
  nino4anom = nino4 - avg(nino4)

  nino12anom = runave(nino12anom,nsmooth,0)
  nino3anom = runave(nino3anom,nsmooth,0)
  nino4anom = runave(nino4anom,nsmooth,0)
  nino34anom = runave(nino34anom,nsmooth,0)

  nino12sd = sqrt(variance(nino12anom))
  nino3sd = sqrt(variance(nino3anom))
  nino34sd = sqrt(variance(nino34anom))
  nino4sd = sqrt(variance(nino4anom))

;;; CFC11

  print("plotting time series NINO")
  fname = "diagts_NINO"
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
  res@vpHeightF = .2
  res@vpWidthF = .6
  res@xyMonoDashPattern = True
  res@xyDashPattern = 0
  res@xyMonoLineColor = True
  res@xyLineColor = "black"
  res@gsnYRefLine = 0.0
  res@gsnPaperOrientation = "portrait"
  res@gsnDraw = False
  res@gsnFrame = False

  ytitle = "NINO1+2 (degC)"
  res@tiYAxisString = ytitle
  title = "Std dev = " + sprintf("%5.3f",nino12sd) + " (Obs = 1.033)"
  res@tiMainString = title
  plot1 = gsn_csm_xy(wks,montime,nino12anom,res)

  ytitle = "NINO3.4 (degC)"
  res@tiYAxisString = ytitle
  title = "Std dev = " + sprintf("%5.3f",nino34sd) + " (Obs = 0.824)"
  res@tiMainString = title

  plot2 = gsn_csm_xy(wks,montime,nino34anom,res)

  ytitle = "NINO3 (degC)"
  res@tiYAxisString = ytitle
  title = "Std dev = " + sprintf("%5.3f",nino3sd) + " (Obs = 0.852)"
  res@tiMainString = title

  plot3 = gsn_csm_xy(wks,montime,nino3anom,res)

  ytitle = "NINO4 (degC)"
  res@tiYAxisString = ytitle
  title = "Std dev = " + sprintf("%5.3f",nino4sd) + " (Obs = 0.615)"
  res@tiMainString = title

  plot4 = gsn_csm_xy(wks,montime,nino4anom,res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  gsn_panel(wks,(/plot1,plot2,plot3,plot4/), (/4,1/),panel_res)


end
