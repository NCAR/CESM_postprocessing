; NCL script
; function_calc_mopitt_column_co.ncl
; Simone Tilmes,Novb 2013
;**************************************

; read MOPITT
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH

function function_calc_mopitt_column_co(inptr,f1,mo)
begin
; get MOPITT information
;dir = "/Users/tilmes/DATA/MOPITT/"
;f_mo = "v6j_co_colm_clim.2003_2012.nc"
;f1 = addfile(dir+f_mo,"r")
 lat_mop = f1->latitude
 lon_mop = f1->longitude
 lon_mop = f1->longitude
 nlat_mop = dimsizes(lat_mop)
 nlon_mop = dimsizes(lon_mop)
 var = "surface pressure"
 spress = f1->$var$
 var = "retrieved CO total column"
 cocol_retr = f1->$var$
 var = "a priori CO total column"
 cocol_a_priori = f1->$var$
 var = "retrieved CO profile"
 coprof_retr = f1->$var$
 var = "a priori CO profile"
 coprof_a_priori = f1->$var$
 var = "CO total column averaging kernel"
 avkernel = f1->$var$
 C_clim_mop1 = new((/nlon_mop,nlat_mop/),"float")


 lev1 = inptr->lev
 lat1 = inptr->lat
 lon1 = inptr->lon
 nlat1 = dimsizes(lat1)
 nlon1 = dimsizes(lon1)
 nlev1 = dimsizes(lev1)
 hyam1 = inptr->hyam
 hybm1 = inptr->hybm
 co1 = inptr->CO
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


; interpolate CO to lon/lat from MOPITT climatology 5x5
  co1_climo_regrid = area_conserve_remap_Wrap (lon1,lat1,co1(0,:,:,:), lon_mop,lat_mop, False)
  p1_regrid = area_conserve_remap_Wrap (lon1,lat1,press1(0,:,:,:), lon_mop,lat_mop, False)
  p1_regrid!1 = "lev"

  plvMOPITT = p1_regrid(0:10,:,:)
  plvMOPITT1 = new(11,"float")
  plvMOPITT1(0:9) = fspan(1000.,100.,10)
  plvMOPITT1(10) = 50
  plvMOPITT = conform(plvMOPITT,plvMOPITT1,0)
  plvMOPITT(0,:,:) = where(p1_regrid(nlev1-1,:,:).gt.900.,p1_regrid(nlev1-1,:,:),1000.)
  linlog = 0
; interpolate CO to pressure levels
  co_climo1 =  int2p_n_Wrap (p1_regrid(:,:,:),co1_climo_regrid(:,:,:),plvMOPITT,linlog,0)
  co_climo_layer = co_climo1
  do l = 0, 9
    co_climo_layer(l,:,:) = dim_avg_n_Wrap(co_climo1(l:l+1,:,:),0)
  end do

  ap_mopit = coprof_a_priori(mo,:,:,:)
  ap_mopit@_FillValue = -999
  cocol_a_priori@_FillValue = -999
  avkernel@_FillValue = -999
  log_ap = log10(ap_mopit*1.e-09)
  log_co = log10(transpose(co_climo_layer(0:9,:,:)))
  do la = 0, nlat_mop -1
   do lo = 0, nlon_mop -1
  ; print(avkernel(mo,lo,la,:))
  ; print(log_ap(lo,la,:))
    if (.not.all(ismissing(avkernel(mo,lo,la,:)))) then
  ;  print(la)
     in1 = ind(avkernel(mo,lo,la,:).ne.avkernel@_FillValue .and. log_co(lo,la,:).lt.9.96921e+36)
     avkernel1 = avkernel(mo,lo,la,in1)
     log_co1 = log_co(lo,la,in1)
     log_ap1 = log_ap(lo,la,in1)
     C_clim_mop1(lo,la) = cocol_a_priori(mo,lo,la)  + avkernel1 # (log_co1 - log_ap1)
   ; if dimsizes(in1).lt.10 .and. dimsizes(in1).gt.0 then 
   ;   print(C_clim_mop1(lo,la))
   ;   print(avkernel1)
   ;   print(log_ap1)
   ;   print(log_co1)
   ;   a = log_co1 - log_ap1
   ;   print(a)
   ;   b = avkernel1 # (log_co1 - log_ap1)
   ; end if
     delete(in1)
     delete(avkernel1)
     delete(log_co1)
     delete(log_ap1)
;    if C_clim_mop1(lo,la).eq.C_clim_mop1@_FillValue then
;     print(cocol_a_priori(mo,lo,la)) 
;     print(log_co(lo,la,:)) 
;     print(log_ap(lo,la,:))
;     print(ap_mopit(lo,la,:)) 
;     print(C_clim_mop1(lo,la)) 
;    end if
    end if 
   end do
  end do
  delete(co_climo_layer)
  delete(co1_climo_regrid)
  delete(p1_regrid)
  delete(log_ap)
  delete(log_co)
  delete(plvMOPITT)
; C_clim_mop1@_FillValue=-9.990001e-16
; C_clim_mop1 = where(C_clim_mop1.eq."nan",C_clim_mop1@_FillValue,C_clim_mop1)
  return(C_clim_mop1) 
end

