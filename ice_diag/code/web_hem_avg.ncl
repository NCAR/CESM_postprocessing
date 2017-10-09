
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

pre_proc_cont = getenv("PRE_PROC_ROOT_CONT")
pre_proc_diff = getenv("PRE_PROC_ROOT_DIFF")
wkdir = getenv("WKDIR")
yr1 = getenv("YR1")
yr2 = getenv("YR2")
yr1_diff = getenv("YR1_DIFF")
yr2_diff = getenv("YR2_DIFF")
wks_type = getenv("PLOT_FORMAT")
wks_type@wkWidth  = stringtointeger(getenv("PLOT_RES"))
wks_type@wkHeight = stringtointeger(getenv("PLOT_RES"))

xyr1 = stringtofloat(yr1)
xyr1_diff = stringtofloat(yr1_diff)

; This version of the time series plots uses the offsets differently.
; Added flexibility allows the user to plot two time series of different
; lengths and offset the case in the x-direction as needed.

x1_off = stringtofloat(getenv("X1_OFF"))
x2_off = stringtofloat(getenv("X2_OFF"))

ix1_off = stringtoint(getenv("X1_OFF"))
ix2_off = stringtoint(getenv("X2_OFF"))

case_to_cont = getenv("CASE_TO_CONT")
f1 = addfile(pre_proc_cont+"/"+"ice_vol_"+case_to_cont+"_"+yr1+"-"+yr2+".nc","r")

plot_line_diff = getenv("PLOT_LINE_DIFF")
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



vhi_mo_nh_1 = f1->vhi_mo_nh
vai_mo_nh_1 = f1->vai_mo_nh
vhs_mo_nh_1 = f1->vhs_mo_nh
vhi_mo_sh_1 = f1->vhi_mo_sh
vai_mo_sh_1 = f1->vai_mo_sh
vhs_mo_sh_1 = f1->vhs_mo_sh

ndim = dimsizes(vhi_mo_nh_1)
ntimes = ndim(0)

vhi_data1 = new((/2,5,ntimes/12/),float)
vai_data1 = new((/2,5,ntimes/12/),float)

vhs_data1 = new((/2,5,ntimes/12/),float)

ntimes_tot = ntimes

if (ncases .gt. 1) then

   vhi_mo_nh_2 = f2->vhi_mo_nh
   vai_mo_nh_2 = f2->vai_mo_nh
   vhs_mo_nh_2 = f2->vhs_mo_nh
   vhi_mo_sh_2 = f2->vhi_mo_sh
   vai_mo_sh_2 = f2->vai_mo_sh
   vhs_mo_sh_2 = f2->vhs_mo_sh

   ndim = dimsizes(vhi_mo_nh_2)
   ntimes2 = ndim(0)

   ntimes_tot = max((/ntimes+ix1_off*12,ntimes2+ix2_off*12/))

   vhi_data2 = new((/2,5,ntimes2/12/),float)
   vai_data2 = new((/2,5,ntimes2/12/),float)
   vhs_data2 = new((/2,5,ntimes2/12/),float)

end if

vhi_mo_nh1 = onedtond(vhi_mo_nh_1,(/ntimes/12,12/))
vhi_mo_nh1!0 = "years"
vhi_mo_nh1!1 = "months"
vhi_data1(0,0,:) = dim_avg(vhi_mo_nh1)
vhi_data1(0,1,:) = dim_avg(vhi_mo_nh1(years|:,months|0:2))
vhi_data1(0,2,:) = dim_avg(vhi_mo_nh1(years|:,months|3:5))
vhi_data1(0,3,:) = dim_avg(vhi_mo_nh1(years|:,months|6:8))
vhi_data1(0,4,:) = dim_avg(vhi_mo_nh1(years|:,months|9:11))

vhs_mo_nh1 = onedtond(vhs_mo_nh_1,(/ntimes/12,12/))
vhs_mo_nh1!0 = "years"
vhs_mo_nh1!1 = "months"
vhs_data1(0,0,:) = dim_avg(vhs_mo_nh1)
vhs_data1(0,1,:) = dim_avg(vhs_mo_nh1(years|:,months|0:2))
vhs_data1(0,2,:) = dim_avg(vhs_mo_nh1(years|:,months|3:5))
vhs_data1(0,3,:) = dim_avg(vhs_mo_nh1(years|:,months|6:8))
vhs_data1(0,4,:) = dim_avg(vhs_mo_nh1(years|:,months|9:11))

