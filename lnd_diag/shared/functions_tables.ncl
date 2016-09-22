;*****************************************************************
; NCL script
; functions_tables.ncl
; Keith Oleson, OCT 2003
; revised:  Dec 2005 Nan Rosenbloom
;******************************************************************

procedure make_reg_table (case1,label1,case2,label2,regs,vars,means,title,tablename)

; case1 -  case1 name (string)
; label1 - case1 name (string)
; case2 -  case2 name (string)
; label2 - case2 name (string)
; regs  -  1d array (/nreg/) of region names (strings)
; vars  -  1d array (/nvars/) of variable names + units (strings)
; vunits  -  1d array (/nvars/) of variable units (strings)
; means -  3d array (/nvars,nreg,2/) of table values (floats)
; title -  table title (string)
; tablename - table filename (string)

begin
 nregs = dimsizes (regs)           ; number of regions
 nvars = dimsizes (vars)           ; number of variables
 spaces = integertochar(32)        ; space
 nheaders = 9                      ; number of header lines
 nrows = nregs+nheaders            ; total numbers of lines
 maxchar = 20                      ; max number of chars in case names

;----------------------------------------------
; makes a 13 column table
; column 1 contains the region names  
; columns 3-13 contain the table values (5 values for each "model")
;----------------------------------------------
; calculate number of spaces needed to approximately
; center case1 name at top of columns 2,4,6,8,10,12
;----------------------------------------------
 chr1a = stringtochar("case1")
 nchr1a = dimsizes(chr1a)-1
 if(nchr1a .ge. maxchar - 2) then
	nchr1a = 15
 end if
 nsp1a = (maxchar-nchr1a)/2 
 sp1a = new(nsp1a,"character")
 sp1a = spaces 
 spaces1a = chartostring(sp1a)

 nsp1b = 30-6-4-nchr1a/2            ;30 (right edge of second column)
                                    ; 6 (length of "region")
                                    ; 4 (spaces to decimal point)
                                    
 sp1b = new(nsp1b,"character")
 sp1b = spaces 
 spaces1b = chartostring(sp1b)

;----------------------------------------------
; calculate number of spaces needed to approximately
; center case2 name at top of columns 3,5,7,9,11,13
;----------------------------------------------
 chr2 = stringtochar("case2")
 nchr2 = dimsizes(chr2)-1
 if(nchr2 .ge. maxchar - 2) then
	nchr2 = 13
 end if
 nsp2 = (maxchar-nchr2)/2
 sp2 = new(nsp2,"character")
 sp2 = spaces 
 spaces2 = chartostring(sp2)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(0) name below case names
;----------------------------------------------
 
 chr3 = stringtochar(vars(0))
 nchr3 = dimsizes(chr3)-1
 nsp3 = (2*maxchar-nchr3)/2
 sp3 = new(nsp3,"character")
 sp3 = spaces 
 spaces3 = chartostring(sp3)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(1) name below case names
;----------------------------------------------
 chr4 = stringtochar(vars(1))
 nchr4 = dimsizes(chr4)-1
 nsp4 = (2*maxchar-nchr4)/2
 sp4 = new(nsp4,"character")
 sp4 = spaces 
 spaces4 = chartostring(sp4)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(2) name below case names
;----------------------------------------------
 chr5 = stringtochar(vars(2))
 nchr5 = dimsizes(chr5)-1
 nsp5 = (2*maxchar-nchr5)/2
 sp5 = new(nsp5,"character")
 sp5 = spaces 
 spaces5 = chartostring(sp5)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(3) name below case names
;----------------------------------------------
 chr6 = stringtochar(vars(3))
 nchr6 = dimsizes(chr6)-1
 nsp6 = (2*maxchar-nchr6)/2
 sp6 = new(nsp6,"character")
 sp6 = spaces 
 spaces6 = chartostring(sp6)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(4) name below case names
;----------------------------------------------
 chr7 = stringtochar(vars(4))
 nchr7 = dimsizes(chr7)-1
 nsp7 = (2*maxchar-nchr7)/2
 sp7 = new(nsp7,"character")
 sp7 = spaces 
 spaces7 = chartostring(sp7)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(5) name below case names
