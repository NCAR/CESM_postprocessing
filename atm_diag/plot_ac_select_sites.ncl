; NCL script
; plot_arm_sites.ncl
; Julie Caron, August 2008
; set 15
;**************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
load "$DIAG_CODE/functions_contrib.ncl"  
load "$DIAG_CODE/functions_cycle.ncl"
;**************************************************
begin
 compare    = getenv("COMPARE")
 color_type = getenv("COLORTYPE")
 rgb_file   = getenv("RGB_FILE") 
 plot_type  = getenv("PLOTTYPE")
 version    = getenv("DIAG_VERSION")
 wkdir      = getenv("WKDIR")
 time_stamp = getenv("TIMESTAMP")
 case_names = getenv("CASENAMES")
 ncdf_mode  = getenv("NCDF_MODE")
 infile1    = getenv("TEST_INPUT")     ; case1 input prefix 
 outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
 infile2    = getenv("CNTL_INPUT")     ; case2 input prefix 

 if (compare .ne. "OBS") then
   outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
 else
   infile2 = getenv("OBS_DATA")
 end if

 sites = (/"SGP","NSA","TWP1","TWP2","TWP3","SHEBA"/)
 latv = (/36.6,71.3,-2.1,-0.5,-12.4,77.0/)
 lonv = (/262.5,203.4,147.4,166.9,130.9,202.0/)

 nsites = dimsizes(sites)

; CASE 1 MODEL 
 inptr1 = addfile(infile1+"_01_climo.nc","r")  
 lat = inptr1->lat
 lon = inptr1->lon

 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case  
 end if
 if (isatt(inptr1,"yrs_averaged")) then
   yrs_ave1 = inptr1@yrs_averaged 
 end if 
 delete(inptr1)
 if (ncdf_mode .eq. "write") then
   outptr1 = addfile(outfile1,"w")
 else
   outptr1 = addfile(outfile1,"c")
 end if

; CASE 2 IS OBS
if (compare.eq."OBS") then    
   month = (/"01","02","03","04","05","06","07","08","09","10","11","12"/)   
   ac_nsa = new(12,file)
   ac_sgp = new(12,file)
   ac_twp1 = new(12,file)
   ac_twp2 = new(12,file)
   ac_twp3 = new(12,file)
   ac_sheb = new(12,file)
   do m = 0, 11
     ac_nsa(m) = addfile(infile2+"/ARM_annual_cycle_nsa_cmbe_sound_p_f.cdf","r")
     ac_sgp(m) = addfile(infile2+"/ARM_annual_cycle_sgp_cmbe_sound_cf_p_f.cdf","r")
     ac_twp1(m) = addfile(infile2+"/ARM_annual_cycle_twp_c1_cmbe_sound_p_f.cdf","r")
     ac_twp2(m) = addfile(infile2+"/ARM_annual_cycle_twp_c2_cmbe_sound_p_f.cdf","r")
     ac_twp3(m) = addfile(infile2+"/ARM_annual_cycle_twp_c3_cmbe_sound_p_f.cdf","r")
     ac_sheb(m) = addfile(infile2+"/SHEBA_annual_cycle.nc","r")
   end do
 else    

;  CASE 2 IS MODEL

  ; to check for 1d vs 2d variables
   opath = getenv("OBS_DATA")
   ac_sgp = new(1,file)
   ac_sgp = addfile(opath+"/ARM_annual_cycle_sgp_cmbe_sound_cf_p_f.cdf","r")

   inptr2 = addfile(infile2+"_01_climo.nc","r")  

   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case  
   end if
   if (isatt(inptr2,"yrs_averaged")) then
     yrs_ave2 = inptr2@yrs_averaged 
   end if 
   if (ncdf_mode .eq. "write") then
     outptr2 = addfile(outfile2,"w")
   else
     outptr2 = addfile(outfile2,"c")
   end if
 end if

