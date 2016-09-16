load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
gridfilename = getenv("GRIDFILE")
reg_file = getenv("REGIONFILE")
;****************************************************************
; Boundary areas for regional masks:
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
;******************************************************************

Lab_lat = (/50.,78./)
Lab_long = (/284.,315./)
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

b = addfile(gridfilename,"r")
tlat = dble2flt(b->TLAT)
tlon = dble2flt(b->TLONG)
tarea = dble2flt(b->TAREA)*1.0e-4
delete(b)

dims = dimsizes(tlat)
time = 1
lat = dims(0)
lon = dims(1)

Lab = new((/time,lat,lon/),float,0)
GIN = new((/time,lat,lon/),float,0)
Bar = new((/time,lat,lon/),float,0)
ArcOc = new((/time,lat,lon/),float,0)
Sib = new((/time,lat,lon/),float,0)
Beau = new((/time,lat,lon/),float,0)
CArc = new((/time,lat,lon/),float,0)
Bering = new((/time,lat,lon/),float,0)
Okhotsk = new((/time,lat,lon/),float,0)
Hudson = new((/time,lat,lon/),float,0)
CAArch = new((/time,lat,lon/),float,0)
Wed = new((/time,lat,lon/),float,0)
Ross = new((/time,lat,lon/),float,0)
Ind = new((/time,lat,lon/),float,0)
Pac = new((/time,lat,lon/),float,0)
BAm = new((/time,lat,lon/),float,0)
nh = new((/time,lat,lon/),float,0)
sh = new((/time,lat,lon/),float,0)

Lab_mask = new((/time,lat,lon/),float,0)
GIN_mask = new((/time,lat,lon/),float,0)
Bar_mask = new((/time,lat,lon/),float,0)
ArcOc_mask = new((/time,lat,lon/),float,0)
Sib_mask = new((/time,lat,lon/),float,0)
Beau_mask = new((/time,lat,lon/),float,0)
CArc_mask = new((/time,lat,lon/),float,0)
Bering_mask = new((/time,lat,lon/),float,0)
Okhotsk_mask = new((/time,lat,lon/),float,0)
Hudson_mask = new((/time,lat,lon/),float,0)
CAArch_mask = new((/time,lat,lon/),float,0)
Wed_mask = new((/time,lat,lon/),float,0)
Ross_mask = new((/time,lat,lon/),float,0)
Ind_mask = new((/time,lat,lon/),float,0)
Pac_mask = new((/time,lat,lon/),float,0)
BAm_mask = new((/time,lat,lon/),float,0)
nh_mask = new((/time,lat,lon/),float,0)
sh_mask = new((/time,lat,lon/),float,0)


nrank = dimsizes(dimsizes(tlat))

if (nrank .eq. 3) then
   tlat2 = conform(Lab,tlat(0,:,:),(/1,2/))
   tlon2 = conform(Lab,tlon(0,:,:),(/1,2/))
else
   tlat2 = conform(Lab,tlat,(/1,2/))
   tlon2 = conform(Lab,tlon,(/1,2/))
end if

      np = dimsizes(tlat)
      nlat = np(0)
      nlon = np(1)
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
            if ((plat.ge.min(Okhotsk_poly_lat)).and.(plon.ge.min(Okhotsk_poly_long))) then
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

GIN_mask = where((tlat2.ge.GIN_lat(0) .and. tlat2.le.GIN_lat(1) .and.\
                  ((tlon2.ge.GIN_long1(0) .and. tlon2.le.GIN_long1(1)) .or.\
                   (tlon2.ge.GIN_long2(0) .and. tlon2.le.GIN_long2(1)))), 1,0)

Bar_mask = where((tlat2.ge.Bar_lat(0) .and. tlat2.le.Bar_lat(1) .and.\
                  tlon2.ge.Bar_long(0) .and. tlon2.le.Bar_long(1)), 1,0)

ArcOc_mask = where(((tlat2.ge.ArcOc_lat1(0) .and. (tlon2.ge.ArcOc_long1(0) .or.\
                  tlon2.le.ArcOc_long2(1))) .or. (tlat2.ge.ArcOc_lat3(0) .and.\
                   (tlon2.ge.ArcOc_long3(0) .and. tlon2.le.ArcOc_long3(1)))), 1,0)

Sib_mask = where((tlat2.ge.Sib_lat(0) .and. tlat2.le.Sib_lat(1) .and.\
                  tlon2.ge.Sib_long(0) .and. tlon2.le.Sib_long(1)), 1,0)

Beau_mask = where((tlat2.ge.Beau_lat(0) .and. tlat2.le.Beau_lat(1) .and.\
                  tlon2.ge.Beau_long(0) .and. tlon2.le.Beau_long(1)), 1,0)

CArc_mask = where((tlat2.ge.CArc_lat(0) .and. tlat2.le.CArc_lat(1) .and.\
                  tlon2.ge.CArc_long(0) .and. tlon2.le.CArc_long(1)), 1,0)

Wed_mask = where((tlat2.le.Wed_lat(1) .and. ((tlon2.ge.Wed_long1(0) \
                  .and. tlon2.le.Wed_long1(1)) .or. (tlon2.ge.Wed_long2(0) \
                   .and. tlon2.le.Wed_long2(1)))), 1,0)

Ross_mask = where((tlat2.le.Ross_lat(1) .and. tlon2.ge.Ross_long(0) \
                   .and. tlon2.le.Ross_long(1)), 1,0)

