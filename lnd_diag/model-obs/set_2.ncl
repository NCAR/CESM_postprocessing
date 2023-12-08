load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/find_var_with_alts.ncl"
;************************************************
; NOTE:  adapted from plot_cons.ncl (KOleson code)
;  Revision Author:  Nan Rosenbloom Spring 2005
;************************************************
begin
  print ("=========================================")
  print ("Starting:  set_2.ncl")
  print ("Start Time: "+systemfunc("date") )
  print ("=========================================")
  wkdir    = getenv("WKDIR")
  ptmpdir  = getenv("PTMPDIR_1")
  obsdata  = getenv("OBS_DATA")
  obs_res  = getenv("OBS_RES")
  paleo    = getenv("paleo") 
  useCommon1 = getenv("UseCommonName_1")
  raster   = getenv("raster")
  land_mask = getenv("land_mask1")
  user_defined = getenv("expContours")
  cn       = getenv("CN")
  colormap = getenv("colormap")
  projection=getenv("projection")
  cn       = getenv("CN")
  plot_type  = getenv("PLOTTYPE")

  fland_mask = stringtofloat(land_mask)

; the set lists contains two columns of information. This comes into
; NCL as one long string that we need to parse out.
  tmp = stringtocharacter(asciiread(wkdir+"/master_set2.txt",-1,"string"))
  nvar = dimsizes(tmp(:,0))
  scale_type = new(nvar,"string")
  vars       = new(nvar,"string")
  c13Flag    = new(nvar,"string")
  c14Flag    = new(nvar,"string")
  dynContour = new(nvar,"string")
  do i=0,nvar-1
    scale_type(i) = charactertostring(tmp(i,0:12))
    dynContour(i) = charactertostring(tmp(i,13))
    vars(i)       = charactertostring(tmp(i,16:))
    c13Flag(i)    = charactertostring(tmp(i,16:19))     ; derived variable prefix
    c14Flag(i)    = charactertostring(tmp(i,16:19))     ; derived variable prefix
  end do
  delete(tmp)

;************************************************
; Cut off top and bottom percent to tighten contour intervals.  12/06 nanr
;************************************************
  pCut  = 5
  pLow  = 0.05
  pHigh = 0.95

  res = True
  res = set2Res(res)

;*************************************************
; get case names and create filenames to read in
;*************************************************
  nyrs     = stringtointeger(getenv("clim_num_yrs_1"))
  fyr      = stringtointeger(getenv("clim_first_yr_1"))
;;  nyrs     = getenv("clim_num_yrs_1")
;;  fyr      = getenv("clim_first_yr_1")
  sig_lvl  = getenv("sig_lvl") 
  lyr   = (fyr + nyrs)-1 ; for plotting
  zoom  = stringtointeger(getenv("reg_contour")); # (0 = SUBREGION, 1 = GLOBAL)
  if (zoom.eq.0)then
     min_lat = stringtofloat(getenv("min_lat"))
     max_lat = stringtofloat(getenv("max_lat"))
     min_lon = stringtofloat(getenv("min_lon"))
     max_lon = stringtofloat(getenv("max_lon"))
  end if
  seasons  = (/"DJF","JJA","MAM","SON","ANN"/)
  if (zoom .eq. 0) then
    res@mpLimitMode = "LatLon"
    res@mpMinLatF = min_lat
    res@mpMaxLatF = max_lat
    res@mpMinLonF = min_lon
    res@mpMaxLonF = max_lon
  end if
;*************************************************
; common plot resources
;*************************************************
  pres                            = True           ; panel only resources
  pres@gsnPanelYWhiteSpacePercent = 2
  pres@gsnMaximize            = True                   ; make as large as possible
  pres@gsnPaperOrientation   = "portrait"

; read in case strings
  cases = new(2,string)
  if (useCommon1 .eq. "True") then
     name1  = "commonName_1"
  else
     name1  = "caseid_1"
  end if
  name11     = "prefix_1"
  cases(0)   = getenv(name1)
  cases(1)   = "Obs"
  prefix     = getenv(name11)

; ***************************
; loop over seasons
; ***************************

  do n = 0,dimsizes(seasons)-1
     print("Processing season " + seasons(n))
;    pres@txString  = seasons(n)

; open model1 files
     in1  = addfile(ptmpdir +"/"+prefix+"_"+seasons(n)+"_climo.nc","r")

