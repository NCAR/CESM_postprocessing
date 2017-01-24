;***************************************************************
; NCL script
; tables.ncl
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
;rho    = p/(287.04*t)

 wkdir      = getenv("WKDIR")
 compare    = getenv("COMPARE")
 season     = getenv("SEASON")  
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input filename

 region = (/"GLBL","TROP","NEXT","SEXT"/)

 vars = (/"CH4","CH3CCL3","CO","O3","ISOP","C10H16","CH3OH","CH3COCH3"/)
 factor = (/1.,1.,1.,1.,1.,1.,1.,1./)
 ivars = dimsizes(vars)
 mw = (/16.,133.4042, 28.,48.,68.,136.,32.,58./)
 nvars = 5*(dimsizes(vars)-2) +1   ; burden, emis, tdep, chem_loss per, lifetime, variable plus lno_prod
 global  = new ((/nvars,3/),"float", -999)   ; global means,diff
 global = 0.
 vars_all = new((/nvars/),"string")

 do i = 0, 3
  vars_all(i*5) = vars(i)+"_BURDEN (Tg)"
  vars_all(i*5+1) = vars(i)+"_EMIS (Tg/yr)"
  vars_all(i*5+2) = vars(i)+"_TDEP (Tg/yr)"
  vars_all(i*5+3) = vars(i)+"_CHEM_LOSS (Tg/yr)"
  vars_all(i*5+4) = vars(i)+"_LIFETIME (yr)"
 end do 
 vars_all(i*5) = "O3_CHEM Prod (Tg/yr)"
 vars_all(i*5+1) = "O3_NET_CHEM_CHANGE (Tg/yr)"
 vars_all(i*5+2) = "O3_STE (Tg/yr)"
 vars_all(i*5+3) = "O3 Strat BURDEN (Tg/yr)"
 vars_all(i*5+4) = "ISOP_EMIS (Tg/yr)"
 vars_all(i*5+5) = "Monoterpene_EMIS (Tg/yr)"
 vars_all(i*5+6) = "Methanol_EMIS (Tg/yr)"
 vars_all(i*5+7) = "Aceton_EMIS (Tg/yr)"
 vars_all(i*5+8) = "LNO_PROD (TgN/yr)"
 vars_all(i*5+9) = "Total optical depth"
 vars_all(i*5+10) = "DUST optical depth"

 ;1. Tune down dust emission so that dust optical thickness is between 0.025 and 0.03 ODV_DST0* (I chose 0.028).  (2.3 tuning factor for MERRA CAM5)
 ;2. Tune down sea salt emission so that total aerosol optical thickness is 0.135 (AERO_v).  (0.9 tuning factor for MERRA CAM5)
 ; (dust_emis_fact         = 2.30D0)
 ;3.  Surface moisture flux is multiplied by a scale factor of 0.86.


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
	if (isfilevar(inptr1,"LNO_COL_PROD")) then
	lno_col1 = inptr1->LNO_COL_PROD
	else 
	lno_col1 = new((/ntime1,nlat1,nlon1/),"float")
	lno_col1 = 0.
	end if
	if (isfilevar(inptr1,"DO3CHM")) then
	o3chm1 =inptr1->DO3CHM
	else
	o3chm1 = new((/ntime1,nlev1,nlat1,nlon1/),"float")
	o3chm1 = 0.
	end if 
	if (isfilevar(inptr1,"DCOCHM")) then
	cochm1 =inptr1->DCOCHM
	else
	cochm1 = new((/ntime1,nlev1,nlat1,nlon1/),"float")
	cochm1 = 0.
	end if 

	aerod1 = new((/ntime1,nlat1,nlon1/),"float")
	if (isfilevar(inptr1, "AODVIS"))
	aerod1  = inptr1->AODVIS
	else
	aerod1 = 0.
	end if
	dst11 = aerod1
	dst11 = 0.
	if (isfilevar(inptr1, "ODV_DST01").and.isfilevar(inptr1, "ODV_DST02").and.isfilevar(inptr1, "ODV_DST03").and.isfilevar(inptr1, "ODV_DST04"))
	dst1 = inptr1->ODV_DST01
	dst2 = inptr1->ODV_DST02
	dst3 = inptr1->ODV_DST03
	dst4 = inptr1->ODV_DST04
	dst11 = dst1+dst2+dst3+dst4
	delete(dst3)
	delete(dst4)
	delete(dst1)
        delete(dst2)
	end if
	if (isfilevar(inptr1, "AODDUST1").and.isfilevar(inptr1, "AODDUST2").and.isfilevar(inptr1, "AODDUST3"))
	dst1 = inptr1->AODDUST1
	dst2 = inptr1->AODDUST2
	dst3 = inptr1->AODDUST3
	dst11 = dst1+dst2+dst3
	delete(dst1)
	delete(dst2)
        delete(dst3)
        else
	 if (isfilevar(inptr1, "AODDUST"))
	 dst1 = inptr1->AODDUST
	 dst11 = dst1
	 delete(dst1)
	 end if 
	end if 
        dlon1=360./nlon1
        coffa=pi*re^2./180.
        area1 = aerod1
        area1 = 1.
        area1 = area1 + aerod1*0.
        do ii=0,dimsizes(gw1)-1
          aerod1(:,ii,:)=aerod1(:,ii,:)*coffa*dlon1*gw1(ii)
          dst11(:,ii,:)=dst11(:,ii,:)*coffa*dlon1*gw1(ii)
          area1(:,ii,:)=area1(:,ii,:)*coffa*dlon1*gw1(ii)
        end do
        taerod1 = sum(aerod1)/sum(area1)
        tdst11 = sum(dst11)/sum(area1)
        delete(area1)

	ps1 = inptr1->PS
	if (isfilevar(inptr1,"O3")) then
	o3flag1 = 1
	o311 = inptr1->O3
	o311 = o311*1.e+09
	else 
	o3flag1 = 0
	end if
	ha1=doubletofloat(inptr1->hyai)
	hb1=doubletofloat(inptr1->hybi)
	ha11=doubletofloat(inptr1->hyam)
	hb11=doubletofloat(inptr1->hybm)
	p0=doubletofloat(inptr1->P0)
	p1 = pres_hybrid_ccm(ps1,p0,ha1,hb1)
        p11 = pres_hybrid_ccm(ps1,p0,ha11,hb11)
        t1 = inptr1->T
        rho1 = p11/(287.04*t1)   ; ;cm-3

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
	lno_col2 = new((/ntime2,nlat2,nlon2/),"float")
	if (isfilevar(inptr2,"LNO_COL_PROD")) then
	lno_col2 = inptr2->LNO_COL_PROD
	else 
	lno_col2 = 0.
	end if
	o3chm2 = new((/ntime2,nlev2,nlat2,nlon2/),"float")
	if (isfilevar(inptr2,"DO3CHM")) then
	o3chm2 =inptr2->DO3CHM
	else
	o3chm2 = 0.
	end if 
	if (isfilevar(inptr2,"DCOCHM")) then
	cochm2 =inptr2->DCOCHM
	else
	cochm2 = new((/ntime2,nlev2,nlat2,nlon2/),"float")
	cochm2 = 0.
	end if 
	aerod2 = new((/ntime2,nlat2,nlon2/),"float")
	if (isfilevar(inptr2, "AODVIS"))
	aerod2  = inptr2->AODVIS
	else
	aerod2 = 0.
	end if
	dst22 = aerod2
	dst22 = 0.
	;print("AEROD: "+sum(aerod))
	if (isfilevar(inptr2, "ODV_DST01").and.isfilevar(inptr2, "ODV_DST02").and.isfilevar(inptr2, "ODV_DST03").and.isfilevar(inptr2, "ODV_DST04"))
	dst1 = inptr2->ODV_DST01
	dst2 = inptr2->ODV_DST02
	dst3 = inptr2->ODV_DST03
	dst4 = inptr2->ODV_DST04
	dst22 = dst1+dst2+dst3+dst4
	delete(dst1)
	delete(dst2)
	delete(dst3)
