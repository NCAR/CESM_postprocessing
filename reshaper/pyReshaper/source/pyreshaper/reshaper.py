"""
The module containing the Reshaper class

This is the main reshaper module.  This is where the specific operations
are defined.  Currently, only one operation has been implemented (i.e.,
the time-slice to time-series operation).

Copyright 2017, University Corporation for Atmospheric Research
See the LICENSE.rst file for details
"""

# Built-in imports
from sys import platform
from os import linesep, remove, rename, fstatvfs
from os import open as fdopen, close as fdclose, O_RDONLY, O_CREAT
from os.path import exists, isfile, isdir, join

# Third-party imports
import numpy
from asaptools.simplecomm import create_comm, SimpleComm
from asaptools.timekeeper import TimeKeeper
from asaptools.partition import WeightBalanced, EqualStride, Duplicate
from asaptools.vprinter import VPrinter

# PyReshaper imports
from specification import Specifier
import iobackend

# For memory diagnostics
from resource import getrusage, RUSAGE_SELF


#=========================================================================
# _get_memory_usage_MB_
#=========================================================================
def _get_memory_usage_MB_():
    """
    Return the maximum memory use of this Python process in MB
    """
    to_MB = 1024.
    if platform == 'darwin':
        to_MB *= to_MB
    return getrusage(RUSAGE_SELF).ru_maxrss / to_MB


#=========================================================================
# _get_io_blocksize_MB_
#=========================================================================
def _get_io_blocksize_MB_(pathname):
    """
    Return the I/O blocksize for a given path (used to estimate IOPS)
    """
    if isfile(pathname):
        fname = pathname
        fflag = O_RDONLY
    elif isdir(pathname):
        fname = join(pathname, '.bsize_test_file')
        fflag = O_CREAT
    else:
        return None
    fd = fdopen(fname, fflag)
    bsize = fstatvfs(fd).f_bsize
    fdclose(fd)
    return bsize


#=========================================================================
# create_reshaper factory function
#=========================================================================
def create_reshaper(specifier, serial=False, verbosity=1, wmode='w', once=False, simplecomm=None):
    """
    Factory function for Reshaper class instantiations.

    Parameters:
        specifier (Specifier): An instantiation of a Specifier class that
            defines the type of operation to be performed.  (That is, a
            Slice2SeriesSpecifier will invoke the creation of a
            matching Slice2SeriesReshaper object.)
            Alternatively, this can be a list of Specifier objects,
            or dictionary of named Specifier objects.
            In this case, a reshaper will be created for each
            specifier in the list, and each reshaper will be
            created and run in sequence.
        serial (bool): True or False, indicating whether the Reshaper object
            should perform its operation in serial (True) or
            parallel (False).
        verbosity (int): Level of printed output (stdout).  A value of 0 means
            no output, and a higher value means more output.  The
            default value is 1.
        wmode (str): The mode to use for writing output.  Can be 'w' for
            normal write operation, 's' to skip the output generation for
            existing time-series files, 'o' to overwrite existing time-series
            files, 'a' to append to existing time-series files.
        once (bool): True or False, indicating whether the Reshaper should
            write all metadata to a 'once' file (separately).
        simplecomm (SimpleComm): A SimpleComm object to handle the parallel
            communication, if necessary

    Returns:
        Reshaper: An instance of the Reshaper object requested
    """
    # Determine the type of Reshaper object to instantiate
    if isinstance(specifier, Specifier):
        return Reshaper(specifier, serial=serial, verbosity=verbosity, wmode=wmode, once=once, simplecomm=simplecomm)
    else:
        err_msg = 'Specifier of type {} is not a valid Specifier object.'.format(
            type(specifier))
        raise TypeError(err_msg)


#=========================================================================
# _pprint_dictionary - Helper method for printing diagnostic data
#=========================================================================
def _pprint_dictionary(title, dictionary, order=None):
    """
    Hidden method for pretty-printing a dictionary of numeric values, with a given title.

    Parameters:
        title (str): The title to give to the printed table
        dictionary (dict): A dictionary of numeric values
        order (list): The print order for the keys in the dictionary (only
            items that are in both the order list and the dictionary will be
            printed)

    Return:
        str: A string with the pretty-printed dictionary data
    """
    # Type checking
    if not isinstance(title, basestring):
        err_msg = 'Title must be a string type'
        raise TypeError(err_msg)
    if not isinstance(dictionary, dict):
        err_msg = 'Input dictionary needs to be a dictionary type'
        raise TypeError(err_msg)
    if order is not None and not isinstance(order, (tuple, list)):
        err_msg = 'Order list needs to be a list type'
        raise TypeError(err_msg)

    # Determine the print order, if present
    print_order = dictionary.keys()
    if (order is not None):
        print_order = []
        for item in order:
            if (item in dictionary):
                print_order.append(item)

    # Header line with Title
    hline = '-' * 50 + linesep
    ostr = hline + ' ' + title.upper() + ':' + linesep + hline

    # Determine the longest timer name
    # and thus computer the column to line up values
    valcol = 0
    for name in print_order:
        if (len(str(name)) > valcol):
            valcol = len(str(name))
    valcol += 2

    # Print out the timer names and the accumulated times
    for name in print_order:
        spacer = ' ' * (valcol - len(str(name)))
        ostr += str(name) + ':' + spacer
        ostr += str(dictionary[name]) + linesep
    ostr += hline

    return ostr


