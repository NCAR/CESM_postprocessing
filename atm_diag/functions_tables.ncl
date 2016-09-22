;*****************************************************************
; NCL script
; table_functions.ncl
; Mark Stevens, Sept 2001
;******************************************************************

procedure make_table (case1,label1,case2,label2,vars,means,title,tablename)

; case1 - case1 name (string)
; label1 -case1 name (string)
; case2 - case2 name (string)
; label2 -case2 name (string)
; vars  - 1d array (/nvar/) of variable names (strings)
; means - 2d array (/nvar,4/) of table values (floats)
; title - table title (string)
; tablename - table filename (string)

begin

 nvars = dimsizes (vars)           ; number of variables
 spaces = integertochar(32)        ; space
 nheaders = 8                      ; number of header lines
 nrows = nvars+nheaders            ; total numbers of lines
 maxchar = 21                      ; max number of chars in case names

; makes a 5 column table
; column 1 contains the variable names  
; columns 2-5 contain the table values

; calculate number of spaces needed to approximately
; center case1 name at top of column 2
 chr1 = stringtochar(case1)
 if (dimsizes(chr1) .gt. 20) then
   nchr1 = 19
 else
   nchr1 = dimsizes(chr1)-1
 end if
 nsp1 = (maxchar-nchr1)/2
 sp1 = new(nsp1,"character")
 sp1 = spaces 
 spaces1 = chartostring(sp1)

; calculate number of spaces needed to approximately
; center case2 name at top of column 3
 chr2 = stringtochar(case2)
 if (dimsizes(chr2) .gt. 20) then
   nchr2 = 19 
 else
   nchr2 = dimsizes(chr2)-1
 end if
 nsp2 = (maxchar-nchr2)/2
 sp2 = new(nsp2,"character")
 sp2 = spaces 
 spaces2 = chartostring(sp2)

; calculate number of spaces needed to approximately
; center case1-case2 name at top of column 4
 nchr3 = nchr1 
 nsp3 = (maxchar-nchr3)/2
 sp3 = new(nsp3,"character")
 sp3 = spaces 
 spaces3 = chartostring(sp3)

; column 4 second line
 nsp = 11+nsp1+nchr1+nsp1+nsp2+nchr2+nsp2+nsp3
 sp5 = new(nsp,"character")
 sp5 = spaces

; calculate number of spaces needed to approximately
; center RMSE at top of column 5
 nchr4 = 4
 nsp4 = (maxchar-nchr4)/2
 sp4 = new(nsp4,"character")
 sp4 = spaces
 spaces4 = chartostring(sp4)

; the lines of the header
 table = new(nrows,"string")  
 table(0) = title 
 table(1) = " "
 table(2) = "TEST CASE: "+label1
 table(3) = " "
 table(4) = "CONTROL CASE: "+label2
 table(5) = " "
 table(6) = "Variable   "+spaces1+case1+spaces1+spaces2+case2+spaces2+ \
            spaces3+case1+spaces4+"RMSE"
 table(7) = sp5+"-"+case2

 do n = 0, nvars-1
   varchr = stringtochar(vars(n))
   nchar = dimsizes(varchr)-1
   nspaces = 24-nchar
   if (vars(n).eq."AAM" .or. vars(n).eq."EP") then
     fmt = "%"+nspaces+".3e"
     table(nheaders+n) = vars(n)+sprintf(fmt,means(n,0))+ \
                  sprintf("%20.3e",means(n,1))+sprintf("%18.3e",means(n,2))+ \
                  sprintf("%14.3f",means(n,3))
   else
     fmt = "%"+nspaces+".3f"
     table(nheaders+n) = vars(n)+sprintf(fmt,means(n,0))+ \
     sprintf("%20.3f",means(n,1))+sprintf("%18.3f",means(n,2))+ \
     sprintf("%14.3f",means(n,3))
   end if
   delete(varchr)
 end do
 asciiwrite(tablename,table)       ; write out table to file
end
