; NCL script
; plot_vertical_cons.ncl
; Mark Stevens, Sept 2001
;**************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_vertical.ncl"

begin
 compare    = getenv("COMPARE")
 plot_type  = getenv("PLOTTYPE")
 color_type = getenv("COLORTYPE")
 rgb_file   = getenv("RGB_FILE")
 season     = getenv("SEASON")
 version    = getenv("DIAG_VERSION")
 wkdir      = getenv("WKDIR")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename
 mg_micro   = getenv("MG_MICRO")

 use_waccm_levs = getenv("USE_WACCM_LEVS")

 if( (compare .eq. "OBS").and.(mg_micro.eq."0") )then
  mg_micro = 1
  print("Cannot select mg_micro when comparing with obs. Set mg_micro to 1")
  ;exit
 end if

 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
 end if

; CASE 1 MODEL
 inptr1 = addfile(infile1,"r")

 if (ncdf_mode .eq. "write") then
   outptr1 = addfile(outfile1,"w")
 else
   outptr1 = addfile(outfile1,"c")
 end if

 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case           ; case name
 end if
 case1 = str_strip(case1)

 if (isatt(inptr1,"yrs_averaged")) then
   yrs_ave1 = inptr1@yrs_averaged
 end if
 tmp = inptr1->lat
 lev = inptr1->lev
 if (typeof(tmp).eq."double") then
   lat1 = dble2flt(tmp)
 else
   lat1 = tmp
 end if
 delete(tmp) 
 nlat1 = dimsizes(lat1)

; CASE 2 IS OBS OR MODEL
 if (compare .eq. "OBS") then
   ptr_haloe = addfile(infile2+"/HALOE_"+season+"_climo.nc","r")
 else                        ;  CASE 2 IS MODEL
   inptr2 = addfile(infile2,"r")
   if (ncdf_mode .eq. "write") then
     outptr2 = addfile(outfile2,"w")
   else
     outptr2 = addfile(outfile2,"c")
   end if
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case
   end if
   case2 = str_strip(case2)
   if (isatt(inptr2,"yrs_averaged")) then
     yrs_ave2 = inptr2@yrs_averaged
   end if
   tmp = inptr2->lat
   if (typeof(tmp).eq."double") then
     lat2 = dble2flt(tmp)
   else
     lat2 = tmp
   end if
   delete(tmp) 
   nlat2 = dimsizes(lat2)
 end if

;----------------------------------------------------------------------
 if (compare .eq. "OBS") then
   haloe_vars = (/"O3","H2O","CH4","HCL","HF","NO","NO2"/) 
; corresponding model variables
   obsvars    = (/"O3","Q","CH4","HCL","HF","NO","NO2"/) 
   nvars = dimsizes(obsvars)
