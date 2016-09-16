;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
; Utility files for:
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;          Taylor_Metrics_Processor
;         for AMWG Mean Diagnostics
;                  [TMP]
;               Version 0.60
;               18 Sept 2006
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
; 20 Dec 2010: Use dim_???_n where appropriate
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
;
;================================================
; procedure to get weights
; force return as double for numerical reasons
;================================================

;setfileoption('nc', 'SuppressClose', False)

undef("getWeights")
function getWeights (f:file, opt)
local gw, gwf, lat, rad, clat
begin
  if (isfilevar(f, "gw")) then  
      gw = f->gw                   ; gaus weights
      if (typeof(gw).eq."double") then
          return(gw)          
      else
          gwd = flt2dble( gw )
          copy_VarMeta(gw, gwd)
          return(gwd)
      end if
      
  else 
      if (isfilevar(f, "lat")) then   ; make more general later 
          lat = f->lat
          LAT = NormCosWgtGlobe(lat)
          if (typeof(LAT).eq."double")
              return(LAT) 
          else
              LATD = flt2dble( lat )
              copy_VarMeta(lat, LATD)
              return(NormCosWgtGlobe(LATD)) 
          end if
      else  
          print("=======================================")  
          print("getWeights: missing expected gw and lat")  
          print("=======================================")  
          print(f)
          exit 
      end if  
  end if  
end
;--------------------------
undef("chkData")
function chkData(cdata, rdata, caseName, opt)
local ier, ctest, rtest
begin
  if (isatt(cdata,"missing_value") .and. .not.isatt(cdata,"_FillValue")) then 
      cdata@_FillValue = cdata@missing_value 
  end if    
  if (isatt(rdata,"missing_value") .and. .not.isatt(rdata,"_FillValue")) then 
      rdata@_FillValue = rdata@missing_value 
  end if    

  ier = 0
  case_test = all(ismissing(cdata))
  ref_test  = all(ismissing(rdata))
  if (.not.case_test .and. .not.ref_test) then 
      return(ier)
  end if

  if (case_test .and. ref_test) then 
      print("=====================================")
      print("Warning: chkData: Variables not found: "+ \
                      caseName+" , "+caseName)
      print("=====================================")
      ier = 1
      return(ier)
  end if
  if (case_test .and. .not.ref_test) then 
      print("=====================================")
      print("Warning: chkData: Case variable not found: "+ \
                      caseName)
      print("=====================================")
      ier = 2
      return(ier)
  end if
  if (.not.case_test .and. ref_test) then 
      print("=====================================")
      print("Warning: chkData: Reference variable not found: "+ \
                      caseName)
      print("=====================================")
      ier = 3
      return(ier)
  end if
end 

;================================================
; procedure to rename dimension names
; **not necessary: done for consistency/convenience
;================================================
undef("renameDimNames")
procedure renameDimNames ( x:numeric )
local dimx, rankx
begin
  dimx   = dimsizes(x)
  rankx  = dimsizes(dimx)

  if (x@class.eq."scalar") then
      if (rankx.eq.2) then
          x!0 = "lat"
          x!1 = "lon"
      end if
      if (rankx.eq.3) then
          x!0 = "time"
          x!1 = "lat"
          x!2 = "lon"
      end if
      if (rankx.eq.4) then
          x!0 = "time"
          x!1 = "lev"
          x!2 = "lat"
          x!3 = "lon"
      end if
  end if
  

  if (x@class.eq."vector") then
      x!0 = "xy"
      xy   = (/ 0,1 /)
      xy@units = "0=zonal, 1-meridional component"
      x&xy = xy
      if (rankx.eq.3) then
          x!1 = "lat"
          x!2 = "lon"
      end if
      if (rankx.eq.4) then
          x!1 = "time"
          x!2 = "lat"
          x!3 = "lon"
      end if
      if (rankx.eq.5) then
          x!1 = "time"
          x!2 = "lev"
          x!3 = "lat"
          x!4 = "lon"
      end if
  end if


  xDimNames = getvardims( x )   ; get dimension names
  if (any(xDimNames.eq."time")) then
      time   = ispan(1,12,1)
      time!0 = "time" 
      time@units = "month: 1=Jan, 2=Feb,...,12=Dec"
      x&time = time             ; force consistent time coordinate
  end if

end

;================================================
; function to read scalar or vector components for 
; user specified variable [varName] 
; for numerical reasons force a type double return
;================================================
undef("getData")
function getData (f:list          \  ; file references [pointers]
                 ,fils:string       \  ; file list [string]
                 ,varName:string  \  ; variable name
                 ,opt:logical)    \  ; optional argument [not used]

