function var_init(varName:string)
local secondsInDay,secondsInYear,grams2Pgrams,grams2Tgrams,umols2mols,\
gramsCperMole
; History:  created by nanr: /cgd/tss/nanr/diag/srcCode/lnd3.0_alterVarMst.pl
;           input:  variable_master3.0.ncl 
; Flux conversions:  
begin
  secondsInDay  = 86400     ; 60s/min * 60min/hr * 24hr/day
  secondsInYear = 3.1536e07 ;60s/min * 60min/hr * 24hr/day * 365day/y
  grams2Pgrams  = 1e-15	
  kgrams2Pgrams = 1e-12
  kgrams2grams  = 1e3
  grams2Tgrams  = 1e-12	
  grams2Kgrams  = 1e-3	
  umols2mols    = 1e-6
  mols2umols    = 1e6
  mols2Tmols    = 1e-12
  uGrams2Kgrams = 1e-9
  hr2sec 	= 3600.
  m2km      = 1.e9
  gramsCperMole = 12.0107	
  fraction2percent = 100.
  kgCO2_to_ppmv    = 1e6 * (28.966/44.)
  kgCO2_to_gC      = 1e3 * (12.011/44.)
  
; create global mean/total without changing time units.
; globalTotal__units  
; globalMean_units      
; state variables do not have:
;   globalMean_Annual, 
;   globalMean_daily, 
;   globalTotal_Annual, 
;   globalTotal_daily (which we don not define for any variables)
; contour intervals.  if we don't have explicit levels yet, and don't have a 
; set min/max, default flag will be to dynamically set range as is already 
; done for CN variables.
;   info@cn_Explicit               = True
;   info@cn_Min                    = -999
;   info@cn_Max                    = -999
;   info@cn_Levels                 = -999.

; ------------------------------------------------------------------------------------------
; FORMAT NOTE:  each line of variable definition ('if (varname .eq. ....)' 
;	 must be indented at least one space for the perl routine (land_create_webpage.pl).
; ------------------------------------------------------------------------------------------


  info = True
; set default values for attributes that may not be set for some variables
  info@altNames = ""

  if (varName .eq. "NEE") then
    info@flux=True
    info@longName="net ecosys exchange of C;incl fire flx;pos for source"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-0.1, -0.075, -0.05, -0.025, 0.0, 0.025, 0.05, 0.075, 0.1/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if
  if (varName .eq. "NEP") then
    info@flux=True
    info@longName="net ecosystem production;excl fire flx;pos for sink"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  if (varName .eq. "NBP") then
    info@flux=True
    info@longName="net biome production, includes fire, landuse and harvest flux"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "GPP") then
    info@flux=True
    info@longName="gross primary production"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "CUE") then
    info@flux=True
    info@longName="carbon use efficiency"
    info@nativeUnits = "NPP/GPP"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "NPP/GPP"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NPP/GPP"
    info@globalMean_Annual__SF     =  1.0
    info@globalMean_Daily__units   = "NPP/GPP"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "LAND_USE_FLUX") then
    info@flux=True
    info@longName="total C emitted from land cover conversion and wood product pools"
    info@nativeUnits = "gC/m^2/s"
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
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-0.1, -0.075, -0.05, -0.025, 0.0, 0.025, 0.05, 0.075, 0.1/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "PCT_BSOIL_PFT") then
    info@flux=False
    info@longName="Percent Bare Soil on Natural Veg Landunit"
    info@nativeUnits = "%"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "%"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/10., 20., 30., 40., 50., 60., 70., 80., 90./)
    info@cn_LevelsDiff             = (/-100.0,-80.0,-60.0,-40.0,-20.0,0.,20.0,40.0,60.0,80.0,100.0/)
    return(info)
  end if

  if (varName .eq. "PCT_TREE_PFT") then
    info@flux=False
    info@longName="Percent Tree on Natural Veg Landunit"
    info@nativeUnits = "%"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "%"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/10., 20., 30., 40., 50., 60., 70., 80., 90./)
    info@cn_LevelsDiff             = (/-100.0,-80.0,-60.0,-40.0,-20.0,0.,20.0,40.0,60.0,80.0,100.0/)
    return(info)
  end if

  if (varName .eq. "PCT_GRASS_PFT") then
    info@flux=False
    info@longName="Percent Grass on Natural Veg Landunit"
    info@nativeUnits = "%"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "%"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/10., 20., 30., 40., 50., 60., 70., 80., 90./)
    info@cn_LevelsDiff             = (/-100.0,-80.0,-60.0,-40.0,-20.0,0.,20.0,40.0,60.0,80.0,100.0/)
    return(info)
  end if

  if (varName .eq. "PCT_SHRUB_PFT") then
    info@flux=False
    info@longName="Percent Shrub on Natural Veg Landunit"
    info@nativeUnits = "%"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "%"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/10., 20., 30., 40., 50., 60., 70., 80., 90./)
    info@cn_LevelsDiff             = (/-100.0,-80.0,-60.0,-40.0,-20.0,0.,20.0,40.0,60.0,80.0,100.0/)
    return(info)
  end if

  if (varName .eq. "PCT_CROP_PFT") then
    info@flux=False
    info@longName="Percent Crop on Natural Veg Landunit or Gridcell (CropModel)"
    info@nativeUnits = "%"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "%"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/10., 20., 30., 40., 50., 60., 70., 80., 90./)
    info@cn_LevelsDiff             = (/-100.0,-80.0,-60.0,-40.0,-20.0,0.,20.0,40.0,60.0,80.0,100.0/)
    return(info)
  end if

  if (varName .eq. "PSNSUN_TO_CPOOL") then
    info@flux=True
    info@longName="GPP from Sunlit Canopy"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "PSNSHADE_TO_CPOOL") then
    info@flux=True
    info@longName="GPP from Shaded Canopy"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "NPP") then
    info@flux=True
    info@longName="net primary production"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.50, -1.2, -0.9, -0.6, -0.3, 0., 0.3, 0.6, 0.9, 1.2, 1.5/)
    return(info)
  end if

  if (varName .eq. "NPP_NUPTAKE") then
    info@flux=True
    info@longName="total carbon used by N uptake in FUN"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.50, -1.2, -0.9, -0.6, -0.3, 0., 0.3, 0.6, 0.9, 1.2, 1.5/)
    return(info)
  end if

  if (varName .eq. "NUPTAKE_NPP_FRACTION") then
    info@flux=True
    info@longName="frac of NPP used in N uptake"
    info@nativeUnits = "unitless"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "unitless"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "NA"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.1,0.2,0.3,0.5,0.6,0.7,0.8,0.9/)
    info@cn_LevelsDiff             = (/-.5,-.4,-.3,-.2,-.1,0.,.1,.2,.3,.4,.5/)
    return(info)
  end if

  if (varName .eq. "NUPTAKE_FRACTION") then
    info@flux=True
    info@longName="NPP_NUPTAKE/(NPP_NUPTAKE+NPP)"
    info@nativeUnits = "unitless"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "unitless"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "NA"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "unitless"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.1,0.2,0.3,0.5,0.6,0.7,0.8,0.9/)
    info@cn_LevelsDiff             = (/-.5,-.4,-.3,-.2,-.1,0.,.1,.2,.3,.4,.5/)
    return(info)
  end if

  if (varName .eq. "NPP_NFIX") then
    info@flux=True
    info@longName="Symbiotic BNF uptake used C"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.50, -1.2, -0.9, -0.6, -0.3, 0., 0.3, 0.6, 0.9, 1.2, 1.5/)
    return(info)
  end if

  if (varName .eq. "NPP_NACTIVE") then
    info@flux=True
    info@longName="Mycorrhizal N uptake used C"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.50, -1.2, -0.9, -0.6, -0.3, 0., 0.3, 0.6, 0.9, 1.2, 1.5/)
    return(info)
  end if

  if (varName .eq. "NPP_NRETRANS") then
    info@flux=True
    info@longName="retranslocated N uptake flux"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.50, -1.2, -0.9, -0.6, -0.3, 0., 0.3, 0.6, 0.9, 1.2, 1.5/)
    return(info)
  end if

  if (varName .eq. "AGNPP") then
    info@flux=True
    info@longName="above ground net primary production"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2., 2.5 /)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "BGNPP") then
    info@flux=True
    info@longName="below ground net primary production"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2., 2.5 /)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "CANNSUM_NPP") then
    info@flux=True
    info@longName="annual sum of column-level NPP"
    info@nativeUnits = "gC/m^2/y"
    ; -- global Total
    info@globalTotal__units        = "PgC/y"
    info@globalTotal__SF           = grams2Pgrams 
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/y"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  1.0 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = "...."
    return(info)
  end if
  
  if (varName .eq. "MR") then
    info@flux=True
    info@longName="maintenance respiration"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.25, 0.5, 1.0, 2.0, 3., 4., 5., 6., 7./)
    info@cn_LevelsDiff             = (/-2.50, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5/)
    return(info)
  end if
  if (varName .eq. "GR") then
    info@flux=True
    info@longName="total growth respiration"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.1, 0.2, 0.3, 0.4, 0.5, 0.75, 1.0, 1.25, 1.5/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  if (varName .eq. "GRAINC") then
    info@flux=True
    info@longName="grain C (does not equal yield)"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.1, 0.2, 0.3, 0.4, 0.5, 0.75, 1.0, 1.25, 1.5/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  if (varName .eq. "GRAINC_TO_FOOD") then
    info@flux=True
    info@longName="grain C to food"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.1, 0.2, 0.3, 0.4, 0.5, 0.75, 1.0, 1.25, 1.5/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  if (varName .eq. "GRAINC_TO_SEED") then
    info@flux=True
    info@longName="grain C to seed"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.1, 0.2, 0.3, 0.4, 0.5, 0.75, 1.0, 1.25, 1.5/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  if (varName .eq. "AR") then
    info@flux=True
    info@longName="autotrophic respiration (MR + GR)"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.25, 0.5, 1.0, 2.0, 3., 4., 5., 6., 7./)
    info@cn_LevelsDiff             = (/-2.50, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5/)
    return(info)
  end if

  if (varName .eq. "LITHR") then
    info@flux=True
    info@longName="litter hetereotrophic respiration"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2./)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "SOILC_HR") then
    info@flux=True
    info@longName="Soil C hetereotrophic respiration"
    info@nativeUnits = "gC/m2s"  
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
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "SOILC_LOSS") then
    info@flux=True
    info@longName="Soil C Loss"
    info@nativeUnits = "gC/m2s"
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
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "SOMHR") then
    info@flux=True
    info@longName="SOM hetereotrophic respiration"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "WOODC_ALLOC") then
    info@flux=True
    info@longName="Wood C Allocation"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "WOODC_LOSS") then
    info@flux=True
    info@longName="Wood C Loss"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "WOOD_HARVESTC") then
    info@flux=True
    info@longName="Wood Harvest C (to prod pools)"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "WOOD_HARVESTN") then
    info@flux=True
    info@longName="Wood Harvest N (to prod pools)"
    info@nativeUnits = "gN/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgN/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gN/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "TOT_WOODPRODC_LOSS") then
    info@flux=True
    info@longName="Total C loss from wood prod pools"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "TOT_WOODPRODN_LOSS") then
    info@flux=True
    info@longName="Total N loss from wood prod pools"
    info@nativeUnits = "gN/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgN/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gN/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "PROD10C_LOSS") then
    info@flux=True
    info@longName="C loss from 10-yr wood prod pool"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "PROD10N_LOSS") then
    info@flux=True
    info@longName="N loss from 10-yr wood prod pool"
    info@nativeUnits = "gN/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgN/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gN/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "PROD100C_LOSS") then
    info@flux=True
    info@longName="C loss from 100-yr wood prod pool"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "PROD100N_LOSS") then
    info@flux=True
    info@longName="N loss from 100-yr wood prod pool"
    info@nativeUnits = "gN/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgN/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gN/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "DWT_PROD10C_GAIN") then
    info@flux=True
    info@longName="LCC-driven addition to 10-yr wood prod pool"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "DWT_PROD10N_GAIN") then
    info@flux=True
    info@longName="LCC-driven addition to 10-yr wood prod pool"
    info@nativeUnits = "gN/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgN/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gN/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "DWT_PROD100C_GAIN") then
    info@flux=True
    info@longName="LCC-driven addition to 100-yr wood prod pool"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "DWT_PROD100N_GAIN") then
    info@flux=True
    info@longName="LCC-driven addition to 100-yr wood prod pool"
    info@nativeUnits = "gN/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgN/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gN/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "DWT_CONV_CFLUX") then
    info@flux=True
    info@longName="conversion C flux (immediate loss to atm)"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0., 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "HR") then
    info@flux=True
    info@longName="total hetereotrophic respiration"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "RR") then
    info@flux=True
    info@longName="root respiration (fine root MR + total root GR)"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "PFT_FIRE_CLOSS") then
    info@flux=True
    info@longName="total pft-level fire C loss"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 4., 8., 10., 15.0, 20.0, 25., 35., 45/)
    info@cn_LevelsDiff             = (/-10., -8.0, -6.0, -4.0, -2.0, 0.0, 2.0, 4.0, 6.0, 8.0, 10/)
    return(info)
  end if
  
  if (varName .eq. "SR") then
    info@flux=True
    info@longName="total soil respiration (HR + root resp)"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.25, 0.5, 1.0, 2.0, 3., 4., 5., 6., 7./)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "ER") then
    info@flux=True
    info@longName="total ecosystem respiration (AR + HR)"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "COL_FIRE_CLOSS") then
    info@flux=True
    info@longName="total column-level fire C loss"
    info@nativeUnits = "gC/m^2/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 10.0, 20.0, 30.0, 40.0, 50., 60., 70., 80./)
    info@cn_LevelsDiff             = (/-10.0, -8.0, -6.0, -4.0, -2.0, 0, 2.0, 4.0, 6.0, 8.0, 10/)
    return(info)
  end if
