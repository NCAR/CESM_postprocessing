; NCL script
; plot_ann_cycle.ncl
; Mark Stevens Sept 2001
; set 8
;**************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH
load "$DIAG_CODE/functions_contrib.ncl"  
load "$DIAG_CODE/functions_cycle.ncl"
;**************************************************
begin
 compare    = getenv("COMPARE")
 color_type = getenv("COLORTYPE")
 rgb_file   = getenv("RGB_FILE") 
 plot_type  = getenv("PLOTTYPE")
 version    = getenv("DIAG_VERSION")
 wkdir      = getenv("WKDIR")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input prefix 
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input prefix 
 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
 end if

; CASE 1 MODEL 
 inptr1 = addfile(infile1+"_01_climo.nc","r")  
 lat1 = inptr1->lat
 nlat1 = dimsizes(lat1)
 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case  
 end if
 if (isatt(inptr1,"yrs_averaged")) then
   yrs_ave1 = inptr1@yrs_averaged 
 end if 
 delete(inptr1)
 if (ncdf_mode .eq. "write") then
   outptr1 = addfile(outfile1,"w")
 else
   outptr1 = addfile(outfile1,"c")
 end if

; CASE 2 IS OBS
if (compare.eq."OBS") then    
  month = (/"01","02","03","04","05","06","07","08","09","10","11","12"/)   
   ptr_erai = new(12,file)
   ptr_era40 = new(12,file)
   ptr_jra25= new(12,file)
   ptr_erbe = new(12,file)
   ptr_ceres = new(12,file)
   ptr_ceres2 = new(12,file)
   ptr_merra = new(12,file)
   ptr_gpcp = new(12,file)
   ptr_nvap = new(12,file)
   ptr_xa = new(12,file)
   ptr_isccpcosp = new(12,file) ; BRH
   ptr_modiscosp = new(12,file) ; BRH
   ptr_misrcosp = new(12,file) ; BRH
   ptr_calipsocosp = new(12,file) ; BRH
   ptr_cloudsatcosp = new(12,file) ; BRH
   do m = 0, 11
     ptr_jra25(m) = addfile(infile2+"/JRA25_"+month(m)+"_climo.nc","r")
     ptr_erai(m) = addfile(infile2+"/ERAI_"+month(m)+"_climo.nc","r")
     ptr_era40(m) = addfile(infile2+"/ERA40_"+month(m)+"_climo.nc","r")
     ptr_erbe(m) = addfile(infile2+"/ERBE_"+month(m)+"_climo.nc","r")
     ptr_ceres(m) = addfile(infile2+"/CERES_"+month(m)+"_climo.nc","r")
     ptr_merra(m) = addfile(infile2+"/MERRA_"+month(m)+"_climo.nc","r")
     ptr_ceres2(m) = addfile(infile2+"/CERES-EBAF_"+month(m)+"_climo.nc","r")
     ptr_gpcp(m) = addfile(infile2+"/GPCP_"+month(m)+"_climo.nc","r")
     ptr_nvap(m) = addfile(infile2+"/NVAP_"+month(m)+"_climo.nc","r")
     ptr_xa(m) = addfile(infile2+"/XIEARKIN_"+month(m)+"_climo.nc","r")
     ptr_isccpcosp(m) = addfile(infile2+"/ISCCPCOSP_"+month(m)+"_climo.nc","r") ; BRH
     ptr_modiscosp(m) = addfile(infile2+"/MODISCOSP_"+month(m)+"_climo.nc","r") ; BRH
     ptr_misrcosp(m) = addfile(infile2+"/MISRCOSP_"+month(m)+"_climo.nc","r") ; BRH
     ptr_calipsocosp(m) = addfile(infile2+"/CALIPSOCOSP_"+month(m)+"_climo.nc","r") ; BRH
     ptr_cloudsatcosp(m) = addfile(infile2+"/CLOUDSATCOSP_"+month(m)+"_climo.nc","r") ; BRH
   end do
 else    
;  CASE 2 IS MODEL
   inptr2 = addfile(infile2+"_01_climo.nc","r")  
   lat2 = inptr2->lat
   nlat2 = dimsizes(lat2)
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case  
   end if
   if (isatt(inptr2,"yrs_averaged")) then
     yrs_ave2 = inptr2@yrs_averaged 
   end if 
   delete(inptr2)
   if (ncdf_mode .eq. "write") then
     outptr2 = addfile(outfile2,"w")
   else
     outptr2 = addfile(outfile2,"c")
   end if
 end if

