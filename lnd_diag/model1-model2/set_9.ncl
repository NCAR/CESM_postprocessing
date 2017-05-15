load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/read_obs.ncl"
;************************************************
; NOTE:  adapted from plot_cons.ncl (KOleson code)
;  Revision Author:  Nan Rosenbloom Spring 2005
;************************************************
begin
 print ("=========================================")
 print ("Starting:  set_9.ncl - Validation diagnostics")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
  wkdir     = getenv("WKDIR")
  prefix1   = getenv("prefix_1")
  prefix2   = getenv("prefix_2")
  ptmpdir1   = getenv("PTMPDIR_1")
  ptmpdir2   = getenv("PTMPDIR_2")
  obsdata   = getenv("OBS_DATA")
  obs_res   = getenv("OBS_RES")
  useCommon1 = getenv("UseCommonName_1")
  useCommon2 = getenv("UseCommonName_2")
  raster    = getenv("raster")
  cn        = getenv("CN")
  land_mask = getenv("land_mask1")
  colormap = getenv("colormap")
  landmask  = stringtofloat(land_mask)
  plot_type  = getenv("PLOTTYPE")

; read in case strings
  cases  = new(2,string)
  do m = 0,1
     if (m .eq. 0) then
        useFlag = useCommon1
     end if
     if (m .eq. 1) then
        useFlag = useCommon2
     end if
     if (useFlag .eq. "True") then
         name1  = "commonName_"+(m+1)
     else
         name1  = "caseid_"+(m+1)
     end if
     cases(m)  = getenv(name1)
  end do

;**************************************************************************
; Cut off top and bottom percent to tighten contour intervals.  12/06 nanr
;**************************************************************************
  pCut  = 5
  pLow  = 0.05
  pHigh = 0.95

;************************************************
; variables
;************************************************

  if (cn .eq. 1) then
    vars     = (/"TSA","PREC","ASA","LHEAT","GPP","TLAI"/)	; prec = rain+snow
  else
    vars     = (/"TSA","PREC","ASA","LHEAT","FPSN","TLAI"/)	; prec = rain+snow
  end if
  seasons  = (/"ANN","DJF","MAM","JJA","SON"/)
  nvars = dimsizes(vars)
  nseas = dimsizes(seasons)

;************************************************
; Statistical output
;************************************************

  ncases   = 2	; case1, case2, summary
  nstats   = 13	; rmse, rmseArea0, bias, bias*nseas,biasArea*nseas,rArea0.9

;*************************************************
; create filenames to read in
;*************************************************
  nyrs1 = stringtointeger(getenv("clim_num_yrs_1"))
  fyr1  = stringtointeger(getenv("clim_first_yr_1"))
  nyrs2 = stringtointeger(getenv("clim_num_yrs_2"))
  fyr2  = stringtointeger(getenv("clim_first_yr_2"))

  sig_lvl  = getenv("sig_lvl") 
  lyr1   = (fyr1 + nyrs1)-1 		; for plotting
  lyr2   = (fyr2 + nyrs2)-1 		; for plotting

  ;; set thresholds, significance levels
  acr_diff_sig     = (/0.1,0.2,0.2,0.1,0.1,0.1/)   ; randomly selected corrlelation difference that signifies that models
  				   ; are statistically different
  acr_good         = 0.9           ; correlation considered a good validation
  siglvl_mn        = 0.05          ; statistical significance level for difference of means
  ; siglvl_mn        = 0.95          ; statistical significance level for difference of means
  diff_phys_mn     = (/0.5,0.25,0.5,5.0,1.0,0.25/)  ; difference in means that is physically significant, chosen subjectively
  siglvl_std       = 0.0   	   ;  not clear how to calculate so setting to zero
  diff_phys_std    = (/1.0,0.5,0.5,5.0,1.0,0.5/)   ; difference in std that is physically significant, chosen subjectively
  siglvl_rmse      = 0.0           ;  not clear how to calculate so setting to zero
  diff_phys_rmse   = (/0.5,0.5,0.5,5.0,1.0,0.5/)   ; difference in RMSE that is physically significant, chosen subjectively

;*************************************************
; common plot resources
;*************************************************
  pres                         = True           ; panel only resources
  pres@gsnMaximize 	       = True
  pres@gsnPanelYWhiteSpacePercent = 2

; ***************************
; open files
; ***************************
    
     inMon1  = addfile(ptmpdir1 +"/"+prefix1+"MONS_climo.nc","r")
     inMon2  = addfile(ptmpdir2 +"/"+prefix2+"MONS_climo.nc","r")

     inANN1  = addfile(ptmpdir1 +"/"+prefix1+"_ANN_means.nc","r")
     inANN2  = addfile(ptmpdir2 +"/"+prefix2+"_ANN_means.nc","r")

     inMAM1  = addfile(ptmpdir1 +"/"+prefix1+"_MAM_means.nc","r")
     inMAM2  = addfile(ptmpdir2 +"/"+prefix2+"_MAM_means.nc","r")

     inJJA1  = addfile(ptmpdir1 +"/"+prefix1+"_JJA_means.nc","r")
     inJJA2  = addfile(ptmpdir2 +"/"+prefix2+"_JJA_means.nc","r")

     inSON1  = addfile(ptmpdir1 +"/"+prefix1+"_SON_means.nc","r")
     inSON2  = addfile(ptmpdir2 +"/"+prefix2+"_SON_means.nc","r")

     inDJF1  = addfile(ptmpdir1 +"/"+prefix1+"_DJF_means.nc","r")
     inDJF2  = addfile(ptmpdir2 +"/"+prefix2+"_DJF_means.nc","r")

     climoANN1  = addfile(ptmpdir1 +"/"+prefix1+"_ANN_climo.nc","r")
     climoANN2  = addfile(ptmpdir2 +"/"+prefix2+"_ANN_climo.nc","r")

     climoJJA1  = addfile(ptmpdir1 +"/"+prefix1+"_JJA_climo.nc","r")
     climoJJA2  = addfile(ptmpdir2 +"/"+prefix2+"_JJA_climo.nc","r")

     climoDJF1  = addfile(ptmpdir1 +"/"+prefix1+"_DJF_climo.nc","r")
     climoDJF2  = addfile(ptmpdir2 +"/"+prefix2+"_DJF_climo.nc","r")

     climoMAM1  = addfile(ptmpdir1 +"/"+prefix1+"_MAM_climo.nc","r")
     climoMAM2  = addfile(ptmpdir2 +"/"+prefix2+"_MAM_climo.nc","r")

     climoSON1  = addfile(ptmpdir1 +"/"+prefix1+"_SON_climo.nc","r")
     climoSON2  = addfile(ptmpdir2 +"/"+prefix2+"_SON_climo.nc","r")


