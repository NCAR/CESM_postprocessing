; NCL script
; plot_polar_cons.ncl
; Mark Stevens, Sept 2001
; Jan 2002 updated with significance plots
;********************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" ; BRH
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
load "$DIAG_CODE/funcs_surf_variance.ncl"
;*********************************************************
begin
  compare    = getenv("COMPARE")
  color_type = getenv("COLORTYPE")
  rgb_file   = getenv("RGB_FILE")
  plot_type  = getenv("PLOTTYPE")
  season     = getenv("SEASON")
  version    = getenv("DIAG_VERSION")
  paleo      = getenv("PALEO")
  wkdir      = getenv("WKDIR")
  time_stamp = getenv("TIMESTAMP")
  tick_marks = getenv("TICKMARKS")
  case_names = getenv("CASENAMES")
  ncdf_mode  = getenv("NCDF_MODE")
  infile1    = getenv("TEST_INPUT")     ; case1 input filename
  outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
  infile2    = getenv("CNTL_INPUT")     ; case2 input filename
  sig_plot   = getenv("SIG_PLOT")
  if (compare .ne. "OBS") then
    outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
  end if
  if (sig_plot .eq. "True") then
    sig_lvl  = getenv("SIG_LVL")
    means1   = getenv("TEST_MEANS")     ; case1 means input filename
    varfile1 = getenv("TEST_VARIANCE")  ; case1 variances output filename
    means2   = getenv("CNTL_MEANS")     ; case2 means input filename
    varfile2 = getenv("CNTL_VARIANCE")  ; case2 variances output filename
    var_mode = getenv("VAR_MODE")
  end if

  if (paleo .eq. "True") then
    PALEO = True
    paleocoast1 = getenv("PALEOCOAST1")
    if (compare .eq. "USER") then
      paleocoast2 = getenv("PALEOCOAST2")
      diffs = getenv("DIFF_PLOTS")
      if (diffs .eq. "True") then
        DIFFS = True
      else
        DIFFS = False
      end if
    end if
  else
    PALEO = False
    DIFFS = True
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
    case1 = inptr1@case      ; case names
  end if
  if (sig_plot .eq. "True") then      ; significance plots
    meansptr1 = addfile(means1,"r")
    time1 = meansptr1->time
    nt1 = dimsizes(time1)
    if (var_mode .eq. "write") then
      varptr1 = addfile(varfile1,"w")
    else
      varptr1 = addfile(varfile1,"c")
    end if
  end if
  if (isatt(inptr1,"yrs_averaged")) then
    yrs_ave1 = inptr1@yrs_averaged
  end if
  tmp = inptr1->lat          ; latitudes
  if (typeof(tmp).eq."double") then
    lat1 = dble2flt(tmp)
  else
    lat1 = tmp
  end if
  delete(tmp)
  nlat1 = dimsizes(lat1)   ; number of latitudes
;jt  gw1 = inptr1->gw              ; gaussian weights
  if (isfilevar(inptr1,"gw")) then
    gw1 = inptr1->gw 
  else
    if (isfilevar(inptr1,"wgt")) then
      gw1 = inptr1->wgt
    else 
      gw1temp = latRegWgt(lat1,"double",0)  ; no gw1 in file
      gw1 = gw1temp
      delete(gw1temp)
      gw1!0 = "lat"
      gw1&lat = lat1
    end if
  end if
  tmp = inptr1->lon          ; longitudes
  if (typeof(tmp).eq."double") then
    lon1 = dble2flt(tmp)
  else
    lon1 = tmp
  end if
  delete(tmp)

;  CASE 2 MODEL OR OBS
  if (compare .eq. "OBS") then
    ptr_ceres2 = addfile(infile2+"/CERES-EBAF_"+season+"_climo.nc","r")
    ptr_ceres = addfile(infile2+"/CERES_"+season+"_climo.nc","r") 
    ptr_cru = addfile(infile2+"/CRU_"+season+"_climo.nc","r")
    ptr_erbe = addfile(infile2+"/ERBE_"+season+"_climo.nc","r")
    ptr_erai = addfile(infile2+"/ERAI_"+season+"_climo.nc","r")
    ptr_era40 = addfile(infile2+"/ERA40_"+season+"_climo.nc","r")
    ptr_jra25 = addfile(infile2+"/JRA25_"+season+"_climo.nc","r")
    ptr_laryea = addfile(infile2+"/LARYEA_"+season+"_climo.nc","r")
    ptr_gpcp = addfile(infile2+"/GPCP_"+season+"_climo.nc","r")
    ptr_had_cl = addfile(infile2+"/HadISST_CL_"+season+"_climo.nc","r")
    ptr_had_pd = addfile(infile2+"/HadISST_PD_"+season+"_climo.nc","r")
    ptr_had_pi = addfile(infile2+"/HadISST_PI_"+season+"_climo.nc","r")
    ptr_isccp = addfile(infile2+"/ISCCP_"+season+"_climo.nc","r")
    ptr_isccpFD = addfile(infile2+"/ISCCPFD_"+season+"_climo.nc","r")
    ptr_merra = addfile(infile2+"/MERRA_"+season+"_climo.nc","r")
    ptr_ssmi = addfile(infile2+"/SSMI_SEAICE_"+season+"_climo.nc","r")
    ptr_warren = addfile(infile2+"/WARREN_"+season+"_climo.nc","r")
    ptr_cloudsat = addfile(infile2+"/CLOUDSAT_"+season+"_climo.nc","r")
    ptr_will = addfile(infile2+"/WILLMOTT_"+season+"_climo.nc","r")
    ptr_calipsocosp = addfile(infile2+"/CALIPSOCOSP_"+season+"_climo.nc","r") ; BRH
    ptr_cloudsatcosp = addfile(infile2+"/CLOUDSATCOSP_"+season+"_climo.nc","r") ; BRH
  else
    inptr2 = addfile(infile2,"r")
    if (ncdf_mode .eq. "write")
      outptr2 = addfile(outfile2,"w")
    else
      outptr2 = addfile(outfile2,"c")
    end if
    if (case_names .eq. "True") then
      case2 = getenv("CASE2")
    else
      case2 = inptr2@case         ; case names
    end if
    if (sig_plot .eq. "True") then      ; significance plots
       meansptr2 = addfile(means2,"r")
       time2 = meansptr2->time
       nt2 = dimsizes(time2)
       if (var_mode .eq. "write") then
         varptr2 = addfile(varfile2,"w")
       else
         varptr2 = addfile(varfile2,"c")
       end if
    end if
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
;jt   gw2 = inptr2->gw 
    if (isfilevar(inptr2,"gw")) then
      gw2 = inptr2->gw 
    else
      if (isfilevar(inptr2,"wgt")) then
        gw2 = inptr2->wgt
      else 
        gw2temp = latRegWgt(lat2,"double",0)  ; no gw2 in file
        gw2 = gw2temp
        delete(gw2temp)
        gw2!0 = "lat"
        gw2&lat = lat2
      end if
    end if
    tmp = inptr2->lon
    if (typeof(tmp).eq."double") then
      lon2 = dble2flt(tmp)
    else
      lon2 = tmp
    end if
    delete(tmp)
  end if

