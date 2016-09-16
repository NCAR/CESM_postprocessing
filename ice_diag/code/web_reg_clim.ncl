
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

pre_proc_cont = getenv("PRE_PROC_ROOT_CONT")
pre_proc_diff = getenv("PRE_PROC_ROOT_DIFF")
wkdir = getenv("WKDIR")
obs_data = getenv("DIAGOBSROOT")
yr1 = getenv("YR1")
yr2 = getenv("YR2")
yr1_diff = getenv("YR1_DIFF")
yr2_diff = getenv("YR2_DIFF")
wks_type = getenv("PLOT_FORMAT")
wks_type@wkWidth  = stringtointeger(getenv("PLOT_RES"))
wks_type@wkHeight = stringtointeger(getenv("PLOT_RES"))

xyr1 = stringtofloat(yr1)
xyr1_diff = stringtofloat(yr1_diff)

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

region_titles = (/"Lab","GIN","Bar","ArcOC", "Sib","Beau","CArc","Bering","Okhotsk","Hudson",\
     "CAArch","Wed","Ross","Ind","Pac","BAm"/)

region_long_titles = (/"Labrador Sea","GIN Sea","Barents/Kara Sea","Arctic Ocean", "Siberian Sea",\
     "Beaufort Sea","Central Arctic Ocean","Bering Sea","Sea of Okhotsk","Hudson Bay",\
     "Canadian Archiplelago","Weddell Sea","Ross Sea","Indian sector","Pacific","Bellingshausen-Amundsen Sea"/)

ext_mo_Lab_1 = f1->ext_mo_Lab

ndim = dimsizes(ext_mo_Lab_1)
ntimes = ndim(0)
nregions = 16

ext_data1 = new((/nregions,12/),float)

; read in all regions for case1
ext_mo_GIN_1 = f1->ext_mo_GIN
ext_mo_Bar_1 = f1->ext_mo_Bar
ext_mo_ArcOc_1 = f1->ext_mo_ArcOc
ext_mo_Sib_1 = f1->ext_mo_Sib
ext_mo_Beau_1 = f1->ext_mo_Beau
ext_mo_CArc_1 = f1->ext_mo_CArc
ext_mo_Bering_1 = f1->ext_mo_Bering
ext_mo_Okhotsk_1 = f1->ext_mo_Okhotsk
ext_mo_Hudson_1 = f1->ext_mo_Hudson
ext_mo_CAArch_1 = f1->ext_mo_CAArch
ext_mo_Wed_1 = f1->ext_mo_Wed
ext_mo_Ross_1 = f1->ext_mo_Ross
ext_mo_Ind_1 = f1->ext_mo_Ind
ext_mo_Pac_1 = f1->ext_mo_Pac
ext_mo_BAm_1 = f1->ext_mo_BAm

if (ncases .gt. 1) then

   ext_mo_Lab_2 = f2->ext_mo_Lab

   ndim = dimsizes(ext_mo_Lab_2)
   ntimes2 = ndim(0)

   ext_data2 = new((/nregions,12/),float)

   ext_mo_GIN_2 = f2->ext_mo_GIN
   ext_mo_Bar_2 = f2->ext_mo_Bar
   ext_mo_ArcOc_2 = f2->ext_mo_ArcOc
   ext_mo_Sib_2 = f2->ext_mo_Sib
   ext_mo_Beau_2 = f2->ext_mo_Beau
   ext_mo_CArc_2 = f2->ext_mo_CArc
   ext_mo_Bering_2 = f2->ext_mo_Bering
   ext_mo_Okhotsk_2 = f2->ext_mo_Okhotsk
   ext_mo_Hudson_2 = f2->ext_mo_Hudson
   ext_mo_CAArch_2 = f2->ext_mo_CAArch
   ext_mo_Wed_2 = f2->ext_mo_Wed
   ext_mo_Ross_2 = f2->ext_mo_Ross
   ext_mo_Ind_2 = f2->ext_mo_Ind
   ext_mo_Pac_2 = f2->ext_mo_Pac
   ext_mo_BAm_2 = f2->ext_mo_BAm

end if

