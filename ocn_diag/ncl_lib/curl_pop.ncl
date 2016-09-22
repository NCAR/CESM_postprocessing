
function curl_pop( k, ux, uy, dxu, dyu, tarea, kmt, missing) 

;================================================================
;
;   z-curl operator on vector fields defined at U-points:
;
;   z-curl(Ux,Uy) =  (1/dy)*Dx[Ay(dy*Uy)] - (1/dx)*Dy[Ax(dx*Ux)]
; 
; * this is the same discretization as in POP.
;
; * this routine returns curl (in N/m^3) computed at T-points.
;
;================================================================
begin
; array size checks

  sx = dimsizes(ux)
  sy = dimsizes(uy)

  if (.not. all(sx .eq. sy)) then
    print ("vector field components have incorrect size")
  end if

  if (.not. all(dimsizes(dxu).eq.sx)) then
    print ("DXU has incorrect dimension size")
  end if 
  if (.not. all(dimsizes(dyu).eq.sx)) then
    print ("DXU has incorrect dimension size")
  end if
  if (.not. all(dimsizes(tarea).eq.sx)) then
    print ("DXU has incorrect dimension size")
  end if
  if (.not. all(dimsizes(kmt).eq.sx)) then
    print ("DXU has incorrect dimension size")
  end if
  if (.not. isatt(uy,"_FillValue")) then
    uy@_FillValue = default_fillvalue(typeof(uy))
  end if
  if (.not. isatt(ux,"_FillValue")) then
    ux@_FillValue = default_fillvalue(typeof(ux))
  end if
  workx = 0.5 * uy * dyu
  worky = -0.5 * ux * dxu
  curl = new(sx,float)

  curl(1:,1:) = tofloat(workx(1:,1:) + workx(:sx(0)-2,1:) - workx(1:,:sx(1)-2) - workx(:sx(0)-2,:sx(1)-2) \
                        + worky(1:,1:) + worky(1:,:sx(1) -2) - worky(:sx(0)-2,1:) - worky(:sx(0)-2,:sx(1)-2))

; convert to N/m^3 and divide by area

  curl = tofloat(10. * curl / tarea)


  curl = where (k .gt. kmt,curl@_FillValue,curl)

  curl(0,:) = curl@_FillValue
  curl(:,0) = curl(:,sx(1)-1)

  return curl
end
