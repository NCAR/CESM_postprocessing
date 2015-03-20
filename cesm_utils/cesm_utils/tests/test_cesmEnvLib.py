#!/usr/bin/env python
"""
Unit test suite for the CESM utilities
"""
from __future__ import print_function

import os
import unittest

from cesm_utils import cesmEnvLib

class test_expand(unittest.TestCase):
    def setUp(self):
        self.src = { 'baz':'blue','bar':'$baz' }
        self.caseroot = '/Users/aliceb/sandboxes/runs/b.e13.B1850C5CN.f19_g16.01'
        self.env_file_list = [ 'env_run.xml', 'env_case.xml', 'env_diags_ocn.xml' ]

    def tearDown(self):
        pass

    def test_nothingToExpand(self):
        """ test to see if variable and dictionary passed in returns itself
        """
        value = 'foo'
        rc = cesmEnvLib.expand( value, self.src )
        self.assertEqual(rc, value)

    def test_somethingToExpand(self):
        """ test to see if variable and dictionary passed in returns itself
        """
        value = '$baz'
        rc = cesmEnvLib.expand( value, self.src )
        self.assertEqual(rc, 'blue')

    def test_readXML(self):
        """ test to see if readXML dictionary returned is expanded correctly
        """
        pass
        

if __name__ == '__main__':
    unittest.main()
