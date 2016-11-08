; NCL script
; plot_waccm_cycle_.ncl
; Charles Barden, July 2016
;**************************************
; Plot season cycle line plots for variables of interest to
; WACCM users. Plots will be done for several latitude averages
; including:
;
;   - equatorial  (10S - 10N)
;   - south pole  (60S - 90S)
;   - north pole  (60N - 90N)
;   - vortex edge (55S - 65S)
;
; Reanalysis and satellite data sets will be used for comparisons and
; model to model comparisons are also supported. Monthly data will be
; used for these plots, and any variables supported by the monthly files
; could be plotted. The main variables that will be analyzed are:
;
;   - zonal wind (U),
;   - temperature (T),
;   - water vapor (H2O)
;
; The main altitudes of interest are witihin the stratosphere and mesosphere,
; roughly from 100 hPa to 0.005 hPa.
;
; For differences, the model vertical grid will be used and reanalysis or
; observational data set will be interpolated onto this resolution.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_waccm.ncl"


; Load in diagnostic environment variables that control the plots.
compare    = getenv("COMPARE")
plot_type  = getenv("PLOTTYPE")
color_type = getenv("COLORTYPE")
version    = getenv("DIAG_VERSION")
wkdir      = getenv("WKDIR")
time_stamp = getenv("TIMESTAMP")
infile1    = getenv("TEST_INPUT")     ; case1 input filename
infile2    = getenv("CNTL_INPUT")     ; case2 input filename
case_names = getenv("CASENAMES")
code_dir   = getenv("DIAG_CODE")


; Create a 2 panel plot showing the annual cycle of the variable from:
;   - the model & observation
;   - the difference between the two
; Data is averaged between the latitude bands.
procedure plot_waccm_cycle(inptr1, vars1, inptr2, vars2, case2, yrs_ave2, minP, maxP, pAbbr, pName, ofMin, minLat, maxLat, latAbbr)

local tmp, case1, yrs_ave1, case2, yrs_ave2, gw1, gw2, var1, var2, i, j, var1a, var2a, \
      var1av, var2av, diff, wks, plot  

begin
  pi = acos(-1.0)
  d2r = pi/180.0             ; convert degrees to radians

  ; Get information for model 1
  if (case_names .eq. "True") then
   case1 = getenv("CASE1")
  else
    if (isatt(inptr1[0], "case")) then
      case1 = inptr1[0]@case
    else
      case1 = "Test"
    end if
  end if
  case1 = shorten_case_name(case1)
  

  if (isatt(inptr1[0],"yrs_averaged")) then
    yrs_ave1 = "(" + inptr1[0]@yrs_averaged + ")"
  else
    yrs_ave1 = ""
  end if
  
  ; Get information for the plots
  cnplot = new(2, "graphic")

  cres                        = True        
  cres@gsnDraw                = False      
  cres@gsnFrame               = False
