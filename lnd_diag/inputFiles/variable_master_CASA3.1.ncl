function var_init(varName:string)
local secondsInDay,secondsInYear,grams2Pgrams,grams2Tgrams,umols2mols,\
   gramsCperMole,fraction2percent,kgCO2_to_ppmv,kgCO2_to_gC
begin

  info = True

; ------------------------------------------------------------------------------------------
; Flux conversions:  
; ------------------------------------------------------------------------------------------
  secondsInDay  = 86400     ; 60s/min * 60min/hr * 24hr/day
  secondsInYear = 3.1536e07 ;60s/min * 60min/hr * 24hr/day * 365day/y
  grams2Pgrams  = 1e-15	
  grams2Tgrams  = 1e-12	
  grams2Kgrams  = 1e-3
  umols2mols    = 1e-6
  gramsCperMole = 12.0107	
  fraction2percent = 100.
  kgCO2_to_ppmv    = 1e6 * (28.966/44.)
  kgCO2_to_gC      = 1e3 * (12.011/44.)
  
; ------------------------------------------------------------------------------------------
; ------------------------------------------------------------------------------------------

  if (varName .eq. "BGTEMP") then
    info@flux=False
    info@longName="Temperature Dependence"
    info@nativeUnits="unitless"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "BGMOIST") then
    info@flux=False
    info@longName="Moisture Dependence"
    info@nativeUnits="unitless"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "NPP") then
    info@flux=True
    info@longName="Net Primary Production"
    info@nativeUnits="gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.50, -1.2, -0.9, -0.6, -0.3, 0., 0.3, 0.6, 0.9, 1.2, 1.5/)
    return(info)
  end if

  if (varName .eq. "CFLUX") then
    info@flux=True
    info@longName="Total C Flux"
    info@nativeUnits="gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "CLOSS") then
    info@flux=True
    info@longName="Total C Lost by Pool"
    info@nativeUnits="gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "CO2FLUX") then
    info@flux=True
    info@longName="Net CO2 Flux"
    info@nativeUnits="gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-0.1, -0.075, -0.05, -0.025, 0.0, 0.025, 0.05, 0.075, 0.1/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "EXCESSC") then
    info@flux=True
    info@longName="Excess C"
    info@nativeUnits="gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "PET") then
    info@flux=True
    info@longName="Potential ET"
    info@nativeUnits="mm/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "mm/y"
    info@globalTotal_Annual__SF    = secondsInYear
    ; -- global Mean
    info@globalMean__units         = "mm/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "mm/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "mm/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,6.,12.,18.,24.,30.,36.,42.,48./)
    return(info)
  end if

  if (varName .eq. "RESP_C") then
    info@flux=True
    info@longName="C lost to Atmosphere"
    info@nativeUnits="gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
