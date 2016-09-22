load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/eos.ncl"

begin
  file_T = getenv("CNTRLSEASAVGTEMP")
  file_S = getenv("CNTRLSEASAVGSALT")
  file_out = getenv("CNTRLSEASAVGRHO")

  fileid = addfile(file_T,"r")
  TLONG = fileid->TLONG
  TLAT = fileid->TLAT
  z_t = fileid->z_t
  time = fileid->time
  TEMP = fileid->TEMP

  fileid = addfile(file_S,"r")
  SALT = fileid->SALT

  size = dimsizes(TEMP)
  nx = size(3)
  ny = size(2)
  nz = size(1)
  nt = size(0)

  missing_value = 98d

  PD = new(dimsizes(TEMP),double)

  do n = 0, nt - 1
    do k = 0, nz - 1 
      print("month = " + (n+1) + " level = " + (k+1))
      opt = False
      PD(n,k,:,:) = (eos(TEMP(n,k,:,:),SALT(n,k,:,:),0,opt) - 1.0d) * 1000.0d
    end do
  end do

  PD@missing_value = missing_value - 1.
  PD@_FillValue = PD@missing_value

  fileid = addfile(file_out,"c")

  dim_names = (/ "time","z_t","lat","lon"/)
  dim_sizes = (/ nt, nz, ny, nx /)
  dim_unlim = (/ False, False, False, False /)
  filedimdef(fileid,dim_names,dim_sizes,dim_unlim)

  filevardef(fileid,"time",typeof(time),getvardims(time))
  filevardef(fileid,"z_t",typeof(z_t),getvardims(z_t))
  filevardef(fileid,"TLAT",typeof(TLAT),(/"lat","lon"/))
  filevardef(fileid,"TLONG",typeof(TLONG),(/"lat","lon"/))
  filevardef(fileid,"PD",typeof(PD),(/ "time","z_t","lat","lon"/))

  time@long_name = "Month Index"
  TLAT@long_name = "Latitude (T grid)"
  TLONG@long_name = "Longitude (T grid)"
  PD@long_name = "Potential density referenced to surface"
  PD@coordinates = "time z_t lat lon"
  filevarattdef(fileid,"time",time)
  filevarattdef(fileid,"z_t",z_t)
  filevarattdef(fileid,"TLAT",TLAT)
  filevarattdef(fileid,"TLONG",TLONG)

  PD@units = "sigma"


  filevarattdef(fileid,"PD",PD)

  gatt = True
  gatt@Title = "PHC2 potential density computed on the Levitus grid"
  fileattdef(fileid,gatt)

  fileid->time = (/time/)
  fileid->z_t = (/z_t/)
  fileid->TLAT = (/TLAT/)
  fileid->TLONG = (/TLONG/)
  fileid->PD = (/PD/)

end
