from __future__ import print_function

import sys

if sys.hexversion < 0x02070000:
    print(70 * "*")
    print("ERROR: {0} requires python >= 2.7.x. ".format(sys.argv[0]))
    print("It appears that you are running python {0}".format(
        ".".join(str(x) for x in sys.version_info[0:3])))
    print(70 * "*")
    sys.exit(1)

import traceback
import os
import errno

# import the helper utility module
from cesm_utils import cesmEnvLib
from diag_utils import diagUtilsLib

# import the diag baseclass module
from ocn_diags_bc import OceanDiagnostic

class modelVsObs(OceanDiagnostic):
    """model vs. observations ocean diagnostics setup
    """
    def __init__(self):
        """ initialize
        """
        super(modelVsObs, self).__init__()

        self._name = 'MODEL_VS_OBS'
        self._title = 'Model vs. Observations'

    def check_prerequisites(self, env, debugMsg):
        """ check prerequisites
        """
        super(modelVsObs, self).check_prerequisites(env)
        print("  Checking prerequisites for : {0}".format(self.__class__.__name__))

        # create the working directory if it doesn't already exists
        subdir = 'model_vs_obs.{0}_{1}'.format(env['YEAR0'], env['YEAR1'])
        workdir = '{0}/{1}'.format(env['WORKDIR'], subdir)
        debugMsg('workdir = {0}'.format(workdir), header=True)

        try:
            os.makedirs(workdir)
        except OSError as exception:
            if exception.errno != errno.EEXIST:
                err_msg = 'ERROR: {0} problem accessing the working directory {1}'.format(self.__class__.__name__, workdir)
                raise OSError(err_msg)

        env['WORKDIR'] = workdir

        # clean out the old working plot files from the workdir
        if env['CLEANUP_FILES'].upper() in ['T','TRUE']:
            cesmEnvLib.purge(workdir, '.*\.pro')
            cesmEnvLib.purge(workdir, '.*\.gif')
            cesmEnvLib.purge(workdir, '.*\.dat')
            cesmEnvLib.purge(workdir, '.*\.ps')
            cesmEnvLib.purge(workdir, '.*\.png')
            cesmEnvLib.purge(workdir, '.*\.html')

        # create the plot.dat file in the workdir used by all NCL plotting routines
        diagUtilsLib.create_plot_dat(env['WORKDIR'], env['XYRANGE'], env['DEPTHS'])

        # create symbolic links between the tavgdir and the workdir and get the real names of the mavg and tavg files
        env['MAVGFILE'], env['TAVGFILE'] = diagUtilsLib.createLinks(env['YEAR0'], env['YEAR1'], env['TAVGDIR'], env['WORKDIR'], env['CASE'], debugMsg)

        # setup the gridfile based on the resolution
        os.environ['gridfile'] = '{0}/tool_lib/zon_avg/grids/{1}_grid_info.nc'.format(env['DIAGROOTPATH'],env['RESOLUTION'])
        if env['VERTICAL'] == '42':
            os.environ['gridfile'] = '{0}/tool_lib/zon_avg/grids/{1}_42lev_grid_info.nc'.format(env['DIAGROOTPATH'],env['RESOLUTION'])

        # check if gridfile exists and is readable
        rc, err_msg = cesmEnvLib.checkFile(os.environ['gridfile'], 'read')
        if not rc:
            raise OSError(err_msg)

        env['GRIDFILE'] = os.environ['gridfile']

        # check the resolution and decide if some plot modules should be turned off
        if env['RESOLUTION'] == 'tx0.1v2' :
            env['PM_VELISOPZ'] = os.environ['PM_VELISOPZ'] = 'FALSE'
            env['PM_KAPPAZ'] = os.environ['PM_KAPPAZ'] = 'FALSE'

        # create the global zonal average file used by most of the plotting classes
        debugMsg('calling create_za', header=True)
        diagUtilsLib.create_za( env['WORKDIR'], env['TAVGFILE'], env['GRIDFILE'], env['TOOLPATH'], env, debugMsg )

        return env

    def run_diagnostics(self, env, scomm, debugMsg):
        """ call the necessary plotting routines to generate diagnostics plots
        """
        super(modelVsObs, self).run_diagnostics(env, scomm, debugMsg)

        # all the plot module XML vars start with PM_ 
        # TODO modify the XML so that the different diag types can specify different plots
        requested_plots = []
        for key, value in env.iteritems():
            if (re.search("\APM_", key) and value.upper() in ['T','TRUE']):
                requested_plots.append(key)

        # setup the plots to be called based on directives in the env_diags_ocn.xml file
        requested_plot_names = []
        local_requested_plots = list()
    
        # define the templatePath for all tasks
        templatePath = '{0}/diagnostics/diagnostics/ocn/Templates'.format(env['POSTPROCESS_PATH']) 

        if scomm.is_manager():
