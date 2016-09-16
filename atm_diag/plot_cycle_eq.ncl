; NCL script
; plot_cycle_eq.ncl
; Mark Stevens Jan 2003
;**************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
load "$DIAG_CODE/functions_contrib.ncl"  
load "$DIAG_CODE/functions_cycle_eq.ncl"
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
 infile1    = getenv("TEST_INPUT")     ; case1 input path/prefix 
 infile2    = getenv("CNTL_INPUT")     ; case2 input path/prefix 

; CASE 1 MODEL 
 inptr1 = addfile(infile1+"_ANN_climo.nc","r")  
 if (case_names .eq. "True") then
   case1 = getenv("CASE1")
 else
   case1 = inptr1@case  
 end if
 if (isatt(inptr1,"yrs_averaged")) then
   yrs_ave1 = inptr1@yrs_averaged 
 end if 
 delete(inptr1)

; CASE 2 IS MODEL
 if (compare.ne."OBS") then    
   inptr2 = addfile(infile2+"_ANN_climo.nc","r")  
   if (case_names .eq. "True") then
     case2 = getenv("CASE2")
   else
     case2 = inptr2@case  
   end if
   if (isatt(inptr2,"yrs_averaged")) then
     yrs_ave2 = inptr2@yrs_averaged 
   end if 
   delete(inptr2)
 end if

;---------------------------------------------------------------------
 if (compare .eq. "OBS") then
   obsvars = (/"PRECT_GPCP","SST_HADISST","TAUX_ERS","TAUY_ERS", \
               "SWCF_ERBE","LHFLX_WHOI", \
               "TAUX_LARYEA","TAUY_LARYEA"  /)
;  corresponding model variables
 vars = (/"PRECT_OCEAN","SST","TAUX_OCEAN","TAUY_OCEAN", \
          "SWCF_OCEAN", "LHFLX_OCEAN", \
          "TAUX_OCEAN","TAUY_OCEAN"  /)

 else

;  corresponding model variables
   vars = (/"PRECT_OCEAN","SST","TAUX_OCEAN","TAUY_OCEAN","SWCF_OCEAN", \
          "LHFLX_OCEAN"/)

 end if


 nvars  = dimsizes(vars)
;-----------------------------------------------------------------------
; common resources for contour plots
 minlon = 150  
 maxlon = 270   ; 90W
 plot = new(2,graphic)
 res                        = True        
 res@gsnDraw                = False      
 res@gsnFrame               = False
 res@txFontHeightF          = 0.020
 res@tiMainFontHeightF      = 0.022
 res@tiYAxisString = "Month"
 res@tmYLMode = "Explicit"
 res@tmYLValues = ispan(0,11,1)
 res@tmYLLabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
 res@tmXBMode = "Explicit"
 res@tmXBValues = ispan(minlon,maxlon,20)
 res@tmXBLabels = (/"150E","170E","170W","150W","130W","110W","90W"/)
 res@tmXBMinorValues = ispan(minlon,maxlon,10)
 if (color_type .eq. "COLOR") then 
   res@cnFillOn  = True
   res@cnLinesOn = False
   res@lbBoxMinorExtentF = 0.25
   res@lbOrientation = "vertical"
   res@cnLevelSelectionMode="ExplicitLevels"
   cmap = RGBtoCmap(rgb_file)
   cntr = new((/nvars,15/),float)
   if (compare .eq. "OBS") then
     ; PRECT
     cntr(0,:)=(/-3.5,-3.,-2.5,-2.,-1.5,-1.,-.5,0.,.5,1.,1.5,2.,2.5,3.,3.5/)
     ; SST
     cntr(1,:)=(/-2.1,-1.8,-1.5,-1.2,-.9,-.6,-.3,0.,.3,.6,.9,1.2,1.5,1.8,2.1/)
     ; TAUX
     cntr(2,:)=(/-2.8,-2.4,-2,-1.6,-1.2,-.8,-.4,0,.4,.8,1.2,1.6,2.,2.4,2.8/)
     ; TAUY
     cntr(3,:)=(/-2.8,-2.4,-2,-1.6,-1.2,-.8,-.4,0,.4,.8,1.2,1.6,2.,2.4,2.8/)
     ; SWCF 
     cntr(4,:)=(/-15.,-12.,-10.,-8.,-6.,-4.,-2.,0.,2.,4.,6.,8.,10.,12.,15./)
     ; LHFLX WHOI
     cntr(5,:) =(/-25.,-20.,-15.,-12.,-9.,-6.,-3.,0.,3.,6.,9.,12.,15.,20.,25./)
     ; TAUX LARYEA
     cntr(6,:)=cntr(2,:)
     ; TAUY LARYEA
     cntr(7,:)=cntr(3,:)
   else
     ; PRECT
     cntr(0,:)=(/-3.5,-3.,-2.5,-2.,-1.5,-1.,-.5,0.,.5,1.,1.5,2.,2.5,3.,3.5/)
     ; SST
     cntr(1,:)=(/-2.1,-1.8,-1.5,-1.2,-.9,-.6,-.3,0.,.3,.6,.9,1.2,1.5,1.8,2.1/)
     ; TAUX
     cntr(2,:)=(/-2.8,-2.4,-2,-1.6,-1.2,-.8,-.4,0,.4,.8,1.2,1.6,2.,2.4,2.8/)
     ; TAUY
     cntr(3,:)=(/-2.8,-2.4,-2,-1.6,-1.2,-.8,-.4,0,.4,.8,1.2,1.6,2.,2.4,2.8/)
     ; SWCF 
     cntr(4,:)=(/-15.,-12.,-10.,-8.,-6.,-4.,-2.,0.,2.,4.,6.,8.,10.,12.,15./)
     ; LHFLX
     cntr(5,:)=(/-25.,-20.,-15.,-12.,-9.,-6.,-3.,0.,3.,6.,9.,12.,15.,20.,25./)
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
 end if
