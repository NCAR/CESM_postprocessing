===========================
The PyConform User's Manual
===========================

What is it?
===========

PyConform is a tool for converting standardizing large NetCDF datasets,
such as standardization of model output for a model intercomparison
project like CMIP.

Requirements
------------

PyConform explicitly depends upon the following Python packages:

- netCDF4-python
- ASAPPyTools
- cf_units
- pyparsing
- dreqPy

These packages imply a dependency on the NumPy (v1.4+) and mpi4py (v1.3+) 
packages, and the libraries NetCDF, MPI/MPI-2, and UDUNITS2..

If using Python version 2.6, you will need to install the ``ordereddict``
package, too.

No thorough testing has been done to show whether earlier versions of
these dependencies will work with the PyReshaper. The versions listed
have been shown to work, and it is assumed that later versions will
continue to work.

How can I install it?
=====================

The easiest way of obtaining the PyReshaper is from the Python Package
Index (PyPI), using ``pip``:

::

    $  pip install [--user] PyReshaper

Alternatively, you can download the source from GitHub and install with
``setuptools``:

::

    $  git clone https://github.com/NCAR/PyReshaper
    $  cd PyReshaper
    $  python setup.py install [--user] 

This will download and install the most recent stable version of the source
code.  If the most recent version of the non-stable source is desired, you 
may switch to the development branch before installing.

::

    $  git checkout devel
   
When installing, the ``--user`` option to either ``pip`` or ``setup.py``
will install the PyReshaper in the user's private workspace, as defined
by the system on which the user is installing.  This is useful if you don't
have permissions to install system-wide software.

Generating the API Documentation
--------------------------------

If you are a developer, you may find the Sphinx API documentation helpful 
in understanding the design and functionality of the PyReshaper code. To 
generate this documentation, you must have Sphinx available and installed. 
If you do, the API documentation can be easily generated with the following 
command from the ``docs`` directory.

::

    $  make html

The API documentation will be placed in the ``docs/build/html/`` directory.

Generating the User Documentation
---------------------------------

The ``README.rst`` file and this User Manual should be consulted for help
on installing and using the software. Both documents are included with
the source. The ``README.rst`` file is included with the top-level
PyReshaper directory, and the User Manual is contained in the
``docs/source/manual.rst`` file. Both files are reStructuredText formatted
files, meaning they are simple text files that can be read with any text
viewer.

An HTML version of the User Manual will automatically be created by
Sphinx, as described in the previous section. A link will be created
to the manual in the HTML documentation.

Before Using the PyReshaper
---------------------------

If you installed the PyReshaper using ``pip``, then you should be ready to
go.  However, if you using the ``--user`` option, the local install directories
using by ``pip`` may not be in your paths.

First, you must add the installation site-packages directory to your
``PYTHONPATH``. If you installed with the ``--user`` option, this means
adding the ``$HOME/.local/lib/python2.X/site-packages`` (on Linux) directory 
to your ``PYTHONPATH``. If you specified a different ``--prefix`` option,
then you must point to that prefix directory. For bash users, this is
done with the following command.

::

    $ export PYTHONPATH=$PYTHONPATH:$PREFIX/lib/python2.X/site-packages

where the ``$PREFIX`` is the root installation directory used when
installing the PyReshaper package (``$HOME/.local/`` if using the
``--user`` option on Linux), and the value of ``X`` will correspond to the
version of Python used to install the PyReshaper package.

If you want to use the command-line interface to the PyReshaper, you
must also add the PyReshaper executables directory to your ``PATH``.
Like for the ``PYTHONPATH``, this can be done with the following
command.

::

    $ export PATH=$PATH:$PREFIX/bin

How do I use it?
================

Some General Concepts
---------------------

Before we describe the various ways you can use the PyReshaper, we must
describe more about what, precisely, the PyReshaper is designed to do.

