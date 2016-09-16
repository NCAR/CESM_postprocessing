load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
load "$DIAG_SHARED/$VAR_MASTER"

;************************************************
begin
  print ("=========================================")
  print ("Starting:  set_1.ncl")
  print ("Start Time: "+systemfunc("date") )
  print ("=========================================")
  ptmpdir1 = getenv("PTMPDIR_1")
  ptmpdir2 = getenv("PTMPDIR_2")
  wkdir   = getenv("WKDIR")
  plot_type  = getenv("PLOTTYPE")
  useCommon1 = getenv("UseCommonName_1")
  useCommon2 = getenv("UseCommonName_2")


; the set lists contains two columns of information. This comes into
; NCL as one long string that we need to parse out.
  tmp = stringtocharacter(asciiread(wkdir+"/master_set1.txt",-1,"string"))
  nvar = dimsizes(tmp(:,0))
  scale_type = new(nvar,"string")
  vars       = new(nvar,"string")
  c13Flag    = new(nvar,"string")
  do i=0,nvar-1
    scale_type(i) = charactertostring(tmp(i,0:12))
    vars(i)       = charactertostring(tmp(i,16:))
    c13Flag(i)    = charactertostring(tmp(i,16:19))     ; derived variable prefix
  end do

;*************************************************
; get case names and create filenames to read in
;*************************************************
  nyrs1    = stringtointeger(getenv("trends_num_yrs_1"))
  fyr1     = stringtointeger(getenv("trends_first_yr_1"))
  matchYr1 = stringtointeger(getenv("trends_match_yr_1"))
  nyrs2    = stringtointeger(getenv("trends_num_yrs_2"))
  fyr2     = stringtointeger(getenv("trends_first_yr_2"))
  matchYr2 = stringtointeger(getenv("trends_match_yr_2"))
trendsFlag = stringtointeger(getenv("trends_match_Flag"))

  yrs    = new((/2/),"integer")
  offset = new((/2/),"integer")
  if (nyrs1 .ne. nyrs2 .or. fyr1 .ne. fyr2 .or. trendsFlag .eq. 1) then
     x2y2Plot = 1                ; 1=ON, 0=OFF
     yrDifferential = matchYr2 - matchYr1
     fy = min( (/fyr1,(fyr2-yrDifferential)/) )
     ly = max( (/(fyr1+nyrs1),(fyr2-yrDifferential+nyrs2)/) )
     nyrs = ly - fy

     fy1 = fy
     fy2 = fy + yrDifferential
     if (fyr1 .eq. fy) then
        offset(0) = 0
        offset(1) = matchYr2 - fy2
     else
        offset(1) = 0
        offset(0) = matchYr1 - fy1
     end if
     tspan = ispan(0,nyrs-1,1)
     t1 = tspan + fy
     t2 = tspan + fy + yrDifferential
  else
     x2y2Plot = 0                ; 1=ON, 0=OFF
     nyrs = nyrs1
     fyr  = fyr1
     offset(0) = 0
     offset(1) = 0
  end if
  yrs(0) = nyrs1
  yrs(1) = nyrs2

