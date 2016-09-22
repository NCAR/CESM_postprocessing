module constants

  !-----------------------------------------------------------------------------
  !   define numerical constants, such as pi
  !
  !   CVS:$Id: constants.F90,v 1.4 2001/09/15 17:42:17 klindsay Exp $
  !   CVS:$Name:  $
  !   CVS:$Log: constants.F90,v $
  !   CVS:Revision 1.4  2001/09/15 17:42:17  klindsay
  !   CVS:added deg2rad and rad2deg
  !   CVS:
  !   CVS:Revision 1.3  2001/09/12 23:10:51  klindsay
  !   CVS:added c0 and c90
  !   CVS:
  !   CVS:Revision 1.2  2001/09/11 20:29:37  klindsay
  !   CVS:added stdin & stdout parameters
  !   CVS:
  !   CVS:Revision 1.1  2001/09/10 23:36:48  klindsay
  !   CVS:initial checkin
  !   CVS:
  !-----------------------------------------------------------------------------

  use kinds_mod

  implicit none

  integer (kind=int_kind), parameter :: &
     stdin  =         5          , &
     stdout =         6

  real (kind=r8), parameter ::     &
     c0     =   0.00_r8          , &
     c1     =   1.00_r8          , &
     c2     =   2.00_r8          , &
     c4     =   4.00_r8          , &
     c10    =  10.00_r8          , &
     c90    =  90.00_r8          , &
     c180   = 180.00_r8          , &
     c360   = 360.00_r8          , &
     p5     =   0.50_r8          , &
     p25    =   0.25_r8

  real (kind=r8), save ::          &
     pi, pih, pi2, deg2rad, rad2deg

  contains

  !-----------------------------------------------------------------------------

  subroutine init_constants

    pi  = c4 * atan(c1)
    pi2 = c2 * pi
    pih = p5 * pi
    deg2rad = pi / c180
    rad2deg = c180 / pi

  end subroutine init_constants

  !-----------------------------------------------------------------------------

end module constants
