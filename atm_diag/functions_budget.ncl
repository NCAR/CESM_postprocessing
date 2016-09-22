; NCL script
; functions_vertical.ncl
; Mark Stevens, Sept 2001
;************************************************************************
p0     = 1000.     ; mb required by vinth2p
interp = 2         ; log interpolation
extrap = False     ; no extrapolation past psfc.

; for comparison with another model interpolate the model data to these
; 25 constant pressure levels
plvlM = (/30.,50.,70.,100.,150.,200.,250.,300.,350.,400.,450.,500.,550., \
          600.,650.,700.,750.,800.,850.,875.,900.,925.,950.,975.,1000./)
plvlM@units = "mb"
nplvlM = 25

; TOM to bottom is the order of the model data
;-----------------------------------------------------------------------

function vertical_Q_budget_term(inptr:file, varName:string)

begin
   if (isfilevar(inptr, varName)) then
    tmp = inptr->$varName$(0,:,:,:)
    tmp = tmp*86400*1000
    hyam = inptr->hyam
    hybm = inptr->hybm
    ps = inptr->PS(0,:,:) 
    var = vinth2p(tmp,hyam,hybm,plvlM,ps,interp,p0,1,extrap)
   else
    var = -999.
   end if
    return(var)
end
