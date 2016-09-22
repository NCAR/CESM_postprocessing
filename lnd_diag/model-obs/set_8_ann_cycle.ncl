load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
;************************************************
begin
  print ("=========================================")
  print ("Starting:  set_8_ann_cycle.ncl; zonal tracers")
  print ("Start Time: "+systemfunc("date") )
  print ("=========================================")
  ptmpdir = getenv("PTMPDIR_1")
  wkdir   = getenv("WKDIR")
  useCommon1 = getenv("UseCommonName_1")
  plot_type  = getenv("PLOTTYPE")


; the set lists contains two columns of information. This comes into
; NCL as one long string that we need to parse out.
  tmp = stringtocharacter(asciiread(wkdir+"/master_set8_ann_cycle.txt",-1,"string"))
  nvars  = dimsizes(tmp(:,0))
  scale_type = new(nvars,"string")
  vars       = new(nvars,"string")
  dFlag      = new(nvars,"string")
  do i=0,nvars-1
    scale_type(i) = charactertostring(tmp(i,0:12))
    vars(i)       = charactertostring(tmp(i,16:))
    dFlag(i)      = charactertostring(tmp(i,16:17))
  end do
  nmons  = 13
  months = 12   ; number of months


; common resources for contour plots
  cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/redyellowblue.rgb")  ; read in colormap
  ; cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/amwg.rgb")  ; read in colormap
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
    prefix   = new(2,"string")
    useFlag1 = useCommon1 
    if (useFlag1 .eq. "True") then
          name1   = "commonName_1"
    else
          name1   = "caseid_1"
    end if
    name11      = "prefix_1"
    prefix(0)      = getenv(name11)
    caseid_1    = getenv("caseid_1")
    cam         = getenv("atm_modelstream_1")

    in1    = addfile(ptmpdir+"/"+"/atm/"+caseid_1+"."+cam+".MONS_climo.nc","r")
    nlev1  = getfilevardimsizes(in1,"lev")
    lat1   = in1->lat
    lon1   = in1->lon
    time   = in1->time
    nlat1  = dimsizes(lat1)
    nlon1  = dimsizes(lon1)
    data1  = new((/nmons,nlat1/),float)
    plot_check = False
      
   ; *************************
   ; read case 1 model variable
   ; *************************
      if (dFlag(i) .eq. "SF") then 
        if(isfilevar(in1,vars(i)))then
                x = in1->$vars(i)$
		plot_check = True
        else
                if (vars(i) .eq. "SFCO2_LND") then
        	    if(isfilevar(in1,"SFCO2_LN"))then
                        x = in1->SFCO2_LN
			plot_check = True
                    end if
                end if
                if (vars(i) .eq. "SFCO2_OCN") then
        	    if(isfilevar(in1,"SFCO2_OC"))then
                        x = in1->SFCO2_OC
			plot_check = True
                    end if
                end if
                if (vars(i) .eq. "SFCO2_FFF") then
        	    if(isfilevar(in1,"SFCO2_FF"))then
                        x = in1->SFCO2_FF
			plot_check = True
                    end if
                end if
        end if
      else
        info = var_init(vars(i))
      	if(isfilevar(in1,vars(i)))then
         	x = in1->$vars(i)$
		plot_check = True
      	else
		if (info@derivedVariable .eq. True) then
          		x = derive_land(vars(i),in1)
			plot_check = True
        	else
            		print("variable "+ vars(i)+ " is not a defined variable.")
            		plot_check = False
            		continue
        	end if
      	end if
      end if

      if (plot_check .eq. True) then
         rank = dimsizes(dimsizes(x))
         if(rank .eq. 4) then
	        x1  = x(:,nlev1-1,:,:)	; lev0 = top of atm 
         else
	           x1  = x
         end if

         delete(x)
         if(all(ismissing(x1)))then
             print("variable "+ vars(i)+ " has all missing values")
             plot_check1 = False
             continue
         end if
   
         info = var_init(vars(i))
         x1    = scale_var(x1,scale_type(i),info)

         ; catch NaNs
         x1 = catchNaN(x1)
   
         x11 = new((/13,nlat1/),float)
         x11!0 = "time"
         x11&time = ispan(1,13,1)
         x11!1 = "lat"
         x11&lat = lat1
      
         do m = 0,11
      	      x11(m,:) = dim_avg_Wrap(x1(m,:,:))
         end do
      
         x11(12,:) = (/x11(0,:)/)		; wrap around to january
      
      ; extract years averaged for plotting
          if (isatt(in1,"yrs_averaged")) then
              yrs_ave1 = in1@yrs_averaged
          end if
      
          cases    = new(2,"string")
          cases(0) = getenv(name1)
          cases(0) = cases(0) + " (" + yrs_ave1 + ")"
          cases(1) = "No Obs"
      
      ; calculate zonal values
          if(plot_check1.eq.False)then
	        continue
          else
    	        data1 = x11
          end if
      
           
      ;*************************************************
      ; create plot
      ;*************************************************
           if(plot_check1.eq.False)then
	     continue
           else
           plot = new(1,graphic)
   
    	   wks = gsn_open_wks(plot_type,wkdir + "set8_ann_cycle_"+vars(i))
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
  	   maxLevel = 9
  	   mnmxint = nice_mnmxintvl( min1, max1, maxLevel, True)
  	   res@cnLevelSelectionMode   = "ManualLevels" ; ncl defined contour levels
  	   res@cnMinLevelValF         = mnmxint(0)
  	   res@cnMaxLevelValF         = mnmxint(1)
  	   res@cnLevelSpacingF        = mnmxint(2)
     	   res@lbOrientation = "Horizontal"
     	   res@lbTitleString = "MIN = "+sprintf("%4.2f",min1)+" MAX = "+sprintf("%4.2f",max1)
   	
    	   res@pmLegendDisplayMode    = "Never"
    	   res@pmLegendSide           = "Right"            
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
   
           gsn_panel(wks,plot,1,pres)               ; draw panel plot
   
	   frame(wks)
    	   delete(x1)
    	   delete(x11)
    	   delete(plot)
    	   delete(cases)
    	   delete(data1)
	   delete(max1)
	   delete(min1)
         end if	; Inner plot_check loop   
       end if	; Outer plot_check loop   
     end do   	; end variable plot

     ; remove error file if program completes successfully.  
     filo  = wkdir +"/set8_ann_cycle_error_file"                   
     system("/bin/rm -f " + filo)  

end