delete(dst4)
	end if
	if (isfilevar(inptr2, "AODDUST1").and.isfilevar(inptr2, "AODDUST2").and.isfilevar(inptr2, "AODDUST3"))
	dst1 = inptr2->AODDUST1
	dst2 = inptr2->AODDUST2
	dst3 = inptr2->AODDUST3
	dst22 = dst1+dst2+dst3
	delete(dst1)
	delete(dst2)
        delete(dst3)
        else
	 if (isfilevar(inptr2, "AODDUST"))
	 dst1 = inptr2->AODDUST
	 dst22 = dst1
	 delete(dst1)
	 end if 
	end if
        dlon2=360./nlon2
        coffa=pi*re^2./180.
        area2 = aerod2
        area2 = 1.
        area2 = area2 + aerod2*0.
        do ii=0,dimsizes(gw2)-1
          aerod2(:,ii,:)=aerod2(:,ii,:)*coffa*dlon2*gw2(ii)
          dst22(:,ii,:)=dst22(:,ii,:)*coffa*dlon2*gw2(ii)
          area2(:,ii,:)=area2(:,ii,:)*coffa*dlon2*gw2(ii)
        end do
        taerod2 = sum(aerod2)/sum(area2)
        tdst22 = sum(dst22)/sum(area2)
        delete(area2)


	ps2 = inptr2->PS
	if (isfilevar(inptr2,"O3")) then
	o3flag2 = 1
	o321 = inptr2->O3
	o321 = o321*1.e+09
	else 
	o3flag2 = 0
	end if
	ha2=doubletofloat(inptr2->hyai)
	hb2=doubletofloat(inptr2->hybi)
	p2 = pres_hybrid_ccm(ps2,p0,ha2,hb2)
	ha21=doubletofloat(inptr2->hyam)
	hb21=doubletofloat(inptr2->hybm)
