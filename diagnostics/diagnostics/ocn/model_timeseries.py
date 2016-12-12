from __future__ import print_function

import sys

if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

# import core python modules
import collections
import datetime
import errno
import glob
import gzip
import itertools
import os
import re
import shutil
import subprocess
import traceback

# import modules installed by pip into virtualenv
import jinja2

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the MPI related modules
from asaptools import partition, simplecomm, vprinter, timekeeper

# import the diag baseclass module
from ocn_diags_bc import OceanDiagnostic

# import the plot classes
from diagnostics.ocn.Plots import ocn_diags_plot_bc
from diagnostics.ocn.Plots import ocn_diags_plot_factory

class modelTimeseries(OceanDiagnostic):
    """model timeserieservations ocean diagnostics setup
    """
    def __init__(self):
        """ initialize
        """
        super(modelTimeseries, self).__init__()

        self._name = 'MODEL_TIMESERIES'
        self._title = 'Model Timeseries'

    def check_prerequisites(self, env):
        """ check prerequisites
        """
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))
        super(modelTimeseries, self).check_prerequisites(env)
        
        # chdir into the  working directory
        os.chdir(env['WORKDIR'])

        # clean out the old working plot files from the workdir
        if env['CLEANUP_FILES'].upper() in ['T','TRUE']:
            cesmEnvLib.purge(env['WORKDIR'], '.*\.pro')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.gif')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.dat')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.ps')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.png')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.html')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.log\.*')
            cesmEnvLib.purge(env['WORKDIR'], '.*\.pop\.d.\.*')

        # create the plot.dat file in the workdir used by all NCL plotting routines
        diagUtilsLib.create_plot_dat(env['WORKDIR'], env['XYRANGE'], env['DEPTHS'])

        # set the OBSROOT 
        env['OBSROOT'] = env['OBSROOTPATH']

        # check the resolution and decide if some plot modules should be turned off
        if env['RESOLUTION'] == 'tx0.1v2' :
            env['MTS_PM_MOCANN'] = os.environ['PM_MOCANN'] = 'FALSE'
            env['MTS_PM_MOCMON'] = os.environ['PM_MOCMON'] = 'FALSE'

        # check if cpl log file path is defined
        if len(env['CPLLOGFILEPATH']) == 0:
            # print a message that the cpl log path isn't defined and turn off CPLLOG plot module
            print('model timeseries - CPLLOGFILEPATH is undefined. Disabling MTS_PM_CPLLOG module')
            env['MTS_PM_CPLLOG'] = os.environ['PM_CPLLOG'] = 'FALSE'

        else:
            # check that cpl log files exist and gunzip them if necessary
            initcplLogs = cplLogs = list()
            initCplLogs = glob.glob('{0}/cpl.log.*'.format(env['CPLLOGFILEPATH']))
            if len(initCplLogs) > 0:
                for cplLog in initCplLogs:
                    logFileList = cplLog.split('/')
                    cplLogFile = logFileList[-1]
                    shutil.copy2(cplLog, '{0}/{1}'.format(env['WORKDIR'],cplLogFile))

                    # gunzip the cplLog in the workdir
                    if cplLogFile.lower().find('.gz') != -1:
                        cplLog_gunzip = cplLogFile[:-3]
                        inFile = gzip.open('{0}/{1}'.format(env['WORKDIR'],cplLogFile), 'rb')
                        outFile = open('{0}/{1}'.format(env['WORKDIR'],cplLog_gunzip), 'wb')
                        outFile.write( inFile.read() )
                        inFile.close()
                        outFile.close()

                        # append the gunzipped cpl log file to the cplLogs list
                        cplLogs.append('{0}/{1}'.format(env['WORKDIR'],cplLog_gunzip))

                        # remove the original .gz file in the workdir
                        os.remove('{0}/{1}'.format(env['WORKDIR'],cplLogFile))
                    else:
                        # append the original gunzipped cpl log file to the cplLogs list
                        cplLogs.append('{0}/{1}'.format(env['WORKDIR'],cplLogFile))

                # parse the cpllog depending on the coupler version - default to 7b
                print('model_timeseries: setting up heat and freshwater awk calls with cplLogs = {0}'.format(cplLogs))
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
                cplLogs.sort()
                cplLogsString = ' '.join(cplLogs)

                # define the awk scripts to parse the cpllog file
                heatPath = '{0}/process_{1}_logfiles_heat.awk'.format(env['TOOLPATH'], cplVersion)
                heatPath = os.path.abspath(heatPath)

                fwPath = '{0}/process_{1}_logfiles_fw.awk'.format(env['TOOLPATH'], cplVersion)
                fwPath = os.path.abspath(fwPath)
        
                heatCmd = '{0} y0={1} y1={2} {3}'.format(heatPath, env['TSERIES_YEAR0'], env['TSERIES_YEAR1'], cplLogsString).split(' ')
                freshWaterCmd = '{0} y0={1} y1={2} {3}'.format(fwPath, env['TSERIES_YEAR0'], env['TSERIES_YEAR1'], cplLogsString).split(' ')

                # run the awk scripts to generate the .txt files from the cpllogs
                cmdList = [ (heatCmd, heatFile, env['ntailht']), (freshWaterCmd, freshWaterFile, env['ntailfw']) ]
                for cmd in cmdList:
                    outFile = '{0}.txt'.format(cmd[1])
                    with open (outFile, 'w') as results:
                        try:
                            subprocess.check_call(cmd[0], stdout=results, env=env)
                        except subprocess.CalledProcessError as e:
                            print('WARNING: {0} time series error executing command:'.format(self._name))
                            print('    {0}'.format(e.cmd))
                            print('    rc = {0}'.format(e.returncode))

                        rc, err_msg = cesmEnvLib.checkFile(outFile, 'read')
                        if rc:
                            # get the tail of the .txt file and redirect to a .asc file for the web
                            ascFile = '{0}.asc'.format(cmd[1])
                            with open (ascFile, 'w') as results:
                                try:
                                    # TODO - read the .txt in and write just the lines needed to avoid subprocess call
                                    tailCmd = 'tail -{0} {1}.txt'.format(cmd[2], cmd[1]).split(' ')
                                    subprocess.check_call(tailCmd, stdout=results, env=env)
                                except subprocess.CalledProcessError as e:
                                    print('WARNING: {0} time series error executing command:'.format(self._name))
                                    print('    {0}'.format(e.cmd))
                                    print('    rc = {0}'.format(e.returncode))

            else:
                print('model timeseries - Coupler logs do not exist. Disabling MTS_PM_CPLLOG module')
                env['MTS_PM_CPLLOG'] = os.environ['PM_CPLLOG'] = 'FALSE'

        # check if ocn log files exist
        if len(env['OCNLOGFILEPATH']) == 0:
            # print a message that the ocn log path isn't defined and turn off POPLOG plot module
            print('model timeseries - OCNLOGFILEPATH is undefined. Disabling MTS_PM_YPOPLOG module')
            env['MTS_PM_YPOPLOG'] = os.environ['PM_YPOPLOG'] = 'FALSE'
        
        else:
            # check that ocn log files exist and gunzip them if necessary
            initOcnLogs = ocnLogs = list()
            initOcnLogs = glob.glob('{0}/ocn.log.*'.format(env['OCNLOGFILEPATH']))
            if len(initOcnLogs) > 0:
                for ocnLog in initOcnLogs:
                    logFileList = ocnLog.split('/')
                    ocnLogFile = logFileList[-1]
                    shutil.copy2(ocnLog, '{0}/{1}'.format(env['WORKDIR'],ocnLogFile))

                    # gunzip the ocnLog in the workdir
                    if ocnLogFile.lower().find('.gz') != -1:
                        ocnLog_gunzip = ocnLogFile[:-3]
                        inFile = gzip.open('{0}/{1}'.format(env['WORKDIR'],ocnLogFile), 'rb')
                        outFile = open('{0}/{1}'.format(env['WORKDIR'],ocnLog_gunzip), 'wb')
                        outFile.write( inFile.read() )
                        inFile.close()
                        outFile.close()

                        # append the gunzipped ocn log file to the ocnLogs list
                        ocnLogs.append('{0}/{1}'.format(env['WORKDIR'],ocnLog_gunzip))

                        # remove the original .gz file in the workdir
                        os.remove('{0}/{1}'.format(env['WORKDIR'],ocnLogFile))

                    else:
                        # append the original gunzipped ocn log file to the ocnLogs list
                        ocnLogs.append('{0}/{1}'.format(env['WORKDIR'],ocnLogFile))

                # expand the ocn.log* into a list
                ocnLogs.sort()
                ocnLogsString = ' '.join(ocnLogs)

                # define the awk script to parse the ocn log files
                globalDiagAwkPath = '{0}/process_pop2_logfiles.globaldiag.awk'.format(env['TOOLPATH'])
                globalDiagAwkCmd = '{0} {1}'.format(globalDiagAwkPath, ocnLogsString).split(' ')
                print('model_timeseries: globalDiagAwkCmd = {0}'.format(globalDiagAwkCmd))

                # run the awk scripts to generate the .txt files from the ocn logs
                try:
                    subprocess.check_call(globalDiagAwkCmd)
                except subprocess.CalledProcessError as e:
                    print('WARNING: {0} time series error executing command:'.format(self._name))
                    print('    {0}'.format(e.cmd))
                    print('    rc = {0}'.format(e.returncode))
            else:
                print('model timeseries - Ocean logs do not exist. Disabling MTS_PM_YPOPLOG and MTS_PM_ENSOWVLT modules')
                env['MTS_PM_YPOPLOG'] = os.environ['PM_YPOPLOG'] = 'FALSE'
                env['MTS_PM_ENSOWVLT'] = os.environ['PM_ENSOWVLT'] = 'FALSE'

        # check if dt files exist
        if len(env['DTFILEPATH']) == 0:
            # print a message that the dt file path isn't defined and turn off POPLOG plot module
            print('model timeseries - DTFILEPATH is undefined. Disabling MTS_PM_YPOPLOG and MTS_PM_ENSOWVLT modules')
            env['MTS_PM_YPOPLOG'] = os.environ['PM_YPOPLOG'] = 'FALSE'
            env['MTS_PM_ENSOWVLT'] = os.environ['PM_ENSOWVLT'] = 'FALSE'
        
        else:
            # check that dt files exist
            dtFiles = list()
            dtFiles = glob.glob('{0}/{1}.pop.dt.*'.format(env['DTFILEPATH'], env['CASE']))
            print('dtFiles = {0}'.format(dtFiles))
            if len(dtFiles) > 0:
                for dtFile in dtFiles:
                    logFileList = dtFile.split('/')
                    dtLogFile = logFileList[-1]
                    shutil.copy2(dtFile, '{0}/{1}'.format(env['WORKDIR'],dtLogFile))

                # expand the *.dt.* into a list
                dtFiles.sort()
                dtFilesString = ' '.join(dtFiles)

                # define the awk script to parse the dt log files
                dtFilesAwkPath = '{0}/process_pop2_dtfiles.awk'.format(env['TOOLPATH'])
                dtFilesAwkCmd = '{0} {1}'.format(dtFilesAwkPath, dtFilesString).split(' ')
                print('model_timeseries: dtFilesAwkCmd = {0}'.format(dtFilesAwkCmd))

                # run the awk scripts to generate the .txt files from the dt log files
                try:
                    subprocess.check_call(dtFilesAwkCmd)
                except subprocess.CalledProcessError as e:
                    print('WARNING: {0} time series error executing command:'.format(self._name))
                    print('    {0}'.format(e.cmd))
                    print('    rc = {0}'.format(e.returncode))
            else:
                print('model_timeseries - ocean dt files do not exist. Disabling MTS_PM_YPOPLOG and MTS_PM_ENSOWVLT modules')
                env['MTS_PM_YPOPLOG'] = os.environ['PM_YPOPLOG'] = 'FALSE'
                env['MTS_PM_ENSOWVLT'] = os.environ['PM_ENSOWVLT'] = 'FALSE'

        return env

    def run_diagnostics(self, env, scomm):
        """ call the necessary plotting routines to generate diagnostics plots
        """
        super(modelTimeseries, self).run_diagnostics(env, scomm)
        scomm.sync()

        # setup some global variables
        requested_plots = list()
        local_requested_plots = list()

        # define the templatePath for all tasks
        templatePath = '{0}/diagnostics/diagnostics/ocn/Templates'.format(env['POSTPROCESS_PATH']) 

        # all the plot module XML vars start with MVO_PM_  need to strip that off
        for key, value in env.iteritems():
            if (re.search("\AMTS_PM_", key) and value.upper() in ['T','TRUE']):
                k = key[4:]                
                requested_plots.append(k)

        scomm.sync()
        print('model timeseries - after scomm.sync requested_plots = {0}'.format(requested_plots))

        if scomm.is_manager():
            print('model timeseries - User requested plot modules:')
            for plot in requested_plots:
                print('  {0}'.format(plot))

            print('model timeseries - Creating plot html header')
            templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
            templateEnv = jinja2.Environment( loader=templateLoader )
                
            template_file = 'model_timeseries.tmpl'
            template = templateEnv.get_template( template_file )
    
            # get the current datatime string for the template
            now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

            # test the template variables
            templateVars = { 'casename' : env['CASE'],
                             'tagname' : env['CESM_TAG'],
                             'start_year' : env['TSERIES_YEAR0'],
                             'stop_year' : env['TSERIES_YEAR1'],
                             'today': now
                             }

            print('model timeseries - Rendering plot html header')
            plot_html = template.render( templateVars )

        scomm.sync()

        print('model timeseries - Partition requested plots')
        # partition requested plots to all tasks
        local_requested_plots = scomm.partition(requested_plots, func=partition.EqualStride(), involved=True)
        scomm.sync()

        for requested_plot in local_requested_plots:
            try:
                plot = ocn_diags_plot_factory.oceanDiagnosticPlotFactory('timeseries', requested_plot)

                print('model timeseries - Checking prerequisite for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                plot.check_prerequisites(env)

                print('model timeseries - Generating plots for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                plot.generate_plots(env)

                print('model timeseries - Converting plots for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                plot.convert_plots(env['WORKDIR'], env['IMAGEFORMAT'])

            except RuntimeError as e:
                # unrecoverable error, bail!
                print("model timeseries - Skipped '{0}' and continuing!".format(requested_plot))
                print(e)

        scomm.sync()

        # initialize OrderedDict with plot_order list entries as key
        html_order = collections.OrderedDict()
        for plot in env['MTS_PLOT_ORDER'].split():
            html_order[plot] = '';

        if scomm.is_manager():
            for plot in env['MTS_PLOT_ORDER'].split():
                if plot in requested_plots:
                    print('calling get_html for plot = {0}'.format(plot))
                    plot_obj = ocn_diags_plot_factory.oceanDiagnosticPlotFactory('timeseries', plot)
                    shortname, html = plot_obj.get_html(env['WORKDIR'], templatePath, env['IMAGEFORMAT'])
                    html_order[shortname] = html

            for k, v in html_order.iteritems():
                print('Adding html for plot = {0}'.format(k))
                plot_html += v

            print('model timeseries - Adding footer html')
            with open('{0}/footer.tmpl'.format(templatePath), 'r') as tmpl:
                plot_html += tmpl.read()

            print('model timeseries - Writing plot index.html')
            with open( '{0}/index.html'.format(env['WORKDIR']), 'w') as index:
                index.write(plot_html)

            print('**************************************************************************')
            print('Successfully completed generating ocean diagnostics model timeseries plots')
            print('**************************************************************************')

        scomm.sync()

        # append the web_dir location to the env
        key = 'OCNDIAG_WEBDIR_{0}'.format(self._name)
        env[key] = env['WORKDIR']

        return env

