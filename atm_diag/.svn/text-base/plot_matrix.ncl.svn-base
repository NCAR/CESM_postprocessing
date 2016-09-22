;********************************************************
; NCL script
; plot_matrix.ncl
; Benjamin Hillman August 2011
;********************************************************
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  load "$DIAG_CODE/functions_contrib.ncl"
  load "$DIAG_CODE/functions_matrix.ncl"

  undef("histogram2D")
  function histogram2D(wks,data,res)
  local dimNames,yDim,xDim,yBnds,xBnds
  begin
    dimNames = getvardims(data)
    yDim = dimNames(0)
    xDim = dimNames(1)
    delete(dimNames)
    if (isatt(res,"tmYLLabels")) then
      if (any(typeof(res@tmYLLabels).eq.(/"float","double"/))) then
        yBnds = res@tmYLLabels
        delete(res@tmYLLabels)
        res@tmYLLabels = sprintf("%.1f",yBnds)
      else
        yBnds = stringtofloat(res@tmYLLabels)
      end if
      res@tmYLMode   = "Explicit"
      res@tmYLValues = ispan(0,dimsizes(res@tmYLLabels)-1,1)
      res@sfYArray   = res@tmYLValues
    end if
    if (isatt(res,"tmXBLabels")) then
      if (any(typeof(res@tmXBLabels).eq.(/"float","double"/))) then
        xBnds = res@tmXBLabels
        delete(res@tmXBLabels)
        res@tmXBLabels = sprintf("%.1f",xBnds)
      else
        xBnds = stringtofloat(res@tmXBLabels)
      end if
      res@tmXBMode   = "Explicit"
      res@tmXBValues = ispan(0,dimsizes(res@tmXBLabels)-1,1)
      res@sfXArray   = res@tmXBValues
    end if
    plot = gsn_csm_contour(wks,data,res)

;   compute sums of ISCCP standard cloud types?
    if (any((/isStrSubset(yDim,"prs"),isStrSubset(yDim,"cth")/))) then
      sums = new((/3,3/),float)
      tauBnds = (/(/0.3,3.6/),(/3.6,23.0/),(/23.0,379/)/)
      if (isStrSubset(yDim,"prs")) then
        cthBnds = (/(/680,1000/),(/440,680/),(/0,440/)/)
      else
        cthBnds = (/(/0.0,3.0/),(/3.0, 7.0/),(/ 7.0,23.0/)/)
      end if
      txtRes = True
      txtRes@txFontHeightF = 0.03
      do nx = 0,dimsizes(sums(0,:))-1
        do ny = 0,dimsizes(sums(:,0))-1
          tauMin = tauBnds(nx,0)
          tauMax = tauBnds(nx,1)
          cthMin = cthBnds(ny,0)
          cthMax = cthBnds(ny,1)

;         calculate sum of ISCCP cloud types
          sums(ny,nx) = sum(sum(data({cthMin:cthMax},{tauMin:tauMax})))
          txtStr = sprintf("%.1f",sums(ny,nx))

;         find y-coordinate to place text
          yind = ind( \
            data&$yDim$.ge.cthMin.and. \
            data&$yDim$.le.cthMax \
          )
          ypt = avg(yind)+0.5
          delete([/cthMin,cthMax,yind/])

;         find x-coordinate to place text
          xind = ind( \
            data&$xDim$.ge.tauMin.and. \
            data&$xDim$.le.tauMax \
          )
          xpt = avg(xind)+0.5
          delete([/tauMin,tauMax,xind/])

;         place value of sum on plot at xy coordinates found
          txt = gsn_add_text(wks,plot,txtStr,xpt,ypt,txtRes)
          delete([/txtStr,xpt,ypt/])
        end do
      end do
      delete([/sums,txtRes/])

;     draw vertical lines
      xpt = ind_nearest_coord(tauBnds(:,0),xBnds,0)
      do nx = 0,dimsizes(xpt)-1
        xpts = (/xpt(nx),xpt(nx)/)
        ypts = (/0,dimsizes(data(:,0))/)
        str = unique_string("polyline")
        plot@$str$ = gsn_add_polyline(wks,plot,xpts,ypts,False)
        delete([/xpts,ypts/])
      end do
      delete(xpt)