; open observation files
     if (obs_res .eq. "T85") then
        ptr_wm = addfile(obsdata+"/T85_WILLMOTT_"+seasons(n)+"_climo.nc","r") ; temp and precip
     else
        ptr_wm = addfile(obsdata+"/WILLMOTT_"+seasons(n)+"_climo.nc","r") ; temp and precip
     end if
     if (obs_res .eq. "T85") then
        ptr_grdc = addfile(obsdata+"/T85_GRDC_"+seasons(n)+"_climo.nc","r")   ; runoff
        ptr_fd   = addfile(obsdata+"/T85_FOSTERDAVY_"+seasons(n)+"_climo.nc","r")   ; snow depth
     else
        ptr_grdc = addfile(obsdata+"/GRDC_"+seasons(n)+"_climo.nc","r")   ; runoff
        ptr_fd   = addfile(obsdata+"/FOSTERDAVY_"+seasons(n)+"_climo.nc","r")   ; snow depth
     end if
     ptr_scf    = addfile(obsdata+"/NOAA_AVHRR_SNOWF_"+seasons(n)+"_climo.070502.nc","r")   ; snow cover
     ptr_swe    = addfile(obsdata+"/CMC_SWE_"+seasons(n)+"_climo.070502.nc","r")       ; snow depth
     ptr_sd     = addfile(obsdata+"/CMC_SNOWD_"+seasons(n)+"_climo.070503.nc","r")          ; swe
     ptr_alb    = addfile(obsdata+"/T42_MODIS_"+seasons(n)+"_climo.070523.nc","r")          ; albedo
     ptr_asa    = addfile(obsdata+"/modisradweighted_"+seasons(n)+"_071105.nc","r")          ; albedo
     ptr_lhf    = addfile(obsdata+"/MR_LHF_0.9x1.25_"+seasons(n)+"_climo.nc","r")           ; latent heat flux
     ptr_gpp    = addfile(obsdata+"/MR_GPP_0.9x1.25_"+seasons(n)+"_climo.nc","r")           ; gross primary production
     ptr_lai    = addfile(obsdata+"/MODIS_LAI_"+seasons(n)+"_climo.nc","r")                 ; leaf area index

;      extract years averaged for plotting
     if (isatt(in1,"yrs_averaged")) then
        yrs_ave1 = in1@yrs_averaged
     else
        yrs_ave1 = fyr+"-"+lyr
     end if

     nlev = 0
     if (isfilevar(in1,"levsoi")) then
        nlev  = getfilevardimsizes(in1,"levsoi")
     end if
     if (isfilevar(in1,"levgrnd")) then
        nlev  = getfilevardimsizes(in1,"levgrnd")
     end if
     if (nlev .eq. 0)
        print("FATAL ERROR:  nlev = 0")
        exit
     end if
;      truncate soil layers if needed
     if (nlev .gt. 10) then 
        print("Truncating soil levels to 10 levels [caseid: "+prefix(0)+"  nlev:  " + nlev +"]") 
        nlev = 10 
     end if

     if (isfilevar(in1,"TLAKE") .and. isfilevar(in1,"levlak") ) then
        levlak1  = in1->levlak
        nlevlak1 = getfilevardimsizes(in1,"levlak")
     end if 
     lat1   = in1->lat
     nlat1  = dimsizes(lat1)
     lon1   = in1->lon
     nlon1  = dimsizes(lon1)

;      extract landfrac if paleo file
     print(paleo)
     if (paleo .eq. "True") then 
        landfrac = in1->landfrac
        printVarSummary(landfrac)
        oro = new((/nlat1,nlon1/),integer)
        oro = 1
        oro@_FillValue = 0
        oro = where(landfrac .gt. 0.0, 1,0)
;       fname = wkdir+prefix
;       fname = wkdir+"basename"
;       fname = wkdir+cases(0)
        fname = wkdir+getenv(name1)
        paleo_outline(oro,lat1,lon1,1., fname)
        res = True
        res@mpDataBaseVersion = "Ncarg4_1"
        res@mpDataSetName     =  fname
     end if

;      truncate soil layers if needed
     if (nlev .gt. 10) then
        print("Truncating soil levels to 10 levels [caseid: "+prefix+"  nlev:  " + nlev +"]")
        nlev = 10
     end if

;      loop over variables

     snowFlag = 0

     do i=0,dimsizes(vars)-1 
        if (paleo .ne. "True") then
           if (snowFlag .eq. 1) then  ; run SNOWDP twice to see both obs datasets
              i = i-1 
           end if
           if (vars(i) .eq. "SNOWDP") then
              snowFlag = snowFlag + 1
           end if
        end if
        print("Processing variable " + vars(i))