; contour levels
   con = new((/nvars,15/),float)
   dcon = new ((/nvars,15/),float)

   con(0,:)=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/)   ; SHUM
   dcon(0,:)=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
   con(1,:) = con(0,:)     ; SHUM ERA40
   dcon(1,:) = dcon(0,:)   ; SHUM ERA40
   con(2,:) = con(0,:)     ; SHUM ERAI
   dcon(2,:) = dcon(0,:)   ; SHUM ERAI
   con(3,:)=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; RELHUM NCEP
   dcon(3,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
   con(4,:) = con(3,:)    ; RELHUM ERA40
   dcon(4,:) = dcon(3,:)
   con(5,:) = con(3,:)    ; RELHUM ERAI
   dcon(5,:) = dcon(3,:)
   con(6,:)=(/-20,-15,-10,-5,0,5,10,15,20,25,30,40,50,60,70/) ; U
   dcon(6,:)=(/-18,-15,-12,-9,-6,-3,-1,0,1,3,6,9,12,15,18/)

;--------------------------------------------------------------------
   plev = plvlH(::-1)               ; flip to bottom to top
   plev@units = "mb"               ; flip to bottom to top
;  plot from 1000 to 4 mb
   vars_top = (/"O3","Q","CH4","HCl","HF","NO","NO2"/)
   if (use_waccm_levs .eq. "False") then
     ptop  =  4.83445                      ; topmost pressure level
   else
     ptop = 2.9935e-3
   end if
    print(plev)
   itop   = ind(plev.eq.ptop)       ; index of top level 

;--------------------------------------------------------------------
;  plot from 1000 to 100 mb
   vars_trop1 =(/""/)
   ptrop1 = 100.0                   ; tropopause pressure level 1 
   itrop1 = ind(plev.eq.ptrop1)     ; index of tropopause level 1
;--------------------------------------------------------------------
;  plot from 1000 to 300 mb
   vars_trop2 =(/""/)
   ptrop2 = 300.0                   ; tropopause pressure level 2 
   itrop2 = ind(plev.eq.ptrop2)     ; index of tropopause level 2
 else
 end if

; all model data is interpolated to the same 16 pressure levels for
; comparison to obs data, or 25 levels for model-to-model comparisons
 
; linear vertical scale
 if (use_waccm_levs .eq. "False") then
   linear = (/ "" /)
 else
   linear = (/ "" /)
 end if

;**********************************************************************
; common resources for contour plots
 cnplot = new(3,"graphic")
 cres                        = True        
 cres@gsnDraw                = False      
 cres@gsnFrame               = False
 cres@trXReverse             = True
 cres@tiYAxisString          = "Pressure (mb)"  
 cres@txFontHeightF = 0.023
 if (color_type .eq. "COLOR") then
   cres@cnLevelSelectionMode = "ExplicitLevels" 
   cres@cnFillOn             = True
   cres@cnLinesOn            = False
   cres@cnLineLabelsOn       = False
   cres@lbTitleOn = True
   cres@lbLabelFontHeightF = 0.018
   cres@lbTitleFontHeightF = 0.02
   cmap = RGBtoCmap(rgb_file)
 else
   cres@cnLevelSelectionMode = "ManualLevels" 
   cres@cnLinesOn              = True 
   cres@cnLineLabelsOn         = True 
   cres@cnLineLabelInterval    = 1
   cres@cnLineLabelFontHeightF = .02
   cres@cnInfoLabelFontHeightF = .02
   cnlvls = 15
   diffcnlvls = 12
 end if
;-------------------------------------------
; common resoureces for panel plot 
 pan = True
 pan@gsnMaximize = True
 pan@gsnPaperOrientation = "portrait"
 pan@txString = season
 pan@txFontHeightF = 0.018
 pan@gsnFrame = False
;***********************************************************
vunits = (/"ppmv","ppmv","ppbv","ppbv","ppbv","ppbv","ppbv"/)
do i = 0,nvars-1
; print("i = "+i+": "+obsvars(i)) ; BRH

; CASE 1 MODEL
; if (obsvars(i) .eq. "T") then
    A = vertical_haloe (inptr1,outptr1,compare,obsvars(i),vunits(i))
    printVarSummary(A)
; end if

  if (all(A.eq.-999.)) then
    print (obsvars(i)+" not present in test case input file.")
    delete (A)
    continue         ; proceed to next variable in do loop 
  end if

  if (compare .eq. "OBS") then        ; CASE 2 IS OBS
  ; if (any(haloe_vars(i).eq.obsvars)) then
      inptr2 = ptr_haloe
      case2 = "HALOE"
      plev2 = inptr2->lev             ; 8-17 constant pressure levels
      iNtrop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iNtrop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      iNtop   = ind(plev2.eq.ptop)    ; index of top level
      delete(plev2)
      tmp = inptr2->$haloe_vars(i)$(:,:)  ; get from obs data file
      printVarSummary(tmp)
    ; B = dim_avg_Wrap(tmp)             ; which is bottom to top
      B = tmp
      printVarSummary(B)
  ; end if
    lat2 = inptr2->lat      ; obs data could be on anyy grid
    nlat2 = dimsizes(lat2)
    delete (tmp)
  else                                ; CASE 2 IS MODEL
  end if

  if (all(B.eq.-999.)) then
    print (obsvars(i)+" not present in control case input file.")
    delete (A)
    delete (B)
    continue         ; proceed to next variable in do loop 
  end if

  if (any(obsvars(i) .eq. vars_top)) then  ; change top level plotted 
    cres@trYMinF = ptop   
    itop1 = itop               ; model 1 top
    if (compare.eq."OBS") then
      if (case2.eq."HALOE") then
        itop2 = iNtop
      end if
    else
      itop2 = itop             ; model 2 top
    end if
  end if
  if (any(obsvars(i) .eq. vars_trop1)) then  ; change top level plotted 
    cres@trYMinF = ptrop1
    itop1 = itrop1              ; model 1 trop1 
    if (compare.eq."OBS") then
       itop2 = iNtop
    else
      itop2 = itrop1            ; model 2 trop1
    end if
  end if
  if (any(obsvars(i) .eq. vars_trop2)) then  ; change top level plotted 
    cres@trYMinF = ptrop2
    itop1 = itrop2              ; model 1 trop2
    if (compare.eq."OBS") then
    else
      itop2 = itrop2            ; model 2 trop2
    end if
  end if

; for model-to-model only
  if (compare .ne. "OBS") then
    if (any(obsvars(i) .eq. vars_trop3)) then  ; change top level plotted 
      cres@trYMinF = ptrop3
      itop1 = itrop3            ; model 1 trop3
      itop2 = itrop3            ; model 2 trop3
    end if
  end if
 print(itop1)
 data1 = A(0:itop1,:)          ; model data(lev,lat)
 data2 = B(0:itop2,:)          ; model or obs data(lev,lat)

  data1!0 = "lev"
  data1!1 = "lat"
  data2!0 = "lev"
  data2!1 = "lat"

;------------------------- Open files for plots -----------------------------
  if (use_waccm_levs .eq. "False") then
    set_prefix = "cset2_"
  else
    set_prefix = "wset2_"
  end if

  if (compare.eq."OBS") then
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+obsvars(i)+"_obsc")
      gsn_define_colormap(wks,cmap)
    else
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+obsvars(i)+"_obs")
    end if
  else
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+vars(i)+"_c")
      gsn_define_colormap(wks,cmap)
    else
      wks = gsn_open_wks(plot_type,wkdir+set_prefix+season+"_"+vars(i))
    end if
  end if 