;---------------------------------------------------------------------

     cntr_FLUT=(/100,115,130,145,160,175,190,205,220,235,250,260,270,280,290/)
     dcntr_FLUT=(/-13,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,13/) ;FLUT ERBE
     cntr_PREH2O=(/2,4,8,12,16,20,24,28,32,36,40,44,46,48,50/) ;  PREH2O
     dcntr_PREH2O=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/) 
     cntr_U200 = (/-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45/) ;U 200
     dcntr_U200 = (/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/) ;U at 200
     cntr_PRECT = (/.5,1,2,3,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9/)     ; PRECT GPCP
     dcntr_PRECT = (/-2.5,-2,-1.5,-1,-.7,-.5,-.3,0,.3,.5,.7,1,1.5,2,2.5/)
     cntr_CLDTOT_ISCCPCOSP = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  ; CLDTOT_ISCCPCOSP
     dcntr_CLDTOT_ISCCPCOSP = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDLOW_ISCCPCOSP  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; CLDLOW_ISCCPCOSP
     dcntr_CLDLOW_ISCCPCOSP = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDMED_ISCCPCOSP  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDMED_ISCCPCOSP = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDHGH_ISCCPCOSP  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDHGH_ISCCPCOSP = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDTHICK_ISCCPCOSP  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDTHICK_ISCCPCOSP = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_MEANPTOP_ISCCPCOSP=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/) ; MEANPTOP_ISCCPCOSP
     dcntr_MEANPTOP_ISCCPCOSP=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200,250,300/)
     cntr_MEANCLDALB_ISCCPCOSP=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/) ; MEANCLDALB_ISCCPCOSP
     dcntr_MEANCLDALB_ISCCPCOSP=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
     cntr_CLDTOT_MISR = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  ; CLDTOT_MISR
     dcntr_CLDTOT_MISR = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDLOW_MISR  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; CLDLOW_MISR
     dcntr_CLDLOW_MISR = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDMED_MISR  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDMED_MISR = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDHGH_MISR  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDHGH_MISR = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDTHICK_MISR  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDTHICK_MISR = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDTOT_MODIS = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  ; CLDTOT_MODIS
     dcntr_CLDTOT_MODIS = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDLOW_MODIS  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; CLDLOW_MODIS
     dcntr_CLDLOW_MODIS = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDMED_MODIS  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDMED_MODIS = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDHGH_MODIS  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDHGH_MODIS = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDTHICK_MODIS  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDTHICK_MODIS = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLWMODIS = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  ; 
     dcntr_CLWMODIS = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLIMODIS = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  ; 
     dcntr_CLIMODIS = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_IWPMODIS = (/50,100,150,200,250,300,350,400,450,500,550,600,650,700,800/) ; IWPMODIS
     dcntr_IWPMODIS = (/-700,-600,-500,-400,-300,-200,-100,0,100,200,300,400,500,600,700/)
     cntr_LWPMODIS = (/40,80,120,160,200,240,280,320,360,400,440,480,520,560,600/) ; LWPMODIS
     dcntr_LWPMODIS = (/-200,-150,-100,-80,-60,-40,-20,0,20,40,60,80,100,150,200/)
     cntr_REFFCLIMODIS = (/5,10,15,20,25,30,35,40,45,50,55,60,65,70,75/) ; REFFCLIMODIS
     dcntr_REFFCLIMODIS = (/-70,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70/)
     cntr_REFFCLWMODIS = (/1.5,3.0,4.5,6.0,7.5,9.0,10.5,12.0,13.5,15.0,16.5,18.0,19.5,21.0,22.5/) ; REFFCLWMODIS
     dcntr_REFFCLWMODIS = (/-10.5,-9.0,-7.5,-6.0,-4.5,-3.0,-1.5,0,1.5,3.0,4.5,6.0,7.5,9.0,10.5/)
     cntr_TAUILOGMODIS = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/) 
     dcntr_TAUILOGMODIS = (/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
     cntr_TAUWLOGMODIS = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/) 
     dcntr_TAUWLOGMODIS = (/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
     cntr_TAUTLOGMODIS = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/) 
     dcntr_TAUTLOGMODIS = (/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
     cntr_TAUIMODIS = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/) 
     dcntr_TAUIMODIS = (/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
     cntr_TAUWMODIS = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/) 
     dcntr_TAUWMODIS = (/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
     cntr_TAUTMODIS = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/) 
     dcntr_TAUTMODIS = (/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
     cntr_PCTMODIS=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/) ; PCTMODIS
     dcntr_PCTMODIS=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200,250,300/)
     cntr_CLDTOT_CAL = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  ; CLDTOT_CAL
     dcntr_CLDTOT_CAL = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDLOW_CAL  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; CLDLOW_CAL
     dcntr_CLDLOW_CAL = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDMED_CAL  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDMED_CAL = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDHGH_CAL  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     dcntr_CLDHGH_CAL = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr_CLDTHICK_CAL  = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; 
     cntr_CLDTOT_CS2 = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  ; CLDTOT_CAL
     dcntr_CLDTOT_CS2 = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)

if (compare .eq. "OBS") then
   merra_vars = (/"PREH2O_MERRA","U_200_MERRA"/)
   erai_vars = (/"PREH2O_ERAI","U_200_ERAI"/)
   era40_vars = (/"PREH2O_ERA40","U_200_ERA40"/)
   jra25_vars = (/"PREH2O_JRA25","U_200_JRA25"/)
   gpcp_vars = (/"PRECT_GPCP"/)
   nvap_vars = (/"PREH2O_NVAP"/)
   erbe_vars = (/"FLUT_ERBE"/)
   ceres_vars = (/"FLUT_CERES"/)
   ceres2_vars = (/"FLUT_CERES-EBAF"/)
   xa_vars = (/"PRECT_XA"/)
   isccpcosp_vars = (/"CLDTOT_ISCCPCOSP","CLDLOW_ISCCPCOSP", \
                      "CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP", \
                      "CLDTHICK_ISCCPCOSP","MEANCLDALB_ISCCPCOSP", \
                      "MEANPTOP_ISCCPCOSP","MEANTTOP_ISCCPCOSP"/) ; BRH
   misrcosp_vars = (/"CLDTOT_MISR","CLDLOW_MISR","CLDMED_MISR", \
                     "CLDHGH_MISR","CLDTHICK_MISR"/) ; BRH
   modiscosp_vars = (/"CLDTOT_MODIS","CLDTHICK_MODIS", \
                      "CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS", \
                      "CLWMODIS","CLIMODIS","IWPMODIS","LWPMODIS", \
                      "REFFCLIMODIS","REFFCLWMODIS", \
                      "TAUILOGMODIS","TAUWLOGMODIS","TAUTLOGMODIS", \                                 "TAUIMODIS","TAUWMODIS","TAUTMODIS", \
                      "PCTMODIS"/) ; BRH
   calipsocosp_vars = (/"CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL"/) ; BRH
   cloudsatcosp_vars = (/"CLDTOT_CS2","CLDTOT_CS2"/) ; BRH
   obsvars = (/"PREH2O_MERRA", "U_200_MERRA", "FLUT_ERBE","PREH2O_NVAP","PREH2O_ERAI", \
               "U_200_ERAI","PRECT_GPCP","PRECT_XA", "PREH2O_ERA40", \
               "U_200_ERA40","FLUT_CERES","FLUT_CERES-EBAF", \
               "PREH2O_JRA25","U_200_JRA25",  \
               "CLDTOT_ISCCPCOSP","CLDLOW_ISCCPCOSP", \
               "CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP", \
               "CLDTHICK_ISCCPCOSP", \
               "MEANPTOP_ISCCPCOSP","MEANCLDALB_ISCCPCOSP", \
               "CLDTOT_MISR","CLDLOW_MISR","CLDMED_MISR","CLDHGH_MISR", \
               "CLDTHICK_MISR", \
               "CLDTOT_MODIS","CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS", \
               "CLDTHICK_MODIS", \
               "CLWMODIS","CLIMODIS", \
               "IWPMODIS","LWPMODIS", \
               "REFFCLIMODIS","REFFCLWMODIS", \
               "TAUILOGMODIS","TAUWLOGMODIS","TAUTLOGMODIS", \
               "TAUIMODIS","TAUWMODIS","TAUTMODIS", \
               "PCTMODIS", \
               "CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL", \
               "CLDTOT_CS2"/) ; BRH
 
