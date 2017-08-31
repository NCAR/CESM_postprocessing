; NCL script
; plot_rivers.ncl
; Keith Oleson, Nov 2003
;**************************************

load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/shea_util.ncl"
load "$DIAG_SHARED/functions_tables.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
begin
 print ("=========================================")
 print ("Starting:  set_7.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
;----------------------------------------------
; Get environment variables
;----------------------------------------------
 compare    = getenv("COMPARE")
 plot_type  = getenv("PLOTTYPE")
 version    = getenv("DIAG_VERSION")
 ptmpdir1    = getenv("PTMPDIR_1")
 ptmpdir2    = getenv("PTMPDIR_2")
 wkdir      = getenv("WKDIR")
 obsdata    = getenv("OBS_DATA")      ; OBS directory
 diag_code  = getenv("DIAG_CODE")
 inputPath  = getenv("INPUT_FILES")
 resdir     = getenv("DIAG_RESOURCES")
 useCommon1 = getenv("UseCommonName_1")
 useCommon2 = getenv("UseCommonName_2")
 case1      = getenv("caseid_1")
 case2      = getenv("caseid_2") 
 prefix1    = getenv("prefix_1")
 prefix2    = getenv("prefix_2")
 rtm1       = getenv("rtm_1")    ; Are RTM variables on separate history files?
 rtm2       = getenv("rtm_2")    ; Are RTM variables on separate history files?
 rmodel1    = getenv("rmodel_1") ; Is Mosart used?
 rmodel2    = getenv("rmodel_2") ; Is Mosart used?

;----------------------------------------------
; CASE 1 MODEL
;----------------------------------------------

 print("useCommon1 = "+useCommon1)
 print("rmodel1 = "+rmodel1)
 print("rtm1 = "+rtm1)
 print("prefix1 = "+prefix1)
 print("case1 = "+case1)
 print("ptmpdir1 = "+ptmpdir1)
 print("useCommon2 = "+useCommon2)
 print("rmodel2 = "+rmodel2)
 print("rtm2 = "+rtm2)
 print("prefix2 = "+prefix2)
 print("case2 = "+case2)
 print("ptmpdir2 = "+ptmpdir2)


 if ((rmodel1 .eq. "False") .and. (rtm1 .eq. "False"))  then
; river variables on clm history files
   inptr1a = addfile(ptmpdir1+"/"+prefix1+"_ANN_climo.nc","r")
   inptr1m = addfile(ptmpdir1+"/"+prefix1+"MONS_climo.nc","r")
   print("inptr1a = "+ptmpdir1+"/"+prefix1+"_ANN_climo.nc")
   print("inptr1m = "+ptmpdir1+"/"+prefix1+"MONS_climo.nc")
 end if
 if ((rmodel1 .eq. "False") .and. (rtm1 .eq. "True" )) then
; river variables on rtm history files
   inptr1a = addfile(ptmpdir1+"/"+"/rof/"+case1+".rtm.h0._ANN_climo.nc","r")
   inptr1m = addfile(ptmpdir1+"/"+"/rof/"+case1+".rtm.h0.MONS_climo.nc","r")
   print("inptr1a = "+ptmpdir1+"/"+"/rof/"+case1+".rtm.h0._ANN_climo.nc")
   print("inptr1m = "+ptmpdir1+"/"+"/rof/"+case1+".rtm.h0.MONS_climo.nc")
 end if
 if (rmodel1 .eq. "True") then
; river variables on mosart history files
   inptr1a = addfile(ptmpdir1+"/"+"/rof/"+case1+".mosart.h0._ANN_climo.nc","r")
   inptr1m = addfile(ptmpdir1+"/"+"/rof/"+case1+".mosart.h0.MONS_climo.nc","r")
   print("inptr1a = "+ptmpdir1+"/"+"/rof/"+case1+".mosart.h0._ANN_climo.nc")
   print("inptr1m = "+ptmpdir1+"/"+"/rof/"+case1+".mosart.h0.MONS_climo.nc")
 end if

 if (useCommon1 .eq. "True") then 
     case1  = getenv("commonName_1")
 end if 

 time = inptr1m->time
 months = dimsizes(time)
;; if (rtm1 .eq. "1") then
;; if (rmodel1 .eq. "True") then
   lat = inptr1a->lat
   lon = inptr1a->lon
;; else
;;   lat = inptr1a->latrof
;;   lon = inptr1a->lonrof
;; end if
 nlat = dimsizes(lat)
 nlon = dimsizes(lon)
 if (isatt(inptr1a,"yrs_averaged")) then
  yrs_ave1 = inptr1a@yrs_averaged
  label1 = case1+" (yrs "+yrs_ave1+")"
 else
  label1 = case1
 end if

;----------------------------------------------
; CASE 2 MODEL
;----------------------------------------------

 print("rmodel2 = "+rmodel2)
 print("rtm2 = "+rtm2)
 print("prefix2 = "+prefix2)
 print("case2 = "+case2)
 print("ptmpdir2 = "+ptmpdir2)

 if ((rmodel2 .eq. "False") .and. (rtm2 .eq. "False"))  then
; river variables on clm history files
   inptr2a = addfile(ptmpdir2+"/"+prefix2+"_ANN_climo.nc","r")
   inptr2m = addfile(ptmpdir2+"/"+prefix2+"MONS_climo.nc","r")
   print("inptr2a = "+ptmpdir2+"/"+prefix2+"_ANN_climo.nc")
   print("inptr2m = "+ptmpdir2+"/"+prefix2+"MONS_climo.nc")
 end if
 if ((rmodel2 .eq. "False") .and. (rtm2 .eq. "True" )) then
; river variables on rtm history files
   inptr2a = addfile(ptmpdir2+"/"+"/rof/"+case2+".rtm.h0._ANN_climo.nc","r")
   inptr2m = addfile(ptmpdir2+"/"+"/rof/"+case2+".rtm.h0.MONS_climo.nc","r")
   print("inptr2a = "+ptmpdir2+"/"+"/rof/"+case2+".rtm.h0._ANN_climo.nc")
   print("inptr2m = "+ptmpdir2+"/"+"/rof/"+case2+".rtm.h0.MONS_climo.nc")
 end if
 if (rmodel2 .eq. "True") then
; river variables on mosart history files
   inptr2a = addfile(ptmpdir2+"/"+"/rof/"+case2+".mosart.h0._ANN_climo.nc","r")
   inptr2m = addfile(ptmpdir2+"/"+"/rof/"+case2+".mosart.h0.MONS_climo.nc","r")
   print("inptr2a = "+ptmpdir2+"/"+"/rof/"+case2+".mosart.h0._ANN_climo.nc")
   print("inptr2m = "+ptmpdir2+"/"+"/rof/"+case2+".mosart.h0.MONS_climo.nc")
 end if

 if (useCommon2 .eq. "True") then 
     case2  = getenv("commonName_2")
 end if 

 if (isatt(inptr2a,"yrs_averaged")) then
   yrs_ave2 = inptr2a@yrs_averaged
   label2 = case2+" (yrs "+yrs_ave2+")"
 else
   label2 = case2
 end if

 dayinmonth = (/31,28,31,30,31,30,31,31,30,31,30,31/)

;----------------------------------------------
; ALWAYS OBS for table of river flow
;----------------------------------------------
 ptr_rivflow = obsdata +"/dai_and_trenberth_table2.asc"
 case3 = "Dai and Trenberth (2002)"

;----------------------------------------------
; Get river names and other fields. These
; are from Dai and Trenberth (2002). 
;----------------------------------------------
 dStr = asciiread (ptr_rivflow, -1, "string")
 dChr = stringtochar(dStr)
 no                    = stringtointeger( chartostring(dChr(3:,0:2)) )
 river_name            = chartostring(dChr(3:,4:18))
 obs_vol_at_stn        = stringtointeger( chartostring(dChr(3:,20:23)) )
 obs_sd_vol_at_stn     = stringtointeger( chartostring(dChr(3:,25:27)) )
 fekete_rtm_vol_at_stn = stringtointeger( chartostring(dChr(3:,29:32)) )
 da_at_stn             = stringtointeger( chartostring(dChr(3:,34:37)) )
 stn_lon               = stringtofloat( chartostring(dChr(3:,39:45)) )
 stn_lat               = stringtofloat( chartostring(dChr(3:,47:52)) )
 rtm_fekete_stn_lon    = stringtofloat( chartostring(dChr(3:,54:60)) )
 rtm_fekete_stn_lat    = stringtofloat( chartostring(dChr(3:,62:67)) )
 obs_nyr_stn           = stringtointeger( chartostring(dChr(3:,69:71)) )
 stn_name              = chartostring(dChr(3:,73:99))
 obs_vol_at_riv_mou    = stringtointeger( chartostring(dChr(3:,101:104)) )
 da_at_riv_mou         = stringtointeger( chartostring(dChr(3:,106:109)) )
 rtm_fekete_mou_lon    = stringtofloat( chartostring(dChr(3:,111:117)) )
 rtm_fekete_mou_lat    = stringtofloat( chartostring(dChr(3:,119:124)) )
 delete(dStr)
 delete(dChr)
;----------------------------------------------
; Get RTM station locations. These are in river
; direction file.
;----------------------------------------------

 if (rmodel1 .eq. "True") then   ; Mosart
   ptr_rtm_station_locations_A = resdir+"/rdirc.mosart.05"
 else                       ; RTM
   ptr_rtm_station_locations_A = resdir+"/rdirc.rtm.05"
 end if
 if (rmodel2 .eq. "True") then   ; Mosart
   ptr_rtm_station_locations_B = resdir+"/rdirc.mosart.05"
 else                       ; RTM
   ptr_rtm_station_locations_B = resdir+"/rdirc.rtm.05"
 end if

 dStr = asciiread (ptr_rtm_station_locations_A, -1, "string")
 dChr = stringtochar(dStr)
 r_name                = chartostring(dChr(:,0:16))
 rtm_stn_lon_A         = stringtofloat( chartostring(dChr(:,17:23)) )
 rtm_stn_lat_A         = stringtofloat( chartostring(dChr(:,25:30)) )
 stn_name              = chartostring(dChr(:,33:59))
 delete(dStr)
 delete(dChr)
 delete(r_name)
 delete(stn_name)

 dStr = asciiread (ptr_rtm_station_locations_B, -1, "string")

 dChr = stringtochar(dStr)
 r_name                = chartostring(dChr(:,0:16))
 rtm_stn_lon_B         = stringtofloat( chartostring(dChr(:,17:23)) )
 rtm_stn_lat_B         = stringtofloat( chartostring(dChr(:,25:30)) )
 stn_name              = chartostring(dChr(:,33:59))

 nriv  = dimsizes(no)    ; number of rivers
 rtm_vol_at_stn = new(nriv,float)
 rtm_vol_at_stn_A = new(nriv,float)
 rtm_vol_at_stn_B = new(nriv,float)
 rtm_vol_at_stn_m = new((/months,nriv/),float)
 rtm_vol_at_stn_mA = new((/months,nriv/),float)
 rtm_vol_at_stn_mB = new((/months,nriv/),float)


 if (rmodel1 .eq. "False") then
   if (isfilevar(inptr1a,"QCHANR")) then
     qchanr_A   = inptr1a->QCHANR(0,:,:)
   else
     qchanr_A   = inptr1a->QCHANR_LIQ(0,:,:)
   end if
 else
   qchanr_A     = inptr1a->RIVER_DISCHARGE_OVER_LAND_LIQ(0,:,:)
 end if
 if (rmodel2 .eq. "False") then
   if (isfilevar(inptr2a,"QCHANR")) then
     qchanr_B   = inptr2a->QCHANR(0,:,:)
   else
     qchanr_B   = inptr2a->QCHANR_LIQ(0,:,:)
   end if
 else
   qchanr_B     = inptr2a->RIVER_DISCHARGE_OVER_LAND_LIQ(0,:,:)
 end if
  if (rmodel1 .eq. "False") then
   if (isfilevar(inptr1m,"QCHANR")) then
     qchanr_mA  = inptr1m->QCHANR(:,:,:)
   else
     qchanr_mA  = inptr1m->QCHANR_LIQ(:,:,:)
   end if
 else
   qchanr_mA    = inptr1m->RIVER_DISCHARGE_OVER_LAND_LIQ(:,:,:)
 end if
 if (rmodel2 .eq. "False") then
   if (isfilevar(inptr2m,"QCHANR")) then
     qchanr_mB  = inptr2m->QCHANR(:,:,:)
   else
     qchanr_mB  = inptr2m->QCHANR_LIQ(:,:,:)
   end if
 else
   qchanr_mB    = inptr2m->RIVER_DISCHARGE_OVER_LAND_LIQ(:,:,:)
 end if

 if (rmodel1 .eq. "False") then
   if (isfilevar(inptr1a,"QCHOCNR")) then
     print("QCHOCNR 1.1")
     qchocnr_A  = inptr1a->QCHOCNR(0,:,:)
     print("dimsize qhcocnr_A = "+dimsizes(qchocnr_A))
   else
     qchocnr_A  = inptr1a->QCHOCNR_LIQ(0,:,:)
   end if
 else
   qchocnr_A    = inptr1a->TOTAL_DISCHARGE_TO_OCEAN_LIQ(0,:,:)
 end if
 if (rmodel2 .eq. "False") then
   if (isfilevar(inptr2a,"QCHOCNR")) then
     print("QCHOCNR 2.1")
     qchocnr_B  = inptr2a->QCHOCNR(0,:,:)
   else
     qchocnr_B  = inptr2a->QCHOCNR_LIQ(0,:,:)
   end if
 else
   qchocnr_B    = inptr2a->TOTAL_DISCHARGE_TO_OCEAN_LIQ(0,:,:)
 end if

 if (rmodel1 .eq. "False") then
   if (isfilevar(inptr1m,"QCHOCNR")) then
     print("QCHOCNR 1.2")
     qchocnr_mA = inptr1m->QCHOCNR(:,:,:)
   else
     qchocnr_mA = inptr1m->QCHOCNR_LIQ(:,:,:)
   end if
 else
   qchocnr_mA   = inptr1m->TOTAL_DISCHARGE_TO_OCEAN_LIQ(:,:,:)
 end if
 if (rmodel2 .eq. "False") then
   if (isfilevar(inptr2m,"QCHOCNR")) then
     print("QCHOCNR 2.2")
     qchocnr_mB = inptr2m->QCHOCNR(:,:,:)
   else
     qchocnr_mB = inptr2m->QCHOCNR_LIQ(:,:,:)
   end if
 else
   qchocnr_mB   = inptr2m->TOTAL_DISCHARGE_TO_OCEAN_LIQ(:,:,:)
 end if

 qchanr_A   = catchNaN(qchanr_A)
 qchocnr_A  = catchNaN(qchocnr_A)
 qchanr_B   = catchNaN(qchanr_B)
 qchocnr_B  = catchNaN(qchocnr_B)
 qchanr_mA  = catchNaN(qchanr_mA)
 qchocnr_mA = catchNaN(qchocnr_mA)
 qchanr_mB  = catchNaN(qchanr_mB)
 qchocnr_mB = catchNaN(qchocnr_mB)
;----------------------------------------------
; Start calculations for table of river flow for
; 50 lartest rivers and for monthly station flow 
; from largest 10 rivers
;----------------------------------------------

 nmodels = 1

 do j = 0,nmodels
   if (j .eq. 0) then
     qchanr = qchanr_A
     qchanr_m = qchanr_mA
   else
     qchanr = qchanr_B
     qchanr_m = qchanr_mB
   end if

   if (j .eq. 0) then
      do i = 0,nriv-1 
        obs_vol_stn  = obs_vol_at_stn(i)*1.e9/(86400.*365.) ; from km3/yr to m3/s
	rtm_vol_at_stn(i) = qchanr({rtm_stn_lat_A(i)},{rtm_stn_lon_A(i)})
	do m = 0,months-1
           rtm_vol_at_stn_m(m,i) = qchanr_m(m,{rtm_stn_lat_A(i)},{rtm_stn_lon_A(i)})
        end do
      end do
     rtm_vol_at_stn_A = rtm_vol_at_stn/1.e9*86400.*365 ;from m3/s to km3/yr
     rtm_vol_at_stn_mA = rtm_vol_at_stn_m/1.e9*86400.*conform(rtm_vol_at_stn_m,dayinmonth,0)/100. ;from m3/s to 100 km3/month
   else
     do i = 0,nriv-1 
       obs_vol_stn  = obs_vol_at_stn(i)*1.e9/(86400.*365.) ; from km3/yr to m3/s
       print(rtm_stn_lat_B(i))
       print(rtm_stn_lon_B(i))
       rtm_vol_at_stn(i) = qchanr({rtm_stn_lat_B(i)},{rtm_stn_lon_B(i)})
       do m = 0,months-1
          rtm_vol_at_stn_m(m,i) = qchanr_m(m,{rtm_stn_lat_B(i)},{rtm_stn_lon_B(i)})
       end do
     end do
     rtm_vol_at_stn_B = rtm_vol_at_stn/1.e9*86400.*365 ;from m3/s to km3/yr
     rtm_vol_at_stn_mB = rtm_vol_at_stn_m/1.e9*86400.*conform(rtm_vol_at_stn_m,dayinmonth,0)/100. ;from m3/s to 100 km3/month
   end if
 end do

;----------------------------------------------
; Prepare data for table of river flow
;----------------------------------------------

 riv_data = new((/11,nriv/),"float")
 riv_data(0,:)  = ispan(1,nriv,1)
 riv_data(1,:)  = obs_vol_at_stn
 riv_data(2,:)  = fekete_rtm_vol_at_stn
 riv_data(3,:)  = rtm_vol_at_stn_A
 riv_data(4,:)  = rtm_vol_at_stn_B
 riv_data(5,:)  = stn_lon
 riv_data(6,:)  = stn_lat
 riv_data(7,:)  = rtm_stn_lon_A
 riv_data(8,:)  = rtm_stn_lat_A
 riv_data(9,:)  = rtm_stn_lon_B
 riv_data(10,:) = rtm_stn_lat_B

 riv_data_titles = new(13,"string")
 riv_data_titles(0)  = "NO.                     "
 riv_data_titles(1)  = "RIVER NAME              "
 riv_data_titles(2)  = "   OBS VOL              "
 riv_data_titles(3)  = "RTM VOL GRDC            "
 riv_data_titles(4)  = " RTM VOL TEST CASE      "
 riv_data_titles(5)  = " RTM VOL REF CASE       "
 riv_data_titles(6)  = "    STN LON             "
 riv_data_titles(7)  = "    STN LAT             "
 riv_data_titles(8)  = " STN LON TEST CASE      "
 riv_data_titles(9)  = " STN LAT TEST CASE      "
 riv_data_titles(10) = " STN LON REF CASE       "
 riv_data_titles(11) = " STN LAT REF CASE       "
 riv_data_titles(12) = "STATION, COUNTRY        "

;----------------------------------------------
; Print the table
;----------------------------------------------
 typ = (/"RIVER_STN_VOL"/)
 numtab = dimsizes(typ)
 do n = 0, numtab-1
   tablename = wkdir+"set7_table_"+typ(n)+".txt"
   if (typ(n) .eq. "RIVER_STN_VOL") then
     title = (/"DIAG SET 7: RTM flow at station for world's 50 largest rivers (km3/yr)"/)
     make_rivers_table(case1,label1,case2,label2,case3,river_name,riv_data,riv_data_titles, \
                       stn_name,title,tablename)
   end if
 end do
;----------------------------------------------
; End calculations for table of river flow
;----------------------------------------------

;----------------------------------------------
; Plot RTM station locations
;----------------------------------------------
;----------------------------------------------
; Open ps workstation
;----------------------------------------------
 wks = gsn_open_wks(plot_type,wkdir+"set7_stations")
;----------------------------------------------
; Common plot resources
;----------------------------------------------
 res = True
 res@mpProjection = "Robinson"
 res@mpPerimOn    = False
 res@mpGridLineColor = "transparent" 
 res@gsnDraw = False
 res@gsnFrame = False
 res@gsnMaximize = True
 res@gsnPaperOrientation = "landscape"
 res@mpGridLonSpacingF   = 60.0            ; Set lon grid spacing
 res@mpGridLatSpacingF    = 30.0           ; Set lat grid spacing
 res@mpOutlineOn          =  True
 res@mpGridAndLimbOn      =  True
 res@mpGridLineDashPattern =  2            ; Set grid line dash pattern (dash)
 res@mpGridLineThicknessF   = 0.5          ; Set grid line thickness
 res@gsnRightString = " "
 res@gsnLeftString  = " "

 res@tiMainString = "RTM location corresponding to gauge station"
 polyres = True
 polyres@gsMarkerIndex = 16
 polyres@gsMarkerSizeF = 8.
 polyres@gsMarkerColor = "Blue1"
 plot = gsn_csm_map(wks,res)
 dum1 = gsn_add_polymarker(wks,plot,rtm_stn_lon_A,rtm_stn_lat_A,polyres)
 polyres@gsMarkerColor = "Red1"
 dum2 = gsn_add_polymarker(wks,plot,rtm_stn_lon_B,rtm_stn_lat_B,polyres)
 draw(wks)
 frame(wks)
 delete(res)
 delete(plot)

;----------------------------------------------
; Plot scatter plot of model river flow versus observations for top 50 rivers
; but excluding the top two rivers, the Amazon and Congo
;----------------------------------------------
;----------------------------------------------
; Open ps workstation
;----------------------------------------------
   wks = gsn_open_wks(plot_type,wkdir+"set7_scatter_50riv")
;----------------------------------------------
; Common plot resources
;----------------------------------------------
 res                        = True
 res@xyMarkLineModes        = "Markers"
 res@xyMarkers              = 16
 res@xyMarkerColor          = "Blue"
 res@xyMarkerSizeF          = 0.008
 res@trXMinF = -200.
 res@trXMaxF = 1200.
 res@trYMinF = -200.
 res@trYMaxF = 1200.
 res@gsnDraw = False
 res@gsnFrame = False
 res@tiXAxisString          = "Station Observations"

 polyres = True
 polyres@gsLineThicknessF      = 1.
 polyres@gsLineDashPattern     = 16.
 polyres@gsLineColor           = "black"
 rgpolyres = True
 rgpolyres@gsLineThicknessF      = 2.
 rgpolyres@gsLineDashPattern     = 0.
 rgpolyres@gsLineColor           = "Blue"
 xx = (/-200.,1200./)
 yy = (/-200.,1200./)

 txres = True
 txres@txFont = "Times-Roman"
 txres@txFontHeightF = 0.015

;----------------------------------------------
; common resources for panel plots
;----------------------------------------------
   pan = True
   pan@gsnMaximize = True
   pan@gsnPaperOrientation = "portrait"
   pan@txString           = "               River Flow at Station"+" (km~S~3~N~ yr~S~-1~N~)~C~(Top 50 rivers excluding the Amazon and Congo)"
   res@tiMainString           = " "
   plot = new(2,"graphic")
   res@tiYAxisString          = case1
   plot(0) = gsn_csm_xy(wks,riv_data(1,2:49),riv_data(3,2:49),res)
   dum1 = gsn_add_polyline(wks,plot(0),xx,yy,polyres)
   rc = regline(riv_data(1,2:49),riv_data(3,2:49))
   yReg = rc*(riv_data(1,2:49)-rc@xave) + rc@yave
   intercept = rc*(0.-rc@xave) + rc@yave
   dum2 = gsn_add_polyline(wks,plot(0),riv_data(1,2:49),yReg,rgpolyres)
   dum3 = gsn_add_text (wks,plot(0),"Y = "+sprintf("%5.2f",rc)+"*X + "+"("+sprintf("%8.2f",intercept)+")",800.,0.,txres)
   res@tiYAxisString          = case2
   plot(1) = gsn_csm_xy(wks,riv_data(1,2:49),riv_data(4,2:49),res)
   dum4 = gsn_add_polyline(wks,plot(1),xx,yy,polyres)
   rc = regline(riv_data(1,2:49),riv_data(4,2:49))
   yReg = rc*(riv_data(1,2:49)-rc@xave) + rc@yave
   intercept = rc*(0.-rc@xave) + rc@yave
   dum5 = gsn_add_polyline(wks,plot(1),riv_data(1,2:49),yReg,rgpolyres)
   dum6 = gsn_add_text (wks,plot(1),"Y = "+sprintf("%5.2f",rc)+"*X + "+"("+sprintf("%8.2f",intercept)+")",800.,0.,txres)
   pan@gsnPanelBottom = 0.01
   gsn_panel(wks,plot,(/2,1/),pan)
   delete(res)
   delete(polyres)
   delete(plot)

;----------------------------------------------
; Start calculations for plots of monthly flow
; at station for 10 largest rivers
;----------------------------------------------
;----------------------------------------------
; ALWAYS OBS for plots of monthly flow at station
;----------------------------------------------
 ptr_top10riv_mon_stn_disch = obsdata +"/dai_and_trenberth_top10riv_mon_stn_disch.asc"
 top10riv_mon_stn_disch = asciiread (ptr_top10riv_mon_stn_disch, (/11,15/), "float")

;----------------------------------------------
; Common resources for xy plots
;----------------------------------------------
 res                        = True
 res@tiXAxisString          = " "
 res@tiXAxisFontHeightF     = 0.040
 res@tiYAxisFontHeightF     = 0.040
 res@tiMainFontHeightF      = 0.045
 res@tmYLLabelFontHeightF   = 0.04
 res@tmXBLabelFontHeightF   = 0.04
 res@txFontHeightF = 0.045
 res@xyLineThicknesses       = (/2.,2.,1./)
 res@xyDashPatterns         = (/0.,0.,0./)          ; solid
 res@xyLineColors           = (/"red","blue","black"/)
 res@xyMonoLineColor = False
 x = ispan(1,months+1,1)
 x!0 = "month"
 res@trXMinF = 1
 res@trXMaxF = months+1
 res@tmXBMode = "Explicit"
 res@tmXBValues = x
 res@tmXBLabels = (/"J","F","M","A","M","J","J","A","S","O","N","D","J"/)
 ymin = (/ -1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0/)
 ymax = (/10.0,2.5,4.5,2.5,2.5,2.5,2.5,2.5,3.5,2.0/)
 timainstr = (/"Amazon","Mississippi","Congo","Yenisey", \
               "Orinoco","Parana","Changjiang","Lena", \
               "Brahmaputra+Ganges","Mekong"/)
;----------------------------------------------
; common resources for panel plots
;----------------------------------------------
 pan = True
 pan@gsnMaximize = True
 pan@gsnPaperOrientation = "portrait"
 pan@gsnFrame = False
 pan@txString = "Mean Annual Cycle of River Flow at Station"
 plot = new(10,"graphic")
 res@gsnDraw                = False               ; Do not draw plot
 res@gsnFrame               = False               ; Do not advance frame
 res@vpKeepAspect           = False
 res@vpWidthF               = 1.2
 ydata = new((/3,months+1/),"float")
 top10riv_index = (/0,5,1,6,2,7,3,8,4,9/)
;----------------------------------------------
; Open file for plots
;----------------------------------------------
 wks = gsn_open_wks(plot_type,wkdir+"set7_mon_stndisch_10riv")

 do k = 0,9

   if (top10riv_index(k) .eq. 4) then  ;Brahmaputra+Ganges
     ydata(0,0:months-1) = rtm_vol_at_stn_mA(0:months-1,top10riv_index(k)) \
                           +rtm_vol_at_stn_mA(0:months-1,13)
     ydata(0,months)     = rtm_vol_at_stn_mA(0,top10riv_index(k))+rtm_vol_at_stn_mA(0,13)
     ydata(1,0:months-1) = rtm_vol_at_stn_mB(0:months-1,top10riv_index(k)) \
                           +rtm_vol_at_stn_mB(0:months-1,13)
     ydata(1,months)     = rtm_vol_at_stn_mB(0,top10riv_index(k))+rtm_vol_at_stn_mB(0,13)

     ydata(2,0:months-1) = (top10riv_mon_stn_disch(top10riv_index(k),2:13) \
                           +top10riv_mon_stn_disch(10,2:13))/100.
     ydata(2,months)     = (top10riv_mon_stn_disch(top10riv_index(k),2) \
                           +top10riv_mon_stn_disch(10,2))/100.
   else
     ydata(0,0:months-1) = rtm_vol_at_stn_mA(0:months-1,top10riv_index(k))
     ydata(0,months)     = rtm_vol_at_stn_mA(0,top10riv_index(k))
     ydata(1,0:months-1) = rtm_vol_at_stn_mB(0:months-1,top10riv_index(k))
     ydata(1,months)     = rtm_vol_at_stn_mB(0,top10riv_index(k))

     ydata(2,0:months-1) = top10riv_mon_stn_disch(top10riv_index(k),2:13)/100.
     ydata(2,months)     = top10riv_mon_stn_disch(top10riv_index(k),2)/100.
   end if
   
   res@trYMinF = ymin(k)
   res@trYMaxF = ymax(k)
   res@gsnCenterString = timainstr(k)
   if (k%2 .eq. 0) then
     res@tiYAxisString         = "Total Runoff (X100 km~S~3~N~ month~S~-1~N~)"
   else
     res@tiYAxisString         = " "
   end if
   plot(k) = gsn_csm_xy(wks,x,ydata(:,:),res)

 end do
 delete(ydata)

 pan@gsnPanelBottom = 0.18
 gsn_panel(wks,plot,(/5,2/),pan)
 legend = create "Legend" legendClass wks
   "vpXF"                     : 0.325
   "vpYF"                     : 0.15
   "vpWidthF"                 : 0.35
   "vpHeightF"                : 0.10
   "lgPerimOn"                : False
   "lgItemCount"              : 3
   "lgLabelsOn"               : True
   "lgLineLabelsOn"           : False
   "lgLabelStrings"           : (/label1,label2,"Station Observation"/)
   "lgDashIndexes"            : (/0,0,0/)
   "lgLineColors"             : (/"red","blue","black"/)
   "lgMonoLineLabelFontColor" : True
   "lgAutoManage"             : False
   "lgLabelFontHeightF"       : 0.01
   "lgLabelPosition"          : "Right"
 end create
 draw(legend)

 frame(wks)
 delete(res)
 delete(pan)
 delete(ymin)
 delete(ymax)
 delete(timainstr)
 delete(plot)
 delete(x)

;----------------------------------------------
; Start calculations for plots of annual discharge
; into oceans
;----------------------------------------------

;----------------------------------------------
; ALWAYS OBS for plots of annual discharge into oceans
;----------------------------------------------
 ptr_921riv_disch = obsdata +"/dai_and_trenberth_921riv_ann_disch.asc"
 ann_disch_921riv = asciiread (ptr_921riv_disch, (/180,6/), "float")

 ptr_921riv_acc_disch = obsdata +"/dai_and_trenberth_921riv_acc_ann_disch.asc"
 acc_ann_disch_921riv = asciiread (ptr_921riv_acc_disch, (/180,8/), "float")

 ptr_ocean_basin_index = addfile(obsdata +"/DIAG_OCEAN_BASIN_INDEX.nc","r")
 ocean_basin_index = ptr_ocean_basin_index->OCEAN_BASIN_INDEX

;----------------------------------------------
; Reorder south to north and identify missing data
;----------------------------------------------
 ann_disch_921riv = ann_disch_921riv(::-1,:)
 acc_ann_disch_921riv = acc_ann_disch_921riv(::-1,:)
 ann_disch_921riv@_FillValue = -999.
 acc_ann_disch_921riv@_FillValue = -999.
;----------------------------------------------
; Set accumulated discharge data south of 58.5S to missing 
; per Dai and Trenberth (2002) because 
; 921riv doesn't include Antarctica
;----------------------------------------------
 acc_ann_disch_921riv(0:30,:) = -999.

 ocean_basin = new(4,"integer")
 ocean_basin(0) = 6 ;used to eliminate inland discharge from global ocean
 ocean_basin(1) = 1 ;atlantic
 ocean_basin(2) = 3 ;indian
 ocean_basin(3) = 2 ;pacific

;----------------------------------------------
; Common resources for xy plots
;----------------------------------------------
 resL                       = True
 resL@gsnFrame              = False
 resL@tiXAxisString         = "Latitude"
 resL@tiYAxisString         = "Total Discharge Accumulated from 90N (10~S~6~N~ m~S~3~N~ s~S~-1~N~)"
 resL@tiXAxisFontHeightF     = 0.015
 resL@tiYAxisFontHeightF     = 0.015
 resL@tiMainFontHeightF      = 0.015
 resL@xyDashPatterns         = (/0,0,0/)
 resL@xyLineThicknesses       = (/2.,2.,1./)
 resL@xyLineColors           = (/"red","blue","black"/)
 resL@xyMonoLineColor = False

 resR = True
 resR@gsnFrame              = False
 resR@tiXAxisFontHeightF     = 0.015
 resR@tiYAxisFontHeightF     = 0.015
 resR@tiMainFontHeightF      = 0.015
 resR@xyDashPatterns         = (/0,0,0/)
 resR@xyLineThicknesses       = (/2.,2.,1./)
 resR@xyLineColors           = (/"red","blue","black"/)

 x = fspan(-89.5,89.5,180)
 x!0 = "latitude"

 filestr = (/"globalocean","atlantic","indian","pacific"/)
 nocean_basin = dimsizes(filestr)
 yminr = (/0.0,0.0,0.0,0.0/)
 ymaxr = (/0.3,0.3,0.12,0.08/)
 xminl = (/-80.,-80.,-60.,-80./)
 xmaxl = (/80.,80.,40.,80./)
 yminl = (/-0.2,-0.2,-0.1,-0.15/)
 ymaxl = (/1.4,0.7,0.3,0.40/)
 divis = (/17,17,11,17/)
 disch_id = (/5,2,4,3/)
 acc_disch_id = (/7,2,4,3/)
 timainstr = (/"Annual discharge into the Global Ocean", \
               "Annual discharge into the Atlantic Ocean", \
               "Annual discharge into the Indian Ocean", \
               "Annual discharge into the Pacific Ocean"/)
 tiyaxisstr = (/"Discharge into the Global Ocean (10~S~6~N~ m~S~3~N~ s~S~-1~N~ per degree lat)", \
                "Discharge into the Atlantic Ocean (10~S~6~N~ m~S~3~N~ s~S~-1~N~ per degree lat)", \
                "Discharge into the Indian Ocean (10~S~6~N~ m~S~3~N~ s~S~-1~N~ per degree lat)", \
                "Discharge into the Pacific Ocean (10~S~6~N~ m~S~3~N~ s~S~-1~N~ per degree lat)"/)
;----------------------------------------------
; Loop over number of ocean basins (global,atlantic,
; indian, pacific)
;----------------------------------------------
 do k = 0,3

 if (k .eq. 0) then
   tmp_A = mask(qchocnr_A,(ocean_basin_index .ne. ocean_basin(k)),True)
   tmp_B = mask(qchocnr_B,(ocean_basin_index .ne. ocean_basin(k)),True)
 else
   tmp_A = mask(qchocnr_A,ocean_basin_index,ocean_basin(k))
   tmp_B = mask(qchocnr_B,ocean_basin_index,ocean_basin(k))
 end if
;----------------------------------------------
; Derive zonal average of ocean discharge at 1 degree resolution
;----------------------------------------------

 qchocnr_lat_A = new(nlat/2,"float")
 qchocnr_lat_B = new(nlat/2,"float")
 st_lat = 0
 fn_lat = 1
 do j = 0,nlat/2-1
   qchocnr_lat_A(j) = sum(tmp_A(st_lat:fn_lat,:))
   if (ismissing(qchocnr_lat_A(j))) then
     qchocnr_lat_A(j) = 0.
   end if
   st_lat = fn_lat+1
   fn_lat = st_lat+1
 end do
 st_lat = 0
 fn_lat = 1
 do j = 0,nlat/2-1
     qchocnr_lat_B(j) = sum(tmp_B(st_lat:fn_lat,:))
     if (ismissing(qchocnr_lat_B(j))) then
       qchocnr_lat_B(j) = 0.
     end if
     st_lat = fn_lat+1
     fn_lat = st_lat+1
 end do
 delete(tmp_A)
 delete(tmp_B)

;----------------------------------------------
; Derive zonal average of accumulated ocean discharge
; at 1 degree resolution
;----------------------------------------------
; Reorder north to south 
 tmp = qchocnr_lat_A(::-1)

 qchocnr_acc_A = new(nlat/2,"float")
 qchocnr_acc_A(0) = tmp(0)
 do j = 1,nlat/2-1
   qchocnr_acc_A(j) = tmp(j)+qchocnr_acc_A(j-1)
 end do
 delete(tmp)
 qchocnr_acc_A = qchocnr_acc_A(::-1)

 qchocnr_acc_B = new(nlat/2,"float")
 tmp = qchocnr_lat_B(::-1)
 qchocnr_acc_B(0) = tmp(0)
 do j = 1,nlat/2-1
     qchocnr_acc_B(j) = tmp(j)+qchocnr_acc_B(j-1)
 end do
 delete(tmp)
 qchocnr_acc_B = qchocnr_acc_B(::-1)

;----------------------------------------------
; Convert from m3/s to 10**6 m3/s
;----------------------------------------------
 qchocnr_lat_A = qchocnr_lat_A/1.e6
 qchocnr_acc_A = qchocnr_acc_A/1.e6
 qchocnr_lat_B = qchocnr_lat_B/1.e6
 qchocnr_acc_B = qchocnr_acc_B/1.e6

 resL@tiMainString = timainstr(k)
 resL@trXMinF = xminl(k)
 resL@trXMaxF = xmaxl(k)
 resL@trYMinF = yminl(k)
 resL@trYMaxF = ymaxl(k)
 resL@tmXBMode = "Explicit"
 xvalues = fspan(xminl(k),xmaxl(k),divis(k))
 resL@tmXBValues = xvalues
 delete(xvalues)
 if (k .eq. 2) then
   resL@tmXBLabels = (/"60S"," ","40S"," ","20S"," ","0"," ","20N"," ","40N"/)
 else
   resL@tmXBLabels = (/"80S"," ","60S"," ","40S"," ","20S"," ","0"," ","20N"," ","40N"," ","60N"," ","80N"/)
 end if

 resR@tiYAxisString = tiyaxisstr(k)
 resR@trYMinF = yminr(k)
 resR@trYMaxF = ymaxr(k)
 resR@trXMinF = xminl(k)
 resR@trXMaxF = xmaxl(k)

 ydataR = new((/3,180/),"float")
 ydataR(0,:) = qchocnr_lat_A
 ydataR(1,:) = qchocnr_lat_B
 ydataR(2,:) = ann_disch_921riv(:,disch_id(k))
 ydataL = new((/3,180/),"float")
 ydataL(0,:) = qchocnr_acc_A
 ydataL(1,:) = qchocnr_acc_B
 ydataL(2,:) = acc_ann_disch_921riv(:,acc_disch_id(k))
;----------------------------------------------
; Open file for plots
;----------------------------------------------
 wks = gsn_open_wks(plot_type,wkdir+"set7_ann_disch_"+filestr(k))
 plot = plot_xy2(wks,x,ydataL,ydataR,resL,resR)
 legend = create "Legend" legendClass wks
   "vpXF"                     : 0.35
   "vpYF"                     : 0.10
   "vpWidthF"                 : 0.30
   "vpHeightF"                : 0.10
   "lgPerimOn"                : False
   "lgItemCount"              : 3
   "lgLabelsOn"               : True
   "lgLineLabelsOn"           : False
   "lgLabelStrings"           : (/label1,label2,"Largest 921 Rivers"/)
   "lgDashIndexes"            : (/0,0,0/)
   "lgLineColors"             : (/"red","blue","black"/)
   "lgMonoLineLabelFontColor" : True
   "lgAutoManage"             : False
   "lgLabelFontHeightF"       : 0.015
   "lgLabelPosition"          : "Right"
 end create
 draw(legend)
 frame(wks)
 delete(resL@tmXBValues)
 delete(resL@tmXBLabels)

 end do ; End loop over ocean basins

 delete(plot)
 delete(ocean_basin)
 delete(x)
 delete(timainstr)

;----------------------------------------------
; Start calculations for plots of monthly discharge
; into oceans
;----------------------------------------------

;----------------------------------------------
; ALWAYS OBS for plots of monthly discharge into oceans
;----------------------------------------------
 ptr_921riv_mon_disch = obsdata +"/dai_and_trenberth_921riv_mon_disch.asc"
 mon_disch_921riv = asciiread (ptr_921riv_mon_disch, (/months,6/), "float")

;----------------------------------------------
; Common resources for xy plots
;----------------------------------------------
 res                        = True
 res@tiXAxisString          = " "
 res@tiXAxisFontHeightF     = 0.040
 res@tiYAxisFontHeightF     = 0.040
 res@tiMainFontHeightF      = 0.045
 res@tmYLLabelFontHeightF   = 0.04
 res@tmXBLabelFontHeightF   = 0.04
 res@txFontHeightF = 0.045
 res@xyLineThicknesses       = (/2.,2.,1./)
 res@xyDashPatterns         = (/0.,0.,0./)          ; solid, dashed
 res@xyLineColors           = (/"red","blue","black"/)
 res@xyMonoLineColor = False
 x = ispan(1,months+1,1)
 x!0 = "month"
 res@trXMinF = 1
 res@trXMaxF = months+1
 res@tmXBMode = "Explicit"
 res@tmXBValues = x
 res@tmXBLabels = (/"J","F","M","A","M","J","J","A","S","O","N","D","J"/)
 res@tiYAxisString         = "Total Runoff (10~S~6~N~ m~S~3~N~ s~S~-1~N~)"
 ymin = (/0.0,0.0,0.0,0.00,0.0,0.6/)
 ymax = (/0.8,1.1,0.5,0.12,1.0,2.6/)
 timainstr = (/"Arctic Ocean", \
               "Atlantic Ocean", \
               "Indian Ocean", \
               "Med. & Black Seas", \
               "Pacific Ocean", \
               "Global Oceans"/)
;----------------------------------------------
; common resources for panel plots
;----------------------------------------------
 pan = True
 pan@gsnMaximize = True
 pan@gsnPaperOrientation = "portrait"
 pan@gsnFrame = False
 pan@txString = "Mean Annual Cycle of Freshwater Discharge"
 plot = new(6,"graphic")
 res@gsnDraw                = False               ; Do not draw plot
 res@gsnFrame               = False               ; Do not advance frame
 res@vpKeepAspect           = False
 res@vpWidthF               = 1.2
 ydata = new((/3,months+1/),"float")
;----------------------------------------------
; Open file for plots
;----------------------------------------------
 wks = gsn_open_wks(plot_type,wkdir+"set7_mon_disch")

 ocean_order = (/3,0,2,4,1,5/)

 ocean_basin = new(6,"integer")
 ocean_basin(0) = 4 ;arctic
 ocean_basin(1) = 1 ;atlantic
 ocean_basin(2) = 3 ;indian
 ocean_basin(3) = 5 ;med. & black sea
 ocean_basin(4) = 2 ;pacific
 ocean_basin(5) = 6 ;used to eliminate inland discharge from global ocean
;----------------------------------------------
; Loop over number of ocean basins (atlantic, pacific,
; indian, arctic, med. and black seas, global) 
;----------------------------------------------
 do k = 0,5
   tmp_A = new((/months,nlat,nlon/),"float")
   tmp_B = new((/months,nlat,nlon/),"float")
   qchocnr_mon_A = new(months,"float")
   qchocnr_mon_B = new(months,"float")

   do m = 0,months-1
     if (k .eq. 5) then
       tmp_A(m,:,:) = mask(qchocnr_mA(m,:,:),(ocean_basin_index .ne. ocean_basin(k)),True)
       tmp_B(m,:,:) = mask(qchocnr_mB(m,:,:),(ocean_basin_index .ne. ocean_basin(k)),True)
     else
       tmp_A(m,:,:) = mask(qchocnr_mA(m,:,:),ocean_basin_index,ocean_basin(k))
       tmp_B(m,:,:) = mask(qchocnr_mB(m,:,:),ocean_basin_index,ocean_basin(k))
     end if
     qchocnr_mon_A(m) = sum(tmp_A(m,:,:))
     qchocnr_mon_B(m) = sum(tmp_B(m,:,:))
   end do

; Convert from m3/s to 10**6 m3/s
   qchocnr_mon_A = qchocnr_mon_A/1.e6
   qchocnr_mon_B = qchocnr_mon_B/1.e6

   ydata(0,0:months-1) = qchocnr_mon_A(0:months-1)
   ydata(0,months)     = qchocnr_mon_A(0)
   ydata(1,0:months-1) = qchocnr_mon_B(0:months-1)
   ydata(1,months)     = qchocnr_mon_B(0)

   ydata(2,0:months-1) = mon_disch_921riv(:,ocean_order(k))
   ydata(2,months)     = mon_disch_921riv(0,ocean_order(k))
   
   res@trYMinF = ymin(k)
   res@trYMaxF = ymax(k)
   res@gsnCenterString = timainstr(k)
   plot(k) = gsn_csm_xy(wks,x,ydata(:,:),res)
   delete(tmp_A)
   delete(tmp_B)
   delete(qchocnr_mon_A)
   delete(qchocnr_mon_B)

 end do

 pan@gsnPanelBottom = 0.1
 gsn_panel(wks,plot,(/4,2/),pan)
 legend = create "Legend" legendClass wks
   "vpXF"                     : 0.375
   "vpYF"                     : 0.28
   "vpWidthF"                 : 0.25
   "vpHeightF"                : 0.14
   "lgPerimOn"                : False
   "lgItemCount"              : 3
   "lgLabelsOn"               : True
   "lgLineLabelsOn"           : False
   "lgLabelStrings"           : (/label1,label2,"Largest 921 Rivers"/)
   "lgDashIndexes"            : (/0,0,0/)
   "lgLineColors"             : (/"red","blue","black"/)
   "lgMonoLineLabelFontColor" : True
   "lgAutoManage"             : False
   "lgLabelFontHeightF"       : 0.01
   "lgLabelPosition"          : "Right"
 end create
 draw(legend)

 frame(wks)

;----------------------------------------------
; Plot ocean basin index over land
;----------------------------------------------
 delete(res)
 land_ocean_basin_index = ptr_ocean_basin_index->LAND_OCEAN_BASIN_INDEX
; Plot data
 res = True
 res@mpProjection = "Robinson"
 res@mpPerimOn    = False
 res@mpGridLineColor = "transparent" 
 res@cnRasterModeOn = True
 res@cnMissingValFillColor    = "white"
 res@cnFillOn = True
 res@cnLineLabelsOn = False
 res@lbLabelBarOn = True
 res@gsnFrame = True
 res@gsnMaximize = True
 res@gsnPaperOrientation = "landscape"
 res@mpGridLonSpacingF    = 60.0           ; Set lon grid spacing
 res@mpGridLatSpacingF    = 30.0           ; Set lat grid spacing
 res@mpFillOn = False
 res@mpOutlineOn = True
 res@mpGridAndLimbOn = True
 res@mpGridLineThicknessF   = 0.5          ; Set grid line thickness
 res@cnLinesOn            =  False
 res@cnLevelSelectionMode =  "ExplicitLevels"
 res@tiMainFont = "Helvetica"
 res@txFontHeightF = 0.015
 res@tiMainFontHeightF = 0.015
 res@lbBoxMinorExtentF = 0.15
 res@lbOrientation = "Horizontal"
 res@lbTitlePosition = "Bottom"
 res@lbLabelFontHeightF = 0.012
 res@lbTitleFontHeightF = 0.015
 res@lbLabelAlignment = "BoxCenters"
 res@lbLabelStrings = (/"Atlantic","Pacific","Indian","Arctic","Med&BlackSeas","Inland"/)
 res@pmLabelBarWidthF = 0.9
 res@gsnLeftString = ""
 res@gsnRightString = ""
 res@tiMainString   = "Ocean Basin Index at 0.5 degree (Dai and Trenberth 2002)"
 res@cnLevels = (/1.1,2.1,3.1,4.1,5.1/)
 wks = gsn_open_wks(plot_type,wkdir+"set7_ocean_basin_index")
 cmap = (/"(/1.00, 1.00, 1.00/)", "(/0.00, 0.00, 0.00/)","CadetBlue1","Blue","GreenYellow","Orange","Yellow","Red"/)
 gsn_define_colormap(wks, cmap )
 plot = gsn_csm_contour_map(wks, land_ocean_basin_index, res)
 delete(plot)
 delete(res)
 delete(cmap)

;----------------------------------------------
; Plot QCHANR
;----------------------------------------------
 qchanr_A!0 = "lat"
 qchanr_A&lat = lat
 qchanr_A!1 = "lon"
 qchanr_A&lon = lon
 res = True
 res@mpProjection = "Robinson"
 res@mpPerimOn    = False
 res@mpGridLineColor = "transparent" 
 res@cnFillOn = True
 res@cnLineLabelsOn = False
 res@lbLabelBarOn = True
 res@gsnMaximize = True
 res@mpGridLonSpacingF    = 60.0           ; Set lon grid spacing
 res@mpGridLatSpacingF    = 30.0           ; Set lat grid spacing
 res@mpFillOn = False
 res@mpOutlineOn = True
 res@mpGridAndLimbOn = True
 res@mpGridLineDashPattern =  2            ; Set grid line dash pattern (dash)
 res@mpGridLineThicknessF   = 0.5          ; Set grid line thickness
 res@cnLinesOn            =  False
 res@cnLevelSelectionMode =  "ExplicitLevels"
 res@tiMainFont = "Helvetica"
 res@lbTitleOn = True
 res@lbBoxMinorExtentF = 0.15
 res@lbLabelStride = 1
 res@cnMissingValFillColor = "Background"
 res@gsnDraw = True
 res@cnRasterModeOn = True
 res@txFontHeightF = 0.015
 res@tiMainFontHeightF = 0.015
 res@lbOrientation = "Horizontal"
 res@lbTitlePosition = "Bottom"
 res@lbLabelFontHeightF = 0.012
 res@pmLabelBarWidthF = 0.7
 res@lbTitleFontHeightF = 0.015
 res@gsnLeftString = qchanr_A@long_name
 res@gsnRightString = qchanr_A@units
 res@gsnCenterString = "Annual average"
 res@cnLevels             =  (/200.,400.,600.,800.,1000.,1200.,1400.,1700.,2000/)
 res@cnFillColors = (/0,2,4,5,6,7,8,9,10,11/)
 wks  = gsn_open_wks (plot_type,wkdir+"set7_"+"ANN_"+"QCHANR"+"_Ac")
 gsn_define_colormap(wks, "cosam" )
 min1 = min(qchanr_A)
 max1 = max(qchanr_A)
 qchanr_A = qchanr_A - 1.e-35
 res@lbTitleString = "MIN = "+sprintf("%6.4e",doubletofloat(min1))+ \
                     " MAX = "+sprintf("%6.4e",doubletofloat(max1))
 res@tiMainString            = case1+" (yrs "+yrs_ave1+") "
 plot = gsn_csm_contour_map(wks, qchanr_A, res)

 qchanr_B!0 = "lat"
 qchanr_B&lat = lat
 qchanr_B!1 = "lon"
 qchanr_B&lon = lon
 res@gsnLeftString = qchanr_B@long_name
 res@gsnRightString = qchanr_B@units
 wks  = gsn_open_wks (plot_type,wkdir+"set7_"+"ANN_"+"QCHANR"+"_Bc")
 gsn_define_colormap(wks, "cosam" )
 min1 = min(qchanr_B)
 max1 = max(qchanr_B)
 qchanr_B = qchanr_B - 1.e-35
 res@lbTitleString = "MIN = "+sprintf("%6.4e",doubletofloat(min1))+ \
                     " MAX = "+sprintf("%6.4e",doubletofloat(max1))
 res@tiMainString            = case2+" (yrs "+yrs_ave2+") "
 plot = gsn_csm_contour_map(wks, qchanr_B, res)

 print ("=========================================")
 print ("Finish Time: "+systemfunc("date") )
 print ("=========================================")

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set7_error_file"                   
  system("/bin/rm -f " + filo)  

end
