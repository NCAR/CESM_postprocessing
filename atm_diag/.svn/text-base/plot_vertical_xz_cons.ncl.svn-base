; NCL script
; plot_vertical_cons.ncl
; Mark Stevens, Sept 2001
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_vertical_xz.ncl"

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
 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
 end if
 latlim     = 5. 

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
 if (isatt(inptr1,"yrs_averaged")) then
   yrs_ave1 = inptr1@yrs_averaged
 end if
 tmp = inptr1->lon
 if (typeof(tmp).eq."double") then
   lon1 = dble2flt(tmp)
 else
   lon1 = tmp
 end if
 delete(tmp) 
 nlon1 = dimsizes(lon1)

; CASE 2 IS OBS OR MODEL
 if (compare .eq. "OBS") then
   ptr_merra = addfile(infile2+"/MERRA_"+season+"_climo.nc","r")
   ptr_erai = addfile(infile2+"/ERAI_"+season+"_climo.nc","r")
   ptr_era40 = addfile(infile2+"/ERA40_"+season+"_climo.nc","r")
   ptr_jra25 = addfile(infile2+"/JRA25_"+season+"_climo.nc","r")
   ptr_nvap = addfile(infile2+"/NVAP_"+season+"_climo.nc","r")
   ptr_erbe = addfile(infile2+"/ERBE_"+season+"_climo.nc","r")
   ptr_xa = addfile(infile2+"/XIEARKIN_"+season+"_climo.nc","r")
   ptr_isccp = addfile(infile2+"/ISCCP_"+season+"_climo.nc","r")
   ptr_airs = addfile(infile2+"/AIRS_"+season+"_climo.nc","r")
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
   if (isatt(inptr2,"yrs_averaged")) then
     yrs_ave2 = inptr2@yrs_averaged
   end if
   tmp = inptr2->lon
   if (typeof(tmp).eq."double") then
     lon2 = dble2flt(tmp)
   else
     lon2 = tmp
   end if
   delete(tmp) 
   nlon2 = dimsizes(lon2)
 end if

;----------------------------------------------------------------------
 con_SHUM = (/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/)   ; SHUM
 dcon_SHUM =(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)  
 con_RELHUM=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; RELHUM
 dcon_RELHUM=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
 con_U=(/-60.,-50.,-40.,-30,-20.,-15,-10,-5,0,5,10,15,20,25,30/) ; U
 dcon_U=(/-18,-15,-12,-9,-6,-3,-1,0,1,3,6,9,12,15,18/)
 con_T=(/180,185,190,200,210,220,230,240,250,260,270,280,290,295,300/) ; T
 dcon_T=(/-9,-7,-5,-4,-3,-2,-1,0,1,2,3,4,5,7,9/)
 con_OMEGA=(/-100,-80,-60,-40,-20,-10,-5,0,5,10,20,30,40,50,60/) ; OMEGA
 dcon_OMEGA=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
 con_CFAD = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/)  ; BRH CFAD_DBZE94_CS
 dcon_CFAD = (/-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/) ; BRH

 if (compare .eq. "OBS") then
   jra25_vars = (/"T_JRA25","U_JRA25","SHUM_JRA25"/)
   merra_vars = (/"T_MERRA","U_MERRA","RELHUM_MERRA","SHUM_MERRA","OMEGA_MERRA"/)
   erai_vars = (/"T_ERAI","OMEGA_ERAI","SHUM_ERAI", "RELHUM_ERAI"/)
   era40_vars = (/"T_ERA40","U_ERA40","OMEGA_ERA40","SHUM_ERA40", "RELHUM_ERA40"/) 
   airs_vars =  (/"T_AIRS","RELHUM_AIRS"/)            
 
; obs vars 
; need to add "CFAD_DBZE94_CS"
   obsvars = (/"SHUM_ERA40","SHUM_ERAI", "SHUM_MERRA", "SHUM_AIRS", "SHUM_JRA25", \
               "RELHUM_AIRS","RELHUM_ERA40","RELHUM_ERAI", "RELHUM_MERRA", \
               "U_ERA40","U_ERAI","U_JRA25", "U_MERRA",  \
               "T_ERA40","T_ERAI", "T_AIRS", "T_JRA25","T_MERRA", \
               "OMEGA_ERA40", "OMEGA_ERAI", "OMEGA_JRA25", "OMEGA_MERRA"\  
               /) ; BRH

