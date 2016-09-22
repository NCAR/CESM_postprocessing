load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCLPATH/pressure.ncl"
;load "pressure.ncl"

;PRO eos, TEMP, SALT, depth, RHOFULL, $
;    expansion_coeff=expansion_coeff, DRHODT, DRHODS

function eos( TEMP, SALT, depth, opt)
;------------------------------------------------------------
;
; McDougall, Wright, Jackett, and Feistel EOS
; test value : rho = 1.033213387 for
; S = 35.0 PSU, theta = 20.0 C, pressure = 2000.0 dbars
;
;   variable         units
;   --------       ---------
;     TEMP          degree C     (IN)
;     SALT            psu        (IN)
;     depth            m         (IN)
;    RHOFULL         g/cm^3      (OUT)
;
;------------------------------------------------------------

; MWJF EOS coefficients

local tmin,tmax,smin,smax,dim,TQ,SQ,p,SQR,WORK1,WORK2,DENOMK, \
      RHOFULL,size,ret_var,WORK3,WORK4,DRHODT,DRHODS
begin

; *** these constants will be used to construct the numerator
  mwjfnp0s0t0 =  9.99843699d+2
  mwjfnp0s0t1 =  7.35212840d+0
  mwjfnp0s0t2 = -5.45928211d-2
  mwjfnp0s0t3 =  3.98476704d-4
  mwjfnp0s1t0 =  2.96938239d+0
  mwjfnp0s1t1 = -7.23268813d-3
  mwjfnp0s2t0 =  2.12382341d-3
  mwjfnp1s0t0 =  1.04004591d-2
  mwjfnp1s0t2 =  1.03970529d-7
  mwjfnp1s1t0 =  5.18761880d-6
  mwjfnp2s0t0 = -3.24041825d-8
  mwjfnp2s0t2 = -1.23869360d-11

; *** factor unit change (kg/m^3 -> g/cm^3) into numerator terms

  mwjfnp0s0t0 = mwjfnp0s0t0 * 0.001d
  mwjfnp0s0t1 = mwjfnp0s0t1 * 0.001d
  mwjfnp0s0t2 = mwjfnp0s0t2 * 0.001d
  mwjfnp0s0t3 = mwjfnp0s0t3 * 0.001d 
  mwjfnp0s1t0 = mwjfnp0s1t0 * 0.001d 
  mwjfnp0s1t1 = mwjfnp0s1t1 * 0.001d
  mwjfnp0s2t0 = mwjfnp0s2t0 * 0.001d
  mwjfnp1s0t0 = mwjfnp1s0t0 * 0.001d 
  mwjfnp1s0t2 = mwjfnp1s0t2 * 0.001d 
  mwjfnp1s1t0 = mwjfnp1s1t0 * 0.001d
  mwjfnp2s0t0 = mwjfnp2s0t0 * 0.001d 
  mwjfnp2s0t2 = mwjfnp2s0t2 * 0.001d 

; *** these constants will be used to construct the denominator

  mwjfdp0s0t0 =  1.0d+0
  mwjfdp0s0t1 =  7.28606739d-3
  mwjfdp0s0t2 = -4.60835542d-5
  mwjfdp0s0t3 =  3.68390573d-7
  mwjfdp0s0t4 =  1.80809186d-10
  mwjfdp0s1t0 =  2.14691708d-3
  mwjfdp0s1t1 = -9.27062484d-6
  mwjfdp0s1t3 = -1.78343643d-10
  mwjfdp0sqt0 =  4.76534122d-6
  mwjfdp0sqt2 =  1.63410736d-9
  mwjfdp1s0t0 =  5.30848875d-6
  mwjfdp2s0t3 = -3.03175128d-16
  mwjfdp3s0t1 = -1.27934137d-17

  tmin =  -2.0d
  tmax = 999.0d
  smin =   0.0d
  smax = 999.0d

  dim = dimsizes(dimsizes(TEMP))

  if (dim .ne. dimsizes(dimsizes(SALT)) .or. any(dimsizes(TEMP) .ne. dimsizes(SALT))) then
    print ("T and S must be of the same size....")
  end if
  
  if ( dim .ge. 3 ) then 
    print( " T & S should be < 3D arrays.... ")
  end if

  TQ = todouble(where(TEMP .gt. tmin, TEMP, tmin))
  SQ = todouble(where(SALT .gt. tmin, SALT, tmin))


  p = todouble(10.0) * pressure(depth)

  SQR = sqrt(SQ)