vai_mo_nh1 = onedtond(vai_mo_nh_1,(/ntimes/12,12/))
vai_mo_nh1!0 = "years"
vai_mo_nh1!1 = "months"
vai_data1(0,0,:) = dim_avg(vai_mo_nh1)
vai_data1(0,1,:) = dim_avg(vai_mo_nh1(years|:,months|0:2))
vai_data1(0,2,:) = dim_avg(vai_mo_nh1(years|:,months|3:5))
vai_data1(0,3,:) = dim_avg(vai_mo_nh1(years|:,months|6:8))
vai_data1(0,4,:) = dim_avg(vai_mo_nh1(years|:,months|9:11))

vhi_mo_sh1 = onedtond(vhi_mo_sh_1,(/ntimes/12,12/))
vhi_mo_sh1!0 = "years"
vhi_mo_sh1!1 = "months"
vhi_data1(1,0,:) = dim_avg(vhi_mo_sh1)
vhi_data1(1,1,:) = dim_avg(vhi_mo_sh1(years|:,months|0:2))
vhi_data1(1,2,:) = dim_avg(vhi_mo_sh1(years|:,months|3:5))
vhi_data1(1,3,:) = dim_avg(vhi_mo_sh1(years|:,months|6:8))
vhi_data1(1,4,:) = dim_avg(vhi_mo_sh1(years|:,months|9:11))

vhs_mo_sh1 = onedtond(vhs_mo_sh_1,(/ntimes/12,12/))
vhs_mo_sh1!0 = "years"
vhs_mo_sh1!1 = "months"
vhs_data1(1,0,:) = dim_avg(vhs_mo_sh1)
vhs_data1(1,1,:) = dim_avg(vhs_mo_sh1(years|:,months|0:2))
vhs_data1(1,2,:) = dim_avg(vhs_mo_sh1(years|:,months|3:5))
vhs_data1(1,3,:) = dim_avg(vhs_mo_sh1(years|:,months|6:8))
vhs_data1(1,4,:) = dim_avg(vhs_mo_sh1(years|:,months|9:11))

vai_mo_sh1 = onedtond(vai_mo_sh_1,(/ntimes/12,12/))
vai_mo_sh1!0 = "years"
vai_mo_sh1!1 = "months"
vai_data1(1,0,:) = dim_avg(vai_mo_sh1)
vai_data1(1,1,:) = dim_avg(vai_mo_sh1(years|:,months|0:2))
vai_data1(1,2,:) = dim_avg(vai_mo_sh1(years|:,months|3:5))
vai_data1(1,3,:) = dim_avg(vai_mo_sh1(years|:,months|6:8))
vai_data1(1,4,:) = dim_avg(vai_mo_sh1(years|:,months|9:11))

if (ncases .gt. 1) then

vhi_mo_nh2 = onedtond(vhi_mo_nh_2,(/ntimes2/12,12/))
vhi_mo_nh2!0 = "years"
vhi_mo_nh2!1 = "months"
vhi_data2(0,0,:) = dim_avg(vhi_mo_nh2)
vhi_data2(0,1,:) = dim_avg(vhi_mo_nh2(years|:,months|0:2))
vhi_data2(0,2,:) = dim_avg(vhi_mo_nh2(years|:,months|3:5))
vhi_data2(0,3,:) = dim_avg(vhi_mo_nh2(years|:,months|6:8))
vhi_data2(0,4,:) = dim_avg(vhi_mo_nh2(years|:,months|9:11))

vhs_mo_nh2 = onedtond(vhs_mo_nh_2,(/ntimes2/12,12/))
vhs_mo_nh2!0 = "years"
vhs_mo_nh2!1 = "months"
vhs_data2(0,0,:) = dim_avg(vhs_mo_nh2)
vhs_data2(0,1,:) = dim_avg(vhs_mo_nh2(years|:,months|0:2))
vhs_data2(0,2,:) = dim_avg(vhs_mo_nh2(years|:,months|3:5))
vhs_data2(0,3,:) = dim_avg(vhs_mo_nh2(years|:,months|6:8))
vhs_data2(0,4,:) = dim_avg(vhs_mo_nh2(years|:,months|9:11))

