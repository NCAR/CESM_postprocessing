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
  path      = getenv("DIAG_CODE")
  inputdir  = getenv("INPUT_FILES")
  resdir    = getenv("DIAG_RESOURCES")
  ptmpdir1   = getenv("PTMPDIR_1")
  ptmpdir2   = getenv("PTMPDIR_2")
  wkdir     = getenv("WKDIR")
  cn        = getenv("CN")
  casa      = getenv("CASA")
 useCommon1 = getenv("UseCommonName_1")
 useCommon2 = getenv("UseCommonName_2")

;***********************************************
; import regional information
;***********************************************

 months = 12   ; number of months
 regions_file = addfile(resdir +"/region_definitions.nc","r")
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

; 1 regional, 2 global (carbon-nitrogen-fire, biogeophysics)
nplots = 4

; loop over plots
do p=0,nplots-1

print("Now printing plot #" + p)
  if (p .eq. 0) then 
	fileName  = "set5_hydReg.txt"
	plot_name = "hydReg"
	title     = (/"DIAG SET 5: REGIONAL HYDROLOGIC CYCLE OVER LAND"/)
	Dtitle    = (/"DIAG SET 5: REGIONAL HYDROLOGIC CYCLE OVER LAND - DIFFERENCE (case1 - case2)"/)
  end if
  if (p .eq. 1) then
	fileName  = "set5_clm.txt"
	plot_name = "clm"
	title     = (/"DIAG SET 5: CLM ANNUAL MEANS OVER LAND"/)
	Dtitle    = (/"DIAG SET 5: CLM ANNUAL MEANS OVER LAND - DIFFERENCE (case1 - case2)"/)
  end if
  if (p .eq. 2) then
     if (cn .eq. 1) then
        inputdir  = wkdir
	fileName  = "masterCN_set5.txt"
	plot_name = "cn"
	title     = (/"DIAG SET 5: CN ANNUAL MEANS OVER LAND"/)
	Dtitle    = (/"DIAG SET 5: CN ANNUAL MEANS OVER LAND - DIFFERENCE (case1 - case2)"/)
     else
	continue
     end if
  end if
  if (p .eq. 3) then
     if (casa .eq. 1) then
        inputdir  = wkdir
	fileName  = "masterCASA_set5.txt"
	plot_name = "casa"
	title     = (/"DIAG SET 5: CASA ANNUAL MEANS OVER LAND"/)
	Dtitle    = (/"DIAG SET 5: CASA ANNUAL MEANS OVER LAND - DIFFERENCE (case1 - case2)"/)
     else
	continue
     end if
  end if

;----------------------------------------------------------
; read in file and parse into variables
;----------------------------------------------------------
  tmp = stringtocharacter(asciiread(inputdir+"/"+fileName,-1,"string"))
  nvars = dimsizes(tmp(:,0))
  scale_type = new(nvars,"string")
  vars       = new(nvars,"string")
  c13Flag    = new(nvars,"string")
  do i=0,nvars-1
  	scale_type(i) = charactertostring(tmp(i,0:12))
    	vars(i)       = charactertostring(tmp(i,16:))
        c13Flag(i)    = charactertostring(tmp(i,16:19))     ; derived variable prefix
  end do
  delete(tmp)

