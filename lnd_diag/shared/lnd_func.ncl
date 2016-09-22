undef("scale_var")
function scale_var(x,scale_type,info)
begin
;********************************************************
; this function scales the input variable based upon
; the given scale type and changes the units accordingly

  if(scale_type.eq."globalTotlNat")then
    x = x * info@globalTotal__SF
    x@units = info@globalTotal__units
  end if
  if(scale_type.eq."globalTotlAnn")then
    x = x * info@globalTotal_Annual__SF
    x@units = info@globalTotal_Annual__units
  end if
  if(scale_type.eq."globalMeanNat")then
    x = x * info@globalMean__SF
    x@units = info@globalMean__units
  end if
  if(scale_type.eq."globalMeanDay")then
    x = x * info@globalMean_Daily__SF
    x@units = info@globalMean_Daily__units
  end if
  if(scale_type.eq."globalMeanAnn")then
    x = x * info@globalMean_Annual__SF
    x@units = info@globalMean_Annual__units
  end if
  x@long_name = info@longName
  return(x)
end
;********************************************************
undef("global_values")
function global_values(varName, x,area,landfrac,scale_type,numyrs,nlev)
local area1,land1,tmp,typ,rank,avg_x,start
begin
;********************************************************
  tmp  = stringtocharacter(scale_type) ; 
  type = charactertostring(tmp(6:9))   ; checking for Mean or Totl
  rank = dimsizes(dimsizes(x))         ; 3D or 4D?

;********************************************************
; calculate either global mean or global value or global sum as necesseary 
; 20apr06 - create new area mask for every year in case of missing values or NaNs
;******************************************************** 

; area mean per time step
  if(type .eq. "Mean")then
    if(rank.eq.3)then 
      avg_x = new(numyrs,typeof(x))            ; no level
        ; This variable is calculated per total GLOBAL area, not global LAND area.
        ; therefore, area1 is not masked by land as it is for the other vars.
        if (varName .eq. "RNET-SENS-LATENT") then
             if(isvar("area1")) then
		delete(area1)
	     end if
             area1 = area
             do i = 0,numyrs-1
    	        land1    = mask(landfrac,(x(i,:,:) .eq. x@_FillValue), False)
        	avg_x(i) = sum( x(i,:,:)*area1/sum(area1)*land1 )
		delete(land1)
             end do
	     delete(area1)
        else
             do i = 0,numyrs-1
;               printVarSummary(area)
;               printVarSummary(landfrac)
    		area1 = mask(area,    (x(i,:,:) .eq. x@_FillValue), False)
    		land1 = mask(landfrac,(x(i,:,:) .eq. x@_FillValue), False)
        	avg_x(i)  = sum( x(i,:,:)*area1*land1/sum(area1*land1) )
                indx = ind(ismissing(ndtooned(x(i,:,:))) .and. .not.(ismissing(ndtooned(area1))))
;               print(indx)
                delete(indx)
                indx = ind(ismissing(ndtooned(x(i,:,:))) .and. .not.(ismissing(ndtooned(land1))))
;               print(indx)
                delete(indx)
;               print(min(x(i,:,:)))
;               printVarSummary(area1)
;               printVarSummary(land1)
;               print(sum(area1*land1/sum(area1*land1)))
;               print(x(i,62,:))
;               print(x(i,:,:))
;               print(area1(62,:))
;               print(land1(62,:))
;               print(avg_x(i))
		delete(area1)
		delete(land1)
             end do
	end if
	
    else
; area mean per time and per level
      avg_x = new((/numyrs,nlev/),typeof(x))
      do i = 0,numyrs-1
        do j=0,nlev-1
    	  area1 = mask(area,    (x(i,j,:,:) .eq. x@_FillValue), False)
    	  land1 = mask(landfrac,(x(i,j,:,:) .eq. x@_FillValue), False)
          avg_x(i,j)  = sum( x(i,j,:,:)*area1*land1/sum(area1*land1) )
	  delete(area1)
	  delete(land1)
        end do
      end do
    end if
  end if

; area total per time step
  if(type .eq. "Totl")then
    avg_x = new(numyrs,typeof(x))   
    do i = 0,numyrs-1
    	area1 = mask(area,    (x(i,:,:) .eq. x@_FillValue), False)
    	land1 = mask(landfrac,(x(i,:,:) .eq. x@_FillValue), False)
        avg_x(i) = sum( x(i,:,:)*area1*land1*1.e6 )
	delete(area1)
	delete(land1)
    end do
  end if

  return(avg_x)
end