;     draw horizontal lines
      ypt = ind_nearest_coord(cthBnds(:,0),yBnds,0)
      do ny = 0,dimsizes(ypt)-1
        ypts = (/ypt(ny),ypt(ny)/)
        xpts = (/0,dimsizes(data(0,:))/)
        str = unique_string("polyline")
        plot@$str$ = gsn_add_polyline(wks,plot,xpts,ypts,False)
        delete([/xpts,ypts/])
      end do
      delete(ypt)

;     clean up
      delete([/tauBnds,cthBnds/])
    end if
    delete([/xDim,yDim,xBnds,yBnds/])
    return(plot)
  end

  cnLevelsFull = (/0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, \
                   5.0, 5.5, 6.0, 6.5, 7.0, 7.5 /)
                   
; cnLevelsFull = (/ \
;       0.1, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5,  \
;       4.0, 4.5, 5.0, 6.0, 7.0, 8.0, 9.0,10.0   \
; /)
  cnLevelsDiff = (/ \
    -3.5,-3.0,-2.5,-2.0,-1.5,-1.0,-0.5, 0.0, \
     0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5       \
  /)
  regionInfo = (/ \
;   (/"long_name"          , "lats", "latn", "lonw", "lone"/), \
    (/"Global"             ,"-90.0", "90.0",  "0.0","360.0"/), \
    (/"NH Sub-Tropics"     , "15.0", "30.0",  "0.0","360.0"/), \
    (/"SH Sub-Tropics"     ,"-30.0","-15.0",  "0.0","360.0"/), \
    (/"Tropics"            ,"-15.0", "15.0",  "0.0","360.0"/), \
    (/"NH Mid-Lats"        , "30.0", "70.0",  "0.0","360.0"/), \
    (/"SH Mid-Lats"        ,"-70.0","-30.0",  "0.0","360.0"/), \
    (/"North Pole"         ," 70.0", "90.0",  "0.0","360.0"/), \
    (/"South Pole"         ,"-90.0","-70.0",  "0.0","360.0"/), \
    (/"Warm Pool"          ,"-15.0", "15.0","110.0","150.0"/), \
    (/"Central Africa"     ,"-15.0",  "5.0", "15.0", "35.0"/), \
    (/"NH Pacific Stratus" , "15.0", "35.0","210.0","240.0"/), \
    (/"SH Pacific Stratus" ,"-30.0", "-5.0","250.0","280.0"/), \
    (/"North Pacific"      , "40.0", "55.0","165.0","205.0"/), \
    (/"North Atlantic"     , "40.0", "55.0","310.0","345.0"/), \
    (/"USA"                , "31.0", "46.0","248.0","278.0"/), \
    (/"VOCALS"             ,"-40.0",  "0.0","250.0","295.0"/), \
    (/"Southern Ocean"     ,"-90.0","-50.0",  "0.0","360.0"/), \
    (/"Tropical C Pacific" ,"-15.0", "15.0","150.0","240.0"/), \
    (/"Tropical E Pacific" ,"-15.0", "15.0","240.0","280.0"/), \
    (/"ARM SGP"            , "37.0", "37.0","263.0","263.0"/)  \
  /)
  begin
;   environment variables
    compare    = getenv("COMPARE")
    plotType   = getenv("PLOTTYPE")
    color_type = getenv("COLORTYPE")
    season     = getenv("SEASON")
    version    = getenv("DIAG_VERSION")
    wkdir      = getenv("WKDIR")
    timestamp  = getenv("TIMESTAMP")
    casenames  = getenv("CASENAMES")
    ncdf_mode  = getenv("NCDF_MODE")
    infile1    = getenv("TEST_INPUT")
    outfile1   = getenv("TEST_PLOTVARS")
    infile2    = getenv("CNTL_INPUT")
    if (compare .ne. "OBS") then
     outfile2  = getenv("CNTL_PLOTVARS")
    end if
    RGB        = getenv("DIAG_HOME")+"/rgb"
    cmap       = RGBtoCmap(RGB+"/cloudsim.rgb")

;   CASE 1 (always model)
    inptr1 = addfile(infile1,"r")
    if (ncdf_mode .eq. "write") then
      outptr1 = addfile(outfile1,"w")
    else
      outptr1 = addfile(outfile1,"c")
    end if
    if (casenames .eq. "True") then
      case1 = getenv("CASE1")
    else
      case1 = inptr1@case
    end if
    if (isatt(inptr1,"yrs_averaged")) then
      yrs_ave1 = inptr1@yrs_averaged
      case1title = case1+" (yrs "+yrs_ave1+")"
    else
      case1title = case1
    end if

