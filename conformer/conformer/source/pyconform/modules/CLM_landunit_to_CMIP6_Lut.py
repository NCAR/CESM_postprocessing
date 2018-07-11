#! /usr/bin/env python


import time, sys
import numpy as np
from pyconform.physarray import PhysArray, UnitsError, DimensionsError
from pyconform.functions import Function, is_constant


class CLM_landunit_to_CMIP6_Lut_Function(Function):
    key = 'CLM_landunit_to_CMIP6_Lut'

    def __init__(self, EFLX_LH_TOT, vegType, ntim, nlat, nlon, grid1d_ixy, grid1d_jxy, grid1d_lon,
                              grid1d_lat, land1d_lon, land1d_lat, land1d_ityplunit,
                              land1d_active, land1d_wtgcell, landUse):

        super(CLM_landunit_to_CMIP6_Lut_Function, self).__init__(EFLX_LH_TOT, vegType, ntim, nlat, nlon, grid1d_ixy, grid1d_jxy, grid1d_lon,
                              grid1d_lat, land1d_lon, land1d_lat, land1d_ityplunit,
                              land1d_active, land1d_wtgcell, landUse)
  

    def __getitem__(self, index):

        pEFLX_LH_TOT = self.arguments[0][index]
        vegType = self.arguments[1]
        pntim = self.arguments[2][index]
        pnlat = self.arguments[3][index]
        pnlon = self.arguments[4][index]
        pgrid1d_ixy = self.arguments[5][index]
        pgrid1d_jxy  = self.arguments[6][index]
        pgrid1d_lon = self.arguments[7][index]
        pgrid1d_lat = self.arguments[8][index]
        pland1d_lon = self.arguments[9][index]
        pland1d_lat = self.arguments[10][index]
        pland1d_ityplunit = self.arguments[11][index]
        pland1d_active = self.arguments[12][index]
        pland1d_wtgcell = self.arguments[13][index]
        landUse = self.arguments[14][index]

        if index is None:
            if 'all' in vegType:
                return PhysArray(np.zeros((0,4,0,0)), dimensions=[pntim.dimensions[0],landUse.dimensions[0],pnlat.dimensions[0],pnlon.dimensions[0]])
            else:
                return PhysArray(np.zeros((0,0,0)), dimensions=[pntim.dimensions[0],pnlat.dimensions[0],pnlon.dimensions[0]])

        EFLX_LH_TOT = pEFLX_LH_TOT.data 
        ntim = pntim.data
        nlat = pnlat.data
        nlon = pnlon.data
        grid1d_ixy = pgrid1d_ixy.data
        grid1d_jxy  = pgrid1d_jxy.data
        grid1d_lon = pgrid1d_lon.data
        grid1d_lat = pgrid1d_lat.data
        land1d_lon = pland1d_lon.data
        land1d_lat = pland1d_lat.data
        land1d_ityplunit = pland1d_ityplunit.data
        land1d_active = pland1d_active.data
        land1d_wtgcell = pland1d_wtgcell.data

        missing = 1e+20

	long_name = "latent heat flux on land use tile (lut=0:natveg, =1:pasture, =2:crop, =3:urban)"
	nlut    = 4
	veg     = 0
	pasture    = 1
	crop = 2
	urban   = 3

	# Tolerance check for weights summing to 1
	eps = 1.e-5

	# Will contain landunit variables for veg, crop, pasture, and urban on 2d grid
	#varo_lut_temp = np.full([len(ntim),4,len(nlat),len(nlon)],fill_value=missing)
        #varo_lut = np.ma.masked_values(varo_lut_temp, missing)
        varo_lut = np.zeros([len(ntim),4,len(nlat),len(nlon)])
	# Set pasture to fill value
	varo_lut[:,pasture,:,:] = 1e+20 

	# If 1, landunit is active
	active_lunit = 1
	# If 1, landunit is veg
	veg_lunit  = 1
	# If 2, landunit is crop
	crop_lunit  = 2
	# If 7,8, or 9, landunit is urban
	beg_urban_lunit  = 7
	end_urban_lunit  = 9

	# Set up numpy array to compare against
	t = np.stack((land1d_lon,land1d_lat,land1d_active,land1d_ityplunit), axis=1)
	tu = np.stack((land1d_lon,land1d_lat,land1d_active), axis=1)

	ind = np.stack((grid1d_ixy,grid1d_jxy), axis=1)

	# Loop over lat/lons
	for ixy in range(len(nlon)):
	    for jxy in range(len(nlat)):

		grid_indx = -99 
		# 1d grid index
		ind_comp = (ixy+1,jxy+1)
		gi = np.where(np.all(ind==ind_comp, axis=1))[0]
		if len(gi) > 0:
		    grid_indx = gi[0]

		landunit_indx_veg = 0.0
		landunit_indx_crop = 0.0
		landunit_indx_urban = 0.0
		# Check for valid land gridcell
		if grid_indx != -99:
     
		    # Gridcell lat/lons
		    grid1d_lon_pt = grid1d_lon[grid_indx]
		    grid1d_lat_pt = grid1d_lat[grid_indx]

		    # veg landunit index for this gridcell
		    t_var = (grid1d_lon_pt, grid1d_lat_pt, active_lunit, veg_lunit) 
		    landunit_indx_veg = np.where(np.all(t_var == t, axis=1) * (land1d_wtgcell>0))[0]
		    
		    # crop landunit index for this gridcell
		    t_var = (grid1d_lon_pt, grid1d_lat_pt, active_lunit, crop_lunit)
		    landunit_indx_crop = np.where(np.all(t_var == t, axis=1) * (land1d_wtgcell>0))[0]

		    # urban landunit indices for this gridcell
		    t_var = (grid1d_lon_pt, grid1d_lat_pt, active_lunit)
		    landunit_indx_urban = np.where( np.all(t_var == tu, axis=1) * (land1d_ityplunit>=beg_urban_lunit) * (land1d_ityplunit<=end_urban_lunit) * (land1d_wtgcell>0))[0]

		    # Check for valid veg landunit 
		    if landunit_indx_veg.size > 0:
			varo_lut[:,veg,jxy,ixy] = EFLX_LH_TOT[:,landunit_indx_veg].squeeze()
		    else:
			varo_lut[:,veg,jxy,ixy] = 1e+20 

		    # Check for valid crop landunit
		    if landunit_indx_crop.size > 0:
			varo_lut[:,crop,jxy,ixy] = EFLX_LH_TOT[:,landunit_indx_crop].squeeze()
		    else:
			varo_lut[:,crop,jxy,ixy] = 1e+20 

		    # Check for valid urban landunit and compute weighted-average
		    if landunit_indx_urban.size > 0:
			dum = EFLX_LH_TOT[:,landunit_indx_urban].squeeze()
			land1d_wtgcell_pts = (land1d_wtgcell[landunit_indx_urban]).astype(np.float32)
			weights = land1d_wtgcell_pts / np.sum(land1d_wtgcell_pts)
			if (np.absolute(1. - np.sum(weights)) > eps):
			    print ("Weights do not sum to 1, exiting")
			    sys.exit(-1)
			varo_lut[:,urban,jxy,ixy] = np.sum(dum * weights)
		    else:
			varo_lut[:,urban,jxy,ixy] = 1e+20 
                else:
                    varo_lut[:,:,jxy,ixy] = 1e+20 

        new_name = 'CLM_landunit_to_CMIP6_Lut({}{}{}{}{}{}{}{}{}{}{}{}{})'.format(pEFLX_LH_TOT.name, 
                              pntim.name, pnlat.name, pnlon.name, pgrid1d_ixy.name, pgrid1d_jxy.name, pgrid1d_lon.name,
                              pgrid1d_lat.name, pland1d_lon.name, pland1d_lat.name, pland1d_ityplunit.name,
                              pland1d_active.name, pland1d_wtgcell.name) 

        varo_lut[varo_lut>=1e+15] = 1e+20
        mvaro_lut = np.ma.masked_values(varo_lut, 1e+20) 

        if 'crop' in vegType:  
	    return PhysArray(mvaro_lut[:,crop,:,:],  name=new_name, units=pEFLX_LH_TOT.units)
        elif 'veg' in vegType:         
            return PhysArray(mvaro_lut[:,veg,:,:],  name=new_name, units=pEFLX_LH_TOT.units)
        elif 'urban' in vegType:         
            return PhysArray(mvaro_lut[:,urban,:,:],  name=new_name, units=pEFLX_LH_TOT.units)
        elif 'pasture' in vegType:         
            return PhysArray(mvaro_lut[:,pasture,:,:],  name=new_name, units=pEFLX_LH_TOT.units)
        elif 'nlut' in vegType:         
            return PhysArray(mvaro_lut[:,nlut,:,:],  name=new_name, units=pEFLX_LH_TOT.units)
        elif 'all' in vegType:
            return PhysArray(mvaro_lut,  name=new_name, units=pEFLX_LH_TOT.units)
