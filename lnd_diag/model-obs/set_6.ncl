load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/lnd_func.ncl"
;************************************************
; adapted from plot_regTrends.ncl (KOleson code)
; Revision Author:  Nan Rosenbloom
;************************************************
begin
 print ("=========================================")
 print ("Starting:  set_6.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
  path      = getenv("DIAG_CODE")
  resdir    = getenv("DIAG_RESOURCES")
  inputdir  = getenv("INPUT_FILES")
  plot_type = getenv("PLOTTYPE")
  plot_type = "png"

  wkdir     = getenv("WKDIR")
  ptmpdir   = getenv("PTMPDIR_1")
  cn        = getenv("CN")
  casa      = getenv("CASA")
  clamp     = getenv("CLAMP")
  hydroFlag = getenv("HYDRO")
      paleo = getenv("paleo")
  land_mask = getenv("land_mask1")
  flandmask = stringtofloat(land_mask)
 useCommon1 = getenv("UseCommonName_1")

  nyrs      = stringtointeger(getenv("trends_num_yrs_1"))
  fyr       = stringtointeger(getenv("trends_first_yr_1"))

;;  nyrs      = getenv("trends_num_yrs_1")
;;  fyr       = getenv("trends_first_yr_1")


;***********************************************
; import regional information
;***********************************************

 regions_file = addfile(resdir + "/region_definitions.nc","r")
 box_n = regions_file->BOX_N
 box_w = regions_file->BOX_W
 box_e = regions_file->BOX_E
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

nplots = 11		

; loop over plots
do p=0,nplots-1

print("Now printing plot #" + p)
  if (p .eq. 0) then 
	fileName   = "set6_landFlx.txt"
	plot_name  = "landf"
        titstr = new(4,"string")
        titstr(0) = "2m Air Temperature (~S~o~N~K)"
        titstr(1) = "Precipitation (mm day~S~-1~N~)"
        titstr(2) = "Runoff (mm day~S~-1~N~)"
        titstr(3) = "Snow Depth (m)"
  end if
  if (p .eq. 1) then
	fileName   = "set6_radFlx.txt"
	plot_name  = "radf"
        titstr = new(8,"string")
        titstr(0) = "Incoming Solar"
        titstr(1) = "Albedo"
        titstr(2) = "Absorbed Solar"
        titstr(3) = "Incoming Longwave"
        titstr(4) = "Emitted Longwave"
        titstr(5) = "Net Longwave"
        titstr(6) = "Net Radiation"
        titstr(7) = "Ground Snow Covered Fraction"
  end if
  if (p .eq. 2) then
	fileName   = "set6_turbFlx.txt"
	plot_name  = "turbf"
        titstr = new(9,"string")
        titstr(0) = "Net Radiation"
        titstr(1) = "Sensible Heat"
        titstr(2) = "Latent Heat"
        titstr(3) = "Transpiration"
        titstr(4) = "Canopy Evaporation"
        titstr(5) = "Ground Evaporation"
        titstr(6) = "Ground Heat + Snow Melt"
        titstr(7) = "Soil moisture factor (BTRAN or BTRANMN)"
        titstr(8) = "Total LAI"
  end if
  if (p .eq. 3) then
    if (clamp .eq. 1) then
                fileName   = "set6_clampFlx.txt"
                plot_name  = "cnFlx"
                titstr = new(6,"string")
                titstr(0) = "Net Ecosystem Exchange"
                titstr(1) = "GPP"
                titstr(2) = "NPP"
                titstr(3) = "Autotrophic Respiration"
                titstr(4) = "Heterotrophic Respiration"
                titstr(5) = "Net Ecosystem Production"
    else
        if (cn .eq. 1) then
                fileName   = "set6_cnFlx.txt"
                plot_name  = "cnFlx"
                titstr = new(10,"string")
                titstr(0) = "Net Ecosystem Exchange"
                titstr(1) = "GPP"
                titstr(2) = "NPP"
                titstr(3) = "Autotrophic Respiration"
                titstr(4) = "Heterotrophic Respiration"
                titstr(5) = "Ecosystem Respiration"
                titstr(6) = "Gridcell Surface CH4 Flux"
                titstr(7) = "Carbon Use Efficiency (NPP/GPP)"
                titstr(8) = "Soil NO3 Pool Loss to Leaching"
                titstr(9) = "Soil NO3 Pool Loss to Runoff"
        else
            if (casa .eq. 1) then
                fileName   = "set6_casaFlx.txt"
                plot_name  = "cnFlx"
                titstr = new(5,"string")
                titstr(0) = "Net Ecosystem Exchange"
                titstr(1) = "GPP"
                titstr(2) = "NPP"
                titstr(3) = "Autotrophic Respiration"
                titstr(4) = "Heterotrophic Respiration"
            else
                continue
            end if
        end if
    end if
  end if
  if (p .eq. 4) then
     if (cn .eq. 1) then
	fileName   = "set6_fireFlx.txt"
	plot_name  = "frFlx"
        titstr = new(6,"string")
        titstr(0) = "Column-Level Fire C Loss"
        titstr(1) = "Column-Level Fire N Loss"
        titstr(2) = "PFT-Level Fire C Loss"
        titstr(3) = "PFT-Level Fire N Loss"
        titstr(4) = "Fractional Area Burned"
        titstr(5) = "Fractional Area Burned - Crop"
     else
	continue
     end if
  end if
  if (p .eq. 5) then 
        vars         = (/"TSOI"/)
        scale_type   = (/"globalMeanNat"/)
        nvars        = dimsizes(vars)
        nplotsPerCol = 5                        ; hardwired for 10 soil levels
        fileName     = "set6_tsoi.txt"
        plot_name    = "tsoi"
        titstr       = new(1,"string")
        titstr(0)    = "Mean Soil Temperature"
  end if
  if (p .eq. 6) then 
        vars         = (/"SOILLIQ"/)
        scale_type   = (/"globalMeanNat"/)
        nvars        = dimsizes(vars)
        nplotsPerCol = 5                        ; hardwired for 10 soil levels
        fileName     = "set6_soilliq.txt"
        plot_name    = "soilliq"
        titstr       = new(1,"string")
        titstr(0)    = "Soil Liquid Water"
  end if
  if (p .eq. 7) then 
        vars         = (/"SOILICE"/)
        scale_type   = (/"globalMeanNat"/)
        nvars        = dimsizes(vars)
        nplotsPerCol = 5                        ; hardwired for 10 soil levels
        fileName     = "set6_soilice.txt"
        plot_name    = "soilice"
        titstr       = new(1,"string")
        titstr(0)    = "Soil Ice"
  end if
  if (p .eq. 8) then 
        vars         = (/"TOTSOILICE","TOTSOILLIQ"/)
        scale_type   = (/"globalMeanNat","globalMeanNat"/)
        nvars        = dimsizes(vars)
        nplotsPerCol = (nvars+1)/2
        fileName     = "set6_soilliqIce.txt"
        plot_name    = "soilliqIce"
        titstr       = new(2,"string")
        titstr(0)    = "Total Soil Ice"
        titstr(1)    = "Total Soil Liquid Water"
  end if
  if (p .eq. 9) then 
        vars         = (/"SNOWLIQ","SNOWICE"/)
        scale_type   = (/"globalMeanNat","globalMeanNat"/)
        nvars        = dimsizes(vars)
        nplotsPerCol = (nvars+1)/2
        fileName     = "set6_snowliqIce.txt"
        plot_name    = "snowliqIce"
        titstr       = new(2,"string")
        titstr(0)    = "Total Snow Liquid Water"
        titstr(1)    = "Total Snow Ice"
  end if
  if (p .eq. 10) then
     if (hydroFlag .eq. 1) then
	fileName   = "set6_hydro.txt"
	plot_name  = "hydro"
        titstr = new(6,"string")
        titstr(0) = "Water in Unconfined Aquifer"	; WA
        titstr(1) = "Water Table Depth"			; ZWT
        titstr(2) = "Aquifer Recharge Rate"		; QCHARGE
        titstr(3) = "Frac Water Table at Surface"	; FCOV
        titstr(4) = "Total Water Storage"	        ; TWS
        titstr(5) = "River Channel Total Water Storage" ; VOLR
     else
	continue
     end if
  end if
;----------------------------------------------------------
; read in file and parse into variables
;----------------------------------------------------------
  if (p .lt. 5 .or. p .eq. 10)
  	tmp = stringtocharacter(asciiread(inputdir+"/"+fileName,-1,"string"))
  	nvars = dimsizes(tmp(:,0))
  	nplotsPerCol = (nvars+1)/2
  	scale_type = new(nvars,"string")
  	vars       = new(nvars,"string")
  	do i=0,nvars-1
        	scale_type(i) = charactertostring(tmp(i,0:12))
        	vars(i)       = charactertostring(tmp(i,16:))
  	end do
  	delete(tmp)
  end if

  vcheck1    = new(nvars,"string")
  plot_check = True	; 20dec04 - nanr; added so that plot_check would be defined for underived vars.

;----------------------------------------------------------
; Define common plots resources 
;----------------------------------------------------------

  res                        = True
  res@xyDashPatterns         = (/0.,16./)          ; solid, dashed
  res@xyLineThicknesses      = (/2.,2./)
  res@xyLineColors           = (/"red","blue"/)
  res@tmXBMinorOn            = False
  res@tiMainOn               = False
  res@gsnDraw                = False
  res@gsnFrame               = False
  res@tiXAxisFontHeightF     = 0.030
  res@tiYAxisFontHeightF     = 0.030
  res@txFontHeightF          = 0.030
  res@tmYLLabelFontHeightF   = 0.030
  res@tmYLFormat             = "0@!;*?5g"

  res@pmLegendDisplayMode    = "Never"
  res@vpHeightF              = 0.4
  res@vpWidthF               = 0.8

  cases = new(2,"string")
  if (useCommon1 .eq. "True") then
        name1  = "commonName_1"
  else
        name1  = "caseid_1"
  end if
  name11    = "prefix_1"
  cases(0)  = getenv(name1)
  cases(1)  = "No Obs"
  prefix1   = getenv(name11)
  in1       = addfile(ptmpdir + "/" + prefix1 +"ANN_ALL.nc","r")
  print ("DEBUG file in1 = "+ptmpdir+"/"+prefix1+"ANN_ALL.nc")	
  nlev1 = 0
  if(isfilevar(in1,"levsoi")) then
  	nlev1  = getfilevardimsizes(in1,"levsoi")
  end if
  if(isfilevar(in1,"levgrnd")) then
  	nlev1  = getfilevardimsizes(in1,"levgrnd")
  end if
  if (nlev1 .eq. 0)
        print("FATAL ERROR:  nlev1 = 0")
        exit
  end if
  fland1     = in1->landfrac
  area1      = in1->area
  lat1       = in1->lat
  lon1       = in1->lon
  nlat1      = dimsizes(lat1)
  nlon1      = dimsizes(lon1)
  time1      = in1->time

; ----------------------------------------------------------
; region_definitions are defined from -180 to -180; if history file comes in
; with lon defined as 0-360, need to use lonFlip to change incoming history variables
; including area, fland, etc.
; ----------------------------------------------------------
    if (lon1(0) .lt. 0.) then
      fliplon1 = "False"           ; history files (including area) run from -180 to 180
    else
      fliplon1 = "True"            ; history files (including area) run from 0 - 360; need to be flipped
    end if

    if (fliplon1 .eq. "True") then
         area1  = lonFlip(area1)
         fland1 = lonFlip(fland1)
    end if



;**************************
; Variable loop ----------- read both cases of each variable into memeory.
;**************************
  array1   = new((/nvars, nyrs, nlat1, nlon1/),"float")
  array1_3 = new((/nyrs, nlev1, nlat1, nlon1/),"float")

  units = new(nvars,"string")
  long_name = new(nvars,"string")

  if(nyrs .ne. dimsizes(time1)) then
        print("   ")
        print("   ")
        print("FATAL ERROR:")     
        print("ANN_ALL.nc time dimension wrong:  ANN_ALL.nc=(" + dimsizes(time1) + ") vs trends_num_yrs=(" + nyrs +")")              
        print("Exiting Set_6.ncl")  
        print("   ")
        print("   ")
        exit
  end if

; read all variables into memory first and stuff them into two arrays (2 cases)
  pcheck1 = 0
  do i=0,nvars-1 

print("processing " + vars(i) + " for plot " + p)

; check for variables in case 1
      info = var_init(vars(i))
      vcheck1(i) = True
      if(isfilevar(in1,vars(i)) .and. info@derivedVariable .eq. False)then
          x1 = in1->$vars(i)$
               rank = dimsizes(dimsizes(x1))
          plot_check = True
      else
          if (info@derivedVariable .eq. True) then
                  x1 = derive_land(  vars(i),in1)
                         rank = dimsizes(dimsizes(x1))
          else
                  print("variable "+ vars(i)+ " is not a defined variable in case1.")
                  pcheck1 = pcheck1 + 1
                  vcheck1(i) = False
          end if
       end if

       if (pcheck1 .eq. nvars) then
		plot_check = False
       end if


       ; catch NaNs
       if (vcheck1(i) .eq. True) then
           x1 = catchNaN(x1)

           ; flip variable to match regions definitions (-180-180)
           if (fliplon1 .eq. "True") then
               x1 = lonFlip(x1)
           end if

           x1    = scale_var(x1,scale_type(i),info)

           if (rank .eq. 3) then
                array1(i,:,:,:) = x1
           else     
                array1_3(:,:,:,:) = x1
           end if   
           units(i)        = x1@units
           long_name(i)    = x1@long_name

           delete(x1)
       end if
 
   end do 	; end variable loop


print("End processing plot " + p + " variables")

wcStart = systemfunc("date")

;**********************************
; now plot vars by region
;**********************************
if(plot_check.eq.True)then

 if (paleo .eq. "True") then
	startRegion = nreg-3	; N + S. Hemisphere land, global
 else
	startRegion = 0
 end if

 do region=startRegion,nreg-1

   print("Plotting " + ps_id(region))

  ; open ps file for plotting
    wks = gsn_open_wks(plot_type,wkdir + "set6_" + plot_name + "_" + ps_id(region))

    pres                     = True                   ; panel only resources
  ; create common legend 
    pres@txString            = ptitstr(region)+boxstr(region)  ; common title

  ; each regional plot contains all variables, so loop over vars
  compare = "model"		              ; flag for regional_values fcn
  if (rank .eq. 3) then
     plot = new(nvars,graphic)
     do i = 0,nvars-1
              data = new((/1,nyrs/),"double")
           if (vcheck1(i) .eq. True) then
           	x1 = array1(i,:,:,:)
		wcStartv = systemfunc("date")
           	var_plot1 = regional_values_set6(x1,region,area1,fland1,scale_type(i),\
	          	regions_file,time1,nyrs,compare)
		; wallClockElapseTime(wcStartv,"regionalValues processing: ",0)

           	data(0,:) = var_plot1
           end if

                res@tiYAxisString          = units(i)
                res@gsnCenterString        = titstr(i)
	
           wcStartg = systemfunc("date")
           plot(i) = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data,res)
           ; wallClockElapseTime(wcStartv,"plotting 3D variables : ",0)
      end do	; end variable string
      delete(data)
   else
          delete(pres@txString)
          pres@txString            = titstr(0) + "~C~" + ptitstr(region)+boxstr(region)  ; common title
          nlevLimit = 10               ; prescribe 10 soil layers 
          data3 = new((/2,nyrs,nlevLimit/),"double")
          wcStartl = systemfunc("date")
          do j = 0,nlevLimit-1
                x1 = array1_3(:,j,:,:)
                var_plot1 = regional_values_set6(x1,region,area1,fland1,scale_type(0),\
                                regions_file,time1,nyrs,compare)

                data3(0,:,j) = var_plot1
          end do

          plot = new(nlevLimit,graphic)
          res@tiMainOn               = False
          res@gsnDraw                = False
          res@gsnFrame               = False
          res@tiXAxisFontHeightF     = 0.030
          res@tiYAxisFontHeightF     = 0.030
          res@txFontHeightF          = 0.030
          res@tmXBLabelFontHeightF   = 0.030
          res@tmYLLabelFontHeightF   = 0.030
          res@pmLegendDisplayMode    = "Never"
          res@vpHeightF              = 0.4
          res@vpWidthF               = 0.8
          res@tiXAxisOn              = False
          if(isfilevar(in1,"levsoi")) then
          	lev = in1->levsoi
          end if
          if(isfilevar(in1,"levgrnd")) then
          	lev = in1->levgrnd
          end if
          res@tiYAxisString          = array1_3@units
          do k=0,nlevLimit-1
                        
                        res@gsnCenterString           = "Layer " + (k+1)
                        plot(k) = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data3(:,:,k),\
                        res) 
           end do
           pres                     = True                   ; panel only resources
           pres@txString            = long_name(0)           ; common title
           pres@gsnFrame            = False                  ; don't advance yet so add legend
           pres@gsnMaximize         = True                   ; make as large as possible
           pres@gsnPanelBottom      = 0.12                   ; save space for legend
           delete(data3)
