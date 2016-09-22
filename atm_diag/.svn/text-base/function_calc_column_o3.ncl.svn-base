; NCL script
;  function_calc_column_o3.ncl
; Calcuate column ozone using ozonopause or tropopause
; o3case:0 total column, o3case:1 strat column, o3case:2 trop column
; Simone Tilmes,Jan 2014
;**************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH

;
function function_calc_column_o3(inptr,o3case)
begin
 lev1 = inptr->lev
 lat1 = inptr->lat
 lon1 = inptr->lon
 nlat1 = dimsizes(lat1)
 nlon1 = dimsizes(lon1)
 nlev1 = dimsizes(lev1)
 hyam1 = inptr->hyam
 hybm1 = inptr->hybm
 hyai1 = inptr->hyai
 hybi1 = inptr->hybi
 o31 = inptr->O3
 tmp = inptr->PS
 interp = 2 ; log interpolation
 if (typeof(tmp).eq."double") then
        ps1 = dble2flt(tmp)
 else
     ps1 = tmp
 end if
 p0 = 1.e+05
 delete(tmp)
 press1 = pres_hybrid_ccm(ps1,p0,hyam1,hybm1)
 press1 = press1/100.
 pp1 = pres_hybrid_ccm(ps1,p0,hyai1,hybi1)
 pp1 = pp1/100.

; derive column ozone for model grid
 ; calculate to molec/cm3
; vertical scale to compute total ozone  in molec/cm^2
; We use:
;  INT( [O3] dz) = INT( mix(o3) M dz ) = -(1/g) INT( (M/rho) mix(o3) dp )
;                = alpha * INT(mix(o3) dp )
;  where
;  g = 9.81 m/sec^-2
;  M = dens air [molec/cm^3]
;  rho = dens air [g/cm^3]
;  z   = geometric height
;  p   = pressure [mbar]
;  so that :
;  alpha = 2.1e+22 molec / (mbar cm^2)
; ----
 delp = o31 
 do k=0,nlev1-1
    delp(:,k,:,:)=pp1(:,k+1,:,:)-pp1(:,k,:,:)
 end do
; set delp to zero where ozone is not included
if o3case.eq.0 then
else
 if o3case.eq.1 then
     if (isfilevar(inptr,"TROP_P"))
        tp_p = inptr->TROP_P 
        tp_p = tp_p/100.
        do la = 0,nlat1-1
         do lo = 0,nlon1-1
          delp(0,:,la,lo) = where(press1(0,:,la,lo).le.tp_p(0,la,lo),delp(0,:,la,lo),0.)
         end do
        end do
        print("burden above WMO tropoause pressure")
     else
        delp = where(o31.gt.150*1.e-09,delp,0.)
        print("burden above 150ppb ozone level")
     end if
 end if
 if o3case.eq.2 then
     if (isfilevar(inptr,"TROP_P"))
        tp_p = inptr->TROP_P 
        tp_p = tp_p/100.
        do la = 0,nlat1-1
         do lo = 0,nlon1-1
          delp(0,:,la,lo) = where(press1(0,:,la,lo).ge.tp_p(0,la,lo),delp(0,:,la,lo),0.)
         end do
        end do
        print("burden below WMO tropoause pressure")
     else
        delp = where(o31.lt.150*1.e-09,delp,0.)
        print("burden below 150ppb ozone level")
     end if
 end if
end if
 
 o3p = delp*o31
 copy_VarMeta(o31,o3p)
 o3colp =dim_sum_n_Wrap(o3p,1)
 o3col = o3colp * 2.1e+22
 o3col = o3col/2.69e16
 copy_VarMeta(o3colp,o3col)
if o3case.eq.0 then
  o3col@long_name = "Total Column Ozone"
else
 if o3case.eq.1 then
  o3col@long_name = "Stratospheric Column Ozone"
 end if
 if o3case.eq.2 then
  o3col@long_name = "Tropospheric Column Ozone"
 end if
end if
 
 o3col@units= "DU"


; interpolateO to lon/lat from OMI climatology 5x5
  lat_mid = fspan(-87.5,87.5,36)
  lon_mid = fspan(2.5,357.5,72)
  o3col_regrid = area_conserve_remap_Wrap (lon1,lat1,o3col(0,:,:), lon_mid,lat_mid, False)
  return(o3col_regrid) 
  delete(o3col)
  delete(o3col_regrid)
  delete(delp)
end