local vClm, vClmx, vClmy, vFlag, vClass, dimv, rankv
;   , usrClm, dimu, ranku
begin
 
    vFlag  = False                   ; flag iff variable found
    vClass = "null"
    f0 = addfile(fils(0),"r")
                                ; READ FULL CLIMATOLOGY (12,:,:)
    if (isfilevar(f0, varName)) then  ; is specified variable on files
        vClm = addfiles_GetVar(f,fils,varName)
        vFlag      = True
        vClass     = "scalar"
        vClm@class =  vClass
    else                             ; must not be on the file
                                     ; must be derived or vector variable
      if (varName.eq."PRECT") then
        if (isfilevar(f0,"PRECL") .and. isfilevar(f0,"PRECC")) then
          vClm        = addfiles_GetVar(f,fils,"PRECL") 
          vClm        = vClm + addfiles_GetVar(f,fils,"PRECC") 
          vClm@long_name = "Total prc: (PRECL + PRECC)"
          vFlag       = True
          vClass      = "scalar"
          vClm@class  =  vClass
        end if
      end if

      if (varName.eq."TREFHT") then
        if (isfilevar(f0,"TREFHT_LAND")) then
          ListSetType (f, "join") 
          vClm        = addfiles_GetVar(f,fils,"TREFHT_LAND") 
          vClm!0 = "time"
          vFlag       = True
          vClass      = "scalar"
          vClm@class  =  vClass
        end if
      end if
      if (varName.eq."STRESS") then
        if (isfilevar(f0,"TAUX") .and. isfilevar(f0,"TAUY")) then
          vClmx       = addfiles_GetVar(f,fils,"TAUX") 
          vClmy       = addfiles_GetVar(f,fils,"TAUY") 
          vFlag       = True
          vClass      = "vector"
        end if
      end if
      
      if (varName.eq."WIND") then
        if (isfilevar(f0,"U") .and. isfilevar(f0,"V")) then
          vClmx       = addfiles_GetVar(f,fils,"U") 
          vClmy       = addfiles_GetVar(f,fils,"V") 
          vFlag       = True
          vClass      = "vector"
        end if
      end if

        
      
       ;if (.not.vFlag) then   
           ;if (isdefined("getDataUser")) then   ; has user defined function
           ;
           ;    usrClm = getDataUser( f, varName, opt ) 
           ;
           ;    if (all(ismissing(usrClm))) then
           ;    
           ;    end if
           ;    vFlag  = usrClm@flag
           ;    vClass = usrClm@class
           ;                                     ; put in local variables
           ;    if (vClass.eq."scalar") then
           ;        vClm = usrClm
           ;    end if
           ;    if (vClass.eq."vector") then
           ;        dimu  = dimsizes( usrClm )
           ;        ranku = dimsizes( dimu )
           ;        if (ranku.eq.4) then
           ;            vClmx = usrClm(0,:,:,:)
           ;            vClmy = usrClm(1,:,:,:)
           ;        end if
           ;        if (ranku.eq.5) then
           ;            vClmx = usrClm(0,:,:,:,:)
           ;            vClmy = usrClm(1,:,:,:,:)
           ;        end if
           ;    end if
           ;end if
       ;end if
   end if
   



   if (vFlag) then

; RBN 02APR09
; ERA40 has a float missing value for an integer time variable
; which messes up flt2dble conversion so just remove it when present.


       if (vClass.eq."scalar") then
         if (isatt(vClm&time,"_FillValue")) then
           delete(vClm&time@_FillValue)
         end if
           vClm@class = vClass
           vClm@flag  = vFlag
           vClm@rank  = dimsizes(dimsizes(vClm))
           if (typeof(vClm).eq."double") then
                return( vClm )
           else
               return( flt2dble(vClm) )
           end if
       else
           dimv  = dimsizes( vClmx )
           rankv = dimsizes( dimv )
           if (rankv.eq.3) then
               vdata  = new ( (/2,dimv(0),dimv(1),dimv(2)/) \
                               ,typeof(vClmx), getFillValue(vClmx) )
               vdata(0,:,:,:) = vClmx
               vdata(1,:,:,:) = (/ vClmy /) 
           end if
           if (rankv.eq.4) then
               vdata  = new ( (/2,dimv(0),dimv(1),dimv(2),dimv(3)/) \
                               ,typeof(vClmx), getFillValue(vClmx) )
               vdata(0,:,:,:,:) = vClmx
               vdata(1,:,:,:,:) = (/ vClmy /) 
           end if
    
           vdata!0     = "xy"
           vdata@class = "vector"
           vdata@flag  = True 
           vdata@rank  = dimsizes(dimsizes(vdata))
           if (typeof(vdata).eq."double") then
               return( vdata )
           else
               return( flt2dble(vdata) )
           end if
       end if
   end if
   vClm = 1d20
   vClm@_FillValue = 1d20
   vClm@class      = "null"
   vClm@flag       = False
   vClm@rank       = -1    

   printVarSummary(vClm)

   delete(f0)
   return(vClm)
