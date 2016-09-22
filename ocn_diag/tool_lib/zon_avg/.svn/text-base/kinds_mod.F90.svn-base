module kinds_mod

  !-----------------------------------------------------------------------------
  !   This module defines variable precision for all common data types.
  !
  !   CVS:$Id: kinds_mod.F90,v 1.3 2002/02/11 04:40:47 klindsay Exp $
  !   CVS:$Name:  $
  !   CVS:$Log: kinds_mod.F90,v $
  !   CVS:Revision 1.3  2002/02/11 04:40:47  klindsay
  !   CVS:add long_char_len
  !   CVS:remove hard-wired values for log_kind and int_kind
  !   CVS:   they were there for flint friendliness
  !   CVS:
  !   CVS:Revision 1.2  2001/10/15 17:37:54  klindsay
  !   CVS:initial checkin
  !   CVS:
  !   CVS:Revision 1.1  2001/09/10 22:40:28  klindsay
  !   CVS:initial checkin
  !   CVS:
  !-----------------------------------------------------------------------------

  implicit none

  integer, parameter :: &
       char_len = 256                          , &
       long_char_len = 1024                    , &
       log_kind = kind(.true.)                 , &
       int_kind = kind(1)                      , &
       i4       = selected_int_kind(6)         , &
       i8       = selected_int_kind(13)        , &
       r4       = selected_real_kind(6)        , &
       r8       = selected_real_kind(13)

end module kinds_mod