vai_mo_nh2 = onedtond(vai_mo_nh_2,(/ntimes2/12,12/))
vai_mo_nh2!0 = "years"
vai_mo_nh2!1 = "months"
vai_data2(0,0,:) = dim_avg(vai_mo_nh2)
vai_data2(0,1,:) = dim_avg(vai_mo_nh2(years|:,months|0:2))
vai_data2(0,2,:) = dim_avg(vai_mo_nh2(years|:,months|3:5))
vai_data2(0,3,:) = dim_avg(vai_mo_nh2(years|:,months|6:8))
vai_data2(0,4,:) = dim_avg(vai_mo_nh2(years|:,months|9:11))

vhi_mo_sh2 = onedtond(vhi_mo_sh_2,(/ntimes2/12,12/))
vhi_mo_sh2!0 = "years"
vhi_mo_sh2!1 = "months"
vhi_data2(1,0,:) = dim_avg(vhi_mo_sh2)
vhi_data2(1,1,:) = dim_avg(vhi_mo_sh2(years|:,months|0:2))
vhi_data2(1,2,:) = dim_avg(vhi_mo_sh2(years|:,months|3:5))
vhi_data2(1,3,:) = dim_avg(vhi_mo_sh2(years|:,months|6:8))
vhi_data2(1,4,:) = dim_avg(vhi_mo_sh2(years|:,months|9:11))

vhs_mo_sh2 = onedtond(vhs_mo_sh_2,(/ntimes2/12,12/))
vhs_mo_sh2!0 = "years"
vhs_mo_sh2!1 = "months"
vhs_data2(1,0,:) = dim_avg(vhs_mo_sh2)
vhs_data2(1,1,:) = dim_avg(vhs_mo_sh2(years|:,months|0:2))
vhs_data2(1,2,:) = dim_avg(vhs_mo_sh2(years|:,months|3:5))
vhs_data2(1,3,:) = dim_avg(vhs_mo_sh2(years|:,months|6:8))
vhs_data2(1,4,:) = dim_avg(vhs_mo_sh2(years|:,months|9:11))

vai_mo_sh2 = onedtond(vai_mo_sh_2,(/ntimes2/12,12/))
vai_mo_sh2!0 = "years"
vai_mo_sh2!1 = "months"
vai_data2(1,0,:) = dim_avg(vai_mo_sh2)
vai_data2(1,1,:) = dim_avg(vai_mo_sh2(years|:,months|0:2))
vai_data2(1,2,:) = dim_avg(vai_mo_sh2(years|:,months|3:5))
vai_data2(1,3,:) = dim_avg(vai_mo_sh2(years|:,months|6:8))
vai_data2(1,4,:) = dim_avg(vai_mo_sh2(years|:,months|9:11))

end if

ice_mon_area_nh = fspan(1,1,ntimes_tot)*-999.
ice_mon_area_nh@_FillValue = -999.
ice_mon_area_nh(ntimes_tot-12:ntimes_tot-1) =  \
   (/11.5471, 12.2401, 12.3798, 11.7942, 10.5622, 9.10205, \
     6.77052, 5.45986, 5.20947, 6.79627, 8.82731, 10.3631 /)
ice_max_area_nh = fspan(1,1,ntimes_tot)*max(ice_mon_area_nh)
ice_min_area_nh = fspan(1,1,ntimes_tot)*min(ice_mon_area_nh)

ice_mon_area_sh = fspan(1,1,ntimes_tot)*-999.
ice_mon_area_sh@_FillValue = -999.
ice_mon_area_sh(ntimes_tot-12:ntimes_tot-1) = \
   (/ 2.77545, 2.13688, 3.21481, 5.63966, 8.36514, 10.9483, \
     13.1488, 14.2961, 14.5287, 13.3955, 10.3602, 5.96624 /)
