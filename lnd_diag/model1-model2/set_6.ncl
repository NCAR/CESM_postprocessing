load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/lnd_func.ncl"
;************************************************
begin
 print ("=========================================")
 print ("Starting:  set_6.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
  resdir    = getenv("DIAG_RESOURCES")
  inputdir  = getenv("INPUT_FILES")
  plot_type = getenv("PLOTTYPE")
  wkdir     = getenv("WKDIR")
  ptmpdir1   = getenv("PTMPDIR_1")
  ptmpdir2   = getenv("PTMPDIR_2")
  paleo     = getenv("paleo")
  land_mask = getenv("land_mask1")
   landmask = stringtofloat(land_mask)
  cn        = getenv("CN")
  clamp     = getenv("CLAMP")
  casa      = getenv("CASA")
  hydroFlag = getenv("HYDRO")
 useCommon1 = getenv("UseCommonName_1")
 useCommon2 = getenv("UseCommonName_2")
  plot_type = getenv("PLOTTYPE")


;*************************************************
; check for comparable time periods
;*************************************************
  nyrs1      = stringtointeger(getenv("trends_num_yrs_1"))
  fyr1       = stringtointeger(getenv("trends_first_yr_1"))
  matchYr1   = stringtointeger(getenv("trends_match_yr_1"))
  nyrs2      = stringtointeger(getenv("trends_num_yrs_2"))
  fyr2       = stringtointeger(getenv("trends_first_yr_2"))
  matchYr2   = stringtointeger(getenv("trends_match_yr_2"))
  trendsFlag = stringtointeger(getenv("trends_match_Flag"))

  if (nyrs1 .ne. nyrs2 .or. fyr1 .ne. fyr2 .or. trendsFlag .eq. 1) then
        x2y2Plot = 1			; 1=ON, 0=OFF
        yrDifferential = matchYr2 - matchYr1
        fy = min( (/fyr1,(fyr2-yrDifferential)/) )
        ly = max( (/(fyr1+nyrs1),(fyr2-yrDifferential+nyrs2)/) )
        nyrs = ly - fy

        fy1 = fy
        fy2 = fy + yrDifferential
        if (fyr1 .eq. fy) then
                offset1 = 0
                offset2 = matchYr2 - fy2
        else
                offset2 = 0
                offset1 = matchYr1 - fy1
        end if
        tspan = ispan(0,nyrs-1,1)
        t1 = tspan + fy
        t2 = tspan + fy + yrDifferential
  else
        x2y2Plot = 0			; 1=ON; 0=OFF
        nyrs = nyrs1
        fyr  = fyr1
        offset1 = 0
        offset2 = 0
  end if
  yrs1 = nyrs1
  yrs2 = nyrs2

;***********************************************
; import regional information
;***********************************************

 months = 12   ; number of months
 regions_file = addfile(resdir + "/region_definitions.nc","r")
; regions_file = addfile("/glade/u/home/dlawren/regions_temp.nc","r")
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

; print("Start main loop")
; print ("=========================================")
; print ("Time: "+systemfunc("date") )
; print ("=========================================")

;*************************************************
; main loop
;*************************************************

nplots = 12

; loop over plots
 do p=0,nplots-1

 print("Now printing plot #" + p)
  if (p .eq. 0) then 
	fileName   = "set6_landFlx.txt"
	plot_name  = "landf"
        titstr = new(4,"string")
        titstr(0) = "2m Air Temperature (~S~o~N~K)"
        titstr(1) = "Precipitation (mm day~S~-1~N~)"
        titstr(2) = "Runoff (mm day~S~-1~N~)"
        titstr(3) = "Snow Depth (m)"
  end if
  if (p .eq. 1) then
	fileName   = "set6_radFlx.txt"
	plot_name  = "radf"
        titstr = new(8,"string")
        titstr(0) = "Incoming Solar"
        titstr(1) = "Albedo"
        titstr(2) = "Absorbed Solar"
        titstr(3) = "Incoming Longwave"
        titstr(4) = "Emitted Longwave"
        titstr(5) = "Net Longwave"
        titstr(6) = "Net Radiation"
        titstr(7) = "Ground Snow Covered Fraction"
  end if
  if (p .eq. 2) then
	fileName   = "set6_turbFlx.txt"
	plot_name  = "turbf"
        titstr = new(9,"string")
        titstr(0) = "Net Radiation"
        titstr(1) = "Sensible Heat"
        titstr(2) = "Latent Heat"
        titstr(3) = "Transpiration"
        titstr(4) = "Canopy Evaporation"
        titstr(5) = "Ground Evaporation"
        titstr(6) = "Ground Heat + Snow Melt"
        titstr(7) = "Soil moisture factor (BTRAN or BTRANMN)"
        titstr(8) = "Total LAI"
  end if
  if (p .eq. 3) then
    if (clamp .eq. 1) then
                fileName   = "set6_clampFlx.txt"
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
                fileName   = "set6_cnFlx.txt"
                plot_name  = "cnFlx"
                titstr = new(10,"string")
                titstr(0) = "Net Ecosystem Exchange"
                titstr(1) = "GPP"
                titstr(2) = "NPP"
                titstr(3) = "Autotrophic Respiration"
                titstr(4) = "Heterotrophic Respiration"
                titstr(5) = "Ecosystem Respiration"
                titstr(6) = "Gridcell Surface CH4 Flux"
                titstr(7) = "Carbon Use Efficiency (NPP/GPP)"
                titstr(8) = "Soil NO3 Pool Loss to Leaching"
                titstr(9) = "NPP_NUPTAKE/(NPP_NUPTAKE+NPP)"
        else
            if (casa .eq. 1) then
                fileName   = "set6_casaFlx.txt"
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
	fileName   = "set6_fireFlx.txt"
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
     if (cn .eq. 1) then
        fileName   = "set6_carbonStock.txt"
        plot_name  = "crbStock"
        titstr = new(8,"string")
        titstr(0) = "Total Ecosystem Carbon"
        titstr(1) = "Total Soil Organic Matter Carbon"
        titstr(2) = "Total Vegetation Carbon"
        titstr(3) = "Total Litter Carbon"
        titstr(4) = "Coarse Woody Debris Carbon"
        titstr(5) = "Land Cover Change Flux"
        titstr(6) = "Leaf C/N"
        titstr(7) = "Total Vegetation C/N"
     else
        continue
     end if
  end if
  if (p .eq. 6) then 
        vars         = (/"TSOI"/)
        scale_type   = (/"globalMeanNat"/)
        nvars        = dimsizes(vars)
        nplotsPerCol = 5			; hardwired for 10 soil levels
        plot_name    = "tsoi"
        titstr       = new(1,"string")
        titstr(0)    = "Mean Soil Temperature"
        units_layer  = "K"
  end if
  if (p .eq. 7) then 
        vars         = (/"SOILLIQ"/)
        scale_type   = (/"globalMeanNat"/)
        nvars        = dimsizes(vars)
        nplotsPerCol = 5			; hardwired for 10 soil levels
        plot_name    = "soilliq"
        titstr       = new(1,"string")
        titstr(0)    = "Soil Liquid Water"
        units_layer  = "kg/m2"
  end if
  if (p .eq. 8) then 
        vars         = (/"SOILICE"/)
        scale_type   = (/"globalMeanNat"/)
        nvars        = dimsizes(vars)
        nplotsPerCol = 5			; hardwired for 10 soil levels
        plot_name    = "soilice"
        titstr       = new(1,"string")
        titstr(0)    = "Soil Ice"
        units_layer  = "kg/m2"
  end if
  if (p .eq. 9) then 
        vars         = (/"TOTSOILICE","TOTSOILLIQ"/)
        scale_type   = (/"globalMeanNat","globalMeanNat"/)
        nvars        = dimsizes(vars)
  	nplotsPerCol = 2
        plot_name    = "soilliqIce"
        titstr       = new(2,"string")
        titstr(0)    = "Total Soil Ice"
        titstr(1)    = "Total Soil Liquid Water"
  end if
  if (p .eq. 10) then 
        vars         = (/"SNOWLIQ","SNOWICE"/)
        scale_type   = (/"globalMeanNat","globalMeanNat"/)
        nvars        = dimsizes(vars)
  	nplotsPerCol = 2
        plot_name    = "snowliqIce"
        titstr       = new(2,"string")
        titstr(0)    = "Total Snow Liquid Water"
        titstr(1)    = "Total Snow Ice"
  end if
  if (p .eq. 11) then
     if (hydroFlag .eq. 1) then
        fileName   = "set6_hydro.txt"  
        plot_name  = "hydro"
        titstr = new(6,"string")
        titstr(0) = "Water in Unconfined Aquifer"       ; WA 
        titstr(1) = "Water Table Depth"                 ; ZWT
        titstr(2) = "Aquifer Recharge Rate"             ; QCHARGE
        titstr(3) = "Frac Water Table at Surface"       ; FCOV                  
        titstr(4) = "Total Water Storage"               ; TWS
        titstr(5) = "River Channel Total Water Storage" ; VOLR
     else
        continue
     end if
  end if

;----------------------------------------------------------
; read in file and parse into variables
;----------------------------------------------------------
  if (p .lt. 6 .or. p .eq. 11)
  	tmp = stringtocharacter(asciiread(inputdir+"/"+fileName,-1,"string"))
  	nvars = dimsizes(tmp(:,0))
  	nplotsPerCol = (nvars+1)/2
  	scale_type = new(nvars,"string")
  	vars       = new(nvars,"string")
  	do i=0,nvars-1
        	scale_type(i) = charactertostring(tmp(i,0:12))
        	vars(i)       = charactertostring(tmp(i,16:))
  	end do
  	delete(tmp)
  end if

  vcheck1    = new(nvars,"string")
  vcheck2    = new(nvars,"string")
  plot_check = True	; 20dec04 - nanr; added so that plot_check would be defined for underived vars.
  rank   = 0 

;----------------------------------------------------------
; Define common plots resources 
;----------------------------------------------------------

  res                        = True
  res@xyDashPatterns         = (/0.,16./)          ; solid, dashed
  res@xyLineThicknesses      = (/2.,2./)
  res@xyLineColors           = (/"red","blue"/)
  res@tmXBMinorOn            = False
  res@tiMainOn               = False
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@tiXAxisFontHeightF     = 0.030
  res@tiYAxisFontHeightF     = 0.030
  res@txFontHeightF          = 0.030
  res@tmYLLabelFontHeightF   = 0.030
  res@tmYLFormat             = "0@!;*?5g"

  res@pmLegendDisplayMode    = "Never"
  res@vpHeightF              = 0.4
  res@vpWidthF               = 0.8

  cases  = new(2,"string")
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
  cases(0)  = "  "+getenv(name1)
  cases(1)  = "  "+getenv(name2)
  prefix(0)  = getenv(name11)
  prefix(1)  = getenv(name22)
  in1       = addfile(ptmpdir1+"/"+prefix(0)+"ANN_ALL.nc","r")
  in2       = addfile(ptmpdir2+"/"+prefix(1)+"ANN_ALL.nc","r")
; Follow logic of set_1 because now both levsoi and levgrnd may be present
  nlev1 = 0
  if (isfilevar(in1,"levsoi")) then
     nlev1       = getfilevardimsizes(in1,"levsoi")
     levsoi1     = in1->levsoi
  end if
  if (isfilevar(in1,"levgrnd")) then
     nlev1       = getfilevardimsizes(in1,"levgrnd")
     levsoi1     = in1->levgrnd
  end if
  if (nlev1 .eq. 0)
     print("FATAL ERROR:  nlev1 = 0")
     exit
  end if
; truncate soil layers if needed
  if (nlev1 .gt. 10) then
;    print("Truncating soil levels to 10 levels [caseid: "+prefix(0)+"  nlev:  " + nlev +"]")
     nlev1 = 10
  end if
  nlev2 = 0
  if (isfilevar(in2,"levsoi")) then
     nlev2       = getfilevardimsizes(in2,"levsoi")
     levsoi2     = in2->levsoi
  end if
  if (isfilevar(in2,"levgrnd")) then
     nlev2 = getfilevardimsizes(in2,"levgrnd")
     levsoi2     = in2->levgrnd
  end if
  if (nlev2 .eq. 0)
     print("FATAL ERROR:  nlev2 = 0")
     exit
  end if
; truncate soil layers if needed
  if (nlev2 .gt. 10) then
;    print("Truncating soil levels to 10 levels [caseid: "+prefix(1)+"  nlev:  " + nlev +"]")
     nlev2 = 10
  end if

  fland1     = in1->landfrac
  area1      = in1->area
  lat1       = in1->lat
  lon1       = in1->lon
  time1      = in1->time
  nlat1      = dimsizes(lat1)
  nlon1      = dimsizes(lon1)
  fland2     = in2->landfrac
  area2      = in2->area
  lat2       = in2->lat
  lon2       = in2->lon
  nlat2      = dimsizes(lat2)
  nlon2      = dimsizes(lon2)
  time2      = in2->time

  if(yrs1 .ne. dimsizes(time1) .or. yrs2 .ne. dimsizes(time2) ) then
           print("   ")
           print("   ")
           print("FATAL ERROR:")
           print("case1: ANN_ALL.nc time dimension wrong:  ANN_ALL.nc=(" + dimsizes(time1) + ") vs trends_num_yrs=(" + yrs1 +")")
           print("case2: ANN_ALL.nc time dimension wrong:  ANN_ALL.nc=(" + dimsizes(time2) + ") vs trends_num_yrs=(" + yrs2 +")")
           print("Exiting Set_6.ncl")
           print("   ")
           print("   ")
           exit
  end if     


; ----------------------------------------------------------
; region_definitions are defined from -180 to -180; if history file comes in
; with lon defined as 0-360, need to use lonFlip to change incoming history variables
; including area, fland, etc.
; ----------------------------------------------------------
  if (lon1(0) .lt. 0.) then
      fliplon1 = "False"           ; history files (including area) run from -180 to 180
  else
      fliplon1 = "True"            ; history files (including area) run from 0 - 360; need to be flipped
  end if

  if (lon2(0) .lt. 0.) then
      fliplon2 = "False"           ; history files (including area) run from -180 to 180
  else
      fliplon2 = "True"            ; history files (including area) run from 0 - 360; need to be flipped
  end if

;----------------------------------------------
; Flip area1 and fland1 from 0/360 to -180/180 
; Note:  lon(0) is from history files.  previous lonFlips do not affect its value.
;----------------------------------------------
  if (fliplon1 .eq. "True") then
            area1  = lonFlip(area1)
            fland1 = lonFlip(fland1)
  end if

  if (fliplon2 .eq. "True") then
            area2  = lonFlip(area2)
            fland2 = lonFlip(fland2)
  end if



; ---------------------
; extract record information
; ---------------------

  if (isatt(in1,"yrs_averaged")) then
        yrs_ave1 = in1@yrs_averaged
        cases(0) = cases(0)+" (yrs "+yrs_ave1+")"
  end if
  if (isatt(in2,"yrs_averaged")) then
        yrs_ave2 = in2@yrs_averaged
        cases(1) = cases(1)+" (yrs "+yrs_ave2+")"
  end if

;**************************
; Variable loop ----------- read both cases of each variable into memeory.
;**************************
  array1   = new((/nvars, nyrs,  nlat1, nlon1/),"float")
  array2   = new((/nvars, nyrs,  nlat2, nlon2/),"float")
  array1_3 = new((/nyrs,  nlev1, nlat1, nlon1/),"float")
  array2_3 = new((/nyrs,  nlev2, nlat2, nlon2/),"float")
  units = new(nvars,"string")
  long_name = new(nvars,"string")

; read all variables into memory first and stuff them into two arrays (2 cases)
  pcheck1 = 0
  pcheck2 = 0

; print("Start variable loop")
; print ("=========================================")
; print ("Time: "+systemfunc("date") )
; print ("=========================================")

  do i=0,nvars-1 

;      print("Processing variable:  " + vars(i) )
;      print ("=========================================")
;      print ("Time: "+systemfunc("date") )
;      print ("=========================================")

; check for variables in case 1
      info = var_init(vars(i))
      vcheck1(i) = True
      if(isfilevar(in1,vars(i)) .and. info@derivedVariable .eq. False)then

          x1 = in1->$vars(i)$
          plot_check = True
      	  rank = dimsizes(dimsizes(x1))
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
      vcheck2(i) = True
      if(isfilevar(in2,vars(i)) .and. info@derivedVariable .eq. False)then
          x2 = in2->$vars(i)$
      else
          if (info@derivedVariable .eq. True) then
          	x2 = derive_land(vars(i),in2)
	  else
                print("variable "+ vars(i)+ " is not a defined variable in case2.")
                pcheck2 = pcheck2 + 1
                vcheck2(i) = False
          end if
       end if
;       print ("Complete reading in variable or derive_land")
;       print ("=========================================")
;       print ("Time: "+systemfunc("date") )
;       print ("=========================================")


; if neither case has the variables, don't plot them.
       if (pcheck1 .eq. nvars .and. pcheck2 .eq. nvars) then
              	plot_check = False
       end if

       ; catch NaNs

       if (vcheck1(i) .eq. True)
       	  x1 = catchNaN(x1)
      	  rank = dimsizes(dimsizes(x1))
          ; flip variable to match regions definitions (-180-180)
          if (fliplon1 .eq. "True") then
             x1 = lonFlip(x1)
          end if
          x1    = scale_var(x1,scale_type(i),info)
          if (rank .eq. 3) then
                array1(i,offset1:(offset1+nyrs1-1),:,:) = x1
          end if
          if (rank .eq. 4) then
                array1_3(offset1:(offset1+nyrs1-1),:,:,:) = x1(:,0:nlev1-1,:,:)
          end if 	
          units(i)        = x1@units
          long_name(i)    = x1@long_name
          delete(x1)
       end if 	
       if (vcheck2(i) .eq. True)
          x2 = catchNaN(x2)
      	  rank = dimsizes(dimsizes(x2))
          if (fliplon2 .eq. "True") then
             x2 = lonFlip(x2)
          end if
          x2    = scale_var(x2,scale_type(i),info)

          if (rank .eq. 3) then
                array2(i,offset2:(offset2+nyrs2-1),:,:) = x2
          end if
          if (rank .eq. 4) then
                array2_3(offset2:(offset2+nyrs2-1),:,:,:) = x2(:,0:nlev2-1,:,:)
          end if 	
          units(i)        = x2@units
          long_name(i)    = x2@long_name
          delete(x2)
       end if
;       print ("Complete lonFlips and scaling of variable")
;       print ("=========================================")
;       print ("Time: "+systemfunc("date") )
;       print ("=========================================")

 
   end do 	; end variable loop

;  print("End processing variables for plot " + p)
;  print ("=========================================")
;  print ("Time: "+systemfunc("date") )
;  print ("=========================================")

;**********************************
; now plot vars by region
;**********************************
if(plot_check.eq.True)then

 if (paleo .eq. "True") then
	startRegion = nreg-3		; N. + S. Hemisphere land + global
 else
	startRegion = 0
 end if

 do region=startRegion,nreg-1

; print("Plotting " + ps_id(region))
; print ("=========================================")
; print ("Time: "+systemfunc("date") )
; print ("=========================================")

; open ps file for plotting
    wks = gsn_open_wks(plot_type,wkdir + "set6_" + plot_name + "_" + ps_id(region))

    pres                     = True                   ; panel only resources
; create common legend 
    pres@txString            = ptitstr(region)+boxstr(region)  ; common title

; each regional plot contains all variables, so loop over vars
  compare = "model"
  if (rank .eq. 3) then
     plot = new(nvars,graphic)
     do i = 0,nvars-1

;      print("Processing variable:  " + vars(i) )
;      print ("=========================================")
;      print ("Time: "+systemfunc("date") )
;      print ("=========================================")

     	   data  = new((/2,nyrs/),"double")
	   if (vcheck1(i) .eq. True) then
           	x1 = array1(i,offset1:(offset1+nyrs1-1),:,:)
           	var_plot1 = regional_values_set6(x1,region,area1,fland1,scale_type(i),\
	  		    regions_file,time1,nyrs1,compare)
           	data(0,offset1:(offset1+nyrs1-1) ) = var_plot1
           end if
	   if (vcheck2(i) .eq. True) then
           	x2 = array2(i,offset2:(offset2+nyrs2-1),:,:)
           	var_plot2 = regional_values_set6(x2,region,area2,fland2,scale_type(i),\
		  	    regions_file,time2,nyrs2,compare)
           	data(1,offset2:(offset2+nyrs2-1) ) = var_plot2
	   end if
           if (p .eq. 0) then
              res@tiYAxisString      = ""     ; units already in main title
           else
              res@tiYAxisString      = units(i)
           end if
           res@gsnCenterString    = titstr(i)

;      print("Complete computing regional_values:  " + vars(i) )
;      print ("=========================================")
;      print ("Time: "+systemfunc("date") )
;      print ("=========================================")

           if (x2y2Plot .eq. 1) then

                ymin = 0.0
                ymax = 0.0
                if (all(ismissing(data(0,:)) .and. all(ismissing(data(1,:))))) then
                        ymin = 0.0
                        ymax = 0.0
                else
                    if (all(ismissing(data(1,:)))) then
                        ymin = doubletofloat(min(data(0,:)))
                        ymax = doubletofloat(max(data(0,:)))
                    else
                        if (all(ismissing(data(0,:)))) then
                            ymin = doubletofloat(min(data(1,:)))
                            ymax = doubletofloat(max(data(1,:)))
                        else
                            ymin = doubletofloat(min( (/data(0,:),data(1,:)/) ))
                            ymax = doubletofloat(max( (/data(0,:),data(1,:)/) ))
                        end if
                    end if
                end if

		minvalue = 0.001
		yrange = ymax-ymin
                if (ymin .eq. ymax .or. fabs(yrange) .lt. minvalue)
                        pad = 0.01
                   	ypad = ymin * pad
                else
                        pad = 0.05
	           	ypad = yrange * pad
                end if
                ymin = ymin - ypad
                ymax = ymax + ypad
		delete(yrange)

                res1    = True
                res1@gsnFrame                     = False
      	    	res1@gsnDraw                 	  = False

                res1@tiMainString                 = titstr(i)
                res1@tiXAxisOn                    = False
                res1@trXMinF                      = t1(0)
                res1@trXMaxF                      = t1(nyrs-1)
                res1@trYMinF                      = ymin
                res1@trYMaxF                      = ymax
                res1@tmXMajorGrid                 = True
                res1@tmXMajorGridThicknessF       = 0.5
                res1@tmXMajorGridLineDashPattern  = 2
                res1@tmYROn                       = False
                res1@tmYRLabelsOn                 = False
                res1@xyLineColor                  = "Red"
                res1@tmXBLabelFontColor           = res1@xyLineColor
                res1@xyDashPattern                = 0
                res1@xyLineThicknessF             = 1
                res1@tiYAxisString                = vars(i)
                res1@pmLegendDisplayMode          = "Never"
                res1@pmLegendSide                 = "Bottom"
                res1@pmLegendParallelPosF         = 0.50
                res1@pmLegendOrthogonalPosF       = 0.02
                res1@pmLegendWidthF               = 0.25
                res1@pmLegendHeightF              = 0.08
                res1@lgLabelFontHeightF           = 0.020
                res1@lgPerimOn                    = True
                res1@xyExplicitLegendLabels       = cases
      	    	res1@vpHeightF              	  = 0.4
      	    	res1@vpWidthF               	  = 0.8

                res2    = True
      	    	res2@gsnDraw                 	  = False
                res2@tiXAxisOn                    = False
                res2@gsnFrame                     = False
                res2@trXMinF                      = t2(0)
                res2@trXMaxF                      = t2(nyrs-1)
                res2@trYMinF                      = ymin
                res2@trYMaxF                      = ymax
                res2@tmYROn                       = False
                res2@tmYRLabelsOn                 = False
                res2@xyLineColor                  = "blue"
                res2@tmXTLabelFontColor           = "blue"
                res2@xyDashPattern                = 2
                res2@gsnRightString               = units(i)

                res2@xyLineThicknessF             = 2
                plot(i) = gsn_csm_x2y2(wks,t1,t2,data(0,:),data(1,:),res1,res2)
                delete(res1)
                delete(res2)
		delete(ymin)
		delete(ymax)
	   else
	   	plot(i) = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data,res)
	   end if

