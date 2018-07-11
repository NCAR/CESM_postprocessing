"""
MIP Table Parser

Copyright 2017, University Corporation for Atmospheric Research
LICENSE: See the LICENSE.rst file for details
"""

import sys

#=============================================
# Parse and Standardize the MIP table.
# Return a dcitionary that contains the parsed
# information.
#=============================================
def  mip_table_parser(exp,mip,table,variables,type=None,user_vars={},user_axes={},user_tableInfo={}):
    """
    Function will parse three different MIP table formats: tab deliminated, CMOR, and XML.
    After the table has been parsed, the information is standardized into the three dictionaries 
    and combined into one final dictionary.  The three dictionaries are keyed with 'variables',  
    'axes', and 'table_info'.  The standardization methods found in the three dictionaries 
    resemble the identifiers used in the CMOR code.  Variables are indexed by their string
    id/label/variable_entry name.
    Usage examples - table_dict = mip_table_parser('6hrLev','xml')
                     table_dict = mip_table_parser('Tables/CMIP5_Amon','cmor')
                     table_dict = mip_table_parser('Tables/CMIP6_MIP_tables.txt','excel')

    Parameters:
        exp (str): Name of the experiment.
        table_name (str):  Full path to a table.  Or in the case of XML, the experiment name.
        type (str): One of 3 keys that identify table type: 'excel', 'cmor', or 'xml'.
        user_var (dict): Allows users to add another synonym for one of the standard variable field keys.
        user_axes (dict): Allows users to add another synonym for one of the standard axes field keys.
        user_tableInfo (dict): Allows users to add another synonym for one of the standard table field keys. 

    Returns:
        table_dict (dict): A dictionary that holds all of the parsed table information.  Contains the keys:
        'variables', 'axes', and 'table_info'.  Each of these are dictionaries, keyed with variable names and
        each variable has a value of a dictionary keyed with the standard field names.        
    """
    # Standardized identifiers for variable fields
    # Format: standardName: [synonym list]
    table_var_fields = {
			'cell_measures': ['cell_measures'],
			'cell_methods': ['cell_methods'],
			'cf_standard_name': ['CF Standard Name','CF_Standard_Name','cf_standard_name','standard_name'],
			'comment': ['comment'],
			'deflate': ['deflate'],
			'deflate_level': ['deflate_level'],
			'description': ['description'],
			'dimensions': ['dimensions'],
			'ext_cell_measures': ['ext_cell_measures'],
			'flag_meanings': ['flag_meanings'],
			'flag_values': ['flag_values'],
			'frequency': ['frequency'],
			'id': ['id','label','variable_entry'],
			'long_name': ['long_name'],
			'modeling_realm': ['modeling_realm'],
			'ok_min_mean_abs': ['ok_min_mean_abs'],
			'ok_max_mean_abs': ['ok_max_mean_abs'],
			'out_name': ['out_name'],
			'positive': ['positive'],
			'prov': ['prov'],
			'provNote': ['provNote'],
			'required': ['required'],
			'shuffle': ['shuffle'],
			'title': ['title'],
			'type': ['type'],
			'units': ['units'],
			'valid_max': ['valid_max'],
			'valid_min': ['valid_min']
    }

    # Standardized identifiers for axes fields
    # Format: standardName: [synonym list]
    table_axes_fields = {
			 'axis': ['axis'],
			 'bounds_values': ['bounds_values'],
			 'climatology': ['climatology'],
			 'convert_to': ['convert_to'],
			 'coords_attrib': ['coords_attrib'],
			 'formula': ['formula'],
			 'id': ['id'],
			 'index_only': ['index_only'],
			 'long_name': ['long_name'],
			 'must_call_cmor_grid': ['must_call_cmor_grid'],
			 'must_have_bounds': ['must_have_bounds'],
			 'out_name': ['out_name'],
			 'positive': ['positive'],
			 'requested': ['requested'],
			 'requested_bounds': ['bounds_requested','requested_bounds'],
			 'required': ['required'],
			 'standard_name': ['standard_name'],
			 'stored_direction': ['stored_direction'],
			 'tolerance': ['tolerance'],
			 'tol_on_requests': ['tol_on_requests'],
			 'type': ['type'],
			 'units': ['units'],
			 'valid_max': ['valid_max'],
			 'valid_min': ['valid_min'],
			 'value': ['value'],
			 'z_bounds_factors': ['z_bounds_factors'],
			 'z_factors': ['z_factors']
    }

    # Standardized identifiers for table information fields
    # Format: standardName: [synonym list]
    table_fields = {
			'approx_interval': ['approx_interval'],
			'approx_interval_error': ['approx_interval_error'],
			'approx_interval_warning': ['approx_interval_warning'],
			'baseURL': ['baseURL'],
			'cf_version': ['cf_version'],
			'cmor_version': ['cmor_version'],
			'expt_id_ok': ['expt_id_ok'],
			'forcings': ['forcings'],
			'frequency': ['frequency'],
			'generic_levels': ['generic_levels'],
			'magic_number': ['magic_number'],
			'missing_value': ['missing_value'],
			'modeling_realm': ['modeling_realm'],
			'product': ['product'],
			'project_id': ['project_id'],
			'required_global_attributes': ['required_global_attributes'],
			'table_date': ['table_date'],
			'table_id': ['table_id'],
			'tracking_prefix': ['tracking_prefix']
    }

    # Set the type of table and return a dictionary that contains the read information.
    if type == 'excel':
        p = ParseExcel()
    elif type == 'cmor':
        p = ParseCmorTable()
    elif type == 'xml':
        p = ParseXML()
    return p.parse_table(exp,mip,table,variables,table_var_fields,table_axes_fields,table_fields,
                        user_vars,user_axes,user_tableInfo)
 