p21 = pres_hybrid_ccm(ps2,p0,ha21,hb21)
        t2 = inptr2->T
        rho2 = p21/(287.04*t2)   ; ;cm-3


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
	; and thenn the difference between
	; the fields

	do i = 0, ivars-1
	vinta=vars(i)              ; interstitial value 
	vchml =vinta+"_CHML"         ; chemical loss 
	vchmp =vinta+"_CHMP"         ; chemical loss 
      ;	if i.eq.2 then
       	vchmll =vinta+"_Loss"         ; chemical loss 
       	vchmpp =vinta+"_Prod"         ; chemical loss 
      ;	end if
	vdf ="DF_"+vinta       ; wet deposition flux at surface
	vemis="SF"+vinta          ; surface emission
	; vemix=vinta+"_CLXF"       ; elevated emission

	; CASE 1 MODEL
	if (isfilevar(inptr1,vinta)) then
	vint1=inptr1->$vinta$
	else
	vint1 = new((/ntime1,nlev1,nlat1,nlon1/),"float")
	vint1(:,:,:,:) = 0.
	end if 
	if (isfilevar(inptr1,vchmll)) then
	chml1=inptr1->$vchmll$
	else
	 if (isfilevar(inptr1,vchml)) then
	  chml1=inptr1->$vchml$
 	 else
	  chml1 = new((/ntime1,nlev1,nlat1,nlon1/),"float")
	  chml1(:,:,:,:) = 0.
         end if
	end if 
	if (isfilevar(inptr1,vchmpp)) then
	chmp1=inptr1->$vchmpp$
	else
	  if (isfilevar(inptr1,vchmp)) then
	   chmp1=inptr1->$vchmp$
	  else
	   chmp1 = new((/ntime1,nlev1,nlat1,nlon1/),"float")
	   chmp1(:,:,:,:) = 0.
          end if
	end if 
	if (isfilevar(inptr1,vdf)) then
	df1=inptr1->$vdf$
	else
	df1 = new((/ntime1,nlat1,nlon1/),"float")
	df1(:,:,:) = 0.
	end if 
	if (isfilevar(inptr1,vemis)) then
	emis1=inptr1->$vemis$
	else
	emis1 = new((/ntime1,nlat1,nlon1/),"float")
	emis1(:,:,:) = 0.
	end if 
	delp1=vint1
        ddd1=dimsizes(delp1)
	do k=0,ddd1(1)-1
        delp1(:,k,:,:)=p1(:,k+1,:,:)-p1(:,k,:,:)
	end do
	delp11=delp1
	delp11d = ndtooned(delp1)
        p11d = ndtooned(p11)
	if o3flag1.eq.1 then
        o311d = ndtooned(o311)
	; use ozone to set delp11d to 0.
        delp11d_strat = delp11d
        delp11d = where(o311d.gt.150.,0.,delp11d) 
	print("burden below 150ppb ozone")
        delp11d_strat = where(o311d.gt.150.,delp11d_strat,0.) 
        delp1_strat = onedtond(delp11d_strat, dimsizes(delp11))
	else
        delp11d = where(p11d.lt.20000.,0.,delp11d) 
	print("burden below 200hPa")
	end if
        delp1 = onedtond(delp11d, dimsizes(delp11))

	vint1=vint1*mw(i)/mw_dryair  ;mol/mol kg/mol / kg/mol
        vint1_strat = vint1
	vint1=vint1*delp1/grav  ;mol/mol kg/mol / kg/mol
        bvar1=dim_sum_n_Wrap(vint1,1)
	chml1=chml1* ( mw(i)/rho1*1.e-3/6.022e23 )   ;chml_spec KG/M^2/S   ;mw*1.e3 kg/mol ; avog (mol^-1)
	chml1=chml1*delp1/grav*1.e-3
        bchml1=dim_sum_n_Wrap(chml1,1)
	if vars(i).eq."O3" then 
	if (isfilevar(inptr1,"O3")) then
	 vint1_strat=vint1_strat*delp1_strat/grav  ;mol/mol kg/mol / kg/mol
         bvar1_strat=dim_sum_n_Wrap(vint1_strat,1)
         copy_VarMeta(bvar1,bvar1_strat)
	 o3chm11 = o3chm1
	 o3chm11d = ndtooned(o3chm1)
         o3chm11d = where(o311d.gt.150.,0.,o3chm11d)
	 ; o3chm11d = where(p11d.lt.10000.,0.,o3chm11d)
         o3chm1 = onedtond(o3chm11d, dimsizes(o3chm11))
	 ;  o3chm1=o3chm1* ( mw(i)*1.e-3/6.022e23 )   ;chml_spec KG/M^2/S   ;mw*1.e3 kg/mol ; avog (mol^-1)
	 ;  o3chm1=o3chm1*delp1/grav*1.e-3
         bo3chm1=dim_sum_n_Wrap(o3chm1,1)
         bcochm1=dim_sum_n_Wrap(cochm1,1)
	 chmp1=chmp1* ( mw(i)/rho1*1.e-3/6.022e23 )   ;chml_spec KG/M^2/S   ;mw*1.e3 kg/mol ; avog (mol^-1)
	 chmp1=chmp1*delp1/grav*1.e-3
         bchmp1=dim_sum_n_Wrap(chmp1,1)
	end if
	end if 
        coo1=new((/ddd1(2)/),float)
	do ii=0, ddd1(2)-1
	coo1(ii) = gw1(ii)*(2.*pi/nlon1)*re^2.
	end do
	do ii=0,ddd1(2)-1
	bvar1(:,ii,:)=bvar1(:,ii,:)*coo1(ii)
	bchml1(:,ii,:)=bchml1(:,ii,:)*coo1(ii)
	emis1(:,ii,:)=emis1(:,ii,:)*coo1(ii)
        df1(:,ii,:)=df1(:,ii,:)*coo1(ii)
	; if i.eq.0 then
	; end if
	end do


	tbvar1 = sum(bvar1)*1e-12*factor(i)
	tbchml1 = sum(bchml1)*86400.*365.*factor(i)
	temis1 = sum(emis1)*86400.*365.*1e-9*factor(i)
	tdf1 = sum(df1)*86400.*365.*1e-9*factor(i)
	if vars(i).eq."O3" then 
	if (isfilevar(inptr1,"O3")) then
	 do ii=0,ddd1(2)-1
          bchmp1(:,ii,:)=bchmp1(:,ii,:)*coo1(ii)
	  bvar1_strat(:,ii,:)=bvar1_strat(:,ii,:)*coo1(ii)
         end do 

	;    bo3chm1(:,ii,:)=bo3chm1(:,ii,:)*coo1(ii)
  	 tbchmp1 = sum(bchmp1)*86400.*365.*factor(i)
         tbo3chm1 = sum(bo3chm1)*86400.*365.*1e-9*factor(i)
	 ste1_o3 = tdf1-tbo3chm1
	 tbvar1_strat = sum(bvar1_strat)*1e-12*factor(i)
        end if
	end if
	lifet1 = tbvar1
	if (tbchml1+tdf1).gt.0 then
        lifet1 = tbvar1/(tbchml1+tdf1)
	else
	lifet1 = 0.
	end if
	if i.eq.0 then
         tlno_prod1 = sum(lno_col1)
	end if




	if (compare .eq. "OBS") then
	else
	; CASE 2 MODEL
	if (isfilevar(inptr2,vinta)) then
	vint2=inptr2->$vinta$
	else
	vint2 = new((/ntime2,nlev2,nlat2,nlon2/),"float")
	vint2(:,:,:,:) = 0.
	end if
	if (isfilevar(inptr2,vchmll)) then
	chml2=inptr2->$vchmll$
	else
	 if (isfilevar(inptr2,vchml)) then
	  chml2=inptr2->$vchml$
 	 else
	  chml2 = new((/ntime2,nlev2,nlat2,nlon2/),"float")
	  chml2(:,:,:,:) = 0.
         end if
	end if
	;if i.eq.2 then
	if (isfilevar(inptr2,vchmpp)) then
	chmp2=inptr2->$vchmpp$
	else
	  if (isfilevar(inptr2,vchmp)) then
	   chmp2=inptr2->$vchmp$
	  else
	   chmp2 = new((/ntime2,nlev2,nlat2,nlon2/),"float")
	   chmp2(:,:,:,:) = 0.
          end if
	end if
	;end if
	if (isfilevar(inptr2,vdf)) then
	df2=inptr2->$vdf$
	else
	df2 = new((/ntime2,nlat2,nlon2/),"float")
	df2(:,:,:) = 0.
	end if
	if (isfilevar(inptr2,vemis)) then
	emis2=inptr2->$vemis$
	else
	emis2 = new((/ntime2,nlat2,nlon2/),"float")
	emis2(:,:,:) = 0.
	end if

	delp2=vint2
        ddd2=dimsizes(delp2)
	do k=0,ddd2(1)-1
        delp2(:,k,:,:)=p2(:,k+1,:,:)-p2(:,k,:,:)
	end do
	delp21=delp2
	delp21d = ndtooned(delp2)
        p21d = ndtooned(p21)
	if o3flag2.eq.1 then
         delp21d_strat = delp21d
         o321d = ndtooned(o321)
         delp21d_strat = where(o321d.le.150.,0.,delp21d_strat)
         delp2_strat = onedtond(delp21d_strat, dimsizes(delp21))
	; use ozone to set delp21d to 0.
         delp21d = where(o321d.gt.150.,0.,delp21d) 
	print("burden below 150ppb ozone")
	else
        delp21d = where(p21d.lt.20000.,0.,delp21d) 
	print("burden below 200hPa")
	end if
        delp2 = onedtond(delp21d, dimsizes(delp21))

	vint2=vint2*mw(i)/mw_dryair  ;mol/mol kg/mol / kg/mol
        vint2_strat = vint2
	vint2=vint2*delp2/grav  ;mol/mol kg/mol / kg/mol
        bvar2=dim_sum_n_Wrap(vint2,1)
 	chml2=chml2* ( mw(i)/rho2*1.e-3/6.022e23 )   ;chml_spec KG/M^2/S   ;mw*1.e3 kg/mol ; avog (mol^-1)
	chml2=chml2*delp2/grav*1.e-3
        bchml2=dim_sum_n_Wrap(chml2,1)
	if (isfilevar(inptr2,"O3")) then
	if vars(i).eq."O3" then
	vint2_strat=vint2_strat*delp2_strat/grav  ;mol/mol kg/mol / kg/mol
        bvar2_strat=dim_sum_n_Wrap(vint2_strat,1)
	o3chm21 = o3chm2
	o3chm21d = ndtooned(o3chm2)
        o3chm21d = where(o321d.gt.150.,0.,o3chm21d)
	;  o3chm21d = where(p21d.lt.10000.,0.,o3chm21d)
	o3chm2 = onedtond(o3chm21d, dimsizes(o3chm21))
        bo3chm2=dim_sum_n_Wrap(o3chm2,1)
        bcochm2=dim_sum_n_Wrap(cochm2,1)
	chmp2=chmp2* ( mw(i)/rho2*1.e-3/6.022e23 )   ;chml_spec KG/M^2/S   ;mw*1.e3 kg/mol ; avog (mol^-1)
	chmp2=chmp2*delp2/grav*1.e-3
        bchmp2=dim_sum_n_Wrap(chmp2,1)
        end if
        end if

  coo2=new((/ddd2(2)/),float)
 do ii=0, ddd2(2)-1
   coo2(ii) = gw2(ii)*(2.*pi/nlon2)*re^2.
  end do
  do ii=0,ddd2(2)-1
   bvar2(:,ii,:)=bvar2(:,ii,:)*coo2(ii)
   bchml2(:,ii,:)=bchml2(:,ii,:)*coo2(ii)
   emis2(:,ii,:)=emis2(:,ii,:)*coo2(ii)
   df2(:,ii,:)=df2(:,ii,:)*coo2(ii)
  end do


 tbvar2 = sum(bvar2)*1e-12*factor(i)
 tbchml2 = sum(bchml2)*86400.*365.*factor(i)
 temis2 = sum(emis2)*86400.*365.*1e-9*factor(i)
 tdf2 = sum(df2)*86400.*365.*1e-9*factor(i)
  if (isfilevar(inptr2,"O3")) then
   if vars(i).eq."O3" then
   do ii=0,ddd2(2)-1
    bvar2_strat(:,ii,:)=bvar2_strat(:,ii,:)*coo2(ii)
    bchmp2(:,ii,:)=bchmp2(:,ii,:)*coo2(ii)
