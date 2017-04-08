#!/usr/bin/env python

import os, string

file = open('time_series_vars.txt','r')
buffer = file.read()
tseries = buffer.split('\n')
tseries.pop()
for stream in tseries:
    stream.replace('  Time-Series Variables: ','')
    stream.replace('[','')
    stream.replace(']','')
    vars = stream.split(',')
    print len(vars)
