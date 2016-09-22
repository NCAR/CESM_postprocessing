#!/usr/bin/env perl

#
# log2cdf.pl
#
# Strip diagnostics from POP logfile and place in a NetCDF file.
# Keith Lindsay (May 2001)
# (first excursion into perl)
#
# based on proto-getH1.pl by Russell Quong
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
my ($version) = "Version 0.2";
my ($reldate) = "March 2002";

##
## define global variables
##
my ($char_len) = 128;           # length of NetCDF strings
my ($filelist_file) = "none";   # name of file containing list of files to be processed
my ($clobber) = 1;              # should existing NetCDF file be clobbered?
my ($proc_surf) = 1;            # should surface information be extracted?
my ($proc_levels) = 0;          # should level information be extracted?
my ($ncfid_tavg) = -1;          # NetCDF file handle for tavg file
my ($ncfid_diag) = -1;          # NetCDF file handle for diag file
my (@tavg_time_vals) = ( ) ;    # time axis of tavg file
my (@diag_time_vals) = ( ) ;    # time axis of diag file
my ($runid) = "";               # name of case
my ($km) = 0;                   # number of vertical levels
my (@tr_names) = ( ) ;          # names of tracers
my (%tavg_vals) = ( ) ;         # (name,value) pairs for tavg variables
my (%monthnum) = (              # (monthname,index) pairs
    "jan" =>  1,
    "feb" =>  2,
    "mar" =>  3,
    "apr" =>  4,
    "may" =>  5,
    "jun" =>  6,
    "jul" =>  7,
    "aug" =>  8,
    "sep" =>  9,
    "oct" => 10,
    "nov" => 11,
    "dec" => 12,
);

