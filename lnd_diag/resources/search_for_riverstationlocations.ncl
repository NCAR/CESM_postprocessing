; ***********************************************
; search_for_riverstationlocations.ncl
; Dec. 3, 2015  K. Oleson
; This script determines the lat/lon of best fit of model (simulated) 
; discharge to observed discharge at station within a 3X3 grid of
; 0.5deg cells whose center is the closest grid cell to the station
; lat/lon
; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin

 print ("=========================================")
 print ("Starting:  search_for_riverstationlocations.ncl")
 print ("Start Time: "+systemfunc("date") )
 print ("=========================================")

 mosart = 1  ; 1(ON) for mosart, 0 for RTM

;----------------------------------------------
; The following simulation will be used to determine lat/lon of best 
; fit of model (simulated) discharge to observed discharge at station
; The lat/lon file (see tablename) will be used by the diagnostics package
;----------------------------------------------
 simdir = "/glade/p/work/oleson/lnd_diag4.2.34_commit/code/resources/"
 if (mosart .eq. 1) then
   sim = "40_year_mosart_09_30_39_ANN_climo_rtm.nc"
 else
   sim = "40_year_mosart_rtm_09_30_39_ANN_climo_rtm.nc"
 end if

;----------------------------------------------
; Specify the name of the table that will contain the river name, 
; the lat/lon station coordinates, and station name,country
;----------------------------------------------
 if (mosart .eq. 1) then
   tablename = "rdirc.mosart.05"
 else
   tablename = "rdirc.rtm.05"
 end if

;----------------------------------------------
; This directory could change depending on lnd_diag tag
;----------------------------------------------
 obsdatadir = "/glade/p/work/oleson/lnd_diag4.2.34_commit/obs_data/"

;----------------------------------------------
; Get river names, station locations, observed discharge, etc. These
; are from Dai and Trenberth (2002).
;----------------------------------------------
 ptr_rivflow = obsdatadir +"dai_and_trenberth_table2.asc"

 dStr = asciiread (ptr_rivflow, -1, "string")
 dChr = stringtochar(dStr)
 no                    = stringtointeger( chartostring(dChr(3:,0:2)) )
 river_name            = chartostring(dChr(3:,4:18))
 obs_vol_at_stn        = stringtofloat( chartostring(dChr(3:,20:23)) )
 obs_sd_vol_at_stn     = stringtointeger( chartostring(dChr(3:,25:27)) )
 fekete_rtm_vol_at_stn = stringtointeger( chartostring(dChr(3:,29:32)) )
 da_at_stn             = stringtointeger( chartostring(dChr(3:,34:37)) )
 stn_lon               = stringtofloat( chartostring(dChr(3:,39:45)) )
 stn_lat               = stringtofloat( chartostring(dChr(3:,47:52)) )
 rtm_fekete_stn_lon    = stringtofloat( chartostring(dChr(3:,54:60)) )
 rtm_fekete_stn_lat    = stringtofloat( chartostring(dChr(3:,62:67)) )
 obs_nyr_stn           = stringtointeger( chartostring(dChr(3:,69:71)) )
 stn_name              = chartostring(dChr(3:,73:99))
 obs_vol_at_riv_mou    = stringtointeger( chartostring(dChr(3:,101:104)) )
 da_at_riv_mou         = stringtointeger( chartostring(dChr(3:,106:109)) )
 rtm_fekete_mou_lon    = stringtofloat( chartostring(dChr(3:,111:117)) )
 rtm_fekete_mou_lat    = stringtofloat( chartostring(dChr(3:,119:124)) )
 delete(dStr)
 delete(dChr)
 nriv  = dimsizes(no)    ; number of rivers

;----------------------------------------------
; Get qchanr from model simulation
;----------------------------------------------
 inptr  = addfile(simdir+sim,"r")
 qchanr = inptr->QCHANR_LIQ(0,:,:)
 lat = inptr->lat
 lon = inptr->lon
 printVarSummary(qchanr)