ice_max_area_sh = fspan(1,1,ntimes_tot)*max(ice_mon_area_sh)
ice_min_area_sh = fspan(1,1,ntimes_tot)*min(ice_mon_area_sh)

plotname  = new((/2,6/),string)
plotname2 = new((/2,5/),string)
title     = new((/2,6/),string)
title2    = new((/2,5/),string)

title(0,0) = "ANN Mean "+case
title(0,1) = "JFM Mean "+case
title(0,2) = "AMJ Mean "+case
title(0,3) = "JAS Mean "+case
title(0,4) = "OND Mean "+case
title(0,5) = case

title2(0,0) = "ANN Anomalies "+case
title2(0,1) = "JFM Anomalies "+case
title2(0,2) = "AMJ Anomalies "+case
title2(0,3) = "JAS Anomalies "+case
title2(0,4) = "OND Anomalies "+case

title(1,0) = "ANN Mean "+case
title(1,1) = "JFM Mean "+case
title(1,2) = "AMJ Mean "+case
title(1,3) = "JAS Mean "+case
title(1,4) = "OND Mean "+case
title(1,5) = case

title2(1,0) = "ANN Anomalies "+case
title2(1,1) = "JFM Anomalies "+case
title2(1,2) = "AMJ Anomalies "+case
title2(1,3) = "JAS Anomalies "+case
title2(1,4) = "OND Anomalies "+case

if (ncases .gt. 1) then
   plotname(0,0) = "line_avg_ANN_NH_diff"
   plotname(0,1) = "line_avg_JFM_NH_diff"
   plotname(0,2) = "line_avg_AMJ_NH_diff"
   plotname(0,3) = "line_avg_JAS_NH_diff"
   plotname(0,4) = "line_avg_OND_NH_diff"
   plotname(0,5) = "line_mo_NH_diff"

   plotname2(0,0) = "line_var_ANN_NH_diff"
   plotname2(0,1) = "line_var_JFM_NH_diff"
   plotname2(0,2) = "line_var_AMJ_NH_diff"
   plotname2(0,3) = "line_var_JAS_NH_diff"
   plotname2(0,4) = "line_var_OND_NH_diff"

   plotname(1,0) = "line_avg_ANN_SH_diff"
   plotname(1,1) = "line_avg_JFM_SH_diff"
   plotname(1,2) = "line_avg_AMJ_SH_diff"
   plotname(1,3) = "line_avg_JAS_SH_diff"
   plotname(1,4) = "line_avg_OND_SH_diff"
   plotname(1,5) = "line_mo_SH_diff"

   plotname2(1,0) = "line_var_ANN_SH_diff"
   plotname2(1,1) = "line_var_JFM_SH_diff"
   plotname2(1,2) = "line_var_AMJ_SH_diff"
   plotname2(1,3) = "line_var_JAS_SH_diff"
   plotname2(1,4) = "line_var_OND_SH_diff"
else
   plotname(0,0) = "line_avg_ANN_NH"
   plotname(0,1) = "line_avg_JFM_NH"
   plotname(0,2) = "line_avg_AMJ_NH"
   plotname(0,3) = "line_avg_JAS_NH"
   plotname(0,4) = "line_avg_OND_NH"
   plotname(0,5) = "line_mo_NH"

   plotname2(0,0) = "line_var_ANN_NH"
   plotname2(0,1) = "line_var_JFM_NH"
   plotname2(0,2) = "line_var_AMJ_NH"
   plotname2(0,3) = "line_var_JAS_NH"
   plotname2(0,4) = "line_var_OND_NH"

   plotname(1,0) = "line_avg_ANN_SH"
   plotname(1,1) = "line_avg_JFM_SH"
   plotname(1,2) = "line_avg_AMJ_SH"
   plotname(1,3) = "line_avg_JAS_SH"
   plotname(1,4) = "line_avg_OND_SH"
   plotname(1,5) = "line_mo_SH"

   plotname2(1,0) = "line_var_ANN_SH"
   plotname2(1,1) = "line_var_JFM_SH"
   plotname2(1,2) = "line_var_AMJ_SH"
   plotname2(1,3) = "line_var_JAS_SH"
   plotname2(1,4) = "line_var_OND_SH"
end if

