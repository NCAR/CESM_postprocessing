;***************************************************************
; NCL script
; tables_soa.ncl
; Simone Tilmes Jan 2013
;***************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$DIAG_CODE/functions_contrib.ncl"
load "$DIAG_CODE/functions_surfaces.ncl"
load "$DIAG_CODE/functions_tables_chem.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
 re = 6.3712e6         ; radius of earth
 pi = 3.14159265
 grav = 9.81
 mw_dryair = 28.97e-3  ;kg/mole
 kboltz = 1.381e-23    ;J/K
 Rgas = 286.9969
 avog = 6.022e23       ;mole^-1

 wkdir      = getenv("WKDIR")
 compare    = getenv("COMPARE")
 season     = getenv("SEASON")  
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename

 region = (/"GLBL","TROP","NEXT","SEXT"/)

;vars=(/"POM","SOA","BC","DUST","SALT"/)
 vars=(/"POM","SOA","BC","DUST","SALT","SO4"/)
;vars=(/"POM","SOA"/)
 factor_bam = (/1.,1.,1.,1.,1.,32.066/96.06/)  ; SO4 in TgS
 factor_mam = (/1.,1.,1.,1.,1.,32.066/115.11/)  ; SO4 in TgS
 ivars = dimsizes(vars)
  mw_bam = (/12.001,144.132,12.011,12.011,12.011,96.06/)  ; chem mw (96.06 is from SO4, 115.11 is from NH4HSO4 (mam) 
  mw_mam = (/12.001,144.132,12.011,12.011,12.011,115.11/)  ; chem mw (96.06 is from SO4, 115.11 is from NH4HSO4 (mam) 
 nvars = 6*dimsizes(vars)+2   ; burden, emis, dry dep, wet dep, chem_loss, lifetime
 global  = new ((/nvars,3/),"float", -999)   ; global means,diff
 vars_all = new((/nvars/),"string")

 inptr1 = addfile(infile1,"r")       ; pointer to file1
 gw1=doubletofloat(inptr1->gw)

 lat1 = inptr1->lat
 nlat1 = dimsizes(lat1) 
 lon1 = inptr1->lon
 nlon1 = dimsizes(lon1) 
 lev1 = inptr1->lev
 nlev1 = dimsizes(lev1) 
 time1 = inptr1->time
 ntime1 = dimsizes(time1)
 ps1 = inptr1->PS
 t1 = inptr1->T
 ha1=doubletofloat(inptr1->hyai)
 hb1=doubletofloat(inptr1->hybi)
 ha11=doubletofloat(inptr1->hyam)
 hb11=doubletofloat(inptr1->hybm)
 p0=doubletofloat(inptr1->P0)
 p1 = pres_hybrid_ccm(ps1,p0,ha1,hb1)
 p11 = pres_hybrid_ccm(ps1,p0,ha11,hb11)
 rho1   = p11/(287.04*t1)

; Keep values for resetting after grid equalization computation for SST
 gw1_keep   = gw1
 lat1_keep  = lat1
 nlat1_keep = nlat1
 lon1_keep  = lon1
 nlon1_keep = nlon1

 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case         ; case names
 end if
 if (isatt(inptr1,"yrs_averaged")) then
   label1 = case1+" (yrs "+inptr1@yrs_averaged+")"
 else
   label1 = case1
 end if

 if (compare .eq. "OBS") then
 else
   inptr2 = addfile(infile2,"r")       ; pointer to infile2
   gw2=doubletofloat(inptr2->gw)
   lat2 = inptr2->lat
   nlat2 = dimsizes(lat2) 
   lon2 = inptr2->lon
   nlon2 = dimsizes(lon2) 
   lev2 = inptr2->lev
   nlev2 = dimsizes(lev2) 
   time2 = inptr2->time
   ntime2 = dimsizes(time2) 
   ps2 = inptr2->PS
   t2 = inptr2->T
   ha2=doubletofloat(inptr2->hyai)
   hb2=doubletofloat(inptr2->hybi)
   p2 = pres_hybrid_ccm(ps2,p0,ha2,hb2)
   ha21=doubletofloat(inptr2->hyam)
   hb21=doubletofloat(inptr2->hybm)
   p21 = pres_hybrid_ccm(ps2,p0,ha21,hb21)
  rho2   = p21/(287.04*t2)

; Keep values for resetting after grid equalization computation for SST
   gw2_keep   = gw2
   lat2_keep  = lat2
   nlat2_keep = nlat2
   lon2_keep  = lon2
   nlon2_keep = nlon2
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case
   end if
   if (isatt(inptr2,"yrs_averaged")) then
     label2 = case2+" (yrs "+inptr2@yrs_averaged+")"
   else
     label2 = case2
   end if
 end if
;****************************************************************
; For each variable in the list compute the fields 
; and then the difference between
; the fields
aer = new(2,"string")
  
 do i = 0, ivars-1
  vint1 = new((/ntime1,nlev1,nlat1,nlon1/),"float")
  vemis1 = new((/ntime1,nlat1,nlon1/),"float")
  vgas1 = new((/ntime1,nlat1,nlon1/),"float")
  chmp1 = new((/ntime1,nlev1,nlat1,nlon1/),"float")
  chml1 = new((/ntime1,nlev1,nlat1,nlon1/),"float")
  vdso41 = new((/ntime1,nlev1,nlat1,nlon1/),"float")
  ddf1 = new((/ntime1,nlat1,nlon1/),"float")
  dwf1 = new((/ntime1,nlat1,nlon1/),"float")
  vaqu1 = new((/ntime1,nlat1,nlon1/),"float")
  vnuc1 = new((/ntime1,nlat1,nlon1/),"float")
  if (compare .eq. "OBS") then
   nca = 1
  else
; CASE 2 MODEL
  vint2 = new((/ntime2,nlev2,nlat2,nlon2/),"float")
  vemis2 = new((/ntime2,nlat2,nlon2/),"float")
  vgas2 = new((/ntime2,nlat2,nlon2/),"float")
  chmp2 = new((/ntime2,nlev2,nlat2,nlon2/),"float")
  chml2 = new((/ntime2,nlev2,nlat2,nlon2/),"float")
  vdso42 = new((/ntime2,nlev2,nlat2,nlon2/),"float")
  ddf2 = new((/ntime2,nlat2,nlon2/),"float")
  dwf2 = new((/ntime2,nlat2,nlon2/),"float")
  vaqu2 = new((/ntime2,nlat2,nlon2/),"float")
  vnuc2 = new((/ntime2,nlat2,nlon2/),"float")
  nca = 2
  end if

 do ca = 0, nca-1   
  if ca.eq.0 then 
   inptr = inptr1 
   ntime = ntime1
   nlev = nlev1
   nlat = nlat1
   nlon = nlon1
   rho = rho1
  else 
   inptr = inptr2 
   ntime = ntime2
   nlev = nlev2
   nlat = nlat2
   nlon = nlon2
   rho = rho2
  end if
  vint11 = new((/ntime,nlev,nlat,nlon/),"float")
  vemis11 = new((/ntime,nlat,nlon/),"float")
  vemis11_a = new((/ntime,nlat,nlon/),"float")
  vemis11_b = new((/ntime,nlat,nlon/),"float")
  chmp11 = new((/ntime,nlev,nlat,nlon/),"float")
  chml11 = new((/ntime,nlev,nlat,nlon/),"float")
  vdso411 = new((/ntime,nlev,nlat,nlon/),"float")
  vgas11 = new((/ntime,nlat,nlon/),"float")
  vddep11 = new((/ntime,nlat,nlon/),"float")
  vwdep11 = new((/ntime,nlat,nlon/),"float")  ; OC
  vcddep11 = new((/ntime,nlat,nlon/),"float")
  vcwdep11 = new((/ntime,nlat,nlon/),"float")  ; OC
  vcaqa11 = new((/ntime,nlat,nlon/),"float")  ; OC
  vcaqb11 = new((/ntime,nlat,nlon/),"float")  ; OC
  vnuc11 = new((/ntime,nlat,nlon/),"float")  ; OC

 varsoa = -1
  if vars(i).eq."SOA" then
   ; function SOA Colette
   if (isfilevar(inptr,"SOAI") .and. isfilevar(inptr,"SOAT") .and. isfilevar(inptr,"SOAB") .and. isfilevar(inptr,"SOAX") .and. isfilevar(inptr,"SOAM")) then
     delete(varsoa)
     varsoa = (/"SOAI","SOAT","SOAB","SOAX","SOAM"/)
     mwsoa_c = (/60.0550,    84.077,    72.0660,    96.0880,   120.1100/)
     mwsoa = (/ 136.141400,   141.141800,   127.116000,   155.167600,   200.226000 /)
     aer(ca) = "bam"
   end if
   if (isfilevar(inptr,"soa_a1") .and. isfilevar(inptr,"soa_a2")) then
     delete(varsoa)
     varsoa =  (/"soa_a1","soa_a2"/)
     vara =  (/"soa_c1","soa_c2"/)
     aer(ca) = "mam3"
   end if
  end if
   if vars(i).eq."DUST" then
         if (isfilevar(inptr,"DST01") .and. isfilevar(inptr,"DST02") .and. isfilevar(inptr,"DST03") .and. isfilevar(inptr,"DST04")) then
           delete(varsoa)
          varsoa = (/"DST01","DST02","DST03","DST04"/)
          aer(ca) = "bam"
         else
          if (isfilevar(inptr,"dst_a1") .and. isfilevar(inptr,"dst_a3")) then
           delete(varsoa)
           varsoa = (/"dst_a1","dst_a3"/)
           vara = (/"dst_c1","dst_c3"/)
           aer(ca) = "mam3"
          end if
          if (isfilevar(inptr,"dst_a5") .and. isfilevar(inptr,"dst_a7")) then
           delete(varsoa)
           varsoa = (/"dst_a5","dst_a7"/)
           vara = (/"dst_c5","dst_c7"/)
           aer(ca) = "mam3"
          end if
         end if
   end if
   if vars(i).eq."SALT" then
         if (isfilevar(inptr,"SSLT01") .and. isfilevar(inptr,"SSLT02") .and. isfilevar(inptr,"SSLT03") .and. isfilevar(inptr,"SSLT04")) then
           delete(varsoa)
          varsoa = (/"SSLT01","SSLT02","SSLT03","SSLT04"/)
          aer(ca) = "bam"
         else
          if (isfilevar(inptr,"ncl_a1") .and. isfilevar(inptr,"ncl_a2") .and. isfilevar(inptr,"ncl_a3")) then
           delete(varsoa)
           varsoa = (/"ncl_a1","ncl_a2","ncl_a3"/)
           vara = (/"ncl_c1","ncl_c2","ncl_c3"/)
           aer(ca) = "mam3"
          end if
          if (isfilevar(inptr,"ncl_a4") .and. isfilevar(inptr,"ncl_a6")) then
           delete(varsoa)
           varsoa = (/"ncl_a1","ncl_a2","ncl_a4","ncl_a6"/)
           vara = (/"ncl_c1","ncl_c2","ncl_c4","ncl_c6"/)
           aer(ca) = "mam3"
          end if
         end if
   end if
   if vars(i).eq."POM" then
         if (isfilevar(inptr,"OC1") .and. isfilevar(inptr,"OC2")) then
           delete(varsoa)
          varsoa = (/"OC1","OC2"/)
          aer(ca) = "bam"
         else
          if (isfilevar(inptr,"pom_a1")) then
           delete(varsoa)
           varsoa = (/"pom_a1"/)
           vara = (/"pom_c1"/)
           aer(ca) = "mam3"
          end if
          if (isfilevar(inptr,"pom_a1") .and. isfilevar(inptr,"pom_a3")) then
           delete(vara)
           delete(varsoa)
           varsoa = (/"pom_a1","pom_a3"/)
           vara = (/"pom_c1","pom_c3"/)
           aer(ca) = "mam3"
          end if
          if (isfilevar(inptr,"pom_a1") .and. isfilevar(inptr,"pom_a4")) then
           delete(vara)
           delete(varsoa)
           varsoa = (/"pom_a1","pom_a4"/)
           vara = (/"pom_c1","pom_c4"/)
           aer(ca) = "mam3"
          end if
         end if
   end if
   if vars(i).eq."BC" then
         if (isfilevar(inptr,"CB1") .and. isfilevar(inptr,"CB2")) then
           delete(varsoa)
          varsoa = (/"CB1","CB2"/)
          aer(ca) = "bam"
         else
          if (isfilevar(inptr,"bc_a1")) then
           delete(varsoa)
           varsoa = (/"bc_a1"/)
           vara = (/"bc_c1"/)
           aer(ca) = "mam3"
          end if
          if (isfilevar(inptr,"bc_a1") .and. isfilevar(inptr,"bc_a3")) then
           delete(vara)
           delete(varsoa)
           varsoa = (/"bc_a1","bc_a3"/)
           vara = (/"bc_c1","bc_c3"/)
           aer(ca) = "mam3"
          end if
          if (isfilevar(inptr,"bc_a1") .and. isfilevar(inptr,"bc_a4")) then
           delete(varsoa)
           delete(vara)
           varsoa = (/"bc_a1","bc_a4"/)
           vara = (/"bc_c1","bc_c4"/)
           aer(ca) = "mam3"
          end if

         end if
   end if
   if vars(i).eq."SO4" then
         if (isfilevar(inptr,"SO4") ) then
           delete(varsoa)
          varsoa = (/"SO4"/)
          aer(ca) = "bam"
         else
          if (isfilevar(inptr1,"so4_a1") .and. isfilevar(inptr1,"so4_a2") .and. isfilevar(inptr1,"so4_a3") )  then 
           delete(varsoa)
           varsoa = (/"so4_a1","so4_a2","so4_a3"/)
           vara = (/"so4_c1","so4_c2","so4_c3"/)
           aer(ca) = "mam3"
          end if
          if (isfilevar(inptr1,"so4_a1") .and. isfilevar(inptr1,"so4_a2") .and. isfilevar(inptr1,"so4_a4") .and. isfilevar(inptr1,"so4_a5") .and. isfilevar(inptr1,"so4_a6") .and. isfilevar(inptr1,"so4_a7") )  then 
           delete(varsoa)
           varsoa = (/"so4_a1","so4_a2","so4_a4","so4_a5","so4_a6","so4_a7"/)
           vara = (/"so4_c1","so4_c2","so4_c4","so4_c5","so4_c6","so4_c7"/)
           aer(ca) = "mam3"
          end if
         end if
  end if

 if varsoa(0).ne.-1 then
   nvarsoa = dimsizes(varsoa)
   do si = 0, nvarsoa-1
      vinta = varsoa(si)       ; kg/kg
      vemis_b =vinta+"_CLXF"      ; elevated emission
      vemis_a="SF"+vinta          ; surface emission  kg/m2/s
      vgas =vinta+"_sfgaex1"      ; chemical production of SOA,( SO4 CAM5 )
      vloss =vinta+"_CHML"       ; chem loss of molec/molec/s 
      if aer(ca).eq."bam" then 
       vddep="DF_"+vinta          ; dry depostion flux  kg/m2/s 
       vwdep=vinta+"SFWET"         ; surface wet deposition kg/m2/s 
      else
       vcba = vara(si)
       vcddep =vcba+"DDF"      ; elevated emission
       vcwdep =vcba+"SFWET"      ; elevated emission
       vddep =vinta+"DDF"      ; elevated emission
       vwdep =vinta+"SFWET"      ; elevated emission
      end if
      if vars(i).eq."SOA" .and. (isfilevar(inptr,"SOAI") .and. isfilevar(inptr,"SOAT") .and. isfilevar(inptr,"SOAB") .and. isfilevar(inptr,"SOAX") .and. isfilevar(inptr,"SOAM")) then
        vprod =vinta+"_PROD"      ; production of SOA molec/molec/s 
      else
         vprod =vinta+"_CHMP"     
      end if
  ; variables in CAM5
      vcaqa="AQSO4_H2O2"
      vcaqb="AQSO4_O3"
      vnuc=vinta+"_sfnnuc1"
  ; varibles in CAM4
      vdso4 = "DSO4CHM"
      
      if aer(ca).eq."bam" then 
        mw = mw_bam
      else
        mw = mw_mam
      end if
 
      if (isfilevar(inptr,vinta)) then
        if vars(i).eq."SOA" .and. (isfilevar(inptr,"SOAI") .and. isfilevar(inptr,"SOAT") .and. isfilevar(inptr,"SOAB") .and. isfilevar(inptr,"SOAX") .and. isfilevar(inptr,"SOAM")) then
          vint11=inptr->$vinta$*mwsoa_c(si)/mwsoa(si)
       ;  vint11=inptr->$vinta$
        else
          vint11=inptr->$vinta$
        end if
      else
        vint11(:,:,:,:) = 0.
      end if 
      if (isfilevar(inptr,vgas)) then
          vgas11=inptr->$vgas$   ; kg/kg
         else
          vgas11(:,:,:)=0.
      end if
      if (isfilevar(inptr,vprod)) then
        chmp11=inptr->$vprod$
     ;  chmp11=chmp11* ( mwsoa(si)*1.e-3/6.022e23 )   ;chml_spec KG/M^2/S   ;mw*1.e3 kg/mol ; avog (mol^-1)
        if  vars(i).eq."SOA" .and. (isfilevar(inptr,"SOAI_PROD") .and. isfilevar(inptr,"SOAT_PROD") .and. isfilevar(inptr,"SOAB_PROD") .and. isfilevar(inptr,"SOAX_PROD") .and. isfilevar(inptr,"SOAM_PROD")) then
         chmp11=chmp11*mwsoa_c(si)/mw_dryair/rho*1.e-03   ;chml_spec transform to kg/m2/s    ; production of SOA molec/molec/s
        else
         chmp11=chmp11* ( mw(i)*1.e+3/6.022e23 )/rho   ; from /cm3/s to  KG/M^2/S   ;mw*1.e3 kg/mol ; avog (mol^-1)
        end if
      else
        chmp11(:,:,:,:) = 0.
      end if
      if (isfilevar(inptr,vloss)) then
        chml11=inptr->$vloss$
        chml11=chml11* ( mw(i)*1.e+3/6.022e23 )/rho   ; from /cm3/s to  KG/M^2/S   ;mw*1.e3 kg/mol ; avog (mol^-1)
      else
        chml11(:,:,:,:) = 0.
      end if
      if (isfilevar(inptr,vemis_a)) then
        vemis11_a=inptr->$vemis_a$
         if (vars(i).eq."SOA" .and. (isfilevar(inptr,"SOAI") .and. isfilevar(inptr,"SOAT") .and. isfilevar(inptr,"SOAB") .and. isfilevar(inptr,"SOAX") .and. isfilevar(inptr,"SOAM"))) then
          vemis11_a = vemis11_a*mwsoa_c(si)/mwsoa(si)   
         end if
      else
        vemis11_a(:,:,:) = 0.
      end if 
      if (isfilevar(inptr,vemis_b)) then
          vemis11_b=inptr->$vemis_b$   
           vemis11_b = vemis11_b/6.02e+23*mw(i)*1.e+1
         else
          vemis11_b(:,:,:)=0.
      end if
      vemis11=vemis11_a+vemis11_b

      if (isfilevar(inptr,vddep)) then
        vddep11=inptr->$vddep$
        if  vars(i).eq."SOA" .and. (isfilevar(inptr,"SOAI") .and. isfilevar(inptr,"SOAT") .and. isfilevar(inptr,"SOAB") .and. isfilevar(inptr,"SOAX") .and. isfilevar(inptr,"SOAM")) then
          vddep11 = vddep11*mwsoa_c(si)/mwsoa(si)   
        end if 
      else
        vddep11(:,:,:) = 0.
      end if
     if aer(ca).eq."mam3" then
      if (isfilevar(inptr,vcddep)) then
        vcddep11=inptr->$vcddep$
      else
        vcddep11(:,:,:) = 0.
      end if
     else
        vcddep11(:,:,:) = 0.
     end if
      

       if (isfilevar(inptr,vwdep)) then
        vwdep11=inptr->$vwdep$
        if vars(i).eq."SOA" .and. (isfilevar(inptr,"SOAI") .and. isfilevar(inptr,"SOAT") .and. isfilevar(inptr,"SOAB") .and. isfilevar(inptr,"SOAX") .and. isfilevar(inptr,"SOAM")) then
          vwdep11 = vwdep11*mwsoa_c(si)/mwsoa(si)
        end if
      else
        vwdep11(:,:,:) = 0.
      end if
    if aer(ca).eq."mam3" then
     if (isfilevar(inptr,vcwdep)) then
        vcwdep11=inptr->$vcwdep$
      else
        vcwdep11(:,:,:) = 0.
      end if
     else
        vcwdep11(:,:,:) = 0.
     end if

      if (isfilevar(inptr,vcaqa)) then
        vcaqa11=inptr->$vcaqa$
      else
        vcaqa11(:,:,:) = 0.
      end if
      if (isfilevar(inptr,vcaqb)) then
        vcaqb11=inptr->$vcaqb$
      else
        vcaqb11(:,:,:) = 0.
      end if
      if (isfilevar(inptr,vnuc)) then
        vnuc11=inptr->$vnuc$
      else
        vnuc11(:,:,:) = 0.
      end if
      if (isfilevar(inptr,vdso4)) then
        vdso411=inptr->$vdso4$
      else
        vdso411(:,:,:,:) = 0.
      end if
     if ca.eq.0 then 
      vcaqb1 = vcaqb11
      vcaqa1 = vcaqa11
      vdso41 = vdso411
      vaqu1 = vcaqa1 + vcaqb1
      if si.eq.0 then 
        vint1 = (/vint11/)
        chmp1 = (/chmp11/)
        chml1 = (/chml11/)
        vgas1 = (/vgas11/)
        vemis1 = (/vemis11/)
        ddf1 = vddep11+vcddep11
        dwf1 = vwdep11+vcwdep11
        vnuc1 = vnuc11
      else
        vint1 = vint1 + vint11
        chmp1 = chmp1 + chmp11
        chml1 = chml1 + chml11
        vgas1 = vgas1 + vgas11
        vemis1 = vemis1 + vemis11
        ddf1 = ddf1 + vddep11 + vcddep11
        dwf1 = dwf1 + vwdep11 + vcwdep11
        vnuc1 = vnuc1 + vnuc11
      end if 
     else
      vcaqb2 = vcaqb11
      vcaqa2 = vcaqa11
      vdso42 = vdso411
      vaqu2 = vcaqa2 + vcaqb2
      if si.eq.0 then 
        vint2 = (/vint11/)
        chmp2 = chmp11
        chml2 = chml11
        vgas2 = vgas11
        vemis2 = vemis11
        ddf2 = vddep11+vcddep11
        dwf2 = vwdep11+vcwdep11
        vnuc2 = vnuc11
      else
        vint2 = vint2 + vint11
        chmp2 = chmp2 + chmp11
        chml2 = chml2 + chml11
        vgas2 = vgas2 + vgas11
        vemis2 = vemis2 + vemis11
        ddf2 = ddf2 + vddep11 + vcddep11
        dwf2 = dwf2 + vwdep11 + vcwdep11
        vnuc2 = vnuc2 + vnuc11
      end if 
     end if 
     end do
   if aer(ca).eq."mam3" then 
      delete(vara)
   end if
  end if
        delete(vint11)                                          
        delete(vemis11)                                         
        delete(vemis11_a)                                          
        delete(vemis11_b)                                          
        delete(chmp11)                                          
        delete(chml11)                                          
        delete(vgas11)                                          
        delete(vddep11)                                         
        delete(vwdep11)                                          
        delete(vcddep11)                                         
        delete(vcwdep11)                                          
        delete(vcaqa11)                                          
        delete(vcaqb11)                                          
        delete(vnuc11)                                          
        delete(vdso411)                                          
   delete(varsoa)
   delete(rho)
 end do ;ncases
    if aer(0).eq."bam" then 
         factor1 =factor_bam 
    else
          factor1 = factor_mam
    end if
   if nca.eq.2 then
    if aer(1).eq."bam" then 
         factor2 =factor_bam 
    else
          factor2 = factor_mam
    end if
   end if



 

; CASE 1 MODEL
  delp1=vint1
  ddd1=dimsizes(delp1)
  do k=0,ddd1(1)-1
     delp1(:,k,:,:)=p1(:,k+1,:,:)-p1(:,k,:,:)
  end do
; delp11=delp1
; delp11d = ndtooned(delp1)
; p11d = ndtooned(p11)
; help11d = where(p11d.lt.20000.,0.,delp11d) 
; delp1 = onedtond(delp11d, dimsizes(delp11))
  
  vint1=vint1*delp1/grav 
  bvar1=dim_sum_n_Wrap(vint1,1)
  chmp1=chmp1*delp1/grav
  chml1=chml1*delp1/grav
; vdso41=vdso41*delp1/grav  ; check units!

  bchmp1=dim_sum_n_Wrap(chmp1,1)
  bchml1=dim_sum_n_Wrap(chml1,1)
  bvdso41=dim_sum_n_Wrap(vdso41,1)

  coo1=new((/ddd1(2)/),float)
  do ii=0, ddd1(2)-1
   coo1(ii) = gw1(ii)*(2.*pi/nlon1)*re^2.
  end do
  do ii=0,ddd1(2)-1
   bvar1(:,ii,:)=bvar1(:,ii,:)*coo1(ii)
   bchmp1(:,ii,:)=bchmp1(:,ii,:)*coo1(ii)
   bchml1(:,ii,:)=bchml1(:,ii,:)*coo1(ii)
;  bvdso41(:,ii,:)=bvdso41(:,ii,:)*coo1(ii)
   vemis1(:,ii,:)=vemis1(:,ii,:)*coo1(ii)
   vgas1(:,ii,:)=vgas1(:,ii,:)*coo1(ii)
   ddf1(:,ii,:)=ddf1(:,ii,:)*coo1(ii)
   dwf1(:,ii,:)=dwf1(:,ii,:)*coo1(ii)
   vaqu1(:,ii,:)=vaqu1(:,ii,:)*coo1(ii)
   vnuc1(:,ii,:)=vnuc1(:,ii,:)*coo1(ii)
  end do
  baqu_der1 = bvdso41 - (bchmp1 - bchml1)   
  bprod1 = bchmp1+vaqu1+vnuc1+vgas1

  tbvar1 = sum(bvar1)*1e-09*factor1(i)
  tbchmp1 = sum(bchmp1)*86400.*365.*1.e-09*factor1(i)
  tbchml1 = sum(bchml1)*86400.*365.*1.e-09*factor1(i)
  tbprod1 = sum(bprod1)*86400.*365.*1.e-09*factor1(i)
  tbvdso41 = sum(bvdso41)*86400.*365.*1.e-09*factor1(i)
  tbaqu_der1 = sum(baqu_der1)*86400.*365.*1.e-09*factor1(i)
  tbvgas1 = sum(vgas1)*86400.*365.*1.e-09*factor1(i)
  tbaqu1 = sum(vaqu1)*86400.*365.*1.e-09*factor1(i)
  tbnuc1 = sum(vnuc1)*86400.*365.*1.e-09*factor1(i)
  temis1 = sum(vemis1)*86400.*365.*1.e-9 *factor1(i)
  tddf1 = sum(ddf1)*86400.*365.*1e-9*factor1(i)
  tdwf1 = sum(dwf1)*86400.*365.*1e-9*factor1(i)
  lifet1 = tbvar1

 
 if vars(i).eq."POM" .or. vars(i).eq."BC" .or. vars(i).eq."DUST" .or. vars(i).eq."SALT"  then
  if (all(ismissing(tddf1)) .or. all(ismissing(tddf1))) then
      lifet1=0. 
    else
     if (tddf1-tdwf1).gt.0. then
       lifet1 = tbvar1/(tddf1-tdwf1)*365.
     else
      lifet1=0. 
     end if
  end if
 end if
 if vars(i).eq."SOM" .or. vars(i).eq."SO4" then
;if (tbchmp1.gt.0 .and. tddf1.gt.0 .and. tdwf1.lt.0) then
 if (tddf1.gt.0 .and. tdwf1.lt.0) then
   ; lifet1 = tbvar1/(tbchmp1+tddf1-tdwf1+tbaqu1+tbnuc1)*365
     lifet1 = tbvar1/(tddf1-tdwf1)*365
    else
      lifet1=0. 
  end if
 end if
   if aer(0).eq."mam3" then 
     tbchmp1 = tbvgas1
     tbprod1 = tbprod1
     tbaqu1 = tbaqu1
   else 
     tbchmp1 = tbchmp1 
     tbprod1 = tbvdso41 - tbchml1
     tbaqu1 = tbaqu_der1 
   end if

 if (compare .ne. "OBS") then
; CASE 2 MODEL
  vaqu2 = vcaqa2 + vcaqb2
  delp2=(/vint2/)
  ddd2=dimsizes(delp2)
  do k=0,ddd2(1)-1
     delp2(:,k,:,:)=p2(:,k+1,:,:)-p2(:,k,:,:)
  end do

  vint2=vint2*delp2/grav
  bvar2=dim_sum_n_Wrap(vint2,1)
  chmp2=chmp2*delp2/grav
  chml2=chml2*delp2/grav
  bchmp2=dim_sum_n_Wrap(chmp2,1)
  bchml2=(/dim_sum_n_Wrap(chml2,1)/)
  bvdso42=dim_sum_n_Wrap(vdso42,1)
  delete(chmp2)
  delete(chml2)

  coo2=new((/ddd2(2)/),float)
  do ii=0, ddd2(2)-1
   coo2(ii) = gw2(ii)*(2.*pi/ddd2(3))*re^2.
  end do
  do ii=0,ddd2(2)-1
   bvar2(:,ii,:)=bvar2(:,ii,:)*coo2(ii)
   bchmp2(:,ii,:)=bchmp2(:,ii,:)*coo2(ii)
   bchml2(:,ii,:)=bchml2(:,ii,:)*coo2(ii)
;  bvdso42(:,ii,:)=bvdso42(:,ii,:)*coo2(ii)
   vemis2(:,ii,:)=vemis2(:,ii,:)*coo2(ii)
   ddf2(:,ii,:)=ddf2(:,ii,:)*coo2(ii)
   dwf2(:,ii,:)=dwf2(:,ii,:)*coo2(ii)
   vaqu2(:,ii,:)=vaqu2(:,ii,:)*coo2(ii)
   vnuc2(:,ii,:)=vnuc2(:,ii,:)*coo2(ii)
  end do

   bprod2 = bchmp2+vaqu2+vnuc2+vgas2

   tbvar2 = sum(bvar2)*1e-09*factor2(i)
   tbvgas2 = sum(vgas2)*86400.*365.*1.e-09*factor2(i)
   tbchmp2 = sum(bchmp2)*86400.*365.*1.e-09*factor2(i)
   tbchml2 = sum(bchml2)*86400.*365.*1.e-09*factor2(i)
   tbprod2 = sum(bprod2)*86400.*365.*1.e-09*factor2(i)
   tbvdso42 = sum(bvdso42)*86400.*365.*1.e-09*factor2(i)
   temis2 = sum(vemis2)*86400.*365.*1e-9*factor2(i)
   tddf2 = sum(ddf2)*86400.*365.*1e-9*factor2(i)
   tdwf2 = sum(dwf2)*86400.*365.*1e-9*factor2(i)
;  tbaqu_der2 = sum(baqu_der2)*86400.*365.*1.e-09*factor2(i)
   tbaqu2 = sum(vaqu2)*86400.*365.*1.e-09*factor2(i)
   tbnuc2 = sum(vnuc2)*86400.*365.*1.e-09*factor2(i)
   lifet2 = tbvar2

   tbaqu_der2 = tbvdso42 - (tbchmp2 - tbchml2)   

   delete(vgas2)

  if vars(i).eq."POM" .or. vars(i).eq."BC" .or. vars(i).eq."DUST" .or. vars(i).eq."SALT"  then
   if (all(ismissing(tddf2)) .or. all(ismissing(tdwf2))) then
      lifet2=0. 
    else
     if (tddf2.gt.0 .and. tdwf2.lt.0) then
        lifet2 = tbvar2/(tddf2-tdwf2)*365.
     else
      lifet2=0. 
     end if
   end if
  end if 
  if vars(i).eq."SOM" .or. vars(i).eq."SO4" then
   lifet2 = tbvar2
   if (all(ismissing(tbchmp2)) .or. all(ismissing(tddf2)) .or. all(ismissing(tdwf2))) then
      lifet2=0. 
   else
     lifet2 = tbvar2/(tbchmp2+tddf2-tdwf2 + tbaqu2+tbnuc2)*365.
   end if 
  end if
 
   if aer(1).eq."mam3" then 
     tbchmp2 = tbvgas2
     tbprod2 = tbprod2
     tbaqu2 = tbaqu2
   else 
     tbchmp2 = tbchmp2 
     tbprod2 = tbvdso42 - tbchml2
     tbaqu2 = tbaqu_der2 
   end if
 end if
;--------------------------------------------------------------------
; AT THIS POINT WE HAVE A AND B
; GLOBAL MEANS AND DIFFERENCES

 if i.ne.5 then 
  vars_all(i*6) = vars(i)+"_BURDEN (TgC)"
  vars_all(i*6+1) = vars(i)+"_EMIS (TgC/yr)"
  vars_all(i*6+2) = vars(i)+"_DRYDEP (TgC/yr)"
  vars_all(i*6+3) = vars(i)+"_WETDEP (TgC/yr)"
  vars_all(i*6+4) = vars(i)+"_CHMP (TgC/yr)"
  vars_all(i*6+5) = vars(i)+"_LIFETIME (days)"
; i over variable
   global(i*6 ,0) = tbvar1   ; case1
   global(i*6 + 1,0) =  temis1    ; case1
   global(i*6 + 2,0) =  tddf1    ; case1
   global(i*6 + 3,0) =  tdwf1    ; case1
   global(i*6 + 4,0) =  tbchmp1    ; case1
   global(i*6 + 5,0) = lifet1    ; case1
 if (compare .ne. "OBS") then
   global(i*6 ,1) = tbvar2   ; case1
   global(i*6 + 1,1) =  temis2    ; case1
   global(i*6 + 2,1) =  tddf2    ; case1
   global(i*6 + 3,1) =  tdwf2    ; case1
   global(i*6 + 4,1) =  tbchmp2    ; case1
   global(i*6 + 5,1) = lifet2    ; case1
  end if
 else
  vars_all(i*6) = vars(i)+"_BURDEN (TgS)"
  vars_all(i*6+1) = vars(i)+"_EMIS (TgS/yr)"
  vars_all(i*6+2) = vars(i)+"_DRYDEP (TgS/yr)"
  vars_all(i*6+3) = vars(i)+"_WETDEP (TgS/yr)"
  vars_all(i*6+4) = vars(i)+"_CHMP (TgS/yr)"
  vars_all(i*6+5) = vars(i)+"_AQ_PROD (TgS/yr)"
  vars_all(i*6+6) = vars(i)+"_TOTAL_PROD (TgS/yr)"
  vars_all(i*6+7) = vars(i)+"_LIFETIME (days)"
   global(i*6 ,0) = tbvar1   ; case1
   global(i*6 + 1,0) =  temis1    ; case1
   global(i*6 + 2,0) =  tddf1    ; case1
   global(i*6 + 3,0) =  tdwf1    ; case1
   global(i*6 + 4,0) =  tbchmp1    ; case1
   global(i*6 + 5,0) =  tbaqu1 ; case1
   global(i*6 + 6,0) =  tbprod1 ; case1
   global(i*6 + 7,0) = lifet1    ; case1
  if (compare .ne. "OBS") then
   global(i*6 ,1) = tbvar2   ; case1
   global(i*6 + 1,1) =  temis2    ; case1
   global(i*6 + 2,1) =  tddf2    ; case1
   global(i*6 + 3,1) =  tdwf2    ; case1
   global(i*6 + 4,1) =  tbchmp2    ; case1
   global(i*6 + 5,1) =  tbaqu2 ; case1
   global(i*6 + 6,1) =  tbprod2 ; case1
   global(i*6 + 7,1) = lifet2    ; case1
  end if
 end if

  if (compare .ne. "OBS") then
   global(i*6,2) = global(6*i,0) - global(6*i,1)           ; diff
   global(i*6+1,2) = global(6*i+1,0) - global(6*i+1,1)           ; diff
   global(i*6+2,2) = global(6*i+2,0) - global(6*i+2,1)           ; diff
   global(i*6+3,2) = global(6*i+3,0) - global(6*i+3,1)           ; diff
   global(i*6+4,2) = global(6*i+4,0) - global(6*i+4,1)           ; diff
   global(i*6+5,2) = global(6*i+5,0) - global(6*i+5,1)           ; diff
  if i.eq.5 then 
   global(i*6+6,2) = global(6*i+6,0) - global(6*i+6,1)           ; diff
   global(i*6+7,2) = global(6*i+7,0) - global(6*i+7,1)           ; diff
  end if
  else
   global(i*6,2) = 0.           ; diff
   global(i*6+1,2) = 0.         ; diff
   global(i*6+2,2) = 0.         ; diff
   global(i*6+3,2) = 0.         ; diff
   global(i*6+4,2) = 0.         ; diff
   global(i*6+5,2) = 0.         ; diff
  if i.eq.5 then 
   global(i*6+6,2) = 0.         ; diff
   global(i*6+7,2) = 0.         ; diff
  end if
 end if



 delete(bvar1)
 delete(vemis1)
 delete(ddf1)
 delete(dwf1)
 delete(bchmp1)
 delete(tbchmp1)
 delete(lifet1)
 delete(tbvar1)
 delete(temis1)
 delete(tddf1)
 delete(tdwf1)
 delete(vaqu1)

if (compare .eq. "OBS") then
 else
 delete(bvar2)
 delete(vemis2)
 delete(ddf2)
 delete(dwf2)
 delete(bchmp2)
 delete(tbchmp2)
 delete(lifet2)
 delete(tbvar2)
 delete(temis2)
 delete(tddf2)
 delete(tdwf2)
 delete(vaqu2)
end if

end do     


; PRINTT THE TABLES
  tablename = wkdir+"table_soa_"+season+".asc"
  if (compare .eq. "OBS") then
    label2 = ""
    case2 = ""
    title = (/"DIAG SET1 Aerosol: "+season+" MEANS GLOBAL < 200hPa"/)
    make_table_chem(case1,label1,case2,label2,vars_all,global,title,tablename)
  else
    title = (/"DIAG SET1 Aerosol: "+season+" MEANS GLOBAL < 200hPa"/)
    make_table_chem(case1,label1,case2,label2,vars_all,global,title,tablename)
  end if
end