;      print("Complete plot:  " + vars(i) )
;      print ("=========================================")
;      print ("Time: "+systemfunc("date") )
;      print ("=========================================")

      end do	; end variable loop
      delete(data)
   else
	   delete(pres@txString)
    	   pres@txString   = titstr(0) + "~C~" + ptitstr(region)+boxstr(region)  ; common title
	   nlevLimit = 10		; prescribe 10 soil layers 
     	   data3 = new((/2,nyrs,nlevLimit/),"double")
	   do j = 0,nlevLimit-1
	      if (vcheck1(0) .eq. True) then
                x1 = array1_3(offset1:(offset1+nyrs1-1),j,:,:)
           	var_plot1 = regional_values_set6(x1,region,area1,fland1,scale_type(0),\
		  		regions_file,time1,nyrs1,compare)
                data3(0,offset1:(offset1+nyrs1-1),j) = var_plot1
              end if
	      if (vcheck2(0) .eq. True) then
                x2 = array2_3(offset2:(offset2+nyrs2-1),j,:,:)
                var_plot2 = regional_values_set6(x2,region,area2,fland2,scale_type(0),\
		  		regions_file,time2,nyrs2,compare)
                data3(1,offset2:(offset2+nyrs2-1),j) = var_plot2
               end if
            end do
