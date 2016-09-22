;***************************************************************
; This script reads in satellite-derived daily average sea ice 
; area fraction files processed by Steve Yeager. A monthly 
; climatology for ifrac is computed from the daily data. 
; This script also calculates monthly mean (climatology) extent for
; northern and southern hemisphere, as well as regional monthly mean 
; ice extents. For these calculations the script requires TAREA from 
; the same grid that the SSMI data are on - user needs to supply 
; a file with TAREA of same grid for these calculations.
;
; The user can specify the years over which to make the climatology
; as well as the grid used (current grid options are 0.5x0.5, gx1v5, 
; and gx3v5
;
; Laura Landrum
; May, 2012
;
;***************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

   wks_type = getenv("PLOT_FORMAT")
   wks_type@wkWidth  = stringtointeger(getenv("PLOT_RES"))
   wks_type@wkHeight = stringtointeger(getenv("PLOT_RES"))

   data_dir = "/glade/proj2/ccsm/ocn/iaf"
   out_dir = "/glade/home/landrum/mydiags/ice_diag/data"

   yr1 = 1981
   yr2 = 2005

   grid = "gx1v5"			;choices are 0.5x0.5, gx1v5 and gx3v5

   min_ifrac = 0.15			; minimum ice fraction at which to define "ice covered" for ice extent - typicaly 15%
;-----------------------------------------
; get a file to get tarea of cells from...
;-----------------------------------------
   tarea_file = "/glade/proj3/CESM/pcwg/landrum/b.e10.B2000CN.f09_g16.test_alb4.001/ocn/hist/b.e10.B2000CN.f09_g16.test_alb4.001.pop.h.0019-01.nc"

  write_netCDF = False                   ; can set this to False if file is already created and just want to look at plots
  write_ascii = False 			; can set this to False if file is already created and just want to look at plots
;--------------------------------------------------------------------
;  boundaries for regional computations
; Abbreviations are:
; Northern Hemisphere:
;       Lab            Lab Sea
;       GIN            GIN Sea
;       Bar            Barents/Kara Sea
;       ArcOc          Arctic Ocean
;       Sib            Siberian Sea
;       Beau           Beaufort Sea
;       CArc           Central Arctic
;       Bering         Bering Sea
;       Okhotsk        Sea of Okhotsk
;       Hudson         Hudson Bay
;       CAArch         Canadian Archipelago
;
;Southern Hemisphere:
;       Wed            Weddell Sea
;       Ross           Ross Sea
;       Ind            Indian sector
;       Pac            Pacific sector
;       BAm            Bellingshausen-Amundsen Sea
;
;-------------------------------------------------------------------
   GIN_lat = (/65.,80./)
   GIN_long1 = (/315.,360./)
   GIN_long2 = (/0.,15./)
   Bar_lat = (/66.,80./)
   Bar_long = (/15.,100./)
   ArcOc_lat1 = (/80.,90./)
   ArcOc_lat2 = ArcOc_lat1
   ArcOc_lat3 = (/68.,90./)
   ArcOc_long1 = (/243.,360./)
   ArcOc_long2 = (/0.,100./)
   ArcOc_long3 = (/100.,243./)
   Sib_lat = (/68.,80./)
   Sib_long = (/100.,192./)
   Beau_lat = (/68.,80./)
   Beau_long = (/192.,243./)
   CArc_lat = (/80.,90./)
   CArc_long = (/0.,360./)
;---------------------------------------------------------------
; These Arctic regions are more complicated geographically
; and will be defined by polygons rather than min,max lat,lon
;--------------------------------------------------------------
   Lab_poly_lat = (/50., 64., 74., 78., 78., 50./)
   Lab_poly_long = (/295., 292., 280., 280., 315., 315./)
   Bering_poly_lat = (/56., 60., 68., 68., 58., 52.5, 52.5/)
   Bering_poly_long = (/162., 162., 178., 200., 204., 190., 180./)
   Okhotsk_poly_lat = (/44., 44., 46., 51., 60., 64., 60., 55., 44./)
   Okhotsk_poly_long = (/142., 145., 150., 157., 162., 168., 140., 133., 142./)
   Hudson_poly_lat = (/50., 66., 66., 70., 70., 68., 62., 60., 50./)
   Hudson_poly_long = (/265., 265., 274., 274., 290., 290., 292., 295., 295./)
   CAArch_poly_lat = (/67., 80., 80., 70., 67./)
   CAArch_poly_long = (/243., 243., 281., 281., 275./)
; ------SH regions------------------
   Wed_lat = (/-90.,-50./)
   Wed_long1 = (/300.,360./)
   Wed_long2 = (/0.,20./)
   Ross_lat = (/-90.,-50./)
   Ross_long = (/160.,220./)
   Ind_lat = (/-90.,-50./)
   Ind_long = (/20.,90./)
   Pac_lat = (/-90.,-50./)
   Pac_long = (/90.,160./)
   BAm_lat = (/-90.,-50./)
   BAm_long = (/220.,300./)
;--------------------------------------------------------------------
;  create monthly ifrac
;-------------------------------------------------------------------
   if (write_netCDF .eq. True) then
      fnames = data_dir+"/ssmi.ifrac."+grid+"*.nc "
      files = systemfunc("ls "+fnames)

      nyrs = yr2 - yr1 + 1
      if (grid .eq. "gx3v5") then				; starts in 1949
        fi = yr1 - 1949
      else							; starts in 1948
        fi = yr1 - 1948
      end if

      do i=0,nyrs-1
            findex = fi + i
            f  = addfile(files(findex), "r")

            ifrac = f->ifrac
            tlat = f->tlat
            tlon = f->tlon

            if (i .eq. 0)
               ndims = dimsizes(ifrac)
               nlat = ndims(1)
               nlon = ndims(2)

               all_monthly_ifrac = new((/nyrs,12,ndims(1),ndims(2)/),float,ifrac@_FillValue)
            end if

            all_monthly_ifrac(i,0,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|0:30))
            all_monthly_ifrac(i,1,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|31:58))
            all_monthly_ifrac(i,2,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|59:89))
            all_monthly_ifrac(i,3,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|90:119))
            all_monthly_ifrac(i,4,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|120:150))
            all_monthly_ifrac(i,5,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|151:180))
            all_monthly_ifrac(i,6,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|181:211))
            all_monthly_ifrac(i,7,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|212:242))
            all_monthly_ifrac(i,8,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|243:272))
            all_monthly_ifrac(i,9,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|273:303))
            all_monthly_ifrac(i,10,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|304:333))
            all_monthly_ifrac(i,11,:,:) = dim_avg_Wrap(ifrac(nlat|:,nlon|:,time|334:364))
      end do

      all_monthly_ifrac!0 = "year"
      all_monthly_ifrac!1 = "month"
      monthly_ifrac = all_monthly_ifrac(0,:,:,:)

      do i=0,11
         monthly_ifrac(i,:,:) = dim_avg_Wrap(all_monthly_ifrac(month|i,nlat|:,nlon|:,year|:))
      end do

      delete(ifrac)
   
      month = ispan(1,12,1)
      nmonth = 12

      monthly_ifrac&month = month
      monthly_ifrac@long_name = yr1+"-"+yr2+" averaged monthly SMMR/SSMI BOOTSTRAP Sea Ice Fraction"
      monthly_ifrac@comment = "computed from SMMR/SSMI BOOTSTRAP Daily Sea Ice Fraction"