;************************************************
; define variables to plot
;************************************************
; model-to-obs controls 
if (compare .eq. "OBS") then

  Pcntrs_PSL=(/991.,994.,997.,1000.,1003.,1006.,1009.,1012.,1015.,1018.,1021.,1024.,1027.,1030.,1033./)        
  dPcntrs_PSL=(/-12.,-10.,-8.,-6.,-4.,-2.,-1.,0.,1.,2.,4.,6.,8.,10.,12/)       
  Pcntrs_Z3_500=(/49.5,50.,50.5,51.,51.5,52.,52.5,53.,53.5,54.,54.5,55.,55.5,56.,56.5/)
  dPcntrs_Z3_500=(/-1.,-.8,-.6,-.4,-.3,-.2,-.1,0.,.1,.2,.3,.4,.6,.8,1/) 
  Pcntrs_CLD=(/5.,10.,15.,20.,25.,30.,40.,50.,60.,70.,75.,80.,85.,90.,95/) 
  dPcntrs_CLD=(/-50.,-40.,-30.,-20.,-15.,-10.,-5.,0.,5.,10.,15.,20.,30.,40.,50/)  
  Pcntrs_TS=(/210.,220.,230.,240.,250.,255.,260.,265.,270.,275.,280.,285.,290.,295.,300/)
  dPcntrs_TS=(/-15.,-12.,-9.,-7.,-5.,-3.,-1.,0.,1.,3.,5.,7.,9.,12.,15/)       
  Pcntrs_SST= (/-1,0,1,3,6,9,12,15,18,20,22,24,26,28,29/) 
  dPcntrs_SST=(/-5,-4,-3,-2,-1,-.5,-.2,0,.2,.5,1,2,3,4,5/) 
  Pcntrs_ICEFRAC=(/1.,5.,10.,15.,20.,30.,40.,50.,60.,70.,80.,85.,90.,95.,97/) 
  dPcntrs_ICEFRAC=(/-40.,-30.,-20.,-15.,-10.,-5.,-2.,0.,2.,5.,10.,15.,20.,30.,40/) 
  Pcntrs_FLUT=(/130.,140.,150.,160.,170.,180.,190.,200.,210.,220.,230.,240.,250.,260.,270/)
  dPcntrs_FLUT=(/-20.,-15.,-10.,-8.,-6.,-4.,-2.,0.,2.,4.,6.,8.,10.,15.,20/)         
  Pcntrs_FLUTC=(/150.,160.,170.,180.,190.,200.,210.,220.,230.,240.,250.,260.,270.,280.,290/)
  dPcntrs_FLUTC=(/-25.,-20.,-15.,-10.,-7.,-5.,-3.,0.,3.,5.,7.,10.,15.,20.,25/)       
  Pcntrs_FSNTOA=(/25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.,300.,325.,350.,375/)
  dPcntrs_FSNTOA=(/-60.,-40.,-30.,-20.,-15.,-10.,-5.,0.,5.,10.,15.,20.,30.,40.,60/) 
  Pcntrs_FSNTOAC=(/25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.,300.,325.,350.,375/)
  dPcntrs_FSNTOAC=(/-60.,-40.,-30.,-20.,-15.,-10.,-5.,0.,5.,10.,15.,20.,30.,40.,60/) ;
  Pcntrs_PS=(/650.,700.,750.,800.,820.,840.,860.,880.,900.,920.,940.,960.,980.,1000.,1020/)
  dPcntrs_PS=(/-15.,-10.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,10.,15/)  
  Pcntrs_PRECT=(/.3,.5,.7,1.0,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,6.0,7.0,8/)        
  dPcntrs_PRECT=(/-4.,-3.,-2.,-1.5,-1.,-.5,-.3,0,.3,.5,1.,1.5,2.,3.,4/)
  Pcntrs_FLDS=(/90.,110.,130.,150.,170.,190.,210.,230.,250.,270.,290.,310.,330.,350.,370/)
  dPcntrs_FLDS=(/-40.,-30.,-25.,-20.,-15.,-10.,-5.,0.,5.,10.,15.,20.,25.,30.,40/)  
  Pcntrs_FLDSC=(/70.,90.,110.,130.,150.,170.,190.,210.,230.,250.,270.,290.,310.,330.,350/)
  dPcntrs_FLDSC=(/-35.,-30.,-25.,-20.,-15.,-10.,-5.,0.,5.,10.,15.,20.,25.,30.,35/)  
  Pcntrs_FLNS=(/5.,10.,15.,20.,30.,40.,50.,60.,70.,80.,90.,100.,110.,120.,130/)    
  dPcntrs_FLNS=(/-35.,-30.,-25.,-20.,-15.,-10.,-5.,0.,5.,10.,15.,20.,25.,30.,35/) 
  Pcntrs_FLNSC=(/5.,10.,15.,20.,30.,40.,50.,60.,70.,80.,90.,100.,110.,120.,130/)    
  dPcntrs_FLNSC= (/-35.,-30.,-25.,-20.,-15.,-10.,-5.,0.,5.,10.,15.,20.,25.,30.,35/)                                     
  Pcntrs_FSDS=(/0.,25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,275.,300.,325.,350/)
  dPcntrs_FSDS=(/-80.,-60.,-40.,-30.,-20.,-10.,-5.,0.,5.,10.,20.,30.,40.,60.,80/)     
  Pcntrs_FSDSC=(/0.,20.,40.,60.,80.,100.,150.,200.,250.,280.,300.,320.,340.,360.,380/) 
  dPcntrs_FSDSC=(/-35.,-30.,-25.,-20.,-15.,-10.,-5.,0.,5.,10.,15.,20.,25.,30.,35/)    
  Pcntrs_FSNS=(/0.,25.,50.,75.,100.,125.,150.,175.,200.,220.,240.,260.,280.,300.,320/)
  dPcntrs_FSNS= (/-80.,-60.,-40.,-30.,-20.,-10.,-5.,0.,5.,10.,20.,30.,40.,60.,80/)   
  Pcntrs_FSNSC=(/0.,25.,50.,75.,100.,125.,150.,175.,200.,225.,250.,270.,290.,310.,330/)
  dPcntrs_FSNSC= (/-80.,-60.,-40.,-30.,-20.,-10.,-5.,0.,5.,10.,20.,30.,40.,60.,80/)                                
  Pcntrs_ALBEDO=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/) 
  dPcntrs_ALBEDO=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0,.03,.05,.07,.1,.15,.2,.25/)
  Pcntrs_SHFLX  = (/-100.,-80.,-50.,-30.,-20.,-10.,-5.,0.,5.,10.,20.,30.,50.,80.,100/)   
  dPcntrs_SHFLX = (/-100.,-80.,-50.,-30.,-20.,-10.,-5.,0.,5.,10.,20.,30.,50.,80.,100/)
  Pcntrs_QFLX  = (/-3.,-2.5,-2.,-1.5,-1.,-.5,-.3,0.,.3,.5,1.,1.5,2.,2.5,3./)  
  dPcntrs_QFLX = (/-2.,-1.5,-1.25,-1.,-0.75,-.5,-.25,0.,.25,.5,0.75,1.,1.25,1.5,2./)
  Pcntrs_CLD_CAL = (/5.,10.,15.,20.,25.,30.,40.,50.,60.,70.,75.,80.,85.,90.,95/)  ;
  dPcntrs_CLD_CAL = (/-50.,-40.,-30.,-20.,-15.,-10.,-5.,0.,5.,10.,15.,20.,30.,40.,50/)   
  Pcntrs_WIND_MAG_SURF = (/.5,1,1.5,2,2.5,3,4,5,6,7,8,9,10,11,12/)
  dPcntrs_WIND_MAG_SURF =  (/-6,-5,-4,-3,-2,-1,-.5,0,.5,1,2,3,4,5,6/)

  ceres2_vars = (/"FLUT_CERES-EBAF","FLUTC_CERES-EBAF","FSNTOA_CERES-EBAF","FSNTOAC_CERES-EBAF", \
                 "ALBEDO_CERES-EBAF","ALBEDOC_CERES-EBAF"/)
  cru_vars = (/"TREFHT_CRU"/)
  erbe_vars = (/"FLUT_ERBE","FLUTC_ERBE","FSNTOA_ERBE","FSNTOAC_ERBE"/)
  erai_vars = (/"Z3_500_ERAI", "PSL_ERAI", "TS_ERAI", "WIND_MAG_SURF_ERAI"/)
  era40_vars = (/"Z3_500_ERA40"/)
  jra25_vars = (/"PSL_JRA25","Z3_500_JRA25"/)
  laryea_vars = (/"FLNS_LARYEA","FSNS_LARYEA","SHFLX_LARYEA","QFLX_LARYEA"/)
  gpcp_vars = (/"PRECT_GPCP"/)
  had_cl_vars = (/"ICEFRAC_HADISST_CL", "SST_HADISST_CL"/)
  had_pd_vars = (/"ICEFRAC_HADISST_PD", "SST_HADISST_PD"/)
  had_pi_vars = (/"ICEFRAC_HADISST_PI", "SST_HADISST_PI"/)
  isccp_vars = (/"CLDHGH_ISCCP","CLDLOW_ISCCP","CLDMED_ISCCP","CLDTOT_ISCCP", \
                 "CLDHGH_VISIR","CLDLOW_VISIS","CLDMED_VISIR","CLDTOT_VISIR"/)
  isccpFD_vars=(/"FLDS_ISCCP","FLDSC_ISCCP","FLNS_ISCCP","FLNSC_ISCCP", \
                 "FSDS_ISCCP","FSDSC_ISCCP","FSNS_ISCCP","FSNSC_ISCCP"/)
  merra_vars = (/"PSL_MERRA","TS_MERRA","PS_MERRA","Z3_500_MERRA"/) 
  ssmi_vars = (/"ICEFRAC_SSMI"/)
  warren_vars = (/"CLDLOW_WARREN","CLDTOT_WARREN"/)
  cloudsat_vars = (/"CLDLOW_CLOUDSAT","CLDMED_CLOUDSAT","CLDHGH_CLOUDSAT","CLDTOT_CLOUDSAT"/)
  will_vars = (/"TREFHT_WILLMOTT"/)
  calipsocosp_vars = (/"CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL"/) 
  cloudsatcosp_vars = (/"CLDTOT_CS2"/) 

