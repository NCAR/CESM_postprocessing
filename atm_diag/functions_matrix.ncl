; functions_matrix.ncl
; Benjamin Hillman May 2011
; Functions for working with COSP joint histogram vars
;********************************************************
  undef("get_CLMISR")
  function get_CLMISR(inptr:file,outptr:file)
  begin
    if (isfilevar(outptr,"CLMISR")) then
      clmisr = outptr->CLMISR
    else
      vFlag = False
      if (isfilevar(inptr,"CLMISR")) then
        tmp = inptr->CLMISR(0,:,:,:,:)
        if (typeof(tmp).eq."double") then 
          clmisr = dble2flt(tmp)
        else
          clmisr = tmp
        end if
        delete(tmp)
        vFlag = True
      end if
      
;     CAM4/CAM5 OUTPUT
      if (.not.vFlag .and. isfilevar(inptr,"CLD_MISR")) then
        tmp = inptr->CLD_MISR(0,:,:,:,:)
        if (typeof(tmp).eq."double") then 
          clmisr = dble2flt(tmp(cosp_htmisr|:,cosp_tau|:,lat|:,lon|:))
        else
          clmisr = tmp(cosp_htmisr|:,cosp_tau|:,lat|:,lon|:)
        end if
        delete(tmp)
        vFlag = True
      end if
;     CAM3 output
      if (.not.vFlag .and. isfilevar(inptr,"FMISR1")) then
;       read MISR cthtau from file
        tmp = inptr->FMISR1(0,:,:,:)
        if (typeof(tmp).eq."double") then 
          fmisr1 = dble2flt(tmp(misr_cthtau|:,lat|:,lon|:))
        else
          fmisr1 = tmp(misr_cthtau|:,lat|:,lon|:)
        end if
        delete(tmp)

;       get coordinate dimensions so fmisr1 can be reshaped
        misr_cth = inptr->misr_cth
        misr_tau = inptr->misr_tau
        lat      = inptr->lat
        lon      = inptr->lon
        ncth     = dimsizes(misr_cth)
        ntau     = dimsizes(misr_tau)
        nlat     = dimsizes(lat)
        nlon     = dimsizes(lon)
        delete([/misr_cth,misr_tau,lat,lon/])

;       reshape FMISR1
        clmisr = onedtond(ndtooned(fmisr1),(/ncth,ntau,nlat,nlon/))

        vFlag = True
      end if

      if (vFlag) then
;       lat and lon coordinate axes
        lat = inptr->lat
        lon = inptr->lon

;       tau coordinate axis
        misr_tau = (/ \
          0.15, \
          0.80, \
          2.45, \
          6.50, \
          16.20, \
          41.5, \
          100.0 \
        /)
        misr_tau@long_name = "Optical Depth"
        misr_tau@units     = "unitless"
        misr_tau@bounds    = "misr_bnds_bnds"
        misr_tau_bnds = (/ \
          (/0.0, 0.3/), \
          (/0.3, 1.3/), \
          (/1.3, 3.6/), \
          (/3.6, 9.4/), \
          (/9.4, 23.0/), \
          (/23.0,60.0/), \
          (/60.0,379.0/) \
        /)

;       cth coordinate axis
        misr_cth = (/ \
          -1.00, \
           0.25, \
           0.75, \
           1.25, \
           1.75, \
           2.25, \
           2.75, \
           3.50, \
           4.50, \
           6.00, \
           8.00, \
          10.00, \
          12.00, \
          14.00, \
          16.00, \
          20.00 \
        /)
        misr_cth@long_name = "Cloud Top Height"
        misr_cth@units     = "km"
        misr_cth@bounds = "misr_cth_bnds"
        misr_cth_bnds = (/ \
          (/-1, -1/), \
          (/0, 0.5/), \
          (/0.5, 1/), \
          (/1, 1.5/), \
          (/1.5, 2/), \
          (/2, 2.5/), \
          (/2.5, 3/), \
          (/3, 4/), \
          (/4, 5/), \
          (/5, 7/), \
          (/7, 9/), \
          (/9, 11/), \
          (/11, 13/), \
          (/13, 15/), \
          (/15, 17/), \
          (/17, 23/) \
        /)

