load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/lnd_func.ncl"
;************************************************
begin
  print ("=========================================")
  print ("Starting:  set_1DiffPlot.ncl")
  print ("Start Time: "+systemfunc("date") )
  print ("=========================================")
  ptmpdir1 = getenv("PTMPDIR_1")
  ptmpdir2 = getenv("PTMPDIR_2")
  wkdir   = getenv("WKDIR")
  useCommon1 = getenv("UseCommonName_1")
  useCommon2 = getenv("UseCommonName_2")
  plot_type  = getenv("PLOTTYPE")

; the set lists contains two columns of information. This comes into
; NCL as one long string that we need to parse out.
  tmp = stringtocharacter(asciiread(wkdir+"/master_set1.txt",-1,"string"))
  nvar = dimsizes(tmp(:,0))
  scale_type = new(nvar,"string")
  vars       = new(nvar,"string")
  c13Flag    = new(nvar,"string")
  c14Flag    = new(nvar,"string")
  do i=0,nvar-1
    scale_type(i) = charactertostring(tmp(i,0:12))
    vars(i)       = charactertostring(tmp(i,16:))
    c13Flag(i)    = charactertostring(tmp(i,16:19))     
    c14Flag(i)    = charactertostring(tmp(i,16:19))     
  end do
  delete(tmp)

;*************************************************
; get case names and create filenames to read in
;*************************************************
  nyrs1    = stringtointeger(getenv("trends_num_yrs_1"))
  fyr1     = stringtointeger(getenv("trends_first_yr_1"))
  matchYr1 = stringtointeger(getenv("trends_match_yr_1"))
  nyrs2    = stringtointeger(getenv("trends_num_yrs_2"))
  fyr2     = stringtointeger(getenv("trends_first_yr_2"))
  matchYr2 = stringtointeger(getenv("trends_match_yr_2"))
trendsFlag = stringtointeger(getenv("trends_match_Flag"))

  yrs    = new((/2/),"integer")
  offset = new((/2/),"integer")
  if (nyrs1 .ne. nyrs2 .or. fyr1 .ne. fyr2 .or. trendsFlag .eq. 1) then
        x2y2Plot = 1			; 1=ON, 0=OFF
        yrDifferential = matchYr2 - matchYr1
        fy = max( (/matchYr1,(matchYr2-yrDifferential)/) )
	ly1 = ( (fyr1+nyrs1) - matchYr1)
	ly2 = ( (fyr2+nyrs2) - matchYr2) 
        minyrs = min( (/ly1, ly2/) )
	if (minyrs .le. 0) then
		print("")
		print("NORMAL EXIT:  Set_1DiffPlot.ncl.")
		print("REASON: No Overlapping years for difference plot.")
		print("")
  		; remove error file if program completes successfully.
  		filo  = wkdir +"/set1Diff_error_file"            
  		system("/bin/rm -f " + filo)
		exit
	end if
	nyrs = minyrs

        fy1 = fy
        fy2 = fy + yrDifferential
        if (fyr1 .eq. fy) then
                offset(0) = 0
                offset(1) = matchYr2 - fyr2
        else
                offset(1) = 0
                offset(0) = matchYr1 - fyr1
        end if
        tspan = ispan(0,minyrs-1,1)
        t1 = tspan + matchYr1
        t2 = tspan + matchYr2 

  else
        x2y2Plot = 0			; 1=ON, 0=OFF
	matchYr1 = 1			
	matchYr2 = 1
        nyrs = nyrs1
        fyr  = fyr1
	minyrs = nyrs
	offset(0) = 0
	offset(1) = 0
  end if
  yrs(0) = minyrs
  yrs(1) = minyrs

  data   = new((/2,nyrs/),"float")
  data3  = new((/2,nyrs,10/),"float")    ; how do we not hardwire this?
  cases  = new(2,"string")
  legendLabel  = new(1,"string")
  prefix = new(2,"string")
  do m = 0,1
    name2      = "prefix_"+(m+1)
    prefix(m)  = getenv(name2)
  end do
  in1    = addfile(ptmpdir1+"/"+prefix(0)+"ANN_ALL.nc","r")
  in2    = addfile(ptmpdir2+"/"+prefix(1)+"ANN_ALL.nc","r")
  landfrac1 = in1->landfrac
  area1     = in1->area
  time1     = in1->time
  landfrac2 = in2->landfrac
  area2     = in2->area
  time2     = in2->time
  nlev1 = 0
