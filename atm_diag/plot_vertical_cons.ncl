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
 pt = inptr1->lev 
 lev_top1 = pt(0)
 delete(pt)

 if (isfilepresent(outfile1) .and. ncdf_mode .eq. "write") then
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
 if (typeof(tmp).eq."double") then
   lat1 = dble2flt(tmp)
 else
   lat1 = tmp
 end if
 delete(tmp) 
 nlat1 = dimsizes(lat1)

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
   ptr_cloudsatcosp = addfile(infile2+"/CLOUDSATCOSP_"+season+"_climo.nc","r") ; BRH
 else                        ;  CASE 2 IS MODEL
   inptr2 = addfile(infile2,"r")
   if (isfilepresent(outfile2) .and. ncdf_mode .eq. "write") then
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
   con_SHUM=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/)   ; SHUM
   dcon_SHUM=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
   con_RELHUM=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; RELHUM
   dcon_RELHUM=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
   con_U=(/-20,-15,-10,-5,0,5,10,15,20,25,30,40,50,60,70/) ; U
   dcon_U=(/-18,-15,-12,-9,-6,-3,-1,0,1,3,6,9,12,15,18/)
   con_T=(/180,185,190,200,210,220,230,240,250,260,270,280,290,295,300/) ; T
   dcon_T=(/-9,-7,-5,-4,-3,-2,-1,0,1,2,3,4,5,7,9/)
   con_OMEGA=(/-20,-10,-5,0,5,10,20,30,40,50,60,80,100,120,150/) ; OMEGA
   dcon_OMEGA=(/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/)
   con_CFAD = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/)  ; BRH CFAD_DBZE94_CS
   dcon_CFAD = (/-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/) ; BRH

;-------------------------------------------------------------------
;-------------------------------------------------------------------
if (compare .eq. "OBS") then
   jra25_vars = (/"T_JRA25","U_JRA25","SHUM_JRA25","OMEGA_JRA25"/)
   merra_vars = (/"T_MERRA","U_MERRA","RELHUM_MERRA","SHUM_MERRA","OMEGA_MERRA"/)
   erai_vars = (/"T_ERAI","OMEGA_ERAI","SHUM_ERAI", \
                  "RELHUM_ERAI"/)
  
   era40_vars = (/"T_ERA40","U_ERA40","OMEGA_ERA40","SHUM_ERA40", \
                  "RELHUM_ERA40"/)        
   airs_vars =  (/"T_AIRS","RELHUM_AIRS","SHUM_AIRS"/)  
   cloudsatcosp_vars = (/"CFAD_DBZE94_CS"/) ; BRH
 
; obs vars 
   obsvars = (/"SHUM_ERA40","SHUM_ERAI", "SHUM_MERRA", "SHUM_AIRS", "SHUM_JRA25", \
               "RELHUM_AIRS","RELHUM_ERA40","RELHUM_ERAI", "RELHUM_MERRA", \
               "U_ERA40","U_ERAI","U_JRA25", "U_MERRA",  \
               "T_ERA40","T_ERAI", "T_AIRS", "T_JRA25","T_MERRA", \
               "OMEGA_ERA40", "OMEGA_ERAI", "OMEGA_JRA25", "OMEGA_MERRA",\  
               "CFAD_DBZE94_CS"/) ; BRH

; corresponding model variables
   vars    = (/ "SHUM","SHUM", "SHUM","SHUM","SHUM", \
                "RELHUM","RELHUM", "RELHUM","RELHUM",\
                "U","U", "U", "U", \
                "T","T", "T","T","T",\
                "OMEGA","OMEGA","OMEGA", "OMEGA",\
                "CFAD_DBZE94_CS"/) ; BRH
   nvars = dimsizes(vars)

  ; contour levels
   con = new((/nvars,15/),float)
   dcon = new ((/nvars,15/),float)
   con    = (/  con_SHUM,con_SHUM, con_SHUM,con_SHUM,con_SHUM, \
                con_RELHUM,con_RELHUM,con_RELHUM,con_RELHUM,  \
                con_U,con_U, con_U, con_U, \
                con_T,con_T, con_T,con_T,con_T,\
                con_OMEGA,con_OMEGA,con_OMEGA,con_OMEGA, \
                con_CFAD/) ; BRH

   dcon    = (/ dcon_SHUM,dcon_SHUM, dcon_SHUM,dcon_SHUM,dcon_SHUM, \
                dcon_RELHUM, dcon_RELHUM,dcon_RELHUM,dcon_RELHUM, \
                dcon_U,dcon_U, dcon_U, dcon_U , \
                dcon_T,dcon_T, dcon_T,dcon_T,dcon_T,\
                dcon_OMEGA,dcon_OMEGA,dcon_OMEGA, dcon_OMEGA,\
                dcon_CFAD/) ; BRH

;------
   plev = plvlO(::-1)               ; flip to bottom to top