;     	    if (all(ismissing(var_plot1)) ) then
;     		  vcheck1(i) = False
;           end if
;           if (all(ismissing(var_plot2)) ) then
;     		  vcheck2(i) = False
;           end if

     	    plot = new(nlevLimit,graphic)
      	    res@tiMainOn               = False
      	    res@gsnDraw                = False
      	    res@gsnFrame               = False
      	    res@tiXAxisOn             = False
      	    res@tiYAxisFontHeightF     = 0.030
            res@tiYAxisString          = array1_3@units
      	    res@txFontHeightF          = 0.030
      	    res@tmXBLabelFontHeightF   = 0.030
      	    res@tmYLLabelFontHeightF   = 0.030
      	    res@pmLegendDisplayMode    = "Never"
      	    res@vpHeightF              = 0.4
      	    res@vpWidthF               = 0.8
      	    do k=0,nlevLimit-1
        		res@gsnCenterString           = "Layer " + (k+1)
         		if (x2y2Plot .eq. 1) then
				ymin = 0.0
				ymax = 0.0

                		if (all(ismissing(data3(0,:,k)) .and. all(ismissing(data3(1,:,k))))) then
                        		ymin = 0.0
                        		ymax = 0.0
                		else
                    		   if (all(ismissing(data3(1,:,k)))) then
                        		ymin = doubletofloat(min(data3(0,:,k)))
                        		ymax = doubletofloat(max(data3(0,:,k)))
                    	 	  else
                        	      if (all(ismissing(data3(0,:,k)))) then
                            	      	ymin = doubletofloat(min(data3(1,:,k)))
                            	        ymax = doubletofloat(max(data3(1,:,k)))
                        	      else
                            		ymin = doubletofloat(min( (/data3(0,:,k),data3(1,:,k)/) ))
                            		ymax = doubletofloat(max( (/data3(0,:,k),data3(1,:,k)/) ))
                        	      end if
                                  end if
                	        end if
                		if (ismissing(ymin) .or. ismissing(ymax) ) then
                        		print("FATAL - missing ymin and ymax in set 6")
                        		exit
                		end if
		
                		minvalue = 0.001
                		yrange = ymax-ymin
                		if (ymin .eq. ymax .or. fabs(yrange) .lt. minvalue)
                        		pad = 0.01
                        		ypad = ymin * pad
                		else
                        		pad = 0.05
                        		ypad = yrange * pad
                		end if
                		ymin = ymin - ypad
                		ymax = ymax + ypad

                		res1    = True
      	    			res1@gsnDraw                 	  = False
                		res1@gsnFrame                     = False
		
                		res1@tiYAxisString                = vars
                		res1@tiYAxisFontHeightF           = 0.030
                		res1@tiMainString                 = "Layer " + (k+1)
                		res1@tiMainFontHeightF            = 0.030
                		res1@tiXAxisOn                    = False
                		res1@trXMinF                      = t1(0)
                		res1@trXMaxF                      = t1(nyrs-1)
                		res1@trYMinF                      = ymin
                		res1@trYMaxF                      = ymax
                		res1@tmXMajorGrid                 = True
                		res1@tmXMajorGridThicknessF       = 0.5
                		res1@tmXMajorGridLineDashPattern  = 2
                		res1@tmYROn                       = False
                		res1@tmYRLabelsOn                 = False
                		res1@xyLineColor                  = "Red"
                		res1@tmXBLabelFontColor           = res1@xyLineColor
                		res1@xyDashPattern                = 0
                		res1@xyLineThicknessF             = 1
                		res1@pmLegendDisplayMode          = "Never"
                		res1@pmLegendSide                 = "Bottom"
                		res1@pmLegendParallelPosF         = 0.50
                		res1@pmLegendOrthogonalPosF       = 0.02
                		res1@pmLegendWidthF               = 0.25
                		res1@pmLegendHeightF              = 0.08
                		res1@lgLabelFontHeightF           = 0.020
                		res1@lgPerimOn                    = True
                		res1@xyExplicitLegendLabels       = cases
      	    			res1@vpHeightF              	  = 0.4
      	    			res1@vpWidthF               	  = 0.8
		
                		res2    = True
                                res2@tiXAxisOn                    = False
      	    			res2@gsnDraw                 	  = False
                		res2@gsnFrame                     = False
                		res2@trXMinF                      = t2(0)
                		res2@trXMaxF                      = t2(nyrs-1)
                		res2@trYMinF                      = ymin
                		res2@trYMaxF                      = ymax
                		res2@tmYROn                       = False
                		res2@tmYRLabelsOn                 = False
                		res2@xyLineColor                  = "blue"
                		res2@tmXTLabelFontColor           = "blue"
                		res2@xyDashPattern                = 2
                                res2@gsnRightString               = units_layer
		
                		res2@xyLineThicknessF             = 2
                		plot(k) = gsn_csm_x2y2(wks,t1,t2,data3(0,:,k),data3(1,:,k),res1,res2)
                		delete(res1)
                		delete(res2)
			else
        			plot(k) = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data3(:,:,k),res) 
			end if
      	     end do
      	     delete(data3)
   end if

   if (isvar ("var_plot1") ) then
   	delete(var_plot1)
   end if
   if (isvar ("var_plot2") ) then
   	delete(var_plot2)
   end if


