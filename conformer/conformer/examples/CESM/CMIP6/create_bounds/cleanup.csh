#!/bin/csh

cd /glade/p/work/mickelso/cesm_sandbox/cesm2_0_beta03-POSTPROC/postprocessing/conformer/conformer/scripts

./xconform -s -f ../examples/CESM/CMIP6/create_bounds/atmos_bounds.json -m ../source/pyconform/modules/commonfunctions.py /glade/scratch/mickelso/archive/b.e20.B1850.f09_g17.historical5/atm/proc/tseries/month_1/b.e20.B1850.f09_g17.historical5.cam.h0.*
ncks -O -x -v mc 192x288x32.nc 192x288x32.nc
ncrename -O -v lat,latitude 192x288x32.nc 192x288x32.nc
ncrename -O -v lon,longitude 192x288x32.nc 192x288x32.nc
ncrename -O -v lon_bnds,longitude_bnds 192x288x32.nc 192x288x32.nc
ncrename -O -v lat_bnds,latitude_bnds 192x288x32.nc 192x288x32.nc
ncatted -O -a ,global,d,, -h 192x288x32.nc 192x288x32.nc

./xconform -s -f ../examples/CESM/CMIP6/create_bounds/lnd_bounds.json -m ../source/pyconform/modules/commonfunctions.py /glade/scratch/mickelso/archive/b.e20.B1850.f09_g17.historical5/lnd/proc/tseries/month_1/b.e20.B1850.f09_g17.historical5.clm2.h0.SOILLIQ.000101-000212.nc /glade/scratch/mickelso/archive/b.e20.B1850.f09_g17.historical5/lnd/proc/tseries/month_1/b.e20.B1850.f09_g17.historical5.clm2.h0.SOILICE.000101-000212.nc
ncks -O -x -v mrlsl 192x288x25.nc 192x288x25.nc
ncrename -O -v lat,latitude 192x288x25.nc 192x288x25.nc
ncrename -O -v lon,longitude 192x288x25.nc 192x288x25.nc
ncrename -O -v lon_bnds,longitude_bnds 192x288x25.nc 192x288x25.nc
ncrename -O -v lat_bnds,latitude_bnds 192x288x25.nc 192x288x25.nc
ncrename -O -d hist_interval,nbnd 192x288x25.nc 192x288x25.nc
ncatted -O -a ,global,d,, -h 192x288x25.nc 192x288x25.nc

./xconform -s -f ../examples/CESM/CMIP6/create_bounds/ocn_bounds.json -m ../source/pyconform/modules/commonfunctions.py /glade/scratch/mickelso/archive/b.e20.B1850.f09_g17.historical5/ocn/proc/tseries/month_1/b.e20.B1850.f09_g17.historical5.pop.h.IAGE.000101-000212.nc
ncks -O -x -v agessc 384x320x60.nc 384x320x60.nc
ncrename -O -d d2,nbnd 384x320x60.nc 384x320x60.nc
ncatted -O -a ,global,d,, -h 384x320x60.nc 384x320x60.nc