As we've already mentioned, the PyReshaper is designed to convert a set
of NetCDF files from time-slice (i.e., synoptic or history-file) format 
to time-series (or single-field) format, either in serial or parallel.  
Time-slice files contain all of the model variables in one file, but typically
only span 1 or a few time-steps per file.  Time-series files nominally contain
only 1 single time-dependent variable spanning many time-steps, but they
can additionally contain metadata used to describe the single-field variable
contained by the file.

In serial, the PyReshaper will write each time-series variable to its own 
file in sequence.  In parallel, time-series variables will be 
written simultaneously across the MPI processes allocated for the job.

There are a number of assumptions that the PyReshaper makes regarding the
time-slice (input) data, which we list below.

1. Each time-slice NetCDF file has multiple time-dependent variables
   inside it, but can have many time-independent variables inside it, as
   well.
2. Each time-slice NetCDF file contains data for times that do not
   overlap with each other. (That is, each time-slice NetCDF file can
   contain data spanning a number of simulation time steps. However, the
   span of time contained in one time slice cannot overlap the span of
   time in another time-slice.)  If the time-slices overlap, an error
   will be given and execution will stop.
3. Every time-slice NetCDF file contains the same time-dependent
   variables, just at differing times.

Similarly, there are a number of assumptions made about the time-series
(output) data produced by the PyReshaper conversion process.  The variables 
written to the output data can be time-series variables or metadata
variables.  Time-series variables are written to one output file only.
Metadata variables are written to all output files.

1. By default, every time-dependent variable will be assumed to be a
   time-series variable (i.e., written to its own time-series NetCDF file).
2. Every time-independent variable that appears in the time-slice files
   will be assumed to be a metadata variable (i.e., written to every 
   time-series file).
3. Users can explicitly specify any number of time-dependent variables
   as metadata variables (e.g., such as ``time`` itself).
4. Every time-series file written by the PyReshaper will span the total
   range of time spanned by all time-slice files specified.
5. Every time-series file will be named with the same prefix and suffix,
   according to the rule:

   time\_series\_filename = prefix + variable\_name + suffix

where the variable\_name is the name of the time-series variable
associated with that time-series file.

It is important to understand the implications of the last assumption on
the list above. Namely, it is important to note what this assumption
means in terms of NetCDF file-naming conventions. It is common for the
file-name to contain information that pertains to the time-sampling
frequency of the data in the file, or the range of time spanned by the
time-series file, or any number of other things. To conform to such
naming conventions, it may be required that the total set of time-slice
files that the user wishes to convert to time-series be given to the
PyReshaper in multiple subsets, running the PyReshaper independently on
each subset of time-slice files. Throughout this manual, we 
will refer to such "subsets" as streams. As such, every single PyReshaper
operation is designed to act on a single stream.

Using the PyReshaper from the Unix Command-Line
-----------------------------------------------

While the most flexible way of using the PyReshaper is from within
Python, as described above, the easiest way to use the PyReshaper is usually
to run the PyReshaper command-line utilities.  In this section, we describe 
how to use the command-line utilities ``s2smake`` and ``s2srun``, which 
provide command-line interfaces (CLI) to the PyReshaper. (These scripts 
will be installed in the ``$PREFIX/bin`` directory, where ``PREFIX`` is the
installation root directory.  If you installed PyReshaper with the ``--user``
flag, you may need to add this directpry to your path.)

The ``s2smake`` utility is designed to generate a Specifier object file
(*specfile*) that contains a specification of the PyReshaper job.
The ``s2srun`` utility is then used to run the PyReshaper with the newly
generated *specfile*.

Below is an example of how to use the PyReshaper's ``s2smake`` utility, 
with all options and parameters specified on the command line.

