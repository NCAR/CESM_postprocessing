C Scrip/remap code modified for wrapping in Python with f2py
C Ivan Lima - Fri Jan  9 11:55:37 EST 2009
C modified by Keith Lindsay Thu Dec  6 15:16:35 MST 2012 to normalize DST_ARRAY by MAP_WTS_LOC_SUM
C
C NCLFORTSTART
      SUBROUTINE DPOPREMAP(DST_ARRAY,MAP_WTS,DST_ADD,SRC_ADD,SRC_ARRAY,
     +                     NDST,NLINK,NW,NSRC,XMSG)

c written in f77 for the GNU f77 compiler for portability reasons
c Compiled in NCAR DASG (i.e., GLADE) machines with the following statement:
c   f2py -c --fcompiler=gfortran --f77exec=/usr/bin/gfortran -m remap remap.f

      IMPLICIT NONE
      INTEGER NLINK,NW,NDST,NSRC
      DOUBLE PRECISION MAP_WTS(NW,NLINK)
      DOUBLE PRECISION DST_ARRAY(NDST)
      DOUBLE PRECISION SRC_ARRAY(NSRC)
      INTEGER DST_ADD(NLINK)
      INTEGER SRC_ADD(NLINK)
      DOUBLE PRECISION XMSG
C
Cf2py intent(in) NLINK,NW,NDST,NSRC
Cf2py intent(in) MAP_WTS, SRC_ARRAY
Cf2py intent(in) DST_ADD,SRC_ADD
Cf2py intent(in) XMSG
Cf2py intent(out) DST_ARRAY
Cf2py depend(NW) MAP_WTS
Cf2py depend(NLINK) MAP_WTS
Cf2py depend(NDST) DST_ARRAY
Cf2py depend(NSRC) SRC_ARRAY
Cf2py depend(NLINK) DST_ADD
Cf2py depend(NLINK) SRC_ADD
C
C NCLEND
      INTEGER N,M
      DOUBLE PRECISION MAP_WTS_LOC_SUM

      DO N = 1,NDST
c initialize
          DST_ARRAY(N) = XMSG
      END DO

      DO N = 1,NLINK
          IF (SRC_ARRAY(1+SRC_ADD(N)).NE.XMSG) THEN
              IF (DST_ARRAY(DST_ADD(N)).EQ.XMSG) THEN
                  DST_ARRAY(DST_ADD(N)) = SRC_ARRAY(1+SRC_ADD(N))*
     +                                    MAP_WTS(1,N)
              ELSE
                  DST_ARRAY(DST_ADD(N)) = DST_ARRAY(DST_ADD(N)) +
     +                                    SRC_ARRAY(1+SRC_ADD(N))*
     +                                    MAP_WTS(1,N)
              END IF
          END IF
      END DO

C Normalize to account for differences in missing value
C pattern from that used when map_wts was generated.
      DO M = 1,NDST
          IF (DST_ARRAY(M).NE.XMSG) THEN
              MAP_WTS_LOC_SUM = 0.0
              DO N = 1,NLINK
                  IF ((DST_ADD(N).EQ.M).AND.
     +                (SRC_ARRAY(1+SRC_ADD(N)).NE.XMSG)) THEN
                      MAP_WTS_LOC_SUM = MAP_WTS_LOC_SUM+MAP_WTS(1,N)
                  END IF
              END DO
              DST_ARRAY(M) = DST_ARRAY(M)/MAP_WTS_LOC_SUM
          END IF
      END DO

      RETURN
      END