; corresponding model variables
; need to add "CFAD_DBZE94_CS"
   vars    = (/ "SHUM","SHUM", "SHUM","SHUM","SHUM", \
                "RELHUM","RELHUM", "RELHUM","RELHUM",\
                "U","U", "U", "U", \
                "T","T", "T","T","T",\
                "OMEGA","OMEGA","OMEGA", "OMEGA"\
                /) ; BRH
   nvars = dimsizes(vars)

  ; contour levels
   con = new((/nvars,15/),float)
   dcon = new ((/nvars,15/),float)
   con    = (/  con_SHUM,con_SHUM, con_SHUM,con_SHUM,con_SHUM, \
                con_RELHUM,con_RELHUM,con_RELHUM,con_RELHUM,  \
                con_U,con_U, con_U, con_U, \
                con_T,con_T, con_T,con_T,con_T,\
                con_OMEGA,con_OMEGA,con_OMEGA,con_OMEGA \
                /) 

   dcon    = (/ dcon_SHUM,dcon_SHUM, dcon_SHUM,dcon_SHUM,dcon_SHUM, \
                dcon_RELHUM, dcon_RELHUM,dcon_RELHUM,dcon_RELHUM, \
                dcon_U,dcon_U, dcon_U, dcon_U , \
                dcon_T,dcon_T, dcon_T,dcon_T,dcon_T,\
                dcon_OMEGA,dcon_OMEGA,dcon_OMEGA, dcon_OMEGA\
                /)  
           
;--------------------------------------------------------------------
   plev = plvlO(::-1)               ; flip to bottom to top
;  plot from 1000 to 30 mb
   vars_top = (/"U","T"/)
   ptop  =  30.0      ; topmost pressure level
   ptop_merra  =  100.0     
   itop   = ind(plev.eq.ptop)       ; index of top level 
;--------------------------------------------------------------------
;  plot from 1000 to 100 mb
   vars_trop1 =(/"OMEGA"/)
   ptrop1 = 100.0                   ; tropopause pressure level 1 
   itrop1 = ind(plev.eq.ptrop1)     ; index of tropopause level 1
;--------------------------------------------------------------------
;  plot from 1000 to 300 mb
   vars_trop2 =(/"SHUM","RELHUM"/)
   ptrop2 = 300.0                   ; tropopause pressure level 2 
   itrop2 = ind(plev.eq.ptrop2)     ; index of tropopause level 2
  

 else


   vars =(/"SHUM","RELHUM","U","T","OMEGA","TDH","TDM", \
           "VBSTAR_UBSTAR","UBSTAR_TBSTAR","OBSTAR_TBSTAR",\
           "UBSTAR_QBSTAR","EKE","UT","UQ","CLOUD","QRS","QRL", \
           "CWAT","ICLDTWP","GCLDLWP_ICE","GCLDLWP_LIQUID", \
           "VPUP_BAR","UPTP_BAR","UPQP_BAR","OPTP_BAR","ICWMR","ICIMR"/)

   nvars = dimsizes(vars)

