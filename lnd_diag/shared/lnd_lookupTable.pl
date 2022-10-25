#!/usr/bin/perl

# written by Nan Rosenbloom
# January 2005
# Usage:  called by /code/lnd_driver.csh to dynamically generate
# html files for revised LMWG Diagnostics Package.

# program checks for successful completion of plots; variables not
# successfully plotted are not linked to the html.

# --------------------------------
# get environment variables

  $wkdir     =    $ENV{'WKDIR'};
  $webdir    =    $ENV{'WEB_DIR'};
  $runtype   =    $ENV{'RUNTYPE'};
  $cn        =    $ENV{'CN'};
  $prefix_1  = $ENV{'prefix_1'};
  $prefix_2  = $ENV{'prefix_2'};
  $diag_home = $ENV{'DIAG_HOME'};

  $set_1 = $ENV{'set_1'};
  $set_2 = $ENV{'set_2'};
  $set_3 = $ENV{'set_3'};
  $set_4 = $ENV{'set_4'};
  $set_5 = $ENV{'set_5'};
  $set_6 = $ENV{'set_6'};
  $set_7 = $ENV{'set_7'};
  $set_8 = $ENV{'set_8'};
  $set_9 = $ENV{'set_9'};
  $set_10 = $ENV{'set_10'};
  $set_11 = $ENV{'set_11'};

# --------------------------------
# define auxillary files 
# --------------------------------

  # master variable list contains all variable definitions
  $variableMaster = $wkdir."/variable_master.ncl";

# --------------------------------
#  start main loop 
# --------------------------------
  @setList = (1,2,3,4,5,6,7,8,9,10,11);
  @status = ($set_1, $set_2, $set_3, $set_4, $set_5, $set_6, $set_7, $set_8, $set_9, $set_10, $set_11);

for $set (@setList)
{

print "set = $set status = @status[$set-1]\n";
    if( lc(@status[$set-1]) eq "true") { 

  	$mainFile = $webdir."/set".$set."/variableList_".$set.".html";
  	close(fp_main);
  	open(fp_main,">"."$mainFile") || die "Can't open main output file ($mainFile) \n";
  	&mainHeader1($set);

        # list set on main html page and link to set web page
        # &set_Active($set);
        
        # write list of active variables

	if ($set == 8 )                    { &writeSetEightPage($set); }
	else { if ($set != 4 & $set != 7)  { &writeSetPage($set);      } }

	printf(fp_main "<br clear=left>\n");
	printf(fp_main "</TABLE>\n");
	printf fp_main "<hr noshade size=2 size=\"100%\">\n";
	printf(fp_main "</BODY>\n");
	printf(fp_main "</HTML>\n");

	close(fp_main);
    }
}


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
	# printf fp_main "<TABLE>\n";
	# printf fp_main "  <TH><A HREF=\"setsIndex.html\">\n";
	# printf fp_main "<font color=blue>Back to diagnostic sets </font></A>\n";
	# printf fp_main "</TABLE>\n";
	$description = &setDescription($set);
	printf fp_main "<font color=maroon size=+2><b>Set $set Description:</font>\n $description </b></font>\n";
	printf fp_main "<font color=black size=+1><b>\'D_\' denotes a variable derived from two or more history file variables (lnd_func.ncl)\n";
	printf fp_main "<font color=black size=+1><b><br>\'C_\' denotes a CASA model variable.\n";

	printf fp_main "<hr noshade size=2 size=\"100%\">\n";
	if ($set != 8 ) {
	  printf(fp_main "<TABLE>\n");
	  printf(fp_main "<table style=\"width: 100%; text-align: left;\" border=\"1\" cellpadding=\"2\" cellspacing=\"2\">\n");
	  printf(fp_main "<border=\"1\">\n");
	  printf(fp_main "<TR>\n");
	  printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>Variable Name</font>\n";
	  printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>Long Name</font>\n";
	  printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>NativeUnits</font>\n";
	  printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>ReportedUnits</font>\n";
	  printf fp_main "<TR>\n";
	}
}

