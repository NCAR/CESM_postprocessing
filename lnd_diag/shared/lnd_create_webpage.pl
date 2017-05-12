#!/usr/bin/perl

# written by Nan Rosenbloom
# January 2005
# Usage:  called by /code/lnd_driver.csh to dynamically generate
# html files for revised LMWG Diagnostics Package.

# program checks for successful completion of plots; variables not
# successfully plotted are not linked to the html.

# --------------------------------
# get environment variables

  $set_1  = $ENV{'set_1'};
  $set_2  = $ENV{'set_2'};
  $set_3  = $ENV{'set_3'};
  $set_4  = $ENV{'set_4'};
  $set_5  = $ENV{'set_5'};
  $set_6  = $ENV{'set_6'};
  $set_7  = $ENV{'set_7'};
  $set_8  = $ENV{'set_8'};
  $set_8_lnd  = $ENV{'set_8_lnd'};
  $set_9  = $ENV{'set_9'};
  $set_10 = $ENV{'set_10'};
  $set_11 = $ENV{'set_11'};
  $set_12 = $ENV{'set_12'};

##  $prefix_1  = $ENV{'prefix_1'};
  $prefix_1  = $ENV{'CASE'};
##  $prefix_2  = $ENV{'prefix_2'};
  $prefix_2  = $ENV{'caseid_2'};

  $wkdir     =    $ENV{'WKDIR'};
  $webdir    =    $ENV{'WEB_DIR'};
##  $diag_code =    $ENV{'DIAG_CODE'};
  $runtype   =    $ENV{'RUNTYPE'};
  $source    =    $ENV{'DIAG_HOME'};
  $cn        =    $ENV{'CN'};
  $clamp     =    $ENV{'CLAMP'};
  $hydro     =    $ENV{'HYDRO'};
  $casa      =    $ENV{'CASA'};
  $paleo     =    $ENV{'paleo'};
  $plot_type =    $ENV{'PLOTTYPE'};

  # turn on CN flag if CLAMP run.
  if ($clamp) { $cn = 1; }

  $obsFlag      = 0;		# 1 = on; 0 = off
  $set1DiffFlag = 0;		# 1 = on; 0 = off
  $set1AnomFlag = 0;            # 1 = on; 0 = off

  if ($runtype eq "model-obs") { 
      $obsFlag = 1;
      $prefix_2 = "Obs";
  }
  else { 
      $set1DiffFlag = 1;
      $set1AnomFlag = 1; 
  }
  if    ($plot_type eq "ps")   { $sfx = ".gif"; }
  elsif ($plot_type eq "png")  { $sfx = ".png"; }
  else			       { die "Check plot type\n"; }

# --------------------------------
# define auxillary files 
# --------------------------------

  # master variable list contains all variable definitions
  $variableMaster = $wkdir."/variable_master.ncl";
  $miss = "missing.txt";

# ------------------------------------------------
#  create master web page that links to index.html
# ------------------------------------------------

  $mainFile = $webdir."/setsIndex.html";
  close(fp_main);
  open(fp_main,">"."$mainFile") || die "Can't open main output file ($mainFile) \n";
  &mainHeader1();


# --------------------------------
#  start main loop 
# --------------------------------

# adding differences plots as difference set (101).
# model vs model comparision includes difference tests for set 1.

##if($set_8_lnd) { $set_8 = 1; }
##if($set_8_lnd) { $set_8 = 'True'; }
if($set_8_lnd eq "True") { $set_8 = 'True'; }
##if($runtype eq "model-obs")   { $set_9=0; }
if($runtype eq "model-obs")   { $set_9 = 'False'; }

@setList = (1,2,3,4,5,6,7,8,9,10,11,12); 
@status = ($set_1, $set_2, $set_3, $set_4, $set_5, $set_6, $set_7,$set_8,$set_9,$set_10,$set_11,$set_12);

for $set (@setList)
{
    print "lnd_create_webpage.pl - set = $set status = @status[$set-1]\n";
##    if( @status[$set-1] == "False") { 
    if( @status[$set-1] eq "False") { 
	&set_Inactive($set); 
    }
##    if( @status[$set-1] == "True") { 
    else {
	print "Creating Web Page for Set $set \n";
    	# list set on main html page and link to set web page
	&set_Active($set);
	
    	# open html file for each active set 
    	$outfile = $webdir."/set".$set."/set".$set.".html";
	print "Creating $outfile \n";
    	close(fp_wp);
    	open(fp_wp,">"."$outfile") || die "Can't open output file ($outfile) \n";
	
    	# create set specific web file and write header information
    	&setHeader($set);

	if ($set ==  1)   { &set1Page; }
	if ($set ==  2)   { &set2Page; }
	if ($set ==  3 || $set == 6) { &set3and6Page; }
	if ($set ==  4)   { &set4Page; } 
	if ($set ==  5)   { &set5Page; } 
	if ($set ==  7)   { &set7Page; } 
	if ($set ==  8)   { &set8Page; }
	if ($set ==  9)   { &set9Page; }
	if ($set ==  10)  { &set10Page; }
	if ($set ==  11)  { &set11Page; }
   if ($set ==  12)  { &set12Page; }
    }
}
&clickablePlotTypes(@status);
printf(fp_main "<br clear=left>\n");
printf(fp_main "<p>\n");
printf(fp_main "</BODY>\n");
printf(fp_main "</HTML>\n");

printf(fp_wp "<TR>\n");
printf(fp_wp "</TABLE>\n");
printf fp_wp "<hr noshade size=2 size=\"100%\">\n";
printf(fp_wp "</BODY>\n");
printf(fp_wp "</HTML>\n");

close(fp_wp);
close(fp_main);

#  end main loop ------------------------------------------


sub mainHeader1
{
	local($num) = @_;
	$num++;
	$path = "\"http://www.cgd.ucar.edu/tss/clm/clm/diagnostics/images/NCAR.gif\"";
	printf fp_main "<HTML>\n";
	printf fp_main "<HEAD>\n";
	printf fp_main "<TITLE>LND_DIAG Diagnostic Plots</TITLE>\n";
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
	printf fp_main "<TABLE>\n";
	printf fp_main "  <TH><A HREF=\"http://www.cgd.ucar.edu/tss/clm/diagnostics/index.html\">\n";
	printf fp_main "<font color=blue>LND_DIAG Diagnostics Plots</font></A>\n";
	printf fp_main "<font color=black>Source: $source\n";
	printf fp_main "</TABLE>\n";
	printf fp_main "<hr noshade size=2 size=\"100%\">\n";
	printf fp_main "<TABLE>\n";
	printf fp_main "<TR>\n";
	printf fp_main "  <TH><font color=red>Set</font>\n";
	printf fp_main "  <TH ALIGN=LEFT><font color=red>Description</font>\n";
	printf fp_main "<TR>\n";

	#print " done writing main file header information \n";
}

sub set_Active
{
        print "active: set = $set\n";
	# write set number
	printf fp_main "  <TH>$set\n";

	# get formal set description
	$description = &setDescription($set);

	# parse for <a href> definition
	@line = split(/\s+/,$description);
	$path = "set".$set."/set".$set.".html";

	if ($set == 2) {
		$s = 1;
		$e = 2;
	}
	else {
	   $s = 0;
	   $e = 1;
	   if ($set == 5) { $e = 0; }
	   if ($set == 7 || $set == 8) { $e = 4; }
	}
	if ($set == 2) { printf fp_main "  <TH ALIGN=LEFT> Horizontal"; }
	else           { printf fp_main "  <TH ALIGN=LEFT>";               }
	printf fp_main "  <A HREF=\"$path\">";
	printf fp_main "@line[$s..$e]"; 
	printf fp_main "</A> ";
	$e++;
	printf fp_main "@line[$e..$#line]\n";
	printf fp_main "<TR>\n";
}

sub set_Inactive
{
        print "Inactive: set = $set\n";
        # write set number
        printf fp_main "  <TH>$set\n";

        # get formal set description
        $description = &setDescription($set);
	@line = split(/\s+/,$description);

        printf fp_main "  <TH ALIGN=LEFT><span style=\"font-style:italic; font-weight: bold; color: rgb(255,0,0);\">";
	printf fp_main "(Inactive)</span> $description\n";
        printf fp_main "<TR>\n";
}