;----------------------------------------------
; Loop through rivers and print out river flow for grid cell closest to 
; actual station location
;----------------------------------------------
 rof_vol_at_stn = new(nriv,float,qchanr@_FillValue)
 do i = 0, nriv-1
   obs_vol_at_stn(i) = obs_vol_at_stn(i)*1.e9/(86400.*365.) ; from km3/yr to m3/s
   rof_vol_at_stn(i) = qchanr({stn_lat(i)},{stn_lon(i)})    ; m3/s
   if (.not.(ismissing(rof_vol_at_stn(i)))) then
     print((/"River: "+river_name(i)+" OBS DISCH: "+sprintf("%5.2f",obs_vol_at_stn(i))+" SIM DISCH: "+sprintf("%5.2f",rof_vol_at_stn(i))/))
   else
     print((/"River: "+river_name(i)+" OBS DISCH: "+sprintf("%5.2f",obs_vol_at_stn(i))+" SIM DISCH: "+sprintf("%5.2f",-999.)/))
   end if
 end do

;----------------------------------------------
; Now find lat/lon of gridcell within 3X3 grid that will minimize difference
; between annual simulated and observed discharge
;----------------------------------------------
 jlat = new(nriv,integer)
 ilon = new(nriv,integer)
 rtm_stn_lat = new(nriv,float)
 rtm_stn_lon = new(nriv,float)
 rof_vol_at_stn_new = new(nriv,float,qchanr@_FillValue)
 do i = 0,nriv-1
   jlat(i) = ind_nearest_coord (stn_lat(i), qchanr&lat, 0)
;  print((/"jlat: "+jlat(i)/))
   ilon(i) = ind_nearest_coord (stn_lon(i), qchanr&lon, 0)
;  print((/"ilon: "+ilon(i)/))

   rof_vol_at_stn_blk = ndtooned(qchanr(jlat(i)-1:jlat(i)+1,ilon(i)-1:ilon(i)+1))
;  print(rof_vol_at_stn_blk)

   obs_rof_vol_at_stn = rof_vol_at_stn_blk - conform(rof_vol_at_stn_blk,obs_vol_at_stn(i),-1)
;  print(minind(abs(obs_rof_vol_at_stn)))

   indices = ind_resolve(minind(abs(obs_rof_vol_at_stn)),(/3,3/))

   rtm_stn_lat(i) = lat(jlat(i)-1+indices(0,0))
;  print((/"rtm_stn_lat: "+rtm_stn_lat(i)/))
   rtm_stn_lon(i) = lon(ilon(i)-1+indices(0,1))
;  print((/"rtm_stn_lon: "+rtm_stn_lon(i)/))

   rof_vol_at_stn_new(i) = qchanr({rtm_stn_lat(i)},{rtm_stn_lon(i)})    ; m3/s
;  print((/"rof_vol_at_stn_new: "+rof_vol_at_stn_new(i)/))
   print((/"River: "+river_name(i)+" OBS DISCH: "+sprintf("%5.2f",obs_vol_at_stn(i))+" SIM DISCH: "+sprintf("%5.2f",rof_vol_at_stn_new(i))/))
 end do

;----------------------------------------------
; The best-fit gridcell that is found for the Parana is for a location that has low flow.
; Overwrite location for Parana with RTM location.
;----------------------------------------------
 if (mosart .eq. 1) then
   rtm_stn_lat(7) = -32.25
   rtm_stn_lon(7) = -60.75
 end if

;----------------------------------------------
; makes a 4 column table
; column 1 contains the river name
; columns 2-3 contain the lat/lon values
; column 4 contains the station, country
;----------------------------------------------
 nvars = 4
 spaces = integertochar(32)
 nrows = nriv

 table = new(nrows,"string")

 sp1 = new(1,"character")
 sp1 = spaces
 spaces1 = chartostring(sp1)
 sp2 = new(2,"character")
 sp2 = spaces
 spaces2 = chartostring(sp2)
 do n = 0, nriv-1
   table(n) = spaces1+river_name(n)+ \
   sprintf("%8.2f",rtm_stn_lon(n))+sprintf("%7.2f",rtm_stn_lat(n))+ \
   spaces2+stn_name(n)
 end do
 asciiwrite(tablename,table)       ; write out table to file

 print ("=========================================")
 print ("Finishing:  search_for_riverstationlocations.ncl")
 print ("Finish Time: "+systemfunc("date") )
 print ("=========================================")

end
