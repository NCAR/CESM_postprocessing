; file: functions_contrib.ncl
; some more contributed functions
;******************************************************************
; Mark Stevens
; normalized cosine weights

undef("NormCosWgt")
function NormCosWgt (lat:numeric)
begin
 deg_to_rad = acos(-1.0)/180.0
 wgt = lat 
 wgt = cos(lat*deg_to_rad)
 tsum = sum(wgt)
 nwgt = 2.*wgt/tsum    ; normalized so that the sum 
 return(nwgt)          ; is 2.0, just as the gw are 
end
;******************************************************************
; Mark Stevens
; Determine if model type is GFDL or not.

undef("ModelType")
function ModelType (fptr:file)

begin
if (isfilevar(fptr,"zfull")) then
  return (True)
else
  return (False)
end if
end

;*********************************************************************
; Mark Stevens
; Read RGB file format of n rows by 3 columns (R,G,B)
; values are integers from 0 to 255
; first triplet is the background
; second triplet is the foreground
; normalize RGB values (=RGB/255) for cmap format

undef("RGBtoCmap")
function RGBtoCmap (fName:string)


begin
   rgb  = asciiread (fName, -1, "integer") 
   size = dimsizes(rgb)
   n    = size/3                    ; number of rows 
   norm = rgb/255.0                 ; divide all elements     
   cmap = onedtond (norm, (/n,3/))  ; back to triplets
   return (cmap)
end

; *****************************************************************
; D. Shea
; Generate gaussian weights and meta data 
; gwt = latGauWgt (64, "lat", "gaussian weights", "dimension_less ")

undef ("latGauWgt")
function latGauWgt(nlat:integer,dimName:string,longName:string,units:string)
begin
  gau_info      = doubletofloat(gaus(nlat/2))         
  gwt           = gau_info(:,1)       ; gaussian wgt values
  gwt!0         = dimName             ; name the dimension
  gwt@long_name = longName            
  if (units.ne."")then
      gwt@units     = units
  end if
  gwt&$dimName$ = gau_info(:,0)       ; lat to named dimension
  return (gwt)
end

;************************************************************
; D. Shea
; Copy all of the coordinate variables from one variable to another.  
; Both variables must be the same size, and have the exact same 
; coordinate variables.

undef("copy_VarCoords")
procedure copy_VarCoords(var_from,var_to)  
local rfrom, rto, i
begin                                     
  rfrom = dimsizes(dimsizes(var_from))
  rto   = dimsizes(dimsizes(var_to))

  if((rto.eq.rfrom).and.(all(dimsizes(var_from).eq.dimsizes(var_to))))
      do i = 0,rfrom-1
         if (.not.ismissing(var_from!i)) then
            var_to!i = var_from!i
            if(iscoord(var_from,var_from!i))
	       var_to&$var_to!i$ = var_from&$var_from!i$
            end if
         end if
      end  do
  else
      print("ERROR: copy_VarCoords: number of dimensions do not match")
  end if
end

;************************************************************
; D. Shea
; Copy the coordinate variables from one variable to another,
; except for last dimension.  

undef ("copy_VarCoords_1")
procedure copy_VarCoords_1(var_from,var_to)  
local dimt, dimf, rfrom, rto, i
begin                      
        dimf  = dimsizes(var_from)            
        dimt  = dimsizes(var_to)
        rfrom = dimsizes(dimf)      ; rank of var_from
        rto   = dimsizes(dimt)      ; rank of var_to
        if (rto.eq.(rfrom-1)) then
                do i = 0,rfrom-2            ; do not use last dimension
                   if (.not.ismissing(var_from!i).and.dimf(i).eq.dimt(i))then
                        var_to!i = var_from!i
			if(iscoord(var_from,var_from!i))
				var_to&$var_to!i$ = var_from&$var_from!i$
			end if
                   end if
                end  do
        else
                print("ERROR: copy_VarCoords_1: rank problem")
        end if
end
;****************************************
; D. Shea
; Copies all of a variables attributes (e.g. long_name) from
; one variable to another

undef("copy_VarAtts")
procedure copy_VarAtts(var_from,var_to)    
local att_names, i
begin                                       
  att_names =getvaratts(var_from);
    if(.not.all(ismissing(att_names)))
      do i = 0,dimsizes(att_names)-1
	 var_to@$att_names(i)$ = var_from@$att_names(i)$
      end do
  end if