;****************************************************************************
 do i = 0, nvars-1

;  CASE 1 IS MODEL

   if (vars(i).eq."LHFLX_OCEAN") then
     A = cycle_LHFLX_OCEAN (infile1)
   end if
   if (vars(i).eq."PRECT_OCEAN") then
     A = cycle_PRECT_OCEAN (infile1)
   end if
   if (vars(i).eq."SST") then
     A = cycle_SST (infile1)
   end if
   if (vars(i).eq."SWCF_OCEAN") then
     A = cycle_SWCF_OCEAN (infile1)
   end if
   if (vars(i).eq."TAUX_OCEAN") then
     A = cycle_TAUX_OCEAN (infile1)
   end if
   if (vars(i).eq."TAUY_OCEAN") then
     A = cycle_TAUY_OCEAN (infile1)
   end if

   if (all(A.eq.-999.)) then
     print (vars(i)+" not present in test case input file.")
     delete (A)
     continue
   end if

;  CASE 2 IS OBS
   if (compare .eq. "OBS") then

     if (obsvars(i).eq."LHFLX_WHOI") then
       case2 = "WHOI (1958-2006)"
       B = cycle_LHFLX_OCEAN_OBS (infile2,"/WHOI")
     end if
     if (obsvars(i).eq."PRECT_GPCP") then
       case2 = "GPCP (1979-2000)"
       B = cycle_PRECT_OCEAN_OBS (infile2,"/GPCP")
     end if
     if (obsvars(i).eq."SST_HADISST") then
       case2 = "HadISST (1982-2001)"
       B = cycle_SST_OBS (infile2,"/HadISST")
     end if
     if (obsvars(i).eq."SWCF_ERBE") then
       case2 = "ERBE (1985-1989)"
       B = cycle_SWCF_OCEAN_OBS (infile2,"/ERBE")
     end if
     if (obsvars(i).eq."TAUX_ERS") then
       case2 = "ERS (1992-2000)"
       B = cycle_TAUX_OCEAN_OBS (infile2,"/ERS")
     end if
     if (obsvars(i).eq."TAUY_ERS") then
       case2 = "ERS (1992-2000)"
       B = cycle_TAUY_OCEAN_OBS (infile2,"/ERS")
     end if
     if (obsvars(i).eq."TAUX_LARYEA") then
       case2 = "LARGE-YEAGER (1984-2004)"
       B = cycle_TAUX_OCEAN_OBS (infile2,"/LARYEA")
     end if
     if (obsvars(i).eq."TAUY_LARYEA") then
       case2 = "LARGE-YEAGER (1984-2004)"
       B = cycle_TAUY_OCEAN_OBS (infile2,"/LARYEA")
     end if
     


   else
