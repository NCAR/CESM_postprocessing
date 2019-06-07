load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/$VAR_MASTER"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/find_var_with_alts.ncl"
;************************************************
begin
  print ("=========================================")
  print ("Starting:  set_11.ncl")
  print ("Start Time: "+systemfunc("date") )
  print ("=========================================")
  ptmpdir1  = getenv("PTMPDIR_1")
  ptmpdir2  = getenv("PTMPDIR_2")
  wkdir    = getenv("WKDIR")
  obsdata  = getenv("OBS_DATA")
  obs_res  = getenv("OBS_RES")
  paleo    = getenv("paleo")
  plotObs  = getenv("plotObs")
  useCommon1 = getenv("UseCommonName_1")
  useCommon2 = getenv("UseCommonName_2")
  raster = getenv("raster")
  plot_type = getenv("PLOTTYPE")
  land_mask = getenv("land_mask1")
  user_defined = getenv("expContours")
  cn = getenv("CN")
  colormap = getenv("colormap")
  projection=getenv("projection")

;;  print((/"PTMPDIR_1: "+ptmpdir1/))
;;  print((/"PTMPDIR_2: "+ptmpdir2/))
;;  print((/"wkdir: "+wkdir/))

  flandmask = stringtofloat(land_mask)

  nyrs1 = stringtointeger(getenv("clim_num_yrs_1"))
  nyrs2 = stringtointeger(getenv("clim_num_yrs_2"))

;**************************************************************************
; Cut off top and bottom percent to tighten contour intervals.  12/06 nanr
;**************************************************************************
  pCut        = 5
  pLow  = 0.05
  pHigh = 0.95

; the set lists contains two columns of information. This comes into
; NCL as one long string that we need to parse out.
  tmp = stringtocharacter(asciiread(wkdir+"/master_set11.txt",-1,"string"))
  nvar = dimsizes(tmp(:,0))
  scale_type = new(nvar,"string")
  vars       = new(nvar,"string")
  c13Flag    = new(nvar,"string")
  c14Flag    = new(nvar,"string")
  dynContour = new(nvar,"string")
  do i=0,nvar-1
     scale_type(i) = charactertostring(tmp(i,0:12))
     dynContour(i) = charactertostring(tmp(i,13))
     vars(i)       = charactertostring(tmp(i,16:))
     c13Flag(i)    = charactertostring(tmp(i,16:19))     ; derived variable prefix
     c14Flag(i)    = charactertostring(tmp(i,16:19))     ; derived variable prefix
  end do

;*************************************************
; get case names and create filenames to read in
;*************************************************
  sig_lvl = stringtofloat(getenv("sig_lvl") )
  zoom  = stringtointeger(getenv("reg_contour")); # (1 = SUB, 0 = GLOBAL)
  if (zoom.eq.1)then
     min_lat = stringtofloat(getenv("min_lat"))
     max_lat = stringtofloat(getenv("min_lat"))
     min_lon = stringtofloat(getenv("min_lon"))
     max_lon = stringtofloat(getenv("min_lon"))
  end if
  seasons = (/"DJF","JJA","MAM","SON","ANN"/)
;*************************************************
; common plot resources
;*************************************************
  pres                         = True           ; panel only resources

; read in case strings
  cases  = new(3,string)
  prefix = new(2,string)
  do m = 0,1 
     if (m .eq. 0) then 
        useFlag = useCommon1 
     end if
     if (m .eq. 1) then 
        useFlag = useCommon2 
     end if
     if (useFlag .eq. "True") then
         name1  = "commonName_"+(m+1)
     else
         name1  = "caseid_"+(m+1)
     end if
     name2     = "prefix_"+(m+1)
     cases(m)  = getenv(name1)
     prefix(m) = getenv(name2)
  end do

; loop over seasons

  do n = 0,dimsizes(seasons)-1
     print("Processing season " + seasons(n))
     in1  = addfile(ptmpdir1+"/"+prefix(0)+"_"+seasons(n)+"_climo.nc","r")        ; used for first 3 plots
     in2  = addfile(ptmpdir2+"/"+prefix(1)+"_"+seasons(n)+"_climo.nc","r")        ; used for first 3 plots
     in11 = addfile(ptmpdir1+"/"+prefix(0)+"_"+seasons(n)+"_means.nc","r")
     in22 = addfile(ptmpdir2+"/"+prefix(1)+"_"+seasons(n)+"_means.nc","r")
    ; get degrees of freedom for t test
     if (isatt(in11,"num_yrs_averaged")) then
        dof_1 = in11@num_yrs_averaged
     else
        dof_1 = getfilevardimsizes(in11, "time")
     end if
     if (isatt(in22,"num_yrs_averaged")) then
        dof_2 = in22@num_yrs_averaged
     else
        dof_2 = getfilevardimsizes(in22, "time")
     end if
; open observation files

     ptr_racmo    = addfile(obsdata+"/RACMO2_ANT_"+seasons(n)+"_climo.nc","r")                 ; RACMO2.3_p2

; extract years averaged for plotting
     if (isatt(in1,"yrs_averaged")) then
        yrs_ave1 = in1@yrs_averaged
     end if
     if (isatt(in2,"yrs_averaged")) then
        yrs_ave2 = in2@yrs_averaged
     end if

; check to make sure levels are the same for both model cases
     nlev1 = 0
     nlev2 = 0
     if (isfilevar(in1,"levsoi")) then
        nlev1 = getfilevardimsizes(in1,"levsoi")
     end if
     if (isfilevar(in2,"levsoi")) then
        nlev2 = getfilevardimsizes(in2,"levsoi")
     end if
     if (isfilevar(in1,"levgrnd")) then
        nlev1 = getfilevardimsizes(in1,"levgrnd")
     end if
     if (isfilevar(in2,"levgrnd")) then
        nlev2 = getfilevardimsizes(in2,"levgrnd")
     end if
     if (nlev1 .eq. 0 .or. nlev2 .eq. 0)
        print("FATAL ERROR Set2:  nlev1 = 0")
        exit
     end if

     if (isfilevar(in1,"TLAKE") ) then
        if (isfilevar(in1,"levlak") ) then
           nlevlak1 = getfilevardimsizes(in1,"levlak")
        end if
     end if
     if (isfilevar(in2,"TLAKE") ) then
        if (isfilevar(in2,"levlak") ) then
           nlevlak2 = getfilevardimsizes(in2,"levlak")
        end if
     end if

     lon1    = in1->lon 
     lon2    = in2->lon 
     lat1    = in1->lat 
     lat2    = in2->lat 
     nlon1   = dimsizes(lon1)
     nlon2   = dimsizes(lon2)
     nlat1   = dimsizes(lat1)
     nlat2   = dimsizes(lat2)
     time1   = in1->time
     time2   = in2->time

; extract landfrac if paleo file
     if (paleo .eq. "True") then
        flandmask = 0
        landfrac = in1->landfrac(:,:)
        oro = new((/nlat1,nlon1/),integer)
        oro = 1
        oro@_FillValue = 0
        oro = where(landfrac .gt. 0.0, 1,0)