;---------------------------------------------------------------------
; Save monthly ifrac to a netCDF file for use with all ice diagnostics
;---------------------------------------------------------------------
      fifrac = out_dir+"/SSMI.ifrac."+yr1+"-"+yr2+"monthlymean."+grid+".nc"
;      system("/bin/rm -f " + fifrac)    ; remove if exists
      fout  = addfile (fifrac, "c")  ; open output file

      ifrac_file_title = "Monthly Mean Climatology of daily SSMI Sea Ice Fraction "+yr1+"-"+yr2
      setfileoption(fout,"DefineMode",True)

      fileAtt = True
      fileAtt@creation_date = systemfunc("date")
      fileAtt@program = systemfunc("pwd")+"/"+get_script_name()
      fileAtt@title = ifrac_file_title
      fileattdef(fout,fileAtt)

      dimNames = (/"month","nlat","nlon"/)
      dimSizes = (/nmonth,nlat,nlon/)
      dimUnlim = (/False, False, False/)
      filedimdef(fout,dimNames,dimSizes,dimUnlim)

      filevardef(fout,"tlat",typeof(tlat),getvardims(tlat))
      filevardef(fout,"tlon",typeof(tlon),getvardims(tlon))
      filevardef(fout,"monthly_ifrac",typeof(monthly_ifrac),getvardims(monthly_ifrac))

      filevarattdef(fout,"tlat",tlat)
      filevarattdef(fout,"tlon",tlon)
      filevarattdef(fout,"monthly_ifrac",monthly_ifrac)

      fout->monthly_ifrac = monthly_ifrac
      fout->tlat = tlat
      fout->tlon = tlon
   else
      fifrac = out_dir+"/SSMI.ifrac."+yr1+"-"+yr2+"monthlymean."+grid+".nc"
      f = addfile(fifrac,"r")

      monthly_ifrac = f->monthly_ifrac
      tlat = f->tlat
      tlon = f->tlon

      ndims = dimsizes(monthly_ifrac)
      nlat = ndims(1)
      nlon = ndims(2)
   end if

