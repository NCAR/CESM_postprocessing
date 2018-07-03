#!/usr/bin/env python
import sys

try:
    from asaptools import simplecomm
except:
    print 'asaptools not loaded. exiting...'
    sys.exit(1)

try:
    scomm = simplecomm.create_comm(serial=False)
except:
    print 'unable to create scomm. exiting...'
    sys.exit(1)

rank = scomm.get_rank()
size = scomm.get_size()

if scomm.is_manager():

    l = range(10)

    for i in l:
        scomm.ration(i)
        print '{0}/{1}: Sent {2!r}'.format(rank, size, i)

    for i in range(scomm.get_size()-1):
        scomm.ration(None)
        print '{0}/{1}: Sent None'.format(rank, size)

else:

    i = -1
    while i is not None:
        i = scomm.ration()
        print '{0}/{1}: Recvd {2!r}'.format(rank, size, i)

print '{0}/{1}: Out of loop'.format(rank, size)

scomm.sync()
if scomm.is_manager():
    print 'Done.'

sys.exit(0)
