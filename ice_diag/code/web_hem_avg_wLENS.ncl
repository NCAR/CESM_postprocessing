
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



; get data from model files
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


; load and process the LENS data (only concentration and volume, not snow)
f3 = addfile(diag_obs+"/LE_hitot_nh_1920-2100.nc","r")
f4 = addfile(diag_obs+"/LE_hitot_sh_1920-2100.nc","r")
f5 = addfile(diag_obs+"/LE_aicetot_nh_1920-2100.nc","r")
f6 = addfile(diag_obs+"/LE_aicetot_sh_1920-2100.nc","r")

;ice volume
vhi_mo_nh3_all = f3->hi_monthly
vhi_ann_nh3_all = f3->hi_ann
vhi_mo_sh3_all = f4->hi_monthly
vhi_ann_sh3_all = f4->hi_ann
yr_3 = f3->year
dims = dimsizes(vhi_mo_nh3_all)
vhi_nLENS = dims(0)  ; get # LENS members
delete([/f3,f4,dims/])

; convert volume units
vhi_mo_nh3_all  = vhi_mo_nh3_all/(1.E13)
vhi_mo_nh3_all@units = "1.E+13 m3"
vhi_mo_sh3_all  = vhi_mo_sh3_all/(1.E13)
vhi_mo_sh3_all@units = "1.E+13 m3"
vhi_ann_nh3_all  = vhi_ann_nh3_all/(1.E13)
vhi_ann_nh3_all@units = "1.E+13 m3"
vhi_ann_sh3_all  = vhi_ann_sh3_all/(1.E13)
vhi_ann_sh3_all@units = "1.E+13 m3"

; ice extent
vai_mo_nh3_all = f5->aice_monthly
vai_ann_nh3_all = f5->aice_ann
vai_mo_sh3_all = f6->aice_monthly
vai_ann_sh3_all = f6->aice_ann
yr_5 = f5->year
dims = dimsizes(vai_mo_nh3_all)
vai_nLENS = dims(0)  ; get # LENS members
delete([/f5,f6,dims/])

; convert volume units
vai_mo_nh3_all  = vai_mo_nh3_all/(1.E12)
vai_mo_nh3_all@units = "1.E+12 m3"
vai_mo_sh3_all  = vai_mo_sh3_all/(1.E12)
vai_mo_sh3_all@units = "1.E+12 m3"
vai_ann_nh3_all  = vai_ann_nh3_all/(1.E12)
vai_ann_nh3_all@units = "1.E+12 m3"
vai_ann_sh3_all  = vai_ann_sh3_all/(1.E12)
vai_ann_sh3_all@units = "1.E+12 m3"


; subset just historical period (1920-2005)
vhi_yrs_LENS = yr_3(0:85)
vhi_nyrs_LENS = dimsizes(vhi_yrs_LENS)
vhi_mo_nh3 = vhi_mo_nh3_all(:,0:vhi_nyrs_LENS-1,:)
vhi_ann_nh3 = vhi_ann_nh3_all(:,0:vhi_nyrs_LENS-1)
vhi_mo_sh3 = vhi_mo_sh3_all(:,0:vhi_nyrs_LENS-1,:)
vhi_ann_sh3 = vhi_ann_sh3_all(:,0:vhi_nyrs_LENS-1)

vai_mo_nh3 = vai_mo_nh3_all(:,0:vhi_nyrs_LENS-1,:)
vai_ann_nh3 = vai_ann_nh3_all(:,0:vhi_nyrs_LENS-1)
vai_mo_sh3 = vai_mo_sh3_all(:,0:vhi_nyrs_LENS-1,:)
vai_ann_sh3 = vai_ann_sh3_all(:,0:vhi_nyrs_LENS-1)

; LENS ice volumes
vhi_data3 = new((/2,vhi_nLENS,5,vhi_nyrs_LENS/),float)