;---------------------------------------------------------------------
 do isite = 0, nsites-1     

  if (compare .eq. "OBS") then
   if(sites(isite).eq."SGP")then
    obsvars = (/"Temp","H2O_Mixing_Ratio","cld_frac","h","pwv","lwp","swdn","lwdn","tot_cld","Prec","LH","SH"/)
 ;  corresponding model variables
    vars = (/"T","Q","CLOUD","MSE","TMQ","TGCLDLWP","FSDS","FLDS","CLDTOT","PRECT","LHFLX","SHFLX"/)
   else
    if(sites(isite).eq."SHEBA")then
     obsvars = (/"swdn","lwdn"/)
     vars = (/"FSDS","FLDS"/)
    else
     obsvars = (/"Temp","H2O_Mixing_Ratio","cld_frac","h","pwv","lwp","swdn","lwdn","tot_cld"/)
  ;  corresponding model variables
     vars = (/"T","Q","CLOUD","MSE","TMQ","TGCLDLWP","FSDS","FLDS","CLDTOT"/)
    end if
   end if
  else 
 ;  model-to-model comparisons
   if(sites(isite).eq."SGP")then
    obsvars = (/"Temp","H2O_Mixing_Ratio","cld_frac","h","pwv","lwp","swdn","lwdn","tot_cld","Prec","LH","SH"/)
    vars = (/"T","Q","CLOUD","MSE","TMQ","TGCLDLWP","FSDS","FLDS","CLDTOT","PRECT","LHFLX","SHFLX"/)
   else
    if(sites(isite).eq."SHEBA")then
     obsvars = (/"swdn","lwdn"/)
     vars = (/"FSDS","FLDS"/)
    else
     obsvars = (/"Temp","H2O_Mixing_Ratio","cld_frac","h","pwv","lwp","swdn","lwdn","tot_cld"/)
     vars = (/"T","Q","CLOUD","MSE","TMQ","TGCLDLWP","FSDS","FLDS","CLDTOT"/)
    end if
   end if
  end if

  vname = (/"Temperature","Specific Humidity","Cloud Fraction","Moist Static Energy","Precipitable Water","Cloud Liquid Water Path","Downwelling SW at Surface","Downwelling LW at Surface","Total Cloud","Precipitation","Latent Heat Flux","Sensible Heat Flux"/)
  unit = (/"K","g/kg","%","kJ/kg","mm","g/m:S:2:N:","W/m:S:2:N:","W/m:S:2:N:","%","mm/day","W/m:S:2:N:", "W/m:S:2:N:"/)

  n3dvars = 4 ; number of 3D vars
  nvars  = dimsizes(vars)