my (%tavg_metadata) = (         # (variable,[units,scale_factor]) pairs   
    "PO4"     => [ "umol/L",            1.0e3 ],
    "DOP"     => [ "umol/L",            1.0e3 ],
    "DIC"     => [ "umol/L",            1.0e3 ],
    "ALK"     => [ "ueq/L",             1.0e3 ],
    "O2"      => [ "umol/L",            1.0e3 ],
    "Fg_CO2"  => [ "Pg C/y",           1.36e6 ],
    "Fcomp_POP" => [ "Pg C/y",         1.59e8 ],
    "IAGE"    => [ "years",             1.0e0 ],
    "IAGE_OS" => [ "years",             1.0e0 ],
    "IAGE_US" => [ "years",             1.0e0 ],
    "TEMP"    => [ "C",                 1.0e0 ],
    "SALT"    => [ "psu",               1.0e3 ],   # convert from msu
    "TEMP2"   => [ "C^2",               1.0e0 ],
    "SALT2"   => [ "psu^2",             1.0e6 ],   # convert from msu
    "UVEL"    => [ "cm/sec",            1.0e0 ],
    "VVEL"    => [ "cm/sec",            1.0e0 ],
    "KE"      => [ "cm^2/sec^2",        1.0e0 ],
    "ST"      => [ "C psu",             1.0e3 ],   # convert from msu
    "RHO"     => [ "g/cm^3",            1.0e0 ],
    "UET"     => [ "C/sec",             1.0e0 ],
    "VNT"     => [ "C/sec",             1.0e0 ],
    "WTT"     => [ "C/sec",             1.0e0 ],
    "UES"     => [ "C/sec",             1.0e0 ],
    "VNS"     => [ "psu/sec",           1.0e3 ],   # convert from msu
    "WTS"     => [ "psu/sec",           1.0e3 ],   # convert from msu
    "UEU"     => [ "",                  1.0e0 ],
    "VNU"     => [ "",                  1.0e0 ],
    "WTU"     => [ "",                  1.0e0 ],
    "UEV"     => [ "",                  1.0e0 ],
    "VNV"     => [ "",                  1.0e0 ],
    "WTV"     => [ "",                  1.0e0 ],
    "PV"      => [ "1/sec",             1.0e0 ],
    "Q"       => [ "g/cm^4",            1.0e0 ],
    "PD"      => [ "g/cm^3",            1.0e0 ],
    "UDP"     => [ "",                  1.0e0 ],
    "PEC"     => [ "",                  1.0e0 ],
    "NCNV"    => [ "",                  1.0e0 ],
    "VUF"     => [ "",                  1.0e0 ],
    "VVF"     => [ "",                  1.0e0 ],
    "UV"      => [ "cm^2/sec^2",        1.0e0 ],
    "RHOU"    => [ "g/cm^2/sec",        1.0e0 ],
    "RHOV"    => [ "g/cm^2/sec",        1.0e0 ],
    "PVWM"    => [ "",                  1.0e0 ],
    "PVWP"    => [ "",                  1.0e0 ],
    "UPV"     => [ "",                  1.0e0 ],
    "VPV"     => [ "",                  1.0e0 ],
    "URHO"    => [ "",                  1.0e0 ],
    "VRHO"    => [ "",                  1.0e0 ],
    "WRHO"    => [ "",                  1.0e0 ],
    "UQ"      => [ "g/cm^3/sec",        1.0e0 ],
    "VQ"      => [ "g/cm^3/sec",        1.0e0 ],
    "SHF"     => [ "W/m^2",             1.0e0 ],
    "SHF_QSW" => [ "W/m^2",             1.0e0 ],
    "SFWF"    => [ "mm/day",          86400.0 ], # convert from kg/m^2/sec, ignore old versions in m/y
    "SSH"     => [ "cm",                1.0e0 ],
    "H2"      => [ "cm^2",              1.0e0 ],
    "H3"      => [ "",                  1.0e0 ],
    "TAUX"    => [ "dyne/cm^2",         1.0e0 ],
    "TAUY"    => [ "dyne/cm^2",         1.0e0 ],
    "SU"      => [ "cm^2/sec",          1.0e0 ],
    "SV"      => [ "cm^2/sec",          1.0e0 ],
    "T1-8"    => [ "C",                 1.0e0 ],
    "S1-8"    => [ "psu",               1.0e3 ], # convert from msu
    "U1-8"    => [ "cm/sec",            1.0e0 ],
    "V1-8"    => [ "cm/sec",            1.0e0 ],
    "HDIFT"   => [ "",                  1.0e0 ],
    "ADVT"    => [ "",                  1.0e0 ],
    "HMXL"    => [ "m",                1.0e-2 ], # convert from cm
    "HBLT"    => [ "m",                1.0e-2 ], # convert from cm
    "XMXL"    => [ "m",                1.0e-2 ], # convert from cm
    "XBLT"    => [ "m",                1.0e-2 ], # convert from cm
    "TMXL"    => [ "m",                1.0e-2 ], # convert from cm
    "TBLT"    => [ "m",                1.0e-2 ], # convert from cm
    "RESID_T" => [ "W/m^2",             1.0e0 ],
    "RESID_S" => [ "mm/day",          86400.0 ], # convert from kg/m^2/sec, ignore old versions in m/y
    "PREC_F"  => [ "mm/day",          86400.0 ], # convert from kg/m^2/sec
    "EVAP_F"  => [ "mm/day",          86400.0 ], # convert from kg/m^2/sec
    "MELT_F"  => [ "mm/day",          86400.0 ], # convert from kg/m^2/sec
    "ROFF_F"  => [ "mm/day",          86400.0 ], # convert from kg/m^2/sec
    "SALT_F"  => [ "mm/day",          86400.0 ], # convert from kg/m^2/sec
    "SENH_F"  => [ "W/m^2",             1.0e0 ],
    "LWUP_F"  => [ "W/m^2",             1.0e0 ],
    "LWDN_F"  => [ "W/m^2",             1.0e0 ],
    "MELTH_F" => [ "W/m^2",             1.0e0 ],
    "QFLUX"   => [ "W/m^2",             1.0e0 ],
    "UISOP"   => [ "cm/sec",            1.0e0 ],
    "VISOP"   => [ "cm/sec",            1.0e0 ],
    "WISOP"   => [ "cm/sec",            1.0e0 ],
    "FW"      => [ "cm/sec",            1.0e0 ],
    "TFW_T"   => [ "W/m^2",             1.0e0 ],
    "TFW_S"   => [ "mm/day",          86400.0 ], # convert from kg/m^2/sec
    "WVEL"    => [ "cm/sec",            1.0e0 ],
    "NINO_1_PLUS_2"  => [ "C",          1.0e0 ],
    "NINO_3"         => [ "C",          1.0e0 ],
    "NINO_3_POINT_4" => [ "C",          1.0e0 ],
    "NINO_4"         => [ "C",          1.0e0 ],
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
        if ($ARGV[0] =~ /^-f/) {
            shift @ARGV;                # discard ARGV[0] = the -f flag
            $filelist_file = $ARGV[0];  # get arg after -f
        } elsif ($ARGV[0] =~ /^-O/) {
            $clobber = 1;
        } elsif ($ARGV[0] =~ /^-A/) {
            $clobber = 0;
        } elsif ($ARGV[0] =~ /^-nosurf/) {
            $proc_surf = 0;
        } elsif ($ARGV[0] =~ /^-surf/) {
            $proc_surf = 1;
        } elsif ($ARGV[0] =~ /^-nolevels/) {
            $proc_levels = 0;
        } elsif ($ARGV[0] =~ /^-levels/) {
            $proc_levels = 1;
        } else {
            last;                       # break out of this loop
        }
        shift @ARGV;                    # discard processed flag
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

    #
    # read till POP logfile header is found
    #
    while (defined($line = <$IN>) && ! ($line =~ /Parallel Ocean Program/)) {
    }

    if (! defined($line)) {
        fyi("POP Header not found");
        return;
    }

    proc_header($IN);

    while (defined($line = <$IN>)) {
        if ($line =~ /Step number/) {
            proc_diag($IN, $line);
            next;
        }
        if ($line =~ /Global Time Averages/) {
            proc_tavg($IN, $line);
            next;
        }
    }
}