vhi_data3(0,:,0,:) = vhi_ann_nh3
vhi_data3(0,:,1,:) = dim_avg_n(vhi_mo_nh3(n_members|:,nyr|:,nmonth|0:2),2)
vhi_data3(0,:,2,:) = dim_avg_n(vhi_mo_nh3(n_members|:,nyr|:,nmonth|3:5),2)
vhi_data3(0,:,3,:) = dim_avg_n(vhi_mo_nh3(n_members|:,nyr|:,nmonth|6:8),2)
vhi_data3(0,:,4,:) = dim_avg_n(vhi_mo_nh3(n_members|:,nyr|:,nmonth|9:11),2)

vhi_data3(1,:,0,:) = vhi_ann_sh3
vhi_data3(1,:,1,:) = dim_avg_n(vhi_mo_sh3(n_members|:,nyr|:,nmonth|0:2),2)
vhi_data3(1,:,2,:) = dim_avg_n(vhi_mo_sh3(n_members|:,nyr|:,nmonth|3:5),2)
vhi_data3(1,:,3,:) = dim_avg_n(vhi_mo_sh3(n_members|:,nyr|:,nmonth|6:8),2)
vhi_data3(1,:,4,:) = dim_avg_n(vhi_mo_sh3(n_members|:,nyr|:,nmonth|9:11),2)

; LENS ice areas
vai_data3 = new((/2,vai_nLENS,5,vhi_nyrs_LENS/),float)

vai_data3(0,:,0,:) = vai_ann_nh3
vai_data3(0,:,1,:) = dim_avg_n(vai_mo_nh3(n_members|:,nyr|:,nmonth|0:2),2)
vai_data3(0,:,2,:) = dim_avg_n(vai_mo_nh3(n_members|:,nyr|:,nmonth|3:5),2)
vai_data3(0,:,3,:) = dim_avg_n(vai_mo_nh3(n_members|:,nyr|:,nmonth|6:8),2)
vai_data3(0,:,4,:) = dim_avg_n(vai_mo_nh3(n_members|:,nyr|:,nmonth|9:11),2)

vai_data3(1,:,0,:) = vai_ann_sh3
vai_data3(1,:,1,:) = dim_avg_n(vai_mo_sh3(n_members|:,nyr|:,nmonth|0:2),2)
vai_data3(1,:,2,:) = dim_avg_n(vai_mo_sh3(n_members|:,nyr|:,nmonth|3:5),2)
vai_data3(1,:,3,:) = dim_avg_n(vai_mo_sh3(n_members|:,nyr|:,nmonth|6:8),2)
vai_data3(1,:,4,:) = dim_avg_n(vai_mo_sh3(n_members|:,nyr|:,nmonth|9:11),2)

; plotting the data

plotname  = new((/2,5/),string)
title     = new((/2,5/),string)

title(0,0) = "ANN Mean LENS and "+case
title(0,1) = "JFM Mean LENS and "+case
title(0,2) = "AMJ Mean LENS and "+case
title(0,3) = "JAS Mean LENS and "+case
title(0,4) = "OND Mean LENS and "+case

title(1,0) = "ANN Mean LENS and "+case
title(1,1) = "JFM Mean LENS and "+case
title(1,2) = "AMJ Mean LENS and "+case
title(1,3) = "JAS Mean LENS and "+case
title(1,4) = "OND Mean LENS and "+case

if (ncases .gt. 1) then

   plotname(0,0) = "line_avg_LENS_ANN_NH_diff"
   plotname(0,1) = "line_avg_LENS_JFM_NH_diff"
   plotname(0,2) = "line_avg_LENS_AMJ_NH_diff"
   plotname(0,3) = "line_avg_LENS_JAS_NH_diff"
   plotname(0,4) = "line_avg_LENS_OND_NH_diff"

   plotname(1,0) = "line_avg_LENS_ANN_SH_diff"
   plotname(1,1) = "line_avg_LENS_JFM_SH_diff"
   plotname(1,2) = "line_avg_LENS_AMJ_SH_diff"
   plotname(1,3) = "line_avg_LENS_JAS_SH_diff"
   plotname(1,4) = "line_avg_LENS_OND_SH_diff"