;    area1     = inMon1->area
;    landfrac1 = inMon1->landfrac
;    landmask1 = inMon1->landmask
     lat1      = inMon1->lat
     lon1      = inMon1->lon
     nlat1     = dimsizes(lat1)
     nlon1     = dimsizes(lon1)

;    area2     = inMon2->area
;    landfrac2 = inMon2->landfrac
;    landmask2 = inMon2->landmask
     lat2      = inMon2->lat
     lon2      = inMon2->lon
     nlat2     = dimsizes(lat2)
     nlon2     = dimsizes(lon2)

;    if (min(area1&lon) .ge. 0) then
;    	landfrac1 = lonFlip(landfrac1)
;    	landmask1 = lonFlip(landmask1)
;    	area1     = lonFlip(area1)
;    end if
;    if (min(area2&lon) .ge. 0) then
;    	landfrac2 = lonFlip(landfrac2)
;    	landmask2 = lonFlip(landmask2)
;    	area2     = lonFlip(area2)
;    end if

     dim   = nlat1 * nlon1

     seasonal = False
     pct_glacier = read_obs("PCT_GLACIER",lat1,lon1,nlat1,nlon1,"",seasonal,0)
     if (min(pct_glacier&lon) .ge. 0) then
     	pct_glacier = lonFlip(pct_glacier)
     end if
 ; =======================================================
 ; START: main loop
 ; =======================================================

 do i=0,dimsizes(vars)-1 
     area1     = inMon1->area
     landfrac1 = inMon1->landfrac
     landmask1 = inMon1->landmask
     area2     = inMon2->area
     landfrac2 = inMon2->landfrac
     landmask2 = inMon2->landmask
     if (min(area1&lon) .ge. 0) then
     	landfrac1 = lonFlip(landfrac1)
     	landmask1 = lonFlip(landmask1)
     	area1     = lonFlip(area1)
     end if
     if (min(area2&lon) .ge. 0) then
     	landfrac2 = lonFlip(landfrac2)
     	landmask2 = lonFlip(landmask2)
     	area2     = lonFlip(area2)
     end if

     statsOut = new((/nstats,ncases/),"float")

   ; output statistics for tables

    ; stdev vars
     x1_acsd     = new((/nlat1,nlon1/),"float")	; case1 stdev of annual cycle
     x2_acsd     = new((/nlat1,nlon1/),"float")
     obs_acsd    = new((/nlat1,nlon1/),"float")
     sd_imp_area = new((/2/),"float")
     sd_map      = new((/nlat1,nlon1/),"float")

    ; correlation (r) vars
     x1_corr       = new((/nlat1,nlon1/),"float")
     x2_corr       = new((/nlat1,nlon1/),"float")
     acr_good_area = new((/2/),"float")
     acr_map       = new((/nlat1,nlon1/),"float")

    ; RMSE vars
     x1_acrmse     = new((/nlat1,nlon1/),"float")	; case1 rmse rel to obs
     x2_acrmse     = new((/nlat2,nlon2/),"float")	; case2 rmse rel to obs
     rmse_imp_area = new((/2/),"float")
     rmse_map      = new((/nlat1,nlon1/),"float")	; model improvement rel to obs

    ; bias vars
     x1_mn         = new((/nseas,nlat1,nlon1/),"float")	; mean annual cycle (nyrs1 avg)
     x2_mn         = new((/nseas,nlat1,nlon1/),"float")	; mean annual cycle (nyrs2 avg)
     obs_mn        = new((/nseas,nlat1,nlon1/),"float")	; mean annual cycle 
     x1_mn_avg     = new((/nseas/),"float")
     x2_mn_avg     = new((/nseas/),"float")
     x1_mnvar      = new((/nseas,nlat1,nlon1/),"float")	; var of annual cycle (case1)
     x2_mnvar      = new((/nseas,nlat1,nlon1/),"float")	; var of annual cycle (case2)
     x1_bias       = new((/nseas,nlat1,nlon1/),"float")	; x1 - obs 
     x2_bias       = new((/nseas,nlat1,nlon1/),"float")	; x2 - obs
     bias_map      = new((/nseas,nlat1,nlon1/),"float")	; model improvement rel to obs
     bias_imp_area = new((/nseas,2/),"float")
     x1_bias_mn    = new((/nseas/),"float")
     x2_bias_mn    = new((/nseas/),"float")
     acr_area      = new((/2/),"float")

     print("Processing variable " + vars(i))

     ; open plot wks
     cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag12.rgb")  ; read in colormap.  8 colors for case maps.

   ; =======================================================
   ;  Read seasonal and annual clim
   ; =======================================================

     filevar = vars(i)
     info = var_init(vars(i))

   ; =======================================================
   ; Read all months to get statistics for correlation
   ; =======================================================

     if(isfilevar(inMon1,filevar))then
             x1 = inMon1->$filevar$
     else
             if (info@derivedVariable .eq. True) then
                  x1 = derive_land(  vars(i),inMon1)
             else
                  print("variable "+ vars(i)+ " is not a defined variable.")
                  continue
             end if
     end if
     if(isfilevar(inMon2,filevar))then
             x2 = inMon2->$filevar$
     else
             if (info@derivedVariable .eq. True) then
                  x2 = derive_land(  vars(i),inMon2)
             else
                  print("variable "+ vars(i)+ " is not a defined variable.")
                  continue
             end if
     end if

   ; =======================================================
   ; Read climos
   ; =======================================================

     if(isfilevar(inMon1,filevar))then
             x1 = inMon1->$filevar$
     else
             if (info@derivedVariable .eq. True) then
                  x1 = derive_land(  vars(i),inMon1)
             else
                  print("variable "+ vars(i)+ " is not a defined variable.")
                  continue
             end if
     end if
     if(isfilevar(inMon2,filevar))then
             x2 = inMon2->$filevar$
     else
             if (info@derivedVariable .eq. True) then
                  x2 = derive_land(  vars(i),inMon2)
             else
                  print("variable "+ vars(i)+ " is not a defined variable.")
                  continue
             end if
     end if

     if (min(x1&lon) .ge. 0) then
        x1        = lonFlip(x1)
     end if
     if (min(x2&lon) .ge. 0) then
        x2        = lonFlip(x2)
     end if
     if (vars(i) .eq. "TSA") then
        x1 = x1-273.15
        x2 = x2-273.15
     end if             
     if (vars(i) .eq. "PREC") then
        x1 = x1*86400
        x2 = x2*86400
     end if             
     if (vars(i) .eq. "FPSN") then
        x1 = x1 * 1.e-6 * 12.0107 * 86400. ; umole/m2/s -> gC/m2/day
        x2 = x2 * 1.e-6 * 12.0107 * 86400. ; umole/m2/s -> gC/m2/day
     end if
     if (vars(i) .eq. "GPP") then
        x1 = x1 * 86400. ; gC/m2/s -> gC/m2/day
        x2 = x2 * 86400. ; gC/m2/s -> gC/m2/day
     end if

     x1_ac = x1                                                         ; annual climatology cycle
     x2_ac = x2                                                         ; annual climatology cycle

     delete(x1)
     delete(x2)

   ; =======================================================
   ; Read means to get stdev (read 20 values)
   ; Read climo for biases
   ; =======================================================
    do s = 0,dimsizes(seasons)-1
       if (seasons(s) .eq. "ANN") then
                fptr1 = inANN1
                fptr2 = inANN2
                fptr1c = climoANN1
                fptr2c = climoANN2
        end if
        if (seasons(s) .eq. "DJF") then
                fptr1 = inDJF1
                fptr2 = inDJF2
                fptr1c = climoDJF1
                fptr2c = climoDJF2
        end if
        if (seasons(s) .eq. "MAM") then
                fptr1 = inMAM1
                fptr2 = inMAM2
                fptr1c = climoMAM1
                fptr2c = climoMAM2
        end if
        if (seasons(s) .eq. "JJA") then
                fptr1 = inJJA1
                fptr2 = inJJA2
                fptr1c = climoJJA1
                fptr2c = climoJJA2
        end if
        if (seasons(s) .eq. "SON") then
                fptr1 = inSON1
                fptr2 = inSON2
                fptr1c = climoSON1
                fptr2c = climoSON2
        end if

      ; ==================
      ; clear variables
      ; ==================
	if (isvar("x1")) then
		delete(x1)
	end if
	if (isvar("x2")) then
		delete(x2)
	end if
	if (isvar("x11")) then
		delete(x11)
	end if
	if (isvar("x22")) then
		delete(x22)
	end if
        if(isvar("obs") ) then
	   delete(obs)
        end if


      ; ==================
      ; read seasonal obs + variables
      ; ==================
        casename = new(nvars+1,"string")
        seasonal = True
        obs = read_obs(filevar,lat1,lon1,nlat1,nlon1,casename(2),seasonal,seasons(s))

     	if(isfilevar(fptr1,filevar))then
             x1 = fptr1->$filevar$
     	else
             info = var_init(vars(i))
             if (info@derivedVariable .eq. True) then
                  x1 = derive_land(  vars(i),fptr1)
             else
                  print("variable "+ vars(i)+ " is not a defined variable.")
                  continue
             end if
     	end if
     	if(isfilevar(fptr2,filevar))then
             x2 = fptr2->$filevar$
     	else
             info = var_init(vars(i))
             if (info@derivedVariable .eq. True) then
                  x2 = derive_land(  vars(i),fptr2)
             else
                  print("variable "+ vars(i)+ " is not a defined variable.")
                  continue
             end if
     	end if

        if(isfilevar(fptr1c,filevar))then
             x11 = fptr1c->$filevar$
        else
             info = var_init(vars(i))
             if (info@derivedVariable .eq. True) then
                  x11 = derive_land(  vars(i),fptr1c)
             else
                  print("variable "+ vars(i)+ " is not a defined variable.")
                  continue
             end if
        end if
        if(isfilevar(fptr2c,filevar))then
             x22 = fptr2c->$filevar$
        else
             info = var_init(vars(i))
             if (info@derivedVariable .eq. True) then
                  x22 = derive_land(  vars(i),fptr2c)
             else
                  print("variable "+ vars(i)+ " is not a defined variable.")
                  continue
             end if
        end if


     	if (min(x1&lon) .ge. 0) then
     		x1        = lonFlip(x1)
     	end if
     	if (min(x2&lon) .ge. 0) then
     		x2        = lonFlip(x2)
     	end if
     	if (min(x11&lon) .ge. 0) then
     		x11       = lonFlip(x11)
     	end if
     	if (min(x22&lon) .ge. 0) then
     		x22       = lonFlip(x22)
     	end if
        if (iscoord(obs,(/"lon"/))) then
     	   if (min(obs&lon) .ge. 0) then
     		obs = lonFlip(obs)
           end if
        else
           if (iscoord(obs,(/"lsmlon"/))) then
     		if (min(obs&lsmlon) .ge. 0) then
     			obs = lonFlip(obs)
        	end if
           end if
        end if

     	if (vars(i) .eq. "TSA") then
     		x1  = x1-273.15
     		x2  = x2-273.15
     		x11 = x11-273.15
     		x22 = x22-273.15
     	end if		
     	if (vars(i) .eq. "PREC") then
     		x1  = x1*86400
     		x2  = x2*86400
     		x11 = x11*86400
     		x22 = x22*86400
     	end if		
        if (vars(i) .eq. "FPSN") then
                x1 = x1 * 1.e-6 * 12.0107 * 86400.   ; umole/m2/s -> gC/m2/day
                x2 = x2 * 1.e-6 * 12.0107 * 86400.   ; umole/m2/s -> gC/m2/day
                x11 = x11 * 1.e-6 * 12.0107 * 86400. ; umole/m2/s -> gC/m2/day
                x22 = x22 * 1.e-6 * 12.0107 * 86400. ; umole/m2/s -> gC/m2/day
        end if
        if (vars(i) .eq. "GPP") then
                x1 = x1*86400   ; gC/m2/s -> gC/m2/day
                x2 = x2*86400   ; gC/m2/s -> gC/m2/day
     		x11 = x11*86400 ; gC/m2/s -> gC/m2/day
     		x22 = x22*86400 ; gC/m2/s -> gC/m2/day
        end if
     	if (vars(i) .eq. "ASA")
        	if (isdouble(obs)) then
     	   		fobs = dble2flt(obs(0,:,:))
        	else
     	   		fobs = obs(0,:,:)
        	end if
	else
        	if (isdouble(obs)) then
     	   		fobs = dble2flt(obs)
        	else
     	   		fobs = obs
        	end if
	end if

	x1_mn(s,:,:) = x11						  ; Seasonal record
	x2_mn(s,:,:) = x22						  ; Seasonal record
	obs_mn(s,:,:) = fobs						  ; Seasonal record

   	x1_mnvar(s,:,:) = dim_variance_Wrap(x1(lat|:,lon|:,time|:) )      ; variance for ttest (annual record)
     	x2_mnvar(s,:,:) = dim_variance_Wrap(x2(lat|:,lon|:,time|:) )      ; variance for ttest (annual record)
     
     end do

     delete(x1)
     delete(x2)
     delete(x11)
     delete(x22)
     delete(obs)
     delete(fobs)

   ; =======================================================
   ; read all 12 months of obs for annual cycle
   ; =======================================================
     if(isvar("obs") ) then
	delete(obs_ac)
     end if
     casename = new(nvars+1,"string")
     seasonal = False
     obs = read_obs(filevar,lat1,lon1,nlat1,nlon1,casename(2),seasonal,0)
     if (iscoord(obs,(/"lon"/))) then
     	if (min(obs&lon) .ge. 0) then
     		obs = lonFlip(obs)
        end if
     else
        if (iscoord(obs,(/"lsmlon"/))) then
     		if (min(obs&lsmlon) .ge. 0) then
     			obs = lonFlip(obs)
        	end if
        end if
     end if

     if (isdouble(obs)) then
     	obs_ac = dble2flt(obs)
     else
     	obs_ac = obs
     end if

    ; ========================
    ; write out obs to netcdf
    ; ========================

