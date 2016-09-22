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
  ptmpdir = getenv("PTMPDIR_1")
  wkdir   = getenv("WKDIR")
  useCommon1 = getenv("UseCommonName_1")
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
;;  nyrs1    = stringtointeger(getenv("trends_num_yrs_1"))
;;  fyr1     = stringtointeger(getenv("trends_first_yr_1"))
  nyrs1    = getenv("trends_num_yrs_1")
  fyr1     = getenv("trends_first_yr_1")

  nyrs = nyrs1
  fyr = fyr1
; ************************************************
; open new output file for intermediate variables
; ************************************************
  name1      = "prefix_"+1
  prefix1  = getenv(name1)
  filo  = ptmpdir +"/"+"/atm/"+prefix1+"_ANN_atm_globaltrends.nc"
  system("/bin/rm -f " + filo)
  delete(filo)
  fout1 = addfile(ptmpdir+"/"+"/atm/"+prefix1+"_ANN_atm_globaltrends.nc","c")

  fileAtt               = True
  fileAtt@history       = "annual global trends calculated by set_8_trends.ncl:wgt_areaave()"
  fileAtt@creation_date = systemfunc("date")
  fileattdef(fout1, fileAtt)

  dimNames      = (/"time"/)
  dimSizes      = (/-1/)
  dimUnlim      = (/True/)

  filedimdef(fout1,dimNames,dimSizes,dimUnlim)
;*************************************************
; main loop
;*************************************************
  do i=0,dimsizes(vars)-1 
      data   = new((/1,nyrs/),"float")
      cases  = new(2,"string")
      prefix = new(1,"string")
      useFlag = useCommon1 
      if (useFlag .eq. "True") then
          name   = "commonName_"+1
      else
          name   = "caseid_"+1
      end if
      name2      = "prefix_"+1
      cases(0)   = getenv(name)
      prefix(0)  = getenv(name2)
      caseid_1    = getenv("caseid_1")
      cam         = getenv("atm_modelstream_1")
      in         = addfile(ptmpdir+"/"+"/atm/"+caseid_1+"."+cam+".ANN_ALL.nc","r")
      time       = in->time
      lev        = in->lev
      gw         = in->gw
      nlev       = dimsizes(lev)
      if (nlev .ne. 26) then
	   print("Error in Number of atm Levels:" + nlev + " vs 26 ") 
      	   exit
      end if

     plot_check = True
     if (dFlag(i) .eq. "SF") then
        if(isfilevar(in,vars(i)))then
                xx  = in ->$vars(i)$
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
	
      	; catch NaNs
      	x = catchNaN(x)
	
	; scale variable
      	x    = scale_var(x,scale_type(i),info)
	
	; extract years averaged for plotting
      	if (isatt(in,"yrs_averaged")) then
          	yrs_ave = in@yrs_averaged
      	end if
	
      	cases(0) = cases(0) + " (" + yrs_ave + ")"
      	cases(1) = "No Obs"
	
	; caculate weighted areal average over time
      	tmp  = stringtocharacter(scale_type(i)) ; 
      	type = charactertostring(tmp(6:9))   ; checking for Mean or Totl
	
      	avg_x    = new(nyrs,typeof(x))            ; no level
      	if (type .eq. "Mean") then
      		avg_x  = wgt_areaave(x,gw,1.0,1)
      	end if
	
      	if (type .eq. "Totl") then
      		avg_x  = ( wgt_areaave(x,gw,1.0,1) ) * totalGlobalArea * 1e6	; km2 to m2
      	end if
	
; write to output file -------------------
      	filevardef(fout1,vars(i),"float",(/"time"/))
      	if(i .eq. 0) then
         	filevardef(fout1,"time",typeof(time),"time")
      	end if
      	fout1->time = time
      	fout1->$vars(i)$ = avg_x
	
; end write to output file -------------------

        data(0,:) = avg_x
  
        delete(avg_x)
        delete(gw)
        delete(tmp)
        delete(type)
;*************************************************
; create plot
;*************************************************
    	wks = gsn_open_wks(plot_type,wkdir + "set8_trends_" + vars(i))
    
    	res                        = True
    	res@tiXAxisString          = "Simulation Year"
    	res@gsnRightString         = x@units
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

    	res@tiMainString           = x@long_name
    	plot = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data,res)   
    	delete(x)
    	delete(plot)
    	delete(res)
    end if	; plot_check loop   
  end do   

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set8_trends_error_file"                   
  system("/bin/rm -f " + filo)  

end