; wallClockElapseTime(wcStartl,"plotting 4D vars : ",0)
   end if

   delete(var_plot1)

;*************************************************
;  gsnpanel takes this plot array and massages it and puts it onto page for us.
;*************************************************

wcStartp = systemfunc("date")
      pres@gsnFrame            = False                  ; don't advance yet so add legend
      pres@gsnPanelBottom      = 0.12                   ; save space for legend
      pres@gsnPanelCenter      = False

      lgres                    = True                   ; allow legend resources
      lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
      lgres@lgPerimOn          = False
      lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
      lgres@lgLabelFontHeightF = 0.025                  ; increase font height
      lgres@lgLineLabelStrings = (/"",""/)              ; no labels in lines
      lgres@lgAutoManage       = False                  ; must have to adjust fonts
      lgres@vpWidthF           = 0.4
      lgres@vpHeightF          = 0.10
      pres@gsnPaperOrientation = "Portrait"
      pres@gsnMaximize         = True                   ; make as large as possible

      if (p .eq. 2) then                                ; turbf (9)
            pres@gsnPanelRowSpec = True
            gsn_panel(wks,plot,(/2,2,2,2,1/),pres)
            legend = create "Legend" legendClass wks
              "vpXF"                     : 0.525
              "vpYF"                     : 0.25
              "vpWidthF"                 : 0.20
              "vpHeightF"                : 0.08
              "lgPerimOn"                : False
              "lgItemCount"              : 2
              "lgLabelsOn"               : True
              "lgLineLabelsOn"           : False
              "lgLabelStrings"           : cases
              "lgDashIndexes"            : (/0,1/)
              "lgLineColors"             : (/"red","blue"/)
              "lgMonoLineLabelFontColor" : True
              "lgAutoManage"             : False
              "lgLabelFontHeightF"       : 0.01
              "lgLabelPosition"          : "Center"
              "lgLabelAlignment"         : "AboveItems"
            end create
            draw(legend)
	    frame(wks)	
            delete(legend)
      else 
       if (p .eq. 3) then                                ; cnFlx (10)
             pres@gsnPanelRowSpec     = True
             pres@gsnPanelCenter      = False
             gsn_panel(wks,plot,(/2,2,2,2,2/),pres)
             legend = create "Legend" legendClass wks
               "vpXF"                     : 0.45
               "vpYF"                     : 0.10
               "vpWidthF"                 : 0.20
               "vpHeightF"                : 0.08
               "lgPerimOn"                : True
               "lgItemCount"              : 2
               "lgLabelsOn"               : True
               "lgPerimOn"                : False
               "lgLineLabelsOn"           : False
               "lgLabelStrings"           : cases
               "lgDashIndexes"            : (/0,1/)
               "lgLineColors"             : (/"red","blue"/)
               "lgMonoLineLabelFontColor" : True
               "lgAutoManage"             : False
               "lgLabelFontHeightF"       : 0.01
               "lgLabelPosition"          : "Center"
               "lgLabelAlignment"         : "AboveItems"
             end create
             draw(legend)
	     frame(wks)
             delete(legend)
       else
         if (p .eq. 8 .or. p .eq. 9) then                          ; snowliq + snowice
            pres@gsnPanelRowSpec = True
            gsn_panel(wks,plot,(/1,1/),pres)               ; draw panel plot
            gsn_legend_ndc(wks,2,cases,0.3,0.12,lgres)    ; draw common legend    MAY HAVE TO ADJUST Y
	    frame(wks)     ; add frame to support plot_type = png
         else
            pres@gsnPanelRowSpec     = False
            gsn_panel(wks,plot,(/nplotsPerCol,2/),pres)       ; draw panel plot
            if (p.ne.0) then
               gsn_legend_ndc(wks,2,cases,0.3,0.10,lgres)     ; draw common legend   MAY HAVE TO ADJUST Y
   	       frame(wks)     ; add frame to support plot_type = png
            else
               gsn_legend_ndc(wks,2,cases,0.3,0.175,lgres)     ; draw common legend   MAY HAVE TO ADJUST Y
	       frame(wks)     ; add frame to support plot_type = png
            end if
         end if
       end if
      end if