;       fname = wkdir+prefix(0)
;       fname = wkdir+"basename"
        fname = wkdir+getenv(name1)
        paleo_outline(oro,lat1,lon1,flandmask, fname )
        res = True
        res@mpDataBaseVersion = "Ncarg4_1"
        res@mpDataSetName     = fname
     end if

; truncate soil layers if needed
     if (nlev1 .gt. 10) then
        print("Truncating soil levels to 10 levels [caseid: "+prefix(0)+"  nlev:  " + nlev1 +"]")
        nlev1 = 10
     end if
     if (nlev2 .gt. 10) then
        print("Truncating soil levels to 10 levels [caseid: "+prefix(1)+"  nlev:  " + nlev2 +"]")
        nlev2 = 10
     end if

; loop over variables

     snowFlag = 0
     do i=0,dimsizes(vars)-1 

        if (paleo .ne. "True") then
           if (snowFlag .eq. 1) then             ; run SNOWDP twice to see both obs datasets
              i = i-1
           end if
           if (vars(i) .eq. "SNOWDP") then
              snowFlag = snowFlag + 1
           end if
        end if
        print("Processing variable " + vars(i))

        plot_check_1  = True
        plot_check_11 = True
        plot_check_2  = True
        plot_check_22 = True

        info    = var_init(vars(i))     ; read in case 1 variable
        filevar = find_var_with_alts(in1, vars(i), info)
;         now filevar is the name of the variable in the file (either
;         vars(i) or one of its alternate names); if this variable was
;         not found in the file, then filevar will be ""

        plot_check = True
        if (filevar .ne. "")then
           if (isvar("x1")) then
              delete(x1)
           end if
           if (isvar("x11")) then
              delete(x11)
           end if
           if (c13Flag(i) .eq. "C13_") then
              x1  = derive_del13C(vars(i),in1, scale_type(i),0,2)
              x11 = derive_del13C(vars(i),in11,scale_type(i),0,2)
           else
              if (c14Flag(i) .eq. "C14_") then
                 x1  = derive_del14C(vars(i),in1, scale_type(i),0,2)
                 x11 = derive_del14C(vars(i),in11,scale_type(i),0,2)
              else
                 x1  = in1 ->$filevar$
                 x11 = in11->$filevar$
                 plot_check_1  = True
                 plot_check_11 = True
                 delete(filevar)
              end if
           end if
        else
           if (info@derivedVariable .eq. True) then
              x1  = derive_land(vars(i),in1)
              x11 = derive_land(vars(i),in11)
           else
              print("variable "+ vars(i)+ " is not a defined variable.")
              plot_check_1  = False
              plot_check_11 = False
              continue
           end if
        end if

        info    = var_init(vars(i))   ; read in case 2 variable
        filevar = find_var_with_alts(in2, vars(i), info)
;         now filevar is the name of the variable in the file (either
;         vars(i) or one of its alternate names); if this variable was
;         not found in the file, then filevar will be ""

        plot_check = True
        if (filevar .ne. "")then
           if (isvar("x2")) then
              delete(x2)
           end if
           if (isvar("x22")) then
              delete(x22)
           end if
           if (c13Flag(i) .eq. "C13_") then
              x2  = derive_del13C(vars(i),in2, scale_type(i),0,2)
              x22 = derive_del13C(vars(i),in22,scale_type(i),0,2)
           else
              if (c14Flag(i) .eq. "C14_") then
                 x2  = derive_del14C(vars(i),in2, scale_type(i),0,2)
                 x22 = derive_del14C(vars(i),in22,scale_type(i),0,2)
              else
                 x2  = in2 ->$filevar$
                 x22 = in22->$filevar$
                 plot_check_2  = True
                 plot_check_22 = True
                 delete(filevar)
              end if
           end if
        else
           if (info@derivedVariable .eq. True) then
              x2  = derive_land(vars(i),in2)
              x22 = derive_land(vars(i),in22)
           else
              print("variable "+ vars(i)+ " is not a defined variable.")
              plot_check_2  = False
              plot_check_22 = False
              continue
           end if
        end if

        obsFlag = 0                                  ; read in observations (if present) (1 = on; 0 = off)
        if (isvar("x3") ) then
           delete(x3)
        end if
        if (paleo .ne. "True") then
           if (vars(i) .eq. "ASA" ) then
              x3 = ptr_racmo->$vars(i)$
              x3 = x3*100. ; fraction to %
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "QSOIL" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "U10" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "FGR" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "FLDS" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "FIRE" ) then
              x3 = ptr_racmo->$vars(i)$
              x3 = x3 * -1. ; defined negative in RACMO2.3_p2
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "RAIN" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "PBOT" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "Q2M" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "QICE_FRZ" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "RH2M" ) then
              x3 = ptr_racmo->$vars(i)$
              x3 = x3 * 100. ; fraction to %
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "QICE_MELT" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "FSH" ) then
              x3 = ptr_racmo->$vars(i)$
              x3 = x3 * -1. ; defined neg. in CESM
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "QICE" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "SNOW" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "QSNOMELT" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "FSDS" ) then
              x3 = ptr_racmo->$vars(i)$
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "FSR" ) then
              x3 = ptr_racmo->$vars(i)$
              x3 = x3 * -1. ; defined as negative in RACMO2.3_p2
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           else
           if (vars(i) .eq. "TSA" ) then
              x3 = ptr_racmo->$vars(i)$
              x3 = x3 - 273.16 ; K to C
              lon3 = ptr_racmo->lon
              lat3 = ptr_racmo->lat
              cases(2) = "RACMO2.3_p2"
              obsFlag = 1;
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
           end if
        
        end if                ; paleo

        if (paleo .eq. "True") then
           obsFlag = 0
        end if

        if (obsFlag .eq. 1) then
           nlon3   = dimsizes(lon3)
           nlat3   = dimsizes(lat3)
        end if

        if (x1@units .eq. "K") then
           x1 = x1 - 273.15  ; convert K to C 
           x2 = x2 - 273.15  ; convert K to C 
;          x1 = x1 - 273.15  ; convert K to C 
;          x2 = x2 - 273.15  ; convert K to C 
        end if

      ; catch NaNs 
        if (isvar("x1") ) then
           x1  = catchNaN(x1)
        end if
        if (isvar("x11") ) then
           x11 = catchNaN(x11)
        end if
        if (isvar("x2") ) then
           x2  = catchNaN(x2)
        end if
        if (isvar("x22") ) then
           x22 = catchNaN(x22)
        end if

        if (all(ismissing(x1)))then
           print("variable "+ vars(i)+ " contains all missing values.")
           plot_check_1 = False
           delete(x1)
        end if
        if (all(ismissing(x11)))then
           print("variable "+ vars(i)+ " not found")
           plot_check_11 = False
           delete(x11)
        end if
        if (all(ismissing(x2)))then
           print("variable "+ vars(i)+ " not found")
           plot_check_2 = False
           delete(x2)
        end if
        if (all(ismissing(x22)))then
           print("variable "+ vars(i)+ " not found")
           plot_check_22 = False
           delete(x22)
        end if