end

; *******************************************************************
; D. Shea
; Compute a dimension average of "x" [x may have many dimensions]
; return with one less dimension
; Copies over all the attribures and coordinate variables
; x    - multidimensional variable 

undef ("dim_avg_Wrap")
function dim_avg_Wrap (x:numeric)     
local xave, att_names, i, dimx, Ndx, Ndx1
begin

 xave = dim_avg(x)          ; arithmetic ave [no meta data]
 
 copy_VarAtts (x, xave)     ; copy attributes
                            ; copy dim  names and coord  variables
 dimx = dimsizes(x)         ; size of each dimension
 Ndx  = dimsizes(dimx)      ; number of dimensions
 copy_VarCoords_1 (x, xave) ; one less dimension 
                                       ; add an extra attribute
 Ndx1 = Ndx-1                          ; last dimension
 if (.not.ismissing(x!Ndx1)) then   
      xave@average_op= "dim_avg over dimension: "+x!Ndx1
 else
      xave@average_op= "dim_avg function was applied"
 end if
 
 return (xave)
end

;******************************************************************
; Variation by M Stevens of D Shea's short2flt
; converts shorts to floats using the "scale_factor" and "add_offset"
; attributes (if present) 

undef("short2float")
function short2float (xS:short)
local xF
begin
 if (isatt(xS,"missing_value") .and. .not.isatt(xS,"_FillValue")) then
   xS@_FillValue = xS@missing_value
 end if

 xF = new ( dimsizes(xS), float)
 
 if (isatt(xS,"add_offset") .and. isatt(xS,"scale_factor") ) then
     xF = xS*xS@scale_factor + xS@add_offset
 end if
 
 if (isatt(xS,"add_offset") .and. .not.isatt(xS,"scale_factor") ) then
     xF = xS + xS@add_offset
 end if
 
 if (.not.isatt(xS,"add_offset") .and. isatt(xS,"scale_factor") ) then
     xF = xS@scale_factor*xS
 end if
 
 if (.not.isatt(xS,"add_offset") .and. .not.isatt(xS,"scale_factor") ) then
     xF = xS
 end if

 copy_VarAtts   (xS, xF)
 copy_VarCoords (xS, xF)

 return (xF)

end

; *************************************************************
; D. Shea
; Wrapper for NCL function: doubletofloat
; This does the conversion and copies all the attributes
; and coordinate variables [CV] and attributes of the CV.
; This is more complicated than usual beacuse I want
; to convert any double attributes and CVs to float.

undef("dble2flt")
function dble2flt (xD:double)
local dimx, ndimx, xF, xD_atts, i, j, cv, cvD, cvF, cvD_atts
begin
 dimx = dimsizes(xD)

 if (isatt(xD,"_FillValue")) then
   xF = new (dimx, float, doubletofloat(xD@_FillValue ) )
 else
   if (isatt(xD,"missing_value")) then
      xF = new (dimx(xD), float, doubletofloat(xD@missing_value) )
   end if
 end if

 xF = doubletofloat (xD)       ; convert values

 xD_atts = getvaratts(xD)      ; copy attributes of input variable
 if (.not.all(ismissing(xD_atts))) then
    do i=0,dimsizes(xD_atts)-1
       if (xD_atts(i).ne."_FillValue") then                   ; done above
           if(typeof(xD@$xD_atts(i)$) .ne. "double" ) then
              xF@$xD_atts(i)$ = xD@$xD_atts(i)$
           else
              xF@$xD_atts(i)$ = doubletofloat(xD@$xD_atts(i)$)
           end if
       end if
    end do
 end if
 delete (xD_atts)
                                  ; add info on operation performed
 xF@typeConversion_op = "NCL: double converted to float"

 ndimx = dimsizes(dimx)           ; number of dimensions
 do i=0,ndimx-1                   ; loop over all dimensions
    if (.not.ismissing(xD!i)) then
        xF!i = xD!i               ; copy dimension name
        if(iscoord(xD,xD!i)) then ; copy coordinate variable [if present]
           cvD = xD&$xD!i$        ; coordinate variable [for convenience]
           if (typeof(cvD).ne."double") then
               xF&$xF!i$ = cvD    ; straight copy
           else
               cvF       = doubletofloat(cvD) ; no attributes copied
               cvD_atts  = getvaratts(cvD)    ; coord var atts
               if (.not.all(ismissing(cvD_atts))) then
                   do j=0,dimsizes(cvD_atts)-1
                      if (typeof(cvD@$cvD_atts(j)$) .ne. "double" ) then
                          cvF@$cvD_atts(j)$  = cvD@$cvD_atts(j)$
                      else                    ; must be double
                          cvF@$cvD_atts(j)$ = doubletofloat( cvD@$cvD_atts(j)$)
                      end if
                   end do
               end if
               xF&$xF!i$ = cvF          ; assign float coord variable
               delete (cvF)
               delete (cvD_atts)
           end if                   
           delete (cvD)
        end if                     
    end if                        
 end do                          

 return (xF)
 
