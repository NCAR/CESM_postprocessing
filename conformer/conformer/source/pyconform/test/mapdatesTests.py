"""
MapDates Unit Tests

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

import numpy as np
from cStringIO import StringIO
from pyconform.test.makeTestData import DataMaker
from pyconform import mapdates
import unittest

files=['test1.nc', 'test2.nc', 'test3.nc']

#===============================================================================
# dateMapTests
#===============================================================================
class dateMapTests(unittest.TestCase):

    def test_get_files_in_order(self):

        # Create some data that should be contiguous
        t = {'time': [3,3,3], 'space': 2}
        dm = DataMaker(dimensions=t, filenames=files)
        dm.write()

        # Call get_files_in_order and evaluate the return values
        ordered_files,counts,error = mapdates.get_files_in_order(files)
        self.assertTrue(ordered_files == ['test1.nc', 'test2.nc', 'test3.nc'],
                        "get_files_in_order, ordered_list".format())
        self.assertTrue(counts == [3,3,3],
                        "get_files_in_order, counts".format())
        self.assertTrue(error == 0,  "get_files_in_order, error".format())
        dm.clear()

    def test_get_files_out_of_order(self):
 
        # Create some data that is not contiguous
        a = np.asarray([1,2,3])
        b = np.asarray([7,8,9])
        c = np.asarray([4,5,6])
        t = {'time': [3,3,3], 'space': 2}
        dm = DataMaker(dimensions=t, vardata={'time': [a,b,c]}, filenames=files)
        dm.write()

        # Call get_files_in_order and evaluate the return values
        ordered_files,counts,error = mapdates.get_files_in_order(files)
        self.assertTrue(ordered_files == ['test1.nc', 'test3.nc', 'test2.nc'],
                        "get_files_in_order, ordered_list".format())
        self.assertTrue(counts == [3,3,3],
                        "get_files_in_order, counts".format())
        self.assertTrue(error == 0,  "get_files_in_order, error".format())
        dm.clear()

    def test_get_files_gap_between_files(self):

        # Create some data that is not contiguous
        a = np.asarray([1,2,3])
        b = np.asarray([4,5,6])
        c = np.asarray([10,11,12])
        t = {'time': [3,3,3], 'space': 2}
        dm = DataMaker(dimensions=t, vardata={'time': [a,b,c]}, filenames=files)
        dm.write()

        # Call get_files_in_order and evaluate the return values, return value should fail
        _ordered_files, _counts, error = mapdates.get_files_in_order(files)
        self.assertTrue(error == 1,  "get_files_in_order, error".format())
        dm.clear()

    def test_get_files_gap_in_a_file(self):

        # Create some data that is not contiguous
        a = np.asarray([1,2,4])
        b = np.asarray([5,6,7])
        c = np.asarray([8,9,10])
        t = {'time': [3,3,3], 'space': 2}
        dm = DataMaker(dimensions=t, vardata={'time': [a,b,c]}, filenames=files)
        dm.write()

        # Call get_files_in_order and evaluate the return values, return value should fail
        _ordered_files, _counts, error = mapdates.get_files_in_order(files)
        self.assertTrue(error == 1,  "get_files_in_order, error".format())
        dm.clear()

    def test_get_files_6hr(self):

        from collections import OrderedDict

        # Create some data that is not contiguous
        a = np.asarray([1,1.25,1.50,1.75])
        b = np.asarray([2,2.25,2.50,2.75])
        c = np.asarray([3,3.25,3.50,3.75])
        t = OrderedDict([('time', [4,4,4]),('space', 2)])
        dm = DataMaker(dimensions=t, vardata={'time': [a,b,c]}, filenames=files)
        dm.write()

        # Call get_files_in_order and evaluate the return values
        ordered_files,counts,error = mapdates.get_files_in_order(files)
        self.assertTrue(ordered_files == ['test1.nc', 'test2.nc', 'test3.nc'],
                        "get_files_in_order, ordered_list".format())
        self.assertTrue(counts == [4,4,4],
                        "get_files_in_order, counts".format())
        self.assertTrue(error == 0,  "get_files_in_order, error".format())
        dm.clear()

    def test_get_files_monthly(self):

        from collections import OrderedDict

        # Create some data 
        a = np.asarray([31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365])
        b1=[]
        c1=[]
        for i in range(0,12):
            b1.append(a[i]+365)
            c1.append(a[i]+730)
        b = np.asarray(b1)
        c = np.asarray(c1)  
        t = OrderedDict([('time', [12,12,12]),('space', 2)])
        dm = DataMaker(dimensions=t, vardata={'time': [a,b,c]}, filenames=files)
        dm.write()

        # Call get_files_in_order and evaluate the return values
        ordered_files,counts,error = mapdates.get_files_in_order(files)
        self.assertTrue(ordered_files == ['test1.nc', 'test2.nc', 'test3.nc'],
                        "get_files_in_order, ordered_list".format())
        self.assertTrue(counts == [12,12,12],
                        "get_files_in_order, counts".format())
        self.assertTrue(error == 0,  "get_files_in_order, error".format())
        dm.clear()

    def test_get_files_monthly_gap_between_files(self):

        from collections import OrderedDict

        # Create some data that is not contiguous
        a = np.asarray([31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334])
        b1=[]
        c1=[]
        for i in range(0,11):
            b1.append(a[i]+365)
            c1.append(a[i]+730)
        b = np.asarray(b1)
        c = np.asarray(c1)
        t = OrderedDict([('time', [11,11,11]),('space', 2)])
        dm = DataMaker(dimensions=t, vardata={'time': [a,b,c]}, filenames=files)
        dm.write()

        # Call get_files_in_order and evaluate the return values
        _ordered_files, _counts, error = mapdates.get_files_in_order(files)
        self.assertTrue(error == 1,  "get_files_in_order, error".format())
        dm.clear()

    def test_get_files_monthly_gap_in_a_file(self):

        from collections import OrderedDict

        # Create some data that is not contiguous
        a = np.asarray([31, 59, 90, 120, 151, 181, 212, 243, 273, 334, 365])
        b1=[]
        c1=[]
        for i in range(0,11):
            b1.append(a[i]+365)
            c1.append(a[i]+730)
        b = np.asarray(b1)
        c = np.asarray(c1)
        t = OrderedDict([('time', [11,11,11]),('space', 2)])
        dm = DataMaker(dimensions=t, vardata={'time': [a,b,c]}, filenames=files)
        dm.write()

        # Call get_files_in_order and evaluate the return values
        _ordered_files, _counts, error = mapdates.get_files_in_order(files)
        self.assertTrue(error == 1,  "get_files_in_order, error".format())
        dm.clear()

    def test_get_files_yearly(self):

        # Create some data 
        a = np.asarray([365, 730, 1095])
        b = np.asarray([1460, 1825, 2190])
        c = np.asarray([2555, 2920, 3285])
        t = {'time': [3,3,3], 'space': 2}
        dm = DataMaker(dimensions=t, vardata={'time': [a,b,c]}, filenames=files)
        dm.write()

        # Call get_files_in_order and evaluate the return values
        ordered_files,counts,error = mapdates.get_files_in_order(files)
        self.assertTrue(ordered_files == ['test1.nc', 'test2.nc', 'test3.nc'],
                        "get_files_in_order, ordered_list".format())
        self.assertTrue(counts == [3,3,3],
                        "get_files_in_order, counts".format())
        self.assertTrue(error == 0,  "get_files_in_order, error".format())
        dm.clear()

#===============================================================================
# Command-Line Operation
#===============================================================================
if __name__ == "__main__":
    hline = '=' * 70
    print hline
    print 'STANDARD OUTPUT FROM ALL TESTS:'
    print hline

    mystream = StringIO()
    tests = unittest.TestLoader().loadTestsFromTestCase(dateMapTests)
    unittest.TextTestRunner(stream=mystream).run(tests)

    print hline
    print 'TESTS RESULTS:'
    print hline
    print str(mystream.getvalue())