; --- CARBON STATE VARIABLES -------------------------------------------------------------------
  if (varName .eq. "STORVEGC") then
    info@flux=False
    info@longName="stored vegetation C, excluding cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LEAFC") then
    info@flux=False
    info@longName="leaf carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "KgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "LEAFC_ALLOC") then
    info@flux=True
    info@longName="Leaf C Allocation"     
    info@nativeUnits = "gC/m2s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/m2y" 
    info@globalTotal_Annual__SF    =  grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s" 
    info@globalMean__SF            =  grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Pgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"   
    info@globalMean_Daily__SF      =  grams2Pgrams * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "LEAFC_LOSS") then
    info@flux=True
    info@longName="Leaf C Loss"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/m2y"
    info@globalTotal_Annual__SF    = grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            =  grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Pgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      =  grams2Pgrams * secondsInDay
    ; -- Origin 
    info@model                    = "CN"
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "FINUNDATED") then
    info@flux=False
    info@longName="Fractional inundated of veg col"
    info@nativeUnits = "unitless"
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
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.1,0.2,0.3,0.5,0.6,0.7,0.8,0.9/)
    info@cn_LevelsDiff             = (/-.5,-.4,-.3,-.2,-.1,0.,.1,.2,.3,.4,.5/)
    return(info)
  end if

  if (varName .eq. "FCH4") then
    info@flux=True
    info@longName="Gridcell surface CH4 flux"     
    info@nativeUnits = "kgC/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y" 
    info@globalTotal_Annual__SF    =  kgrams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  kgrams2grams * secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"   
    info@globalMean_Daily__SF      =  kgrams2grams * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "FCH4TOCO2") then
    info@flux=True
    info@longName="Gridcell oxidation of CH4 to CO2"     
    info@nativeUnits = "gC/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y" 
    info@globalTotal_Annual__SF    =  grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"   
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "FCH4_DFSAT") then
    info@flux=True
    info@longName="CH4 additional flux"     
    info@nativeUnits = "kgC/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y" 
    info@globalTotal_Annual__SF    =  kgrams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  kgrams2grams * secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"   
    info@globalMean_Daily__SF      =  kgrams2grams * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CH4PROD") then
    info@flux=True
    info@longName="Gridcell total CH4 production"     
    info@nativeUnits = "gC/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y" 
    info@globalTotal_Annual__SF    =  grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"   
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CH4_SURF_AERE_SAT") then
    info@flux=True
    info@longName="aerenchyma sfc CH4 flx-inundated area"    
    info@nativeUnits = "mol/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Tmol/y" 
    info@globalTotal_Annual__SF    =  mols2Tmols * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "mol/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "mol/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mol/m^2/d"   
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CH4_SURF_AERE_UNSAT") then
    info@flux=True
    info@longName="aerenchyma sfc CH4 flx-non-inundated area"    
    info@nativeUnits = "mol/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Tmol/y" 
    info@globalTotal_Annual__SF    =  mols2Tmols * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "mol/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "mol/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mol/m^2/d"   
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CH4_SURF_DIFF_SAT") then
    info@flux=True
    info@longName="diffusive sfc CH4 flx-inundated/lake area"    
    info@nativeUnits = "mol/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Tmol/y" 
    info@globalTotal_Annual__SF    =  mols2Tmols * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "mol/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "mol/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mol/m^2/d"   
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CH4_SURF_DIFF_UNSAT") then
    info@flux=True
    info@longName="diffusive sfc CH4 flx-non-inundated area"    
    info@nativeUnits = "mol/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Tmol/y" 
    info@globalTotal_Annual__SF    =  mols2Tmols * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "mol/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "mol/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mol/m^2/d"   
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CH4_SURF_EBUL_SAT") then
    info@flux=True
    info@longName="ebullition sfc CH4 flx-inundated/lake area"    
    info@nativeUnits = "mol/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Tmol/y" 
    info@globalTotal_Annual__SF    =  mols2Tmols * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "mol/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "mol/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mol/m^2/d"   
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CH4_SURF_EBUL_UNSAT") then
    info@flux=True
    info@longName="ebullition sfc CH4 flx-non-inundated area"    
    info@nativeUnits = "mol/m^2/s" 
    ; -- global Total
    info@globalTotal__units        = "NA" 
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Tmol/y" 
    info@globalTotal_Annual__SF    =  mols2Tmols * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "mol/m^2/s" 
    info@globalMean__SF            =  1.0
    info@globalMean_Annual__units  = "mol/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mol/m^2/d"   
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "SOILC") then
    info@flux=False
    info@longName="soil organic matter C (fast pool)"
    info@nativeUnits = "gC/m2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "WOODC") then
    info@flux=False
    info@longName="Wood C"
    info@nativeUnits = "gC/m2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SOIL1C") then
    info@flux=False
    info@longName="soil organic matter C (fast pool)"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
 
  if (varName .eq. "SOIL2C") then
    info@flux=False
    info@longName="soil organic matter C (medium pool)"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SOIL3C") then
    info@flux=False
    info@longName="Soil organic matter C (slow pool)"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "SOIL4C") then
    info@flux=False
    info@longName="Soil organic matter C (slowest pool)"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if
  if (varName .eq. "PFT_CTRUNC") then
    info@flux=False
    info@longName="pft-level sink for C truncation"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "COL_CTRUNC") then
    info@flux=False
    info@longName="column-level sink for C truncation" 
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  
  if (varName .eq. "LITR1C") then
    info@flux=False
    info@longName="litter labile C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LITR2C") then
    info@flux=False
    info@longName="litter cellulose C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LITR3C") then
    info@flux=False
    info@longName="litter lignin C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "TOTPFTC") then
    info@flux=False
    info@longName="total PFT-level C, including cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "FROOTC") then
    info@flux=False
    info@longName="fine root carbon"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.075, 0.15, 0.225, 0.3, 0.375, 0.45, 0.525, 0.6/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "FROOTC_ALLOC") then
    info@flux=True
    info@longName="Fine root C allocation"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/m2y"
    info@globalTotal_Annual__SF    = grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Kgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      = grams2Kgrams * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.075, 0.15, 0.225, 0.3, 0.375, 0.45, 0.525, 0.6/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "FROOTC_LOSS") then
    info@flux=True
    info@longName="Fine root C Loss"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/m2y"
    info@globalTotal_Annual__SF    = grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Kgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      = grams2Kgrams * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.075, 0.15, 0.225, 0.3, 0.375, 0.45, 0.525, 0.6/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "WOODC_ALLOC") then
    info@flux=True
    info@longName="Wood C Allocation"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/m2y"
    info@globalTotal_Annual__SF    = grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Kgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      = grams2Kgrams * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.075, 0.15, 0.225, 0.3, 0.375, 0.45, 0.525, 0.6/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "WOODC_LOSS") then
    info@flux=True
    info@longName="Wood C Loss"     
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/m2y"
    info@globalTotal_Annual__SF    = grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Kgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      = grams2Kgrams * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.075, 0.15, 0.225, 0.3, 0.375, 0.45, 0.525, 0.6/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0., 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "WOODC") then
    info@flux=False
    info@longName="Live+Dead Stem C"
    info@nativeUnits = "gC/m2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kgC/m2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if
  
  if (varName .eq. "LIVESTEMC") then
    info@flux=False
    info@longName="live stem C"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if
  
  if (varName .eq. "DEADSTEMC") then
    info@flux=False
    info@longName="dead stem carbon"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 2., 4., 8., 10.0, 15.0, 20., 25., 35/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  if (varName .eq. "DISPVEGC") then
    info@flux=False
    info@longName="displayed veg carbon, excluding storage and cpool"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "LIVECROOTC") then
    info@flux=False
    info@longName="live coarse root carbon"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if
  
  if (varName .eq. "DEADCROOTC") then
    info@flux=False
    info@longName="dead coarse root carbon"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 2., 4., 8., 10.0, 15.0, 20., 25., 35/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "CPOOL") then
    info@flux=False
    info@longName="temporary photosynthate C pool"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0, -0.875, -0.75, -0.625, -0.5, -0.375, -0.25, -0.125, 0/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if
  
  if (varName .eq. "XSMRPOOL") then
    info@flux=False
    info@longName="Temporary Photosynthate C Pool"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0, -0.875, -0.75, -0.625, -0.5, -0.375, -0.25, -0.125, 0/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if
  
  if (varName .eq. "TOTVEGC") then
    info@flux=False
    info@longName="total vegetation C, excluding cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "KgC/m^2"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 4., 8., 10., 15.0, 20.0, 25., 35., 45/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "CWDC_LOSS") then
    info@flux=True
    info@longName="Coarse Woody Debris C Loss"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            = grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Kgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      = grams2Kgrams * secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 2., 3., 4., 5.0, 6.0, 7., 8., 9/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "CWDC_HR") then
    info@flux=True
    info@longName="Coarse Woody Debris C Hetereotrophic respiration"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            = grams2Kgrams 
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Kgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      = grams2Kgrams * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 2., 3., 4., 5.0, 6.0, 7., 8., 9/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "CWDC") then
    info@flux=False
    info@longName="coarse woody debris carbon"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 2., 3., 4., 5.0, 6.0, 7., 8., 9/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "TOTLITC") then
    info@flux=False
    info@longName="total litter carbon"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.10, .2, .3, .4, .50, .60, .7, .8, .9/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "TOTLITC_1m") then
    info@flux=False
    info@longName="total litter carbon to 1m depth"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.10, .2, .3, .4, .50, .60, .7, .8, .9/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "LITTERC") then
    info@flux=False
    info@longName="Total Litter C"
    info@nativeUnits = "gC/m2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.10, .2, .3, .4, .50, .60, .7, .8, .9/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

if (varName .eq. "LITTERC_HR") then
    info@flux=True
    info@longName="Litter Hetereotrophic Respiration"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/m2y"
    info@globalTotal_Annual__SF    = secondsInYear * grams2Pgrams
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            =  grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Kgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      =  grams2Kgrams * secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2./)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "LITTERC_LOSS") then
    info@flux=True
    info@longName="Litter C Loss"
    info@nativeUnits = "gC/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/m2y"
    info@globalTotal_Annual__SF    =  grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            =  grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     =  grams2Kgrams * secondsInYear
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      =  grams2Kgrams * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.10, .2, .3, .4, .50, .60, .7, .8, .9/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if
  
  if (varName .eq. "TOTSOMC") then
    info@flux=False
    info@longName="total SOM carbon"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 2., 3., 4., 5.0, 6.0, 7., 8., 9/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "TOTSOMC_1m") then
    info@flux=False
    info@longName="total SOM carbon to 1 meter depth"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 2., 3., 4., 5.0, 6.0, 7., 8., 9/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "TOTECOSYSC") then
    info@flux=False
    info@longName="total ecosystem C, incl veg but excl cpool"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 4., 8., 10., 15.0, 25.0, 35., 45., 55/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "TOTCOLC") then
    info@flux=False
    info@longName="total ecosystem C, incl veg and cpool"
    info@nativeUnits = "gC/m^2"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 4., 8., 10., 15.0, 25.0, 35., 45., 55/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "TOTCOLC") then
    info@flux=False
    info@longName="total column C, incl veg and cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgC"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  
  if (varName .eq. "FPG") then
    info@flux=False
    info@longName="fraction of potential GPP"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "proportion"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if
  
  if (varName .eq. "FPI") then
    info@flux=False
    info@longName="fraction of potential immobilization"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "proportion"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if
  
