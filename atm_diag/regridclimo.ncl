;***************************************************************
; NCL script
; regridclimo.ncl
; John Truesdale, May 2012
;***************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

ingrid        = getenv("INGRID")
outgrid       = getenv("OUTGRID")
map_method    = getenv("INTERP_METHOD")  
srcFileName   = getenv("TEST_INPUT")     ; case1 input filename
dstFileName   = getenv("TEST_PLOTVARS")  ; case1 output filename
WGT_dir       = getenv("MAP_DATA")

;print("Beginning to regrid "+srcFileName+" from "+ingrid+" to "+outgrid)

; --- Define grid
grid_type = "unknown"
nx=-999
ny=-999

if (outgrid.eq."0.23x0.31") then
  nx=1152
  ny=768
  grid_type = "degree"
end if
if (outgrid.eq."0.47x0.63") then
  nx=576
  ny=384
  grid_type = "degree"
end if
if (outgrid.eq."0.9x1.25") then
  nx=288
  ny=192
  grid_type = "degree"
end if
if (outgrid.eq."1.9x2.5") then
   nx=144
   ny=96
  grid_type = "degree"
end if
if (outgrid.eq."2x2.5") then
   nx=144
   ny=91
  grid_type = "degree"
end if
if (outgrid.eq."4x5") then
   nx=72
   ny=46
  grid_type = "degree"
end if
if (outgrid.eq."10x15") then
   nx=24
   ny=19
  grid_type = "degree"
end if

if (outgrid.eq."gx1v6") then
   nx=320
   ny=384
  grid_type = "degree"
end if
if (outgrid.eq."gx3v7") then
   nx=100
   ny=116
  grid_type = "degree"
end if
if (outgrid.eq."gx3v5") then
   nx=100
   ny=116
  grid_type = "degree"
end if
if (outgrid.eq."x0.1v2") then
  nx=3600
  ny=2400
  grid_type = "degree"
end if
if (outgrid.eq."tx1v1") then
   nx=360
   ny=240
  grid_type = "degree"
end if

if (nx.eq.-999) then
;---Check for "1x1", "2x3", "0.25x0.25" format
    if(isStrSubset(outgrid,"x")) then
      str = str_split(outgrid,"x")
      if(dimsizes(str).ne.2) then
        print("regridclimo: invalid format for grid type")
        exit
      end if
      dlat = tofloat(str(0))
      dlon = tofloat(str(1))
      if(ismissing(dlat).or.ismissing(dlon)) then
        print("regridclimo: invalid format for grid type")
        exit
      end if
      grid_type = "degree"
      delete(str)
    else if(isStrSubset(outgrid,"deg")) then
;---Check for "1deg", "0.25 deg" format
      str = str_split(outgrid,"deg")
      if(dimsizes(str).ne.1) then
        print("regridclimo: invalid format for grid type")
        exit
      end if
      dlat = tofloat(str(0))
      if(ismissing(dlat)) then
        print("regridclimo: invalid format for grid type")
        exit
      end if
      dlon = dlat
      grid_type = "degree"
      delete(str)
    else if(isStrSubset(outgrid,"G")) then
;---Check for "G64", "G 128" format
      str = str_split(outgrid,"G")
      if(dimsizes(str).ne.1) then
        print("regridclimo: invalid format for grid type")
        exit
      end if
      nlon = tointeger(str(0))
      if(ismissing(nlon)) then
        print("regridclimo: invalid value for gaussian grid")
        exit
      end if
      if((nlon%2).ne.0) then
        print("regridclimo: invalid value for gaussian grid")
        exit
      end if
      nlat = nlon/2
      grid_type = "gaussian"
      delete(str)
    else
      print("regrid: invalid format for output grid type "+outgrid)
      exit
    end if
    end if
    end if
    ny=floattointeger(180./dlat)
    nx=floattointeger(360./dlon)