resP = True
resP@gsnMaximize         = True
resP@gsnPaperOrientation = "portrait"
resP@txFont              = "helvetica"
resP@txFontHeightF   = 0.015
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

do iseas=0,5

climatol = False
if (iseas .eq. 5) then
   climatol = True
end if

do ihem=0,1

resP@txString = title(ihem,iseas)
;resP@txPosYF  = 1.

if (climatol) then

   if (ncases .gt. 1) then

   delete(res@xyDashPatterns)
   delete(res@xyLineThicknesses)
   delete(res@xyLineColors)
   resb = res
   res@xyMarkLineModes = (/"Lines","Lines","Lines","Lines","Markers"/)
   res@xyMarkerColors  = (/"white","white","white","white","red"/)
   res@xyMarkers         = (/0,0,0,0,0/)
   res@xyDashPatterns    = (/0,0,0,0,0/)
   res@xyLineThicknesses = (/5,3,3,3,3/)    
   res@xyLineColors      = (/"blue","cyan","black","black","white"/)

   resb@xyLineThicknesses = (/5/)
   resb@xyLineColors      = (/"red"/)

   else

   res@xyMarkLineModes = (/"Lines","Lines","Lines","Lines","Markers"/)
   res@xyMarkerColors  = (/"white","white","white","white","red"/)
   res@xyMarkers         = (/0,0,0,0,0/)
   res@xyDashPatterns    = (/0,0,0,0,0/)
   res@xyLineThicknesses = (/5,3,3,3,3/)    
   res@xyLineColors      = (/"blue","cyan","black","black","white"/)

   end if

   if (ihem .eq. 0) then
      if (ncases .gt. 1) then
         y1   = new((/ntimes_tot/),float)
         y2   = new((/ntimes_tot/),float)
         y3   = new((/ntimes_tot/),float)
         y1b  = new((/ntimes_tot/),float)
         y2b  = new((/ntimes_tot/),float)
         y3b  = new((/ntimes_tot/),float)
         y1   = -999.
         y2   = -999.
         y3   = -999.
         y1b  = -999.
         y2b  = -999.
         y3b  = -999.

         y1(ix1_off*12:ntimes-1+ix1_off*12)  = vhi_mo_nh_1
         y2(ix1_off*12:ntimes-1+ix1_off*12)  = vhs_mo_nh_1
         y1b(ix2_off*12:ntimes2-1+ix2_off*12) = vhi_mo_nh_2
         y2b(ix2_off*12:ntimes2-1+ix2_off*12) = vhs_mo_nh_2
         y3 (ix1_off*12:ntimes -1+ix1_off*12) = vai_mo_nh_1
         y3b(ix2_off*12:ntimes2-1+ix2_off*12) = vai_mo_nh_2

         x1 = fspan(1,ntimes_tot,ntimes_tot) / 12. + xyr1      - x1_off
         x2 = fspan(1,ntimes_tot,ntimes_tot) / 12. + xyr1_diff - x2_off

      else
         y1 = vhi_mo_nh_1
         y2 = vhs_mo_nh_1
         y3 = vai_mo_nh_1

         x1 = vhi_mo_nh_1&time / 365.

      end if
   else
      if (ncases .gt. 1) then
         y1   = new((/ntimes_tot/),float)
         y2   = new((/ntimes_tot/),float)
         y3   = new((/ntimes_tot/),float)
         y1b  = new((/ntimes_tot/),float)
         y2b  = new((/ntimes_tot/),float)
         y3b  = new((/ntimes_tot/),float)
         y1   = -999.
         y2   = -999.
         y3   = -999.
         y1b  = -999.
         y2b  = -999.
         y3b  = -999.

         y1(ix1_off*12:ntimes-1+ix1_off*12)  = vhi_mo_sh_1
         y2(ix1_off*12:ntimes-1+ix1_off*12)  = vhs_mo_sh_1
         y1b(ix2_off*12:ntimes2-1+ix2_off*12) = vhi_mo_sh_2
         y2b(ix2_off*12:ntimes2-1+ix2_off*12) = vhs_mo_sh_2
         y3 (ix1_off*12:ntimes -1+ix1_off*12) = vai_mo_sh_1
         y3b(ix2_off*12:ntimes2-1+ix2_off*12) = vai_mo_sh_2

         x1 = fspan(1,ntimes_tot,ntimes_tot) / 12. + xyr1      - x1_off
         x2 = fspan(1,ntimes_tot,ntimes_tot) / 12. + xyr1_diff - x2_off

      else
         y1 = vhi_mo_sh_1
         y2 = vhs_mo_sh_1
         y3 = vai_mo_sh_1

         x1 = vhi_mo_sh_1&time / 365.

      end if
   end if

