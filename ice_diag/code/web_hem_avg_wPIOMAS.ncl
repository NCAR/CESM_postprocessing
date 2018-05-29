load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

pre_proc_cont = getenv("PRE_PROC_ROOT_CONT")
pre_proc_diff = getenv("PRE_PROC_ROOT_DIFF")
wkdir = getenv("WKDIR")
diag_obs = getenv("DIAGOBSROOT")
yr1 = getenv("YR1")
yr2 = getenv("YR2")
yr1_diff = getenv("YR1_DIFF")
yr2_diff = getenv("YR2_DIFF")
wks_type = getenv("PLOT_FORMAT")
wks_type@wkWidth  = stringtointeger(getenv("PLOT_RES"))
wks_type@wkHeight = stringtointeger(getenv("PLOT_RES"))

xyr1 = stringtofloat(yr1)
xyr1_diff = stringtofloat(yr1_diff)
xyr2 = stringtofloat(yr2)
xyr2_diff = stringtofloat(yr2_diff)

; This version of the time series plots uses the offsets differently.
; Added flexibility allows the user to plot two time series of different
; lengths and offset the case in the x-direction as needed.

x1_off = stringtofloat(getenv("X1_OFF"))
x2_off = stringtofloat(getenv("X2_OFF"))

ix1_off = stringtoint(getenv("X1_OFF"))
ix2_off = stringtoint(getenv("X2_OFF"))

case_to_cont = getenv("CASE_TO_CONT")
f1 = addfile(pre_proc_cont+"/"+"ice_vol_"+case_to_cont+"_"+yr1+"-"+yr2+".nc","r")

plot_line_diff = getenv("PLOT_LINE_DIFF_LENS")
model_vs_model = getenv("MODEL_VS_MODEL")

;;if (plot_line_diff .eq. "True") then
if ((model_vs_model .eq. "True") .and. (plot_line_diff .eq. "True")) then
   case_to_diff = getenv("CASE_TO_DIFF")
   f2 = addfile(pre_proc_diff+"/"+"ice_vol_"+case_to_diff+"_"+yr1_diff+"-"+yr2_diff+".nc","r")
   case = case_to_cont+"-"+case_to_diff
   ncases = 2
else
   case = case_to_cont
   ncases = 1
end if


; get data from model files
vhi_mo_nh_1 = f1->vhi_mo_nh
time_1 = f1->time
time_1_all = cd_calendar(time_1,0)  ; note, the months are off by one based on time file was written
time_1_str = flt2string(time_1_all(:,0))+"-"+flt2string(time_1_all(:,1))

ndim = dimsizes(vhi_mo_nh_1)
ntimes = ndim(0)

vhi_data1 = new((/2,5,ntimes/12/),float)

ntimes_tot = ntimes

if (ncases .gt. 1) then

   vhi_mo_nh_2 = f2->vhi_mo_nh
   time_2 = f2->time
   time_2_all = cd_calendar(time_2,0)  ; note, the months are off by one based on time file was written
   time_2_str = flt2string(time_2_all(:,0))+"-"+flt2string(time_2_all(:,1))

   ndim = dimsizes(vhi_mo_nh_2)
   ntimes2 = ndim(0)

   ntimes_tot = max((/ntimes+ix1_off*12,ntimes2+ix2_off*12/))

   vhi_data2 = new((/2,5,ntimes2/12/),float)

end if

; get averages
vhi_mo_nh1 = onedtond(vhi_mo_nh_1,(/ntimes/12,12/))
vhi_mo_nh1!0 = "years"
vhi_mo_nh1!1 = "months"
vhi_data1(0,0,:) = dim_avg(vhi_mo_nh1)
vhi_data1(0,1,:) = dim_avg(vhi_mo_nh1(years|:,months|0:2))
vhi_data1(0,2,:) = dim_avg(vhi_mo_nh1(years|:,months|3:5))
vhi_data1(0,3,:) = dim_avg(vhi_mo_nh1(years|:,months|6:8))
vhi_data1(0,4,:) = dim_avg(vhi_mo_nh1(years|:,months|9:11))

if (ncases .gt. 1) then