; ----------------------
; start plotting process if variables exist
; ----------------------
        if (plot_check_1 .eq. True .and. plot_check_11 .eq. True .and. plot_check_2 .eq. True .and. plot_check_22 .eq. True) then
           x1       = scale_var(x1, scale_type(i),info)
           x11      = scale_var(x11,scale_type(i),info)
           x2       = scale_var(x2, scale_type(i),info)
           x22      = scale_var(x22,scale_type(i),info)

; flip longitudes to -180 to 180 if needed 
           if (min(x2&lon) .ge. 0 .and. min(x1&lon) .lt. 0) then
              x2  = lonFlip(x2)
              x22 = lonFlip(x22)
           end if
           if (min(x1&lon) .ge. 0 .and. min(x2&lon) .lt. 0) then
              x1  = lonFlip(x1)
              x11 = lonFlip(x11)
           end if

;            process observations if present.  Case 1 as root.
;            flip x3 longitudes to -180 to 180 if needed
           if (obsFlag .eq. 1)                                   ; (1 = on; 0 = off)
              if (min(x1&lon) .lt. 0 .and. min(x3&lon) .ge. 0) then
                 if (lon3(0) .ge. 0.) then
                    x3 = lonFlip(x3)
                 end if
              end if
           end if

           rank1 = dimsizes(dimsizes(x1))    ; calculate size
           rank2 = dimsizes(dimsizes(x2))

           useCase1 = True
           useCase2 = False
           if (nlat1 .ne. nlat2) then
              if (nlat1 .gt. nlat2) then              ; interpolate x1 to x2 grid
                 x1_interp = linint2_Wrap(lon1,lat1,x1,True,lon2,lat2,0)
                 x2_interp = x2
                 x11_interp = linint2_Wrap(lon1,lat1,x11,True,lon2,lat2,0)
                 x22_interp = x22
                 useCase1 = False
                 useCase2 = True
                 use_nlat = nlat2
                 use_nlon = nlon2
              else
                 x2_interp = linint2_Wrap(lon2,lat2,x2,True,lon1,lat1,0)
                 x1_interp = x1
                                
                 x22_interp = linint2_Wrap(lon2,lat2,x22,True,lon1,lat1,0)
                 x11_interp = x11
                 use_nlat = nlat1
                 use_nlon = nlon1
              end if
           else
              use_nlon   = nlon1
              use_nlat   = nlat1
              x1_interp  = x1
              x2_interp  = x2
              x11_interp = x11
              x22_interp = x22
           end if

;            interpolate obs to new grid if necessary
           if (obsFlag .eq. 1)                                   ; (1 = on; 0 = off)
              if (nlat1 .ne. nlat3 .or. nlat2 .ne. nlat3) then
                 if (useCase1 .eq. True) then
                    x3_interp = linint2_Wrap(lon3,lat3,x3,True,lon1,lat1,0) ; interpolate x3 to x1 grid
                 end if
                 if (useCase2 .eq. True) then
                    x3_interp = linint2_Wrap(lon3,lat3,x3,True,lon2,lat2,0) ; interpolate x3 to x2 grid
                 end if
              else
                 x3_interp = x3
              end if
;               different plots for observations
;             plot = new(9,graphic)
           else
;               x1_interp = x1        ; fix, per Keith Oleson
;             plot = new(4,graphic)
           end if            ; end observations

           if (obsFlag .eq. 1 .and. plotObs .eq. 1) then
              plot = new(9,graphic)
           else
              plot = new(4,graphic)
           end if

           if (x1@units .eq. "K") then
              useUnits   = "C"        ; assume same units for x1 and x2
           else
              useUnits   = x1@units        ; assume same units for x1 and x2
           end if
;*******************************************************************
; 3D VARIABLES
;*******************************************************************
           if (rank1.eq.3)then

;               calculate time average
              var_avg_1 = dim_avg_n_Wrap(x1,0)  ; time average
              var_avg_2 = dim_avg_n_Wrap(x2,0)  ; time average
              var_avg_1_intp = dim_avg_n_Wrap(x1_interp,0)  ; time average
              var_avg_2_intp = dim_avg_n_Wrap(x2_interp,0)  ; time average

              if (obsFlag .eq. 1) then         ; (1 = obs; 0 = no obs)
                 x3_interp = mask(x3_interp,    (x1_interp(0,:,:) .eq. x1_interp@_FillValue), False)        ; remove non-land points
                 var_avg_3      = x3_interp
                 var_avg_3_intp = x3_interp
                 min3 = min(var_avg_3)
                 max3 = max(var_avg_3)
                 delete(x3_interp)
              end if

              min1 = min(var_avg_1)
              min2 = min(var_avg_2)
              max1 = max(var_avg_1)
              max2 = max(var_avg_2)

              if (min1 .le. min2) then
                 if (isvar("min12")) then
                    delete(min12)
                 end if
                 min12 = min1
              else
                 if (isvar("min12")) then
                    delete(min12)
                 end if
                 min12 = min2
              end if

              if (max1 .ge. max2) then
                 if (isvar("max12")) then
                    delete(max12)
                 end if
                 max12 = max1
              else
                 if(isvar("max12")) then
                        delete(max12)
                end if
                max12 = max2
              end if

;**************************************************************************
; Set contour Levels:  Dynamic vs pre-defined contours
;**************************************************************************

;               dynContour:  0=dynamic;1=explicit
              if (info@cn_Explicit .eq. True .and. dynContour(i) .eq. 1 .and. user_defined .eq. 1) then   
                 expFlag = True
              else
                 expFlag = False
              end if

              res  = True
              res  = set11ResMvM(res)
              if (paleo .eq. "True") then
                 res@mpDataBaseVersion = "Ncarg4_1"
                 res@mpDataSetName     =  fname
              end if

              if (expFlag .eq. True) then                            ; explicitly defined contours.
                 res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                 res@cnLevels             = info@cn_Levels   ; contour levels
              else 
                 if (c13Flag(i) .eq. "C13_" .or. c14Flag(i) .eq. "C14_") then
                    useMin12 = -40              ; hardcode boundaries to expectations
                    useMax12 = 0                ; hardcode boundaries to expectations
                 else
                    x = ndtooned(var_avg_1)
                    nMsg  = num(ismissing(x))
                    nGood = num(.not.ismissing(x))

                    qsort(x)

                    iLow  = floattointeger( pLow*nGood)
                    useMin12  = x(iLow )
                    iHigh = floattointeger( pHigh*nGood)
                    useMax12  = x(iHigh)
                    delete(x)
                 end if
                 maxLevel = 9
                 if (vars(i) .eq. "SNOWDP") then
                    useMin12 = 0.
                    useMax12 = 1.
                 end if
                 if (vars(i) .eq. "H2OSNO") then
                    useMin12 = 0.
                    useMax12 = 500.
                 end if
                 if (vars(i) .eq. "SNOWICE") then
                    useMin12 = 0.
                    useMax12 = 500.
                 end if
                 if (vars(i) .eq. "TWS") then
                    useMin12 = 4000.
                    useMax12 = 10000.
                 end if
                 mnmxint = nice_mnmxintvl( useMin12, useMax12, maxLevel, False)
                 res@cnLevelSelectionMode = "ManualLevels" ; explicit contour levels
                 res@cnMinLevelValF       = mnmxint(0)
                 res@cnMaxLevelValF       = mnmxint(1)
                 res@cnLevelSpacingF      = mnmxint(2)

                 delete(useMin12)
                 delete(useMax12)
              end if