;    bo3chm2(:,ii,:)=bo3chm2(:,ii,:)*coo2(ii)
   end do
   tbvar2_strat = sum(bvar2_strat)*1e-12*factor(i)
   tbchmp2 = sum(bchmp2)*86400.*365.*factor(i)
   tbo3chm2 = sum(bo3chm2)*86400.*365.*1e-9*factor(i)
   ste2_o3 = tdf2-tbo3chm2
   end if
    end if
 lifet2 = tbvar2
 if (tbchml2+tdf2).gt.0 then
   lifet2 = tbvar2/(tbchml2+tdf2)
 else
  lifet2 = 0.
 end if
 if i.eq.0 then
   tlno_prod2 = sum(lno_col2)
 end if


 end if
 

;--------------------------------------------------------------------
; AT THIS POINT WE HAVE A AND B
; GLOBAL MEANS AND DIFFERENCES

if (compare .ne. "OBS") then
; i over variable
  if i.le.3 then 
   global(i*5 ,0) = tbvar1   ; case1
   global(i*5 + 1,0) =  temis1    ; case1
   global(i*5 + 2,0) =  tdf1    ; case1
   global(i*5 + 3,0) = tbchml1    ; case1
   global(i*5 + 4,0) = lifet1    ; case1
   global(i*5 ,1) = tbvar2   ; case1
   global(i*5 + 1,1) = temis2    ; case1
   global(i*5 + 2,1) = tdf2    ; case1
   global(i*5 + 3,1) = tbchml2    ; case1
   global(i*5 + 4,1) = lifet2 ; case1
  else
   global(4*5 + i ,0) = temis1    ; case1
   global(4*5 + i ,1) = temis2    ; case1
  end if 
  if vars(i).eq."O3" then
  if (isfilevar(inptr1,"O3")) then
   global((i+1)*5, 0) = tbchmp1    ; case1
   global((i+1)*5 + 1, 0) =  tbo3chm1  ; case1
   global((i+1)*5 + 2,0) = ste1_o3  ; case1
   global((i+1)*5 + 3,0) = tbvar1_strat; case1
  end if 
  if (isfilevar(inptr2,"O3")) then
   global((i+1)*5, 1) = tbchmp2    ; case1
   global((i+1)*5 + 1, 1) =  tbo3chm2  ; case1
   global((i+1)*5 + 2,1) = ste2_o3  ; case1
   global((i+1)*5 + 3,1) = tbvar2_strat; case1
   delete(tbchmp2)
  end if 
  end if 