;         read in case 1 variable
        info = var_init(vars(i))
        filevar = find_var_with_alts(in1, vars(i), info)
;         now filevar is the name of the variable in the file (either
;         vars(i) or one of its alternate names); if this variable was
;         not found in the file, then filevar will be ""

        plot_check = True
        if (isvar("x1")) then
           delete(x1)
        end if

        if (filevar .ne. "" .and. info@derivedVariable .eq. False)then
           if (c13Flag(i) .eq. "C13_") then
              x1 = derive_del13C(vars(i),in1,scale_type(i),0,2)
           else
              if (c14Flag(i) .eq. "C14_") then
                 x1 = derive_del14C(vars(i),in1,scale_type(i),0,2)
              else
                 x1 = in1->$filevar$
              end if
           end if
           plot_check = True
           delete(filevar)
        else
           if (info@derivedVariable .eq. True) then
              x1 = derive_land(  vars(i),in1)
           else
              print("variable "+ vars(i)+ " is not a defined variable.")
              plot_check  = False
              continue
           end if
        end if
;         catch NaNs
        x1 = catchNaN(x1)

        if (all(ismissing(x1)))then
           print("variable "+ vars(i)+ " contains all missing values.")
           plot_check = False
           delete(x1)
        end if

        if (plot_check .eq. False) then
           continue
        else
;            read in observations (if present)
           obsFlag = 0       ; (0 = on; 1 = off)
           if (isvar("x2") ) then
              delete(x2)
           end if
           if (paleo .ne. "True") then
           if (vars(i) .eq. "TSA" ) then
              x2 = ptr_wm->$vars(i)$
              x2 = x2 - 273.15  ; convert K to C
              k2c = True
              lon2 = ptr_wm->lon
              lat2 = ptr_wm->lat
              cases(1) = ptr_wm@case_id
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "PREC" ) then
              x2 = ptr_wm->PREC
              lon2 = ptr_wm->lon
              lat2 = ptr_wm->lat
              cases(1) = ptr_wm@case_id
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "TOTRUNOFF" ) then
              x2 = ptr_grdc->RUNOFF
              lon2 = ptr_grdc->lon
              lat2 = ptr_grdc->lat
              cases(1) = "GRDC"
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "SNOWDP" .and. snowFlag .eq. 1) then
              x2 = ptr_fd->$vars(i)$
              lon2 = ptr_fd->lon
              lat2 = ptr_fd->lat
              cases(1) = "FOSTERDAVY"
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "FSNO" ) then                ; fractional snow cover
              x2 = ptr_scf->SCF
              x2 = x2 * 0.01                        ; convert from percent to 0-1
              lon2 = ptr_scf->lon
              lat2 = ptr_scf->lat
              cases(1) = "NOAA AVHRR (1967-2003)"
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "H2OSNO" ) then                ; fractional snow cover
              x2 = ptr_swe->SWE
              lon2 = ptr_scf->lon
              lat2 = ptr_scf->lat
              cases(1) = "CMC (1980-1996)"
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "SNOWDP" .and. snowFlag .eq. 2) then
              x2 = ptr_sd->SNOWD
              lon2 = ptr_sd->lon
              lat2 = ptr_sd->lat
              cases(1) = "CMC (1980-1996)"
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "VBSA") then
              x2 = ptr_alb->VBSA(0,:,:)
              cases(1) = "MODIS (2001-2003)"
              lat2     = ptr_alb->lat
              lon2     = ptr_alb->lon
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "NBSA") then
              x2 = ptr_alb->NBSA(0,:,:)
              cases(1) = "MODIS (2001-2003)"
              lat2 = ptr_alb->lat
              lon2 = ptr_alb->lon
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "VWSA") then
              x2       = ptr_alb->VWSA(0,:,:)
              cases(1) = "MODIS (2001-2003)"
              lat2     = ptr_alb->lat
              lon2     = ptr_alb->lon
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "NWSA") then
              x2       = ptr_alb->NWSA(0,:,:)
              cases(1) = "MODIS (2001-2003)"
              lat2     = ptr_alb->lat
              lon2     = ptr_alb->lon
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "ASA") then
              x2       = ptr_asa->BRDALB(0,:,:)
              cases(1) = "MODIS (2001-2003)"
              lat2     = ptr_asa->lat
              lon2     = ptr_asa->lon
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "LHEAT") then
              x2       = ptr_lhf->LHF(:,:)
              cases(1) = "FLUXNET (1982-2008)"
              lat2     = ptr_lhf->lat
              lon2     = ptr_lhf->lon
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if ((vars(i) .eq. "FPSN" .and. cn .eq. 0) .or. vars(i) .eq. "GPP") then
              x2 = ptr_gpp->GPP(:,:)
              cases(1) = "FLUXNET (1982-2008)"
              lat2     = ptr_gpp->lat
              lon2     = ptr_gpp->lon
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
           if (vars(i) .eq. "TLAI") then
              x2 = ptr_lai->TLAI(:,:)