::

    $ s2smake \
      --netcdf_format="netcdf4" \
      --compression_level=1 \
      --output_prefix="/path/to/outfile_prefix." \
      --output_suffix=".000101-001012.nc" \
      -m "time" -m "time_bounds" \
      --specfile=example.s2s \
      /path/to/infiles/*.nc

In this example, you will note that we have specified each
time-dependent metadata variable name with its own ``-m`` option. (In
this case, there are only 2, ``time`` and ``time_bounds``.) We have also
specified the list of input (time-slice) files using a wildcard, which
the Unix shell fills in with a list of all filenames that match this *glob*
*pattern*. In this case, we are specifying all files with the ``.nc`` file
extension in the directory ``/path/to/infiles``. These command-line options
and arguments specify all of the same input needed to run the PyReshaper.
Running this command will save this PyReshaper *specfile* in a file called
``example.s2s``.

When using *glob patterns*, it is important to understand that the *shell*
expands these glob patterns out into the full list of matching filenames 
*before* running the ``s2smake`` command.  On many systems, the length of
a shell command is limited to a fixed number of characters, and it is possible
for the *glob pattern* to expand to a length that makes the command too long
for the shell to execute!  If this is the case, you may contain your glob 
pattern in quotation marks (i.e., ``"/path/to/infiles/*.nc"`` instead of
``/path/to/infiles/*.nc``).  The ``s2smake`` command will then expand the
glob pattern internally, allowing you to avoid the command-line character
limit of the system.

With the *specfile* created and saved using the ``s2smake`` utility,
we can run the PyReshaper with this *specfile* using the ``s2srun`` utility,
with all options and parameters specified on the command line.

::

    $ s2srun --serial --verbosity=2 example.s2s

The example above shows the execution, in serial, of the PyReshaper job 
specified by the ``example.s2s`` *specfile* with a verbosity 
level of 2.

For parallel operation, one must launch the ``s2srun`` script from
the appropriate MPI launcher. On the NCAR Yellowstone system
(``yellowstone.ucar.edu``), for example, this is done with the following
command.

::

    $ mpirun.lsf s2srun --verbosity=3 example.s2s

In the above example, this will launch the ``s2srun`` script into
the MPI environment already created by either a request for an
interactive session or from an LSF submission script.

Arguments to the ``s2smake`` Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The arguments to the ``s2smake`` utility are as follows.

-  ``--backend BACKEND`` (``-b BACKEND``):  I/O backend to be used when
   reading or writing from NetCDF files.  The parameter ``BACKEND`` can be one
   of ``'Nio'`` or ``'netCDF4'``, indicating PyNIO or netCDF4-python, respectively.
   The default value is ``'netCDF4'``.

-  ``--compression_level C`` (``-c C``):  NetCDF compression level, when using the
   netcdf4 file format, where ``C`` is an integer between 0 and 9, with 0 indicating
   no compression at all and 9 indicating the highest level of compression. The 
   default compression level is 1.

-  ``--netcdf_format NCFORMAT`` (``-f NCFORMAT``):  NetCDF file format to be used
   for all output files, where ``NCFORMAT`` can be ``'netcdf'``, ``'netcdf4'``, or
   ``'netcdf4c'``, indicating NetCDF3 Classic format, NetCDF4 Classic format, or
   NetCDF4 Classic format with forced compression level 1.  The default file format
   is ``'netcdf4'``.

-  ``--metadata VNAME`` (``-m VNAME``):  Indicate that the variable ``VNAME`` should
   be treated as metadata, and written to all output files.  There may be more than
   one ``--metadata`` (or ``-m``) options given, each one being added to a list.

-  ``--meta1d`` (``-1``):  This flag forces all 1D time-variant variables to be treated
   as metadata.  These variables need not be added explicitly to the list of metadata
   variables (i.e., with the ``--metadata`` or ``-m`` argument).  These variables will
   be added to the list when the PyReshaper runs.
   
-  ``--specfile SPECFILE`` (``-o SPECFILE``):  The name of the *specfile* to write,
   containing the specification of the PyReshaper job.  The default *specfile* name
   is ``'input.s2s'``.

-  ``--output_prefix PREFIX`` (``-p PREFIX``):  A string specifying the prefix to be
   given to all output filenames.  The output file will be named according to the 
   rule:
   
   ``output_prefix + variable_name + output_suffix``
   
   The default output filename prefix is ``'tseries.'``.
   
-  ``--output_suffix SUFFIX`` (``-s SUFFIX``):  A string specifying the suffix to be
   given to all output filenames.  The output file will be named according to the 
   rule:
   
   ``output_prefix + variable_name + output_suffix``
   
   The default output filename suffix is ``'.nc'``.

-  ``--time_series VNAME``:  Indicate that only the named ``VNAME`` variables should
   be treated as time-series variables and extracted into their own time-series files.
   This option works like the ``--metadata`` option, in that multiple occurrences of
   this option can be used to extract out only the time-series variables given.  If
   any variable names are given to both the ``--metadata`` and ``--time_series`` 
   options, then the variable will be treated as metadata.  If the ``--time_series``
   option is *not* used, then all time-dependent variables that are not specified to
   be metadata (i.e., with the ``--metadata`` option) will be treated as time-series
   variables and given their own output file.  **NOTE: If you use this option, data
   can be left untransformed from time-slice to time-series output!  DO NOT DELETE
   YOUR OLD TIME-SLICE FILES!**
    
Each input file should be listed in sequence, space separated, on the command line to
the utility, nominally after all other options have been specified.

   
Arguments to the ``s2srun`` Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While the basic options shown in the previous examples above are
sufficient for most purposes, additional options are available.

-  ``--chunk NAME,SIZE`` (``-c NAME,SIZE``):  This command-line option can be used
   to specify a maximum read/write chunk-size ``SIZE`` along a given named dimension
   ``NAME``.  Multiple ``--chunk`` options can be given to specify chunk-sizes along
   multiple dimensions.  This option determines the size of the data "chunk" read
   from a single input file (and then written to an output file).  If the chunk-size
   is greater than the given dimension size, then the entire dimension will be read
   at once.  If the chunk-size is less than the given dimension size, then all variables
   that depend on that dimension will be read in multiple parts, each "chunk" being written
   before the next is read.  This can be important to control memory use.  By default,
   chunking is done over the unlimited dimension with a chunk-size of 1.

-  ``--limit L`` (``-l L``):  This command-line option can be used to set the 
   ``output_limit`` argument of the PyReshaper ``convert()`` function, 
   described below.  This can be used when testing to only output the first ``L``
   files.  The default value is 0, which indicates no limit (normal operation).

-  ``--write_mode M`` (``-m M``): This command-line option can be used to set
   the ``wmode`` output file write-mode parameter of the ``create_reshaper()``
   function, described below.  The default write mode is ``'w'``, which indicates
   normal writing, which will error if the output files already exists (i.e.,
   no overwriting).  Other options are ``'o'`` to overwrite existing output files,
   ``'s'`` to skip existing output files, ``'a'`` to append to existing output
   files.

-  ``--serial`` (``-s``):  If this flag is used, it will run the PyReshaper in
   serial mode.  By default, it will run PyReshaper in parallel mode.

-  ``--verbosity V`` (``-v V``):  Sets the verbosity level for standard output
   from the PyReshaper.  A level of 0 means no output, and a value of 1 or more
   means increasingly more output.  The default verbosity level is 1.

Nominally, the last argument given to the ``s2srun`` utility should be the name
of the *specfile* to run.


Using the PyReshaper from within Python
---------------------------------------

Obviously, one of the advantages of writing the PyReshaper in Python is
that it is easy to import features (modules) of the PyReshaper into your
own Python code, as you might link your own software tools to an
external third-party library. The library API for the PyReshaper is
designed to be simple and light-weight, making it easy to use in your
own Python tools or scripts.

Below, we show an example of how to use the PyReshaper from within
Python to convert a stream from time-slice format to time-series
format.

.. code:: py

    from pyreshaper import specification, reshaper

    # Create a Specifier object
    specifier = specification.create_specifier()

    # Specify the input needed to perform the PyReshaper conversion
    specifier.input_file_list = [ "/path/to/infile1.nc", "/path/to/infile2.nc", ...]
    specifier.netcdf_format = "netcdf4"
    specifier.compression_level = 1
    specifier.output_file_prefix = "/path/to/outfile_prefix."
    specifier.output_file_suffix = ".000101-001012.nc"
    specifier.time_variant_metadata = ["time", "time_bounds"]

    # Create the PyReshaper object
    rshpr = reshaper.create_reshaper(specifier,
                                     serial=False,
                                     verbosity=1,
                                     wmode='s')

    # Run the conversion (slice-to-series) process
    rshpr.convert()

    # Print timing diagnostics
    rshpr.print_diagnostics()

In the above example, it is important to understand the input given to
the PyReshaper. Namely, all of the input for this single stream is
contained by a single instantiation of a Specifier object (the code for
which is defined in the specification module). We will describe each
attribute of the Specifier object below.

Specifier Object Attributes
~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  ``input_file_list``: This specifies a list of input (time-slice) file
   paths that all conform to the input file assumptions (described
   above). The list of input files need not be time-ordered, as the
   PyReshaper will order them appropriately. (This means that this list
   can easily be generated by using filename globs.)

In the example above, each file path is full and absolute, for safety's
sake.

-  ``netcdf_format``: This is a string specifying what NetCDF format
   will be used to write the output (time-series) files.  Acceptable options 
   for ``netcdf_format`` are: ``"netcdf"`` for NetCDF3 format, ``"netcdf4"``
   for NetCDF4 Classic format, and ``"netcdf4c"`` for NetCDF4 Classic with
   level-1 compression.

-  ``compression_level``: This is an integer specifying the level of 
   compression to use when writing the output files.  This can be a number
   from 0 to 9, where 0 means no compression (default) and 9 mean the
   highest level of compression.  This is overridden when the ``"netcdf4c"``
   format is used, where it is forced to be 1.

In the above example, NetCDF4 Classic format is used for the output files,
with level-1 compression.  The ``"netcdf4c"`` option can be used as a 
short-hand notation for this combination of ``netcdf_format`` and 
``compression_level`` options.

-  ``output_file_prefix``: This is a string specifying the common output
   (time-series) filename prefix. It is assumed that each time-series
   file will be named according to the rule:

   filename = output\_file\_prefix + variable\_name + output\_file\_suffix

-  ``output_file_suffix``: This is a string specifying the common output
   (time-series) filename suffix. It is assumed that each time-series
   file will be named according to the above rule.

It is important to understand, as in the example above, that the prefix
can include the full, absolute path information for the output
(time-series) files.

-  ``time_variant_metadata``: This specifies a list of variable names
   corresponding to variables that should be written to every output
   (time-series) NetCDF file.  Nominally, this should specify only the
   time-variant (time-dependent) variables that should *not* be treated
   as time-series variables (i.e., treated as metadata), since all 
   time-invariant (time-independent) variables will be treat as metadata
   automatically.

-  ``assume_1d_time_variant_metadata``: If set to ``True``, this indicates
   that all 1D time-variant variables (i.e., variables that *only* depend
   upon ``time``) should be added to the list of ``time_variant_metadata``
   when the Reshaper runs.  The default for this option is ``False``.

-  ``time_series``: If set to a list of string variable names, only these
   variable names will be transformed into time-series format.  This is
   equivalent to the ``--time_series`` option to the ``s2smake`` utility.
   **NOTE: Setting this attribute can leave data untransformed from time-slice
   to time-series format!  DO NOT DELETE YOUR OLD TIME-SLICE FILES!**
   
-  ``backend``: This specifies which I/O backend to use for reading
   and writing NetCDF files.  The default backend is ``'netCDF4'``, but
   the user can alternatively specify ``'Nio'`` to use PyNIO.

Specifier Object Methods
~~~~~~~~~~~~~~~~~~~~~~~~

In addition to the attributes above, the Specifier objects have some useful
methods that can be called.

-  ``validate()``:  Calling this function validates the attributes of the
   Specifier, making sure their types and values appear correct.

-  ``write(filename)``:  Calling this function with the argument ``filename``
   will write the *specfile* matching the Specifier.


Specfiles
~~~~~~~~~

*Specfiles* are simply *pickled* Specifier objects written to a file.  To
create a *specfile*, one can simply call the Specifier's ``write()`` method,
described above, or one can explicitly *pickle* the Specifier directly, as
shown below.

.. code:: py

    import pickle
    
    # Assume "spec" is an existing Specifier instance
    pickle.dump(spec, open("specfile.s2s", "wb"))

This is equivalent to the call ``spec.write('specfile.s2s')``.

A *specfile* can be read with the following Python code.

.. code:: py

    import pickle
    
    spec = pickle.load( open("specfile.s2s", "rb") )
        
    
Arguments to the ``create_reshaper()`` Function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the example above, the PyReshaper object (rshpr) is created by
passing the single Specifier instance to the *factory* function
``create_reshaper()``. This function returns a PyReshaper object that has
the functions ``convert()`` and ``print_diagnostics()`` that perform the
time-slice to time-series conversion step and print useful timing
diagnostics, respectively.

In addition to the Specifier instance, the ``create_reshaper()`` function 
takes the following parameters.

-  ``serial``: This is a boolean flag, which can be ``True`` or ``False``,
   indicating whether the PyReshaper ``convert()`` step should be done in serial
   (``True``) or parallel (``False``). By default, parallel operation is
   assumed if this parameter is not specified.

-  ``verbosity``: This is an integer parameter that specifies what level of
   output to produce (to ``stdout``) during the ``convert()`` step.  A
   verbosity level of ``0`` means that no output will be produced, while an
   increasing vebosity level producing more and more output.  Currently, a
   level of ``2`` produces the most output possible.

   1. ``verbosity = 0``: This means that no output will be produced unless
      specifically requested (i.e., by calling the ``print_diagnostics()``
      function).
   2. ``verbosity = 1``: This means that only output that would be produced
      by the head rank of a parallel process will be generated.
   3. ``verbosity = 2``: This means that all output from all processors
      will be generated, but any output that is the same on all processors
      will only be generated once.

-  ``wmode``: This is a single-character string that can be used to set the
   *write mode* of the PyReshaper.  By default, the PyReshaper will not overwrite
   existing output files, if they exist.  In normal operation, this means the 
   PyReshaper will error (and stop execution) if output files are already
   present.  This behavior can be  controlled with the ``wmode`` parameter.  
   The ``wmode`` parameter can be set to any of the following.
   
   1. ``wmode = 'w'``: This indicates that normal write operation is to be
      performed.  That is, the PyReshaper will error and stop execution if it
      finds output files that already exist.  This is the default setting.
   2. ``wmode = 's'``: This indicates that the PyReshaper should skip generating
      time-series files for output files that already exist.  No check is
      done to see if the output files are correct.
   3. ``wmode = 'o'``:  This indicates that the PyReshaper should overwrite 
      existing output files, if present.  In this mode, the existing output
      files will be deleted before running the PyReshaper operation.
   4. ``wmode = 'a'``:  This indicates that the PyReshaper should append to 
      existing output files, if present.  In this mode, it is assumed that the
      existing output files have the correct format before appending new data
      to them.

-  ``simplecomm``: This option allows the user to pass an ``ASAPPyTools``
   ``SimpleComm`` instance to the PyReshaper, instead of having the PyReshaper
   create its own internally.  The ``SimpleComm`` object is the simple MPI
   communication object used by the PyReshaper to handle its MPI communication.
   By default, the PyReshaper will create its own SimpleComm that uses the
   MPI ``COMM_WORLD`` communicator for communication.  However, the user
   may create their own ``SimpleComm`` object and force the PyReshaper to use
   it by setting this option equal to the user-created ``SimpleComm`` instance.


Arguments to the ``convert()`` Function
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While not shown in the above examples, there are named arguments that can
be passed to the ``convert()`` function of the Reshaper object.

-  ``output_limit``:  This argument sets an integer limit on the number of
   time-series files generated during the ``convert()`` operation (per MPI process).
   This can be useful for debugging purposes, as it can greatly reduce the length
   of time consumed in the ``convert()`` function. A value of ``0`` indicates
   no limit, or all output files will be generated.

-  ``chunks``:  This argument sets a dictionary of dimension names to chunk-sizes.
   This is equivalent to the ``--chunk`` command-line option to ``s2srun``.  This option
   determines the size of the data "chunk" read from a single input file (and then written 
   to an output file) along each given dimension.  If a chunk-size is greater than the given
   dimension size, then the entire dimension will be read at once.  If a chunk-size is less
   than the given dimension size, then all variables  that depend on that dimension will be 
   read in multiple parts, each "chunk" being written before the next is read.  This can be 
   important to control memory use.  By default, the ``chunks`` parameter is equal to 
   ``None``, which means chunking is done over the unlimited dimension with a chunk-size of 1.


Obtaining Best Performance with the PyReshaper
----------------------------------------------

While the PyReshaper can be run in either serial or parallel, best performance
is almost always achieved by running in parallel.  Understanding how the
PyReshaper operates, however, is important to knowing how to get the best
performance.

Of critical importance to understanding this, one must appreciate the fact that
the PyReshaper only parallelizes over *time-series* (output) variables.  Or,
in other words, it parallelizes over output files, since each time-series
variable is written to its own file.  Thus, the maximum amount of parallelism
in the PyReshaper equal to the number of time-series variables in the input
dataset.  If 10 time-series variables exist in the input dataset, then the
maximum performance will be achieved by running the job with 10 MPI processes.

Unfortunately, that is not all that needs to be appreciated, because there are
many factors that can impact performance.

Shared Memory
~~~~~~~~~~~~~

On many parallel systems, with well-scaling parallel software, *compute*
performance scales with the number of MPI processes, where each process is
executed on its own CPU core.  Multicore CPUs, therefore, can run (efficiently)
as many MPI processes simultaneously as there are cores on the CPU.  These 
MPI processes will share the memory attached to the CPU, however, so 
memory-intensive MPI processes may require leaving some cores idle on the 
CPU in order to leave enough memory for the MPI processes to execute without
an out-of-memory failure.

To best determine how much memory you need on a single MPI process, find the
largest time-series variable in the input dataset.  This can usually be found
by multiplying the size of each dimension upon which the time-series variable
depends, and then multiplying by the byte-size of the variable's data type.
For example, a ``double`` time-series variable with the dimensions 
``('time', 'lat', 'lon')``, would have a byte-size of the following.

::

    S_B('var') = S('time') * S('lat') * S('lon') * S_B('double')

where ``S(d)`` represents the numeric size of dimension ``d``, and ``S_B(v)``
represents the number of bytes of the variable ``v``.  (The ``S_B('double')``
is equal to 8 bytes, while ``S_B('float')`` is equal to 4 bytes.)  If we
assume ``S('time') = 14600``, ``S('lat') = 180``, and ``S('lon') = 360``, then
``S_B('var') = 7`` GB.

If you then run ``N`` MPI processes on each node, each MPI process has roughly
``1/N``th of the memory available to it, and this memory must be large enough
to contain the time-series variable.  So, on a system with 16 cores per node,
and 64 GB per node, has only (on average) 4 GB per core.  The above time-series
variable would not fit in only 4 GB, but it would fit in 8 GB, so we might use
only 8 of the 16 available cores per node in our PyReshaper run.

I/O Nodes
~~~~~~~~~

Similar limitations usually apply to *I/O* (reading/writing data) operations,
of which the PyReshaper is one.  The PyReshaper does very little computation
on the CPU, and almost all of its operation time is dominated by I/O.  
Unfortunately, most systems have serial I/O from all MPI processes on the same
CPU (or *node*).  Hence, while a multicore CPU can efficiently execute as many
MPI processes as cores on the CPU for *computation*, this may not be true for 
I/O.  To prevent overloading the node's I/O capabilities, it may be necessary
to run fewer PyReshaper processes *per node* than there are available cores.

This is a parameter that is hard to get a feel for, so it is best to see how
performance varies on the system you are using.  In general, though, using the
maximum number of processes per node will saturate the I/O capabilities of the
node, so using fewer processes per node may improve conversion speeds.