;  plot from 1000 to 30 mb
   vars_top = (/"U","T"/)
   ptop  =  30.0                    ; topmost pressure level
   ptop_merra  =  100.0                    ; topmost pressure level
   itop   = ind(plev.eq.ptop)       ; index of top level 
;-------
;  plot from 1000 to 100 mb
   vars_trop1 =(/"OMEGA"/)
   ptrop1 = 100.0                   ; tropopause pressure level 1 
   itrop1 = ind(plev.eq.ptrop1)     ; index of tropopause level 1
;-------
;  plot from 1000 to 300 mb
   vars_trop2 =(/"SHUM","RELHUM"/)
   ptrop2 = 300.0                   ; tropopause pressure level 2 
   itrop2 = ind(plev.eq.ptrop2)     ; index of tropopause level 2

;-------------------------------------------------------------------
;-------------------------------------------------------------------
 else
;  plot these from 1000 to 30 mb (0.003 mb for WACCM)
   vars_top = (/"RELHUM","U","T","VBSTAR_UBSTAR","EKE","CLOUD","QRS","QRL",  \
                "VPUP_BAR","VPTP_BAR"/)

   if (use_waccm_levs .eq. "False") then
     if(mg_micro.eq.0)then
       vars =(/"SHUM","RELHUM","U","T","OMEGA","TDH","TDM", \
               "VBSTAR_UBSTAR","VBSTAR_TBSTAR","OBSTAR_TBSTAR",\
               "VBSTAR_QBSTAR","EKE","VT","VQ","CLOUD","QRS","QRL", \
               "CWAT","ICLDTWP","GCLDLWP_ICE","GCLDLWP_LIQUID","ZMMSF", \
               "VPUP_BAR","VPTP_BAR","VPQP_BAR","OPTP_BAR","ICWMR","ICIMR",\
               "CLDLIQ","CLDICE",\
               "SIWC","WSUB","CCN3","AWNC","AWNI","AREL","AREI","AQSNOW",\
               "AQRAIN","ANRAIN","ANSNOW","CFAD_DBZE94_CS"/) 
     else
       vars =(/"SHUM","RELHUM","U","T","OMEGA","TDH","TDM", \
               "VBSTAR_UBSTAR","VBSTAR_TBSTAR","OBSTAR_TBSTAR",\
               "VBSTAR_QBSTAR","EKE","VT","VQ","CLOUD","QRS","QRL", \
               "CWAT","ICLDTWP","GCLDLWP_ICE","GCLDLWP_LIQUID","ZMMSF", \
               "VPUP_BAR","VPTP_BAR","VPQP_BAR","OPTP_BAR","ICWMR","ICIMR",\
               "CLDLIQ","CLDICE","CFAD_DBZE94_CS"/) 
     end if
   else
     vars = vars_top
   end if
   
   ; contour levels
   nvars = dimsizes(vars)
   con = new((/nvars,15/),float)
   dcon = new ((/nvars,15/),float)

   ; set contour intervals
   do i = 0,nvars-1
     if (vars(i) .eq. "SHUM") then
       con(i,:)=(/1,2,3,4,5,6,7,8,9,10,11,12,13,14,16/)
       dcon(i,:)=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
     end if
     if (vars(i) .eq. "RELHUM") then
       con(i,:)=(/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) 
       dcon(i,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     end if
     if (vars(i) .eq. "U") then
       con(i,:)=(/-20,-15,-10,-5,0,5,10,15,20,25,30,40,50,60,70/) 
       dcon(i,:)=(/-18,-15,-12,-9,-6,-3,-1,0,1,3,6,9,12,15,18/)
     end if
     if (vars(i) .eq. "T") then
       con(i,:)=(/180,185,190,200,210,220,230,240,250,260,270,280,290,295,300/) 
       dcon(i,:)=(/-9,-7,-5,-4,-3,-2,-1,0,1,2,3,4,5,7,9/)
     end if
     if (vars(i) .eq. "OMEGA") then
       con(i,:)=(/-20,-10,-5,0,5,10,20,30,40,50,60,80,100,120,150/) 
       dcon(i,:)=(/-20,-15,-10,-8,-6,-4,-2,0,2,4,6,8,10,15,20/)
     end if
     if (vars(i) .eq. "TDH") then
       con(i,:)=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/) 
       dcon(i,:)=(/-1.8,-1.5,-1.2,-.9,-.6,-.3,-.1,0,.1,.3,.6,.9,1.2,1.5,1.8/)
     end if
     if (vars(i) .eq. "TDM") then
       con(i,:)=(/-2.1,-1.8,-1.5,-1.2,-.9,-.6,-.3,0,.3,.6,.9,1.2,1.5,1.8,2.1/) 
       dcon(i,:)=(/-.7,-.6,-.5,-.4,-.3,-.2,-.1,0,.1,.2,.3,.4,.5,.6,.7/)
     end if
     if (vars(i) .eq. "VBSTAR_UBSTAR") then
       con(i,:)=(/-30,-25,-20,-15,-10,-5,-2,0,2,5,10,15,20,25,30/) 
       dcon(i,:)=(/-10,-8,-6,-4,-3,-2,-1,0,1,2,3,4,6,8,10/)
     end if
     if (vars(i) .eq. "VBSTAR_TBSTAR") then
       con(i,:)=(/-20,-16,-12,-8,-6,-4,-2,0,2,4,6,8,12,16,20/) 
       dcon(i,:)=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/)
     end if
     if (vars(i) .eq. "OBSTAR_TBSTAR") then
       con(i,:)=(/-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250/)
       dcon(i,:)=(/-100,-80,-60,-40,-20,-10,-5,0,5,10,20,40,60,80,100/)
     end if
     if (vars(i) .eq. "VBSTAR_QBSTAR") then
       con(i,:)=(/-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7/) 
       dcon(i,:)=(/-2.1,-1.8,-1.5,-1.2,-.9,-.6,-.3,0,.3,.6,.9,1.2,1.5,1.8,2.1/)
     end if
     if (vars(i) .eq. "EKE") then
       con(i,:)=(/10,30,50,70,90,110,130,150,170,190,210,230,250,270,290/) 
       dcon(i,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     end if
     if (vars(i) .eq. "VT") then
       con(i,:)=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/) 
       dcon(i,:)=(/-2.4,-2,-1.6,-1.2,-.8,-.4,-.2,0,.2,.4,.8,1.2,1.6,2,2.4/)
     end if
     if (vars(i) .eq. "VQ") then
       con(i,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/) 
       dcon(i,:)=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/)
     end if
     if (vars(i) .eq. "CLOUD") then
       con(i,:)=(/.05,.1,.15,.2,.25,.3,.35,.4,.45,.5,.55,.6,.65,.7,.75/)  
       dcon(i,:)=(/-.20,-.17,-.14,-.11,-.08,-.05,-.02,0,.02,.05,.08,.11,.14,.17,.20/)
     end if
     if (vars(i) .eq. "QRS") then
       con(i,:)=(/.1,.2,.3,.4,.5,.6,.7,.8,.9,1,1.1,1.2,1.3,1.4,1.5/) 
       dcon(i,:)=(/-.4,-.3,-.25,-.2,-.15,-.1,-.05,0,.05,.1,.15,.2,.25,.3,.4/)
     end if
     if (vars(i) .eq. "QRL") then
       con(i,:)=(/-7,-6,-5,-4.5,-4,-3.5,-3,-2.5,-2,-1.5,-1,-.5,0,.5,1/) 
       dcon(i,:)=(/-1,-.8,-.6,-.4,-.3,-.2,-.1,0,.1,.2,.3,.4,.6,.8,1/)
     end if
     if (vars(i) .eq. "CWAT") then
       con(i,:)=(/.01,.015,.02,.025,.03,.035,.04,.05,.06,.07,.08,.09,.10,.11,.12/) 
       dcon(i,:)=(/-.06,-.05,-.04,-.03,-.02,-.01,-.005,0,.005,.01,.02,.03,.04,.05,.06/)
     end if
     if (vars(i) .eq. "ICLDTWP") then
       con(i,:)=(/5,10,20,50,80,120,150,200,250,300,350,400,450,500,600/) 
       dcon(i,:)=(/-200,-150,-100,-50,-20,-10,-5,0,5,10,20,50,100,150,200/)
     end if
     if (vars(i) .eq. "GCLDLWP_ICE") then
       con(i,:)=(/.5,1,2,3,4,5,6,7,8,9,10,12,14,16,18/)
       dcon(i,:)=(/-10,-8,-6,-4,-2,-1,-.5,0,.5,1,2,4,6,8,10/)
     end if
     if (vars(i) .eq. "GCLDLWP_LIQUID") then
       con(i,:)=(/2,4,6,8,10,12,14,16,20,25,30,35,40,45,50/) 
       dcon(i,:)=(/-30,-25,-20,-15,-10,-5,-1,0,1,5,10,15,20,25,30/)
     end if
     if (vars(i) .eq. "ZMMSF") then
       con(i,:)=(/-200,-160,-120,-90,-60,-30,-15,0,15,30,60,90,120,160,200/) 
       dcon(i,:)=(/-40,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,40/)
     end if
     if (vars(i) .eq. "VPUP_BAR") then
       con(i,:)=(/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/) 
       dcon(i,:)=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/)
     end if
     if (vars(i) .eq. "VPTP_BAR") then
       con(i,:)=(/-18,-14,-10,-8,-6,-4,-2,0,2,4,6,8,10,14,18/) 
       dcon(i,:)=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/)
     end if
     if (vars(i) .eq. "VPQP_BAR") then
       con(i,:)=(/-14,-12,-10,-6,-4,-2,-1,0,1,2,4,6,10,12,14/) 
       dcon(i,:)=(/-3.5,-3,-2.5,-2,-1.5,-1,-.5,0,.5,1,1.5,2,2.5,3,3.5/)
     end if
     if (vars(i) .eq. "OPTP_BAR") then
       con(i,:)=(/-250,-200,-150,-100,-75,-50,-25,0,25,50,75,100,150,200,250/)
       dcon(i,:)=(/-100,-80,-60,-40,-20,-10,-5,0,5,10,20,40,60,80,100/)
     end if
     if (vars(i) .eq. "ICWMR") then
       con(i,:)=(/0.01,0.02,0.03,0.04,0.05,0.08,0.1,0.12,0.14,0.16,0.18,0.20,0.22,0.24,0.26/)
       dcon(i,:)=(/-0.12,-0.1,-0.08,-0.06,-0.04,-0.02,-0.01,0,0.01,0.02,0.04,0.06,0.08,0.1,0.12/)
     end if
     if (vars(i) .eq. "ICIMR") then
       con(i,:)=(/0.001,0.002,0.004,0.006,0.008,0.01,0.012,0.015,0.02,0.025,0.03,0.035,0.04,0.045,0.05/)
       dcon(i,:)=(/-0.02,-0.015,-0.010,-0.005,-0.004,-0.002,-0.001,0,0.001,0.002,0.004,0.005,0.01,0.015,0.02/)
     end if
     if (vars(i) .eq. "CLDLIQ") then
       con(i,:)=(/0.01,0.02,0.03,0.04,0.05,0.08,0.1,0.12,0.14,0.16,0.18,0.20,0.22,0.24,0.26/)
       dcon(i,:)=(/-0.12,-0.1,-0.08,-0.06,-0.04,-0.02,-0.01,0,0.01,0.02,0.04,0.06,0.08,0.1,0.12/)
     end if
     if (vars(i) .eq. "CLDICE") then
       con(i,:)=(/0.001,0.002,0.004,0.006,0.008,0.01,0.012,0.015,0.02,0.025,0.03,0.035,0.04,0.045,0.05/)
       dcon(i,:)=(/-0.02,-0.015,-0.010,-0.005,-0.004,-0.002,-0.001,0,0.001,0.002,0.004,0.005,0.01,0.015,0.02/)
     end if
     if (vars(i) .eq. "SIWC") then
       con(i,:)=(/0.0,0.2,0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.6,2.8/)
       dcon(i,:)=(/-14.0,-12.,-10.,-8.,-6.,-4.,-2.,0.0,2.0,4.0,6.0,8.0,10.0,\
                     12.0,14.0/)/10.
     end if
     if (vars(i) .eq. "WSUB") then
       con(i,:)=(/0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5/)
       dcon(i,:)=(/-0.14,-0.12,-0.1,-0.06,-0.08,-0.04,-0.02,0.0,0.02,0.04,0.06,\
                     0.08,0.1,0.12,0.14/)
     end if
     if (vars(i) .eq. "CCN3") then
       con(i,:)=(/0.0,10.,20.,30.,40.,50.,60.,70.,80.,90.,100.,110.,120.,130.,\
                   140./)
       dcon(i,:)=(/-70.,-60.,-50.,-40.,-30.,-20.,-10.,0.0,10.,20.,30.,40.,50.,\
                     60.,70./)/10.
     end if
     if (vars(i) .eq. "AWNC") then
       con(i,:)=(/60.,75.,90.,105.,120.,135.,150.,165.,180.,195.,210.,225.,240.,\
                   255.,270./)
       dcon(i,:)=(/-110.,-100.,-90.,-80.,-70.,-60.,-50.,-40.,-30.,-20.,-10.,\
                     0.0,10.,20.,30./)
     end if
     if (vars(i) .eq. "AWNI") then
       con(i,:)=(/0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5/)
       dcon(i,:)=(/-0.07,-0.06,-0.05,-0.04,-0.03,-0.02,-0.01,0.0,0.01,0.02,0.03,\
                     0.04,0.05,0.06,0.07/)*10.
     end if
     if (vars(i) .eq. "AREL") then
       con(i,:)=(/6.,6.5,7.,7.5,8.,8.5,9.,9.5,10.,10.5,11.,11.5,12.,12.5,13./)
       dcon(i,:)=(/-7.,-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6.,7./)/10.
     end if
     if (vars(i) .eq. "AREI") then
       con(i,:)=(/5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,65.,70.,75./)
       dcon(i,:)=(/-7.,-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6.,7./)*10.
     end if
     if (vars(i) .eq. "AQSNOW") then
       con(i,:)=(/1.,5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,65.,70./)
       dcon(i,:)=(/-7.,-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6.,7./)
     end if
     if (vars(i) .eq. "AQRAIN") then
       con(i,:)=(/1.,5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,65.,70./)
       dcon(i,:)=(/-7.,-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6.,7./)
     end if
     if (vars(i) .eq. "ANRAIN") then
       con(i,:)=(/0.,5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,65.,70./)
       dcon(i,:)=(/-6.,-4.,-2.,0.,2.,4.,6.,8.,10.,12.,14.,16.,18.,20.,22./)
     end if
     if (vars(i) .eq. "ANSNOW") then
       con(i,:)=(/1.,2.,3.,4.,5.,6.,7.,8.,9.,10.,11.,12.,13.,14.,15./)
       dcon(i,:)=(/-7.,-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6.,7./)
     end if
     if (vars(i) .eq. "CFAD_DBZE94_CS") then ; BRH
       con(i,:) = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/)
       dcon(i,:) = (/-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/)
     end if
   end do