#
# proc_header(INPUT_STREAM);
# process POP header
# collect run information & open/create output file
#
sub proc_header($) {
    my ($IN) = @_;
    my ($line, $oldrunid) = ("", $runid);
    my ($POPversion) = "";
    my ($CCSM_mod_tag) = "";
    my (@dz, @z_t, @z_w) = ((), (), ());
    my ($has_diag) = 0;
    my ($diag_all_levels) = 0;
    my ($has_tavg) = 0;

    $#tr_names = 1;
    $tr_names[0] = "TEMP";
    $tr_names[1] = "SALT";

    while (defined($line = <$IN>) && ! ($line =~ /End of initialization/)) {
        if ($line =~ /Version (.*)/) {
            $POPversion = $1;
            fyi("$POPversion");
            next;
        }
        if ($line =~ /CCSM modification tag: (.*)/) {
            $CCSM_mod_tag = $1;
            next;
        }
        if ($line =~ /Global problem size: \s*(\d*)\s*x\s*(\d*)\s*x\s*(\d*)/) {
            $km = $3;
            $#dz = $km - 1;
            $#z_t = $km - 1;
            $#z_w = $km;
            read_vgrid($IN, \@dz, \@z_t, \@z_w);
            next;
        }
        if ($line =~ /Run id: (.*)/) {
            $runid = $1;
            next;
        }
        if ($line =~ /Global +diagnostics computed/) {
            $has_diag = 1;
            next;
        }
        if ($line =~ /Diagnostics output for all vertical levels/) {
            $diag_all_levels = 1;
            next;
        }
        if ($line =~ /TRACER NAME/) {
            read_tr_names($IN);
            next;
        }
        if (($line =~ /Tavg options/) || ($line =~ /Tavg:/)) {
            read_tavg_names($IN, \$has_tavg, $POPversion);
            next;
        }
    }

    update_tavg_metadata($CCSM_mod_tag);

    my $tr_count = $#tr_names + 1;

    #
    # set up diag NetCDF file
    # if file is required, do nothing only if file is open & runid == oldrunid
    #
    if ($has_diag) {
        #
        # if (runid == oldrunid) && (file already open) then do nothing
        #
        if (($runid ne $oldrunid) || ($ncfid_diag == -1)) {
            #
            # if (file open) then close it
            #
            if ($ncfid_diag != -1) {
                NetCDF::close($ncfid_diag);
                $ncfid_diag = -1;
            }
            #
            # generate filename & open/create it
            #
            my $ncfilename = "diagnostics.nc";
            if ( (-e $ncfilename) && (! $clobber)) {
                $ncfid_diag = NetCDF::open($ncfilename, NetCDF::WRITE);

                #
                # read in time values
                #
                my $time_len;                 # length of time dimension
                my $time_name;                # place holder for diminq call
                my $time_dimid = NetCDF::dimid($ncfid_diag, "time");
                NetCDF::diminq($ncfid_diag, $time_dimid, \$time_name, \$time_len);
                $#diag_time_vals = $time_len - 1;

                my $time_varid = NetCDF::varid($ncfid_diag, "time");
                my @start = ( 0 );
                my @count = ( $time_len );
                NetCDF::varget($ncfid_diag, $time_varid, \@start, \@count, \@diag_time_vals);

            } else {
                $ncfid_diag = NetCDF::create($ncfilename, NetCDF::CLOBBER);
                global_att($ncfid_diag, $POPversion, $CCSM_mod_tag, $runid);
                my ($dimid, $varid);
                $dimid = NetCDF::dimdef($ncfid_diag, "time", NetCDF::UNLIMITED);
                $varid = NetCDF::vardef($ncfid_diag, "time", NetCDF::DOUBLE, \$dimid);
                NetCDF::attput($ncfid_diag, $varid, "long_name", NetCDF::CHAR, "time");
                NetCDF::attput($ncfid_diag, $varid, "units", NetCDF::CHAR, "days since 0000-01-01 00:00:00 GMT");
                NetCDF::attput($ncfid_diag, $varid, "calendar", NetCDF::CHAR, "noleap");

                #
                # initially there are no time values
                #
                $#diag_time_vals = -1;

                my $chars_dimid = NetCDF::dimdef($ncfid_diag, "chars", $char_len);

                $dimid = NetCDF::dimdef($ncfid_diag, "tracers", $tr_count);

                my $varname = "tracers_label"; my @dimids = ($dimid, $chars_dimid);
                def_var($ncfid_diag, $varname, NetCDF::CHAR, "Tracer Identification", "", 1.0, @dimids);

                if ($proc_levels) {
                    $dimid = NetCDF::dimdef($ncfid_diag, "z_t", $km);
                    $varid = NetCDF::vardef($ncfid_diag, "z_t", NetCDF::DOUBLE, \$dimid);
                    NetCDF::attput($ncfid_diag, $varid, "long_name", NetCDF::CHAR, "Depth (T grid)");
                    NetCDF::attput($ncfid_diag, $varid, "units", NetCDF::CHAR, "m");
                    NetCDF::attput($ncfid_diag, $varid, "positive", NetCDF::CHAR, "down");
                    NetCDF::attput($ncfid_diag, $varid, "edges", NetCDF::CHAR, "z_w");

                    $dimid = NetCDF::dimdef($ncfid_diag, "z_w", $km+1);
                    $varid = NetCDF::vardef($ncfid_diag, "z_w", NetCDF::DOUBLE, \$dimid);
                    NetCDF::attput($ncfid_diag, $varid, "long_name", NetCDF::CHAR, "Depth (W grid)");
                    NetCDF::attput($ncfid_diag, $varid, "units", NetCDF::CHAR, "m");
                    NetCDF::attput($ncfid_diag, $varid, "positive", NetCDF::CHAR, "down");
                    NetCDF::endef($ncfid_diag);

                    my ($start, $count);

                    $start = 0; $count = $km;
                    $varid = NetCDF::varid($ncfid_diag, "z_t");
                    NetCDF::varput($ncfid_diag, $varid, \$start, \$count, \@z_t);

                    $start = 0; $count = $km+1;
                    $varid = NetCDF::varid($ncfid_diag, "z_w");
                    NetCDF::varput($ncfid_diag, $varid, \$start, \$count, \@z_w);
                } else {
                    NetCDF::endef($ncfid_diag);
                }

                $varid = NetCDF::varid($ncfid_diag, "tracers_label");
                for (my $n = 0; $n < $tr_count; $n++) {
                    my (@start, @count);
                    @start = ($n, 0); @count = (1, length($tr_names[$n]));
                    NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$tr_names[$n]);
                }
            }
        }
        #
        # define diag vars
        #
        NetCDF::redef($ncfid_diag);
        my $time_dimid = NetCDF::dimid($ncfid_diag, "time");
        my ($tr_name, $varname, $varid, $units, @dimids);

        $varname = "step"; @dimids = ($time_dimid);
        def_var($ncfid_diag, $varname, NetCDF::DOUBLE,
            "Model Step Number", "", 1.0, @dimids);

        $varname = "MEAN_KE"; @dimids = ($time_dimid);
        def_var($ncfid_diag, $varname, NetCDF::DOUBLE,
            "mean kinetic energy", "cm^2/sec^2", 1.0, @dimids);

        foreach $tr_name (@tr_names) {
            if ($tr_name eq "TEMP") {
                $units = "C";
            } elsif ($tr_name eq "SALT") {
                $units = "psu";
            } elsif ($tr_name eq "sphytoChl" || $tr_name eq "diatChl") {
                $units = "ng Chl/cm^3";
            } else {
                $units = "nmol/cm^3";
            }

            $varname = $tr_name; @dimids = ($time_dimid);
            def_var($ncfid_diag, $varname, NetCDF::DOUBLE, "$varname", $units, 1.0, @dimids);

            $varname = "delta_" . $tr_name . "_vdiff"; @dimids = ($time_dimid);
            def_var($ncfid_diag, $varname, NetCDF::DOUBLE,
                "$tr_name rate of change, vert. diff.", $units."/sec", 1.0, @dimids);

            $varname = "delta_" . $tr_name . "_source"; @dimids = ($time_dimid);
            def_var($ncfid_diag, $varname, NetCDF::DOUBLE,
                "$tr_name rate of change, int. sources", $units."/sec", 1.0, @dimids);

            $varname = "sflx_" . $tr_name; @dimids = ($time_dimid);
            def_var($ncfid_diag, $varname, NetCDF::DOUBLE,
                "$tr_name surface flux", $units." cm/sec", 1.0, @dimids);

            if ($diag_all_levels && $proc_surf) {
                $varname = $tr_name . "_surf";
                @dimids = ($time_dimid);
                def_var($ncfid_diag, $varname, NetCDF::DOUBLE,
                    "surface $tr_name", $units, 1.0, @dimids);
            }

            if ($diag_all_levels && $proc_levels) {
                $varname = $tr_name . "_lev";
                my $z_t_dimid  = NetCDF::dimid($ncfid_diag, "z_t");
                @dimids = ($time_dimid, $z_t_dimid);
                def_var($ncfid_diag, $varname, NetCDF::DOUBLE,
                    "level averages of $tr_name", $units, 1.0, @dimids);
            }
        }

        $varname = "MEAN_SSH"; @dimids = ($time_dimid);
        def_var($ncfid_diag, $varname, NetCDF::DOUBLE,
            "mean sea surface height", "cm", 1.0, @dimids);

        NetCDF::endef($ncfid_diag);
    }

    #
    # set up tavg NetCDF file
    # if file is required, do nothing only if file is open & runid == oldrunid
    #
    if ($has_tavg) {
        #
        # if (runid == oldrunid) && (file already open) then do nothing
        #
        if (($runid ne $oldrunid) || ($ncfid_tavg == -1)) {
            #
            # if (file open) then close it
            #
            if ($ncfid_tavg != -1) {
                NetCDF::close($ncfid_tavg);
                $ncfid_tavg = -1;
            }
            #
            # generate filename & open/create it
            #
            my $ncfilename = "tavg.nc";
            if ( (-e $ncfilename) && (! $clobber)) {
                $ncfid_tavg = NetCDF::open($ncfilename, NetCDF::WRITE);

                #
                # read in time values
                #
                my $time_len;                 # length of time dimension
                my $time_name;                # place holder for diminq call
                my $time_dimid = NetCDF::dimid($ncfid_tavg, "time");
                NetCDF::diminq($ncfid_tavg, $time_dimid, \$time_name, \$time_len);
                $#tavg_time_vals = $time_len - 1;

                my $time_varid = NetCDF::varid($ncfid_tavg, "time");
                my @start = ( 0 );
                my @count = ( $time_len );
                NetCDF::varget($ncfid_tavg, $time_varid, \@start, \@count, \@tavg_time_vals);
            } else {
                $ncfid_tavg = NetCDF::create($ncfilename, NetCDF::CLOBBER);
                global_att($ncfid_tavg, $POPversion, $CCSM_mod_tag, $runid);
                my ($dimid, $varid);
                $dimid = NetCDF::dimdef($ncfid_tavg, "time", NetCDF::UNLIMITED);
                $varid = NetCDF::vardef($ncfid_tavg, "time", NetCDF::DOUBLE, \$dimid);
                NetCDF::attput($ncfid_tavg, $varid, "long_name", NetCDF::CHAR, "time");
                NetCDF::attput($ncfid_tavg, $varid, "units", NetCDF::CHAR, "days since 0000-01-01 00:00:00 GMT");
                NetCDF::attput($ncfid_tavg, $varid, "calendar", NetCDF::CHAR, "noleap");

                #
                # initially there are no time values
                #
                $#tavg_time_vals = -1;
 
                my $chars_dimid = NetCDF::dimdef($ncfid_tavg, "chars", $char_len);

                my $tr_count = $#tr_names + 1;
                $dimid = NetCDF::dimdef($ncfid_tavg, "tracers", $tr_count);

                my $varname = "tracers_label"; my @dimids = ($dimid, $chars_dimid);
                def_var($ncfid_tavg, $varname, NetCDF::CHAR, "Tracer Identification", "", 1.0, @dimids);
                NetCDF::endef($ncfid_tavg);
            }
        }
        #
        # define tavg vars
        #
        NetCDF::redef($ncfid_tavg);
        my $time_dimid = NetCDF::dimid($ncfid_tavg, "time");
        my ($tavg_var, $units, $scale_factor, @dimids);
        #
        # define variables in order of hash output
        # when writing out data, do so in same order for file performance
        #
        foreach $tavg_var (sort keys %tavg_vals) {
            if (defined($tavg_metadata{$tavg_var})) {
               $units = $tavg_metadata{$tavg_var}[0];
               $scale_factor = $tavg_metadata{$tavg_var}[1];
            } else {
               $units = "";
               $scale_factor = 1.0;
            }
            @dimids = ($time_dimid);
            def_var($ncfid_tavg, $tavg_var, NetCDF::FLOAT,
                "time-average of $tavg_var", $units, $scale_factor, @dimids);
        }
        NetCDF::endef($ncfid_tavg);

        my $varid = NetCDF::varid($ncfid_tavg, "tracers_label");
        for (my $n = 0; $n < $tr_count; $n++) {
            my (@start, @count);
            @start = ($n, 0); @count = (1, length($tr_names[$n]));
            NetCDF::varput($ncfid_tavg, $varid, \@start, \@count, \$tr_names[$n]);
        }
    }

}