sub set_Active
{
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
	   if ($set == 7) { $e = 4; }
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

sub variableDefinition
{
   close(fp_varMaster);
   open(fp_varMaster,"<"."$variableMaster") || die "Can't open variable master ($variableMaster) \n";
   $found = 0;
   $w2 = "";
   while(<fp_varMaster>)
   {
	# assign expression in quotes to $w2
	$fcn = '[^"]+"([^"]+)"';
	/${fcn}/ && ($w2 = $1);
	# /[^"]+"([^"]+)"/ && ($w2 = $1);
	if($w2 eq $varname)
	{
		# get longName:
		$ln = "info\@longName";
		while(!/$ln(.*)/) {$_ = <fp_varMaster>;}
		if (/${fcn}/) { $array[0] = $1; }
		# get native units:
		$nu = "info\@nativeUnits";
		while(!/$nu(.*)/) {$_ = <fp_varMaster>;}
		#if (/[^"]+"([^"]+)"/) { $array[1] = $1; }
		if (/${fcn}/) { $array[1] = $1; }
		# get reported units
		if ($type eq "globalTotlNat") { $compareWord = "info\@globalTotal__units";        }
		if ($type eq "globalTotlAnn") { $compareWord = "info\@globalTotal_Annual__units"; }
		if ($type eq "globalMeanNat") { $compareWord = "info\@globalMean__units";         }
		if ($type eq "globalMeanAnn") { $compareWord = "info\@globalMean_Annual__units";  }
		if ($type eq "globalMeanDay") { $compareWord = "info\@globalMean_Daily__units";   }
		while(!/$compareWord(.*)/) {$_ = <fp_varMaster>;}
		if (/${fcn}/) { $array[2] = $1; return(@array); }
   	} elsif(eof(fp_varMaster)) { 
		$array[0] = $array[1] = $array[2] = "VARIABLE NOT FOUND"; 
		print ("Variable [$varname] not found.\n"); 
		return(@array); 
	}
   }
   close(fp_varMaster);
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
		$l1  = "Line plots of monthly climatology: regional air temperature, precipitation,"; 
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
		$l1  = "Line plots of annual trends in regional soil water/ice and temperature,"; 
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
        if ($set == 10)
        {
                $l  = "Horizontal contour plots of DJF, MAM, JJA, SON, and ANN means, zoomed in on the Greenland ice sheet</b><br>";
        }
        if ($set == 11)
        {
                $l  = "Horizontal contour plots of DJF, MAM, JJA, SON, and ANN means, zoomed in on the Antarctic ice sheet</b><br>";
        }
	return($l)
}

sub writeSetPage
{
        undef @fileList;
        $ctr=0;

	# open list of output variables for set
        $inFile = $wkdir."/master_set".$set.".txt";
        close(fp_in);
        open(fp_in,"<"."$inFile") || die "Can't open set input filelist ($inFile) \n";
        
	# read list of output variables for set
        while(<fp_in>)
        {
                @line = split(/\s+/,$_);
		$type    = @line[0];
		$varname = @line[1];

        	# retrieve variable definition from variable_master list
    		@infoArray = &variableDefinition($type);

		$longName = $infoArray[0];
		$natUnits = $infoArray[1];
		$repUnits = $infoArray[2];

		if($varname eq "TSOI" || $varname eq "SOILLIQ" || $varname eq "SOILICE") { 
			printf fp_main "  <TH ALIGN=LEFT>$varname\n";
			printf fp_main "     <TH ALIGN=LEFT>$longName : layers 1-10\n"; 
			printf fp_main "     <TH ALIGN=LEFT>$natUnits\n";
			printf fp_main "     <TH ALIGN=LEFT>$repUnits\n";
		}
		else {
			printf fp_main "  <TH ALIGN=LEFT>$varname <TH ALIGN=LEFT>$longName\n"; 
			printf fp_main "     <TH ALIGN=LEFT>$natUnits\n";
			printf fp_main "     <TH ALIGN=LEFT>$repUnits\n";
		}
		printf fp_main "<TR>\n";
        }
}
sub writeSetEightPage
{
        undef @fileList;
        $ctr=0;
	@subsetList  = ("zonal","trends","contour","contourDJF-JJA","ann_cycle");

	foreach $subset (@subsetList)
        {
           if ($subset eq "zonal")
                { printf fp_main "<br><font color=maroon size=+2> Line Plots of Seasonal Zonal Means<BR>\n  </font><BR>\n"; }
           if ($subset eq "trends")
                { printf fp_main "<br><font color=maroon size=+2> Line Plots of Annual Trends<BR>\n     </font><BR>\n"; }
           if ($subset eq "contour")
                { printf fp_main "<br><font color=maroon size=+2> Contour Plots of Seasonal Means<BR>\n </font><BR>\n"; }
           if ($subset eq "ann_cycle")
                { printf fp_main "<br><font color=maroon size=+2> Annual Cycle of Zonal Fluxes<BR>\n    </font><BR>\n"; }
           if ($subset eq "contourDJF-JJA")
                { printf fp_main "<br><font color=maroon size=+2> Contour Plots of Seasonal Difference (DJF-JJA)<BR>\n </font><BR>\n"}
	   printf fp_main "<hr noshade size=2 size=\"100%\">\n";
	   printf(fp_main "<TABLE>\n");
	   printf(fp_main "<table style=\"width: 100%; text-align: left;\" border=\"1\" cellpadding=\"2\" cellspacing=\"2\">\n");
	   printf(fp_main "<border=\"1\">\n");
	   printf(fp_main "<TR>\n");
	   printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>Variable Name</font>\n";
	   printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>Long Name</font>\n";
	   printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>NativeUnits</font>\n";
	   printf fp_main "<TH ALIGN=LEFT><font color=maroon size=+2>ReportedUnits</font>\n";
	   printf fp_main "<TR>\n";

           # open list of output variables for set
           $inFile = $wkdir."/master_set".$set."_".$subset.".txt";
           close(fp_in);
           open(fp_in,"<"."$inFile") || die "Can't open set input filelist ($inFile) \n";
   
           # read list of output variables for set
           while(<fp_in>)
           {
                   @line = split(/\s+/,$_);
                   $type    = @line[0];
                   $varname = @line[1];
   
                   # retrieve variable definition from variable_master list
                   @infoArray = &variableDefinition();
		   $longName = $infoArray[0];
		   $natUnits = $infoArray[1];
		   $repUnits = $infoArray[2];
   
                   printf fp_main "  <TH ALIGN=LEFT>$varname <TH ALIGN=LEFT>$longName\n";
                   printf fp_main "     <TH ALIGN=LEFT>$natUnits\n";
                   printf fp_main "     <TH ALIGN=LEFT>$repUnits\n";
                   printf fp_main "<TR>\n";
           }
	   printf(fp_main "<br clear=left>\n");
	   printf(fp_main "</TABLE>\n");
	   printf fp_main "<hr noshade size=2 size=\"100%\">\n";
	}
}
