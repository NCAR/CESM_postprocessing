 vv = ispan(0,nvars-1,1)
 mm = ispan(0,months-1,1)
 rr = ispan(0,nreg-1,1)

 d = new((/nvars,months,nlat1,nlon1/),"double")
 e = new((/nvars,months,nlat2,nlon2/),"double")

 A = new((/nvars,months,nreg/),"double")
 A!0 = "var"
 A&var = vv
 A!1 = "mons"
 A&mons = mm
 A!2 = "reg"
 A&reg = rr
 B = new((/nvars,months,nreg/),"double")
 copy_VarCoords(A,B)

 weights_1n = new((/nvars,nlat1,nlon1/),"double")
 weights_1n!0 = "var"
 weights_1n&var = vv
 weights_1n!1 = "lat"
 weights_1n&lat = lat1
 weights_1n!2 = "lon"
 weights_1n&lon = lon1
 if (fliplon1 .eq. "True") then
   weights_1n = lonFlip(weights_1n)
 end if
 weights_2n = new((/nvars,nlat2,nlon2/),"double")
 weights_2n!0 = "var"
 weights_2n&var = vv
 weights_2n!1 = "lat"
 weights_2n&lat = lat2
 weights_2n!2 = "lon"
 weights_2n&lon = lon2

;----------------------------------------------
; Loop over regions
;----------------------------------------------
 do ar = 0,nreg-1
;----------------------------------------------
; Loop over months
;----------------------------------------------
   do i = 0,months-1
;----------------------------------------------
;----------------------------------------------
; Normalized weights for each region and variable
;----------------------------------------------
     weights_1n = 0.
     do var = 0,nvars-1
        weights_1n (var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = \
              (area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
              fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))/ \
              sum(area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
              fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
     end do

     weights_2n = 0.
     if (compare .eq. "OBS") then
      do var = 0,nvars-1
        if (sum(area2(var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
               landmask2(var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})) \
               .gt. 0.) then
         weights_2n (var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = \
               (area2(var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
               landmask2(var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))/ \
               sum(area2(var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
               landmask2(var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
        else
           weights_2n (var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = 0.
        end if
      end do
     else
      do var = 0,nvars-1
         weights_2n (var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = \
               (area2({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
               fland2({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))/ \
               sum(area2({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
               fland2({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
      end do
     end if

;----------------------------------------------
; Regional averages
;----------------------------------------------
     do var = 0,nvars-1
       A(var,i,ar) = sum((d(var,i,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))* \
                  weights_1n(var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
       B(var,i,ar) = sum((e(var,i,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))* \
                  weights_2n(var,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
     end do
   end do  ; End month loop
 end do  ; End region loop