;  corresponding model variables
   vars = (/"PREH2O", "U_200", "FLUT","PREH2O","PREH2O", \ 
            "U_200","PRECT","PRECT","PREH2O", \
            "U_200","FLUT","FLUT","PREH2O","U_200",  \
            "CLDTOT_ISCCPCOSP","CLDLOW_ISCCPCOSP", \
            "CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP", \
            "CLDTHICK_ISCCPCOSP", \
            "MEANPTOP_ISCCPCOSP","MEANCLDALB_ISCCPCOSP", \
            "CLDTOT_MISR","CLDLOW_MISR","CLDMED_MISR","CLDHGH_MISR", \
            "CLDTHICK_MISR", \
            "CLDTOT_MODIS","CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS", \
            "CLDTHICK_MODIS", \
            "CLWMODIS","CLIMODIS", \
            "IWPMODIS","LWPMODIS", \
            "REFFCLIMODIS","REFFCLWMODIS", \
            "TAUILOGMODIS","TAUWLOGMODIS","TAUTLOGMODIS", \
            "TAUIMODIS","TAUWMODIS","TAUTMODIS", \
            "PCTMODIS", \
            "CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL", \
            "CLDTOT_CS2"/) ; BRH
  nvars  = dimsizes(vars)
  cntr = new((/nvars,15/),float)
  dcntr = new((/nvars,15/),float)

  cntr = (/cntr_PREH2O, cntr_U200, cntr_FLUT,cntr_PREH2O,cntr_PREH2O,\
            cntr_U200,cntr_PRECT,cntr_PRECT,cntr_PREH2O, \
            cntr_U200,cntr_FLUT,cntr_FLUT,cntr_PREH2O,cntr_U200,  \
            cntr_CLDTOT_ISCCPCOSP,cntr_CLDLOW_ISCCPCOSP, \
            cntr_CLDMED_ISCCPCOSP,cntr_CLDHGH_ISCCPCOSP, \
            cntr_CLDTHICK_ISCCPCOSP, \
            cntr_MEANPTOP_ISCCPCOSP,cntr_MEANCLDALB_ISCCPCOSP, \
            cntr_CLDTOT_MISR,cntr_CLDLOW_MISR,cntr_CLDMED_MISR,cntr_CLDHGH_MISR, \
            cntr_CLDTHICK_MISR, \
            cntr_CLDTOT_MODIS,cntr_CLDLOW_MODIS,cntr_CLDMED_MODIS,cntr_CLDHGH_MODIS, \
            cntr_CLDTHICK_MODIS, \
            cntr_CLWMODIS,cntr_CLIMODIS, \
            cntr_IWPMODIS,cntr_LWPMODIS, \
            cntr_REFFCLIMODIS,cntr_REFFCLWMODIS, \
            cntr_TAUILOGMODIS,cntr_TAUWLOGMODIS,cntr_TAUTLOGMODIS, \
            cntr_TAUIMODIS,cntr_TAUWMODIS,cntr_TAUTMODIS, \
            cntr_PCTMODIS, \
            cntr_CLDTOT_CAL,cntr_CLDLOW_CAL,cntr_CLDMED_CAL,cntr_CLDHGH_CAL, \
            cntr_CLDTOT_CS2/) ; BRH
 
  dcntr = (/dcntr_PREH2O, dcntr_U200, dcntr_FLUT,dcntr_PREH2O,dcntr_PREH2O,\
            dcntr_U200,dcntr_PRECT,dcntr_PRECT,dcntr_PREH2O, \
            dcntr_U200,dcntr_FLUT,dcntr_FLUT,dcntr_PREH2O,dcntr_U200,  \
            dcntr_CLDTOT_ISCCPCOSP,dcntr_CLDLOW_ISCCPCOSP, \
            dcntr_CLDMED_ISCCPCOSP,dcntr_CLDHGH_ISCCPCOSP, \
            dcntr_CLDTHICK_ISCCPCOSP, \
            dcntr_MEANPTOP_ISCCPCOSP,dcntr_MEANCLDALB_ISCCPCOSP, \
            dcntr_CLDTOT_MISR,dcntr_CLDLOW_MISR,dcntr_CLDMED_MISR,dcntr_CLDHGH_MISR, \
            dcntr_CLDTHICK_MISR, \
            dcntr_CLDTOT_MODIS,dcntr_CLDLOW_MODIS,dcntr_CLDMED_MODIS,dcntr_CLDHGH_MODIS, \
            dcntr_CLDTHICK_MODIS, \
            dcntr_CLWMODIS,dcntr_CLIMODIS, \
            dcntr_IWPMODIS,dcntr_LWPMODIS, \
            dcntr_REFFCLIMODIS,dcntr_REFFCLWMODIS, \
            dcntr_TAUILOGMODIS,dcntr_TAUWLOGMODIS,dcntr_TAUTLOGMODIS, \
            dcntr_TAUIMODIS,dcntr_TAUWMODIS,dcntr_TAUTMODIS, \
            dcntr_PCTMODIS, \
            dcntr_CLDTOT_CAL,dcntr_CLDLOW_CAL,dcntr_CLDMED_CAL,dcntr_CLDHGH_CAL, \
            dcntr_CLDTOT_CS2/) ; BRH

 else 