;;  	filo1  = ptmpdir1 +"/model1-model2/"+prefix1+"_OBS_"+vars(i)+".nc"
  	filo1  = ptmpdir1 +"/"+prefix1+"_OBS_"+vars(i)+".nc"
  	system("/bin/rm -f " + filo1)
  	fout = addfile(filo1,"c")
	
  	fileAtt               = True
  	fileAtt@history       = "obs data after interpolation"
  	fileAtt@creation_date = systemfunc("date")
  	fileattdef(fout, fileAtt)
	
  	dimNames      = (/"month","lat","lon"/)
  	dimSizes      = (/12,nlat1,nlon1/)             ; bummer that this is hardwired....
  	dimUnlim      = (/False,False,False/)
	
  	filedimdef(fout,dimNames,dimSizes,dimUnlim)
        filevardef(fout,vars(i),"float",(/"month","lat","lon"/))
        fout->$vars(i)$ = obs_ac
	delete(filo1)

     ; ==========================
     ; end write to netcdf
     ; ==========================

  ; =======================================================
  ; Start processing:  assess model differences : model vs control
  ; =======================================================

   ; ==========================
   ; mask data and create 1d Arrays
   ; ==========================
;    area1  = mask(area1,     ismissing(x1_ac(0,:,:)), False)
;    area2  = mask(area2,     ismissing(x2_ac(0,:,:)), False)