;------------------------------------------------------------------------- 
   plev = plvlM(::-1)                 ; flip to bottom to top
   ; topmost pressure level
   if (use_waccm_levs .eq. "False") then
     ptop = 30.0
   else
     if (lev_top1.lt.1.) then 
      ptop = 2.9935e-3
     else
      ptop = 4.83445
    end if
   end if

   itop   = ind(plev.eq.ptop)         ; index of top level 
;------------------------------------------------------------------------- 
;  plot these below 100mb
   vars_trop1 =(/"OMEGA","VT","VBSTAR_TBSTAR","GCLDLWP_ICE","ZMMSF", \
                 "OPTP_BAR","ICIMR","CLDICE"/)
   ptrop1 = 100.0                             ; tropopause pressure level  1 
   itrop1 = ind(plev.eq.ptrop1)        ; index of tropopause level 1
;------------------------------------------------------------------------- 
;  plot these below 300mb
   vars_trop2=(/"SHUM","TDH","OBSTAR_TBSTAR","CWAT","GCLDLWP_LIQUID", \
                "ICLDTWP","VPQP_BAR","ICWMR","CLDLIQ"/)
   ptrop2 = 300.0                      ; tropopause pressure level 2 
   itrop2 = ind(plev.eq.ptrop2)        ; index of tropopause level 2