;*************************************************
;  gsnpanel takes this plot array and massages it and puts it onto page for us.
;*************************************************
      pres@gsnFrame            = False                  ; don't advance yet so add legend
      pres@gsnPanelBottom      = 0.14                   ; save space for legend
      pres@gsnPanelCenter      = False

      lgres                    = True                   ; allow legend resources
      lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
      lgres@lgPerimOn          = False
      lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
      lgres@lgLabelFontHeightF = 0.025                  ; increase font height
      lgres@lgLineLabelStrings = (/"",""/)              ; no labels in lines
      lgres@lgAutoManage       = False                  ; must have to adjust fonts
      lgres@vpWidthF           = 0.55
      lgres@vpHeightF          = 0.10
      pres@gsnPaperOrientation = "Portrait"
      pres@gsnMaximize         = True                   ; make as large as possible

      plotFlag = False
      if (p .eq. 2) then                                ; turbf (9)
            pres@gsnPanelRowSpec     = True
            pres@gsnPanelCenter      = False
            gsn_panel(wks,plot,(/2,2,2,2,1/),pres)
            legend = create "Legend" legendClass wks
              "vpXF"                     : 0.525
              "vpYF"                     : 0.25
              "vpWidthF"                 : 0.20
              "vpHeightF"                : 0.08
              "lgPerimOn"                : True
              "lgItemCount"              : 2
              "lgLabelsOn"               : True
              "lgPerimOn"                : False
              "lgLineLabelsOn"           : False
              "lgLabelStrings"           : cases
              "lgDashIndexes"            : (/0,1/)
              "lgLineColors"             : (/"red","blue"/)
              "lgMonoLineLabelFontColor" : True
              "lgAutoManage"             : False
              "lgLabelFontHeightF"       : 0.01
              "lgLabelPosition"          : "Center"
              "lgLabelAlignment"         : "AboveItems"
            end create
            draw(legend)
	    frame(wks)
            delete(legend)
	    plotFlag = True
      end if
      if (p .eq. 3) then                                ; cnFlx (10)
            pres@gsnPanelRowSpec     = True
            pres@gsnPanelCenter      = False
            gsn_panel(wks,plot,(/2,2,2,2,2/),pres)
            legend = create "Legend" legendClass wks
              "vpXF"                     : 0.45
              "vpYF"                     : 0.10
              "vpWidthF"                 : 0.20
              "vpHeightF"                : 0.08
              "lgPerimOn"                : True
              "lgItemCount"              : 2
              "lgLabelsOn"               : True
              "lgPerimOn"                : False
              "lgLineLabelsOn"           : False
              "lgLabelStrings"           : cases
              "lgDashIndexes"            : (/0,1/)
              "lgLineColors"             : (/"red","blue"/)
              "lgMonoLineLabelFontColor" : True
              "lgAutoManage"             : False
              "lgLabelFontHeightF"       : 0.01
              "lgLabelPosition"          : "Center"
              "lgLabelAlignment"         : "AboveItems"
            end create
            draw(legend)
	    frame(wks)
            delete(legend)
	    plotFlag = True
      end if
      if (p .eq. 9 .or. p .eq. 10) then   ; TotalSoilIce/TotalSoilH2O, TotalSnowH2O/TotalSnowIce
            pres@gsnPanelRowSpec = True
      	    gsn_panel(wks,plot,(/1,1/),pres)       	; draw panel plot
            gsn_legend_ndc(wks,2,cases,0.225,0.12,lgres)   
	    frame(wks)
	    plotFlag = True
      end if
      if (plotFlag .eq. False)
            pres@gsnPanelCenter  = True
            pres@gsnPanelRowSpec = False
      	    gsn_panel(wks,plot,(/nplotsPerCol,2/),pres)       ; draw panel plot
            if (p.ne.0) then
               gsn_legend_ndc(wks,2,cases,0.225,0.10,lgres)   
	       frame(wks)
            else
               gsn_legend_ndc(wks,2,cases,0.225,0.175,lgres)
	       frame(wks)
            end if
      end if
 
