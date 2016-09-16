MODULE nf_wrap

  !-----------------------------------------------------------------------------
  !   module consisting of NetCDF library wrappers
  !   stopping on bad status codes can be enabled/disabled
  !   can be used in multi-task environment via appropriate calls to
  !   nf_wrap_put_lcall_nf & nf_wrap_put_broadcast
  !
  !   CVS:$Id: nf_wrap.F90,v 1.1 2001/09/10 22:40:28 klindsay Exp $
  !   CVS:$Name:  $
  !   CVS:$Log: nf_wrap.F90,v $
  !   CVS:Revision 1.1  2001/09/10 22:40:28  klindsay
  !   CVS:initial checkin
  !   CVS:
  !-----------------------------------------------------------------------------

  USE kinds_mod
  USE msg_mod
  USE nf_wrap_stubs

  IMPLICIT NONE

  !-----------------------------------------------------------------------------
  !   generic interfaces
  !-----------------------------------------------------------------------------

  INTERFACE NF_PUT_VAR_WRAP
     MODULE PROCEDURE &
          NF_PUT_VAR_TEXT_WRAP, &
          NF_PUT_VAR_INT_WRAP_1D, &
          NF_PUT_VAR_REAL_WRAP_1D, &
          NF_PUT_VAR_DOUBLE_WRAP_1D, &
          NF_PUT_VAR_INT_WRAP_2D, &
          NF_PUT_VAR_REAL_WRAP_2D, &
          NF_PUT_VAR_DOUBLE_WRAP_2D, &
          NF_PUT_VAR_INT_WRAP_3D, &
          NF_PUT_VAR_REAL_WRAP_3D, &
          NF_PUT_VAR_DOUBLE_WRAP_3D, &
          NF_PUT_VAR_INT_WRAP_4D, &
          NF_PUT_VAR_REAL_WRAP_4D, &
          NF_PUT_VAR_DOUBLE_WRAP_4D
  END INTERFACE

  INTERFACE NF_PUT_VARA_WRAP
     MODULE PROCEDURE &
          NF_PUT_VARA_TEXT_WRAP, &
          NF_PUT_VARA_INT_WRAP_1D, &
          NF_PUT_VARA_REAL_WRAP_1D, &
          NF_PUT_VARA_DOUBLE_WRAP_1D, &
          NF_PUT_VARA_INT_WRAP_2D, &
          NF_PUT_VARA_REAL_WRAP_2D, &
          NF_PUT_VARA_DOUBLE_WRAP_2D, &
          NF_PUT_VARA_INT_WRAP_3D, &
          NF_PUT_VARA_REAL_WRAP_3D, &
          NF_PUT_VARA_DOUBLE_WRAP_3D, &
          NF_PUT_VARA_INT_WRAP_4D, &
          NF_PUT_VARA_REAL_WRAP_4D, &
          NF_PUT_VARA_DOUBLE_WRAP_4D
  END INTERFACE

  INTERFACE NF_GET_VAR_WRAP
     MODULE PROCEDURE &
          NF_GET_VAR_TEXT_WRAP, &
          NF_GET_VAR_INT_WRAP_1D, &
          NF_GET_VAR_REAL_WRAP_1D, &
          NF_GET_VAR_DOUBLE_WRAP_1D, &
          NF_GET_VAR_INT_WRAP_2D, &
          NF_GET_VAR_REAL_WRAP_2D, &
          NF_GET_VAR_DOUBLE_WRAP_2D, &
          NF_GET_VAR_INT_WRAP_3D, &
          NF_GET_VAR_REAL_WRAP_3D, &
          NF_GET_VAR_DOUBLE_WRAP_3D, &
          NF_GET_VAR_INT_WRAP_4D, &
          NF_GET_VAR_REAL_WRAP_4D, &
          NF_GET_VAR_DOUBLE_WRAP_4D
  END INTERFACE

  INTERFACE NF_GET_VARA_WRAP
     MODULE PROCEDURE &
          NF_GET_VARA_TEXT_WRAP, &
          NF_GET_VARA_INT_WRAP_1D, &
          NF_GET_VARA_REAL_WRAP_1D, &
          NF_GET_VARA_DOUBLE_WRAP_1D, &
          NF_GET_VARA_INT_WRAP_2D, &
          NF_GET_VARA_REAL_WRAP_2D, &
          NF_GET_VARA_DOUBLE_WRAP_2D, &
          NF_GET_VARA_INT_WRAP_3D, &
          NF_GET_VARA_REAL_WRAP_3D, &
          NF_GET_VARA_DOUBLE_WRAP_3D, &
          NF_GET_VARA_INT_WRAP_4D, &
          NF_GET_VARA_REAL_WRAP_4D, &
          NF_GET_VARA_DOUBLE_WRAP_4D
  END INTERFACE

  INTERFACE NF_PUT_ATT_WRAP
     MODULE PROCEDURE &
          NF_PUT_ATT_TEXT_WRAP, &
          NF_PUT_ATT_INT_WRAP, &
          NF_PUT_ATT_INT_WRAP_1D, &
          NF_PUT_ATT_REAL_WRAP, &
          NF_PUT_ATT_REAL_WRAP_1D, &
          NF_PUT_ATT_DOUBLE_WRAP, &
          NF_PUT_ATT_DOUBLE_WRAP_1D
  END INTERFACE

  INTERFACE NF_GET_ATT_WRAP
     MODULE PROCEDURE &
          NF_GET_ATT_TEXT_WRAP, &
          NF_GET_ATT_INT_WRAP, &
          NF_GET_ATT_INT_WRAP_1D, &
          NF_GET_ATT_REAL_WRAP, &
          NF_GET_ATT_REAL_WRAP_1D, &
          NF_GET_ATT_DOUBLE_WRAP, &
          NF_GET_ATT_DOUBLE_WRAP_1D
  END INTERFACE

  !-----------------------------------------------------------------------------
  !   module variables (private)
  !-----------------------------------------------------------------------------

  LOGICAL(KIND=log_kind), PRIVATE, SAVE :: lcall_nf   = .TRUE.
  LOGICAL(KIND=log_kind), PRIVATE, SAVE :: lstop      = .TRUE.
  LOGICAL(KIND=log_kind), PRIVATE, SAVE :: lbroadcast = .TRUE.

  INCLUDE 'netcdf.inc'

  !*****************************************************************************