#=========================================================================
# Reshaper Base Class
#=========================================================================
class Reshaper(object):

    """
    The time-slice to time-series Reshaper class

    This is the class that defines how the time-slice to time-series
    reshaping operation is to be performed.
    """

    def __init__(self, specifier, serial=False, verbosity=1, wmode='w', once=False, simplecomm=None):
        """
        Constructor

        Parameters:
            specifier (Specifier): An instance of the Specifier class,
                defining the input specification for this reshaper operation.
            serial (bool): True or False, indicating whether the operation
                should be performed in serial (True) or parallel
                (False).  The default is to assume parallel operation
                (but serial will be chosen if the mpi4py cannot be
                found when trying to initialize decomposition.
            verbosity(int): Level of printed output (stdout).  A value of 0
                means no output, and a higher value means more output.  The
                default value is 1.
            wmode (str): The mode to use for writing output.  Can be 'w' for
                normal write operation, 's' to skip the output generation for
                existing time-series files, 'o' to overwrite existing
                time-series files, 'a' to append to existing time-series files.
            once (bool): True or False, indicating whether the Reshaper should
                write all metadata to a 'once' file (separately).
            simplecomm (SimpleComm): A SimpleComm object to handle the parallel
                communication, if necessary
        """

        # Type checking (or double-checking)
        if not isinstance(specifier, Specifier):
            err_msg = "Input must be given in the form of a Specifier object"
            raise TypeError(err_msg)
        if type(serial) is not bool:
            err_msg = "Serial indicator must be True or False."
            raise TypeError(err_msg)
        if type(verbosity) is not int:
            err_msg = "Verbosity level must be an integer."
            raise TypeError(err_msg)
        if type(wmode) is not str:
            err_msg = "Write mode flag must be a str."
            raise TypeError(err_msg)
        if type(once) is not bool:
            err_msg = "Once-file indicator must be True or False."
            raise TypeError(err_msg)
        if simplecomm is not None:
            if not isinstance(simplecomm, SimpleComm):
                err_msg = "Simple communicator object is not a SimpleComm"
                raise TypeError(err_msg)
        if wmode not in ['w', 's', 'o', 'a']:
            err_msg = "Write mode '{0}' not recognized".format(wmode)
            raise ValueError(err_msg)

        # Whether to write a once file
        self._use_once_file = once

        # The output write mode to use
        self._write_mode = wmode

        # Internal timer data
        self._timer = TimeKeeper()

        self._timer.start('Initializing Simple Communicator')
        if simplecomm is None:
            simplecomm = create_comm(serial=serial)

        # Reference to the simple communicator
        self._simplecomm = simplecomm
        self._timer.stop('Initializing Simple Communicator')

        # Dictionary storing read/write data amounts
        self.assumed_block_size = float(4 * 1024 * 1024)
        self._byte_counts = {}

        # Contruct the print header
        header = ''.join(['[', str(self._simplecomm.get_rank()),
                          '/', str(self._simplecomm.get_size()), '] '])

        # Reference to the verbose printer tool
        self._vprint = VPrinter(header=header, verbosity=verbosity)

        # Debug output starting
        if self._simplecomm.is_manager():
            self._vprint('Initializing Reshaper...', verbosity=0)
            self._vprint('  MPI Communicator Size: {}'.format(
                self._simplecomm.get_size()), verbosity=1)

        # Validate the user input data
        self._timer.start('Specifier Validation')
        specifier.validate()
        self._timer.stop('Specifier Validation')
        if self._simplecomm.is_manager():
            self._vprint('  Specifier validated', verbosity=1)

        # The I/O backend to use
        if iobackend.is_available(specifier.io_backend):
            self._backend = specifier.io_backend
        else:
            self._backend = iobackend.get_backend()
            self._vprint(('  I/O Backend {0} not available.  Using {1} '
                          'instead').format(specifier.io_backend, self._backend), verbosity=1)

        # Store the input file names
        self._input_filenames = specifier.input_file_list

        # Store the time-series variable names
        self._time_series_names = specifier.time_series
        if self._time_series_names is not None:
            vnames = ', '.join(self._time_series_names)
            if self._simplecomm.is_manager():
                self._vprint('WARNING: Extracting only variables: {0}'.format(
                    vnames), verbosity=-1)

        # Store the list of metadata names
        self._metadata_names = specifier.time_variant_metadata

        # Store whether to treat 1D time-variant variables as metadata
        self._1d_metadata = specifier.assume_1d_time_variant_metadata

        # Store the metadata filename
        self._metadata_filename = specifier.metadata_filename

        # Store time invariant variables that should be excluded from the timeseries files
        self._exclude_list = specifier.exclude_list

        # Store the output file prefix and suffix
        self._output_prefix = specifier.output_file_prefix
        self._output_suffix = specifier.output_file_suffix

        # Setup NetCDF file options
        self._netcdf_format = specifier.netcdf_format
        self._netcdf_compression = specifier.compression_level
        self._netcdf_least_significant_digit = specifier.least_significant_digit
        if self._simplecomm.is_manager():
            self._vprint(
                '  NetCDF I/O Backend: {0}'.format(self._backend), verbosity=1)
            self._vprint('  NetCDF Output Format: {0}'.format(
                self._netcdf_format), verbosity=1)
            self._vprint('  NetCDF Compression: {0}'.format(
                self._netcdf_compression), verbosity=1)
            trunc_str = ('{} decimal places'.format(self._netcdf_least_significant_digit)
                         if self._netcdf_least_significant_digit else 'Disabled')
            self._vprint('  NetCDF Truncation: {0}'.format(
                trunc_str), verbosity=1)

        # Helpful debugging message
        if self._simplecomm.is_manager():
            self._vprint('...Reshaper initialized.', verbosity=0)

        # Sync before continuing..
        self._simplecomm.sync()

    def _inspect_input_files(self):
        """
        Inspect the input data files themselves.

        We check the file contents here, which means opening and reading heading information from the files.
        """
        # Set the I/O backend according to what is specified
        iobackend.set_backend(self._backend)

        # Initialize the list of variable names for each category
        udim = None
        timeta = []
        xtra_timeta = []
        tvmeta = []

        # Initialize the local dictionary of time-series variables and sizes
        all_tsvars = {}
        file_times = {}

        #===== INSPECT FIRST INPUT FILE (ON MASTER PROCESS ONLY) =====

        # Open first file
        if self._simplecomm.is_manager():
            ifile = iobackend.NCFile(self._input_filenames[0])

            # Look for the 'unlimited' dimension
            try:
                udim = next(
                    dim for dim in ifile.dimensions if ifile.unlimited(dim))
            except StopIteration:
                err_msg = 'Unlimited dimension not found.'
                raise LookupError(err_msg)

            # Get the first file's time values
            file_times[self._input_filenames[0]] = ifile.variables[udim][:]

            # Categorize each variable (only looking at first file)
            for var_name, var in ifile.variables.iteritems():
                if udim not in var.dimensions:
                    if var_name not in self._exclude_list:
                        timeta.append(var_name)
                elif var_name in self._metadata_names or (self._1d_metadata and len(var.dimensions) == 1):
                    tvmeta.append(var_name)
                elif self._time_series_names is None or var_name in self._time_series_names:
                    all_tsvars[var_name] = var.datatype.itemsize * var.size

            # Close the first file
            ifile.close()

            # Find variables only in the metadata file
            if self._metadata_filename is not None:
                ifile = iobackend.NCFile(self._metadata_filename)
                for var_name, var in ifile.variables.iteritems():
                    if udim not in var.dimensions and var_name not in timeta:
                        xtra_timeta.append(var_name)
                ifile.close()

        self._simplecomm.sync()

        # Send information to worker processes
        self._unlimited_dim = self._simplecomm.partition(
            udim, func=Duplicate(), involved=True)
        self._time_invariant_metadata = self._simplecomm.partition(
            timeta, func=Duplicate(), involved=True)
        self._time_invariant_metafile_vars = self._simplecomm.partition(
            xtra_timeta, func=Duplicate(), involved=True)
        self._time_variant_metadata = self._simplecomm.partition(
            tvmeta, func=Duplicate(), involved=True)
        all_tsvars = self._simplecomm.partition(
            all_tsvars, func=Duplicate(), involved=True)

        self._simplecomm.sync()
        if self._simplecomm.is_manager():
            self._vprint('  First input file inspected.', verbosity=2)

        #===== INSPECT REMAINING INPUT FILES (IN PARALLEL) =====

        # Get the list of variable names and missing variables
        var_names = set(
            all_tsvars.keys() + self._time_invariant_metadata +
            self._time_invariant_metafile_vars + self._time_variant_metadata)
        missing_vars = set()

        # Partition the remaining filenames to inspect
        input_filenames = self._simplecomm.partition(
            self._input_filenames[1:], func=EqualStride(), involved=True)

        # Make a pass through remaining files and:
        # (1) Make sure it has the 'unlimited' dimension
        # (2) Make sure this dimension is truely 'unlimited'
        # (3) Check that this dimension has a corresponding variable
        # (4) Check if there are any missing variables
        # (5) Get the time values from the files
        for ifilename in input_filenames:
            ifile = iobackend.NCFile(ifilename)

            # Determine the unlimited dimension
            if self._unlimited_dim not in ifile.dimensions:
                err_msg = 'Unlimited dimension not found in file "{0}"'.format(
                    ifilename)
                raise LookupError(err_msg)
            if not ifile.unlimited(self._unlimited_dim):
                err_msg = 'Dimension "{0}" not unlimited in file "{1}"'.format(
                    self._unlimited_dim, ifilename)
                raise LookupError(err_msg)
            if self._unlimited_dim not in ifile.variables:
                err_msg = 'Unlimited dimension variable not found in file "{0}"'.format(
                    ifilename)
                raise LookupError(err_msg)

            # Get the time values (list of NDArrays)
            file_times[ifilename] = ifile.variables[self._unlimited_dim][:]

            # Get the missing variables
            var_names_next = set(ifile.variables.keys())
            missing_vars.update(var_names - var_names_next)

            # Close the file
            ifile.close()

        self._simplecomm.sync()
        if self._simplecomm.is_manager():
            self._vprint('  Remaining input files inspected.', verbosity=2)

        #===== CHECK FOR MISSING VARIABLES =====

        # Gather all missing variables on the master process
        if self._simplecomm.get_size() > 1:
            if self._simplecomm.is_manager():
                for _ in range(1, self._simplecomm.get_size()):
                    missing_vars.update(self._simplecomm.collect()[1])
            else:
                self._simplecomm.collect(missing_vars)
        self._simplecomm.sync()

        # Check for missing variables only on master process
        if self._simplecomm.is_manager():

            # Remove metafile variables from missing vars set
            missing_vars -= set(self._time_invariant_metafile_vars)

            # Make sure that the list of variables in each file is the same
            if len(missing_vars) != 0:
                warning = ("WARNING: Some variables are not in all input files:{0}   "
                           "{1}").format(linesep, ', '.join(sorted(missing_vars)))
                self._vprint(warning, header=False, verbosity=0)

            self._vprint('  Checked for missing variables.', verbosity=2)

        #===== SORT INPUT FILES BY TIME =====

        # Gather the file time values onto the master process
        if self._simplecomm.get_size() > 1:
            if self._simplecomm.is_manager():
                for _ in range(1, self._simplecomm.get_size()):
                    file_times.update(self._simplecomm.collect()[1])
            else:
                self._simplecomm.collect(file_times)
        self._simplecomm.sync()

        # Check the order of the input files based on the time values
        if self._simplecomm.is_manager():

            # Determine the sort order based on the first time in the time
            # values
            old_order = range(len(self._input_filenames))
            new_order = sorted(
                old_order, key=lambda i: file_times[self._input_filenames[i]][0])

            # Re-order the list of input filenames and time values
            new_filenames = [self._input_filenames[i] for i in new_order]
            new_values = [file_times[self._input_filenames[i]]
                          for i in new_order]

            # Now, check that the largest time in each file is less than the smallest time
            # in the next file (so that the time spans of each file do not
            # overlap)
            for i in xrange(1, len(new_values)):
                if new_values[i - 1][-1] >= new_values[i][0]:
                    err_msg = ('Times in input files {0} and {1} appear to '
                               'overlap').format(new_filenames[i - 1], new_filenames[i])
                    raise ValueError(err_msg)

        else:
            new_filenames = None

        # Now that this is validated, save the time values and filename in the
        # new order
        self._input_filenames = self._simplecomm.partition(
            new_filenames, func=Duplicate(), involved=True)

        if self._simplecomm.is_manager():
            self._vprint('  Input files sorted by time.', verbosity=2)

        #===== FINALIZING OUTPUT =====
        self._simplecomm.sync()

        # Debug output
        if self._simplecomm.is_manager():
            self._vprint('  Time-Invariant Metadata: {0}'.format(
                ', '.join(self._time_invariant_metadata)), verbosity=1)
            if len(self._time_invariant_metafile_vars) > 0:
                self._vprint('  Additional Time-Invariant Metadata: {0}'.format(
                    ', '.join(self._time_invariant_metafile_vars)), verbosity=1)
            self._vprint('  Time-Variant Metadata: {0}'.format(
                ', '.join(self._time_variant_metadata)), verbosity=1)
            self._vprint(
                '  Time-Series Variables: {0}'.format(', '.join(all_tsvars.keys())), verbosity=1)

        # Add 'once' variable if writing to a once file
        # NOTE: This is a "cheat"!  There is no 'once' variable.  It's just
        #       a catch for all metadata IFF the 'once-file' is enabled.
        if self._use_once_file:
            all_tsvars['once'] = max(all_tsvars.values())

        # Partition the time-series variables across processors
        self._time_series_variables = self._simplecomm.partition(
            all_tsvars.items(), func=WeightBalanced(), involved=True)

    def _inspect_output_files(self):
        """
        Perform inspection of the output data files themselves.

        We compute the output file name from the prefix and suffix, and then
        we check whether the output files exist.  By default, if the output
        file exists, then the job is stopped.
        """
        iobackend.set_backend(self._backend)

        # Loop through the time-series variables and generate output filenames
        self._time_series_filenames = \
            dict([(variable, self._output_prefix + variable + self._output_suffix)
                  for variable in self._time_series_variables])

        # Find which files already exist
        self._existing = [v for (v, f) in self._time_series_filenames.iteritems()
                          if isfile(f)]

        # Set the starting step index for each variable
        self._time_series_step_index = dict([(variable, 0) for variable in
                                             self._time_series_variables])

        # If overwrite is enabled, delete all existing files first
        if self._write_mode == 'o':
            if self._simplecomm.is_manager() and len(self._existing) > 0:
                self._vprint('WARNING: Deleting existing output files for time-series '
                             'variables: {0}'.format(', '.join(sorted(self._existing))), verbosity=0)
            for variable in self._existing:
                remove(self._time_series_filenames[variable])
            self._existing = []

        # Or, if skip existing is set, remove the existing time-series
        # variables from the list of time-series variables to convert
        elif self._write_mode == 's':
            if self._simplecomm.is_manager() and len(self._existing) > 0:
                self._vprint('WARNING: Skipping time-series variables with '
                             'existing output files: {0}'.format(', '.join(sorted(self._existing))), verbosity=0)
            for variable in self._existing:
                self._time_series_variables.remove(variable)

        # Or, if appending, check that the existing output files conform
        # to the expected pattern
        elif self._write_mode == 'a':

            # Check each existing time-series file
            for variable in self._existing:

                # Get the matching filename
                filename = self._time_series_filenames[variable]

                # Open the time-series file for inspection
                tsfile = iobackend.NCFile(filename)

                # Check that the file has the unlimited dim and var
                if not tsfile.unlimited(self._unlimited_dim):
                    err_msg = ('Cannot append to time-series file with missing unlimited '
                               'dimension {0!r}').format(self._unlimited_dim)
                    raise RuntimeError(err_msg)

                # Check for once file
                is_once_file = (variable == 'once')
                needs_meta_data = not (
                    self._use_once_file and not is_once_file)
                needs_tser_data = not (self._use_once_file and is_once_file)

                # Look for metadata
                if needs_meta_data:

                    # Check that the time-variant metadata are all present
                    for metavar in self._time_variant_metadata:
                        if metavar not in tsfile.variables:
                            err_msg = ("Cannot append to time-series file with missing time-variant metadata "
                                       "'{0}'").format(metavar)
                            raise RuntimeError(err_msg)

                # Check that the time-series variable is present
                if needs_tser_data and variable not in tsfile.variables:
                    err_msg = ("Cannot append to time-series file with missing time-series variable "
                               "'{0}'").format(variable)
                    raise RuntimeError(err_msg)

                # Get the starting step index to start writing from
                self._time_series_step_index[variable] = tsfile.dimensions[self._unlimited_dim]

                # Close the time-series file
                tsfile.close()

        # Otherwise, throw an exception if any existing output files are found
        elif len(self._existing) > 0:
            err_msg = "Found existing output files for time-series variables: {0}".format(
                ', '.join(sorted(self._existing)))
            raise RuntimeError(err_msg)

    def _create_var(self, in_file, out_file, vname, chunks=None):
        in_var = in_file.variables[vname]
        fill_value = in_var.fill_value
        if in_var.chunk_sizes is not None and chunks is not None:
            chunksizes = [chunks[d] if d in chunks else c
                          for d, c in zip(in_var.dimensions, in_var.chunk_sizes)]
        else:
            chunksizes = None
        out_var = out_file.create_variable(
            vname, in_var.datatype, in_var.dimensions, fill_value=fill_value, chunksizes=chunksizes)
        for att_name in in_var.ncattrs:
            att_value = in_var.getncattr(att_name)
            out_var.setncattr(att_name, att_value)

    def _chunk_iter(self, vobj, chunks={}, corder=True):
        """
        This is a generator function to iterator over chunks of arrays with named dimensions

        Parameters:
            vobj: A NetCDF file variable object with dimensions and shape attributes
            chunks (dict): A dictionary of dimension names mapped to chunk sizes along that
                named dimension
            corder (bool): Whether to assume the array has C-style axis ordering, where the
                fastest changing dimension is assumed to be the first axis.  If False, then
                the fastest changing dimension is assumed to be the last.
        """
        dimensions = vobj.dimensions
        shape = vobj.shape

        nchunks = 1
        dchunks = []
        for dname, dlen in zip(dimensions, shape):
            if dname in chunks:
                clen = chunks[dname]
                cnum = dlen // clen
                if dlen % clen > 0:
                    cnum += 1
                nchunks *= cnum
            else:
                clen = dlen
                cnum = 1
            dchunks.append((dlen, clen, cnum))

        for n in xrange(nchunks):
            cidx = []
            nidx = n
            nstride = nchunks
            if corder:
                diter = reversed(dchunks)
            else:
                diter = iter(dchunks)
            for dlen, clen, cnum in diter:
                nstride = nstride // cnum
                cidx.append(nidx // nstride)
                nidx = nidx % nstride
            if corder:
                cidx.reverse()

            cslice = []
            for d in xrange(len(shape)):
                ic = cidx[d]
                dlen, clen, cnum = dchunks[d]

                ibeg = ic * clen
                iend = (ic + 1) * clen
                if iend >= dlen:
                    iend = dlen

                cslice.append(slice(ibeg, iend))

            yield tuple(cslice)

    def _offset_chunk(self, chunk, vobj, offset):
        """
        Compute a new chunk/slice for a variable with a given offset

        Parameters:
            chunk (tuple): A tuple of slices across each dimension
            vobj: A NetCDF file variable object with dimensions and shape attributes
            offset (dict): Offsets for each dimension (if any)

        Returns:
            tuple: A tuple of slices across each dimension with offsets added
        """
        new_chunk = []
        for i, d in enumerate(vobj.dimensions):
            if d in offset:
                o = offset[d]
            else:
                o = 0
            new_chunk.append(slice(chunk[i].start + o, chunk[i].stop + o))
        return tuple(new_chunk)

    def _copy_var(self, kind, in_var, out_var, chunks={}, offsets={}):
        """
        Copy variable data from one variable object to another via chunking

        Parameters:
            kind (str): A string describing the kind of variable being copied
            in_var: A NetCDF variable object to read data from
            out_var: A NetCDF variable object to write data to
            chunks (dict): A dictionary of dimension names mapped to chunk sizes along that named dimension
            offsets (dict): Integer offsets along each dimension
        """
        for rslice in self._chunk_iter(in_var, chunks=chunks):

            self._timer.start('Read {0}'.format(kind))
            tmp_data = in_var[rslice]
            self._timer.stop('Read {0}'.format(kind))
            wslice = self._offset_chunk(rslice, out_var, offsets)
            self._timer.start('Write {0}'.format(kind))
            out_var[wslice] = tmp_data
            self._timer.stop('Write {0}'.format(kind))

            requested_nbytes = tmp_data.nbytes if hasattr(
                tmp_data, 'nbytes') else 0
            self._byte_counts['Requested Data'] += requested_nbytes
            actual_nbytes = (self.assumed_block_size *
                             numpy.ceil(requested_nbytes / self.assumed_block_size))
            self._byte_counts['Actual Data'] += actual_nbytes

    def convert(self, output_limit=0, rchunks=None, wchunks=None):
        """
        Method to perform the Reshaper's designated operation.

        In this case, convert a list of time-slice files to time-series files.

        Parameters:
            output_limit (int): Limit on the number of output (time-series) files to write during the
                convert() operation.  If set to 0, no limit is placed.  This limits the number of output files
                produced by each processor in a parallel run.
            rchunks (dict): A dictionary of dimension names mapped to reading chunk sizes along that named
                dimension
            wchunks (dict): A dictionary of dimension names mapped to writing chunk sizes along that named
                dimension
        """
        iobackend.set_backend(self._backend)

        # Type checking input
        if type(output_limit) is not int:
            err_msg = 'Output limit must be an integer'
            raise TypeError(err_msg)

        # Start the total convert process timer
        self._timer.start('Complete Conversion Process')

        # Validate the input files themselves
        if self._simplecomm.is_manager():
            self._vprint('Inspecting input files...', verbosity=0)
        self._timer.start('Inspect Input Files')
        self._inspect_input_files()
        self._timer.stop('Inspect Input Files')
        if self._simplecomm.is_manager():
            self._vprint('...Input files inspected.', verbosity=0)

        # Validate the output files
        if self._simplecomm.is_manager():
            self._vprint('Inspecting output files...', verbosity=0)
        self._timer.start('Inspect Output Files')
        self._inspect_output_files()
        self._timer.stop('Inspect Output Files')
        if self._simplecomm.is_manager():
            self._vprint('...Output files inspected.', verbosity=0)

        # Check the read chunking
        if rchunks is None:
            # Default chunking is over 1 time-step at a time
            rchunks = {self._unlimited_dim: 1}
        if not isinstance(rchunks, dict):
            err_msg = 'Chunks must be specified with a dictionary'
            raise TypeError(err_msg)
        for key, value in rchunks.iteritems():
            if not isinstance(key, basestring):
                err_msg = 'Chunks dictionary must have string-type keys'
                raise TypeError(err_msg)
            if not isinstance(value, int):
                err_msg = 'Chunks dictionary must have integer chunk sizes'
                raise TypeError(err_msg)

        # Debugging output
        if self._simplecomm.is_manager():
            if len(rchunks) > 0:
                self._vprint('Read chunk sizes:', verbosity=1)
                for dname in rchunks:
                    self._vprint('  {!s}: {}'.format(
                        dname, rchunks[dname]), verbosity=1)
            else:
                self._vprint('No read chunking specified.', verbosity=1)
            self._vprint(
                'Converting time-slices to time-series...', verbosity=0)
        self._simplecomm.sync()

        # Partition the time-series variables across all processors
        tsv_names_loc = self._time_series_variables
        if output_limit > 0:
            tsv_names_loc = tsv_names_loc[0:output_limit]

        # Print partitions for all ranks
        dbg_msg = 'Converting time-series variables: {0}'.format(
            ', '.join(tsv_names_loc))
        self._vprint(dbg_msg, header=True, verbosity=1)

        # Reset all of the timer values (as it is possible that there are no
        # time-series variables in the local list procuded above)
        self._timer.reset('Open Output Files')
        self._timer.reset('Close Output Files')
        self._timer.reset('Open Input Files')
        self._timer.reset('Close Input Files')
        self._timer.reset('Create Time-Invariant Metadata')
        self._timer.reset('Create Time-Variant Metadata')
        self._timer.reset('Create Time-Series Variables')
        self._timer.reset('Read Time-Invariant Metadata')
        self._timer.reset('Read Time-Variant Metadata')
        self._timer.reset('Read Time-Series Variables')
        self._timer.reset('Write Time-Invariant Metadata')
        self._timer.reset('Write Time-Variant Metadata')
        self._timer.reset('Write Time-Series Variables')

        # Initialize the byte count dictionary
        self._byte_counts['Requested Data'] = 0
        self._byte_counts['Actual Data'] = 0

        #===== LOOP OVER TIME_SERIES VARIABLES =====

        if len(self._time_invariant_metafile_vars) > 0:
            metafile = iobackend.NCFile(self._metadata_filename)
        else:
            metafile = None

        # Loop over all time-series variables
        for out_name in tsv_names_loc:

            # Once-file data, for convenience
            is_once_file = (out_name == 'once')
            write_meta_data = not (self._use_once_file and not is_once_file)
            write_tser_data = not (self._use_once_file and is_once_file)

            # Determine the output file name for this variable
            out_filename = self._time_series_filenames[out_name]
            dbg_msg = 'Opening output file for variable: {0}'.format(out_name)
            if out_name == 'once':
                dbg_msg = 'Opening "once" file.'
            self._vprint(dbg_msg, header=True, verbosity=1)

            # Open the output file
            self._timer.start('Open Output Files')
            temp_filename = out_filename + '_temp_.nc'
            if exists(temp_filename):
                remove(temp_filename)
            if self._write_mode == 'a' and out_name in self._existing:
                rename(out_filename, temp_filename)
                out_file = iobackend.NCFile(temp_filename, mode='a',
                                            ncfmt=self._netcdf_format,
                                            compression=self._netcdf_compression,
                                            least_significant_digit=self._netcdf_least_significant_digit)
                appending = True
            else:
                out_file = iobackend.NCFile(temp_filename, mode='w',
                                            ncfmt=self._netcdf_format,
                                            compression=self._netcdf_compression,
                                            least_significant_digit=self._netcdf_least_significant_digit)
                appending = False
            self._timer.stop('Open Output Files')

            # Start the loop over input files (i.e., time-slices)
            offsets = {
                self._unlimited_dim: self._time_series_step_index[out_name]}
            for in_filename in self._input_filenames:

                # Open the input file (and metadata file, if necessary)
                self._timer.start('Open Input Files')
                in_file = iobackend.NCFile(in_filename)
                self._timer.stop('Open Input Files')

                # Create header info, if this is the first input file
                if in_filename == self._input_filenames[0] and not appending:

                    # Copy file attributes and dimensions to output file
                    for name in in_file.ncattrs:
                        out_file.setncattr(name, in_file.getncattr(name))
                    for name, val in in_file.dimensions.iteritems():
                        if name == self._unlimited_dim:
                            out_file.create_dimension(name)
                        else:
                            out_file.create_dimension(name, val)

                    # Create the metadata variables
                    if write_meta_data:

                        # Time-invariant metadata variables
                        self._timer.start('Create Time-Invariant Metadata')
                        for name in self._time_invariant_metadata:
                            self._create_var(in_file, out_file, name)
                        for name in self._time_invariant_metafile_vars:
                            self._create_var(metafile, out_file, name)
                        self._timer.stop('Create Time-Invariant Metadata')

                        # Time-variant metadata variables
                        self._timer.start('Create Time-Variant Metadata')
                        for name in self._time_variant_metadata:
                            self._create_var(in_file, out_file, name)
                        self._timer.stop('Create Time-Variant Metadata')

                    # Create the time-series variable
                    if write_tser_data:

                        # Time-series variable
                        self._timer.start('Create Time-Series Variables')
                        self._create_var(in_file, out_file,
                                         out_name, chunks=wchunks)
                        self._timer.stop('Create Time-Series Variables')

                    dbg_msg = 'Writing output file for variable: {0}'.format(
                        out_name)
                    if out_name == 'once':
                        dbg_msg = 'Writing "once" file.'
                    self._vprint(dbg_msg, header=True, verbosity=1)

                    # Copy the time-invariant metadata
                    if write_meta_data:
                        for name in self._time_invariant_metadata:
                            in_var = in_file.variables[name]
                            out_var = out_file.variables[name]
                            self._copy_var('Time-Invariant Metadata',
                                           in_var, out_var, chunks=rchunks)
                        for name in self._time_invariant_metafile_vars:
                            in_var = metafile.variables[name]
                            out_var = out_file.variables[name]
                            self._copy_var('Time-Invariant Metadata',
                                           in_var, out_var, chunks=rchunks)

                # Copy the time-varient metadata
                if write_meta_data:
                    for name in self._time_variant_metadata:
                        in_var = in_file.variables[name]
                        out_var = out_file.variables[name]
                        self._copy_var('Time-Variant Metadata', in_var,
                                       out_var, chunks=rchunks, offsets=offsets)

                # Copy the time-series variables
                if write_tser_data:
                    in_var = in_file.variables[out_name]
                    out_var = out_file.variables[out_name]
                    self._copy_var('Time-Series Variables', in_var,
                                   out_var, chunks=rchunks, offsets=offsets)

                # Increment the time-series index offset
                offsets[self._unlimited_dim] += in_file.dimensions[self._unlimited_dim]

                # Close the input file
                self._timer.start('Close Input Files')
                in_file.close()
                self._timer.stop('Close Input Files')

            # Close the output file
            self._timer.start('Close Output Files')
            out_file.close()
            rename(temp_filename, out_filename)
            self._timer.stop('Close Output Files')

            # Output message to user
            dbg_msg = 'Closed output file for variable: {0}'.format(out_name)
            if out_name == 'once':
                dbg_msg = 'Closed "once" file.'
            self._vprint(dbg_msg, header=True, verbosity=1)

        # Close the metadata file, if necessary
        if metafile:
            metafile.close()

        # Information
        self._simplecomm.sync()
        if self._simplecomm.is_manager():
            self._vprint(
                '...Finished converting time-slices to time-series.', verbosity=0)

        # Finish clocking the entire convert procedure
        self._timer.stop('Complete Conversion Process')

    def print_diagnostics(self):
        """
        Print out timing and I/O information collected up to this point
        """

        # Get all totals and maxima
        my_times = self._timer.get_all_times()
        max_times = self._simplecomm.allreduce(my_times, op='max')
        my_memory = {'Maximum Memory Use': _get_memory_usage_MB_()}
        max_memory = self._simplecomm.allreduce(my_memory, op='max')
        my_bytes = self._byte_counts
        total_bytes = self._simplecomm.allreduce(my_bytes, op='sum')

        # Synchronize
        self._simplecomm.sync()

        # Print timing maxima
        o = self._timer.get_names()
        time_table_str = _pprint_dictionary('TIMING DATA', max_times, order=o)
        if self._simplecomm.is_manager():
            self._vprint(time_table_str, verbosity=-1)

        # Convert byte count to MB
        for name in total_bytes:
            total_bytes[name] = total_bytes[name] / float(1024 * 1024)

        # Print byte count totals
        byte_count_str = _pprint_dictionary('BYTE COUNTS (MB)', total_bytes)
        if self._simplecomm.is_manager():
            self._vprint(byte_count_str, verbosity=-1)

        # Print maximum memory use in MB
        memory_str = _pprint_dictionary('MEMORY USAGE (MB)', max_memory)
        if self._simplecomm.is_manager():
            self._vprint(memory_str, verbosity=-1)
