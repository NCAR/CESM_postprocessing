;;; AMWG Diagnostics NCL script
;;; plot_taylor.ncl
; Taylor Diagram
; Jan 2008 - Adapted from AMP code for diagnostics package.
; Dec 1010 - Change to use dim_???_n functions where appropriate
;********************************************************
;
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;                Core Code 
;          Taylor_Metrics_Processor for 
;            AMWG Mean Diagnsotics
;                 [TMP]
;               Version 0.69
;               29 Sept 2006
;----------------------------------------------
; load assorted utility and graphic functions
; needed by following code
; ---------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;                  Main [driver] Script 
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  setfileoption("nc", "SuppressClose", False)


  wkdir      = getenv("WKDIR")
  compare    = getenv("COMPARE")
  case_names = getenv("CASENAMES")
  obs_data   = getenv("OBS_DATA")
  cam_data   = getenv("CAM35_DATA")
  ncdf_mode  = getenv("NCDF_MODE")
  case_names = getenv("CASENAMES")
  infile1    = getenv("TEST_INPUT")     ; case1 input filename
  outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
  infile2    = getenv("CNTL_INPUT")     ; case2 input filename
  cam_base   = getenv("TAYLOR_BASECASE")
  if (compare .ne. "OBS") then
    outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
  end if

;----------------------------------------------
; Make sure NCL version is appropriate
;----------------------------------------------


  nclv   = get_ncl_version()  ; string
  nclv_c = stringtochar(nclv)
  nclv_i = stringtointeger( chartostring(nclv_c(0)) )
 if (nclv_i.lt.5) then
   print("Taylor Metrics Processor requires version 5 or newer")
  print("Current version: "+nclv)
  print("On CGD/SCD systems, try using  'ncl.new' ")
  print("To download the latest ampNCL:")
  print("   http://www.ncl.ucar.edu/Download/index.shtml")
  exit
end if 
  
  month = (/"01","02","03","04","05","06","07","08","09","10","11","12"/)

; Baseline model data.
  
  outptr_base = new(12,file)
  
  infile_base = cam_data+"/"+cam_base

  inflist_base   = systemfunc("ls -1 "+infile_base+"_{01,02,03,04,05,06,07,08,09,10,11,12}_climo.nc")
  inptr_base = addfile(inflist_base(0), "r")           ; note the "s" of addfiless
  
  if (case_names .eq. "True") then
    case_base = getenv("CASE_BASE")
  else
    case_base = inptr_base@case
  end if
  if (isatt(inptr_base,"yrs_averaged")) then
    yrs_ave_base = inptr_base@yrs_averaged
  end if

; CASE 1 is model (test)

  
  inflist1   = systemfunc("ls -1 "+infile1+"_{01,02,03,04,05,06,07,08,09,10,11,12}_climo.nc")
  inptr1 = addfile(inflist1(0), "r")           ; note the "s" of addfiless
    
  if (case_names .eq. "True") then
    case1 = getenv("CASE1")
  else
    case1 = inptr1@case
  end if
  if (isatt(inptr1,"yrs_averaged")) then
    yrs_ave1 = inptr1@yrs_averaged
  end if


; COMPARE to another model.

  if (compare .ne. "OBS") then
    inflist2  = systemfunc("ls -1 "+infile2+"_{01,02,03,04,05,06,07,08,09,10,11,12}_climo.nc")
    inptr2    = addfile(inflist2(0), "r")           ; note the "s" of addfiless
   
    if (case_names .eq. "True") then
      case2 = getenv("CASE2")
    else
      case2 = inptr2@case
    end if
    if (isatt(inptr2,"yrs_averaged")) then
      yrs_ave2 = inptr2@yrs_averaged
    end if
  end if


;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;  Begin user specified REQUIRED parameters
;        SEASONS, CASE_TAYLOR, VAR_TAYLOR
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&


   SEASONS    = (/"ANN","DJF","MAM","JJA","SON"/)
   PLOT_NAME  = "set14"
   
   if (compare.eq."OBS") then
     PLOT_SUFFIX = "_obsc"

    CASE_DIR   = (/cam_data+"/"+case_base,infile1/) ; case directories

    CASE_FILE  = (/case_base,case1/) ; case names

    CASE_TAYLOR = (/  \
     \;                            taylor_id      ,marker  color
     \;------------------------------------------------------------------------------------
     (/CASE_DIR(0), CASE_FILE(0),    case_base, "16" , "black" /), \
     (/CASE_DIR(1), CASE_FILE(1),    case1,     "16" , "darkgreen"/), \
      \;------------------------------------------------------------------------------------
     (/"0","0","0","0","0"/) /)    ; endd CASE_TAYLOR


     else

       PLOT_SUFFIX = "_c"
  
       CASE_DIR   = (/cam_data+"/"+case_base,infile1,infile2/) ; case directories

       CASE_FILE  = (/case_base,case1,case2/) ; case names

       CASE_TAYLOR = (/  \
     \;                            taylor_id      ,marker  color
     \;------------------------------------------------------------------------------------
     (/CASE_DIR(0), CASE_FILE(0), case_base,     "16" , "black" /), \
     (/CASE_DIR(1), CASE_FILE(1), case1,         "16" , "darkgreen"/), \
     (/CASE_DIR(2), CASE_FILE(2), case2,         "16" , "blue"/), \
      \;------------------------------------------------------------------------------------
     (/"0","0","0","0","0"/) /)    ; endd CASE_TAYLOR

   end if


    pUnit    = flt2string( 1./(1000*86400) )  ; a034

     ;  Model   ,   Reference   ,unit ,latS,latN,lonL,lonR, ls(1=land, 0=ocn), lev
  VAR_TAYLOR  = (/  \       ; start VAR_TAYLOR   \
    \;                                                          (1=lnd,0=ocn)
    \;  Case    , Reference    ,Unit ,   latS , latN, lonL, lonR,  ls ,  lev, label
    \;------------------------------------------------------------------------------------
    (/"PSL"    , "ERAI"    ,    "100.",   "-90", "90",  "0","360",   "-1",  "0"   , "Sea Level Pressure (ERAI)" /),\
    (/"SWCF"   , "CERES-EBAF",  "1.0",   "-90", "90",  "0","360",   "-1",  "0"    , "SW Cloud Forcing (CERES-EBAF)" /),\
    (/"LWCF"   , "CERES-EBAF",  "1.0",   "-90", "90",  "0","360",   "-1",  "0"    , "LW Cloud Forcing (CERES-EBAF)" /),\
    (/"PRECT"  , "GPCP",        pUnit,   "-30", "30",  "0","360",    "1",  "0"    , "Land Rainfall (30N-30S, GPCP)" /),\
    (/"PRECT"  , "GPCP",        pUnit,   "-30", "30",  "0","360",    "0",  "0"    , "Ocean Rainfall (30N-30S, GPCP)" /),\
    (/"TREFHT" , "WILLMOTT",    "1.0",   "-90", "90",  "0","360",    "1",  "0"    , "Land 2-m Temperature (Willmott)" /),\
    (/"STRESS" , "ERS",        "-1.0",    "-5",  "5","135","270",    "0",  "0"    , "Pacific Surface Stress (5N-5S,ERS)" /),\
    (/"U"      , "ERAI",       "1.0",   "-90", "90",  "0","360",   "-1","300"    , "Zonal Wind (300mb, ERAI)" /),\
    (/"RELHUM" , "ERAI",       "1.0",   "-90", "90",  "0","360",   "-1",  "0"    , "Relative Humidity (ERAI)" /),\
    (/"T"      , "ERAI",       "1.0",   "-90", "90",  "0","360",   "-1",  "0"    , "Temperature (ERAI)" /),\
    \;------------------------------------------------------------------------------------
    (/"0","0","0","0","0","0","0","0","0","0"/) /)          ; end VAR_TAYLOR

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;  Begin user specified OPTIONAL  parameters
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

  PLOT_TYPE  = "png"                           ; eps, ps, gif, pdf, ncgm [,png]
 ;PLOT_NAME  = "taylor_CMS_069"
 ;USER_REF_DIR        = "/blah/blah/"          ; User Ref dir
 ;USER_REF_FILE       = (/"BLAH_MONTHS_climo.nc"        \
 ;                       ,"FOO_MONTHS_climo.nc"         /)

  REF_to_CASE         = False   ; default True [Reference/User grid to model]
  REF_USER_LOAD_ORDER = True   ; load REF files 1st
                               ; only True now
  METRICS_NETCDF      = False
  METRICS_FILENAME    = "taylor_CMS_069"

  CC_TIME             = True   ; "ANN" must also be specified in SEASONS:x
  CC_SPACE_TIME       = True   ; "ANN" must also be specified in SEASONS:x


