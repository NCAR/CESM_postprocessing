#!/bin/bash
     for fl in *.ncl; do
     mv $fl $fl.old
     sed 's/(\"ps\",/(img_format,/g' $fl.old > $fl
#     rm -f $fl.old
     done