;;      frame(wks)

   end do	;  end of region loop
 end if		;  end of plot_check loop

   if(isvar("scale_type") ) then
   	delete(scale_type)
   end if
   if(isvar("x1") ) then
      delete(x1)
   end if
   if(isvar("x2") ) then
      delete(x2)
   end if
   if(isvar("vars") ) then
      delete(vars)
   end if
   if(isvar("vcheck1") ) then
      delete(vcheck1)
   end if
   if(isvar("vcheck2") ) then
      delete(vcheck2)
   end if
   if(isvar("array1") ) then
      delete(array1)
   end if
   if(isvar("array2") ) then
      delete(array2)
   end if
   if(isvar("array1_3") ) then
      delete(array1_3)
   end if
   if(isvar("array2_3") ) then
      delete(array2_3)
   end if
   if(isvar("scale_type") ) then
      delete(scale_type)
   end if
   if(isvar("plot") ) then
      delete(plot)
   end if
   if(isvar("units") ) then
      delete(units)
   end if
   if(isvar("long_name") ) then
      delete(long_name)
   end if
   if(isvar("titstr") ) then
      delete(titstr)
   end if
  end do   ; end plot loop

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
 res@mpGridLonSpacingF   = 60.0            ; Set lon grid spacing
 res@mpGridLatSpacingF    = 30.0           ; Set lat grid spacing
 res@mpFillOn             =  False
 res@mpOutlineOn          =  True
 res@mpGridAndLimbOn      =  True
 res@mpGridLineDashPattern =  2            ; Set grid line dash pattern (dash)
 res@mpGridLineThicknessF   = 0.5          ; Set grid line thickness
 sstr=(/" "/)
 res@gsnMaximize = True
 res@cnLevelSelectionMode =  "ExplicitLevels"
 wks = gsn_open_wks(plot_type,wkdir+"set6_reg_all")
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
   wks = gsn_open_wks(plot_type,wkdir+"set6_reg_"+ps_id(ar))
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
  filo  = wkdir +"/set6_error_file"                   
  system("/bin/rm -f " + filo)  

end
