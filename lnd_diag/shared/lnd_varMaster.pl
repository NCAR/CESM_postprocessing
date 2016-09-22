#!/usr/bin/perl

# written by Nan Rosenbloom
# February 2006
# Usage:  called by /code/lnd_driver.csh to dynamically generate
# variable_master_Use.ncl

# --------------------------------
# get environment variables

  $var_master_cn   = 'variable_master4.3.ncl';
  $var_master_casa = 'variable_master_CASA.ncl';

# --------------------------------
# define files 
# --------------------------------

  # master variable list contains all variable definitions
  $cn   = $var_master_cn;
  $casa = $var_master_casa;
  $ofile = "variable_master_cn_casa.ncl";

  $flag = 0;

# --------------------------------
#  start main loop 
# --------------------------------

  	close(fp_cn);
  	open(fp_cn,"<"."$cn")     || die "lnd_varMaster.pl: varCan't open CN input file ($cn) \n";
  	close(fp_casa);
  	open(fp_casa,"<"."$casa") || die "lnd_varMaster.pl: Can't open CASA input file ($casa) \n";

  	close(fp_out);
  	open(fp_out,">"."$ofile") || die "lnd_varMaster.pl: Can't open main output file ($ofile) \n";

	while(<fp_cn>)
	{
		if (/info+(.*)/ && /False+(.*)/ && !/\@+(.*)/) { last; }
		else					       { printf( fp_out "$_"); }


	}
	while(<fp_casa>)
	{
		if (/info+(.*)/ && /True+(.*)/ && !/\@+(.*)/) { $_=<fp_casa>; $flag++; }
		if ($flag) { printf( fp_out "$_"); }
	}

	close(fp_out);
	close(fp_cn);
	close(fp_casa);
