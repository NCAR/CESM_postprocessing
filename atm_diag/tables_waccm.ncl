;***************************************************************
; NCL script
; tables_waccm.ncl
; Charles Bardeen, July 2016
;***************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_tables.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
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

; This routine calculates min, max, and average values of specified pressure levels and
; latitude ranges. Horizontally, the data is first averaged using latitude weights. If
; ofMin is true, then the minimum in the vertical of the horizontal average is used to
; compute the statistics. Otherwise, the average over the pressure levels is used.
procedure compute_waccm_minmaxavg(inptr1, vars1, inptr2, vars2, r, obsName, minP, maxP, pAbbr, ofMin, minLat, maxLat, latAbbr, tvars, tvals)

local i, nvars, var1, var2, gw1, gw2, var1a, var2a, j

begin
  pi = acos(-1.0)
  d2r = pi/180.0             ; convert degrees to radians

  ; Iterate over the varibles
  nvars = dimsizes(vars1)

  ; Determine latitude weighting.  
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
    
  ; Iterate over the variables
  do i = 0, nvars-1

    ; Do vertical interpolation first, since for hydrid coordinates,
    ; this should be done on lev x lat x lon data prior to averaging.
    ; Also calculate a zonal average.
    var1 = inptr1[:]->$vars1(i)$
    
    ; If the OBS/Model2 don't have a corresponding field, then
    ; skip it.
    if (isfilevar(inptr2[0], vars2(i))) then
      var2 = inptr2[:]->$vars2(i)$
    else
    
      ; If it is missing water vapor, look for specific humidity and convert.
      if (vars2(i) .eq. "H2O") then
        if (isfilevar(inptr2[0], "SHUM")) then
          var2 = inptr2[:]->SHUM
          var2 = (/ var2 * 28.89 / 18. / 1e3 /)     ; convert from g/kg to ppv
        else
          if (isfilevar(inptr2[0], "Q")) then
            var2 = inptr2[:]->Q
            var2 = (/ var2 * 28.89 / 18. /)     ; convert from g/kg to ppv
          else
            continue
          end if   
        end if   
      else
        continue
      end if
    end if
    
    if (vars1(i) .eq. "H2O") then
      var1 = (/ var1 * 1e6 /)
      var2 = (/ var2 * 1e6 /)
    end if

    ; iterate over the latitudes (i.e. tables)
    nlats = dimsizes(minLat)
    do j = 0, nlats-1

      ; Calculate the min/max/mean of the min values each month.
      rbase = r*nvars*3
      tvars(j, rbase+i*3+0) = vars1(i) + "_" + pAbbr(i) + "_MIN" + obsName
      tvars(j, rbase+i*3+1) = vars1(i) + "_" + pAbbr(i) + "_AVG" + obsName
      tvars(j, rbase+i*3+2) = vars1(i) + "_" + pAbbr(i) + "_MAX" + obsName

      ; If the minimum pressur eis smaller than the data, then skip it.
      if (minP(i) .lt. min(var2&lev)) then
        continue
      end if
      
      ; One level or a range of levels?
      if (minP(i) .eq. maxP(i)) then
        var1a = dim_avg_wgt_Wrap(dim_avg_Wrap(var1(:, {minP(i)}, {minLat(j):maxLat(j)}, :)), gw1({minLat(j):maxLat(j)}), 1)
        var2a = dim_avg_wgt_Wrap(dim_avg_Wrap(var2(:, {minP(i)}, {minLat(j):maxLat(j)}, :)), gw2({minLat(j):maxLat(j)}), 1)
      else
        var1a = dim_avg_wgt_Wrap(dim_avg_Wrap(var1(:, {minP(i):maxP(i)}, {minLat(j):maxLat(j)}, :)), gw1({minLat(j):maxLat(j)}), 1)
        var2a = dim_avg_wgt_Wrap(dim_avg_Wrap(var2(:, {minP(i):maxP(i)}, {minLat(j):maxLat(j)}, :)), gw2({minLat(j):maxLat(j)}), 1)
      end if
    
      ; Use the minima or evaluate the whole range.
      if (ofMin(j)) then
        if (minP(i) .eq. maxP(i)) then
          tvals(j, rbase+i*3+0, 0) = dim_min(var1a(:))
          tvals(j, rbase+i*3+1, 0) = dim_avg(var1a(:))
          tvals(j, rbase+i*3+2, 0) = dim_max(var1a(:))

          tvals(j, rbase+i*3+0, 1) = dim_min(var2a(:))
          tvals(j, rbase+i*3+1, 1) = dim_avg(var2a(:))
          tvals(j, rbase+i*3+2, 1) = dim_max(var2a(:))
        else
          tvals(j, rbase+i*3+0, 0) = dim_min(dim_min(var1a(:, :)))
          tvals(j, rbase+i*3+1, 0) = dim_avg(dim_min(var1a(:, :)))
          tvals(j, rbase+i*3+2, 0) = dim_max(dim_min(var1a(:, :)))

          tvals(j, rbase+i*3+0, 1) = dim_min(dim_min(var2a(:, :)))
          tvals(j, rbase+i*3+1, 1) = dim_avg(dim_min(var2a(:, :)))
          tvals(j, rbase+i*3+2, 1) = dim_max(dim_min(var2a(:, :)))
        end if
      else
        tvals(j, rbase+i*3+0, 0) = min(var1a)
        tvals(j, rbase+i*3+1, 0) = avg(var1a)
        tvals(j, rbase+i*3+2, 0) = max(var1a)

        tvals(j, rbase+i*3+0, 1) = min(var2a)
        tvals(j, rbase+i*3+1, 1) = avg(var2a)
        tvals(j, rbase+i*3+2, 1) = max(var2a)
      end if
      
      delete(var1a)
      delete(var2a)
    end do
    
    delete(var1)
    delete(var2)
  end do

  ; Calculate Model - Obs or Model - Model  
  tvals(:, r*nvars*3:(r+1)*nvars*3-1, 2) = tvals(:, r*nvars*3:(r+1)*nvars*3-1, 0) - tvals(:, r*nvars*3:(r+1)*nvars*3-1, 1)
