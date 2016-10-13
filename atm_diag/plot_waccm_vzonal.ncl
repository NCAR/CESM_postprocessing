; NCL script
; plot_waccm_vzonal_.ncl
; Charles Barden, July 2016
;**************************************
; Plot pressure versus latitude plots for variables of interest to
; WACCM users in altitude ranges appropriate for WACCM. Plots
; will be done for several different time periods including:
;
;   - June
;   - December
;   - 4 seasons
;   - annual
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
; The main altitudes of interest are the stratosphere and mesosphere,
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
rgb_file   = getenv("RGB_FILE")
version    = getenv("DIAG_VERSION")
wkdir      = getenv("WKDIR")
time_stamp = getenv("TIMESTAMP")
infile1    = getenv("TEST_INPUT")     ; case1 input filename
infile2    = getenv("CNTL_INPUT")     ; case2 input filename
case_names = getenv("CASENAMES")
code_dir   = getenv("DIAG_CODE")

; For now override the default RGB file with amwg and use bluered for the
; difference plots.
rgb_file = code_dir + "/rgb/amwg.rgb"


; Create a 3 panel plot showing the zonal average of the variable from:
;   - the model
;   - the observation/reanalysis/model
;   - the difference between the two
; Data is for different time periods.
procedure plot_waccm_vzonal(inptr1, vars1, inptr2, vars2, case2, yrs_ave2, minP, maxP, pAbbr, period)

local tmp, case1, yrs_ave1, case2, yrs_ave2, gw1, gw2, var1, var2, i, j, var1a, var2a, \
      var1av, var2av, diff, wks, plot  

begin

  ; Get information for model 1
  if (case_names .eq. "True") then
   case1 = getenv("CASE1")
  else
    if (isatt(inptr1, "case")) then
      case1 = inptr1@case
    else
      case1 = "Test"
    end if
  end if
  case1 = shorten_case_name(case1)

  if (isatt(inptr1,"yrs_averaged")) then
    yrs_ave1 = "(" + inptr1@yrs_averaged + ")"
  else
    yrs_ave1 = ""
  end if
  
  ; Get information for the plots
  cnplot = new(3, "graphic")

  cres                        = True        
  cres@gsnDraw                = False      
  cres@gsnFrame               = False