;----------------------------------------------------------
; open cases
;----------------------------------------------------------

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
    name11    = "prefix_1"
    name22    = "prefix_2"
    cases(0)  = getenv(name1)
    cases(1)  = getenv(name2)
    prefix(0) = getenv(name11)
    prefix(1) = getenv(name22)
    in1       = addfile(ptmpdir1+"/"+prefix(0)+"_ANN_climo.nc","r")
    in2       = addfile(ptmpdir2+"/"+prefix(1)+"_ANN_climo.nc","r")
    if (isatt(in1,"yrs_averaged")) then
        yrs_avg1  = in1@yrs_averaged
	label1 = cases(0) + "  (yrs "+yrs_avg1+")"
    end if
    if (isatt(in2,"yrs_averaged")) then
        yrs_avg2  = in2@yrs_averaged
	label2 = cases(1) + "  (yrs "+yrs_avg2+")"
    end if
    nyrs1      = getfilevardimsizes(in1,"time")
    landfrac1  = in1->landfrac
    area1      = in1->area	; read in variable to retain metadata
    area1      = area1 * 1.e6	; convert from km2 to m2
    time1      = in1->time
    lat1       = in1->lat
    lon1       = in1->lon
    nlat1      = dimsizes(lat1)
    nlon1      = dimsizes(lon1)
    nyrs2      = getfilevardimsizes(in2,"time")
    landfrac2  = in2->landfrac
    area2      = in2->area	; read in variable to retain metadata
    area2      = area2 * 1.e6	; convert from km2 to m2
    time2      = in2->time
    lat2       = in2->lat
    lon2       = in2->lon
    nlat2      = dimsizes(lat2)
    nlon2      = dimsizes(lon2)


    if (lon1(0) .lt. 0.) then
         fliplon1 = "False"           ; history files start at dateline
    else
         fliplon1 = "True"            ; history files start at greenwich
    end if

    if (lon2(0) .lt. 0.) then
         fliplon2 = "False"           ; history files start at dateline
    else
         fliplon2 = "True"            ; history files start at greenwich
    end if

    if (fliplon1 .eq. "True") then
           area1     = lonFlip(area1)
           landfrac1 = lonFlip(landfrac1)
    end if

    if (fliplon2 .eq. "True") then
           area2     = lonFlip(area2)
           landfrac2 = lonFlip(landfrac2)
    end if

;**************************
; Variable loop ----------- read both cases of each variable 
;			    into memeory so they can be printed on the same line.
;**************************
  array1    = new((/nvars, nlat1, nlon1/),"float")
  array2    = new((/nvars, nlat2, nlon2/),"float")
  array13c1 = new((/nvars/),"float")
  array13c2 = new((/nvars/),"float")

; read all variables into memory first and stuff them into two arrays (2 cases)
  varLabelsA = new(nvars,"string")
  varLabelsR = new(nvars,"string")
  varUnits   = new(nvars,"string")
  vLongNames = new(nvars,"string")

  do i=0,nvars-1 
      
; check for variables in case 1
      info = var_init(vars(i))

      filevar = vars(i)
      if(isfilevar(in1,filevar))then
         if (c13Flag(i) .eq. "C13_") then
                x1 = derive_del13C(vars(i),in1,scale_type(i),nyrs1,5)
         else
          	x1 = in1->$filevar$
	 end if
      else
          if (info@derivedVariable .eq. True) then
              x1 = derive_land(  vars(i),in1)
              if(all(ismissing(x1)))then
                      print("variable "+ vars(i)+ " values are all missing")
              end if
           else
              print("Case 1 variable "+ vars(i)+ " is not a defined variable.")
              if (c13Flag(i) .eq. "C13_") then
	        x1 = new((/nyrs1/),"float")
	        x1!0 ="time"
	        x1&time =time1
              else
	        x1 = new((/nyrs1,nlat1,nlon1/),"float")
	        x1!0 ="time"
	        x1&time =time1
	        x1!1 ="lat"
	        x1&lat = lat1
	        x1!2 ="lon"
	        x1&lon = lon1
              end if
           end if
      end if

; check for variables in case 2
      filevar = vars(i)
      if(isfilevar(in2,filevar))then
          if (c13Flag(i) .eq. "C13_") then
                x2 = derive_del13C(vars(i),in2,scale_type(i),nyrs2,5)
          else
          	x2 = in2->$filevar$
	  end if
      else
          if (info@derivedVariable .eq. True) then
              x2 = derive_land(  vars(i),in2)
              if(all(ismissing(x2)))then
                     print("variable "+ vars(i)+ " values are all missing")
              end if
           else
              print("Case 2 variable "+ vars(i)+ " is not a defined variable.")
              if (c13Flag(i) .eq. "C13_") then
	        x2 = new((/nyrs2/),"float")
	        x2!0 ="time"
	        x2&time =time2
              else
	        x2 = new((/nyrs2,nlat2,nlon2/),"float")
	        x2!0 ="time"
	        x2&time =time2
	        x2!1 ="lat"
	        x2&lat = lat2
	        x2!2 ="lon"
	        x2&lon = lon2
              end if
           end if
       end if

       ; catch NaNs
       x1 = catchNaN(x1)
       x2 = catchNaN(x2)

       ; flip variable to match regions definitions (-180-180)
       dm = dimsizes(dimsizes(x1))
       if (fliplon1 .eq. "True" .and. dm .gt. 1) then
           x1 = lonFlip(x1)
       end if
       dm = dimsizes(dimsizes(x2))
       if (fliplon2 .eq. "True" .and. dm .gt. 1) then
           x2 = lonFlip(x2)
       end if

       info = var_init(vars(i))

       x1 = scale_var(x1,scale_type(i),info)
       x2 = scale_var(x2,scale_type(i),info)
       varLabelsA(i) = vars(i) + "("+x1@units+")" + " " + x1@long_name
       varLabelsR(i) = vars(i)
       vLongNames(i) = x1@long_name
       varUnits(i) = "("+x1@units+")"

       if (c13Flag(i) .eq. "C13_") then
          array13c1(i) = x1
          array13c2(i) = x2
       else
          array1(i,:,:) = x1
          array2(i,:,:) = x2
       end if

       delete(x1)
       delete(x2)
 
   end do 	; end variable loop
   delete(in1)
   delete(in2)