; Mask area by missing data in observations
; Need to set to missing only if all months are missing because rmse will be computed 
;  below as long as at least one month is not missing
     do ii = 0,nlat1-1
       do jj = 0,nlon1-1
         area1(ii,jj)  = mask(area1(ii,jj),     all(ismissing(obs_ac(:,ii,jj))), False)
       end do
     end do
     do ii = 0,nlat2-1
       do jj = 0,nlon2-1
         area2(ii,jj)  = mask(area2(ii,jj),     all(ismissing(obs_ac(:,ii,jj))), False)
       end do
     end do

     x1_acm   = x1_ac
     x2_acm   = x2_ac
     obs_acm  = obs_ac
     x1_acm   = mask(x1_acm,    landmask1   .ne. 1, False)	; mask out partial gridcells
     x2_acm   = mask(x2_acm,    landmask2   .ne. 1, False)	; mask out partial gridcells
     obs_acm  = mask(obs_acm,   landmask1   .ne. 1, False)	; mask out partial gridcells
     x1_mn    = mask(x1_mn,     landmask1   .ne. 1, False)	; mask out partial gridcells
     x2_mn    = mask(x2_mn,     landmask2   .ne. 1, False)	; mask out partial gridcells
     obs_mn   = mask(obs_mn,    landmask1   .ne. 1, False)	; mask out partial gridcells
     x1_mnvar = mask(x1_mnvar,  landmask1   .ne. 1, False)	; mask out partial gridcells
     x2_mnvar = mask(x2_mnvar,  landmask2   .ne. 1, False)	; mask out partial gridcells

     x1_acm   = mask(x1_acm,    pct_glacier .ne. 0, False)	; mask out glacier gridcells
     x2_acm   = mask(x2_acm,    pct_glacier .ne. 0, False)	; mask out glacier gridcells
     obs_acm  = mask(obs_acm,   pct_glacier .ne. 0, False)	; mask out glacier gridcells
     x1_mn    = mask(x1_mn,     pct_glacier .ne. 0, False)	; mask out partial gridcells
     x2_mn    = mask(x2_mn,     pct_glacier .ne. 0, False)	; mask out partial gridcells
     obs_mn   = mask(obs_mn,    pct_glacier .ne. 0, False)	; mask out partial gridcells
     x1_mnvar = mask(x1_mnvar,  pct_glacier .ne. 0, False)	; mask out partial gridcells
     x2_mnvar = mask(x2_mnvar,  pct_glacier .ne. 0, False)	; mask out partial gridcells

     area1   = mask(area1,      pct_glacier .ne. 0, False)	; mask out glacier gridcells
     area2   = mask(area2,      pct_glacier .ne. 0, False)	; mask out glacier gridcells

     landfrac1  = mask(landfrac1, pct_glacier .ne. 0, False)	; mask out glacier gridcells
     landfrac2  = mask(landfrac2, pct_glacier .ne. 0, False)	; mask out glacier gridcells
     landmask1  = mask(landmask1, pct_glacier .ne. 0, False)	; mask out glacier gridcells
     landmask2  = mask(landmask2, pct_glacier .ne. 0, False)	; mask out glacier gridcells

     area1  = area1*landfrac1
     area2  = area2*landfrac2

     weights_1n = area1 / sum(area1)
     weights_2n = area2 / sum(area2)

     area1d     = ndtooned(area1)
     area2d     = ndtooned(area2)

   ; ==========================
   ; RMSE
   ; ==========================

     prob = new((/dim/),float,0)  ; !!! replace with statistics if available

     ; 2D RMSE map
     x1_acrmse = dim_rmsd_Wrap(x1_acm(lat|:,lon|:,time|:),obs_acm(lat|:,lon|:,month|:) )
     x2_acrmse = dim_rmsd_Wrap(x2_acm(lat|:,lon|:,time|:),obs_acm(lat|:,lon|:,month|:) )

     indx = ind(ismissing(ndtooned(x1_acrmse)) .and. .not.(ismissing(ndtooned(weights_1n))))
     if (.not.(all(ismissing(indx)))) then
       print((/"WARNING: Model and/or obs data is missing for valid area averaging weights for variable: "+vars(i)/))
     end if
     delete(indx)
     indx = ind(.not.(ismissing(ndtooned(x1_acrmse))) .and. ismissing(ndtooned(weights_1n)))
     if (.not.(all(ismissing(indx)))) then
       print((/"WARNING: Area averaging weights are missing for valid model and/or obs data for variable: "+vars(i)/))
     end if
     delete(indx)

     ; global weighted average RMSE 
     x1_acrmse_avg = wgt_areaave2(x1_acrmse,weights_1n,0)
     x2_acrmse_avg = wgt_areaave2(x2_acrmse,weights_2n,0)

     ; out 1.  RMSE
     stat = 0
     statsOut(stat,0) = x1_acrmse_avg
     statsOut(stat,1) = x2_acrmse_avg

     ; create 1D vectors
     x1_1d = ndtooned(x1_acrmse)
     x2_1d = ndtooned(x2_acrmse)

     rmse_imp = new((/dim/),"float",1e30)
     b = ind( (abs(x2_1d  - x1_1d) .ge. diff_phys_rmse(i)) .and. \
	    (    x2_1d .lt. x1_1d) )
     g = ind( (abs(x2_1d  - x1_1d) .ge. diff_phys_rmse(i)) .and. \
	    (    x2_1d .gt. x1_1d) )

     if (.not.all(ismissing(g)))
        rmse_imp_area(0) = 100. * (sum(area1d(g))/sum(area1d))
        rmse_imp(g) = 2
     end if
     if (.not.all(ismissing(b)))
        rmse_imp_area(1) = 100. * (sum(area1d(b))/sum(area1d))
        rmse_imp(b) = 1
     end if
     rmse_map = onedtond(rmse_imp,(/nlat1,nlon1/) )
     copy_VarCoords(x1_acrmse,rmse_map)

     ; out 2.  RMSE % area
     stat = 1
     statsOut(stat,0) = rmse_imp_area(0)
     statsOut(stat,1) = rmse_imp_area(1)

     delete(g)
     delete(b)
     delete(prob)
     delete(rmse_imp)

   ; ==========================
   ; correlation (r)
   ; ==========================

     ; 2D mapping data
     x1_corr = escorc(x1_acm(lat|:,lon|:,time|:),obs_acm(lat|:,lon|:,month|:) )
     x2_corr = escorc(x2_acm(lat|:,lon|:,time|:),obs_acm(lat|:,lon|:,month|:) )

     x1_corr = mask(x1_corr, fabs(x1_corr) .lt. 0.5, False)
     x2_corr = mask(x2_corr, fabs(x2_corr) .lt. 0.5, False)

     ; create 1D vectors
     x1_acr1d = ndtooned(x1_corr)
     x2_acr1d = ndtooned(x2_corr)

     ; identify areas with good correlation
     g = ind(x1_acr1d .ge. acr_good)
     if (.not. all(ismissing(g))) then
        	acr_good_area(0) = 100. * (sum(area1d(g))/sum(area1d))
     end if
     delete(g)
     g = ind(x2_acr1d .ge. acr_good)
     if (.not. all(ismissing(g))) then
        	acr_good_area(1) = 100. * (sum(area2d(g))/sum(area2d))
     end if

     ; out 13.  % area with r > 0.9
     stat = 12
     statsOut(stat,0) = acr_good_area(0)		; % area with r>0.9
     statsOut(stat,1) = acr_good_area(1)		; % area with r>0.9

     delete(g)

     b = ind( (x2_acr1d - x1_acr1d) .ge.    acr_diff_sig(i) )
     g = ind( (x2_acr1d - x1_acr1d) .le. -1*acr_diff_sig(i) )
     if (.not.all(ismissing(g)))
        	acr_area(0) = 100. * (sum(area1d(g))/sum(area1d))
     end if
     if (.not.all(ismissing(b)))
        	acr_area(1) = 100. * (sum(area1d(b))/sum(area1d))
     end if

     acr_map = x1_corr-x2_corr

     delete(g)
     delete(b)
     delete(x1_acr1d)
     delete(x2_acr1d)

   ; ==========================
   ; stdev
   ; ==========================

     ; 2D Mapping data
     x1_acsd = dim_stddev_Wrap( x1_acm(lat|:,lon|:,time|:) )	; stdev of annual cycle
     x2_acsd = dim_stddev_Wrap( x2_acm(lat|:,lon|:,time|:) )	; stdev of annual cycle
     obs_acsd = dim_stddev_Wrap(obs_acm(lat|:,lon|:,month|:) )	; stdev of annual cycle
     delete(x1_acm)
     delete(x2_acm)

     ; global average
     x1_acsd_avg = wgt_areaave2(x1_acsd,weights_1n,0)
     x2_acsd_avg = wgt_areaave2(x2_acsd,weights_2n,0)

     ; create vectors
     x1_sd  = ndtooned(x1_acsd)
     x2_sd  = ndtooned(x2_acsd)
     obs_sd = ndtooned(obs_acsd)

     sd_imp = new((/dim/),"float")
     b = ind( (abs(x2_sd  -   x1_sd) .ge. diff_phys_std(i)) .and. \                ; x2 better than x1
               abs(x2_sd  -  obs_sd) .lt. abs(  x1_sd - obs_sd)  )
     g = ind( (abs(x2_sd  -   x1_sd) .ge. diff_phys_std(i)) .and. \                ; x1 better than x2
               abs(x2_sd  -  obs_sd) .gt. abs(  x1_sd - obs_sd)  )
     if (.not.all(ismissing(g)))
        sd_imp_area(1) = 100. * (sum(area1d(g))/sum(area1d))
        sd_imp(g) = 2
     end if
     if (.not.all(ismissing(b)))
        sd_imp_area(0) = 100. * (sum(area1d(b))/sum(area1d))
        sd_imp(b) = 1
     end if
     sd_map = onedtond(sd_imp,(/nlat1,nlon1/) )
     delete(g)
     delete(b)
     delete(x1_sd)
     delete(x2_sd)
     delete(sd_imp)


   ; ====================================
   ; Seasonal bias (models vs obs)
   ; ====================================

   do s=0,dimsizes(seasons)-1 
   	x1_bias(s,:,:) = x1_mn(s,:,:) - obs_mn(s,:,:)
   	x2_bias(s,:,:) = x2_mn(s,:,:) - obs_mn(s,:,:)

        x1_mn1d  = ndtooned( x1_mn(s,:,:))
        x2_mn1d  = ndtooned( x2_mn(s,:,:))
        obs_mn1d = ndtooned(obs_mn(s,:,:))

     	prob = ttest(x1_mn(s,:,:),x1_mnvar(s,:,:),nyrs1,x2_mn(s,:,:),x2_mnvar(s,:,:),nyrs2,True,False)
     	p1d = ndtooned(prob)

        bias_imp = new((/dim/),"float")

        b = ind(p1d .le. siglvl_mn .and. \
                (abs(x2_mn1d-obs_mn1d) .le. abs(x1_mn1d-obs_mn1d)) .and. \
                (abs(x2_mn1d- x1_mn1d) .ge. diff_phys_mn(i)) )
        g = ind(p1d .le. siglvl_mn .and. \
                (abs(x2_mn1d-obs_mn1d) .ge. abs(x1_mn1d-obs_mn1d)) .and. \
                (abs(x2_mn1d- x1_mn1d) .ge. diff_phys_mn(i)) )
        if (.not.all(ismissing(g)))
                bias_imp_area(s,0) = 100. * sum(area1d(g))/sum(area1d)
                bias_imp(g) = 2
        end if
        if (.not.all(ismissing(b)))
                 bias_imp_area(s,1) = 100. * sum(area1d(b))/sum(area1d)
                 bias_imp(b) = 1
        end if
        bias_map(s,:,:) = onedtond(bias_imp,(/nlat1,nlon1/) )

        x1_bias_mn(s) = sum(area1d * (x1_mn1d-obs_mn1d))/sum(area1d)
        x2_bias_mn(s) = sum(area1d * (x2_mn1d-obs_mn1d))/sum(area1d)
 
	
	if  (seasons(s) .eq. "ANN") then
		stat = 2
	end if
       	; out 2,4,6,8,10.  Bias
       	statsOut(stat,0) = x1_bias_mn(s)
       	statsOut(stat,1) = x2_bias_mn(s)
       	stat = stat + 1

       	; out 3, 5,7,9,11.  Bias % area
       	statsOut(stat,0) = bias_imp_area(s,0)
       	statsOut(stat,1) = bias_imp_area(s,1)
       	stat = stat + 1

        delete(prob)
        delete(p1d)
        delete(x1_mn1d)
        delete(x2_mn1d)
	delete(bias_imp)
	delete(g)
	delete(b)
   end do   ; seasons loop 


  ; =======================================================
  ; PLOTTING
  ; =======================================================

   plot = new(3,graphic)
   wks  = gsn_open_wks(plot_type,wkdir+"set9_rmse_"+vars(i))

  ; =======================================================
  ; plot RMSE  
  ; =======================================================
     res = True
     if (colormap.eq.0) then
        gsn_define_colormap(wks,"testcmap")
     end if
     if (colormap.eq.1) then
        gsn_define_colormap(wks,"ncl_default")
        cmap1 = gsn_retrieve_colormap(wks)
        res@cnFillPalette = cmap1(13:240,:)
     end if
     
     res = set9Res(res)

     maxLevel = 11
     if (vars(i) .eq. "LHEAT") then
       useMin = 0
       useMax = 40
     else
       if (vars(i) .eq. "ASA") then
         useMin = 0
         useMax = 10
       else
         useMin = 0
         useMax = 5
       end if
     end if
     mnmxint = nice_mnmxintvl( useMin, useMax, maxLevel, True)
     res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
     res@cnMinLevelValF       = mnmxint(0)
     res@cnMaxLevelValF       = mnmxint(1)
     res@cnLevelSpacingF      = mnmxint(2)