;********************************************************
undef("derive_land")
function derive_land(var_name:string,ptr:file)
; derive various variables
begin
  if(var_name .eq. "RNET-SENS-LATENT")then
    fsa  = ptr->FSA
    fira = ptr->FIRA
    fctr = ptr->FCTR
    fcev = ptr->FCEV
    fgev = ptr->FGEV
    fsh  = ptr->FSH

    var = fsa ; trick to retain meta data
    var = fsa-fira-fctr-fcev-fgev-fsh
    return(var)
  end if

  if(var_name .eq. "TOTRUNOFF")then
    qover = ptr->QOVER
    qdrai = ptr->QDRAI
    qrgwl = ptr->QRGWL

    var   = qover ; trick to retain meta data
    var   = qover + qdrai + qrgwl
    return(var)
  end if

  if(var_name.eq."TOTSOILLIQ")then
    var = ptr ->SOILLIQ        ; derivation is merely sum over levels
    if(isfilevar(ptr,"levsoi")) then
    	new_var = dim_sum_Wrap(var(time|:,lat|:,lon|:,levsoi|:))
    end if
    if(isfilevar(ptr,"levgrnd")) then
    	new_var = dim_sum_Wrap(var(time|:,lat|:,lon|:,levgrnd|:))
    end if
    return(new_var)
  end if

  if(var_name.eq."TOTSOILICE")then
    var = ptr ->SOILICE        ; derivation is merely sum over levels
    if(isfilevar(ptr,"levsoi")) then
    	new_var = dim_sum_Wrap(var(time|:,lat|:,lon|:,levsoi|:))
    end if
    if(isfilevar(ptr,"levgrnd")) then
    	new_var = dim_sum_Wrap(var(time|:,lat|:,lon|:,levgrnd|:))
    end if
    return(new_var)
  end if

  if(var_name.eq."VBSA")then
    fsdsvdln = ptr ->FSDSVDLN
    fsrvdln  = ptr ->FSRVDLN

    var = fsrvdln                 ; trick to retain meta data
    if (any(fsdsvdln .eq. 0)) then  ; set zeros to _FillValue
      fsdsvdln = mask(fsdsvdln,(fsdsvdln .eq. 0),False)
    end if
    var = ( fsrvdln/fsdsvdln ) * 100.
    return(var)
  end if

  if(var_name.eq."NBSA")then
    fsdsndln = ptr ->FSDSNDLN
    fsrndln  = ptr ->FSRNDLN

    var = fsrndln                   ; trick to retain meta data
    if (any(fsdsndln .eq. 0)) then  ; set zeros to _FillValue
      fsdsndln = mask(fsdsndln,(fsdsndln .eq. 0),False)
    end if
    var = ( fsrndln/fsdsndln ) * 100.
    return(var)
  end if

  if(var_name.eq."VWSA")then
    fsdsvi = ptr->FSDSVI
    fsrvi  = ptr->FSRVI

    var    = fsrvi                ; trick to retain meta data
    if (any(fsdsvi .eq. 0)) then  ; set zeros to _FillValue
      fsdsvi = mask(fsdsvi,(fsdsvi .eq. 0),False)
    end if
    var    = ( fsrvi/fsdsvi ) * 100.
    return(var)
  end if

  if(var_name.eq."NWSA")then
    fsdsni = ptr->FSDSNI
    fsrni  = ptr->FSRNI

    var    = fsrni                ; trick to retain meta data
    if (any(fsdsni .eq. 0)) then  ; set zeros to _FillValue
      fsdsni = mask(fsdsni,(fsdsni .eq. 0),False)
    end if
    var    = ( fsrni/fsdsni ) * 100.
    return(var)
  end if

  if(var_name.eq."PREC")then
    rain = ptr ->RAIN
    snow = ptr ->SNOW

    var = rain                 ; trick to retain meta data
    var = rain + snow
    return(var)
  end if

  if(var_name.eq."FGNET")then
    fgr = ptr ->FGR
    fsm = ptr ->FSM

    var = fgr                 ; trick to retain meta data
    var = fgr - fsm
    return(var)
  end if

  if(var_name.eq."XIM")then
    rain  = ptr ->RAIN
    snow  = ptr ->SNOW
    fsa   = ptr ->FSA
    fira  = ptr ->FIRA

    lat   = ptr ->lat
    nlat  = dimsizes(lat)
    lon   = ptr ->lon
    nlon  = dimsizes(lon)
    time  = ptr ->time
    ntime = dimsizes(time)

    var = rain                 ; trick to retain meta data
    p   = (rain + snow) * 2.501e6
    xim1d = ndtooned(p)
    xim1d = 0.0

    p1d = ndtooned(p)
    pe  = fsa - fira

    pe = pe > 0.
    pe1d = ndtooned(pe)
    indx = ind(pe1d .gt. p1d .and. pe1d .ne. 0.0)
    ; indx = ind(pe1d .gt. p1d)
    xim1d(indx) = (p1d(indx) / pe1d(indx)) - 1.0
    delete(indx)
    indx = ind(pe1d .le. p1d .and. p1d .ne. 0.0)
    xim1d(indx) = 1.0 - (pe1d(indx) / p1d(indx))
    delete(indx)
    indx = ind(p1d .eq. 0.0 .and. pe1d .eq. 0.0)
    if (.not. (any(ismissing(indx)))) then
    	xim1d(indx) = 0.0
    end if
    delete(indx)
    var = onedtond(xim1d,(/ntime,nlat,nlon/))
    var = mask(var, ismissing(rain), False)
    return(var)
  end if

  if(var_name.eq."RNET")then
    fsa  = ptr ->FSA
    fira = ptr ->FIRA

    var = fsa                  ; trick to retain meta data
    var = fsa-fira
    return(var)
  end if

  if(var_name.eq."LHEAT")then
    fctr = ptr ->FCTR
    fcev = ptr ->FCEV
    fgev = ptr ->FGEV
    
    var = fctr                 ; trick to retain meta data
    var = fctr + fcev + fgev
    return(var)
  end if

  if(var_name.eq."QVEGEP")then
    qvege = ptr ->QVEGE
    rain  = ptr ->RAIN
    snow  = ptr ->SNOW
    
    var =  qvege                ; trick to retain meta data
    y = rain
    y = rain + snow
    var = 100 * qvege / where(y.ne.0,y,y@_FillValue)
    return(var)
  end if

  if(var_name.eq."P-E")then
    qvege = ptr ->QVEGE
    qvegt = ptr ->QVEGT
    qsoil = ptr ->QSOIL
    
    var =  qvege                ; trick to retain meta data
    var =  qvege+qvegt+qsoil
    return(var)
  end if

  if(var_name.eq."CO2_PPMV") then
    var  = ptr ->FSR
    var = var@_FillValue
    if(isfilevar(ptr,"PCO2") .and. isfilevar(ptr,"PBOT"))then
    	pco2 = ptr ->PCO2
    	pbot = ptr ->PBOT
    	var =  pco2                ; trick to retain meta data
    	var =  (pco2/pbot) * 1e6
    end if
    return(var)
  end if

  if(var_name.eq."PCT_BSOIL_PFT") then
    var  = ptr ->FSR
    var = var@_FillValue
    if(isfilevar(ptr,"PCT_NAT_PFT"))then
        pct_nat_pft = ptr ->PCT_NAT_PFT
        var         = pct_nat_pft(:,0,:,:)
    end if
    return(var)
  end if

  if(var_name.eq."PCT_TREE_PFT") then
    var  = ptr ->FSR
    var = var@_FillValue
    if(isfilevar(ptr,"PCT_NAT_PFT"))then
        pct_nat_pft = ptr ->PCT_NAT_PFT
        var         = pct_nat_pft(:,1,:,:)+pct_nat_pft(:,2,:,:)+pct_nat_pft(:,3,:,:)+pct_nat_pft(:,4,:,:)+ \
                      pct_nat_pft(:,5,:,:)+pct_nat_pft(:,6,:,:)+pct_nat_pft(:,7,:,:)+pct_nat_pft(:,8,:,:)
    end if
    return(var)
  end if

  if(var_name.eq."PCT_GRASS_PFT") then
    var  = ptr ->FSR
    var = var@_FillValue
    if(isfilevar(ptr,"PCT_NAT_PFT"))then
        pct_nat_pft = ptr ->PCT_NAT_PFT
        var         = pct_nat_pft(:,12,:,:)+pct_nat_pft(:,13,:,:)+pct_nat_pft(:,14,:,:)
    end if
    return(var)
  end if

  if(var_name.eq."PCT_SHRUB_PFT") then
    var  = ptr ->FSR
    var = var@_FillValue
    if(isfilevar(ptr,"PCT_NAT_PFT"))then
        pct_nat_pft = ptr ->PCT_NAT_PFT
        var         = pct_nat_pft(:,9,:,:)+pct_nat_pft(:,10,:,:)+pct_nat_pft(:,11,:,:)
    end if
    return(var)
  end if

  if(var_name.eq."PCT_CROP_PFT") then
    var  = ptr ->FSR
    var = var@_FillValue
    if(isfilevar(ptr,"PCT_NAT_PFT"))then
        pct_nat_pft = ptr ->PCT_NAT_PFT
        var         = pct_nat_pft(:,15,:,:)+pct_nat_pft(:,16,:,:)
    end if
    return(var)
  end if

