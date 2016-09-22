load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/get_environment.ncl"

begin

   zmin = 500.
   zmax = 2000.
   print(" computing regional upperocean TEMP biases,"+ zmin +" to "+ zmax + " m")

   x0 = (/140., 35.,300.,107.,0.,230.,280.,308.,0./)
   x1 = (/285.,105.,15.,138.,15.,250.,293.,333.,360./)
   y0 = (/-12.,-12.,-12.,-12.,-30.,20.,-50.,35.,75./)
   y1 = (/12.,12.,12.,12.,-10.,50.,-15.,55.,90./)
   regname=(/"Trop Pac","Trop Ind","Trop Atl","Maritime Con","East SAtl","East NPac", \
             "East SPac","Newfoundland","Arctic"/)
   
   nreg = dimsizes(x0)

   fileid = addfile(file_netcdf,"r")
   TEMP = fileid->TEMP
   if (isatt(TEMP,"_FillValue"))
      missing = TEMP@_FillValue
   else
      missing = 1e30
   end if

   units = TEMP@units
   tlon = fileid->TLONG
   tlat = fileid->TLAT
   size = dimsizes(tlon)
   nx = size(1)
   ny = size(0)
   ulon = fileid->ULONG
   ulat = fileid->ULAT
   kmt = fileid->KMT
   kmu = fileid->KMU
   region_mask = fileid->REGION_MASK
   tarea = fileid->TAREA
   uarea = fileid->UAREA
   angle = fileid->ANGLE
   anglet = fileid->ANGLET
   z_t = fileid->z_t
   dz = fileid->dz

   nz = dimsizes(z_t)
   z_t = z_t / 100.
   kl = ind(z_t .ge. zmin .and. z_t .le. zmax)
   nk = dimsizes(kl)

   fileid_obs = addfile(file_T_obs,"r")
   TEMP_obs = fileid_obs->TEMP

   depstr = zmin + "-" + zmax
   outf = case_number+".regionalTbias."+depstr+".asc"
   if (dimsizes(dimsizes(TEMP)) .eq. 4) then
      field = TEMP(0,:,:,:)
   else
      field = TEMP
   end if
   if (dimsizes(dimsizes(TEMP_obs)) .eq. 4) then
      field_obs = TEMP_obs(0,:,:,:)
   else
      field_obs = TEMP_obs
   end if

   ; calculate weighted statistics for each region
   ;
   ; first conform the area variable with the field and mask (by setting to fill values) 
   ; all grid locations that are on land or under the ocean floor
   field_diff = field(kl,:,:)
   field_diff = field(kl,:,:) - field_obs(kl,:,:)

   c_tlon = conform_dims((/nk,ny,nx/),tlon,(/1,2/))
   c_tlat = conform_dims((/nk,ny,nx/),tlat,(/1,2/))
   c_kmt = conform_dims((/nk,ny,nx/),kmt,(/1,2/))
   z_ind = ispan(0,nk-1,1)
   cz_ind = conform_dims((/nk,ny,nx/),z_ind,0)
   c_tarea = conform_dims((/nk,ny,nx/),tarea,(/1,2/))
   c_tarea@_FillValue = tarea@_FillValue
   c_tarea = where(c_kmt .gt. cz_ind,c_tarea,c_tarea@_FillValue)
   c_tarea = where(ismissing(field_diff),c_tarea@_FillValue,c_tarea)
   ; ensure that c_tarea and field_diff have exactly the same missing values
   ; there may be some overkill here, because some points may already be set to fill values 
   field_diff = where(ismissing(c_tarea),field_diff@_FillValue,field_diff)
   delete([/c_kmt, z_ind, cz_ind /])

   ; c_tarea now maps the ocean floor in 3D: it is set to _FillValue where level depth is greater than actual depth

   regTanom = new((/nreg,nk/),float)
   regTmin = new((/nreg,nk/),float)
   regTmax = new((/nreg,nk/),float)
   regTstd = new((/nreg,nk/),float)

   regTmeananom = new(nreg,float)

   do i = 0, nreg - 1
      cta = c_tarea
      if (x1(i) .gt. x0(i)) then
         cta = where(c_tlon .gt. x0(i) .and. c_tlon .le. x1(i) .and. c_tlat .ge. y0(i) .and. c_tlat .le. y1(i),cta,cta@_FillValue)
      else
         cta = where((c_tlon .gt. x0(i) .or. c_tlon .le. x1(i)) .and. c_tlat .ge. y0(i) .and. c_tlat .le. y1(i),cta,cta@_FillValue)
      end if
      regTanom(i,:) = tofloat(dim_sum_n(field_diff * cta,(/1,2/)) / dim_sum_n(cta,(/1,2/)))
      regTstd(i,:) = tofloat(sqrt(dim_sum_n(field_diff * field_diff * cta,(/1,2/)) / dim_sum_n(cta,(/1,2/))))
      regTmin(i,:) = dim_min_n(field_diff,(/1,2/))
      regTmax(i,:) = dim_max_n(field_diff,(/1,2/))
  end do

  c_dz = conform_dims((/nreg,nk/),dz(kl),1)
  regTmeananom = dim_sum_n(regTanom * c_dz,1) / dim_sum_n(c_dz,1)
  delete(c_dz)

  ; write out an ascii file of the main statistics
  ; the first part is an awkward workaround for what in IDL is a simple 
  ; Fortran style print directive (A20 -- for right-justified string within 20 spaces)
  ; NCL could us a proper formatted print with a list for variable arguments
  ;
  rj_regname = regname ; rj = right justify
  blanks = "                    "
  do i = 0, nreg-1
     ln = strlen(rj_regname(i))
     rj_regname(i) = str_insert(rj_regname(i),str_get_cols(blanks,0,20 - ln - 1),0)
  end do
  crj_regname = conform_dims((/nreg,nk/),rj_regname,0)

  outstr = new((/nk,nreg/),string)
  do i = 0, nk -1 
     outstr(i,:) = sprinti("%3d",kl(i)) + sprintf("%14.4f",z_t(kl(i))) + crj_regname(:,i)  + \
              sprintf("%14.4f",regTanom(:,i))  + sprintf("%14.4f",regTstd(:,i))
  end do
  outf = case_number+".regionalTbias."+depstr+".asc"
  asciiwrite(outf,outstr)

  data = new((/3,nreg,nk/),float)
  data(0,:,:) = regTanom
  data(1,:,:) = regTanom - regTstd
  data(2,:,:) = regTanom + regTstd    

  ;wks = gsn_open_wks("x11","regionalTbias."+depstr)
  wks = gsn_open_wks(img_format,"regionalTbias."+depstr)
  gsn_define_colormap(wks,"table42")

  plot = new(nreg,graphic)
  do i = 0, nreg-1
     res = True
     res@gsnDraw = False
     res@gsnFrame = False
     res@vpWidthF = .75 * 0.6
     res@gsnXRefLine = 0.0
     res@gsnXRefLineColor = "red"
     res@trXMinF = -1.0
     res@trXMaxF = 1.0
     res@trYMinF = zmin
     res@trYMaxF = zmax
     res@trYReverse = True
     res@tiMainString = "" + (i+1) + ". "  + regname(i)
     res@tiYAxisString = "Depth (m)"
     if (i % 3 .eq. 0) then
        res@tiYAxisOn = True
        res@tmYLLabelsOn = True
     else
        res@tiYAxisOn = False
        res@tmYLLabelsOn = False
     end if
     res@tmYLMode = "explicit"
     res@tmYLValues = (/ 500, 1000, 1500, 2000 /)
     res@tmYLLabels = (/ "500", "1000", "1500", "2000" /)
     res@tmXBMode = "explicit"
     res@tmXBValues = (/ -1.0, -0.5, 0.0, 0.5, 1.0 /)
     res@tmXBLabels = sprintf("%.1f",res@tmXBValues)
     res@xyDashPatterns = (/ 0, 2, 2 /)
     res@xyLineColors = (/ "black", "blue", "blue" /)
     res@xyMarkLineModes = (/ "lines", "markers", "markers" /)
     res@xyMarkerColor = "blue"
     res@xyMarker = 17
     res@xyMarkerSizeF = 0.02
     plot(i) = gsn_csm_xy(wks,data(:,i,:),z_t(kl),res)
     txt_res = True
     txt_res@txFontHeightF = 0.02
     txt_res@txJust = "centerleft"
     an_id = gsn_add_text(wks,plot(i),sprintf("%6.3f",regTmeananom(i)),-.8,1800,txt_res)
  end do

  panel_res = True
  panel_res@gsnPanelScalePlotIndex = 1
  gsn_panel(wks,plot,(/3,3/),panel_res)
   
end
   
