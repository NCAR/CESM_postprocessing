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
import datetime
import errno
import glob
import gzip
import itertools
import os
import re
import shutil
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
            cplLogs = list()
            cplLogs = glob.glob('{0}/cpl.log.*'.format(env['CPLLOGFILEPATH']))
            if len(cplLogs) > 0:
                for cplLog in cplLogs:
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

                        # remove the original .gz file in the workdir
                        os.remove('{0}/{1}'.format(env['WORKDIR'],cplLogFile))
            else:
                print('model timeseries - Coupler logs do not exist. Disabling MTS_PM_CPLLOG module')
                env['MTS_PM_CPLLOG'] = os.environ['PM_CPLLOG'] = 'FALSE'

        # check if ocn log files exist
        if len(env['OCNLOGFILEPATH']) == 0:
            # print a message that the ocn log path isn't defined and turn off POPLOG plot module
            print('model timeseries - OCNLOGFILEPATH is undefined. Disabling MTS_PM_POPLOG module')
            env['MTS_PM_POPLOG'] = os.environ['PM_POPLOG'] = 'FALSE'
        
        else:
            # check that ocn log files exist and gunzip them if necessary
            ocnLogs = list()
            ocnLogs = glob.glob('{0}/ocn.log.*'.format(env['OCNLOGFILEPATH']))
            if len(ocnLogs) > 0:
                for ocnLog in ocnLogs:
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

                        # remove the original .gz file in the workdir
                        os.remove('{0}/{1}'.format(env['WORKDIR'],ocnLogFile))
            else:
                print('model timeseries - Ocean logs do not exist. Disabling MTS_PM_POPLOG module')
                env['MTS_PM_POPLOG'] = os.environ['PM_POPLOG'] = 'FALSE'

        # check if dt files exist
        if len(env['DTFILEPATH']) == 0:
            # print a message that the dt file path isn't defined and turn off POPLOG plot module
            print('model timeseries - OCNLOGFILEPATH is undefined. Disabling MTS_PM_POPLOG module')
            env['MTS_PM_POPLOG'] = os.environ['PM_POPLOG'] = 'FALSE'
        
        else:
            # check that dt files exist
            dtFiles = list()
            dtFiles = glob.glob('{0}/{1}.dt.*'.format(env['CASE'], env['OCNLOGFILEPATH']))
            if len(dtFiles) > 0:
                for dtFile in dtFiles:
                    logFileList = dtFile.split('/')
                    dtLogFile = logFileList[-1]
                    shutil.copy2(ocnLog, '{0}/{1}'.format(env['WORKDIR'],dtLogFile))

                    # gunzip the dt filein the workdir
                    if dtLogFile.lower().find('.gz') != -1:
                        dtLog_gunzip = dtLogFile[:-3]
                        inFile = gzip.open('{0}/{1}'.format(env['WORKDIR'],dtLogFile), 'rb')
                        outFile = open('{0}/{1}'.format(env['WORKDIR'],dtLog_gunzip), 'wb')
                        outFile.write( inFile.read() )
                        inFile.close()
                        outFile.close()

                        # remove the original .gz file in the workdir
                        os.remove('{0}/{1}'.format(env['WORKDIR'],dtLogFile))

            else:
                print('model timeseries - ocean dt files do not exist. Disabling MTS_PM_POPLOG module')
                env['MTS_PM_POPLOG'] = os.environ['PM_POPLOG'] = 'FALSE'
            
        return env

    def run_diagnostics(self, env, scomm):
        """ call the necessary plotting routines to generate diagnostics plots
        """
        super(modelTimeseries, self).run_diagnostics(env, scomm)
        scomm.sync()

        # setup some global variables
        requested_plots = list()
        local_requested_plots = list()
        local_html_list = list()

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

            if env['DOWEB'].upper() in ['T','TRUE']:
                
                print('model timeseries - Creating plot html header')
                templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
                templateEnv = jinja2.Environment( loader=templateLoader )
                
                template_file = 'model_timeseries.tmpl'
                template = templateEnv.get_template( template_file )
    
                # get the current datatime string for the template
                now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

                # test the template variables
                templateVars = { 'casename' : env['CASE'],
                                 'tagname' : env['CCSM_REPOTAG'],
                                 'start_year' : env['YEAR0'],
                                 'stop_year' : env['YEAR1'],
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

                print('model timeseries - Creating HTML for {0} on rank {1}'.format(plot.__class__.__name__, scomm.get_rank()))
                html = plot.get_html(env['WORKDIR'], templatePath, env['IMAGEFORMAT'])
            
                local_html_list.append(str(html))
                #print('local_html_list = {0}'.format(local_html_list))

            except ocn_diags_plot_bc.RecoverableError as e:
                # catch all recoverable errors, print a message and continue.
                print(e)
                print("model timeseries - Skipped '{0}' and continuing!".format(request_plot))
            except RuntimeError as e:
                # unrecoverable error, bail!
                print(e)
                return 1

        scomm.sync()

        # define a tag for the MPI collection of all local_html_list variables
        html_msg_tag = 1

        all_html = list()
        all_html = [local_html_list]
        if scomm.get_size() > 1:
            if scomm.is_manager():
                all_html  = [local_html_list]
                
                for n in range(1,scomm.get_size()):
                    rank, temp_html = scomm.collect(tag=html_msg_tag)
                    all_html.append(temp_html)

                #print('all_html = {0}'.format(all_html))
            else:
                return_code = scomm.collect(data=local_html_list, tag=html_msg_tag)

        scomm.sync()
        
        if scomm.is_manager():

            # merge the all_html list of lists into a single list
            all_html = list(itertools.chain.from_iterable(all_html))
            for each_html in all_html:
                #print('each_html = {0}'.format(each_html))
                plot_html += each_html

            print('model timeseries - Adding footer html')
            with open('{0}/footer.tmpl'.format(templatePath), 'r+') as tmpl:
                plot_html += tmpl.read()

            print('model timeseries - Writing plot index.html')
            with open( '{0}/index.html'.format(env['WORKDIR']), 'w') as index:
                index.write(plot_html)

            if len(env['WEBDIR']) > 0 and len(env['WEBHOST']) > 0 and len(env['WEBLOGIN']) > 0:
                # copy over the files to a remote web server and webdir 
                diagUtilsLib.copy_html_files(env, 'model_timeseries')
            else:
                print('model timeseries - Web files successfully created in directory:')
                print('{0}'.format(env['WORKDIR']))
                print('The env_diags_ocn.xml variable WEBDIR, WEBHOST, and WEBLOGIN were not set.')
                print('You will need to manually copy the web files to a remote web server.')

            print('**************************************************************************')
            print('Successfully completed generating ocean diagnostics model timeseries plots')
            print('**************************************************************************')