# START HERE to get requested plots for this diag type - need to update XML and make this
# a private method...
            requested_plot_names = setup_plots(env)
            print('User requested plots:')
            for plot in requested_plot_names:
                print('  {0}'.format(plot))

            if env['DOWEB'].upper() in ['T','TRUE']:
                
                debugMsg('Creating plot html header', header=True)

                templateLoader = jinja2.FileSystemLoader( searchpath=templatePath )
                templateEnv = jinja2.Environment( loader=templateLoader )
                
                TEMPLATE_FILE = 'model_vs_obs.tmpl'
                template = templateEnv.get_template( TEMPLATE_FILE )
    
                # test the template variables
                templateVars = { 'casename' : env['CASE'],
                                 'tagname' : env['CCSM_REPOTAG'],
                                 'start_year' : env['YEAR0'],
                                 'stop_year' : env['YEAR1']
                                 }

                plot_html = template.render( templateVars )

        scomm.sync()

        # broadcast requested plot names to all tasks
        requested_plot_names = scomm.partition(data=requested_plot_names, func=partition.Duplicate(), involved=True)

        local_requested_plots = scomm.partition(requested_plot_names, func=partition.EqualStride(), involved=True)
        scomm.sync()

        # define the local_html_list
        local_html_list = list()
        for requested_plot in local_requested_plots:
            try:
                plot = ocn_diags_plot_factory.oceanDiagnosticPlotFactory(requested_plot)

                debugMsg('Checking prerequisite for {0}'.format(plot.__class__.__name__), header=True)
                plot.check_prerequisites(env)

                debugMsg('Generating plots for {0}'.format(plot.__class__.__name__), header=True)
                plot.generate_plots(env)

                debugMsg('Converting plots for {0}'.format(plot.__class__.__name__), header=True)
                plot.convert_plots(env['WORKDIR'], env['IMAGEFORMAT'])

                html = plot.get_html(env['WORKDIR'], templatePath, env['IMAGEFORMAT'])
            
                local_html_list.append(str(html))
                debugMsg('local_html_list = {0}'.format(local_html_list), header=True, verbosity=2)

            except ocn_diags_plot_bc.RecoverableError as e:
                # catch all recoverable errors, print a message and continue.
                print(e)
                print("Skipped '{0}' and continuing!".format(request_plot))
            except RuntimeError as e:
                # unrecoverable error, bail!
                print(e)
                return 1

        scomm.sync()

        # define a tag for the MPI collection of all local_html_list variables
        html_msg_tag = 1

        if scomm.get_size() > 1:
            if scomm.is_manager():
                all_html  = [local_html_list]
                
                for n in range(1,scomm.get_size()):
                    rank, temp_html = scomm.collect(tag=html_msg_tag)
                    all_html.append(temp_html)

                debugMsg('all_html = {0}'.format(all_html), header=True, verbosity=2)
            else:
                return_code = scomm.collect(data=local_html_list, tag=html_msg_tag)

        scomm.sync()
        
        if scomm.is_manager():

            # merge the all_html list of lists into a single list
            all_html = list(itertools.chain.from_iterable(all_html))
            for each_html in all_html:
                debugMsg('each_html = {0}'.format(each_html), header=True, verbosity=2)
                plot_html += each_html

            debugMsg('Adding footer html', header=True)
            with open('{0}/footer.tmpl'.format(templatePath), 'r+') as tmpl:
                plot_html += tmpl.read()

            debugMsg('Writing plot html', header=True)
            with open( '{0}/index.html'.format(env['WORKDIR']), 'w') as index:
                index.write(plot_html)

            debugMsg('Copying stylesheet', header=True)
            shutil.copy2('{0}/diag_style.css'.format(templatePath), '{0}/diag_style.css'.format(env['WORKDIR']))

            debugMsg('Copying logo files', header=True)
            if not os.path.exists('{0}/logos'.format(env['WORKDIR'])):
                os.mkdir('{0}/logos'.format(env['WORKDIR']))

            for filename in glob.glob(os.path.join('{0}/logos'.format(templatePath), '*.*')):
                shutil.copy(filename, '{0}/logos'.format(env['WORKDIR']))

            if len(env['WEBDIR']) > 0 and len(env['WEBHOST']) > 0 and len(env['WEBLOGIN']) > 0:
                # copy over the files to a remote web server and webdir 
                diagUtilsLib.copy_html_files(env)
            else:
                print('Web files successfully created in directory {0}'.format(env['WORKDIR']))
                print('The env_diags_ocn.xml variable WEBDIR, WEBHOST, and WEBLOGIN were not set.')
                print('You will need to manually copy the web files to a remote web server.')

            print('*******************************************************************************')
            print('Successfully completed generating ocean diagnostics model vs. observation plots')
            print('*******************************************************************************')


