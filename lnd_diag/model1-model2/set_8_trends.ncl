load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
;************************************************
begin
  print ("=========================================")
  print ("Starting:  set_8_trends.ncl")
  print ("Start Time: "+systemfunc("date") )
  print ("=========================================")
  ptmpdir1 = getenv("PTMPDIR_1")
  ptmpdir2 = getenv("PTMPDIR_2")
  wkdir   = getenv("WKDIR")
  useCommon1 = getenv("UseCommonName_1")
  useCommon2 = getenv("UseCommonName_2")
  plot_type  = getenv("PLOTTYPE")
  totalGlobalArea = 510099683	; km2


; the set lists contains two columns of information. This comes into
; NCL as one long string that we need to parse out.
  tmp = stringtocharacter(asciiread(wkdir+"/master_set8_trends.txt",-1,"string"))
  nvar = dimsizes(tmp(:,0))
  scale_type = new(nvar,"string")
  vars       = new(nvar,"string")
  dFlag      = new(nvar,"string")
  do i=0,nvar-1
    scale_type(i) = charactertostring(tmp(i,0:12))
    vars(i)       = charactertostring(tmp(i,16:))
    dFlag(i)      = charactertostring(tmp(i,16:17))
  end do
  delete(tmp)

;*************************************************
; get case names and create filenames to read in
;*************************************************
  nyrs1    = stringtointeger(getenv("trends_num_yrs_1"))
  fyr1     = stringtointeger(getenv("trends_first_yr_1"))
  nyrs2    = stringtointeger(getenv("trends_num_yrs_2"))
  fyr2     = stringtointeger(getenv("trends_first_yr_2"))
  matchYr1 = stringtointeger(getenv("trends_match_yr_1"))
  matchYr2 = stringtointeger(getenv("trends_match_yr_2"))
trendsFlag = stringtointeger(getenv("trends_match_Flag"))

  yrs    = new((/2/),"integer")
  offset = new((/2/),"integer")
  if (nyrs1 .ne. nyrs2 .or. fyr1 .ne. fyr2 .or. trendsFlag .eq. 1) then
        x2y2Plot = 1				; 1=ON, 0=OFF
	yrDifferential = matchYr2 - matchYr1
        fy = min( (/fyr1,(fyr2-yrDifferential)/) )
        ly = max( (/(fyr1+nyrs1),(fyr2-yrDifferential+nyrs2)/) )
        nyrs = ly - fy

        fy1 = fy
        fy2 = fy + yrDifferential
        if (fyr1 .eq. fy) then
                offset(0) = 0
                offset(1) = matchYr2 - fy2
        else
                offset(1) = 0
                offset(0) = matchYr1 - fy1
        end if
        tspan = ispan(0,nyrs-1,1)
        t1 = tspan + fy
        t2 = tspan + fy + yrDifferential
  else
        x2y2Plot = 0				; 1=ON, 0=OFF
        nyrs = nyrs1
        fyr  = fyr1
	offset(0) = 0
	offset(1) = 0
  end if
  yrs(0) = nyrs1
  yrs(1) = nyrs2

; ************************************************
; open new output files for intermediate variables
; ************************************************
  name1      = "prefix_"+1
  name2      = "prefix_"+2
  prefix1  = getenv(name1)
  prefix2  = getenv(name2)
  filo1  = ptmpdir1 +"/"+"/atm/"+prefix1+"_ANN_atm_globalClimo1.nc"
  filo2  = ptmpdir2 +"/"+"/atm/"+prefix2+"_ANN_atm_globalClimo2.nc"
  system("/bin/rm -f " + filo1)
  system("/bin/rm -f " + filo2)
  delete(filo1)
  delete(filo2)
  fout1 = addfile(ptmpdir1+"/"+"/atm/"+prefix1+"_ANN_atm_globalClimo1.nc","c")
  fout2 = addfile(ptmpdir2+"/"+"/atm/"+prefix2+"_ANN_atm_globalClimo2.nc","c")

  fileAtt               = True
  fileAtt@history       = "global climatology calculated by set_8_trends.ncl"
  fileAtt@creation_date = systemfunc("date")
  fileattdef(fout1, fileAtt)

  dimNames      = (/"time"/)
  dimSizes      = (/-1/)             ; bummer that this is hardwired....
  dimUnlim      = (/True/)

  filedimdef(fout1,dimNames,dimSizes,dimUnlim)
  filedimdef(fout2,dimNames,dimSizes,dimUnlim)