;-----------------------------------------------------------------------
; common resources for contour plots
  plot = new(3,graphic)
  res                        = True        
  res@gsnDraw                = False      
  res@gsnFrame               = False
  res@txFontHeightF          = 0.025
  res@sfXArray               = ispan(0,12,1)
  res@tiMainFontHeightF      = 0.03
  res@tmXBMode               = "Explicit"
  res@tmXBValues             = ispan(0,12,1)
  res@tmXBLabels = (/"J","F","M","A","M","J","J","A","S",\
                     "O","N","D","J"/) 

  if (color_type .eq. "COLOR") then 
    res@cnFillOn  = True
    res@cnLinesOn = False
    res@lbTitleOn = True
    res@lbLabelFontHeightF = 0.018
    res@lbTitleFontHeightF = 0.02
    res@lbBoxMinorExtentF = 0.18
    res@cnLevelSelectionMode="ExplicitLevels"
    cmap = RGBtoCmap(rgb_file) 

    if (compare .eq. "OBS") then
      cntr = new((/n3dvars,15/),float)
      dcntr = new((/n3dvars,15/),float)
      cntr(0,:)= (/200.,210.,220.,230.,240.,250.,260.,270.,280.,290.,300.,310.,320.,330.,340./) ;T
      dcntr(0,:)= (/-7.,-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6.,7./)
      cntr(1,:)= (/0.5,1.,2.,3.,4.,5.,6.,7.,8.,9.,10.,11.,12.,13.,14./) ;Q
      dcntr(1,:)= (/-1.4,-1.2,-1.0,-0.8,-0.6,-.4,-.2,0.,0.2,0.4,0.6,0.8,1.0,1.2,1.4/)
      cntr(2,:)= (/5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,70.,80.,90./) ;CLOUD
      dcntr(2,:)= (/-4.0,-3.5,-3.,-2.5,-2.,-1.5,-1.,0.,1.,1.5,2.,2.5,3.,3.5,4.0/)*10.
      cntr(3,:)= (/260.,270.,280.,290.,300.,310.,320.,330.,340.,350.,360.,370.,380.,390.,400./) ;MSE
      dcntr(3,:)= (/-14.,-12.,-10.,-8.,-6.,-4.,-2.,0.,2.,4.,6.,8.,10.,12.,14./)
    else
      stride = (/2,1,1,2,2/)
      stride_diff = (/1,1,1,1,1/)
      cntr = new((/n3dvars,15/),float)
      dcntr = new((/n3dvars,15/),float)
      cntr(0,:)= (/200.,210.,220.,230.,240.,250.,260.,270.,280.,290.,300.,310.,320.,330.,340./) ;T
      dcntr(0,:)= (/-7.,-6.,-5.,-4.,-3.,-2.,-1.,0.,1.,2.,3.,4.,5.,6.,7./)
      cntr(1,:)= (/0.5,2.,4.,6.,8.,10.,12.,14.,16.,18.,20.,22.,24.,26.,28./) ;Q
      dcntr(1,:)= (/-4.0,-3.5,-3.,-2.5,-2.,-1.5,-1.,0.,1.,1.5,2.,2.5,3.,3.5,4.0/)
      cntr(2,:)= (/5.,10.,15.,20.,25.,30.,35.,40.,45.,50.,55.,60.,70.,80.,90./) ;CLOUD
      dcntr(2,:)= (/-4.0,-3.5,-3.,-2.5,-2.,-1.5,-1.,0.,1.,1.5,2.,2.5,3.,3.5,4.0/)*10.
      cntr(3,:)= (/260.,270.,280.,290.,300.,310.,320.,330.,340.,350.,360.,370.,380.,390.,400./) ;MSE
      dcntr(3,:)= (/-14.,-12.,-10.,-8.,-6.,-4.,-2.,0.,2.,4.,6.,8.,10.,12.,14./)
    end if
  else
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnFillOn  = False
    res@cnLinesOn = True 
    res@cnLineLabelsOn = True 
    res@cnLineLabelInterval = 1
    res@cnLineLabelFontHeightF =  0.02
    res@cnInfoLabelFontHeightF =  0.02
    cnlvls = 15
    dcnlvls = 12
  end if
