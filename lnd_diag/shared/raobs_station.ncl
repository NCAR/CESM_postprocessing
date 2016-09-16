; raobs_stations.ncl
; Plot raobs station locations.
; Keith Oleson Aug 2002
;********************************************************
load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
begin
 print ("=========================================")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")
;----------------------------------------------
; Get environment variables
;----------------------------------------------
 testcase   = getenv("caseid_1")
 compcase   = getenv("caseid_2")
 version    = getenv("DIAG_VERSION")
 ptmpdir    = getenv("PTMPDIR")
 wkdir      = getenv("WKDIR")
 plot_type  = getenv("PLOTTYPE")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")
 inputVars  = getenv("INPUT_FILES")

;----------------------------------------------
; Station names for reference
;----------------------------------------------
 station_names = (/"Ascension_Island","Diego_Garcia","Truk_Island", \
 "Western_Europe","Ethiopia","Resolute_Canada","Western_Desert_Australia", \
 "Great_Plains_USA","Central_India","Marshall_Islands","Easter_Island", \
 "McMurdo_Antarctica","SouthPole_Antarctica","Panama","Western_North_Atlantic",\
 "Singapore","Manila","Gilbert_Islands","Hawaii","San_Paulo","Heard_Island", \
 "Kagoshima_Japan","Port_Moresby","San_Juan_PR","Western_Alaska", \
 "Thule_Greenland","SanFrancisco_CA","Denver_CO","London_UK","Crete", \
 "Tokyo","Sydney_Australia","Christchurch_NZ","Lima_Peru","Miami_FL","Samoa", \
 "ShipP_GulfofAlaska","ShipC_North_Atlantic","Azores","NewYork_USA", \
 "Darwin_Australia","Christmas_Island","Cocos_Islands","Midway_Island", \
 "Raoui_Island","Whitehorse_Canada","OklahomaCity_OK","Gibraltor", \
 "Mexico_City","Recife_Brazil","Nairobi_Kenya","New_Delhi_India", \
 "Madras_India","DaNang_Vietnam","Yap_Island","Falkland_Islands"/)

 station_names_nodata = (/"Alaskan_Arctic","Canadian_Arctic", \
 "Greenland","Russian_Arctic","Alaska","Northwest_Canada", \
 "Central_Canada","Eastern_Canada","Northern_Europe", \
 "Western_Siberia","Eastern_Siberia","Western_US","Central_US", \
 "Eastern_US","Europe","Mediterranean","Central_America", \
 "Amazonia","Central_Africa","Indonesia","Brazil","Sahel", \
 "Southern_Africa","India","Indochina","Sahara_Desert", \
 "Arabian_Peninsula","Australia","Central_Asia","Mongolia", \
 "Tibetan_Plateau"/)

 nstations_nodata = dimsizes(station_names_nodata)
;----------------------------------------------
; Open raobs data file
;----------------------------------------------
 in0 = addfile("$OBS_DATA/RAOBS_new.nc","r")
 slat = in0->slat                    ; raobs station latitudes
 slon = in0->slon                    ; raobs station longitudes
;----------------------------------------------
; Read station id numbers selected in script for plotting
;----------------------------------------------
 station_ids = asciiread(inputVars+"/set4_stationIds.txt",-1,"integer")
 nstations = dimsizes(station_ids) - nstations_nodata ; stations with data
;----------------------------------------------
; The following station lat/lons were modified by Mark Stevens so that
; data from the "proper" model gridcell would be extracted.
;----------------------------------------------
 do  ns = 0, nstations-1         ; loop over stations
   sid = station_ids(ns)        ; station id number
   if (sid .eq. 3) then         ; Western Europe
     slat(sid) = 51.626
   end if
   if (sid .eq. 26) then        ; San Francisco
     slon(sid) = 236.250
   end if
   if (sid .eq. 31) then        ; Sydney Australia
     slon(sid) = 151.875
   end if
   if (sid .eq. 32) then        ; Christchurch NZ
     slon(sid) = 174.375
   end if
   if (sid .eq. 34) then        ; Miami FL
    slat(sid) = 26.511
   end if
   if (sid .eq. 47) then        ; Gibraltor
     slat(sid) = 37.673
   end if
 end do
