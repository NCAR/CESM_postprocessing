Obtaining the ILAMB Data with ``ilamb-fetch``
=============================================

In previous tutorials we provided links to download a small dataset
for the purposes of demonstration. However we have another mechanism
for downloading the observational datasets which ILAMB needs. From a
commandline prompt, run ``ilamb-fetch``. You should see output similar
to the following::

  Comparing remote location:
 
  	http://ilamb.ornl.gov/ILAMB-Data/

  To local location:

  	./

  I found the following files which are missing, out of date, or corrupt:

	.//DATA/twsa/GRACE/twsa_0.5x0.5.nc
	.//DATA/rlus/CERES/rlus_0.5x0.5.nc
	...

  Download replacements? [y/n]

This tool looks at a remote location (by default the location of the
land datasets) and compares it to a local location (by defult
``ILAMB_ROOT`` or ``./``). It detects for the presence and version of
the data on your local machine and populates a list for download. The
tool will then prompt you to rerun to check for file validity.

This tool can be used to download other data collections as well. If
you need the ocean IOMB data, then you can change the remote location
by running::

  ilamb-fetch --remote_root http://ilamb.ornl.gov/IOMB-Data/

