load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

  data = asciiread("cplfwbudget.txt",-1,"string")
  yeartry = str_get_field(data,1," ")
  lix = ind(yeartry .eq. "-99") -1
  years = tofloat(tointeger(str_get_field(data(2:lix),1," ")) / 10000) + 0.5
  atmnet = tofloat(str_get_field(data(2:lix),2," "))
  lndnet = tofloat(str_get_field(data(2:lix),3," "))
  nicenet = tofloat(str_get_field(data(2:lix),4," "))
  sicenet = tofloat(str_get_field(data(2:lix),5," "))
  ocnnet = tofloat(str_get_field(data(2:lix),6," "))
  roffnet = tofloat(str_get_field(data(2:lix),7," "))
  ny = dimsizes(years)

  print("plotting fresh water budget")
  fname = "cplfwbudget"
  ;wks = gsn_open_wks("x11",fname)
  wks = gsn_open_wks(img_format,fname)
  gsn_define_colormap(wks,"table42")
  
  units = "W/m~S~2~N~"
  res = True
  res@tiMainFontHeightF = 0.022
  res@tiMainOffsetYF = -0.015
  res@tiYAxisFontHeightF = 0.02
  res@tiXAxisFontHeightF = 0.02
  res@tiXAxisOffsetYF = -0.03
  if (isvar("units")) then
    res@tiYAxisString = units
  end if
  res@vpHeightF = .18
  res@vpWidthF = .18 *5
  res@xyMonoDashPattern = True
  res@xyDashPattern = 0
  res@gsnYRefLine = 0.0
  res@gsnPaperOrientation = "portrait"
  res@gsnDraw = False
  res@gsnFrame = False

  xtitle = ""
  title = "CPL Global net ATM surface freshwater flux "+ case_number
  res@tiMainString = title

  plot1 = gsn_csm_xy(wks,years,atmnet,res)
  if (ny .gt. 50) then
    atm_smooth = runave(atmnet,11,0)
    plotadd1 = gsn_csm_xy(wks,years,atm_smooth,res)
    overlay(plot1,plotadd1)
  end if

  title = "CPL Global net OCEAN surface freshwater flux "+ case_number
  res@tiMainString = title

  plot2 = gsn_csm_xy(wks,years,ocnnet,res)
  if (ny .gt. 50) then
    ocn_smooth = runave(ocnnet,11,0)
    plotadd2 = gsn_csm_xy(wks,years,ocn_smooth,res)
    overlay(plot2,plotadd2)
  end if

  title = "CPL Global net NH ICE surface freshwater flux "+ case_number
  res@tiMainString = title

  plot3 = gsn_csm_xy(wks,years,nicenet,res)
  if (ny .gt. 50) then
    nice_smooth = runave(nicenet,11,0)
    plotadd3 = gsn_csm_xy(wks,years,nice_smooth,res)
    overlay(plot3,plotadd3)
  end if

  title = "CPL Global net SH ICE surface freshwater flux "+ case_number
  res@tiMainString = title

  plot4 = gsn_csm_xy(wks,years,sicenet,res)
  if (ny .gt. 50) then
    sice_smooth = runave(sicenet,11,0)
    plotadd4 = gsn_csm_xy(wks,years,sice_smooth,res)
    overlay(plot4,plotadd4)
  end if

  title = "CPL Global net LAND surface freshwater flux "+ case_number
  res@tiMainString = title

  plot5 = gsn_csm_xy(wks,years,lndnet,res)
  if (ny .gt. 50) then
    lnd_smooth = runave(lndnet,11,0)
    plotadd5 = gsn_csm_xy(wks,years,lnd_smooth,res)
    overlay(plot5,plotadd5)
  end if
  
  title = "CPL Global net RUNOFF surface freshwater flux "+ case_number
  res@tiMainString = title
  
  plot6 = gsn_csm_xy(wks,years,roffnet,res)
  if (ny .gt. 50) then
    roff_smooth = runave(roffnet,11,0)
    plotadd5 = gsn_csm_xy(wks,years,roff_smooth,res)
    overlay(plot5,plotadd5)
  end if

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  panel_res@gsnPanelYWhiteSpacePercent = 3.0
  gsn_panel(wks,(/plot1,plot2,plot3,plot4,plot5,plot6/), (/6,1/),panel_res)

end