;;      frame(wks)
      ; wallClockElapseTime(wcStartp,"plotting 4D vars : ",0)
   end do	;  end of region loop
end if  ; end plot_check loop

   if(isvar("x1") ) then
      delete(x1)
   end if
   if(isvar("vars") ) then
      delete(vars)
   end if
   if(isvar("vcheck1") ) then
      delete(vcheck1)
   end if
   if(isvar("array1") ) then
      delete(array1)
   end if
   if(isvar("array1_3") ) then
      delete(array1_3)
   end if
   if(isvar("scale_type") ) then
      delete(scale_type)
   end if
   if(isvar("plot") ) then
      delete(plot)
   end if
   if(isvar("units") ) then
      delete(units)
   end if
   if(isvar("long_name") ) then
      delete(long_name)
   end if
   if(isvar("titstr") ) then
      delete(titstr)
   end if
end do   ; end plot loop

;---------------------------------------------- 
; Create global maps delineating regions (on model grid)
;----------------------------------------------

;----------------------------------------------
; common plot resources
;----------------------------------------------
 delete(res)
 res = True
 res@mpProjection = "Robinson"
 res@mpPerimOn    = False
 res@mpGridLineColor = "transparent"     
 res@cnFillOn = True
 res@cnLineLabelsOn = False
 res@lbLabelBarOn = False
 res@cnLinesOn =  False
 res@mpGridLonSpacingF   = 60.0            ; Set lon grid spacing
 res@mpGridLatSpacingF    = 30.0           ; Set lat grid spacing
 res@mpFillOn             =  False
 res@mpOutlineOn          =  True
 res@mpGridAndLimbOn      =  True
 res@mpGridLineDashPattern =  2            ; Set grid line dash pattern (dash)
 res@mpGridLineThicknessF   = 0.5          ; Set grid line thickness
 sstr=(/" "/)
 res@gsnMaximize = True
 res@cnLevelSelectionMode =  "ExplicitLevels"
 wks = gsn_open_wks(plot_type,wkdir+"set6_reg_all")
 cmap = (/"(/1.00, 1.00, 1.00/)", "(/0.00, 0.00, 0.00/)", \
          "(/1.00, 1.00, 1.00/)", "Blue" /)
 gsn_define_colormap(wks, cmap )
 res@gsnLeftString = " "
 res@gsnRightString = " "
 res@cnLevels = (/0./)
 res@cnRasterModeOn = True

 flag1 = area1
 flag1 = -0.1

 if (paleo .eq. "True") then
	startRegion = nreg-3	; N. + S. Hemisphere land + global
 else
	startRegion = 0
 end if

 if (paleo .eq. "True") then
    landfrac = in1->landfrac
    oro = new((/nlat1,nlon1/),integer)
    oro = 1
    oro@_FillValue = 0
    oro = where(landfrac .gt. 0.0, 1,0)