;  model-to-model comparisons
   vars = (/"FLNT","PREH2O","PRECT","TAUX_OCEAN","U_200","SOLIN", \
            "CLDTOT_ISCCPCOSP","CLDLOW_ISCCPCOSP", \
            "CLDMED_ISCCPCOSP","CLDHGH_ISCCPCOSP", \
            "CLDTHICK_ISCCPCOSP", \
            "MEANPTOP_ISCCPCOSP","MEANCLDALB_ISCCPCOSP", \
            "CLDTOT_MISR","CLDLOW_MISR","CLDMED_MISR","CLDHGH_MISR", \
            "CLDTHICK_MISR", \
            "CLDTOT_MODIS","CLDLOW_MODIS","CLDMED_MODIS","CLDHGH_MODIS", \
            "CLDTHICK_MODIS", \
            "CLWMODIS","CLIMODIS", \
            "IWPMODIS","LWPMODIS", \
            "REFFCLIMODIS","REFFCLWMODIS", \
            "TAUILOGMODIS","TAUWLOGMODIS","TAUTLOGMODIS", \
            "TAUIMODIS","TAUWMODIS","TAUTMODIS", \
            "PCTMODIS", \
            "CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL", \
            "CLDTOT_CS2"/) ; BRH

 end if
 nvars  = dimsizes(vars)
;-----------------------------------------------------------------------
; common resources for contour plots
 plot = new(3,graphic)
 res                        = True        
 res@gsnDraw                = False      
 res@gsnFrame               = False
 res@txFontHeightF          = 0.025
 res@sfXArray               = ispan(0,12,1)
 res@tiMainFontHeightF      = 0.03
 res@tmXBMode               = "Explicit"
 res@tmXBValues             = ispan(0,12,1)
 res@tmXBLabels = (/"J","F","M","A","M","J","J","A","S",\
                    "O","N","D","J"/) 
 if (color_type .eq. "COLOR") then 
   res@cnFillOn  = True
   res@cnLinesOn = False
   res@lbTitleOn = True
   res@lbLabelFontHeightF = 0.018
   res@lbTitleFontHeightF = 0.02
   res@lbBoxMinorExtentF = 0.18
   res@cnLevelSelectionMode="ExplicitLevels"
   cmap = RGBtoCmap(rgb_file)
   if (compare .eq. "OBS") then
    
   else
     stride = (/2,1,1,2,2/)
     stride_diff = (/1,1,1,1,1/)
     cntr = new((/nvars,15/),float)
     dcntr = new((/nvars,15/),float)
     cntr(0,:)=(/100,115,130,145,160,175,190,205,220,235,250,260,270,280,290/)
     dcntr(0,:)=(/-13,-12,-10,-8,-6,-4,-2,0,2,4,6,8,10,12,13/) ;FLNT
     cntr(1,:)=(/2,4,8,12,16,20,24,28,32,36,40,44,46,48,50/) ; PREH2O
     dcntr(1,:)=(/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/)   ; PREH2O 
     cntr(2,:)=(/.5,1,2,3,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9/)  ; PRECT
     dcntr(2,:)=(/-2.5,-2,-1.5,-1,-.7,-.5,-.3,0,.3,.5,.7,1,1.5,2,2.5/) ; PRECT
     cntr(3,:)=(/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/) ; TAUX OCEAN
     dcntr(3,:)=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/)    ; TAUX
     cntr(4,:)=(/-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35,40,45/) ; U at 200
     dcntr(4,:)=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/) ; U at 200
     cntr(5,:)=(/5,25,50,75,100,125,150,175,200,250,300,350,400,450,500/)
     dcntr(5,:)=(/-30,-20,-15,-10,-5,-3,-1,0,1,3,5,10,15,20,30/) ;SOLIN
