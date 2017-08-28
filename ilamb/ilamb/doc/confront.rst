Custom Confrontations
=====================

The ``Confrontation`` object we described in the previous tutorial is
implemented as a python class. This tutorial will assume you have some
familiarity with python and classes. We will try to make the concepts
easy to follow, but if you find that you need to learn about *class*
basics, we recommend the python documentation on them `here
<https://docs.python.org/2/tutorial/classes.html>`_.

In this tutorial we will explain the implementation of a custom
``Confrontation`` by way of example. We will detail the code that we
use in the ILAMB system for benchmarking the global net ecosystem
carbon balance. The generic ``Confrontation`` will not work in this
case because:

* There is no variable in the model outputs which directly compares to
  the benchmark datasets. The variable ``nbp`` must be integrated over
  the globe for it to be comparable.
* The analysis we want to perform is different than our standard mean
  state analysis. We will compare the bias and RMSE of the integrated
  quantity, but then we would like to also view the accumulation of
  carbon over the time period.

So we have some special-purpose code to write. We will present here
the implementation bit by bit and explain each function and
section. However, if you are following along and implementing the
class as you read, we recommend you look at the original source which
may be found on our `bitbucket
<https://bitbucket.org/ncollier/ilamb/src/6616b026a2ce743dcd819a7a61f3f6b2275541d7/src/ILAMB/ConfNBP.py?at=master&fileviewer=file-view-default>`_
site. This is because the amount of tab space gets shifted in the
generation of this document. I will also omit the documentation
strings and imports here to keep the code short.

The Constructor
---------------

The first thing we will do, is define a new class ``ConfNBP`` which
will be derived from the ``Confrontation`` base class. This means that
all the methods and member data of the ``Confrontation`` class will be
part of ``ConfNBP`` automatically. This is helpful, as it means that
the developer only needs to rewrite the functions that must behave
differently in his benchmark. So we define our class by writing::

  class ConfNBP(Confrontation):
  
    def __init__(self,**keywords):
        
        # Ugly, but this is how we call the Confrontation constructor
        super(ConfNBP,self).__init__(**keywords)

        # Now we overwrite some things which are different here
        self.regions = ['global']

We place this class in a file which bears the name of the class
itself, ``ConfNBP.py``. The ``__init__`` function is what is known as
the constructor. A class can be thought of as a template and the
constructor is the function which runs when a new instance is
created. If I were to type::

  a = Confrontation()
  b = Confrontation()

I would be creating two instances (``a`` and ``b``) of the
``Confrontation`` class and the constructor would run separately for
each of them. The constructor for the ``Confrontation`` class takes in
keywords as arguments. This means that instead of requiring users to
place arguments in a defined order, we allow them to specify arguments
by their names. We did this in the previous tutorial, when we
initialized a ``Confrontation`` in the following way::
  
  c = Confrontation(source   = os.environ["ILAMB_ROOT"] + "/DATA/rsus/CERES/rsus_0.5x0.5.nc",
                    name     = "CERES",
                    variable = "rsus")

The keywords we used here were ``source``, ``name``, and
``variable``. You have a lot of control over what a ``Confrontation``
does via these keywords. A full list of them is available in the
`documentation
<_generated/ILAMB.Confrontation.Confrontation.html>`_. For the most
part, we want to use the ``Confrontation`` constructor as it is, and
so we could just leave the ``__init__`` function
unimplemented. However, one of the keywords of the ``Confrontation``
constructor is not valid in our benchmark--the ``regions``
keyword. This is a keyword where a user may specify a list of GFED
regions over which we will perform the analysis. In the case of our
``ConfNBP``, this is not a valid option as the benchmark data is
integrated over the globe. 

For this reason, we implement our own ``__init__`` function where we
manually call the constructor of the ``Confrontation`` class. This is
handled by using the python function ``super``. This references the
super object of our ``ConfNBP`` object and allows us to manually call
its constructor. After this constructor has run, we simply overwrite
the value of the ``regions`` member data to be the only valid value.

Staging Data
------------