;       remove bins
        dims = dimsizes(clmisr)
        tmp = clmisr( \
          dims(0)-dimsizes(misr_cth):, \
          dims(1)-dimsizes(misr_tau):, \
          :,: \
        )
        delete(clmisr)
        clmisr = tmp
        delete(tmp)
        delete(dims)

;       name coordinate axes and attributes
        clmisr!0 = "misr_cth"
        clmisr!1 = "misr_tau"
        clmisr!2 = "lat"
        clmisr!3 = "lon"

;       assign coordinate arrays
        clmisr&misr_tau = misr_tau
        clmisr&misr_cth = misr_cth
        clmisr&lat = lat
        clmisr&lon = lon

;       attributes
        clmisr@long_name   = "MISR cloud amount"
        clmisr@units       = "percent"
        clmisr@_FillValue     = -999.0
        clmisr@_missing_value = -999.0

;       mask land
        landFlag = False
        if (isfilevar(inptr,"LANDFRAC")) then
          tmp = inptr->LANDFRAC(0,:,:)
          if (typeof(tmp).eq."double") then 
            land = dble2flt(tmp)
          else
            land = tmp
          end if
          delete(tmp)
          landFlag = True
        end if
        if (isfilevar(inptr,"land_mask")) then
          tmp = inptr->land_mask
          if (typeof(tmp).eq."double") then 
            land = dble2flt(tmp)
          else
            land = tmp
          end if
          delete(tmp)
          landFlag = True
        end if
        if (landFlag) then
          clmisr = mask(clmisr,land.gt.0.5,False)
          delete(land)
        end if

;       mask ice
        iceFlag = False
        if (isfilevar(inptr,"ICEFRAC")) then
          tmp = inptr->ICEFRAC(0,:,:)
          if (typeof(tmp).eq."double") then 
            ice = dble2flt(tmp)
          else
            ice = tmp
          end if
          delete(tmp)
          iceFlag = True
        end if
        if (isfilevar(inptr,"ice_mask")) then
          tmp = inptr->ice_mask(0,:,:)
          if (typeof(tmp).eq."double") then 
            ice = dble2flt(tmp)
          else
            ice = tmp
          end if
          delete(tmp)
          iceFlag = True
        end if
        if (iceFlag) then
          clmisr = mask(clmisr,ice.gt.0.5,False)
          delete(ice)
        end if

;       write to output file
        outptr->CLMISR = clmisr
        outptr->misr_tau_bnds = misr_tau_bnds
        outptr->misr_cth_bnds = misr_cth_bnds
      else
        clmisr = -999.0
      end if
    end if
    return(clmisr)
  end

  undef("get_CLISCCP")
  function get_CLISCCP(inptr:file,outptr:file)
  begin
    if (isfilevar(outptr,"CLISCCP")) then
      clisccp = outptr->CLISCCP
    else
      vFlag = False
      if (isfilevar(inptr,"CLISCCP")) then
        tmp = inptr->CLISCCP(0,:,:,:,:)
        if (typeof(tmp).eq."double") then 
          clisccp = dble2flt(tmp)
        else
          clisccp = tmp
        end if
        delete(tmp)
        vFlag = True
      end if
;     CAM4/CAM5 output
      if (.not.vFlag .and. isfilevar(inptr,"FISCCP1_COSP")) then
;       read ISCCP prs-tau from file
        tmp = inptr->FISCCP1_COSP(0,:,:,:,:)
        if (typeof(tmp).eq."double") then 
          clisccp = dble2flt(tmp(cosp_prs|:,cosp_tau|:,lat|:,lon|:))
        else
          clisccp = tmp(cosp_prs|:,cosp_tau|:,lat|:,lon|:)
        end if
        delete(tmp)
        vFlag = True
      end if
;     CAM3-type output 
      if (.not.vFlag .and. isfilevar(inptr,"FISCCP1")) then
;       read combined pctau variable from file
        tmp = inptr->FISCCP1(0,:,:,:)
        if (typeof(tmp).eq."double") then 
          fisccp1 = dble2flt(tmp(isccp_prstau|:,lat|:,lon|:))
        else
          fisccp1 = tmp(isccp_prstau|:,lat|:,lon|:)
        end if
        delete(tmp)

