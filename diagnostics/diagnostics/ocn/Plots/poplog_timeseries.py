""" 
plot module: PM_POPLOG
plot name:   POP log & dt file time series plots

classes:           PopLog_timeseries
CplLog:            base class
CplLog_timeseries: defines specific NCL list for model timeseries plots
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
import jinja2
import os
import shutil
import subprocess
import traceback


# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the plot baseclass module
from ocn_diags_plot_bc import OceanDiagnosticPlot

class PopLog(OceanDiagnosticPlot):
    """Detailed description of the plot that will show up in help documentation
    """

    def __init__(self):
        super(PopLog, self).__init__()

        self._expectedPlots_globalAvg = ['diagts_TEMP', 'diagts_SALT', 'diagts_RHO', 'diagts_IAGE', 'diagts_HBLT', 'diagts_HMXL', 'diagts_SSH',
                                         'diagts_SHF_TOTAL', 'diagts_SWNET', 'diagts_LWNET', 'diagts_LWUP_F', 'diagts_LWDN_F', 'diagts_LATENT',
                                         'diagts_SENH_F', 'diagts_MELTH_F', 'diagts_QFLUX', 'diagts_SFWF_TOTAL', 'diagts_PREC_F', 'diagts_EVAP_F',
                                         'diagts_SNOW_F', 'diagts_MELT_F', 'diagts_ROFF_F', 'diagts_SALT_F', 'diagts_SFWF_QFLUX',
                                         'diagts_CFC11', 'diagts_STF_CFC11', 'diagts_CFC12', 'diagts_STF_CFC12', 'diagts_precf']
        self._expectedPlots_globalAvgLabels = ['TEMP', 'SALT', 'RHO', 'IAGE', 'HBLT', 'HMXL', 'SSH',
                                               'SHF_TOTAL', 'SWNET', 'LWNET', 'LWUP_F', 'LWDN_F', 'LATENT',
                                               'SENH_F', 'MELTH_F', 'QFLUX', 'SFWF_TOTAL', 'PREC_F', 'EVAP_F',
                                               'SNOW_F', 'MELT_F', 'ROFF_F', 'SALT_F', 'SFWF_QFLUX',
                                               'CFC11', 'STF_CFC11', 'CFC12', 'STF_CFC12', 'Precip_factor']

        self._expectedPlots_Nino = ['NINO']
        self._expectedPlots_NinoLabels = ['diagts_NINO']

        self._expectedPlots_transportDiags = ['diagts_transport.drake', 'diagts_transport.mozam', 'diagts_transport.bering', 'diagts_transport.nwpassage'
                                              'diagts_transport.itf1', 'diagts_transport.itf2', 'diagts_transport.windward1', 'diagts_transport.windward2',
                                              'diagts_transport.florida', 'diagts_transport.gibraltar', 'diagts_transport.nares']

        self._expectedPlots_transportDiagsLabels = ['Drake_Passage', 'Mozambique_Channel', 'Bering_Strait', 'Northwest_Passage'
                                                    'Indonesian_Throughflow_1', 'Indonesian_Throughflow_2', 'Windward_Passage_1', 'Windward2_Passage_2',
                                                    'Florida_Strait', 'Gibraltar', 'Nares_Straigt']
        
        self._expectedPlotsHeaders = ['Global Average Fields', 'Nino Indices', 'Transport Diagnostics']

        self._name = 'POP log and dt file time series plots'
        self._shortname = 'POPLOG'
        self._template_file = 'poplog_timeseries.tmpl'
        self._ncl = list()

    def check_prerequisites(self, env):
        """list and check specific prequisites for this plot.
        """
        super(PopLog, self).check_prerequisites(env)
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))

        # chdir into the  working directory
        os.chdir(env['WORKDIR'])

        # parse the cpllog depending on the coupler version - default to 7b
        heatFile = 'cplheatbudget'
        freshWaterFile = 'cplfwbudget'
        cplVersion = 'cpl7b'
        env['ntailht'] = os.environ['ntailht'] = '22'
        env['ntailfw'] = os.environ['ntailfw'] = '16'

        if '7' == env['TS_CPL'] or '6' == env['TS_CPL']:
            cplVersion = 'cpl{0}'.format(env['TS_CPL'])
            env['ntailht'] = os.environ['ntailht'] = '21'
            env['ntailfw'] = os.environ['ntailfw'] = '16'

        # expand the cpl.log* into a list
        cplLogs = list()
        cplLogs = glob.glob('{0}/cpl.log.*'.format(env['WORKDIR']))
        
        cplLogsString = ' '.join(cplLogs)

        # defing the awk command to parse the cpllog file
        heatPath = '{0}/process_{1}_logfiles_heat.awk'.format(env['TOOLPATH'], cplVersion)
        heatPath = os.path.abspath(heatPath)

        fwPath = '{0}/process_{1}_logfiles_fw.awk'.format(env['TOOLPATH'], cplVersion)
        fwPath = os.path.abspath(fwPath)
        
        heatCmd = '{0} y0={1} y1={2} {3}'.format(heatPath, env['YEAR0'], env['YEAR1'], cplLogsString).split(' ')
        freshWaterCmd = '{0} y0={1} y1={2} {3}'.format(fwPath, env['YEAR0'], env['YEAR1'], cplLogsString).split(' ')

        # run the awk scripts to generate the .txt files from the cpllogs
        print('cwd = {0}'.format(os.getcwd()))
        cmdList = [ (heatCmd, heatFile, env['ntailht']), (freshWaterCmd, freshWaterFile, env['ntailfw']) ]
        for cmd in cmdList:
            outFile = '{0}.txt'.format(cmd[1])
            with open (outFile, 'w') as results:
                try:
                    subprocess.check_call(cmd[0], stdout=results, env=env)
                    rc, err_msg = cesmEnvLib.checkFile(outFile, 'read')
                    if rc:
                        # get the tail of the .txt file and redirect to a .asc file for the web
                        ascFile = '{0}.asc'.format(cmd[1])
                        with open (ascFile, 'w') as results:
                            try:
                                #TODO - read the .txt in and write just the lines needed to avoid subprocess call
                                tailCmd = 'tail -{0} {1}.txt'.format(cmd[2], cmd[1]).split(' ')
                                subprocess.check_call(tailCmd, stdout=results, env=env)
                            except subprocess.CalledProcessError as e:
                                print('WARNING: {0} time series error executing command:'.format(self._shortname))
                                print('    {0}'.format(e.cmd))
                                print('    rc = {0}'.format(e.returncode))

                except subprocess.CalledProcessError as e:
                    print('WARNING: {0} time series error executing command:'.format(self._shortname))
                    print('    {0}'.format(e.cmd))
                    print('    rc = {0}'.format(e.returncode))

    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))

        # chdir into the  working directory
        os.chdir(env['WORKDIR'])

        for ncl in self._ncl:
            # prepend the TS_CPL log value to the ncl plot name
            nclPlotFile = 'cpl{0}_{1}'.format(env['TS_CPL'], ncl)
            
            # copy the NCL command to the workdir
            shutil.copy2('{0}/{1}'.format(env['NCLPATH'],nclPlotFile), '{0}/{1}'.format(env['WORKDIR'], nclPlotFile))

            nclFile = '{0}/{1}'.format(env['WORKDIR'],nclPlotFile)
            rc, err_msg = cesmEnvLib.checkFile(nclFile, 'read')
            if rc:
                try:
                    print('      calling NCL plot routine {0}'.format(nclPlotFile))
                    subprocess.check_call(['ncl', '{0}'.format(nclFile)], env=env)
                except subprocess.CalledProcessError as e:
                    print('WARNING: {0} call to {1} failed with error:'.format(self.name(), nclfile))
                    print('    {0}'.format(e.cmd))
                    print('    rc = {0}'.format(e.returncode))
            else:
                print('{0}... continuing with additional plots.'.format(err_msg))


    def convert_plots(self, workdir, imgFormat):
        """Converts plots for this class
        """
        self._convert_plots(workdir, imgFormat, self._expectedPlots)

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        plot_table = []
        num_cols = 3

        for i in range(len(self._labels)):  
            plot_tuple_list = []
            plot_tuple = (0, 'label','{0}:'.format(self._labels[i]))
            plot_tuple_list.append(plot_tuple)
            plot_list = self._expectedPlots

            # create the image link
            img_file = '{0}.{1}'.format(self._expectedPlots[i], imgFormat)
            rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
            if not rc:
                plot_tuple = (i+1, 'timeseries', '{0} - Error'.format(img_file))
            else:
                plot_tuple = (i+1, 'timeseries', img_file)
            plot_tuple_list.append(plot_tuple)

            # create the ascii file link
            asc_file = '{0}.{1}'.format(self._expectedPlots[i], 'asc')
            rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, asc_file), 'read' )
            if not rc:
                plot_tuple = (i+1, 'table', '{0} - Error'.format(asc_file))
            else:
                plot_tuple = (i+1, 'table', asc_file)
            plot_tuple_list.append(plot_tuple)

            print('DEBUG... plot_tuple_list[{0}] = {1}'.format(i, plot_tuple_list))
            plot_table.append(plot_tuple_list)

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
        templateEnv = jinja2.Environment( loader=templateLoader, keep_trailing_newline=False )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'plot_table' : plot_table,
                         'num_rows' : len(self._labels),
                         }

        # render the html template using the plot tables
        self._html = template.render( templateVars )
        
        return self._html

class PopLog_timeseries(PopLog):

    def __init__(self):
        super(PopLog_timeseries, self).__init__()
        self._ncl = ['pop_log_diagts_3d.monthly.ncl', 'pop_log_diagts_hflux.monthly.ncl', 
                     'pop_log_diagts_fwflux.monthly.ncl', 'pop_log_diagts_cfc.monthly.ncl', 
                     'pop_log_diagts_nino.monthly.ncl', 'pop_log_diagts_transports.monthly.ncl', 
                     'pop_log_diagts_precf.ncl']
