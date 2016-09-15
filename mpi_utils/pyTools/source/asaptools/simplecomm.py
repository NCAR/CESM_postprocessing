"""
A module for simple MPI communication.

The SimpleComm class is designed to provide a simplified MPI-based
communication strategy using the MPI4Py module.

To accomplish this task, the SimpleComm object provides a single communication
pattern with a simple, light-weight API.  The communication pattern is a
common 'manager'/'worker' pattern, with the 0th rank assumed to be the
'manager' rank.  The SimpleComm API provides a way of sending data out from the
'manager' rank to the 'worker' ranks, and for collecting the data from the
'worker' ranks back on the 'manager' rank.

**PARTITIONING:**

Within the SimpleComm paradigm, the 'manager' rank is assumed to be responsible
for partition (or distributing) the necessary work to the 'worker' ranks.
The *partition* mathod provides this functionality.  Using a *partition
function*, the *partition* method takes data known on the 'manager' rank and
gives each 'worker' rank a part of the data according to the algorithm of the
partition function.

The *partition* method is *synchronous*, meaning that every rank (from the
'manager' rank to all of the 'worker' ranks) must be in synch when the method
is called.  This means that every rank must participate in the call, and
every rank will wait until all of the data has been partitioned before
continuing.  Remember, whenever the 'manager' rank speaks, all of the
'worker' ranks listen!  And they continue to listen until dismissed by the
'manager' rank.

Additionally, the 'manager' rank can be considered *involved* or *uninvolved*
in the partition process.  If the 'manager' rank is *involved*, then the
master will take a part of the data for itself.  If the 'manager' is
*uninvolved*, then the data will be partitioned only across the 'worker' ranks.

*Partitioning* is a *synchronous* communication call that implements a
*static partitioning* algorithm.

**RATIONING:**

An alternative approach to the *partitioning* communication method is the
*rationing* communication method.  This method involves the individual
'worker' ranks requesting data to work on.  In this approach, each 'worker'
rank, when the 'worker' rank is ready, asks the 'manager' rank for a new
piece of data on which to work.  The 'manager' rank receives the request
and gives the next piece of data for processing out to the requesting
'worker' rank.  It doesn't matter what order the ranks request data, and
they do not all have to request data at the same time.  However, it is
critical to understand that if a 'worker' requests data when the 'manager'
rank does not listen for the request, or the 'manager' expects a 'worker'
to request work but the 'worker' never makes the request, the entire
process will hang and wait forever!

*Rationing* is an *asynchronous* communication call that allows the 'manager'
to implement a *dynamic partitioning* algorithm.

**COLLECTING:**

Once each 'worker' has received its assigned part of the data, the 'worker'
will perform some work pertaining to the data it received.  In such a case,
the 'worker' may (though not necessarily) return one or more results back to
the 'manager'.  The *collect* method provides this functionality.

The *collect* method is *asynchronous*, meaning that each slave can send
its data back to the master at any time and in any order.  Since the 'manager'
rank does not care where the data came from, the 'manager' rank simply receives
the result from the 'worker' rank and processes it.  Hence, all that matters
is that for every *collect* call made by all of the 'worker' ranks, a *collect*
call must also be made by the 'manager' rank.

The *collect* method is a *handshake* method, meaning that while the 'manager'
rank doesn't care which 'worker' rank sends it data, the 'manager' rank does
acknowledge the 'worker' rank and record the 'worker' rank's identity.

**REDUCING:**

In general, it is assumed that each 'worker' rank works independently from the
other 'worker' ranks.  However, it may be occasionally necessary for the
'worker' ranks to know something about the work being done on (or the data
given to) each of the other ranks.  The only allowed communication of this
type is provided by the *allreduce* method.

The *allreduce* method allows for *reductions* of the data distributed across
all of the ranks to be made available to every rank.  Reductions are operations
such as 'max', 'min', 'sum', and 'prod', which compute and distribute to the
ranks the 'maximum', 'minimum', 'sum', or 'product' of the data distributed
across the ranks.  Since the *reduction* computes a reduced quantity of data
distributed across all ranks, the *allreduce* method is a *synchronous* method
(i.e., all ranks must participate in the call, including the 'manager').

**DIVIDING:**

It can be occasionally useful to subdivide the 'worker' ranks into different
groups to perform different tasks in each group.  When this is necessary, the
'manager' rank will assign itself and each 'worker' rank a *color* ID.  Then,
the 'manager' will assign each rank (including itself) to 2 new groups:

1. Each rank with the same color ID will be assigned to the same group, and
    within this new *color* group, each rank will be given a new rank ID
    ranging from 0 (identifying the color group's 'manager' rank) to the number
    of 'worker' ranks in the color group.  This is called
    the *monocolor* grouping.

2. Each rank with the same new rank ID across all color groups will be assigned
    to the same group.  Hence, all ranks with rank ID 0 (but different color
    IDs) will be in the same group, all ranks with rank ID 1 (but different
    color IDs) will be the in another group, etc.  This is called the
    *multicolor* grouping.  NOTE: This grouping will look like grouping (1)
    except with the rank ID and the color ID swapped.

The *divide* method provides this functionality, and it returns 2 new
SimpleComm objects for each of the 2 groupings described above.  This means
that within each group, the same *partition*, *collecting*, and *reducing*
operations can be performed in the same way as described above for the *global*
group.

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from functools import partial
from collections import defaultdict

# Define the supported reduction operators
OPERATORS = ['sum', 'prod', 'max', 'min']

# Define the reduction operators map (Maps names to function names.
# The 'py' function names are passed to 'eval(*)' and executed as python code.
# The 'np' function names are passed to 'getattr(numpy,*)' and executed as
# numpy code.  The 'mpi' function names are passed to 'getattr(mpi4py,*)'
# and return an MPI operator object which is passed as an argument to MPI
# reduce functions.
_OP_MAP = {'sum': {'py': 'sum',
                   'np': 'sum',
                   'mpi': 'SUM'},
           'prod': {'py': 'partial(reduce, lambda x, y: x * y)',
                    'np': 'prod',
                    'mpi': 'PROD'},
           'max': {'py': 'max',
                   'np': 'max',
                   'mpi': 'MAX'},
           'min': {'py': 'min',
                   'np': 'min',
                   'mpi': 'MIN'}}


#==============================================================================
# create_comm - Simple Communicator Factory Function
#==============================================================================
def create_comm(serial=False):
    """
    This is a factory function for creating SimpleComm objects.

    Depending on the argument given, it returns an instance of a serial or
    parallel SimpleComm object.

    Keyword Arguments:
        serial (bool): A boolean flag with True indicating the desire for a
            serial SimpleComm instance, and False incidicating the
            desire for a parallel SimpleComm instance.

    Returns:
        SimpleComm: An instance of a SimpleComm object, either serial
            (if serial == True) or parallel (if serial == False)

    Raises:
        TypeError: if the serial argument is not a bool.

    Examples:

        >>> sercomm = create_comm(serial=True)
        >>> type(sercomm)
        <class 'simplecomm.SimpleComm'>

        >>> parcomm = create_comm()
        >>> type(parcomm)
        <class 'simplecomm.SimpleCommMPI'>
    """
    if type(serial) is not bool:
        raise TypeError('Serial parameter must be a bool')
    if serial:
        return SimpleComm()
    else:
        return SimpleCommMPI()


#==============================================================================
# SimpleComm - Simple Communicator
#==============================================================================
class SimpleComm(object):

    """
    Simple Communicator for serial operation.

    Attributes:
        _numpy: Reference to the Numpy module, if found
        _color: The color associated with the communicator, if colored
        _group: The group ID associated with the communicator's color
    """

    def __init__(self):
        """
        Constructor.
        """

        # Try importing the Numpy module
        try:
            import numpy
        except:
            numpy = None

        # To the Numpy module, if found
        self._numpy = numpy

        # The color ID associated with this communicator
        self._color = None

        # The group ID associated with the color
        self._group = None

    def _is_ndarray(self, obj):
        """
        Helper function to determing if an object is a Numpy NDArray.

        Parameters:
            obj: The object to be tested

        Returns:
            bool: True if the object is a Numpy NDArray. False otherwise,
                or if the Numpy module was not found during
                the SimpleComm constructor.

        Examples:

            >>> _is_ndarray(1)
            False

            >>> alist = [1,2,3,4]
            >>> _is_ndarray(alist)
            False

            >>> aarray = numpy.array(alist)
            >>> _is_ndarray(aarray)
            True
        """
        if self._numpy:
            return isinstance(obj, self._numpy.ndarray)
        else:
            return False

    def get_size(self):
        """
        Get the integer number of ranks in this communicator.

        The size includes the 'manager' rank.

        Returns:
            int: The integer number of ranks in this communicator.
        """
        return 1

    def get_rank(self):
        """
        Get the integer rank ID of this MPI process in this communicator.

        This call can be made independently from other ranks.

        Returns:
            int: The integer rank ID of this MPI process
        """
        return 0

    def is_manager(self):
        """
        Check if this MPI process is on the 'manager' rank (i.e., rank 0).

        This call can be made independently from other ranks.

        Returns:
            bool: True if this MPI process is on the master rank
                (or rank 0). False otherwise.
        """
        return self.get_rank() == 0

    def get_color(self):
        """
        Get the integer color ID of this MPI process in this communicator.

        By default, a communicator's color is None, but a communicator can
        be divided into color groups using the 'divide' method.

        This call can be made independently from other ranks.

        Returns:
            int: The color of this MPI communicator
        """
        return self._color

    def get_group(self):
        """
        Get the group ID of this MPI communicator.

        The group ID is the argument passed to the 'divide' method, and it
        represents a unique identifier for all ranks in the same color group.
        It can be any type of object (e.g., a string name).

        This call can be made independently from other ranks.

        Returns:
            The group ID of this communicator
        """
        return self._group

    def sync(self):
        """
        Synchronize all MPI processes at the point of this call.

        Immediately after this method is called, you can guarantee that all
        ranks in this communicator will be synchronized.

        This call must be made by all ranks.
        """
        return

    def allreduce(self, data, op):
        """
        Perform an MPI AllReduction operation.

        The data is "reduced" across all ranks in the communicator, and the
        result is returned to all ranks in the communicator.  (Reduce
        operations such as 'sum', 'prod', 'min', and 'max' are allowed.)

        This call must be made by all ranks.

        Parameters:
            data: The data to be reduced
            op (str): A string identifier for a reduce operation (any string
                found in the OPERATORS list)

        Returns:
            The single value constituting the reduction of the input data.
            (The same value is returned on all ranks in this communicator.)
        """
        if (isinstance(data, dict)):
            totals = {}
            for k, v in data.items():
                totals[k] = SimpleComm.allreduce(self, v, op)
            return totals
        elif self._is_ndarray(data):
            return SimpleComm.allreduce(self,
                                        getattr(self._numpy,
                                                _OP_MAP[op]['np'])(data),
                                        op)
        elif hasattr(data, '__len__'):
            return SimpleComm.allreduce(self,
                                        eval(_OP_MAP[op]['py'])(data),
                                        op)
        else:
            return data

    def partition(self, data=None, func=None, involved=False, tag=0):
        """
        Partition and send data from the 'manager' rank to 'worker' ranks.

        By default, the data is partitioned using an "equal stride" across the
        data, with the stride equal to the number of ranks involved in the
        partitioning.  If a partition function is supplied via the `func`
        argument, then the data will be partitioned across the 'worker' ranks,
        giving each 'worker' rank a different part of the data according to
        the algorithm used by partition function supplied.

        If the `involved` argument is True, then a part of the data (as
        determined by the given partition function, if supplied) will be
        returned on the 'manager' rank.  Otherwise, ('involved' argument is
        False) the data will be partitioned only across the 'worker' ranks.

        This call must be made by all ranks.

        Keyword Arguments:
            data: The data to be partitioned across the ranks in the
                communicator.
            func: A PartitionFunction object/function that returns a part
                of the data given the index and assumed size of the partition.
            involved (bool): True if a part of the data should be given to the
                'manager' rank in addition to the 'worker' ranks. False
                otherwise.
            tag (int): A user-defined integer tag to uniquely specify this
                communication message.

        Returns:
            A (possibly partitioned) subset (i.e., part) of the data.  Depending
            on the PartitionFunction used (or if it is used at all), this method
            may return a different part on each rank.
        """
        op = func if func else lambda *x: x[0][x[1]::x[2]]
        if involved:
            return op(data, 0, 1)
        else:
            return None

    def ration(self, data=None, tag=0):
        """
        Send a single piece of data from the 'manager' rank to a 'worker' rank.

        If this method is called on a 'worker' rank, the worker will send a
        "request" for data to the 'manager' rank.  When the 'manager' receives
        this request, the 'manager' rank sends a single piece of data back to
        the requesting 'worker' rank.

        For each call to this function on a given 'worker' rank, there must
        be a matching call to this function made on the 'manager' rank.

        NOTE: This method cannot be used for communication between the
        'manager' rank and itself.  Attempting this will cause the code to
        hang.

        Keyword Arguments:
            data: The data to be asynchronously sent to the 'worker' rank
            tag (int): A user-defined integer tag to uniquely specify this
                communication message

        Returns:
            On the 'worker' rank, the data sent by the manager.  On the
            'manager' rank, None.

        Raises:
            RuntimeError: If executed during a serial or 1-rank parallel run
        """
        err_msg = 'Rationing cannot be used in serial operation'
        raise RuntimeError(err_msg)

    def collect(self, data=None, tag=0):
        """
        Send data from a 'worker' rank to the 'manager' rank.

        If the calling MPI process is the 'manager' rank, then it will
        receive and return the data sent from the 'worker'.  If the calling
        MPI process is a 'worker' rank, then it will send the data to the
        'manager' rank.

        For each call to this function on a given 'worker' rank, there must
        be a matching call to this function made on the 'manager' rank.

        NOTE: This method cannot be used for communication between the
        'manager' rank and itself.  Attempting this will cause the code to
        hang.

        Keyword Arguments:
            data: The data to be collected asynchronously on the manager rank.
            tag (int): A user-defined integer tag to uniquely specify this
                communication message

        Returns:
            On the 'manager' rank, a tuple containing the source rank ID
            and the data collected.  None on all other ranks.

        Raises:
            RuntimeError: If executed during a serial or 1-rank parallel run
        """
        err_msg = 'Collection cannot be used in serial operation'
        raise RuntimeError(err_msg)

    def divide(self, group):
        """
        Divide this communicator's ranks into groups.

        Creates and returns two (2) kinds of groups:

        1. groups with ranks of the same color ID but different rank IDs
            (called a "monocolor" group), and

        2. groups with ranks of the same rank ID but different color IDs
            (called a "multicolor" group).

        Parameters:
            group: A unique group ID to which will be assigned an integer
                color ID ranging from 0 to the number of group ID's
                supplied across all ranks

        Returns:
            tuple: A tuple containing (first) the "monocolor" SimpleComm for
                ranks with the same color ID (but different rank IDs) and
                (second) the "multicolor" SimpleComm for ranks with the same
                rank ID (but different color IDs)

        Raises:
            RuntimeError: If executed during a serial or 1-rank parallel run
        """
        err_msg = 'Division cannot be done on a serial communicator'
        raise RuntimeError(err_msg)


#==============================================================================
# SimpleCommMPI - Simple Communicator using MPI
#==============================================================================
class SimpleCommMPI(SimpleComm):

    """
    Simple Communicator using MPI.

    Attributes:
        PART_TAG: Partition Tag Identifier
        RATN_TAG: Ration Tag Identifier
        CLCT_TAG: Collect Tag Identifier
        REQ_TAG: Request Identifier
        MSG_TAG: Message Identifer
        ACK_TAG: Acknowledgement Identifier
        PYT_TAG: Python send/recv Identifier
        NPY_TAG: Numpy send/recv Identifier
        _mpi: A reference to the mpi4py.MPI module
        _comm: A reference to the mpi4py.MPI communicator
    """

    PART_TAG = 1  # Partition Tag Identifier
    RATN_TAG = 2  # Ration Tag Identifier
    CLCT_TAG = 3  # Collect Tag Identifier

    REQ_TAG = 1  # Request Identifier
    MSG_TAG = 2  # Message Identifier
    ACK_TAG = 3  # Acknowledgement Identifier
    PYT_TAG = 4  # Python Data send/recv Identifier
    NPY_TAG = 5  # Numpy NDArray send/recv Identifier

    def __init__(self):
        """
        Constructor.
        """

        # Call the base class constructor
        super(SimpleCommMPI, self).__init__()

        # Try importing the MPI4Py MPI module
        try:
            from mpi4py import MPI
        except:
            err_msg = 'MPI could not be found.'
            raise ImportError(err_msg)

        # Hold on to the MPI module
        self._mpi = MPI

        # The MPI communicator (by default, COMM_WORLD)
        self._comm = self._mpi.COMM_WORLD

    def __del__(self):
        """
        Destructor.

        Free the communicator if this SimpleComm goes out of scope
        """
        if self._comm != self._mpi.COMM_WORLD:
            self._comm.Free()

    def _is_bufferable(self, obj):
        """
        Check if the data is bufferable or not
        """
        if self._is_ndarray(obj):
            if hasattr(self._mpi, '_typedict_c'):
                return (obj.dtype.char in self._mpi._typedict_c)
            elif hasattr(self._mpi, '__CTypeDict__'):
                return (obj.dtype.char in self._mpi.__CTypeDict__ and
                        obj.dtype.char != 'c')
            else:
                return False
        else:
            return False
        
    def get_size(self):
        """
        Get the integer number of ranks in this communicator.

        The size includes the 'manager' rank.

        Returns:
            int: The integer number of ranks in this communicator.
        """
        return self._comm.Get_size()

    def get_rank(self):
        """
        Get the integer rank ID of this MPI process in this communicator.

        This call can be made independently from other ranks.

        Returns:
            int: The integer rank ID of this MPI process
        """
        return self._comm.Get_rank()

    def sync(self):
        """
        Synchronize all MPI processes at the point of this call.

        Immediately after this method is called, you can guarantee that all
        ranks in this communicator will be synchronized.

        This call must be made by all ranks.
        """
        self._comm.Barrier()

    def allreduce(self, data, op):
        """
        Perform an MPI AllReduction operation.

        The data is "reduced" across all ranks in the communicator, and the
        result is returned to all ranks in the communicator.  (Reduce
        operations such as 'sum', 'prod', 'min', and 'max' are allowed.)

        This call must be made by all ranks.

        Parameters:
            data: The data to be reduced
            op (str): A string identifier for a reduce operation (any string
                found in the OPERATORS list)

        Returns:
            The single value constituting the reduction of the input data.
            (The same value is returned on all ranks in this communicator.)
        """
        if (isinstance(data, dict)):
            all_list = self._comm.gather(SimpleComm.allreduce(self, data, op))
            if self.is_manager():
                all_dict = defaultdict(list)
                for d in all_list:
                    for k, v in d.items():
                        all_dict[k].append(v)
                result = {}
                for k, v in all_dict.items():
                    result[k] = SimpleComm.allreduce(self, v, op)
                return self._comm.bcast(result)
            else:
                return self._comm.bcast(None)
        else:
            return self._comm.allreduce(SimpleComm.allreduce(self, data, op),
                                        op=getattr(self._mpi,
                                                   _OP_MAP[op]['mpi']))

    def _tag_offset(self, method, message, user):
        """
        Method to generate the tag for a given MPI message

        Parameters:
            method (int): One of PART_TAG, RATN_TAG, CLCT_TAG
            message (int):  One of REQ_TAG, MSG_TAG, ACK_TAG, PYT_TAG, NPY_TAG
            user (int): A user-defined integer tag

        Returns:
            int: A new tag uniquely combining all of the method, message, and
                user tags together
        """
        return 100 * user + 10 * method + message

    def partition(self, data=None, func=None, involved=False, tag=0):
        """
        Partition and send data from the 'manager' rank to 'worker' ranks.

        By default, the data is partitioned using an "equal stride" across the
        data, with the stride equal to the number of ranks involved in the
        partitioning.  If a partition function is supplied via the 'func'
        argument, then the data will be partitioned across the 'worker' ranks,
        giving each 'worker' rank a different part of the data according to
        the algorithm used by partition function supplied.

        If the 'involved' argument is True, then a part of the data (as
        determined by the given partition function, if supplied) will be
        returned on the 'manager' rank.  Otherwise, ('involved' argument is
        False) the data will be partitioned only across the 'worker' ranks.

        This call must be made by all ranks.

        Keyword Arguments:
            data: The data to be partitioned across
                the ranks in the communicator.
            func: A PartitionFunction object/function that returns
                a part of the data given the index and assumed
                size of the partition.
            involved (bool): True, if a part of the data should be given
                to the 'manager' rank in addition to the 'worker'
                ranks. False, otherwise.
            tag (int): A user-defined integer tag to uniquely
                specify this communication message

        Returns:
            A (possibly partitioned) subset (i.e., part) of the data.
            Depending on the PartitionFunction used (or if it is used at all),
            this method may return a different part on each rank.
        """
        if self.is_manager():
            op = func if func else lambda *x: x[0][x[1]::x[2]]
            j = 1 if not involved else 0
            for i in xrange(1, self.get_size()):

                # Get the part of the data to send to rank i
                part = op(data, i - j, self.get_size() - j)

                # Create the handshake message
                msg = {}
                msg['rank'] = self.get_rank()
                msg['buffer'] = self._is_bufferable(part)
                msg['shape'] = getattr(part, 'shape', None)
                msg['dtype'] = getattr(part, 'dtype', None)
                
                # Send the handshake message to the worker rank
                msg_tag = self._tag_offset(self.PART_TAG, self.MSG_TAG, tag)
                self._comm.send(msg, dest=i, tag=msg_tag)

                # Receive the acknowledgement from the worker
                ack_tag = self._tag_offset(self.PART_TAG, self.ACK_TAG, tag)
                ack = self._comm.recv(source=i, tag=ack_tag)

                # Check the acknowledgement, if bad skip this rank
                if not ack:
                    continue

                # If OK, send the data to the worker
                if msg['buffer']:
                    npy_tag = self._tag_offset(
                        self.PART_TAG, self.NPY_TAG, tag)
                    self._comm.Send(self._numpy.array(part),
                                    dest=i, tag=npy_tag)
                else:
                    pyt_tag = self._tag_offset(
                        self.PART_TAG, self.PYT_TAG, tag)
                    self._comm.send(part, dest=i, tag=pyt_tag)

            if involved:
                return op(data, 0, self.get_size())
            else:
                return None
        else:

            # Get the data message from the manager
            msg_tag = self._tag_offset(self.PART_TAG, self.MSG_TAG, tag)
            msg = self._comm.recv(source=0, tag=msg_tag)

            # Check the message content
            ack = (type(msg) is dict and 
                   all([key in msg for key in 
                        ['rank', 'buffer', 'shape', 'dtype']]))

            # If the message is good, acknowledge
            ack_tag = self._tag_offset(self.PART_TAG, self.ACK_TAG, tag)
            self._comm.send(ack, dest=0, tag=ack_tag)

            # if acknowledgement is bad, skip
            if not ack:
                return None

            # Receive the data
            if msg['buffer']:
                npy_tag = self._tag_offset(
                    self.PART_TAG, self.NPY_TAG, tag)
                recvd = self._numpy.empty(msg['shape'], dtype=msg['dtype'])
                self._comm.Recv(recvd, source=0, tag=npy_tag)
            else:
                pyt_tag = self._tag_offset(
                    self.PART_TAG, self.PYT_TAG, tag)
                recvd = self._comm.recv(source=0, tag=pyt_tag)

            return recvd

    def ration(self, data=None, tag=0):
        """
        Send a single piece of data from the 'manager' rank to a 'worker' rank.

        If this method is called on a 'worker' rank, the worker will send a
        "request" for data to the 'manager' rank.  When the 'manager' receives
        this request, the 'manager' rank sends a single piece of data back to
        the requesting 'worker' rank.

        For each call to this function on a given 'worker' rank, there must
        be a matching call to this function made on the 'manager' rank.

        NOTE: This method cannot be used for communication between the
        'manager' rank and itself.  Attempting this will cause the code to
        hang.

        Keyword Arguments:
            data: The data to be asynchronously sent to the 'worker' rank
            tag (int): A user-defined integer tag to uniquely specify this
                communication message

        Returns:
            On the 'worker' rank, the data sent by the manager.  On the
            'manager' rank, None.

        Raises:
            RuntimeError: If executed during a serial or 1-rank parallel run
        """
        if self.get_size() > 1:
            if self.is_manager():

                # Listen for a requesting worker rank
                req_tag = self._tag_offset(self.RATN_TAG, self.REQ_TAG, tag)
                rank = self._comm.recv(
                    source=self._mpi.ANY_SOURCE, tag=req_tag)

                # Create the handshake message
                msg = {}
                msg['buffer'] = self._is_bufferable(data)
                msg['shape'] = data.shape if hasattr(data, 'shape') else None
                msg['dtype'] = data.dtype if hasattr(data, 'dtype') else None

                # Send the handshake message to the requesting worker
                msg_tag = self._tag_offset(self.RATN_TAG, self.MSG_TAG, tag)
                self._comm.send(msg, dest=rank, tag=msg_tag)

                # Receive the acknowledgement from the requesting worker
                ack_tag = self._tag_offset(self.RATN_TAG, self.ACK_TAG, tag)
                ack = self._comm.recv(source=rank, tag=ack_tag)

                # Check the acknowledgement, if not OK skip
                if not ack:
                    return

                # If OK, send the data to the requesting worker
                if msg['buffer']:
                    npy_tag = self._tag_offset(
                        self.RATN_TAG, self.NPY_TAG, tag)
                    self._comm.Send(data, dest=rank, tag=npy_tag)
                else:
                    pyt_tag = self._tag_offset(
                        self.RATN_TAG, self.PYT_TAG, tag)
                    self._comm.send(data, dest=rank, tag=pyt_tag)
            else:

                # Send a request for data to the manager
                req_tag = self._tag_offset(self.RATN_TAG, self.REQ_TAG, tag)
                self._comm.send(self.get_rank(), dest=0, tag=req_tag)

                # Receive the handshake message from the manager
                msg_tag = self._tag_offset(self.RATN_TAG, self.MSG_TAG, tag)
                msg = self._comm.recv(source=0, tag=msg_tag)

                # Check the message content
                ack = (type(msg) is dict and
                       all([key in msg for key in
                            ['buffer', 'shape', 'dtype']]))

                # Send acknowledgement back to the manager
                ack_tag = self._tag_offset(self.RATN_TAG, self.ACK_TAG, tag)
                self._comm.send(ack, dest=0, tag=ack_tag)

                # If acknowledgement is bad, don't receive
                if not ack:
                    return None

                # Receive the data from the manager
                if msg['buffer']:
                    npy_tag = self._tag_offset(
                        self.RATN_TAG, self.NPY_TAG, tag)
                    recvd = self._numpy.empty(msg['shape'], dtype=msg['dtype'])
                    self._comm.Recv(recvd, source=0, tag=npy_tag)
                else:
                    pyt_tag = self._tag_offset(
                        self.RATN_TAG, self.PYT_TAG, tag)
                    recvd = self._comm.recv(source=0, tag=pyt_tag)
                return recvd
        else:
            err_msg = 'Rationing cannot be used in 1-rank parallel operation'
            raise RuntimeError(err_msg)

    def collect(self, data=None, tag=0):
        """
        Send data from a 'worker' rank to the 'manager' rank.

        If the calling MPI process is the 'manager' rank, then it will
        receive and return the data sent from the 'worker'.  If the calling
        MPI process is a 'worker' rank, then it will send the data to the
        'manager' rank.

        For each call to this function on a given 'worker' rank, there must
        be a matching call to this function made on the 'manager' rank.

        NOTE: This method cannot be used for communication between the
        'manager' rank and itself.  Attempting this will cause the code to
        hang.

        Keyword Arguments:
            data: The data to be collected asynchronously
                on the 'manager' rank.
            tag (int): A user-defined integer tag to uniquely
                specify this communication message

        Returns:
            tuple: On the 'manager' rank, a tuple containing the source rank
                ID and the the data collected.  None on all other ranks.

        Raises:
            RuntimeError: If executed during a serial or 1-rank parallel run
        """
        if self.get_size() > 1:
            if self.is_manager():

                # Receive the message from the worker
                msg_tag = self._tag_offset(self.CLCT_TAG, self.MSG_TAG, tag)
                msg = self._comm.recv(source=self._mpi.ANY_SOURCE, tag=msg_tag)

                # Check the message content
                ack = (type(msg) is dict and
                       all([key in msg for key in 
                            ['rank', 'buffer', 'shape', 'dtype']]))

                # Send acknowledgement back to the worker
                ack_tag = self._tag_offset(self.CLCT_TAG, self.ACK_TAG, tag)
                self._comm.send(ack, dest=msg['rank'], tag=ack_tag)

                # If acknowledgement is bad, don't receive
                if not ack:
                    return None

                # Receive the data
                if msg['buffer']:
                    npy_tag = self._tag_offset(
                        self.CLCT_TAG, self.NPY_TAG, tag)
                    recvd = self._numpy.empty(msg['shape'], dtype=msg['dtype'])
                    self._comm.Recv(recvd, source=msg['rank'], tag=npy_tag)
                else:
                    pyt_tag = self._tag_offset(
                        self.CLCT_TAG, self.PYT_TAG, tag)
                    recvd = self._comm.recv(source=msg['rank'], tag=pyt_tag)
                return msg['rank'], recvd

            else:

                # Create the handshake message
                msg = {}
                msg['rank'] = self.get_rank()
                msg['buffer'] = self._is_bufferable(data)
                msg['shape'] = data.shape if hasattr(data, 'shape') else None
                msg['dtype'] = data.dtype if hasattr(data, 'dtype') else None

                # Send the handshake message to the manager
                msg_tag = self._tag_offset(self.CLCT_TAG, self.MSG_TAG, tag)
                self._comm.send(msg, dest=0, tag=msg_tag)

                # Receive the acknowledgement from the manager
                ack_tag = self._tag_offset(self.CLCT_TAG, self.ACK_TAG, tag)
                ack = self._comm.recv(source=0, tag=ack_tag)

                # Check the acknowledgement, if not OK skip
                if not ack:
                    return

                # If OK, send the data to the manager
                if msg['buffer']:
                    npy_tag = self._tag_offset(
                        self.CLCT_TAG, self.NPY_TAG, tag)
                    self._comm.Send(data, dest=0, tag=npy_tag)
                else:
                    pyt_tag = self._tag_offset(
                        self.CLCT_TAG, self.PYT_TAG, tag)
                    self._comm.send(data, dest=0, tag=pyt_tag)
        else:
            err_msg = 'Collection cannot be used in a 1-rank communicator'
            raise RuntimeError(err_msg)

    def divide(self, group):
        """
        Divide this communicator's ranks into groups.

        Creates and returns two (2) kinds of groups:

            (1) groups with ranks of the same color ID but different rank IDs
                (called a "monocolor" group), and

            (2) groups with ranks of the same rank ID but different color IDs
                (called a "multicolor" group).

        Parameters:
            group: A unique group ID to which will be assigned an integer
                color ID ranging from 0 to the number of group ID's
                supplied across all ranks

        Returns:
            tuple: A tuple containing (first) the "monocolor" SimpleComm for
                ranks with the same color ID (but different rank IDs) and
                (second) the "multicolor" SimpleComm for ranks with the same
                rank ID (but different color IDs)

        Raises:
            RuntimeError: If executed during a serial or 1-rank parallel run
        """
        if self.get_size() > 1:
            allgroups = list(set(self._comm.allgather(group)))
            color = allgroups.index(group)
            monocomm = SimpleCommMPI()
            monocomm._color = color
            monocomm._group = group
            monocomm._comm = self._comm.Split(color)

            rank = monocomm.get_rank()
            multicomm = SimpleCommMPI()
            multicomm._color = rank
            multicomm._group = rank
            multicomm._comm = self._comm.Split(rank)

            return monocomm, multicomm
        else:
            err_msg = 'Division cannot be done on a 1-rank communicator'
            raise RuntimeError(err_msg)
