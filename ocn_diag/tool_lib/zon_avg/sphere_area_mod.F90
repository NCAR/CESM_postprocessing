module sphere_area_mod

  !-----------------------------------------------------------------------------
  !   This module has routines to clip and compute spherical areas of polygons.
  !   It is assumed that the polygon edges are straight lines in lat-lon space.
  !
  !   CVS:$Id: sphere_area_mod.F90,v 1.3 2001/10/15 16:27:15 klindsay Exp $
  !   CVS:$Name:  $
  !   CVS:$Log: sphere_area_mod.F90,v $
  !   CVS:Revision 1.3  2001/10/15 16:27:15  klindsay
  !   CVS:various F90 optimization tricks
  !   CVS:
  !   CVS:Revision 1.2  2001/09/17 22:26:17  klindsay
  !   CVS:changed summation of line integral terms to Kahan summation
  !   CVS:changed dlat,lat_mid,dlon in clip_sphere_area_nonp to degrees from radians
  !   CVS:increaed region where sinc(p5*dlat/180*pi) is replaced with 1 from
  !   CVS:   dlat == 0 to abs(p5*dlat/180*pi) < 1e-10
  !   CVS:added many box intersection test cases
  !   CVS:testing no longer stops on first encountered failure
  !   CVS:
  !   CVS:Revision 1.1  2001/09/15 18:07:08  klindsay
  !   CVS:initial checkin
  !   CVS:
  !-----------------------------------------------------------------------------

  use kinds_mod
  use constants

  implicit none
  private
  public :: &
     clip_sphere_area, &
     contains_np, &
     test_clip_sphere_area, &
     test_contains_np

  contains

  !-----------------------------------------------------------------------------

  real(kind=r8) function clip_sphere_area(cnt, lat, lon, &
       latmin, latmax, lonmin, lonmax, lat_threshold)

     !--------------------------------------------------------------------------
     !   Compute the spherical area of a clipped polygon. This is a wrapper
     !   function. If the input polygon does not contain the North Pole, the
     !   arguments are passed through to clip_sphere_area_nonp. If the input
     !   polygon does contain the North Pole, it is decomposed into convex
     !   quadrilateral pieces that are passed to clip_sphere_area_nonp.
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     integer(kind=int_kind), intent(in) :: &
          cnt                ! size of lat & lon

     real(kind=r8), dimension(cnt), intent(in) :: &
          lat,             & ! latitude of polygon vertices (degrees_north)
          lon                ! longitude of polygon vertices (degrees_east)

     real(kind=r8), intent(in) :: &
          latmin,          & ! minimum clipping latitude (degrees_north)
          latmax,          & ! maximum clipping latitude (degrees_north)
          lonmin,          & ! minimum clipping longitude (degrees_east)
          lonmax             ! maximum clipping longitude (degrees_east)

     real(kind=r8), intent(in), optional :: &
          lat_threshold      ! latitude threshold for short-circuiting
                             ! modulo computations in contains_np (degrees_north)

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     integer(kind=int_kind) :: &
          i, ip1             ! loop index and increment

     real(kind=r8) :: &
          new_lon_min        ! temporary longitude for handling pole polygon

     real(kind=r8), dimension(4) :: &
          tmp_lat,         & ! latitude of polygon piece vertices (degrees_north)
          tmp_lon            ! longitude of polygon piece vertices (degrees_east)

     if (.not. contains_np(cnt, lat, lon, lat_threshold)) then
        clip_sphere_area = clip_sphere_area_nonp(cnt, lat, lon, &
             latmin, latmax, lonmin, lonmax)
     else
        clip_sphere_area = c0
        do i = 1,cnt
           if (i < cnt) then
              ip1 = i + 1
           else
              ip1 = 1
           end if
           tmp_lat = (/ lat(i), lat(ip1),      c90,    c90 /)
           tmp_lon = (/ lon(i), lon(ip1), lon(ip1), lon(i) /)
           if (i == cnt) then
              new_lon_min = lon(i) - c180
              tmp_lon(2:3) = modulo(lon(ip1) - new_lon_min, c360) + new_lon_min
           end if
           clip_sphere_area = clip_sphere_area + &
                clip_sphere_area_nonp(4, tmp_lat, tmp_lon, &
                latmin, latmax, lonmin, lonmax)
        end do
     end if

  end function clip_sphere_area

  !-----------------------------------------------------------------------------

  logical(kind=log_kind) function contains_np(cnt, lat, lon, lat_threshold)

     !--------------------------------------------------------------------------
     !   Determine if the polygon formed by the lat, lon sequence contains
     !   the North Pole.
     !
     !   An initial check is done to see if any of the vertices are north of
     !   80N, or lat_threshold if it is present. If none are, then .false. is
     !   returned without any further computation.
     !
     !   The algorithm for testing pole inclusion is :
     !   Start at second vertex, march around polygon, modifying each vertices
     !   longitude so that it is within 180 degrees of the previous vertex.
     !   If the modified longitude of vertex number cnt differs from the
     !   original longitude of vertex 1, then the pole is in the polygon.
     !   This is indirectly computing the turning angle about the pole.
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     integer(kind=int_kind), intent(in) :: &
          cnt                ! size of lat & lon

     real(kind=r8), dimension(cnt), intent(in) :: &
          lat,             & ! latitude of polygon vertices (degrees_north)
          lon                ! longitude of polygon vertices (degrees_east)

     real(kind=r8), intent(in), optional :: &
          lat_threshold      ! latitude threshold for short-circuiting
                             ! modulo computations (degrees_north)

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     integer(kind=int_kind) :: &
          i                  ! loop index

     real(kind=r8) :: &
          new_lon_min,     & ! minimum allowable lon when matching longitude of
                             ! ith vertex to i-1th vertex
          new_lon,         & ! longitude of ith vertex matched to i-1th vertex
          new_lon_prev       ! longitude of i-1th vertex

     !--------------------------------------------------------------------------
     !   Check to see if any point goes north of lat_threshold.
     !--------------------------------------------------------------------------

     if (present(lat_threshold)) then
        if (maxval(lat) < lat_threshold) then
           contains_np = .false.
           return
        end if
     else
        if (maxval(lat) < 60.0_r8) then
           contains_np = .false.
           return
        end if
     end if

     !--------------------------------------------------------------------------
     !   If one of the vertices is at the North Pole, return .false. .
     !--------------------------------------------------------------------------

     if (any(lat == c90)) then
        contains_np = .false.
        return
     end if

     !--------------------------------------------------------------------------
     !   March around polygon, modifying longitude along the way.
     !   Branch cut goes at new_lon_prev - 180
     !--------------------------------------------------------------------------

     new_lon_prev = lon(1)
     do i = 2,cnt
        new_lon_min = new_lon_prev - c180
        new_lon = modulo(lon(i) - new_lon_min, c360) + new_lon_min
        new_lon_prev = new_lon
     end do
     new_lon_min = new_lon_prev - c180
     new_lon = modulo(lon(1) - new_lon_min, c360) + new_lon_min

     !--------------------------------------------------------------------------
     !   Allow for roundoff differences, don't demand exact equality.
     !--------------------------------------------------------------------------

     contains_np = abs(lon(1) - new_lon) > c1

  end function contains_np

  !-----------------------------------------------------------------------------

  real(kind=r8) function clip_sphere_area_nonp(cnt, lat, lon, &
       latmin, latmax, lonmin, lonmax)

     !--------------------------------------------------------------------------
     !   Compute the spherical area of a clipped polygon.
     !
     !   It is assumed that the North Pole is not in the interior of the polygon.
     !   It is assumed that the polygon is convex.
     !   No assumption is made about the orientation of the vertices.
     !
     !   First the polygon is clipped. This is done by calling clip_poly_halfplane
     !   four times, once for each rectangular boundary. Since each clipping
     !   adds at most 1 vertex, the end clipped polygon has at most in_cnt+4
     !   vertices, where in_cnt in the number of vertices in the original polygon.
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     integer(kind=int_kind), intent(in) :: &
          cnt                ! size of lat & lon

     real(kind=r8), dimension(cnt), intent(in) :: &
          lat,             & ! latitude of polygon vertices (degrees_north)
          lon                ! longitude of polygon vertices (degrees_east)

     real(kind=r8), intent(in) :: &
          latmin,          & ! minimum clipping latitude (degrees_north)
          latmax,          & ! maximum clipping latitude (degrees_north)
          lonmin,          & ! minimum clipping longitude (degrees_east)
          lonmax             ! maximum clipping longitude (degrees_east)

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     real(kind=r8), dimension(cnt+4) :: &
          latA, latB,      & ! latitudes passed to clip_poly_halfplane (degrees_north)
          lonA, lonB         ! longitudes passed from clip_poly_halfplane (degrees_east)

     real(kind=r8) :: &
          p5_dlat,         & ! half of latitude diff between adjacent vertices (degrees)
          dlon,            & ! longitude diff between adjacent vertices (degrees)
          term,c,t,y         ! variables for Kahan summation

     real(kind=r8), parameter :: &
          sixth = c1 / 6.0_r8 ! one-sixth

     integer(kind=int_kind) :: &
          cntA, cntB,      & ! vertex count passed to/from clip_poly_halfplane
          i, ip1             ! loop index and increment

     !--------------------------------------------------------------------------
     !   clip 1, keep latitude >= latmin
     !      i.e. 1 * lat + 0 * lon - latmin >= 0
     !--------------------------------------------------------------------------

     call clip_poly_halfplane(cnt, lat, lon, c1, c0, -latmin, &
          cntA, latA, lonA)

     if (cntA == 0) then
        clip_sphere_area_nonp = c0
        return
     end if

     !--------------------------------------------------------------------------
     !   clip 2, keep latitude <= latmax
     !      i.e. -1 * lat + 0 * lon + latmax >= 0
     !--------------------------------------------------------------------------

     call clip_poly_halfplane(cntA, latA, lonA, -c1, c0, latmax, &
          cntB, latB, lonB)

     if (cntB == 0) then
        clip_sphere_area_nonp = c0
        return
     end if

     !--------------------------------------------------------------------------
     !   clip 3, keep longitude >= lonmin
     !      i.e. 0 * lat + 1 * lon - lonmin >= 0
     !--------------------------------------------------------------------------

     call clip_poly_halfplane(cntB, latB, lonB, c0, c1, -lonmin, &
          cntA, latA, lonA)

     if (cntA == 0) then
        clip_sphere_area_nonp = c0
        return
     end if

     !--------------------------------------------------------------------------
     !   clip 4, keep longitude <= lonmax
     !      i.e. 0 * lat - 1 * lon + lonmax >= 0
     !--------------------------------------------------------------------------

     call clip_poly_halfplane(cntA, latA, lonA, c0, -c1, lonmax, &
          cntB, latB, lonB)

     if (cntB == 0) then
        clip_sphere_area_nonp = c0
        return
     end if

     !--------------------------------------------------------------------------
     !   Compute area of clipped polygon using line integral.
     !   When computing terms, replace sin(x)/x with 1 for abs(x) < 1e-10.
     !   The next term in the Taylor expansion is -1/6 * x**2, which is less
     !   than 1e-20, which can safely be ignored with 8 byte reals.
     !   Use Kahan summation to add up individual terms.
     !   SUM = X(1)
     !   C = 0.0
     !   DO J = 2, N
     !     Y = X(J) - C
     !     T = SUM + Y
     !     C = (T - SUM) - Y
     !     SUM = T
     !   ENDDO
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !  convert lon_out & lat_out to radians
     !--------------------------------------------------------------------------

     lonB(1:cntB) = deg2rad * lonB(1:cntB)
     latB(1:cntB) = deg2rad * latB(1:cntB)

     clip_sphere_area_nonp = c0
     c = c0

     do i = 1,cntB
        if (i < cntB) then
           ip1 = i + 1
        else
           ip1 = 1
        end if
        dlon = lonB(ip1) - lonB(i)

        if (dlon /= c0) then
           p5_dlat = p5 * (latB(ip1) - latB(i))

           if (abs(p5_dlat) < 3.3e-4_r8) then
              term = -dlon * sin(latB(i) + p5_dlat) * (c1 - (p5_dlat)**2 * sixth)
           else
              term = -dlon * sin(latB(i) + p5_dlat) * sin(p5_dlat) / (p5_dlat)
           end if

           y = term - c
           t = clip_sphere_area_nonp + y
           c = (t - clip_sphere_area_nonp) - y
           clip_sphere_area_nonp = t
        end if
     end do

     !--------------------------------------------------------------------------
     !   Ensure non-negativity of result, e.g. if polygon is oriented clockwise.
     !--------------------------------------------------------------------------

     clip_sphere_area_nonp = abs(clip_sphere_area_nonp)

  end function clip_sphere_area_nonp

  !-----------------------------------------------------------------------------

  subroutine clip_poly_halfplane(cnt_in, lat_in, lon_in, lat_coeff, lon_coeff, &
       const_coeff, cnt_out, lat_out, lon_out)

     !--------------------------------------------------------------------------
     !   Clip a polygon with respect to a half-plane in lat-lon space. The half-
     !   plane to be included is described by
     !      lat_coeff * lat + lon_coeff * lon + const_coeff >= 0
     !
     !   It is assumed that the North Pole is not in the interior of the polygon.
     !   It is assumed that the polygon is convex.
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     integer(kind=int_kind), intent(in) :: &
          cnt_in             ! number of incoming polygon vertices

     real(kind=r8), dimension(cnt_in), intent(in) :: &
          lat_in,          & ! latitude of incoming polygon vertices (degrees_north)
          lon_in             ! longitude of incoming polygon vertices (degrees_east)

     real(kind=r8), intent(in) :: &
          lat_coeff,       & ! latitude coefficient of half-plane equation
          lon_coeff,       & ! longitude coefficient of half-plane equation
          const_coeff        ! constant coefficient of half-plane equation

     integer(kind=int_kind), intent(out) :: &
          cnt_out            ! number of outgoing polygon vertices

     real(kind=r8), dimension(*), intent(out) :: &
          lat_out,         & ! latitude of outgoing polygon vertices (degrees_north)
          lon_out            ! longitude of outgoing polygon vertices (degrees_east)

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     real(kind=r8) :: &
          eqn_val,         & ! evaluation of affine equation at ith vertex
          eqn_val_next,    & ! evaluation of affine equation at (i+1)th vertex
          max_eqn_val,     & ! max value of affine equation over all vertices
          eqn_val_i1,      & ! value of affine equation over all vertices at i=1
          lat_const,       & ! latitude value when lon_coeff == c0
          lon_const,       & ! longitude value when lat_coeff == c0
          s                  ! parameterized location where current edge
                             ! crosses halfplane boundary

     integer(kind=int_kind) :: &
          i, ip1             ! loop index and increment

     !--------------------------------------------------------------------------

     if (lon_coeff == c0) then
        lat_const = -const_coeff / lat_coeff

        eqn_val_i1 = lat_coeff * lat_in(1) + const_coeff
        max_eqn_val = eqn_val_i1
        eqn_val_next = eqn_val_i1
        cnt_out = 0

        do i = 1,cnt_in
           eqn_val = eqn_val_next

           if (eqn_val >= c0) then
              cnt_out = cnt_out + 1
              lat_out(cnt_out) = lat_in(i)
              lon_out(cnt_out) = lon_in(i)
           end if

           if (i < cnt_in) then
              ip1 = i + 1
              eqn_val_next = lat_coeff * lat_in(ip1) + const_coeff
              if (eqn_val_next > max_eqn_val) max_eqn_val = eqn_val_next
           else
              ip1 = 1
              eqn_val_next = eqn_val_i1
           end if

           if (((eqn_val < c0) .and. (eqn_val_next > c0)) .or. &
                ((eqn_val > c0) .and. (eqn_val_next < c0))) then

              s = eqn_val / (eqn_val - eqn_val_next)

              cnt_out = cnt_out + 1
              lat_out(cnt_out) = lat_const
              lon_out(cnt_out) = lon_in(i) + s * (lon_in(ip1) - lon_in(i))
           end if
        end do
     else if (lat_coeff == c0) then
        lon_const = -const_coeff / lon_coeff

        eqn_val_i1 = lon_coeff * lon_in(1) + const_coeff
        max_eqn_val = eqn_val_i1
        eqn_val_next = eqn_val_i1
        cnt_out = 0

        do i = 1,cnt_in
           eqn_val = eqn_val_next

           if (eqn_val >= c0) then
              cnt_out = cnt_out + 1
              lat_out(cnt_out) = lat_in(i)
              lon_out(cnt_out) = lon_in(i)
           end if

           if (i < cnt_in) then
              ip1 = i + 1
              eqn_val_next = lon_coeff * lon_in(ip1) + const_coeff
              if (eqn_val_next > max_eqn_val) max_eqn_val = eqn_val_next
           else
              ip1 = 1
              eqn_val_next = eqn_val_i1
           end if

           if (((eqn_val < c0) .and. (eqn_val_next > c0)) .or. &
                ((eqn_val > c0) .and. (eqn_val_next < c0))) then

              s = eqn_val / (eqn_val - eqn_val_next)

              cnt_out = cnt_out + 1
              lat_out(cnt_out) = lat_in(i) + s * (lat_in(ip1) - lat_in(i))
              lon_out(cnt_out) = lon_const
           end if
        end do
     else
        eqn_val_i1 = lat_coeff * lat_in(1) + lon_coeff * lon_in(1) + const_coeff
        max_eqn_val = eqn_val_i1
        eqn_val_next = eqn_val_i1
        cnt_out = 0

        do i = 1,cnt_in
           eqn_val = eqn_val_next

           if (eqn_val >= c0) then
              cnt_out = cnt_out + 1
              lat_out(cnt_out) = lat_in(i)
              lon_out(cnt_out) = lon_in(i)
           end if

           if (i < cnt_in) then
              ip1 = i + 1
              eqn_val_next = lat_coeff * lat_in(ip1) + lon_coeff * lon_in(ip1) + &
                   const_coeff
              if (eqn_val_next > max_eqn_val) max_eqn_val = eqn_val_next
           else
              ip1 = 1
              eqn_val_next = eqn_val_i1
           end if

           if (((eqn_val < c0) .and. (eqn_val_next > c0)) .or. &
                ((eqn_val > c0) .and. (eqn_val_next < c0))) then

              s = eqn_val / (eqn_val - eqn_val_next)

              cnt_out = cnt_out + 1
              lat_out(cnt_out) = lat_in(i) + s * (lat_in(ip1) - lat_in(i))
              lon_out(cnt_out) = lon_in(i) + s * (lon_in(ip1) - lon_in(i))
           end if
        end do
     end if

     if (max_eqn_val <= c0) cnt_out = 0

  end subroutine clip_poly_halfplane

  !-----------------------------------------------------------------------------

  subroutine test_contains_np

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     real(kind=r8), dimension(4) :: &
          lat4,            & ! latitude of polygon vertices (degrees_north)
          lon4               ! longitude of polygon vertices (degrees_east)

     integer(kind=int_kind) :: &
          i,j                ! loop indices

     logical(kind=log_kind) :: &
          pass = .true.      ! were all tests passed

     do j = 0,8
        do i = -10,10
           lat4 = c10 * j + (/ 3.0, 5.0, 7.0, 5.0 /)
           lon4 = c2 * c10 * i + (/ 1.0, 3.0, 1.0, -3.0 /)
           if (contains_np(4, lat4, lon4)) then
              write(stdout,fmt='(A)') 'test_contains_np : unexpected answer'
              write(stdout,*) 'lat = ', lat4
              write(stdout,*) 'lon = ', lon4
              pass = .false.
           end if

           lat4 = c10 * j + (/ 3.0, 5.0, 7.0, 5.0 /)
           lon4 = c2 * c10 * i + (/ 1.0, -3.0, 1.0, 3.0 /)
           if (contains_np(4, lat4, lon4)) then
              write(stdout,fmt='(A)') 'test_contains_np : unexpected answer'
              write(stdout,*) 'lat = ', lat4
              write(stdout,*) 'lon = ', lon4
              pass = .false.
           end if

           lat4 = j + (/ 80.3, 80.5, 80.7, 80.5 /)
           lon4 = c2 * c10 * i + (/ 240.0, 160.0, 80.0, 0.0 /)
           if (.not. contains_np(4, lat4, lon4)) then
              write(stdout,fmt='(A)') 'test_contains_np : unexpected answer'
              write(stdout,*) 'lat = ', lat4
              write(stdout,*) 'lon = ', lon4
              pass = .false.
           end if

           lat4 = j + (/ 80.3, 80.5, 80.7, 80.5 /)
           lon4 = c2 * c10 * i + (/ 0.0, 80.0, 160.0, 240.0 /)
           if (.not. contains_np(4, lat4, lon4)) then
              write(stdout,fmt='(A)') 'test_contains_np : unexpected answer'
              write(stdout,*) 'lat = ', lat4
              write(stdout,*) 'lon = ', lon4
              pass = .false.
           end if
        end do
     end do

     if (.not. pass) stop

     write(stdout,fmt='(A)') 'test_contains_np : OK'

  end subroutine test_contains_np

  !-----------------------------------------------------------------------------

  subroutine test_clip_sphere_area

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     real(kind=r8), dimension(4) :: &
          lat4,            & ! latitude of polygon vertices (degrees_north)
          lon4               ! longitude of polygon vertices (degrees_east)

     real(kind=r8), dimension(3) :: &
          lat3,            & ! latitude of polygon vertices (degrees_north)
          lon3               ! longitude of polygon vertices (degrees_east)

     real(kind=r8) :: &
          lon_mid, dlon,   & ! longitude midpoint and delta
          lat_mid, dlat,   & ! latitude midpoint and delta
          ans_exp,         & ! expected answer
          ans_act,         & ! actual answer
          eps,             & ! allowable relative tolerance
          latmin, latmax,  & ! latitude bounds for clipping
          lonmin, lonmax     ! longitude bounds for clipping

     integer(kind=int_kind) :: &
          j,j_2,i_1,i_2      ! loop indices

     logical(kind=log_kind) :: &
          pass = .true.      ! were all tests passed

     !--------------------------------------------------------------------------

     eps = 1.0e-12_r8

     do j = 0,8
        do i_1 = -10,10
           dlat = real(j,r8) + c1
           lat4 = c10 * j + (/ c0, c0, dlat, dlat /)
           lat_mid = lat4(1) + p5 * dlat

           dlon = real(i_1,r8) + c10 + c10
           lon4 = c2 * c10 * i_1 + (/ c0, dlon, dlon, c0 /)
           lon_mid = lon4(1) + p5 * dlon

           ans_exp = c2 * deg2rad * dlon * cos(deg2rad * lat_mid) * &
                sin(p5 * deg2rad * dlat)

           ans_act = clip_sphere_area(4, lat4, lon4, -c90, c90, -c2*c360, c2*c360)
           if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
              write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 1'
              write(stdout,*) 'lat     = ', lat4
              write(stdout,*) 'lon     = ', lon4
              write(stdout,*) 'ans_exp = ', ans_exp
              write(stdout,*) 'ans_act = ', ans_act
              pass = .false.
           end if

           ans_act = &
                clip_sphere_area(4, lat4, lon4, -c90, lat_mid, -c2*c360, c2*c360) + &
                clip_sphere_area(4, lat4, lon4, lat_mid, c90, -c2*c360, c2*c360)
           if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
              write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 2'
              write(stdout,*) 'lat     = ', lat4
              write(stdout,*) 'lon     = ', lon4
              write(stdout,*) 'lat_mid = ', lat_mid
              write(stdout,*) 'ans_exp = ', ans_exp
              write(stdout,*) 'ans_act = ', ans_act
              pass = .false.
           end if

           ans_act = &
                clip_sphere_area(4, lat4, lon4, -c90, c90, -c2*c360, lon_mid) + &
                clip_sphere_area(4, lat4, lon4, -c90, c90, lon_mid, c2*c360)
           if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
              write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 3'
              write(stdout,*) 'lat     = ', lat4
              write(stdout,*) 'lon     = ', lon4
              write(stdout,*) 'lon_mid = ', lon_mid
              write(stdout,*) 'ans_exp = ', ans_exp
              write(stdout,*) 'ans_act = ', ans_act
              pass = .false.
           end if

           ans_act = &
                clip_sphere_area(4, lat4, lon4, -c90, lat_mid, -c2*c360, lon_mid) + &
                clip_sphere_area(4, lat4, lon4, -c90, lat_mid, lon_mid, c2*c360) + &
                clip_sphere_area(4, lat4, lon4, lat_mid, c90, -c2*c360, lon_mid) + &
                clip_sphere_area(4, lat4, lon4, lat_mid, c90, lon_mid, c2*c360)
           if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
              write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 4'
              write(stdout,*) 'lat     = ', lat4
              write(stdout,*) 'lon     = ', lon4
              write(stdout,*) 'lat_mid = ', lat_mid
              write(stdout,*) 'lon_mid = ', lon_mid
              write(stdout,*) 'ans_exp = ', ans_exp
              write(stdout,*) 'ans_act = ', ans_act
              pass = .false.
           end if

           do i_2 = -11,11
              dlat = real(j,r8) + c1
              lat3 = c10 * j + (/ c0, c0, dlat /)
              lat_mid = lat3(1) + p5 * dlat

              dlon = real(i_1,r8) + c10 + c1
              lon3 = c2 * c10 * i_1 + (/ -dlon, dlon, real(i_2,r8) /)
              lon_mid = lon3(1) + dlon

              ans_exp = (c2 * deg2rad * dlon) * (sin(deg2rad * lat3(1)) * &
                   (sin(deg2rad * dlat) / (deg2rad * dlat) - c1) + cos(deg2rad * lat3(1)) * &
                   sin(p5 * deg2rad * dlat) ** 2 / (p5 * deg2rad * dlat))

              ans_exp = (c2 * deg2rad * dlon) * (sin(deg2rad * lat_mid) * &
                   sin(p5 * deg2rad * dlat) / (p5 * deg2rad * dlat) - &
                   sin(deg2rad * lat3(1)))

              ans_act = clip_sphere_area(3, lat3, lon3, -c90, c90, -c2*c360, c2*c360)
              if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
                 write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 5'
                 write(stdout,*) 'lat     = ', lat3
                 write(stdout,*) 'lon     = ', lon3
                 write(stdout,*) 'ans_exp = ', ans_exp
                 write(stdout,*) 'ans_act = ', ans_act
                 pass = .false.
              end if

              ans_act = &
                   clip_sphere_area(3, lat3, lon3, -c90, lat_mid, -c2*c360, c2*c360) + &
                   clip_sphere_area(3, lat3, lon3, lat_mid, c90, -c2*c360, c2*c360)
              if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
                 write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 6'
                 write(stdout,*) 'lat     = ', lat3
                 write(stdout,*) 'lon     = ', lon3
                 write(stdout,*) 'lat_mid = ', lat_mid
                 write(stdout,*) 'ans_exp = ', ans_exp
                 write(stdout,*) 'ans_act = ', ans_act
                 pass = .false.
              end if

              ans_act = &
                   clip_sphere_area(3, lat3, lon3, -c90, c90, -c2*c360, lon_mid) + &
                   clip_sphere_area(3, lat3, lon3, -c90, c90, lon_mid, c2*c360)
              if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
                 write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 7'
                 write(stdout,*) 'lat     = ', lat3
                 write(stdout,*) 'lon     = ', lon3
                 write(stdout,*) 'lon_mid = ', lon_mid
                 write(stdout,*) 'ans_exp = ', ans_exp
                 write(stdout,*) 'ans_act = ', ans_act
                 pass = .false.
              end if

              ans_act = &
                   clip_sphere_area(3, lat3, lon3, -c90, lat_mid, -c2*c360, lon_mid) + &
                   clip_sphere_area(3, lat3, lon3, lat_mid, c90, -c2*c360, lon_mid) + &
                   clip_sphere_area(3, lat3, lon3, -c90, lat_mid, lon_mid, c2*c360) + &
                   clip_sphere_area(3, lat3, lon3, lat_mid, c90, lon_mid, c2*c360)
              if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
                 write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 8'
                 write(stdout,*) 'lat     = ', lat3
                 write(stdout,*) 'lon     = ', lon3
                 write(stdout,*) 'lat_mid = ', lat_mid
                 write(stdout,*) 'lon_mid = ', lon_mid
                 write(stdout,*) 'ans_exp = ', ans_exp
                 write(stdout,*) 'ans_act = ', ans_act
                 pass = .false.
              end if

           end do
        end do

        lat4 = 75.0
        lon4 = (/ 0.0, 90.0, 180.0, 270.0 /)

        ans_exp = c4 * pi * sin(p5 * deg2rad * j) ** 2

        ans_act = clip_sphere_area(4, lat4, lon4, c90-j, c90, -c2*c360, c2*c360)
        if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
           write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 9'
           write(stdout,*) 'lat     = ', lat4
           write(stdout,*) 'lon     = ', lon4
           write(stdout,*) '90-j    = ', c90-j
           write(stdout,*) 'ans_exp = ', ans_exp
           write(stdout,*) 'ans_act = ', ans_act
           pass = .false.
        end if
     end do

     do j=-5,5
        do i_1=-5,5
           lat4 = (/ c10*j, c10*j, c10*j + (j+c10), c10*j + (j+c10) /)
           lon4 = (/ c10*i_1, c10*i_1 + (i_1+c10), c10*i_1 + (i_1+c10), c10*i_1 /)

           do j_2 = 1,31
              do i_2 = 1,31
                 call gen_test_lims(j_2, lat4(1), lat4(3), latmin, latmax)
                 call gen_test_lims(i_2, lon4(1), lon4(3), lonmin, lonmax)

                 if (latmin >= latmax .or. &
                      latmin >= lat4(3) .or. &
                      latmax <= lat4(1) .or. &
                      lonmin >= lonmax .or. &
                      lonmin >= lon4(3) .or. &
                      lonmax <= lon4(1)) then
                    ans_exp = c0
                 else
                    dlat = min(lat4(3),latmax) - max(lat4(1),latmin)
                    lat_mid = max(lat4(1),latmin) + p5 * dlat
                    dlon = min(lon4(3),lonmax) - max(lon4(1),lonmin)
                    ans_exp = c2 * deg2rad * dlon * cos(deg2rad * lat_mid) * &
                         sin(p5 * deg2rad * dlat)
                 end if

                 ans_act = clip_sphere_area(4, lat4, lon4, latmin, latmax, lonmin, lonmax)
                 if (abs(ans_exp - ans_act) > eps * max(abs(ans_exp), abs(ans_act))) then
                    write(stdout,fmt='(A)') 'test_clip_sphere_area : unexpected answer, test 10'
                    write(stdout,*) 'lat     = ', lat4
                    write(stdout,*) 'lon     = ', lon4
                    write(stdout,*) 'j_2     = ', j_2
                    write(stdout,*) 'i_2     = ', i_2
                    write(stdout,*) 'dlat    = ', dlat
                    write(stdout,*) 'lat_mid = ', lat_mid
                    write(stdout,*) 'dlon    = ', dlon
                    write(stdout,*) 'latmin  = ', latmin
                    write(stdout,*) 'latmax  = ', latmax
                    write(stdout,*) 'lonmin  = ', lonmin
                    write(stdout,*) 'lonmax  = ', lonmax
                    write(stdout,*) 'ans_exp = ', ans_exp
                    write(stdout,*) 'ans_act = ', ans_act
                 end if
              end do
           end do
        end do
     end do

     if (.not. pass) stop

     write(stdout,fmt='(A)') 'test_clip_sphere_area : OK'

  end subroutine test_clip_sphere_area

  !-----------------------------------------------------------------------------

  subroutine gen_test_lims(ind, coord0, coord1, coordmin, coordmax)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     integer(kind=int_kind), intent(in) :: &
          ind                ! which case is this

     real(kind=r8), intent(in) :: &
          coord0,          & ! starting input coordinate (degrees)
          coord1             ! ending input coordinate (degrees)

     real(kind=r8), intent(out) :: &
          coordmin,        & ! generated coordmin (degrees)
          coordmax           ! generated coordmax (degrees)

     !--------------------------------------------------------------------------

     select case (ind)
        case (1)
           coordmin = coord0 - c1
           coordmax = coord0 - c2
        case (2)
           coordmin = coord0 - c1
           coordmax = coord0 - c1
        case (3)
           coordmin = coord0 - c1
           coordmax = coord0
        case (4)
           coordmin = coord0 - c1
           coordmax = coord0 - p5
        case (5)
           coordmin = coord0 - c1
           coordmax = coord0 + p5 * (coord1 - coord0)
        case (6)
           coordmin = coord0 - c1
           coordmax = coord1
        case (7)
           coordmin = coord0 - c1
           coordmax = coord1 + c1
        case (8)
           coordmin = coord0
           coordmax = coord0 - c1
        case (9)
           coordmin = coord0
           coordmax = coord0
        case (10)
           coordmin = coord0
           coordmax = coord0 + p5 * (coord1 - coord0)
        case (11)
           coordmin = coord0
           coordmax = coord1
        case (12)
           coordmin = coord0
           coordmax = coord1 + c1
        case (13)
           coordmin = coord0 + p5 * (coord1 - coord0)
           coordmax = coord0 - c1
        case (14)
           coordmin = coord0 + p5 * (coord1 - coord0)
           coordmax = coord0
        case (15)
           coordmin = coord0 + p5 * (coord1 - coord0)
           coordmax = coord0 + p25 * (coord1 - coord0)
        case (16)
           coordmin = coord0 + p5 * (coord1 - coord0)
           coordmax = coord0 + p5 * (coord1 - coord0)
        case (17)
           coordmin = coord0 + p5 * (coord1 - coord0)
           coordmax = coord0 + (p5+p25) * (coord1 - coord0)
        case (18)
           coordmin = coord0 + p5 * (coord1 - coord0)
           coordmax = coord1
        case (19)
           coordmin = coord0 + p5 * (coord1 - coord0)
           coordmax = coord1 + c1
        case (20)
           coordmin = coord1
           coordmax = coord0 - c1
        case (21)
           coordmin = coord1
           coordmax = coord0
        case (22)
           coordmin = coord1
           coordmax = coord0 + p5 * (coord1 - coord0)
        case (23)
           coordmin = coord1
           coordmax = coord1
        case (24)
           coordmin = coord1
           coordmax = coord1 + c1
        case (25)
           coordmin = coord1 + c1
           coordmax = coord0 - c1
        case (26)
           coordmin = coord1 + c1
           coordmax = coord0
        case (27)
           coordmin = coord1 + c1
           coordmax = coord0 + p5 * (coord1 - coord0)
        case (28)
           coordmin = coord1 + c1
           coordmax = coord1
        case (29)
           coordmin = coord1 + c1
           coordmax = coord0 + p5
        case (30)
           coordmin = coord1 + c1
           coordmax = coord1 + c1
        case (31)
           coordmin = coord1 + c1
           coordmax = coord1 + c2
     end select

  end subroutine gen_test_lims

  !-----------------------------------------------------------------------------

end module sphere_area_mod