We need to implement our own ``stageData`` functionality as models do
not provide us with the integrated ``nbp`` directly. We will go over
its implementation here in pieces. First we get the observational
dataset::

    def stageData(self,m):

        # get the observational data
        obs = Variable(filename       = self.source,
                       variable_name  = self.variable,
                       alternate_vars = self.alternate_vars)

So you will see first that the function signature has a ``self``
argument. This will be true of all member functions of our class. This
is a special argument which is used to access all the member data of
the class itself. The second argument is ``m`` which is a instance of
a ``ModelResult``. Just below we use the ``Variable`` constructor to
extract the source data for this benchmark using member data of our
class. The member data ``source`` refers to the full path of the
benchmark dataset, ``variable`` is the name of the variable to extract
from within, and ``alternate_vars`` is a list of alternative names for
variable names which we can accept. By convention, we use the ``obs``
name to refer to the returned ``Variable``. Next, we need to extract
the same data from the model::
    
        # the model data needs integrated over the globe
        mod = m.extractTimeSeries(self.variable,
                                  alt_vars = self.alternate_vars)
        mod = mod.integrateInSpace().convert(obs.unit)
        
        obs,mod = il.MakeComparable(obs,mod,clip_ref=True)

        # sign convention is backwards
        obs.data *= -1.
        mod.data *= -1.
        
        return obs,mod

Here we use the ``ModelResult`` instance ``m`` to extract the
variable, and immediately integrate it over all space. We also ensure
that the units match the observations and, again by convention, we
refer to this in a variable we call ``mod``. Then we use the function
`MakeComparable <_generated/ILAMB.ilamblib.MakeComparable.html>`_ to ensure
that both the ``obs`` and ``mod`` variables are on the same time
frame, trimming away the non-overlapping times. Finally we multiply the
data associated with the observations and models by a negative one
because of a unwanted sign convention.

The main concept of the ``stageData`` function is that you are passed
a ``ModelResult`` and you need to return two ``Variables`` which
represent comparable quantities from the observational and model
datasets. The ILAMB system does not care how you came about these
quantities. Here we have used more of the ILAMB package to create the
quantities we wish to compare. However, you may prefer to use other
tools or even interface to more complex methods of extracting relevant
information. The ILAMB package simply defines an interface which makes
the results of such data manipulation usable in a consistent system.

Confront
--------

We also need to implement our own ``confront`` functionality. This is
because most of our `mean state
<./_generated/ILAMB.ilamblib.AnalysisMeanState.html>`_ is not relevant
for our benchmark, and we would like to study the accumulation of
carbon which is not part of the procedure. As before we will break up
the ``confront`` function we implemented and explain it in sections::

    def confront(self,m):
    
        # Grab the data
        obs,mod = self.stageData(m)
        
As with the ``stageData`` function, the ``confront`` function takes in
a ``ModelResult`` instance ``m`` and immediately calls the
``stageData`` function we just implemented. The observational dataset
and model result are returned as represented as ``Variables`` and
named ``obs`` and ``mod``, respectively. For both datasets, we want to
study the accumulated amount of carbon over the time period::

        obs_sum  = obs.accumulateInTime().convert("Pg")
        mod_sum  = mod.accumulateInTime().convert("Pg")

as well as compare the mean values over the time period::
  
        obs_mean = obs.integrateInTime(mean=True)
        mod_mean = mod.integrateInTime(mean=True)

and then the bias and RMSE::
  
        bias     = obs.bias(mod)
        rmse     = obs.rmse(mod)

The functions, ``accumulateInTime``, ``convert``, ``integrateInTime``,
``bias``, and ``rmse`` are all member functions of the `Variable
<_generated/ILAMB.Variable.Variable.html>`_ class. So you can see that
this keeps analysis clean, short, and human readable. This handles the
majority of the analysis which we want to perform in this
confrontation. However, the ILAMB system is geared towards determining
a score from the analysis results. In this case, we will score a model
based on the bias and the RMSE in the following way:

  .. math:: S_{\text{bias}} = e^{-\left| \frac{\int \left(obs(t) - mod(t)\right)\ dt }{\int obs(t)\ dt } \right|}
  .. math:: S_{\text{RMSE}} = e^{-\sqrt{ \frac{\int \left(obs(t) - mod(t)\right)^2\ dt }{\int obs(t)^2\ dt } }}

