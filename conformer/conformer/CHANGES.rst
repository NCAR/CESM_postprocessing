PyConform ChangeLog
===================

Copyright 2017, University Corporation for Atmospheric Research
See the LICENSE.rst file for details

VERSION 0.0.1
-------------
 - Add date check/mapping ability.
 - Added initial CESM to CMIP6 JSON tables to the examples directory.
 - Added the code within examples/CESM/CMIP6/src used to generate these tables.
 - Added initial CESM to CMIP5 JSON tables to examples directory
 - Add initial version of mip_table_parser.py.
 - Add initial versions of climIO.py and its unit test.
 - Working repository created.  Template in place.

VERSION 0.1.0
-------------
 - Pre-release of Version 0.1.0
 - Many improvements and features
 - Demo with CMIP5 Amon table with the b40.rcp4_5-1deg.006 experiment data

VERSION 0.2.0
-------------
 - Major refactor of the graph data structure and dependent objects
 - Includes allowances for 'chunking' (serialization) of the data
 - Uses the SimpleComm interface for parallelism
 - Many other improvements and simplifications

VERSION 0.2.1
-------------
 - Automatic interpretation of "direction" attribute in coordinate variables
 - Simplified PhysArray API
 - More powerful Dataset Descriptors

VERSION 0.2.2
-------------
 - New user-defined function API
 