
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
nr = stringtoint(getenv("REGION_NUMBER"))
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


vhi_mo_Lab_1 = f1->vhi_mo_Lab
vai_mo_Lab_1 = f1->vai_mo_Lab
vhs_mo_Lab_1 = f1->vhs_mo_Lab

ndim = dimsizes(vhi_mo_Lab_1)
ntimes = ndim(0)
nregions = 16
vhi_mo_regions_1 = new((/nregions,ntimes/),float)
vai_mo_regions_1 = new((/nregions,ntimes/),float)
vhs_mo_regions_1 = new((/nregions,ntimes/),float)

vhi_mo_regions_1(0,:) = vhi_mo_Lab_1
vai_mo_regions_1(0,:) = f1->vai_mo_Lab
vhs_mo_regions_1(0,:) = f1->vhs_mo_Lab 
vhi_mo_regions_1(1,:) = f1->vhi_mo_GIN
vai_mo_regions_1(1,:) = f1->vai_mo_GIN
vhs_mo_regions_1(1,:) = f1->vhs_mo_GIN
vhi_mo_regions_1(2,:) = f1->vhi_mo_Bar
vai_mo_regions_1(2,:) = f1->vai_mo_Bar
vhs_mo_regions_1(2,:) = f1->vhs_mo_Bar
vhi_mo_regions_1(3,:) = f1->vhi_mo_ArcOc
vai_mo_regions_1(3,:) = f1->vai_mo_ArcOc
vhs_mo_regions_1(3,:) = f1->vhs_mo_ArcOc
vhi_mo_regions_1(4,:) = f1->vhi_mo_Sib
vai_mo_regions_1(4,:) = f1->vai_mo_Sib
vhs_mo_regions_1(4,:) = f1->vhs_mo_Sib
vhi_mo_regions_1(5,:) = f1->vhi_mo_Beau
vai_mo_regions_1(5,:) = f1->vai_mo_Beau
vhs_mo_regions_1(5,:) = f1->vhs_mo_Beau
vhi_mo_regions_1(6,:) = f1->vhi_mo_CArc
vai_mo_regions_1(6,:) = f1->vai_mo_CArc
vhs_mo_regions_1(6,:) = f1->vhs_mo_CArc

vhi_mo_regions_1(7,:) = f1->vhi_mo_Bering
vai_mo_regions_1(7,:) = f1->vai_mo_Bering
vhs_mo_regions_1(7,:) = f1->vhs_mo_Bering
vhi_mo_regions_1(8,:) = f1->vhi_mo_Okhotsk
vai_mo_regions_1(8,:) = f1->vai_mo_Okhotsk
vhs_mo_regions_1(8,:) = f1->vhs_mo_Okhotsk
vhi_mo_regions_1(9,:) = f1->vhi_mo_Hudson
vai_mo_regions_1(9,:) = f1->vai_mo_Hudson
vhs_mo_regions_1(9,:) = f1->vhs_mo_Hudson
vhi_mo_regions_1(10,:) = f1->vhi_mo_CAArch
vai_mo_regions_1(10,:) = f1->vai_mo_CAArch
vhs_mo_regions_1(10,:) = f1->vhs_mo_CAArch

vhi_mo_regions_1(11,:) = f1->vhi_mo_Wed
vai_mo_regions_1(11,:) = f1->vai_mo_Wed
vhs_mo_regions_1(11,:) = f1->vhs_mo_Wed
vhi_mo_regions_1(12,:) = f1->vhi_mo_Ross
vai_mo_regions_1(12,:) = f1->vai_mo_Ross
vhs_mo_regions_1(12,:) = f1->vhs_mo_Ross
vhi_mo_regions_1(13,:) = f1->vhi_mo_Ind
vai_mo_regions_1(13,:) = f1->vai_mo_Ind
vhs_mo_regions_1(13,:) = f1->vhs_mo_Ind
vhi_mo_regions_1(14,:) = f1->vhi_mo_Pac
vai_mo_regions_1(14,:) = f1->vai_mo_Pac
vhs_mo_regions_1(14,:) = f1->vhs_mo_Pac
vhi_mo_regions_1(15,:) = f1->vhi_mo_BAm
vai_mo_regions_1(15,:) = f1->vai_mo_BAm
vhs_mo_regions_1(15,:) = f1->vhs_mo_BAm

vhi_data1 = new((/nregions,5,ntimes/12/),float)
vai_data1 = new((/nregions,5,ntimes/12/),float)
vhs_data1 = new((/nregions,5,ntimes/12/),float)

ntimes_tot = ntimes

