#!/bin/csh -f
#
#  Generates the html code for depth-level plots of
#  multiple 3D variables which together form a block.
#
#  Usage:
#	gen_multivarz_html.csh nvar var1 var2 ... ncol z1 z2 z3 z4 ...
#		where 
#	             nvar = # of variables
#		     var1 = variable name #1, etc
#		     ncol = # of columns per row of links
#		       z1 = depth level #1, etc
#

set nvar = $argv[1]
@ tmp = (2 + $nvar) - 1
set vars = ($argv[2-$tmp])
@ tmp = (2 + $nvar)
@ ncol = $argv[$tmp]
@ ndep = ($#argv - $tmp) 
@ tmp = (2 + $nvar) + 1
set depths = ($argv[$tmp-$#argv])


echo "<hr noshade size=2 size="90%">" >! tmp.html
echo "<p>" >> tmp.html
echo "<TH ALIGN=LEFT><font size=+2 color=green>${MODULETITLE}</font>" >> tmp.html
echo "<TABLE>" >> tmp.html
echo "<TR>" >> tmp.html

@ iv = 1
while ($iv <= $nvar)

set curvar = $vars[$iv]

@ lnk = 1
@ rowlnk = 1
while ($lnk <= $ndep)
  if ($rowlnk > $ncol) then
    echo "<TR>" >> tmp.html
    @ rowlnk = 0
  endif
  if ($lnk == 1) then
   echo "  <TH ALIGN=LEFT>${curvar}: &nbsp;" >> tmp.html
  endif
  echo "  <TH ALIGN=LEFT><A HREF="${curvar}${depths[$lnk]}.gif">${depths[$lnk]}m</a>&nbsp;" >> tmp.html

  @ lnk++
  @ rowlnk++
end
echo "<TR>" >> tmp.html
  @ iv++
end
echo "</TABLE>" >> tmp.html
exit 0