;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;        End user specified parameters
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&









;----------------------------------------------
; Check for *required* parameters
;----------------------------------------------

    if (.not.isvar("CASE_TAYLOR") .and. .not.isvar("VAR_TAYLOR")) then
        print("REQUIRED VARIABLEs ===> CASE_TAYLOR and VAR_TAYLOR <=== NOT PRESENT")
        exit
    end if
    if (.not.isvar("CASE_TAYLOR")) then
        print("REQUIRED VARIABLE ===> CASE_TAYLOR <=== NOT PRESENT")
        exit
    end if
    if (.not.isvar("VAR_TAYLOR")) then
        print("REQUIRED VARIABLE ===> VAR_TAYLOR <=== NOT PRESENT")
        exit
    end if

;----------------------------------------------
; Default variables set to defaults if not specified 
; in user spexification file.
;----------------------------------------------

    if (.not.isvar("REF_to_CASE")) then
        REF_to_CASE = True
    end if
    if (.not.isvar("REF_USER_LOAD_ORDER")) then
        REF_USER_LOAD_ORDER = True
    end if
    if (.not.isvar("WGT_MONTH")) then
        WGT_MONTH = True                
    end if
    if (.not.isvar("PLOT_TYPE")) then
        PLOT_TYPE = "png"
    end if
    if (.not.isvar("PLOT_NAME")) then
        PLOT_NAME = "taylor_"
    end if
    if (.not.isvar("METRICS_PRINT")) then
        METRICS_PRINT = False
    end if
    if (.not.isvar("METRICS_NETCDF")) then 
        METRICS_NETCDF= False             
    else                                 
        if (.not.isvar("METRICS_FILENAME")) then 
            metrics_fname = "TAYLOR_METRICS."+TEST+".nc" ; default
        else
            metrics_fname = METRICS_FILENAME
        end if                             
    end if 

    CC_SPACE = True     ; always         

    if (any(SEASONS.eq."ANN")) then
        if (.not.isvar("CC_TIME")) then
             CC_TIME = True         
        end if
        if (.not.isvar("CC_SPACE_TIME")) then
             CC_SPACE_TIME = True         
        end if
    end if
        
    if (.not.isvar("DEBUG")) then
        DEBUG = False                  ; not used
    end if
    if (.not.isvar("DEBUG_PLOT")) then 
        DEBUG_PLOT = False             ; not used
    end if
    
begin
;----------------------------------------------
; Set the directories that have the Reference data sets
; Default directories used iff none specified
; CGD and SCD have different versions of convert
;----------------------------------------------
  load "$DIAG_CODE/taylor_utils.ncl" 
  load "$DIAG_CODE/taylor_diagram_cam.ncl"
  load "$DIAG_CODE/taylor_metrics_table.ncl" 


    OS = systemfunc("uname")
    if (.not.isvar("REF_DIR")) then
        if (OS.eq."Linux" .or. OS.eq."SunOS") then
            REF_DIR = obs_data+"/"   
        end if
        if (OS.eq."IRIX64" .or. OS.eq."AIX") then
            REF_DIR = obs_data+"/"   
        end if
    end if
    if (.not.isvar("REF_FILE")) then ; RBN just list the first (Jan) file of 12.
        REF_FILE= systemfunc("cd "+REF_DIR+"; ls *01_climo.nc")
    end if

;----------------------------------------------
; get dimension sizes
; The -1 for nVar and nCase eliminates dummy table entry
;----------------------------------------------

    dimCase     = dimsizes( CASE_TAYLOR )   
    dimVar      = dimsizes( VAR_TAYLOR  ) 
    nCase       = dimCase(0) - 1
    nVar        = dimVar(0)  - 1
    nSeason     = dimsizes( SEASONS )

    ;print("========================================")
    ;print("nSeason="+nSeason+"  nVar="+nVar+"  nCase="+nCase)
    ;print("========================================")

;----------------------------------------------
; Allocate the arrays used to hold results for plots/netCDF
; The reason for the ",1," in the _T and _ST variables
; is to match the number of arguments required by the 
; taylor_metrics_table procedure.
;----------------------------------------------

    ratio_metric_S  = new ((/nCase,nSeason,nVar/), "double", 1d20 )
    bias_metric_S   = new ((/nCase,nSeason,nVar/), typeof(ratio_metric_S), 1d20)
    cc_metric_S     = new ((/nCase,nSeason,nVar/), typeof(ratio_metric_S), 1d20) 
    mean_S          = new ((/2,nCase,nSeason,nVar/), typeof(ratio_metric_S), 1d20) 

                                         ; only for ANN 
    cc_metric_T     = new ((/nCase,1,nVar/), typeof(ratio_metric_S), 1d20) 
    ratio_metric_T  = new ((/nCase,1,nVar/), typeof(ratio_metric_S), 1d20) 
    bias_metric_T   = new ((/nCase,1,nVar/), typeof(ratio_metric_S), 1d20) 
    mean_T          = new ((/2,nCase,1,nVar/), typeof(ratio_metric_S), 1d20) 
                                         ; only for ANN 
    ratio_metric_ST = new ((/nCase,1,nVar/), typeof(ratio_metric_S), 1d20) 
    cc_metric_ST    = new ((/nCase,1,nVar/), typeof(ratio_metric_S), 1d20) 
    bias_metric_ST  = new ((/nCase,1,nVar/), typeof(ratio_metric_S), 1d20) 
    mean_ST         = new ((/2,nCase,1,nVar/), typeof(ratio_metric_S), 1d20) 

    ratio_metric_S@long_name  = "ratio of wgted variances"
    ratio_metric_T@long_name  = "ratio of wgted variances"
    ratio_metric_ST@long_name = "ratio of wgted variances calculated over space and time"

    cc_metric_S@long_name     = "spatial correlation coef"
    cc_metric_T@long_name     = "temporal correlation coef"
    cc_metric_ST@long_name    = "correlation coef using space and time"

    bias_metric_S@long_name   = "bias: wgted spatial means:  ((case-ref)/abs(ref))*100"
    bias_metric_T@long_name   = "bias: wgted spatial means:  ((case-ref)/abs(ref))*100"
    bias_metric_ST@long_name  = "bias: wgted space and time: ((case-ref)/abs(ref))*100"
    bias_metric_S@units       = "%"
    bias_metric_T@units       = "%"
    bias_metric_ST@units      = "%"

    units_table    = new ( nVar, "string", "No_FillValue")
    
    wcc            = 0.d0
    wcc@_FillValue = 1d20      

    plt = new ( 2, "graphic")
;----------------------------------------------
; Break out info within VAR_TAYLOR
;----------------------------------------------

    caseVarCompare  = VAR_TAYLOR(0:nVar-1,0)
    refDsetCompare   = VAR_TAYLOR(0:nVar-1,1)
    unitScaleFactor = stringtofloat  ( VAR_TAYLOR(0:nVar-1,2) )

    latS            = stringtofloat  ( VAR_TAYLOR(0:nVar-1,3) )
    latN            = stringtofloat  ( VAR_TAYLOR(0:nVar-1,4) )
    lonL            = stringtofloat  ( VAR_TAYLOR(0:nVar-1,5) ) ; Left
    lonR            = stringtofloat  ( VAR_TAYLOR(0:nVar-1,6) ) ; Right
    lsFlag          = stringtointeger( VAR_TAYLOR(0:nVar-1,7) ) 

    levP            = parsePlevel( VAR_TAYLOR(0:nVar-1,8) )

    VAR_ID_PLOT     = VAR_TAYLOR(0:nVar-1,9)                    ; default
    do nv=0,nVar-1                                              ; automatic labeling
       VAR_ID_PLOT(nv) = create_VAR_ID_PLOT (caseVarCompare(nv), levP(nv,:)        \
                                            ,latS(nv), latN(nv), lonL(nv), lonR(nv)\
                                            ,lsFlag(nv), VAR_TAYLOR(nv,9) )
    end do