;     res@cnFillColors         = (/2, 4,12, 53, 38, 61, 74,135,146,156,169,185/)          
;     res@gsnSpreadColors      = False
     delete(mnmxint)

  ; rmse plots
  ; Plot 1
     res@tiMainString    = "RMSE("+vars(i)+") " + cases(0)
     res@gsnCenterString =  sprintf("%6.2f",(x1_acrmse_avg))
;     printVarSummary(res)
;     exit
     
     plot(0) = gsn_csm_contour_map(wks,x1_acrmse,res) ; will be sig test

  ; Plot 2
     res@tiMainString    = "RMSE("+vars(i)+") " + cases(1) + " (control)"
     res@gsnCenterString = sprintf("%6.2f",(x2_acrmse_avg))
     plot(1) = gsn_csm_contour_map(wks,x2_acrmse,res) ; will be sig test

  ; rmse vs obs plots
  ; Plot 3
     ; reset resources for difference plot
     delete(res)

     res = True
     res = set9Res(res)

     res@cnFillOn             = True          ; turn on color fill
     res@cnLinesOn            = False         ; turn on contour lines

     res@lbLabelBarOn         = False
     res@tiMainString         = "Model relative to Obs"
     res@gsnCenterString      = "green: "+ cases(0)+"~C~red: "+cases(1)

     res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
     res@cnMinLevelValF       =   1                ; set min contour level
     res@cnMaxLevelValF       =   2                ; one less than max
     res@cnLevelSpacingF      =   1                ; set contour spacing
     res@cnFillColors         = (/"white","red","green"/) ; white=NoChange; red=Case2 better; green=Case1 better
     res@gsnLeftString        = ""
     res@gsnRightString       = ""

  ; Plot 1.3
     plot(2) = gsn_csm_contour_map(wks, rmse_map,res) ; will be sig test

  ; Panel plot
     pres = True
     nrows = 3
     ncols = 1
     pres@gsnMaximize 	      = True