;   fname = wkdir+prefix1
;   fname = wkdir+"basename"
;   fname = wkdir+cases(0)
    fname = wkdir+getenv(name1)
    paleo_outline(oro,lat1,lon1,1, fname)
    res@mpDataBaseVersion = "Ncarg4_1"
    res@mpDataSetName     =  fname
    do ar = startRegion, nreg-1  ; don't include northern and southern hemisphere and global
          flag1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = 0.1*fland1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) - 1.e-36
    end do
 else
   do ar = 0, nreg-4  ; don't include northern and southern hemisphere and global
     	flag1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = 0.1*fland1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) - 1.e-36
   end do
 end if

 res@gsnCenterString = "Model Data Regions - All"
 plot = gsn_csm_contour_map(wks, flag1, res)

 do ar = startRegion, nreg-1
;----------------------------------------------
; Open file for plots
;----------------------------------------------
   wks = gsn_open_wks(plot_type,wkdir+"set6_reg_"+ps_id(ar))
   cmap = (/"(/1.00, 1.00, 1.00/)", "(/0.00, 0.00, 0.00/)", \
            "(/1.00, 1.00, 1.00/)", "Blue" /)
   gsn_define_colormap(wks, cmap )
   flag1 = -0.1
   flag1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = 0.1*fland1 ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) - 1.e-36
   res@gsnCenterString = "Model Data Regions - " + ptitstr(ar) + boxstr(ar)
   plot = gsn_csm_contour_map(wks, flag1, res)
 end do

 print ("=========================================")
 print ("Finish Time: "+systemfunc("date") )
 print ("=========================================")

 ; remove error file if program completes successfully.  
 filo  = wkdir +"/set6_error_file"                   
 system("/bin/rm -f " + filo)  

end
