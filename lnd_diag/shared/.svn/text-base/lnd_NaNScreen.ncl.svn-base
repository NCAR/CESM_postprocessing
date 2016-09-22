load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$DIAG_SHARED/lnd_func.ncl"
load "$WKDIR/variable_master.ncl"

;************************************************
begin
  print ("=========================================")
  print ("Starting:  lnd_NaNScreen.ncl")
  print ("Start Time: "+systemfunc("date") )
  print ("=========================================")
  ptmpdir = getenv("PTMPDIR")
  wkdir   = getenv("WKDIR")
  runtype = getenv("RUNTYPE")

  name1      = "prefix_1"
  prefix1    = getenv(name1)
  in         = addfile(ptmpdir+"/"+prefix1+"/"+prefix1+"_ANN_ALL.nc","r")
  vars       = getfilevarnames (in)
  nvars      = dimsizes(vars)
  do i=0,nvars-1
	x = in->$vars(i)$
	rank = dimsizes(dimsizes(x))

	if (isfloat(x) .or. isdouble(x) .and. rank .gt. 1 ) then
		print("screening case 1 :  " + vars(i) )
        	; catch NaNs
        	if (any(isnan_ieee(x))) then
               		nNaN = num(isnan_ieee(x))
               		x1d = ndtooned(x)
               		dsizes_x = dimsizes(x)
               		indices = ind_resolve(ind(isnan_ieee(x1d)), dsizes_x)
               		value = x@_FillValue
               		print("found " + nNaN + " NaNs ")
               		if (nNaN .gt. 5) then
                        		loopNum = 5
               		else
                        		loopNum = nNaN
               		end if
               		do n = 0, loopNum-1
                       		print("   Sample NaN Coords: time = " + indices(n,0) + " latDim =  " + indices(n,1) + " lonDim " + indices(n,2) )
               		end do
	       		message = " Found " + nNaN + " NaNs for variable " + vars(i) + " in " + prefix1 + "_ANN_ALL data file"
	       		asciiwrite(wkdir+"NaN.txt",message)
	
	       		delete(dsizes_x)
	       		delete(indices)
	       		delete(x1d)
		
        	end if
	end if

	delete(x)
	delete(rank)

  end do   		; variable loop
  delete(in)
  delete(vars)
  delete(nvars)


  if (runtype .eq. "model1-model2") then
  	name2    = "prefix_2"
  	prefix2  = getenv(name2)
  	in       = addfile(ptmpdir+"/"+prefix2+"/"+prefix2+"_ANN_ALL.nc","r")
  	vars     = getfilevarnames (in)
  	nvars    = dimsizes(vars)
  	do i=0,nvars-1
		x = in->$vars(i)$
		rank = dimsizes(dimsizes(x))

		if (isfloat(x) .or. isdouble(x) .and. rank .gt. 1 ) then
			print("screening case 2 :  " + vars(i) )
	
        		; catch NaNs
        		if (any(isnan_ieee(x))) then
               			nNaN = num(isnan_ieee(x))
               			x1d = ndtooned(x)
               			dsizes_x = dimsizes(x)
               			indices = ind_resolve(ind(isnan_ieee(x1d)), dsizes_x)
               			value = x@_FillValue
               			print("found " + nNaN + " NaNs ")
               			if (nNaN .gt. 5) then
                        		loopNum = 5
               			else
                        		loopNum = nNaN
               			end if
               			do n = 0, loopNum-1
                        		print("   Sample NaN Coords: time = " + indices(n,0) + " latDim =  " + indices(n,1) + " lonDim " + indices(n,2) )
               			end do
               			message = " Found " + nNaN + " NaNs for variable " + vars(i) + " in " + prefix2 + "_ANN_ALL data file"               
               			asciiwrite(wkdir+"NaN.txt",message)  
	
               			delete(dsizes_x)        
               			delete(indices)               
               			delete(x1d)        
        		end if

        	end if
		delete(x)
		delete(rank)
	
	end do
   end if

print("Leaving lnd_NaNScreen")
end