end if


    ; 0. Set the source/destination file names, 
    ;    open the source file for reading, 
    ;    create a destination file for regridded data.
    ;------------------------------------------------

    print(" ")
    print("Regridding: ")
    print("SRC:"+srcFileName)
    print("DST:"+dstFileName)
    if(isfilepresent(dstFileName)) then
      system("rm "+dstFileName)
    end if
    src_file=addfile(srcFileName,"r")
    dst_file=addfile(dstFileName,"c")

    ;
    ; 1. Generate a description file for the source grid (SE).
    ;---------------------------------------------------
    srcGridName=WGT_dir+"/ne"+ingrid+".nc"
    if(isfilepresent(srcGridName)) then
      print("Found srcGrid description "+srcGridName)
    else
      print("Creating srcGrid description "+srcGridName)
      Opt               =True
      Opt@ForceOverWrite=True
      Opt@Title         ="SE Grid"  
      Opt@Debug         =False ; True
      Opt@PrintTimings  =False ; True
      unstructured_to_ESMF(srcGridName,src_file->lat,src_file->lon,Opt)
      delete(Opt)
    end if

    ;
    ; 2. Generate a description file for the destination grid (FV).
    ;-----------------------------------------------------
    dstGridName = WGT_dir+"/"+outgrid+".nc"
    if(isfilepresent(dstGridName)) then
      print("Found dstGrid description "+dstGridName)
    else
      print("Creating dstGrid description "+dstGridName)
      Opt               =True
      Opt@ForceOverWrite=True
      Opt@Debug         =False ; True
      Opt@PrintTimings  =False ; True
      lats              =latGlobeF(ny,"lat","latitude" ,"degrees_north")
      lons              =lonGlobeF(nx,"lon","longitude","degrees_east" )
      rectilinear_to_SCRIP(dstGridName,lats,lons,Opt)
      delete(lats)
      delete(lons)
      delete(Opt)
    end if

    ;
    ; 3. Generate the weights file, using the source and 
    ;    destination files created in #1 and #2.
    ;-----------------------------------------------------
    wgtFileName = WGT_dir+"/map_ne"+ingrid+"_to_"+outgrid+"_"+map_method+".nc"
    if(isfilepresent(wgtFileName)) then
      print("Found WeightFile "+wgtFileName)
    else
      print("Creating WeightFile "+wgtFileName)
      Opt               = True
      Opt@InterpMethod  =map_method ;"bilinear"  "patch", "conserve"
      Opt@ForceOverWrite=True
      Opt@SrcESMF       =True   
      Opt@Debug         =False ; True
      Opt@PrintTimings  =False ; True
      ESMF_regrid_gen_weights(srcGridName,dstGridName,wgtFileName,Opt)
      delete(Opt)
    end if


    ;--- Specify a list of 1D variables on the *source SE file* that should NOT be copied
    var_in_exclude = (/"lat", "lon", "area", "date_written", "time_written"/)  

    ;--- Specify a list of variables on the source SE file that should be directly copied 
    var_in_copy = (/"time_bnds"/)  

    ;--- Specify a list of variables to be regridded
    var_out        = "All_Variables"     ; to be regridded

    ;---Read from the weight file the method used to derive the remap weights
    wgt_file       = addfile(wgtFileName, "r")
    dst_grid_dims  = wgt_file->dst_grid_dims
    dst_mlon       = dst_grid_dims(0)
    dst_nlat       = dst_grid_dims(1)
    dst_lat        = wgt_file->yc_b(::dst_mlon)
    dst_lon        = wgt_file->xc_b(:dst_mlon-1)

    ;---Generate or read the latitudinal weights dir the FV grid
    gw  = latRegWgt(dst_lat, "double", 0)
    gw!0= "lat"

    ;---Use the destination (FV) grid info on the weight file to create lat/lon
    lat       = dst_lat                  ; get from weight file
    lat@long_name = "latitude"
    lat!0     = "lat"
    lat@units = "degrees_north"
    lat&lat   =  lat
    nlat      = dimsizes(lat)            ; same as dst_nlat

    lon       = dst_lon
    lon@long_name = "longitude"
    lon!0     = "lon"
    lon@units = "degrees_east"
    lon&lon   =  lon
    mlon      = dimsizes(lon)            ; same as dst_mlon

    ;---Get all variables on the SE file 
    var_in   = getfilevarnames( src_file )
    nvar_in  = dimsizes(var_in)
    Opt_RGRD  = True


;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                    PREDEFINE MODE
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    setfileoption(dst_file,"DefineMode",True)

;===================================================================
; create global attributes of the netCDF file containing regridded data
;===================================================================
    global    = True
    global@separator2= "---------------------------------------"
    copy_VarAtts(src_file, global)
    global@separator1= "------- SOURCE FILE ATTRIBUTES --------"

    if (isatt(src_file,"title")) then
        global@TITLE = "REMAPPED: "+src_file@title
    end if

    global@remap         = "NCL: ESMF_regrid_with_weights"
    global@map_method    = map_method
    global@creation_date = systemfunc("date")
    
    fileattdef( dst_file, global )        ; copy file attributes to netCDF file

