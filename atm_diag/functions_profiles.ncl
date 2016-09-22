; NCL script
; functions_profiles.ncl
; Mark Stevens
;*****************************************************************

function ssh_hybrid (p[*]:numeric,tk[*]:numeric)

; input arguments
;  p[*] - pressure on hybrid levels in millibars (lev)
;  tk[*] - temperature in Kelvin (lev)
;
; returns saturation specific humidity (dimensionless)
; uses several functions from Dennis's thermo.f code
;-------------------------------------------------------------------------
; from the fortran function ssh
;   this function returns saturation specific humidity ssh (grams of
;   water vapor per kilogram of moist air) given the pressure p
;   (millibars) and the temperature t (celsius). the equation is given
;   in standard meteorological texts. if t is dew point (celsius), then
;   ssh returns the actual specific humidity.
;   compute the dimensionless mixing ratio.

begin

  T = tk - 273.15           ; convert Kelvin to Celsius (lev)
  q = tk                    ; copy coords and atrributes (lev)
  
;-------------------------------------------------------------------------
; from fortran function esw
;   this function returns the saturation vapor pressure esw (millibars)
;   over liquid water given the temperature t (celsius). the polynomial
;   approximation below is due to herman wobus, a mathematician who
;   worked at the navy weather research facility, norfolk, virginia,
;   but who is now retired. the coefficients of the polynomial were
;   chosen to fit the values in table 94 on pp. 351-353 of the smith-
;   sonian meteorological tables by roland list (6th edition). the
;   approximation is valid for -50 < t < 100c
;   include 'lib_dev:[gudoc]edfvaxbox.for/list'
;   baker, schlatter  17-may-1982     original version.
;-----------------------------------------------------------------------------
; es0 = saturation vapor ressure over liquid water at 0C

  es0 = 6.1078
    
  pol = 0.99999683        + T*(-0.90826951e-02 +      \
        T*(0.78736169e-04 + T*(-0.61117958e-06 +   \
        T*(0.43884187e-08 + T*(-0.29883885e-10 +   \ 
        T*(0.21874425e-12 + T*(-0.17892321e-14 +   \
        T*(0.11112018e-16 + T*(-0.30994571e-19)))))))))               
  
  esw = es0/pol^8    ; 3D array (millibars)

;-------------------------------------------------------------------------
; from the fortran function wmr
;   this function approximates the mixing ratio wmr (grams of water
;   vapor per kilogram of dry air) given the pressure p (mb) and the
;   temperature t (celsius). the formula used is given on p. 302 of the
;   smithsonian meteorological tables by roland list (6th edition).
;   the next two lines contain a formula by herman wobus for the
;   correction factor wfw for the departure of the mixture of air
;   and water vapor from the ideal gas law. the formula fits values
;   in table 89, p. 340 of the smithsonian meteorological tables,
;   but only for temperatures and pressures normally encountered in
;   in the atmosphere.
;-------------------------------------------------------------------------
;  eps = ratio of the mean molecular weight of water (18.016 g/mole)
;                               to that of dry air (28.966 g/mole)
 eps = 0.62197

 x = 0.02*(T-12.5+7500./p)
 wfw = 1.+ 4.5e-06*p + 1.4e-03*x^2
 fwesw = wfw*esw
 r = eps*fwesw/(p-fwesw)      ; dimensionless (g/g or kg/kg) 2D array

;--------------------------------------------------------------------------
;  compute the dimensionless saturation specific humidity.

 q  = r/(1.+r)
   
 q@long_name = "saturation specific humidity"
 q@units = "kg/kg"
 q@op_derive = "computed using the function ssh"

 return (q)
end

;************************************************************************

function  smse_hybrid (t[*]:numeric,z[*]:numeric,p[*]:numeric)

; compute the saturation moist static energy (smse) from the 
; model data on the hybrid levels
; t[*] array of temperatures(K) on the hybrid levels
; z[*] array of geopotential heights(m) of the hybrid levels
; p[*] array of pressures(mb or hPa) on the hybrid levels

begin

; define constants
  Cp = 1.00464e3 ; specific heat of dry air at constant pressure (J/(K*kg)) 
  L = 2.501e6    ; latent heat of vaporization (J/kg)
  g = 9.80616    ; acceleration due to gravity at sea level (m/s^2)

; compute the dry static energy on the hybrid levels (J/kg)
  s = Cp*t + g*z

; compute the stauration specific humidity on the hybrid levels
  qs = ssh_hybrid (p,t) 

; compute the staturation moist static energy on the hybrid levels (J/kg)
; and convert to kJ/kg
  hs = (s + L*qs)/1000.0
  hs@long_name = "stat moist static energy"  
  hs@units = "kJ/kg"

  return (hs)
end
