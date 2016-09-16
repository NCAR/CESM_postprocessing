MODULE msg_mod

  !-----------------------------------------------------------------------------
  !   module for printing messages
  !   all msg_write calls have a routine name as the first argument
  !   positional notation added to arguments to get module to compile
  !
  !   CVS:$Id: msg_mod.F90,v 1.1 2001/09/10 22:40:28 klindsay Exp $
  !   CVS:$Name:  $
  !   CVS:$Log: msg_mod.F90,v $
  !   CVS:Revision 1.1  2001/09/10 22:40:28  klindsay
  !   CVS:initial checkin
  !   CVS:
  !-----------------------------------------------------------------------------

  !*****************************************************************************

  USE kinds_mod

  IMPLICIT NONE
  PRIVATE
  SAVE

  !-----------------------------------------------------------------------------
  !   public parameters & subroutines
  !-----------------------------------------------------------------------------

  PUBLIC :: &
       msg_set_state, &
       msg_get_state, &
       msg_set_iunit, &
       msg_get_iunit, &
       msg_write

  !-----------------------------------------------------------------------------
  !   module variables
  !-----------------------------------------------------------------------------

  LOGICAL(KIND=log_kind) :: msg_state = .TRUE.

  INTEGER(KIND=int_kind) :: msg_iunit = 6

  !-----------------------------------------------------------------------------
  !   generic interfaces
  !-----------------------------------------------------------------------------

  INTERFACE msg_write
     MODULE PROCEDURE &
          msg_write_A, &
          msg_write_AA, &
          msg_write_AI, &
          msg_write_AAA, &
          msg_write_AAI, &
          msg_write_AIA, &
          msg_write_AAAA, &
          msg_write_AIAI, &
          msg_write_AAAI, &
          msg_write_AAIA, &
          msg_write_AAAIAI
  END INTERFACE

  !*****************************************************************************

CONTAINS

  !*****************************************************************************

  SUBROUTINE msg_set_state(state)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    LOGICAL(KIND=log_kind), INTENT(IN) :: state

    msg_state = state

  END SUBROUTINE msg_set_state

  !*****************************************************************************

  SUBROUTINE msg_get_state(state)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    LOGICAL(KIND=log_kind), INTENT(OUT) :: state

    state = msg_state

  END SUBROUTINE msg_get_state

  !*****************************************************************************

  SUBROUTINE msg_set_iunit(msg_iunit_in)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    INTEGER(KIND=int_kind), INTENT(IN) :: msg_iunit_in

    msg_iunit = msg_iunit_in

  END SUBROUTINE msg_set_iunit

  !*****************************************************************************

  SUBROUTINE msg_get_iunit(msg_iunit_out)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    INTEGER(KIND=int_kind), INTENT(OUT) :: msg_iunit_out

    msg_iunit_out = msg_iunit

  END SUBROUTINE msg_get_iunit

  !*****************************************************************************

  SUBROUTINE msg_write_A(sub_name, A1_1)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A)") &
            sub_name, A1_1
    END IF

  END SUBROUTINE msg_write_A

  !*****************************************************************************

  SUBROUTINE msg_write_AA(sub_name, A1_1, A2_2)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1, A2_2

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A, A)") &
            sub_name, A1_1, A2_2
    END IF

  END SUBROUTINE msg_write_AA

  !*****************************************************************************

  SUBROUTINE msg_write_AI(sub_name, A1_1, I1_2)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1
    INTEGER(KIND=int_kind), INTENT(IN) :: I1_2

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A, I6)") &
            sub_name, A1_1, I1_2
    END IF

  END SUBROUTINE msg_write_AI

  !*****************************************************************************

  SUBROUTINE msg_write_AAA(sub_name, A1_1, A2_2, A3_3)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1, A2_2, A3_3

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A, A, A)") &
            sub_name, A1_1, A2_2, A3_3
    END IF

  END SUBROUTINE msg_write_AAA

  !*****************************************************************************

  SUBROUTINE msg_write_AAI(sub_name, A1_1, A2_2, I1_3)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1, A2_2
    INTEGER(KIND=int_kind), INTENT(IN) :: I1_3

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A, A, I6)") &
            sub_name, A1_1, A2_2, I1_3
    END IF

  END SUBROUTINE msg_write_AAI

  !*****************************************************************************

  SUBROUTINE msg_write_AIA(sub_name, A1_1, I1_2, A2_3)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1, A2_3
    INTEGER(KIND=int_kind), INTENT(IN) :: I1_2

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A, I6, A)") &
            sub_name, A1_1, I1_2, A2_3
    END IF

  END SUBROUTINE msg_write_AIA

  !*****************************************************************************

  SUBROUTINE msg_write_AAAA(sub_name, A1_1, A2_2, A3_3, A4_4)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1, A2_2, A3_3, A4_4

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A, A, A, A)") &
            sub_name, A1_1, A2_2, A3_3, A4_4
    END IF

  END SUBROUTINE msg_write_AAAA

  !*****************************************************************************

  SUBROUTINE msg_write_AIAI(sub_name, A1_1, I1_2, A2_3, I2_4)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1, A2_3
    INTEGER(KIND=int_kind), INTENT(IN) :: I1_2, I2_4

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A, I6, A, I6)") &
            sub_name, A1_1, I1_2, A2_3, I2_4
    END IF

  END SUBROUTINE msg_write_AIAI

  !*****************************************************************************

  SUBROUTINE msg_write_AAAI(sub_name, A1_1, A2_2, A3_3, I1_4)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1, A2_2, A3_3
    INTEGER(KIND=int_kind), INTENT(IN) :: I1_4

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A, A, A, I6)") &
            sub_name, A1_1, A2_2, A3_3, I1_4
    END IF

  END SUBROUTINE msg_write_AAAI

  !*****************************************************************************

  SUBROUTINE msg_write_AAIA(sub_name, A1_1, A2_2, I1_3, A3_4)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1, A2_2, A3_4
    INTEGER(KIND=int_kind), INTENT(IN) :: I1_3

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, FMT="('(', A, ') ', A, A, I6, A)") &
            sub_name, A1_1, A2_2, I1_3, A3_4
    END IF

  END SUBROUTINE msg_write_AAIA

  !*****************************************************************************

  SUBROUTINE msg_write_AAAIAI(sub_name, A1_1, A2_2, A3_3, I1_4, A4_5, I2_6)

    !---------------------------------------------------------------------------
    !   arguments
    !---------------------------------------------------------------------------

    CHARACTER(LEN=*), INTENT(IN) :: sub_name, A1_1, A2_2, A3_3, A4_5
    INTEGER(KIND=int_kind), INTENT(IN) :: I1_4, I2_6

    IF (msg_state) THEN
       WRITE(UNIT=msg_iunit, &
            FMT="('(', A, ') ', A, A, A, I6, A, I6)") &
            sub_name, A1_1, A2_2, A3_3, I1_4, A4_5, I2_6
    END IF

  END SUBROUTINE msg_write_AAAIAI

  !*****************************************************************************

END MODULE msg_mod
