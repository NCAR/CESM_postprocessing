#!/usr/bin/env python

from __future__ import print_function
import sys

# check the system python version and require 2.7.x or greater
if sys.hexversion < 0x02070000:
    print(70 * '*')
    print('ERROR: {0} requires python >= 2.7.x. '.format(sys.argv[0]))
    print('It appears that you are running python {0}'.format(
            '.'.join(str(x) for x in sys.version_info[0:3])))
    print(70 * '*')
    sys.exit(1)

import os

#
# check the POSTPROCESS_PATH which must be set
#
try:
    os.environ["POSTPROCESS_PATH"]
except KeyError:
    err_msg = ('create_postprocess ERROR: please set the POSTPROCESS_PATH environment variable.' \
                   ' For example on yellowstone: setenv POSTPROCESS_PATH /glade/p/cesm/postprocessing')
    raise OSError(err_msg)

cesm_pp_path = os.environ["POSTPROCESS_PATH"]

#
# activate the virtual environment that was created by create_python_env
#
if not os.path.isfile('{0}/cesm-env2/bin/activate_this.py'.format(cesm_pp_path)):
    err_msg = ('create_postprocess ERROR: the virtual environment cesm-env2 does not exist.' \
                   ' Please run $POSTPROCESS_PATH/create_python_env -machine [machine name]')
    raise OSError(err_msg)

execfile('{0}/cesm-env2/bin/activate_this.py'.format(cesm_pp_path), dict(__file__='{0}/cesm-env2/bin/activate_this.py'.format(cesm_pp_path)))

from pyaverager import PyAverager, specification

#### User modify ####

in_dir='/glade/scratch/aliceb/F1850C5_f02_cntrl/atm//proc/tseries/month_1'
out_dir= '/glade/scratch/aliceb/F1850C5_f02_cntrl/atm/proc/climo/F1850C5_f02_cntrl//F1850C5_f02_cntrl.2-5'
pref= 'F1850C5_f02_cntrl.cam.h0'
htype= 'series'
average = ['dep_ann:2:5', 'dep_djf:2:5', 'dep_mam:2:5', 'dep_jja:2:5', 'dep_son:2:5', 'jan:2:5', 'feb:2:5', 'mar:2:5', 'apr:2:5', 'may:2:5', 'jun:2:5', 'jul:2:5', 'aug:2:5', 'sep:2:5', 'oct:2:5', 'nov:2:5', 'dec:2:5']
collapse_dim = 'lon'
wght= False
ncfrmt = 'netcdfLarge'
serial=False
suffix = 'nc'
clobber = True
date_pattern= 'yyyymm-yyyymm'
var_list = ['CLDLIQ', 'PRECC', 'T', 'TS']

#### End user modify ####

pyAveSpecifier = specification.create_specifier(in_directory=in_dir,
                                  out_directory=out_dir,
                                  prefix=pref,
                                  suffix=suffix,
                                  date_pattern=date_pattern,
                                  hist_type=htype,
                                  avg_list=average,
                                  varlist=var_list,
                                  collapse_dim=collapse_dim,
                                  weighted=wght,
                                  ncformat=ncfrmt,
                                  serial=serial,
                                  clobber=clobber)

PyAverager.run_pyAverager(pyAveSpecifier)
