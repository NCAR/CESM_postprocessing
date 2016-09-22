module arg_wrap

  !-----------------------------------------------------------------------------
  !   wrappers to access program command-line arguments
  !
  !   CVS:$Id: arg_wrap.F90,v 1.1 2001/09/10 22:40:27 klindsay Exp $
  !   CVS:$Name:  $
  !   CVS:$Log: arg_wrap.F90,v $
  !   CVS:Revision 1.1  2001/09/10 22:40:27  klindsay
  !   CVS:initial checkin
  !   CVS:
  !-----------------------------------------------------------------------------

  use kinds_mod

  implicit none

  contains

  !-----------------------------------------------------------------------------

  integer(kind=i4) function iargc_wrap()

     integer(kind=i4) :: iargc
     iargc_wrap = iargc()

  end function iargc_wrap

  !-----------------------------------------------------------------------------

  subroutine getarg_wrap(i, c)

     integer(kind=i4), intent(in) :: i
     character(len=*), intent(out) :: c

     call getarg(i, c)

  end subroutine getarg_wrap

  !-----------------------------------------------------------------------------

end module arg_wrap