; dcontour levels
   con = new((/nvars,15/),float)
   dcon = new ((/nvars,15/),float)
   con(0,:)=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,16/)   ; SHUM
   dcon(0,:)=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
   con(1,:)=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; RELHUM
   dcon(1,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
   con(2,:)=(/-60,-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,25,30/) ; U
   dcon(2,:)=(/-18,-15,-12,-9,-6,-3,-1,0,1,3,6,9,12,15,18/)
   con(3,:)=(/180,185,190,200,210,220,230,240,250,260,270,280,290,295,300/) ; T
   dcon(3,:)=(/-9,-7,-5,-4,-3,-2,-1,0,1,2,3,4,5,7,9/)
   con(4,:)=(/-100,-80,-60,-40,-20,-10,-5,0,5,10,20,30,40,50,60/) ; OMEGA
   dcon(4,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
   con(5,:)=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/) ; TDH
   dcon(5,:)=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
   con(6,:)=(/-2.1,-1.8,-1.5,-1.2,-.9,-.6,-.3,0,.3,.6,.9,1.2,1.5,1.8,2.1/) ;TDM
   dcon(6,:)=(/-2.0,-1.5,-1.0,-.8,-.6,-.2,-.1,0,.1,.2,.6,.8,1.0,1.5,2.0/)
   con(7,:)=(/-30,-25,-20,-15,-10,-5,-2,0,2,5,10,15,20,25,30/) ; VB_UB
   dcon(7,:)=(/-10,-8,-6,-4,-3,-2,-1,0,1,2,3,4,6,8,10/)
   con(8,:)=(/-20,-16,-12,-8,-6,-4,-2,0,2,4,6,8,12,16,20/) ; UB_TB
   dcon(8,:)=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/)
   con(9,:)=(/-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250/);OB_TB
   dcon(9,:)=(/-100,-80,-60,-40,-20,-10,-5,0,5,10,20,40,60,80,100/)
   con(10,:)=(/-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7/) ; UB_QB
   dcon(10,:)=(/-2.1,-1.8,-1.5,-1.2,-.9,-.6,-.3,0,.3,.6,.9,1.2,1.5,1.8,2.1/)
   con(11,:)=(/10,30,50,70,90,110,130,150,170,190,210,230,250,270,290/) ; EKE
   dcon(11,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
   con(12,:)=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/) ; UT
   dcon(12,:)=(/-2.4,-2,-1.6,-1.2,-.8,-.4,-.2,0,.2,.4,.8,1.2,1.6,2,2.4/)
   con(13,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/) ; UQ
   dcon(13,:)=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/)
   con(14,:)=(/.05,.1,.15,.2,.25,.3,.35,.4,.45,.5,.55,.6,.65,.7,.75/) ; CLOUD 
   dcon(14,:)=(/-.20,-.17,-.14,-.11,-.08,-.05,-.02,0,.02,.05,.08,.11,.14,.17,.20/)
   con(15,:)=(/.1,.2,.3,.4,.5,.6,.7,.8,.9,1,1.1,1.2,1.3,1.4,1.5/) ; QRS
   dcon(15,:)=(/-.4,-.3,-.25,-.2,-.15,-.1,-.05,0,.05,.1,.15,.2,.25,.3,.4/)
   con(16,:)=(/-7,-6,-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-.5,0,.5,1/) ;  QRL
   dcon(16,:)=(/-1,-.8,-.6,-.4,-.3,-.2,-.1,0,.1,.2,.3,.4,.6,.8,1/)
   con(17,:)=(/.01,.015,.02,.025,.03,.035,.04,.05,.06,.07,.08,.09,.10,.11,.12/) ; CWAT
   dcon(17,:)=(/-.06,-.05,-.04,-.03,-.02,-.01,-.005,0,.005,.01,.02,.03,.04,.05,.06/)
   con(18,:)=(/5,10,20,50,100,150,200,300,400,500,600,700,800,900,1000/) ; ICLDTWP
   dcon(18,:)=(/-200,-150,-100,-50,-20,-10,-5,0,5,10,20,50,100,150,200/)
   con(19,:)=(/.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18/);GCLDLWP_ICE
   dcon(19,:)=(/-10,-8,-6,-4,-2,-1,-.5,0,.5,1,2,4,6,8,10/)
   con(20,:)=(/2,4,6,8,10,12,14,16,20,25,30,35,40,45,50/) ; GCLDLWP_LQD
   dcon(20,:)=(/-30,-25,-20,-15,-10,-5,-1,0,1,5,10,15,20,25,30/)
   con(21,:)=(/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/) ; VPUP_BAR
   dcon(21,:)=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/)
   con(22,:)=(/-18,-14,-10,-8,-6,-4,-2,0,2,4,6,8,10,14,18/) ; UPTP_BAR
   dcon(22,:)=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/)
   con(23,:)=(/-14,-12,-10,-6,-4,-2,-1,0,1,2,4,6,10,12,14/) ; UPQP_BAR
   dcon(23,:)=(/-3.5,-3,-2.5,-2,-1.5,-1,-.5,0,.5,1,1.5,2,2.5,3,3.5/)
   con(24,:)=(/-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250/)
   dcon(24,:)=(/-100,-80,-60,-40,-20,-10,-5,0,5,10,20,40,60,80,100/) ;OPTP_BAR
   con(25,:)=(/0.01,0.02,0.03,0.04,0.05,0.08,0.1,0.12,0.14,0.16,0.18,0.20,0.22,0.24,0.26/)
   dcon(25,:)=(/-0.12,-0.1,-0.08,-0.06,-0.04,-0.02,-0.01,0,0.01,0.02,0.04,0.06,0.08,0.1,0.12/) ;ICWMR
   con(26,:)=(/0.001,0.002,0.004,0.006,0.008,0.01,0.012,0.015,0.02,0.025,0.03,0.035,0.04,0.045,0.05/)
   dcon(26,:)=(/-0.02,-0.015,-0.010,-0.005,-0.004,-0.002,-0.001,0,0.001,0.002,0.004,0.005,0.01,0.015,0.02/) ;ICWMR
