"""
A module containing the TimeKeeper class.

This module contains is a simple class to act as a time keeper for internal
performance monitoring (namely, timing given processes).

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from time import time


class TimeKeeper(object):

    """
    Class to keep timing recordings, start/stop/reset timers.

    Attributes:
        _time: The method to use for getting the time (e.g., time.time)
        _start_times (dict): A dictionary of start times for each named timer
        _accumulated_times (dict): A dictionary of the total accumulated times
            for each named timer
        _added_order (list): A list containing the name of each timer, in the
            order it was added to the TimeKeeper
    """

    def __init__(self, time=time):
        """
        Constructor.

        Keyword Arguments:
            time: The function to use for measuring the time.  By default,
                it is the Python 'time.time()' method.
        """

        # The method to use for time measurements
        self._time = time

        # Dictionary of start times associated with a string name
        self._start_times = {}

        # Dictionary of accumulated times associated with a string name
        self._accumulated_times = {}

        # List containing the order of the timers
        #  (when added to the dictionaries)
        self._added_order = []

    def reset(self, name):
        """
        Method to reset a timer associated with a given name.

        If the name has never been used before, the timer is created and the
        accumulated time is set to 0.  If the timer has been used before, the
        accumulated time is set to 0.

        Parameters:
            name: The name or ID of the timer to reset
        """

        # Reset the named timer (creates it if it doesn't exist yet)
        if (name not in self._added_order):
            self._added_order.append(name)
        self._accumulated_times[name] = 0.0
        self._start_times[name] = self._time()

    def start(self, name):
        """
        Method to start a timer associated with a given name.

        If the name has never been used before, the timer is created and
        the accumulated time is set to 0.

        Parameters:
            name: The name or ID of the timer to start
        """

        # Start the named timer (creates it if it doesn't exist yet)
        if (name not in self._accumulated_times):
            self.reset(name)
        else:
            self._start_times[name] = self._time()

    def stop(self, name):
        """
        Stop the timing and add the accumulated time to the timer.

        Method to stop a timer associated with a given name, and adds
        the accumulated time to the timer when stopped.  If the given timer
        name has never been used before (either by calling reset() or start()),
        the timer is created and the accumulated time is set to 0.

        Parameters:
            name: The name or ID of the timer to stop
        """

        # Stop the named timer, add to accumulated time
        if (name not in self._accumulated_times):
            self.reset(name)
        else:
            self._accumulated_times[name] += \
                self._time() - self._start_times[name]

    def get_names(self):
        """
        Method to return the clock names in the order in which they were added.

        Returns:
            list: The list of timer names in the order they were added
        """
        return self._added_order

    def get_time(self, name):
        """
        Returns the accumulated time of the given timer.

        If the given timer name has never been created, it is created and the
        accumulated time is set to zero before returning.

        Parameters:
            name: The name or ID of the timer to stop

        Returns:
            float: The accumulated time of the named timer (or 0.0 if the
                named timer has never been created before).
        """

        # Get the accumulated time
        if (name not in self._accumulated_times):
            self.reset(name)
        return self._accumulated_times[name]

    def get_all_times(self):
        """
        Returns the dictionary of accumulated times on the local processor.

        Returns:
            dict: The dictionary of accumulated times
        """
        return self._accumulated_times
