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
    remap_method = "bilinear"     ; "bilinear" , "patch", "conserve"

;---Specify source SE grid resolution
    SE_res       = "ne30"

;---Specify name of destination grid
    DstGridName  = "FV_768x1152"

;---Specify name of weight file to be generated; name of destination grid; dst directory
    WgtFileDir   = "./"
    WgtFileName  = "SE_"+str_upper(SE_res)+"_to_"+DstGridName+"."+remap_method+".nc"

;---Sample plot options
    pltDir   = "./"
    pltType  = "png"
    pltName  = "SE_"+str_upper(SE_res)+"_to_"+DstGridName

;---Data file containing source grid (sample)
    SE_dir   = "/location/of/file/on/the/next/line/"
    SE_file  = "any_nc_file_with_same_orig_resolution"
    sfile    = addfile(SE_dir + SE_file,"r")

;---Data file containing destination grid
    FV_dir   = "/location/of/file/on/the/next/line/"
    FV_file  = "any_nc_file_with_same_destination_grid"
    dfile    = addfile(FV_dir+FV_file,"r")
    xFV_dir   = "/location/of/file/on/the/next/line/"
    xFV_file  = "file_with_a_land_mask"
    extradfile    = addfile(xFV_dir+xFV_file,"r")

;---Get any variable to regrid
;    var_name = "TSA"                  ; (time, lev, ncol) 
    var_name = "TSOI"                    ; TSOI(time, levgrnd, lndgrid)
;    var_name = "TAUX"
    var_in   = sfile->$var_name$
    src_lat  = sfile->lat
    src_lon  = sfile->lon

;+++
; End user input
;+++

;---Set up regridding options
    Opt                = True
    Opt@InterpMethod   = remap_method

    Opt@WgtFileName    = WgtFileDir+WgtFileName
    Opt@SrcGridLat     = src_lat
    Opt@SrcGridLon     = src_lon
    Opt@SrcInputFileName = SE_file 

    Opt@DstGridLat     = dfile->lat
    Opt@DstGridLon     = dfile->lon


   Opt@DstMask2D = extradfile->PFTDATA_MASK ;change if var name in extrafile is different

    Opt@ForceOverwrite = True
    Opt@Debug          = True
    Opt@PrintTimings   = True

;---Call the regridding function
    var_regrid = ESMF_regrid(var_in,Opt)
    printVarSummary(var_regrid)

;----------------------------------------------------------------------
; Plotting section
;
; This section creates filled contour plots of both the original
; data and the regridded data, and panels them.
;----------------------------------------------------------------------
    dims_in = dimsizes(var_in)
    rank_in = dimsizes(dims_in)
    ntim    = dims_in(0)
    if (rank_in.ge.3) then
        klev = dims_in(1)
        nt  = 0
        kl  = klev/2
        LEV = var_in&levgrnd(kl)
    end if

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

    res@lbLabelBarOn         = False      ; Will turn on in panel later

    res@mpFillOn             = False

    res@gsnLeftString        = var_name    ; long_name is too long!
    res@gsnLeftString        = var_in@long_name
    res@gsnCenterString      = "lev="+LEV
 
;---Resources for plotting regridded data
    res@gsnAddCyclic  = True

    dims = tostring(dimsizes(var_regrid))
    rank = dimsizes(dims)
    res@tiMainString  = "Data regridded to FV grid (" + \
                        str_join(dims(rank-2:)," x ") + ") using '" + \
                        Opt@InterpMethod + "' method"

    plot_regrid = gsn_csm_contour_map(wks,var_regrid(nt,kl,:,:),res)
;---Resources for contouring the above grid; apply to next grid

    res@cnLevelSelectionMode = "ManualLevels"
    getvalues plot_regrid@contour
      "cnMinLevelValF"       : res@cnMinLevelValF   
      "cnMaxLevelValF"       : res@cnMaxLevelValF 
      "cnMaxLevelValF"       : res@cnMaxLevelValF 
      "cnLevelSpacingF"      : res@cnLevelSpacingF
    end getvalues

;---Resources for plotting original (source) data
    res@sfXArray     = src_lon
    res@sfYArray     = src_lat
    res@gsnAddCyclic = False

    res@tiMainString = "Original SE grid (" + dims_in(2) +" cells)"

   res@mpFillOn = True
   res@mpOceanFillColor = "white"
   res@mpLandFillColor = "transparent"
   res@mpFillDrawOrder = "postdraw"

    plot_orig = gsn_csm_contour_map(wks,var_in(nt,kl,:),res)  
;---Draw both plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)
end
