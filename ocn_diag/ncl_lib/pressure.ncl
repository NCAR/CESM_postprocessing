function pressure( depth )

;-----------------------------------------------------------------------
;
;     this function computes pressure in bars from depth in meters
;     by using a mean density derived from depth-dependent global
;     average temperatures and salinities from Levitus_94, and
;     integrating using hydrostatic balance.
;
;     references:
;        Levitus, S., R. Burgett, and T.P. Boyer, World Ocean Atlas
;          1994, Volume 3: Salinity, NOAA Atlas NESDIS 3, US Dept. of
;          Commerce, 1994.
;        Levitus, S. and T.P. Boyer, World Ocean Atlas 1994,
;          Volume 4: Temperature, NOAA Atlas NESDIS 4, US Dept. of
;          Commerce, 1994.
;        Dukowicz, J. K., 2000: Reduction of Pressure and Pressure
;          Gradient Errors in Ocean Simulations, J. Phys. Oceanogr.,
;          submitted.
;
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
;
;    convert depth in meters to pressure in bars
;
;-----------------------------------------------------------------------

begin
  ddepth = todouble(depth)
  pressure_ret = 0.059808d*(exp(-0.025d * ddepth) - 1.0d)    \
        + 0.100766d * ddepth + 2.28405d-7 * (ddepth^2)

  return (pressure_ret) 
end 