;----------------------------------------------
 chr8 = stringtochar(vars(5))
 nchr8 = dimsizes(chr8)-1
 nsp8 = (2*maxchar-nchr8)/2
 sp8 = new(nsp8,"character")
 sp8 = spaces 
 spaces8 = chartostring(sp8)
;----------------------------------------------
; the lines of the header
;----------------------------------------------
 c1    = "case1    "
 c2    = "case2    "
 spX = new(4,"character")
 spX = spaces 
 spacesX = chartostring(spX)
 table = new(nrows,"string")  
 table(0) = title 
 table(1) = " "
 table(2) = "TEST CASE (case1):      "+label1
 table(3) = " "
 table(4) = "REFERENCE CASE (case2): "+label2
 table(5) = " "
 table(6) = "Region"+spaces1b+c1+spaces1a+spacesX+c2+spaces1a+ \
            spacesX+c1+spaces1a+spacesX+c2+spaces1a+spacesX+c1+      \
            spaces1a+spacesX+c2+spaces1a+spacesX+c1+spaces1a+spacesX+    \
            c2+spaces1a+spacesX+c1+spaces1a+spacesX+c2+spaces1a+spacesX+ \
            c1+spaces1a+spacesX+c2
 table(7) = "                "+spaces3+vars(0)+spaces3+spaces4+vars(1)+     \
            spaces4+spaces5+vars(2)+spaces5+spaces6+vars(3)+spaces6+        \
            spaces7+vars(4)+spaces7+spaces8+vars(5)
 table(8) = " "
;----------------------------------------------
; the data
;----------------------------------------------
 do n = 0, nregs-1
   varchr = stringtochar(regs(n))
   nchar = dimsizes(varchr)-1
   nspaces = 30-nchar
   fmt = "%"+nspaces+".3f"
   table(nheaders+n) = regs(n)+sprintf(fmt,means(0,n,0))+ \
   sprintf("%20.3f",means(0,n,1))+sprintf("%20.3f",means(1,n,0))+ \
   sprintf("%20.3f",means(1,n,1))+sprintf("%20.3f",means(2,n,0))+ \
   sprintf("%20.3f",means(2,n,1))+sprintf("%20.3f",means(3,n,0))+ \
   sprintf("%20.3f",means(3,n,1))+sprintf("%20.3f",means(4,n,0))+ \
   sprintf("%20.3f",means(4,n,1))+sprintf("%20.3f",means(5,n,0))+ \
   sprintf("%20.3f",means(5,n,1))
   delete(varchr)
 end do
 asciiwrite(tablename,table)       ; write out table to file
end

procedure make_rivers_table (case1,label1,case2,label2,case3,river_name,riv_data, \
                             riv_data_titles,stn_name,title,tablename)

; case1 -  case1 name (string)
; label1 - case1 name (string)
; case2 -  case2 name (string)
; label2 - case2 name (string)
; case3 - case3 name (obs) (string)
; river_name  -  1d array (/nriv/) of river names (strings)
; riv_data -  2d array (/nvars,nriv/) of table values (floats)
; riv_data_titles  -  1d array (/nvars/) of variables (strings)
; title -  table title (string)
; tablename - table filename (string)

begin
 nriv = dimsizes (river_name)      ; number of regions
 nvars = dimsizes (riv_data_titles) ; number of variables
 spaces = integertochar(32)        ; space
 nheaders = 9                     ; number of header lines
 nrows = nriv+nheaders            ; total numbers of lines

;----------------------------------------------
; makes an 13 column table
; column 1 contains the river number
; column 2 contains the river name
; columns 3-12 contain the table values
; column 13 contains the station, country
;----------------------------------------------

