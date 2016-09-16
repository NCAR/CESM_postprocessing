; plot_paleo.ncl
; thanks to Christine
begin
 model_file = getenv("MODELFILE")
 data_file = getenv("PALEODATA")
 land_mask = getenv("LANDMASK")
 landmask = stringtofloat(land_mask)
 
 in = addfile(model_file,"r")
 lat = in->lat
 lon = in->lon

 if (isfilevar(in,"ORO")) then
   oro = in->ORO(0,:,:)            ; (lat,lon)
 else
   landfrac = in->LANDFRAC(0,:,:)  ; (lat,lon)
   nlat = dimsizes(lat)
   nlon = dimsizes(lon)
   oro = new((/nlat,nlon/),integer)
   oro = 1
   oro@_FillValue = 0
   oro = mask(oro,landfrac.ge.0.5,True) 
 end if

 paleo_outline (oro,lat,lon,landmask,data_file)

end
