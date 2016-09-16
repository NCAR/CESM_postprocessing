#!/bin/csh -f
#
#  Generates the html code for depth-level plots of
#  a 3D variable.
#
#  Usage:
#	gen_varz_html.csh var ncol z1 z2 z3 z4 ...
#		where var = variable name
#		     ncol = # of columns per row of links
#		       z1 = depth level #1
#		       z2 = depth level #2
#		       etc.
#


set var = $argv[1]
@ ncol = $argv[2]
@ ndep = $#argv - 2
set depths = ($argv[3-$#argv])

echo "<hr noshade size=2 size="90%">" >! ${var}Z.html
echo "<p>" >> ${var}Z.html
echo "<TH ALIGN=LEFT><font size=+2 color=green>${var} at depth</font>" >> ${var}Z.html
echo "<TABLE>" >> ${var}Z.html
echo "<TR>" >> ${var}Z.html

@ lnk = 1
@ rowlnk = 1
while ($lnk <= $ndep)
  if ($rowlnk > $ncol) then
    echo "<TR>" >> ${var}Z.html
    @ rowlnk = 0
  endif

  echo "  <TH ALIGN=LEFT><A HREF="${var}${depths[$lnk]}.gif">${depths[$lnk]}m</a>&nbsp;" >> ${var}Z.html

  @ lnk++
  @ rowlnk++
end
echo "<TR>" >> ${var}Z.html
echo "</TABLE>" >> ${var}Z.html
exit 0
