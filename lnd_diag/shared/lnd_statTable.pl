#!/usr/bin/perl

# written by Nan Rosenbloom
# July 2007
# Usage:  called by /code/lnd_driver.csh to dynamically generate
# stats table (html) for set_9.ncl in the v3.1 LMWG Diagnostics Package.

# program checks for successful completion of plots; variables not
# successfully plotted are not linked to the html.

# --------------------------------
# get environment variables

  $wkdir     = $ENV{'WKDIR'};
# ASB - runtype not used
##  $runtype   = $ENV{'RUNTYPE'};
  $prefix_1  = $ENV{'prefix_1'};
  $prefix_2  = $ENV{'prefix_2'};
  $diag_home = $ENV{'DIAG_HOME'};
  $cn        = $ENV{'CN'};

# --------------------------------
# input files
# --------------------------------

if ($cn ==  1) { @varList = ("TSA","PREC","ASA","LHEAT","GPP","TLAI"); }
else { @varList = ("TSA","PREC","ASA","LHEAT","FPSN"); }

# --------------------------------
#  Open file and write header
# --------------------------------
$mainFile = $wkdir."/set9_statTable.html";
close(fp_main);
open(fp_main,">"."$mainFile") || die "Can't open main output file ($mainFile) \n";
&mainHeader1($set);

# --------------------------------
#  start main loop 
# --------------------------------
for $var (@varList) 
{
	print("Processing $var\n");
	&tableHeader($var);
	&writePage($var);
}

printf(fp_main "<br clear=left>\n");
printf(fp_main "</TABLE>\n");
printf fp_main "<hr noshade size=2 size=\"100%\">\n";
printf(fp_main "</BODY>\n");
printf(fp_main "</HTML>\n");

close(fp_main);
close(fp_wp);

#  end main loop ------------------------------------------


sub mainHeader1
{
	local($num) = @_;
	$num++;
	$path = "\"http://www2.cgd.ucar.edu/tss/clm/clm/diagnostics/images/NCAR.gif\"";
	printf fp_main "<HTML>\n";
	printf fp_main "<HEAD>\n";
	printf fp_main "<TITLE>LND Variable Definitions</TITLE>\n";
	printf fp_main "</HEAD>\n";
	printf fp_main "<BODY BGCOLOR=\"bisque\">\n";
	printf fp_main "<img src=$path border=1 hspace=10 align=left alt=\"NCAR logo\">\n";
	printf fp_main "<p>\n";
        printf fp_main "<font color=maroon size=+3><b>\n";
        printf(fp_main "<font color=maroon size=+3><b>$prefix_1<br> \n");
        printf(fp_main "and<br>\n");
        printf(fp_main "$prefix_2<br></b></font></a> \n");
	printf fp_main "<TR>\n";
	printf fp_main "</b></font>\n";
	printf fp_main "<br clear=left>\n";
	printf fp_main "<p>\n";
	printf fp_main "<font color=maroon size=+2><b>Set 9 </b></font>\n";
}
sub tableHeader
{

	printf fp_main "<br>\n";
	printf fp_main "<br>\n";
	# printf fp_main "<font color=maroon size=+2>Statistics for $var</font>\n";
	printf(fp_main "<TABLE>\n");
	printf(fp_main "<table style=\"width: 100%; text-align: left;\" border=\"1\" cellpadding=\"2\" cellspacing=\"2\">\n");
	printf(fp_main "<border=\"1\">\n");
	printf(fp_main "<TR>\n");
	printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>$var</font>\n";
	printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>modified</font>\n";
	printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>control</font>\n";
	printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>Comparison </font>\n";
	printf fp_main "<TR>\n";
	printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>Model</font>\n";
	printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>$prefix_1</font>\n";
	printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>$prefix_2</font>\n";
	printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>Summary</font>\n";
	printf fp_main "<TR>\n";
}

