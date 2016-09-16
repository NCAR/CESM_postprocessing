;----------------------------------------------------------------------
; Original code written by Dennis Shea and modeified by Sheri Mickelson 
; March 2013
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin
;---Specify remap method  
;   remap_method = "bilinear"     ; "bilinear" , "patch", "conserve"
    remap_method = "conserve"     ; "bilinear" , "patch", "conserve"

;---Specify source SE grid resolution
;   SE_res       = "ne30"
    SE_res       = "ne120"

;---Specify name of destination grid
;   DstGridName  = "FV_192x288"
    DstGridName  = "FV_768x1152"

;---Sample plot options
    pltDir   = "./"
    pltType  = "ps"
    pltName  = "SE_"+str_upper(SE_res)+"_to_"+DstGridName

;---Data file containing source grid (sample)
;   SE_dir   = "/glade/scratch/oleson/ANALYSIS/cam5clm45bgc_ne30cesm12rel06_2000b/"
;   SE_file  = "SE_NE30_cam5clm45bgc_ne30cesm12rel06_2000b_ANN_climo.nc"
    SE_dir   = "/glade/scratch/oleson/ANALYSIS/hybrid_v5_rel04_BC5_ne120_t12_pop62_46-75/"
    SE_file  = "SE_NE120_hybrid_v5_rel04_BC5_ne120_t12_pop62_46-75_ANN_climo.nc"
    sfile    = addfile(SE_dir + SE_file,"r")

;---Data file containing destination grid
;   FV_dir   = "/glade/scratch/oleson/ANALYSIS/cam5clm45bgc_ne30cesm12rel06_2000b/"
;   FV_file  = "FV_192x288_cam5clm45bgc_ne30cesm12rel06_2000b_ANN_climo.nc"
;   FV_file  = "FV_192x288_cam5clm45bgc_ne30cesm12rel06_2000b_ANN_climo_mkprocdata.nc"
;   FV_file  = "FV_192x288_cam5clm45bgc_ne30cesm12rel06_2000b_ANN_climo_diag_conserve.nc"
    FV_dir   = "/glade/scratch/oleson/ANALYSIS/hybrid_v5_rel04_BC5_ne120_t12_pop62_46-75/"
    FV_file  = "FV_768x1152_hybrid_v5_rel04_BC5_ne120_t12_pop62_46-75_ANN_climo_diag.nc"

;   FV_dir   = "/glade/scratch/oleson/ANALYSIS/cam5clm4cn_ne30cesm12rel06_2000b/"
;   FV_file  = "FV_192x288_cam5clm4cn_ne30cesm12rel06_2000b_ANN_climo.nc"
;   FV_file  = "FV_192x288_cam5clm4cn_ne30cesm12rel06_2000b_ANN_climo_mkprocdata.nc"
    dfile    = addfile(FV_dir+FV_file,"r")

;---Get SE variable
    var_name = "TLAI" 
    var_in   = sfile->$var_name$
    src_lat  = sfile->lat
    src_lon  = sfile->lon

;---Get FV variable
    var_regrid = dfile->$var_name$
    dst_lat    = dfile->lat
    dst_lon    = dfile->lon

;+++
; End user input
;+++

;----------------------------------------------------------------------
; Plotting section
;
; This section creates filled contour plots of both the original
; data and the regridded data, and panels them.
;----------------------------------------------------------------------
    dims_in = dimsizes(var_in)
    print(dims_in)
    rank_in = dimsizes(dims_in)
    ntim    = dims_in(0)

    pltName = pltName+"."+remap_method
    pltPath = pltDir+pltName
    wks = gsn_open_wks(pltType,pltPath)

;---Resources to share between both plots
    res                      = True              ; Plot modes desired.

    res@gsnDraw              = False
    res@gsnFrame             = False

    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels
    res@cnFillMode           = "RasterFill"      ; turn raster on      
    res@cnMissingValFillColor = "white"

    res@lbLabelBarOn         = False      ; Will turn on in panel later

    res@mpFillOn             = False

    res@gsnLeftString        = var_name    ; long_name is too long!
    res@gsnLeftString        = var_in@long_name
    res@gsnCenterString      = " "
 
;---Resources for plotting regridded data
    res@gsnAddCyclic  = True

    dims = tostring(dimsizes(var_regrid))
    rank = dimsizes(dims)
    res@tiMainFontHeightF = 0.015
    res@tiMainString  = "Data regridded to FV grid (" + \
                        str_join(dims(rank-2:)," x ") + ") using '" + \
                        "conservative" + "' method" + " w/diag"
;                       "conservative" + "' method" + " w/mkprocdata"
;                       "bilinear" + "' method"

    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels = (/1,2,3,4,5,6,7,8,9,10,11,12,13,14/)

    plot_regrid = gsn_csm_contour_map(wks,var_regrid(0,:,:),res)
;---Resources for contouring the above grid; apply to next grid

;   res@cnLevelSelectionMode = "ManualLevels"
;   getvalues plot_regrid@contour
;     "cnMinLevelValF"       : res@cnMinLevelValF   
;     "cnMaxLevelValF"       : res@cnMaxLevelValF 
;     "cnMaxLevelValF"       : res@cnMaxLevelValF 
;     "cnLevelSpacingF"      : res@cnLevelSpacingF
;   end getvalues

;---Resources for plotting original (source) data
    res@sfXArray     = src_lon
    res@sfYArray     = src_lat
    res@gsnAddCyclic = False
;   res@trGridType = "TriangularMesh"

    res@tiMainString = "Original SE grid (" + dims_in(1) +" cells)"

    res@mpFillOn = True
    res@mpOceanFillColor = "white"
    res@mpLandFillColor = "transparent"
    res@mpFillDrawOrder = "postdraw"

    plot_orig = gsn_csm_contour_map(wks,var_in(0,:),res)  
;---Draw both plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
