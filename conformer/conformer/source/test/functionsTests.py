"""
Functions Unit Tests

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from pyconform import functions
from pyconform.physarray import PhysArray
from cf_units import Unit
from testutils import print_test_message

import unittest
import numpy as np
import operator as op


#===================================================================================================
# FindTests
#===================================================================================================
class FindTests(unittest.TestCase):
    """
    Unit tests for finding functions and operators
    """

    def setUp(self):
        self.all_operators = set((('-', 1), ('^', 2), ('+', 2),
                                  ('-', 2), ('*', 2), ('/', 2)))
        self.all_functions = set((('T', 2), ('sqrt', 1), ('C', 2)))
        self.all = (self.all_operators).union(self.all_functions)

    def test_operator_neg(self):
        key = '-'
        numargs = 1
        testname = 'find_operator({!r}, {})'.format(key, numargs)
        actual = functions.find_operator(key, numargs)
        expected = functions.NegationOperator
        print_test_message(testname, actual=actual, expected=expected, key=key, numargs=numargs)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_operator_add(self):
        key = '+'
        numargs = 2
        testname = 'find_operator({!r}, {})'.format(key, numargs)
        actual = functions.find_operator(key, numargs)
        expected = functions.AdditionOperator
        print_test_message(testname, actual=actual, expected=expected, key=key, numargs=numargs)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_operator_sub(self):
        key = '-'
        numargs = 2
        testname = 'find_operator({!r}, {})'.format(key, numargs)
        actual = functions.find_operator(key, numargs)
        expected = functions.SubtractionOperator
        print_test_message(testname, actual=actual, expected=expected, key=key, numargs=numargs)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_operator_mul(self):
        key = '*'
        testname = 'find_operator({!r})'.format(key)
        actual = functions.find_operator(key)
        expected = functions.MultiplicationOperator
        print_test_message(testname, key=key, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_operator_div(self):
        key = '/'
        testname = 'find_operator({!r})'.format(key)
        actual = functions.find_operator(key)
        expected = functions.DivisionOperator
        print_test_message(testname, key=key, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_operator_pow(self):
        key = '**'
        testname = 'find_operator({!r})'.format(key)
        actual = functions.find_operator(key)
        expected = functions.PowerOperator
        print_test_message(testname, key=key, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_operator_key_failure(self):
        key = '?'
        testname = 'find_operator({!r})'.format(key)
        expected = KeyError
        print_test_message(testname, key=key, expected=expected)
        self.assertRaises(KeyError, functions.find_operator, key)

    def test_operator_numargs_failure(self):
        key = '*'
        numargs = 1
        testname = 'find_operator({!r}, {})'.format(key, numargs)
        expected = KeyError
        print_test_message(testname, key=key, numargs=numargs, expected=expected)
        self.assertRaises(KeyError, functions.find_operator, key, numargs)

    def test_function_sqrt(self):
        key = 'sqrt'
        testname = 'find_function({!r})'.format(key)
        actual = functions.find_function(key)
        expected = functions.SquareRootFunction
        print_test_message(testname, key=key, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_function_key_failure(self):
        key = 'f'
        testname = 'find_function({!r})'.format(key)
        expected = KeyError
        print_test_message(testname, key=key, expected=expected)
        self.assertRaises(KeyError, functions.find_function, key)

    def test_sqrt(self):
        key = 'sqrt'
        testname = 'find({!r})'.format(key)
        actual = functions.find(key)
        expected = functions.SquareRootFunction
        print_test_message(testname, key=key, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_mul(self):
        key = '*'
        testname = 'find({!r})'.format(key)
        actual = functions.find(key)
        expected = functions.MultiplicationOperator
        print_test_message(testname, key=key, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        
    def test_key_failure(self):
        key = '?'
        testname = 'find({!r})'.format(key)
        expected = KeyError
        print_test_message(testname, key=key, expected=expected)
        self.assertRaises(KeyError, functions.find, key)

    def test_numargs_failure(self):
        key = '*'
        numargs = 3
        testname = 'find({!r}, {})'.format(key, numargs)
        expected = KeyError
        print_test_message(testname, key=key, numargs=numargs, expected=expected)
        self.assertRaises(KeyError, functions.find, key, numargs)

    def test_user_defined(self):
        class myfunc(functions.Function):
            key = 'myfunc'
            def __init__(self, x):
                super(myfunc, self).__init__(x)
            def __getitem__(self, index):
                return self.arguments[0][index]

        key = 'myfunc'
        testname = 'find({})'.format(key)
        actual = functions.find(key)
        expected = myfunc
        print_test_message(testname, key=key, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
    
    def test_list_operators(self):
        testname = 'list_operators()'
        actual = functions.list_operators()
        expected = sorted(functions.__OPERATORS__.keys())
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_list_functions(self):
        testname = 'list_functions()'
        actual = sorted(functions.list_functions())
        expected = sorted(['sqrt', 'mean', 'up', 'down', 'chunits', 'limit'])
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
        

#===============================================================================
# EvaluationTests
#===============================================================================
class EvaluationTests(unittest.TestCase):
    """
    Unit tests for evaluating functions and operators
    """

    def test_op_neg_int(self):
        key = '-'
        indata = 3
        testname = '({}{})'.format(key, indata)
        funcref = functions.find(key, 1)
        func = funcref(indata)
        actual = func[:]
        expected = op.neg(indata)
        print_test_message(testname, input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_neg_float(self):
        key = '-'
        indata = 3.1
        testname = '({}{})'.format(key, indata)
        func = functions.find(key, 1)
        actual = func(indata)[:]
        expected = op.neg(indata)
        print_test_message(testname, input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_neg_physarray(self):
        key = '-'
        indata = PhysArray(3, units='m')
        testname = '({}{})'.format(key, indata)
        funcref = functions.find(key, 1)
        func = funcref(indata)
        actual = func[:]
        expected = PhysArray(-3, name='3', units='m')
        print_test_message(testname, input=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed'.format(testname))

    def test_op_add_int(self):
        key = '+'
        left = 2
        right = 3
        testname = '({} {} {})'.format(left, key, right)
        funcref = functions.find(key, 2)
        func = funcref(left, right)
        actual = func[:]
        expected = 5
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_add_float(self):
        key = '+'
        left = 2.4
        right = 3.2
        testname = '({} {} {})'.format(left, key, right)
        funcref = functions.find(key, 2)
        func = funcref(left, right)
        actual = func[:]
        expected = 5.6
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_add_physarray(self):
        key = '+'
        x = PhysArray(1.5, name='x', units='m')
        y = PhysArray(7.9, name='y', units='km')
        testname = '({} {} {})'.format(x, key, y)
        funcref = functions.find(key, 2)
        func = funcref(x, y)
        actual = func[:]
        expected = PhysArray(7901.5, name='(x+convert(y, from=km, to=m))', units='m')
        print_test_message(testname, actual=actual, expected=expected, x=x, y=y)
        self.assertEqual(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))

    def test_op_sub_int(self):
        key = '-'
        left = 2
        right = 3
        testname = '({} {} {})'.format(left, key, right)
        funcref = functions.find(key, 2)
        func = funcref(left, right)
        actual = func[:]
        expected = -1
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_sub_float(self):
        key = '-'
        left = 2.4
        right = 3.2
        testname = '({} {} {})'.format(left, key, right)
        funcref = functions.find(key, 2)
        func = funcref(left, right)
        actual = func[:]
        expected = 2.4 - 3.2
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_sub_physarray(self):
        key = '-'
        x = PhysArray(1.5, name='x', units='m')
        y = PhysArray(7.9, name='y', units='km')
        testname = '({} {} {})'.format(x, key, y)
        func = functions.find(key, 2)
        actual = func(x, y)[:]
        expected = PhysArray(-7898.5, name='(x-convert(y, from=km, to=m))', units='m')
        print_test_message(testname, actual=actual, expected=expected, x=x, y=y)
        self.assertEqual(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))

    def test_op_mul_int(self):
        key = '*'
        left = 2
        right = 3
        testname = '({} {} {})'.format(left, key, right)
        funcref = functions.find(key, 2)
        func = funcref(left, right)
        actual = func[:]
        expected = 6
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_mul_float(self):
        key = '*'
        left = 2.4
        right = 3.2
        testname = '({} {} {})'.format(left, key, right)
        funcref = functions.find(key, 2)
        func = funcref(left, right)
        actual = func[:]
        expected = 2.4 * 3.2
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_mul_physarray(self):
        key = '*'
        x = PhysArray(1.5, name='x', units='m')
        y = PhysArray(7.9, name='y', units='km')
        testname = '({} {} {})'.format(x, key, y)
        func = functions.find(key, 2)
        actual = func(x, y)[:]
        expected = PhysArray(1.5 * 7.9, name='(x*y)', units='m-km')
        print_test_message(testname, actual=actual, expected=expected, x=x, y=y)
        self.assertEqual(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))

    def test_op_div_int(self):
        key = '/'
        left = 7
        right = 3
        testname = '({} {} {})'.format(left, key, right)
        funcref = functions.find(key, 2)
        func = funcref(left, right)
        actual = func[:]
        expected = 2
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_div_float(self):
        key = '/'
        left = 2.4
        right = 3.2
        testname = '({} {} {})'.format(left, key, right)
        funcref = functions.find(key, 2)
        func = funcref(left, right)
        actual = func[:]
        expected = 2.4 / 3.2
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_div_physarray(self):
        key = '/'
        x = PhysArray(1.5, name='x', units='m')
        y = PhysArray(7.9, name='y', units='km')
        testname = '({} {} {})'.format(x, key, y)
        func = functions.find(key, 2)
        actual = func(x, y)[:]
        expected = PhysArray(1.5 / 7.9, name='(x/y)', units='0.001 1')
        print_test_message(testname, actual=actual, expected=expected, x=x, y=y)
        np.testing.assert_array_almost_equal(actual, expected, 16,
                                             '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))

    def test_op_pow_int(self):
        key = '**'
        left = 7
        right = 3
        testname = '({} {} {})'.format(left, key, right)
        func = functions.find(key, 2)
        actual = func(left, right)[:]
        expected = 7 ** 3
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_pow_float(self):
        key = '**'
        left = 2.4
        right = 3.2
        testname = '({} {} {})'.format(left, key, right)
        func = functions.find(key, 2)
        actual = func(left, right)[:]
        expected = 2.4 ** 3.2
        print_test_message(testname, actual=actual, expected=expected, left=left, right=right)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_op_pow_physarray(self):
        key = '**'
        x = PhysArray(4.3, name='x', units='m')
        y = PhysArray(2, name='y')
        testname = '({} {} {})'.format(x, key, y)
        func = functions.find(key, 2)
        actual = func(x, y)[:]
        expected = PhysArray(4.3 ** 2, name='(x**y)', units=Unit('m') ** 2)
        print_test_message(testname, actual=actual, expected=expected, x=x, y=y)
        self.assertEqual(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))

    def test_func_sqrt_int(self):
        key = 'sqrt'
        indata = 4
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        actual = func(indata)[:]
        expected = np.sqrt(indata)
        print_test_message(testname, input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))\

    def test_func_sqrt_float(self):
        key = 'sqrt'
        indata = 4.0
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        fobj = func(indata)
        actual = fobj[:]
        expected = np.sqrt(indata)
        print_test_message(testname, input=indata, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_func_sqrt_physarray(self):
        key = 'sqrt'
        indata = PhysArray([9.0, 16.0, 4.0], name='x', units='m^2')
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        actual = func(indata)[:]
        expected = PhysArray([3.0, 4.0, 2.0], name='sqrt(x)', units='m')
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))

    def test_func_mean_ndarray(self):
        key = 'mean'
        indata = PhysArray([1.0, 2.0, 3.0], name='x', units='m', dimensions=('t',))
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        fobj = func(indata, 't')
        actual = fobj[:]
        expected = PhysArray(2.0, name='mean(x, dims=[t])', units='m')
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))
        
    def test_func_mean_physarray(self):
        key = 'mean'
        indata = PhysArray([1.0, 2.0, 3.0], mask=[False, False, True], name='x', units='m', dimensions=('t',))
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        fobj = func(indata, 't')
        actual = fobj[:]
        expected = PhysArray(1.5, name='mean(x, dims=[t])', units='m')
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))

    def test_func_mean_physarray_2d(self):
        key = 'mean'
        indata = PhysArray([[1.0, 2.0], [3.0, 4.0]], mask=[[False, False], [True, False]], name='x', units='m', dimensions=('t','u'))
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        fobj = func(indata, 't')
        actual = fobj[:]
        expected = PhysArray([1.0, 3.0], name='mean(x, dims=[t])', units='m', dimensions=('u',))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))
        
    def test_func_sqrt_sumlike(self):
        key = 'sqrt'
        testname = '{}.sumlike_dimensions'.format(key)
        func = functions.find(key)
        actual = func(2.0).sumlike_dimensions
        expected = set()
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_func_mean_sumlike(self):
        key = 'mean'
        indata = PhysArray([1.0, 2.0, 3.0, 4.0, 5.0], name='x', units='m', dimensions=('t',))
        testname = '{}({}).sumlike_dimensions'.format(key, indata)
        func = functions.find(key)
        fobj = func(indata, 't')
        fobj[None]
        actual = fobj.sumlike_dimensions
        expected = set(['t'])
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_func_up_physarray_none(self):
        key = 'up'
        indata = PhysArray(2.5, name='x')
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        actual = func(indata)[:]
        expected = PhysArray(indata, name='up(x)', positive='up')
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.positive, expected.positive, '{} failed - positive'.format(testname))

    def test_func_up_physarray_up(self):
        key = 'up'
        indata = PhysArray(2.5, name='x', positive='up')
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        actual = func(indata)[:]
        expected = PhysArray(indata, name='x', positive='up')
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.positive, expected.positive, '{} failed - positive'.format(testname))
        
    def test_func_up_physarray_down(self):
        key = 'up'
        indata = PhysArray(2.5, name='x', positive='down')
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        actual = func(indata)[:]
        expected = PhysArray(-2.5, name='up(x)', positive='up')
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.positive, expected.positive, '{} failed - positive'.format(testname))

    def test_func_down_physarray_none(self):
        key = 'down'
        indata = PhysArray(2.5, name='x')
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        actual = func(indata)[:]
        expected = PhysArray(indata, name='down(x)', positive='down')
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.positive, expected.positive, '{} failed - positive'.format(testname))

    def test_func_down_physarray_down(self):
        key = 'down'
        indata = PhysArray(2.5, name='x', positive='down')
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        actual = func(indata)[:]
        expected = PhysArray(2.5, name='x', positive='down')
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.positive, expected.positive, '{} failed - positive'.format(testname))

    def test_func_down_physarray_up(self):
        key = 'down'
        indata = PhysArray(2.5, name='x', positive='up')
        testname = '{}({})'.format(key, indata)
        func = functions.find(key)
        actual = func(indata)[:]
        expected = PhysArray(-2.5, name='down(x)', positive='down')
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.positive, expected.positive, '{} failed - positive'.format(testname))

    def test_func_chunits(self):
        key = 'chunits'
        indata = PhysArray(2.5, name='x', units='m')
        new_units = 'kg'
        testname = '{}({}, units={})'.format(key, indata, new_units)
        func = functions.find(key)
        actual = func(indata, units=new_units)[:]
        expected = PhysArray(2.5, name='chunits(x, units=kg)', units=new_units)
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))

    def test_func_chunits_calendar(self):
        key = 'chunits'
        indata = PhysArray(2.5, name='t', units=Unit('days since 1850-01-01', calendar='noleap'))
        new_cal = 'gregorian'
        testname = '{}({}, calendar={})'.format(key, indata, new_cal)
        func = functions.find(key)
        actual = func(indata, calendar=new_cal)[:]
        expected = PhysArray(2.5, name='chunits(t, units=days since 1850-01-01|gregorian)',
                             units=Unit('days since 1850-01-01', calendar=new_cal))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))
       
    def test_func_chunits_refdate(self):
        key = 'chunits'
        indata = PhysArray(2.5, name='t', units=Unit('days since 1850-01-01', calendar='noleap'))
        new_ref = '0001-01-01'
        testname = '{}({}, refdate={})'.format(key, indata, new_ref)
        func = functions.find(key)
        actual = func(indata, refdate=new_ref)[:]
        expected = PhysArray(2.5, name='chunits(t, units=days since {}|noleap)'.format(new_ref),
                             units=Unit('days since {}'.format(new_ref), calendar='noleap'))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))
 
    def test_func_chunits_refdate_calendar(self):
        key = 'chunits'
        indata = PhysArray(2.5, name='t', units=Unit('days since 1850-01-01', calendar='noleap'))
        new_ref = '0001-01-01'
        new_cal = 'gregorian'
        testname = '{}({}, refdate={}, calendar={})'.format(key, indata, new_ref, new_cal)
        func = functions.find(key)
        actual = func(indata, refdate=new_ref, calendar=new_cal)[:]
        expected = PhysArray(2.5, name='chunits(t, units=days since {}|{})'.format(new_ref, new_cal),
                             units=Unit('days since {}'.format(new_ref), calendar=new_cal))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))
        
    def test_func_limit(self):
        key = 'limit'
        indata = PhysArray([2.5, 7.3, 8.2, 1.4], name='x', units='m', dimensions=('t',))
        below_val = 3.0
        above_val = 7.5
        testname = '{}({}, above={}, below={})'.format(key, indata, above_val, below_val)
        func = functions.find(key)
        actual = func(indata, above=above_val, below=below_val)[:]
        expected = PhysArray([3.0, 7.3, 7.5, 3.0], name=testname, units='m', dimensions=('t',))
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        np.testing.assert_array_equal(actual, expected, '{} failed - data'.format(testname))
        self.assertEqual(actual.name, expected.name, '{} failed - name'.format(testname))
        self.assertEqual(actual.units, expected.units, '{} failed - units'.format(testname))
        

#===============================================================================
# Command-Line Operation
#===============================================================================
if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