if (ncases .gt. 1) then
   vhi_mo_Lab_2 = f2->vhi_mo_Lab
   vai_mo_Lab_2 = f2->vai_mo_Lab
   vhs_mo_Lab_2 = f2->vhs_mo_Lab

   ndim = dimsizes(vhi_mo_Lab_2)
   ntimes2 = ndim(0)

   vhi_mo_regions_2 = new((/nregions,ntimes2/),float)
   vai_mo_regions_2  = new((/nregions,ntimes2/),float)
   vhs_mo_regions_2 = new((/nregions,ntimes2/),float)

   vhi_mo_regions_2(0,:) = vhi_mo_Lab_2
   vai_mo_regions_2(0,:) = f2->vai_mo_Lab
   vhs_mo_regions_2(0,:) = f2->vhs_mo_Lab 
   vhi_mo_regions_2(1,:) = f2->vhi_mo_GIN
   vai_mo_regions_2(1,:) = f2->vai_mo_GIN
   vhs_mo_regions_2(1,:) = f2->vhs_mo_GIN
   vhi_mo_regions_2(2,:) = f2->vhi_mo_Bar
   vai_mo_regions_2(2,:) = f2->vai_mo_Bar
   vhs_mo_regions_2(2,:) = f2->vhs_mo_Bar
   vhi_mo_regions_2(3,:) = f2->vhi_mo_ArcOc
   vai_mo_regions_2(3,:) = f2->vai_mo_ArcOc
   vhs_mo_regions_2(3,:) = f2->vhs_mo_ArcOc
   vhi_mo_regions_2(4,:) = f2->vhi_mo_Sib
   vai_mo_regions_2(4,:) = f2->vai_mo_Sib
   vhs_mo_regions_2(4,:) = f2->vhs_mo_Sib
   vhi_mo_regions_2(5,:) = f2->vhi_mo_Beau
   vai_mo_regions_2(5,:) = f2->vai_mo_Beau
   vhs_mo_regions_2(5,:) = f2->vhs_mo_Beau
   vhi_mo_regions_2(6,:) = f2->vhi_mo_CArc
   vai_mo_regions_2(6,:) = f2->vai_mo_CArc
   vhs_mo_regions_2(6,:) = f2->vhs_mo_CArc
   vhi_mo_regions_2(7,:) = f2->vhi_mo_Bering
   vai_mo_regions_2(7,:) = f2->vai_mo_Bering
   vhs_mo_regions_2(7,:) = f2->vhs_mo_Bering
   vhi_mo_regions_2(8,:) = f2->vhi_mo_Okhotsk
   vai_mo_regions_2(8,:) = f2->vai_mo_Okhotsk
   vhs_mo_regions_2(8,:) = f2->vhs_mo_Okhotsk
   vhi_mo_regions_2(9,:) = f2->vhi_mo_Hudson
   vai_mo_regions_2(9,:) = f2->vai_mo_Hudson
   vhs_mo_regions_2(9,:) = f2->vhs_mo_Hudson
   vhi_mo_regions_2(10,:) = f2->vhi_mo_CAArch
   vai_mo_regions_2(10,:) = f2->vai_mo_CAArch
   vhs_mo_regions_2(10,:) = f2->vhs_mo_CAArch
   vhi_mo_regions_2(11,:) = f2->vhi_mo_Wed
   vai_mo_regions_2(11,:) = f2->vai_mo_Wed
   vhs_mo_regions_2(11,:) = f2->vhs_mo_Wed
   vhi_mo_regions_2(12,:) = f2->vhi_mo_Ross
   vai_mo_regions_2(12,:) = f2->vai_mo_Ross
   vhs_mo_regions_2(12,:) = f2->vhs_mo_Ross
   vhi_mo_regions_2(13,:) = f2->vhi_mo_Ind
   vai_mo_regions_2(13,:) = f2->vai_mo_Ind
   vhs_mo_regions_2(13,:) = f2->vhs_mo_Ind
   vhi_mo_regions_2(14,:) = f2->vhi_mo_Pac
   vai_mo_regions_2(14,:) = f2->vai_mo_Pac
   vhs_mo_regions_2(14,:) = f2->vhs_mo_Pac
   vhi_mo_regions_2(15,:) = f2->vhi_mo_BAm
   vai_mo_regions_2(15,:) = f2->vai_mo_BAm
   vhs_mo_regions_2(15,:) = f2->vhs_mo_BAm

   ntimes_tot = max((/ntimes+ix1_off*12,ntimes2+ix2_off*12/))

   vhi_data2 = new((/nregions,5,ntimes2/12/),float)
   vai_data2 = new((/nregions,5,ntimes2/12/),float)
   vhs_data2 = new((/nregions,5,ntimes2/12/),float)

