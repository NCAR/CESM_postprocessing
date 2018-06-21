"""
Parsing Unit Tests

Copyright 2017-2018, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from pyconform import parsing
from testutils import print_test_message

import unittest


#=========================================================================
# ParsedStringTypeTests
#=========================================================================
class ParsedStringTypeTests(unittest.TestCase):

    def test_pst_init(self):
        indata = ['x']
        pst = parsing.FuncType(*indata)
        actual = type(pst)
        expected = parsing.FuncType
        testname = 'FuncType.__init__({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Types do not match')

    def test_varpst_init(self):
        indata = ['x']
        pst = parsing.VarType(*indata)
        actual = type(pst)
        expected = parsing.VarType
        testname = 'VarType.__init__({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Types do not match')

    def test_funcpst_init(self):
        indata = (['x'], {})
        pst = parsing.FuncType(indata)
        actual = type(pst)
        expected = parsing.FuncType
        testname = 'FuncType.__init__({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Types do not match')

    def test_operpst_init(self):
        indata = (['x'], {})
        pst = parsing.OpType(indata)
        actual = type(pst)
        expected = parsing.OpType
        testname = 'OpType.__init__({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Types do not match')

    def test_pst_init_args(self):
        indata = (['x', 1, -3.2], {})
        pst = parsing.FuncType(indata)
        actual = type(pst)
        expected = parsing.FuncType
        testname = 'FuncType.__init__({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Types do not match')

    def test_pst_func_key(self):
        indata = ['x', [1, -3.2], {}]
        pst = parsing.FuncType(*indata)
        actual = pst.key
        expected = indata[0]
        testname = 'FuncType.__init__({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Key does not match')

    def test_pst_func_args(self):
        indata = ['x', [1, -3.2], {}]
        pst = parsing.FuncType(*indata)
        actual = pst.args
        expected = indata[1]
        testname = 'FuncType.__init__({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Args do not match')

    def test_pst_func_kwds(self):
        indata = ['x', [1, -3.2], {'x': 5}]
        pst = parsing.FuncType(*indata)
        actual = pst.kwds
        expected = {'x': 5}
        testname = 'FuncType.__init__({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Args do not match')


#=========================================================================
# DefinitionParserTests
#=========================================================================
class DefinitionParserTests(unittest.TestCase):

    #===== QUOTED STRINGS ====================================================

    def test_parse_quote_funcarg_int(self):
        indata = 'f("1")'
        actual = parsing.parse_definition(indata)
        expected = parsing.FuncType('f', ['1'])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'String parsing failed')

    def test_parse_quote_funcarg_kwd(self):
        indata = 'f(a="1")'
        actual = parsing.parse_definition(indata)
        expected = parsing.FuncType('f', [], {'a': '1'})
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'String parsing failed')

    def test_parse_quote_funcarg(self):
        indata = 'f("Hello, World!")'
        actual = parsing.parse_definition(indata)
        expected = parsing.FuncType('f', ['Hello, World!'])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'String parsing failed')

    def test_parse_quote_funcarg_escaped(self):
        indata = 'f(\'"1"\')'
        actual = parsing.parse_definition(indata)
        expected = parsing.FuncType('f', ['"1"'])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'String parsing failed')

    def test_parse_quote_funcarg_func(self):
        indata = 'g("f(x,y,z)")'
        actual = parsing.parse_definition(indata)
        expected = parsing.FuncType('g', ['f(x,y,z)'])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'String parsing failed')

#===== INTEGERS ==========================================================

    def test_parse_integer(self):
        indata = '1'
        actual = parsing.parse_definition(indata)
        expected = int(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Integer parsing failed')

    def test_parse_integer_large(self):
        indata = '98734786423867234'
        actual = parsing.parse_definition(indata)
        expected = int(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Integer parsing failed')

#===== FLOATS ============================================================

    def test_parse_float_dec(self):
        indata = '1.'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_long(self):
        indata = '1.8374755'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_nofirst(self):
        indata = '.35457'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_exp(self):
        indata = '1e7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_pos_exp(self):
        indata = '1e+7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_neg_exp(self):
        indata = '1e-7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_exp(self):
        indata = '1.e7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_pos_exp(self):
        indata = '1.e+7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_neg_exp(self):
        indata = '1.e-7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_long_exp(self):
        indata = '1.324523e7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_long_pos_exp(self):
        indata = '1.324523e+7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_long_neg_exp(self):
        indata = '1.324523e-7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_nofirst_exp(self):
        indata = '.324523e7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_nofirst_pos_exp(self):
        indata = '.324523e+7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

    def test_parse_float_dec_nofirst_neg_exp(self):
        indata = '.324523e-7'
        actual = parsing.parse_definition(indata)
        expected = float(indata)
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Float parsing failed')

#===== FUNCTIONS =========================================================

    def test_parse_func(self):
        indata = 'f()'
        actual = parsing.parse_definition(indata)
        expected = parsing.FuncType('f')
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Function parsing failed')

    def test_parse_func_arg(self):
        indata = 'f(1)'
        actual = parsing.parse_definition(indata)
        expected = parsing.FuncType('f', [1])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Function parsing failed')

    def test_parse_func_nested(self):
        indata = 'f(1, g(2))'
        g2 = parsing.FuncType('g', [2])
        f1g = parsing.FuncType('f', [1, g2])
        actual = parsing.parse_definition(indata)
        expected = f1g
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Function parsing failed')

#===== VARIABLES =========================================================

    def test_parse_var(self):
        indata = 'x'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('x')
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Variable parsing failed')

    def test_parse_var_index(self):
        indata = 'x[1]'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('x', [1])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Variable parsing failed')

    def test_parse_var_slice(self):
        indata = 'x[1:2:3]'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('x', [slice(1, 2, 3)])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Variable parsing failed')

    def test_parse_var_int_slice(self):
        indata = 'x[3,1:2]'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('x', [3, slice(1, 2, None)])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Variable parsing failed')

    def test_parse_var_slice_empty(self):
        indata = 'x[:]'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('x', [slice(None)])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Variable parsing failed')

    def test_parse_var_slice_partial_1(self):
        indata = 'x[1:]'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('x', [slice(1, None)])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Variable parsing failed')

    def test_parse_var_slice_partial_2(self):
        indata = 'x[:2]'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('x', [slice(None, 2)])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Variable parsing failed')

    def test_parse_var_slice_partial_3(self):
        indata = 'x[::-1]'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('x', [slice(None, None, -1)])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Variable parsing failed')

    def test_parse_var_slice_partial_4(self):
        indata = 'x[::-1::::]'
        expected = TypeError
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata, expected=expected)
        self.assertRaises(expected, parsing.parse_definition, indata)

    def test_parse_var_time(self):
        indata = 'time'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('time')
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Variable time parsing failed')


#===== NEGATION ==========================================================

    def test_parse_neg_integer(self):
        indata = '-1'
        actual = parsing.parse_definition(indata)
        expected = -1
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Negation parsing failed')

    def test_parse_neg_float(self):
        indata = '-1.4'
        actual = parsing.parse_definition(indata)
        expected = -1.4
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Negation parsing failed')

    def test_parse_neg_var(self):
        indata = '-x'
        actual = parsing.parse_definition(indata)
        x = parsing.VarType('x')
        expected = parsing.OpType('-', [x])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Negation parsing failed')

    def test_parse_neg_func(self):
        indata = '-f()'
        actual = parsing.parse_definition(indata)
        f = parsing.FuncType('f')
        expected = parsing.OpType('-', [f])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Negation parsing failed')

#===== POSITIVE ==========================================================

    def test_parse_pos_integer(self):
        indata = '+1'
        actual = parsing.parse_definition(indata)
        expected = 1
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Positive operator parsing failed')

    def test_parse_pos_float(self):
        indata = '+1e7'
        actual = parsing.parse_definition(indata)
        expected = 1e7
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Positive operator parsing failed')

    def test_parse_pos_func(self):
        indata = '+f()'
        actual = parsing.parse_definition(indata)
        expected = parsing.FuncType('f')
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Positive operator parsing failed')

    def test_parse_pos_var(self):
        indata = '+x[1]'
        actual = parsing.parse_definition(indata)
        expected = parsing.VarType('x', [1])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Positive operator parsing failed')

#===== POWER =============================================================

    def test_parse_int_pow_int(self):
        indata = '2**1'
        actual = parsing.parse_definition(indata)
        expected = 2
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Power operator parsing failed')

    def test_parse_float_pow_float(self):
        indata = '2.4 ** 3.5'
        actual = parsing.parse_definition(indata)
        expected = 2.4 ** 3.5
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Power operator parsing failed')

    def test_parse_func_pow_func(self):
        indata = 'f() ** g(1)'
        actual = parsing.parse_definition(indata)
        f = parsing.FuncType('f')
        g1 = parsing.FuncType('g', [1])
        expected = parsing.OpType('**', [f, g1])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Power operator parsing failed')

    def test_parse_var_pow_var(self):
        indata = 'x[1] ** y'
        actual = parsing.parse_definition(indata)
        x1 = parsing.VarType('x', [1])
        y = parsing.VarType('y')
        expected = parsing.OpType('**', [x1, y])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Power operator parsing failed')

#===== DIV ===============================================================

    def test_parse_int_div_int(self):
        indata = '2/1'
        actual = parsing.parse_definition(indata)
        expected = 2 / 1
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Division operator parsing failed')

    def test_parse_float_div_float(self):
        indata = '2.4/1e7'
        actual = parsing.parse_definition(indata)
        expected = 2.4 / 1e7
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Division operator parsing failed')

    def test_parse_func_div_func(self):
        indata = 'f() / g(1)'
        actual = parsing.parse_definition(indata)
        f = parsing.FuncType('f')
        g1 = parsing.FuncType('g', [1])
        expected = parsing.OpType('/', [f, g1])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Division operator parsing failed')

    def test_parse_var_div_var(self):
        indata = 'x[1] / y'
        actual = parsing.parse_definition(indata)
        x1 = parsing.VarType('x', [1])
        y = parsing.VarType('y')
        expected = parsing.OpType('/', [x1, y])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Division operator parsing failed')

#===== MUL ===============================================================

    def test_parse_int_mul_int(self):
        indata = '2*1'
        actual = parsing.parse_definition(indata)
        expected = 2
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Multiplication operator parsing failed')

    def test_parse_float_mul_float(self):
        indata = '2.4*1e7'
        actual = parsing.parse_definition(indata)
        expected = 2.4 * 1e7
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Multiplication operator parsing failed')

    def test_parse_func_mul_func(self):
        indata = 'f() * g(1)'
        actual = parsing.parse_definition(indata)
        f = parsing.FuncType('f')
        g1 = parsing.FuncType('g', [1])
        expected = parsing.OpType('*', [f, g1])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Multiplication operator parsing failed')

    def test_parse_var_mul_var(self):
        indata = 'x[1] * y'
        actual = parsing.parse_definition(indata)
        x1 = parsing.VarType('x', [1])
        y = parsing.VarType('y')
        expected = parsing.OpType('*', [x1, y])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Multiplication operator parsing failed')

#===== ADD ===============================================================

    def test_parse_int_add_int(self):
        indata = '2+1'
        actual = parsing.parse_definition(indata)
        expected = 3
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Addition operator parsing failed')

    def test_parse_float_add_float(self):
        indata = '2.4+1e7'
        actual = parsing.parse_definition(indata)
        expected = 1e7 + 2.4
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Addition operator parsing failed')

    def test_parse_func_add_func(self):
        indata = 'f() + g(1)'
        actual = parsing.parse_definition(indata)
        f = parsing.FuncType('f')
        g1 = parsing.FuncType('g', [1])
        expected = parsing.OpType('+', [f, g1])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Addition operator parsing failed')

    def test_parse_var_add_var(self):
        indata = 'x[1] + y'
        actual = parsing.parse_definition(indata)
        x1 = parsing.VarType('x', [1])
        y = parsing.VarType('y')
        expected = parsing.OpType('+', [x1, y])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected, 'Addition operator parsing failed')

#===== SUB ===============================================================

    def test_parse_int_sub_int(self):
        indata = '2-1'
        actual = parsing.parse_definition(indata)
        expected = 1
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Subtraction operator parsing failed')

    def test_parse_float_sub_float(self):
        indata = '2.4-1e7'
        actual = parsing.parse_definition(indata)
        expected = 2.4 - 1e7
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Subtraction operator parsing failed')

    def test_parse_func_sub_func(self):
        indata = 'f() - g(1)'
        actual = parsing.parse_definition(indata)
        f = parsing.FuncType('f')
        g1 = parsing.FuncType('g', [1])
        expected = parsing.OpType('-', [f, g1])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Subtraction operator parsing failed')

    def test_parse_var_sub_var(self):
        indata = 'x[1] - y'
        actual = parsing.parse_definition(indata)
        x1 = parsing.VarType('x', [1])
        y = parsing.VarType('y')
        expected = parsing.OpType('-', [x1, y])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Subtraction operator parsing failed')

#===== Integration =======================================================

    def test_parse_integrated_1(self):
        indata = '2-17.3*x**2'
        actual = parsing.parse_definition(indata)
        x = parsing.VarType('x')
        x2 = parsing.OpType('**', [x, 2])
        m17p3x2 = parsing.OpType('*', [17.3, x2])
        expected = parsing.OpType('-', [2, m17p3x2])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Integrated #1 operator parsing failed')

    def test_parse_integrated_2(self):
        indata = '2-17.3*x / f(2.3, x[2:5])'
        actual = parsing.parse_definition(indata)
        x = parsing.VarType('x')
        x25 = parsing.VarType('x', [slice(2, 5)])
        f = parsing.FuncType('f', [2.3, x25])
        m17p3x = parsing.OpType('*', [17.3, x])
        dm17p3xf = parsing.OpType('/', [m17p3x, f])
        expected = parsing.OpType('-', [2, dm17p3xf])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Integrated #2 operator parsing failed')

    def test_parse_integrated_3(self):
        indata = '2-3+1'
        actual = parsing.parse_definition(indata)
        expected = 0
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Integrated #3 operator parsing failed')

    def test_parse_integrated_4(self):
        indata = '2-3/4*2+1'
        actual = parsing.parse_definition(indata)
        expected = 3
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Integrated #4 operator parsing failed')

    def test_parse_integrated_5(self):
        indata = 'mean(chunits(time_bnds, units=time), "bnds")'
        actual = parsing.parse_definition(indata)
        time = parsing.VarType('time')
        time_bnds = parsing.VarType('time_bnds')
        chunits = parsing.FuncType('chunits', [time_bnds], {'units': time})
        expected = parsing.FuncType('mean', [chunits, 'bnds'])
        testname = 'parse_definition({0!r})'.format(indata)
        print_test_message(testname, indata=indata,
                           actual=actual, expected=expected)
        self.assertEqual(actual, expected,
                         'Integrated #5 operator parsing failed')


#=========================================================================
# Command-Line Operation
#=========================================================================
if __name__ == "__main__":
    # import sys;sys.argv = ['', 'Test.testName']
    unittest.main()