;  cres@trYReverse             = True
  cres@tiYAxisString          = "Pressure (mb)"  
  cres@txFontHeightF = 0.023
  if (color_type .eq. "COLOR") then
    cres@cnFillOn             = True
    cres@cnLinesOn            = False
    cres@cnLineLabelsOn       = False
    cres@lbTitleOn = True
    cres@lbLabelFontHeightF = 0.018
    cres@lbTitleFontHeightF = 0.02    
    cmap  = RGBtoCmap(rgb_file)
    cmapd = RGBtoCmap(code_dir + "/rgb/bluered.rgb")
    cres@gsnSpreadColorStart = 2
    cres@gsnSpreadColorEnd   = 17
  else
    cres@cnLevelSelectionMode = "ManualLevels" 
    cres@cnLinesOn              = True 
    cres@cnLineLabelsOn         = True 
    cres@cnLineLabelInterval    = 1
    cres@cnLineLabelFontHeightF = .02
    cres@cnInfoLabelFontHeightF = .02
    cnlvls = 15
    diffcnlvls = 12
  end if
  
  dres = cres 

  pan                       = True
  pan@gsnMaximize           = True
  pan@gsnPaperOrientation   = "portrait"
  pan@txFontHeightF         = 0.018
  pan@gsnFrame              = False
  
  
  nvars = dimsizes(vars1)
  do i = 0, nvars-1

    ; Do vertical interpolation first, since for hydrid coordinates,
    ; this should be done on lev x lat x lon data prior to averaging.
    ; Also calculate a zonal average.
    if (isfilevar(inptr1, vars1(i))) then
      var1 = dim_avg_Wrap(inptr1->$vars1(i)$)
    else
    
      ; If it is missing water vapor, look for specific humidity and convert.
      if (vars1(i) .eq. "H2O") then
        if (isfilevar(inptr1, "SHUM")) then
          var1 = dim_avg_Wrap(inptr1->SHUM)
          var1 = (/ var1 * 28.89 / 18. / 1e3 /)     ; convert from g/kg to ppv
          var1@units = "mol/mol"
        else
          if (isfilevar(inptr1, "Q")) then
            var1 = dim_avg_Wrap(inptr1->Q)
            var1 = (/ var1 * 28.89 / 18. /)     ; convert from g/kg to ppv
            var1@units = "mol/mol"
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
    if (isfilevar(inptr2, vars2(i))) then
      var2 = dim_avg_Wrap(waccm_vintrp(inptr2, inptr2->$vars2(i)$, var1&lev))
    else
    
      ; If it is missing water vapor, look for specific humidity and convert.
      if (vars2(i) .eq. "H2O") then
        if (isfilevar(inptr2, "SHUM")) then
          var2 = dim_avg_Wrap(waccm_vintrp(inptr2, inptr2->SHUM, var1&lev))
          var2 = (/ var2 * 28.89 / 18. / 1e3 /)     ; convert from g/kg to ppv
          var2@units = "mol/mol"
        else
          if (isfilevar(inptr2, "Q")) then
            var2 = dim_avg_Wrap(waccm_vintrp(inptr2, inptr2->Q, var1&lev))
            var2 = (/ var2 * 28.89 / 18. /)     ; convert from g/kg to ppv
            var2@units = "mol/mol"
          else
            continue
          end if   
        end if   
      else
        continue
      end if
    end if
    
    ; Interpolate to the model latitudes
    ;
    ; NOTE: In data sets where all the values are fill at a particular latitude,
    ; the linint1_Wrap call generates an error, but it doesn't really seem to be
    ; fatal:
    ;
    ;   fatal:["NclAtt.c":262]:Attribute assignment type mismatch.
    var1a = var1(0, {minP(i):maxP(i)}, :)
    var2a = linint1_Wrap(var2&lat, var2(0, {minP(i):maxP(i)}, :), False, var1&lat, 0)
    
    ; Select the region of interest and do a latitude average.
    pan@txString              = period

    diff = var1a
    diff = (/  var1a - var2a /)
      
    ; Do a 3 panel plot with mode1, obs/model2, diff.
    set_prefix = "wset4"

    if (compare .eq. "OBS") then
      if (color_type .eq. "COLOR") then
        wks = gsn_open_wks(plot_type, wkdir + "/" + set_prefix + "_" + case2 + "_" + vars1(i) + "_" + period + pAbbr(i) + "_obsc")
        gsn_define_colormap(wks, cmap)
      else
        wks = gsn_open_wks(plot_type, wkdir + "/" + set_prefix + "_" + case2 + "_" + vars1(i) + "_" + period + pAbbr(i) + "_obs")
      end if
    else
      if (color_type .eq. "COLOR") then
        wks = gsn_open_wks(plot_type, wkdir + "/" + set_prefix + "_" + vars1(i) + "_" + period + pAbbr(i) + "_c")
        gsn_define_colormap(wks, cmap)
      else
        wks = gsn_open_wks(plot_type, wkdir + "/" + set_prefix + "_" + vars1(i) + "_" + period + pAbbr(i))
      end if
    end if 
    
    ; Assign variables generically as 15 linear levels in the
    ; range the data will be plotted. Also adjust scales for variables with
    ; small numbers to ppm, ppb, ppt as appropriate.
    varmax = max((/ max(var1a), max(var2a) /))
    varmin = min((/ min(var1a), min(var2a) /))
    
    scale = 1.
    units = var1a@units
    waccm_scaleunits(vars1(i), var1a@units, varmin, varmax, scale, units)
    
    if (scale .ne. 1.) then
      var1a@units = units
      
      var1a = (/ var1a * scale /)
      var2a = (/ var2a * scale /)
      diff  = (/ diff  * scale /)
  
      varmax = max((/ max(var1a), max(var2a) /))
      varmin = min((/ min(var1a), min(var2a) /))
    end if
    
    maxmin  = nice_mnmxintvl(varmin, varmax, 15, False)
    symMinMaxPlt(diff, 15, False, dres)
    

    ; If desired, override the default contour levels with hard coded levels for
    ; specific fields. Also some fields need to be scaled to reasonable units.
    if (vars1(i) .eq. "CO") then
      con = (/ 0.01,0.02,0.04,0.08,0.1,0.2,0.4,0.8,1.,2.,4.,8.,10.,20.,40. /)
      dcon = (/ -10.,-4.,-1.,-0.4,-0.1,-.04,-.01,0.,0.01,0.04,0.1,0.4,1.,4.,10. /)
    end if

    if (vars1(i) .eq. "H2O") then
      var1a@long_name = "Water Vapor"
      con  = fspan(1, 8, 15)
      dcon = (/ -1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8 /)
    end if
    
    if (vars1(i) .eq. "QRL_TOT") then
      var1a@long_name = "Merged LW Heating"
    end if

    if (vars1(i) .eq. "QRS_TOT") then
      var1a@long_name = "Merged SW Heating"
    end if

    if (vars1(i) .eq. "RELHUM") then
      var1a@long_name = "Relative Humidity"
      var1a@units     = "%"
      con  = fspan(0., 140., 15)
      dcon = (/ -18.,-15.,-12.,-9.,-6.,-3.,-1.,0.,1.,3.,6.,9.,12.,15.,18. /)
    end if

    if (vars1(i) .eq. "T") then
      var1a@long_name = "Temperature"
      var1a@units     = "K"
      
      if (pAbbr(i) .eq. "_z") then
        con  = fspan(180., 250., 15)
        dcon = (/ -9.,-7.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,7.,9. /)
      else
        con  = fspan(130., 270., 15)
        dcon = (/ -18.,-14.,-10.,-8.,-6.,-4.,-2.,0.,2.,4.,6.,8.,10.,14.,18. /)
      end if
    end if

    if (vars1(i) .eq. "U") then
      var1a@long_name = "Zonal Wind"
      var1a@units     = "m/s"
      con  = fspan(-70., 70., 15)
      dcon = (/ -18.,-15.,-12.,-9.,-6.,-3.,-1.,0.,1.,3.,6.,9.,12.,15.,18. /)
    end if

    if (vars1(i) .eq. "V") then
      var1a@long_name = "Meridional Wind"
      var1a@units     = "m/s"

      if (pAbbr(i) .eq. "_z") then
        con  = fspan(-3.5, 3.5, 15)
        dcon = (/ -1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0.,.1,.3,.6,.9,1.2,1.5,1.8 /)
      else
        con  = fspan(-14., 14., 15)
        dcon = (/ -7.2,-6.,-4.8,-3.6,-2.4,-1.2,-.4,0.,.4,1.2,2.4,3.6,4.8,6.,7.2 /)
      end if
    end if

    if (vars1(i) .eq. "Z3") then
      var1a@long_name = "Geopotential Height"
    end if

    var2a@long_name = var1a@long_name
    var2a@units     = var1a@units
    diff@long_name  = var1a@long_name
    diff@units      = var1a@units

    min1 = min(var1a)
    max1 = max(var1a)
    min2 = min(var2a)
    max2 = max(var2a)

    if (color_type .eq. "COLOR") then
      cres@lbLabelStride  = 2
      cres@lbOrientation = "Horizontal"
      if (isvar("con")) then
        cres@cnLevelSelectionMode = "ExplicitLevels" 
        cres@cnLevels = con(:)
        delete(con)
      else
        cres@cnLevelSelectionMode = "ManualLevels" 
        cres@cnMinLevelValF  = maxmin(0)
        cres@cnMaxLevelValF  = maxmin(1)
        cres@cnLevelSpacingF = maxmin(2)
      end if
      cres@cnFillPalette = cmap
      cres@cnLinesOn = False
      cres@cnLineLabelsOn = False
    else
      minab = min((/min1,min2/))
      maxab = min((/max1,max2/))
      mnmxint = nice_mnmxintvl (minab,maxab,cnlvls,False)
      cres@cnMinLevelValF  = mnmxint(0)
      cres@cnMaxLevelValF  = mnmxint(1)
      cres@cnLevelSpacingF = mnmxint(2)
    end if

    ; Plot the model plot.
    
    cres@tiMainString = case1 + " " + yrs_ave1
    if (color_type .eq. "COLOR") then
      cres@lbTitleString = "MIN = " + sprintf("%6.2f",min1) + "  MAX = " + sprintf("%6.2f",max1)
    end if

    cnplot(0) = gsn_csm_pres_hgt(wks, var1a(lev|:, lat|:), cres)

    ; Plot the obs/model plot.

    cres@tiMainString = case2 + " " + yrs_ave2
    if (color_type .eq. "COLOR") then
      cres@lbTitleString = "MIN = " + sprintf("%6.2f",min2) + "  MAX = " + sprintf("%6.2f",max2)
    end if

    cnplot(1) = gsn_csm_pres_hgt(wks, var2a(lev|:, lat|:), cres)
    
    ; Plot the difference plot.
    mind = min(diff)
    maxd = max(diff)

    dres@tiMainString = case1 + " - " + case2
    if (color_type .eq. "COLOR") then
      dres@lbLabelStride = 1
      dres@lbOrientation = "Vertical"
      dres@lbBoxMinorExtentF = 0.18
      if (isvar("dcon")) then
        dres@cnLevelSelectionMode = "ExplicitLevels" 
        dres@cnLevels = dcon(:)
        delete(dcon)
      else
        dres@cnLevelSelectionMode = "ManualLevels" 
      end if
      dres@cnFillPalette = cmapd
      dres@lbTitleString = "MIN = " + sprintf("%6.2f",mind) + "  MAX = " + sprintf("%6.2f",maxd)
      dres@cnLinesOn = True
      dres@cnLineLabelsOn = True
      dres@cnLineLabelPlacementMode = "Constant"
    else
      mnmxint = nice_mnmxintvl (mind, maxd, diffcnlvls, False)
      dres@cnMinLevelValF  = mnmxint(0)
      dres@cnMaxLevelValF  = mnmxint(1)
      dres@cnLevelSpacingF = mnmxint(2)
      delete(mnmxint)
    end if

    cnplot(2) = gsn_csm_pres_hgt(wks, diff(lev|:, lat|:), dres)

    
    ; Create the panel.      
    if (time_stamp .eq. "True") then
      pan@gsnPanelBottom = 0.05
      gsn_panel(wks, cnplot, (/ 2 , 2 /), pan)         ; panel plot
      infoTimeStamp(wks, 0.011, "DIAG Version: " + version)
    else
      gsn_panel(wks, cnplot, (/ 2, 2 /), pan)         ; panel plot
    end if

    frame (wks)
    delete(wks)
    
    delete(diff)
    delete(var1a)
    delete(var2a)
    delete(var1)
    delete(var2)
  end do