;    BRH additions for COSP
     cntr(6,:) = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/)  ; CLDTOT_ISCCPCOSP
     dcntr(6,:) = (/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)
     cntr(7,:) = (/4,8,12,16,20,24,28,32,36,40,44,48,52,56,60/)   ; CLDLOW_ISCCPCOSP
     dcntr(7,:) = dcntr(6,:) 
     cntr(8,:) = cntr(7,:) ; CLDMED_ISCCPCOSP
     dcntr(8,:) = dcntr(7,:) 
     cntr(9,:) = cntr(7,:) ; CLDHGH_ISCCPCOSP
     dcntr(9,:) = dcntr(7,:) 
     cntr(10,:) = cntr(7,:) ; CLDTHICK_ISCCP
     dcntr(10,:) = dcntr(7,:) 
     cntr(11,:)=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/) ; MEANPTOP_ISCCPCOSP
     dcntr(11,:)=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200,250,300/)
     cntr(12,:)=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/) ; MEANCLDALB_ISCCPCOSP
     dcntr(12,:)=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
     cntr(13,:) = cntr(6,:) ; CLDTOT_MISR
     dcntr(13,:) = dcntr(6,:)
     cntr(14,:) = cntr(7,:) ; CLDLOW_MISR
     dcntr(14,:) = dcntr(7,:)
     cntr(15,:) = cntr(8,:) ; CLDMED_MISR
     dcntr(15,:) = dcntr(8,:)
     cntr(16,:) = cntr(9,:) ; CLDHGH_MISR
     dcntr(16,:) = dcntr(9,:)
     cntr(17,:) = cntr(10,:) ; CLDTHICK_MISR
     dcntr(17,:) = dcntr(10,:)
     cntr(18,:) = cntr(6,:) ; CLDTOT_MODIS
     dcntr(18,:) = dcntr(6,:)
     cntr(19,:) = cntr(7,:) ; CLDLOW_MODIS
     dcntr(19,:) = dcntr(7,:)
     cntr(20,:) = cntr(8,:) ; CLDMED_MODIS
     dcntr(20,:) = dcntr(8,:)
     cntr(21,:) = cntr(9,:) ; CLDHGH_MODIS
     dcntr(21,:) = dcntr(9,:)
     cntr(22,:) = cntr(10,:) ; CLDTHICK_MODIS
     dcntr(22,:) = dcntr(10,:)
     cntr(23,:) = cntr(6,:) ; CLWMODIS
     dcntr(23,:) = dcntr(6,:)
     cntr(24,:) = cntr(6,:) ; CLWMODIS
     dcntr(24,:) = dcntr(6,:)
     cntr(25,:) = (/50,100,150,200,250,300,350,400,450,500,550,600,650,700,800/) ; IWPMODIS
     dcntr(25,:) = (/-700,-600,-500,-400,-300,-200,-100,0,100,200,300,400,500,600,700/)
     cntr(26,:) = (/40,80,120,160,200,240,280,320,360,400,440,480,520,560,600/) ; LWPMODIS
     dcntr(26,:) = (/-200,-150,-100,-80,-60,-40,-20,0,20,40,60,80,100,150,200/)
     cntr(27,:) = (/5,10,15,20,25,30,35,40,45,50,55,60,65,70,75/) ; REFFCLIMODIS
     dcntr(27,:) = (/-70,-60,-50,-40,-30,-20,-10,0,10,20,30,40,50,60,70/)
     cntr(28,:) = (/1.5,3.0,4.5,6.0,7.5,9.0,10.5,12.0,13.5,15.0,16.5,18.0,19.5,21.0,22.5/) ; REFFCLWMODIS
     dcntr(28,:) = (/-10.5,-9.0,-7.5,-6.0,-4.5,-3.0,-1.5,0,1.5,3.0,4.5,6.0,7.5,9.0,10.5/)
     cntr(29,:) = (/2,4,6,8,10,12,14,16,18,20,22,24,26,28,30/) ; TAUILOGMODIS
     dcntr(29,:) = (/-21,-18,-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21/)
     cntr(30,:) = cntr(29,:) ; TAUWLOGTMODIS
     dcntr(30,:) = dcntr(29,:)
     cntr(31,:) = cntr(29,:) ; TAUTLOGMODIS
     dcntr(31,:) = dcntr(29,:)
     cntr(32,:) = cntr(29,:) ; TAUIMODIS
     dcntr(32,:) = dcntr(29,:)
     cntr(33,:) = cntr(29,:) ; TAUWMODIS
     dcntr(33,:) = dcntr(29,:)
     cntr(34,:) = cntr(29,:) ; TAUTMODIS
     dcntr(34,:) = dcntr(29,:)
     cntr(35,:)=(/150,200,250,300,350,400,450,500,550,600,650,700,750,800,850/) ; PCTMODIS
     dcntr(35,:)=(/-300,-250,-200,-150,-100,-50,-25,0,25,50,100,150,200,250,300/)
     cntr(36,:) = cntr(6,:) ; CLDTOT_CAL
     dcntr(36,:) = dcntr(6,:)
     cntr(37,:) = cntr(7,:) ; CLDLOW_CAL
     dcntr(37,:) = dcntr(7,:)
     cntr(38,:) = cntr(8,:) ; CLDMED_CAL
     dcntr(38,:) = dcntr(8,:)
     cntr(39,:) = cntr(9,:) ; CLDHGH_CAL
     dcntr(39,:) = dcntr(9,:)
     cntr(40,:) = cntr(6,:) ; CLDTOT_CS2
     dcntr(40,:) = dcntr(6,:)
;    end BRH additions
   end if
 else
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnFillOn  = False
   res@cnLinesOn = True 
   res@cnLineLabelsOn = True 
   res@cnLineLabelInterval = 1
   res@cnLineLabelFontHeightF =  0.02
   res@cnInfoLabelFontHeightF =  0.02
   cnlvls = 15
   dcnlvls = 12
 end if
;****************************************************************************
 do i = 0, nvars-1

   ;print("==="+obsvars(i))

   if (vars(i).eq."FLNT") then
     A = cycle_FLNT (infile1,outptr1)
   end if
   if (vars(i).eq."FLUT") then
     A = cycle_FLUT (infile1,outptr1)
   end if
   if (vars(i).eq."PRECT") then
     A = cycle_PRECT (infile1,outptr1)
   end if
   if (vars(i).eq."PREH2O") then
     A = cycle_PREH2O (infile1,outptr1)
   end if
   if (vars(i).eq."SOLIN") then
     A = cycle_SOLIN (infile1,outptr1)
   end if
   if (vars(i).eq."TAUX_OCEAN") then
     A = cycle_TAUX_OCEAN (infile1,outptr1)
   end if
   if (vars(i).eq."U_200") then
     A = cycle_U_200 (infile1,outptr1)
   end if
;  BRH additions for COSP
;  ISCCP diagnostics
   if (vars(i).eq."CLDTOT_ISCCPCOSP") then
     A = cycle_CLDTOT_ISCCPCOSP (infile1,outptr1)
   end if
   if (vars(i).eq."CLDLOW_ISCCPCOSP") then
     A = cycle_CLDLOW_ISCCPCOSP (infile1,outptr1)
   end if
   if (vars(i).eq."CLDMED_ISCCPCOSP") then
     A = cycle_CLDMED_ISCCPCOSP (infile1,outptr1)
   end if
   if (vars(i).eq."CLDHGH_ISCCPCOSP") then
     A = cycle_CLDHGH_ISCCPCOSP (infile1,outptr1)
   end if
   if (vars(i).eq."CLDTHICK_ISCCPCOSP") then
     A = cycle_CLDTHICK_ISCCPCOSP (infile1,outptr1)
   end if
   if (vars(i).eq."MEANPTOP_ISCCPCOSP") then
     A = cycle_MEANPTOP_ISCCPCOSP (infile1,outptr1)
   end if
   if (vars(i).eq."MEANTTOP_ISCCPCOSP") then
     A = cycle_MEANTTOP_ISCCPCOSP (infile1,outptr1)
   end if
   if (vars(i).eq."MEANCLDALB_ISCCPCOSP") then
     A = cycle_MEANCLDALB_ISCCPCOSP (infile1,outptr1)
   end if
