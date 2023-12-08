load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/lnd_func.ncl"
;************************************************
; NOTE:  Adapted from plot_tpr.ncl, plot_eb.ncl, 
;         plot_fire.ncl (KOleson code).
; Revision Author:  Nan Rosenbloom Spring 2005
;************************************************

begin
 print ("=========================================")
 print ("Starting:  set_3.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
  inputdir  = getenv("INPUT_FILES")
  resdir    = getenv("DIAG_RESOURCES")
  diag_home = getenv("DIAG_HOME")
  obsdata   = getenv("OBS_DATA")
  plot_type = getenv("PLOTTYPE")
  cn        = getenv("CN")
  clamp     = getenv("CLAMP")
  casa      = getenv("CASA")
  hydroFlag = getenv("HYDRO")
      paleo = getenv("paleo")
  land_mask = getenv("land_mask1")
  flandmask = stringtofloat(land_mask)
 useCommon1 = getenv("UseCommonName_1")

;*************************************************
; get case names and create filenames to read in
;*************************************************
  wkdir   = getenv("WKDIR")
  ptmpdir = getenv("PTMPDIR_1")
;;  fyr     = stringtointeger(getenv("clim_first_yr_1"))
  fyr     = getenv("clim_first_yr_1")

;***********************************************
; import regional information
;***********************************************

 secondsPerDay = 86400.
 months = 12   ; number of months
 regions_file = addfile(resdir+"/region_definitions.nc","r")
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
                titstr(5) = "Net Ecocystem Production"
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
        if (paleo .eq. "True") then                                                ; paleo run, no obs
                titstr = new(4,"string")
                titstr(0) = "Snow height"                                ; SNOWDP
                titstr(1) = "Fractional Snow Cover"                        ; FSNO
                titstr(2) = "Snow Water Equivalent"                       ; H2OSNO
        else                                                                ; obs
                titstr = new(4,"string")
                titstr(0) = "Snow height (USAF/CMC)"        ; SNOWDP
                titstr(1) = "Fractional Snow Cover (NOAA-AVHRR)"; FSNO
                titstr(2) = "Snow Water Equivalent (CMC)"       ; H2OSNO
        end if
  end if 
  if (p .eq. 8) then
        fileName   = "set3_albedo.txt"
        plot_name  = "albedo"
        titstr = new(5,"string")
        titstr(0) = "Visible BlackSky Albedo"        ; VBSA
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
  nplotsPerCol = (nvars+1)/2
  scale_type = new(nvars,"string")
  vars       = new(nvars,"string")
  vcheck1    = new(nvars,"string")
  do i=0,nvars-1
        scale_type(i) = charactertostring(tmp(i,0:12))
        vars(i)       = charactertostring(tmp(i,16:))
  end do
  delete(tmp)

  plot_check = True        ; 20dec04 - nanr; added so that plot_check would be defined for underived vars.


; Define common plots resources --------
  if (p .eq. 5)
          plot = new(1,graphic)
  else
          plot = new(nvars,graphic)
  end if

  res                        = True
  res@xyLineThicknesses      = (/2.,2.,2./)
  res@xyDashPatterns         = (/0.,16.,16./)          ; solid, dashed
  res@xyLineColors           = (/"red","blue","black"/)
  res@tmXBMinorOn            = False
  res@tiMainOn               = False
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@tiXAxisFontHeightF     = 0.030
  res@tiYAxisFontHeightF     = 0.030
  res@txFontHeightF          = 0.030
  ;res@tmXBLabelFontHeightF   = 0.030
  res@tmYLLabelFontHeightF   = 0.030
  res@tmYLFormat             = "0@!;*?5g"


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

;******************************
; Read model data 
;******************************
    cases = new(4,"string")
    if (useCommon1 .eq. "True") then
        name1  = "commonName_1"
    else
        name1  = "caseid_1"
    end if
    cases(0)  = getenv(name1)
    cases(1)  = "No Obs"
    name11    = "prefix_1"
    prefix    = getenv(name11)
    in1       = addfile(ptmpdir+"/"+prefix+"MONS_climo.nc","r")
    print ("DEBUG file in1 = "+ptmpdir+"/"+prefix+"MONS_climo.nc")
    if(isfilevar(in1,"levsoi")) then
        nlev1  = getfilevardimsizes(in1,"levsoi")
    end if
    if(isfilevar(in1,"levgrnd")) then
        nlev1  = getfilevardimsizes(in1,"levgrnd")
    end if
    fland1    = in1->landfrac
    area1     = in1->area
    time1     = in1->time
    lat1      = in1->lat
    lon1      = in1->lon
    nlat1     = dimsizes(lat1)
    nlon1     = dimsizes(lon1)
    if (isatt(in1,"yrs_averaged")) then
        yrs_ave1 = in1@yrs_averaged
        cases(0) = cases(0)+" (yrs "+yrs_ave1+")"
    end if
    if (lon1(0) .ge. 0.) then
         area1  = lonFlip(area1)
         fland1 = lonFlip(fland1)
    end if


;******************************
; Read observed data 
;******************************

   if (p .eq. 0) then                        ; read observations for landf variables

        ; T, P, and runoff at 05 degree
        ; these variables read in a datamask and weights from their nc file.

           ptr_wm   = addfile(obsdata+"/0_5_WILLMOTT_ALLMONS_climo.nc","r")   ; temp,precip
           case2    = ptr_wm@case_id
           lat2     = ptr_wm->lat
           nlat2    = dimsizes(lat2)
           lon2     = ptr_wm->lon
           nlon2    = dimsizes(lon2)
           ptr_grdc = addfile(obsdata+"/0_5_GRDC_ALLMONS_climo.nc","r")    ; runoff
           case2_r  = ptr_grdc@case_id
           ptr_fd   = addfile(obsdata+"/0_5_FOSTERDAVY_ALLMONS_climo.nc","r")    ; snowdepth
           case2_sd = ptr_fd@case_id

           landmask2 = new((/nvars,nlat2,nlon2/),"double")
           area2     = new((/nvars,nlat2,nlon2/),"double")

        ; 1x1 degree = landmask3 - snow data is at 1 degree

            ptr_scf  = addfile(obsdata+"/NOAA_AVHRR_SNOWF_ALLMONS_climo.100318.nc","r")   ; snow cover
            ptr_sd   = addfile(obsdata+"/CMC_SNOWD_ALLMONS_climo.100318.nc","r")          ; snow depth
            ptr_swe  = addfile(obsdata+"/CMC_SWE_ALLMONS_climo.100318.nc","r")            ; swe

           lat3     = ptr_sd->lat
           nlat3    = dimsizes(lat3)
           lon3     = ptr_sd->lon
           nlon3    = dimsizes(lon3)

           landmask3 = new((/nvars,nlat3,nlon3/),"double")
           area3     = new((/nvars,nlat3,nlon3/),"double")

        ; 0.9x1.25 degree = landmask5 - lhf and gpp data is at 0.9x.125 degree

           ptr_lhf  = addfile(obsdata+"/MR_LHF_0.9x1.25_ALLMONS_climo.nc","r")           ; lhf
           ptr_gpp  = addfile(obsdata+"/MR_GPP_0.9x1.25_ALLMONS_climo.nc","r")           ; gpp

           lat5     = ptr_lhf->lat
           nlat5    = dimsizes(lat5)
           lon5     = ptr_lhf->lon
           nlon5    = dimsizes(lon5)

           landmask5 = new((/nvars,nlat5,nlon5/),"double")
           area5     = new((/nvars,nlat5,nlon5/),"double")

           ptr_lai  = addfile(obsdata+"/MODIS_LAI_ALLMONS_climo.nc","r")                 ; lai

           lat7     = ptr_lai->lat
           nlat7    = dimsizes(lat7)
           lon7     = ptr_lai->lon
           nlon7    = dimsizes(lon7)

           landmask7 = new((/nvars,nlat7,nlon7/),"float")
           area7     = new((/nvars,nlat7,nlon7/),"float")

        ; No obs for soil moisture storage

           landmask2!0   = "var"
           landmask2&var = vv
           landmask2!1   = "lat"
           landmask2&lat = lat2
           landmask2!2   = "lon"
           landmask2&lon = lon2
           area2!0   = "var"
           area2&var = vv
           area2!1   = "lat"
           area2&lat = lat2
           area2!2   = "lon"
           area2&lon = lon2
        
           landmask3!0   = "var"
           landmask3&var = vv
           landmask3!1   = "lat"
           landmask3!2   = "lon"
           landmask3&lat = lat3
           landmask3&lon = lon3
           area3!0   = "var"
           area3&var = vv
           area3!1   = "lat"
           area3&lat = lat3
           area3!2   = "lon"
           area3&lon = lon3

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
   if (p .eq. 8) then
        ; 64x128 degree = landmask4 - albedo data is at T42
        ptr_alb  = addfile(obsdata+"/T42_MODIS_ALLMONS_climo.070523.nc","r")    ; albedo

        ; 64x128 degree = landmask4 - albedo data is at T42
        ptr_asa  = addfile(obsdata+"/modisradweighted.nc","r")    ; ASA albedo

        lat4     = ptr_alb->lat
           nlat4    = dimsizes(lat4)
           lon4     = ptr_alb->lon
           nlon4    = dimsizes(lon4)

           landmask4 = new((/nvars,nlat4,nlon4/),"double")
           area4     = new((/nvars,nlat4,nlon4/),"double")
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
        array4 = new((/nvars, months, nlat4, nlon4/),"double")        ; T42

   end if

   sFlag = new((/nvars/),"integer")
   aFlag = new((/nvars/),"integer")
   sFlag = 0
   aFlag = 0
;**************************
; Variable loop ----------- read both cases of each variable into memeory.
;**************************
  array1 = new((/nvars, months, nlat1, nlon1/),"double")        ; T42
  array2 = new((/nvars, months, nlat2, nlon2/),"double")        ; 05 degree
  array3 = new((/nvars, months, nlat3, nlon3/),"double")        ; 1  degree
  array5 = new((/nvars, months, nlat5, nlon5/),"double")        ; 0.9x1.25 degree
  array7 = new((/nvars, months, nlat7, nlon7/),"float")         ; 0.5 degree


  nv = nvars+1
  units = new(nvars,"string")
  long_name = new(nvars,"string")

; read all variables into memory first and stuff them into two arrays (2 cases)
  pcheck1  = 0
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

      if (pcheck1 .eq. nvars) then
                 plot_check = False
      end if


;read in observations (if present)
     obsFlag = 0                                  ; (1 = on; 0 = off)
     if (paleo .ne. "True") then
      if (vars(i) .eq. "TSA" ) then
        x2 = ptr_wm->$vars(i)$
        l2 = ptr_wm->datamask
        a2 = ptr_wm->weight
        cases(1)  = "Willmott-Matsuura(T,P),GRDC(R),USAF/ETAC(S),FLUXNET(LHF,GPP)"
        obsFlag = 1
        sFlag(i) = 0
        aFlag(i) = 0
      else
        if (vars(i) .eq. "PREC" .and. p .ne. 5 ) then
          x2 = ptr_wm->PREC
          l2 = ptr_wm->datamask
          a2 = ptr_wm->weight
          obsFlag = 1
          cases(1)  = "Willmott-Matsuura(T,P),GRDC(R),USAF/ETAC(S),FLUXNET(LHF,GPP)"
          sFlag(i) = 0
          aFlag(i) = 0
        else
          if (vars(i) .eq. "TOTRUNOFF" ) then
            x2 = ptr_grdc->RUNOFF
            l2 = ptr_grdc->datamask
            a2 = ptr_grdc->weight
            obsFlag = 1
            cases(1)  = "Willmott-Matsuura(T,P),GRDC(R),USAF/ETAC(S)"
            sFlag(i) = 0
            aFlag(i) = 0
          else
            if (vars(i) .eq. "SNOWDP" .and. snowFlag .eq. 1) then
              if (isvar("x2")) then
                delete(x2)
              end if
              x2 = ptr_fd->$vars(i)$
              l2 = ptr_fd->datamask
              a2 = ptr_fd->weight
              cases(1)      = "FOSTERDAVY"
              x2@_FillValue = 1e30
              obsFlag = 1
              sFlag(i) = 0
              aFlag(i) = 0
            else
              if (vars(i) .eq. "FSNO" ) then
                if (isvar("x3")) then
                    delete(x3)
                 end if
                x3               = ptr_scf->SCF
                x3               = x3 * 0.01            ; convert from percent to 0-1
                l3 = ptr_scf->landmask 
                lf = ptr_scf->landfrac 
                a3 = ptr_scf->weight
                cases(2)         = "NOAA AVHRR (1967-2003)"
                x3@_FillValue    = 1e30
                obsFlag          = 1
                sFlag(i)         = 1
                aFlag(i)         = 0
              else
                  if (vars(i) .eq. "H2OSNO" ) then
                    if (isvar("x3")) then
                        delete(x3)
                     end if
                    x3 = ptr_swe->SWE
                    l3 = ptr_swe->landmask
                    lf = ptr_swe->landfrac 
                    a3 = ptr_swe->weight
                    cases(3)         = "CMC (1980-1996)"
                    x3@_FillValue    = 1e30
                    obsFlag  = 1
                    sFlag(i) = 1;
                    aFlag(i) = 0;
                  else
                    if (vars(i) .eq. "SNOWDP" .and. snowFlag .eq. 2) then
                      if (isvar("x3")) then
                        delete(x3)
                      end if
                      x3 = ptr_sd->SNOWD
                      l3 = ptr_sd->landmask
                      lf = ptr_sd->landfrac 
                      a3 = ptr_sd->weight
                      cases(3)         = "CMC (1980-1996)"
                      x3@_FillValue    = 1e30
                      obsFlag  = 1
                      sFlag(i) = 1
                      aFlag(i) = 0
                    else
                      if (vars(i) .eq. "VBSA") then
                        if (isvar("x4")) then
                            delete(x4)
                         end if
                        x4       = ptr_alb->VBSA
                        cases(3) = "MODIS (2001-2003)"
                        l4 = ptr_alb->LANDFRAC 
                        a4 = ptr_alb->weight
                        x4@_FillValue = 1e30
                        obsFlag  = 1;
                        sFlag(i) = 0;
                        aFlag(i) = 1;
                      else
                        if (vars(i) .eq. "NBSA") then
                           if (isvar("x4")) then
                               delete(x4)
                            end if
                          x4       = ptr_alb->NBSA
                          cases(3) = "MODIS (2001-2003)"
                          l4 = ptr_alb->LANDFRAC 
                          a4 = ptr_alb->weight
                          x4@_FillValue = 1e30
                          obsFlag  = 1;
                          sFlag(i) = 0;
                          aFlag(i) = 1;
                        else
                          if (vars(i) .eq. "VWSA") then
                            if (isvar("x4")) then
                                delete(x4)
                             end if
                            x4       = ptr_alb->VWSA
                            cases(3) = "MODIS (2001-2003)"
                            l4 = ptr_alb->LANDFRAC 
                            a4 = ptr_alb->weight
                            x4@_FillValue = 1e30
                            obsFlag  = 1;
                            sFlag(i) = 0;
                            aFlag(i) = 1;
                          else
                            if (vars(i) .eq. "NWSA") then
                              if (isvar("x4")) then
                                  delete(x4)
                               end if
                              x4       = ptr_alb->NWSA
                              cases(3) = "MODIS (2001-2003)"
                              l4 = ptr_alb->LANDFRAC 
                              a4 = ptr_alb->weight
                              x4@_FillValue = 1e30
                              obsFlag  = 1;
                              sFlag(i) = 0;
                              aFlag(i) = 1;
                            else
                              if (vars(i) .eq. "ASA") then      ; read ASA from different modis file (ptr_asa)
                                if (isvar("x4")) then
                                    delete(x4)
                                end if
                                x4 = ptr_asa->BRDALB            ; broadband albedo
                                cases(3) = "MODIS (2001-2003)"
                                l4 = ptr_alb->LANDFRAC          ; use LANDFRAC and weight from ptr_alb file.
                                a4 = ptr_alb->weight
                                x4@_FillValue = 1e30
                                obsFlag  = 1;
                                sFlag(i) = 0;
                                aFlag(i) = 1;
                              else
                                if (vars(i) .eq. "LHEAT") then
                                  x5 = ptr_lhf->LHF
                                  l5 = ptr_lhf->datamask
                                  a5 = ptr_lhf->area
                                  obsFlag = 1
                                  cases(1)  = "Willmott-Matsuura(T,P),GRDC(R),USAF/ETAC(S),FLUXNET(LHF,GPP)"
                                  sFlag(i) = 0
                                  aFlag(i) = 0
                                else
                                  if ((vars(i) .eq. "FPSN" .and. cn .eq. 0) .or. vars(i) .eq. "GPP") then
                                    x5 = ptr_gpp->GPP
                                    l5 = ptr_gpp->datamask
                                    a5 = ptr_gpp->area
                                    obsFlag = 1
                                    cases(1)  = "Willmott-Matsuura(T,P),GRDC(R),USAF/ETAC(S),FLUXNET(LHF,GPP)"
                                    sFlag(i) = 0
                                    aFlag(i) = 0
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
      end if        ; paleo

      if (paleo .eq. "True") then
                obsFlag = 0
      end if

      if (vcheck1(i) .eq. True) then
         ; catch NaNs
         x1 = catchNaN(x1)

         ; flip variable to match regions definitions (-180-180)
         if (min(x1&lon) .ge. 0) then
              x1 = lonFlip(x1)
         end if

         x1    = scale_var(x1,scale_type(i),info)

         if (obsFlag .eq. 1) then                                ; process variables with observed data
           if (isvar("x2")) then
                   x2 = catchNaN(x2)
                         x2!0    = "mons"
                         x2&mons = mm
                         x2!1    = "lat"
                         x2!2    = "lon"
                         x2&lat  = lat2
                         x2&lon  = lon2
                   if (min(x2&lon) .ge. 0) then
                            x2 = lonFlip(x2)
                   end if
                         a2!0    = "lat"
                         a2!1    = "lon"
                         l2!0    = "lat"
                         l2!1    = "lon"
                         a2&lat  = lat2
                         a2&lon  = lon2
                         l2&lat  = lat2
                         l2&lon  = lon2
                if (min(a2&lon) .ge. 0) then
                     a2 = lonFlip(a2)
                end if
                if (min(l2&lon) .ge. 0) then
                     l2 = lonFlip(l2)
                end if
                   array2(i,:,:,:)  = x2                ; Wrapper fcn that copies coord Vars
                   landmask2(i,:,:) = l2                
                   area2(i,:,:)     = a2                
                   delete(l2)
                   delete(a2)
                delete(x2)
           end if

           if (isvar("x3") .and. sFlag(i) .eq. 1) then
                   x3 = catchNaN(x3)
                         x3!0    = "mons"
                         x3&mons = mm
                         x3!1    = "lat"
                         x3!2    = "lon"
                         x3&lat  = lat3
                         x3&lon  = lon3
                   if (min(x3&lon) .ge. 0) then
                            x3 = lonFlip(x3)
                   end if
                         a3!0    = "lat"
                         a3!1    = "lon"
                         l3!0    = "lat"
                         l3!1    = "lon"
                         lf!0    = "lat"
                         lf!1    = "lon"
                         a3&lat  = lat3
                         a3&lon  = lon3
                         l3&lat  = lat3
                         l3&lon  = lon3
                         lf&lat  = lat3
                         lf&lon  = lon3
                if (min(a3&lon) .ge. 0) then
                     a3 = lonFlip(a3)
                end if
                if (min(l3&lon) .ge. 0) then
                     l3 = lonFlip(l3)
                end if
                if (min(lf&lon) .ge. 0) then
                     lf = lonFlip(lf)
                end if

                ; mask out fractional grid cells.
                l31d = ndtooned(l3)
                lf1d = ndtooned(lf)
                l31d = mask(l31d, lf1d .ne. 1, False)
                l3 = onedtond(l31d,(/nlat3,nlon3/))

                   array3(i,:,:,:)  = x3                ; Wrapper fcn that copies coord Vars
                   landmask3(i,:,:) = l3                
                   area3(i,:,:)     = a3                
                   delete(l3)
                   delete(a3)
                   delete(lf)
           end if

           if (isvar("x4") .and. aFlag(i) .eq. 1) then
                   x4 = catchNaN(x4)
                         x4!0    = "mons"
                         x4&mons = mm
                         x4!1    = "lat"
                         x4!2    = "lon"
                         x4&lat  = lat4
                         x4&lon  = lon4
                   if (min(x4&lon) .ge. 0) then
                            x4 = lonFlip(x4)
                   end if
                         a4!0    = "lat"
                         a4!1    = "lon"
                         l4!0    = "lat"
                         l4!1    = "lon"
                         a4&lat  = lat4
                         a4&lon  = lon4
                         l4&lat  = lat4
                         l4&lon  = lon4
                if (min(a4&lon) .ge. 0) then
                     a4 = lonFlip(a4)
                end if
                if (min(l4&lon) .ge. 0) then
                     l4 = lonFlip(l4)
                end if
                   array4(i,:,:,:)  = x4                ; Wrapper fcn that copies coord Vars
                   landmask4(i,:,:) = l4
                   area4(i,:,:)     = a4                
                   delete(l4)
                   delete(a4)
                delete(x4)
           end if

           if (isvar("x5")) then
                   x5 = catchNaN(x5)
                         x5!0    = "mons"
                         x5&mons = mm
                         x5!1    = "lat"
                         x5!2    = "lon"
                         x5&lat  = lat5
                         x5&lon  = lon5
                   if (min(x5&lon) .ge. 0) then
                            x5 = lonFlip(x5)
                   end if
                         a5!0    = "lat"
                         a5!1    = "lon"
                         l5!0    = "lat"
                         l5!1    = "lon"
                         a5&lat  = lat5
                         a5&lon  = lon5
                         l5&lat  = lat5
                         l5&lon  = lon5
                if (min(a5&lon) .ge. 0) then
                     a5 = lonFlip(a5)
                end if
                if (min(l5&lon) .ge. 0) then
                     l5 = lonFlip(l5)
                end if
                   array5(i,:,:,:)  = x5                ; Wrapper fcn that copies coord Vars
                   landmask5(i,:,:) = l5                
                   area5(i,:,:)     = a5                
                   delete(l5)
                   delete(a5)
                delete(x5)
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
   
         array1(i,:,:,:) = x1                 ; time, lat, lon
         units(i)        = x1@units
         long_name(i)    = x1@long_name
         delete(x1)

      end if
      if (paleo .ne. "True") then
          if (snowFlag .eq. 1) then             ; run SNOWDP twice to see both obs datasets
                i = i-1 
          end if
       end if

   end do         ; end variable loop
   print ("End variable loop")


;**********************************
; now plot vars by region
;**********************************
if(plot_check.eq.True)then
 if (paleo .eq. "True") then
         startRegion=nreg-3        ; N. and S. Hemisphere Land, global
 else
         startRegion=0
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
        data = new((/nvars,nmons/),"double")
            labels = new(3,"string")
        do i = 0,nvars-1
   
      ; process model results
              compare = "model"
              if(vcheck1(i) .eq. True) then
                   x1 = array1(i,:,:,:)
                   if (vars(i) .eq. "RNET") then
                           x1 = (x1 / 2.501e6) * secondsPerDay
                   end if
                   var_plot1 = regional_values(x1,region,area1,fland1,scale_type(i),\
                       regions_file,time1,nmons,compare)
                   data(i,:) = var_plot1
   
                   res@tiYAxisString = "mm/d"
                   labels(i)              = titstr(i)
     
                   delete(var_plot1)
                   delete(x1)
               end if
        end do
        res@gsnLeftString = cases(0)
            plot(0) = gsn_csm_xy(wks,month,data,res) 
        delete(res@gsnLeftString)
        delete(data)
   else
        do i = 0,nvars-1
          if (vcheck1(i) .eq. True) then

; snowdp plot draws 2 obs + 1 variable on snowdp plot.  Other plots have only 1 variable per plot.
            if (vars(i) .eq. "SNOWDP") then

                   if (paleo .eq. "True") then                        ; paleo runs, no obs
                           data   = new((/1,nmons/),"double")
                   else
                           data   = new((/3,nmons/),"double")
                   end if
                     res@xyDashPatterns  = (/0.,16.,16./)          ; solid, dashed
                     res@xyLineColors    = (/"red","blue","black"/)  ; model,FOSTER,CMC
      
                ; process model results
                    compare = "model"
                    if (isvar("x1")) then
                        delete(x1)
                    end if
                    x1 = array1(i,:,:,:)
                    var_plot1 = regional_values(x1,region,area1,fland1,scale_type(i),\
                          regions_file,time1,nmons,compare)
                    data(0,:) = var_plot1
                    delete(var_plot1)
                    delete(x1)

                   if (paleo .eq. "False") then                        ; paleo runs, no obs
                ; process 1st set of obs (FOSTER = dashed line)
                            compare = "obs"
                            if (isvar("x2")) then
                                delete(x2)
                            end if
                            x2 = array2(i,:,:,:)
                            var_plot2 = regional_values(x2,region,area2(i,:,:),landmask2(i,:,:),scale_type(i),\
                                regions_file,time1,nmons,compare)
                            data(1,:) = var_plot2
                            delete(var_plot2)
                            delete(x2)

                 ; 2nd SNOWDP obs (CMC = solid line)
                            if (isvar("x3")) then
                                delete(x3)
                            end if
                            x3 = array3(i,:,:,:)
                            var_plot2 = regional_values(x3,region,area3(i,:,:),landmask3(i,:,:),scale_type(i),\
                                regions_file,time1,nmons,compare)
                            data(2,:) = var_plot2
                            delete(var_plot2)
                            delete(x3)
      
                    end if                         ; paleo
                    res@tiYAxisString = "mm/d"
                    res@gsnCenterString = titstr(i)
        
                           plot(i) = gsn_csm_xy(wks,month,data,res) 
                       delete(data)
            else
                    if (vars(i) .eq. "FSNO") then                ; NOAA-AVHRR (black)
                        delete(res@xyLineColors)
                        res@xyLineColors         = (/"red","black","black"/)
                    end if
                    if (vars(i) .eq. "H2OSNO") then                ; CMC (black)
                        delete(res@xyLineColors)
                        res@xyLineColors         = (/"red","black","blue"/)
                    end if
                    if (aFlag(i) .eq. 0) then
                        delete(res@xyLineColors)
                        res@xyLineColors         = (/"red","black","black"/)
                    end if
   
                       ; process model 
                    if (isvar("x1")) then
                        delete(x1)
                    end if
                    x1 = array1(i,:,:,:)
                    compare = "model"
                    if (vars(i) .eq. "ALBEDO" .or. aFlag(i) .eq. 1) then        ; any albedo variable
                      var_plot1 = regional_albedo(x1,region,area1,fland1,scale_type(i),\
                              regions_file,nmons,compare)
                    else
                      var_plot1 = regional_values(x1,region,area1,fland1,scale_type(i),\
                              regions_file,time1,nmons,compare)
                    end if
                    delete(x1)

           ; process observations, if available
                    if (obsFlag .eq. 1) then                        ; process variables with observed data
                                data = new((/2,nmons/),"double")
                           compare = "obs"
                           if (sFlag(i) .eq. 1) then                ; processing snow vars at 1x1 degree
                                    if (isvar("x3")) then
                                    delete(x3)
                                    end if
                                   x3 = array3(i,:,:,:)
                                var_plot2 = regional_values(x3,region,area3(i,:,:),landmask3(i,:,:),scale_type(i),\
                                                              regions_file,time1,nmons,compare)
                                delete(x3)
                           else
                              if (aFlag(i) .eq. 1) then                ; processing albedo variables (T42)
                                    if (isvar("x4")) then
                                    delete(x4)
                                    end if
                                   x4 = array4(i,:,:,:)
                                var_plot2 = regional_albedo(x4,region,area4(i,:,:),landmask4(i,:,:),scale_type(i),\
                                                              regions_file,nmons,compare)
                                delete(x4)
                              else
                                    if (isvar("x2")) then
                                    delete(x2)
                                    end if
                                   x2 = array2(i,:,:,:)
                                var_plot2 = regional_values(x2,region,area2(i,:,:),landmask2(i,:,:),scale_type(i),\
                                                              regions_file,time1,nmons,compare)
                                delete(x2)
                                if (vars(i) .eq. "LHEAT") then
                                  if (isvar("x5")) then
                                      delete(x5)
                                  end if
                                     x5 = array5(i,:,:,:)
                                  var_plot2 = regional_values(x5,region,area5(i,:,:),landmask5(i,:,:),scale_type(i),\
                                                                regions_file,time1,nmons,compare)
                                  delete(x5)
                                else
                                  if ((vars(i) .eq. "FPSN" .and. cn .eq. 0) .or. vars(i) .eq. "GPP") then
                                    if (isvar("x5")) then
                                        delete(x5)
                                    end if
                                       x5 = array5(i,:,:,:)
                                    var_plot2 = regional_values(x5,region,area5(i,:,:),landmask5(i,:,:),scale_type(i),\
                                                                  regions_file,time1,nmons,compare)
                                    delete(x5)
                                  else
                                    if (vars(i) .eq. "TLAI") then
                                      if (isvar("x7")) then
                                        delete(x7)
                                      end if
                                      x7 = array7(i,:,:,:)
                                      var_plot2 = regional_values(x7,region,area7(i,:,:),landmask7(i,:,:),scale_type(i),\
                                                                    regions_file,time1,nmons,compare)
                                      delete(x7)
                                    end if
                                  end if
                                end if
                              end if
                           end if
                           data(1,:) = var_plot2
                    else
                                data = new((/1,nmons/),"double")
                    end if
   
                    data(0,:) = var_plot1
        
                    res@tiYAxisString          = units(i)
                    res@gsnCenterString        = titstr(i)
        
             ; now stuff it into a graphics array variable for plotting after all variables are done for
             ; this region.
                        plot(i) = gsn_csm_xy(wks,month,data,res) 

                    delete(data)
                    delete(var_plot1)
                    delete(res@gsnCenterString)
               end if        ; end SNOWDP
             end if
       end do        ; end variable loop
  end if        ; end plot 5 fork

; and plot it already using gsn_panel to print all plots onto it from plot array


;*************************************************
;  gsnpanel takes this plot array and massages it and puts it onto page for us.
;*************************************************

      if (isdefined("lgres"))
        delete(lgres)
      end if
      lgres                    = True                   ; allow legend resources
      lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
      lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
      lgres@lgPerimOn          = False
      lgres@lgLabelFontHeightF = 0.015                  ; increase font height
      lgres@lgLineLabelStrings = (/"","",""/)           ; no labels in lines
      lgres@lgAutoManage       = False                  ; must have to adjust fonts
      lgres@vpWidthF           = 0.45
      lgres@vpHeightF          = 0.10

      pres@gsnFrame            = False                  ; don't advance yet so add legend
      pres@gsnMaximize         = True                   ; make as large as possible
      pres@gsnPaperOrientation = "Portrait"
      pres@gsnPanelBottom      = 0.15                   ; save space for legend
      pres@gsnPanelRowSpec     = True
      pres@gsnPanelCenter      = True

      if (p .eq. 0) then                                ; landf (6 vars)
           cases(1)  = "Willmott-Matsuura(T,P),GRDC(R),USAF/ETAC(S),FLUXNET(LHF,GPP),MODIS(LAI)"
           cases(2)                     = "CMC 1980-1996"
           pres@gsnPanelCenter      = False
           pres@gsnPanelYWhiteSpacePercent = 4
           pres@gsnPanelXWhiteSpacePercent = 4
           gsn_panel(wks,plot,(/2,2,2,2/),pres)             ; draw panel plot
           lgres@vpWidthF           = 0.80
                 lgres@lgLineColors       = (/"red","blue","black"/)       ; set these equal to those
                 lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
           gsn_legend_ndc(wks,3,cases(0:2),0.15,0.15,lgres)  ; draw common legend    MAY HAVE TO ADJUST Y
      end if
      if (p .eq. 1) then                                ; radf  (7 vars)
            pres@gsnPanelCenter      = False
            gsn_panel(wks,plot,(/2,2,2,1/),pres)
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
              "lgDashIndexes"            : (/0,1/)
              "lgLineColors"             : (/"red","blue"/)
              "lgMonoLineLabelFontColor" : True
              "lgAutoManage"             : False
              "lgLabelFontHeightF"       : 0.0125
              "lgLabelPosition"          : "Center"
              "lgLabelAlignment"         : "AboveItems"
            end create
            draw(legend)
            delete(legend)
      end if
      if (p .eq. 2) then                                ; turbf (9)
            pres@gsnPanelCenter      = False
            gsn_panel(wks,plot,(/2,2,2,2,2/),pres)
            legend = create "Legend" legendClass wks
              "vpXF"                     : 0.20
              "vpYF"                     : 0.16
              "vpWidthF"                 : 0.20
              "vpHeightF"                : 0.1
              "lgPerimOn"                : False
              "lgItemCount"              : 2
              "lgLabelsOn"               : True
              "lgLineLabelsOn"           : False
              "lgLabelStrings"           : cases(0:1)
              "lgDashIndexes"            : (/0,1/)
              "lgLineColors"             : (/"red","blue"/)
              "lgMonoLineLabelFontColor" : True
              "lgAutoManage"             : False
              "lgLabelFontHeightF"       : 0.015
              "lgLabelPosition"          : "Center"
              "lgLabelAlignment"         : "AboveItems"
            end create
            draw(legend)
            delete(legend)
      end if
      if (p .eq. 3 ) then                  ; 3 and 4 are cn and fire (10 vars each)
            cases(1)  = "No Obs"
            pres@gsnPanelCenter      = False
            lgres@lgLabelFontHeightF = 0.025
            if (clamp .eq. 1 .or. casa .eq. 1)  then
                 gsn_panel(wks,plot,(/2,2,2/),pres)        ; draw panel plot
                 gsn_legend_ndc(wks,1,cases(0:1),0.275,0.13,lgres) ; draw common legend   
            else
                 gsn_panel(wks,plot,(/2,2,2,2,2/),pres)        ; draw panel plot
;                gsn_legend_ndc(wks,1,cases(0:1),0.275,0.10,lgres) ; draw common legend  
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
                 delete(legend)
            end if
            lgres@lgLabelFontHeightF = 0.015
      end if
      if (p .eq. 4) then                  ; 3 and 4 are cn and fire (4 vars each)
            cases(1)  = "No Obs"
            pres@gsnPanelCenter      = False
            gsn_panel(wks,plot,(/2,2,2/),pres)        ; draw panel plot
            gsn_legend_ndc(wks,2,cases(0:1),0.35,0.10,lgres) ; draw common legend
      end if
      if (p .eq. 5) then
            pres@gsnPanelCenter      = True
            gsn_panel(wks,plot,(/1,1/),pres)            ; draw panel plot
            lgres@lgLabelFontHeightF = 0.015 
            gsn_legend_ndc(wks,3,labels,0.275,0.52,lgres); draw common legend       
            delete(labels)
      end if
      if (p .eq. 6) then
            cases(1)  = "No Obs"
            pres@gsnPanelCenter      = True
            gsn_panel(wks,plot,(/2,2,1/),pres) ; draw panel plot
            lgres@lgLabelFontHeightF = 0.028
            gsn_legend_ndc(wks,2,cases,0.275,0.17,lgres) ; draw common legend        
            lgres@lgLabelFontHeightF = 0.015
      end if
      if (p .eq. 7) then                                                            ; snow
            cases(1)                      = "USAF"
            cases(2)                 = "CMC/NOAA-AVHRR"
            delete(lgres)
            lgres                    = True                   ; allow legend resources
            lgres@lgPerimOn          = False
            lgres@lgLabelFontHeightF = 0.015                   ; increase font height
            lgres@lgLineLabelStrings = (/"","",""/)           ; no labels in lines
            lgres@lgAutoManage       = False                  ; must have to adjust fonts
            lgres@vpWidthF           = 0.55
            lgres@vpHeightF          = 0.15
            lgres@lgLineColors       = (/"red","blue","black"/)
            lgres@xyLineThicknesses  = (/2.,2.,2./)
            lgres@lgDashIndexes      = (/0.,16.,16./)          ; solid, dashed
            lgres@lgLineLabelsOn     = False
            gsn_legend_ndc(wks,3,cases(0:3),0.225,0.23,lgres)  ; draw common legend      MAY HAVE TO ADJUST Y
            gsn_panel(wks,plot,(/2,2/),pres)             ; draw panel plot
      end if
      if (p .eq. 8) then                                                            ; snow
            cases(1)                      = "MODIS 2001-2003"
            delete(lgres)
            lgres                    = True                   ; allow legend resources
            lgres@lgPerimOn          = False
            lgres@lgLabelFontHeightF = 0.015                  ; increase font height
            lgres@lgLineLabelStrings = (/"","",""/)           ; no labels in lines
            lgres@lgAutoManage       = False                  ; must have to adjust fonts
            lgres@vpWidthF           = 0.55
            lgres@vpHeightF          = 0.15
            lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
            lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
            lgres@lgLineLabelsOn     = False
            gsn_legend_ndc(wks,2,cases(0:1),0.225,0.15,lgres)  ; draw common legend      MAY HAVE TO ADJUST Y
            gsn_panel(wks,plot,(/2,2,1/),pres)             ; draw panel plot
      end if
      frame(wks)

   end do        ;  end of region loop
end if        ;  end of plot_check loop

   delete(vars)
   delete(vcheck1)
   if (isvar("array1")) then
           delete(array1)
   end if
   if (isvar("array2")) then
           delete(array2)
   end if
   if (isvar("array3")) then
           delete(array3)
   end if
   if (isvar("array4")) then
           delete(array4)
   end if
   if (isvar("array5")) then
           delete(array5)
   end if
   if (isvar("array7")) then
           delete(array7)
   end if
   delete(scale_type)
   delete(plot)
   delete(units)
   delete(long_name)
   delete(mm)
   delete(vv)
   delete(titstr)
   delete(sFlag)
   delete(aFlag)

  end do   ; end plot loop

  delete(landmask2)
  delete(landmask3)
  delete(landmask4)
  delete(landmask5)
  delete(landmask7)
  delete(area2)
  delete(area3)
  delete(area4)
  delete(area5)
  delete(area7)

;----------------------------------------------
; Create global maps delineating regions (on model grid)
;----------------------------------------------

;----------------------------------------------
; common plot resources
;----------------------------------------------
 if(isvar("res")) then
        delete(res)
 end if
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
 res@cnRasterModeOn = True

 flag1 = area1
 flag1 = -0.1

 
 if (paleo .eq. "True") then
         startRegion=nreg-3        ; N. + S. Hemisphere land  + global
 else
         startRegion=0
 end if

 if (paleo .eq. "True") then
    landfrac = in1->landfrac
    oro = new((/nlat1,nlon1/),integer)
    oro = 1
    oro@_FillValue = 0
    oro = where(landfrac .gt. 0.0, 1,0)
;   fname = wkdir+prefix
;   fname = wkdir+"basename"
;   fname = wkdir+cases(0)
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