;;              cases(1) = "LAI (MODIS years ???)"
	      cases(1) = "MODIS (2001-2003)"
              lat2     = ptr_lai->lat
              lon2     = ptr_lai->lon
              x2@_FillValue = 1e30
              obsFlag = 1;
           else
              x2 = 0.0
              obsFlag = 0;
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if ; paleo 

           if (paleo .eq. "True") then
              obsFlag = 0
              printVarSummary(obsFlag)
           end if

           if (obsFlag .eq. 1) then
              nlat2    = dimsizes(lat2)
              nlon2    = dimsizes(lon2)
           end if

;            get info for @ varb and scale
           info = var_init(vars(i))
           x1   = scale_var(x1,scale_type(i),info)

           if (x1@units .eq. "K") then
              x1 = x1 - 273.15  ; convert K to C
              useUnits = "C"
           else
              useUnits = x1@units
           end if

           print("processing variable: " + vars(i) )

;            process observations if present
           if (obsFlag .eq. 1)       ; (0 = on; 1 = off)
 ;              flip longitudes to -180 to 180 if needed
              if (min(x2&lon) .ge. 0 .and. min(x1&lon) .lt. 0) then
                 x2 = lonFlip(x2)
              end if
              if (min(x1&lon) .ge. 0 .and. min(x2&lon) .lt. 0) then
                 x1 = lonFlip(x1)
              end if

 ;              interpolate data to new grid if necessary
              if (nlat1 .ne. nlat2) then
                 if (nlat1 .gt. nlat2) then  ; interpolate x1 to x2 grid
                    x1_interp = linint2_Wrap(lon1,lat1,x1,True,lon2,lat2,0)
                    x2_interp = x2
                 else
                    x2_interp = linint2_Wrap(lon2,lat2,x2,True,lon1,lat1,0)
                    x1_interp = x1
                 end if
              else
                 x1_interp = x1
                 x2_interp = x2
              end if
;               different plots for observations
              plot = new(3,graphic)
           else
              x1_interp = x1
              plot = new(1,graphic)
           end if  ; end observations 

;            calculate size
           rank      = dimsizes(dimsizes(x1))
;*******************************************************************
; 3D VARIABLES (time, lat, lon)
;*******************************************************************
           if (rank.eq.3)then
;               open postscript file and choose colormap
              if (isvar("wks")) then
                 delete(wks)
              end if
              if (vars(i) .eq. "SNOWDP") then
                 if (snowFlag .eq. 1) then
                    wks  = gsn_open_wks(plot_type,wkdir + "set2_" + seasons(n) + "_" + vars(i) + "_FOSTERDAVY")
                 else 
                    wks  = gsn_open_wks(plot_type,wkdir + "set2_" + seasons(n) + "_" + vars(i) + "_CMC")
                 end if
              else 
                 wks  = gsn_open_wks(plot_type,wkdir + "set2_" + seasons(n) + "_" + vars(i))
              end if
              if (isvar("cmap") ) then
                 delete(cmap)
              end if
              if (colormap.eq.0) then
                 cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag10.rgb")  ; read in colormap.  10 colors for case maps.
                 gsn_define_colormap(wks,cmap)                     
              end if
              if (colormap.eq.1) then
                 gsn_define_colormap(wks,"ncl_default")
                 cmap1 = gsn_retrieve_colormap(wks)
              end if
;               calculate time average
              if (obsFlag .eq. 1) then  ; (1 = obs; 0 = no obs)
                 x2_interp = mask(x2_interp, (x1_interp(0,:,:) .eq. x1_interp@_FillValue), False)     ; remove non-land points
                 var_avg_2 = x2_interp
              end if
              var_avg_1 = dim_avg_n_Wrap(x1_interp,0)  ; time average
              min1 = min(var_avg_1)
              max1 = max(var_avg_1)