;     pres@gsnPanelDebug = True
     pres@gsnPanelYF  = (/-1,-1,.265 /)     ; reposition 3rd panel downwards to allow space for titles
     gsn_panel(wks,plot,(/nrows,ncols/),pres)           ; draw panel plot
     delete([/res,pres/])

   ; =======================================================
   ; plot BIAS  
   ; =======================================================

     do s=0,dimsizes(seasons)-1 
   	; set resources
     	res = True
     	res = set9Res(res)

     	res@cnRasterModeOn           = True
;     	res@gsnSpreadColors          = False

  	; Set colortables
     	res@cnLevelSelectionMode = "ExplicitLevels" ; ncl defined contour levels

       	bias1 =  x1_bias(s,:,:)	
       	bias2 =  x2_bias(s,:,:)	
       	bmap  = bias_map(s,:,:)	

       	copy_VarCoords(x1_acrmse,bias1)
       	copy_VarCoords(x2_acrmse,bias2)
       	copy_VarCoords(x1_acrmse,bmap)

       	wks  = gsn_open_wks(plot_type,wkdir+"set9_bias_"+vars(i)+"_"+seasons(s))
        if (colormap.eq.0) then
           gsn_define_colormap(wks,"testcmap")
           res@cnFillColors = (/2, 15, 52, 101, 101, 153, 192, 182/)
        end if
        if (colormap.eq.1) then
           gsn_define_colormap(wks,"ncl_default")
           cmap1 = gsn_retrieve_colormap(wks)
           res@cnFillPalette = cmap1(13:240,:)
        end if

      ; individual plots --------------------------------------
	if (vars(i) .eq. "TSA") then
        	res@cnLevels     = (/-4.0, -2.0, -1.0, 0.0, 1.0, 2.0, 4.0/)
        	res@lbTitleString   = "C"
	end if
	if (vars(i) .eq. "PREC") then
        	res@cnLevels     = (/-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0/)
        	res@lbTitleString        = "mm/day"
	end if
	if (vars(i) .eq. "ASA") then
        	res@cnLevels     = (/-6.0, -3.0, -1.0, 0.0, 1.0, 3.0, 6.0/)
        	res@lbTitleString        = "%"
	end if
	if (vars(i) .eq. "LHEAT") then
        	res@cnLevels     = (/-30.0, -20.0, -10.0, 0.0, 10.0, 20.0, 30.0/)
        	res@lbTitleString        = "W/m2"
	end if
	if (vars(i) .eq. "FPSN" .or. vars(i) .eq. "GPP") then
        	res@cnLevels     = (/-5.0, -3.0, -1.0, 0.0, 1.0, 3.0, 5.0/)
        	res@lbTitleString        = "gC/m2/day"
	end if
        if (vars(i) .eq. "TLAI") then
                res@cnLevels     = (/-3.0, -1.0, -0.25, 0.0, 0.25, 1.0, 3.0/)
                res@lbTitleString        = ""
        end if

      ; plot 1
        res@tiMainString    = seasons(s)+" Bias("+vars(i)+") " + cases(0)
     	res@gsnCenterString = x1_bias_mn(s)
     	plot(0) = gsn_csm_contour_map(wks,bias1,res) ; will be sig test
	
      ;  plot 2
        res@tiMainString    = seasons(s)+" Bias("+vars(i)+") " + cases(1)
     	res@gsnCenterString = x2_bias_mn(s)
     	plot(1) = gsn_csm_contour_map(wks,bias2,res) ; will be sig test
	
      ; plot model relative to obs ------------------------

      ; reset resources for difference plot
        delete(res)
   
        res = True
   	res = set9Res(res)
  	res@cnFillOn             = True          ; turn on color fill
  	res@cnLinesOn            = False         ; turn on contour lines
   
   	res@lbLabelBarOn         = False
        res@lbTitleString        = ""
   	res@tiMainString         = "Model relative to Obs"
       	res@gsnCenterString      = "green: "+ cases(0)+"~C~red: "+cases(1)
  	 
  	res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
   	res@cnMinLevelValF       =   1                ; set min contour level
   	res@cnMaxLevelValF       =   2                ; one less than max
   	res@cnLevelSpacingF      =   1                ; set contour spacing
   	res@cnFillColors         = (/"white","red","green"/) ; white=NoChange; red=Case2 better; green=Case1 better
   	res@gsnLeftString        = ""
   	res@gsnRightString       = ""

      ;  plot 3
     	res@gsnCenterString = bias_imp_area(s,0)+"% - " +bias_imp_area(s,1)+"%"
     	plot(2) = gsn_csm_contour_map(wks, bmap,res) ; will be sig test
	
     	pres = True
        pres@gsnMaximize 	      = True
     	gsn_panel(wks,plot,(/nrows,ncols/),pres)           ; draw panel plot
 	
	delete(bias1)
	delete(bias2)
	delete(bmap)
        delete(res)
   	
     end do

   ; =======================================================
   ; plot corr   (r)
   ; =======================================================
     print("plotting r")
     wks  = gsn_open_wks(plot_type,wkdir+"set9_corr_"+vars(i))

     copy_VarCoords(x1_acrmse,x1_corr)
     copy_VarCoords(x2_acrmse,x2_corr)
     copy_VarCoords(x2_acrmse,acr_map)

   ; set resources
     res = True
     
     
     res = set9Res(res)

