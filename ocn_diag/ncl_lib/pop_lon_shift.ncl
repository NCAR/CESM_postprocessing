function pop_lon_shift(arr,n)
begin
   temp=arr
   size = dimsizes(arr)
   nd = dimsizes(size)
   nx = size(nd-1)
   if (nd .eq. 1) then
         arr(0:nx-1-n)=temp(n:nx-1)
         arr(nx-n:nx-1)=temp(0:n-1)
   else if (nd .eq. 2) then
         arr(:,0:nx-1-n)=temp(:,n:nx-1)
         arr(:,nx-n:nx-1)=temp(:,0:n-1)
   else if (nd .eq. 3) then
         arr(:,:,0:nx-1-n)=temp(:,:,n:nx-1)
         arr(:,:,nx-n:nx-1)=temp(:,:,0:n-1)
   else if (nd .eq. 4) then
         arr(:,:,:,0:nx-1-n)=temp(:,:,:,n:nx-1)
         arr(:,:,:,nx-n:nx-1)=temp(:,:,:,0:n-1)
   end if
   end if
   end if
   end if
   return arr
end