else
   plotname(0,0) = "line_avg_LENS_ANN_NH"
   plotname(0,1) = "line_avg_LENS_JFM_NH"
   plotname(0,2) = "line_avg_LENS_AMJ_NH"
   plotname(0,3) = "line_avg_LENS_JAS_NH"
   plotname(0,4) = "line_avg_LENS_OND_NH"

   plotname(1,0) = "line_avg_LENS_ANN_SH"
   plotname(1,1) = "line_avg_LENS_JFM_SH"
   plotname(1,2) = "line_avg_LENS_AMJ_SH"
   plotname(1,3) = "line_avg_LENS_JAS_SH"
   plotname(1,4) = "line_avg_LENS_OND_SH"
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
do ihem=0,1

resP@txString = title(ihem,iseas)
;resP@txPosYF  = 1.

   if (ncases .gt. 1) then

      ; arrays to plot against
      x1 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + xyr1      - x1_off
      x2 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + xyr1_diff - x2_off

      ; non-LENS resources
      res = res
      res@xyLineThicknesses = (/5/)
      res@xyDashPatterns    = (/0/)
      res@xyLineColors      = (/"blue"/)

      ; volume resources
      resv = res
      delete([/resv@xyLineThicknesses, resv@xyDashPatterns, resv@xyLineColors/])
 
      ; dummy variables for the big array of LENS data
      dumi = new((/vhi_nLENS+1/),integer)
      dums = new((/vhi_nLENS+1/),string)
      ts = dumi
      ts = 5
      resv@xyLineThicknesses = ts
      delete(ts)
      ps = dumi
      ps = 0
      resv@xyDashPatterns    = ps
      delete(ps)
      cs = dums
      cs = "grey"
      cs(vhi_nLENS) = "blue"
      resv@xyLineColors = cs
      delete(cs)

      ; area resources
      resa = res
      delete([/resa@xyLineThicknesses, resa@xyDashPatterns, resa@xyLineColors/])
 
      ; dummy variables for the big array of LENS data
      dumi = new((/vhi_nLENS+1/),integer)
      dums = new((/vhi_nLENS+1/),string)
      ts = dumi
      ts = 5
      resa@xyLineThicknesses = ts
      delete(ts)
      ps = dumi
      ps = 0
      resa@xyDashPatterns    = ps
      delete(ps)
      cs = dums
      cs = "grey"
      cs(vhi_nLENS) = "blue"
      resa@xyLineColors = cs
      delete(cs)

      resb = res
      delete([/resb@xyLineThicknesses, resb@xyDashPatterns, resb@xyLineColors/])
      resb@xyLineThicknesses = (/5/)
      resb@xyDashPatterns    = (/0/)
      resb@xyLineColors      = (/"red"/)

      ; get indices where LENS is available for this dataset
      ; array of "good" data indices
      dum1 = x1
      dum1@_FillValue = -999.9
      dum1 = where(dum1 .lt. min(yr_3), dum1@_FillValue, dum1)
      inds1 = ind(.not.ismissing(dum1))
      ; array of "good" LENS indices
      dum2 = yr_3
      dum2@_FillValue = -999.9
      dum2 = where(dum2 .gt. max(x1), dum2@_FillValue, dum2)
      inds2 = ind(.not.ismissing(dum2))

      ; fill in arrays
      y1   = new((/vhi_nLENS+1,ntimes_tot/12/),float)
      y2   = new((/ntimes_tot/12/),float)
      y3   = new((/vhi_nLENS+1,ntimes_tot/12/),float)
      y1b  = new((/ntimes_tot/12/),float)
      y2b  = new((/ntimes_tot/12/),float)
      y3b  = new((/ntimes_tot/12/),float)
      y1   = -999.
      y2   = -999.
      y3   = -999.
      y1b  = -999.
      y2b  = -999.
      y3b  = -999.

      y1(0:vhi_nLENS-1,inds1(0):ntimes/12-1+ix1_off) = (/vhi_data3(ihem,:,iseas,0:inds2(max(inds2)))/)
      y1(vhi_nLENS,ix1_off:ntimes/12-1+ix1_off)  = (/vhi_data1(ihem,iseas,:)/)
      y2(ix1_off:ntimes/12-1+ix1_off)  = vhs_data1(ihem,iseas,:)
      y3(0:vhi_nLENS-1,inds1(0):ntimes/12-1+ix1_off) = (/vai_data3(ihem,0:vhi_nLENS-1,iseas,0:inds2(max(inds2)))/)
      y3(vhi_nLENS,ix1_off:ntimes/12-1+ix1_off)  = (/vai_data1(ihem,iseas,:)/)

      y1b(ix2_off:ntimes2/12-1+ix2_off) = vhi_data2(ihem,iseas,:)
      y2b(ix2_off:ntimes2/12-1+ix2_off) = vhs_data2(ihem,iseas,:)
      y3b(ix2_off:ntimes2/12-1+ix2_off) = vai_data2(ihem,iseas,:)

   else
      ; array to plot against
      x1 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + stringtofloat(yr1)

      ; non-LENS resources
      res = res
      res@xyLineThicknesses = (/5/)
      res@xyDashPatterns    = (/0/)
      res@xyLineColors      = (/"blue"/)
      res@trXMinF = min((/x1/))
      res@trXMaxF = max((/x1/))

      ; volume resources
      resv = res
      delete([/resv@xyLineThicknesses, resv@xyDashPatterns, resv@xyLineColors/])
 
      ; dummy variables for the big array of LENS data
      dumi = new((/vhi_nLENS+1/),integer)
      dums = new((/vhi_nLENS+1/),string)
      ts = dumi
      ts = 5
      resv@xyLineThicknesses = ts
      delete(ts)
      ps = dumi
      ps = 0
      resv@xyDashPatterns    = ps
      delete(ps)
      cs = dums
      cs = "grey"
      cs(vhi_nLENS) = "blue"
      resv@xyLineColors = cs
      delete(cs)

      ; area resources
      resa = res
      delete([/resa@xyLineThicknesses, resa@xyDashPatterns, resa@xyLineColors/])
 
      ; dummy variables for the big array of LENS data
      dumi = new((/vhi_nLENS+1/),integer)
      dums = new((/vhi_nLENS+1/),string)
      ts = dumi
      ts = 5
      resa@xyLineThicknesses = ts
      delete(ts)
      ps = dumi
      ps = 0
      resa@xyDashPatterns    = ps
      delete(ps)
      cs = dums
      cs = "grey"
      cs(vhi_nLENS) = "blue"
      resa@xyLineColors = cs
      delete(cs)

      ; get indices where LENS is available for this dataset
      ; array of "good" data indices
      dum1 = x1
      dum1@_FillValue = -999.9
      dum1 = where(dum1 .lt. min(yr_3), dum1@_FillValue, dum1)
      inds1 = ind(.not.ismissing(dum1))
      ; array of "good" LENS indices
      dum2 = yr_3
      dum2@_FillValue = -999.9
      dum2 = where(dum2 .gt. max(x1), dum2@_FillValue, dum2)
      inds2 = ind(.not.ismissing(dum2))

      y1   = new((/vhi_nLENS+1,ntimes_tot/12/),float)
      y2   = new((/ntimes_tot/12/),float)
      y3   = new((/vhi_nLENS+1,ntimes_tot/12/),float)
      y1   = -999.
      y2   = -999.
      y3   = -999.

      y1(0:vhi_nLENS-1,inds1(0):ntimes/12-1+ix1_off) = (/vhi_data3(ihem,:,iseas,0:inds2(max(inds2)))/)
      y1(vhi_nLENS,ix1_off:ntimes/12-1+ix1_off)  = (/vhi_data1(ihem,iseas,:)/)
      y2(ix1_off:ntimes/12-1+ix1_off)  = vhs_data1(ihem,iseas,:)
      y3(0:vhi_nLENS-1,inds1(0):ntimes/12-1+ix1_off) = (/vai_data3(ihem,0:vhi_nLENS-1,iseas,0:inds2(max(inds2)))/)
      y3(vhi_nLENS,ix1_off:ntimes/12-1+ix1_off)  = (/vai_data1(ihem,iseas,:)/)

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

