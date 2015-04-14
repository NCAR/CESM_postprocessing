#!/usr/bin/env perl

#-----------------------------------------------------------------------------------------------
#** @file clean_archive
# @brief script to clean the st_archive 
#*
#-----------------------------------------------------------------------------------------------

use strict;
use Cwd qw(abs_path);
use English;
use Getopt::Long;
use IO::File;
use IO::Handle;
use XML::LibXML;
use Data::Dumper;
use POSIX qw(strftime);
use File::Path;
use File::Basename;
use File::Copy;
use File::Find;
use File::stat;
use File::Glob;

# the st_archive is run in the CASEROOT and needs to look in the CASETOOLS for ConfigCase.pm
my $includedirs = "./Tools";
unshift(@INC, $includedirs);
require ConfigCase;

#-----------------------------------------------------------------------------------------------
#** @brief Setting autoflush (an IO::Handle method) on STDOUT helps in debugging.  It forces the test
# descriptions to be printed to STDOUT before the error messages start.
#*
#-----------------------------------------------------------------------------------------------

*STDOUT->autoflush();                  

# Globals
my %opts = ();

# the global config hash holds all valid XML variables necessary for the clean_archive to function
my %config = ConfigCase->getAllResolved();

#-----------------------------------------------------------------------------------------------
#** @function usage
# @brief print out the command line usage
#*
#-----------------------------------------------------------------------------------------------
sub usage {
    my $usgstatement;
    $usgstatement = <<EOF;

SYNOPSIS

    Stand-alone script to clean the \$DOUT_S_ROOT/\$CASE and \$DOUT_S_ROOT.locked/\$CASE locations depending 
    on the options specified. At least one option must be specified.

CESM OUTPUT FILE NAMING CONVENTIONS

    The clean_archive script adheres to the CESM model file naming conventions defined in
        http://www.cesm.ucar.edu/models/cesm1.2/filename_conventions_cesm.html

USAGE
    clean_archive [options]

OPTIONS
    no_options         Print usage to STDOUT.
    --all              Delete the all the files in the short-term archive locations - \$DOUT_S_ROOT.locked/\$CASE and \$DOUT_S_ROOT/\$CASE.
    --debug            Turn on script debugging messages.
    --diags            Delete intermediate diagnostics work directories defined by [component_name]DIAG_WORKDIR XML variable where 
                       component name is ATM, ICE, LND, or OCN.
    --force            Delete all the \$DOUT_S_ROOT archive directories bypassing the HPSS check.
    --help [or --h]    Print usage to STDOUT.
    --historyslice     Delete from the short-term archive locations all model output history slice data.
    --hpsscheck        Check the short-term archive file list against the HPSS file list.
    --list             List out the contents of the \$DOUT_S_ROOT archive directories.
    --tavg             Delete from the short-term archive locations all diagnostics climatology average files.
    --tseries          Delete from the short-term archive locations all model output variable time series history data.
    --xmlin            List out the contents of the env_archive.xml file in friendly format.

EOF
#" added per for emacs perl mode parsing

    print $usgstatement;
    exit(1);
}


#-----------------------------------------------------------------------------------------------
#** @function getOptions
# @brief Parse command-line options.
#*
#-----------------------------------------------------------------------------------------------
sub getOptions
{
    my $result = GetOptions(
        "all"           => \$opts{'all'}, 	
        "debug"         => \$opts{'debug'}, 	
        "diags"         => \$opts{'diags'}, 	
        "force"         => \$opts{'force'}, 	
	"h|help"        => \$opts{'help'},
        "historyslice"  => \$opts{'historyslice'}, 	
        "hpsscheck"     => \$opts{'hpsscheck'}, 	
        "list"          => \$opts{'list'}, 	
        "tavg"          => \$opts{'tavg'}, 	
        "tseries"       => \$opts{'tseries'}, 	
        "xmlin"         => \$opts{'xmlin'}, 	
    );
    usage() if $opts{'help'};
}