end
; -------------------------------
undef("getLANDFRAC")
function getLANDFRAC (fc:list,fils:string)
local lfrac
begin
   f0 = addfile(fils(0),"r")
   if (isfilevar(f0,"LANDFRAC")) then
       lfrac       = addfiles_GetVar(fc,fils,"LANDFRAC")   ; will this always be present???
       lfrac@flag  = True
       lfrac@class = "scalar"
       lfrac@rank  = dimsizes(dimsizes(lfrac))

       if (.not.isatt(lfrac,"_FillValue")) then
           lfrac@_FillValue = 1e20
       end if
   else
       print("------------------------------------------")
       print("-->TAYLOR: land-sea: LANDFRAC not found  <--")
       print("------------------------------------------")

       lfrac = 1e20
       lfrac@_FillValue = 1e20
       lfrac@flag       = False
       lfrac@class      = "null"
       lfrac@rank       = -1    
   end if
   delete(f0)
   return (lfrac)
end 
                        
; -------------------------------
;;undef("getLandSeaMask")
;;function getLandSeaMask (lfrac, lsFlag:integer)
;;local lsMask, lsM1d, iLand, iOcean
;;begin
;;   lsMask = lfrac
;;                        
;;  ;if (lsFlag.eq.0) then                ; ocean
;;  ;    lsMask = mask(lsMask, lsMask.eq.0, False) ; < 0.9 
;;  ;end if
;;  ;if (lsFlag.eq.1) then                ; land
;;  ;    lsMask = mask(lsMask, lsMask.eq.1, False) ; > 0.9
;;  ;end if
;; 
;;   lsM1d      = ndtooned ( lsMask )
;;   iLand      = ind(lsM1.eq.1)          ; > 0.9
;;   iOcean     = ind(lsM1.ne.1)          ; < 0.9
;;   if (lsFlag.eq.1) then
;;           lsM1d(iOcean) = lsMask@_FillValue
;;           lsM1d(iLand)  = 1.0
;;   end if
;;   if (lsFlag.eq.0) then
;;           lsM1d(iOcean) = 1.0
;;           lsM1d(iLand)  = lsMask@_FillValue
;;   end if
;;       
;;   lsMask     = onedtond(lsM1d, dimsizes(lsMask))
;;   return (lsMask)
;;end 
; -------------------------------