;---------------------------------------------------------------------------------------------------
; Ice Extent climatologies are calculated here
;---------------------------------------------------------------------------------------------------
   delete(f)
   f = addfile(tarea_file,"r")

   tarea = dble2flt(f->TAREA)

   tarea = 0.0001*tarea				;convert from cm2 to m2

   monthly_ifrac@lat2d = tlat
   monthly_ifrac@lon2d = tlon

   tlat2 = conform(monthly_ifrac,tlat,(/1,2/))
   tlon2 = conform(monthly_ifrac,tlon,(/1,2/))
; 
;  global monthly ice extent
;
   ext = where(monthly_ifrac.ge.min_ifrac,1.,0.)*conform(monthly_ifrac,tarea,(/1,2/))
;  
;  global monthly ice area
;  
   vai = monthly_ifrac*conform(monthly_ifrac,tarea,(/1,2/))
;
; NH and SH ice extent climatologies
;
   ext_nh = mask(ext,(tlat2.ge.0.),True)
   ext_sh = mask(ext,(tlat2.ge.0.),False)
;
; NH and SH ice area climatologies
;  
   vai_nh = mask(vai,(tlat2.ge.0.),True)
   vai_sh = mask(vai,(tlat2.ge.0.),False)
;
; Regional ice extent climatologies
;
   Lab_mask = new(dimsizes(ext),typeof(ext),ext@_FillValue)
   Bering_mask = new(dimsizes(ext),typeof(ext),ext@_FillValue)
   Okhotsk_mask = new(dimsizes(ext),typeof(ext),ext@_FillValue)
   CAArch_mask = new(dimsizes(ext),typeof(ext),ext@_FillValue)
   Hudson_mask = new(dimsizes(ext),typeof(ext),ext@_FillValue)

   do i=0,nlat-1
      zlat = ind(.not.ismissing(tlat(i,:)))
      zlon = ind(.not.ismissing(tlon(i,:)))
      j1 = min((/min(zlat),min(zlon)/))
      j2 = max((/max(zlat),max(zlon)/))
      delete(zlat)
      delete(zlon)
      do j=j1,j2
         plat = tlat(i,j)
         plon = tlon(i,j)
         if .not.(ismissing(plat) .or. ismissing(plon)) then
	    if ((plat .ge. min(Okhotsk_poly_lat)).and.(plon.ge.min(Okhotsk_poly_long))) then
               Lab_inout = gc_inout(plat,plon,Lab_poly_lat,Lab_poly_long)
               Bering_inout = gc_inout(plat,plon,Bering_poly_lat,Bering_poly_long)
               Okhotsk_inout = gc_inout(plat,plon,Okhotsk_poly_lat,Okhotsk_poly_long)
               Hudson_inout = gc_inout(plat,plon,Hudson_poly_lat,Hudson_poly_long)
               CAArch_inout = gc_inout(plat,plon,CAArch_poly_lat,CAArch_poly_long)
               if (Lab_inout .eq. True) then
                  Lab_mask(:,i,j) = 1.
               end if
               if (Bering_inout .eq. True) then
                  Bering_mask(:,i,j) = 1.
               end if
               if (Okhotsk_inout .eq. True) then
                  Okhotsk_mask(:,i,j) = 1.
               end if
               if (Hudson_inout .eq. True) then
                  Hudson_mask(:,i,j) = 1.
               end if
               if (CAArch_inout .eq. True) then
                  CAArch_mask(:,i,j) = 1.
               end if
            end if
          end if
      end do
   end do
