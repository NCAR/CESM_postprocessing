; file: functions_waccm.ncl
; some functions used for waccm plots
;******************************************************************
; Charles Bardeen
; normalized cosine weights


; Does a vertical interpolation of the supplied data to pressure
; levels.
;
; NOTE this function assumes that inptr is a single pointer
; from addfile.
function waccm_vintrp(inptr, ivar, lev)

local hyam, hybm, tmp, ps, p0, interp, extrap

begin

  ; If the data is on hybrid coordinates then interpolate to pressure.
  ; Otherwise assume it is already on pressure levels.
  if (isfilevar(inptr, "hyam")) then
    p0     = 1000.     ; mb required by vinth2p
    interp = 2         ; log interpolation
    extrap = False     ; no extrapolation past psfc.

    hyam = inptr->hyam
    hybm = inptr->hybm

    tmp  = inptr->PS(:,:,:)      
    if (typeof(tmp).eq."double") then
      ps = dble2flt(tmp)
    else
      ps = tmp
    end if 
    delete(tmp)

    tmp = vinth2p(ivar, hyam, hybm, lev, ps, interp, p0, 1, extrap)
    tmp@long_name = ivar@long_name
    tmp@units     = ivar@units
    
    ; This still allows extrapolation beyond the top of the model, so set those
    ; to the fill value.
    if (min(lev) .lt. min(ivar&lev)) then

      ; Make sure a fill value is defined.
      if (.not. isatt(tmp, "_FillValue")) then
        tmp@_FillValue = default_fillvalue(typeof(tmp))
      end if
    
      tmp(:,{min(lev):min(ivar&lev)},:,:) = tmp@_FillValue
    end if
  else
    interp = 0         ; log interpolation

    ; NOTE: In future, check for altitude scales for some observations?
    tmp = int2p_n_Wrap(ivar&lev, ivar, lev, interp, 1)
  end if
  
  if (typeof(tmp).eq."double") then
    ovar = dble2flt(tmp)
  else
    ovar = tmp
  end if
  delete(tmp)
  
  return(ovar)
end


; Scale mixing ratio and length variables.
procedure waccm_scaleunits(varname, iunits, varmin, varmax, scale, ounits)

begin

  ; Adjust units
  scale  = 1.
  ounits = iunits

  if ((iunits .eq. "mol/mol") .or. (iunits .eq. "kg/kg")) then
    if (varmax .lt. 1e-12) then
      scale   = 1e15
      ounits   = "ppq"
    else
      if (varmax .lt. 1e-9) then
        scale   = 1e12
        ounits   = "ppt"
      else
        if (varmax .lt. 1e-6) then
          scale   = 1e9
          ounits   = "ppb"
        else
          if (varmax .lt. 1e-3) then
            scale   = 1e6
            ounits  = "ppm"
          end if
        end if
      end if
    end if
    
    ; For water vapor, always want ppm for WACCM
    if (varname .eq. "H2O") then
      scale   = 1e6
      ounits  = "ppm"
    end if

    ; For carbon monoxide, always want ppm for WACCM
    if (varname .eq. "CO") then
      scale   = 1e6
      ounits  = "ppm"
    end if

    if (scale .ne. 1.) then
      if (iunits .eq. "mol/mol") then
        ounits = ounits + "v"
      end if
    end if
  end if
  
  if (iunits .eq. "m") then
    if (varmax .gt. 1e3) then
      scale   = 1e-3
      ounits  = "km"
    else
      if (varmax .lt. 1e-2) then
        scale   = 1e6
        ounits  = "um"
      else
        if (varmax .lt. 1.) then
          scale   = 1e2
          ounits  = "cm"
        end if
      end if
    end if
  end if
end


; Does a vertical interpolation of the supplied data to pressure
; levels.
;
; NOTE this function assumes that inptr is an array of pointers
; from addfiles.
function waccm_vintrps(inptr, ivar, lev)

local hyam, hybm, tmp, ps, p0, interp, extrap