ext_mo_Lab1 = onedtond(ext_mo_Lab_1,(/ntimes/12,12/))
ext_mo_GIN1 = onedtond(ext_mo_GIN_1,(/ntimes/12,12/))
ext_mo_Bar1 = onedtond(ext_mo_Bar_1,(/ntimes/12,12/))
ext_mo_ArcOc1 = onedtond(ext_mo_ArcOc_1,(/ntimes/12,12/))
ext_mo_Sib1 = onedtond(ext_mo_Sib_1,(/ntimes/12,12/))
ext_mo_Beau1 = onedtond(ext_mo_Beau_1,(/ntimes/12,12/))
ext_mo_CArc1 = onedtond(ext_mo_CArc_1,(/ntimes/12,12/))
ext_mo_Bering1 = onedtond(ext_mo_Bering_1,(/ntimes/12,12/))
ext_mo_Okhotsk1 = onedtond(ext_mo_Okhotsk_1,(/ntimes/12,12/))
ext_mo_Hudson1 = onedtond(ext_mo_Hudson_1,(/ntimes/12,12/))
ext_mo_CAArch1 = onedtond(ext_mo_CAArch_1,(/ntimes/12,12/))
ext_mo_Wed1 = onedtond(ext_mo_Wed_1,(/ntimes/12,12/))
ext_mo_Ross1 = onedtond(ext_mo_Ross_1,(/ntimes/12,12/))
ext_mo_Ind1 = onedtond(ext_mo_Ind_1,(/ntimes/12,12/))
ext_mo_Pac1 = onedtond(ext_mo_Pac_1,(/ntimes/12,12/))
ext_mo_BAm1 = onedtond(ext_mo_BAm_1,(/ntimes/12,12/))

ext_mo_Lab1!0 = "years"
ext_mo_Lab1!1 = "months"
ext_mo_GIN1!0 = "years"
ext_mo_GIN1!1 = "months"
ext_mo_Bar1!0 = "years"
ext_mo_Bar1!1 = "months"
ext_mo_ArcOc1!0 = "years"
ext_mo_ArcOc1!1 = "months"
ext_mo_Sib1!0 = "years"
ext_mo_Sib1!1 = "months"
ext_mo_Beau1!0 = "years"
ext_mo_Beau1!1 = "months"
ext_mo_CArc1!0 = "years"
ext_mo_CArc1!1 = "months"
ext_mo_Bering1!0 = "years"
ext_mo_Bering1!1 = "months"
ext_mo_Okhotsk1!0 = "years"
ext_mo_Okhotsk1!1 = "months"
ext_mo_Hudson1!0 = "years"
ext_mo_Hudson1!1 = "months"
ext_mo_CAArch1!0 = "years"
ext_mo_CAArch1!1 = "months"
ext_mo_Wed1!0 = "years"
ext_mo_Wed1!1 = "months"
ext_mo_Ross1!0 = "years"
ext_mo_Ross1!1 = "months"
ext_mo_Ind1!0 = "years"
ext_mo_Ind1!1 = "months"
ext_mo_Pac1!0 = "years"
ext_mo_Pac1!1 = "months"
ext_mo_BAm1!0 = "years"
ext_mo_BAm1!1 = "months"

ext_data1(0,:) = dim_avg(ext_mo_Lab1(months|:,years|:))
ext_data1(1,:) = dim_avg(ext_mo_GIN1(months|:,years|:))
ext_data1(2,:) = dim_avg(ext_mo_Bar1(months|:,years|:))
ext_data1(3,:) = dim_avg(ext_mo_ArcOc1(months|:,years|:))
ext_data1(4,:) = dim_avg(ext_mo_Sib1(months|:,years|:))
ext_data1(5,:) = dim_avg(ext_mo_Beau1(months|:,years|:))
ext_data1(6,:) = dim_avg(ext_mo_CArc1(months|:,years|:))
ext_data1(7,:) = dim_avg(ext_mo_Bering1(months|:,years|:))
ext_data1(8,:) = dim_avg(ext_mo_Okhotsk1(months|:,years|:))
ext_data1(9,:) = dim_avg(ext_mo_Hudson1(months|:,years|:))
ext_data1(10,:) = dim_avg(ext_mo_CAArch1(months|:,years|:))
ext_data1(11,:) = dim_avg(ext_mo_Wed1(months|:,years|:))
ext_data1(12,:) = dim_avg(ext_mo_Ross1(months|:,years|:))
ext_data1(13,:) = dim_avg(ext_mo_Ind1(months|:,years|:))
ext_data1(14,:) = dim_avg(ext_mo_Pac1(months|:,years|:))
ext_data1(15,:) = dim_avg(ext_mo_BAm1(months|:,years|:))

