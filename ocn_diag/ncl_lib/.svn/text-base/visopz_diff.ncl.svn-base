load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/contour_plot.ncl"

begin

   print( " plotting VISOP at "+ n_depth + " depth levels")
   
   fileid_1 = addfile(file_netcdf,"r")
   visop_1 = fileid_1->VISOP
   if (isatt(visop_1,"_FillValue"))
      missing = visop_1@_FillValue
   else
      missing = 1e30
   end if
   units = visop_1@units
   uisop_1 = fileid_1->UISOP
   
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
   visop_2 = fileid_2->VISOP
   uisop_2 = fileid_2->UISOP

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

     if (dimsizes(dimsizes(visop_1)) .eq. 4) then
        field_1_1 = visop_1(0,klev,:,:)
     else
        field_1_1 = visop_1(klev,:,:)
     end if
     if (dimsizes(dimsizes(uisop_1)) .eq. 4) then
        field_2_1 = uisop_1(0,klev,:,:)
     else
        field_2_1 = uisop_1(klev,:,:)
     end if
     if (dimsizes(dimsizes(visop_1)) .eq. 4) then
        field_1_2 = visop_2(0,klev,:,:)
     else
        field_1_2 = visop_2(klev,:,:)
     end if
     if (dimsizes(dimsizes(uisop_1)) .eq. 4) then
        field_2_2 = uisop_2(0,klev,:,:)
     else
        field_2_2 = uisop_2(klev,:,:)
     end if

     ; rotate vector
     field_1 = tofloat(field_1_1 * cos(angle) - field_2_1 * sin(-angle))
     field_2 = tofloat(field_1_2 * cos(angle) - field_2_2 * sin(-angle))

     field_diff = field_1
     field_diff = field_1 - field_2

;
;    "gauss" level type not supported yet
;
     if (cntrlvls .eq. "gauss") then
       print ("'gauss' CNTRLVLS not currently supported in NCL version of OMWG: using 'std' method") 
     end if

     if ( zdep .le. 200. ) then
       dmin = -10.0
       dmax = 10.0
       dmin_diff =  -2.0
       dmax_diff =   2.0
     else if (zdep .le.   800.) then
       dmin = -5.0
       dmax =  5.0
       dmin_diff = -1.0
       dmax_diff =  1.0
     else
       dmin = -2.0
       dmax =  2.0
       dmin_diff = -0.5
       dmax_diff =  0.5
     end if
     end if
     dlev = (dmax-dmin) / (nlev - 1)
     lev  = dmin + ispan(0,nlev-1,1)*dlev
     dlev_diff = (dmax_diff-dmin_diff) / (nlev - 1)
     lev_diff  = dmin_diff + ispan(0,nlev-1,1)*dlev_diff

     depstr = sprintf("%.0f",dep)
     zdepstr = sprintf("%6.1fm",zdep)
     case_info = "VISOP at z="+zdepstr+", " + case_number + " " + time_info 
   
     ;wks = gsn_open_wks("x11","VISOP"+depstr)
     wks = gsn_open_wks(img_format,"VISOP"+depstr)
     gsn_define_colormap(wks,"table42")
   
     units = "cm s~S~-1~N~"
     opt = True
     opt@charsize = 0.9
     opt@landcolor = lndcolor
     opt@contourline = 2
     opt@xrange = (/ xr0,xr1/)
     opt@yrange = (/ yr0,yr1/)
     opt@do_panel = True
     opt@gsnRightStringParallelPosF = 1.2

     plot1 = contour_plot(wks, field_1, tlon, tlat, kmt, region_mask, tarea, case_info, \
               	          missing, units, dlev, lev, coltab, opt)

     case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info

     plot2 = contour_plot(wks, field_diff, tlon, tlat, kmt, region_mask, tarea, case_info_diff, \
                          missing, units, dlev_diff, lev_diff, coltab, opt)

     gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)
   end do
   
end
   
