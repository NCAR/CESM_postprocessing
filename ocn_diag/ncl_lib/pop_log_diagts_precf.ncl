load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin
  daysperm = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31./)
  midmonth = (/15.5,45.,74.5,105.,135.5,166.,196.5,227.5,258.,288.5,319.,349.5/)

;; grab data from 2: in order to skip the first line (which is 0)
  data = asciiread("diagts_precfactor.asc",-1,"string")
  year = tofloat(str_get_field(data(2:),1," "))
  precf = tofloat(str_get_field(data(2:),2," "))
  precf@_FillValue = default_fillvalue("float")

  if (year(0) .lt. 2.) then 
    precf(0) = precf@_FillValue   ; ignore year 1
  end if

  print("plotting time series PRECF")
  title =  "Annual Precipitation Factor"
  outname = "diagts_precf"
  ;wks = gsn_open_wks("x11",outname)
  wks = gsn_open_wks(img_format,outname)
  gsn_define_colormap(wks,"table42")

  res = True
  res@vpHeightF = .2857   ; height and width are important for proportion mainly -- the exact numbers do not matter
  res@vpWidthF = .6
  res@tiXAxisFontHeightF = 0.018
  res@tiYAxisFontHeightF = 0.018
  res@tiMainFontHeightF = 0.018
  res@tiMainOn = True
  res@tiMainString = title
  res@tiXAxisString = "Model Year"
  res@tmEqualizeXYSizes = True
  res@tmYLLabelFontHeightF = 0.015
  res@xyMonoDashPattern = True
  res@xyDashPattern = 0
  res@xyMonoLineColor = True
  res@xyLineColor = "black"

  res@trXMinF = year0
  res@trXMaxF = year1
  res@trYMinF = 0.5
  res@trYMaxF = 1.5
  res@gsnMaximize = True
  res@gsnPaperOrientation = "portrait"

  plot = gsn_csm_xy(wks,year,precf,res)

end


