
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCLPATH/readobs.ncl"

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

chem = (/"NH","SH"/)

ext_mo_nh_1 = f1->ext_mo_nh
ext_mo_sh_1 = f1->ext_mo_sh

ndim = dimsizes(ext_mo_nh_1)
ntimes = ndim(0)

ext_data1 = new((/2,12/),float)

if (ncases .gt. 1) then

   ext_mo_nh_2 = f2->ext_mo_nh
   ext_mo_sh_2 = f2->ext_mo_sh

   ndim = dimsizes(ext_mo_nh_2)
   ntimes2 = ndim(0)

   ext_data2 = new((/2,12/),float)

end if

ext_mo_nh1 = onedtond(ext_mo_nh_1,(/ntimes/12,12/))
ext_mo_sh1 = onedtond(ext_mo_sh_1,(/ntimes/12,12/))

ext_mo_nh1!0 = "years"
ext_mo_nh1!1 = "months"
ext_mo_sh1!0 = "years"
ext_mo_sh1!1 = "months"

ext_data1(0,:) = dim_avg(ext_mo_nh1(months|:,years|:))
ext_data1(1,:) = dim_avg(ext_mo_sh1(months|:,years|:))

if (ncases .gt. 1) then

ext_mo_nh2 = onedtond(ext_mo_nh_2,(/ntimes/12,12/))
ext_mo_sh2 = onedtond(ext_mo_sh_2,(/ntimes/12,12/))

ext_mo_nh2!0 = "years"
ext_mo_nh2!1 = "months"
ext_mo_sh2!0 = "years"
ext_mo_sh2!1 = "months"

ext_data2(0,:) = dim_avg(ext_mo_nh2(months|:,years|:))
ext_data2(1,:) = dim_avg(ext_mo_sh2(months|:,years|:))

end if

if (ncases .gt. 1) then
else
end if

ext = new((/2,25,12/),float)
readobs(ext)

ext@long_name = "NSIDC sea ice extent"
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

do ihem=0,1

   if (ncases .gt. 1) then
      y = new((/3,12/),float)
      y(0,:) = ext_data1(ihem,:)
      y(1,:) = ext_data2(ihem,:)
      y(2,:) = ext_clim(ihem,:)

      res@xyExplicitLegendLabels = (/case_to_cont,case_to_diff,"NSIDC"/)
      res@xyLineColors = (/"blue","red","black"/)
      res@xyDashPatterns    = (/0,0,0/)
      res@xyLineThicknesses = (/5,5,5/)

      plotname = "clim_mo_"+chem(ihem)+"_diff"
      wks1 = gsn_open_wks(wks_type,wkdir + plotname)
   else
      y = new((/2,12/),float)
      y(0,:) = ext_data1(ihem,:)
      y(1,:) = ext_clim(ihem,:)

      res@xyExplicitLegendLabels = (/case_to_cont,"NSIDC"/)
      res@xyLineColors = (/"red","black"/)
      res@xyDashPatterns    = (/0,0/)
      res@xyLineThicknesses = (/5,5/)
      plotname = "clim_mo_"+chem(ihem)
      wks1 = gsn_open_wks(wks_type,wkdir + plotname)
   end if

   if (ihem .eq. 0) then
      y@long_name = "NH Sea Ice Extent 10~S~12~N~ m~S~2~N~"
   else
      y@long_name = "SH Sea Ice Extent 10~S~12~N~ m~S~2~N~"
   end if

;
; Add a legend.
;
   res@pmLegendDisplayMode    = "Always"                 ; Turn on legend
   res@pmLegendWidthF         = 0.325                     ; Resize legend width
   res@pmLegendHeightF        = 0.15                     ; and height
   res@pmLegendOrthogonalPosF = -0.5                    ; Move legend up
   res@pmLegendParallelPosF   = 0.4+int2flt(ihem)*0.2   ; and to the right.
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

end do ; ihem

end
