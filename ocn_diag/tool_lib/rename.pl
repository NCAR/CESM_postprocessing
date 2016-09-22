#!/usr/bin/perl -w
#
# rename -- 	Perl script to rename files in current
#		directory by substituting string fragments
#
# Usage:  rename <string1> <string2> <wildcardfiledescriptor>	
#
#	Eg., 	>>ls
#		   a0083-01-01.nc
#	   	   a0083-02-01.nc
#		   a0083-03-01.nc
#		>>rename 'a00' 'YES' *.nc
#		>>ls
#                  YES83-01-01.nc
#                  YES83-02-01.nc
#                  YES83-03-01.nc
#
$a = @ARGV;
if ($a < 2) {
   print "Usage: rename <oldstring> <newstring> <wildcardfiledescriptor>\n";
} elsif ($a < 3) {
   print "ERROR: no matching filenames\n";
} else {
        $a = shift(@ARGV);
        $b = shift(@ARGV);
        @files = @ARGV;
        foreach $i (@files) {
                $_ = $i;
                s/$a/$b/g;
                $new = $_;
                rename($i,$new);
        }
}