#
# read_vgrid(INPUT_STREAM, ref2dz, ref2z_t, ref2z_w);
#
sub read_vgrid($$$$) {
    my ($IN, $ref2dz, $ref2z_t, $ref2z_w) = @_;
    my ($line, @arr) = ("", ());

    #
    # Read & skip till vgrid header. Then skip next 2 lines.
    #
    while (defined($line = <$IN>) && ! ($line =~ /Vertical grid:/)) {
    }
    if (! defined($line)) {
        fyi("vgrid header not found");
        return;
    }
    if (! defined($line = <$IN>)) { return; }
    if (! defined($line = <$IN>)) { return; }

    #
    # Read in dz (convert to m from cm) & compute z_w and z_t.
    #
    $$ref2z_w[0] = 0.0;
    for (my $k=0; $k<$km; $k++) {
        if (! defined($line = <$IN>)) { return; }
        @arr = split /\s+/, $line;
        $$ref2dz[$k]   = 0.01 * $arr[2];
        $$ref2z_w[$k+1] = $$ref2z_w[$k] + $$ref2dz[$k];
        $$ref2z_t[$k]   = $$ref2z_w[$k] + 0.5 * $$ref2dz[$k];
    }
}

#
# read_tr_names(INPUT_STREAM);
# read tracer names & store into hash table
#
sub read_tr_names($) {
    my ($IN) = @_;
    my ($line, @arr) = ("", ());

    $#tr_names = 1;
    $tr_names[0] = "TEMP";
    $tr_names[1] = "SALT";

    #
    # Read & process till line of dashes.
    #
    while (defined($line = <$IN>) && ! ($line =~ /-----/)) {
        @arr = split /\s+/, $line;
        $tr_names[$arr[1]-1] = $arr[2];
    }
}