end
;********************************************************************
; D. Shea
; set a _FillValue "automatically" 
; If a variable has a "_FillValue" use it, if not "missing_value" etc.
; if none on file, then set default by variable type 
; example of inline use: var = new(dimsizes(x),typeof(x),getFillValue(x))

undef("getFillValue")
function getFillValue (x)
begin
  if (isatt(x,"_FillValue")) then
      FillValue = x@_FillValue
  else
      if (isatt(x,"missing_value")) then
           FillValue = x@missing_value
      else
           if (typeof(x).eq."float") then
               FillValue = -999.
           end if
           if (typeof(x).eq."double") then
               FillValue = -9999.
           end if
           if (typeof(x).eq."integer") then
               FillValue = -99
           end if
           if (typeof(x).eq."logical") then
               FillValue = -1
           end if
           if (typeof(x).eq."byte") then
               FillValue = 0377
           end if
           if (typeof(x).eq."short") then
               FillValue = -99
           end if
           if (typeof(x).eq."graphic") then
               FillValue = -9999
           end if
           if (typeof(x).eq."file") then
               FillValue = -9999
           end if
           if (typeof(x).eq."list") then
               FillValue = -9999
           end if
           if (typeof(x).eq."character") then
               FillValue = "\0"
           end if
           if (typeof(x).eq."string") then
               FillValue = "missing"
           end if
      end if
  end if

   return (FillValue)
end
;*****************************************************************
; S. Murphy
; goes and determines the appropriate value for the missing value from
; getFillValue, and then assigns the _FillValue and the missing_value
; to this number. This is useful when creating derivations and outputting
; data to netcdf, or dealing with netcdf data that has no attributes.

undef("assignFillValue")
procedure assignFillValue(var_from:numeric,var_to:numeric)
begin

  value = getFillValue(var_from)

  var_to@_FillValue    = value
  var_to@missing_value = value

end

;************************************************************
procedure infoTimeStamp (wks:graphic, chSize:float, FileInfo:string)

; Place text on plot to indicate the data source and time created
; This procedure must be invoked prior to any advance
; frame call.
; examples:
;          (0) wks =  gsn_open_wks("ncgm","bogus") 
;          (1) infoTimeStamp (wks, 0.01, "Bogus File")
;              [plot]
;
;          (2) mssPath = "/SHEA/ECMWF/"
;              mssName = "sample"
;              size    = 0.015
;              infoTimeStamp (wks, size, mssPath+mssName )
;              [plot]