;               open postscript file and choose colormap        
              if (isvar("wks")) then
                 delete(wks)
              end if
              if (vars(i) .eq. "SNOWDP") then
                 if (snowFlag .eq. 1) then
;;                   print((/"plot_type: "+plot_type/))
;;                   print((/"wkdir: "+wkdir/))
;;                   print((/"seasons: "+seasons(n)/))
;;                   print((/"vars: "+vars(i)/))
;;                   print((/"Fullname: "+wkdir + "set11_" + seasons(n)+"_"+vars(i)+"_FOSTERDAVY"/))
                   fullname = wkdir+"set11_"+seasons(n)+"_"+vars(i)+"_FOSTERDAVY"
;;		     print((/"Fullname: "+fullname/))
;;                    wks  = gsn_open_wks(plot_type,wkdir + "set11_" + seasons(n)+"_"+vars(i)+"_FOSTERDAVY")
		      wks = gsn_open_wks(plot_type,fullname)
                 else
;;                   print((/"plot_type: "+plot_type/))
;;                   print((/"wkdir: "+wkdir/))
;;                   print((/"seasons: "+seasons(n)/))
;;                   print((/"vars: "+vars(i)/))
;;                   print((/"Fullname: "+wkdir + "set11_" + seasons(n)+"_"+vars(i)+"_CMC"/))
                   fullname = wkdir + "set11_" + seasons(n)+"_"+vars(i)+"_CMC"
;;		     print((/"Fullname: "+fullname/))
;;                    wks  = gsn_open_wks(plot_type,wkdir + "set11_" + seasons(n)+"_"+vars(i)+"_CMC")
		      wks = gsn_open_wks(plot_type,fullname)
                 end if
              else
;;                print((/"plot_type: "+plot_type/))
;;                print((/"wkdir: "+wkdir/))
;;                print((/"seasons: "+seasons(n)/))
;;                print((/"vars: "+vars(i)/))
                fullname = wkdir + "set11_" + seasons(n)+"_"+vars(i)
;;		  print((/"Fullname: "+fullname/))
;;                print((/"Fullname: "+wkdir + "set11_" + seasons(n)+"_"+vars(i)/))
;;                 wks  = gsn_open_wks(plot_type,wkdir + "set11_" + seasons(n)+"_"+vars(i))
	         wks = gsn_open_wks(plot_type,fullname) 
              end if
              if (colormap.eq.0) then
                 cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag10.rgb")  ; read in colormap
                 gsn_define_colormap(wks,cmap)
              end if
              if (colormap.eq.1) then
                 gsn_define_colormap(wks,"ncl_default")
                 cmap1 = gsn_retrieve_colormap(wks)
                 res@cnFillPalette = cmap1(13:240,:)
              end if
        
              res@tiMainString           = cases(0)     ; set case 1 titles
              res@gsnCenterString        = "(yrs " + yrs_ave1 + ")"
              min1 = min(var_avg_1)
              max1 = max(var_avg_1)

              res@gsnLeftString    = ""     ; vars(i)        ; could also use info@longName if we want
              res@gsnRightString   = ""     ;useUnits        ; assume same units for x1 and x2
              delete(min1)
              delete(max1)
        
              if (projection.eq.1) then    ; projection = CE        
                 if (obsFlag.eq.1 .and. plotObs .eq. 1) then    ; set differing font heights/labelbar placement depending on whether there is 4 or 9 plots
                    res@gsnLeftStringFontHeightF   = 0.026     ; 9 plots
                    res@gsnCenterStringFontHeightF = 0.030
                    res@tiMainFontHeightF        = 0.030
                    res@lbLabelFontHeightF       = 0.026
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 else
                    res@gsnLeftStringFontHeightF   = 0.024     ; 4 plots
                    res@gsnCenterStringFontHeightF = 0.028
                    res@tiMainFontHeightF        = 0.028
                    res@lbLabelFontHeightF       = 0.024
                    res@pmLabelBarOrthogonalPosF = 0.05
                    res@tiMainOffsetYF = -.01
                 end if
              else             
                 if (obsFlag.eq.1 .and. plotObs .eq. 1) then ; projection = Robinson        
                    res@gsnLeftStringFontHeightF   = 0.018
                    res@gsnCenterStringFontHeightF = 0.022
                    res@tiMainFontHeightF        = 0.022
                    res@lbLabelFontHeightF       = 0.018
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 else
                    res@gsnLeftStringFontHeightF   = 0.016
                    res@gsnCenterStringFontHeightF = 0.020
                    res@tiMainFontHeightF        = 0.020
                    res@lbLabelFontHeightF       = 0.016
                    res@pmLabelBarOrthogonalPosF = 0.05
                    res@tiMainOffsetYF = -.01
                 end if
              end if

              ctr = 0
              plot(ctr) = gsn_csm_contour_map(wks,var_avg_1,res)    ; case 1 plot
              ctr = ctr+1

;               Note:  Don't delete res here - save until after obs are posted.
              res@tiMainString    = cases(1) ; set case 2 titles
              res@gsnCenterString = " (yrs " + yrs_ave2 + ")"
              if (vars(i) .eq. "CH4PROD" .or. vars(i) .eq. "CH4_SURF_EBUL_SAT" .or. vars(i) .eq. "CH4_SURF_EBUL_UNSAT" .or. vars(i) .eq. "CPOOL") then
                 if (isatt(res,"cnLabelBarEndStyle")) then
                    if (res@cnLabelBarEndStyle.eq."IncludeMinMaxLabels") then
                       res@cnLabelBarEndStyle = "IncludeOuterBoxes" ; temporarily turn off minmax labels.
                    end if
                 end if
              else
                 if (isatt(res,"cnLabelBarEndStyle")) then
                    res@cnLabelBarEndStyle = "IncludeMinMaxLabels"
                 end if
              end if
              plot(ctr) = gsn_csm_contour_map(wks,var_avg_2,res)   ; case 2 plot
              ctr = ctr+1