#-----------------------------------------------------------------------------------------------
#** @function checkRun
#** @brief check the run environment and create the associated directories
#-----------------------------------------------------------------------------------------------
sub checkRun
{
    my $statusFile = shift;
    my $runComplete = 0;

    if( defined $opts{'debug'} ) { print qq(In checkRun...\n); }
#
# check if DOUT_S_ROOT is defined
#
    if( !defined $config{'DOUT_S_ROOT'} || uc($config{'DOUT_S_ROOT'}) eq 'UNSET' )
    {
	die qq(clean_archive: Error - XML variable DOUT_S_ROOT is required for root location of short-term achiver. Exiting...\n);
    }
#
# check if DOUT_S_ROOT dir needs to be created (or not) and if it can be read - creation permissions defaults to user's umask setting
# force the output filename to have .locked appended to distinguish from .linked 
#
    my $dir = dirname( $config{'DOUT_S_ROOT'} );
    my $basename = basename( $config{'DOUT_S_ROOT'} );
    $config{'ARCHIVE_DIR_LOCKED'} = qq($dir.locked/$basename);
    $config{'ARCHIVE_DIR_LINKED'} = qq($dir/$basename);
#
# check if the run completed successfully
#
    if( -f $statusFile ) 
    {
	open my $CASESTATUS, "<", "$statusFile"  or die qq(clean_archive: unable to open $statusFile. Exiting...\n);
	while( <$CASESTATUS> ) 
	{
	    chomp $_;
	    if( /^run SUCCESSFUL/ )
	    {
		$runComplete = 1;
	    }
	}
	close( $CASESTATUS );
    }
    return $runComplete;
}


#-----------------------------------------------------------------------------------------------
#** @function readXMLin
# @brief read the archive XML file - env_archive.xml
#*
#-----------------------------------------------------------------------------------------------
sub readXMLin
{
    my $filename = shift;
    if( defined $opts{'debug'} ) { print qq(In readXMLin...\n); }
    my $parser = XML::LibXML->new();
    my $xml = $parser->parse_file($filename);
    return $xml;
}

#-----------------------------------------------------------------------------------------------
#** @function listXMLin
# @brief list archive XML file contents
#*
#-----------------------------------------------------------------------------------------------
sub listXMLin
{
    my ($xml) = shift;
    if( defined $opts{'debug'} ) { print qq(In listXMLin...\n); }
    my $rootel = $xml->getDocumentElement();

    my $schema = <<EOF;

The env_archive.xml brief XML tag schema:

    <comp_archive_spec name="[string:component name] (cpl|dart|cam\*|datm|clm\?|dlnd|rtm|cice|dice|pop|docn|cism|ww3|dwav)">
	<rootdir>[string:root directory name after DOUT_S_ROOT.locked] (rest|cpl|dart|atm|lnd|rof|ice|ocn|glc|wav)</rootdir>
        <multi_instance>[string: multi-instance support] (y|n)</multi_instance>
        <files>
            <file_extension suffix="[string: regular expression for matching file suffix patterns"]>
	    <dispose>[string: specify whether or not to save a copy of the matching files in the RUNDIR in addition to archive] (y|n)</dispose> 
	    <keepLast>[string: specify if the most recent copy of the matching file should be saved in the RUNDIR] (y|n)</keepLast> 
            <tseries_create>[*OPTIONAL* string: create variable time series files] (TRUE|FALSE)</tseries_create>
            <tseries_output_format>[*OPTIONAL* string: variable time series file output format] (netcdf|netcdf4|netcdf4c)</tseries_output_format>
	    <tseries_output_subdir>[*OPTIONAL* string: example: proc/tseries/monthly <tseries_output_subdir>
            <tseries_tper>[*OPTIONAL* string] (monthly|weekly|daily|hourly6|hourly3|hourly1|min30)</tseries_tper>
	    <tseries_filecat_years>[*OPTIONAL* integer] number of years to concatenate into a variable time series file</tseries_filecat_years>
        </files>
	<tseries_time_variant_variables> 
	  <variable>[*OPTIONAL* string] a list of time variant variables included as metadata in each variable time series file.</variable>
	</tseries_time_variant_variables>
    </comp_archive_spec>
			
Run st_archive --help for complete tag schema descriptions.	   

EOF
#" added per for emacs perl mode parsing

    print $schema;

    my $elname = $rootel->getName();
    print qq(Root element is a $elname and it contains ...\n);
#
# list out the components nodes
#
    my @comps = ($xml->findnodes('//comp_archive_spec'));
    foreach my $comp (@comps) {

	my $compname = $comp->getAttribute('name');
	my $rootdir = $comp->findvalue('./rootdir');
	my $multi = $comp->findvalue('./multi_instance');

	print qq(\n============================================================================\n);
	print qq(Component name = $compname\n);
	print qq(rootdir = $rootdir\n);
	print qq(multiple-instance support = $multi\n);

	my @files = $comp->findnodes('./files/file_extension');
        foreach my $file (@files) 
	{
	    my $suffix = $file->getAttribute('suffix');
	    my $subdir = $file->findvalue('./subdir');
	    my $dispose = $file->findvalue('./dispose');
	    my $keepLast = $file->findvalue('./keepLast');
	    my $tseries = $file->findvalue('./tseries_create');
	    my $netcdf = $file->findvalue('./tseries_output_format');
	    my $tseries_subdir = $file->findvalue('./tseries_output_subdir');
	    my $tper = $file->findvalue('./tseries_tper');
	    my $tseries_filecat_years = $file->findvalue('./tseries_filecat_years');


	    print qq(\n***** File extension specification\n);
	    print qq(  suffix = $suffix\n);  
	    print qq(  subdir = $config{'ARCHIVE_DIR_LOCKED'}/$config{'CASENAME'}$rootdir/$subdir\n);
	    print qq(  dispose = $dispose\n);
	    print qq(  keepLast = $keepLast\n);
	    if( length($tseries) > 0 ) { 
		print qq(  create tseries = $tseries\n);  
		print qq(  tseries output file format = $netcdf\n);  
		print qq(  tseries output time period = $tper\n);
		print qq(  tseries subdir = $config{'DOUT_S_ROOT'}/$config{'CASENAME'}$tseries_subdir\n);  
		print qq(  tseries filecat years = $tseries_filecat_years\n);
	    }
	}
	print qq(\n);

	my @tseries_variables = $comp->findnodes('./tseries_time_variant_variables/variable');
	if ($#tseries_variables > 0) {
	    print qq(\n***** $compname Time variant variables\n);
	}
	foreach my $tseries_variable (@tseries_variables) {
	    my $variable = $tseries_variable->textContent;
	    print qq( $variable\n);
	}
    }
    print qq(\n);
}