; -----------------------------extent----------------------------------
   ext_Lab = mask(ext,(Lab_mask .eq. 1.), True)
   ext_GIN = mask(ext,(tlat2.ge.GIN_lat(0) .and. tlat2.le.GIN_lat(1) .and.\
                  ((tlon2.ge.GIN_long1(0) .and. tlon2.le.GIN_long1(1)) .or.\
                   (tlon2.ge.GIN_long2(0) .and. tlon2.le.GIN_long2(1)))), True)
   ext_Bar = mask(ext,(tlat2.ge.Bar_lat(0) .and. tlat2.le.Bar_lat(1) .and.\
                  tlon2.ge.Bar_long(0) .and. tlon2.le.Bar_long(1)), True)
   ext_ArcOc = mask(ext,((tlat2.ge.ArcOc_lat1(0) .and. (tlon2.ge.ArcOc_long1(0) .or.\
                  tlon2.le.ArcOc_long2(1))) .or. (tlat2.ge.ArcOc_lat3(0) .and.\
                   (tlon2.ge.ArcOc_long3(0) .and. tlon2.le.ArcOc_long3(1)))), True)
   ext_Sib = mask(ext,(tlat2.ge.Sib_lat(0) .and. tlat2.le.Sib_lat(1) .and.\
                  tlon2.ge.Sib_long(0) .and. tlon2.le.Sib_long(1)), True)
   ext_Beau = mask(ext,(tlat2.ge.Beau_lat(0) .and. tlat2.le.Beau_lat(1) .and.\
                  tlon2.ge.Beau_long(0) .and. tlon2.le.Beau_long(1)), True)
   ext_CArc = mask(ext,(tlat2.ge.CArc_lat(0) .and. tlat2.le.CArc_lat(1) .and.\
                  tlon2.ge.CArc_long(0) .and. tlon2.le.CArc_long(1)), True)
   ext_Bering = mask(ext,(Bering_mask .eq. 1.), True)
   ext_Okhotsk = mask(ext,(Okhotsk_mask .eq. 1.), True)
   ext_Hudson = mask(ext,(Hudson_mask .eq. 1.), True)
   ext_CAArch = mask(ext,(CAArch_mask .eq. 1.), True)

   ext_Wed = mask(ext,(tlat2.le.Wed_lat(1) .and.((tlon2.ge.Wed_long1(0) \
                  .and. tlon2.le.Wed_long1(1)) .or. (tlon2.ge.Wed_long2(0) \
                  .and. tlon2.le.Wed_long2(1)))), True)
   ext_Ross = mask(ext,(tlat2.le.Ross_lat(1) .and. tlon2.ge.Ross_long(0) \
                   .and. tlon2.le.Ross_long(1)), True)
   ext_Ind = mask(ext,(tlat2.le.Ind_lat(1) .and. tlon2.ge.Ind_long(0) \
                   .and. tlon2.le.Ind_long(1)), True)
   ext_Pac = mask(ext,(tlat2.le.Pac_lat(1) .and. tlon2.ge.Pac_long(0) \
                   .and. tlon2.le.Pac_long(1)), True)
   ext_BAm = mask(ext,(tlat2.le.BAm_lat(1) .and. tlon2.ge.BAm_long(0) \ 
                   .and. tlon2.le.BAm_long(1)), True)