#
# read_tavg_names(INPUT_STREAM, ref2has_tavg, POPversion);
# read tavg variables and set up hash table
#
sub read_tavg_names($$) {
    my ($IN, $ref2has_tavg, $POPversion) = @_;
    my ($line, @POPversion_arr, @arr) = ("", (), ());

    #
    # Read & skip till tavg diagnostics message.
    #
    while (defined($line = <$IN>) && ! ($line =~ /tavg diagnostics/)) {
    }
    if (! defined($line)) {
        fyi("tavg diagnostics line not found");
        return;
    }
    if ($line =~ /tavg diagnostics off/) {
        $$ref2has_tavg = 0;
        return;
    }
    $$ref2has_tavg = 1;

    @POPversion_arr = split /\s+/, $POPversion;

    if ($POPversion_arr[0] eq "1.4.3") {
        #
        # Get 2d & 3d counts, reading till non-blank line.
        #
        if (! defined($line = <$IN>)) { return; }
        my ($ref2cnt, $twoDcnt, $threeDcnt, $FvICEcnt);
        foreach $ref2cnt (\$twoDcnt, \$threeDcnt, \$FvICEcnt) {
           while (defined($line = <$IN>) && ($line =~ /^ *$/)) { }
           if (! defined($line)) { return; }
           @arr = split /\s+/, $line;
           $$ref2cnt = $arr[4];
        }

        undef %tavg_vals;
        %tavg_vals = ();
        #
        # Skip 'tavg diagnostics requested for fields' line, reading till non-blank line.
        # Get 2d variable names, reading till non-blank line.
        # Skip 'Begin testing 3-D names' line, reading till non-blank line.
        # Get 3d variable names, reading till non-blank line.
        #
        my $klim;
        foreach $klim ($twoDcnt, $FvICEcnt, $threeDcnt) {
            while (defined($line = <$IN>) && ($line =~ /^ *$/)) { }
            if (! defined($line)) { return; }
            for (my $k=0; $k<$klim; $k++) {
                while (defined($line = <$IN>) && ($line =~ /^ *$/)) { }
                if (! defined($line)) { return; }
                @arr = split /\s+/, $line;
                $tavg_vals{$arr[2]} = -1;
            }
        }
    } else {
        # skip till 'tavg fields requested' line
        # get field count
        # skip line starting field list
        while (defined($line = <$IN>) && ! ($line =~ /tavg fields requested/)) {
        }
        @arr = split /\s+/, $line;
        my ($varcnt);
        $varcnt = $arr[3];
        if (! defined($line = <$IN>)) { return; }
        for (my $k=0; $k<$varcnt; $k++) {
            while (defined($line = <$IN>) && ($line =~ /^ *$/)) { }
            if (! defined($line)) { return; }
            @arr = split /\s+/, $line;
            $tavg_vals{$arr[1]} = -1;
        }
    }

    #
    # Manually add QFLUX to table, model does not state
    # that it is being time-averaged.
    #
    $tavg_vals{'QFLUX'} = -1;

    #
    # Manually add Nino Indices to table
    #
    $tavg_vals{'NINO_1_PLUS_2'}  = -1;
    $tavg_vals{'NINO_3'}         = -1;
    $tavg_vals{'NINO_3_POINT_4'} = -1;
    $tavg_vals{'NINO_4'}         = -1;
}