;****************************************************************************

  do i = 0, nvars-1

   if (vars(i).eq."T") then
     A = cycle_T (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."Q") then
     A = cycle_Q (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."CLOUD") then
     A = cycle_CLOUD (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."MSE") then
     A = cycle_MSE (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."TMQ") then
     A = cycle_TMQ (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."TGCLDLWP") then
     A = cycle_TGCLDLWP (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."FSDS") then
     A = cycle_FSDS (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."FLDS") then
     A = cycle_FLDS (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."CLDTOT") then
     A = cycle_CLDTOT (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
   end if
   if(sites(isite).eq."SGP")then
    if (vars(i).eq."PRECT") then
      A = cycle_PRECT_PT (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
    end if
    if (vars(i).eq."LHFLX") then
      A = cycle_LHFLX (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
    end if
    if (vars(i).eq."SHFLX") then
      A = cycle_SHFLX (infile1,outptr1,latv(isite),lonv(isite),sites(isite))
    end if
   end if

   if (all(A.eq.-999.0)) then
     print (vars(i)+" not present in test case input file.")
     delete (A)
     continue
   end if

   A@short_name = vars(i)

;  CASE 2 IS OBS
   if (compare .eq. "OBS") then

     do m = 0, 11
       if (sites(isite).eq."SGP")then
         inptr2 = ac_sgp(m)
         case2 = "ARM SGP"
       end if
       if (sites(isite).eq."NSA")then
         inptr2 = ac_nsa(m)
         case2 = "ARM NSA"
       end if
       if (sites(isite).eq."TWP1")then
         inptr2 = ac_twp1(m)
         case2 = "ARM TWP1"
       end if
       if (sites(isite).eq."TWP2")then
         inptr2 = ac_twp2(m)
         case2 = "ARM TWP2"
       end if
       if (sites(isite).eq."TWP3")then
         inptr2 = ac_twp3(m)
         case2 = "ARM TWP3"
       end if
       if (sites(isite).eq."SHEBA")then
         inptr2 = ac_sheb(m)
         case2 = "SHEBA"
       end if

      tmpin = inptr2->$obsvars(i)$     

      dims = dimsizes(tmpin)
      dsize = dimsizes(dims)

      if(dsize.gt.1)then
        if (m.eq.0) then 

          plev = inptr2->lev(::-1)
          plev@units = "mb" 

          np = dimsizes(plev)
          B = new((/13,np/),float)
          B!0 = "time"
          B&time = ispan(1,13,1)
          B!1 = "lev"
          B&lev = plev
          B@long_name = vname(i)
          B@units = unit(i)
        end if

         if(obsvars(i).eq."H2O_Mixing_Ratio")then
           tmp = tmpin(:,::-1)*1000.
         else
           if(obsvars(i).eq."h")then
            tmp = tmpin(:,::-1)/1000.
           else
            tmp = tmpin(:,::-1)
           end if
         end if

         B(0:11,:) = (/tmp/)
         B(12,:) = B(0,:)                  ; wrap around

      else

        if (m.eq.0) then 

          B = new((/13/),float)
          B!0 = "time"
          B&time = ispan(1,13,1)
          B@long_name = vname(i)
          B@units = unit(i)
        end if

          tmp = tmpin
         B(0:11) = (/tmp/)
         B(12) = B(0)                  ; wrap around
      end if

        delete(tmpin)
        delete(tmp)
     end do
   else
;  model-to-model comparison

    plev = (/25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350,\
     375, 400, 425, 450, 475, 500, 525, 550, 575, 600, 625, 650, 675, 700,\
     725, 750, 775, 800, 825, 850, 875, 900, 925, 950, 975, 1000/)
    plev = plev(::-1)

        tmpin = ac_sgp->$obsvars(i)$
        dims = dimsizes(tmpin)
        dsize = dimsizes(dims)
        delete(tmpin)
       
    if (vars(i).eq."T") then
      B = cycle_T (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
    end if
    if (vars(i).eq."Q") then
      B = cycle_Q (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
    end if
    if (vars(i).eq."CLOUD") then
      B = cycle_CLOUD (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
    end if
    if (vars(i).eq."MSE") then
      B = cycle_MSE (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
    end if

    if (vars(i).eq."TMQ") then
      B = cycle_TMQ (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
    end if
   if (vars(i).eq."TGCLDLWP") then
     B = cycle_TGCLDLWP (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."FSDS") then
     B = cycle_FSDS (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."FLDS") then
     B = cycle_FLDS (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
   end if
   if (vars(i).eq."CLDTOT") then
     B = cycle_CLDTOT (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
   end if
   if(sites(isite).eq."SGP")then
    if (vars(i).eq."PRECT") then
      B = cycle_PRECT_PT (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
    end if
    if (vars(i).eq."LHFLX") then
      B = cycle_LHFLX (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
    end if
    if (vars(i).eq."SHFLX") then
      B = cycle_SHFLX (infile2,outptr2,latv(isite),lonv(isite),sites(isite))
    end if
   end if

    if (all(B.eq.-999.)) then
      print (vars(i)+" not present in control case input file.")
      delete (A)
      delete (B)
      continue
    end if
   end if

;----------------------- Open files for plots ----------------------
   if (compare .eq. "OBS") then
     if (color_type .eq. "COLOR") then 
       wks = gsn_open_wks(plot_type,wkdir+"set15_"+sites(isite)+"_"+vars(i)+"_obsc")
       gsn_define_colormap(wks,cmap)
     else
       wks = gsn_open_wks(plot_type,wkdir+"set15_"+sites(isite)+"_"+vars(i)+"_obs")
     end if
   else
     if (color_type .eq. "COLOR") then 
       wks = gsn_open_wks(plot_type,wkdir+"set15_"+sites(isite)+"_"+vars(i)+"_c")
       gsn_define_colormap(wks,cmap)
     else
       wks = gsn_open_wks(plot_type,wkdir+"set15_"+sites(isite)+"_"+vars(i))
     end if
   end if

  if(dsize.gt.1)then
  ;------------------------------------------------------------------------
  ; case contour plots of time(x) vs. pressure/height(y)
    min1 = min(A)
    max1 = max(A)
    min2 = min(B)
    max2 = max(B)

    if (color_type .eq. "COLOR") then
      res@cnLevels = cntr(i,:) 
      res@lbLabelStride = 2
      res@lbOrientation = "Horizontal"
      res@lbTitleString = "MIN = "+sprintf("%6.2f",min1)+ \
                         " MAX = "+sprintf("%6.2f",max1)
    else
      minab = min((/min1,min2/))
      maxab = max((/max1,max2/))
      mnmxint = nice_mnmxintvl(minab,maxab,cnlvls,False)
      res@cnMinLevelValF = mnmxint(0)
      res@cnMaxLevelValF = mnmxint(1)
      res@cnLevelSpacingF = mnmxint(2)
    end if

    res@gsnLeftString = A@short_name+" at "+lat({latv(isite)})+","+lon({lonv(isite)})

    if (isvar("yrs_ave1")) then
      res@tiMainString = case1+" (yrs "+yrs_ave1+")"	
    else
      res@tiMainString = case1	
    end if

    res@sfYArray = plev
    plot(0) = gsn_csm_pres_hgt(wks,A(lev|:,time|:),res)
    if (color_type .eq. "MONO") then
      plot(0) = ZeroNegDashLineContour (plot(0))
    else
      delete (res@lbTitleString)
    end if
    delete(res@sfYArray)
    delete(res@tiMainString)

    if (isvar("yrs_ave2")) then
      res@tiMainString = case2+" (yrs "+yrs_ave2+")"	
    else
      res@tiMainString = case2	
    end if
    res@sfYArray = plev
    if (color_type .eq. "COLOR") then
      res@lbTitleString = "MIN = "+sprintf("%6.2f",min2)+ \
                         " MAX = "+sprintf("%6.2f",max2)
    end if
    res@gsnLeftString = B@long_name
    plot(1) = gsn_csm_pres_hgt(wks,B(lev|:,time|:),res)
    if (color_type .eq. "MONO") then
      plot(1) = ZeroNegDashLineContour (plot(1))
    else
      delete (res@cnLevels)
      delete (res@lbTitleString)
    end if

    delete (res@sfYArray)
    delete (res@gsnLeftString)
    delete (min1)
    delete (max1)
    delete (min2)
    delete (max2)

 ;----------------------------------------------------------------------
 ; difference plot of time(x) vs. pres/height(y)

      C = A                                    ; copy dims,coords
      C = (/A-B/)                              ; get diff values
      res@sfYArray = plev

    mind = min(C)
    maxd = max(C)

    res@tiMainString = case1+" - "+case2
    if (color_type .eq. "COLOR") then
      res@cnLevels = dcntr(i,:) 
      res@lbLabelStride = 1
      res@lbOrientation = "Vertical"
      res@lbTitleString = "MIN = "+sprintf("%6.2f",mind)+ \
                         " MAX = "+sprintf("%6.2f",maxd)
    else
      mnmxint = nice_mnmxintvl(mind,maxd,dcnlvls,False)
      res@cnMinLevelValF = mnmxint(0)
      res@cnMaxLevelValF = mnmxint(1)
      res@cnLevelSpacingF = mnmxint(2)
    end if

    plot(2) = gsn_csm_pres_hgt(wks,C(lev|:,time|:),res)
    plot(2) = ZeroNegDashLineContour (plot(2))
    if (color_type .eq. "COLOR") then
      delete (res@lbTitleString)
 ;    delete (res@lbBoxMinorExtentF)
      delete (res@cnLevels)
    end if
    delete (mind)
    delete (maxd)

    pan = True
    pan@gsnMaximize = True
    pan@gsnFrame = False
    pan@gsnPaperOrientation = "portrait"
    if (time_stamp .eq. "True") then
      pan@gsnPanelBottom = 0.05
      gsn_panel(wks,plot,(/2,2/),pan)
      infoTimeStamp(wks, 0.011, "DIAG Version: "+version)   
    else
      gsn_panel(wks,plot,(/2,2/),pan)
    end if
    frame (wks)

    delete(res@sfYArray)
  else
 ;-----------------------------------
 ; case line plots of annual cycle
 ;-----------------------------------

    res2 = True
    res2@gsnMaximize = True
    res2@gsnPaperOrientation = "portrait"
    res2@tiMainString = "Annual Cycle of "+A@long_name
    res2@tiMainFontHeightF = 0.022
    res2@tiMainFont = "helvetica-bold"
    res2@tiYAxisFontHeightF = 0.015
    if (color_type .eq. "COLOR") then
      res2@xyLineColors    = (/"red","blue"/)
    else
      res2@xyMonoLineColor = True
      res2@xyLineColor = "black"
    end if
    res2@xyLineThicknesses = (/2,2/)
    res2@xyDashPatterns    = (/1,0/)
    res2@xyMarkLineModes = (/"MarkLines","MarkLines"/)
    res2@xyMarker = 16
    res2@xyMarkerSizeF = 0.01
    res2@pmLegendDisplayMode = "Always"
    res2@pmLegendSide = "Bottom"
    res2@pmLegendWidthF = 0.15
    res2@pmLegendHeightF = 0.08
    res2@pmLegendOrthogonalPosF = -.018
    res2@pmLegendParallelPosF = 0.5
    res2@lgLabelFontHeightF = .018
    res2@lgPerimOn = True
    res2@txFontHeightF = 0.020
    res2@tmXBMode = "Explicit"
    res2@tmXBLabelFontHeightF = 0.015
    res2@tmXBLabels=(/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep", \
                     "Oct","Nov","Dec","Jan"/)
    res2@tmXBValues = ispan(0,12,1)

    if (compare .eq. "OBS") then
      if (isvar("yrs_ave1")) then
        res2@xyExplicitLegendLabels=(/case1+" ("+yrs_ave1+")",case2/)
      else
        res2@xyExplicitLegendLabels=(/case1,case2/)
      end if
    else
      if (isvar("yrs_ave1") .and. isvar("yrs_ave2")) then
        res2@xyExplicitLegendLabels=(/case1+" ("+yrs_ave1+")",case2+" ("+yrs_ave2+")"/)
      end if
      if (.not.isvar("yrs_ave1") .and. isvar("yrs_ave2")) then
        res2@xyExplicitLegendLabels=(/case1,case2+" ("+yrs_ave2+")"/)
      end if
      if (isvar("yrs_ave1") .and. .not.isvar("yrs_ave2")) then
        res2@xyExplicitLegendLabels=(/case1+" ("+yrs_ave1+")",case2/)
      end if
      if (.not.isvar("yrs_ave1") .and. .not.isvar("yrs_ave2")) then
        res2@xyExplicitLegendLabels=(/case1,case2/)
      end if
    end if


    res2@gsnLeftString = vars(i)+" at "+lat({latv(isite)})+","+lon({lonv(isite)})
    res2@tiYAxisString = A@units
    

    arr = new( (/2,13/), float)
    arr(0,:) = A
    arr(1,:) = B

    months = new((/2,13/),integer)
    months(0,:) = ispan(0,12,1)
    months(1,:) = ispan(0,12,1)
    months!0 = "month"
    months!1 = "month"

    res2@gsnFrame = False
    res2@gsnDraw = False
    plot2 = new ( (/2/), graphic)
    plot2(0) = gsn_csm_xy(wks,months,arr,res2)

 ;difference plot

    res2@pmLegendDisplayMode = "Never"
    res2@tiMainString = "Difference "+case1+" - "+case2

      C = A                                    ; copy dims,coords
      C = (/A-B/)                              ; get diff values

    plot2(1) = gsn_csm_xy(wks,months,C,res2)
    gsn_panel(wks,plot2(0:1),(/2,1/),False)

    delete(plot2)
  end if

    delete(dims)
    delete(dsize)

    delete(C)
    delete(B)
    delete(A)
  end do             ; loop over variables 
  delete(vars)
  delete(obsvars)
 end do                ; loop over ARM sites

end