; -----------------------------area----------------------------------
   vai_Lab = mask(vai,(Lab_mask .eq. 1.), True)
   vai_GIN = mask(vai,(tlat2.ge.GIN_lat(0) .and. tlat2.le.GIN_lat(1) .and.\
                  ((tlon2.ge.GIN_long1(0) .and. tlon2.le.GIN_long1(1)) .or.\
                   (tlon2.ge.GIN_long2(0) .and. tlon2.le.GIN_long2(1)))), True)
   vai_Bar = mask(vai,(tlat2.ge.Bar_lat(0) .and. tlat2.le.Bar_lat(1) .and.\
                  tlon2.ge.Bar_long(0) .and. tlon2.le.Bar_long(1)), True)
   vai_ArcOc = mask(vai,((tlat2.ge.ArcOc_lat1(0) .and. (tlon2.ge.ArcOc_long1(0) .or.\
                  tlon2.le.ArcOc_long2(1))) .or. (tlat2.ge.ArcOc_lat3(0) .and.\
                   (tlon2.ge.ArcOc_long3(0) .and. tlon2.le.ArcOc_long3(1)))), True)
   vai_Sib = mask(vai,(tlat2.ge.Sib_lat(0) .and. tlat2.le.Sib_lat(1) .and.\
                  tlon2.ge.Sib_long(0) .and. tlon2.le.Sib_long(1)), True)
   vai_Beau = mask(vai,(tlat2.ge.Beau_lat(0) .and. tlat2.le.Beau_lat(1) .and.\
                  tlon2.ge.Beau_long(0) .and. tlon2.le.Beau_long(1)), True)
   vai_CArc = mask(vai,(tlat2.ge.CArc_lat(0) .and. tlat2.le.CArc_lat(1) .and.\
                  tlon2.ge.CArc_long(0) .and. tlon2.le.CArc_long(1)), True)
   vai_Bering = mask(vai,(Bering_mask .eq. 1.), True)
   vai_Okhotsk = mask(vai,(Okhotsk_mask .eq. 1.), True)
   vai_Hudson = mask(vai,(Hudson_mask .eq. 1.), True)
   vai_CAArch = mask(vai,(CAArch_mask .eq. 1.), True)

   vai_Wed = mask(vai,(tlat2.le.Wed_lat(1) .and.((tlon2.ge.Wed_long1(0) \
                  .and. tlon2.le.Wed_long1(1)) .or. (tlon2.ge.Wed_long2(0) \
                  .and. tlon2.le.Wed_long2(1)))), True)
   vai_Ross = mask(vai,(tlat2.le.Ross_lat(1) .and. tlon2.ge.Ross_long(0) \
                   .and. tlon2.le.Ross_long(1)), True)
   vai_Ind = mask(vai,(tlat2.le.Ind_lat(1) .and. tlon2.ge.Ind_long(0) \
                   .and. tlon2.le.Ind_long(1)), True)
   vai_Pac = mask(vai,(tlat2.le.Pac_lat(1) .and. tlon2.ge.Pac_long(0) \
                   .and. tlon2.le.Pac_long(1)), True)
   vai_BAm = mask(vai,(tlat2.le.BAm_lat(1) .and. tlon2.ge.BAm_long(0) \
                   .and. tlon2.le.BAm_long(1)), True)