;----------------------------------------------
; the lines of the header
;----------------------------------------------
 table = new(nrows,"string")  
 table(0) = title 
 table(1) = " "
 table(2) = "TEST CASE (case1):      "+label1
 table(3) = " "
 table(4) = "REFERENCE CASE (case2): "+label2
 table(5) = " "
 table(6) = "OBS CASE: "+case3
 table(7) = " "
 table(8) = riv_data_titles(0)+riv_data_titles(1)+riv_data_titles(2)+ \
            riv_data_titles(3)+riv_data_titles(4)+riv_data_titles(5)+ \
            riv_data_titles(6)+riv_data_titles(7)+riv_data_titles(8)+ \
            riv_data_titles(9)+riv_data_titles(10)+riv_data_titles(11)+ \
            riv_data_titles(12)
;----------------------------------------------
; the data
;----------------------------------------------
 sp1 = new(18,"character")
 sp1 = spaces 
 spaces1 = chartostring(sp1)
 sp2 = new(9,"character")
 sp2 = spaces 
 spaces2 = chartostring(sp2)
 do n = 0, nriv-1
   table(nheaders+n) = sprintf("%2.0f",riv_data(0,n))+spaces1+river_name(n)+ \
   sprintf("%24.3f",riv_data(1,n))+sprintf("%24.3f",riv_data(2,n))+ \
   sprintf("%24.3f",riv_data(3,n))+sprintf("%24.3f",riv_data(4,n))+ \
   sprintf("%24.3f",riv_data(5,n))+sprintf("%24.3f",riv_data(6,n))+ \
   sprintf("%24.3f",riv_data(7,n))+sprintf("%24.3f",riv_data(8,n))+ \
   sprintf("%24.3f",riv_data(9,n))+sprintf("%24.3f",riv_data(10,n))+ \
   spaces2+stn_name(n)
 end do
 asciiwrite(tablename,table)       ; write out table to file
end

; ----------------------------------------------------------------------------
procedure make_ann_table (case1,label1,case2,label2,vars,means,title,tablename)
; ----------------------------------------------------------------------------

; case1 -  case1 name (string)
; label1 - case1 name (string)
; case2 -  case2 name (string)
; label2 - case2 name (string)
; vars  -  1d array (/nvars/) of variables (strings)
; means -  3d array (/nvars,2/) of table values (floats)
; title -  table title (string)
; tablename - table filename (string)

begin
 nvars = dimsizes (vars)           ; number of variables
 spaces = integertochar(32)        ; space
 nheaders = 8                      ; number of header lines
 nrows = nvars+nheaders            ; total numbers of lines

;----------------------------------------------
; makes a 3 column table
; column 1 contains the variable names  
; columns 2-3 contain the table values (1 value for each "model")
;----------------------------------------------
 sp1b = new(65,"character")
 sp1b = spaces 
 spaces1b = chartostring(sp1b)

;----------------------------------------------
; the lines of the header
;----------------------------------------------
 c1    = "case1"
 c2    = "case2"
 spX = new(15,"character")
 spX = spaces 
 spacesX = chartostring(spX)
 table = new(nrows,"string")  
 table(0) = title 
 table(1) = " "
 table(2) = "TEST CASE (case1):      "+label1
 table(3) = " "
 table(4) = "REFERENCE CASE (case2): "+label2
 table(5) = " "
 table(6) = "Variable"+spaces1b \
            +c1+spacesX+c2
 table(7) = " "
;----------------------------------------------
; the data
;----------------------------------------------
 do n = 0, nvars-1
   varchr = stringtochar(vars(n))
   nchar = dimsizes(varchr)-1
   nspaces = 80-nchar
   fmt = "%"+nspaces+".3f"
   table(nheaders+n) = vars(n)+sprintf(fmt,means(n,0))+ \
   sprintf("%20.3f",means(n,1))
   delete(varchr)
 end do
 asciiwrite(tablename,table)       ; write out table to file
end
; ------------------------------------------------------
; post regional differences (case1 - case2) nanr 12/06/05
; ------------------------------------------------------
procedure make_reg_Dtable (case1,label1,case2,label2,regs,vars,vunits,vLongName,means,title,tablename)