;  cres@trYReverse             = True
  cres@txFontHeightF = 0.023
  cres@tiXAxisFontHeightF     = 0.020
  cres@tiYAxisFontHeightF     = 0.020
  cres@tiMainFontHeightF      = 0.025
  cres@pmLegendSide           = "Right"            ; Change location of 
  cres@pmLegendParallelPosF   = 0.10               ; of the legend
  cres@pmLegendOrthogonalPosF = 0.02               ; of the legend
  cres@pmLegendWidthF         = 0.12               ; Change width and
  cres@pmLegendHeightF        = 0.10               ; height of legend.
  cres@lgPerimOn              = True
  cres@lgLabelFontHeightF     = .020
  cres@txFontHeightF = 0.015
  cres@xyDashPatterns         = (/0.,1./)          ; solid, dashed 
  cres@xyLineThicknesses      = (/2.,2./)
  if (color_type .eq. "COLOR") then
    cres@xyLineColors         = (/"black","red","blue","green"/)
    cres@xyLineColor = "black"
  end if
  cres@tmXBMode   = "Explicit"
  cres@tmXBValues = (/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 /)
  cres@trXMinF = min(cres@tmXBValues)
  cres@trXMaxF = max(cres@tmXBValues)
  cres@tmXBLabels = (/ "J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D" /)
  cycletime       = cres@tmXBValues
  

  pan                       = True
  pan@gsnMaximize           = True
  pan@gsnPaperOrientation   = "portrait"
  pan@txFontHeightF         = 0.018
  pan@gsnFrame              = False
  
  
  ; Iterate over the variables
  if (isfilevar(inptr1[0], "gw")) then
    gw1 = inptr1[0]->gw
  else
    lat = inptr1[0]->lat
    gw1 = cos(lat * d2r)
    gw1!0 = "lat"
    gw1&lat = lat
    delete(lat)
  end if
  
  if (isfilevar(inptr2[0], "gw")) then
    gw2 = inptr2[0]->gw
  else
    lat = inptr2[0]->lat
    gw2 = cos(lat * d2r)
    gw2!0 = "lat"
    gw2&lat = lat
    delete(lat)
  end if

  nvars = dimsizes(vars1)
  do i = 0, nvars-1
  
    ; Do vertical interpolation first, since for hydrid coordinates,
    ; this should be done on lev x lat x lon data prior to averaging.
    ; Also calculate a zonal average.
    if (isfilevar(inptr1[0], vars1(i))) then
      var1 = dim_avg_Wrap(inptr1[:]->$vars1(i)$)
    else
    
      ; If it is missing water vapor, look for specific humidity and convert.
      if (vars1(i) .eq. "H2O") then
        if (isfilevar(inptr1[0], "SHUM")) then
          var1 = dim_avg_Wrap(inptr1[:]->SHUM)
          var1 = (/ var1 * 28.89 / 18. / 1e3 /)     ; convert from g/kg to ppv
        else
          if (isfilevar(inptr1[0], "Q")) then
            var1 = dim_avg_Wrap(inptr1[:]->Q)
            var1 = (/ var1 * 28.89 / 18. /)     ; convert from kg/kg to ppv
          else
            continue
          end if   
        end if   
      else
        continue
      end if
    end if

    ; If the OBS/Model2 don't have a corresponding field, then
    ; skip it.
    if (isfilevar(inptr2[0], vars2(i))) then
      var2 = dim_avg_Wrap(waccm_vintrps(inptr2, inptr2[:]->$vars2(i)$, var1&lev))
    else
    
      ; If it is missing water vapor, look for specific humidity and convert.
      if (vars2(i) .eq. "H2O") then
        if (isfilevar(inptr2[0], "SHUM")) then
          var2 = dim_avg_Wrap(waccm_vintrps(inptr2, inptr2[:]->SHUM, var1&lev))
          var2 = (/ var2 * 28.89 / 18. / 1e3 /)     ; convert from g/kg to ppv
        else
          if (isfilevar(inptr2[0], "Q")) then
            var2 = dim_avg_Wrap(waccm_vintrps(inptr2, inptr2[:]->Q, var1&lev))
            var2 = (/ var2 * 28.89 / 18. /)     ; convert from g/kg to ppv
          else
            continue
          end if   
        end if   
      else
        continue
      end if
    end if
    
    
    ; iterate over the latitudes
    nlats = dimsizes(minLat)
    lowP = min((/ min(var1&lev), minP(i) /))
    do j = 0, nlats-1
     
      ; Skip cases that are outside the range of the model data.
      if (minP(i) .lt. min(var1&lev)) then
        continue
      end if

      ; Select the region of interest and do a latitude average.
      pan@txString              = sprintf("%5.1f", minLat(j)) + " to " + sprintf("%5.1f", maxLat(j))

      ; One level or a range of levels?
      if (minP(i) .eq. maxP(i)) then
        var1a = dim_avg_wgt_Wrap(var1(:, {minP(i)}, {minLat(j):maxLat(j)}), gw1({minLat(j):maxLat(j)}), 1)
        var2a = dim_avg_wgt_Wrap(var2(:, {minP(i)}, {minLat(j):maxLat(j)}), gw2({minLat(j):maxLat(j)}), 1)
      else
        var1a = dim_avg_Wrap(dim_avg_wgt_Wrap(var1(:, {minP(i):maxP(i)}, {minLat(j):maxLat(j)}), gw1({minLat(j):maxLat(j)}), 1))
        var2a = dim_avg_Wrap(dim_avg_wgt_Wrap(var2(:, {minP(i):maxP(i)}, {minLat(j):maxLat(j)}), gw2({minLat(j):maxLat(j)}), 1))

        if (ofMin(j)) then
          var1a = (/ dim_min(dim_avg_wgt_Wrap(var1(:, {minP(i):maxP(i)}, {minLat(j):maxLat(j)}), gw1({minLat(j):maxLat(j)}), 1)) /)
          var2a = (/ dim_min(dim_avg_wgt_Wrap(var2(:, {minP(i):maxP(i)}, {minLat(j):maxLat(j)}), gw2({minLat(j):maxLat(j)}), 1)) /)
        end if
      end if
          
      ; Calculate the difference
      var1a&time = cycletime
      var2a&time = cycletime
      diff = var1a
      diff = (/  var1a - var2a /)
      
      ; Do a 2 panel plot with mode1 & obs/model2, diff.
      set_prefix = "wset2"

      if (compare .eq. "OBS") then
        if (color_type .eq. "COLOR") then
          wks = gsn_open_wks(plot_type, wkdir + "/" + set_prefix + "_" + case2 + "_" + vars1(i) + latAbbr(j) + "_" + pAbbr(i) + "_obsc")
        else
          wks = gsn_open_wks(plot_type, wkdir + "/" + set_prefix + "_" + case2 + "_" + vars1(i) + latAbbr(j) + "_" + pAbbr(i) + "_obs")
        end if
      else
        if (color_type .eq. "COLOR") then
          wks = gsn_open_wks(plot_type, wkdir + "/" + set_prefix + "_" + vars1(i) + latAbbr(j) + "_" + pAbbr(i) + "_c")
        else
          wks = gsn_open_wks(plot_type, wkdir + "/" + set_prefix + "_" + vars1(i) + latAbbr(j) + "_" + pAbbr(i))
        end if
      end if 
      
      ; Assign the contour levels for different variables
      if (vars1(i) .eq. "T") then
        var1a@long_name = "Temperature"
        var1a@units     = "K"
      end if

      if (vars1(i) .eq. "U") then
        var1a@long_name = "Zonal Wind"
        var1a@units     = "m/s"
      end if

      if (vars1(i) .eq. "RELHUM") then
       var1a@long_name = "Relative Humidity"
       var1a@units     = "%"
      end if

      if (vars1(i) .eq. "H2O") then
        var1a = (/ var1a * 1e6 /)
        var2a = (/ var2a * 1e6 /)
        diff  = (/ diff  * 1e6 /)

        var1a@long_name = "Water Vapor"
        var1a@units     = "ppmv"
      end if

      var2a@long_name = var1a@long_name
      var2a@units     = var1a@units
      diff@long_name  = var1a@long_name
      diff@units      = var1a@units

      min1 = min(var1a)
      max1 = max(var1a)
      min2 = min(var2a)
      max2 = max(var2a)


      ; Plot the model & obs plot.
      cres@tiMainString = pName(i) 
      cres@pmLegendDisplayMode = "Always"

      cres@tiYAxisString = var1a@long_name + " ("+ var1a@units + ")"
      cres@xyExplicitLegendLabels = (/ case1, case2 /)
      cres@xyMonoLineColor = False

      ydata = new((/ 2, dimsizes(cycletime) /),"float")
      ydata(0,:) = (/ var1a /)                      ; case1
      ydata(1,:) = (/ var2a /)                      ; case2

      cnplot(0) = gsn_csm_xy(wks, cycletime, ydata, cres)
      delete(ydata)
      
      ; Plot the difference plot.
      mind = min(diff)
      maxd = max(diff)

      delete(cres@xyExplicitLegendLabels)
      delete(cres@pmLegendDisplayMode)

      cres@tiMainString = case1 + " - " + case2
      cres@xyMonoLineColor = True 
      cnplot(1) = gsn_csm_xy(wks, cycletime, diff, cres)
      
      ; Create the panel.      
      if (time_stamp .eq. "True") then
        pan@gsnPanelBottom = 0.05
        gsn_panel(wks, cnplot, (/ 2 , 1 /), pan)         ; panel plot
        infoTimeStamp(wks, 0.011, "DIAG Version: " + version)
      else
        gsn_panel(wks, cnplot, (/ 2, 1 /), pan)         ; panel plot
      end if

      frame (wks)
      delete(wks)

      delete(diff)
      delete(var1a)
      delete(var2a)
    end do

    delete(var1)
    delete(var2)
  end do