;   CASE 2: model or obs
    if (compare .ne. "OBS") then
      inptr2 = addfile(infile2,"r")
      if (inptr2@source .eq. "GFDL") then
        print("ISCCP cloud simulator not supported for GFDL model")
        exit
      end if
      if (ncdf_mode .eq. "write") then
        outptr2 = addfile(outfile2,"w")
      else
        outptr2 = addfile(outfile2,"c")
      end if
      if (casenames .eq. "True") then
        case2 = getenv("CASE2")
      else
        case2 = inptr2@case
      end if
      if (isatt(inptr2,"yrs_averaged")) then
        yrs_ave2 = inptr2@yrs_averaged
        case2title = case2+" (yrs "+yrs_ave2+")"
      else
        case2title = case2
      end if
    else
      inptr2 = new(1,file)
      outptr2 = new(1,file)
      case2title = ""
    end if

;   variables to plot
    varInfo = (/ \
      (/"CLISCCP","ISCCPCOSP"   ,"ISCCP-COSP (1983-2008)"             /), \
      (/"CLMISR" ,"MISRCOSP"    ,"MISR L3 CTH-OD V5 (2000-2009)"      /), \
      (/"CLMODIS","MODISCOSP"   ,"MODIS-COSP (2003-2010)"             /), \
      (/"CFAD_DBZE94_CS","CLOUDSATCOSP","CLOUDSAT-COSP (2006-2010)"/)  \
    /)
    passiveVars = (/"CLISCCP","CLMISR","CLMODIS"/)

;   break out variable info
    if (dimsizes(dimsizes(varInfo)).eq.2) then
      varNames  = varInfo(:,0)
      obsFiles  = varInfo(:,1)
      obsNames  = varInfo(:,2)
    else
      varNames  = varInfo(0)
      obsFiles  = varInfo(1)
      obsNames  = varInfo(2)
    end if

;   break out region info
    regionNames = regionInfo(:,0)
    latMinVals  = stringtofloat(regionInfo(:,1))
    latMaxVals  = stringtofloat(regionInfo(:,2))
    lonMinVals  = stringtofloat(regionInfo(:,3))
    lonMaxVals  = stringtofloat(regionInfo(:,4))

;   dimension sizes
    nVars     = dimsizes(varNames)
    nRegions  = dimsizes(regionNames)

;   common resources for XY plots
    resXY                        = True
    resXY@gsnDraw                = False               ; Do not draw plot
    resXY@gsnFrame               = False               ; Do not advance frame
    resXY@tiXAxisFontHeightF     = 0.020
    resXY@tiYAxisFontHeightF     = 0.020
    resXY@tiMainFontHeightF      = 0.025
    resXY@pmLegendDisplayMode = "Always"
    resXY@pmLegendWidthF         = 0.12               ; Change width and
    resXY@pmLegendHeightF        = 0.10               ; height of legend.
    resXY@lgPerimOn              = True
    resXY@lgLabelFontHeightF     = .020
    resXY@txFontHeightF = 0.015
    resXY@xyDashPatterns         = (/0.,1./)          ; solid, dashed
    resXY@xyLineThicknesses      = (/2.,2./)
    if (color_type .eq. "COLOR") then
      resXY@xyLineColors         = (/"red","blue"/)
      resXY@xyLineColor = "black"
    end if

;   common resources for 2D histograms
    resHist = True
    resHist@gsnDraw = False
    resHist@gsnFrame = False
    resHist@gsnSpreadColors       = True
    resHist@cnLinesOn             = False
    resHist@cnLineLabelsOn        = False
    resHist@cnInfoLabelOn         = False
    resHist@cnFillOn              = True
    resHist@cnFillMode            = "RasterFill"
    resHist@cnLevelSelectionMode  = "ExplicitLevels"
    resHist@lbLabelBarOn          = True
    resHist@lbLabelAutoStride     = True
    resHist@tmLabelAutoStride     = True

    do nv = 0,nVars-1

     print("DEBUG set13 - nv = "+nv+": "+varNames(nv))