;*************************************************
; main loop
;*************************************************
  do i=0,dimsizes(vars)-1 
    data   = new((/2,nyrs/),"float")
    cases  = new(2,"string")
    prefix = new(2,"string")
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
      name2      = "prefix_"+(m+1)
      cases(m)   = getenv(name)
      prefix(m)  = getenv(name2)
      caseid(m)  = getenv("caseid_"+(m+1))
      cam(m)     = getenv("atm_modelstream_"+(m+1))
      in         = addfile(ptmpdir1+"/"+"/atm/"+caseid(m)+"."+cam+".ANN_ALL.nc","r")
      lev        = in->lev
      gw         = in->gw
      time	 = in->time
      nlev       = dimsizes(lev)
      if (nlev .ne. 26) then
	   print("Error in Number of atm Levels:" + nlev + " vs 26 ") 
      	   exit
      end if
      if (dFlag(i) .eq. "SF") then 
        if(isfilevar(in,vars(i)))then
                xx = in->$vars(i)$
        else
                if (vars(i) .eq. "SFCO2_LND") then
                    if(isfilevar(in,"SFCO2_LN"))then
                        xx = in ->SFCO2_LN
                    end if
                end if
                if (vars(i) .eq. "SFCO2_OCN") then
                    if(isfilevar(in,"SFCO2_OC"))then
                        xx = in ->SFCO2_OC
                    end if
                end if
                if (vars(i) .eq. "SFCO2_FFF") then
                    if(isfilevar(in,"SFCO2_FF"))then
                        xx = in ->SFCO2_FF
                    end if
                end if
        end if
      else
                info = var_init(vars(i))
                if(isfilevar(in,vars(i)))then
                        xx   = in->$vars(i)$
                        plot_check = True
                else
                        if (info@derivedVariable .eq. True) then
                                xx = derive_land(  vars(i),in)
                        else
                                print("variable "+ vars(i)+ " is not a defined variable.")
                                plot_check = False
                                continue
                        end if
                end if
      end if
      if (.not. isvar("xx")) then
                plot_check = False
      end if
      if (plot_check .eq. False) then
                continue
      else
      	rank       = dimsizes(dimsizes(xx))
      	if(rank .eq. 4) then
             x  = xx(:,nlev-1,:,:)     ; lev0 = top of atm 
      	else
             x  = xx
      	end if
      	delete(xx)
      	delete(rank)

      	if(all(ismissing(x)))then
      	  	print("variable "+ vars(i)+ " has all missing values")
       	  	plot_check = False
       	  	continue
       	else
       	  	plot_check = True
       	end if
        info = var_init(vars(i))

; screen for NaNs
        x = catchNaN(x)

; scale variable
        x    = scale_var(x,scale_type(i),info)

; extract years averaged for plotting
        if (isatt(in,"yrs_averaged")) then
            yrs_ave = in@yrs_averaged
        end if

        cases(m) = cases(m) + " (" + yrs_ave + ")"

; caculate weighted areal average over time
        tmp  = stringtocharacter(scale_type(i)) ; 
        type = charactertostring(tmp(6:9))   ; checking for Mean or Totl

        avg_x    = new(yrs(m),typeof(x))            ; no level
        if (type .eq. "Mean") then
      	  avg_x  = wgt_areaave(x,gw,1.0,1)
        end if
  
        if (type .eq. "Totl") then
      	  avg_x  = ( wgt_areaave(x,gw,1.0,1) ) * totalGlobalArea * 1e6	; km2 to m2
        end if

        if (m .eq. 0) then
             fout = fout1
        else
             fout = fout2
        end if
        filevardef(fout,vars(i),"float",(/"time"/))
        if (i .eq. 0) then
      	   filevardef(fout,"time",typeof(time),"time")
        end if
        fout->time = time
        fout->$vars(i)$ = avg_x

        data(m,offset(m):(offset(m)+yrs(m)-1) ) = avg_x
        units	= x@units
        long_name = x@long_name

        delete(avg_x)
        delete(gw)
        delete(tmp)
        delete(type)
        delete(time)
        delete(x)
      end if	; plot_check loop
    end do	; m case loop
;*************************************************
; create plot
;*************************************************
   if(plot_check.eq.False)then
	  continue
   else
    	wks = gsn_open_wks(plot_type,wkdir + "set8_trends_" + vars(i))
    
    	res                        = True
    	res@tiXAxisString          = "Simulation Year"
	res@gsnRightString         = units
    	res@tiYAxisString          = vars(i)
    	res@tmYLFormat             = "0@!;*?5g"

    	res@xyDashPatterns         = (/0.,16./)          ; solid, dashed
    	res@xyLineThicknesses      = (/2.,2./)
    	res@xyLineColors           = (/"red","blue"/)

    	res@pmLegendDisplayMode    = "Always"
    	res@pmLegendSide           = "Bottom"            
    	res@pmLegendParallelPosF   = 0.50           
    	res@pmLegendOrthogonalPosF = 0.02              
    	res@pmLegendWidthF         = 0.25             
    	res@pmLegendHeightF        = 0.08 
    	res@lgLabelFontHeightF     = 0.020
    	res@lgPerimOn              = True
    	res@xyExplicitLegendLabels = cases

    	res@tmXBMinorOn            = False
        res@tiMainString           = long_name

        if (x2y2Plot .eq. 1) then
                ymin = min( (/data(0,:),data(1,:)/) )
                ymax = max( (/data(0,:),data(1,:)/) )

		yrange = ymax-ymin
                ypad = yrange * 0.05
                ymin = ymin - ypad
                ymax = ymax + ypad

                res1    = True
                res1@gsnFrame                     = False

                res1@tiMainString                 = long_name
                res1@tiXAxisString                = "Simulation Year"
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
                res1@pmLegendDisplayMode          = "Always"
                res1@pmLegendSide                 = "Bottom"
                res1@pmLegendParallelPosF         = 0.50
                res1@pmLegendOrthogonalPosF       = 0.02
                res1@pmLegendWidthF               = 0.25
                res1@pmLegendHeightF              = 0.08
                res1@lgLabelFontHeightF           = 0.020
                res1@lgPerimOn                    = True
                res1@xyExplicitLegendLabels       = cases

                res2    = True
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
                res2@gsnRightString               = units

                res2@xyLineThicknessF             = 2
                plot = gsn_csm_x2y2(wks,t1,t2,data(0,:),data(1,:),res1,res2)
                delete(res1)
                delete(res2)
		frame(wks)
        else
    		plot = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data,res)   
	end if
    	delete(plot)
    	delete(res)
    end if	; plot_check loop   
  end do   
  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set8_trends_error_file"                   
  system("/bin/rm -f " + filo)  
end


