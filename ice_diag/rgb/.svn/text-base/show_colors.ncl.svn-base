;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
;************************************************
begin
; replace amwg.rgb with your own rgb file
 wks = gsn_open_wks("x11","colors")            
 cmap = RGBtoCmap("julies.rgb")
 gsn_define_colormap(wks,cmap)       
 gsn_merge_colormaps(wks,cmap, "BlWhRe")       
 gsn_draw_colormap(wks)             
end