local yBot, xLeft, xRight, txres, TimeStamp
begin
   yBot                = 0.001
   xLeft               = 0.001
   xRight              = 0.999
                                        ; Sylvia Murphy mods
   if (NhlClassName(wks).eq."psWorkstationClass") then
      getvalues wks
         "wkDeviceLowerX"   : ps_xLeft
         "wkDeviceLowerY"   : ps_yLeft
	 "wkDeviceUpperX"   : ps_xRight
      end getvalues
      
      if(ps_xLeft .lt. 0)then           ; 36 is default, 0 is the beginning
         xoff_set = fabs(ps_xLeft/612.) ; 612 is 8.5 * 72 in-1
         xLeft = 0.02941 + xoff_set     ; .02941 is 1/4 of an inch
      else                              ; which is the margin required
	 xLeft = 0.02941                ; when printing postscript 
      end if

      if(ps_xRight .gt. 612)then              ; 576 is default,612 is end
         xoff_set = fabs(1 - (ps_xRight/612.)); 612 is 8.5 * 72 in-1
         xRight= 0.97059 - xoff_set
      else
	 xRight = 0.97059
      end if

      if(ps_yLeft .lt. 0)then         ; 126 is default, 0 is the beginning
         yoff_set = fabs(ps_yLeft/792.) ; 792 is 11  * 72 in-1
         yBot  = 0.02941  + yoff_set
      else
         yBot  = 0.02941
      end if
   end if

   txres               = True         ; additional info
   txres@txFontHeightF = chSize       ; size of meta data
   txres@txJust        = "BottomRight"
   gsn_text_ndc  (wks, FileInfo  , xRight , yBot , txres)

   TimeStamp           = systemfunc( "date" )
   txres@txJust        = "BottomLeft"
   gsn_text_ndc  (wks,"Created: "+TimeStamp , xLeft, yBot, txres)
end

;*********************************************************************
function FixZeroContour (CNLVLS[*]:float, label:string)
; called internally
local eps, indEps
begin
       cnlvls = CNLVLS                          ; historical
       if (dimsizes(cnlvls).gt.1) then
           eps    = 1.e-09                          ; arbitrary
           indEps=ind(fabs(cnlvls).le.eps) 
           if (.not.ismissing(indEps)) then
               cnlvls(indEps) = 0.0        ; the "zero" line ==>-0.8e-09
          ;else                            ; debug print
          ;    print (label+": no zero contours")
           end if
       end if
       return (cnlvls)                                      
end

;*******************************************************************
function get_cnLevels (plot:graphic) 
local cnlvls
begin
       if (isatt(plot,"contour")) then
           getvalues plot@contour       
             "cnLevels"   : cnlvls
           end getvalues
       else
           getvalues plot
             "cnLevels"   : cnlvls
           end getvalues
       end if
       return(cnlvls)
end

;*********************************************************************
function ZeroNegDashLineContour (plot:graphic) 

; operates on a plot object created by "gsn_csm.ncl" code
; Make zero line twice as thick and set neg contourlines to dash
; Dash line patterns: http://ngwww.ucar.edu/ngdoc/ng/ref/dashpatterns.html

local cnlvls, cnlinepat, cnlinethk, n, N
begin
       cnlvls = get_cnLevels (plot)

       N = dimsizes(cnlvls)
       if (ismissing(N) .or. N.le.0) then
           print ("ZeroNegDashLineContour: dimsizes(cnlvls)=" \
                  +N+" return (non-fatal)")
           return (plot)
       else 
           cnlvls = FixZeroContour (cnlvls, "ZeroNegDashLineContour")
       end if

       if (any(cnlvls.le.0.)) then
           cnlinepat = new (dimsizes(cnlvls), integer) ; line pattern vector
           cnlinepat = 0                               ; default is solid (=0)
           cnlinethk = new (dimsizes(cnlvls), integer) ; line thick vector
           cnlinethk = 1                               ; default

           do n=0,N-1
              if (cnlvls(n).lt.0.) then
                  cnlinepat(n) = 5               ; simple dash line pattern
              end if
              if (cnlvls(n).eq.0.) then
                  cnlinethk(n) = 2               ; make the zero contour thicker
              end if
           end do
    
           if (isatt(plot,"contour")) then
               setvalues plot@contour
                 "cnMonoLineDashPattern"  : False
                 "cnLineDashPatterns"     : cnlinepat
                 "cnMonoLineThickness"    : False
                 "cnLineThicknesses"      : cnlinethk
               end setvalues
           else
               setvalues plot
                 "cnMonoLineDashPattern"  : False
                 "cnLineDashPatterns"     : cnlinepat
                 "cnMonoLineThickness"    : False
                 "cnLineThicknesses"      : cnlinethk
               end setvalues
           end if
      end if                                ; any
      return (plot)
end

;************************************************************
function iceareaFIX (icefrac[*][*]:numeric,hem:integer) 
begin
; icearea is the fractional sea ice area (0.0-1.0)
; icefrac first dimension is latitude, second is longitude
; hem = 0 (SH), 1 (NH)

if (.not.isatt(icefrac,"_FillValue")) then
  icefrac@_FillValue = getFillValue(icefrac)