;  MISR diagnostics
   if (vars(i).eq."CLDTOT_MISR") then
     A = cycle_CLDTOT_MISR (infile1,outptr1)
   end if
   if (vars(i).eq."CLDLOW_MISR") then
     A = cycle_CLDLOW_MISR (infile1,outptr1)
   end if
   if (vars(i).eq."CLDMED_MISR") then
     A = cycle_CLDMED_MISR (infile1,outptr1)
   end if
   if (vars(i).eq."CLDHGH_MISR") then
     A = cycle_CLDHGH_MISR (infile1,outptr1)
   end if
   if (vars(i).eq."CLDTHICK_MISR") then
     A = cycle_CLDTHICK_MISR (infile1,outptr1)
   end if
;  MODIS diagnostics
   if (vars(i).eq."CLDTOT_MODIS") then
     A = cycle_CLDTOT_MODIS (infile1,outptr1)
   end if
   if (vars(i).eq."CLDLOW_MODIS") then
     A = cycle_CLDLOW_MODIS (infile1,outptr1)
   end if
   if (vars(i).eq."CLDMED_MODIS") then
     A = cycle_CLDMED_MODIS (infile1,outptr1)
   end if
   if (vars(i).eq."CLDHGH_MODIS") then
     A = cycle_CLDHGH_MODIS (infile1,outptr1)
   end if
   if (vars(i).eq."CLDTHICK_MODIS") then
     A = cycle_CLDTHICK_MODIS (infile1,outptr1)
   end if
   if (vars(i).eq."CLWMODIS") then
     A = cycle_CLWMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."CLIMODIS") then
     A = cycle_CLIMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."LWPMODIS") then
     A = cycle_LWPMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."IWPMODIS") then
     A = cycle_IWPMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."REFFCLWMODIS") then
     A = cycle_REFFCLWMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."REFFCLIMODIS") then
     A = cycle_REFFCLIMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."TAUWLOGMODIS") then
     A = cycle_TAUWLOGMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."TAUILOGMODIS") then
     A = cycle_TAUILOGMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."TAUTLOGMODIS") then
     A = cycle_TAUTLOGMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."TAUWMODIS") then
     A = cycle_TAUWMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."TAUIMODIS") then
     A = cycle_TAUIMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."TAUTMODIS") then
     A = cycle_TAUTMODIS (infile1,outptr1)
   end if
   if (vars(i).eq."PCTMODIS") then
     A = cycle_PCTMODIS (infile1,outptr1)
   end if
;  CALIPSO diagnostics
   if (vars(i).eq."CLDTOT_CAL") then
     A = cycle_CLDTOT_CAL (infile1,outptr1)
   end if
   if (vars(i).eq."CLDLOW_CAL") then
     A = cycle_CLDLOW_CAL (infile1,outptr1)
   end if
   if (vars(i).eq."CLDMED_CAL") then
     A = cycle_CLDMED_CAL (infile1,outptr1)
   end if
   if (vars(i).eq."CLDHGH_CAL") then
     A = cycle_CLDHGH_CAL (infile1,outptr1)
   end if
;  CLOUDSAT diagnostics
   if (vars(i).eq."CLDTOT_CS2") then
     A = cycle_CLDTOT_CS2 (infile1,outptr1)
   end if
   if (vars(i).eq."CLDTOT_CS") then
     A = cycle_CLDTOT_CS (infile1,outptr1)
   end if
;  end BRH additions

   if (all(A.eq.-999.0)) then
     print (vars(i)+" not present in test case input file.")
     delete (A)
     continue
   end if

;  CASE 2 IS OBS
   if (compare .eq. "OBS") then
     
     do m = 0, 11
       if (any(obsvars(i) .eq. nvap_vars)) then
         inptr2 = ptr_nvap(m)
         case2 = "NVAP"
       end if
       if (any(obsvars(i) .eq. merra_vars)) then
         inptr2 = ptr_merra(m)
         case2 = "MERRA"
       end if
       if (any(obsvars(i) .eq. erai_vars)) then
         inptr2 = ptr_erai(m)
         case2 = "ERAI"
       end if
       if (any(obsvars(i) .eq. era40_vars)) then
         inptr2 = ptr_era40(m)
         case2 = "ERA40"
       end if
       if (any(obsvars(i) .eq. jra25_vars)) then
         inptr2 = ptr_jra25(m)
         case2 = "JRA25"
       end if
       if (any(obsvars(i) .eq. erbe_vars)) then
         inptr2 = ptr_erbe(m)
         case2 = "ERBE"
       end if
       if (any(obsvars(i) .eq. ceres_vars)) then
         inptr2 = ptr_ceres(m)
         case2 = "CERES"
       end if
       if (any(obsvars(i) .eq. ceres2_vars)) then
         inptr2 = ptr_ceres2(m)
         case2 = "CERES-EBAF"
       end if
       if (any(obsvars(i) .eq. gpcp_vars)) then
         inptr2 = ptr_gpcp(m)
         case2 = "GPCP"
       end if
       if (any(obsvars(i) .eq. xa_vars)) then
         inptr2 = ptr_xa(m)
         case2 = "XIE-ARKIN"
       end if
;      BRH additions for COSP
       if (any(obsvars(i) .eq. isccpcosp_vars)) then
         inptr2 = ptr_isccpcosp(m)
         case2 = "ISCCP-COSP"
       end if
       if (any(obsvars(i) .eq. misrcosp_vars)) then
         inptr2 = ptr_misrcosp(m)
         case2 = "MISR L3 CTH-OD V5"
       end if
       if (any(obsvars(i) .eq. modiscosp_vars)) then
         inptr2 = ptr_modiscosp(m)
         case2 = "MODIS-COSP"
       end if
       if (any(obsvars(i) .eq. calipsocosp_vars)) then
         inptr2 = ptr_calipsocosp(m)
         case2 = "CALIPSO-GOCCP"
       end if
       if (any(obsvars(i) .eq. cloudsatcosp_vars)) then
         inptr2 = ptr_cloudsatcosp(m)
         case2 = "CLOUDSAT-COSP"
       end if
