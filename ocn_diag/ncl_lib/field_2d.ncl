load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin
  field_name  = [/"HMXL", "HBLT", "SU", "SV", "BSF" /]

  missing = 1.0e30

  fileid = addfile(file_netcdf,"r")
  if (isfilevar(fileid,"DIA_DEPTH")) then
    ListPush(field_name,"DIA_DEPTH")
  end if
  if (isfilevar(fileid,"TLT")) then
    ListPush(field_name,"TLT")
  end if
  if (isfilevar(fileid,"INT_DEPTH")) then
    ListPush(field_name,"INT_DEPTH")
  end if

  n_fields = ListCount(field_name)
  print( " the number of fields to be processed is " +  n_fields)

  days_in_norm_year = fileid->days_in_norm_year
  sflux_factor = fileid->sflux_factor
  salinity_factor = fileid->salinity_factor
  rho_sw = fileid->rho_sw * 1000.0
  l_f = fileid->latent_heat_fusion / 1e4
  tlat = fileid->TLAT
  tlon = fileid->TLONG
  sizes = dimsizes(tlon)
  nx = sizes(1)
  ny = sizes(0)
  kmt = fileid->KMT
  kmu = fileid->KMU
  region_mask = fileid->REGION_MASK
  tarea = fileid->TAREA
  uarea = fileid->UAREA
  angle = fileid->ANGLE

  do n=0,n_fields-1 

    contourline = 3
    fname = ListPop(field_name)
    field = fileid->$fname$
    area = tarea

    if ( fname .eq. "SU" ) then
      field_2 = fileid->SV
      area = uarea
      field(0,:,:) = tofloat(field(0,:,:) * cos(angle) + field_2(0,:,:) * sin(-angle))
      field = where (abs(field) .gt. 1.0e10, field@_FillValue, field)
    end if
    if ( fname .eq. "SV" ) then 
      field_2 = fileid->SU
      area = uarea
      field(0,:,:) = tofloat(field(0,:,:) * cos(angle) - field_2(0,:,:) * sin(-angle))
      field = where (abs(field) .gt. 1.0e10, field@_FillValue, field)
    end if

    dmin = missing 
    dmax = missing 
    if ( fname .eq. "HMXL"       .or. \
      fname .eq. "HBLT"       .or. \
      fname .eq. "DIA_DEPTH"  .or. \
      fname .eq. "INT_DEPTH" ) then
      dmin  =   0.0
      dmax  = 400.0
      units = "m"
      field = field / 100. 
      contourline = 2
    end if
    if ( fname .eq. "TLT" ) then
      dmin  =   0.0
      dmax  = 80.0
      units = "m"
      field = field / 100. 
      contourline = 2
    end if
    if ( fname .eq. "SU"  .or. fname .eq. "SV" ) then 
      dmin  = -40.0
      dmax  =  40.0
      units = "x10~S~5~N~ cm~S~2~N~ s~S~-1~N~"
      field = field / 1.0e5
      contourline = 2
    end if
    if ( fname .eq. "BSF" ) then
      dmin  = -110.
      dmax  =  190.
      units = "Sv"
      delete(contourline)
      contourline = (/0,0,0,1,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,1,0,0, \
      0,1,0,0,0,1,0,0,0/)
    end if  

    if ( dmin      .eq. missing  .or.  dmax      .eq. missing ) then 
      print( " user must set the contour limits .... ")
    end if

    nlev = 21
    if ( fname .eq. "BSF" ) then 
      nlev = 31
    end if
    dlev = (dmax-dmin)/(nlev-1) 
    lev  = dmin + ispan(0,nlev-1,1)*dlev

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

    opt = True
    opt@charsize = 0.9
    opt@landcolor = lndcolor
    opt@contourline = contourline
    opt@xrange = (/ xr0,xr1/)
    opt@yrange = (/ yr0,yr1/)
    opt@do_panel = False

    plot = contour_plot(wks, field(0,:,:), tlon, tlat, kmt, region_mask, area, case_info, \
    missing, units, dlev, lev, coltab, opt)

    delete([/lev,coltab,field/])
    delete(opt@contourline)


  end do

end
