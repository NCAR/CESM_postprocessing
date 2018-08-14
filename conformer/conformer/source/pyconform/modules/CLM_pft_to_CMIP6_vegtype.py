#! /usr/bin/env python

import time, sys
import numpy as np
from pyconform.physarray import PhysArray, UnitsError, DimensionsError
from pyconform.functions import Function, is_constant


class CLM_pft_to_CMIP6_vegtype_Function(Function):
    key = 'CLM_pft_to_CMIP6_vegtype'
    numargs = 18

    def __init__(self, GPP, vegType, time, lat, lon, grid1d_ixy, grid1d_jxy, grid1d_lon,
                                 grid1d_lat, land1d_lon, land1d_lat, land1d_ityplunit,
                                 pfts1d_lon, pfts1d_lat, pfts1d_active, pfts1d_itype_veg,
                                 pfts1d_wtgcell, pfts1d_wtlunit):

        super(CLM_pft_to_CMIP6_vegtype_Function, self).__init__(GPP, vegType, time, lat, lon, grid1d_ixy, grid1d_jxy, grid1d_lon,
                                 grid1d_lat, land1d_lon, land1d_lat, land1d_ityplunit,
                                 pfts1d_lon, pfts1d_lat, pfts1d_active, pfts1d_itype_veg,
                                 pfts1d_wtgcell, pfts1d_wtlunit)    

    def __getitem__(self, index):


        pGPP = self.arguments[0][index]
        # vegType = grass, shrub, or tree
        vegType = self.arguments[1]
        ptime = self.arguments[2][index]
        plat = self.arguments[3][index]
        plon = self.arguments[4][index]
        pgrid1d_ixy = self.arguments[5][index]
        pgrid1d_jxy = self.arguments[6][index]
        pgrid1d_lon = self.arguments[7][index]
	pgrid1d_lat = self.arguments[8][index]
        pland1d_lon = self.arguments[9][index]
        pland1d_lat = self.arguments[10][index]
        pland1d_ityplunit = self.arguments[11][index]
	ppfts1d_lon = self.arguments[12][index]
        ppfts1d_lat = self.arguments[13][index]
        ppfts1d_active = self.arguments[14][index]
        ppfts1d_itype_veg = self.arguments[15][index]
	ppfts1d_wtgcell = self.arguments[16][index]
        ppfts1d_wtlunit = self.arguments[17][index]

        if index is None:
            return PhysArray(np.zeros((0,0,0)), dimensions=[ptime.dimensions[0],plat.dimensions[0],plon.dimensions[0]])
           
        GPP = pGPP.data
        time = ptime.data 
        lat = plat.data
        lon = plon.data
        grid1d_ixy = pgrid1d_ixy.data
        grid1d_jxy = pgrid1d_jxy.data
        grid1d_lon = pgrid1d_lon.data
        grid1d_lat = pgrid1d_lat.data
        land1d_lon = pland1d_lon.data
        land1d_lat = pland1d_lat.data
        land1d_ityplunit = pland1d_ityplunit.data
        pfts1d_lon = ppfts1d_lon.data
        pfts1d_lat = ppfts1d_lat.data
        pfts1d_active = ppfts1d_active.data
        pfts1d_itype_veg = ppfts1d_itype_veg.data
        pfts1d_wtgcell = ppfts1d_wtgcell.data
        pfts1d_wtlunit = ppfts1d_wtlunit.data
 

	# vegType = grass, shrub, or tree

	# Tolerance check for weights summing to 1
	eps = 1.e-5

	# If 1, pft is active
	active_pft = 1

	# If 1, landunit is veg
	veg_lunit  = 1

	# C3 arctic grass,
	# C3 non-arctic grass,
	# C4 grass
	beg_grass_pfts = 12
	end_grass_pfts = 14

	# broadleaf evergreen shrub - temperate,
	# broadleaf deciduous shrub - temperate,
	# broadleaf deciduous shrub - boreal
	beg_shrub_pfts =  9
	end_shrub_pfts = 11
     
	# needleleaf evergreen tree - temperate,
	# needleleaf evergreen tree - boreal,
	# needleleaf deciduous tree - boreal,
	# broadleaf evergreen tree - tropical,
	# broadleaf evergreen tree - temperate,
	# broadleaf deciduous tree - tropical,
	# broadleaf deciduous tree - temperate,
	# broadleaf deciduous tree - boreal
	beg_tree_pfts  = 1
	end_tree_pfts  = 8

	# Will contain weighted average for grass pfts on 2d grid
	varo_vegType = np.zeros([len(time),len(lat),len(lon)]) 
        tu = np.stack((pfts1d_lon,pfts1d_lat, pfts1d_active), axis=1)

	ind = np.stack((grid1d_ixy,grid1d_jxy), axis=1)

	lu = np.stack((land1d_lon,land1d_lat,land1d_ityplunit), axis=1)

	# Loop over lat/lons
	for ixy in range(len(lon)):
	    for jxy in range(len(lat)):
		grid_indx = -99
		# 1d grid index
		ind_comp = (ixy+1,jxy+1)
		gi = np.where(np.all(ind==ind_comp, axis=1))[0]
		if len(gi) > 0:
		    grid_indx = gi[0] 

		# Check for valid land gridcell
		if grid_indx != -99:   

		    # Gridcell lat/lons
		    grid1d_lon_pt = grid1d_lon[grid_indx]
		    grid1d_lat_pt = grid1d_lat[grid_indx]

		    # veg landunit index for this gridcell
		    t_var = (grid1d_lon_pt, grid1d_lat_pt, veg_lunit)
		    landunit_indx = np.where(np.all(t_var == lu, axis=1))[0]

		    # Check for valid veg landunit
		    if landunit_indx.size > 0: 
			if 'grass' in vegType:
			    t_var = (grid1d_lon_pt,grid1d_lat_pt, active_pft)
			    pft_indx = np.where( np.all(t_var == tu, axis=1) * (pfts1d_wtgcell > 0.) * (pfts1d_itype_veg >= beg_grass_pfts) * (pfts1d_itype_veg <= end_grass_pfts))[0]
			elif 'shrub' in vegType:
			    t_var = (grid1d_lon_pt,grid1d_lat_pt, active_pft)
			    pft_indx = np.where( np.all(t_var==tu, axis=1) * (pfts1d_wtgcell > 0.) * (pfts1d_itype_veg >= beg_shrub_pfts) * (pfts1d_itype_veg <= end_shrub_pfts))[0]
			elif 'tree' in vegType: 
			    t_var = (grid1d_lon_pt,grid1d_lat_pt, active_pft)
			    pft_indx = np.where( np.all(t_var==tu, axis=1) * (pfts1d_wtgcell > 0.) * (pfts1d_itype_veg >= beg_tree_pfts) * (pfts1d_itype_veg <= end_tree_pfts))[0]
                          
			# Check for valid pfts and compute weighted average
			if pft_indx.size > 0:
			    if 'grass' in vegType:
				pfts1d_wtlunit_grass = (pfts1d_wtlunit[pft_indx]).astype(np.float32)
				dum = GPP[:,pft_indx]
				weights = pfts1d_wtlunit_grass / np.sum(pfts1d_wtlunit_grass)
				if np.absolute(1.-np.sum(weights)) > eps:
				   print("Weights do not sum to 1, exiting")
				   sys.exit(-1)
				varo_vegType[:,jxy,ixy] = np.sum(dum * weights)

			    elif 'shrub' in vegType:
				pfts1d_wtlunit_shrub = (pfts1d_wtlunit[pft_indx]).astype(np.float32)
				dum = GPP[:,pft_indx]
				weights = pfts1d_wtlunit_shrub / np.sum(pfts1d_wtlunit_shrub)
				varo_vegType[:,jxy,ixy] = np.sum(dum * weights)

			    elif 'tree' in vegType:
				pfts1d_wtlunit_tree = (pfts1d_wtlunit[pft_indx]).astype(np.float32)
				dum = GPP[:,pft_indx]
				weights = pfts1d_wtlunit_tree / np.sum(pfts1d_wtlunit_tree)     
				varo_vegType[:,jxy,ixy] = np.sum(dum * weights)

			else:
			    varo_vegType[:,jxy,ixy] = 1e+20
		    else:
			varo_vegType[:,jxy,ixy] = 1e+20
		else:
		   varo_vegType[:,jxy,ixy] = 1e+20  


        new_name = 'CLM_pft_to_CMIP6_vegtype({}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{}{})'.format(pGPP.name, 
                                 vegType, ptime.name, plat.name, plon.name, pgrid1d_ixy.name, pgrid1d_jxy.name, pgrid1d_lon.name,
                                 pgrid1d_lat.name, pland1d_lon.name, pland1d_lat.name, pland1d_ityplunit.name,
                                 ppfts1d_lon.name, ppfts1d_lat.name, ppfts1d_active.name, ppfts1d_itype_veg.name,
                                 ppfts1d_wtgcell.name, ppfts1d_wtlunit.name) 

        print 'FINISHED FUNCTION'

        varo_vegType[varo_vegType>=1e+16] = 1e+20
        ma_varo_vegType = np.ma.masked_values(varo_vegType, 1e+20)

        return PhysArray(ma_varo_vegType,  name=new_name, units=pGPP.units)   