vhi_mo_nh2 = onedtond(vhi_mo_nh_2,(/ntimes2/12,12/))
vhi_mo_nh2!0 = "years"
vhi_mo_nh2!1 = "months"
vhi_data2(0,0,:) = dim_avg(vhi_mo_nh2)
vhi_data2(0,1,:) = dim_avg(vhi_mo_nh2(years|:,months|0:2))
vhi_data2(0,2,:) = dim_avg(vhi_mo_nh2(years|:,months|3:5))
vhi_data2(0,3,:) = dim_avg(vhi_mo_nh2(years|:,months|6:8))
vhi_data2(0,4,:) = dim_avg(vhi_mo_nh2(years|:,months|9:11))

end if

; load and process PIOMAS data
data = asciiread(diag_obs+"/PIOMAS.vol.daily.1979.2017.Current.v2.1.dat",(/14143,3/),"float")
; fractional years
yy = data(:,0)
dd = data(:,1)  ; assumes 365 days/yr
vhi_dd_nh3 = data(:,2)/10.0   ; get units to match CESM units
nPIOMAS = 1

yr_all = ispan(floattoint(min(yy)),floattoint(max(yy)),1)
; get just years that correspond to CESM data
inds = ind((yr_all .ge. yr1) .and. (yr_all .le. yr2))
yr_3 = yr_all(inds)
delete(inds)
nyrs = dimsizes(yr_3)
mm_start_day = (/1,32,60,91,121,152,182,213,244,274,305,335,366/)  ; one extra than # months
nmonths = (dimsizes(mm_start_day)-1)
ntimes_PIOMAS = nyrs*nmonths

; get monthly averages for PIOMAS
vhi_mo_nh3 = new((/nyrs,nmonths/),typeof(vhi_dd_nh3))
vhi_mo_nh_3 = new((/ntimes_PIOMAS/),typeof(vhi_dd_nh3))
time_3_str = new((/ntimes_PIOMAS/),string)

y = 0
n = 0 
i = 0
do y = 0, nyrs - 1  ; do this for all but last year (2017) because it isn't a complete year
do m = 0, nmonths - 1
   inds = ind((yr_3(y) .eq. yy) .and. ((dd .ge. mm_start_day(m)) .and. (dd .lt. mm_start_day(m+1))))
   vhi_mo_nh3(y,m) = dim_avg_n(vhi_dd_nh3(inds),0)
   vhi_mo_nh_3(i) = dim_avg_n(vhi_dd_nh3(inds),0)
   time_3_str(i) = tostring(yr_3(y))+"-"+tostring(m+1)
   delete(inds)
   i = i + 1
end do
end do

; convert yr array to float for later
dum = int2flt(yr_3)
delete(yr_3)
yr_3 = dum
delete(dum)

; get averages
vhi_data3 = new((/2,nPIOMAS,5,nyrs/),float)
vhi_mo_nh3 = onedtond(vhi_mo_nh3,(/nyrs,12/))
vhi_mo_nh3!0 = "years"
vhi_mo_nh3!1 = "months"
vhi_data3(0,:,0,:) = dim_avg(vhi_mo_nh3)
vhi_data3(0,:,1,:) = dim_avg(vhi_mo_nh3(years|:,months|0:2))
vhi_data3(0,:,2,:) = dim_avg(vhi_mo_nh3(years|:,months|3:5))
vhi_data3(0,:,3,:) = dim_avg(vhi_mo_nh3(years|:,months|6:8))
vhi_data3(0,:,4,:) = dim_avg(vhi_mo_nh3(years|:,months|9:11))


; plotting the data -- annual and seasonal averages

plotname  = new((/2,5/),string)
title     = new((/2,5/),string)

title(0,0) = "ANN Mean PIOMAS and "+case
title(0,1) = "JFM Mean PIOMAS and "+case
title(0,2) = "AMJ Mean PIOMAS and "+case
title(0,3) = "JAS Mean PIOMAS and "+case
title(0,4) = "OND Mean PIOMAS and "+case

title(1,0) = "ANN Mean PIOMAS and "+case
title(1,1) = "JFM Mean PIOMAS and "+case
title(1,2) = "AMJ Mean PIOMAS and "+case
title(1,3) = "JAS Mean PIOMAS and "+case
title(1,4) = "OND Mean PIOMAS and "+case