undef("getSeason")
function getSeason (vClm, monsea, opt)
; select appropriate month/season
; perform averaging ... if needed
begin

   month = (/"JAN","FEB","MAR","APR","MAY","JUN" \
            ,"JUL","AUG","SEP","OCT","NOV","DEC" /)

   sea3  = (/"DJF","JFM","FMA","MAM","AMJ","MJJ" \
            ,"JJA","JAS","ASO","SON","OND","NDJ" /)

   i3    = (/(/12,1,2/),(/1,2,3/),(/2,3,4/),(/3,4,5/) \ 
            ,(/ 4,5,6/),(/5,6,7/),(/6,7,8/),(/7,8,9/) \ 
            ,(/ 8,9,10/),(/9,10,11/),(/10,11,12/),(/11,12,1/) /)
   i3    = i3-1    ; NCL is zero based

   if (WGT_MONTH) then
       wgtmo = (/0.08493151, 0.076712325, 0.08493151, 0.08219178 \
                ,0.08493151, 0.08219178 , 0.08493151, 0.08493151 \
                ,0.08219178, 0.08493151 , 0.08219178, 0.08493151 /)
   else
       wgtmo = fspan(1,1,12)/12.
   end if

   if (isatt(vClm,"class")) then
       vClass = vClm@class
   else
       print("------------------------------------------")
       print("-->TAYLOR: getSeason: vClm missing class attribute  <--")
       print("------------------------------------------")
       printVarSummary(vClm)
       exit
   end if

   dimv  = dimsizes(vClm)
   rank  = dimsizes( dimv )
   dNam  = getvardims ( vClm )             ; get dimension names

   if (vClass.eq."scalar") then            ; "METHODS" for scalar
       i = ind(month.eq.monsea)
       if (.not.ismissing(i)) then
           if (rank.eq.3) then             ; (time[month],lat,lon)
               data = vClm(i,:,:)          ; extract specified month
           end if
           if (rank.eq.4) then             ; (time[month],lev,lat,lon)
               data = vClm(i,:,:,:)        ; extract specified month
           end if
           data@rank   = dimsizes(dimsizes(data))
           data@season = monsea
           return( data )
       end if

       if (monsea.eq."ANN") then
           data = dim_avg_wgt_n_Wrap( vClm, wgtmo, 0, 0) 
        ;;;if (rank.eq.3) then             ; (time[month],lat,lon)
        ;;;    data = dim_avg_wgt_Wrap( vClm($dNam(1)$|:,$dNam(2)$|:,$dNam(0)$|:), wgtmo, 0) ; a034
        ;;;    data@long_name = "ANN: "+vClm@long_name
        ;;;end if
        ;;;if (rank.eq.4) then             ; (time[month],lev,lat,lon)
        ;;;    data = dim_avg_wgt_Wrap( vClm($dNam(1)$|:,$dNam(2)$|:,$dNam(3)$|:,$dNam(0)$|:), wgtmo, 0)
        ;;;    data@long_name = "ANN: "+vClm@long_name
        ;;;end if
           data@rank   = dimsizes(dimsizes(data))
           data@season = monsea
           return( data )
       end if

       i  = ind(sea3.eq.monsea)
       if (.not.ismissing(i)) then
               data = dim_avg_wgt_n_Wrap( vClm(i3(i,:),:,:), wgtmo(i3(i,:)), 0, 0)
        ;;;if (rank.eq.3) then            ; (time[month],lat,lon)
        ;;;    data = dim_avg_wgt_Wrap( vClm($dNam(1)$|:,$dNam(2)$|:,$dNam(0)$|i3(i,:)) \
        ;;;                           , wgtmo(i3(i,:)),0)
        ;;;end if
        ;;;if (rank.eq.4) then            ; (time[month],lev,lat,lon)
        ;;;    data = dim_avg_wgt_Wrap( vClm($dNam(1)$|:,$dNam(2)$|:,$dNam(3)$|:,$dNam(0)$|i3(i,:)) \
        ;;;                           , wgtmo(i3(i,:)),0) 
        ;; end if
           data@rank   = dimsizes(dimsizes(data))
           data@season = monsea
           return( data )
       end if
   end if

   if (vClass.eq."vector") then        ; "METHODS" for vector
       dimv = dimsizes( vClm )
       rank = dimsizes( dimv )
 
      ;if (rank.eq.4) then             ; (2,time[month],lat,lon)
      ;    data = new ( (/2,dimv(2),dimv(3)/), typeof(vClm), getFillValue(vClm) )
      ;end if
      ;if (rank.eq.5) then             ; (2,time[month],lev,lat,lon)
      ;    data = new ( (/2,dimv(1),dimv(2),dimv(3)/), typeof(vClm), getFillValue(vClm) )
      ;end if

       i = ind(month.eq.monsea)
       if (.not.ismissing(i)) then
           if (rank.eq.4) then
               data = vClm(:,i,:,:)    ; (2,lat,lon)
           end if
           if (rank.eq.5) then
               data = vClm(:,i,:,:,:)  ; (2,lev,lat,lon)
           end if
           data@rank   = dimsizes(dimsizes(data))
           data@season = monsea
           return( data )
       end if

       dNam = getvardims ( vClm )      ; get dimension names
                                       ; (xy,time,lat,lon) , (xy,time,lev,lat,lon)
       if (monsea.eq."ANN") then
                data = dim_avg_wgt_n_Wrap( vClm, wgtmo,0, 1)
        ;;;if (rank.eq.4) then
        ;;;     data = dim_avg_wgt_Wrap( vClm($dNam(0)$|:,$dNam(2)$|:,$dNam(3)$|:,$dNam(1)$|:) \
        ;;;                            , wgtmo,0)
        ;;;end if
        ;;;if (rank.eq.5) then
        ;;;     data = dim_avg_wgt_Wrap( vClm($dNam(0)$|:,$dNam(2)$|:,$dNam(3)$|:,$dNam(4)$|:,$dNam(1)$|:)\
        ;;;                            , wgtmo, 0 )
        ;;;end if
           data@rank   = dimsizes(dimsizes(data))
           data@season = monsea
           return( data )
       end if

       i  = ind(sea3.eq.monsea)
       if (.not.ismissing(i)) then
                data = dim_avg_wgt_n_Wrap( vClm(:,i3(i,:),:,:), wgtmo(i3(i,:)), 0, 1 )
        ;;;if (rank.eq.4) then
        ;;;     data = dim_avg_wgt_Wrap( vClm($dNam(0)$|:,$dNam(2)$|:,$dNam(3)$|:,$dNam(1)$|i3(i,:)) \
        ;;;                            , wgtmo(i3(i,:)), 0 )
        ;;;end if
        ;;;if (rank.eq.5) then
        ;;;     data = dim_avg_wgt_Wrap( vClm($dNam(0)$|:,$dNam(2)$|:,$dNam(3)$|:,$dNam(4)$|:,$dNam(1)$|i3(i,:)) \
        ;;;                            , wgtmo(i3(i,:)), 0 )
        ;;;end if
           data@rank   = dimsizes(dimsizes(data))
           data@season = monsea
           return( data )
       end if
   end if

