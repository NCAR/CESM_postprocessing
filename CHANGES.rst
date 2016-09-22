PyReshaper Change Log
=====================

Copyright 2015, University Corporation for Atmospheric Research
See the LICENSE.rst file for details

VERSION 0.9.0
-------------

9 Jun 2014:
 - Initial release.  (Previously in prototype repo.)

1 Jul 2014:
 - Improvements to the Yellowstone testing scripts

2 Jul 2014:
 - Added new UCAR license agreement


VERSION 0.9.1
-------------
  
4 Aug 2014:
 - Added many new helper tools in the Yellowstone testing directory.
 
18 Aug 2014:
 - Perform a sort of the time-series variables by size before partitioning
   them across processors.  Since the partition strides through the list of
   variables names, by sorting the variables by size first, we do a reasonable
   job of selecting as many small variables as large on every processor

28 Aug 2014:
 - A few minor typo bugfixes.
 
1 Sep 2014:
 - Added the ability to output all metadata to a "once" file.  This metadata
   includes ALL variables that are NOT the time-series variables being written
   to file.  Hence, this can produce time-series files that are not entirely
   self-describing.

3 Sep 2014:
 - Fixed a bug in which a job hangs when using more ranks than variables

10 Sep 2014:
 - Switched to using the identified 'unlimited' dimension name instead of
   explicitly using the string 'time'.

11 Sep 2014:
 - Added the ability to process time-slice files with multiple time steps
   in each slice file. 
 - Added new plotting utility and module.  Some changes to the getsizes
   utility in the Yellowstone testing area.  Some more tweaks here, too.
  
4 March 2015:
 - Updated the PyReshaper to use the newly created PyTools/trunk.  (Will
   modify the externals to use a tag once the new PyTools has been tested and
   verified).
 - Renamed any ATM/LND 0.1 degree tests in the tests/yellowstone directory to 
   0.25 degree, which they actually are.  Similarly, any 0.25 degree OCN/ICE
   tests were named 0.1 degree.
  
16 March 2015:
 - Updated the Specifier and Reshaper Doxygen comments to use Doxypypy
   formatting.
  
VERSION 0.9.2
-------------

26 March 2015:
 - Tagging new branch for version 0.9.2 release.
 
10 June 2015:
 - Restructured source tree
 - Installation of LICENSE file with package
 - Updates for upload to PyPI

VERSION 0.9.3
-------------

10 June 2015:
 - Bugfix: Now installs properly from PyPI
 
VERSION 0.9.4
-------------

29 June 2015:
 - Newly automated versioning information
 
1 October 2015:
 - Bugfixes, performance improvements
 - New yellowstone testing code

2 October 2015:
 - Now measures read/write times separately in diagnostic data
 - Performance improvement (no explicit loop over time-steps in a time-slice
   file needed)
 - Enabling user-defined compression level for NetCDF4 output
 
VERSION 0.9.5
-------------

6 October 2015:
 - Fix bug in the 'slice2series' script
 - Adds a write to file option for the Specifiers
 - Modifying output message verbosity settings
   
VERSION 0.9.6
-------------

7 October 2015:
 - Split 'slice2series' script into 2 separate scripts: 's2smake' to generate
   specifier object files (specfiles), and 's2srun' to run a reshaper job
   with a given specifier object file
 - Now uses 'write mode' to determing if overwriting output files or skipping
   existing output files
   
12 October 2015:
 - Added capability to append to existing output files
 
VERSION 0.9.10
--------------

7 March 2016:
 - Python 2.6 back-porting

 