#=============================================
#  Find the standardization key to use
#=============================================
def _get_key(key, table, user_table):
    """
    Find the standardization key to use.
    
    Parameters:
        key (str): Supplied field name to match to a standard key
        table (dict):  One of the three standardized field dictionaries.
        user_table (dict):  A user created dictionary.  Keys should match a key already in 
                            the table argument, values are the new field names used in the table.
 
    Returns:
        k (str): The key to use that matches the standardization.  Program will exit if no matching 
                 key is found. 
    """
    for k,v in table.iteritems():
        if key in v: # Search for field name in standard dictionary.
	    return k
	elif k in user_table.keys(): # Search for field name in user created dictionary.
	    if key in user_table[k]:
	        return k
    # field name is not recognized.  Exit the program with an error.
    print('Error: ',key,' is not a valid field name at this time.  Please define and resubmit.')
    sys.exit(1)


#=============================================
#  Parse Excel Spreadsheets that have been
#  reformatted to tab deliminated fields. 
#=============================================
class ParseExcel(object):

    def __init__(self):
        super(ParseExcel, self).__init__()

    #=============================================
    # Parse the tab deliminated table file
    #=============================================
    def parse_table(self,exp,mip,table,variables,table_var_fields,table_axes_fields,table_fields,
                    user_vars,user_axes,user_tableInfo):
        """
        Function will parse a tab deliminated file and return a dictionary containing
        the parsed fields.

        Parameter:
            exp (str):  The name of the experiment.
            table_name (str): The full path to the table to be parsed.
            table_var_fields (dict):  Dictionary containing standardized field var names 
                                      as keys and acceptable synonyms as values.
            table_axes_fields (dict): Dictionary containing standardized field axes names 
                                      as keys and acceptable synonyms as values.
            table_fields (dict): Dictionary containing standardized table field names 
                                 as keys and acceptable synonyms as values.
            user_vars (dict): User defined dictionary.  Keys should match standard name. 
                              Values should be a list of acceptable field names.
            user_axes (dict): User defined dictionary.  Keys should match standard name. 
                              Values should be a list of acceptable field names.
            user_tableInfo (dict): User defined dictionary.  Keys should match standard name. 
                                   Values should be a list of acceptable field names.  

        Returns:
            table_dict (dict): A dictionary that holds all of the parsed table information.  Contains the keys:
            'variables', 'axes', and 'table_info'.  Each of these are dictionaries, keyed with variable names and
            each variable has a value of a dictionary keyed with the standard field names.           
        """
        from openpyxl import load_workbook

	table_dict = {}

        for t in table:
           wb = load_workbook(t)
           for sheet in wb.get_sheet_names():
               if sheet != 'Notes': 
                   s = wb.get_sheet_by_name(sheet)          
                   variables = {}
                   axes = {}
                   cols = []
                   table_info = {}
                   for c in range(0,len(s.columns)):
                       cols.append(s.rows[0][c].value)
                   for r in range(1,len(s.rows)):
                       vnc = cols.index('Variable Name')
                       vn = s.rows[r][vnc].value
                       variables[vn] = {}
                       for c in range(0,len(s.columns)):
                           variables[vn][cols[c]] = s.rows[r][c].value
                       variables[vn]['variable_id'] = vn
                       variables[vn]['mipTable'] = sheet
                       variables[vn]['coordinates'] = variables[vn]['dimensions'].strip().replace(' ','|')
                       dims = variables[vn]['dimensions'].encode("utf-8").split()
                       for dim in dims:
                           if dim not in axes.keys():
                               axes[dim] = {}
                   table_info["table_id"] = sheet
                   table_dict[sheet] = {}
                   table_dict[sheet]['variables'] = variables
                   table_dict[sheet]['axes'] = axes
                   table_dict[sheet]['table_info'] = table_info


	return table_dict