; CLM-CN and/or CLAMP Variables -----------------------

  if(var_name.eq."ALBEDO" .or. var_name .eq. "ASA" .or. var_name .eq. "ALL_SKY_ALBEDO" )then
    fsr  = ptr ->FSR
    fsds = ptr ->FSDS

    var  = fsr                  ; trick to retain meta data
    if (any(fsds .eq. 0)) then  ; set zeros to _FillValue
      fsds = mask(fsds,(fsds .eq. 0),False)
    end if
    var  = ( fsr/fsds ) * 100.
    return(var)
  end if

  if(var_name.eq."TOTSOILLIQ" .or. var_name .eq. "TOTAL_SOIL_LIQUID" )then
    var = ptr ->SOILLIQ        ; derivation is merely sum over levels
    if(isfilevar(ptr,"levsoi")) then
    	new_var = dim_sum_Wrap(var(time|:,lat|:,lon|:,levsoi|:))
    end if
    if(isfilevar(ptr,"levgrnd")) then
    	new_var = dim_sum_Wrap(var(time|:,lat|:,lon|:,levgrnd|:))
    end if
    return(new_var)
  end if

  if(var_name.eq."TOTSOILICE" .or. var_name .eq. "TOTAL_SOIL_ICE" )then
    var = ptr ->SOILICE        ; derivation is merely sum over levels
    if(isfilevar(ptr,"levsoi")) then
    	new_var = dim_sum_Wrap(var(time|:,lat|:,lon|:,levsoi|:))
    end if
    if(isfilevar(ptr,"levgrnd")) then
    	new_var = dim_sum_Wrap(var(time|:,lat|:,lon|:,levgrnd|:))
    end if
    return(new_var)
  end if

  if(var_name.eq."EVAPFRAC" .or. var_name .eq. "LATENT")then
    ; LHEAT
    fctr = ptr ->FCTR
    fcev = ptr ->FCEV
    fgev = ptr ->FGEV
    lheat = fctr + fcev + fgev

    ; SENSIBLE HEAT
    sheat = ptr ->FSH

    var =  fctr			; trick to retain meta data
    denom = lheat + sheat

    ; Use this if want sparse grid
    ; get rid of zero or negative sensible or latent heat values
    ; denom = mask (denom, (sheat .lt. 0 .or. lheat .lt. 0), False)

    ; use this to mask entire region if ANY values are missing. Want
    ; to avoid misrepresenting a region with one good value.
    ; avoid division by 0.
    if (any(sheat .lt. 0) )then
    	denom = mask (denom, (sheat .lt. 0), False)
    end if
    if (any(lheat .lt. 0) )then
    	denom = mask (denom, (lheat .lt. 0), False)
    end if
    denom = mask (denom, (denom .eq. 0), False)

    var =  lheat / denom

    if (any(var .lt. 0) )then
        printVarSummary(var)
    end if
	
    return(var)
  end if


  if(var_name.eq."ET")then
    qvege = ptr ->QVEGE
    qvegt = ptr ->QVEGT
    qsoil = ptr ->QSOIL
    
    var =  qvege                ; trick to retain meta data
    var =  qvege+qvegt+qsoil
    return(var)
  end if

  if(var_name.eq."LEAFCN")then
    leafc = ptr ->LEAFC
    leafn = ptr ->LEAFN

    var = leafc                 ; trick to retain meta data
    if (any(leafn .eq. 0)) then  ; set zeros to _FillValue
      leafn = mask(leafn,(leafn .eq. 0),False)
    end if
    var = leafc/leafn
    return(var)
  end if

  if(var_name.eq."TOTVEGCN")then
    totvegc = ptr ->TOTVEGC
    totvegn = ptr ->TOTVEGN

    var = totvegc                 ; trick to retain meta data
    if (any(totvegn .eq. 0)) then  ; set zeros to _FillValue
      totvegn = mask(totvegn,(totvegn .eq. 0),False)
    end if
    var = totvegc/totvegn
    return(var)
  end if