;------------------------------------------------------------------------- 
   plev = plvlM(::-1)                 ; flip to bottom to top
;  plot these from 1000 to 30 mb
   vars_top = (/"RELHUM","U","T","VBSTAR_UBSTAR","EKE","CLOUD","QRS","QRL",  \
                "VPUP_BAR","UPTP_BAR"/)
   ptop  =  30.0                      ; topmost pressure level
   itop   = ind(plev.eq.ptop)         ; index of top level 
;------------------------------------------------------------------------- 
;  plot these below 100mb
   vars_trop1 =(/"OMEGA","UT","UBSTAR_TBSTAR","GCLDLWP_ICE", \
                 "OPTP_BAR","ICIMR"/)
   ptrop1 = 100.0                             ; tropopause pressure level  1 
   itrop1 = ind(plev.eq.ptrop1)        ; index of tropopause level 1
;--------------------------------------------------------CWAT----------------- 
;  plot these below 300mb
   vars_trop2=(/"SHUM","TDH","OBSTAR_TBSTAR","CWAT","GCLDLWP_LIQUID", \
                "ICLDTWP","UPQP_BAR","ICWMR"/)
   ptrop2 = 300.0                      ; tropopause pressure level 2 
   itrop2 = ind(plev.eq.ptrop2)        ; index of tropopause level 2
;------------------------------------------------------------------------- 
;  plot these below 500mb
   vars_trop3 =(/"TDM","UQ","UBSTAR_QBSTAR"/)
   ptrop3 = 500.0                      ; tropopause pressure level 3 
   itrop3 = ind(plev.eq.ptrop3)        ; index of tropopause level 3
 end if

; all model data is interpolated to the same 16 pressure levels for
; comparison to obs data, or 25 levels for model-to-model comparisons
 
; linear vertical scale
 linear = (/"SHUM","RELHUM","TDH","TDM","UT","UQ","CLOUD","QRS","QRL", \
             "CWAT","ICLDTWP","GCLDLWP_ICE","GCLDLWP_LIQUID"/)

;**********************************************************************
; common resources for contour plots
 cnplot = new(3,"graphic")
 cres                        = True        
 cres@gsnDraw                = False      
 cres@gsnFrame               = False
 cres@trXReverse             = False
 cres@tiYAxisString          = "Pressure (mb)" 
 cres@tiMainFontHeightF      = 0.05  
 cres@txFontHeightF = 0.04
 cres@tiMainFont = "Helvetica"
 cres@vpXF = 0.05
 cres@vpWidthF = 1.80
 cres@vpHeightF = 0.70
 cres@pmLabelBarWidthF = 1.80

 if (color_type .eq. "COLOR") then
   cres@cnLevelSelectionMode = "ExplicitLevels" 
   cres@cnFillOn             = True
   cres@cnFillMode           = "AreaFill"
   cres@cnLinesOn            = False
   cres@cnLineLabelsOn       = False
   cres@lbBoxMinorExtentF = 0.1
   cres@lbTitleOn = True
   cres@lbLabelFontHeightF = 0.03
   cres@lbTitleFontHeightF = 0.03
   cmap = RGBtoCmap(rgb_file)
 else
   cres@cnLevelSelectionMode = "ManualLevels" 
   cres@cnLinesOn              = True 
   cres@cnLineLabelsOn         = True 
   cres@cnLineLabelInterval    = 1
   cres@cnLineLabelFontHeightF = .03
   cres@cnInfoLabelFontHeightF = .03
   cnlvls = 15
   diffcnlvls = 12
 end if
;-------------------------------------------
; common resources for panel plot 
 pan = True
 pan@gsnMaximize = True
 pan@gsnPaperOrientation = "portrait"
 pan@gsnPanelYWhiteSpacePercent = 2
 pan@txString = season
 pan@txFontHeightF = 0.018
 pan@gsnFrame = False
;***********************************************************

do i = 0,nvars-1

  ;print("=== "+ obsvars(i))