;**************************************************************************
; Set contour Levels:  Dynamic vs pre-defined contours
;**************************************************************************
;               dynContour:  1=dynamic; 0=explicit
              if (info@cn_Explicit .eq. True .and. dynContour(i) .eq. 0 .and. user_defined .eq. True) then
                 expFlag = True
              else
                 expFlag = False
              end if
              res = True
              res = set2Res(res)
              if (zoom .eq. 0) then
                res@mpLimitMode = "LatLon"
                res@mpMinLatF = min_lat
                res@mpMaxLatF = max_lat
                res@mpMinLonF = min_lon
                res@mpMaxLonF = max_lon
              end if
              if (colormap.eq.1) then
                 res@cnFillPalette = cmap1(13:240,:)
              end if
              if (min1.eq.max1) then
                 delete(res@cnLabelBarEndStyle)
              end if

              if (paleo .eq. "True") then
                 res@mpDataBaseVersion = "Ncarg4_1"
                 res@mpDataSetName     =  fname
              end if
;               plot Model (no obs)
              if (obsFlag .eq. 0) then  ; (1 = obs; 0 = no obs) 
;                  set case 1 titles
                 if (expFlag .eq. True) then
                    res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                    res@cnLevels        = info@cn_Levels   ; contour levels
                 else 
                    if (c13Flag(i) .eq. "C13_" .or. c14Flag(i) .eq. "C14_") then
                       useMin1 = -40  ; hardcode boundaries to expectations
                       useMax1 = 0  ; hardcode boundaries to expectations
                    else
                       x = ndtooned(var_avg_1)
                       nMsg  = num(ismissing(x))
                       nGood = num(.not.ismissing(x))
                       qsort(x)

                       iLow  = floattointeger( pLow*nGood)
                       useMin1  = x(iLow )
                       iHigh = floattointeger( pHigh*nGood)
                       useMax1  = x(iHigh)
                       delete(x)
                    end if
                    maxLevel = 14
                    mnmxint  = nice_mnmxintvl( useMin1, useMax1, maxLevel, False)
                    res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
                    res@cnMinLevelValF       = mnmxint(0)
                    res@cnMaxLevelValF       = mnmxint(1)
                    res@cnLevelSpacingF      = mnmxint(2)
                    delete(useMin1)
                    delete(useMax1)
                 end if

                 res@tiMainString                = cases(0) + " (yrs " + yrs_ave1 + ")"
                 res@tiMainOffsetYF              = 0.0
;                 if (expFlag .eq. True) then
;                    res@lbTitleString = "Min = "+sprintf("%6.4g",min1)+\
;                                 " Max = "+sprintf("%6.4g",max1)
;                 else
;                    res@lbTitleString = "Min = "+sprintf("%6.4g",min1)+\
;                                 " Max = "+sprintf("%6.4g",max1)+" (+/-"+pCut+"%)"
;                 end if
                 res@gsnLeftString           = vars(i)  ; could also use info@longName if we want
                 res@gsnCenterString     = seasons(n)
                 res@gsnRightString    = useUnits ; assume same units for x1 and x2
                 res@lbOrientation   = "horizontal"
                 res@pmLabelBarWidthF  = 0.4
                 res@pmLabelBarHeightF  = 0.085
                 if (projection.eq.1) then
                    res@pmLabelBarOrthogonalPosF= 0.085
                 else
                    res@pmLabelBarOrthogonalPosF= 0.05
                 end if
                 res@lbLabelFontHeightF   = 0.014
                 res@gsnStringFontHeightF = 0.014
                 res@tiMainFontHeightF    = 0.018
     
;                  case 1 plot
                 plot = gsn_csm_contour_map(wks,var_avg_1,res)
         
                 pres@txFontHeightF = res@tiMainFontHeightF + .003
                 gsn_panel(wks,plot,(/1,1/),pres)           ; draw panel plot

                 delete(res)
                 delete(min1)
                 delete(max1)
; OBSERVATION PLOTS -----------------------------------------------------------------------------------------
              else    ; model + observations