;===================================================================
; predefine the coordinate dimension names and their sizes
;===================================================================
    dNames   = getvardims(src_file)       ; get level info from source file
    dSizes   = getfiledimsizes(src_file)
    ia       = ind(dNames.eq."lev" )   ; # of levels 
    ib       = ind(dNames.eq."ilev")
    klev     = dSizes(ia)
    klevi    = dSizes(ib)
                                       ; standard CAM dimensions
    dimNames = (/"time",    "lat",    "lon", "lev",  "ilev", "nbnd", "chars"/)  
    dimSizes = (/ -1   ,    nlat ,    mlon ,  klev,  klevi ,   2   ,    8   /) 
    dimUnlim = (/ True ,    False,    False, False,  False , False , False  /)   
    filedimdef(dst_file,dimNames,dimSizes,dimUnlim)

;--- The following are explicitly added because they are 'special'

   filevardef(dst_file, "lat", typeof(lat), getvardims(lat)) 
   filevarattdef(dst_file,"lat" ,lat)           

   filevardef(dst_file, "lon", typeof(lon), getvardims(lon)) 
   filevarattdef(dst_file,"lon" ,lon)           

   filevardef(dst_file, "gw", typeof(gw), getvardims(gw)) 
   filevarattdef(dst_file,"gw" ,gw)           

;--- Loop over all variables and predfine meta data
    do nv=0,nvar_in-1
       if (.not.any(var_in(nv).eq.var_in_exclude)) then 
        if(var_out(0).eq."All_Variables"          .or. \
           any(var_in(nv).eq.var_out)             .or. \
           any(var_in(nv).eq.var_in_copy)       ) then

           rank_in = dimsizes(getfilevardimsizes(src_file, var_in(nv)))

           if (rank_in .eq.1 .or. any(var_in(nv).eq.var_in_copy) ) then
               filevardef(dst_file, var_in(nv), getfilevartypes(src_file,var_in(nv)) \
                                             , getfilevardims(src_file,var_in(nv))  )
;
           end if
           if (rank_in .eq.2 .and. .not.any(var_in(nv).eq.var_in_copy)) then
               filevardef(dst_file, var_in(nv), getfilevartypes(src_file,var_in(nv)) \
                                             , (/ "time", "lat", "lon" /)        )
           end if
           if (rank_in .eq.3) then
               vdims = getfilevardims(src_file, var_in(nv))
               filevardef(dst_file, var_in(nv), getfilevartypes(src_file,var_in(nv)) \
                                             , (/ "time", vdims(1),  "lat", "lon" /)        )
           end if

           dumAtts = new( 1, getfilevartypes(src_file,var_in(nv)))
           varAtts = getfilevaratts(src_file, var_in(nv))
           if (.not.ismissing(varAtts(0))) then
               nAtts = dimsizes(varAtts)
               do na=0,nAtts-1
                  dumAtts@$varAtts(na)$ = src_file->$var_in(nv)$@$varAtts(na)$
               end do
               filevarattdef(dst_file, var_in(nv) , dumAtts)
           end if
           delete([/varAtts, dumAtts/])   ; may change size next iteration
        end if
       end if
    end do       ; nv

;===================================================================
; explicitly exit file definition mode. **NOT REQUIRED in NCL**
;===================================================================
    setfileoption(dst_file,"DefineMode",False)
        
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;        Write the basic and regridded data values to the predefined structures
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    dst_file->lat = (/ lat /)
    dst_file->lon = (/ lon /)
    dst_file->gw  = (/ gw  /)

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;        Write the basic and regridded data values to the predefined structures
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    dst_file->lat = (/ lat /)
    dst_file->lon = (/ lon /)
    dst_file->gw  = (/ gw  /)

    do nv=0,nvar_in-1
       if (.not.any(var_in(nv).eq.var_in_exclude)) then 
        if(var_out(0).eq."All_Variables"          .or. \
           any(var_in(nv).eq.var_out)             .or. \
           any(var_in(nv).eq.var_in_copy)       ) then

           rank_in = dimsizes(getfilevardimsizes(src_file, var_in(nv)))

           if (rank_in .eq.1 .or. any(var_in(nv).eq.var_in_copy) ) then
               dst_file->$var_in(nv)$ = (/ src_file->$var_in(nv)$ /)
           end if
           if (rank_in .ge.2 .and. .not.any(var_in(nv).eq.var_in_copy)) then
               dst_file->$var_in(nv)$ = (/ ESMF_regrid_with_weights(src_file->$var_in(nv)$,wgtFileName,Opt_RGRD) /)
           end if
        end if
       end if
    end do       ; nv


end
