load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment_diff.ncl"
load "$NCLPATH/contour_plot.ncl"

begin
  field_name  = [/"SSH", "HMXL", "HBLT"/]

  missing = 1.0e30

  fileid_1 = addfile(file_netcdf,"r")
  fileid_2 = addfile(cntrl_netcdf,"r")

  if (isfilevar(fileid_1,"DIA_DEPTH")) then
    ListPush(field_name,"DIA_DEPTH")
  end if
  if (isfilevar(fileid_1,"TLT")) then
    ListPush(field_name,"TLT")
  end if
  if (isfilevar(fileid_1,"INT_DEPTH")) then
    ListPush(field_name,"INT_DEPTH")
  end if
  if (isfilevar(fileid_1,"SU")) then
    ListPush(field_name,"SU")
  end if
  if (isfilevar(fileid_1,"SV")) then
    ListPush(field_name,"SV")
  end if
  if (isfilevar(fileid_1,"BSF")) then
    ListPush(field_name,"BSF")
  end if

  n_fields = ListCount(field_name)
  print( " the number of fields to be processed is " +  n_fields)

  days_in_norm_year = fileid_1->days_in_norm_year
  sflux_factor = fileid_1->sflux_factor
  salinity_factor = fileid_1->salinity_factor
  rho_sw = fileid_1->rho_sw * 1000.0
  l_f = fileid_1->latent_heat_fusion / 1e4
  tlat = fileid_1->TLAT
  tlon = fileid_1->TLONG
  sizes = dimsizes(tlon)
  nx = sizes(1)
  ny = sizes(0)
  kmt = fileid_1->KMT
  kmu = fileid_1->KMU
  region_mask = fileid_1->REGION_MASK
  tarea = fileid_1->TAREA
  uarea = fileid_1->UAREA
  angle = fileid_1->ANGLE

  do n=0,n_fields-1 

    contourline = 3
    fname = ListPop(field_name)
    field_1 = fileid_1->$fname$
    field_2 = fileid_2->$fname$
    if (dimsizes(dimsizes(field_1)) .eq. 3) then
      tmp = field_1(0,:,:)
      delete(field_1)
      field_1 = tmp
      delete(tmp)
    end if
    if (dimsizes(dimsizes(field_2)) .eq. 3) then
      tmp = field_2(0,:,:)
      delete(field_2)
      field_2 = tmp
      delete(tmp)
    end if
    area = tarea

    if ( fname .eq. "SU" ) then
      area = uarea
      if (dimsizes(getfilevardims(fileid_1,"SV")) .eq. 3) then
        tmp_field = fileid_1->SV(0,:,:)
      else
        tmp_field = fileid_1->SV
      end if
      field_1 = tofloat(field_1* cos(angle) + tmp_field * sin(-angle))
      field_1 = where (abs(field_1) .gt. 1.0e10, field_1@_FillValue, field_1)

      if (dimsizes(getfilevardims(fileid_2,"SV")) .eq. 3) then
        tmp_field = fileid_2->SV(0,:,:)
      else
        tmp_field = fileid_2->SV
      end if
      field_2 = tofloat(field_2 * cos(angle) + tmp_field * sin(-angle))
      field_2 = where (abs(field_2) .gt. 1.0e10, field_2@_FillValue, field_2)
    end if
    if ( fname .eq. "SV" ) then 
      area = uarea
      if (dimsizes(getfilevardims(fileid_1,"SU")) .eq. 3) then
        tmp_field = fileid_1->SU(0,:,:)
      else
        tmp_field = fileid_1->SU
      end if
      field_1 = tofloat(field_1* cos(angle) + tmp_field * sin(-angle))
      field_1 = where (abs(field_1) .gt. 1.0e10, field_1@_FillValue, field_1)

      if (dimsizes(getfilevardims(fileid_2,"SU")) .eq. 3) then
        tmp_field = fileid_2->SU(0,:,:)
      else
        tmp_field = fileid_2->SU
      end if
      field_2 = tofloat(field_2 * cos(angle) + tmp_field * sin(-angle))
      field_2 = where (abs(field_2) .gt. 1.0e10, field_2@_FillValue, field_2)
    end if

    dmin = missing 
    dmax = missing 
    dmin_diff = missing
    dmax_diff = missing
    if ( fname .eq. "HMXL"       .or. \
      fname .eq. "HBLT"       .or. \
      fname .eq. "DIA_DEPTH"  .or. \
      fname .eq. "INT_DEPTH" ) then
      dmin  =   0.0
      dmax  = 400.0
      dmin_diff = -40.0
      dmax_diff =  40.0
      units = "m"
      field_1 = field_1 / 100. 
      field_2 = field_2 / 100. 
      contourline = 2
    end if
    if ( fname .eq. "SSH" ) then
      dmin  = -200.0
      dmax  =  200.0
      dmin_diff =  -20.0
      dmax_diff =   20.0
      units = "cm"
    end if
    if ( fname .eq. "TLT" ) then
      dmin  =   0.0
      dmax  = 40.0
      dmin_diff =  -10.0
      dmax_diff =   10.0
      units = "m"
      field_1 = field_1 / 100.
      field_2 = field_2 / 100.
      contourline = 2
    end if
    if ( fname .eq. "SU"  .or. fname .eq. "SV" ) then 
      dmin  = -40.0
      dmax  =  40.0
      dmin_diff = -6.0
      dmax_diff =  6.0
      units = "x10~S~5~N~ cm~S~2~N~ s~S~-1~N~"
      field_1 = field_1 / 1.0e5
      field_2 = field_2 / 1.0e5
      contourline = 2
    end if
    if ( fname .eq. "BSF" ) then
      dmin  = -80.
      dmax  =  200.
      dmin_diff =  -20.
      dmax_diff =   20.
      units = "Sv"
      contourline = 1
    end if  

    if ( dmin      .eq. missing  .or.  dmax      .eq. missing ) then 
      print( " user must set the contour limits .... ")
    end if

    field_diff = field_1 - field_2

    if (iscoord(field_1,"ULONG")) then
      ugrid = True
    else
      ugrid = False
    end if

    nlev = 21
    dlev = (dmax-dmin)/(nlev-1) 
    lev  = dmin + ispan(0,nlev-1,1)*dlev
    dlev_diff = (dmax_diff-dmin_diff)/(nlev-1) 
    lev_diff  = dmin_diff + ispan(0,nlev-1,1)*dlev_diff

    print( " plotting ..... " + fname)

    ;wks = gsn_open_wks("x11",fname)
    wks = gsn_open_wks(img_format,fname)
    gsn_define_colormap(wks,"table42")

    coltab = new(nlev + 1,"integer")
    coltab(0) = 1
    color1 = 2 
    coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1
    coltab(0) = 0

    case_info = fname+" " + case_number + " " + time_info
    case_info_diff = case_number+" "+time_info+" - "+cntrl_number+" "+cntrl_time_info

    opt = True
    opt@charsize = 0.9
    opt@landcolor = lndcolor
    opt@contourline = contourline
    opt@xrange = (/ xr0,xr1/)
    opt@yrange = (/ yr0,yr1/)
    opt@do_panel = True
    opt@gsnRightStringParallelPosF = 1.2
    opt@cnLineLabelsOn = True

    if (ugrid) then
      lon = fileid_1->ULONG
      lat = fileid_1->ULAT
    else
      lon = tlon
      lat = tlat
    end if
    plot1 = contour_plot(wks, field_1, lon, lat, kmt, region_mask, area, case_info, \
    missing, units, dlev, lev, coltab, opt)

    if (opt@do_panel) then
      opt@contourline = 2
      plot2 = contour_plot(wks, field_diff, lon, lat, kmt, region_mask, area, case_info_diff, \
      missing, units, dlev_diff, lev_diff, coltab, opt)

      gsn_panel(wks, (/plot1,plot2/), (/2,1/),False)
    end if
    delete([/lev,coltab,field_1,lev_diff,field_2/])

  end do

end