; --- NITROGEN FLUX + STATE VARIABLES -------------------------------------------------------------------
  
  if (varName .eq. "PFT_FIRE_NLOSS") then
    info@flux=True
    info@longName="total pft-level fire N loss"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 0.10, 0.15, 0.20, 0.25, 0.3, 0.35, 0.40, 0.45/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "NDEP_TO_SMINN") then
    info@flux=True
    info@longName="nitrogen deposition"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "FERT") then
    info@flux=True
    info@longName="fertilizer added"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "FERT_TO_SMINN") then
    info@flux=True
    info@longName="fertilizer to soil mineral N"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "NFERTILIZATION") then
    info@flux=True
    info@longName="fertilizer added"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "RETRANSN_TO_NPOOL") then
    info@flux=True
    info@longName="Retranslocated N to NPool"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "SMINN_TO_NPOOL") then
    info@flux=True
    info@longName="Mineral N to NPool"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "DENIT") then
    info@flux=True
    info@longName="Total Denitrification"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "POTENTIAL_IMMOB") then
    info@flux=True
    info@longName="Potential Immobilization"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "ACTUAL_IMMOB") then
    info@flux=True
    info@longName="Actual Immobilization"  
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "N_MINERAL") then
    info@flux=True
    info@longName="Gross N Mineralization"
    info@nativeUnits = "gN/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m2s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m2y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m2d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "GROSS_NMIN") then   
    info@flux=True
    info@longName="Gross N Mineralization"     
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "NET_NMIN") then     
    info@flux=True
    info@longName="Net N Mineralization"      
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "NDEPLOY") then       
    info@flux=True
    info@longName="Total N Deployed in New Growth"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.01, -0.008, -0.006, -0.004, -0.002, 0, 0.002, 0.004, 0.006, 0.008, 0.01/)
    return(info)
  end if

  if (varName .eq. "COL_FIRE_NLOSS") then
    info@flux=True
    info@longName="total column-level fire N loss"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.01, 0.03, 0.05, 0.08, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.3, -0.1, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.1, 0.3/)
    return(info)
  end if

  if (varName .eq. "NET_NMIN") then
    info@flux=True
    info@longName="net N mineralization"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "NFIX_TO_SMINN") then
    info@flux=True
    info@longName="nitrogen fixation"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.1, 0.3, 0.5, 0.8, 0.10, 0.13, 0.15, 0.18, 0.2/)
    info@cn_LevelsDiff             = (/-.1, -0.08, -0.06, -0.04, -0.02, 0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "GROSS_NMIN") then
    info@flux=True
    info@longName="gross N mineralization"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "NDEPLOY") then
    info@flux=True
    info@longName="total N deployed in new growth"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SUPPLEMENT_TO_SMINN") then
    info@flux=True
    info@longName="supplement to mineral nitrogen"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SMINN_LEACHED") then
    info@flux=True
    info@longName="Nitrogen Leached"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SMIN_NO3_LEACHED") then
    info@flux=True
    info@longName="Soil NO3 pool loss to leaching"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SMIN_NO3_RUNOFF") then
    info@flux=True
    info@longName="Soil NO3 pool loss to runoff"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "NACTIVE") then
    info@flux=True
    info@longName="Mycorrhizal N uptake flux"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "NAM") then
    info@flux=True
    info@longName="AM-associated N uptake flux"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "NECM") then
    info@flux=True
    info@longName="ECM-associated N uptake flux"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "NFIX") then
    info@flux=True
    info@longName="Symbiotic BNF uptake flux"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "NRETRANS") then
    info@flux=True
    info@longName="Retranslocated N uptake flux"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "FFIX_TO_SMINN") then
    info@flux=True
    info@longName="free living N fixation to soil mineral N"
    info@nativeUnits = "gN/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999. 
    info@globalTotal_Annual__units = "TgN/y"
    info@globalTotal_Annual__SF    = grams2Tgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gN/m^2/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "gN/m^2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "gN/m^2/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model                    = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "DISPVEGN") then
    info@flux=False
    info@longName="displayed vegetation nitrogen"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "COL_NTRUNC") then
    info@flux=False
    info@longName="column-level sink for N truncation"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "PFT_NTRUNC") then
    info@flux=False
    info@longName="pft-level sink for N truncation"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "DEADCROOTN") then
    info@flux=False
    info@longName="dead coarse root N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "FROOTN") then
    info@flux=False
    info@longName="fine root nitrogen"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "CWDN") then
    info@flux=False
    info@longName="coarse woody debris N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "DEADSTEMN") then
    info@flux=False
    info@longName="dead stem N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "TOTECOSYSN") then
    info@flux=False
    info@longName="total ecosystem N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "TOTSOMN") then
    info@flux=False
    info@longName="total soil organic matter N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "TOTSOMN_1m") then
    info@flux=False
    info@longName="total soil organic matter N to 1m depth"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "TOTLITN") then
    info@flux=False
    info@longName="total litter N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "TOTLITN_1m") then
    info@flux=False
    info@longName="total litter N to 1m depth"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "TOTVEGN") then
    info@flux=False
    info@longName="total vegetation N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgN"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "TOTVEGCN") then
    info@flux=False
    info@longName="total vegetation C/N"
    info@nativeUnits = "gC/gN"
    ; -- global Total
    info@globalTotal__units        = "gC/gN"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/gN"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "TOTPFTN") then
    info@flux=False
    info@longName="total PFT-level N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SOIL1N") then
    info@flux=False
    info@longName="soil organic matter N (fast pool)"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "SOIL2N") then
    info@flux=False
    info@longName="soil organic matter N (medium pool)"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "SOIL3N") then
    info@flux=False
    info@longName="soil organic matter N (slow pool)"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "SOIL4N") then
    info@flux=False
    info@longName="Soil organic matter N (slowest pool)"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.50, -1.2, -0.9, -0.6, -0.3, 0., 0.3, 0.6, 0.9, 1.2, 1.5/)
    return(info)
  end if

  if (varName .eq. "SoilAlpha") then
    info@flux=False
    info@longName="Soil Specific Humidity Factor"
    info@nativeUnits = "unitless [0-1]"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless [0-1]"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9/)
    info@cn_LevelsDiff             = (/-0.4, -0.3, -0.2, -0.1, 0.,0.1,0.2,0.3,0.4/)
    return(info)
  end if

  if (varName .eq. "WA") then
    info@flux=False
    info@longName="water in the unconfined aquifer"
    info@nativeUnits = "mm"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0., 3700.0, 4000., 4300., 4600., 4900., 5200., 5500., 5800./)
    info@cn_LevelsDiff             = (/-2500., -2000., -1500., -1000., -500., 0., 500., 1000., 1500., 2000., 2500./)
    return(info)
  end if

  if (varName .eq. "ZWT") then
    info@flux=False
    info@longName="water table depth"
    info@nativeUnits = "m"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/2., 2.5, 3., 3.5, 4., 6., 8., 16., 32./)
    info@cn_LevelsDiff             = (/-1.50, -1.2, -0.9, -0.6, -0.3, 0., 0.3, 0.6, 0.9, 1.2, 1.5/)
    return(info)
  end if

  if (varName .eq. "TWS") then
    info@flux=False
    info@longName="total water storage"
    info@nativeUnits = "mm"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/2.e3, 2.5e3, 3.e3, 3.5e3, 4.e3, 6.e3, 8.e3, 16.e3, 32.e3/)
    info@cn_LevelsDiff             = (/-1.50e3, -1.2e3, -0.9e3, -0.6e3, -0.3e3, 0.e3, 0.3e3, 0.6e3, 0.9e3, 1.2e3, 1.5e3/)
    return(info)
  end if

  if (varName .eq. "VOLR") then
    info@flux=False
    info@longName="river channel total water storage"
    info@nativeUnits = "m3"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m3"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/2.e3, 2.5e3, 3.e3, 3.5e3, 4.e3, 6.e3, 8.e3, 16.e3, 32.e3/)
    info@cn_LevelsDiff             = (/-1.50e3, -1.2e3, -0.9e3, -0.6e3, -0.3e3, 0.e3, 0.3e3, 0.6e3, 0.9e3, 1.2e3, 1.5e3/)
    return(info)
  end if

  if (varName .eq. "QCHARGE") then
    info@flux=False
    info@longName="aquifer recharge rate"
    info@nativeUnits = "mm/s"
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
    info@model                     = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-3., 0., 1., 2., 3., 4., 5., 6., 7./)
    info@cn_LevelsDiff             = (/-5.0, -4.0, -3.0, -2.0, -1.0, 0., 1.0, 2.0, 3.0, 4.0, 5.0/)
    return(info)
  end if

  if (varName .eq. "FCOV") then
    info@flux=False
    info@longName="fractional area with water table at surface"
    info@nativeUnits = "unitless [0-1]"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "unitless [0-1]"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model                     = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0., 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8/)
    info@cn_LevelsDiff             = (/-0.25, -0.2, -0.15, -0.1, -0.05, 0., 0.05, 0.1, 0.15, 0.2, 0.25/)
    return(info)
  end if

  if (varName .eq. "LEAFN") then
    info@flux=False
    info@longName="leaf nitrogen"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "PgN"
    info@globalTotal__SF           = grams2Pgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LEAFCN") then
    info@flux=False
    info@longName="leaf carbon/nitrogen"
    info@nativeUnits = "gC/gN"
    ; -- global Total
    info@globalTotal__units        = "gC/gN"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gC/gN"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "TOTCOLN") then
    info@flux=False
    info@longName="total column-level N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if
  
  if (varName .eq. "SMINN") then
    info@flux=False
    info@longName="soil mineral N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mgN/m^2"
    info@globalMean__SF            = 1000.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/1.0, 2., 3., 4., 5.0, 6.0, 7., 8., 9/)
    info@cn_LevelsDiff             = (/-1., -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "LITR1N") then
    info@flux=False
    info@longName="litter labile N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LITR2N") then
    info@flux=False
    info@longName="litter cellulose N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LITR3N") then
    info@flux=False
    info@longName="litter lignin N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LIVECROOTN") then
    info@flux=False
    info@longName="live coarse root N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "STORVEGN") then
    info@flux=False
    info@longName="stored vegetation N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "LIVESTEMN") then
    info@flux=False
    info@longName="live stem N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "RETRANSN") then
    info@flux=False
    info@longName="plant pool of retranslocated N"
    info@nativeUnits = "gN/m^2"
    ; -- global Total
    info@globalTotal__units        = "TgN"
    info@globalTotal__SF           = grams2Tgrams
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "gN/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 1.0, 1.5, 2., 2.5, 3., 3.5/)
    info@cn_LevelsDiff             = (/-1.50, -1.2, -0.9, -0.6, -0.3, 0., 0.3, 0.6, 0.9, 1.2, 1.5/)
    return(info)
  end if

  if (varName .eq. "SNOWDP") then
    info@flux=False
    info@longName="snow height"
    info@nativeUnits = "m"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.1,0.2,0.3,0.4,0.5,0.6,0.8,1.0/)
    info@cn_LevelsDiff             = (/-0.5,-0.4,-0.3, -0.2,-0.1, 0., 0.1, 0.2, 0.3,0.4,0.5/)
    info@cn_LevelsDiffObs          = (/-0.8,-0.5, -0.3, -0.2, -0.1,  0., 0.1, 0.2, 0.3, 0.5, 0.8/)
    return(info)
  end if

  if (varName .eq. "SNOWAGE") then
    info@flux=False
    info@longName="snow age"
    info@nativeUnits = "unitless"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8/)
    info@cn_LevelsDiff             = (/-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5./)
    return(info)
  end if

  if (varName .eq. "TSA") then
    info@flux=False
    info@longName="2m air temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-5.0,-4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.,5./)
    info@cn_LevelsDiffObs          = (/-16,-12,-8,-4.,-2,0.,2,4,8.,12,16/)
    return(info)
  end if

  if (varName .eq. "TSA2M") then
    info@flux=False
    info@longName="2m Air Temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "TV") then
    info@flux=False
    info@longName="vegetation temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             =  (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "TVEG") then
    info@flux=False
    info@longName="Vegetation Temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "TSOI") then
    info@flux=False
    info@longName="soil temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level1                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level2                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level3                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level4                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level5                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level6                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level7                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level8                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level9                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level0Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level1Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level2Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level3Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level4Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level5Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level6Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level7Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level8Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level9Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "TSOIL") then
    info@flux=False
    info@longName="soil temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level1                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level2                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level3                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level4                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level5                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level6                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level7                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level8                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level9                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_Level0Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level1Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level2Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level3Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level4Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level5Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level6Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level7Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level8Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level9Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "DEGREE_DAYS") then
    info@flux=False
    info@longName="Accumulated degree days"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-55, -45, -35, -25, -15, -10, -5, -3, -1/)
    info@cn_LevelsDiff             =  (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "NETRAD") then
    info@flux=True
    info@longName="Net radiation"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "CPL_ENERGY_BAL") then
    info@flux=True
    info@longName="Coupler Energy Balance (Land Area)"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = True
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "FSA") then
    info@flux=True
    info@longName="absorbed solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "SABV") then
    info@flux=True
    info@longName="solar rad absorbed by vegetation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if


  if (varName .eq. "SOLAR_AB") then
    info@flux=True
    info@longName="Total Absorbed Solar Radiation"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CLM"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 25, 50, 75, 100, 125, 150, 175, 200/)
    info@cn_LevelsDiff             = (/-25.0, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25/)
    return(info)
  end if

  if (varName .eq. "SOLAR_ABV") then
    info@flux=True
    info@longName="Solar Rad Absorbed by Vegetation"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 25, 50, 75, 100, 125, 150, 175, 200/)
    info@cn_LevelsDiff             = (/-25.0, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25/)
    return(info)
  end if

  if (varName .eq. "SABG") then
    info@flux=True
    info@longName="solar rad absorbed by ground"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "SOLAR_ABG") then
    info@flux=True
    info@longName="Solar Radiation Absorbed by Ground"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 31.25, 62.5, 93.75, 125, 156.25, 187.5, 218.75, 250/)
    info@cn_LevelsDiff             = (/-10.0, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10/)
    return(info)
  end if


  if (varName .eq. "REFLECT") then
    info@flux=True
    info@longName="Total Reflected Solar Radiation"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 15, 30, 45, 60, 75, 90, 105, 120/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "FSR") then
    info@flux=True
    info@longName="reflected solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "NETIR") then
    info@flux=True
    info@longName="Net Infrared (longwave) Radiation"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 17.5, 35, 52.5, 70, 87.5, 105, 122.5, 140/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0.0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "FIRA") then
    info@flux=True
    info@longName="net infrared (longwave) radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,30.,60.,90.,120.,150.,180.,210.,240./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "IRUP") then
    info@flux=True
    info@longName="Upward Infrared Radiation"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/100, 147, 195, 242, 290, 337, 385, 432, 480/)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "FIRE") then
    info@flux=True
    info@longName="emitted infrared (longwave) radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/100.,160.,220.,280.,340.,400.,460.,520.,580./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FCTR") then
    info@flux=True
    info@longName="canopy transpiration"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 15, 30, 45, 60, 75, 90, 105, 120/)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "ET") then
    info@flux=True
    info@longName="Evapotranspiration"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,6.,12.,18.,24.,30.,36.,42.,48./)
    return(info)
  end if

  if (varName .eq. "FCEV") then
    info@flux=True
    info@longName="canopy evaporation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,10.,20.,30.,40.,50.,60.,70.,80./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FGEV") then
    info@flux=True
    info@longName="ground evaporation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "SENSIBLE") then
    info@flux=True
    info@longName="Sensible Heat Flux"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-40.,-20.,0.,20.,40.,60.,80.,100.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSH") then
    info@flux=True
    info@longName="sensible heat"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-40.,-20.,0.,20.,40.,60.,80.,100.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSH_TO_COUPLER") then
    info@flux=True
    info@longName="sensible heat sent to coupler"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-40.,-20.,0.,20.,40.,60.,80.,100.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSH_PRECIP_CONVERSION") then
    info@flux=True
    info@longName="SHF from conv of rain/snow atm forcing"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-40.,-20.,0.,20.,40.,60.,80.,100.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSH_RUNOFF_ICE_TO_LIQ") then
    info@flux=True
    info@longName="SHF from conv of ice runoff to liquid"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-40.,-20.,0.,20.,40.,60.,80.,100.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "LATENT") then
    info@flux=True
    info@longName="Latent Heat Flux"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-40.,-20.,0.,20.,40.,60.,80.,100.,120./)
    return(info)
  end if

  if (varName .eq. "RNET-SENS-LATENT") then
    info@flux=True
    info@longName="Net:fsa-fira-fctr-fcev-fgev-fsh"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-40.,-20.,0.,20.,40.,60.,80.,100.,120./)
    return(info)
  end if

  if (varName .eq. "SENSIBLE_VEG") then
    info@flux=True
    info@longName="Sensible Heat Flux from Vegetation"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSH_V") then
    info@flux=True
    info@longName="sensible heat from vegetation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "SENSIBLE_GND") then
    info@flux=True
    info@longName="Sensible Heat Flux from Ground"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSH_G") then
    info@flux=True
    info@longName="sensible heat from ground"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FGR") then
    info@flux=True
    info@longName="heat flux into snow/soil (includes snow melt)"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-24.,-18.,-12.,-6.,0.,6.,12.,18.,24./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "GROUND") then
    info@flux=True
    info@longName="heat flux into soil"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-24.,-18.,-12.,-6.,0.,6.,12.,18.,24./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSM") then
    info@flux=True
    info@longName="snow melt heat flux"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,2.,4.,6.,8.,10.,12.,14.,16./) 
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "TAUX") then
    info@flux=True
    info@longName="zonal surface stress"
    info@nativeUnits = "kg/m/s^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m/s^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0,-0.4,-0.2,-.1,0.,.1,0.2,0.4,1.0/)
    info@cn_LevelsDiff             = (/-1.,-.8,-.4,-.2,-.1,0.,.1,.2,.4,.8,1./)
    return(info)
  end if

  if (varName .eq. "TAUY") then
    info@flux=True
    info@longName="meridional surface stress"
    info@nativeUnits = "kg/m/s^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m/s^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0,-0.4,-0.2,-.1,0.,.1,0.2,0.4,1.0/)
    info@cn_LevelsDiff             = (/-1.,-.8,-.4,-.2,-.1,0.,.1,.2,.4,.8,1./)
    return(info)
  end if

  if (varName .eq. "LAI") then
    info@flux=False
    info@longName="Total one-sided leaf area index"
    info@nativeUnits = "m2/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m2/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             = (/-.1,-.08,-.06,-.04,-.02,0.,.02,.04,.06,.08,.1/)
    return(info)
  end if

  if (varName .eq. "TLAI") then
    info@flux=False
    info@longName="total one-sided leaf area index"
    info@nativeUnits = "m2/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m2/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             = (/-.1,-.08,-.06,-.04,-.02,0.,.02,.04,.06,.08,.1/)
    return(info)
  end if

  if (varName .eq. "TSAI") then
    info@flux=False
    info@longName="total one-sided stem area index"
    info@nativeUnits = "m2/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m2/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.15,0.3,0.45,0.6,0.75,0.9,1.05,1.2/)
    info@cn_LevelsDiff             = (/-.1,-.08,-.06,-.04,-.02,0.,.02,.04,.06,.08,.1/)
    return(info)
  end if

  if (varName .eq. "ELAI") then
    info@flux=False
    info@longName="exposed one-sided leaf area index"
    info@nativeUnits = "m2/m2"
    ; -- global Total
    info@globalTotal__units        = "m2/m2"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m2/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./) 
    info@cn_LevelsDiff             = (/-2.,-1.,-.5,-.25,-.1,0.,.1,.25,.5,1.,2./)
    return(info)
  end if

  if (varName .eq. "LAISUN") then
    info@flux=False
    info@longName="Sunlit Projected Leaf Area Index"        
    info@nativeUnits = "m2/m2"
    ; -- global Total
    info@globalTotal__units        = "m^2/m^2"
    info@globalTotal__SF           = 1.0
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
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.1,.2,.3,.4,.5,.6,.7,.8/)
    info@cn_LevelsDiff             = (/-.1,-.08,-.06,-.04,-.02,0.,.02,.04,.06,.08,.1/)
    return(info)
  end if

  if (varName .eq. "LAISHA") then
    info@flux=False
    info@longName="Shaded Projected Leaf Area Index"
    info@nativeUnits = "m^2/m^2"
    ; -- global Total
    info@globalTotal__units        = "m^2/m^2"
    info@globalTotal__SF           = 1.0
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
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 0.75, 1.5, 2.25, 3, 3.75, 4.5, 5.25, 6/)
    info@cn_LevelsDiff             = (/-.1,-.08,-.06,-.04,-.02,0.,.02,.04,.06,.08,.1/)
    return(info)
  end if

  if (varName .eq. "ESAI") then
    info@flux=False
    info@longName="exposed one-sided stem area index"
    info@nativeUnits = "m2/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m2/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.15,0.3,0.45,0.6,0.75,0.9,1.05,1.2/) 
    info@cn_LevelsDiff             = (/-2.,-1.,-.5,-.25,-.1,0.,.1,.25,.5,1.,2./)
    return(info)
  end if

  if (varName .eq. "HTOP") then
    info@flux=False
    info@longName="canopy top height"
    info@nativeUnits = "m"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CLM"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,5.0,10.0,15.0,20.0,25.0,30.0,35.0,40.0/)
    info@cn_LevelsDiff             = (/-2.,-1.,-.5,-.25,-.1,0.,.1,.25,.5,1.,2./)
    return(info)
  end if

  if (varName .eq. "RSSUN") then
    info@flux=False
    info@longName="Sunlit leaf stomatal resistance"
    info@nativeUnits = "s/m"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "s/m"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.e2,5.e2,1.e3,5.e3,7.5e3,1.e4,1.5e4,2.e4/) 
    info@cn_LevelsDiff             = (/-1e4,-5e3,-1e3,-500.,-100.,0.,100.,500.,1e3,5e3,1e4/)
    return(info)
  end if

  if (varName .eq. "RSSHA") then
    info@flux=False
    info@longName="shaded leaf stomatal resistance"
    info@nativeUnits = "s/m"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "s/m"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.e2,5.e2,1.e3,5.e3,7.5e3,1.e4,1.5e4,2.e4/) 
    info@cn_LevelsDiff             = (/-1e4,-5e3,-1e3,-500.,-100.,0.,100.,500.,1e3,5e3,1e4/)
    return(info)
  end if

  if (varName .eq. "BTRAN") then
    info@flux=False
    info@longName="transpiration beta factor"
    info@nativeUnits = "unitless"
    ; -- global Total
    info@globalTotal__units        = "unitless"
    info@globalTotal__SF           = 1.0
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
    info@model		           = "CLM" 
    info@derivedVariable           = True
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.15,0.3,0.45,0.6,0.75,0.9,1.05,1.2/)
    info@cn_LevelsDiff             = (/-.5,-.4,-.3,-.2,-.1,0.,.1,.2,.3,.4,.5/)
    return(info)
  end if

  if (varName .eq. "BTRAN2") then
    info@flux=False
    info@longName="root zone soil moisture factor"
    info@nativeUnits = "unitless"
    ; -- global Total
    info@globalTotal__units        = "unitless"
    info@globalTotal__SF           = 1.0
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
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.15,0.3,0.45,0.6,0.75,0.9,1.05,1.2/)
    info@cn_LevelsDiff             = (/-.5,-.4,-.3,-.2,-.1,0.,.1,.2,.3,.4,.5/)
    return(info)
  end if

  if (varName .eq. "BTRANMN") then
    info@flux=False
    info@longName="daily minimum of transpiration beta factor"
    info@nativeUnits = "unitless"
    ; -- global Total
    info@globalTotal__units        = "unitless"
    info@globalTotal__SF           = 1.0
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
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.15,0.3,0.45,0.6,0.75,0.9,1.05,1.2/)
    info@cn_LevelsDiff             = (/-.5,-.4,-.3,-.2,-.1,0.,.1,.2,.3,.4,.5/)
    return(info)
  end if

  if (varName .eq. "SNOW_DEPTH") then
    info@flux=False
    info@longName="Snow depth"
    info@nativeUnits = "mm"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,900./)
    info@cn_LevelsDiff             = (/-250.,-200.,-150.,-100.,-50.,0.,50.,100.,150.,200.,250./)
    info@cn_LevelsDiffObs          = (/-1.,-.6,-.2,  0., .2, .6, .8, 1.,1.5, 2,2.5/)
    return(info)
  end if

  if (varName .eq. "H2OSNO") then
    info@flux=False
    info@longName="total snow water equiv (SNOWICE + SNOWLIQ)"
    info@nativeUnits = "mm"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,25.,50.,75.,100.,125.,150.,175.,200./)
    info@cn_LevelsDiff             = (/-50.,-40.,-30.,-20.,-10.,0.,10.,20.,30.,40.,50./)
    info@cn_LevelsDiffObs          = (/-50.,0.,50.,100.,150.,200.,250.,300.,350.,400.,450./)
    return(info)
  end if

  if (varName .eq. "H2OSNO_ICE") then
    info@flux=False
    info@longName="total snow water equiv (SNOWICE + SNOWLIQ) over glacier units"
    info@nativeUnits = "mm"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,25.,50.,75.,100.,125.,150.,175.,200./)
    info@cn_LevelsDiff             = (/-50.,-40.,-30.,-20.,-10.,0.,10.,20.,30.,40.,50./)
    info@cn_LevelsDiffObs          = (/-50.,0.,50.,100.,150.,200.,250.,300.,350.,400.,450./)
    return(info)
  end if

  if (varName .eq. "H2OSOI") then
    info@flux= True
    info@longName="volumetric soil water"
    info@nativeUnits = "mm3/mm3"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level1                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level2                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level3                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level4                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level5                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level6                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level7                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level8                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level9                 = (/0.,0.01,0.05,0.1,0.2,0.3,0.4,0.5,0.9/)
    info@cn_Level0Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    info@cn_Level1Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    info@cn_Level2Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    info@cn_Level3Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    info@cn_Level4Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    info@cn_Level5Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    info@cn_Level6Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    info@cn_Level7Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    info@cn_Level8Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    info@cn_Level9Diff             = (/-0.4,-0.2,-0.1,-0.05,-0.01,0.,0.01,0.05,0.1,0.2,0.4/)
    return(info)
  end if

  if (varName .eq. "SOIL_WATER") then
    info@flux= True
    info@longName="Volumetric Soil Water"
    info@nativeUnits = "mm3/mm3"
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
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/0.,1.,2.,5.,8.,11.,14.,17.,20./)
    info@cn_Level1                 = (/0.,1.,2.,5.,9.,13.,17.,21.,25./)
    info@cn_Level2                 = (/0.,5.,10.,15.,20.,25.,30.,35.,40./)
    info@cn_Level3                 = (/0.,10.,20.,30.,40.,50.,60.,70.,80./)
    info@cn_Level4                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_Level5                 = (/0.,25.,50.,75.,100.,125.,150.,175.,200./)
    info@cn_Level6                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_Level7                 = (/0.,75.,150.,225.,300.,375.,450.,525.,600./)
    info@cn_Level8                 = (/0.,110.,220.,330.,440.,550.,660.,770.,880./)
    info@cn_Level9                 = (/0.,140.,280.,420.,560.,700.,840.,980.,1120./)
    info@cn_Level0Diff             = (/-15.,-10.,-5.,-2.,-1.,0.,1.,2.,5.,10.,15./)
    info@cn_Level1Diff             = (/-25.,-15.,-5.,-2.,-1.,0.,1.,2.,5.,15.,25./)
    info@cn_Level2Diff             = (/-35.,-25.,-15.,-5.,-1.,0.,1.,5.,15.,25.,35./)
    info@cn_Level3Diff             = (/-45.,-30.,-15.,-5.,-1.,0.,1.,5.,15.,30.,45./)
    info@cn_Level4Diff             = (/-60.,-40.,-20.,-5.,-1.,0.,1.,5.,20.,40.,60./)
    info@cn_Level5Diff             = (/-90.,-60.,-30.,-10.,-5.,0.,5.,10.,30.,60.,90./)
    info@cn_Level6Diff             = (/-100.,-75.,-50.,-25.,-5.,0.,5.,25.,50.,75.,100./)
    info@cn_Level7Diff             = (/-175.,-125.,-75.,-25.,-5.,0.,5.,25.,75.,125.,175./)
    info@cn_Level8Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    info@cn_Level9Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    return(info)
  end if

  if (varName .eq. "VOL_SOIL_WATER") then 
    info@flux= True
    info@longName="Volumetric Soil Water"
    info@nativeUnits = "mm3/mm3"
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
    info@model                     = "CLM"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/0.,1.,2.,5.,8.,11.,14.,17.,20./)
    info@cn_Level1                 = (/0.,1.,2.,5.,9.,13.,17.,21.,25./)
    info@cn_Level2                 = (/0.,5.,10.,15.,20.,25.,30.,35.,40./)
    info@cn_Level3                 = (/0.,10.,20.,30.,40.,50.,60.,70.,80./)
    info@cn_Level4                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_Level5                 = (/0.,25.,50.,75.,100.,125.,150.,175.,200./)
    info@cn_Level6                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_Level7                 = (/0.,75.,150.,225.,300.,375.,450.,525.,600./)
    info@cn_Level8                 = (/0.,110.,220.,330.,440.,550.,660.,770.,880./)
    info@cn_Level9                 = (/0.,140.,280.,420.,560.,700.,840.,980.,1120./)
    info@cn_Level0Diff             = (/-15.,-10.,-5.,-2.,-1.,0.,1.,2.,5.,10.,15./)
    info@cn_Level1Diff             = (/-25.,-15.,-5.,-2.,-1.,0.,1.,2.,5.,15.,25./)
    info@cn_Level2Diff             = (/-35.,-25.,-15.,-5.,-1.,0.,1.,5.,15.,25.,35./)
    info@cn_Level3Diff             = (/-45.,-30.,-15.,-5.,-1.,0.,1.,5.,15.,30.,45./)
    info@cn_Level4Diff             = (/-60.,-40.,-20.,-5.,-1.,0.,1.,5.,20.,40.,60./)
    info@cn_Level5Diff             = (/-90.,-60.,-30.,-10.,-5.,0.,5.,10.,30.,60.,90./)
    info@cn_Level6Diff             = (/-100.,-75.,-50.,-25.,-5.,0.,5.,25.,50.,75.,100./)
    info@cn_Level7Diff             = (/-175.,-125.,-75.,-25.,-5.,0.,5.,25.,75.,125.,175./)
    info@cn_Level8Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    info@cn_Level9Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    return(info)
  end if

  if (varName .eq. "H2OCAN") then
    info@flux=False
    info@longName="intercepted water"
    info@nativeUnits = "mm"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4/)
    info@cn_LevelsDiff             = (/-.08,-.06,-.04,-.02,-.01,0.,.01,.02,.04,.06,.08/)
    return(info)
  end if

  if (varName .eq. "SNOWLIQ") then
    info@flux=False
    info@longName="snow liquid water"
    info@nativeUnits = "kg/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"	
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m^2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,2.,4.,6.,8.,10.,12.,14.,16./)
    info@cn_LevelsDiff             = (/-10.,-8.,-6.,-4.,-2.,0.,2.,4.,6.,8.,10./)
    return(info)
  end if

  if (varName .eq. "SNOWICE") then
    info@flux=False
    info@longName="snow ice"
    info@nativeUnits = "kg/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"	
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m^2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,900./)
    info@cn_LevelsDiff             = (/-500.,-250.,-100.,-50.,-10.,0.,10.,50.,100.,250.,500./) 
    return(info)
  end if

  if (varName .eq. "SOIL_ICE") then
    info@flux=False
    info@longName="Soil Ice in each soil layer"
    info@nativeUnits = "kg/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/0.,1.,2.,5.,8.,11.,14.,17.,20./)
    info@cn_Level1                 = (/0.,1.,2.,5.,9.,13.,17.,21.,25./)
    info@cn_Level2                 = (/0.,5.,10.,15.,20.,25.,30.,35.,40./)
    info@cn_Level3                 = (/0.,10.,20.,30.,40.,50.,60.,70.,80./)
    info@cn_Level4                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_Level5                 = (/0.,25.,50.,75.,100.,125.,150.,175.,200./)
    info@cn_Level6                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_Level7                 = (/0.,75.,150.,225.,300.,375.,450.,525.,600./)
    info@cn_Level8                 = (/0.,110.,220.,330.,440.,550.,660.,770.,880./)
    info@cn_Level9                 = (/0.,140.,280.,420.,560.,700.,840.,980.,1120./)
    info@cn_Level0Diff             = (/-15.,-10.,-5.,-2.,-1.,0.,1.,2.,5.,10.,15./)
    info@cn_Level1Diff             = (/-25.,-15.,-5.,-2.,-1.,0.,1.,2.,5.,15.,25./)
    info@cn_Level2Diff             = (/-35.,-25.,-15.,-5.,-1.,0.,1.,5.,15.,25.,35./)
    info@cn_Level3Diff             = (/-45.,-30.,-15.,-5.,-1.,0.,1.,5.,15.,30.,45./)
    info@cn_Level4Diff             = (/-60.,-40.,-20.,-5.,-1.,0.,1.,5.,20.,40.,60./)
    info@cn_Level5Diff             = (/-90.,-60.,-30.,-10.,-5.,0.,5.,10.,30.,60.,90./)
    info@cn_Level6Diff             = (/-100.,-75.,-50.,-25.,-5.,0.,5.,25.,50.,75.,100./)
    info@cn_Level7Diff             = (/-175.,-125.,-75.,-25.,-5.,0.,5.,25.,75.,125.,175./)
    info@cn_Level8Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    info@cn_Level9Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    return(info)
  end if

  if (varName .eq. "SOILICE") then
    info@flux=False
    info@longName="soil ice"
    info@nativeUnits = "kg/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"	
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m^2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/0.,1.,2.,5.,8.,11.,14.,17.,20./)
    info@cn_Level1                 = (/0.,1.,2.,5.,9.,13.,17.,21.,25./)
    info@cn_Level2                 = (/0.,5.,10.,15.,20.,25.,30.,35.,40./)
    info@cn_Level3                 = (/0.,10.,20.,30.,40.,50.,60.,70.,80./)
    info@cn_Level4                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_Level5                 = (/0.,25.,50.,75.,100.,125.,150.,175.,200./)
    info@cn_Level6                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_Level7                 = (/0.,75.,150.,225.,300.,375.,450.,525.,600./)
    info@cn_Level8                 = (/0.,110.,220.,330.,440.,550.,660.,770.,880./)
    info@cn_Level9                 = (/0.,140.,280.,420.,560.,700.,840.,980.,1120./)
    info@cn_Level0Diff             = (/-15.,-10.,-5.,-2.,-1.,0.,1.,2.,5.,10.,15./)
    info@cn_Level1Diff             = (/-25.,-15.,-5.,-2.,-1.,0.,1.,2.,5.,15.,25./)
    info@cn_Level2Diff             = (/-35.,-25.,-15.,-5.,-1.,0.,1.,5.,15.,25.,35./)
    info@cn_Level3Diff             = (/-45.,-30.,-15.,-5.,-1.,0.,1.,5.,15.,30.,45./)
    info@cn_Level4Diff             = (/-60.,-40.,-20.,-5.,-1.,0.,1.,5.,20.,40.,60./)
    info@cn_Level5Diff             = (/-90.,-60.,-30.,-10.,-5.,0.,5.,10.,30.,60.,90./)
    info@cn_Level6Diff             = (/-100.,-75.,-50.,-25.,-5.,0.,5.,25.,50.,75.,100./)
    info@cn_Level7Diff             = (/-175.,-125.,-75.,-25.,-5.,0.,5.,25.,75.,125.,175./)
    info@cn_Level8Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    info@cn_Level9Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    return(info)
  end if

  if (varName .eq. "SOILPSI") then
    info@flux=False
    info@longName="Soil Water Potential in Each Soil Layer"
    info@nativeUnits = "MPa"
    ; -- global Total
    info@globalTotal__units        = "NA"	
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "MPa"  
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/0.,1.,2.,5.,8.,11.,14.,17.,20./)
    info@cn_Level1                 = (/0.,1.,2.,5.,9.,13.,17.,21.,25./)
    info@cn_Level2                 = (/0.,5.,10.,15.,20.,25.,30.,35.,40./)
    info@cn_Level3                 = (/0.,10.,20.,30.,40.,50.,60.,70.,80./)
    info@cn_Level4                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_Level5                 = (/0.,25.,50.,75.,100.,125.,150.,175.,200./)
    info@cn_Level6                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_Level7                 = (/0.,75.,150.,225.,300.,375.,450.,525.,600./)
    info@cn_Level8                 = (/0.,110.,220.,330.,440.,550.,660.,770.,880./)
    info@cn_Level9                 = (/0.,140.,280.,420.,560.,700.,840.,980.,1120./)
    info@cn_Level0Diff             = (/-15.,-10.,-5.,-2.,-1.,0.,1.,2.,5.,10.,15./)
    info@cn_Level1Diff             = (/-25.,-15.,-5.,-2.,-1.,0.,1.,2.,5.,15.,25./)
    info@cn_Level2Diff             = (/-35.,-25.,-15.,-5.,-1.,0.,1.,5.,15.,25.,35./)
    info@cn_Level3Diff             = (/-45.,-30.,-15.,-5.,-1.,0.,1.,5.,15.,30.,45./)
    info@cn_Level4Diff             = (/-60.,-40.,-20.,-5.,-1.,0.,1.,5.,20.,40.,60./)
    info@cn_Level5Diff             = (/-90.,-60.,-30.,-10.,-5.,0.,5.,10.,30.,60.,90./)
    info@cn_Level6Diff             = (/-100.,-75.,-50.,-25.,-5.,0.,5.,25.,50.,75.,100./)
    info@cn_Level7Diff             = (/-175.,-125.,-75.,-25.,-5.,0.,5.,25.,75.,125.,175./)
    info@cn_Level8Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    info@cn_Level9Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    return(info)
  end if

  if (varName .eq. "TOTSOILICE") then
    info@flux=False
    info@longName="total soil ice"
    info@nativeUnits = "kg/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"	
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m^2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,900./)
    return(info)
  end if

 if (varName .eq. "TOTAL_SOIL_ICE") then
    info@flux=False
    info@longName="Total soil ice"
    info@nativeUnits = "kg/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m^2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CLM"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,900./)
    return(info)
  end if

  if (varName .eq. "SOIL_LIQUID") then
    info@flux=False
    info@longName="Soil Liquid Water"
    info@nativeUnits = "kg/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/0.,1.,2.,4.,6.,8.,10.,12.,14./)
    info@cn_Level1                 = (/0.,1.,2.,4.,8.,12.,16.,20.,24./)
    info@cn_Level2                 = (/0.,5.,10.,15.,20.,25.,30.,35.,40./)
    info@cn_Level3                 = (/0.,10.,20.,30.,40.,50.,60.,70.,80./)
    info@cn_Level4                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_Level5                 = (/0.,25.,50.,75.,100.,125.,150.,175.,200./)
    info@cn_Level6                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_Level7                 = (/0.,75.,150.,225.,300.,375.,450.,525.,600./)
    info@cn_Level8                 = (/0.,110.,220.,330.,440.,550.,660.,770.,880./)
    info@cn_Level9                 = (/0.,140.,280.,420.,560.,700.,840.,980.,1120./)
    info@cn_Level0Diff             = (/-15.,-10.,-5.,-2.,-1.,0.,1.,2.,5.,10.,15./)
    info@cn_Level1Diff             = (/-25.,-15.,-5.,-2.,-1.,0.,1.,2.,5.,15.,25./)
    info@cn_Level2Diff             = (/-35.,-25.,-15.,-5.,-1.,0.,1.,5.,15.,25.,35./)
    info@cn_Level3Diff             = (/-45.,-30.,-15.,-5.,-1.,0.,1.,5.,15.,30.,45./)
    info@cn_Level4Diff             = (/-60.,-40.,-20.,-5.,-1.,0.,1.,5.,20.,40.,60./)
    info@cn_Level5Diff             = (/-90.,-60.,-30.,-10.,-5.,0.,5.,10.,30.,60.,90./)
    info@cn_Level6Diff             = (/-100.,-75.,-50.,-25.,-5.,0.,5.,25.,50.,75.,100./)
    info@cn_Level7Diff             = (/-175.,-125.,-75.,-25.,-5.,0.,5.,25.,75.,125.,175./)
    info@cn_Level8Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    info@cn_Level9Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    return(info)
  end if

  if (varName .eq. "SOILLIQ") then
    info@flux=False
    info@longName="soil liquid water"
    info@nativeUnits = "kg/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"	
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m^2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/0.,1.,2.,4.,6.,8.,10.,12.,14./)
    info@cn_Level1                 = (/0.,1.,2.,4.,8.,12.,16.,20.,24./)
    info@cn_Level2                 = (/0.,5.,10.,15.,20.,25.,30.,35.,40./)
    info@cn_Level3                 = (/0.,10.,20.,30.,40.,50.,60.,70.,80./)
    info@cn_Level4                 = (/0.,15.,30.,45.,60.,75.,90.,105.,120./)
    info@cn_Level5                 = (/0.,25.,50.,75.,100.,125.,150.,175.,200./)
    info@cn_Level6                 = (/0.,40.,80.,120.,160.,200.,240.,280.,320./)
    info@cn_Level7                 = (/0.,75.,150.,225.,300.,375.,450.,525.,600./)
    info@cn_Level8                 = (/0.,110.,220.,330.,440.,550.,660.,770.,880./)
    info@cn_Level9                 = (/0.,140.,280.,420.,560.,700.,840.,980.,1120./)
    info@cn_Level0Diff             = (/-15.,-10.,-5.,-2.,-1.,0.,1.,2.,5.,10.,15./)
    info@cn_Level1Diff             = (/-25.,-15.,-5.,-2.,-1.,0.,1.,2.,5.,15.,25./)
    info@cn_Level2Diff             = (/-35.,-25.,-15.,-5.,-1.,0.,1.,5.,15.,25.,35./)
    info@cn_Level3Diff             = (/-45.,-30.,-15.,-5.,-1.,0.,1.,5.,15.,30.,45./)
    info@cn_Level4Diff             = (/-60.,-40.,-20.,-5.,-1.,0.,1.,5.,20.,40.,60./)
    info@cn_Level5Diff             = (/-90.,-60.,-30.,-10.,-5.,0.,5.,10.,30.,60.,90./)
    info@cn_Level6Diff             = (/-100.,-75.,-50.,-25.,-5.,0.,5.,25.,50.,75.,100./)
    info@cn_Level7Diff             = (/-175.,-125.,-75.,-25.,-5.,0.,5.,25.,75.,125.,175./)
    info@cn_Level8Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    info@cn_Level9Diff             = (/-350.,-250.,-150.,-50.,-10.,0.,10.,50.,150.,250.,350./)
    return(info)
  end if

  if (varName .eq. "TOTAL_SOIL_LIQUID") then
    info@flux=False
    info@longName="total soil liquid water"
    info@nativeUnits = "kg/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m^2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CLM"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,900./)
    return(info)
  end if

  if (varName .eq. "TOTSOILLIQ") then
    info@flux=False
    info@longName="total soil liquid water"
    info@nativeUnits = "kg/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"	
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m^2"  ;for mm water equivalent: 1:1 conversion from kg/m2
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,900./)
    return(info)
  end if

  if (varName .eq. "SOIL_PSI") then
    info@flux=False
    info@longName="Soil Water Potential"
    info@nativeUnits = "MPa"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "MPa"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,900./)
    return(info)
  end if

  if (varName .eq. "SOILPSI") then
    info@flux=False
    info@longName="soil water potential in each soil layer"
    info@nativeUnits = "MPa"
    ; -- global Total
    info@globalTotal__units        = "NA"	
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "MPa"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,900./)
    return(info)
  end if

  if (varName .eq. "QINFL") then
    info@flux=True
    info@longName="infiltration"
    info@nativeUnits = "mm/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "mm/y"
    info@globalTotal_Annual__SF    = secondsInYear
    ; -- global Mean
    info@globalMean__units         = "mm/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "mm/y"
    info@globalMean_Annual__SF     = secondsInYear 
    info@globalMean_Daily__units   = "mm/d"
    info@globalMean_Daily__SF      = secondsInDay 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "RUNOFF") then
    info@flux=True
    info@longName="Surface Runoff"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QOVER") then
    info@flux=True
    info@longName="surface runoff"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QIRRIG") then
    info@flux=True
    info@longName="water added through irrig"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QRGWL") then
    info@flux=True
    info@longName="surface runoff at glaciers (liquid only), wetlands, lakes; also includes melted ice runoff from QSNWCPICE"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-4.,-3.,-2.,-1.,0.,1.,2.,3.,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "TOTRUNOFF") then
    info@flux=True
    info@longName="Total Liquid Runoff"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             =  (/-4.,-2.,-1.,-0.5,-0.25,0.,0.25,0.5,1.,2.,4./)
    info@cn_LevelsDiffObs          =  (/-10., -8., -6., -4., -2., 0., 2, 4, 6, 8, 10./)
    return(info)
  end if

  if (varName .eq. "QRUNOFF_RAIN_TO_SNOW_CONVERSION") then
    info@flux=True
    info@longName="liquid runoff from rain-to-snow conversion when this conversion leads to immediate runoff"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             =  (/-4.,-2.,-1.,-0.5,-0.25,0.,0.25,0.5,1.,2.,4./)
    info@cn_LevelsDiffObs          =  (/-10., -8., -6., -4., -2., 0., 2, 4, 6, 8, 10./)
    return(info)
  end if

  if (varName .eq. "QFLX_LIQ_DYNBAL") then
    info@flux=True
    info@longName="liq dynamic land cover change conversion runoff flux"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             =  (/-4.,-2.,-1.,-0.5,-0.25,0.,0.25,0.5,1.,2.,4./)
    info@cn_LevelsDiffObs          =  (/-10., -8., -6., -4., -2., 0., 2, 4, 6, 8, 10./)
    return(info)
  end if

  if (varName .eq. "QFLX_ICE_DYNBAL") then
    info@flux=True
    info@longName="ice dynamic land cover change conversion runoff flux"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             =  (/-4.,-2.,-1.,-0.5,-0.25,0.,0.25,0.5,1.,2.,4./)
    info@cn_LevelsDiffObs          =  (/-10., -8., -6., -4., -2., 0., 2, 4, 6, 8, 10./)
    return(info)
  end if

  if (varName .eq. "QRUNOFF_ICE") then
    info@flux=True
    info@longName="total liquid runoff not incl correction for LULCC (ice landunits only)"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             =  (/-4.,-2.,-1.,-0.5,-0.25,0.,0.25,0.5,1.,2.,4./)
    info@cn_LevelsDiffObs          =  (/-10., -8., -6., -4., -2., 0., 2, 4, 6, 8, 10./)
    return(info)
  end if

  if (varName .eq. "DRAINAGE") then
    info@flux=True
    info@longName="Subsurface Drainage"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QDRAI") then
    info@flux=True
    info@longName="sub-surface drainage"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "INTERCEPTION") then
    info@flux=True
    info@longName="Canopy Interception"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,2.,4.,6.,8.,10.,12.,14.,16./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QINTR") then
    info@flux=True
    info@longName="interception"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,3.,4.,5.,6.,7.,8./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QDRIP") then
    info@flux=True
    info@longName="throughfall"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,2.,4.,6.,8.,10.,12.,14.,16./) 
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QSNOMELT") then
; WJS 8-19-11: QMELT changed to QSNOMELT, but allowing both for
; backwards compatibility
    info@altNames=(/"QMELT"/)  
    info@flux=True
    info@longName="snow melt"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QSNOMELT_ICE") then
    info@flux=True
    info@longName="snow melt over glacier units"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QSNOFRZ") then
    info@flux=True
    info@longName="column-integrated snow freezing rate"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QSNOFRZ_ICE") then
    info@flux=True
    info@longName="column-integrated snow freezing rate (ice landunits only)"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QICE") then
    info@flux=True
    info@longName="ice growth/melt"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QICE_FRZ") then
    info@flux=True
    info@longName="ice growth"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QICE_MELT") then
    info@flux=True
    info@longName="ice melt"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "SOIL_EVAPORATION") then
    info@flux=True
    info@longName="Soil Evaporation"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QSOIL") then
    info@flux=True
    info@longName="ground evaporation"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QSOIL_ICE") then
    info@flux=True
    info@longName="ground evaporation over glacier units"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "CANOPY_EVAPORATION") then
    info@flux=True
    info@longName="Canopy Evaporation"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QVEGE") then
    info@flux=True
    info@longName="canopy evaporation"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QVEGEP") then
    info@flux=True
    info@longName="canopy evap:QVEGE/(RAIN+SNOW)*100"
    info@nativeUnits = "%"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "%"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     = -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    return(info)
  end if

  if (varName .eq. "TRANSPIRATION") then
    info@flux=True
    info@longName="Transpiration"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

  if (varName .eq. "QVEGT") then
    info@flux=True
    info@longName="canopy transpiration"
    info@nativeUnits = "mm/s"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-5.,-2.5,-1.,-.5,-.1,0.,.1,.5,1.,2.5,5./)
    return(info)
  end if

