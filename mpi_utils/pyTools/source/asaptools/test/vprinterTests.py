"""
Tests of the verbose printer utility

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from __future__ import print_function

import unittest
import sys

from asaptools import vprinter
from os import linesep
try:
    from cStringIO import StringIO
except ImportError:
    from io import StringIO


def test_message(name, data, actual, expected):
    spcr = ' ' * len(name)
    return ''.join([name, ' - data:     ', str(data), linesep,
                    spcr, ' - actual:   ', str(actual), linesep,
                    spcr, ' - expected: ', str(expected), linesep])


class VPrinterTests(unittest.TestCase):

    def setUp(self):
        self.header = '[1] '
        self.vprint = vprinter.VPrinter(header=self.header, verbosity=2)

    def testToStr(self):
        data = ['a', 'b', 'c', 1, 2, 3, 4.0, 5.0, 6.0]
        actual = self.vprint.to_str(*data)
        expected = ''.join([str(d) for d in data])
        msg = test_message('to_str(*data)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)

    def testToStrHeader(self):
        data = ['a', 'b', 'c', 1, 2, 3, 4.0, 5.0, 6.0]
        actual = self.vprint.to_str(*data, header=True)
        expected = self.header + ''.join([str(d) for d in data])
        msg = test_message('to_str(*data)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)

    def testVPrint(self):
        data = ['a', 'b', 'c', 1, 2, 3, 4.0, 5.0, 6.0]
        backup = sys.stdout
        sys.stdout = StringIO()
        self.vprint(*data)
        actual = sys.stdout.getvalue()
        sys.stdout.close()
        sys.stdout = backup
        expected = self.vprint.to_str(*data) + linesep
        msg = test_message('vprint(*data)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)

    def testVPrintHeader(self):
        data = ['a', 'b', 'c', 1, 2, 3, 4.0, 5.0, 6.0]
        backup = sys.stdout
        sys.stdout = StringIO()
        self.vprint(*data, header=True)
        actual = sys.stdout.getvalue()
        sys.stdout.close()
        sys.stdout = backup
        expected = self.vprint.to_str(*data, header=True) + linesep
        msg = test_message('vprint(*data)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)

    def testVPrintVerbosityCut(self):
        data = ['a', 'b', 'c', 1, 2, 3, 4.0, 5.0, 6.0]
        backup = sys.stdout
        sys.stdout = StringIO()
        self.vprint(*data, verbosity=3)
        actual = sys.stdout.getvalue()
        sys.stdout.close()
        sys.stdout = backup
        expected = ''
        msg = test_message('vprint(*data)', data, actual, expected)
        print(msg)
        self.assertEqual(actual, expected, msg)


if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testToStr']
    unittest.main()
