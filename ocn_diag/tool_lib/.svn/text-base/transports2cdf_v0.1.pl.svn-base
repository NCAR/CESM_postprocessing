#!/usr/bin/env perl

#
# transports2cdf_v0.1.pl
#
# Strip transports from POP transports files and place in a NetCDF file.
# Keith Lindsay (March 2002)
#
# based on log2cdf_v0.2.pl which was based on proto-getH1.pl by Russell Quong
# http://www.best.com/~quong/perlin20/perlin20.html
#

require 5.003;                  # need this version of Perl or newer
use English;                    # use English names, not cryptic ones
use FileHandle;                 # use FileHandles instead of open(), close()
use Carp;                       # get standard error / warning messages
use strict;                     # force disciplined use of variables
use diagnostics;
use NetCDF;

##
## define documentary variables
##
my ($author) = "Keith Lindsay";
my ($version) = "Version 0.1";
my ($reldate) = "March 2002";

##
## define global variables
##
my ($oname) = "transports.nc";  # default output file name
my ($clobber) = 1;              # should existing NetCDF file be clobbered?
my ($ncfid) = -1;               # NetCDF file handle for transports file
my (@time_vals) = ( );          # time axis of transports file
my ($runid) = "none";           # name of case
my ($basedate) = "0000-01-01";  # base date
my ($filelist_file) = "none";   # name of file containing list of files to be processed

my (%metadata) = (
    "Drake Passage"          => [ "Drake Passage", "drake" ],
    "Mozambique Channel"     => [ "Mozambique Channel", "mozambique" ],
    "Bering Strait"          => [ "Bering Strait", "bering" ],
    "Northwest Passage"      => [ "Northwest Passage", "northwest" ],
    "Indonesian Throughflow" => [ "Indonesia", "indonesia" ],
    "Florida Strait"         => [ "Florida Strait", "florida" ],
    "Windward Passage"       => [ "Windward Passage", "windward" ],
    "Gibraltar"              => [ "Gibraltar", "gibraltar" ],
);

#
# print out a non-crucial for-your-information messages.
# By making fyi() a function, we enable/disable debugging messages easily.
#
sub fyi($) {
    my ($str) = @_;
    print ($str, "\n");
}

sub main() {
    fyi("$PROGRAM_NAME, $version, $author, $reldate.");

    handle_flags();

    open_ofile();

    # handle remaining command line args, namely the input files
    if (@ARGV == 0) {
        if ($filelist_file eq "none") {
            handle_file('-');
        } else {
            my ($filelist_handle) = new FileHandle;
            my ($line) = "";
            fyi("reading file names from file " . $filelist_file);
            open($filelist_handle, $filelist_file);
            if (! defined($filelist_handle)) {
                fyi("Can't open file $filelist_file: $!\n");
                return;
            }
            while (defined($line = <$filelist_handle>)) {
                my (@filename) = split /\s+/, $line;
                handle_file($filename[0]);
            }
            $filelist_handle->close();
        }
    } else {
        my ($i);
        foreach $i (@ARGV) {
            handle_file($i);
        }
    }

    postProcess();              # additional processing after reading input
}

#
# handle all the arguments, in the @ARGV array.
# we assume flags begin with a '-' (dash or minus sign).
#
sub handle_flags() {
    while ($#ARGV >= 0) {
        if ($ARGV[0] =~ /^-o/) {
            shift @ARGV;                # discard ARGV[0] = the -o flag
            $oname = $ARGV[0];          # get arg after -o
        } elsif ($ARGV[0] =~ /^-runid/) {
            shift @ARGV;                # discard ARGV[0] = the -runid flag
            $runid = $ARGV[0];          # get arg after -runid
        } elsif ($ARGV[0] =~ /^-basedate/) {
            shift @ARGV;                # discard ARGV[0] = the -basedate flag
            $basedate = $ARGV[0];       # get arg after -basedate
        } elsif ($ARGV[0] =~ /^-f/) {
            shift @ARGV;                # discard ARGV[0] = the -f flag
            $filelist_file = $ARGV[0];  # get arg after frunid
        } elsif ($ARGV[0] =~ /^-O/) {
            $clobber = 1;
        } elsif ($ARGV[0] =~ /^-A/) {
            $clobber = 0;
        } else {
            last;                       # break out of this loop
        }
        shift @ARGV;                    # discard processed flag
    }
}