end

;**********************************************************
; Interpolate Case/Model to ERA40 constant pressure levels
;**********************************************************

undef("caseLevel_to_refPresLevel")
function  caseLevel_to_refPresLevel(fc, cdata, rdata)
local caseType, lev_p, lev_ref, hyam, hybm, P0mb, PS, pmin, pint \
    , dimint, npint, work, vnew, klev_ref, cFill, ptmp, wcStrt
begin
  caseVarNames = getfilevarnames( fc )
  if (any(caseVarNames.eq."PINT")) then
      caseType = "isentropic"
  else
      caseType = "hybrid"
  end if

  if (.not.isdefined("caseType")) then
      print("=============================")
      print("caseLevel_to_refPresLevel: FATAL: caseType not defined")
      print("=============================")
      exit
  end if

  if (cdata@rank .ne. rdata@rank) then
      print("=============================")
      print("caseLevel_to_refPresLevel: FATAL: rank mismatch")
      print("=============================")
      exit
  end if
                                            ; ERA40 23 pressure (hPa) levels
  if (iscoord(rdata,"lev")) then
      levr  = rdata&lev
      if (typeof(levr).eq."integer") then
          lev_ref = levr*1.                 ; force float [convenience]
          copy_VarMeta(levr, lev_ref)
      else
          lev_ref = levr
      end if
      klev_ref = dimsizes( lev_ref)
  else
      print("=============================")
      print("caseLevel_to_refPresLevel: FATAL: no pressure level rdata")
      print("=============================")
      exit
  end if

  dimc = dimsizes(cdata)             
  if (isatt(cdata,"_FillValue")) then
      cFill = cdata@_FillValue
  else
      cFill = 1.e20
  end if

  PS   = fc->PS

  if (caseType.eq."hybrid") then
      hyam = fc->hyam 
      hybm = fc->hybm
      P0mb = 1000.                           ; reference pressure [mb]
      if (cdata@class.eq."scalar") then 
          vnew = vinth2p (cdata,hyam,hybm,lev_ref,PS,1,P0mb,1,False)
          copy_VarAtts(cdata, vnew)           ; contributd.ncl
          return( vnew)
      else
                        ; xy      time             lat     lon
          vnew = new ( (/dimc(0),dimc(1),klev_ref,dimc(3),dimc(4)/) \
                     , typeof(cdata), cFill)

          vnew(0,:,:,:,:) = vinth2p (cdata(0,:,:,:,:),hyam,hybm,lev_ref,PS,1,P0mb,1,False)
          vnew(1,:,:,:,:) =(/vinth2p(cdata(1,:,:,:,:),hyam,hybm,lev_ref,PS,1,P0mb,1,False)/)
      end if 

      return(vnew)
  end if

  if (caseType.eq."isentropic") then
      pint   = fc->PINT                        ; (time,lev,lat,lon)
      dimint = dimsizes( pint )
      npint  = dimint(1)
      if (isfilevar(fc, "PMID")) then
          pmid = fc->PMID   
      else
          pmid =  pint(:,0:npint-2,:,:)        ; keep meta data 
          pmid = (pint(:,0:npint-2,:,:) + pint(:,1:npint-1,:,:))*0.5
          pmid!1 = "lev"
          pmid&lev = (pint&ilev(0:npint-2) + pint&ilev(1:npint-1))*0.5 
          pmid@long_name = "Pressure at mid-level"
          pmid@units     = pint@units
      end if

      if (pint@units.eq."Pa") then
          pint = pint*0.01                     ; match reference units
          pmid = pmid*0.01
          pint@units = "hPa"
          pmid@units = "hPa"
      end if

      linlog = 1
      if (cdata@class.eq."scalar") then 
          work   = int2p( pmid(time|:,lat|:,lon|:,lev|:)  \
                        ,cdata(time|:,lat|:,lon|:,lev|:)  \
                        , lev_ref, linlog)
          work!0 = "time"
          work!1 = "lat"
          work!2 = "lon"
          work!3 = "lev"

          vnew   = work(time|:,lev|:,lat|:,lon|:)
          copy_VarAtts (cdata, vnew)              ; contributed.ncl

          vnew&time = cdata&time
          vnew&lev  = lev_ref    
          vnew&lat  = cdata&lat 
          vnew&lon  = cdata&lon
      else
          ptmp            = pmid(time|:,lat|:,lon|:,lev|:)
                        ; xy      time     lat     lon
          work = new ( (/dimc(0),dimc(1),dimc(2),dimc(3),klev_ref/) \
                     , typeof(cdata), cFill)
          
          work(0,:,:,:,:) = int2p(ptmp,cdata(xy|0,time|:,lat|:,lon|:,lev|:)  \
                                 ,lev_ref, linlog)
          work(1,:,:,:,:) = int2p(ptmp,cdata(xy|1,time|:,lat|:,lon|:,lev|:)  \
                                 ,lev_ref, linlog)
          work!0 = "xy"
          work!1 = "time"
          work!2 = "lat"
          work!3 = "lon"
          work!4 = "lev"

          vnew   = work(xy|:,time|:,lev|:,lat|:,lon|:)
          copy_VarAtts (cdata, vnew)              ; contributed.ncl

          vnew&xy   = cdata&xy
          vnew&time = cdata&time
          vnew&lev  = lev_ref    
          vnew&lat  = cdata&lat 
          vnew&lon  = cdata&lon
      end if
      return (vnew)
  end if