;-------------------------------------------------------------------------
; case plots of latitude(x) vs. pressure/height(y)

  if (any(obsvars(i) .eq. linear)) then
    cres@trYLog = False
  else
    cres@trYLog = True
  end if

  min1 = min(data1)
  max1 = max(data1)
  min2 = min(data2)
  max2 = max(data2)

  if (color_type .eq. "COLOR") then
    cres@lbLabelStride  = 2
    cres@lbOrientation = "Horizontal"
    cres@cnLevels = con(i,:)
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                       "  MAX = "+sprintf("%6.2f",max1)
  else
    minab = min((/min1,min2/))
    maxab = min((/max1,max2/))
    mnmxint = nice_mnmxintvl (minab,maxab,cnlvls,False)
    cres@cnMinLevelValF = mnmxint(0)
    cres@cnMaxLevelValF = mnmxint(1)
    cres@cnLevelSpacingF = mnmxint(2)
  end if

  if (isvar("yrs_ave1")) then
    cres@tiMainString = case1+" (yrs "+yrs_ave1+")"
  else  
    cres@tiMainString = case1
  end if
    cnplot(0)  = gsn_csm_contour(wks,data1,cres)
    delete (cres@lbTitleString)
  delete (cres@tiMainString)

  if (isvar("yrs_ave2")) then
    cres@tiMainString = case2+" (yrs "+yrs_ave2+")"
  else  
    cres@tiMainString = case2
  end if
  if (color_type .eq. "COLOR") then
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                       "  MAX = "+sprintf("%6.2f",max2)
  end if

    cnplot(1)  = gsn_csm_contour(wks,data2,cres)
  if (color_type .eq. "MONO") then
    cnplot(1) = ZeroNegDashLineContour(cnplot(1))
  else
    delete (cres@cnLevels)
    delete (cres@lbLabelStride)
    delete (cres@lbOrientation)
    delete (cres@lbTitleString)
  end if
  delete (cres@tiMainString)
  delete (min1)
  delete (max1)
  delete (min2)
  delete (max2)