;**********************************
; prepare to make tables
;**********************************

tablename  = wkdir+"set5_" +plot_name+".txt"
dtablename = wkdir+"set5_D"+plot_name+".txt"

if (p .eq. 0) then	; regional Table
   startNumber = 0
   regional    = True
   AB = new((/nvars,nreg,3/),"double")	; 3()=case1, case2, difference
else			; global tables
   startNumber = nreg-1 ; global only 
   regional    = False
   AB = new((/nvars,3/),"double")	; 3()=case1, case2, difference
end if

do region=startNumber,nreg-1

; each region contains all variables, so loop over vars
     nTime = 1		; required by function call to distinguish annual vs monthly values
     do i = 0,nvars-1
	   compare = "model"
	 
	   if (c13Flag(i) .eq. "C13_") then 
	        x1 = array13c1(i)
                x2 = array13c2(i)
		value1 = x1		; del13C values are regionally averaged before conversion
		value2 = x2
	   else
	   	x1 = array1(i,:,:)
	   	x2 = array2(i,:,:)
		; NOTE:  area units are m2

           	value1 = regional_values(x1,region,area1,landfrac1,scale_type(i),\
		  	regions_file,time1,nTime,compare)
           	value2 = regional_values(x2,region,area2,landfrac2,scale_type(i),\
		  	regions_file,time2,nTime,compare)
	   end if

	   ; load up a big array to work with Keith's existing print fcn
	  if (p .eq. 0) then
	   	AB(i,region,0) = value1
	   	AB(i,region,1) = value2
	   	AB(i,region,2) = value1-value2
	        AB(i,region,2) = mask(AB(i,region,2), AB(i,region,1) .eq. -999, False)  ; mask missing values
	   else
	   	AB(i,0) = value1
	   	AB(i,1) = value2
	   	AB(i,2) = value1-value2
		AB(i,2) = mask(AB(i,2), AB(i,1) .eq. -999, False)       ; mask missing values
	   end if

	   ABt = doubletofloat(AB)
	   ABt@_FillValue = -999.

	   delete(value1)
	   delete(value2)
	   delete(x1)
	   delete(x2)
    end do	; end variable loop
end do		;  end of region loop

   ; write out regional variables to file
   if (regional .eq. True) then
      make_reg_table( cases(0),label1,cases(1),label2,ptitstr,vLongNames,ABt,title, tablename)
      make_reg_Dtable(cases(0),label1,cases(1),label2,ptitstr,varLabelsR,varUnits,vLongNames,ABt,Dtitle,dtablename)
      delete(AB)
      delete(ABt)
   else	; global tables
      make_ann_table( cases(0),label1,cases(1),label2,varLabelsA,ABt,title, tablename)
      make_ann_Dtable(cases(0),label1,cases(1),label2,varLabelsA,ABt,Dtitle,dtablename)
      delete(AB)
      delete(ABt)
   end if	

   delete(vars)
   delete(c13Flag)
   delete(varLabelsR)
   delete(varLabelsA)
   delete(varUnits)
   delete(vLongNames)
   delete(array1)
   delete(array2)
   delete(array13c1)
   delete(array13c2)
   delete(scale_type)
   delete(plot_name)
   delete(title)
   delete(Dtitle)
  end do   ; end plot loop

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set5_error_file"                   
  system("/bin/rm -f " + filo)  

end