;       get coordinate variables sizes so fisccp1 can be reshaped
        isccp_prs = inptr->isccp_prs
        isccp_tau = inptr->isccp_tau
        lat = inptr->lat
        lon = inptr->lon
        nprs = dimsizes(isccp_prs)
        ntau = dimsizes(isccp_tau)
        nlat = dimsizes(lat)
        nlon = dimsizes(lon)
        delete([/isccp_prs,isccp_tau,lat,lon/])

;       reshape pctau
        clisccp = onedtond(ndtooned(fisccp1),(/nprs,ntau,nlat,nlon/))

        vFlag = True
      end if
      if (vFlag) then
;       lat and lon coordinate arrays
        lat = inptr->lat
        lon = inptr->lon

;       tau coordinate array
        isccp_tau = (/ \
          0.15, \
          0.66, \
          2.45, \
          6.5, \
          16.2, \
          41.5, \
          100.0 \
        /)
        isccp_tau@long_name = "Optical Depth"
        isccp_tau@units     = "unitless"
        isccp_tau@bounds    = "isccp_tau_bnds"
        isccp_tau_bnds = (/ \
          (/ 0.0,  0.3/), \
          (/ 0.3,  1.3/), \
          (/ 1.3,  3.6/), \
          (/ 3.6,  9.4/), \
          (/ 9.4, 23.0/), \
          (/23.0, 60.0/), \
          (/60.0,100.0/) \
        /)

;       prs coordinate array
        isccp_prs = (/950, 740, 620, 500, 375, 245, 90.5/)
        isccp_prs@long_name = "Cloud Top Pressure"
        isccp_prs@units     = "hPa"
        isccp_prs@bounds    = "isccp_prs_bnds"
        isccp_prs_bnds = (/ \
          (/1100, 800/), \
          (/800, 680/), \
          (/680, 560/), \
          (/560, 440/), \
          (/440, 310/), \
          (/310, 180/), \
          (/180, 1  /) \
        /)

;       remove bins if necessary
        dims = dimsizes(clisccp)
        tmp = clisccp( \
          dims(0)-dimsizes(isccp_prs):, \
          dims(1)-dimsizes(isccp_tau):, \
          :,: \
        )
        delete(clisccp)
        clisccp = tmp
        delete(tmp)
        delete(dims)

;       name coordinate axes and attributes
        clisccp!0 = "isccp_prs"
        clisccp!1 = "isccp_tau"
        clisccp!2 = "lat"
        clisccp!3 = "lon"

;       assign coordinate axes
        clisccp&isccp_prs = isccp_prs
        clisccp&isccp_tau = isccp_tau
        clisccp&lat = lat
        clisccp&lon = lon

;       assign variable attributes
        clisccp@long_name   = "ISCCP cloud amount"
        clisccp@units       = "percent"
        clisccp@_FillValue     = -999.0
        clisccp@_missing_value = -999.0

;       write to output file
        outptr->CLISCCP = clisccp
        outptr->isccp_tau_bnds = isccp_tau_bnds
        outptr->isccp_prs_bnds = isccp_prs_bnds
      else
        clisccp = -999.0
      end if
    end if
    return(clisccp)
  end

  undef("get_CLMODIS")
  function get_CLMODIS(inptr:file,outptr:file)
  begin
    if (isfilevar(outptr,"CLMODIS")) then
      clmodis = outptr->CLMODIS
    else
      vFlag = False
      if (isfilevar(inptr,"CLMODIS").and.isfilevar(inptr,"modis_tau").and.isfilevar(inptr,"modis_prs")) then
        tmp = inptr->CLMODIS(0,:,:,:,:)
        if (typeof(tmp).eq."double") then 
          clmodis = dble2flt(tmp)
        else
          clmodis = tmp
        end if
        delete(tmp)
        vFlag = True
      end if
;     CAM4/CAM5 output
      if (.not.vFlag .and. isfilevar(inptr,"CLMODIS").and.isfilevar(inptr,"cosp_prs").and.isfilevar(inptr,"cosp_tau_modis")) then
        tmp = inptr->CLMODIS(0,:,:,:,:)
        if (typeof(tmp).eq."double") then 
          clmodis = dble2flt(tmp(cosp_prs|:,cosp_tau_modis|:,lat|:,lon|:))
        else
          clmodis = tmp(cosp_prs|:,cosp_tau_modis|:,lat|:,lon|:)
        end if
        delete(tmp)
        vFlag = True
      end if
;     CAM3-type output 
      if (.not.vFlag .and. isfilevar(inptr,"FMODIS1")) then