resv@tmXMajorGrid = True
;resv@tmYMajorGrid = True
resv@tmXMajorGridLineDashPattern = 2
;resv@tmYMajorGridLineDashPattern = 2
resv@tmXMajorGridThicknessF = 1
;resv@tmYMajorGridThicknessF = 1

resa@tmXMajorGrid = True
;resa@tmYMajorGrid = True
resa@tmXMajorGridLineDashPattern = 2
;resa@tmYMajorGridLineDashPattern = 2
resa@tmXMajorGridThicknessF = 1
;resa@tmYMajorGridThicknessF = 1

if (ncases .gt. 1) then
   res@gsnRightString = case_to_cont
   res@gsnRightStringFontColor = "blue"
   res@gsnLeftString = case_to_diff
   res@gsnLeftStringFontColor = "red"

   resv@gsnRightString = case_to_cont
   resv@gsnRightStringFontColor = "blue"
   resv@gsnLeftString = case_to_diff
   resv@gsnLeftStringFontColor = "red"

   ;resa@gsnRightString = case_to_cont
   ;resa@gsnRightStringFontColor = "blue"
   ;resa@gsnLeftString = case_to_diff
   ;resa@gsnLeftStringFontColor = "red"

   y1b@_FillValue = -999.
   y2b@_FillValue = -999.
   y3b@_FillValue = -999.
   x2@units = "years"
   x2@long_name = "Years"

   res@tmXBLabelFontColor = "blue"
   resv@tmXBLabelFontColor = "blue"
   resa@tmXBLabelFontColor = "blue"

   res@trYMinF = min((/min(y1),min(y1b)/))
   res@trYMaxF = max((/max(y1),max(y1b)/))
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

   res@trXMinF = min((/min(x1),min(x1)/))
   res@trXMaxF = max((/max(x1),max(x1)/))
   resv@trXMinF = min((/min(x1),min(x1)/))
   resv@trXMaxF = max((/max(x1),max(x1)/))
   resa@trXMinF = min((/min(x1),min(x1)/))
   resa@trXMaxF = max((/max(x1),max(x1)/))
   resb@trXMinF = min((/min(x2),min(x2)/))
   resb@trXMaxF = max((/max(x2),max(x2)/))

   plot1 = gsn_csm_x2y2(wks1,x1,x2,y1,y1b,resv,resb)

   res@gsnRightString = " "
   res@gsnLeftString = " "
   res@trYMinF = min((/min(y2),min(y2b)/))
   res@trYMaxF = max((/max(y2),max(y2b)/))
   resb@trYMinF = min((/min(y2),min(y2b)/))
   resb@trYMaxF = max((/max(y2),max(y2b)/))
   plot2 = gsn_csm_x2y2(wks1,x1,x2,y2,y2b,res,resb)

   resa@trYMinF = min((/min(y3),min(y3b)/))
   resa@trYMaxF = max((/max(y3),max(y3b)/))
   resb@trYMinF = min((/min(y3),min(y3b)/))
   resb@trYMaxF = max((/max(y3),max(y3b)/))
   plot3 = gsn_csm_x2y2(wks1,x1,x2,y3,y3b,resa,resb)
else
   plot1 = gsn_csm_xy(wks1,x1,y1,resv)
   plot2 = gsn_csm_xy(wks1,x1,y2,res)
   plot3 = gsn_csm_xy(wks1,x1,y3,resa)
end if

gsn_panel(wks1,(/plot1,plot2,plot3/),(/3,1/),resP)
;drawNDCGrid(wks1)
;frame(wks1)

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