; ************************************************
; open new output files for intermediate variables
; ************************************************
  name1      = "prefix_"+1
  name2      = "prefix_"+2
  prefix1  = getenv(name1)
  prefix2  = getenv(name2)
  filo1  = ptmpdir1 +"/"+prefix1+"_ANN_globalClimo.nc"
  filo2  = ptmpdir2 +"/"+prefix2+"_ANN_globalClimo.nc"
  system("/bin/rm -f " + filo1)
  system("/bin/rm -f " + filo2)
  delete(filo1)
  delete(filo2)
  fout1 = addfile(ptmpdir1+"/"+prefix1+"_ANN_globalClimo.nc","c")
  fout2 = addfile(ptmpdir2+"/"+prefix2+"_ANN_globalClimo.nc","c")

  fileAtt               = True
  fileAtt@history       = "global climatology calculated by set_1.ncl:global_values():lnd_func.ncl"
  fileAtt@creation_date = systemfunc("date")
  fileattdef(fout1, fileAtt)

  dimNames      = (/"time","levsoi"/)
  dimSizes      = (/-1,10/)                ; bummer that this is hardwired....
  dimUnlim      = (/True,False/)

  filedimdef(fout1,dimNames,dimSizes,dimUnlim)
  filedimdef(fout2,dimNames,dimSizes,dimUnlim)

  data   = new((/2,nyrs/),"float")
  data3  = new((/2,nyrs,10/),"float")    ; how do we not hardwire this?
  cases  = new(2,"string")
  prefix = new(2,"string")
  do m = 0,1
    name2      = "prefix_"+(m+1)
    prefix(m)  = getenv(name2)
  end do
  in1    = addfile(ptmpdir1+"/"+prefix(0)+"ANN_ALL.nc","r")
  in2    = addfile(ptmpdir2+"/"+prefix(1)+"ANN_ALL.nc","r")
  landfrac1 = in1->landfrac
  area1     = in1->area
  time1     = in1->time
  landfrac2 = in2->landfrac
  area2     = in2->area
  time2     = in2->time
  nlev1 = 0
  if(isfilevar(in1,"levsoi")) then
        nlev1       = getfilevardimsizes(in1,"levsoi")
               levsoi1     = in1->levsoi
  end if
  if (isfilevar(in1,"levgrnd")) then
            nlev1       = getfilevardimsizes(in1,"levgrnd")
               levsoi1     = in1->levgrnd
  end if
  if (nlev1 .eq. 0)
     print("FATAL ERROR:  nlev1 = 0")
     exit
  end if
; truncate soil layers if needed
  if (nlev1 .gt. 10) then
;    print("Truncating soil levels to 10 levels [caseid: "+prefix(0)+"  nlev:  " + nlev +"]")
     nlev1 = 10
  end if
  nlev2 = 0
  if (isfilevar(in2,"levsoi")) then
     nlev2       = getfilevardimsizes(in2,"levsoi")
     levsoi2     = in2->levsoi
  end if
  if (isfilevar(in2,"levgrnd")) then
            nlev2 = getfilevardimsizes(in2,"levgrnd")
     levsoi2     = in2->levgrnd
  end if
  if (nlev2 .eq. 0)
     print("FATAL ERROR:  nlev2 = 0")
     exit
  end if
; truncate soil layers if needed
  if (nlev2 .gt. 10) then
;    print("Truncating soil levels to 10 levels [caseid: "+prefix(1)+"  nlev:  " + nlev +"]")
     nlev2 = 10
  end if

