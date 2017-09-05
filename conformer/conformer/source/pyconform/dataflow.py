"""
Data Flow Classes and Functions

This module contains the classes and functions needed to define Data Flows.

A Data Flow is a directed acyclic graph (DAG) that describes the flow of data
from one node in the graph to another.  Each node in the flow represents a
data action of some sort, such as reading data from file, transposing data,
unit conversion, addition, subtraction, etc.  The data transmitted along the
graph edges is assumed to a Numpy.NDArray-like object.

The action associated with each node is not performed until the data is
"requested" with the __getitem__ interface, via Node[key].  

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from pyconform.datasets import InputDatasetDesc, OutputDatasetDesc, DefinitionWarning
from pyconform.parsing import parse_definition
from pyconform.parsing import ParsedVariable, ParsedFunction, ParsedUniOp, ParsedBinOp
from pyconform.functions import find_operator, find_function
from pyconform.physarray import PhysArray
from pyconform.flownodes import DataNode, ReadNode, EvalNode, iter_dfs
from pyconform.flownodes import MapNode, ValidateNode, WriteNode
from asaptools.simplecomm import create_comm, SimpleComm
from asaptools.partition import WeightBalanced
from warnings import warn

import numpy


#=======================================================================================================================
# VariableNotFoundError
#=======================================================================================================================
class VariableNotFoundError(ValueError):
    """Indicate if an input variable could not be found during construction"""


#===================================================================================================
# DataFlow
#===================================================================================================
class DataFlow(object):
    """
    An object describing the flow of data from input to output
    """

    def __init__(self, inpds, outds):
        """
        Initializer
        
        Parameters:
            inpds (InputDatasetDesc): The input dataset to use as reference when
                parsing variable definitions
            outds (OutputDatasetDesc): The output dataset defining the output variables and
                their definitions or data
        """
        # Input dataset
        if not isinstance(inpds, InputDatasetDesc):
            raise TypeError('Input dataset must be of InputDatasetDesc type')
        self._ids = inpds

        # Output dataset
        if not isinstance(outds, OutputDatasetDesc):
            raise TypeError('Output dataset must be of OutputDatasetDesc type')
        self._ods = outds

        # Create a dictionary of DataNodes from variables with non-string definitions
        datnodes = self._create_data_nodes_()

        # Create a dictionary to store FlowNodes for variables with string definitions
        defnodes = self._create_definition_nodes_(datnodes)

        # Compute the definition node info objects (zero-sized physarrays)
        definfos = self._compute_node_infos_(defnodes)
        
        # Construct the dimension map
        self._i2omap, self._o2imap = self._compute_dimension_maps_(definfos)
        
        # Create the map nodes
        defnodes = self._create_map_nodes_(defnodes, definfos)

        # Create the validate nodes for each valid output variable
        valnodes = self._create_validate_nodes_(datnodes, defnodes)
        
        # Get the set of all sum-like dimensions (dimensions that cannot be broken into chunks)
        self._sumlike_dimensions = self._find_sumlike_dimensions_(valnodes)

        # Create the WriteNodes for each time-series output file
        self._writenodes = self._create_write_nodes_(valnodes)

        # Compute the bytesizes of each output variable
        varsizes = self._compute_variable_sizes_(valnodes)

        # Compute the file sizes for each output file
        self._filesizes = self._compute_file_sizes(varsizes)

    def _create_data_nodes_(self):
        datnodes = {}
        for vname in self._ods.variables:
            vdesc = self._ods.variables[vname]
            if not isinstance(vdesc.definition, basestring):
                if vdesc.datatype == 'char':
                    vdata = numpy.asarray(vdesc.definition, dtype='S')
                else:
                    vdata = numpy.asarray(vdesc.definition, dtype=vdesc.dtype)
                vunits = vdesc.cfunits()
                vdims = vdesc.dimensions.keys()
                varray = PhysArray(vdata, name=vname, units=vunits, dimensions=vdims)
                datnodes[vname] = DataNode(varray)
        return datnodes

    def _create_definition_nodes_(self, datnodes):        
        defnodes = {}
        for vname in self._ods.variables:
            vdesc = self._ods.variables[vname]
            if isinstance(vdesc.definition, basestring):
                try:
                    vnode = self._construct_flow_(parse_definition(vdesc.definition), datnodes=datnodes)
                except VariableNotFoundError, err:
                    warn('{}. Skipping output variable {}.'.format(str(err), vname), DefinitionWarning)
                else:
                    defnodes[vname] = vnode
        return defnodes      

    def _construct_flow_(self, obj, datnodes={}):
        if isinstance(obj, ParsedVariable):
            vname = obj.key
            if vname in self._ids.variables:
                return ReadNode(self._ids.variables[vname], index=obj.args)

            elif vname in datnodes:
                return datnodes[vname]

            else:
                raise VariableNotFoundError('Input variable {!r} not found or cannot be used as input'.format(vname))

        elif isinstance(obj, (ParsedUniOp, ParsedBinOp)):
            name = obj.key
            nargs = len(obj.args)
            op = find_operator(name, numargs=nargs)
            args = [self._construct_flow_(arg, datnodes=datnodes) for arg in obj.args]
            return EvalNode(name, op, *args)

        elif isinstance(obj, ParsedFunction):
            name = obj.key
            func = find_function(name)
            args = [self._construct_flow_(arg, datnodes=datnodes) for arg in obj.args]
            kwds = {k:self._construct_flow_(obj.kwds[k], datnodes=datnodes) for k in obj.kwds}
            return EvalNode(name, func, *args, **kwds)

        else:
            return obj

    def _compute_node_infos_(self, nodes):
        # Gather information about each FlowNode's metadata (via empty PhysArrays)
        infos = {}
        for name in nodes:
            node = nodes[name] 
            try:
                info = node[None]
            except Exception, err:
                ndef = self._ods.variables[name].definition
                err_msg = 'Failure in variable {!r} with definition {!r}: {}'.format(name, ndef, str(err))
                raise RuntimeError(err_msg)
            else:
                infos[name] = info
        return infos
        
    def _compute_dimension_maps_(self, definfos):
        # Each output variable FlowNode must be mapped to its output dimensions.
        # To aid with this, we sort by number of dimensions:
        nodeorder = zip(*sorted((len(self._ods.variables[vname].dimensions), vname) for vname in definfos))[1]

        # Now, we construct the dimension maps
        i2omap = {}
        o2imap = {}
        for vname in nodeorder:
            out_dims = self._ods.variables[vname].dimensions.keys()
            inp_dims = definfos[vname].dimensions

            unmapped_out = tuple(d for d in out_dims if d not in o2imap)
            mapped_inp = tuple(o2imap[d] for d in out_dims if d in o2imap)
            unmapped_inp = tuple(d for d in inp_dims if d not in mapped_inp)

            if len(unmapped_out) != len(unmapped_inp):
                map_str = ', '.join('{}-->{}'.format(k, i2omap[k]) for k in i2omap)
                err_msg = ('Cannot map dimensions {} to dimensions {} in output variable {} '
                           '(MAP: {})').format(inp_dims, out_dims, vname, map_str)
                raise ValueError(err_msg)
            if len(unmapped_out) == 0:
                continue
            for out_dim, inp_dim in zip(unmapped_out, unmapped_inp):
                o2imap[out_dim] = inp_dim
                i2omap[inp_dim] = out_dim

        # Now that we know how dimensions are mapped, compute the output dimension sizes
        for dname, ddesc in self._ods.dimensions.iteritems():
            if dname in o2imap:
                idd = self._ids.dimensions[o2imap[dname]]
                if (ddesc.is_set() and ddesc.stringlen and ddesc.size < idd.size) or not ddesc.is_set():
                    ddesc.set(idd)
        
        return i2omap, o2imap

    @property
    def dimension_map(self):
        """The internally generated input-to-output dimension name map"""
        return self._i2omap

    def _create_map_nodes_(self, defnodes, definfos):
        mapnodes = {}
        for vname in defnodes:
            dnode = defnodes[vname]
            dinfo = definfos[vname]
            map_dims = tuple(self._i2omap[d] for d in dinfo.dimensions)
            name = 'map({!s}, to={})'.format(vname, map_dims)
            mapnodes[vname] = MapNode(name, dnode, self._i2omap)
        return mapnodes

    def _create_validate_nodes_(self, datnodes, defnodes):
        valid_vars = datnodes.keys() + defnodes.keys()          
        valnodes = {}
        for vname in valid_vars:
            vdesc = self._ods.variables[vname]
            vnode = datnodes[vname] if vname in datnodes else defnodes[vname]

            try:
                validnode = ValidateNode(vname, vnode, dimensions=vdesc.dimensions.keys(),
                                         attributes=vdesc.attributes, dtype=vdesc.dtype)
            except Exception, err:
                vdef = vdesc.definition
                err_msg = 'Failure in variable {!r} with definition {!r}: {}'.format(vname, vdef, str(err))
                raise RuntimeError(err_msg)

            valnodes[vname] = validnode
        return valnodes
    
    def _find_sumlike_dimensions_(self, valnodes):
        unmapped_sumlike_dimensions = set()
        for vname in valnodes:
            vnode = valnodes[vname]
            for nd in iter_dfs(vnode):
                if isinstance(nd, EvalNode):
                    unmapped_sumlike_dimensions.update(nd.sumlike_dimensions)
        
        # Map the sum-like dimensions to output dimensions
        return set(self._i2omap[d] for d in unmapped_sumlike_dimensions if d in self._i2omap)

    def _create_write_nodes_(self, valnodes):
        writenodes = {}
        for fname in self._ods.files:
            fdesc = self._ods.files[fname]
            vmissing = tuple(vname for vname in fdesc.variables if vname not in valnodes)
            if vmissing:
                warn('Skipping output file {} due to missing required variables: '
                     '{}'.format(fname, ', '.join(sorted(vmissing))), DefinitionWarning)
            else:
                vnodes = tuple(valnodes[vname] for vname in fdesc.variables)
                wnode = WriteNode(fdesc, inputs=vnodes)
                writenodes[wnode.label] = wnode
        return writenodes

    def _compute_variable_sizes_(self, valnodes):
        bytesizes = {}
        for vname in valnodes:
            vdesc = self._ods.variables[vname]
            vsize = sum(ddesc.size for ddesc in vdesc.dimensions.itervalues())
            vsize = 1 if vsize == 0 else vsize
            bytesizes[vname] = vsize * vdesc.dtype.itemsize
        return bytesizes
    
    def _compute_file_sizes(self, varsizes):
        filesizes = {}
        for fname, wnode in self._writenodes.iteritems():
            filesizes[fname] = sum(varsizes[vnode.label] for vnode in wnode.inputs)
        return filesizes

    def execute(self, chunks={}, serial=False, history=False, scomm=None, deflate=None):
        """
        Execute the Data Flow
        
        Parameters:
            chunks (dict): A dictionary of output dimension names and chunk sizes for each
                dimension given.  Output dimensions not included in the dictionary will not be
                chunked.  (Use OrderedDict to preserve order of dimensions, where the first
                dimension will be assumed to correspond to the fastest-varying index and the last
                dimension will be assumed to correspond to the slowest-varying index.)
            serial (bool): Whether to run in serial (True) or parallel (False)
            history (bool): Whether to write a history attribute generated during execution
                for each variable in the file
            scomm (SimpleComm): An externally created SimpleComm object to use for managing
                parallel operation
            deflate (int): Override all output file deflate levels with given value
        """
        # Check chunks type
        if not isinstance(chunks, dict):
            raise TypeError('Chunks must be specified with a dictionary')

        # Make sure that the specified chunking dimensions are valid
        for odname, odsize in chunks.iteritems():
            if odname not in self._o2imap:
                raise ValueError('Cannot chunk over unknown output dimension {!r}'.format(odname))
            if not isinstance(odsize, int):
                raise TypeError(('Chunk size invalid for output dimension {!r}: '
                                 '{}').format(odname, odsize))
        
        # Check that we are not chunking over any "sum-like" dimensions
        sumlike_chunk_dims = sorted(d for d in chunks if d in self._sumlike_dimensions)
        if len(sumlike_chunk_dims) > 0:
            raise ValueError(('Cannot chunk over dimensions that are summed over (or "sum-like")'
                              ': {}'.format(', '.join(sumlike_chunk_dims))))

        # Create the simple communicator, if necessary
        if scomm is None:
            scomm = create_comm(serial=bool(serial))
        elif isinstance(scomm, SimpleComm):
            if scomm.is_manager():
                print 'Inheriting SimpleComm object from parent.  (Ignoring serial argument.)'
        else:
            raise TypeError('Communication object is not a SimpleComm!')
        
        # Start general output
        prefix = '[{}/{}]'.format(scomm.get_rank(), scomm.get_size())
        if scomm.is_manager():
            print 'Beginning execution of data flow...'
            print 'Mapping Input Dimensions to Output Dimensions:'
            for d in sorted(self._i2omap):
                print '   {} --> {}'.format(d, self._i2omap[d])
            if len(chunks) > 0:
                print 'Chunking over Output Dimensions:'
                for d in chunks:
                    print '   {}: {}'.format(d, chunks[d])
            else:
                print 'Not chunking output.'

        # Partition the output files/variables over available parallel (MPI) ranks
        fnames = scomm.partition(self._filesizes.items(), func=WeightBalanced(), involved=True)
        if scomm.is_manager():
            print 'Writing {} files across {} MPI processes.'.format(len(self._filesizes), scomm.get_size())
        scomm.sync()

        # Standard output
        print '{}: Writing {} files: {}'.format(prefix, len(fnames), ', '.join(fnames))
        scomm.sync()
        
        # Loop over output files and write using given chunking
        for fname in fnames:
            print '{}: Writing file: {}'.format(prefix, fname)
            if history:
                self._writenodes[fname].enable_history()
            else:
                self._writenodes[fname].disable_history()
            self._writenodes[fname].execute(chunks=chunks, deflate=deflate)
            print '{}: Finished writing file: {}'.format(prefix, fname)

        scomm.sync()
        if scomm.is_manager():
            print 'All output variables written.'
            print
