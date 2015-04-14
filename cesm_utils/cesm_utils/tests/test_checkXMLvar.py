#!/usr/bin/env python
"""
Unit test suite for the CESM diagnostics wrapper scripts

"""

from __future__ import print_function

import os
import unittest

from cesm_utils import cesmEnvLib

class test_checkEnv(unittest.TestCase):
    def setUp(self):
        self.test_data = []

    def tearDown(self):
        pass

    def test_defaultEnvVar(self):
        """ test to see if path env can be read from through checkEnv
        """
        found = cesmEnvLib.checkEnv("PATH", ".")
        self.assertTrue(found)

    def test_invalidEnvVar(self):
        """ test to see if invalid var raises an error
        """
        self.assertRaises(Exception, cesmEnvLib.checkEnv, "blah", ".")

if __name__ == '__main__':
    unittest.main()