; CASE 1 MODEL
  if (vars(i) .eq. "CLOUD") then
    A = vertical_xz_CLOUD (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "CWAT") then
    A = vertical_xz_CWAT (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "EKE") then
    A = vertical_xz_EKE (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "ICWMR") then
    A = vertical_xz_ICWMR (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "ICIMR") then
    A = vertical_xz_ICIMR (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "GCLDLWP_ICE") then
    A = vertical_xz_GCLDLWP_ICE (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "GCLDLWP_LIQUID") then
    A = vertical_xz_GCLDLWP_LIQUID (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "ICLDTWP") then
    A = vertical_xz_ICLDTWP (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "OMEGA") then
    A = vertical_xz_OMEGA (inptr1,outptr1,latlim,compare)
  end if
  if (vars(i) .eq. "QRL") then
    A = vertical_xz_QRL (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "QRS") then
    A = vertical_xz_QRS (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "RELHUM") then
    A = vertical_xz_RELHUM (inptr1,outptr1,latlim,compare)
  end if
  if (vars(i) .eq. "SHUM") then
    A = vertical_xz_SHUM (inptr1,outptr1,latlim,compare)
  end if
  if (vars(i) .eq. "T") then
    A = vertical_xz_T (inptr1,outptr1,latlim,compare)
  end if
  if (vars(i) .eq. "TDH") then
    A = vertical_xz_TDH (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "TDM") then
    A = vertical_xz_TDM (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "U") then
    A = vertical_xz_U (inptr1,outptr1,latlim,compare)
  end if
  if (vars(i) .eq. "UQ") then
    A = vertical_xz_UQ (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "UT") then
    A = vertical_xz_UT (inptr1,outptr1,latlim)
  end if

;----------------- EDDY FLUXES ------------------
  if (vars(i) .eq. "OBSTAR_TBSTAR") then
    A = vertical_xz_OBSTAR_TBSTAR (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "OPTP_BAR") then
    A = vertical_xz_OPTP_BAR (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "UBSTAR_QBSTAR") then
    A = vertical_xz_UBSTAR_QBSTAR (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "UPQP_BAR") then
    A = vertical_xz_UPQP_BAR (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "UBSTAR_TBSTAR") then
    A = vertical_xz_UBSTAR_TBSTAR (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "UPTP_BAR") then
    A = vertical_xz_UPTP_BAR (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "VBSTAR_UBSTAR") then
    A = vertical_xz_VBSTAR_UBSTAR (inptr1,outptr1,latlim)
  end if
  if (vars(i) .eq. "VPUP_BAR") then
    A = vertical_xz_VPUP_BAR (inptr1,outptr1,latlim)
  end if

  if (all(A.eq.-999.)) then
    print (vars(i)+" not present in test case input file.")
    delete (A)
    continue         ; proceed to next variable in do loop 
  end if

  if (compare .eq. "OBS") then        ; CASE 2 IS OBS

    if (any(obsvars(i).eq.merra_vars)) then
      inptr2 = ptr_merra
      case2 = "MERRA"
      plev2 = inptr2->lev             ; 17 constant pressure levels
      iMtrop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iMtrop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      iMtop   = ind(plev2.eq.ptop_merra)    ; index of top level
      delete(plev2)
    end if
    if (any(obsvars(i).eq.jra25_vars)) then
      inptr2 = ptr_jra25
      case2 = "JRA25"
      plev2 = inptr2->plev             ; 17 constant pressure levels
      iNtrop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iNtrop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      iNtop   = ind(plev2.eq.ptop)    ; index of top level
      delete(plev2)
    end if
    if (any(obsvars(i).eq.era40_vars)) then
      inptr2 = ptr_era40
      case2 = "ERA40"
      plev2 = inptr2->lev             ; 17 constant pressure levels 
      iE40trop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iE40trop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      iE40top   = ind(plev2.eq.ptop)    ; index of top level
      delete(plev2)
    end if
    if (any(obsvars(i).eq.erai_vars)) then
      inptr2 = ptr_erai
      case2 = "ERAI"
      plev2 = inptr2->lev             ; 17 constant pressure levels 
      iEtrop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iEtrop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      iEtop   = ind(plev2.eq.ptop)    ; index of top level
      delete(plev2)
    end if
    if (any(obsvars(i).eq.airs_vars)) then
      inptr2 = ptr_airs
      case2 = "AIRS"
      plev2 = inptr2->lev             ; 17 constant pressure levels 
      iAtrop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iAtrop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      Aptop = 70.
      if (ptop.gt.Aptop) then         ; AIRS only goes to 70mb. 
        Aptop = ptop
      end if
      iAtop   = ind(plev2.eq.Aptop)    ; index of top level
      delete(plev2)   
    end if

    lon2 = inptr2->lon      ; obs can be on anyy grid.
    nlon2 = dimsizes(lon2)
    tmp = inptr2->$vars(i)$(0,:,:,:)  ; get from obs data file
    tmp!0 = "lev"
    B = dim_avg_Wrap(tmp(lev|:,lon|:,{lat|-latlim:latlim}))             ; which is bottom to top
    delete (tmp)
  else                                ; CASE 2 IS MODEL
    if (vars(i) .eq. "CLOUD") then
      B = vertical_xz_CLOUD (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "CWAT") then
      B = vertical_xz_CWAT (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "EKE") then
      B = vertical_xz_EKE (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "ICWMR") then
      B = vertical_xz_ICWMR (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "ICIMR") then
      B = vertical_xz_ICIMR (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "GCLDLWP_ICE") then
      B = vertical_xz_GCLDLWP_ICE (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "GCLDLWP_LIQUID") then
      B = vertical_xz_GCLDLWP_LIQUID (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "ICLDTWP") then
      B = vertical_xz_ICLDTWP (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "OMEGA") then
      B = vertical_xz_OMEGA (inptr2,outptr2,latlim,compare)
    end if
    if (vars(i) .eq. "QRL") then
      B = vertical_xz_QRL (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "QRS") then
      B = vertical_xz_QRS (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "RELHUM") then
      B = vertical_xz_RELHUM (inptr2,outptr2,latlim,compare)
    end if
    if (vars(i) .eq. "SHUM") then
      B = vertical_xz_SHUM (inptr2,outptr2,latlim,compare)
    end if
    if (vars(i) .eq. "T") then
      B = vertical_xz_T (inptr2,outptr2,latlim,compare)
    end if
    if (vars(i) .eq. "TDH") then
      B = vertical_xz_TDH (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "TDM") then
      B = vertical_xz_TDM (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "U") then
      B = vertical_xz_U (inptr2,outptr2,latlim,compare)
    end if
    if (vars(i) .eq. "UQ") then
      B = vertical_xz_UQ (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "UT") then
      B = vertical_xz_UT (inptr2,outptr2,latlim)
    end if