This is accomplished in the following way::
  
        obs_L1       = obs.integrateInTime()
        dif_L1       = deepcopy(obs)
        dif_L1.data -= mod.data
        dif_L1       = dif_L1.integrateInTime()
        bias_score   = Variable(name = "Bias Score global",
                                unit = "1",
                                data = np.exp(-np.abs(dif_L1.data/obs_L1.data)))

for the bias score and::
  
        obs_L2       = deepcopy(obs)
        obs_L2.data *= obs_L2.data
        obs_L2       = obs_L2.integrateInTime()
        dif_L2       = deepcopy(obs)
        dif_L2.data  = (dif_L2.data-mod.data)**2
        dif_L2       = dif_L2.integrateInTime()
        rmse_score   = Variable(name = "RMSE Score global",
                                unit = "1",
                                data = np.exp(-np.sqrt(dif_L2.data/obs_L2.data)))

for the RMSE score. The code here is a bit more ugly than the previous
and reflects ways in which the ``Variable`` object needs to grow. At
this point the analysis results are finished and we are ready to save
things into result files. First, we will rename the variables in the
following way::

        obs     .name = "spaceint_of_nbp_over_global"
        mod     .name = "spaceint_of_nbp_over_global"
        obs_sum .name = "accumulate_of_nbp_over_global"
        mod_sum .name = "accumulate_of_nbp_over_global"
        obs_mean.name = "Period Mean global"
        mod_mean.name = "Period Mean global"
        bias    .name = "Bias global"       
        rmse    .name = "RMSE global" 

We rename the variables because the ILAMB plotting and HTML generation
engine is built to recognize certain keywords in the variable name and
subsequently render the appropriate plots. Since our ``obs`` and
``mod`` variables represent spatial integrals of ``nbp``, we name them
with the keyword ``spaceint``. The ``accumulate`` keyword also will
cause a plot to automatically be generated and placed in the HTML
output in a predetermined location. This feature makes the
presentation of results trivial. The scalar quantities are also
changed such that their names reflect the table headings of the HTML
output.

Finally we dump these variables into netCDF4 files. The first file
corresponds to the current model being analyzed. The dataset is opened
which will be saved into a logical path, with descriptive names. The
``Variable`` class has support for simply asking that an instanced be
dumped into an open dataset. Any dimension information or units are
automatically recorded::

        results = Dataset("%s/%s_%s.nc" % (self.output_path,self.name,m.name),mode="w")
        results.setncatts({"name" :m.name, "color":m.color})
        mod       .toNetCDF4(results)
        mod_sum   .toNetCDF4(results)
        mod_mean  .toNetCDF4(results)
        bias      .toNetCDF4(results)
        rmse      .toNetCDF4(results)
        bias_score.toNetCDF4(results)
        rmse_score.toNetCDF4(results)
        results.close()

We also write out information from the benchmark dataset as
well. However, since confrontations can be run in parallel, only the
confrontation that is flagged as the master need write this output::
  
        if self.master:
            results = Dataset("%s/%s_Benchmark.nc" % (self.output_path,self.name),mode="w")
            results.setncatts({"name" :"Benchmark", "color":np.asarray([0.5,0.5,0.5])})
            obs     .toNetCDF4(results)
            obs_sum .toNetCDF4(results)
            obs_mean.toNetCDF4(results)
            results.close()

That is it
----------

While more involved than simply adding a dataset or model result to
the analysis, that is all we need to implement for our custom
confrontation. As you can see, we managed to encapsulate all of the
relevant code into one file which interfaces seamlessly with the rest
of the ILAMB system. In the case of ``ConfNBP.py``, we have included
it in the main repository for the ILAMB package. However, users may
create their own confrontations and host/maintain them separately for
use with the system. We see this as a first step towards a more
general framework for community-driven benchmarking.
