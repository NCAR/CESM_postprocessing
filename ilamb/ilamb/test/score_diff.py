import numpy as np
import sys
if len(sys.argv) != 3:
    print "usage: python score_diff.py scores1.csv scores2.csv"
    sys.exit(1)
gold = np.recfromcsv(sys.argv[1])
test = np.recfromcsv(sys.argv[2])
assert gold.dtype == test.dtype
ok   = True
for model in gold.dtype.names[1:]:
    if not np.allclose(test[model],gold[model]):
        ok   = False
        diff = np.abs(test[model]-gold[model])/gold[model]
        for i in range(diff.size):
            if diff[i] > 1e-12:
                print "%s | %s | %.6f%% " % (gold['variables'][i],model,diff[i]*100.)
if not ok: sys.exit(1)
print "Test passed"