if (ncases .gt. 1) then

   plotname(0,0) = "line_avg_PIOMAS_ANN_NH_diff"
   plotname(0,1) = "line_avg_PIOMAS_JFM_NH_diff"
   plotname(0,2) = "line_avg_PIOMAS_AMJ_NH_diff"
   plotname(0,3) = "line_avg_PIOMAS_JAS_NH_diff"
   plotname(0,4) = "line_avg_PIOMAS_OND_NH_diff"

   plotname(1,0) = "line_avg_PIOMAS_ANN_SH_diff"
   plotname(1,1) = "line_avg_PIOMAS_JFM_SH_diff"
   plotname(1,2) = "line_avg_PIOMAS_AMJ_SH_diff"
   plotname(1,3) = "line_avg_PIOMAS_JAS_SH_diff"
   plotname(1,4) = "line_avg_PIOMAS_OND_SH_diff"
else
   plotname(0,0) = "line_avg_PIOMAS_ANN_NH"
   plotname(0,1) = "line_avg_PIOMAS_JFM_NH"
   plotname(0,2) = "line_avg_PIOMAS_AMJ_NH"
   plotname(0,3) = "line_avg_PIOMAS_JAS_NH"
   plotname(0,4) = "line_avg_PIOMAS_OND_NH"

   plotname(1,0) = "line_avg_PIOMAS_ANN_SH"
   plotname(1,1) = "line_avg_PIOMAS_JFM_SH"
   plotname(1,2) = "line_avg_PIOMAS_AMJ_SH"
   plotname(1,3) = "line_avg_PIOMAS_JAS_SH"
   plotname(1,4) = "line_avg_PIOMAS_OND_SH"
end if

resP = True
resP@gsnMaximize         = True
resP@gsnPaperOrientation = "portrait"
resP@txFont              = "helvetica"
resP@txFontHeightF       = 0.012 ;0.015
resP@txFuncCode          = "~"

resP@gsnPanelYWhiteSpacePercent = 0.0

res = True
res@gsnDraw = False
res@gsnFrame = False
res@txFont   = "helvetica"
res@txFuncCode = "~"
res@txFontHeightF   = 0.015
res@tiXAxisFont          = "helvetica"
res@tiXAxisFontHeightF   = 0.015
res@tiXAxisFuncCode          = "~"
res@tiYAxisFont          = "helvetica"
res@tiYAxisFontHeightF   = 0.015
res@tiYAxisFuncCode          = "~"
res@tmXBLabelFont          = "helvetica"
res@tmYLLabelFont          = "helvetica"

res@vpHeightF = 0.2
res@vpWidthF = 0.9

do iseas=0,4
ihem = 0   ; just NH for now
;do ihem=0,1

