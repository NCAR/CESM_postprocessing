First Steps
===========

This software comes with no data. It is meant to be generic software
which facilitates the automatic confrontation of model results with
benchmark observational datasets. However, the best way to learn how
to use this software is with actual data. To this end we have a
relatively small sample which you can `download
<http://climate.ornl.gov/~ncf/ILAMB/minimal_ILAMB_data.tgz>`_. Extract
this file to a location of your choosing by the following::

  tar -xvf minimal_ILAMB_data.tgz
  cd ILAMB_sample
  export ILAMB_ROOT=$PWD

We use this environment variable in the ILAMB package to point to the
top level directory of the data. Later, when we reference specific
data locations, we can specify them relative to this path. This both
shortens the path and makes the configuration portable to other
systems or data locations.

The following tree represents the organization of the contents of this
sample data::

  ILAMB_sample/
  ├── DATA
  │   ├── albedo
  │   │   └── CERES
  │   │       └── albedo_0.5x0.5.nc
  │   └── rsus
  │       └── CERES
  │           └── rsus_0.5x0.5.nc
  └── MODELS
      └── CLM40cn
          ├── rsds
          │   └── rsds_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
          └── rsus
              └── rsus_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc

There are two main branches in this directory. The first is the
``DATA`` directory--this is where we keep the observational datasets
each in a subdirectory bearing the name of the variable. While not
strictly necesary to follow this form, it is a convenient
convention. The second branch is the ``MODEL`` directory in which we
see a single model result from CLM. 

Configure Files
---------------

Now that we have data, we need to setup a file which the ILAMB package
will use to initiate a benchmark study. There is such a file which
comes with the software package in the ``demo`` directory called
``sample.cfg``. Navigate to the demo directory and open this file or view it `online
<https://bitbucket.org/ncollier/ilamb/src/79a261c2fc832dbe9b736cf8edcf8b941bea341b/demo/sample.cfg?at=master&fileviewer=file-view-default>`_. We also reproduce it here for the purpose of this tutorial::

  # This configure file specifies the variables 

  [h1: Radiation and Energy Cycle]
  bgcolor  = "#FFECE6"              

  [h2: Surface Upward SW Radiation]
  variable = "rsus"

  [CERES]
  source   = "DATA/rsus/CERES/rsus_0.5x0.5.nc"

  [h2: Albedo]
  variable = "albedo"
  derived  = "rsus/rsds"            

  [CERES]
  source   = "DATA/albedo/CERES/albedo_0.5x0.5.nc"

We note that while the ILAMB package is written in python, this file
contains no python and is written in a small configure language of our
invention. Here we will go over this file line by line and explain how
each entry functions.

At the top of the file, you see the following lines::

  [h1: Radiation and Energy Cycle]
  bgcolor = "#FFECE6"

This is a tag that we use to tell the system that we will have a top
level heading ``h1`` which we call *Radiation and Energy Cycle*. While
you can name this section anything of your choosing, we have chosen
this name as it is descriptive of the benchmarking activities we will
perform. Also note that you may specify a background color here in
hexadecimal format (we found this site to be helpful to play around
with `colors <http://www.colorpicker.com/ffece6>`_). This color will
be used in the output which we will show later. It is important to
understand that heading are hierarchical--this heading owns everything
underneath it until the next ``h1`` tag is found or the file ends. We
use ``h1`` level headings to group variables of a given type to better
organize the output.

Below this, you will notice a second level heading which appears like
this::

  [h2: Surface Upward SW Radiation]
  variable = "rsus"

We will be looking at radiation here. The ``variable`` tag is the name
of the variable inside the dataset which represents the variable of
interest. Here ``rsus`` is a standard name used to represent
*Surface Upward Shortwave Radiation*. We use ``h2`` headings to
represent a variable which we wish to compare.

The next entry in the file appears as the following::

  [CERES]
  source   = "DATA/rsus/CERES/rsus_0.5x0.5.nc"

First, notice the absence of a ``h1`` or ``h2`` tag. This indicates
that this entry is a particular dataset of a given variable (our
``h2`` heading) of a given grouping (our ``h1`` heading). We have
named it CERES as that is the name of the data source we have
included. We only have to specify the location of the source dataset,
relative to the environment variable we set earlier, ``ILAMB_ROOT``.