; CTSM5.1.dev021 now has both levsoi and levgrnd variables
; so I'm changing this to an if/else (01/19/21)
  if(isfilevar(in1,"levsoi")) then
     nlev1       = getfilevardimsizes(in1,"levsoi")
     levsoi1     = in1->levsoi
  else
     if (isfilevar(in1,"levgrnd")) then
         nlev1       = getfilevardimsizes(in1,"levgrnd")
         levsoi1     = in1->levgrnd
     end if
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
; CTSM5.1.dev021 now has both levsoi and levgrnd variables
; so I'm changing this to an if/else (01/19/21)
  if(isfilevar(in2,"levsoi")) then
     nlev2       = getfilevardimsizes(in2,"levsoi")
     levsoi2     = in2->levsoi
  else
     if (isfilevar(in2,"levgrnd")) then
         nlev2       = getfilevardimsizes(in2,"levgrnd")
         levsoi2     = in2->levgrnd
     end if
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

;*************************************************
; main loop
;*************************************************
  do i=0,dimsizes(vars)-1 
    dataDiff  = new((/minyrs/),"float")
    data3Diff = new((/minyrs,10/),"float")    ; how do we not hardwire this?
    do m = 0,1 
       if (m .eq. 0) then
                 useFlag = useCommon1
       end if
       if (m .eq. 1) then
                 useFlag = useCommon2
       end if
       if (useFlag .eq. "True") then
           name   = "commonName_"+(m+1)
       else
           name   = "caseid_"+(m+1)
       end if
       cases(m)   = getenv(name)
       if (m .eq. 0) then
         in       = in1
         landfrac = landfrac1
         area     = area1
         time     = time1
         nlev     = nlev1
         ; levsoi   = levsoi1	; nanr 5may11 - causing problems for AdamPhillips.  Not sure why
       else
         in = in2
         landfrac = landfrac2
         area     = area2
         time     = time2
         nlev     = nlev2
         ; levsoi   = levsoi2	; nanr 5may11 - causing problems for AdamPhillips.  Not sure why
       end if

       filevar = vars(i)

       if(isfilevar(in,filevar))then
         if (c13Flag(i) .eq. "C13_") then
           	tmp = derive_del13C(vars(i),in,scale_type(i),yrs(m),1)
         else
            if (c14Flag(i) .eq. "C14_") then
           	tmp = derive_del14C(vars(i),in,scale_type(i),yrs(m),1)
            else
         	tmp = in->$filevar$
            end if
	 end if
         plot_check = True
         delete(filevar)
       else
	       info = var_init(vars(i))
               if (info@derivedVariable .eq. True) then
                  tmp = derive_land(  vars(i),in)
                  if(all(ismissing(tmp)))then
			  print("variable "+ vars(i)+ " contains only missing values")
                          plot_check = False
			  delete(tmp)
		   	  delete(landfrac)	
	           	  delete(area)
	           	  delete(nlev)
	           	  delete(time)
                          continue
                  else
                          plot_check = True
                  end if
               else
                   print("variable "+ vars(i)+ " is not a defined variable.")
                   plot_check = False
		   delete(landfrac)	
	           delete(area)
	           delete(nlev)
	           delete(time)
                   continue
               end if
        end if

	; screen for NaNs
 	tmp = catchNaN(tmp)

	; trim the inputdata down to the overlapping years.
	m1 = offset(0)
	m2 = offset(1)
	mm1 = offset(0) + minyrs - 1
	mm2 = offset(1) + minyrs - 1
        rank1 = dimsizes(dimsizes(tmp))
        if (rank1 .eq. 4 ) then
	   if (nlev .gt. 10) then
              	print("Truncating soil levels to 10 levels [caseid: "+prefix(m)+"  "+vars(i)+" nlev:  " + nlev +"]")
               	nlev = 10
	   end if
	   if (m .eq. 0) then
        	x = tmp(m1:mm1,:,:,:)
	   end if
	   if (m .eq. 1) then
        	x = tmp(m2:mm2,:,:,:)
	   end if
	else
	   rank1 = 3
	   if (m .eq. 0) then
                if (c13Flag(i) .eq. "C13_" .or. c14Flag(i) .eq. "C14_") then  ; data is already globally averaged
        	  x = tmp(m1:mm1)
                else
                  x = tmp(m1:mm1,:,:)
                end if
	   end if
	   if (m .eq. 1) then
                if (c13Flag(i) .eq. "C13_" .or. c14Flag(i) .eq. "C14_") then  ; data is already globally averaged
        	  x = tmp(m2:mm2)
                else
                  x = tmp(m2:mm2,:,:)
                end if
	   end if
        end if
	delete(tmp)
	delete(m1)
	delete(m2)
	delete(mm1)
	delete(mm2)

        if(plot_check.eq.True)then
 	     info = var_init(vars(i))
 	     x    = scale_var(x,scale_type(i),info)

