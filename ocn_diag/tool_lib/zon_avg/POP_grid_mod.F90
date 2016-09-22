module POP_grid_mod

  !-----------------------------------------------------------------------------
  !   This module has data structures to represent POP grids and to read them
  !   from NetCDF files.
  !
  !   Assumes that the coordinates of the tracer points are (TLONG,TLAT).
  !   Assumes that the coordinates of the velocity points are (ULONG,ULAT).
  !   The assumptions are localized via use of the string parameters :
  !   TLONG_name, TLAT_name, ULONG_name, and ULAT_name.
  !
  !   CVS:$Id: POP_grid_mod.F90,v 1.6 2003/12/03 20:45:03 klindsay Exp $
  !   CVS:$Name:  $
  !   CVS:$Log: POP_grid_mod.F90,v $
  !   CVS:Revision 1.6  2003/12/03 20:45:03  klindsay
  !   CVS:Allow for one extra singleton dimension on grid variables.
  !   CVS:
  !   CVS:Revision 1.5  2003/11/25 23:48:30  klindsay
  !   CVS:Allow number of detected cells containing NP to be zero.
  !   CVS:
  !   CVS:Revision 1.4  2002/02/07 05:05:34  klindsay
  !   CVS:Add TAREA & UAREA back to file.
  !   CVS:This is to enable area-weighted sums, as opposed to area-weighted averages.
  !   CVS:This feature is to be added soon.
  !   CVS:
  !   CVS:Revision 1.3  2002/02/06 22:20:32  klindsay
  !   CVS:fix bug in computation of grid_var%tvert_lonmax, found by Steve Yeager
  !   CVS:
  !   CVS:Revision 1.2  2001/11/21 19:46:43  klindsay
  !   CVS:Remove reading of TAREA & UAREA from grid file,
  !   CVS:as they were not being used.
  !   CVS:
  !   CVS:Revision 1.1  2001/10/15 17:37:54  klindsay
  !   CVS:initial checkin
  !   CVS:
  !-----------------------------------------------------------------------------

  use kinds_mod
  use constants
  use nf_wrap
  use sphere_area_mod

  implicit none
  private
  public :: &
     POP_grid, &
     read_POP_grid_NetCDF, &
     free_POP_grid, &
     gen_Tcell_vertices, &
     read_rmask, &
     TLONG_name, &
     TLAT_name

  type POP_grid
     real(kind=r8), dimension(:,:), pointer :: &
          tlong, tlat,     & ! horizontal location of tracer points
          ulong, ulat,     & ! horizontal location of velocity points
          tarea, uarea       ! areas of tracer & velocity cells respectively

     integer(kind=int_kind), dimension(:,:), pointer :: &
          kmt                ! topography field (at tracer points)

     real(kind=r8) :: &
          lat_threshold,   & ! latitude threshold passed to clip_sphere_area
          tvert_latmin,    & ! minimum latitude for T cell vertices
          tvert_latmax,    & ! maximum latitude for T cell vertices
          tvert_lonmin,    & ! minimum longitude for T cell vertices
          tvert_lonmax       ! maximum longitude for T cell vertices

     integer(kind=int_kind) :: km, nlon, nlat, pole_i, pole_j

  end type POP_grid

  character(len=*), parameter :: &
     TLONG_name = 'TLONG', &
     TLAT_name  = 'TLAT', &
     ULONG_name = 'ULONG', &
     ULAT_name  = 'ULAT', &
     TAREA_name = 'TAREA', &
     UAREA_name = 'UAREA', &
     KMT_name   = 'KMT'

  contains

  !-----------------------------------------------------------------------------

  subroutine read_POP_grid_NetCDF(filename, filename_KMT, grid_var)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     character(len=char_len), intent(in) :: &
          filename,        & ! file containing non-KMT grid vars
          filename_KMT       ! file containing KMT

     type(POP_grid), intent(out) :: &
          grid_var           ! where to store grid information

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     character(len=*), parameter :: &
          subname = 'POP_grid_mod:read_POP_grid_NetCDF'

     integer(kind=int_kind) :: &
          ncid,            & ! file ID
          ncid_KMT,        & ! file ID for KMT
          varid,           & ! variable ID
          ndims,           & ! number of dimensions for variable varid
          dimids(3),       & ! dimension IDs for variable varid
          dimlen             ! dimlen for extra dimension

     logical(kind=log_kind) :: &
          lExtraSingletonDim ! is there one extra singleton dimension

     !--------------------------------------------------------------------------

     call nf_open_wrap(filename, 0, ncid, subname)
     call nf_open_wrap(filename_KMT, 0, ncid_KMT, subname)

     !--------------------------------------------------------------------------
     !   ensure that horizontal variables exist & have the same size
     !   allowing for one extra singleton dimension
     !--------------------------------------------------------------------------

     call nf_inq_varid_wrap(ncid, TLONG_name, varid, subname)
     call nf_inq_varndims_wrap(ncid, varid, ndims, subname)

     if (ndims /= 2) then
        if (ndims == 3) then
           call nf_inq_vardimid_wrap(ncid, varid, dimids, subname)
           call nf_inq_dimlen_wrap(ncid, dimids(3), dimlen, subname)
           lExtraSingletonDim = (dimlen == 1)
        else
           lExtraSingletonDim = .false.
        end if
        if (.not. lExtraSingletonDim) then
           call msg_write(subname, 'unexpected ndims for ' // TLONG_name, ndims)
           stop
        end if
     else
        call nf_inq_vardimid_wrap(ncid, varid, dimids, subname)
     end if

     call nf_inq_dimlen_wrap(ncid, dimids(1), grid_var%nlon, subname)
     call nf_inq_dimlen_wrap(ncid, dimids(2), grid_var%nlat, subname)

     call check_var_size(ncid, TLAT_name, 2, (/ grid_var%nlon, grid_var%nlat /))

     call check_var_size(ncid, ULONG_name, 2, (/ grid_var%nlon, grid_var%nlat /))

     call check_var_size(ncid, ULAT_name, 2, (/ grid_var%nlon, grid_var%nlat /))

     call check_var_size(ncid, TAREA_name, 2, (/ grid_var%nlon, grid_var%nlat /))

     call check_var_size(ncid, UAREA_name, 2, (/ grid_var%nlon, grid_var%nlat /))

     call check_var_size(ncid_KMT, KMT_name, 2, (/ grid_var%nlon, grid_var%nlat /))

     !--------------------------------------------------------------------------
     !   allocate memory for all grid variables & read them in
     !--------------------------------------------------------------------------

     allocate( &
          grid_var%tlong(grid_var%nlon, grid_var%nlat), &
          grid_var%tlat(grid_var%nlon, grid_var%nlat), &
          grid_var%ulong(grid_var%nlon, grid_var%nlat), &
          grid_var%ulat(grid_var%nlon, grid_var%nlat), &
          grid_var%tarea(grid_var%nlon, grid_var%nlat), &
          grid_var%uarea(grid_var%nlon, grid_var%nlat), &
          grid_var%kmt(grid_var%nlon, grid_var%nlat))

     call nf_inq_varid_wrap(ncid, TLONG_name, varid, subname)
     call nf_get_var_wrap(ncid, varid, grid_var%tlong, subname)

     call nf_inq_varid_wrap(ncid, TLAT_name, varid, subname)
     call nf_get_var_wrap(ncid, varid, grid_var%tlat, subname)

     call nf_inq_varid_wrap(ncid, ULONG_name, varid, subname)
     call nf_get_var_wrap(ncid, varid, grid_var%ulong, subname)

     call nf_inq_varid_wrap(ncid, ULAT_name, varid, subname)
     call nf_get_var_wrap(ncid, varid, grid_var%ulat, subname)

     call nf_inq_varid_wrap(ncid, TAREA_name, varid, subname)
     call nf_get_var_wrap(ncid, varid, grid_var%tarea, subname)

     call nf_inq_varid_wrap(ncid, UAREA_name, varid, subname)
     call nf_get_var_wrap(ncid, varid, grid_var%uarea, subname)

     call nf_inq_varid_wrap(ncid_KMT, KMT_name, varid, subname)
     call nf_get_var_wrap(ncid_KMT, varid, grid_var%kmt, subname)

     call nf_close_wrap(ncid, subname)
     call nf_close_wrap(ncid_KMT, subname)

     call gen_grid_derived_vals(grid_var)

  end subroutine read_POP_grid_NetCDF

  !-----------------------------------------------------------------------------

  subroutine check_var_size(ncid, var_name, ndims_in, dimlens)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     integer(kind=int_kind), intent(in) :: &
          ncid,            & ! NetCDF file ID
          ndims_in           ! number of expected dimensions

     character(len=*), intent(in) :: &
          var_name           ! name of variables to check

     integer(kind=int_kind), dimension(:), intent(in) :: &
          dimlens            ! expected dimension lengths

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     character(len=*), parameter :: &
          subname = 'POP_grid_mod:check_var_size'

     integer(kind=int_kind) :: &
          varid,             & ! NetCDF variable ID
          ndims,             & ! actual number of dimensinos for varid
          dimids(ndims_in+1),& ! NetCDF dimension IDs for varid
          dimlen,            & ! dimlen for ith dimid
          i                    ! loop index

     logical(kind=log_kind) :: &
          lExtraSingletonDim   ! is there one extra singleton dimension

     !--------------------------------------------------------------------------

     call nf_inq_varid_wrap(ncid, var_name, varid, subname)
     call nf_inq_varndims_wrap(ncid, varid, ndims, subname)

     !--------------------------------------------------------------------------
     !   allow for one extra singleton dimension
     !--------------------------------------------------------------------------

     if (ndims /= ndims_in) then
        if (ndims == ndims_in+1) then
           call nf_inq_vardimid_wrap(ncid, varid, dimids, subname)
           call nf_inq_dimlen_wrap(ncid, dimids(ndims_in+1), dimlen, subname)
           lExtraSingletonDim = (dimlen == 1)
        else
           lExtraSingletonDim = .false.
        end if
        if (.not. lExtraSingletonDim) then
           call msg_write(subname, 'unexpected ndims for ' // var_name, ndims)
           stop
        end if
     else
        call nf_inq_vardimid_wrap(ncid, varid, dimids, subname)
     end if

     do i=1,ndims_in
        call nf_inq_dimlen_wrap(ncid, dimids(i), dimlen, subname)
        if (dimlen /= dimlens(i)) then
           call msg_write(subname, 'dimlen for ' // var_name // &
                ' unexpected ', dimlen, ' /= ', dimlens(i))
           stop
        end if
     end do

  end subroutine check_var_size

  !-----------------------------------------------------------------------------

  subroutine gen_grid_derived_vals(grid_var)

     !--------------------------------------------------------------------------
     !   generate various grid derived quantities
     !      lat_threshold
     !      extremum of tracer cell vertex coordinates
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     type(POP_grid), intent(inout) :: &
          grid_var           ! grid to generate lat_threshold for

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     character(len=*), parameter :: &
          subname = 'POP_grid_mod:gen_grid_derived_vals'

     real(kind=r8) :: &
          lat_threshold      ! least latitude of pole containing cells

     real(kind=r8), dimension(4) :: &
          Tvert_lat,       & ! latitude of tracer cell vertices (degrees_north)
          Tvert_long         ! longitude of tracer cell vertices (degrees_east)

     integer(kind=int_kind) :: &
          polecnt,         & ! counts no. of pole containing cells
          i, j               ! indices of tracer cell to get vertices for

     !--------------------------------------------------------------------------

     polecnt = 0
     lat_threshold = c90

     grid_var%tvert_latmin = c90
     grid_var%tvert_latmax = -c90
     grid_var%tvert_lonmin = c2*c360
     grid_var%tvert_lonmax = -c2*c360

     grid_var%pole_i = 0
     grid_var%pole_j = 0

     do j = 1,grid_var%nlat
        do i = 1,grid_var%nlon
           call gen_Tcell_vertices(grid_var, i, j, Tvert_lat, Tvert_long)
           if (contains_np(4, Tvert_lat, Tvert_long)) then
              polecnt = polecnt + 1
              lat_threshold = min(lat_threshold, minval(Tvert_lat))

              grid_var%tvert_latmin = min(grid_var%tvert_latmin, minval(Tvert_lat))
              grid_var%tvert_latmax = max(grid_var%tvert_latmax, c90)
              grid_var%tvert_lonmin = min(grid_var%tvert_lonmin, minval(Tvert_long))
              grid_var%tvert_lonmax = max(grid_var%tvert_lonmax, maxval(Tvert_long))

              grid_var%pole_i = i
              grid_var%pole_j = j
           else
              grid_var%tvert_latmin = min(grid_var%tvert_latmin, minval(Tvert_lat))
              grid_var%tvert_latmax = max(grid_var%tvert_latmax, maxval(Tvert_lat))
              grid_var%tvert_lonmin = min(grid_var%tvert_lonmin, minval(Tvert_long))
              grid_var%tvert_lonmax = max(grid_var%tvert_lonmax, maxval(Tvert_long))
           endif
        end do
     end do

     if (polecnt > 1) then
        call msg_write(subname, 'unexpected polecnt = ', polecnt)
        stop
     end if

     grid_var%lat_threshold = lat_threshold

  end subroutine gen_grid_derived_vals

  !-----------------------------------------------------------------------------

  subroutine free_POP_grid(grid_var)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     type(POP_grid), intent(inout) :: &
          grid_var           ! where to store grid was

     !--------------------------------------------------------------------------

     deallocate( &
          grid_var%tlong, &
          grid_var%tlat, &
          grid_var%ulong, &
          grid_var%ulat, &
          grid_var%tarea, &
          grid_var%uarea, &
          grid_var%kmt)

  end subroutine free_POP_grid

  !-----------------------------------------------------------------------------

  subroutine gen_Tcell_vertices(grid_var, i, j, lat, lon)

     !--------------------------------------------------------------------------
     !   Generate vertices of the (i,j) tracer cell.
     !   The relationship between U points and T points is as in this figure
     !
     !   (4)  U(i-1,j)--------------U(i,j)  (3)
     !            |                   |
     !            |       T(i,j)      |
     !            |                   |
     !   (1) U(i-1,j-1)------------U(i,j-1) (2)
     !
     !   The order that the vertices are generated is according to the numbers
     !   in parentheses.
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     type(POP_grid), intent(in) :: &
          grid_var           ! grid

     integer(kind=int_kind), intent(in) :: &
          i, j               ! indices of tracer cell to get vertices for

     real(kind=r8), dimension(4), intent(out) :: &
          lat,             & ! latitude of cell vertices (degrees_north)
          lon                ! longitude of cell vertices (degrees_east)

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     integer(kind=int_kind) :: &
          im1,             & ! previous index in longitude direction, w/ wrapping
          vert_ind           ! loop index over vertices

     real(kind=r8) :: &
          lon_min            ! longitude used when mathcing longitudes

     !--------------------------------------------------------------------------

     im1 = i - 1
     if (i == 1) im1 = grid_var%nlon

     lat(4) = grid_var%ulat(im1,j)
     lon(4) = grid_var%ulong(im1,j)

     lat(3) = grid_var%ulat(i,j)
     lon(3) = grid_var%ulong(i,j)

     if (j > 1) then
        lat(2) = grid_var%ulat(i,j-1)
        lon(2) = grid_var%ulong(i,j-1)

        lat(1) = grid_var%ulat(im1,j-1)
        lon(1) = grid_var%ulong(im1,j-1)
     else
        lat(2) = grid_var%ulat(i,1) - (grid_var%ulat(i,2) - grid_var%ulat(i,1))
        lon(2) = grid_var%ulong(i,1)

        lat(1) = grid_var%ulat(im1,1) - (grid_var%ulat(im1,2) - grid_var%ulat(im1,1))
        lon(1) = grid_var%ulong(im1,1)
     end if

     lon_min = grid_var%tlong(i,j) - c180
     lon(1) = modulo(lon(1) - lon_min, c360) + lon_min
     do vert_ind = 2,4
        lon_min = lon(vert_ind-1) - c180
        lon(vert_ind) = modulo(lon(vert_ind) - lon_min, c360) + lon_min
     end do

  end subroutine gen_Tcell_vertices

  !-----------------------------------------------------------------------------

  subroutine read_rmask(rmask_filename, rmask_name, rmask)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     character(len=*), intent(in) :: &
          rmask_filename,  & ! file to read rmask from
          rmask_name         ! name of variable

     integer(kind=int_kind), dimension(:,:), intent(out) :: &
          rmask              ! where read in mask is to be stored

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     character(len=*), parameter :: &
          subname = 'POP_grid_mod:read_rmask'

     integer(kind=int_kind) :: &
          rmask_shape(2),  & ! shape of rmask
          ncid,            & ! file ID
          varid              ! variable ID

     !--------------------------------------------------------------------------

     rmask_shape = shape(rmask)
     call nf_open_wrap(rmask_filename, 0, ncid, subname)
     call check_var_size(ncid, trim(rmask_name), 2, rmask_shape)
     call nf_inq_varid_wrap(ncid, trim(rmask_name), varid, subname)
     call nf_get_var_wrap(ncid, varid, rmask, subname)
     call nf_close_wrap(ncid, subname)

  end subroutine read_rmask

  !-----------------------------------------------------------------------------

end module POP_grid_mod