#=============================================
# Parses standard CMOR table files
#=============================================
class ParseCmorTable(object):

    def _init_():
        super(ParseCmorTable, self).__init__()

    #=============================================
    #  Parse a CMOR text file
    #=============================================
    def parse_table(self, exp,mip,table,v_list,table_var_fields,table_axes_fields,table_fields,
                    user_vars,user_axes,user_tableInfo):
        """
        Function will parse a CMOR table text file and return a dictionary containing
        the parsed fields.

        Parameter:
            exp (str):  The name of the experiment.
            table_name (str): The full path to the table to be parsed.
            table_var_fields (dict):  Dictionary containing standardized field var names 
                                      as keys and acceptable synonyms as values.
            table_axes_fields (dict): Dictionary containing standardized field axes names 
                                      as keys and acceptable synonyms as values.
            table_fields (dict): Dictionary containing standardized table field names 
                                 as keys and acceptable synonyms as values.
            user_vars (dict): User defined dictionary.  Keys should match standard name. 
                              Values should be a list of acceptable field names.
            user_axes (dict): User defined dictionary.  Keys should match standard name. 
                              Values should be a list of acceptable field names.
            user_tableInfo (dict): User defined dictionary.  Keys should match standard name. 
                                   Values should be a list of acceptable field names.  

        Returns:
            table_dict (dict): A dictionary that holds all of the parsed table information.  Contains the keys:
            'variables', 'axes', and 'table_info'.  Each of these are dictionaries, keyed with variable names and
            each variable has a value of a dictionary keyed with the standard field names.           
        """
        import json

        # Open and load the CMOR/CMIP json file
        total_request = {}
        print table
        for t in table:
            table_dict = {}
            with open(t) as f:
                mt = json.load(f)

            if len(v_list) == 0:
                v_list = mt["variable_entry"].keys()

            variables = {}
            axes = {}
            for var in v_list:
                v = mt["variable_entry"][var]
                variables[var] = v
                variables[var]["variable_id"] = var
                variables[var]['realm'] = mt['Header']['realm']
                variables[var]['mipTable'] = mt['Header']['table_id'].replace('Table ','')
                variables[var]['frequency'] = mt['Header']['frequency']
                variables[var]['coordinates'] = v['dimensions'].replace(' ','|')
                dims = v['dimensions'].encode("utf-8").split()
                for dim in dims:
                    if dim not in axes.keys() and dim in mt['axis_entry'].keys():
                        axes[dim] = mt['axis_entry'][dim]

            # Combine three separate dictionaries into the table summary dictionary
	    table_dict['variables'] = variables
	    table_dict['table_info'] = mt['Header']
            table_dict['axes'] = axes
            table_id = mt['Header']['table_id'].replace('Table ','')
            total_request[table_id] = table_dict
	return total_request