; print("Start main loop")
; print ("=========================================")
; print ("Time: "+systemfunc("date") )
; print ("=========================================")
;*************************************************
; main loop
;*************************************************
  do i=0,dimsizes(vars)-1 
     do m = 0,1 
        if (m .eq. 0) then 
           useFlag = useCommon1 
        end if
        if (m .eq. 1) then 
           useFlag = useCommon2 
        end if
        if (useFlag .eq. "True") then
           name   = "commonName_"+(m+1)
        else
           name   = "caseid_"+(m+1)
        end if
        cases(m)   = "  "+getenv(name)
        if (m .eq. 0) then
           in       = in1
           landfrac = landfrac1
           area     = area1
           time     = time1
           nlev     = nlev1
           levsoi   = levsoi1
        else
           in       = in2
           landfrac = landfrac2
           area     = area2
           time     = time2
           nlev     = nlev2
           levsoi   = levsoi2
        end if

        if (yrs(m) .ne. dimsizes(time)) then
           print("   ")
           print("   ")
           print("FATAL ERROR:")
           print("ANN_ALL.nc time dimension wrong:  ANN_ALL.nc=(" + dimsizes(time) + ") vs trends_num_yrs=(" + yrs(m) +")")
           print("Exiting Set_1.ncl")
           print("   ")
           print("   ")
           exit
        end if

        filevar = vars(i)

        if (isfilevar(in,filevar))then
           if (c13Flag(i) .eq. "C13_") then
              x = derive_del13C(vars(i),in,scale_type(i),yrs(m),1)
           else
              x = in->$filevar$
           end if
           plot_check = True
           delete(filevar)
        else
           info = var_init(vars(i))
           if (info@derivedVariable .eq. True) then
              x = derive_land(  vars(i),in)
              if (all(ismissing(x)))then
                 print("variable "+ vars(i)+ " contains only missing values")
                 plot_check = False
                 delete(x)
                 delete(time)
                 delete(landfrac)
                 delete(levsoi)
                 delete(area)
                 delete(nlev)
                 continue
              else
                 plot_check = True
              end if
           else
              print("variable "+ vars(i)+ " is not a defined variable.")
              delete(time)
              delete(levsoi)
              delete(landfrac)
              delete(area)
              delete(nlev)
              if (isvar("x")) then
                 delete(x)
              end if        
              plot_check = False
              continue
           end if
        end if

        rank1 = dimsizes(dimsizes(x))
        if (rank1 .eq. 4 ) then
           if (nlev .gt. 10) then
              print("Truncating soil levels to 10 levels [caseid: "+prefix(m)+"  "+vars(i)+" nlev:  " + nlev +"]")
              nlev = 10
           end if
        else
           rank1 = 3
        end if

        ; catch NaNs
        x = catchNaN(x)

        if (plot_check.eq.True)then
           info = var_init(vars(i))
           x    = scale_var(x,scale_type(i),info)

           if (isatt(in,"yrs_averaged")) then
              yrs_ave = in@yrs_averaged    ; extract years averaged for plotting
           end if

           cases(m) = cases(m) + " (" + yrs_ave + ")"

 ; calculate global summation or global total      
           if (c13Flag(i) .ne. "C13_") then
              var_plot = global_values(vars(i), x,area,landfrac,scale_type(i),yrs(m),nlev)
           else
              var_plot = x        ; del13C vars are globally averaged before the del value is calculated
           end if

           rank2 = dimsizes(dimsizes(var_plot))

           if (m .eq. 0) then
              fout = fout1
           else
              fout = fout2
           end if
           if (rank2.eq.1)then
;           printVarSummary(data)
              data(m,offset(m):(offset(m)+yrs(m)-1) ) = var_plot
              filevardef(fout,vars(i),typeof(var_plot),(/"time"/))
              if (i .eq. 0) then
                 filevardef(fout,"time",typeof(time),"time")
                 filevardef(fout,"levsoi",typeof(levsoi),"levsoi")
              end if
              fout->time = time
              fout->$vars(i)$ = var_plot
           else
              data3(m,offset(m):(offset(m)+yrs(m)-1),:) = var_plot
              filevardef(fout,vars(i),"float",(/"time","levsoi"/))
              fout->$vars(i)$ = var_plot
           end if
           long_name = x@long_name
           units     = x@units
           delete(var_plot)
        end if        ; plot_check loop
        delete(x)
        delete(time)
        delete(levsoi)
        delete(area)
        delete(landfrac)
     end do        ; case loop
;*************************************************
; create plot
;*************************************************
     if (plot_check.eq.True)then
        wks = gsn_open_wks(plot_type,wkdir + "set1_" + vars(i))

        res                        = True
        res@tiXAxisOn              = False
        res@gsnRightString         = ""    ;units
        if (vars(i) .eq. "C13_NEP" .or. vars(i) .eq. "C13_NEE") then         
           res@tiYAxisString      = vars(i) + "  ("+units+")  [ValidRange:-40-0]"                         
        else
           res@tiYAxisString      = vars(i)+"  ("+units+")"
        end if


        res@gsnFrame                  = False
        res@xyDashPatterns         = (/0.,16./)          ; solid, dashed
        res@xyLineThicknesses      = (/2.,2./)
        res@xyLineColors           = (/"red","blue"/)

        res@pmLegendDisplayMode    = "Never"