begin

  ; If the data is on hybrid coordinates then interpolate to pressure.
  ; Otherwise assume it is already on pressure levels.
  if (isfilevar(inptr[0], "hyam")) then
    p0     = 1000.     ; mb required by vinth2p
    interp = 2         ; log interpolation
    extrap = False     ; no extrapolation past psfc.

    hyam = inptr[0]->hyam
    hybm = inptr[0]->hybm

    tmp  = inptr[:]->PS(:,:,:)      
    if (typeof(tmp).eq."double") then
      ps = dble2flt(tmp)
    else
      ps = tmp
    end if 
    delete(tmp)

    tmp = vinth2p(ivar, hyam, hybm, lev, ps, interp, p0, 1, extrap)
    tmp@long_name = ivar@long_name
    tmp@units     = ivar@units

    ; This still allows extrapolation beyond the top of the model, so set those
    ; to the fill value.
    if (min(lev) .lt. min(ivar&lev)) then

      ; Make sure a fill value is defined.
      if (.not. isatt(tmp, "_FillValue")) then
        tmp@_FillValue = default_fillvalue(typeof(tmp))
      end if
    
      tmp(:,{min(lev):min(ivar&lev)},:,:) = tmp@_FillValue
    end if
  else
    interp = 0         ; log interpolation

    ; NOTE: In future, check for altitude scales for some observations?
    tmp = int2p_n_Wrap(ivar&lev, ivar, lev, interp, 1)
  end if
  
  if (typeof(tmp).eq."double") then
    ovar = dble2flt(tmp)
  else
    ovar = tmp
  end if
  delete(tmp)
  
  return(ovar)
end


; Case names are getting really long and are too big for plot titles.
; If the case name is too long shorten it to xxx...yyy.
function shorten_case_name(case)

local maxlen, len, tmp

begin
  maxlen = 12
  
  len = strlen(case)
  if (len .le. maxlen+3) then
    tmp = case
  else
    tmp = str_get_cols(case, 0, maxlen/2 -1) + "..." + str_get_cols(case, -maxlen/2, -1)
  end if
  
  return(tmp)
end


undef("nice_mnmxintvl_log")
function nice_mnmxintvl_log(minval, maxval, numlevs, drange)

local minabs, maxabs, nicelevs, epos, eneg 

begin

  ; Default drange to cover full range if nothing was provided.
  if (drange .eq. 0) then
    drange = abs(log10(max(abs(maxval))) - log10(max(abs(minval))))
    
    if (drange < 3) then
      drange = 3
    end if

    if (drange > 15) then
      drange = 15
    end if
  end if

  
  ; Does the range span 0?
  if (minval * maxval .lt. 0.) then

    ; Pick a spacing based upon the largest value.
    maxabs = max((/ abs(minval), abs(maxval) /))
    minabs = maxabs / (10^(drange))

    maxmin = nice_mnmxintvl(log10(minabs), log10(maxabs), numlevs / 2, False)
    
    nicelevs = tointeger((maxmin(1) - maxmin(0)) / maxmin(2) + 1)

    eneg = fspan(maxmin(1), maxmin(0), nicelevs)
    eneg = -1 * (10.^eneg)

    epos = -1 * eneg(::-1)
    
    elevels = array_append_record(eneg, epos, 0)
    
    delete(eneg)
    delete(epos)
  else
    
    ; One sided, so just take the log and build a scale.
    if ((minval .eq. 0.) .or. (maxval .eq. 0.)) then
    
      ; Since we can't go to zero, use the drange.
      ; Could look for largest non-zero value.
      if (maxval .eq. 0.) then
        maxval = minval / (10^(drange))
      else
        minval = maxval / (10^(drange))
      end if
    end if

    if (minval .lt. 0.) then
      maxmin = nice_mnmxintvl(log10(abs(maxval)), log10(abs(minval)), numlevs, False)
    else
      maxmin = nice_mnmxintvl(log10(abs(minval)), log10(abs(maxval)), numlevs, False)
    end if

    nicelevs = tointeger((maxmin(1) - maxmin(0)) / maxmin(2) + 1)

    elevels = fspan(maxmin(0), maxmin(1), nicelevs)
    elevels = 10.^elevels

    if (minval .lt. 0.) then
      elevels = elevels(::-1) * -1
    end if
  end if

  return(elevels)
end 



;***********************************************************************;
; Procedure : set_pres_hgt_axes                                         ;
;               pres: numeric                                           ;
;                res: logical                                           ;
;            add_hgt: logical                                           ;
;                                                                       ;
; NOTE: This function is a slight alteration of gsn_csm_pres_hgt that   ;
; creates a vertical scale that has reasonable height values for        ;
; altitudes > 85 km. The data for this come from the US Standard        ;
; Atmosphere 1976.                                                      ;
;                                                                       ;
; This procedure sets some resources necessary to label the left and    ;
; right Y axis with "nice" pressure and height values. The left axis is ;
; values, and the right for height values. The pressure values are      ;
; assumed to be in millibars.                                           ;
;***********************************************************************;
undef("set_pres_hgt_axes")
procedure set_pres_hgt_axes(pres:numeric,res:logical,add_hgt:logical)
local hgt, hnice, pnice, ptmp
begin
  if(pres(0).lt.pres(dimsizes(pres)-1))
    ptmp = tofloat_wunits(pres(::-1))    ; reverse values so descending order
  else
    ptmp = tofloat_wunits(pres)          ; Make sure values are floating point.
  end if

  if(.not.(isatt(res,"sfYCStartV").and.isatt(res,"sfYCEndV")))
    set_attr(res,"sfYArray",ptmp)
  end if

