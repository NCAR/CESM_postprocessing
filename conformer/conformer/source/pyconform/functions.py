"""
Functions for FunctionEvaluator Actions

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

from abc import ABCMeta, abstractmethod
from pyconform.physarray import PhysArray, UnitsError
from numpy.ma import sqrt, where
from cf_units import Unit

#=======================================================================================================================
# is_constant - Determine if an argument is a constant (number or string)
#=======================================================================================================================
def is_constant(arg):
    return isinstance(arg, (basestring, float, int)) or arg is None
    
#===================================================================================================
# Find a function or operator based on key and number of arguments
#===================================================================================================
def find(key, numargs=None):
    try:
        fop = find_operator(key, numargs=numargs)
    except:
        pass
    else:
        return fop
    
    if numargs is not None:
        raise KeyError('No operator {!r} with {} arguments found'.format(key, numargs))

    try:
        fop = find_function(key)
    except:
        raise KeyError('No operator or function {!r} found'.format(key))
    else:
        return fop


#===================================================================================================
# FunctionBase - base class for Function and Operator Classes
#===================================================================================================
class FunctionBase(object):
    __metaclass__ = ABCMeta
    key = 'function'

    def __init__(self, *args, **kwds):
        self.arguments = args
        self.keywords = kwds

    @abstractmethod
    def __getitem__(self):
        return None


####################################################################################################
##### OPERATORS ####################################################################################
####################################################################################################


#===================================================================================================
# Get the function associated with the given key-symbol
#===================================================================================================
def find_operator(key, numargs=None):
    if key not in __OPERATORS__:
        raise KeyError('Operator {!r} not found'.format(key))
    ops = __OPERATORS__[key]
    if numargs is None:
        if len(ops) == 0:
            raise KeyError('Operator {!r} found but not defined'.format(key))
        elif len(ops) == 1:
            return ops[ops.keys()[0]]
        else:
            raise KeyError(('Operator {!r} has multiple definitions, '
                            'number of arguments required').format(key))
    elif numargs not in ops:
        raise KeyError('Operator {!r} with {} arguments not found'.format(key, numargs))
    else:
        return ops[numargs]


#===================================================================================================
# operators
#===================================================================================================
def list_operators():
    return sorted(__OPERATORS__.keys())


#===================================================================================================
# Operator - From which all 'X op Y'-pattern operators derive
#===================================================================================================
class Operator(FunctionBase):
    key = '?'
    numargs = 2
    
    def __init__(self, *args):
        super(Operator, self).__init__(*args)


#===================================================================================================
# NegationOperator
#===================================================================================================
class NegationOperator(Operator):
    key = '-'
    numargs = 1

    def __init__(self, arg):
        super(NegationOperator, self).__init__(arg)
    
    def __getitem__(self, index):
        arg = self.arguments[0] if is_constant(self.arguments[0]) else self.arguments[0][index]
        return -arg


#===================================================================================================
# AdditionOperator
#===================================================================================================
class AdditionOperator(Operator):
    key = '+'
    numargs = 2

    def __init__(self, left, right):
        super(AdditionOperator, self).__init__(left, right)
    
    def __getitem__(self, index):
        left = self.arguments[0] if is_constant(self.arguments[0]) else self.arguments[0][index]
        right = self.arguments[1] if is_constant(self.arguments[1]) else self.arguments[1][index]
        return left + right


#===================================================================================================
# SubtractionOperator
#===================================================================================================
class SubtractionOperator(Operator):
    key = '-'
    numargs = 2

    def __init__(self, left, right):
        super(SubtractionOperator, self).__init__(left, right)
    
    def __getitem__(self, index):
        left = self.arguments[0] if is_constant(self.arguments[0]) else self.arguments[0][index]
        right = self.arguments[1] if is_constant(self.arguments[1]) else self.arguments[1][index]
        return left - right


#===================================================================================================
# PowerOperator
#===================================================================================================
class PowerOperator(Operator):
    key = '**'
    numargs = 2

    def __init__(self, left, right):
        super(PowerOperator, self).__init__(left, right)
    
    def __getitem__(self, index):
        left = self.arguments[0] if is_constant(self.arguments[0]) else self.arguments[0][index]
        right = self.arguments[1] if is_constant(self.arguments[1]) else self.arguments[1][index]
        return left ** right


#===================================================================================================
# MultiplicationOperator
#===================================================================================================
class MultiplicationOperator(Operator):
    key = '*'
    numargs = 2

    def __init__(self, left, right):
        super(MultiplicationOperator, self).__init__(left, right)
    
    def __getitem__(self, index):
        left = self.arguments[0] if is_constant(self.arguments[0]) else self.arguments[0][index]
        right = self.arguments[1] if is_constant(self.arguments[1]) else self.arguments[1][index]
        return left * right


#===================================================================================================
# DivisionOperator
#===================================================================================================
class DivisionOperator(Operator):
    key = '-'
    numargs = 2

    def __init__(self, left, right):
        super(DivisionOperator, self).__init__(left, right)
    
    def __getitem__(self, index):
        left = self.arguments[0] if is_constant(self.arguments[0]) else self.arguments[0][index]
        right = self.arguments[1] if is_constant(self.arguments[1]) else self.arguments[1][index]
        return left / right


#===================================================================================================
# Operator map - Fixed to prevent user-redefinition!
#===================================================================================================

__OPERATORS__ = {'-': {1: NegationOperator, 2: SubtractionOperator},
                 '**': {2: PowerOperator},
                 '+': {2: AdditionOperator},
                 '*': {2: MultiplicationOperator},
                 '/': {2: DivisionOperator}}

####################################################################################################
##### FUNCTIONS ####################################################################################
####################################################################################################

#===================================================================================================
# Recursively return all subclasses of a given class
#===================================================================================================
def _all_subclasses_(cls):
    return cls.__subclasses__() + [c for s in cls.__subclasses__() for c in _all_subclasses_(s)]


#===================================================================================================
# Get the function associated with the given key-symbol
#===================================================================================================
def find_function(key):
    func = None
    for c in _all_subclasses_(Function):
        if c.key == key:
            if func is None:
                func = c
            else:
                raise RuntimeError('Function {!r} is multiply defined'.format(key))
    if func is None:
        raise KeyError('Function {!r} not found'.format(key))
    else:
        return func
    

#===================================================================================================
# list_functions
#===================================================================================================
def list_functions():
    return [c.key for c in _all_subclasses_(Function)]


#===================================================================================================
# Function - From which all 'func(...)'-pattern functions derive
#===================================================================================================
class Function(FunctionBase):
    key = 'func'
    
    def __init__(self, *args, **kwds):
        super(Function, self).__init__(*args, **kwds)
        self._sumlike_dimensions = set()
    
    def __getitem__(self, _):
        return None
    
    @property
    def sumlike_dimensions(self):
        return self._sumlike_dimensions
    
    def add_sumlike_dimensions(self, *dims):
        self._sumlike_dimensions.update(set(dims))


#===================================================================================================
# SquareRoot
#===================================================================================================
class SquareRootFunction(Function):
    key = 'sqrt'

    def __init__(self, data):
        super(SquareRootFunction, self).__init__(data)
        data_info = data if is_constant(data) else data[None]
        if isinstance(data_info, PhysArray):
            try:
                units = data_info.units.root(2)
            except:
                raise UnitsError('sqrt: Cannot take square-root of units {!r}'.format(data.units))
            self._units = units
        else:
            self._units = None

    def __getitem__(self, index):
        data_r = self.arguments[0]
        data = data_r if is_constant(data_r) else data_r[index]
        if isinstance(data, PhysArray):
            return PhysArray(sqrt(data), units=self._units, name='sqrt({})'.format(data.name),
                             dimensions=data.dimensions, positive=data.positive)
        else:
            return sqrt(data)


#===================================================================================================
# MeanFunction
#===================================================================================================
class MeanFunction(Function):
    key = 'mean'

    def __init__(self, data, *dimensions):
        super(MeanFunction, self).__init__(data, *dimensions)
        self.add_sumlike_dimensions(*dimensions)
        data_info = data if is_constant(data) else data[None]
        if not isinstance(data_info, PhysArray):
            raise TypeError('mean: Data must be a PhysArray')
        if not all(isinstance(d, basestring) for d in dimensions):
            raise TypeError('mean: Dimensions must be strings')
    
    def __getitem__(self, index):
        data = self.arguments[0][index]
        dimensions = self.arguments[1:]
        indims = [d for d in dimensions if d in data.dimensions]
        return data.mean(dimensions=indims)


#===================================================================================================
# PositiveUpFunction
#===================================================================================================
class PositiveUpFunction(Function):
    key = 'up'

    def __init__(self, data):
        super(PositiveUpFunction, self).__init__(data)
    
    def __getitem__(self, index):
        data_r = self.arguments[0]
        data = data_r if is_constant(data_r) else data_r[index]
        return PhysArray(data).up()


#===================================================================================================
# PositiveDownFunction
#===================================================================================================
class PositiveDownFunction(Function):
    key = 'down'

    def __init__(self, data):
        super(PositiveDownFunction, self).__init__(data)
    
    def __getitem__(self, index):
        data_r = self.arguments[0]
        data = data_r if is_constant(data_r) else data_r[index]
        return PhysArray(data).down()


#===================================================================================================
# ChangeUnitsFunction
#===================================================================================================
class ChangeUnitsFunction(Function):
    key = 'chunits'

    def __init__(self, data, units=None, refdate=None, calendar=None):
        super(ChangeUnitsFunction, self).__init__(data, units=units, refdate=refdate, calendar=calendar)
    
        dunits = Unit(1) if is_constant(data) else data[None].units
        dcal = dunits.calendar
        if dunits.is_time_reference():
            dunit, dref = [s.strip() for s in dunits.origin.split('since')]
        else:
            dunit = dunits.origin
            dref = None
        
        uobj = Unit(units) if is_constant(units) else units[None].units
        ucal = uobj.calendar
        if uobj.is_time_reference():
            uunit, uref = [s.strip() for s in uobj.origin.split('since')]
        else:
            uunit = uobj.origin
            uref = None
        
        unit = dunit if units is None else uunit
        
        if isinstance(refdate, basestring):
            ref = refdate
        elif refdate is None:
            ref = dref if uref is None else uref
        else:
            raise ValueError('chunits: Reference date must be a string, if given')

        if isinstance(calendar, basestring):
            cal = calendar
        elif calendar is None:
            cal = dcal if ucal is None else ucal
        else:
            raise ValueError('chunits: Calendar must be a string, if given')
        
        if ref is None:
            self._newunits = Unit(unit, calendar=cal)
        else:
            self._newunits = Unit('{} since {}'.format(unit, ref), calendar=cal)
        
    def __getitem__(self, index):
        data = self.arguments[0] if is_constant(self.arguments[0]) else self.arguments[0][index]
        cal_str = '' if self._newunits.calendar is None else '|{}'.format(self._newunits.calendar)
        unit_str = '{}{}'.format(self._newunits, cal_str)
        new_name = 'chunits({}, units={})'.format(data.name, unit_str)
        return PhysArray(data, name=new_name, units=self._newunits)


#===================================================================================================
# LimitFunction
#===================================================================================================
class LimitFunction(Function):
    key = 'limit'

    def __init__(self, data, below=None, above=None):
        super(LimitFunction, self).__init__(data, below=below, above=above)
    
    def __getitem__(self, index):
        data = self.arguments[0] if is_constant(self.arguments[0]) else self.arguments[0][index]

        above_val = self.keywords['above']
        below_val = self.keywords['below']
        if above_val is None and below_val is None:
            return data
        
        above_str = ''
        if above_val is not None:
            above_ind = where(data > above_val)
            if len(above_ind) > 0:
                data[above_ind] = above_val
                above_str = ', above={}'.format(above_val)
                
        below_str = ''
        if below_val is not None:
            below_ind = where(data < below_val)
            if len(below_ind) > 0:
                data[below_ind] = below_val
                below_str = ', below={}'.format(below_val)

        new_name = 'limit({}{}{})'.format(data.name, above_str, below_str)
        return PhysArray(data, name=new_name)