;     open files
      if (compare.eq."OBS") then
        inptr2 = addfile(infile2+"/"+obsFiles(nv)+"_"+season+"_climo.nc","r")
        case2 = obsNames(nv)
      end if

;     read variables from files
      if (varNames(nv).eq."CLISCCP") then
        tmp = get_CLISCCP(inptr1,outptr1)
        yBnds = (/1100., 800., 680., 560., 440., 310., 180., 0./)
        xBnds = (/0.3,1.3,3.6,9.4,23.0,60.0,379/)
        A = tmp(:,{0.3:},:,:)
        delete(tmp)
      end if
      if (varNames(nv).eq."CLMODIS") then
        tmp = get_CLMODIS(inptr1,outptr1)
        yBnds = (/1100., 800., 680., 560., 440., 310., 180., 0./)
        xBnds = (/0.3,1.3,3.6,9.4,23.0,60.0,379/)
        A = tmp(:,{0.3:},:,:)
        delete(tmp)
      end if
      if (varNames(nv).eq."CLMISR") then
        tmp = get_CLMISR(inptr1,outptr1)
        xBnds = (/0.3,1.3,3.6,9.4,23.0,60.0,379/)
        yBnds = (/ \
           0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, \
           5.0, 7.0, 9.0,11.0,13.0,15.0,17.0,23.0  \
        /)
        A = tmp({0.0:},{0.3:},:,:)
        delete(tmp)
      end if
      if (varNames(nv).eq."CFAD_DBZE94_CS") then
        A = get_CFAD_DBZE94_CS(inptr1,outptr1)
        xBnds = fspan(-50.0,25.0,16)
        yBnds = fspan(0.0,19.2,41)
      end if

      if (compare.eq."OBS") then
        tmp = inptr2->$varNames(nv)$(0,:,:,:,:)
        if (varNames(nv).eq."CLISCCP") then
          B = tmp(:,{0.3:},:,:)
        end if
        if (varNames(nv).eq."CLMODIS") then
          B = tmp(:,{0.3:},:,:)
        end if
        if (varNames(nv).eq."CLMISR") then
          B = tmp({0.0:},{0.3:},:,:)
        end if
        if (varNames(nv).eq."CFAD_DBZE94_CS") then
          B = tmp
        end if
        delete(tmp)
      else
        if (varNames(nv).eq."CLISCCP") then
          tmp = get_CLISCCP(inptr2,outptr2)
          B = tmp(:,{0.3:},:,:)
          delete(tmp)
        end if
        if (varNames(nv).eq."CLMODIS") then
          tmp = get_CLMODIS(inptr2,outptr2)
          B = tmp(:,{0.3:},:,:)
          delete(tmp)
        end if
        if (varNames(nv).eq."CLMISR") then
          tmp = get_CLMISR(inptr2,outptr2)
          B = tmp({0.0:},{0.3:},:,:)
          delete(tmp)
        end if
        if (varNames(nv).eq."CFAD_DBZE94_CS") then
          B = get_CFAD_DBZE94_CS(inptr2,outptr2)
        end if
      end if

      if (all(A.eq.-999.0).or.all(B.eq.-999.0)) then
        print("Variable "+varNames(nv)+" not found.")
        continue
      end if

;     read weights from files
      gw1 = inptr1->gw
      gw2 = inptr2->gw

;     dimension names
      dimNames = getvardims(A)
      yDim = dimNames(0)
      xDim = dimNames(1)
      delete(dimNames)

;     loop over regions
      do nr = 0,nRegions-1
        print("DEBUG set13 -  nr = "+nr+": "+regionNames(nr))

        latMin = latMinVals(nr)
        latMax = latMaxVals(nr)
        lonMin = lonMinVals(nr)
        lonMax = lonMaxVals(nr)

;       calculate regional means
        A2D = wgt_areaave_Wrap( \
          A(:,:,{latMin:latMax},{lonMin:lonMax}), \
          gw1({latMin:latMax}),1.0,0 \
        )
        B2D = wgt_areaave_Wrap( \
          B(:,:,{latMin:latMax},{lonMin:lonMax}), \
          gw2({latMin:latMax}),1.0,0 \
        )

        if (all(ismissing(A2D)).or.all(ismissing(B2D))) then
          print("No valid data for variable "+varNames(nv)+" in region "+regionNames(nr))
          delete([/A2D,B2D/])
          continue
        end if