; case1 -  case1 name (string)
; label1 - case1 name (string)
; case2 -  case2 name (string)
; label2 - case2 name (string)
; regs  -  1d array (/nreg/) of region names (strings)
; vars  -  1d array (/nvars/) of variable names + units (strings)
; vunits  -  1d array (/nvars/) of variable units (strings)
; means -  3d array (/nvars,nreg,2/) of table values (floats)
; title -  table title (string)
; tablename - table filename (string)

begin
 nregs = dimsizes (regs)           ; number of regions
 nvars = dimsizes (vars)           ; number of variables
 spaces = integertochar(32)        ; space
 nheaders = 18                     ; number of header lines
 nrows = nregs+nheaders            ; total numbers of lines
 maxchar = 20                      ; max number of chars in case names

;----------------------------------------------
; makes a 13 column table
; column 1 contains the region names  
; columns 3-13 contain the table values (5 values for each "model")
;----------------------------------------------
; calculate number of spaces needed to approximately
; center case1 name at top of columns 2,3,4,5,6,7
;----------------------------------------------
 chr1a = stringtochar(case1)
 chr2a = stringtochar(case2)
 
 nchr1a = (dimsizes(chr1a) + dimsizes(chr2a))-1
 if(nchr1a .ge. maxchar - 2) then
	nchr1a = 15
 end if
 nsp1a = (maxchar-nchr1a)/2 
 sp1a = new(nsp1a,"character")
 sp1a = spaces 
 spaces1a = chartostring(sp1a)

 nsp1b = 30-6-4-nchr1a/2            ;30 (right edge of second column)
                                    ; 6 (length of "region")
                                    ; 4 (spaces to decimal point)
                                    
 sp1b = new(nsp1b,"character")
 sp1b = spaces 
 spaces1b = chartostring(sp1b)

;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(0) name below case names
;----------------------------------------------
 chr3 = stringtochar(vars(0))
 nchr3 = dimsizes(chr3)-1
 nsp3 = (maxchar-nchr3)/2
 sp3 = new(nsp3,"character")
 sp3 = spaces 
 spaces3 = chartostring(sp3)
 delete(chr3)
 delete(sp3)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(1) name below case names
;----------------------------------------------
 chr4 = stringtochar(vars(1))
 nchr4 = dimsizes(chr4)-1
 nsp4 = (maxchar-nchr4)/2
 sp4 = new(nsp4,"character")
 sp4 = spaces 
 spaces4 = chartostring(sp4)
 delete(chr4)
 delete(sp4)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(2) name below case names
;----------------------------------------------
 chr5 = stringtochar(vars(2))
 nchr5 = dimsizes(chr5)-1
 nsp5 = (maxchar-nchr5)/2
 sp5 = new(nsp5,"character")
 sp5 = spaces 
 spaces5 = chartostring(sp5)
 delete(sp5)
 delete(chr5)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(3) name below case names
;----------------------------------------------
 chr6 = stringtochar(vars(3))
 nchr6 = dimsizes(chr6)-1
 nsp6 = (maxchar-nchr6)/2
 sp6 = new(nsp6,"character")
 sp6 = spaces 
 spaces6 = chartostring(sp6)
 delete(chr6)
 delete(sp6)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(4) name below case names
;----------------------------------------------
 chr7 = stringtochar(vars(4))
 nchr7 = dimsizes(chr7)-1
 nsp7 = (maxchar-nchr7)/2
 sp7 = new(nsp7,"character")
 sp7 = spaces 
 spaces7 = chartostring(sp7)
 delete(chr7)
 delete(sp7)
;----------------------------------------------
; calculate number of spaces needed to approximately
; center vars(5) name below case names
;----------------------------------------------
 chr8 = stringtochar(vars(5))
 nchr8 = dimsizes(chr8)-1
 nsp8 = (maxchar-nchr8)/2
 sp8 = new(nsp8,"character")
 sp8 = spaces 
 spaces8 = chartostring(sp8)
 delete(chr8)
 delete(sp8)
