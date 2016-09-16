load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin
   print ( " plotting VELOCITY vectors at " + n_depth + " depth levels")

   fileid = addfile(file_netcdf,"r")
   uvel = fileid->UVEL
   if (isatt(uvel,"_FillValue"))
      missing = uvel@_FillValue
   else
      missing = 1e30
   end if
   units = uvel@units
   vvel = fileid->VVEL
   
   tlon = fileid->TLONG
   tlat = fileid->TLAT
   size = dimsizes(tlon)
   nx = size(1)
   ny = size(0)
   ulon = fileid->ULONG
   ulat = fileid->ULAT
   kmt = fileid->KMT
   kmu = fileid->KMU
   region_mask = fileid->REGION_MASK
   tarea = fileid->TAREA
   uarea = fileid->UAREA
   angle = fileid->ANGLE
   anglet = fileid->ANGLET
   z_t = fileid->z_t
   nz = dimsizes(z_t)
   z_t = z_t / 100.

   nlev = 21
   coltab = new(nlev + 1,"integer")
   color1 = 2 
   coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
   coltab(0) = 0

   do l=0, n_depth-1
     dep =  depth(l)
     min_diff = min(abs(z_t - dep))
     klev_arr = ind(abs(dep-z_t) .eq. min_diff) ; if 2 depth are equally distant you get an array
     klev = klev_arr(0)
     delete(klev_arr)
     zdep = z_t(klev)
     if (dimsizes(dimsizes(uvel)) .eq. 4) then
        ufield = uvel(0,klev,:,:)
     else
        ufield = uvel(klev,:,:)
     end if
     if (dimsizes(dimsizes(vvel)) .eq. 4) then
        vfield = vvel(0,klev,:,:)
     else
        vfield = vvel(klev,:,:)
     end if
     ; rotate vector
     ufield = tofloat(ufield * cos(angle) + vfield * sin(-angle))
     vfield = tofloat(vfield * cos(angle) - ufield * sin(-angle))
     mag = sqrt(ufield * ufield + vfield * vfield)

     nlev = 21
     dmin = 0.0
     if ( zdep .le. 200 ) then 
        dmax =  50.0
        refval = 25.
     else if (zdep .le. 800) then
        dmax =  20.0
        refval = 10.
     else if (zdep .le. 1500 ) then
        dmax =  10.0
        refval = 5.
     else 
        dmax =  5.0
        refval = 2.5
     end if
     end if
     end if
     dlev = (dmax-dmin) / (nlev - 1)
     lev  = dmin + ispan(0,nlev-1,1)*dlev

     depstr = sprintf("%.0f",dep)
     zdepstr = sprintf("%6.1fm",zdep)
     casestr = "VELOCITY at z="+zdepstr+", " + case_number + " " + time_info 
   
     ;wks = gsn_open_wks("x11","VELOCITY" +depstr)
     wks = gsn_open_wks(img_format,"VELOCITY" +depstr)
     gsn_define_colormap(wks,"table42")
   
     units = "cm s~S~-1~N~"
     opt = True
     opt@charsize = 0.9
     opt@landcolor = lndcolor
     opt@contourline = 2
     opt@xrange = (/ xr0,xr1/)
     opt@yrange = (/ yr0,yr1/)
     opt@do_panel = True

     plot1 = contour_plot(wks, mag, tlon, tlat, kmt, region_mask, tarea, casestr, \
               	          missing, units, dlev, lev, coltab, opt)

     res = True
     res@gsnDraw = False
     res@gsnFrame = False
     res@gsnMaximize = True
     res@gsnPaperOrientation = "portrait"
     res@vfXArray = ulon
     res@vfYArray = ulat
     res@vcMinDistanceF = 0.015
     res@vcRefMagnitudeF = refval 
     res@vcRefLengthF = .02
     res@vcRefAnnoString1 = "$VMG$" + " cm / s"
     res@vcRefAnnoOrthogonalPosF = -.08
     res@vcMinFracLengthF = .15 

     vec_plot = gsn_vector(wks,ufield,vfield,res)
     overlay(plot1,vec_plot)
     draw(plot1)
     frame(wks)
   end do
   
end