;----------------------------------------------
; Break out info within CASE_TAYLOR
;----------------------------------------------

   ;CASE_DIR         = CASE_TAYLOR(0:nCase-1,0)
   ;CASE_FILE        = CASE_TAYLOR(0:nCase-1,1)
    CASE_ID_PLOT     = CASE_TAYLOR(0:nCase-1,2)
    CASE_ID_MARKERS  = stringtointeger( CASE_TAYLOR(0:nCase-1,3) )
    CASE_ID_COLORS   = CASE_TAYLOR(0:nCase-1,4) 

;----------------------------------------------
; Merge specified REF and/or USER files: 
; ->    create master file reference list
;----------------------------------------------
    if (isvar("REF_DIR") .and. isvar("REF_FILE") ) then
        REF_LIST  = REF_DIR + REF_FILE
        nREF      = dimsizes(REF_LIST) 
    else
        nREF      = 0
    end if

    if (isvar("USER_REF_DIR") .and. isvar("USER_REF_FILE") ) then
        USER_LIST = USER_REF_DIR + USER_REF_FILE
        nUSER     = dimsizes(USER_LIST) 
    else
        nUSER     = 0
    end if

    nOBS = nREF + nUSER
    if (nOBS.eq.0) then
        print("=============================")
        print("FATAL error: no REFERENCE or USER files specified")
        print("=============================")
        exit
    end if

    OBS_FILE  = new ( nOBS , "string")
    if (nREF.gt.0 .and. nUSER.gt.0) then
        OBS_FILE(0:nREF-1) = REF_LIST
        OBS_FILE(nREF:)    = USER_LIST
      ;;OBS_FILE = array_append_record(REF_LIST,USER_LIST,0) ; a034
    end if
    if (nREF.gt.0 .and. nUSER.eq.0) then
        OBS_FILE = REF_LIST
    end if
    if (nREF.eq.0 .and. nUSER.gt.0) then
        OBS_FILE = USER_LIST
    end if



;----------------------------------------------
; Create a table that contains OBS file variable names and a 
; 2nd table that contains an index to appropriate file
;----------------------------------------------
;    refVarNames  = getfilevarnames( addfile(OBS_FILE(0), "r") )
;    nrefVarNames = dimsizes( refVarNames )
;    refVarInd    = new( nrefVarNames, "integer") 
;    refVarInd    = 0

;    do n=1,nOBS-1
;       xNames = getfilevarnames( addfile(OBS_FILE(n), "r") )
;       na     = dimsizes( refVarNames )
;       nb     = dimsizes( xNames )
;       zNames = new ( na+nb , "string" ) 
;       zNames(0:na-1) = refVarNames
;       zNames(na:   ) = xNames
;       delete(xNames)

;       zInd           = new ( na+nb , "integer" ) 
;       zInd(0:na-1)   = refVarInd
;       zInd(na:   )   = n

;       delete(refVarNames)
;       delete(refVarInd)
;     
;       refVarNames = zNames
;       refVarInd   = zInd   

;       delete( zNames )
;       delete( zInd   )
;    end do
    
;----------------------------------------------
; Generate one spatial Taylor diagram per season
;----------------------------------------------

  do ns=0,nSeason-1                     ; loop over seasons
    
    do nc=0,nCase-1                    ; loop over alll the test cases  
      if (nc.eq.0) then
        inflist = inflist_base
      end if
      if (nc.eq.1) then
        inflist = inflist1
      end if
      if (nc.eq.2) then
        inflist = inflist2
      end if
       
      fc = addfiles(inflist, "r") ; 
      fc0 = addfile(inflist(0),"r")

        print("################################################################")
        print("ns="+ns+"  "+SEASONS(ns)+"  nc="+nc+"  "+ CASE_FILE(nc))
        print("################################################################")

      do nv=0,nVar-1
        
         ;print("-------------")
         print("nv="+nv+"  "+ caseVarCompare(nv)+"  "+refDsetCompare(nv))

