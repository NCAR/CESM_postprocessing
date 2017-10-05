Diagnosing Missing Model Values with ``ilamb-doctor``
=====================================================

In a previous `tutorial <./add_model.html>`_ we covered how a model
can be added to the analysis. However, it can be challenging to know
which variables are needed. To this end we have created a tool called
``ilamb-doctor`` which tries to diagnose what is incorrect or missing
from a given analysis. It takes options similar to ``ilamb-run`` and
is used in the following way::

  [ILAMB/test]$ ilamb-doctor --config test.cfg --model_root ${ILAMB_ROOT}/MODELS/CLM

  Searching for model results in /Users/ncf/ILAMB//MODELS/CLM

                                     CLM40n16r228
                                     CLM45n16r228
                                     CLM50n18r229

  We will now look in each model for the variables in the ILAMB
  configure file you specified (test.cfg). The color green is used to reflect
  which variables were found in the model. The color red is used to
  reflect that a model is missing a required variable.

                             Biomass/GlobalCarbon CLM40n16r228 biomass or cVeg
                 GrossPrimaryProductivity/Fluxnet CLM40n16r228 gpp
                    GrossPrimaryProductivity/GBAF CLM40n16r228 gpp
          GlobalNetEcosystemCarbonBalance/Hoffman CLM40n16r228 nbp
                        NetEcosystemExchange/GBAF CLM40n16r228 gpp, rh, and ra
             TerrestrialWaterStorageAnomaly/GRACE CLM40n16r228 tws
                                     Albedo/MODIS CLM40n16r228 rsus and rsds
                        SurfaceAirTemperature/CRU CLM40n16r228 tas
                              Precipitation/GPCP2 CLM40n16r228 pr
                             Biomass/GlobalCarbon CLM45n16r228 biomass or cVeg
                 GrossPrimaryProductivity/Fluxnet CLM45n16r228 gpp
                    GrossPrimaryProductivity/GBAF CLM45n16r228 gpp
          GlobalNetEcosystemCarbonBalance/Hoffman CLM45n16r228 nbp
                        NetEcosystemExchange/GBAF CLM45n16r228 gpp, rh, and ra
             TerrestrialWaterStorageAnomaly/GRACE CLM45n16r228 tws
                                     Albedo/MODIS CLM45n16r228 rsus and rsds
                        SurfaceAirTemperature/CRU CLM45n16r228 tas
                              Precipitation/GPCP2 CLM45n16r228 pr
                             Biomass/GlobalCarbon CLM50n18r229 biomass or cVeg
                 GrossPrimaryProductivity/Fluxnet CLM50n18r229 gpp
                    GrossPrimaryProductivity/GBAF CLM50n18r229 gpp
          GlobalNetEcosystemCarbonBalance/Hoffman CLM50n18r229 nbp
                        NetEcosystemExchange/GBAF CLM50n18r229 gpp, rh, and ra
             TerrestrialWaterStorageAnomaly/GRACE CLM50n18r229 tws
                                     Albedo/MODIS CLM50n18r229 rsus and rsds
                        SurfaceAirTemperature/CRU CLM50n18r229 tas
                              Precipitation/GPCP2 CLM50n18r229 pr

Here we have run the command on some inputs in our ``test``
directory. You will see a list of the confrontations we run and the
variables which are required or their synonyms. What is missing in
this tutorial is the text coloring which will indicate if a given
model has the required variables.

In the future we will add more intelligence to this tool to help
diagnose potential problems.