#
# global_att($ncfid, $POPversion, $CCSM_mod_tag, $runid);
# Put in global attributes.
#
sub global_att($$$$) {
    my ($ncfid, $POPversion, $CCSM_mod_tag, $runid) = @_;

    NetCDF::attput($ncfid, NetCDF::GLOBAL, "history", NetCDF::CHAR, "created by $PROGRAM_NAME, $version");
    my $now = localtime();
    NetCDF::attput($ncfid, NetCDF::GLOBAL, "processing_date", NetCDF::CHAR, $now);
    NetCDF::attput($ncfid, NetCDF::GLOBAL, "POPversion", NetCDF::CHAR, $POPversion);
    NetCDF::attput($ncfid, NetCDF::GLOBAL, "CCSM_mod_tag", NetCDF::CHAR, $CCSM_mod_tag);
    NetCDF::attput($ncfid, NetCDF::GLOBAL, "title", NetCDF::CHAR, $runid);
}

#
# def_var($ncfid, $varname, $type, $long_name, $units, @dimids);
# Define a NetCDF variable, first checking to see if it is defined.
#
sub def_var($$$$$$$) {
    my ($ncfid, $varname, $type, $long_name, $units, $scale_factor, @dimids) = @_;

    NetCDF::opts(0);
    my $varid = NetCDF::varid($ncfid, $varname);
    NetCDF::opts(NetCDF::VERBOSE | NetCDF::FATAL);
    if ($varid == -1) {
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
    }
}

