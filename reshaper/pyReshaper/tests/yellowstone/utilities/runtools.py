#==============================================================================
#
#  RunTools
#
#  This is a collection of functions that are useful for running the PyReshaper
#  tests on the Yellowstone compute system.
#
#==============================================================================

# Builtin Modules
import os
import re
import abc
import stat
import socket
from subprocess import Popen, PIPE, STDOUT


#==============================================================================
# Job Class - Public Interface
#==============================================================================
class Job(object):

    def __init__(self, nodes=0, **kwargs):
        """
        Factor function for job objects

        Parameters:
            nodes (int): Number of nodes to run on (<=0 implies serial)
            kwargs (dict): Additional arguments
        """

        self._nodes = int(nodes)
        self._hostname = socket.gethostname()
        if self._nodes <= 0:
            self._job = _SerialJob(**kwargs)
        elif _YellowstoneJob.HOSTNAME_PATTERN.match(self._hostname):
            self._job = _YellowstoneJob(nodes=self._nodes, **kwargs)
        else:
            err_msg = "Parallel job on " + self._hostname + " unsupported"
            raise RuntimeError(err_msg)

    def start(self):
        """
        Launch/start the job
        """
        self._job.start()

    def wait(self):
        """
        Wait for the job to complete
        """
        self._job.wait()


#==============================================================================
# Job Base Abstract Class
#==============================================================================
class _Job(object):
    """
    A class for defining a serial job type
    """

    __metaclass__ = abc.ABCMeta

    def __init__(self, runcmds=[], name="job"):
        """
        Initializer

        Parameters:
            runcmds (list, tuple): The list of commands to run
            name (str): Name of the run script
        """

        # Initialize internal data
        self._jobname = str(name)
        self._rundir = os.getcwd()
        self._runscript = os.path.join(self._rundir, self._jobname + '.sh')
        self._process = None

        self._runcmds = []
        if isinstance(runcmds, str):
            self._runcmds.append(runcmds)
        elif isinstance(runcmds, (list, tuple)):
            strcmds = [str(cmd) for cmd in runcmds]
            self._runcmds.extend(strcmds)

    @abc.abstractmethod
    def start(self):
        """
        Start the job (or submit into the queue)
        """
        pass

    @abc.abstractmethod
    def wait(self):
        """
        Wait for the job to complete
        """
        pass


#==============================================================================
# Job Class for serial operation
#==============================================================================
class _SerialJob(_Job):
    """
    A class for defining a serial job type
    """

    def __init__(self, runcmds=[], name="serialjob", **kwargs):
        """
        Initializer

        Parameters:
            runcmds (list, tuple): The list of commands to run
            name (str): Name of the run script
        """

        # Call the base class initialization
        super(_SerialJob, self).__init__(runcmds=runcmds, name=name)

        # Define the name of the log file, and set the file object to None
        self._logfilenm = os.path.join(self._rundir, self._jobname + '.log')
        self._logfile = None

        # Start creating the run scripts for each test
        runscript_list = ['#!/bin/bash',
                          '',
                          '# Necessary modules to load',
                          'module load python',
                          'module load all-python-libs',
                          '']
        runscript_list.extend(self._runcmds)
        runscript_list.append('')

        # Write the script to file
        runscript_file = open(self._runscript, 'w')
        runscript_file.write(os.linesep.join(runscript_list))
        runscript_file.close()

        # Make the script executable
        os.chmod(self._runscript, stat.S_IRWXU | stat.S_IRGRP | stat.S_IROTH)

    def start(self):
        """
        Start the job (or submit into the queue)
        """

        # Go to the run directory
        cwd = os.getcwd()
        os.chdir(self._rundir)

        # if the process is already running, kill it
        if self._process is not None:
            self._process.kill()
            self._logfile.close()

        # Open the log file
        self._logfile = open(self._logfilenm, 'w')

        # Launch the serial job as a subprocess
        self._process = Popen([self._runscript],
                              stdout=self._logfile, stderr=STDOUT,
                              env=os.environ.copy(), bufsize=0)

        # Display PID on screen and let run in background
        print "Process launched in background with PID {0!s}".format(self._process.pid)
        print

        # Go back to where you started
        os.chdir(cwd)

    def wait(self):
        """
        Wait for the job to complete
        """

        if self._process is not None:
            self._process.wait()
            self._process = None


