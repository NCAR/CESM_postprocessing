function pop_eq_avg(arr,y0,y1,miss)
;; averages a POP field (arr) to get field
;; 	defined on the Equator (straddled by
;;	meridional indicies y0, y1).
;;
;; assumes meridional dimension is second!!
begin
   size = dimsizes(arr)
   nd = dimsizes(size)
   nx = size(nd-1)
   ny = size(nd-2)
   if (nd .eq. 2) then
      tmp1 = arr(y0,:)
      tmp2 = arr(y1,:)
      out = 0.5 * tmp1 + 0.5 * tmp2
   else if (nd .eq. 3) then
      nz = size(0)
      tmp1 = arr(:,y0,:)
      tmp2 = arr(:,y0,:)
      out = 0.5 * tmp1 + 0.5 * tmp2
   else
      print("wrong dimensions for pop_eq_avg")
   end if
   end if
   
   return out
end