#
# proc_diag(INPUT_STREAM, line);
# read & process block of diagnostics
#
sub proc_diag($$) {
    my ($IN, $line) = @_;
    my (@arr, @start, @count);
    my $varid;

    #
    # Get the step number
    #
    my ($step);
    @arr = split /:/, $line; $step = $arr[1];

    #
    # Get the date from the diagnostics header & put in NetCDF file.
    #
    my ($YEAR,$MONTH,$DAY,$HOUR,$MINUTE,$SECOND);
    if (! defined($line = <$IN>)) { return; }
    @arr = split /\s+/, $line;
    if ($arr[1] eq "Date") {
        $DAY    = $arr[3];
        $MONTH  = $monthnum{$arr[4]};
        $YEAR   = $arr[5];
    } else {
        $DAY    = $arr[2];
        $MONTH  = $monthnum{$arr[3]};
        $YEAR   = $arr[4];
    }

    if (! defined($line = <$IN>)) { return; }
    @arr = split /:/, $line; $HOUR   = $arr[1];

    if (! defined($line = <$IN>)) { return; }
    @arr = split /:/, $line; $MINUTE = $arr[1];

    if (! defined($line = <$IN>)) { return; }
    @arr = split /:/, $line; $SECOND = $arr[1];

    my $time = ymdhms2days($YEAR,$MONTH,$DAY,$HOUR,$MINUTE,$SECOND);
    my $time_ind = get_time_ind($time, @diag_time_vals);
    $diag_time_vals[$time_ind] = $time;

    @start = ($time_ind); @count = (1);
    $varid = NetCDF::varid($ncfid_diag, "time");
    NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$time);

    #
    # Put the step number in NetCDF file.
    #
    @start = ($time_ind); @count = (1);
    $varid = NetCDF::varid($ncfid_diag, "step");
    NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$step);

    # Read till timing information.
    my ($tr_name, $val, $level, @aval);
    $#aval = $km - 1;
    while (defined($line = <$IN>) && ! ($line =~ /Timing information/)) {
        $line =~ s/D\+/E+/g;
        $line =~ s/D\-/E-/g;
        if ($line =~ /mean value  of tracer +(\d+)/) {
            $tr_name = $tr_names[$1-1];
            if ($line =~ /at level +1 /) {
                if ($proc_surf) {
                    @arr = split /:/, $line;
                    $val = $arr[1];
                    $varid = NetCDF::varid($ncfid_diag, $tr_name . "_surf");
                    @start = ($time_ind); @count = (1);
                    NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$val);
                }
                if ($proc_levels) {
                    @arr = split /:/, $line;
                    $aval[0] = $arr[1];
                    for ($level = 2; $level <= $km; $level++) {
                        if (! defined($line = <$IN>)) { return; }
                        $line =~ s/D\+/E+/g;
                        $line =~ s/D\-/E-/g;
                        @arr = split /:/, $line;
                        $aval[$level-1] = $arr[1];
                    }
                    $varid = NetCDF::varid($ncfid_diag, $tr_name . "_lev");
                    @start = ($time_ind, 0); @count = (1, $km);
                    NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \@aval);
                } else {
                    for ($level = 2; $level <= $km; $level++) {
                        if (! defined($line = <$IN>)) { return; }
                    }
                }
            } else {
                @arr = split /:/, $line;
                $val = $arr[1];
                $varid = NetCDF::varid($ncfid_diag, $tr_name);
                @start = ($time_ind); @count = (1);
                NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$val);
            }
        } elsif ($line =~ /mean change in tracer +(\d+) +from vert/) {
            $tr_name = $tr_names[$1-1];
            @arr = split /:/, $line;
            $val = $arr[1];
            $varid = NetCDF::varid($ncfid_diag, "delta_" . $tr_name . "_vdiff");
            @start = ($time_ind); @count = (1);
            NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$val);
        } elsif ($line =~ /mean change in tracer +(\d+) +from sources/) {
            $tr_name = $tr_names[$1-1];
            @arr = split /:/, $line;
            $val = $arr[1];
            $varid = NetCDF::varid($ncfid_diag, "delta_" . $tr_name . "_source");
            @start = ($time_ind); @count = (1);
            NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$val);
        } elsif ($line =~ /surface flux of tracer +(\d+) /) {
            $tr_name = $tr_names[$1-1];
            @arr = split /:/, $line;
            $val = $arr[1];
            $varid = NetCDF::varid($ncfid_diag, "sflx_" . $tr_name);
            @start = ($time_ind); @count = (1);
            NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$val);
        } elsif ($line =~ /mean K\.E\./) {
            @arr = split /:/, $line;
            $val = $arr[1];
            $varid = NetCDF::varid($ncfid_diag, "MEAN_KE");
            @start = ($time_ind); @count = (1);
            NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$val);
        } elsif ($line =~ /global mean sea level/) {
            @arr = split /:/, $line;
            $val = $arr[1];
            $varid = NetCDF::varid($ncfid_diag, "MEAN_SSH");
            @start = ($time_ind); @count = (1);
            NetCDF::varput($ncfid_diag, $varid, \@start, \@count, \$val);
        }
    }
}