;  CLAMP Variables -----------------------------------
  if(var_name.eq."VOL_SOIL_WATER")then
    var = ptr ->H2OSOI
    return(var)
  end if
  if(var_name.eq."TRANSPIRATION")then
    var = ptr ->QVEGT
    return(var)
  end if
  if(var_name.eq."SPEC_HUM")then
    var = ptr ->QBOT
    return(var)
  end if
  if(var_name.eq."SPEC_HUM_2M")then
    var = ptr ->Q2M
    return(var)
  end if
  if(var_name.eq."GROUND")then
    var = ptr ->FGR
    return(var)
  end if
  if(var_name.eq."SENSIBLE")then
    var = ptr ->FSH
    return(var)
  end if
  if(var_name.eq."SENSIBLE_GND")then
    var = ptr ->FSH_G
    return(var)
  end if
  if(var_name.eq."SENSIBLE_VEG")then
    var = ptr ->FSH_V
    return(var)
  end if
  if(var_name.eq."CANOPY_EVAPORATION")then
    var = ptr ->QVEGE
    return(var)
  end if
  if(var_name.eq."DRAINAGE")then
    var = ptr ->QDRAI
    return(var)
  end if
  if(var_name.eq."INTERCEPTION")then
    var = ptr ->QINTR
    return(var)
  end if
  if(var_name.eq."RUNOFF")then
    var = ptr ->QOVER
    return(var)
  end if
  if(var_name.eq."SNOW_DEPTH")then
    var = ptr ->H2OSNO
    return(var)
  end if
  if(var_name.eq."SOIL_EVAPORATION")then
    var = ptr ->QSOIL
    return(var)
  end if
  if(var_name.eq."SOIL_ICE")then
    var = ptr ->SOILICE
    return(var)
  end if
  if(var_name.eq."SOIL_LIQUID")then
    var = ptr ->SOILLIQ
    return(var)
  end if
  if(var_name.eq."SOIL_PSI")then
    var = ptr ->SOILPSI
    return(var)
  end if
  if(var_name.eq."TOTAL_SOIL_ICE")then
    var = ptr ->SOILPSI
    return(var)
  end if
  if(var_name.eq."TOTAL_SOIL_LIQUID")then
    var = ptr ->SOILPSI
    return(var)
  end if
  if(var_name.eq."BLACK_SKY_ALBEDO")then
    fsrndln = ptr ->FSRNDLN
    fsrvdln = ptr ->FSRVDLN

    fsdsndln = ptr ->FSDSNDLN
    fsdsvdln = ptr ->FSDSVDLN

    fsr  = fsrndln  + fsrvdln 
    fsds = fsdsndln + fsdsvdln
    var  = fsrndln                  ; trick to retain meta data
    if (any(fsds .eq. 0)) then  ; set zeros to _FillValue
      fsds = mask(fsds,(fsds .eq. 0),False)
    end if
    var  = ( fsr/fsds ) * 100.
    return(var)
  end if
  if(var_name.eq."ALL_SKY_ALBEDO")then
    fsrnd = ptr ->FSRND
    fsrni = ptr ->FSRNI
    fsrvd = ptr ->FSRVD
    fsrvi = ptr ->FSRVI

    fsdsnd = ptr ->FSDSND
    fsdsni = ptr ->FSDSNI
    fsdsvd = ptr ->FSDSVD
    fsdsvi = ptr ->FSDSVI

    fsr  = fsrnd  + fsrni  + fsrvd  + fsrvi
    fsds = fsdsnd + fsdsni + fsdsvd + fsdsvi
    var  = fsrnd                  ; trick to retain meta data
    if (any(fsds .eq. 0)) then  ; set zeros to _FillValue
      fsds = mask(fsds,(fsds .eq. 0),False)
    end if
    var  = ( fsr/fsds ) * 100.
    return(var)
  end if
  if(var_name.eq."VOL_SOIL_WATER")then
    var = ptr ->H2OSOI
    return(var)
  end if
  if(var_name.eq."IRDOWN")then
    var = ptr ->FLDS
    return(var)
  end if
  if(var_name.eq."IRUP")then
    var = ptr ->FIRE
    return(var)
  end if
  if(var_name.eq."NETIR")then
    var = ptr ->FIRA
    return(var)
  end if
  if(var_name.eq."NETRAD")then
    var = ptr ->FIRA
    return(var)
  end if

