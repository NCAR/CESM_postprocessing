; ***********************************************
; mkdelPlio.ncl
; ***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
;************************************************
; read in data
;************************************************

 dd = systemfunc("date -u +%y%m%d")

 print("date = " + dd)

 ifile1 = "landArea.nc"
 ifile2 = "region_definitions.20080422.nc"
 ofile = "region_definitions."+dd+".nc"

 in1   = addfile(ifile1,"r")				; prism3d pliocene (2x2)
 in2   = addfile(ifile2,"r")				; prism3d pliocene (2x2)
 system("rm -f " + ofile)
 fout = addfile(ofile,"c")				; prism3d pliocene (2x2)

 fland1 = in1->landfrac
 area1  = in1->area
 lon1   = in1->lon

 if (lon1(0) .ge. 0) then
	area1 = lonFlip(area1)
	fland1 = lonFlip(fland1)
 end if

 box_s = in2->BOX_S
 box_n = in2->BOX_N
 box_w = in2->BOX_W
 box_e = in2->BOX_E
 ps_id = in2->PS_ID
 ptitstr = in2->PTITSTR
 boxstr = in2->BOXSTR
 oregion = in2->region

norig = dimsizes(box_s)
print(norig)

 delete(in1)
 delete(in2)

 new_S = (/40,40,30,30,20,15,30,30,60/)
 new_N = (/55,50,40,40,30,30,45,40,90/)
 new_E = (/40,100,100,80,60,-15,-10,37,-180/)
 new_W = (/100,130,120,100,120,60,60,50,180/)