#
# proc_tavg(INPUT_STREAM, line);
# Read tavg variable values and store into hash table.
# If this is not a restart dump, store the values to the NetCDF file.
#
sub proc_tavg($$) {
    my ($IN, $line) = @_;
    my (@arr) = ();

    # Read tavg variable values and store into hash table.
    $line =~ /.*: (\d*)[ -](\d*)[ -](\d*) (\d*):(\d*):(\d*)/;
    my $time;
    $time = ymdhms2days($3,$1,$2,$4,$5,$6);
    fyi("$time");
    while (defined($line = <$IN>) && ! ($line =~ /file written:/)) {
        $line =~ s/D\+/E+/g;
        $line =~ s/D\-/E-/g;
        @arr = split /[:\s]+/, $line;
        if (defined($arr[1]) && defined($tavg_vals{$arr[1]})) {
            $tavg_vals{$arr[1]} = $arr[2];
        }
    }

    # If this is not a restart dump, store the values to the NetCDF file.
    if (defined($line) && ! ($line =~ /rest/)) {
        my ($tavg_var, $tavg_val, $varid);

        my $time_ind = get_time_ind($time, @tavg_time_vals);
        $tavg_time_vals[$time_ind] = $time;
        my (@start) = ($time_ind); my (@count) = (1);

        $varid = NetCDF::varid($ncfid_tavg, "time");
        NetCDF::varput($ncfid_tavg, $varid, \@start, \@count, \$time);

        #
        # traverse fields in same order that they were defined
        #
        foreach $tavg_var (sort keys %tavg_vals) {
            $tavg_val = $tavg_vals{$tavg_var};
            $varid = NetCDF::varid($ncfid_tavg, $tavg_var);
            NetCDF::varput($ncfid_tavg, $varid, \@start, \@count, \$tavg_val);
        }
    }
}

#
# ymdhms2days(YEAR,MONTH,DAY,HOUR,MINUTE,SECOND);
#
sub ymdhms2days($$$$$$) {
    my ($YEAR,$MONTH,$DAY,$HOUR,$MINUTE,$SECOND) = @_;
    my (@days_start_month) =
        (0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);
    my $days;
    $days = $YEAR * 365 + $days_start_month[$MONTH-1] + ($DAY-1) +
        (($SECOND/60.0 + $MINUTE)/60.0 + $HOUR)/24.0;
    return $days;
}

#
# get_time_ind(time_val, time_val_array);
#
sub get_time_ind($$) {
    my ($time_val, @time_val_array) = @_;

    my $time_ind;
    my $time_len = $#time_val_array;

    for ($time_ind = 0; $time_ind <= $time_len; $time_ind++) {
       if ($time_val_array[$time_ind] == $time_val) {
          last;
       }
    }

    return $time_ind;
}

#
# update_tavg_metadata($CCSM_mod_tag);
#
sub update_tavg_metadata($) {
    my ($CCSM_mod_tag) = @_;

    my ($majorversion) = 0;
    my ($minorversion) = 0;
    my ($betaversion) = 0;
    my ($pop_1_4_version) = 0;

    if ($CCSM_mod_tag =~ /ccsm(\d*)_(\d*)_beta(\d*)/) {
       $majorversion = $1;
       $minorversion = $2;
       $betaversion = $3;
    }  elsif ($CCSM_mod_tag =~ /ccsm_pop_1_4_(\d*)/) {
       $pop_1_4_version = $1;
    }

    if (($majorversion >= 3) || ($minorversion >= 1) || ($betaversion >= 36) || ($pop_1_4_version >= 20020125)) {
       $tavg_metadata{"SFWF"}    = [ "mm/day", 86400.0 ], # convert from kg/m^2/sec
       $tavg_metadata{"RESID_S"} = [ "mm/day", 86400.0 ], # convert from kg/m^2/sec
    }

}

sub postProcess() {
    if ($ncfid_diag != -1) {
        NetCDF::close($ncfid_diag);
    }
    if ($ncfid_tavg != -1) {
        NetCDF::close($ncfid_tavg);
    }
}

# start executing at main()
#
main();
0;              # return 0 (no error from this script)