;--------------------------------------------------------------------------
;    regional monthly, climatological mean sea ice extent and area in 10^12 m^2
;-------------------------------------------------------------------------
   ext_mo_nh = dim_sum(dim_sum(ext_nh))*1.0e-12
   ext_mo_Lab = dim_sum(dim_sum(ext_Lab))*1.0e-12
   ext_mo_GIN = dim_sum(dim_sum(ext_GIN))*1.0e-12
   ext_mo_Bar = dim_sum(dim_sum(ext_Bar))*1.0e-12
   ext_mo_ArcOc = dim_sum(dim_sum(ext_ArcOc))*1.0e-12
   ext_mo_Sib = dim_sum(dim_sum(ext_Sib))*1.0e-12
   ext_mo_Beau = dim_sum(dim_sum(ext_Beau))*1.0e-12
   ext_mo_CArc = dim_sum(dim_sum(ext_CArc))*1.0e-12
   ext_mo_Bering = dim_sum(dim_sum(ext_Bering))*1.0e-12
   ext_mo_Okhotsk = dim_sum(dim_sum(ext_Okhotsk))*1.0e-12
   ext_mo_Hudson = dim_sum(dim_sum(ext_Hudson))*1.0e-12
   ext_mo_CAArch = dim_sum(dim_sum(ext_CAArch))*1.0e-12

   ext_mo_sh = dim_sum(dim_sum(ext_sh))*1.0e-12
   ext_mo_Wed = dim_sum(dim_sum(ext_Wed))*1.0e-12
   ext_mo_Ross = dim_sum(dim_sum(ext_Ross))*1.0e-12
   ext_mo_Ind = dim_sum(dim_sum(ext_Ind))*1.0e-12
   ext_mo_Pac = dim_sum(dim_sum(ext_Pac))*1.0e-12
   ext_mo_BAm = dim_sum(dim_sum(ext_BAm))*1.0e-12

   vai_mo_nh = dim_sum(dim_sum(vai_nh))*1.0e-12
   vai_mo_Lab = dim_sum(dim_sum(vai_Lab))*1.0e-12
   vai_mo_GIN = dim_sum(dim_sum(vai_GIN))*1.0e-12
   vai_mo_Bar = dim_sum(dim_sum(vai_Bar))*1.0e-12
   vai_mo_ArcOc = dim_sum(dim_sum(vai_ArcOc))*1.0e-12
   vai_mo_Sib = dim_sum(dim_sum(vai_Sib))*1.0e-12
   vai_mo_Beau = dim_sum(dim_sum(vai_Beau))*1.0e-12
   vai_mo_CArc = dim_sum(dim_sum(vai_CArc))*1.0e-12
   vai_mo_Bering = dim_sum(dim_sum(vai_Bering))*1.0e-12
   vai_mo_Okhotsk = dim_sum(dim_sum(vai_Okhotsk))*1.0e-12
   vai_mo_Hudson = dim_sum(dim_sum(vai_Hudson))*1.0e-12
   vai_mo_CAArch = dim_sum(dim_sum(vai_CAArch))*1.0e-12

   vai_mo_sh = dim_sum(dim_sum(vai_sh))*1.0e-12
   vai_mo_Wed = dim_sum(dim_sum(vai_Wed))*1.0e-12
   vai_mo_Ross = dim_sum(dim_sum(vai_Ross))*1.0e-12
   vai_mo_Ind = dim_sum(dim_sum(vai_Ind))*1.0e-12
   vai_mo_Pac = dim_sum(dim_sum(vai_Pac))*1.0e-12
   vai_mo_BAm = dim_sum(dim_sum(vai_BAm))*1.0e-12

   region_titles = (/"NH","Lab","GIN","Bar","ArcOC","Sib","Beau","CArc","Bering","Okhotsk",\
         "Hudson","CAArchipelago","SH","Wed","Ross","Ind","Pac","BAm"/)

