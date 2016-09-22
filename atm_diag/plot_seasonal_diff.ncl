; NCL script
; plot_season_diff.ncl
; Mark Stevens, Sept 2001
;************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
load "$DIAG_CODE/functions_contrib.ncl" 
load "$DIAG_CODE/functions_surfaces.ncl"
;************************************************************
begin

 compare    = getenv("COMPARE")
 color_type = getenv("COLORTYPE")
 rgb_file   = getenv("RGB_FILE")
 plot_type  = getenv("PLOTTYPE")
 version    = getenv("DIAG_VERSION")
 paleo      = getenv("PALEO")
 wkdir      = getenv("WKDIR")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")
 ncdf_djf_mode = getenv("NCDF_DJF_MODE")
 ncdf_jja_mode = getenv("NCDF_JJA_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename
 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
 end if
 if (paleo .eq. "True") then
   PALEO = True
   paleocoast1 = getenv("PALEOCOAST1")
   if (compare .eq. "USER") then
     paleocoast2 = getenv("PALEOCOAST2")
   end if
 else
   PALEO = False
 end if


; CASE 1 MODEL
 inptr1_djf = addfile(infile1+"_DJF_climo.nc","r")
 inptr1_jja = addfile(infile1+"_JJA_climo.nc","r")
 if (ncdf_djf_mode .eq. "write") then
   outptr1_djf = addfile(outfile1+"_DJF_plotvars.nc","w")
 else
   outptr1_djf = addfile(outfile1+"_DJF_plotvars.nc","c")
 end if
 if (ncdf_jja_mode .eq. "write") then
   outptr1_jja = addfile(outfile1+"_JJA_plotvars.nc","w")
 else
   outptr1_jja = addfile(outfile1+"_JJA_plotvars.nc","c")
 end if
 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1_djf@case         ; case names
 end if
 if (isatt(inptr1_djf,"yrs_averaged")) then
   yrs_ave1 = inptr1_djf@yrs_averaged
 end if

 if (compare .eq. "OBS") then
;  CASE 2 IS OBS
   djf_erai = addfile(infile2+"/ERAI_DJF_climo.nc","r")
   jja_erai = addfile(infile2+"/ERAI_JJA_climo.nc","r")
   djf_era40 = addfile(infile2+"/ERA40_DJF_climo.nc","r")
   jja_era40 = addfile(infile2+"/ERA40_JJA_climo.nc","r")
   djf_jra25 = addfile(infile2+"/JRA25_DJF_climo.nc","r")
   jja_jra25 = addfile(infile2+"/JRA25_JJA_climo.nc","r")
   djf_airs  = addfile(infile2+"/AIRS_DJF_climo.nc","r")
   jja_airs  = addfile(infile2+"/AIRS_JJA_climo.nc","r")
   djf_erbe = addfile(infile2+"/ERBE_DJF_climo.nc","r")
   jja_erbe = addfile(infile2+"/ERBE_JJA_climo.nc","r")
   djf_ceres2 = addfile(infile2+"/CERES-EBAF_DJF_climo.nc","r")
   jja_ceres2 = addfile(infile2+"/CERES-EBAF_JJA_climo.nc","r")
   djf_ceres = addfile(infile2+"/CERES_DJF_climo.nc","r")
   jja_ceres = addfile(infile2+"/CERES_JJA_climo.nc","r")
   djf_gpcp = addfile(infile2+"/GPCP_DJF_climo.nc","r")
   jja_gpcp = addfile(infile2+"/GPCP_JJA_climo.nc","r")
   djf_isccp = addfile(infile2+"/ISCCP_DJF_climo.nc","r")
   jja_isccp = addfile(infile2+"/ISCCP_JJA_climo.nc","r")
   djf_cloudsat = addfile(infile2+"/CLOUDSAT_DJF_climo.nc","r")
   jja_cloudsat = addfile(infile2+"/CLOUDSAT_JJA_climo.nc","r")
   djf_legs = addfile(infile2+"/LEGATES_DJF_climo.nc","r")
   jja_legs = addfile(infile2+"/LEGATES_JJA_climo.nc","r")
   djf_merra = addfile(infile2+"/MERRA_DJF_climo.nc","r")
   jja_merra = addfile(infile2+"/MERRA_JJA_climo.nc","r")
   djf_nvap = addfile(infile2+"/NVAP_DJF_climo.nc","r")
   jja_nvap = addfile(infile2+"/NVAP_JJA_climo.nc","r")
   djf_xa = addfile(infile2+"/XIEARKIN_DJF_climo.nc","r")
   jja_xa = addfile(infile2+"/XIEARKIN_JJA_climo.nc","r")
 else
;  CASE 2 IS MODEL
   inptr2_djf = addfile(infile2+"_DJF_climo.nc","r")
   inptr2_jja = addfile(infile2+"_JJA_climo.nc","r")
   if (ncdf_djf_mode .eq. "write") then
     outptr2_djf = addfile(outfile2+"_DJF_plotvars.nc","w")
   else
     outptr2_djf = addfile(outfile2+"_DJF_plotvars.nc","c")
   end if
   if (ncdf_jja_mode .eq. "write") then
     outptr2_jja = addfile(outfile2+"_JJA_plotvars.nc","w")
   else
     outptr2_jja = addfile(outfile2+"_JJA_plotvars.nc","c")
   end if
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2_djf@case         ; case names
   end if
   if (isatt(inptr2_djf,"yrs_averaged")) then
     yrs_ave2 = inptr2_djf@yrs_averaged
   end if
 end if

;------------------------------------------------------------------
; define variables to plot
erai_vars = (/"T_850_ERAI","PREH2O_ERAI"/)
era40_vars = (/"T_850_ERA40","PREH2O_ERA40"/)
jra25_vars = (/"T_850_JRA25","PREH2O_JRA25"/)
airs_vars  =  (/"T_850_AIRS"/)
erbe_vars = (/"SWCF_ERBE","LWCF_ERBE"/)
ceres2_vars = (/"SWCF_CERES-EBAF","LWCF_CERES-EBAF"/)
ceres_vars = (/"SWCF_CERES","LWCF_CERES"/)
gpcp_vars = (/"PRECT_GPCP"/)
isccp_vars = (/"CLDTOT_ISCCP"/)
cloudsat_vars = (/"CLDTOT_CLOUDSAT"/)
leg_vars = (/"TREFHT_LEGATES"/)
merra_vars = (/"PSL_MERRA","T_850_MERRA","PREH2O_MERRA"/)
nvap_vars = (/"PREH2O_NVAP"/)
xa_vars = (/"PRECT_XA"/)

contours_PSL=(/-25,-20,-15,-10,-6,-4,-2,0,2,4,6,10,15,20,25/) ; PSL
contours_TREFHT=(/-35,-25,-20,-15,-10,-5,-2,0,2,5,10,15,20,25,35/) ;TREFHT
contours_T850=(/-30,-25,-20,-15,-10,-5,-2,0,2,5,10,15,20,25,30/) ;T at 850
contours_SWCF=(/-125,-100,-75,-50,-30,-20,-10,0,10,20,30,50,75,100,125/) ;SWCF
contours_LWCF=(/-70,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,70/) ;LWCF
contours_LWCF=(/-35,-30,-15,-10,-6,-4,-2, 0, 2,4,6,10,15,30,35/) ; LWCF  ++ ceh
contours_PREH2O=(/-40,-30,-20,-15,-10,-5,-2,0,2,5,10,15,20,30,40/) ; PREH2O
contours_PRECT=(/-18,-14,-10,-6,-4,-2,-1,0,1,2,4,6,10,14,18/) ; PRECT
contours_CLDTOT=(/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/) ; CLDTOT
contours_ISCCP=(/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/) ; ISCCP

if (compare .eq. "OBS") then
  obsvars = (/"PSL_MERRA","TREFHT_LEGATES","T_850_MERRA", \
           "T_850_ERAI","SWCF_ERBE","LWCF_ERBE","PREH2O_MERRA","PREH2O_NVAP", \
           "PREH2O_ERAI","PRECT_XA","PRECT_GPCP","CLDTOT_ISCCP", \
           "T_850_ERA40","PREH2O_ERA40","CLDTOT_CLOUDSAT","T_850_AIRS", \
           "SWCF_CERES","LWCF_CERES","SWCF_CERES-EBAF","LWCF_CERES-EBAF", \
           "T_850_JRA25","PREH2O_JRA25"/)
; corresponding model variables
  vars = (/"PSL","TREFHT","T_850","T_850","SWCF","LWCF", \
           "PREH2O","PREH2O","PREH2O","PRECT","PRECT","CLDTOT", \
           "T_850","PREH2O","CLDTOT","T_850","SWCF","LWCF","SWCF","LWCF",\
           "T_850","PREH2O"/)

  contours = (/contours_PSL,contours_TREFHT,contours_T850,contours_T850,contours_SWCF,contours_LWCF, \
           contours_PREH2O,contours_PREH2O,contours_PREH2O,contours_PRECT,contours_PRECT,contours_CLDTOT, \
           contours_T850,contours_PREH2O,contours_CLDTOT,contours_T850,contours_SWCF,contours_LWCF,contours_SWCF,contours_LWCF,\
           contours_T850,contours_PREH2O/)

else
  vars = (/"PSL","TREFHT","T_850","SWCF","LWCF","PREH2O","PRECT","CLDTOT"/)
  contours = (/contours_PSL,contours_TREFHT,contours_T850,contours_SWCF,contours_LWCF,contours_PREH2O,contours_PRECT,contours_CLDTOT/)

end if
nvars = dimsizes(vars)
plot = new(2,graphic)
;-------------------------------------------------------------------
; common resources for plots
res = True    
res@mpCenterLonF = 180  
res@mpGeophysicalLineThicknessF = 2.0
res@gsnDraw = False               ; Do not draw plot
res@gsnFrame = False               ; Do not advance frame
res@txFontHeightF = 0.017
res@tiMainString = ""
if (color_type .eq. "COLOR") then
  cmap = RGBtoCmap (rgb_file)
  res@lbTitleOn = True
  res@lbOrientation = "Vertical"
  res@lbBoxMinorExtentF = 0.15
  res@lbLabelFontHeightF = 0.013
  res@lbTitleFontHeightF = 0.013
  res@mpFillOn = False
  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnLineLabelsOn = False
  res@cnLevelSelectionMode="ExplicitLevels"
else
; resources for black and white plots
  res@mpFillOn = True 
  res@cnFillOn = False
  res@cnLinesOn = True 
  res@cnLineLabelInterval = 1
  res@cnLineLabelsOn = True 
  res@cnLineLabelFontHeightF = .010
  res@cnInfoLabelOrthogonalPosF = -0.06     ; move info label
  res@cnInfoLabelFontHeightF = .010
  res@cnLevelSelectionMode = "ManualLevels"
  cnlvls = 15
end if
;----------------------------------------------------------------
; common resources for panel plot
 pan =True
 pan@gsnMaximize = True
 pan@txString = "DJF-JJA"
 pan@txFont = "helvetica-bold"
 pan@txFontHeightF = 0.02
 pan@gsnFrame = False
 pan@gsnPaperOrientation = "portrait"
;************************************************************************
do i = 0, nvars-1

  ;print("==="+obsvars(i))

  if (vars(i) .eq. "CLDTOT") then
    DJF = get_CLDTOT (inptr1_djf,outptr1_djf)
    JJA = get_CLDTOT (inptr1_jja,outptr1_jja)
    A = DJF
    A = (/DJF-JJA/)
  end if
  if (vars(i) .eq. "LWCF") then
    if (compare .eq. "OBS") then
      DJF = get_LWCFTOA (inptr1_djf,outptr1_djf)
      JJA = get_LWCFTOA (inptr1_jja,outptr1_jja)
    else
      DJF = get_LWCFTOM (inptr1_djf,outptr1_djf)
      JJA = get_LWCFTOM (inptr1_jja,outptr1_jja)
    end if
    A = DJF
    A = (/DJF-JJA/)
  end if
  if (vars(i) .eq. "PRECT") then
    DJF = get_PRECT (inptr1_djf,outptr1_djf)
    JJA = get_PRECT (inptr1_jja,outptr1_jja)
    A = DJF
    A = (/DJF-JJA/)
  end if
  if (vars(i) .eq. "PREH2O") then
    DJF = get_PREH2O (inptr1_djf,outptr1_djf)
    JJA = get_PREH2O (inptr1_jja,outptr1_jja)
    A = DJF
    A = (/DJF-JJA/)
  end if
  if (vars(i) .eq. "PSL") then
    DJF = get_PSL (inptr1_djf,outptr1_djf)
    JJA = get_PSL (inptr1_jja,outptr1_jja)
    A = DJF
    A = (/DJF-JJA/)
  end if
  if (vars(i) .eq. "SWCF") then
    if (compare .eq. "OBS") then
      DJF = get_SWCFTOA (inptr1_djf,outptr1_djf)
      JJA = get_SWCFTOA (inptr1_jja,outptr1_jja)
    else
      DJF = get_SWCFTOM (inptr1_djf,outptr1_djf)
      JJA = get_SWCFTOM (inptr1_jja,outptr1_jja)
    end if
    A = DJF
    A = (/DJF-JJA/)
  end if
  if (vars(i) .eq. "T_850") then
    DJF = get_T_850 (inptr1_djf,outptr1_djf)
    JJA = get_T_850 (inptr1_jja,outptr1_jja)
    A = DJF
    A = (/DJF-JJA/)
  end if
  if (vars(i) .eq. "TREFHT") then
    DJF = get_TREFHT (inptr1_djf,outptr1_djf)
    JJA = get_TREFHT (inptr1_jja,outptr1_jja)
    A = DJF
    A = (/DJF-JJA/)
  end if

  if (all(DJF.eq.-999.)) then
    print (vars(i)+" not present in test case input file.")
    delete (DJF)
    delete (JJA)
    delete (A)
    continue 
  else
    delete (DJF)
    delete (JJA)
  end if

  if (compare .eq. "OBS") then
;   CASE 2 IS OBS DATA
    if (any(obsvars(i).eq.erai_vars)) then
      inptr2_djf = djf_erai
      inptr2_jja = jja_erai
      case2 = "ERAI"
    end if 
    if (any(obsvars(i).eq.era40_vars)) then
      inptr2_djf = djf_era40
      inptr2_jja = jja_era40
      case2 = "ERA40"
    end if 
     if (any(obsvars(i).eq.jra25_vars)) then
      inptr2_djf = djf_jra25
      inptr2_jja = jja_jra25
      case2 = "JRA25"
    end if 
    if (any(obsvars(i).eq.airs_vars)) then
      inptr2_djf = djf_airs
      inptr2_jja = jja_airs
      case2 = "AIRS"
    end if 
    if (any(obsvars(i).eq.erbe_vars)) then
      inptr2_djf = djf_erbe
      inptr2_jja = jja_erbe
      case2 = "ERBE"
    end if 
    if (any(obsvars(i).eq.ceres2_vars)) then
      inptr2_djf = djf_ceres2
      inptr2_jja = jja_ceres2
      case2 = "CERES-EBAF"
    end if 
    if (any(obsvars(i).eq.ceres_vars)) then
      inptr2_djf = djf_ceres
      inptr2_jja = jja_ceres
      case2 = "CERES"
    end if 
    if (any(obsvars(i).eq.gpcp_vars)) then
      inptr2_djf = djf_gpcp
      inptr2_jja = jja_gpcp
      case2 = "GPCP"
    end if 
    if (any(obsvars(i).eq.isccp_vars)) then
      inptr2_djf = djf_isccp
      inptr2_jja = jja_isccp
      case2 = "ISCCP"
    end if 
    if (any(obsvars(i).eq.cloudsat_vars)) then
      inptr2_djf = djf_cloudsat
      inptr2_jja = jja_cloudsat
      case2 = "CLOUDSAT"
    end if 
    if (any(obsvars(i).eq.leg_vars)) then
      inptr2_djf = djf_legs
      inptr2_jja = jja_legs
      case2 = "LEGATES"
    end if
    if (any(obsvars(i).eq.merra_vars)) then
      inptr2_djf = djf_merra
      inptr2_jja = jja_merra
      case2 = "MERRA"
    end if 
    if (any(obsvars(i).eq.nvap_vars)) then
      inptr2_djf = djf_nvap
      inptr2_jja = jja_nvap
      case2 = "NVAP"
    end if 
    if (any(obsvars(i).eq.xa_vars)) then
      inptr2_djf = djf_xa
      inptr2_jja = jja_xa
      case2 = "XIE-ARKIN"
    end if
    if (vars(i) .eq. "T_850") then
      DJF = inptr2_djf->T(0,{850},:,:)
      JJA = inptr2_jja->T(0,{850},:,:)
      B = DJF
      B = (/DJF-JJA/)
      B@long_name = "850mb temperature"
      B@units = "K"
    else 
      if (obsvars(i).eq."CLDTOT_CLOUDSAT") then ; No time dimension.
        DJF = inptr2_djf->$vars(i)$
        JJA = inptr2_jja->$vars(i)$
      else
        DJF = inptr2_djf->$vars(i)$(0,:,:)
        JJA = inptr2_jja->$vars(i)$(0,:,:)
      end if
      B = DJF
      B = (/DJF-JJA/)
    end if
  else
;   CASE 2 IS MODEL
    if (vars(i) .eq. "CLDTOT") then
      DJF = get_CLDTOT (inptr2_djf,outptr2_djf)
      JJA = get_CLDTOT (inptr2_jja,outptr2_jja)
      B = DJF
      B = (/DJF-JJA/)
    end if
    if (vars(i) .eq. "LWCF") then
      DJF = get_LWCFTOM (inptr2_djf,outptr2_djf)
      JJA = get_LWCFTOM (inptr2_jja,outptr2_jja)
      B = DJF
      B = (/DJF-JJA/)
    end if
    if (vars(i) .eq. "PRECT") then
      DJF = get_PRECT (inptr2_djf,outptr2_djf)
      JJA = get_PRECT (inptr2_jja,outptr2_jja)
      B = DJF
      B = (/DJF-JJA/)
    end if
    if (vars(i) .eq. "PREH2O") then
      DJF = get_PREH2O (inptr2_djf,outptr2_djf)
      JJA = get_PREH2O (inptr2_jja,outptr2_jja)
      B = DJF
      B = (/DJF-JJA/)
    end if
    if (vars(i) .eq. "PSL") then
      DJF = get_PSL (inptr2_djf,outptr2_djf)
      JJA = get_PSL (inptr2_jja,outptr2_jja)
      B = DJF
      B = (/DJF-JJA/)
    end if
    if (vars(i) .eq. "SWCF") then
      DJF = get_SWCFTOM (inptr2_djf,outptr2_djf)
      JJA = get_SWCFTOM (inptr2_jja,outptr2_jja)
      B = DJF
      B = (/DJF-JJA/)
    end if
    if (vars(i) .eq. "T_850") then
      DJF = get_T_850 (inptr2_djf,outptr2_djf)
      JJA = get_T_850 (inptr2_jja,outptr2_jja)
      B = DJF
      B = (/DJF-JJA/)
    end if
    if (vars(i) .eq. "TREFHT") then
      DJF = get_TREFHT (inptr2_djf,outptr2_djf)
      JJA = get_TREFHT (inptr2_jja,outptr2_jja)
      B = DJF
      B = (/DJF-JJA/)
    end if
  end if

  if (all(DJF.eq.-999.)) then
    print (vars(i)+" not present in control case input file.")
    delete (DJF)
    delete (JJA)
    delete (A)
    delete (B)
    continue 
  else
    delete (DJF)
    delete (JJA)
  end if

;----------------------- Open files for plots -------------------
  if (color_type .eq. "COLOR") then
    if (compare .eq. "OBS") then
      wks = gsn_open_wks(plot_type,wkdir+"set9_"+obsvars(i)+"_obsc")
    else
      wks = gsn_open_wks(plot_type,wkdir+"set9_"+vars(i)+"_c")
    end if
    gsn_define_colormap(wks,cmap)
  else
    if (compare .eq. "OBS") then
      wks = gsn_open_wks(plot_type,wkdir+"set9_"+obsvars(i)+"_obs")
    else
      wks = gsn_open_wks(plot_type,wkdir+"set9_"+vars(i))
    end if
  end if
;------------------------------------------------------------------

  min1 = min(A)
  max1 = max(A)
  min2 = min(B)
  max2 = max(B)

; CASE 1 PLOT
  if (PALEO) then
    res@mpDataBaseVersion = "Ncarg4_1"
    res@mpDataSetName = paleocoast1
  end if
  if (isvar("yrs_ave1")) then
    res@gsnCenterString  = case1+" (yrs "+yrs_ave1+")"
  else 
    res@gsnCenterString  = case1 
  end if
  res@gsnLeftString = A@long_name
  if (color_type .eq. "COLOR") then
    res@cnLevels = contours(i,:)
    res@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                       " MAX = "+sprintf("%6.2f",max1)
    plot(0) = gsn_csm_contour_map_ce(wks,A,res)
    delete (res@lbTitleString)
  else
    minab = min((/min1,min2/))
    maxab = min((/max1,max2/))
    mnmxint = nice_mnmxintvl(minab,maxab,cnlvls,False)
    res@cnMinLevelValF = mnmxint(0)
    res@cnMaxLevelValF = mnmxint(1)
    res@cnLevelSpacingF = mnmxint(2)
    plot(0) = gsn_csm_contour_map(wks,A,res)
    plot(0) = ZeroNegDashLineContour (plot(0))
  end if
  delete (res@gsnCenterString)

; CASE 2 PLOT
  if (isvar("yrs_ave2")) then
    res@gsnCenterString  = case2+" (yrs "+yrs_ave2+")"
  else 
    res@gsnCenterString  = case2 
  end if
  if (PALEO) then
    if (compare.eq."USER") then 
      res@mpDataSetName = paleocoast2
    else
      delete(res@mpDataBaseVersion)
      delete(res@mpDataSetName)
    end if
  end if

  if (color_type .eq. "COLOR") then
    res@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                       " MAX = "+sprintf("%6.2f",max2)
    plot(1) = gsn_csm_contour_map_ce(wks,B,res)
    delete (res@lbTitleString)
  else
    plot(1) = gsn_csm_contour_map(wks,B,res)
    plot(1) = ZeroNegDashLineContour (plot(1))
  end if
  delete(res@gsnCenterString)
  delete (min1)
  delete (max1)
  delete (min2)
  delete (max2)

  if (time_stamp .eq. "True") then
    pan@gsnPanelBottom = 0.06 
    gsn_panel(wks,plot,(/2,1/),pan) 
    infoTimeStamp(wks, 0.011, "DIAG Version: "+version)
  else
    gsn_panel(wks,plot,(/2,1/),pan) 
  end if
  frame (wks)
  delete(A)
  delete(B)
end do        

end