;----------------------------------------------
; the lines of the header
;----------------------------------------------
 dname = "Case1-Case2"
 table = new(nrows,"string")  
 table(0) = title 
 table(1) = " "
 table(2) = "TEST CASE (case1):      "+label1
 table(3) = " "
 table(4) = "REFERENCE CASE (case2): "+label2
 table(5) = " "
 table(6) = "DIFFERENCE:            ("+case1+") - ("+case2+")"
 table(7) = " "
 table(8) = "Variables:      " + vars(0) + " = " + vLongName(0) + " (" + vunits(0) +")"
 table(9) = "		" + vars(1) + " = " + vLongName(1) + " (" + vunits(1) +")"
 table(10) = "		" + vars(2) + " = " + vLongName(2) + " (" + vunits(2) +")"
 table(11) = "		" + vars(3) + " = " + vLongName(3) + " (" + vunits(3) +")"
 table(12) = "		" + vars(4) + " = " + vLongName(4) + " (" + vunits(4) +")"
 table(13) = "		" + vars(5) + " = " + vLongName(5) + " (" + vunits(5) +")"
 table(14) = " "
 table(15) = "Region           " +spaces3+vars(0)+spaces3+spaces4+vars(1)+spaces4+ \
            spaces5+vars(2)+spaces5+spaces6+vars(3)+spaces6+       \
            spaces7+vars(4)+spaces7+spaces8+vars(5)
 table(16) = " "
;----------------------------------------------
; the data
;----------------------------------------------
 do n = 0, nregs-1
   varchr = stringtochar(regs(n))
   nchar = dimsizes(varchr)-1
   nspaces = 30-nchar
   fmt = "%"+nspaces+".3f"
   table(nheaders+n) = regs(n)+sprintf(fmt,means(0,n,2))+ \
   sprintf("%20.3f",means(1,n,2))+ \
   sprintf("%20.3f",means(2,n,2))+ \
   sprintf("%20.3f",means(3,n,2))+ \
   sprintf("%20.3f",means(4,n,2))+ \
   sprintf("%20.3f",means(5,n,2))
   
   delete(varchr)
 end do
 asciiwrite(tablename,table)       ; write out table to file
end

; ----------------------------------------------------------------------------
procedure make_ann_Dtable (case1,label1,case2,label2,vars,means,title,tablename)
; ----------------------------------------------------------------------------

; case1 -  case1 name (string)
; label1 - case1 name (string)
; case2 -  case2 name (string)
; label2 - case2 name (string)
; vars  -  1d array (/nvars/) of variables (strings)
; means -  3d array (/nvars,2/) of table values (floats)
; title -  table title (string)
; tablename - table filename (string)

begin
 nvars = dimsizes (vars)           ; number of variables
 spaces = integertochar(32)        ; space
 nheaders = 10                     ; number of header lines
 nrows = nvars+nheaders            ; total numbers of lines
 maxchar = 25                      ; max number of chars in case names

;----------------------------------------------
; makes a 3 column table
; column 1 contains the variable names
; columns 2-3 contain the table values (1 value for each "model")
;----------------------------------------------
 spX = new(62,"character")
 spX = spaces
 spacesX = chartostring(spX)
;----------------------------------------------
; the lines of the header
;----------------------------------------------
 c1    = "case1-case2"
 table = new(nrows,"string")
 table(0) = title
 table(1) = " "
 table(2) = "TEST CASE (case1):      "+label1
 table(3) = " "
 table(4) = "REFERENCE CASE (case2): "+label2
 table(5) = " "
 table(6) = "DIFFERENCE:            ("+case1+") - ("+case2+")"
 table(7) = " "
 table(8) = "Variable"+spacesX+c1
 table(9) = " "
;----------------------------------------------
; the data
;----------------------------------------------
 do n = 0, nvars-1
   varchr = stringtochar(vars(n))
   nchar = dimsizes(varchr)-1
   nspaces = 80-nchar
   fmt = "%"+nspaces+".3f"
   table(nheaders+n) = vars(n)+sprintf(fmt,means(n,2))
   delete(varchr)
 end do
 asciiwrite(tablename,table)       ; write out table to file
end
