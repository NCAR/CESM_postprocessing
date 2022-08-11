load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
;************************************************
; NOTE:  Adapted from plot_trends.ncl (KOleson code)
;        Revision Author:  Nan Rosenbloom Spring 2005
;************************************************
begin
 print ("=========================================")
 print ("Starting:  set_1.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
  ptmpdir    = getenv("PTMPDIR_1")
  wkdir      = getenv("WKDIR")
  useCommon1 = getenv("UseCommonName_1")
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

;*************************************************
; get case names and create filenames to read in
;*************************************************
  nyrs  = stringtointeger(getenv("trends_num_yrs_1"))
  fyr   = stringtointeger(getenv("trends_first_yr_1"))
;;  print ("DEBUG nyrs = "+nyrs)
;;  print ("DEBUG fyr = "+fyr)

;;  nyrs  = getenv("trends_num_yrs_1")
;;  fyr   = getenv("trends_first_yr_1")

; ************************************************
; open new output file for intermediate variables
; ************************************************
  lastyr   = fyr + nyrs - 1
  name1    = "prefix_"+1
  prefix1  = getenv(name1)
  filo  = ptmpdir +"/"+prefix1+"_ANN_globalClimo.nc"
  print ("DEBUG filo = "+filo)
  system("/bin/rm -f " + filo)
  delete(filo)
  fout1 = addfile(ptmpdir+"/"+prefix1+"_ANN_globalClimo.nc","c")

  fileAtt               = True
  fileAtt@history       = "global climatology calculated by set_1.ncl:global_values():lnd_func.ncl"
  fileAtt@model_years   = fyr +"-"+ lastyr
  fileAtt@creation_date = systemfunc("date")
  fileattdef(fout1, fileAtt)

  dimNames      = (/"time"/)
  dimSizes      = (/-1/)
  dimUnlim      = (/True/)

  filedimdef(fout1,dimNames,dimSizes,dimUnlim)
  name11     = "prefix_1"
  prefix     = getenv(name11)
  in         = addfile(ptmpdir+ "/" +prefix+"ANN_ALL.nc","r")
  print ("DEBUG file in = "+ptmpdir+"/"+prefix+"ANN_ALL.nc")
  nlev = 0
  if(isfilevar(in,"levsoi")) then
  	nlev  = getfilevardimsizes(in,"levsoi")
  end if
  if(isfilevar(in,"levgrnd")) then
    	nlev  = getfilevardimsizes(in,"levgrnd")
  end if
  if (nlev .eq. 0)
    	print("FATAL ERROR:  nlev = 0")
	exit
  end if
; truncate soil layers if needed
  if (nlev .gt. 10) then 
           print("Truncating soil levels to 10 levels [caseid: "+prefix(0)+"  nlev:  " + nlev +"]") 
           nlev = 10 
  end if
  landfrac   = in->landfrac
  time       = in->time
  area       = in->area
  ; We only have area for land gridcells and we need area over all gridcells
  ; to calculate CPL_ENERGY_BAL with respect to global area consistent with
  ; calculation in the coupler
  areag    = dble2flt(area_global_rectilinear_grid(lat1,lon1,False))
  lat        = in->lat 
  lon        = in->lon 
  if(nyrs .ne. dimsizes(time)) then
	print("   ")
	print("   ")
	print("FATAL ERROR:")
	print("ANN_ALL.nc time dimension wrong:  ANN_ALL.nc=(" + dimsizes(time) + ") vs trends_num_yrs=(" + nyrs +")")
	print("Exiting Set_1.ncl")
	print("   ")
	print("   ")
	exit
  end if

;*************************************************
; main loop
;*************************************************
  do i=0,dimsizes(vars)-1 
    cases  = new(2,"string")
    data   = new((/2,nyrs/),"float")
    data3  = new((/2,nyrs,10/),"float")    ; how do we not hardwire this?
    if (useCommon1 .eq. "True") then
        name1  = "commonName_1"
    else
        name1  = "caseid_1"
    end if
    cases(0)   = "  "+getenv(name1)
;;    print ("DEBUG 1 cases(0) = "+cases(0))
    cases(1)   = "  No Obs"
    filevar = vars(i)
    info = var_init(vars(i))
    if(isfilevar(in,filevar) .and. info@derivedVariable .eq. False)then
        if (c13Flag(i) .eq. "C13_") then
           x = derive_del13C(vars(i),in,scale_type(i),nyrs,1)
        else
           if (c14Flag(i) .eq. "C14_") then
              x = derive_del14C(vars(i),in,scale_type(i),nyrs,1)
           else
              x = in->$filevar$
           end if
	end if
;;	printVarSummary(x)
        plot_check = True
	delete(filevar)
    else 
        info = var_init(vars(i))
        if (info@derivedVariable .eq. True) then
            x = derive_land(  vars(i),in)
            if(all(ismissing(x)))then
              print("variable "+ vars(i)+ " contains only missing values.")
              plot_check = False
              delete(x)
              continue
            else
              plot_check = True
            end if
         else
              print("variable "+ vars(i)+ " is not a defined variable.")
              plot_check = False
              continue
         end if
    end if

    ; catch NaNs
    x = catchNaN(x)

    rank1 = dimsizes(dimsizes(x))
    if (rank1 .eq. 4) then
	if (nlev .gt. 10) then
          print("Truncating soil levels to 10 levels [caseid: "+prefix+"  "+vars(i)+" nlev:  " + nlev +"]")
          nlev = 10
	end if
    else
	rank1 = 3
    end if

    if(plot_check.eq.True)then
       print(" " + vars(i))
       info = var_init(vars(i))
       x    = scale_var(x,scale_type(i),info)

       if (isatt(in,"yrs_averaged")) then
                yrs_ave = in@yrs_averaged
       		cases(0) = cases(0) + " (" + yrs_ave + ")"
;;		print ("DEBUG 2 cases(0) = "+cases(0))
       end if


; calculate global summation or global total      
       if (c13Flag(i) .ne. "C13_" .and. c14Flag(i) .ne. "C14_") then 
          if (vars(i) .eq. "CPL_ENERGY_BAL") then
            var_plot = global_values(vars(i),x,areag,landfrac,scale_type(i),nyrs,nlev)
          else
            var_plot = global_values(vars(i), x,area,landfrac,scale_type(i),yrs(m),nlev)
          end if
       else
          var_plot = x    ; del13C and del14C vars are globally averaged before the del value is calculated
       end if

       rank2 = dimsizes(dimsizes(var_plot))
       if(rank2.eq.1)then
           data(0,:)    = var_plot
       	   filevardef(fout1,vars(i),typeof(var_plot),(/"time"/))    
       	   if(i .eq. 0) then
           	   filevardef(fout1,"time",typeof(time),"time")
       	   end if
       	   fout1->time = time
       	   fout1->$vars(i)$ = var_plot
       else
           data3(0,:,:) = var_plot
       end if
       long_name = x@long_name
       units     = x@units
       delete(var_plot)
       delete(x)
;*************************************************
; create plot
;*************************************************
    wks = gsn_open_wks(plot_type,wkdir + "set1_" + vars(i))
    print ("Creating: "+wkdir + "set1_" + vars(i)) 
 
    res                        = True
    res@tiXAxisOn              = False
    res@gsnRightString         = units
    if (vars(i) .eq. "C13_NEP" .or. vars(i) .eq. "C13_NEE") then
    	res@tiYAxisString      = vars(i) + "  ("+units+")  [ValidRange:-40-0]"
    else
    	res@tiYAxisString      = vars(i)+"  ("+units+")"
    end if

    res@xyDashPatterns         = (/0.,16./)          ; solid, dashed
    res@xyLineThicknesses      = (/2.,2./)
    res@xyLineColors           = (/"red","blue"/)

    res@pmLegendDisplayMode    = "Never"
    res@tmXBMinorOn            = False
    res@tmYLFormat             = "0@!;*?5g"

    if(rank1.eq.3)then
        res@tiMainString           = long_name
        res@gsnFrame               = False
        plot = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data,res)
 
        lgres                    = True                   ; allow legend resources
        lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
        lgres@vpHeightF          = 0.11
        lgres@lgPerimOn          = False
        lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
        lgres@lgLabelFontHeightF = 0.04                  ; increase font height
        lgres@lgLineLabelStrings = (/"",""/)              ; no labels in lines
        lgres@lgAutoManage       = False                  ; must have to adjust fonts
        nc = max((/dimsizes(stringtochar(cases(0)))-1,dimsizes(stringtochar(cases(1)))-1/))
        if (nc.lt.20) then
           lgres@vpWidthF        = 0.35
        end if
        if (nc.ge.20.and.nc.lt.40) then
           lgres@vpWidthF        = 0.5
        end if
        if (nc.ge.40.and.nc.lt.60) then
           lgres@vpWidthF        = 0.65
        end if
        if (nc.ge.60) then
           lgres@vpWidthF        = 0.8
        end if  

        gsn_legend_ndc(wks,2,cases,(1.0-lgres@vpWidthF)/2.,0.1,lgres)         ; draw common legend
	frame(wks)     ; add frame to support plot_type = png
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
        if(isfilevar(in,"levsoi")) then
        	lev = in->levsoi
        end if
        if(isfilevar(in,"levgrnd")) then
        	lev = in->levgrnd
        end if
        do k=0,nlev-1
          res@tiXAxisOn              = False
          res@gsnCenterString          = "Layer " + (k+1)
          plot(k) = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data3(:,:,k),\
          res) 
        end do
        pres                     = True                   ; panel only resources
        pres@txString            = long_name            ; common title
        pres@gsnFrame            = False                  ; don't advance yet so add legend
        pres@gsnMaximize         = True                   ; make as large as possible
        pres@gsnPanelBottom      = 0.12                   ; save space for legend
  
        gsn_panel(wks,plot,(/(nlev/2),2/),pres)           ; draw panel plot

        lgres                    = True                   ; allow legend resources
        lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
        lgres@vpHeightF          = 0.11
        lgres@lgPerimOn          = False
        lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
        lgres@lgLabelFontHeightF = 0.025                  ; increase font height
        lgres@lgLineLabelStrings = (/"",""/)              ; no labels in lines
        lgres@lgAutoManage       = False                  ; must have to adjust fonts
        nc = max((/dimsizes(stringtochar(cases(0)))-1,dimsizes(stringtochar(cases(1)))-1/))
        if (nc.lt.20) then
           lgres@vpWidthF        = 0.35
        end if
        if (nc.ge.20.and.nc.lt.40) then
           lgres@vpWidthF        = 0.5
        end if
        if (nc.ge.40.and.nc.lt.60) then
           lgres@vpWidthF        = 0.65
        end if
        if (nc.ge.60) then
           lgres@vpWidthF        = 0.8
        end if  
        
        gsn_legend_ndc(wks,2,cases,(1.0-lgres@vpWidthF)/2.,0.13,lgres)         ; draw common legend
	frame(wks)         ; add frame to support plot_type = png

      end if	; rank loop
      delete(plot)
      delete(res)
      delete(lgres)
    end if	; plotting loop for active variables
  end do

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set1_error_file"              
  system("/bin/rm -f " + filo)  

end
