load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/yz_plot.ncl"

begin
  file_netcdf = getenv("MOCTSMONFILE")

  zmin = 500.
  ymin = 28.

  ncid = addfile(file_netcdf,"r")

  lat = ncid->lat_aux_grid
  mocz = ncid->moc_z
  time = ncid->time
  time=time/365.

  if (max(mocz) .gt. 10000.) then 
    mocz = mocz/100.
  end if

  annual = 0

  km = dimsizes(mocz)
  nlat = dimsizes(lat)
  nt = dimsizes(time)

  moc = ncid->MOC

  mocg = moc(:,0,0,:,:)
  moca = moc(:,1,0,:,:)
  miss = moc@_FillValue

  lat0 = min(lat > ymin)
  z0 = min(mocz > zmin)

  if (annual .eq. 0) then
    ny = nt / 12

    mocgann = mocg(0:ny-1,:,:)
    mocaann = moca(0:ny-1,:,:)
    maxmocgy = new(ny,float)
    maxmocay = new(ny,float)

    do it=0,ny-1 
      m0= it*12
      m1= m0+11
      mocgann(it,:,:) = dim_avg_n(mocg(m0:m1,:,:),0)
      mocaann(it,:,:) = dim_avg_n(moca(m0:m1,:,:),0)
      maxmocgy(it) = max(mocgann(it,{z0:},{lat0:}))
      maxmocay(it) = max(mocaann(it,{z0:},{lat0:}))
    end do
    timey = time(ispan(0,ny-1,1)*12 + 5)
  end if

  maxmocg = dim_max_n(mocg(:,{z0:},{lat0:}),(/1,2/))
  maxmoca = dim_max_n(moca(:,{z0:},{lat0:}),(/1,2/))

  fname = "maxmoc"
  print("plotting moc monthly time series")
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

  ytitle = "Sv"
  res@tiYAxisString = ytitle
  title = "Max Global Overturning "+case_number
  res@tiMainOn = True
  res@tiMainString = title
  res@tiXAxisOn = False
  res@xyLineColor = "black"
  res@trYMinF = 10
  res@trYMaxF = 40

  plot1 = gsn_csm_xy(wks,time,maxmocg,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd = gsn_csm_xy(wks,timey,maxmocgy,res)
  overlay(plot1,plotadd)

  xtitle = "Year"
  res@tiXAxisString = xtitle
  res@tiXAxisOn = True
  res@xyLineColor = "black"
  title = "Max Atlantic Overturning "+case_number
  res@tiMainString = title
  res@tiMainOn = True
  plot2 = gsn_csm_xy(wks,time,maxmoca,res)
  res@xyLineColor = "red"
  res@tiMainOn = False
  plotadd2 = gsn_csm_xy(wks,timey,maxmocay,res)
  overlay(plot2,plotadd2)

  text_res = True
  text_res@txFontHeightF = 0.018
  text_res@txJust = "topcenter"
  tx_id = gsn_create_text(wks,"(below 500m, North of 28~S~o~N~N)",text_res)
  anno_res = True
  anno_res@amSide = "bottom"
  anno_res@amZone = 9
  anno_res@amParallelPosF = 0.5
  anno_res@amOrthogonalPosF = 0.05
  anno_id = gsn_add_annotation(plot2,tx_id,anno_res)

  panel_res = True
  panel_res@gsnMaximize = True
  panel_res@gsnPaperOrientation = "portrait"
  panel_res@gsnPanelBottom = .08
  panel_res@gsnPanelYWhiteSpacePercent = 3
  gsn_panel(wks,(/plot1,plot2/), (/2,1/),panel_res)

end

exit()
