load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCLPATH/get_environment.ncl"
load "$NCLPATH/contour_plot.ncl"

begin
    missing = 1.0e30
    
    fileid = addfile(file_netcdf,"r")
    ocn_comp = getenv("OCN_COMP")
    if (ocn_comp.eq."MOM") then
      dout_s_root = getenv("DOUT_S_ROOT")
      ocn_geo_file = addfile(dout_s_root+"/ocn/hist/ocean_geometry.nc","r")
      tlon = ocn_geo_file->geolon
      tlat = ocn_geo_file->geolat
      gridInfoFilePath = getenv("DIAGOBSROOT")+"/omwg/za_grids/"+getenv("RESOLUTION")+"_grid_info.nc"
      gridInfoFile = addfile(gridInfoFilePath,"r")
      kmt = gridInfoFile->KMT
      region_mask = kmt ; TODO: fix_this !!!
      tarea = gridInfoFile->TAREA
      field = fileid->SSH
      field = where(field.eq.1e20,fileid->SSH@missing_value,field*100.0) ; TODO, remove hardcoded missing_value 
      field_miss = field@missing_value
    else ; POP
      tlon = fileid->TLONG
      tlat = fileid->TLAT
      kmt = fileid->KMT
      region_mask = fileid->REGION_MASK
      tarea = fileid->TAREA
      field = fileid->SSH
      field_miss = field@missing_value
    end if
    
    
    fileid     = addfile(file_SSH_obs,"r")
    field_obs = fileid->SSH
    field_obs_miss = field_obs@missing_value
    field_diff = field(0,:,:) - field_obs
    
    contourline = 3
    dmin  = -200.0
    dmax  =  200.0
    units = "cm"
    nlev = 21
    dlev = (dmax-dmin)/(nlev-1) 
    lev  = dmin + ispan(0,nlev-1,1)*dlev
    
    dmin2 = -50.
    dmax2 = 50.
    dlev2 = (dmax2-dmin2)/(nlev-1) 
    lev2  = dmin2 + ispan(0,nlev-1,1)*dlev2
    
    print( " plotting ..... SSH")
    
    ;wks = gsn_open_wks("x11","SSH")
    wks = gsn_open_wks(img_format,"SSH")
    gsn_define_colormap(wks,"table42")
    coltab = new(nlev + 1,"integer")
    coltab(0) = 1
    color1 = 2 
    coltab(1:) = ((color2-color1+1)/(nlev-1))*ispan(0,nlev-1,1)+color1

    case_info = "SSH " + case_number + " " + time_info
    
    opt = True
    opt@charsize = 0.9
    opt@landcolor = lndcolor
    opt@contourline = contourline
    opt@xrange = (/ xr0,xr1/)
    opt@yrange = (/ yr0,yr1/)
    opt@do_panel = True
    
    plot1 = contour_plot(wks, field(0,:,:), tlon, tlat, kmt, region_mask, tarea, case_info, \
               	      missing, units, dlev, lev, coltab, opt)
    
    case_info = "MODEL - (Maximenko/Niiler 1992-2002 MDOT SSH)"
    
    opt@contourline = 2
    opt@yrange = (/ -75.,83./)
    
    plot2 = contour_plot(wks, field_diff, tlon, tlat, kmt, region_mask, tarea, case_info, \
              	      missing, units, dlev2, lev2, coltab, opt)
    gsn_panel(wks,(/plot1,plot2/), (/2,1/),False)

end
