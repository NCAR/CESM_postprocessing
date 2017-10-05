Package Contents
================

We have written this python package with the intent that it be easy to
use on a variety of levels. For the researcher who just wants to setup
basic model-benchmark confrontations using our mean-state analysis,
they may never need to program in python. For those who wish to
perform more complicated comparisons or pose their own analysis, we
present the package contents with some underlying philosophy
concerning the purpose of each object.

Variable
--------

This class encapsulates data defined in space/time with common
analysis capabilities. You can think of it as a netCDF variable with
analysis routines that are aware of the spatial/temporal nature of the
data. It is the basic building block on which the analysis portion of
the package is built.

.. currentmodule:: ILAMB.Variable
.. autosummary::
   :toctree: _generated
   :nosignatures:
   :template: class.rst

   Variable

ModelResults
------------

This model result class aims to handle model queries efficiently and
uniformly without requiring the user to interface with the source
netCDF files themselves.

.. currentmodule:: ILAMB.ModelResult
.. autosummary::
   :toctree: _generated
   :nosignatures:
   :template: class.rst
   
   ModelResult

Confrontations
--------------

In the ILAMB parlance, a *confrontation* is a observational benchmark
dataset and its accompanying analysis. Thus we have implemented the
``Confrontation`` base class which will automatically handle the
querying of data from the model and perform our mean-state
analysis. In anticipation that users will want to write their own
analysis, or have benchmark datasets which compare to a non-algebraic
combination of model inputs, we support confrontation classes which
derive from the base class. The other classes listed here are examples
of how this may be accomplished.

.. currentmodule:: ILAMB.Confrontation
.. autosummary::
   :toctree: _generated
   :nosignatures:
   :template: class.rst
   
   Confrontation

.. currentmodule:: ILAMB.ConfNBP
.. autosummary::
   :toctree: _generated
   :nosignatures:
   :template: class.rst

   ConfNBP

Regions
-------

This class unifies treatment of regions in ILAMB by allowing regions
to be defined by latitude and longitude bounds as well by netCDF4
files containing integer indices.

.. currentmodule:: ILAMB.Regions
.. autosummary::
   :toctree: _generated
   :nosignatures:
   :template: class.rst

   Regions

ilamblib
--------

This module collects many routines which may be helpful but do not
belong with any of the above objects.

.. currentmodule:: ILAMB.ilamblib
.. autosummary::
   :toctree: _generated

   GenerateDistinctColors
   ClipTime
   ConvertCalendar
   ComposeSpatialGrids   
   CellAreas
   GlobalLatLonGrid
   NearestNeighborInterpolation
   TrueError
   SympifyWithArgsUnits
   FromNetCDF4
   CombineVariables
   Score
   ScoreSeasonalCycle
   MakeComparable
   AnalysisMeanState
   AnalysisRelationship
   
Post
----

Finally we provide a module with many ways of presenting these
results. While we want to keep data formats open such that researchers
may use plotting code of their own in their own language, we also want
to provide a robust set of tools for generating different views and
organizations of the confrontation results.

.. currentmodule:: ILAMB.Post
.. autosummary::
   :toctree: _generated

   ColorBar
   TaylorDiagram
   WhittakerDiagram
   RegisterCustomColormaps
   BenchmarkSummaryFigure
