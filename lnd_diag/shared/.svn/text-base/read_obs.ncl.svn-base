undef("read_obs")
function read_obs(filevar,lat1,lon1,nlat1,nlon1,reference,seasonal,seas)
begin
; This function gets the observations for each variable
; open observation files
    obsdata  = getenv("OBS_DATA")
    obs_res  = getenv("OBS_RES")
    diag_resources  = getenv("DIAG_RESOURCES")
    obs_res         = getenv("OBS_RES")

    print("Processing " + filevar + " observations")
    
    obsFlag = 0;
    if (seasonal .eq. True) then
        if (filevar .eq. "ALBEDO") then
       		ptr  = addfile(obsdata+"/T42_MODIS_"+seas+"_climo.070523.nc","r")          ; albedo
	end if
        if (filevar .eq. "SNOWD") then
       		ptr   = addfile(obsdata+"/CMC_SNOWD_"+seas+"_climo.070503.nc","r")     ; snow depth #2
	end if
        if (filevar .eq. "SWE") then
       		ptr  = addfile(obsdata+"/CMC_SWE_"+seas+"_climo.070502.nc","r")        ; swe
	end if
        if (filevar .eq. "SNOWCOVER") then
       		ptr  = addfile(obsdata+"/NOAA_AVHRR_SNOWF_"+seas+"_climo.070502.nc","r")   ; snow cover
	end if
        if (filevar .eq. "RUNOFF") then
    	  if (obs_res .eq. "T85") then
      	 	 ptr = addfile(obsdata+"/T85_GRDC_"+seas+"_climo.nc","r") ; temp and precip
    	  else
      	 	 ptr = addfile(obsdata+"/GRDC_"+seas+"_climo.nc","r") ; temp and precip
    	  end if
	end if
        if (filevar .eq. "SNOWDP") then
    	  if (obs_res .eq. "T85") then
      	 	 ptr = addfile(obsdata+"/T85_FOSTERDAVY_"+seas+"_climo.nc","r") ; temp and precip
    	  else
      	 	 ptr = addfile(obsdata+"/FOSTERDAVY_"+seas+"_climo.nc","r") ; temp and precip
    	  end if
	end if
        if (filevar .eq. "TSA") then
    	  if (obs_res .eq. "T85") then
      	 	 ptr_wm = addfile(obsdata+"/T85_WILLMOTT_"+seas+"_climo.nc","r") ; temp and precip
    	  else
      	 	 ptr_wm = addfile(obsdata+"/WILLMOTT_"+seas+"_climo.nc","r") ; temp and precip
    	  end if
          x = ptr_wm->$filevar$
          x = x - 273.15  ; convert K to C
          reference = ptr_wm@case_id
          lat     = ptr_wm->lat
          lon     = ptr_wm->lon
          x@_FillValue = 1e30
          obsFlag = 1;
        end if
        if (filevar .eq. "PREC" ) then
    	  if (obs_res .eq. "T85") then
      	 	 ptr_wm = addfile(obsdata+"/T85_WILLMOTT_"+seas+"_climo.nc","r") ; temp and precip
    	  else
      	 	 ptr_wm = addfile(obsdata+"/WILLMOTT_"+seas+"_climo.nc","r") ; temp and precip
    	  end if
          x       = ptr_wm->PREC
          reference = ptr_wm@case_id
          lat     = ptr_wm->lat
          lon     = ptr_wm->lon
          x@_FillValue = 1e30
          obsFlag  = 1;
        end if
        if (filevar .eq. "ASA" ) then
      	  ptr_asa = addfile(obsdata+"/modisradweighted_"+seas+"_071105.nc","r") ; Peter Lawrence
          x       = ptr_asa->BRDALB		; broadband albedo
          lat     = ptr_asa->lat
          lon     = ptr_asa->lon
          reference = "Modis (PL)"
          x@_FillValue = 1e30
          obsFlag  = 1;
	end if
        if (filevar .eq. "LHEAT") then
       	  ptr_lhf  = addfile(obsdata+"/MR_LHF_0.9x1.25_"+seas+"_climo.nc","r") ; lhf
          x = ptr_lhf->LHF
          reference = ptr_lhf@case_id
          lat     = ptr_lhf->lat
          lon     = ptr_lhf->lon
          x@_FillValue = 1e30
          obsFlag = 1;
	end if
        if (filevar .eq. "FPSN" .or. filevar .eq. "GPP") then
       	  ptr_gpp  = addfile(obsdata+"/MR_GPP_0.9x1.25_"+seas+"_climo.nc","r") ; gpp
          x = ptr_gpp->GPP
          reference = ptr_gpp@case_id
          lat     = ptr_gpp->lat
          lon     = ptr_gpp->lon
          x@_FillValue = 1e30
          obsFlag = 1;
	end if
        if (filevar .eq. "TLAI") then
          ptr_lai  = addfile(obsdata+"/MODIS_LAI_"+seas+"_climo.nc","r") ; lai
          x = ptr_lai->TLAI
          reference = ptr_lai@case_id
          lat     = ptr_lai->lat
          lon     = ptr_lai->lon
          x@_FillValue = 1e30
          obsFlag = 1;
        end if
    else
      if (filevar .eq. "TSA") then
    	  if (obs_res .eq. "T85") then
		print("Error in read_obs.ncl")
    	  else
      	 	 ptr_wm = addfile(obsdata+"/0_5_WILLMOTT_ALLMONS_climo.nc","r") ; temp and precip
    	  end if
          x = ptr_wm->$filevar$
          x = x - 273.15  ; convert K to C
          reference = ptr_wm@case_id
          lat     = ptr_wm->lat
          lon     = ptr_wm->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "PREC" ) then
    	  if (obs_res .eq. "T85") then
		print("Error in read_obs.ncl")
    	  else
      	 	 ptr_wm = addfile(obsdata+"/0_5_WILLMOTT_ALLMONS_climo.nc","r") ; temp and precip
    	  end if
          x       = ptr_wm->PREC
          reference = ptr_wm@case_id
          lat     = ptr_wm->lat
          lon     = ptr_wm->lon
          x@_FillValue = 1e30
          obsFlag  = 1;
      end if
      if (filevar .eq. "ASA" ) then
      	  ptr_alb = addfile(obsdata+"/modisradweighted.nc","r") ; Peter Lawrence
          x       = ptr_alb->BRDALB		; broadband albedo
          reference = "Modis (PL)"
	  x!0   = "month"		; rename from time
	  x!1   = "lat"			; rename from lsmlat
	  x!2   = "lon"			; rename from lsmlon
	  nlat2 = dimsizes(x(0,:,0))
	  nlon2 = dimsizes(x(0,0,:))
	  month = ispan(1,12,1)
  	  lat = latGau(nlat2,"lat","latitude","degrees_north")
  	  lon = lonGlobeF(nlon2,"lon","longitude","degrees_east")
	  x&month = month
	  x&lat = lat
	  x&lon = lon
          x@_FillValue = 1e30
          obsFlag  = 1;
      end if
      if (filevar .eq. "TOTRUNOFF" ) then
          x    = ptr_grdc->RUNOFF
          reference = "GRDC"
          lat     = ptr_grdc->lat
          lon     = ptr_grdc->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "SNOWDP" .and. snowFlag .eq. 1) then
          x  = ptr_fd->$filevar$
          reference = "FOSTERDAVY"
          lat     = ptr_fd->lat
          lon     = ptr_fd->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "FSNO" ) then
          x  = ptr_scf->SCF
          x = x * 0.01                ; convert from percent to 0-1
          reference = "NOAA AVHRR (1967-2003)"
          lat     = ptr_scf->lat
          lon     = ptr_scf->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "H2OSNO" ) then
          x  = ptr_swe->SWE
          reference = "CMC (1980-1996)"
          lat     = ptr_swe->lat
          lon     = ptr_swe->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "SNOWDP" .and. snowFlag .eq. 2) then
          x = ptr_sd->SNOWD
          reference = "CMC (1980-1996)"
          lat     = ptr_sd->lat
          lon     = ptr_sd->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "VBSA") then
          x       = ptr_alb->VBSA(0,:,:)
          reference = "MODIS (2001-2003)"
          lat     = ptr_alb->lat
          lon     = ptr_alb->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "NBSA") then
          x       = ptr_alb->NBSA(0,:,:)
          reference = "MODIS (2001-2003)"
          lat     = ptr_alb->lat
          lon     = ptr_alb->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "VWSA") then
          x       = ptr_alb->VWSA(0,:,:)
          reference = "MODIS (2001-2003)"
          lat     = ptr_alb->lat
          lon     = ptr_alb->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "NWSA") then
          x       = ptr_alb->NWSA(0,:,:)
          reference = "MODIS (2001-2003)"
          lat     = ptr_alb->lat
          lon     = ptr_alb->lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "PCT_GLACIER") then
	  ; in1 = addfile("pct_glacier_64x128_c070501.nc","r")
	  ; in1 = addfile(diag_resources+"/pct_glacier_64x128_c070501.nc","r")
	  in1 = addfile(diag_resources+"/pct_glacier_1.9x2.5_070501.nc","r")
	  x = in1->PCT_GLACIER
          reference = " "
	  x!0   = "lat"
	  x!1   = "lon"
          lat   = in1->lat
          lon   = in1->lon
	  nlat2 = dimsizes(x(:,0))
	  nlon2 = dimsizes(x(0,:))
          x&lat = lat
          x&lon = lon
          x@_FillValue = 1e30
          obsFlag = 1;
      end if
      if (filevar .eq. "LHEAT") then
          ptr_lhf  = addfile(obsdata+"/MR_LHF_0.9x1.25_ALLMONS_climo.nc","r") ; lhf
          x       = ptr_lhf->LHF
          reference = ptr_lhf@case_id
          lat     = ptr_lhf->lat
          lon     = ptr_lhf->lon
          x@_FillValue = 1e30
          obsFlag  = 1;
      end if
      if (filevar .eq. "FPSN" .or. filevar .eq. "GPP") then
          ptr_gpp  = addfile(obsdata+"/MR_GPP_0.9x1.25_ALLMONS_climo.nc","r") ; gpp
          x       = ptr_gpp->GPP
          reference = ptr_gpp@case_id
          lat     = ptr_gpp->lat
          lon     = ptr_gpp->lon
          x@_FillValue = 1e30
          obsFlag  = 1;
      end if
      if (filevar .eq. "TLAI") then
          ptr_lai  = addfile(obsdata+"/MODIS_LAI_ALLMONS_climo.nc","r") ; lai
          x       = ptr_lai->TLAI
          reference = ptr_lai@case_id
          lat     = ptr_lai->lat
          lon     = ptr_lai->lon
          x@_FillValue = 1e30
          obsFlag  = 1;
      end if
    end if
    if (isvar("lat")) 
      	lat2 = lat
      	lon2 = lon
        nlat2 = dimsizes(lat)
        nlon2 = dimsizes(lon)
  ; flip lon if necessary
        if (min(x&lon) .ge. 0 .and. min(lon1) .lt. 0) then
      		x = lonFlip(x)
		print("Flipping lon for " + filevar + " observations")
        end if
    else
	print("Fatal Error - no Lat")
	exit
    end if
    ; interpolate data to new grid if necessary
    if (nlat1 .ne. nlat2) then
	print("Interpolating obs to model")
        x2_interp = linint2_Wrap(lon2,lat2,x,True,lon1,lat1,0)	; obs have fine grid; interpolate to modelgrid.
    else
    	x2_interp = x
    end if
    return(x2_interp)

end 

;***************************************************************************