#==============================================================================
# Script/Job Runner for the Yellowstone LSF environment
#==============================================================================
class _YellowstoneJob(_Job):
    """
    A simple class for running jobs on Yellowstone
    """

    HOSTNAME_PATTERN = re.compile('^(yslogin|caldera|geyser|pronghorn)')

    def __init__(self, runcmds=[], name="ysjob", nodes=1, tiling=16,
                 minutes=120, queue="small", project="STDD0002", **kwargs):
        """
        Constructor

        Parameters:
            runcmds (list, tuple): The list of commands to run
            name (str): Name of the run script
            nodes (int): Number of nodes to request
            tiling (int): Number of processors per node to request
            minutes (int): Number of walltime minutes to request
            queue (str): Name of queue to submit the job
            project (str): Name of project with which to associate the job
        """

        # Call the base class initialization
        super(_YellowstoneJob, self).__init__(runcmds=runcmds, name=name)

        # Initialize internal data
        self._nodes = int(nodes)
        self._tiling = int(tiling)
        self._minutes = int(minutes)
        self._queue = str(queue)
        self._project = str(project)

        # Number of processors total
        num_procs = self._nodes * self._tiling

        # Generate walltime in string form
        wtime_hours = self._minutes / 60
        if (wtime_hours > 99):
            wtime_hours = 99
            print 'Requested number of hours too large.  Limiting to {0!s}.'.format(wtime_hours)
        wtime_minutes = self._minutes % 60
        wtime_str = '{:0>2}:{:0>2}'.format(wtime_hours, wtime_minutes)

        # String list representing LSF preamble
        runscript_list = ['#!/bin/bash',
                          '#BSUB -n {0!s}'.format(num_procs),
                          '#BSUB -R "span[ptile={0!s}]"'.format(self._tiling),
                          '#BSUB -q {0!s}'.format(self._queue),
                          '#BSUB -a poe',
                          '#BSUB -x',
                          '#BSUB -o {0!s}.%J.log'.format(self._jobname),
                          '#BSUB -J {0!s}'.format(self._jobname),
                          '#BSUB -P {0!s}'.format(self._project),
                          '#BSUB -W {0!s}'.format(wtime_str),
                          '',
                          'export MP_TIMEOUT=14400',
                          'export MP_PULSE=1800',
                          'export MP_DEBUG_NOTIMEOUT=yes',
                          '',
                          '# Necessary modules to load',
                          'module load python',
                          'module load all-python-libs',
                          '']
        runscript_list.extend(self._runcmds)
        runscript_list.append('')

        # Write the script to file
        runscript_file = open(self._runscript, 'w')
        runscript_file.write(os.linesep.join(runscript_list))
        runscript_file.close()

    def start(self):
        """
        Start the job (or submit into the queue)
        """

        # Go to the run directory
        cwd = os.getcwd()
        os.chdir(self._rundir)

        # If the process is still running, kill it first
        if self._process is not None:
            job = Popen(['bkill', self._process],
                        stdout=PIPE, stderr=STDOUT)
            job.wait()

        # Open up the run script for input to LSF's bsub
        runscript_file = open(self._runscript, 'r')

        # Launch the parallel job with LSF bsub
        job = Popen(['bsub'], stdout=PIPE, stderr=STDOUT,
                    stdin=runscript_file, env=os.environ.copy())

        # Get the process ID from bsub output
        output = str(job.communicate()[0]).strip()

        # Display the job name
        print str(output)
        print

        # Get the job ID (first integer in output)
        self._process = re.findall('\d+', output)[0]

        # Close the script file and print submission info
        runscript_file.close()

        # Go back to where we started
        os.chdir(cwd)

    def wait(self):
        """
        Wait for the job to complete
        """

        # Wait until the process completes
        while self._process is not None:
            job = Popen(['bjobs', self._process],
                        stdout=PIPE, stderr=PIPE)
            job_output = job.communicate()[0]
            if len(job_output) == 0:
                self._process = None
