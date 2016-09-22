load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
;************************************************
begin
 print ("=========================================")
 print ("Starting:  set_8_contour.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
  ptmpdir1 = getenv("PTMPDIR_1")
  ptmpdir2 = getenv("PTMPDIR_2")
  wkdir   = getenv("WKDIR")
  useCommon1 = getenv("UseCommonName_1")
  useCommon2 = getenv("UseCommonName_2")
  raster     = getenv("raster")
  plot_type  = getenv("PLOTTYPE")

  pCut  = 5
  pLow  = 0.05
  pHigh = 0.95

; the set lists contains two columns of information. This comes into
; NCL as one long string that we need to parse out.
  tmp = stringtocharacter(asciiread(wkdir+"/master_set8_contour.txt",-1,"string"))
  nvar = dimsizes(tmp(:,0))
  scale_type = new(nvar,"string")
  vars       = new(nvar,"string")
  dFlag      = new(nvar,"string")
  c13Flag    = new(nvar,"string")
  dynContour = new(nvar,"string")
  do i=0,nvar-1
    scale_type(i) = charactertostring(tmp(i,0:12))
    dynContour(i) = charactertostring(tmp(i,13))
    vars(i)       = charactertostring(tmp(i,16:))
    dFlag(i)      = charactertostring(tmp(i,16:17))
    c13Flag(i)    = charactertostring(tmp(i,16:19))
  end do

;*************************************************
; get case names and create filenames to read in
;*************************************************
  sig_lvl = stringtofloat(getenv("sig_lvl"))
  zoom  = stringtointeger(getenv("reg_contour")); # (0 = SUB, 1 = GLOBAL)
  if(zoom.eq.0)then
    min_lat = stringtofloat(getenv("min_lat"))
    max_lat = stringtofloat(getenv("min_lat"))
    min_lon = stringtofloat(getenv("min_lon"))
    max_lon = stringtofloat(getenv("min_lon"))
  end if
  seasons = (/"DJF","JJA","MAM","SON","ANN"/)
;*************************************************
; common plot resources
;*************************************************
  res                             = True
  res@txFontHeightF               = 0.024
  res@tiMainFontHeightF           = 0.030
  pres                            = True           ; panel only resources

  res                          = True
  res@cnFillOn                 = True
  if (raster .eq. 1) then
  	res@cnRasterModeOn     = True
  end if
  res@gsnMaximize              = True
  res@cnInfoLabelOn            = False
  res@cnLinesOn                = False


  res@gsnDraw                  = False
  res@gsnFrame                 = False

  res@pmLabelBarHeightF        = 0.05
  res@pmLabelBarWidthF         = 0.85
  res@pmLabelBarOrthogonalPosF = 0.12
  res@lbTitleOn                = True
  res@lbTitlePosition          = "bottom"
  res@lbLabelFontHeightF       = 0.020
  res@lbTitleFontHeightF       = 0.022
  res@tiMainFont               = "Helvetica"

  res@mpGridLonSpacingF        = 60.0
  res@mpGridLatSpacingF        = 30.0
  res@mpFillOn 		       = False
  res@mpOutlineOn              = True
  res@mpGridAndLimbOn          = True
  res@mpGridLineDashPattern    =  2           ; Set grid line dash pattern (dash)
  res@mpGridLineThicknessF     = 0.5          ; Set grid line thickness

  res@gsnPaperOrientation      = "landscape"

; read in case strings
  cases  = new(2,string)
  prefix = new(2,string)
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
    name2     = "prefix_"+(m+1)
    cases(m)  = getenv(name1)
    prefix(m) = getenv(name2)
  end do

    caseid_1    = getenv("caseid_1")
    cam_1       = getenv("atm_modelstream_1")
    caseid_2    = getenv("caseid_2")
    cam_2       = getenv("atm_modelstream_2")

; loop over seasons

  do n = 0,dimsizes(seasons)-1
    print("Processing season " + seasons(n))
    pres@txString  = seasons(n)
    in1  = addfile(ptmpdir1+"/"+"/atm/"+caseid_1+"."+cam_1+"._"+seasons(n)+"_climo.nc","r")	; used for first 3 plots
    in2  = addfile(ptmpdir2+"/"+"/atm/"+caseid_2+"."+cam_2+"._"+seasons(n)+"_climo.nc","r")	; used for first 3 plots
    in11 = addfile(ptmpdir1+"/"+"/atm/"+caseid_1+"."+cam_1+"._"+seasons(n)+"_means.nc","r")
    in22 = addfile(ptmpdir2+"/"+"/atm/"+caseid_2+"."+cam_2+"._"+seasons(n)+"_means.nc","r")
    ; get degrees of freedom for t test
    if (isatt(in11,"num_yrs_averaged")) then
  	dof_1 = in11@num_yrs_averaged
    else
        dof_1 = getfilevardimsizes(in11, "time")
    end if
    if (isatt(in22,"num_yrs_averaged")) then
  	dof_2 = in22@num_yrs_averaged
    else
        dof_2 = getfilevardimsizes(in22, "time")
    end if

; extract years averaged for plotting
    if (isatt(in1,"yrs_averaged")) then
  	yrs_ave1 = in1@yrs_averaged
    end if
    if (isatt(in2,"yrs_averaged")) then
  	yrs_ave2 = in2@yrs_averaged
    end if

; check to make sure levels are the same for both model cases
    nlev1      = getfilevardimsizes(in1,"lev")
    nlev2      = getfilevardimsizes(in2,"lev")
    if(nlev1 .ne. nlev2)then
      print("your case1 and case2 levels must be the same: EXITING SET 2")
      exit
    end if

    lon1    = in1->lon 
    if (lon1(0) .lt. 0.) then 
       fliplon1 = "False"           ; history files start at dateline
    else 
       fliplon1 = "True"            ; history files start at greenwich
    end if 

    lon2    = in2->lon 
    if (lon2(0) .lt. 0.) then 
       fliplon2 = "False"           ; history files start at dateline
    else 
       fliplon2 = "True"            ; history files start at greenwich
    end if 


; loop over variables
    do i=0,dimsizes(vars)-1 
      print(" " + vars(i))
      res@gsnLeftString = vars(i)
      res@gsnSpreadColors	       = True	      ; key for for maintaining colorbar!
      plot = new(4,graphic)

; read in case 1 variable
     plot_check = True
     if (dFlag(i) .eq. "SF") then
        if(isfilevar(in1,vars(i)))then
                xa  = in1 ->$vars(i)$
                xaa = in11->$vars(i)$
        else
                if (vars(i) .eq. "SFCO2_LND") then
                    if(isfilevar(in1,"SFCO2_LN"))then
                        xa  = in1 ->SFCO2_LN
		    end if
                    if(isfilevar(in11,"SFCO2_LN"))then
                        xaa = in11->SFCO2_LN
		    end if
                end if
                if (vars(i) .eq. "SFCO2_OCN") then
                    if(isfilevar(in1,"SFCO2_OC"))then
                        xa  = in1 ->SFCO2_OC
		    end if
                    if(isfilevar(in11,"SFCO2_OC"))then
                        xaa = in11->SFCO2_OC
		    end if
                end if
                if (vars(i) .eq. "SFCO2_FFF") then
                    if(isfilevar(in1,"SFCO2_FF"))then
                        xa  = in1 ->SFCO2_FF
		    end if
                    if(isfilevar(in11,"SFCO2_FF"))then
                        xaa = in11->SFCO2_FF
		    end if
                end if
          end if
      else
          info = var_init(vars(i))
          if(isfilevar(in1,vars(i)))then
        		xa  = in1 ->$vars(i)$
        		xaa = in11->$vars(i)$
                        plot_check = True
          else
                        if (info@derivedVariable .eq. True) then
        			xa  = derive_land(vars(i),in1)
        			xaa = derive_land(vars(i),in11)
                        	plot_check = True
                        else
                                print("variable "+ vars(i)+ " is not a defined variable.")
                                plot_check = False
                                continue
                        end if
           end if
      end if
  ; pull surface level from 4D atm data
      if (.not. isvar("xa")) then
                plot_check = False
      end if
      if (.not. isvar("xaa")) then
                plot_check = False
      end if
      if (plot_check .eq. False) then
                continue
      else
         	rank       = dimsizes(dimsizes(xa))
         	if(rank .eq. 4) then
      	      		x1  =  xa(:,nlev1-1,:,:)	; lev0 = top of atm
      	      		x11 = xaa(:,nlev1-1,:,:)	; lev0 = top of atm
         	else
      	      		x1  = xa
      	      		x11 = xaa
         	end if
         	delete(xa)
         	delete(xaa)
         	if(all(ismissing(x1)))then
             		print("variable "+ vars(i)+ " not found")
             		plot_check_1 = False
             		delete(x1)
             		continue
         	end if
         	if(all(ismissing(x11)))then
             		print("variable "+ vars(i)+ " not found")
             		plot_check_11 = False
             		delete(x11)
             		continue
         	end if
       end if	; plot check look

;read in case 2 variable
     if (dFlag(i) .eq. "SF") then
        if(isfilevar(in2,vars(i)))then
                xa  = in2 ->$vars(i)$
                xaa = in22->$vars(i)$
        else
                if (vars(i) .eq. "SFCO2_LND") then
                    if(isfilevar(in2,"SFCO2_LN"))then
                        xa  = in2 ->SFCO2_LN
		    end if
                    if(isfilevar(in22,"SFCO2_LN"))then
                        xaa = in22->SFCO2_LN
		    end if
                end if
                if (vars(i) .eq. "SFCO2_OCN") then
                    if(isfilevar(in2,"SFCO2_OC"))then
                        xa  = in2 ->SFCO2_OC
		    end if
                    if(isfilevar(in22,"SFCO2_OC"))then
                        xaa = in22->SFCO2_OC
		    end if
                end if
                if (vars(i) .eq. "SFCO2_FFF") then
                    if(isfilevar(in2,"SFCO2_FF"))then
                        xa  = in2 ->SFCO2_FF
		    end if
                    if(isfilevar(in22,"SFCO2_FF"))then
                        xaa = in22->SFCO2_FF
		    end if
                end if
        end if
      else
                info = var_init(vars(i))
                if(isfilevar(in2,vars(i)))then
        		xa  = in2 ->$vars(i)$
        		xaa = in22->$vars(i)$
                        plot_check = True
                else
                        if (info@derivedVariable .eq. True) then
        			xa  = derive_land(vars(i),in2)
        			xaa = derive_land(vars(i),in22)
                        else
                                print("variable "+ vars(i)+ " is not a defined variable.")
                                plot_check = False
                                continue
                        end if
                end if
      end if
  ; pull surface level from 4D atm data
      if (.not. isvar("xa")) then
                plot_check = False
      end if
      if (.not. isvar("xaa")) then
                plot_check = False
      end if
      if (plot_check .eq. False) then
                continue
      else
      	if(rank .eq. 4) then
      		x2  =  xa(:,nlev1-1,:,:)	; lev0 = top of atm
      		x22 = xaa(:,nlev1-1,:,:)	; lev0 = top of atm
      	else
      		x2 = xa
      		x22 = xaa
      	end if
      	delete(xa)
      	delete(xaa)
      	if(all(ismissing(x2)))then
          	print("variable "+ vars(i)+ " not found")
          	plot_check = False
          	delete(x2)
          	continue
      	end if
      	if(all(ismissing(x22)))then
          	print("variable "+ vars(i)+ " not found")
          	plot_check = False
          	delete(x22)
          	continue
      	end if
	
      	; screen for NaNs
      	x1  = catchNaN(x1)
      	x11 = catchNaN(x11)
      	x2  = catchNaN(x2)
      	x22 = catchNaN(x22)
	
	; get info for @ varb and scale
      	info     = var_init(vars(i))
      	x1       = scale_var(x1, scale_type(i),info)
      	x11      = scale_var(x11,scale_type(i),info)
      	x2       = scale_var(x2, scale_type(i),info)
      	x22      = scale_var(x22,scale_type(i),info)
	
	; flip longitudes to -180 to 180 if needed 
      	if (fliplon1 .eq. "False" .and. fliplon2 .eq. "True" ) then
        	x2  = lonFlip(x2)
        	x22 = lonFlip(x22)
      	end if
      	if (fliplon2 .eq. "False" .and. fliplon1 .eq. "True" ) then
        	x1  = lonFlip(x1)
        	x11 = lonFlip(x11)
      	end if
      	; regional plotting
      	if (zoom .eq. 1) 
        	if (fliplon1 .eq. "True" .and. fliplon2 .eq. "True" ) then
                	x1  = lonFlip(x1)
                	x2  = lonFlip(x2)
                	x11 = lonFlip(x11)
                	x22 = lonFlip(x22)
        	end if
      	end if
	
; calculate size
      	rank      = dimsizes(dimsizes(x1))

      	cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag12.rgb")  ; read in colormap

; calculate time average
        var_avg_1 = dim_avg_Wrap(x1(lat|:,lon|:,time|:))  ; time average
        var_avg_2 = dim_avg_Wrap(x2(lat|:,lon|:,time|:))  ; time average

	min1 = doubletofloat(min(var_avg_1))
        max1 = doubletofloat(max(var_avg_1))

        expFlag = False
        if(info@cn_Explicit .eq. True .and. dynContour(i) .eq. 1) then        ; dynContour:  0=ON;1=OFF
                expFlag = True
        end if

        if(isatt(res,"lbLabelStrings")) then
                delete(res@lbLabelStrings)
        end if

; set explicit contour levels 
        if(expFlag .eq. True) then
                res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                res@cnLevels             = info@cn_Levels   ; contour levels
                if (any(abs(res@cnLevels) .le. 1e-2 .and. res@cnLevels .ne. 0)) then
                          res@lbLabelStrings = sprintf("%4.0e",res@cnLevels)      ; format the labels
                else
                     if (any(abs(res@cnLevels) .le. 1e-1 .and. res@cnLevels .ne. 0)) then
                          res@lbLabelStrings = sprintf("%4.2f",res@cnLevels)      ; format the labels
                     else
                          res@lbLabelStrings = sprintf("%4.1f",res@cnLevels)      ; format the labels
                     end if
                end if
        else
                if (c13Flag(i) .eq. "C13_") then
                        useMin12 = -40              ; hardcode boundaries to expectations
                        useMax12 = 0                ; hardcode boundaries to expectations
                else
                        x = ndtooned(var_avg_1)
                        nMsg  = num(ismissing(x))
                        nGood = num(.not.ismissing(x))

                        qsort(x)

                        iLow  = floattointeger( pLow*nGood)
                        useMin12  = x(iLow )
                        iHigh = floattointeger( pHigh*nGood)
                        useMax12  = x(iHigh)

                        delete(x)
                end if
                maxLevel = 9
                mnmxint = nice_mnmxintvl( useMin12, useMax12, maxLevel, True)
                res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
                res@cnMinLevelValF       = mnmxint(0)
                res@cnMaxLevelValF       = mnmxint(1)
                res@cnLevelSpacingF      = mnmxint(2)

		delete(useMin12)
		delete(useMax12)
        end if

; open postscript file and choose colormap
        wks  = gsn_open_wks(plot_type,wkdir + "set8_contour_" + seasons(n)+"_"+vars(i))
        gsn_define_colormap(wks,cmap)

; set case 1 titles
        res@tiMainString           = cases(0) + " (yrs " + yrs_ave1 + ")"
        min1 = min(var_avg_1)
        max1 = max(var_avg_1)
        if(expFlag .eq. True) then
                res@lbTitleString = "MIN = "+sprintf("%6.4e",min1)+\
                " MAX = "+sprintf("%6.4e",max1)
        else
                res@lbTitleString = "MIN = "+sprintf("%6.4e",min1)+\
                " MAX = "+sprintf("%6.4e",max1)+" (+/-"+pCut+"%)"
        end if
        res@gsnLeftString    = vars(i)	; could also use info@longName if we want
        res@gsnRightString   = x1@units	; assume same units for x1 and x2

; case 1 plot
        plot(0) = gsn_csm_contour_map_ce(wks,var_avg_1,res)

; set case 2 titles
        res@tiMainString           = cases(1) + " (yrs " + yrs_ave2 + ")"
        min2 = min(var_avg_2)
        max2 = max(var_avg_2)
        if (expFlag .eq. True) then
                res@lbTitleString = "MIN = "+sprintf("%6.4e",min2)+ \
                " MAX = "+sprintf("%6.4e",max2)
        else
                res@lbTitleString = "MIN = "+sprintf("%6.4e",min2)+ \
                " MAX = "+sprintf("%6.4e",max2)+" (+/-"+pCut+"%)"
        end if
        res@gsnLeftString    = vars(i)	; could also use info@longName if we want
        res@gsnRightString   = x1@units	; assume same units for x1 and x2

; case 2 plot
        plot(1) = gsn_csm_contour_map_ce(wks,var_avg_2,res)

; remove explicit labels
        if(expFlag .eq. True) then
                delete(res@cnLevelSelectionMode)
                if(isatt(res,"cnLevels")) then
                        delete(res@cnLevels)
                end if
        end if

; difference plot
        diff = var_avg_1 ; trick to maintain meta data
        diff = var_avg_1 - var_avg_2


        diff_max = "Min = " + min(diff) + "  Max = " + max(diff)
        res@tiMainString           = cases(0) +" - "+cases(1)
        mindiff = min(diff)
        maxdiff = max(diff)
        min1 = doubletofloat(min(diff))
        max1 = doubletofloat(max(diff))

; set contour levels
        if(isatt(res,"lbLabelStrings")) then
                delete(res@lbLabelStrings)
        end if
        if (expFlag .eq. False) then
                  if (c13Flag(i) .eq. "C13_") then
                                useMin1 = -40              ; hardcode boundaries to expectations
                                useMax1 = 0                ; hardcode boundaries to expectations
                  else
                                useMin1 = mindiff
                                useMax1 = maxdiff
                  end if
                  maxLevel = 11
                  mnmxint = nice_mnmxintvl( useMin1, useMax1, maxLevel, False)
                  res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
                  res@cnMinLevelValF       = mnmxint(0)
                  res@cnMaxLevelValF       = mnmxint(1)
                  res@cnLevelSpacingF      = mnmxint(2)
                  delete(useMin1)
                  delete(useMax1)
        else
                res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                res@cnLevels             = info@cn_LevelsDiff   ; contour levels
                if (any(abs(res@cnLevels) .le. 1e-2 .and. res@cnLevels .ne. 0)) then
                                res@lbLabelStrings = sprintf("%4.0e",res@cnLevels)      ; format the labels
                else
                        if (any(abs(res@cnLevels) .le. 1e-1 .and. res@cnLevels .ne. 0)) then
                                res@lbLabelStrings = sprintf("%4.2f",res@cnLevels)      ; format the labels
                        else
                                res@lbLabelStrings = sprintf("%4.1f",res@cnLevels)      ; format the labels
                        end if
                end if
        end if

        res@lbTitleString = "MIN = "+sprintf("%6.4e",mindiff)+ \
        " MAX = "+sprintf("%6.4e",maxdiff)
        res@gsnLeftString    = vars(i)	; could also use info@longName if we want
        res@gsnRightString   = x1@units	; assume same units for x1 and x2
        plot(2) = gsn_csm_contour_map_ce(wks,diff,res)


; T-Test plot

        if(expFlag .eq. True) then
                delete(res@cnLevelSelectionMode)
        end if

; calculate 
        var_variance_1 = dim_variance_Wrap(x11(lat|:,lon|:,time|:))  ; time average
        var_variance_2 = dim_variance_Wrap(x22(lat|:,lon|:,time|:))  ; time average

; set variances < 0 to missing so don't divide by zero        
        if (any(var_variance_1 .le. 0)) then
          var_variance_1 = mask(var_variance_1,(var_variance_1 .gt. 0),True)
        end if
        if (any(var_variance_2 .le. 0)) then
          var_variance_2 = mask(var_variance_2,(var_variance_2 .gt. 0),True)
        end if
; calculate t-test
        prob = var_avg_1 ; trick to maintain meta data
        prob = ttest(var_avg_1,var_variance_1,dof_1,var_avg_2,var_variance_2,dof_2,\
        True,False)

        res@gsnSpreadColors      = False
        res@gsnLeftString        = ""
        res@gsnRightString       = ""
        res@cnLevelSelectionMode =  "ExplicitLevels"
        res@cnLevels             = sig_lvl  ; user defined sig level to view
        res@cnFillColors         = (/11,0/) ; only have red squares
        res@lbLabelBarOn         = False
        res@tiMainString         = "T-Test of two means at each grid point"
        res@gsnCenterString      = "Cells are significant at " + sig_lvl +" level"

; t-test plot
        plot(3) = gsn_csm_contour_map_ce(wks,prob,res) ; will be sig test
        delete(res@lbLabelBarOn)
        delete(res@gsnCenterString)
        delete(res@cnLevelSelectionMode)
        delete(res@cnLevels)
        delete(res@cnFillColors)

; panel plot
        gsn_panel(wks,plot,(/2,2/),pres)           ; draw panel plot
        delete(x1)
        delete(x11)
        delete(x2)
        delete(x22)
        delete(diff)
        delete(prob)
        delete(var_avg_1)
        delete(var_avg_2)
        delete(var_variance_1)
        delete(var_variance_2)
        delete(plot)
    end if ; plot_check loop
    end do ; variable loop
  end do   ; seasons loop 

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set8_contour_error_file"                   
  system("/bin/rm -f " + filo)  

end


