; Adapted from tables.ncl (KOleson)
; Revision Author:  Nan Rosenbloom Spring 2005
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/functions_tables.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
;************************************************
begin
 print ("=========================================")
 print ("Starting:  set_5.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
   path     = getenv("DIAG_CODE")
   inputdir = getenv("INPUT_FILES")
   resdir   = getenv("DIAG_RESOURCES")
   wkdir    = getenv("WKDIR")
   ptmpdir  = getenv("PTMPDIR_1")
   obsdata  = getenv("OBS_DATA")
;;   cn       = stringtointeger(getenv("CN"))
;;   casa     = stringtointeger(getenv("CASA"))
;; useCommon1 = stringtointeger(getenv("UseCommonName_1"))
   cn       = getenv("CN")
   casa     = getenv("CASA")
 useCommon1 = getenv("UseCommonName_1")


;***********************************************
; import regional information
;***********************************************

 regions_file = addfile(resdir +"/region_definitions.nc","r")
 box_s   = regions_file->BOX_S
 nreg    = dimsizes(box_s)    ; number of regions
 tmp     = regions_file->PS_ID
 ps_id   = charactertostring(tmp)
 delete(tmp)
 tmp     = regions_file->PTITSTR
 ptitstr = charactertostring(tmp)
 delete(tmp)
 tmp   = regions_file->BOXSTR
 boxstr = charactertostring(tmp)
 delete(tmp)

;*************************************************
; main loop
;*************************************************

; 1 regional, 2 global (carbon-nitrogen-fire, biogeophysics)
nplots = 4
daysInYear = 365

; loop over plots
do p=0,nplots-1

  if (p .eq. 0) then 
	fileName = "set5_hydReg.txt"
	plot_name  = "hydReg"
	title      = (/"DIAG SET 5: REGIONAL HYDROLOGIC CYCLE OVER LAND"/)
	Dtitle     = (/"DIAG SET 5: REGIONAL HYDROLOGIC CYCLE OVER LAND - DIFFERENCE (case1 - case2)"/)
  end if
  if (p .eq. 1) then
	fileName = "set5_clm.txt"
	plot_name  = "clm"
	title      = (/"DIAG SET 5: CLM ANNUAL MEANS OVER LAND"/)
	Dtitle     = (/"DIAG SET 5: CLM ANNUAL MEANS OVER LAND - DIFFERENCE (case1 - case2)"/)
  end if
  if (p .eq. 2) then
     if (cn .eq. 1) then
        inputdir = wkdir
	fileName = "masterCN_set5.txt"
	plot_name  = "cn"
	title      = (/"DIAG SET 5: CN ANNUAL MEANS OVER LAND"/)
	Dtitle     = (/"DIAG SET 5: CN ANNUAL MEANS OVER LAND - DIFFERENCE (case1 - case2)"/)
     else
	continue
     end if
  end if
  if (p .eq. 3) then
     if (casa .eq. 1) then
        inputdir = wkdir
	fileName = "masterCASA_set5.txt"
	plot_name  = "casa"
	title      = (/"DIAG SET 5: CASA ANNUAL MEANS OVER LAND"/)
	Dtitle     = (/"DIAG SET 5: CASA ANNUAL MEANS OVER LAND - DIFFERENCE (case1 - case2)"/)
     else
	continue
     end if
  end if
  print("Now creating table #" + p + " " + title)

;----------------------------------------------------------
; read in file and parse into variables
;----------------------------------------------------------
  tmp = stringtocharacter(asciiread(inputdir+"/"+fileName,-1,"string"))
  nvars = dimsizes(tmp(:,0))
  scale_type = new(nvars,"string")
  vars       = new(nvars,"string")
  c13Flag    = new(nvars,"string")
  c14Flag    = new(nvars,"string")
  obsFlag    = new(nvars,"integer")
  resoln     = new(nvars,"integer")
  obsFlag    = 0
  do i=0,nvars-1
  	scale_type(i) = charactertostring(tmp(i,0:12))
    	vars(i)       = charactertostring(tmp(i,16:))
        c13Flag(i)    = charactertostring(tmp(i,16:19))     ; derived variable prefix
        c14Flag(i)    = charactertostring(tmp(i,16:19))     ; derived variable prefix
  end do
  delete(tmp)


;----------------------------------------------------------
; open cases
;----------------------------------------------------------

    cases = new(2,"string")
    if (useCommon1 .eq. "True") then
        name1  = "commonName_1"
    else
        name1  = "caseid_1"
    end if
    name11    = "prefix_1"
    cases(0)  = getenv(name1)
    cases(1)  = "Obs"
    prefix1   = getenv(name11)
    in1       = addfile(ptmpdir+"/"+prefix1 +"_ANN_climo.nc","r")
    print ("DEBUG file in1 = "+ptmpdir+"/"+prefix1+"_ANN_climo.nc")
    if (isatt(in1,"yrs_averaged")) then
        yrs_avg1  = in1@yrs_averaged
	label1 = cases(0) + "  (yrs "+yrs_avg1+")"
    end if
    nyrs      = getfilevardimsizes(in1, "time")
    landfrac1 = in1->landfrac
    area1     = in1->area		; read in variable with metadata
    area1     = area1 * 1.e6		; convert from km2 to m2
    lat1      = in1->lat
    time1     = in1->time
    lon1      = in1->lon
    nlat1     = dimsizes(lat1)
    nlon1     = dimsizes(lon1)
    if (lon1(0) .ge. 0) then
           area1     = lonFlip(area1)
           landfrac1 = lonFlip(landfrac1)
    end if

    label2    = "Obs"
    ptr_wm    = addfile(obsdata+"/0_5_WILLMOTT_ALLMONS_climo.nc","r") ; precip
    lat2      = ptr_wm->lat
    nlat2     = dimsizes(lat2)
    lon2      = ptr_wm->lon
    nlon2     = dimsizes(lon2)
    ptr_grdc  = addfile(obsdata+"/0_5_GRDC_ALLMONS_climo.nc","r")    ; runoff

    landmask2 = new((/nvars,nlat2,nlon2/),"double")
    area2     = new((/nvars,nlat2,nlon2/),"double")

    ptr_swe   = addfile(obsdata+"/CMC_SWE_ALLMONS_climo.100318.nc","r")          ; SWE
    ptr_sd    = addfile(obsdata+"/CMC_SNOWD_ALLMONS_climo.100318.nc","r")        ; SNOWDP
    ptr_scf   = addfile(obsdata+"/NOAA_AVHRR_SNOWF_ALLMONS_climo.100318.nc","r") ; FSNO
    lat3      = ptr_swe->lat
    lon3      = ptr_swe->lon
    nlat3     = dimsizes(lat3)
    nlon3     = dimsizes(lon3)
    landmask3 = new((/nvars,nlat3,nlon3/),"double")
    area3     = new((/nvars,nlat3,nlon3/),"double")

    ptr_alb    = addfile(obsdata+"/T42_MODIS_ALLMONS_climo.070523.nc","r") ; VBSA, NBSA, VWSA, NWSA
    lat4      = ptr_alb->lat
    lon4      = ptr_alb->lon
    nlat4     = dimsizes(lat4)
    nlon4     = dimsizes(lon4)
    landmask4 = new((/nvars,nlat4,nlon4/),"double")
    area4     = new((/nvars,nlat4,nlon4/),"double")

    ptr_lai   = addfile(obsdata+"/MODIS_LAI_ANN_climo.nc","r") ; TLAI
    lat5      = ptr_lai->lat
    lon5      = ptr_lai->lon
    nlat5     = dimsizes(lat5)
    nlon5     = dimsizes(lon5)
    landmask5 = new((/nvars,nlat5,nlon5/),"double")
    area5     = new((/nvars,nlat5,nlon5/),"double")
 
    ptr_gpp   = addfile(obsdata+"/MR_GPP_0.9x1.25_ANN_climo.nc","r") ; FPSN or GPP
    lat6      = ptr_gpp->lat
    lon6      = ptr_gpp->lon
    nlat6     = dimsizes(lat6)
    nlon6     = dimsizes(lon6)
    landmask6 = new((/nvars,nlat6,nlon6/),"double")
    area6     = new((/nvars,nlat6,nlon6/),"double")

    ptr_lhf   = addfile(obsdata+"/MR_LHF_0.9x1.25_ANN_climo.nc","r") ; LHEAT
    lat7      = ptr_lhf->lat
    lon7      = ptr_lhf->lon
    nlat7     = dimsizes(lat7)
    nlon7     = dimsizes(lon7)
    landmask7 = new((/nvars,nlat7,nlon7/),"double")
    area7     = new((/nvars,nlat7,nlon7/),"double")

 months = 12
 mm = ispan(0,months-1,1)
 vv = ispan(0,nvars-1,1)

;**************************
; Variable loop ----------- read both cases of each variable 
;			    into memeory so they can be printed on the same line.
;**************************
  array1    = new((/nvars, nlat1, nlon1/),"double")
  array2    = new((/nvars, nlat2, nlon2/),"double")
  array3    = new((/nvars, nlat3, nlon3/),"double")
  array4    = new((/nvars, nlat4, nlon4/),"double")
  array5    = new((/nvars, nlat5, nlon5/),"double")
  array6    = new((/nvars, nlat6, nlon6/),"double")
  array7    = new((/nvars, nlat7, nlon7/),"double")
  array13c1 = new((/nvars/),"double")
  array14c1 = new((/nvars/),"double")

; read all variables into memory first and stuff them into two arrays (2 cases)
  varLabelsR = new(nvars,"string")
  varLabelsA = new(nvars,"string")
  varUnits   = new(nvars,"string")
  vLongNames = new(nvars,"string")
  if(isvar("plot_check")) then
	delete(plot_check)
  end if
  plot_check = new((/nvars/),"logical")

  do i=0,nvars-1 
      print("processing variable " + vars(i) )
      plot_check(i) = True

; check for variables in case 1
      info = var_init(vars(i))
      filevar = vars(i)
      if(isfilevar(in1,filevar) .and. info@derivedVariable .eq. False)then
          if (c13Flag(i) .eq. "C13_") then
             x1 = derive_del13C(vars(i),in1,scale_type(i),nyrs,5)
             if(all(ismissing(x1)))then
                print("variable "+ vars(i)+ " values are all missing")
                plot_check(i) = False
             end if
          else
             if (c14Flag(i) .eq. "C14_") then
                x1 = derive_del14C(vars(i),in1,scale_type(i),nyrs,5)
                if(all(ismissing(x1)))then
                   print("variable "+ vars(i)+ " values are all missing")
                   plot_check(i) = False
                end if
             else
                x1 = in1->$filevar$
             end if
	  end if
	  delete(filevar)
      else
          if (info@derivedVariable .eq. True) then
              x1 = derive_land(  vars(i),in1)
      	      if(all(ismissing(x1)))then
                    print("variable "+ vars(i)+ " values are all missing")
		    plot_check(i) = False
              end if
           else
              print("variable "+ vars(i)+ " is not a defined variable.")
	      plot_check(i) = False
              continue
           end if
      end if

;read in observations (if present)

      if (isvar("x2")) then
	  delete(x2)
      end if
      if (isvar("x3")) then
	  delete(x3)
      end if
      if (isvar("x4")) then
	  delete(x4)
      end if
      if (isvar("x5")) then
	  delete(x5)
      end if
      if (isvar("x6")) then
	  delete(x6)
      end if
      if (isvar("x7")) then
	  delete(x7)
      end if
      if (vars(i) .eq. "TSA" ) then
        tmp        = ptr_wm->$vars(i)$
	x2 = dim_avg(tmp(lat|:,lon|:,month|:))
        l2 = ptr_wm->datamask
        a2 = ptr_wm->weight
        obsFlag(i) = 1;
        resoln(i)  = 2
	delete(tmp)
      else
        if (vars(i) .eq. "PREC" ) then
           tmp      = ptr_wm->PREC
	   x2 = dim_avg(tmp(lat|:,lon|:,month|:))
	   x2 = x2 * 365.
           l2 = ptr_wm->datamask
           a2 = ptr_wm->weight
           obsFlag(i) = 1;
           resoln(i)  = 2
	   delete(tmp)
        else
          if (vars(i) .eq. "TOTRUNOFF" ) then
             tmp    = ptr_grdc->RUNOFF
	     x2 = dim_avg(tmp(lat|:,lon|:,month|:))
             l2 = ptr_grdc->datamask
             a2 = ptr_grdc->weight
             obsFlag(i) = 1;
             resoln(i)  = 2
	     delete(tmp)
          else
              if (vars(i) .eq. "FSNO" ) then
                tmp = ptr_scf->SCF
	        x3 = dim_avg(tmp(lat|:,lon|:,time|:))
                x3 = x3 * 0.01            ; convert from percent to 0-1
                l3 = ptr_scf->landmask 
                lf = ptr_scf->landfrac 
                a3 = ptr_scf->weight
                x3@_FillValue = 1e30
                obsFlag(i) = 1;
                resoln(i)  = 3
	        delete(tmp)
              else
                  if (vars(i) .eq. "H2OSNO" ) then
                    tmp = ptr_swe->SWE
	            x3 = dim_avg(tmp(lat|:,lon|:,time|:))
                    l3 = ptr_swe->landmask 
                    lf = ptr_swe->landfrac 
                    a3 = ptr_swe->weight
                    x3@_FillValue = 1e30
                    obsFlag(i) = 1;
                    resoln(i)  = 3
	            delete(tmp)
                  else
                    if (vars(i) .eq. "SNOWDP") then
                       tmp = ptr_sd->SNOWD
	               x3 = dim_avg(tmp(lat|:,lon|:,time|:))
                       l3 = ptr_sd->landmask 
                       lf = ptr_sd->landfrac 
                       a3 = ptr_sd->weight
                       x3@_FillValue = 1e30
                       obsFlag(i) = 1;
                       resoln(i)  = 3
	               delete(tmp)
                    else
                      if (vars(i) .eq. "VBSA") then
                          tmp = ptr_alb->VBSA
	                  x4 = dim_avg(tmp(lat|:,lon|:,time|:))
                          l4 = ptr_alb->LANDMASK 
                          lf = ptr_alb->LANDFRAC 
                          a4 = ptr_alb->weight
                          x4@_FillValue = 1e30
                          obsFlag(i) = 1;
                          resoln(i)  = 4
	                  delete(tmp)
                      else
                        if (vars(i) .eq. "NBSA") then
                             tmp = ptr_alb->NBSA
	                     x4 = dim_avg(tmp(lat|:,lon|:,time|:))
                             l4 = ptr_alb->LANDMASK 
                             lf = ptr_alb->LANDFRAC 
                             a4 = ptr_alb->weight
                             x4@_FillValue = 1e30
                             obsFlag(i) = 1;
                             resoln(i)  = 4
	                     delete(tmp)
                        else
                          if (vars(i) .eq. "VWSA") then
                                tmp = ptr_alb->VWSA
	                        x4 = dim_avg(tmp(lat|:,lon|:,time|:))
                                l4 = ptr_alb->LANDMASK 
                                lf = ptr_alb->LANDFRAC 
                                a4 = ptr_alb->weight
                                x4@_FillValue = 1e30
                                obsFlag(i) = 1;
                                resoln(i)  = 4
	                        delete(tmp)
                          else
                            if (vars(i) .eq. "NWSA") then
                                tmp = ptr_alb->NWSA
	                        x4 = dim_avg(tmp(lat|:,lon|:,time|:))
                                l4 = ptr_alb->LANDMASK 
                                lf = ptr_alb->LANDFRAC 
                                a4 = ptr_alb->weight
                                x4@_FillValue = 1e30
                                obsFlag(i) = 1;
                                resoln(i)  = 4
	                        delete(tmp)
			    else
                              if (vars(i) .eq. "TLAI") then
                                  x5 = ptr_lai->TLAI
                                  l5 = ptr_lai->landmask
                                  a5 = ptr_lai->area
                                  x5@_FillValue = 1e36
                                  obsFlag(i) = 1;
                                  resoln(i)  = 5
                              else
                                if ((vars(i) .eq. "FPSN" .and. cn .eq. 0) .or. vars(i) .eq. "GPP") then
                                    x6 = ptr_gpp->GPP  ; gC/m2/day
                                    x6@_FillValue = -9999.
                                    grams2Pgrams  = 1e-15
                                    x6 = x6 * daysInYear * grams2Pgrams
                                    l6 = ptr_gpp->datamask
                                    a6 = ptr_gpp->area
                                    km2tom2 = 1.e6
                                    a6 = a6 * km2tom2
                                    obsFlag(i) = 1;
                                    resoln(i)  = 6
                                else
                                    if (vars(i) .eq. "LHEAT") then
                                        x7 = ptr_lhf->LHF
                                        l7 = ptr_lhf->datamask
                                        a7 = ptr_lhf->area
                                        x7@_FillValue = -9999.
                                        km2tom2 = 1.e6
                                        a7 = a7 * km2tom2
                                        obsFlag(i) = 1;
                                        resoln(i)  = 7
                                    else
             		      	        obsFlag(i) = 0;
             			        resoln(i)  = 1;
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

      if (obsFlag(i) .eq. 1) then                           ; process variables with observed data
       	if (isvar("x2")) then
          x2 = catchNaN(x2)
          x2!0    = "lat"
          x2&lat  = lat2
          x2!1    = "lon"
          x2&lon  = lon2
          a2!0    = "lat"
          a2!1    = "lon"
          l2!0    = "lat"
          l2!1    = "lon"
          a2&lat  = lat2
          a2&lon  = lon2
          l2&lat  = lat2
          l2&lon  = lon2
          if (min(x2&lon) .ge. 0) then
               x2 = lonFlip(x2)
               a2 = lonFlip(a2)
               l2 = lonFlip(l2)
          end if
          array2(i,:,:)    = x2           ; Wrapper fcn that copies coord Vars
          landmask2(i,:,:) = l2           
          area2(i,:,:)     = a2           
          delete(l2)
          delete(a2)
          delete(x2)
	end if
       	if (isvar("x3")) then
          x3 = catchNaN(x3)
          x3!0    = "lat"
          x3&lat  = lat3
          x3!1    = "lon"
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
               a3 = lonFlip(a3)
               l3 = lonFlip(l3)
          end if

          ; mask out fractional grid cells.
          l31d = ndtooned(l3)
          lf1d = ndtooned(lf)
          l31d = mask(l31d, lf1d .ne. 1, False)
          l3   = onedtond(l31d,(/nlat3,nlon3/))
          array3(i,:,:)    = x3           ; Wrapper fcn that copies coord Vars
          landmask3(i,:,:) = l3           
          area3(i,:,:)     = a3           
          delete(l3)
          delete(a3)
	  delete(lf)
	  delete(l31d)
	  delete(lf1d)
	end if
       	if (isvar("x4")) then
          x4 = catchNaN(x4)
          x4!0    = "lat"
          x4&lat  = lat4
          x4!1    = "lon"
          x4&lon  = lon4
          a4!0    = "lat"
          a4!1    = "lon"
          l4!0    = "lat"
          l4!1    = "lon"
          a4&lat  = lat4
          a4&lon  = lon4
          l4&lat  = lat4
          l4&lon  = lon4
          if (min(x4&lon) .ge. 0) then
               x4 = lonFlip(x4)
               a4 = lonFlip(a4)
               l4 = lonFlip(l4)
          end if
          array4(i,:,:)    = x4           ; Wrapper fcn that copies coord Vars
          landmask4(i,:,:) = l4
          area4(i,:,:)     = a4           
          delete(l4)
          delete(a4)
          delete(x4)
	end if
        if (isvar("x5")) then
          x5 = catchNaN(x5)
          x5!0    = "lat"
          x5&lat  = lat5
          x5!1    = "lon"
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
               a5 = lonFlip(a5)
               l5 = lonFlip(l5)
          end if
          array5(i,:,:)    = x5           ; Wrapper fcn that copies coord Vars
          landmask5(i,:,:) = l5
          area5(i,:,:)     = a5           
          delete(l5)
          delete(a5)
          delete(x5)
	end if
        if (isvar("x6")) then
          x6 = catchNaN(x6)
          x6!0    = "lat"
          x6&lat  = lat6
          x6!1    = "lon"
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
               a6 = lonFlip(a6)
               l6 = lonFlip(l6)
          end if
          array6(i,:,:)    = x6           ; Wrapper fcn that copies coord Vars
          landmask6(i,:,:) = l6
          area6(i,:,:)     = a6           
          delete(l6)
          delete(a6)
          delete(x6)
	end if
       	if (isvar("x7")) then
          x7 = catchNaN(x7)
          x7!0    = "lat"
          x7&lat  = lat7
          x7!1    = "lon"
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
               a7 = lonFlip(a7)
               l7 = lonFlip(l7)
          end if
          array7(i,:,:)    = x7           ; Wrapper fcn that copies coord Vars
          landmask7(i,:,:) = l7
          area7(i,:,:)     = a7           
          delete(l7)
          delete(a7)
          delete(x7)
	end if
      end if

      ; catch NaNs
      x1 = catchNaN(x1)
      if (isdim(x1,"lon")) then
      	if (min(x1&lon) .ge. 0) then
             x1     = lonFlip(x1)
        end if
      end if

      info = var_init(vars(i))

      x1 = scale_var(x1,scale_type(i),info)
      varLabelsR(i) = vars(i) + "("+x1@units+")" 
      varLabelsA(i) = vars(i) + "("+x1@units+")" + " " + x1@long_name

      vLongNames(i) = x1@long_name
      varUnits(i) = "("+x1@units+")"

      if (c13Flag(i) .eq. "C13_") then
      	array13c1(i) = x1
      else
        if (c14Flag(i) .eq. "C14_") then
          array14c1(i) = x1
        else
      	  array1(i,:,:) = x1
        end if
      end if
 
      delete(x1)

   end do 	; end variable loop

;**********************************
; prepare to make tables
;**********************************

tablename = wkdir+"set5_"+plot_name+".txt"
dtablename = wkdir+"set5_D"+plot_name+".txt"

if (p .eq. 0) then	; regional Table
   startNumber = 0
   regional   = True
   AB = new((/nvars,nreg,3/),"double")	; 3()=case1, case2, difference
else			; global tables
   startNumber = nreg-1 ; global only 
   regional   = False
   AB = new((/nvars,3/),"double")	; 3()=case1, case2, difference
end if

print("processing Variable " + vars + " obsFlag = " + obsFlag)

do region=startNumber,nreg-1

; each region contains all variables, so loop over vars
     nTime = 1		; required by function call to distinguish annual vs monthly values
     do i = 0,nvars-1
	   
	   if(plot_check(i) .eq. True) then
              if (obsFlag(i) .eq. 1) then
		compare = "obs"
	        ; NOTE:  area units are m2
		if (resoln(i) .eq. 2) then
	   	        x2 = array2(i,:,:)
           		value2 = regional_values(x2,region,area2(i,:,:),landmask2(i,:,:),scale_type(i),\
		  		 regions_file,time1,nTime,compare)
	                delete(x2)
		end if
		if (resoln(i) .eq. 3) then
	   	        x3 = array3(i,:,:)
           		value2 = regional_values(x3,region,area3(i,:,:),landmask3(i,:,:),scale_type(i),\
		  		 regions_file,time1,nTime,compare)
	                delete(x3)
		end if
		if (resoln(i) .eq. 4) then
	   	        x4 = array4(i,:,:)
           		value2 = regional_values(x4,region,area4(i,:,:),landmask4(i,:,:),scale_type(i),\
		  		 regions_file,time1,nTime,compare)
	                delete(x4)
		end if
 		if (resoln(i) .eq. 5) then
 	   	        x5 = array5(i,:,:)
            		value2 = regional_values(x5,region,area5(i,:,:),landmask5(i,:,:),scale_type(i),\
 		  		 regions_file,time1,nTime,compare)
 	                delete(x5)
 		end if
 		if (resoln(i) .eq. 6) then
 	   	        x6 = array6(i,:,:)
            		value2 = regional_values(x6,region,area6(i,:,:),landmask6(i,:,:),scale_type(i),\
 		  		 regions_file,time1,nTime,compare)
 	                delete(x6)
 		end if
 		if (resoln(i) .eq. 7) then
 	   	        x7 = array7(i,:,:)
            		value2 = regional_values(x7,region,area7(i,:,:),landmask7(i,:,:),scale_type(i),\
 		  		 regions_file,time1,nTime,compare)
 	                delete(x7)
 		end if
 	        ;       print("processing Variable " + vars(i) + " value = " + value2)
	      else 
	           value2 = -999.
	      end if
	      compare = "model"
              if (c13Flag(i) .eq. "C13_") then 
                 x1 = array13c1(i)
		 value1 = x1		; del13C values are regionally averaged before conversion
              else
                 if (c14Flag(i) .eq. "C14_") then 
	   	    x1 = array14c1(i)
		    value1 = x1		; del14C values are regionally averaged before conversion
                 else
	   	    x1 = array1(i,:,:)
		    ; NOTE:  area units are m2
           	    value1 = regional_values(x1,region,area1,landfrac1,scale_type(i),\
		            regions_file,time1,nTime,compare)
                 end if
	      end if
	      delete(x1)
	   else
	      value1 = -999.
	      value2 = -999.
	   end if

	  ; load up a big array to work with Keith's existing print fcn
	  if (p .eq. 0) then
	   	AB(i,region,0) = value1
	   	AB(i,region,1) = value2
	   	AB(i,region,2) = value1-value2
		AB(i,region,2) = mask(AB(i,region,2), AB(i,region,1) .eq. -999, False)	; mask missing values
	   else
	   	AB(i,0) = value1
	   	AB(i,1) = value2
	   	AB(i,2) = value1-value2
		AB(i,2) = mask(AB(i,2), AB(i,1) .eq. -999, False)	; mask missing values
	   end if
	   delete(value1)
	   delete(value2)

	   ABt = doubletofloat(AB)
	   ABt@_FillValue = -999.

    end do		; end variable loop
   end do		; end of region loop
   

   ; write out regional variables to file
   if (regional .eq. True) then
      case1 = "model"
      make_reg_table( case1,label1,cases(1),label2,ptitstr,vLongNames,ABt,title,tablename)
      make_reg_Dtable(case1,label1,cases(1),label2,ptitstr,varLabelsR,varUnits,vLongNames,ABt,Dtitle,dtablename)
      delete(AB)
      delete(ABt)
   else	; global tables
      make_ann_table( cases(0),label1,cases(1),label2,varLabelsA,ABt, title, tablename)
      make_ann_Dtable(cases(0),label1,cases(1),label2,varLabelsA,ABt,Dtitle,dtablename)
      delete(AB)
      delete(ABt)
   end if	

   delete(area2)
   delete(area3)
   delete(area4)
   delete(area5)
   delete(area6)
   delete(area7)
   delete(landmask2)
   delete(landmask3)
   delete(landmask4)
   delete(landmask5)
   delete(landmask6)
   delete(landmask7)
   delete(vv)
   delete(vars)
   delete(c13Flag)
   delete(c14Flag)
   delete(varLabelsR)
   delete(varLabelsA)
   delete(vLongNames)
   delete(varUnits)
   delete(array1)
   delete(array2)
   delete(array3)
   delete(array4)
   delete(array5)
   delete(array6)
   delete(array7)
   delete(array13c1)
   delete(array14c1)
   delete(scale_type)
   delete(plot_name)
   delete(title)
   delete(Dtitle)
   delete(obsFlag)
   delete(resoln)
  end do   ; end plot loop

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set5_error_file"                   
  system("/bin/rm -f " + filo)  

end