;----------------- EDDY FLUXES ------------------
    if (vars(i) .eq. "OBSTAR_TBSTAR") then
      B = vertical_xz_OBSTAR_TBSTAR (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "OPTP_BAR") then
      B = vertical_xz_OPTP_BAR (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "UBSTAR_QBSTAR") then
      B = vertical_xz_UBSTAR_QBSTAR (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "UPQP_BAR") then
      B = vertical_xz_UPQP_BAR (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "UBSTAR_TBSTAR") then
      B = vertical_xz_UBSTAR_TBSTAR (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "UPTP_BAR") then
      B = vertical_xz_UPTP_BAR (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "VBSTAR_UBSTAR") then
      B = vertical_xz_VBSTAR_UBSTAR (inptr2,outptr2,latlim)
    end if
    if (vars(i) .eq. "VPUP_BAR") then
      B = vertical_xz_VPUP_BAR (inptr2,outptr2,latlim)
    end if
  end if

  if (all(B.eq.-999.)) then
    print (vars(i)+" not present in control case input file.")
    delete (A)
    delete (B)
    continue         ; proceed to next variable in do loop 
  end if

  if (any(vars(i) .eq. vars_top)) then  ; change top level plotted 
    cres@trYMinF = ptop   
    itop1 = itop               ; model 1 top
    if (compare.eq."OBS") then
      if (case2.eq."ERAI") then
        itop2 = iEtop          ; obs top
      end if
      if (case2.eq."MERRA") then
        itop2 = iMtop          ; obs top
      end if
      if (case2.eq."ERA40") then
        itop2 = iE40top
      end if
      if (case2.eq."JRA25") then
        itop2 = iNtop
      end if
      if (case2.eq."AIRS") then  
        itop2 = iAtop             ; Airs only goes to 70mb
        itop1 = ind(plev.eq.Aptop) 
        cres@trYMinF = Aptop
      end if     
    else
      itop2 = itop             ; model 2 top
    end if
  end if
  if (any(vars(i) .eq. vars_trop1)) then  ; change top level plotted 
    cres@trYMinF = ptrop1
    itop1 = itrop1              ; model 1 trop1 
    if (compare.eq."OBS") then
      if (case2.eq."ERAI") then
        itop2 = iEtrop1          ; obs top
      end if
      if (case2.eq."ERA40") then
        itop2 = iE40trop1
      end if
      if (case2.eq."JRA25") then
        itop2 = iNtrop1
      end if
      if (case2.eq."MERRA") then
        itop2 = iMtrop1
      end if
      if (case2.eq."AIRS") then
        itop2 = iAtrop1
      end if
    else
      itop2 = itrop1            ; model 2 trop1
    end if
  end if
  if (any(vars(i) .eq. vars_trop2)) then  ; change top level plotted 
    cres@trYMinF = ptrop2
    itop1 = itrop2              ; model 1 trop2
    if (compare.eq."OBS") then
      if (case2.eq."ERAI") then
        itop2 = iEtrop2          ; obs top
      end if
      if (case2.eq."ERA40") then
        itop2 = iE40trop2
      end if
      if (case2.eq."JRA25") then
        itop2 = iNtrop2
      end if
      if (case2.eq."MERRA") then
        itop2 = iMtrop2
      end if
      if (case2.eq."AIRS") then
        itop2 = iAtrop2
      end if
    else
      itop2 = itrop2            ; model 2 trop2
    end if
  end if