resP@txString = title(ihem,iseas)
;resP@txPosYF  = 1.

   if (ncases .gt. 1) then

      ; arrays to plot against
      x1 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + xyr1      - x1_off
      x2 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + xyr1_diff - x2_off

      ; non-PIOMAS resources
      res = res
      res@xyLineThicknesses = (/5/)
      res@xyDashPatterns    = (/0/)
      res@xyLineColors      = (/"blue"/)

      ; ice volume resources
      resv = res
      delete([/resv@xyLineThicknesses, resv@xyDashPatterns, resv@xyLineColors/])
 
      ; dummy variables for the big array of PIOMAS data
      dumi = new((/nPIOMAS+1/),integer)
      dums = new((/nPIOMAS+1/),string)
      ts = dumi
      ts = 5
      resv@xyLineThicknesses = ts
      delete(ts)
      ps = dumi
      ps = 0
      resv@xyDashPatterns    = ps
      delete(ps)
      cs = dums
      cs = "black"
      cs(nPIOMAS) = "blue"
      resv@xyLineColors = cs
      delete(cs)

      resb = res
      delete([/resb@xyLineThicknesses, resb@xyDashPatterns, resb@xyLineColors/])
      resb@xyLineThicknesses = (/5/)
      resb@xyDashPatterns    = (/0/)
      resb@xyLineColors      = (/"red"/)

      ; get indices where PIOMAS is available for this dataset
      ; array of "good" data indices
      dum1 = x1
      dum1@_FillValue = -999.9
      dum1 = where(dum1 .lt. min(yr_3), dum1@_FillValue, dum1)
      inds1 = ind(.not.ismissing(dum1))
      ; array of "good" PIOMAS indices
      dum2 = yr_3
      dum2@_FillValue = -999.9
      dum2 = where(dum2 .gt. max(x1), dum2@_FillValue, dum2)
      inds2 = ind(.not.ismissing(dum2))

      ; fill in arrays
      y1   = new((/nPIOMAS+1,ntimes_tot/12/),float)
      y1b  = new((/ntimes_tot/12/),float)
      y1   = -999.
      y1b  = -999.

      y1(0:nPIOMAS-1,inds1(0):ntimes/12-1+ix1_off) = (/vhi_data3(ihem,0:nPIOMAS-1,iseas,0:inds2(max(inds2)))/)
      y1(nPIOMAS,ix1_off:ntimes/12-1+ix1_off)  = (/vhi_data1(ihem,iseas,:)/)

      y1b(ix2_off:ntimes2/12-1+ix2_off) = vhi_data2(ihem,iseas,:)

   else
      ; array to plot against
      x1 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + stringtofloat(yr1)

      ; non-PIOMAS resources
      res = res
      res@xyLineThicknesses = (/5/)
      res@xyDashPatterns    = (/0/)
      res@xyLineColors      = (/"blue"/)
      res@trXMinF = min((/x1/))
      res@trXMaxF = max((/x1/))

      ; ice volume resources
      resv = res
      delete([/resv@xyLineThicknesses, resv@xyDashPatterns, resv@xyLineColors/])
 
      ; dummy variables for the big array of PIOMAS data
      dumi = new((/nPIOMAS+1/),integer)
      dums = new((/nPIOMAS+1/),string)
      ts = dumi
      ts = 5
      resv@xyLineThicknesses = ts
      delete(ts)
      ps = dumi
      ps = 0
      resv@xyDashPatterns    = ps
      delete(ps)
      cs = dums
      cs = "black"
      cs(nPIOMAS) = "blue"
      resv@xyLineColors = cs
      delete(cs)

      ; get indices where PIOMAS is available for this dataset
      ; array of "good" data indices
      dum1 = x1
      dum1@_FillValue = -999.9
      dum1 = where(dum1 .lt. min(yr_3), dum1@_FillValue, dum1)
      inds1 = ind(.not.ismissing(dum1))
      ; array of "good" PIOMAS indices
      dum2 = yr_3
      dum2@_FillValue = -999.9
      dum2 = where(dum2 .gt. max(x1), dum2@_FillValue, dum2)
      inds2 = ind(.not.ismissing(dum2))

      y1   = new((/nPIOMAS+1,ntimes_tot/12/),float)
      y1   = -999.

      y1(0:nPIOMAS-1,inds1(0):ntimes/12-1+ix1_off) = (/vhi_data3(ihem,0:nPIOMAS-1,iseas,0:inds2(max(inds2)))/)
      y1(nPIOMAS,ix1_off:ntimes/12-1+ix1_off)  = (/vhi_data1(ihem,iseas,:)/)

   end if

wks1 = gsn_open_wks(wks_type,wkdir + plotname(ihem,iseas))

if (ihem .eq. 0) then
   y1@long_name = "NH Ice Volume 10~S~13~N~ m~S~3~N~"
else
   y1@long_name = "SH Ice Volume 10~S~13~N~ m~S~3~N~"
end if

y1@_FillValue = -999.
x1@units = "years"
x1@long_name = "Years"

resv@tmXMajorGrid = True
;resv@tmYMajorGrid = True
resv@tmXMajorGridLineDashPattern = 2
;resv@tmYMajorGridLineDashPattern = 2
resv@tmXMajorGridThicknessF = 1
;resv@tmYMajorGridThicknessF = 1