Ind_mask = where((tlat2.le.Ind_lat(1) .and. tlon2.ge.Ind_long(0) \
                   .and. tlon2.le.Ind_long(1)), 1,0)

Pac_mask = where((tlat2.le.Pac_lat(1) .and. tlon2.ge.Pac_long(0) \
                   .and. tlon2.le.Pac_long(1)),1,0)

BAm_mask = where((tlat2.le.BAm_lat(1) .and. tlon2.ge.BAm_long(0) \
                   .and. tlon2.le.BAm_long(1)),1,0)

nh_mask = where((tlat2.ge.0),1,0)

sh_mask = where((tlat2.ge.0),0,1)

fout = addfile(reg_file,"c")
setfileoption(fout,"DefineMode",True)

dimNames = (/"time","lat","lon"/)
dimSizes = (/-1,lat,lon/)
dimUnlim = (/True,False,False/)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

filevardef(fout,"Lab_mask","float",(/"time","lat","lon"/))
filevardef(fout,"GIN_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Bar_mask","float",(/"time","lat","lon"/))
filevardef(fout,"ArcOc_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Sib_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Beau_mask","float",(/"time","lat","lon"/))
filevardef(fout,"CArc_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Bering_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Okhotsk_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Hudson_mask","float",(/"time","lat","lon"/))
filevardef(fout,"CAArch_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Wed_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Ross_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Ind_mask","float",(/"time","lat","lon"/))
filevardef(fout,"Pac_mask","float",(/"time","lat","lon"/))
filevardef(fout,"BAm_mask","float",(/"time","lat","lon"/))
filevardef(fout,"nh_mask","float",(/"time","lat","lon"/))
filevardef(fout,"sh_mask","float",(/"time","lat","lon"/))

atts = True
atts@missing_value = 1.e+30

filevarattdef(fout,"Lab_mask",atts)
filevarattdef(fout,"GIN_mask",atts)
filevarattdef(fout,"Bar_mask",atts)
filevarattdef(fout,"ArcOc_mask",atts)
filevarattdef(fout,"Sib_mask",atts)
filevarattdef(fout,"Beau_mask",atts)
filevarattdef(fout,"CArc_mask",atts)
filevarattdef(fout,"Bering_mask",atts)
filevarattdef(fout,"Okhotsk_mask",atts)
filevarattdef(fout,"Hudson_mask",atts)
filevarattdef(fout,"CAArch_mask",atts)
filevarattdef(fout,"Wed_mask",atts)
filevarattdef(fout,"Ross_mask",atts)
filevarattdef(fout,"Ind_mask",atts)
filevarattdef(fout,"Pac_mask",atts)
filevarattdef(fout,"BAm_mask",atts)
filevarattdef(fout,"nh_mask",atts)
filevarattdef(fout,"sh_mask",atts)

setfileoption(fout,"DefineMode",False)

Lab_mask!0="time"
Lab_mask!1="lat"
Lab_mask!2="lon"
fout->Lab_mask = Lab_mask

GIN_mask!0="time"
GIN_mask!1="lat"
GIN_mask!2="lon"
fout->GIN_mask = GIN_mask

Bar_mask!0="time"
Bar_mask!1="lat"
Bar_mask!2="lon"
fout->Bar_mask = Bar_mask

ArcOc_mask!0="time"
ArcOc_mask!1="lat"
ArcOc_mask!2="lon"
fout->ArcOc_mask = ArcOc_mask

Sib_mask!0="time"
Sib_mask!1="lat"
Sib_mask!2="lon"
fout->Sib_mask = Sib_mask

Beau_mask!0="time"
Beau_mask!1="lat"
Beau_mask!2="lon"
fout->Beau_mask = Beau_mask

CArc_mask!0="time"
CArc_mask!1="lat"
CArc_mask!2="lon"
fout->CArc_mask = CArc_mask

Bering_mask!0="time"
Bering_mask!1="lat"
Bering_mask!2="lon"
fout->Bering_mask = Bering_mask

Okhotsk_mask!0="time"
Okhotsk_mask!1="lat"
Okhotsk_mask!2="lon"
fout->Okhotsk_mask = Okhotsk_mask

Hudson_mask!0="time"
Hudson_mask!1="lat"
Hudson_mask!2="lon"
fout->Hudson_mask = Hudson_mask

CAArch_mask!0="time"
CAArch_mask!1="lat"
CAArch_mask!2="lon"
fout->CAArch_mask = CAArch_mask

Wed_mask!0="time"
Wed_mask!1="lat"
Wed_mask!2="lon"
fout->Wed_mask = Wed_mask

Ross_mask!0="time"
Ross_mask!1="lat"
Ross_mask!2="lon"
fout->Ross_mask = Ross_mask

Ind_mask!0="time"
Ind_mask!1="lat"
Ind_mask!2="lon"
fout->Ind_mask = Ind_mask

Pac_mask!0="time"
Pac_mask!1="lat"
Pac_mask!2="lon"
fout->Pac_mask = Pac_mask

BAm_mask!0="time"
BAm_mask!1="lat"
BAm_mask!2="lon"
fout->BAm_mask = BAm_mask

nh_mask!0="time"
nh_mask!1="lat"
nh_mask!2="lon"
fout->nh_mask = nh_mask

sh_mask!0="time"
sh_mask!1="lat"
sh_mask!2="lon"
fout->sh_mask = sh_mask

end