; for model-to-model only
  if (compare .ne. "OBS") then
    if (any(vars(i) .eq. vars_trop3)) then  ; change top level plotted 
      cres@trYMinF = ptrop3
      itop1 = itrop3            ; model 1 trop3
      itop2 = itrop3            ; model 2 trop3
    end if
  end if

  data1 = A(0:itop1,:)          ; model data(lev,lon)
  data2 = B(0:itop2,:)          ; model or obs data(lev,lon)

;------------------------- Open files for plots -----------------------------
  if (compare.eq."OBS") then
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+"set4a_"+season+"_"+obsvars(i)+"_obsc")
      gsn_define_colormap(wks,cmap)
    else
      wks = gsn_open_wks(plot_type,wkdir+"set4a_"+season+"_"+obsvars(i)+"_obs")
    end if
  else
    if (color_type .eq. "COLOR") then
      wks = gsn_open_wks(plot_type,wkdir+"set4a_"+season+"_"+vars(i)+"_c")
      gsn_define_colormap(wks,cmap)
    else
      wks = gsn_open_wks(plot_type,wkdir+"set4a_"+season+"_"+vars(i))
    end if
  end if 

;-------------------------------------------------------------------------
; case plots of lonitude(x) vs. pressure/height(y)

  if (any(vars(i) .eq. linear)) then
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
    cres@lbBoxMinorExtentF = 0.15
    cres@cnMissingValFillPattern = 0               ; choose fill pattern 0 (solid fill) 
    cres@cnLevels = con(i,:)
    cres@cnMissingValFillColor = "black"
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

  cnplot(0)  = gsn_csm_pres_hgt(wks,data1,cres)
  if (color_type .eq. "MONO") then
    cnplot(0) = ZeroNegDashLineContour(cnplot(0))
  else
    delete (cres@lbTitleString)
  end if
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

  cnplot(1)  = gsn_csm_pres_hgt(wks,data2,cres)
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

; difference plot of lonitude(x) vs. pressure(y)
; check for different number of lonitudes and then
; lineary interpolate to the smaller number of lonitudes