;       read combined pctau variable from file
        tmp = inptr->FMODIS1(0,:,:,:)
        if (typeof(tmp).eq."double") then 
          fmodis1 = dble2flt(tmp(modis_prstau|:,lat|:,lon|:))
        else
          fmodis1 = tmp(modis_prstau|:,lat|:,lon|:)
        end if
        delete(tmp)

;       get coordinate variable sizes so that fmodis1 can be reshaped
        modis_prs = inptr->modis_prs
        modis_tau = inptr->modis_tau
        lat       = inptr->lat
        lon       = inptr->lon
        nprs      = dimsizes(modis_prs)
        ntau      = dimsizes(modis_tau)
        nlat      = dimsizes(lat)
        nlon      = dimsizes(lon)
        delete([/modis_prs,modis_tau,lat,lon/])

;       reshape pctau
        clmodis = onedtond(ndtooned(fmodis1),(/nprs,ntau,nlat,nlon/))

        vFlag = True
      end if
      if (vFlag) then
;       lat and lon coordinate arrays
        lat = inptr->lat
        lon = inptr->lon

;       tau coordinate axis
        modis_tau = (/ \
;         0.15, \
          0.8, \
          2.45, \
          6.5, \
          16.2, \
          41.5, \
          80 \
        /)
        modis_tau@long_name = "Optical Depth"
        modis_tau@units     = "unitless"
        modis_tau@bounds    = "modis_tau_bnds"
        modis_tau_bnds = (/ \
;         (/ 0.0,  0.3/), \
          (/ 0.3,  1.3/), \
          (/ 1.3,  3.6/), \
          (/ 3.6,  9.4/), \
          (/ 9.4, 23.0/), \
          (/23.0, 60.0/), \
          (/60.0,100.0/) \
        /)

;       prs coordinate axis
        modis_prs = (/950, 740, 620, 500, 375, 245, 90/)
        modis_prs@long_name = "Cloud Top Pressure"
        modis_prs@units     = "hPa"
        modis_prs_bnds = (/ \
          (/1100.0, 800.0/), \
          (/ 800.0, 680.0/), \
          (/ 680.0, 560.0/), \
          (/ 560.0, 440.0/), \
          (/ 440.0, 310.0/), \
          (/ 310.0, 180.0/), \
          (/ 180.0,   0.0/) \
        /)

;       remove bins if necessary
        dims = dimsizes(clmodis)
        tmp = clmodis( \
          dims(0)-dimsizes(modis_prs):, \
          dims(1)-dimsizes(modis_tau):, \
          :,: \
        )
        delete(clmodis)
        clmodis = tmp
        delete(tmp)
        delete(dims)

;       name coordinate axes and attributes
        clmodis!0 = "modis_prs"
        clmodis!1 = "modis_tau"
        clmodis!2 = "lat"
        clmodis!3 = "lon"

;       assign coordinate axes
        clmodis&modis_prs = modis_prs
        clmodis&modis_tau = modis_tau
        clmodis&lat = lat
        clmodis&lon = lon

;       assign variable attributes
        clmodis@long_name   = "MODIS cloud amount"
        clmodis@units       = "percent"
        clmodis@_FillValue     = -999.0
        clmodis@_missing_value = -999.0

;       write to output file
        outptr->CLMODIS = clmodis
      else
        clmodis = -999.0
      end if
    end if
    return(clmodis)
  end

  undef("get_CFAD_DBZE94_CS")
  function get_CFAD_DBZE94_CS(inptr:file,outptr:file)
  begin
    if (isfilevar(outptr,"CFAD_DBZE94")) then
      cfad = outptr->CFAD_DBZE94
    else
;     CAM4/CAM5 output
      if (isfilevar(inptr,"CFAD_DBZE94_CS")) then
;       read CFAD from file
        tmp = inptr->CFAD_DBZE94_CS(0,:,:,:,:)
        if (typeof(tmp).eq."double") then 
          cfad = dble2flt(tmp(cosp_ht|:,cosp_dbze|:,lat|:,lon|:))
        else
          cfad = tmp(cosp_ht|:,cosp_dbze|:,lat|:,lon|:)
        end if
        delete(tmp)

