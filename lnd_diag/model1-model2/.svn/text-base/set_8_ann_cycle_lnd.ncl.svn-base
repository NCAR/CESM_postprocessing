load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
;************************************************
begin
  print ("=========================================")
  print ("Starting:  set_8_ann_cycle_lnd.ncl")
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
; check for files with only 1 variable

  q = asciiread(wkdir+"/master_set8_ann_cycle_lnd.txt",-1,"string")
  if (dimsizes(q) .eq. 1) then
        tmp = stringtocharacter(q)
        nvars = 1
        scale_type = new(nvars,"string")
        vars       = new(nvars,"string")
        dFlag      = new(nvars,"string")
        do i=0,nvars-1
                scale_type(i) = charactertostring(tmp(0:12))
                vars(i)       = charactertostring(tmp(16:))
                dFlag(i)      = charactertostring(tmp(16:17))
        end do
  else
        tmp = stringtocharacter(asciiread(wkdir+"/master_set8_ann_cycle_lnd.txt",-1,"string"))
        nvars = dimsizes(tmp(:,0))
        scale_type = new(nvars,"string")
        vars       = new(nvars,"string")
        dFlag      = new(nvars,"string")
        do i=0,nvars-1
                scale_type(i) = charactertostring(tmp(i,0:12))
                vars(i)       = charactertostring(tmp(i,16:))
                dFlag(i)      = charactertostring(tmp(i,16:17))
        end do
  end if
  delete(tmp)
  delete(q)
  nmons  = 13
  months = 12   ; number of months


; common resources for contour plots
  cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/redyellowblue.rgb")  ; read in colormap
  plot = new(3,graphic)
  res                        = True        
  res@gsnDraw                = False      
  res@gsnFrame               = False
  res@txFontHeightF          = 0.025
  res@sfXArray               = ispan(0,12,1)
  res@tiMainFontHeightF      = 0.03
  res@tmXBMode               = "Explicit"
  res@tmXBValues             = ispan(0,12,1)
  res@tmXBLabels = (/"J","F","M","A","M","J","J","A","S","O","N","D","J"/) 
  res@cnFillOn  = True
  res@cnLinesOn = False
  res@lbTitleOn = True
  res@lbLabelFontHeightF = 0.018
  res@lbTitleFontHeightF = 0.02
  res@lbBoxMinorExtentF = 0.18

; creating x-axis labels
  stride = (/2,1,1,2,2/)
  stride_diff = (/1,1,1,1,1/)
  cntr  = new((/nvars,15/),float)
  dcntr = new((/nvars,15/),float)

;*************************************************
; main loop
;*************************************************
  
  do i=0,dimsizes(vars)-1 
    prefix  = new(2,"string")
    prefix = new(2,"string")
    useFlag1 = useCommon1 
    useFlag2 = useCommon2 
    if (useFlag1 .eq. "True") then
          name1   = "commonName_1"
    else
          name1   = "caseid_1"
    end if
    if (useFlag2 .eq. "True") then
          name2   = "commonName_2"
    else
          name2   = "caseid_2"
    end if
    name11      = "prefix_1"
    name22      = "prefix_2"
    prefix(0)      = getenv(name11)
    prefix(1)      = getenv(name22)

    in1       = addfile(ptmpdir1+"/"+"/"+prefix(0)+"MONS_climo.nc","r")
    in2       = addfile(ptmpdir2+"/"+"/"+prefix(1)+"MONS_climo.nc","r")
    nlev1      = getfilevardimsizes(in1,"lev")
    lat1       = in1->lat
    lon1       = in1->lon
    time       = in1->time
    nlat1      = dimsizes(lat1)
    nlon1      = dimsizes(lon1)
    nlev2      = getfilevardimsizes(in2,"lev")
    lat2       = in2->lat
    lon2       = in2->lon
    nlat2      = dimsizes(lat2)
    nlon2      = dimsizes(lon2)
    data1 = new((/nmons,nlat1/),float)
    data2 = new((/nmons,nlat2/),float)
    plot = new(3,graphic)
      
   ; *************************
   ; read case 1 model variable
   ; *************************
      info = var_init(vars(i))
      if(isfilevar(in1,vars(i)))then
             x   = in1->$vars(i)$
      else
	if (info@derivedVariable .eq. True) then
             x 	 = derive_land(vars(i),in1)
        else
	    print("variable "+ vars(i)+ " is not a defined variable.")
            plot_check = False
            continue
        end if
      end if
      x1  = x

      delete(x)
      if(all(ismissing(x1)))then
          print("variable "+ vars(i)+ " has all missing values.")
          plot_check1 = False
          continue
      else
          plot_check1 = True
      end if

   ; *************************
   ; read case 2 model variable
   ; *************************
      if(isfilevar(in2,vars(i)))then
        x  = in2->$vars(i)$
      else
	if (info@derivedVariable .eq. True) then
            x  = derive_land(vars(i),in2)
        else
	    print("variable "+ vars(i)+ " is not a defined variable.")
            plot_check = False
            continue
        end if
      end if
      x2  = x
      delete(x)

      if(all(ismissing(x2)))then
          print("variable "+ vars(i)+ " has all missing values.")
          plot_check = False
          continue
      else
          plot_check2 = True
      end if

      ; catch NaNs
      x1 = catchNaN(x1)
      x2 = catchNaN(x2)

      info = var_init(vars(i))
      x1    = scale_var(x1,scale_type(i),info)
      x2    = scale_var(x2,scale_type(i),info)

      x11 = new((/13,nlat1/),float)
      x11!0 = "time"
      x11&time = ispan(1,13,1)
      x11!1 = "lat"
      x11&lat = lat1

      x22 = new((/13,nlat2/),float)
      x22!0 = "time"
      x22&time = ispan(1,13,1)
      x22!1 = "lat"
      x22&lat = lat2

      do m = 0,11
      	x11(m,:) = dim_avg_Wrap(x1(m,:,:))
      	x22(m,:) = dim_avg_Wrap(x2(m,:,:))
      end do

      x11(12,:) = (/x11(0,:)/)		; wrap around to january
      x22(12,:) = (/x22(0,:)/)		; wrap around to january

