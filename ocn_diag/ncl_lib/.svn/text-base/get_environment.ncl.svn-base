  print_values = False
  resolution = getenv("RESOLUTION")
  file_netcdf = getenv("TAVGFILE")
  file_T_obs = getenv("TOBSFILE")
  file_S_obs = getenv("SOBSFILE")
  file_RHO_obs = getenv("RHOOBSFILE")
  file_SST_obs = getenv("SSTOBSFILE")
  file_SSH_obs = getenv("SSHOBSFILE")
  file_flux_obs = getenv("FLUXOBSFILE")
  file_wind_obs = getenv("WINDOBSFILE")
  file_tao_obs = getenv("TOGATAOFILE")
  grid_file    = getenv("gridfile")
  case_number = getenv("CASE")
  img_format = getenv("IMAGEFORMAT")
  clrtblfile = getenv("NCLCOLORTABLEFILE")
;;  clrtbl = getenv("NCLCOLORTABLE")

  tmp = getenv("NCLCOLORTABLE")
  if (.not. ismissing(tmp)) then
    clrtbl = tointeger(tmp)
  else
    clrtbl = new(42,"integer")
  end if
  tmp = getenv("NCLMINCOLOR")
  if (.not. ismissing(tmp)) then
    color1 = tointeger(tmp)
  else
    color1 = new(1,"integer")
  end if
  tmp = getenv("NCLMAXCOLOR")
  if (.not. ismissing(tmp)) then
    color2 = tointeger(tmp)
  else
    color2 = new(1,"integer")
  end if
  tmp = getenv("NCLLNDCOLOR")
  if (.not. ismissing(tmp)) then
    lndcolor = tointeger(tmp)
  else
    lndcolor = new(1,"integer")
  end if
  cntrlvls = getenv("CNTRLVLS")
  year0 = getenv("YEAR0")
  year1 = getenv("YEAR1")
  moc0 = getenv("MOC0")
  moc1 = getenv("MOC1")
  time_info   = "["+year0+"-"+year1+"]"
  cpl = getenv("CPL")
  delete(tmp)

;; read plot.dat file to get bounds &
;;      depth information
  tmp_arr = asciiread("plot.dat",-1,"float")
  bounds = tmp_arr(0:3)
  n_depth = tmp_arr(4)
  depth = tmp_arr(5:5 + tointeger(n_depth-1))
  xr0 = bounds(0)
  xr1 = bounds(1)
  yr0 = bounds(2)
  yr1 = bounds(3)
  delete(tmp_arr)
  if (print_values) then
    print(depth)
    print(bounds)
    list_vars()
    print( 	clrtblfile )
    print( 	case_number )
    print( 	yr1 )
    print( 	yr0 )
    print( 	file_T_obs )
    print( 	file_S_obs )
    print( 	cntrlvls )
    print( 	file_flux_obs )
    print( 	file_wind_obs )
    print( 	n_depth )
    print( 	file_tao_obs )
    print( 	depth )
    print( 	time_info )
    print( 	xr1 )
    print( 	year1 )
    print( 	xr0 )
    print( 	year0 )
    print( 	bounds )
    print( 	file_RHO_obs )
    print( 	file_SST_obs )
    print( 	moc1 )
    print( 	moc0 )
    print( 	color2 )
    print( 	color1 )
    print( 	lndcolor )
    print( 	file_SSH_obs )
    print( 	cpl )
    print( 	file_netcdf )
    print( 	clrtbl )
  end if