;               Note:  Don't delete res here - save until after obs are posted.
              if (obsFlag .eq. 1 .and. plotObs .eq. 1) then   ; OBS  plot (if present)
                 res  = True
                 res  = set11ResMvM(res)
                 if (paleo .eq. "True") then
                    res@mpDataBaseVersion = "Ncarg4_1"
                    res@mpDataSetName     = fname
                 end if
                 res@tiMainString           = cases(2) 
                 res@gsnCenterString = " "
                 delete(min3)
                 delete(max3)
                 if (projection.eq.1) then    ; CE
                    res@gsnLeftStringFontHeightF   = 0.026
                    res@gsnCenterStringFontHeightF = 0.030
                    res@tiMainFontHeightF        = 0.030
                    res@lbLabelFontHeightF       = 0.026
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 else                         ; Robinson
                    res@gsnLeftStringFontHeightF   = 0.018
                    res@gsnCenterStringFontHeightF = 0.022
                    res@tiMainFontHeightF        = 0.022
                    res@lbLabelFontHeightF       = 0.018
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 end if
                 plot(ctr) = gsn_csm_contour_map(wks,var_avg_3,res)
                 ctr = ctr+1
              end if
              delete(res)                  ; delete res in time for difference plots.
              
;               difference plots
              if (isvar("cmap") ) then
                 delete(cmap)
              end if
              if (colormap.eq.0) then
                 cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag12.rgb")  ; read in colormap (increase color resolution for difference maps)
                 gsn_define_colormap(wks,cmap)
                 delete(cmap)
              end if
              
              if (obsFlag .eq. 1 .and. plotObs .eq. 1) then    ; OBS  plot (if present)
                 res  = True
                 res  = set11ResMvM(res)
                 if (paleo .eq. "True") then
                    res@mpDataBaseVersion = "Ncarg4_1"
                    res@mpDataSetName     = fname
                 end if
                 res@cnFillPalette = cmap1(13:240,:)


;                  Case 1 - Obs
                 diff = var_avg_1_intp ; trick to maintain meta data
                 check = isdouble(var_avg_3_intp)
                 if (check .eq. True) then
                    diff = var_avg_1_intp - doubletofloat(var_avg_3_intp)
                 else
                    diff = var_avg_1_intp - var_avg_3_intp
                 end if
                 delete(check)
                 mindiff = min(diff)
                 maxdiff = max(diff)
                 res@tiMainString           = cases(0)
                 res@gsnCenterString = "- Observations"
;                  set contour levels ( use larger contour intervals for Model vs Obs )
                 res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                 res@cnLevels  = info@cn_LevelsDiffObs   ; contour levels

                 if (projection.eq.1) then    ; CE
                    res@gsnLeftStringFontHeightF   = 0.026
                    res@gsnCenterStringFontHeightF = 0.030
                    res@tiMainFontHeightF        = 0.030
                    res@lbLabelFontHeightF       = 0.026
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 else                         ; Robinson
                    res@gsnLeftStringFontHeightF   = 0.018
                    res@gsnCenterStringFontHeightF = 0.022
                    res@tiMainFontHeightF        = 0.022
                    res@lbLabelFontHeightF       = 0.018
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 end if

                 res@gsnLeftString    = ""    ;vars(i)        ; could also use info@longName if we want
                 res@gsnRightString   = ""    ;useUnits        ; assume same units for x1 and x2
                 plot(ctr) = gsn_csm_contour_map(wks,diff,res)
                 delete(diff)
                 delete(mindiff)
                 delete(maxdiff)
                 ctr = ctr+1

;                  Case 2 - Obs
                 diff = var_avg_1_intp ; trick to maintain meta data
                 diff = var_avg_2_intp - doubletofloat(var_avg_3_intp)
                 res@tiMainString     = cases(1)
                 res@gsnCenterString = "- Observations"
                 mindiff = min(diff)
                 maxdiff = max(diff)

                 res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                 res@cnLevels       = info@cn_LevelsDiffObs   ; contour levels
                 plot(ctr) = gsn_csm_contour_map(wks,diff,res)
                 delete(res)
                 delete(diff)
                 delete(mindiff)
                 delete(maxdiff)
                 ctr = ctr+2
              end if

;               Case 1 - Case 2
              diff = var_avg_1_intp ; trick to maintain meta data
              diff = var_avg_1_intp - var_avg_2_intp                
              mindiff = min(diff)
              maxdiff = max(diff)

;               set contour levels 
              res  = True
              res  = set11ResMvM(res)
              res@cnFillPalette = cmap1(13:240,:)

              if (paleo .eq. "True") then
                 res@mpDataBaseVersion = "Ncarg4_1"
                 res@mpDataSetName     = fname
              end if

              if (expFlag .eq. False) then
                 sd = dim_stddev(ndtooned(diff))
            
                 if (vars(i).eq."PREC") then
                    useMin1  = -2.*sd   ; = mindiff
                    useMax1  = 2.*sd    ; = maxdiff
                 else
                    useMin1  = -2.5*sd   ; = mindiff
                    useMax1  = 2.5*sd    ; = maxdiff
                 end if
                
                 if (c13Flag(i) .eq. "C13_" .or. c14Flag(i) .eq. "C14_") then
                    useMin1 = -40              ; hardcode boundaries to expectations
                    useMax1 = 0                ; hardcode boundaries to expectations
                 end if
                 if (mindiff.eq.maxdiff) then    ; two cases are identical
                    useMin1 = -6
                    useMax1 = 6
                    diff = 0.
                    if (isatt(res,"cnLabelBarEndStyle")) then
                       if (res@cnLabelBarEndStyle.eq."IncludeMinMaxLabels") then
                          res@cnLabelBarEndStyle = "IncludeOuterBoxes" ; temporarily turn off minmax labels.
                       end if
                    end if
                 end if
                 maxLevel = 13
                 mnmxint = nice_mnmxintvl( useMin1, useMax1, maxLevel, False)
                 res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
                 res@cnMinLevelValF       = mnmxint(0)
                 res@cnMaxLevelValF       = mnmxint(1)
                 res@cnLevelSpacingF      = mnmxint(2)
                 delete([/useMin1,useMax1/])
              else
                 res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                 res@cnLevels             = info@cn_LevelsDiff   ; contour levels
              end if
        
              if (projection.eq.1) then    ; projection = CE        
                 if (obsFlag.eq.1 .and. plotObs .eq. 1) then    ; set differing font heights/labelbar placement depending on whether there is 4 or 9 plots
                    res@gsnLeftStringFontHeightF   = 0.026     ; 9 plots
                    res@gsnCenterStringFontHeightF = 0.030
                    res@tiMainFontHeightF        = 0.030
                    res@lbLabelFontHeightF       = 0.026
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 else
                    res@gsnLeftStringFontHeightF   = 0.024     ; 4 plots
                    res@gsnCenterStringFontHeightF = 0.028
                    res@tiMainFontHeightF        = 0.028
                    res@lbLabelFontHeightF       = 0.024
                    res@pmLabelBarOrthogonalPosF = 0.05
                    res@tiMainOffsetYF = -.01
                 end if
              else             
                 if (obsFlag.eq.1 .and. plotObs .eq. 1) then ; projection = Robinson        
                    res@gsnLeftStringFontHeightF   = 0.018
                    res@gsnCenterStringFontHeightF = 0.022
                    res@tiMainFontHeightF        = 0.022
                    res@lbLabelFontHeightF       = 0.018
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 else
                    res@gsnLeftStringFontHeightF   = 0.016
                    res@gsnCenterStringFontHeightF = 0.020
                    res@tiMainFontHeightF        = 0.020
                    res@lbLabelFontHeightF       = 0.016
                    res@pmLabelBarOrthogonalPosF = 0.05
                    res@tiMainOffsetYF = -.01
                 end if
              end if
              res@tiMainString   = cases(0) 
              res@gsnCenterString= "- "+cases(1)

              res@gsnLeftString    = ""       ; vars(i)        ; could also use info@longName if we want
              res@gsnRightString   = ""       ; useUnits        ; assume same units for x1 and x2
              plot(ctr) = gsn_csm_contour_map(wks,diff,res)
              delete(res)
              ctr = ctr+1
              delete([/diff,mindiff,maxdiff/])

              res  = True     ; T-Test plots
              res  = set11ResMvM(res)
              if (paleo .eq. "True") then
                 res@mpDataBaseVersion = "Ncarg4_1"
                 res@mpDataSetName     = fname
              end if

              var_variance_1 = dim_variance_n_Wrap(x11_interp,0)  ; time average
              var_variance_2 = dim_variance_n_Wrap(x22_interp,0)  ; time average

