load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
; Data is not averaged in this script.  Seasonally and
; annually averaged data is read in from netcdf files.

wkdir = getenv("WKDIR")
case = getenv("CASE_TO_CONT")
dir   = getenv("PATH_PLOT")
var_names = getenv("VAR_NAMES")
frst_avg_yr = getenv("YR_AVG_FRST")
last_avg_yr = getenv("YR_AVG_LAST")
hires = getenv("HIRES")
gridfile = getenv("GRIDFILECONT")

wks_type = getenv("PLOT_FORMAT")
wks_type@wkWidth  = stringtointeger(getenv("PLOT_RES"))
wks_type@wkHeight = stringtointeger(getenv("PLOT_RES"))

;---------USER DEFINED QUANTITIES------------------

season = (/"ann", "jfm", "amj", "jas", "ond"/)    ; These are for file names
NH_min_lat   = 40               
NH_max_lat   = 90
SH_min_lat   = -90
SH_max_lat   = -45
if (var_names.eq."CICE") then
  var_to_read = (/"uvel","vvel"/)
else
if (var_names.eq."SIMIP") then
  var_to_read = (/"siu","siv"/)
else
  var_to_read = (/"u","v"/)
end if
end if
;-------END USER DEFINED QUANTITIES----------------

nvar = dimsizes(var_to_read)
nseasons = dimsizes(season)

ifrst_avg_yr = stringtointeger(frst_avg_yr)
ilast_avg_yr = stringtointeger(last_avg_yr)

left_label = "Ice velocity"

main_labels = (/"ANN Mean", "JFM Mean", "AMJ Mean", "JAS Mean", "OND Mean"/)

grid = addfile(gridfile,"r")
rot_ang= dble2flt(grid->ANGLE)                          ; Rotation angle on U grid
lat2d  = dble2flt(grid->ULAT)                           ; Latitude on U grid
lon2d  = dble2flt(grid->ULONG)                           ; Longitude on U grid

;--------------------------------------------------------------------
; Construct file name and read in data
;--------------------------------------------------------------------

do j = 0, nseasons-1

  cyear_frst = sprinti("%0.4i", ifrst_avg_yr)   ; Convert integer year to string
  cyear_last = sprinti("%0.4i", ilast_avg_yr)   ; Convert integer year to string
  file_name = season(j) + "_avg_" + cyear_frst + "-" + cyear_last + ".nc"
  b = addfile(dir + "/" + file_name,"r")
  u_mean = b->$var_to_read(0)$(0,:,:)      ; Read u into memory
  v_mean = b->$var_to_read(1)$(0,:,:)    ; Read v into memory
  if (max(abs(u_mean)).gt.10.) then
     min_vector = 0.
     max_vector = 22.
     vec_spacing = 2.
     ref_vec_mag = 10.
     right_label= "cm/s"
  else
     min_vector = 0.
     max_vector = 0.22
     vec_spacing = 0.02
     ref_vec_mag = 0.1
     right_label= "m/s"
  end if
;--------------------------------------------------------------------
; Convert velocities from the POP grid to regular meridional grid
;--------------------------------------------------------------------
    
  if (hires .eq. 0) then
     urot        = u_mean(:,:)     ; Copy coordinate variables
     vrot        = v_mean(:,:)
     urot        = u_mean(:,:)*cos(rot_ang) - v_mean(:,:)*sin(rot_ang)
     vrot        = u_mean(:,:)*sin(rot_ang) + v_mean(:,:)*cos(rot_ang)
     urot@lon2d  = lon2d
     urot@lat2d  = lat2d
     vrot@lon2d  = lon2d
     vrot@lat2d  = lat2d
  else
     ; Subsample the vectors for high-resolution data.
     urot        = u_mean(::3,::3)     ; Copy coordinate variables
     vrot        = v_mean(::3,::3)
     urot        = u_mean(::3,::3)*cos(rot_ang(::3,::3)) - v_mean(::3,::3)*sin(rot_ang(::3,::3))
     vrot        = u_mean(::3,::3)*sin(rot_ang(::3,::3)) + v_mean(::3,::3)*cos(rot_ang(::3,::3))
     urot@lon2d  = lon2d(::3,::3)
     urot@lat2d  = lat2d(::3,::3)
     vrot@lon2d  = lon2d(::3,::3)
     vrot@lat2d  = lat2d(::3,::3)
  end if

  delete(u_mean)
  delete(v_mean)