;
; Set up the "nice" pressure values for which to label the left axis.
;
  if(.not.isatt(res,"tmYLMode"))
    res@tmYLMode   = "Explicit" ; Define own tick mark labels.
    res@tmYLValues = (/1000.,  850., 700., 500., 400., 300., 250., \
                       200., 150., 100.,  70., 50., 30., 10., 1., \
                       0.1, 0.01, 0.001, 0.0001/)
    res@tmYLLabels = (/"1000","850","700","500","400","300","250", \
                       "200","150","100", "70", "50", "30", "10", "1", "0.1", \
                       "0.01", "0.001", "0.0001"/)
    res@tmYLMinorOn= False        ; No minor tick marks.
    set_attr(res,"tiYAxisString","Pressure (mb)")
  end if

;
; Calculate "nice" height values for which to label the right axis
;
  if(.not.isatt(res,"tmYRMode"))
    add_hgt = True
    
;
; If the maximium height is greater than 85 km, then theheight estimates from
; gsn_geop_hgt are not accurate. In this case, use a height axis which is just
; a table of values every 10km from 0 - 200km based on the US Standard
; Atmosphere.

    if (min(ptmp).le.0.01) then

      pnice = (/ 1013.25, 264.99, 55.293, 11.970, 2.8714, 0.79779, \
                 0.21958, 5.2209e-2, 1.0524e-2, 1.8359e-3, 3.2011e-4, \
                 7.1042e-5, 2.5382e-5, 1.2505e-5, 7.2028e-6, 4.5422e-6, \
                 3.0395e-6, 2.1210e-6, 1.5271e-6, 1.1266e-6, 8.4736e-7 /)
      hnice = (/ "0", "10", "20", "30", "40", "50", \
                 "60", "70", "80", "90", "100", \
                 "110", "120", "130", "140", "150", \
                 "160", "170", "180", "190", "200" /)

    else    
      hgt    = gsn_geop_hgt(ptmp)     ; Calculate hgts as a fcn of pres.
      
      hrange = fabs(hgt(0)-hgt(dimsizes(hgt)-1))
      if(hrange.le.35) then
        step = 4
      else
        if(hrange.le.70) then
          step = 7
        else
          step = 10
        end if
      end if

; If user has set the resource "tmYRTickSpacingF", then use this for
; the value of the height spacing, instead of our calculated values
; above.  This value must be a "nice" value, like 1, 2, 4, etc.
;
      step = tointeger(get_res_value(res,"tmYRTickSpacingF",step))
                                            ; Set range of "nice" hgt values.
      hnice = tofloat(ispan(tointeger(floor(hgt(0))), \
                      tointeger(ceil(hgt(dimsizes(hgt)-1))),step))
      pnice = ftcurv(hgt,ptmp,hnice)  ; Get pres vals at nice hgt vals.
      delete(hgt)
    end if

    use_left    = get_res_value_keep(res,"tmYUseLeft",False)
    yrvalues    = get_res_value_keep(res,"tmYRValues",pnice)
    yrlabels    = get_res_value_keep(res,"tmYRLabels",hnice)
    yron        = get_res_value_keep(res,"tmYROn",True)
    yrlabelson  = get_res_value_keep(res,"tmYRLabelsOn",True )
    yrminoron   = get_res_value_keep(res,"tmYRMinorOn",False)
;
; At each "nice" pressure value put a "height" value label, unless
; the user has specified own labels.  The user has to know what he's
; doing if he specifies own labels, because the values must be in pressure
; units, not height units.
;
    if(.not.isatt(res,"tmYRValues")) then
      res@tmYRValues  = yrvalues
    end if
    if(.not.isatt(res,"tmYRLabels")) then
      res@tmYRLabels  = yrlabels
    end if
    res@tmYRMode      = "Explicit"
    res@tmYUseLeft    = use_left
    res@tmYROn        = yron
    res@tmYRLabelsOn  = yrlabelson
    res@tmYRMinorOn   = yrminoron
    delete(hnice)
    delete(pnice)
  else
    add_hgt = False
  end if
  delete(ptmp)
  return
end