; extract years averaged for plotting
   	    if (isatt(in,"yrs_averaged")) then
        	yrs_ave = in@yrs_averaged
            end if

    	    legendLabel = "  "+cases(0) + " - " + cases(1) 

; calculate global summation or global total      
            if (c13Flag(i) .ne. "C13_" .and. c14Flag(i) .ne. "C14_") then
                    var_plot = global_values(vars(i), x,area,landfrac,scale_type(i),yrs(m),nlev)
            else
                    var_plot = x    ; del14C vars are globally averaged before the del value is calculated
            end if

            rank2 = dimsizes(dimsizes(var_plot))

            if(rank2.eq.1)then
          	data(m,:) = var_plot
          	; data(m,0:yrs(m)-1) = var_plot
            else
          	data3(m,:,:) = var_plot
          	; data3(m,0:yrs(m)-1,:) = var_plot
            end if
            long_name = x@long_name
            units     = x@units
            delete(var_plot)
          end if ; plot_check loop
	  delete(x)
	  delete(time)
	  delete(landfrac)
	  delete(area)
      end do	 ; case loop


;*************************************************
; create plot
;*************************************************
  if(plot_check.eq.True)then

    if(rank1.eq.3)then
		dataDiff = data(0,:) - data(1,:)
    		if (all(dataDiff .eq. 0)) then
			; continue
    		end if
    else
      		data3Diff = data3(0,:,:) - data3(1,:,:)
    		if (all(data3Diff .eq. 0)) then
			; continue
    		end if
    end if

    wks = gsn_open_wks(plot_type,wkdir + "set1Diff_" + vars(i))
    
    res                        = True
    res@gsnFrame	       = False
    
    res@tiXAxisOn              = False
    res@gsnRightString         = ""
    res@gsnLeftString          = ""     ;"case1 - case2"
    res@tiYAxisString          = vars(i) + "  ("+units+")"

    res@xyDashPatterns         = (/0./)          ; solid, dashed
    res@xyLineThicknesses      = (/2./)
    res@xyLineColors           = (/"red"/)

    res@pmLegendDisplayMode    = "Always"
    res@pmLegendSide           = "Bottom"            
    res@pmLegendParallelPosF   = 0.50           
    res@pmLegendOrthogonalPosF = 0.02              
    res@pmLegendWidthF         = 0.3             
    res@pmLegendHeightF        = 0.1 
    res@lgLabelFontHeightF     = 0.020
    res@lgPerimOn              = False
    res@xyExplicitLegendLabels = legendLabel

    res@tmXBMinorOn            = False

    if(rank1.eq.3)then
         if (x2y2Plot .eq. 1) then

                ymin = 0.0
                ymax = 0.0
                if (all(ismissing(dataDiff))) then
                        ymin = 0.0
                        ymax = 0.0
                else
                        ymin = min(dataDiff)
                        ymax = max(dataDiff)
                end if
                if (ismissing(ymin) .or. ismissing(ymax) ) then
                        print(" -----FATAL - missing ymin and ymax in set 6")
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
                delete(yrange)

                res1    = True
                res1@gsnFrame                     = False

                res1@tiMainString                 = "Difference Plot: " + long_name
                res1@tiXAxisOn              = False
                res1@trXMinF                      = t1(0)
                res1@trXMaxF                      = t1(minyrs-1)
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
                res1@lgPerimOn                    = False
                res1@xyExplicitLegendLabels       = legendLabel

                res2    = True
                res2@gsnFrame                     = False
                res2@trXMinF                      = t2(0)
                res2@trXMaxF                      = t2(minyrs-1)
                res2@trYMinF                      = ymin
                res2@trYMaxF                      = ymax
                res2@tmYROn                       = False
                res2@tmYRLabelsOn                 = False
                res2@xyLineColor                  = "blue"
                res2@tmXTLabelFontColor           = "blue"
                res2@xyDashPattern                = 2
                res2@gsnRightString               = units

                res2@xyLineThicknessF             = 2
                plot = gsn_csm_x2y2(wks,t1,t2,dataDiff,dataDiff,res1,res2)
                delete(res1)
                delete(res2)
	else	
	      res@tiMainString           = "Difference Plot: " + long_name
	      plot = gsn_csm_xy(wks,ispan(fyr,fyr+(minyrs-1),1),dataDiff,res)   
	end if
        frame(wks)
    else
	      plot = new(nlev,graphic)
	      res@tiMainOn               = False
	      res@gsnDraw                = False
	      res@gsnFrame               = False
	      res@tiXAxisFontHeightF     = 0.030
	      res@tiYAxisFontHeightF     = 0.030
	      res@txFontHeightF          = 0.030
	      res@tmXBLabelFontHeightF   = 0.030
	      res@tmYLLabelFontHeightF   = 0.030
	      res@tmYLFormat             = "0@!;*?5g"

	      res@pmLegendDisplayMode    = "Never"
	      res@vpHeightF              = 0.4
	      res@vpWidthF               = 0.8
              ; CTSM5.1.dev021 now has both levsoi and levgrnd variables
              ; so I'm changing this to an if/else (01/19/21)
  	      if(isfilevar(in,"levsoi")) then
	      	lev = in->levsoi
              else
  	         if(isfilevar(in,"levgrnd")) then
	      	   lev = in->levgrnd
  	         end if
  	      end if
	      do k=0,nlev-1
        	 res@tiXAxisOn              = False
         	if (x2y2Plot .eq. 1) then
	
                	if (all(ismissing(data3Diff(:,k)))) then
                        	ymin = 0.0
                        	ymax = 0.0
                	else
                        	ymin = min( (/data3Diff(:,k)/) )
                        	ymax = max( (/data3Diff(:,k)/) )
                	end if
			minvalue = 0.001
                	yrange = ymax-ymin   
                	if (ymin .eq. ymax .or. fabs(yrange) .lt. minvalue) then   
                        	pad = 0.01
                        	ypad = ymin * pad
                	else   
                        	pad = 0.05
                        	ypad = yrange * pad
                	end if   
                	ymin = ymin - ypad   
                	ymax = ymax + ypad   
	
                	res1    = True
                	res1@gsnFrame                     = False
                	res1@gsnDraw                      = False
	
                	res1@pmLegendDisplayMode    = "Never"
                	res1@vpHeightF              = 0.4
                	res1@vpWidthF               = 0.8
                	res1@tmYLFormat             = "0@!;*?5g"
                	res1@tiXAxisOn              = False
                	res1@tiMainString                 = "Layer " + (k+1)
                	res1@trXMinF                      = t1(0)
                	res1@trXMaxF                      = t1(minyrs-1)
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
	
                	res2    = True
			res2@pmLegendDisplayMode          = "Never"
                	res2@gsnFrame                     = False
                	res2@trXMinF                      = t2(0)
                	res2@trXMaxF                      = t2(minyrs-1)
                	res2@trYMinF                      = ymin
                	res2@trYMaxF                      = ymax
                	res2@tmYROn                       = False
                	res2@tmYRLabelsOn                 = False
                	res2@xyLineColor                  = "blue"
                	res2@tmXTLabelFontColor           = "blue"
                	res2@xyDashPattern                = 2
                	res2@gsnRightString               = units
	
                	res2@xyLineThicknessF             = 2
                	plot(k) = gsn_csm_x2y2(wks,t1,t2,data3Diff(:,k),data3Diff(:,k),res1,res2)
		   else
        		res@tiXAxisOn              = False
        		res@gsnCenterString           = "Layer " + (k+1)
        		plot(k) = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data3Diff(:,k),res) 
		   end if
	      end do
              if(isvar("res1") ) then
                     delete(res1)
              end if
              if(isvar("res2") ) then
                     delete(res2)
              end if
	      pres                     = True                   ; panel only resources
	      pres@txString            = long_name            ; common title
	      pres@gsnFrame            = False                  ; don't advance yet so add legend
	      pres@gsnMaximize         = True                   ; make as large as possible
	      pres@gsnPanelBottom      = 0.12                   ; save space for legend

	      gsn_panel(wks,plot,(/(nlev/2),2/),pres)           ; draw panel plot

              lgres                    = True                   ; allow legend resources
	      lgres@gsnFrame           = False                  ; don't advance yet so add legend
              lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
       
       lgres@vpWidthF           = 0.6   ;res@pmLegendWidthF     ; above for consistency   
              lgres@vpHeightF          = 0.15   ;res@pmLegendHeightF    ; ditto
              lgres@lgPerimOn          = False
              lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
              lgres@lgLabelFontHeightF = 0.025                  ; increase font height
              lgres@lgLineLabelStrings = (/"",""/)              ; no labels in lines
              lgres@lgAutoManage       = False                  ; must have to adjust fonts
       if (x2y2Plot .eq. 1) then
          nc = max((/dimsizes(stringtochar(cases(0)))-1,dimsizes(stringtochar(cases(1)))-1/))
          if (nc.lt.20) then
             lgres@vpWidthF        = 0.25
          end if
          if (nc.ge.20.and.nc.lt.40) then
             lgres@vpWidthF        = 0.4
          end if
          if (nc.ge.40.and.nc.lt.60) then
             lgres@vpWidthF        = 0.55
          end if
          if (nc.ge.60) then
             lgres@vpWidthF        = 0.7
          end if             
          gsn_legend_ndc(wks,2,"  "+cases(:1),(1.0-lgres@vpWidthF)/2.,0.1,lgres)         ; draw common legend
    	  else
          nc = dimsizes(stringtochar(legendLabel))-1
          if (nc.lt.20) then
             lgres@vpWidthF        = 0.25
          end if
          if (nc.ge.20.and.nc.lt.40) then
             lgres@vpWidthF        = 0.4
          end if
          if (nc.ge.40.and.nc.lt.60) then
             lgres@vpWidthF        = 0.55
          end if
          if (nc.ge.60) then
             lgres@vpWidthF        = 0.7
          end if          
          gsn_legend_ndc(wks,1,"  "+legendLabel,(1.0-lgres@vpWidthF)/2.,0.15,lgres)         ; draw common legend
       end if           
       frame(wks)

    end if

    delete(plot)
    delete(dataDiff)
    if(isvar("data3Diff") ) then
	delete(data3Diff)
    end if
    delete(res)
   end if ; plot_check loop   
  end do   

  ; remove error file if program completes successfully.
  filo  = wkdir +"/set1Diff_error_file"            
  system("/bin/rm -f " + filo)

end