if (ncases .gt. 1) then
   resv@gsnRightString = case_to_cont
   resv@gsnRightStringFontColor = "blue"
   resv@gsnCenterString = "PIOMAS"
   resv@gsnCenterStringFontColor = "black"
   resv@gsnLeftString = case_to_diff
   resv@gsnLeftStringFontColor = "red"

   y1b@_FillValue = -999.
   x2@units = "years"
   x2@long_name = "Years"

   resv@tmXBLabelFontColor = "blue"

   resv@trYMinF = min((/min(y1),min(y1b)/))
   resv@trYMaxF = max((/max(y1),max(y1b)/))
   resb@trYMinF = min((/min(y1),min(y1b)/))
   resb@trYMaxF = max((/max(y1),max(y1b)/))

   resb@gsnRightString = " "
   resb@gsnLeftString = " "
   resb@tmXTLabelFontColor = "red"
   resb@tmYROn = False
   resb@tmXMajorGrid = False
   ;resb@tmYMajorGrid = False

   resv@trXMinF = min((/min(x1),min(x1)/))
   resv@trXMaxF = max((/max(x1),max(x1)/))
   resb@trXMinF = min((/min(x2),min(x2)/))
   resb@trXMaxF = max((/max(x2),max(x2)/))

   plot1 = gsn_csm_x2y2(wks1,x1,x2,y1,y1b,resv,resb)

   resv@trXMinF = 1979. 
   resb@trXMinF = 1979.
   plot2 = gsn_csm_x2y2(wks1,x1,x2,y1,y1b,resv,resb)

else
   plot1 = gsn_csm_xy(wks1,x1,y1,resv)

   resv@trXMinF = 1979.
   plot2 = gsn_csm_xy(wks1,x1,y1,resv)
end if

gsn_panel(wks1,(/plot1,plot2/),(/2,1/),resP)
;drawNDCGrid(wks1)
;frame(wks1)

delete(y1)
delete(x1)
delete(resP@txString)

if (ncases .gt. 1) then
   delete(x2)
   delete(y1b)
end if

;end do  ; ihem loop

end do
print("Finished annual and seasonal plots")


; plotting the data -- monthly means

delete([/plotname,title,resP,res,resv/])
plotname  = new((/2,1/),string)
title     = new((/2,1/),string)

title(0,0) = "Monthly Mean PIOMAS and "+case
title(1,0) = "Monthly Mean PIOMAS and "+case

if (ncases .gt. 1) then
   plotname(0,0) = "line_avg_PIOMAS_mon_NH_diff"
   plotname(1,0) = "line_avg_PIOMAS_mon_SH_diff"
else
   plotname(0,0) = "line_avg_PIOMAS_mon_NH"
   plotname(1,0) = "line_avg_PIOMAS_mon_SH"
end if

resP = True
resP@gsnMaximize         = True
resP@gsnPaperOrientation = "portrait"
resP@txFont              = "helvetica"
resP@txFontHeightF       = 0.012 ;0.015
resP@txFuncCode          = "~"

resP@gsnPanelYWhiteSpacePercent = 0.0

res = True
res@gsnDraw = False
res@gsnFrame = False
res@txFont   = "helvetica"
res@txFuncCode = "~"
res@txFontHeightF   = 0.015
res@tiXAxisFont          = "helvetica"
res@tiXAxisFontHeightF   = 0.015
res@tiXAxisFuncCode          = "~"
res@tiYAxisFont          = "helvetica"
res@tiYAxisFontHeightF   = 0.015
res@tiYAxisFuncCode          = "~"
res@tmXBLabelFont          = "helvetica"
res@tmYLLabelFont          = "helvetica"

res@vpHeightF = 0.2
res@vpWidthF = 0.9

ihem = 0   ; just NH for now
;do ihem=0,1

resP@txString = title(ihem,0)
;resP@txPosYF  = 1.

      res = res
      res@xyLineThicknesses = (/5/)
      res@xyDashPatterns    = (/0/)
      res@xyLineColors      = (/"blue"/)

      ; Non-PIOMAS resources
      resv = res
      delete([/resv@xyLineThicknesses, resv@xyDashPatterns, resv@xyLineColors/])
 
      ; dummy variables for the big array of PIOMAS data
      dumi = new((/nPIOMAS+1/),integer)
      dums = new((/nPIOMAS+1/),string)
      ts = dumi
      ts = 5
      resv@xyLineThicknesses = ts
      delete(ts)
      ps = dumi
      ps = 0
      resv@xyDashPatterns    = ps
      delete(ps)
      cs = dums
      cs = "blue"
      cs(nPIOMAS) = "red"
      resv@xyLineColors = cs
      delete(cs)

      ; PIOMAS resources
      resb = res
      delete([/resb@xyLineThicknesses, resb@xyDashPatterns, resb@xyLineColors/])
      resb@xyLineThicknesses = (/5/)
      resb@xyDashPatterns    = (/0/)
      resb@xyLineColors      = (/"black"/)

