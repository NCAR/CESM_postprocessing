============================
The PyReshaper User's Manual
============================

What is it?
===========

The PyReshaper is a tool for converting NetCDF time-slice formatted
files into time-series format. It is written in Python as an
easy-to-install package consisting of 4 Python modules.

Requirements
------------

The PyReshaper is built upon 2 third-party Python packages, which
separately depend upon other packages, as indicated below.

-  PyNIO (v1.4.1)
-  numpy (v1.4)
-  NetCDF
-  mpi4py (v1.3)
-  A dynamic/shared library installation of MPI or MPI-2

No thorough testing has been done to show whether earlier versions of
these dependencies will work with the PyReshaper. The versions listed
have been shown to work, and it is assumed that later versions will
continue to work.

How can I get it?
=================

The best way to obtain the PyReshaper code is to check it out from the
GitHub site, as shown below.

::

    $  git clone https://github.com/NCAR-CISL-ASAP/PyReshaper
    $  cd PyReshaper

This will download the most recent stable version of the source code.  If
the most recent version of the non-stable source is desired, you may switch
to the development branch.

::

    $  git checkout devel


How do I set it up?
===================

Easy Installation
-----------------

The easiest way to install the PyReshaper is from the Python Package Index,
PyPI.  To do this, use the ``pip`` tool like follows.

::

    $  pip install [--user] PyReshaper
    
If you do not have the required dependencies installed, then ``pip`` will
install them for you at this time.  The ``--user`` option will be necessary
if you do not have system install privileges on the machine you are using.
    
Installation from Source
------------------------

In this section, we describe how to install the PyReshaper package on a
unix-like system. The procedure is similar for a Mac, but we have not
tested the package on Windows.

As described in the previous section, first check out the source code
from the subversion repository. On unix-like systems, the command is
shown below.

::

    $  git clone https://github.com/NCAR-CISL-ASAP/PyReshaper

Enter into the newly created directory.

::

    $  cd PyReshaper

The contents of the repository will look like the following.

::

    $  ls
    CHANGES.rst README.rst  docs/       setup.py    tests/
    LICENSE.rst bin/        setup.cfg   source/

To install the package, type the following command from this directory.

::

    $  python setup.py install [--user]

If you are a system administrator, you can leave off the ``--user``
option, and the package will be installed in ``/usr/local``, by default.
Alternatively, you may specify your own installation root directory with
the ``--prefix`` option.

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
of NetCDF files from time-slice (i.e., multiple time-dependent variables
with one time-value per file) format to time-series (one time-dependent
variable with multiple time-values per file) format, either in serial or
parallel.  In serial, the PyReshaper will write each time-series variable
to its own file in sequence.  In parallel, time-series variables will be 
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
   time in another time-slice.)
3. Every time-slice NetCDF file contains the same time-dependent
   variables, just at differing times.

Similarly, there are a number of assumptions made about the time-series
(output) data produced by the PyReshaper conversion process.

1. By default, every time-dependent variable will be written to its own
   time-series NetCDF file.
2. Any time-dependent variables that should be included in every
   time-series file (e.g., such as ``time`` itself), instead of getting
   their own time-series file, must be specified by name.
3. Every time-independent variable that appears in the time-slice files
   will be written to every time-series file.
4. Every time-series file written by the PyReshaper will span the total
   range of time spanned by all time-slice files specified.
5. Every time-series file will be named with the same prefix and suffix,
   according to the rule:

   time\_series\_filename = prefix + variable\_name + suffix

where the variable\_name is the name of the time-dependent variable
associated with that time-series file.

It is important to understand the implications of the last assumption on
the list above. Namely, it is important to note what this assumption
means in terms of NetCDF file-naming conventions. It is common for the
file-name to contain information that pertains to the time-sampling
frequency of the data in the file, or the range of time spanned by the
time-series file, or any number of other things. To conform to such
naming conventions, it may be required that the total set of time-slice
files that the user which to convert to time-series be given to the
PyReshaper in multiple subsets, or chunks. Throughout this manual, we
will refer to such "chunks" as streams. As such, every single PyReshaper
operation is designed to act on a single stream.

Using the PyReshaper from within Python
---------------------------------------

Obviously, one of the advantages of writing the PyReshaper in Python is
that it is easy to import features (modules) of the PyReshaper into your
own Python code, as you might link your own software tools to an
external third-party library. The library API for the PyReshaper is
designed to be simple and light-weight, making it easy to use in your
own Python tools or scripts.

Single-Stream Usage
~~~~~~~~~~~~~~~~~~~

Below, we show an example of how to use the PyReshaper from within
Python to convert a single stream from time-slice format to time-series
format.

.. code:: py

    from pyreshaper import specification, reshaper

    # Create a Specifier object (that defined a single stream to be converted
    specifier = specification.create_specifier()

    # Specify the input needed to perform the PyReshaper conversion
    specifier.input_file_list = [ "/path/to/infile1.nc", "/path/to/infile2.nc", ...]
    specifier.netcdf_format = "netcdf4"
    specifier.compression_level = 1
    specifier.output_file_prefix = "/path/to/outfile_prefix."
    specifier.output_file_suffix = ".000101-001012.nc"
    specifier.time_variant_metadata = ["time", "time_bounds", ...]

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^

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