else
 
if i.le.3 then
   global(i*5 ,0) = tbvar1   ; case1
   global(i*5 + 1,0) =  temis1    ; case1
   global(i*5 + 2,0) =  tdf1    ; case1
   global(i*5 + 3,0) = tbchml1    ; case1
   global(i*5 + 4,0) = lifet1    ; case1
 else
   global(4*5 + i + 1,0) = temis1    ; case1
 end if
 if vars(i).eq."O3" then
  if (isfilevar(inptr1,"O3")) then
   global((i+1)*5, 0) = tbchmp1    ; case1
   global((i+1)*5 + 1, 0) =  tbo3chm1  ; case1
   global((i+1)*5 + 2,0) = ste1_o3  ; case1
   global((i+1)*5 + 3,0) = tbvar1_strat; case1
   delete(bchmp1)
  end if
  end if
end if


 delete(bvar1)
 delete(emis1)
 delete(df1)
 delete(bchml1)
 delete(lifet1)
 delete(tbvar1)
 delete(temis1)
 delete(tdf1)
 delete(tbchml1)

if (compare .eq. "OBS") then
 else
 delete(bvar2)
 delete(emis2)
 delete(df2)
 delete(bchml2)
 delete(lifet2)
 delete(tbvar2)
 delete(temis2)
 delete(tdf2)
 delete(tbchml2)
