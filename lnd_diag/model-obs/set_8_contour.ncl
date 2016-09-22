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
   ptmpdir = getenv("PTMPDIR_1")
   wkdir   = getenv("WKDIR")
useCommon1 = getenv("UseCommonName_1")
    raster = getenv("raster")
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
  dynContour = new(nvar,"string")
  c13Flag    = new(nvar,"string")
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
  sig_lvl = getenv("sig_lvl") 
;;  zoom  = stringtointeger(getenv("reg_contour")); # (0 = SUB, 1 = GLOBAL)
  zoom  = getenv("reg_contour"); # (0 = SUB, 1 = GLOBAL)
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

  res@gsnSpreadColors	       = True	      ; key for for maintaining colorbar!

  res@gsnPaperOrientation      = "portrait"

; read in case strings
  cases  = new(2,string)
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

; loop over seasons

  do n = 0,dimsizes(seasons)-1
    print("Processing season " + seasons(n))
    pres@txString  = seasons(n)
    in1  = addfile(ptmpdir+"/"+"/atm/"+caseid_1+"."+cam+"._"+seasons(n)+"_climo.nc","r")	; used for first 3 plots

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
      plot = new(1,graphic)
      plot_check = False
      info = var_init(vars(i))

; read in case 1 variable
     if (dFlag(i) .eq. "SF") then
           if(isfilevar(in1,vars(i)))then
                xa  = in1 ->$vars(i)$
		plot_check = True
           else
                if (vars(i) .eq. "SFCO2_LND") then
                    if(isfilevar(in1,"SFCO2_LN"))then
                        xa  = in1 ->SFCO2_LN
			plot_check = True
                    end if
                end if
                if (vars(i) .eq. "SFCO2_OCN") then
                    if(isfilevar(in1,"SFCO2_OC"))then
                        xa  = in1 ->SFCO2_OC
			plot_check = True
                    end if
                end if
                if (vars(i) .eq. "SFCO2_FFF") then
                    if(isfilevar(in1,"SFCO2_FF"))then
                        xa  = in1 ->SFCO2_FF
			plot_check = True
                    end if
                end if
           end if
     else
      	if(isfilevar(in1,vars(i)))then
        	xa  = in1 ->$vars(i)$
		plot_check = True
      	else
                if (info@derivedVariable .eq. True) then
        		xa  = derive_land(vars(i),in1)
                        plot_check = True
                else
                        print("variable "+ vars(i)+ " is not a defined variable.")
                        plot_check = False
                end if
      	end if
     end if
  ; pull surface level from 4D atm data
  if (plot_check .eq. True) then
      rank       = dimsizes(dimsizes(xa))
      if(rank .eq. 4) then
      	x1  =  xa(:,nlev1-1,:,:)	; lev0 = top of atm
      else
      	x1  = xa
      end if
      delete(xa)
      if(all(ismissing(x1)))then
          print("variable "+ vars(i)+ " not Found")
          delete(x1)
          continue
      end if

      ; catch NaNs
      x1  = catchNaN(x1)

; get info for @ varb and scale
      x1       = scale_var(x1, scale_type(i),info)

; flip longitudes to -180 to 180 if needed 
      if (fliplon1 .eq. "True") then
        x1  = lonFlip(x1)
      end if

; calculate size
      rank      = dimsizes(dimsizes(x1))
      cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag12.rgb")  ; read in colormap

; calculate time average
        var_avg_1 = dim_avg_Wrap(x1(lat|:,lon|:,time|:))  ; time average

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

; panel plot
        gsn_panel(wks,plot,(/1,1/),pres)           ; draw panel plot
        delete(x1)
        delete(var_avg_1)
        delete(plot)

; remove explicit labels
        if(expFlag .eq. True) then
                delete(res@cnLevelSelectionMode)
                if(isatt(res,"cnLevels")) then
                        delete(res@cnLevels)
                end if
        end if
      end if ; plot_check loop
    end do ; variable loop
  end do   ; seasons loop 

  ; remove error file if program completes successfully.  
  filo  = wkdir +"/set8_contour_error_file"                   
  system("/bin/rm -f " + filo)  

end