end if

; Compute seasonal and annual means

   vhi_mo_1 = onedtond(vhi_mo_regions_1(nr,:),(/ntimes/12,12/))
   vhi_mo_1!0 = "years"
   vhi_mo_1!1 = "months"
   vhi_data1(nr,0,:) = dim_avg(vhi_mo_1)
   vhi_data1(nr,1,:) = dim_avg(vhi_mo_1(years|:,months|0:2))
   vhi_data1(nr,2,:) = dim_avg(vhi_mo_1(years|:,months|3:5))
   vhi_data1(nr,3,:) = dim_avg(vhi_mo_1(years|:,months|6:8))
   vhi_data1(nr,4,:) = dim_avg(vhi_mo_1(years|:,months|9:11))

   vhs_mo_1 = onedtond(vhs_mo_regions_1(nr,:),(/ntimes/12,12/))
   vhs_mo_1!0 = "years"
   vhs_mo_1!1 = "months"
   vhs_data1(nr,0,:) = dim_avg(vhs_mo_1)
   vhs_data1(nr,1,:) = dim_avg(vhs_mo_1(years|:,months|0:2))
   vhs_data1(nr,2,:) = dim_avg(vhs_mo_1(years|:,months|3:5))
   vhs_data1(nr,3,:) = dim_avg(vhs_mo_1(years|:,months|6:8))
   vhs_data1(nr,4,:) = dim_avg(vhs_mo_1(years|:,months|9:11))

   vai_mo_1 = onedtond(vai_mo_regions_1(nr,:),(/ntimes/12,12/))
   vai_mo_1!0 = "years"
   vai_mo_1!1 = "months"
   vai_data1(nr,0,:) = dim_avg(vai_mo_1)
   vai_data1(nr,1,:) = dim_avg(vai_mo_1(years|:,months|0:2))
   vai_data1(nr,2,:) = dim_avg(vai_mo_1(years|:,months|3:5))
   vai_data1(nr,3,:) = dim_avg(vai_mo_1(years|:,months|6:8))
   vai_data1(nr,4,:) = dim_avg(vai_mo_1(years|:,months|9:11))

   if (ncases .gt. 1) then
      vhi_mo_2 = onedtond(vhi_mo_regions_2(nr,:),(/ntimes2/12,12/))
      vhi_mo_2!0 = "years" 
      vhi_mo_2!1 = "months"
      vhi_data2(nr,0,:) = dim_avg(vhi_mo_2)
      vhi_data2(nr,1,:) = dim_avg(vhi_mo_2(years|:,months|0:2))
      vhi_data2(nr,2,:) = dim_avg(vhi_mo_2(years|:,months|3:5))
      vhi_data2(nr,3,:) = dim_avg(vhi_mo_2(years|:,months|6:8))
      vhi_data2(nr,4,:) = dim_avg(vhi_mo_2(years|:,months|9:11))
   
      vhs_mo_2 = onedtond(vhs_mo_regions_2(nr,:),(/ntimes2/12,12/))
      vhs_mo_2!0 = "years" 
      vhs_mo_2!1 = "months"
      vhs_data2(nr,0,:) = dim_avg(vhs_mo_2)
      vhs_data2(nr,1,:) = dim_avg(vhs_mo_2(years|:,months|0:2))
      vhs_data2(nr,2,:) = dim_avg(vhs_mo_2(years|:,months|3:5))
      vhs_data2(nr,3,:) = dim_avg(vhs_mo_2(years|:,months|6:8))
      vhs_data2(nr,4,:) = dim_avg(vhs_mo_2(years|:,months|9:11))
   
      vai_mo_2 = onedtond(vai_mo_regions_2(nr,:),(/ntimes2/12,12/))
      vai_mo_2!0 = "years"
      vai_mo_2!1 = "months" 
      vai_data2(nr,0,:) = dim_avg(vai_mo_2)
      vai_data2(nr,1,:) = dim_avg(vai_mo_2(years|:,months|0:2))
      vai_data2(nr,2,:) = dim_avg(vai_mo_2(years|:,months|3:5))
      vai_data2(nr,3,:) = dim_avg(vai_mo_2(years|:,months|6:8))
      vai_data2(nr,4,:) = dim_avg(vai_mo_2(years|:,months|9:11))
   end if

plotname  = new((/nregions,6/),string)
plotname2 = new((/nregions,5/),string)
title     = new((/nregions,6/),string)
title2    = new((/nregions,5/),string)

region_titles = (/"Lab","GIN","Bar","ArcOC", "Sib","Beau","CArc","Bering","Okhotsk","Hudson",\
     "CAArch","Wed","Ross","Ind","Pac","BAm"/)

