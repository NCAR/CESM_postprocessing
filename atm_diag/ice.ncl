load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;;;load "/fs/cgd/data0/stevens/DIAG/timeseries/icearea.ncl"

begin
wkdir = getenv("WKDIR")+"/"
case = getenv("CASENAME")
cname = getenv("CNAME")
yr0 = getenv("BEGINYR")
yr1 = getenv("FIRSTYR")
yr2 = getenv("LASTYR")
mnths = getenv("MNTHS")

beginyr = stringtointeger(yr0)
firstyr = stringtointeger(yr1)
lastyr = stringtointeger(yr2)

newyrs = lastyr-firstyr+1
if (firstyr .gt. beginyr) then
  oldyrs = firstyr-beginyr
  nyrs = oldyrs + newyrs 
  prevyr = firstyr-1
else                        ; firstyr = beginyr
  nyrs = newyrs 
end if
means = new((/2,nyrs/),"string")

; if the file exists read the old data from the previous oldyrs
if (firstyr .gt. beginyr) then
  filename = wkdir+cname+".sh.icefrac."+yr0+"-00"+prevyr
  means(0,0:oldyrs-1) = asciiread(filename,oldyrs,"string")
  filename = wkdir+cname+".nh.icefrac."+yr0+"-00"+prevyr
  means(1,0:oldyrs-1) = asciiread(filename,oldyrs,"string")
end if

; read the new data from the newyrs
files = asciiread(wkdir+"work.files",newyrs,"string")
f= addfiles(files,"r")
icefrac = addfiles_GetVar(f,files,"ICEFRAC")

if (isfilevar(f[0],"slat")) then   ; finite volume
  do yr = firstyr, lastyr
    means(0,yr-beginyr)= yr+" "+iceareaFIX(icefrac(yr-firstyr,:,:),0) ; SH 
    means(1,yr-beginyr)= yr+" "+iceareaFIX(icefrac(yr-firstyr,:,:),1) ; NH 
  end do
else
  do yr = firstyr, lastyr
    means(0,yr-beginyr)= yr+" "+iceareaGAU(icefrac(yr-firstyr,:,:),0) ; SH 
    means(1,yr-beginyr)= yr+" "+iceareaGAU(icefrac(yr-firstyr,:,:),1) ; NH 
  end do
end if
asciiwrite(wkdir+cname+".sh.icefrac."+yr0+"-"+yr2,means(0,:))
asciiwrite(wkdir+cname+".nh.icefrac."+yr0+"-"+yr2,means(1,:))

end
