#!/bin/csh -f
#
#  Removes the footer information from an html file so that
#  additional body html can be appended.
#
#  Assumes:  footer looks like
#	/fis/cgd/home/yeager/ccsm_diag/html/footer.html
#
#  Usage:
#	removefooter.csh <htmlfile>
#

set file = $1

sed '/\/BODY/d' $file > tmp.html
sed '/\/HTML/d' tmp.html >! $file
sed '$d' $file >! tmp.html
sed '$d' tmp.html >! $file
sed '$d' $file >! tmp.html
\mv -f tmp.html $file

exit 0
