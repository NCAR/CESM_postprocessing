Adding a Model
==============

The following tutorial builds on the `previous <./first_steps.html>`_
by describing how another model's results may be added to the
benchmarking results for CLM40cn. At this point, we suggest that you
try to incoporate model result data of your own. At a minimum you will
need to have the ``rsus`` and ``rsds`` variables expressed as monthly
mean values at least partially over the time period of the source data
(2000-2012). In the event you do not have model data of your own, this
tutorial will copy the CLM40cn results data and treat it as another
model as a demonstration only.

The main concept you need to understand is how ``ilamb-run`` finds and
classifies model results. When executing ``ilamb-run`` in the previous
tutorial, we specified an option ``--model_root
$ILAMB_ROOT/MODELS/``. This tells the script where to look for model
results. The script will consider each subdirectory of the specified
directory as a separate model result. So for example, if we copy the
CLM40cn results into a new directory represented in the following
tree::

  ./MODELS
  ├── CLM40cn
  │   ├── rsds
  │   │   └── rsds_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
  │   └── rsus
  │       └── rsus_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
  └── CLMCopy
      ├── rsds
      │   └── rsds_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
      └── rsus
          └── rsus_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
	  
Then when we execute the same ``ilamb-run`` command as before::

  ilamb-run --config sample.cfg --model_root $ILAMB_ROOT/MODELS/ --regions global

We observe that the new model is indeed found and the confrontations
are run. Here we reproduce the screen output::

  Searching for model results in /home/ncf/sandbox/ILAMB_sample/MODELS/

                                          CLM40cn
                                          CLMCopy
  
  Parsing config file sample.cfg...

                     SurfaceUpwardSWRadiation/CERES Initialized
                                       Albedo/CERES Initialized

  Running model-confrontation pairs...

                     SurfaceUpwardSWRadiation/CERES CLM40cn              UsingCachedData 
                     SurfaceUpwardSWRadiation/CERES CLMCopy              Completed  38.4 s
                                       Albedo/CERES CLM40cn              UsingCachedData 
                                       Albedo/CERES CLMCopy              Completed  39.9 s

  Finishing post-processing which requires collectives...

                     SurfaceUpwardSWRadiation/CERES CLM40cn              Completed   3.8 s
                     SurfaceUpwardSWRadiation/CERES CLMCopy              Completed   3.0 s
                                       Albedo/CERES CLM40cn              Completed   3.9 s
                                       Albedo/CERES CLMCopy              Completed   3.8 s

  Completed in 92.8 s

You will notice that on executing the run script again, we did not have to
perform the analysis step for the model we ran in the previous
tutorial. When a model-confrontation pair is run, we save the analysis
information in a netCDF4 file. If this file is detected in the setup
process, then we will use the results from the file and skip the
analysis step. The plotting, however, is repeated. This is because
adding extra models will possible change the limits on the plots and
thus must be rendered again.

You have a great deal of flexibility as to how results are saved. That
is, they need not exist in separate files within subdirectories
bearing the name of the variable which they represent. We could, for
example, move the sample data around in the following way::
  
  ./MODELS
  ├── CLM40cn
  │   ├── rsds
  │   │   └── rsds_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
  │   └── rsus
  │       └── rsus_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
  └── CLMCopy
      └── rsds_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
      └── rsus_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc

and the run script will interpret the model in exactly the same
manner. The variables can even be in the same file or across multiple
files representing different sections of the simulation time. We will
detect which variables are in which files, and combine them
automatically. The only real requirement is that all the files be
located under a directory bearing the model's name. This directory
could even be a symbolic link. On my personal machine, I have data
from a CLM45bgc run saved. So I can create a symbolic link from my
``MODELS`` directory to the location on my local machine::

  ./MODELS
  ├── CLM40cn
  │   ├── rsds
  │   │   └── rsds_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
  │   └── rsus
  │       └── rsus_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
  ├── CLM45bgc -> /work/ILAMB/MODELS/CLM/CLM45bgc/
  └── CLMCopy
      └── rsds_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc
      └── rsus_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc

and the run script will follow this link and perform the analysis on the
result files it finds there. This allows you to create a group of
models which you wish to study without having to move results around
your machine.

