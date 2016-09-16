#!/bin/csh -f
#
#  Generates time-series netcdf files from POP ocean
#  log and transport files residing on mass store.  Based
#  on K Lindsay's update_plots.csh, this version creates
#  the netcdf files but does not generate plots.
#
#  Invoke as
#	gen_poplog_ts_netcdfs.csh MSROOT CASE WEBMACH WEBDIR
#

set MSROOT = $1
set CASE = $2
set WEBMACH = $3
set WEBDIR = $4
setenv LOG_DIR  	/${MSROOT}/${CASE}/ocn/logs
setenv TRANSPORT_DIR	/${MSROOT}/${CASE}/ocn/hist
setenv TRANSPORT_ROOT ${CASE}.pop.dt
setenv BASEDATE 0000-01-01
set max_msread_cnt  = 20

# grab list of processed files and timeseries files
# generate current listing of log and transport files
#
scp "${WEBMACH}:${WEBDIR}/{processed_{log,transport}_dir_msls,transports.nc,tavg.nc,diagnostics.nc}" .
hsi -P -P "ls -l ${LOG_DIR}" | grep ocn.log > current_log_dir_msls &
hsi -P -P "ls -l ${TRANSPORT_DIR}" | grep ${TRANSPORT_ROOT} > current_transport_dir_msls &
wait

# generate list of files to be processed, and read them in
# only post $max_msread_cnt msread's at a time
#
\rm -f needed_logfiles needed_transportfiles
touch needed_logfiles needed_transportfiles

@ msread_cnt = 0
foreach file (`cat current_log_dir_msls`)
   if (! { grep ${file} processed_log_dir_msls >& /dev/null }) then
      echo ${file} >> needed_logfiles
      if (! -f ${file}) then
       hsi -P "get ${file} : ${LOG_DIR}/${file}"
         @ msread_cnt++
         if ($msread_cnt >= $max_msread_cnt) then
            wait
            @ msread_cnt = 0
         endif
      endif
   endif
end

foreach file (`cat current_transport_dir_msls`)
   if (! { grep ${file} processed_transport_dir_msls >& /dev/null }) then
      echo ${file} >> needed_transportfiles
      if (! -f ${file}) then
       hsi -P "get ${file} : ${TRANSPORT_DIR}/${file}" &
         @ msread_cnt++
         if ($msread_cnt >= $max_msread_cnt) then
            wait
            @ msread_cnt = 0
         endif
      endif
   endif
end

if ($msread_cnt > 0) wait

# process files that have just been read in
#
if (-z tavg.nc) \rm -f tavg.nc
if (-z diagnostics.nc) \rm -f diagnostics.nc
log2cdf_v0.3.pl -A -f needed_logfiles

if (-z transports.nc) \rm -f transports.nc
transports2cdf_v0.1.pl -A -runid ${CASE} -basedate ${BASEDATE} -f needed_transportfiles

# append names of files that have just been read to list of processed files
#
cat needed_logfiles >> processed_log_dir_msls
cat needed_transportfiles >> processed_transport_dir_msls

# generate time series of annual means from monthly means
#
nc_mon_to_ann.csh diagnostics.nc ann_diagnostics.nc
nc_mon_to_ann.csh tavg.nc        ann_tavg.nc
nc_mon_to_ann.csh transports.nc  ann_transports.nc

# extract nino indices from tavg.nc
# only grab full years, assumes NINO_MON_SKIP is a multiple of 12
# generate nino index anomalies
#
if ( ! ${?NINO_MON_SKIP}) then
   setenv NINO_MON_SKIP 0
endif

set tavg_rec_cnt = `ncdump -h tavg.nc | grep 'time = ' | awk '{print $6}' | tr '(' ' '`
@ tavg_rec_cnt_div_12 = $tavg_rec_cnt / 12
@ tavg_end_rec = 12 * $tavg_rec_cnt_div_12 - 1

ncks -O -d time,$NINO_MON_SKIP,$tavg_end_rec -v NINO_1_PLUS_2,NINO_3,NINO_3_POINT_4,NINO_4 tavg.nc nino.nc
nc_time_detrend.csh nino.nc nino_detrend.nc
nc_mon_anom.csh nino_detrend.nc nino_anom.nc

# copy files to WEBMACH
#
scp processed_{log,transport}_dir_msls *transports.nc *tavg.nc *diagnostics.nc nino_anom.nc ${WEBMACH}:${WEBDIR}

exit 0

