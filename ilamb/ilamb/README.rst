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

ILAMB 2.1 Release
-----------------

We are pleased to announce version 2.1 of the ILAMB python package,
with the following new features:

* Revamped treatment of relationships. Relationship plots now also
  include a difference plot of the distributions as well as a
  representation of the mean relationship function. We have moved the
  relationships to their own tab in the dataset HTML pages and given
  them their own scores. The first is based on the Hellinger distance,
  which quantifies the difference between the model and data
  distributions. The second is a RMSE score used to quantify the
  similarity of the model and observation mean relationship
  curves. This revamp also removed unneeded recomputation, speeding up
  the entire ILAMB run by 25%.
* Logfiles are now generated when ILAMB is run. They contain more
  information about the python packages used, the amount of time spent
  on each process, and more debugging information when errors are
  encountered. Look for files with the ``.log`` suffix in the
  ``_build`` directory after ILAMB is run.
* We have removed ``demo/driver.py`` and added an executable version
  ``ilamb-run``. When you install the ILAMB package, this new script
  will be added to your ``bin`` directory. This allows you to run the
  ILAMB package anywhere without needing to copy the driver. Thanks to
  Mark Piper for this contribution.
* We have added an option to the ``ilamb-run`` script which allows
  users to shift the time representation in the model results. This is
  helpful during model development to compare model results to the
  ILAMB suite without needing to fully spin up the model. The option
  syntax is ``--model_year y0 yf`` which will make the year ``y0`` in
  the models equal to ``yf``, shifting all times by ``yf-y0`` years.
* The ``ILAMB.Variable`` object now has support for layered data,
  including a new member function ``integrateInDepth``.
* Improved calendar conversion capability, enabling the use of models
  with calendars other than ``noleap``.
* All plots now color land areas in a light grey, and oceans with a
  darker grey. Plots over the globe will be in the Robinson projection
  for both globally gridded data as well as sites. Regional plots now
  mask out areas not in the region and will be in the cylindrical
  projection.
* ILAMB is now listed in the `Python Package Index
  <https://pypi.python.org/pypi>`_ and can now be installed using
  ``pip``. The installation tutorial has been rewritten to reflect
  this change as well as adapted based on user feedback to be more
  helpful.
* Numerous bugfixes, many cosmetic, but a few substantive fixes include:
  
  * Moved to using the ``with`` statement for handling the opening of
    files. This ensures that files always close, even when errors are
    thrown.
  * Fixed a bug which caused intermittent inconsistencies when running
    in parallel. This would cause the scores for some models/variables
    to appear as Nans, despite the fact that the analysis was run.
  * Fixed a bug relating to the computation of RMSE scores. Scores
    were too low relative to ILAMB v1 because the wrong normalizer was
    being used. Thanks to Alberto Martinez-de la Torre for this patch.
  * Fixed code which triggers depracation warnings from numpy and
    matplotlib.
  

  
Useful Information
------------------

* `Documentation
  <http://climate.ornl.gov/~ncf/ILAMB/docs/index.html>`_ of the public
  API is included in the repository, but also hosted if you follow the
  link.
* `Sample output
  <http://www.climatemodeling.org/~nate/ILAMB/index.html>`_ gives you
  an idea of the scope and magnitude of the package capabilities.
* You may cite the software package by using the following reference (DOI:10.18139/ILAMB.v002.00/1251621).

Funding
-------

This research was performed for the Biogeochemistry--Climate Feedbacks
Scientific Focus Area, which is sponsored by the Regional and Global
Climate Modeling (RGCM) Program in the Climate and Environmental
Sciences Division (CESD) of the Biological and Environmental Research
(BER) Program in the U.S. Department of Energy Office of Science.
