load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/lnd_func.ncl"
;************************************************
begin
 print ("=========================================")
 print ("Starting:  set_3.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
  resdir    = getenv("DIAG_RESOURCES")
  inputdir  = getenv("INPUT_FILES")
  diag_home = getenv("DIAG_HOME")
  plot_type = getenv("PLOTTYPE")
  paleo	    = getenv("paleo")
  land_mask = getenv("land_mask1")
  landmask  = stringtofloat(land_mask)
  cn	    = getenv("CN")
  clamp	    = getenv("CLAMP")
  casa	    = getenv("CASA")
  hydroFlag = getenv("HYDRO")
  obsdata   = getenv("OBS_DATA")
  debugFlag = getenv("debugFlag")
 useCommon1 = getenv("UseCommonName_1")
 useCommon2 = getenv("UseCommonName_2")
  plot_type = getenv("PLOTTYPE")

;*************************************************
; get case names and create filenames to read in
;*************************************************
  ptmpdir1 = getenv("PTMPDIR_1")
  ptmpdir2 = getenv("PTMPDIR_2")
  wkdir   = getenv("WKDIR")

;***********************************************
; import regional information
;***********************************************

 secondsPerDay = 86400.
 months = 12   ; number of months
 regions_file = addfile(resdir+"/region_definitions.nc","r")
; regions_file = addfile("/glade/u/home/dlawren/region_polar.nc","r")
 box_n = regions_file->BOX_N
 box_w = regions_file->BOX_W
 box_e = regions_file->BOX_E
 box_s = regions_file->BOX_S
 nreg  = dimsizes(box_s)    ; number of regions
 tmp   = regions_file->PS_ID
 ps_id = charactertostring(tmp)
 delete(tmp)
 tmp   = regions_file->PTITSTR
 ptitstr = charactertostring(tmp)
 delete(tmp)
 tmp   = regions_file->BOXSTR
 boxstr = charactertostring(tmp)
 delete(tmp)

;*************************************************
; main loop
;*************************************************

nplots = 9
nmons = 13

; loop over plots
do p=0,nplots-1

print("Now printing plot #" + p)
  if (p .eq. 0) then 
        if (cn .eq. 1) then
          fileName   = "set3_cn_landFlx.txt"
        else
          fileName   = "set3_landFlx.txt"
        end if
        plot_name  = "landf"
 	titstr = new(8,"string")
 	titstr(0) = "2m Air Temperature (~S~o~N~K)"
 	titstr(1) = "Precipitation (mm day~S~-1~N~)"
 	titstr(2) = "Runoff (mm day~S~-1~N~)"
 	titstr(3) = "Snow Depth (m)"
        titstr(4) = "Latent Heat Flux (W m~S~-2~N~)"
        titstr(5) = "Photosynthesis (gC m~S~-2~N~day~S~-1~N~)"
        titstr(6) = "Leaf Area Index"
        titstr(7) = "Soil Moisture Storage - liq+ice (kg m~S~-2~N~)"
  end if
  if (p .eq. 1) then
        fileName   = "set3_radFlx.txt"
        plot_name  = "radf"
 	titstr = new(7,"string")
 	titstr(0) = "Incoming Solar"
 	titstr(1) = "Albedo"
 	titstr(2) = "Absorbed Solar"
 	titstr(3) = "Incoming Longwave"
 	titstr(4) = "Emitted Longwave"
 	titstr(5) = "Net Longwave"
 	titstr(6) = "Net Radiation"
  end if
  if (p .eq. 2) then
        fileName   = "set3_turbFlx.txt"
        plot_name  = "turbf"
 	titstr = new(10,"string")
 	titstr(0) = "Net Radiation"
 	titstr(1) = "Sensible Heat"
 	titstr(2) = "Latent Heat"
 	titstr(3) = "Transpiration"
 	titstr(4) = "Canopy Evaporation"
 	titstr(5) = "Ground Evaporation"
 	titstr(6) = "Ground Heat + Snow Melt"
 	titstr(7) = "Soil moisture factor (BTRAN or BTRANMN)"
 	titstr(8) = "Evaporative Fraction"
 	titstr(9) = "Total LAI"
  end if
  if (p .eq. 3) then
    if (clamp .eq. 1) then
                fileName   = "set3_clampFlx.txt"
                plot_name  = "cnFlx"
                titstr = new(6,"string")
                titstr(0) = "Net Ecosystem Exchange"
                titstr(1) = "GPP"
                titstr(2) = "NPP"
                titstr(3) = "Autotrophic Respiration"
                titstr(4) = "Heterotrophic Respiration"
                titstr(5) = "Net Ecosystem Production"
    else
        if (cn .eq. 1) then
                fileName   = "set3_cnFlx.txt"
                plot_name  = "cnFlx"
                titstr = new(10,"string")
                titstr(0) = "Net Ecosystem Exchange"
                titstr(1) = "GPP"
                titstr(2) = "NPP"
                titstr(3) = "Autotrophic Respiration"
                titstr(4) = "Heterotrophic Respiration"
                titstr(5) = "Ecosystem Respiration"
                titstr(6) = "Surface CH4 Flux"
                titstr(7) = "Leached Mineral Nitrogen"
                titstr(8) = "Soil NO3 Pool Loss to Leaching"
                titstr(9) = "Soil NO3 Pool Loss to Runoff"
        else
            if (casa .eq. 1) then
                fileName   = "set3_casaFlx.txt"
                plot_name  = "cnFlx"
                titstr = new(5,"string")
                titstr(0) = "Net Ecosystem Exchange"
                titstr(1) = "GPP"
                titstr(2) = "NPP"
                titstr(3) = "Autotrophic Respiration"
                titstr(4) = "Heterotrophic Respiration"
            else
                continue
            end if
        end if
    end if
  end if
  if (p .eq. 4) then
    if (cn .eq. 1) then
        fileName   = "set3_fireFlx.txt"
        plot_name  = "frFlx"
 	titstr = new(6,"string")
 	titstr(0) = "Column-Level Fire C Loss"
 	titstr(1) = "Column-Level Fire N Loss"
 	titstr(2) = "PFT-Level Fire C Loss"
 	titstr(3) = "PFT-Level Fire N Loss"
 	titstr(4) = "Fractional Area Burned"
 	titstr(5) = "Fractional Area Burned - Crop"
     else
	continue
     end if
  end if
  if (p .eq. 5) then
        fileName   = "set3_moistEnergyFlx.txt"
        plot_name  = "moistEnergyFlx"
 	titstr = new(3,"string")
 	titstr(0) = "Precipitation"
 	titstr(1) = "Net Radiation"
 	titstr(2) = "Evapotranspiration"
  end if
  if (p .eq. 6) then
     if (hydroFlag .eq. 1) then
        fileName   = "set3_hydro.txt"
        plot_name  = "hydro"
        titstr = new(5,"string")
        titstr(0) = "Water in Unconfined Aquifer"       ; WA
        titstr(1) = "Water Table Depth"                 ; ZWT
        titstr(2) = "Aquifer Recharge Rate"             ; QCHARGE
        titstr(3) = "Frac Water Table at Surface"       ; FCOV
        titstr(4) = "Total Water Storage"               ; TWS
     else
        continue
     end if 
   end if 
  if (p .eq. 7) then
        fileName   = "set3_snow.txt"
        plot_name  = "snow"
	if (paleo .eq. "True") then
        	titstr = new(4,"string")
        	titstr(0) = "Snow height"      		; SNOWDP
        	titstr(1) = "Fractional Snow Cover"	; FSNO
        	titstr(2) = "Snow Water Equivalent"     ; H2OSNO
	else
        	titstr = new(4,"string")
        	titstr(0) = "Snow height (USAF/CMC)"      ; SNOWDP
        	titstr(1) = "Fractional Snow Cover (NOAA-AVHRR)"; FSNO
        	titstr(2) = "Snow Water Equivalent (CMC)"       ; H2OSNO
	end if
   end if
   if (p .eq. 8) then
        fileName   = "set3_albedo.txt"
        plot_name  = "albedo"
        titstr = new(5,"string")
        titstr(0) = "Visible BlackSky Albedo"   ; VBSA
        titstr(1) = "NearIR BlackSky Albedo"    ; NBSA
        titstr(2) = "Visible WhiteSky Albedo"   ; VWSA
        titstr(3) = "NearIR WhiteSky Albedo"    ; NWSA
        titstr(4) = "All Sky Albedo"            ; ASA
   end if 

;----------------------------------------------------------
; read in file and parse into variables
;----------------------------------------------------------
  tmp = stringtocharacter(asciiread(inputdir+"/"+fileName,-1,"string"))
  nvars = dimsizes(tmp(:,0))
  print(" p = " + p + "  nvars = " + nvars)
  nplotsPerCol = (nvars+1)/2
  scale_type = new(nvars,"string")
  vars       = new(nvars,"string")
  vcheck1    = new(nvars,"string")
  vcheck2    = new(nvars,"string")
  do i=0,nvars-1
        scale_type(i) = charactertostring(tmp(i,0:12))
        vars(i)       = charactertostring(tmp(i,16:))
  end do
  delete(tmp)

  plot_check = True	; 20dec04 - nanr; added so that plot_check would be defined for underived vars.

; Define common plots resources --------
  plot1 = new(1,graphic)
  if (p .eq. 5)
        plot = new(2,graphic)
  else
        plot = new(nvars,graphic)
  end if

  res                        = True
  res@xyLineColors           = (/"red","blue","black","black"/)
  res@xyDashPatterns         = (/0.,0.,16.,2./)          ; solid, dashed
  res@xyLineThicknesses      = (/2.,2.,2.,2./)
  res@tmXBMinorOn            = False
  res@tiMainOn               = False
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@tiXAxisFontHeightF     = 0.030
  res@tiYAxisFontHeightF     = 0.030
  res@txFontHeightF          = 0.030
  res@tmYLLabelFontHeightF   = 0.030
  res@tmYLFormat             = "0@!;*?5g"
  res@vpKeepAspect           = False
  res@vpWidthF               = 1.2

; creating x-axis labels
  month = ispan(1,months+1,1)
  month!0 = "month"
  res@trXMinF = 1
  res@trXMaxF = months+1
  res@tmXBMode = "Explicit"
  res@tmXBValues = month
  res@tmXBLabels = (/"J","F","M","A","M","J","J","A","S","O","N","D","J"/)
  res@pmLegendDisplayMode    = "Never"
  res@vpHeightF              = 0.4
  res@vpWidthF               = 0.8

  vv = ispan(0,nvars-1,1)
  mm = ispan(0,months-1,1)


    cases  = new(5,"string")
    prefix = new(2,"string")
    if (useCommon1 .eq. "True") then
        name1  = "commonName_1"
    else
        name1  = "caseid_1"
    end if
    if (useCommon2 .eq. "True") then
        name2  = "commonName_2"
    else
        name2  = "caseid_2"
    end if
    name11     = "prefix_1"
    name22     = "prefix_2"
    cases(0)   = getenv(name1)
    cases(1)   = getenv(name2)
    prefix(0)  = getenv(name11)
    prefix(1)  = getenv(name22)
    in1        = addfile(ptmpdir1+"/"+prefix(0)+"MONS_climo.nc","r")
    in2        = addfile(ptmpdir2+"/"+prefix(1)+"MONS_climo.nc","r")
    if(isfilevar(in1,"levsoi")) then
        nlev1  = getfilevardimsizes(in1,"levsoi")
    end if
    if(isfilevar(in1,"levgrnd")) then
        nlev1  = getfilevardimsizes(in1,"levgrnd")
    end if
    fland1     = in1->landfrac
    area1      = in1->area
    time1      = in1->time
    lat1       = in1->lat
    lon1       = in1->lon
    time       = in1->time
    nlat1      = dimsizes(lat1)
    nlon1      = dimsizes(lon1)
    
    ; read case 2
    if(isfilevar(in2,"levsoi")) then
        nlev2  = getfilevardimsizes(in2,"levsoi")
    end if
    if(isfilevar(in2,"levgrnd")) then
        nlev2  = getfilevardimsizes(in2,"levgrnd")
    end if
    fland2     = in2->landfrac
    area2      = in2->area
    time2      = in2->time
    lat2       = in2->lat
    lon2       = in2->lon
    nlat2      = dimsizes(lat2)
    nlon2      = dimsizes(lon2)

    if (lon1(0) .ge. 0) then
         area1  = lonFlip(area1)
         fland1 = lonFlip(fland1)
    end if

    if (lon2(0) .ge. 0) then
         area2  = lonFlip(area2)
         fland2 = lonFlip(fland2)
    end if

    if (isatt(in1,"yrs_averaged")) then
  	yrs_ave1 = in1@yrs_averaged
  	cases(0) = cases(0)+" (yrs "+yrs_ave1+")"
    end if
    if (isatt(in2,"yrs_averaged")) then
  	yrs_ave2 = in2@yrs_averaged
  	cases(1) = cases(1)+" (yrs "+yrs_ave2+")"
    end if


;******************************
; Read observed data
;******************************

   if (p .eq. 0) then                   ; read observations for landf variables
        ptr_wm   = addfile(obsdata+"/0_5_WILLMOTT_ALLMONS_climo.nc","r")   ; temp,precip
        case3    = ptr_wm@case_id
        lat3     = ptr_wm->lat
        time3    = ptr_wm->month
        nlat3    = dimsizes(lat3)
        lon3     = ptr_wm->lon
        nlon3    = dimsizes(lon3)
        ptr_grdc = addfile(obsdata+"/0_5_GRDC_ALLMONS_climo.nc","r")    ; runoff
        case2_r  = ptr_grdc@case_id
        ptr_fd   = addfile(obsdata+"/0_5_FOSTERDAVY_ALLMONS_climo.nc","r")    ; snowdepth
        case2_sd = ptr_fd@case_id

        landmask3 = new((/nvars,nlat3,nlon3/),"double")
        area3     = new((/nvars,nlat3,nlon3/),"double")

        ptr_scf  = addfile(obsdata+"/NOAA_AVHRR_SNOWF_ALLMONS_climo.100318.nc","r")   ; snow cover
        ptr_sd   = addfile(obsdata+"/CMC_SNOWD_ALLMONS_climo.100318.nc","r")          ; snow depth
        ptr_swe  = addfile(obsdata+"/CMC_SWE_ALLMONS_climo.100318.nc","r")            ; swe

        lat4     = ptr_sd->lat
        nlat4    = dimsizes(lat4)
        lon4     = ptr_sd->lon
        nlon4    = dimsizes(lon4)

        landmask4 = new((/nvars,nlat4,nlon4/),"double")
        area4     = new((/nvars,nlat4,nlon4/),"double")

        ; 0.9x1.25 degree = landmask6 - lhf and gpp data is at 0.9x.125 degree

        ptr_lhf  = addfile(obsdata+"/MR_LHF_0.9x1.25_ALLMONS_climo.nc","r")           ; lhf
        ptr_gpp  = addfile(obsdata+"/MR_GPP_0.9x1.25_ALLMONS_climo.nc","r")           ; gpp

        lat6     = ptr_lhf->lat
        nlat6    = dimsizes(lat6)
        lon6     = ptr_lhf->lon
        nlon6    = dimsizes(lon6)

        landmask6 = new((/nvars,nlat6,nlon6/),"float")
        area6     = new((/nvars,nlat6,nlon6/),"float")

        ptr_lai  = addfile(obsdata+"/MODIS_LAI_ALLMONS_climo.nc","r")                 ; lai

        lat7     = ptr_lai->lat
        nlat7    = dimsizes(lat7)
        lon7     = ptr_lai->lon
        nlon7    = dimsizes(lon7)

        landmask7 = new((/nvars,nlat7,nlon7/),"float")
        area7     = new((/nvars,nlat7,nlon7/),"float")

        ; No obs for soil moisture storage

   	landmask3!0   = "var"
   	landmask3&var = vv
   	landmask3!1   = "lat"
   	landmask3&lat = lat3
   	landmask3!2   = "lon"
   	landmask3&lon = lon3
   	area3!0   = "var"
   	area3&var = vv
   	area3!1   = "lat"
   	area3&lat = lat3
   	area3!2   = "lon"
   	area3&lon = lon3

   	landmask4!0   = "var"
   	landmask4&var = vv
   	landmask4!1   = "lat"
   	landmask4!2   = "lon"
   	landmask4&lat = lat4
   	landmask4&lon = lon4
   	area4!0   = "var"
   	area4&var = vv
   	area4!1   = "lat"
   	area4&lat = lat4
   	area4!2   = "lon"
   	area4&lon = lon4

        landmask6!0   = "var"
        landmask6&var = vv
        landmask6!1   = "lat"
        landmask6!2   = "lon"
        landmask6&lat = lat6
        landmask6&lon = lon6
        area6!0   = "var"
        area6&var = vv
        area6!1   = "lat"
        area6&lat = lat6
        area6!2   = "lon"
        area6&lon = lon6

        landmask7!0   = "var"
        landmask7&var = vv
        landmask7!1   = "lat"
        landmask7!2   = "lon"
        landmask7&lat = lat7
        landmask7&lon = lon7
        area7!0   = "var"
        area7&var = vv
        area7!1   = "lat"
        area7&lat = lat7
        area7!2   = "lon"
        area7&lon = lon7
	
   end if
   if (p .eq. 8)		; albedo
        ; 64x128 degree = landmask4 - albedo data is at T42
        ptr_alb  = addfile(obsdata+"/T42_MODIS_ALLMONS_climo.070523.nc","r")    ; albedo

        ; 64x128 degree = landmask4 - albedo data is at T42
        ptr_asa  = addfile(obsdata+"/modisradweighted.nc","r")    ; ASA albedo

        lat5     = ptr_alb->lat
        nlat5    = dimsizes(lat5)
        lon5     = ptr_alb->lon
        nlon5    = dimsizes(lon5)

        landmask5 = new((/nvars,nlat5,nlon5/),"double")
        area5     = new((/nvars,nlat5,nlon5/),"double")
   	landmask5!0   = "var"
   	landmask5&var = vv
   	landmask5!1   = "lat"
   	landmask5!2   = "lon"
   	landmask5&lat = lat5
   	landmask5&lon = lon5
   	area5!0   = "var"
   	area5&var = vv
   	area5!1   = "lat"
   	area5&lat = lat5
   	area5!2   = "lon"
   	area5&lon = lon5
        array5 = new((/nvars, months, nlat5, nlon5/),"double")	;  1 degree
   end if

   sFlag = new((/nvars/),"integer")
   aFlag = new((/nvars/),"integer")
   sFlag = 0
   aFlag = 0

;**************************
; Variable loop ----------- read both cases of each variable into memeory.
;**************************
  array1 = new((/nvars, months, nlat1, nlon1/),"float")		; T42
  array2 = new((/nvars, months, nlat2, nlon2/),"float")		; T42
  array3 = new((/nvars, months, nlat3, nlon3/),"double")	; 05 degree
  array4 = new((/nvars, months, nlat4, nlon4/),"double")	; 1 degree
  array6 = new((/nvars, months, nlat6, nlon6/),"float")	        ; 0.9x1.25 degree
  array7 = new((/nvars, months, nlat7, nlon7/),"float")         ; 0.5 degree

  units     = new(nvars,"string")
  long_name = new(nvars,"string")

; read all variables into memory first and stuff them into two arrays (2 cases)
  pcheck1  = 0
  pcheck2  = 0
  snowFlag = 0
  do i=0,nvars-1 

      print("vars = " + vars(i) )
      if (paleo .ne. "True") then
          if (vars(i) .eq. "SNOWDP") then
                snowFlag = snowFlag + 1
          end if
      end if

; check for variables in case 1
     vcheck1(i) = True
     vcheck2(i) = True
     info = var_init(vars(i))
     if(isfilevar(in1,vars(i)) .and. info@derivedVariable .eq. False)then
          x1 = in1->$vars(i)$
          plot_check = True
     else
          if (info@derivedVariable .eq. True) then
                  x1 = derive_land(  vars(i),in1)
          else
                  print("variable "+ vars(i)+ " is not a defined variable in case1.")
                  pcheck1 = pcheck1 + 1
                  vcheck1(i) = False
          end if
     end if
; check for variables in case 2
     if(isfilevar(in2,vars(i)) .and. info@derivedVariable .eq. False)then

          x2 = in2->$vars(i)$
          plot_check = True
     else
          if (info@derivedVariable .eq. True) then
                  x2 = derive_land(  vars(i),in2)
          else
                  print("variable "+ vars(i)+ " is not a defined variable in case2.")
                  pcheck2 = pcheck2 + 1
                  vcheck2(i) = False
          end if
      end if

; if neither case has the variables, don't plot them.
       if (pcheck1 .eq. nvars .and. pcheck2 .eq. nvars) then
                plot_check = False
       end if

;read in observations (if present)
     obsFlag = 0                                  ; (1 = on; 0 = off)
     if (paleo .ne. "True") then
      if (vars(i) .eq. "TSA" ) then
        x3 = ptr_wm->$vars(i)$
        l3 = ptr_wm->datamask
        a3 = ptr_wm->weight
        cases(2)  = "Willmott-Matsuura(T,P),GRDC(R),USAF/ETAC(S),FLUXNET(LHF,GPP)"
        obsFlag  = 1
	sFlag(i) = 0
      else
      if (vars(i) .eq. "PREC" .and. p .ne. 5) then
        x3 = ptr_wm->PREC
        l3 = ptr_wm->datamask
        a3 = ptr_wm->weight
        cases(2) = "Willmott-Matsuura(T,P),GRDC(R),USAF/ETAC(S),FLUXNET(LHF,GPP)"
        obsFlag  = 1
	sFlag(i) = 0
      else
        if (vars(i) .eq. "TOTRUNOFF" ) then
        x3 = ptr_grdc->RUNOFF
        l3 = ptr_grdc->datamask
        a3 = ptr_grdc->weight
        obsFlag  = 1
        sFlag(i) = 0
      else
      if (vars(i) .eq. "SNOWDP" .and. snowFlag .eq. 1) then
	if (isvar("x3")) then
	  delete(x3)
	end if
        x3 = ptr_fd->$vars(i)$
        l3 = ptr_fd->datamask
        a3 = ptr_fd->weight
        cases(2) = "USAF"
        x3@_FillValue = 1e30
        obsFlag  = 1
        sFlag(i) = 0
      else
      if (vars(i) .eq. "FSNO" ) then
        x4 = ptr_scf->SCF
        x4 = x4 * 0.01            ; convert from percent to 0-1
        l4 = ptr_scf->landmask
        lf = ptr_scf->landfrac
        a4 = ptr_scf->weight
        cases(2) = "NOAA AVHRR (1967-2003)"
        x4@_FillValue = 1e30
        obsFlag  = 1
        sFlag(i) = 1
      else
      if (vars(i) .eq. "H2OSNO" ) then
        x4 = ptr_swe->SWE
        l4 = ptr_swe->landmask
        lf = ptr_swe->landfrac
        a4 = ptr_swe->weight
        cases(3) = "CMC (1980-1996)"
        x4@_FillValue = 1e30
        obsFlag  = 1
        sFlag(i) = 1
      else
      if (vars(i) .eq. "SNOWDP" .and. snowFlag .eq. 2) then
	if (isvar("x4")) then
	  delete(x4)
	end if
        x4 = ptr_sd->SNOWD
        l4 = ptr_sd->landmask
        lf = ptr_sd->landfrac
        a4 = ptr_sd->weight
        cases(3) = "CMC (1980-1996)"
        x4@_FillValue = 1e30
        obsFlag  = 1
        sFlag(i) = 1
      else
      if (vars(i) .eq. "VBSA") then
        if (isvar("x5")) then
          delete(x5)
        end if
        x5 = ptr_alb->VBSA
        cases(3) = "MODIS (2001-2003)"
        l5 = ptr_alb->LANDFRAC
        a5 = ptr_alb->weight
        x5@_FillValue = 1e30
        obsFlag  = 1;
        sFlag(i) = 0;
        aFlag(i) = 1;
      else
      if (vars(i) .eq. "NBSA") then
        if (isvar("x5")) then
          delete(x5)
        end if
        x5 = ptr_alb->NBSA
        cases(3) = "MODIS (2001-2003)"
        l5 = ptr_alb->LANDFRAC
        a5 = ptr_alb->weight
        x5@_FillValue = 1e30
        obsFlag  = 1;
        sFlag(i) = 0;
        aFlag(i) = 1;
      else
      if (vars(i) .eq. "VWSA") then
        if (isvar("x5")) then
          delete(x5)
        end if
        x5 = ptr_alb->VWSA
        cases(3) = "MODIS (2001-2003)"
        l5 = ptr_alb->LANDFRAC
        a5 = ptr_alb->weight
        x5@_FillValue = 1e30
        obsFlag  = 1;
        sFlag(i) = 0;
        aFlag(i) = 1;
      else
      if (vars(i) .eq. "NWSA") then
        if (isvar("x5")) then
          delete(x5)
        end if
        x5 = ptr_alb->NWSA
        cases(3) = "MODIS (2001-2003)"
        l5 = ptr_alb->LANDFRAC
        a5 = ptr_alb->weight
        x5@_FillValue = 1e30
        obsFlag  = 1;
        sFlag(i) = 0;
        aFlag(i) = 1;
      else
      if (vars(i) .eq. "ASA") then	; read ASA from different modis file (ptr_asa)
        if (isvar("x5")) then
          delete(x5)
        end if
        x5 = ptr_asa->BRDALB		; broadband albedo
        cases(3) = "MODIS (2001-2003)"
        l5 = ptr_alb->LANDFRAC		; use LANDFRAC and weight from ptr_alb file.
        a5 = ptr_alb->weight
        x5@_FillValue = 1e30
        obsFlag  = 1;
        sFlag(i) = 0;
        aFlag(i) = 1;
      else
      if (vars(i) .eq. "LHEAT") then
        x6 = ptr_lhf->LHF
        l6 = ptr_lhf->datamask
        a6 = ptr_lhf->area
        obsFlag = 1
        sFlag(i) = 0
      else
      if ((vars(i) .eq. "FPSN" .and. cn .eq. 0) .or. vars(i) .eq. "GPP") then
        x6 = ptr_gpp->GPP
        l6 = ptr_gpp->datamask
        a6 = ptr_gpp->area
        obsFlag = 1
        sFlag(i) = 0
      else
      if (vars(i) .eq. "TLAI") then
        x7 = ptr_lai->TLAI         
        l7 = ptr_lai->landmask    
        a7 = ptr_lai->area        
        obsFlag = 1               
        sFlag(i) = 0              
      else              ; This will cover TOTSOILLIQICE (no obs)
        obsFlag  = 0
        sFlag(i) = 0
        aFlag(i) = 0
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
     end if	; paleo

     if (paleo .eq. "True") then
		obsFlag = 0
     end if

       if (vcheck1(i) .eq. True) then
         ; catch NaNs
         x1 = catchNaN(x1)
         x1 = scale_var(x1,scale_type(i),info)

         if (obsFlag .eq. 1) then                           ; process variables with observed data
	   if (isvar("x3") )
           	x3 = catchNaN(x3)
           	x3!0    = "mons"
           	x3&mons = mm
           	x3!1    = "lat"
           	x3&lat  = lat3
           	x3!2    = "lon"
           	x3&lon  = lon3
                a3!0    = "lat"
                a3!1    = "lon"
                l3!0    = "lat"
                l3!1    = "lon"
                a3&lat  = lat3
                a3&lon  = lon3
                l3&lat  = lat3
                l3&lon  = lon3
           	if (min(x3&lon) .ge. 0) then
               	     x3 = lonFlip(x3)
           	end if
                if (min(a3&lon) .ge. 0) then
                     a3 = lonFlip(a3)
                end if
                if (min(l3&lon) .ge. 0) then
                     l3 = lonFlip(l3)
                end if
                array3(i,:,:,:)  = x3           ; Wrapper fcn that copies coord Vars
                landmask3(i,:,:) = l3
                area3(i,:,:)     = a3
                delete(l3)
                delete(a3)
                delete(x3)
           end if

	   if (isvar("x4") .and. sFlag(i) .eq. 1) then
           	x4 = catchNaN(x4)
           	x4!0    = "mons"
           	x4&mons = mm
           	x4!1    = "lat"
           	x4&lat  = lat4
           	x4!2    = "lon"
           	x4&lon  = lon4
                a4!0    = "lat"
                a4!1    = "lon"
                l4!0    = "lat"
                l4!1    = "lon"
                lf!0    = "lat"
                lf!1    = "lon"
                a4&lat  = lat4
                a4&lon  = lon4
                l4&lat  = lat4
                l4&lon  = lon4
                lf&lat  = lat4
                lf&lon  = lon4
           	if (min(x4&lon) .ge. 0) then
                     x4 = lonFlip(x4)
           	end if
                if (min(a4&lon) .ge. 0) then
                     a4 = lonFlip(a4)
                end if
                if (min(l4&lon) .ge. 0) then
                     l4 = lonFlip(l4)
                end if
                if (min(lf&lon) .ge. 0) then
                     lf = lonFlip(lf)
                end if

		; mask out fractional grid cells.
		l41d = ndtooned(l4)
		lf1d = ndtooned(lf)
		l41d = mask(l41d, lf1d .ne. 1, False)
		l4 = onedtond(l41d,(/nlat4,nlon4/))

                array4(i,:,:,:)  = x4           ; Wrapper fcn that copies coord Vars
                landmask4(i,:,:) = l4
                area4(i,:,:)     = a4
                delete(l4)
                delete(a4)
                delete(x4)
                delete(lf)
	   end if

           if (isvar("x5") .and. aFlag(i) .eq. 1) then
                x5 = catchNaN(x5)
                x5!0    = "mons"
                x5&mons = mm
                x5!1    = "lat"
                x5&lat  = lat5
                x5!2    = "lon"
                x5&lon  = lon5
                a5!0    = "lat"
                a5!1    = "lon"
                l5!0    = "lat"
                l5!1    = "lon"
                a5&lat  = lat5
                a5&lon  = lon5
                l5&lat  = lat5
                l5&lon  = lon5

                if (min(x5&lon) .ge. 0) then
                     x5 = lonFlip(x5)
                end if
                if (min(a5&lon) .ge. 0) then
                     a5 = lonFlip(a5)
                end if
                if (min(l5&lon) .ge. 0) then
                     l5 = lonFlip(l5)
                end if

                array5(i,:,:,:)  = x5           ; Wrapper fcn that copies coord Vars
                landmask5(i,:,:) = l5
                area5(i,:,:)     = a5
                delete(l5)
                delete(a5)
                delete(x5)
           end if

           if (isvar("x6")) then
                x6 = catchNaN(x6)
                x6!0    = "mons"
                x6&mons = mm
                x6!1    = "lat"
                x6&lat  = lat6
                x6!2    = "lon"
                x6&lon  = lon6
                a6!0    = "lat"
                a6!1    = "lon"
                l6!0    = "lat"
                l6!1    = "lon"
                a6&lat  = lat6
                a6&lon  = lon6
                l6&lat  = lat6
                l6&lon  = lon6

                if (min(x6&lon) .ge. 0) then
                     x6 = lonFlip(x6)
                end if
                if (min(a6&lon) .ge. 0) then
                     a6 = lonFlip(a6)
                end if
                if (min(l6&lon) .ge. 0) then
                     l6 = lonFlip(l6)
                end if

                array6(i,:,:,:)  = x6           ; Wrapper fcn that copies coord Vars
                landmask6(i,:,:) = l6
                area6(i,:,:)     = a6
                delete(l6)
                delete(a6)
                delete(x6)
           end if

           if (isvar("x7")) then
                x7 = catchNaN(x7)
                x7!0    = "mons"
                x7&mons = mm
                x7!1    = "lat"
                x7&lat  = lat7
                x7!2    = "lon"
                x7&lon  = lon7
                a7!0    = "lat"
                a7!1    = "lon"
                l7!0    = "lat"
                l7!1    = "lon"
                a7&lat  = lat7
                a7&lon  = lon7
                l7&lat  = lat7
                l7&lon  = lon7

                if (min(x7&lon) .ge. 0) then
                     x7 = lonFlip(x7)
                end if
                if (min(a7&lon) .ge. 0) then
                     a7 = lonFlip(a7)
                end if
                if (min(l7&lon) .ge. 0) then
                     l7 = lonFlip(l7)
                end if

                array7(i,:,:,:)  = x7           ; Wrapper fcn that copies coord Vars
                landmask7(i,:,:) = l7
                area7(i,:,:)     = a7
                delete(l7)
                delete(a7)
                delete(x7)
           end if

         end if

         if (min(x1&lon) .ge. 0) then
            x1  = lonFlip(x1)
         end if
         array1(i,:,:,:) = x1
         units(i)        = x1@units
         long_name(i)    = x1@long_name
         delete(x1)
       end if

       if (vcheck2(i) .eq. True) then
         x2 = catchNaN(x2)
         x2 = scale_var(x2,scale_type(i),info)
         if (min(x2&lon) .ge. 0) then
            x2  = lonFlip(x2)
         end if
         array2(i,:,:,:) = x2
         delete(x2)
       end if
       if (paleo .ne. "True") then
          if (snowFlag .eq. 1) then             ; run SNOWDP twice to see both obs datasets
                i = i-1
          end if
       end if
   end do 	; end variable loop

;**********************************
; now plot vars by region
;**********************************
if(plot_check.eq.True)then

 if (paleo .eq. "True") then
	startRegion = nreg-3		; N. + S. hemisphere land + global
 else
	startRegion = 0
 end if

 do region=startRegion,nreg-1

; open ps file for plotting
    wks = gsn_open_wks(plot_type,wkdir + "set3_" + plot_name + "_" + ps_id(region))

    pres                     = True                   ; panel only resources
; create common legend 
    pres@txString            = ptitstr(region)+boxstr(region)  ; common title

; each regional plot contains all variables, so loop over vars
; moistEnergyFlx plot draws three variabls on one plot.  Other plots have only 1 variable per plot.
   if (p .eq. 5) then
        data1 = new((/nvars,nmons/),"double")
        data2 = new((/nvars,nmons/),"double")
        labels = new(3,"string")
        do i = 0,nvars-1
  
      ; process model results
              compare = "model"
	      if (vcheck1(i) .eq. True) then
                 x1 = array1(i,:,:,:)
                 if (vars(i) .eq. "RNET") then
                        x1 = (x1 / 2.501e6 ) * secondsPerDay
                 end if
                 var_plot1 = regional_values(x1,region,area1,fland1,scale_type(i),\
                   	regions_file,time1, nmons,compare)
                 data1(i,:) = var_plot1
                 delete(x1)
              end if
	      if (vcheck2(i) .eq. True) then
                 x2 = array2(i,:,:,:)
                 if (vars(i) .eq. "RNET") then
                        x2 = (x2 / 2.501e6 ) * secondsPerDay
                 end if
                 var_plot2 = regional_values(x2,region,area2,fland2,scale_type(i),\
                 	regions_file,time2, nmons,compare)
                 data2(i,:) = var_plot2
                 delete(x2)
              end if
  
              res@tiYAxisString          = "mm/d"
              labels(i)                  = titstr(i)
  
	      if (vcheck1(i) .eq. True) then
              	delete(var_plot1)
	      end if
	      if (vcheck2(i) .eq. True) then
              	delete(var_plot2)
	      end if
        end do
	res@gsnLeftString    	 = cases(0)
        plot(0) = gsn_csm_xy(wks,month,data1,res)
	res@gsnLeftString    	 = cases(1)
        plot(1) = gsn_csm_xy(wks,month,data2,res)
        delete(data1)
        delete(data2)
	delete(res@gsnLeftString)
  else
     do i = 0,nvars-1
	   compare = "model"

; snowdp plot draws 2 obs + 1 variable on snowdp plot.  Other plots have only 1 variable per plot.
           if (vars(i) .eq. "SNOWDP") then
		if (paleo .eq. "True") then				; no obs
                   data  = new((/2,nmons/),"double")
		else
                   data  = new((/4,nmons/),"double")
		end if
                res@xyDashPatterns         = (/0.,0.,16.,16./)          ; solid, dashed
                res@xyLineColors         = (/"red","blue","blue","black"/)

                ; process model 1 results
                    compare = "model"
                    x1 = array1(i,:,:,:)
                    var_plot1 = regional_values(x1,region,area1,fland1,scale_type(i),\
                         regions_file,time1,nmons,compare)
                    data(0,:) = var_plot1
                    delete(var_plot1)
                    delete(x1)

                ; process model 2 results
                    compare = "model"
                    x2 = array2(i,:,:,:)
                    var_plot2 = regional_values(x2,region,area2,fland2,scale_type(i),\
                              regions_file,time1,nmons,compare)
                    data(1,:) = var_plot2
                    delete(var_plot2)
                    delete(x2)

		    if (paleo .eq. "False") then		
                ; process 1st set of obs (FOSTERDAVY/USAF - dashed line)
                    	compare = "obs"
                    	x3 = array3(i,:,:,:)
                    	var_plot3 = regional_values(x3,region,area3(i,:,:),landmask3(i,:,:),scale_type(i),\
                              regions_file,time1,nmons,compare)
                    	data(2,:) = var_plot3
                    	delete(var_plot3)
                    	delete(x3)

                 ; process 2nd set of obs (CMC) - (dashed line)
                    	x4 = array4(i,:,:,:)
                    	var_plot4 = regional_values(x4,region,area4(i,:,:),landmask4(i,:,:),scale_type(i),\
                              regions_file,time1,nmons,compare)
                    	data(3,:) = var_plot4
                    	delete(var_plot4)
                    	delete(x4)
		     end if			; paleo
      
                    res@tiYAxisString   = "mm/d"
                    res@gsnCenterString = titstr(i)
        
                    plot(i) = gsn_csm_xy(wks,month,data,res) 
                    delete(data)
            else
                    if (vars(i) .eq. "FSNO") then
                        delete(res@xyLineColors)
                        res@xyDashPatterns         = (/0.,0.,16.,16./)          ; solid, dashed
  		        res@xyLineThicknesses      = (/2.,2.,2.,2./)
                        res@xyLineColors         = (/"red","blue","black","black"/)
                    end if
                    if (vars(i) .eq. "H2OSNO") then
                        delete(res@xyDashPatterns)
                        delete(res@xyLineColors)
  		        res@xyLineThicknesses      = (/2.,2.,2.,2./)
                        res@xyDashPatterns         = (/0.,0.,16.,16./)          ; solid, dashed
                        res@xyLineColors         = (/"red","blue","black","black"/)
                    end if
                    if (aFlag(i) .eq. 1) then
                        delete(res@xyDashPatterns)
                        delete(res@xyLineColors)
                        delete(res@xyLineThicknesses)
  		        res@xyLineThicknesses      = (/2.,2.,2./)
                        res@xyDashPatterns         = (/0.,0.,16./)          ; solid, dashed
                        res@xyLineColors         = (/"red","blue","black"/)
                    end if
   
                    ; process model 
	   	    if (vcheck1(i) .eq. True)
                    	x1 = array1(i,:,:,:)
                    	compare = "model"
                    	if (vars(i) .eq. "ALBEDO" .or. aFlag(i) .eq. 1) then
                      		var_plot1 = regional_albedo(x1,region,area1,fland1,scale_type(i),\
                              		regions_file,nmons,compare)
                    	else
                      		var_plot1 = regional_values(x1,region,area1,fland1,scale_type(i),\
                              		regions_file,time1,nmons,compare)
                    	end if
                    	delete(x1)
	   	     end if
	   	     if (vcheck2(i) .eq. True)
             	     	x2 = array2(i,:,:,:)
             	     	if (vars(i) .eq. "ALBEDO" .or. aFlag(i) .eq. 1) then
                	         var_plot2 = regional_albedo(x2,region,area2,fland2,scale_type(i),\
                        		regions_file,nmons,compare)
                        else
                                 var_plot2 = regional_values(x2,region,area2,fland2,scale_type(i),\
                        		regions_file,time2,nmons,compare)
                        end if
                    	delete(x2)
	              end if


		    ; process variables with observed data
           	    if (obsFlag .eq. 1) then                           
                        data  = new((/3,nmons/),"double")
	        	compare = "obs"
                        if (sFlag(i) .eq. 1) then            ; processing snow vars at 1x1 degree
                                x4 = array4(i,:,:,:)
                                var_plot3 = regional_values(x4,region,area4(i,:,:),landmask4(i,:,:),scale_type(i),\
                                                            regions_file,time1,nmons,compare)
                                delete(x4)
                        else
                        if ( aFlag(i) .eq. 1) then            ; processing albedo vars at 1x1 degree
                           x5 = array5(i,:,:,:)
                           var_plot3 = regional_values(x5,region,area5(i,:,:),landmask5(i,:,:),scale_type(i),\
                           regions_file,time1,nmons,compare)
                           delete(x5)
			else
                           x3 = array3(i,:,:,:)
                           var_plot3 = regional_values(x3,region,area3(i,:,:),landmask3(i,:,:),scale_type(i),\
                           regions_file,time1,nmons,compare)
                           delete(x3)
                           if (vars(i) .eq. "LHEAT") then
                              x6 = array6(i,:,:,:)
                              var_plot3 = regional_values(x6,region,area6(i,:,:),landmask6(i,:,:),scale_type(i),\
                              regions_file,time1,nmons,compare)
                              delete(x6)
                           else
                           if ((vars(i) .eq. "FPSN" .and. cn .eq. 0) .or. vars(i) .eq. "GPP") then
                              x6 = array6(i,:,:,:)
                              var_plot3 = regional_values(x6,region,area6(i,:,:),landmask6(i,:,:),scale_type(i),\
                              regions_file,time1,nmons,compare)
                              delete(x6)
                           end if
                           if (vars(i) .eq. "TLAI") then 
                              x7 = array7(i,:,:,:)
                              var_plot3 = regional_values(x7,region,area7(i,:,:),landmask7(i,:,:),scale_type(i),\ 
                              regions_file,time1,nmons,compare)
                              delete(x7)
                           end if
                        end if
                        end if
                        end if
                        data(2,:) = var_plot3
	        	delete(var_plot3)
	   	     else
                        data  = new((/2,nmons/),"double")
	   	     end if

		     if (isvar("var_plot1")) then
             	     	data(0,:) = var_plot1
                        delete(var_plot1)
		     end if
		     if (isvar("var_plot2")) then
             	     	data(1,:) = var_plot2
                     	delete(var_plot2)
		     end if

           	     res@tiYAxisString   = units(i)
           	     res@gsnCenterString = titstr(i)

    	   	     plot(i) = gsn_csm_xy(wks,month,data,res) 
	   	     delete(data)
   	   	     delete(res@gsnCenterString)
         end if	; end SNOWDP loop
    end do	; end variable loop
  end if	; end plot 5 fork 

; and plot it already using gsn_panel to print all plots onto it from plot array


;*************************************************
;  gsnpanel takes this plot array and massages it and puts it onto page for us.
;*************************************************
      pres@gsnFrame            = False                  ; don't advance yet so add legend
      pres@gsnMaximize         = True                   ; make as large as possible
      pres@gsnPaperOrientation = "Portrait"
      pres@gsnPanelRowSpec     = True
      pres@gsnPanelBottom      = 0.15                   ; save space for legend

      if (isdefined("lgres"))
      	delete(lgres)
      end if
      lgres                    = True                   ; allow legend resources
      lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
      lgres@lgPerimOn          = False
      lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
      lgres@lgLabelFontHeightF = 0.015                   ; increase font height
      lgres@lgLineLabelStrings = (/"","",""/)           ; no labels in lines
      lgres@lgAutoManage       = False                  ; must have to adjust fonts
      lgres@vpWidthF           = 0.45
      lgres@vpHeightF          = 0.15
      if (p .eq. 0) then				; landf	(7 vars)
           cases(2)  = "Willmott-Matsuura(T,P),GRDC(R),USAF/ETAC(S),FLUXNET(LHF,GPP),MODIS(LAI)"
           cases(3)  = "CMC 1980-1996"
           pres@gsnPanelCenter      = False
 	   pres@gsnPanelYWhiteSpacePercent = 4
 	   pres@gsnPanelXWhiteSpacePercent = 4
           gsn_panel(wks,plot,(/2,2,2,2/),pres)             ; draw panel plot
           lgres@vpWidthF           = 0.80
           lgres@lgLineLabelsOn     = False
           lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
           lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
           gsn_legend_ndc(wks,4,cases(0:3),0.15,0.15,lgres)  ; draw common legend	MAY HAVE TO ADJUST Y
	   frame(wks)
      end if
      if (p .eq. 1) then				; radf	(7 vars)
            pres@gsnPanelCenter      = False
            gsn_panel(wks,plot,(/2,2,2,1/),pres)        
            ; gsn_legend_ndc(wks,2,cases,0.35,0.10,lgres) ; draw common legend	MAY HAVE TO ADJUST Y
            legend = create "Legend" legendClass wks
              "vpXF"                     : 0.51
              "vpYF"                     : 0.33
              "vpWidthF"                 : 0.25
              "vpHeightF"                : 0.125
              "lgPerimOn"                : False
              "lgItemCount"              : 2
              "lgLabelsOn"               : True
              "lgLineLabelsOn"           : False
              "lgLabelStrings"           : cases(0:1)
              "lgDashIndexes"            : (/0,0/)
              "lgLineColors"             : (/"red","blue"/)
              "lgMonoLineLabelFontColor" : True
              "lgAutoManage"             : False
              "lgLabelFontHeightF"       : 0.0125
              "lgLabelPosition"          : "Center"
              "lgLabelAlignment"         : "AboveItems"
            end create
            draw(legend)
	    frame(wks)
	    delete(legend)
      end if
      if (p .eq. 2) then				; turbf (9)
            pres@gsnPanelCenter      = False
            gsn_panel(wks,plot,(/2,2,2,2,2/),pres)     
            legend = create "Legend" legendClass wks
              "vpXF"                     : 0.30
              "vpYF"                     : 0.16
              "vpWidthF"                 : 0.20
              "vpHeightF"                : 0.1
              "lgPerimOn"                : False
              "lgItemCount"              : 2
              "lgLabelsOn"               : True
              "lgLineLabelsOn"           : False
              "lgLabelStrings"           : cases(0:1)
              "lgDashIndexes"            : (/0,0/)
              "lgLineColors"             : (/"red","blue"/)
              "lgMonoLineLabelFontColor" : True
              "lgAutoManage"             : False
              "lgLabelFontHeightF"       : 0.015
              "lgLabelPosition"          : "Center"
              "lgLabelAlignment"         : "AboveItems"
            end create
            draw(legend)
	    frame(wks)
	    delete(legend)
      end if
      if (p .eq. 3 ) then                  ; cn (10 vars each)
            pres@gsnPanelCenter      = False
            if (clamp .eq. 1 .or. casa .eq. 1)  then
                 gsn_panel(wks,plot,(/2,2,2/),pres)          ; draw panel plot  
                 gsn_legend_ndc(wks,2,cases(0:1),0.38,0.13,lgres) ; draw common legend    MAY HAVE TO ADJUST Y
		 frame(wks)
            else
                 gsn_panel(wks,plot,(/2,2,2,2,2/),pres)        ; draw panel plot
                ;gsn_legend_ndc(wks,2,cases(0:1),0.35,0.13,lgres) ; draw common legend    MAY HAVE TO ADJUST Y
                 legend = create "Legend" legendClass wks
                   "vpXF"                     : 0.30
                   "vpYF"                     : 0.16
                   "vpWidthF"                 : 0.20
                   "vpHeightF"                : 0.1
                   "lgPerimOn"                : False
                   "lgItemCount"              : 2
                   "lgLabelsOn"               : True
                   "lgLineLabelsOn"           : False
                   "lgLabelStrings"           : cases(0:1)
                   "lgDashIndexes"            : (/0,0/)
                   "lgLineColors"             : (/"red","blue"/)
                   "lgMonoLineLabelFontColor" : True
                   "lgAutoManage"             : False
                   "lgLabelFontHeightF"       : 0.015
                   "lgLabelPosition"          : "Center"
                   "lgLabelAlignment"         : "AboveItems"
                 end create
                 draw(legend)
		 frame(wks)
	         delete(legend)
            end if
      end if
      if (p .eq. 4) then                  ; cn and fire (6 vars each)
            pres@gsnPanelCenter      = False
            gsn_panel(wks,plot,(/2,2,2/),pres)        ; draw panel plot
            gsn_legend_ndc(wks,2,cases(0:1),0.35,0.17,lgres) ; draw common legend    MAY HAVE TO ADJUST Y
	    frame(wks)
      end if
      if (p .eq. 5) then
      	    pres@gsnPanelCenter      = True
            gsn_panel(wks,plot,(/1,2/),pres)             ; draw panel plot
            lgres@lgLabelFontHeightF = 0.015              ; increase font height
            gsn_legend_ndc(wks,3,labels,0.275,0.22,lgres) ; draw common legend	MAY HAVE TO ADJUST Y
	    frame(wks)
	    delete(labels)
      end if	
      if (p .eq. 6) then
      	    pres@gsnPanelCenter      = True
            gsn_panel(wks,plot,(/2,2,1/),pres)  ; draw panel plot
            lgres@lgLabelFontHeightF = 0.028
            gsn_legend_ndc(wks,2,cases(0:1),0.275,0.17,lgres)  ; draw common legend	MAY HAVE TO ADJUST Y
	    frame(wks)
            lgres@lgLabelFontHeightF = 0.015
      end if	
      if (p .eq. 7) then                                                            ; snow
            cases(2)  = "USAF"
            cases(3)  = "CMC/NOAA-AVHRR"
            pres@gsnPanelCenter      = True
 	    pres@gsnPanelYWhiteSpacePercent = 4
 	    pres@gsnPanelXWhiteSpacePercent = 4
            gsn_panel(wks,plot,(/2,2/),pres)             ; draw panel plot

	    delete(lgres)
      	    lgres                    = True                   ; allow legend resources
      	    lgres@lgPerimOn          = False
      	    lgres@lgLabelFontHeightF = 0.015                   ; increase font height
      	    lgres@lgLineLabelStrings = (/"","",""/)           ; no labels in lines
      	    lgres@lgAutoManage       = False                  ; must have to adjust fonts
      	    lgres@vpWidthF           = 0.55
      	    lgres@vpHeightF          = 0.15
            lgres@lgLineColors       = (/"red","blue","blue","black"/)
            lgres@lgLineThicknesses  = (/2.,2.,2,1.5/)
      	    lgres@lgDashIndexes      = (/0.,0.,16.,16./)          ; solid, dashed
            lgres@lgLineLabelsOn     = False
            gsn_legend_ndc(wks,4,cases(0:3),0.225,0.23,lgres)  ; draw common legend	MAY HAVE TO ADJUST Y
            gsn_panel(wks,plot,(/2,2/),pres)             ; draw panel plot
	    frame(wks)
      end if
      if (p .eq. 8) then                                                            ; snow
            cases(2)                 = "MODIS 2001-2003"
            delete(lgres)
            lgres                    = True                   ; allow legend resources
            lgres@lgPerimOn          = False
            lgres@lgLabelFontHeightF = 0.015                   ; increase font height
            lgres@lgLineLabelStrings = (/"","",""/)           ; no labels in lines
            lgres@lgAutoManage       = False                  ; must have to adjust fonts
            lgres@vpWidthF           = 0.55
            lgres@vpHeightF          = 0.15
            lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
            lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
            lgres@lgLineLabelsOn     = False
            gsn_legend_ndc(wks,3,cases(0:2),0.225,0.15,lgres)  ; draw common legend      MAY HAVE TO ADJUST Y
            gsn_panel(wks,plot,(/2,2,1/),pres)             ; draw panel plot
	    frame(wks)
      end if

;;      frame(wks)

   end do	;  end of region loop
end if	        ;  end of plot_check loop


   delete(vars)
   delete(vcheck1)
   delete(vcheck2)
   delete(array1)
   delete(array2)
   delete(array3)
   delete(array4)
   if (isvar("array5")) then
   	delete(array5)
   end if
   if (isvar("array6")) then
   	delete(array6)
   end if
   if (isvar("array7")) then
        delete(array7)
   end if
   delete(scale_type)
   delete(plot)
   delete(units)
   delete(long_name)
   delete(vv)
   delete(cases)
   delete(pres@gsnPanelRowSpec)
   delete(titstr)
   delete(res@xyLineColors)
   delete(res@xyDashPatterns)
   delete(sFlag)
   delete(aFlag)

  end do   ; end p plot loop

  delete(landmask3)
  delete(landmask4)
  delete(landmask5)
  delete(landmask6)
  delete(landmask7)
  delete(area2)
  delete(area3)
  delete(area4)
  delete(area5)
  delete(area6)
  delete(area7)

;----------------------------------------------
; Create global maps delineating regions (on model grid)
;----------------------------------------------

;----------------------------------------------
; common plot resources
;----------------------------------------------
 delete(res)
 res = True
 res@mpProjection = "Robinson"
 res@mpPerimOn    = False
 res@mpGridLineColor = "transparent"       
 res@cnFillOn = True
 res@cnLineLabelsOn = False
 res@lbLabelBarOn = False
 res@cnLinesOn =  False
 res@mpGridLonSpacingF   = 180.0            ; Set lon grid spacing
 res@mpGridLatSpacingF    = 90.0           ; Set lat grid spacing
 res@mpFillOn             =  False
 res@mpOutlineOn          =  True
 res@mpGridAndLimbOn      =  True
 res@mpGridLineDashPattern =  2            ; Set grid line dash pattern (dash)
 res@mpGridLineThicknessF   = 0.5          ; Set grid line thickness
 sstr=(/" "/)
 res@gsnMaximize = True
 res@cnLevelSelectionMode =  "ExplicitLevels"
 wks = gsn_open_wks(plot_type,wkdir+"set3_reg_all")
 cmap = (/"(/1.00, 1.00, 1.00/)", "(/0.00, 0.00, 0.00/)", \
          "(/1.00, 1.00, 1.00/)", "Blue" /)
 gsn_define_colormap(wks, cmap )
 res@gsnLeftString = " "
 res@gsnRightString = " "
 res@cnLevels = (/0./)

 flag1 = area1
 flag1 = -0.1

 if (paleo .eq. "True") then
	startRegion = nreg-3		; N. + S. hemisphere land + global
 else
	startRegion = 0
 end if

 if (paleo .eq. "True") then
   landfrac = in1->landfrac
   oro = new((/nlat1,nlon1/),integer)
   oro = 1
   oro@_FillValue = 0
   oro = where(landfrac .gt. 0.0, 1,0)
;  fname = wkdir+prefix(0)
;  fname = wkdir+"basename"
   fname = wkdir+getenv(name1)
   paleo_outline(oro,lat1,lon1,1, fname)
   res@mpDataBaseVersion = "Ncarg4_1"
   res@mpDataSetName     =  fname
   do ar = startRegion, nreg-1  ; don't include northern and southern hemisphere and global
     flag1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = 0.1*fland1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) - 1.e-36
   end do
 else
   do ar = 0, nreg-4  ; don't include northern and southern hemisphere and global
     flag1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = 0.1*fland1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) - 1.e-36
   end do
 end if

 res@gsnCenterString = "Model Data Regions - All"
 plot = gsn_csm_contour_map(wks, flag1, res)

 do ar = startRegion, nreg-1
;----------------------------------------------
; Open file for plots 
;----------------------------------------------
   wks = gsn_open_wks(plot_type,wkdir+"set3_reg_"+ps_id(ar))
   cmap = (/"(/1.00, 1.00, 1.00/)", "(/0.00, 0.00, 0.00/)", \
            "(/1.00, 1.00, 1.00/)", "Blue" /)
   gsn_define_colormap(wks, cmap )
   flag1 = -0.1
   flag1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = 0.1*fland1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) - 1.e-36
   res@gsnCenterString = "Model Data Regions - " + ptitstr(ar) + boxstr(ar)
   plot = gsn_csm_contour_map(wks, flag1, res)
 end do

 print ("=========================================")
 print ("Finish Time: "+systemfunc("date") )
 print ("=========================================")   

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set3_error_file"                   
  system("/bin/rm -f " + filo)  

end
