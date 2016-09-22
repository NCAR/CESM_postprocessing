undef("find_var_with_alts")
function find_var_with_alts(infile, varname, info)
local i, altName
begin
;********************************************************
; This function looks for a variable named 'varname' in the given open
; file; if found, returns varname. If 'varname' is not found, the
; function checks for the altNames attribute in 'info'; if this
; attribute is present, it is taken to be a list of alternative
; variable names. The function then loops through this list of names 
; until it finds one present in the file; it then returns this first
; alternate name found. If 'varname' is not found in the file and
; either (1) there is no altNames attribute in info, or (2) the
; altNames attribute is just an empty string, or
; (3) none of the variable names in the altNames list are 
; present in the file, then the function returns an empty string.

  if (isfilevar(infile, varname)) then
    return(varname)
  end if

  ; if we get here, variable is not found yet

  if (.not. isatt(info, "altNames")) then
    return("")
  end if

  if (dimsizes(info@altNames) .eq. 1 .and. info@altNames(0) .eq. "") then
    return("")
  end if

  ; if we get here (1) varname is not in the file, and (2) info has an
  ; altNames attribute that is not just ""

  do i=0,dimsizes(info@altNames)-1
    altName=info@altNames(i)
    if (isfilevar(infile, altName)) then
      return(altName)
    end if
  end do
  
  ; if we get here, none of the altNames were found

  return("")
end