Even though the PyReshaper is designed to work on a single stream at a
time, multiple streams can be defined as input to the PyReshaper. When
running the PyReshaper with multiple stream, multiple Specifier objects
must be created, one for each stream.  See the section on 
Multiple Stream Usage.

Arguments to the ``create_reshaper()`` Function
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

While not shown in the above examples, there is an argument to the
``convert()`` function of the PyReshaper object called ``output_limit``.
This argument sets an integer limit on the number of time-series files
generated during the ``convert()`` operation (per MPI process). This can
be useful for debugging purposes, as it can greatly reduce the length of
time consumed in the ``convert()`` function. A value of ``0`` indicates
no limit, or all output files will be generated.

Multiple Stream Usage
~~~~~~~~~~~~~~~~~~~~~

In the example below, we show one way to define a multiple stream
PyReshaper run.

.. code:: py

    from pyreshaper import specification, reshaper

    # Assuming all data defining each stream is contained 
    # in a list called "streams"
    specifiers = {}
    for stream in streams:
        specifier = specification.create_specifier()

        # Define the Pyreshaper input for this stream
        specifier.input_file_list = stream.input_file_list
        specifier.netcdf_format = stream.netcdf_format
        specifier.compression_level = stream.compression_level
        specifier.output_file_prefix = stream.output_file_prefix
        specifier.output_file_suffix = stream.output_file_suffix
        specifier.time_variant_metadata = stream.time_variant_metadata

        # Append this Specifier to the dictionary of specifiers
        specifiers[stream.name] = specifier

    # Create the PyReshaper object
    rshpr = reshaper.create_reshaper(specifiers, serial=False, verbosity=1)

    # Run the conversion (slice-to-series) process
    rshpr.convert()

    # Print timing diagnostics
    rshpr.print_diagnostics()

In the above example, we assume the properly formatted data (like the
data shown in the single-stream example above) is contained in the list
called ``streams``. In addition to the data needed by each Specifier
(i.e., the data defining each ``stream`` instance), this example assumes that
a name has been given to each stream, contained in the attribute 
``stream.name``.  Each Specifier is then contained in a dictionary with keys
corresponding to the stream name and values corresponding to the stream
Specifier. This name will be used when printing diagnostic information during
the ``convert()`` and ``print_diagnostics()`` operations of the PyReshaper.

Alternatively, the specifiers object (in the above example) can be a
Python list, instead of a Python dictionary. If this is the case, the
list of Specifier objects will be converted to a dictionary, with the
keys of the dictionary corresponding to the list index (i.e., an
integer).

It is important to note that when running multiple streams through one
PyReshaper, however, load-balancing may not be ideal.  Some streams may only
have a handful of time-series variables, while other streams may have a
large number of time-series variables.  Since the PyReshaper parallelizes over
time-series variables, this means that the ideal number of MPI processes for
best performance of one stream may be very different than for another.  Hence,
running multiple streams through one PyReshaper can lead to either a large number
of MPI processes sitting idle (with no time-series variables to write) or
not enough MPI processes to achieve optimal speed.

Using the PyReshaper from the Unix Command-Line
-----------------------------------------------

While the most flexible way of using the PyReshaper is from within
Python, as described above, it is also possible to run the PyReshaper
from the command-line. In this section, we describe how to use the
Python scripts ``s2smake`` and ``s2srun``, which provide command-line
interfaces (CLI) to the PyReshaper. (These scripts will be installed in the
``$PREFIX/bin`` directory, where ``PREFIX`` is the installation root
directory.)

The ``s2smake`` utility is designed to generate a Specifier object file
(*specfile*) that contains a Specifier that can be used in a PyReshaper run.
The ``s2srun`` utility is then used to run the PyReshaper with the newly
generated Specifier.  The *specfile* is a convenient way of saving Specifier
information for future use or reference.

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
and arguments specify all of the same input passed to the Specifier objects
in the examples of the previous section.  This script will create a 
Specifier object with the options passed via the command line, and it will
save this Specifier object in *specfile* called ``example.s2s``.

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

With the Specifier created and saved to file using the ``s2smake`` utility,
we can run the PyReshaper with this Specifier using the ``s2srun`` utility,
with all options and parameters specified on the command line.

::

    $ s2srun --serial --verbosity=2 example.s2s

The example above shows the execution, in serial, of the PyReshaper job 
specified by the ``example.s2s`` Specifier object file with a verbosity 
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

The Specifier object files, or *specfiles*, described above can be generated
from within Python, too.  These files are serialized instances of Specifier
objects, saved to a file.  The serializing tool assumed is Python's ``pickle``
library.  To generate your own *specfile* from within Python, do the following.

.. code:: py

    import pickle
    
    # Assume "spec" is an existing Specifier instance
    pickle.dump(spec, open("specfile.s2s", "wb"))

Similarly, a *specfile* can be read with the following Python code.

.. code:: py

    import pickle
    
    spec = pickle.load( open("specfile.s2s", "rb") )
    
Additional Arguments to the ``s2srun`` Script
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

While the basic options shown in the previous examples above are
sufficient for most purposes, two a options are available.

-  ``--limit``:  This command-line option can be used to set the 
   ``output_limit`` argument of the PyReshaper ``convert()`` function, 
   described previously.

-  ``--write_mode``: This command-line option can be used to set
   the ``wmode`` output file write mode parameter of the ``create_reshaper()``
   function, described previously.

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