end

;==================================================
; parse the pressure level variable
; allows strings like "300:900"
;==================================================

function parsePlevel (PRES[*]:string)
local nVar, varP_chr, nChar, colon_chr, levP, icolon, nv
begin
    nVar            = dimsizes(PRES)

    if (nVar.gt.1) then
        varP_chr    = stringtochar( PRES )
    else                          ; SPECIAL CASE: force 2D
        nChar       = dimsizes( stringtochar( PRES ) )
        varP_chr    = new ( (/1,nChar/), "character")
        varP_chr(0,:) = stringtochar( PRES )
    end if

    colon_chr       = stringtochar( ":" )
    levP            = new ((/nVar,2/), "float")
    levP(:,0)       =    0.          ; top        top to bottom
    levP(:,1)       = 1100.          ; bottom
    levP@units      = "hPa"

    do nv=0,nVar-1
       if (any(varP_chr(nv,:).eq.colon_chr(0))) then
           icolon = ind(varP_chr(nv,:).eq. colon_chr(0))
           if (.not.ismissing(icolon)) then
               levP(nv,0) = stringtofloat(chartostring(varP_chr(nv,0:icolon-1)))
               levP(nv,1) = stringtofloat(chartostring(varP_chr(nv,icolon+1:)))

               if (levP(nv,0).gt.levP(nv,1)) then  ; reorder if necessary
                   tmpP = levP(nv,1)
                   levP(nv,1) = levP(nv,0)
                   levP(nv,0) = tmpP
               end if
           end if
           delete(icolon)
       else
           if (stringtofloat(PRES(nv)).ne.0) then
               levP(nv,0:1) = stringtofloat(PRES(nv))
           end if
       end if
    end do

    return(levP)
end

;==================================================
; Extract single Pressure level
;         scalar: x(time,lev,lat,lon) 
;         vector: x(xy,time,lev,lat,lon) 
;==================================================

undef("extractPresLvl")
function extractPresLvl (x:numeric, levP:numeric, nv:integer)            
; If specified: extract single Pressure level 
; INPUT:  scalar: x(time,lev,lat,lon) 
;         vector: x(xy,time,lev,lat,lon) 
; OUTPUT: scalar: x_P(time,lat,lon) 
;         vector: x_P(xy,time,lat,lon) 
begin
  if (levP(nv,1).gt.0 .and. levP(nv,0).eq.levP(nv,1)) then
      if (x@class.eq."scalar") then
          x_P    = x(:,{levP(nv,0)},:,:)   ; (time,lat,lon)
      else           ; must be vector
          x_P    = x(:,:,{levP(nv,0)},:,:) ; (xy,time,lat,lon)
      end if
    
      x_P@rank   = dimsizes( dimsizes(x_P) )
      return( x_P )
  else
      print("extractPresLvl: not sure how this got called")
      exit
  end if