; -----------------------------------------------------------------------------------------------------------
;                  panel 1 plot: case 1 plot
                 res = True
                 res = set2Res(res)
                 if (zoom .eq. 0) then
                   res@mpLimitMode = "LatLon"
                   res@mpMinLatF = min_lat
                   res@mpMaxLatF = max_lat
                   res@mpMinLonF = min_lon
                   res@mpMaxLonF = max_lon
                 end if

                 if (paleo .eq. "True") then
                    res@mpDataBaseVersion = "Ncarg4_1"
                    res@mpDataSetName     =  fname
                 end if
                 min1 = doubletofloat(min(var_avg_1))
                 max1 = doubletofloat(max(var_avg_1))

                 if (expFlag .eq. True) then
                    res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                    res@cnLevels             = info@cn_Levels   ; contour levels
                 else 
                    x = ndtooned(var_avg_1)
                    nMsg  = num(ismissing(x))
                    nGood = num(.not.ismissing(x))

                    qsort(x)
                    iLow  = floattointeger( pLow*nGood)
                    useMin1  = x(iLow )
                    iHigh = floattointeger( pHigh*nGood)
                    useMax1  = x(iHigh)
                    delete(x)

                    maxLevel = 9
;; added 2016/01/29
                    if (vars(i) .eq. "SNOWDP") then 
                        useMin12 = 0. 
                        useMax12 = 1. 
                    end if
                    if (vars(i) .eq. "H2OSNO") then 
                        useMin12 = 0. 
                        useMax12 = 500. 
                    end if

                    mnmxint  = nice_mnmxintvl( useMin1, useMax1, maxLevel, False)
                    res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
                    res@cnMinLevelValF       = mnmxint(0)
                    res@cnMaxLevelValF       = mnmxint(1)
                    res@cnLevelSpacingF      = mnmxint(2)
                    delete(useMax1)
                    delete(useMin1)
                 end if

                 res@gsnDraw        = False ; for panel plots
                 res@lbLabelStride        = 1
                 res@lbLabelFontHeightF    = 0.018
                 res@gsnStringFontHeightF  = 0.018
                 res@tiMainFontHeightF     = 0.022
                 res@pmLabelBarHeightF     = 0.4
                 res@pmLabelBarWidthF      = 0.085
                 res@pmLabelBarOrthogonalPosF= 0.05

                 res@tiMainString          = cases(0) + " (yrs " + yrs_ave1 + ")"
                 res@tiMainOffsetYF        = -0.01
                 res@gsnLeftString         = ""   ; info@longName  ; could also use info@longName if we want
                 res@gsnCenterString       = ""
                 res@gsnRightString        = ""   ; useUnits ; assume same units for x1 and x2
                 res@lbOrientation         = "Vertical"
                 delete(min1)
                 delete(max1)

                 plot(0) = gsn_csm_contour_map(wks,var_avg_1,res)
;                  save settings to plot obs
 
;                  panel 2 plot: case 2 plot
 
                 check = isdouble(var_avg_2)
                 if (check .eq. True) then
                    min1 = doubletofloat(min(var_avg_2))
                    max1 = doubletofloat(max(var_avg_2))
                 else
                    min1 = min(var_avg_2)
                    max1 = max(var_avg_2)
                 end if
                 delete(check)
                 res@tiMainString           = cases(1) 
;                 if (expFlag .eq. True) then
;                    res@lbTitleString = "Min = "+sprintf("%6.4g",min1)+\
;                                             "~C~Max = "+sprintf("%6.4g",max1)
;                 else
;                    res@lbTitleString = "Min = "+sprintf("%6.4g",min1)+\
;                                         "~C~Max = "+sprintf("%6.4g",max1)+" (+/-"+pCut+"%)"
;                 end if
                 delete(min1)
                 delete(max1)
                 
                 plot(1) = gsn_csm_contour_map(wks,var_avg_2,res)
                 delete(res)

;                  panel 3 difference plot

                 if ( isvar("cmap") ) then
                    delete(cmap)
                 end if
                 if (colormap.eq.0) then
                    cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag12.rgb")  ; read in colormap.  12 colors for diff maps.
                    gsn_define_colormap(wks,cmap)
                    delete(cmap)
                 end if
         
                 res = True
                 res = set2Res(res)
                 if (zoom .eq. 0) then
                   res@mpLimitMode = "LatLon"
                   res@mpMinLatF = min_lat
                   res@mpMaxLatF = max_lat
                   res@mpMinLonF = min_lon
                   res@mpMaxLonF = max_lon
                 end if
         
                 if (colormap.eq.1) then
                    res@cnFillPalette = cmap1(13:240,:)
                    delete(cmap1)
                 end if
                 if (paleo .eq. "True") then
                    res@mpDataBaseVersion = "Ncarg4_1"
                    res@mpDataSetName     =  fname
                 end if
                 res@gsnLeftString         = ""  ;info@longName ; could also use info@longName if we want
                 res@gsnCenterString = ""
                 res@gsnRightString        = ""  ;useUnits ; assume same units for x1 and x2
                 res@lbOrientation         = "Vertical"
                 res@lbLabelStride        = 1
                 res@lbLabelFontHeightF    = 0.018
                 res@gsnStringFontHeightF  = 0.018
                 res@tiMainFontHeightF     = 0.022
                 res@pmLabelBarHeightF     = 0.40
                 res@pmLabelBarWidthF      = 0.085
                 res@pmLabelBarOrthogonalPosF= 0.05
        
                 diff = var_avg_1 ; trick to maintain meta data
                 check = isdouble(var_avg_2)
                 if (check .eq. True) then
                    diff = var_avg_1 - doubletofloat(var_avg_2)
                 else
                    diff = var_avg_1 - var_avg_2
                 end if
                 delete(check)
                 mindiff = min(diff)
                 maxdiff = max(diff)

                 if (expFlag .eq. True) then
