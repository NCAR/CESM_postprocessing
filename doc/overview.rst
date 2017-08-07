Package Overview
================

This tutorial is meant to provide some basic understanding of how the
ILAMB python package works and is organized. The level of information
communicated is aimed at a developer who wants to implement his own
benchmark into the system and needs to understand how to go about
doing so. We will start here with a few simple examples which
demonstrate functionality, and layer in complexity in subsequent
tutorials.

The ILAMB python package consists of four main objects: ``Variable``,
``ModelResult``, ``Confrontation``, and ``Scoreboard``. We will
discuss the first three in this tutorial.

The Variable Object
-------------------

The ``Variable`` object is the basic building block of the ILAMB
package. It keeps track of dimensions as the netCDF variables do, but
also provides data-aware analysis routines which operate on the data
in an intelligent manner. For example, consider the following variable
we can create from the data used in a `previous <./first_steps.html>`_
tutorial::

  from ILAMB.Variable import Variable
  import os
  v = Variable(filename = os.environ["ILAMB_ROOT"] + "/MODELS/CLM40cn/rsus/rsus_Amon_CLM40cn_historical_r1i1p1_185001-201012.nc",
               variable_name = "rsus")

The first two lines here import the functionality we need. The first
imports the ``Variable`` object from the ILAMB package and the second
imports a standard python package which allows us to interact with the
operating system. We need this package to gain access to the
``ILAMB_ROOT`` environment variable explained in the `First Steps
<./first_steps.html>`_ tutorial. Then we create a variable object by
specifying the filename as well as the name of the variable which want
to extract from inside. We can then print this variable::

  print v

which will display the following information to the screen::
  
  Variable: rsus
  --------------
                unit: W m-2
          isTemporal: True (1932)
           isSpatial: True (192,288)
          nDatasites: N/A
           dataShape: (1932, 192, 288)
             dataMax: 4.028994e+02
             dataMin: 0.000000e+00
            dataMean: 6.153053e+01

The ``Variable`` object understands the dimensionality of the data as
well as its unit and then provides analysis routines which operate
intelligently depending on the type of data present. So for example,
we can find the mean value over the time period of the data by::

  print v.integrateInTime(mean=True)

which will display::
  
  Variable: rsus_integrated_over_time_and_divided_by_time_period
  --------------------------------------------------------------
                unit: W m-2
          isTemporal: False
           isSpatial: True (192,288)
          nDatasites: N/A
           dataShape: (192, 288)
             dataMax: 1.386898e+02
             dataMin: 9.787394e+00
            dataMean: 6.148656e+01

The returned value is another ``Variable`` object, which now has lost
its temporal dimension because this was integrated out. It represents
the average in time at each grid cell in the original data. The
``Variable`` object has a lot of functionality and will be expanded to
meet needs of developers. For a more complete explanation of the
interface, consult the `documentation
<_generated/ILAMB.Variable.Variable.html>`_. However, the point of
this tutorial is that we use the ``Variable`` object to perform
analysis operations in a uniform and flexible manner. Its full
functionality will be covered in more detail in a future tutorial.

The ModelResult Object
----------------------

The ``ModelResult`` object is meant to make getting a model's
variables easy. We anticipate that researchers will have placed all a
model run's results in a single directory bearing the model name as
well as perhaps version, or forcing. To create this object, we simply
point to the top-level directory where the results are contained::

  from ILAMB.ModelResult import ModelResult
  m = ModelResult(os.environ["ILAMB_ROOT"] + "/MODELS/CLM40cn",
                 modelname = "CLM40cn")

When we instantiate the model result, internally we search for all
variables found in all netCDF files contained underneath this
top-level directory. This makes extracting variables simple. We can
extract the same variable as above, but in a much more simple manner
once the model result has been defined::

  v = m.extractTimeSeries("rsus")
  print v

yields the folling screen output::

  Variable: rsus
  --------------
                unit: W m-2
          isTemporal: True (1932)
           isSpatial: True (192,288)
          nDatasites: N/A
           dataShape: (1932, 192, 288)
             dataMax: 4.028994e+02
             dataMin: 0.000000e+00
            dataMean: 6.153053e+01
  
In addition to making the aquisition of model data simpler, if land
fractions and areas are relevant (that is, the variable is spatial),
we will apply them to the variable automatically. The user is only
responsible for having the appropriate datafiles (``areacella`` and
``sftlf``) in the model's directory. Extracting the variables from the
``ModelResult`` object ensures that we handle model data
consistently. The ``ModelResult`` `interface
<_generated/ILAMB.ModelResult.ModelResult.html>`_ is much smaller, and
will be expanded in the future.

The Confrontation Object
------------------------

The ``Confrontation`` object manages the benchmark dataset, the
extraction of the data from the model, the anaylsis performed, as well
as the plotting and generating of results. As a developer, you will be
writing your own ``Confrontation`` objects so it is important to
understand what they are and how they work. First, we will initialize
one to help illustrate their functionality::

  from ILAMB.Confrontation import Confrontation
  c = Confrontation(source   = os.environ["ILAMB_ROOT"] + "/DATA/rsus/CERES/rsus_0.5x0.5.nc",
                    name     = "CERES",
		    variable = "rsus")

As before, we specify the source data relative to the ``ILAMB_ROOT``
variable. We also have given the confrontation a name and a variable
to expect. There are two main functions to highlight at this
point. The first has to do with preparing data for comparison::

  obs,mod = c.stageData(m)

The ``stageData`` functionality returns both the observational and
model datasets as ``Variable`` objects and in a form in which they are
comparable. For example, if we again print ``mod`` here, we is
analagous to ``v`` above, we see::
  
  Variable: rsus
  --------------
                unit: W/m2
          isTemporal: True (131)
           isSpatial: True (192,288)
          nDatasites: N/A
           dataShape: (131, 192, 288)
             dataMax: 4.028824e+02
             dataMin: 0.000000e+00
            dataMean: 6.035579e+01

However, the temporal dimension has been greatly reduced (from 1932
entries down to 131). This is because the observational dataset is
contemporary and the model starts back in 1850. In addition to
clipping the data, we also convert units if appropriate.

The second main function of the ``Confrontation`` is to perform the
desired analysis. This happens in the ``confront`` functionality::

  c.confront(m)

Where ``m`` is the ``ModelResult`` being passed in. This routine calls
``stageData`` internally, and then performs the desired analysis. The
function does not return anything, but generates an analysis file
which contains the results of the analysis. In this case, you will
find two netCDF4 files in your directory: ``CERES_Benchmark.nc`` and
``CERES_CLM40cn.nc``. You can use ``ncdump`` or ``ncview`` (from
NetCDF Tools) to examine the contents of these files.

The ``Confrontation`` also handles the plotting and generation of HTML
output pages, but this is a more advanced aspect of the object,
detailed in its interface, shown `here
<_generated/ILAMB.Confrontation.Confrontation.html>`_.

Summary
-------

While there is much more to learn in understanding the ILAMB python
package, these are the basic objects and concepts you will need to
grasp to implement new benchmarks and analysis. The basic idea is that
we have encapsulated the notion of benchmark datasets and their
accompanying analysis into a ``Confrontation`` class which operates on
the ``ModelResult`` represented as a ``Variable``. What we have done
here manually is part of what happens inside of the ``ilamb-run``
script, which we executed in previous tutorials.

