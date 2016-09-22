load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment_diff.ncl"

begin

  file_netcdf_za = "za_"+file_netcdf
  cntrl_netcdf_za = "za_"+cntrl_netcdf

  nlev    = 21
  missing = 1.0e30

  global   = 0
  atlantic = 6
  pacific  = 2 
  indian   = 3 
  southern = 1 

  region_index = (/ global, atlantic, pacific, indian, southern /)
  n_reg = dimsizes(region_index)

  field_name = [/ "SSH", "HBLT", "HMXL" /] 

  fileid_1 = addfile(file_netcdf_za,"r")
  fileid_2 = addfile(cntrl_netcdf_za,"r")
  if (isfilevar(fileid_1,"DIA_DEPTH")) then
    ListPush(field_name,"DIA_DEPTH")
  end if
  if (isfilevar(fileid_1,"TLT")) then
    ListPush(field_name,"TLT")
  end if
  if (isfilevar(fileid_1,"INT_DEPTH")) then
    ListPush(field_name,"INT_DEPTH")
  end if

  n_fields = ListCount(field_name)
  print( " the number of fields to be processed is " +  n_fields)

  lat_t = fileid_1->lat_t
  z_t = fileid_1->z_t
  z_t = z_t / 1.0e5


  do n=0,n_fields-1

    fname = ListPop(field_name)
    field_1 = fileid_1->$fname$
    field_2 = fileid_2->$fname$

    if ( fname .eq. "SSH" ) then
      units = "cm" 
    else
      units = "m"
      field_1 = field_1 / 100.0
      field_2 = field_2 / 100.0
    end if

    print( " plotting zonal average of " + fname)

    ;wks = gsn_open_wks("x11",fname + "_GLO_za")
    wks = gsn_open_wks(img_format,fname+ "_GLO_za")
    gsn_define_colormap(wks,"table42")
    
    case_info = fname +" ZONAL-AVE (GLO) " + case_number + " " + time_info
    subt = cntrl_number+" "+cntrl_time_info+" in red"
    res = True
    res@tiMainFontHeightF = 0.022
    res@tiYAxisFontHeightF = 0.02
    res@tiXAxisFontHeightF = 0.02
    res@tiXAxisOffsetYF = -0.03
    res@tiMainString = case_info
    res@tiXAxisString = subt
    if (isvar("units")) then
      res@tiYAxisString = units
    else
      res@tiYAxisString = field@units
    end if
    res@vpHeightF = .5
    res@vpWidthF = .5 * 1.6
    res@gsnMaximize = True
    res@xyLineColors = (/"blue", "red"/)
    res@xyMonoDashPattern = True
    res@xyDashPattern = 0
    res@gsnYRefLine = 0.0
    res@gsnPaperOrientation = "portrait"

    data = new((/2,dimsizes(lat_t)/),float)
    data(0,:) = field_1(0,global,:)
    data(1,:) = field_2(0,global,:)
    plot = gsn_csm_xy(wks,lat_t,data,res)
    delete([/data,field_1,field_2/])
  end do

end