#-----------------------------------------------------------------------------------------------
#** @function listArchive
# @brief recursive file tree traverse function to print out the archive
# @params dirname directory name
#*
#-----------------------------------------------------------------------------------------------
sub listArchive
{
    my ($thing) = @_;
    if( defined $opts{'debug'} ) { print qq(In listArchive: $thing ...\n); }

    print qq($thing \n);
    return if not -d $thing;
    opendir my $dh, $thing or die;
    while (my $sub = readdir $dh) {
	next if $sub eq '.' or $sub eq '..';
 	listArchive( "$thing/$sub" );
    }
    closedir $dh;
    return;
}


#-----------------------------------------------------------------------------------------------
#** @function hpssCrossCheck
# @brief cross check files between the on-disk archive and the HPSS
#*
#-----------------------------------------------------------------------------------------------
sub hpssCrossCheck
{
    if( defined $opts{'debug'} ) { print qq(In hpssCrossCheck...\n); }

    return;
}

#-----------------------------------------------------------------------------------------------
#** @function cleanArchive_hist
# @brief short term archive clean - deletes history files 
# from both the $DOUT_S_ROOT.locked and $DOUT_S_ROOT directories
#*
#-----------------------------------------------------------------------------------------------
sub cleanArchive_hist
{
    my ($xml) = shift;
    my $rc = 0;

    my $rootel = $xml->getDocumentElement();
    my $elname = $rootel->getName();

    if( defined $opts{'debug'} ) { print qq(In cleanArchive_hist...\n); }

    # crawl through the XMLin looking for /hist dirs and delete in both linked and locked archive dirs
    my @comps = ($xml->findnodes('//comp_archive_spec'));
    foreach my $comp (@comps) 
    {
	my $compname = $comp->getAttribute('name');
	my $rootdir = $comp->findvalue('./rootdir');
	my @files = $comp->findnodes('./files/file_extension');
	foreach my $file (@files) 
	{
	    my $suffix = $file->getAttribute('suffix');
	    my $subdir = $file->findvalue('./subdir');
	    if( lc($subdir) eq 'hist' )
	    {
		my @histdirs;
		my $histdir = qq($config{'ARCHIVE_DIR_LOCKED'}/$config{'CASENAME'}/$rootdir/$subdir);
		push( @histdirs, $histdir);
		my $histdir = qq($config{'ARCHIVE_DIR_LINKED'}/$config{'CASENAME'}/$rootdir/$subdir);
		push( @histdirs, $histdir);

		foreach my $hdir (@histdirs) 
		{
		    if( -d $hdir ) 
		    {
			if( -w $hdir ) 
			{
			    opendir( my $dh, $hdir);
			    my @histfiles = grep { /$suffix/ } readdir $dh;
			    closedir $dh;
			    foreach my $hfile (@histfiles)
			    {
				if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting $hdir/$hfile...\n); }
##				    unlink $hdir/$hfile;
			    }
			}
			else 
			{
			    print qq(clean_archive: Error permission denied for $hdir);
			    return 1;
			}
		    }
		    else
		    {
			print qq(clean_archive: Error $hdir does not exist.);
			return 1;
		    }
		}
	    }
	}
    }
    return 0;
}