; For model compared to JRA25 observed remove the 775 mb level
; from the model data so the levels are the same as the JRA25 levels.

  if (compare.ne."OBS") then   ; both are models on same pressure levels
                         ; but not necessarily the same grids
    if (nlon1 .ne. nlon2) then         ; lon grids different
      if (nlon1 .gt. nlon2) then     
        tmp1 = linint1 (lon1,data1,False,lon2,0)
        C = data2
        C = (/tmp1-data2/)               ; get diff values
        delete (tmp1)
      else
        tmp2 = linint1 (lon2,data2,False,lon1,0)
        C = data1                        ; copy dims,coords
        C = (/data1-tmp2/)               ; get diff values
        delete (tmp2)
      end if
    else                                 ; same grid lonitudes
      C = data1                          ; copy dims,coords
      C = (/data1-data2/)                ; get diff values 
    end if
  else                             ; case 2 is OBS data on T42
    if (nlon1 .ne. nlon2) then           ; lon grids different  
      if (nlon1 .gt. nlon2) then         ; interp model data   
        tmp1 = linint1_Wrap (lon1,data1,False,lon2,0)
        if (case2.eq."AIRS".or.case2.eq."JRA25") then         ; fix the levels 
          tmp = data2                     ; copy coords 
          tmp(0:2,:) = (/tmp1(0:2,:)/)    ; skip the 775 mb level
          tmp(3:,:) = (/tmp1(4:,:)/)      ; which is in the model 1
          tmp@long_name = data1@long_name
          delete(tmp1)
          tmp1 = tmp
          delete(tmp)
        end if
        if (case2.eq."ERAI" .or. case2.eq."MERRA") then        ; interpolate on model levels
          level1 = tmp1&lev_p
          level2 = data2&lev 
          data2_int= linint1_n_Wrap(level2, data2, False, level1, 0, 0)
          delete(data2)
          data2 =  data2_int
          delete(level1)
          delete(level2)
          delete(data2_int)
        end if
        C = data2
        C = (/tmp1-data2/)                ; get diff values
        delete (tmp1)
      else                               ; interp T42 OBS data 
        tmp2 = linint1_Wrap (lon2,data2,False,lon1,0)
        if (case2.eq."AIRS".or.case2.eq."JRA25") then         ; fix the levels
          copy_VarCoords(data2(:,0),tmp2(:,0))
          tmp = tmp2                      ; copy levels  
          tmp(0:2,:) = (/data1(0:2,:)/)    ; skip the ERAI 775 mb level
          tmp(3:,:) = (/data1(4:,:)/)      ; which is in the model 1
          tmp!1 = "lon" 
          delete(tmp&lon)
          tmp&lon = data1&lon
          tmp@long_name = data1@long_name
          delete(data1)
          data1 = tmp
          delete(tmp) 
       end if 
        if (case2.eq."ERAI" .or. case2.eq."MERRA") then           ; interpolate on model levels
          level1 = data1&lev_p
          level2 = tmp2&lev  
          tmp2_int= linint1_n_Wrap(level2, tmp2, False, level1, 0, 0)
          delete(tmp2)
          tmp2 =  tmp2_int
          delete(level1)
          delete(level2)
          delete(tmp2_int)
        end if
        C = data1                        ; copy dims,coords
        C = (/data1-tmp2/)               ; get diff values
        delete(tmp2)
      end if
    else                                 ; same grid lonitudes
      if (case2.eq."AIRS".or.case2.eq."JRA25") then          ; fix the levels
        tmp = data2                      ; copy coords f
        tmp(0:2,:) = (/data1(0:2,:)/)    ; skip the ERAI 775 mb level
        tmp(3:,:) = (/data1(4:,:)/)      ; which is in the model 1
        tmp@long_name = data1@long_name
        delete(data1)
        data1 = tmp
        delete(tmp) 
      end if
      if (case2.eq."ERAI".or. case2.eq."MERRA") then           ; interpolate on model levels
          level1 = data1&lev_p
          level2 = data2&lev  
          data2_int = linint1_n_Wrap(level2, data2, False, level1, 0, 0)
          delete(data2)
          data2 =  data2_int
          delete(level1)
          delete(level2)
          delete(data2_int)
      end if
      C = data1                          ; copy dims,coords
      C = (/data1-data2/)                ; get diff values 
    end if
  end if
  mind = min(C)
  maxd = max(C)

  cres@tiMainString = case1+" - "+case2
  if (color_type .eq. "COLOR") then
    cres@lbLabelStride = 1
    cres@lbOrientation = "Horizontal"
    cres@cnLevels = dcon(i,:)
    cres@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                       "  MAX = "+sprintf("%6.2f",maxd)
  else
    mnmxint = nice_mnmxintvl (mind,maxd,diffcnlvls,False)
    cres@cnMinLevelValF = mnmxint(0)
    cres@cnMaxLevelValF = mnmxint(1)
    cres@cnLevelSpacingF = mnmxint(2)
  end if

  cnplot(2)= gsn_csm_pres_hgt(wks,C,cres)    ; contour plot

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
    gsn_panel(wks,cnplot,(/3,1/),pan)         ; panel plot
    infoTimeStamp(wks,0.011,"DIAG Version: "+version)
  else
    gsn_panel(wks,cnplot,(/3,1/),pan)         ; panel plot
  end if
  frame (wks)
  
  delete (cres@trYMinF)
  delete (A)
  delete (B)
  delete (C)
  delete (data1)
  delete (data2)
  delete (mind)
  delete (maxd)
  if (compare.eq."OBS") then
    delete (lon2)
    delete (nlon2)
  end if
end do

end