title(0:nregions-1,0) = "ANN Mean "+case
title(0:nregions-1,1) = "JFM Mean "+case
title(0:nregions-1,2) = "AMJ Mean "+case
title(0:nregions-1,3) = "JAS Mean "+case
title(0:nregions-1,4) = "OND Mean "+case
title(0:nregions-1,5) = case

title2(0:nregions-1,0) = "ANN Anomalies "+case
title2(0:nregions-1,1) = "JFM Anomalies "+case
title2(0:nregions-1,2) = "AMJ Anomalies "+case
title2(0:nregions-1,3) = "JAS Anomalies "+case
title2(0:nregions-1,4) = "OND Anomalies "+case

if (ncases .gt. 1) then
   add_title = "_diff"
else
   add_title = ""
end if

   plotname(nr,0) = "line_avg_ANN_" + region_titles(nr) + add_title
   plotname(nr,1) = "line_avg_JFM_" + region_titles(nr) + add_title
   plotname(nr,2) = "line_avg_AMJ_" + region_titles(nr) + add_title
   plotname(nr,3) = "line_avg_JAS_" + region_titles(nr) + add_title
   plotname(nr,4) = "line_avg_OND_" + region_titles(nr) + add_title
   plotname(nr,5) = "line_mo_" + region_titles(nr) + add_title

   plotname2(nr,0) = "line_var_ANN_" + region_titles(nr) + add_title
   plotname2(nr,1) = "line_var_JFM_" + region_titles(nr) + add_title
   plotname2(nr,2) = "line_var_AMJ_" + region_titles(nr) + add_title
   plotname2(nr,3) = "line_var_JAS_" + region_titles(nr) + add_title
   plotname2(nr,4) = "line_var_OND_" + region_titles(nr) + add_title

resP = True
resP@gsnMaximize         = True
resP@gsnPaperOrientation = "portrait"
resP@txFont              = "helvetica"
resP@txFontHeightF = 0.015
resP@txFuncCode          = "~"

resP@gsnPanelYWhiteSpacePercent = 0.0

res = True
res@gsnDraw = False
res@gsnFrame = False
res@txFont   = "helvetica"
res@txFontHeightF   = 0.015
res@txFuncCode = "~"
res@tiMainFont          = "helvetica"
res@tiMainFuncCode          = "~"
res@tiXAxisFont          = "helvetica"
res@tiXAxisFontHeightF = 0.015
res@tiXAxisFuncCode          = "~"
res@tiYAxisFont          = "helvetica"
res@tiYAxisFontHeightF = 0.015
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


   resP@txString = title(nr,iseas)

   if (climatol) then
      if (ncases .gt. 1) then

         delete(res@xyLineThicknesses)
         delete(res@xyDashPatterns)
         delete(res@xyLineColors)
         resb = res

         resb@xyDashPatterns    = (/0/)
         resb@xyLineThicknesses = (/5/)
         resb@xyLineColors      = (/"red"/)

      end if

      res@xyDashPatterns    = (/0/)
      res@xyLineThicknesses = (/5/)    
      res@xyLineColors      = (/"blue"/)