; *** first calculate numerator of MWJF density [P_1(S,T,p)]

  mwjfnums0t0 = mwjfnp0s0t0 + p*(mwjfnp1s0t0 + p*mwjfnp2s0t0)
  mwjfnums0t1 = mwjfnp0s0t1
  mwjfnums0t2 = mwjfnp0s0t2 + p*(mwjfnp1s0t2 + p*mwjfnp2s0t2)
  mwjfnums0t3 = mwjfnp0s0t3
  mwjfnums1t0 = mwjfnp0s1t0 + p*mwjfnp1s1t0
  mwjfnums1t1 = mwjfnp0s1t1
  mwjfnums2t0 = mwjfnp0s2t0

  WORK1 = mwjfnums0t0 + TQ * (mwjfnums0t1 + TQ * (mwjfnums0t2 + \
           mwjfnums0t3 * TQ)) + SQ * (mwjfnums1t0 +             \ 
           mwjfnums1t1 * TQ + mwjfnums2t0 * SQ)

; *** now calculate denominator of MWJF density [P_2(S,T,p)]

  mwjfdens0t0 = mwjfdp0s0t0 + p*mwjfdp1s0t0
  mwjfdens0t1 = mwjfdp0s0t1 + (p^3) * mwjfdp3s0t1
  mwjfdens0t2 = mwjfdp0s0t2
  mwjfdens0t3 = mwjfdp0s0t3 + (p^2) * mwjfdp2s0t3
  mwjfdens0t4 = mwjfdp0s0t4
  mwjfdens1t0 = mwjfdp0s1t0
  mwjfdens1t1 = mwjfdp0s1t1
  mwjfdens1t3 = mwjfdp0s1t3
  mwjfdensqt0 = mwjfdp0sqt0
  mwjfdensqt2 = mwjfdp0sqt2

  WORK2 = mwjfdens0t0 + TQ * (mwjfdens0t1 + TQ * (mwjfdens0t2 +      \ 
         TQ * (mwjfdens0t3 + mwjfdens0t4 * TQ))) +                   \ 
         SQ * (mwjfdens1t0 + TQ * (mwjfdens1t1 + TQ*TQ*mwjfdens1t3)+ \ 
         SQR * (mwjfdensqt0 + TQ*TQ*mwjfdensqt2))

  DENOMK = 1.0d/WORK2

  RHOFULL = WORK1 * DENOMK

  if (.not. (isatt(opt,"expansion_coeff") .and. opt@expansion_coeff .eq. 1)) then
    return (RHOFULL)
  else
    size = new(dim + 1, long)
    size(0) = 3
    size(1:) = dimsizes(TEMP)
    ret_var = new(size,double)
    WORK3 = mwjfnums0t1 + TQ * (2.0d*mwjfnums0t2 +    \             
            3.0d*mwjfnums0t3 * TQ) + mwjfnums1t1 * SQ

    WORK4 = mwjfdens0t1 + SQ * mwjfdens1t1 +                \
            TQ * (2.0d*(mwjfdens0t2 + SQ*SQR*mwjfdensqt2) + \
            TQ * (3.0d*(mwjfdens0t3 + SQ * mwjfdens1t3) +   \
            TQ *  4.0d*mwjfdens0t4))

    DRHODT = (WORK3 - WORK1*DENOMK*WORK4)*DENOMK

    WORK3 = mwjfnums1t0 + mwjfnums1t1 * TQ + 2.0d*mwjfnums2t0 * SQ 

    WORK4 = mwjfdens1t0 +                                     \ 
             TQ * (mwjfdens1t1 + TQ*TQ*mwjfdens1t3) +         \
             1.5d*SQR*(mwjfdensqt0 + TQ*TQ*mwjfdensqt2)

    DRHODS = (WORK3 - WORK1*DENOMK*WORK4)*DENOMK * 1000.0d
    if (dimsizes(ret_var) .eq. 3) then
      ret_var(0,:,:) = RHOFULL
      ret_var(1,:,:) = DRHODT
      ret_var(2,:,:) = DRHODS
    else
      ret_var(0,:) = RHOFULL
      ret_var(1,:) = DRHODT
      ret_var(2,:) = DRHODS
    end if
  end if

  return ret_var

end