sub writePage
{
        undef @fileList;
        $ctr=0;

	# open list of output variables for set
        $inFile = $wkdir."/set9/set9_".$var."_statsOut.txt"; 
        close(fp_in);
        open(fp_in,"<"."$inFile") || die "Can't open set input filelist ($inFile) \n";

	print("Processing Table for $var\n");
        
	# read stats
        $ctr=0;
        $_ = <fp_in>;
        while(<fp_in>)
        {
                @line = split(/\s+/,$_);
		$case1[$ctr]   = @line[2];
		$case2[$ctr]   = @line[3];
		$ctr++;
        }
	# create summary variables
	$summ[0]  =  sprintf("%2.2f",$case1[0]  - $case2[0]);			# RMSE Bias
	$summ[1]  =  sprintf("%2.2f",$case1[1]  - $case2[1]);			# RMSE % area (case2 - c1)
	$summ[2]  =  sprintf("%2.2f",abs($case1[2])  - abs($case2[2]));		# Ann Diff
	$summ[3]  =  sprintf("%2.2f",$case1[3]  - $case2[3]);			# Ann Bias % area
	$summ[4]  =  sprintf("%2.2f",abs($case1[4])  - abs($case2[4]));		# Avg DJF diff
	$summ[5]  =  sprintf("%2.2f",$case1[5]  - $case2[5]);			# DJF Bias % area
	$summ[6]  =  sprintf("%2.2f",abs($case1[6])  - abs($case2[6]));		# Avg MAM Diff
	$summ[7]  =  sprintf("%2.2f",$case1[7]  - $case2[7]);			# MAM Bias % area
	$summ[8]  =  sprintf("%2.2f",abs($case1[8])  - abs($case2[8]));		# Avg JJA Diff
	$summ[9]  =  sprintf("%2.2f",$case1[9]  - $case2[9]);			# JJA Bias % area
	$summ[10] =  sprintf("%2.2f",abs($case1[10]) - abs($case2[10]));	# Avg SON Diff
	$summ[11] =  sprintf("%2.2f",$case1[11] - $case2[11]);			# SON Bias % area
	$summ[12] =  sprintf("%2.2f",$case1[12] - $case2[12]);			# Diff % good r area (> 0.9)

	$c = 0;
	while ($c < $ctr)
	{
	print("Ctr = $ctr -- c = $c\n");
	   if ($c ==  0) {$comment1 = "RMSE";     $comment2 = "RMSE % Area";}
	   if ($c ==  2) {$comment1 = "ANN Bias"; $comment2 = "ANN Bias % Area";}
	   if ($c ==  4) {$comment1 = "DJF Bias"; $comment2 = "DJF Bias % Area";}
	   if ($c ==  6) {$comment1 = "MAM Bias"; $comment2 = "MAM Bias % Area";}
	   if ($c ==  8) {$comment1 = "JJA Bias"; $comment2 = "JJA Bias % Area";}
	   if ($c == 10) {$comment1 = "SON Bias"; $comment2 = "SON Bias % Area";}
	   if ($c == 12) {$comment1 = "% Area with r>0.9"; 
	   		printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>$comment1</font>\n";
			printf fp_main " <TH ALIGN=LEFT>$case1[$c]\n";  
			printf fp_main " <TH ALIGN=LEFT>$case2[$c]\n";  
               		if ($summ[$c] > 0.0) { printf fp_main " <TH ALIGN=LEFT><font color=green>+$summ[$c]</font>\n"; }
               		else                 { printf fp_main " <TH ALIGN=LEFT><font color=red>-$summ[$c]</font>\n"; }
			printf fp_main " <TR> \n";  
	      $c++;
	    } else {
	      # raw  numbers
	      printf("firstline = $c -- $case1[$c] == $case2[$c]\n");
	      printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>$comment1</font>\n";
			printf fp_main " <TH ALIGN=LEFT>$case1[$c]\n";  
			printf fp_main " <TH ALIGN=LEFT>$case2[$c]\n";  
			# a negative change is good, b/c it shows that case2 is less than case1,  
			# which indicates the model has improved.
                	if   ($summ[$c] <= 0.0) { printf fp_main " <TH ALIGN=LEFT><font color=green>$summ[$c]</font>\n"; }
                	else                    { printf fp_main " <TH ALIGN=LEFT><font color=red>+$summ[$c]</font>\n"; }
			printf fp_main " <TR> \n";  
	      $c++;
	      # areal increases
	      printf("next line = $c -- $case1[$c] == $case2[$c]\n");
	      printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>$comment2</font>\n"; 
			printf fp_main " <TH ALIGN=LEFT>$case1[$c]\n"; 
			printf fp_main " <TH ALIGN=LEFT>$case2[$c]\n"; 
			# a positive change is good, b/c it shows that the area of case2 is greater than case1,  
			# which indicates the model has improved.
                	if ($summ[$c] >= 0.0) { printf fp_main " <TH ALIGN=LEFT><font color=green>+$summ[$c]</font>\n"; }
                	if ($summ[$c] < 0.0) { printf fp_main " <TH ALIGN=LEFT><font color=red>$summ[$c]</font>\n";   }
			printf fp_main " <TR> \n";  
	      $c++;
	    }
	}

	printf fp_main "<TR>\n"; 
}