; obs variables
  obsvars = (/"PSL_MERRA","TS_MERRA","PS_MERRA","Z3_500_MERRA",\
             "Z3_500_ERAI", "PSL_ERAI", "TS_ERAI", "WIND_MAG_SURF_ERAI", \
             "CLDLOW_WARREN", "CLDTOT_WARREN","ICEFRAC_SSMI", \ 
             "ICEFRAC_HADISST_CL","SST_HADISST_CL", \
             "ICEFRAC_HADISST_PD","SST_HADISST_PD", \
             "ICEFRAC_HADISST_PI","SST_HADISST_PI", \
             "TREFHT_WILLMOTT","FLUT_ERBE", \
             "FLUTC_ERBE","FSNTOA_ERBE", \
             "FSNTOAC_ERBE","PRECT_GPCP", \
             "FLDS_ISCCP","FLDSC_ISCCP","FLNS_ISCCP","FLNSC_ISCCP", \
             "FSDS_ISCCP","FSDSC_ISCCP","FSNS_ISCCP","FSNSC_ISCCP", \
             "TREFHT_CRU","CLDHGH_VISIR", \
             "CLDLOW_VISIR","CLDMED_VISIR","CLDTOT_VISIR","Z3_500_ERA40", \
             "CLDLOW_CLOUDSAT","CLDMED_CLOUDSAT","CLDHGH_CLOUDSAT","CLDTOT_CLOUDSAT", \
             "FLNS_LARYEA","FSNS_LARYEA","SHFLX_LARYEA","QFLX_LARYEA", \
             "FLUT_CERES-EBAF","FLUTC_CERES-EBAF","FSNTOA_CERES-EBAF","FSNTOAC_CERES-EBAF", \
             "ALBEDO_CERES-EBAF","ALBEDOC_CERES-EBAF","Z3_500_JRA25","PSL_JRA25", \
             "CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL","CLDTOT_CS2"/) 

; corresponding model variables
  vars = (/"PSL","TS","PS","Z3_500", \
           "Z3_500",  "PSL", "TS", "WIND_MAG_SURF", \
           "CLDLOW","CLDTOT","ICEFRAC", \
           "ICEFRAC", "SST", \
           "ICEFRAC", "SST", \
           "ICEFRAC", "SST", \
           "TREFHT_LAND","FLUT", \
           "FLUTC","FSNTOA", \
           "FSNTOAC","PRECT",\
           "FLDS","FLDSC","FLNS", \
           "FLNSC","FSDS","FSDSC","FSNS","FSNSC", \
           "TREFHT_LAND","CLDHGH","CLDLOW", \
           "CLDMED","CLDTOT","Z3_500","CLDLOW","CLDMED","CLDHGH","CLDTOT",\
           "FLNS","FSNS","SHFLX","QFLX","FLUT","FLUTC","FSNTOA","FSNTOAC",\
           "ALBEDO","ALBEDOC","Z3_500","PSL", \
           "CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL","CLDTOT_CS2" /) 
 
; Define contours intervals
  nvars = dimsizes(vars)
  Pcntrs = new ((/nvars,15/),float)
  dPcntrs = new ((/nvars,15/),float)

; Contours for plots
  Pcntrs = (/Pcntrs_PSL, Pcntrs_TS, Pcntrs_PS,Pcntrs_Z3_500,\
        Pcntrs_Z3_500, Pcntrs_PSL, Pcntrs_TS, Pcntrs_WIND_MAG_SURF, \
        Pcntrs_CLD,Pcntrs_CLD,Pcntrs_ICEFRAC, \
        Pcntrs_ICEFRAC, Pcntrs_SST,  \
        Pcntrs_ICEFRAC, Pcntrs_SST,  \
        Pcntrs_ICEFRAC, Pcntrs_SST,  \
        Pcntrs_TS, Pcntrs_FLUT, \
        Pcntrs_FLUTC,Pcntrs_FSNTOA, \
        Pcntrs_FSNTOAC,Pcntrs_PRECT,\
        Pcntrs_FLDS,Pcntrs_FLDSC,Pcntrs_FLNS, \
        Pcntrs_FLNSC,Pcntrs_FSDS,Pcntrs_FSDSC,Pcntrs_FSNS,Pcntrs_FSNSC,Pcntrs_TS,Pcntrs_CLD,Pcntrs_CLD, \
        Pcntrs_CLD,Pcntrs_CLD,Pcntrs_Z3_500,Pcntrs_CLD,Pcntrs_CLD,Pcntrs_CLD,Pcntrs_CLD,\
        Pcntrs_FLNS,Pcntrs_FSNS,Pcntrs_SHFLX,Pcntrs_QFLX,Pcntrs_FLUT,Pcntrs_FLUTC,Pcntrs_FSNTOA,Pcntrs_FSNTOAC,\
        Pcntrs_ALBEDO,Pcntrs_ALBEDO,Pcntrs_Z3_500,Pcntrs_PSL, \
        Pcntrs_CLD_CAL,Pcntrs_CLD_CAL,Pcntrs_CLD_CAL,Pcntrs_CLD_CAL,Pcntrs_CLD/) 

; Contours for plots
  dPcntrs = (/dPcntrs_PSL, dPcntrs_TS, dPcntrs_PS,dPcntrs_Z3_500,\
        dPcntrs_Z3_500, dPcntrs_PSL, dPcntrs_TS, dPcntrs_WIND_MAG_SURF,  \
        dPcntrs_CLD,dPcntrs_CLD,dPcntrs_ICEFRAC, \
        dPcntrs_ICEFRAC, dPcntrs_SST, \
        dPcntrs_ICEFRAC, dPcntrs_SST, \
        dPcntrs_ICEFRAC, dPcntrs_SST, \
        dPcntrs_TS, dPcntrs_FLUT, \
        dPcntrs_FLUTC,dPcntrs_FSNTOA, \
        dPcntrs_FSNTOAC,dPcntrs_PRECT,\
        dPcntrs_FLDS,dPcntrs_FLDSC,dPcntrs_FLNS, \
        dPcntrs_FLNSC,dPcntrs_FSDS,dPcntrs_FSDSC,dPcntrs_FSNS,dPcntrs_FSNSC, \
        dPcntrs_TS,dPcntrs_CLD,dPcntrs_CLD, \
        dPcntrs_CLD,dPcntrs_CLD,dPcntrs_Z3_500,dPcntrs_CLD,dPcntrs_CLD,dPcntrs_CLD,dPcntrs_CLD,\
        dPcntrs_FLNS,dPcntrs_FSNS,dPcntrs_SHFLX,dPcntrs_QFLX,dPcntrs_FLUT,dPcntrs_FLUTC,dPcntrs_FSNTOA,dPcntrs_FSNTOAC,\
        dPcntrs_ALBEDO,dPcntrs_ALBEDO,dPcntrs_Z3_500,dPcntrs_PSL, \
        dPcntrs_CLD_CAL,dPcntrs_CLD_CAL,dPcntrs_CLD_CAL,dPcntrs_CLD_CAL,dPcntrs_CLD/) 

;---------------------------------------------------------------------------
; model-to-model controls only
else
  vars = (/"FSNT","FLNT","FSNS","FLNS","FSDS","PSL","Z3_500","TGCLDLWP", \
           "TS","CLDTOT","CLDHGH","CLDMED","CLDLOW","FLDS","FLDSC", \
           "ICEFRAC","PRECST","SNOWH","SNOWHICE","SNOWHLND","PS", \
           "PRECT","FSDSC","FSNSC","ALBSURF","TGCLDIWP","FLNSC","ALBEDO", \
           "ALBEDOC", \
           "CLDTOT_CAL","CLDLOW_CAL","CLDMED_CAL","CLDHGH_CAL","CLDTOT_CS2"/) ; BRH
  nvars = dimsizes(vars)