;**********************************************************
; Read the 12 monthly climatological values 
; The reference files need some special handling.
; Return variables are classified with "scalar" or "vector" attributes
;**********************************************************

         cdata = getData( fc, inflist,caseVarCompare(nv), False )  ; case 
     
         if (.not.cdata@flag) then
             delete(cdata)
             continue                 ; go to next variable
         end if
                                           ; is desired ref variable present         
         refVarNames  = getfilevarnames( addfile(REF_DIR+"/"+refDsetCompare(nv)+"_01_climo.nc", "r") )
         flist_obs =  systemfunc("ls -1 "+REF_DIR+"/"+refDsetCompare(nv)+"_{01,02,03,04,05,06,07,08,09,10,11,12}_climo.nc")
         fr = addfiles(flist_obs, "r") 
         fr0 = addfile(flist_obs(0), "r")

         rdata = getData( fr, flist_obs,caseVarCompare(nv), False ) ; reference
                                ; guess not  :-( specially names variable.

         if (.not.isvar("rdata")) then
           print("------------------------------------------")
           print("-->TAYLOR: getData:  "+refDsetCompare(nv)+" "+caseVarCompare(nv)+" not found   <--")
           print("-->TAYLOR: getData:   ?Incorrect spelling?   <--")
           print("-->TAYLOR: getData: ?Not a special Variable? <--")
           print("------------------------------------------")
           delete(cdata)
           continue    ; go to next variable
         end if
  
         delete(refVarNames)
                                           ; data variable check
         ier = chkData(cdata, rdata, caseVarCompare(nv),0) 
         if (ier.ne.0) then
             delete(cdata)
             delete(rdata)
             continue                      ; go to next variable
         end if
  
;********************************************************** 
; procedure to rename dimension names
; **not necessary: done for consistency/convenience**
; scalar: (time[,lev],lat,lon)  vector: (xy,time[,lev],lat,lon)  
;********************************************************** 

         renameDimNames ( cdata )
         renameDimNames ( rdata )

;**********************************************************
; Iff specified: change Units of ref variable [rdata] to 
;               that of the case variable [cdata]
;**********************************************************

         if (.not.(unitScaleFactor(nv).eq.1)) then
             rdata = rdata*unitScaleFactor(nv)   ; change units
             rdata@units = cdata@units           ; update attribute   
         end if

         units_table(nv) = cdata@units           ; for netCDF only

;**********************************************************
; Miscellaneous: consistency and check and clean up
;**********************************************************

         if (.not.(rdata@class.eq.cdata@class)) then
             print("variable class mismatch: refClass="+rdata@class+" " \
                                         +" caseClass="+cdata@class    )
             exit
         end if
         if (.not.(rdata@rank.eq.cdata@rank)) then
             print("variable rank mismatch: refRank="+rdata@rank+" " \
                                         +" caseRank="+cdata@rank    )
             exit
         end if

;**********************************************************
; Iff specified: extract single Pressure level 
;    or
; Iff multilevel: Interpolate Case/Model to the constant 
;                pressure levels associated with rdata. 
;                Compute weighted vertical mean.
;                Result is variable with *no* vertical dimension.
;**********************************************************

         dimNames = getvardims( rdata )
         if (any(dimNames.eq."lev").or.any(dimNames.eq."lev2")) then   ; ?(lev,lat,lon) or (xy,lev,lat,lon)?
             if (levP(nv,1).gt.0 .and. levP(nv,0).eq.levP(nv,1)) then
                                    ; extract SINGLE LEVEL [rank reduction]
                 rdata_P = extractPresLvl(rdata, levP, nv )
                 cdata_P = extractPresLvl(cdata, levP, nv )
             else                   ; extract specified levels   
                                    ; perform weighted vertical avg
                  rdata_P = getPresAvg (rdata, fr, flist_obs, SEASONS(ns), levP(nv,:)) 
                  cdata_P = getPresAvg (cdata, fc, inflist, SEASONS(ns), levP(nv,:))                  
             end if
 
             delete(rdata)
             delete(cdata)
             rdata = rdata_P          ; keep same names [convenience]
             cdata = cdata_P 
             delete(rdata_P)
             delete(cdata_P)
         end if
         delete(dimNames)

;**********************************************************
; HORIZONTAL [SPATIAL] INTERPOLATION
; Default: REF_to_CASE=True
;          Interpolate reference to case/model resolution [RN] 
; Note:    linint2 does not extrapolate
;**********************************************************

         if (REF_to_CASE) then
             rdatax = linint2_Wrap(rdata&lon, rdata&lat, rdata, True \
                                  ,cdata&lon, cdata&lat, 0)
             delete(rdata)
             rdata   = rdatax     ; keep same name [convenience]
             delete(rdatax)
         else
             cdatax = linint2_Wrap(cdata&lon, cdata&lat, cdata, True \
                                  ,rdata&lon, rdata&lat, 0)
             delete(cdata)
             cdata  = cdatax     ; keep same name [convenience]
             delete(cdatax)
         end if

;**********************************************************
; At this point, rdata and cdata are on the SAME GRID.
; Ensure that both have consistent spatial _FillValue 
; patterns at each time
;**********************************************************

         nMsg_r = num(ismissing(rdata))  ; count of msg values
         nMsg_c = num(ismissing(cdata))

         if ((nMsg_r+nMsg_c).gt.0) then
             cdata  = mask (cdata, ismissing(rdata), False)
             rdata  = mask (rdata, ismissing(cdata), False)
         end if

;**********************************************************
; If SEASONS(ns)="ANN" impose a requirement:
;    At each grid point all 12 values must be present
;**********************************************************
  
         if (SEASONS(ns).eq."ANN") then
             require12(rdata, cdata)
         end if

;**********************************************************
; get lat weights from case/model file: one dimensional array
;**********************************************************

         if (REF_to_CASE) then
             wt_1d  = getWeights( fc0 , 0)   ; gaussian(lat) 
         else
             wt_1d  = getWeights( fr0 , 0)   ; cos(lat) norm=>2
         end if

;**********************************************************
; create a global weight array that conforms to appropriate shape
; perform a 'space-time' mask with either rdata or cdata 
;**********************************************************
 
         if (REF_to_CASE) then
             if (cdata@class.eq."scalar") then
                 wt   = conform(cdata, wt_1d , 1)  ; (time,lat,lon)        
                 copy_VarCoords(cdata, wt)
                 wt@class = "scalar"
                 wt@rank  = 3
             else
                 wt   = conform(cdata, wt_1d , 2)  ; (xy,time,lat,lon) 
                 copy_VarCoords(cdata, wt)
                 wt@class = "vector"
                 wt@rank  = 4
             end if
             wt@flag  = True
         else
             if (rdata@class.eq."scalar") then
                 wt   = conform(rdata, wt_1d , 1)  ; (time,lat,lon)       
                 copy_VarCoords(rdata, wt)
                 wt@class = "scalar"
                 wt@rank  = 3
             else
                 wt   = conform(rdata, wt_1d , 2)  ; (xy,time,lat,lon)  
                 copy_VarCoords(rdata, wt)
                 wt@class = "vector"
                 wt@rank  = 4
             end if
             wt@flag  = True
         end if
         wt@long_name = "grid pt weights"

         wt    = mask (wt, ismissing(cdata), False)  ; space-time mask

;**********************************************************
; Iff requested, create a global land/ocean mask 
; applicable to case/model grid. Then apply the mask.
; This looks for the variable "LANDFRAC" and 
; [possibly] renames dimensions
;
; RN [2 Aug 2006] said to use 0.5 
;**********************************************************

         if (lsFlag(nv).ne.-1) then

             lfrac = getLANDFRAC (fc,inflist)   ; 12 months (time,lat,lon)
             if (.not.REF_to_CASE) then
                 lfracr = linint2_Wrap(lfrac&lon, lfrac&lat, lfrac, True, rdata&lon, rdata&lat, 0)
                 delete(lfrac)
                 lfrac  = lfracr
                 delete(lfracr)
             end if

             if (.not.lfrac@flag) then
                 delete(lfrac)
                 continue         ; not found: continue to next iteration
             end if
 
             if (lsFlag(nv).eq.1) then  ; land only
                 lfrac  = mask (lfrac, lfrac.gt.0.5, True)
             end if
             if (lsFlag(nv).eq.0) then  ; ocean only
                 lfrac  = mask (lfrac, lfrac.gt.0.5, False)
             end if




             if (rdata@class.eq."scalar") then             



                 rdata = mask(rdata, ismissing(lfrac), False)
                 cdata = mask(cdata, ismissing(lfrac), False)
                 wt    = mask(wt   , ismissing(lfrac), False)
             else
                 do n=0,1               ; loop over each vevtor component
                    rdata(n,:,:,:) = mask(rdata(n,:,:,:), ismissing(lfrac), False)
                    cdata(n,:,:,:) = mask(cdata(n,:,:,:), ismissing(lfrac), False)
                    wt   (n,:,:,:) = mask(   wt(n,:,:,:), ismissing(lfrac), False)
                 end do
             end if

             delete(lfrac) 
         end if

;**********************************************************
; Iff necessary: flip the longitudes 
;               input assumed to be 0-360 'by rule'
;**********************************************************

        if (lonL(nv).lt.0 .or. lonL(nv).gt.lonR(nv)) then
            cdata = lonFlip( cdata )
            rdata = lonFlip( rdata )
            wt    = lonFlip( wt    )
        end if

;**********************************************************
; Iff specified: extract Region subset using input specifications
;**********************************************************

        if (latS(nv).ne.-90  .or. latN(nv).ne. 90   .or. \ 
            lonL(nv).ne.0    .or. lonR(nv).ne.360) then 

            if (cdata@class.eq."scalar") then
                cdata_R = cdata(:,{latS(nv):latN(nv)},{lonL(nv):lonR(nv)})
                rdata_R = rdata(:,{latS(nv):latN(nv)},{lonL(nv):lonR(nv)})
                wt_R    = wt   (:,{latS(nv):latN(nv)},{lonL(nv):lonR(nv)})
            else
                cdata_R = cdata(:,:,{latS(nv):latN(nv)},{lonL(nv):lonR(nv)})
                rdata_R = rdata(:,:,{latS(nv):latN(nv)},{lonL(nv):lonR(nv)})
                wt_R    = wt   (:,:,{latS(nv):latN(nv)},{lonL(nv):lonR(nv)})
            end if
            wt_1d_R     = wt_1d({latS(nv):latN(nv)})

            delete(rdata)
            delete(cdata)
            delete(wt)
            delete(wt_1d)

            rdata = rdata_R    ; keep same name [convenience]
            cdata = cdata_R    ; (time,lat,lon)
            wt    = wt_R       ; (time,lat,lon)
            wt_1d = wt_1d_R 

            delete(rdata_R)
            delete(cdata_R)
            delete(wt_R)
            delete(wt_1d_R)
        end if


;**********************************************************
; Extract the desired season
; Input variables could be scalar or vector class
; Returned rank will be one less because season extracted.
; This results in a degenerate dimension which is eliminated
; Summary: time dimension is eliminated
;          scalar: (lat,lon)      , vector (xy,lat,lon)
;**********************************************************
; The _S means "[S]pace" not Season [no time dimension]
;**********************************************************

        vref_S   = getSeason (rdata, SEASONS(ns), 0)  
        vcase_S  = getSeason (cdata, SEASONS(ns), 0)
        wgt_S    = getSeason (wt   , SEASONS(ns), 0)
 
        vClass   = vcase_S@class
        vRank    = vcase_S@rank 

 ;**********************************************************
 ; computations: scalar/vector
 ;**********************************************************
                                       
          if (vClass.eq."scalar") then    ; =====> SCALAR <===== 
                                          ; [S]PACE
              sumwgt_S      = sum(wgt_S)  
                                          ; temporary variables
              sumwr         = sum(wgt_S*vref_S) ; (lat,lon)*(lat,lon)
              sumwc         = sum(wgt_S*vcase_S)

                                          ; wgted areal (spatial) means
              wmean_ref_S   = sumwr/sumwgt_S
              wmean_case_S  = sumwc/sumwgt_S
              bias_S        = wmean_case_S - wmean_ref_S
              if (wmean_ref_S.ne.0) then
                  bias_S    = abs(bias_S/wmean_ref_S)*100  ; bias [%]
              else
                  bias_S    = bias_metric_S@_FillValue
              end if

                                          ; wgted areal variance
              wvar_ref_S    = sum(wgt_S*(vref_S -wmean_ref_S )^2)/sumwgt_S  
              wvar_case_S   = sum(wgt_S*(vcase_S-wmean_case_S)^2)/sumwgt_S  
              wvar_ratio_S  = (wvar_case_S/wvar_ref_S)^0.5 

                                          ; variance (wgt_numerator/wgt_denominator)
              wcc_numer_S   = (sum(wgt_S*vref_S*vcase_S) - sumwr*sumwc/sumwgt_S )
              wcc_denom_S   = ((sum(wgt_S*(vref_S^2 )) - sumwr^2/sumwgt_S)*\
                               (sum(wgt_S*(vcase_S^2)) - sumwc^2/sumwgt_S) )        
              if (wcc_denom_S.gt.0.) then 
                  wcc_S = wcc_numer_S/sqrt(wcc_denom_S) ; wgted spatial correlation coef
              else
                  wcc_S = cc_metric_S@_FillValue
 	      end if
                                          ; arrays used for plot/netCDF
              cc_metric_S(nc,ns,nv)     = wcc_S
              ratio_metric_S(nc,ns,nv)  = wvar_ratio_S 
              bias_metric_S(nc,ns,nv)   = bias_S  

              mean_S(0,nc,ns,nv)        = wmean_ref_S  
              mean_S(1,nc,ns,nv)        = wmean_case_S  

              if ((CC_TIME .or. CC_SPACE_TIME) .and. SEASONS(ns).eq."ANN") then 
                                          ; SCALAR [S]pace-[T]ime
                                          ; temporary variables
                                          ; 3D (12,lat,lon) stuff
                  sumw_ST       = sum(wt)      ; wt(12,lat,lon) 
                  sumwr_ST      = sum(wt*rdata); (12,lat,lon)*(12,lat,lon)
                  sumwc_ST      = sum(wt*cdata)

                                          ; weighted ST mean 
                  wmean_ref_ST  = sumwr_ST/sumw_ST
                  wmean_case_ST = sumwc_ST/sumw_ST   
                  bias_ST       = wmean_case_ST - wmean_ref_ST
                  if (wmean_ref_ST.ne.0) then
                      bias_ST   = abs(bias_ST/wmean_ref_ST)*100   ; bias [%]  
                  else
                      bias_ST   = bias_metric_S@_FillValue
                  end if
                                          ; wgted ratio space-time var [scalar]
                                          ; [(time,lat,lon) - mean_ST]^2
                  wvar_ref_ST   = sum(wt*(rdata-wmean_ref_ST )^2)/sumw_ST  
                  wvar_case_ST  = sum(wt*(cdata-wmean_case_ST)^2)/sumw_ST  
                  wvar_ratio_ST = (wvar_case_ST/wvar_ref_ST)^0.5 

                                          ; wgted space-time cc [scalar]
                  wcc_numer_ST  = (sum(wt*rdata*cdata) - sumwr_ST*sumwc_ST/sumw_ST )
                  wcc_denom_ST  = ((sum(wt*(rdata^2))  - sumwr_ST^2/sumw_ST)*\
                                   (sum(wt*(cdata^2))  - sumwc_ST^2/sumw_ST))        
                  if (wcc_denom_ST.gt.0.) then 
                      wcc_ST = wcc_numer_ST/sqrt(wcc_denom_ST) 
                  else
                      wcc_ST = cc_metric_ST@_FillValue
 	          end if
                                          ; [T]emporal cor coef (local)
;; not yet avail  cc_T          = escorc_n(cdata, rdata, 0 )  ; (lat,lon)  
                  cc_T          = escorc(cdata(lat|:,lon|:,time|:) \  ; local     
                                        ,rdata(lat|:,lon|:,time|:) )  ; (lat,lon)  
                  copy_VarCoords(cdata(0,:,:), cc_T)
                  cc_T@long_name= "spatial avg of temporal lin cor: "+VAR_ID_PLOT(nv) 
                                          ; wgt spatial avg of cc_T
                  wcc_T         = sum(wgt_S*cc_T)/sumwgt_S            

                                          ; temporal mean at each grid point
                  vref_mean_T   = dim_avg_n(rdata, 0 )  ; local
                  vcase_mean_T  = dim_avg_n(cdata, 0 )  ; (lat,lon) 
                ;;vref_mean_T   = dim_avg(rdata(lat|:,lon|:,time|:) )  ; local
                ;;vcase_mean_T  = dim_avg(cdata(lat|:,lon|:,time|:) )  ; (lat,lon) 

                                          ; wgt spatial avg of _T grid point means 
                  wmean_ref_T   = sum(wgt_S*vref_mean_T)/sumwgt_S   
                  wmean_case_T  = sum(wgt_S*vcase_mean_T)/sumwgt_S   
                                          ; bias of _T
                  bias_T        = wmean_case_T - wmean_ref_T
                  if (wmean_ref_T.ne.0) then
                      bias_T    = abs(bias_T/wmean_ref_T)*100  ; bias [%]
                  else
                      bias_T    = bias_metric_T@_FillValue
                  end if
                                          ; temporal variance at each grid point [local]
                  vref_var_T    = dim_variance_n(rdata, 0 )  ; (lat,lon) 
                  vcase_var_T   = dim_variance_n(cdata, 0 )
                ;;vref_var_T    = dim_variance(rdata(lat|:,lon|:,time|:) )  ; (lat,lon) 
                ;;vcase_var_T   = dim_variance(cdata(lat|:,lon|:,time|:) )

                                          ; wgted areal *local* temporal variance
                  wvar_ref_T    = sum(wgt_S*vref_var_T)/sumwgt_S   
                  wvar_case_T   = sum(wgt_S*vcase_var_T)/sumwgt_S   
                                          ; ratio
                  wvar_ratio_T  = (wvar_case_T/wvar_ref_T)^0.5 
                                                ; arrays used for plot/netCDF
                  cc_metric_T(nc,0,nv)      = wcc_T
                  cc_metric_ST(nc,0,nv)     = wcc_ST
                  bias_metric_T(nc,0,nv)    = bias_T
                  bias_metric_ST(nc,0,nv)   = bias_ST
                  ratio_metric_T(nc,0,nv)   = wvar_ratio_T 
                  ratio_metric_ST(nc,0,nv)  = wvar_ratio_ST 
                  mean_T(0,nc,0,nv)         = wmean_ref_T  
                  mean_ST(0,nc,0,nv)        = wmean_ref_ST  
                  mean_T(1,nc,0,nv)         = wmean_case_T  
                  mean_ST(1,nc,0,nv)        = wmean_case_ST  

                  delete(cc_T)              
                  delete( vref_mean_T )
                  delete( vcase_mean_T)
                  delete( vref_var_T  )
                  delete( vcase_var_T )
              end if

          else                            ; =====> VECTOR <===== 
              vrefx_S       = vref_S(0,:,:)     ; (xy,lat,lon)
              vrefy_S       = vref_S(1,:,:)
              vcasex_S      = vcase_S(0,:,:)
              vcasey_S      = vcase_S(1,:,:)
              wgtxy_S       = wgt_S(0,:,:)      ; wgt_S(0,:,:)=wgt_S(1,:,:)
 
              sumwgt_S      = sum(wgtxy_S)      ; [spatial]
              sumwrx        = sum(wgtxy_S*vrefx_S)
              sumwry        = sum(wgtxy_S*vrefy_S)
              sumwcx        = sum(wgtxy_S*vcasex_S)
              sumwcy        = sum(wgtxy_S*vcasey_S)

                                          ; wgted areal means (vector components)
              wmean_refx_S  = sumwrx/sumwgt_S
              wmean_refy_S  = sumwry/sumwgt_S
              wmean_casex_S = sumwcx/sumwgt_S
              wmean_casey_S = sumwcy/sumwgt_S
                                          ; vector magnitudes
              magref_S      = sqrt(wmean_refx_S^2  + wmean_refy_S^2 ) 
              magcase_S     = sqrt(wmean_casex_S^2 + wmean_casey_S^2) 
              bias_S        = magcase_S - magref_S
              if (magref_S.ne.0) then
                  bias_S    = abs(bias_S/magref_S)*100    ; bias [%]  
              else
                  bias_S    = bias_metric_ST@_FillValue
              end if

                                          ; wgted areal (spatial) variance (vector)
              wvar_ref_S    = sum(wgtxy_S*((vrefx_S -wmean_refx_S)^2 +\
                                           (vrefy_S -wmean_refy_S)^2))/sumwgt_S  
              wvar_case_S   = sum(wgtxy_S*((vcasex_S-wmean_casex_S)^2 +\
                                           (vcasey_S-wmean_casey_S)^2))/sumwgt_S  
              wvar_ratio_S  = (wvar_case_S/wvar_ref_S)^0.5 

                                          ; wgted vector cor coef [space-time] 
              wcc_S   = sum(wgtxy_S*((vrefx_S-wmean_refx_S)*(vcasex_S-wmean_casex_S)   \
                                    +(vrefy_S-wmean_refy_S)*(vcasey_S-wmean_casey_S))) \
                                    /(sqrt(wvar_ref_S*wvar_case_S)*sumwgt_S)

                                          ; arrays used for plot/netCDF
              cc_metric_S(nc,ns,nv)     = wcc_S
              bias_metric_S(nc,ns,nv)   = bias_S  
              ratio_metric_S(nc,ns,nv)  = wvar_ratio_S 
              mean_S(0,nc,ns,nv)        = magref_S  
              mean_S(1,nc,ns,nv)        = magcase_S  

              delete( vrefx_S)            ; delete variablds which may change
              delete( vrefy_S)            ; rank on next variable iteration
              delete( vcasex_S)           ; [really needed for 
              delete( vcasey_S)           ;  REF_to_CASE  = False]

              if ((CC_TIME .or. CC_SPACE_TIME) .and. SEASONS(ns).eq."ANN") then 
                                          ; VECTOR Space-Time
                  vrefx_ST         = rdata(0,:,:,:)  ; (12,lat,lon)
                  vrefy_ST         = rdata(1,:,:,:)
                  vcasex_ST        = cdata(0,:,:,:)
                  vcasey_ST        = cdata(1,:,:,:)
                  wgt_ST           = wt(0,:,:,:)     ; (12,lat,lon)     

                  sumwgt_ST        = sum(wgt_ST)      
                                                     ; (12,lat,lon)*(12,lat,lon)
                  sumwrx           = sum(wgt_ST*vrefx_ST) 
                  sumwry           = sum(wgt_ST*vrefy_ST)
                  sumwcx           = sum(wgt_ST*vcasex_ST)
                  sumwcy           = sum(wgt_ST*vcasey_ST)

                                          ; wgted areal means of vector components
                  wmean_refx_ST    = sumwrx/sumwgt_ST
                  wmean_refy_ST    = sumwry/sumwgt_ST
                  wmean_casex_ST   = sumwcx/sumwgt_ST
                  wmean_casey_ST   = sumwcy/sumwgt_ST
                                          ; magnitude 
                  mag_ref_ST       = sqrt(wmean_refx_ST^2  + wmean_refy_ST^2 ) 
                  mag_case_ST      = sqrt(wmean_casex_ST^2 + wmean_casey_ST^2) 
                  bias_ST          = mag_case_ST - mag_ref_ST
                  if (mag_ref_ST.ne.0) then
                      bias_ST = abs(bias_ST/mag_ref_ST)*100  
                  else
                      bias_ST = bias_metric_S@_FillValue
                  end if

                                          ; wgted space/time variance (vector)
                  wvar_ref_ST      = sum(wgt_ST*((vrefx_ST -wmean_refx_ST)^2 +\
                                                 (vrefy_ST -wmean_refy_ST)^2))/sumwgt_ST  
                  wvar_case_ST     = sum(wgt_ST*((vcasex_ST-wmean_casex_ST)^2 +\
                                                 (vcasey_ST-wmean_casey_ST)^2))/sumwgt_ST  
                  wvar_ratio_ST    = (wvar_case_ST/wvar_ref_ST)^0.5 

                                          ; wgted vector cor coef [space-time] 
                  wcc_ST  = sum(wgt_ST*((vrefx_ST-wmean_refx_ST)*(vcasex_ST-wmean_casex_ST)    \
                                       +(vrefy_ST-wmean_refy_ST)*(vcasey_ST-wmean_casey_ST)))  \
                                       /(sqrt(wvar_ref_ST*wvar_case_ST)*sumwgt_ST)
 
                                          ; vector magnitudes  (12[=time],lat,lon)
                  vref_mag_T       = sqrt( vrefx_ST^2  + vrefy_ST^2 )  
                  vcase_mag_T      = sqrt( vcasex_ST^2 + vcasey_ST^2  )   
                  copy_VarCoords(vrefx_ST , vref_mag_T)
                  copy_VarCoords(vcasex_ST, vcase_mag_T)
                   
                                          ; local temporal cor 
;; not yet avail  cc_T             = escorc_n(vcase_mag_T, vref_mag_T, 0 )  ; (lat,lon)  
                  cc_T             = escorc(vcase_mag_T(lat|:,lon|:,time|:) \  ; local     
                                           ,vref_mag_T (lat|:,lon|:,time|:) )  ; (lat,lon)  
                  cc_T@long_name   = "temporal lin cor: "+VAR_ID_PLOT(nv) 
                  wcc_T            = sum(wgtxy_S*cc_T)/sumwgt_S
                                          ; temporal mean magnitude at each grid point
                  vref_mean_T   = dim_avg_n(vref_mag_T, 0)  ; (lat,lon) 
                  vcase_mean_T  = dim_avg_n(vcase_mag_T, 0) ; local 
                ;;vref_mean_T   = dim_avg(vref_mag_T (lat|:,lon|:,time|:))  ; (lat,lon) 
                ;;vcase_mean_T  = dim_avg(vcase_mag_T(lat|:,lon|:,time|:))  ; local 

                                          ; wgt spatial avg of _T means 
                  wmean_ref_T   = sum(wgtxy_S*vref_mean_T)/sumwgt_S   
                  wmean_case_T  = sum(wgtxy_S*vcase_mean_T)/sumwgt_S   

                                          ; bias of _T
                  bias_T        = wmean_case_T - wmean_ref_T
                  if (wmean_ref_T.ne.0) then
                      bias_T    = abs(bias_T/wmean_ref_T)*100  ; bias [%]
                  else
                      bias_T    = bias_metric_T@_FillValue
                  end if

                                          ; temporal variance at each grid point [local]
                  vref_var_T    = dim_variance_n(vref_mag_T , 0) ; (lat,lon)
                  vcase_var_T   = dim_variance_n(vcase_mag_T, 0)
                ;;vref_var_T    = dim_variance(vref_mag_T (lat|:,lon|:,time|:)) ; (lat,lon)
                ;;vcase_var_T   = dim_variance(vcase_mag_T(lat|:,lon|:,time|:))

                                          ; wgted areal *local* temporal variance
                  wvar_ref_T    = sum(wgtxy_S*vref_var_T)/sumwgt_S   
                  wvar_case_T   = sum(wgtxy_S*vcase_var_T)/sumwgt_S   

                                          ; ratio
                  wvar_ratio_T  = (wvar_case_T/wvar_ref_T)^0.5 

                  cc_metric_T(nc,0,nv)     = wcc_T
                  cc_metric_ST(nc,0,nv)    = wcc_ST
                  bias_metric_T(nc,0,nv)   = bias_T
                  bias_metric_ST(nc,0,nv)  = bias_ST

                  ratio_metric_T(nc,0,nv)  = wvar_ratio_T 
                  ratio_metric_ST(nc,0,nv) = wvar_ratio_ST 
                  mean_T(0,nc,0,nv)        = wmean_ref_T  
                  mean_ST(0,nc,0,nv)       = mag_ref_ST  
                  mean_T(1,nc,0,nv)        = wmean_case_T  
                  mean_ST(1,nc,0,nv)       = mag_case_ST  

                  delete( vrefx_ST )            ; delete variablds which may change
                  delete( vrefy_ST )            ; rank on next variable iteration
                  delete( vcasex_ST)            ; [really needed for 
                  delete( vcasey_ST)            ;  REF_to_CASE  = False]
                  delete( wgt_ST )
                  delete( cc_T   )
                  delete( vref_mag_T  )
                  delete( vcase_mag_T  )
                  delete( vref_mean_T  )
                  delete( vcase_mean_T  )
                  delete( vref_var_T  )
                  delete( vcase_var_T )
              end if
              
              if (isvar("wgtxy_S")) then
                  delete( wgtxy_S )
              end if
 
          end if

          delete( vref_S )            ; delete variables which may change
          delete( vcase_S)            ; rank on next variable iteration
          delete( wgt_S  )           

          delete( wt   )          
          delete( wt_1d)
 
          delete(cdata)
          delete(rdata)
 
          if (isvar("lfrac")) then
              delete(lfrac)
          end if
          delete(fr0)
          delete(fr)
      end do                             ; endd VARIABLE loop

    end do                              ; endd CASE loop
 
 ;**********************************************************
 ; plot Taylor Diagram(s)
 ;**********************************************************
 
      plot_root_name   = wkdir+PLOT_NAME+"_"+SEASONS(ns) 
  
      if (isvar("PLOT_TYPE")) then
          if (PLOT_TYPE.eq."png" .or. PLOT_TYPE.eq."gif") then
              plot_type    = "png"
          else
              plot_type    = PLOT_TYPE
          end if
      else
          plot_type    = "png"
      end if
      plot_file        = plot_root_name +"."+plot_type
 
      opt              = True
                                           ; string for non-default set
      if (.not.REF_to_CASE) then
        optionString = "Reference Grids Used"
      end if
    ;;if (???????????) then
    ;;    optionString = optionString +": "+ "whatever"
    ;;end if
 
      opt@varLabels = VAR_ID_PLOT
 
      if (.not.isvar("CASE_ID_PLOT")) then
          CASE_ID_PLOT = CASE_FILE         ; default
      end if
      opt@caseLabels   = CASE_ID_PLOT
 
      if (isvar("CASE_ID_MARKERS")) then
          opt@Markers  = CASE_ID_MARKERS 
      end if

      if (isvar("CASE_ID_COLORS")) then
          opt@Colors   = CASE_ID_COLORS
      end if
 
     ;if (isvar("METRICS_PANEL") .and. METRICS_PANEL) then ; paneling not implemented  
     ;    opt@taylorFrame  = False
     ;end if

      if (isvar("optionString")) then
          opt@gsnCenterString = optionString
      end if

      tiMainString     = SEASONS(ns)
      if (isvar("TI_MAIN_EXTRA")) then  ; user specified info for *all* titles
          tiMainString = tiMainString +": "+TI_MAIN_EXTRA
      end if
  
      wks              = gsn_open_wks(plot_type,plot_root_name+"_SPACE"+PLOT_SUFFIX) 
      opt@tiMainString = tiMainString + ": SPACE"
      plot             = taylor_diagram_cam(wks,ratio_metric_S(:,ns,:) \
                                               ,cc_metric_S(:,ns,:)    \
                                               ,bias_metric_S(:,ns,:),opt)
                      
      if (CC_TIME  .and. SEASONS(ns).eq."ANN") then 
          opt@tiMainString = tiMainString + ": TIME"
          wks_T            = gsn_open_wks(plot_type,plot_root_name+"_TIME"+PLOT_SUFFIX) 
          plot             = taylor_diagram_cam(wks_T,ratio_metric_T(:,0,:) \
                                               ,cc_metric_T(:,0,:) \
                                               ,bias_metric_T(:,0,:),opt)
      end if
                      
      if (CC_SPACE_TIME  .and. SEASONS(ns).eq."ANN") then 
          opt@tiMainString = tiMainString + ": SPACE-TIME"
          wks_T            = gsn_open_wks(plot_type,plot_root_name+"_SPACE_TIME"+PLOT_SUFFIX) 
          plot             = taylor_diagram_cam(wks_T,ratio_metric_ST(:,0,:) \
                                               ,cc_metric_ST(:,0,:)          \
                                               ,bias_metric_ST(:,0,:),opt)
      end if
 
     ;if (isatt(opt,"taylorFrame") .and. .not.opt@taylorFrame) then
     ;   ; add non-default options chosen
     ;    txres = True
     ;    txres@txFontHeightF = 0.015 
     ;    txres@txJust        = "BottomLeft"
     ;    gsn_text_ndc (wks,"REF_to_CASE="+REF_to_CASE , 0.15, 0.05, txres)
     ;    frame(wks)
     ;end if
 
      if (PLOT_TYPE.eq."png" .or. PLOT_TYPE.eq."gif") then
          system ("convert "+plot_file+"  "+plot_root_name +"."+PLOT_TYPE)
          system ("'rm' -f "+plot_file)
      end if
  end do   ; end SEASONS loop

 ;**********************************************************
 ; Gross error checks on cross correlations
 ;**********************************************************
  printMinMax(cc_metric_S , True)
  printMinMax(cc_metric_T , False)
  printMinMax(cc_metric_ST, False)

  if (any(abs(cc_metric_S).gt.1)) then
      print("===================================")
      print("     abs(cc_metric_S)>1            ")
      print("===================================")
  end if
  if (any(abs(cc_metric_T).gt.1)) then
      print("===================================")
      print("     abs(cc_metric_T)>1            ")
      print("===================================")
  end if
  if (any(abs(cc_metric_ST).gt.1)) then
      print("===================================")
      print("     abs(cc_metric_ST)>1           ")
      print("===================================")
  end if

;**********************************************************
; Print metric values
;**********************************************************

  if (METRICS_PRINT) then
      if ((CC_TIME .or. CC_SPACE_TIME) .and. any(SEASONS.eq."ANN")) then 
           print(" ")
           print("++++++++++ SPATIAL METRICS +++++++++++++")
           print("  bias_S="     +sprintf("%6.3j", bias_metric_S)  \
                +"  ratio_S="    +sprintf("%6.3f", ratio_metric_S) \
                +"  cc_S="       +sprintf("%6.3f", cc_metric_S)    \
                +"  mean_ref_S=" +sprintf("%9.3g", mean_S(0,:,:,:))\
                +"  mean_case_S="+sprintf("%9.3g", mean_S(1,:,:,:)))
           print(" ")
           print("++++++++++ TEMPORAL  METRICS +++++++++++++")
           print("  bias_T="     +sprintf("%6.3f", bias_metric_T(:,0,:))  \
                +"  ratio_T="    +sprintf("%6.3f", ratio_metric_T(:,0,:)) \
                +"  cc_T="       +sprintf("%6.3f", cc_metric_T(:,0,:))    \
                +"  mean_ref_T ="+sprintf("%9.3g", mean_T(0,:,0,:))   \
                +"  mean_case_T="+sprintf("%9.3g", mean_T(1,:,0,:)) )
           print("++++++++++ SPACE-TIME METRICS +++++++++++++")
           print("  bias_ST="    +sprintf("%6.3f", bias_metric_ST(:,0,:))  \
                +"  ratio_ST="   +sprintf("%6.3f", ratio_metric_ST(:,0,:)) \
                +"  cc_ST="      +sprintf("%6.3f", cc_metric_ST(:,0,:))    \
                +"  mean_ref_ST="+sprintf("%9.3g", mean_ST(0,:,0,:))   \
                +"  mean_case_ST="+sprintf("%9.3g", mean_ST(1,:,0,:)) )
      end if   
      print("++++++++++")
  end if
 
;**********************************************************
; Metrics Table
;**********************************************************
     tt_opt        = True
     tt_opt@pltType= plot_type  ; "eps" [default], "pdf", "ps"
                                ; "png", "gif" [if you have ImageMajik 'convert']
    
     METRICS_NAME = PLOT_NAME + ".METRICS_VAR_SPACE"+PLOT_SUFFIX
     tt_opt@title = "var ratio: Space"
     tt_opt@vartype = "variance"
     tt_opt@color0 = "DarkOliveGreen3" 
     tt_opt@color1 = "IndianRed1"

     taylor_metrics_table(METRICS_NAME, VAR_ID_PLOT, CASE_ID_PLOT ,SEASONS \
                         ,ratio_metric_S, tt_opt)
 
     METRICS_NAME = PLOT_NAME + ".METRICS_BIAS_SPACE"+PLOT_SUFFIX
     tt_opt@title = "bias [%]: Space"
     tt_opt@vartype = "bias"
     tt_opt@color0 = "DarkOliveGreen3" 
     tt_opt@color1 = "IndianRed1"
     taylor_metrics_table(METRICS_NAME, VAR_ID_PLOT, CASE_ID_PLOT ,SEASONS \
                         ,bias_metric_S, tt_opt)
 
     METRICS_NAME = PLOT_NAME + ".METRICS_CC_SPACE"+PLOT_SUFFIX
     tt_opt@title = "cor coef: Space"
     tt_opt@vartype = "correlation"
     tt_opt@color0 = "IndianRed1"
     tt_opt@color1 = "DarkOliveGreen3" 
     taylor_metrics_table(METRICS_NAME, VAR_ID_PLOT, CASE_ID_PLOT ,SEASONS \
                         ,cc_metric_S, tt_opt)
 
     if (CC_TIME  .and. any(SEASONS.eq."ANN")) then 
          METRICS_NAME = PLOT_NAME + ".METRICS_CC_TIME"+PLOT_SUFFIX
          tt_opt@title = "cor coef: Time"
          tt_opt@vartype = "correlation"
          tt_opt@color0 = "IndianRed1"
          tt_opt@color1 = "DarkOliveGreen3" 
          taylor_metrics_table(METRICS_NAME, VAR_ID_PLOT, CASE_ID_PLOT , "ANN" \
                             ,cc_metric_T, tt_opt)
     end if
 
     if (CC_SPACE_TIME  .and. any(SEASONS.eq."ANN")) then 
         METRICS_NAME = PLOT_NAME + ".METRICS_CC_SPACE_TIME"+PLOT_SUFFIX
         tt_opt@tableTitle = "cor coef: Space-Time"
         tt_opt@vartype = "correlation"
         tt_opt@color0 = "IndianRed1"
         tt_opt@color1 = "DarkOliveGreen3" 
         taylor_metrics_table(METRICS_NAME, VAR_ID_PLOT, CASE_ID_PLOT , "ANN" \
                             ,cc_metric_ST, tt_opt)
         


         METRICS_NAME = PLOT_NAME + ".METRICS_BIAS_SPACE_TIME"+PLOT_SUFFIX
         tt_opt@tableTitle = "bias [%]: Space-Time"
         tt_opt@vartype = "bias"
         tt_opt@color0 = "DarkOliveGreen3" 
         tt_opt@color1 = "IndianRed1"
         taylor_metrics_table(METRICS_NAME, VAR_ID_PLOT, CASE_ID_PLOT , "ANN" \
                             ,bias_metric_ST, tt_opt)

         METRICS_NAME = PLOT_NAME + ".METRICS_VAR_SPACE_TIME"+PLOT_SUFFIX
         tt_opt@tableTitle = "var-ratio: Space-Time"
         tt_opt@vartype = "variance"
         taylor_metrics_table(METRICS_NAME, VAR_ID_PLOT, CASE_ID_PLOT , "ANN" \
                             ,ratio_metric_ST, tt_opt)
     end if
 
     metrics_file = METRICS_NAME+"."+plot_type
     if (PLOT_TYPE.eq."png" .or. PLOT_TYPE.eq."gif") then
         system("convert "+metrics_file+"  "+ METRICS_NAME +"."+PLOT_TYPE)
         system ("'rm' -f "+metrics_file)
     end if

;**********************************************************
; Create netCDF file   [Default:  METRICS_NETCDF=False]
;**********************************************************

    if (METRICS_NETCDF) then
        metrics_fname     = METRICS_FILENAME + ".nc"
        system("'rm' -f "+metrics_fname)
        fnc = addfile(metrics_fname, "c")

        ratio_metric_S!0  = "case"
        ratio_metric_S!1  = "season"
        ratio_metric_S!2  = "variable"
        bias_metric_S!0   = "case"
        bias_metric_S!1   = "season"
        bias_metric_S!2   = "variable"
        cc_metric_S!0     = "case"
        cc_metric_S!1     = "season"
        cc_metric_S!2     = "variable"
 
        ratio_metric_T!0  = "case"
        ratio_metric_T!1  = "ANN"
        ratio_metric_T!2  = "variable"
        bias_metric_T!0   = "case"
        bias_metric_T!1   = "ANN"
        bias_metric_T!2   = "variable"
        cc_metric_T!0     = "case"
        cc_metric_T!1     = "ANN"
        cc_metric_T!2     = "variable"

        ratio_metric_ST!0 = "case"
        ratio_metric_ST!1 = "ANN"
        ratio_metric_ST!2 = "variable"
        bias_metric_ST!0  = "case"
        bias_metric_ST!1  = "ANN"
        bias_metric_ST!2  = "variable"
        cc_metric_ST!0    = "case"
        cc_metric_ST!1    = "ANN"
        cc_metric_ST!2    = "variable"
   
        units_table!0     = "variable"

        case_c         = s2c_2d (CASE_TAYLOR(0:nCase-1,1))
        case_c!0       = "case"
        case_c!1       = "case_max"

        variable_c     = s2c_2d ( VAR_ID_PLOT )
        variable_c!0   = "variable"
        variable_c!1   = "variable_max"
    
        season_c       = s2c_2d ( SEASONS )
        season_c!0     = "season"
        season_c!1     = "season_max"

        units_c        = s2c_2d ( units_table )
        units_c!0      = "variable"
        units_c!1      = "unit_max"
        units_c@long_name = "variable units"

        fnc@TITLE           = "AMP: TAYLOR PLOT INFO"
        fnc@creation_date   = systemfunc("date")

        fnc->CC_METRIC_S    = cc_metric_S
        fnc->CC_METRIC_T    = cc_metric_T
        fnc->CC_METRIC_ST   = cc_metric_ST

        fnc->BIAS_METRIC_S  = bias_metric_S
        fnc->BIAS_METRIC_T  = bias_metric_T
        fnc->BIAS_METRIC_ST = bias_metric_ST

        fnc->RATIO_METRIC_S = ratio_metric_S 
        fnc->RATIO_METRIC_T = ratio_metric_T 
        fnc->RATIO_METRIC_ST= ratio_metric_ST

        fnc->CASE           = case_c
        fnc->VARIABLE       = variable_c
        fnc->SEASON         = season_c
        fnc->UNITS          = units_c
    end if
 
end

