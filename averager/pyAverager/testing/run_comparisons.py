#!/usr/bin/env python

import glob,sys,os
from subprocess import Popen, PIPE
import yaml

class bcolors:
    PASS = '\033[92m'
    FAIL = '\033[91m'
    EXPECTED = '\033[93m'
    RESET = '\033[0m' 

def compare(command, type, log, expected):
    p = Popen(command, stdout=PIPE, stderr=PIPE,shell=True)
    out,err = p.communicate()
    if len(err) > 0:
        if 'No such file or directory' in err or 'FILE FORMATS' in err:
            err_m = err
        else:
            error_a = err.split(':')
            err_m = error_a[3:]
        if expected:
            print bcolors.EXPECTED + 'EXPECTED FAIL ' + type + ' ' + f
            print bcolors.EXPECTED + err
            print bcolors.RESET
            log['EXPECTED'].append(type + ' ' + f + ' ' + str(err_m))
        else:
            print bcolors.FAIL + 'FAIL ' + type + ' ' + f
            print bcolors.FAIL + err
            print bcolors.RESET
            log['FAIL'].append(type + ' ' + f + ' ' + str(err_m))
    else:
        print bcolors.PASS + 'PASS ' + type + ' ' + f
        print bcolors.RESET
        log['PASS'].append(type + ' ' + f)

    return log

# Setup report log
log = {'PASS':[],'FAIL':[],'EXPECTED':[]}

# Read in testing info
stream = file('config.yaml','r')
testing_info = yaml.load(stream)

test_root = testing_info['test_dir']
test_comps = testing_info['test_comps']
test_types = testing_info['test_types']
control_dir = testing_info['control_dir']

# Loop through types and model components to compare slice against series
for tt in test_types:
    for comp in test_comps:
    
        test_dir = test_root+'/'+tt+'/'
        glob_string = test_dir + '/' + comp + '/slice/*.nc'

        file_list = []
        for path in glob.glob(glob_string):
            dirname,f_name = os.path.split(path)
            file_list.append(f_name)

        for f in file_list:
            expected_f = False
            file1 = test_dir + '/' + comp + '/slice/' + f
            file2 = test_dir + '/' + comp + '/series/' + f
            cont_file = control_dir + '/' + comp + '/' + f
            if 'atm' in comp or 'atm_se' in comp:
                var = 'T'
            elif 'lnd' in comp:
                var = 'TG'
            elif 'ice' in comp:
                if 'ice_vol_' in f:
                    var = 'vai_mo_nh'
                else:
                    expected_f = True # Expected failure because there are no values at the equator in series files
                    var = 'Tair'
            else:
                var = 'TEMP'

             # Test each files' slice and series results agaist each other
            command = 'nccmp -d -v ' + var + ' ' + file1 + ' ' + file2
            log = compare(command,'/'+tt+'/slice-series/',log,expected_f)

            # Test each files' slice and series results against the trusted values
            # Series Comparison
            command = 'nccmp -d -v ' + var + ' ' + cont_file + ' ' + file2
            log = compare(command,'/'+tt+'/control-series/',log,expected_f)
            # Slice Comparison 
            expected_f = False # All control - slice tests should pass
            command = 'nccmp -d -v ' + var + ' ' + cont_file + ' ' + file1
            log = compare(command,'/'+tt+'/control-slice/',log,expected_f)

# Summary information
pass_len = len(log['PASS'])
fail_len = len(log['FAIL'])
expected_len = len(log['EXPECTED'])
total = pass_len + fail_len + expected_len

# Write the summary file to a file
summary = open('test_summary.out','w')
summary.write('-------------------------------------------------------------------'+'\n')
summary.write('Comparisons that PASSED:\n')
for test in log['PASS']:
    summary.write(test+'\n')
summary.write('-------------------------------------------------------------------'+'\n')
summary.write('Comparisons that FAIL (Expected):'+'\n')
for test in log['EXPECTED']:
    summary.write(test+'\n')
summary.write('-------------------------------------------------------------------'+'\n')
summary.write('Comparisons that FAIL:'+'\n')
for test in log['FAIL']:
    summary.write(test+'\n')
summary.write('-------------------------------------------------------------------'+'\n')
summary.write('Summary:'+'\n')
summary.write('Pass: '+str(pass_len)+'/'+str(total)+'\n')
summary.write('Expected Fail: '+str(expected_len)+'/'+str(total)+'\n')
summary.write('Fail: '+str(fail_len)+'/'+str(total)+'\n')
summary.write('-------------------------------------------------------------------'+'\n')
summary.close()

# Print summary on the terminal
print '-------------------------------------------------------------------'
print 'Summary:'
print bcolors.PASS + 'Pass: ' + str(pass_len) + '/' + str(total)
print bcolors.EXPECTED + 'Expected Fail: '+str(expected_len)+'/'+str(total)
print bcolors.FAIL + 'Fail: ' + str(fail_len) + '/' + str(total)
print bcolors.RESET
if fail_len > 0:
    print 'Failed Comparisons:'
    for test in log['FAIL']:
        print test
print '-------------------------------------------------------------------'