end


; This is the main entry point for the diagnostic plots.
begin

  ; Define the latitude bands
  periods  = (/ "06", "12", "JJA", "MAM", "SON", "DJF", "ANN" /)
  nPeriods = dimsizes(periods)
  
  
  do p = 0, nPeriods-1

    ; Get the model data.
    files = systemfunc("ls " + infile1 + "_" + periods(p) + "_climo.nc")
    if (any(ismissing(files))) then
      print(" plot_waccm_vcycle : ERROR - Missing model 1 data.")
    else
      inptr1 = addfile(files(0),"r")
    end if
    delete(files)
  
  
    ; Get data from the OBS or other model.
    if (compare .eq. "OBS") then
  
      ; ERAI
      obs     = "ERAI"
      obsName = "ERAI"
      years   = "(1989-2005)"

      files = systemfunc("ls " + infile2 + "/" + obs + "_" + periods(p) + "_climo.nc")
      if (any(ismissing(files))) then
        print(" plot_waccm_vzonal : ERROR - Missing " + obs + " data.")
      else
        inptr2 = addfile(files(0),"r")

        if (isatt(inptr2,"yrs_averaged")) then
          years = "(" + inptr2@yrs_averaged + ")"
        end if
      end if
      delete(files)

      ; Stratosphere
      vars    = (/  "H2O", "O3", "RELHUM", "T", "U", "V" /)
      nvars    = dimsizes(vars)
      minP     = new(nvars, float)
      minP(:)  = 1.
      maxP     = new(nvars, float)
      maxP(:)  = 200.
      pAbbr    = new(nvars, string)
      pAbbr(:) = "_z"

      plot_waccm_vzonal(inptr1, vars, inptr2, vars, obsName, years, minP, maxP, pAbbr, periods(p))
      delete(inptr2)
    
      delete(pAbbr)
      delete(maxP)
      delete(minP)
      delete(vars)
      
      
      ; MERRA
      obs     = "MERRAW_19x2"
      obsName = "MERRA"
      years   = "(1975-2015)"

      files = systemfunc("ls " + infile2 + "/" + obs + "_" + periods(p) + "_climo.nc")
      if (any(ismissing(files))) then
        print(" plot_waccm_vzonal : ERROR - Missing " + obs + " data.")
      else
        inptr2 = addfile(files(0),"r")

        if (isatt(inptr2,"yrs_averaged")) then
          years = "(" + inptr2@yrs_averaged + ")"
        end if
      end if
      delete(files)

      ; Middle Atmosphere
      vars    = (/  "H2O",  "T", "U", "V" /)
      nvars    = dimsizes(vars)
      minP     = new(nvars, float)
      minP(:)  = 1e-3
      maxP     = new(nvars, float)
      maxP(:)  = 500.
      pAbbr    = new(nvars, string)
      pAbbr(:) = ""
      
      plot_waccm_vzonal(inptr1, vars, inptr2, vars, obsName, years, minP, maxP, pAbbr, periods(p))

      delete(pAbbr)
      delete(maxP)
      delete(minP)

      ; Stratosphere
      minP     = new(nvars, float)
      minP(:)  = 1.
      maxP     = new(nvars, float)
      maxP(:)  = 200.
      pAbbr    = new(nvars, string)
      pAbbr(:) = "_z"

      plot_waccm_vzonal(inptr1, vars, inptr2, vars, obsName, years, minP, maxP, pAbbr, periods(p))
      delete(inptr2)
    
      delete(pAbbr)
      delete(maxP)
      delete(minP)
      delete(vars)


      ; MLSW - Temperature, Water vapor, ...
      obs     = "mlsw"
      obsName = "MLS"
      years   = "(2004-2016)"

      files = systemfunc("ls " + infile2 + "/" + obs + "_" + periods(p) + "_climo.nc")
      if (any(ismissing(files))) then
        print(" plot_waccm_vzonal : ERROR - Missing " + obs + " data.")
      else
        inptr2 = addfile(files(0),"r")

        if (isatt(inptr2,"yrs_averaged")) then
          years = "(" + inptr2@yrs_averaged + ")"
        end if
      end if
      delete(files)

      ; Middle Atmosphere
      vars    = (/  "H2O",  "O3", "RELHUM", "T", "Z3" /)
      nvars    = dimsizes(vars)
      minP     = new(nvars, float)
      minP(:)  = 1e-3
      maxP     = new(nvars, float)
      maxP(:)  = 500.
      pAbbr    = new(nvars, string)
      pAbbr(:) = ""
      
      plot_waccm_vzonal(inptr1, vars, inptr2, vars, obsName, years, minP, maxP, pAbbr, periods(p))

      delete(pAbbr)
      delete(maxP)
      delete(minP)

      ; Stratosphere
      minP     = new(nvars, float)
      minP(:)  = 1.
      maxP     = new(nvars, float)
      maxP(:)  = 200.
      pAbbr    = new(nvars, string)
      pAbbr(:) = "_z"

      plot_waccm_vzonal(inptr1, vars, inptr2, vars, obsName, years, minP, maxP, pAbbr, periods(p))
      delete(inptr2)
      
      delete(pAbbr)
      delete(maxP)
      delete(minP)
      delete(vars)


      ; MLSG - Most Trace Gases
      obs     = "mlsg"
      obsName = "MLS"
      years   = "(2004-2016)"

      files = systemfunc("ls " + infile2 + "/" + obs + "_" + periods(p) + "_climo.nc")
      if (any(ismissing(files))) then
        print(" plot_waccm_vzonal : ERROR - Missing " + obs + " data.")
      else
        inptr2 = addfile(files(0),"r")

        if (isatt(inptr2,"yrs_averaged")) then
          years = "(" + inptr2@yrs_averaged + ")"
        end if
      end if
      delete(files)

      ; Middle Atmosphere
      vars    = (/  "CO", "HO2" /)
      nvars    = dimsizes(vars)
      minP     = new(nvars, float)
      minP(:)  = 1e-3
      maxP     = new(nvars, float)
      maxP(:)  = 500.
      pAbbr    = new(nvars, string)
      pAbbr(:) = ""
      
      plot_waccm_vzonal(inptr1, vars, inptr2, vars, obsName, years, minP, maxP, pAbbr, periods(p))

      delete(pAbbr)
      delete(maxP)
      delete(minP)
      delete(vars)

      ; Stratosphere
      vars    = (/  "BRO",  "CH3CL", "CLO", "CO", "HCL", "HNO3", "HO2", "HOCL", "N2O" /)
      nvars    = dimsizes(vars)
      minP     = new(nvars, float)
      minP(:)  = 1.
      maxP     = new(nvars, float)
      maxP(:)  = 200.
      pAbbr    = new(nvars, string)
      pAbbr(:) = "_z"

      plot_waccm_vzonal(inptr1, vars, inptr2, vars, obsName, years, minP, maxP, pAbbr, periods(p))
      delete(inptr2)
      
      delete(pAbbr)
      delete(maxP)
      delete(minP)
      delete(vars)


      ; MLSO - OH
      obs     = "mlso"
      obsName = "MLS"
      years   = "(2004-2016)"

      files = systemfunc("ls " + infile2 + "/" + obs + "_" + periods(p) + "_climo.nc")
      if (any(ismissing(files))) then
        print(" plot_waccm_vzonal : ERROR - Missing " + obs + " data.")
      else
        inptr2 = addfile(files(0),"r")

        if (isatt(inptr2,"yrs_averaged")) then
          years = "(" + inptr2@yrs_averaged + ")"
        end if
      end if
      delete(files)

      ; Middle Atmosphere
      vars    = (/  "OH" /)
      nvars    = dimsizes(vars)
      minP     = new(nvars, float)
      minP(:)  = 1e-3
      maxP     = new(nvars, float)
      maxP(:)  = 500.
      pAbbr    = new(nvars, string)
      pAbbr(:) = ""
      
      plot_waccm_vzonal(inptr1, vars, inptr2, vars, obsName, years, minP, maxP, pAbbr, periods(p))

      delete(pAbbr)
      delete(maxP)
      delete(minP)

      ; Stratosphere
      minP     = new(nvars, float)
      minP(:)  = 1.
      maxP     = new(nvars, float)
      maxP(:)  = 200.
      pAbbr    = new(nvars, string)
      pAbbr(:) = "_z"

      plot_waccm_vzonal(inptr1, vars, inptr2, vars, obsName, years, minP, maxP, pAbbr, periods(p))
      delete(inptr2)
      
      delete(pAbbr)
      delete(maxP)
      delete(minP)
      delete(vars)
    
    else

      ; Model to Model
      
      files = systemfunc("ls " + infile2 + "_" + periods(p) + "_climo.nc")
      if (any(ismissing(files))) then
        print(" plot_waccm_vzonal : ERROR - Missing model 2 data.")
      else
        inptr2 = addfile(files(0), "r")
      end if
      delete(files)
    
      ; Get information for obs / model 2
      if (case_names .eq. "True") then
        case2 = getenv("CASE2")
      else
        if (isatt(inptr2, "case")) then
          case2 = inptr2@case
        else
          case2 = "Control"
        end if
       end if
      case2 = shorten_case_name(case2)

      if (isatt(inptr2,"yrs_averaged")) then
        yrs_ave2 = "(" + inptr2@yrs_averaged + ")"
      else
        yrs_ave2 = ""
      end if

      ; Middle Atmosphere
      vars     = (/  "CH4", "CO", "CO2", "H2O", "O3", "OH", "RELHUM", "QRS_TOT", "QRL_TOT", "SO2", "T", "U", "V"  /)
      nvars    = dimsizes(vars)
      minP     = new(nvars, float)
      minP(:)  = 1e-3
      maxP     = new(nvars, float)
      maxP(:)  = 500.
      pAbbr    = new(nvars, string)
      pAbbr(:) = ""
      
      plot_waccm_vzonal(inptr1, vars, inptr2, vars, case2, yrs_ave2, minP, maxP, pAbbr, periods(p))

      delete(pAbbr)
      delete(maxP)
      delete(minP)
      delete(vars)      
      
      ; Stratosphere
      vars     = (/ "CH4", "CO", "CO2", "H2O", "N2O", "O3", "OH", "RELHUM", "SO2", "T" /)
      nvars    = dimsizes(vars)
      minP     = new(nvars, float)
      minP(:)  = 1.
      maxP     = new(nvars, float)
      maxP(:)  = 200.
      pAbbr    = new(nvars, string)
      pAbbr(:) = "_z"
      
      plot_waccm_vzonal(inptr1, vars, inptr2, vars, case2, yrs_ave2, minP, maxP, pAbbr, periods(p))
      
      delete(inptr2)

      delete(pAbbr)
      delete(maxP)
      delete(minP)
      delete(vars)

    end if
  end do
end

  