end

;==================================================
; get wgted vertical average 
; Currently, this is a **place holder**
; Vertical avg of vector quantities **not** supported
;
; lev has the pressure levels but 
;     surface pressure is needed          
;==================================================

function getPresAvg ( x:numeric, f:list, fils:string,monsea:string, levP[2]  )
local dimx, rankx, xNew, lev, dp, k, klev
begin
   dimx  = dimsizes( x )
   rankx = dimsizes( dimx )

   levX  = x&lev
   if (isatt(levX,"units")) then
   if (levX@units .eq. "level") then   ; unusual unit!!!
           if (all(levX.lt.1100.)) then
               levX@units = "hPa"
           end if
           if (any(levX.gt.85000.)) then
               levX@units = "Pa"
           end if
       end if
   end if
       
   ipunit = 0     ;  (levX="hPa") or (levX,"mb") or (levX,"level")
   if (isatt(levX,"Pa") .or. any(levX.gt.85000)) then
       ipunit = 1
   end if
 
; The PS_ERA40 specific name may have to become an argument
; PS is Model/Case variable name

   f0 = addfile(fils(0),"r")
                                ; READ FULL CLIMATOLOGY (12,:,:)
   
   if (isfilevar(f0,"PS") ) then
          
     PS_MONTH = addfiles_GetVar(f,fils,"PS")              ; (time=12,lat,lon)
     PS_MONTH@class = "scalar"
     
     if (ipunit.eq.0 .and. PS_MONTH@units.eq."Pa") then
       PS_MONTH = PS_MONTH*0.01
       PS_MONTH@units = "hPa"
     end if 
     
     if (typeof(levP).eq."float" .or. typeof(levP).eq."double") then
       opt  = (/1, round(levP(0),3), round(levP(1),3) /)
     else 
       opt  = (/1, levP(0), levP(1) /)
     end if
     
     ;print("lev  ="+ x&lev)   ;-- hannay
     xNew = wgt_vert_avg_beta(x&lev, x, PS_MONTH, ipunit, opt)
     
     xNew@long_name = x@long_name
     xNew@units     = x@units
     xNew@wgt_vert_avg_beta = True
     xNew@class     = x@class
     xNew@rank      = dimsizes(dimsizes(xNew))
     xNew@flag      = True
     if (rankx.eq.3) then
       copy_VarCoords(x(0,:,:), xNew)
     else
       copy_VarCoords(x(:,0,:,:), xNew)
     end if
   else                                ; default to arithmetic average
     if (rankx.eq.3) then
       xNew = dim_avg_n_Wrap(x, 0)
     else
       xNew = dim_avg_n_Wrap(x, 1)
     end if
   end if
   
   delete(f0)

   return (xNew)
 end
 
;==================================================
; Create the variable labels for the Taylor plot
;==================================================

undef ("create_VAR_ID_PLOT")
function create_VAR_ID_PLOT (caseVarCompare:string \
                            ,levP, latS, latN, lonL, lonR, lsFlag, pLabel:string)
local VAR_ID_PLOT, latS_id, latN_id, lonL_id, lonR_id  
begin
  if (pLabel.eq."" .or. pLabel.eq." ") then
      VAR_ID_PLOT = caseVarCompare

      if (levP(0).eq.levP(1) .and. levP(0).ne.0) then
          VAR_ID_PLOT = VAR_ID_PLOT + "_"+levP(0)+"P"
      else      
          if (.not.(levP(0).eq.0 .and. levP(1).eq.1100)) then
              VAR_ID_PLOT = VAR_ID_PLOT + "_"+levP(0)+":"+levP(1)+"P"
          end if
      end if

      if (latS.ne.-90 .or. latN.ne. 90 .or. \ 
          lonL.ne.0   .or. lonR.ne.360 ) then 

          latS_id = "EQ"  
          if (latS.lt.0)
              latS_id = floattointeger(abs(latS)) + "S"  
          end if
          if (latS.gt.0)
              latS_id = floattointeger(abs(latS)) + "N"  
          end if

          latN_id = "EQ"  
          if (latN.lt.0)
              latN_id = floattointeger(abs(latN)) + "S"  
          end if
          if (latN.gt.0)
              latN_id = floattointeger(abs(latN)) + "N"  
          end if

          lonL_id = "0"
          if (lonL.gt.0)
              lonL_id = floattointeger(abs(lonL)) + "E"  
          end if
          if (lonL.lt.0)
              lonL_id = floattointeger(abs(lonL)) + "W"  
          end if

          lonR_id = "0"
          if (lonR.gt.0)
              lonR_id = floattointeger(abs(lonR)) + "E"  
          end if
          if (lonR.lt.0)
              lonR_id = floattointeger(abs(lonR)) + "W"  
          end if

          VAR_ID_PLOT = VAR_ID_PLOT+ "_"+latS_id+"_"+latN_id \
                                   + "_"+lonL_id+"_"+lonR_id
 
      end if

      if (lsFlag.ne.-1) then
          if (lsFlag.eq.0) then
                    VAR_ID_PLOT = VAR_ID_PLOT + "_ocn"
          end if
          if (lsFlag.eq.1) then
                    VAR_ID_PLOT = VAR_ID_PLOT + "_lnd"
          end if
      end if
  else
      VAR_ID_PLOT = pLabel
  end if

  return (VAR_ID_PLOT)