;       get coordinate variables
        tmp = inptr->cosp_ht
        if (typeof(tmp).eq."double") then
          cosp_ht = dble2flt(tmp)
        else
          cosp_ht = tmp
        end if
        delete(tmp)
        tmp = inptr->cosp_dbze
        if (typeof(tmp).eq."double") then
          cosp_dbze = dble2flt(tmp)
        else
          cosp_dbze = tmp
        end if
        delete(tmp)
        tmp = inptr->lat
        if (typeof(tmp).eq."double") then
          lat = dble2flt(tmp)
        else
          lat = tmp
        end if
        delete(tmp)
        tmp = inptr->lon
        if (typeof(tmp).eq."double") then
          lon = dble2flt(tmp)
        else
          lon = tmp
        end if
        delete(tmp)

        cosp_ht@long_name = "Height Above Mean Sea Level (km)"
        cosp_ht@units = "km"

        cosp_dbze@long_name = "Radar Reflectivity Factor (dBZ)"
        cosp_dbze@units = "dBZ"

        cfad!0 = "cosp_ht"
        cfad!1 = "cosp_dbze"
        cfad!2 = "lat"
        cfad!3 = "lon"

        cfad&cosp_ht   = cosp_ht
        cfad&cosp_dbze = cosp_dbze
        cfad&lat  = lat 
        cfad&lon  = lon 

;       convert to percent
        cfad = cfad*100.0
        cfad@units = "percent"

;       assign attributes
        cfad@_FillValue     = -999.0
        cfad@_missing_value = -999.0

        outptr->CFAD_DBZE94 = cfad

      else
        cfad = -999.0
      end if
    end if
    return(cfad)
  end

  undef("get_CFAD_SR532_CAL")
  function get_CFAD_SR532_CAL(inptr:file,outptr:file)
  begin
    if (isfilevar(outptr,"CFAD_SR532_CAL")) then
      cfad = outptr->CFAD_SR532_CAL
    else
;     CAM4/CAM5 output
      if (isfilevar(inptr,"CFAD_SR532_CAL")) then
;       read CFAD from file
        tmp = inptr->CFAD_SR532_CAL(0,:,:,:,:)
        if (typeof(tmp).eq."double") then 
          tmp = dble2flt(tmp)
        else
          tmp = tmp
        end if
        delete(tmp)
        cfad_tmp = tmp(cosp_ht|:,cosp_sr|:,lat|:,lon|:)
        delete(tmp)

;       get coordinate variables
        tmp = inptr->cosp_ht
        if (typeof(tmp).eq."double") then
          cosp_ht = dble2flt(tmp)
        else
          cosp_ht = tmp
        end if
        delete(tmp)
        tmp = inptr->cosp_sr
        if (typeof(tmp).eq."double") then
          cosp_sr = dble2flt(tmp)
        else
          cosp_sr = tmp
        end if
        delete(tmp)
        tmp = inptr->lat
        if (typeof(tmp).eq."double") then
          lat = dble2flt(tmp)
        else
          lat = tmp
        end if
        delete(tmp)
        tmp = inptr->lon
        if (typeof(tmp).eq."double") then
          lon = dble2flt(tmp)
        else
          lon = tmp
        end if
        delete(tmp)

;       normalize
;       NOTE: This is NOT right yet! Waiting for Jen to have a discussion
;       with the LIDAR people about the proper way to normalize the
;       CALIPSO output from the simulator and from the obs data.
        cfad_tmp = cfad_tmp*50.0
        counts = dim_sum_Wrap(cfad_tmp(cosp_ht|:,lat|:,lon|:,cosp_sr|:))
        cfad = cfad_tmp
        do i = 0,dimsizes(cosp_sr)
          cfad(:,i,:,:) = cfad_tmp(:,i,:,:)/counts       ; do not use (:,:,:)
       ;;;cfad(:,i,:,:) = cfad_tmp(:,i,:,:)/counts(:,:,:)
        end do
        
        cfad!0 = "cosp_ht"
        cfad!1 = "cosp_sr"
        cfad!2 = "lat"
        cfad!3 = "lon"

        cfad&cosp_ht   = cosp_ht
        cfad&cosp_sr   = cosp_sr
        cfad&lat  = lat 
        cfad&lon  = lon 

;       convert to percent
        cfad = cfad*100.0
        outptr->CFAD_SR532 = cfad
      else
        cfad = -999.0
      end if
    end if
    return(cfad)
  end