nnew = dimsizes(new_S)
print(nnew)
totalnew = nnew + norig - 1
print(totalnew)
 new_id = (/"Asia",\
 	    "Mongolia_China",\
	    "Eastern_China",\
	    "Tibet",\
	    "Southern_Asia",\
	    "NAfrica_Arabia",\
	    "Med_MidEast",\
	    "Tigris_Euphrates",\
	    "Polar"/)
 new_tit = (/"Central Asia",\
 	    "NE China",\
	    "Eastern China",\
	    "Tibetan Plateau",\
	    "Southern Asia",\
	    "Sahara and Arabia",\
	    "MedSea and MidEast",\
	    "Tigris Euphrates",\
	    "Polar"/)
 new_box = (/"(40-50N,40-100E)",\
 	    "(40-50N,100-130E)",\
	    "(30-40N,100-120E)",\
	    "(30-40N,80-100E)",\
	    "(20-30N,60-120E)",\
	    "(15-30N,15W-60E)",\
	    "(30-45N,10W-60E)",\
	    "(30-40N,50W-37E)",\
	    "(60-90N,-180W-180E)"/)

 new_region = ispan(0,totalnew,1)
 nreg = dimsizes(new_region)

 nboxS  = new((/nreg/),"float",-9999)
 nboxW  = new((/nreg/),"float",-9999)
 nboxN  = new((/nreg/),"float",-9999)
 nboxE  = new((/nreg/),"float",-9999)
 nps_id = new((/nreg/),"string")
 nptitstr = new((/nreg/),"string")
 nboxstr  = new((/nreg/),"string")

 nboxS(0:31) = box_s(0:31)		; fill in the first 31 regions
 nboxW(0:31) = box_w(0:31)		; fill in the first 31 regions
 nboxN(0:31) = box_n(0:31)		; fill in the first 31 regions
 nboxE(0:31) = box_e(0:31)		; fill in the first 31 regions
   nps_id(0:31) =   charactertostring(ps_id(0:31,:))	; fill in the first 31 regions
 nptitstr(0:31) = charactertostring(ptitstr(0:31,:))	; fill in the first 31 regions
  nboxstr(0:31) =  charactertostring(boxstr(0:31,:))	; fill in the first 31 regions

 st = totalnew-2
 en = totalnew
 nboxS(st:en) = box_s(32:34)		; NH, SH and global in last 3 slots
 nboxW(st:en) = box_w(32:34)		; NH, SH and global in last 3 slots
 nboxN(st:en) = box_n(32:34)		; NH, SH and global in last 3 slots
 nboxE(st:en) = box_e(32:34)		; NH, SH and global in last 3 slots
   nps_id(st:en) =   charactertostring(ps_id(32:34,:))	; NH, SH and global in last 3 slots
 nptitstr(st:en) = charactertostring(ptitstr(32:34,:))	; NH, SH and global in last 3 slots
  nboxstr(st:en) =  charactertostring(boxstr(32:34,:))	; NH, SH and global in last 3 slots

 en = totalnew-3
 nboxS(32:en) = (/new_S/)		; add new regions
 nboxW(32:en) = (/new_W/)		; add new regions
 nboxN(32:en) = (/new_N/)		; add new regions
 nboxE(32:en) = (/new_E/)		; add new regions
   
   nps_id(32:en) = (/new_id/)	; add new regions
 nptitstr(32:en) = (/new_tit/)	; add new regions
  nboxstr(32:en) = (/new_box/)	; add new regions


  nboxS!0 = "region"
  nboxN!0 = "region"
  nboxE!0 = "region"
  nboxW!0 = "region"
  nboxS&region = new_region
  nboxN&region = new_region
  nboxE&region = new_region
  nboxW&region = new_region

 ; create netcdf file

  fileAtt             = True
  fileAtt@create_date = systemfunc("date")
  fileAtt@creator     = "Nan Rosenbloom (nanr@ucar.edu)"
  fileAtt@srcCode     = "mkNewRegions.ncl"
  fileAtt@project     = "adding Asian Sub-Regions (for Liya Jin)"
  fileattdef(fout, fileAtt)

  dimNames = (/"region","ncl1","ncl2","ncl3"/)
  dimSizes = (/nreg,18,20,20/)
  dimUnlim = (/False,False,False,False/)
        
  filedimdef(fout,dimNames,dimSizes,dimUnlim)
  filevardef(fout,"region",typeof(oregion),getvardims(oregion))
  filevardef(fout,"BOX_S",typeof(box_s),getvardims(nboxS))
  filevardef(fout,"BOX_N",typeof(box_n),getvardims(nboxN))
  filevardef(fout,"BOX_W",typeof(box_w),getvardims(nboxW))
  filevardef(fout,"BOX_E",typeof(box_e),getvardims(nboxE))
  filevardef(fout,"PS_ID",typeof(ps_id),getvardims(ps_id))
  filevardef(fout,"PTITSTR",typeof(ptitstr),getvardims(ptitstr))
  filevardef(fout,"BOXSTR",typeof(boxstr),getvardims(boxstr))
        
  filevarattdef(fout,"BOX_S",box_s)
  filevarattdef(fout,"BOX_N",box_n)
  filevarattdef(fout,"BOX_E",box_e)
  filevarattdef(fout,"BOX_W",box_w)
  filevarattdef(fout,"PS_ID",ps_id)
  filevarattdef(fout,"PTITSTR",ptitstr)
  filevarattdef(fout,"BOXSTR",boxstr)
        
  fout->region = (/new_region/)
  fout->BOX_S  = (/nboxS/)
  fout->BOX_W  = (/nboxW/)
  fout->BOX_E  = (/nboxE/)
  fout->BOX_N  = (/nboxN/)
  fout->PS_ID  = (/stringtocharacter(nps_id)/)
  fout->PTITSTR = (/stringtocharacter(nptitstr)/)
  fout->BOXSTR  = (/stringtocharacter(nboxstr)/)
  delete(fout)

 ; map regions

  res = True
  res@cnFillOn = True
  res@cnLineLabelsOn = False
  res@lbLabelBarOn = False
  res@cnLinesOn =  False
  res@mpGridLonSpacingF   = 60.0            ; Set lon grid spacing
  res@mpGridLatSpacingF    = 30.0           ; Set lat grid spacing
  res@mpFillOn             =  False
  res@mpOutlineOn          =  True
  res@mpGridAndLimbOn      =  True
  res@mpGridLineDashPattern =  2            ; Set grid line dash pattern (dash)
  res@mpGridLineThicknessF   = 0.5          ; Set grid line thickness
  sstr=(/" "/)
  res@gsnMaximize = True
  res@cnLevelSelectionMode =  "ExplicitLevels"
  wks = gsn_open_wks("ps","set3_reg_all")
  cmap = (/"(/1.00, 1.00, 1.00/)", "(/0.00, 0.00, 0.00/)", \
           "(/1.00, 1.00, 1.00/)", "Blue" /)
  gsn_define_colormap(wks, cmap )
  res@gsnLeftString = " "
  res@gsnRightString = " "
  res@cnLevels = (/0./)

  flag1 = area1
  flag1 = -0.1

  do ar = 0, nreg-4  ; don't include northern and southern hemisphere and global
    flag1({nboxS(ar):nboxN(ar)},{nboxW(ar):nboxE(ar)}) = 0.1*fland1({nboxS(ar):nboxN(ar)},{nboxW(ar):nboxE(ar)})-1.e-36
  end do

  res@gsnCenterString = "Model Data Regions - All"
  plot = gsn_csm_contour_map_ce(wks, flag1, res)

  do ar = 0, nreg-1
;----------------------------------------------
; Open file for plots 
;----------------------------------------------
    wks = gsn_open_wks("ps","map_reg_"+nps_id(ar))
    cmap = (/"(/1.00, 1.00, 1.00/)", "(/0.00, 0.00, 0.00/)", \
             "(/1.00, 1.00, 1.00/)", "Blue" /)
    gsn_define_colormap(wks, cmap )
    flag1 = -0.1
    flag1 ({nboxS(ar):nboxN(ar)},{nboxW(ar):nboxE(ar)}) = \
        0.1*fland1 ({nboxS(ar):nboxN(ar)},{nboxW(ar):nboxE(ar)}) - 1.e-36
    res@gsnCenterString = "Model Data Regions - " + nptitstr(ar) + nboxstr(ar)
    plot = gsn_csm_contour_map_ce(wks, flag1, res)
  end do

end
