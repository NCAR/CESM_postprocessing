The ILAMB Benchmarking System
=============================

The International Land Model Benchmarking (ILAMB) project is a
model-data intercomparison and integration project designed to improve
the performance of land models and, in parallel, improve the design of
new measurement campaigns to reduce uncertainties associated with key
land surface processes. Building upon past model evaluation studies,
the goals of ILAMB are to:

* develop internationally accepted benchmarks for land model
  performance, promote the use of these benchmarks by the
  international community for model intercomparison,
* strengthen linkages between experimental, remote sensing, and
  climate modeling communities in the design of new model tests and
  new measurement programs, and
* support the design and development of a new, open source,
  benchmarking software system for use by the international community.

It is the last of these goals to which this repository is
concerned. We have developed a python-based generic benchmarking
system, initially focused on assessing land model performance.
  
Useful Information
------------------

* `Documentation <http://ilamb.ornl.gov/doc/>`_ - installation and
  basic usage tutorials
* Sample Output
  
  * `CLM <http://ilamb.ornl.gov/CLM/>`_ - land comparison against 3 CLM versions and 2 forcings
  * `CMIP5 <http://ilamb.ornl.gov/CMIP5/>`_ - land comparison against a collection of CMIP5 models
  * `IOMB <http://ilamb.ornl.gov/IOMB/>`_ - ocean comparison against a few ocean models
    
* If you find the package or the ouput helpful in your research or
  development efforts, we kindly ask you to cite the following
  reference (DOI:10.18139/ILAMB.v002.00/1251621).

ILAMB 2.2 Release
-----------------

We are pleased to announce version 2.2 of the ILAMB python package. Among many small bugfixes and enhancements, the new version contains the following new features:

* A new installed command ``ilamb-fetch`` has been included which can be run to automatically download the observational datasets. Running this command after the data has been downloaded will check your collection for updates and consistency.
* A new installed command ``ilamb-doctor`` has been included which can be run with options similar to ``ilamb-run`` to help identify which values a particular configure file needs in order to run.
* ILAMB will now check the spatial extents of all the models present in the current run and clip away to the largest shared extent. This allows ILAMB to be applied to regional models.
* User-defined regions can now be added at runtime either by specifying latitude/longitude bounds, or a mask in a netCDF4 file. For specifics, consult the regions `tutorial <http://ilamb.ornl.gov/doc/custom_regions.html>`_.
* Added a runoff and evaporative fraction benchmark to the ILAMB canon, removed the GFED3 and GFED4 burned area data products.
* Added many more plots to the generic output including the RMSE and the score maps.
* The ILAMB core has been enhanced to better handle depths. This has enabled ocean comparisons among others.
* An initial collection of ocean datasets has been assembled in the ``demo/iomb.cfg`` file for ocean benchmarking.
* The plotting phase of ``ilamb-run`` may now be skipped with the ``--skip_plots`` option.
* Relationship overall scores are now available in an image on the main html output page.
* Additional `tutorials <http://ilamb.ornl.gov/doc/>`_ have been added to explain these new features.

Funding
-------

This research was performed for the *Reducing Uncertainties in Biogeochemical Interactions through Synthesis and Computation* (RUBISCO) Scientific Focus Area, which is sponsored by the Regional and Global Climate Modeling (RGCM) Program in the Climate and Environmental Sciences Division (CESD) of the Biological and Environmental Research (BER) Program in the U.S. Department of Energy Office of Science.