; difference plot of latitude(x) vs. pressure(y)
; check for different number of latitudes and then
; lineary interpolate to the smaller number of latitudes

; For model compared to NCEP/JRA25 observed remove the 775 mb level
; from the model data so the levels are the same as the NCEP/JRA25 levels.

  if (compare.ne."OBS") then   ; both are models on same pressure levels
                               ; but not necessarily the same grids

    if (nlat1 .ne. nlat2) then         ; lat grids different
      if (nlat1 .gt. nlat2) then     
        tmp1 = linint1 (lat1,data1,False,lat2,0)
        C = data2
        C = (/tmp1-data2/)               ; get diff values
        delete (tmp1)
      else
        tmp2 = linint1 (lat2,data2,False,lat1,0)
        C = data1                        ; copy dims,coords
        C = (/data1-tmp2/)               ; get diff values
        delete (tmp2)
      end if
    else                                 ; same grid latitudes
      C = data1                          ; copy dims,coords
      C = (/data1-data2/)                ; get diff values 
    end if

  else                                   ; case 2 is OBS data on T42
  ;print("==========================================")   ;++ hannay
  ;print(case1)  
  ;print(nlat1)
  ;print("Case ====>"+case2) 
  ;print("nlat (obs) ="+ nlat2)
  ;print("nlat (cam) ="+ nlat1)

   if (nlat1 .ne. nlat2) then           ; lat grids different

      if (nlat1 .gt. nlat2) then         ;  model grid thinner than obs grid
        tmp1 = linint1_Wrap (lat1,data1,False,lat2,0)  ; interp model data to obs grid
        C = data2
        C = (/tmp1-data2/)                ; get diff values
        delete (tmp1)
      else                                         ; obs grid thinner than model grid   
        tmp2 = linint1_Wrap (lat2,data2,False,lat1,0)   ; interp to model grid 
        C = data1                        ; copy dims,coords
        C = (/data1-tmp2/)               ; get diff values
        delete(tmp2)
      end if
    else                                 ; same grid latitudes
      ; hannay: we need to do something about ERAI
      C = data1                          ; copy dims,coords
      C = (/data1-data2/)                ; get diff values 
    end if
  end if
  ; print("========================")
  mind = min(C)
  maxd = max(C)

  cres@tiMainString = case1+" - "+case2
  if (color_type .eq. "COLOR") then
    cres@lbLabelStride = 1
    cres@lbOrientation = "Vertical"
    cres@lbBoxMinorExtentF = 0.18
    cres@cnLevels = dcon(i,:)
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                       "  MAX = "+sprintf("%6.2f",maxd)
  else
    mnmxint = nice_mnmxintvl (mind,maxd,diffcnlvls,False)
    cres@cnMinLevelValF = mnmxint(0)
    cres@cnMaxLevelValF = mnmxint(1)
    cres@cnLevelSpacingF = mnmxint(2)
  end if

; BRH edit for COSP: CFAD_DBZE94_CS has a height vertical coordinate
; as opposed to a pressure coordinate, so we need to treat it
; differently.
    cnplot(2)= gsn_csm_contour(wks,C,cres)    ; contour plot

  if (color_type .eq. "COLOR") then
    delete (cres@lbTitleString)
    delete (cres@lbOrientation)
    delete (cres@lbLabelStride)
    delete (cres@lbBoxMinorExtentF)
    delete (cres@cnLevels)
  else
    cnplot(2) = ZeroNegDashLineContour(cnplot(2))
  end if

  if (time_stamp .eq. "True") then
    pan@gsnPanelBottom = 0.05
    gsn_panel(wks,cnplot,(/2,2/),pan)         ; panel plot
    infoTimeStamp(wks,0.011,"DIAG Version: "+version)
  else
    gsn_panel(wks,cnplot,(/2,2/),pan)         ; panel plot
  end if
  frame (wks)


;  delete (cres@trYMinF)
  delete (A)
  delete (B)
  delete (C)
  delete (data1)
  delete (data2)
  delete (mind)
  delete (maxd)
  if (compare.eq."OBS") then
    delete (lat2)
    delete (nlat2)
  end if
end do

end
