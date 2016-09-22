procedure footer_text(wks : graphic, plot:  graphic, text1 : string, text2 : string, txres : logical)

begin

  if(.not.isatt(txres,"txFontHeightF")) then
    getvalues plot
    "tiXAxisFontHeightF" : font_height
    end getvalues

    txres@txFontHeightF = font_height
  end if

  if (isatt(txres,"colors")) then
    txres@txFontColor = txres@colors(0)
  end if

  tx1 = gsn_create_text(wks, text1, txres)

  if (isatt(txres,"colors")) then
    txres@txFontColor = txres@colors(1)
  end if

  tx2 = gsn_create_text(wks, text2, txres)

  amres = True

  amres@amSide = "bottom"
  amres@amOrthogonalPosF = 0.06
  amres@amParallelPosF = 0.5
  amres@amJust = "topcenter"
  amres@amZone = 5
  am1 = gsn_add_annotation(plot,tx1,amres)
  amres@amZone = 6
  amres@amOrthogonalPosF = 0.03
  am2 = gsn_add_annotation(plot,tx2,amres)

end