end if 
lat = icefrac&lat
nlat = dimsizes(lat)
lon = icefrac&lon
nlon = dimsizes(lon)

RE = 6.37122e3             ; radius of earth in km
pi = acos(-1.0)
area = 4.*pi*RE^2          ; surface area of Earth 
d2r = pi/180.0

wgt = cos(d2r*lat)         ; weights for each latitude
tsum = sum(wgt)            ; sum of all weights
nwgt = wgt/tsum            ; frac of sphere of each lat band
boxarea = area*nwgt/nlon   ; area of each grid box (lat) in km^2
hemarea = new(nlat,float)

if (hem .eq. 0) then       ; Southern Hemisphere
  do j = 0, nlat/2-1 
    hemarea(j) =  sum(boxarea(j)*icefrac(j,:))
  end do
else                       ; Northern Hemisphere
  do j = nlat/2, nlat-1 
    hemarea(j) =  sum(boxarea(j)*icefrac(j,:))
  end do
end if
icearea = sum(hemarea)/1.e6

return(icearea)      ; return area of ice km^2 x 10^6 

end

;************************************************************
function iceareaGAU (icefrac[*][*]:numeric,hem:integer) 
begin
; icearea is the fractional sea ice area (0.0-1.0)
; icefrac first dimension is latitude, second is longitude
; hem = 0 (SH), 1 (NH)

if (.not.isatt(icefrac,"_FillValue")) then
  icefrac@_FillValue = getFillValue(icefrac)
end if 
lat = icefrac&lat
nlat = dimsizes(lat)
lon = icefrac&lon
nlon = dimsizes(lon)

RE = 6.37122e3            ; radius of earth in km
pi = acos(-1.0)
area = 4.*pi*RE^2         ; surface area of Earth 

gw = latGauWgt(nlat,"lat","gaussian weights","none")
tsum = sum(gw)            ; sum of all weights
nwgt = gw/tsum            ; frac of sphere of each lat band
boxarea = area*nwgt/nlon  ; area of each grid box (lat) in km^2
hemarea = new(nlat,float)

if (hem .eq. 0) then         ; Southern Hemisphere
  do j = 0, nlat/2-1 
    hemarea(j) =  sum(boxarea(j)*icefrac(j,:))
  end do
else
  do j = nlat/2, nlat-1 
    hemarea(j) =  sum(boxarea(j)*icefrac(j,:))
  end do
end if
icearea = sum(hemarea)/1.e6

return(icearea)      ; return area of ice km^2 x 10^6 

end

;************************************************************
function SigPattern (plot:graphic, CnLt:float, FillPatLt:integer ) 

; variation of Dennis Shea's ShadeLtContour
; operates on a plot object created by "gsn_csm.ncl" code
; Fill all contours less than or equal to "CnLt" to the
;      pattern corresponding to "FillPatLt" 
;      http://ngwww.ucar.edu/ngdoc/ng/ref/fillpatterns.html

local cnlvls, patterns, i, N
begin
                                        ; Retrieve contour levels.
   cnlvls = get_cnLevels (plot)

   N = dimsizes(cnlvls)
   if (ismissing(N) .or. N.le.0) then
       print ("SigPattern: dimsizes(cnlvls)=" \
              +N+" return (non-fatal)")
       return (plot)
   end if

   if (any(cnlvls.le.CnLt)) then
       patterns  = new(dimsizes(cnlvls)+1,integer) ; Create array for fill 
       patterns(:)  = -1                           ; patterns and initialize
                                                   ; it to transparent.
       do i=0,N-1                        ; Fill contour levels depending on 
         if(cnlvls(i).le.CnLt) then      ; different criteria.
           patterns(i) = FillPatLt       ; see above URL
         end if
       end do
     
       if (isatt(plot,"contour")) then
           setvalues plot@contour           ; Retrieve contour levels.
             "cnFillOn"          : True
             "cnMonoFillColor"   : True
             "cnMonoFillPattern" : False
             "cnFillPatterns"    : patterns
           end setvalues
       else
           setvalues plot
             "cnFillOn"          : True
             "cnMonoFillColor"   : True
             "cnMonoFillPattern" : False
             "cnFillPatterns"    : patterns
           end setvalues
       end if
   end if           
 
   return (plot)
end