; ERROR terms ---------------------------------------------------------------------------
  if (varName .eq. "ERRSOL") then
    info@flux=True
    info@longName="solar radiation conservation error"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0e-12,-1.0e-13,-1.0e-14,-1.0e-15,0.,1.0e-15,1.0e-14,1.0e-13,1.0e-12/)
    info@cn_LevelsDiff             = (/-1.0e-11,-1.0e-12,-1.0e-13,-1.0e-14,-1.0e-15,0.,1.0e-15,1.0e-14,1.0e-13,1.0e-12,1.0e-11/)
    return(info)
  end if

  if (varName .eq. "ERRH2O") then
    info@flux=False
    info@longName="total water conservation error"
    info@nativeUnits = "mm"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999
    ; -- global Mean
    info@globalMean__units         = "mm"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0e-6,-1.0e-8,-1.0e-10,-1.0e-12,0.,1.0e-12,1.0e-10,1.0e-8,1.0e-6/)
    info@cn_LevelsDiff             = (/-1.0e-5,-1.0e-6,-1.0e-8,-1.0e-10,-1.0e-12,0.,1.0e-12,1.0e-10,1.0e-8,1.0e-6,1.0e-5/)
    return(info)
  end if

  if (varName .eq. "ERRSOI") then
    info@flux=True
    info@longName="soil/lake energy conservation error"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0e-7,-1.0e-8,-1.0e-9,-1.0e-10,0.,1.0e-10,1.0e-9,1.0e-8,1.0e-7/)
    info@cn_LevelsDiff             = (/-1.0e-6,-1.0e-7,-1.0e-8,-1.0e-9,-1.0e-10,0.,1.0e-10,1.0e-9,1.0e-8,1.0e-7,1.0e-6/)
    return(info)
  end if

  if (varName .eq. "ERRSEB") then
    info@flux=True
    info@longName="surface energy conservation error"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-1.0e-12,-1.0e-13,-1.0e-14,-1.0e-15,0.,1.0e-15,1.0e-14,1.0e-13,1.0e-12/)
    info@cn_LevelsDiff             = (/-1.e-11,-1.0e-12,-1.0e-13,-1.0e-14,-1.0e-15,0.,1.0e-15,1.0e-14,1.0e-13,1.0e-12,1.0e-11/)
    return(info)
  end if

  if (varName .eq. "SNOW_FRACTION") then
    info@flux=False
    info@longName="Snow Fraction"
    info@nativeUnits = "unitless"
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
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.1,0.2,0.3,0.5,0.6,0.7,0.8,0.9/)
    info@cn_LevelsDiff             = (/-.5,-.4,-.3,-.2,-.1,0.,.1,.2,.3,.4,.5/)
    return(info)
  end if

  if (varName .eq. "FSNO") then
    info@flux=False
    info@longName="fraction of ground covered by snow"
    info@nativeUnits = "unitless"
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.1,0.2,0.3,0.5,0.6,0.7,0.8,0.9/)
    info@cn_LevelsDiff             = (/-.5,-.4,-.3,-.2,-.1,0.,.1,.2,.3,.4,.5/)
    info@cn_LevelsDiffObs          = (/-0.5,-.4,-.3, -.2, -.1, 0., 0.1, 0.2, 0.3, 0.4, 0.5/)
    return(info)
  end if


  if (varName .eq. "RAIN") then
    info@flux=True
    info@longName="atmospheric rain"
    info@nativeUnits = "mm/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "mm/y"
    info@globalMean_Annual__SF     =  secondsInYear 
    info@globalMean_Daily__units   = "mm/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,2.,4.,6.,8.,10.,12.,14.,16./)
    info@cn_LevelsDiff             = (/-1.25,-1.,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.,1.25/)
    return(info)
  end if

  if (varName .eq. "SNOW") then
    info@flux=True
    info@longName="atmospheric snow"
    info@nativeUnits = "mm/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "mm/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mm/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-1.25,-1.,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.,1.25/)
    return(info)
  end if


  if (varName .eq. "SNOW_REPARTITIONED") then
    info@flux=True
    info@longName="atmospheric snow after repartitioning"
    info@nativeUnits = "mm/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "mm/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mm/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-1.25,-1.,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.,1.25/)
    return(info)
  end if

  if (varName .eq. "RAIN_REPARTITIONED") then
    info@flux=True
    info@longName="atmospheric rain after repartitioning"
    info@nativeUnits = "mm/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "mm/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mm/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,.5,1.,1.5,2.,2.5,3.,3.5,4./)
    info@cn_LevelsDiff             = (/-1.25,-1.,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.,1.25/)
    return(info)
  end if
  if (varName .eq. "WIND") then
    info@flux=True
    info@longName="atmospheric wind velocity magnitude"
    info@nativeUnits = "m/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "m/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "m/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,2.,4.,6.,8.,10.,12.,14.,16./)
    info@cn_LevelsDiff             = (/-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5./)
    return(info)
  end if

  if (varName .eq. "U10") then
    info@flux=True
    info@longName="10-m wind"
    info@nativeUnits = "m/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "m/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "m/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,2.,4.,6.,8.,10.,12.,14.,16./)
    info@cn_LevelsDiff             = (/-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5./)
    return(info)
  end if

  if (varName .eq. "TG") then
    info@flux=False
    info@longName="ground temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "PBOT") then
    info@flux=False
    info@longName="atm pressure of bottom layer"
    info@nativeUnits = "Pa"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "Pa"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CLM"
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "PCO2") then
    info@flux=False
    info@longName="partial pressure of CO2"
    info@nativeUnits = "Pa"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "Pa"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CLM"
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "CO2_PPMV") then
    info@flux=False
    info@longName="CO2 concentration"
    info@nativeUnits = "ppmv"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "ppmv"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CLM"
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "TBOT") then
    info@flux=False
    info@longName="atmospheric air temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "THBOT") then
    info@flux=False
    info@longName="atmospheric air potential temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "TLAKE") then
    info@flux=False
    info@longName="lake temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Level0                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level1                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level2                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level3                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level4                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level5                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level6                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level7                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level8                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level9                 = (/-10, -5, -1, 0, 1, 5, 10, 15, 20/)
    info@cn_Level0Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level1Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level2Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level3Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level4Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level5Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level6Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level7Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level8Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    info@cn_Level9Diff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "REL_HUM") then
    info@flux=False
    info@longName="Relative Humidity at 2m"
    info@nativeUnits = "kg/kg"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/kg"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.002,0.004,0.006,0.008,0.010,0.012,0.014,0.016/)
    info@cn_LevelsDiff             = (/-2.5e-3,-2.0e-3,-1.5e-3,-1.0e-3,-0.5e-3,0.,0.5e-3,1.0e-3,1.5e-3,2.0e-3,2.5e-3/)
    return(info)
  end if

  if (varName .eq. "SPEC_HUM") then
    info@flux=False
    info@longName="Atmospheric Specific Humidity"
    info@nativeUnits = "kg/kg"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/kg"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.002,0.004,0.006,0.008,0.010,0.012,0.014,0.016/)
    info@cn_LevelsDiff             = (/-2.5e-3,-2.0e-3,-1.5e-3,-1.0e-3,-0.5e-3,0.,0.5e-3,1.0e-3,1.5e-3,2.0e-3,2.5e-3/)
    return(info)
  end if

  if (varName .eq. "QBOT") then
    info@flux=False
    info@longName="atmospheric specific humidity"
    info@nativeUnits = "kg/kg"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/kg"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.002,0.004,0.006,0.008,0.010,0.012,0.014,0.016/)
    info@cn_LevelsDiff             = (/-2.5e-3,-2.0e-3,-1.5e-3,-1.0e-3,-0.5e-3,0.,0.5e-3,1.0e-3,1.5e-3,2.0e-3,2.5e-3/)
    return(info)
  end if

  if (varName .eq. "ZBOT") then
    info@flux=False
    info@longName="atmospheric reference height"
    info@nativeUnits = "m"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/40.,45.,50.,55.,60.,65.,70.,75.,80./)
    info@cn_LevelsDiff             = (/-1.,-.8,-.6,-.4,-.2,0.,.2,.4,.6,.8,1./)
    return(info)
  end if

  if (varName .eq. "IRDOWN") then
    info@flux=True
    info@longName="Downward Infrared Radiation"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/100.,150.,200.,250.,300.,350.,400.,450.,500./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FLDS") then
    info@flux=True
    info@longName="atmospheric longwave radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/100.,150.,200.,250.,300.,350.,400.,450.,500./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "SOLAR") then
    info@flux=True
    info@longName="Total Incident Solar Radiation"
    info@nativeUnits = "W/m2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,400./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSDS") then
    info@flux=True
    info@longName="atmospheric incident solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,50.,100.,150.,200.,250.,300.,350.,400./) 
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FPSN") then
    info@flux=True
    info@longName="photosynthesis"
    info@nativeUnits = "umol/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = umols2mols * gramsCperMole * grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "gC/m2s"
    info@globalMean__SF            = umols2mols * gramsCperMole
    info@globalMean_Annual__units  = "gC/m2y"
    info@globalMean_Annual__SF     = umols2mols * gramsCperMole * secondsInYear
    info@globalMean_Daily__units   = "gC/m2d"
    info@globalMean_Daily__SF      = umols2mols * gramsCperMole * secondsInDay
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.5,3.,4.5,6.,7.5,9.,10.5,12./)
    info@cn_LevelsDiff             = (/-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5./)
    info@cn_LevelsDiffObs          = (/-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5./)
    return(info)
  end if

  if (varName .eq. "PHOTOSYNTHESIS") then
    info@flux=True
    info@longName="Photosynthesis"
    info@nativeUnits = "umol/m2s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    = umols2mols * gramsCperMole * grams2Pgrams * secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kgC/m2s"
    info@globalMean__SF            = umols2mols * gramsCperMole * grams2Kgrams
    info@globalMean_Annual__units  = "kgC/m2y"
    info@globalMean_Annual__SF     = umols2mols * gramsCperMole * secondsInYear * grams2Kgrams
    info@globalMean_Daily__units   = "kgC/m2d"
    info@globalMean_Daily__SF      = umols2mols * gramsCperMole * secondsInDay  * grams2Kgrams
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "QCHANR") then
    info@flux=True
    info@longName="RTM River Flow"
    info@nativeUnits = "m^3/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m^3/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "km^3/y"
    info@globalMean_Annual__SF     = m2km * secondsInYear
    info@globalMean_Daily__units   = "km^3/d"
    info@globalMean_Daily__SF      = m2km * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "QCHOCNR") then
    info@flux=True
    info@longName="RTM River Discharge into Ocean"
    info@nativeUnits = "m^3/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m^3/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "km^3/y"
    info@globalMean_Annual__SF     = m2km * secondsInYear
    info@globalMean_Daily__units   = "km^3/d"
    info@globalMean_Daily__SF      = m2km * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "FSDSND") then
    info@flux=True
    info@longName="direct nir incident solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,20.,40.,60.,80.,100.,120.,140.,160./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSDSNDLN") then
    info@flux=True
    info@longName="direct nir incident solar radiation at local noon"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 62., 125, 187., 250, 312., 375, 437., 500/)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSDSNI") then
    info@flux=True
    info@longName="diffuse nir incident solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 12.5, 25, 37.5, 50, 62.5, 75, 87.5, 100/)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSDSVD") then
    info@flux=True
    info@longName="direct vis incident solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,20.,40.,60.,80.,100.,120.,140.,160./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSDSVDLN") then
    info@flux=True
    info@longName="direct vis incident solar radiation at local noon"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 62., 125, 187., 250, 312., 375, 437., 500/)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSDSVI") then
    info@flux=True
    info@longName="diffuse vis incident solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 12.5, 25, 37.5, 50, 62.5, 75, 87.5, 100/)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSRND") then
    info@flux=True
    info@longName="direct nir reflected solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,20.,40.,60.,80.,100.,120.,140.,160./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSRNDLN") then
    info@flux=True
    info@longName="direct nir reflected solar radiation at local noon"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 32., 65, 97.5, 130, 162., 195, 227., 260/)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSRNI") then
    info@flux=True
    info@longName="diffuse nir reflected solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 7.5, 15, 22.5, 30, 37.5, 45, 52.5, 60/)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSRVD") then
    info@flux=True
    info@longName="direct vis reflected solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,20.,40.,60.,80.,100.,120.,140.,160./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSRVDLN") then
    info@flux=True
    info@longName="direct vis reflected solar radiation at local noon"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 32., 65, 97.5, 130, 162., 195, 227., 260/)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "FSRVI") then
    info@flux=True
    info@longName="diffuse vis reflected solar radiation"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False

    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,10.,20.,30.,40.,50.,60.,70.,80./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

  if (varName .eq. "SPEC_HUM_2M") then
    info@flux=False
    info@longName="Specific Humidity at 2m"
    info@nativeUnits = "kg/kg"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/kg"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.002,0.004,0.006,0.008,0.010,0.012,0.014,0.016/)
    info@cn_LevelsDiff             = (/-2.5e-3,-2.0e-3,-1.5e-3,-1.0e-3,-0.5e-3,0.,0.5e-3,1.0e-3,1.5e-3,2.0e-3,2.5e-3/)
    return(info)
  end if

  if (varName .eq. "Q2M") then
    info@flux=False
    info@longName="2m specific humidity"
    info@nativeUnits = "kg/kg"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/kg"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,0.002,0.004,0.006,0.008,0.010,0.012,0.014,0.016/)
    info@cn_LevelsDiff             = (/-2.5e-3,-2.0e-3,-1.5e-3,-1.0e-3,-0.5e-3,0.,0.5e-3,1.0e-3,1.5e-3,2.0e-3,2.5e-3/)
    return(info)
  end if

  if (varName .eq. "RH2M") then
    info@flux=False
    info@longName="2m relative humidity"
    info@nativeUnits = "%"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "%"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0., 10., 20., 30., 40., 50., 60., 70., 80./)
    info@cn_LevelsDiff             = (/-25., -20., -15., -10., -5., 0., 5., 10., 15., 20., 25./)
    return(info)
  end if

  if (varName .eq. "TREFMNAV") then
    info@flux=True
    info@longName="daily minimum of average 2m temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "K"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "TREFMXAV") then
    info@flux=True
    info@longName="daily maximum of average 2m temperature"
    info@nativeUnits = "K"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "K"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "K"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False 
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-50, -40, -30, -20, -10, 0, 10, 20, 30/)
    info@cn_LevelsDiff             = (/-2.5,-2.,-1.5,-1.,-0.5,0.,0.5,1.,1.5,2.,2.5/)
    return(info)
  end if

  if (varName .eq. "BLACK_SKY_ALBEDO") then
    info@flux=False
    info@longName="Surface Black-Sky Albedo"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "% reflected"
    info@globalMean__SF            = 1.0                ; used to be fraction2percent
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 11., 22., 33., 45, 56., 67., 78., 90/)
    info@cn_LevelsDiff             = (/-10.0, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10/)
    return(info)
  end if

  if (varName .eq. "VBSA") then
    info@flux=False
    info@longName="visible black-sky albedo"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "% reflected"
    info@globalMean__SF            = 1.0		; used to be fraction2percent
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 11., 22., 33., 45, 56., 67., 78., 90/)
    info@cn_LevelsDiff             = (/-10.0, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10/)
    info@cn_LevelsDiffObs          = (/-20, -15.0, -10.0, -5.0, -2.0, 0., 2., 5., 10.0, 15.0, 20/)
    return(info)
  end if

  if (varName .eq. "NBSA") then
    info@flux=False
    info@longName="near-IR black-sky albedo"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "% reflected"
    info@globalMean__SF            = 1.0		; used to be fraction2percent
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 11., 22., 33., 45, 56., 67., 78., 90/)
    info@cn_LevelsDiff             = (/-10.0, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10/)
    info@cn_LevelsDiffObs          = (/-20, -15.0, -10.0, -5.0, -2.0, 0., 2., 5., 10.0, 15.0, 20/)
    return(info)
  end if

  if (varName .eq. "ALBEDO") then
    info@flux=True
    info@longName="all-sky albedo:FSR/FSDS"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "% reflected"
    info@globalMean__SF            = 1.0		; used to be fraction2percent
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 11., 22., 33., 45, 56., 67., 78., 90/)
    info@cn_LevelsDiff             = (/-10.0, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10/)
    return(info)
  end if

  if (varName .eq. "VWSA") then
    info@flux=True
    info@longName="visible white-sky albedo"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "% reflected"
    info@globalMean__SF            = 1.0		; used to be fraction2percent
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 11., 22., 33., 45, 56., 67., 78., 90/)
    info@cn_LevelsDiff             = (/-10.0, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10/)
    info@cn_LevelsDiffObs          = (/-20, -15.0, -10.0, -5.0, -2.0, 0., 2., 5., 10.0, 15.0, 20/)
    return(info)
  end if

  if (varName .eq. "NWSA") then
    info@flux=True
    info@longName="near-IR white-sky albedo"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "% reflected"
    info@globalMean__SF            = 1.0		; used to be fraction2percent
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 11., 22., 33., 45, 56., 67., 78., 90/)
    info@cn_LevelsDiff             = (/-10.0, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10/)
    info@cn_LevelsDiffObs          = (/-20, -15.0, -10.0, -5.0, -2.0, 0., 2., 5., 10.0, 15.0, 20/)
    return(info)
  end if

  if (varName .eq. "ALL_SKY_ALBEDO") then
    info@flux=True
    info@longName="All-Sky Albedo"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "% reflected"
    info@globalMean__SF            = 1.0                ; used to be fraction2percent
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CLM" 
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 11., 22., 33., 45, 56., 67., 78., 90/)
    info@cn_LevelsDiff             = (/-10.0, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10/)
    return(info)
  end if

  if (varName .eq. "ASA") then
    info@flux=True
    info@longName="all-sky albedo:FSR/FSDS"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "% reflected"
    info@globalMean__SF            = 1.0		; used to be fraction2percent
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 11., 22., 33., 45, 56., 67., 78., 90/)
    info@cn_LevelsDiff             = (/-10.0, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10/)
    info@cn_LevelsDiffObs          = (/-15, -10.0, -7.0, -5.0, -2.0, 0., 2., 5., 7.0, 10.0, 15./)
    return(info)
  end if

  if (varName .eq. "PREC") then
    info@flux=True
    info@longName="ppt: rain+snow"
    info@nativeUnits = "mm/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "mm/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mm/d"
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0.,1.,2.,4.,7.,10.,15.,20.,30./)
    info@cn_LevelsDiff             = (/-1.25,-1.,-0.75,-0.5,-0.25,0.,0.25,0.5,0.75,1.,1.25/)
    info@cn_LevelsDiffObs          = (/-10, -7.5, -5.0, -2.5, -1.0, 0., 1., 2.5, 5.0, 7.5, 10/)
    return(info)
  end if

  if (varName .eq. "P-E") then
    info@flux=True
    info@longName="PREC-ET"
    info@nativeUnits = "mm/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "mm/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "mm/d"
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = False
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-0.001, -7.5e-04, -5e-04, -2.5e-04, 0.0, 2.5e-04, 5e-04, 7.5e-04, 0.001/)
    info@cn_LevelsDiff             = (/-.001, -8e-04, -6e-04, -4e-04, -2e-04, 0.0, 2e-04, 4e-04, 6e-04, 8e-04, 0.001/)
    return(info)
  end if

  if (varName .eq. "RNET") then
    info@flux=True
    info@longName="net radiation:fsa-fira"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-40.,0.,40.,80.,120.,160.,200.,240.,280./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    return(info)
  end if