#-----------------------------------------------------------------------------------------------
#** @function cleanArchive_tseries
# @brief short term archive clean - deletes time series files from the $DOUT_S_ROOT directories
#*
#-----------------------------------------------------------------------------------------------
sub cleanArchive_tseries
{
    my ($xml) = shift;
    my $rc = 0;

    my $rootel = $xml->getDocumentElement();
    my $elname = $rootel->getName();

    if( defined $opts{'debug'} ) { print qq(In cleanArchive_tseries...\n); }

    # crawl through the XMLin looking for /proc/tseries and delete in linked dirs
    my @comps = ($xml->findnodes('//comp_archive_spec'));
    foreach my $comp (@comps) 
    {
	my $compname = $comp->getAttribute('name');
	my $rootdir = $comp->findvalue('./rootdir');
	my @files = $comp->findnodes('./files/file_extension');
	foreach my $file (@files) 
	{
	    my $suffix = $file->getAttribute('suffix');
	    my $tseries_create = $file->findvalue('./tseries_create');
	    if( lc($tseries_create) eq 'true' )
	    {
		my $subdir = $file->findvalue('./tseries_output_subdir');
		my $tseries_dir = qq($config{'ARCHIVE_DIR_LINKED'}/$config{'CASENAME'}/$rootdir/$subdir);
		if( -d $tseries_dir ) 
		{
		    if( -w $tseries_dir ) 
		    {
			opendir( my $dh, $tseries_dir);
			my @tseriesfiles = grep { /$suffix/ } readdir $dh;
			closedir $dh;
			foreach my $tfile (@tseriesfiles)
			{
			    if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting $tseries_dir/$tfile...\n); }
##				unlink $tseries_dir/$tfile;
			}
		    }
		    else 
		    {
			print qq(clean_archive: Error permission denied for $tseries_dir);
			return 1;
		    }
		}
		else
		{
		    print qq(clean_archive: Error $tseries_dir does not exist.);
		    return 1;
		}
	    }
	}
    }
    return 0;
}

#-----------------------------------------------------------------------------------------------
#** @function cleanArchive_diags
# @brief short term archive clean - deletes diagnostics work files from $DOUT_S_ROOT directories
#*
#-----------------------------------------------------------------------------------------------
sub cleanArchive_diags
{
    my ($xml) = shift;
    my $rc = 0;
    my @diagvars = ('ATMDIAG_WORKDIR','ICEDIAG_WORKDIR','LNDDIAG_WORKDIR','OCNDIAG_WORKDIR');

    if( defined $opts{'debug'} ) { print qq(In cleanArchive_diags...\n); }

    foreach my $diagvar (@diagvars) 
    {
	my $diagdir = $config{$diagvar};
	if( -d $diagdir ) 
	{
	    if( -w $diagdir ) 
	    {
		if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting $diagdir...\n); }
##		rmtree($diagdir);
	    }
	    else 
	    {
		print qq(clean_archive: Error permission denied for $diagdir);
		return 1;
	    }
	}
	else
	{
	    print qq(clean_archive: Error $diagdir does not exist.);
	    return 1;
	}
    }
    return 0;
}


#-----------------------------------------------------------------------------------------------
#** @function cleanArchive_tavg
# @brief short term archive clean - deletes diagnostics tavg files from $DOUT_S_ROOT directories
#*
#-----------------------------------------------------------------------------------------------
sub cleanArchive_tavg
{
    my ($xml) = shift;
    my $rc = 0;
    my @diagvars = ('ATMDIAG_TAVGDIR','ICEDIAG_TAVGDIR','LNDDIAG_TAVGDIR','OCNDIAG_TAVGDIR');

    if( defined $opts{'debug'} ) { print qq(In cleanArchive_tavg...\n); }

    foreach my $diagvar (@diagvars) 
    {
	my $diagdir = $config{$diagvar};
	if( -d $diagdir ) 
	{
	    if( -w $diagdir ) 
	    {
		if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting $diagdir...\n); }
##		rmtree($diagdir);
	    }
	    else 
	    {
		print qq(clean_archive: Error permission denied for $diagdir);
		return 1;
	    }
	}
	else
	{
	    print qq(clean_archive: Error $diagdir does not exist.);
	    return 1;
	}
    }
    return 0;
}