end if

end do     
 
do i = 0,5
 if (compare .ne. "OBS") then
 global(i*5,2) = global(5*i,0) - global(5*i,1)           ; diff
 global(i*5+1,2) = global(5*i+1,0) - global(5*i+1,1)           ; diff
 global(i*5+2,2) = global(5*i+2,0) - global(5*i+2,1)           ; diff
 global(i*5+3,2) = global(5*i+3,0) - global(5*i+3,1)           ; diff
 global(i*5+4,2) = global(5*i+4,0) - global(5*i+4,1)           ; diff
 end if
end do
global((i-1)*5+3,0)=  tlno_prod1
if (compare .ne. "OBS") then
 global((i-1)*5+3,1)=  tlno_prod2
 global((i-1)*5+3,2) = global(5*(i-1)+3,1) - global(5*(i-1)+3,0)           ; diff
end if
global((i-1)*5+4,0)=  taerod1
if (compare .ne. "OBS") then
 global((i-1)*5+4,1)=  taerod2
 global((i-1)*5+4,2) = global(5*(i-1)+4,1) - global(5*(i-1)+4,0)           ; diff
 delete(aerod2)
 delete(taerod2)
end if
global((i-1)*5+5,0)=  tdst11
if (compare .ne. "OBS") then
 global((i-1)*5+5,1)=  tdst22
 global((i-1)*5+5,2) = global(5*(i-1)+5,1) - global(5*(i-1)+5,0)           ; diff
 delete(dst22)
 delete(tdst22)
end if

; PRINTT THE TABLES
  tablename = wkdir+"table_chem_"+season+".asc"
  if (compare .eq. "OBS") then
    label2 = ""
    case2 = ""
    title = (/"DIAG SET1 Chemistry: "+season+" MEANS GLOBAL for O3 < 150ppb"/)
    make_table_chem(case1,label1,case2,label2,vars_all,global,title,tablename)
  else
    title = (/"DIAG SET1 Chemistry: "+season+" MEANS GLOBAL for O3 < 150ppb"/)
    make_table_chem(case1,label1,case2,label2,vars_all,global,title,tablename)
  end if
end