At this point we feel it important to mention that this is the minimum
required to setup a benchmark study in this system. If you have an
observational dataset which directly maps to a variable which is
output by models as ``rsus`` is, you are done.

However, it is possible that your dataset has no direct analog in the
list of variables which models output and some manipulation is
needed. We have support for when your dataset corresponds to an
algebraic function of model variables. Consider the remaining entries
in our sample::

  [h2: Albedo]
  variable = "albedo"
  derived  = "rsus/rsds"            

  [CERES]
  source   = "DATA/albedo/CERES/albedo_0.5x0.5.nc"

We have done two things here. First we started a new ``h2`` heading
because we will now look at albedo. But albedo is not a variable which
is included in our list of model outputs (see the tree above). However
we have both upward and downward radiation, so we could compute
albedo. This is accomplished by adding the ``derived`` tag and
specifying the algebraic relationship. When our ILAMB system looks for
the albedo variable for a given model and cannot find it, it will try
to find the variables which are the arguments of the expression you
type in the ``derived`` tag. It will then combined them automatically
and resolve unit differences.

The configuration language is small, but allows you to change a lot of
the behavior of the system. The full functionality is documented `here
<nope_not_yet>`_. Non-algebraic manipulations are also possible, but
will be covered in a more advanced tutorial.

Running the Study
-----------------

Now that we have the configuration file set up, you can run the study
using the ``ilamb-run`` script. Executing the command::

  ilamb-run --config sample.cfg --model_root $ILAMB_ROOT/MODELS/ --regions global

If you are on some institutional resource, you may need to launch the
above command using a submission script, or request an interactive
node. As the script runs, it will yield output which resembles the
following::

  Searching for model results in /Users/ncf/sandbox/ILAMB_sample/MODELS/
  
                                            CLM40cn
  
  Parsing config file sample.cfg...
  
                     SurfaceUpwardSWRadiation/CERES Initialized
                                       Albedo/CERES Initialized
  
  Running model-confrontation pairs...
  
                     SurfaceUpwardSWRadiation/CERES CLM40cn              Completed  37.3 s
                                       Albedo/CERES CLM40cn              Completed  44.7 s
  
  Finishing post-processing which requires collectives...
  
                     SurfaceUpwardSWRadiation/CERES CLM40cn              Completed   3.3 s
                                       Albedo/CERES CLM40cn              Completed   3.3 s

  Completed in  91.8 s

What happened here? First, the script looks for model results in the
directory you specified in the ``--model_root`` option. It will treat
each subdirectory of the specified directory as a separate model
result. Here since we only have one such directory, ``CLM40cn``, it
found that and set it up as a model in the system. Next it parsed the
configure file we examined earlier. We see that it found the CERES
data source for both variables as we specified it. If the source data
was not found or some other problem was encountered, the green
``Initialized`` will appear as red text which explains what the
problem was (most likely ``MisplacedData``). If you encounter this
error, make sure that ``ILAMB_ROOT`` is set correctly and that the
data really is in the paths you specified in the configure file.

Next we ran all model-confrontation pairs. In our parlance, a
*confrontation* is a benchmark observational dataset and its
accompanying analsys. We have two confrontations specified in our
configure file and one model, so we have two entries here. If the
analysis completed without error, you will see a green ``Completed``
text appear along with the runtime. Here we see that ``albedo`` took a
few seconds longer than ``rsus``, presumably because we had the
additional burden of reading in two datasets and combining them.

The next stage is the post-processing. This is done as a separate loop
to exploit some parallelism. All the work in a model-confrontation
pair is purely local to the pair. Yet plotting results on the same
scale implies that we know the maxmimum and minimum values from all
models and thus requires the communcation of this information. Here,
as we are plotting only over the globe and not extra regions, the
plotting occurs quickly.

Viewing the Output
------------------

The whole process generated a new directory of results in the demo
dorectory called ``_build``. To browse the results, open the
``_build/index.html`` file in any browser and you will see a webpage
with a summary image in the center. As we have so few variables and
models, this image will not make much sense at this point. Instead,
click the middle tab called ``Results Table``. From here you will see
both variables which we compared. Clicking on eithe will expand the
row to show the data sources which were part of the study. If you
further click on the CERES link in any row, it will take you to the
plots and tabulated information from the study.


