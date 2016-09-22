load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/yt_plot.ncl"

begin
  region = (/"Sou","Pac","Ind","Atl","Lab","Gin","Arc","Hud","Glo"/)
  yr0str = sprinti("%04.4d",tointeger(year0))
  yr1str = sprinti("%04.4d",tointeger(year1))

  ts_netcdf = region + "_hor_mean_"+case_number+"*"+".nc"
  do i = 0, dimsizes(ts_netcdf) - 1
    ts_netcdf(i) = systemfunc("ls " + ts_netcdf(i))
  end do
  
  basin_title = (/ "SOUTHERN", "PACIFIC", "INDIAN", "ATLANTIC", \
                   "LABRADOR", "GIN",     "ARCTIC", "HUDSON",   \
                   "GLOBAL" /)

  n_tracer = 2
  nb = dimsizes(ts_netcdf)
  fileid = addfile(ts_netcdf(0),"r")
  z_t = fileid->z_t
  time = fileid->time

; convert z_t to km from cm
  z_t = z_t / 1.0e5
; convert time to years from days
  time = time / 365.

  nz = dimsizes(z_t)
  nt = dimsizes(time)
 
  TRACER = new((/n_tracer,nb,nz,nt/),float)
  TRACER!2 = "z_t"
  TRACER&z_t = z_t
  TRACER!3 = "time" 
  TRACER&time = time
  TRACER_DIFF = TRACER
  TRACER_RMS = TRACER

  do n = 0, nb -1 
    fileid = addfile(ts_netcdf(n),"r")
    tmp = fileid->TEMP
    TRACER(0,n,:,:) = (/ tmp(z_t|:,time|:) /)
    delete(tmp)
    tmp = fileid->SALT
    TRACER(1,n,:,:) = (/ tmp(z_t|:,time|:) /)
    delete(tmp)
    tmp = fileid->TEMP_DIFF
    TRACER_DIFF(0,n,:,:) = (/ tmp(z_t|:,time|:) /)
    delete(tmp)
    tmp = fileid->SALT_DIFF
    TRACER_DIFF(1,n,:,:) = (/ tmp(z_t|:,time|:) /)
    delete(tmp)
    tmp = fileid->TEMP_RMS
    TRACER_RMS(0,n,:,:) = (/ tmp(z_t|:,time|:) /)
    delete(tmp)
    tmp = fileid->SALT_RMS
    TRACER_RMS(1,n,:,:) = (/ tmp(z_t|:,time|:) /)
  end do

  nlev_TRACER      = 51
  dmin_TRACER      = (/ -2.0, 27.0 /)
  dmax_TRACER      = (/ 23.0, 37.0 /)

  coltab_TRACER = new(nlev_TRACER + 1,"integer")
  color1 = 2 
  coltab_TRACER(1:) = ((color2-color1+1)/(nlev_TRACER-1))*ispan(0,nlev_TRACER-1,1)+color1
  coltab_TRACER(0) = 0

  nlev_TRACER_DIFF = 61 
  dmin_TRACER_DIFF = (/ -3.0, -1.5 /)
  dmax_TRACER_DIFF = (/  3.0,  1.5 /)

  coltab_TRACER_DIFF = new(nlev_TRACER_DIFF + 1,"integer")
  color1 = 2 
  coltab_TRACER_DIFF(1:) = ((color2-color1+1)/(nlev_TRACER_DIFF-1))*ispan(0,nlev_TRACER_DIFF-1,1)+color1
  coltab_TRACER_DIFF(0) = 0

  nlev_TRACER_RMS  = 61
  dmin_TRACER_RMS  = (/  0.0,  0.0 /)
  dmax_TRACER_RMS  = (/  6.0,  3.0 /)

  coltab_TRACER_RMS = new(nlev_TRACER_RMS + 1,"integer")
  color1 = 2 
  coltab_TRACER_RMS(1:) = ((color2-color1+1)/(nlev_TRACER_RMS-1))*ispan(0,nlev_TRACER_RMS-1,1)+color1
  coltab_TRACER_RMS(0) = 0

  con_int_TRACER = (dmax_TRACER - dmin_TRACER) / tofloat(nlev_TRACER-1)
  con_int_TRACER_DIFF = (dmax_TRACER_DIFF - dmin_TRACER_DIFF) / tofloat(nlev_TRACER_DIFF-1)
  con_int_TRACER_RMS  = (dmax_TRACER_RMS  - dmin_TRACER_RMS) / tofloat(nlev_TRACER_RMS-1)
  dlev_TRACER = new((/n_tracer,nlev_TRACER/),float)
  dlev_TRACER_DIFF = new((/n_tracer,nlev_TRACER_DIFF/),float)
  dlev_TRACER_RMS = new((/n_tracer,nlev_TRACER_RMS/),float)
  missing = default_fillvalue("float")
  do i = 0,n_tracer-1
    dlev_TRACER(i,:) = dmin_TRACER(i) + ispan(0,nlev_TRACER-1,1) * con_int_TRACER(i)
    dlev_TRACER_DIFF(i,:) = dmin_TRACER_DIFF(i) + ispan(0,nlev_TRACER_DIFF-1,1) * con_int_TRACER_DIFF(i)
    dlev_TRACER_RMS(i,:) = dmin_TRACER_RMS(i) + ispan(0,nlev_TRACER_RMS-1,1) * con_int_TRACER_RMS(i)
    tracer_title = (/ "_hor_mean_T_timeseries", "_hor_mean_S_timeseries" /)
    diff_tracer_title = (/ "_hor_mean_Tdiff_timeseries", "_hor_mean_Sdiff_timeseries" /)
    rms_tracer_title = (/ "_hor_mean_Trms_timeseries", "_hor_mean_Srms_timeseries" /)
    main_title = (/ "POTENTIAL TEMPERATURE (~S~o~N~C)", "Salinity (psu)" /)
    tracer_type = (/ "TEMP", "SALT" /)
    units = (/ "~S~o~N~C" , "psu" /)
    do n = 0, nb - 1
      print("plotting " + tracer_type(i) + " tracers for " + basin_title(n) + " BASIN")
      ;wks = gsn_open_wks("x11",region(n) + tracer_title(i))
      wks = gsn_open_wks(img_format,region(n) + tracer_title(i))
      gsn_define_colormap(wks,"table42")

      opt = True
      opt@do_panel =False
      if (region(n) .eq. "Hud") then
        opt@max_depth = .3
      end if
      
      case_info = case_number + " " + basin_title(n) + " BASIN"
      opt@tiXAxisString =  main_title(i) 
      plot =  yt_plot(wks, TRACER(i,n,:,:), z_t, time, case_info, \
                        missing, units(i), con_int_TRACER, dlev_TRACER(i,:), coltab_TRACER, opt)

      ;wks = gsn_open_wks("x11",region(n) + diff_tracer_title(i))
      wks = gsn_open_wks(img_format,region(n) + diff_tracer_title(i))
      gsn_define_colormap(wks,"table42")

      opt = True
      opt@do_panel =False
      if (region(n) .eq. "Hud") then
        opt@max_depth = .3
      else if (isatt(opt,"max_depth")) then
        delete(opt@max_depth)
      end if
      end if
      
      case_info = case_number + " " + basin_title(n) + " BASIN"
      opt@tiXAxisString =  main_title(i) + " (MODEL - OBS)"
      plot =  yt_plot(wks, TRACER_DIFF(i,n,:,:), z_t, time, case_info, \
                        missing, units(i), con_int_TRACER_DIFF, dlev_TRACER_DIFF(i,:), coltab_TRACER_DIFF, opt)

      ;wks = gsn_open_wks("x11",region(n) + rms_tracer_title(i))
      wks = gsn_open_wks(img_format,region(n) + rms_tracer_title(i))
      gsn_define_colormap(wks,"table42")

      opt = True
      opt@do_panel =False
      if (region(n) .eq. "Hud") then
        opt@max_depth = .3
      end if
      
      case_info = case_number + " " + basin_title(n) + " BASIN"
      opt@tiXAxisString =  main_title(i) + " RMS (MODEL - OBS)"
      plot =  yt_plot(wks, TRACER_RMS(i,n,:,:), z_t, time, case_info, \
                        missing, units(i), con_int_TRACER_RMS, dlev_TRACER_RMS(i,:), coltab_TRACER_RMS, opt)
    end do
  end do
end

