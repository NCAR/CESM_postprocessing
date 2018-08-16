Adding a Benchmark Dataset
==========================

The following tutorial builds on the *First Steps* `tutorial
<./first_steps.html>`_ by describing how additional datasets may be
added to our sample benchmark comparison. We will add a Surface Upward
Shortwave Radiation dataset from the the central archive of the
Baseline Surface Radiation Network (BSRN) on the World Radiation
Monitoring Center (WRMC). We have provided a file in the appropriate
format `here <http://climate.ornl.gov/~ncf/ILAMB/rsus.nc>`_. We
suggest that you create a directory inside the ``rsus`` directory
called ``WRMC.BSRN`` and place the downloaded file inside. We will
show the appropriate part of the tree here::

  DATA/
  ├── albedo
  │   └── CERES
  │       └── albedo_0.5x0.5.nc
  └── rsus
      ├── CERES
      │   └── rsus_0.5x0.5.nc
      └── WRMC.BSRN
          └── rsus.nc
  
To add this dataset to our benchmarks, we only need to add a new line
to ``sample.cfg`` under the ``h2`` heading which corresponds to
Surface Upward Shortwave Radiation. Here we show only the portion of
the configure file which pertains to this variable with the new
dataset addition::

  [h2: Surface Upward SW Radiation]
  variable = "rsus"

  [CERES]
  source   = "DATA/rsus/CERES/rsus_0.5x0.5.nc"

  [WRMC.BSRN]
  source   = "DATA/rsus/WRMC.BSRN/rsus.nc"

Now if we execute the ``ilamb-run`` script as before::

  ilamb-run --config sample.cfg --model_root $ILAMB_ROOT/MODELS/ --regions global

we will see the following output to the screen::
  
  Searching for model results in /home/ncf/sandbox/ILAMB_sample//MODELS/

                                            CLM40cn

  Parsing config file sample.cfg...

                     SurfaceUpwardSWRadiation/CERES Initialized
                 SurfaceUpwardSWRadiation/WRMC.BSRN Initialized
                                       Albedo/CERES Initialized

  Running model-confrontation pairs...

                     SurfaceUpwardSWRadiation/CERES CLM40cn              UsingCachedData 
                 SurfaceUpwardSWRadiation/WRMC.BSRN CLM40cn              Completed   1.0 s
                                       Albedo/CERES CLM40cn              UsingCachedData 

  Finishing post-processing which requires collectives...

                     SurfaceUpwardSWRadiation/CERES CLM40cn              Completed   6.4 s
                 SurfaceUpwardSWRadiation/WRMC.BSRN CLM40cn              Completed   6.3 s
                                       Albedo/CERES CLM40cn              Completed   6.8 s

  Completed in  29.0 s

You will notice that on running the script again, we did not have to
perform the analysis step for the confrontations we ran
previously. When a model-confrontation pair is run, we save the
analysis information in a netCDF4 file. If this file is detected in
the setup process, then we will use the results from the file and skip
the analysis step. The plotting, however, is repeated.

You will also notice that the new ``rsus`` dataset we added ran much
more quickly than the CERES dataset. This is because the new dataset
is only defined at 55 specific sites as opposed to the whole globe at
half degree resolution. Despite the difference in these datasets, the
interface into the system (that is, the configuration file entry) is
the same. This represents an element of our design philosophy--the
benchmark datasets should contain sufficient information so that the
appropriate commensurate information from the model may be
extracted. When we open the ``WRMC.BSRN`` dataset, we detect that the
desired variable is defined over datasites. From this we can then
automatically sample the model results, extracting information from
the appropriate gridcells.

Weighting Datasets
------------------

To view the results of the new dataset, look inside the ``_build``
directory and open a file called ``index.html`` in your favorite web
browser. You should see a webpage entitled *ILAMB Benchmark Results*
and a series of three tabs, the middle of which is entitled *Results
Table*. If you click on the row of the table which bears the name
*Surface Upward SW Radiation* you will see that the row expands to
reveal how individual datasets contributed to the overall score for
this variable. Here we reproduce this portion of the table.

===========================  =======
Dataset                      CLM40cn
===========================  =======			     
Surface Upward SW Radiation  0.77	
   CERES (50.0%)             0.79	
   WRMC.BSRN (50.0%)         0.74
===========================  =======

The values you get for scores may vary from this table as our scoring
methodology is in flux as we develop and hone it. The main point here
is that we have weighted each dataset equally, as seen in the
percentages listed after each dataset name. While this is a reasonable
default, it is unlikely as you add datasets that you will have equal
confidence in their quality. To address this, we provide you with a
method of weighting datasets in the configuration file. For the sake
of demonstration, let us assume that we are five times as confident in
the CERES data. This we can express by modifying the relevant section
of the configuration file::

  [h2: Surface Upward SW Radiation]
  variable = "rsus"

  [CERES]
  source   = "DATA/rsus/CERES/rsus_0.5x0.5.nc"
  weight   = 5

  [WRMC.BSRN]
  source   = "DATA/rsus/WRMC.BSRN/rsus.nc"
  weight   = 1

and then running the script as before. This will run quickly as we do
not require a reanalysis for a mere change of weights. Once the run is
complete, open again or reload ``_build/index.html`` and navigate to
the same section of the results table. You should see the change in
weight reflected in the percentages as well as in the overall score
for the variable.

===========================  =======
Dataset                      CLM40cn
===========================  =======			     
Surface Upward SW Radiation  0.78	
   CERES (83.3%)             0.79	
   WRMC.BSRN (16.7%)         0.74
===========================  =======

You may notice that if you apply the weighting by hand based on the
output printed in the table, that you appear to get a different
result. This is because the HTML table output is rounded for display
purposes, but the scores are computed and weighted in full precision.