;      end BRH additions

       if (m.eq.0) then ; Find nlat2 and create B array for first month

         lat2 = inptr2->lat
         nlat2 = dimsizes(lat2)

         B = new((/13,nlat2/),float)
         B!0 = "time"
         B&time = ispan(1,13,1)
         B!1 = "lat"
         B&lat = lat2

       end if

       if (vars(i).eq."U_200") then
         tmp = inptr2->U(:,{200},:,:)   ; (time,lat,lon)
         B(m,:) = dim_avg(tmp)          ; (time,lat)
         B@long_name = "200mb zonal wind"
         B@units = "m/s"
       else
;        BRH edit to handle obs vars with no time dimension
         if (dimsizes(getfilevardimsizes(inptr2,obsvars(i))).eq.3) then
           tmp = inptr2->$vars(i)$(0,:,:)
         else
           tmp = inptr2->$vars(i)$
         end if
;        end BRH edit
         B(m,:) = dim_avg(tmp)          ; (time,lat)
       end if 
       delete(tmp)
     end do
     B(12,:) = B(0,:)                  ; wrap around

   else
;  model-to-model comparison

     if (vars(i).eq."FLNT") then
       B = cycle_FLNT (infile2,outptr2)
     end if
     if (vars(i).eq."FLUT") then
       B = cycle_FLUT (infile2,outptr2)
     end if
     if (vars(i).eq."PRECT") then
       B = cycle_PRECT (infile2,outptr2)
     end if
     if (vars(i).eq."PREH2O") then
       B = cycle_PREH2O (infile2,outptr2)
     end if
     if (vars(i).eq."SOLIN") then
       B = cycle_SOLIN (infile2,outptr2)
     end if
     if (vars(i).eq."TAUX_OCEAN") then
       B = cycle_TAUX_OCEAN (infile2,outptr2)
     end if
     if (vars(i).eq."U_200") then
       B = cycle_U_200 (infile2,outptr2)
     end if
;    BRH additions for COSP
;    ISCCP diagnostics
     if (vars(i).eq."CLDTOT_ISCCPCOSP") then
       B = cycle_CLDTOT_ISCCPCOSP (infile2,outptr2)
     end if
     if (vars(i).eq."CLDLOW_ISCCPCOSP") then
       B = cycle_CLDLOW_ISCCPCOSP (infile2,outptr2)
     end if
     if (vars(i).eq."CLDMED_ISCCPCOSP") then
       B = cycle_CLDMED_ISCCPCOSP (infile2,outptr2)
     end if
     if (vars(i).eq."CLDHGH_ISCCPCOSP") then
       B = cycle_CLDHGH_ISCCPCOSP (infile2,outptr2)
     end if
     if (vars(i).eq."CLDTHICK_ISCCPCOSP") then
       B = cycle_CLDTHICK_ISCCPCOSP (infile2,outptr2)
     end if
     if (vars(i).eq."MEANPTOP_ISCCPCOSP") then
       B = cycle_MEANPTOP_ISCCPCOSP (infile2,outptr2)
     end if
     if (vars(i).eq."MEANTTOP_ISCCPCOSP") then
       B = cycle_MEANTTOP_ISCCPCOSP (infile2,outptr2)
     end if
     if (vars(i).eq."MEANCLDALB_ISCCPCOSP") then
       B = cycle_MEANCLDALB_ISCCPCOSP (infile2,outptr2)
     end if
;    MISR diagnostics
     if (vars(i).eq."CLDTOT_MISR") then
       B = cycle_CLDTOT_MISR (infile2,outptr2)
     end if
     if (vars(i).eq."CLDLOW_MISR") then
       B = cycle_CLDLOW_MISR (infile2,outptr2)
     end if
     if (vars(i).eq."CLDMED_MISR") then
       B = cycle_CLDMED_MISR (infile2,outptr2)
     end if
     if (vars(i).eq."CLDHGH_MISR") then
       B = cycle_CLDHGH_MISR (infile2,outptr2)
     end if
     if (vars(i).eq."CLDTHICK_MISR") then
       B = cycle_CLDTHICK_MISR (infile2,outptr2)
     end if
;    MODIS diagnostics
     if (vars(i).eq."CLDTOT_MODIS") then
       B = cycle_CLDTOT_MODIS (infile2,outptr2)
     end if
     if (vars(i).eq."CLDLOW_MODIS") then
       B = cycle_CLDLOW_MODIS (infile2,outptr2)
     end if
     if (vars(i).eq."CLDMED_MODIS") then
       B = cycle_CLDMED_MODIS (infile2,outptr2)
     end if
     if (vars(i).eq."CLDHGH_MODIS") then
       B = cycle_CLDHGH_MODIS (infile2,outptr2)
     end if
     if (vars(i).eq."CLDTHICK_MODIS") then
       B = cycle_CLDTHICK_MODIS (infile2,outptr2)
     end if
     if (vars(i).eq."CLWMODIS") then
       B = cycle_CLWMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."CLIMODIS") then
       B = cycle_CLIMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."LWPMODIS") then
       B = cycle_LWPMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."IWPMODIS") then
       B = cycle_IWPMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."REFFCLWMODIS") then
       B = cycle_REFFCLWMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."REFFCLIMODIS") then
       B = cycle_REFFCLIMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."TAUWLOGMODIS") then
       B = cycle_TAUWLOGMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."TAUILOGMODIS") then
       B = cycle_TAUILOGMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."TAUTLOGMODIS") then
       B = cycle_TAUTLOGMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."TAUWMODIS") then
       B = cycle_TAUWMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."TAUIMODIS") then
       B = cycle_TAUIMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."TAUTMODIS") then
       B = cycle_TAUTMODIS (infile2,outptr2)
     end if
     if (vars(i).eq."PCTMODIS") then
       B = cycle_PCTMODIS (infile2,outptr2)
     end if
;    CALIPSO diagnostics
     if (vars(i).eq."CLDTOT_CAL") then
       B = cycle_CLDTOT_CAL (infile2,outptr2)
     end if
     if (vars(i).eq."CLDLOW_CAL") then
       B = cycle_CLDLOW_CAL (infile2,outptr2)
     end if
     if (vars(i).eq."CLDMED_CAL") then
       B = cycle_CLDMED_CAL (infile2,outptr2)
     end if
     if (vars(i).eq."CLDHGH_CAL") then
       B = cycle_CLDHGH_CAL (infile2,outptr2)
     end if
