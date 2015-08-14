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

        self._expectedPlots_globalAvg = [('TEMP','diagts_TEMP'), ('SALT','diagts_SALT'), ('RHO','diagts_RHO'), ('IAGE','diagts_IAGE'), ('HBLT','diagts_HBLT'), ('HMXL','diagts_HMXL'), ('SSH','diagts_SSH'),
                                         ('SHF_TOTAL','diagts_SHF_TOTAL'), ('SWNET','diagts_SWNET'), ('LWNET','diagts_LWNET'), ('LWUP_F','diagts_LWUP_F'), ('LWDN_F','diagts_LWDN_F'), ('LATENT','diagts_LATENT'),
                                         ('SENH_F','diagts_SENH_F'), ('MELTH_F','diagts_MELTH_F'), ('QFLUX','diagts_QFLUX'), ('SFWF_TOTAL','diagts_SFWF_TOTAL'), ('PREC_F','diagts_PREC_F'), ('EVAP_F','diagts_EVAP_F'),
                                         ('SNOW_F','diagts_SNOW_F'), ('MELT_F','diagts_MELT_F'), ('ROFF_F','diagts_ROFF_F'), ('SALT_F','diagts_SALT_F'), ('SFWF_QFLUX','diagts_SFWF_QFLUX'),
                                         ('CFC11','diagts_CFC11'), ('STF_CFC11','diagts_STF_CFC11'), ('CFC12','diagts_CFC12'), ('STF_CFC12','diagts_STF_CFC12'), ('Precip_factor','diagts_precf')]

        self._expectedPlots_Nino = [('NINO','diagts_NINO')]

        self._expectedPlots_transportDiags = [('Drake_Passage','diagts_transport.drake'), ('Mozambique_Channel','diagts_transport.mozam'), ('Bering_Strait','diagts_transport.bering'), 
                                              ('Northwest_Passage','diagts_transport.nwpassage'), ('Indonesian_Throughflow_1','diagts_transport.itf1'), ('Indonesian_Throughflow_2','diagts_transport.itf2'), 
                                              ('Windward_Passage_1','diagts_transport.windward1'), ('Windward2_Passage_2','diagts_transport.windward2'), ('Florida_Strait','diagts_transport.florida'), 
                                              ('Gibraltar','diagts_transport.gibraltar'), ('Nares_Straight','diagts_transport.nares')]
        
        self._expectedPlotsHeaders = ['Global Average Fields', 'Nino Indices', 'Transport Diagnostics']
        self._columns = [ 8, 1, 4 ]
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

        # expand the ocn.log* into a list
        ocnLogs = list()
        ocnLogs = glob.glob('{0}/ocn.log.*'.format(env['WORKDIR']))
        ocnLogsString = ' '.join(ocnLogs)

        # define the awk script to parse the ocn log files
        globalDiagAwkPath = '{0}/process_pop2_logfiles.globaldiag.awk'.format(env['TOOLPATH'])
        globalDiagAwkCmd = '{0} {1}'.format(globalDiagAwkPath, ocnLogsString).split(' ')

        # expand the *.dt.* into a list
        dtFiles = list()
        dtFiles = glob.glob('{0}/{1}.pop.dt.*'.format(env['WORKDIR'], env['CASE']))
        dtFilesString = ' '.join(dtFiles)

        # define the awk script to parse the ocn log files
        dtFilesAwkPath = '{0}/process_pop2_logfiles.dtfiles.awk'.format(env['TOOLPATH'])
        dtFilesAwkCmd = '{0} {1}'.format(dtFilesAwkPath, dtFilesString).split(' ')

        # run the awk scripts to generate the .txt files from the ocn logs and dt files
        cmdList = [ globalDiagAwkCmd, dtFilesAwkCmd ]
        for cmd in cmdList:
            try:
                subprocess.check_call(cmd, stdout=results, env=env)
            except subprocess.CalledProcessError as e:
                print('WARNING: {0} time series error executing command:'.format(self._shortname))
                print('    {0}'.format(e.cmd))
                print('    rc = {0}'.format(e.returncode))


    def generate_plots(self, env):
        """Put commands to generate plot here!
        """
        print('  Generating diagnostic plots for : {0}'.format(self.__class__.__name__))
        for ncl in self._ncl:
            diagUtilsLib.generate_ncl_plots(env, ncl)

    def convert_plots(self, workdir, imgFormat):
        """Converts plots for this class
        """
        #START HERE
        #TODO the expectedPlots are in tuples - need to loop through and just get the second tuple member
        self._convert_plots(workdir, imgFormat, self._expectedPlots_globalAvg)
        self._convert_plots(workdir, imgFormat, self._expectedPlots_Nino)
        self._convert_plots(workdir, imgFormat, self._expectedPlots_transportDiags)

    def _create_html(self, workdir, templatePath, imgFormat):
        """Creates and renders html that is returned to the calling wrapper
        """
        plot_tables = []
        plot_table = []

        suffix = ['globaAvg', 'Nino', 'transportDiags']

        #START HERE
        # build up the plot_tables array
        for k in range(len(suffix)):
            plot_list = eval('{0}_{1}'.format(self._expectedPlots, suffix[k]))
            num_plots = len(plot_list)
            num_last_row = num_plots % self._columns[k]
            num_rows = num_plots//self._columns[k]
            index = 0

            for i in range(num_rows):
                ptuple = []
                for j in range(self._columns[k]):
                    plot_file = plot_list[index]
                    img_file = '{0}.{1}'.format(plot_file, imgFormat)
                    rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                    if not rc:
                        ptuple.append('{0} - Error'.format(plot_file))
                    else:
                        ptuple.append(plot_file)
                    index += 1                    
                plot_table.append(ptuple)

            # pad out the last row
            if num_last_row > 0:
                plist = []
                for i in range(num_last_row):
                    plot_file = plot_list[index]
                    img_file = '{0}.{1}'.format(plot_file, imgFormat)
                    rc, err_msg = cesmEnvLib.checkFile( '{0}/{1}'.format(workdir, img_file), 'read' )
                    if not rc:
                        plist.append('{0} - Error'.format(plot_file))
                    else:
                        plist.append(plot_file)
                    index += 1                    

                for i in range(num_cols - num_last_row):
                    plist.append('')

                plot_table.append(plist)
            
            plot_tables.append(plot_table)

        # create a jinja2 template object
        templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
        templateEnv = jinja2.Environment( loader=templateLoader, keep_trailing_newline=False )

        template = templateEnv.get_template( self._template_file )

        # add the template variables
        templateVars = { 'title' : self._name,
                         'plot_tables' : plot_tables, 
                         'plot_headers' : self._expectedPlotsHeaders
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