;----------------------------------------------------------------------
; Polar plots
  Pcntrs = new ((/nvars,15/),float)
  dPcntrs = new ((/nvars,15/),float)
  Pcntrs(0,:)=(/0,25,50,75,100,125,150,175,200,225,250,275,300,325,350/) ;FSNT
  dPcntrs(0,:)=(/-40,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,40/)      ;FSNT
  Pcntrs(1,:)=(/150,160,170,180,190,200,210,220,230,240,250,260,270,280,290/)
  dPcntrs(1,:)=(/-20,-15,-10,-8,-6,-4,-2,0,2,4,6,8,10,15,20/)            ;FLNT
  Pcntrs(2,:)=(/0,25,50,75,100,125,150,175,200,220,240,260,280,300,320/) ;FSNS
  dPcntrs(2,:)=(/-40,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,40/)      ;FSNS
  Pcntrs(3,:)=(/5,10,15,20,30,40,50,60,70,80,90,100,110,120,130/)        ;FLNS
  dPcntrs(3,:)=(/-20,-15,-10,-8,-6,-4,-2,0,2,4,6,8,10,15,20/)            ;FLNS
  Pcntrs(4,:)=(/0,25,50,75,100,125,150,175,200,225,250,275,300,325,350/) ;FSDS
  dPcntrs(4,:)=(/-40,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,40/)      ;FSDS
  Pcntrs(5,:)=(/991,994,997,1000,1003,1006,1009,1012,1015,1018,1021,1024,1027, \
                1030,1033/)                             ; PSL 
  dPcntrs(5,:)=(/-12,-10,-8,-6,-4,-2,-1,0,1,2,4,6,8,10,12/)  ; PSL
  Pcntrs(6,:)=(/49.5,50,50.5,51,51.5,52,52.5,53,53.5,54,54.5,55,55.5,56,56.5/)
  dPcntrs(6,:)=(/-1,-.8,-.6,-.4,-.3,-.2,-.1,0,.1,.2,.3,.4,.6,.8,1/)      ;Z3
  Pcntrs(7,:)=(/10,30,50,90,130,170,210,250,290,330,370,400,420,440,460/) ;TGCLDLWP
  dPcntrs(7,:)=(/-60,-50,-40,-30,-20,-10,-5,0,5,10,20,30,40,50,60/)   ;TGCLDLWP
  Pcntrs(8,:)=(/210,220,230,240,250,255,260,265,270,275,280,285,290,295,300/)
  dPcntrs(8,:)=(/-15,-12,-9,-7,-5,-3,-1,0,1,3,5,7,9,12,15/)           ; TS 
  Pcntrs(9,:)=(/10,20,30,40,45,50,55,60,65,70,75,80,85,90,95/)  ;CLDTOT
  dPcntrs(9,:)=(/-50,-40,-30,-20,-15,-10,-5,0,5,10,15,20,30,40,50/)  
  Pcntrs(10,:) = Pcntrs(9,:)         ; CLDHGH
  dPcntrs(10,:) = dPcntrs(9,:)
  Pcntrs(11,:) = Pcntrs(9,:)         ; CLDMED
  dPcntrs(11,:) = dPcntrs(9,:)
  Pcntrs(12,:) = Pcntrs(9,:)         ; CLDLOW
  dPcntrs(12,:) = dPcntrs(9,:)
  Pcntrs(13,:)=(/90,110,130,150,170,190,210,230,250,270,290,310,330,350,370/)
  dPcntrs(13,:)=(/-40,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,40/)  ;FLDS
  Pcntrs(14,:)=(/70,90,110,130,150,170,190,210,230,250,270,290,310,330,350/)
  dPcntrs(14,:)=(/-35,-30,-25,-20,-15,-10,-5,0,5,10,15,20,25,30,35/)  ;FLDSC
  Pcntrs(15,:)=(/1,5,10,15,20,30,40,50,60,70,80,85,90,95,97/) ;ICEFRAC 
  dPcntrs(15,:)=(/-40,-30,-20,-15,-10,-5,-2,0,2,5,10,15,20,30,40/) 
  Pcntrs(16,:)=(/.2,.4,.6,.8,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6/)   ; PRECST
  dPcntrs(16,:)=(/-2.5,-2,-1.5,-1,-.7,-.5,-.3,0,.3,.5,.7,1,1.5,2,2.5/)
  Pcntrs(17,:)=(/1,3,5,7,10,15,20,30,40,50,60,70,80,90,95/) ; SNOWH
  dPcntrs(17,:)=(/-25,-20,-15,-10,-7,-5,-3,0,3,5,7,10,15,20,25/)
  Pcntrs(18,:)=(/.5,1,2,3,4,5,6,7,8,10,12,14,16,18,20/) ;SNOWHICE
  dPcntrs(18,:)=(/-10,-8,-6,-4,-2,-1,-.5,0,.5,1,2,4,6,8,10/)
  Pcntrs(19,:)=(/1,3,5,7,10,15,20,30,40,50,60,70,80,90,95/) ; SNOWHLND
  dPcntrs(19,:)=(/-25,-20,-15,-10,-7,-5,-3,0,3,5,7,10,15,20,25/)
  Pcntrs(20,:)=(/650,700,750,800,820,840,860,880,900,920,940,960,980,1000,1020/)
  dPcntrs(20,:)=(/-15,-10,-5,-4,-3,-2,-1,0,1,2,3,4,5,10,15/)  ; PS
  Pcntrs(21,:)=(/.3,.5,.7,1,1.5,2,2.5,3,3.5,4,4.5,5,6,7,8/)   ; PRECT
  dPcntrs(21,:)=(/-4,-3,-2,-1.5,-1,-.5,-.3,0,.3,.5,1,1.5,2,3,4/)
  Pcntrs(22,:)=(/0,20,40,60,80,100,150,200,250,280,300,320,340,360,380/) ;FSDSC
  dPcntrs(22,:)=(/-25,-20,-15,-10,-6,-4,-2,0,2,4,6,10,15,20,25/)      ;FSDSC
  Pcntrs(23,:)=(/0,25,50,75,100,125,150,175,200,225,250,270,290,310,330/) ;FSNSC
  dPcntrs(23,:)=(/-30,-25,-20,-15,-10,-5,-2,0,2,5,10,15,20,25,30/)      ;FSNSC
  Pcntrs(24,:)=(/.05,.1,.15,.2,.25,.3,.4,.5,.6,.7,.75,.8,.85,.9,.95/) ;ALBSURF
  dPcntrs(24,:)=(/-.25,-.2,-.15,-.1,-.07,-.05,-.03,0.,.03,.05,.07,.1,.15,.2,.25/)
  Pcntrs(25,:)=(/1,5,10,15,20,25,30,35,40,45,50,55,60,70,80/)
  dPcntrs(25,:)=(/-15,-12,-9,-7,-5,-3,-1,0,1,3,5,7,9,12,15/) ;TGCLDIWP
  Pcntrs(26,:)=(/5,10,15,20,30,40,50,60,70,80,90,100,110,120,130/)    ;FLNSC
  dPcntrs(26,:)=(/-20,-15,-10,-8,-6,-4,-2,0,2,4,6,8,10,15,20/)        ;FLNSC
  Pcntrs(27,:) = Pcntrs(24,:)    ; ALBEDO
  dPcntrs(27,:) = dPcntrs(24,:)
  Pcntrs(28,:) = Pcntrs(24,:)    ; ALBEDOC
  dPcntrs(28,:) = dPcntrs(24,:)
; BRH additions for COSP diagnostics
  Pcntrs(29,:) = (/5,10,15,20,25,30,40,50,60,70,75,80,85,90,95/) ; CLDTOT_CAL
  dPcntrs(29,:) = dPcntrs(9,:)
  Pcntrs(30,:) = (/5,10,15,20,25,30,35,40,45,50,55,60,65,70,75/) ; CLDLOW_CAL
  dPcntrs(30,:) = dPcntrs(9,:)
  Pcntrs(31,:) = Pcntrs(30,:) ; CLDMED_CAL
  dPcntrs(31,:) = dPcntrs(30,:)
  Pcntrs(32,:) = Pcntrs(30,:) ; CLDHGH_CAL
  dPcntrs(32,:) = dPcntrs(30,:)
  Pcntrs(33,:) = Pcntrs(29,:) ; CLDTOT_CS2
  dPcntrs(33,:) = dPcntrs(29,:)
; end BRH additions

end if
;-----------------------------------------------------------------------
; common resources for north and south polar plots
spmaxlat = -55
npminlat =  50 
polar = True
polar@gsnDraw  = False
polar@gsnFrame = False
polar@gsnAddCyclic = True
if (tick_marks .eq. "True") then
  polar@gsnTickMarksOn = True 
else
  polar@gsnTickMarksOn = False
end if
polar@mpGridAndLimbOn = False
polar@tiMainFontHeightF = 0.025
polar@txFontHeightF = 0.022
polar@mpGeophysicalLineThicknessF = 1.5
polar@mpPerimOn = True
polar@mpPerimDrawOrder = "PostDraw" 
if (color_type .eq. "COLOR") then
  polar@mpFillOn = True           ; land fill off
  polar@mpLandFillColor = "Background"
  polar@cnLevelSelectionMode = "ExplicitLevels"
  polar@cnFillOn       = True
  polar@cnLinesOn      = False
  polar@cnLineLabelsOn = False
  polar@lbLabelFontHeightF = 0.017
  polar@lbTitleFontHeightF = 0.018
  polar@lbBoxMinorExtentF = 0.18
else
  polar@mpFillOn =  True           ; land fill on
  polar@cnLevelSelectionMode = "ManualLevels"
  polar@cnLinesOn      = True 
  polar@cnLineLabelsOn = True
  polar@cnLineLabelInterval = 1
  polar@cnLineLabelFontHeightF = .018
  polar@cnInfoLabelFontHeightF = .018
  cnlvls = 15
  dcnlvls = 12
