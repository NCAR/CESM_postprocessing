"""
Physical Array Unit Tests

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from pyconform.physarray import PhysArray, CharArray, UnitsError, DimensionsError
from testutils import print_test_message
from cf_units import Unit

import unittest
import numpy
import operator
from numpy import testing as npt
from copy import deepcopy


#===============================================================================
# PhysArrayTests
#===============================================================================
class PhysArrayTests(unittest.TestCase):
    """
    Unit tests for basic aspects of the PhysArray class
    """

    def assertPhysArraysEqual(self, left, right, testname='Test', decimal=0):
        if type(left) != type(right):
            self.fail('{} failed - type')
        elif isinstance(left, PhysArray):
            if decimal == 0:
                npt.assert_array_equal(left, right, '{} failed - data'.format(testname))
            else:
                npt.assert_array_almost_equal(left, right, decimal, '{} failed - data'.format(testname))
            self.assertEqual(left.dtype, right.dtype, '{} failed - dtype'.format(testname))
            self.assertEqual(left.name, right.name, '{} failed - name'.format(testname))
            self.assertEqual(left.units, right.units, '{} failed - units'.format(testname))
            self.assertEqual(left.dimensions, right.dimensions, '{} failed - dimensions'.format(testname))
            self.assertEqual(left.positive, right.positive, '{} failed - positive'.format(testname))
        else:
            self.assertEqual(left, right, '{} failed')

    def test_init(self):
        inp = [(1, {}),
               (1.3, {}),
               ((1, 2, 3), {}),
               ([1, 2, 3], {}),
               (numpy.array([1, 2, 3], dtype=numpy.float64), {}),
               (PhysArray([1, 2, 3]), {}),
               ('asfeasefa', {}),
               (['asfeasefa', 'asfe', 'e'], {})]
        exp = [PhysArray(1),
               PhysArray(1.3),
               PhysArray((1, 2, 3)),
               PhysArray([1, 2, 3]),
               PhysArray(numpy.array([1,2,3], dtype=numpy.float64)),
               PhysArray([1, 2, 3]),
               CharArray('asfeasefa'),
               CharArray(['asfeasefa', 'asfe', 'e'])]
        for (arg, kwds), expected in zip(inp, exp):
            argstr = repr(arg)
            kwdstr = ', '.join('{}={!r}'.format(k, kwds[k]) for k in kwds)
            initstr = argstr + (', {}'.format(kwdstr) if len(kwds) > 0 else '')
            testname = 'PhysArray.__init__({})'.format(initstr)
            actual = PhysArray(arg, **kwds)
            print_test_message(testname, parameter=arg, keywords=kwds, actual=actual, expected=expected)
            self.assertPhysArraysEqual(actual, expected, testname)

    def test_init_units_default(self):
        testname = 'PhysArray(1.2, name="X").units'
        X = PhysArray(1.2, name='X')
        actual = X.units
        expected = Unit(1)
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_init_units_valid(self):
        valid_input = [Unit('m'), 'm', 1, 1e-7, Unit('days since 0001-01-01', calendar='noleap')]
        for indata in valid_input:
            testname = 'PhysArray(1.2, name="X", units={!r}).units'.format(indata)
            X = PhysArray(1.2, name='X', units=indata)
            actual = X.units
            expected = indata if isinstance(indata, Unit) else Unit(indata)
            print_test_message(testname, units=indata, actual=actual, expected=expected)
            self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_init_units_value_error(self):
        invalid_input = [[], (), 'alksfhenliaunseca']
        for indata in invalid_input:
            testname = 'PhysArray(1.2, name="X", units={!r})'.format(indata)
            expected = ValueError
            print_test_message(testname, units=indata, expected=expected)
            self.assertRaises(expected, PhysArray, 1.2, units=indata, name='X')

    def test_init_dimensions_default(self):
        testname = 'PhysArray([[1,2],[3,4]], name="X").dimensions'
        X = PhysArray([[1,2],[3,4]], name='X')
        actual = X.dimensions
        expected = (1,0)
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))
            
    def test_init_dimensions_valid(self):
        valid_input = [(1,), (1.4,), ('x',), [-1]]
        for indata in valid_input:
            testname = 'PhysArray([1,2,3], name="X", dimensions={!r}).dimensions'.format(indata)
            X = PhysArray([1,2,3], name='X', dimensions=indata)
            actual = X.dimensions
            expected = tuple(indata)
            print_test_message(testname, dimensions=indata, actual=actual, expected=expected)
            self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_init_dimensions_type_error(self):
        invalid_input = [1, 'x', -3.4]
        for indata in invalid_input:
            testname = 'PhysArray([1,2,3], name="X", dimensions={!r})'.format(indata)
            expected = TypeError
            print_test_message(testname, units=indata, expected=expected)
            self.assertRaises(expected, PhysArray, [1,2,3], dimensions=indata, name='X')

    def test_init_dimensions_value_error(self):
        invalid_input = [(1,2), ['a', 'b', 'c'], []]
        for indata in invalid_input:
            testname = 'PhysArray([1,2,3], name="X", dimensions={!r})'.format(indata)
            expected = ValueError
            print_test_message(testname, units=indata, expected=expected)
            self.assertRaises(expected, PhysArray, [1,2,3], dimensions=indata, name='X')

    def test_init_char(self):
        valid_input = [['asef', 'ae', 'dfht'], ('shfudnej', 'x')]
        for indata in valid_input:
            testname = 'PhysArray({}, name="X", dimensions=(x,n))'.format(indata)
            actual = PhysArray(indata, name='X', dimensions=('x','n'))
            expected = CharArray(indata, name='X', dimensions=('x','n'))
            print_test_message(testname, actual=actual, expected=expected)
            self.assertPhysArraysEqual(actual, expected, testname)

    def test_positive_default(self):
        nlist = range(3)
        testname = 'PhysArray({}, name="X").positive'.format(nlist)
        X = PhysArray(nlist, name='X')
        actual = X.positive
        expected = None
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_positive_none(self):
        nlist = range(3)
        indata = None
        testname = 'PhysArray({}, name="X", positive={!r}).positive'.format(nlist, indata)
        X = PhysArray(nlist, positive=indata, name='X')
        actual = X.positive
        expected = indata
        print_test_message(testname, actual=actual, expected=expected)
        self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_positive_valid_str(self):
        nlist = range(3)
        valid_indata = ['up', 'Up', 'UP', 'down', 'Down', 'DOWN', 'doWN']
        for indata in valid_indata:
            testname = 'PhysArray({}, positive={!r}).positive'.format(nlist, indata)
            X = PhysArray(nlist, positive=indata, name='X')
            actual = X.positive
            expected = indata.lower()
            print_test_message(testname, actual=actual, expected=expected)
            self.assertEqual(actual, expected, '{} failed'.format(testname))

    def test_positive_invalid(self):
        nlist = range(3)
        invalid_indata = ['x', 'y', 1, -1.0]
        for indata in invalid_indata:
            testname = 'PhysArray({}, name="X", positive={!r}).positive'.format(nlist, indata)
            expected = ValueError
            print_test_message(testname, expected=expected)
            self.assertRaises(expected, PhysArray, nlist, positive=indata, name='X')

    def test_cast(self):
        indata = PhysArray([1, 2, 3], name='X', units='m', dimensions=('x',), positive='up')
        testname = 'PhysArray({!r})'.format(indata)
        actual = PhysArray(indata)
        expected = indata
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertIsNot(actual, expected, '{} failed - same objects'.format(testname))
        self.assertPhysArraysEqual(actual, expected, testname)

    def test_cast_override(self):
        indata = PhysArray([1, 2, 3], name='X', units='m', dimensions=('x',), positive='up')
        overrides = {'name':"Y", 'units':1, 'dimensions': (5,), 'positive': "down"}
        overridestr = ','.join('{!s}={!r}'.format(k,overrides[k]) for k in overrides)
        testname = 'PhysArray({!r}, {})'.format(indata, overridestr)
        actual = PhysArray(indata, **overrides)
        expected = PhysArray([1, 2, 3], **overrides)
        print_test_message(testname, indata=indata, actual=actual, expected=expected)
        self.assertIsNot(actual, expected, '{} failed - same objects'.format(testname))
        self.assertPhysArraysEqual(actual, expected, testname)

    def test_flip(self):
        valid_input = [PhysArray(1.0, name='X', units='m'),
                       PhysArray(1.0, name='X', units='m', positive='up'),
                       PhysArray(1.0, name='X', units='m', positive='down')]
        valid_output = [PhysArray(1.0, name='X', units='m'),
                        PhysArray(-1.0, name='down(X)', units='m', positive='down'),
                        PhysArray(-1.0, name='up(X)', units='m', positive='up')]
        for inp, out in zip(valid_input, valid_output):
            testname = '{!r}.flip()'.format(inp)
            actual = inp.flip()
            expected = PhysArray(out)
            print_test_message(testname, actual=actual, expected=expected)
            self.assertPhysArraysEqual(actual, expected, testname=testname)

    def test_up(self):
        valid_input = [PhysArray(1.0, name='X', units='m'),
                       PhysArray(1.0, name='X', units='m', positive='up'),
                       PhysArray(1.0, name='X', units='m', positive='down')]
        valid_output = [PhysArray(1.0, name='up(X)', units='m', positive='up'),
                        PhysArray(1.0, name='X', units='m', positive='up'),
                        PhysArray(-1.0, name='up(X)', units='m', positive='up')]
        for inp, out in zip(valid_input, valid_output):
            testname = '{!r}.up()'.format(inp)
            actual = inp.up()
            expected = PhysArray(out)
            print_test_message(testname, actual=actual, expected=expected)
            self.assertPhysArraysEqual(actual, expected, testname=testname)

    def test_down(self):
        valid_input = [PhysArray(1.0, name='X', units='m'),
                       PhysArray(1.0, name='X', units='m', positive='up'),
                       PhysArray(1.0, name='X', units='m', positive='down')]
        valid_output = [PhysArray(1.0, name='down(X)', units='m', positive='down'),
                        PhysArray(-1.0, name='down(X)', units='m', positive='down'),
                        PhysArray(1.0, name='X', units='m', positive='down')]
        for inp, out in zip(valid_input, valid_output):
            testname = '{!r}.down()'.format(inp)
            actual = inp.down()
            expected = PhysArray(out)
            print_test_message(testname, actual=actual, expected=expected)
            self.assertPhysArraysEqual(actual, expected, testname=testname)

#===============================================================================
# PhysArrayBinOpTests
#===============================================================================
class PhysArrayBinOpTests(PhysArrayTests):
    """
    Unit tests for binary operators of the PhysArray class
    """

    def setUp(self):
        self.vs = {0: 1.0,
                   1: PhysArray(1.0),
                   2: PhysArray(1.0, positive='up'),
                   3: PhysArray(1.0, positive='down'),
                   4: PhysArray(1.0, units='m'),
                   5: PhysArray(1.0, units='cm'),
                   6: PhysArray(1.0, units=1),
                   7: PhysArray(1.0, units=.02),
                   8: PhysArray([1.0, 2.0, 3.0], dimensions=('x',)),
                   9: PhysArray([4.0, 5.0, 6.0], dimensions=('y',)),
                   10: PhysArray([[1.0, 2.0], [3.0, 4.0]], dimensions=('x', 'y')),
                   11: PhysArray([[1.0, 2.0], [3.0, 4.0]], dimensions=('y', 'x')),
                   12: PhysArray([[1.0, 2.0], [3.0, 4.0]], dimensions=('x', 'y'), positive='up'),
                   13: PhysArray([[1.0, 2.0], [3.0, 4.0]], dimensions=('y', 'x'), positive='down'),
                   14: 2,
                   15: PhysArray(3.0)}

    def _test_binary_operator_(self, binop, expvals, testname):
        for i,j in expvals:
            expected = expvals[(i,j)]
            X = PhysArray(deepcopy(self.vs[i]), name='X') if isinstance(self.vs[i], PhysArray) else deepcopy(self.vs[i])
            Y = PhysArray(deepcopy(self.vs[j]), name='Y') if isinstance(self.vs[j], PhysArray) else deepcopy(self.vs[j])
            
            print 'TEST ID: {}'.format((i,j))
            if type(expected) is type and issubclass(expected, Exception):
                print_test_message(testname, testid=(i,j), X=X, Y=Y, expected=expected)
                self.assertRaises(expected, binop, X, Y)
            else:
                actual = binop(X, Y)
                print_test_message(testname, testid=(i,j), X=X, Y=Y, actual=actual, expected=expected)
                self.assertPhysArraysEqual(actual, expected, testname)

    def test_add(self):
        expvals = {(0,1): PhysArray(2.0, name='(1.0+Y)'),
                   (1,0): PhysArray(2.0, name='(X+1.0)'),
                   (1,1): PhysArray(2.0, name='(X+Y)'),
                   (1,2): PhysArray(2.0, name='(up(X)+Y)', positive='up'),
                   (2,1): PhysArray(2.0, name='(X+up(Y))', positive='up'),
                   (1,3): PhysArray(2.0, name='(down(X)+Y)', positive='down'),
                   (2,3): PhysArray(0.0, name='(X+up(Y))', positive='up'),
                   (3,2): PhysArray(0.0, name='(X+down(Y))', positive='down'),
                   (4,5): PhysArray(1.01, name='(X+convert(Y, from=cm, to=m))', units='m'),
                   (6,7): PhysArray(1.02, name='(X+convert(Y, from=0.02, to=1))', units=1),
                   (1,8): PhysArray([2.0, 3.0, 4.0], name='(X+Y)', dimensions=('x',)),
                   (8,8): PhysArray([2.0, 4.0, 6.0], name='(X+Y)', dimensions=('x',)),
                   (8,9): PhysArray([[5., 6., 7.], [6., 7., 8.], [7., 8., 9.]], dimensions=('x','y'),
                                    name='(broadcast(X, from=[x], to=[x,y])+transpose(broadcast(Y, from=[y], to=[y,x]), from=[y,x], to=[x,y]))'),
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[2.0, 4.0], [6.0, 8.0]], name='(X+Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[2.0, 5.0], [5.0, 8.0]], name='(X+transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[2.0, 5.0], [5.0, 8.0]], name='(up(X)+transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[0.0, -1.0], [1.0, 0.0]], name='(X+up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.add, expvals, 'X + Y')

    def test_iadd(self):
        expvals = {(0,1): PhysArray(2.0, name='(1.0+Y)'),
                   (1,0): PhysArray(2.0, name='(X+1.0)'),
                   (1,1): PhysArray(2.0, name='(X+Y)'),
                   (1,2): PhysArray(2.0, name='(up(X)+Y)', positive='up'),
                   (2,1): PhysArray(2.0, name='(X+up(Y))', positive='up'),
                   (1,3): PhysArray(2.0, name='(down(X)+Y)', positive='down'),
                   (2,3): PhysArray(0.0, name='(X+up(Y))', positive='up'),
                   (3,2): PhysArray(0.0, name='(X+down(Y))', positive='down'),
                   (4,5): PhysArray(1.01, name='(X+convert(Y, from=cm, to=m))', units='m'),
                   (6,7): PhysArray(1.02, name='(X+convert(Y, from=0.02, to=1))', units=1),
                   (1,8): DimensionsError,
                   (8,8): PhysArray([2.0, 4.0, 6.0], name='(X+Y)', dimensions=('x',)),
                   (8,9): DimensionsError,
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[2.0, 4.0], [6.0, 8.0]], name='(X+Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[2.0, 5.0], [5.0, 8.0]], name='(X+transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[2.0, 5.0], [5.0, 8.0]], name='(up(X)+transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[0.0, -1.0], [1.0, 0.0]], name='(X+up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.iadd, expvals, 'X += Y')

    def test_sub(self):
        expvals = {(0,1): PhysArray(0.0, name='(1.0-Y)'),
                   (1,0): PhysArray(0.0, name='(X-1.0)'),
                   (1,1): PhysArray(0.0, name='(X-Y)'),
                   (1,2): PhysArray(0.0, name='(up(X)-Y)', positive='up'),
                   (2,1): PhysArray(0.0, name='(X-up(Y))', positive='up'),
                   (1,3): PhysArray(0.0, name='(down(X)-Y)', positive='down'),
                   (2,3): PhysArray(2.0, name='(X-up(Y))', positive='up'),
                   (3,2): PhysArray(2.0, name='(X-down(Y))', positive='down'),
                   (4,5): PhysArray(0.99, name='(X-convert(Y, from=cm, to=m))', units='m'),
                   (6,7): PhysArray(0.98, name='(X-convert(Y, from=0.02, to=1))', units=1),
                   (1,8): PhysArray([0.0, -1.0, -2.0], name='(X-Y)', dimensions=('x',)),
                   (8,8): PhysArray([0.0, 0.0, 0.0], name='(X-Y)', dimensions=('x',)),
                   (8,9): PhysArray([[-3., -4., -5.], [-2., -3., -4.], [-1., -2., -3.]], dimensions=('x','y'),
                                    name='(broadcast(X, from=[x], to=[x,y])-transpose(broadcast(Y, from=[y], to=[y,x]), from=[y,x], to=[x,y]))'),
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[0.0, 0.0], [0.0, 0.0]], name='(X-Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[0.0, -1.0], [1.0, 0.0]], name='(X-transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[0.0, -1.0], [1.0, 0.0]], name='(up(X)-transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[2.0, 5.0], [5.0, 8.0]], name='(X-up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.sub, expvals, 'X - Y')

    def test_isub(self):
        expvals = {(0,1): PhysArray(0.0, name='(1.0-Y)'),
                   (1,0): PhysArray(0.0, name='(X-1.0)'),
                   (1,1): PhysArray(0.0, name='(X-Y)'),
                   (1,2): PhysArray(0.0, name='(up(X)-Y)', positive='up'),
                   (2,1): PhysArray(0.0, name='(X-up(Y))', positive='up'),
                   (1,3): PhysArray(0.0, name='(down(X)-Y)', positive='down'),
                   (2,3): PhysArray(2.0, name='(X-up(Y))', positive='up'),
                   (3,2): PhysArray(2.0, name='(X-down(Y))', positive='down'),
                   (4,5): PhysArray(0.99, name='(X-convert(Y, from=cm, to=m))', units='m'),
                   (6,7): PhysArray(0.98, name='(X-convert(Y, from=0.02, to=1))', units=1),
                   (1,8): DimensionsError,
                   (8,8): PhysArray([0.0, 0.0, 0.0], name='(X-Y)', dimensions=('x',)),
                   (8,9): DimensionsError,
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[0.0, 0.0], [0.0, 0.0]], name='(X-Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[0.0, -1.0], [1.0, 0.0]], name='(X-transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[0.0, -1.0], [1.0, 0.0]], name='(up(X)-transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[2.0, 5.0], [5.0, 8.0]], name='(X-up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.isub, expvals, 'X -= Y')

    def test_mul(self):
        expvals = {(0,1): PhysArray(1.0, name='(1.0*Y)'),
                   (1,0): PhysArray(1.0, name='(X*1.0)'),
                   (1,1): PhysArray(1.0, name='(X*Y)'),
                   (1,2): PhysArray(1.0, name='(up(X)*Y)', positive='up'),
                   (2,1): PhysArray(1.0, name='(X*up(Y))', positive='up'),
                   (1,3): PhysArray(1.0, name='(down(X)*Y)', positive='down'),
                   (2,3): PhysArray(-1.0, name='(X*up(Y))', positive='up'),
                   (3,2): PhysArray(-1.0, name='(X*down(Y))', positive='down'),
                   (4,5): PhysArray(1.0, name='(X*Y)', units='0.01 m^2'),
                   (6,7): PhysArray(1.0, name='(X*Y)', units='0.02'),
                   (1,8): PhysArray([1.0, 2.0, 3.0], name='(X*Y)', dimensions=('x',)),
                   (8,8): PhysArray([1.0, 4.0, 9.0], name='(X*Y)', dimensions=('x',)),
                   (8,9): PhysArray([[4., 5., 6.], [8., 10., 12.], [12., 15., 18.]], dimensions=('x','y'),
                                    name='(broadcast(X, from=[x], to=[x,y])*transpose(broadcast(Y, from=[y], to=[y,x]), from=[y,x], to=[x,y]))'),
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[1.0, 4.0], [9.0, 16.0]], name='(X*Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[1.0, 6.0], [6.0, 16.0]], name='(X*transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[1.0, 6.0], [6.0, 16.0]], name='(up(X)*transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[-1.0, -6.0], [-6.0, -16.0]], name='(X*up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.mul, expvals, 'X * Y')

    def test_imul(self):
        expvals = {(0,1): PhysArray(1.0, name='(1.0*Y)'),
                   (1,0): PhysArray(1.0, name='(X*1.0)'),
                   (1,1): PhysArray(1.0, name='(X*Y)'),
                   (1,2): PhysArray(1.0, name='(up(X)*Y)', positive='up'),
                   (2,1): PhysArray(1.0, name='(X*up(Y))', positive='up'),
                   (1,3): PhysArray(1.0, name='(down(X)*Y)', positive='down'),
                   (2,3): PhysArray(-1.0, name='(X*up(Y))', positive='up'),
                   (3,2): PhysArray(-1.0, name='(X*down(Y))', positive='down'),
                   (4,5): PhysArray(1.0, name='(X*Y)', units='0.01 m^2'),
                   (6,7): PhysArray(1.0, name='(X*Y)', units='0.02'),
                   (1,8): DimensionsError,
                   (8,8): PhysArray([1.0, 4.0, 9.0], name='(X*Y)', dimensions=('x',)),
                   (8,9): DimensionsError,
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[1.0, 4.0], [9.0, 16.0]], name='(X*Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[1.0, 6.0], [6.0, 16.0]], name='(X*transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[1.0, 6.0], [6.0, 16.0]], name='(up(X)*transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[-1.0, -6.0], [-6.0, -16.0]], name='(X*up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.imul, expvals, 'X *= Y')

    def test_div(self):
        expvals = {(0,1): PhysArray(1.0, name='(1.0/Y)'),
                   (1,0): PhysArray(1.0, name='(X/1.0)'),
                   (1,1): PhysArray(1.0, name='(X/Y)'),
                   (1,2): PhysArray(1.0, name='(up(X)/Y)', positive='up'),
                   (2,1): PhysArray(1.0, name='(X/up(Y))', positive='up'),
                   (1,3): PhysArray(1.0, name='(down(X)/Y)', positive='down'),
                   (2,3): PhysArray(-1.0, name='(X/up(Y))', positive='up'),
                   (3,2): PhysArray(-1.0, name='(X/down(Y))', positive='down'),
                   (4,5): PhysArray(1.0, name='(X/Y)', units='100'),
                   (6,7): PhysArray(1.0, name='(X/Y)', units='50'),
                   (1,8): PhysArray([1.0, 0.5, 1/3.], name='(X/Y)', dimensions=('x',)),
                   (8,8): PhysArray([1.0, 1.0, 1.0], name='(X/Y)', dimensions=('x',)),
                   (8,9): PhysArray([[.25, .2, 1/6.], [.5, .4, 1/3.], [.75, 3/5., .5]], dimensions=('x','y'),
                                    name='(broadcast(X, from=[x], to=[x,y])/transpose(broadcast(Y, from=[y], to=[y,x]), from=[y,x], to=[x,y]))'),
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[1.0, 1.0], [1.0, 1.0]], name='(X/Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[1.0, 2/3.], [1.5, 1.0]], name='(X/transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[1.0, 2/3.], [1.5, 1.0]], name='(up(X)/transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[-1.0, -2/3.], [-1.5, -1.0]], name='(X/up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.div, expvals, 'X / Y')

    def test_idiv(self):
        expvals = {(0,1): PhysArray(1.0, name='(1.0/Y)'),
                   (1,0): PhysArray(1.0, name='(X/1.0)'),
                   (1,1): PhysArray(1.0, name='(X/Y)'),
                   (1,2): PhysArray(1.0, name='(up(X)/Y)', positive='up'),
                   (2,1): PhysArray(1.0, name='(X/up(Y))', positive='up'),
                   (1,3): PhysArray(1.0, name='(down(X)/Y)', positive='down'),
                   (2,3): PhysArray(-1.0, name='(X/up(Y))', positive='up'),
                   (3,2): PhysArray(-1.0, name='(X/down(Y))', positive='down'),
                   (4,5): PhysArray(1.0, name='(X/Y)', units='100'),
                   (6,7): PhysArray(1.0, name='(X/Y)', units='50'),
                   (1,8): DimensionsError,
                   (8,8): PhysArray([1.0, 1.0, 1.0], name='(X/Y)', dimensions=('x',)),
                   (8,9): DimensionsError,
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[1.0, 1.0], [1.0, 1.0]], name='(X/Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[1.0, 2/3.], [1.5, 1.0]], name='(X/transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[1.0, 2/3.], [1.5, 1.0]], name='(up(X)/transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[-1.0, -2/3.], [-1.5, -1.0]], name='(X/up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.idiv, expvals, 'X /= Y')

    def test_floordiv(self):
        expvals = {(0,1): PhysArray(1.0, name='(1.0//Y)'),
                   (1,0): PhysArray(1.0, name='(X//1.0)'),
                   (1,1): PhysArray(1.0, name='(X//Y)'),
                   (1,2): PhysArray(1.0, name='(up(X)//Y)', positive='up'),
                   (2,1): PhysArray(1.0, name='(X//up(Y))', positive='up'),
                   (1,3): PhysArray(1.0, name='(down(X)//Y)', positive='down'),
                   (2,3): PhysArray(-1.0, name='(X//up(Y))', positive='up'),
                   (3,2): PhysArray(-1.0, name='(X//down(Y))', positive='down'),
                   (4,5): PhysArray(1.0, name='(X//Y)', units='100'),
                   (6,7): PhysArray(1.0, name='(X//Y)', units='50'),
                   (1,8): PhysArray([1.0, 0., 0.], name='(X//Y)', dimensions=('x',)),
                   (8,8): PhysArray([1.0, 1.0, 1.0], name='(X//Y)', dimensions=('x',)),
                   (8,9): PhysArray([[0., 0., 0.], [0., 0., 0.], [0., 0., 0.]], dimensions=('x','y'),
                                    name='(broadcast(X, from=[x], to=[x,y])//transpose(broadcast(Y, from=[y], to=[y,x]), from=[y,x], to=[x,y]))'),
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[1.0, 1.0], [1.0, 1.0]], name='(X//Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[1., 0.], [1., 1.]], name='(X//transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[1., 0.], [1., 1.]], name='(up(X)//transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[-1., -1.], [-2., -1.]], name='(X//up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.floordiv, expvals, 'X // Y')

    def test_ifloordiv(self):
        expvals = {(0,1): PhysArray(1.0, name='(1.0//Y)'),
                   (1,0): PhysArray(1.0, name='(X//1.0)'),
                   (1,1): PhysArray(1.0, name='(X//Y)'),
                   (1,2): PhysArray(1.0, name='(up(X)//Y)', positive='up'),
                   (2,1): PhysArray(1.0, name='(X//up(Y))', positive='up'),
                   (1,3): PhysArray(1.0, name='(down(X)//Y)', positive='down'),
                   (2,3): PhysArray(-1.0, name='(X//up(Y))', positive='up'),
                   (3,2): PhysArray(-1.0, name='(X//down(Y))', positive='down'),
                   (4,5): PhysArray(1.0, name='(X//Y)', units='100'),
                   (6,7): PhysArray(1.0, name='(X//Y)', units='50'),
                   (1,8): DimensionsError,
                   (8,8): PhysArray([1.0, 1.0, 1.0], name='(X//Y)', dimensions=('x',)),
                   (8,9): DimensionsError,
                   (8,10): DimensionsError,
                   (10,10): PhysArray([[1., 1.], [1.0, 1.0]], name='(X//Y)', dimensions=('x', 'y')),
                   (10,11): PhysArray([[1., 0.], [1.0, 1.0]], name='(X//transpose(Y, from=[y,x], to=[x,y]))', dimensions=('x', 'y')),
                   (11,12): PhysArray([[1., 0.], [1.0, 1.0]], name='(up(X)//transpose(Y, from=[x,y], to=[y,x]))', dimensions=('y', 'x'), positive='up'),
                   (12,13): PhysArray([[-1., -1.], [-2.0, -1.0]], name='(X//up(transpose(Y, from=[y,x], to=[x,y])))', dimensions=('x', 'y'), positive='up')}
        self._test_binary_operator_(operator.ifloordiv, expvals, 'X //= Y')

    def test_mod(self):
        expvals = {(0,1): NotImplementedError,
                   (1,0): NotImplementedError,
                   (1,1): NotImplementedError}
        self._test_binary_operator_(operator.mod, expvals, 'X % Y')
        self._test_binary_operator_(operator.imod, expvals, 'X %= Y')

    def test_pow(self):
        expvals = {(1,14): PhysArray(1.0, name='(X**2)'),
                   (15,14): PhysArray(9.0, name='(X**2)'),
                   (8,14): PhysArray([1., 4., 9.], name='(X**2)', dimensions=('x',)),
                   (8,8): DimensionsError,
                   (8,4): UnitsError,
                   (2,14): PhysArray(1., name='(X**2)'),
                   (2,15): PhysArray(1., name='(X**Y)', positive='up')}
        self._test_binary_operator_(operator.pow, expvals, 'X ** Y')
        self._test_binary_operator_(operator.ipow, expvals, 'X **= Y')
        
    def test_convert(self):
        xdata = numpy.array(2., dtype='d')
        X = PhysArray(xdata, name='X', units='km')
        indata = 'm'
        testname = 'X.convert({})'.format(indata)
        actual = X.convert(Unit(indata))
        new_name = "convert({}, from={}, to={})".format(X.name, X.units, indata)
        expected = PhysArray(2000., name=new_name, units=indata)
        print_test_message(testname, actual=actual, expected=expected, X=X)
        self.assertPhysArraysEqual(actual, expected, testname=testname)

    def test_convert_error(self):
        xdata = numpy.array(2., dtype='d')
        X = PhysArray(xdata, name='X', units='km')
        indata = 'g'
        testname = 'X.convert({})'.format(indata)
        expected = UnitsError
        print_test_message(testname, expected=expected, X=X)
        self.assertRaises(expected, X.convert, indata)

    def test_transpose_dims(self):
        xdata = numpy.array([[1., 2.], [3., 4.]], dtype='d')
        X = PhysArray(xdata, name='X', units='m', dimensions=('u', 'v'))
        indata = ('v', 'u')
        testname = 'X.transpose({}, {})'.format(*indata)
        actual = X.transpose(*indata)
        new_name = "transpose({}, from=[u,v], to=[v,u])".format(X.name, indata)
        expected = PhysArray([[1., 3.], [2., 4.]], units=X.units,
                                       name=new_name, dimensions=indata)
        print_test_message(testname, actual=actual, expected=expected, X=X)
        self.assertPhysArraysEqual(actual, expected, testname=testname)

    def test_transpose_axes(self):
        xdata = numpy.array([[1., 2.], [3., 4.]], dtype='d')
        X = PhysArray(xdata, name='X', units='m', dimensions=('u', 'v'))
        indata = (1, 0)
        testname = 'X.transpose({}, {})'.format(*indata)
        actual = X.transpose(*indata)
        new_dims = ('v', 'u')
        new_name = "transpose({}, from=[u,v], to=[v,u])".format(X.name)
        expected = PhysArray([[1., 3.], [2., 4.]], units=X.units,
                                       name=new_name, dimensions=new_dims)
        print_test_message(testname, actual=actual, expected=expected, X=X)
        self.assertPhysArraysEqual(actual, expected, testname=testname)

    def test_transpose_axes_tuple(self):
        xdata = numpy.array([[1., 2.], [3., 4.]], dtype='d')
        X = PhysArray(xdata, name='X', units='m', dimensions=('u', 'v'))
        indata = (1, 0)
        testname = 'X.transpose({})'.format(indata)
        actual = X.transpose(indata)
        new_dims = ('v', 'u')
        new_name = "transpose({}, from=[u,v], to=[v,u])".format(X.name, new_dims)
        expected = PhysArray([[1., 3.], [2., 4.]], units=X.units,
                                       name=new_name, dimensions=new_dims)
        print_test_message(testname, actual=actual, expected=expected, X=X)
        self.assertPhysArraysEqual(actual, expected, testname=testname)


#===============================================================================
# Command-Line Operation
#===============================================================================
if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