#=============================================
#  Parse the XML format
#=============================================
class ParseXML(object):

    def _init_():
        super(ParseXML, self, mips,table_var_fields,table_axes_fields,table_fields).__init__()

    #=============================================
    # Parse the XML format using dreqPy
    #=============================================
    def parse_table(self,exp,mips,tables,v_list,table_var_fields,table_axes_fields,table_fields,
                    user_vars,user_axes,user_tableInfo):
        """
        Function will parse an XML file using dreqPy and return a dictionary containing
        the parsed fields.

        Parameter:
            exp (str):  The name of the experiment.
            miptable (str): The name of the miptable.
            table_var_fields (dict):  Dictionary containing standardized field var names 
                                      as keys and acceptable synonyms as values.
            table_axes_fields (dict): Dictionary containing standardized field axes names 
                                      as keys and acceptable synonyms as values.
            table_fields (dict): Dictionary containing standardized table field names 
                                 as keys and acceptable synonyms as values.
            user_vars (dict): User defined dictionary.  Keys should match standard name. 
                              Values should be a list of acceptable field names.
            user_axes (dict): User defined dictionary.  Keys should match standard name. 
                              Values should be a list of acceptable field names.
            user_tableInfo (dict): User defined dictionary.  Keys should match standard name. 
                                   Values should be a list of acceptable field names.  

        Returns:
            table_dict (dict): A dictionary that holds all of the parsed table information.  Contains the keys:
            'variables', 'axes', and 'table_info'.  Each of these are dictionaries, keyed with variable names and
            each variable has a value of a dictionary keyed with the standard field names.           
        """
        from dreqPy import dreq

        dq = dreq.loadDreq()

        # Get table id
#        if len(g_id) == 0:
#            print 'ERROR: Variable group/table ',table_name, ' not supported.'  
#            print 'Please select from the following: '
#            print dq.inx.requestVarGroup.label.keys()
#            print '\nIf your selected table is listed, it may not be supported in this verison of dreqpy.'
#            print '\nEXITING. \n'
#            sys.exit(1) 
#        # Get the id's of the variables in this table
#        g_vars = dq.inx.iref_by_sect[g_id[0]].a

        # Get a list of mips for the experiment