;  model-to-model comparison

     if (vars(i).eq."LHFLX_OCEAN") then
       B = cycle_LHFLX_OCEAN (infile2)
     end if
     if (vars(i).eq."PRECT_OCEAN") then
       B = cycle_PRECT_OCEAN (infile2)
     end if
     if (vars(i).eq."SST") then
       B = cycle_SST (infile2)
     end if
     if (vars(i).eq."SWCF_OCEAN") then
       B = cycle_SWCF_OCEAN (infile2)
     end if
     if (vars(i).eq."TAUX_OCEAN") then
       B = cycle_TAUX_OCEAN (infile2)
     end if
     if (vars(i).eq."TAUY_OCEAN") then
       B = cycle_TAUY_OCEAN (infile2)
     end if
   end if

   if (all(B.eq.-999.)) then
     print (vars(i)+" not present in control case input file.")
     delete (A)
     delete (B)
     continue
   end if

;----------------------- Open files for plots ----------------------
   if (compare .eq. "OBS") then
     if (color_type .eq. "COLOR") then 
       wks = gsn_open_wks(plot_type,wkdir+"set11_"+obsvars(i)+"_obsc")
       gsn_define_colormap(wks,cmap)
     else
       wks = gsn_open_wks(plot_type,wkdir+"set11_"+obsvars(i)+"_obs")
     end if
   else
     if (color_type .eq. "COLOR") then 
       wks = gsn_open_wks(plot_type,wkdir+"set11_"+vars(i)+"_c")
       gsn_define_colormap(wks,cmap)
     else
       wks = gsn_open_wks(plot_type,wkdir+"set11_"+vars(i))
     end if
   end if

;------------------------------------------------------------------------
; case contour plots of time(y) vs. longitude(x)

   if (color_type .eq. "COLOR") then
     res@cnLevels = cntr(i,:) 
   else
     min1 = min(A(:,{minlon:maxlon}))
     max1 = max(A(:,{minlon:maxlon}))
     min2 = min(B(:,{minlon:maxlon}))
     max2 = max(B(:,{minlon:maxlon}))
     minab = min((/min1,min2/))
     maxab = max((/max1,max2/))
     mnmxint = nice_mnmxintvl(minab,maxab,cnlvls,False)
     res@cnMinLevelValF = mnmxint(0)
     res@cnMaxLevelValF = mnmxint(1)
     res@cnLevelSpacingF = mnmxint(2)
   end if

   res@gsnLeftString = A@long_name
   res@gsnRightString = A@units
   if (isvar("yrs_ave1")) then
     res@tiMainString = case1+" (yrs "+yrs_ave1+")"	
   else
     res@tiMainString = case1	
   end if
   plot(0) = gsn_csm_contour(wks,A(:,{minlon:maxlon}),res)

   if (color_type .eq. "MONO") then
     plot(0) = ZeroNegDashLineContour (plot(0))
   end if
   delete(res@tiMainString)

   if (isvar("yrs_ave2")) then
     res@tiMainString = case2+" (yrs "+yrs_ave2+")"	
   else
     res@tiMainString = case2	
   end if
   plot(1) = gsn_csm_contour(wks,B(:,{minlon:maxlon}),res)

   if (color_type .eq. "MONO") then
     plot(1) = ZeroNegDashLineContour (plot(1))
   else
     delete (res@cnLevels)
   end if

   delete (res@gsnLeftString)

   pan = True
   pan@txString = "Equatorial Pacific Ocean (5S-5N)"
   pan@txFont = "helvetica-bold"
   pan@txFontHeightF = 0.018
   pan@gsnMaximize = True
   pan@gsnFrame = False
   pan@gsnPaperOrientation = "portrait"
   pan@gsnPanelYWhiteSpacePercent = 2.0
   if (time_stamp .eq. "True") then
     pan@gsnPanelBottom = 0.05
     gsn_panel(wks,plot,(/2,1/),pan)
     infoTimeStamp(wks, 0.011, "DIAG Version: "+version)   
   else
     gsn_panel(wks,plot,(/2,1/),pan)
   end if
   frame (wks)
   delete (A)
   delete (B)
 end do  
      
end