end if 
;----------------------------------------------------
; common resources for planel plots
panP = True
panP@gsnMaximize = True
panP@gsnPaperOrientation = "portrait"
if (sig_plot .eq. "True") then
  panP@gsnPanelXWhiteSpacePercent = 2
  panP@gsnPanelYWhiteSpacePercent = 2
end if
panP@txFontHeightF = 0.020
panP@txFont = "helvetica-bold"
panP@gsnFrame = False
;--------------------------------------------------------------
if (sig_plot .eq. "True") then
  plotNP = new((/4/),"graphic")    ; NH polar plots
  plotSP = new((/4/),"graphic")    ; SH polar plots
  SigLvl = sig_lvl                 ; Significance level
else
  plotNP = new((/3/),"graphic")    ; NH polar plots
  plotSP = new((/3/),"graphic")    ; SH polar plots
end if
;*****************************************************************
; loop over the variables to plot

do i = 0,  nvars-1  

  ;print("======== cons ==="+vars(i))
  ;print("======== cons ==="+obsvars(i))

  if (vars(i) .eq. "ALBEDO") then
    A = get_ALBEDO (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_ALBEDO_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "ALBEDOC") then
    A = get_ALBEDOC (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_ALBEDOC_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "ALBSURF") then
    A = get_ALBSURF (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_ALBSURF_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "CLDHGH") then
    A = get_CLDHGH (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDHGH")
    end if
  end if
  if (vars(i) .eq. "CLDLOW") then
    A = get_CLDLOW (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDLOW")
    end if
  end if
  if (vars(i) .eq. "CLDMED") then
    A = get_CLDMED (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDMED")
    end if
  end if
  if (vars(i) .eq. "CLDTOT") then
    A = get_CLDTOT (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTOT")
    end if
  end if
  if (vars(i) .eq. "FLDS") then
    A = get_FLDS (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_FLDS_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "FLDSC") then
    A = get_FLDSC (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_FLDSC_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "FLNS") then
    A = get_FLNS (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FLNS")
    end if
  end if
  if (vars(i) .eq. "FLNSC") then
    A = get_FLNSC (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FLNSC")
    end if
  end if
  if (vars(i) .eq. "FLNT") then
    A = get_FLNT (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FLNT")
    end if
  end if
  if (vars(i) .eq. "FLUT") then
    A = get_FLUT (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FLUT")
    end if
  end if
  if (vars(i) .eq. "FLUTC") then
    A = get_FLUTC (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FLUTC")
    end if
  end if
  if (vars(i) .eq. "FSDS") then
    A = get_FSDS (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSDS")
    end if
  end if
  if (vars(i) .eq. "FSDSC") then
    A = get_FSDSC (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSDSC")
    end if
  end if
  if (vars(i) .eq. "FSNS") then
    A = get_FSNS (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSNS")
    end if
  end if
  if (vars(i) .eq. "FSNSC") then
    A = get_FSNSC (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSNSC")
    end if
  end if
  if (vars(i) .eq. "FSNT") then
    A = get_FSNT (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSNT")
    end if
  end if
  if (vars(i) .eq. "FSNTOA") then
    A = get_FSNTOA (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSNTOA")
    end if
  end if
  if (vars(i) .eq. "FSNTOAC") then
    A = get_FSNTOAC (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"FSNTOAC")
    end if
  end if
  if (vars(i) .eq. "ICEFRAC") then
    A = get_ICEFRAC (inptr1,outptr1) 
    if (all(A.eq.-999.)) then
      print ("ICEFRAC not present in test case input file.") 
      delete(A)
      continue
    else
      A = (/A*100./)                    ; convert to percent
      A@units = "%"
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"ICEFRAC")
      end if
    end if
  end if
  if (vars(i) .eq. "SST") then
    A = get_SST (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_SST_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PRECT") then
    A = get_PRECT (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_PRECT_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PRECST") then
    A = get_PRECST (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_PRECST_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PS") then
    A = get_PS (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_PS_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "PSL") then
    A = get_PSL (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_PSL_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "QFLX") then
    A = get_QFLX (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_QFLX_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "SHFLX") then
    A = get_SHFLX (inptr1,outptr1)
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"SHFLX")
    end if
  end if
  if (vars(i) .eq. "SNOWH") then
    A = get_SNOWH (inptr1,outptr1) 
    if (all(A.eq.-999.)) then
      print ("SNOWH not present in test case input file.") 
      delete(A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_SNOWH_VARIANCE (meansptr1,varptr1,"SNOWH")
      end if
    end if
  end if
  if (vars(i) .eq. "SNOWHICE") then
    A = get_SNOWHICE (inptr1,outptr1) 
    if (all(A.eq.-999.)) then
      print ("SNOWHICE not present in test case input file.") 
      delete(A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_SNOWH_VARIANCE (meansptr1,varptr1,"SNOWHICE")
      end if
    end if
  end if
  if (vars(i) .eq. "SNOWHLND") then
    A = get_SNOWHLND (inptr1,outptr1) 
    if (all(A.eq.-999.)) then
      print ("SNOWHLND not present in test case input file.") 
      delete(A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_SNOWH_VARIANCE (meansptr1,varptr1,"SNOWHLND")
      end if
    end if
  end if
  if (vars(i) .eq. "TGCLDIWP") then
    A = get_TGCLDIWP (inptr1,outptr1) 
    if (all(A.eq.-999.)) then
      print ("TGCLDIWP not present in test case input file.") 
      delete(A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"TGCLDIWP")
      end if
    end if
  end if
  if (vars(i) .eq. "TGCLDLWP") then
    A = get_TGCLDLWP (inptr1,outptr1) 
    if (all(A.eq.-999.)) then
      print ("TGCLDLWP not present in test case input file.") 
      delete(A)
      continue
    else
      if (sig_plot .eq. "True") then
        A_var = get_VARIANCE (meansptr1,varptr1,"TGCLDLWP")
      end if
    end if
  end if
  if (vars(i) .eq. "TREFHT_LAND") then
    A = get_TREFHT_LAND (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_TREFHT_LAND_VARIANCE (meansptr1,varptr1)
    end if
  end if
  if (vars(i) .eq. "TS") then
    A = get_TS (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"TS")
    end if
  end if
  if (vars(i) .eq. "WIND_MAG_SURF") then
    A = get_WIND_MAG_SURF (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"WIND_MAG_SURF")
    end if
  end if
  if (vars(i) .eq. "Z3_500") then
    A = get_Z3_500 (inptr1,outptr1) 
    if (sig_plot .eq. "True") then
      A_var = get_PLEVEL_VARIANCE (meansptr1,varptr1,"Z3_500",500.)
    end if
  end if
 
 if (vars(i) .eq. "CLDTOT_CAL") then
    A = get_CLDTOT_CAL (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print (" not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTOT_CAL")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDLOW_CAL") then
    A = get_CLDLOW_CAL (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print (" not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDLOW_CAL")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDMED_CAL") then
    A = get_CLDMED_CAL (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print (" not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDMED_CAL")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDHGH_CAL") then
    A = get_CLDHGH_CAL (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print (" not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDHGH_CAL")
      end if
    end if
  end if
  if (vars(i) .eq. "CLDTOT_CS2") then
    A = get_CLDTOT_CS2 (inptr1,outptr1)
    if (all(A.eq.-999.)) then
      print (" not present in test case input file.")
      delete (A)
      continue
    else  
      if (sig_plot .eq. "True") then
      A_var = get_VARIANCE (meansptr1,varptr1,"CLDTOT_CS2")
      end if
    end if
  end if


  if (all(A.eq.-999.)) then    
    print (vars(i)+" not present in test case input file.") 
    delete(A)
    continue         ; procede to next variable in do loop
  end if

;print("===> "+ obsvars(i) )

  if (compare .eq. "OBS") then             ; case 2 is obs

    if (any(obsvars(i) .eq. ceres2_vars)) then
      inptr2 = ptr_ceres2
      case2 = "CERES-EBAF"
    end if
    if (any(obsvars(i) .eq. cru_vars)) then
      inptr2 = ptr_cru
      case2 = "IPCC/CRU"
    end if
    if (any(obsvars(i) .eq. erbe_vars)) then
      inptr2 = ptr_erbe
      case2 = "ERBE"
    end if
    if (any(obsvars(i) .eq. erai_vars)) then
      inptr2 = ptr_erai
      case2 = "ERAI"
    end if
    if (any(obsvars(i) .eq. era40_vars)) then
      inptr2 = ptr_era40
      case2 = "ERA40"
    end if
    if (any(obsvars(i) .eq. jra25_vars)) then
      inptr2 = ptr_jra25
      case2 = "JRA25"
    end if
    if (any(obsvars(i) .eq. laryea_vars)) then
      inptr2 = ptr_laryea
      case2 = "LARGE-YEAGER"
    end if
    if (any(obsvars(i) .eq. gpcp_vars)) then
      inptr2 = ptr_gpcp
      case2 = "GPCP"
    end if
    if (any(obsvars(i) .eq. had_cl_vars)) then
      inptr2 = ptr_had_cl
      case2 = "HadISST_CL"
    end if
    if (any(obsvars(i) .eq. had_pd_vars)) then
      inptr2 = ptr_had_pd
      case2 = "HadISST_PD"
    end if
    if (any(obsvars(i) .eq. had_pi_vars)) then
      inptr2 = ptr_had_pi
      case2 = "HadISST_PI"
    end if
    if (any(obsvars(i) .eq. isccp_vars)) then
      inptr2 = ptr_isccp
      case2 = "ISCCP D2"
    end if
    if (any(obsvars(i) .eq. isccpFD_vars)) then
      inptr2 = ptr_isccpFD
      case2 = "ISCCP FD"
    end if
    if (any(obsvars(i) .eq. merra_vars)) then
      inptr2 = ptr_merra
      case2 = "MERRA"
    end if
    if (any(obsvars(i) .eq. ssmi_vars)) then
      inptr2 = ptr_ssmi
      case2 = "SMMR & SSM/I"
    end if
    if (any(obsvars(i) .eq. warren_vars)) then
      inptr2 = ptr_warren
      case2 = "WARREN"
    end if
    if (any(obsvars(i) .eq. cloudsat_vars)) then
      inptr2 = ptr_cloudsat
      case2 = "CLOUDSAT"
    end if
    if (any(obsvars(i) .eq. will_vars)) then
      inptr2 = ptr_will
      case2 = "WILLMOTT"
    end if
    if (any(obsvars(i) .eq. calipsocosp_vars)) then
      inptr2 = ptr_calipsocosp
      case2 = "CALIPSO-GOCCP"
    end if
    if (any(obsvars(i) .eq. cloudsatcosp_vars)) then
      inptr2 = ptr_cloudsatcosp
      case2 = "CLOUDSAT-COSP"
    end if


;   get the latitudes, longitudes and weights
    lat2 = inptr2->lat
    nlat2 = dimsizes(lat2)
    lon2 = inptr2->lon
    if (any(obsvars(i).eq.warren_vars)) then
      gw2 = latGauWgt(64,"lat","gaussian weights","none")  ; no gw in file 
    else
      if (isfilevar(inptr2,"wgt")) then
        gw2 = inptr2->wgt          ; non-gaussian weights (1x1 degree)
      else
        gw2 = inptr2->gw           ; gaussian weights
      end if
    end if
    if (vars(i).eq."Z3_500" .or. vars(i).eq."TREFHT_LAND" .or. \
        obsvars(i).eq."CLDLOW_WARREN" .or. obsvars(i).eq."CLDTOT_WARREN" .or. \
        obsvars(i).eq."CLDLOW_CLOUDSAT" .or. obsvars(i).eq."CLDMED_CLOUDSAT" .or. \
        obsvars(i).eq."CLDHGH_CLOUDSAT" .or. obsvars(i).eq."CLDTOT_CLOUDSAT" ) then
   
      if (vars(i).eq."Z3_500") then
        B = inptr2->Z3(0,{500},:,:)
        B@long_name = "500mb geopotential height"
        B@units = "hectometers"
        B = (/B/100./)    ; convert to hectometers
      else
        B = inptr2->$vars(i)$   ; no time dimension
      end if
    else
      if (isfilevar(inptr2,obsvars(i))) then
        if (dimsizes(getfilevardimsizes(inptr2,obsvars(i))).eq.3) then ; handle other obs files that don't have time dimension
          B = inptr2->$obsvars(i)$(0,:,:)
        else
          B = inptr2->$obsvars(i)$
        end if
      else
       if (dimsizes(getfilevardimsizes(inptr2,vars(i))).eq.3) then ; handle other obs files that don't have time dimension
          B = inptr2->$vars(i)$(0,:,:)
        else
          B = inptr2->$vars(i)$
        end if
      end if
  
      if (vars(i).eq."ICEFRAC") then
        B = (/B*100./)  ; convert to percent
        B@units = "%"
      end if
    end if


  else                                     ; case 2 is model
    if (vars(i) .eq. "ALBEDO") then
      B = get_ALBEDO (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_ALBEDO_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "ALBEDOC") then
      B = get_ALBEDOC (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_ALBEDOC_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "ALBSURF") then
      B = get_ALBSURF (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_ALBSURF_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "CLDHGH") then
      B = get_CLDHGH (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDHGH")
      end if
    end if
    if (vars(i) .eq. "CLDLOW") then
      B = get_CLDLOW (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDLOW")
      end if
    end if
    if (vars(i) .eq. "CLDMED") then
      B = get_CLDMED (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDMED")
      end if
    end if
    if (vars(i) .eq. "CLDTOT") then
      B = get_CLDTOT (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTOT")
      end if
    end if
    if (vars(i) .eq. "FLDS") then
      B = get_FLDS (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_FLDS_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "FLDSC") then
      B = get_FLDSC (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_FLDSC_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "FLNS") then
      B = get_FLNS (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FLNS")
      end if
    end if
    if (vars(i) .eq. "FLNSC") then
      B = get_FLNSC (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FLNSC")
      end if
    end if
    if (vars(i) .eq. "FLNT") then
      B = get_FLNT (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FLNT")
      end if
    end if
    if (vars(i) .eq. "FSDS") then
      B = get_FSDS (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSDS")
      end if
    end if
    if (vars(i) .eq. "FSDSC") then
      B = get_FSDSC (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSDSC")
      end if
    end if
    if (vars(i) .eq. "FSNS") then
      B = get_FSNS (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSNS")
      end if
    end if
    if (vars(i) .eq. "FSNSC") then
      B = get_FSNSC (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSNSC")
      end if
    end if
    if (vars(i) .eq. "FSNT") then
      B = get_FSNT (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"FSNT")
      end if
    end if
    if (vars(i) .eq. "ICEFRAC") then
      B = get_ICEFRAC (inptr2,outptr2) 
      if (all(B.eq.-999.)) then
        print ("ICEFRAC not present in control case input file.") 
        delete (A)
        delete (B)
        continue
      else
        B = (/B*100./)
        B@units = "%"
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"ICEFRAC")
        end if
      end if
    end if
    if (vars(i) .eq. "PRECT") then
      B = get_PRECT (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_PRECT_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "PRECST") then
      B = get_PRECST (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_PRECST_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "PS") then
      B = get_PS (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_PS_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "PSL") then
      B = get_PSL (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_PSL_VARIANCE (meansptr2,varptr2)
      end if
    end if
    if (vars(i) .eq. "SNOWH") then
      B = get_SNOWH (inptr2,outptr2) 
      if (all(B.eq.-999.)) then
        print ("SNOWH not present in control case input file.") 
        delete(A)
        delete(B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_SNOWH_VARIANCE (meansptr2,varptr2,"SNOWH")
        end if
      end if
    end if
    if (vars(i) .eq. "SNOWHICE") then
      B = get_SNOWHICE (inptr2,outptr2) 
      if (all(B.eq.-999.)) then
        print ("SNOWHICE not present in control case input file.") 
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_SNOWH_VARIANCE (meansptr2,varptr2,"SNOWHICE")
        end if
      end if
    end if
    if (vars(i) .eq. "SNOWHLND") then
      B = get_SNOWHLND (inptr2,outptr2) 
      if (all(B.eq.-999.)) then
        print ("SNOWHLND not present in control case input file.") 
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_SNOWH_VARIANCE (meansptr2,varptr2,"SNOWHLND")
        end if
      end if
    end if
    if (vars(i) .eq. "TGCLDIWP") then
      B = get_TGCLDIWP (inptr2,outptr2) 
      if (all(B.eq.-999.)) then
        print ("TGCLDIWP not present in control case input file.") 
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"TGCLDIWP")
        end if
      end if
    end if
    if (vars(i) .eq. "TGCLDLWP") then
      B = get_TGCLDLWP (inptr2,outptr2) 
      if (all(B.eq.-999.)) then
        print ("TGCLDLWP not present in control case input file.") 
        delete (A)
        delete (B)
        continue
      else
        if (sig_plot .eq. "True") then
          B_var = get_VARIANCE (meansptr2,varptr2,"TGCLDLWP")
        end if
      end if
    end if
    if (vars(i) .eq. "TS") then
      B = get_TS (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"TS")
      end if
    end if
    if (vars(i) .eq. "Z3_500") then
      B = get_Z3_500 (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_PLEVEL_VARIANCE (meansptr2,varptr2,"Z3_500",500.)
      end if
    end if
    if (vars(i) .eq. "WIND_MAG_SURF") then
      B = get_WIND_MAG_SURF (inptr2,outptr2) 
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"WIND_MAG_SURF")
      end if
    end if
    if (vars(i) .eq. "CLDTOT_CAL") then
      B = get_CLDTOT_CAL (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTOT_CAL")
      end if
    end if 
    if (vars(i) .eq. "CLDLOW_CAL") then
      B = get_CLDLOW_CAL (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDLOW_CAL")
      end if
    end if 
    if (vars(i) .eq. "CLDMED_CAL") then
      B = get_CLDMED_CAL (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDMED_CAL")
      end if
    end if 
    if (vars(i) .eq. "CLDHGH_CAL") then
      B = get_CLDHGH_CAL (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDHGH_CAL")
      end if
    end if 
    if (vars(i) .eq. "CLDTOT_CS2") then
      B = get_CLDTOT_CS2 (inptr2,outptr2)
      if (sig_plot .eq. "True") then
        B_var = get_VARIANCE (meansptr2,varptr2,"CLDTOT_CS2")
      end if
    end if 
;   end BRH additions
  end if

  if (all(B.eq.-999.)) then    
    print (vars(i)+" not present in control case input file.") 
    delete(A)
    delete(B)
    continue         ; preceed to next variable in do loop
  else
    if (sig_plot .eq. "True") then
      SIG = get_SIGNIFICANCE (A,A_var,nt1,B,B_var,nt2)
    end if
  end if

; Interpolate the fields to the same grids if needed, and compute
; the difference of the fields.

  if (nlat1 .eq. nlat2) then             ; same grids
    C = A
    C = (/A - B/)
  else                                   ; different grids
    if (nlat1 .gt. nlat2) then           ; interp a to nlat2
      tmp = linint2(lon1,lat1,A,True,lon2,lat2,0)
      C = B
      C = (/tmp - B/)
    else                                ; interp b to nlat1
      tmp = linint2(lon2,lat2,B,True,lon1,lat1,0)
      C = A
      C = (/A - tmp/)
    end if
    delete (tmp)
  end if

  if (compare .eq. "OBS") then
    delete (lat2)
    delete (lon2)
  end if
;-------------------- Open file for plots -------------------------
  if (color_type .eq. "COLOR") then
    cmap = RGBtoCmap(rgb_file)
    if (compare .eq. "OBS") then
      wksNP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+obsvars(i)+ \
             "_NP_obsc")
      wksSP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+obsvars(i)+ \
             "_SP_obsc")
    else
      wksNP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+vars(i)+"_NP_c")
      wksSP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+vars(i)+"_SP_c")
    end if
    gsn_define_colormap (wksNP,cmap)
    gsn_define_colormap (wksSP,cmap)
  else     ; Black and white
    if (compare .eq. "OBS") then
      wksNP=gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+obsvars(i)+"_NP_obs")
      wksSP=gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+obsvars(i)+"_SP_obs")
    else
      wksNP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+vars(i)+"_NP")
      wksSP = gsn_open_wks(plot_type,wkdir+"set7_"+season+"_"+vars(i)+"_SP")
    end if
  end if

;-------------------------- North Polar Plots ---------------------

  if (color_type .eq. "COLOR") then
    if (vars(i).eq."SNOWHICE" .or. vars(i).eq."SNOWHLND" .or. \
        vars(i).eq."TREFHT_LAND") then
      polar@cnRasterModeOn = True
    else
      polar@cnRasterModeOn = False
    end if
    if (vars(i).eq."ICEFRAC" .or. vars(i).eq."SNOWHICE" .or. \
        vars(i).eq."SNOWHLND") then
      if (vars(i).eq."ICEFRAC") then
        polar@mpFillDrawOrder = "PostDraw" 
        polar@lbLabelStride = 1
      else
        polar@mpFillDrawOrder = "Draw" 
        polar@lbLabelStride = 1
      end if
    else
      polar@mpFillDrawOrder = "Draw" 
      polar@lbLabelStride = 2
    end if
  end if

  polar@gsnLeftString = A@long_name
  polar@gsnRightString = A@units
  polar@gsnPolar = "NH"  
  polar@mpMinLatF = npminlat

; NP CASE 1
  if (isvar("yrs_ave1")) then
    polar@tiMainString = case1+" (yrs "+yrs_ave1+")"
  else
    polar@tiMainString = case1
  end if
  if (PALEO) then                  
    polar@mpDataBaseVersion = "Ncarg4_1"
    polar@mpDataSetName = paleocoast1
  end if

  meannp1 = wgt_areaave(A({npminlat:},:),gw1({npminlat:}),1.,0) 
  minnp1 = min(A({npminlat:},:)) 
  maxnp1 = max(A({npminlat:},:))
  meannp2 = wgt_areaave(B({npminlat:},:),gw2({npminlat:}),1.,0) 
  minnp2 = min(B({npminlat:},:))
  maxnp2 = max(B({npminlat:},:))
  if (color_type .eq. "COLOR") then
    polar@lbOrientation   = "Horizontal"
    polar@lbTitleOffsetF = -.25
    polar@cnLevels = Pcntrs(i,:)
    polar@lbTitleString = "MEAN= "+sprintf("%6.2f",meannp1)+ \
                         "  Min= "+sprintf("%6.2f",minnp1)+ \
                         "  Max= "+sprintf("%6.2f",maxnp1)
  else
    polar@cnInfoLabelParallelPosF = 0.65
    minab = min((/minnp1,minnp2/))
    maxab = min((/maxnp1,maxnp2/))
    mnmxint = nice_mnmxintvl(minab,maxab,cnlvls,False)
    polar@cnMinLevelValF = mnmxint(0)
    polar@cnMaxLevelValF = mnmxint(1)
    polar@cnLevelSpacingF = mnmxint(2)
  end if

  plotNP(0) = gsn_csm_contour_map_polar(wksNP,A,polar)
  if (color_type .eq. "MONO") then
    plotNP(0) = ZeroNegDashLineContour (plotNP(0))
  end if

; NP CASE 2
  if (isvar("yrs_ave2")) then
    polar@tiMainString = case2+" (yrs "+yrs_ave2+")"
  else
    polar@tiMainString = case2
  end if
  if (PALEO) then                   
    if (compare.eq."USER") then
      polar@mpDataSetName = paleocoast2
    else   
      delete(polar@mpDataBaseVersion)
      delete(polar@mpDataSetName)
    end if
  end if

  if (color_type .eq. "COLOR") then
    polar@lbTitleString ="MEAN= "+sprintf("%6.2f",meannp2)+ \
                         "  Min= "+sprintf("%6.2f",minnp2)+ \
                         "  Max= "+sprintf("%6.2f",maxnp2)
  else
    polar@cnInfoLabelParallelPosF = 1.10
  end if

  plotNP(1) = gsn_csm_contour_map_polar(wksNP,B,polar)
  if (color_type .eq. "MONO") then
    plotNP(1) = ZeroNegDashLineContour (plotNP(1))
  end if
  delete (polar@mpMinLatF)

;----------------------------- South Polar Plots ---------------------
  polar@gsnPolar = "SH"
  polar@mpMaxLatF = spmaxlat

  meansp1 = wgt_areaave(A({:spmaxlat},:),gw1({:spmaxlat}),1.,0)
  minsp1 = min(A({:spmaxlat},:))
  maxsp1 = max(A({:spmaxlat},:))
  meansp2 = wgt_areaave(B({:spmaxlat},:),gw2({:spmaxlat}),1.,0)
  minsp2 = min(B({:spmaxlat},:))
  maxsp2 = max(B({:spmaxlat},:))

; SP CASE 1
  if (isvar("yrs_ave1")) then
    polar@tiMainString = case1+" (yrs "+yrs_ave1+")"
  else
    polar@tiMainString = case1
  end if
  if (PALEO) then                  
    polar@mpDataBaseVersion = "Ncarg4_1"
    polar@mpDataSetName = paleocoast1
  end if
  if (color_type .eq. "COLOR") then
    if (vars(i).eq."PSL") then
      polar@cnLevels = (/Pcntrs(i,:)-18/)
    end if 
    polar@lbTitleString ="MEAN= "+sprintf("%6.2f",meansp1)+ \
                         "  Min= "+sprintf("%6.2f",minsp1)+ \
                         "  Max= "+sprintf("%6.2f",maxsp1)
  else
    polar@cnInfoLabelParallelPosF = 0.65
    minab = min((/minsp1,minsp2/))
    maxab = min((/maxsp1,maxsp2/))
    mnmxint = nice_mnmxintvl(minab,maxab,cnlvls,False)
    polar@cnMinLevelValF = mnmxint(0)
    polar@cnMaxLevelValF = mnmxint(1)
    polar@cnLevelSpacingF = mnmxint(2)
  end if

  plotSP(0) = gsn_csm_contour_map_polar(wksSP,A,polar)
  if (color_type .eq. "MONO") then
    plotSP(0) = ZeroNegDashLineContour (plotSP(0))
  end if

; SP CASE 2
  if (isvar("yrs_ave2")) then
    polar@tiMainString = case2+" (yrs "+yrs_ave2+")"
  else
    polar@tiMainString = case2
  end if
  if (PALEO) then                   
    if (compare.eq."USER") then
      polar@mpDataSetName = paleocoast2
    else   
      delete(polar@mpDataBaseVersion)
      delete(polar@mpDataSetName)
    end if
  end if

  if (color_type .eq. "COLOR") then
   polar@lbTitleString ="MEAN= "+sprintf("%6.2f",meansp2)+ \
                        "  Min= "+sprintf("%6.2f",minsp2)+ \
                        "  Max= "+sprintf("%6.2f",maxsp2)
  else
    polar@cnInfoLabelParallelPosF = 1.10
  end if

  plotSP(1) = gsn_csm_contour_map_polar(wksSP,B,polar)
  if (color_type .eq. "MONO") then
    plotSP(1) = ZeroNegDashLineContour (plotSP(1))
  else
    delete (polar@lbTitleString)
    delete (polar@lbOrientation)
    delete (polar@cnLevels)
    delete (polar@lbTitleOffsetF)
  end if
  delete (polar@mpMaxLatF)
  delete (polar@tiMainString)

  if (PALEO .and. (compare.ne."USER" .or. \
    (compare.eq."USER" .and. .not.DIFFS))) then
;   NO DIFFERENCE PLOTS MADE
    panP@txString = season
    if (time_stamp .eq. "True") then
      panP@gsnPanelBottom = 0.05
      gsn_panel(wksNP,plotNP(0:1),(/2,1/),panP)
      infoTimeStamp(wksNP, 0.011, "DIAG Version: "+version)
      gsn_panel(wksSP,plotSP(0:1),(/2,1/),panP)
      infoTimeStamp(wksSP, 0.011, "DIAG Version: "+version)
    else
      gsn_panel(wksNP,plotNP(0:1),(/2,1/),panP)
      gsn_panel(wksSP,plotSP(0:1),(/2,1/),panP)
    end if
    frame(wksNP)
    frame(wksSP)
    delete(A)
    delete(B)
  else                                     
;   MAKE DIFFERENCE PLOTS
    if (PALEO) then
      polar@mpDataBaseVersion = "Ncarg4_1"    ; use case1 coast lines
      polar@mpDataSetName = paleocoast1
    end if

;   NORTH POLE
    polar@gsnPolar = "NH"
    polar@mpMinLatF = npminlat
    polar@tiMainString = case1+" - "+case2

    mind = min(C({npminlat:},:))
    maxd = max(C({npminlat:},:))

    if (color_type .eq. "COLOR") then
      polar@cnLevels = dPcntrs(i,:)
      polar@lbLabelStride = 1
      if (sig_plot .eq. "True") then
        polar@lbOrientation = "Horizontal"
      else
        polar@lbOrientation = "Vertical"
      end if
      polar@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                           " MAX = "+sprintf("%6.2f",maxd)
      plotNP(2) = gsn_csm_contour_map_polar(wksNP,C,polar)
      delete (polar@cnLevels)
    else
      polar@cnInfoLabelParallelPosF = 0.80
      mnmxint = nice_mnmxintvl(mind,maxd,dcnlvls,False)
      polar@cnMinLevelValF = mnmxint(0)
      polar@cnMaxLevelValF = mnmxint(1)
      polar@cnLevelSpacingF = mnmxint(2)
      plotNP(2) = gsn_csm_contour_map_polar(wksNP,C,polar)
      plotNP(2) = ZeroNegDashLineContour (plotNP(2))
    end if
    delete (polar@tiMainString)

   ; NP SIGNIFICANCE PLOT
    if (sig_plot .eq. "True") then
      polar@gsnLeftString = ""
      polar@gsnRightString = ""
      polar@tiMainString = "T-test of the two means at each grid point"
      polar@cnLevels = SigLvl 
      if (color_type .eq. "COLOR") then
        polar@cnFillColors = (/13,0/)
        polar@gsnCenterString="Colored cells are significant at the "+SigLvl+" level"
        polar@lbLabelBarOn = False
        polar@cnRasterModeOn = True
        plotNP(3) = gsn_csm_contour_map_polar(wksNP,SIG,polar)
        delete (polar@cnFillColors)
        polar@cnRasterModeOn = False
        polar@lbLabelBarOn = True
      else
        polar@cnLevelSelectionMode = "ExplicitLevels"
        polar@gsnCenterString="Hatched areas are significant at the "+SigLvl+" level"
        polar@cnInfoLabelOn = False
        polar@cnLineThicknessF = 2.0
        plotNP(3) = gsn_csm_contour_map_polar(wksNP,SIG,polar)
        plotNP(3) = SigPattern (plotNP(3),SigLvl,5)
        polar@cnInfoLabelOn = True 
        polar@cnLevelSelectionMode = "ManualLevels"
        polar@cnLineThicknessF = 1.0
      end if
      delete (polar@cnLevels)
      delete (polar@tiMainString)
      delete (polar@gsnCenterString)
    end if
    delete (polar@mpMinLatF)

;   SOUTH POLE
    polar@gsnPolar = "SH"              ; south pole 
    polar@mpMaxLatF = spmaxlat
    polar@tiMainString = case1+" - "+case2
    polar@gsnLeftString = A@long_name
    polar@gsnRightString = A@units

    mind = min(C({:spmaxlat},:))
    maxd = max(C({:spmaxlat},:))
    if (color_type .eq. "COLOR") then
      polar@cnLevels = dPcntrs(i,:)
      polar@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                           " MAX = "+sprintf("%6.2f",maxd)
      plotSP(2) = gsn_csm_contour_map_polar(wksSP,C,polar)
      delete (polar@lbTitleString)
      delete (polar@lbOrientation)
      delete (polar@cnLevels)
    else
      polar@cnInfoLabelParallelPosF = 0.80
      mnmxint = nice_mnmxintvl(mind,maxd,dcnlvls,False)
      polar@cnMinLevelValF = mnmxint(0)
      polar@cnMaxLevelValF = mnmxint(1)
      polar@cnLevelSpacingF = mnmxint(2)
      plotSP(2) = gsn_csm_contour_map_polar(wksSP,C,polar)
      plotSP(2) = ZeroNegDashLineContour (plotSP(2))
    end if
    delete (polar@tiMainString)

   ; SP SIGNIFICANCE PLOT
    if (sig_plot .eq. "True") then
      polar@gsnLeftString = ""
      polar@gsnRightString = ""
      polar@tiMainString = "T-test of the two means at each grid point"
      polar@cnLevels = SigLvl 
      if (color_type .eq. "COLOR") then
        polar@cnFillColors = (/13,0/)
        polar@gsnCenterString="Colored cells are significant at the "+SigLvl+" level"
        polar@lbLabelBarOn = False
        polar@cnRasterModeOn = True
        plotSP(3) = gsn_csm_contour_map_polar(wksSP,SIG,polar)
        delete (polar@cnFillColors)
        polar@cnRasterModeOn = False
        polar@lbLabelBarOn = True
      else
        polar@cnLevelSelectionMode = "ExplicitLevels"
        polar@gsnCenterString="Hatched areas are significant at the "+SigLvl+" level"
        polar@cnInfoLabelOn = False
        plotSP(3) = gsn_csm_contour_map_polar(wksSP,SIG,polar)
        plotSP(3) = SigPattern (plotSP(3),SigLvl,5)
        polar@cnInfoLabelOn = True 
        polar@cnLevelSelectionMode = "ManualLevels"
      end if
      delete (polar@cnLevels)
      delete (polar@tiMainString)
      delete (polar@gsnCenterString)
    end if

    delete (polar@gsnLeftString)
    delete (polar@gsnRightString)
    delete (polar@mpMaxLatF)
    delete (mind)
    delete (maxd)
    delete (A)
    delete (B)
    delete (C)
    if (compare .eq. "OBS") then
      delete (gw2)
    end if

;   PANEL PLOTS 
    panP@txString = season
    if (time_stamp .eq. "True") then
      panP@gsnPanelBottom = 0.05
      gsn_panel(wksNP,plotNP,(/2,2/),panP)
      infoTimeStamp(wksNP, 0.011, "DIAG Version: "+version)
      gsn_panel(wksSP,plotSP,(/2,2/),panP)
      infoTimeStamp(wksSP, 0.011, "DIAG Version: "+version)
    else
      gsn_panel(wksNP,plotNP,(/2,2/),panP)
      gsn_panel(wksSP,plotSP,(/2,2/),panP)
    end if
    frame(wksNP)
    frame(wksSP)
  end if

end do     

end