;--------------------------------------------------------------------------
;    output regional monthly mean sea ice area matrix to ascii file
;-------------------------------------------------------------------------
   if (write_ascii .eq. True) then
      asciiout_ext = "data/SSMI.ice_extent."+yr1+"-"+yr2+".monthly.regional.txt"
      nregions = dimsizes(region_titles)      
      regional_ext_mo = new((/12,nregions/),float,ext@_FillValue)
      regional_ext_mo@units = "1.E+12 m2"

      regional_ext_mo(:,0) = ext_mo_nh
      regional_ext_mo(:,1) = ext_mo_Lab
      regional_ext_mo(:,2) = ext_mo_GIN
      regional_ext_mo(:,3) = ext_mo_Bar
      regional_ext_mo(:,4) = ext_mo_ArcOc
      regional_ext_mo(:,5) = ext_mo_Sib
      regional_ext_mo(:,6) = ext_mo_Beau
      regional_ext_mo(:,7) = ext_mo_CArc
      regional_ext_mo(:,8) = ext_mo_Bering
      regional_ext_mo(:,9) = ext_mo_Okhotsk
      regional_ext_mo(:,10) = ext_mo_Hudson
      regional_ext_mo(:,11) = ext_mo_CAArch
      regional_ext_mo(:,12) = ext_mo_sh
      regional_ext_mo(:,13) = ext_mo_Wed
      regional_ext_mo(:,14) = ext_mo_Ross
      regional_ext_mo(:,15) = ext_mo_Ind
      regional_ext_mo(:,16) = ext_mo_Pac
      regional_ext_mo(:,17) = ext_mo_BAm

      opt = True
      opt@fout = asciiout_ext
      title = "Month"
      do ir=0,nregions-1
         title = title + " "+ region_titles(ir)
      end do
      title = title +" units are (1.E+12 m2)"
      opt@title = title
      opt@row = True

      fmtf = nregions + "f8.4"
      write_matrix(regional_ext_mo,fmtf,opt)

      asciiout_area = "data/SSMI.ice_area."+yr1+"-"+yr2+".monthly.regional.txt"
      regional_vai_mo = new((/12,nregions/),float,vai@_FillValue)
      regional_vai_mo@units = "1.E+12 m2"

      regional_vai_mo(:,0) = vai_mo_nh
      regional_vai_mo(:,1) = vai_mo_Lab
      regional_vai_mo(:,2) = vai_mo_GIN
      regional_vai_mo(:,3) = vai_mo_Bar
      regional_vai_mo(:,4) = vai_mo_ArcOc
      regional_vai_mo(:,5) = vai_mo_Sib
      regional_vai_mo(:,6) = vai_mo_Beau
      regional_vai_mo(:,7) = vai_mo_CArc
      regional_vai_mo(:,8) = vai_mo_Bering
      regional_vai_mo(:,9) = vai_mo_Okhotsk
      regional_vai_mo(:,10) = vai_mo_Hudson
      regional_vai_mo(:,11) = vai_mo_CAArch
      regional_vai_mo(:,12) = vai_mo_sh
      regional_vai_mo(:,13) = vai_mo_Wed
      regional_vai_mo(:,14) = vai_mo_Ross
      regional_vai_mo(:,15) = vai_mo_Ind
      regional_vai_mo(:,16) = vai_mo_Pac
      regional_vai_mo(:,17) = vai_mo_BAm

      opt@fout = asciiout_area
      title = "Month"
      do ir=0,nregions-1
         title = title + " "+ region_titles(ir)
      end do
      title = title +" units are (1.E+12 m2)"
      opt@title = title
      opt@row = True

      fmtf = nregions + "f8.4"
      write_matrix(regional_vai_mo,fmtf,opt)

   end if