sub setHeader
{

	if ($set == 5 || $set == 9)  { $path = "\"http://www.cgd.ucar.edu/tss/clm/diagnostics/images/3Dglobe.gif\""; }
	else {
		if ($set == 3 | $set == 4) { $sn = "s"; }
		else                       { $sn = "sn";}
	        if (  $set == 8) { $path = "\"http://www.cgd.ucar.edu/tss/clm/diagnostics/images/SET".$set.".jpg\""; }
		else             { $path = "\"http://www.cgd.ucar.edu/tss/clm/diagnostics/images/SET".$set.$sn.".gif\""; }
	}

	# write generalized header
	printf fp_wp "<HTML>\n";
	printf fp_wp "<HEAD>\n";
	printf fp_wp "<TITLE>Set $set Diagnostic Plots</TITLE>\n";
	printf fp_wp "<link rel=\"shortcut icon\" href=$path>\n";
	printf fp_wp "</HEAD>\n";
	printf fp_wp "<BODY BGCOLOR=\"bisque\">\n";
	printf fp_wp "<img src=$path border=1 hspace=10 align=left alt=\"Set List\">\n";
	printf fp_wp "<p>\n";
	printf fp_wp "<font color=maroon size=+3><b>\n";

	# write set-specific header
	$description = &setDescription($set);
	printf(fp_wp "<font color=maroon size=+3><b>$prefix_1<br> \n");
	printf(fp_wp "and<br>\n");
	printf(fp_wp "$prefix_2<br></b></font></a> \n");
	printf(fp_wp "</b></font>\n <p> \n <a href=\"../setsIndex.html\">\n");
	printf(fp_wp "<font color=blue><b>Back to diagnostic sets</b></font></a> \n");
	printf(fp_wp "<br clear=left> \n <p> \n");
	printf(fp_wp "<b><font color=maroon size=+2>Set $set Description: <b></font>$description\n");
	printf(fp_wp "<br clear=left> \n <p> \n");
	if ($set != 4 & $set != 7  & $set != 9) {
		$fname = "variableList_".$set.".html";
		$tname = "set".$set."_Variables";
        	printf(fp_wp "<A HREF=\"$fname\" target=\"$tname\">\n");
		printf(fp_wp "<font color=maroon size=+1 text-align: right><b>Lookup Table: Set $set Variable Definition</b></font></a>\n");
		printf(fp_wp "<br> \n <p> \n");
	}
	printf(fp_wp "<hr noshade size=2 size=\"100%\">\n");
        printf(fp_wp "<TABLE> \n <TR>\n ");

}

sub clickablePlotTypes
{
	printf(fp_main "</table>\n");
        @setList = (1,2,3,4,6,7,8,10,11,12);
	printf(fp_main "<hr noshade size=2 size=\"100%\">\n");
	printf(fp_main "<em>Click on Plot Type</em></b><p>\n");
	for $set (@setList)
	{
	   if ($set == 3 | $set == 4 | $set == 12) { $sn = "s"; }
	   else                       { $sn = "sn";  }
##           if( @status[$set-1] == "True") { 
           if( @status[$set-1] eq "True") { 
	        $href = "set".$set."/set".$set.".html";
	        if ($set == 8) { $path = "\"http://www.cgd.ucar.edu/tss/clm/diagnostics/images/SET".$set.".jpg\""; }
		else           { $path = "\"http://www.cgd.ucar.edu/tss/clm/diagnostics/images/SET".$set.$sn.".gif\""; }
	        printf(fp_main "<a href=\"$href\"><img src=$path align=left border=1 hspace=1 alt=\"Set $set\"></a>\n");
	   }
	}
	printf(fp_main "<br clear=left>\n");
	printf(fp_main "<p>\n");
}

