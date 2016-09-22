load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
;************************************************
begin
 print ("=========================================")
 print ("Starting:  set_8_DJF-JJA_contour.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
  ptmpdir = getenv("PTMPDIR_1")
  wkdir   = getenv("WKDIR")
  raster  = getenv("raster")
  useCommon1 = getenv("UseCommonName_1")
  plot_type  = getenv("PLOTTYPE")

; the set lists contains two columns of information. This comes into
; NCL as one long string that we need to parse out.
  tmp = stringtocharacter(asciiread(wkdir+"/master_set8_contourDJF-JJA.txt",-1,"string"))
  nvar = dimsizes(tmp(:,0))
  scale_type = new(nvar,"string")
  vars       = new(nvar,"string")
  dFlag      = new(nvar,"string")
  do i=0,nvar-1
    scale_type(i) = charactertostring(tmp(i,0:12))
    vars(i)       = charactertostring(tmp(i,16:))
    dFlag(i)      = charactertostring(tmp(i,16:17))
  end do

;*************************************************
; get case names and create filenames to read in
;*************************************************
  sig_lvl = getenv("sig_lvl") 
;;  zoom  = stringtointeger(getenv("reg_contour")); # (0 = SUB, 1 = GLOBAL)
  zoom  = getenv("reg_contour"); # (0 = SUB, 1 = GLOBAL)
  if(zoom.eq.0)then
    min_lat = stringtofloat(getenv("min_lat"))
    max_lat = stringtofloat(getenv("min_lat"))
    min_lon = stringtofloat(getenv("min_lon"))
    max_lon = stringtofloat(getenv("min_lon"))
  end if
  seasons = (/"DJF","JJA"/)
;*************************************************
; common plot resources
;*************************************************
  res                          = True
  res@txFontHeightF            = 0.024
  res@tiMainFontHeightF        = 0.030
  pres                         = True           ; panel only resources
  pres@gsnPanelCenter          = True
  pres@gsnPanelBottom          = 0.15           ; save space for legend
  pres@gsnPanelRowSpec         = True

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

  res@gsnSpreadColors	       = True	      ; key for for maintaining colorbar!

  res@gsnPaperOrientation      = "portrait"

; read in case strings
    cases  = new(1,string)
    prefix = new(1,string)
    useFlag = useCommon1 
    if (useFlag .eq. "True") then
         name1  = "commonName_"+1
    else
         name1  = "caseid_"+1
    end if
    name2     = "prefix_"+1
    cases(0)  = getenv(name1)
    prefix(0) = getenv(name2)

    caseid_1    = getenv("caseid_1")
    cam         = getenv("atm_modelstream_1")

    pres@txString  = "DJF - JJA"
    in1  = addfile(ptmpdir+"/"+"/atm/"+caseid_1+"."+cam+"._"+seasons(0)+"_climo.nc","r")	; DJF
    in11 = addfile(ptmpdir+"/"+"/atm/"+caseid_1+"."+cam+"._"+seasons(1)+"_climo.nc","r")  ; JJA

; extract years averaged for plotting
    if (isatt(in1,"yrs_averaged")) then
  	yrs_ave1 = in1@yrs_averaged
    end if

; check to make sure levels are the same for both model cases
    nlev1      = getfilevardimsizes(in1,"lev")

    lon1    = in1->lon 
    if (lon1(0) .lt. 0.) then 
       fliplon1 = "False"           ; history files start at dateline
    else 
       fliplon1 = "True"            ; history files start at greenwich
    end if 

; loop over variables
    do i=0,dimsizes(vars)-1 
      print(" " + vars(i))
      res@gsnLeftString = vars(i)
      res@gsnSpreadColors	       = True	      ; key for for maintaining colorbar!
      info = var_init(vars(i))
      plot = new(1,graphic)
      plot_check = False

; read in case 1 variable
     if (dFlag(i) .eq. "SF") then
        if(isfilevar(in1,vars(i)))then
                xa  = in1 ->$vars(i)$
                xaa = in11->$vars(i)$
      		plot_check = True
        else
                if (vars(i) .eq. "SFCO2_LND") then
        	    if(isfilevar(in1,"SFCO2_LN"))then
                          xa  = in1 ->SFCO2_LN
                          xaa = in11->SFCO2_LN
      			  plot_check = True
                    end if
                end if
                if (vars(i) .eq. "SFCO2_OCN") then
        	    if(isfilevar(in1,"SFCO2_OC"))then
                          xa  = in1 ->SFCO2_OC
                          xaa = in11->SFCO2_OC
      			  plot_check = True
                    end if
                end if
                if (vars(i) .eq. "SFCO2_FFF") then
        	    if(isfilevar(in1,"SFCO2_FF"))then
                          xa  = in1 ->SFCO2_FF
                          xaa = in11->SFCO2_FF
      			  plot_check = True
                    end if
                end if
        end if
      else
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
    if (plot_check .eq. True) then
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
      else
          plot_check_1 = True
      end if
      if(all(ismissing(x11)))then
          print("variable "+ vars(i)+ " not found")
          plot_check_11 = False
          delete(x11)
          continue
      else
          plot_check_11 = True
      end if

      ; catch NaNs
      x1  = catchNaN(x1)
      x11 = catchNaN(x11)


; get info for @ varb and scale
      x1       = scale_var(x1, scale_type(i),info)
      x11      = scale_var(x11,scale_type(i),info)

; flip longitudes to -180 to 180 if needed 
      if (fliplon1 .eq. "True") then
        x1  = lonFlip(x1)
        x11 = lonFlip(x11)
      end if
      ; regional plotting

; calculate size
      rank      = dimsizes(dimsizes(x1))

      cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag12.rgb")  ; read in colormap

; calculate time average
        var_avg_1  = dim_avg_Wrap(x1 (lat|:,lon|:,time|:))  ; time average
        var_avg_11 = dim_avg_Wrap(x11(lat|:,lon|:,time|:))  ; time average
; difference plot
        diff1 = var_avg_1 ; trick to maintain meta data
        diff1 = var_avg_1 - var_avg_11

        diff_max1 = "Min = " + min(diff1) + "  Max = " + max(diff1)
        res@tiMainString           = cases(0) 
        mindiff1 = min(diff1)
        maxdiff1 = max(diff1)
        min1 = doubletofloat(min(diff1))
        max1 = doubletofloat(max(diff1))

; set explicit contour levels 
        maxLevel = 9
        mnmxint = nice_mnmxintvl( min1, max1, maxLevel, True)
        res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
        res@cnMinLevelValF       = mnmxint(0)
        res@cnMaxLevelValF       = mnmxint(1)
        res@cnLevelSpacingF      = mnmxint(2)

; open postscript file and choose colormap
        wks  = gsn_open_wks(plot_type,wkdir + "set8_contourDJF-JJA_" + vars(i))
        gsn_define_colormap(wks,cmap)

; set case 1 titles
        res@lbTitleString = "MIN = "+sprintf("%4.2e",min1)+" MAX = "+sprintf("%4.2e",max1)
        res@gsnLeftString    = vars(i)	; could also use info@longName if we want
        res@gsnRightString   = x1@units	; assume same units for x1 and x2

; case 1 plot
        res@gsnCenterString           = cases(0) + " (yrs " + yrs_ave1 + ")"
        plot(0) = gsn_csm_contour_map_ce(wks,diff1,res)

; create panel plot
	gsn_panel(wks,plot,1,pres)           ; draw panel plot

; remove explicit labels

        delete(x1)
        delete(diff1)
        delete(var_avg_1)
        delete(var_avg_11)
        delete(plot)
    end if ; plot_check loop
  end do ; variable loop

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set8_DJF-JJA_contour_error_file"                   
  system("/bin/rm -f " + filo)  

end