#        print sorted(dq.inx.experiment.label.keys()),len(dq.inx.experiment.label.keys())
        e_mip = []
        e_id = dq.inx.experiment.label[exp]
        if len(e_id)==0:
            print '\033[91m','Invalid experiment name.  Please choose from the folowing options:','\033[0m' 
            print sorted(dq.inx.experiment.label.keys()),len(dq.inx.experiment.label.keys())
            return {} 
        activity_id = dq.inx.uid[e_id[0]].mip
        e_vars = dq.inx.iref_by_sect[e_id[0]].a
        if len(e_vars['requestItem']) == 0:
            e_vars = dq.inx.iref_by_sect[dq.inx.uid[e_id[0]].egid].a
        total_request = {}
        for ri in e_vars['requestItem']:

            table_info = {}
            dr = dq.inx.uid[ri]
            if dr.mip in mips or '--ALL--' in mips:

                table_dict = {}
                variables = {}
                axes = {}
                table_info = {}
                data = {}

                table_info['experiment'] = dq.inx.uid[e_id[0]].title
                table_info['experiment_id'] = exp
                table_info['data_specs_version'] = dreq.version
                table_info['activity_id'] = activity_id


                rl = dq.inx.requestLink.uid[dr.rlid]
                rvg = dq.inx.requestVarGroup.uid[rl.refid]
                vars = dq.inx.iref_by_sect[rl.refid].a
                axes_list = []
                var_list = []
                if len(v_list) == 0:
                    var_list = vars['requestVar'] 
                else:
                    for v in v_list:
                        uids = dq.inx.requestVar.label[v]
                        for uid in uids:
                            if uid in vars['requestVar']:
                                var_list.append(uid)
                for rv in var_list:
                    var = {}
                    v_id = dq.inx.uid[rv].vid  # Get the CMORvar id
                    c_var = dq.inx.uid[v_id]
	            # Set what we can from the CMORvar section
                    if hasattr(c_var,'mipTable'):
                        var['mipTable']=c_var.mipTable
                        if c_var.mipTable in tables or '--ALL--' in tables: 
                            var["_FillValue"] = "1e+20"
                            if hasattr(c_var,'deflate'):
                                var['deflate']= c_var.deflate
                            if hasattr(c_var,'deflate_level'):
                                var['deflate_level']= c_var.deflate_level
                            if hasattr(c_var,'description'):
                                var['description']= c_var.description
	                    if hasattr(c_var,'frequency'):
                                var['frequency']= c_var.frequency
                                table_info['frequency']= c_var.frequency
	                    if hasattr(c_var,'label'):
                                var['id']= c_var.label
                                var['out_name'] = c_var.label
                                var['variable_id'] = c_var.label
                                l = dq.inx.var.label[c_var.label]
                                if len(l)>0:
                                    var['standard_name'] = dq.inx.var.uid[l[0]].sn
	                    if hasattr(c_var,'modeling_realm'):
                                var['realm']= c_var.modeling_realm
	                    #if hasattr(c_var,'ok_min_mean_abs'):
                            #    var['ok_min_mean_abs']= c_var.ok_min_mean_abs
	                    #if hasattr(c_var,'ok_max_mean_abs'):
                            #    var['ok_max_mean_abs']= c_var.ok_max_mean_abs
	                    if hasattr(c_var,'out_name'):
                                var['out_name']= c_var.label #?
	                    if hasattr(c_var,'positive'):
                                var['positive']= c_var.positive
                            if hasattr(c_var,'direction'):
                                var['direction']= c_var.direction
	                    if hasattr(c_var,'prov'):
                                var['prov']= c_var.prov
	                    if hasattr(c_var,'procNote'):
                                var['provcNote']= c_var.procNote
	                    if hasattr(c_var,'shuffle'):
                                var['shuffle']= c_var.shuffle
	                    if hasattr(c_var,'title'):
                                var['title']= c_var.title
                                var['long_name']= c_var.title
                            if hasattr(c_var,'description'):
                                var['comment']= c_var.description
	                    if hasattr(c_var,'type'):
                                var['type']= c_var.type
	                    if hasattr(c_var,'valid_max'):
                                if isinstance(c_var.valid_max, (int, long, float, complex)):
                                    var['valid_max']= c_var.valid_max
	                    if hasattr(c_var,'valid_min'):
                                if isinstance(c_var.valid_min, (int, long, float, complex)): 
                                    var['valid_min']= c_var.valid_min

 	                    # Set what we can from the standard section
                            if hasattr(c_var,'stid'):
	                        s_var = dq.inx.uid[c_var.stid]
	                        if hasattr(s_var,'cell_measures'):
                                    var['cell_measures']= s_var.cell_measures
	                        if hasattr(s_var,'cell_methods'):
                                    var['cell_methods']= s_var.cell_methods
                                if hasattr(s_var,'coords'):
                                    #if len(s_var.coords)>0:
                                        if isinstance(s_var.cids,list) :
                                            var['coordinate'] = dq.inx.uid[s_var.cids[0]].label
                                            c = dq.inx.uid[s_var.cids[0]]
                                            if c not in axes_list and c != '' and c != 'None':
                                                axes_list.append(c)

                            # Set what we can from the time section
                            if hasattr(s_var, 'tmid'):
                                t_var = dq.inx.uid[s_var.tmid]
                                if hasattr(t_var,'dimensions'):
                                    t = t_var.dimensions
                                    if t != '' and t != 'None':
                                        var['time'] = t
                                        var['coordinates'] = t
                                if hasattr(t_var,'label'):
                                    var['time_label'] = t_var.label
                                if hasattr(t_var,'title'):
                                    var['time_title'] = t_var.title

                            # Is there did? 
                            if hasattr(s_var, 'dids'):
                                if isinstance(s_var.dids, tuple): 
                                    extra_dim = dq.inx.uid[s_var.dids[0]].label
                                    if 'coordinates' not in var.keys():
                                        var['coordinates'] = extra_dim
                                    else:
                                        var['coordinates'] = extra_dim + "|"+ var['coordinates']
                                    if extra_dim not in axes_list:
                                        axes_list.append(extra_dim) 

                            # Set what we can from the spatial section
                            if hasattr(s_var, 'spid'):
	                        sp_var = dq.inx.uid[s_var.spid]
	                        if hasattr(sp_var,'dimensions'):
                                    if len(sp_var.dimensions) > 1:
                                        if 'coordinates' in var.keys():
                                            sp_var_d = sp_var.dimensions
                                            if len(sp_var_d) > 1:
                                                if sp_var_d[-1] == '|':
                                                    sp_var_d = sp_var_d[:-1]
                                            var['coordinates'] = sp_var_d + '|' + var['coordinates']
                                        else:
                                            var['coordinates'] = sp_var.dimensions
                                        if 'grid_latitude' in var['coordinates']:
                                            var['coordinates'] = var['coordinates'].replace('grid_latitude','gridlatitude')
                                        dims = var['coordinates'].split('|')
                                        for d in dims:
                                            if d not in axes_list and d != '' and d != 'None':
                                                if 'copy' not in var['id'] and '?' not in d:
                                                    axes_list.append(d)
                            if 'coordinates' in var.keys(): 
                                if len(var['coordinates']) > 1:
                                    if var['coordinates'][-1] == '|':
                                        var['coordinates'] = var['coordinates'][:-1] 

	                    # Set what we can from the variable section
                            if hasattr(c_var, 'vid'):
                                v_var = dq.inx.uid[c_var.vid]
	                        if hasattr(v_var,'cf_standard_name'):
                                    var['cf_standard_name']= v_var.sn
	                        if hasattr(v_var,'long_name'):
                                    var['long_name']= v_var.sn
	                        if hasattr(v_var,'units'):
                                    if v_var.units == "":
                                        var['units']= 'None'
                                        print c_var.label, " does not have units" 
                                    else:
                                        var['units']= v_var.units

                            # Add variable to variable dictionary
                            variables[c_var.label] = var
                for a in axes_list:
                    if 'grid_latitude' in a:
                        a = 'gridlatitude'
                    if a in dq.inx.grids.label.keys():
                        id = dq.inx.grids.label[a]
                        if len(id) > 0:
                            v = dq.inx.grids.uid[id[0]]
                        ax = {}
                        if hasattr(v,'units'):
                            if v.units == "":
                                ax['units'] = '1'
                            else: 
                                ax['units'] = v.units
                        if hasattr(v,'value'):
                            ax['value'] = v.value
                        if hasattr(v,'axis'):
                            ax['axis'] = v.axis
                        if hasattr(v,'valid_max'):
                            if isinstance(v.valid_max, (int, long, float, complex)):        
                                ax['valid_max'] = v.valid_max
                        if hasattr(v,'valid_min'):
                            if isinstance(v.valid_min, (int, long, float, complex)):
                                ax['valid_min'] = v.valid_min
                        if hasattr(v,'standardName'):
                            if isinstance(v.standardName, (str)):
                                ax['standard_name'] = v.standardName
                            else:
                                ax['standard_name'] = a
                        if hasattr(v,'type'):
                            if 'landUse' in a:
                                ax['type'] = 'int'
                            else:
                                ax['type'] = v.type
                        if hasattr(v,'id'):
                            ax['id'] = v.label
                        if hasattr(v,'positive'):
                            ax['positive'] = v.positive
                        if hasattr(v,'direction'):
                            ax['direction'] = v.direction
                        if hasattr(v,'title'):
                            ax['title'] = v.title
                        if hasattr(v,'bounds'):
                            if 'yes' in v.bounds:
                                ax['bounds'] = v.label+"_bnds"
                        if hasattr(v,'requested'):
                            ax['requested'] = v.requested
                        #if hasattr(v,'boundsValues'):
                        #    ax['boundsValues'] = v.boundsValues
                        if hasattr(v,'coords'):
                            ax['coords'] = v.coords
                        axes[a] = ax
                    else:
                        v = a
                        print "Cannot find link for dimension: ",v
   
                try:
                    table_dict['variables'] = variables
                    table_dict['axes'] = axes
                except UnboundLocalError:
                    print 'Does not fit criteria: ', exp 
                table_dict['table_info'] = table_info
                tab = rvg.label
                table_info['table_id'] = tab
                total_request[dr.mip+'_'+tab] = table_dict
        #print 'Total in request:',len(total_request)
        #for k in sorted(total_request.keys()):
        #    v = total_request[k]
        #    print k, len(v['variables'])

        return total_request