;     res@gsnSpreadColors          = False

   ; Set colortables
     res@cnLevelSelectionMode = "ExplicitLevels" ; ncl defined contour levels
     ; res@cnLevels     = (/0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95/)
     res@cnLevels     = (/0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90, 0.95, 1.00/)
     if (colormap.eq.0) then
        gsn_define_colormap(wks,"testcmap")
        res@cnFillColors = (/   2,    4,   12,   53,   38,   61,   74,  135,  146,  156,  185, 185/)     
     end if
     if (colormap.eq.1) then
        gsn_define_colormap(wks,"ncl_default")
        cmap1 = gsn_retrieve_colormap(wks)
        res@cnFillPalette = cmap1(13:240,:)
     end if
     
     res@lbTitleString   = ""

   ; model correlation to obs
   ; plot 1
     res@tiMainString    = "r("+vars(i)+") " + cases(0)
     res@gsnCenterString = acr_good_area(0)
     plot(0) = gsn_csm_contour_map(wks,x1_corr,res) ; will be sig test

   ; plot 2
     res@tiMainString    = "r("+vars(i)+") " + cases(1)
     res@gsnCenterString = acr_good_area(1)
     plot(1) = gsn_csm_contour_map(wks,x2_corr,res) ; will be sig test

   ; performance relative to obs

     delete(res@gsnCenterString)
     delete(res@cnLevels)