else

   if (ncases .gt. 1) then

      res@xyLineThicknesses = (/5/)    
      res@xyDashPatterns    = (/0/)
      res@xyLineColors      = (/"blue"/)
      resb = res
      resb@xyLineColors      = (/"red"/)

      y1   = new((/ntimes_tot/12/),float)
      y2   = new((/ntimes_tot/12/),float)
      y3   = new((/ntimes_tot/12/),float)
      y1b  = new((/ntimes_tot/12/),float)
      y2b  = new((/ntimes_tot/12/),float)
      y3b  = new((/ntimes_tot/12/),float)
      y1   = -999.
      y2   = -999.
      y3   = -999.
      y1b  = -999.
      y2b  = -999.
      y3b  = -999.
      y4   = new((/ntimes_tot/12/),float)
      y5   = new((/ntimes_tot/12/),float)
      y6   = new((/ntimes_tot/12/),float)
      y4b  = new((/ntimes_tot/12/),float)
      y5b  = new((/ntimes_tot/12/),float)
      y6b  = new((/ntimes_tot/12/),float)
      y4   = -999.
      y5   = -999.
      y6   = -999.
      y4b  = -999.
      y5b  = -999.
      y6b  = -999.

      y1(ix1_off:ntimes/12-1+ix1_off)  = vhi_data1(ihem,iseas,:)
      y2(ix1_off:ntimes/12-1+ix1_off)  = vhs_data1(ihem,iseas,:)
      y3(ix1_off:ntimes/12-1+ix1_off)  = vai_data1(ihem,iseas,:)
      y1b(ix2_off:ntimes2/12-1+ix2_off) = vhi_data2(ihem,iseas,:)
      y2b(ix2_off:ntimes2/12-1+ix2_off) = vhs_data2(ihem,iseas,:)
      y3b(ix2_off:ntimes2/12-1+ix2_off) = vai_data2(ihem,iseas,:)

      vhi_anom0 = vhi_data1(ihem,iseas,:)-dim_avg(vhi_data1(ihem,iseas,:))
      vhs_anom0 = vhs_data1(ihem,iseas,:)-dim_avg(vhs_data1(ihem,iseas,:))
      vai_anom0 = vai_data1(ihem,iseas,:)-dim_avg(vai_data1(ihem,iseas,:))
      vhi_anom1 = vhi_data2(ihem,iseas,:)-dim_avg(vhi_data2(ihem,iseas,:))
      vhs_anom1 = vhs_data2(ihem,iseas,:)-dim_avg(vhs_data2(ihem,iseas,:))
      vai_anom1 = vai_data2(ihem,iseas,:)-dim_avg(vai_data2(ihem,iseas,:))

      y4(ix1_off:ntimes/12-1+ix1_off)  = vhi_anom0
      y5(ix1_off:ntimes/12-1+ix1_off)  = vhs_anom0
      y6(ix1_off:ntimes/12-1+ix1_off)  = vai_anom0
      y4b(ix2_off:ntimes2/12-1+ix2_off) = vhi_anom1
      y5b(ix2_off:ntimes2/12-1+ix2_off) = vhs_anom1
      y6b(ix2_off:ntimes2/12-1+ix2_off) = vai_anom1

      x1 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + xyr1      - x1_off
      x2 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + xyr1_diff - x2_off

   else

      res@xyLineThicknessF = 5
      res@xyLineColor      = "blue"

      y1 = vhi_data1(ihem,iseas,:)
      y2 = vhs_data1(ihem,iseas,:)
      y3 = vai_data1(ihem,iseas,:)
      vhi_anom0 = vhi_data1(ihem,iseas,:)-dim_avg(vhi_data1(ihem,iseas,:))
      vhs_anom0 = vhs_data1(ihem,iseas,:)-dim_avg(vhs_data1(ihem,iseas,:))
      vai_anom0 = vai_data1(ihem,iseas,:)-dim_avg(vai_data1(ihem,iseas,:))
      y4 = vhi_anom0
      y5 = vhs_anom0
      y6 = vai_anom0

      x1 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + stringtofloat(yr1)

   end if