#
# open the output file
#
sub open_ofile() {
    if ( (-e $oname) && (! $clobber)) {
        #
        # open file for appending and read in time values
        #
        $ncfid = NetCDF::open($oname, NetCDF::WRITE);
        my $time_len;                 # length of time dimension
        my $time_name;                # place holder for diminq call
        my $time_dimid = NetCDF::dimid($ncfid, "time");
        NetCDF::diminq($ncfid, $time_dimid, \$time_name, \$time_len);
        $#time_vals = $time_len - 1;

        my $time_varid = NetCDF::varid($ncfid, "time");
        my @start = ( 0 );
        my @count = ( $time_len );
        NetCDF::varget($ncfid, $time_varid, \@start, \@count, \@time_vals);
    } else {
        #
        # create file, silently clobbering any existing one
        #
        $ncfid = NetCDF::create($oname, NetCDF::CLOBBER);
        global_att($ncfid, $runid);
        my ($dimid, $varid);
        $dimid = NetCDF::dimdef($ncfid, "time", NetCDF::UNLIMITED);
        $varid = NetCDF::vardef($ncfid, "time", NetCDF::DOUBLE, \$dimid);
        NetCDF::attput($ncfid, $varid, "long_name", NetCDF::CHAR, "time");
        NetCDF::attput($ncfid, $varid, "units", NetCDF::CHAR, "days since " . $basedate . " 00:00:00 GMT");
        NetCDF::attput($ncfid, $varid, "calendar", NetCDF::CHAR, "noleap");
        NetCDF::endef($ncfid);

        #
        # initially there are no time values
        #
        $#time_vals = -1;
    }
}

#
# handle_file(FILENAME);
# Open a file handle or input stream for the file named FILENAME.
# If FILENAME == '-' use stdin instead.
#
sub handle_file($) {
    my ($infile) = @_;
    fyi("handle_file($infile)");
    if ($infile eq "-") {
        read_file(\*STDIN);             # \*STDIN=input stream for STDIN.
    } else {
        my ($IN) = new FileHandle;
        if ($infile =~ /\.gz$/) {       # gunzip file if it has .gz extension
           open($IN, "gunzip -c $infile |");
        } else {
           open($IN, $infile);
        }
        if (! defined($IN)) {
            fyi("Can't open file $infile: $!\n");
            return;
        }
        read_file($IN);                 # $IN = file handle for $infile
        $IN->close();                   # done, close the file.
    }
}

#
# read_file(INPUT_STREAM, filename);
#
sub read_file($) {
    my ($IN) = @_;
    my ($line) = ("");
    my (%sect_ind_hash) = ("I" => 1, "II" => 2, "III" => 3, "IV" => 4);

    my $time_dimid = NetCDF::dimid($ncfid, "time");
    my @dimids = ( $time_dimid );
    my ($time_ind, @start, @count, $lname, $sname, $varid);
    my (@val_current) = ( 0 );

    #
    # process all non-blank lines
    #
    while (defined($line = <$IN>)) {
        if ($line =~ /^ *$/) { next; }
        $line =~ s/D\+/E+/g;
        $line =~ s/D\-/E-/g;
        #
        # break line into tokens and skip initial token
        # from blank at beginning of line
        #
        my (@tokens)   = split /\s+/, $line;
        shift @tokens;

        my ($time_val) = 0 + $tokens[0] ; shift @tokens;
        my ($mass)     = 0 + $tokens[0] ; shift @tokens;
        my ($heat)     = 0 + $tokens[0] ; shift @tokens;
        my ($salt)     = 0 + $tokens[0] ; shift @tokens;

        my ($poplname) = $tokens[0] ; shift @tokens;
        my ($sect_ind) = 0;
        while ($#tokens >= 0) {
           if (defined($sect_ind_hash{$tokens[0]})) {
              $sect_ind = $sect_ind_hash{$tokens[0]};
           } else {
              $poplname = $poplname . " " . $tokens[0];
           }
           shift @tokens;
        }

        $time_ind = get_time_ind($time_val, @time_vals);
        $time_vals[$time_ind] = $time_val;
        $varid = NetCDF::varid($ncfid, "time");
        @start = ( $time_ind ); @count = ( 1 ) ;
        NetCDF::varput($ncfid, $varid, \@start, \@count, \$time_val);

        if (! defined($metadata{$poplname}[0])) {
           fyi("unknown name " . $poplname);
           next;
        }

        $lname = "mass transport through " . $metadata{$poplname}[0] ;
        $sname = $metadata{$poplname}[1] . "_mass" ;
        def_var($ncfid, $sname, NetCDF::FLOAT, $lname, "sverdrups", 1.0, @dimids);
        $varid = NetCDF::varid($ncfid, $sname);
        if ($sect_ind > 1) {
           NetCDF::varget($ncfid, $varid, \@start, \@count, \@val_current);
           $mass = $mass + $val_current[0] ;
        }
        NetCDF::varput($ncfid, $varid, \@start, \@count, \$mass);

        $lname = "heat transport through " . $metadata{$poplname}[0] ;
        $sname = $metadata{$poplname}[1] . "_heat" ;
        def_var($ncfid, $sname, NetCDF::FLOAT, $lname, "PW", 1.0, @dimids);
        $varid = NetCDF::varid($ncfid, $sname);
        if ($sect_ind > 1) {
           NetCDF::varget($ncfid, $varid, \@start, \@count, \@val_current);
           $heat = $heat + $val_current[0] ;
        }
        NetCDF::varput($ncfid, $varid, \@start, \@count, \$heat);

    }
}

