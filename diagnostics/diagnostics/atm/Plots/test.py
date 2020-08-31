        
seas = 'ANN'
#suf = '_obsc.png' 
suf = '_c.png'
pref = 'set3_'+seas+'_'

mo_vars = {'CRU'       :['TREFHT'],
           'WILLMOTT'  :['TREFHT'],
           'LEGATES'   :['TREFHT','PRECT'],
           'JRA25'     :['TREFHT','PREH2O','PSL','SHFLX','LHFLX'],
           'GPCP'      :['PRECT'],
           'XA'        :['PRECT'],
           'SSMI'      :['PRECT'],
           'TRMM'      :['PRECT'],
           'MERRA'     :['PREH2O','PSL'],
           'ERAI'      :['PREH2O','PSL'],
           'ERA40'     :['PREH2O','LHFLX'],
           'NVAP'      :['PREH2O','TGCLDLWP'],
           'AIRS'      :['PREH2O'],
           'SSMI'      :['PREH2O'],
           'LARYEA'    :['SHFLX','QFLX','FLNS','FSNS'],
           'WHOI'      :['LHFLX','QFLX'],
           'UWISC'     :['TGCLDLWP'],
           'ISCCP'     :['FLNS','FSNS','FLDS','FLDSC','FLNSC','FSDS','FSDSC','LWCFSRF','SWCFSRF','CLDHGH','CLDLOW','CLDMED','CLDTOT'],
           'CERES-EBAF':['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF'],
           'CERES'     :['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF'],
           'ERBE'      :['FLUT','FLUTC','FSNTOA','FSNTOAC','LWCF','SWCF'],
           'VISIR'     :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
           'CLOUDSAT'  :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
           'CAL'       :['CLDHGH','CLDLOW','CLDMED','CLDTOT'],
           'ISCCPCOSP' :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK','MEANPTOP','MEANCLDALB'],
           'MISR'      :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
           'MODIS'     :['CLDHGH','CLDLOW','CLDMED','CLDTOT','CLDTHICK'],
           'WARREN'    :['CLDLOW','CLDTOT'],
           'CS2'       :['CLDTOT'] }
mo_extra = ['CLIMODIS','CLWMODIS','IWPMODIS','LWPMODIS','PCTMODIS','REFFCLIMODIS','REFFCLWMODIS',
            'TAUILOGMODIS','TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS','TAUWMODIS','TAUTMODIS']

mm_vars = ['PBLH','PS','PSL','TAUX_OCEAN','TREFHT','TREFHT_LAND','TS','TS_LAND','EP','PRECT','PREH2O',
           'QFLX','FLDS','FLDSC','FLNS','FLNSC','FSDS','FSDSC','FSNS','FSNSC','LHFLX','RESSURF',
           'SHFLX','FLNT','FLNTC','FSNT','FSNTC','LWCF','RESTOM','SOLIN','SWCF','CLDHGH','CLDLOW',
           'CLDMED','CLDTOT','TGCLDIWP','TGCLDLWP','TICLDIWP','TICLDLIQWP','TICLDLWP','VBSTAR_TBSTAR',
           'VPTP_BAR','VBSTAR_QBSTAR','VPQP_BAR','VBSTAR_UBSTAR','VPUP_BAR','AODVIS','AODDUST',
           'CLDTOT_CAL','CLDLOW_CAL','CLDMED_CAL','CLDHGH_CAL','CLDTOT_ISCCPCOSP','CLDTHICK_ISCCPCOSP',
           'CLDTOT_MISR','CLDTHICK_MISR','CLDTOT_MODIS','CLDTHICK_MODIS','CLDTOT_CAL','CLDLOW_CAL',
           'CLDMED_CAL','CLDHGH_CAL','CLDTOT_CS2','CLDTOT_ISCCPCOSP','CLDLOW_ISCCPCOSP','CLDMED_ISCCPCOSP',
           'CLDHGH_ISCCPCOSP','CLDTHICK_ISCCPCOSP','MEANPTOP_ISCCPCOSP','MEANCLDALB_ISCCPCOSP',
           'CLDTOT_MISR','CLDLOW_MISR','CLDMED_MISR','CLDHGH_MISR','CLDTHICK_MISR','CLDTOT_MODIS',
           'CLDLOW_MODIS','CLDMED_MODIS','CLDHGH_MODIS','CLDTHICK_MODIS','CLIMODIS','CLWMODIS',
           'IWPMODIS','LWPMODIS','PCTMODIS','REFFCLIMODIS','REFFCLWMODIS','TAUILOGMODIS',
           'TAUWLOGMODIS','TAUTLOGMODIS','TAUIMODIS','TAUWMODIS','TAUTMODIS']
expectedPlots = []
if 1==2:
    for ob_set,var_list in mo_vars.items():
        for var in var_list:
            expectedPlots.append(pref+var+'_'+ob_set+suf)
    for t in mo_extra:
        expectedPlots.append(pref+t+suf)
else:
    for var in mm_vars:
        expectedPlots.append(pref+var+suf)

print expectedPlots
print len(expectedPlots)
