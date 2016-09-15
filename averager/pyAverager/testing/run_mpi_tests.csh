#!/bin/csh
#BSUB -n 32 
#BSUB -q geyser
#BSUB -N 
#BSUB -W 12:00
#BSUB -R "span[ptile=8]"
#BSUB -P STDD0002 
#BSUB -o pyAve.%J.out         # output file name in which %J is replaced by the job ID
#BSUB -e pyAve.%J.err         # error file name in which %J is replaced by the job ID

module load python 
module load all-python-libs
setenv PYTHONPATH /glade/p/work/mickelso/pyAverager/pyAverager/pyaverager/:$PYTHONPATH


set testing_root = /glade/scratch/mickelso/averager_sandbox/
set control_root = /glade/p/tdd/asap/pyAverager/testing_compare/ 

# Control which test sets will get ran
# 1 = on, 0 = off 
set set_1 = 1 # Default setups
set set_2 = 1 # Reuse computed averages from set_1
set set_3 = 1 # Compute averages without reusing previously calculated averages from same run (ie monthlies to compute seasons)
set set_4 = 0 # Run a smaller round of serial (non-parallel) testing


set script_list = (control_atm_series.py control_atm_slice.py control_atm_se_series.py control_atm_se_slice.py control_ice_series.py control_ice_slice.py control_lnd_series.py control_lnd_slice.py control_ocn_series.py control_ocn_slice.py control_other.py)

set components = (atm/slice atm/series atm_se/slice atm_se/series ice/slice ice/series lnd/slice lnd/series ocn/slice ocn/series other/gfdl)

set tt=""

# The first set runs through typical averages
if ($set_1 == 1) then
set first_dir = 'results'
set first_root_path = ${testing_root}'/'${first_dir}'/'
foreach comp ($components)
  set f_path =  ${first_root_path}${comp}
  if (-d $f_path) then
    echo $f_path 'exits.'
    set fns = `ls ${f_path}`
    foreach f ($fns)
      echo 'Removing '${f_path}'/'${f}
      rm ${f_path}'/'${f}
    end
  else
    echo 'Will make ' $f_path
    mkdir -p ${f_path}
  endif
end
setenv RESULTS_DIR $first_root_path 
foreach s ($script_list)
   echo 'Starting ' 'default_tests/'$s
   mpirun.lsf 'default_tests/'${s}
end
set tt = "$tt $first_dir,"
endif

# The second set of runs will reuse some of the averages created in the first set
if ($set_1 == 1 && $set_2 == 1) then
set second_dir = 'reuse'
set second_root_path = ${testing_root}'/'${second_dir}'/'
if (-d $second_root_path) then
  rm -fr $second_root_path 
endif
cp -r $first_root_path $second_root_path 
setenv RESULTS_DIR $second_root_path
foreach s ($script_list)
   echo 'Starting ' 'default_tests/'$s
   mpirun.lsf 'default_tests/'${s}
end
set tt = "$tt $second_dir,"
endif

# The third set of runs relies on no depend averages
if ($set_3 == 1) then
set third_dir = 'noDepend'
set third_root_path = ${testing_root}'/'${third_dir}'/'
foreach comp ($components)
  set f_path =  ${third_root_path}${comp}
  if (-d $f_path) then
    echo $f_path 'exits.'
    set fns = `ls ${f_path}`
    foreach f ($fns)
      echo 'Removing '${f_path}'/'${f}
      rm ${f_path}'/'${f}
    end
  else
    echo 'Will make ' $f_path
    mkdir -p ${f_path}
  endif
end
setenv RESULTS_DIR $third_root_path
foreach s ($script_list)
   echo 'Starting ' 'noDepend_tests/'$s
   mpirun.lsf 'noDepend_tests/'${s}
end
set tt = "$tt $third_dir,"
endif

# The forth set runs the serial version of the code
if ($set_4 == 1) then
set forth_dir = 'serial'
set forth_root_path = ${testing_root}'/'${forth_dir}'/'
foreach comp ($components)
  set f_path =  ${forth_root_path}${comp}
  if (-d $f_path) then
    echo $f_path 'exits.'
    set fns = `ls ${f_path}`
    foreach f ($fns)
      echo 'Removing '${f_path}'/'${f}
      rm ${f_path}'/'${f}
    end
  else
    echo 'Will make ' $f_path
    mkdir -p ${f_path}
  endif
end
setenv RESULTS_DIR $forth_root_path
foreach s ($script_list)
   echo 'Starting ' 'serial_tests/'$s
   './serial_tests/'${s}
end
set tt = "$tt $forth_dir,"
endif

# Write out yaml testing file needed by the evaluation script
set config_fn = 'config.yaml'
echo 'test_dir: '$testing_root > $config_fn
echo 'test_comps: [atm, atm_se, lnd, ice, ocn]' >> $config_fn
echo 'control_dir: '$control_root >> $config_fn
echo 'test_types: ['$tt']' >> $config_fn


