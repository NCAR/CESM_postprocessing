"""
Unit tests (serial only) for the TimeKeeper class

Copyright 2016, University Corporation for Atmospheric Research
See the LICENSE.txt file for details
"""

from __future__ import print_function

import unittest

from time import sleep
from asaptools import timekeeper


class TimeKeeperTests(unittest.TestCase):

    """
    Tests for the TimeKeeper class
    """

    def test_init(self):
        tk = timekeeper.TimeKeeper()
        self.assertEqual(type(tk), timekeeper.TimeKeeper,
                         'TimeKeeper class instantiated incorrectly.')

    def test_start_stop_names(self):
        tk = timekeeper.TimeKeeper()
        name = 'Test Clock'
        wait_time = 0.05
        tk.start(name)
        sleep(wait_time)
        tk.stop(name)
        self.assertTrue(name in tk._accumulated_times,
                        'Clock name not found in accumulated times dictionary')
        self.assertTrue(name in tk._added_order,
                        'Clock name not found in added order list')
        self.assertTrue(name in tk._start_times,
                        'Clock name not found in start times dictionary')

    def test_start_stop_values(self):
        tk = timekeeper.TimeKeeper()
        name = 'Test Clock'
        wait_time = 0.05
        tk.start(name)
        sleep(wait_time)
        tk.stop(name)
        dt = tk.get_time(name)
        dterr = abs(dt / wait_time - 1.0)
        self.assertTrue(dterr < 0.15, msg='Accumulated time seems off')

    def test_start_stop_order_names(self):
        tk = timekeeper.TimeKeeper()
        name1 = 'Test Clock 1'
        name2 = 'Test Clock 2'
        wait_time = 0.01
        tk.start(name1)
        sleep(wait_time)
        tk.stop(name1)
        tk.start(name2)
        sleep(wait_time)
        tk.stop(name2)
        self.assertEqual(name1, tk._added_order[0],
                         'Clock name 1 not appropriately ordered')
        self.assertEqual(name2, tk._added_order[1],
                         'Clock name 2 not appropriately ordered')

    def test_start_stop_values2(self):
        tk = timekeeper.TimeKeeper()
        name1 = 'Test Clock 1'
        name2 = 'Test Clock 2'
        wait_time = 0.05
        tk.start(name1)
        sleep(2 * wait_time)
        tk.start(name2)
        sleep(wait_time)
        tk.stop(name1)
        sleep(wait_time)
        tk.stop(name2)
        dt1 = tk.get_time(name1)
        dt1err = abs(dt1 / (3 * wait_time)  - 1.0) 
        self.assertTrue(dt1err < 0.15, msg='Accumulated time 1 seems off')
        dt2 = tk.get_time(name2)
        dt2err = abs(dt2 / (2 * wait_time)  - 1.0)
        self.assertTrue(dt2err < 0.15, msg='Accumulated time 1 seems off')

    def test_reset_values(self):
        tk = timekeeper.TimeKeeper()
        name = 'Test Clock'
        wait_time = 0.05
        tk.start(name)
        sleep(wait_time)
        tk.stop(name)
        tk.reset(name)
        self.assertEqual(0, tk.get_time(name),
                         msg='Accumulated time seems off')

    def test_get_time(self):
        tk = timekeeper.TimeKeeper()
        name = 'Test Clock'
        wait_time = 0.05
        tk.start(name)
        sleep(wait_time)
        tk.stop(name)
        dt = tk.get_time(name)
        dterr = abs(dt / wait_time - 1.0)
        self.assertTrue(dterr < 0.15, msg='Get time seems off')

    def test_get_all_times(self):
        tk = timekeeper.TimeKeeper()
        name1 = 'Test Clock 1'
        name2 = 'Test Clock 2'
        wait_time = 0.05
        tk.start(name1)
        sleep(2 * wait_time)
        tk.start(name2)
        sleep(wait_time)
        tk.stop(name1)
        sleep(wait_time)
        tk.stop(name2)
        all_times = tk.get_all_times()
        expected_all_times = {name1: 3 * wait_time,
                              name2: 2 * wait_time}
        self.assertTrue(len(expected_all_times.keys()) == len(all_times.keys()),
                        'Different number of time clonk names')
        self.assertTrue(all([i1==i2 for i1,i2 in 
                             zip(expected_all_times.keys(),all_times.keys())]),
                        'Clock names are not the same')
        self.assertAlmostEqual(list(expected_all_times.values())[0],
                               list(all_times.values())[0],
                               msg='Accumulated time 1 seems off',
                               places=1)
        self.assertAlmostEqual(list(expected_all_times.values())[1],
                               list(all_times.values())[1],
                               msg='Accumulated time 2 seems off',
                               places=1)


if __name__ == "__main__":
    #import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