;       calculate difference
        C2D = A2D
        C2D = A2D - B2D

;       make plots
        plotName  = wkdir+"/set13_"+season+"_"+varNames(nv)+"2D_"+str_sub_str(regionNames(nr)," ","")
        wks = gsn_open_wks(plotType,plotName)
        gsn_define_colormap(wks,cmap)

        res2D = resHist
        res2D@tmYLLabels = yBnds
        res2D@tmXBLabels = xBnds

        res2D@gsnLeftString = ""
        res2D@gsnCenterString = case1
        res2D@gsnRightString = ""
        res2D@cnLevels = cnLevelsFull
        res2D@lbLabelStrings = sprintf("%.1f",res2D@cnLevels)
         
        plot1 = histogram2D(wks,A2D,res2D)

        res2D@gsnCenterString = case2
        plot2 = histogram2D(wks,B2D,res2D)

        delete(res2D@cnLevels)
        delete(res2D@lbLabelStrings)
        res2D@cnLevels = cnLevelsDiff
        res2D@lbLabelStrings = sprintf("%.1f",res2D@cnLevels)
        res2D@gsnCenterString = case1+" - "+case2
        plot3 = histogram2D(wks,C2D,res2D)
        delete(res2D)

        resPanel = True
        resPanel@txString = regionNames(nr)+" "+season
        gsn_panel(wks,(/plot1,plot2,plot3/),(/2,2/),resPanel)
        delete([/wks,resPanel/])

;       1D histograms
        if (any(varNames(nv).eq.passiveVars)) then
          plotName  = wkdir+"/set13_"+season+"_"+varNames(nv)+"1D_"+str_sub_str(regionNames(nr)," ","")
          wks = gsn_open_wks(plotType,plotName)

;         calculate distributions along each axis
          AX = dim_sum_Wrap(A2D($xDim$|:,$yDim$|:))
          BX = dim_sum_Wrap(B2D($xDim$|:,$yDim$|:))

          AY = dim_sum_Wrap(A2D($yDim$|:,{$xDim$|0.3:}))
          BY = dim_sum_Wrap(B2D($yDim$|:,{$xDim$|0.3:}))

;         copy data to 2D matrix to plot at the same time
          plotDataX = new((/2,dimsizes(AX)/),float)
          plotDataY = new((/2,dimsizes(AY)/),float)
          plotDataX(0,:) = (/AX(:)/)
          plotDataX(1,:) = (/BX(:)/)
          plotDataY(0,:) = (/AY(:)/)
          plotDataY(1,:) = (/BY(:)/)

;         plot X histogram
          resX = resXY
          resX@xyExplicitLegendLabels = (/case1,case2/)
          resX@tmXBMode = "Explicit"
          resX@tmXBLabels = sprintf("%.1f",xBnds)
          resX@tmXBValues = ispan(0,dimsizes(resX@tmXBLabels)-1,1)-0.5
          resX@tiYAxisString = "Cloud Amount ("+A@units+")"
          resX@tiXAxisString = A&$xDim$@long_name
          plotX = gsn_csm_xy(wks,ispan(0,dimsizes(AX)-1,1),plotDataX,resX)
          delete([/plotDataX,resX/])

;         plot Y histogram
          resY = resXY
          resY@xyExplicitLegendLabels = (/case1,case2/)
          resY@tmYLMode = "Explicit"
          resY@tmYLLabels = sprintf("%.1f",yBnds)
          resY@tmYLValues = ispan(0,dimsizes(resY@tmYLLabels)-1,1)-0.5
          resY@tiXAxisString = "Cloud Amount ("+A@units+")"
          resY@tiYAxisString = A&$yDim$@long_name+" ("+A&$yDim$@units+")"
          delete(resY@pmLegendDisplayMode)
          plotY = gsn_csm_xy(wks,plotDataY,ispan(0,dimsizes(AY)-1,1),resY)
          delete([/plotDataY,resY/])

          resPanel = True
          resPanel@txString = regionNames(nr)+" "+season
          gsn_panel(wks,(/plotX,plotY/),(/1,2/),resPanel)
          delete([/plotX,plotY,BX,AX,BY,AY/])
        end if
        delete([/B2D,A2D,C2D/])
      end do
      delete([/A,B,gw1,gw2,xBnds,yBnds,xDim,yDim/])
    end do
  end