;        res@pmLegendSide           = "Bottom"            
;        res@pmLegendParallelPosF   = 0.50           
;        res@pmLegendOrthogonalPosF = 0.02              
;        res@pmLegendWidthF         = 0.35             
;        res@pmLegendHeightF        = 0.12 
;        res@lgLabelFontHeightF     = 0.025
;        res@lgPerimOn              = False
;        res@xyExplicitLegendLabels = cases

        res@tmXBMinorOn            = False
        res@tmYLFormat             = "0@!;*?5g"

        if (rank1.eq.3)then
           res@tiMainString           = long_name
           if (x2y2Plot .eq. 1) then
              ymin = 0.0
              ymax = 0.0
              if (all(ismissing(data(0,:)) .and. all(ismissing(data(1,:))))) then
                 ymin = 0.0
                 ymax = 0.0
              else
                 if (all(ismissing(data(1,:)))) then
                    ymin = min(data(0,:))
                    ymax = max(data(0,:))
                 else
                    if (all(ismissing(data(0,:)))) then
                       ymin = min(data(1,:))
                       ymax = max(data(1,:))
                    else
                       ymin = min( (/data(0,:),data(1,:)/) )
                       ymax = max( (/data(0,:),data(1,:)/) )
                    end if
                 end if
              end if

              minvalue = 0.001
              yrange = ymax-ymin
              if (ymin .eq. ymax .or. fabs(yrange) .lt. minvalue) then
                 pad = 0.01
                 ypad = ymin * pad
              else
                 pad = 0.05
                 ypad = yrange * pad
              end if
              ymin = ymin - ypad
              ymax = ymax + ypad

              res1    = True
              res1@gsnFrame                       = False
              res1@gsnLeftString                  = ""
              res1@gsnRightString                 = ""
              res1@tiMainString                   = long_name
              res1@tiXAxisOn                      = False
              res1@tiXAxisFontHeightF              = 0.020                  ; increase font height
              res1@trXMinF                        = t1(0)
              res1@trXMaxF                        = t1(nyrs-1)
              res1@trYMinF                        = ymin 
              res1@trYMaxF                        = ymax
              res1@tmXMajorGrid                   = True
              res1@tmXMajorGridThicknessF           = 0.5
              res1@tmXMajorGridLineDashPattern  = 2
              res1@tmYROn                         = False
              res1@tmYRLabelsOn                   = False
              res1@xyLineColor                    = "Red"
              res1@tmXBLabelFontColor            = res1@xyLineColor
              res1@xyDashPattern                    = 0
              res1@xyLineThicknessF                  = 1
              res1@tiYAxisString                     = vars(i)
              res1@pmLegendDisplayMode             = "Never"
;              res1@pmLegendSide                    = "Bottom"            
;              res1@pmLegendParallelPosF            = 0.50           
;              res1@pmLegendOrthogonalPosF          = 0.02              
;              res1@pmLegendWidthF                  = 0.25             
;              res1@pmLegendHeightF                 = 0.1 
;              res1@lgLabelFontHeightF              = 0.025
;              res1@lgPerimOn                       = False
              res1@xyExplicitLegendLabels          = cases
        
              res2    = True
              res2@gsnLeftString                  = ""
              res2@gsnRightString                 = ""
              res2@gsnFrame                        = False
              res2@trXMinF                        = t2(0)
              res2@trXMaxF                        = t2(nyrs-1)
              res2@trYMinF                        = ymin 
              res2@trYMaxF                        = ymax
              res2@tmYROn                         = False
              res2@tmYRLabelsOn                   = False
              res2@xyLineColor                    = "blue"
              res2@tmXTLabelFontColor             = "blue"
              res2@xyDashPattern                  = 2