; state variables -------------------------------------
  if (varName .eq. "DEGDAY") then
    info@flux=False
    info@longName="Accumulated Degree Days"
    info@nativeUnits="C"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "C"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "ISEABEG") then
    info@flux=False
    info@longName="Index for start of growing season"
    info@nativeUnits=""
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LGROW") then
    info@flux=False
    info@longName="Growing season index (0 or 1)"
    info@nativeUnits=""
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LIVEFR") then
    info@flux=False
    info@longName="Live fraction leaf,wood,froot"
    info@nativeUnits="g/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "g/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "NSTEPBEG") then
    info@flux=False
    info@longName="Nstep at start of growing season"
    info@nativeUnits=""
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = ""
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "PLAI") then
    info@flux=False
    info@longName="Prognostic LAI"
    info@nativeUnits="m^2/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m^2/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SOILT") then
    info@flux=False
    info@longName="Soil temperature: top 30cm"
    info@nativeUnits="C"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "C"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SMOIST") then
    info@flux=False
    info@longName="Soil moisture: top 30cm"
    info@nativeUnits="mm3/mm3"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm3/mm3"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "STRESSCD") then
    info@flux=False
    info@longName="Cold+drought stress fcn for leaf loss"
    info@nativeUnits="unitless"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "STRESST") then
    info@flux=False
    info@longName="Temperature stress fcn for leaf loss"
    info@nativeUnits="unitless"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "STRESSW") then
    info@flux=False
    info@longName="Water stress fcn for leaf loss"
    info@nativeUnits="unitless"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "TDAYAVG") then
    info@flux=False
    info@longName="Daily Averaged T"
    info@nativeUnits="C"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "C"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "TPOOL_C") then
    info@flux=False
    info@longName="Total C for pool"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LIVEFR_LEAFC") then
    info@flux=False
    info@longName="Live Fraction Leaf C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "LIVEFR_WOODC") then
    info@flux=False
    info@longName="Live Fraction Wood C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "LIVEFR_FROOTC") then
    info@flux=False
    info@longName="Live Fraction Froot C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if



  if (varName .eq. "LEAFC") then
    info@flux=False
    info@longName="Total Leaf C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "WOODC") then
    info@flux=False
    info@longName="Total Wood C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "FROOTC") then
    info@flux=False
    info@longName="Total Fine Root C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "SURFMETC") then
    info@flux=False
    info@longName="Total Metabolized Litter C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "SURFSTRC") then
    info@flux=False
    info@longName="Total Structural Litter C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "SOILMETC") then
    info@flux=False
    info@longName="Total Metabolized Structural Soil C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "SOILSTRC") then
    info@flux=False
    info@longName="Total Structural Soil C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CWDC") then
    info@flux=False
    info@longName="Total Coarse Woody Debris C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "SURFMIC") then
    info@flux=False
    info@longName="Total Microbial Litter C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "SOILMIC") then
    info@flux=False
    info@longName="Total Microbial Soil C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "SLOWC") then
    info@flux=False
    info@longName="Total Slow C Pool"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "PASSIVEC") then
    info@flux=False
    info@longName="Total Passive C Pool"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_LEAFC") then
    info@flux=False
    info@longName="Respired Leaf C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "RESP_WOODC") then
    info@flux=False
    info@longName="Respired Wood C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_FROOTC") then
    info@flux=False
    info@longName="Respired Fine Root C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_SURFMETC") then
    info@flux=False
    info@longName="Respired Metabolized Litter C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_SURFSTRC") then
    info@flux=False
    info@longName="Respired Structural Litter C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_SOILMETC") then
    info@flux=False
    info@longName="Respired Metabolized Soil C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_SOILSTRC") then
    info@flux=False
    info@longName="Respired Structural Soil C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_CWDC") then
    info@flux=False
    info@longName="Respired Coarse Woody Debris C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_SURFMIC") then
    info@flux=False
    info@longName="Respired Microbial Litter C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_SOILMIC") then
    info@flux=False
    info@longName="Respired Microbial Soil C"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_SLOWC") then
    info@flux=False
    info@longName="Respired Slow C Pool"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "RESP_PASSIVEC") then
    info@flux=False
    info@longName="Respired Passive C Pool"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_LEAF") then
    info@flux=False
    info@longName="Leaf C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "CLOSS_WOOD") then
    info@flux=False
    info@longName="Wood C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_FROOT") then
    info@flux=False
    info@longName="Fine Root C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_SURFMET") then
    info@flux=False
    info@longName="Metabolized Litter C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_SURFSTR") then
    info@flux=False
    info@longName="Structural Litter C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_SOILMET") then
    info@flux=False
    info@longName="Metabolized Structural Soil C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_SOILSTR") then
    info@flux=False
    info@longName="Structural Soil C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_CWD") then
    info@flux=False
    info@longName="Coarse Woody Debris C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_SURFMIC") then
    info@flux=False
    info@longName="Microbial Litter C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_SOILMIC") then
    info@flux=False
    info@longName="Microbial Soil C Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_SLOW") then
    info@flux=False
    info@longName="Slow C Pool Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if
  if (varName .eq. "CLOSS_PASSIVE") then
    info@flux=False
    info@longName="Passive C Pool Loss"
    info@nativeUnits="gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = True 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if


  if (varName .eq. "WATDRY") then
    info@flux=False
    info@longName="watdry for entire column"
    info@nativeUnits="mm3/mm3"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm3/mm3"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "WATOPT") then
    info@flux=False
    info@longName="watopt for entire column"
    info@nativeUnits="mm3/mm3"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm3/mm3"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "WLIM") then
    info@flux=False
    info@longName="water limitation used in bgmoist (atmp factor)"
    info@nativeUnits="unitless"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "XSCPOOL") then
    info@flux=False
    info@longName="total excess C"
    info@nativeUnits="g/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "g/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CASA" 
    info@derivedVariable           = False 
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

    info = False
    print("no variable info for variable "+ varName)
    return(info)
end