; extract years averaged for plotting
    if (isatt(in1,"yrs_averaged")) then
        yrs_ave1 = in1@yrs_averaged
    end if
    if (isatt(in2,"yrs_averaged")) then
        yrs_ave2 = in2@yrs_averaged
    end if

    cases    = new(2,"string")
    cases(0) = getenv(name1)
    cases(1) = getenv(name2)
    cases(0) = cases(0) + " (" + yrs_ave1 + ")"
    cases(1) = cases(1) + " (" + yrs_ave2 + ")"

; calculate zonal values
      if(plot_check1.eq.False)then
	  continue
      else
    	  data1 = x11
    	  data2 = x22
      end if

     
;*************************************************
; create plot
;*************************************************
     if(plot_check1.eq.False)then
	  continue
     else
        plot = new(3,graphic)
    	varDiff = data1
    	varDiff = (/data1-data2/)        ; case difference

    	wks = gsn_open_wks(plot_type,wkdir + "set8_ann_cycle_lnd_"+vars(i))
	gsn_define_colormap(wks,cmap)
   	 
    	pres                       = True
        pres@gsnMaximize           = True                   ; make as large as possible
        pres@gsnPaperOrientation   = "Portrait"
        pres@gsnPanelCenter        = True
        pres@gsnPanelBottom        = 0.15                   ; save space for legend
        pres@gsnPanelRowSpec       = True
        pres@gsnFrame              = False                  ; don't advance yet so add legend

    	res                        = True
        res@gsnDraw                = False                  ; don't advance yet so add legend
        res@gsnFrame               = False                  ; don't advance yet so add legend

; case contour plots of time(x) vs. latitude(y)
   	min1 = min(data1)
   	max1 = max(data1)
   	min2 = min(data2)
   	max2 = max(data2)
	if (max1 .gt. max2) then
		useMax = max1
	else
		useMax = max2
	end if
	if (min1 .lt. min2) then
		useMin = min1
	else
		useMin = min2
	end if
     	res@lbOrientation = "Horizontal"
     	res@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+" MAX = "+sprintf("%6.2f",max1)
        maxLevel = 9
        mnmxint = nice_mnmxintvl( useMin, useMax, maxLevel, True)
        res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
        res@cnMinLevelValF       = mnmxint(0)
        res@cnMaxLevelValF       = mnmxint(1)
        res@cnLevelSpacingF      = mnmxint(2)
	
    	res@pmLegendDisplayMode    = "Never"
    	res@pmLegendSide           = "Bottom"            
    	res@pmLegendParallelPosF   = 0.50           
    	res@pmLegendOrthogonalPosF = 0.02              
    	res@pmLegendWidthF         = 0.25             
    	res@pmLegendHeightF        = 0.08 
    	res@lgLabelFontHeightF     = 0.020
    	res@lgPerimOn              = True
    	res@tmXBMinorOn            = False

        lgres                       = True                   ; allow legend resources
        lgres@lgPerimOn             = True
        lgres@lgLabelFontHeightF    = 0.040                  ; increase font height
        lgres@lgAutoManage          = False                  ; must have to adjust fonts
        lgres@vpWidthF              = 0.35
        lgres@vpHeightF             = 0.10

    	res@tiMainString           = cases(0)
        plot(0) = gsn_csm_lat_time(wks,data1(lat|:,time|:),res)
    	res@tiMainString           = cases(1)
        plot(1) = gsn_csm_lat_time(wks,data2(lat|:,time|:),res)
    	res@tiMainString           = "Case1 - Case2"
        plot(2) = gsn_csm_lat_time(wks,varDiff(lat|:,time|:),res)

        gsn_panel(wks,plot,(/2,1/),pres)               ; draw panel plot

	frame(wks)
    	delete(x1)
    	delete(x2)
    	delete(x11)
    	delete(x22)
    	delete(plot)
    	delete(cases)
    	delete(data1)
    	delete(data2)
    	delete(varDiff)
    end if	; plot_check loop   
  end do   	; end variable plot

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set8_ann_cycle_lnd_error_file"                   
  system("/bin/rm -f " + filo)  

end