if (ncases .gt. 1) then

   ext_mo_Lab2 = onedtond(ext_mo_Lab_2,(/ntimes/12,12/))
   ext_mo_GIN2 = onedtond(ext_mo_GIN_2,(/ntimes/12,12/))
   ext_mo_Bar2 = onedtond(ext_mo_Bar_2,(/ntimes/12,12/))
   ext_mo_ArcOc2 = onedtond(ext_mo_ArcOc_2,(/ntimes/12,12/))
   ext_mo_Sib2 = onedtond(ext_mo_Sib_2,(/ntimes/12,12/))
   ext_mo_Beau2 = onedtond(ext_mo_Beau_2,(/ntimes/12,12/))
   ext_mo_CArc2 = onedtond(ext_mo_CArc_2,(/ntimes/12,12/))
   ext_mo_Bering2 = onedtond(ext_mo_Bering_2,(/ntimes/12,12/))
   ext_mo_Okhotsk2 = onedtond(ext_mo_Okhotsk_2,(/ntimes/12,12/))
   ext_mo_Hudson2 = onedtond(ext_mo_Hudson_2,(/ntimes/12,12/))
   ext_mo_CAArch2 = onedtond(ext_mo_CAArch_2,(/ntimes/12,12/))
   ext_mo_Wed2 = onedtond(ext_mo_Wed_2,(/ntimes/12,12/))
   ext_mo_Ross2 = onedtond(ext_mo_Ross_2,(/ntimes/12,12/))
   ext_mo_Ind2 = onedtond(ext_mo_Ind_2,(/ntimes/12,12/))
   ext_mo_Pac2 = onedtond(ext_mo_Pac_2,(/ntimes/12,12/))
   ext_mo_BAm2 = onedtond(ext_mo_BAm_2,(/ntimes/12,12/))

   ext_mo_Lab2!0 = "years"
   ext_mo_Lab2!1 = "months"
   ext_mo_GIN2!0 = "years"
   ext_mo_GIN2!1 = "months"
   ext_mo_Bar2!0 = "years"
   ext_mo_Bar2!1 = "months"
   ext_mo_ArcOc2!0 = "years"
   ext_mo_ArcOc2!1 = "months"
   ext_mo_Sib2!0 = "years"
   ext_mo_Sib2!1 = "months"
   ext_mo_Beau2!0 = "years"
   ext_mo_Beau2!1 = "months"
   ext_mo_CArc2!0 = "years"
   ext_mo_CArc2!1 = "months"
   ext_mo_Bering2!0 = "years"
   ext_mo_Bering2!1 = "months"
   ext_mo_Okhotsk2!0 = "years"
   ext_mo_Okhotsk2!1 = "months"
   ext_mo_Hudson2!0 = "years"
   ext_mo_Hudson2!1 = "months"
   ext_mo_CAArch2!0 = "years"
   ext_mo_CAArch2!1 = "months"
   ext_mo_Wed2!0 = "years"
   ext_mo_Wed2!1 = "months"
   ext_mo_Ross2!0 = "years"
   ext_mo_Ross2!1 = "months"
   ext_mo_Ind2!0 = "years"
   ext_mo_Ind2!1 = "months"
   ext_mo_Pac2!0 = "years"
   ext_mo_Pac2!1 = "months"
   ext_mo_BAm2!0 = "years"
   ext_mo_BAm2!1 = "months"

   ext_data2(0,:) = dim_avg(ext_mo_Lab2(months|:,years|:))
   ext_data2(1,:) = dim_avg(ext_mo_GIN2(months|:,years|:))
   ext_data2(2,:) = dim_avg(ext_mo_Bar2(months|:,years|:))
   ext_data2(3,:) = dim_avg(ext_mo_ArcOc2(months|:,years|:))
   ext_data2(4,:) = dim_avg(ext_mo_Sib2(months|:,years|:))
   ext_data2(5,:) = dim_avg(ext_mo_Beau2(months|:,years|:))
   ext_data2(6,:) = dim_avg(ext_mo_CArc2(months|:,years|:))
   ext_data2(7,:) = dim_avg(ext_mo_Bering2(months|:,years|:))
   ext_data2(8,:) = dim_avg(ext_mo_Okhotsk2(months|:,years|:))
   ext_data2(9,:) = dim_avg(ext_mo_Hudson2(months|:,years|:))
   ext_data2(10,:) = dim_avg(ext_mo_CAArch2(months|:,years|:))
   ext_data2(11,:) = dim_avg(ext_mo_Wed2(months|:,years|:))
   ext_data2(12,:) = dim_avg(ext_mo_Ross2(months|:,years|:))
   ext_data2(13,:) = dim_avg(ext_mo_Ind2(months|:,years|:))
   ext_data2(14,:) = dim_avg(ext_mo_Pac2(months|:,years|:))
   ext_data2(15,:) = dim_avg(ext_mo_BAm2(months|:,years|:))