end if

wks1 = gsn_open_wks(wks_type,wkdir + plotname(ihem,iseas))

if (ihem .eq. 0) then
   y1@long_name = "NH Ice Volume 10~S~13~N~ m~S~3~N~"
   y2@long_name = "NH Snow Volume 10~S~13~N~ m~S~3~N~"
   y3@long_name = "NH Ice Area 10~S~12~N~ m~S~2~N~"
else
   y1@long_name = "SH Ice Volume 10~S~13~N~ m~S~3~N~"
   y2@long_name = "SH Snow Volume 10~S~13~N~ m~S~3~N~"
   y3@long_name = "SH Ice Area 10~S~12~N~ m~S~2~N~"
end if

y1@_FillValue = -999.
y2@_FillValue = -999.
y3@_FillValue = -999.
x1@units = "years"
x1@long_name = "Years"

res@tmXMajorGrid = True
;res@tmYMajorGrid = True
res@tmXMajorGridLineDashPattern = 2
;res@tmYMajorGridLineDashPattern = 2
res@tmXMajorGridThicknessF = 1
;res@tmYMajorGridThicknessF = 1

if (ncases .gt. 1) then
   res@gsnRightString = case_to_cont
   res@gsnRightStringFontColor = "blue"
   res@gsnLeftString = case_to_diff
   res@gsnLeftStringFontColor = "red"

   y1b@_FillValue = -999.
   y2b@_FillValue = -999.
   y3b@_FillValue = -999.
   x2@units = "years"
   x2@long_name = "Years"

   res@tmXBLabelFontColor = "blue"

   res@trYMinF = min((/min(y1),min(y1b)/))
   res@trYMaxF = max((/max(y1),max(y1b)/))
   resb@trYMinF = min((/min(y1),min(y1b)/))
   resb@trYMaxF = max((/max(y1),max(y1b)/))

   resb@gsnRightString = " "
   resb@gsnLeftString = " "
   resb@tmXTLabelFontColor = "red"
   resb@tmYROn = False
   resb@tmXMajorGrid = False
   ;resb@tmYMajorGrid = False

   res@trXMinF = min((/min(x1),min(x1)/))
   res@trXMaxF = max((/max(x1),max(x1)/))
   resb@trXMinF = min((/min(x2),min(x2)/))
   resb@trXMaxF = max((/max(x2),max(x2)/))

   plot1 = gsn_csm_x2y2(wks1,x1,x2,y1,y1b,res,resb)
   res@gsnRightString = " "
   res@gsnLeftString = " "
   res@trYMinF = min((/min(y2),min(y2b)/))
   res@trYMaxF = max((/max(y2),max(y2b)/))
   resb@trYMinF = min((/min(y2),min(y2b)/))
   resb@trYMaxF = max((/max(y2),max(y2b)/))
   plot2 = gsn_csm_x2y2(wks1,x1,x2,y2,y2b,res,resb)
   res@trYMinF = min((/min(y3),min(y3b)/))
   res@trYMaxF = max((/max(y3),max(y3b)/))
   resb@trYMinF = min((/min(y3),min(y3b)/))
   resb@trYMaxF = max((/max(y3),max(y3b)/))
   plot3 = gsn_csm_x2y2(wks1,x1,x2,y3,y3b,res,resb)
else
   res@trXMinF = min((/x1/))
   res@trXMaxF = max((/x1/))
   plot1 = gsn_csm_xy(wks1,x1,y1,res)
   plot2 = gsn_csm_xy(wks1,x1,y2,res)
   plot3 = gsn_csm_xy(wks1,x1,y3,res)
end if

