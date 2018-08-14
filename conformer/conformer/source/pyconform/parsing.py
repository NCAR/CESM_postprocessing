"""
Parsing Module - NEW Based on PLY

This module defines the necessary elements to parse a string variable definition
into the recognized elements that are used to construct an Operation Graph.

Copyright 2017-2018, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from ply import lex, yacc
from collections import namedtuple

tokens = ('UINT', 'UFLOAT', 'STRING', 'NAME', 'POW', 'EQ', 'LEQ', 'GEQ')
literals = ('*', '/', '+', '-', '<', '>', '=', ',', ':', '(', ')', '[', ']')
t_ignore = ' \t'

t_NAME = r'[a-zA-Z_][a-zA-Z0-9_]*'
t_POW = r'\*\*'
t_LEQ = r'<='
t_GEQ = r'>='
t_EQ = r'=='


def t_UFLOAT(t):
    r'(([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)([eE][+-]?[0-9]+)?|[0-9]+[eE][+-]?[0-9]+)'
    t.value = float(t.value)
    return t


def t_UINT(t):
    r'[0-9]+'
    t.value = int(t.value)
    return t


def t_STRING(t):
    r'"([^"\\]*(\\.[^"\\]*)*)"|\'([^\'\\]*(\\.[^\'\\]*)*)\''
    t.value = t.value[1:-1]
    return t


def t_error(t):
    raise TypeError('Unexpected string: {!r}'.format(t.value))


lex.lex(debug=False)


def ind_str(index):
    if isinstance(index, slice):
        ind_list = [index.start, index.stop, index.step]
        _str = ':'.join('' if i is None else str(i) for i in ind_list)
        return ':' if _str == '::' else _str
    else:
        return str(index)


def op_str(self):
    if len(self.args) == 1:
        return '({}{})'.format(self.key, self.args[0])
    elif len(self.args) == 2:
        return '({}{}{})'.format(self.args[0], self.key, self.args[1])


OpType = namedtuple('OpType', ['key', 'args'])
OpType.__new__.__defaults__ = (None, [])
OpType.__str__ = lambda self: op_str(self)

FuncType = namedtuple('FuncType', ['key', 'args', 'kwds'])
FuncType.__new__.__defaults__ = (None, [], {})
FuncType.__str__ = lambda self: '{}({})'.format(
    self.key, ','.join([str(a) for a in self.args] +
                       ['{}={}'.format(k, self.kwds[k]) for k in self.kwds]))

VarType = namedtuple('VarType', ['key', 'ind'])
VarType.__new__.__defaults__ = (None, [])
VarType.__str__ = lambda self: '{}{}'.format(
    self.key, '' if len(self.ind) == 0 else '[{}]'.format(','.join([ind_str(a) for a in self.ind])))


precedence = (('left', 'EQ'),
              ('left', '<', '>', 'LEQ', 'GEQ'),
              ('left', '+', '-'),
              ('left', '*', '/'),
              ('right', 'NEG', 'POS'),
              ('left', 'POW'))


def p_array_like(p):
    """
    array_like : UFLOAT
    array_like : UINT
    array_like : function
    array_like : variable
    """
    p[0] = p[1]


def p_array_like_group(p):
    """
    array_like : '(' array_like ')'
    """
    p[0] = p[2]


def p_function_with_arguments_and_keywords(p):
    """
    function : NAME '(' argument_list ',' keyword_dict ')'
    """
    p[0] = FuncType(p[1], p[3], p[5])


def p_function_with_arguments_only(p):
    """
    function : NAME '(' argument_list ')'
    """
    p[0] = FuncType(p[1], p[3], {})


def p_function_with_keywords_only(p):
    """
    function : NAME '(' keyword_dict ')'
    """
    p[0] = FuncType(p[1], [], p[3])


def p_argument_list_append(p):
    """
    argument_list : argument_list ',' argument
    """
    p[0] = p[1] + [p[3]]


def p_single_item_argument_list(p):
    """
    argument_list : argument
    argument_list : 
    """
    p[0] = [p[1]] if len(p) > 1 else []


def p_argument(p):
    """
    argument : array_like
    argument : STRING
    """
    p[0] = p[1]


def p_keyword_dict_setitem(p):
    """
    keyword_dict : keyword_dict ',' NAME '=' argument
    """
    p[1][p[3]] = p[5]
    p[0] = p[1]


def p_single_item_keyword_dict(p):
    """
    keyword_dict : NAME '=' argument
    """
    p[0] = {p[1]: p[3]}


def p_variable(p):
    """
    variable : NAME '[' index_list ']'
    variable : NAME
    """
    indices = p[3] if len(p) > 3 else []
    p[0] = VarType(p[1], indices)


def p_index_list_append(p):
    """
    index_list : index_list ',' index
    """
    p[0] = p[1] + [p[3]]


def p_single_item_index_list(p):
    """
    index_list : index
    """
    p[0] = [p[1]]


def p_index(p):
    """
    index : slice
    index : array_like
    """
    p[0] = p[1]


def p_slice(p):
    """
    slice : slice_argument ':' slice_argument ':' slice_argument
    slice : slice_argument ':' slice_argument
    """
    p[0] = slice(*p[1::2])


def p_slice_argument(p):
    """
    slice_argument : array_like
    slice_argument : 
    """
    p[0] = p[1] if len(p) > 1 else None


def p_expression_unary(p):
    """
    array_like : '-' array_like %prec NEG
    array_like : '+' array_like %prec POS
    """
    if p[1] == '+':
        p[0] = p[2]
    elif p[1] == '-':
        if isinstance(p[2], (OpType, FuncType, VarType)):
            p[0] = OpType(p[1], [p[2]])
        else:
            p[0] = -p[2]


def p_expression_binary(p):
    """
    array_like : array_like POW array_like
    array_like : array_like '-' array_like
    array_like : array_like '+' array_like
    array_like : array_like '*' array_like
    array_like : array_like '/' array_like
    array_like : array_like '<' array_like
    array_like : array_like '>' array_like
    array_like : array_like LEQ array_like
    array_like : array_like GEQ array_like
    array_like : array_like EQ array_like
    """
    if (isinstance(p[1], (OpType, FuncType, VarType)) or
            isinstance(p[3], (OpType, FuncType, VarType))):
        p[0] = OpType(p[2], [p[1], p[3]])
    elif p[2] == '**':
        p[0] = p[1] ** p[3]
    elif p[2] == '-':
        p[0] = p[1] - p[3]
    elif p[2] == '+':
        p[0] = p[1] + p[3]
    elif p[2] == '*':
        p[0] = p[1] * p[3]
    elif p[2] == '/':
        p[0] = p[1] / p[3]
    elif p[2] == '<':
        p[0] = p[1] < p[3]
    elif p[2] == '>':
        p[0] = p[1] > p[3]
    elif p[2] == '<=':
        p[0] = p[1] <= p[3]
    elif p[2] == '>=':
        p[0] = p[1] >= p[3]
    elif p[2] == '==':
        p[0] = p[1] == p[3]


def p_error(p):
    raise TypeError('Parsing error at {!r}'.format(p.value))


yacc.yacc(debug=False)


#=========================================================================
# Function to parse a string definition
#=========================================================================
def parse_definition(strexpr):
    return yacc.parse(strexpr)  # @UndefinedVariable