;     delete(res@cnFillColors)
     res@cnLevels     = (/-0.28, -0.21, -0.14, -0.07, 0.00, 0.07, 0.14, 0.21, 0.28/)
     if (colormap.eq.0) then
        gsn_define_colormap(wks,"testcmap")
        res@cnFillColors = (/    2,    15,    20,    52,   101,  101,  153,  169, 182, 192/)     
     end if
     if (colormap.eq.1) then
        gsn_define_colormap(wks,"ncl_default")
        cmap1 = gsn_retrieve_colormap(wks)
        res@cnFillPalette = cmap1(13:240,:)
     end if

   ; plot 3
     res@tiMainString    = "r("+vars(i)+") " + cases(0) + " - " + cases(1)
     res@gsnCenterString = acr_area(0)+ "% - " + acr_area(1)+"%"
     plot(2) = gsn_csm_contour_map(wks, acr_map,res) ; will be sig test

     pres = True
     pres@gsnMaximize 	      = True
     gsn_panel(wks,plot,(/nrows,ncols/),pres)           ; draw panel plot
   ; =======================================================
   ; plot stdev 
   ; =======================================================

     print("plotting stdev")
     delete(res)

     ; set resources
     res = True
     res = set9Res(res)

;     res@gsnSpreadColors          = False

    ; Set colortables
     res@cnLevelSelectionMode = "ExplicitLevels" ; ncl defined contour levels

     wks  = gsn_open_wks(plot_type,wkdir+"set9_stdev_"+vars(i))

     if (colormap.eq.0) then
        gsn_define_colormap(wks,"testcmap")
        res@cnFillColors = (/2, 15, 52, 101, 101, 153, 192, 182/)    
     end if
     if (colormap.eq.1) then
        gsn_define_colormap(wks,"ncl_default")
        cmap1 = gsn_retrieve_colormap(wks)
        res@cnFillPalette = cmap1(13:240,:)
     end if

     copy_VarCoords(x1_acrmse,x1_acsd)
     copy_VarCoords(x2_acrmse,x2_acsd)
;    copy_VarCoords(x2_acrmse,obs_acsd)
     copy_VarCoords(x2_acrmse,sd_map)

     if (vars(i) .eq. "TSA") then
     		res@cnLevels     = (/-4.0, -2.0, -1.0, 0.0, 1.0, 2.0, 4.0/)
     		res@lbTitleString        = "C"
     end if
     if (vars(i) .eq. "PREC") then
     		res@cnLevels        = (/-2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0/)
     		res@lbTitleString   = "mm/day"
     end if
     if (vars(i) .eq. "LHEAT") then
     		res@cnLevels        = (/-30.0, -20.0, -10.0, 0.0, 10.0, 20.0, 30.0/)
     		res@lbTitleString   = "mm/day"
     end if
     if (vars(i) .eq. "FPSN" .or. vars(i) .eq. "GPP") then
     		res@cnLevels        = (/-5.0, -3.0, -1.0, 0.0, 1.0, 3.0, 5.0/)
     		res@lbTitleString   = "gC/m2/day"
     end if

   ; model relative to obs
   ; plot 1
     res@tiMainString = "o("+vars(i)+") " + cases(0) + "-obs"
     d1 = x1_acsd
     d1 = x1_acsd-obs_acsd
     plot(0) = gsn_csm_contour_map(wks,d1,res) ; will be sig test

   ; plot 2
     res@tiMainString    = "o("+vars(i)+") " + cases(1) + "-obs"
     d2 = x2_acsd
     d2 = x2_acsd-obs_acsd
     plot(1) = gsn_csm_contour_map(wks,d2,res) ; will be sig test

     delete(d1)
     delete(d2)

   ; performance relative to obs

     delete(res)

     res = True
     res = set9Res(res)

     res@cnFillOn             = True          ; turn on color fill
     res@cnLinesOn            = False         ; turn on contour lines

     res@lbLabelBarOn         = False
     res@tiMainString         = "Model relative to Obs"
     res@gsnCenterString      = "green: "+ cases(0)+"~C~red: "+cases(1)

     res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
     res@cnMinLevelValF       =   1                ; set min contour level
     res@cnMaxLevelValF       =   2                ; one less than max
     res@cnLevelSpacingF      =   1                ; set contour spacing
     res@cnFillColors         = (/"white","red","green"/) ; white=NoChange; red=Case2 better; green=Case1 better
     res@gsnLeftString        = ""
     res@gsnRightString       = ""

   ; plot 3
     plot(2) = gsn_csm_contour_map(wks, sd_map,res) ; will be sig test

     pres = True
     pres@gsnMaximize 	      = True
;     pres@gsnPanelDebug = True
     pres@gsnPanelYF  = (/-1,-1,.265 /)     ; reposition 3rd panel downwards to allow space for titles
     gsn_panel(wks,plot,(/nrows,ncols/),pres)           ; draw panel plot
     delete([/res,pres/])
     delete(x1_acsd)
     delete(x2_acsd)
     delete(obs_acsd)
     delete(sd_imp_area)
     delete(sd_map)
   
    ; correlation (r) vars
     delete(x1_corr)
     delete(x2_corr)
     delete(acr_good_area)
     delete(acr_map)
  
    ; RMSE vars
     delete(x1_acrmse)
     delete(x2_acrmse)
     delete(rmse_imp_area)
     delete(rmse_map)
     delete(x1_acrmse_avg)
     delete(x2_acrmse_avg)
 
    ; bias vars
     delete(x1_mn)
     delete(x2_mn)
     delete(obs_mn)
     delete(x1_mn_avg)
     delete(x2_mn_avg)
     delete(x1_mnvar)
     delete(x2_mnvar)
     delete(x1_bias)
     delete(x2_bias)
     delete(bias_map)
     delete(bias_imp_area)
     delete(x1_bias_mn)
     delete(x2_bias_mn)
     delete(acr_area)
     delete(area1)
     delete(area2)
     delete(landfrac1)
     delete(landfrac2)
     delete(landmask1)
     delete(landmask2)

   ; =======================================================
   ; End Plotting
   ; =======================================================
   ; Write Stats
   ; =======================================================

  
     fWidth   = 10
     M        = 3
     fDec     = 2
     fmtx     = M + "f"+fWidth+"."+fDec
     opt      = True
     opt@row  = True				; add line numbers
     opt@title  = "    "+cases(0) + "   " + cases(1)
   
     opt@fout = wkdir+"/set9_"+vars(i)+"_statsOut.txt"	; output filename
     statsOut = where(ismissing(statsOut),0.,statsOut)
     write_matrix(statsOut,fmtx,opt)
     delete(statsOut)

  end do ; end variable loop

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set9_error_file"              
  system("/bin/rm -f " + filo)  

end
