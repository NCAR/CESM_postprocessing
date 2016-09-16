load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

   print( " plotting KAPPA_ISOP at "+ n_depth + " depth levels")
   
   fileid = addfile(file_netcdf,"r")
   kappa_isop = fileid->KAPPA_ISOP
   if (isatt(kappa_isop,"_FillValue"))
      missing = kappa_isop@_FillValue
   else
      missing = 1e30
   end if
   units = kappa_isop@units
   uvel = fileid->UVEL
   
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

     if (dimsizes(dimsizes(kappa_isop)) .eq. 4) then
        field = kappa_isop(0,klev,:,:)
     else
        field = kappa_isop(klev,:,:) 
     end if
     field = field / 1e4

     dlev = new(1,"float")
     lev = (/ 0.,  20.,  40.,  60.,   80.,  100.,  200.,  300.,  400.,  500., \
          600., 700., 800., 900., 1000., 1200., 1400., 1600., 1800., 2000., \
          3000. /)

     depstr = sprintf("%.0f",dep)
     zdepstr = sprintf("%6.1fm",zdep)
     case_info = "KAPPA_ISOP at z="+zdepstr+", " + case_number + " " + time_info 
   
    ;wks = gsn_open_wks("x11","KAPPA_ISOP"+depstr)
     wks = gsn_open_wks(img_format,"KAPPA_ISOP"+depstr)
     gsn_define_colormap(wks,"table42")
   
     units = "m~S~2~N~ s~S~-1~N~"
     opt = True
     opt@charsize = 0.9
     opt@landcolor = lndcolor
     opt@contourline = 3
     opt@cnLineLabelsOn = False
     opt@aspect_ratio = 1.2
     opt@gsnMajorLonSpacing = 60
     opt@gsnLeftStringFontHeightF = 0.014
     opt@gsnRightStringFontHeightF = 0.012
     opt@gsnRightStringParallelPosF = 1.2
     opt@xrange = (/ xr0,xr1/)
     opt@yrange = (/ yr0,yr1/)
    
     plot1 = contour_plot(wks, field, tlon, tlat, kmt, region_mask, tarea, case_info, \
               	          missing, units, dlev, lev, coltab, opt)
   end do
   
end
   
