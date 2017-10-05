Controlling the Analysis with ``ilamb-run`` Options
===================================================

While the basic operation of ``ilamb-run`` is covered in previous
tutorials, there are more options which can be used to control what
happens in a run. In this tutorial we will describe these options and
motivate when they are useful.

Limiting the analysis
---------------------

The configure file specifies the confrontations which will be
performed. However, for many reasons in the development and debugging
process it may be advantageous to run ILAMB on only a subset of the
configure file. You can control this by specifying strings which must
be in the confrontation longname. For example, consider the following
arguments::

  ilamb-run --config ilamb.cfg --model_root ${ILAMB_ROOT}/MODELS --confrontation CERES

This line will run only the CERES confrontations found in the
``ilamb.cfg``. The same can be achieved for models with the
``--models`` option. In this case, you must specify the model names
which you wish to run against in a given run.

To see how this is useful, imagine you have 3 models in your
``--model_root`` directory, but for one you needed to replace all the
model result files. So you need to rerun ILAMB, but not on all three
models. With this option, you can rerun ILAMB on just the needed
model, saving time. If this model name is ``modelC``, then the option
would be::

  ilamb-run --config ilamb.cfg --model_root ${ILAMB_ROOT}/MODELS --models modelC --clean

The ``--clean`` option here tells ILAMB to rerun the analysis even if
intermediate files are present, essentially cleaning out the
``modelC`` ILAMB contents and recomputing them, while leaving the rest
of the models untouched.

Defining models
---------------

There are two ways to define models for an analysis. The first was
covered in previous tutorials. The ``--model_root`` option is used to
specify a location whose subdirectories (not recursive) are
initialized as separate models. This is the recommended method as it
is simple and fast.

One issue that comes up is that model developers want to run ILAMB,
but during the development process as a sanity check on the model
performance. This means that model results may not be available in the
contemporary period. The ``--model_year`` option can be used to shift
the time of all models in an analysis by a fixed number of years. So
if a model run starts in 1850, but you wish to treat these results as
if they were the year 2000 (for comparing to some dataset), then the
appropriate command is ``--model_year 1850 2000``.

While helplful, we also acknowledge that globally applying a shift in
time across all models might not be desirable. It is likely that a
user has cached the results from previous versions of the model which
have been spun up and run over the contemporary period. To this end we
provide a more detailed model setup option ``--model_setup
file.txt``. The contents of ``file.txt`` could look something like the
following::

  # Model Name, Location of Files     , Shift From, Shift To
  CLM40       , ABSOLUTE/PATH/TO/CLM40
  CLM45       , ABSOLUTE/PATH/TO/CLM45
  CLM5X       , ABSOLUTE/PATH/TO/CLM5X, 1850      , 2000
  CLM5Y       , ABSOLUTE/PATH/TO/CLM5Y, 1850      , 2000

The text file is in simple comma delimited form with either 2 or 4
columns. Lines which begin with ``#`` will be ignored. The first
column is the name which you wish to assign to the model and the
second is the absolute path of the results. The third and fourth
columns define the shift in years for each model. If there are only
two columns of data, we will not apply a shift.

To add some context, this option may be useful in the model
development process. In our sample setup, we have two model versions
CLM4 and CLM4.5 whose results are archived and will not be changing
and thus do not need time shifted. We have setup two versions of CLM5,
X and Y which represent perhaps different parameterization choices,
shifted because we have not spun these models up. The ILAMB results
should be interpretted carefully, but comparing two parameterizations
in this way might provide insight into key differences.

Regions
-------

The ILAMB analysis can be performed on an arbitrary number of regions
which may be defined in many ways. The ILAMB package comes with a set
of these regions predefined which are used in the `Global Fire
Emissions Database <http://www.globalfiredata.org/>`_. They are:

    * bona, Boreal North America
    * tena, Temperate North America
    * ceam, Central America
    * nhsa, Northern Hemisphere South America
    * shsa, Southern Hemisphere South America
    * euro, Europe
    * mide, Middle East
    * nhaf, Northern Hemisphere Africa
    * shaf, Southern Hemisphere Africa
    * boas, Boreal Asia
    * ceas, Central Asia
    * seas, Southeast Asia
    * eqas, Equatorial Asia
    * aust, Australia

The first entry in the above list is a region label. To avoid
confusion these should not have spaces or special characters. The
second entry is the name itself which will appear in the pull down
menus on the webpage otput. To run the ilamb analysis over particular
regions, use the ``--regions`` option and include the region labels
delimited by spaces.

As we anticipate that users will desire to define their own regions,
we have provided this capability in two forms. The first is region
definition by latitude and longitude bounds which can be done in the
form of a text file in the following comma delimited format::

  #label,name       ,lat_min,lat_max,lon_min,lon_max
  usa,Continental US,     24,     50,   -126,    -66

Additional rows in the same format may be included to define more
regions in the same file. The first column is the label to be used,
followed by the region name. Then the minimum and maximum bounds on
the latitude and longitude are specified. Note that longitude values
are expected on the [-180,180] interval. In this current iteration
regions cannot be specified which span the international dateline.

The second form is by creating a mask using a netCDF4 file. We will go
into more detail about the format of the netCDF4 file for defining
masks in its own `tutorial <./custom_regions.html>`_. So if the sample
text file above is called ``regions.txt`` and we have a netCDF4 file
called ``amazon.nc`` with a region label ``amazon``, then the ILAMB
analysis can be performed over additional regions by specifying::

  --define_regions regions.txt amazon.nc --regions global usa amazon

In its current form, ILAMB expects that the analysis will be performed
over at least the global region. All overall scores are based on
information in that region. This is a restriction we are working to
loosen. If you need to circumvent this, you can redefine the region
labeled ``global`` to meet your needs.


Other options
-------------

* ``--filter``, Sometimes a model has output from several runs or
  experiments included in the same location. This is frequently
  indicated by some string in the filename, such as ``r0i0p0``. This
  option may be used to require that files contain a specific string
  to be considered in the list of variables models provide.
* ``--skip_plots``, The plotting phase of ILAMB is expensive. It
  takes a long time to generate all the thousands of graphics that get
  produced. It may be that you are running ILAMB for the summary
  graphic/information only. In this case you can run with this option
  to speed up the run.
* ``--build_dir``, The default location for generating the ILAMB
  output is a ``_build`` directory placed in the directory from which
  you ran ``ilamb-run``. While fine for everyday use, you may wish to
  control the location of this directory.
* ``--disable_logging``, ILAMB uses a MPI logger to write exceptions
  and progress to a log file in a thread-lock fashion. This helps
  tremendously when tracking down user errors. However, we have found
  that on some systems (e.g. geysey at NCAR) this causes ``ilamb-run`` to
  lock for reasons we do not yet understand. Disabling the logging
  seems to circumvent the issue. If you find that ``ilamb-run`` makes
  no progress when running in parallel, you might try this option.
* ``--quiet``, By default, ILAMB spits out progress information to
  the screen. If you wish to supress this information, run with this
  option.
  