end

function s2c_2d (s[*]:string)
; function to ensure 2D character variable return 
; get around an NCL idiosyncrasy
; used in METRICS_NETCDF                         
begin                        
  s_c    = stringtochar( s )
  dims_c = dimsizes( s_c ) 
  rank   = dimsizes( dims_c ) 
  if (rank.eq.2) then        
      return( s_c)          
  end if                   
                          
  if (rank.eq.1) then    
      S_C = new ( (/1,dims_c(0)/) , "character", "No_FillValue")  
      S_C(0,:) = s_c       
      return( S_C )       
  end if                 
end     

undef ("require12_scalar")
procedure require12_scalar ( x[12][*][*]:numeric \
                           , y[12][*][*]:numeric )
; if all 12 values are not present, set all months to _FillValue
local xLLT, nMonth, m1d, i1d, i, dimi, ni, n
begin
  if (isatt(x,"_FillValue") .and. isatt(y,"_FillValue") ) then
      xLLT = x(lat|:,lon|:,time|:)
      nMonth = dim_num( .not.ismissing(xLLT) )    ; (lat,lon)
      if (any(nMonth.gt.0 .and. nMonth.lt.12)) then
          m1d = ndtooned( nMonth )
          i1d = ind(m1d.gt.0 .and. m1d.lt.12)
          i   = ind_resolve(i1d, dimsizes(nMonth) ) 
          dimi= dimsizes( i )
          ni  = dimi(0)
          do n=0,ni-1
             x(:,i(n,0),i(n,1)) = x@_FillValue
             y(:,i(n,0),i(n,1)) = y@_FillValue
          end do
      end if
  end if 
end

undef ("require12_vector")
procedure require12_vector ( x[2][12][*][*]:numeric \
                           , y[2][12][*][*]:numeric )
; if all 12 values are not present, set all months to _FillValue
local xLLT, nMonth, m1d, i1d, i, dimi, ni, n
begin
      ; only applicable if _FillValue present
  if (isatt(x,"_FillValue") .and. isatt(y,"_FillValue")) then 
      xLLT = x(xy|0,lat|:,lon|:,time|:)
      nMonth = dim_num( .not.ismissing(xLLT) )    ; (lat,lon)
      if (any(nMonth.gt.0 .and. nMonth.lt.12)) then
          m1d = ndtooned( nMonth )
          i1d = ind(m1d.gt.0 .and. m1d.lt.12)
          i   = ind_resolve(i1d, dimsizes(nMonth) ) 
          dimi= dimsizes( i )
          ni  = dimi(0)
          do n=0,ni-1
             x(:,:,i(n,0),i(n,1)) = x@_FillValue
             y(:,:,i(n,0),i(n,1)) = y@_FillValue
          end do
      end if
  end if 
end

undef ("require12")
procedure require12 ( rdata, cdata)
; temporal mask
begin
  if (rdata@class.eq."scalar" .and. cdata@class.eq."scalar") then
      require12_scalar(rdata, cdata)
      require12_scalar(cdata, rdata)
  else
      if (rdata@class.eq."vector" .and. cdata@class.eq."vector") then
          require12_vector(rdata, cdata)
          require12_vector(cdata, rdata)
      else
          print("++++++++++++++++++++++++++++++++++")
          print("require12: class conflict         ")
          print("++++++++++++++++++++++++++++++++++")
          exit
      end if
  end if
end