def main(argv=None):

    import netCDF4 as nc

    sim   = "clm50_r243_1deg_GSWP3V2_cropopt_nsc_emergeV2F_dailyo_hist"
    f_in  = sim+".clm2.h1.2005-01.nc"
    f_out = sim+".clm2.h1veg.0001-01.nc"
    f_dir = "/glade2/scratch2/mickelso/CMIP6_LND_SCRIPTS/DATA/"
    f_outfir = "/glade2/scratch2/mickelso/CMIP6_LND_SCRIPTS/new/OUTDIR/"

    cdf_file = nc.Dataset(f_dir+f_in,"r")

    ntim = cdf_file.variables['time'][:]
    nlat = cdf_file.variables['lat'][:]
    nlon = cdf_file.variables['lon'][:]

    grid1d_ixy = cdf_file.variables['grid1d_ixy'][:]
    grid1d_jxy = cdf_file.variables['grid1d_jxy'][:]
    grid1d_lon = cdf_file.variables['grid1d_lon'][:]
    grid1d_lat = cdf_file.variables['grid1d_lat'][:]
    land1d_lon = cdf_file.variables['land1d_lon'][:]
    land1d_lat = cdf_file.variables['land1d_lat'][:]
    land1d_ityplunit = cdf_file.variables['land1d_ityplunit'][:]
    pfts1d_lon = cdf_file.variables['pfts1d_lon'][:]
    pfts1d_lat = cdf_file.variables['pfts1d_lat'][:]
    pfts1d_active = cdf_file.variables['pfts1d_active'][:]
    pfts1d_itype_veg = cdf_file.variables['pfts1d_itype_veg'][:]
    pfts1d_wtgcell = cdf_file.variables['pfts1d_wtgcell'][:]
    pfts1d_wtlunit = cdf_file.variables['pfts1d_wtlunit'][:]


    GPP = cdf_file.variables['GPP'][:]

    cdf_file.close()

    out_file = nc.Dataset(f_outfir+f_out,"w")

    time = out_file.createDimension('time',None)
    lat = out_file.createDimension('lat',len(nlat))
    lon = out_file.createDimension('lon',len(nlon))
    gppGrass = out_file.createVariable('gppGrass', 'f4', ('time', 'lat', 'lon'),fill_value=1.e36)
    gppShrub = out_file.createVariable('gppShrub', 'f4', ('time', 'lat', 'lon'),fill_value=1.e36)
    gppTree = out_file.createVariable('gppTree', 'f4', ('time', 'lat', 'lon'),fill_value=1.e36)

    print 'Looking for grass'
    gppGrass[:] = CLM_pft_to_CMIP6_vegtype(GPP, 'grass', ntim, nlat, nlon, grid1d_ixy, grid1d_jxy, grid1d_lon,
                                           grid1d_lat, land1d_lon, land1d_lat, land1d_ityplunit,
                                           pfts1d_lon, pfts1d_lat, pfts1d_active, pfts1d_itype_veg,
                                           pfts1d_wtgcell, pfts1d_wtlunit)
    print 'Looking for shrubs'
    gppShrub[:] = CLM_pft_to_CMIP6_vegtype(GPP, 'shrub', ntim, nlat, nlon, grid1d_ixy, grid1d_jxy, grid1d_lon,
                                           grid1d_lat, land1d_lon, land1d_lat, land1d_ityplunit,
                                           pfts1d_lon, pfts1d_lat, pfts1d_active, pfts1d_itype_veg,
                                           pfts1d_wtgcell, pfts1d_wtlunit)
    print 'Looking for trees'
    gppTree[:] = CLM_pft_to_CMIP6_vegtype(GPP, 'tree', ntim, nlat, nlon, grid1d_ixy, grid1d_jxy, grid1d_lon,
                                           grid1d_lat, land1d_lon, land1d_lat, land1d_ityplunit,
                                           pfts1d_lon, pfts1d_lat, pfts1d_active, pfts1d_itype_veg,
                                           pfts1d_wtgcell, pfts1d_wtlunit) 


    out_file.close()

if __name__ == '__main__':
    main()


      
      
