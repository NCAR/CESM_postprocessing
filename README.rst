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

* Paper `preprint <https://www.ilamb.org/ILAMB_paper.pdf>`_ which
  details the design and methodology employed in the ILAMB package
* If you find the package or the ouput helpful in your research or
  development efforts, we kindly ask you to cite the following
  reference (DOI:10.18139/ILAMB.v002.00/1251621).

ILAMB 2.3 Release
-----------------

We are pleased to announce version 2.3 of the ILAMB python
package. Among many bugfixes and improvements we highlight these major
changes:

* You may observe a large shift in some score values. In this version
  we solidified our scoring methodology while writing a `paper
  <https://www.ilamb.org/ILAMB_paper.pdf>`_ which necesitated
  reworking some of the scores. For details, see the linked paper.
* Made a memory optimization pass through the analysis routines. Peak
  memory usage and the time at peak was reduced improving performance. 
* Restructured the symbolic manipulation of derived variables to
  greatly reduce the required memory.
* Moved from using cfunits to cf_units. Both are python wrappers
  around the UDUNITS library, but cfunits is stagnant and placed a
  lower limit to the version of the netCDF4 python wrappers we could
  use.
* The scoring of the interannual variability was missed in the port
  from version 1 to 2, we have added the metric.
* The terrestrial water storage anomaly GRACE metric was changed to
  compare mean anomaly values over large river basins. For details see
  the ILAMB paper.


Funding
-------

This research was performed for the *Reducing Uncertainties in Biogeochemical Interactions through Synthesis and Computation* (RUBISCO) Scientific Focus Area, which is sponsored by the Regional and Global Climate Modeling (RGCM) Program in the Climate and Environmental Sciences Division (CESD) of the Biological and Environmental Research (BER) Program in the U.S. Department of Energy Office of Science.