CONTAINS

  !*****************************************************************************

  SUBROUTINE nf_wrap_put_lcall_nf(STATE)

    LOGICAL(KIND=log_kind), INTENT(IN) :: STATE

    lcall_nf = STATE

  END SUBROUTINE nf_wrap_put_lcall_nf

  !*****************************************************************************

  SUBROUTINE nf_wrap_get_lcall_nf(state)

    LOGICAL(KIND=log_kind), INTENT(OUT) :: state

    state = lcall_nf

  END SUBROUTINE nf_wrap_get_lcall_nf

  !*****************************************************************************

  SUBROUTINE nf_wrap_put_lstop(STATE)

    LOGICAL(KIND=log_kind), INTENT(IN) :: STATE

    lstop = STATE

  END SUBROUTINE nf_wrap_put_lstop

  !*****************************************************************************

  SUBROUTINE nf_wrap_get_lstop(state)

    LOGICAL(KIND=log_kind), INTENT(OUT) :: state

    state = lstop

  END SUBROUTINE nf_wrap_get_lstop

  !*****************************************************************************

  SUBROUTINE nf_wrap_put_lbroadcast(STATE)

    LOGICAL(KIND=log_kind), INTENT(IN) :: STATE

    lbroadcast = STATE

  END SUBROUTINE nf_wrap_put_lbroadcast

  !*****************************************************************************

  SUBROUTINE nf_wrap_get_lbroadcast(state)

    LOGICAL(KIND=log_kind), INTENT(OUT) :: state

    state = lbroadcast

  END SUBROUTINE nf_wrap_get_lbroadcast

  !*****************************************************************************

  LOGICAL(KIND=log_kind) FUNCTION int_is_optional(VAL, OPT)

    INTEGER(KIND=int_kind), INTENT(IN) :: VAL
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: OPT

    IF (PRESENT(OPT)) THEN
       int_is_optional = VAL == OPT
    ELSE
       int_is_optional = .FALSE.
    END IF

  END FUNCTION int_is_optional

  !*****************************************************************************

  SUBROUTINE NF_CREATE_WRAP(PATH, CMODE, ncid, MSG, ALLOW, stat_out)

    CHARACTER(LEN=*), INTENT(IN) :: PATH
    INTEGER(KIND=int_kind), INTENT(IN) :: CMODE
    INTEGER(KIND=int_kind), INTENT(OUT) :: ncid
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_CREATE(PATH, CMODE, ncid)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_CREATE_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_CREATE_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_CREATE_WRAP

  !*****************************************************************************

  SUBROUTINE NF_OPEN_WRAP(PATH, MODE, ncid, MSG, ALLOW, stat_out)

    CHARACTER(LEN=*), INTENT(IN) :: PATH
    INTEGER(KIND=int_kind), INTENT(IN) :: MODE
    INTEGER(KIND=int_kind), INTENT(OUT) :: ncid
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_OPEN(PATH, MODE, ncid)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_OPEN_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_OPEN_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_OPEN_WRAP

  !*****************************************************************************

  SUBROUTINE NF_REDEF_WRAP(NCID, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_REDEF(NCID)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_REDEF_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_REDEF_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_REDEF_WRAP

  !*****************************************************************************

  SUBROUTINE NF_ENDDEF_WRAP(NCID, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_ENDDEF(NCID)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_ENDDEF_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_ENDDEF_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_ENDDEF_WRAP

  !*****************************************************************************

  SUBROUTINE NF_CLOSE_WRAP(NCID, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_CLOSE(NCID)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_CLOSE_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_CLOSE_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_CLOSE_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_WRAP(NCID, ndims, nvars, ngatts, unlimdimid, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    INTEGER(KIND=int_kind), INTENT(OUT) :: ndims, nvars, ngatts, unlimdimid
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ(NCID, ndims, nvars, ngatts, unlimdimid)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_NDIMS_WRAP(NCID, ndims, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    INTEGER(KIND=int_kind), INTENT(OUT) :: ndims
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_NDIMS(NCID, ndims)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_NDIMS_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_NDIMS_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_NDIMS_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_NVARS_WRAP(NCID, nvars, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    INTEGER(KIND=int_kind), INTENT(OUT) :: nvars
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_NVARS(NCID, nvars)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_NVARS_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_NVARS_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_NVARS_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_NATTS_WRAP(NCID, ngatts, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    INTEGER(KIND=int_kind), INTENT(OUT) :: ngatts
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_NATTS(NCID, ngatts)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_NATTS_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_NATTS_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_NATTS_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_UNLIMDIM_WRAP(NCID, unlimdimid, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    INTEGER(KIND=int_kind), INTENT(OUT) :: unlimdimid
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_UNLIMDIM(NCID, unlimdimid)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_UNLIMDIM_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_UNLIMDIM_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_UNLIMDIM_WRAP

  !*****************************************************************************

  SUBROUTINE NF_SYNC_WRAP(NCID, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_SYNC(NCID)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_SYNC_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_SYNC_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_SYNC_WRAP

  !*****************************************************************************

  SUBROUTINE NF_ABORT_WRAP(NCID, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_ABORT(NCID)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_ABORT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_ABORT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_ABORT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_SET_FILL_WRAP(NCID, FILLMODE, old_mode, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, FILLMODE
    INTEGER(KIND=int_kind), INTENT(OUT) :: old_mode
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_SET_FILL(NCID, FILLMODE, old_mode)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_SET_FILL_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_SET_FILL_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_SET_FILL_WRAP

  !*****************************************************************************

  SUBROUTINE NF_DEF_DIM_WRAP(NCID, NAME, LEN, dimid, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: LEN
    INTEGER(KIND=int_kind), INTENT(OUT) :: dimid
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_DEF_DIM(NCID, NAME, LEN, dimid)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_DEF_DIM_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_DEF_DIM_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_DEF_DIM_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_DIMID_WRAP(NCID, NAME, dimid, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(OUT) :: dimid
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_DIMID(NCID, NAME, dimid)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_DIMID_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_DIMID_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_DIMID_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_DIM_WRAP(NCID, DIMID, name, len, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, DIMID
    CHARACTER(LEN=*), INTENT(OUT) :: name
    INTEGER(KIND=int_kind), INTENT(OUT) :: len
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_DIM(NCID, DIMID, name, len)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_DIM_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_DIM_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_DIM_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_DIMNAME_WRAP(NCID, DIMID, name, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, DIMID
    CHARACTER(LEN=*), INTENT(OUT) :: name
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_DIMNAME(NCID, DIMID, name)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_DIMNAME_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_DIMNAME_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_DIMNAME_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_DIMLEN_WRAP(NCID, DIMID, len, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, DIMID
    INTEGER(KIND=int_kind), INTENT(OUT) :: len
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_DIMLEN(NCID, DIMID, len)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_DIMLEN_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_DIMLEN_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_DIMLEN_WRAP

  !*****************************************************************************

  SUBROUTINE NF_RENAME_DIM_WRAP(NCID, DIMID, NAME, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, DIMID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_RENAME_DIM(NCID, DIMID, NAME)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_RENAME_DIM_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_RENAME_DIM_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_RENAME_DIM_WRAP

  !*****************************************************************************

  SUBROUTINE NF_DEF_VAR_WRAP(NCID, NAME, XTYPE, NDIMS, DIMIDS, varid, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: XTYPE, NDIMS
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: DIMIDS
    INTEGER(KIND=int_kind), INTENT(OUT) :: varid
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_DEF_VAR(NCID, NAME, XTYPE, NDIMS, DIMIDS, varid)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_DEF_VAR_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_DEF_VAR_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_DEF_VAR_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_VARID_WRAP(NCID, NAME, varid, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(OUT) :: varid
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_VARID(NCID, NAME, varid)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_VARID_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_VARID_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_VARID_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_VAR_WRAP(NCID, VARID, name, xtype, ndims, dimids, natts, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(OUT) :: name
    INTEGER(KIND=int_kind), INTENT(OUT) :: xtype, ndims
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(OUT) :: dimids
    INTEGER(KIND=int_kind), INTENT(OUT) :: natts
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_VAR(NCID, VARID, name, xtype, ndims, dimids, natts)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_VAR_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_VAR_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_VAR_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_VARNAME_WRAP(NCID, VARID, name, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(OUT) :: name
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_VARNAME(NCID, VARID, name)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_VARNAME_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_VARNAME_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_VARNAME_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_VARTYPE_WRAP(NCID, VARID, xtype, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), INTENT(OUT) :: xtype
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_VARTYPE(NCID, VARID, xtype)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_VARTYPE_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_VARTYPE_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_VARTYPE_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_VARNDIMS_WRAP(NCID, VARID, ndims, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), INTENT(OUT) :: ndims
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_VARNDIMS(NCID, VARID, ndims)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_VARNDIMS_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_VARNDIMS_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_VARNDIMS_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_VARDIMID_WRAP(NCID, VARID, dimids, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(OUT) :: dimids
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_VARDIMID(NCID, VARID, dimids)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_VARDIMID_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_VARDIMID_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_VARDIMID_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_VARNATTS_WRAP(NCID, VARID, natts, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), INTENT(OUT) :: natts
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_VARNATTS(NCID, VARID, natts)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_VARNATTS_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_VARNATTS_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_VARNATTS_WRAP

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_TEXT_WRAP(NCID, VARID, TEXT, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: TEXT
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_TEXT(NCID, VARID, TEXT)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_TEXT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_TEXT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_TEXT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_INT_WRAP_1D(NCID, VARID, IVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: IVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_INT(NCID, VARID, IVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_INT_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_INT_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_INT_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_INT_WRAP_2D(NCID, VARID, IVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:,:), INTENT(IN) :: IVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_INT(NCID, VARID, IVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_INT_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_INT_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_INT_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_INT_WRAP_3D(NCID, VARID, IVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:,:,:), INTENT(IN) :: IVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_INT(NCID, VARID, IVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_INT_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_INT_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_INT_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_INT_WRAP_4D(NCID, VARID, IVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:,:,:,:), INTENT(IN) :: IVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_INT(NCID, VARID, IVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_INT_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_INT_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_INT_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_REAL_WRAP_1D(NCID, VARID, RVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r4), DIMENSION(:), INTENT(IN) :: RVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_REAL(NCID, VARID, RVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_REAL_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_REAL_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_REAL_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_REAL_WRAP_2D(NCID, VARID, RVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r4), DIMENSION(:,:), INTENT(IN) :: RVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_REAL(NCID, VARID, RVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_REAL_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_REAL_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_REAL_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_REAL_WRAP_3D(NCID, VARID, RVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r4), DIMENSION(:,:,:), INTENT(IN) :: RVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_REAL(NCID, VARID, RVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_REAL_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_REAL_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_REAL_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_REAL_WRAP_4D(NCID, VARID, RVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r4), DIMENSION(:,:,:,:), INTENT(IN) :: RVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_REAL(NCID, VARID, RVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_REAL_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_REAL_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_REAL_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_DOUBLE_WRAP_1D(NCID, VARID, DVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r8), DIMENSION(:), INTENT(IN) :: DVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_DOUBLE(NCID, VARID, DVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_DOUBLE_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_DOUBLE_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_DOUBLE_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_DOUBLE_WRAP_2D(NCID, VARID, DVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r8), DIMENSION(:,:), INTENT(IN) :: DVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_DOUBLE(NCID, VARID, DVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_DOUBLE_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_DOUBLE_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_DOUBLE_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_DOUBLE_WRAP_3D(NCID, VARID, DVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r8), DIMENSION(:,:,:), INTENT(IN) :: DVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_DOUBLE(NCID, VARID, DVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_DOUBLE_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_DOUBLE_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_DOUBLE_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VAR_DOUBLE_WRAP_4D(NCID, VARID, DVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r8), DIMENSION(:,:,:,:), INTENT(IN) :: DVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VAR_DOUBLE(NCID, VARID, DVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VAR_DOUBLE_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VAR_DOUBLE_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VAR_DOUBLE_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_TEXT_WRAP(NCID, VARID, START, COUNT, TEXT, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    CHARACTER(LEN=*), INTENT(IN) :: TEXT
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_TEXT(NCID, VARID, START, COUNT, TEXT)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_TEXT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_TEXT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_TEXT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_INT_WRAP_1D(NCID, VARID, START, COUNT, IVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT, IVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_INT(NCID, VARID, START, COUNT, IVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_INT_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_INT_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_INT_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_INT_WRAP_2D(NCID, VARID, START, COUNT, IVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    INTEGER(KIND=int_kind), DIMENSION(:,:), INTENT(IN) :: IVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_INT(NCID, VARID, START, COUNT, IVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_INT_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_INT_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_INT_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_INT_WRAP_3D(NCID, VARID, START, COUNT, IVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    INTEGER(KIND=int_kind), DIMENSION(:,:,:), INTENT(IN) :: IVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_INT(NCID, VARID, START, COUNT, IVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_INT_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_INT_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_INT_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_INT_WRAP_4D(NCID, VARID, START, COUNT, IVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    INTEGER(KIND=int_kind), DIMENSION(:,:,:,:), INTENT(IN) :: IVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_INT(NCID, VARID, START, COUNT, IVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_INT_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_INT_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_INT_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_REAL_WRAP_1D(NCID, VARID, START, COUNT, RVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r4), DIMENSION(:), INTENT(IN) :: RVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_REAL(NCID, VARID, START, COUNT, RVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_REAL_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_REAL_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_REAL_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_REAL_WRAP_2D(NCID, VARID, START, COUNT, RVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r4), DIMENSION(:,:), INTENT(IN) :: RVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_REAL(NCID, VARID, START, COUNT, RVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_REAL_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_REAL_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_REAL_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_REAL_WRAP_3D(NCID, VARID, START, COUNT, RVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r4), DIMENSION(:,:,:), INTENT(IN) :: RVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_REAL(NCID, VARID, START, COUNT, RVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_REAL_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_REAL_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_REAL_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_REAL_WRAP_4D(NCID, VARID, START, COUNT, RVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r4), DIMENSION(:,:,:,:), INTENT(IN) :: RVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_REAL(NCID, VARID, START, COUNT, RVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_REAL_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_REAL_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_REAL_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_DOUBLE_WRAP_1D(NCID, VARID, START, COUNT, DVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r8), DIMENSION(:), INTENT(IN) :: DVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_DOUBLE(NCID, VARID, START, COUNT, DVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_DOUBLE_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_DOUBLE_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_DOUBLE_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_DOUBLE_WRAP_2D(NCID, VARID, START, COUNT, DVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r8), DIMENSION(:,:), INTENT(IN) :: DVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_DOUBLE(NCID, VARID, START, COUNT, DVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_DOUBLE_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_DOUBLE_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_DOUBLE_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_DOUBLE_WRAP_3D(NCID, VARID, START, COUNT, DVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r8), DIMENSION(:,:,:), INTENT(IN) :: DVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_DOUBLE(NCID, VARID, START, COUNT, DVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_DOUBLE_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_DOUBLE_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_DOUBLE_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_PUT_VARA_DOUBLE_WRAP_4D(NCID, VARID, START, COUNT, DVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r8), DIMENSION(:,:,:,:), INTENT(IN) :: DVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_VARA_DOUBLE(NCID, VARID, START, COUNT, DVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_VARA_DOUBLE_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_VARA_DOUBLE_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_VARA_DOUBLE_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_TEXT_WRAP(NCID, VARID, text, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(OUT) :: text
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_TEXT(NCID, VARID, text)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_TEXT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_TEXT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_TEXT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_INT_WRAP_1D(NCID, VARID, ivals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(OUT) :: ivals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_INT(NCID, VARID, ivals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_INT_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_INT_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_INT_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_INT_WRAP_2D(NCID, VARID, ivals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:,:), INTENT(OUT) :: ivals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_INT(NCID, VARID, ivals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_INT_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_INT_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_INT_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_INT_WRAP_3D(NCID, VARID, ivals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:,:,:), INTENT(OUT) :: ivals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_INT(NCID, VARID, ivals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_INT_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_INT_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_INT_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_INT_WRAP_4D(NCID, VARID, ivals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:,:,:,:), INTENT(OUT) :: ivals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_INT(NCID, VARID, ivals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_INT_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_INT_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_INT_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_REAL_WRAP_1D(NCID, VARID, rvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r4), DIMENSION(:), INTENT(OUT) :: rvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_REAL(NCID, VARID, rvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_REAL_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_REAL_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_REAL_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_REAL_WRAP_2D(NCID, VARID, rvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r4), DIMENSION(:,:), INTENT(OUT) :: rvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_REAL(NCID, VARID, rvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_REAL_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_REAL_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_REAL_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_REAL_WRAP_3D(NCID, VARID, rvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r4), DIMENSION(:,:,:), INTENT(OUT) :: rvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_REAL(NCID, VARID, rvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_REAL_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_REAL_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_REAL_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_REAL_WRAP_4D(NCID, VARID, rvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r4), DIMENSION(:,:,:,:), INTENT(OUT) :: rvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_REAL(NCID, VARID, rvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_REAL_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_REAL_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_REAL_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_DOUBLE_WRAP_1D(NCID, VARID, dvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r8), DIMENSION(:), INTENT(OUT) :: dvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_DOUBLE(NCID, VARID, dvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_DOUBLE_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_DOUBLE_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_DOUBLE_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_DOUBLE_WRAP_2D(NCID, VARID, dvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r8), DIMENSION(:,:), INTENT(OUT) :: dvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_DOUBLE(NCID, VARID, dvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_DOUBLE_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_DOUBLE_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_DOUBLE_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_DOUBLE_WRAP_3D(NCID, VARID, dvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r8), DIMENSION(:,:,:), INTENT(OUT) :: dvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_DOUBLE(NCID, VARID, dvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_DOUBLE_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_DOUBLE_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_DOUBLE_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_GET_VAR_DOUBLE_WRAP_4D(NCID, VARID, dvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    REAL(KIND=r8), DIMENSION(:,:,:,:), INTENT(OUT) :: dvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VAR_DOUBLE(NCID, VARID, dvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VAR_DOUBLE_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VAR_DOUBLE_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VAR_DOUBLE_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_TEXT_WRAP(NCID, VARID, START, COUNT, text, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    CHARACTER(LEN=*), INTENT(OUT) :: text
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_TEXT(NCID, VARID, START, COUNT, text)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_TEXT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_TEXT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_TEXT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_INT_WRAP_1D(NCID, VARID, START, COUNT, ivals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(OUT) :: ivals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_INT(NCID, VARID, START, COUNT, ivals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_INT_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_INT_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_INT_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_INT_WRAP_2D(NCID, VARID, START, COUNT, ivals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    INTEGER(KIND=int_kind), DIMENSION(:,:), INTENT(OUT) :: ivals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_INT(NCID, VARID, START, COUNT, ivals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_INT_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_INT_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_INT_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_INT_WRAP_3D(NCID, VARID, START, COUNT, ivals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    INTEGER(KIND=int_kind), DIMENSION(:,:,:), INTENT(OUT) :: ivals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_INT(NCID, VARID, START, COUNT, ivals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_INT_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_INT_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_INT_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_INT_WRAP_4D(NCID, VARID, START, COUNT, ivals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    INTEGER(KIND=int_kind), DIMENSION(:,:,:,:), INTENT(OUT) :: ivals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_INT(NCID, VARID, START, COUNT, ivals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_INT_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_INT_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_INT_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_REAL_WRAP_1D(NCID, VARID, START, COUNT, rvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r4), DIMENSION(:), INTENT(OUT) :: rvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_REAL(NCID, VARID, START, COUNT, rvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_REAL_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_REAL_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_REAL_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_REAL_WRAP_2D(NCID, VARID, START, COUNT, rvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r4), DIMENSION(:,:), INTENT(OUT) :: rvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_REAL(NCID, VARID, START, COUNT, rvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_REAL_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_REAL_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_REAL_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_REAL_WRAP_3D(NCID, VARID, START, COUNT, rvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r4), DIMENSION(:,:,:), INTENT(OUT) :: rvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_REAL(NCID, VARID, START, COUNT, rvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_REAL_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_REAL_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_REAL_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_REAL_WRAP_4D(NCID, VARID, START, COUNT, rvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r4), DIMENSION(:,:,:,:), INTENT(OUT) :: rvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_REAL(NCID, VARID, START, COUNT, rvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_REAL_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_REAL_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_REAL_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_DOUBLE_WRAP_1D(NCID, VARID, START, COUNT, dvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r8), DIMENSION(:), INTENT(OUT) :: dvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_DOUBLE(NCID, VARID, START, COUNT, dvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_DOUBLE_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_DOUBLE_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_DOUBLE_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_DOUBLE_WRAP_2D(NCID, VARID, START, COUNT, dvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r8), DIMENSION(:,:), INTENT(OUT) :: dvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_DOUBLE(NCID, VARID, START, COUNT, dvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_DOUBLE_WRAP_2D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_DOUBLE_WRAP_2D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_DOUBLE_WRAP_2D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_DOUBLE_WRAP_3D(NCID, VARID, START, COUNT, dvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r8), DIMENSION(:,:,:), INTENT(OUT) :: dvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_DOUBLE(NCID, VARID, START, COUNT, dvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_DOUBLE_WRAP_3D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_DOUBLE_WRAP_3D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_DOUBLE_WRAP_3D

  !*****************************************************************************

  SUBROUTINE NF_GET_VARA_DOUBLE_WRAP_4D(NCID, VARID, START, COUNT, dvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: START, COUNT
    REAL(KIND=r8), DIMENSION(:,:,:,:), INTENT(OUT) :: dvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_VARA_DOUBLE(NCID, VARID, START, COUNT, dvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_VARA_DOUBLE_WRAP_4D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_VARA_DOUBLE_WRAP_4D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_VARA_DOUBLE_WRAP_4D

  !*****************************************************************************

  SUBROUTINE NF_RENAME_VAR_WRAP(NCID, VARID, NAME, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_RENAME_VAR(NCID, VARID, NAME)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_RENAME_VAR_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_RENAME_VAR_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_RENAME_VAR_WRAP

  !*****************************************************************************

  SUBROUTINE NF_PUT_ATT_TEXT_WRAP(NCID, VARID, NAME, LEN, TEXT, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: LEN
    CHARACTER(LEN=*), INTENT(IN) :: TEXT
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_ATT_TEXT(NCID, VARID, NAME, LEN, TEXT)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_ATT_TEXT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_ATT_TEXT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_ATT_TEXT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_PUT_ATT_INT_WRAP(NCID, VARID, NAME, XTYPE, LEN, IVAL, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: XTYPE, LEN, IVAL
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_ATT_INT(NCID, VARID, NAME, XTYPE, LEN, IVAL)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_ATT_INT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_ATT_INT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_ATT_INT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_PUT_ATT_INT_WRAP_1D(NCID, VARID, NAME, XTYPE, LEN, IVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: XTYPE, LEN
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(IN) :: IVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_ATT_INT(NCID, VARID, NAME, XTYPE, LEN, IVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_ATT_INT_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_ATT_INT_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_ATT_INT_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_PUT_ATT_REAL_WRAP(NCID, VARID, NAME, XTYPE, LEN, RVAL, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: XTYPE, LEN
    REAL(KIND=r4), INTENT(IN) :: RVAL
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_ATT_REAL(NCID, VARID, NAME, XTYPE, LEN, RVAL)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_ATT_REAL_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_ATT_REAL_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_ATT_REAL_WRAP

  !*****************************************************************************

  SUBROUTINE NF_PUT_ATT_REAL_WRAP_1D(NCID, VARID, NAME, XTYPE, LEN, RVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: XTYPE, LEN
    REAL(KIND=r4), DIMENSION(:), INTENT(IN) :: RVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_ATT_REAL(NCID, VARID, NAME, XTYPE, LEN, RVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_ATT_REAL_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_ATT_REAL_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_ATT_REAL_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_PUT_ATT_DOUBLE_WRAP(NCID, VARID, NAME, XTYPE, LEN, DVAL, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: XTYPE, LEN
    REAL(KIND=r8), INTENT(IN) :: DVAL
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_ATT_DOUBLE(NCID, VARID, NAME, XTYPE, LEN, DVAL)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_ATT_DOUBLE_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_ATT_DOUBLE_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_ATT_DOUBLE_WRAP

  !*****************************************************************************

  SUBROUTINE NF_PUT_ATT_DOUBLE_WRAP_1D(NCID, VARID, NAME, XTYPE, LEN, DVALS, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: XTYPE, LEN
    REAL(KIND=r8), DIMENSION(:), INTENT(IN) :: DVALS
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_PUT_ATT_DOUBLE(NCID, VARID, NAME, XTYPE, LEN, DVALS)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_PUT_ATT_DOUBLE_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_PUT_ATT_DOUBLE_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_PUT_ATT_DOUBLE_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_INQ_ATT_WRAP(NCID, VARID, NAME, xtype, len, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(OUT) :: xtype, len
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_ATT(NCID, VARID, NAME, xtype, len)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_ATT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_ATT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_ATT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_ATTTYPE_WRAP(NCID, VARID, NAME, xtype, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(OUT) :: xtype
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_ATTTYPE(NCID, VARID, NAME, xtype)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_ATTTYPE_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_ATTTYPE_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_ATTTYPE_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_ATTLEN_WRAP(NCID, VARID, NAME, len, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(OUT) :: len
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_ATTLEN(NCID, VARID, NAME, len)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_ATTLEN_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_ATTLEN_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_ATTLEN_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_ATTNAME_WRAP(NCID, VARID, ATTNUM, name, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID, ATTNUM
    CHARACTER(LEN=*), INTENT(OUT) :: name
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_ATTNAME(NCID, VARID, ATTNUM, name)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_ATTNAME_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_ATTNAME_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_ATTNAME_WRAP

  !*****************************************************************************

  SUBROUTINE NF_INQ_ATTID_WRAP(NCID, VARID, NAME, attnum, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(OUT) :: attnum
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_INQ_ATTID(NCID, VARID, NAME, attnum)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_INQ_ATTID_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_INQ_ATTID_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_INQ_ATTID_WRAP

  !*****************************************************************************

  SUBROUTINE NF_GET_ATT_TEXT_WRAP(NCID, VARID, NAME, text, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    CHARACTER(LEN=*), INTENT(OUT) :: text
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_ATT_TEXT(NCID, VARID, NAME, text)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_ATT_TEXT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_ATT_TEXT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_ATT_TEXT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_GET_ATT_INT_WRAP(NCID, VARID, NAME, ival, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(OUT) :: ival
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_ATT_INT(NCID, VARID, NAME, ival)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_ATT_INT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_ATT_INT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_ATT_INT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_GET_ATT_INT_WRAP_1D(NCID, VARID, NAME, ivals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), DIMENSION(:), INTENT(OUT) :: ivals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_ATT_INT(NCID, VARID, NAME, ivals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_ATT_INT_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_ATT_INT_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_ATT_INT_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_GET_ATT_REAL_WRAP(NCID, VARID, NAME, rval, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    REAL(KIND=r4), INTENT(OUT) :: rval
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_ATT_REAL(NCID, VARID, NAME, rval)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_ATT_REAL_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_ATT_REAL_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_ATT_REAL_WRAP

  !*****************************************************************************

  SUBROUTINE NF_GET_ATT_REAL_WRAP_1D(NCID, VARID, NAME, rvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    REAL(KIND=r4), DIMENSION(:), INTENT(OUT) :: rvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_ATT_REAL(NCID, VARID, NAME, rvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_ATT_REAL_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_ATT_REAL_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_ATT_REAL_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_GET_ATT_DOUBLE_WRAP(NCID, VARID, NAME, dval, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    REAL(KIND=r8), INTENT(OUT) :: dval
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_ATT_DOUBLE(NCID, VARID, NAME, dval)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_ATT_DOUBLE_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_ATT_DOUBLE_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_ATT_DOUBLE_WRAP

  !*****************************************************************************

  SUBROUTINE NF_GET_ATT_DOUBLE_WRAP_1D(NCID, VARID, NAME, dvals, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    REAL(KIND=r8), DIMENSION(:), INTENT(OUT) :: dvals
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_GET_ATT_DOUBLE(NCID, VARID, NAME, dvals)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_GET_ATT_DOUBLE_WRAP_1D", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_GET_ATT_DOUBLE_WRAP_1D", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_GET_ATT_DOUBLE_WRAP_1D

  !*****************************************************************************

  SUBROUTINE NF_COPY_ATT_WRAP(NCID_IN, VARID_IN, NAME, NCID_OUT, VARID_OUT, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID_IN, VARID_IN
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    INTEGER(KIND=int_kind), INTENT(IN) :: NCID_OUT, VARID_OUT
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_COPY_ATT(NCID_IN, VARID_IN, NAME, NCID_OUT, VARID_OUT)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_COPY_ATT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_COPY_ATT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_COPY_ATT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_RENAME_ATT_WRAP(NCID, VARID, CURNAME, NEWNAME, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: CURNAME, NEWNAME
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_RENAME_ATT(NCID, VARID, CURNAME, NEWNAME)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_RENAME_ATT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_RENAME_ATT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_RENAME_ATT_WRAP

  !*****************************************************************************

  SUBROUTINE NF_DEL_ATT_WRAP(NCID, VARID, NAME, MSG, ALLOW, stat_out)

    INTEGER(KIND=int_kind), INTENT(IN) :: NCID, VARID
    CHARACTER(LEN=*), INTENT(IN) :: NAME
    CHARACTER(LEN=*), OPTIONAL, INTENT(IN) :: MSG
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(IN) :: ALLOW
    INTEGER(KIND=int_kind), OPTIONAL, INTENT(OUT) :: stat_out

    INTEGER(KIND=int_kind) :: stat

    stat = NF_NOERR
    IF (lcall_nf) stat = NF_DEL_ATT(NCID, VARID, NAME)
    IF (lbroadcast) CALL nf_wrap_broadcast(stat)
    IF (stat /= NF_NOERR .AND. .NOT. int_is_optional(stat, ALLOW)) THEN
       CALL msg_write("NF_DEL_ATT_WRAP", NF_STRERROR(stat))
       IF (PRESENT(MSG)) CALL msg_write("NF_DEL_ATT_WRAP", MSG)
       IF (lstop) CALL nf_wrap_stop
    END IF
    IF (PRESENT(stat_out)) stat_out = stat

  END SUBROUTINE NF_DEL_ATT_WRAP

  !*****************************************************************************

END MODULE nf_wrap