;              res2@gsnRightString                = ""      ;units
              res2@gsnRightString                 = units

              res2@xyLineThicknessF                  = 2
              plot = gsn_csm_x2y2(wks,t1,t2,data(0,:),data(1,:),res1,res2)   
              delete(res1)
              delete(res2)
           else
              plot = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data,res)   
           end if
           lgres                    = True                   ; allow legend resources
           lgres@gsnFrame           = False
           lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
           lgres@vpHeightF          = 0.11  
           lgres@lgPerimOn          = False 
           lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
           lgres@lgLabelFontHeightF = 0.025                  ; increase font height
           lgres@lgLineLabelStrings = (/"",""/)              ; no labels in lines
           lgres@lgAutoManage       = False                  ; must have to adjust fonts
           nc = max((/dimsizes(stringtochar(cases(0)))-1,dimsizes(stringtochar(cases(1)))-1/))
           if (nc.lt.20) then
              lgres@vpWidthF        = 0.35
           end if
           if (nc.ge.20.and.nc.lt.40) then
              lgres@vpWidthF        = 0.5
           end if
           if (nc.ge.40.and.nc.lt.60) then
              lgres@vpWidthF        = 0.65
           end if
           if (nc.ge.60) then
              lgres@vpWidthF        = 0.8
           end if   
           
           gsn_legend_ndc(wks,2,"  "+cases,(1.0-lgres@vpWidthF)/2.,0.13,lgres)         ; draw common legend
 	   frame(wks)     ; add frame to support plot_type = png
        else
           plot = new(nlev,graphic)
           res@tiMainOn               = False
           res@gsnDraw                = False
           res@gsnFrame               = False
           res@tiXAxisFontHeightF     = 0.030
           res@tiYAxisFontHeightF     = 0.030
           res@txFontHeightF          = 0.030
           res@tmXBLabelFontHeightF   = 0.030
           res@tmYLLabelFontHeightF   = 0.030
           res@tmYLFormat             = "0@!;*?5g"

           res@pmLegendDisplayMode    = "NoCreate"   ;"Never"
           res@vpHeightF              = 0.4
           res@vpWidthF               = 0.8
           if (isfilevar(in, "levsoi")) then
              lev = in->levsoi
           end if
           if (isfilevar(in, "levgrnd")) then
              lev = in->levgrnd
           end if
           do k=0,nlev-1
              res@tiXAxisOn              = False
              res@gsnCenterString           = "Layer " + (k+1)
              if (x2y2Plot .eq. 1) then
                 ymin = 0.0
                 ymax = 0.0
                 if (all(ismissing(data3(0,:,k)) .and. all(ismissing(data3(1,:,k))))) then
                    ymin = 0.0
                    ymax = 0.0
                 else
                    if (all(ismissing(data3(1,:,k)))) then
                       ymin = min(data3(0,:,k))
                       ymax = max(data3(0,:,k))
                    else
                       if (all(ismissing(data3(0,:,k)))) then
                          ymin = min(data3(1,:,k))
                          ymax = max(data3(1,:,k))
                       else
                          ymin = min( (/data3(0,:,k),data3(1,:,k)/) )
                          ymax = max( (/data3(0,:,k),data3(1,:,k)/) )
                       end if
                    end if
                 end if

                 minvalue = 0.001
                 yrange = ymax-ymin
                 if (ymin .eq. ymax .or. fabs(yrange) .lt. minvalue)
                    pad = 0.01
                    ypad = ymin * pad
                 else
                    pad = 0.05
                    ypad = yrange * pad
                 end if
                 ymin = ymin - ypad
                 ymax = ymax + ypad
                 delete(yrange)

                 res1    = True
                 res1@gsnFrame               = False
                 res1@gsnDraw                = False

                 res1@pmLegendDisplayMode    = "NoCreate"
                 res1@vpHeightF              = 0.4
                 res1@vpWidthF               = 0.8
                 res1@tmYLFormat             = "0@!;*?5g"
                 if (k .lt. 8) then
                    res1@tiXAxisString = ""
                 else
                    res1@tiXAxisString = "time [model yrs]"
                 end if
                 res1@trXMinF                          = t1(0)
                 res1@trXMaxF                          = t1(nyrs-1)
                 res1@trYMinF                          = ymin 
                 res1@trYMaxF                        = ymax
                 res1@tmXMajorGrid                       = True
                 res1@tmXMajorGridThicknessF       = 0.5
                 res1@tmXMajorGridLineDashPattern  = 2
                 res1@tmYROn                         = False
                 res1@tmYRLabelsOn                   = False
                 res1@xyLineColor                    = "Red"
                 res1@xyLineThicknessF                  = 1
                 res1@tmXBLabelFontColor            = res1@xyLineColor
                 res1@xyDashPattern                    = 0
                 res1@tiYAxisString                    = units
         
                 res2                             = True
                 res2@gsnFrame                        = False
                 res2@tiXAxisString                  = "Layer " + (k+1)
                 res2@trXMinF                        = t2(0)
                 res2@trXMaxF                        = t2(nyrs-1)
                 res2@trYMinF                        = ymin
                 res2@trYMaxF                        = ymax
                 res2@tmYROn                         = False
                 res2@tmYRLabelsOn                   = False
                 res2@xyLineColor                    = "blue"
                 res2@tmXTLabelFontColor             = "blue"
                 res2@xyDashPattern                     = 2
                 res2@xyLineThicknessF                   = 2
                 plot(k) = gsn_csm_x2y2(wks,t1,t2,data3(0,:,k),data3(1,:,k),res1,res2)   
              else
                 plot(k) = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data3(:,:,k),res) 
              end if
           end do                ; level loop
           if (isvar("res1") ) then
              delete(res1)
           end if
           if (isvar("res2") ) then
              delete(res2)
           end if
           pres                     = True                   ; panel only resources
           pres@txString            = long_name            ; common title
           pres@gsnFrame            = False                  ; don't advance yet so add legend
           pres@gsnMaximize         = True                   ; make as large as possible
           pres@gsnPanelBottom      = 0.12                   ; save space for legend

           gsn_panel(wks,plot,(/(nlev/2),2/),pres)           ; draw panel plot

           lgres                    = True                   ; allow legend resources
           lgres@gsnFrame           = False                  ; don't advance yet so add legend
           lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
           lgres@vpHeightF    = 0.08
           lgres@lgPerimOn          = False         ; ditto
           lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
           lgres@lgLabelFontHeightF = 0.025                  ; increase font height
           lgres@lgLineLabelStrings = (/"",""/)              ; no labels in lines
           lgres@lgAutoManage       = False                  ; must have to adjust fonts
           nc = max((/dimsizes(stringtochar(cases(0)))-1,dimsizes(stringtochar(cases(1)))-1/))
           if (nc.lt.20) then
              lgres@vpWidthF        = 0.25
           end if
           if (nc.ge.20.and.nc.lt.40) then
              lgres@vpWidthF        = 0.4
           end if
           if (nc.ge.40.and.nc.lt.60) then
              lgres@vpWidthF        = 0.55
           end if
           if (nc.ge.60) then
              lgres@vpWidthF        = 0.7
           end if  
           gsn_legend_ndc(wks,2,cases,(1.0-lgres@vpWidthF)/2.,0.125,lgres)         ; draw common legend
           frame(wks)

        end if                ; 3D or 2D plot loop

        delete(plot)
        delete(res)
     end if                ; plotCheck loop
  end do                   ; variable loop
  
; remove error file if program completes successfully.
  filo  = wkdir +"/set1_error_file"
  system("/bin/rm -f " + filo)
end