; CASA Variables -------------------------------------

  if(var_name .eq. "LEAFC")then
    in  = ptr->TPOOL_C
    var = in(:,0,:,:)
    return(var)
  end if
  if(var_name .eq. "WOODC")then
    in  = ptr->TPOOL_C
    var = in(:,1,:,:)
    return(var)
  end if
  if(var_name .eq. "FROOTC")then
    in  = ptr->TPOOL_C
    var = in(:,2,:,:)
    return(var)
  end if
  if(var_name .eq. "SURFMETC")then
    in  = ptr->TPOOL_C
    var = in(:,3,:,:)
    return(var)
  end if
  if(var_name .eq. "SURFSTRC")then
    in  = ptr->TPOOL_C
    var = in(:,4,:,:)
    return(var)
  end if
  if(var_name .eq. "SOILMETC")then
    in  = ptr->TPOOL_C
    var = in(:,5,:,:)
    return(var)
  end if
  if(var_name .eq. "SOILSTRC")then
    in  = ptr->TPOOL_C
    var = in(:,6,:,:)
    return(var)
  end if
  if(var_name .eq. "CWDC")then
    in  = ptr->TPOOL_C
    var = in(:,7,:,:)
    return(var)
  end if
  if(var_name .eq. "SURFMIC")then
    in  = ptr->TPOOL_C
    var = in(:,8,:,:)
    return(var)
  end if
  if(var_name .eq. "SOILMIC")then
    in  = ptr->TPOOL_C
    var = in(:,9,:,:)
    return(var)
  end if
  if(var_name .eq. "SLOWC")then
    in  = ptr->TPOOL_C
    var = in(:,10,:,:)
    return(var)
  end if
  if(var_name .eq. "PASSIVEC")then
    in  = ptr->TPOOL_C
    var = in(:,11,:,:)
    return(var)
  end if

  if(var_name .eq. "RESP_LEAFC")then
    in  = ptr->RESP_C
    var = in(:,0,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_WOODC")then
    in  = ptr->RESP_C
    var = in(:,1,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_FROOTC")then
    in  = ptr->RESP_C
    var = in(:,2,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_SURFMETC")then
    in  = ptr->RESP_C
    var = in(:,3,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_SURFSTRC")then
    in  = ptr->RESP_C
    var = in(:,4,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_SOILMETC")then
    in  = ptr->RESP_C
    var = in(:,5,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_SOILSTRC")then
    in  = ptr->RESP_C
    var = in(:,6,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_CWDC")then
    in  = ptr->RESP_C
    var = in(:,7,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_SURFMIC")then
    in  = ptr->RESP_C
    var = in(:,8,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_SOILMIC")then
    in  = ptr->RESP_C
    var = in(:,9,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_SLOWC")then
    in  = ptr->RESP_C
    var = in(:,10,:,:)
    return(var)
  end if
  if(var_name .eq. "RESP_PASSIVEC")then
    in  = ptr->RESP_C
    var = in(:,11,:,:)
    return(var)
  end if

  if(var_name .eq. "CLOSS_LEAF")then
    in  = ptr->CLOSS
    var = in(:,0,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_WOOD")then
    in  = ptr->CLOSS
    var = in(:,1,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_FROOT")then
    in  = ptr->CLOSS
    var = in(:,2,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_SURFMET")then
    in  = ptr->CLOSS
    var = in(:,3,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_SURFSTR")then
    in  = ptr->CLOSS
    var = in(:,4,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_SOILMET")then
    in  = ptr->CLOSS
    var = in(:,5,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_SOILSTR")then
    in  = ptr->CLOSS
    var = in(:,6,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_CWD")then
    in  = ptr->CLOSS
    var = in(:,7,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_SURFMIC")then
    in  = ptr->CLOSS
    var = in(:,8,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_SOILMIC")then
    in  = ptr->CLOSS
    var = in(:,9,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_SLOW")then
    in  = ptr->CLOSS
    var = in(:,10,:,:)
    return(var)
  end if
  if(var_name .eq. "CLOSS_PASSIVE")then
    in  = ptr->CLOSS
    var = in(:,11,:,:)
    return(var)
  end if

  if(var_name .eq. "LIVEFR_LEAFC")then
    in  = ptr->LIVEFR
    var = in(:,0,:,:)
    return(var)
  end if
  if(var_name .eq. "LIVEFR_WOODC")then
    in  = ptr->LIVEFR
    var = in(:,1,:,:)
    return(var)
  end if
  if(var_name .eq. "LIVEFR_FROOTC")then
    in  = ptr->LIVEFR
    var = in(:,2,:,:)
    return(var)
  end if


; if derived variable is not found, return an array of missing values.
; this is check for in the set code. size is irrelevant as long as
; the array is greater than 1.
  var = new(20,"float")
  return(var)

 end

;********************************************************
undef("regional_values")
function regional_values(x,ar,area,landfrac,scale_type,\
	regions_file,time,nTime,compare)
local area1,fland1,tmp,type,rank,regional_sum,box_n,box_w,box_e,box_s,weights_1n
begin
;********************************************************
  tmp  = stringtocharacter(scale_type) ; 
  type = charactertostring(tmp(6:9))   ; checking for Mean or Totl
  rank = dimsizes(dimsizes(x))         ; 3D or 4D? (dimensions: time, (lev),lat, lon)
;********************************************************
; make a missing value mask for area and land, based on 
; missing values from input variable assumed same for
;********************************************************

    box_n = regions_file->BOX_N
    box_s = regions_file->BOX_S
    box_w = regions_file->BOX_W
    box_e = regions_file->BOX_E

    if (nTime .gt. 1) then
       regional_sum = new(nTime,"double")
    end if

    if (nTime .eq. 13) then	; special case for monthly data	 (set 3)
	   endTime = nTime-2
    else			; annual data	 		 (set 6)
	   endTime = nTime-1
    end if

    ; define initial mask
    area1  = area
    fland1 = landfrac
    weights_1n = area
    weights_1n = -9999.
    if(rank.eq.2)then
      area1  = mask(area,       ismissing(x), False)
      fland1 = mask(landfrac,   ismissing(x), False)
      nmissing   = num(isnan_ieee(x) )
    end if
    if(rank.eq.3)then
      area1  = mask(area,       ismissing(x(0,:,:)), False)
      fland1 = mask(landfrac,   ismissing(x(0,:,:)), False)
      nmissing   = num(isnan_ieee(x(0,:,:)) )
    end if
    if(rank.eq.4)then
      area1  = mask(area,       ismissing(x(0,0,:,:)), False)
      fland1 = mask(landfrac,   ismissing(x(0,0,:,:)), False)
      nmissing   = num(isnan_ieee(x(0,:,:)) )
    end if
    pnMissing = nmissing

do t = 0,endTime
    if(rank.eq.2)then
    	nmissing = num(ismissing(x) )
    end if
    if(rank.eq.3)then
    	nmissing = num(ismissing(x(t,:,:)) )
    end if
    if(rank.eq.4)then
    	nmissing = num(ismissing(x(t,0,:,:)) )
    end if

    if (nmissing .ne. pnMissing) then

;********************************************************
;----------------------------------------------
; Normalized weights for each region and variable
;----------------------------------------------
; check for scale type
;********************************************************
	delete(area1)
        delete(fland1)
	delete(weights_1n)
  	area1  = area
  	fland1 = landfrac
  	weights_1n = area
  	weights_1n = -9999.

  	if(rank.eq.2)then
      		area1  = mask(area,       ismissing(x(:,:)), False)
      		fland1 = mask(landfrac,   ismissing(x(:,:)), False)
  	end if
  	if(rank.eq.3)then
      		area1  = mask(area,       ismissing(x(t,:,:)), False)
      		fland1 = mask(landfrac,   ismissing(x(t,:,:)), False)
  	end if
  	if(rank.eq.4)then
      		area1  = mask(area,       ismissing(x(t,0,:,:)), False)
      		fland1 = mask(landfrac,   ismissing(x(t,0,:,:)), False)
  	end if
        pnMissing = nmissing
     end if

     if (compare .eq. "model") then
     ; calculate area mean 		
     if(type .eq. "Mean")then		; sets 3, 5 (some) and 6
        	weights_1n ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = \
             	(area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
             fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))/ \
          sum(area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
             fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
      end if
  ; calculate area total 
     if(type .eq. "Totl")then		; set 5 (some)
        weights_1n ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = \
             (area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
             fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
     end if
  end if
  if (compare .eq. "obs") then
     if(type .eq. "Mean")then		; sets 3, 5 (some) and 6
	  if (.not. all(fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) .lt. 0 ) ) then

             if (sum(area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
               fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})) \
               .gt. 0.) then
                weights_1n ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = \
                     (area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
                     fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))/ \
                  sum(area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
                     fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
              else
                weights_1n ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = 0.
             end if

          end if			; end .all. loop
      end if
  end if


;----------------------------------------------
; Regional averages
;----------------------------------------------

;----------------
;  Monthly trends
;----------------

    if (nTime .gt. 1) then
        regional_sum(t) = sum((x(t,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))* \
                      weights_1n(  {box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
;--------------
;  Annual sums
;--------------
    else
       regional_sum = sum((x({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))* \
                weights_1n(  {box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
       return(regional_sum)
    end if

    pnMissing = nmissing
 end do		; end endtime loop
;-----------------------------------------------
; repeat last monthly value for set 3 plots
;-----------------------------------------------
   if (nTime .eq. 13) then	; special case for monthly data  (set 3)
             regional_sum(12) = regional_sum(0)
   end if

   return(regional_sum)
end
;*************************************************************************************************
undef("regional_values_set6")
function regional_values_set6(x,ar,area,landfrac,scale_type,\
	regions_file,time,nTime,compare)
local area1,fland1,tmp,type,rank,regional_sum,box_n,box_w,box_e,box_s,weights_1n
begin
;********************************************************
  tmp  = stringtocharacter(scale_type) ; 
  type = charactertostring(tmp(6:9))   ; checking for Mean or Totl
  rank = dimsizes(dimsizes(x))         ; 3D or 4D? (dimensions: time, (lev),lat, lon)
;********************************************************
; make a missing value mask for area and land, based on 
; missing values from input variable assumed same for
;********************************************************

    box_n = regions_file->BOX_N
    box_s = regions_file->BOX_S
    box_w = regions_file->BOX_W
    box_e = regions_file->BOX_E

    regional_sum = new(nTime,"double")
    endTime = nTime-1

    ; define initial mask
    area1  = area
    fland1 = landfrac
    weights_1n = area
    weights_1n = -9999.
    if(rank.eq.2)then
      area1  = mask(area,       ismissing(x), False)
      fland1 = mask(landfrac,   ismissing(x), False)
      nmissing   = num(isnan_ieee(x) )
    end if
    if(rank.eq.3)then
      area1  = mask(area,       ismissing(x(0,:,:)), False)
      fland1 = mask(landfrac,   ismissing(x(0,:,:)), False)
      nmissing   = num(isnan_ieee(x(0,:,:)) )
    end if
    if(rank.eq.4)then
      area1  = mask(area,       ismissing(x(0,0,:,:)), False)
      fland1 = mask(landfrac,   ismissing(x(0,0,:,:)), False)
      nmissing   = num(isnan_ieee(x(0,:,:)) )
    end if
    pnMissing = nmissing

do t = 0,endTime
    if(rank.eq.2)then
    	nmissing = num(ismissing(x) )
    end if
    if(rank.eq.3)then
    	nmissing = num(ismissing(x(t,:,:)) )
    end if
    if(rank.eq.4)then
    	nmissing = num(ismissing(x(t,0,:,:)) )
    end if

    if (nmissing .ne. pnMissing) then

;********************************************************
;----------------------------------------------
; Normalized weights for each region and variable
;----------------------------------------------
; check for scale type
;********************************************************
	delete(area1)
        delete(fland1)
	delete(weights_1n)
  	area1  = area
  	fland1 = landfrac
  	weights_1n = area
  	weights_1n = -9999.

  	if(rank.eq.2)then
      		area1  = mask(area,       ismissing(x(:,:)), False)
      		fland1 = mask(landfrac,   ismissing(x(:,:)), False)
  	end if
  	if(rank.eq.3)then
      		area1  = mask(area,       ismissing(x(t,:,:)), False)
      		fland1 = mask(landfrac,   ismissing(x(t,:,:)), False)
  	end if
  	if(rank.eq.4)then
      		area1  = mask(area,       ismissing(x(t,0,:,:)), False)
      		fland1 = mask(landfrac,   ismissing(x(t,0,:,:)), False)
  	end if
        pnMissing = nmissing
    end if

    if (.not. all(fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) .lt. 0 ) ) then

        if (sum(area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
           fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})) \
           .gt. 0.) then

        ; calculate area mean 		
           if(type .eq. "Mean")then		
        	weights_1n ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = \
             	   (area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
                   fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))/ \
                   sum(area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
                   fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
           end if
        ; calculate area total 
           if(type .eq. "Totl")then		
              weights_1n ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = \
                 1.e6*(area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
                 fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
           end if
     
        else
              weights_1n ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = 0.
        end if

    end if

;----------------------------------------------
; Regional averages
;----------------------------------------------

    regional_sum(t) = sum((x(t,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))* \
                  weights_1n(  {box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))

    pnMissing = nmissing
 end do		; end endtime loop

   return(regional_sum)
end
;*************************************************************************************************

;*************************************************************************************************
undef("interp_grid")
function interp_grid(x1,x2,nlat1,nlat2,lat1,lat2,lon1,lon2)
begin
   if (nlat1 .gt. nlat2) then	; interpolation x1 to x2 grid
	x = linint2_Wrap(lon1,lat1,x1,True,lon2,lat2,0)
   end if
   if (nlat2 .gt. nlat1) then	; interpolation x2 to x1 grid
	x = linint2_Wrap(lon2,lat2,x2,True,lon1,lat1,0)
   end if

   return(x)
end
;********************************************************
;********************************************************************
;********************************************************************
undef("regional_albedo")		; set3
function regional_albedo(x,ar,area,landfrac,scale_type,\
	regions_file,nmons,compare)
local area1,land1,tmp,type,rank,regional_sum,box_n,box_w,box_e,box_s
begin
;********************************************************
  tmp  = stringtocharacter(scale_type) ; 
  type = charactertostring(tmp(6:9))   ; checking for Mean or Totl
  rank = dimsizes(dimsizes(x))         ; 3D or 4D? (dimensions: time, (lev),lat, lon)
;********************************************************

   box_n = regions_file->BOX_N
   box_s = regions_file->BOX_S
   box_w = regions_file->BOX_W
   box_e = regions_file->BOX_E

   endTime = nmons-2
   regional_sum = new(nmons,"double")


; --------------------------------------------------
; Calculate weights; note that weights for Albedo need to reflect monthly area.
; --------------------------------------------------

do time = 0,endTime

;********************************************************
; make a missing value mask for area and land, based on 
; missing values from input variable assumed same for
;********************************************************

        area1   = area
        fland1  = landfrac
   	weights_1n = area	; trick to create variable with correct coord dimensions
   	weights_1n = -9999.

       	area1  = mask(area,     ismissing(x(time,:,:)), False)
        fland1 = mask(landfrac, ismissing(x(time,:,:)), False)

;----------------------------------------------
; Normalized weights for each region and variable
;----------------------------------------------
       	weights_1n ({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}) = \
             (area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
             fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))/ \
          sum(area1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)})* \
             fland1({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))

;----------------------------------------------
; Regional averages of Monthy trends
;----------------------------------------------
       	regional_sum(time) = sum((x(time,{box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))* \
                              weights_1n({box_s(ar):box_n(ar)},{box_w(ar):box_e(ar)}))
	delete(area1)
	delete(fland1)
	delete(weights_1n)
end do

;-----------------------------------------------
; repeat last monthly value for set 3 plots
;-----------------------------------------------
       regional_sum(12) = regional_sum(0)
       return(regional_sum)
end
;*************************************************************************************************
undef("derive_del13C")
function derive_del13C(var_name:string,ptr:file,scale_type:string,nyrs:integer,set:integer)
; derive various variables
local nlev,landfrac,area,c13,ic13,ctot,ictot,ctotName,c13Name
begin
    tmp      = stringtochar(var_name)
    ctotName = charactertostring(tmp(4:))
    c13Name  = charactertostring(tmp)
    if(isfilevar(ptr,c13Name) .and. isfilevar(ptr,ctotName))then
        ictot    = ptr->$ctotName$
        ic13     = ptr->$c13Name$
    else
        print("variable "+ var_name+ " is not a defined variable")
	; if derived variable is not found, return an array of missing values.
  	var  = new(1,"float")
	return(var)
    end if

    landfrac = ptr->landfrac
    area     = ptr->area
    if (set .eq. 1 .or. set .eq. 5) then
        if(isfilevar(ptr,"levsoi")) then
        	nlev = getfilevardimsizes(ptr,"levsoi")
        end if
        if(isfilevar(ptr,"levgrnd")) then
        	nlev = getfilevardimsizes(ptr,"levgrnd")
        end if
	c13  = global_values(var_name, ic13, area,landfrac,scale_type,nyrs,nlev)
	ctot = global_values(var_name, ictot,area,landfrac,scale_type,nyrs,nlev)
	if (set .eq. 5) then
		c13  =  avg(c13)    ; average over time period
		ctot =  avg(ctot)   ; average over time period
	end if
    else 
	ctot = ictot
	c13  = ic13
    end if

    if (any(ctot .eq. 0)) then  ; set zeros to _FillValue
      ctot = mask(ctot,(ctot .eq. 0),False)
    end if
    var = ctot ; trick to retain meta data
    var = ( ((c13/ctot) / 0.01112) - 1.) * 1000.
    ; NOTE:  del13C :  valid range = -40 to 0 per mil PDB
    ; values outside this range are considered spurious and set to missing.
    if (var_name .eq. "C13_NEP" .or. var_name .eq. "C13_NEE") then
      	var = mask(var,(var .lt. -40 .or. var .gt. 0),False)
    end if
    return(var)
end 
;*************************************************************************************************

undef("catchNaN")
function catchNaN(x)
begin
           ; catch NaNs

           if (any(isnan_ieee(x))) then
               nNaN = num(isnan_ieee(x))
	       x1d = ndtooned(x)
	       dsizes_x = dimsizes(x)
               indices = ind_resolve(ind(isnan_ieee(x1d)), dsizes_x)
               value = x@_FillValue
               print("found " + nNaN + " NaNs ")
	       if (nNaN .gt. 5) then
			loopNum = 5
	       else
			loopNum = nNaN
	       end if
	       do i = 0, loopNum-1
               		print("   Sample NaN Coords: time = " + indices(i,0) + " latDim =  " + indices(i,1) + " lonDim " + indices(i,2) )
	       end do

               replace_ieeenan(x, value, 0)
           end if

	   return(x)

end

;**************************************************************************************************
undef("set2ResMvM")
function set2ResMvM(res)
begin
    	raster 			     = getenv("raster")
    	paleo 			     = getenv("paleo")
     proj_type     = getenv("projection")

     res                          = True
     res@cnFillOn                 = True
     res@cnMissingValFillColor    = "white"
;;     if (raster .eq. 1) then
     if (raster .eq. "True") then
;;        res@cnRasterModeOn     = True
        res@cnFillMode           = "RasterFill"
     end if
;;     if (paleo .eq. 1) then
     if (paleo .eq. "True") then
        res@cnFillMode         = "CellFill"
     end if
     res@cnInfoLabelOn            = False
     res@cnLinesOn                = False
     res@gsnDraw                  = False
     res@gsnFrame           = False
;     res@gsnLeftStringParallelPosF = 0.2  ; Values set in set_2.ncl
     res@gsnLeftStringOrthogonalPosF = -1.25
     res@tiMainFont            = "Helvetica"
     res@cnLabelBarEndStyle = "IncludeMinMaxLabels"
     if (proj_type.eq.1) then
        res@mpGridLonSpacingF     = 60.0
        res@mpGridLatSpacingF     = 30.0
        res@mpGridLineDashPattern    =  2        ; Set grid line dash pattern (dash)
        res@mpGridLineThicknessF     = 0.5       ; Set grid line thickness
     else
        res@mpProjection = "Robinson"
        res@mpPerimOn    = False
        res@mpGridLineColor = "transparent"       
     end if
     res@mpFillOn           = False
     res@mpOutlineOn           = True
     res@mpGridAndLimbOn       = True
     res@gsnPaperOrientation      = "landscape"
	return(res)

end

;**************************************************************************************************
undef("set2Res")
function set2Res(res)
begin
    	raster 			     = getenv("raster")
    	paleo 			     = getenv("paleo")
     proj_type     = getenv("projection")

     res                          = True
     res@cnFillOn                 = True
     res@cnMissingValFillColor    = "white"
;;     if (raster .eq. 1) then
     if (raster .eq. "True") then
;;        res@cnRasterModeOn     = True
        res@cnFillMode           = "RasterFill"
     end if
;;     if (paleo .eq. 1) then
     if (paleo .eq. "True") then
        res@cnFillMode         = "CellFill"
     end if
     res@cnInfoLabelOn            = False
     res@cnLinesOn                = False
     res@gsnDraw                  = False
     res@gsnFrame                 = False
     res@lbTitleOn                = False
     res@tiMainFont               = "Helvetica"
     res@cnLabelBarEndStyle = "IncludeMinMaxLabels"
     if (proj_type.eq.1) then
        res@mpGridLonSpacingF        = 60.0
        res@mpGridLatSpacingF        = 30.0
        res@mpGridLineDashPattern    =  2           ; Set grid line dash pattern (dash)
        res@mpGridLineThicknessF     = 0.5          ; Set grid line thickness
     else
        res@mpProjection = "Robinson"
        res@mpPerimOn    = False
        res@mpGridLineColor = "transparent"
        res@gsnLeftStringParallelPosF = 0.1
        res@gsnRightStringParallelPosF = 0.9        
     end if
     res@mpFillOn                 = False
     res@mpOutlineOn              = True
     res@mpGridAndLimbOn          = True
     return(res)
end

;**************************************************************************************************
undef("set9Res")
function set9Res(res)
begin

   proj_type     = getenv("projection")

   res                          = True
   res@cnSpanFillPalette        = True
   res@cnFillOn                 = True
;;   res@cnRasterModeOn           = True
   res@cnFillMode           = "RasterFill"	
   res@cnInfoLabelOn            = False
   res@cnLinesOn                = False
   res@gsnDraw                  = False
   res@gsnFrame                 = False
   res@lbTitleOn                = False
   res@tiMainFont               = "Helvetica"
   res@cnMissingValFillColor    = "white"

   res@gsnRightString           = ""
   res@gsnLeftString            = ""
   res@pmLabelBarHeightF        = 0.08
   res@pmLabelBarWidthF         = 0.6
   res@pmLabelBarOrthogonalPosF = -.02
   res@tiMainOffsetYF           = -.005
   res@lbLabelFontHeightF       = 0.016

   res@gsnStringFontHeightF            = 0.016
   res@tiMainFontHeightF        = 0.02

   res@gsnSpreadColors          = False


   if (proj_type.eq.0) then
      res@mpProjection = "Robinson"
      res@mpPerimOn    = False
      res@mpGridLineColor = "transparent"   
   end if
   res@mpFillOn                 = False
   res@mpOutlineOn              = True
   res@mpGridAndLimbOn          = True
   return(res)
end

;***************************************************************************
undef("set9Resa")
function set9Resa(res)
begin
        proj_type     = getenv("projection")
        ; Define plot resources:
        res                          = True
        res@gsnStringFontHeightF            = 0.016
        res@tiMainFontHeightF        = 0.02
        res@cnFillOn                 = True
        res@cnFillMode      	        = "CellFill"
        res@cnInfoLabelOn            = False
        res@cnLinesOn                = False
        res@gsnDraw                  = False
        res@gsnFrame                 = False
        res@pmLabelBarHeightF        = 0.08
        res@pmLabelBarWidthF         = 0.6
        res@pmLabelBarOrthogonalPosF = -.02
        res@lbTitleOn                = True
        res@lbTitlePosition          = "bottom"
        res@lbLabelFontHeightF       = 0.016
        res@lbTitleFontHeightF       = 0.016
        res@tiMainFont               = "Helvetica"
        res@mpGridLonSpacingF        = 60.0
        res@mpGridLatSpacingF        = 30.0
        res@mpOutlineOn              = True
        res@mpGridAndLimbOn          = True
        res@mpGridLineDashPattern    =  2           ; Set grid line dash pattern (dash)
        res@mpGridLineThicknessF     = 0.5          ; Set grid line thickness
        if (proj_type.eq.0) then
           res@mpProjection = "Robinson"
           res@mpPerimOn    = False
           res@mpGridLineColor = "transparent"   
        end if
        res@mpFillOn                 = False
        res@mpOutlineOn              = True
        return(res)
end

;***************************************************************************
undef("getLimits")
function getLimits(val)
local pCut, pLow, pHigh
begin
     pCut  = 5
     pLow  = 0.05
     pHigh = 0.95
     useVal = new(2,double)

     x = ndtooned(val)
     x@_FillValue = 1e30
     nMsg  = num(ismissing(x))  
     nGood = num(.not.ismissing(x))  

     qsort(x)
     iLow  = floattointeger( pLow*nGood)
     useVal(0)  = x(iLow )
     iHigh = floattointeger( pHigh*nGood)
     useVal(1)  = x(iHigh)
     delete(x)
     return(useVal)

end