#
# def_var($ncfid, $varname, $type, $long_name, $units, @scale_factor, @dimids);
# Define a NetCDF variable, first checking to see if it is defined.
#
sub def_var($$$$$$$) {
    my ($ncfid, $varname, $type, $long_name, $units, $scale_factor, @dimids) = @_;

    NetCDF::opts(0);
    my $varid = NetCDF::varid($ncfid, $varname);
    NetCDF::opts(NetCDF::VERBOSE | NetCDF::FATAL);

    if ($varid == -1) {
        NetCDF::redef($ncfid);
        $varid = NetCDF::vardef($ncfid, $varname, $type, \@dimids);
        if ($long_name) {
            NetCDF::attput($ncfid, $varid, "long_name", NetCDF::CHAR, $long_name);
        }
        if ($units) {
            NetCDF::attput($ncfid, $varid, "units", NetCDF::CHAR, $units);
        }
        if ($scale_factor != 1.0) {
            NetCDF::attput($ncfid, $varid, "scale_factor", $type, $scale_factor);
        }
        if ($type == NetCDF::FLOAT || $type == NetCDF::DOUBLE) {
            my ($msv) = 9.9692099683868690e+36;
            NetCDF::attput($ncfid, $varid, "_FillValue", $type, $msv);
            NetCDF::attput($ncfid, $varid, "missing_value", $type, $msv);
        }
        NetCDF::endef($ncfid);
    }
}

#
# global_att($ncfid, $runid);
# Put in global attributes.
#
sub global_att($$$$) {
    my ($ncfid, $runid) = @_;

    NetCDF::attput($ncfid, NetCDF::GLOBAL, "history", NetCDF::CHAR, "created by $PROGRAM_NAME, $version");
    my $now = localtime();
    NetCDF::attput($ncfid, NetCDF::GLOBAL, "processing_date", NetCDF::CHAR, $now);
    NetCDF::attput($ncfid, NetCDF::GLOBAL, "title", NetCDF::CHAR, $runid);
}

#
# get_time_ind(time_val, time_val_array);
#
sub get_time_ind($$) {
    my ($time_val, @time_val_array) = @_;

    my $time_ind;
    my $time_len = $#time_val_array;

    if ($time_len >= 0 && $time_val_array[$time_len] < $time_val) {
        return $time_len + 1;
    }

    for ($time_ind = $#time_val_array; $time_ind >= 0; $time_ind--) {
        if ($time_val_array[$time_ind] == $time_val) {
            return $time_ind;
        }
    }
    return $time_len + 1;

}

sub postProcess() {
    if ($ncfid != -1) {
        NetCDF::close($ncfid);
    }
}

# start executing at main()
#
main();
0;              # return 0 (no error from this script)