;****************************************************
; Line that adds climatological average, min and max
; is deleted out for now (y3 = ...). We don't have 
; climatological values yet for individual regions ....
;****************************************************
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

          y1(ix1_off*12:ntimes-1+ix1_off*12)  = vhi_mo_regions_1(nr,:)
          y2(ix1_off*12:ntimes-1+ix1_off*12)  = vhs_mo_regions_1(nr,:)
          y1b(ix2_off*12:ntimes2-1+ix2_off*12) = vhi_mo_regions_2(nr,:)
          y2b(ix2_off*12:ntimes2-1+ix2_off*12) = vhs_mo_regions_2(nr,:)
          y3(ix1_off*12:ntimes-1+ix1_off*12)  = vai_mo_regions_1(nr,:)
          y3b(ix2_off*12:ntimes2-1+ix2_off*12) = vai_mo_regions_2(nr,:)

          x1 = fspan(1,ntimes_tot,ntimes_tot) / 12. + xyr1      - x1_off
          x2 = fspan(1,ntimes_tot,ntimes_tot) / 12. + xyr1_diff - x2_off

       else
          y1 = vhi_mo_regions_1(nr,:)
          y2 = vhs_mo_regions_1(nr,:)
          y3 = vai_mo_regions_1(nr,:)

          x1 = vhi_mo_regions_1&time / 365.
          x2 = x1

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

          y1(ix1_off:ntimes/12-1+ix1_off)  = vhi_data1(nr,iseas,:)
          y2(ix1_off:ntimes/12-1+ix1_off)  = vhs_data1(nr,iseas,:)
          y3(ix1_off:ntimes/12-1+ix1_off)  = vai_data1(nr,iseas,:)
          y1b(ix2_off:ntimes2/12-1+ix2_off) = vhi_data2(nr,iseas,:)
          y2b(ix2_off:ntimes2/12-1+ix2_off) = vhs_data2(nr,iseas,:)
          y3b(ix2_off:ntimes2/12-1+ix2_off) = vai_data2(nr,iseas,:)

          vhi_anom0 = vhi_data1(nr,iseas,:)-dim_avg(vhi_data1(nr,iseas,:))
          vhs_anom0 = vhs_data1(nr,iseas,:)-dim_avg(vhs_data1(nr,iseas,:))
          vai_anom0 = vai_data1(nr,iseas,:)-dim_avg(vai_data1(nr,iseas,:))
          vhi_anom1 = vhi_data2(nr,iseas,:)-dim_avg(vhi_data2(nr,iseas,:))
          vhs_anom1 = vhs_data2(nr,iseas,:)-dim_avg(vhs_data2(nr,iseas,:))
          vai_anom1 = vai_data2(nr,iseas,:)-dim_avg(vai_data2(nr,iseas,:))

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
          y1 = vhi_data1(nr,iseas,:)
          y2 = vhs_data1(nr,iseas,:)
          y3 = vai_data1(nr,iseas,:)
          vhi_anom0 = vhi_data1(nr,iseas,:)-dim_avg(vhi_data1(nr,iseas,:))
          vhs_anom0 = vhs_data1(nr,iseas,:)-dim_avg(vhs_data1(nr,iseas,:))
          vai_anom0 = vai_data1(nr,iseas,:)-dim_avg(vai_data1(nr,iseas,:))
          y4 = vhi_anom0
          y5 = vhs_anom0
          y6 = vai_anom0

          x1 = fspan(1,ntimes_tot/12,ntimes_tot/12) - 1. + stringtofloat(yr1)
          x2 = x1

       end if

   end if

   wks1 = gsn_open_wks(wks_type,wkdir+plotname(nr,iseas))

   y1@long_name = region_titles(nr) + " Ice Volume 10~S~13~N~ m~S~3~N~"
   y2@long_name = region_titles(nr) + " Snow Volume 10~S~13~N~ m~S~3~N~"
   y3@long_name = region_titles(nr) + " Ice Area 10~S~12~N~ m~S~2~N~"

   y1@_FillValue = -999
   y2@_FillValue = -999
   y3@_FillValue = -999
   x1@units = "years"
   x1@long_name = "Years"

   res@tmXMajorGrid = True
   res@tmXMajorGridLineDashPattern = 2
   res@tmXMajorGridThicknessF = 1
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

;;      res@trYMinF = min((/min(y1),min(y1b)/))
      res@trYMinF = 0.
      res@trYMaxF = max((/max(y1),max(y1b)/))
;;      resb@trYMinF = min((/min(y1),min(y1b)/))
      resb@trYMinF = 0.
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
;;      res@trYMinF = min((/min(y2),min(y2b)/))
      res@trYMaxF = max((/max(y2),max(y2b)/))
;;      resb@trYMinF = min((/min(y2),min(y2b)/))
      resb@trYMaxF = max((/max(y2),max(y2b)/))
      plot2 = gsn_csm_x2y2(wks1,x1,x2,y2,y2b,res,resb)
;;      res@trYMinF = min((/min(y3),min(y3b)/))
      res@trYMaxF = max((/max(y3),max(y3b)/))
;;      resb@trYMinF = min((/min(y3),min(y3b)/))
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

   if (.not. climatol) then

      wks2 = gsn_open_wks(wks_type,wkdir+plotname2(nr,iseas))

      res2 = res
      resP2 = resP
      resP2@txString = title2(nr,iseas)

      y4@long_name = region_titles(nr) + " Ice Volume 10~S~13~N~ m~S~3~N~"
      y5@long_name = region_titles(nr) + " Snow Volume 10~S~13~N~ m~S~3~N~"
      y6@long_name = region_titles(nr) + " Ice Area 10~S~12~N~ m~S~2~N~"

      y4@_FillValue = -999
      y5@_FillValue = -999
      y6@_FillValue = -999
      x1@units = "years"
      x1@long_name = "Years"

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
   delete(x2)
   delete(resP@txString)

   if (ncases .gt. 1) then
      delete(y1b)
      delete(y2b)
      delete(y3b)
   end if

end do

end