end


; This is the main entry point for generating the tables.
begin

  set_prefix = "wset1"

  ; Define the latitude bands
  minLat  = (/ -90.,    -10,   60. /)
  maxLat  = (/ -60.,    10.,   90. /)
  latAbbr = (/ "_SP", "_EQ", "_NP" /)
  latName = (/ "SOUTH POLE (60S-90S)", "TROPICS (10S-10N)", "NORTH POLE (60N-90N)" /)
  nTables = dimsizes(latAbbr)
  
  ; Define the model variables and the range of pressure levels over
  ; which to plot them.
  vars  = (/     "T",   "H2O",     "T", "H2O",   "T" /)
  minP  = (/      50,      1.,    5e-4,   85.,   85. /)
  maxP  = (/    120.,    120.,    1e-2,   85.,   85. /)
  pAbbr = (/   "TRP",   "STR",   "MSP",  "85",  "85" /)
  ofMin = (/    True,   False,    True, False, False /)
  nVars = dimsizes(vars)
  
  ; Get the model data.
  files = systemfunc("ls " + infile1 + "_??_climo.nc")
  if (any(ismissing(files))) then
    print(" tables_waccm : ERROR - Missing model 1 data.")
  else
    inptr1 = addfiles(files,"r")
  end if
  delete(files)
  
  ; Get information for model 1
  if (case_names .eq. "True") then
   case1 = getenv("CASE1")
  else
    if (isatt(inptr1[0], "case")) then
      case1 = inptr1[0]@case
    else
      case1 = "Control"
    end if
  end if
  label1 = shorten_case_name(case1)

  if (isatt(inptr1[0],"yrs_averaged")) then
    yrs_ave1 = "(" + inptr1[0]@yrs_averaged + ")"
  else
    yrs_ave1 = ""
  end if
  
  ; Get data from the OBS or other model.
  if (compare .eq. "OBS") then
  
    ; Reanalysis data sets.
    ;
    ; NOTE: For WACCM, we need to make reanalysis data sets that go
    ; to higher altitudes (lower pressures).
    obs     = (/ "MLS", "MERRAW_19x2" /)
    obsName = (/ "MLS", "MERRA" /)
    nObs = dimsizes(obs)
    
    tvars = new((/ nTables, nVars * nObs * 3 /), string)
    tvars(:,:) = ""
    
    tvals = new((/ nTables, nVars * nObs * 3, 4 /), float)
    tvals(:,:,:) = 0.
    
    do r = 0, nObs-1
    
      files = systemfunc("ls " + infile2 + "/" + obs(r) + "_??_climo.nc")
      if (any(ismissing(files))) then
        print(" tables_waccm : ERROR - Missing " + obs(r) + " data.")
      else
        inptr2 = addfiles(files,"r")
      end if
      delete(files)

      ; Do model to obs tables.
      compute_waccm_minmaxavg(inptr1, vars, inptr2, vars, r, "_"+obsName(r), minP, maxP, pAbbr, ofMin, minLat, maxLat, latAbbr, tvars, tvals)

      delete(inptr2)
    end do
    
    ; Additional values could be added now to tvars and tvals before the table is generated.

    ; Write out the tables
    do i = 0, nTables-1
      tablename = wkdir + "/" + set_prefix + "_table" + latAbbr(i) + "_obs.asc"
      title = (/"DIAG WSET 1: MONTHLY MIN,MAX,MEAN " + latName(i) /)

      make_table(label1, case1, "OBS data", "OBS data", tvars(i, :), tvals(i, :, :), title, tablename)
    end do
    
  else

    files = systemfunc("ls " + infile2 + "_??_climo.nc")
    if (any(ismissing(files))) then
      print(" tables_waccm : ERROR - Missing model 2 data.")
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
    label2 = shorten_case_name(case2)

    if (isatt(inptr2[0],"yrs_averaged")) then
      yrs_ave2 = "(" + inptr2[0]@yrs_averaged + ")"
    else
      yrs_ave2 = ""
    end if

    ; Do model to model tables.
    tvars = new((/ nTables, nVars * 3 /), string)
    tvals = new((/ nTables, nVars * 3, 4 /), float)
    
    compute_waccm_minmaxavg(inptr1, vars, inptr2, vars, 0, "", minP, maxP, pAbbr, ofMin, minLat, maxLat, latAbbr, tvars, tvals)
    delete(inptr2)

    ; Additional values could be added now to tvars and tvals before the table is generated.

    ; Write out the tables
    do i = 0, nTables-1
      tablename = wkdir + "/" + set_prefix + "_table" + latAbbr(i) + ".asc"
      title = (/"DIAG WSET 1: MONTHLY MIN,MAX,MEAN " + latName(i) /)
      make_table(label1, case1, label2, case2, tvars(i, :), tvals(i, :, :), title, tablename)
    end do

  end if
end

