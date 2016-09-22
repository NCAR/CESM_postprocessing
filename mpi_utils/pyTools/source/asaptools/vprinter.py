"""
A module containing the VPrinter class.

This module contains the VPrinter class that enables clean printing to
standard out (or a string) with verbosity-level print management.

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""


class VPrinter(object):

    """
    A Verbosity-enabled Printing Class.

    The VPrinter is designed to print messages to standard out, or optionally
    a string, as determined by a pre-set verbosity-level and/or on which
    parallel rank the VPrinter is instantiated.

    Attributes:
        header (str): A string to prepend to any print messages before
            they are printed
        verbosity (int): The verbosity level to use when determining if a
            message should be printed
    """

    def __init__(self, header='', verbosity=1):
        """
        Constructor - Creates an instance of a VPrinter object.

        Keyword Arguments:
            header (str): A string to prepend to any print messages before
                they are printed
            verbosity (int): The verbosity level to use when determining if a
                message should be printed
        """
        # The message header to prepend to messages if desired
        self.header = header

        # The verbosity level for determining if a message is printed
        self.verbosity = verbosity

    def to_str(self, *args, **kwargs):
        """
        Concatenates string representations of the input arguments.

        This takes a list of arguments of any length, converts each argument
        to a string representation, and concatenates them into a single string.

        Parameters:
            args (list): A list of arguments supplied to the function.  All 
                of these arguments will be concatenated together.

        Keyword Arguments:
            kwargs (dict): The dictionary of keyword arguments
                passed to the function.

        Returns:
            str: A single string with the arguments given converted to strings
                and concatenated together (in order).  If the keyword
                'header==True' is supplied, then the 'header' string is 
                prepended to the string before being output.

        Raises:
            TypeError: If the 'header' keyword argument is supplied and is 
                not a bool
        """
        out_args = []
        if 'header' in kwargs:
            if type(kwargs['header']) is bool:
                if kwargs['header']:
                    out_args.append(self.header)
            else:
                raise TypeError('Header keyword argument not bool')
        out_args.extend(args)

        return ''.join([str(arg) for arg in out_args])

    def __call__(self, *args, **kwargs):
        """
        Print the supplied arguments to standard out.

        Prints all supplied positional arguments to standard output, if the
        message verbosity is less than the VPrinter's verbosity level.  Can
        also print a useful header based on the parallel rank and size.

        Parameters:
            args (list): A list of arguments supplied to the function.  All 
                of these arguments will be concatenated together.

        Keyword Arguments:
            kwargs (dict): The dictionary of keyword arguments
                passed to the function.

        Returns:
            None: However, if the 'verbosity' keyword argument is supplied,
                and the 'verbosity' value is less than the VPrinter object's
                'verbosity' attribute, then it prints to stdout. Like
                the 'to_str' method, if the 'header' keyword is supplied and
                equal to 'True', then it prepends the output with the header.
        """
        verbosity = 0
        if 'verbosity' in kwargs and type(kwargs['verbosity']) is int:
            verbosity = kwargs['verbosity']

        if verbosity < self.verbosity:
            print self.to_str(*args, **kwargs)
