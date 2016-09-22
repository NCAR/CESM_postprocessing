load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

   print( " plotting KAPPA_THIC at "+ n_depth + " depth levels")
   
   fileid_1 = addfile(file_netcdf,"r")
   kappa_thic_1 = fileid_1->KAPPA_THIC
   if (isatt(kappa_thic_1,"_FillValue"))
      missing = kappa_thic_1@_FillValue
   else
      missing = 1e30
   end if
   units = kappa_thic_1@units
   
   tlon = fileid_1->TLONG
   tlat = fileid_1->TLAT
   size = dimsizes(tlon)
   nx = size(1)
   ny = size(0)
   ulon = fileid_1->ULONG
   ulat = fileid_1->ULAT
   kmt = fileid_1->KMT
   kmu = fileid_1->KMU
   region_mask = fileid_1->REGION_MASK
   tarea = fileid_1->TAREA
   uarea = fileid_1->UAREA
   angle = fileid_1->ANGLE
   anglet = fileid_1->ANGLET
   z_t = fileid_1->z_t
   nz = dimsizes(z_t)
   z_t = z_t / 100.

   fileid_2 = addfile(cntrl_netcdf,"r")
   kappa_thic_2 = fileid_2->KAPPA_THIC

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
     if (dimsizes(dimsizes(kappa_thic_1)) .eq. 4) then
        field_1 = kappa_thic_1(0,klev,:,:)
     else
        field_1 = kappa_thic_1(klev,:,:) 
     end if
     field_1 = field_1 / 1e4
     if (dimsizes(dimsizes(kappa_thic_2)) .eq. 4) then
        field_2 = kappa_thic_2(0,klev,:,:)
     else
        field_2 = kappa_thic_2(klev,:,:) 
     end if
     field_2 = field_2 / 1e4

     field_diff = field_1
     field_diff = field_diff - field_2

     dlev = new(1,"float")
     lev = (/ 0.,  20.,  40.,  60.,   80.,  100.,  200.,  300.,  400.,  500., \
          600., 700., 800., 900., 1000., 1200., 1400., 1600., 1800., 2000., \
          3000. /)
     dmin_diff = -400.0
     dmax_diff =  400.0
     dlev_diff = (dmax_diff-dmin_diff)/(nlev-1)
     lev_diff  = dmin_diff + ispan(0,nlev-1,1) *dlev_diff

     depstr = sprintf("%.0f",dep)
     zdepstr = sprintf("%6.1fm",zdep)
     case_info = "KAPPA_THIC at z="+zdepstr+", " + case_number + " " + time_info 
   
     ;wks = gsn_open_wks("x11","KAPPA_THIC"+depstr)
     wks = gsn_open_wks(img_format,"KAPPA_THIC"+depstr)
     gsn_define_colormap(wks,"table42")
   
     units = "m~S~2~N~ s~S~-1~N~"
     opt = True
     opt@charsize = 0.9
     opt@landcolor = lndcolor
     opt@contourline = 3
     opt@cnLineLabelsOn = True
     opt@gsnMajorLonSpacing = 60
     opt@gsnLeftStringFontHeightF = 0.014
     opt@gsnRightStringFontHeightF = 0.012
     opt@gsnRightStringParallelPosF = 1.2
     opt@xrange = (/ xr0,xr1/)
     opt@yrange = (/ yr0,yr1/)
     opt@do_panel = True

     plot1 = contour_plot(wks, field_1, tlon, tlat, kmt, region_mask, tarea, case_info, \
               	          missing, units, dlev, lev, coltab, opt)

     case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info

     opt@contourline = 2
     plot2 = contour_plot(wks, field_diff, tlon, tlat, kmt, region_mask, tarea, case_info_diff, \
                         missing, units, dlev_diff, lev_diff, coltab, opt)

     gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)

   end do
   
end
   
