undef("set1Plot")
procedure set1Plot(variable,long_name,units,cases,data,data3,res,nyrs,fyr,in)
begin
    wks = gsn_open_wks("ps",wkdir + "set1_" + variable)

    res                        = True
    res@tiXAxisString          = "Simulation Year"
    res@gsnRightString         = units
    res@tiYAxisString          = variable

    res@xyDashPatterns         = (/0.,16./)          ; solid, dashed
    res@xyLineThicknesses      = (/2.,2./)
    res@xyLineColors           = (/"red","blue"/)

    res@pmLegendDisplayMode    = "Always"
    res@pmLegendSide           = "Bottom"
    res@pmLegendParallelPosF   = 0.50
    res@pmLegendOrthogonalPosF = 0.02
    res@pmLegendWidthF         = 0.15
    res@pmLegendHeightF        = 0.08
    res@lgLabelFontHeightF     = 0.020
    res@lgPerimOn              = True
    res@xyExplicitLegendLabels = cases

    res@tmXBMinorOn            = False

    if(rank.eq.1)then
    res@tiMainString           = long_name
    plot = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data,res)
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
      res@pmLegendDisplayMode    = "Never"
      res@vpHeightF              = 0.4
      res@vpWidthF               = 0.8
      lev = in->levsoi
      do k=0,nlev-1
        if(k.eq.nlev-1 .or. k.eq.nlev-2)then
          res@tiXAxisString          = "Simulation Year"
        else
          res@tiXAxisString          = ""
        end if
        res@gsnCenterString           = "level " + lev(k)
        plot(k) = gsn_csm_xy(wks,ispan(fyr,fyr+(nyrs-1),1),data3(:,:,k),\
        res)
      end do
      pres                     = True                   ; panel only resources
      pres@txString            = x@long_name            ; common title
      pres@gsnFrame            = False                  ; don't advance yet so add legend
      pres@gsnMaximize         = True                   ; make as large as possible
      pres@gsnPanelBottom      = 0.12                   ; save space for legend

      gsn_panel(wks,plot,(/(nlev/2),2/),pres)           ; draw panel plot

      lgres                    = True                   ; allow legend resources
      lgres@lgLineColors       = res@xyLineColors       ; set these equal to those
      lgres@vpWidthF           = res@pmLegendWidthF     ; above for consistency
      lgres@vpHeightF          = res@pmLegendHeightF    ; ditto
      lgres@lgPerimOn          = res@lgPerimOn          ; ditto
      lgres@lgDashIndexes      = res@xyDashPatterns     ; ditto
      lgres@lgLabelFontHeightF = 0.010                  ; increase font height
      lgres@lgLineLabelStrings = (/"",""/)              ; no labels in lines
      lgres@lgAutoManage       = False                  ; must have to adjust fonts
      gsn_legend_ndc(wks,2,cases,0.4,0.1,lgres)         ; draw common legend
      frame(wks)
    endif



end