end


; This is the main entry point for the diagnostic plots.
begin

  ; Define the latitude bands
  minLat  = (/ -90., -65., -10,   55.,  60. /)
  maxLat  = (/ -60., -55.,  10.,  65.,  90. /)
  latAbbr = (/ "_SP", "_SM", "_EQ", "_NM", "_NP" /)
  
  ; Define the model variables and the range of pressure levels over
  ; which to plot them.
  vars  = (/     "T",   "T", "H2O",   "T",   "U" /)
  minP  = (/      50,  5e-4,   85.,   85.,   10. /)
  maxP  = (/    120.,  1e-2,   85.,   85.,   10. /)
  pAbbr = (/   "TRP", "MSP",  "85",  "85",  "10" /)
  pName = (/   "Tropopause", "Mesopause",  "85 hPa",  "85 hPa",  "10 hPa" /)
  ofMin = (/    True,  True, False, False, False /)
  nVars = dimsizes(vars)
  
  ; Get the model data.
  files = systemfunc("ls " + infile1 + "_??_climo.nc")
  if (any(ismissing(files))) then
    print(" plot_waccm_vcycle : ERROR - Missing model 1 data.")
  else
    inptr1 = addfiles(files,"r")
  end if
  delete(files)
  
  
  ; Get data from the OBS or other model.
  if (compare .eq. "OBS") then
  
    ; Reanalysis data sets.
    ;
    ; NOTE: For WACCM, we need to make reanalysis data sets that go
    ; to higher altitudes (lower pressures).
    obs     = (/ "mlsw",        "ERAI",         "MERRAW_19x2" /)
    obsName = (/ "MLS",         "ERAI",         "MERRA" /)
    years   = (/ "(2004-2016)", "(1989-2005)",  "(1975-2015)" /)
    nobs = dimsizes(obs)
    
    do r = 0, nobs-1
    
      files = systemfunc("ls " + infile2 + "/" + obs(r) + "_??_climo.nc")
      if (any(ismissing(files))) then
        print(" plot_waccm_vcycle : ERROR - Missing " + obs(r) + " data.")
      else
        inptr2 = addfiles(files,"r")
        
        if (isatt(inptr2,"yrs_averaged")) then
          years(r) = "(" + inptr2@yrs_averaged + ")"
        end if
      end if
      delete(files)

      ; Do model to obs plots.
      plot_waccm_cycle(inptr1, vars, inptr2, vars, obsName(r), years(r), minP, maxP, pAbbr, pName, ofMin, minLat, maxLat, latAbbr)
      delete(inptr2)
      
    end do
    
  else

    files = systemfunc("ls " + infile2 + "_??_climo.nc")
    if (any(ismissing(files))) then
      print(" plot_waccm_vcycle : ERROR - Missing model 2 data.")
    else
      inptr2 = addfiles(files,"r")
    end if
    delete(files)
    
    ; Get information for obs / model 2
    if (case_names .eq. "True") then
     case2 = getenv("CASE2")
    else
      if (isatt(inptr2[0], "case")) then
        case2 = inptr2[0]@case
      else
        case2 = "Control"
      end if
    end if
    case2 = shorten_case_name(case2)

    if (isatt(inptr2[0],"yrs_averaged")) then
      yrs_ave2 = "(" + inptr2[0]@yrs_averaged + ")"
    else
      yrs_ave2 = ""
    end if

    ; Do model to model plots.
    plot_waccm_cycle(inptr1, vars, inptr2, vars, case2, yrs_ave2, minP, maxP, pAbbr, pName, ofMin, minLat, maxLat, latAbbr)
    delete(inptr2)

  end if
end

  