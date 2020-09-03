"""
Plot module: PM_E_MAPS
plot name:   Ecosystem maps at surface and various depths

classes:
EcosystemMaps:          base class
EcosystemMaps_obs:      defines specific NCL list for model vs. observations plots
EcosystemMaps_control:  defines specific NCL list for model vs. control plots
"""

from __future__ import print_function

import sys

if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

import glob
import itertools
import jinja2
import os
import traceback
import shutil
import subprocess

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from .ocn_diags_plot_bc import OceanDiagnosticPlot

class EcosystemMaps(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(EcosystemMaps, self).__init__()
        self._name = 'Ecosystem: Maps'
        self._shortname = 'E_MAPS'

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(EcosystemMaps, self).check_prerequisites(env)
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))

        # copy the remap.so file to the workdir
        shutil.copy2('{0}/remap.so'.format(env['ECOPATH']), '{0}/remap.so'.format(env['WORKDIR']))

        # setup of the arg file to pass to the python modules
        f = open('{0}/PM_E_input'.format(env['WORKDIR']), 'w')
        self._setup_args(env)
        for arg in self._args:
            f.write('{0}\n'.format(arg))
        f.close()

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))
        rawIn = ''
        with open('{0}/PM_E_input'.format(env['WORKDIR']), 'r') as fp:
            for line in fp:
                rawIn += ('{0}'.format(line))
        for script in self._python:
            try:
                pipe = subprocess.Popen(['python','{0}/{1}.py'.format(env['ECOPATH'],script)], stdin=subprocess.PIPE)
                pipe.communicate(rawIn)
                pipe.wait()
            except OSERROR as e:
                print('WARNING: {0} failed to call {1}/{2}.py'.format(self.__class__.__name__),env['ECOPATH'],script)
                print('    {0} - {1}'.format(e.errno, e.strerr))

    def convert_plots(self, workdir, imgFormat):
        """Converts plots for this class
        """
        pass

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """

        # work on the first grouping of plots
        plot_tables_g1 = []
        # build up the plot_tables array
        for h in range(len(self._expectedPlots)):
            plot_set = self._expectedPlots[h]
            columns = self._columns[h]

            for k in range(len(plot_set)):
                plot_table = []
                plot_tuple_list = plot_set[k]
                num_plots = len(plot_tuple_list)
                num_last_row = num_plots % columns[k]
                num_rows = num_plots//columns[k]
                index = 0

                for i in range(num_rows):
                    ptuple = []
                    for j in range(self._columns[k]):
                        label, plot_file = plot_tuple_list[index]
                        img_file = '{0}.{1}'.format(plot_file, imgFormat)
                        rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                        if not rc:
                            ptuple.append(('{0}'.format(label), '{0} - Error'.format(plot_file)))
                        else:
                            ptuple.append(('{0}'.format(label), plot_file))
                            index += 1
                        plot_table.append(ptuple)

            # pad out the last row
            if num_last_row > 0:
                ptuple = []
                for i in range(num_last_row):
                    label, plot_file = plot_tuple_list[index]
                    img_file = '{0}.{1}'.format(plot_file, imgFormat)
                    rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                    if not rc:
                        ptuple.append(('{0}'.format(label), '{0} - Error'.format(plot_file)))
                    else:
                        ptuple.append(('{0}'.format(label), plot_file))
                    index += 1

                for i in range(columns[k] - num_last_row):
                    ptuple.append(('',''))

                plot_table.append(ptuple)

            plot_tables_g1.append(('{0}'.format(self._expectedPlotHeaders[h]), plot_table, columns))

        # work on the second grouping of plots
        plot_tables_g2 = []
        for i in range(len(self._labels)):
            plot_tuple_list = []
            plot_tuple = (0,'label','{0}:'.format(self._labels[i]))
            plot_tuple_list.append(plot_tuple)

            for j in range(len(self._linkNames)):
                img_file = '{0}_{1}_{2}.{3}'.format(self._prefix, self._labels[i], self._linkNames[j], imgFormat)
                rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                if not rc:
                    plot_tuple = (j+1, self._linkNames[j],'{0} - Error'.format(img_file))
                else:
                    plot_tuple = (j+1, self._linkNames[j], img_file)
                plot_tuple_list.append(plot_tuple)

            print('DEBUG... plot_tuple_list[{0}] = {1}'.format(i, plot_tuple_list))
            plot_tables_g2.append(plot_tuple_list)

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
        templateEnv = jinja2.Environment( loader=templateLoader, keep_trailing_newline=False )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'plotTitles' : self._plotTitles,
                         'plot_tables_g1' : plot_tables_g1,
                         'plot_tables_g2' : plot_tables_g2,
                         'num_rows_g2' : len(self._labels),
                         'imgFormat' : imgFormat
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )

        return self._html

class EcosystemMaps_obs(EcosystemMaps):

    def __init__(self):
        super(EcosystemMaps_obs, self).__init__()
        self._python = ['clim_maps_surface', 'clim_maps_surface_2D', 'clim_maps_at_depths',
                        'nutlim_maps', 'model_obs_maps_surface', 'model_obs_maps_at_depths']

        self._template_file = 'ecosystem_maps.tmpl'


        self._expectedPlotsHeaders = ['Lat,Lon', ' ', ' ']

        self._expectedPlots_s1 = [('NH4','map_NH4'), ('NO3_excess','map_NO3'), ('spChl','map_spChl'), ('diatChl','map_diatChl'), ('diazChl','map_diazChl'), ('totChl','map_totChl'),
                                  ('spC','map_spC'), ('diatC','map_diatC'), ('diazC','map_diazC'), ('photoC_sp','map_photoC_sp'), ('photoC_diat','map_photoC_diat'),
                                  ('photoC_diaz','map_photoC_diaz'), ('diaz_Nfix','map_diaz_Nfix'), ('DENITRIF','map_DENITRIF'), ('NITRIF','map_NITRIF'),
                                  ('CaCO3_form','map_CaCO3_form'), ('bSi_form','map_bSi_form'), ('IRON_FLUX','map_IRON_FLUX'), ('POC_FLUX_IN','map_POC_FLUX_IN'),
                                  ('CaCO3_FLUX_IN','map_CaCO3_FLUX_IN'), ('SiO2_FLUX_IN','map_SiO2_FLUX_IN'), ('STF_O2','map_STF_O2'), ('FvPER_DIC','map_FvPER_DIC'),
                                  ('FvICE_DIC','map_FvICE_DIC')]

        self._expectedPlots_s2 = [('sp_nutlim','map_nutlim_sp'), ('diat_nutlim','map_nutlim_diat'), ('diaz_nutlim','map_nutlim_diaz')]

        self._expectedPlots_s3 = [('pCO2SURF','mod_obs_map_pCO2SURF_0m'), ('FG_CO2','mod_obs_map_FG_CO2_0m'), ('totChl','mod_obs_map_totChl_0m'),
                                  ('photoC_tot','mod_obs_map_photoC_tot_0m'), ('phytoC','mod_obs_map_phytoC_0m'), ('phyto_mu','mod_obs_map_phyto_mu_0m')]

        self._expectedPlots = [ self._expectedPlots_s1, self._expectedPlots_s2, self._expectedPlots_s3 ]

        self._columns_s1 = [2, 4, 3, 3, 5, 4, 3]
        self._columns_s2 = [3]
        self._columns_s3 = [6]

        self._columns = [ self._columns_s1, self._columns_s2, self._columns_s3 ]

        self._plotTitles = ['Ecosystem: Maps', 'Ecosystem: Maps at Depth (with obs where applicable)']
        self._labels = ['NO3','PO4','SiO3','O2','DIC','ALK','Fe']
        self._linkNames = ['0m', '50m', '100m','200m', '300m','500m', '1000m', '1500m', '2000m', '2500m','3000m', '3500','4000m']
        self._prefix = 'mod_obs_map'

    def _setup_args(self, env):
        # arg order list expected as line separated
        # CASE, YEAR0, YEAR1, POPDIAG, YROFFSET, WORKDIR, REOSLUTION, ECODATADIR
        self._args = [env['CASE'], env['YEAR0'], env['YEAR1'], env['POPDIAG'], env['YROFFSET'],
                      env['WORKDIR'], env['RESOLUTION'], env['ECODATADIR']]

class EcosystemMaps_control(EcosystemMaps):

    def __init__(self):
        super(EcosystemMaps_control, self).__init__()
        self._python = [maps_surface_diff, maps_surface_diff_2D, maps_at_depths_diff]

    def _setup_args(self, env):
        # arg order list expected as line separated
        # CASE, YEAR0, YEAR1, POPDIAG, YROFFSET, WORKDIR, REOSLUTION, ECODATADIR
        self._args = [env['CASE'], env['YEAR0'], env['YEAR1'], env['POPDIAG'], env['YROFFSET'],
                      env['WORKDIR'], env['RESOLUTION'], env['ECODATADIR']]
