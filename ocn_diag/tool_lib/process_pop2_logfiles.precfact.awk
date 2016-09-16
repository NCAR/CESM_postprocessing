#! /usr/bin/awk -f
#
# process_pop2_logfiles.precfact.awk -- 
#	prints global precip factor recorded
#	in pop2 log files.
#
# Usage: process_pop2_logfiles.precfact.awk y0=year0 y1=year1 <cpl6logfile(s)>
#
#
BEGIN {
  tstampcnt = 0
  year = 0
}
/set ladjust_precip/ {
   ladjust_precip = $4
}
/set lsend_precip_fact/ {
   lsend_precip_fact = $4
}
/precipitation factor/ {
   precip_fact = $5
}
/ocn date/ {
   yearnew = int(substr($4,1,4))
   if (yearnew != year) {
    year = yearnew
    if (lsend_precip_fact == ".true." && ladjust_precip == ".true.") {
       printf("%8i%10.3f\n",year,precip_fact)
    }
   }
}

END {
}