;               set variances < 0 to missing so don't divide by zero        
              if (any(var_variance_1 .le. 0)) then
                 var_variance_1 = mask(var_variance_1,(var_variance_1 .gt. 0),True)
              end if
              if (any(var_variance_2 .le. 0)) then
                 var_variance_2 = mask(var_variance_2,(var_variance_2 .gt. 0),True)
              end if
;               calculate t-test
              prob = var_avg_1_intp ; trick to maintain meta data
              prob = ttest(var_avg_1_intp,var_variance_1,dof_1,var_avg_2_intp,var_variance_2,dof_2,True,False)

              if (obsFlag .eq. 1 .and. plotObs .eq. 1) then

                 pfinal = new((/use_nlat,use_nlon/),"float")

                 diff13 = abs(var_avg_1_intp - doubletofloat(var_avg_3_intp))
                 diff23 = abs(var_avg_2_intp - doubletofloat(var_avg_3_intp))
                 delete(var_avg_3_intp)
                 copy_VarCoords(prob,diff13)
                 copy_VarCoords(prob,diff23)

                 p1d   = ndtooned(prob)
                 d131d = ndtooned(diff13)
                 d231d = ndtooned(diff23) 

                 do c=0,dimsizes(p1d)-1
                    if (.not. ismissing(d131d(c)) .and. .not. ismissing(d231d(c) )) then
                       if (.not. ismissing(p1d(c))) then
                          if (d131d(c) .gt. d231d(c) ) then  ; case 2 is closer to obs
                             if (p1d(c) .lt. sig_lvl ) then
                                p1d(c) = 10           ; blue
                             end if
                          else                                     ; case 1 is closer to obs
                             if (p1d(c) .lt. sig_lvl ) then
                                p1d(c) = 5           ; red
                             end if
                          end if
                       end if
                    end if
                 end do

                 pfinal = onedtond(p1d,dimsizes(prob))
                 copy_VarCoords(prob,pfinal)

                 res@gsnCenterString        = ""
                 res@gsnRightString       = ""
                 res@lbLabelBarOn         = False
                 res@gsnLeftStringParallelPosF = 0.3
                 res@tiMainString         = cases(0)+" (green)"
                 res@gsnCenterString      = cases(1)+" (red)"
                ; res@tiMainString         = "Case1+ (green) and Case2+ (red) relative to obs"
                 res@gsnLeftString      = "Model relative to Obs"
;                res@gsnSpreadColors      = False
                 res@cnFillMode                 = "RasterFill"
                 res@cnLevelSelectionMode =  "ExplicitLevels"
                ; nanr 12/01/07
                 if (isvar("cnLevels")) then
                    delete(res@cnLevels)
                 end if
                 res@cnLevels             = (/2,7/)  ; user defined sig level to view
                 res@cnFillColors         = (/"white","green","red"/) ; white=NoChange; green=Case1 better; red=Case2 better
;                 res@cnFillColors         = (/0,11,11/) ; only have red squares
                
                
                 if (projection.eq.1) then    ; CE
                    res@gsnLeftStringFontHeightF   = 0.026
                    res@gsnCenterStringFontHeightF = 0.030
                    res@tiMainFontHeightF        = 0.030
                    res@lbLabelFontHeightF       = 0.026
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 else                         ; Robinson
                    res@gsnLeftStringFontHeightF   = 0.018
                    res@gsnCenterStringFontHeightF = 0.022
                    res@tiMainFontHeightF        = 0.022
                    res@lbLabelFontHeightF       = 0.018
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 end if

                 plot(ctr) = gsn_csm_contour_map(wks, pfinal,res) ; will be sig test
                 delete([/res,pfinal,p1d,d131d,d231d,diff13,diff23/])
                 ctr = ctr+1
              end if

              res  = True     ; t-test plot (3D vars)
              res  = set11ResMvM(res)
              if (paleo .eq. "True") then
                 res@mpDataBaseVersion = "Ncarg4_1"
                 res@mpDataSetName     = fname
              end if

              prob = var_avg_1_intp ; trick to maintain meta data
              prob = ttest(var_avg_1_intp,var_variance_1,dof_1,var_avg_2_intp,var_variance_2,dof_2,True,False)
  