;********************************************************
; plot here....
;********************************************************

   wks = gsn_open_wks(wks_type,"PolarRegions")   ; Open ncgm for graphics output

   gsn_define_colormap(wks,"WhBlGrYeRe")
   i = NhlNewColor(wks,0.7,0.7,0.7) 

   res                      = True            ; Set some plot options
   res@gsnDraw              = False        ; don't draw yet
   res@gsnFrame             = False        ; don't advance frame yet
   res@vpHeightF = 0.4
   res@vpWidthF = 0.9
   res@trXMinF = 1
   
   NH_colors = (/"black","greenyellow","green","orange","yellow","red","blue","gold","pink","purple",\
      "navy","turquoise"/)
   SH_colors = (/"black","blue","orange","green","turquoise","purple"/)

   resP = True
   resP@gsnFrame = False
   resP@gsnMaximize         = True
   resP@gsnPaperOrientation = "portrait"
   resP@txFont              = "helvetica"
   resP@txFuncCode          = "~"
   resP@tiMainFont          = "helvetica"
   resP@tiMainFuncCode          = "~"
   resP@tiXAxisFont          = "helvetica"
   resP@tiXAxisFuncCode          = "~"
   resP@tiYAxisFont          = "helvetica"
   resP@tiYAxisFuncCode          = "~"
   resP@tmXBLabelFont          = "helvetica"
   resP@tmYLLabelFont          = "helvetica"

   x1 = ispan(1,12,1)
   yNH = (/ext_mo_nh,ext_mo_Lab,ext_mo_GIN,ext_mo_Bar,ext_mo_ArcOc,ext_mo_Sib,ext_mo_Beau,\
          ext_mo_CArc,ext_mo_Bering,ext_mo_Okhotsk,ext_mo_Hudson,ext_mo_CAArch/)
   ySH = (/ext_mo_sh,ext_mo_Wed,ext_mo_Ross,ext_mo_Ind,ext_mo_Pac,ext_mo_BAm/)

   res@xyLineColors = NH_colors
   res@xyMonoDashPattern = True
   res@xyDashPattern = 0
   res@tiMainString = "Northern Hemisphere Ice Extent 10~S~12~N~ m~S~2~N~"
   plot1 = gsn_csm_xy(wks,x1,yNH,res)

   delete(res@xyLineColors)
   res@xyLineColors = SH_colors

   res@tiMainString = "Southern Hemisphere Ice Extent 10~S~12~N~ m~S~2~N~"
   plot2 = gsn_csm_xy(wks,x1,ySH,res)

   gsn_panel(wks,(/plot1,plot2/),(/2,1/),resP)

;***********************************************
; legend resources
;***********************************************
  lgres                    = True
  lgres@lgLineColors     = NH_colors(::-1)
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .04            ; set the legend label font thickness
  lgres@vpWidthF           = 0.15           ; width of legend (NDC)
  lgres@vpHeightF          = 0.18            ; height of legend (NDC)
  lgres@lgPerimColor       = "black"       ; draw the box perimeter in orange
  lgres@lgPerimThicknessF  = 2.0
   lgres@lgMonoDashIndex = True
   lgres@lgDashIndex = 0 

   gsn_legend_ndc(wks,12,region_titles(0:11:-1),0.15,0.88,lgres)

   delete(lgres@lgLineColors)
   lgres@vpHeightF = 0.1
   lgres@lgLineColors     = SH_colors(::-1)
   gsn_legend_ndc(wks,6,region_titles(12:17:-1),0.15,0.35,lgres)
   frame(wks)

   yNH = (/vai_mo_nh,vai_mo_Lab,vai_mo_GIN,vai_mo_Bar,vai_mo_ArcOc,vai_mo_Sib,vai_mo_Beau,\
          vai_mo_CArc,vai_mo_Bering,vai_mo_Okhotsk,vai_mo_Hudson,vai_mo_CAArch/)
   ySH = (/vai_mo_sh,vai_mo_Wed,vai_mo_Ross,vai_mo_Ind,vai_mo_Pac,vai_mo_BAm/)

   res@tiMainString = "Northern Hemisphere Ice Area 10~S~12~N~ m~S~2~N~"
   plot1 = gsn_csm_xy(wks,x1,yNH,res)

   delete(res@xyLineColors)
   res@xyLineColors = SH_colors

   res@tiMainString = "Southern Hemisphere Ice Area 10~S~12~N~ m~S~2~N~"
   plot2 = gsn_csm_xy(wks,x1,ySH,res)

   gsn_panel(wks,(/plot1,plot2/),(/2,1/),resP)

   delete(lgres@lgLineColors)
   lgres@lgLineColors     = NH_colors(::-1)
   gsn_legend_ndc(wks,12,region_titles(0:11:-1),0.15,0.88,lgres)

   delete(lgres@lgLineColors)
   lgres@vpHeightF = 0.1  
   lgres@lgLineColors     = SH_colors(::-1)
   gsn_legend_ndc(wks,6,region_titles(12:17:-1),0.15,0.35,lgres)
   frame(wks)
end 
