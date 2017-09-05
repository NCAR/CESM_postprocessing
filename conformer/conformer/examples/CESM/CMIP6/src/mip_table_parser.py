import sys

#=============================================
# Parse and Standardize the MIP table.
# Return a dcitionary that contains the parsed
# information.
#=============================================
def  mip_table_parser(table_name,type=None,user_vars={},user_axes={},user_tableInfo={}):
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
    return p.parse_table(table_name,table_var_fields,table_axes_fields,table_fields,
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
    def parse_table(self, table_name,table_var_fields,table_axes_fields,table_fields,
                    user_vars,user_axes,user_tableInfo):
        """
        Function will parse a tab deliminated file and return a dictionary containing
        the parsed fields.

        Parameter:
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
        import csv

	table_dict = {}

	output_var_keys = table_var_fields['id']
	variables = {}
	key = None
	longest = 0
	found = False
	fieldnames = []

        # First time reading the file:  Read the file and determine the longest line (first is recorded).
        # This line is assumed to contain the field names.
	f = open(table_name, 'rU')
	reader = (f.read().splitlines()) 
	for row in reader:
	    r = row.split('\t')
	    i = 0 
	    l = len(r)
	    for g in r:
		if g == '':
		    l = l-1
		i = i+1
	    if l > longest:
		fieldnames = list(r)   
		longest = l 

        # Second time reading the file:  Parse the file into a dictionary that uses the field
        # names found in the first read as the keys.
	reader = csv.DictReader(open(table_name, 'rU'), delimiter='\t',fieldnames=fieldnames)

        # Standardize the field  names and store in a final dictionary.
	for row in reader:
	    fields = {}
	    for k in row.keys():
	       if k in output_var_keys:
		   key = row[k]
	    for k,v in row.iteritems():
		if v != '':
		    var_key = _get_key(k, table_var_fields, user_vars)
		    fields[var_key] = v

	    variables[key] = fields

	table_dict['variables'] = variables

	return table_dict


#=============================================
# Parses standard CMOR table files
#=============================================
class ParseCmorTable(object):

    def _init_():
        super(ParseCmorTable, self).__init__()

    #=============================================
    #  Reset and get ready for a new variable set 
    #=============================================  
    def _reset(self, status, part, whole, name):

        whole[name] = part
        part = {}
        status = False
        return status, part, whole

    #=============================================
    #  Setup for the new entry group found
    #=============================================
    def _new_entry(self, status, part, whole, name, key, value):

        if len(part.keys()) > 0:
            whole[name] = part
        part = {}
        name = value
        part['id'] = value
        status = True
        return status, part, whole, name

    #=============================================
    #  Parse a CMOR text file
    #=============================================
    def parse_table(self, table_name,table_var_fields,table_axes_fields,table_fields,
                    user_vars,user_axes,user_tableInfo):
        """
        Function will parse a CMOR table text file and return a dictionary containing
        the parsed fields.

        Parameter:
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

        # Initialize needed dictionaries
	table_dict = {}
	table_info = {}
	expt_id_ok = {}
	axes = {}
	variables = {}
	subroutines = {}
	mapping = {}
        axis = {}
        var = {}
        sub = {}
        map = {} 

        # Status Variables
	current_axis = None
	current_var = None
	current_sub = None
	current_mapping = None
	in_axis = False
	in_var = False
	in_sub = False
	in_mapping = False

        # Open table file
        mip_file = open(table_name)

	for l in mip_file:
	    # if comment - don't proceed
	    #print l
	    l_no_comment = l.split('!')
	    l = l_no_comment[0].strip()
	    if len(l) > 0 and ':' in l:
		# remove anything after a comment character
		# parse the key from the value
		parts = l.split(':')
		if len(parts) > 2:
		    parts[1] = ''.join(parts[1:])
		key = parts[0].strip()
		value = parts[1].strip()
		#print l,'->',parts

		# add to table_info dictionary
                # Start an entry for 'expt_id_ok'
		if 'expt_id_ok' in key:
		    equiv = value.split("\' \'")
		    if len(equiv) == 2:
		       expt_id_ok[equiv[0]] = equiv[1]
		    elif len(equiv) == 1:
		       expt_id_ok[equiv[0]] = None
                # Start an entry for 'axis_entry'
		elif 'axis_entry' in key:
		    if in_var == True:
			in_var,var,variables = self.reset(in_var,var,variables,current_var)
		    if in_sub == True:
			in_sub,sub,subroutines = self._reset(in_sub,sub,subroutines,current_sub)
		    if in_mapping == True:
			in_mapping,map,maping = self._reset(in_mapping,map,mapping,current_mapping)
		    in_axis,axis,axes,current_axis = self._new_entry(in_axis,axis,axes,current_axis,key,value)
                # Start an entry for 'variable_entry'
		elif 'variable_entry' in key:
		    if in_axis == True:
			in_axis,axis,axes = self._reset(in_axis,axis,axes,current_axis)
		    if in_sub == True:
			in_sub,sub,subroutines = self._reset(in_sub,sub,subroutines,current_sub)
		    if in_mapping == True:
			in_mapping,map,maping = self._reset(in_mapping,map,mapping,current_mapping)
		    in_var,var,variables,current_var = self._new_entry(in_var,var,variables,current_var,key,value)
                # Start an entry for 'subroutine_entry'
		elif 'subroutine_entry' in key:
		    if in_axis == True:
			in_axis,axis,axes = self._reset(in_axis,axis,axes,current_axis)
		    if in_var == True:
			in_var,var,variables = self._reset(in_var,var,variables,current_var)
		    if in_mapping == True:
			in_mapping,map,maping = self._reset(in_mapping,map,mapping,current_mapping)
		    in_sub,sub,subroutines,current_sub = self._new_entry(in_sub,sub,subroutines,current_sub,key,value)
                # Start an entry for 'mapping_entry'
		elif 'mapping_entry' in key:
		    if in_axis == True:
			in_axis,axis,axes = self._reset(in_axis,axis,axes,current_axis)
		    if in_var == True:
			in_var,var,variables = self._reset(in_var,var,variables,current_var)
		    if in_sub == True:
			in_sub,sub,subroutines = self._reset(in_sub,sub,subroutines,current_sub)
		    in_mapping,map,maping,current_mapping = self._new_entry(in_mapping,map,mapping,current_mapping,key,value)
                # The new entry has been started.  If this point has been reached, parse this line into the correct standardized
                # field name under the current activated entry.
		else:
		    if (in_axis): #field added to axes variable
			axis_key = _get_key(key, table_axes_fields, user_axes) 
			axis[axis_key] = value
		    elif (in_var): #field added to variable
			var_key = _get_key(key, table_var_fields, user_vars)
			var[var_key] = value
		    elif (in_sub): #field added to subroutine
			sub[key] = value
		    elif (in_mapping): #field added to mapping
			map[key] = value
		    else: #field added to table information
			mip_key = _get_key(key, table_fields, user_tableInfo)
			table_info[mip_key] = value

        # Add final entry into its group dictionary
	if in_var == True:
	    variables[current_var] = var
	if in_axis == True:
	    axes[current_axis] = axis
	if in_sub == True:
	    subroutines[current_sub] = sub
	if in_mapping == True:
	    mapping[current_mapping] = map

        # Combine three separate dictionaries into the table summary dictionary
	table_dict['variables'] = variables
	table_dict['axes'] = axes
	table_dict['subroutines'] = subroutines
	table_dict['table_info'] = table_info

	return table_dict 

#=============================================
#  Parse the XML format
#=============================================
class ParseXML(object):

    def _init_():
        super(ParseXML, self, table_name,table_var_fields,table_axes_fields,table_fields).__init__()

    #=============================================
    # Parse the XML format using dreqPy
    #=============================================
    def parse_table(self, table_name,table_var_fields,table_axes_fields,table_fields,
                    user_vars,user_axes,user_tableInfo):
        """
        Function will parse an XML file using dreqPy and return a dictionary containing
        the parsed fields.

        Parameter:
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
        import dreq

        table_dict = {}

        variables = {}
        axes = {}
        table_info = {} 

        dq = dreq.loadDreq()

        # Get table id
        g_id = dq.inx.requestVarGroup.label[table_name]
       
        # Get the id's of the variables in this table
        g_vars = dq.inx.iref_by_sect[g_id[0]].a

        # Loop through the variables and set their values
        for v in g_vars['requestVar']:
	    var = {}
	    v_id = dq.inx.uid[v].vid  # Get the CMORvar id
	    c_var = dq.inx.uid[v_id]

	    # Set what we can from the CMORvar section
	    #var['comment']= c_var.comment
	    var['deflate']= c_var.deflate
	    var['deflate_level']= c_var.deflate_level
	    var['description']= c_var.description
	    #var['flag_meanings']= c_var.flag_meanings
	    #var['flag_values']= c_var.flag_values
	    var['frequency']= c_var.frequency
	    var['id']= c_var.label
	    var['modeling_realm']= c_var.modeling_realm
	    var['ok_min_mean_abs']= c_var.ok_min_mean_abs
	    var['ok_max_mean_abs']= c_var.ok_max_mean_abs
	    var['out_name']= c_var.label #?
	    var['positive']= c_var.positive
	    var['prov']= c_var.prov
	    var['provNote']= c_var.provNote
	    var['shuffle']= c_var.shuffle
	    var['title']= c_var.title
	    var['type']= c_var.type
	    var['valid_max']= c_var.valid_max
	    var['valid_min']= c_var.valid_min
 
  	    # Set what we can from the standard section
	    s_var = dq.inx.uid[c_var.stid]
	    var['cell_measures']= s_var.cell_measures
	    var['cell_methods']= s_var.cell_methods
 
	    # Set what we can from the sp section
	    sp_var = dq.inx.uid[s_var.spid]
	    var['dimensions']= sp_var.dimensions

	    # Set what we can from the variable section
	    v_var = dq.inx.uid[c_var.vid]
	    var['cf_standard_name']= v_var.sn
	    var['long_name']= v_var.sn
	    var['units']= v_var.units

	    #var['ext_cell_measures']=
	    #var['required']=

            # Add variable to variable dictionary
	    variables[c_var.label] = var
       
        table_dict['variables'] = variables

        return table_dict

# Generate CESM to CMIP5 Mapping json files
def xwalk(xWalk_fn):

    mip_table = {}

    j_fn = os.path.basename(xWalk_fn)
    j_fn = j_fn.replace('xwalk_','')
    json_f = open(j_fn+'.json', 'wb')

    xWalk_file = open(xWalk_fn)
    for e_line in xWalk_file:
        # initialize entry (line in table), split the line up, store values into entry
        e_line = e_line.strip()
        line = e_line.split(':')
        vn = line[1]
        formula = line[-1]

        json_f.write("{}\n".format(json.dumps(vn+'='+formula)))


# Open CMIP5 json files and compare it to CMIP6 parsed variables.
# For all CMIP6 needed variables for that table, find definition
# within the CMIP5 mapping files.  If not found (new variable within 
# CMIP), mark as MISSING. 
def json_parser(fn, mip_dict, t):

    new_dict = {}
    # Open table file
    f = open(fn)
    out = open('CMIP6_'+t+'.json','wb')

    # Create a new dictionary with variable names as keys from the CMIP5 json file
    for l in f:
        p1 = l.split('=')
        p2 = p1[0].replace('\"','')
        if p2 in mip_dict['variables'].keys():
            new_dict[p2] = l.rstrip()
        else:
            print p2,' in CMIP5, but not in CMIP6'
    # Loop through CMIP6 var to find definition on how to the var was derived in CMIP5
    #  New vars are marked as 'MISSING'
    for v in mip_dict['variables'].keys():
        if v in new_dict.keys():
            out.write(new_dict[v]+'\n')
        else:
            out.write('\"'+v+'= MISSING\"\n')     
    

import glob,json,os

# Look through all tables and create new CESM to CMIP6 mapping files
tables = ['3hr','6hrLev','6hrPlev','aero','Amon','cf3hr','cfDay','cfMon','cfOff','cfSites','day','fx','LImon','Lmon','Oclim','OImon','Omon','Oyr']
for t in tables:
    print t
    xml_table_dict = mip_table_parser(t,'xml')
    json_parser('../../CMIP5/CMIP5_'+t+'.json', xml_table_dict,t)