;              res@gsnSpreadColors      = False
              res@cnLevelSelectionMode =  "ExplicitLevels"
              res@cnLevels             = sig_lvl  ; user defined sig level to view
              res@cnFillColors         = (/"red","white"/) ; only have red squares
              res@lbLabelBarOn         = False
              res@gsnLeftStringParallelPosF = 0.245
              res@tiMainString         = "T-Test of two Case means at each grid point"
              res@gsnLeftString        = "Cells are significant at " + sig_lvl +" level"
              res@gsnRightString       = ""
              res@gsnCenterString      = ""
              if (projection.eq.1) then    ; projection = CE        
                 if (obsFlag.eq.1 .and. plotObs .eq. 1) then    ; set differing font heights/labelbar placement depending on whether there is 4 or 9 plots
                    res@gsnLeftStringFontHeightF   = 0.026     ; 9 plots
                    res@gsnCenterStringFontHeightF = 0.030
                    res@tiMainFontHeightF        = 0.030
                    res@lbLabelFontHeightF       = 0.026
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 else
                    res@gsnLeftStringFontHeightF   = 0.024     ; 4 plots
                    res@gsnCenterStringFontHeightF = 0.028
                    res@tiMainFontHeightF        = 0.028
                    res@lbLabelFontHeightF       = 0.024
                    res@pmLabelBarOrthogonalPosF = 0.05
                    res@tiMainOffsetYF = -.01
                 end if
              else            
                 if (obsFlag.eq.1 .and. plotObs .eq. 1) then  ; projection = Robinson        
                    res@gsnLeftStringFontHeightF   = 0.018
                    res@gsnCenterStringFontHeightF = 0.022
                    res@tiMainFontHeightF        = 0.022
                    res@lbLabelFontHeightF       = 0.018
                    res@pmLabelBarOrthogonalPosF = 0.075
                    res@tiMainOffsetYF = -.0075
                 else
                    res@gsnLeftStringFontHeightF   = 0.016
                    res@gsnCenterStringFontHeightF = 0.020
                    res@tiMainFontHeightF        = 0.020
                    res@lbLabelFontHeightF       = 0.016
                    res@pmLabelBarOrthogonalPosF = 0.05
                    res@tiMainOffsetYF = -.01
                 end if
              end if
              res@tiMainOffsetYF = 0

              plot(ctr) = gsn_csm_contour_map(wks,prob,res) ; will be sig test
              delete(res)
      
              if (obsFlag .eq. 1 .and. plotObs .eq. 1) then   ; panel plot
                 nrows = 3
                 ncols = 3
              else
                 nrows = 2
                 ncols = 2
              end if
              pres@txString = seasons(n)+" "+vars(i)+" ("+useUnits+")" ; "
              gsn_panel(wks,plot,(/nrows,ncols/),pres)           ; draw panel plot
           else
;*************************************************************************
; 4D VARIABLES
;*************************************************************************
;            calculate 4D average
              var_avg_1      = dim_avg_n_Wrap(x1(:,:nlev1-1,:,:),0)   ; time average
              var_avg_1_intp = dim_avg_n_Wrap(x1_interp(:,:nlev1-1,:,:),0)   ; time average
              var_avg_2      = dim_avg_n_Wrap(x2(:,:nlev1-1,:,:),0)   ; time average
              var_avg_2_intp = dim_avg_n_Wrap(x2_interp(:,:nlev1-1,:,:),0)   ; time average
              
              if (isdim(x1_interp,"levlak") )then
                 nlev1 = nlevlak1
              end if
              if (isdim(x2_interp,"levlak") )then
                 nlev2 = nlevlak2
              end if
         
              if (nlev1 .ne. nlev2) then
                 print("Set 2 Failed: number of soil levels is unequal:  " + nlev1 + " vs  " + nlev2)
              end if
         
              karr = (/0,4,9/)
              do lev=0,2  ; assume both cases have same number of levels.
                 k = karr(lev)
                 res  = True
                 res  = set11ResMvM(res)
                 if (paleo .eq. "True") then
                    res@mpDataBaseVersion = "Ncarg4_1"
                    res@mpDataSetName     = fname
                 end if
;                 open postscript file (4D)
                 if (isvar("wks")) then
                    delete(wks)
                 end if
;;                print((/"plot_type: "+plot_type/))
;;                print((/"wkdir: "+wkdir/))
;;                print((/"seasons: "+seasons(n)/))
;;                print((/"vars: "+vars(i)/))
;;                print((/"Fullname: "+wkdir + "set11_" + seasons(n)+"_"+vars(i)+"_"+k/))
                 wks  = gsn_open_wks(plot_type,wkdir + "set11_" + seasons(n)+"_"+vars(i)+"_"+k)
                 if (isvar("cmap")) then
                    delete(cmap)
                 end if
                 if (colormap.eq.0) then
                    cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag10.rgb")  ; read in colormap
                    gsn_define_colormap(wks,cmap)
                 end if
                 if (colormap.eq.1) then
                    gsn_define_colormap(wks,"ncl_default")
                    cmap1 = gsn_retrieve_colormap(wks)
                    res@cnFillPalette = cmap1(13:240,:)
                 end if   
 
                 min1 = min(var_avg_1(k,:,:))
                 max1 = max(var_avg_1(k,:,:))  

                 if (expFlag .eq. True) then     ; set explicit contour levels (4D)
                    res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                    st = "cn_Level"+k        ; get cn levels for a specific levsoi
                    res@cnLevels             = info@$st$
                 else
                    maxLevel = 9
                    x = ndtooned(var_avg_1(k,:,:))
                    nMsg  = num(ismissing(x))                
                    nGood = num(.not.ismissing(x))                  
                    qsort(x)  
 
                    iLow  = floattointeger( pLow*nGood)
                    useMin1  = x(iLow )
                    iHigh = floattointeger( pHigh*nGood)
                    useMax1  = x(iHigh) 

                    delete(x)
                    mnmxint = nice_mnmxintvl( useMin1, useMax1, maxLevel, False)
                    res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
                    res@cnMinLevelValF       = mnmxint(0)
                    res@cnMaxLevelValF       = mnmxint(1)
                    res@cnLevelSpacingF      = mnmxint(2)
                    delete(useMin1)
                    delete(useMax1)
                 end if
          
                 res@pmLabelBarHeightF     = 0.085
                 res@pmLabelBarWidthF      = 0.4
                 if (projection.eq.1) then    ; CE
                    res@gsnLeftStringFontHeightF   = 0.026
                    res@gsnCenterStringFontHeightF = 0.030
                    res@tiMainFontHeightF        = 0.030
                    res@lbLabelFontHeightF       = 0.026
                    res@pmLabelBarOrthogonalPosF = 0.075
                 else                         ; Robinson
                    res@gsnLeftStringFontHeightF   = 0.018
                    res@gsnCenterStringFontHeightF = 0.022
                    res@tiMainFontHeightF        = 0.022
                    res@lbLabelFontHeightF       = 0.018
                    res@pmLabelBarOrthogonalPosF = 0.075
                 end if
                 res@tiMainOffsetYF = -.01
                 res@tiMainString   = cases(0)
                 res@gsnLeftString  = ""    ;vars(i)        ; could also use info@longName if we want
                 res@gsnRightString = ""    ;useUnits        ; assume same units for x1 and x2
                 res@gsnCenterString = "(yrs " + yrs_ave1 +")" 

                 plot(0) = gsn_csm_contour_map(wks,var_avg_1(k,:,:),res)    ; 4D case 1 plot

;                  set case 2 titles (4D)
;                  Note:  Don't delete res here - save until after obs are posted.

                 delete(min1)
                 delete(max1)
           
                 res@tiMainString           = cases(1)
                 res@gsnCenterString = "(yrs " + yrs_ave2 +")"
                 plot(1) = gsn_csm_contour_map(wks,var_avg_2(k,:,:),res)   ; 4D case 2 plot
                 delete(res)

                 res  = True
                 res  = set11ResMvM(res)
                 if (paleo .eq. "True") then
                    res@mpDataBaseVersion = "Ncarg4_1"
                    res@mpDataSetName     = fname
                 end if 