;    CLOUDSAT diagnostics
     if (vars(i).eq."CLDTOT_CS2") then
       B = cycle_CLDTOT_CS2 (infile2,outptr2)
     end if
     if (vars(i).eq."CLDTOT_CS") then
       B = cycle_CLDTOT_CS (infile2,outptr2)
     end if
;    end BRH additions
   end if

   if (all(B.eq.-999.)) then
     print (vars(i)+" not present in control case input file.")
     delete (A)
     delete (B)
     continue
   end if

;----------------------- Open files for plots ----------------------
   if (compare .eq. "OBS") then
     if (color_type .eq. "COLOR") then 
       wks = gsn_open_wks(plot_type,wkdir+"set8_"+obsvars(i)+"_obsc")
       gsn_define_colormap(wks,cmap)
     else
       wks = gsn_open_wks(plot_type,wkdir+"set8_"+obsvars(i)+"_obs")
     end if
   else
     if (color_type .eq. "COLOR") then 
       wks = gsn_open_wks(plot_type,wkdir+"set8_"+vars(i)+"_c")
       gsn_define_colormap(wks,cmap)
     else
       wks = gsn_open_wks(plot_type,wkdir+"set8_"+vars(i))
     end if
   end if

;------------------------------------------------------------------------
; case contour plots of time(x) vs. latitude(y)
   min1 = min(A)
   max1 = max(A)
   min2 = min(B)
   max2 = max(B)

   if (color_type .eq. "COLOR") then
     res@cnLevels = cntr(i,:) 
     res@lbLabelStride = 2
     res@lbOrientation = "Horizontal"
     res@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                        " MAX = "+sprintf("%6.2f",max1)
   else
     minab = min((/min1,min2/))
     maxab = max((/max1,max2/))
     mnmxint = nice_mnmxintvl(minab,maxab,cnlvls,False)
     res@cnMinLevelValF = mnmxint(0)
     res@cnMaxLevelValF = mnmxint(1)
     res@cnLevelSpacingF = mnmxint(2)
   end if

   res@gsnLeftString = A@long_name
   if (isvar("yrs_ave1")) then
     res@tiMainString = case1+" (yrs "+yrs_ave1+")"	
   else
     res@tiMainString = case1	
   end if
   res@sfYArray = lat1
   plot(0) = gsn_csm_lat_time(wks,A(lat|:,time|:),res)
   if (color_type .eq. "MONO") then
     plot(0) = ZeroNegDashLineContour (plot(0))
   else
     delete (res@lbTitleString)
   end if
   delete(res@sfYArray)
   delete(res@tiMainString)

   if (isvar("yrs_ave2")) then
     res@tiMainString = case2+" (yrs "+yrs_ave2+")"	
   else
     res@tiMainString = case2	
   end if
   res@sfYArray = lat2
   if (color_type .eq. "COLOR") then
     res@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                        " MAX = "+sprintf("%6.2f",max2)
   end if
   plot(1) = gsn_csm_lat_time(wks,B(lat|:,time|:),res)
   if (color_type .eq. "MONO") then
     plot(1) = ZeroNegDashLineContour (plot(1))
   else
     delete (res@cnLevels)
     delete (res@lbTitleString)
   end if

   delete (res@sfYArray)
   delete (res@gsnLeftString)
   delete (min1)
   delete (max1)
   delete (min2)
   delete (max2)

;----------------------------------------------------------------------
; difference plot of time(x) vs. latitude(y)
; check for different number of latitudes and then
; lineary interpolate to the smaller number of latitudes

   if (nlat1 .ne. nlat2) then                 ; lat grids different
     if (nlat1 .gt. nlat2) then
       tmp1 = linint1 (lat1,A,False,lat2,0)   ; a(time,lat)
       C = B                                  ; copy dims,coords
       C = (/tmp1-B/)                         ; get diff values
       delete (tmp1)
       res@sfYArray = lat2
     else
       tmp2 = linint1 (lat2,B,False,lat1,0)   ; b(time,lat)
       C = A                                  ; copy dims,coords
       C = (/A-tmp2/)                         ; get diff values
       delete (tmp2)
       res@sfYArray = lat1
     end if
   else                                       ; same grid latitudes
     C = A                                    ; copy dims,coords
     C = (/A-B/)                              ; get diff values
     res@sfYArray = lat1
   end if

   mind = min(C)
   maxd = max(C)

   res@tiMainString = case1+" - "+case2
   if (color_type .eq. "COLOR") then
     res@cnLevels = dcntr(i,:) 
     res@lbLabelStride = 1
     res@lbOrientation = "Vertical"
     res@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                        " MAX = "+sprintf("%6.2f",maxd)
   else
     mnmxint = nice_mnmxintvl(mind,maxd,dcnlvls,False)
     res@cnMinLevelValF = mnmxint(0)
     res@cnMaxLevelValF = mnmxint(1)
     res@cnLevelSpacingF = mnmxint(2)
   end if

   plot(2) = gsn_csm_lat_time(wks,C(lat|:,time|:),res)
   plot(2) = ZeroNegDashLineContour (plot(2))
   if (color_type .eq. "COLOR") then
     delete (res@lbTitleString)
;    delete (res@lbBoxMinorExtentF)
     delete (res@cnLevels)
   end if
   delete (mind)
   delete (maxd)

   pan = True
   pan@gsnMaximize = True
   pan@gsnFrame = False
   pan@gsnPaperOrientation = "portrait"
   if (time_stamp .eq. "True") then
     pan@gsnPanelBottom = 0.05
     gsn_panel(wks,plot,(/2,2/),pan)
     infoTimeStamp(wks, 0.011, "DIAG Version: "+version)   
   else
     gsn_panel(wks,plot,(/2,2/),pan)
   end if
   frame (wks)

   delete(C)
   delete(B)
   delete(res@sfYArray)
   if (compare.eq."OBS") then
     delete(lat2)
   end if

 end do                 ; loop over variables 
      
end