sub getLongName
{
   close(fp_varMaster);
   open(fp_varMaster,"<"."$variableMaster") || die "Can't open variable master ($variableMaster) \n";
   $found = 0;
   $w2 = "";
   while(<fp_varMaster>)
   {
	# assign expression in quotes to $w2
        /[^"]+"([^"]+)"/ && ($w2 = $1);
	if($w2 eq $varname)
	{
                $ln = "info\@longName";
		# skip extra lines until we find the long name definition
                while(!/$ln(.*)/) {$_ = <fp_varMaster>;}
                if (/[^"]+"([^"]+)"/) { $longName = $1; $found = 1; return($longName); }
	}
   }
   if (FEOF & !$found) 
   {
		print ("Variable not found:  $varname\n"); 
		printf fp_wp "<TR> \n   <TH ALIGN=LEFT><font color=red>";
		printf fp_wp ("Variable Not Found:"); 
		printf fp_wp "<TH ALIGN=LEFT>$varname\n";
		</font>
   }
}

sub setDescription
{
	if ($set == 1)
	{
		$l1 = "Line plots of annual trends in energy balance,";
	        $l2 = " soil water/ice and temperature, runoff, snow water/ice, photosynthesis </b><br>";
		$l  = $l1.$l2;
	}
	if ($set == 2)
	{
		$l  = "Horizontal contour plots of DJF, MAM, JJA, SON, and ANN means </b><br>";
	}
	if ($set == 3)
	{
		$l1 = "Line plots of monthly climatology: regional air temperature, precipitation,"; 
	        $l2 = " runoff, snow depth, radiative fluxes, and turbulent fluxes </b><br>";
		$l  = $l1.$l2;
	}
	if ($set == 4)
	{
		$l  = "Vertical profiles at selected land raobs stations </b><br>";
	}
	if ($set == 5)
	{
		$l  = "Tables of annual means </b><br>";
	}
	if ($set == 6)
	{
		$l1 = "Line plots of annual trends in regional soil water/ice and temperature,"; 
	        $l2 = " runoff, snow water/ice, photosynthesis </b><br>";
		$l  = $l1.$l2;
	}
	if ($set == 7)
	{
		$l  = "Line plots, tables, and maps of RTM river flow and discharge to oceans </b><br>";
	}
	if ($set == 8)
	{
		$l  = "Line and contour plots of Ocean/Land/Atmosphere CO2 exchange</b><br>";
	}
	if ($set == 9)
	{
		$l1 = "Contour plots and statistics for precipitation and temperature.";
	        $l2 = "  Statistics include DJF, JJA, and ANN biases, and RMSE, correlation and standard deviation of the annual cycle relative to observations</b><br>";
		$l  = $l1.$l2;
	}
	if ($set == 10)
	{
		$l  = "Horizontal contour plots of DJF, MAM, JJA, SON, and ANN means, zoomed in on the Greenland ice sheet </b><br>";
	}
	if ($set == 11)
	{
		$l  = "Horizontal contour plots of DJF, MAM, JJA, SON, and ANN means, zoomed in on the Antarctic ice sheet </b><br>";
	}
	if ($set == 12)
	{
	      $l1 = "Line plots of monthly climatology: regional air temperature, precipitation,";
                    $l2 = " runoff, snow depth, radiative fluxes, and turbulent fluxes,";
                     $l3 = " ice sheet cells only (courtesy: Jan Lenaerts, jtmlenaerts@gmail.com) </b><br>";
                          $l  = $l1.$l2.$l3;
	}
	return($l)
}

sub set1Page
{
	printf(fp_wp "  <TH><TH ALIGN=LEFT><font color=maroon>Trend</font>\n"); 
	if ($set1DiffFlag) { printf(fp_wp "  <TH></TH><TH ALIGN=LEFT><font color=maroon> Difference</font>\n"); }
	if ($set1AnomFlag) { printf(fp_wp "  <TH></TH><TH ALIGN=LEFT><font color=maroon> Anomaly</font>\n");  }
	printf fp_wp "<TR>\n";
        undef @fileList;
        $ctr=0;

	# open list of output variables for set1
        $inFile = $wkdir."/master_set".$set.".txt";
        close(fp_in);
        open(fp_in,"<"."$inFile") || die "Can't open set input set1Page filelist ($inFile) \n";
        
	# read list of output variables for set1
        while(<fp_in>)
        {
                @line = split(/\s+/,$_);
		$varname = @line[1];

        	# retrieve variable definition from variable_master list
    		$longName = &getLongName($varname);
		$filename = "set1_".$varname.$sfx;
		$file     = $webdir."/set1/".$filename;
		$href     = $filename;

		if ($set1DiffFlag) {
                	$filename2 = "set1Diff_".$varname.$sfx;
                	$file2     = $webdir."/set1/".$filename2;
                	$href2     = $filename2;
		}

		if ($set1AnomFlag) {
		    $filename3 = "set1Anom_".$varname.$sfx;
		    $file3     = $webdir."/set1/".$filename3;
		    $href3     = $filename3;
		}
		
		if($varname eq "TSOI" || $varname eq "SOILLIQ" || $varname eq "SOILICE") { 
			# printf fp_wp "  <TH ALIGN=LEFT>$longName: layers 1-10 ($varname)\n"; 
			printf fp_wp "  <TH ALIGN=LEFT>$longName: layers 1,5,10 ($varname)\n"; 
		}
		else {
		        printf fp_wp "  <TH ALIGN=LEFT>$longName ($varname)\n"; 
		}
		# link plot if variable was successfully plotted by ncl
		if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green:font weight=bold>---</font>\n"; }
		if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><A HREF=\"$href\">TrendPlot</a>\n"; }

		if ($set1DiffFlag) {
			if (!-e $file2) { printf fp_wp "  <TH ALIGN=LEFT><font color=green:font weight=bold>---</font>\n"; }
			if ( -e $file2) { printf fp_wp "  <TH><TH ALIGN=LEFT><A HREF=\"$href2\">DifferencePlot</a>\n"; }
		}
		if ($set1AnomFlag) {
		    if (!-e $file3) { printf fp_wp "  <TH ALIGN=LEFT><font color=green:font weight=bold>---</font>\n"; }
		    if ( -e $file3) { printf fp_wp "  <TH><TH ALIGN=LEFT><A HREF=\"$href3\">AnomalyPlot</a>\n"; }
		}
		printf fp_wp "<TR>\n";
        }
}

sub set2Page
{
	# set-specific header
        @time  = ("DJF","MAM","JJA","SON","ANN");
	printf fp_wp "  <TH><BR>\n";
	$snF = 0;
        @vSP = ("TSA","PREC","TOTRUNOFF","SNOWDP","SNOWDP","H2OSNO","FSNO",
                "VBSA","NBSA","VWSA","NWSA","ASA","LHEAT","FPSN","TLAI");
        @vCN = ("TSA","PREC","TOTRUNOFF","SNOWDP","SNOWDP","H2OSNO","FSNO",
                "VBSA","NBSA","VWSA","NWSA","ASA","LHEAT","GPP","TLAI");
        if ($cn) { @VarArray = @vCN }
        else     { @VarArray = @vSP }
	foreach $varname (@VarArray)
	{
		if ($varname eq "VBSA") {
	    		printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>MODIS</font>\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
		if ($varname eq "TSA") {
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>Willmott-Matsuura</font>\n";
			printf fp_wp "<TH>DJF\n  <TH>MAM\n  <TH>JJA\n  <TH>SON\n  <TH>ANN\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
		if ($varname eq "TOTRUNOFF") {
	    		printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>GRDC</font>\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
		if ($varname eq "SNOWDP") {
		    if (!$snF) {
	    		printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>USAF\/ETAC - FOSTERDAVY</font>\n";
			printf fp_wp "<TR>\n";
			$v2 = "_FOSTERDAVY";
			$snF++;
		    } else {
	    		printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>CMC</font>\n";
			printf fp_wp "<TR>\n";
			$v2 = "_CMC";
		    }
		}
		if ($varname eq "H2OSNO" | $varname eq "PREC" | 
                    $varname eq "NBSA"   | $varname eq "NWSA" | $varname eq "VWSA" | $varname eq "ASA" ) {
			$v2="";
		}
		if ($varname eq "FSNO") {
	    		printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>NOAA-AVHRR</font>\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
		if ($varname eq "LHEAT") {
	    		printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>FLUXNET</font>\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
                if ($varname eq "FPSN" or $varname eq "GPP") { 
			$v2="";
                }
                if ($varname eq "TLAI") {
                        printf fp_wp "<TH><BR>\n";
                        printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>MODIS</font>\n";
                        printf fp_wp "<TR>\n";
                        $v2="";
                }
    		$longName = &getLongName($varname);
	   	printf fp_wp "  <TH ALIGN=LEFT> $varname&nbsp&nbsp&nbsp&nbsp\n";
	   	printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
               	foreach $t (@time) {
			$filename = "set2_".$t."_".$varname.$v2.$sfx; 
			$file  = $webdir."/set2/".$filename;
			$href  = $filename;
			if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
			if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
               	}
	    	printf fp_wp "<TR>\n";
	}

	printf fp_wp "<TR>\n";
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH></TH><TH ALIGN=LEFT><font color=navy size=+1>Model Only</font>\n";
	printf fp_wp "<TH>DJF\n  <TH>MAM\n  <TH>JJA\n  <TH>SON\n  <TH>ANN\n";
	printf fp_wp "<TR>\n";
        $inFile = $wkdir."/master_set".$set.".txt";
        close(fp_in);
        open(fp_in,"<"."$inFile") || die "Can't open set input set2Page filelist ($inFile) \n";

        $ctr=0;
        while(<fp_in>)
        {
            @line = split(/\s+/,$_);
            $varname = @line[1];

	    # skip model vs obs plots.
	    if ($varname eq "TSA" | $varname eq "PREC" | $varname eq "TOTRUNOFF" | $varname eq "SNOWDP" |
		$varname eq "FSNO"| $varname eq "H2OSNO" | $varname eq "LHEAT" | $varname eq "GPP" |
                $varname eq "TLAI" ) { next; } 

    	    $longName = &getLongName($varname);
	    # $suffix = substr($filename,(length($filename)-5),1);
	    if ($varname eq "TLAKE" | $varname eq "SOILLIQ" | $varname eq "SOILICE" | $varname eq "H2OSOI" | $varname eq "TSOI") {
		   # foreach $layer (0 .. 9) {
		   foreach $layer (0, 4, 9) {
			$lyr = $layer+1;
		        printf fp_wp "  <TH ALIGN=LEFT> $varname ($lyr)&nbsp&nbsp&nbsp&nbsp\n";
		        printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
                	foreach $t (@time) {
			     	$filename = "set2_".$t."_".$varname."_".$layer.$sfx; 
				$file  = $webdir."/set2/".$filename;
				$href  = $filename;
				if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
				if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
			}
			printf fp_wp "<TR>\n";
		   }
              }
	      else {
		   printf fp_wp "  <TH ALIGN=LEFT> $varname&nbsp&nbsp&nbsp&nbsp\n";
		   printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
                   foreach $t (@time) {
			$filename = "set2_".$t."_".$varname.$sfx; 
			$file  = $webdir."/set2/".$filename;
			$href  = $filename;
			if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
			if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
                    }
		    printf fp_wp "<TR>\n";
              }
        }
}


sub set3and6Page
{
	%polar = ( 'Alaskan_Arctic',   'Alaskan Arctic', 	# polar
		    'Canadian_Arctic',  'Canadian Arctic',
		    'Greenland',        'Greenland',
		    'Russian_Arctic',   'Russian Arctic',
		    'Polar',            'Polar',
		    'Antarctica',       'Antarctica', );

	%boreal = ( 'Alaska',		'Alaska',		# boreal
		    'Northwest_Canada', 'Northwest Canada', 
		    'Central_Canada',   'Central Canada',
		    'Eastern_Canada',   'Eastern Canada',
		    'Northern_Europe',  'Northern Europe',
		    'Western_Siberia',  'Western Siberia',
                    'Lost_BorealForest', 'Lost Boreal Forest',
		    'Eastern_Siberia',  'Eastern Siberia', );

	%midLat = ( 'Western_US',       'Western U.S.',		# middle latitudes
		    'Central_US',       'Central U.S.',
		    'Eastern_US',       'Eastern U.S.',
		    'Europe', 		'Europe',
		    'Mediterranean',    'Mediterranean', );

	%trpRF = ( 'Central_America',  'Central America',	# Tropical Rainforests
		    'Amazonia',         'Amazonia',
		    'Central_Africa',   'Central Africa',
		    'Indonesia',        'Indonesia', );

	%trpSav = ( 'Brazil',	        'Brazil',		# Tropical Savannas
		    'Sahel', 		'Sahel',
		    'Southern_Africa',  'Southern Africa',
		    'India', 		'India',
		    'Indochina', 	'Indochina', );

 	%arid = ( 'Sahara_Desert',	'Sahara Desert',	# arid
		    'Arabian_Peninsula','Arabian Peninsula',
		    'Australia', 	'Australia',
		    'Central_Asia', 	'Central Asia',
		    'Mongolia', 	'Mongolia',
		    'Tigris_Euphrates',	'Tigris_Euphrates');

        %highlands = ('Tibetan_Plateau',  'Tibetan Plateau', );		# highland

        %asia = ('Asia',    'Central Asia',			# Liya Jin
		 'Mongolia_China',    'Central and Eastern Mongolia and NE China',
		 'Eastern_China',     'Eastern China',
		 'Tibet',   	      'Tibetan_Plateau',
		 'Southern_Asia',     'Southern Asia',
		 'NAfrica_Arabia',    'Sahara Desert and Arabian Peninsula',
		 'Med_MidEast',       'Mediterranean and Western Asia', );

	%glHem = ( 'N_H_Land',         'Northern Hemisphere Land',     # global and hemispheric
		   'S_H_Land',         'Southern Hemisphere Land',
		   'Global',           'Global Land', );


	# == Set 3
	if ( $cn) { 
           if ( $hydro) { @set3fluxes  = ("landf","radf","turbf","cnFlx","frFlx","moistEnergyFlx","snow","albedo","hydro"); }
	   else {         @set3fluxes  = ("landf","radf","turbf","cnFlx","frFlx","moistEnergyFlx","snow","albedo"); }
	}
	else       { 
	   if ( $hydro) { @set3fluxes  = ("landf","radf","turbf","moistEnergyFlx","snow","albedo","hydro"); }
	   else         { @set3fluxes  = ("landf","radf","turbf","moistEnergyFlx","snow","albedo"); }
	}
	# == Set 6
        if ( $cn) {
	   if ( $hydro) { 
                  @set6fluxes  = ("landf","radf","turbf","cnFlx","frFlx","crbStock","tsoi","soilliq","soilice",	
			          "soilliqIce","snowliqIce","hydro"); 
	   }
           else { @set6fluxes  = ("landf","radf","turbf","cnFlx","frFlx","crbStock","tsoi","soilliq","soilice",
				  "soilliqIce","snowliqIce"); 
	   }
        }
	else 	 { 
	   if ( $hydro) { 
		@set6fluxes  = ("landf","radf","turbf","tsoi","soilliq","soilice","soilliqIce","snowliqIce","hydro"); 
	   }
	   else {
		@set6fluxes  = ("landf","radf","turbf","tsoi","soilliq","soilice","soilliqIce","snowliqIce"); 
	   }
         }
	@regions = ("HEMISPHERIC AND GLOBAL","POLAR","BOREAL","MIDDLE LATITUDES","TROPICAL RAINFOREST","TROPICAL SAVANNA",
			   "ARID","HIGHLAND","ASIA");
	@paleo_regions = ("HEMISPHERIC AND GLOBAL");

	# print set-specific header information
	printf fp_wp "<TR>\n"; 
	printf fp_wp "<TR>\n  <TH ALIGN=LEFT>All Model Data Regions\n";
	if ($set == 3) { $n2 = "set3_reg_all".$sfx; }
	if ($set == 6) { $n2 = "set6_reg_all".$sfx; }
	printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$n2\">map</A>\n";
	printf fp_wp "<TR>\n<TR>\n";
	if ($set == 3) {
           printf fp_wp "  <TH>\n  <TH>\n  <TH>GPP\n  <TH>\n  <TH>\n";
	   printf fp_wp "<TR>\n";
           printf fp_wp "  <TH>\n  <TH>\n  <TH>Latent Heat\n  <TH>\n  <TH>\n";
	   printf fp_wp "<TR>\n";
        }
	printf fp_wp "  <TH>\n  <TH>\n  <TH>Temp\n  <TH>\n  <TH>\n";
	printf fp_wp "<TR>\n";
	if ($set == 3) {
	   # CN active
           if ( $cn) {	
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Precip\n  <TH>\n  <TH>\n  <TH>Carbon <TH>\n <TH>Energy/Moist\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Runoff\n  <TH>Radiative\n  <TH>Turbulent\n  <TH>Nitrogen\n";
		printf fp_wp "  <TH>Fire <TH>Control of\n<TH>Snow\n<TH>ALbedo\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Fluxes\n";
		if ( $hydro) { printf fp_wp "  <TH>Fluxes\n <TH> Evap\n <TH> vs Obs\n <TH> vs Obs\n <TH> Hydrology\n"; }
		else         { printf fp_wp "  <TH>Fluxes\n <TH> Evap\n <TH> vs Obs\n <TH> vs Obs\n";                  }
		printf fp_wp "<TR>\n";
	   # CN Not Active
	   } else {
	
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Precip\n  <TH>\n  <TH>\n  <TH>Energy/moisture\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Runoff\n  <TH>Radiative\n  <TH>Turbulent\n  <TH>Control of\n<TH>Snow\n<TH>Albedo\n";
		printf fp_wp "<TR>\n";
		if ( $hydro) { printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Evap\n<TH>vsObs\n <TH>vsObs\n <TH> Hydrology\n"; }
		else         { printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Evap\n<TH>vsObs\n <TH>vsObs\n <TH>\n"; }
		printf fp_wp "<TR>\n";
	   }
	}
	else
	{
           if ( $cn) {	
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Precip\n  <TH>\n  <TH>\n  <TH>Carbon/\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Runoff\n  <TH>Radiative\n  <TH>Turbulent\n  <TH>Nitrogen\n  <TH>Fire\n  <TH>Carbon\n";
		printf fp_wp "  <TH>Soil\n  <TH>SoilLiq\n  <TH>\n  <TH>TotalSoilIce\n  <TH>TotalSnowH2O\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Stocks\n";
		if ( $hydro) {
		   printf fp_wp "  <TH>Temp\n  <TH>Water\n  <TH>SoilIce\n  <TH>TotalSoilH2O\n  <TH>TotalSnowIce\n  <TH>Hydrology\n";
		} else {
		   printf fp_wp "  <TH>Temp\n  <TH>Water\n  <TH>SoilIce\n  <TH>TotalSoilH2O\n  <TH>TotalSnowIce\n";
		}
		printf fp_wp "<TR>\n";
	   } else {
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Precip\n  <TH>\n  <TH>\n  <TH>\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Runoff\n  <TH>Radiative\n  <TH>Turbulent\n";
		printf fp_wp "  <TH>Soil\n  <TH>SoilLiq\n  <TH>\n  <TH>TotalSoilIce\n  <TH>TotalSnowH2O\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n";
		if ( $hydro) {
		  printf fp_wp "  <TH>Temp\n  <TH>Water\n  <TH>SoilIce\n  <TH>TotalSoilH2O\n  <TH>TotalSnowIce\n  <TH>Hydrology\n";
	        } else {
		  printf fp_wp "  <TH>Temp\n  <TH>Water\n  <TH>SoilIce\n  <TH>TotalSoilH2O\n  <TH>TotalSnowIce\n";
		}
		printf fp_wp "<TR>\n";
	   }
	}

	if ($paleo eq 'True') {
		@use_region = @paleo_regions;
	}
	else {
		@use_region = @regions;
	}
	foreach $region (@use_region)
	{
	    undef $nList;
	    if ($region eq "POLAR")                  { %nList = %polar;    }
	    if ($region eq "BOREAL")                 { %nList = %boreal;   }
	    if ($region eq "MIDDLE LATITUDES")       { %nList = %midLat;   }
	    if ($region eq "TROPICAL RAINFOREST")    { %nList = %trpRF;    }
	    if ($region eq "TROPICAL SAVANNA")       { %nList = %trpSav;   }
	    if ($region eq "ARID")                   { %nList = %arid;     }
	    if ($region eq "HIGHLAND")               { %nList = %highlands;}
	    if ($region eq "ASIA")                   { %nList = %asia;	   }
	    if ($region eq "HEMISPHERIC AND GLOBAL") { %nList = %glHem;    }

	    &writeRegion();
	}

}

sub set4Page()
{
	%arctic = ('Western_Alaska',	'Western_Alaska',
		'Whitehorse_Canada', 	'Whitehorse_Canada',
		'Resolute_Canada', 	'Resolute_NWT_Canada',
		'Thule_Greenland', 	'Thule_Greenland', );
	% nMidLat = ('New_Delhi_India', 'New Delhi India',
		'Tokyo',		'Tokyo_Japan',	
		'SanFrancisco_CA', 	'San Francisco CA USA',
		'Denver_CO', 		'Denver CO USA',
		'Great_Plains_USA', 	'Northern Great Plains USA ',
		'OklahomaCity_OK', 	'Oklahoma City OK USA ',
		'Miami_FL', 		'Miami FL USA ',
		'NewYork_USA', 		'New York USA ',
		'Gibraltor',            'Gibraltor',
		'London_UK',            'London UK',
		'Western_Europe',       'Western Europe',);

	%tropics = ('Central_India',    'Central India',
        	'Madras_India',          'Madras India',
        	'Singapore',            'Singapore',
        	'DaNang_Vietnam',       'DaNang Vietnam',
        	'Manila',               'Manila',
        	'Darwin_Australia',     'Darwin Australia',
        	'Port_Moresby',         'Port Moresby',
        	'Hawaii',               'Hawaii (Eq Pacific)',
        	'Panama',               'Panama Central America',
        	'Mexico_City',          'Mexico City Mexico',
        	'Lima_Peru',           'Lima Peru',
        	'Recife_Brazil',        'Recife Brazil',
        	'Ethiopia',             'Ethiopia',
        	'Nairobi_Kenya',        'Nairobi Kenya',);
 
	%sMidLat = ('Western_Desert_Australia',         'Western Desert Australia',
        	'Sydney_Australia',     'Sydney Australia',
        	'Christchurch_NZ',      'Christchurch New Zealand',
        	'Sao_Paulo',            'Sao Paulo Brazil',);

	%antarctic = ( 'McMurdo_Antarctica',    'McMurdo Antarctica',);

	%noObs = ('Alaskan_Arctic',     'Alaskan Arctic',
        	'Canadian_Arctic',      'Canadian Arctic',
        	'Greenland',            'Greenland',
        	'Russian_Arctic',       'Russian Arctic',
        	'Alaska',               'Alaska',
        	'Northwest_Canada',     'Northwest Canada',
        	'Central_Canada',       'Central Canada',
        	'Eastern_Canada',       'Eastern Canada',
        	'Northern_Europe',      'Northern Europe',
        	'Western_Siberia',      'Western Siberia',
        	'Eastern_Siberia',      'Eastern Siberia',
        	'Western_US',           'Western US',
        	'Central_US',           'Central US',
        	'Eastern_US',           'Eastern US',
        	'Europe',               'Europe',
        	'Mediterranean',        'Mediterranean',
        	'Central_America',      'Central America',
        	'Amazonia',             'Amazonia',
        	'Central_Africa',       'Central Africa',
        	'Indonesia',            'Indonesia',
        	'Brazil',               'Brazil',
        	'Sahel',                'Sahel',
        	'Southern_Africa',      'Southern Africa',
        	'India',                'India',
        	'Indochina',            'Indochina',
        	'Sahara_Desert',        'Sahara Desert',
        	'Arabian_Peninsula',    'Arabian Peninsula',
        	'Australia',            'Australia',
        	'Central_Asia',         'Central Asia',
        	'Mongolia',             'Mongolia',
        	'Tibetan_Plateau',      'Tibetan Plateau',);

	@fluxes  = ("T","Q");
	@regions = ("ARCTIC","NORTHERN MIDLATITUDES","TROPICS","SOUTHERN MIDLATITUDES","ANTARCTICA", "NO OBSERVATIONS");

	printf fp_wp "  <TH ALIGN=LEFT>All Station Locations\n";	
	$n1 = "set_4_stationMap".$sfx;
	printf fp_wp "  <TH><A HREF=\"$n1\">map</A>\n";
	#  printf fp_wp "  <TH><A HREF=\"set_4_stationMap.gif\">map</A>\n";
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT><font color=red>STATION NAME</font>\n";	
	printf fp_wp "  <TH>T [K]\n";
	printf fp_wp "  <TH>Q [mb] \n";
	printf fp_wp "<TR>\n";

	foreach $region (@regions)
	{
	    undef $nList;
	    if ($region eq "ARCTIC")                  	{ %nList = %arctic;    }
	    if ($region eq "NORTHERN MIDLATITUDES")     { %nList = %nMidLat;   }
	    if ($region eq "TROPICS")       		{ %nList = %tropics;   }
	    if ($region eq "SOUTHERN MIDLATITUDES")     { %nList = %sMidLat;    }
	    if ($region eq "ANTARCTICA")       		{ %nList = %antarctic;    }
	    if ($region eq "NO OBSERVATIONS")           { %nList = %noObs;     }

	    &writeRegion();
	}
}
sub set5Page()
{
	printf fp_wp "  <TH ALIGN=LEFT><font color=red>TABLE</font>\n";
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Regional Hydrologic Cycle\n";
		   $filename  = "set5_hydReg.txt";
		   $dfilename = "set5_DhydReg.txt";
		   $file      = $webdir."/set".$set."/".$filename;
		   $dfile     = $webdir."/set".$set."/".$dfilename;
		   $href      = $filename;
		   $dhref     = $dfilename;
		   if (!-e $file)  { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file)  { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">Table</a></font>\n"; }
		   if (!-e $dfile) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $dfile) { printf fp_wp "  <TH><TH ALIGN=LEFT><font color=black><A HREF=\"$dhref\">Difference Table</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Global Biogeophysics\n";
		   $filename  = "set5_clm.txt";
		   $dfilename = "set5_Dclm.txt";
		   $file      = $webdir."/set".$set."/".$filename;
		   $dfile     = $webdir."/set".$set."/".$dfilename;
		   $href      = $filename;
		   $dhref     = $dfilename;
		   if (!-e $file)  { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file)  { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">Table</a></font>\n"; }
		   if (!-e $dfile) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $dfile) { printf fp_wp "  <TH><TH ALIGN=LEFT><font color=black><A HREF=\"$dhref\">Difference Table</a></font>\n"; }
	printf fp_wp "<TR>\n";
	if ($cn) {
	   printf fp_wp "  <TH ALIGN=LEFT>Global Carbon/Nitrogen\n";
		   $filename  = "set5_cn.txt";
		   $dfilename = "set5_Dcn.txt";
		   $file      = $webdir."/set".$set."/".$filename;
		   $dfile     = $webdir."/set".$set."/".$dfilename;
		   $href      = $filename;
		   $dhref     = $dfilename;
		   if (!-e $file)  { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file)  { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">Table</a></font>\n"; }
		   if (!-e $dfile) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $dfile) { printf fp_wp "  <TH><TH ALIGN=LEFT><font color=black><A HREF=\"$dhref\">Difference Table</a></font>\n"; }
	   printf fp_wp "<TR>\n";
	}
	printf fp_wp "<TR>\n";
	if ($casa) {
	   printf fp_wp "  <TH ALIGN=LEFT>Gobal Carbon/Nitrogen [CASA model]\n";
		   $filename  = "set5_casa.txt";
		   $dfilename = "set5_Dcasa.txt";
		   $file      = $webdir."/set".$set."/".$filename;
		   $dfile     = $webdir."/set".$set."/".$dfilename;
		   $href      = $filename;
		   $dhref     = $dfilename;
		   if (!-e $file)  { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file)  { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">Table</a></font>\n"; }
		   if (!-e $dfile) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $dfile) { printf fp_wp "  <TH><TH ALIGN=LEFT><font color=black><A HREF=\"$dhref\">Difference Table</a></font>\n"; }
	   printf fp_wp "<TR>\n";
	}
}

sub set7Page()
{

	printf fp_wp "  <TH ALIGN=LEFT><font color=red>TABLE</font>\n";
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>RTM flow at station for world's 50 largest rivers\n";
		   $filename = "set7_table_RIVER_STN_VOL.txt";
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">table</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT><font color=red>SCATTER PLOTS</font>\n";
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>RTM flow at station versus obs for world's 50 largest rivers (QCHANR)\n";
		   $filename = "set7_scatter_50riv".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">plot</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT><font color=red>LINE PLOTS</font>\n";
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Mean annual cycle of river flow at station for world's 10 largest rivers (QCHANR)\n";
		   $filename = "set7_mon_stndisch_10riv".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">plot</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Annual discharge into the Global Ocean (QCHOCNR)\n";
		   $filename = "set7_ann_disch_globalocean".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">plot</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Annual discharge into the Atlantic Ocean (QCHOCNR)\n";
		   $filename = "set7_ann_disch_atlantic".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">plot</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Annual discharge into the Indian Ocean (QCHOCNR)\n";
		   $filename = "set7_ann_disch_indian".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">plot</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Annual discharge into the Pacific Ocean (QCHOCNR)\n";
		   $filename = "set7_ann_disch_pacific".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">plot</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Mean annual cycle of discharge into the oceans (QCHOCNR)\n";
		   $filename = "set7_mon_disch".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">plot</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT><font color=red>MAPS</font>\n";
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Station locations (50 largest rivers)\n";
		   $filename = "set7_stations".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">Map</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>Ocean Basins\n";
		   $filename = "set7_ocean_basin_index".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">Map</a></font>\n"; }
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH ALIGN=LEFT>River Flow (QCHANR)\n";
		   $filename = "set7_ANN_QCHANR_Ac".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">Model1</a></font>\n"; }
	    if (!$obsFlag) {
		   printf fp_wp " vs \n";
		   $filename = "set7_ANN_QCHANR_Bc".$sfx;
		   $file     = $webdir."/set".$set."/".$filename;
		   $href     = $filename;
		   if (!-e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=LEFT><font color=black><A HREF=\"$href\">Model2</a></font>\n"; }
	    } 
	printf fp_wp "<TR>\n";
}
sub writeRegion()
{
	printf fp_wp "<TH COLSPAN=\"5\"><font color=red>$region</font>\n<TR>\n"; 
	foreach $nameHyp (sort keys(%nList) )
	{
		$name = $nList{$nameHyp};
		printf fp_wp "  <TH ALIGN=LEFT>$name\n";             
	        if($set == 3 || $set == 6)
		{
		   $filename = "set".$set."_reg_".$nameHyp.$sfx;
		   $file  = $webdir."/set".$set."/".$filename;
		   $href  = $filename;

		   if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>--</font>\n"; }
		   if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=black><A HREF=\"$href\">map</a></font>\n"; }
		}
		if ($set == 4) { @usefluxes = @fluxes; }
		if ($set == 3) { @usefluxes = @set3fluxes; }
		if ($set == 6) { @usefluxes = @set6fluxes; }
		foreach $flx (@usefluxes)
		{
##			if ($flx == "reg") { $ref = "map"; } else { $ref = "plot"; }
			if ($flx eq "reg") { $ref = "map"; } else { $ref = "plot"; }
			if ($set == 4) { $filename = "set".$set."_".$nameHyp."_".$flx.$sfx; }
			else           { $filename = "set".$set."_".$flx."_".$nameHyp.$sfx; }
			$file  = $webdir."/set".$set."/".$filename;
			$href     = $filename;
			if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>--</font></a>\n"; }
			if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n";      }
		}
		printf(fp_wp "<TR>\n");
	}
}
sub set8Page()
{
        # set-specific header
        @time  = ("DJF","MAM","JJA","SON","ANN");
        @subsetList  = ("zonal","trends","contour","contourDJF-JJA","ann_cycle");

        foreach $subset (@subsetList)
        {
           if ($subset eq "zonal")
                {printf fp_wp "<br><font color=maroon size=+2> Line Plots of Seasonal Zonal Means<BR>\n  </font><BR>\n"; $nfiles=2; }
           if ($subset eq "trends")
                {printf fp_wp "<br><font color=maroon size=+2> Line Plots of Annual Trends<BR>\n     </font><BR>\n"; $nfiles=1; }
           if ($subset eq "contour")
                {printf fp_wp "<br><font color=maroon size=+2> Contour Plots of Seasonal Means<BR>\n </font><BR>\n"; $nfiles=1; }
           if ($subset eq "ann_cycle")
                {printf fp_wp "<br><font color=maroon size=+2> Annual Cycle of Zonal Fluxes<BR>\n    </font><BR>\n"; $nfiles=2; }
           if ($subset eq "contourDJF-JJA")
                {printf fp_wp "<br><font color=maroon size=+2> Contour Plots of Seasonal Difference (DJF-JJA)<BR>\n </font><BR>\n"; $nfiles=1; }
	   printf(fp_wp "<TABLE> \n <TR>\n ");
           if ($subset eq "zonal" | $subset eq "contour") {
                  printf fp_wp "  <TH><TH><TH>DJF\n  <TH>MAM\n  <TH>JJA\n  <TH>SON\n  <TH>ANN\n";
                  printf fp_wp "<TR>\n";
           }
	   # printf(fp_wp "  </font> \n");
	   $f = 0;
	   while ($f < $nfiles) {
		if ($f == 1) { $inFile = $wkdir."/master_set".$set."_".$subset."_lnd.txt"; } 
		else         { $inFile = $wkdir."/master_set".$set."_".$subset.".txt"; }
	
           	close(fp_in);
           	open(fp_in,"<"."$inFile") || die "Can't open set input set8Page ($subset) filelist ($inFile) \n";
           	while(<fp_in>)
           	{
               		@line = split(/\s+/,$_);
               		$varname = @line[1];

               		$longName = &getLongName($varname);
               		printf fp_wp "  <TH ALIGN=LEFT> $varname&nbsp&nbsp&nbsp&nbsp\n";
               		printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
               		if ($subset eq "zonal" | $subset eq "contour" | $subset eq "zonal_lnd") {
                  		foreach $t (@time) {
					if ($f == 1) { $filename = "set8_".$subset."_lnd_".$t."_".$varname.$sfx; }
                           		else 	     { $filename = "set8_".$subset."_".$t."_".$varname.$sfx;     }
                           		$file  = $webdir."/set8/".$filename;
                           		$href  = $filename;
                           		if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
                           		if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
                  		}
               		} else {
                  		if ($f == 1) { $filename = "set8_".$subset."_lnd_".$varname.$sfx; }
                  		else         { $filename = "set8_".$subset."_".$varname.$sfx;     }
                  		$file  = $webdir."/set8/".$filename;
                  		$href  = $filename;
                  		if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
                  		if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
               		}

               		printf fp_wp "<TR>\n";
            	}
		$f++;
            }
            printf fp_wp "<TR><TR><TR>\n";
            printf(fp_wp "<br clear=left>\n");
            printf(fp_wp "</table>\n");
        }
}
sub set9Page
{
        # set-specific header
        @time  = ("DJF","MAM","JJA","SON","ANN");
        @vSP = ("TSA","PREC","ASA","LHEAT","FPSN","TLAI");
        @vCN = ("TSA","PREC","ASA","LHEAT","GPP","TLAI");
        if ($cn) { @vars = @vCN }
        else     { @vars = @vSP }
	$ctr=1;
        foreach $plot ("rmse","bias","corr","stdev","tables") {
	    if ($plot eq "bias") {
                printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1> $ctr. Seasonal $plot </font><TR>\n";  $ctr++;
            	foreach $v (@vars) {
                   printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>&nbsp&nbsp&nbsp&nbsp $v </font>\n";  
            	   foreach $t (@time) {
                        $filename = "set9_bias_".$v."_".$t.$sfx;
                        $file  = $webdir."/set9/".$filename;
                        $href  = $filename;
                        if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
                        if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">$t</a>\n"; }
		   }
               	   printf fp_wp "<TR>\n";
		 }
	 
	    } elsif ($plot eq "tables") {
                	printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1> $ctr. Tables</font>\n";            $ctr++;
                	$filename = "set9_statTable.html";
                	$file  = $webdir."/set9/".$filename;
                	$href  = $filename;
                	if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
                	if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">All Variables</a>\n"; }
            } else {
	        	if ($plot eq "rmse")  { $useName = "RMSE"; }
	        	if ($plot eq "corr")  { $useName = "Correlation"; }
	        	if ($plot eq "stdev") { $useName = "Standard Deviation"; }
                        printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1> $ctr. $useName </font>\n";    $ctr++;
            	        foreach $v (@vars) {
                        	$filename = "set9_".$plot."_".$v.$sfx;
                        	$file  = $webdir."/set9/".$filename;
                        	$href  = $filename;
                        	if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
                        	if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">$v</a>\n"; }
	    		}
	    }
            printf fp_wp "<TR>\n";
        }
        printf fp_wp "<TR>\n";
}
 
 
 
sub set10Page
{
	# set-specific header
        @time  = ("DJF","MAM","JJA","SON","ANN");
	printf fp_wp "  <TH><BR>\n";
	$snF = 0;
        @vSP = ("TSA","Q2M","RH2M","U10","SNOW","RAIN","PBOT",
                "FSH","QSOIL","FGR","FLDS","FIRE","FSDS","FSR","ASA",
                "QICE_FRZ","QICE_MELT","QSNOMELT","QICE");
        @vCN = ("TSA","Q2M","RH2M","U10","SNOW","RAIN","PBOT",
                "FSH","QSOIL","FGR","FLDS","FIRE","FSDS","FSR","ASA",
                "QICE_FRZ","QICE_MELT","QSNOMELT","QICE");
        if ($cn) { @VarArray = @vCN }
        else     { @VarArray = @vSP }
	foreach $varname (@VarArray)
	{
		if ($varname eq "TSA") {
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>RACMO2.3: near-sfc atm & precip</font>\n";
			printf fp_wp "<TH>DJF\n  <TH>MAM\n  <TH>JJA\n  <TH>SON\n  <TH>ANN\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
		if ($varname eq "FSH" ) { 
	    	printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>RACMO2.3: Fluxes</font>\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
      if ($varname eq "QICE_FRZ" ) { 
	    	printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>RACMO2.3: SMB and components</font>\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
    		$longName = &getLongName($varname);
	   	printf fp_wp "  <TH ALIGN=LEFT> $varname&nbsp&nbsp&nbsp&nbsp\n";
	   	printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
               	foreach $t (@time) {
			$filename = "set10_".$t."_".$varname.$v2.$sfx; 
			$file  = $webdir."/set10/".$filename;
			$href  = $filename;
			if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
			if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
               	}
	    	printf fp_wp "<TR>\n";
	}

	printf fp_wp "<TR>\n";
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH></TH><TH ALIGN=LEFT><font color=navy size=+1>Model Only</font>\n";
	printf fp_wp "<TH>DJF\n  <TH>MAM\n  <TH>JJA\n  <TH>SON\n  <TH>ANN\n";
	printf fp_wp "<TR>\n";
        $inFile = $wkdir."/master_set".$set.".txt";
        close(fp_in);
        open(fp_in,"<"."$inFile") || die "Can't open set input set10Page filelist ($inFile) \n";

        $ctr=0;
        while(<fp_in>)
        {
            @line = split(/\s+/,$_);
            $varname = @line[1];

	    # skip model vs obs plots.
	   # if ($varname eq "TSA" | $varname eq "Q2M" | $varname eq "RH2M" | $varname eq "U10" |
		#$varname eq "FSNO"| $varname eq "H2OSNO" | $varname eq "LHEAT" | $varname eq "GPP" |
      #          $varname eq "TLAI" ) { next; } 

    	    $longName = &getLongName($varname);
	    # $suffix = substr($filename,(length($filename)-5),1);
	    if ($varname eq "TLAKE" | $varname eq "SOILLIQ" | $varname eq "SOILICE" | $varname eq "H2OSOI" | $varname eq "TSOI") {
		   # foreach $layer (0 .. 9) {
		   foreach $layer (0, 4, 9) {
			$lyr = $layer+1;
		        printf fp_wp "  <TH ALIGN=LEFT> $varname ($lyr)&nbsp&nbsp&nbsp&nbsp\n";
		        printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
                	foreach $t (@time) {
			     	$filename = "set10_".$t."_".$varname."_".$layer.$sfx; 
				$file  = $webdir."/set10/".$filename;
				$href  = $filename;
				if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
				if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
			}
			printf fp_wp "<TR>\n";
		   }
              }
	      else {
		   printf fp_wp "  <TH ALIGN=LEFT> $varname&nbsp&nbsp&nbsp&nbsp\n";
		   printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
                   foreach $t (@time) {
			$filename = "set10_".$t."_".$varname.$sfx; 
			$file  = $webdir."/set10/".$filename;
			$href  = $filename;
			if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
			if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
                    }
		    printf fp_wp "<TR>\n";
              }
          }
}

 
sub set11Page
{
	# set-specific header
        @time  = ("DJF","MAM","JJA","SON","ANN");
	printf fp_wp "  <TH><BR>\n";
	$snF = 0;
        @vSP = ("TSA","Q2M","RH2M","U10","SNOW","RAIN","PBOT",
                "FSH","QSOIL","FGR","FLDS","FIRE","FSDS","FSR","ASA",
                "QICE_FRZ","QICE_MELT","QSNOMELT","QICE");
        @vCN = ("TSA","Q2M","RH2M","U10","SNOW","RAIN","PBOT",
                "FSH","QSOIL","FGR","FLDS","FIRE","FSDS","FSR","ASA",
                "QICE_FRZ","QICE_MELT","QSNOMELT","QICE");
        if ($cn) { @VarArray = @vCN }
        else     { @VarArray = @vSP }
	foreach $varname (@VarArray)
	{
		if ($varname eq "TSA") {
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>RACMO2.3: near-sfc atm & precip</font>\n";
			printf fp_wp "<TH>DJF\n  <TH>MAM\n  <TH>JJA\n  <TH>SON\n  <TH>ANN\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
		if ($varname eq "FSH" ) { 
	    	printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>RACMO2.3: Fluxes</font>\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
      if ($varname eq "QICE_FRZ" ) { 
	    	printf fp_wp "<TH><BR>\n";
			printf fp_wp "<TH ALIGN=LEFT><font color=navy size=+1>RACMO2.3: SMB and components</font>\n";
			printf fp_wp "<TR>\n";
			$v2="";
		}
    		$longName = &getLongName($varname);
	   	printf fp_wp "  <TH ALIGN=LEFT> $varname&nbsp&nbsp&nbsp&nbsp\n";
	   	printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
               	foreach $t (@time) {
			$filename = "set11_".$t."_".$varname.$v2.$sfx; 
			$file  = $webdir."/set11/".$filename;
			$href  = $filename;
			if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
			if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
               	}
	    	printf fp_wp "<TR>\n";
	}

	printf fp_wp "<TR>\n";
	printf fp_wp "<TR>\n";
	printf fp_wp "  <TH></TH><TH ALIGN=LEFT><font color=navy size=+1>Model Only</font>\n";
	printf fp_wp "<TH>DJF\n  <TH>MAM\n  <TH>JJA\n  <TH>SON\n  <TH>ANN\n";
	printf fp_wp "<TR>\n";
        $inFile = $wkdir."/master_set".$set.".txt";
        close(fp_in);
        open(fp_in,"<"."$inFile") || die "Can't open set input set11Page filelist ($inFile) \n";

        $ctr=0;
        while(<fp_in>)
        {
            @line = split(/\s+/,$_);
            $varname = @line[1];

	    # skip model vs obs plots.
	   # if ($varname eq "TSA" | $varname eq "Q2M" | $varname eq "RH2M" | $varname eq "U10" |
		#$varname eq "FSNO"| $varname eq "H2OSNO" | $varname eq "LHEAT" | $varname eq "GPP" |
      #          $varname eq "TLAI" ) { next; } 

    	    $longName = &getLongName($varname);
	    # $suffix = substr($filename,(length($filename)-5),1);
	    if ($varname eq "TLAKE" | $varname eq "SOILLIQ" | $varname eq "SOILICE" | $varname eq "H2OSOI" | $varname eq "TSOI") {
		   # foreach $layer (0 .. 9) {
		   foreach $layer (0, 4, 9) {
			$lyr = $layer+1;
		        printf fp_wp "  <TH ALIGN=LEFT> $varname ($lyr)&nbsp&nbsp&nbsp&nbsp\n";
		        printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
                	foreach $t (@time) {
			     	$filename = "set11_".$t."_".$varname."_".$layer.$sfx; 
				$file  = $webdir."/set11/".$filename;
				$href  = $filename;
				if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
				if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
			}
			printf fp_wp "<TR>\n";
		   }
              }
	      else {
		   printf fp_wp "  <TH ALIGN=LEFT> $varname&nbsp&nbsp&nbsp&nbsp\n";
		   printf fp_wp "  <TH ALIGN=LEFT> $longName&nbsp&nbsp&nbsp&nbsp\n";
                   foreach $t (@time) {
			$filename = "set11_".$t."_".$varname.$sfx; 
			$file  = $webdir."/set11/".$filename;
			$href  = $filename;
			if (!-e $file) { printf fp_wp "  <TH ALIGN=CENTER><font color=green>---</font></a>\n"; }
			if ( -e $file) { printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$href\">plot</a>\n"; }
                    }
		    printf fp_wp "<TR>\n";
              }
          }
}

 
sub set12Page
{
	%polar = ( 'Alaskan_Arctic',   'Alaskan Arctic', 	# polar
		    'Canadian_Arctic',  'Canadian Arctic',
		    'Greenland',        'Greenland',
		    'Russian_Arctic',   'Russian Arctic',
		    'Polar',            'Polar',
		    'Antarctica',       'Antarctica', );

	%boreal = ( 'Alaska',		'Alaska',		# boreal
		    'Northwest_Canada', 'Northwest Canada', 
		    'Central_Canada',   'Central Canada',
		    'Eastern_Canada',   'Eastern Canada',
		    'Northern_Europe',  'Northern Europe',
		    'Western_Siberia',  'Western Siberia',
                    'Lost_BorealForest', 'Lost Boreal Forest',
		    'Eastern_Siberia',  'Eastern Siberia', );

	%midLat = ( 'Western_US',       'Western U.S.',		# middle latitudes
		    'Central_US',       'Central U.S.',
		    'Eastern_US',       'Eastern U.S.',
		    'Europe', 		'Europe',
		    'Mediterranean',    'Mediterranean', );

	%trpRF = ( 'Central_America',  'Central America',	# Tropical Rainforests
		    'Amazonia',         'Amazonia',
		    'Central_Africa',   'Central Africa',
		    'Indonesia',        'Indonesia', );

	%trpSav = ( 'Brazil',	        'Brazil',		# Tropical Savannas
		    'Sahel', 		'Sahel',
		    'Southern_Africa',  'Southern Africa',
		    'India', 		'India',
		    'Indochina', 	'Indochina', );

 	%arid = ( 'Sahara_Desert',	'Sahara Desert',	# arid
		    'Arabian_Peninsula','Arabian Peninsula',
		    'Australia', 	'Australia',
		    'Central_Asia', 	'Central Asia',
		    'Mongolia', 	'Mongolia',
		    'Tigris_Euphrates',	'Tigris_Euphrates');

        %highlands = ('Tibetan_Plateau',  'Tibetan Plateau', );		# highland

        %asia = ('Asia',    'Central Asia',			# Liya Jin
		 'Mongolia_China',    'Central and Eastern Mongolia and NE China',
		 'Eastern_China',     'Eastern China',
		 'Tibet',   	      'Tibetan_Plateau',
		 'Southern_Asia',     'Southern Asia',
		 'NAfrica_Arabia',    'Sahara Desert and Arabian Peninsula',
		 'Med_MidEast',       'Mediterranean and Western Asia', );

	%glHem = ( 'N_H_Land',         'Northern Hemisphere Land',     # global and hemispheric
		   'S_H_Land',         'Southern Hemisphere Land',
		   'Global',           'Global Land', );


	# == Set 3
	if ( $cn) { 
           if ( $hydro) { @set3fluxes  = ("landf","radf","turbf","cnFlx","frFlx","moistEnergyFlx","snow","albedo","hydro"); }
	   else {         @set3fluxes  = ("landf","radf","turbf","cnFlx","frFlx","moistEnergyFlx","snow","albedo"); }
	}
	else       { 
	   if ( $hydro) { @set3fluxes  = ("landf","radf","turbf","moistEnergyFlx","snow","albedo","hydro"); }
	   else         { @set3fluxes  = ("landf","radf","turbf","moistEnergyFlx","snow","albedo"); }
	}
	# == Set 6
        if ( $cn) {
	   if ( $hydro) { 
                  @set6fluxes  = ("landf","radf","turbf","cnFlx","frFlx","crbStock","tsoi","soilliq","soilice",	
			          "soilliqIce","snowliqIce","hydro"); 
	   }
           else { @set6fluxes  = ("landf","radf","turbf","cnFlx","frFlx","crbStock","tsoi","soilliq","soilice",
				  "soilliqIce","snowliqIce"); 
	   }
        }
	else 	 { 
	   if ( $hydro) { 
		@set6fluxes  = ("landf","radf","turbf","tsoi","soilliq","soilice","soilliqIce","snowliqIce","hydro"); 
	   }
	   else {
		@set6fluxes  = ("landf","radf","turbf","tsoi","soilliq","soilice","soilliqIce","snowliqIce"); 
	   }
         }
	@regions = ("HEMISPHERIC AND GLOBAL","POLAR","BOREAL","MIDDLE LATITUDES","TROPICAL RAINFOREST","TROPICAL SAVANNA",
			   "ARID","HIGHLAND","ASIA");
	@paleo_regions = ("HEMISPHERIC AND GLOBAL");

	# print set-specific header information
	printf fp_wp "<TR>\n"; 
	printf fp_wp "<TR>\n  <TH ALIGN=LEFT>All Model Data Regions\n";
	if ($set == 3) { $n2 = "set3_reg_all".$sfx; }
	if ($set == 6) { $n2 = "set6_reg_all".$sfx; }
	printf fp_wp "  <TH ALIGN=CENTER><A HREF=\"$n2\">map</A>\n";
	printf fp_wp "<TR>\n<TR>\n";
	if ($set == 3) {
           printf fp_wp "  <TH>\n  <TH>\n  <TH>GPP\n  <TH>\n  <TH>\n";
	   printf fp_wp "<TR>\n";
           printf fp_wp "  <TH>\n  <TH>\n  <TH>Latent Heat\n  <TH>\n  <TH>\n";
	   printf fp_wp "<TR>\n";
        }
	printf fp_wp "  <TH>\n  <TH>\n  <TH>Temp\n  <TH>\n  <TH>\n";
	printf fp_wp "<TR>\n";
	if ($set == 3) {
	   # CN active
           if ( $cn) {	
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Precip\n  <TH>\n  <TH>\n  <TH>Carbon <TH>\n <TH>Energy/Moist\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Runoff\n  <TH>Radiative\n  <TH>Turbulent\n  <TH>Nitrogen\n";
		printf fp_wp "  <TH>Fire <TH>Control of\n<TH>Snow\n<TH>ALbedo\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Fluxes\n";
		if ( $hydro) { printf fp_wp "  <TH>Fluxes\n <TH> Evap\n <TH> vs Obs\n <TH> vs Obs\n <TH> Hydrology\n"; }
		else         { printf fp_wp "  <TH>Fluxes\n <TH> Evap\n <TH> vs Obs\n <TH> vs Obs\n";                  }
		printf fp_wp "<TR>\n";
	   # CN Not Active
	   } else {
	
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Precip\n  <TH>\n  <TH>\n  <TH>Energy/moisture\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Runoff\n  <TH>Radiative\n  <TH>Turbulent\n  <TH>Control of\n<TH>Snow\n<TH>Albedo\n";
		printf fp_wp "<TR>\n";
		if ( $hydro) { printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Evap\n<TH>vsObs\n <TH>vsObs\n <TH> Hydrology\n"; }
		else         { printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Evap\n<TH>vsObs\n <TH>vsObs\n <TH>\n"; }
		printf fp_wp "<TR>\n";
	   }
	}
	else
	{
           if ( $cn) {	
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Precip\n  <TH>\n  <TH>\n  <TH>Carbon/\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Runoff\n  <TH>Radiative\n  <TH>Turbulent\n  <TH>Nitrogen\n  <TH>Fire\n  <TH>Carbon\n";
		printf fp_wp "  <TH>Soil\n  <TH>SoilLiq\n  <TH>\n  <TH>TotalSoilIce\n  <TH>TotalSnowH2O\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Fluxes\n  <TH>Stocks\n";
		if ( $hydro) {
		   printf fp_wp "  <TH>Temp\n  <TH>Water\n  <TH>SoilIce\n  <TH>TotalSoilH2O\n  <TH>TotalSnowIce\n  <TH>Hydrology\n";
		} else {
		   printf fp_wp "  <TH>Temp\n  <TH>Water\n  <TH>SoilIce\n  <TH>TotalSoilH2O\n  <TH>TotalSnowIce\n";
		}
		printf fp_wp "<TR>\n";
	   } else {
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Precip\n  <TH>\n  <TH>\n  <TH>\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>\n  <TH>Runoff\n  <TH>Radiative\n  <TH>Turbulent\n";
		printf fp_wp "  <TH>Soil\n  <TH>SoilLiq\n  <TH>\n  <TH>TotalSoilIce\n  <TH>TotalSnowH2O\n";
		printf fp_wp "<TR>\n";
		printf fp_wp "  <TH>\n  <TH>Map\n  <TH>SnowDepth\n  <TH>Fluxes\n  <TH>Fluxes\n";
		if ( $hydro) {
		  printf fp_wp "  <TH>Temp\n  <TH>Water\n  <TH>SoilIce\n  <TH>TotalSoilH2O\n  <TH>TotalSnowIce\n  <TH>Hydrology\n";
	        } else {
		  printf fp_wp "  <TH>Temp\n  <TH>Water\n  <TH>SoilIce\n  <TH>TotalSoilH2O\n  <TH>TotalSnowIce\n";
		}
		printf fp_wp "<TR>\n";
	   }
	}

	if ($paleo eq 'True') {
		@use_region = @paleo_regions;
	}
	else {
		@use_region = @regions;
	}
	foreach $region (@use_region)
	{
	    undef $nList;
	    if ($region eq "POLAR")                  { %nList = %polar;    }
	    if ($region eq "BOREAL")                 { %nList = %boreal;   }
	    if ($region eq "MIDDLE LATITUDES")       { %nList = %midLat;   }
	    if ($region eq "TROPICAL RAINFOREST")    { %nList = %trpRF;    }
	    if ($region eq "TROPICAL SAVANNA")       { %nList = %trpSav;   }
	    if ($region eq "ARID")                   { %nList = %arid;     }
	    if ($region eq "HIGHLAND")               { %nList = %highlands;}
	    if ($region eq "ASIA")                   { %nList = %asia;	   }
	    if ($region eq "HEMISPHERIC AND GLOBAL") { %nList = %glHem;    }

	    &writeRegion();
	}

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 

 
 
 
 
 

 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
}