;------------------------------------------------------------------------- 
;  plot these below 500mb
   vars_trop3 =(/"TDM","VQ","VBSTAR_QBSTAR"/)
   ptrop3 = 500.0                      ; tropopause pressure level 3 
   itrop3 = ind(plev.eq.ptrop3)        ; index of tropopause level 3
 end if

; all model data is interpolated to the same 16 pressure levels for
; comparison to obs data, or 25 levels for model-to-model comparisons
 
; linear vertical scale
 if (use_waccm_levs .eq. "False") then
   linear = (/"SHUM","RELHUM","TDH","TDM","VT","VQ","CLOUD","QRS","QRL", \
              "CWAT","ICLDTWP","GCLDLWP_ICE","GCLDLWP_LIQUID", \
              "CLDLIQ","CLDICE","CFAD_DBZE94_CS"/) ; BRH
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

do i = 0,nvars-1

     ;print("=========")
     ;print("===="+vars(i))
     ;print("===="+obsvars(i))

; CASE 1 MODEL
  if (vars(i) .eq. "CLOUD") then
    A = vertical_CLOUD (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CWAT") then
    A = vertical_CWAT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "EKE") then
    A = vertical_EKE (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDLIQ") then
    A = vertical_CLDLIQ (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CLDICE") then
    A = vertical_CLDICE (inptr1,outptr1)
  end if
  if (vars(i) .eq. "ICWMR") then
    A = vertical_ICWMR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "ICIMR") then
    A = vertical_ICIMR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "GCLDLWP_ICE") then
    A = vertical_GCLDLWP_ICE (inptr1,outptr1)
  end if
  if (vars(i) .eq. "GCLDLWP_LIQUID") then
    A = vertical_GCLDLWP_LIQUID (inptr1,outptr1)
  end if
  if (vars(i) .eq. "ICLDTWP") then
    A = vertical_ICLDTWP (inptr1,outptr1)
  end if
  if (vars(i) .eq. "OMEGA") then
    A = vertical_OMEGA (inptr1,outptr1,compare)
  end if
  if (vars(i) .eq. "QRL") then
    A = vertical_QRL (inptr1,outptr1)
  end if
  if (vars(i) .eq. "QRS") then
    A = vertical_QRS (inptr1,outptr1)
  end if
  if (vars(i) .eq. "RELHUM") then
    A = vertical_RELHUM (inptr1,outptr1,compare)
  end if
  if (vars(i) .eq. "SHUM") then
    A = vertical_SHUM (inptr1,outptr1,compare)
  end if
  if (vars(i) .eq. "T") then
    A = vertical_T (inptr1,outptr1,compare)
  end if
  if (vars(i) .eq. "TDH") then
    A = vertical_TDH (inptr1,outptr1)
  end if
  if (vars(i) .eq. "TDM") then
    A = vertical_TDM (inptr1,outptr1)
  end if
  if (vars(i) .eq. "U") then
    A = vertical_U (inptr1,outptr1,compare)
  end if
  if (vars(i) .eq. "VQ") then
    A = vertical_VQ (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VT") then
    A = vertical_VT (inptr1,outptr1)
  end if
  if (vars(i) .eq. "ZMMSF") then
    A = vertical_ZMMSF (inptr1,outptr1)
  end if
  if (vars(i) .eq. "SIWC") then
    A = vertical_SIWC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "WSUB") then
    A = vertical_WSUB (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CCN3") then
    A = vertical_CCN3 (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AWNC") then
    A = vertical_AWNC (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AWNI") then
    A = vertical_AWNI (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AREL") then
    A = vertical_AREL (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AREI") then
    A = vertical_AREI (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AQRAIN") then
    A = vertical_AQRAIN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "ANRAIN") then
    A = vertical_ANRAIN (inptr1,outptr1)
  end if
  if (vars(i) .eq. "AQSNOW") then
    A = vertical_AQSNOW (inptr1,outptr1)
  end if
  if (vars(i) .eq. "ANSNOW") then
    A = vertical_ANSNOW (inptr1,outptr1)
  end if


;----------------- EDDY FLUXES ------------------
  if (vars(i) .eq. "OBSTAR_TBSTAR") then
    A = vertical_OBSTAR_TBSTAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "OPTP_BAR") then
    A = vertical_OPTP_BAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VBSTAR_QBSTAR") then
    A = vertical_VBSTAR_QBSTAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VPQP_BAR") then
    A = vertical_VPQP_BAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VBSTAR_TBSTAR") then
    A = vertical_VBSTAR_TBSTAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VPTP_BAR") then
    A = vertical_VPTP_BAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VBSTAR_UBSTAR") then
    A = vertical_VBSTAR_UBSTAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "VPUP_BAR") then
    A = vertical_VPUP_BAR (inptr1,outptr1)
  end if
  if (vars(i) .eq. "CFAD_DBZE94_CS") then        
    A = vertical_CFAD_DBZE94_CS (inptr1,outptr1) 
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
      plev2 = inptr2->lev             ; 25 constant pressure levels
      iMtrop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iMtrop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      iMtop   = ind(plev2.eq.ptop_merra)    ; index of top level
      delete(plev2)
    end if
    if (any(obsvars(i).eq.erai_vars)) then
      inptr2 = ptr_erai
      case2 = "ERAI"
      plev2 = inptr2->lev             ; 37 constant pressure levels 
      plev_erai =plev2
      iEItrop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iEItrop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      iEItop   = ind(plev2.eq.ptop)    ; index of top level
      delete(plev2)
    end if
    if (any(obsvars(i).eq.jra25_vars)) then ; 
      inptr2 = ptr_jra25
      case2 = "JRA25"
      plev2 = inptr2->plev             ; 23 constant pressure levels 
      iNtrop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iNtrop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      iNtop   = ind(plev2.eq.ptop)    ; index of top level
      delete(plev2)
    end if
    if (any(obsvars(i).eq.era40_vars)) then
      inptr2 = ptr_era40
      case2 = "ERA40"
      plev2 = inptr2->lev             ; 23 constant pressure levels 
      iE40trop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iE40trop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      iE40top   = ind(plev2.eq.ptop)    ; index of top level
      delete(plev2)
    end if
    if (any(obsvars(i).eq.airs_vars)) then
      inptr2 = ptr_airs
      case2 = "AIRS"
      plev2 = inptr2->lev             ; 13 constant pressure levels 
      iAtrop1 = ind(plev2.eq.ptrop1)  ; index of tropopause level 1
      iAtrop2 = ind(plev2.eq.ptrop2)  ; index of tropopause level 2
      Aptop = 70.                     
      if (ptop.gt.Aptop) then         ; AIRS only goes to 70mb. 
        Aptop = ptop
      end if
      iAtop   = ind(plev2.eq.Aptop)   ; index of top level
      delete(plev2)
    end if
    if (any(obsvars(i).eq.cloudsatcosp_vars)) then ; BRH
      inptr2 = ptr_cloudsatcosp                    ; BRH
      case2 = "CLOUDSAT-COSP (2006-2010)"          ; BRH
    end if                                         ; BRH

    lat2 = inptr2->lat      ; obs data could be on anyy grid
    nlat2 = dimsizes(lat2)

;   BRH edit for COSP
;   CFAD_DBZE94_CS is a special case, and we need to sum over all bins
;   with dBZe > -25.0 in order to get the vertical profile.
    if (vars(i).eq."CFAD_DBZE94_CS") then
      tmp = inptr2->CFAD_DBZE94_CS(0,:,:,:,:)
      B = dim_avg_Wrap( \
        dim_sum_Wrap(tmp(cosp_ht|:,lat|:,lon|:,{cosp_dbze|-25:})) \
      )
      B = B*100.0
      B@long_name = "Hydrometeor occurrence"
      B@units = "percent"
    else
      tmp = inptr2->$vars(i)$(0,:,:,:)  ; get from obs data file
      B = dim_avg_Wrap(tmp)             ; which is bottom to top
    end if
    delete (tmp)
;   end BRH edit
  else                                ; CASE 2 IS MODEL

    if (vars(i) .eq. "CLOUD") then
      B = vertical_CLOUD (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CWAT") then
      B = vertical_CWAT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "EKE") then
      B = vertical_EKE (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDLIQ") then
      B = vertical_CLDLIQ (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CLDICE") then
      B = vertical_CLDICE (inptr2,outptr2)
    end if
    if (vars(i) .eq. "ICWMR") then
      B = vertical_ICWMR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "ICIMR") then
      B = vertical_ICIMR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "GCLDLWP_ICE") then
      B = vertical_GCLDLWP_ICE (inptr2,outptr2)
    end if
    if (vars(i) .eq. "GCLDLWP_LIQUID") then
      B = vertical_GCLDLWP_LIQUID (inptr2,outptr2)
    end if
    if (vars(i) .eq. "ICLDTWP") then
      B = vertical_ICLDTWP (inptr2,outptr2)
    end if
    if (vars(i) .eq. "OMEGA") then
      B = vertical_OMEGA (inptr2,outptr2,compare)
    end if
    if (vars(i) .eq. "QRL") then
      B = vertical_QRL (inptr2,outptr2)
    end if
    if (vars(i) .eq. "QRS") then
      B = vertical_QRS (inptr2,outptr2)
    end if
    if (vars(i) .eq. "RELHUM") then
      B = vertical_RELHUM (inptr2,outptr2,compare)
    end if
    if (vars(i) .eq. "SHUM") then
      B = vertical_SHUM (inptr2,outptr2,compare)
    end if
    if (vars(i) .eq. "T") then
      B = vertical_T (inptr2,outptr2,compare)
    end if
    if (vars(i) .eq. "TDH") then
      B = vertical_TDH (inptr2,outptr2)
    end if
    if (vars(i) .eq. "TDM") then
      B = vertical_TDM (inptr2,outptr2)
    end if
    if (vars(i) .eq. "U") then
      B = vertical_U (inptr2,outptr2,compare)
    end if
    if (vars(i) .eq. "VQ") then
      B = vertical_VQ (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VT") then
      B = vertical_VT (inptr2,outptr2)
    end if
    if (vars(i) .eq. "ZMMSF") then
      B = vertical_ZMMSF (inptr2,outptr2)
    end if
    if (vars(i) .eq. "SIWC") then
      B = vertical_SIWC (inptr2,outptr2)
    end if    
    if (vars(i) .eq. "WSUB") then
      B = vertical_WSUB (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CCN3") then
      B = vertical_CCN3 (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AWNC") then
      B = vertical_AWNC (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AWNI") then
      B = vertical_AWNI (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AREL") then
      B = vertical_AREL (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AREI") then
      B = vertical_AREI (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AQRAIN") then
      B = vertical_AQRAIN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "AQSNOW") then
      B = vertical_AQSNOW (inptr2,outptr2)
    end if
    if (vars(i) .eq. "ANRAIN") then
      B = vertical_ANRAIN (inptr2,outptr2)
    end if
    if (vars(i) .eq. "ANSNOW") then
      B = vertical_ANSNOW (inptr2,outptr2)
    end if
    if (vars(i) .eq. "CFAD_DBZE94_CS") then        
      B = vertical_CFAD_DBZE94_CS (inptr2,outptr2) 
    end if    
;----------------- EDDY FLUXES ------------------
    if (vars(i) .eq. "OBSTAR_TBSTAR") then
      B = vertical_OBSTAR_TBSTAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "OPTP_BAR") then
      B = vertical_OPTP_BAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VBSTAR_QBSTAR") then
      B = vertical_VBSTAR_QBSTAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VPQP_BAR") then
      B = vertical_VPQP_BAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VBSTAR_TBSTAR") then
      B = vertical_VBSTAR_TBSTAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VPTP_BAR") then
      B = vertical_VPTP_BAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VBSTAR_UBSTAR") then
      B = vertical_VBSTAR_UBSTAR (inptr2,outptr2)
    end if
    if (vars(i) .eq. "VPUP_BAR") then
      B = vertical_VPUP_BAR (inptr2,outptr2)
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
        itop2 = iEItop          ; obs top
      end if
      if (case2.eq."MERRA") then
        itop2 = iMtop
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
        itop2 = iEItrop1          ; obs top
      end if
      if (case2.eq."MERRA") then
        itop2 = iMtrop1          ; obs top
      end if
      if (case2.eq."ERA40") then
        itop2 = iE40trop1
      end if
      if (case2.eq."JRA25") then
        itop2 = iNtrop1
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
        itop2 = iEItrop2          ; obs top
      end if
     if (case2.eq."MERRA") then
        itop2 = iMtrop2          ; obs top
      end if
      if (case2.eq."ERA40") then
        itop2 = iE40trop2
      end if
      if (case2.eq."JRA25") then
        itop2 = iNtrop2
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

; BRH edit for COSP: CFAD_DBZE94_CS has a height vertical coordinate
; as opposed to a pressure coordinate, so we need to treat it
; differently.
  if (vars(i) .eq. "CFAD_DBZE94_CS") then
    delete(cres@trYMinF)
    cres@tiYAxisString = "Height (km)"
  end if
  if (vars(i).eq."CFAD_DBZE94_CS") then
    data1 = A                ; model data(height,lat)
    data2 = B                ; model or obs data(height,lat)
  else
    data1 = A(0:itop1,:)          ; model data(lev,lat)
    data2 = B(0:itop2,:)          ; model or obs data(lev,lat)
  end if
; end BRH edit

  data1!0 = "lev"
  data1!1 = "lat"
  data2!0 = "lev"
  data2!1 = "lat"

;------------------------- Open files for plots -----------------------------
  if (use_waccm_levs .eq. "False") then
    set_prefix = "set4_"
  else
    set_prefix = "wset1_"
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
; BRH edit for COSP: CFAD_DBZE94_CS has a height vertical coordinate
; as opposed to a pressure coordinate, so we need to treat it
; differently.
  if (vars(i).eq."CFAD_DBZE94_CS") then
    cnplot(0) = gsn_csm_contour(wks,data1,cres)
  else
    cnplot(0)  = gsn_csm_pres_hgt(wks,data1,cres)
  end if
; end BRH edit for COSP
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

; BRH edit for COSP: CFAD_DBZE94_CS has a height vertical coordinate
; as opposed to a pressure coordinate, so we need to treat it
; differently.
  if (vars(i).eq."CFAD_DBZE94_CS") then
    cnplot(1) = gsn_csm_contour(wks,data2,cres)
  else
    cnplot(1)  = gsn_csm_pres_hgt(wks,data2,cres)
  end if
; end BRH edit for COSP
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

; For model compared toJRA25 observed remove the 775 mb level
; from the model data so the levels are the same as the JRA25 levels.

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

   if (nlat1 .ne. nlat2) then           ; lat grids different

      if (nlat1 .gt. nlat2) then         ;  model grid thinner than obs grid
        tmp1 = linint1_Wrap (lat1,data1,False,lat2,0)  ; interp model data to obs grid
        if (case2.eq."AIRS".or.case2.eq."JRA25") then         ; fix the levels
          tmp = data2                     ; copy coords 
          tmp(0:2,:) = (/tmp1(0:2,:)/)    ; skip the 775 mb level
          tmp(3:,:) = (/tmp1(4:,:)/)      ; which is in the model 1
          tmp@long_name = data1@long_name
          delete(tmp1)
          tmp1 = tmp
          delete(tmp)
        end if
        if (case2.eq."ERAI".or.case2.eq."MERRA") then        ; interpolate on model levels
          level1 = tmp1&lev
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
 
      else                                         ; obs grid thinner than model grid   
        tmp2 = linint1_Wrap (lat2,data2,False,lat1,0)   ; interp to model grid 
        if (case2.eq."AIRS".or.case2.eq."JRA25") then         ; fix the levels
          copy_VarCoords(data2(:,0),tmp2(:,0))
          tmp = tmp2                      ; copy levels from 
          tmp(0:2,:) = (/data1(0:2,:)/)    ; skip the 775 mb level
          tmp(3:,:) = (/data1(4:,:)/)      ; which is in the model 1
          tmp!1 = "lat" 
          tmp&lat = data1&lat
          tmp@long_name = data1@long_name
          delete(data1)
          data1 = tmp
          delete(tmp) 
        end if 
        if (case2.eq."ERAI".or.case2.eq."MERRA") then           ; interpolate on model levels
          level1 = data1&lev
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
    else                                 ; same grid latitudes
      if (case2.eq."AIRS".or.case2.eq."JRA25") then          ; fix the levels
        tmp = data2                      ; copy coords from 
        tmp(0:2,:) = (/data1(0:2,:)/)    ; skip the ERAI 775 mb level
        tmp(3:,:) = (/data1(4:,:)/)      ; which is in the model 1
        tmp@long_name = data1@long_name
        delete(data1)
        data1 = tmp
        delete(tmp) 
      end if
      if (case2.eq."ERAI".or.case2.eq."MERRA") then           ; interpolate on model levels
          level1 = data1&lev
          level2 = data2&lev  
          data2_int = linint1_n_Wrap(level2, data2, False, level1, 0, 0)
          delete(data2)
          data2 =  data2_int
          delete(level1)
          delete(level2)
          delete(data2_int)
      end if
      ; hannay: we need to do something about ERAI
      C = data1                          ; copy dims,coords
      C = (/data1-data2/)                ; get diff values 
    end if
  end if

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
  if (vars(i).eq."CFAD_DBZE94_CS") then
    cnplot(2) = gsn_csm_contour(wks,C,cres)    ; contour plot
  else
    cnplot(2)= gsn_csm_pres_hgt(wks,C,cres)    ; contour plot
  end if
; end BRH edit for COSP

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