gsn_panel(wks1,(/plot1,plot2,plot3/),(/3,1/),resP)
;drawNDCGrid(wks1)
;frame(wks1)

if (.not. climatol) then

wks2 = gsn_open_wks(wks_type,wkdir + plotname2(ihem,iseas))

resP2 = resP
resP2@txString = title2(ihem,iseas)

if (ihem .eq. 0) then
   y4@long_name = "NH Ice Volume 10~S~13~N~ m~S~3~N~"
   y5@long_name = "NH Snow Volume 10~S~13~N~ m~S~3~N~"
   y6@long_name = "NH Ice Area 10~S~12~N~ m~S~2~N~"
else
   y4@long_name = "SH Ice Volume 10~S~13~N~ m~S~3~N~"
   y5@long_name = "SH Snow Volume 10~S~13~N~ m~S~3~N~"
   y6@long_name = "SH Ice Area 10~S~12~N~ m~S~2~N~"
end if

y4@_FillValue = -999.
y5@_FillValue = -999.
y6@_FillValue = -999.
x1@units = "years"
x1@long_name = "Years"

res2 = res
if (ncases .gt. 1) then
   res2@gsnRightString = case_to_cont
   res2@gsnRightStringFontColor = "blue"
   res2@gsnLeftString = case_to_diff
   res2@gsnLeftStringFontColor = "red"

   y4b@_FillValue = -999.
   y5b@_FillValue = -999.
   y6b@_FillValue = -999.
   x2@units = "years"
   x2@long_name = "Years"

   res2b = resb
   res2@tmXBLabelFontColor = "blue"
   res2b@tmXMajorGrid = False
   ;res2b@tmYMajorGrid = False

   res2@trYMinF = min((/min(y4),min(y4b)/))
   res2@trYMaxF = max((/max(y4),max(y4b)/))
   res2b@trYMinF = min((/min(y4),min(y4b)/))
   res2b@trYMaxF = max((/max(y4),max(y4b)/))

   res2b@tmXTLabelFontColor = "red"
   res2b@tmYROn = False

   res2@trXMinF = min((/min(x1),min(x1)/))
   res2@trXMaxF = max((/max(x1),max(x1)/))
   res2b@trXMinF = min((/min(x2),min(x2)/))
   res2b@trXMaxF = max((/max(x2),max(x2)/))

   res2b@gsnRightString = " "
   res2b@gsnLeftString = " "
   plot4 = gsn_csm_x2y2(wks2,x1,x2,y4,y4b,res2,res2b)
   res2@trYMinF = min((/min(y5),min(y5b)/))
   res2@trYMaxF = max((/max(y5),max(y5b)/))
   res2b@trYMinF = min((/min(y5),min(y5b)/))
   res2b@trYMaxF = max((/max(y5),max(y5b)/))
   res2@gsnRightString = " "
   res2@gsnLeftString = " "
   plot5 = gsn_csm_x2y2(wks2,x1,x2,y5,y5b,res2,res2b)
   res2@trYMinF = min((/min(y6),min(y6b)/))
   res2@trYMaxF = max((/max(y6),max(y6b)/))
   res2b@trYMinF = min((/min(y6),min(y6b)/))
   res2b@trYMaxF = max((/max(y6),max(y6b)/))
   plot6 = gsn_csm_x2y2(wks2,x1,x2,y6,y6b,res2,res2b)
else
   res2@trXMinF = min((/x1/))
   res2@trXMaxF = max((/x1/))
   plot4 = gsn_csm_xy(wks2,x1,y4,res2)
   plot5 = gsn_csm_xy(wks2,x1,y5,res2)
   plot6 = gsn_csm_xy(wks2,x1,y6,res2)
end if

gsn_panel(wks2,(/plot4,plot5,plot6/),(/3,1/),resP2)

delete(y4)
delete(y5)
delete(y6)
delete(resP2@txString)
if (ncases .gt. 1) then
   delete(y4b)
   delete(y5b)
   delete(y6b)
end if

end if

delete(y1)
delete(y2)
delete(y3)
delete(x1)
delete(resP@txString)

if (ncases .gt. 1) then
   delete(x2)
   delete(y1b)
   delete(y2b)
   delete(y3b)
end if

end do

end do

end