#-----------------------------------------------------------------------------------------------
#** @function cleanArchive_all
# @brief short term archive clean - deletes entire $DOUT_S_ROOT.locked and $DOUT_S_ROOT directories
#*
#-----------------------------------------------------------------------------------------------
sub cleanArchive_all
{
    my $rc = 0;
    my @dirs = (qq($config{'ARCHIVE_DIR_LOCKED'}/$config{'CASENAME'}), qq($config{'ARCHIVE_DIR_LINKED'}/$config{'CASENAME'}));

    if( defined $opts{'debug'} ) { print qq(In cleanArchive_all...\n); }
    
    foreach my $dir (@dirs) 
    {
	if( -d $dir ) 
	{
	    if( -w $dir ) 
	    {
		if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting $dir...\n); }
##		rmtree($diagdir);
	    }
	    else 
	    {
		print qq(clean_archive: Error permission denied for $dir);
		return 1;
	    }
	}
	else
	{
	    print qq(clean_archive: Error $dir does not exist.);
	    return 1;
	}
    }
    return 0;
}

#-----------------------------------------------------------------------------------------------
#** @function main
# @brief Main program
#-----------------------------------------------------------------------------------------------
sub main
{
    my $dname;
    my $rc = 0;

    getOptions();

    # check that at least one option is selected
    my $option = 0;
    foreach my $key ( keys %opts ) {
	if( length( $opts{$key} )) 
	{ 
	    $option = 1; 
	}
    }
    if( !$option ) { usage(); }

    my $runComplete = checkRun( "$config{'CASEROOT'}/CaseStatus" );
    if( !$runComplete )
    {
        print qq(clean_archive: Error - run is not yet complete or was not successful...\n);
        exit 1;
    }

    my $XMLin  = readXMLin( "$config{'CASEROOT'}/env_archive.xml" );

    if ( defined $opts{'list'} && $runComplete )
    {
        # list the directories in the $config{'ARCHIVE_DIR_LOCKED'} directory
	print qq(clean_archive: archive listing of $config{'ARCHIVE_DIR_LOCKED'}:\n\n);
	listArchive( $config{'ARCHIVE_DIR_LOCKED'} );
	print qq(\n\n***********************************************************\n\n);
	print qq(clean_archive: archive listing of $config{'ARCHIVE_DIR_LINKED'}:\n\n);
	listArchive( $config{'ARCHIVE_DIR_LINKED'} );
    }

    if ( defined $opts{'xmlin'} && $runComplete )
    {
        # List out the contents of the env_archive.xml file in friendly format.
	print qq(clean_archive: env_archive.xml listing in $config{'CASEROOT'}:\n\n);
	listXMLin($XMLin);
    }

    if( defined $opts{'historyslice'} && $runComplete )
    {
        # clean up the archive directories deleting the history slice files
	if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting history slice files from $config{'ARCHIVE_DIR_LOCKED'} and $config{'ARCHIVE_DIR_LINKED'}); }
	if( !defined $opts{'force'} ) {
	    hpssCrossCheck('historyslice', $XMLin);
	}
	$rc = cleanArchive_hist($XMLin);
    }

    if( defined $opts{'tseries'} && $runComplete )
    {
        # clean up the archive directories deleting the variable time series files
	if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting variable time series files from $config{'ARCHIVE_DIR_LINKED'}); }
	if( !defined $opts{'force'} ) {
	    hpssCrossCheck('tseries', $XMLin);
	}
	$rc = cleanArchive_tseries($XMLin);
    }

    if( defined $opts{'tavg'} && $runComplete )
    {
        # clean up the archive directories deleting the climatology average files
	if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting climatology files from $config{'ARCHIVE_DIR_LINKED'}); }
	if( !defined $opts{'force'} ) {
	    hpssCrossCheck('tavg', $XMLin);
	}
	$rc = cleanArchive_tavg();
    }

    if( defined $opts{'diags'} && $runComplete )
    {
        # clean up the archive directories deleting the intermediate diagnostics work files
	if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting intermediate diagnostics work files from $config{'ARCHIVE_DIR_LINKED'}); }
	$rc = cleanArchive_diags();
    }

    if( defined $opts{'all'} && $runComplete )
    {
        # clean up the archive directories deleting all files
	if( defined $opts{'debug'} ) { print qq(clean_archive: Deleting $config{'ARCHIVE_DIR_LOCKED'} and $config{'ARCHIVE_DIR_LINKED'}); }
	if( !defined $opts{'force'} ) {
	    hpssCrossCheck('all', $XMLin);
	}
	$rc = cleanArchive_all();
    }

    if( $rc ) 
    {
	# problem with a cleanArchive call
	print qq(clean_archive: Unable to perform options ...\n);
	print Dumper(\%opts);
	exit 1;
    }
    else
    {
	print qq(clean_archive: Completed successfully.\n);
    }
}

main(@ARGV) unless caller;