;DML
  if (varName .eq. "FGNET") then
    info@flux=True
    info@longName="net ground heat flux:fgr-fsm"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = True
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-24.,-18.,-12.,-6.,0.,6.,12.,18.,24./)
    info@cn_LevelsDiff             = (/-10.,-5.,-2.,-0.5,-0.1,0.,0.1,0.5,2.,5.,10./)
    return(info)
  end if
;DML

  if (varName .eq. "LHEAT") then
    info@flux=True
    info@longName="latent heat:FCTR+FCEV+FGEV"
    info@nativeUnits = "W/m^2"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "W/m^2"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/-20.,0.,20.,40.,60.,80.,100.,120.,140./)
    info@cn_LevelsDiff             = (/-50.,-25.,-10.,-5.,-1.,0.,1.,5.,10.,25.,50./)
    info@cn_LevelsDiffObs          = (/-75.,-60.,-45.,-30.,-15.,0.,15.,30.,45.,60.,75./)
    return(info)
  end if

  if (varName .eq. "EVAPFRAC") then
    info@flux=True
    info@longName="LHEAT/(LHEAT+FSH)"
    info@nativeUnits = "unitless"
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
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1/)
    info@cn_LevelsDiff             = (/-0.2, -0.16, -0.12, -0.08, -0.04, 0.0, 0.04, 0.08, 0.12, 0.16, 0.2/)
    return(info)
  end if

  if (varName .eq. "ZSOI") then
    info@flux=False
    info@longName="soil depth"
    info@nativeUnits = "m"
    ; -- global Total
    info@globalTotal__units        = "m"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = "...."
    return(info)
  end if
  if (varName .eq. "DZSOI") then
    info@flux=False
    info@longName="soil thickness"
    info@nativeUnits = "m"
    ; -- global Total
    info@globalTotal__units        = "m"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "m"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = "...."
    return(info)
  end if

  if (varName .eq. "WATSAT") then
    info@flux=False
    info@longName="saturated soil water content (porosity)"
    info@nativeUnits = "mm3/mm3"
    ; -- global Total
    info@globalTotal__units        = "mm3/mm3"
    info@globalTotal__SF           = 1.0
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = "...."
    return(info)
  end if

  if (varName .eq. "SUCSAT") then
    info@flux=False
    info@longName="saturated soil matrix potential"
    info@nativeUnits = "mm"
    ; -- global Total
    info@globalTotal__units        = "mm"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "mm"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = "...."
    return(info)
  end if

  if (varName .eq. "BSW") then
    info@flux=False
    info@longName="slope of soil water retention curve"
    info@nativeUnits = "unitless"
    ; -- global Total
    info@globalTotal__units        = "unitless"
    info@globalTotal__SF           = 1.0
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
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = "...."
    return(info)
  end if

  if (varName .eq. "FAREA_BURNED") then
    info@flux=False
    info@longName="fractional area burned"
    info@nativeUnits = "proportion/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "proportion/y"
    info@globalTotal_Annual__SF    = secondsInYear
    ; -- global Mean
    info@globalMean__units         = "proportion/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "proportion/y"
    info@globalMean_Annual__SF     = secondsInYear
    info@globalMean_Daily__units   = "proportion/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "BAF_CROP") then
    info@flux=False
    info@longName="fractional area burned - crop"
    info@nativeUnits = "proportion/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "proportion/y"
    info@globalTotal_Annual__SF    = secondsInYear
    ; -- global Mean
    info@globalMean__units         = "proportion/s"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "proportion/y"
    info@globalMean_Annual__SF     = secondsInYear
    info@globalMean_Daily__units   = "proportion/d"
    info@globalMean_Daily__SF      = secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "ME") then
    info@flux=False
    info@longName="moisture of extinction"
    info@nativeUnits = "proportion"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "proportion"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "XIM") then
    info@flux=False
    info@longName="moisture index"
    info@nativeUnits = "+/-1"
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
    info@model		           = "CN" 
    info@derivedVariable           = True 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CO2") then
    info@flux=False
    info@longName="CO2 concentration"
    info@nativeUnits = "kgCO2/kgDryAir"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "ppmv"
    info@globalMean__SF            =  kgCO2_to_ppmv
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CO2_FFF") then
    info@flux=False
    info@longName="CO2 Fossil Fuel Concentration"
    info@nativeUnits = "kgCO2/kgDryAir"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "ppmv"
    info@globalMean__SF            =  kgCO2_to_ppmv
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CO2_LND") then
    info@flux=False
    info@longName="CO2 Land-Atm Concentration"
    info@nativeUnits = "kgCO2/kgDryAir"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "ppmv"
    info@globalMean__SF            =  kgCO2_to_ppmv
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "CO2_OCN") then
    info@flux=False
    info@longName="CO2 Ocn-Atm Concentration"
    info@nativeUnits = "kgCO2/kgDryAir"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "ppmv"
    info@globalMean__SF            =  kgCO2_to_ppmv
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "SFCO2") then
    info@flux=True
    info@longName="CO2 Surface Flux"
    info@nativeUnits = "kgCO2/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    =  kgCO2_to_gC * secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            =  kgCO2_to_gC
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  kgCO2_to_gC * secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      =  kgCO2_to_gC * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "SFCO2_FFF") then
    info@flux=True
    info@longName="CO2 Fossil Fuel Surface Flux"
    info@nativeUnits = "kgCO2/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    =  kgCO2_to_gC * secondsInYear * grams2Pgrams
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            =  kgCO2_to_gC
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  kgCO2_to_gC * secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      =  kgCO2_to_gC * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "SFCO2_LND") then
    info@flux=True
    info@longName="CO2 Land Surface Flux"
    info@nativeUnits = "kgCO2/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    =  kgCO2_to_gC * secondsInYear * grams2Pgrams
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            =  kgCO2_to_gC
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  kgCO2_to_gC * secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      =  kgCO2_to_gC * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "SFCO2_OCN") then
    info@flux=True
    info@longName="CO2 Ocean Surface Flux"
    info@nativeUnits = "kgCO2/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    =  kgCO2_to_gC * secondsInYear * grams2Pgrams
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            =  kgCO2_to_gC
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  kgCO2_to_gC * secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      =  kgCO2_to_gC * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "SFCO2_FF") then
    info@flux=True
    info@longName="CO2 Fossil Fuel Surface Flux"
    info@nativeUnits = "kgCO2/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    =  kgCO2_to_gC * secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            =  kgCO2_to_gC
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  kgCO2_to_gC * secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      =  kgCO2_to_gC * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "SFCO2_LN") then
    info@flux=True
    info@longName="CO2 Land Surface Flux"
    info@nativeUnits = "kgCO2/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    =  kgCO2_to_gC * secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            =  kgCO2_to_gC
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  kgCO2_to_gC * secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      =  kgCO2_to_gC * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if

  if (varName .eq. "SFCO2_OC") then
    info@flux=True
    info@longName="CO2 Ocean Surface Flux"
    info@nativeUnits = "kgCO2/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "PgC/y"
    info@globalTotal_Annual__SF    =  kgCO2_to_gC * secondsInYear * grams2Pgrams 
    ; -- global Mean
    info@globalMean__units         = "gC/m^2/s"
    info@globalMean__SF            =  kgCO2_to_gC
    info@globalMean_Annual__units  = "gC/m^2/y"
    info@globalMean_Annual__SF     =  kgCO2_to_gC * secondsInYear
    info@globalMean_Daily__units   = "gC/m^2/d"
    info@globalMean_Daily__SF      =  kgCO2_to_gC * secondsInDay
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999.
    info@cn_Max                    = -999.
    info@cn_Levels                 = (/-1, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1/)
    info@cn_LevelsDiff             = (/-0.1, -0.08, -0.06, -0.04, -0.02, 0.0, 0.02, 0.04, 0.06, 0.08, 0.1/)
    return(info)
  end if
  
  if (varName .eq. "C13_PSNSUN_TO_CPOOL") then
    info@flux=True
    info@longName="C13 GPP from Sunlit Canopy"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     =  1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "C13_PSNSHADE_TO_CPOOL") then
    info@flux=True
    info@longName="C13 GPP from Shaded Canopy"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     =  1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "C13_AGNPP") then
    info@flux=True
    info@longName="C13 Aboveground NPP"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2., 2.5 /)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "C13_BGNPP") then
    info@flux=True
    info@longName="C13 Belowground NPP"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2., 2.5 /)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "C13_AR") then
    info@flux=True
    info@longName="C13 Autotrophic Respiration (MR + GR)"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.25, 0.5, 1.0, 2.0, 3., 4., 5., 6., 7./)
    info@cn_LevelsDiff             = (/-2.50, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5/)
    return(info)
  end if

  if (varName .eq. "C13_COL_CTRUNC") then
    info@flux=False
    info@longName="C13 Column-Level Sink for C Truncation" 
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C13_COL_FIRE_CLOSS") then
    info@flux=True
    info@longName="C13 Totl Col-Level Fire C Loss"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 10.0, 20.0, 30.0, 40.0, 50., 60., 70., 80./)
    info@cn_LevelsDiff             = (/-10.0, -8.0, -6.0, -4.0, -2.0, 0, 2.0, 4.0, 6.0, 8.0, 10/)
    return(info)
  end if

  if (varName .eq. "C13_CPOOL") then
    info@flux=False
    info@longName="C13 Temporary Photosynthate C Pool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_XSMRPOOL") then
    info@flux=False
    info@longName="C13 Temporary Photosynthate C Pool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_CWDC") then
    info@flux=False
    info@longName="C13 Coarse Woody Debris Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if
    
  if (varName .eq. "C13_DEADCROOTC") then
    info@flux=False
    info@longName="C13 Dead Coarse Root Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_DEADSTEMC") then
    info@flux=False
    info@longName="C13 Dead Stem Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if
  
  if (varName .eq. "C13_DISPVEGC") then
    info@flux=False
    info@longName="C13 Displayed Veg Carbon, Excluding Storage and Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C13_ER") then
    info@flux=True
    info@longName="C13 Totl Ecosystem Respiration (AR + HR)"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_FROOTC") then
    info@flux=False
    info@longName="C13 Fine Root CC"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_GPP") then
    info@flux=True
    info@longName="C13 Gross Primary Production"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_GR") then
    info@flux=True
    info@longName="C13 Total Growth Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_HR") then
    info@flux=True
    info@longName="C13 Total Hetereotrophic Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_LEAFC") then
    info@flux=False
    info@longName="C13 Leaf Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_LITHR") then
    info@flux=True
    info@longName="C13 Litter Hetereotrophic Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_LITR1C") then
    info@flux=False
    info@longName="C13 Litter Labile C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C13_LITR2C") then
    info@flux=False
    info@longName="C13 Litter Cellulose C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C13_LITR3C") then
    info@flux=False
    info@longName="C13 Litter Lignin C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C13_LIVECROOTC") then
    info@flux=False
    info@longName="C13 Live Coarse Root Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_LIVESTEMC") then
    info@flux=False
    info@longName="C13 Live Stem C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_MR") then
    info@flux=True
    info@longName="C13 Maintenance Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_NEE") then
    info@flux=True
    info@longName="C13 Net Ecosys Exchange of C;Incl Fire Flx;Pos for Source"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_NEP") then
    info@flux=True
    info@longName="C13 Net Ecosystem Production;Excl Fire Flx;Pos for Sink"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_NBP") then
    info@flux=True
    info@longName="C13 net biome production, includes fire, landuse and harvest flux"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_NPP") then
    info@flux=True
    info@longName="C13 Net Primary Production"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_PFT_CTRUNC") then
    info@flux=False
    info@longName="C13 Pft-Level Sink for C Truncation"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_PFT_FIRE_CLOSS") then
    info@flux=True
    info@longName="C13 Totl Pft-Level Fire C Loss"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_RR") then
    info@flux=True
    info@longName="C13 Root Respiration (Fine Root MR + Total Root GR)"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_SOIL1C") then
    info@flux=False
    info@longName="C13 Soil Organic Matter C (Fast Pool)"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if
  
  if (varName .eq. "C13_SOIL2C") then
    info@flux=False
    info@longName="C13 Soil Organic Matter C (Medium Pool)"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_SOIL3C") then
    info@flux=False
    info@longName="C13 Soil Organic Matter C (Slow Pool)"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_SOIL4C") then
    info@flux=False
    info@longName="C13 Soil Organic Matter C (Slowest Pool)"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_SOMHR") then
    info@flux=True
    info@longName="C13 SOM Hetereotrophic Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_SR") then
    info@flux=True
    info@longName="C13 Totl Soil Respiration (HR + Root Resp)"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil v PDB"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil v PDB"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil v PDB"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_STORVEGC") then
    info@flux=False
    info@longName="C13 Stored Vegetation C, Excluding Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_TOTLITC") then
    info@flux=False
    info@longName="C13 Totl Litter Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if
  
  if (varName .eq. "C13_TOTSOMC") then
    info@flux=False
    info@longName="C13 Total SOM Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if
  
  if (varName .eq. "C13_TOTECOSYSC") then
    info@flux=False
    info@longName="C13 Totl Ecosystem C, Incl Veg But Excl Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_TOTCOLC") then
    info@flux=False
    info@longName="C13 Total Column C, Incl Veg and Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_TOTPFTC") then
    info@flux=False
    info@longName="C13 Totl PFT-Level C, Including Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C13_TOTVEGC") then
    info@flux=False
    info@longName="C13 Total Vegetation C, Excluding Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil v PDB"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil v PDB"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_PSNSUN_TO_CPOOL") then
    info@flux=True
    info@longName="C14 GPP from Sunlit Canopy"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     =  1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "C14_PSNSHADE_TO_CPOOL") then
    info@flux=True
    info@longName="C14 GPP from Shaded Canopy"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     =  1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.5, 1.0, 1.5, 2.0, 4.0, 6., 8., 10., 12./)
    info@cn_LevelsDiff             = (/-5.0, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5/)
    return(info)
  end if

  if (varName .eq. "C14_AGNPP") then
    info@flux=True
    info@longName="C14 Aboveground NPP"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2., 2.5 /)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if
  
  if (varName .eq. "C14_BGNPP") then
    info@flux=True
    info@longName="C14 Belowground NPP"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.12, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2., 2.5 /)
    info@cn_LevelsDiff             = (/-1.0, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1/)
    return(info)
  end if

  if (varName .eq. "C14_AR") then
    info@flux=True
    info@longName="C14 Autotrophic Respiration (MR + GR)"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/.25, 0.5, 1.0, 2.0, 3., 4., 5., 6., 7./)
    info@cn_LevelsDiff             = (/-2.50, -2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2, 2.5/)
    return(info)
  end if

  if (varName .eq. "C14_COL_CTRUNC") then
    info@flux=False
    info@longName="C14 Column-Level Sink for C Truncation" 
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C14_COL_FIRE_CLOSS") then
    info@flux=True
    info@longName="C14 Totl Col-Level Fire C Loss"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = (/0, 10.0, 20.0, 30.0, 40.0, 50., 60., 70., 80./)
    info@cn_LevelsDiff             = (/-10.0, -8.0, -6.0, -4.0, -2.0, 0, 2.0, 4.0, 6.0, 8.0, 10/)
    return(info)
  end if

  if (varName .eq. "C14_CPOOL") then
    info@flux=False
    info@longName="C14 Temporary Photosynthate C Pool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_XSMRPOOL") then
    info@flux=False
    info@longName="C14 Temporary Photosynthate C Pool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_CWDC") then
    info@flux=False
    info@longName="C14 Coarse Woody Debris Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if
    
  if (varName .eq. "C14_DEADCROOTC") then
    info@flux=False
    info@longName="C14 Dead Coarse Root Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_DEADSTEMC") then
    info@flux=False
    info@longName="C14 Dead Stem Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if
  
  if (varName .eq. "C14_DISPVEGC") then
    info@flux=False
    info@longName="C14 Displayed Veg Carbon, Excluding Storage and Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C14_ER") then
    info@flux=True
    info@longName="C14 Totl Ecosystem Respiration (AR + HR)"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_FROOTC") then
    info@flux=False
    info@longName="C14 Fine Root CC"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_GPP") then
    info@flux=True
    info@longName="C14 Gross Primary Production"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_GR") then
    info@flux=True
    info@longName="C14 Total Growth Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_HR") then
    info@flux=True
    info@longName="C14 Total Hetereotrophic Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_LEAFC") then
    info@flux=False
    info@longName="C14 Leaf Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_LITHR") then
    info@flux=True
    info@longName="C14 Litter Hetereotrophic Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_LITR1C") then
    info@flux=False
    info@longName="C14 Litter Labile C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C14_LITR2C") then
    info@flux=False
    info@longName="C14 Litter Cellulose C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C14_LITR3C") then
    info@flux=False
    info@longName="C14 Litter Lignin C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    return(info)
  end if

  if (varName .eq. "C14_LIVECROOTC") then
    info@flux=False
    info@longName="C14 Live Coarse Root Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_LIVESTEMC") then
    info@flux=False
    info@longName="C14 Live Stem C"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_MR") then
    info@flux=True
    info@longName="C14 Maintenance Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_NEE") then
    info@flux=True
    info@longName="C14 Net Ecosys Exchange of C;Incl Fire Flx;Pos for Source"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_NEP") then
    info@flux=True
    info@longName="C14 Net Ecosystem Production;Excl Fire Flx;Pos for Sink"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_NBP") then
    info@flux=True
    info@longName="C14 net biome production, includes fire, landuse and harvest flux"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False 
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_NPP") then
    info@flux=True
    info@longName="C14 Net Primary Production"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_PFT_CTRUNC") then
    info@flux=False
    info@longName="C14 Pft-Level Sink for C Truncation"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_PFT_FIRE_CLOSS") then
    info@flux=True
    info@longName="C14 Totl Pft-Level Fire C Loss"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_RR") then
    info@flux=True
    info@longName="C14 Root Respiration (Fine Root MR + Total Root GR)"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_SOIL1C") then
    info@flux=False
    info@longName="C14 Soil Organic Matter C (Fast Pool)"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if
  
  if (varName .eq. "C14_SOIL2C") then
    info@flux=False
    info@longName="C14 Soil Organic Matter C (Medium Pool)"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_SOIL3C") then
    info@flux=False
    info@longName="C14 Soil Organic Matter C (Slow Pool)"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_SOIL4C") then
    info@flux=False
    info@longName="C14 Soil Organic Matter C (Slowest Pool)"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999.
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999.
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_SOMHR") then
    info@flux=True
    info@longName="C14 SOM Hetereotrophic Respiration"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_SR") then
    info@flux=True
    info@longName="C14 Totl Soil Respiration (HR + Root Resp)"
    info@nativeUnits = "gC/m^2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "per mil"
    info@globalTotal_Annual__SF    = 1.0
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "per mil"
    info@globalMean_Annual__SF     = 1.0
    info@globalMean_Daily__units   = "per mil"
    info@globalMean_Daily__SF      = 1.0
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_STORVEGC") then
    info@flux=False
    info@longName="C14 Stored Vegetation C, Excluding Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_TOTLITC") then
    info@flux=False
    info@longName="C14 Totl Litter Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if
  
  if (varName .eq. "C14_TOTSOMC") then
    info@flux=False
    info@longName="C14 Total SOM Carbon"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if
  
  if (varName .eq. "C14_TOTECOSYSC") then
    info@flux=False
    info@longName="C14 Totl Ecosystem C, Incl Veg But Excl Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_TOTCOLC") then
    info@flux=False
    info@longName="C14 Total Column C, Incl Veg and Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_TOTPFTC") then
    info@flux=False
    info@longName="C14 Totl PFT-Level C, Including Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "C14_TOTVEGC") then
    info@flux=False
    info@longName="C14 Total Vegetation C, Excluding Cpool"
    info@nativeUnits = "gC/m^2"
    ; -- global Total
    info@globalTotal__units        = "per mil"
    info@globalTotal__SF           = 1.0
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "per mil"
    info@globalMean__SF            = 1.0
    info@globalMean_Annual__units  = "NA"
    info@globalMean_Annual__SF     =  -999. 
    info@globalMean_Daily__units   = "NA"
    info@globalMean_Daily__SF      = -999. 
    ; -- Origin 
    info@model		           = "CN" 
    info@derivedVariable           = False
    info@clampVariable             = False
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "VOCFLXT") then
    info@flux=True
    info@longName="Total VOC flux into Atmosphere"
    info@nativeUnits = "uG/m2/h"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  uGrams2Kgrams * hr2sec
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  uGrams2Kgrams * hr2sec * secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  uGrams2Kgrams * hr2sec * secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "ISOPRENE") then
    info@flux=True
    info@longName="Isoprene Flux"
    info@nativeUnits = "uG/m2/h"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  uGrams2Kgrams * hr2sec
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  uGrams2Kgrams * hr2sec * secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  uGrams2Kgrams * hr2sec * secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "MONOTERPENE") then
    info@flux=True
    info@longName="Monoterpene Flux"
    info@nativeUnits = "uG/m2/h"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  uGrams2Kgrams * hr2sec
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  uGrams2Kgrams * hr2sec * secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  uGrams2Kgrams * hr2sec * secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "OTHER_VOC") then
    info@flux=True
    info@longName="Other VOC Flux"
    info@nativeUnits = "uG/m2/h"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  uGrams2Kgrams * hr2sec
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  uGrams2Kgrams * hr2sec * secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  uGrams2Kgrams * hr2sec * secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "OR_VOC") then    
    info@flux=True
    info@longName="Other Reactive VOC Flux"  
    info@nativeUnits = "uG/m2/h"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  uGrams2Kgrams * hr2sec
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  uGrams2Kgrams * hr2sec * secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  uGrams2Kgrams * hr2sec * secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "BIOGENIC_CO") then    
    info@flux=True
    info@longName="Biogenic CO Flux"  
    info@nativeUnits = "uG/m2/h"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "NA"
    info@globalTotal_Annual__SF    = -999.
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  uGrams2Kgrams * hr2sec
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  uGrams2Kgrams * hr2sec * secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  uGrams2Kgrams * hr2sec * secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "DSTDEP") then    
    info@flux=True
    info@longName="total dust deposition (dry+wet) from atmosphere"  
    info@nativeUnits = "kg/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Pg/y"
    info@globalTotal_Annual__SF    = kgrams2Pgrams*secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  -999.
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "DSTFLXT") then    
    info@flux=True
    info@longName="total surface dust emission"  
    info@nativeUnits = "kg/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Pg/y"
    info@globalTotal_Annual__SF    = kgrams2Pgrams*secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  -999.
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "OCDEP") then    
    info@flux=True
    info@longName="total OC deposition (dry+wet) from atmosphere"  
    info@nativeUnits = "kg/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Pg/y"
    info@globalTotal_Annual__SF    = kgrams2Pgrams*secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  -999.
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

  if (varName .eq. "BCDEP") then    
    info@flux=True
    info@longName="total BC deposition (dry+wet) from atmosphere"  
    info@nativeUnits = "kg/m2/s"
    ; -- global Total
    info@globalTotal__units        = "NA"
    info@globalTotal__SF           = -999.
    info@globalTotal_Annual__units = "Pg/y"
    info@globalTotal_Annual__SF    = kgrams2Pgrams*secondsInYear
    ; -- global Mean
    info@globalMean__units         = "kg/m2/s"
    info@globalMean__SF            =  -999.
    info@globalMean_Annual__units  = "kg/m2/y"
    info@globalMean_Annual__SF     =  secondsInYear
    info@globalMean_Daily__units   = "kg/m2/d"
    info@globalMean_Daily__SF      =  secondsInDay
    ; -- Origin
    info@model                     = "CN"
    info@derivedVariable           = False
    info@clampVariable             = True
    ; -- contour intervals
    info@cn_Explicit               = True
    info@cn_Min                    = -999
    info@cn_Max                    = -999
    info@cn_Levels                 = -999.
    info@cn_LevelsDiff             = -999
    return(info)
  end if

    print("no variable info for variable "+ varName)
    info = False
    return(info)
end