end if

ext = new((/nregions,12/),float)
ext_obs = obs_data+"/SSMI.ice_extent.1981-2005.monthly.regional.txt"
ncol = nregions + 3					; file has month, NH and SH in addition to regional avgs
data = readAsciiTable(ext_obs,ncol,"float",(/1,0/))

data!0 = "month"
data!1 = "region"
ext(:10,:) = data(region|2:12,month|:)
ext(11:,:) = data(region|14:,month|:)

ext@long_name = "SSMI sea ice extent"
ext@_FillValue = -9999

ext_clim = dim_avg_n(ext,1)

res = True
res@txFont   = "helvetica"
res@txFuncCode = "~"
res@tiMainFont          = "helvetica"
res@tiMainFuncCode          = "~"
res@tiXAxisFont          = "helvetica"
res@tiXAxisFuncCode          = "~"
res@tiYAxisFont          = "helvetica"
res@tiYAxisFuncCode          = "~"
res@tmXBLabelFont          = "helvetica"
res@tmYLLabelFont          = "helvetica"

res@trXMinF = 1.
res@trXMaxF = 12.
res@trYMinF = 0.

x = fspan(1,12,12)
x!0 = "month"
x@long_name = "Month"

do iregion=0,nregions-1

   if (ncases .gt. 1) then
      y = new((/3,12/),float)
      y(0,:) = ext_data1(iregion,:)
      y(1,:) = ext_data2(iregion,:)
      y(2,:) = ext(iregion,:)

      res@xyExplicitLegendLabels = (/case_to_cont,case_to_diff,"SSMI"/)
      res@xyLineColors = (/"blue","red","black"/)
      res@xyDashPatterns    = (/0,0,0/)
      res@xyLineThicknesses = (/5,5,5/)

      plotname = "clim_mo_"+region_titles(iregion)+"_diff"
      wks1 = gsn_open_wks(wks_type,wkdir + plotname)
   else
      y = new((/2,12/),float)
      y(0,:) = ext_data1(iregion,:)
      y(1,:) = ext(iregion,:)

      res@xyExplicitLegendLabels = (/case_to_cont,"SSMI"/)
      res@xyLineColors = (/"red","black"/)
      res@xyDashPatterns    = (/0,0/)
      res@xyLineThicknesses = (/5,5/)
      plotname = "clim_mo_"+region_titles(iregion)
      wks1 = gsn_open_wks(wks_type,wkdir + plotname)
   end if

   y@long_name = region_long_titles(iregion) +"Sea Ice Extent 10~S~12~N~ m~S~2~N~"

;
; Add a legend.
;
   res@pmLegendDisplayMode    = "Always"                 ; Turn on legend
   res@pmLegendWidthF         = 0.325                     ; Resize legend width
   res@pmLegendHeightF        = 0.15                     ; and height
   res@pmLegendOrthogonalPosF = -0.5
   if (iregion .lt. 11)	then				; NH
      res@pmLegendParallelPosF   = 0.4                      ; and to the right.
   else							; SH
      res@pmLegendParallelPosF   = 0.6                      ; and to the right.
   end if
   res@lgAutoManage = False
   res@lgBoxMinorExtentF = 0.1
   res@lgLabelFontHeightF = 0.015
   res@lgPerimOn = False

   plot1 = gsn_csm_xy(wks1,x,y,res)

   delete(wks1)
   delete(y)
   delete(res@xyExplicitLegendLabels)
   delete(res@xyLineColors)
   delete(res@xyLineThicknesses)
   delete(res@xyDashPatterns)

end do ; iregion

end