; Calculate the magnitude of the wind for the scalar part of the plot
  mag_vel = urot    ; Copy coordinate variables
  mag_vel = sqrt(urot^2 + vrot^2)

;************************************************
; create plots
;************************************************

  if (var_names.eq."CICE".or.var_names.eq."SIMIP") then
     wks = gsn_open_wks(wks_type,wkdir + "vec_"+season(j)+ \   ; open ps file
                 "_cice")
  else
     wks = gsn_open_wks(wks_type,wkdir + "vec_"+season(j)+ \   ; open ps file
                 "_csim")
  end if
  print (" Plotting " + season(j))

  gsn_define_colormap(wks,"gui_default")
  i = NhlNewColor(wks,0.7,0.7,0.7)              ; add gray to colormap
  plot = new(2,graphic)

  res                      = True
  res@gsnDraw              = False              ; do not draw picture
  res@gsnFrame             = False              ; do not advance frame
  res@gsnPolar             = "NH"
  res@gsnScalarContour     = True               ; vectors over scalars

  res@vcRefMagnitudeF       = ref_vec_mag       ; vec magnitude
  res@vcRefLengthF          = 0.060             ; size of ref vector
  res@vcLineArrowColor      = "black"           ; black vectors
  res@vcMinDistanceF        = 0.015             ; thins arrows near pole 
  res@vcGlyphStyle          = "CurlyVector"     ; turn on curly vectors

  res@cnLevelSelectionMode = "ManualLevels"     ; Manually sets the contour levels.
  res@cnMinLevelValF = min_vector + vec_spacing
  res@cnMaxLevelValF = max_vector - vec_spacing
  res@cnLevelSpacingF = vec_spacing  

  res@cnFillOn             = True               ; turn on color for contours
  res@cnLinesOn            = False              ; turn off contour lines
  res@cnLineLabelsOn       = False              ; turn off contour line labels
  res@gsnScalarContour     = True               ; contours desired

  res@gsnSpreadColors     = True                ; use full colormap
  res@gsnSpreadColorStart = 4
  res@gsnSpreadColorEnd   = 23 

  if (hires .eq. 1) then
     res@cnFillMode           = "RasterFill" ; Raster Mode
     res@trGridType           = "TriangularMesh"  ; Define the mesh type
  end if

  res@gsnLeftString       = left_label
  res@gsnRightString      = right_label
  res@gsnAddCyclic        = True
  res@txFontHeightF  = 0.025
  res@tiMainFontHeightF  = 0.025                ; size of title main string
  res@lbLabelBarOn        = False               ; Turns off the individual label bars

  res@mpMinLatF             = NH_min_lat        ; minimum lat to plot
  res@mpMaxLatF             = NH_max_lat        ; maximum lat to plot
  res@mpLandFillColor       = "grey"            ; color of continents
  res@mpLabelFontHeightF   = 0.05               ; size of map long. labels

  plot(0) = gsn_csm_vector_scalar_map_polar \
          (wks,urot(:,:), vrot(:,:), mag_vel(:,:), res)

  res@gsnPolar   = "SH"
  res@mpMinLatF  = SH_min_lat                   ; minimum lat to plot
  res@mpMaxLatF  = SH_max_lat                   ; maximum lat to plot

  plot(1) = gsn_csm_vector_scalar_map_polar \
          (wks,urot(:,:), vrot(:,:), mag_vel(:,:), res)

; draw panel without white space
  resP = True
  resP@gsnPaperOrientation = "portrait"
  resP@gsnMaximize      = True                  ; maximize plot area
  resP@gsnPanelLabelBar = True                  ; create common label bar
  resP@lbLabelStride    = 1                     ; alter label bar stride
  resP@lbLabelFontHeightF  = 0.015              ; label bar font height
  resP@txFontColor      = "black"                     ; Font color of top label
  resP@txFuncCode = "~"
  resP@txString   = "     Case "+case+"~C~   "+main_labels(j) \
                  + "   Years "+cyear_frst+"-"+cyear_last+"~C~ "

  gsn_panel(wks,plot,(/2,1/),resP)

  delete(urot)
  delete(vrot)
  delete(mag_vel)
end do   ; End loop through seasons

end