;                     use larger contour intervals for Model vs Obs
                    res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                    res@cnLevels     = info@cn_LevelsDiffObs   ; contour levels
                 else
                    sd = dim_stddev(ndtooned(diff))
            
                    if (vars(i).eq."PREC") then
                       useMin1  = -2.*sd   ; = mindiff
                       useMax1  = 2.*sd    ; = maxdiff
                    else
                       useMin1  = -2.5*sd   ; = mindiff
                       useMax1  = 2.5*sd    ; = maxdiff
                    end if
                    if (c13Flag(i) .eq. "C13_" .or. c14Flag(i) .eq. "C14_") then
                       useMin1 = -40              ; hardcode boundaries to expectations
                       useMax1 = 0                ; hardcode boundaries to expectations
                    end if            
                    delete(sd)
                    maxLevel = 13
                    mnmxint  = nice_mnmxintvl( useMin1, useMax1, maxLevel, False)
                    res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
                    res@cnMinLevelValF       = mnmxint(0)
                    res@cnMaxLevelValF       = mnmxint(1)
                    res@cnLevelSpacingF      = mnmxint(2)
                    delete(useMin1)
                    delete(useMax1)
                 end if

                 res@tiMainString           = cases(0) +" - "+cases(1)
                 res@tiMainOffsetYF = -.01
                 plot(2) = gsn_csm_contour_map(wks,diff,res)
                 delete(res)
                 
;                  panel plot
                 pres@txFontHeightF = 0.02
                 pres@txString = seasons(n)+" "+info@longName+" ("+useUnits+")" 

;; ASB hard code the wks height and width - need this to be a env var
                 wks@wkWidth  = 1500
                 wks@wkHeight = 1500

                 gsn_panel(wks,plot,(/3,1/),pres)           ; draw panel plot
                 pres@txString = ""
         
                 delete(x2_interp)
                 delete(var_avg_2)
                 delete(diff)
                 delete(mindiff)
                 delete(maxdiff)
              end if ; end obsFlag
 ;            remove explicit labels
           else ; end 3D variables
;*************************************************************************
; 4D VARIABLES (time, lev, lat, lon)
;*************************************************************************
;               calculate 4D average
              print("Starting 4D variables")

              var_avg_1 = dim_avg_n_Wrap(x1,0) ; time average

              do lev=0,2  ; assume both cases have same number of levels.
                 if ( lev .eq. 0 ) then
                    k = 0
                 end if
                 if ( lev .eq. 1) then
                    k = 4
                 end if
                 if ( lev .eq. 2) then
                    k = 9
                 end if

;                  open postscript file (4D)
                 if (isvar("wks")) then
                    delete(wks)
                 end if
                 wks  = gsn_open_wks(plot_type,wkdir + "set2_" + seasons(n)+"_"+vars(i)+"_"+k)
                 if (isvar("cmap") ) then
                    delete(cmap)
                 end if
                      
                 res = True
                 res = set2Res(res)
                 if (zoom .eq. 0) then
                   res@mpLimitMode = "LatLon"
                   res@mpMinLatF = min_lat
                   res@mpMaxLatF = max_lat
                   res@mpMinLonF = min_lon
                   res@mpMaxLonF = max_lon
                 end if
      
                 if (colormap.eq.0) then
                    cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag10.rgb")  ; read in colormap.  10 colors for case maps.
                    gsn_define_colormap(wks,cmap)
                    delete(cmap)
                 end if
                 if (colormap.eq.1) then
                    gsn_define_colormap(wks,"ncl_default")
                    cmap1 = gsn_retrieve_colormap(wks)     ;read_colormap_file("ncl_default")
                    res@cnFillPalette = cmap1(13:240,:)
                    delete(cmap1)         
                 end if
      
                 res@gsnLeftString            = info@longName        ; could also use info@longName if we want
                 res@gsnRightString           = useUnits     ; assume same units for x1 and x2
                 res@lbOrientation            = "Vertical"
                 res@gsnCenterString = "Level = " + k

