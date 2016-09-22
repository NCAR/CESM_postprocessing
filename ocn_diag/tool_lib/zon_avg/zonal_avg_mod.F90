module zonal_avg_mod

  !-----------------------------------------------------------------------------
  !   This module computes basin zonal averages on POP grids. The steps are
  !      1) set up the destination grid
  !      2) compute averaging weights for each grid cell
  !      3) compute normalizing weights for each basin (if required)
  !      4) compute basin zonal averages
  !
  !   The averages can be masked in longitude or latitude.
  !
  !   CVS:$Id: zonal_avg_mod.F90,v 1.7 2002/02/11 05:04:40 klindsay Exp $
  !   CVS:$Name:  $
  !   CVS:$Log: zonal_avg_mod.F90,v $
  !   CVS:Revision 1.7  2002/02/11 05:04:40  klindsay
  !   CVS:add options -v and -x
  !   CVS:
  !   CVS:Revision 1.6  2002/02/11 03:18:13  klindsay
  !   CVS:add -N option, which produces area-weighted sums, as opposed to averages
  !   CVS:   together with running sums on latitude, is useful for
  !   CVS:   making inferred transports from fluxes
  !   CVS:use NF_FILL_DOUBLE for missing_value and _FillValue if variable doesn't
  !   CVS:   already have one
  !   CVS:
  !   CVS:Revision 1.5  2002/02/07 13:33:00  klindsay
  !   CVS:scale line integral areas for partial cells so that they sum to model
  !   CVS:generated area
  !   CVS:
  !   CVS:Revision 1.4  2002/02/07 00:08:05  klindsay
  !   CVS:fix bug (array length mismatch) in computation of dest_lat_axis
  !   CVS:also use TLAT for dest_lat_axis where grid has constant latitude
  !   CVS:continue to use averaging for TLAT where grid has variable latitude
  !   CVS:
  !   CVS:Revision 1.3  2001/11/21 22:56:44  klindsay
  !   CVS:Changed out_dimind to in_dimind, as it really specifies
  !   CVS:a dimension index in the input variable.
  !   CVS:
  !   CVS:Revision 1.2  2001/11/21 20:08:31  klindsay
  !   CVS:add additional valid depth axis names
  !   CVS:
  !   CVS:Revision 1.1  2001/10/15 17:37:54  klindsay
  !   CVS:initial checkin
  !   CVS:
  !-----------------------------------------------------------------------------

  use kinds_mod
  use constants
  use nf_wrap
  use POP_grid_mod
  use sphere_area_mod

  implicit none
  private
  public :: &
       gen_dest_lat_axis, &
       def_dest_dimsnvars, &
       put_dest_dim_vars, &
       gen_weights, &
       compute_zon_avg, &
       varlist_include, &
       parse_varlist, &
       free_zon_avg

  integer(kind=int_kind), save :: &
       dest_lat_len,        & ! length of generated latitude axis
       init_unlimdim_len      ! initial length of unlimited dimension in outfile

  real(kind=r8), dimension(:), allocatable, save :: &
       dest_lat_axis,       & ! cell midpoints of destination axis
       dest_lat_axis_edges    ! cell edges of destination axis

  integer(kind=int_kind), dimension(:,:), allocatable, save :: &
       wght_cnt,            & ! no. of weights for (i,j) T cell
       lat_axis_ind0,       & ! first lat_axis cell (i,j) T cell intersects with
       Twght_ind0             ! first index in Twght array

  real(kind=r8), dimension(:), allocatable, save :: &
       Twght                  ! area common to tracer cells and latitude bands

  real(kind=r8), dimension(:,:), allocatable, save :: &
       var_in_lev,          & ! data for 1 level on source grid
       var_out_lev            ! basin zonal averages for 1 level

  real(kind=r8), dimension(:,:,:), allocatable, save :: &
       Twght_basin_sum_kmt    ! sum of Twght across each basin for kmt value

  logical(kind=log_kind), save :: &
       varlist_include = .true. ! is varlist an inclusion list or exclusion list

  character(len=long_char_len), save :: &
       varlist_pad = 'empty'  ! comma padded version of varlist

  contains

  !-----------------------------------------------------------------------------

  subroutine gen_dest_lat_axis(grid_var, latmin, latmax)

     !--------------------------------------------------------------------------
     !   Generate destination axis for zonal averaging. For the genral case,
     !   1) generate axis_edges ignoring clipping
     !   2) generate axis
     !   3) clip where needed
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     type(POP_grid), intent(in) :: &
          grid_var           ! grid to generate destination axis from

     real(kind=r8), intent(in) :: &
          latmin, latmax     ! latitude bounds of averaging

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     real(kind=r8), dimension(:), allocatable :: &
          tmp_dest_lat_axis_edges    ! cell edges of destination axis before clipping

     real(kind=r8) :: &
          dlat               ! change in lat across first T cell

     integer(kind=int_kind) :: &
          j,               & ! loop index
          max_j_single,    & ! maximum j value for which latitude on U grid is constant
          tmp_len,         & ! length of tmp_dest_lat_axis_edges - 1
          jlo, jhi           ! lo & hi j indices of tmp_dest_lat_axis_edges that
                             ! get copied to dest_lat_axis_edges

     !--------------------------------------------------------------------------
     !    compute max_j_reg
     !--------------------------------------------------------------------------

     max_j_single = 0
     do j = 1,grid_var%nlat
        if (maxval(grid_var%ulat(:,j)) - minval(grid_var%ulat(:,j)) < 1.0e-10_r8) then
           max_j_single = j
        else
           exit
        end if
     end do

     !--------------------------------------------------------------------------
     !   generate destination axis ignoring clipping
     !   first generate edges, then generate cell midpoints
     !--------------------------------------------------------------------------

     if (max_j_single == grid_var%nlat) then

        !-----------------------------------------------------------------------
        !   case 1 : all constant j lines have constant latitude
        !-----------------------------------------------------------------------

        tmp_len = grid_var%nlat
        allocate(tmp_dest_lat_axis_edges(0:tmp_len))
        tmp_dest_lat_axis_edges(0) = grid_var%tvert_latmin
        tmp_dest_lat_axis_edges(1:tmp_len) = grid_var%ulat(1,:)

     else if (max_j_single == 0) then

        !-----------------------------------------------------------------------
        !   case 2 : no constant j lines have constant latitude
        !-----------------------------------------------------------------------

        tmp_len = grid_var%nlat
        allocate(tmp_dest_lat_axis_edges(0:tmp_len))
        do j = 0,tmp_len
           tmp_dest_lat_axis_edges(j) = grid_var%tvert_latmin + &
                (grid_var%tvert_latmax - grid_var%tvert_latmin) * &
                real(j,r8) / real(tmp_len,r8)
        end do

     else if (grid_var%ulat(1,max_j_single) == c0) then

        !-----------------------------------------------------------------------
        !   case 3 : constant j lines have constant latitude go to equator
        !-----------------------------------------------------------------------

        tmp_len = max_j_single
        if (-grid_var%ulat(1,1) > grid_var%tvert_latmax) then
           do j = max_j_single-1,1,-1
              tmp_len = tmp_len + 1
              if (-grid_var%ulat(1,j) > grid_var%tvert_latmax) exit
           end do
           allocate(tmp_dest_lat_axis_edges(0:tmp_len))
           tmp_dest_lat_axis_edges(0) = grid_var%tvert_latmin
           tmp_dest_lat_axis_edges(1:max_j_single) = &
              grid_var%ulat(1,1:max_j_single)
           do j = max_j_single+1,tmp_len
              tmp_dest_lat_axis_edges(j) = &
                 -tmp_dest_lat_axis_edges(max_j_single-(j-max_j_single))
           end do
        else
           tmp_len = tmp_len + (max_j_single-1)
           dlat = grid_var%ulat(1,1) - grid_var%tvert_latmin
           tmp_len = tmp_len + &
                ceiling((grid_var%tvert_latmax + grid_var%ulat(1,1)) / dlat)
           allocate(tmp_dest_lat_axis_edges(0:tmp_len))
           tmp_dest_lat_axis_edges(0) = grid_var%tvert_latmin
           tmp_dest_lat_axis_edges(1:max_j_single) = &
              grid_var%ulat(1,1:max_j_single)
           do j = max_j_single+1,2*max_j_single-1
              tmp_dest_lat_axis_edges(j) = &
                 -tmp_dest_lat_axis_edges(max_j_single-(j-max_j_single))
           end do
           do j = 2*max_j_single,tmp_len
              tmp_dest_lat_axis_edges(j) = tmp_dest_lat_axis_edges(j-1) + dlat
           end do
        end if

     else

        !-----------------------------------------------------------------------
        !   case 4 : constant j lines do not stop at equator
        !-----------------------------------------------------------------------

        tmp_len = grid_var%nlat
        allocate(tmp_dest_lat_axis_edges(0:tmp_len))
        tmp_dest_lat_axis_edges(0) = grid_var%tvert_latmin
        tmp_dest_lat_axis_edges(1:max_j_single) = &
             grid_var%ulat(1,1:max_j_single)
        do j = max_j_single+1,tmp_len
           tmp_dest_lat_axis_edges(j) = grid_var%ulat(1,max_j_single) + &
                (grid_var%tvert_latmax - grid_var%ulat(1,max_j_single)) * &
                real(j-max_j_single,r8) / real(tmp_len-max_j_single,r8)
        end do

     end if

     !--------------------------------------------------------------------------
     !   generate actual returned axes, taking clipping into account
     !--------------------------------------------------------------------------

     if (tmp_dest_lat_axis_edges(0) < latmin) then
        do j = 1,tmp_len
           if (tmp_dest_lat_axis_edges(j) > latmin) then
              jlo = j-1
              exit
           end if
        end do
     else
        jlo = 0
     end if

     if (tmp_dest_lat_axis_edges(tmp_len) > latmax) then
        do j = tmp_len-1,0,-1
           if (tmp_dest_lat_axis_edges(j) < latmax) then
              jhi = j+1
              exit
           end if
        end do
     else
        jhi = tmp_len
     end if

     dest_lat_len = jhi - jlo

     allocate(dest_lat_axis(dest_lat_len), dest_lat_axis_edges(0:dest_lat_len))

     dest_lat_axis_edges = tmp_dest_lat_axis_edges(jlo:jhi)

     !--------------------------------------------------------------------------
     !   compute midpoints of cells for tracer points
     !--------------------------------------------------------------------------

     dest_lat_axis = dest_lat_axis_edges(0:dest_lat_len-1) + p5 * &
          (dest_lat_axis_edges(1:dest_lat_len) - dest_lat_axis_edges(0:dest_lat_len-1))

     !--------------------------------------------------------------------------
     !   in between where the source grid edges has constant latitude edges,
     !   use the source grid tracer point latitudes
     !
     !   check first generated point for reasonableness, as some versions of POP
     !   produced unreasonable TLAT values for j=1
     !--------------------------------------------------------------------------

     if (max_j_single > jlo) then
        dest_lat_axis(1:max_j_single-jlo) = grid_var%tlat(1,jlo+1:max_j_single)

        if (dest_lat_axis(1) > dest_lat_axis_edges(1) .or. &
            dest_lat_axis(1) < dest_lat_axis_edges(0)) then
           dest_lat_axis(1) = dest_lat_axis_edges(0) + p5 * &
              (dest_lat_axis_edges(1) - dest_lat_axis_edges(0))
        end if
     end if

     !--------------------------------------------------------------------------
     !   clip latitude axes
     !--------------------------------------------------------------------------

     if (dest_lat_axis(1) < latmin) &
          dest_lat_axis(1) = latmin

     if (dest_lat_axis(dest_lat_len) > latmax) &
          dest_lat_axis(dest_lat_len) = latmax

     if (dest_lat_axis_edges(0) < latmin) &
          dest_lat_axis_edges(0) = latmin

     if (dest_lat_axis_edges(dest_lat_len) > latmax) &
          dest_lat_axis_edges(dest_lat_len) = latmax

     !--------------------------------------------------------------------------
     !   free tmp_dest_lat_axis_edges
     !--------------------------------------------------------------------------

     deallocate(tmp_dest_lat_axis_edges)

  end subroutine gen_dest_lat_axis

  !-----------------------------------------------------------------------------

  subroutine def_dest_dimsnvars(outfilename, infilename, basin_cnt, time_const, lopen)

     !--------------------------------------------------------------------------
     !   Define in outfile the variables from infile that are to be averaged.
     !   Ensure that the required dimensions and their associated variables are
     !   defined as well. Also copy global attributes from infile to outfile.
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     character(len=*), intent(in) :: &
          outfilename,     & ! name of file where dims & vars are to be defined
          infilename         ! name of file where dims & vars come from

     integer(kind=int_kind), intent(in) :: &
          basin_cnt          ! number of basins in rmask, including global

     logical(kind=log_kind), intent(in) :: &
          time_const,      & ! are time constant variables to be averaged?
          lopen              ! should file be opened vs. created

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     character(len=*), parameter :: &
          subname = 'zonal_avg_mod:def_dest_dims'

     integer(kind=int_kind) :: &
          i,               & ! loop index
          nlon_dimid,      & ! dimid on "nlon" in infile
          nlat_dimid,      & ! dimid on "nlat" in infile
          stat,            & ! status from NetCDF calls
          in_ncid,         & ! file ID for infile
          out_ncid,        & ! file ID for outfile
          dimlen,          & ! dimension length
          basin_dimid,     & ! basin dimension ID in outfile
          lat_dimid,       & ! latitude dimension ID in outfile
          in_nvars,        & ! number of variables in infile
          in_unlimdim,     & ! unlimited dimension from infile
          in_varid,        & ! variable ID from infile
          in_ndims,        & ! ndims of in_varid
          out_dimid,       & ! dimid in outfile
          out_varid,       & ! varid in outfile
          vartype,         & ! NetCDF type of variable
          dimvarid,        & ! varid of a coordinate variable
          dimvarndims,     & ! number of dimensions of a coordinate variable
          dimvardimids(1), & ! dimids of a coordinate variable
          dimvartype,      & ! NetCDF type of a coordinate variable
          natts,           & ! number of attributes a variable has
          attnum,          & ! number of a specific attribute
          swap_dimid         ! temporary dimid used for swapping

     integer(kind=int_kind), dimension(NF_MAX_VAR_DIMS) :: &
          in_dimids,       & ! dimids of in_varid
          out_dimids         ! dimids of out_varid

     character(len=char_len) :: &
          att_name,        & ! name of an attribute
          att_text_val,    & ! attribute value
          varname,         & ! variable name
          dimname            ! dimension name

     real(kind=r8) :: &
          msv                ! value to be used where there is no data

     !--------------------------------------------------------------------------

     call nf_open_wrap(infilename, 0, in_ncid, subname)

     if (lopen) then
        call nf_open_wrap(outfilename, NF_WRITE, out_ncid, subname)
        call nf_redef_wrap(out_ncid, subname)
     else
        call nf_create_wrap(outfilename, 0, out_ncid, subname)
     end if

     !--------------------------------------------------------------------------
     !   Define basin & latitude axes in outfile.
     !--------------------------------------------------------------------------

     call nf_inq_dimid_wrap(out_ncid, 'basins', basin_dimid, subname, &
          ALLOW=NF_EBADDIM, stat_out=stat)
     if (stat == NF_EBADDIM) then
        call nf_def_dim_wrap(out_ncid, 'basins', basin_cnt, basin_dimid, subname)
     end if

     call nf_inq_dimid_wrap(out_ncid, 'lat_t', lat_dimid, subname, &
          ALLOW=NF_EBADDIM, stat_out=stat)
     if (stat == NF_EBADDIM) then
        dimlen = dest_lat_len
        call nf_def_dim_wrap(out_ncid, 'lat_t', dimlen, lat_dimid, subname)
     end if

     call nf_inq_varid_wrap(out_ncid, 'lat_t', out_varid, subname, &
          ALLOW=NF_ENOTVAR, stat_out=stat)
     if (stat == NF_ENOTVAR) then
        call nf_def_var_wrap(out_ncid, 'lat_t', NF_FLOAT, 1, (/ lat_dimid /), &
             out_varid, subname)

        att_text_val = 'Latitude Cell Centers'
        call nf_put_att_wrap(out_ncid, out_varid, 'long_name', &
             len_trim(att_text_val), trim(att_text_val), subname)

        att_text_val = 'degrees_north'
        call nf_put_att_wrap(out_ncid, out_varid, 'units', &
             len_trim(att_text_val), trim(att_text_val), subname)

        att_text_val = 'lat_t_edges'
        call nf_put_att_wrap(out_ncid, out_varid, 'edges', &
             len_trim(att_text_val), trim(att_text_val), subname)
     end if

     call nf_inq_dimid_wrap(out_ncid, 'lat_t_edges', out_dimid, subname, &
          ALLOW=NF_EBADDIM, stat_out=stat)
     if (stat == NF_EBADDIM) then
        dimlen = dest_lat_len+1
        call nf_def_dim_wrap(out_ncid, 'lat_t_edges', dimlen, out_dimid, subname)
     end if

     call nf_inq_varid_wrap(out_ncid, 'lat_t_edges', out_varid, subname, &
          ALLOW=NF_ENOTVAR, stat_out=stat)
     if (stat == NF_ENOTVAR) then
        call nf_def_var_wrap(out_ncid, 'lat_t_edges', NF_FLOAT, 1, &
             (/ out_dimid /), out_varid, subname)
     end if

     !--------------------------------------------------------------------------
     !   Loop over variables in infile.
     !   1) If variable is not to be averaged, go to next variable.
     !   2) If variable is already defined, go to next variable.
     !      This does check that previously defined variable has same dimensions.
     !   3) For each variable dimension not defined in outfile, except nlon & nlat
     !      3a) define the dimension in outfile
     !      3b) if it has a coordinate variable, define it, copying attributes
     !   4) Define variable, changing (nlon,nlat) to (basins,lat_t).
     !   5) Copy non-coordinate attributes from infile to outfile.
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   obtain dimids of unlimdim, "nlon", and "nlat" from infile
     !   they are treated specially
     !--------------------------------------------------------------------------

     call nf_inq_unlimdim_wrap(in_ncid, in_unlimdim, subname)
     call nf_inq_varid_wrap(in_ncid, TLONG_name, in_varid, subname)
     call nf_inq_vardimid_wrap(in_ncid, in_varid, in_dimids, subname)
     nlon_dimid = in_dimids(1)
     nlat_dimid = in_dimids(2)

     call nf_inq_nvars_wrap(in_ncid, in_nvars, subname)
     do in_varid = 1,in_nvars

        if (.not. to_comp_avg(in_ncid, in_varid, time_const)) cycle

        !-----------------------------------------------------------------------
        !   Is the variable already defined in outfile?
        !-----------------------------------------------------------------------

        varname = ''
        call nf_inq_varname_wrap(in_ncid, in_varid, varname, subname)
        call nf_inq_varid_wrap(out_ncid, trim(varname), out_varid, subname, &
             ALLOW=NF_ENOTVAR, stat_out=stat)
        if (stat == NF_NOERR) cycle

        call nf_inq_vartype_wrap(in_ncid, in_varid, vartype, subname)
        call nf_inq_varndims_wrap(in_ncid, in_varid, in_ndims, subname)
        call nf_inq_vardimid_wrap(in_ncid, in_varid, in_dimids, subname)

        !-----------------------------------------------------------------------
        !   Construct dimids array
        !   Initial construction has nlon -> lat, nlat -> basin
        !   basin is shifted to end of dimid array later
        !-----------------------------------------------------------------------

        do i = 1,in_ndims
           if (in_dimids(i) == nlon_dimid) then
              out_dimids(i) = lat_dimid
              cycle
           end if

           if (in_dimids(i) == nlat_dimid) then
              out_dimids(i) = basin_dimid
              cycle
           end if

           !--------------------------------------------------------------------
           !   Is the dimension already defined in outfile?
           !--------------------------------------------------------------------

           dimname = ''
           call nf_inq_dimname_wrap(in_ncid, in_dimids(i), dimname, subname)
           call nf_inq_dimid_wrap(out_ncid, trim(dimname), out_dimids(i), subname, &
                ALLOW=NF_EBADDIM, stat_out=stat)
           if (stat == NF_NOERR) cycle

           !--------------------------------------------------------------------
           !   What is the length of the dimension? Treat the unlimited
           !   dimension correctly.
           !--------------------------------------------------------------------

           if (in_dimids(i) == in_unlimdim) then
              dimlen = NF_UNLIMITED
           else
              call nf_inq_dimlen_wrap(in_ncid, in_dimids(i), dimlen, subname)
           end if

           !--------------------------------------------------------------------
           !   Define dimension in outfile
           !--------------------------------------------------------------------

           call nf_def_dim_wrap(out_ncid, trim(dimname), dimlen, out_dimids(i), subname)

           !--------------------------------------------------------------------
           !   Does this dimension have a corresponding coordinate variable?
           !   I.e. a variable w/ the same name, defined on a single dimension
           !   that is the dimension in question
           !--------------------------------------------------------------------

           call nf_inq_varid_wrap(in_ncid, trim(dimname), dimvarid, subname, &
                ALLOW=NF_ENOTVAR, stat_out=stat)
           if (stat == NF_ENOTVAR) cycle
           call nf_inq_varndims_wrap(in_ncid, dimvarid, dimvarndims, subname)
           if (dimvarndims /= 1) cycle
           call nf_inq_vardimid_wrap(in_ncid, dimvarid, dimvardimids, subname)
           if (dimvardimids(1) /= in_dimids(i)) cycle

           !--------------------------------------------------------------------
           !   Define coordinate variable in outfile
           !--------------------------------------------------------------------

           call nf_inq_vartype_wrap(in_ncid, dimvarid, dimvartype, subname)
           call nf_def_var_wrap(out_ncid, trim(dimname), dimvartype, 1, &
                (/ out_dimids(i) /), out_varid, subname)

           !--------------------------------------------------------------------
           !   Copy non-coordinates attributes
           !--------------------------------------------------------------------

           call nf_inq_varnatts_wrap(in_ncid, dimvarid, natts, subname)
           do attnum = 1,natts
              att_name = ''
              call nf_inq_attname_wrap(in_ncid, dimvarid, attnum, att_name, subname)
              call nf_copy_att_wrap(in_ncid, dimvarid, trim(att_name), &
                   out_ncid, out_varid, subname)
           end do

        end do

        !-----------------------------------------------------------------------
        !   Shift basin_dimid to end of list, but not beyond unlimited dimension
        !-----------------------------------------------------------------------

        do i = 1,in_ndims-1
           if (out_dimids(i) == basin_dimid .and. in_dimids(i+1) /= in_unlimdim) then
              swap_dimid = out_dimids(i+1)
              out_dimids(i+1) = out_dimids(i)
              out_dimids(i) = swap_dimid
           end if
        end do

        !-----------------------------------------------------------------------
        !   Define variable in outfile
        !-----------------------------------------------------------------------

        call nf_def_var_wrap(out_ncid, trim(varname), vartype, in_ndims, &
             out_dimids, out_varid, subname)

        !-----------------------------------------------------------------------
        !   Copy non-coordinates attributes
        !-----------------------------------------------------------------------

        call nf_inq_varnatts_wrap(in_ncid, in_varid, natts, subname)
        do attnum = 1,natts
           att_name = ''
           call nf_inq_attname_wrap(in_ncid, in_varid, attnum, att_name, subname)
           if (att_name == 'coordinates') cycle
           call nf_copy_att_wrap(in_ncid, in_varid, trim(att_name), &
                out_ncid, out_varid, subname)
        end do

        !-----------------------------------------------------------------------
        !   If variable does not have _FillValue or missing_value attribute,
        !   put default value in for both.
        !-----------------------------------------------------------------------

        call nf_get_att_wrap(out_ncid, out_varid, '_FillValue', msv, subname, &
             ALLOW=NF_ENOTATT, stat_out=stat)
        if (stat == NF_ENOTATT) then
           call nf_get_att_wrap(out_ncid, out_varid, 'missing_value', msv, subname, &
                ALLOW=NF_ENOTATT, stat_out=stat)
           if (stat == NF_ENOTATT) then
              call nf_put_att_wrap(out_ncid, out_varid, '_FillValue', &
                   vartype, 1, NF_FILL_DOUBLE, subname)
              call nf_put_att_wrap(out_ncid, out_varid, 'missing_value', &
                   vartype, 1, NF_FILL_DOUBLE, subname)
           end if
        end if

     end do

     !--------------------------------------------------------------------------
     !   Copy global attributes from infile to outfile
     !--------------------------------------------------------------------------

     call nf_inq_varnatts_wrap(in_ncid, NF_GLOBAL, natts, subname)
     do attnum = 1,natts
        att_name = ''
        call nf_inq_attname_wrap(in_ncid, NF_GLOBAL, attnum, att_name, subname)
        call nf_copy_att_wrap(in_ncid, NF_GLOBAL, trim(att_name), &
             out_ncid, NF_GLOBAL, subname)
     end do

     call nf_close_wrap(out_ncid, subname)
     call nf_close_wrap(in_ncid, subname)
     
  end subroutine def_dest_dimsnvars

  !-----------------------------------------------------------------------------

  subroutine parse_varlist(varlist)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     character(len=long_char_len), intent(in) :: varlist

     !--------------------------------------------------------------------------

     varlist_pad = ',' // trim(varlist) // ','

  end subroutine parse_varlist

  !-----------------------------------------------------------------------------

  logical(kind=log_kind) function to_comp_avg(ncid, varid, time_const)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     integer(kind=int_kind) :: &
          ncid,            & ! file ID
          varid              ! variable ID

     logical(kind=log_kind) :: &
          time_const         ! are time constant variables to be averaged?

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     character(len=*), parameter :: &
          subname = 'zonal_avg_mod:to_comp_avg'

     character(len=char_len) :: &
          varname,         & ! name of variable
          att_text_val       ! attribute value

     integer(kind=int_kind) :: &
          stat,            & ! status from NetCDF calls
          vartype,         & ! variable type
          timedim,         & ! time dimension in ncid
          ndims              ! ndims of in_varid

     integer(kind=int_kind), dimension(NF_MAX_VAR_DIMS) :: &
          dimids             ! dimids of varid

     logical(kind=log_kind) :: &
          var_in_list        ! is variable in varlist

     !--------------------------------------------------------------------------

     to_comp_avg = .false.

     call nf_inq_vartype_wrap(ncid, varid, vartype, subname)
     if (vartype /= NF_DOUBLE .and. vartype /= NF_FLOAT) return

     att_text_val = ''
     call nf_get_att_wrap(ncid, varid, 'coordinates', att_text_val, &
          ALLOW=NF_ENOTATT, stat_out=stat)
     if (stat == NF_ENOTATT) return
     if (index(att_text_val, TLONG_name) == 0) return
     if (index(att_text_val, TLAT_name) == 0) return

     if (varlist_pad == 'empty') then
        if (.not. time_const) then
           call nf_inq_dimid_wrap(ncid, 'time', timedim, subname, &
                ALLOW=NF_EBADDIM, stat_out=stat)
           if (stat /= NF_EBADDIM) then
              call nf_inq_varndims_wrap(ncid, varid, ndims, subname)
              call nf_inq_vardimid_wrap(ncid, varid, dimids, subname)
              to_comp_avg = any(dimids(1:ndims) == timedim)
           else
              to_comp_avg = .false.
           end if
        else
           to_comp_avg = .true.
        end if
     else
        call nf_inq_varname_wrap(ncid, varid, varname, subname)
        var_in_list = index(varlist_pad, ',' // trim(varname) // ',') > 0
        to_comp_avg = var_in_list .eqv. varlist_include
     end if

  end function to_comp_avg

  !-----------------------------------------------------------------------------

  subroutine put_dest_dim_vars(outfilename, infilename)

     !--------------------------------------------------------------------------
     !   put latitude axes and coordinate variables from infile into outfile
     !--------------------------------------------------------------------------

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     character(len=*), intent(in) :: &
          outfilename,     & ! file where dims are to be put
          infilename         ! file where dims come from

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     character(len=*), parameter :: &
          subname = 'zonal_avg_mod:put_dest_dim_vars'

     integer(kind=int_kind) :: &
          stat,            & ! status from NetCDF calls
          in_ncid,         & ! file ID for infile
          out_ncid,        & ! file ID for outfile
          out_varid,       & ! varid of coordinate variable in outfile
          out_unlimdim,    & ! unlimited dimension from infile
          out_ndims,       & ! number of dimensions in outfile
          out_dimid,       & ! dimid in outfile
          out_varndims,    & ! number of dimensions of coordinate variable in outfile
          out_vardimids(1),& ! dimids of coordinate variable in outfile
          in_dimid,        & ! dimid in infile
          in_varid,        & ! varid of coordinate variable in infile
          in_varndims,     & ! number of dimensions of coordinate variable in infile
          in_vardimids(1), & ! dimids of coordinate variable in infile
          vartype,         & ! NetCDF type of coordinate variable
          dimlen,          & ! length of dimension
          out_start(1),    & ! start index of coordinate variable in outfile
          out_count(1)       ! length of coordinate variable in outfile

     real(kind=r8), dimension(:), allocatable :: &
          double_space       ! space for double coordinate variable

     real(kind=r4), dimension(:), allocatable :: &
          float_space        ! space for float coordinate variable

     integer(kind=int_kind), dimension(:), allocatable :: &
          int_space          ! space for integer coordinate variable

     character(len=char_len) :: &
          dimname            ! dimension name

     !--------------------------------------------------------------------------

     call nf_open_wrap(infilename, 0, in_ncid, subname)
     call nf_open_wrap(outfilename, NF_WRITE, out_ncid, subname)

     call nf_inq_varid_wrap(out_ncid, 'lat_t', out_varid, subname)
     call nf_put_var_wrap(out_ncid, out_varid, dest_lat_axis, subname)

     call nf_inq_varid_wrap(out_ncid, 'lat_t_edges', out_varid, subname)
     call nf_put_var_wrap(out_ncid, out_varid, dest_lat_axis_edges, subname)

     !--------------------------------------------------------------------------
     !   Loop over dimensions in outfile. For each dimension that has a
     !   coordinate variable, check to see if there is a corresponding
     !   dimension with coordinate variable in infile. If there is, copy
     !   the coordinate variable from infile to outfile.
     !--------------------------------------------------------------------------

     call nf_inq_unlimdim_wrap(out_ncid, out_unlimdim, subname)
     call nf_inq_ndims_wrap(out_ncid, out_ndims, subname)

     do out_dimid = 1,out_ndims
        dimname = ''
        call nf_inq_dimname_wrap(out_ncid, out_dimid, dimname, subname)

        !-----------------------------------------------------------------------
        !   Does dimname have a corresponding coordinate variable in outfile?
        !-----------------------------------------------------------------------

        call nf_inq_varid_wrap(out_ncid, trim(dimname), out_varid, subname, &
             ALLOW=NF_ENOTVAR, stat_out=stat)
        if (stat == NF_ENOTVAR) cycle
        call nf_inq_varndims_wrap(out_ncid, out_varid, out_varndims, subname)
        if (out_varndims /= 1) cycle
        call nf_inq_vardimid_wrap(out_ncid, out_varid, out_vardimids, subname)
        if (out_vardimids(1) /= out_dimid) cycle

        !-----------------------------------------------------------------------
        !   Does dimname occur in infile?
        !-----------------------------------------------------------------------

        call nf_inq_dimid_wrap(in_ncid, trim(dimname), in_dimid, subname, &
             ALLOW=NF_EBADDIM, stat_out=stat)
        if (stat == NF_EBADDIM) cycle

        !-----------------------------------------------------------------------
        !   Does dimname have a corresponding coordinate variable in infile?
        !-----------------------------------------------------------------------

        call nf_inq_varid_wrap(in_ncid, trim(dimname), in_varid, subname, &
             ALLOW=NF_ENOTVAR, stat_out=stat)
        if (stat == NF_ENOTVAR) cycle
        call nf_inq_varndims_wrap(in_ncid, in_varid, in_varndims, subname)
        if (in_varndims /= 1) cycle
        call nf_inq_vardimid_wrap(in_ncid, in_varid, in_vardimids, subname)
        if (in_vardimids(1) /= in_dimid) cycle

        !-----------------------------------------------------------------------
        !   allocate space for reading in variable
        !   read in variable
        !   write out variable
        !   deallocate space
        !
        !   Use put_vara when writing out so that same call sequence can be
        !   used for unlimited dimension as other dimensions.
        !-----------------------------------------------------------------------

        call nf_inq_dimlen_wrap(in_ncid, in_dimid, dimlen, subname)

        if (out_dimid /= out_unlimdim) then
           out_start(1) = 1
        else
           call nf_inq_dimlen_wrap(out_ncid, out_dimid, init_unlimdim_len, subname)
           out_start(1) = init_unlimdim_len + 1
        end if
        out_count(1) = dimlen

        call nf_inq_vartype_wrap(in_ncid, in_varid, vartype, subname)
        select case (vartype)
           case (NF_DOUBLE)
              allocate(double_space(dimlen))
              call nf_get_var_wrap(in_ncid, in_varid, double_space, subname)
              call nf_put_vara_wrap(out_ncid, out_varid, out_start, out_count, &
                   double_space, subname)
              deallocate(double_space)
           case (NF_FLOAT)
              allocate(float_space(dimlen))
              call nf_get_var_wrap(in_ncid, in_varid, float_space, subname)
              call nf_put_vara_wrap(out_ncid, out_varid, out_start, out_count, &
                   float_space, subname)
              deallocate(float_space)
           case (NF_INT, NF_SHORT)
              allocate(int_space(dimlen))
              call nf_get_var_wrap(in_ncid, in_varid, int_space, subname)
              call nf_put_vara_wrap(out_ncid, out_varid, out_start, out_count, &
                   int_space, subname)
              deallocate(int_space)
        end select

     end do

     call nf_close_wrap(out_ncid, subname)
     call nf_close_wrap(in_ncid, subname)

  end subroutine put_dest_dim_vars

  !-----------------------------------------------------------------------------

  subroutine gen_weights(grid_var, normalizing, rmask, &
       latmin, latmax, lonmin, lonmax)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     type(POP_grid), intent(in) :: &
          grid_var           ! source grid

     logical(kind=log_kind), intent(in) :: &
          normalizing        ! compute area averages (.T.) or area sums (.F.)

     integer(kind=int_kind), dimension(:,:), intent(in) :: &
          rmask              ! basin mask

     real(kind=r8), intent(in) :: &
          latmin, latmax,  & ! latitude bounds of averaging
          lonmin, lonmax     ! longitude bounds of averaging

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     integer(kind=int_kind) :: &
          i, j, k,         & ! loop indices
          j2,              & ! loop index into weights for a T cell
          j3,              & ! loop index into dest_lat_axis
          j4,              & ! loop index into Twght
          jlo, jhi,        & ! lo & hi j indices of a T cell intersection with
                             ! latitude bands from dest_lat_axis
          Twght_ind0_prev, & ! Twght_ind0 from 'previous' T cell
          wght_cnt_prev,   & ! wght_cnt from 'previous' T cell
          basin_cnt,       & ! no. of basins (=maxval(abs(rmask)))
          level_cnt,       & ! no. of vertical levels (=maxval(kmt))
          basin_ind          ! basin index of current T cell

     real(kind=r8) :: &
          tmp_lat,         & ! temporary latitude value
          scale,           & ! scale factor to convert line integral area
                             ! to model generated area
          LI_area_band       ! line integral area of T cell in latitude band

     real(kind=r8), dimension(4) :: &
          Tvert_lat,       & ! latitude of tracer cell vertices (degrees_north)
          Tvert_long         ! longitude of tracer cell vertices (degrees_east)

     !--------------------------------------------------------------------------

     allocate( &
          wght_cnt(grid_var%nlon, grid_var%nlat), &
          lat_axis_ind0(grid_var%nlon, grid_var%nlat), &
          Twght_ind0(grid_var%nlon, grid_var%nlat))

     do j = 1,grid_var%nlat
        do i = 1,grid_var%nlon
           if (grid_var%kmt(i,j) == 0 .or. rmask(i,j) == 0) then
              wght_cnt(i,j) = 0
              lat_axis_ind0(i,j) = 1
              cycle
           end if

           call gen_Tcell_vertices(grid_var, i, j, Tvert_lat, Tvert_long)

           if (i == grid_var%pole_i .and. j == grid_var%pole_j) then
              tmp_lat = c90
           else
              tmp_lat = maxval(Tvert_lat)
           end if

           if ((tmp_lat <= latmin) .or. &
                (minval(Tvert_lat) >= latmax) .or. &
                (maxval(Tvert_long) <= lonmin) .or. &
                (minval(Tvert_long) >= lonmax)) then
              wght_cnt(i, j) = 0
              cycle
           end if

           do jhi = dest_lat_len,1,-1
              if (tmp_lat > dest_lat_axis_edges(jhi-1)) exit
           end do

           tmp_lat = minval(Tvert_lat)
           do jlo = 1,dest_lat_len
              if (tmp_lat < dest_lat_axis_edges(jlo)) exit
           end do

           wght_cnt(i,j)      = jhi - jlo + 1
           lat_axis_ind0(i,j) = jlo
        end do
     end do

     allocate(Twght(sum(wght_cnt)))

     Twght_ind0_prev = 1
     wght_cnt_prev   = 0

     do j = 1,grid_var%nlat
        do i = 1,grid_var%nlon
           Twght_ind0(i,j) = Twght_ind0_prev + wght_cnt_prev
           if (wght_cnt(i,j) == 0 .or. grid_var%kmt(i,j) == 0) cycle

           call gen_Tcell_vertices(grid_var, i, j, Tvert_lat, Tvert_long)

           !--------------------------------------------------------------------
           !   normalize weights so that the weights for a full cell would
           !   sum to the model generated area
           !--------------------------------------------------------------------

           scale = grid_var%tarea(i,j) / clip_sphere_area(4, Tvert_lat, &
              Tvert_long, -90.0_r8, 90.0_r8, -720.0_r8, 720.0_r8, &
              grid_var%lat_threshold)

           do j2 = 0,wght_cnt(i,j)-1
              j3 = lat_axis_ind0(i,j) + j2
              j4 = Twght_ind0(i,j) + j2
              LI_area_band = clip_sphere_area(4, Tvert_lat, Tvert_long, &
                   dest_lat_axis_edges(j3-1), dest_lat_axis_edges(j3), &
                   lonmin, lonmax, grid_var%lat_threshold)
              Twght(j4) = LI_area_band * scale
           end do

           Twght_ind0_prev = Twght_ind0(i,j)
           wght_cnt_prev   = wght_cnt(i,j)
        end do
     end do

     level_cnt = maxval(grid_var%kmt)
     basin_cnt = maxval(abs(rmask))

     allocate( &
          var_in_lev(grid_var%nlon,grid_var%nlat), &
          var_out_lev(dest_lat_len, 0:basin_cnt))

     allocate(Twght_basin_sum_kmt(dest_lat_len, 0:basin_cnt, level_cnt))

     Twght_basin_sum_kmt = c0

     do k = 1,level_cnt
        do j = 1,grid_var%nlat
           do i = 1,grid_var%nlon
              if (k > grid_var%kmt(i,j) .or. rmask(i,j) == 0) cycle
              basin_ind = abs(rmask(i,j))
              do j2 = 0,wght_cnt(i,j)-1
                 j3 = lat_axis_ind0(i,j) + j2
                 j4 = Twght_ind0(i,j) + j2

                 Twght_basin_sum_kmt(j3, basin_ind, k) = &
                      Twght_basin_sum_kmt(j3, basin_ind, k) + Twght(j4)
              end do
           end do
        end do
     end do

     do k = 1,level_cnt
        do basin_ind = 1,basin_cnt
           do j3 = 1,dest_lat_len
              Twght_basin_sum_kmt(j3, 0, k) = &
                   Twght_basin_sum_kmt(j3, 0, k) + &
                   Twght_basin_sum_kmt(j3, basin_ind, k)
           end do
        end do
     end do

  end subroutine gen_weights

  !-----------------------------------------------------------------------------

  subroutine compute_zon_avg(outfilename, grid_var, infilename, normalizing, &
       rmask, time_const)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     character(len=*), intent(in) :: &
          outfilename,     & ! name of file where dims & vars are to be defined
          infilename         ! name of file where dims & vars come from

     type(POP_grid), intent(in) :: &
          grid_var           ! grid to generate destination axis from

     logical(kind=log_kind), intent(in) :: &
          normalizing        ! compute area averages (.T.) or area sums (.F.)

     integer(kind=int_kind), dimension(:,:), intent(in) :: &
          rmask              ! basin mask

     logical(kind=log_kind), intent(in) :: &
          time_const         ! are time constant variables to be averaged?

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     character(len=*), parameter :: &
          subname = 'zonal_avg_mod:compute_zon_avg'

     integer(kind=int_kind) :: &
          stat,            & ! status from NetCDF calls
          in_ncid,         & ! file ID for infile
          out_ncid,        & ! file ID for outfile
          in_nvars,        & ! number of variables in infile
          in_varid,        & ! varid of coordinate variable in infile
          out_varid,       & ! varid of coordinate variable in outfile
          in_varndims,     & ! number of dimensions of variable in infile
          nlon_dimid,      & ! dimid on "nlon" in infile
          nlat_dimid,      & ! dimid on "nlat" in infile
          in_unlimdim,     & ! unlimited dimension from infile
          dimind,          & ! loop index
          depthind,        & ! which dimension corresponds to depth
          swap_int           ! temporary for swapping integers

     logical(kind=log_kind) :: &
          carry              ! carry flag for incrementing in_start

     integer(kind=int_kind), dimension(NF_MAX_VAR_DIMS) :: &
          in_dimids,       & ! dimids of in_varid
          in_dimlens,      & ! dimlens of in_dimids
          in_start,        & ! start index for reading from infile
          in_count,        & ! count for reading from infile
          out_start,       & ! start index for writing to outfile
          out_count,       & ! count for writing to outfile
          in_dimind          ! maps dimensions from infile to outfile

     real(kind=r8) :: &
          msv                ! value to be used where there is no data

     character(len=char_len) :: &
          varname,         & ! variable name
          dimname            ! dimension name

     !--------------------------------------------------------------------------

     call nf_open_wrap(infilename, 0, in_ncid, subname)
     call nf_open_wrap(outfilename, NF_WRITE, out_ncid, subname)

     call nf_inq_unlimdim_wrap(in_ncid, in_unlimdim, subname)
     call nf_inq_varid_wrap(in_ncid, TLONG_name, in_varid, subname)
     call nf_inq_vardimid_wrap(in_ncid, in_varid, in_dimids, subname)
     nlon_dimid = in_dimids(1)
     nlat_dimid = in_dimids(2)

     call nf_inq_nvars_wrap(in_ncid, in_nvars, subname)
     do in_varid = 1,in_nvars

        if (.not. to_comp_avg(in_ncid, in_varid, time_const)) cycle
        varname = ''
        call nf_inq_varname_wrap(in_ncid, in_varid, varname, subname)
        call nf_inq_varid_wrap(out_ncid, trim(varname), out_varid, subname)

        !-----------------------------------------------------------------------
        !   get _FillValue or missing_value value
        !-----------------------------------------------------------------------

        call nf_get_att_wrap(out_ncid, out_varid, '_FillValue', msv, subname, &
             ALLOW=NF_ENOTATT, stat_out=stat)
        if (stat == NF_ENOTATT) then
           call nf_get_att_wrap(out_ncid, out_varid, 'missing_value', msv, subname, &
                ALLOW=NF_ENOTATT, stat_out=stat)
           if (stat == NF_ENOTATT) then
              msv = NF_FILL_DOUBLE
           end if
        end if

        call nf_inq_varndims_wrap(in_ncid, in_varid, in_varndims, subname)
        call nf_inq_vardimid_wrap(in_ncid, in_varid, in_dimids, subname)

        !-----------------------------------------------------------------------
        !   attempt to detect depth dimension, if not found, use surface mask
        !   get dimension lengths and initialize in_start & in_count
        !-----------------------------------------------------------------------

        depthind = -1
        do dimind = 1,in_varndims

           dimname = ''
           call nf_inq_dimname_wrap(in_ncid, in_dimids(dimind), dimname, subname)
           if (dimname(1:3) == 'z_t') depthind = dimind
           if (dimname(1:3) == 'z_w') depthind = dimind
           if (dimname == 'depth') depthind = dimind
           if (dimname == 'Depth') depthind = dimind
           if (dimname == 'DEPTH') depthind = dimind

           call nf_inq_dimlen_wrap(in_ncid, in_dimids(dimind), in_dimlens(dimind), &
                subname)
           in_start(dimind) = 1
           if (in_dimids(dimind) == nlon_dimid) then
              in_count(dimind) = in_dimlens(dimind)
           else if (in_dimids(dimind) == nlat_dimid) then
              in_count(dimind) = in_dimlens(dimind)
           else
              in_count(dimind) = 1
           end if
        end do

        !-----------------------------------------------------------------------
        !   generate out_count & in_dimind, first mapping nlat -> basin
        !   then shift basin to end of array
        !-----------------------------------------------------------------------

        do dimind = 1,in_varndims
           if (in_dimids(dimind) == nlon_dimid) then
              out_count(dimind) = dest_lat_len
           else if (in_dimids(dimind) == nlat_dimid) then
              out_count(dimind) = maxval(abs(rmask)) + 1
           else
              out_count(dimind) = 1
           end if
           in_dimind(dimind) = dimind
        end do

        do dimind = 1,in_varndims-1
           if (out_count(dimind) == maxval(abs(rmask)) + 1 .and. &
                in_dimids(dimind+1) /= in_unlimdim) then
              swap_int = out_count(dimind+1)
              out_count(dimind+1) = out_count(dimind)
              out_count(dimind) = swap_int

              swap_int = in_dimind(dimind+1)
              in_dimind(dimind+1) = in_dimind(dimind)
              in_dimind(dimind) = swap_int
           end if
        end do

        !-----------------------------------------------------------------------
        !   loop over non-nlon,nlat dimensions doing the following
        !   1) read a level
        !   2) compute zonal average of the level
        !   3) set out_start from in_start
        !   4) write out the average
        !   5) advance in_start counters
        !-----------------------------------------------------------------------

        do
           call nf_get_vara_wrap(in_ncid, in_varid, in_start, in_count, &
                var_in_lev, subname)

           if (depthind == -1) then
              call compute_zon_avg_lev(grid_var, normalizing, rmask, 1, msv)
           else
              call compute_zon_avg_lev(grid_var, normalizing, rmask, &
                   in_start(depthind), msv)
           end if

           do dimind = 1,in_varndims
              if (in_dimids(in_dimind(dimind)) /= in_unlimdim) then
                 out_start(dimind) = in_start(in_dimind(dimind))
              else
                 out_start(dimind) = in_start(in_dimind(dimind)) + init_unlimdim_len
              end if
           end do

           call nf_put_vara_wrap(out_ncid, out_varid, out_start, out_count, &
                var_out_lev, subname)

           carry = .true.
           do dimind = 1,in_varndims
              if (in_dimids(dimind) /= nlon_dimid .and. &
                   in_dimids(dimind) /= nlat_dimid .and. carry) then
                 in_start(dimind) = in_start(dimind) + 1
                 carry = (in_start(dimind) > in_dimlens(dimind))
                 if (carry) in_start(dimind) = 1
              end if
           end do
           if (carry) exit
        end do

     end do

     call nf_close_wrap(out_ncid, subname)
     call nf_close_wrap(in_ncid, subname)

  end subroutine compute_zon_avg

  !-----------------------------------------------------------------------------

  subroutine compute_zon_avg_lev(grid_var, normalizing, rmask, k, msv)

     !--------------------------------------------------------------------------
     !   arguments
     !--------------------------------------------------------------------------

     type(POP_grid), intent(in) :: &
          grid_var           ! source grid

     logical(kind=log_kind), intent(in) :: &
          normalizing        ! compute area averages (.T.) or area sums (.F.)

     integer(kind=int_kind), dimension(:,:), intent(in) :: &
          rmask              ! basin mask

     integer(kind=int_kind), intent(in) :: &
          k                  ! depth level

     real(kind=r8), intent(in) :: &
          msv                ! value to use where there is no data

     !--------------------------------------------------------------------------
     !   local variables
     !--------------------------------------------------------------------------

     integer(kind=int_kind) :: &
          i, j,            & ! loop indices
          j2,              & ! loop index into weights for a T cell
          j3,              & ! loop index into dest_lat_axis
          j4,              & ! loop index into Twght
          basin_cnt,       & ! no. of basins (=maxval(abs(rmask)))
          basin_ind          ! basin index of current T cell

     !--------------------------------------------------------------------------


     var_out_lev = c0
     basin_cnt = maxval(abs(rmask))

     do j = 1,grid_var%nlat
        do i = 1,grid_var%nlon
           if (k > grid_var%kmt(i,j) .or. rmask(i,j) == 0) cycle
           basin_ind = abs(rmask(i,j))
           do j2 = 0,wght_cnt(i,j)-1
              j3 = lat_axis_ind0(i,j) + j2
              j4 = Twght_ind0(i,j) + j2

              var_out_lev(j3, basin_ind) = var_out_lev(j3, basin_ind) + &
                 Twght(j4) * var_in_lev(i,j)
           end do
        end do
     end do

     do basin_ind = 1,basin_cnt
        do j3 = 1,dest_lat_len
           var_out_lev(j3, 0) = var_out_lev(j3, 0) + var_out_lev(j3, basin_ind)
        end do
     end do

     if (normalizing) then
        do basin_ind = 0,basin_cnt
           do j3 = 1,dest_lat_len
              if (Twght_basin_sum_kmt(j3, basin_ind, k) > c0) then
                 var_out_lev(j3, basin_ind) = var_out_lev(j3, basin_ind) / &
                      Twght_basin_sum_kmt(j3, basin_ind, k)
              else
                 var_out_lev(j3, basin_ind) = msv
              end if
           end do
        end do
     else
        do basin_ind = 0,basin_cnt
           do j3 = 1,dest_lat_len
              if (Twght_basin_sum_kmt(j3, basin_ind, k) == c0) then
                 var_out_lev(j3, basin_ind) = msv
              end if
           end do
        end do
     end if

  end subroutine compute_zon_avg_lev

  !-----------------------------------------------------------------------------

  subroutine free_zon_avg

     deallocate( &
          dest_lat_axis, &
          dest_lat_axis_edges, &
          wght_cnt, &
          lat_axis_ind0, &
          Twght_ind0, &
          Twght, &
          var_in_lev, &
          var_out_lev )

     if (allocated(Twght_basin_sum_kmt)) deallocate(Twght_basin_sum_kmt)

  end subroutine free_zon_avg

  !-----------------------------------------------------------------------------

end module zonal_avg_mod