;----------------------------------------------
; Get lat/lon from the first model file
;----------------------------------------------
 cases = new(2,"string")
 name = "prefix_1"
 cases(0) = getenv(name)
 file1 = ptmpdir +"/" + cases(0)+"/atm/"+cases(0)+"_ANN_climo_atm.nc"
 in1 = addfile(file1,"r")
 lat = in1->lat
 lon = in1->lon
 nlat = dimsizes(lat)
 nlon = dimsizes(lon)
 global = nlat*nlon
 glat = new(global,"double")
 glon = new(global,"double")
 glon = onedtond(lon,(/global/))
 do i = 0,nlon-1
   glat(i:global-1:nlon) = lat
 end do
;----------------------------------------------
; Locate active stations with data and without data
;----------------------------------------------
 station = new((/nlat,nlon/),"integer")
 station!0 = "lat"
 station&lat = lat
 station!1 = "lon"
 station&lon = lon
 do i = 0,nstations-1
   if (slat(station_ids(i)) .ge. -87.8638) then  
     station({slat(station_ids(i))},{slon(station_ids(i))}) = 1
   end if
 end do
 station1d = ndtooned(station)
 inds = ind(.not. ismissing(station1d))
 delete(station1d)
 delete(station)

 station = new((/nlat,nlon/),"integer")
 station!0 = "lat"
 station&lat = lat
 station!1 = "lon"
 station&lon = lon
 do i = nstations,nstations+nstations_nodata-1
   if (slat(station_ids(i)) .ge. -87.8638) then  
     station({slat(station_ids(i))},{slon(station_ids(i))}) = 1
   end if
 end do
 station1d = ndtooned(station)
 inds_nodata = ind(.not. ismissing(station1d))
;----------------------------------------------
; Open ps workstation
;----------------------------------------------
 wks = gsn_open_wks(plot_type,wkdir+"set4_stationMap")
;----------------------------------------------
; Common plot resources
;----------------------------------------------
 res = True
 res@gsnDraw = False
 res@gsnFrame = False
 res@gsnMaximize = True
 res@gsnPaperOrientation = "landscape"
 res@mpGridLonSpacingF   = 60.0            ; Set lon grid spacing
 res@mpGridLatSpacingF    = 30.0           ; Set lat grid spacing
 res@mpOutlineOn          =  True
 res@mpGridAndLimbOn      =  True
 res@mpGridLineDashPattern =  2            ; Set grid line dash pattern (dash)
 res@mpGridLineThicknessF   = 0.5          ; Set grid line thickness
 res@gsnRightString = " "
 res@gsnLeftString  = " "

 res@tiMainString = "Model Gridcell closest to Station with data (Blue) and without (Green)"
 polyres = True
 polyres@gsMarkerIndex = 16
 polyres@gsMarkerSizeF = 8.
 polyres@gsMarkerColor = "Blue1"
 plot = gsn_csm_map_ce(wks,res)
 dum1 = gsn_add_polymarker(wks,plot,glon(inds),glat(inds),polyres)
 delete(polyres)
 polyres = True
 polyres@gsMarkerIndex = 16
 polyres@gsMarkerSizeF = 8.
 polyres@gsMarkerColor = "Green"
 dum2 = gsn_add_polymarker(wks,plot,glon(inds_nodata),glat(inds_nodata),polyres)
 draw(wks)
 frame(wks)

 print ("=========================================")
 print ("Finished creating RAOB_STATIONS map------")
 print ("Finish Time: "+systemfunc("date") )
 print ("=========================================")

end
