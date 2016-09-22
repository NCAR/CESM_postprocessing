load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

;; assumes the following standard transport diagnostics:
;;	Drake Passage
;;	Mozambique Channel
;;	Bering Strait
;;	Northwest Passage
;;	Indonesian Throughflow I
;;	Indonesian Throughflow II
;;	Florida Strait
;;	Windward Passage I
;;	Windward Passage II
;;	Gibraltar
;;	Nares Strait

begin

  daysperm = (/31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31./)
  midmonth = (/15.5,45.,74.5,105.,135.5,166.,196.5,227.5,258.,288.5,319.,349.5/)

  out_name = (/ "diagts_transport.drake", \
               "diagts_transport.mozam", \
               "diagts_transport.bering", \
               "diagts_transport.nwpassage", \
               "diagts_transport.itf1", \
               "diagts_transport.itf2", \
               "diagts_transport.florida", \
               "diagts_transport.windward1", \
               "diagts_transport.windward2", \
               "diagts_transport.gibraltar", \
               "diagts_transport.nares" /)

  in_name = (/ "transports.drake",\
               "transports.mozambique", \
               "transports.bering", \
               "transports.nwpassage",\
               "transports.itf1", \
               "transports.itf2", \
               "transports.florida", \
               "transports.windward1", \
               "transports.windward2", \
               "transports.gibraltar", \
               "transports.nares" /)
                    
  title_prefix = (/"Drake Passage", \
                   "Mozambique Channel", \
                   "Bering Strait", \
                   "Northwest Passage", \
                   "Indonesian Throughflow I", \
                   "Indonesian Throughflow II", \
                   "Florida Strait", \
                   "Windward Passage I", \
                   "Windward Passage II", \
                   "Gibraltar", \
                   "Nares Strait" /)

  ;          
  ; this processing assumes all ascii files have a single line header
  ;
   
  do i = 0, dimsizes(in_name) - 1
  ; isfilepresent always return false for .asc files so using fileexists instead
;;     if (.not. isfilepresent(in_name(i) + ".asc")) then
     if (.not. fileexists(in_name(i) + ".asc")) then
      print (in_name(i) + ".asc not found")
      continue
     end if
   
    data = asciiread(in_name(i)+".asc",-1,"string")
    year = tofloat(str_get_field(data(1:),1," "))
    mass = tofloat(str_get_field(data(1:),2," "))
    heat = tofloat(str_get_field(data(1:),3," "))
    salt = tofloat(str_get_field(data(1:),4," "))

    nyear = dimsizes(year) / 12

    mass_ann = new(nyear,float)
    heat_ann = new(nyear,float)
    salt_ann = new(nyear,float)
    yeartime = new(nyear,float)

    do iy = 0, nyear - 1
      m0 = iy*12
      m1 = m0+11
      mass_ann(iy) = avg(mass(m0:m1))
      heat_ann(iy) = avg(heat(m0:m1))
      salt_ann(iy) = avg(salt(m0:m1))
      yeartime(iy) = avg(year(m0:m1))
    end do

    title = title_prefix(i) + " Transports, " + case_number

    print("plotting time series " + title_prefix(i) + " Transports")
    ;wks = gsn_open_wks("x11",out_name(i))
    wks = gsn_open_wks(img_format,out_name(i))
    gsn_define_colormap(wks,"table42")

    res = True
    res@vpHeightF = .2857   ; height and width are important for proportion mainly -- the exact numbers do not matter
    res@vpWidthF = .6
    res@tiXAxisFontHeightF = 0.018
    res@tiYAxisFontHeightF = 0.018
    res@tiMainFontHeightF = 0.018
    res@tiMainOn = True
    res@tiMainString = title
    res@tiXAxisOn = False
    res@tmXBLabelsOn = False
    res@tmEqualizeXYSizes = True
    res@tmYLLabelFontHeightF = 0.015
    res@xyMonoDashPattern = True
    res@xyDashPattern = 0
    res@xyMonoLineColor = True
    res@xyLineColor = "black"
    res@gsnPaperOrientation = "portrait"
    res@gsnDraw = False
    res@gsnFrame = False

    ytitle = "MASS (Sv)"
    res@tiYAxisString = ytitle
    res@xyLineColor = "black"

    res@trXMaxF = max( (/max(year),max(yeartime)/) )
    res@trYMinF = min(mass)
    res@trYMaxF = max(mass)
    plot1 = gsn_csm_xy(wks,year,mass,res)
    res@xyLineColor = "red"
    plotadd1 = gsn_csm_xy(wks,yeartime,mass_ann,res)
    overlay(plot1,plotadd1)

    ytitle = "HEAT (PW)"
    res@tiMainOn = False
    res@tiYAxisString = ytitle
    res@xyLineColor = "black"
    res@trYMinF = min(heat)
    res@trYMaxF = max(heat)
    plot2 = gsn_csm_xy(wks,year,heat,res)
    res@xyLineColor = "red"
    plotadd2 = gsn_csm_xy(wks,yeartime,heat_ann,res)
    overlay(plot2,plotadd2)

    ytitle = "SALT (Sv*ppt)"
    res@tiYAxisString = ytitle
    res@xyLineColor = "black"
    res@tiXAxisString = "Years of Integration"
    res@tiXAxisOn = True
    res@tmXBLabelsOn = True
    res@trYMinF = min(salt)
    res@trYMaxF = max(salt)
    plot3 = gsn_csm_xy(wks,year,salt,res)
    res@xyLineColor = "red"
    plotadd3 = gsn_csm_xy(wks,yeartime,salt_ann,res)
    overlay(plot3,plotadd3)

    panel_res = True
    panel_res@gsnMaximize = True
    panel_res@gsnPaperOrientation = "portrait"
    panel_res@gsnPanelBottom = 0.08
    panel_res@gsnPanelTop = 0.92
    panel_res@gsnPanelScalePlotIndex = 1
    gsn_panel(wks,(/plot1,plot2,plot3/), (/3,1/),panel_res)

    delete([/data,year,yeartime,mass,heat,salt,mass_ann,heat_ann,salt_ann/])

  end do
end