;                  extract landfrac if paleo file
                 if (paleo .eq. "True") then 
                    res@mpDataBaseVersion = "Ncarg4_1"
                    res@mpDataSetName     =  fname
                 end if

;                  set case 1 titles (4D)
                 res@tiMainString           = cases(0) + " (yrs " + yrs_ave1 + ")"
                 min1 = min(var_avg_1(k,:,:))
                 max1 = max(var_avg_1(k,:,:))
;                 if (expFlag .eq. True) then
;                    res@lbTitleString = "Min = "+sprintf("%6.4g",min1)+\
;                                           " Max = "+sprintf("%6.4g",max1)
;                 else
;                    res@lbTitleString = "Min = "+sprintf("%6.4g",min1)+\
;                                           " Max = "+sprintf("%6.4g",max1)+" (+/-"+pCut+"%)"
;                 end if
                 res@gsnLeftString    = vars(i) ; could also use info@longName if we want
                 res@gsnRightString   = useUnits ; assume same units for x1 and x2

;                  set explicit contour levels (4D)
                 if (expFlag .eq. True) then
                    res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                    st = "cn_Level"+k        ; get cn levels for a specific levsoi
                    res@cnLevels             = info@$st$
                 else 
                    x = ndtooned(var_avg_1(k,:,:))
                    nMsg  = num(ismissing(x))
                    nGood = num(.not.ismissing(x))
                    qsort(x)

                    iLow  = floattointeger( pLow*nGood)
                    useMin1  = x(iLow )
                    iHigh = floattointeger( pHigh*nGood)
                    useMax1  = x(iHigh)
                    delete(x)

                    maxLevel = 9
                    mnmxint  = nice_mnmxintvl( useMin1, useMax1, maxLevel, False)
                    res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
                    res@cnMinLevelValF       = mnmxint(0)
                    res@cnMaxLevelValF       = mnmxint(1)
                    res@cnLevelSpacingF      = mnmxint(2)
                    delete(useMin1)
                    delete(useMax1)
                 end if

                 res@tiMainString                    = cases(0) + " (yrs " + yrs_ave1 + ")"
                 res@tiMainOffsetYF                  = 0.0
;                 res@lbTitleString                   = "Min = "+sprintf("%6.4g",min1)+ \
 ;                                   " Max = "+sprintf("%6.4g",max1)
                 res@gsnLeftString       = vars(i)  ; could also use info@longName if we want
                 res@gsnCenterString     = seasons(n)
                 res@gsnRightString      = useUnits ; assume same units for x1 and x2
                 res@lbOrientation     = "horizontal"
                 res@pmLabelBarWidthF    = 0.4
                 res@pmLabelBarHeightF           = 0.085
                 
                 if (projection.eq.1) then
                    res@pmLabelBarOrthogonalPosF= 0.085
                 else
                    res@pmLabelBarOrthogonalPosF= 0.05
                 end if
                 res@lbLabelFontHeightF   = 0.014
                 res@gsnStringFontHeightF = 0.014
                 res@tiMainFontHeightF    = 0.018
           
;                  4D case 1 plot
                 plot(0) = gsn_csm_contour_map(wks,var_avg_1(k,:,:),res)


;; ASB hard code the wks height and width - need this to be a env var
                 wks@wkWidth  = 1500
                 wks@wkHeight = 1500

;                  panel plot
                 gsn_panel(wks,plot,(/1,1/),pres)           ; draw panel plot

                 delete([/res,min1,max1/])
              end do ; level loop

;               plot Observed vs Model
           end if ; 4d variables
           delete([/var_avg_1,x1,x1_interp,plot/])
        end if ; end plot_check 
        if (isvar("useUnits")) then
           delete(useUnits)
        end if
        if (isvar("lon2")) then    
           delete(lon2)
        end if
        if (isvar("lat2")) then
           delete(lat2)
        end if
     end do ; end variable loop
  end do   ; seasons loop 

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set2_error_file"              
  system("/bin/rm -f " + filo)  
end