;                  diff plot (4D)
                 if (isvar("cmap") ) then
                    delete(cmap)
                 end if
                 if (colormap.eq.0) then
                    cmap = RGBtoCmap("$DIAG_RESOURCES/rgb_files/diag12.rgb")  ; read in colormap ( increase color resolution for difference maps)
                    gsn_define_colormap(wks,cmap)
                    delete(cmap)
                 end if
                 if (colormap.eq.1) then
                    res@cnFillPalette = cmap1(13:240,:)
                 end if
          
                 diff = var_avg_1_intp                 ; trick to maintain meta data
                 diff(k,:,:) = var_avg_1_intp(k,:,:) - var_avg_2_intp(k,:,:)
                 res@tiMainString               = "Case 1 - Case 2"
                 mindiff = min(diff(k,:,:))
                 maxdiff = max(diff(k,:,:)) 

                 if (expFlag .eq. True) then
                    res@cnLevelSelectionMode = "ExplicitLevels" ; explicit contour levels
                    st = "cn_Level"+k+"Diff"   ; get cn levels for a specific levsoi
                    res@cnLevels             = info@$st$
                 else 
                    sd = dim_stddev(ndtooned(diff))
             
                    if (vars(i).eq."PREC") then
                       useMin1  = -2.*sd   ; = mindiff
                       useMax1  = 2.*sd    ; = maxdiff
                    else
                       useMin1  = -2.5*sd   ; = mindiff
                       useMax1  = 2.5*sd    ; = maxdiff
                    end if
                    if (useMax1 .gt. maxdiff) then
                       useMin1 = -sd/5.
                       useMax1 = sd/5.
                    end if
                    maxLevel = 13

                    mnmxint = nice_mnmxintvl( useMin1, useMax1, maxLevel, False)
                    res@cnLevelSelectionMode = "ManualLevels" ; ncl defined contour levels
                    res@cnMinLevelValF       = mnmxint(0)
                    res@cnMaxLevelValF       = mnmxint(1)
                    res@cnLevelSpacingF      = mnmxint(2)
                    delete(useMin1)
                    delete(useMax1)
                 end if
                 res@pmLabelBarHeightF     = 0.085
                 res@pmLabelBarWidthF      = 0.4
                 if (projection.eq.1) then    ; CE
                    res@gsnLeftStringFontHeightF   = 0.026
                    res@gsnCenterStringFontHeightF = 0.030
                    res@tiMainFontHeightF        = 0.030
                    res@lbLabelFontHeightF       = 0.026
                    res@pmLabelBarOrthogonalPosF = 0.075
                 else                         ; Robinson
                    res@gsnLeftStringFontHeightF   = 0.018
                    res@gsnCenterStringFontHeightF = 0.022
                    res@tiMainFontHeightF        = 0.022
                    res@lbLabelFontHeightF       = 0.018
                    res@pmLabelBarOrthogonalPosF = 0.075
                 end if
                 res@tiMainOffsetYF = -.01
                 res@gsnLeftString  = ""    ;vars(i)        ; could also use info@longName if we want
                 res@gsnRightString = ""    ;useUnits        ; assume same units for x1 and x2
                 res@tiMainString           = cases(0)
                 res@gsnCenterString = "- "+cases(1)
                 plot(2) = gsn_csm_contour_map(wks,diff(k,:,:),res)
                 delete(res)
                 delete(diff) 

                 res  = True    ; T-Test plot (4D)
                 res  = set11ResMvM(res)
                 if (paleo .eq. "True") then
                    res@mpDataBaseVersion = "Ncarg4_1"
                    res@mpDataSetName     = fname
                 end if

                 var_variance_1 = dim_variance_n_Wrap(x11_interp(:,:nlev1-1,:,:),0)
                 var_variance_2 = dim_variance_n_Wrap(x22_interp(:,:nlev2-1,:,:),0)

                 if (any(var_variance_1 .le. 0)) then      ;set variances < 0 to missing so don't divide by zero 
                    var_variance_1 = mask(var_variance_1,(var_variance_1 .gt. 0),True)
                 end if
                 if (any(var_variance_2 .le. 0)) then
                    var_variance_2 = mask(var_variance_2,(var_variance_2 .gt. 0),True)
                 end if
          
                 prob = var_avg_1_intp ; trick to maintain meta data
                 prob = ttest(var_avg_1_intp,var_variance_1,dof_1,var_avg_2_intp,var_variance_2,dof_2,True,False)
          
                 res@cnLevelSelectionMode =  "ExplicitLevels"
                 res@cnLevels             = sig_lvl  ; user defined sig level to view
                 res@cnFillColors         = (/"red","white"/) ; only have red squares
                 res@lbLabelBarOn         = False
                 res@gsnLeftStringParallelPosF = 0.245
                 if (projection.eq.1) then    ; CE
                    res@gsnLeftStringFontHeightF   = 0.026
                    res@gsnCenterStringFontHeightF = 0.030
                    res@tiMainFontHeightF        = 0.030
                    res@lbLabelFontHeightF       = 0.026
                    res@pmLabelBarOrthogonalPosF = 0.075
                 else                         ; Robinson
                    res@gsnLeftStringFontHeightF   = 0.018
                    res@gsnCenterStringFontHeightF = 0.022
                    res@tiMainFontHeightF        = 0.022
                    res@lbLabelFontHeightF       = 0.018
                    res@pmLabelBarOrthogonalPosF = 0.075
                 end if
                 res@tiMainOffsetYF = 0
                 res@tiMainString         = "T-Test of two Case means at each grid point"
                 res@gsnCenterString        = " "
                 res@gsnRightString       = " "
                 res@gsnLeftString      = "Cells are significant at " + sig_lvl +" level"
                 plot(3) = gsn_csm_contour_map(wks,prob(k,:,:),res) ; will be sig test
                 delete(res)
                 pres@txString = seasons(n)+" "+vars(i)+" Level " + k+" ("+useUnits+")" ; "
                 gsn_panel(wks,plot,(/2,2/),pres)           ; draw panel plot
              end do ; level loop
           end if ; 4d variables
           delete([/x1,x11,x2,x1_interp,x2_interp,x11_interp,x22_interp,x22,prob,var_avg_1,var_avg_2/])
           if (isvar("var_avg_3") ) then
              delete(var_avg_3)
           end if
           if (isvar("cmap1") ) then
              delete(cmap1)
           end if
           delete(var_avg_1_intp)
           delete(var_avg_2_intp)
           delete(var_variance_1)
           delete(var_variance_2)
           delete(plot)
        else 
           print("Variable " + vars(i) + " does not exist.")
        end if ; plot_check loop
        if (isvar("useUnits")) then
           delete(useUnits)
        end if
        if (isvar("lon3")) then
           delete(lon3)
        end if
        if (isvar("lat3")) then
           delete(lat3)
        end if
     end do ; end variable loop
  end do   ; seasons loop 
;  remove error file if program completes successfully.  
  filo  = wkdir +"/set11_error_file"                   
  system("/bin/rm -f " + filo)  
end