; CESM arrays
; time array
  x1 = fspan(xyr1,(xyr2+1),(ntimes+1))  ; CESM array, one bigger than total points for January of final year

; values (y array)
   if (ncases .gt. 1) then
      ; note, assumes both CESM arrays are the same size. if not this will fail
      ; fill in to plot with arrays
      y1   = new((/nPIOMAS+1,(ntimes_tot+1)/),float)
      y1   = -999.
      y1(0:nPIOMAS-1,0:ntimes_tot-1) = (/vhi_mo_nh_1/)
      y1(nPIOMAS,0:ntimes_tot-1)  = (/vhi_mo_nh_2/)

   else
      case_to_diff = ""
      ; fill in to plot with arrays
      y1   = new((/(ntimes_tot+1)/),float)
      y1   = -999.
      y1(0:ntimes_tot-1)  = (/vhi_mo_nh_1/)

   end if

; piomas arrays 
; time array
  ; get matching times for PIOMAS
  inds = ind((x1.ge.1979.0).and.(x1.le.2017.0))
  x2 = x1(inds)  ; PIOMAS array
  delete(inds)     

; values (y array)
y2  = new((/ntimes_PIOMAS+1/),float)
y2(0:ntimes_PIOMAS-1) = (/vhi_mo_nh_3/)


; actual plotting

wks1 = gsn_open_wks(wks_type,wkdir + plotname(ihem,0))

if (ihem .eq. 0) then
   y1@long_name = "NH Ice Volume 10~S~13~N~ m~S~3~N~"
else
   y1@long_name = "SH Ice Volume 10~S~13~N~ m~S~3~N~"
end if

y1@_FillValue = -999.
x1@units = "years"
x1@long_name = "Years"

x2@units = "years"
x2@long_name = "Years"

resv@tmXMajorGrid = True
;resv@tmYMajorGrid = True
resv@tmXMajorGridLineDashPattern = 2
;resv@tmYMajorGridLineDashPattern = 2
resv@tmXMajorGridThicknessF = 1
;resv@tmYMajorGridThicknessF = 1

resv@gsnRightString = case_to_cont
resv@gsnRightStringFontColor = "blue"
resv@gsnCenterString = "PIOMAS"
resv@gsnCenterStringFontColor = "black"
resv@gsnLeftString = case_to_diff
resv@gsnLeftStringFontColor = "red"

resv@tmXBLabelFontColor = "blue"

resv@trYMinF = min((/min(y1),min(y2)/))
resv@trYMaxF = max((/max(y1),max(y2)/))
resb@trYMinF = resv@trYMinF
resb@trYMaxF = resv@trYMaxF

resb@gsnRightString = " "
resb@gsnLeftString = " "
resb@tmXTLabelFontColor = "black"
resb@tmYROn = False
resb@tmXMajorGrid = False
;resb@tmYMajorGrid = False

resv@trXMinF = min((/min(x1),min(x2)/))
resv@trXMaxF = max((/max(x1),max(x1)/))
resb@trXMinF = min((/min(x1),min(x2)/))
resb@trXMaxF = max((/max(x1),max(x1)/))

   plot1 = gsn_csm_x2y2(wks1,x1,x2,y1,y2,resv,resb)

   resv@trXMinF = 1979. 
   resb@trXMinF = 1979.
   plot2 = gsn_csm_x2y2(wks1,x1,x2,y1,y2,resv,resb)


gsn_panel(wks1,(/plot1,plot2/),(/2,1/),resP)
;drawNDCGrid(wks1)
;frame(wks1)

delete(y1)
delete(x1)
delete(resP@txString)

if (ncases .gt. 1) then
   delete(x2)
   delete(y2)
end if

;end do  ; ihem loop
print("Finished monthly plots")

print("Finished PIOMAS figures, yay!")
end
